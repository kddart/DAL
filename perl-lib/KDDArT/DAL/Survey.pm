#$Id$
#$Author$

# Copyright (c) 2011, Diversity Arrays Technology, All rights reserved.

# Author    : Puthick Hok
# Created   : 02/06/2010
# Modified  :
# Purpose   :
#
#

package KDDArT::DAL::Survey;

use strict;
use warnings;

BEGIN {
  use File::Spec;

  my ($volume, $current_dir, $file) = File::Spec->splitpath(__FILE__);

  my @current_dir_part = split('/perl-lib/KDDArT/DAL/', $current_dir);
  $main::kddart_base_dir = $current_dir_part[0];
}

use lib "$main::kddart_base_dir/perl-lib";

use base 'KDDArT::DAL::Transformation';

use KDDArT::DAL::Common;
use KDDArT::DAL::Security;
use CGI::Application::Plugin::Session;
use Log::Log4perl qw(get_logger :levels);
use XML::Checker::Parser;
use Crypt::Random qw( makerandom );
use Time::HiRes qw( tv_interval gettimeofday );
use DateTime;
use DateTime::Format::Pg;

sub setup {

  my $self = shift;

  CGI::Session->name("KDDArT_DAL_SESSID");

  __PACKAGE__->authen->init_config_parameters();
  __PACKAGE__->authen->check_login_runmodes(':all');
  __PACKAGE__->authen->check_content_type_runmodes(':all');
  __PACKAGE__->authen->check_rand_runmodes('add_survey',
                                           'update_survey',
                                           'delete_survey',
                                           'add_survey_trial_unit',
                                           'add_survey_trial_unit_bulk',
                                           'update_survey_trial_unit',
                                           'delete_survey_trial_unit',
                                           'add_survey_trait',
                                           'delete_survey_trait',
                                           'update_survey_trait',

  );
  __PACKAGE__->authen->count_session_request_runmodes(':all');
  __PACKAGE__->authen->check_signature_runmodes('add_survey',
                                                'update_survey',
                                                'delete_survey',
                                                'update_survey_trial_unit',
                                                'delete_survey_trial_unit',
                                                'delete_survey_trait',
                                                'update_survey_trait',
  );
  __PACKAGE__->authen->check_gadmin_runmodes();
  __PACKAGE__->authen->check_sign_upload_runmodes('add_survey_trial_unit',
                                                  'add_survey_trial_unit_bulk',
  );

  $self->run_modes(
    'add_survey'                                   => 'add_survey_runmode',
    'get_survey'                                   => 'get_survey_runmode',
    'update_survey'                                => 'update_survey_runmode',
    'delete_survey'                                => 'delete_survey_runmode',
    'list_survey_advanced'                         => 'list_survey_advanced_runmode',
    'add_survey_trial_unit'                        => 'add_survey_trial_unit_runmode',
    'add_survey_trial_unit_bulk'                   => 'add_survey_trial_unit_bulk_runmode',
    'get_survey_trial_unit'                        => 'get_survey_trial_unit_runmode',
    'update_survey_trial_unit'                     => 'update_survey_trial_unit_runmode',
    'delete_survey_trial_unit'                     => 'delete_survey_trial_unit_runmode',
    'list_survey_trial_unit'                       => 'list_survey_trial_unit_runmode',
    'update_survey_geography'                      => 'update_survey_geography_runmode',
    'add_survey_trait'                             => 'add_survey_trait_runmode',
    'list_survey_trait'                            => 'list_survey_trait_runmode',
    'get_survey_trait'                             => 'get_survey_trait_runmode',
    'delete_survey_trait'                          => 'delete_survey_trait_runmode',
    'update_survey_trait'                          => 'update_survey_trait_runmode',
  );

  my $logger = get_logger();
  Log::Log4perl::MDC->put('client_ip', $ENV{'REMOTE_ADDR'});

  if ( ! $logger->has_appenders() ) {
    my $app = Log::Log4perl::Appender->new(
                               "Log::Log4perl::Appender::Screen",
                               utf8 => undef
        );

    my $layout = Log::Log4perl::Layout::PatternLayout->new("[%d] [%H] [%X{client_ip}] [%p] [%F{1}:%L] [%M] [%m]%n");

    $app->layout($layout);

    $logger->add_appender($app);
  }
  $logger->level($DEBUG);

  $self->{logger} = $logger;

  my $domain_name = $COOKIE_DOMAIN->{$ENV{DOCUMENT_ROOT}};
  $self->logger->debug("COOKIE DOMAIN: $domain_name");

  $self->authen->config(LOGIN_URL => '');
  $self->session_config(
          CGI_SESSION_OPTIONS => [ "driver:File", $self->query, {Directory => $SESSION_STORAGE_PATH} ],
          SEND_COOKIE         => 0,
      );
}

sub add_survey_runmode {

=pod add_survey_HELP_START
{
"OperationName": "Add survey",
"Description": "Add a new survey to the system.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "survey",
"KDDArTFactorTable": "surveyfactor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='10' ParaName='SurveyId' /><Info Message='Survey (10) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '9','ParaName' : 'SurveyId'}],'Info' : [{'Message' : 'Survey (9) has been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error SurveyTypeId='Survey Type (111) does not exist.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'SurveyTypeId' : 'Survey Type (111) does not exist.'}]}"}],
"HTTPParameter": [{"Name": "surveylocation", "DataType": "polygon_wkt", "Description": "GIS field defining the polygon geometry object of the survey in a standard GIS well-known text.", "Type": "LCol", "Required": "0"},{"Name": "surveylocdt", "DataType": "timestamp", "Description": "DateTime of survey location", "Type": "LCol", "Required": "0"},{"Name": "currentloc", "DataType": "tinyint", "Description": "Flag to notify current location", "Type": "LCol", "Required": "0"},{"Name": "description", "DataType": "varchar", "Description": "Description for location", "Type": "LCol", "Required": "0"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};
  my $survey_err = 0;
  my $survey_err_aref = [];

  my $dbh_read = connect_kdb_read();

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read, 'survey');

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  my $survey_manager     = $query->param('SurveyManagerId');
  my $survey_type        = $query->param('SurveyTypeId');
  my $survey_name        = $query->param('SurveyName');
  my $survey_starttime   = $query->param('SurveyStartTime');

  my $survey_endtime = undef;

  if (defined $query->param('SurveyEndTime')) {

    if (length($query->param('SurveyEndTime')) > 0) {

      $survey_endtime = $query->param('SurveyEndTime');
    }
  }

  my $survey_note = undef;

  if (defined $query->param('SurveyNote')) {

    if (length($query->param('SurveyNote')) > 0) {

      $survey_note = $query->param('SurveyNote');
    }
  }

  my $survey_location  = '';

  if (length($query->param('surveylocation')) > 0) {

    $survey_location = $query->param('surveylocation');
  }

  if (length($survey_location) > 0) {

    my $dbh_gis_read = connect_gis_read();
    my ($is_wkt_err, $wkt_err_href) = is_valid_wkt_href($dbh_gis_read, {'surveylocation' => $survey_location}, ['POINT','MULTIPOINT']);
    $dbh_gis_read->disconnect();

    if ($is_wkt_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [$wkt_err_href]};

      return $data_for_postrun_href;
    }
  }

  my ($date_err, $date_href) = check_dt_href( { 'SurveyStartTime' => $survey_starttime } );

  if ($date_err) {

    push(@{$survey_err_aref}, $date_href);
    $survey_err = 1;
  }

  if (length($survey_endtime) > 0) {

    ($date_err, $date_href) = check_dt_href( { 'SurveyEndTime'   => $survey_endtime } );

    if ($date_err) {

      push(@{$survey_err_aref}, $date_href);
      $survey_err = 1;
    }
  }
  else {

    $survey_endtime = undef;
  }

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength, FactorValidRuleErrMsg, FactorValidRule  ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='surveyfactor'";

  my $dbh_k_read = connect_kdb_read();
  my $vcol_data = $dbh_k_read->selectall_hashref($sql, 'FactorId');

  my $vcol_param_data = {};
  my $vcol_len_info   = {};
  my $vcol_param_data_maxlen = {};
  my $pre_validate_vcol = {};

  for my $vcol_id (keys(%{$vcol_data})) {

    my $vcol_param_name = "VCol_${vcol_id}";
    my $vcol_value      = $query->param($vcol_param_name) ;
    if ($vcol_data->{$vcol_id}->{'CanFactorHaveNull'} != 1) {

      $vcol_param_data->{$vcol_param_name} = $vcol_value;
    }

    $vcol_len_info->{$vcol_param_name} = $vcol_data->{$vcol_id}->{'FactorValueMaxLength'};
    $vcol_param_data_maxlen->{$vcol_param_name} = $vcol_value;

    $pre_validate_vcol->{$vcol_param_name} = {
      'Rule' => $vcol_data->{$vcol_id}->{'FactorValidRule'},
      'Value'=> $vcol_value,
      'FactorId'=> $vcol_id,
      'RuleErrorMsg'=> $vcol_data->{$vcol_id}->{'FactorValidRuleErrMsg'},
      'CanFactorHaveNull' => $vcol_data->{$vcol_id}->{'CanFactorHaveNull'},
    };
  }

  my ($vcol_missing_err, $vcol_missing_href) = check_missing_href( $vcol_param_data );

  if ($vcol_missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$vcol_missing_href]};

    return $data_for_postrun_href;
  }

  my ($vcol_maxlen_err, $vcol_maxlen_href) = check_maxlen_href($vcol_param_data_maxlen, $vcol_len_info);

  if ($vcol_maxlen_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$vcol_maxlen_href]};

    return $data_for_postrun_href;
  }

  if (defined $survey_manager) {

    my $survey_manager_existence = record_existence($dbh_k_read, 'contact', 'ContactId', $survey_manager);

    if (!$survey_manager_existence) {

      my $err_msg = "Survey Manager ($survey_manager) does not exist.";

      push(@{$survey_err_aref}, {'SurveyManagerId' => $err_msg});
      $survey_err = 1;
    }
  }

  my $survey_type_existence = type_existence($dbh_k_read, 'survey', $survey_type);

  if (!$survey_type_existence) {

    my $err_msg = "Survey Type ($survey_type) does not exist.";

    push(@{$survey_err_aref}, {'SurveyTypeId' => $err_msg});
    $survey_err = 1;
  }

  #prevalidate values to be finished in later version

  my ($vcol_error, $vcol_error_aref) = validate_all_factor_input($pre_validate_vcol);

  if ($vcol_error) {
    push(@{$survey_err_aref}, @{$vcol_error_aref});
    $survey_err = 1;
  }

  if ($survey_err != 0) {

    $dbh_k_read->disconnect();

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => $survey_err_aref};
    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write(1);

  eval {
    $sql    = 'INSERT INTO survey SET ';
    $sql   .= 'SurveyManagerId=?, ';
    $sql   .= 'SurveyTypeId=?, ';
    $sql   .= 'SurveyName=?, ';
    $sql   .= 'SurveyStartTime=?, ';
    $sql   .= 'SurveyEndTime=?, ';
    $sql   .= 'SurveyNote=?';

    my $sth = $dbh_k_write->prepare($sql);
    $sth->execute($survey_manager, $survey_type, $survey_name, $survey_starttime, $survey_endtime, $survey_note);
    my $survey_id = $dbh_k_write->last_insert_id(undef, undef, 'survey', 'SurveyId');
    $sth->finish();

    for my $vcol_id (keys(%{$vcol_data})) {

      my $factor_value = $query->param('VCol_' . "$vcol_id");

      if (length($factor_value) > 0) {

        $sql  = 'INSERT INTO surveyfactor SET ';
        $sql .= 'SurveyId=?, ';
        $sql .= 'FactorId=?, ';
        $sql .= 'FactorValue=?';
        my $factor_sth = $dbh_k_write->prepare($sql);
        $factor_sth->execute($survey_id, $vcol_id, $factor_value);
        $factor_sth->finish();
      }
    }

    if (length($survey_location) > 0) {
      my $sub_PGIS_val_builder = sub {
        my $wkt = shift;
        if ($wkt =~ /^POINT/i) {
          return "ST_ForceCollection(ST_Multi(ST_GeomFromText(?, -1)))";
        } else {
          return "ST_ForceCollection(ST_GeomFromText(?, -1))";
        }
      };
      my ($err, $err_msg) = append_geography_loc(
                                                  "survey",
                                                  $survey_id,
                                                  ['POINT','MULTIPOINT'],
                                                  $query,
                                                  $sub_PGIS_val_builder,
                                                  $self->logger,
                                                );
      if ($err) {
        eval {$dbh_k_write->rollback;};
        $data_for_postrun_href = $self->_set_error($err_msg);
        return 1;
      }
    }

    $dbh_k_write->commit;

    my $info_msg_aref = [{'Message' => "Survey ($survey_id) has been added successfully."}];
    my $return_id_aref = [{'Value' => "$survey_id", 'ParaName' => 'SurveyId'}];

    $data_for_postrun_href->{'Error'}     = 0;
    $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                            'ReturnId' => $return_id_aref,
    };
    $data_for_postrun_href->{'ExtraData'} = 0;

    1;
  } or do {
    eval {$dbh_k_write->rollback;};
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};
    return $data_for_postrun_href;
  };

  $dbh_k_write->disconnect();
  return $data_for_postrun_href;

}

sub logger {

  my $self = shift;
  return $self->{logger};
}

sub _set_error {

  my ( $self, $error_message ) = @_;
  return {
    'Error' => 1,
    'Data'  => { 'Error' => [ { 'Message' => $error_message || 'Unexpected error.' } ] }
  };
}

sub list_survey {
  my $self            = $_[0];
  my $extra_attr_yes  = $_[1];
  my $field_list      = $_[2];
  my $sql             = $_[3];
  my $where_para_aref = [];

  if (defined $_[4]) {

    $where_para_aref = $_[4];
  }

  my $err = 0;
  my $msg = '';

  my $data_aref = [];

  my $count = 0;
  while ($sql =~ /\?/g) {

    $count += 1;
  }

  if ( scalar(@{$where_para_aref}) != $count ) {

    my $msg = 'Number of arguments does not match with ';
    $msg   .= 'number of SQL parameter.';
    return (1, $msg, []);
  }

  my $dbh = connect_kdb_read();

  ($err, $msg, $data_aref) = read_data($dbh, $sql, $where_para_aref);

  if ($err) {

    return ($err, $msg, []);
  }

  my $field_list_loc_href = {};
  for my $field (@{$field_list}) {
    if ($field eq 'Longitude' || $field eq 'Latitude' || $field eq 'LCol*' || $field eq 'surveylocation') {
      $field_list_loc_href->{$field} = 1;
    }
  }

  my $survey_id_list = [];

  for my $survey_rec (@{$data_aref}) {

    push(@{$survey_id_list}, $survey_rec->{'SurveyId'});
  }

  my $extra_attr_survey_data = [];

  if (scalar @$survey_id_list) {

    my $survey_gis_href = {};

    if (scalar keys %$field_list_loc_href) {

      my $dbh_gis = connect_gis_read();
      $sql  = 'SELECT surveyid, surveylocdt, description, ST_AsText(surveylocation) AS surveylocation ';
      $sql .= 'FROM surveyloc ';
      $sql .= 'WHERE surveyid IN (' . join(',', @$survey_id_list) . ') AND currentloc = 1';

      my $sth_gis = $dbh_gis->prepare($sql);
      $sth_gis->execute();

      if (!$dbh_gis->err()) {
        my $gis_href = $sth_gis->fetchall_hashref('surveyid');
        if (!$sth_gis->err()) {
          $survey_gis_href = $gis_href;
        } else {
          $self->logger->debug('Err: ' . $dbh_gis->errstr());
          return (1, 'Unexpected error.');
        }
      } else {
        $self->logger->debug('Err: ' . $dbh_gis->errstr());
        return (1, 'Unexpected error.');
      }

      $sth_gis->finish();
      $dbh_gis->disconnect();
    }

    if ($extra_attr_yes) {
      #extra attributes for survey
    }

    for my $row (@{$data_aref}) {

      my $survey_id = $row->{'SurveyId'};

      if ($extra_attr_yes) {
        $row->{'update'}   = "update/survey/$survey_id";
      }

      if ($field_list_loc_href->{'LCol*'} || $field_list_loc_href->{'surveylocation'}) {
        $row->{'surveylocation'} = $survey_gis_href->{$survey_id}->{'surveylocation'};
        $row->{'surveylocdt'} = $survey_gis_href->{$survey_id}->{'surveylocdt'};
        $row->{'surveylocdescription'} = $survey_gis_href->{$survey_id}->{'description'};
      }

      push(@{$extra_attr_survey_data}, $row);
    }
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_survey_data);

}

sub get_survey_runmode {

=pod get_survey_HELP_START
{
"OperationName": "Get survey",
"Description": "Get detailed information about a survey specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='Survey' /><Survey SurveyTypeId='2' surveylocation='GEOMETRYCOLLECTION(POINT(149.1057021617679 -35.317184619919445))' SurveyId='1' SurveyManagerId='6' SurveyStartTime='2023-03-15 00:00:00' surveylocdt='2023-04-11 05:14:57' SurveyEndTime='2023-04-15 00:00:00' surveylocdescription='' SurveyNote='SurveyNote' update='update/survey/1' SurveyName='Survey_06481870235'/></DATA>",
"SuccessMessageJSON": "{'VCol' : [],'RecordMeta' : [{'TagName' : 'Survey'}],'Survey' : [{ 'surveylocdt' : '2023-04-11 05:19:20', 'update' : 'update/survey/2', 'SurveyNote' : 'SurveyNote', 'SurveyId' : 2, 'surveylocation' : 'GEOMETRYCOLLECTION(POINT(149.1057021617679 -35.317184619919445))', 'SurveyStartTime' : '2023-03-15 00:00:00', 'surveylocdescription' : '', 'SurveyTypeId' : 25, 'SurveyEndTime' : '2023-04-15 00:00:00', 'SurveyManagerId' : 26, 'SurveyName' : 'Survey_28959317320' }]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Survey (20) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Survey (20) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SurveyId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self    = shift;
  my $survey_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();
  my $survey_exist = record_existence($dbh, 'survey', 'SurveyId', $survey_id);

  if (!$survey_exist) {

    my $err_msg = "Survey ($survey_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $field_list = ['survey.*', 'generaltype.TypeName AS SurveyTypeName', 'VCol*', 'LCol*',
                    "concat(contact.ContactFirstName, concat(' ', contact.ContactLastName)) As SurveyManagerName"];

  my $other_join = ' LEFT JOIN generaltype ON survey.SurveyTypeId = generaltype.TypeId ';
  $other_join   .= ' LEFT JOIN contact ON survey.SurveyManagerId = contact.ContactId ';

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $field_list, 'survey',
                                                                        'SurveyId', $other_join);
  $dbh->disconnect();

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql   .= ' HAVING SurveyId=?';

  $self->logger->debug("SQL with VCol: $sql");

  my ($read_survey_err, $read_survey_msg, $survey_data) = $self->list_survey(1, $field_list, $sql, [$survey_id]);

  if ($read_survey_err) {

    $self->logger->debug($read_survey_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Data'}    = {'Survey'       => $survey_data,
                                         'VCol'         => $vcol_list,
                                         'RecordMeta'   => [{'TagName' => 'Survey'}]};

  return $data_for_postrun_href;

}

sub update_survey_runmode {

=pod update_survey_HELP_START
{
"OperationName": "Update survey",
"Description": "Update information about a survey specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "survey",
"KDDArTFactorTable": "surveyfactor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Survey (1) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Survey (1) has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Survey (20) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Survey (20) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SurveyId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $survey_id = $self->param('id');
  my $query      = $self->query();

  my $data_for_postrun_href = {};
  my $survey_err = 0;
  my $survey_err_aref = [];

  my $sql;

  my $dbh_read = connect_kdb_read();

  my $skip_field = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read, 'survey', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  my $dbh_k_read = connect_kdb_read();

  my $survey_exist = record_existence($dbh_k_read, 'survey', 'SurveyId', $survey_id);

  if (!$survey_exist) {

    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => "Survey ($survey_id) not found."}]};

    return $data_for_postrun_href;
  }

  my $survey_manager     = $query->param('SurveyManagerId');
  my $survey_type        = $query->param('SurveyTypeId');
  my $survey_name        = $query->param('SurveyName');
  my $survey_starttime   = $query->param('SurveyStartTime');

  my $read_survey_sql      =  'SELECT SurveyEndTime, SurveyNote ';
  $read_survey_sql        .=  'FROM survey WHERE SurveyId=? ';

  my ($r_df_val_err, $r_df_val_msg, $survey_df_val_data) = read_data($dbh_k_read, $read_survey_sql, [$survey_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve survey default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $survey_endtime    =  undef;
  my $survey_note       =  undef;

  my $nb_df_val_rec    =  scalar(@{$survey_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve survey default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $survey_endtime     =  $survey_df_val_data->[0]->{'SurveyEndTime'};
  $survey_note        =  $survey_df_val_data->[0]->{'SurveyNote'};

  if (defined $query->param('SurveyEndTime')) {

    if (length($query->param('SurveyEndTime')) > 0) {

      $survey_endtime = $query->param('SurveyEndTime');
    }
  }

  if (defined $query->param('SurveyNote')) {

    if (length($query->param('SurveyNote')) > 0) {

      $survey_note = $query->param('SurveyNote');
    }
  }

  if ($survey_endtime eq '0000-00-00 00:00:00') {

    $survey_endtime = undef;
  }

  my $survey_manager_existence = record_existence($dbh_k_read, 'contact', 'ContactId', $survey_manager);

  if (!$survey_manager_existence) {

      my $err_msg = "Survey Manager ($survey_manager) does not exist.";

      push(@{$survey_err_aref}, {'SurveyManagerId' => $err_msg});
      $survey_err = 1;
    }

  my $survey_type_existence = type_existence($dbh_k_read, 'survey', $survey_type);

  if (!$survey_type_existence) {

    my $err_msg = "Survey Type ($survey_type) does not exist.";

    push(@{$survey_err_aref}, {'SurveyTypeId' => $err_msg});
    $survey_err = 1;
  }

  $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength, FactorValidRuleErrMsg, FactorValidRule  ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='surveyfactor'";

  my $dbh_k_read = connect_kdb_read();
  my $vcol_data = $dbh_k_read->selectall_hashref($sql, 'FactorId');

  my $vcol_param_data = {};
  my $vcol_len_info   = {};
  my $vcol_param_data_maxlen = {};
  my $pre_validate_vcol = {};

  for my $vcol_id (keys(%{$vcol_data})) {

    my $vcol_param_name = "VCol_${vcol_id}";
    my $vcol_value      = $query->param($vcol_param_name) ;
    if ($vcol_data->{$vcol_id}->{'CanFactorHaveNull'} != 1) {

      $vcol_param_data->{$vcol_param_name} = $vcol_value;
    }

    $vcol_len_info->{$vcol_param_name} = $vcol_data->{$vcol_id}->{'FactorValueMaxLength'};
    $vcol_param_data_maxlen->{$vcol_param_name} = $vcol_value;

    $pre_validate_vcol->{$vcol_param_name} = {
      'Rule' => $vcol_data->{$vcol_id}->{'FactorValidRule'},
      'Value'=> $vcol_value,
      'FactorId'=> $vcol_id,
      'RuleErrorMsg'=> $vcol_data->{$vcol_id}->{'FactorValidRuleErrMsg'},
      'CanFactorHaveNull' => $vcol_data->{$vcol_id}->{'CanFactorHaveNull'},
    };
  }

  my ($vcol_missing_err, $vcol_missing_href) = check_missing_href( $vcol_param_data );

  if ($vcol_missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$vcol_missing_href]};

    return $data_for_postrun_href;
  }

  my ($vcol_maxlen_err, $vcol_maxlen_href) = check_maxlen_href($vcol_param_data_maxlen, $vcol_len_info);

  if ($vcol_maxlen_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$vcol_maxlen_href]};

    return $data_for_postrun_href;
  }

  my ($date_err, $date_href) = check_dt_href( { 'SurveyStartTime' => $survey_starttime } );

  if ($date_err) {

      push(@{$survey_err_aref}, $date_href);
      $survey_err = 1;
    }

  if (length($survey_endtime) > 0) {

    ($date_err, $date_href) = check_dt_href( { 'SurveyEndTime'   => $survey_endtime } );

    if ($date_err) {

      push(@{$survey_err_aref}, $date_href);
      $survey_err = 1;
    }
  }
  else {

    $survey_endtime = undef;
  }

  #prevalidate values to be finished in later version

  my ($vcol_error, $vcol_error_aref) = validate_all_factor_input($pre_validate_vcol);

  if ($vcol_error) {
    push(@{$survey_err_aref}, @{$vcol_error_aref});
    $survey_err = 1;
  }

  if ($survey_err != 0) {

    $dbh_k_read->disconnect();

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => $survey_err_aref};
    return $data_for_postrun_href;
  }


  my $dbh_k_write = connect_kdb_write();

  $sql    = 'UPDATE survey SET ';
  $sql   .= 'SurveyManagerId=?, ';
  $sql   .= 'SurveyTypeId=?, ';
  $sql   .= 'SurveyName=?, ';
  $sql   .= 'SurveyStartTime=?, ';
  $sql   .= 'SurveyEndTime=?, ';
  $sql   .= 'SurveyNote=? ';
  $sql   .= 'WHERE SurveyId=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($survey_manager, $survey_type, $survey_name, $survey_starttime, $survey_endtime, $survey_note, $survey_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  my $vcol_error = [];

  for my $vcol_id (keys(%{$vcol_data})) {

    if (defined $query->param('VCol_' . "$vcol_id")) {

      my $factor_value = $query->param('VCol_' . "$vcol_id");

      my ($vcol_err, $vcol_msg) = update_factor_value($dbh_k_write, $vcol_id, $factor_value, 'surveyfactor', 'SurveyId', $survey_id);

      if ($vcol_err) {

        $self->logger->debug("VCol_" . "$vcol_id => $vcol_msg" );

        push(@{$survey_err_aref}, {'VCol_' . "$vcol_id" => $vcol_msg});

        $survey_err = 1;
      }
    }
  }

  my $info_msg_aref = [{'Message' => "Survey ($survey_id) has been updated successfully."}];

  $dbh_k_write->disconnect();

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;

}


sub delete_survey_runmode {
=pod delete_survey_HELP_START
{
"OperationName": "Delete survey",
"Description": "Delete survey for a specified id. Survey can be deleted only if not attached to any lower level related record.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Survey (14) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Survey (15) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdUsed": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Survey (1) has trial unit(s).' /></DATA>"}],
"ErrorMessageJSON": [{"IdUsed": "{'Error' : [{'Message' : 'Survey (1) has trial unit(s).'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SurveyId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $survey_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_k_read = connect_kdb_read();

  my $survey_exist = record_existence($dbh_k_read, 'survey', 'SurveyId', $survey_id);

  if (!$survey_exist) {

    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => "Survey ($survey_id) not found."}]};

    return $data_for_postrun_href;
  }

  my $survey_trait = record_existence($dbh_k_read, 'surveytrait', 'SurveyId', $survey_id);

  if ($survey_trait) {

    my $err_msg = "Survey ($survey_id) has trait(s).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $survey_surveytrialunit = record_existence($dbh_k_read, 'surveytrialunit', 'SurveyId', $survey_id);

  if ($survey_surveytrialunit) {

    my $err_msg = "Survey ($survey_id) has trial units(s).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_gis_write = connect_gis_write();

  my $sql = 'DELETE FROM surveyloc WHERE surveyid=?';

  my $sth = $dbh_gis_write->prepare($sql);
  $sth->execute($survey_id);

  if ($dbh_gis_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_gis_write->disconnect();

  my $dbh_k_write = connect_kdb_write();

  $sql = "DELETE FROM surveyfactor WHERE SurveyId=?";
  $sth = $dbh_k_write->prepare($sql);

  $sth->execute($survey_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $sql = "DELETE FROM survey WHERE SurveyId=?";
  $sth = $dbh_k_write->prepare($sql);

  $sth->execute($survey_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref = [{'Message' => "Survey ($survey_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_survey_advanced_runmode {

=pod list_survey_advanced_HELP_START
{
"OperationName": "List surveys",
"Description": "List surveys available in the system. This listing requires pagination information.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination NumOfRecords='10' NumOfPages='10' Page='1' NumPerPage='1' /><RecordMeta TagName='Survey' /><Survey SurveyTypeId='2' surveylocation='GEOMETRYCOLLECTION(POINT(149.1057021617679 -35.317184619919445))' SurveyId='1' SurveyManagerId='6' SurveyStartTime='2023-03-15 00:00:00' surveylocdt='2023-04-11 05:14:57' SurveyEndTime='2023-04-15 00:00:00' surveylocdescription='' SurveyNote='SurveyNote' update='update/survey/1' SurveyName='Survey_06481870235'/><RecordMeta TagName='Survey'/></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfRecords' : '10','NumOfPages' : 10,'NumPerPage' : '1','Page' : '1'}],'VCol' : [],'RecordMeta' : [{'TagName' : 'Survey'}],'Survey' : [{ 'surveylocdt' : '2023-04-11 05:19:20', 'update' : 'update/survey/2', 'SurveyNote' : 'SurveyNote', 'SurveyId' : 2, 'surveylocation' : 'GEOMETRYCOLLECTION(POINT(149.1057021617679 -35.317184619919445))', 'SurveyStartTime' : '2023-03-15 00:00:00', 'surveylocdescription' : '', 'SurveyTypeId' : 25, 'SurveyEndTime' : '2023-04-15 00:00:00', 'SurveyManagerId' : 26, 'SurveyName' : 'Survey_28959317320' }] }",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"URLParameter": [{"ParameterName": "nperpage", "Description": "Number of records in a page for pagination"}, {"ParameterName": "num", "Description": "The page number of the pagination"}],
"HTTPParameter": [{"Required": 0, "Name": "Filtering", "Description": "Filtering parameter string consisting of filtering expressions which are separated by ampersand (&) which needs to be encoded if HTTP GET method is used. Each filtering expression is composed of a database field name, a filtering operator and the filtering value."}, {"Required": 0, "Name": "FieldList", "Description": "Comma separated value of wanted fields."}, {"Required": 0, "Name": "Sorting", "Description": "Comma separated value of SQL sorting phrases."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $pagination  = 0;
  my $nb_per_page = -1;
  my $page        = -1;

  if ( (defined $self->param('nperpage')) && (defined $self->param('num')) ) {

    $pagination = 1;
    $nb_per_page = $self->param('nperpage');
    $page        = $self->param('num');
  }

  my $field_list_csv = '';

  if (defined $query->param('FieldList')) {

    $field_list_csv = $query->param('FieldList');
  }

  my $filtering_csv = '';

  if (defined $query->param('Filtering')) {

    $filtering_csv = $query->param('Filtering');
  }

  if (defined $self->param('surveyid')) {

    my $survey_id = $self->param('surveyid');

    if ($filtering_csv =~ /SurveyId=(.*),?/) {

      if ( "$survey_id" ne "$1" ) {

        my $err_msg = 'Duplicate filtering condition for SurveyId.';
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
    else {

      if (length($filtering_csv) > 0) {

        if ($filtering_csv =~ /&$/) {

          $filtering_csv .= "SurveyId=$survey_id";
        }
        else {

          $filtering_csv .= "&SurveyId=$survey_id";
        }
      }
      else {

        $filtering_csv .= "SurveyId=$survey_id";
      }
    }
  }

  $self->logger->debug("Filtering csv: $filtering_csv");

  my $sorting = '';

  if (defined $query->param('Sorting')) {
    $sorting = $query->param('Sorting');
  }

  my $dbh = connect_kdb_read();
  my $field_list = ['survey.*', 'VCol*', 'LCol*'];

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $field_list, 'survey', 'SurveyId', '');
  $self->logger->debug("SQL 1: $sql");

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql   .= " LIMIT 1;";

  $self->logger->debug("SQL with VCol: $sql");

  my ($sam_survey_err, $sam_survey_msg, $sam_survey_data) = $self->list_survey(0, $field_list, $sql);

  if ($sam_survey_err) {

    $self->logger->debug($sam_survey_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $sample_data_aref = $sam_survey_data;

  my @field_list_all;

  if (scalar(@{$sample_data_aref}) == 1) {

    @field_list_all = keys(%{$sample_data_aref->[0]});
  }
  else {

    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'survey');

    if ($sfield_err) {

      $self->logger->debug("Get static field failed: $sfield_msg");
      return $self->_set_error();
    }

    for my $sfield_rec (@{$sfield_data}) {

      push(@field_list_all, $sfield_rec->{'Name'});
    }

    for my $pkey_field (@{$pkey_data}) {

      push(@field_list_all, $pkey_field);
    }
  }

  $self->logger->debug("Field list all: " . join(',', @field_list_all));

  my $final_field_list = \@field_list_all;
  my $sql_field_list   = [];

  if (length($field_list_csv) > 0) {

    my ($sel_field_err, $sel_field_msg, $sel_field_list) = parse_selected_field($field_list_csv,
                                                                                $final_field_list,
                                                                                'SurveyId');

    if ($sel_field_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;

    for my $fd_name (@$final_field_list) {
      # need to remove location field because generate_factor_sql does not understand these field
      if ( (!($fd_name =~ /Longitude/)) &&
            (!($fd_name =~ /Latitude/)) &&
            (!($fd_name =~ /surveylocation/)) &&
            (!($fd_name =~ /surveylocdt/)) &&
            (!($fd_name =~ /surveylocdescription/))) {
        push(@$sql_field_list, $fd_name);
      }
    }
  } else {
      for my $fd_name (@$final_field_list) {
      # need to remove location field because generate_factor_sql does not understand these field
      if ( (!($fd_name =~ /Longitude/)) &&
            (!($fd_name =~ /Latitude/)) &&
            (!($fd_name =~ /surveylocation/)) &&
            (!($fd_name =~ /surveylocdt/)) &&
            (!($fd_name =~ /surveylocdescription/))) {
        push(@$sql_field_list, $fd_name);
      }
    }
  }

  my $field_lookup = {};
  for my $fd_name (@{$sql_field_list}) {

    $field_lookup->{$fd_name} = 1;
  }

  my $other_join = '';

  if ($filtering_csv !~ /Factor/) {

    ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $sql_field_list,
                                                                                    'survey',
                                                                                    'SurveyId',
                                                                                    $other_join);
  }
  else {

    ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql_v2($dbh, $sql_field_list,
                                                                                       'survey',
                                                                                       'SurveyId',
                                                                                       $other_join);
  }

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($filter_err, $filter_msg,
      $filter_phrase, $where_arg,
      $having_phrase, $count_filter_phrase,
      $nb_filter_factor) = parse_filtering_v2('SurveyId',
                                              'survey',
                                              $filtering_csv,
                                              $final_field_list,
                                              $vcol_list);

  $self->logger->debug("Filter phrase: $filter_phrase");

  if ($filter_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $filter_msg}]};

    return $data_for_postrun_href;
  }

  my $filtering_exp = '';

  if (length($filter_phrase) > 0) {

    $filtering_exp = " WHERE $filter_phrase ";
  }

  if (length($having_phrase) > 0) {

    $sql =~ s/FACTORHAVING/ HAVING $having_phrase/;

    $sql .= " $filtering_exp ";
  }
  else {

    $sql =~ s/GROUP BY/ $filtering_exp GROUP BY /;
  }

  my $pagination_aref    = [];
  my $paged_limit_clause = '';
  my $paged_limit_elapsed;

  if ($pagination) {

    my ($int_err, $int_err_msg) = check_integer_value( {'nperpage' => $nb_per_page,
                                                        'num'      => $page
                                                       });

    if ($int_err) {

      $int_err_msg .= ' not integer.';
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $int_err_msg}]};

      return $data_for_postrun_href;
    }

    $self->logger->debug("Filtering expression: $filtering_exp");

    my $paged_limit_start_time = [gettimeofday()];

    my ($pg_id_err, $pg_id_msg, $nb_records,
        $nb_pages, $limit_clause, $rcount_time);

    if (length($having_phrase) == 0) {

      $self->logger->debug("COUNT NB RECORD: NO FACTOR IN FILTERING");

      ($pg_id_err, $pg_id_msg, $nb_records,
       $nb_pages, $limit_clause, $rcount_time) = get_paged_filter($dbh,
                                                                  $nb_per_page,
                                                                  $page,
                                                                  'survey',
                                                                  'SurveyId',
                                                                  $filtering_exp,
                                                                  $where_arg);
    }
    else {

      $self->logger->debug("COUNT NB RECORD: FACTOR IN FILTERING");

      my $count_sql = "SELECT COUNT(survey.SurveyId) ";
      $count_sql   .= "FROM survey INNER JOIN ";
      $count_sql   .= " (SELECT SurveyId, COUNT(SurveyId) ";
      $count_sql   .= " FROM surveyfactor WHERE $count_filter_phrase ";
      $count_sql   .= " GROUP BY SurveyId HAVING COUNT(SurveyId)=$nb_filter_factor) AS subq ";
      $count_sql   .= "ON survey.SurveyId = subq.SurveyId ";
      $count_sql   .= "$filtering_exp";

      $self->logger->debug("COUNT SQL: $count_sql");

      ($pg_id_err, $pg_id_msg, $nb_records,
       $nb_pages, $limit_clause, $rcount_time) = get_paged_filter_sql($dbh,
                                                                      $nb_per_page,
                                                                      $page,
                                                                      $count_sql,
                                                                      $where_arg);

      $self->logger->debug("COUNT WITH Factor TIME: $rcount_time");
    }

    $paged_limit_elapsed = tv_interval($paged_limit_start_time);

    $self->logger->debug("SQL Row count time: $rcount_time");

    if ($pg_id_err == 1) {

      $self->logger->debug($pg_id_msg);

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    if ($pg_id_err == 2) {

      $page = 0;
    }

    $pagination_aref = [{'NumOfRecords' => $nb_records,
                         'NumOfPages'   => $nb_pages,
                         'Page'         => $page,
                         'NumPerPage'   => $nb_per_page,
                        }];

    $paged_limit_clause = $limit_clause;
  }

  $dbh->disconnect();

  my ($sort_err, $sort_msg, $sort_sql) = parse_sorting($sorting, $final_field_list);

  if ($sort_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sort_msg}]};

    return $data_for_postrun_href;
  }

  if (length($sort_sql) > 0) {

    $sql .= " ORDER BY $sort_sql ";
  }
  else {

    $sql .= ' ORDER BY survey.SurveyId DESC';
  }

  $sql .= " $paged_limit_clause ";

  $self->logger->debug("SQL with VCol: $sql");
  $self->logger->debug("Where arg: " . join(',', @{$where_arg}));

  my $data_start_time = [gettimeofday()];

  # where_arg here in the list function because of the filtering
  my ($read_sur_err, $read_sur_msg, $sur_data) = $self->list_survey(1, $final_field_list, $sql, $where_arg);

  my $data_elapsed = tv_interval($data_start_time);

  if ($read_sur_err) {

    $self->logger->debug($read_sur_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Survey'       => $sur_data,
                                           'VCol'         => $vcol_list,
                                           'Pagination'   => $pagination_aref,
                                           'RecordMeta'   => [{'TagName' => 'Survey'}],
  };

  return $data_for_postrun_href;

}

sub add_survey_trial_unit_runmode {

=pod add_survey_trial_unit_HELP_START
{
"OperationName": "Add trial unit to the survey",
"Description": "Add a new trial unit to the survey specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "surveytrialunit",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='70' ParaName='SurveyTrialUnitId' /><Info Message='SurveyTrialUnit (70) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '71','ParaName' : 'SurveyTrialUnitId'}],'Info' : [{'Message' : 'SurveyTrialUnit (71) has been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Survey (123) does not exist.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Survey (123) does not exist.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SurveyId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};
  my $sql;

  my $dbh_read = connect_kdb_read();

  my $skip_field = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'surveytrialunit', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  my $survey_id = $self->param('id');

  my $trial_unit_id   = undef;

  if (defined $query->param('TrialUnitId')) {

    if (length($query->param('TrialUnitId')) > 0) {

      $trial_unit_id = $query->param('TrialUnitId');
    }
  }

  my $visit_time  = undef;

  if (defined $query->param('VisitTime')) {

    $visit_time = $query->param('VisitTime');
  }

  my $visit_order  = undef;

  if (defined $query->param('VisitOrder')) {

    $visit_order = $query->param('VisitOrder');
  }

  my $collector_id = undef;

  if (defined $query->param('CollectorId')) {

    $collector_id = $query->param('CollectorId');
  }

  my $dbh_k_write = connect_kdb_write();

  my $survey_existence = record_existence($dbh_k_write, 'survey', 'SurveyId', $survey_id);

  if (!$survey_existence) {

    my $err_msg = "Survey ($survey_id) does not exist.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trial_unit_existence = record_existence($dbh_k_write, 'trialunit', 'TrialUnitId', $trial_unit_id);

  if (!$trial_unit_existence) {

    my $err_msg = "TrialUnitId ($trial_unit_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TrialUnitId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql    = 'INSERT INTO surveytrialunit SET ';
  $sql   .= 'SurveyId=?, ';
  $sql   .= 'TrialUnitId=?, ';
  $sql   .= 'VisitTime=?, ';
  $sql   .= 'VisitOrder=?, ';
  $sql   .= 'CollectorId=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($survey_id, $trial_unit_id, $visit_time, $visit_order, $collector_id);

  if ($dbh_k_write->err()) {

    $self->logger->debug("SQL Error:" . $dbh_k_write->errstr());
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  my $survey_trial_unit_id = $dbh_k_write->last_insert_id(undef, undef, 'survey', 'SurveyTrialUnitId');

  $dbh_k_write->disconnect();

  my $info_msg_aref  = [{'Message' => "SurveyTrialUnit ($survey_trial_unit_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$survey_trial_unit_id", 'ParaName' => 'SurveyTrialUnitId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;

}

sub list_survey_trial_unit {
  my $self            = $_[0];
  my $extra_attr_yes  = $_[1];
  my $gis_field_list  = $_[2];
  my $sql             = $_[3];
  my $where_para_aref = [];

  if (defined $_[4]) {

    $where_para_aref   = $_[4];
  }

  my $err = 0;
  my $msg = '';

  my $data_aref = [];
  my $extra_attr_survey_data = [];

  my $dbh = connect_kdb_read();

  ($err, $msg, $data_aref) = read_data($dbh, $sql, $where_para_aref);

  if ($err) {

    return ($err, $msg, []);
  }

  my @survey_trial_unit_id_list;

  for my $survey_trialunit_rec (@{$data_aref}) {

    push(@survey_trial_unit_id_list, $survey_trialunit_rec->{'SurveyTrialUnitId'});
  }

  if ($extra_attr_yes) {
    #extra attributes for survey trial unit
  }

  for my $row (@{$data_aref}) {

    my $survey_trial_unit_id = $row->{'SurveyTrialUnitId'};

    if ($extra_attr_yes) {

      $row->{'update'} = "update/surveytrialunit/$survey_trial_unit_id";
    }

    push(@{$extra_attr_survey_data}, $row);

  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_survey_data);
}

sub get_survey_trial_unit_runmode {

=pod get_survey_trial_unit_HELP_START
{
"OperationName": "Get survey trial unit",
"Description": "Get detailed information about survey trial unit specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='SurveyTrialUnit'/><SurveyTrialUnit CollectorId='173' TrialUnitId='47' VisitTime='2023-01-01 00:00:00' update='update/surveytrialunit/8' SurveyTrialUnitId='8' VisitOrder='1' SurveyId='38'/></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'SurveyTrialUnit'}],'SurveyTrialUnit' : [{'SurveyId' : '38','SurveyTrialUnitId' : '8','VisitOrder' : '1','VisitTime' : '2023-01-01 00:00:00','update' : 'update/surveytrialunit/8','CollectorId' : '173','TrialUnitId' : '47'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='SurveyTrialUnitId (3) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'SurveyTrialUnitId (3) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SurveyTrialUnitId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = shift;
  my $survey_trial_unit_id = $self->param('id');

  my $data_for_postrun_href = {};
  my $sql;

  my $dbh = connect_kdb_read();
  my $read_survey_trial_unit_id = read_cell_value($dbh, 'surveytrialunit', 'SurveyId', 'SurveyTrialUnitId', $survey_trial_unit_id);

  if (length($read_survey_trial_unit_id) == 0) {

    my $err_msg = "SurveyTrialUnit ($survey_trial_unit_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $msg = '';

  $sql    = 'SELECT surveytrialunit.* ';
  $sql   .= 'FROM surveytrialunit ';
  $sql   .= "WHERE surveytrialunit.SurveyTrialUnitId=? ";

  my ($survey_trial_unit_err, $survey_trial_unit_msg, $survey_trial_unit_data) = $self->list_survey_trial_unit(1, [], $sql, [$survey_trial_unit_id]);

  if ($survey_trial_unit_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}  = {'SurveyTrialUnit'  => $survey_trial_unit_data,
                                       'RecordMeta' => [{'TagName' => 'SurveyTrialUnit'}],
  };

  return $data_for_postrun_href;

}

sub get_addsurveytrialunit_dtd_file {

  my $dtd_path = $ENV{DOCUMENT_ROOT} . '/' . $DTD_PATH;

  return "${dtd_path}/addsurveytrialunit.dtd";
}

sub add_survey_trial_unit_bulk_runmode {

=pod add_survey_trial_unit_bulk_HELP_START
{
"OperationName": "Add trial units to the survey",
"Description": "Add trial units in bulk to the survey specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='1 TrialUnits for Survey (1) have been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : '1 TrialUnits for Survey (3) have been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Survey (1) does not exist.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Survey (1) does not exist.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "XML",
"UploadFileParameterName": "uploadfile",
"DTDFileNameForUploadXML": "addsurveytrialunit.dtd",
"URLParameter": [{"ParameterName": "id", "Description": "Existing SurveyId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};
  my $sql;
  my $bulk_sql;
  my @tu_sql_rec_list;

  my $survey_id  = $self->param('id');

  my $survey_trialunit_info_xml_file = $self->authen->get_upload_file();
  my $add_survey_trialunit_dtd_file  = $self->get_addsurveytrialunit_dtd_file();

  $self->logger->debug("DOCUMENT_ROOT: " . $ENV{DOCUMENT_ROOT});
  $self->logger->debug("DTD FILE: $add_survey_trialunit_dtd_file");

  add_dtd($add_survey_trialunit_dtd_file, $survey_trialunit_info_xml_file);

  my $xml_checker_parser = new XML::Checker::Parser( Handlers => { } );

  eval {

    local $XML::Checker::FAIL = sub {

      my $code = shift;
      my $err_str = XML::Checker::error_string ($code, @_);
      $self->logger->debug("XML Parsing ERR: $code : $err_str");
      die $err_str;
    };
    $xml_checker_parser->parsefile($survey_trialunit_info_xml_file);
  };

  if ($@) {

    my $err_msg = $@;
    $self->logger->debug("Parsing XML error: $err_msg");
    my $user_err_msg = "Uploaded xml (surveytrialunit) file does not comply with its definition.\n";
    $user_err_msg   .= "Details: $err_msg";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $user_err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_k_write   = connect_kdb_write(1);

  eval {
    my $survey_existence = record_existence($dbh_k_write, 'survey', 'SurveyId', $survey_id);

    if (!$survey_existence) {

      my $err_msg = "Survey ($survey_id) does not exist.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return 1;
    }

    my ($get_scol_err, $get_scol_msg, $scol_data, $pkey_data) = get_static_field($dbh_k_write, 'surveytrialunit');

    if ($get_scol_err) {

      $self->logger->debug("Get static field info failed: $get_scol_msg");

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

      return 1;
    }

    my $survey_trialunit_info_xml  = read_file($survey_trialunit_info_xml_file);
    my $survey_trialunit_info_aref = xml2arrayref($survey_trialunit_info_xml, 'surveytrialunit');


    for my $surveytrialunit (@{$survey_trialunit_info_aref}) {

      my $colsize_info          = {};
      my $chk_maxlen_field_href = {};

      for my $static_field (@{$scol_data}) {

        my $field_name  = $static_field->{'Name'};
        my $field_dtype = $static_field->{'DataType'};

        if (lc($field_dtype) eq 'varchar') {

          $colsize_info->{$field_name}           = $static_field->{'ColSize'};
          $chk_maxlen_field_href->{$field_name}  = $surveytrialunit->{$field_name};
        }
      }

      my ($maxlen_err, $maxlen_msg) = check_maxlen($chk_maxlen_field_href, $colsize_info);

      if ($maxlen_err) {

        $maxlen_msg .= 'longer than its maximum length';

        $data_for_postrun_href->{'Error'}  = 1;
        $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => $maxlen_msg}]};

        return 1;
      }

      my $visit_time  = $surveytrialunit->{'VisitTime'};

      my $trial_unit_id  = undef;

      if (length($surveytrialunit->{'TrialUnitId'}) > 0) {

        $trial_unit_id = $surveytrialunit->{'TrialUnitId'};
      }

      if (defined $trial_unit_id) {

        my $trial_unit_id_existence = record_existence($dbh_k_write, 'trialunit', 'TrialUnitId', $trial_unit_id);

        if (!$trial_unit_id_existence) {

          my $err_msg = "TrialUnit ($trial_unit_id) does not exist.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return 1;
        }
      }

      my $visit_order  = 'NULL';

      if (length($surveytrialunit->{'VisitOrder'}) > 0) {

        $visit_order = $surveytrialunit->{'VisitOrder'};
      }

      my $collector_id  = 'NULL';

      if (length($surveytrialunit->{'CollectorId'}) > 0) {

        $collector_id = $surveytrialunit->{'CollectorId'};
      }

      $bulk_sql  = 'INSERT INTO surveytrialunit ';
      $bulk_sql .= '(SurveyId, TrialUnitId, VisitTime, VisitOrder, CollectorId) VALUES ';

      my $tu_sql_rec_str = qq|(${survey_id},${trial_unit_id},'${visit_time}',${visit_order},${collector_id})|;

      $self->logger->debug("Survey Trial Unit Rec SQL: $tu_sql_rec_str");

      push(@tu_sql_rec_list, $tu_sql_rec_str);

    }

    $bulk_sql .= join(',', @tu_sql_rec_list);

    $sql = 'SELECT TrialUnitId FROM trialunit ORDER BY TrialUnitId DESC LIMIT 1';

    my $r_tu_err;
    my $tu_id_before;
    my $tu_id_after;

    ($r_tu_err, $tu_id_before) = read_cell($dbh_k_write, $sql, []);

    if ($r_tu_err) {

      $self->logger->debug("Read TrialUnitId before bulk INSERT failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return 1;
    }

    my $before_clause = '1=1';

    if (length($tu_id_before) > 0) {

      $before_clause = " TrialUnitId >= $tu_id_before ";
    }

    $self->logger->debug("BULK SQL: $bulk_sql");

    my $sth = $dbh_k_write->prepare($bulk_sql);
    $sth->execute();

    if ($dbh_k_write->err()) {

      $self->logger->debug("Add surveytrialunit in bulk failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return 1;
    }

    $sth->finish();

    $sql = 'SELECT TrialUnitId FROM trialunit ORDER BY TrialUnitId DESC LIMIT 1';

    ($r_tu_err, $tu_id_after) = read_cell($dbh_k_write, $sql, []);

    if ($r_tu_err) {

      $self->logger->debug("Read TrialUnitId after bulk INSERT failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return 1;
    }

    my $after_clause = '1=1';

    if (length($tu_id_after) > 0) {

      $after_clause = " TrialUnitId <= $tu_id_after ";
    }

    $dbh_k_write->commit;

    my $nb_added_survey_trial_unit = scalar(@{$survey_trialunit_info_aref});
    my $info_msg = "$nb_added_survey_trial_unit TrialUnits for Survey ($survey_id) have been added successfully.";

    my $info_msg_aref  = [{'Message' => $info_msg}];

    $data_for_postrun_href->{'Error'}     = 0;
    $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref };
    $data_for_postrun_href->{'ExtraData'} = 0;

    1;
  } or do {
    $self->logger->debug($@);
    eval {$dbh_k_write->rollback;};
    $data_for_postrun_href = $self->_set_error();
  };

  $dbh_k_write->disconnect;

  return $data_for_postrun_href;

}

sub list_survey_trial_unit_runmode {

=pod list_survey_trial_unit_HELP_START
{
"OperationName": "List survey trial units",
"Description": "List survey trial units.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='SurveyTrialUnit' /><SurveyTrialUnit VisitTime='2023-03-15 00:00:00' VisitOrder='1' update='update/surveytrialunit/16' SurveyId='60' SurveyTrialUnitId='16' CollectorId='1' TrialUnitId='61'/></SurveyTrialUnit></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'SurveyTrialUnit'}],'SurveyTrialUnit' : [{'VisitTime' : '2023-03-15 00:00:00','VisitOrder' : '1','update' : 'update/surveytrialunit/16','SurveyId' : '60','SurveyTrialUnitId' : '16','CollectorId' : '1','TrialUnitId' : '61'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SurveyId"}],
"HTTPParameter": [{"Required": 0, "Name": "Filtering", "Description": "Filtering parameter string consisting of filtering expressions which are separated by ampersand (&) which needs to be encoded if HTTP GET method is used. Each filtering expression is composed of a database field name, a filtering operator and the filtering value."}, {"Required": 0, "Name": "FieldList", "Description": "Comma separated value of wanted fields."}, {"Required": 0, "Name": "Sorting", "Description": "Comma separated value of SQL sorting phrases."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $field_list_csv = '';

  if (defined $query->param('FieldList')) {

    $field_list_csv = $query->param('FieldList');
  }

  my $filtering_csv = '';

  if (defined $query->param('Filtering')) {

    $filtering_csv = $query->param('Filtering');
  }

  my $survey_id = -1;
  my $survey_id_provided = 0;

  if (defined $self->param('id')) {

    $survey_id = $self->param('id');
    $survey_id_provided = 1;

    if ($filtering_csv =~ /SurveyId\s*=\s*(.*),?/) {

      if ( "$survey_id" ne "$1" ) {

        my $err_msg = 'Duplicate filtering condition for SurveyId.';
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
    else {

      if (length($filtering_csv) > 0) {

        if ($filtering_csv =~ /&$/) {

          $filtering_csv .= "SurveyId=$survey_id";
        }
        else {

          $filtering_csv .= "&SurveyId=$survey_id";
        }
      }
      else {

        $filtering_csv .= "SurveyId=$survey_id";
      }
    }
  }

  $self->logger->debug("Filtering csv: $filtering_csv");

  my $sorting = '';

  if (defined $query->param('Sorting')) {

    $sorting = $query->param('Sorting');
  }

  my $field_list = [];

  my $sql = 'SELECT * FROM surveytrialunit LIMIT 1';

  my ($survey_tu_err, $survey_tu_msg, $survey_tu_data) = $self->list_survey_trial_unit(0, $field_list, $sql);

  if ($survey_tu_err) {

    $self->logger->debug($survey_tu_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $dbh = connect_kdb_read();

  if ($survey_id_provided == 1) {

    if (!record_existence($dbh, 'survey', 'SurveyId', $survey_id)) {

      my $err_msg = "Survey ($survey_id): not found";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $survey_tu_data_aref = $survey_tu_data;

  my @field_list_all;

  if (scalar(@{$survey_tu_data_aref}) == 1) {

    @field_list_all = keys(%{$survey_tu_data_aref->[0]});
  }
  else {

    my ($survey_field_err, $survey_field_msg, $survey_field_data, $pkey_data) = get_static_field($dbh, 'surveytrialunit');

    if ($survey_field_err) {

      $self->logger->debug("Get static field failed: $survey_field_msg");
      return $self->_set_error();
    }

    for my $survey_field_rec (@{$survey_field_data}) {

      push(@field_list_all, $survey_field_rec->{'Name'});
    }

    for my $pkey_field (@{$pkey_data}) {

      push(@field_list_all, $pkey_field);
    }
  }

  $self->logger->debug("Field list all: " . join(',', @field_list_all));

  my $final_field_list     = \@field_list_all;
  my $sql_field_list       = [];
  my $filtering_field_list = [];

  if (length($field_list_csv) > 0) {

    my ($sel_field_err, $sel_field_msg, $sel_field_list) = parse_selected_field($field_list_csv,
                                                                                $final_field_list,
                                                                                'SurveyTrialUnitId');

    if ($sel_field_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;

    if ($filtering_csv =~ /SurveyId/) {

      push(@{$final_field_list}, 'SurveyId');
    }

    $sql_field_list       = [];
    $filtering_field_list = [];
    for my $fd_name (@{$final_field_list}) {

      # need to remove location field because generate_factor_sql does not understand these field
      if ( (!($fd_name =~ /Longitude/)) && (!($fd_name =~ /Latitude/)) && (!($fd_name =~ /surveylocation/)) && (!($fd_name =~ /surveylocdt/)) && (!($fd_name =~ /surveylocdescription/))) {

        push(@{$sql_field_list}, "surveytrialunit.$fd_name");
        push(@{$filtering_field_list}, $fd_name);
      }
    }
  }
  else {

    for my $fd_name (@{$final_field_list}) {

      # need to remove location field because generate_factor_sql does not understand these field
      if ( (!($fd_name =~ /Longitude/)) && (!($fd_name =~ /Latitude/)) && (!($fd_name =~ /surveylocation/)) && (!($fd_name =~ /surveylocdt/)) && (!($fd_name =~ /surveylocdescription/))) {

        push(@{$sql_field_list}, "surveytrialunit.$fd_name");
        push(@{$filtering_field_list}, $fd_name);
      }
    }
  }

  my $field_lookup = {};
  for my $fd_name (@{$final_field_list}) {

    $field_lookup->{$fd_name} = 1;
  }

  my $other_join = '';

  $sql  = "SELECT surveytrialunit.* ";
  $sql .= 'FROM surveytrialunit';

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering('SurveyTrialUnitId',
                                                                              'surveytrialunit',
                                                                              $filtering_csv,
                                                                              $filtering_field_list,
                                                              );

  $self->logger->debug("Filter phrase: $filter_phrase");

  if ($filter_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $filter_msg}]};

    return $data_for_postrun_href;
  }

  my $filter_where_phrase = '';
  if (length($filter_phrase) > 0) {

    $filter_where_phrase = $filter_phrase ;
  }

  my $filtering_exp = " WHERE $filter_where_phrase ";

  $dbh->disconnect();

  $sql .= "$filtering_exp";

  my ($sort_err, $sort_msg, $sort_sql) = parse_sorting($sorting, $final_field_list);

  if ($sort_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sort_msg}]};

    return $data_for_postrun_href;
  }

  if (length($sort_sql) > 0) {

    $sql .= "ORDER BY $sort_sql ";
  }
  else {

    $sql .= 'ORDER BY surveytrialunit.SurveyTrialUnitId DESC';
  }

  $self->logger->debug("Where arg: " . join(',', @{$where_arg}));

  $self->logger->debug("SQL with VCol: $sql");

  my ($read_tu_err, $read_tu_msg, $tu_data) = $self->list_survey_trial_unit(1, $final_field_list, $sql, $where_arg);

  if ($read_tu_err) {

    $self->logger->debug($read_tu_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'} = 0;
  $data_for_postrun_href->{'Data'}  = {'SurveyTrialUnit' => $tu_data,
                                       'RecordMeta' => [{'TagName' => 'SurveyTrialUnit'}]};

  return $data_for_postrun_href;

}

sub update_survey_trial_unit_runmode {

=pod update_survey_trial_unit_HELP_START
{
"OperationName": "Update survey trial unit",
"Description": "Update survey trial unit specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "surveytrialunit",
"SkippedField": ["SurveyId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Survey TrialUnit (1) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Survey TrialUnit (1) has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Survey TrialUnit (100) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Survey TrialUnit (100) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SurveyTrialUnitId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = shift;
  my $survey_trial_unit_id = $self->param('id');
  my $query = $self->query();

  my $data_for_postrun_href = {};
  my $sql;

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'SurveyId' => 1};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'surveytrialunit', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  my $survey_trial_unit_exist = record_existence($dbh_read, 'surveytrialunit', 'SurveyTrialUnitId', $survey_trial_unit_id);

  if (!$survey_trial_unit_exist) {

    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => "Survey TrialUnit ($survey_trial_unit_id) not found."}]};

    return $data_for_postrun_href;
  }

  $dbh_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $read_tr_u_sql    =   'SELECT VisitOrder, CollectorId ';
  $read_tr_u_sql      .=   'FROM surveytrialunit WHERE SurveyTrialUnitId=? ';

  my ($r_df_val_err, $r_df_val_msg, $survey_tu_df_val_data) = read_data($dbh_k_write, $read_tr_u_sql, [$survey_trial_unit_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve surveytrialunit default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $visit_order  =  undef;
  my $collector_id =  undef;

  my $nb_df_val_rec  =  scalar(@{$survey_tu_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve surveytrialunit default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  my $trial_unit_id = $query->param('TrialUnitId'); #required
  my $visit_time    = $query->param('VisitTime'); #required

  $visit_order     =  $survey_tu_df_val_data->[0]->{'VisitOrder'}; #optional
  $collector_id    =  $survey_tu_df_val_data->[0]->{'CollectorId'}; #optional

  if (defined $query->param('VisitOrder')) {

    if (length($query->param('VisitOrder')) > 0) {

      $visit_order = $query->param('VisitOrder');
    }
  }

  if (defined $query->param('CollectorId')) {

    if (length($query->param('CollectorId')) > 0) {

      $collector_id = $query->param('CollectorId');
    }
  }

  my $trial_unit_existence = record_existence($dbh_k_write, 'trialunit', 'TrialUnitId', $trial_unit_id);

  if (!$trial_unit_existence) {

    my $err_msg = "Trial Unit ($trial_unit_id) does not exist.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TrialUnitId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("Parameter list: " . join(',', ($trial_unit_id, $visit_time, $visit_order, $collector_id)));

  $sql    = 'UPDATE surveytrialunit SET ';
  $sql   .= 'TrialUnitId=?, ';
  $sql   .= 'VisitTime=?, ';
  $sql   .= 'VisitOrder=?, ';
  $sql   .= 'CollectorId=?';
  $sql   .= ' WHERE SurveyTrialUnitId=?';

  $self->logger->debug("SQL: $sql");

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($trial_unit_id, $visit_time, $visit_order, $collector_id, $survey_trial_unit_id);

  if ($dbh_k_write->err()) {

    $self->logger->debug("Update Survey TrialUnit failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref = [{'Message' => "Survey TrialUnit ($survey_trial_unit_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'} = 0;
  $data_for_postrun_href->{'Data'}  = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;

}

sub delete_survey_trial_unit_runmode {

=pod delete_survey_trial_unit_HELP_START
{
"OperationName": "Delete survey trial unit",
"Description": "Delete trial unit from the survey specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Survey TrialUnit (76) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Survey TrialUnit (75) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdUsed": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Survey TrialUnit (77) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdUsed": "{'Error' : [{'Message' : 'Survey TrialUnit (77) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SurveyTrialUnitId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = shift;
  my $survey_trial_unit_id = $self->param('id');

  my $data_for_postrun_href = {};
  my $sql;

  my $dbh_k_read = connect_kdb_read();

  my $read_survey_trial_unit_id = read_cell_value($dbh_k_read, 'surveytrialunit', 'SurveyId', 'SurveyTrialUnitId', $survey_trial_unit_id);

  if (length($read_survey_trial_unit_id) == 0) {

    my $err_msg = "Survey TrialUnit ($survey_trial_unit_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  $sql = "DELETE FROM surveytrialunit WHERE SurveyTrialUnitId=?";
  my $sth = $dbh_k_write->prepare($sql);

  $sth->execute($survey_trial_unit_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref = [{'Message' => "Survey TrialUnit ($survey_trial_unit_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;

}

sub update_survey_geography_runmode {

=pod update_survey_geography_HELP_START
{
"OperationName": "Update survey location",
"Description": "Update survey's geographical location.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Survey (1) location has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Survey (1) location has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Survey (20) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Survey (20) not found.'}]}"}],
"HTTPParameter": [{"Name": "surveylocation", "DataType": "polygon_wkt", "Description": "GIS field defining the polygon geometry object of the survey in a standard GIS well-known text.", "Type": "LCol", "Required": "1"},{"Name": "surveylocdt", "DataType": "timestamp", "Description": "DateTime of survey location", "Type": "LCol", "Required": "0"},{"Name": "currentloc", "DataType": "tinyint", "Description": "Flag to notify current location", "Type": "LCol", "Required": "10"},{"Name": "description", "DataType": "varchar", "Description": "Description for location", "Type": "LCol", "Required": "10"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SurveyId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self        = shift;
  my $survey_id  = $self->param('id');
  my $query       = $self->query();

  my $data_for_postrun_href = {};

  my $dbh_k_read = connect_kdb_read();
  my $survey_exist = record_existence($dbh_k_read, 'survey', 'SurveyId', $survey_id);
  $dbh_k_read->disconnect();

  if (!$survey_exist) {

    my $err_msg = "Survey ($survey_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sub_PGIS_val_builder = sub {
    my $wkt = shift;
    if ($wkt =~ /^POINT/i) {
      return "ST_ForceCollection(ST_Multi(ST_GeomFromText(?, -1)))";
    } else {
      return "ST_ForceCollection(ST_GeomFromText(?, -1))";
    }
  };

  my ($err, $err_msg) = append_geography_loc(
                                              "survey",
                                              $survey_id,
                                              ['POINT','MULTIPOINT'],
                                              $query,
                                              $sub_PGIS_val_builder,
                                              $self->logger,
                                            );

  if ($err) {
    $self->logger->debug($err_msg);
    $data_for_postrun_href = $self->_set_error($err_msg);
  } else {
    my $info_msg_aref = [{'Message' => "Survey ($survey_id) location has been updated successfully."}];
    $data_for_postrun_href->{'Error'}     = 0;
    $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
    $data_for_postrun_href->{'ExtraData'} = 0;
  }

  return $data_for_postrun_href;
}

sub add_survey_trait_runmode {

=pod add_survey_trait_HELP_START
{
"OperationName": "Add trait value for survey",
"Description": "Add known value of the trait for a survey. Usually known feature/value of the particular survey (not generated as a direct measurement).",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "surveytrait",
"SkippedField": ["SurveyId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='4' ParaName='SurveyTraitId' /><Info Message='SurveyTrait (4) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{ 'ReturnId' : [{'Value' : '5', 'ParaName' : 'SurveyTraitId'}], 'Info' : [{'Message' : 'SurveyTrait (5) has been added successfully.'} ]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Trait (100) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{ 'Error' : [ {  'Message' : 'Trait (100) not found.' } ]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing survey id which is known for the adding trait."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self    = shift;
  my $survey_id = $self->param('id');
  my $query   = $self->query();

  my $data_for_postrun_href = {};

  my $sql;

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'SurveyId' => 1};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'surveytrait', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $trait_id    = $query->param('TraitId');
  my $compulsory  = $query->param('Compulsory');

  $dbh_read = connect_kdb_read();

  my $gadmin_status = $self->authen->gadmin_status();

  my $dbh_k_write = connect_kdb_write();

  my $survey_existence = record_existence($dbh_k_write, 'survey', 'SurveyId', $survey_id);

  if (!$survey_existence) {

    my $err_msg = "Survey ($survey_id) does not exist.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( !($compulsory =~ /0|1/) ) {

    my $err_msg = "Compulsory ($compulsory) can be only either 1 or 0.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Compulsory' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trait_exist = record_existence($dbh_read, 'trait', 'TraitId', $trait_id);

  if (!$trait_exist) {

    my $err_msg = "Trait ($trait_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_read->disconnect();

  my $dbh_write = connect_kdb_write();

  $sql  = 'INSERT INTO surveytrait SET ';
  $sql .= 'SurveyId=?, ';
  $sql .= 'TraitId=?, ';
  $sql .= 'Compulsory=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($survey_id, $trait_id, $compulsory);

  my $survey_trait_id = -1;
  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $survey_trait_id = $dbh_write->last_insert_id(undef, undef, 'surveytrait', 'SurveyTraitId');
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref  = [{'Message' => "SurveyTrait ($survey_trait_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$survey_trait_id", 'ParaName' => 'SurveyTraitId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref,
                                           'ReturnId'  => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_survey_trait {

  my $self            = shift;
  my $extra_attr_yes  = shift;
  my $survey_perm       = shift;
  my $where_clause    = qq{};
  $where_clause       = shift;

  if (length($where_clause) > 0) {

    my $count = 0;
    while ($where_clause =~ /\?/g) {

      $count += 1;
    }

    if ( scalar(@_) != $count ) {

      my $msg = 'Number of arguments does not match with ';
      $msg   .= 'number of SQL parameter.';
      return (1, $msg, []);
    }
  }

  my $dbh = connect_kdb_read();

  my $sql = 'SELECT trait.TraitName, surveytrait.SurveyTraitId, surveytrait.SurveyId, surveytrait.TraitId, surveytrait.Compulsory, generalunit.UnitName ';
  $sql   .= 'FROM surveytrait ';
  $sql   .= ' INNER JOIN trait on trait.TraitId=surveytrait.TraitId ';
  $sql   .= ' INNER JOIN generalunit on trait.UnitId=generalunit.UnitId ';
  $sql   .= $where_clause . ' ';
  $sql   .= ' ORDER BY SurveyTraitId DESC ';

  $self->logger->debug("SQL: $sql");

  my $sth = $dbh->prepare($sql);
  # parameters provided by the caller
  # for example, ('WHERE FieldA=?', '1')
  $sth->execute(@_);

  my $err = 0;
  my $msg = '';
  my $survey_trait_data = [];

  if ( !$dbh->err() ) {

    my $array_ref = $sth->fetchall_arrayref({});

    if ( !$sth->err() ) {

      $survey_trait_data = $array_ref;
    }
    else {

      $err = 1;
      $msg = 'Unexpected error';
      $self->logger->debug('Err: ' . $dbh->errstr());
    }
  }
  else {

    $err = 1;
    $msg = 'Unexpected error';
    $self->logger->debug('Err: ' . $dbh->errstr());
  }

  $sth->finish();

  my $extra_attr_survey_trait_data;

  if ($extra_attr_yes) {

    for my $row (@{$survey_trait_data}) {

      if (($survey_perm & $READ_WRITE_PERM) == $READ_WRITE_PERM) {

        my $survey_trait_id  = $row->{'SurveyTraitId'};
        my $survey_id        = $row->{'SurveyId'};
        my $trait_id       = $row->{'TraitId'};
        $row->{'update'}   = "update/surveytrait/$survey_trait_id";
        $row->{'delete'}   = "survey/$survey_id/remove/trait/$trait_id";
      }
      push(@{$extra_attr_survey_trait_data}, $row);
    }
  }
  else {

    $extra_attr_survey_trait_data = $survey_trait_data;
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_survey_trait_data);
}

sub list_survey_trait_runmode {

=pod list_survey_trait_HELP_START
{
"OperationName": "List trait values for survey",
"Description": "Returns full list of trait values for a survey. Usually known feature/value of the particular survey (not generated as a direct measurement).",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='SurveyTrait' /><SurveyTrait SurveyTraitId='4' Compulsory='0' SurveyId='442' delete='survey/442/remove/trait/1' TraitId='1' 'TraitName': 'Yield' update='update/surveytrait/4' /></DATA>",
"SuccessMessageJSON": "{ 'RecordMeta' : [ {  'TagName' : 'SurveyTrait' } ], 'SurveyTrait' : [ {  'SurveyTraitId' : '4',  'TraitName' : 'Yield','Compulsory' : '0',  'delete' : 'survey/442/remove/trait/1',  'SurveyId' : '442',  'update' : 'update/surveytrait/4',  'TraitId' : '1' } ]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Survey (4426) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Survey (4426) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "SurveyId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self    = shift;
  my $survey_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  my $survey_exist = record_existence($dbh, 'survey', 'SurveyId', $survey_id);

  if (!$survey_exist) {

    my $err_msg = "Survey ($survey_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $perm_str = permission_phrase($group_id, 0, $gadmin_status);
  my $sql = "SELECT $perm_str FROM survey WHERE SurveyId=?";

  my ($read_perm_err, $survey_perm) = read_cell($dbh, $sql, [$survey_id]);

  $dbh->disconnect();

  my $where_clause = 'WHERE SurveyId=?';
  my ($survey_trait_err, $survey_trait_msg, $survey_trait_data) = $self->list_survey_trait(1,
                                                                                       $survey_perm,
                                                                                       $where_clause,
                                                                                       $survey_id);

  if ($survey_trait_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'SurveyTrait' => $survey_trait_data,
                                           'RecordMeta'    => [{'TagName' => 'SurveyTrait'}],
  };

  return $data_for_postrun_href;
}

sub get_survey_trait_runmode {

=pod get_survey_trait_HELP_START
{
"OperationName": "Get trait value for survey",
"Description": "Returns known value of the trait for a survey. Usually known feature/value of the particular survey (not generated as a direct measurement).",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='SurveyTrait' /><SurveyTrait SurveyTraitId='4' SurveyId='442' delete='survey/442/remove/trait/1' TraitValue='40' TraitId='1' update='update/surveytrait/4' /></DATA>",
"SuccessMessageJSON": "{ 'RecordMeta' : [ {  'TagName' : 'SurveyTrait' } ], 'SurveyTrait' : [ {  'SurveyTraitId' : '4',  'TraitValue' : '40',  'delete' : 'survey/442/remove/trait/1',  'SurveyId' : '442',  'update' : 'update/surveytrait/4',  'TraitId' : '1' } ]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='SurveyTrait (47) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{ 'Error' : [ {  'Message' : 'SurveyTrait (47) not found.' } ]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SurveyTraitId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self            = shift;
  my $survey_trait_id = $self->param('id');

  my $data_for_postrun_href = {};
  my $sql;

  my $dbh = connect_kdb_read();

  my $read_survey_trait_id = read_cell_value($dbh, 'surveytrait', 'SurveyId', 'SurveyTraitId', $survey_trait_id);

  $self->logger->debug($survey_trait_id);

  if (length($read_survey_trait_id) == 0) {

    my $err_msg = "SurveyTrait ($survey_trait_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $msg = '';

  $sql    = 'SELECT surveytrait.* ';
  $sql   .= 'FROM surveytrait ';
  $sql   .= "WHERE surveytrait.SurveyTraitId=? ";

  my ($survey_trait_err, $survey_trait_msg, $survey_trait_data) = $self->list_survey_trial_unit(1, [], $sql, [$survey_trait_id]);

  if ($survey_trait_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'SurveyTrait' => $survey_trait_data,
                                           'RecordMeta'    => [{'TagName' => 'SurveyTrait'}],
  };

  return $data_for_postrun_href;
}

sub delete_survey_trait_runmode {

=pod delete_survey_trait_HELP_START
{
"OperationName": "Delete survey trait",
"Description": "Delete trait from the survey specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Survey Trait (100) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Survey Trait (75) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdUsed": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Survey Trait (77) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdUsed": "{'Error' : [{'Message' : 'Survey Trait (77) not found.'}]}"}],
"URLParameter": [{"ParameterName": "_surveyid", "Description": "Existing Survey Id."}, {"ParameterName": "_traitid", "Description": "Existing Trait Id that is attached to Survey."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut


  my $self        = shift;
  my $survey_id   = $self->param('surveyid');
  my $trait_id    = $self->param('traitid');

  my $data_for_postrun_href = {};

  my $dbh_read = connect_kdb_read();

  my $survey_exist = record_existence($dbh_read, 'survey', 'SurveyId', $survey_id);

  if (!$survey_exist) {

    my $err_msg = "Survey ($survey_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'SurveyId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trait_exist = record_existence($dbh_read, 'trait', 'TraitId', $trait_id);

  if (!$trait_exist) {

    my $err_msg = "Trait ($trait_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql    = 'SELECT SurveyTraitId ';
  $sql   .= 'FROM surveytrait ';
  $sql   .= 'WHERE SurveyId=? AND TraitId=?';

  my ($read_err, $survey_trait_id) = read_cell($dbh_read, $sql, [$survey_id, $trait_id]);

  if (length($survey_trait_id) == 0) {

    my $err_msg = "Trait ($trait_id) not part of survey ($survey_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_read->disconnect();

  my $dbh_write = connect_kdb_write();

  $sql  = 'DELETE FROM surveytrait ';
  $sql .= 'WHERE SurveyTraitId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($survey_trait_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "Trait ($trait_id) has been successfully removed from survey ($survey_id)."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_survey_trait_runmode {

=pod update_survey_trait_HELP_START
{
"OperationName": "Update survey trait",
"Description": "Update survey and trait association for specified id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "surveytrait",
"SkippedField": ["SurveyId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='SurveyTrait (1) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'SurveyTrait (1) has been updated successfully.'}]}",
"ErrorMessageXML": [{"MissingParameter": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error TraitId='TraitId is missing.' /></DATA>"}],
"ErrorMessageJSON": [{"MissingParameter": "{'Error' : [{'TraitId' : 'TraitId is missing.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SurveyTraitId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self           = shift;
  my $survey_trait_id = $self->param('id');
  my $query          = $self->query();

  my $data_for_postrun_href = {};

  my $compulsory   = $query->param('Compulsory');

  my ($missing_err, $missing_href) = check_missing_href( { 'Compulsory' => $compulsory } );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  my $dbh_read = connect_kdb_read();

  my $read_survey_trait_sql   =   'SELECT SurveyId, TraitId ';
     $read_survey_trait_sql  .=   'FROM surveytrait WHERE SurveyTraitId=? ';

  my ($r_df_val_err, $r_df_val_msg, $surveytrait_df_val_data) = read_data($dbh_read, $read_survey_trait_sql, [$survey_trait_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve surveytrait default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $survey_id     = undef;
  my $trait_id      = undef;

  my $nb_df_val_rec    =  scalar(@{$surveytrait_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve surveytrait default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $survey_id   =  $surveytrait_df_val_data->[0]->{'SurveyId'};
  $trait_id   =  $surveytrait_df_val_data->[0]->{'TraitId'};

  if ( length($survey_id) == 0 ) {

    my $err_msg = "SurveyTraitId ($survey_trait_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($trait_id) == 0) {

    $trait_id = undef;
  }

  if (defined $query->param('TraitId')) {

    if (length($query->param('TraitId')) > 0) {

      $trait_id = $query->param('TraitId');
    }
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status);

  my $sql  = "SELECT $perm_str AS UltimatePermission ";
  $sql    .= 'FROM survey ';
  $sql    .= 'WHERE SurveyId=?';

  my $dbh_write = connect_kdb_write();

  $sql  = 'UPDATE surveytrait SET ';
  $sql .= 'TraitId=?, ';
  $sql .= 'Compulsory=? ';
  $sql .= 'WHERE SurveyTraitId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($trait_id, $compulsory, $survey_trait_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "SurveyTrait ($survey_trait_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

1;
