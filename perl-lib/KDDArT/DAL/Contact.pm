#$Id$
#$Author$

# Copyright (c) 2025, Diversity Arrays Technology, All rights reserved.

# Author    : Puthick Hok
# Created   : 02/06/2010
# Modified  :
# Purpose   :
#
#

package KDDArT::DAL::Contact;

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
use Time::HiRes qw( tv_interval gettimeofday );
use DateTime;
use DateTime::Format::Pg;


sub setup {

  my $self = shift;

  CGI::Session->name($COOKIE_NAME);

  __PACKAGE__->authen->init_config_parameters();
  __PACKAGE__->authen->check_login_runmodes(':all');
  __PACKAGE__->authen->check_content_type_runmodes(':all');
  __PACKAGE__->authen->check_rand_runmodes('update_organisation_gadmin',
                                           'add_contact_gadmin',
                                           'add_organisation_gadmin',
                                           'del_organisation_gadmin',
                                           'update_contact_gadmin',
                                           'del_contact_gadmin',
                                           'update_contact_geography',
      );
  __PACKAGE__->authen->count_session_request_runmodes(':all');

  __PACKAGE__->authen->check_signature_runmodes('update_organisation_gadmin',
                                                'add_contact_gadmin',
                                                'add_organisation_gadmin',
                                                'del_organisation_gadmin',
                                                'update_contact_gadmin',
                                                'del_contact_gadmin',
                                                'update_contact_geography',
      );
  __PACKAGE__->authen->check_gadmin_runmodes('update_organisation_gadmin',
                                             'add_contact_gadmin',
                                             'add_organisation_gadmin',
                                             'del_organisation_gadmin',
                                             'update_contact_gadmin',
                                             'del_contact_gadmin',
                                             'update_contact_geography',
      );

  $self->run_modes(
    'list_organisation_advanced'  => 'list_organisation_advanced_runmode',
    'get_organisation'            => 'get_organisation_runmode',
    'update_organisation_gadmin'  => 'update_organisation_runmode',
    'add_contact_gadmin'          => 'add_contact_runmode',
    'add_organisation_gadmin'     => 'add_organisation_runmode',
    'del_organisation_gadmin'     => 'del_organisation_runmode',
    'update_contact_gadmin'       => 'update_contact_runmode',
    'del_contact_gadmin'          => 'del_contact_runmode',
    'get_contact'                 => 'get_contact_runmode',
    'list_contact_advanced'       => 'list_contact_advanced_runmode',
    'update_contact_geography'    => 'update_contact_geography_runmode',
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

sub list_organisation_advanced_runmode {

=pod list_organisation_advanced_HELP_START
{
"OperationName": "List organisation(s)",
"Description": "Return a list of organisations currently present in the system.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination Page='1' NumOfRecords='23' NumOfPages='23' NumPerPage='1' /><Organisation OrganisationId='24' OrganisationName='DArT Testing 0797388' update='update/organisation/24' /><RecordMeta TagName='Organisation' /></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfRecords' : '23','NumOfPages' : 23,'NumPerPage' : '1','Page' : '1'}],'VCol' : [],'Organisation' : [{'update' : 'update/organisation/24','OrganisationName' : 'DArT Testing 0797388','OrganisationId' : '24'}],'RecordMeta' : [{'TagName' : 'Organisation'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"URLParameter": [{"ParameterName": "nperpage", "Description": "Number of records in a page for pagination"}, {"ParameterName": "num", "Description": "The page number of the pagination"}],
"HTTPParameter": [{"Required": 0, "Name": "Filtering", "Description": "Filtering parameter string consisting of filtering expressions which are separated by ampersand (&) which needs to be encoded if HTTP GET method is used. Each filtering expression is composed of a database field name, a filtering operator and the filtering value."}, {"Required": 0, "Name": "FieldList", "Description": "Comma separated value of wanted fields."}, {"Required": 0, "Name": "Sorting", "Description": "Comma separated value of SQL sorting phrases."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $runmode_start_time = [gettimeofday()];
  my $data_for_postrun_href = {};

  my $pagination  = 0;
  my $nb_per_page = -1;
  my $page        = -1;

  $self->logger->debug("Base dir: $main::kddart_base_dir");

  if ( (defined $self->param('nperpage')) && (defined $self->param('num')) ) {

    $pagination  = 1;
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

  $self->logger->debug("Filtering csv: $filtering_csv");

  my $sorting = '';

  if (defined $query->param('Sorting')) {

    $sorting = $query->param('Sorting');
  }

  my $dbh = connect_kdb_read();
  my $field_list = ['organisation.*', 'VCol*'];

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list, $vcolf_part) = generate_factor_sql($dbh, $field_list, 'organisation',
                                                                                     'OrganisationId', '');

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql   .= " LIMIT 1";

  $self->logger->debug("SQL with VCol: $sql");

  my $samplerecord_start_time = [gettimeofday()];

  my ($sam_org_err, $sam_org_msg, $sam_org_data) = $self->list_organisation(0, $sql);

  my $samplerecord_elapsed = tv_interval($samplerecord_start_time);

  if ($sam_org_err) {

    $self->logger->debug($sam_org_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $sample_data_aref = $sam_org_data;

  my @field_list_all;

  if (scalar(@{$sample_data_aref}) == 1) {

    @field_list_all = keys(%{$sample_data_aref->[0]});
  }
  else {

    $self->logger->debug("It reaches here");
    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'organisation');

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

  if (length($field_list_csv) > 0) {

    my ($sel_field_err, $sel_field_msg, $sel_field_list) = parse_selected_field($field_list_csv,
                                                                                $final_field_list,
                                                                                'OrganisationId');

    if ($sel_field_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;
  }

  my $field_lookup = {};
  for my $fd_name (@{$final_field_list}) {

    $field_lookup->{$fd_name} = 1;
  }

  my $other_join = '';

  if ($filtering_csv !~ /Factor/) {

    ($vcol_err, $trouble_vcol, $sql, $vcol_list, $vcolf_part) = generate_factor_sql($dbh, $final_field_list,
                                                                                    'organisation',
                                                                                    'OrganisationId',
                                                                                    $other_join);
  }
  else {

    ($vcol_err, $trouble_vcol, $sql, $vcol_list, $vcolf_part) = generate_factor_sql_v2($dbh, $final_field_list,
                                                                                       'organisation',
                                                                                       'OrganisationId',
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
      $nb_filter_factor) = parse_filtering_v2('OrganisationId',
                                              'organisation',
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
                                                                  'organisation',
                                                                  'OrganisationId',
                                                                  $filtering_exp,
                                                                  $where_arg);
    }
    else {

      $self->logger->debug("COUNT NB RECORD: FACTOR IN FILTERING");

      my $count_sql = "SELECT COUNT(organisation.OrganisationId) ";
      $count_sql   .= "FROM organisation INNER JOIN ";
      $count_sql   .= " (SELECT OrganisationId, COUNT(OrganisationId) ";
      $count_sql   .= " FROM organisationfactor WHERE $count_filter_phrase ";
      $count_sql   .= " GROUP BY OrganisationId HAVING COUNT(OrganisationId)=$nb_filter_factor) AS subq ";
      $count_sql   .= "ON organisation.OrganisationId = subq.OrganisationId ";
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

    $sql .= ' ORDER BY organisation.OrganisationId DESC';
  }

  $sql .= " $paged_limit_clause ";

  $self->logger->debug("SQL with VCol: $sql");
  $self->logger->debug("Where arg: " . join(',', @{$where_arg}));

  my $data_start_time = [gettimeofday()];

  # where_arg here in the list function because of the filtering
  my ($read_org_err, $read_org_msg, $org_data) = $self->list_organisation(1, $sql, $where_arg);

  my $data_elapsed = tv_interval($data_start_time);

  if ($read_org_err) {

    $self->logger->debug($read_org_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Organisation' => $org_data,
                                           'VCol'         => $vcol_list,
                                           'Pagination'   => $pagination_aref,
                                           'RecordMeta'   => [{'TagName' => 'Organisation'}],
  };

  my $runmode_elapsed = tv_interval($runmode_start_time);

  $self->logger->debug("Sample record time: $samplerecord_elapsed");
  $self->logger->debug("Pagination limit time: $paged_limit_elapsed");
  $self->logger->debug("Data time: $data_elapsed");
  $self->logger->debug("Runmode time: $runmode_elapsed");

  return $data_for_postrun_href;
}

sub list_organisation {

  my $self            = $_[0];
  my $extra_attr_yes  = $_[1];
  my $sql             = $_[2];
  my $where_para_aref = $_[3];

  my $err = 0;
  my $msg = '';

  my $data_aref = [];

  my $dbh = connect_kdb_read();

  ($err, $msg, $data_aref) = read_data($dbh, $sql, $where_para_aref);

  if ($err) {

    return ($err, $msg, []);
  }

  #$self->logger->debug("Number of records: " . scalar(@{$data_aref}));

  my $extra_attr_org_data = [];

  my $gadmin_status = $self->authen->gadmin_status();

  if ($extra_attr_yes && ($gadmin_status eq '1')) {

    my $org_id_aref = [];

    for my $row (@{$data_aref}) {

      push(@{$org_id_aref}, $row->{'OrganisationId'});
    }

    if (scalar(@{$org_id_aref}) > 0) {

      my $chk_table_aref = [{'TableName' => 'contact', 'FieldName' => 'OrganisationId'}];

      my ($chk_id_err, $chk_id_msg,
          $used_id_href, $not_used_id_href) = id_existence_bulk($dbh, $chk_table_aref, $org_id_aref);

      if ($chk_id_err) {

        $self->logger->debug("Check id existence error: $chk_id_msg");
        $err = 1;
        $msg = $chk_id_msg;
      }
      else {

        for my $row (@{$data_aref}) {

          my $org_id = $row->{'OrganisationId'};
          $row->{'update'}   = "update/organisation/$org_id";

          # delete link only if this organisation isn't used in contact
          if ( $not_used_id_href->{$org_id} ) {

            $row->{'delete'}   = "delete/organisation/$org_id";
          }

          push(@{$extra_attr_org_data}, $row);
        }
      }
    }
  }
  else {

    $extra_attr_org_data = $data_aref;
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_org_data);
}

sub get_organisation_runmode {

=pod get_organisation_HELP_START
{
"OperationName": "Get organisation",
"Description": "Return detailed information about organisation specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Organisation OrganisationId='1' OrganisationName='Diversity Arrays Technology Pty Ltd' update='update/organisation/1' /><RecordMeta TagName='Organisation' /></DATA>",
"SuccessMessageJSON": "{'VCol' : [],'Organisation' : [{'update' : 'update/organisation/1','OrganisationName' : 'Diversity Arrays Technology Pty Ltd','OrganisationId' : '1'}],'RecordMeta' : [{'TagName' : 'Organisation'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Organisation (27) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Organisation (27) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing OrganisationId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self      = shift;
  my $org_id    = $self->param('id');

  my $dbh = connect_kdb_read();
  my $org_exist = record_existence($dbh, 'organisation', 'OrganisationId', $org_id);

  my $data_for_postrun_href = {};

  if (!$org_exist) {

    $data_for_postrun_href->{'Error'}       = 1;
    $data_for_postrun_href->{'Data'}        = {'Error' => [{'Message' => "Organisation ($org_id) not found."}]};

    return $data_for_postrun_href;
  }

  my $field_list = ['organisation.*', 'VCol*'];

  my $other_join = '';

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $field_list, 'organisation',
                                                                        'OrganisationId', $other_join);
  $dbh->disconnect();

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql  =~ s/GROUP BY/ WHERE organisation.OrganisationId=? GROUP BY /;

  $self->logger->debug("SQL with VCol: $sql");

  my ($read_org_err, $read_org_msg, $org_data) = $self->list_organisation(1, $sql, [$org_id]);

  if ($read_org_err) {

    $self->logger->debug($read_org_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Data'}    = {'Organisation' => $org_data,
                                         'VCol'         => $vcol_list,
                                         'RecordMeta'   => [{'TagName' => 'Organisation'}]};

  return $data_for_postrun_href;
}

sub update_organisation_runmode {

=pod update_organisation_gadmin_HELP_START
{
"OperationName": "Update organisation",
"Description": "Update organisation in the database using specified id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "organisation",
"KDDArTFactorTable": "organisationfactor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Organisation (2) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Organisation (2) has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Organisation (27) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Organisation (27) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing OrganisationId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self      = shift;
  my $org_id    = $self->param('id');

  my $query     = $self->query();

  my $data_for_postrun_href = {};
  my $org_err = 0;
  my $org_error_aref = [];

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'organisation', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $org_name  = $query->param('OrganisationName');

  my $dbh = connect_kdb_write();

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength, FactorValidRuleErrMsg, FactorValidRule  ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='organisationfactor'";

  my $vcol_data = $dbh->selectall_hashref($sql, 'FactorId');

  my $vcol_param_data = {};
  my $vcol_len_info   = {};
  my $vcol_param_data_maxlen = {};

  ##pre_validate_vcol -> { Rule -> [rule], RuleErrorMsg -> [msg], Value -> [value], FactorId -> [value] } 
  my $pre_validate_vcol = {};

  for my $vcol_id (keys(%{$vcol_data})) {

    my $vcol_param_name = "VCol_${vcol_id}";
    my $vcol_value      = $query->param($vcol_param_name);
    if ($vcol_data->{$vcol_id}->{'CanFactorHaveNull'} != 1) {

      $vcol_param_data->{$vcol_param_name} = $vcol_value;
    }

    $pre_validate_vcol->{$vcol_param_name} = {
      'Rule' => $vcol_data->{$vcol_id}->{'FactorValidRule'},
      'Value'=> $vcol_value,
      'FactorId'=> $vcol_id,
      'RuleErrorMsg'=> $vcol_data->{$vcol_id}->{'FactorValidRuleErrMsg'},
      'CanFactorHaveNull' => $vcol_data->{$vcol_id}->{'CanFactorHaveNull'},
    };

    $vcol_len_info->{$vcol_param_name} = $vcol_data->{$vcol_id}->{'FactorValueMaxLength'};
    $vcol_param_data_maxlen->{$vcol_param_name} = $vcol_value;
  }

  my ($vcol_missing_err, $vcol_missing_href) = check_missing_href( $vcol_param_data );

  if ($vcol_missing_err) {

    $data_for_postrun_href->{'Error'}       = 1;

    push(@{$org_error_aref}, $vcol_missing_href);
    $org_err = 1;
  }

  if ($org_err == 1) {
    $data_for_postrun_href->{'Data'}        = {'Error' => $org_error_aref};

    return $data_for_postrun_href;
  }

  my ($vcol_maxlen_err, $vcol_maxlen_href) = check_maxlen_href($vcol_param_data_maxlen, $vcol_len_info);

  if ($vcol_maxlen_err) {

    $data_for_postrun_href->{'Error'}       = 1;
    $data_for_postrun_href->{'Data'}        = {'Error' => [$vcol_maxlen_href]};

    return $data_for_postrun_href;
  }

  my $organisation_exist = record_existence($dbh, 'organisation', 'OrganisationId', $org_id);

  if (!$organisation_exist) {

    $data_for_postrun_href->{'Error'}       = 1;
    $data_for_postrun_href->{'Data'}        = {'Error' => [{'Message' => "Organisation ($org_id) not found."}]};

    return $data_for_postrun_href;
  }

  my $chk_org_name_sql = 'SELECT OrganisationId FROM organisation WHERE OrganisationName=? AND OrganisationId <> ?';

  my ($read_err, $db_org_id) = read_cell($dbh, $chk_org_name_sql, [$org_name, $org_id]);

  if ($read_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  if (length($db_org_id) > 0) {

    my $err_msg = "OrganisationName ($org_name): already exists.";

    push(@{$org_error_aref}, {'OrganisationName' => $err_msg});
    $org_err = 1;
  }

  #prevalidate values to be finished in later version

  my ($vcol_error, $vcol_error_aref) = validate_all_factor_input($pre_validate_vcol);

  if ($vcol_error) {
    push(@{$org_error_aref}, @{$vcol_error_aref});
    $org_err = 1;
  }


  if ($org_err == 0) {
    $sql    = 'UPDATE organisation SET ';
    $sql   .= 'OrganisationName=? ';
    $sql   .= 'WHERE OrganisationId=?';

    my $sth = $dbh->prepare($sql);
    $sth->execute($org_name, $org_id);

    if ( $dbh->err() ) {

      $data_for_postrun_href->{'Error'}       = 1;
      $data_for_postrun_href->{'Data'}        = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    $sth->finish();

    my $vcol_error = [];

    for my $vcol_id (keys(%{$vcol_data})) {

      if (defined $query->param('VCol_' . "$vcol_id")) {

        my $factor_value = $query->param('VCol_' . "$vcol_id");

        my ($vcol_err, $vcol_msg) = update_factor_value($dbh, $vcol_id, $factor_value, 'organisationfactor', 'OrganisationId', $org_id);

        if ($vcol_err) {

          $self->logger->debug("VCol_" . "$vcol_id => $vcol_msg" );

          push(@{$org_error_aref}, {'VCol_' . "$vcol_id" => $vcol_msg});

          $org_err = 1;
        }
      }
    }
  }

  $dbh->disconnect();

  if ($org_err == 1) {
    $data_for_postrun_href->{'Error'} = $org_err;
    $data_for_postrun_href->{'Data'}  = {'Error' => $org_error_aref};

    return $data_for_postrun_href;
  }
  else {
    my $info_msg = "Organisation ($org_id) has been updated successfully.";

    $data_for_postrun_href->{'Error'}     = 0;
    $data_for_postrun_href->{'Data'}      = {'Info' => [{'Message' => $info_msg}]};
    $data_for_postrun_href->{'ExtraData'} = 0;

    return $data_for_postrun_href;
  }

  
}

sub list_contact_advanced_runmode {

=pod list_contact_advanced_HELP_START
{
"OperationName": "List contact(s)",
"Description": "Return list of contacts currently present in the system.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination Page='22' NumOfRecords='22' NumOfPages='22' NumPerPage='1' /><Contact OrganisationId='41' ContactLastName='User-25644445488' Longitude='149.1057021617679' ContactFirstName='Testing' ContactId='41' ContactAcronym='TU' OrganisationName='DArT Testing 90760121344' contactlocdt='2023-04-11 05:19:51' update='update/contact/41' contactlocation='MULTIPOINT(149.1057021617679 -35.317184619919445)' Latitude='-35.317184619919445' ContactEMail='admin@kddart.example.com' ContactMobile='04 12345678' ContactAddress='1 Wilf Crane Crescent Yarralumla ACT 2600 Australia' ContactTelephone='+61261227335' contactlocdescription=''/></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfRecords' : '22','NumOfPages' : 22,'NumPerPage' : '1','Page' : '22'}],'Contact' : [{ 'ContactFirstName' : 'Testing', 'ContactAcronym' : 'TU', 'ContactId' : 41, 'OrganisationId' : 41, 'ContactLastName' : 'User-25644445488', 'Longitude' : '149.1057021617679', 'ContactMobile' : '04 12345678', 'ContactAddress' : '1 Wilf Crane Crescent Yarralumla ACT 2600 Australia', 'ContactTelephone' : '+61261227335', 'contactlocdescription' : '', 'OrganisationName' : 'DArT Testing 90760121344', 'contactlocdt' : '2023-04-11 05:19:51', 'update' : 'update/contact/41', 'contactlocation' : 'MULTIPOINT(149.1057021617679 -35.317184619919445)', 'Latitude' : '-35.317184619919445', 'ContactEMail' : 'admin@kddart.example.com' }]}",
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

  my $sorting = '';

  if (defined $query->param('Sorting')) {

    $sorting = $query->param('Sorting');
  }

  my $dbh = connect_kdb_read();
  my $field_list = ['SCol*', 'VCol*', 'LCol*'];

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $field_list, 'contact',
                                                                        'ContactId', '');

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql   .= " LIMIT 1";

  $self->logger->debug("SQL with VCol: $sql");

  my ($sam_contact_err, $sam_contact_msg, $sam_contact_data) = $self->list_contact(0, $field_list, $sql);

  if ($sam_contact_err) {

    $self->logger->debug($sam_contact_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $sample_data_aref = $sam_contact_data;

  my @field_list_all;

  if (scalar(@{$sample_data_aref}) == 1) {

    @field_list_all = keys(%{$sample_data_aref->[0]});
  }
  else {

    $self->logger->debug("It reaches here");
    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'contact');

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

  my $final_field_list     = \@field_list_all;
  my $sql_field_list       = [];

  if (length($field_list_csv) > 0) {

    my ($sel_field_err, $sel_field_msg, $sel_field_list) = parse_selected_field($field_list_csv,
                                                                                $final_field_list,
                                                                                'ContactId');

    if ($sel_field_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;

    if ($filtering_csv =~ /OrganisationId/) {

      push(@{$final_field_list}, 'OrganisationId');
    }

    $sql_field_list       = [];
    for my $fd_name (@{$final_field_list}) {

      # need to remove location field because generate_factor_sql does not understand these field
      if ( (!($fd_name =~ /Longitude/)) && 
            (!($fd_name =~ /Latitude/)) && 
            (!($fd_name =~ /contactlocation/)) && 
            (!($fd_name =~ /contactlocdt/)) && 
            (!($fd_name =~ /contactlocdescription/))) {

        push(@{$sql_field_list}, $fd_name);
      }
    }
  }
  else {

    for my $fd_name (@{$final_field_list}) {

      # need to remove location field because generate_factor_sql does not understand these field
      if ( (!($fd_name =~ /Longitude/)) && 
            (!($fd_name =~ /Latitude/)) && 
            (!($fd_name =~ /contactlocation/)) && 
            (!($fd_name =~ /contactlocdt/)) && 
            (!($fd_name =~ /contactlocdescription/))) {

        push(@{$sql_field_list}, $fd_name);
      }
    }
  }

  my $sql_field_lookup = {};

  for my $fd_name (@{$sql_field_list}) {

    $sql_field_lookup->{$fd_name} = 1;
  }

  my $other_join = '';
  if ($sql_field_lookup->{'OrganisationId'}) {

    push(@{$sql_field_list}, 'organisation.OrganisationName');
    $other_join .= ' LEFT JOIN organisation ON contact.OrganisationId = organisation.OrganisationId ';
  }

  if ($filtering_csv !~ /Factor/) {

    ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $sql_field_list, 'contact',
                                                                       'ContactId', $other_join);
  }
  else {

    ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql_v2($dbh, $sql_field_list, 'contact',
                                                                          'ContactId', $other_join);
  }

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("Newly generated SQL: $sql");

  my ($filter_err, $filter_msg,
      $filter_phrase, $where_arg,
      $having_phrase, $count_filter_phrase,
      $nb_filter_factor) = parse_filtering_v2('ContactId',
                                              'contact',
                                              $filtering_csv,
                                              $final_field_list,
                                              $vcol_list);

  $self->logger->debug("Filter phrase: $filter_phrase");
  $self->logger->debug("Where argument: " . join(',', @{$where_arg}));

  if ($filter_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $filter_msg}]};

    return $data_for_postrun_href;
  }

  my $filter_where_phrase = '';
  if (length($filter_phrase) > 0) {

    $filter_where_phrase = " WHERE $filter_phrase ";
  }

  my $filtering_exp = $filter_where_phrase;

  $self->logger->debug("HAVING PHRASE: $having_phrase");

  if (length($having_phrase) > 0) {

    $sql =~ s/FACTORHAVING/ HAVING $having_phrase/;

    $sql .= " $filtering_exp ";
  }
  else {

    $sql =~ s/GROUP BY/ $filtering_exp GROUP BY /;
  }

  my $pagination_aref = [];
  my $paged_limit_clause = '';

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

    my ($pg_id_err, $pg_id_msg, $nb_records,
        $nb_pages, $limit_clause, $rcount_time);

    if (length($having_phrase) == 0) {

      $self->logger->debug("COUNT NB RECORD: NO FACTOR IN FILTERING");

      ($pg_id_err, $pg_id_msg, $nb_records,
       $nb_pages, $limit_clause, $rcount_time) = get_paged_filter($dbh,
                                                                  $nb_per_page,
                                                                  $page,
                                                                  'contact',
                                                                  'ContactId',
                                                                  $filtering_exp,
                                                                  $where_arg);
    }
    else {

      $self->logger->debug("COUNT NB RECORD: FACTOR IN FILTERING");

      my $count_sql = "SELECT COUNT(contact.ContactId) ";
      $count_sql   .= "FROM contact INNER JOIN ";
      $count_sql   .= " (SELECT ContactId, COUNT(ContactId) ";
      $count_sql   .= " FROM contactfactor WHERE $count_filter_phrase ";
      $count_sql   .= " GROUP BY ContactId HAVING COUNT(ContactId)=$nb_filter_factor) AS subq ";
      $count_sql   .= "ON contact.ContactId = subq.ContactId ";
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

    $self->logger->debug("SQL Count time: $rcount_time");

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

  my ($sort_err, $sort_msg, $sort_sql) = parse_sorting($sorting, $sql_field_list);

  if ($sort_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sort_msg}]};

    return $data_for_postrun_href;
  }

  if (length($sort_sql) > 0) {

    $sql .= " ORDER BY $sort_sql ";
  }
  else {

    $sql .= ' ORDER BY contact.ContactId DESC';
  }

  $sql .= " $paged_limit_clause ";

  $self->logger->debug("SQL with VCol: $sql");

  $self->logger->debug('Where arg: ' . join(',', @{$where_arg}));

  my ($read_contact_err, $read_contact_msg, $contact_data) = $self->list_contact(1,
                                                                                 $final_field_list,
                                                                                 $sql,
                                                                                 $where_arg);

  if ($read_contact_err) {

    $self->logger->debug($read_contact_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'geojson'}   = 1;
  $data_for_postrun_href->{'GJSonInfo'} = {'GeometryField' => 'contactlocation',
                                           'FeatureName'   => 'ContactFirstName ContactLastName [ id: ContactId ]',
                                           'FeatureId'     => 'ContactId',
  };
  $data_for_postrun_href->{'Data'}      = {'Contact'    => $contact_data,
                                           'VCol'       => $vcol_list,
                                           'Pagination' => $pagination_aref,
                                           'RecordMeta' => [{'TagName' => 'Contact'}],
  };

  return $data_for_postrun_href;
}

sub list_contact {

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

    if ($field eq 'Longitude' || $field eq 'Latitude' || $field eq 'LCol*' || $field eq 'contactlocation') {

      $field_list_loc_href->{$field} = 1;
    }
  }

  my @extra_attr_contact_data;

  my $gadmin_status = $self->authen->gadmin_status();

  my $contact_id_aref = [];

  for my $row (@{$data_aref}) {

    push(@{$contact_id_aref}, $row->{'ContactId'});
  }

  if (scalar(@{$contact_id_aref}) > 0) {

    my $contact_gis = {};

    if (scalar(keys(%{$field_list_loc_href})) > 0) {

      my $dbh_gis = connect_gis_read();
      $sql  = 'SELECT contactid, contactlocdt, description, ST_AsText(contactlocation) AS contactlocation ';
      $sql .= 'FROM ContactLoc ';
      $sql .= 'WHERE contactid IN (' . join(',', @{$contact_id_aref}) . ') AND currentloc = 1';

      my $sth_gis = $dbh_gis->prepare($sql);
      $sth_gis->execute();

      if (!$dbh_gis->err()) {

        my $gis_href = $sth_gis->fetchall_hashref('contactid');

        if (!$sth_gis->err()) {

          $contact_gis = $gis_href;
        }
        else {

          $err = 1;
          $msg = 'Unexpected error';
          $self->logger->debug('Err: ' . $dbh_gis->errstr());
        }
      }
      else {

        $err = 1;
        $msg = 'Unexpected error';
        $self->logger->debug('Err: ' . $dbh_gis->errstr());
      }

      my $gis_record_counter = scalar(keys(%{$contact_gis}));
      $self->logger->debug("GIS record count: $gis_record_counter");

      $sth_gis->finish();
      $dbh_gis->disconnect();
    }

    if ($err) {

      return ($err, $msg, \@extra_attr_contact_data);
    }

    my $chk_id_err        = 0;
    my $chk_id_msg        = '';
    my $used_id_href      = {};
    my $not_used_id_href  = {};

    if ($extra_attr_yes && ($gadmin_status eq '1')) {

      my $chk_table_aref = [{'TableName' => 'site', 'FieldName' => 'CurrentSiteManagerId'},
                            {'TableName' => 'trial', 'FieldName' => 'TrialManagerId'},
                            {'TableName' => 'systemuser', 'FieldName' => 'ContactId'},
                            {'TableName' => 'project', 'FieldName' => 'ProjectManagerId'},
                            {'TableName' => 'item', 'FieldName' => 'ItemSourceId'}
          ];

      ($chk_id_err, $chk_id_msg,
       $used_id_href, $not_used_id_href) = id_existence_bulk($dbh, $chk_table_aref, $contact_id_aref);

      if ($chk_id_err) {

        $self->logger->debug("Check id existence error: $chk_id_msg");
        $err = 1;
        $msg = $chk_id_msg;
      }
    }

    if ($err) {

      return ($err, $msg, \@extra_attr_contact_data);
    }

    for my $row (@{$data_aref}) {

      my $contact_id = $row->{'ContactId'};

      my $geocode_str = $contact_gis->{$contact_id}->{'contactlocation'};

      $geocode_str =~ /POINT\((.+) (.+)\)/;
      my $longitude = $1;
      my $latitude  = $2;

      if ($field_list_loc_href->{'LCol*'} || $field_list_loc_href->{'Longitude'}) {

        $row->{'Longitude'} = $longitude;
      }

      if ($field_list_loc_href->{'LCol*'} || $field_list_loc_href->{'Latitude'}) {

        $row->{'Latitude'}  = $latitude;
      }

      if ($field_list_loc_href->{'LCol*'} || $field_list_loc_href->{'contactlocation'}) {

        $row->{'contactlocation'} = $contact_gis->{$contact_id}->{'contactlocation'};
      }

      #$self->logger->debug("Geocode: $longitute, $latitute");
      $row->{'contactlocdt'} = $contact_gis->{$contact_id}->{'contactlocdt'};

      $row->{'contactlocdescription'} = $contact_gis->{$contact_id}->{'description'};

      if ($extra_attr_yes && ($gadmin_status eq '1') ) {

        $row->{'update'}   = "update/contact/$contact_id";

        # delete link only if this contact isn't used in contact
        if ( $not_used_id_href->{$contact_id} ) {

          $row->{'delete'}   = "delete/contact/$contact_id";
        }
      }
      push(@extra_attr_contact_data, $row);
    }
  }

  $dbh->disconnect();

  return ($err, $msg, \@extra_attr_contact_data);
}

sub add_contact_runmode {

=pod add_contact_gadmin_HELP_START
{
"OperationName": "Add contact",
"Description": "Add a new contact into a database. Contacts are related to organisations.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "contact",
"KDDArTFactorTable": "contactfactor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='24' ParaName='ContactId' /><Info Message='Contact (24) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '25','ParaName' : 'ContactId'}],'Info' : [{'Message' : 'Contact (25) has been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error OrganisationId='Organisation (25) does not exist.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'OrganisationId' : 'Organisation (25) does not exist.'}]}"}],
"HTTPParameter": [{"Name": "contactlocation", "DataType": "polygon_wkt", "Description": "GIS field defining the polygon geometry object of the survey in a standard GIS well-known text.", "Type": "LCol", "Required": "0"},{"Name": "contactlocdt", "DataType": "timestamp", "Description": "DateTime of survey location", "Type": "LCol", "Required": "0"},{"Name": "currentloc", "DataType": "tinyint", "Description": "Flag to notify current location", "Type": "LCol", "Required": "0"},{"Name": "description", "DataType": "varchar", "Description": "Description for location", "Type": "LCol", "Required": "0"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};
  my $contact_err = 0;
  my $contact_err_aref = [];

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read, 'contact', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $fname           = $query->param('ContactFirstName');
  my $lname           = $query->param('ContactLastName');
  my $org_id          = $query->param('OrganisationId');

  my $acronym         = '';

  if (defined $query->param('ContactAcronym')) {

    $acronym = $query->param('ContactAcronym');
  }

  my $address         = '';

  if (defined $query->param('ContactAddress')) {

    $address = $query->param('ContactAddress');
  }

  my $telephone       = '';

  if (defined $query->param('ContactTelephone')) {

    $telephone = $query->param('ContactTelephone');
  }

  my $mobile          = '';

  if (defined $query->param('ContactMobile')) {

    $mobile = $query->param('ContactMobile');
  }

  my $email           = '';

  if (defined $query->param('ContactEMail')) {

    $email = $query->param('ContactEMail');
  }

  my $contactlocation = '';

  if (length($query->param('contactlocation')) > 0) {

    $contactlocation = $query->param('contactlocation');
  }

  $self->logger->debug("First name: $fname");

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength, FactorValidRuleErrMsg, FactorValidRule  ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='contactfactor'";

  my $vcol_param_data = {};
  my $vcol_len_info   = {};
  my $vcol_param_data_maxlen = {};
  ##pre_validate_vcol -> { Rule -> [rule], RuleErrorMsg -> [msg], Value -> [value], FactorId -> [value] } 
  my $pre_validate_vcol = {};

  my $dbh_k_read = connect_kdb_read();
  my $vcol_data = $dbh_k_read->selectall_hashref($sql, 'FactorId');

  for my $vcol_id (keys(%{$vcol_data})) {

    my $vcol_param_name = "VCol_${vcol_id}";
    my $vcol_value      = $query->param($vcol_param_name);
    
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

    $data_for_postrun_href->{'Error'}       = 1;
    $data_for_postrun_href->{'Data'}        = {'Error' => [$vcol_missing_href]};

    return $data_for_postrun_href;
  }

  my ($vcol_maxlen_err, $vcol_maxlen_href) = check_maxlen_href($vcol_param_data_maxlen, $vcol_len_info);

  if ($vcol_maxlen_err) {

    $data_for_postrun_href->{'Error'}       = 1;
    $data_for_postrun_href->{'Data'}        = {'Error' => [$vcol_maxlen_href]};

    return $data_for_postrun_href;
  }

  my $org_existence = record_existence($dbh_k_read, 'organisation', 'OrganisationId', $org_id);

  $dbh_k_read->disconnect();

  $self->logger->debug("Organisation existence: $org_existence");

  if (!$org_existence) {

    push(@{$contact_err_aref}, {'OrganisationId' => "Organisation ($org_id) does not exist."});
    $contact_err = 1;
  }

  #prevalidate values to be finished in later version

  my ($vcol_error, $vcol_error_aref) = validate_all_factor_input($pre_validate_vcol);

  if ($vcol_error) {
    push(@{$contact_err_aref}, @{$vcol_error_aref});
    $contact_err = 1;
  }


  if ($contact_err != 0) {
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => $contact_err_aref};
    return $data_for_postrun_href;
  }

  my $dbh_k_write = connect_kdb_write(1);
  eval {
    $sql  = 'INSERT INTO contact SET ';
    $sql .= 'ContactLastName=?, ';
    $sql .= 'ContactFirstName=?, ';
    $sql .= 'ContactAcronym=?, ';
    $sql .= 'ContactAddress=?, ';
    $sql .= 'ContactTelephone=?, ';
    $sql .= 'ContactMobile=?, ';
    $sql .= 'ContactEMail=?, ';
    $sql .= 'OrganisationId=?';

    my $sth = $dbh_k_write->prepare($sql);
    $sth->execute($lname, $fname, $acronym, $address, $telephone, $mobile, $email, $org_id);
    my $contact_id = $dbh_k_write->last_insert_id(undef, undef, 'contact', 'ContactId');
    $sth->finish();

    for my $vcol_id (keys(%{$vcol_data})) {
      my $factor_value = $query->param('VCol_' . "$vcol_id");
      if (length($factor_value) > 0) {
        $sql  = 'INSERT INTO contactfactor SET ';
        $sql .= 'ContactId=?, ';
        $sql .= 'FactorId=?, ';
        $sql .= 'FactorValue=?';
        my $factor_sth = $dbh_k_write->prepare($sql);
        $factor_sth->execute($contact_id, $vcol_id, $factor_value);
        $factor_sth->finish();
      }
    }

    if (length($contactlocation) > 0) {
      my $sub_PGIS_val_builder = sub {
        my $wkt = shift;
        if ($wkt =~ /^POINT/i) {
          return "ST_Multi(ST_GeomFromText(?, -1))";
        } else {
          return "ST_GeomFromText(?, -1)";
        }
      };
      my ($err, $err_msg) = append_geography_loc(
                                                  "contact",
                                                  $contact_id,
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

    my $info_msg_aref  = [{'Message' => "Contact ($contact_id) has been added successfully."}];
    my $return_id_aref = [{'Value' => "$contact_id", 'ParaName' => 'ContactId'}];
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

  $dbh_k_write->disconnect;
  return $data_for_postrun_href;
}


sub add_organisation_runmode {

=pod add_organisation_gadmin_HELP_START
{
"OperationName": "Add organisation",
"Description": "Add a new organisation into a database.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "organisation",
"KDDArTFactorTable": "organisationfactor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='25' ParaName='OrganisationId' /><Info Message='Organisation (25) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '26','ParaName' : 'OrganisationId'}],'Info' : [{'Message' : 'Organisation (26) has been added successfully.'}]}",
"ErrorMessageXML": [{"NameAlreadyExists": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error OrganisationName='OrganisationName (DArT): already exists' /></DATA>"}],
"ErrorMessageJSON": [{"NameAlreadyExists": "{'Error' : [{'OrganisationName' : 'OrganisationName (DArT): already exists'}]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};
  my $org_err = 0;
  my $org_error_aref = [];

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'organisation', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $org_name = $query->param('OrganisationName');

  my $dbh_k_write = connect_kdb_write();

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength, FactorValidRuleErrMsg, FactorValidRule  ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='organisationfactor'";

  my $vcol_data = $dbh_read->selectall_hashref($sql, 'FactorId');

  my $vcol_param_data = {};
  my $vcol_len_info   = {};
  my $vcol_param_data_maxlen = {};

  #pre_validate_vcol -> { Rule -> [rule], RuleErrorMsg -> [msg], Value -> [value], FactorId -> [value] } 
  my $pre_validate_vcol = {};

  for my $vcol_id (keys(%{$vcol_data})) {

    my $vcol_param_name = "VCol_${vcol_id}";
    my $vcol_value      = $query->param($vcol_param_name);
    if ($vcol_data->{$vcol_id}->{'CanFactorHaveNull'} != 1) {

      $vcol_param_data->{$vcol_param_name} = $vcol_value;
    }

    $pre_validate_vcol->{$vcol_param_name} = {
      'Rule' => $vcol_data->{$vcol_id}->{'FactorValidRule'},
      'Value'=> $vcol_value,
      'FactorId'=> $vcol_id,
      'RuleErrorMsg'=> $vcol_data->{$vcol_id}->{'FactorValidRuleErrMsg'},
      'CanFactorHaveNull' => $vcol_data->{$vcol_id}->{'CanFactorHaveNull'},
    };

    $vcol_len_info->{$vcol_param_name} = $vcol_data->{$vcol_id}->{'FactorValueMaxLength'};
    $vcol_param_data_maxlen->{$vcol_param_name} = $vcol_value;
  }

  my ($vcol_missing_err, $vcol_missing_href) = check_missing_href( $vcol_param_data );

  if ($vcol_missing_err) {

    push(@{$org_error_aref}, $vcol_missing_href);
    $org_err = 1;
  }

if ($org_err == 1) {
    $data_for_postrun_href->{'Data'}        = {'Error' => $org_error_aref};

    return $data_for_postrun_href;
  }

  my ($vcol_maxlen_err, $vcol_maxlen_href) = check_maxlen_href($vcol_param_data_maxlen, $vcol_len_info);

  if ($vcol_maxlen_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$vcol_maxlen_href]};

    return $data_for_postrun_href;
  }

  if (record_existence($dbh_k_write, 'organisation', 'OrganisationName', $org_name)) {

    my $err_msg = "OrganisationName ($org_name): already exists";

    push(@{$org_error_aref}, {'OrganisationName' => $err_msg});
    $org_err = 1;
  }

  my ($vcol_error, $vcol_error_aref) = validate_all_factor_input($pre_validate_vcol);

  if ($vcol_error) {
    push(@{$org_error_aref}, @{$vcol_error_aref});
   $org_err = 1;
  }


  if ($org_err == 0) {

    $sql    = 'INSERT INTO organisation SET ';
    $sql   .= 'OrganisationName=?';

    my $sth = $dbh_k_write->prepare($sql);
    $sth->execute($org_name);

    my $org_id = -1;
    if (!$dbh_k_write->err()) {

        $org_id = $dbh_k_write->last_insert_id(undef, undef, 'organisation', 'OrganisationId');
        $self->logger->debug("OrganisationId: $org_id");
    }
    else {

        $data_for_postrun_href->{'Error'}       = 1;
        $data_for_postrun_href->{'Data'}        = {'Error' => [{'Message' => 'Unexpected error.'}]};

        return $data_for_postrun_href;
    }
    $sth->finish();

    for my $vcol_id (keys(%{$vcol_data})) {

        if (defined $query->param('VCol_' . "$vcol_id")) {

            my $factor_value = $query->param('VCol_' . "$vcol_id");

            my ($vcol_err, $vcol_msg) = update_factor_value($dbh_k_write, $vcol_id, $factor_value, 'organisationfactor', 'OrganisationId', $org_id);

            if ($vcol_err) {

                    $data_for_postrun_href->{'Error'} = $vcol_err;
                    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $vcol_msg}]};

                    return $data_for_postrun_href;
            }
        }
    }

    $dbh_k_write->disconnect();

    my $info_msg_aref  = [{'Message' => "Organisation ($org_id) has been added successfully."}];
    my $return_id_aref = [{'Value' => "$org_id", 'ParaName' => 'OrganisationId'}];

    $data_for_postrun_href->{'Error'}     = 0;
    $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                            'ReturnId' => $return_id_aref,
    };
    $data_for_postrun_href->{'ExtraData'} = 0;
  }
  else {
    $data_for_postrun_href->{'Error'} = $org_err;
    $data_for_postrun_href->{'Data'}  = {'Error' => $org_error_aref};

    return $data_for_postrun_href;
  }

  return $data_for_postrun_href;
}

sub del_organisation_runmode {

=pod del_organisation_gadmin_HELP_START
{
"OperationName": "Delete organisation",
"Description": "Delete organisation from the database using specified id. Organisation can be deleted only if not attached to any lower level record.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Organisation (25) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Organisation (26) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdUsed": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Organisation (1) is being used in contact.' /></DATA>"}],
"ErrorMessageJSON": [{"IdUsed": "{'Error' : [{'Message' : 'Organisation (1) is being used in contact.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing OrganisationId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self   = shift;
  my $org_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_write = connect_kdb_write();

  my $sql = 'SELECT organisation.OrganisationId, contact.ContactId ';
  $sql   .= 'FROM organisation LEFT JOIN contact ON ';
  $sql   .= 'organisation.OrganisationId = contact.OrganisationId ';
  $sql   .= 'WHERE organisation.OrganisationId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($org_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'}       = 1;
    $data_for_postrun_href->{'Data'}        = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $org_info = $sth->fetchall_arrayref({});

  $sth->finish();

  if ( scalar(@{$org_info}) == 0 ) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => "Organisation ($org_id) not found."}]};

    return $data_for_postrun_href;
  }
  elsif ( (scalar(@{$org_info}) > 1) ||
          (scalar(@{$org_info}) == 1 && length($org_info->[0]->{'ContactId'}) > 0)
      ) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => "Organisation ($org_id) is being used in contact."}]};

    return $data_for_postrun_href;
  }

  $sql = 'DELETE FROM organisation WHERE OrganisationId=?';

  $sth = $dbh_write->prepare($sql);
  $sth->execute($org_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "Organisation ($org_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub del_contact_runmode {

=pod del_contact_gadmin_HELP_START
{
"OperationName": "Delete contact",
"Description": "Delete contact from the database using specified id. Contact can be deleted only if not attached to any lower level record.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Contact (25) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Contact (24) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdUsed": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Contact (1) used in site.' /></DATA>"}],
"ErrorMessageJSON": [{"IdUsed": "{'Error' : [{'Message' : 'Contact (1) used in site.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing ContactId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $contact_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_k_read = connect_kdb_read();

  my $contact_exist = record_existence($dbh_k_read, 'contact', 'ContactId', $contact_id);

  if (!$contact_exist) {

    my $err_msg = "Contact ($contact_id) not found";
    $data_for_postrun_href->{'Error'}       = 1;
    $data_for_postrun_href->{'Data'}        = {'Error' => [{'Message' => $err_msg}]};
    return $data_for_postrun_href;
  }

  my $cont_used_in_site     = record_existence($dbh_k_read, 'site', 'CurrentSiteManagerId', $contact_id);

  if ($cont_used_in_site) {

    my $err_msg = "Contact ($contact_id) used in site.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $contact_in_trial = record_existence($dbh_k_read, 'trial', 'TrialManagerId', $contact_id);

  if ($contact_in_trial) {

    my $err_msg = "Contact ($contact_id) used in trial.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $contact_in_systemuser = record_existence($dbh_k_read, 'systemuser', 'ContactId', $contact_id);

  if ($contact_in_systemuser) {

    my $err_msg = "Contact ($contact_id) used in systemuser.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'ContactId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $cont_used_in_project  = record_existence($dbh_k_read, 'project', 'ProjectManagerId', $contact_id);

  if ($cont_used_in_project) {

    my $err_msg = "Contact ($contact_id) used in project.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $cont_used_in_item     = record_existence($dbh_k_read, 'item', 'ItemSourceId', $contact_id);

  if ($cont_used_in_item) {

    my $err_msg = "Contact ($contact_id) used in item.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_gis_write = connect_gis_write();

  my $sql = 'DELETE FROM contactloc WHERE contactid=?';

  my $sth = $dbh_gis_write->prepare($sql);
  $sth->execute($contact_id);

  if ($dbh_gis_write->err()) {

    $self->logger->debug("Delete contactloc failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_gis_write->disconnect();

  my $dbh_k_write = connect_kdb_write();

  $sql = 'DELETE FROM contactfactor WHERE ContactId=?';
  $sth = $dbh_k_write->prepare($sql);

  $sth->execute($contact_id);

  if ($dbh_k_write->err()) {

    $self->logger->debug("Delete contactfactor failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $sql = 'DELETE FROM contact WHERE ContactId=?';
  $sth = $dbh_k_write->prepare($sql);

  $sth->execute($contact_id);

  if ($dbh_k_write->err()) {

    $self->logger->debug("Delete contact failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref = [{'Message' => "Contact ($contact_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_contact_runmode {

=pod update_contact_gadmin_HELP_START
{
"OperationName": "Update contact",
"Description": "Update a contact in the database using specified id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "contact",
"KDDArTFactorTable": "contactfactor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Contact (23) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Contact (23) has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='ContactId (25) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'ContactId (25) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing ContactId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $contact_id = $self->param('id');
  my $query      = $self->query();

  my $data_for_postrun_href = {};
  my $contact_err = 0;
  my $contact_err_aref = [];

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read, 'contact', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $dbh_k_read = connect_kdb_read();

  my $contact_exist = record_existence($dbh_k_read, 'contact', 'ContactId', $contact_id);

  if (!$contact_exist) {

    $data_for_postrun_href->{'Error'}       = 1;
    $data_for_postrun_href->{'Data'}        = {'Error' => [{'Message' => "ContactId ($contact_id) not found."}]};

    return $data_for_postrun_href;
  }

  my $fname           = $query->param('ContactFirstName');
  my $lname           = $query->param('ContactLastName');
  my $org_id          = $query->param('OrganisationId');

  my $read_contact_sql      =  'SELECT ContactAcronym, ContactAddress, ContactTelephone, ContactMobile, ContactEmail ';
     $read_contact_sql     .=  'FROM contact WHERE ContactId=? ';

  my ($r_df_val_err, $r_df_val_msg, $contact_df_val_data) = read_data($dbh_k_read, $read_contact_sql, [$contact_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve contact default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $acronym     =  undef;
  my $address     =  undef;
  my $telephone   =  undef;
  my $mobile      =  undef;
  my $email       =  undef;

  my $nb_df_val_rec    =  scalar(@{$contact_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve contact default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $acronym     =  $contact_df_val_data->[0]->{'ContactAcronym'};
  $address     =  $contact_df_val_data->[0]->{'ContactAddress'};
  $telephone   =  $contact_df_val_data->[0]->{'ContactTelephone'};
  $mobile      =  $contact_df_val_data->[0]->{'ContactMobile'};
  $email       =  $contact_df_val_data->[0]->{'ContactEmail'};


  if (defined $query->param('ContactAcronym')) {

    $acronym = $query->param('ContactAcronym');
  }


  if (defined $query->param('ContactAddress')) {

    $address = $query->param('ContactAddress');
  }


  if (defined $query->param('ContactTelephone')) {

    $telephone = $query->param('ContactTelephone');
  }


  if (defined $query->param('ContactMobile')) {

    $mobile = $query->param('ContactMobile');
  }


  if (defined $query->param('ContactEMail')) {

    $email = $query->param('ContactEMail');
  }

  my $contactlocation = '';

  if (defined($query->param('contactlocation'))) {

    $contactlocation = $query->param('contactlocation');
  }

  if (length($contactlocation) > 0) {

    my $dbh_gis_read = connect_gis_read();
    my ($is_wkt_err, $wkt_err_href) = is_valid_wkt_href($dbh_gis_read, {'contactlocation' => $contactlocation}, ['POINT', 'MULTIPOINT']);
    $dbh_gis_read->disconnect();

    if ($is_wkt_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [$wkt_err_href]};

      return $data_for_postrun_href;
    }
  }

  $self->logger->debug("First name: $fname");

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength, FactorValidRuleErrMsg, FactorValidRule  ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='contactfactor'";

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

    $data_for_postrun_href->{'Error'}       = 1;
    $data_for_postrun_href->{'Data'}        = {'Error' => [$vcol_missing_href]};

    return $data_for_postrun_href;
  }

  my ($vcol_maxlen_err, $vcol_maxlen_href) = check_maxlen_href($vcol_param_data_maxlen, $vcol_len_info);

  if ($vcol_maxlen_err) {

    $data_for_postrun_href->{'Error'}       = 1;
    $data_for_postrun_href->{'Data'}        = {'Error' => [$vcol_maxlen_href]};

    return $data_for_postrun_href;
  }

  my $org_existence = record_existence($dbh_k_read, 'organisation', 'OrganisationId', $org_id);
  $dbh_k_read->disconnect();

  if (!$org_existence) {

    push(@{$contact_err_aref}, {'OrganisationId' => "Organisation ($org_id) does not exist."});
    $contact_err = 1;
  }
  


  my ($vcol_error, $vcol_error_aref) = validate_all_factor_input($pre_validate_vcol);

  if ($vcol_error) {
    push(@{$contact_err_aref}, @{$vcol_error_aref});
    $contact_err = 1;
  }


  if ($contact_err != 0) {
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => $contact_err_aref};
    return $data_for_postrun_href;
  }

  my $dbh_k_write = connect_kdb_write();

  $sql  = 'UPDATE contact SET ';
  $sql .= 'ContactLastName=?, ';
  $sql .= 'ContactFirstName=?, ';
  $sql .= 'ContactAcronym=?, ';
  $sql .= 'ContactAddress=?, ';
  $sql .= 'ContactTelephone=?, ';
  $sql .= 'ContactMobile=?, ';
  $sql .= 'ContactEMail=?, ';
  $sql .= 'OrganisationId=? ';
  $sql .= 'WHERE ContactId=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($lname, $fname, $acronym, $address, $telephone, $mobile, $email, $org_id, $contact_id);

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

      my ($vcol_err, $vcol_msg) = update_factor_value($dbh_k_write, $vcol_id, $factor_value, 'contactfactor', 'ContactId', $contact_id);

      if ($vcol_err) {

        $self->logger->debug("VCol_" . "$vcol_id => $vcol_msg" );

        push(@{$contact_err_aref}, {'VCol_' . "$vcol_id" => $vcol_msg});

        $contact_err = 1;
      }
    }
  }

  $dbh_k_write->disconnect();

  if ($contact_err != 0) {
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => $contact_err_aref};
    return $data_for_postrun_href;
  }

  my $info_msg_aref = [{'Message' => "Contact ($contact_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub get_contact_runmode {

=pod get_contact_HELP_START
{
"OperationName": "Get contact",
"Description": "Return detailed information about contact specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><<Contact OrganisationId='41' ContactLastName='User-25644445488' Longitude='149.1057021617679' ContactFirstName='Testing' ContactId='41' ContactAcronym='TU' OrganisationName='DArT Testing 90760121344' contactlocdt='2023-04-11 05:19:51' update='update/contact/41' contactlocation='MULTIPOINT(149.1057021617679 -35.317184619919445)' Latitude='-35.317184619919445' ContactEMail='admin@kddart.example.com' ContactMobile='04 12345678' ContactAddress='1 Wilf Crane Crescent Yarralumla ACT 2600 Australia' ContactTelephone='+61261227335' contactlocdescription=''/></DATA>",
"SuccessMessageJSON": "{'Contact' : [{ 'ContactFirstName' : 'Testing', 'ContactAcronym' : 'TU', 'ContactId' : 41, 'OrganisationId' : 41, 'ContactLastName' : 'User-25644445488', 'Longitude' : '149.1057021617679', 'ContactMobile' : '04 12345678', 'ContactAddress' : '1 Wilf Crane Crescent Yarralumla ACT 2600 Australia', 'ContactTelephone' : '+61261227335', 'contactlocdescription' : '', 'OrganisationName' : 'DArT Testing 90760121344', 'contactlocdt' : '2023-04-11 05:19:51', 'update' : 'update/contact/41', 'contactlocation' : 'MULTIPOINT(149.1057021617679 -35.317184619919445)', 'Latitude' : '-35.317184619919445', 'ContactEMail' : 'admin@kddart.example.com' }],'VCol' : [],'RecordMeta' : [{'TagName' : 'Contact'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='ContactId (25): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'ContactId (25): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing ContactId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $contact_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();
  my $contact_exist = record_existence($dbh, 'contact', 'ContactId', $contact_id);

  if (!$contact_exist) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => "ContactId ($contact_id): not found."}]};

    return $data_for_postrun_href;
  }

  my $field_list = ['contact.*', 'VCol*', 'LCol*', 'organisation.OrganisationName'];

  my $other_join = ' LEFT JOIN organisation ON contact.OrganisationId = organisation.OrganisationId ';

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $field_list, 'contact',
                                                                        'ContactId', $other_join);
  $dbh->disconnect();

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql  =~ s/GROUP BY/ WHERE contact.ContactId=? GROUP BY /;

  $self->logger->debug("SQL with VCol: $sql");

  my ($read_contact_err, $read_contact_msg, $contact_data) = $self->list_contact(1, $field_list, $sql, [$contact_id]);

  if ($read_contact_err) {

    $self->logger->debug($read_contact_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'geojson'}   = 1;
  $data_for_postrun_href->{'GJSonInfo'} = {'GeometryField' => 'contactlocation',
                                           'FeatureName'   => 'ContactFirstName ContactLastName [ id: ContactId ]',
                                           'FeatureId'     => 'ContactId',
  };

  $data_for_postrun_href->{'Data'}  = {'Contact'    => $contact_data,
                                       'VCol'       => $vcol_list,
                                       'RecordMeta' => [{'TagName' => 'Contact'}],
  };

  return $data_for_postrun_href;
}

sub update_contact_geography_runmode {

=pod update_contact_geography_HELP_START
{
"OperationName": "Update contact location",
"Description": "Update contact's geographical location.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Contact (1) location has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Contact (1) location has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Contact (20) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Contact (20) not found.'}]}"}],
"HTTPParameter": [{"Name": "contactlocation", "DataType": "polygon_wkt", "Description": "GIS field defining the polygon geometry object of the contact in a standard GIS well-known text.", "Type": "LCol", "Required": "1"},{"Name": "contactlocdt", "DataType": "timestamp", "Description": "DateTime of contact location", "Type": "LCol", "Required": "0"},{"Name": "currentloc", "DataType": "tinyint", "Description": "Flag to notify current location", "Type": "LCol", "Required": "0"},{"Name": "description", "DataType": "varchar", "Description": "Description for location", "Type": "LCol", "Required": "0"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing ContactId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self        = shift;
  my $contact_id  = $self->param('id');
  my $query       = $self->query();

  my $data_for_postrun_href = {};

  my $dbh_k_read = connect_kdb_read();
  my $contact_exist = record_existence($dbh_k_read, 'contact', 'ContactId', $contact_id);
  $dbh_k_read->disconnect();

  if (!$contact_exist) {

    my $err_msg = "Contact ($contact_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sub_PGIS_val_builder = sub {
    my $wkt = shift;
    if ($wkt =~ /^POINT/i) {
      return "ST_Multi(ST_GeomFromText(?, -1))";
    } else {
      return "ST_GeomFromText(?, -1)";
    }
  };

  my ($err, $err_msg) = append_geography_loc(
                                              "contact",
                                              $contact_id,
                                              ['POINT','MULTIPOINT'],
                                              $query,
                                              $sub_PGIS_val_builder,
                                              $self->logger,
                                            );

  if ($err) {
    $data_for_postrun_href = $self->_set_error($err_msg);
  } else {
    my $info_msg_aref = [{'Message' => "Contact ($contact_id) location has been updated successfully."}];
    $data_for_postrun_href->{'Error'}     = 0;
    $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
    $data_for_postrun_href->{'ExtraData'} = 0;
  }

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

1;
