#$Id$
#$Author$

# Copyright (c) 2025, Diversity Arrays Technology, All rights reserved.

# Author    : Puthick Hok
# Created   : 02/06/2010
# Modified  :
# Purpose   :
#
#

package KDDArT::DAL::Trait;

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
use DateTime;
use Crypt::Random qw( makerandom );
use Digest::MD5 qw(md5 md5_hex md5_base64);
use File::Lockfile;
use DateTime::Format::MySQL;
use XML::Checker::Parser;


sub setup {

  my $self = shift;

  CGI::Session->name($COOKIE_NAME);

  __PACKAGE__->authen->init_config_parameters();
  __PACKAGE__->authen->check_login_runmodes(':all');
  __PACKAGE__->authen->check_content_type_runmodes(':all');
  __PACKAGE__->authen->check_rand_runmodes('add_treatment_gadmin',
                                           'import_samplemeasurement_csv',
                                           'update_treatment_gadmin',
                                           'update_trait',
                                           'add_trait_alias',
                                           'remove_trait_alias',
                                           'update_trait_alias',
                                           'del_trait_gadmin',
                                           'del_treatment_gadmin',
                                           'import_datakapture_data_csv',
                                           'import_smgroup_data_csv',
                                           'update_smgroup',
                                           'del_smgroup',
                                           'add_traitgroup',
                                           'update_traitgroup',
                                           'add_trait2traitgroup',
                                           'remove_trait_from_traitgroup',
                                           'del_traitgroup',
                                           'import_itemmeasurement_csv',
                                           'import_imgroup_data_csv',
                                           'update_imgroup',
                                           'delete_imgroup',
                                           'import_crossingmeasurement_csv',
                                           'import_cmgroup_data_csv',
                                           'update_cmgroup',
                                           'delete_cmgroup',

      );
  __PACKAGE__->authen->count_session_request_runmodes(':all');
  __PACKAGE__->authen->check_signature_runmodes('add_treatment_gadmin',
                                                'add_trait',
                                                'update_treatment_gadmin',
                                                'update_trait',
                                                'add_trait_alias',
                                                'remove_trait_alias',
                                                'update_trait_alias',
                                                'del_trait_gadmin',
                                                'del_treatment_gadmin',
                                                'update_smgroup',
                                                'del_smgroup',
                                                'update_traitgroup',
                                                'remove_trait_from_traitgroup',
                                                'del_traitgroup',
                                                'update_imgroup',
                                                'delete_imgroup',
                                                'update_cmgroup',
                                                'delete_cmgroup',

      );
  __PACKAGE__->authen->check_gadmin_runmodes('add_treatment_gadmin',
                                             'update_treatment_gadmin',
                                             'del_trait_gadmin',
                                             'del_treatment_gadmin'
      );
  __PACKAGE__->authen->check_sign_upload_runmodes('import_samplemeasurement_csv',
                                                  'import_datakapture_data_csv',
                                                  'import_smgroup_data_csv',
                                                  'add_traitgroup',
                                                  'add_trait2traitgroup',
                                                  'import_itemmeasurement_csv',
                                                  'import_imgroup_data_csv',
                                                  'import_crossingmeasurement_csv',
                                                  'import_cmgroup_data_csv',
      );

  $self->run_modes(
    'add_treatment_gadmin'             => 'add_treatment_runmode',
    'add_trait'                        => 'add_trait_runmode',
    'import_samplemeasurement_csv'     => 'import_samplemeasurement_csv_runmode',
    'get_treatment'                    => 'get_treatment_runmode',
    'update_treatment_gadmin'          => 'update_treatment_runmode',
    'get_trait'                        => 'get_trait_runmode',
    'update_trait'                     => 'update_trait_runmode',
    'add_trait_alias'                  => 'add_trait_alias_runmode',
    'remove_trait_alias'               => 'remove_trait_alias_runmode',
    'update_trait_alias'               => 'update_trait_alias_runmode',
    'list_trait_alias'                 => 'list_trait_alias_runmode',
    'export_samplemeasurement_csv'     => 'export_samplemeasurement_csv_runmode',
    'list_samplemeasurement_advanced'  => 'list_samplemeasurement_advanced_runmode',
    'list_trait_advanced'              => 'list_trait_advanced_runmode',
    'list_treatment_advanced'          => 'list_treatment_advanced_runmode',
    'del_trait_gadmin'                 => 'del_trait_runmode',
    'del_treatment_gadmin'             => 'del_treatment_runmode',
    'export_datakapture_template'      => 'export_datakapture_template_runmode',
    'export_dkdata_summary'            => 'export_dkdata_summary_runmode',
    'get_genotypedata'                 => 'get_genotypedata_runmode',
    'import_datakapture_data_csv'      => 'import_datakapture_data_csv_runmode',
    'export_datakapture_data'          => 'export_datakapture_data_runmode',
    'list_instancenumber'              => 'list_instancenumber_runmode',
    'import_smgroup_data_csv'          => 'import_smgroup_data_csv_runmode',
    'list_smgroup'                     => 'list_smgroup_runmode',
    'get_smgroup'                      => 'get_smgroup_runmode',
    'update_smgroup'                   => 'update_smgroup_runmode',
    'del_smgroup'                      => 'del_smgroup_runmode',
    'add_traitgroup'                   => 'add_traitgroup_runmode',
    'update_traitgroup'                => 'update_traitgroup_runmode',
    'list_traitgroup_advanced'         => 'list_traitgroup_advanced_runmode',
    'get_traitgroup'                   => 'get_traitgroup_runmode',
    'add_trait2traitgroup'             => 'add_trait2traitgroup_runmode',
    'remove_trait_from_traitgroup'     => 'remove_trait_from_traitgroup_runmode',
    'del_traitgroup'                   => 'del_traitgroup_runmode',
    'import_itemmeasurement_csv'       => 'import_itemmeasurement_csv_runmode',
    'export_itemmeasurement_csv'       => 'export_itemmeasurement_csv_runmode',
    'import_imgroup_data_csv'          => 'import_imgroup_data_csv_runmode',
    'list_itemmeasurement_advanced'    => 'list_itemmeasurement_advanced_runmode',
    'list_imgroup'                     => 'list_imgroup_runmode',
    'get_imgroup'                      => 'get_imgroup_runmode',
    'update_imgroup'                   => 'update_imgroup_runmode',
    'delete_imgroup'                   => 'delete_imgroup_runmode',
    'import_crossingmeasurement_csv'         => 'import_crossingmeasurement_csv_runmode',
    'export_crossingmeasurement_csv'         => 'export_crossingmeasurement_csv_runmode',
    'import_cmgroup_data_csv'                => 'import_cmgroup_data_csv_runmode',
    'list_crossingmeasurement_advanced'      => 'list_crossingmeasurement_advanced_runmode',
    'list_cmgroup'                           => 'list_cmgroup_runmode',
    'get_cmgroup'                            => 'get_cmgroup_runmode',
    'update_cmgroup'                         => 'update_cmgroup_runmode',
    'delete_cmgroup'                         => 'delete_cmgroup_runmode'
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

sub add_treatment_runmode {

=pod add_treatment_gadmin_HELP_START
{
"OperationName": "Add treatment",
"Description": "Add a new treatment to the treatment dictionary.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "treatment",
"KDDArTFactorTable": "treatmentfactor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='14' ParaName='TreatmentId' /><Info Message='Treatment (14) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '15', 'ParaName' : 'TreatmentId'}], 'Info' : [{'Message' : 'Treatment (15) has been added successfully.'}]}",
"ErrorMessageXML": [{"MissingParameter": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error TreatmentText='TreatmentText is missing.' /></DATA>"}],
"ErrorMessageJSON": [{"MissingParameter": "{'Error' : [{'TreatmentText' : 'TreatmentText is missing.'}]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};
  my $treatment_err = 0;
  my $treatment_err_aref = [];

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'treatment', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $treatment_text        = $query->param('TreatmentText');

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength, FactorValidRuleErrMsg, FactorValidRule  ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='treatmentfactor'";

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
  
  my ($vcol_maxlen_err, $vcol_maxlen_msg) = check_maxlen($vcol_param_data_maxlen, $vcol_len_info);

  if ($vcol_maxlen_err) {

    $vcol_maxlen_msg = $vcol_maxlen_msg . ' longer than maximum length.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $vcol_maxlen_msg}]};

    return $data_for_postrun_href;
  }

  if (record_existence($dbh_k_read, 'treatment', 'TreatmentText', $treatment_text)) {

    my $err_msg = "TreatmentText ($treatment_text): already exists.";

    push(@{$treatment_err_aref}, {'TreatmentText' => $err_msg});
    $treatment_err = 1;
  }

  $dbh_k_read->disconnect();

  my ($vcol_error, $vcol_error_aref) = validate_all_factor_input($pre_validate_vcol);

  if ($vcol_error) {
    push(@{$treatment_err_aref}, @{$vcol_error_aref});
    $treatment_err = 1;
  }

  if ($treatment_err != 0) {
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => $treatment_err_aref};
    return $data_for_postrun_href;
  }

  my $dbh_k_write = connect_kdb_write();

  $sql  = 'INSERT INTO treatment SET ';
  $sql .= 'TreatmentText=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($treatment_text);

  my $treatment_id = -1;
  if (!$dbh_k_write->err()) {

    $treatment_id = $dbh_k_write->last_insert_id(undef, undef, 'treatment', 'TreatmentId');
    $self->logger->debug("TreatmentId: $treatment_id");
  }
  else {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  for my $vcol_id (keys(%{$vcol_data})) {

    my $factor_value = $query->param('VCol_' . "$vcol_id");

    if (length($factor_value) > 0) {

      $sql  = 'INSERT INTO treatmentfactor SET ';
      $sql .= 'TreatmentId=?, ';
      $sql .= 'FactorId=?, ';
      $sql .= 'FactorValue=?';
      my $factor_sth = $dbh_k_write->prepare($sql);
      $factor_sth->execute($treatment_id, $vcol_id, $factor_value);

      if ($dbh_k_write->err()) {

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

        return $data_for_postrun_href;
      }

      $factor_sth->finish();
    }
  }

  $dbh_k_write->disconnect();

  my $info_msg_aref  = [{'Message' => "Treatment ($treatment_id) has been added successfully."}];
  my $return_id_aref = [{'Value'   => "$treatment_id", 'ParaName' => 'TreatmentId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_treatment_runmode {

=pod update_treatment_gadmin_HELP_START
{
"OperationName": "Update treatment",
"Description": "Update treatment definition for a specified id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "treatment",
"KDDArTFactorTable": "treatmentfactor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Treatment (15) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Treatment (15) has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Treatment (16) not found.' /></DATA>" }],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Treatment (16) not found.'}]}" }],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TreatmentId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self         = shift;
  my $treatment_id = $self->param('id');
  my $query        = $self->query();

  my $data_for_postrun_href = {};
  my $treatment_err = 0;
  my $treatment_err_aref = [];

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'treatment', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  # Finish generic required static field checking

  my $dbh_k_read = connect_kdb_read();
  my $treatment_exist = record_existence($dbh_k_read, 'treatment', 'TreatmentId', $treatment_id);

  if (!$treatment_exist) {

    my $err_msg = "Treatment ($treatment_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $treatment_text        = $query->param('TreatmentText');

 my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength, FactorValidRuleErrMsg, FactorValidRule  ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='treatmentfactor'";

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

  my ($vcol_missing_err, $vcol_missing_msg) = check_missing_value( $vcol_param_data );

  if ($vcol_missing_err) {

    $vcol_missing_msg = $vcol_missing_msg . ' missing';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $vcol_missing_msg}]};

    return $data_for_postrun_href;
  }

  my ($vcol_maxlen_err, $vcol_maxlen_msg) = check_maxlen($vcol_param_data_maxlen, $vcol_len_info);

  if ($vcol_maxlen_err) {

    $vcol_maxlen_msg = $vcol_maxlen_msg . ' longer than maximum length.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $vcol_maxlen_msg}]};

    return $data_for_postrun_href;
  }

  $sql = 'SELECT TreatmentId FROM treatment WHERE TreatmentText=? AND TreatmentId<>?';

  my ($r_treatment_err, $db_treatment_id) = read_cell($dbh_k_read, $sql, [$treatment_text, $treatment_id]);

  if ($r_treatment_err) {

    $self->logger->debug("Read treatment id from db failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  if (length($db_treatment_id) > 0) {

    my $err_msg = "TreatmentText ($treatment_text): already exists.";

    push(@{$treatment_err_aref}, {'TreatmentText' => $err_msg});
    $treatment_err = 1;
  }

  $dbh_k_read->disconnect();

  my ($vcol_error, $vcol_error_aref) = validate_all_factor_input($pre_validate_vcol);

  if ($vcol_error) {
    push(@{$treatment_err_aref}, @{$vcol_error_aref});
    $treatment_err = 1;
  }

  if ($treatment_err != 0) {
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => $treatment_err_aref};
    return $data_for_postrun_href;
  }

  my $dbh_k_write = connect_kdb_write();

  $sql  = 'UPDATE treatment SET ';
  $sql .= 'TreatmentText=? ';
  $sql .= 'WHERE TreatmentId=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($treatment_text, $treatment_id);

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

      my ($vcol_err, $vcol_msg) = update_factor_value($dbh_k_write, $vcol_id, $factor_value, 'treatmentfactor', 'TreatmentId', $treatment_id);

      if ($vcol_err) {

        $self->logger->debug("VCol_" . "$vcol_id => $vcol_msg" );

        push(@{$treatment_err_aref}, {'VCol_' . "$vcol_id" => $vcol_msg});

        $treatment_err = 1;
      }
    }
  }
  $dbh_k_write->disconnect();

  if ($treatment_err != 0) {
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => $treatment_err_aref};
    return $data_for_postrun_href;
  }

  my $info_msg_aref = [{'Message' => "Treatment ($treatment_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub add_trait_runmode {

=pod add_trait_HELP_START
{
"OperationName": "Add trait",
"Description": "Add a new trait definition to the system.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "trait",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='11' ParaName='TraitId' /><Info Message='Trait (11) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '12', 'ParaName' : 'TraitId'}], 'Info' : [{'Message' : 'Trait (12) has been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error TraitUnit='TraitUnit (Kg): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'TraitUnit' : 'TraitUnit (Kg): not found.'}]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'OwnGroupId' => 1};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'trait', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $trait_name             = $query->param('TraitName');
  my $trait_caption          = $query->param('TraitCaption');
  my $trait_description      = $query->param('TraitDescription');
  my $trait_data_type        = $query->param('TraitDataType');
  my $trait_val_maxlen       = $query->param('TraitValueMaxLength');
  my $trait_level            = $query->param('TraitLevel');
  my $trait_unit             = $query->param('UnitId');
  my $trait_used_in_analysis = $query->param('IsTraitUsedForAnalysis');
  my $trait_val_rule         = $query->param('TraitValRule');
  my $trait_invalid_msg      = $query->param('TraitValRuleErrMsg');
  my $access_group           = $query->param('AccessGroupId');
  my $own_perm               = $query->param('OwnGroupPerm');
  my $access_perm            = $query->param('AccessGroupPerm');
  my $other_perm             = $query->param('OtherPerm');

  my $alt_id                 = undef;

  if (defined $query->param('AltIdentifier')) {

    if (length($query->param('AltIdentifier')) > 0) {

      $alt_id = $query->param('AltIdentifier');
    }
  }

  my $trait_level_lookup = {'trialunit'     => 1,
                            'subtrialunit'  => 1,
                            'notetrialunit' => 1,
                           };

  my ($correct_validation_rule, $val_msg) = is_correct_validation_rule($trait_val_rule);

  if (!$correct_validation_rule) {

    my $err_msg = "$val_msg";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TraitValRule' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trait_group_type = '';

  if (defined $query->param('TraitGroupTypeId')) {

    if (length($query->param('TraitGroupTypeId')) > 0) {

      $trait_group_type = $query->param('TraitGroupTypeId');
    }
  }

  my $dbh_k_read = connect_kdb_read();

  if (length($alt_id) > 0) {

    if (record_existence($dbh_k_read, 'trait', 'AltIdentifier', $alt_id)) {

      my $err_msg = "AltIdentifier ($alt_id): already exists.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'AltIdentifier' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }
  else {

    $alt_id = undef;
  }

  if (length($trait_group_type) > 0) {

    if (!type_existence($dbh_k_read, 'traitgroup', $trait_group_type)) {

      my $err_msg = "TraitGroupType ($trait_group_type) does not exist.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'TraitGroupTypeId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }
  else {

    $trait_group_type = undef;
  }

  if (!type_existence($dbh_k_read, 'traitdatatype', $trait_data_type)) {

    my $err_msg = "TraitDataType ($trait_data_type): not found";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TraitDataType' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trait_existence = record_existence($dbh_k_read, 'trait', 'TraitName', $trait_name);

  if ($trait_existence) {

    my $err_msg = "Trait ($trait_name): already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TraitName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (!record_existence($dbh_k_read, 'generalunit', 'UnitId', $trait_unit)) {

    my $err_msg = "TraitUnit ($trait_unit): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TraitUnit' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( ! (defined $trait_level_lookup->{$trait_level}) ) {

    my $valid_trait_level_csv = join(',', keys(%{$trait_level_lookup}));
    my $err_msg = "TraitLevel ($trait_level): invalid - must be one of ($valid_trait_level_csv).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TraitLevel' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $access_grp_existence = record_existence($dbh_k_read, 'systemgroup', 'SystemGroupId', $access_group);

  if (!$access_grp_existence) {

    my $err_msg = "AccessGroup ($access_group) does not exist.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'AccessGroupId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( ($own_perm > 7 || $own_perm < 0) ) {

    my $err_msg = "OwnGroupPerm ($own_perm) is invalid.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'OwnGroupPerm' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( ($access_perm > 7 || $access_perm < 0) ) {

    my $err_msg = "AccesGroupPerm ($access_perm) is invalid.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'AccessGroupPerm' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( ($other_perm > 7 || $other_perm < 0) ) {

    my $err_msg = "OtherPerm ($other_perm) is invalid.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'OtherPerm' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $group_id = $self->authen->group_id();

  my $sql = '';

  $sql    = 'INSERT INTO trait SET ';
  $sql   .= 'TraitGroupTypeId=?, ';
  $sql   .= 'TraitName=?, ';
  $sql   .= 'TraitCaption=?, ';
  $sql   .= 'TraitDescription=?, ';
  $sql   .= 'TraitDataType=?, ';
  $sql   .= 'TraitValueMaxLength=?, ';
  $sql   .= 'TraitLevel=?, ';
  $sql   .= 'UnitId=?, ';
  $sql   .= 'IsTraitUsedForAnalysis=?, ';
  $sql   .= 'TraitValRule=?, ';
  $sql   .= 'TraitValRuleErrMsg=?, ';
  $sql   .= 'OwnGroupId=?, ';
  $sql   .= 'AccessGroupId=?, ';
  $sql   .= 'OwnGroupPerm=?, ';
  $sql   .= 'AccessGroupPerm=?, ';
  $sql   .= 'OtherPerm=?, ';
  $sql   .= 'AltIdentifier=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($trait_group_type, $trait_name, $trait_caption, $trait_description, $trait_data_type,
                $trait_val_maxlen, $trait_level, $trait_unit, $trait_used_in_analysis, $trait_val_rule,
                $trait_invalid_msg, $group_id, $access_group, $own_perm, $access_perm, $other_perm,
                $alt_id);

  my $trait_id = -1;
  if (!$dbh_k_write->err()) {

    $trait_id = $dbh_k_write->last_insert_id(undef, undef, 'trait', 'TraitId');
    $self->logger->debug("TraitId: $trait_id");
  }
  else {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref  = [{'Message' => "Trait ($trait_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$trait_id", 'ParaName' => 'TraitId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref,
                                           'ReturnId'  => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub import_samplemeasurement_csv_runmode {

=pod import_samplemeasurement_csv_HELP_START
{
"OperationName": "Import sample measurements",
"Description": "Import sample measurements from a csv file formatted as a sparse matrix of phenotypic data.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='2 records of samplemeasurement have been inserted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : '2 records of samplemeasurement have been inserted successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Row (1): TrialUnit (1) does not exist.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Row (1): TrialUnit (1) does not exist.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "CSV",
"UploadFileParameterName": "uploadfile",
"HTTPParameter": [{"Required": 1, "Name": "TrialUnitId", "Description": "Column number counting from zero for TrialUnitId column in the upload CSV file"}, {"Required": 1, "Name": "SampleTypeId", "Description": "Column number counting from zero for SampleTypeId column in the upload CSV file"}, {"Required": 1, "Name": "TraitId", "Description": "Column number counting from zero for TraitId column in the upload CSV file"}, {"Required": 1, "Name": "OperatorId", "Description": "Column number counting from zero for OperatorId column for the upload CSV file"}, {"Required": 1, "Name": "MeasureDateTime", "Description": "Column number counting from zero for MeasureDateTime column in the upload CSV file"}, {"Required": 1, "Name": "InstanceNumber", "Description": "Column number counting from zero for InstanceNumber column in the upload CSV file"}, {"Required": 1, "Name": "TraitValue", "Description": "Column number counting from zero for TraitValue column in the upload CSV file"}, {"Required": 1, "Name": "SurveyId", "Description": "Column number counting from zero for SurveyId column in the upload CSV file"},{"Required": 0, "Name": "TrialUnitSpecimenId", "Description": "Column number counting from zero for TrialUnitSpecimenId column in the upload CSV file for sub-plot scoring"}, {"Required": 0, "Name": "StateReason", "Description": "Column number counting from zero for StateReason column in the upload CSV file for sub-plot scoring"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $data_csv_file = $self->authen->get_upload_file();

  my $num_of_col = get_csvfile_num_of_col($data_csv_file);

  $self->logger->debug("Number of columns: $num_of_col");

  my $TrialUnitId_col     = $query->param('TrialUnitId');
  my $SampleTypeId_col    = $query->param('SampleTypeId');
  my $TraitId_col         = $query->param('TraitId');
  my $OperatorId_col      = $query->param('OperatorId');
  my $MeasureDateTime_col = $query->param('MeasureDateTime');
  my $InstanceNumber_col  = $query->param('InstanceNumber');
  my $TraitValue_col      = $query->param('TraitValue');

  my $chk_col_href = { 'TrialUnitId'     => $TrialUnitId_col,
                       'SampleTypeId'    => $SampleTypeId_col,
                       'TraitId'         => $TraitId_col,
                       'MeasureDateTime' => $MeasureDateTime_col,
                       'InstanceNumber'  => $InstanceNumber_col,
                       'TraitValue'      => $TraitValue_col,
                     };

  my $matched_col = {};

  $matched_col->{$TrialUnitId_col}     = 'TrialUnitId';
  $matched_col->{$SampleTypeId_col}    = 'SampleTypeId';
  $matched_col->{$TraitId_col}         = 'TraitId';
  $matched_col->{$MeasureDateTime_col} = 'MeasureDateTime';
  $matched_col->{$InstanceNumber_col}  = 'InstanceNumber';
  $matched_col->{$TraitValue_col}      = 'TraitValue';

  my $TrialUnitSpecimenId_col = undef;

  if (defined $query->param('TrialUnitSpecimenId')) {

    if (length($query->param('TrialUnitSpecimenId')) > 0) {

      $TrialUnitSpecimenId_col = $query->param('TrialUnitSpecimenId');
      $chk_col_href->{'TrialUnitSpecimenId'} = $TrialUnitSpecimenId_col;

      $matched_col->{$TrialUnitSpecimenId_col} = 'TrialUnitSpecimenId';
    }
  }

  my $StateReason_col = undef;

  if (defined $query->param('StateReason')) {

    if (length($query->param('StateReason')) > 0) {

      $StateReason_col = $query->param('StateReason');
      $chk_col_href->{'StateReason'} = $StateReason_col;

      $matched_col->{$StateReason_col} = 'StateReason';
    }
  }

  my  $SurveyId_col        = undef;

  if (defined $query->param('SurveyId')) {

    if (length($query->param('SurveyId')) > 0) {

      $SurveyId_col = $query->param('SurveyId');
      $chk_col_href->{'SurveyId'} = $SurveyId_col;

      $matched_col->{$SurveyId_col} = 'SurveyId';
    }
  }

  my ($col_def_err, $col_def_err_href) = check_col_def_href( $chk_col_href, $num_of_col);

  if ($col_def_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$col_def_err_href]};

    return $data_for_postrun_href;
  }

  if (length($OperatorId_col) > 0) {

    my ($col_def_err, $col_def_err_href) = check_col_def_href( { 'OperatorId' => $OperatorId_col },
                                                               $num_of_col
        );

    if ($col_def_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [$col_def_err_href]};

      return $data_for_postrun_href;
    }

    $matched_col->{$OperatorId_col} = 'OperatorId';
  }

  my @fieldname_list;

  for (my $i = 0; $i < $num_of_col; $i++) {

    if ($matched_col->{$i}) {

      push(@fieldname_list, $matched_col->{$i});
    }
    else {

      push(@fieldname_list, 'null');
    }
  }

  my ($data_aref, $csv_err, $err_msg) = csvfile2arrayref($data_csv_file, \@fieldname_list, 0);

  if ($csv_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_write = connect_kdb_write();

  my $check_non_trait_field = 1;
  my $validate_trait_value  = 1;
  $data_for_postrun_href = $self->insert_samplemeasurement_data_v2($dbh_write,
                                                                $data_aref,
                                                                $check_non_trait_field,
                                                                $validate_trait_value
      );

  $dbh_write->disconnect();

  return $data_for_postrun_href;
}


sub list_samplemeasurement {

  my $self            = $_[0];
  my $sql             = $_[1];
  my $where_para_aref = $_[2];
  my $field_list      = $_[3];

  my $err = 0;
  my $msg = '';

  my $data_aref = [];

  my $sql_update       = $sql;

  my $sql_select_field = ['samplemeasurement.TrialUnitId',
                          'samplemeasurement.TraitId',
                          'samplemeasurement.OperatorId',
                          'samplemeasurement.MeasureDateTime',
                          'samplemeasurement.InstanceNumber',
                          'samplemeasurement.SampleTypeId',
                          'samplemeasurement.TraitValue',
                          'samplemeasurement.TrialUnitSpecimenId' ];

      $sql_select_field       =  join(',', @{$sql_select_field});

      $sql_update  =~ s/SELECT samplemeasurement.\*/ $sql_select_field /;


  if ($field_list =~ /TrialUnitSpecimenId/) {

    $sql_update  =~ s/samplemeasurement.TraitValue,//g;

    $sql = 'SELECT' . $sql_update;

    $self->logger->debug("SQL when TrialUnitSpecimenID is selected: $sql");
  }

  if ($field_list =~ /TraitValue/) {

    $sql_update  =~ s/,samplemeasurement.TrialUnitSpecimenId//g;

    $sql = 'SELECT' . $sql_update;

    $self->logger->debug("SQL when TraitValue is selected: $sql");
  }

  my $dbh = connect_kdb_read();

  ($err, $msg, $data_aref) = read_data($dbh, $sql, $where_para_aref);

  if ($err) {

    return ($err, $msg, []);
  }

  $dbh->disconnect();

  return ($err, $msg, $data_aref);
}


sub list_samplemeasurement_advanced_runmode {

=pod list_samplemeasurement_advanced_HELP_START
{
"OperationName": "List sample measurements",
"Description": "List sample measurements. This listing requires pagination definition.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination Page='1' NumOfRecords='27823' NumOfPages='557' NumPerPage='50' /><StatInfo ServerElapsedTime='0.444' Unit='second' /><RecordMeta TagName='samplemeasurement' /><samplemeasurement OperatorId='0' TraitValue='40' InstanceNumber='6' TrialUnitId='17572' MeasureDateTime='2011-01-15 14:28:37' TrialUnitSpecimenId='17692' SampleTypeId='328' TraitId='70' /></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfPages' : 16,'Page' : '1','NumPerPage' : '3','NumOfRecords' : '47'}],'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.006'}],'RecordMeta' : [{'TagName' : 'samplemeasurement'}],'samplemeasurement' : [{'SampleTypeId' : '161','InstanceNumber' : '5','TraitValue' : '11','TrialUnitId' : '23','TrialUnitSpecimenId' : '0','SMGroupId' : '15','StateReason' : 'TEST','TraitId' : '23','OperatorId' : '0','MeasureDateTime' : '2011-01-15 14:28:37'},{'TrialUnitId' : '23','TraitValue' : '40','InstanceNumber' : '6','SampleTypeId' : '161','OperatorId' : '0','MeasureDateTime' : '2011-01-15 14:28:37','StateReason' : 'TEST','TraitId' : '23','TrialUnitSpecimenId' : '92','SMGroupId' : '15'},{'StateReason' : 'TEST','TraitId' : '23','MeasureDateTime' : '2011-01-15 14:28:37','OperatorId' : '0','SMGroupId' : '15','TrialUnitSpecimenId' : '91','TraitValue' : '16','InstanceNumber' : '6','TrialUnitId' : '23','SampleTypeId' : '161'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"URLParameter": [{"ParameterName": "nperpage", "Description": "Number of records in a page for pagination"}, {"ParameterName": "num", "Description": "The page number of the pagination"}],
"HTTPParameter": [{"Required": 0, "Name": "Filtering", "Description": "Filtering parameter string consisting of filtering expressions which are separated by ampersand (&) which needs to be encoded if HTTP GET method is used. Each filtering expression is composed of a database field name, a filtering operator and the filtering value."}, {"Required": 0, "Name": "FieldList", "Description": "Comma separated value of wanted fields."}, {"Required": 0, "Name": "Sorting", "Description": "Comma separated value of SQL sorting phrases."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;

  my $query = $self->query();

  my $data_for_postrun_href   = {};

  my $pagination  = 0;
  my $nb_per_page = -1;
  my $page        = -1;

  if ( (defined $self->param('nperpage')) && (defined $self->param('num'))) {

    $pagination  = 1;
    $nb_per_page = $self->param('nperpage');
    $page        = $self->param('num');
  }

  my $group_id = $self->authen->group_id();

  my $gadmin_status = $self->authen->gadmin_status();

  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'trait');

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

    $sorting  = $query->param('Sorting');
  }

  if (defined $self->param('sampletypeid')) {

    my $sampletype_id  = $self->param('sampletype_id');

    if ($filtering_csv = ~ /SampleTypeId=(.*),?/) {

      if ("$sampletype_id" ne "$1" ) {

        my $err_msg  = 'Duplicate filtering condition for SampleTypeId. ';
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
    else {

      if (length($filtering_csv) > 0) {

        if ($filtering_csv =~ /&$/) {

          $filtering_csv   .=  "SampleTypeId=$sampletype_id";
        }
        else {

          $filtering_csv    .=  "&SampleyTypeId=$sampletype_id";
        }
      }
      else {

        $filtering_csv       .=  "SampleTypeId=$sampletype_id";
      }
    }
  }

  my $field_list = $field_list_csv;

  my $sql = 'SELECT samplemeasurement.* FROM samplemeasurement ';
  $sql   .= 'ORDER BY samplemeasurement.TrialUnitId DESC ';
  $sql   .= 'LIMIT 1 ';

  my ($read_sm_err, $read_sm_msg, $sm_data) = $self->list_samplemeasurement($sql, 0, $field_list);

  if ($read_sm_err) {

    $self->logger->debug($read_sm_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $dbh =  connect_kdb_read();

  my $sam_data_aref = $sm_data;

  my @field_list_all;

  if (scalar(@{$sam_data_aref}) == 1) {

    @field_list_all = keys(%{$sam_data_aref->[0]});
  }
  else {

    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'samplemeasurement');

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
                                                                                \@field_list_all,
                                                                                'SampleTypeId');

    if ($sel_field_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;

    if ($filtering_csv =~ /SampleTypeId/) {

      push(@{$final_field_list}, 'SampleTypeId');
    }
  }

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering_v2('SampleTypeId',
                                                                                 'samplemeasurement',
                                                                                 $filtering_csv,
                                                                                 $final_field_list);


  $self->logger->debug("Filter phrase: $filter_phrase");

  if ($filter_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $filter_msg}]};

    return $data_for_postrun_href;
  }

  my $filter_where_phrase = '';
  if (length($filter_phrase) > 0) {

    $filter_where_phrase = " AND $filter_phrase ";
  }

  my $filtering_exp  = " WHERE (($perm_str) & $READ_PERM) = $READ_PERM $filter_where_phrase ";

  my $pagination_aref = [];
  my $paged_limit_clause = '';

  if ($pagination) {

    my ($int_err, $int_err_msg)  = check_integer_value ({'nperpage' => $nb_per_page,
                                                         'num'      => $page
                                                        });

    if ($int_err) {

      $int_err_msg .= ' not integer';
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error'  =>  [{'Message' => $int_err_msg}]};
      return $data_for_postrun_href;
    }

    my $count_sql =  "SELECT COUNT(*) ";
    $count_sql   .=  "FROM samplemeasurement ";
    $count_sql   .=  "LEFT JOIN trait ON samplemeasurement.TraitId = trait.TraitId ";
    $count_sql   .=  "$filtering_exp";

    $self->logger->debug("COUNT SQL: $count_sql");

    my ($paged_id_err, $paged_id_msg, $nb_records,
        $nb_pages, $limit_clause, $sql_count_time) = get_paged_filter_sql($dbh,
                                                                          $nb_per_page,
                                                                          $page,
                                                                          $count_sql,
                                                                          $where_arg);


    $self->logger->debug("SQL Count time: $sql_count_time");

    if ($paged_id_err == 1) {

      $self->logger->debug($paged_id_msg);

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    if ($paged_id_err == 2) {

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

  my $sql_field_lookup = {
    'SampleTypeId' => 1,
    'OperatorId'  => 1,

  };

  my $other_join = '';
  my $extra_fields = '';

  if ($sql_field_lookup->{'SampleTypeId'}) {

    $other_join .=  ' LEFT JOIN generaltype ON samplemeasurement.SampleTypeId = generaltype.TypeId ';
    $extra_fields .= ', generaltype.TypeName ';
  }

  if ($sql_field_lookup->{'OperatorId'}) {
    $extra_fields .= ", concat(contact.ContactFirstName,' ',contact.ContactLastName) As Contact, contact.ContactId";

    $other_join .=  ' LEFT JOIN systemuser ON samplemeasurement.OperatorId = systemuser.UserId  LEFT JOIN contact on systemuser.ContactId = contact.ContactId ';
  }


  $sql    =  "SELECT samplemeasurement.*, trait.TraitName $extra_fields FROM samplemeasurement ";
  $sql   .=  "LEFT JOIN trait ON trait.TraitId = samplemeasurement.TraitId ";
  $sql   .=  "$other_join ";
  $sql   .=  "$filtering_exp ";

  $self->logger->debug($sql);

  my ($sort_err, $sort_msg, $sort_sql) = parse_sorting($sorting, $final_field_list);

  if ($sort_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sort_msg}]};

    return $data_for_postrun_href;
  }

  if (length($sort_sql) > 0) {

    $sql    .= " ORDER BY $sort_sql";
  }
  else {

    $sql    .= 'ORDER BY samplemeasurement.TrialUnitId DESC';
  }

  $sql   .=  " $paged_limit_clause ";

  my ($read_sam_err, $read_sam_msg, $sam_data)   =  $self->list_samplemeasurement($sql, $where_arg, $field_list);

  if ($read_sam_err) {

    $self->logger->debug($read_sam_msg);
    $data_for_postrun_href->{'Error'}  =  1;
    $data_for_postrun_href->{'Data'}   =  {'Error' =>  [{'Message' => 'Unexpected error. '}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}   = 0;
  $data_for_postrun_href->{'Data'}    = {'samplemeasurement'       =>   $sam_data,
                                         'Pagination'              =>   $pagination_aref,
                                         'RecordMeta'              =>   [{'TagName' => 'samplemeasurement'}],
                                        };

  return $data_for_postrun_href;
}

sub list_treatment {

  my $self           = $_[0];
  my $extra_attr_yes = $_[1];
  my $sql            = $_[2];

  my $where_para_aref = [];

  if (defined $_[3]) {

    $where_para_aref = $_[3];
  }

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
  my $sth = $dbh->prepare($sql);

  $sth->execute(@{$where_para_aref});

  my $err = 0;
  my $msg = '';
  my $treatment_data = [];

  if ( !$dbh->err() ) {

    my $array_ref = $sth->fetchall_arrayref({});

    if ( !$sth->err() ) {

      $treatment_data = $array_ref;
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

  my $extra_attr_treatment_data = [];

  if ($extra_attr_yes) {

    my $treatment_id_aref = [];

    for my $row (@{$treatment_data}) {

      push(@{$treatment_id_aref}, $row->{'TreatmentId'});
    }

    my $chk_id_err        = 0;
    my $chk_id_msg        = '';
    my $used_id_href      = {};
    my $not_used_id_href  = {};

    if (scalar(@{$treatment_id_aref}) > 0) {

      my $chk_table_aref = [{'TableName' => 'trialunittreatment', 'FieldName' => 'TreatmentId'}];

      ($chk_id_err, $chk_id_msg,
       $used_id_href, $not_used_id_href) = id_existence_bulk($dbh, $chk_table_aref, $treatment_id_aref);

      if ($chk_id_err) {

        $self->logger->debug("Check id existence error: $chk_id_msg");
        $err = 1;
        $msg = $chk_id_msg;

        return ($err, $msg, []);
      }
    }

    my $gadmin_status = $self->authen->gadmin_status();

    for my $row (@{$treatment_data}) {

      if ($gadmin_status eq '1') {

        my $treatment_id = $row->{'TreatmentId'};
        $row->{'update'} = "update/treatment/$treatment_id";

        if ( $not_used_id_href->{$treatment_id} ) {

          $row->{'delete'}   = "delete/treatment/$treatment_id";
        }
      }
      push(@{$extra_attr_treatment_data}, $row);
    }
  }
  else {

    $extra_attr_treatment_data = $treatment_data;
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_treatment_data);
}

sub get_treatment_runmode {

=pod get_treatment_HELP_START
{
"OperationName": "Get treatment",
"Description": "Get detailed definition of the treatment specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='Treatment' /><Treatment TreatmentText='Testing' TreatmentId='15' delete='delete/treatment/15' update='update/treatment/15' /></DATA>",
"SuccessMessageJSON": "{ 'VCol' : [], 'RecordMeta' : [{ 'TagName' : 'Treatment'} ], 'Treatment' : [{ 'TreatmentText' : 'Testing', 'delete' : 'delete/treatment/15', 'TreatmentId' : '15', 'update' : 'update/treatment/15'} ]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Treatment (25) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Treatment (25) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TreatmentId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self         = shift;
  my $treatment_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $group_id = $self->authen->group_id();

  my $dbh = connect_kdb_read();

  my $treatment_exist = record_existence($dbh, 'treatment', 'TreatmentId', $treatment_id);

  if (!$treatment_exist) {

    my $err_msg = "Treatment ($treatment_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $field_list = ['*'];

  my $other_join = '';

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $field_list, 'treatment',
                                                                        'TreatmentId', $other_join);
  $dbh->disconnect();

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql   .= ' HAVING treatment.TreatmentId=?';
  $sql   .= ' ORDER BY treatment.TreatmentId DESC';

  $self->logger->debug("SQL with VCol: $sql");

  my ($read_treatment_err, $read_treatment_msg, $treatment_data) = $self->list_treatment(1,
                                                                                         $sql,
                                                                                         [$treatment_id]
      );

  if ($read_treatment_err) {

    $self->logger->debug($read_treatment_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Treatment'  => $treatment_data,
                                           'VCol'       => $vcol_list,
                                           'SQL'        => $sql,
                                           'RecordMeta' => [{'TagName' => 'Treatment'}],
  };

  return $data_for_postrun_href;
}

sub list_trait {

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

  my $extra_attr_trait_data = [];

  if ($extra_attr_yes) {

    my $group_sql    = 'SELECT SystemGroupId, SystemGroupName FROM systemgroup';
    my $group_lookup = $dbh->selectall_hashref($group_sql, 'SystemGroupId');

    my $perm_lookup  = {'0' => 'None',
                        '1' => 'Link',
                        '2' => 'Write',
                        '3' => 'Write/Link',
                        '4' => 'Read',
                        '5' => 'Read/Link',
                        '6' => 'Read/Write',
                        '7' => 'Read/Write/Link',
    };

    my $gadmin_status = $self->authen->gadmin_status();
    my $group_id      = $self->authen->group_id();

    my $trait_id_aref = [];

    for my $row (@{$data_aref}) {

      push(@{$trait_id_aref}, $row->{'TraitId'});
    }

    my $trait_alias_lookup = {};

    my $chk_id_err        = 0;
    my $chk_id_msg        = '';
    my $used_id_href      = {};
    my $not_used_id_href  = {};

    if (scalar(@{$trait_id_aref}) > 0) {

      my $trait_alias_sql  = 'SELECT TraitId, TraitAliasId, TraitAliasName ';
      $trait_alias_sql    .= 'FROM traitalias ';
      $trait_alias_sql    .= 'WHERE TraitId IN (' . join(',', @{$trait_id_aref}) . ')';

      my ($talias_err, $talias_msg, $trait_alias_data) = read_data($dbh, $trait_alias_sql, []);

      if ($talias_err) {

        return ($talias_err, $talias_msg, []);
      }

      for my $trait_alias_row (@{$trait_alias_data}) {

        my $trait_id = $trait_alias_row->{'TraitId'};

        if (defined $trait_alias_lookup->{$trait_id}) {

          my $trait_alias_aref = $trait_alias_lookup->{$trait_id};
          delete($trait_alias_row->{'TraitId'});
          push(@{$trait_alias_aref}, $trait_alias_row);
          $trait_alias_lookup->{$trait_id} = $trait_alias_aref;
        }
        else {

          delete($trait_alias_row->{'TraitId'});
          $trait_alias_lookup->{$trait_id} = [$trait_alias_row];
        }
      }

      my $chk_table_aref = [{'TableName' => 'samplemeasurement', 'FieldName' => 'TraitId'},
                            {'TableName' => 'trialtrait', 'FieldName' => 'Traitid'},
                            {'TableName' => 'genotypetrait', 'FieldName' => 'TraitId'}
          ];

      ($chk_id_err, $chk_id_msg,
       $used_id_href, $not_used_id_href) = id_existence_bulk($dbh, $chk_table_aref, $trait_id_aref);

      if ($chk_id_err) {

        $self->logger->debug("Check id existence error: $chk_id_msg");
        $err = 1;
        $msg = $chk_id_msg;

        return ($err, $msg, []);
      }
    }

    for my $row (@{$data_aref}) {

      my $trait_id      = $row->{'TraitId'};

      if (defined $trait_alias_lookup->{$trait_id}) {

        $row->{'Alias'} = $trait_alias_lookup->{$trait_id};
      }

      my $own_grp_id   = $row->{'OwnGroupId'};
      my $acc_grp_id   = $row->{'AccessGroupId'};
      my $own_perm     = $row->{'OwnGroupPerm'};
      my $acc_perm     = $row->{'AccessGroupPerm'};
      my $oth_perm     = $row->{'OtherPerm'};
      my $ulti_perm    = $row->{'UltimatePerm'};

      $row->{'OwnGroupName'}          = $group_lookup->{$own_grp_id}->{'SystemGroupName'};
      $row->{'AccessGroupName'}       = $group_lookup->{$acc_grp_id}->{'SystemGroupName'};
      $row->{'OwnGroupPermission'}    = $perm_lookup->{$own_perm};
      $row->{'AccessGroupPermission'} = $perm_lookup->{$acc_perm};
      $row->{'OtherPermission'}       = $perm_lookup->{$oth_perm};
      $row->{'UltimatePermission'}    = $perm_lookup->{$ulti_perm};

      if (($ulti_perm & $WRITE_PERM) == $WRITE_PERM) {

        $row->{'update'}   = "update/trait/$trait_id";
      }

      if (($ulti_perm & $READ_WRITE_PERM) == $READ_WRITE_PERM) {

        $row->{'addAlias'} = "trait/${trait_id}/add/alias";
      }

      if ($own_grp_id == $group_id) {

        $row->{'chgPerm'} = "trait/$trait_id/change/permission";

        if ($gadmin_status eq '1') {

          $row->{'chgOwner'} = "trait/$trait_id/change/owner";

          if ( $not_used_id_href->{$trait_id} ) {

            $row->{'delete'}   = "delete/trait/$trait_id";
          }
        }
      }

      push(@{$extra_attr_trait_data}, $row);
    }
  }
  else {

    $extra_attr_trait_data = $data_aref;
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_trait_data);
}

sub get_trait_runmode {

=pod get_trait_HELP_START
{
"OperationName": "Get trait",
"Description": "Get detailed information about the trait definition for a specified id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Trait AccessGroupId='0' TraitUnitName='U_5144527' addAlias='trait/1/add/alias' chgPerm='trait/1/change/permission' TraitUnit='2' OwnGroupPermission='Read/Write/Link' TraitValRule='boolex(x &gt; 0 and x &lt; 500)' IsTraitUsedForAnalysis='0' AccessGroupName='admin' TraitValueMaxLength='20' TraitGroupTypeId='' OwnGroupId='0' TraitCaption='Automatic testing trait' UltimatePerm='7' AccessGroupPerm='5' TraitDescription='Trait used for automatic testing' UnitTypeId='15' AccessGroupPermission='Read/Link' OtherPermission='None' OwnGroupPerm='7' OtherPerm='0' ItemUnitNote='' GramsConversionMultiplier='1' TraitName='Trait_4102474' TraitId='1' ItemUnitId='2' TraitDataType='INTEGER' OwnGroupName='admin' ConversionRule='' ItemUnitName='U_5144527' chgOwner='trait/1/change/owner' TraitValRuleErrMsg='invalid value' UltimatePermission='Read/Write/Link' update='update/trait/1'><Alias TraitAliasId='1' TraitAliasName='Trait Alias Name - ' /></Trait><RecordMeta TagName='Trait' /></DATA>",
"SuccessMessageJSON": "{'Trait' : [{'AccessGroupId' : '0', 'TraitUnitName' : 'U_5144527', 'addAlias' : 'trait/1/add/alias', 'chgPerm' : 'trait/1/change/permission', 'TraitUnit' : '2', 'OwnGroupPermission' : 'Read/Write/Link', 'TraitValRule' : 'boolex(x > 0 and x < 500)', 'IsTraitUsedForAnalysis' : '0', 'AccessGroupName' : 'admin', 'TraitValueMaxLength' : '20', 'TraitGroupTypeId' : null, 'OwnGroupId' : '0', 'TraitCaption' : 'Automatic testing trait', 'UltimatePerm' : '7', 'AccessGroupPerm' : '5', 'TraitDescription' : 'Trait used for automatic testing', 'UnitTypeId' : '15', 'AccessGroupPermission' : 'Read/Link', 'OtherPermission' : 'None', 'OwnGroupPerm' : '7', 'OtherPerm' : '0', 'ItemUnitNote' : '', 'GramsConversionMultiplier' : '1', 'TraitName' : 'Trait_4102474', 'TraitId' : '1', 'ItemUnitId' : '2', 'TraitDataType' : 'INTEGER', 'OwnGroupName' : 'admin', 'ConversionRule' : null, 'ItemUnitName' : 'U_5144527', 'Alias' : [{'TraitAliasId' : '1', 'TraitAliasName' : 'Trait Alias Name - '}], 'chgOwner' : 'trait/1/change/owner', 'TraitValRuleErrMsg' : 'invalid value', 'UltimatePermission' : 'Read/Write/Link', 'update' : 'update/trait/1'}], 'RecordMeta' : [{'TagName' : 'Trait'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Trait (20) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Trait (20) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TraitId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self     = shift;
  my $trait_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status);

  my $trait_perm_sql = "SELECT $perm_str as UltimatePerm ";
  $trait_perm_sql   .= 'FROM trait ';
  $trait_perm_sql   .= 'WHERE TraitId=?';

  my ($read_err, $trait_perm) = read_cell($dbh, $trait_perm_sql, [$trait_id]);

  if (length($trait_perm) == 0) {

    my $err_msg = "Trait ($trait_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }
  elsif ( ($trait_perm & $READ_PERM) != $READ_PERM ) {

    my $err_msg = "Permission denied: trait ($trait_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = "SELECT trait.*, generalunit.UnitName AS UnitName, tgrptype.TypeName AS TraitGroupTypeName, ";
  $sql   .= "tdatatype.TypeName AS TraitDataTypeName, $perm_str AS UltimatePerm ";
  $sql   .= 'FROM trait ';
  $sql   .= 'LEFT JOIN generalunit ON trait.UnitId = generalunit.UnitId ';
  $sql   .= 'LEFT JOIN generaltype AS tgrptype ON trait.TraitGroupTypeId = tgrptype.TypeId ';
  $sql   .= 'LEFT JOIN generaltype AS tdatatype ON trait.TraitDataType = tdatatype.TypeId ';
  $sql   .= "WHERE trait.TraitId=? AND (($perm_str) & $READ_PERM) = $READ_PERM ";
  $sql   .= 'ORDER BY trait.TraitId DESC';

  $self->logger->debug("SQL with VCol: $sql");

  my ($read_trait_err, $read_trait_msg, $trait_data) = $self->list_trait(1, $sql, [$trait_id]);

  if ($read_trait_err) {

    $self->logger->debug($read_trait_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Trait'      => $trait_data,
                                           'RecordMeta' => [{'TagName' => 'Trait'}],
  };

  return $data_for_postrun_href;
}

sub update_trait_runmode {

=pod update_trait_HELP_START
{
"OperationName": "Update trait",
"Description": "Update trait definition for a specified trait id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "trait",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Trait (14) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Trait (14) has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Trait (20) not found.' /></DATA>" }],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Trait (20) not found.'}]}" }],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TraitId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self     = shift;
  my $trait_id = $self->param('id');
  my $query    = $self->query();

  my $data_for_postrun_href = {};

  my $dbh_k_read = connect_kdb_read();

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = { 'OwnGroupId'      => 1,
                     'AccessGroupId'   => 1,
                     'OwnGroupPerm'    => 1,
                     'AccessGroupPerm' => 1,
                     'OtherPerm'       => 1,
  };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'trait', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status);

  my $trait_perm_sql = "SELECT $perm_str as UltimatePerm ";
  $trait_perm_sql   .= 'FROM trait ';
  $trait_perm_sql   .= 'WHERE TraitId=?';

  my ($read_err, $trait_perm) = read_cell($dbh_k_read, $trait_perm_sql, [$trait_id]);

  if (length($trait_perm) == 0) {

    my $err_msg = "Trait ($trait_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }
  elsif ( ($trait_perm & $READ_WRITE_PERM) != $READ_WRITE_PERM ) {

    my $err_msg = "Permission denied: trait ($trait_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trait_name             = $query->param('TraitName');
  my $trait_caption          = $query->param('TraitCaption');
  my $trait_description      = $query->param('TraitDescription');
  my $trait_data_type        = $query->param('TraitDataType');
  my $trait_val_maxlen       = $query->param('TraitValueMaxLength');
  my $trait_unit             = $query->param('UnitId');
  my $trait_used_in_analysis = $query->param('IsTraitUsedForAnalysis');
  my $trait_val_rule         = $query->param('TraitValRule');
  my $trait_invalid_msg      = $query->param('TraitValRuleErrMsg');
  my $trait_level            = $query->param('TraitLevel');

  my $trait_level_lookup = {'trialunit'     => 1,
                            'subtrialunit'  => 1,
                            'notetrialunit' => 1,
                           };

  if ( ! (defined $trait_level_lookup->{$trait_level}) ) {

    my $valid_trait_level_csv = join(',', keys(%{$trait_level_lookup}));
    my $err_msg = "TraitLevel ($trait_level): invalid - must be one of ($valid_trait_level_csv).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TraitLevel' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($correct_validation_rule, $val_msg) = is_correct_validation_rule($trait_val_rule);

  if (!$correct_validation_rule) {

    my $err_msg = " $val_msg";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TraitValRule' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (!type_existence($dbh_k_read, 'traitdatatype', $trait_data_type)) {

    my $err_msg = "TraitDataType ($trait_data_type): not found";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TraitDataType' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $read_tr_sql    = 'SELECT TraitName, TraitGroupTypeId, AltIdentifier ';
  $read_tr_sql      .= 'FROM trait WHERE TraitId=? ';

  my ($r_df_val_err, $r_df_val_msg, $trait_df_val_data) = read_data($dbh_k_read, $read_tr_sql, [$trait_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve trait default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $db_trait_name        = undef;
  my $trait_group_type_id  = undef;
  my $alt_id               = undef;

  my $nb_df_val_rec    =  scalar(@{$trait_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve trait default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $db_trait_name            = $trait_df_val_data->[0]->{'TraitName'};
  $trait_group_type_id      = $trait_df_val_data->[0]->{'TraitGroupTypeId'};
  $alt_id                   = $trait_df_val_data->[0]->{'AltIdentifier'};

  if ($trait_name ne $db_trait_name) {

    # Because the new name is different from the old one and the name is unique,
    # this record_existence works. It won't return false error because of checking the old name.

    my $trait_existence = record_existence($dbh_k_read, 'trait', 'TraitName', $trait_name);

    if ($trait_existence) {

      my $err_msg = "Trait ($trait_name): already exists.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'TraitName' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (!record_existence($dbh_k_read, 'generalunit', 'UnitId', $trait_unit)) {

    my $err_msg = "TraitUnit ($trait_unit): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TraitUnit' => $err_msg}]};

    return $data_for_postrun_href;
  }


  if (defined $query->param('TraitGroupTypeId')) {

    if (length($query->param('TraitGroupTypeId')) > 0) {

      $trait_group_type_id = $query->param('TraitGroupTypeId');

      if (!type_existence($dbh_k_read, 'traitgroup', $trait_group_type_id)) {

        my $err_msg = "TraitGroupType ($trait_group_type_id) does not exist.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'TraitGroupTypeId' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
  }

  if (length($trait_group_type_id) == 0) {

    $trait_group_type_id = undef;
  }

  if (defined $query->param('AltIdentifier')) {

    if (length($query->param('AltIdentifier')) > 0) {

      $alt_id = $query->param('AltIdentifier');
    }
    else {

      $alt_id = undef;
    }
  }

  my $sql = '';

  if (length($alt_id) > 0) {

    $sql = 'SELECT TraitId FROM trait WHERE AltIdentifier=? AND TraitId<>?';

    my ($chk_alt_id_err, $db_trait_id) = read_cell($dbh_k_read, $sql, [$alt_id, $trait_id]);

    if (length($db_trait_id) > 0) {

      my $err_msg = "AltIdentifier ($alt_id): already exists.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'AltIdentifier' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  $sql    = 'UPDATE trait SET ';
  $sql   .= 'TraitName=?, ';
  $sql   .= 'TraitGroupTypeId=?, ';
  $sql   .= 'TraitCaption=?, ';
  $sql   .= 'TraitDescription=?, ';
  $sql   .= 'TraitDataType=?, ';
  $sql   .= 'TraitValueMaxLength=?, ';
  $sql   .= 'UnitId=?, ';
  $sql   .= 'IsTraitUsedForAnalysis=?, ';
  $sql   .= 'TraitValRule=?, ';
  $sql   .= 'TraitValRuleErrMsg=?, ';
  $sql   .= 'TraitLevel=? ';
  $sql   .= 'WHERE TraitId=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($trait_name, $trait_group_type_id, $trait_caption, $trait_description, $trait_data_type,
                $trait_val_maxlen, $trait_unit, $trait_used_in_analysis, $trait_val_rule, $trait_invalid_msg,
                $trait_level, $trait_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref = [{'Message' => "Trait ($trait_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub add_trait_alias_runmode {

=pod add_trait_alias_HELP_START
{
"OperationName": "Add trait alias",
"Description": "Add an alias (name, translation, etc) of the trait definition specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "traitalias",
"SkippedField": ["TraitId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='2' ParaName='TraitAliasId' /><Info Message='TraitAlias (2) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '3', 'ParaName' : 'TraitAliasId'}], 'Info' : [{'Message' : 'TraitAlias (3) has been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Trait (20) not found.' /></DATA>" }],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Trait (20) not found.'}]}" }],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TraitId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self     = shift;
  my $trait_id = $self->param('id');
  my $query    = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = { 'TraitId'    => 1 };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'traitalias', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $dbh_write = connect_kdb_write();

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status);

  my $trait_perm_sql = "SELECT $perm_str as UltimatePerm ";
  $trait_perm_sql   .= 'FROM trait ';
  $trait_perm_sql   .= 'WHERE TraitId=?';

  my ($read_err, $trait_perm) = read_cell($dbh_write, $trait_perm_sql, [$trait_id]);

  if (length($trait_perm) == 0) {

    my $err_msg = "Trait ($trait_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }
  elsif ( ($trait_perm & $READ_WRITE_PERM) != $READ_WRITE_PERM ) {

    my $err_msg = "Permission denied: trait ($trait_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trait_alias_name       = $query->param('TraitAliasName');

  my $trait_alias_caption    = '';

  if (defined $query->param('TraitAliasCaption')) {

    $trait_alias_caption = $query->param('TraitAlaisCaption');
  }

  my $trait_alias_description = '';

  if (defined $query->param('TraitAliasDescription')) {

    $trait_alias_description = $query->param('TraitAliasDescription');
  }

  my $trait_alias_value_rule_err_msg = '';

  if (defined $query->param('TraitAliasValueRuleErrMsg')) {

    $trait_alias_value_rule_err_msg = $query->param('TraitAliasValueRuleErrMsg');
  }

  my $trait_lang = '';

  if (defined $query->param('TraitLang')) {

    $trait_lang = $query->param('TraitLang');
  }

  my $sql = 'INSERT INTO traitalias SET ';
  $sql   .= 'TraitId=?, ';
  $sql   .= 'TraitAliasName=?, ';
  $sql   .= 'TraitAliasCaption=?, ';
  $sql   .= 'TraitAliasDescription=?, ';
  $sql   .= 'TraitAliasValueRuleErrMsg=?, ';
  $sql   .= 'TraitLang=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($trait_id, $trait_alias_name, $trait_alias_caption, $trait_alias_description,
                $trait_alias_value_rule_err_msg, $trait_lang
      );

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  my $trait_alias_id = $dbh_write->last_insert_id(undef, undef, 'traitalias', 'TraitAliasId');

  $dbh_write->disconnect();

  my $info_msg_aref  = [{'Message' => "TraitAlias ($trait_alias_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$trait_alias_id", 'ParaName' => 'TraitAliasId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub remove_trait_alias_runmode {

=pod remove_trait_alias_HELP_START
{
"OperationName": "Remove trait alias",
"Description": "Delete alias of the existing trait definition specified by trait alias id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='TraitAlias (3) has been removed successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'TraitAlias (2) has been removed successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TraitAlias (3) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'TraitAlias (3) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TraitAliasId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self           = shift;
  my $trait_alias_id = $self->param('id');
  my $query          = $self->query();

  my $data_for_postrun_href = {};

  my $dbh_write = connect_kdb_write();

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status);

  my $trait_id = read_cell_value($dbh_write, 'traitalias', 'TraitId', 'TraitAliasId', $trait_alias_id);

  if (length($trait_id) == 0) {

    my $err_msg = "TraitAlias ($trait_alias_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trait_perm_sql = "SELECT $perm_str as UltimatePerm ";
  $trait_perm_sql   .= 'FROM trait ';
  $trait_perm_sql   .= 'WHERE TraitId=?';

  my ($read_err, $trait_perm) = read_cell($dbh_write, $trait_perm_sql, [$trait_id]);

  if ( ($trait_perm & $READ_WRITE_PERM) != $READ_WRITE_PERM ) {

    my $err_msg = "Permission denied: trait ($trait_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'DELETE FROM traitalias ';
  $sql   .= 'WHERE TraitAliasId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($trait_alias_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "TraitAlias ($trait_alias_id) has been removed successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_trait_alias_runmode {

=pod update_trait_alias_HELP_START
{
"OperationName": "Update trait alias",
"Description": "Update trait alias definition using specified id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "traitalias",
"SkippedField": ["TraitId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='TraitAlias (1) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'TraitAlias (1) has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TraitAlias (2) not found.' /></DATA>" }],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'TraitAlias (2) not found.'}]}" }],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TraitAliasId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self           = shift;
  my $trait_alias_id = $self->param('id');
  my $query          = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = { 'TraitId'    => 1 };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'traitalias', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $dbh_write = connect_kdb_write();

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status);

  my $read_sql  =  'SELECT TraitAliasCaption, TraitAliasDescription, TraitAliasValueRuleErrMsg, ';
     $read_sql .=  'TraitId, TraitLang ';
     $read_sql .=  'FROM traitalias WHERE TraitAliasId=? ';

  my ($r_df_val_err, $r_df_val_msg, $trait_alias_df_val_data) = read_data($dbh_write, $read_sql, [$trait_alias_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve traitalias default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $trait_alias_caption             =  undef;
  my $trait_alias_description         =  undef;
  my $trait_alias_value_rule_err_msg  =  undef;
  my $trait_id                        =  undef;
  my $trait_lang                      =  undef;

  my $nb_df_val_rec    =  scalar(@{$trait_alias_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve traitalias default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $trait_alias_caption              =   $trait_alias_df_val_data->[0]->{'TraitAliasCaption'};
  $trait_alias_description          =   $trait_alias_df_val_data->[0]->{'TraitAliasDescription'};
  $trait_alias_value_rule_err_msg   =   $trait_alias_df_val_data->[0]->{'TraitAliasValueRuleErrMsg'};
  $trait_id                         =   $trait_alias_df_val_data->[0]->{'TraitId'};
  $trait_lang                       =   $trait_alias_df_val_data->[0]->{'TraitLang'};

  my $trait_perm_sql    = "SELECT $perm_str as UltimatePerm ";
     $trait_perm_sql   .= 'FROM trait ';
     $trait_perm_sql   .= 'WHERE TraitId=?';

  my ($read_err, $trait_perm) = read_cell($dbh_write, $trait_perm_sql, [$trait_id]);

  if ( ($trait_perm & $READ_WRITE_PERM) != $READ_WRITE_PERM ) {

    my $err_msg = "Permission denied: trait ($trait_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trait_alias_name = $query->param('TraitAliasName');

  if (defined $query->param('TraitAliasCaption')) {

     $trait_alias_caption = $query->param('TraitAliasCaption');
  }

  if (defined $query->param('TraitAliasDescription')) {

     $trait_alias_description = $query->param('TraitAliasDescription');
  }

  if (defined $query->param('TraitAliasValueRuleErrMsg')) {

     $trait_alias_value_rule_err_msg = $query->param('TraitAliasValueRuleErrMsg');
  }

  if (defined $query->param('TraitLang')) {

     $trait_lang = $query->param('TraitLang');
  }

  my $sql = 'UPDATE traitalias SET ';
  $sql   .= 'TraitAliasName=?, ';
  $sql   .= 'TraitAliasCaption=?, ';
  $sql   .= 'TraitAliasDescription=?, ';
  $sql   .= 'TraitAliasValueRuleErrMsg=?, ';
  $sql   .= 'TraitLang=? ';
  $sql   .= 'WHERE TraitAliasId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($trait_alias_name, $trait_alias_caption, $trait_alias_description,
                $trait_alias_value_rule_err_msg, $trait_lang, $trait_alias_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "TraitAlias ($trait_alias_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_trait_alias {

  my $self         = shift;
  my $trait_perm   = shift;
  my $where_clause = qq{};
  $where_clause    = shift;

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

  my $sql = 'SELECT TraitAliasId, TraitAliasName ';
  $sql   .= 'FROM traitalias ';
  $sql   .= $where_clause;
  $sql   .= ' ORDER BY TraitAliasId DESC';

  my $sth = $dbh->prepare($sql);
  # parameters provided by the caller
  # for example, ('WHERE FieldA=?', '1')
  $sth->execute(@_);

  my $err = 0;
  my $msg = '';
  my $trait_alias_data = [];

  if ( !$dbh->err() ) {

    my $array_ref = $sth->fetchall_arrayref({});

    if ( !$sth->err() ) {

      $trait_alias_data = $array_ref;
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

  my @extra_attr_trait_alias_data;

  for my $row (@{$trait_alias_data}) {

    if (($trait_perm & $READ_WRITE_PERM) == $READ_WRITE_PERM) {

      my $trait_alias_id = $row->{'TraitAliasId'};
      $row->{'update'}   = "update/trait/alias/$trait_alias_id";
      $row->{'delete'}   = "remove/trait/alias/$trait_alias_id";
    }
    push(@extra_attr_trait_alias_data, $row);
  }

  $dbh->disconnect();

  return ($err, $msg, \@extra_attr_trait_alias_data);
}

sub list_trait_alias_runmode {

=pod list_trait_alias_HELP_START
{
"OperationName": "List trait aliases",
"Description": "List all the trait aliases for a trait specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><TraitAlias TraitAliasName='TestAlias1' TraitAliasId='1' delete='remove/trait/alias/1' update='update/trait/alias/1' /><RecordMeta TagName='TraitAlias' /></DATA>",
"SuccessMessageJSON": "{'TraitAlias' : [{'TraitAliasId' : '1', 'TraitAliasName' : 'TestAlias1', 'delete' : 'remove/trait/alias/1', 'update' : 'update/trait/alias/1'}], 'RecordMeta' : [{'TagName' : 'TraitAlias'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Trait (20) not found.' /></DATA>" }],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Trait (20) not found.'}]}" }],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TraitId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self     = shift;
  my $trait_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status);

  my $sql = "SELECT $perm_str FROM trait WHERE TraitId=?";

  my ($read_perm_err, $trait_perm) = read_cell($dbh, $sql, [$trait_id]);

  $dbh->disconnect();

  if (length($trait_perm) == 0) {

    my $err_msg = "Trait ($trait_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $msg = '';

  my $where_clause = 'WHERE TraitId=?';
  my ($trait_alias_err, $trait_alias_msg, $trait_alias_data) = $self->list_trait_alias($trait_perm,
                                                                                       $where_clause,
                                                                                       $trait_id);

  if ($trait_alias_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'TraitAlias' => $trait_alias_data,
                                           'RecordMeta' => [{'TagName' => 'TraitAlias'}],
  };

  return $data_for_postrun_href;
}

sub export_samplemeasurement_csv_runmode {

=pod export_samplemeasurement_csv_HELP_START
{
"OperationName": "Export sample measurements",
"Description": "Export sample measurements (if exists) into a csv file formatted as a sparse matrix of phenotypic data",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><OutputFile csv='http://kddart-d.diversityarrays.com/data/admin/export_samplemeasurement_fc77a5593427a35b804a07150dccb942.csv' /></DATA>",
"SuccessMessageJSON": "{'OutputFile' : [{'csv' : 'http://kddart-d.diversityarrays.com/data/admin/export_samplemeasurement_fc77a5593427a35b804a07150dccb942.csv'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPParameter": [{"Required": 0, "Name": "TrialUnitIdCSV", "Description": "Filtering parameter for TrialUnitId. The value is comma separated value of TrialUnitId."}, {"Required": 0, "Name": "SampleTypeIdCSV", "Description": "Filtering parameter for SampleTypeId. The value is comma separated value of SampleTypeId."}, {"Required": 0, "Name": "TraitIdCSV", "Description": "Filtering parameter for TraitId. The value is comma separated value of TraitId."}, {"Required": 0, "Name": "OperatorIdCSV", "Description": "Filtering parameter for OperatorId. The value is comma separated value of OperatorId."}, {"Required": 0, "Name": "MeasureDateTimeFrom", "Description": "Filtering parameter for MeasureDateTime. The value is correctly formatted date/time from which the sample measurement was recorded."}, {"Required": 0, "Name": "MeasureDateTimeTo", "Description": "Filtering parameter for MeasureDateTime. The value is correctly formatted date/time to which the sample measurement was recorded."}, {"Required": 0, "Name": "TrialIdCSV", "Description": "Filtering parameter for TrialId. The value is comma separated value of TrialId. This filtering parameter could be overridden by TrialUnitIdCSV if it is provided because filtering on TrialUnitId is at a lower level."}, {"Required": 0, "Name": "SMGroupIdCSV", "Description": "Filtering parameter for SMGroupId. The value is comma separated value of SMGroupId."}, {"Required": 0, "Name": "SurveyIdCSV", "Description": "Filtering parameter for SurveyId. The value is comma separated value of SurveyId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $trial_id_csv = '';

  if (defined $query->param('TrialIdCSV')) {

    $trial_id_csv = $query->param('TrialIdCSV');
  }

  my $tunit_id_csv = '';

  if (defined $query->param('TrialUnitIdCSV')) {

    $tunit_id_csv = $query->param('TrialUnitIdCSV');
  }

  my $stype_id_csv = '';

  if (defined $query->param('SampleTypeIdCSV')) {

    $stype_id_csv = $query->param('SampleTypeIdCSV');
  }

  my $trait_id_csv = '';

  if (defined $query->param('TraitIdCSV')) {

    $trait_id_csv = $query->param('TraitIdCSV');
  }

  my $operator_id_csv = '';

  if (defined $query->param('OperatorIdCSV')) {

    $operator_id_csv = $query->param('OperatorIdCSV');
  }

  my $measure_dt_from = '';

  if (defined $query->param('MeasureDateTimeFrom')) {

    $measure_dt_from = $query->param('MeasureDateTimeFrom');
  }

  my $measure_dt_to = '';

  if (defined $query->param('MeasureDateTimeTo')) {

    $measure_dt_to = $query->param('MeasureDateTimeTo');
  }

  my $survey_id_csv = '';

  if (defined $query->param('SurveyIdCSV')) {

    $survey_id_csv = $query->param('SurveyIdCSV');
  }

  my $smgroup_id_csv = '';

  if (defined $query->param('SMGroupIdCSV')) {

    $smgroup_id_csv = $query->param('SMGroupIdCSV');
  }

  my $specimen_id_csv = '';

  if (defined $query->param('SpecimenIdCSV')) {

    $specimen_id_csv = $query->param('SpecimenIdCSV');
  }
  my $genotype_id_csv = '';

  if (defined $query->param('GenotypeIdCSV')) {

    $genotype_id_csv = $query->param('GenotypeIdCSV');
  }

  my $dbh = connect_kdb_read();

  $self->logger->debug("TrialUnitIdCSV: $tunit_id_csv");

  my @where_phrases;

  if (length($trial_id_csv) > 0) {

    my ($trial_exist_err, $trial_rec_str) = record_exist_csv($dbh, 'trial', 'TrialId', $trial_id_csv);

    if ($trial_exist_err) {

      my $err_msg = "Trial ($trial_rec_str) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $where_trial = " TrialId IN ($trial_rec_str) ";
    push(@where_phrases, $where_trial);
  }

  if (length($smgroup_id_csv) > 0) {

    my ($smgrp_exist_err, $smgrp_rec_str) = record_exist_csv($dbh, 'smgroup', 'SMGroupId', $smgroup_id_csv);

    if ($smgrp_exist_err) {

      my $err_msg = "SMGroup ($smgrp_rec_str): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $where_smgrp = " SMGroupId IN ($smgrp_rec_str) ";
    push(@where_phrases, $where_smgrp);
  }

  if (length($tunit_id_csv) > 0) {

    my ($tunit_exist_err, $tunit_rec_str) = record_exist_csv($dbh, 'trialunit', 'TrialUnitId', $tunit_id_csv);

    if ($tunit_exist_err) {

      my $err_msg = "TrialUnit ($tunit_rec_str) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $where_tunit = " samplemeasurement.TrialUnitId IN ($tunit_rec_str) ";
    push(@where_phrases, $where_tunit);
  }

  if (length($stype_id_csv) > 0) {

    my ($stype_exist_err, $stype_rec_str) = type_existence_csv($dbh, 'sample', $stype_id_csv);

    if ($stype_exist_err) {

      my $err_msg = "SampleType ($stype_rec_str) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $where_stype = " SampleTypeId IN ($stype_rec_str) ";
    push(@where_phrases, $where_stype);
  }

  if (length($trait_id_csv) > 0) {

    my ($trait_exist_err, $trait_rec_str) = record_exist_csv($dbh, 'trait', 'TraitId', $trait_id_csv);

    if ($trait_exist_err) {

      my $err_msg = "Trait ($trait_rec_str) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $where_trait = " TraitId IN ($trait_rec_str) ";
    push(@where_phrases, $where_trait);
  }

  if (length($operator_id_csv) > 0) {

    my ($oper_exist_err, $oper_rec_str) = record_exist_csv($dbh, 'systemuser', 'UserId', $operator_id_csv);

    if ($oper_exist_err) {

      my $err_msg = "Operator ($oper_rec_str) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $where_operator = " OperatorId IN ($oper_rec_str) ";
    push(@where_phrases, $where_operator);
  }

  if (length($survey_id_csv) > 0) {

  my ($survey_exist_err, $survey_rec_str) = record_exist_csv($dbh, 'survey', 'SurveyId', $survey_id_csv);

  if ($survey_exist_err) {

    my $err_msg = "Survey ($survey_rec_str) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $where_trial = " SurveyId IN ($survey_rec_str) ";
  push(@where_phrases, $where_trial);
}

  my $where_measure_time = '';

  if (length($measure_dt_from) > 0) {

    my ($mdt_from_err, $mdt_from_msg) = check_dt_value( { 'MeasureDateTimeFrom' => $measure_dt_from } );

    if ($mdt_from_err) {

      my $err_msg = "$mdt_from_msg not date/time.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    $where_measure_time = " MeasureDateTime >= '$measure_dt_from' ";
  }

  if (length($measure_dt_to) > 0) {


    my ($mdt_to_err, $mdt_to_msg) = check_dt_value( { 'MeasureDateTimeTo' => $measure_dt_to } );

    if ($mdt_to_err) {

      my $err_msg = "$mdt_to_msg not date/time.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if (length($where_measure_time) > 0) {

      $where_measure_time .= " AND MeasureDateTime <= '$measure_dt_to' ";
    }
    else {

      $where_measure_time = " MeasureDateTime <= '$measure_dt_to' ";
    }
  }

  push(@where_phrases, $where_measure_time);

  if (length($specimen_id_csv) > 0) {
    
    push(@where_phrases, "specimen.SpecimenId IN ($specimen_id_csv)");
  
  }

  if (length($genotype_id_csv) > 0) {
    
    push(@where_phrases, "genotypespecimen.GenotypeId IN ($genotype_id_csv)");
  
  }

  my @field_headers = ('TrialUnitId', 'TraitId', 'OperatorId', 'MeasureDateTime',
                       'InstanceNumber', 'SampleTypeId', 'TrialUnitSpecimenId', 'TraitValue',
                       'SMGroupId', 'StateReason', 'SurveyId');

  my @sql_field_list;

  foreach my $field_name (@field_headers) {

    push(@sql_field_list, "samplemeasurement.${field_name}");
  }

  my $sql = 'SELECT ' . join(',', @sql_field_list) . ' ';
  $sql   .= 'FROM samplemeasurement LEFT JOIN trialunit ';

  my $genotype_specimen_sql = "";

  if (length($specimen_id_csv) > 0) {

    $genotype_specimen_sql = 'LEFT JOIN trialunitspecimen ON trialunit.TrialUnitId = trialunitspecimen.TrialUnitId LEFT JOIN specimen on specimen.SpecimenId = trialunitspecimen.SpecimenId '

  }
  
  if (length($genotype_id_csv) > 0) {
    #really can't do genotype id and specimen id at the same time for now
    $genotype_specimen_sql = 'LEFT JOIN trialunitspecimen ON trialunit.TrialUnitId = trialunitspecimen.TrialUnitId ';
    $genotype_specimen_sql .= 'LEFT JOIN specimen on specimen.SpecimenId = trialunitspecimen.SpecimenId ';
    $genotype_specimen_sql .= 'LEFT JOIN genotypespecimen on genotypespecimen.SpecimenId = specimen.SpecimenId ';

  }

  $sql .= $genotype_specimen_sql;

  $sql   .= 'ON samplemeasurement.TrialUnitId = trialunit.TrialUnitId ';

  my $where_clause = '';
  for my $phrase (@where_phrases) {

    if (length($phrase) > 0) {

      if (length($where_clause) > 0) {

        $where_clause .= "AND $phrase";
      }
      else {

        $where_clause .= "$phrase";
      }
    }
  }

  if (length($where_clause) > 0) {

    $sql .= " WHERE $where_clause ";
  }

  my $export_data_sql_md5 = md5_hex($sql);

  $self->logger->debug("SQL: $sql");

  my $username          = $self->authen->username();
  my $doc_root          = $ENV{'DOCUMENT_ROOT'};
  my $export_data_path  = "${doc_root}/data/$username";
  my $current_runmode   = $self->get_current_runmode();
  my $lock_filename     = "${current_runmode}.lock";
  my $filename          = "export_samplemeasurement_$export_data_sql_md5";
  my $csv_file          = "${export_data_path}/${filename}.csv";

  if ( !(-e $export_data_path) ) {

    mkdir($export_data_path);
  }

  my $lockfile = File::Lockfile->new($lock_filename, $export_data_path);

  my $pid = $lockfile->check();

  if ($pid) {

    $self->logger->debug("$lock_filename exists in $export_data_path");
    my $msg = 'Lockfile exists: either another process of this export is running or ';
    $msg   .= 'there was an unexpected error regarding clearing this lockfile.';

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $msg}]};

    return $data_for_postrun_href;
  }

  $lockfile->write();

  my $sth = $dbh->prepare($sql);
  $sth->execute();

  if ($dbh->err()) {

    $lockfile->remove();
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("csv: $csv_file");

  open(my $smeasure_csv_fh, ">$csv_file") or die "Can't open $csv_file for writing: $!";

  print $smeasure_csv_fh '#' . join(',', @field_headers) . "\n";

  while ( my $row_aref = $sth->fetchrow_arrayref() ) {

    foreach my $col_entry (@{$row_aref}) {
        if (length($col_entry)) {
          $col_entry = qq|"$col_entry"|;
        }
        else {
          $col_entry = "";
        }
    }

    my $csv_line = join(',', @{$row_aref});

    print $smeasure_csv_fh "$csv_line\n";
  }

  close($smeasure_csv_fh);

  $lockfile->remove();

  $sth->finish();

  $self->logger->debug("Document root: $doc_root");

  $dbh->disconnect();

  my $url = reconstruct_server_url();

  my $info_aref = [{ 'csv' => "$url/data/$username/${filename}.csv" }];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'OutputFile' => $info_aref };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_trait_advanced_runmode {

=pod list_trait_advanced_HELP_START
{
"OperationName": "List traits",
"Description": "List available traits definitions. This listing requires pagination information.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination NumOfRecords='13' NumOfPages='13' Page='1' NumPerPage='1' /><Trait AccessGroupPerm='5' TraitDescription='Trait used for automatic testing' AccessGroupId='0' TraitUnitName='U_8793656' AccessGroupPermission='Read/Link' OtherPermission='None' addAlias='trait/14/add/alias' chgPerm='trait/14/change/permission' OwnGroupPerm='7' OtherPerm='0' TraitUnit='30' TraitName='Trait_6006712' TraitId='14' OwnGroupPermission='Read/Write/Link' TraitValRule='boolex(x &gt; 0 and x &lt; 500)' TraitDataType='INTEGER' OwnGroupName='admin' IsTraitUsedForAnalysis='0' AccessGroupName='admin' TraitValueMaxLength='20' TraitGroupTypeId='' chgOwner='trait/14/change/owner' TraitValRuleErrMsg='invalid value' UltimatePermission='Read/Write/Link' delete='delete/trait/14' OwnGroupId='0' update='update/trait/14' UltimatePerm='7' TraitCaption='Automatic testing trait' /><RecordMeta TagName='Trait' /></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfRecords' : '13', 'NumOfPages' : 13, 'NumPerPage' : '1', 'Page' : '1'}], 'Trait' : [{'TraitDescription' : 'Trait used for automatic testing', 'AccessGroupPerm' : '5', 'AccessGroupId' : '0', 'TraitUnitName' : 'U_8793656', 'addAlias' : 'trait/14/add/alias', 'OtherPermission' : 'None', 'AccessGroupPermission' : 'Read/Link', 'chgPerm' : 'trait/14/change/permission', 'OwnGroupPerm' : '7', 'OtherPerm' : '0', 'TraitUnit' : '30', 'TraitName' : 'Trait_6006712', 'TraitId' : '14', 'OwnGroupPermission' : 'Read/Write/Link', 'TraitValRule' : 'boolex(x > 0 and x < 500)', 'OwnGroupName' : 'admin', 'TraitDataType' : 'INTEGER', 'IsTraitUsedForAnalysis' : '0', 'AccessGroupName' : 'admin', 'TraitValueMaxLength' : '20', 'TraitGroupTypeId' : null, 'chgOwner' : 'trait/14/change/owner', 'UltimatePermission' : 'Read/Write/Link', 'TraitValRuleErrMsg' : 'invalid value', 'delete' : 'delete/trait/14', 'update' : 'update/trait/14', 'OwnGroupId' : '0', 'TraitCaption' : 'Automatic testing trait', 'UltimatePerm' : '7'}], 'RecordMeta' : [{'TagName' : 'Trait'}]}",
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

  $self->logger->debug("Filtering csv: $filtering_csv");

  my $sorting = '';

  if (defined $query->param('Sorting')) {

    $sorting = $query->param('Sorting');
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status);

  my $sql = 'SELECT * from trait ';
  $sql   .= 'LIMIT 1';

  my ($sam_trait_err, $sam_trait_msg, $sam_trait_data) = $self->list_trait(0, $sql);

  if ($sam_trait_err) {

    $self->logger->debug($sam_trait_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $dbh = connect_kdb_read();

  my $sample_data_aref = $sam_trait_data;

  my @field_list_all;

  if (scalar(@{$sample_data_aref}) == 1) {

    @field_list_all = keys(%{$sample_data_aref->[0]});
  }
  else {

    $self->logger->debug("It reaches here");
    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'trait');

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
                                                                                'TraitId');

    if ($sel_field_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;
  }

  my $field_lookup = {};
  my $field_idx = 0;
  for my $fd_name (@{$final_field_list}) {

    $field_lookup->{$fd_name} = $field_idx;
    $field_idx += 1;
  }

  my $other_join = '';
  if ($field_lookup->{'UnitId'}) {

    my $f_idx = $field_lookup->{'UnitId'};
    $final_field_list->[$f_idx] = 'trait.UnitId';
    push(@{$final_field_list}, 'generalunit.UnitName AS UnitName');
    $other_join .= ' LEFT JOIN generalunit ON trait.UnitId = generalunit.UnitId ';
  }

  if ($field_lookup->{'TraitGroupTypeId'}) {

    push(@{$final_field_list}, 'tgrptype.TypeName AS TraitGroupTypeName');
    $other_join .= ' LEFT JOIN generaltype AS tgrptype ON trait.TraitGroupTypeId = tgrptype.TypeId ';
  }

  if ($field_lookup->{'TraitDataType'}) {

    push(@{$final_field_list}, 'tdatatype.TypeName AS TraitDataTypeName');
    $other_join .= ' LEFT JOIN generaltype AS tdatatype ON trait.TraitDataType = tdatatype.TypeId ';
  }

  push(@{$final_field_list}, 'OwnGroupId');
  push(@{$final_field_list}, 'AccessGroupId');
  push(@{$final_field_list}, 'OwnGroupPerm');
  push(@{$final_field_list}, 'AccessGroupPerm');
  push(@{$final_field_list}, 'OtherPerm');
  push(@{$final_field_list}, "$perm_str AS UltimatePerm");

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering('TraitId',
                                                                              'trait',
                                                                              $filtering_csv,
                                                                              $final_field_list);

  $self->logger->debug("Filter phrase: $filter_phrase");

  if ($filter_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $filter_msg}]};

    return $data_for_postrun_href;
  }

  my $final_field_list_str = join(',', @{$final_field_list});

  my $filter_where_phrase = '';
  if (length($filter_phrase) > 0) {

    $filter_where_phrase = " AND $filter_phrase ";
  }

  my $filtering_exp = " WHERE (($perm_str) & $READ_PERM) = $READ_PERM $filter_where_phrase ";

  $sql  = "SELECT $final_field_list_str ";
  $sql .= "FROM trait ";
  $sql .= "$other_join ";
  $sql .= "$filtering_exp ";

  $self->logger->debug("SQL: $sql");

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

    my ($paged_id_err, $paged_id_msg, $nb_records,
        $nb_pages, $limit_clause, $rcount_time) = get_paged_filter($dbh,
                                                                   $nb_per_page,
                                                                   $page,
                                                                   'trait',
                                                                   'TraitId',
                                                                   $filtering_exp,
                                                                   $where_arg
        );

    $self->logger->debug("SQL Row count time: $rcount_time");

    if ($paged_id_err == 1) {

      $self->logger->debug($paged_id_msg);

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    if ($paged_id_err == 2) {

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

    $sql .= ' ORDER BY TraitId DESC';
  }

  $sql .= " $paged_limit_clause ";

  $self->logger->debug("SQL: $sql");

  my ($read_trait_err, $read_trait_msg, $trait_data) = $self->list_trait(1,
                                                                         $sql,
                                                                         $where_arg);

  if ($read_trait_err) {

    $self->logger->debug($read_trait_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Trait'      => $trait_data,
                                           'Pagination' => $pagination_aref,
                                           'RecordMeta' => [{'TagName' => 'Trait'}],
  };

  return $data_for_postrun_href;
}

sub list_treatment_advanced_runmode {

=pod list_treatment_advanced_HELP_START
{
"OperationName": "List treatments",
"Description": "List treatment entries in the treatment dictionary. This listing requires pagination information.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination Page='1' NumOfRecords='17' NumOfPages='17' NumPerPage='1' /><RecordMeta TagName='Treatment' /><Treatment TreatmentText='Removing weeds' TreatmentId='18' update='update/treatment/18' /></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfRecords' : '17', 'NumOfPages' : 17, 'NumPerPage' : '1', 'Page' : '1'}], 'VCol' : [], 'RecordMeta' : [{'TagName' : 'Treatment'}], 'Treatment' : [{'TreatmentText' : 'Removing weeds', 'TreatmentId' : '18', 'update' : 'update/treatment/18'}]}",
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
  my $field_list = ['SCol*', 'VCol*'];

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $field_list, 'treatment',
                                                                        'TreatmentId', '');

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};
    $self->logger->debug("generate_factor_sql error");

    return $data_for_postrun_href;
  }

  $sql   .= " LIMIT 1";

  $self->logger->debug("SQL with VCol: $sql");


  my ($list_treatment_err, $list_treatment_msg, $pre_list_treatment) = $self->list_treatment(0, $sql);

  if ($list_treatment_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $sample_data_aref = $pre_list_treatment;

  my @field_list_all;

  if (scalar(@{$sample_data_aref}) == 1) {

    @field_list_all = keys(%{$sample_data_aref->[0]});
  }
  else {

    $self->logger->debug("It reaches here");
    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'treatment');

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
                                                                                'TreatmentId');

    if ($sel_field_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;
  }

  ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $final_field_list, 'treatment',
                                                                     'TreatmentId', '');

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};
    $self->logger->debug("generate_factor_sql error: $trouble_vcol");
    $self->logger->debug("Error SQL: $sql");

    return $data_for_postrun_href;
  }

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering('TreatmentId',
                                                                              'treatment',
                                                                              $filtering_csv,
                                                                              $final_field_list);

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

    my ($paged_id_err, $paged_id_msg, $nb_records,
        $nb_pages, $limit_clause, $rcount_time) = get_paged_filter($dbh,
                                                                   $nb_per_page,
                                                                   $page,
                                                                   'treatment',
                                                                   'TreatmentId',
                                                                   $filtering_exp,
                                                                   $where_arg
        );

    $self->logger->debug("SQL Row count time: $rcount_time");

    if ($paged_id_err == 1) {

      $self->logger->debug($paged_id_msg);

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    if ($paged_id_err == 2) {

      $page = 0;
    }

    $pagination_aref = [{'NumOfRecords' => $nb_records,
                         'NumOfPages'   => $nb_pages,
                         'Page'         => $page,
                         'NumPerPage'   => $nb_per_page,
                        }];

    $paged_limit_clause = $limit_clause;
  }

  $sql  =~ s/GROUP BY/ $filtering_exp GROUP BY /;

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

    $sql .= ' ORDER BY treatment.TreatmentId DESC';
  }

  $sql .= " $paged_limit_clause ";

  $dbh->disconnect();

  $self->logger->debug("Final SQL: $sql");

  my ($err, $msg, $list_treatment) = $self->list_treatment(1, $sql, $where_arg);

  if ($err) {

    $self->logger->debug($msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Treatment'  => $list_treatment,
                                           'VCol'       => $vcol_list,
                                           'Pagination' => $pagination_aref,
                                           'RecordMeta' => [{'TagName' => 'Treatment'}],
  };

  return $data_for_postrun_href;
}

sub del_trait_runmode {

=pod del_trait_gadmin_HELP_START
{
"OperationName": "Delete trait",
"Description": "Delete trait definition for a trait specified by id. Trait can be deleted only if not attached to any lower level related record.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Trait (7) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Trait (11) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdUsed": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Trait (1) is used in samplemeasurement.' /></DATA>"}],
"ErrorMessageJSON": [{"IdUsed": "{'Error' : [{'Message' : 'Trait (1) is used in samplemeasurement.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TraitId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $trait_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_k_read = connect_kdb_read();

  my $trait_owner_id = read_cell_value($dbh_k_read, 'trait', 'OwnGroupId', 'TraitId', $trait_id);

  if (length($trait_owner_id) == 0) {

    my $err_msg = "Trait ($trait_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();

  if ($trait_owner_id != $group_id) {

    my $err_msg = "Trait ($trait_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trait_measurement = record_existence($dbh_k_read, 'samplemeasurement', 'TraitId', $trait_id);

  if ($trait_measurement) {

    my $err_msg = "Trait ($trait_id) is used in samplemeasurement.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trait_genotype = record_existence($dbh_k_read, 'genotypetrait', 'TraitId', $trait_id);

  if ($trait_genotype) {

    my $err_msg = "Trait ($trait_id) is used in genotypetrait.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (record_existence($dbh_k_read, 'trialtrait', 'TraitId', $trait_id)) {

    my $err_msg = "Trait ($trait_id) is used in trialtrait.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $sql = 'DELETE FROM traitalias WHERE TraitId=?';
  my $sth = $dbh_k_write->prepare($sql);

  $sth->execute($trait_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $sql = 'DELETE FROM trait WHERE TraitId=?';
  $sth = $dbh_k_write->prepare($sql);

  $sth->execute($trait_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref = [{'Message' => "Trait ($trait_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub del_treatment_runmode {

=pod del_treatment_gadmin_HELP_START
{
"OperationName": "Delete treatment",
"Description": "Delete treatment from a dictionary using specified id. Treatment can be deleted only if not attached to any lower level related record.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Treatment (2) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Treatment (7) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdUsed": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Treatment (1) is used in trialunit.' /></DATA>"}],
"ErrorMessageJSON": [{"IdUsed": "{'Error' : [{'Message' : 'Treatment (1) is used in trialunit.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TreatmentId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $treatment_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_k_read = connect_kdb_read();

  my $treatment_exist = record_existence($dbh_k_read, 'treatment', 'TreatmentId', $treatment_id);

  if (!$treatment_exist) {

    my $err_msg = "Treatment ($treatment_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $treatment_used = record_existence($dbh_k_read, 'trialunittreatment', 'TreatmentId', $treatment_id);

  if ($treatment_used) {

    my $err_msg = "Treatment ($treatment_id) is used in trialunit.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $sql = 'DELETE FROM treatmentfactor WHERE TreatmentId=?';
  my $sth = $dbh_k_write->prepare($sql);

  $sth->execute($treatment_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $sql = 'DELETE FROM treatment WHERE TreatmentId=?';
  $sth = $dbh_k_write->prepare($sql);

  $sth->execute($treatment_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref = [{'Message' => "Treatment ($treatment_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub export_datakapture_template_runmode {

=pod export_datakapture_template_HELP_START
{
"OperationName": "Export trial data template",
"Description": "Export template file for phenotypic data collection for a trial. Once data are collected it can be used to import data for the trial.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info NumOfTraitColumn='2' NumOfTrialUnit='64' /><OutputFile csv='http://kddart-d.diversityarrays.com/data/admin/export_kdsmart_template_trial7_trait8_9.csv' FileType='csv' FileDescription='Template file for KDSmart' FileIdentifier='TemplateFile' /><OutputFile csv='http://kddart-d.diversityarrays.com/data/admin/export_kdsmart_traitfile_trial7_trait8_9.csv' FileType='csv' FileDescription='Trait file for KDSmart' FileIdentifier='TraitFile' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'NumOfTrialUnit' : 64, 'NumOfTraitColumn' : 2}], 'OutputFile' : [{'FileDescription' : 'Template file for KDSmart', 'csv' : 'http://kddart-d.diversityarrays.com/data/admin/export_kdsmart_template_trial7_trait8_9.csv', 'FileType' : 'csv', 'FileIdentifier' : 'TemplateFile'},{'FileDescription' : 'Trait file for KDSmart', 'csv' : 'http://kddart-d.diversityarrays.com/data/admin/export_kdsmart_traitfile_trial7_trait8_9.csv', 'FileType' : 'csv', 'FileIdentifier' : 'TraitFile'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPParameter": [{"Required": 0, "Name": "BlockColName", "Description": "Prefix text for Block in the UnitPosition used in the trial specified in the URLParameter"}, {"Required": 1, "Name": "ColumnColName", "Description": "Prefix text for Column in the UnitPosition used in the trial specified in the URLParameter"}, {"Required": 1, "Name": "RowColName", "Description": "Prefix text for Row in the UnitPosition used in the trial specified in the URLParameter"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $trial_id            = $self->param('id');

  my $unitposition_block  = '';

  if (length($query->param('BlockColName')) > 0) {

    $unitposition_block = $query->param('BlockColName');
  }

  my $unitposition_column = $query->param('ColumnColName');
  my $unitposition_row    = $query->param('RowColName');

  my $data_for_postrun_href = {};

  my ($missing_err, $missing_href) = check_missing_href( {
                                                          'ColumnColName' => $unitposition_column,
                                                          'RowColName'    => $unitposition_row,
                                                         } );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  my $acceptable_dimension_fieldname_lookup = {'TrialUnitEntryId' => 1,
                                               'TrialUnitX'       => 1,
                                               'TrialUnitY'       => 1,
                                               'TrialUnitZ'       => 1,
                                              };

  my $chk_dimension_fieldname_href = {
                                      'ColumnColName' => $unitposition_column,
                                      'RowColName'    => $unitposition_row,
                                      'BlockColName'  => $unitposition_block
                                     };

  my ($di_val_err, $di_val_href) = check_value_href( $chk_dimension_fieldname_href, $acceptable_dimension_fieldname_lookup );

  if ($di_val_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$di_val_href]};

    return $data_for_postrun_href;
  }

  my $dbh = connect_kdb_read();

  my $trial_exist = record_existence($dbh, 'trial', 'TrialId', $trial_id);

  if (!$trial_exist) {

    my $err_msg = "Trial ($trial_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TrialId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trial_name = read_cell_value($dbh, 'trial', 'TrialName', 'TrialId', $trial_id);

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_trial_ok, $trouble_trial_id_aref) = check_permission($dbh, 'trial', 'TrialId',
                                                               [$trial_id], $group_id, $gadmin_status,
                                                               $READ_PERM);

  if (!$is_trial_ok) {

    my $trouble_trial_id = $trouble_trial_id_aref->[0];
    my $err_msg = "Permission denied: Group ($group_id) and trial ($trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TrialId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT TraitId FROM trialtrait WHERE TrialId=?';

  my ($get_trait_id_err, $get_trait_id_msg, $trait_id_aref) = read_data($dbh, $sql, [$trial_id]);

  if ($get_trait_id_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error.'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$trait_id_aref}) == 0) {

    my $err_msg = "No trait attached to this trial.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trait_id_lookup = {};

  for my $trait_rec (@{$trait_id_aref}) {

    $trait_id_lookup->{$trait_rec->{'TraitId'}} = 1;
  }

  my @trait_id_list = keys(%{$trait_id_lookup});

  my ($is_trait_ok, $trouble_trait_id_aref) = check_permission($dbh, 'trait', 'TraitId',
                                                               \@trait_id_list, $group_id, $gadmin_status,
                                                               $READ_PERM);

  if (!$is_trait_ok) {

    my $trouble_trait = join(',', @{$trouble_trial_id_aref});
    my $err_msg = "Permission denied: Group ($group_id) and trait ($trouble_trait).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trait2nb_replicate = {};

  my @selected_trait_list = @trait_id_list;

  if ( defined $query->param('TraitList') ) {

    my $trait_id_csv = $query->param('TraitList');
    @selected_trait_list = split(',', $trait_id_csv);
  }

  for my $sel_trait_id (@selected_trait_list) {

    if ( !(defined $trait_id_lookup->{$sel_trait_id}) ) {

      my $err_msg = "Trait ($sel_trait_id): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'TraitList' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $num_of_rep = 1;
    my $para_name = 'Trait' . $sel_trait_id . 'NumOfRep';
    if (defined $query->param($para_name)) {

      my $tmp_num_of_rep = $query->param($para_name);

      if ($tmp_num_of_rep =~ /^\d+$/) {

        $num_of_rep = $tmp_num_of_rep;
      }
      else {

        my $err_msg = "Invalid string. Only integer is accepted.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{$para_name => $err_msg}]};

        return $data_for_postrun_href;
      }
    }

    if ($num_of_rep > 0) {

      $trait2nb_replicate->{$sel_trait_id} = $num_of_rep;
    }
  }

  my @filter_trait_list = keys(%{$trait2nb_replicate});

  my $trait_id_txt = join('_', @filter_trait_list);

  $trial_name =~ s/\W/_/g;

  my $username          = $self->authen->username();
  my $doc_root          = $ENV{'DOCUMENT_ROOT'};
  my $export_data_path  = "${doc_root}/data/$username";
  my $current_runmode   = $self->get_current_runmode();
  my $filename          = "csv_template_trial${trial_id}_${trial_name}_$trait_id_txt";
  my $csv_file          = "${export_data_path}/${filename}.csv";

  my $trait_filename    = "kdsmart_traitfile_trial${trial_id}__${trial_name}_$trait_id_txt";
  my $trait_csv_file    = "${export_data_path}/${trait_filename}.csv";

  if ( !(-e $export_data_path) ) {

    mkdir($export_data_path);
  }

  $sql    = 'SELECT site.SiteName, site.SiteStartDate, generaltype.TypeName as TrialTypeName, ';
  $sql   .= 'trial.TrialNumber, trial.TrialAcronym, trial.TrialStartDate, trialunit.TrialUnitPosition, ';
  $sql   .= 'trialunit.TrialUnitNote, trialunit.TrialUnitId, trialunit.ReplicateNumber, ';
  $sql   .= 'trialunit.TrialUnitEntryId, trialunit.TrialUnitX, trialunit.TrialUnitY, trialunit.TrialUnitZ, ';
  $sql   .= 'trialunit.TrialUnitBarcode ';
  $sql   .= 'FROM (((trialunit LEFT JOIN trial ON trialunit.TrialId = trial.TrialId) ';
  $sql   .= 'LEFT JOIN site ON trial.SiteId = site.SiteId) ';
  $sql   .= 'LEFT JOIN generaltype ON trial.TrialTypeId = generaltype.TypeId) ';
  $sql   .= 'WHERE trial.TrialId=? ';
  $sql   .= 'ORDER BY trialunit.TrialUnitId ASC ';

  my ($read_tu_err, $read_tu_msg, $trialunit_data) = read_data($dbh, $sql, [$trial_id]);

  if ($read_tu_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error.'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$trialunit_data}) == 0) {

    my $err_msg = "Trial ($trial_id): no trial unit found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TrialId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trait_sql_where   = '';

  if (scalar(@filter_trait_list) > 0) {

    my $filter_trait_txt = join(',', @filter_trait_list);
    $trait_sql_where = " AND trait.TraitId IN ($filter_trait_txt)";
  }

  $sql  = 'SELECT trait.* ';
  $sql .= 'FROM trialtrait LEFT JOIN trait on trialtrait.TraitId = trait.TraitId ';
  $sql .= "WHERE trialtrait.TrialId=? $trait_sql_where";

  if (scalar(@filter_trait_list) > 0) {

    my $official_trait_id_csv = join(',', @filter_trait_list);
    $sql .= " AND trialtrait.TraitId IN ($official_trait_id_csv) ";
  }
  else {

    $sql .= " AND False ";
  }

  $sql .= 'ORDER BY TraitName ASC';

  my ($read_trait_err, $read_trait_msg, $trait_data) = read_data($dbh, $sql, [$trial_id]);

  if ($read_trait_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error.'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$trait_data}) == 0) {

    my $err_msg = "No trait selected.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql  = 'SELECT trialunit.TrialUnitId, specimen.SpecimenName, specimen.SelectionHistory, specimen.Pedigree ';
  $sql .= 'FROM (trialunit LEFT JOIN trialunitspecimen ON trialunit.TrialUnitId = trialunitspecimen.TrialUnitId) ';
  $sql .= 'LEFT JOIN specimen ON trialunitspecimen.SpecimenId = specimen.SpecimenId ';
  $sql .= 'WHERE trialunit.TrialId=? AND (trialunitspecimen.HasDied=0 OR trialunitspecimen.HasDied IS NULL ) ';
  $sql .= 'ORDER BY trialunit.TrialUnitId ASC';

  my ($read_specimen_err, $read_specimen_msg, $specimen_data) = read_data($dbh, $sql, [$trial_id]);

  if ($read_specimen_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error.'}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  if (scalar(@{$specimen_data}) == 0) {

    my $err_msg = "Trial ($trial_id): no specimen found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trialunit2specimen_lookup = {};

  for my $specimen_rec (@{$specimen_data}) {

    my $trial_unit_id = $specimen_rec->{'TrialUnitId'};

    if ( !(defined $trialunit2specimen_lookup->{$trial_unit_id}) ) {

      my $spec_name   = $specimen_rec->{'SpecimenName'};
      my $sel_history = $specimen_rec->{'SelectionHistory'};
      my $pedigree    = $specimen_rec->{'Pedigree'};
      $trialunit2specimen_lookup->{$trial_unit_id} = [$spec_name, $sel_history, $pedigree];
    }
  }

  my $template_data = [];

  my $nb_trait_col        = 0;
  my $record_nb_trait_col = 1;

  for my $trial_unit_rec (@{$trialunit_data}) {

    my $trialunit_id = $trial_unit_rec->{'TrialUnitId'};

    if ( !(defined $trialunit2specimen_lookup->{$trialunit_id}) ) { next; }

    my $template_row   = {};

    my $site_year      = 0;
    my $trial_start_d  = '00 00 0000';

    # Although TrialStartDate is a required field, data loaded through mysql scripts may not have
    # any data for this field. This is to prevent DateTime from throwing exception.
    if (defined $trial_unit_rec->{'TrialStartDate'}) {

      if (length($trial_unit_rec->{'TrialStartDate'}) > 0) {

        $self->logger->debug("TrialStartDate for TrialUnit ($trialunit_id) is NULL in database");

        my $trial_start_dt = DateTime::Format::MySQL->parse_datetime($trial_unit_rec->{'TrialStartDate'});
        $site_year      = $trial_start_dt->year();
        $trial_start_d  = $trial_start_dt->strftime('%d %m %Y');
      }
    }

    $template_row->{'SiteName'}          = $trial_unit_rec->{'SiteName'};
    $template_row->{'SiteYear'}          = $site_year;
    $template_row->{'TrialTypeName'}     = $trial_unit_rec->{'TrialTypeName'};
    $template_row->{'TrialNumber'}       = $trial_unit_rec->{'TrialNumber'};
    $template_row->{'TrialAcronym'}      = $trial_unit_rec->{'TrialAcronym'};
    $template_row->{'TrialStartDate'}    = $trial_start_d;
    $template_row->{'GenotypeName'}      = $trialunit2specimen_lookup->{$trialunit_id}->[0];
    $template_row->{'SelectionHistory'}  = $trialunit2specimen_lookup->{$trialunit_id}->[1];
    $template_row->{'Pedigree'}          = $trialunit2specimen_lookup->{$trialunit_id}->[2];
    $template_row->{'TrialUnitComment'}  = $trial_unit_rec->{'TrialUnitNote'};
    $template_row->{'ReplicateNumber'}   = $trial_unit_rec->{'ReplicateNumber'};
    $template_row->{'TrialUnitPosition'} = $trial_unit_rec->{'TrialUnitPosition'};
    $template_row->{'Barcode'}           = $trial_unit_rec->{'TrialUnitBarcode'};

    $template_row->{'Row'}               = $trial_unit_rec->{$unitposition_row};
    $template_row->{'Column'}            = $trial_unit_rec->{$unitposition_column};

    if (length($unitposition_block) > 0) {

      $template_row->{'Block'} = $trial_unit_rec->{$unitposition_block};
    }
    else {

      $template_row->{'Block'} = '';
    }

    for my $trait_rec (@{$trait_data}) {

      my $trait_id      = $trait_rec->{'TraitId'};
      my $trait_name    = $trait_rec->{'TraitName'};
      my $nb_rep4trait  = $trait2nb_replicate->{$trait_id};

      if ($record_nb_trait_col) {

        $nb_trait_col += $nb_rep4trait;
      }

      if ($nb_rep4trait > 1) {

        for (my $i = 1; $i <= $nb_rep4trait; $i++) {

          my $dk_trait_name = $trait_name . "__$i";
          $template_row->{$dk_trait_name} = '';
        }
      }
      else {

        $template_row->{$trait_name} = '';
      }
    }

    # save the number of trait column only in the first row
    $record_nb_trait_col = 0;

    #$self->logger->debug("Template row: " . join(',', keys(%{$template_row})));

    push(@{$template_data}, $template_row);
  }

  my $nb_trialunit = scalar(@{$template_data});

  if ($nb_trialunit == 0) {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $field_order_href = {};
  $field_order_href->{'SiteName'}           = 0;
  $field_order_href->{'SiteYear'}           = 1;
  $field_order_href->{'TrialTypeName'}      = 2;
  $field_order_href->{'TrialNumber'}        = 3;
  $field_order_href->{'TrialAcronym'}       = 4;
  $field_order_href->{'TrialStartDate'}     = 5;
  $field_order_href->{'GenotypeName'}       = 6;
  $field_order_href->{'SelectionHistory'}   = 7;
  $field_order_href->{'TrialUnitComment'}   = 8;
  $field_order_href->{'ReplicateNumber'}    = 9;
  $field_order_href->{'Block'}              = 10;
  $field_order_href->{'Column'}             = 11;
  $field_order_href->{'Row'}                = 12;
  $field_order_href->{'Barcode'}            = 13;
  $field_order_href->{'Pedigree'}           = 14;
  $field_order_href->{'TrialUnitPosition'}  = 15;

  my $other_field_order_counter = 9000;
  for my $other_field (sort(keys(%{$template_data->[0]}))) {

    if (defined $field_order_href->{$other_field}) {

      next;
    }

    $field_order_href->{$other_field} = $other_field_order_counter;
    $other_field_order_counter += 1;
  }

  arrayref2csvfile($csv_file, $field_order_href, $template_data);

  my $traitfile_field_order_href = {};
  $traitfile_field_order_href->{'TraitId'}                = 0;
  $traitfile_field_order_href->{'TraitName'}              = 1;
  $traitfile_field_order_href->{'TraitCaption'}           = 2;
  $traitfile_field_order_href->{'TraitDescription'}       = 3;
  $traitfile_field_order_href->{'TraitDataType'}          = 4;
  $traitfile_field_order_href->{'TraitValueMaxLength'}    = 5;
  $traitfile_field_order_href->{'TraitUnit'}              = 6;
  $traitfile_field_order_href->{'TraitValRule'}           = 7;
  $traitfile_field_order_href->{'TraitValRuleErrMsg'}     = 8;
  $traitfile_field_order_href->{'IsTraitUsedForAnalysis'} = 9;
  $traitfile_field_order_href->{'OwnGroupId'}             = 10;
  $traitfile_field_order_href->{'AccessGroupId'}          = 11;
  $traitfile_field_order_href->{'OwnGroupPerm'}           = 12;
  $traitfile_field_order_href->{'AccessGroupPerm'}        = 13;
  $traitfile_field_order_href->{'OtherPerm'}              = 14;

  arrayref2csvfile($trait_csv_file, $traitfile_field_order_href, $trait_data);

  my $url = reconstruct_server_url();

  my $output_file_aref = [{ 'FileType' => 'csv',
                            'FileDescription' => 'Template file for KDSmart',
                            'FileIdentifier' => 'TemplateFile',
                            'csv' => "$url/data/$username/${filename}.csv" },
                          { 'FileType' => 'csv',
                            'FileDescription' => 'Trait file for KDSmart',
                            'FileIdentifier' => 'TraitFile',
                            'csv' => "$url/data/$username/${trait_filename}.csv" },
      ];

  my $info_aref = [{'NumOfTrialUnit' => $nb_trialunit, 'NumOfTraitColumn' => $nb_trait_col}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'OutputFile'     => $output_file_aref,
                                           'Info'           => $info_aref,
  };

  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub import_datakapture_data_csv_runmode {

=pod import_datakapture_data_csv_HELP_START
{
"OperationName": "Import trial data",
"Description": "Import phenotypic data for a trial specified by id. Import file format is the same as the trial template file, but already filled with data.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info NumOfNACell='0' NumOfEmptyCell='0' Message='128 records of samplemeasurement have been inserted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'NumOfNACell' : 0, 'Message' : '128 records of samplemeasurement have been inserted successfully.', 'NumOfEmptyCell' : 0}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error SampleTypeValue='SampleType (1434): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'SampleTypeValue' : 'SampleType (1434): not found.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "CSV",
"UploadFileParameterName": "uploadfile",
"HTTPParameter": [{"Required": 0, "Name": "force", "Description": "If a TrialId is specified and it is conflicting with a TrialId based on SiteName, SiteYear, TrialTypeName, TrialNumber, TrialAcronym and TrialStartDate, this parameter will determine if the system returns an error or take the TrialId in the URL. If this parameter is set to 1, the system will use the TrialId in the URL as its priority if the TrialId is provided. Otherwise, the system will return an error if there is a conflict."}, {"Required": 1, "Name": "SiteName", "Description": "Column number counting from zero for SiteName column in the upload CSV."}, {"Required": 1, "Name": "SiteYear", "Description": "Column number counting from zero for SiteYear column in the upload CSV"}, {"Required": 1, "Name": "TrialTypeName", "Description": "Column number counting from zero for TrialTypeName column in the upload CSV"}, {"Required": 1, "Name": "TrialNumber", "Description": "Column number counting from zero for TrialNumber column in the upload CSV"}, {"Required": 1, "Name": "TrialAcronym", "Description": "Column number counting from zero for TrialAcronym column in the upload CSV"}, {"Required": 1, "Name": "TrialStartDate", "Description": "Column number counting from zero for TrialStartDate colum in the upload CSV"}, {"Required": 1, "Name": "GenotypeName", "Description": "Column number counting from zero for GenotypeName column in the upload CSV"}, {"Required": 1, "Name": "ReplicateNumber", "Description": "Column number counting from zero for ReplicateNumber column in the upload CSV"}, {"Required": 1, "Name": "Block", "Description": "Column number counting from zero for Block column in the upload CSV"}, {"Required": 1, "Name": "Column", "Description": "Column number counting from zero for Column column in the upload CSV"}, {"Required": 1, "Name": "Row", "Description": "Column number counting from zero for Row column in the upload CSV"}, {"Required": 1, "Name": "Barcode", "Description": "Column number counting from zero for Barcode column in the upload CSV"}, {"Required": 1, "Name": "TraitDataStartCol", "Description": "Starting column number counting from zero for the first column containing trait data in the upload CSV"}, {"Required": 1, "Name": "TraitDataEndCol", "Description": "Ending column number counting from zero for the last column containing trait data in the upload CSV"}, {"Required": 1, "Name": "ColumnColName", "Description": "Prefix text for column in the UnitPosition used in the trial"}, {"Required": 1, "Name": "RowColName", "Description": "Prefix text for row in the UnitPosition used in the trial"}, {"Required": 1, "Name": "SampleTypeValue", "Description": "Value for the SampleTypeId"}, {"Required": 0, "Name": "BlockColName", "Description": "Prefix text for block in the UnitPosition used in the trial"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialId.", "Optional": 1}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self     = shift;
  my $query    = $self->query();
  my $trial_id = $self->param('id');

  my $force                = $query->param('force');
  my $sitename_col         = $query->param('SiteName');
  my $siteyear_col         = $query->param('SiteYear');
  my $trialtype_name_col   = $query->param('TrialTypeName');
  my $trialnumber_col      = $query->param('TrialNumber');
  my $trialacronym_col     = $query->param('TrialAcronym');
  my $trial_start_date_col = $query->param('TrialStartDate');
  my $genotype_col         = $query->param('GenotypeName');
  my $replicate_num_col    = $query->param('ReplicateNumber');
  my $block_col            = $query->param('Block');
  my $column_col           = $query->param('Column');
  my $row_col              = $query->param('Row');
  my $barcode_col          = $query->param('Barcode');
  my $trait_data_start_col = $query->param('TraitDataStartCol');
  my $trait_data_end_col   = $query->param('TraitDataEndCol');
  my $column_colname       = $query->param('ColumnColName');
  my $row_colname          = $query->param('RowColName');
  my $sampletype_value     = $query->param('SampleTypeValue');

  my $data_for_postrun_href = {};

  my $block_colname        = '';

  if (length($query->param('BlockColName')) > 0) {

    $block_colname = $query->param('BlockColName');
  }

  my ($missing_err, $missing_href) = check_missing_href( {
                                                          'SiteName'          => $sitename_col,
                                                          'SiteYear'          => $siteyear_col,
                                                          'TrialTypeName'     => $trialtype_name_col,
                                                          'TrialNumber'       => $trialnumber_col,
                                                          'TrialAcronym'      => $trialacronym_col,
                                                          'TrialStartDate'    => $trial_start_date_col,
                                                          'GenotypeName'      => $genotype_col,
                                                          'ReplicateNumber'   => $replicate_num_col,
                                                          'Block'             => $block_col,
                                                          'Column'            => $column_col,
                                                          'Row'               => $row_col,
                                                          'Barcode'           => $barcode_col,
                                                          'TraitDataStartCol' => $trait_data_start_col,
                                                          'TraitDataEndCol'   => $trait_data_end_col,
                                                          'ColumnColName'     => $column_colname,
                                                          'RowColName'        => $row_colname,
                                                          'SampleTypeValue'   => $sampletype_value
                                                         } );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  my $data_csv_file = $self->authen->get_upload_file();

  my $num_of_col = get_csvfile_num_of_col($data_csv_file);

  $self->logger->debug("Number of columns: $num_of_col");

  my ($col_def_err, $col_def_err_href) = check_col_def_href( {
                                                              'SiteName'          => $sitename_col,
                                                              'SiteYear'          => $siteyear_col,
                                                              'TrialTypeName'     => $trialtype_name_col,
                                                              'TrialNumber'       => $trialnumber_col,
                                                              'TrialAcronym'      => $trialacronym_col,
                                                              'TrialStartDate'    => $trial_start_date_col,
                                                              'GenotypeName'      => $genotype_col,
                                                              'ReplicateNumber'   => $replicate_num_col,
                                                              'Block'             => $block_col,
                                                              'Column'            => $column_col,
                                                              'Row'               => $row_col,
                                                              'Barcode'           => $barcode_col,
                                                              'TraitDataStartCol' => $trait_data_start_col,
                                                              'TraitDataEndCol'   => $trait_data_end_col
                                                             },
                                                             $num_of_col);

  if ($col_def_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$col_def_err_href]};

    return $data_for_postrun_href;
  }

  if ($trait_data_end_col eq '-1') {

    my $last_col_num = $num_of_col - 1;
    $trait_data_end_col = "$last_col_num";
  }

  my $acceptable_dimension_fieldname_lookup = {'TrialUnitEntryId' => 1,
                                               'TrialUnitX'       => 1,
                                               'TrialUnitY'       => 1,
                                               'TrialUnitZ'       => 1,
                                              };

  my $chk_dimension_fieldname_href = {
                                      'ColumnColName' => $column_colname,
                                      'RowColName'    => $row_colname,
                                      'BlockColName'  => $block_colname
                                     };

  my ($di_val_err, $di_val_href) = check_value_href( $chk_dimension_fieldname_href, $acceptable_dimension_fieldname_lookup );

  if ($di_val_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$di_val_href]};

    return $data_for_postrun_href;
  }

  my $matched_col = {};

  $matched_col->{$sitename_col}         = 'SiteName';
  $matched_col->{$siteyear_col}         = 'SiteYear';
  $matched_col->{$trialtype_name_col}   = 'TrialTypeName';
  $matched_col->{$trialnumber_col}      = 'TrialNumber';
  $matched_col->{$trialacronym_col}     = 'TrialAcronym';
  $matched_col->{$trial_start_date_col} = 'TrialStartDate';
  $matched_col->{$genotype_col}         = 'GenotypeName';
  $matched_col->{$replicate_num_col}    = 'ReplicateNumber';
  $matched_col->{$block_col}            = 'Block';
  $matched_col->{$column_col}           = 'Column';
  $matched_col->{$row_col}              = 'Row';
  $matched_col->{$barcode_col}          = 'Barcode';

  for (my $i = $trait_data_start_col; $i <= $trait_data_end_col; $i++) {

    $matched_col->{"$i"} = "TraitDataCol$i";
  }

  my $fieldname_list_aref = [];

  for (my $i = 0; $i < $num_of_col; $i++) {

    if ($matched_col->{$i}) {

      push(@{$fieldname_list_aref}, $matched_col->{$i});
    }
    else {

      push(@{$fieldname_list_aref}, 'null');
    }
  }

  my $csv_filehandle;
  open($csv_filehandle, "$data_csv_file") or die "$data_csv_file: $!";

  my $check_empty_col   = 0;
  my $nb_line_wanted    = 1; # just header line
  my $ignore_line0      = 0;
  my $ignore_header     = 0;

  my ($csv_header_err, $csv_header_msg, $csv_header_aref) = csvfh2aref($csv_filehandle,
                                                                       $fieldname_list_aref,
                                                                       $check_empty_col,
                                                                       $nb_line_wanted,
                                                                       $ignore_line0,
                                                                       $ignore_header);

  if ($csv_header_err) {

    $self->logger->debug("Parsing CSV file error: $csv_header_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $csv_header_msg}]};

    return $data_for_postrun_href;
  }

  close($csv_filehandle);

  my $csv_header_href = $csv_header_aref->[0];

  for (my $i = $trait_data_start_col; $i <= $trait_data_end_col; $i++) {

    my $old_colname = $matched_col->{"$i"};
    my $new_colname = $csv_header_href->{"$old_colname"};
    $matched_col->{"$i"} = $new_colname;

    $self->logger->debug("Col ($i) new column name: $new_colname");
  }

  $fieldname_list_aref = [];

  for (my $i = 0; $i < $num_of_col; $i++) {

    if ($matched_col->{$i}) {

      push(@{$fieldname_list_aref}, $matched_col->{$i});
    }
    else {

      push(@{$fieldname_list_aref}, 'null');
    }
  }

  my ($data_aref, $csv_err, $csv_err_msg) = csvfile2arrayref($data_csv_file, $fieldname_list_aref, 0);

  if ($csv_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $csv_err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_write = connect_kdb_write();

  if (! (type_existence($dbh_write, 'sample', $sampletype_value)) ) {

    my $err_msg = "SampleType ($sampletype_value): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'SampleTypeValue' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $row_counter = 1;
  my $final_trial_id;
  my $sql;

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $trialunit_lookup       = {};
  my $trait_lookup           = {};
  my $instance_number_lookup = {};

  my $samplemeasurement_aref = [];

  my $no_data_cell_counter   = 0;
  my $na_cell_counter        = 0;

  for my $csv_row (@{$data_aref}) {

    my ($r_missing_err, $r_missing_msg) = check_missing_value( { 'SiteName'        => $csv_row->{'SiteName'},
                                                                 'SiteYear'        => $csv_row->{'SiteYear'},
                                                                 'TrialTypeName'   => $csv_row->{'TrialTypeName'},
                                                                 'TrialNumber'     => $csv_row->{'TrialNumber'},
                                                                 'TrialStartDate'  => $csv_row->{'TrialStartDate'},
                                                                 'GenotypeName'    => $csv_row->{'GenotypeName'},
                                                                 'ReplicateNumber' => $csv_row->{'ReplicateNumber'},
                                                                 'Column'          => $csv_row->{'Column'},
                                                                 'Row'             => $csv_row->{'Row'},
                                                               });

    if ($r_missing_err) {

      my $err_msg = "Row ($row_counter): $r_missing_msg is missing";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my ($r_int_err, $r_int_msg) = check_integer_value( { 'SiteYear'        => $csv_row->{'SiteYear'},
                                                         'TrialNumber'     => $csv_row->{'TrialNumber'},
                                                         'ReplicateNumber' => $csv_row->{'ReplicateNumber'},
                                                       });

    if ($r_int_err) {

      my $err_msg = "Row ($row_counter): $r_int_msg is not an integer.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $ctrl_char_chk_href = {};

    for (my $i = $trait_data_start_col; $i <= $trait_data_end_col; $i++) {

      my $colname = $matched_col->{"$i"};
      $ctrl_char_chk_href->{$colname} = $csv_row->{$colname};
    }

    # These are control characters which can cause problems.
    my $ctrl_char_reg_exp = '[\x00-\x1f]|\x7f';
    my ($ctrl_char_err, $ctrl_char_msg) = check_char( $ctrl_char_chk_href, $ctrl_char_reg_exp );

    if ($ctrl_char_err) {

      my $err_msg = "Row ($row_counter):  $ctrl_char_msg contains invalid character.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    # check and find the trial id
    if ($row_counter == 1) {

      my $trial_start_date_txt = $csv_row->{'TrialStartDate'};
      my $trial_start_date;

      if ( $trial_start_date_txt =~ /^(\d\d) (\d\d) (\d\d\d\d)$/ ) {

        my $trial_sday   = $1;
        my $trial_smonth = $2;
        my $trial_syear  = $3;

        $trial_start_date = DateTime::Format::MySQL->parse_date("${trial_syear}-${trial_smonth}-${trial_sday}");
        #$self->logger->debug("Trial Start Date: $trial_syear-$trial_smonth-$trial_sday");
      }
      else {

        my $err_msg = "Row ($row_counter): TrialStartDate ($trial_start_date_txt) invalid.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }

      my $site_name      = $csv_row->{'SiteName'};
      my $site_year      = $csv_row->{'SiteYear'};
      my $trialtype_name = $csv_row->{'TrialTypeName'};
      my $trial_number   = $csv_row->{'TrialNumber'};
      my $trial_acronym  = '';

      if (defined $csv_row->{'TrialAcronym'}) {

        $trial_acronym  = $csv_row->{'TrialAcronym'};
      }

      $sql  = 'SELECT trial.TrialId ';
      $sql .= 'FROM (trial LEFT JOIN site ON trial.SiteId = site.SiteId) ';
      $sql .= 'LEFT JOIN generaltype ON trial.TrialTypeId = generaltype.TypeId ';
      $sql .= 'WHERE site.SiteName=? AND year(trial.TrialStartDate)=? ';
      $sql .= 'AND generaltype.TypeName=? AND trial.TrialStartDate=? ';
      $sql .= 'AND trial.TrialNumber=? AND trial.TrialAcronym=?';

      $self->logger->debug("Finding trial params - SiteName: $site_name - SiteYear: $site_year - TrialTypeName: $trialtype_name - TrialStartDate: $trial_start_date - TrialNumber: $trial_number - TrialAcronym: $trial_acronym");

      my ($read_trial_err, $read_trial_msg, $trial_data) = read_data($dbh_write,
                                                                     $sql,
                                                                     [
                                                                      $site_name,
                                                                      $site_year,
                                                                      $trialtype_name,
                                                                      $trial_start_date,
                                                                      $trial_number,
                                                                      $trial_acronym
                                                                     ]
          );

      if ($read_trial_err) {

        $self->logger->debug($read_trial_msg);
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error.'}]};

        return $data_for_postrun_href;
      }

      my $nb_trial_found = scalar(@{$trial_data});
      $self->logger->debug("Number of trial found: $nb_trial_found");

      if ($nb_trial_found == 1) {

        my $found_trial_href = $trial_data->[0];
        if ( (defined $trial_id) ) {

          if ($trial_id != $found_trial_href->{'TrialId'}) {

            if ( !(defined $force) ) {

              my $found_trial_id = $found_trial_href->{'TrialId'};
              my $err_msg = "Found TrialId (found_trial_id): ambiguous with user TrialId ($trial_id).";
              $data_for_postrun_href->{'Error'} = 1;
              $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

              return $data_for_postrun_href;
            }
            else {

              $final_trial_id = $trial_id;
            }
          }
          else {

            $final_trial_id = $trial_id;
          }
        }
        else {

          $final_trial_id = $found_trial_href->{'TrialId'};
        }
      }
      else {

        if ( !(defined $trial_id) ) {

          my $err_msg = "TrialId (user TrialId undefined): ambiguous.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
        else {

          my $matched = 0;

          for my $found_trial_href (@{$trial_data}) {

            if ($trial_id == $found_trial_href->{'TrialId'}) {

              $matched = 1;
              last;
            }
          }

          if ($matched) {

            $final_trial_id = $trial_id
          }
          else {

            my $err_msg = "Trial: ambiguous.";
            $data_for_postrun_href->{'Error'} = 1;
            $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

            return $data_for_postrun_href;
          }
        }
      }

      $self->logger->debug("Final TrialId: $final_trial_id");

      my ($is_trial_ok, $trouble_trial_id_aref) = check_permission($dbh_write, 'trial', 'TrialId',
                                                                   [$final_trial_id], $group_id, $gadmin_status,
                                                                   $READ_WRITE_PERM);

      if (!$is_trial_ok) {

        my $err_msg = "Permission denied: Group ($group_id) and TrialId ($final_trial_id).";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }

      $sql  = 'SELECT trialunit.TrialUnitId, specimen.SpecimenName, trialunit.ReplicateNumber, ';
      $sql .= 'trialunit.TrialUnitBarcode, trialunit.TrialUnitEntryId, trialunit.TrialUnitX, trialunit.TrialUnitY, ';
      $sql .= 'trialunit.TrialUnitZ ';
      $sql .= 'FROM trialunit LEFT JOIN trialunitspecimen ';
      $sql .= 'ON trialunit.TrialUnitId = trialunitspecimen.TrialUnitId ';
      $sql .= 'LEFT JOIN specimen ON trialunitspecimen.SpecimenId = specimen.SpecimenId ';
      $sql .= 'WHERE trialunit.TrialId=? AND (ISNULL(trialunitspecimen.HasDied) = 1 OR trialunitspecimen.HasDied = 0) ';

      $self->logger->debug("SQL: $sql");

      my ($read_tu_err, $read_tu_err_msg, $trial_unit_data) = read_data($dbh_write, $sql, [$final_trial_id]);

      if ($read_tu_err) {

        $self->logger->debug($read_tu_err_msg);
        my $err_msg = "Unexpected Error.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }

      my $nb_trial_unit = scalar(@{$trial_unit_data});

      if ($nb_trial_unit == 0) {

        my $err_msg = "No trial unit from database.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }

      $self->logger->debug("Number of trial units: $nb_trial_unit");

      for my $trial_unit_rec (@{$trial_unit_data}) {

        my $specimen_name = trim($trial_unit_rec->{'SpecimenName'});
        my $rep_num       = trim($trial_unit_rec->{'ReplicateNumber'});
        my $tu_barcode    = trim($trial_unit_rec->{'TrialUnitBarcode'});

        my $column_val    = $trial_unit_rec->{$column_colname};
        my $row_val       = $trial_unit_rec->{$row_colname};
        my $block_val     = $trial_unit_rec->{$block_colname};

        my $dk_unitposition_txt = "ROW${row_val} __ COL${column_val} __ BLOCK${block_val}";
        $dk_unitposition_txt   .= "$specimen_name" . "REP$rep_num" . "BCODE$tu_barcode";

        $self->logger->debug("Recalc DK UnitPosition Text: $dk_unitposition_txt");

        if ( !(defined $trialunit_lookup->{$dk_unitposition_txt}) ) {

          $trialunit_lookup->{$dk_unitposition_txt} = $trial_unit_rec;
        }
        else {

          $self->logger->debug("Completely duplicate trial unit $dk_unitposition_txt");

          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error.'}]};

          return $data_for_postrun_href;
        }
      }

      $sql  = 'SELECT trialtrait.TraitId, trait.TraitName ';
      $sql .= 'FROM trialtrait LEFT JOIN trait ON ';
      $sql .= 'trialtrait.TraitId = trait.TraitId ';
      $sql .= 'WHERE trialtrait.TrialId=?';

      my ($read_trait_err, $read_trait_msg, $trait_data) = read_data($dbh_write, $sql, [$final_trial_id]);

      if ($read_trait_err) {

        $self->logger->debug($read_trait_msg);
        my $err_msg = "Unexpected Error.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }

      for my $trait_rec (@{$trait_data}) {

        $trait_lookup->{$trait_rec->{'TraitName'}} = $trait_rec->{'TraitId'};
      }
    }

    my $block_val  = trim($csv_row->{'Block'});
    my $column_val = trim($csv_row->{'Column'});
    my $row_val    = trim($csv_row->{'Row'});

    my $file_replicate_number = trim($csv_row->{'ReplicateNumber'});
    my $file_genotype_name    = trim($csv_row->{'GenotypeName'});
    my $file_barcode          = trim($csv_row->{'Barcode'});

    my $dk_file_unitposition_txt = "ROW${row_val} __ COL${column_val} __ BLOCK${block_val}";

    $dk_file_unitposition_txt   .= "$file_genotype_name" . "REP$file_replicate_number" . "BCODE$file_barcode";

    $self->logger->debug("DK file UnitPosition Text: $dk_file_unitposition_txt");

    if ( !(defined $trialunit_lookup->{$dk_file_unitposition_txt}) ) {

      my $err_msg = "Row ($row_counter): trial unit ($dk_file_unitposition_txt) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $db_trial_unit = {};

    if (defined($trialunit_lookup->{$dk_file_unitposition_txt})) {

      $self->logger->debug("Found trial unit");
      $db_trial_unit = $trialunit_lookup->{$dk_file_unitposition_txt};
    }
    else {

      $self->logger->debug("Cannot find trial unit from: $dk_file_unitposition_txt");
      my $err_msg = "Unexpected Error.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $db_replicate_number = $db_trial_unit->{'ReplicateNumber'};
    my $db_genotype_name    = trim($db_trial_unit->{'SpecimenName'});
    my $db_barcode          = trim($db_trial_unit->{'TrialUnitBarcode'});

    if ($db_replicate_number != $file_replicate_number) {

      my $rep_diff_txt = "(DB: $db_replicate_number, File: $file_replicate_number)";
      my $err_msg = "Row ($row_counter): trial unit mismatched on replicate number $rep_diff_txt.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if ($db_genotype_name ne $file_genotype_name) {

      my $geno_diff_txt = "(DB: $db_genotype_name, File: $file_genotype_name)";
      my $err_msg = "Row ($row_counter): trial unit mismatched on genotype name $geno_diff_txt.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if (length($db_barcode) > 0) {

      if ($db_barcode ne $file_barcode) {

        my $barcode_diff_txt = "(DB: $db_barcode, File: $file_barcode)";
        my $err_msg = "Row ($row_counter): trial unit mismatched on barcode $barcode_diff_txt.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }

    my $trial_unit_id = $db_trial_unit->{'TrialUnitId'};

    my $samplemeasurement_rec_in_row = {};

    $self->logger->debug("Trait Data End Col: $trait_data_end_col");

    for (my $i = $trait_data_start_col; $i <= $trait_data_end_col; $i++) {

      my $colname = $matched_col->{"$i"};

      if ($colname =~ /^Date_(.+)/) {

        my $trait_name = $1;
        $trait_name =~ s/__\d+//g;

        $self->logger->debug("Colname: $colname");

        # remove trailing \r left over from from carriage return line feed used in Windows
        my $measure_datetime_txt = trim($csv_row->{$colname});
        my $measure_datetime;

        if (length($measure_datetime_txt) == 0) {

          next;
        }

        my $day;
        my $month;
        my $year;
        my $hour   = 0;
        my $minute = 0;

        my $second = 0;

        my $known_date_format = 0;

        if ($measure_datetime_txt =~ /(\d\d)\/(\d\d)\/(\d\d) (\d\d)\:(\d\d)\:?(\d\d)?/) {

          $self->logger->debug("MeasureDateTime dd/mm/yy hh:mm:ss");

          $day    = $1;
          $month  = $2;
          $year   = $3;
          $hour   = $4;
          $minute = $5;

          if (defined($6)) {

            $second = $6;
          }

          $year = "20$year";

          $known_date_format = 1;
        }
        elsif ($measure_datetime_txt =~ /(\d{4})\-(\d{2})\-(\d{2})\s?(\d{2})?\:?(\d{2})?\:?(\d{2})?/) {

          $self->logger->debug("MeasureDateTime yyyy-mm-dd hh:mm:ss");

          $day    = $3;
          $month  = $2;
          $year   = $1;

          if (defined($4)) {

            $hour = $4;
          }

          if (defined($5)) {

            $minute = $5;
          }

          if (defined($6)) {

            $second = $6;
          }

          $known_date_format = 1;
        }

        if ($known_date_format) {

          $measure_datetime = DateTime->new(
            year        => $year,
            month       => $month,
            day         => $day,
            hour        => $hour,
            minute      => $minute,
            second      => $second
              );
        }

        if ( !(defined $measure_datetime) ) {

          my $err_msg = "Row ($row_counter): MeasureDateTime ($measure_datetime_txt): unknown format.";
          $self->logger->debug($err_msg);

          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }

        my $measure_datetime_mysql = DateTime::Format::MySQL->format_datetime($measure_datetime);

        # in order to merge date and other field into one hash
        $colname =~ s/Date_//g;

        my $samplemeasurement_rec = {};
        if (defined $samplemeasurement_rec_in_row->{$colname}) {

          $samplemeasurement_rec = $samplemeasurement_rec_in_row->{$colname};
        }

        $samplemeasurement_rec->{'MeasureDateTime'} = $measure_datetime_mysql;
        $samplemeasurement_rec_in_row->{$colname} = $samplemeasurement_rec;
      }
      else {

        my $trait_name  = $colname;
        $trait_name  =~ s/__\d+//g;

        if ( !(defined $trait_lookup->{$trait_name}) ) {

          my $err_msg = "Trait ($trait_name): not found.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }

        my $trait_id = $trait_lookup->{$trait_name};

        my $ins_num_key1 = "TrialId${final_trial_id}$colname";
        my $ins_num_key2 = "TrialId${final_trial_id}TraitId${trait_id}";

        my $instance_num = 0;

        if (defined $instance_number_lookup->{$ins_num_key1}) {

          $instance_num = $instance_number_lookup->{$ins_num_key1};
        }
        else {

          if (defined $instance_number_lookup->{$ins_num_key2}) {

            $instance_num = $instance_number_lookup->{$ins_num_key2};
            $instance_number_lookup->{$ins_num_key1} = $instance_num;

            # The instance for the trait has been used. So the instance number must be increment
            $instance_number_lookup->{$ins_num_key2} += 1;
          }
          else {

            $sql  = 'SELECT InstanceNumber ';
            $sql .= 'FROM samplemeasurement LEFT JOIN trialunit ';
            $sql .= 'ON samplemeasurement.TrialUnitId = trialunit.TrialUnitId ';
            $sql .= 'WHERE TraitId=? AND TrialId=? ';
            $sql .= 'ORDER BY InstanceNumber DESC ';
            $sql .= 'LIMIT 1';

            my ($read_err, $db_instance_num) = read_cell($dbh_write, $sql, [$trait_id, $final_trial_id]);

            if ($read_err) {

              $self->logger->debug("Read instance number SQL error.");
              my $err_msg = "Unexpected Error.";
              $data_for_postrun_href->{'Error'} = 1;
              $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

              return $data_for_postrun_href;
            }

            if (length($db_instance_num) == 0) {

              $db_instance_num = 0;
            }
            else {

              $db_instance_num += 1;
            }

            $instance_num = $db_instance_num;

            # Instance number for the column name which includes the file instance number.
            # All trait value under the same column name would use this instance nubmer straight.
            $instance_number_lookup->{$ins_num_key1} = $db_instance_num;

            # The next instance number for the trait in this trial (final_trial_id) which is available
            # for use. When the instance number of a new column name is not found from ins_num_key1
            # lookup, the code will lookup the instance number using ins_num_key2. If the instance number
            # is not found, it will lookup from the database using TrialId and TraitId.
            $instance_number_lookup->{$ins_num_key2} = $db_instance_num + 1;
          }
        }

        if ( !(defined $csv_row->{$colname}) ) {

          $self->logger->debug("$row_counter: empty cell");

          $no_data_cell_counter += 1;
          next;
        }

        my $trait_value = $csv_row->{$colname};

        my $samplemeasurement_rec = {};
        if (defined $samplemeasurement_rec_in_row->{$colname}) {

          $samplemeasurement_rec = $samplemeasurement_rec_in_row->{$colname};
        }

        $self->logger->debug("Instance Number: $instance_num");

        $samplemeasurement_rec->{'TraitId'}        = $trait_id;
        $samplemeasurement_rec->{'SampleTypeId'}   = $sampletype_value;
        $samplemeasurement_rec->{'InstanceNumber'} = $instance_num;
        $samplemeasurement_rec->{'TraitValue'}     = $trait_value;
        $samplemeasurement_rec->{'TrialUnitId'}    = $trial_unit_id;

        $samplemeasurement_rec_in_row->{$colname} = $samplemeasurement_rec;
      }
    }

    for my $colname (keys(%{$samplemeasurement_rec_in_row})) {

      my $samplemeasurement_rec = $samplemeasurement_rec_in_row->{$colname};

      if ( (length($samplemeasurement_rec->{'TraitValue'}) == 0) ||
           (length($samplemeasurement_rec->{'TraitId'}) == 0) ) {

        next;
      }

      if (length($samplemeasurement_rec->{'MeasureDateTime'}) == 0) {

        my $cur_dt = DateTime->now( time_zone => $TIMEZONE );
        $samplemeasurement_rec->{'MeasureDateTime'} = DateTime::Format::MySQL->format_datetime($cur_dt);
      }

      push(@{$samplemeasurement_aref}, $samplemeasurement_rec);
    }

    $row_counter += 1;
  }

  if (scalar(@{$samplemeasurement_aref}) == 0) {

    $self->logger->debug("NO samplemeasurement record matched.");
    my $err_msg = "Unexpected Error: no matched data";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $check_non_trait_field = 0;
  my $validate_trait_value  = 1;
  $data_for_postrun_href = $self->insert_samplemeasurement_data($dbh_write,
                                                                $samplemeasurement_aref,
                                                                $check_non_trait_field,
                                                                $validate_trait_value
      );

  $dbh_write->disconnect();

  if ($data_for_postrun_href->{'Error'}) {

    return $data_for_postrun_href;
  }
  else {

    my $info_href = $data_for_postrun_href->{'Data'}->{'Info'}->[0];
    $info_href->{'NumOfEmptyCell'} = $no_data_cell_counter;
    $info_href->{'NumOfNACell'}    = $na_cell_counter;

    $data_for_postrun_href->{'Data'} = {'Info' => [$info_href]};

    return $data_for_postrun_href;
  }
}

sub insert_samplemeasurement_data {

  my $self                = $_[0];
  my $dbh_write           = $_[1];
  my $data_aref           = $_[2];
  my $chk_non_trait_field = $_[3];
  my $validate_trait      = $_[4];

  my $enforce_single_trial_data = 0;

  if (defined $_[5]) {

    $enforce_single_trial_data = $_[5];
  }

  my $smgroup_id = 0;

  if (defined $_[6]) {

    $smgroup_id = $_[6];
  }

  my $global_trial_id = undef;

  if (defined $_[7]) {

    $global_trial_id = $_[7];
  }

  my $data_for_postrun_href = {};

  my $user_id       = $self->authen->user_id();
  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str      = permission_phrase($group_id, 0, $gadmin_status);

  if (scalar(@{$data_aref}) == 0) {

    $self->logger->debug("No data provided");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $bulk_sql = 'INSERT INTO samplemeasurement ';
  $bulk_sql   .= '(TrialUnitId,SampleTypeId,SMGroupId,TraitId,OperatorId,MeasureDateTime,InstanceNumber,TraitValue,TrialUnitSpecimenId,StateReason) ';
  $bulk_sql   .= 'VALUES ';

  my $sql;
  my $sth;

  my $uniq_tunit_href         = {};
  my $tunit_val_aref          = [];
  my $tunit_idx_aref          = [];

  my $uniq_sam_type_href      = {};
  my $sam_type_val_aref       = [];
  my $sam_type_idx_aref       = [];

  my $uniq_trait_id_href      = {};
  my $trait_id_val_aref       = [];
  my $trait_id_idx_aref       = [];

  my $tu_trait_id_val_aref    = [];
  my $tu_trait_id_idx_aref    = [];

  my $uniq_operator_href      = {};
  my $operator_val_aref       = [];
  my $operator_idx_aref       = [];

  my $tu_tu_spec_val_aref     = [];
  my $tu_tu_spec_idx_aref     = [];

  my $trait_id2val_href       = {};
  my $trait_id2idx_href       = {};

  my $row_counter = 1;
  for my $data_row (@{$data_aref}) {

    my $effective_user_id = $user_id;
    my $trialunit_id      = $data_row->{'TrialUnitId'};
    my $samp_type_id      = $data_row->{'SampleTypeId'};
    my $trait_id          = $data_row->{'TraitId'};

    my $tu_spec_id        = '0';

    $uniq_trait_id_href->{$trait_id}     = 1;
    $uniq_sam_type_href->{$samp_type_id} = 1;

    if ($chk_non_trait_field) {

      my ($int_id_err, $int_id_msg) = check_integer_value( { 'TrialUnitId'    => $data_row->{'TrialUnitId'},
                                                             'SampleTypeId'   => $data_row->{'SampleTypeId'},
                                                             'TraitId'        => $data_row->{'TraitId'},
                                                             'InstanceNumber' => $data_row->{'InstanceNumber'},
                                                           });

      if ($int_id_err) {

        $int_id_msg = "Row ($row_counter): " . $int_id_msg . ' not integer.';
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $int_id_msg}]};

        return $data_for_postrun_href;
      }

      if (length($data_row->{'OperatorId'}) > 0) {

        my $operator_id = $data_row->{'OperatorId'};

        my ($int_err, $int_msg) = check_integer_value( { 'OperatorId' => $operator_id } );

        if ($int_err) {

          $int_msg = "Row ($row_counter): " . $int_msg . ' not an integer.';
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $int_msg}]};

          return $data_for_postrun_href;
        }

        $uniq_operator_href->{$operator_id} = 1;
        push(@{$operator_val_aref}, $operator_id);
        push(@{$operator_idx_aref}, $row_counter);

        $effective_user_id = $operator_id;
      }
    }

    $uniq_tunit_href->{$trialunit_id} = 1;
    push(@{$tunit_val_aref}, $trialunit_id);
    push(@{$tunit_idx_aref}, $row_counter);

    push(@{$tu_trait_id_val_aref}, [$trialunit_id, $trait_id]);
    push(@{$tu_trait_id_idx_aref}, $row_counter);

    if (length($data_row->{'OperatorId'}) > 0) {

      $effective_user_id = $data_row->{'OperatorId'};
    }

    if (defined $data_row->{'TrialUnitSpecimenId'}) {

      if (length($data_row->{'TrialUnitSpecimenId'}) > 0) {

        $tu_spec_id = $data_row->{'TrialUnitSpecimenId'};

        push(@{$tu_tu_spec_val_aref}, [$trialunit_id, $tu_spec_id]);
        push(@{$tu_tu_spec_idx_aref}, $row_counter);
      }
    }

    my $trait_val = $data_row->{'TraitValue'};
    my $db_trait_val = $dbh_write->quote($trait_val);

    if ($validate_trait) {

      if (defined $trait_id2val_href->{$trait_id}) {

        my $val_aref = $trait_id2val_href->{$trait_id};
        push(@{$val_aref}, $trait_val);
        $trait_id2val_href->{$trait_id} = $val_aref;
      }
      else {

        $trait_id2val_href->{$trait_id} = [$trait_val];
      }

      if (defined $trait_id2idx_href->{$trait_id}) {

        my $idx_aref = $trait_id2idx_href->{$trait_id};
        push(@{$idx_aref}, $row_counter);
        $trait_id2idx_href->{$trait_id} = $idx_aref;
      }
      else {

        $trait_id2idx_href->{$trait_id} = [$row_counter];
      }
    }

    my $measure_dt   = $data_row->{'MeasureDateTime'};

    # Check measure date/time

    my ($measure_dt_err, $measure_dt_msg) = check_dt_value( {'MeasureDateTime' => $measure_dt} );

    if ($measure_dt_err) {

      my $err_msg = "Row ($row_counter): $measure_dt not valid date/time.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    # End check measure date/time

    my $instance_num = $data_row->{'InstanceNumber'};

    my $state_reason      = 'NULL';

    if (defined $data_row->{'StateReason'}) {

      if (length($data_row->{'StateReason'}) > 0) {

        $state_reason = $dbh_write->quote($data_row->{'StateReason'});
      }
    }

    $bulk_sql .= "($trialunit_id,$samp_type_id,$smgroup_id,$trait_id,$effective_user_id,";
    $bulk_sql .= "'$measure_dt',$instance_num,$db_trait_val,$tu_spec_id,$state_reason),";

    $row_counter += 1;
  }

  chop($bulk_sql);      # remove excessive comma

  #

  my @trait_id_list = keys(%{$uniq_trait_id_href});

  if (scalar(@trait_id_list) == 0) {

    $self->logger->debug("List of trait id is empty");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  # Release the memorny
  $uniq_trait_id_href = {};

  $sql  = "SELECT TraitId, $perm_str AS UltimatePerm ";
  $sql .= "FROM trait ";
  $sql .= "WHERE TraitId IN (" . join(',', @trait_id_list) . ')';

  my $trait_lookup = $dbh_write->selectall_hashref($sql, 'TraitId');

  if ($dbh_write->err()) {

    $self->logger->debug("Get trait info failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my @tu_id_list = keys(%{$uniq_tunit_href});

  if (scalar(@tu_id_list) == 0) {

    $self->logger->debug("List of trial unit id is empty");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  # Release the memory
  $uniq_tunit_href = {};

  $sql  = "SELECT trialunit.TrialUnitId, trial.TrialId, $perm_str AS UltimatePerm, ";
  $sql .= "TraitId, TrialUnitSpecimenId ";
  $sql .= "FROM trialunit LEFT JOIN trial ON trialunit.TrialId = trial.TrialId ";
  $sql .= "LEFT JOIN trialunitspecimen ON trialunit.TrialUnitId = trialunitspecimen.TrialUnitId ";
  $sql .= "LEFT JOIN trialtrait ON trial.TrialId = trialtrait.TrialId ";
  $sql .= "WHERE trialunit.TrialUnitId IN (" . join(',', @tu_id_list) . ')';

  my $trialunit_info_href = {};

  my ($r_tu_err, $r_tu_msg, $tu_data) = read_data($dbh_write, $sql, []);

  if ($r_tu_err) {

    $self->logger->debug("Get trial unit info failed: $r_tu_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $uniq_trial_href = {};

  foreach my $tu_rec (@{$tu_data}) {

    my $tu_id      = $tu_rec->{'TrialUnitId'};
    my $trial_id   = $tu_rec->{'TrialId'};
    my $trial_perm = $tu_rec->{'UltimatePerm'};
    my $trait_id   = $tu_rec->{'TraitId'};
    my $tu_spec_id = $tu_rec->{'TrialUnitSpecimenId'};

    $uniq_trial_href->{$trial_id} = 1;

    if (! defined $trialunit_info_href->{$tu_id}) {

      $trialunit_info_href->{$tu_id} = {};
    }

    $trialunit_info_href->{$tu_id}->{'TrialId'}       = $trial_id;
    $trialunit_info_href->{$tu_id}->{'Permission'}    = $trial_perm;

    if (! defined $trialunit_info_href->{$tu_id}->{'TraitInfo'}) {

      $trialunit_info_href->{$tu_id}->{'TraitInfo'} = {};
    }

    $trialunit_info_href->{$tu_id}->{'TraitInfo'}->{$trait_id} = 1;

    if (! defined $trialunit_info_href->{$tu_id}->{'TrialUnitSpecInfo'}) {

      $trialunit_info_href->{$tu_id}->{'TrialUnitSpecInfo'} = {};
    }

    $trialunit_info_href->{$tu_id}->{'TrialUnitSpecInfo'}->{$tu_spec_id} = 1;
  }

  if ($enforce_single_trial_data == 1) {

    my @data_trial_list = keys(%{$uniq_trial_href});

    if (scalar(@data_trial_list) > 1) {

      my $err_msg = "Data from more than one trial not allowed.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    elsif (scalar(@data_trial_list) == 1) {

      if ($data_trial_list[0] != $global_trial_id) {

        my $err_msg = "TrialId derived from upload data and TrialId provided via interface are not the same.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
  }

  for (my $i = 0; $i < scalar(@{$tunit_val_aref}); $i++) {

    my $tu_id    = $tunit_val_aref->[$i];
    my $row_num  = $tunit_idx_aref->[$i];

    if (! defined $trialunit_info_href->{$tu_id}) {

      my $err_msg = "Row ($row_num): TrialUnit ($tu_id) does not exist.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $trial_id         = $trialunit_info_href->{$tu_id}->{'TrialId'};
    my $trial_permission = $trialunit_info_href->{$tu_id}->{'Permission'};

    if ( ($trial_permission & $READ_WRITE_PERM) != $READ_WRITE_PERM ) {

      my $perm_err_msg = "Row ($row_num): Permission denied, Group ($group_id) and Trial ($trial_id).";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $perm_err_msg}]};

      return $data_for_postrun_href;
    }
  }

  for (my $i = 0; $i < scalar(@{$tu_trait_id_val_aref}); $i++) {

    my $row_num   = $tu_trait_id_idx_aref->[$i];
    my $tu_id     = $tu_trait_id_val_aref->[$i]->[0];
    my $trait_id  = $tu_trait_id_val_aref->[$i]->[1];

    if ( ! defined $trait_lookup->{$trait_id} ) {

      my $err_msg = "Row ($row_num): Trait ($trait_id) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $trait_perm = $trait_lookup->{$trait_id}->{'UltimatePerm'};

    if ( ($trait_perm & $LINK_PERM) != $LINK_PERM ) {

      my $perm_err_msg = "Row ($row_num): Permission denied, Group ($group_id) and Trait ($trait_id).";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $perm_err_msg}]};

      return $data_for_postrun_href;
    }

    if ( ! defined $trialunit_info_href->{$tu_id}->{'TraitInfo'}->{$trait_id} ) {

      my $trial_id = $trialunit_info_href->{$tu_id}->{'TrialId'};

      my $err_msg = "Row ($row_counter): Trait ($trait_id) is not attached to Trial ($trial_id).";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @operator_list = keys(%{$uniq_operator_href});

  if (scalar(@operator_list) > 0) {

    $sql = "SELECT UserId FROM systemuser WHERE UserId IN (" . join(',', @operator_list) . ")";

    my $operator_lookup = $dbh_write->selectall_hashref($sql, 'UserId');

    if ($dbh_write->err()) {

      $self->logger->debug("Get operator info failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    for (my $i = 0; $i < scalar(@{$operator_val_aref}); $i++) {

      my $oper_id  = $operator_val_aref->[$i];
      my $row_num  = $operator_idx_aref->[$i];

      if (! defined $operator_lookup->{$oper_id}) {

        my $err_msg = "Row ($row_num): Operator ($oper_id) does not exist.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
  }

  my @sample_type_list = keys(%{$uniq_sam_type_href});

  if (scalar(@sample_type_list) == 0) {

    $self->logger->debug("List of sample type id is empty");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sql  = "SELECT TypeId FROM generaltype WHERE Class='sample' AND ";
  $sql .= "TypeId IN (" . join(',', @sample_type_list) . ")";

  my $sample_type_lookup = $dbh_write->selectall_hashref($sql, 'TypeId');

  if ($dbh_write->err()) {

    $self->logger->debug("Get sample type info failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  for (my $i = 0; $i < scalar(@{$sam_type_val_aref}); $i++) {

    my $sam_type_id = $sam_type_val_aref->[$i];
    my $row_num     = $sam_type_idx_aref->[$i];

    if (! defined $sample_type_lookup->{$sam_type_id}) {

      my $err_msg = "Row ($row_num): SampleType ($sam_type_id) does not exist.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  for (my $i = 0; $i < scalar(@{$tu_tu_spec_val_aref}); $i++) {

    my $tu_id      = $tu_tu_spec_val_aref->[$i]->[0];
    my $tu_spec_id = $tu_tu_spec_val_aref->[$i]->[1];
    my $row_num    = $tu_tu_spec_idx_aref->[$i];

    my $tu_spec_href = $trialunit_info_href->{$tu_id}->{'TrialUnitSpecInfo'};

    if (! defined $tu_spec_href->{$tu_spec_id}) {

      my $err_msg = "Row ($row_num): TrialUnit ($tu_id) and TrialUnitSpecimen ($tu_spec_id) not compatible.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  # Release memory
  $tu_tu_spec_val_aref = [];
  $tu_tu_spec_idx_aref = [];
  $trialunit_info_href = {};

  my ($v_trait_val_err, $v_trait_val_msg,
      $v_trait_id, $v_trait_idx) = validate_trait_db_bulk($dbh_write, $trait_id2val_href);

  if ($v_trait_val_err) {

    $self->logger->debug("Validation error on TraitId: $v_trait_id - index: $v_trait_idx");
    my $row_num = $trait_id2idx_href->{$v_trait_id}->[$v_trait_idx];
    my $err_msg = "Row ($row_num): $v_trait_val_msg";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  #

  $self->logger->debug("Bulk SQL: $bulk_sql");

  my $nrows_inserted = $dbh_write->do($bulk_sql);

  if ($dbh_write->err()) {

    $self->logger->debug("Db err code: " . $dbh_write->err());

    if ($dbh_write->err() == 1062) {

      my $err_str = $dbh_write->errstr();

      $err_str =~ /Duplicate entry '(.+)'/;
      my $err_msg = "Duplicate Entry: $1";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    else {

      $self->logger->debug('Error code: ' . $dbh_write->err());
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }
  }

  my $info_msg = "$nrows_inserted records of samplemeasurement have been inserted successfully.";
  my $info_msg_aref = [{'Message' => $info_msg}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub export_datakapture_data_runmode {

=pod export_datakapture_data_HELP_START
{
"OperationName": "Export trial data",
"Description": "Exports current phenotypic data for the trial.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info MaxInstanceNumber='3' NumOfTrialUnit='64' /><OutputFile csv='http://kddart-d.diversityarrays.com/data/admin/export_dkdata_7_9b96633c51925e8c74f2b87bdc10c785.csv' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'MaxInstanceNumber' : 3, 'NumOfTrialUnit' : 64}], 'OutputFile' : [{'csv' : 'http://kddart-d.diversityarrays.com/data/admin/export_dkdata_7_9b96633c51925e8c74f2b87bdc10c785.csv'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='SampleType (143) invalid.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'SampleType (143) invalid.'}]}"}],
"HTTPParameter": [{"Required": 0, "Name": "BlockColName", "Description": "Prefix text for Block in the UnitPosition used in the trial specified in the URLParameter"}, {"Required": 1, "Name": "ColumnColName", "Description": "Prefix text for Column in the UnitPosition used in the trial specified in the URLParameter"}, {"Required": 1, "Name": "RowColName", "Description": "Prefix text for Row in the UnitPosition used in the trial specified in the URLParameter"}, {"Required": 1, "Name": "SampleTypeId", "Description": "Value for SampleTypeId. This value is needed to restrict the data in 2-dimensional."}, {"Required": 0, "Name": "TraitIdCSV", "Description": "Filtering parameter for TraitId. This parameter takes a comma separated value of valid TraitId"}, {"Required": 0, "Name": "InstanceNumberCSV", "Description": "Filtering parameter for InstanceNumber. This parameter takes a comma separated value of valid InstanceNumber"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $trial_id       = $self->param('id');
  my $sample_type_id = $query->param('SampleTypeId');

  my $trait_id_csv   = '';

  if (defined $query->param('TraitIdCSV')) {

    if (length($query->param('TraitIdCSV')) > 0) {

      $trait_id_csv = $query->param('TraitIdCSV');
    }
  }

  my $instance_num_csv = '';

  if (defined $query->param('InstanceNumberCSV')) {

    if (length($query->param('InstanceNumberCSV')) > 0) {

      $instance_num_csv = $query->param('InstanceNumberCSV');
    }
  }

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  my $trial_exist = record_existence($dbh, 'trial', 'TrialId', $trial_id);

  if (!$trial_exist) {

    my $err_msg = "Trial ($trial_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TrialId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $unitposition_block  = '';

  if (length($query->param('BlockColName')) > 0) {

    $unitposition_block = $query->param('BlockColName');
  }

  my $unitposition_column = $query->param('ColumnColName');
  my $unitposition_row    = $query->param('RowColName');

  my ($missing_err, $missing_href) = check_missing_href( {'SampleTypeId'  => $sample_type_id,
                                                          'ColumnColName' => $unitposition_column,
                                                          'RowColName'    => $unitposition_row,
                                                         } );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  my $acceptable_dimension_fieldname_lookup = {'TrialUnitEntryId' => 1,
                                               'TrialUnitX'       => 1,
                                               'TrialUnitY'       => 1,
                                               'TrialUnitZ'       => 1,
                                              };

  my $chk_dimension_fieldname_href = {
                                      'ColumnColName' => $unitposition_column,
                                      'RowColName'    => $unitposition_row,
                                      'BlockColName'  => $unitposition_block
                                     };

  my ($di_val_err, $di_val_href) = check_value_href( $chk_dimension_fieldname_href, $acceptable_dimension_fieldname_lookup );

  if ($di_val_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$di_val_href]};

    return $data_for_postrun_href;
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_trial_ok, $trouble_trial_id_aref) = check_permission($dbh, 'trial', 'TrialId',
                                                               [$trial_id], $group_id, $gadmin_status,
                                                               $READ_PERM);

  if (!$is_trial_ok) {

    my $trouble_trial_id = $trouble_trial_id_aref->[0];
    my $err_msg = "Permission denied: Group ($group_id) and trial ($trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TrialId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (!(type_existence($dbh, 'sample', $sample_type_id)) ){

    my $err_msg = "SampleType ($sample_type_id) invalid.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT DISTINCT trialtrait.TraitId FROM trialtrait ';
  $sql   .= 'LEFT JOIN samplemeasurement ON trialtrait.TraitId=samplemeasurement.TraitId ';
  $sql   .= 'WHERE TrialId=? AND SampleTypeId=? ';
  $sql   .= 'GROUP BY trialtrait.TraitId';

  my ($get_trait_id_err, $get_trait_id_msg, $trait_id_aref) = read_data($dbh, $sql, [$trial_id, $sample_type_id]);

  if ($get_trait_id_err) {

    $self->logger->debug("Get TraitId from trialtrait failed: $get_trait_id_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error.'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$trait_id_aref}) == 0) {

    my $err_msg = "No trait attached to Trial ($trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trait_id_lookup = {};

  for my $trait_rec (@{$trait_id_aref}) {

    $trait_id_lookup->{$trait_rec->{'TraitId'}} = 1;
  }

  my @trait_id_list;

  if (length($trait_id_csv) > 0) {

    @trait_id_list = split(',', $trait_id_csv);

    for my $sel_trait_id (@trait_id_list) {

      if ( !(defined $trait_id_lookup->{$sel_trait_id}) ) {

        my $err_msg = "Selected trait ($sel_trait_id) not found in trial ($trial_id).";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
  }
  else {

    @trait_id_list = keys(%{$trait_id_lookup});
  }

  my ($is_trait_ok, $trouble_trait_id_aref) = check_permission($dbh, 'trait', 'TraitId',
                                                               \@trait_id_list, $group_id, $gadmin_status,
                                                               $READ_PERM);

  if (!$is_trait_ok) {

    my $trouble_trait = join(',', @{$trouble_trial_id_aref});
    my $err_msg = "Permission denied: Group ($group_id) and trait ($trouble_trait).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trait_where = ' AND TraitId IN (' . join(',', @trait_id_list) . ')';

  $self->logger->debug("Trait where: $trait_where");

  my $check_sample_type_id_sql = 'SELECT SampleTypeId FROM samplemeasurement ';
  $check_sample_type_id_sql   .= 'LEFT JOIN trialunit ON samplemeasurement.TrialUnitId = trialunit.TrialUnitId ';
  $check_sample_type_id_sql   .= "WHERE TrialId=? AND SampleTypeId=? $trait_where";

  my ($r_samptype_id_err, $db_sample_type_id) = read_cell($dbh, $check_sample_type_id_sql, [$trial_id, $sample_type_id]);

  if (length($db_sample_type_id) == 0) {

    my $err_msg = "SampleType ($sample_type_id) not found in Trial ($trial_id)";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'SampleTypeId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql  = 'SELECT InstanceNumber ';
  $sql .= 'FROM samplemeasurement LEFT JOIN trialunit ON samplemeasurement.TrialUnitId = trialunit.TrialUnitId ';
  $sql .= "WHERE TrialId=? AND SampleTypeId=? $trait_where ";
  $sql .= 'GROUP BY InstanceNumber';

  my ($get_inst_num_err, $get_inst_num_msg, $inst_num_aref) = read_data($dbh, $sql, [$trial_id, $sample_type_id]);

  if ($get_inst_num_err) {

    $self->logger->debug("Get instance number failed: $get_inst_num_msg");
    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'SampleTypeId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $instance_num_lookup = {};

  for my $inst_num_rec (@{$inst_num_aref}) {

    $instance_num_lookup->{$inst_num_rec->{'InstanceNumber'}} = 1;
  }

  my @instance_num_list;

  if (length($instance_num_csv) > 0) {

    @instance_num_list = split(',', $instance_num_csv);

    for my $sel_inst_num (@instance_num_list) {

      if ( !(defined $instance_num_lookup->{$sel_inst_num}) ) {

        my $err_msg = "Selected instance ($sel_inst_num): not found.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
  }
  else {

    @instance_num_list = keys(%{$instance_num_lookup});
  }

  my ($tdata_sql_err,
      $tdata_sql_msg, $tdata_sql,
      $tfield_order_aref, $max_instance_number) = samplemeasure_row2col($dbh,
                                                                        $trial_id,
                                                                        $sample_type_id,
                                                                        \@trait_id_list,
                                                                        \@instance_num_list,
          );

  $self->logger->debug("Trait field order: " . join(',', @{$tfield_order_aref}));

  if ($tdata_sql_err) {

    $self->logger->debug("Generate samplemeasurement row into column SQL failed: $tdata_sql_msg");
    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("Trait DATA SQL: $tdata_sql");

  my $md5               = md5_hex($tdata_sql);

  my $username          = $self->authen->username();
  my $doc_root          = $ENV{'DOCUMENT_ROOT'};
  my $export_data_path  = "${doc_root}/data/$username";
  my $current_runmode   = $self->get_current_runmode();
  my $filename          = "export_dkdata_${trial_id}_$md5";
  my $csv_file          = "${export_data_path}/${filename}.csv";

  if ( !(-e $export_data_path) ) {

    mkdir($export_data_path);
  }

  my ($read_tdata_err, $read_tdata_msg, $trial_data_aref) = read_data($dbh, $tdata_sql, [$trial_id, $sample_type_id]);

  if ($read_tdata_err) {

    $self->logger->debug("$read_tdata_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error.'}]};

    return $data_for_postrun_href;
  }

  my $trial_data_href = {};

  for my $trial_data_rec (@{$trial_data_aref}) {

    my $trial_unit_id = $trial_data_rec->{'TrialUnitId'};
    $trial_data_href->{$trial_unit_id} = $trial_data_rec;
  }

  if (scalar(@{$trial_data_aref}) == 0) {

    my $err_msg = "Trial ($trial_id): no data.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql    = 'SELECT trial.TrialId, site.SiteName, site.SiteStartDate, generaltype.TypeName as TrialTypeName, ';
  $sql   .= 'trial.TrialNumber, trial.TrialAcronym, trial.TrialStartDate, trialunit.TrialUnitPosition, ';
  $sql   .= 'trialunit.TrialUnitEntryId, trialunit.TrialUnitX, trialunit.TrialUnitY, trialunit.TrialUnitZ, ';
  $sql   .= 'trialunit.TrialUnitNote, trialunit.TrialUnitId, trialunit.ReplicateNumber, ';
  $sql   .= 'trialunit.TrialUnitBarcode ';
  $sql   .= 'FROM (((trialunit LEFT JOIN trial ON trialunit.TrialId = trial.TrialId) ';
  $sql   .= 'LEFT JOIN site ON trial.SiteId = site.SiteId) ';
  $sql   .= 'LEFT JOIN generaltype ON trial.TrialTypeId = generaltype.TypeId) ';
  $sql   .= 'WHERE trial.TrialId=? ';
  $sql   .= 'ORDER BY trialunit.TrialUnitId ASC ';

  my ($read_tu_err, $read_tu_msg, $trial_info_aref) = read_data($dbh, $sql, [$trial_id]);

  if ($read_tu_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error.'}]};

    return $data_for_postrun_href;
  }

  $sql  = 'SELECT trialunit.TrialUnitId, specimen.SpecimenName, specimen.SelectionHistory, specimen.Pedigree ';
  $sql .= 'FROM (trialunit LEFT JOIN trialunitspecimen ON trialunit.TrialUnitId = trialunitspecimen.TrialUnitId) ';
  $sql .= 'LEFT JOIN specimen ON trialunitspecimen.SpecimenId = specimen.SpecimenId ';
  $sql .= 'WHERE trialunit.TrialId=? AND (ISNULL(trialunitspecimen.HasDied) = 1 OR trialunitspecimen.HasDied = 0) ';
  $sql .= 'ORDER BY trialunit.TrialUnitId ASC';

  my ($read_specimen_err, $read_specimen_msg, $specimen_data) = read_data($dbh, $sql, [$trial_id]);

  if ($read_specimen_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error.'}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  if (scalar(@{$specimen_data}) == 0) {

    my $err_msg = "Trial ($trial_id): no specimen found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trialunit2specimen_lookup = {};

  for my $specimen_rec (@{$specimen_data}) {

    my $trial_unit_id = $specimen_rec->{'TrialUnitId'};

    if ( !(defined $trialunit2specimen_lookup->{$trial_unit_id}) ) {

      my $spec_name   = $specimen_rec->{'SpecimenName'};
      my $sel_history = $specimen_rec->{'SelectionHistory'};
      my $pedigree    = $specimen_rec->{'Pedigree'};

      $trialunit2specimen_lookup->{$trial_unit_id} = [$spec_name, $sel_history, $pedigree];
    }
  }

  my $output_data_aref = [];

  for my $trial_unit_rec (@{$trial_info_aref}) {

    my $trialunit_id = $trial_unit_rec->{'TrialUnitId'};

    if ( !(defined $trialunit2specimen_lookup->{$trialunit_id}) ) {

      #next;
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error.'}]};

      return $data_for_postrun_href;
    }

    my $output_data_row  = {};
    my $trial_start_dt   = DateTime::Format::MySQL->parse_datetime($trial_unit_rec->{'TrialStartDate'});
    my $site_year        = $trial_start_dt->year();
    my $trial_start_d    = $trial_start_dt->strftime('%d %m %Y');
    my $unitposition_txt = $trial_unit_rec->{'TrialUnitPosition'};

    $output_data_row->{'SiteName'}          = $trial_unit_rec->{'SiteName'};
    $output_data_row->{'TrialId'}           = $trial_unit_rec->{'TrialId'};
    $output_data_row->{'SiteYear'}          = $site_year;
    $output_data_row->{'TrialTypeName'}     = $trial_unit_rec->{'TrialTypeName'};
    $output_data_row->{'TrialNumber'}       = $trial_unit_rec->{'TrialNumber'};
    $output_data_row->{'TrialAcronym'}      = $trial_unit_rec->{'TrialAcronym'};
    $output_data_row->{'TrialStartDate'}    = $trial_start_d;
    $output_data_row->{'GenotypeName'}      = $trialunit2specimen_lookup->{$trialunit_id}->[0];
    $output_data_row->{'SelectionHistory'}  = $trialunit2specimen_lookup->{$trialunit_id}->[1];
    $output_data_row->{'Pedigree'}          = $trialunit2specimen_lookup->{$trialunit_id}->[2];
    $output_data_row->{'TrialUnitComment'}  = $trial_unit_rec->{'TrialUnitNote'};
    $output_data_row->{'ReplicateNumber'}   = $trial_unit_rec->{'ReplicateNumber'};
    $output_data_row->{'TrialUnitPosition'} = $unitposition_txt;

    $output_data_row->{'Row'}              = $trial_unit_rec->{$unitposition_row};
    $output_data_row->{'Column'}           = $trial_unit_rec->{$unitposition_column};

    if (length($unitposition_block) > 0) {

      $output_data_row->{'Block'} = $trial_unit_rec->{$unitposition_block};
    }
    else {

      $output_data_row->{'Block'} = '';
    }

    $output_data_row->{'Barcode'} = $trial_unit_rec->{'TrialUnitBarcode'};

    my $trial_data_rec = $trial_data_href->{$trialunit_id};

    if (defined $trial_data_rec) {

      for my $trial_data_field (keys(%{$trial_data_rec})) {

        #my $trait_val = $trial_data_rec->{$trial_data_field};
        #$self->logger->debug("Trial data field: $trial_data_field - $trait_val");
        $output_data_row->{$trial_data_field}  = $trial_data_rec->{$trial_data_field};
      }
    }
    else {

      $output_data_row->{'TrialUnitId'} = $trialunit_id;
    }

    #$self->logger->debug("Output data keys: " . join(',', keys(%{$output_data_row})));

    push(@{$output_data_aref}, $output_data_row);
  }

  my $nb_trialunit = scalar(@{$output_data_aref});

  if ($nb_trialunit == 0) {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $field_order_href = {};
  $field_order_href->{'SiteName'}           = 0;
  $field_order_href->{'TrialId'}            = 1;
  $field_order_href->{'SiteYear'}           = 2;
  $field_order_href->{'TrialTypeName'}      = 3;
  $field_order_href->{'TrialNumber'}        = 4;
  $field_order_href->{'TrialAcronym'}       = 5;
  $field_order_href->{'TrialStartDate'}     = 6;
  $field_order_href->{'GenotypeName'}       = 7;
  $field_order_href->{'SelectionHistory'}   = 8;
  $field_order_href->{'Pedigree'}           = 9;
  $field_order_href->{'TrialUnitComment'}   = 10;
  $field_order_href->{'ReplicateNumber'}    = 11;
  $field_order_href->{'TrialUnitId'}        = 12;
  $field_order_href->{'TrialUnitPosition'}  = 13;
  $field_order_href->{'Block'}              = 14;
  $field_order_href->{'Column'}             = 15;
  $field_order_href->{'Row'}                = 16;
  $field_order_href->{'Barcode'}            = 17;
  $field_order_href->{'UserName'}           = 18;

  my $tfield_order_counter = 7000;

  for my $trait_field_name (@{$tfield_order_aref}) {

    $field_order_href->{$trait_field_name} = $tfield_order_counter;
    $tfield_order_counter += 1;
  }

  my $other_field_order_counter = 8000;
  for my $other_field (sort(keys(%{$output_data_aref->[0]}))) {

    if (defined $field_order_href->{$other_field}) {

      next;
    }

    $field_order_href->{$other_field} = $other_field_order_counter;
    $other_field_order_counter += 1;
  }

  $self->logger->debug("Field order keys: " . join(',', keys(%{$field_order_href})));
  $self->logger->debug("Data field keys: " . join(',', keys(%{$output_data_aref->[0]})));

  arrayref2csvfile($csv_file, $field_order_href, $output_data_aref);

  my $url = reconstruct_server_url();

  my $output_file_aref = [{ 'csv' => "$url/data/$username/${filename}.csv" }];

  my $info_aref = [{'NumOfTrialUnit' => $nb_trialunit, 'MaxInstanceNumber' => $max_instance_number}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'OutputFile'     => $output_file_aref,
                                           'Info'           => $info_aref,
  };

  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_instancenumber_runmode {

=pod list_instancenumber_HELP_START
{
"OperationName": "List instance number",
"Description": "List all the instances for all the traits collected in the trial specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='InstanceNumber' /><InstanceNumber SampleTypeId='109' InstanceNumber='0' TraitId='8' /><InstanceNumber SampleTypeId='109' InstanceNumber='0' TraitId='9' /><InstanceNumber SampleTypeId='25' InstanceNumber='1' TraitId='8' /><InstanceNumber SampleTypeId='25' InstanceNumber='1' TraitId='9' /><InstanceNumber SampleTypeId='25' InstanceNumber='2' TraitId='8' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'InstanceNumber'}], 'InstanceNumber' : [{'SampleTypeId' : '109', 'InstanceNumber' : '0', 'TraitId' : '8'}, {'SampleTypeId' : '109', 'InstanceNumber' : '0', 'TraitId' : '9'}, {'SampleTypeId' : '25', 'InstanceNumber' : '1', 'TraitId' : '8'}, {'SampleTypeId' : '25', 'InstanceNumber' : '1', 'TraitId' : '9'}, {'SampleTypeId' : '25', 'InstanceNumber' : '2', 'TraitId' : '8'}, {'SampleTypeId' : '25', 'InstanceNumber' : '2', 'TraitId' : '9'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Trial (27) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Trial (27) not found.'}]}"}],
"URLParameter": [{"ParameterName": "trialid", "Description": "Existing TrialId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $trial_id = $self->param('trialid');

  my $trait_id = '';

  if (defined $query->param('TraitId')) {

    if (length($query->param('TraitId')) > 0) {

      $trait_id = $query->param('TraitId');
    }
  }

  my $sampletype_id = '';

  if (defined $query->param('SampleTypeId')) {

    if (length($query->param('SampleTypeId')) > 0) {

      $sampletype_id = $query->param('SampleTypeId');
    }
  }

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  my $trial_exist = record_existence($dbh, 'trial', 'TrialId', $trial_id);

  if (!$trial_exist) {

    my $err_msg = "Trial ($trial_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_trial_ok, $trouble_trial_id_aref) = check_permission($dbh, 'trial', 'TrialId',
                                                               [$trial_id], $group_id, $gadmin_status,
                                                               $READ_PERM);

  if (!$is_trial_ok) {

    my $trouble_trial_id = $trouble_trial_id_aref->[0];
    my $err_msg = "Permission denied: Group ($group_id) and trial ($trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT TraitId FROM trialtrait WHERE TrialId=?';

  my ($get_trait_id_err, $get_trait_id_msg, $trait_id_aref) = read_data($dbh, $sql, [$trial_id]);

  if ($get_trait_id_err) {

    $self->logger->debug("Get trialtrait failed: $get_trait_id_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error.'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$trait_id_aref}) == 0) {

    my $err_msg = "No trait attached to Trial ($trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trait_where = '';

  if (length($trait_id) > 0) {

    my $found_trait = 0;

    for my $trait_rec (@{$trait_id_aref}) {

      if ($trait_rec->{'TraitId'} eq "$trait_id") {

        $found_trait = 1;
        last;
      }
    }

    if ( !$found_trait ) {

      my $err_msg = "Trait ($trait_id): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    $trait_where =  " AND TraitId=$trait_id";
  }

  my $sampletype_where = '';

  if (length($sampletype_id) > 0) {

    $sql  = 'SELECT SampleTypeId FROM samplemeasurement ';
    $sql .= 'LEFT JOIN trialunit ON samplemeasurement.TrialUnitId = trialunit.TrialUnitId ';
    $sql .= "WHERE TrialId=? AND SampleTypeId=? $trait_where";

    my ($r_samptype_id_err, $db_sampletype_id) = read_cell($dbh, $sql, [$trial_id, $sampletype_id]);

    if (length($db_sampletype_id) == 0) {

      my $err_msg = "SampleType ($sampletype_id) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'SampleTypeId' => $err_msg}]};

      return $data_for_postrun_href;
    }

    $sampletype_where = " AND SampleTypeId=$sampletype_id";
  }

  $sql  = 'SELECT InstanceNumber, TraitId, SampleTypeId ';
  $sql .= 'FROM samplemeasurement LEFT JOIN trialunit on samplemeasurement.TrialUnitId = trialunit.TrialUnitId ';
  $sql .= "WHERE TrialId=? $trait_where $sampletype_where ";
  $sql .= 'GROUP BY InstanceNumber, TraitId ';
  $sql .= 'ORDER BY InstanceNumber ASC';

  my ($get_inst_err, $get_inst_msg, $instance_num_aref) = read_data($dbh, $sql, [$trial_id]);

  if ($get_inst_err) {

    $self->logger->debug("Get InstanceNumber failed: $get_inst_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error.'}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'InstanceNumber' => $instance_num_aref,
                                           'RecordMeta'     => [{'TagName' => 'InstanceNumber'}],
  };

  return $data_for_postrun_href;
}

sub import_smgroup_data_csv_runmode {

=pod import_smgroup_data_csv_HELP_START
{
"OperationName": "Import sample measurements in a group",
"Description": "Import sample measurements from a csv file formatted as a sparse matrix of phenotypic data in a group. It returns Sample Measurement Group (SMGroupId) when the operation is successful.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "smgroup",
"SkippedField": ["TrialId","OperatorId","SMGroupDateTime"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='3 records of samplemeasurement have been inserted successfully.' /><StatInfo Unit='second' ServerElapsedTime='0.092' /><ReturnId Value='5' ParaName='SMGroupId' /></DATA>",
"SuccessMessageJSON": "{'StatInfo' : [{'ServerElapsedTime' : '0.109','Unit' : 'second'}],'ReturnId' : [{'ParaName' : 'SMGroupId','Value' : '6'}],'Info' : [{'Message' : '3 records of samplemeasurement have been inserted successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Trial (16): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Trial (16): not found.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "CSV",
"UploadFileParameterName": "uploadfile",
"HTTPParameter": [{"Required": 1, "Name": "TrialUnitIdCol", "Description": "Column number counting from zero for TrialUnitId column in the upload CSV file"}, {"Required": 1, "Name": "SampleTypeIdCol", "Description": "Column number counting from zero for SampleTypeId column in the upload CSV file"}, {"Required": 1, "Name": "TraitIdCol", "Description": "Column number counting from zero for TraitId column in the upload CSV file"}, {"Required": 1, "Name": "OperatorIdCol", "Description": "Column number counting from zero for OperatorId column for the upload CSV file"}, {"Required": 1, "Name": "MeasureDateTimeCol", "Description": "Column number counting from zero for MeasureDateTime column in the upload CSV file"}, {"Required": 1, "Name": "InstanceNumberCol", "Description": "Column number counting from zero for InstanceNumber column in the upload CSV file"}, {"Required": 1, "Name": "TraitValueCol", "Description": "Column number counting from zero for TraitValue column in the upload CSV file"}, {"Required": 0, "Name": "TrialUnitSpecimenIdCol", "Description": "Column number counting from zero for TrialUnitSpecimenId column in the upload CSV file for sub-plot scoring"}, {"Required": 0, "Name": "StateReasonCol", "Description": "Column number counting from zero for StateReason column in the upload CSV file for sub-plot scoring"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self     = shift;
  my $trial_id = $self->param('id');
  my $query    = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'TrialId'         => 1,
                    'OperatorId'      => 1,
                    'SMGroupDateTime' => 1,
                   };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'smgroup', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  # Finish generic required static field checking

  my $smgroup_name = $query->param('SMGroupName');

  my $operator_id = $self->authen->user_id();

  my $dbh_write = connect_kdb_write();

  if (record_existence($dbh_write, 'smgroup', 'SMGroupName', $smgroup_name)) {

    my $err_msg = "SMGroupName ($smgroup_name): already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'SMGroupName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $smgroup_status = undef;

  if (defined $query->param('SMGroupStatus')) {

    if (length($query->param('SMGroupStatus')) > 0) {

      $smgroup_status = $query->param('SMGroupStatus');
    }
  }

  my $smgroup_note = undef;

  if (defined $query->param('SMGroupNote')) {

    if (length($query->param('SMGroupNote')) > 0) {

      $smgroup_note = $query->param('SMGroupNote');
    }
  }

  my $cur_dt = DateTime->now( time_zone => $TIMEZONE );
  $cur_dt = DateTime::Format::MySQL->format_datetime($cur_dt);

  if (!record_existence($dbh_write, 'trial', 'TrialId', $trial_id)) {

    my $err_msg = "Trial ($trial_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_trial_ok, $trouble_trial_id_aref) = check_permission($dbh_write, 'trial', 'TrialId',
                                                               [$trial_id], $group_id, $gadmin_status,
                                                               $READ_WRITE_PERM);

  if (!$is_trial_ok) {

    my $trouble_trial_id = $trouble_trial_id_aref->[0];
    my $err_msg = "Permission denied: Group ($group_id) and trial ($trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $data_csv_file = $self->authen->get_upload_file();

  my $num_of_col = get_csvfile_num_of_col($data_csv_file);

  $self->logger->debug("Number of columns: $num_of_col");

  my $TrialUnitId_col     = $query->param('TrialUnitIdCol');
  my $SampleTypeId_col    = $query->param('SampleTypeIdCol');
  my $TraitId_col         = $query->param('TraitIdCol');
  my $MeasureDateTime_col = $query->param('MeasureDateTimeCol');
  my $InstanceNumber_col  = $query->param('InstanceNumberCol');
  my $TraitValue_col      = $query->param('TraitValueCol');

  my $chk_col_href = { 'TrialUnitIdCol'     => $TrialUnitId_col,
                       'SampleTypeIdCol'    => $SampleTypeId_col,
                       'TraitIdCol'         => $TraitId_col,
                       'MeasureDateTimeCol' => $MeasureDateTime_col,
                       'InstanceNumberCol'  => $InstanceNumber_col,
                       'TraitValueCol'      => $TraitValue_col,
                     };

  my $matched_col = {};

  $matched_col->{$TrialUnitId_col}     = 'TrialUnitId';
  $matched_col->{$SampleTypeId_col}    = 'SampleTypeId';
  $matched_col->{$TraitId_col}         = 'TraitId';
  $matched_col->{$MeasureDateTime_col} = 'MeasureDateTime';
  $matched_col->{$InstanceNumber_col}  = 'InstanceNumber';
  $matched_col->{$TraitValue_col}      = 'TraitValue';

  my $TrialUnitSpecimenId_col = undef;

  if (defined $query->param('TrialUnitSpecimenIdCol')) {

    if (length($query->param('TrialUnitSpecimenIdCol')) > 0) {

      $TrialUnitSpecimenId_col = $query->param('TrialUnitSpecimenIdCol');
      $chk_col_href->{'TrialUnitSpecimenIdCol'} = $TrialUnitSpecimenId_col;

      $matched_col->{$TrialUnitSpecimenId_col} = 'TrialUnitSpecimenId';
    }
  }

  my $StateReason_col = undef;

  if (defined $query->param('StateReasonCol')) {

    if (length($query->param('StateReasonCol')) > 0) {

      $StateReason_col = $query->param('StateReasonCol');
      $chk_col_href->{'StateReasonCol'} = $StateReason_col;

      $matched_col->{$StateReason_col} = 'StateReason';
    }
  }

  my $OperatorId_col      = undef;

  if (defined $query->param('OperatorIdCol')) {

    if (length($query->param('OperatorIdCol')) > 0) {

      $OperatorId_col = $query->param('OperatorIdCol');
      $chk_col_href->{'OperatorIdCol'} = $OperatorId_col;

      $matched_col->{$OperatorId_col} = 'OperatorId';
    }
  }

  my $SurveyId_col      = undef;

  if (defined $query->param('SurveyIdCol')) {

    if (length($query->param('SurveyIdCol')) > 0) {

      $SurveyId_col = $query->param('SurveyIdCol');
      $chk_col_href->{'SurveyIdCol'} = $SurveyId_col;

      $matched_col->{$SurveyId_col} = 'SurveyId';
    }
  }

  my ($col_def_err, $col_def_err_href) = check_col_def_href( $chk_col_href, $num_of_col);

  if ($col_def_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$col_def_err_href]};

    return $data_for_postrun_href;
  }

  my @fieldname_list;

  for (my $i = 0; $i < $num_of_col; $i++) {
    if ($matched_col->{$i}) {

      push(@fieldname_list, $matched_col->{$i});
    }
    else {

      push(@fieldname_list, 'null');
    }
  }

  my ($data_aref, $csv_err, $err_msg) = csvfile2arrayref($data_csv_file, \@fieldname_list, 0);

  if ($csv_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'INSERT INTO smgroup SET ';
  $sql   .= 'SMGroupName=?, ';
  $sql   .= 'TrialId=?, ';
  $sql   .= 'OperatorId=?, ';
  $sql   .= 'SMGroupStatus=?, ';
  $sql   .= 'SMGroupDateTime=?, ';
  $sql   .= 'SMGroupNote=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($smgroup_name, $trial_id, $operator_id, $smgroup_status, $cur_dt, $smgroup_note);

  my $smgroup_id = -1;

  if ($dbh_write->err()) {

    $self->logger->debug("Add smgroup record failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $smgroup_id = $dbh_write->last_insert_id(undef, undef, 'smgroup', 'SMGroupId');
  $self->logger->debug("SMGroupID: $smgroup_id");

  $sth->finish();

  my $check_non_trait_field      = 1;
  my $validate_trait_value       = 1;
  my $enforce_single_trial_data  = 1;

  $data_for_postrun_href = $self->insert_samplemeasurement_data_v2($dbh_write,
                                                                $data_aref,
                                                                $check_non_trait_field,
                                                                $validate_trait_value,
                                                                $enforce_single_trial_data,
                                                                $smgroup_id,
                                                                $trial_id
                                                               );

  if ($data_for_postrun_href->{'Error'} == 1) {

    # Delete SMGroup record and return $data_for_postrun_href
    $sql = 'DELETE FROM smgroup WHERE SMGroupId=?';

    $sth = $dbh_write->prepare($sql);
    $sth->execute($smgroup_id);

    if ($dbh_write->err()) {

      $self->logger->debug("Delete smgroup record failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }
  }

  $dbh_write->disconnect();

  my $return_id_aref = [{'Value'   => "$smgroup_id", 'ParaName' => 'SMGroupId'}];

  $data_for_postrun_href->{'Data'}->{'ReturnId'} = $return_id_aref;

  return $data_for_postrun_href;
}

sub list_smgroup_runmode {

=pod list_smgroup_HELP_START
{
"OperationName": "List samplemeasurement groups",
"Description": "List available samplemeasurement group.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='SMGroup' /><SMGroup TrialId='14' OperatorId='0' NumOfMeasurement='3' SMGroupDateTime='2017-04-19 15:22:10' SMGroupId='6' OperatorUserName='admin' SMGroupName='SMG_31217813748' SMGroupStatus='TEST' SMGroupNote='Testing' update='update/smgroup/6' delete='delete/smgroup/6' /><StatInfo ServerElapsedTime='0.006' Unit='second' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'SMGroup'}],'StatInfo' : [{'ServerElapsedTime' : '0.007','Unit' : 'second'}],'SMGroup' : [{'SMGroupId' : '6','SMGroupDateTime' : '2017-04-19 15:22:10','OperatorId' : '0','NumOfMeasurement' : '3','TrialId' : '14','delete' : 'delete/smgroup/6','SMGroupName' : 'SMG_31217813748','update' : 'update/smgroup/6','SMGroupNote' : 'Testing','SMGroupStatus' : 'TEST','OperatorUserName' : 'admin'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self     = shift;
  my $trial_id = $self->param('id');
  my $query    = $self->query();

  my $filtering_csv = '';

  if (defined $query->param('Filtering')) {

    $filtering_csv = $query->param('Filtering');
  }

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  if (!record_existence($dbh, 'trial', 'TrialId', $trial_id)) {

    my $err_msg = "Trial ($trial_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_trial_ok, $trouble_trial_id_aref) = check_permission($dbh, 'trial', 'TrialId',
                                                               [$trial_id], $group_id, $gadmin_status,
                                                               $READ_PERM);

  if (!$is_trial_ok) {

    my $trouble_trial_id = $trouble_trial_id_aref->[0];
    my $err_msg = "Permission denied: Group ($group_id) and trial ($trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  my $sql = 'SELECT smgroup.*, systemuser.UserName AS OperatorUserName ';
  $sql   .= 'FROM smgroup LEFT JOIN systemuser ON smgroup.OperatorId = systemuser.UserId ';
  $sql   .= 'WHERE TrialId=?';

  my $filter_field_list = ['SMGroupName', 'OperatorId', 'SMGroupStatus', 'SMGroupDateTime', 'SMGroupNote'];

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering('SMGroupId',
                                                                              'smgroup',
                                                                              $filtering_csv,
                                                                              $filter_field_list);

  if ($filter_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $filter_msg}]};

    return $data_for_postrun_href;
  }

  if (length($filter_phrase) > 0) {

    $sql .= " AND $filter_phrase";
  }


  my ($read_smgrp_err, $read_smgrp_msg, $smgrp_data) = $self->list_smgroup(1, 0, $sql, [$trial_id, @{$where_arg}]);

  if ($read_smgrp_err) {

    $self->logger->debug($read_smgrp_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'SMGroup'    => $smgrp_data,
                                           'RecordMeta' => [{'TagName' => 'SMGroup'}],
  };

  return $data_for_postrun_href;
}

sub list_smgroup {

  my $self            = $_[0];
  my $extra_attr_yes  = $_[1];
  my $detail_attr_yes = $_[2];
  my $sql             = $_[3];
  my $where_para_aref = $_[4];

  my $err       = 0;
  my $msg       = '';
  my $data_aref = [];

  my $dbh = connect_kdb_read();

  ($err, $msg, $data_aref) = read_data($dbh, $sql, $where_para_aref);

  if ($err) {

    return ($err, $msg, []);
  }

  my $smgroup_id_aref    = [];

  my $smcount_lookup     = {};
  my $trait_lookup       = {};
  my $trial_unit_lookup  = {};
  my $tu_spec_lookup     = {};

  my $uniq_smgrp_trait_href   = {};
  my $uniq_smgrp_tu_href      = {};
  my $uniq_smgrp_tu_spec_href = {};

  if ($extra_attr_yes || $detail_attr_yes) {

    for my $smgroup_rec (@{$data_aref}) {

      push(@{$smgroup_id_aref}, $smgroup_rec->{'SMGroupId'});
    }

    if (scalar(@{$smgroup_id_aref}) > 0) {

      my $count_sql = 'SELECT SMGroupId, COUNT(TrialUnitId) AS NumOfMeasurement ';
      $count_sql   .= 'FROM samplemeasurement ';
      $count_sql   .= 'WHERE SMGroupId IN (' . join(',', @{$smgroup_id_aref}) . ') ';
      $count_sql   .= 'GROUP BY SMGroupId';

      $self->logger->debug("COUNT MEASUREMENT SQL: $count_sql");

      $smcount_lookup = $dbh->selectall_hashref($count_sql, 'SMGroupId');

      if ($dbh->err()) {

        $self->logger->debug("Count number of samplemeasurement failed");
        $err = 1;
        $msg = 'Unexpected Error';

        return ($err, $msg, []);
      }

      if ($detail_attr_yes) {

        my $detail_sql = 'SELECT SMGroupId, trait.TraitId, TraitName, samplemeasurement.TrialUnitId, ';
        $detail_sql   .= 'samplemeasurement.TrialUnitSpecimenId, SpecimenId ';
        $detail_sql   .= 'FROM samplemeasurement ';
        $detail_sql   .= 'LEFT JOIN trait on samplemeasurement.TraitId = trait.TraitId ';
        $detail_sql   .= 'LEFT JOIN trialunitspecimen ON ';
        $detail_sql   .= 'samplemeasurement.TrialUnitSpecimenId = trialunitspecimen.TrialUnitSpecimenId ';
        $detail_sql   .= 'WHERE SMGroupId IN (' . join(',', @{$smgroup_id_aref}) . ')';

        my $detail_data_aref = [];

        ($err, $msg, $detail_data_aref) = read_data($dbh, $detail_sql, []);

        if ($err) {

          return ($err, $msg, []);
        }

        for my $detail_rec (@{$detail_data_aref}) {

          my $smgrp_id    = $detail_rec->{'SMGroupId'};
          my $trait_id    = $detail_rec->{'TraitId'};
          my $trait_name  = $detail_rec->{'TraitName'};
          my $tu_id       = $detail_rec->{'TrialUnitId'};
          my $tu_spec_id  = $detail_rec->{'TrialUnitSpecimenId'};
          my $spec_id     = $detail_rec->{'SpecimenId'};

          if (! defined $uniq_smgrp_trait_href->{"${smgrp_id}_${trait_id}"}) {

            $uniq_smgrp_trait_href->{"${smgrp_id}_${trait_id}"} = 1;

            if (defined $trait_lookup->{$smgrp_id}) {

              my $trait_aref = $trait_lookup->{$smgrp_id};
              push(@{$trait_aref}, {'TraitId' => $trait_id, 'TraitName' => $trait_name});
              $trait_lookup->{$smgrp_id} = $trait_aref;
            }
            else {

              $trait_lookup->{$smgrp_id} = [{'TraitId' => $trait_id, 'TraitName' => $trait_name}];
            }
          }

          if (! defined $uniq_smgrp_tu_href->{"${smgrp_id}_${tu_id}"}) {

            $uniq_smgrp_tu_href->{"${smgrp_id}_${tu_id}"} = 1;

            if (defined $trial_unit_lookup->{$smgrp_id}) {

              my $tu_aref = $trial_unit_lookup->{$smgrp_id};
              push(@{$tu_aref}, {'TrialUnitId' => $tu_id});
              $trial_unit_lookup->{$smgrp_id} = $tu_aref;
            }
            else {

              $trial_unit_lookup->{$smgrp_id} = [{'TrialUnitId' => $tu_id}];
            }
          }

          if ($tu_spec_id != 0) {

            if (! defined $uniq_smgrp_tu_spec_href->{"${smgrp_id}_${tu_spec_id}"}) {

              $uniq_smgrp_tu_spec_href->{"${smgrp_id}_${tu_spec_id}"} = 1;

              if (defined $tu_spec_lookup->{$smgrp_id}) {

                my $tu_spec_aref = $tu_spec_lookup->{$smgrp_id};
                push(@{$tu_spec_aref}, {'TrialUnitSpecimenId' => $tu_spec_id, 'SpecimenId' => $spec_id});
                $tu_spec_lookup->{$smgrp_id} = $tu_spec_aref;
              }
              else {

                $tu_spec_lookup->{$smgrp_id} = [{'TrialUnitSpecimenId' => $tu_spec_id, 'SpecimenId' => $spec_id}];
              }
            }
          }
        }
      }
    }
  }

  my $extra_attr_smgroup_data = [];

  my $user_id = $self->authen->user_id();

  my $gadmin_status = $self->authen->gadmin_status();

  if ($extra_attr_yes) {

    for my $smgroup_rec (@{$data_aref}) {

      my $smgrp_id     = $smgroup_rec->{'SMGroupId'};
      my $operator_id  = $smgroup_rec->{'OperatorId'};

      if ("$operator_id" eq "$user_id") {

        $smgroup_rec->{'update'} = "update/smgroup/${smgrp_id}";
        $smgroup_rec->{'delete'} = "delete/smgroup/${smgrp_id}";
      }

      if (defined $smcount_lookup->{$smgrp_id}) {

        $smgroup_rec->{'NumOfMeasurement'} = $smcount_lookup->{$smgrp_id}->{'NumOfMeasurement'};
      }

      if ($detail_attr_yes) {

        if (defined $trait_lookup->{$smgrp_id}) {

          $smgroup_rec->{'Trait'} = $trait_lookup->{$smgrp_id};
        }

        if (defined $trial_unit_lookup->{$smgrp_id}) {

          $smgroup_rec->{'TrialUnit'} = $trial_unit_lookup->{$smgrp_id};
        }

        if (defined $tu_spec_lookup->{$smgrp_id}) {

          $smgroup_rec->{'TrialUnitSpecimen'} = $tu_spec_lookup->{$smgrp_id};
        }
      }

      push(@{$extra_attr_smgroup_data}, $smgroup_rec);
    }
  }
  else {

    $extra_attr_smgroup_data = $data_aref;
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_smgroup_data);
}

sub get_smgroup_runmode {

=pod get_smgroup_HELP_START
{
"OperationName": "Get samplemeasurement group",
"Description": "Get detail information about a samplemeasurement group.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><SMGroup update='update/smgroup/6' NumOfMeasurement='3' SMGroupDateTime='2017-04-19 15:22:10' TrialId='14' OperatorUserName='admin' SMGroupStatus='TEST' SMGroupNote='Testing' SMGroupId='6' delete='delete/smgroup/6' SMGroupName='SMG_31217813748' OperatorId='0'><Trait TraitId='14' TraitName='Trait_75223850117' /><TrialUnitSpecimen SpecimenId='55' TrialUnitSpecimenId='55' /><TrialUnitSpecimen SpecimenId='56' TrialUnitSpecimenId='56' /><TrialUnit TrialUnitId='14' /></SMGroup><StatInfo Unit='second' ServerElapsedTime='0.015' /><RecordMeta TagName='SMGroup' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'SMGroup'}],'SMGroup' : [{'NumOfMeasurement' : '3','update' : 'update/smgroup/6','Trait' : [{'TraitName' : 'Trait_75223850117','TraitId' : '14'}],'TrialUnitSpecimen' : [{'SpecimenId' : '55','TrialUnitSpecimenId' : '55'},{'TrialUnitSpecimenId' : '56','SpecimenId' : '56'}],'TrialUnit' : [{'TrialUnitId' : '14'}],'SMGroupDateTime' : '2017-04-19 15:22:10','OperatorUserName' : 'admin','SMGroupStatus' : 'TEST','TrialId' : '14','SMGroupNote' : 'Testing','SMGroupId' : '6','SMGroupName' : 'SMG_31217813748','delete' : 'delete/smgroup/6','OperatorId' : '0'}],'StatInfo' : [{'ServerElapsedTime' : '0.018','Unit' : 'second'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='SMGroup (7): not found.' /><StatInfo ServerElapsedTime='0.013' Unit='second' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'SMGroup (7): not found.'}],'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.013'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SMGroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $smgroup_id = $self->param('id');
  my $query      = $self->query();

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  my $trial_id = read_cell_value($dbh, 'smgroup', 'TrialId', 'SMGroupId', $smgroup_id);

  if (length($trial_id) == 0) {

    my $err_msg = "SMGroup ($smgroup_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_trial_ok, $trouble_trial_id_aref) = check_permission($dbh, 'trial', 'TrialId',
                                                               [$trial_id], $group_id, $gadmin_status,
                                                               $READ_PERM);

  if (!$is_trial_ok) {

    my $trouble_trial_id = $trouble_trial_id_aref->[0];
    my $err_msg = "Permission denied: Group ($group_id) and trial ($trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  my $sql = 'SELECT smgroup.*, systemuser.UserName AS OperatorUserName ';
  $sql   .= 'FROM smgroup LEFT JOIN systemuser ON smgroup.OperatorId = systemuser.UserId ';
  $sql   .= 'WHERE SMGroupId = ?';

  my ($read_smgrp_err, $read_smgrp_msg, $smgrp_data) = $self->list_smgroup(1, 1, $sql, [$smgroup_id]);

  if ($read_smgrp_err) {

    $self->logger->debug($read_smgrp_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'SMGroup'    => $smgrp_data,
                                           'RecordMeta' => [{'TagName' => 'SMGroup'}],
  };

  return $data_for_postrun_href;
}

sub update_smgroup_runmode {

=pod update_smgroup_HELP_START
{
"OperationName": "Update samplemeasurement group",
"Description": "Update detail information about a samplemeasurement group.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "smgroup",
"SkippedField": ["TrialId","OperatorId","SMGroupDateTime"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><StatInfo Unit='second' ServerElapsedTime='0.047' /><Info Message='SMGroup (9) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'SMGroup (10) has been updated successfully.'}],'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.075'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='SMGroup (7): not found.' /><StatInfo ServerElapsedTime='0.013' Unit='second' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'SMGroup (7): not found.'}],'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.013'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SMGroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $smgroup_id = $self->param('id');
  my $query      = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'TrialId'         => 1,
                    'OperatorId'      => 1,
                    'SMGroupDateTime' => 1,
                   };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'smgroup', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  # Finish generic required static field checking

  my $dbh = connect_kdb_read();

  my $chk_sql = 'SELECT TrialId, OperatorId, SMGroupName, SMGroupStatus, SMGroupNote ';
  $chk_sql   .= 'FROM smgroup WHERE SMGroupId=?';

  my ($r_smgrp_err, $r_smgrp_msg, $smgrp_data) = read_data($dbh, $chk_sql, [$smgroup_id]);

  if ($r_smgrp_err) {

    $self->logger->debug("Get info about existing smgroup failed: $r_smgrp_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$smgrp_data}) == 0) {

    my $err_msg = "SMGroup ($smgroup_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trial_id       = $smgrp_data->[0]->{'TrialId'};
  my $operator_id    = $smgrp_data->[0]->{'OperatorId'};
  my $db_smgrp_name  = $smgrp_data->[0]->{'SMGroupName'};

  my $smgroup_status = undef;

  if (defined $smgrp_data->[0]->{'SMGroupStatus'}) {

    if (length($smgrp_data->[0]->{'SMGroupStatus'}) > 0) {

      $smgroup_status = $smgrp_data->[0]->{'SMGroupStatus'};
    }
  }

  $smgroup_status = $query->param('SMGroupStatus');

  if (length($smgroup_status) == 0) {

    $smgroup_status = undef;
  }

  my $smgroup_note = undef;

  if (defined $smgrp_data->[0]->{'SMGroupNote'}) {

    if (length($smgrp_data->[0]->{'SMGroupNote'}) > 0) {

      $smgroup_note = $smgrp_data->[0]->{'SMGroupNote'};
    }
  }

  $smgroup_note = $query->param('SMGroupNote');

  if (length($smgroup_note) == 0) {

    $smgroup_note = undef;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_trial_ok, $trouble_trial_id_aref) = check_permission($dbh, 'trial', 'TrialId',
                                                               [$trial_id], $group_id, $gadmin_status,
                                                               $READ_WRITE_PERM);

  if (!$is_trial_ok) {

    my $trouble_trial_id = $trouble_trial_id_aref->[0];
    my $err_msg = "Permission denied: Group ($group_id) and trial ($trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  my $user_id = $self->authen->user_id();

  if ("$user_id" ne "0") {

    if ("$user_id" ne "$operator_id") {

      my $err_msg = "Permission denied: User ($user_id).";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $dbh_write = connect_kdb_write();

  my $cur_dt = DateTime->now( time_zone => $TIMEZONE );
  $cur_dt = DateTime::Format::MySQL->format_datetime($cur_dt);

  my $smgroup_name = $query->param('SMGroupName');

  if ($smgroup_name ne $db_smgrp_name) {

    if (record_existence($dbh_write, 'smgroup', 'SMGroupName', $smgroup_name)) {

      my $err_msg = "SMGroup ($smgroup_name): already exists.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'SMGroupName' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $sql = 'UPDATE smgroup SET ';
  $sql   .= 'SMGroupName=?, ';
  $sql   .= 'SMGroupStatus=?, ';
  $sql   .= 'SMGroupDateTime=?, ';
  $sql   .= 'SMGroupNote=? ';
  $sql   .= 'WHERE SMGroupId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($smgroup_name, $smgroup_status, $cur_dt, $smgroup_note, $smgroup_id);

  if ($dbh_write->err()) {

    $self->logger->debug("Update SMGroup failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "SMGroup ($smgroup_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub del_smgroup_runmode {

=pod del_smgroup_HELP_START
{
"OperationName": "Delete samplemeasurement group",
"Description": "Delete a samplemeasurement group and its associated samplemeasurement records.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><StatInfo ServerElapsedTime='0.075' Unit='second' /><Info Message='SMGroup (12) and its samplemeasurement records have been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'StatInfo' : [{'ServerElapsedTime' : '0.074','Unit' : 'second'}],'Info' : [{'Message' : 'SMGroup (11) and its samplemeasurement records have been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='SMGroup (7): not found.' /><StatInfo ServerElapsedTime='0.013' Unit='second' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'SMGroup (7): not found.'}],'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.013'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SMGroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $smgroup_id = $self->param('id');
  my $query      = $self->query();

  my $data_for_postrun_href = {};

  my $dbh_write = connect_kdb_write();

  my $chk_sql = 'SELECT TrialId, OperatorId, SMGroupName, SMGroupStatus, SMGroupNote ';
  $chk_sql   .= 'FROM smgroup WHERE SMGroupId=?';

  my ($r_smgrp_err, $r_smgrp_msg, $smgrp_data) = read_data($dbh_write, $chk_sql, [$smgroup_id]);

  if ($r_smgrp_err) {

    $self->logger->debug("Get info about existing smgroup failed: $r_smgrp_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$smgrp_data}) == 0) {

    my $err_msg = "SMGroup ($smgroup_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trial_id       = $smgrp_data->[0]->{'TrialId'};
  my $operator_id    = $smgrp_data->[0]->{'OperatorId'};

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_trial_ok, $trouble_trial_id_aref) = check_permission($dbh_write, 'trial', 'TrialId',
                                                               [$trial_id], $group_id, $gadmin_status,
                                                               $READ_WRITE_PERM);

  if (!$is_trial_ok) {

    my $trouble_trial_id = $trouble_trial_id_aref->[0];
    my $err_msg = "Permission denied: Group ($group_id) and trial ($trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $user_id = $self->authen->user_id();

  if ("$user_id" ne "0") {

    if ("$user_id" ne "$operator_id") {

      my $err_msg = "Permission denied: User ($user_id).";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $sql = 'DELETE FROM samplemeasurement WHERE SMGroupId=?';

  my $sth = $dbh_write->prepare($sql);

  $sth->execute($smgroup_id);

  if ($dbh_write->err()) {

    $self->logger->debug("Delete samplemeasurement failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $sql = 'DELETE FROM smgroup where SMGroupId=?';

  $sth = $dbh_write->prepare($sql);

  $sth->execute($smgroup_id);

  if ($dbh_write->err()) {

    $self->logger->debug("Delete smgroup failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "SMGroup ($smgroup_id) and its samplemeasurement records have been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub add_traitgroup_runmode {

=pod add_traitgroup_HELP_START
{
"OperationName": "Group existing traits together",
"Description": "Group existing traits together.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "traitgroup",
"SkippedField": ["OperatorId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId ParaName='TraitGroupId' Value='2' /><StatInfo Unit='second' ServerElapsedTime='0.187' /><Info Message='TraitGroup (2) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '3','ParaName' : 'TraitGroupId'}],'Info' : [{'Message' : 'TraitGroup (3) has been added successfully.'}],'StatInfo' : [{'ServerElapsedTime' : '0.129','Unit' : 'second'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Trait (76): not found.' /><StatInfo ServerElapsedTime='0.065' Unit='second' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'StatInfo' : [{'ServerElapsedTime' : '0.068','Unit' : 'second'}],'Error' : [{'Message' : 'Trait (76): not found.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "XML",
"UploadFileParameterName": "uploadfile",
"DTDFileNameForUploadXML": "traitgroupentry.dtd",
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = $_[0];
  my $query = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'OperatorId' => 1};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'traitgroup', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $t_grp_name = $query->param('TraitGroupName');

  my $user_id = $self->authen->user_id();

  my $uniq_t_grp_name_sql = 'SELECT TraitGroupId FROM traitgroup WHERE TraitGroupName=? AND OperatorId=?';

  my $dbh_k_read = connect_kdb_read();

  my ($chk_t_grp_name_err, $db_t_grp_id) = read_cell($dbh_k_read, $uniq_t_grp_name_sql, [$t_grp_name, $user_id]);

  if ($chk_t_grp_name_err) {

    $self->logger->debug("Check trait group name failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  if (length($db_t_grp_id) > 0) {

    my $err_msg = "TraitGroupName ($t_grp_name): already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TraitGroupName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $alt_id                 = undef;

  if (defined $query->param('AltIdentifier')) {

    if (length($query->param('AltIdentifier')) > 0) {

      $alt_id = $query->param('AltIdentifier');
    }
  }

  if (length($alt_id) > 0) {

    if (record_existence($dbh_k_read, 'traitgroup', 'AltIdentifier', $alt_id)) {

      my $err_msg = "AltIdentifier ($alt_id): already exists.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'AltIdentifier' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }
  else {

    $alt_id = undef;
  }

  my $entry_xml_file           = $self->authen->get_upload_file();
  my $traitgroupentry_dtd_file = $self->get_traitgroupentry_dtd_file();

  $self->logger->debug("Traitgroupentry DTD: $traitgroupentry_dtd_file");

  add_dtd($traitgroupentry_dtd_file, $entry_xml_file);

  my $traitgroup_xml = read_file($entry_xml_file);

  $self->logger->debug("XML file with DTD: $traitgroup_xml");

  my $xml_checker_parser = new XML::Checker::Parser( Handlers => { } );

  eval {

    local $XML::Checker::FAIL = sub {

      my $code = shift;
      my $err_str = XML::Checker::error_string ($code, @_);
      $self->logger->debug("XML Parsing ERR: $code : $err_str");
      die $err_str;
    };
    $xml_checker_parser->parsefile($entry_xml_file);
  };

  if ($@) {

    my $err_msg = $@;
    $self->logger->debug("Parsing XML error: $err_msg");
    my $user_err_msg = "traitgroupentry xml file does not comply with its definition.\n";
    $user_err_msg   .= "Details: $err_msg";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $user_err_msg}]};

    return $data_for_postrun_href;
  }

  my $trait_entry_aref = xml2arrayref($traitgroup_xml, 'traitgroupentry');

  my $trait_id_aref      = [];
  my $uniq_trait_id_href = {};

  for my $trait_entry_info (@{$trait_entry_aref}) {

    my $trait_id = $trait_entry_info->{'TraitId'};

    if (defined $uniq_trait_id_href->{$trait_id}) {

      my $err_msg = "Trait ($trait_id): duplicate.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    else {

      $uniq_trait_id_href->{$trait_id} = 1;
    }

    push(@{$trait_id_aref}, $trait_id);
  }

  my ($trait_err, $trait_msg,
      $unfound_trait_aref, $found_trait_aref) = record_existence_bulk($dbh_k_read, 'trait',
                                                                      'TraitId', $trait_id_aref);

  if ($trait_err) {

    $self->logger->debug("Check recorod existence bulk failed: $trait_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$unfound_trait_aref}) > 0) {

    my $unfound_trait_csv = join(',', @{$unfound_trait_aref});

    my $err_msg = "Trait ($unfound_trait_csv): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_trait_ok, $trouble_trait_id_aref) = check_permission($dbh_k_read, 'trait', 'TraitId',
                                                               $trait_id_aref, $group_id, $gadmin_status,
                                                               $READ_LINK_PERM);

  if (!$is_trait_ok) {

    my $trouble_trait_id = $trouble_trait_id_aref->[0];

    my $err_msg = "Permission denied: Group ($group_id) and Trait ($trouble_trait_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $sql = 'INSERT INTO traitgroup SET ';
  $sql   .= 'TraitGroupName=?, ';
  $sql   .= 'OperatorId=?, ';
  $sql   .= 'AltIdentifier=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($t_grp_name, $user_id, $alt_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  my $t_grp_id = $dbh_k_write->last_insert_id(undef, undef, 'traitgroup', 'TraitGroupId');

  $sql  = 'INSERT INTO traitgroupentry ';
  $sql .= '(TraitGroupId,TraitId) ';
  $sql .= 'VALUES ';

  my @sql_val_list;

  for my $trait_id (@{$trait_id_aref}) {

    push(@sql_val_list, qq|($t_grp_id, $trait_id)|);
  }

  $sql .= join(',', @sql_val_list);

  $self->logger->debug("TraitGroup entry SQL: $sql");

  $sth = $dbh_k_write->prepare($sql);
  $sth->execute();

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref  = [{'Message' => "TraitGroup ($t_grp_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$t_grp_id", 'ParaName' => 'TraitGroupId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref,
                                           'ReturnId'  => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_traitgroup_runmode {

=pod update_traitgroup_HELP_START
{
"OperationName": "Update trait group meta information",
"Description": "Update detailed information of trait grouping",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "traitgroup",
"SkippedField": ["OperatorId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><StatInfo Unit='second' ServerElapsedTime='0.044' /><Info Message='TraitGroup (4) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'TraitGroup (5) has been updated successfully.'}],'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.044'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><StatInfo ServerElapsedTime='0.007' Unit='second' /><Error Message='TraitGroup (10): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'TraitGroup (10): not found.'}],'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.008'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TraitGroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = $_[0];
  my $query = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'OperatorId' => 1};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'traitgroup', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $dbh_k_read = connect_kdb_read();

  my $t_grp_id = $self->param('id');

  my $t_grp_owner = read_cell_value($dbh_k_read, 'traitgroup', 'OperatorId', 'TraitGroupId', $t_grp_id);

  if (length($t_grp_owner) == 0) {

    my $err_msg = "TraitGroup ($t_grp_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trait_id_sql = 'SELECT TraitId FROM traitgroupentry WHERE TraitGroupId=?';

  my ($r_t_id_err, $r_t_id_msg, $trait_id_data) = read_data($dbh_k_read, $trait_id_sql, [$t_grp_id]);

  if ($r_t_id_err) {

    $self->logger->debug("Retrieve trait id failed: $r_t_id_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $trait_id_aref = [];

  for my $trait_rec (@{$trait_id_data}) {

    push(@{$trait_id_aref}, $trait_rec->{'TraitId'});
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_trait_ok, $trouble_trait_id_aref) = check_permission($dbh_k_read, 'trait', 'TraitId',
                                                               $trait_id_aref, $group_id, $gadmin_status,
                                                               $READ_WRITE_PERM);

  if (!$is_trait_ok) {

    my $trouble_trait_id = $trouble_trait_id_aref->[0];

    my $err_msg = "Permission denied: Group ($group_id) and Trait ($trouble_trait_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $user_id = $self->authen->user_id();

  if ("$t_grp_owner" ne "$user_id") {

    my $err_msg = "TraitGroup ($t_grp_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $t_grp_name = $query->param('TraitGroupName');
  my $alt_id     = undef;

  my $sql = 'SELECT TraitGroupId ';
  $sql   .= 'FROM traitgroup ';
  $sql   .= 'WHERE TraitGroupName=? AND OperatorId=? AND TraitGroupId<>?';

  my ($r_t_grp_id_err, $db_t_grp_id) = read_cell($dbh_k_read, $sql, [$t_grp_name, $user_id, $t_grp_id]);

  if ($r_t_grp_id_err) {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_t_grp_id) > 0) {

    my $err_msg = "TraitGroupName ($t_grp_name): already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TraitGroupName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $alt_id = read_cell_value($dbh_k_read, 'traitgroup', 'AltIdentifier', 'TraitGroupId', $t_grp_id);

  if (length($alt_id) == 0) {

    $alt_id = undef;
  }

  if (defined $query->param('AltIdentifier')) {

    if (length($query->param('AltIdentifier')) > 0) {

      $alt_id = $query->param('AltIdentifier')
    }
    else {

      $alt_id = undef;
    }
  }

  if (length($alt_id) > 0) {

    $sql  = 'SELECT TraitGroupId FROM traitgroup ';
    $sql .= 'WHERE AltIdentifier=? AND TraitGroupId<>?';

    my ($chk_alt_id_err, $db_t_grp_id) = read_cell($dbh_k_read, $sql, [$alt_id, $t_grp_id]);

    if (length($db_t_grp_id) > 0) {

      my $err_msg = "AltIdentifier ($alt_id): already exists.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'AltIdentifier' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  $sql  = 'UPDATE traitgroup SET ';
  $sql .= 'TraitGroupName=?, ';
  $sql .= 'AltIdentifier=? ';
  $sql .= 'WHERE TraitGroupId=?';

  my $dbh_k_write = connect_kdb_write();

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($t_grp_name, $alt_id, $t_grp_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref = [{'Message' => "TraitGroup ($t_grp_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_traitgroup {

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

  my $user_id = $self->authen->user_id();

  my $extra_attr_t_grp_data = [];

  if ($extra_attr_yes) {

    my $t_grp_id_aref  = [];

    my $entry_lookup      = {};

    my $chk_id_err        = 0;
    my $chk_id_msg        = '';
    my $used_id_href      = {};
    my $not_used_id_href  = {};

    for my $row (@{$data_aref}) {

      push(@{$t_grp_id_aref}, $row->{'TraitGroupId'});
    }

    if (scalar(@{$t_grp_id_aref}) > 0) {

      my $entry_sql = 'SELECT traitgroupentry.*,trait.TraitName ';
      $entry_sql   .= 'FROM traitgroupentry ';
      $entry_sql   .= 'LEFT JOIN trait ON traitgroupentry.TraitId=trait.TraitId ';
      $entry_sql   .= 'WHERE traitgroupentry.TraitGroupId IN (' . join(',', @{$t_grp_id_aref}) . ')';

      my ($entry_err, $entry_msg, $entry_data) = read_data($dbh, $entry_sql, []);

      if ($entry_err) {

        return ($entry_err, $entry_msg, []);
      }

      for my $row (@{$entry_data}) {

        my $t_grp_id = $row->{'TraitGroupId'};

        if (defined $entry_lookup->{$t_grp_id}) {

          my $entry_aref = $entry_lookup->{$t_grp_id};

          push(@{$entry_aref}, $row);
          $entry_lookup->{$t_grp_id} = $entry_aref;
        }
        else {

          $entry_lookup->{$t_grp_id} = [$row];
        }
      }

      my $chk_table_aref = [{'TableName' => 'traitgroupentry', 'FieldName' => 'TraitGroupId'}];

      ($chk_id_err, $chk_id_msg,
       $used_id_href, $not_used_id_href) = id_existence_bulk($dbh, $chk_table_aref, $t_grp_id_aref);

      if ($chk_id_err) {

        $self->logger->debug("Check id existence error: $chk_id_msg");
        $err = 1;
        $msg = $chk_id_msg;

        return ($err, $msg, []);
      }
    }

    for my $row (@{$data_aref}) {

      my $t_grp_id = $row->{'TraitGroupId'};
      my $owner    = $row->{'OperatorId'};

      if (defined $entry_lookup->{$t_grp_id}) {

        my $entry_aref = [];
        my $entry_data = $entry_lookup->{$t_grp_id};

        for my $entry_info (@{$entry_data}) {

          my $trait_id = $entry_info->{'TraitId'};
          $entry_info->{'removeTrait'} = "traitgroup/${t_grp_id}/remove/trait/$trait_id";

          push(@{$entry_aref}, $entry_info);
        }
        $row->{'traitgroupentry'} = $entry_aref;
      }


      if ("$owner" eq "$user_id") {

        $row->{'update'}   = "update/traitgroup/$t_grp_id";

        if ( $not_used_id_href->{$t_grp_id} ) {

          $row->{'delete'}   = "delete/traitgroup/$t_grp_id";
        }
      }

      push(@{$extra_attr_t_grp_data}, $row);
    }
  }
  else {

    $extra_attr_t_grp_data = $data_aref;
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_t_grp_data);
}

sub list_traitgroup_advanced_runmode {

=pod list_traitgroup_advanced_HELP_START
{
"OperationName": "List traitgroup",
"Description": "Return list of traitgroups. This listing requires pagination definition.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><StatInfo Unit='second' ServerElapsedTime='0.015' /><RecordMeta TagName='TraitGroup' /><TraitGroup OperatorId='0' update='update/traitgroup/7' OperatorUserName='admin' TraitGroupName='TraitGroup_60743915730' TraitGroupId='7'><traitgroupentry TraitGroupId='7' TraitId='55' TraitGroupEntryId='13' removeTrait='traitgroup/7/remove/trait/55' /><traitgroupentry TraitId='56' TraitGroupId='7' TraitGroupEntryId='14' removeTrait='traitgroup/7/remove/trait/56' /></TraitGroup><TraitGroup TraitGroupName='TraitGroup_59313474852' TraitGroupId='6' OperatorUserName='admin' OperatorId='0' update='update/traitgroup/6'><traitgroupentry TraitId='53' TraitGroupId='6' TraitGroupEntryId='11' removeTrait='traitgroup/6/remove/trait/53' /><traitgroupentry TraitId='54' TraitGroupId='6' TraitGroupEntryId='12' removeTrait='traitgroup/6/remove/trait/54' /></TraitGroup><Pagination NumPerPage='2' Page='1' NumOfRecords='7' NumOfPages='4' /></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfRecords' : '7','NumPerPage' : '2','NumOfPages' : 4,'Page' : '1'}],'StatInfo' : [{'ServerElapsedTime' : '0.014','Unit' : 'second'}],'RecordMeta' : [{'TagName' : 'TraitGroup'}],'TraitGroup' : [{'OperatorId' : '0','traitgroupentry' : [{'TraitGroupId' : '7','TraitGroupEntryId' : '13','removeTrait' : 'traitgroup/7/remove/trait/55','TraitId' : '55'},{'TraitGroupEntryId' : '14','TraitGroupId' : '7','removeTrait' : 'traitgroup/7/remove/trait/56','TraitId' : '56'}],'TraitGroupId' : '7','TraitGroupName' : 'TraitGroup_60743915730','update' : 'update/traitgroup/7','OperatorUserName' : 'admin'},{'OperatorUserName' : 'admin','update' : 'update/traitgroup/6','traitgroupentry' : [{'TraitGroupId' : '6','TraitGroupEntryId' : '11','removeTrait' : 'traitgroup/6/remove/trait/53','TraitId' : '53'},{'TraitGroupEntryId' : '12','TraitGroupId' : '6','TraitId' : '54','removeTrait' : 'traitgroup/6/remove/trait/54'}],'TraitGroupId' : '6','TraitGroupName' : 'TraitGroup_59313474852','OperatorId' : '0'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected error.' /><StatInfo ServerElapsedTime='0.012' Unit='second' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected error.'}],'StatInfo' : [{'ServerElapsedTime' : '0.013','Unit' : 'second'}]}"}],
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
  my $field_list = ['traitgroup.*'];

  my $sql   = "SELECT * from traitgroup LIMIT 1";

  $self->logger->debug("SQL: $sql");

  my ($sam_t_grp_err, $sam_t_grp_msg, $sam_t_grp_data) = $self->list_traitgroup(0, $sql);

  if ($sam_t_grp_err) {

    $self->logger->debug($sam_t_grp_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $sample_data_aref = $sam_t_grp_data;

  my @field_list_all;

  if (scalar(@{$sample_data_aref}) == 1) {

    @field_list_all = keys(%{$sample_data_aref->[0]});
  }
  else {

    $self->logger->debug("It reaches here");
    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'traitgroup');

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
                                                                                'TraitGroupId');

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

  if ($field_lookup->{'OperatorId'} == 1) {

    $other_join .= ' LEFT JOIN systemuser ON traitgroup.OperatorId = systemuser.UserId ';
    push(@{$final_field_list}, ' systemuser.UserName AS OperatorUserName ');
  }

  $sql   = "SELECT " . join(',', @{$final_field_list});
  $sql  .= " FROM traitgroup ";
  $sql  .= " $other_join ";

  $self->logger->debug("Filtering CSV: $filtering_csv");

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering('TraitGroupId',
                                                                              'traitgroup',
                                                                              $filtering_csv,
                                                                              $final_field_list);

  $self->logger->debug("Filter phrase: $filter_phrase");

  if ($filter_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $filter_msg}]};

    return $data_for_postrun_href;
  }

  my $filter_where_phrase = '';
  if (length($filter_phrase) > 0) {

    $filter_where_phrase = " WHERE $filter_phrase ";
  }

  my $filtering_exp = " $filter_where_phrase ";

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

    $self->logger->debug("Filtering expression: $filtering_exp");

    my ($pg_id_err, $pg_id_msg, $nb_records,
        $nb_pages, $limit_clause, $rcount_time) = get_paged_filter($dbh,
                                                                   $nb_per_page,
                                                                   $page,
                                                                   'traitgroup',
                                                                   'TraitGroupId',
                                                                   $filtering_exp,
                                                                   $where_arg);

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

  $sql  .=  " $filtering_exp ";

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

    $sql .= ' ORDER BY traitgroup.TraitGroupId DESC';
  }

  $sql .= " $paged_limit_clause ";

  $self->logger->debug("SQL with VCol: $sql");

  my ($read_t_grp_err, $read_t_grp_msg, $t_grp_data) = $self->list_traitgroup(1, $sql, $where_arg);

  if ($read_t_grp_err) {

    $self->logger->debug($read_t_grp_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'TraitGroup'      => $t_grp_data,
                                           'Pagination'      => $pagination_aref,
                                           'RecordMeta'      => [{'TagName' => 'TraitGroup'}],
                                          };

  return $data_for_postrun_href;
}

sub get_traitgroup_runmode {

=pod get_traitgroup_HELP_START
{
"OperationName": "Get traitgroup",
"Description": "Return detailed information about traitgroup specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='TraitGroup' /><TraitGroup OperatorUserName='admin' update='update/traitgroup/7' TraitGroupId='7' TraitGroupName='TraitGroup_60743915730' OperatorId='0'><traitgroupentry TraitGroupId='7' removeTrait='traitgroup/7/remove/trait/55' TraitGroupEntryId='13' TraitId='55' /><traitgroupentry TraitId='56' TraitGroupEntryId='14' removeTrait='traitgroup/7/remove/trait/56' TraitGroupId='7' /></TraitGroup><StatInfo Unit='second' ServerElapsedTime='0.011' /></DATA>",
"SuccessMessageJSON": "{'TraitGroup' : [{'update' : 'update/traitgroup/7','traitgroupentry' : [{'TraitId' : '55','TraitGroupEntryId' : '13','removeTrait' : 'traitgroup/7/remove/trait/55','TraitGroupId' : '7'},{'TraitId' : '56','TraitGroupEntryId' : '14','removeTrait' : 'traitgroup/7/remove/trait/56','TraitGroupId' : '7'}],'OperatorUserName' : 'admin','TraitGroupName' : 'TraitGroup_60743915730','TraitGroupId' : '7','OperatorId' : '0'}],'RecordMeta' : [{'TagName' : 'TraitGroup'}],'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.011'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><StatInfo ServerElapsedTime='0.003' Unit='second' /><Error Message='TraitGroup (17) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'StatInfo' : [{'ServerElapsedTime' : '0.010','Unit' : 'second'}],'Error' : [{'Message' : 'TraitGroup (17) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TraitGroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self    = shift;
  my $t_grp_id  = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  if (!record_existence($dbh, 'traitgroup', 'TraitGroupId', $t_grp_id)) {

    my $err_msg = "TraitGroup ($t_grp_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = "SELECT traitgroup.*, systemuser.UserName AS OperatorUserName ";
  $sql   .= "FROM traitgroup LEFT JOIN systemuser ON traitgroup.OperatorId = systemuser.UserId ";
  $sql   .= "WHERE TraitGroupId=?";

  my ($read_t_grp_err, $read_t_grp_msg, $t_grp_data) = $self->list_traitgroup(1, $sql, [$t_grp_id]);

  if ($read_t_grp_err) {

    $self->logger->debug($read_t_grp_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'TraitGroup'      => $t_grp_data,
                                           'RecordMeta'      => [{'TagName' => 'TraitGroup'}],
  };

  return $data_for_postrun_href;
}

sub add_trait2traitgroup_runmode {

=pod add_trait2traitgroup_HELP_START
{
"OperationName": "Add more traits to a trait group",
"Description": "Add more traits into a trait group specified by id",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><StatInfo ServerElapsedTime='0.080' Unit='second' /><Info Message='Trait (72,73) has been added to TraitGroup (11) successfully.' /></DATA>",
"SuccessMessageJSON": "{'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.091'}],'Info' : [{'Message' : 'Trait (76,77) has been added to TraitGroup (12) successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><StatInfo Unit='second' ServerElapsedTime='0.017' /><Error Message='TraitGroup (20): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'TraitGroup (15): not found.'}],'StatInfo' : [{'ServerElapsedTime' : '0.014','Unit' : 'second'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "XML",
"UploadFileParameterName": "uploadfile",
"DTDFileNameForUploadXML": "traitgroupentry.dtd",
"URLParameter": [{"ParameterName": "id", "Description": "Existing TraitGroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self   = $_[0];
  my $t_grp_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_read = connect_kdb_read();

  my $owner = read_cell_value($dbh_read, 'traitgroup', 'OperatorId', 'TraitGroupId', $t_grp_id);

  if ( length($owner) == 0 ) {

    my $err_msg = "TraitGroup ($t_grp_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $user_id = $self->authen->user_id();

  if ("$owner" ne "$user_id") {

    my $err_msg = "TraitGroup ($t_grp_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $entry_xml_file           = $self->authen->get_upload_file();
  my $traitgroupentry_dtd_file = $self->get_traitgroupentry_dtd_file();

  $self->logger->debug("Traitgroupentry DTD: $traitgroupentry_dtd_file");

  add_dtd($traitgroupentry_dtd_file, $entry_xml_file);

  my $traitgroup_xml = read_file($entry_xml_file);

  $self->logger->debug("XML file with DTD: $traitgroup_xml");

  my $xml_checker_parser = new XML::Checker::Parser( Handlers => { } );

  eval {

    local $XML::Checker::FAIL = sub {

      my $code = shift;
      my $err_str = XML::Checker::error_string ($code, @_);
      $self->logger->debug("XML Parsing ERR: $code : $err_str");
      die $err_str;
    };
    $xml_checker_parser->parsefile($entry_xml_file);
  };

  if ($@) {

    my $err_msg = $@;
    $self->logger->debug("Parsing XML error: $err_msg");
    my $user_err_msg = "traitgroupentry xml file does not comply with its definition.\n";
    $user_err_msg   .= "Details: $err_msg";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $user_err_msg}]};

    return $data_for_postrun_href;
  }

  my $trait_entry_aref = xml2arrayref($traitgroup_xml, 'traitgroupentry');

  my $trait_id_aref      = [];
  my $uniq_trait_id_href = {};

  my $sql = '';

  for my $trait_entry_info (@{$trait_entry_aref}) {

    my $trait_id = $trait_entry_info->{'TraitId'};

    $sql = 'SELECT TraitGroupEntryId FROM traitgroupentry WHERE TraitGroupId=? AND TraitId=?';

    my ($r_t_grp_entry_id, $db_t_grp_entry_id) = read_cell($dbh_read, $sql, [$t_grp_id, $trait_id]);

    if (length($db_t_grp_entry_id) > 0) {

      my $err_msg = "Trait ($trait_id): already in TraitGroup ($t_grp_id).";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if (defined $uniq_trait_id_href->{$trait_id}) {

      my $err_msg = "Trait ($trait_id): duplicate.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    else {

      $uniq_trait_id_href->{$trait_id} = 1;
    }

    push(@{$trait_id_aref}, $trait_id);
  }

  my $chk_table_aref = [{'TableName' => 'trait', 'FieldName' => 'TraitId'}];

  my ($chk_id_err, $chk_id_msg,
      $id_exist_href, $id_not_exist_href) = id_existence_bulk($dbh_read, $chk_table_aref, $trait_id_aref);

  if ($chk_id_err) {

    $self->logger->debug("Check id existence error: $chk_id_msg");

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (scalar(keys(%{$id_not_exist_href})) > 0) {

    my $err_msg = "Trait (" . join(',', keys(%{$id_not_exist_href})) . "): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_trait_ok, $trouble_trait_id_aref) = check_permission($dbh_read, 'trait', 'TraitId',
                                                               $trait_id_aref, $group_id, $gadmin_status,
                                                               $READ_LINK_PERM);

  if (!$is_trait_ok) {

    my $trouble_trait_id = $trouble_trait_id_aref->[0];

    my $err_msg = "Permission denied: Group ($group_id) and Trait ($trouble_trait_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  $sql  = 'INSERT INTO traitgroupentry ';
  $sql .= '(TraitGroupId,TraitId) ';
  $sql .= 'VALUES ';

  my @sql_val_list;

  for my $trait_id (@{$trait_id_aref}) {

    push(@sql_val_list, qq|($t_grp_id, $trait_id)|);
  }

  $sql .= join(',', @sql_val_list);

  $self->logger->debug("SQL: $sql");

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute();

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref  = [{'Message' => "Trait (" . join(',', @{$trait_id_aref}) . ") has been added to TraitGroup ($t_grp_id) successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub remove_trait_from_traitgroup_runmode {

=pod remove_trait_from_traitgroup_HELP_START
{
"OperationName": "Remove trait from traitgroup",
"Description": "Remove trait specified by id from traitgroup specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId ParaName='TraitGroupId' Value='17' /><Info Message='TraitGroup (17) has been added successfully.' /><StatInfo ServerElapsedTime='0.127' Unit='second' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Trait (96) has been removed from TraitGroup (18) successfully.'}],'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.032'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TraitGroup (127): not found.' /><StatInfo Unit='second' ServerElapsedTime='0.005' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.005'}],'Error' : [{'Message' : 'TraitGroup (127): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing traitgroup id"}, {"ParameterName": "tid", "Description": "Trait id which is part of specified traitgroup"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self               = shift;
  my $t_grp_id           = $self->param('id');
  my $trait_id           = $self->param('tid');

  my $data_for_postrun_href = {};

  my $dbh_read = connect_kdb_read();

  my $owner = read_cell_value($dbh_read, 'traitgroup', 'OperatorId', 'TraitGroupId', $t_grp_id);

  if ( length($owner) == 0 ) {

    my $err_msg = "TraitGroup ($t_grp_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $user_id = $self->authen->user_id();

  if ("$owner" ne "$user_id") {

    my $err_msg = "TraitGroup ($t_grp_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT TraitGroupEntryId FROM traitgroupentry WHERE TraitGroupId=? AND TraitId=?';

  my ($r_t_grp_entry_err, $t_grp_entry_id) = read_cell($dbh_read, $sql, [$t_grp_id, $trait_id]);

  if ($r_t_grp_entry_err) {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($t_grp_entry_id) == 0) {

    my $err_msg = "Trait ($trait_id): not part of TraitGroup ($t_grp_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_read->disconnect();

  my $dbh_write = connect_kdb_write();

  $sql  = 'DELETE FROM traitgroupentry WHERE TraitGroupEntryId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($t_grp_entry_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "Trait ($trait_id) has been removed from TraitGroup ($t_grp_id) successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub del_traitgroup_runmode {

=pod del_traitgroup_HELP_START
{
"OperationName": "Delete traitgroup",
"Description": "Delete traitgroup grouping specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='TraitGroup (21) has been deleted successfully.' /><StatInfo Unit='second' ServerElapsedTime='0.039' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'TraitGroup (22) has been deleted successfully.'}],'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.037'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TraitGroup (30): not found.' /><StatInfo Unit='second' ServerElapsedTime='0.004' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'StatInfo' : [{'ServerElapsedTime' : '0.004','Unit' : 'second'}],'Error' : [{'Message' : 'TraitGroup (30): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TraitGroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self               = shift;
  my $t_grp_id           = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_read = connect_kdb_read();

  my $owner = read_cell_value($dbh_read, 'traitgroup', 'OperatorId', 'TraitGroupId', $t_grp_id);

  if ( length($owner) == 0 ) {

    my $err_msg = "TraitGroup ($t_grp_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $user_id = $self->authen->user_id();

  if ("$owner" ne "$user_id") {

    my $err_msg = "TraitGroup ($t_grp_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (record_existence($dbh_read, 'traitgroupentry', 'TraitGroupId', $t_grp_id)) {

    my $err_msg = "TraitGroup ($t_grp_id): traitgroupentry records exist.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_read->disconnect();

  my $dbh_write = connect_kdb_write();

  my $sql  = 'DELETE FROM traitgroup WHERE TraitGroupId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($t_grp_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "TraitGroup ($t_grp_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub get_traitgroupentry_dtd_file {

  my $dtd_path = $ENV{DOCUMENT_ROOT} . '/' . $DTD_PATH;

  return "${dtd_path}/traitgroupentry.dtd";
}

sub logger {

  my $self = shift;
  return $self->{logger};
}

#version 2 of import sample measurement functions that return all errors in the CSV

#inserting with returning of collective errors
#Update 28/03/2023: Allow SurveyId
sub insert_samplemeasurement_data_v2 {

  my $self                = $_[0];
  my $dbh_write           = $_[1];
  my $data_aref           = $_[2];
  my $chk_non_trait_field = $_[3];
  my $validate_trait      = $_[4];

  my $enforce_single_trial_data = 0;

  if (defined $_[5]) {

    $enforce_single_trial_data = $_[5];
  }

  my $smgroup_id = 0;

  if (defined $_[6]) {

    $smgroup_id = $_[6];
  }

  my $global_trial_id = undef;

  if (defined $_[7]) {

    $global_trial_id = $_[7];
  }

  my $data_for_postrun_href = {};

  my $user_id       = $self->authen->user_id();
  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str      = permission_phrase($group_id, 0, $gadmin_status);

  #full error array with the following format for individual errors
  # {'Row' => row of error, 'Type' => type of error, 'Message' => 'message', 'ErrorInput' => what input caused error}
  my $full_error_aref = [];

  if (scalar(@{$data_aref}) == 0) {

    $self->logger->debug("No data provided");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'No data provided.'}]};

    return $data_for_postrun_href;
  }

  my $bulk_sql = 'INSERT INTO samplemeasurement ';
  $bulk_sql   .= '(TrialUnitId,SampleTypeId,SMGroupId,TraitId,OperatorId,MeasureDateTime,InstanceNumber,TraitValue,TrialUnitSpecimenId,StateReason,
  SurveyId) ';
  $bulk_sql   .= 'VALUES ';

  my $sql;
  my $sth;

  my $uniq_tunit_href         = {};
  my $tunit_val_aref          = [];
  my $tunit_idx_aref          = [];

  my $uniq_sam_type_href      = {};
  my $sam_type_val_aref       = [];
  my $sam_type_idx_aref       = [];

  my $uniq_survey_href         = {};
  my $survey_val_aref          = [];
  my $survey_idx_aref          = [];

  my $survey_tu_check_href     = {};
  my $survey_tu_check_val_aref = [];
  my $survey_tu_check_idx_aref = [];

  my $uniq_trait_id_href      = {};
  my $trait_id_val_aref       = [];
  my $trait_id_idx_aref       = [];

  my $tu_trait_id_val_aref    = [];
  my $tu_trait_id_idx_aref    = [];

  my $uniq_operator_href      = {};
  my $operator_val_aref       = [];
  my $operator_idx_aref       = [];

  my $tu_tu_spec_val_aref     = [];
  my $tu_tu_spec_idx_aref     = [];

  my $trait_id2val_href       = {};
  my $trait_id2idx_href       = {};

  my $row_with_survey_href    = {};

  my $date_error_flag = 0;
  my $date_error_aref = [];

  my $row_counter = 1;
  for my $data_row (@{$data_aref}) {
    $self->logger->debug("$row_counter:");
    for my $data_key (keys(%{$data_row})) {
      $self->logger->debug("$data_key -> " .$data_row->{$data_key});
    }
    $self->logger->debug("----");

    my $effective_user_id = $user_id;
    my $trialunit_id      = $data_row->{'TrialUnitId'};
    my $samp_type_id      = $data_row->{'SampleTypeId'};
    my $trait_id          = $data_row->{'TraitId'};

    my $tu_spec_id        = '0';

    my $survey_id         = 'NULL';

    $uniq_trait_id_href->{$trait_id}     = 1;
    $uniq_sam_type_href->{$samp_type_id} = 1;

    #$self->logger->debug("Checking non trait data: $chk_non_trait_field");

    if ($chk_non_trait_field) {

      my ($int_id_err, $int_id_msg) = check_integer_value( { 'TrialUnitId'    => $data_row->{'TrialUnitId'},
                                                             'SampleTypeId'   => $data_row->{'SampleTypeId'},
                                                             'TraitId'        => $data_row->{'TraitId'},
                                                             'InstanceNumber' => $data_row->{'InstanceNumber'},
                                                           });

      if ($int_id_err) {

        $int_id_msg = "Row ($row_counter): " . $int_id_msg . ' not integer.';

        my $error_obj = {};

        $error_obj->{'Message'} = $int_id_msg;
        $error_obj->{'Row'} = $row_counter;
        $error_obj->{'Type'} = 'TrialUnitInteger';
        $error_obj->{'ErrorInput'} = $int_id_msg;

        push(@{$full_error_aref}, $error_obj);
      }

      if (length($data_row->{'OperatorId'}) > 0) {

        my $operator_id = $data_row->{'OperatorId'};

        my ($int_err, $int_msg) = check_integer_value( { 'OperatorId' => $operator_id } );

        if ($int_err) {

          $int_msg = "Row ($row_counter): " . $int_msg . ' not an integer.';

          my $error_obj = {};

          $error_obj->{'Message'} = $int_msg;
          $error_obj->{'Row'} = $row_counter;
          $error_obj->{'Type'} = 'OperatorInteger';
          $error_obj->{'ErrorInput'} = $int_id_msg;

          push(@{$full_error_aref}, $error_obj);
        }

        $uniq_operator_href->{$operator_id} = 1;
        push(@{$operator_val_aref}, $operator_id);
        push(@{$operator_idx_aref}, $row_counter);

        $effective_user_id = $operator_id;
      }
    }

    $uniq_tunit_href->{$trialunit_id} = 1;
    push(@{$tunit_val_aref}, $trialunit_id);
    push(@{$tunit_idx_aref}, $row_counter);

    push(@{$tu_trait_id_val_aref}, [$trialunit_id, $trait_id]);
    push(@{$tu_trait_id_idx_aref}, $row_counter);

    push(@{$sam_type_val_aref},$samp_type_id);
    push(@{$sam_type_idx_aref},$row_counter);

    if (length($data_row->{'OperatorId'}) > 0) {

      $effective_user_id = $data_row->{'OperatorId'};
    }

    if (defined $data_row->{'TrialUnitSpecimenId'}) {

      if (length($data_row->{'TrialUnitSpecimenId'}) > 0) {

        $tu_spec_id = $data_row->{'TrialUnitSpecimenId'};

        push(@{$tu_tu_spec_val_aref}, [$trialunit_id, $tu_spec_id]);
        push(@{$tu_tu_spec_idx_aref}, $row_counter);
      }
    }

    if (defined $data_row->{'SurveyId'}) {

      if (length($data_row->{'SurveyId'}) > 0) {

        $survey_id = $data_row->{'SurveyId'};

        my ($int_err, $int_msg) = check_integer_value( { 'SurveyId' => $survey_id } );

        if ($int_err) {

          $int_msg = "Row ($row_counter): " . $int_msg . ' not an integer.';
  

          my $error_obj = {};

          $error_obj->{'Message'} = $int_msg;
          $error_obj->{'Row'} = $row_counter;
          $error_obj->{'Type'} = 'SurveyInteger';
          $error_obj->{'ErrorInput'} = $survey_id;

          push(@{$full_error_aref}, $error_obj);
        }

        $uniq_survey_href->{$survey_id} = 1;
        push(@{$survey_val_aref}, $survey_id);
        push(@{$survey_idx_aref}, $row_counter);

        $row_with_survey_href->{$row_counter} = $survey_id;

        #$survey_tu_check_href->{$survey_id} = {};
        #$survey_tu_check_href->{$survey_id}->{$trialunit_id} = 1;

        push(@{$survey_tu_check_val_aref}, [$trialunit_id, $survey_id]);
        push(@{$survey_tu_check_idx_aref}, $row_counter);
      }
    }

    my $trait_val = $data_row->{'TraitValue'};
    my $db_trait_val = $dbh_write->quote($trait_val);

    if ($validate_trait) {

      if (defined $trait_id2val_href->{$trait_id}) {

        my $val_aref = $trait_id2val_href->{$trait_id};
        push(@{$val_aref}, $trait_val);
        $trait_id2val_href->{$trait_id} = $val_aref;
      }
      else {

        $trait_id2val_href->{$trait_id} = [$trait_val];
      }

      if (defined $trait_id2idx_href->{$trait_id}) {

        my $idx_aref = $trait_id2idx_href->{$trait_id};
        push(@{$idx_aref}, $row_counter);
        $trait_id2idx_href->{$trait_id} = $idx_aref;
      }
      else {

        $trait_id2idx_href->{$trait_id} = [$row_counter];
      }
    }

    my $measure_dt   = $data_row->{'MeasureDateTime'};

    # Check measure date/time

    my ($measure_dt_err, $measure_dt_msg) = check_dt_value( {'MeasureDateTime' => $measure_dt} );

    if ($measure_dt_err) {

      my $error_obj = {};

      $error_obj->{'Message'} = $measure_dt_msg;
      $error_obj->{'Row'} = $row_counter;
      $error_obj->{'Type'} = 'Date';
      $error_obj->{'ErrorInput'} = $measure_dt;

      push(@{$full_error_aref}, $error_obj);
    }

    # End check measure date/time

    my $instance_num = $data_row->{'InstanceNumber'};

    my $state_reason      = 'NULL';

    if (defined $data_row->{'StateReason'}) {

      if (length($data_row->{'StateReason'}) > 0) {

        $state_reason = $dbh_write->quote($data_row->{'StateReason'});
      }
    }

    $bulk_sql .= "($trialunit_id,$samp_type_id,$smgroup_id,$trait_id,$effective_user_id,";
    $bulk_sql .= "'$measure_dt',$instance_num,$db_trait_val,$tu_spec_id,$state_reason, $survey_id),";

    $row_counter += 1;
  }

  chop($bulk_sql);      # remove excessive comma
  #

  my @trait_id_list = keys(%{$uniq_trait_id_href});

  if (scalar(@trait_id_list) == 0) {

    $self->logger->debug("List of trait id is empty");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  # Release the memorny
  $uniq_trait_id_href = {};

  $sql  = "SELECT TraitId, $perm_str AS UltimatePerm ";
  $sql .= "FROM trait ";
  $sql .= "WHERE TraitId IN (" . join(',', @trait_id_list) . ')';

  my $trait_lookup = $dbh_write->selectall_hashref($sql, 'TraitId');

  if ($dbh_write->err()) {

    $self->logger->debug("Get trait info failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my @tu_id_list = keys(%{$uniq_tunit_href});

  if (scalar(@tu_id_list) == 0) {

    $self->logger->debug("List of trial unit id is empty");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  # Release the memory
  $uniq_tunit_href = {};

  $sql  = "SELECT trialunit.TrialUnitId, trial.TrialId, $perm_str AS UltimatePerm, ";
  $sql .= "TraitId, TrialUnitSpecimenId ";
  $sql .= "FROM trialunit LEFT JOIN trial ON trialunit.TrialId = trial.TrialId ";
  $sql .= "LEFT JOIN trialunitspecimen ON trialunit.TrialUnitId = trialunitspecimen.TrialUnitId ";
  $sql .= "LEFT JOIN trialtrait ON trial.TrialId = trialtrait.TrialId ";
  $sql .= "WHERE trialunit.TrialUnitId IN (" . join(',', @tu_id_list) . ')';

  my $trialunit_info_href = {};

  my ($r_tu_err, $r_tu_msg, $tu_data) = read_data($dbh_write, $sql, []);

  if ($r_tu_err) {

    $self->logger->debug("Get trial unit info failed: $r_tu_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $uniq_trial_href = {};

  
  foreach my $tu_rec (@{$tu_data}) {

    my $tu_id      = $tu_rec->{'TrialUnitId'};
    my $trial_id   = $tu_rec->{'TrialId'};
    my $trial_perm = $tu_rec->{'UltimatePerm'};
    my $trait_id   = $tu_rec->{'TraitId'};
    my $tu_spec_id = $tu_rec->{'TrialUnitSpecimenId'};

    my $trialtrait_id   = $tu_rec->{'TraitId'};

    $uniq_trial_href->{$trial_id} = 1;

    if (! defined $trialunit_info_href->{$tu_id}) {

      $trialunit_info_href->{$tu_id} = {};
    }

    $trialunit_info_href->{$tu_id}->{'TrialId'}       = $trial_id;
    $trialunit_info_href->{$tu_id}->{'Permission'}    = $trial_perm;

    if (! defined $trialunit_info_href->{$tu_id}->{'TraitInfo'}) {

      $trialunit_info_href->{$tu_id}->{'TraitInfo'} = {};
    }

    $trialunit_info_href->{$tu_id}->{'TraitInfo'}->{$trialtrait_id} = 1;

    if (! defined $trialunit_info_href->{$tu_id}->{'TrialUnitSpecInfo'}) {

      $trialunit_info_href->{$tu_id}->{'TrialUnitSpecInfo'} = {};
    }

    $trialunit_info_href->{$tu_id}->{'TrialUnitSpecInfo'}->{$tu_spec_id} = 1;
  }

  $sql  = "SELECT surveytrialunit.TrialUnitId, surveytrialunit.SurveyId, $perm_str AS UltimatePerm, ";
  $sql .= "surveytrait.TraitId ";
  $sql .= "FROM trialunit LEFT JOIN trial ON trial.TrialId = trialunit.TrialId ";
  $sql .= "LEFT JOIN surveytrialunit ON surveytrialunit.TrialUnitId = trialunit.TrialUnitId ";
  $sql .= "LEFT JOIN trialunitspecimen ON surveytrialunit.TrialUnitId = trialunitspecimen.TrialUnitId ";
  $sql .= "LEFT JOIN surveytrait ON surveytrait.SurveyId = surveytrialunit.SurveyId ";
  $sql .= "WHERE trialunit.TrialUnitId IN (" . join(',', @tu_id_list) . ')';

  my ($r_stu_err, $r_stu_msg, $stu_data) = read_data($dbh_write, $sql, []);

  if ($r_stu_err) {

    $self->logger->debug("Get survey trial unit info failed: $r_stu_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

   foreach my $stu_rec (@{$stu_data}) {

    my $tu_id      = $stu_rec->{'TrialUnitId'};
    my $trait_id   = $stu_rec->{'TraitId'};
    my $survey_id  = $stu_rec->{'SurveyId'};

    my $surveytrait_id   = $stu_rec->{'TraitId'};

    if (! defined $trialunit_info_href->{$tu_id}->{'SurveyInfo'}) {

      $trialunit_info_href->{$tu_id}->{'SurveyInfo'} = {};
    }

    if (! defined $trialunit_info_href->{$tu_id}->{'SurveyInfo'}->{$survey_id}) {

      $trialunit_info_href->{$tu_id}->{'SurveyInfo'}->{$survey_id} = {};
    }

    $trialunit_info_href->{$tu_id}->{'SurveyInfo'}->{$survey_id}->{$surveytrait_id} = 1;
  }


  if ($enforce_single_trial_data == 1) {

    my @data_trial_list = keys(%{$uniq_trial_href});

    if (scalar(@data_trial_list) > 1) {

      my $err_msg = "Data from more than one trial not allowed.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    elsif (scalar(@data_trial_list) == 1) {

      if ($data_trial_list[0] != $global_trial_id) {

        my $err_msg = "TrialId derived from upload data and TrialId provided via interface are not the same.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
  }

  for (my $i = 0; $i < scalar(@{$tunit_val_aref}); $i++) {

    my $tu_id    = $tunit_val_aref->[$i];
    my $row_num  = $tunit_idx_aref->[$i];

    if (! defined $trialunit_info_href->{$tu_id}) {

      my $err_msg = "Row ($row_num): TrialUnit ($tu_id) does not exist.";

      my $error_obj = {};

      $error_obj->{'Message'} = $err_msg;
      $error_obj->{'Row'} = $row_num;
      $error_obj->{'Type'} = "TrialUnit";
      #$error_obj->{'Date'} = $measure_dt;
      $error_obj->{'ErrorInput'} = "TrialUnit ($tu_id)";

      push(@{$full_error_aref}, $error_obj);
    }
    else {
      my $trial_id         = $trialunit_info_href->{$tu_id}->{'TrialId'};
      my $trial_permission = $trialunit_info_href->{$tu_id}->{'Permission'};

      if ( ($trial_permission & $READ_WRITE_PERM) != $READ_WRITE_PERM ) {

        my $perm_err_msg = "Row ($row_num): Permission denied, Group ($group_id) and Trial ($trial_id).";

        my $error_obj = {};

        $error_obj->{'Message'} = $perm_err_msg;
        $error_obj->{'Row'} = $row_num;
        $error_obj->{'Type'} = "Trial Permission";
        #$error_obj->{'Date'} = $measure_dt;
        $error_obj->{'ErrorInput'} = "Group ($group_id) and Trial ($trial_id)";

        push(@{$full_error_aref}, $error_obj);
      }
    }
  }

  for (my $i = 0; $i < scalar(@{$tu_trait_id_val_aref}); $i++) {

    my $row_num   = $tu_trait_id_idx_aref->[$i];
    my $tu_id     = $tu_trait_id_val_aref->[$i]->[0];
    my $trait_id  = $tu_trait_id_val_aref->[$i]->[1];

    $self->logger->debug("$row_num: $tu_id, $trait_id");
    $self->logger->debug(defined $trialunit_info_href->{$tu_id});

    if (defined $trialunit_info_href->{$tu_id}) {
      if ( ! defined $trait_lookup->{$trait_id} ) {

        my $err_msg = "Row ($row_num): Trait ($trait_id) not found.";

        my $error_obj = {};

        $error_obj->{'Message'} = $err_msg;
        $error_obj->{'Row'} = $row_num;
        $error_obj->{'Type'} = "Trait";
        #$error_obj->{'Date'} = $measure_dt;
        $error_obj->{'ErrorInput'} = "Trait ($trait_id)";

        push(@{$full_error_aref}, $error_obj);
      }
      else {
        my $trait_perm = $trait_lookup->{$trait_id}->{'UltimatePerm'};

        if ( ($trait_perm & $LINK_PERM) != $LINK_PERM ) {

          my $perm_err_msg = "Row ($row_num): Permission denied, Group ($group_id) and Trait ($trait_id).";
          my $error_obj = {};

          $error_obj->{'Message'} = $perm_err_msg;
          $error_obj->{'Row'} = $row_num;
          $error_obj->{'Type'} = "Trait Permission";
          #$error_obj->{'Date'} = $measure_dt;
          $error_obj->{'ErrorInput'} = "Group ($group_id) and Trait ($trait_id)";

          push(@{$full_error_aref}, $error_obj);
        }

        #is the csv row trying add a sm with SurveyId? 

        if (defined $row_with_survey_href->{$row_num}) {
          
          my $row_survey_id = $row_with_survey_href->{$row_num};

          if ( ! defined $trialunit_info_href->{$tu_id}->{'SurveyInfo'}->{$row_survey_id} ) {
            
            #issue because this tu is not part of this survey 

            my $error_obj = {};

            $error_obj->{'Message'} = "Trial Unit $tu_id is not part of Survey $row_survey_id";
            $error_obj->{'Row'} = $row_num;
            $error_obj->{'Type'} = "Survey Trial Unit";
            #$error_obj->{'Date'} = $measure_dt;
            $error_obj->{'ErrorInput'} = "Trial Unit ($tu_id) and Survey ($row_survey_id)";

            push(@{$full_error_aref}, $error_obj);
          
          }
          else {

            if ( ! defined $trialunit_info_href->{$tu_id}->{'SurveyInfo'}->{$row_survey_id}->{$trait_id} ) {

              my $err_msg = "Row ($row_num): Trait ($trait_id) is not attached to Survey ($row_survey_id).";
              my $error_obj = {};

              $error_obj->{'Message'} = $err_msg;
              $error_obj->{'Row'} = $row_num;
              $error_obj->{'Type'} = "Trait Attach";
              #$error_obj->{'Date'} = $measure_dt;
              $error_obj->{'ErrorInput'} = "Trait ($trait_id) and Survey ($row_survey_id)";

              push(@{$full_error_aref}, $error_obj);

            }

          }


        }
        else {
          if ( ! defined $trialunit_info_href->{$tu_id}->{'TraitInfo'}->{$trait_id} ) {

            my $trial_id = $trialunit_info_href->{$tu_id}->{'TrialId'};

            my $err_msg = "Row ($row_num): Trait ($trait_id) is not attached to Trial ($trial_id).";
            my $error_obj = {};

            $error_obj->{'Message'} = $err_msg;
            $error_obj->{'Row'} = $row_num;
            $error_obj->{'Type'} = "Trait Attach";
            #$error_obj->{'Date'} = $measure_dt;
            $error_obj->{'ErrorInput'} = "Trait ($trait_id) and Trial ($trial_id)";

            push(@{$full_error_aref}, $error_obj);
          }
        }


        
      }
    }
  }

  my @operator_list = keys(%{$uniq_operator_href});

  if (scalar(@operator_list) > 0) {

    $sql = "SELECT UserId FROM systemuser WHERE UserId IN (" . join(',', @operator_list) . ")";

    my $operator_lookup = $dbh_write->selectall_hashref($sql, 'UserId');

    if ($dbh_write->err()) {

      $self->logger->debug("Get operator info failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    for (my $i = 0; $i < scalar(@{$operator_val_aref}); $i++) {

      my $oper_id  = $operator_val_aref->[$i];
      my $row_num  = $operator_idx_aref->[$i];

      if (! defined $operator_lookup->{$oper_id}) {

        my $err_msg = "Row ($row_num): Operator ($oper_id) does not exist.";

        my $error_obj = {};

        $error_obj->{'Message'} = $err_msg;
        $error_obj->{'Row'} = $row_num;
        $error_obj->{'Type'} = "Operator";
        #$error_obj->{'Date'} = $measure_dt;
        $error_obj->{'ErrorInput'} = "Operator ($oper_id)";

        push(@{$full_error_aref}, $error_obj);
      }
    }
  }

  my @survey_list = keys(%{$uniq_survey_href});

  #release memory 
  $uniq_survey_href = {};

  my $survey_info = {};

  if (scalar(@survey_list) > 0) {

    $sql = "SELECT SurveyId FROM survey WHERE SurveyId IN (" . join(',', @survey_list) . ")";

    my $survey_lookup = $dbh_write->selectall_hashref($sql, 'SurveyId');

    if ($dbh_write->err()) {

      $self->logger->debug("Get survey info failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    $sql  = "SELECT TrialUnitId, SurveyId ";
    $sql .= "FROM surveytrialunit ";
    $sql .= "WHERE SurveyId IN (" . join(',', @survey_list) . ')';

    my ($r_stu_err, $r_stu_msg, $stu_data) = read_data($dbh_write, $sql, []);

    if ($dbh_write->err()) {

      $self->logger->debug("Get surveytrialunit info failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    foreach my $stu_rec (@{$stu_data}) {
      my $tu_id      = $stu_rec->{'TrialUnitId'};
      my $survey_id  = $stu_rec->{'SurveyId'};

      if (! defined $survey_info->{$survey_id}) {
          $survey_info->{$survey_id} = {};
          $survey_info->{$survey_id}->{'TrialUnit'} = {};
      }

      $self->logger->debug("Linking $tu_id and $survey_id");

      $survey_info->{$survey_id}->{'TrialUnit'}->{$tu_id} = 1;
    }

    #check if trial unit and survey matches up

    if ($dbh_write->err()) {

      $self->logger->debug("Get survey info failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    for (my $i = 0; $i < scalar(@{$survey_val_aref}); $i++) {

      my $survey_id_row  = $survey_val_aref->[$i];
      my $row_num  = $survey_idx_aref->[$i];

      if (! defined $survey_lookup->{$survey_id_row}) {

        my $err_msg = "Row ($row_num): Survey ($survey_id_row) does not exist.";

        my $error_obj = {};

        $error_obj->{'Message'} = $err_msg;
        $error_obj->{'Row'} = $row_num;
        $error_obj->{'Type'} = "Survey";
        #$error_obj->{'Date'} = $measure_dt;
        $error_obj->{'ErrorInput'} = "Survey ($survey_id_row)";

        push(@{$full_error_aref}, $error_obj);
      }
    }
  }

  my @sample_type_list = keys(%{$uniq_sam_type_href});

  if (scalar(@sample_type_list) == 0) {

    $self->logger->debug("List of sample type id is empty");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sql  = "SELECT TypeId FROM generaltype WHERE Class='sample' AND ";
  $sql .= "TypeId IN (" . join(',', @sample_type_list) . ")";

  my $sample_type_lookup = $dbh_write->selectall_hashref($sql, 'TypeId');

  if ($dbh_write->err()) {

    $self->logger->debug("Get sample type info failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  for (my $i = 0; $i < scalar(@{$sam_type_val_aref}); $i++) {

    my $sam_type_id = $sam_type_val_aref->[$i];
    my $row_num     = $sam_type_idx_aref->[$i];

    if (! defined $sample_type_lookup->{$sam_type_id}) {

      my $err_msg = "Row ($row_num): SampleType ($sam_type_id) does not exist.";

      my $error_obj = {};

      $error_obj->{'Message'} = $err_msg;
      $error_obj->{'Row'} = $row_num;
      $error_obj->{'Type'} = "SampleType";
      #$error_obj->{'Date'} = $measure_dt;
      $error_obj->{'ErrorInput'} = "SampleType ($sam_type_id)";

      push(@{$full_error_aref}, $error_obj);
    }
  }

  my $tus_mismatch_flag = 0;
  my $tus_mismatch_list = [];

  for (my $i = 0; $i < scalar(@{$tu_tu_spec_val_aref}); $i++) {

    my $tu_id      = $tu_tu_spec_val_aref->[$i]->[0];
    my $tu_spec_id = $tu_tu_spec_val_aref->[$i]->[1];
    my $row_num    = $tu_tu_spec_idx_aref->[$i];

    my $tu_spec_href = $trialunit_info_href->{$tu_id}->{'TrialUnitSpecInfo'};

    if (! defined $tu_spec_href->{$tu_spec_id}) {

        my $err_msg = "Row ($row_num): TrialUnit ($tu_id) and TrialUnitSpecimen ($tu_spec_id) not compatible.";

        my $error_obj = {};

        $error_obj->{'Message'} = $err_msg;
        $error_obj->{'Row'} = $row_num;
        $error_obj->{'Type'} = "TrialUnitSpecimen Mismatch";
        #$error_obj->{'Date'} = $measure_dt;
        $error_obj->{'ErrorInput'} = "TrialUnit ($tu_id) and TrialUnitSpecimen ($tu_spec_id)";

        push(@{$full_error_aref}, $error_obj);
    }
  }

  my $stu_mistmatch_flag = 0;
  my $stu_mismatch_list = [];

  for (my $i = 0; $i < scalar(@{$survey_tu_check_val_aref}); $i++) {

    my $tu_id      = $survey_tu_check_val_aref->[$i]->[0];
    my $survey_id  = $survey_tu_check_val_aref->[$i]->[1];
    my $row_num    = $survey_tu_check_idx_aref->[$i];

    my $stu_info_href = $survey_info->{$survey_id}->{'TrialUnit'};

    if (! defined $stu_info_href->{$tu_id}) {

        my $err_msg = "Row ($row_num): TrialUnit ($tu_id) and Survey ($survey_id) not compatible.";

        $self->logger->debug($err_msg);

        my $error_obj = {};

        $error_obj->{'Message'} = $err_msg;
        $error_obj->{'Row'} = $row_num;
        $error_obj->{'Type'} = "SurveyTrialUnit Mismatch";
        #$error_obj->{'Date'} = $measure_dt;
        $error_obj->{'ErrorInput'} = "TrialUnit ($tu_id) and Survey ($survey_id)";

        push(@{$full_error_aref}, $error_obj);
    }
  }

  # Release memory
  $tu_tu_spec_val_aref = [];
  $tu_tu_spec_idx_aref = [];
  $trialunit_info_href = {};

  my $trait_validation_error_aref = [];

  $self->logger->debug("Now trying to validate trait values");

  for my $trait_id2val (keys(%{$trait_id2val_href})) {
    $self->logger->debug("Trait: $trait_id2val");
  }

  my ($v_trait_val_err, $invalid_error_message,
      $v_trait_id_href, $trait_validation_error_aref) = validate_trait_db_bulk_v2($dbh_write, $trait_id2val_href,$self);

  $self->logger->debug("Validation Error: $v_trait_val_err");
  $self->logger->debug("Validation Error: $invalid_error_message");
  $self->logger->debug("Number of Validation Error: " . scalar(@{$trait_validation_error_aref}));

  if ($v_trait_val_err) {

    foreach my $invalid_obj (@{$trait_validation_error_aref}) {

      my $v_trait_id = $invalid_obj->{'Trait'};
      my $v_trait_idx = $invalid_obj->{'Index'};
      my $v_trait_val_msg = $invalid_obj->{'Message'};
      my $v_trait_val = $invalid_obj->{'Value'};

      $self->logger->debug("Validation error on TraitId: $v_trait_id - index: $v_trait_idx");
      my $row_num = $trait_id2idx_href->{$v_trait_id}->[$v_trait_idx];
      my $err_msg = "Row ($row_num): $v_trait_val_msg";

      my $error_obj = {};

      $error_obj->{'Message'} = $err_msg;
      $error_obj->{'Row'} = $row_num;
      $error_obj->{'Type'} = "Validation";
      #$error_obj->{'Date'} = $measure_dt;
      $error_obj->{'ErrorInput'} = "$v_trait_val (Trait $v_trait_id)";

      push(@{$full_error_aref}, $error_obj);
    }

  }

  foreach my $error_obj (@{$full_error_aref}) {
      $self->logger->debug($error_obj->{'Row'}. ": " . $error_obj->{'Message'});
  }

  if (scalar(@{$full_error_aref}) > 0) {
    my $err_msg = 'Issues with CSV identified while inserting sample measurement data';

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg,'ErrorList' => $full_error_aref}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("Bulk SQL: $bulk_sql");

  my $nrows_inserted = $dbh_write->do($bulk_sql);

  if ($dbh_write->err()) {

    $self->logger->debug("Db err code: " . $dbh_write->err());

    if ($dbh_write->err() == 1062) {

      my $err_str = $dbh_write->errstr();

      $err_str =~ /Duplicate entry '(.+)'/;
      my $err_msg = "Duplicate Entry: $1";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    else {

      $self->logger->debug('Error code: ' . $dbh_write->err());
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }
  }

  my $info_msg = "$nrows_inserted records of samplemeasurement have been inserted successfully.";
  my $info_msg_aref = [{'Message' => $info_msg}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}


#this function returns a list of invalid values based on their trialunit and trialunitspecimenid
sub validate_trait_db_bulk_v2 {

  my $dbh                = $_[0];
  my $trait_id2val_href  = $_[1];
  my $self  = $_[2];

  my @trait_id_list = keys(%{$trait_id2val_href});

  my $err          = 0;
  my $err_msg      = '';
  my $err_trait_id = -1;
  my $err_val_idx  = -1;

  #full error array with the following format for individual errors
  # {'Row' => row of error, 'Type' => type of error, 'Message' => 'message', 'ErrorInput' => what input caused error}
  my $full_list_invalid = [];

  #list of trait that have errors
  my $full_err_trait_href = {};

  if (scalar(@trait_id_list) == 0) {

    $err = 1;
    $err_msg = 'No trait';

    return ($err, $err_msg, $full_err_trait_href, $full_list_invalid);
  }

  my $sql = '';
  $sql   .= 'SELECT TraitId, TraitValRule, TraitValRuleErrMsg ';
  $sql   .= 'FROM trait ';
  $sql   .= 'WHERE TraitId IN (' . join(',', @trait_id_list) . ')';

  my ($r_trait_err, $r_trait_msg, $validation_data) = read_data($dbh, $sql, []);

  if ($r_trait_err) {

    $err = 1;
    $err_msg = 'Read trait validation rule failed: ' . $r_trait_msg;

    return ($err, $err_msg, $full_err_trait_href, $full_list_invalid);
  }

  if (scalar(@{$validation_data}) != scalar(@trait_id_list)) {

    $err = 1;
    $err_msg = 'Some validation rules are missing. ';

    #return ($err, $err_msg, $full_err_trait_href, $full_list_invalid);
  }

  my $trait_id2validation_href = {};

  foreach my $valid_rec (@{$validation_data}) {

    my $trait_id = $valid_rec->{'TraitId'};
    my $val_rule = $valid_rec->{'TraitValRule'};
    my $val_msg  = $valid_rec->{'TraitValRuleErrMsg'};

    $trait_id2validation_href->{$trait_id} = [$val_rule, $val_msg];
  }

  my $operator_lookup = { 'AND'     => '&&',
                          'OR'      => '||',
                          '[^<>!]=' => '==',
  };

  foreach my $trait_id (@trait_id_list) {
    if (defined $trait_id2validation_href->{$trait_id}) {
      my $validation_rule     = $trait_id2validation_href->{$trait_id}->[0];
      my $validation_err_msg  = $trait_id2validation_href->{$trait_id}->[1];

      my $value_aref      = $trait_id2val_href->{$trait_id};

      for (my $i = 0; $i < scalar(@{$value_aref}); $i++) {

        my $trait_value = $value_aref->[$i];

        if ($validation_rule =~ /(\w+)\((.*)\)/) {

          my $validation_rule_prefix = $1;
          my $validation_rule_body   = $2;

          if (uc($validation_rule_prefix) eq 'REGEX') {

            if (!($trait_value =~ /$validation_rule_body/)) {

              $err          = 1;
              $err_msg      = $validation_err_msg;
              $err_trait_id = $trait_id;
              $err_val_idx  = $i;
            }
          }
          elsif (uc($validation_rule_prefix) eq 'BOOLEX') {

            if ($validation_rule_body !~ /x/) {

              $err           = 1;
              $err_msg       = 'No variable x in boolean expression.';
              $err_trait_id  = $trait_id;
              $err_val_idx   = $i;
            }
            elsif ( ($validation_rule_body =~ /\&/) ||
                    ($validation_rule_body =~ /\|/) ) {

              $err           = 1;
              $err_msg       = 'Contain forbidden characters';
              $err_trait_id  = $trait_id;
              $err_val_idx   = $i;
            }
            elsif ( $validation_rule_body =~ /\d+\.?\d*\s*,/) {

              $err           = 1;
              $err_msg       = 'Contain a comma - invalid boolean expression';
              $err_trait_id  = $trait_id;
              $err_val_idx   = $i;
            }
            else {

              if ($trait_value =~ /^[-+]?\d+\.?\d*$/) {

                $validation_rule_body =~ s/x/ $trait_value /ig;
              }
              else {

                $validation_rule_body =~ s/x/ '$trait_value' /ig;
              }

              for my $operator (keys(%{$operator_lookup})) {

                my $perl_operator = $operator_lookup->{$operator};
                $validation_rule_body =~ s/$operator/$perl_operator/g;
              }

              my $test_condition;

              eval(q{$test_condition = } . qq{($validation_rule_body) ? 1 : 0;});

              if($@) {

                $err           = 1;
                $err_msg       = "Invalid boolean trait value validation expression ($validation_rule_body).";
                $err_trait_id  = $trait_id;
                $err_val_idx   = $i;
              }
              else {

                if ($test_condition == 0) {

                  $err          = 1;
                  $err_msg      = $validation_err_msg;
                  $err_trait_id = $trait_id;
                  $err_val_idx  = $i;
                }
                else {

                  $err          = 0;
                  $err_msg      = '';
                  $err_trait_id = -1;
                  $err_val_idx  = -1;
                }
              }
            }
          }
          elsif (uc($validation_rule_prefix) eq 'CHOICE') {

            if ($validation_rule_body =~ /^\[.*\]$/) {

              $err          = 1;
              $err_msg      = 'Invalid choice expression containing [].';
              $err_trait_id = $trait_id;
              $err_val_idx  = $i;
            }
            else {

              my @choice_list = split(/\|/, $validation_rule_body);

              $err          = 1;
              $err_msg      = $validation_err_msg;
              $err_trait_id = $trait_id;
              $err_val_idx  = $i;

              foreach my $choice (@choice_list) {

                if (lc("$choice") eq lc("$trait_value")) {

                  $err          = 0;
                  $err_msg      = '';
                  $err_trait_id = -1;
                  $err_val_idx  = -1;
                  last;
                }
              }
            }
          }
          elsif ( (uc($validation_rule_prefix) eq 'DATE_RANGE') ) {

            if ($trait_value !~ /^\d{4}\-\d{2}\-\d{2}( \d{2}\:\d{2}\:\d{2})?$/) {

              $err     = 1;
              $err_msg = 'Invalid date';
            }
          }
          elsif ( (uc($validation_rule_prefix) eq 'RANGE')   ||
                  (uc($validation_rule_prefix) eq 'LERANGE') ||
                  (uc($validation_rule_prefix) eq 'RERANGE') ||
                  (uc($validation_rule_prefix) eq 'BERANGE') ) {

            if ($validation_rule_body !~ /^[-+]?\d+\.?\d*\s*\.\.\s*[-+]?\d+\.?\d*$/) {

              $err          = 1;
              $err_msg      = 'Invalid range expression';
              $err_trait_id = $trait_id;
              $err_val_idx  = $i;
            }
            else {

              $err          = 1;
              $err_msg      = $validation_err_msg;
              $err_trait_id = $trait_id;
              $err_val_idx  = $i;

              if ($trait_value =~ /^[-+]?\d+\.?\d*$/) {

                my ($left_val, $right_val) = split(/\s*\.\.\s*/, $validation_rule_body);

                if (uc($validation_rule_prefix) eq 'RANGE') {

                  if ($trait_value >= $left_val && $trait_value <= $right_val) {

                    $err          = 0;
                    $err_msg      = '';
                    $err_trait_id = -1;
                    $err_val_idx  = -1;
                  }
                }
                elsif (uc($validation_rule_prefix) eq 'LERANGE') {

                  if ($trait_value > $left_val && $trait_value <= $right_val) {

                    $err          = 0;
                    $err_msg      = '';
                    $err_trait_id = -1;
                    $err_val_idx  = -1;
                  }
                }
                elsif (uc($validation_rule_prefix) eq 'RERANGE') {

                  if ($trait_value >= $left_val && $trait_value < $right_val) {

                    $err          = 0;
                    $err_msg      = '';
                    $err_trait_id = -1;
                    $err_val_idx  = -1;
                  }
                }
                elsif (uc($validation_rule_prefix) eq 'BERANGE') {

                  if ($trait_value > $left_val && $trait_value < $right_val) {

                    $err          = 0;
                    $err_msg      = '';
                    $err_trait_id = -1;
                    $err_val_idx  = -1;
                  }
                }
              }
              else {

                $err          = 1;
                $err_msg      = "Trait value ($trait_value) not a valid number";
                $err_trait_id = $trait_id;
                $err_val_idx  = $i;
              }
            }
          }
          else {

            $err          = 1;
            $err_msg      = 'Unknown trait value validation rule.';
            $err_trait_id = $trait_id;
            $err_val_idx  = $i;
          }
        }
        else {

          $err          = 1;
          $err_msg      = "Unknown validation rule.";
          $err_trait_id = $trait_id;
          $err_val_idx  = $i;
        }

        if ($err) {
          my $error_obj = {};

          $error_obj->{'Message'} = $err_msg;
          $error_obj->{'Index'} = $err_val_idx;
          #$error_obj->{'Type'} = "Validation";
          #$error_obj->{'Date'} = $measure_dt;
          $error_obj->{'Trait'} = $trait_id;
          $error_obj->{'Value'} = $trait_value;

          push(@{$full_list_invalid},$error_obj);
          $full_err_trait_href->{$err_trait_id} = 1;
          #return ($err, $err_msg, $err_trait_id, $err_val_idx);

        }
      }
    }
  }

  my $final_err = scalar(@{$full_list_invalid}) > 0;

  return ($final_err, $err_msg, $full_err_trait_href, $full_list_invalid);
}

sub import_itemmeasurement_csv_runmode {

=pod import_itemmeasurement_csv_HELP_START
{
"OperationName": "Import item measurements",
"Description": "Import item measurements from a csv file formatted as a sparse matrix of phenotypic data.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='2 records of itemmeasurement have been inserted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : '2 records of itemmeasurement have been inserted successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Row (1): Item (1) does not exist.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Row (1): Item (1) does not exist.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "CSV",
"UploadFileParameterName": "uploadfile",
"HTTPParameter": [{"Required": 1, "Name": "ItemId", "Description": "Column number counting from zero for ItemId column in the upload CSV file"}, {"Required": 1, "Name": "SampleTypeId", "Description": "Column number counting from zero for SampleTypeId column in the upload CSV file"}, {"Required": 1, "Name": "TraitId", "Description": "Column number counting from zero for TraitId column in the upload CSV file"}, {"Required": 1, "Name": "OperatorId", "Description": "Column number counting from zero for OperatorId column for the upload CSV file"}, {"Required": 1, "Name": "MeasureDateTime", "Description": "Column number counting from zero for MeasureDateTime column in the upload CSV file"}, {"Required": 1, "Name": "InstanceNumber", "Description": "Column number counting from zero for InstanceNumber column in the upload CSV file"}, {"Required": 1, "Name": "TraitValue", "Description": "Column number counting from zero for TraitValue column in the upload CSV file"},  {"Required": 0, "Name": "StateReason", "Description": "Column number counting from zero for StateReason column in the upload CSV file for sub-plot scoring"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $data_csv_file = $self->authen->get_upload_file();

  my $num_of_col = get_csvfile_num_of_col($data_csv_file);

  $self->logger->debug("Number of columns: $num_of_col");

  my $ItemId_col          = $query->param('ItemId');
  my $TraitId_col         = $query->param('TraitId');
  my $OperatorId_col      = $query->param('OperatorId');
  my $InstanceNumber_col  = $query->param('InstanceNumber');
  my $SampleTypeId_col    = $query->param('SampleTypeId');
  my $MeasureDateTime_col = $query->param('MeasureDateTime');
  my $TraitValue_col      = $query->param('TraitValue');

  my $chk_col_href = { 'ItemId'          => $ItemId_col,
                       'SampleTypeId'    => $SampleTypeId_col,
                       'TraitId'         => $TraitId_col,
                       'MeasureDateTime' => $MeasureDateTime_col,
                       'InstanceNumber'  => $InstanceNumber_col,
                       'TraitValue'      => $TraitValue_col,
                     };

  my $matched_col = {};

  $matched_col->{$ItemId_col}          = 'ItemId';
  $matched_col->{$SampleTypeId_col}    = 'SampleTypeId';
  $matched_col->{$TraitId_col}         = 'TraitId';
  $matched_col->{$MeasureDateTime_col} = 'MeasureDateTime';
  $matched_col->{$InstanceNumber_col}  = 'InstanceNumber';
  $matched_col->{$TraitValue_col}      = 'TraitValue';

  my $StateReason_col = undef;

  if (defined $query->param('StateReason')) {

    if (length($query->param('StateReason')) > 0) {

      $StateReason_col = $query->param('StateReason');
      $chk_col_href->{'StateReason'} = $StateReason_col;

      $matched_col->{$StateReason_col} = 'StateReason';
    }
  }

  my ($col_def_err, $col_def_err_href) = check_col_def_href( $chk_col_href, $num_of_col);

  if ($col_def_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$col_def_err_href]};

    return $data_for_postrun_href;
  }

  if (length($OperatorId_col) > 0) {

    my ($col_def_err, $col_def_err_href) = check_col_def_href( { 'OperatorId' => $OperatorId_col },
                                                               $num_of_col
        );

    if ($col_def_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [$col_def_err_href]};

      return $data_for_postrun_href;
    }

    $matched_col->{$OperatorId_col} = 'OperatorId';
  }

  my @fieldname_list;

  for (my $i = 0; $i < $num_of_col; $i++) {

    if ($matched_col->{$i}) {

      push(@fieldname_list, $matched_col->{$i});
    }
    else {

      push(@fieldname_list, 'null');
    }
  }

  my ($data_aref, $csv_err, $err_msg) = csvfile2arrayref($data_csv_file, \@fieldname_list, 0);

  if ($csv_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_write = connect_kdb_write();

  my $check_non_trait_field = 1;
  my $validate_trait_value  = 1;
  $data_for_postrun_href = $self->insert_itemmeasurement_data_v2($dbh_write,
                                                                $data_aref,
                                                                $check_non_trait_field,
                                                                $validate_trait_value
      );

  $dbh_write->disconnect();

  return $data_for_postrun_href;
}

sub export_itemmeasurement_csv_runmode {

=pod export_itemmeasurement_csv_HELP_START
{
"OperationName": "Export item measurements",
"Description": "Export item measurements (if exists) into a csv file formatted as a sparse matrix of phenotypic data",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><OutputFile csv='http://kddart-d.diversityarrays.com/data/admin/export_itemmeasurement_fc77a5593427a35b804a07150dccb942.csv' /></DATA>",
"SuccessMessageJSON": "{'OutputFile' : [{'csv' : 'http://kddart-d.diversityarrays.com/data/admin/export_itemmeasurement_fc77a5593427a35b804a07150dccb942.csv'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPParameter": [{"Required": 0, "Name": "ItemIdCSV", "Description": "Filtering parameter for ItemId. The value is comma separated value of ItemId."}, {"Required": 0, "Name": "SampleTypeIdCSV", "Description": "Filtering parameter for SampleTypeId. The value is comma separated value of SampleTypeId."}, {"Required": 0, "Name": "TraitIdCSV", "Description": "Filtering parameter for TraitId. The value is comma separated value of TraitId."}, {"Required": 0, "Name": "OperatorIdCSV", "Description": "Filtering parameter for OperatorId. The value is comma separated value of OperatorId."}, {"Required": 0, "Name": "MeasureDateTimeFrom", "Description": "Filtering parameter for MeasureDateTime. The value is correctly formatted date/time from which the item measurement was recorded."}, {"Required": 0, "Name": "MeasureDateTimeTo", "Description": "Filtering parameter for MeasureDateTime. The value is correctly formatted date/time to which the item measurement was recorded."}, {"Required": 0, "Name": "IMGroupIdCSV", "Description": "Filtering parameter for IMGroupId. The value is comma separated value of IMGroupId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $item_id_csv = '';

  if (defined $query->param('ItemIdCSV')) {

    $item_id_csv = $query->param('ItemIdCSV');
  }

  my $stype_id_csv = '';

  if (defined $query->param('SampleTypeIdCSV')) {

    $stype_id_csv = $query->param('SampleTypeIdCSV');
  }

  my $trait_id_csv = '';

  if (defined $query->param('TraitIdCSV')) {

    $trait_id_csv = $query->param('TraitIdCSV');
  }

  my $operator_id_csv = '';

  if (defined $query->param('OperatorIdCSV')) {

    $operator_id_csv = $query->param('OperatorIdCSV');
  }

  my $measure_dt_from = '';

  if (defined $query->param('MeasureDateTimeFrom')) {

    $measure_dt_from = $query->param('MeasureDateTimeFrom');
  }

  my $measure_dt_to = '';

  if (defined $query->param('MeasureDateTimeTo')) {

    $measure_dt_to = $query->param('MeasureDateTimeTo');
  }

  my $imgroup_id_csv = '';

  if (defined $query->param('IMGroupIdCSV')) {

    $imgroup_id_csv = $query->param('IMGroupIdCSV');
  }

  my $dbh = connect_kdb_read();

  $self->logger->debug("ItemIdCSV: $item_id_csv");

  my @where_phrases;

  if (length($imgroup_id_csv) > 0) {

    my ($smgrp_exist_err, $smgrp_rec_str) = record_exist_csv($dbh, 'imgroup', 'IMGroupId', $imgroup_id_csv);

    if ($smgrp_exist_err) {

      my $err_msg = "IMGroup ($smgrp_rec_str): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $where_smgrp = " IMGroupId IN ($smgrp_rec_str) ";
    push(@where_phrases, $where_smgrp);
  }

  if (length($item_id_csv) > 0) {

    my ($item_exist_err, $item_rec_str) = record_exist_csv($dbh, 'item', 'ItemId', $item_id_csv);

    if ($item_exist_err) {

      my $err_msg = "Item ($item_rec_str) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $where_item = " itemmeasurement.ItemId IN ($item_rec_str) ";
    push(@where_phrases, $where_item);
  }

  if (length($stype_id_csv) > 0) {

    my ($stype_exist_err, $stype_rec_str) = type_existence_csv($dbh, 'item', $stype_id_csv);

    if ($stype_exist_err) {

      my $err_msg = "SampleType ($stype_rec_str) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $where_stype = " SampleTypeId IN ($stype_rec_str) ";
    push(@where_phrases, $where_stype);
  }

  if (length($trait_id_csv) > 0) {

    my ($trait_exist_err, $trait_rec_str) = record_exist_csv($dbh, 'trait', 'TraitId', $trait_id_csv);

    if ($trait_exist_err) {

      my $err_msg = "Trait ($trait_rec_str) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $where_trait = " TraitId IN ($trait_rec_str) ";
    push(@where_phrases, $where_trait);
  }

  if (length($operator_id_csv) > 0) {

    my ($oper_exist_err, $oper_rec_str) = record_exist_csv($dbh, 'systemuser', 'UserId', $operator_id_csv);

    if ($oper_exist_err) {

      my $err_msg = "Operator ($oper_rec_str) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $where_operator = " OperatorId IN ($oper_rec_str) ";
    push(@where_phrases, $where_operator);
  }

  my $where_measure_time = '';

  if (length($measure_dt_from) > 0) {

    my ($mdt_from_err, $mdt_from_msg) = check_dt_value( { 'MeasureDateTimeFrom' => $measure_dt_from } );

    if ($mdt_from_err) {

      my $err_msg = "$mdt_from_msg not date/time.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    $where_measure_time = " MeasureDateTime >= '$measure_dt_from' ";
  }

  if (length($measure_dt_to) > 0) {


    my ($mdt_to_err, $mdt_to_msg) = check_dt_value( { 'MeasureDateTimeTo' => $measure_dt_to } );

    if ($mdt_to_err) {

      my $err_msg = "$mdt_to_msg not date/time.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if (length($where_measure_time) > 0) {

      $where_measure_time .= " AND MeasureDateTime <= '$measure_dt_to' ";
    }
    else {

      $where_measure_time = " MeasureDateTime <= '$measure_dt_to' ";
    }
  }

  push(@where_phrases, $where_measure_time);

  my @field_headers = ('ItemId', 'TraitId', 'OperatorId', 'MeasureDateTime',
                       'InstanceNumber', 'SampleTypeId', 'TraitValue',
                       'IMGroupId', 'StateReason');

  my @sql_field_list;

  foreach my $field_name (@field_headers) {

    push(@sql_field_list, "itemmeasurement.${field_name}");
  }

  my $sql = 'SELECT ' . join(',', @sql_field_list) . ' ';
  $sql   .= 'FROM itemmeasurement LEFT JOIN item ';
  $sql   .= 'ON itemmeasurement.ItemId = item.ItemId ';

  my $where_clause = '';
  for my $phrase (@where_phrases) {

    if (length($phrase) > 0) {

      if (length($where_clause) > 0) {

        $where_clause .= "AND $phrase";
      }
      else {

        $where_clause .= "$phrase";
      }
    }
  }

  if (length($where_clause) > 0) {

    $sql .= " WHERE $where_clause ";
  }

  my $export_data_sql_md5 = md5_hex($sql);

  $self->logger->debug("SQL: $sql");

  my $username          = $self->authen->username();
  my $doc_root          = $ENV{'DOCUMENT_ROOT'};
  my $export_data_path  = "${doc_root}/data/$username";
  my $current_runmode   = $self->get_current_runmode();
  my $lock_filename     = "${current_runmode}.lock";
  my $filename          = "export_itemmeasurement_$export_data_sql_md5";
  my $csv_file          = "${export_data_path}/${filename}.csv";

  if ( !(-e $export_data_path) ) {

    mkdir($export_data_path);
  }

  my $lockfile = File::Lockfile->new($lock_filename, $export_data_path);

  my $pid = $lockfile->check();

  if ($pid) {

    $self->logger->debug("$lock_filename exists in $export_data_path");
    my $msg = 'Lockfile exists: either another process of this export is running or ';
    $msg   .= 'there was an unexpected error regarding clearing this lockfile.';

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $msg}]};

    return $data_for_postrun_href;
  }

  $lockfile->write();

  my $sth = $dbh->prepare($sql);
  $sth->execute();

  if ($dbh->err()) {

    $lockfile->remove();
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("csv: $csv_file");

  open(my $smeasure_csv_fh, ">$csv_file") or die "Can't open $csv_file for writing: $!";

  print $smeasure_csv_fh '#' . join(',', @field_headers) . "\n";

  while ( my $row_aref = $sth->fetchrow_arrayref() ) {

    foreach my $col_entry (@{$row_aref}) {
        if (length($col_entry)) {
          $col_entry = qq|"$col_entry"|;
        }
        else {
          $col_entry = "";
        }
    }

    my $csv_line = join(',', @{$row_aref});

    print $smeasure_csv_fh "$csv_line\n";
  }

  close($smeasure_csv_fh);

  $lockfile->remove();

  $sth->finish();

  $self->logger->debug("Document root: $doc_root");

  $dbh->disconnect();

  my $url = reconstruct_server_url();

  my $info_aref = [{ 'csv' => "$url/data/$username/${filename}.csv" }];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'OutputFile' => $info_aref };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub import_imgroup_data_csv_runmode {

=pod import_imgroup_data_csv_HELP_START
{
"OperationName": "Import item measurements in a group",
"Description": "Import item measurements from a csv file formatted as a sparse matrix of phenotypic data in a group. It returns Item Measurement Group (IMGroupId) when the operation is successful.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "imgroup",
"SkippedField": ["OperatorId","IMGroupDateTime"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='3 records of itemmeasurement have been inserted successfully.' /><StatInfo Unit='second' ServerElapsedTime='0.092' /><ReturnId Value='5' ParaName='IMGroupId' /></DATA>",
"SuccessMessageJSON": "{'StatInfo' : [{'ServerElapsedTime' : '0.109','Unit' : 'second'}],'ReturnId' : [{'ParaName' : 'IMGroupId','Value' : '6'}],'Info' : [{'Message' : '3 records of itemmeasurement have been inserted successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Operator (16): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Operator (16): not found.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "CSV",
"UploadFileParameterName": "uploadfile",
"HTTPParameter": [{"Required": 1, "Name": "ItemIdCol", "Description": "Column number counting from zero for ItemId column in the upload CSV file"}, {"Required": 1, "Name": "SampleTypeIdCol", "Description": "Column number counting from zero for SampleTypeId column in the upload CSV file"}, {"Required": 1, "Name": "TraitIdCol", "Description": "Column number counting from zero for TraitId column in the upload CSV file"}, {"Required": 1, "Name": "OperatorIdCol", "Description": "Column number counting from zero for OperatorId column for the upload CSV file"}, {"Required": 1, "Name": "MeasureDateTimeCol", "Description": "Column number counting from zero for MeasureDateTime column in the upload CSV file"}, {"Required": 1, "Name": "InstanceNumberCol", "Description": "Column number counting from zero for InstanceNumber column in the upload CSV file"}, {"Required": 1, "Name": "TraitValueCol", "Description": "Column number counting from zero for TraitValue column in the upload CSV file"}, {"Required": 0, "Name": "StateReasonCol", "Description": "Column number counting from zero for StateReason column in the upload CSV file for sub-plot scoring"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self     = shift;
  my $query    = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'OperatorId'      => 1,
                    'IMGroupDateTime' => 1,
                   };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'imgroup', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  # Finish generic required static field checking

  my $imgroup_name = $query->param('IMGroupName');

  my $operator_id = $self->authen->user_id();

  my $dbh_write = connect_kdb_write();

  if (record_existence($dbh_write, 'imgroup', 'IMGroupName', $imgroup_name)) {

    my $err_msg = "IMGroupName ($imgroup_name): already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'IMGroupName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $imgroup_status = undef;

  if (defined $query->param('IMGroupStatus')) {

    if (length($query->param('IMGroupStatus')) > 0) {

      $imgroup_status = $query->param('IMGroupStatus');
    }
  }

  my $imgroup_note = undef;

  if (defined $query->param('IMGroupNote')) {

    if (length($query->param('IMGroupNote')) > 0) {

      $imgroup_note = $query->param('IMGroupNote');
    }
  }

  my $cur_dt = DateTime->now( time_zone => $TIMEZONE );
  $cur_dt = DateTime::Format::MySQL->format_datetime($cur_dt);

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $data_csv_file = $self->authen->get_upload_file();

  my $num_of_col = get_csvfile_num_of_col($data_csv_file);

  $self->logger->debug("Number of columns: $num_of_col");

  my $ItemId_col          = $query->param('ItemIdCol');
  my $SampleTypeId_col    = $query->param('SampleTypeIdCol');
  my $TraitId_col         = $query->param('TraitIdCol');
  my $MeasureDateTime_col = $query->param('MeasureDateTimeCol');
  my $InstanceNumber_col  = $query->param('InstanceNumberCol');
  my $TraitValue_col      = $query->param('TraitValueCol');

  my $chk_col_href = { 'ItemIdCol'          => $ItemId_col,
                       'SampleTypeIdCol'    => $SampleTypeId_col,
                       'TraitIdCol'         => $TraitId_col,
                       'MeasureDateTimeCol' => $MeasureDateTime_col,
                       'InstanceNumberCol'  => $InstanceNumber_col,
                       'TraitValueCol'      => $TraitValue_col,
                     };

  my $matched_col = {};

  $matched_col->{$ItemId_col}          = 'ItemId';
  $matched_col->{$SampleTypeId_col}    = 'SampleTypeId';
  $matched_col->{$TraitId_col}         = 'TraitId';
  $matched_col->{$MeasureDateTime_col} = 'MeasureDateTime';
  $matched_col->{$InstanceNumber_col}  = 'InstanceNumber';
  $matched_col->{$TraitValue_col}      = 'TraitValue';


  my $StateReason_col = undef;

  if (defined $query->param('StateReasonCol')) {

    if (length($query->param('StateReasonCol')) > 0) {

      $StateReason_col = $query->param('StateReasonCol');
      $chk_col_href->{'StateReasonCol'} = $StateReason_col;

      $matched_col->{$StateReason_col} = 'StateReason';
    }
  }

  my $OperatorId_col      = undef;

  if (defined $query->param('OperatorIdCol')) {

    if (length($query->param('OperatorIdCol')) > 0) {

      $OperatorId_col = $query->param('OperatorIdCol');
      $chk_col_href->{'OperatorIdCol'} = $OperatorId_col;

      $matched_col->{$OperatorId_col} = 'OperatorId';
    }
  }

  my ($col_def_err, $col_def_err_href) = check_col_def_href( $chk_col_href, $num_of_col);

  if ($col_def_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$col_def_err_href]};

    return $data_for_postrun_href;
  }

  my @fieldname_list;

  for (my $i = 0; $i < $num_of_col; $i++) {
    if ($matched_col->{$i}) {

      push(@fieldname_list, $matched_col->{$i});
    }
    else {

      push(@fieldname_list, 'null');
    }
  }

  my ($data_aref, $csv_err, $err_msg) = csvfile2arrayref($data_csv_file, \@fieldname_list, 0);

  if ($csv_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'INSERT INTO imgroup SET ';
  $sql   .= 'IMGroupName=?, ';
  $sql   .= 'OperatorId=?, ';
  $sql   .= 'IMGroupStatus=?, ';
  $sql   .= 'IMGroupDateTime=?, ';
  $sql   .= 'IMGroupNote=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($imgroup_name, $operator_id, $imgroup_status, $cur_dt, $imgroup_note);

  my $imgroup_id = -1;

  if ($dbh_write->err()) {

    $self->logger->debug("Add imgroup record failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $imgroup_id = $dbh_write->last_insert_id(undef, undef, 'imgroup', 'IMGroupId');
  $self->logger->debug("IMGroupID: $imgroup_id");

  $sth->finish();

  my $check_non_trait_field      = 1;
  my $validate_trait_value       = 1;

  $data_for_postrun_href = $self->insert_itemmeasurement_data_v2($dbh_write,
                                                                $data_aref,
                                                                $check_non_trait_field,
                                                                $validate_trait_value,
                                                                $imgroup_id,
                                                               );

  if ($data_for_postrun_href->{'Error'} == 1) {

    # Delete IMGroup record and return $data_for_postrun_href
    $sql = 'DELETE FROM imgroup WHERE IMGroupId=?';

    $sth = $dbh_write->prepare($sql);
    $sth->execute($imgroup_id);

    if ($dbh_write->err()) {

      $self->logger->debug("Delete imgroup record failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }
  }

  $dbh_write->disconnect();

  my $return_id_aref = [{'Value'   => "$imgroup_id", 'ParaName' => 'IMGroupId'}];

  $data_for_postrun_href->{'Data'}->{'ReturnId'} = $return_id_aref;

  return $data_for_postrun_href;
}

#version 2 of import item measurement functions that return all errors in the CSV
#version 2 of import item measurement functions that return all errors in the CSV
sub insert_itemmeasurement_data_v2 {

  my $self                = $_[0];
  my $dbh_write           = $_[1];
  my $data_aref           = $_[2];
  my $chk_non_trait_field = $_[3];
  my $validate_trait      = $_[4];

  my $imgroup_id = 0;

  if (defined $_[5]) {

    $imgroup_id = $_[5];
  }

  my $data_for_postrun_href = {};

  my $user_id       = $self->authen->user_id();
  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str      = permission_phrase($group_id, 0, $gadmin_status);

  #full error array with the following format for individual errors
  # {'Row' => row of error, 'Type' => type of error, 'Message' => 'message', 'ErrorInput' => what input caused error}
  my $full_error_aref = [];

  if (scalar(@{$data_aref}) == 0) {

    $self->logger->debug("No data provided");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'No data provided.'}]};

    return $data_for_postrun_href;
  }

  my $bulk_sql = 'INSERT INTO itemmeasurement ';
  $bulk_sql   .= '(ItemId,SampleTypeId,IMGroupId,TraitId,OperatorId,MeasureDateTime,InstanceNumber,TraitValue,StateReason) ';
  $bulk_sql   .= 'VALUES ';

  my $sql;
  my $sth;

  my $uniq_sam_type_href      = {};
  my $sam_type_val_aref       = [];
  my $sam_type_idx_aref       = [];

  my $uniq_trait_id_href      = {};
  my $trait_id_val_aref       = [];
  my $trait_id_idx_aref       = [];

  my $item_trait_id_val_aref    = [];
  my $item_trait_id_idx_aref    = [];

  my $uniq_operator_href      = {};
  my $operator_val_aref       = [];
  my $operator_idx_aref       = [];

  my $trait_id2val_href       = {};
  my $trait_id2idx_href       = {};

  my $date_error_flag = 0;
  my $date_error_aref = [];

  my $row_counter = 1;
  for my $data_row (@{$data_aref}) {
    $self->logger->debug("$row_counter:");
    for my $data_key (keys(%{$data_row})) {
      $self->logger->debug("$data_key -> " .$data_row->{$data_key});
    }  

    $self->logger->debug("----");

    my $effective_user_id = $user_id;
    my $item_id           = $data_row->{'ItemId'};
    my $samp_type_id      = $data_row->{'SampleTypeId'};
    my $trait_id          = $data_row->{'TraitId'};
    
    $uniq_trait_id_href->{$trait_id}     = 1;
    $uniq_sam_type_href->{$samp_type_id} = 1;

    #$self->logger->debug("Checking non trait data: $chk_non_trait_field");

    if ($chk_non_trait_field) {

      my ($int_id_err, $int_id_msg) = check_integer_value( { 'ItemId'         => $data_row->{'ItemId'},
                                                             'SampleTypeId'   => $data_row->{'SampleTypeId'},
                                                             'TraitId'        => $data_row->{'TraitId'},
                                                             'InstanceNumber' => $data_row->{'InstanceNumber'},
                                                           });

      if ($int_id_err) {

        $int_id_msg = "Row ($row_counter): " . $int_id_msg . ' not integer.';

        my $error_obj = {};

        $error_obj->{'Message'} = $int_id_msg;
        $error_obj->{'Row'} = $row_counter;
        $error_obj->{'Type'} = 'ItemInteger';
        $error_obj->{'ErrorInput'} = $int_id_msg;

        push(@{$full_error_aref}, $error_obj);
      }

      if (length($data_row->{'OperatorId'}) > 0) {

        my $operator_id = $data_row->{'OperatorId'};

        my ($int_err, $int_msg) = check_integer_value( { 'OperatorId' => $operator_id } );

        if ($int_err) {

          $int_msg = "Row ($row_counter): " . $int_msg . ' not an integer.';

          my $error_obj = {};

          $error_obj->{'Message'} = $int_msg;
          $error_obj->{'Row'} = $row_counter;
          $error_obj->{'Type'} = 'OperatorInteger';
          $error_obj->{'ErrorInput'} = $int_id_msg;

          push(@{$full_error_aref}, $error_obj);
        }

        $uniq_operator_href->{$operator_id} = 1;
        push(@{$operator_val_aref}, $operator_id);
        push(@{$operator_idx_aref}, $row_counter);

        $effective_user_id = $operator_id;
      }
    }


    push(@{$sam_type_val_aref},$samp_type_id);
    push(@{$sam_type_idx_aref},$row_counter);

    if (length($data_row->{'OperatorId'}) > 0) {

      $effective_user_id = $data_row->{'OperatorId'};
    }
    my $trait_val = $data_row->{'TraitValue'};
    my $db_trait_val = $dbh_write->quote($trait_val);

    if ($validate_trait) {

      if (defined $trait_id2val_href->{$trait_id}) {

        my $val_aref = $trait_id2val_href->{$trait_id};
        push(@{$val_aref}, $trait_val);
        $trait_id2val_href->{$trait_id} = $val_aref;
      }
      else {

        $trait_id2val_href->{$trait_id} = [$trait_val];
      }

      if (defined $trait_id2idx_href->{$trait_id}) {

        my $idx_aref = $trait_id2idx_href->{$trait_id};
        push(@{$idx_aref}, $row_counter);
        $trait_id2idx_href->{$trait_id} = $idx_aref;
      }
      else {

        $trait_id2idx_href->{$trait_id} = [$row_counter];
      }
    }

    my $measure_dt   = $data_row->{'MeasureDateTime'};

    # Check measure date/time

    my ($measure_dt_err, $measure_dt_msg) = check_dt_value( {'MeasureDateTime' => $measure_dt} );

    if ($measure_dt_err) {

      my $error_obj = {};

      $error_obj->{'Message'} = $measure_dt_msg;
      $error_obj->{'Row'} = $row_counter;
      $error_obj->{'Type'} = 'Date';
      $error_obj->{'ErrorInput'} = $measure_dt;

      push(@{$full_error_aref}, $error_obj);
    }

    # End check measure date/time

    my $instance_num = $data_row->{'InstanceNumber'};

    my $state_reason      = 'NULL';

    if (defined $data_row->{'StateReason'}) {

      if (length($data_row->{'StateReason'}) > 0) {

        $state_reason = $dbh_write->quote($data_row->{'StateReason'});
      }
    }

    $bulk_sql .= "($item_id,$samp_type_id,$imgroup_id,$trait_id,$effective_user_id,";
    $bulk_sql .= "'$measure_dt',$instance_num,$db_trait_val,$state_reason),";

    $row_counter += 1;
  }

  chop($bulk_sql);      # remove excessive comma
  #

  my @trait_id_list = keys(%{$uniq_trait_id_href});

  if (scalar(@trait_id_list) == 0) {

    $self->logger->debug("List of trait id is empty");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  # Release the memorny
  $uniq_trait_id_href = {};

  $sql  = "SELECT TraitId, $perm_str AS UltimatePerm ";
  $sql .= "FROM trait ";
  $sql .= "WHERE TraitId IN (" . join(',', @trait_id_list) . ')';

  my $trait_lookup = $dbh_write->selectall_hashref($sql, 'TraitId');

  if ($dbh_write->err()) {

    $self->logger->debug("Get trait info failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my @operator_list = keys(%{$uniq_operator_href});

  if (scalar(@operator_list) > 0) {

    $sql = "SELECT UserId FROM systemuser WHERE UserId IN (" . join(',', @operator_list) . ")";

    my $operator_lookup = $dbh_write->selectall_hashref($sql, 'UserId');

    if ($dbh_write->err()) {

      $self->logger->debug("Get operator info failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    for (my $i = 0; $i < scalar(@{$operator_val_aref}); $i++) {

      my $oper_id  = $operator_val_aref->[$i];
      my $row_num  = $operator_idx_aref->[$i];

      if (! defined $operator_lookup->{$oper_id}) {

        my $err_msg = "Row ($row_num): Operator ($oper_id) does not exist.";

        my $error_obj = {};

        $error_obj->{'Message'} = $err_msg;
        $error_obj->{'Row'} = $row_num;
        $error_obj->{'Type'} = "Operator";
        #$error_obj->{'Date'} = $measure_dt;
        $error_obj->{'ErrorInput'} = "Operator ($oper_id)";

        push(@{$full_error_aref}, $error_obj);
      }
    }
  }

  my @sample_type_list = keys(%{$uniq_sam_type_href});

  if (scalar(@sample_type_list) == 0) {

    $self->logger->debug("List of sample type id is empty");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sql  = "SELECT TypeId FROM generaltype WHERE Class='sample' AND ";
  $sql .= "TypeId IN (" . join(',', @sample_type_list) . ")";

  my $sample_type_lookup = $dbh_write->selectall_hashref($sql, 'TypeId');

  if ($dbh_write->err()) {

    $self->logger->debug("Get sample type info failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  for (my $i = 0; $i < scalar(@{$sam_type_val_aref}); $i++) {

    my $sam_type_id = $sam_type_val_aref->[$i];
    my $row_num     = $sam_type_idx_aref->[$i];

    if (! defined $sample_type_lookup->{$sam_type_id}) {

      my $err_msg = "Row ($row_num): SampleType ($sam_type_id) does not exist.";

      my $error_obj = {};

      $error_obj->{'Message'} = $err_msg;
      $error_obj->{'Row'} = $row_num;
      $error_obj->{'Type'} = "SampleType";
      #$error_obj->{'Date'} = $measure_dt;
      $error_obj->{'ErrorInput'} = "SampleType ($sam_type_id)";

      push(@{$full_error_aref}, $error_obj);
    }
  }

  my $trait_validation_error_aref = [];

  $self->logger->debug("Now trying to validate trait values");

  for my $trait_id2val (keys(%{$trait_id2val_href})) {
    $self->logger->debug("Trait: $trait_id2val");
  }

  my ($v_trait_val_err, $invalid_error_message,
      $v_trait_id_href, $trait_validation_error_aref) = validate_trait_db_bulk_v2($dbh_write, $trait_id2val_href,$self);

  $self->logger->debug("Validation Error: $v_trait_val_err");
  $self->logger->debug("Validation Error: $invalid_error_message");
  $self->logger->debug("Number of Validation Error: " . scalar(@{$trait_validation_error_aref}));

  if ($v_trait_val_err) {

    foreach my $invalid_obj (@{$trait_validation_error_aref}) {

      my $v_trait_id = $invalid_obj->{'Trait'};
      my $v_trait_idx = $invalid_obj->{'Index'};
      my $v_trait_val_msg = $invalid_obj->{'Message'};
      my $v_trait_val = $invalid_obj->{'Value'};

      $self->logger->debug("Validation error on TraitId: $v_trait_id - index: $v_trait_idx");
      my $row_num = $trait_id2idx_href->{$v_trait_id}->[$v_trait_idx];
      my $err_msg = "Row ($row_num): $v_trait_val_msg";

      my $error_obj = {};

      $error_obj->{'Message'} = $err_msg;
      $error_obj->{'Row'} = $row_num;
      $error_obj->{'Type'} = "Validation";
      #$error_obj->{'Date'} = $measure_dt;
      $error_obj->{'ErrorInput'} = "$v_trait_val (Trait $v_trait_id)";

      push(@{$full_error_aref}, $error_obj);
    }

  }

  foreach my $error_obj (@{$full_error_aref}) {
      $self->logger->debug($error_obj->{'Row'}. ": " . $error_obj->{'Message'});
  }

  if (scalar(@{$full_error_aref}) > 0) {
    my $err_msg = 'Issues with CSV identified while inserting item measurement data';

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg,'ErrorList' => $full_error_aref}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("Bulk SQL: $bulk_sql");

  my $nrows_inserted = $dbh_write->do($bulk_sql);

  if ($dbh_write->err()) {

    $self->logger->debug("Db err code: " . $dbh_write->err());

    if ($dbh_write->err() == 1062) {

      my $err_str = $dbh_write->errstr();

      $err_str =~ /Duplicate entry '(.+)'/;
      my $err_msg = "Duplicate Entry: $1";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    else {

      $self->logger->debug('Error code: ' . $dbh_write->err());
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }
  }

  my $info_msg = "$nrows_inserted records of itemmeasurement have been inserted successfully.";
  my $info_msg_aref = [{'Message' => $info_msg}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_itemmeasurement_advanced_runmode {

=pod list_itemmeasurement_advanced_HELP_START
{
"OperationName": "List item measurements",
"Description": "List item measurements. This listing requires pagination definition.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination Page='1' NumOfRecords='27823' NumOfPages='557' NumPerPage='50' /><StatInfo ServerElapsedTime='0.444' Unit='second' /><RecordMeta TagName='itemmeasurement' /><itemmeasurement OperatorId='0' TraitValue='40' InstanceNumber='6' ItemId='17572' MeasureDateTime='2011-01-15 14:28:37' SampleTypeId='328' TraitId='70' /></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfPages' : 16,'Page' : '1','NumPerPage' : '3','NumOfRecords' : '47'}],'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.006'}],'RecordMeta' : [{'TagName' : 'itemmeasurement'}],'itemmeasurement' : [{'SampleTypeId' : '161','InstanceNumber' : '5','TraitValue' : '11','ItemId' : '23','IMGroupId' : '15','StateReason' : 'TEST','TraitId' : '23','OperatorId' : '0','MeasureDateTime' : '2011-01-15 14:28:37'},{'ItemId' : '23','TraitValue' : '40','InstanceNumber' : '6','SampleTypeId' : '161','OperatorId' : '0','MeasureDateTime' : '2011-01-15 14:28:37','StateReason' : 'TEST','TraitId' : '23','IMGroupId' : '15'},{'StateReason' : 'TEST','TraitId' : '23','MeasureDateTime' : '2011-01-15 14:28:37','OperatorId' : '0','IMGroupId' : '15','TraitValue' : '16','InstanceNumber' : '6','ItemId' : '23','SampleTypeId' : '161'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"URLParameter": [{"ParameterName": "nperpage", "Description": "Number of records in a page for pagination"}, {"ParameterName": "num", "Description": "The page number of the pagination"}],
"HTTPParameter": [{"Required": 0, "Name": "Filtering", "Description": "Filtering parameter string consisting of filtering expressions which are separated by ampersand (&) which needs to be encoded if HTTP GET method is used. Each filtering expression is composed of a database field name, a filtering operator and the filtering value."}, {"Required": 0, "Name": "FieldList", "Description": "Comma separated value of wanted fields."}, {"Required": 0, "Name": "Sorting", "Description": "Comma separated value of SQL sorting phrases."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;

  my $query = $self->query();

  my $data_for_postrun_href   = {};

  my $pagination  = 0;
  my $nb_per_page = -1;
  my $page        = -1;

  if ( (defined $self->param('nperpage')) && (defined $self->param('num'))) {

    $pagination  = 1;
    $nb_per_page = $self->param('nperpage');
    $page        = $self->param('num');
  }

  my $group_id = $self->authen->group_id();

  my $gadmin_status = $self->authen->gadmin_status();

  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'trait');

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

    $sorting  = $query->param('Sorting');
  }

  if (defined $self->param('sampletypeid')) {

    my $sampletype_id  = $self->param('sampletype_id');

    if ($filtering_csv = ~ /SampleTypeId=(.*),?/) {

      if ("$sampletype_id" ne "$1" ) {

        my $err_msg  = 'Duplicate filtering condition for SampleTypeId. ';
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
    else {

      if (length($filtering_csv) > 0) {

        if ($filtering_csv =~ /&$/) {

          $filtering_csv   .=  "SampleTypeId=$sampletype_id";
        }
        else {

          $filtering_csv    .=  "&SampleTypeId=$sampletype_id";
        }
      }
      else {

        $filtering_csv       .=  "SampleTypeId=$sampletype_id";
      }
    }
  }

  my $field_list = $field_list_csv;

  my $sql = 'SELECT itemmeasurement.* FROM itemmeasurement ';
  $sql   .= 'ORDER BY itemmeasurement.ItemId DESC ';
  $sql   .= 'LIMIT 1 ';

  my ($read_im_err, $read_im_msg, $im_data) = $self->list_itemmeasurement($sql, 0, $field_list);

  if ($read_im_err) {

    $self->logger->debug($read_im_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $dbh =  connect_kdb_read();

  my $item_data_aref = $im_data;

  my @field_list_all;

  if (scalar(@{$item_data_aref}) == 1) {

    @field_list_all = keys(%{$item_data_aref->[0]});
  }
  else {

    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'itemmeasurement');

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
                                                                                \@field_list_all,
                                                                                'SampleTypeId');

    if ($sel_field_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;

    if ($filtering_csv =~ /SampleTypeId/) {

      push(@{$final_field_list}, 'SampleTypeId');
    }
  }

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering_v2('SampleTypeId',
                                                                                 'itemmeasurement',
                                                                                 $filtering_csv,
                                                                                 $final_field_list);


  $self->logger->debug("Filter phrase: $filter_phrase");

  if ($filter_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $filter_msg}]};

    return $data_for_postrun_href;
  }

  my $filter_where_phrase = '';
  if (length($filter_phrase) > 0) {

    $filter_where_phrase = " AND $filter_phrase ";
  }

  my $filtering_exp  = " WHERE (($perm_str) & $READ_PERM) = $READ_PERM $filter_where_phrase ";

  my $pagination_aref = [];
  my $paged_limit_clause = '';

  if ($pagination) {

    my ($int_err, $int_err_msg)  = check_integer_value ({'nperpage' => $nb_per_page,
                                                         'num'      => $page
                                                        });

    if ($int_err) {

      $int_err_msg .= ' not integer';
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error'  =>  [{'Message' => $int_err_msg}]};
      return $data_for_postrun_href;
    }

    my $count_sql =  "SELECT COUNT(*) ";
    $count_sql   .=  "FROM itemmeasurement ";
    $count_sql   .=  "LEFT JOIN trait ON itemmeasurement.TraitId = trait.TraitId ";
    $count_sql   .=  "$filtering_exp";

    $self->logger->debug("COUNT SQL: $count_sql");

    my ($paged_id_err, $paged_id_msg, $nb_records,
        $nb_pages, $limit_clause, $sql_count_time) = get_paged_filter_sql($dbh,
                                                                          $nb_per_page,
                                                                          $page,
                                                                          $count_sql,
                                                                          $where_arg);


    $self->logger->debug("SQL Count time: $sql_count_time");

    if ($paged_id_err == 1) {

      $self->logger->debug($paged_id_msg);

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    if ($paged_id_err == 2) {

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

  my $sql_field_lookup = {
     'OperatorId'  => 1
  };

  my $other_join = '';
  my $extra_fields = '';

  if ($sql_field_lookup->{'SampleTypeId'}) {

    $other_join .=  ' LEFT JOIN generaltype ON itemmeasurement.SampleTypeId = generaltype.TypeId ';
    $extra_fields .= ', generaltype.TypeName ';
  }

  if ($sql_field_lookup->{'OperatorId'}) {

    $extra_fields .= ", concat(contact.ContactFirstName,' ',contact.ContactLastName) As Contact, contact.ContactId";

    $other_join .=  ' LEFT JOIN systemuser ON itemmeasurement.OperatorId = systemuser.UserId  LEFT JOIN contact on systemuser.ContactId = contact.ContactId ';
  }


  $sql    =  "SELECT itemmeasurement.*, trait.TraitName $extra_fields FROM itemmeasurement ";
  $sql   .=  "LEFT JOIN trait ON trait.TraitId = itemmeasurement.TraitId ";
  $sql   .=  "$other_join ";
  $sql   .=  "$filtering_exp ";

  my ($sort_err, $sort_msg, $sort_sql) = parse_sorting($sorting, $final_field_list);

  if ($sort_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sort_msg}]};

    return $data_for_postrun_href;
  }

  if (length($sort_sql) > 0) {

    $sql    .= " ORDER BY $sort_sql";
  }
  else {

    $sql    .= 'ORDER BY itemmeasurement.ItemId DESC';
  }

  $sql   .=  " $paged_limit_clause ";

  my ($read_item_err, $read_item_msg, $item_data)   =  $self->list_itemmeasurement($sql, $where_arg, $field_list);

  if ($read_item_err) {

    $self->logger->debug($read_item_msg);
    $data_for_postrun_href->{'Error'}  =  1;
    $data_for_postrun_href->{'Data'}   =  {'Error' =>  [{'Message' => 'Unexpected error. '}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}   = 0;
  $data_for_postrun_href->{'Data'}    = {'itemmeasurement'         =>   $item_data,
                                         'Pagination'              =>   $pagination_aref,
                                         'RecordMeta'              =>   [{'TagName' => 'itemmeasurement'}],
                                        };

  return $data_for_postrun_href;
}

sub list_itemmeasurement {

  my $self            = $_[0];
  my $sql             = $_[1];
  my $where_para_aref = $_[2];
  my $field_list      = $_[3];

  my $err = 0;
  my $msg = '';

  my $data_aref = [];

  my $sql_update       = $sql;

  my $sql_select_field = ['itemmeasurement.ItemId',
                          'itemmeasurement.TraitId',
                          'itemmeasurement.OperatorId',
                          'itemmeasurement.MeasureDateTime',
                          'itemmeasurement.InstanceNumber',
                          'itemmeasurement.SampleTypeId',
                          'itemmeasurement.TraitValue' ];

  $sql_select_field       =  join(',', @{$sql_select_field});
  $self->logger->debug("SQL 1: $sql");

  $sql_update  =~ s/SELECT itemmeasurement.\*/ $sql_select_field /;
  
  $sql = 'SELECT' . $sql_update;
  $self->logger->debug("SQL 2: $sql");

  my $dbh = connect_kdb_read();

  ($err, $msg, $data_aref) = read_data($dbh, $sql, $where_para_aref);

  if ($err) {

    return ($err, $msg, []);
  }

  $dbh->disconnect();

  return ($err, $msg, $data_aref);
}

sub list_imgroup_runmode {

=pod list_imgroup_HELP_START
{
"OperationName": "List itemmeasurement groups",
"Description": "List available itemmeasurement group.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='IMGroup' /><IMGroup  OperatorId='0' NumOfMeasurement='3' IMGroupDateTime='2017-04-19 15:22:10' IMGroupId='6' OperatorUserName='admin' IMGroupName='IMGroup_Test_31217813748' IMGroupStatus='TEST' IMGroupNote='Testing' update='update/imgroup/6' delete='delete/imgroup/6' /><StatInfo ServerElapsedTime='0.006' Unit='second' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'IMGroup'}],'StatInfo' : [{'ServerElapsedTime' : '0.007','Unit' : 'second'}],'IMGroup' : [{'IMGroupId' : '6','IMGroupDateTime' : '2017-04-19 15:22:10','OperatorId' : '0','NumOfMeasurement' : '3',delete' : 'delete/imgroup/6','IMGroupName' : 'IMGroup_Test_31217813748','update' : 'update/imgroup/6','IMGroupNote' : 'Testing','IMGroupStatus' : 'TEST','OperatorUserName' : 'admin'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self     = shift;
  my $query    = $self->query();

  my $filtering_csv = '';

  if (defined $query->param('Filtering')) {

    $filtering_csv = $query->param('Filtering');
  }

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  $dbh->disconnect();

  my $sql = 'SELECT imgroup.*, systemuser.UserName AS OperatorUserName ';
  $sql   .= 'FROM imgroup LEFT JOIN systemuser ON imgroup.OperatorId = systemuser.UserId ';

  my $filter_field_list = ['IMGroupName', 'OperatorId', 'IMGroupStatus', 'IMGroupDateTime', 'IMGroupNote'];

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering('IMGroupId',
                                                                              'imgroup',
                                                                              $filtering_csv,
                                                                              $filter_field_list);

  if ($filter_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $filter_msg}]};

    return $data_for_postrun_href;
  }

  if (length($filter_phrase) > 0) {

    $sql .= " AND $filter_phrase";
  }


  my ($read_imgrp_err, $read_imgrp_msg, $imgrp_data) = $self->list_imgroup(1, 0, $sql, $where_arg);

  if ($read_imgrp_err) {

    $self->logger->debug($read_imgrp_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'IMGroup'    => $imgrp_data,
                                           'RecordMeta' => [{'TagName' => 'IMGroup'}],
  };

  return $data_for_postrun_href;
}

sub list_imgroup {

  my $self            = $_[0];
  my $extra_attr_yes  = $_[1];
  my $detail_attr_yes = $_[2];
  my $sql             = $_[3];
  my $where_para_aref = $_[4];

  my $err       = 0;
  my $msg       = '';
  my $data_aref = [];

  my $dbh = connect_kdb_read();

  ($err, $msg, $data_aref) = read_data($dbh, $sql, $where_para_aref);

  if ($err) {

    return ($err, $msg, []);
  }

  my $imgroup_id_aref    = [];

  my $imcount_lookup     = {};
  my $trait_lookup       = {};
  my $item_lookup  = {};

  my $uniq_imgrp_trait_href   = {};
  my $uniq_imgrp_item_href      = {};

  if ($extra_attr_yes || $detail_attr_yes) {

    for my $imgroup_rec (@{$data_aref}) {

      push(@{$imgroup_id_aref}, $imgroup_rec->{'IMGroupId'});
    }

    if (scalar(@{$imgroup_id_aref}) > 0) {

      my $count_sql = 'SELECT IMGroupId, COUNT(ItemId) AS NumOfMeasurement ';
      $count_sql   .= 'FROM itemmeasurement ';
      $count_sql   .= 'WHERE IMGroupId IN (' . join(',', @{$imgroup_id_aref}) . ') ';
      $count_sql   .= 'GROUP BY IMGroupId;';

      $self->logger->debug("COUNT MEASUREMENT SQL: $count_sql");

      $imcount_lookup = $dbh->selectall_hashref($count_sql, 'IMGroupId');

      if ($dbh->err()) {

        $self->logger->debug("Count number of itemmeasurement failed");
        $err = 1;
        $msg = 'Unexpected Error';

        return ($err, $msg, []);
      }

    }
  }

  my $extra_attr_imgroup_data = [];

  my $user_id = $self->authen->user_id();

  my $gadmin_status = $self->authen->gadmin_status();

  if ($extra_attr_yes) {

    for my $imgroup_rec (@{$data_aref}) {

      my $imgrp_id     = $imgroup_rec->{'IMGroupId'};
      my $operator_id  = $imgroup_rec->{'OperatorId'};

      if ("$operator_id" eq "$user_id") {

        $imgroup_rec->{'update'} = "update/imgroup/${imgrp_id}";
        $imgroup_rec->{'delete'} = "delete/imgroup/${imgrp_id}";
      }

      if (defined $imcount_lookup->{$imgrp_id}) {

        $imgroup_rec->{'NumOfMeasurement'} = $imcount_lookup->{$imgrp_id}->{'NumOfMeasurement'};
      }

      if ($detail_attr_yes) {

        if (defined $trait_lookup->{$imgrp_id}) {

          $imgroup_rec->{'Trait'} = $trait_lookup->{$imgrp_id};
        }

        if (defined $item_lookup->{$imgrp_id}) {

          $imgroup_rec->{'Item'} = $item_lookup->{$imgrp_id};
        }

      }

      push(@{$extra_attr_imgroup_data}, $imgroup_rec);
    }
  }
  else {

    $extra_attr_imgroup_data = $data_aref;
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_imgroup_data);
}

sub update_imgroup_runmode {

=pod update_imgroup_HELP_START
{
"OperationName": "Update itemmeasurement group",
"Description": "Update detail information about a itemmeasurement group.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "imgroup",
"SkippedField": ["OperatorId","IMGroupDateTime"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><StatInfo Unit='second' ServerElapsedTime='0.047' /><Info Message='IMGroup (9) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'IMGroup (10) has been updated successfully.'}],'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.075'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='IMGroup (7): not found.' /><StatInfo ServerElapsedTime='0.013' Unit='second' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'IMGroup (7): not found.'}],'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.013'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing IMGroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $imgroup_id = $self->param('id');
  my $query      = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'OperatorId'      => 1,
                    'IMGroupDateTime' => 1,
                   };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'imgroup', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  # Finish generic required static field checking

  my $dbh = connect_kdb_read();

  my $chk_sql = 'SELECT OperatorId, IMGroupName, IMGroupStatus, IMGroupNote ';
  $chk_sql   .= 'FROM imgroup WHERE IMGroupId=?';

  my ($r_imgrp_err, $r_imgrp_msg, $imgrp_data) = read_data($dbh, $chk_sql, [$imgroup_id]);

  if ($r_imgrp_err) {

    $self->logger->debug("Get info about existing imgroup failed: $r_imgrp_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$imgrp_data}) == 0) {

    my $err_msg = "IMGroup ($imgroup_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $operator_id    = $imgrp_data->[0]->{'OperatorId'};
  my $db_imgrp_name  = $imgrp_data->[0]->{'IMGroupName'};

  my $imgroup_status = undef;

  if (defined $imgrp_data->[0]->{'IMGroupStatus'}) {

    if (length($imgrp_data->[0]->{'IMGroupStatus'}) > 0) {

      $imgroup_status = $imgrp_data->[0]->{'IMGroupStatus'};
    }
  }

  $imgroup_status = $query->param('IMGroupStatus');

  if (length($imgroup_status) == 0) {

    $imgroup_status = undef;
  }

  my $imgroup_note = undef;

  if (defined $imgrp_data->[0]->{'IMGroupNote'}) {

    if (length($imgrp_data->[0]->{'IMGroupNote'}) > 0) {

      $imgroup_note = $imgrp_data->[0]->{'IMGroupNote'};
    }
  }

  $imgroup_note = $query->param('IMGroupNote');

  if (length($imgroup_note) == 0) {

    $imgroup_note = undef;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  $dbh->disconnect();

  my $user_id = $self->authen->user_id();

  if ("$user_id" ne "0") {

    if ("$user_id" ne "$operator_id") {

      my $err_msg = "Permission denied: User ($user_id).";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $dbh_write = connect_kdb_write();

  my $cur_dt = DateTime->now( time_zone => $TIMEZONE );
  $cur_dt = DateTime::Format::MySQL->format_datetime($cur_dt);

  my $imgroup_name = $query->param('IMGroupName');

  if ($imgroup_name ne $db_imgrp_name) {

    if (record_existence($dbh_write, 'imgroup', 'IMGroupName', $imgroup_name)) {

      my $err_msg = "IMGroup ($imgroup_name): already exists.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'IMGroupName' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $sql = 'UPDATE imgroup SET ';
  $sql   .= 'IMGroupName=?, ';
  $sql   .= 'IMGroupStatus=?, ';
  $sql   .= 'IMGroupDateTime=?, ';
  $sql   .= 'IMGroupNote=? ';
  $sql   .= 'WHERE IMGroupId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($imgroup_name, $imgroup_status, $cur_dt, $imgroup_note, $imgroup_id);

  if ($dbh_write->err()) {

    $self->logger->debug("Update IMGroup failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "IMGroup ($imgroup_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub get_imgroup_runmode {

=pod get_imgroup_HELP_START
{
"OperationName": "Get itemmeasurement group",
"Description": "Get detail information about a itemmeasurement group.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><IMGroup update='update/imgroup/6' NumOfMeasurement='3' IMGroupDateTime='2017-04-19 15:22:10' OperatorUserName='admin' IMGroupStatus='TEST' IMGroupNote='Testing' IMGroupId='6' delete='delete/imgroup/6' IMGroupName='IMGroup_Test_31217813748' OperatorId='0'><Trait TraitId='14' TraitName='Trait_75223850117' /><Item ItemId='14' /></IMGroup><StatInfo Unit='second' ServerElapsedTime='0.015' /><RecordMeta TagName='IMGroup' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'IMGroup'}],'IMGroup' : [{'NumOfMeasurement' : '3','update' : 'update/imgroup/6','Trait' : [{'TraitName' : 'Trait_75223850117','TraitId' : '14'}],'Item' : [{'ItemId' : '14'}],'IMGroupDateTime' : '2017-04-19 15:22:10','OperatorUserName' : 'admin','IMGroupStatus' : 'TEST','IMGroupNote' : 'Testing','IMGroupId' : '6','IMGroupName' : 'IMGroup_Test_31217813748','delete' : 'delete/imgroup/6','OperatorId' : '0'}],'StatInfo' : [{'ServerElapsedTime' : '0.018','Unit' : 'second'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='IMGroup (7): not found.' /><StatInfo ServerElapsedTime='0.013' Unit='second' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'IMGroup (7): not found.'}],'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.013'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing IMGroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $imgroup_id = $self->param('id');
  my $query      = $self->query();

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  $dbh->disconnect();

  my $sql = 'SELECT imgroup.*, systemuser.UserName AS OperatorUserName ';
  $sql   .= 'FROM imgroup LEFT JOIN systemuser ON imgroup.OperatorId = systemuser.UserId ';
  $sql   .= 'WHERE IMGroupId = ?';

  my ($read_imgrp_err, $read_imgrp_msg, $imgrp_data) = $self->list_imgroup(1, 1, $sql, [$imgroup_id]);

  if ($read_imgrp_err) {

    $self->logger->debug($read_imgrp_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'IMGroup'    => $imgrp_data,
                                           'RecordMeta' => [{'TagName' => 'IMGroup'}],
  };

  return $data_for_postrun_href;
}

sub delete_imgroup_runmode {

=pod delete_imgroup_HELP_START
{
"OperationName": "Delete itemmeasurement group",
"Description": "Delete a itemmeasurement group and its associated itemmeasurement records.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><StatInfo ServerElapsedTime='0.075' Unit='second' /><Info Message='IMGroup (12) and its itemmeasurement records have been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'StatInfo' : [{'ServerElapsedTime' : '0.074','Unit' : 'second'}],'Info' : [{'Message' : 'IMGroup (11) and its itemmeasurement records have been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='IMGroup (7): not found.' /><StatInfo ServerElapsedTime='0.013' Unit='second' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'IMGroup (7): not found.'}],'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.013'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing IMGroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $imgroup_id = $self->param('id');
  my $query      = $self->query();

  my $data_for_postrun_href = {};

  my $dbh_write = connect_kdb_write();

  my $chk_sql = 'SELECT OperatorId, IMGroupName, IMGroupStatus, IMGroupNote ';
  $chk_sql   .= 'FROM imgroup WHERE IMGroupId=?';

  my ($r_imgrp_err, $r_imgrp_msg, $imgrp_data) = read_data($dbh_write, $chk_sql, [$imgroup_id]);

  if ($r_imgrp_err) {

    $self->logger->debug("Get info about existing imgroup failed: $r_imgrp_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$imgrp_data}) == 0) {

    my $err_msg = "IMGroup ($imgroup_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $operator_id    = $imgrp_data->[0]->{'OperatorId'};

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $user_id = $self->authen->user_id();

  if ("$user_id" ne "0") {

    if ("$user_id" ne "$operator_id") {

      my $err_msg = "Permission denied: User ($user_id).";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $sql = 'DELETE FROM itemmeasurement WHERE IMGroupId=?';

  my $sth = $dbh_write->prepare($sql);

  $sth->execute($imgroup_id);

  if ($dbh_write->err()) {

    $self->logger->debug("Delete itemmeasurement failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $sql = 'DELETE FROM imgroup where IMGroupId=?';

  $sth = $dbh_write->prepare($sql);

  $sth->execute($imgroup_id);

  if ($dbh_write->err()) {

    $self->logger->debug("Delete itemroup failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "IMGroup ($imgroup_id) and its itemmeasurement records have been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_crossingmeasurement_advanced_runmode {

=pod list_crossingmeasurement_advanced_HELP_START
{
"OperationName": "List crossing measurements",
"Description": "List crossing measurements. This listing requires pagination definition.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination Page='1' NumOfRecords='27823' NumOfPages='557' NumPerPage='50' /><StatInfo ServerElapsedTime='0.444' Unit='second' /><RecordMeta TagName='crossingmeasurement' /><crossingmeasurement OperatorId='0' TraitValue='40' InstanceNumber='6' CrossingId='17572' MeasureDateTime='2011-01-15 14:28:37' SampleTypeId='328' TraitId='70' /></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfPages' : 16,'Page' : '1','NumPerPage' : '3','NumOfRecords' : '47'}],'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.006'}],'RecordMeta' : [{'TagName' : 'crossingmeasurement'}],'crossingmeasurement' : [{'SampleTypeId' : '161','InstanceNumber' : '5','TraitValue' : '11','CrossingId' : '23','CMGroupId' : '15','StateReason' : 'TEST','TraitId' : '23','OperatorId' : '0','MeasureDateTime' : '2011-01-15 14:28:37'},{'CrossingId' : '23','TraitValue' : '40','InstanceNumber' : '6','SampleTypeId' : '161','OperatorId' : '0','MeasureDateTime' : '2011-01-15 14:28:37','StateReason' : 'TEST','TraitId' : '23','CMGroupId' : '15'},{'StateReason' : 'TEST','TraitId' : '23','MeasureDateTime' : '2011-01-15 14:28:37','OperatorId' : '0','CMGroupId' : '15','TraitValue' : '16','InstanceNumber' : '6','CrossingId' : '23','SampleTypeId' : '161'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"URLParameter": [{"ParameterName": "nperpage", "Description": "Number of records in a page for pagination"}, {"ParameterName": "num", "Description": "The page number of the pagination"}],
"HTTPParameter": [{"Required": 0, "Name": "Filtering", "Description": "Filtering parameter string consisting of filtering expressions which are separated by ampersand (&) which needs to be encoded if HTTP GET method is used. Each filtering expression is composed of a database field name, a filtering operator and the filtering value."}, {"Required": 0, "Name": "FieldList", "Description": "Comma separated value of wanted fields."}, {"Required": 0, "Name": "Sorting", "Description": "Comma separated value of SQL sorting phrases."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;

  my $query = $self->query();

  my $data_for_postrun_href   = {};

  my $pagination  = 0;
  my $nb_per_page = -1;
  my $page        = -1;

  if ( (defined $self->param('nperpage')) && (defined $self->param('num'))) {

    $pagination  = 1;
    $nb_per_page = $self->param('nperpage');
    $page        = $self->param('num');
  }

  my $group_id = $self->authen->group_id();

  my $gadmin_status = $self->authen->gadmin_status();

  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'trait');

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

    $sorting  = $query->param('Sorting');
  }

  if (defined $self->param('sampletypeid')) {

    my $sampletype_id  = $self->param('sampletype_id');

    if ($filtering_csv = ~ /SampleTypeId=(.*),?/) {

      if ("$sampletype_id" ne "$1" ) {

        my $err_msg  = 'Duplicate filtering condition for SampleTypeId. ';
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
    else {

      if (length($filtering_csv) > 0) {

        if ($filtering_csv =~ /&$/) {

          $filtering_csv   .=  "SampleTypeId=$sampletype_id";
        }
        else {

          $filtering_csv    .=  "&SampleTypeId=$sampletype_id";
        }
      }
      else {

        $filtering_csv       .=  "SampleTypeId=$sampletype_id";
      }
    }
  }

  my $field_list = $field_list_csv;

  my $sql = 'SELECT crossingmeasurement.* FROM crossingmeasurement ';
  $sql   .= 'ORDER BY crossingmeasurement.CrossingId DESC ';
  $sql   .= 'LIMIT 1 ';

  my ($read_im_err, $read_im_msg, $im_data) = $self->list_crossingmeasurement($sql, 0, $field_list);

  if ($read_im_err) {

    $self->logger->debug($read_im_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $dbh =  connect_kdb_read();

  my $crossing_data_aref = $im_data;

  my @field_list_all;

  if (scalar(@{$crossing_data_aref}) == 1) {

    @field_list_all = keys(%{$crossing_data_aref->[0]});
  }
  else {

    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'crossingmeasurement');

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
                                                                                \@field_list_all,
                                                                                'SampleTypeId');

    if ($sel_field_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;

    if ($filtering_csv =~ /SampleTypeId/) {

      push(@{$final_field_list}, 'SampleTypeId');
    }
  }

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering_v2('SampleTypeId',
                                                                                 'crossingmeasurement',
                                                                                 $filtering_csv,
                                                                                 $final_field_list);


  $self->logger->debug("Filter phrase: $filter_phrase");

  if ($filter_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $filter_msg}]};

    return $data_for_postrun_href;
  }

  my $filter_where_phrase = '';
  if (length($filter_phrase) > 0) {

    $filter_where_phrase = " AND $filter_phrase ";
  }

  my $filtering_exp  = " WHERE (($perm_str) & $READ_PERM) = $READ_PERM $filter_where_phrase ";

  my $pagination_aref = [];
  my $paged_limit_clause = '';

  if ($pagination) {

    my ($int_err, $int_err_msg)  = check_integer_value ({'nperpage' => $nb_per_page,
                                                         'num'      => $page
                                                        });

    if ($int_err) {

      $int_err_msg .= ' not integer';
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error'  =>  [{'Message' => $int_err_msg}]};
      return $data_for_postrun_href;
    }

    my $count_sql =  "SELECT COUNT(*) ";
    $count_sql   .=  "FROM crossingmeasurement ";
    $count_sql   .=  "LEFT JOIN trait ON crossingmeasurement.TraitId = trait.TraitId ";
    $count_sql   .=  "$filtering_exp";

    $self->logger->debug("COUNT SQL: $count_sql");

    my ($paged_id_err, $paged_id_msg, $nb_records,
        $nb_pages, $limit_clause, $sql_count_time) = get_paged_filter_sql($dbh,
                                                                          $nb_per_page,
                                                                          $page,
                                                                          $count_sql,
                                                                          $where_arg);


    $self->logger->debug("SQL Count time: $sql_count_time");

    if ($paged_id_err == 1) {

      $self->logger->debug($paged_id_msg);

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    if ($paged_id_err == 2) {

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

  my $sql_field_lookup = {
    'SampleTypeId' => 1,
    'OperatorId'  => 1,

  };

  my $other_join = '';
  my $extra_fields = '';

  if ($sql_field_lookup->{'SampleTypeId'}) {

    $other_join .=  ' LEFT JOIN generaltype ON crossingmeasurement.SampleTypeId = generaltype.TypeId ';
    $extra_fields .= ', generaltype.TypeName ';
  }

  if ($sql_field_lookup->{'OperatorId'}) {
    
    $extra_fields .= ", concat(contact.ContactFirstName,' ',contact.ContactLastName) As Contact, contact.ContactId";

    $other_join .=  ' LEFT JOIN systemuser ON crossingmeasurement.OperatorId = systemuser.UserId  LEFT JOIN contact on systemuser.ContactId = contact.ContactId ';
  }


  $sql    =  "SELECT crossingmeasurement.*, trait.TraitName $extra_fields FROM crossingmeasurement ";
  $sql   .=  "LEFT JOIN trait ON trait.TraitId = crossingmeasurement.TraitId ";
  $sql   .=  "$other_join ";
  $sql   .=  "$filtering_exp ";


  my ($sort_err, $sort_msg, $sort_sql) = parse_sorting($sorting, $final_field_list);

  if ($sort_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sort_msg}]};

    return $data_for_postrun_href;
  }

  if (length($sort_sql) > 0) {

    $sql    .= " ORDER BY $sort_sql";
  }
  else {

    $sql    .= 'ORDER BY crossingmeasurement.CrossingId DESC';
  }

  $sql   .=  " $paged_limit_clause ";

  my ($read_crossing_err, $read_crossing_msg, $crossing_data)   =  $self->list_crossingmeasurement($sql, $where_arg, $field_list);

  if ($read_crossing_err) {

    $self->logger->debug($read_crossing_msg);
    $data_for_postrun_href->{'Error'}  =  1;
    $data_for_postrun_href->{'Data'}   =  {'Error' =>  [{'Message' => 'Unexpected error. '}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}   = 0;
  $data_for_postrun_href->{'Data'}    = {'crossingmeasurement'         =>   $crossing_data,
                                         'Pagination'              =>   $pagination_aref,
                                         'RecordMeta'              =>   [{'TagName' => 'crossingmeasurement'}],
                                        };

  return $data_for_postrun_href;
}

sub list_crossingmeasurement {

  my $self            = $_[0];
  my $sql             = $_[1];
  my $where_para_aref = $_[2];
  my $field_list      = $_[3];

  my $err = 0;
  my $msg = '';

  my $data_aref = [];

  my $sql_update       = $sql;

  my $sql_select_field = ['crossingmeasurement.CrossingId',
                          'crossingmeasurement.TraitId',
                          'crossingmeasurement.OperatorId',
                          'crossingmeasurement.MeasureDateTime',
                          'crossingmeasurement.InstanceNumber',
                          'crossingmeasurement.SampleTypeId',
                          'crossingmeasurement.TraitValue' ];

  $sql_select_field       =  join(',', @{$sql_select_field});
  $self->logger->debug("SQL 1: $sql");

  $sql_update  =~ s/SELECT crossingmeasurement.\*/ $sql_select_field /;
  
  $sql = 'SELECT' . $sql_update;
  $self->logger->debug("SQL 2: $sql");

  my $dbh = connect_kdb_read();

  ($err, $msg, $data_aref) = read_data($dbh, $sql, $where_para_aref);

  if ($err) {

    return ($err, $msg, []);
  }

  $dbh->disconnect();

  return ($err, $msg, $data_aref);
}

sub import_crossingmeasurement_csv_runmode {

=pod import_crossingmeasurement_csv_HELP_START
{
"OperationName": "Import crossing measurements",
"Description": "Import crossing measurements from a csv file formatted as a sparse matrix of phenotypic data.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='2 records of crossingmeasurement have been inserted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : '2 records of crossingmeasurement have been inserted successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Row (1): Crossing (1) does not exist.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Row (1): Crossing (1) does not exist.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "CSV",
"UploadFileParameterName": "uploadfile",
"HTTPParameter": [{"Required": 1, "Name": "CrossingId", "Description": "Column number counting from zero for CrossingId column in the upload CSV file"}, {"Required": 1, "Name": "SampleTypeId", "Description": "Column number counting from zero for SampleTypeId column in the upload CSV file"}, {"Required": 1, "Name": "TraitId", "Description": "Column number counting from zero for TraitId column in the upload CSV file"}, {"Required": 1, "Name": "OperatorId", "Description": "Column number counting from zero for OperatorId column for the upload CSV file"}, {"Required": 1, "Name": "MeasureDateTime", "Description": "Column number counting from zero for MeasureDateTime column in the upload CSV file"}, {"Required": 1, "Name": "InstanceNumber", "Description": "Column number counting from zero for InstanceNumber column in the upload CSV file"}, {"Required": 1, "Name": "TraitValue", "Description": "Column number counting from zero for TraitValue column in the upload CSV file"},  {"Required": 0, "Name": "StateReason", "Description": "Column number counting from zero for StateReason column in the upload CSV file for sub-plot scoring"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $data_csv_file = $self->authen->get_upload_file();

  my $num_of_col = get_csvfile_num_of_col($data_csv_file);

  $self->logger->debug("Number of columns: $num_of_col");

  my $CrossingId_col      = $query->param('CrossingId');
  my $TraitId_col         = $query->param('TraitId');
  my $OperatorId_col      = $query->param('OperatorId');
  my $InstanceNumber_col  = $query->param('InstanceNumber');
  my $SampleTypeId_col    = $query->param('SampleTypeId');
  my $MeasureDateTime_col = $query->param('MeasureDateTime');
  my $TraitValue_col      = $query->param('TraitValue');

  my $chk_col_href = { 'CrossingId'      => $CrossingId_col,
                       'SampleTypeId'    => $SampleTypeId_col,
                       'TraitId'         => $TraitId_col,
                       'MeasureDateTime' => $MeasureDateTime_col,
                       'InstanceNumber'  => $InstanceNumber_col,
                       'TraitValue'      => $TraitValue_col,
                     };

  my $matched_col = {};

  $matched_col->{$CrossingId_col}      = 'CrossingId';
  $matched_col->{$SampleTypeId_col}    = 'SampleTypeId';
  $matched_col->{$TraitId_col}         = 'TraitId';
  $matched_col->{$MeasureDateTime_col} = 'MeasureDateTime';
  $matched_col->{$InstanceNumber_col}  = 'InstanceNumber';
  $matched_col->{$TraitValue_col}      = 'TraitValue';

  my $StateReason_col = undef;

  if (defined $query->param('StateReason')) {

    if (length($query->param('StateReason')) > 0) {

      $StateReason_col = $query->param('StateReason');
      $chk_col_href->{'StateReason'} = $StateReason_col;

      $matched_col->{$StateReason_col} = 'StateReason';
    }
  }

  my ($col_def_err, $col_def_err_href) = check_col_def_href( $chk_col_href, $num_of_col);

  if ($col_def_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$col_def_err_href]};

    return $data_for_postrun_href;
  }

  if (length($OperatorId_col) > 0) {

    my ($col_def_err, $col_def_err_href) = check_col_def_href( { 'OperatorId' => $OperatorId_col },
                                                               $num_of_col
        );

    if ($col_def_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [$col_def_err_href]};

      return $data_for_postrun_href;
    }

    $matched_col->{$OperatorId_col} = 'OperatorId';
  }

  my @fieldname_list;

  for (my $i = 0; $i < $num_of_col; $i++) {

    if ($matched_col->{$i}) {

      push(@fieldname_list, $matched_col->{$i});
    }
    else {

      push(@fieldname_list, 'null');
    }
  }

  my ($data_aref, $csv_err, $err_msg) = csvfile2arrayref($data_csv_file, \@fieldname_list, 0);

  if ($csv_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_write = connect_kdb_write();

  my $check_non_trait_field = 1;
  my $validate_trait_value  = 1;
  my $enforce_single_trial_data  = 1;

  $data_for_postrun_href = $self->insert_crossingmeasurement_data_v2($dbh_write,
                                                                $data_aref,
                                                                $check_non_trait_field,
                                                                $validate_trait_value,
                                                                $enforce_single_trial_data
      );

  $dbh_write->disconnect();

  return $data_for_postrun_href;
}


sub export_crossingmeasurement_csv_runmode {

=pod export_crossingmeasurement_csv_HELP_START
{
"OperationName": "Export crossing measurements",
"Description": "Export crossing measurements (if exists) into a csv file formatted as a sparse matrix of phenotypic data",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><OutputFile csv='http://kddart-d.diversityarrays.com/data/admin/export_crossingmeasurement_fc77a5593427a35b804a07150dccb942.csv' /></DATA>",
"SuccessMessageJSON": "{'OutputFile' : [{'csv' : 'http://kddart-d.diversityarrays.com/data/admin/export_crossingmeasurement_fc77a5593427a35b804a07150dccb942.csv'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPParameter": [{"Required": 0, "Name": "CrossingIdCSV", "Description": "Filtering parameter for CrossingId. The value is comma separated value of CrossingId."}, {"Required": 0, "Name": "SampleTypeIdCSV", "Description": "Filtering parameter for SampleTypeId. The value is comma separated value of SampleTypeId."}, {"Required": 0, "Name": "TraitIdCSV", "Description": "Filtering parameter for TraitId. The value is comma separated value of TraitId."}, {"Required": 0, "Name": "OperatorIdCSV", "Description": "Filtering parameter for OperatorId. The value is comma separated value of OperatorId."}, {"Required": 0, "Name": "MeasureDateTimeFrom", "Description": "Filtering parameter for MeasureDateTime. The value is correctly formatted date/time from which the crossing measurement was recorded."}, {"Required": 0, "Name": "MeasureDateTimeTo", "Description": "Filtering parameter for MeasureDateTime. The value is correctly formatted date/time to which the crossing measurement was recorded."}, {"Required": 0, "Name": "CMGroupIdCSV", "Description": "Filtering parameter for CMGroupId. The value is comma separated value of CMGroupId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $crossing_id_csv = '';

  if (defined $query->param('CrossingIdCSV')) {

    $crossing_id_csv = $query->param('CrossingIdCSV');
  }

  my $stype_id_csv = '';

  if (defined $query->param('SampleTypeIdCSV')) {

    $stype_id_csv = $query->param('SampleTypeIdCSV');
  }

  my $trait_id_csv = '';

  if (defined $query->param('TraitIdCSV')) {

    $trait_id_csv = $query->param('TraitIdCSV');
  }

  my $operator_id_csv = '';

  if (defined $query->param('OperatorIdCSV')) {

    $operator_id_csv = $query->param('OperatorIdCSV');
  }

  my $measure_dt_from = '';

  if (defined $query->param('MeasureDateTimeFrom')) {

    $measure_dt_from = $query->param('MeasureDateTimeFrom');
  }

  my $measure_dt_to = '';

  if (defined $query->param('MeasureDateTimeTo')) {

    $measure_dt_to = $query->param('MeasureDateTimeTo');
  }

  my $cmgroup_id_csv = '';

  if (defined $query->param('CMGroupIdCSV')) {

    $cmgroup_id_csv = $query->param('CMGroupIdCSV');
  }

  my $dbh = connect_kdb_read();

  $self->logger->debug("CrossingIdCSV: $crossing_id_csv");

  my @where_phrases;

  if (length($cmgroup_id_csv) > 0) {

    my ($smgrp_exist_err, $smgrp_rec_str) = record_exist_csv($dbh, 'cmgroup', 'CMGroupId', $cmgroup_id_csv);

    if ($smgrp_exist_err) {

      my $err_msg = "CMGroup ($smgrp_rec_str): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $where_smgrp = " CMGroupId IN ($smgrp_rec_str) ";
    push(@where_phrases, $where_smgrp);
  }

  if (length($crossing_id_csv) > 0) {

    my ($crossing_exist_err, $crossing_rec_str) = record_exist_csv($dbh, 'crossing', 'CrossingId', $crossing_id_csv);

    if ($crossing_exist_err) {

      my $err_msg = "Crossing ($crossing_rec_str) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $where_crossing = " crossingmeasurement.CrossingId IN ($crossing_rec_str) ";
    push(@where_phrases, $where_crossing);
  }

  if (length($stype_id_csv) > 0) {

    my ($stype_exist_err, $stype_rec_str) = type_existence_csv($dbh, 'crossing', $stype_id_csv);

    if ($stype_exist_err) {

      my $err_msg = "SampleType ($stype_rec_str) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $where_stype = " SampleTypeId IN ($stype_rec_str) ";
    push(@where_phrases, $where_stype);
  }

  if (length($trait_id_csv) > 0) {

    my ($trait_exist_err, $trait_rec_str) = record_exist_csv($dbh, 'trait', 'TraitId', $trait_id_csv);

    if ($trait_exist_err) {

      my $err_msg = "Trait ($trait_rec_str) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $where_trait = " TraitId IN ($trait_rec_str) ";
    push(@where_phrases, $where_trait);
  }

  if (length($operator_id_csv) > 0) {

    my ($oper_exist_err, $oper_rec_str) = record_exist_csv($dbh, 'systemuser', 'UserId', $operator_id_csv);

    if ($oper_exist_err) {

      my $err_msg = "Operator ($oper_rec_str) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $where_operator = " OperatorId IN ($oper_rec_str) ";
    push(@where_phrases, $where_operator);
  }

  my $where_measure_time = '';

  if (length($measure_dt_from) > 0) {

    my ($mdt_from_err, $mdt_from_msg) = check_dt_value( { 'MeasureDateTimeFrom' => $measure_dt_from } );

    if ($mdt_from_err) {

      my $err_msg = "$mdt_from_msg not date/time.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    $where_measure_time = " MeasureDateTime >= '$measure_dt_from' ";
  }

  if (length($measure_dt_to) > 0) {


    my ($mdt_to_err, $mdt_to_msg) = check_dt_value( { 'MeasureDateTimeTo' => $measure_dt_to } );

    if ($mdt_to_err) {

      my $err_msg = "$mdt_to_msg not date/time.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if (length($where_measure_time) > 0) {

      $where_measure_time .= " AND MeasureDateTime <= '$measure_dt_to' ";
    }
    else {

      $where_measure_time = " MeasureDateTime <= '$measure_dt_to' ";
    }
  }

  push(@where_phrases, $where_measure_time);

  my @field_headers = ('CrossingId', 'TraitId', 'OperatorId', 'MeasureDateTime',
                       'InstanceNumber', 'SampleTypeId', 'TraitValue',
                       'CMGroupId', 'StateReason');

  my @sql_field_list;

  foreach my $field_name (@field_headers) {

    push(@sql_field_list, "crossingmeasurement.${field_name}");
  }

  my $sql = 'SELECT ' . join(',', @sql_field_list) . ' ';
  $sql   .= 'FROM crossingmeasurement LEFT JOIN crossing ';
  $sql   .= 'ON crossingmeasurement.CrossingId = crossing.CrossingId ';

  my $where_clause = '';
  for my $phrase (@where_phrases) {

    if (length($phrase) > 0) {

      if (length($where_clause) > 0) {

        $where_clause .= "AND $phrase";
      }
      else {

        $where_clause .= "$phrase";
      }
    }
  }

  if (length($where_clause) > 0) {

    $sql .= " WHERE $where_clause ";
  }

  my $export_data_sql_md5 = md5_hex($sql);

  $self->logger->debug("SQL: $sql");

  my $username          = $self->authen->username();
  my $doc_root          = $ENV{'DOCUMENT_ROOT'};
  my $export_data_path  = "${doc_root}/data/$username";
  my $current_runmode   = $self->get_current_runmode();
  my $lock_filename     = "${current_runmode}.lock";
  my $filename          = "export_crossingmeasurement_$export_data_sql_md5";
  my $csv_file          = "${export_data_path}/${filename}.csv";

  if ( !(-e $export_data_path) ) {

    mkdir($export_data_path);
  }

  my $lockfile = File::Lockfile->new($lock_filename, $export_data_path);

  my $pid = $lockfile->check();

  if ($pid) {

    $self->logger->debug("$lock_filename exists in $export_data_path");
    my $msg = 'Lockfile exists: either another process of this export is running or ';
    $msg   .= 'there was an unexpected error regarding clearing this lockfile.';

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $msg}]};

    return $data_for_postrun_href;
  }

  $lockfile->write();

  my $sth = $dbh->prepare($sql);
  $sth->execute();

  if ($dbh->err()) {

    $lockfile->remove();
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("csv: $csv_file");

  open(my $smeasure_csv_fh, ">$csv_file") or die "Can't open $csv_file for writing: $!";

  print $smeasure_csv_fh '#' . join(',', @field_headers) . "\n";

  while ( my $row_aref = $sth->fetchrow_arrayref() ) {

    foreach my $col_entry (@{$row_aref}) {
        if (length($col_entry)) {
          $col_entry = qq|"$col_entry"|;
        }
        else {
          $col_entry = "";
        }
    }

    my $csv_line = join(',', @{$row_aref});

    print $smeasure_csv_fh "$csv_line\n";
  }

  close($smeasure_csv_fh);

  $lockfile->remove();

  $sth->finish();

  $self->logger->debug("Document root: $doc_root");

  $dbh->disconnect();

  my $url = reconstruct_server_url();

  my $info_aref = [{ 'csv' => "$url/data/$username/${filename}.csv" }];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'OutputFile' => $info_aref };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub import_cmgroup_data_csv_runmode {

=pod import_cmgroup_data_csv_HELP_START
{
"OperationName": "Import crossing measurements in a group",
"Description": "Import crossing measurements from a csv file formatted as a sparse matrix of phenotypic data in a group. It returns Crossing Measurement Group (CMGroupId) when the operation is successful.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "cmgroup",
"SkippedField": ["TrialId","OperatorId","CMGroupDateTime"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='3 records of crossingmeasurement have been inserted successfully.' /><StatInfo Unit='second' ServerElapsedTime='0.092' /><ReturnId Value='5' ParaName='CMGroupId' /></DATA>",
"SuccessMessageJSON": "{'StatInfo' : [{'ServerElapsedTime' : '0.109','Unit' : 'second'}],'ReturnId' : [{'ParaName' : 'CMGroupId','Value' : '6'}],'Info' : [{'Message' : '3 records of crossingmeasurement have been inserted successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Trial (16): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Trial (16): not found.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "CSV",
"UploadFileParameterName": "uploadfile",
"HTTPParameter": [{"Required": 1, "Name": "CrossingIdCol", "Description": "Column number counting from zero for CrossingId column in the upload CSV file"}, {"Required": 1, "Name": "CrossingTypeIdCol", "Description": "Column number counting from zero for SampleTypeId column in the upload CSV file"}, {"Required": 1, "Name": "TraitIdCol", "Description": "Column number counting from zero for TraitId column in the upload CSV file"}, {"Required": 1, "Name": "OperatorIdCol", "Description": "Column number counting from zero for OperatorId column for the upload CSV file"}, {"Required": 1, "Name": "MeasureDateTimeCol", "Description": "Column number counting from zero for MeasureDateTime column in the upload CSV file"}, {"Required": 1, "Name": "InstanceNumberCol", "Description": "Column number counting from zero for InstanceNumber column in the upload CSV file"}, {"Required": 1, "Name": "TraitValueCol", "Description": "Column number counting from zero for TraitValue column in the upload CSV file"}, {"Required": 0, "Name": "TrialUnitSpecimenIdCol", "Description": "Column number counting from zero for TrialUnitSpecimenId column in the upload CSV file for sub-plot scoring"}, {"Required": 0, "Name": "StateReasonCol", "Description": "Column number counting from zero for StateReason column in the upload CSV file for sub-plot scoring"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self     = shift;
  my $trial_id = $self->param('id');
  my $query    = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'TrialId'         => 1,
                    'OperatorId'      => 1,
                    'CMGroupDateTime' => 1,
                   };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'cmgroup', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  # Finish generic required static field checking

  my $cmgroup_name = $query->param('CMGroupName');

  my $operator_id = $self->authen->user_id();

  my $dbh_write = connect_kdb_write();

  if (record_existence($dbh_write, 'cmgroup', 'CMGroupName', $cmgroup_name)) {

    my $err_msg = "CMGroupName ($cmgroup_name): already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'CMGroupName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $cmgroup_status = undef;

  if (defined $query->param('CMGroupStatus')) {

    if (length($query->param('CMGroupStatus')) > 0) {

      $cmgroup_status = $query->param('CMGroupStatus');
    }
  }

  my $cmgroup_note = undef;

  if (defined $query->param('CMGroupNote')) {

    if (length($query->param('CMGroupNote')) > 0) {

      $cmgroup_note = $query->param('CMGroupNote');
    }
  }

  my $cur_dt = DateTime->now( time_zone => $TIMEZONE );
  $cur_dt = DateTime::Format::MySQL->format_datetime($cur_dt);

  if (!record_existence($dbh_write, 'trial', 'TrialId', $trial_id)) {

    my $err_msg = "Trial ($trial_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_trial_ok, $trouble_trial_id_aref) = check_permission($dbh_write, 'trial', 'TrialId',
                                                               [$trial_id], $group_id, $gadmin_status,
                                                               $READ_WRITE_PERM);

  if (!$is_trial_ok) {

    my $trouble_trial_id = $trouble_trial_id_aref->[0];
    my $err_msg = "Permission denied: Group ($group_id) and trial ($trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $data_csv_file = $self->authen->get_upload_file();

  my $num_of_col = get_csvfile_num_of_col($data_csv_file);

  $self->logger->debug("Number of columns: $num_of_col");

  my $CrossingId_col      = $query->param('CrossingIdCol');
  my $SampleTypeId_col    = $query->param('SampleTypeIdCol');
  my $TraitId_col         = $query->param('TraitIdCol');
  my $MeasureDateTime_col = $query->param('MeasureDateTimeCol');
  my $InstanceNumber_col  = $query->param('InstanceNumberCol');
  my $TraitValue_col      = $query->param('TraitValueCol');

  my $chk_col_href = { 'CrossingIdCol'      => $CrossingId_col,
                       'SampleTypeIdCol'    => $SampleTypeId_col,
                       'TraitIdCol'         => $TraitId_col,
                       'MeasureDateTimeCol' => $MeasureDateTime_col,
                       'InstanceNumberCol'  => $InstanceNumber_col,
                       'TraitValueCol'      => $TraitValue_col,
                     };

  my $matched_col = {};

  $matched_col->{$CrossingId_col}      = 'CrossingId';
  $matched_col->{$SampleTypeId_col}    = 'SampleTypeId';
  $matched_col->{$TraitId_col}         = 'TraitId';
  $matched_col->{$MeasureDateTime_col} = 'MeasureDateTime';
  $matched_col->{$InstanceNumber_col}  = 'InstanceNumber';
  $matched_col->{$TraitValue_col}      = 'TraitValue';

  my $StateReason_col = undef;

  if (defined $query->param('StateReasonCol')) {

    if (length($query->param('StateReasonCol')) > 0) {

      $StateReason_col = $query->param('StateReasonCol');
      $chk_col_href->{'StateReasonCol'} = $StateReason_col;

      $matched_col->{$StateReason_col} = 'StateReason';
    }
  }

  my $OperatorId_col      = undef;

  if (defined $query->param('OperatorIdCol')) {

    if (length($query->param('OperatorIdCol')) > 0) {

      $OperatorId_col = $query->param('OperatorIdCol');
      $chk_col_href->{'OperatorIdCol'} = $OperatorId_col;

      $matched_col->{$OperatorId_col} = 'OperatorId';
    }
  }

  my ($col_def_err, $col_def_err_href) = check_col_def_href( $chk_col_href, $num_of_col);

  if ($col_def_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$col_def_err_href]};

    return $data_for_postrun_href;
  }

  my @fieldname_list;

  for (my $i = 0; $i < $num_of_col; $i++) {
    if ($matched_col->{$i}) {

      push(@fieldname_list, $matched_col->{$i});
    }
    else {

      push(@fieldname_list, 'null');
    }
  }

  my ($data_aref, $csv_err, $err_msg) = csvfile2arrayref($data_csv_file, \@fieldname_list, 0);

  if ($csv_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'INSERT INTO cmgroup SET ';
  $sql   .= 'CMGroupName=?, ';
  $sql   .= 'TrialId=?, ';
  $sql   .= 'OperatorId=?, ';
  $sql   .= 'CMGroupStatus=?, ';
  $sql   .= 'CMGroupDateTime=?, ';
  $sql   .= 'CMGroupNote=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($cmgroup_name, $trial_id, $operator_id, $cmgroup_status, $cur_dt, $cmgroup_note);

  my $cmgroup_id = -1;

  if ($dbh_write->err()) {

    $self->logger->debug("Add cmgroup record failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $cmgroup_id = $dbh_write->last_insert_id(undef, undef, 'cmgroup', 'CMGroupId');
  $self->logger->debug("CMGroupID: $cmgroup_id");

  $sth->finish();

  my $check_non_trait_field      = 1;
  my $validate_trait_value       = 1;
  my $enforce_single_trial_data  = 1;

  $data_for_postrun_href = $self->insert_crossingmeasurement_data_v2($dbh_write,
                                                                $data_aref,
                                                                $check_non_trait_field,
                                                                $validate_trait_value,
                                                                $enforce_single_trial_data,
                                                                $cmgroup_id
                                                               );

  if ($data_for_postrun_href->{'Error'} == 1) {

    # Delete CMGroup record and return $data_for_postrun_href
    $sql = 'DELETE FROM cmgroup WHERE CMGroupId=?';

    $sth = $dbh_write->prepare($sql);
    $sth->execute($cmgroup_id);

    if ($dbh_write->err()) {

      $self->logger->debug("Delete cmgroup record failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }
  }

  $dbh_write->disconnect();

  my $return_id_aref = [{'Value'   => "$cmgroup_id", 'ParaName' => 'CMGroupId'}];

  $data_for_postrun_href->{'Data'}->{'ReturnId'} = $return_id_aref;

  return $data_for_postrun_href;
}

sub insert_crossingmeasurement_data_v2 {

  my $self                = $_[0];
  my $dbh_write           = $_[1];
  my $data_aref           = $_[2];
  my $chk_non_trait_field = $_[3];
  my $validate_trait      = $_[4];
  my $enforce_single_trial_data      = $_[5];

  my $cmgroup_id = 0;

  if (defined $_[6]) {

    $cmgroup_id = $_[6];
  }

  my $data_for_postrun_href = {};

  my $user_id       = $self->authen->user_id();
  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str      = permission_phrase($group_id, 0, $gadmin_status);

  #full error array with the following format for individual errors
  # {'Row' => row of error, 'Type' => type of error, 'Message' => 'message', 'ErrorInput' => what input caused error}
  my $full_error_aref = [];

  if (scalar(@{$data_aref}) == 0) {

    $self->logger->debug("No data provided");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'No data provided.'}]};

    return $data_for_postrun_href;
  }

  my $bulk_sql = 'INSERT INTO crossingmeasurement ';
  $bulk_sql   .= '(CrossingId,SampleTypeId,CMGroupId,TraitId,OperatorId,MeasureDateTime,InstanceNumber,TraitValue,StateReason) ';
  $bulk_sql   .= 'VALUES ';

  my $sql;
  my $sth;

  my $uniq_sam_type_href      = {};
  my $sam_type_val_aref       = [];
  my $sam_type_idx_aref       = [];

  my $uniq_trait_id_href      = {};
  my $trait_id_val_aref       = [];
  my $trait_id_idx_aref       = [];

  my $crossing_trait_id_val_aref    = [];
  my $crossing_trait_id_idx_aref    = [];

  my $uniq_operator_href      = {};
  my $operator_val_aref       = [];
  my $operator_idx_aref       = [];

  my $trait_id2val_href       = {};
  my $trait_id2idx_href       = {};

  my $date_error_flag = 0;
  my $date_error_aref = [];

  my $row_counter = 1;
  for my $data_row (@{$data_aref}) {
    $self->logger->debug("$row_counter:");
    for my $data_key (keys(%{$data_row})) {
      $self->logger->debug("$data_key -> " .$data_row->{$data_key});
    }  

    $self->logger->debug("----");

    my $effective_user_id = $user_id;
    my $crossing_id           = $data_row->{'CrossingId'};
    my $samp_type_id      = $data_row->{'SampleTypeId'};
    my $trait_id          = $data_row->{'TraitId'};
    
    $uniq_trait_id_href->{$trait_id}     = 1;
    $uniq_sam_type_href->{$samp_type_id} = 1;

    #$self->logger->debug("Checking non trait data: $chk_non_trait_field");

    if ($chk_non_trait_field) {

      my ($int_id_err, $int_id_msg) = check_integer_value( { 'CrossingId'         => $data_row->{'CrossingId'},
                                                             'SampleTypeId'   => $data_row->{'SampleTypeId'},
                                                             'TraitId'        => $data_row->{'TraitId'},
                                                             'InstanceNumber' => $data_row->{'InstanceNumber'},
                                                           });

      if ($int_id_err) {

        $int_id_msg = "Row ($row_counter): " . $int_id_msg . ' not integer.';

        my $error_obj = {};

        $error_obj->{'Message'} = $int_id_msg;
        $error_obj->{'Row'} = $row_counter;
        $error_obj->{'Type'} = 'CrossingInteger';
        $error_obj->{'ErrorInput'} = $int_id_msg;

        push(@{$full_error_aref}, $error_obj);
      }

      if (length($data_row->{'OperatorId'}) > 0) {

        my $operator_id = $data_row->{'OperatorId'};

        my ($int_err, $int_msg) = check_integer_value( { 'OperatorId' => $operator_id } );

        if ($int_err) {

          $int_msg = "Row ($row_counter): " . $int_msg . ' not an integer.';

          my $error_obj = {};

          $error_obj->{'Message'} = $int_msg;
          $error_obj->{'Row'} = $row_counter;
          $error_obj->{'Type'} = 'OperatorInteger';
          $error_obj->{'ErrorInput'} = $int_id_msg;

          push(@{$full_error_aref}, $error_obj);
        }

        $uniq_operator_href->{$operator_id} = 1;
        push(@{$operator_val_aref}, $operator_id);
        push(@{$operator_idx_aref}, $row_counter);

        $effective_user_id = $operator_id;
      }
    }


    push(@{$sam_type_val_aref},$samp_type_id);
    push(@{$sam_type_idx_aref},$row_counter);

    if (length($data_row->{'OperatorId'}) > 0) {

      $effective_user_id = $data_row->{'OperatorId'};
    }
    my $trait_val = $data_row->{'TraitValue'};
    my $db_trait_val = $dbh_write->quote($trait_val);

    if ($validate_trait) {

      if (defined $trait_id2val_href->{$trait_id}) {

        my $val_aref = $trait_id2val_href->{$trait_id};
        push(@{$val_aref}, $trait_val);
        $trait_id2val_href->{$trait_id} = $val_aref;
      }
      else {

        $trait_id2val_href->{$trait_id} = [$trait_val];
      }

      if (defined $trait_id2idx_href->{$trait_id}) {

        my $idx_aref = $trait_id2idx_href->{$trait_id};
        push(@{$idx_aref}, $row_counter);
        $trait_id2idx_href->{$trait_id} = $idx_aref;
      }
      else {

        $trait_id2idx_href->{$trait_id} = [$row_counter];
      }
    }

    my $measure_dt   = $data_row->{'MeasureDateTime'};

    # Check measure date/time

    my ($measure_dt_err, $measure_dt_msg) = check_dt_value( {'MeasureDateTime' => $measure_dt} );

    if ($measure_dt_err) {

      my $error_obj = {};

      $error_obj->{'Message'} = $measure_dt_msg;
      $error_obj->{'Row'} = $row_counter;
      $error_obj->{'Type'} = 'Date';
      $error_obj->{'ErrorInput'} = $measure_dt;

      push(@{$full_error_aref}, $error_obj);
    }

    # End check measure date/time

    my $instance_num = $data_row->{'InstanceNumber'};

    my $state_reason      = 'NULL';

    if (defined $data_row->{'StateReason'}) {

      if (length($data_row->{'StateReason'}) > 0) {

        $state_reason = $dbh_write->quote($data_row->{'StateReason'});
      }
    }

    $bulk_sql .= "($crossing_id,$samp_type_id,$cmgroup_id,$trait_id,$effective_user_id,";
    $bulk_sql .= "'$measure_dt',$instance_num,$db_trait_val,$state_reason),";

    $row_counter += 1;
  }

  chop($bulk_sql);      # remove excessive comma
  #

  my @trait_id_list = keys(%{$uniq_trait_id_href});

  if (scalar(@trait_id_list) == 0) {

    $self->logger->debug("List of trait id is empty");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  # Release the memorny
  $uniq_trait_id_href = {};

  $sql  = "SELECT TraitId, $perm_str AS UltimatePerm ";
  $sql .= "FROM trait ";
  $sql .= "WHERE TraitId IN (" . join(',', @trait_id_list) . ')';

  my $trait_lookup = $dbh_write->selectall_hashref($sql, 'TraitId');

  if ($dbh_write->err()) {

    $self->logger->debug("Get trait info failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my @operator_list = keys(%{$uniq_operator_href});

  if (scalar(@operator_list) > 0) {

    $sql = "SELECT UserId FROM systemuser WHERE UserId IN (" . join(',', @operator_list) . ")";

    my $operator_lookup = $dbh_write->selectall_hashref($sql, 'UserId');

    if ($dbh_write->err()) {

      $self->logger->debug("Get operator info failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    for (my $i = 0; $i < scalar(@{$operator_val_aref}); $i++) {

      my $oper_id  = $operator_val_aref->[$i];
      my $row_num  = $operator_idx_aref->[$i];

      if (! defined $operator_lookup->{$oper_id}) {

        my $err_msg = "Row ($row_num): Operator ($oper_id) does not exist.";

        my $error_obj = {};

        $error_obj->{'Message'} = $err_msg;
        $error_obj->{'Row'} = $row_num;
        $error_obj->{'Type'} = "Operator";
        #$error_obj->{'Date'} = $measure_dt;
        $error_obj->{'ErrorInput'} = "Operator ($oper_id)";

        push(@{$full_error_aref}, $error_obj);
      }
    }
  }

  my @sample_type_list = keys(%{$uniq_sam_type_href});

  if (scalar(@sample_type_list) == 0) {

    $self->logger->debug("List of sample type id is empty");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sql  = "SELECT TypeId FROM generaltype WHERE Class='sample' AND ";
  $sql .= "TypeId IN (" . join(',', @sample_type_list) . ")";

  my $sample_type_lookup = $dbh_write->selectall_hashref($sql, 'TypeId');

  if ($dbh_write->err()) {

    $self->logger->debug("Get sample type info failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  for (my $i = 0; $i < scalar(@{$sam_type_val_aref}); $i++) {

    my $sam_type_id = $sam_type_val_aref->[$i];
    my $row_num     = $sam_type_idx_aref->[$i];

    if (! defined $sample_type_lookup->{$sam_type_id}) {

      my $err_msg = "Row ($row_num): SampleType ($sam_type_id) does not exist.";

      my $error_obj = {};

      $error_obj->{'Message'} = $err_msg;
      $error_obj->{'Row'} = $row_num;
      $error_obj->{'Type'} = "SampleType";
      #$error_obj->{'Date'} = $measure_dt;
      $error_obj->{'ErrorInput'} = "SampleType ($sam_type_id)";

      push(@{$full_error_aref}, $error_obj);
    }
  }

  my $trait_validation_error_aref = [];

  $self->logger->debug("Now trying to validate trait values");

  for my $trait_id2val (keys(%{$trait_id2val_href})) {
    $self->logger->debug("Trait: $trait_id2val");
  }

  my ($v_trait_val_err, $invalid_error_message,
      $v_trait_id_href, $trait_validation_error_aref) = validate_trait_db_bulk_v2($dbh_write, $trait_id2val_href,$self);

  $self->logger->debug("Validation Error: $v_trait_val_err");
  $self->logger->debug("Validation Error: $invalid_error_message");
  $self->logger->debug("Number of Validation Error: " . scalar(@{$trait_validation_error_aref}));

  if ($v_trait_val_err) {

    foreach my $invalid_obj (@{$trait_validation_error_aref}) {

      my $v_trait_id = $invalid_obj->{'Trait'};
      my $v_trait_idx = $invalid_obj->{'Index'};
      my $v_trait_val_msg = $v_trait_id . ": ". $invalid_obj->{'Message'};
      my $v_trait_val = $invalid_obj->{'Value'};

      $self->logger->debug("Validation error on TraitId: $v_trait_id - index: $v_trait_idx");
      my $row_num = $trait_id2idx_href->{$v_trait_id}->[$v_trait_idx];
      my $err_msg = "Row ($row_num): $v_trait_val_msg";

      my $error_obj = {};

      $error_obj->{'Message'} = $err_msg;
      $error_obj->{'Row'} = $row_num;
      $error_obj->{'Type'} = "Validation";
      #$error_obj->{'Date'} = $measure_dt;
      $error_obj->{'ErrorInput'} = "$v_trait_val (Trait $v_trait_id)";

      push(@{$full_error_aref}, $error_obj);
    }

  }

  foreach my $error_obj (@{$full_error_aref}) {
      $self->logger->debug($error_obj->{'Row'}. ": " . $error_obj->{'Message'});
  }

  if (scalar(@{$full_error_aref}) > 0) {
    my $err_msg = 'Issues with CSV identified while inserting crossing measurement data';

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg,'ErrorList' => $full_error_aref}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("Bulk SQL: $bulk_sql");

  my $nrows_inserted = $dbh_write->do($bulk_sql);

  if ($dbh_write->err()) {

    $self->logger->debug("Db err code: " . $dbh_write->err());

    if ($dbh_write->err() == 1062) {

      my $err_str = $dbh_write->errstr();

      $err_str =~ /Duplicate entry '(.+)'/;
      my $err_msg = "Duplicate Entry: $1";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    else {

      $self->logger->debug('Error code: ' . $dbh_write->err());
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }
  }

  my $info_msg = "$nrows_inserted records of crossingmeasurement have been inserted successfully.";
  my $info_msg_aref = [{'Message' => $info_msg}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_cmgroup_runmode {

=pod list_cmgroup_HELP_START
{
"OperationName": "List crossingmeasurement groups",
"Description": "List available crossingmeasurement group.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='CMGroup' /><CMGroup TrialId='14' OperatorId='0' NumOfMeasurement='3' CMGroupDateTime='2017-04-19 15:22:10' CMGroupId='6' OperatorUserName='admin' CMGroupName='CMG_31217813748' CMGroupStatus='TEST' CMGroupNote='Testing' update='update/cmgroup/6' delete='delete/cmgroup/6' /><StatInfo ServerElapsedTime='0.006' Unit='second' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'CMGroup'}],'StatInfo' : [{'ServerElapsedTime' : '0.007','Unit' : 'second'}],'CMGroup' : [{'CMGroupId' : '6','CMGroupDateTime' : '2017-04-19 15:22:10','OperatorId' : '0','NumOfMeasurement' : '3','TrialId' : '14','delete' : 'delete/cmgroup/6','CMGroupName' : 'CMG_31217813748','update' : 'update/cmgroup/6','CMGroupNote' : 'Testing','CMGroupStatus' : 'TEST','OperatorUserName' : 'admin'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self     = shift;
  my $trial_id = $self->param('id');
  my $query    = $self->query();

  my $filtering_csv = '';

  if (defined $query->param('Filtering')) {

    $filtering_csv = $query->param('Filtering');
  }

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  if (!record_existence($dbh, 'trial', 'TrialId', $trial_id)) {

    my $err_msg = "Trial ($trial_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_trial_ok, $trouble_trial_id_aref) = check_permission($dbh, 'trial', 'TrialId',
                                                               [$trial_id], $group_id, $gadmin_status,
                                                               $READ_PERM);

  if (!$is_trial_ok) {

    my $trouble_trial_id = $trouble_trial_id_aref->[0];
    my $err_msg = "Permission denied: Group ($group_id) and trial ($trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  my $sql = 'SELECT cmgroup.*, systemuser.UserName AS OperatorUserName ';
  $sql   .= 'FROM cmgroup LEFT JOIN systemuser ON cmgroup.OperatorId = systemuser.UserId ';
  $sql   .= 'WHERE TrialId=?';

  my $filter_field_list = ['CMGroupName', 'OperatorId', 'CMGroupStatus', 'CMGroupDateTime', 'CMGroupNote'];

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering('CMGroupId',
                                                                              'cmgroup',
                                                                              $filtering_csv,
                                                                              $filter_field_list);

  if ($filter_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $filter_msg}]};

    return $data_for_postrun_href;
  }

  if (length($filter_phrase) > 0) {

    $sql .= " AND $filter_phrase";
  }


  my ($read_cmgrp_err, $read_cmgrp_msg, $cmgrp_data) = $self->list_cmgroup(1, 0, $sql, [$trial_id, @{$where_arg}]);

  if ($read_cmgrp_err) {

    $self->logger->debug($read_cmgrp_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'CMGroup'    => $cmgrp_data,
                                           'RecordMeta' => [{'TagName' => 'CMGroup'}],
  };

  return $data_for_postrun_href;
}

sub list_cmgroup {

  my $self            = $_[0];
  my $extra_attr_yes  = $_[1];
  my $detail_attr_yes = $_[2];
  my $sql             = $_[3];
  my $where_para_aref = $_[4];

  my $err       = 0;
  my $msg       = '';
  my $data_aref = [];

  my $dbh = connect_kdb_read();

  ($err, $msg, $data_aref) = read_data($dbh, $sql, $where_para_aref);

  if ($err) {

    return ($err, $msg, []);
  }

  my $cmgroup_id_aref    = [];

  my $smcount_lookup     = {};
  my $trait_lookup       = {};
  my $trial_unit_lookup  = {};
  my $tu_spec_lookup     = {};

  my $uniq_cmgrp_trait_href   = {};
  my $uniq_cmgrp_tu_href      = {};
  my $uniq_cmgrp_tu_spec_href = {};

  if ($extra_attr_yes || $detail_attr_yes) {

    for my $cmgroup_rec (@{$data_aref}) {

      push(@{$cmgroup_id_aref}, $cmgroup_rec->{'CMGroupId'});
    }

    if (scalar(@{$cmgroup_id_aref}) > 0) {

      my $count_sql = 'SELECT CMGroupId, COUNT(CrossingId) AS NumOfMeasurement ';
      $count_sql   .= 'FROM crossingmeasurement ';
      $count_sql   .= 'WHERE CMGroupId IN (' . join(',', @{$cmgroup_id_aref}) . ') ';
      $count_sql   .= 'GROUP BY CMGroupId';

      $self->logger->debug("COUNT MEASUREMENT SQL: $count_sql");

      $smcount_lookup = $dbh->selectall_hashref($count_sql, 'CMGroupId');

      if ($dbh->err()) {

        $self->logger->debug("Count number of crossingmeasurement failed");
        $err = 1;
        $msg = 'Unexpected Error';

        return ($err, $msg, []);
      }

    }
  }

  my $extra_attr_cmgroup_data = [];

  my $user_id = $self->authen->user_id();

  my $gadmin_status = $self->authen->gadmin_status();

  if ($extra_attr_yes) {

    for my $cmgroup_rec (@{$data_aref}) {

      my $cmgrp_id     = $cmgroup_rec->{'CMGroupId'};
      my $operator_id  = $cmgroup_rec->{'OperatorId'};

      if ("$operator_id" eq "$user_id") {

        $cmgroup_rec->{'update'} = "update/cmgroup/${cmgrp_id}";
        $cmgroup_rec->{'delete'} = "delete/cmgroup/${cmgrp_id}";
      }

      if (defined $smcount_lookup->{$cmgrp_id}) {

        $cmgroup_rec->{'NumOfMeasurement'} = $smcount_lookup->{$cmgrp_id}->{'NumOfMeasurement'};
      }

      if ($detail_attr_yes) {

        if (defined $trait_lookup->{$cmgrp_id}) {

          $cmgroup_rec->{'Trait'} = $trait_lookup->{$cmgrp_id};
        }

        if (defined $trial_unit_lookup->{$cmgrp_id}) {

          $cmgroup_rec->{'Crossing'} = $trial_unit_lookup->{$cmgrp_id};
        }

        if (defined $tu_spec_lookup->{$cmgrp_id}) {

          $cmgroup_rec->{'TrialUnitSpecimen'} = $tu_spec_lookup->{$cmgrp_id};
        }
      }

      push(@{$extra_attr_cmgroup_data}, $cmgroup_rec);
    }
  }
  else {

    $extra_attr_cmgroup_data = $data_aref;
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_cmgroup_data);
}

sub get_cmgroup_runmode {

=pod get_cmgroup_HELP_START
{
"OperationName": "Get crossingmeasurement group",
"Description": "Get detail information about a crossingmeasurement group.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><CMGroup update='update/cmgroup/6' NumOfMeasurement='3' CMGroupDateTime='2017-04-19 15:22:10' TrialId='14' OperatorUserName='admin' CMGroupStatus='TEST' CMGroupNote='Testing' CMGroupId='6' delete='delete/cmgroup/6' CMGroupName='CMG_31217813748' OperatorId='0'><Trait TraitId='14' TraitName='Trait_75223850117' /><Crossing CrossingId='14' /></CMGroup><StatInfo Unit='second' ServerElapsedTime='0.015' /><RecordMeta TagName='CMGroup' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'CMGroup'}],'CMGroup' : [{'NumOfMeasurement' : '3','update' : 'update/cmgroup/6','Trait' : [{'TraitName' : 'Trait_75223850117','TraitId' : '14'}],'Crossing' : [{'CrossingId' : '14'}],'CMGroupDateTime' : '2017-04-19 15:22:10','OperatorUserName' : 'admin','CMGroupStatus' : 'TEST','TrialId' : '14','CMGroupNote' : 'Testing','CMGroupId' : '6','CMGroupName' : 'CMG_31217813748','delete' : 'delete/cmgroup/6','OperatorId' : '0'}],'StatInfo' : [{'ServerElapsedTime' : '0.018','Unit' : 'second'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='CMGroup (7): not found.' /><StatInfo ServerElapsedTime='0.013' Unit='second' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'CMGroup (7): not found.'}],'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.013'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing CMGroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $cmgroup_id = $self->param('id');
  my $query      = $self->query();

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  my $trial_id = read_cell_value($dbh, 'cmgroup', 'TrialId', 'CMGroupId', $cmgroup_id);

  if (length($trial_id) == 0) {

    my $err_msg = "CMGroup ($cmgroup_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_trial_ok, $trouble_trial_id_aref) = check_permission($dbh, 'trial', 'TrialId',
                                                               [$trial_id], $group_id, $gadmin_status,
                                                               $READ_PERM);

  if (!$is_trial_ok) {

    my $trouble_trial_id = $trouble_trial_id_aref->[0];
    my $err_msg = "Permission denied: Group ($group_id) and trial ($trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  my $sql = 'SELECT cmgroup.*, systemuser.UserName AS OperatorUserName ';
  $sql   .= 'FROM cmgroup LEFT JOIN systemuser ON cmgroup.OperatorId = systemuser.UserId ';
  $sql   .= 'WHERE CMGroupId = ?';

  my ($read_cmgrp_err, $read_cmgrp_msg, $cmgrp_data) = $self->list_cmgroup(1, 1, $sql, [$cmgroup_id]);

  if ($read_cmgrp_err) {

    $self->logger->debug($read_cmgrp_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'CMGroup'    => $cmgrp_data,
                                           'RecordMeta' => [{'TagName' => 'CMGroup'}],
  };

  return $data_for_postrun_href;
}

sub update_cmgroup_runmode {

=pod update_cmgroup_HELP_START
{
"OperationName": "Update crossingmeasurement group",
"Description": "Update detail information about a crossingmeasurement group.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "cmgroup",
"SkippedField": ["TrialId","OperatorId","CMGroupDateTime"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><StatInfo Unit='second' ServerElapsedTime='0.047' /><Info Message='CMGroup (9) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'CMGroup (10) has been updated successfully.'}],'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.075'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='CMGroup (7): not found.' /><StatInfo ServerElapsedTime='0.013' Unit='second' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'CMGroup (7): not found.'}],'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.013'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing CMGroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $cmgroup_id = $self->param('id');
  my $query      = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'TrialId'         => 1,
                    'OperatorId'      => 1,
                    'CMGroupDateTime' => 1,
                   };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'cmgroup', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  # Finish generic required static field checking

  my $dbh = connect_kdb_read();

  my $chk_sql = 'SELECT TrialId, OperatorId, CMGroupName, CMGroupStatus, CMGroupNote ';
  $chk_sql   .= 'FROM cmgroup WHERE CMGroupId=?';

  my ($r_cmgrp_err, $r_cmgrp_msg, $cmgrp_data) = read_data($dbh, $chk_sql, [$cmgroup_id]);

  if ($r_cmgrp_err) {

    $self->logger->debug("Get info about existing cmgroup failed: $r_cmgrp_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$cmgrp_data}) == 0) {

    my $err_msg = "CMGroup ($cmgroup_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trial_id       = $cmgrp_data->[0]->{'TrialId'};
  my $operator_id    = $cmgrp_data->[0]->{'OperatorId'};
  my $db_cmgrp_name  = $cmgrp_data->[0]->{'CMGroupName'};

  my $cmgroup_status = undef;

  if (defined $cmgrp_data->[0]->{'CMGroupStatus'}) {

    if (length($cmgrp_data->[0]->{'CMGroupStatus'}) > 0) {

      $cmgroup_status = $cmgrp_data->[0]->{'CMGroupStatus'};
    }
  }

  $cmgroup_status = $query->param('CMGroupStatus');

  if (length($cmgroup_status) == 0) {

    $cmgroup_status = undef;
  }

  my $cmgroup_note = undef;

  if (defined $cmgrp_data->[0]->{'CMGroupNote'}) {

    if (length($cmgrp_data->[0]->{'CMGroupNote'}) > 0) {

      $cmgroup_note = $cmgrp_data->[0]->{'CMGroupNote'};
    }
  }

  $cmgroup_note = $query->param('CMGroupNote');

  if (length($cmgroup_note) == 0) {

    $cmgroup_note = undef;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_trial_ok, $trouble_trial_id_aref) = check_permission($dbh, 'trial', 'TrialId',
                                                               [$trial_id], $group_id, $gadmin_status,
                                                               $READ_WRITE_PERM);

  if (!$is_trial_ok) {

    my $trouble_trial_id = $trouble_trial_id_aref->[0];
    my $err_msg = "Permission denied: Group ($group_id) and trial ($trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  my $user_id = $self->authen->user_id();

  if ("$user_id" ne "0") {

    if ("$user_id" ne "$operator_id") {

      my $err_msg = "Permission denied: User ($user_id).";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $dbh_write = connect_kdb_write();

  my $cur_dt = DateTime->now( time_zone => $TIMEZONE );
  $cur_dt = DateTime::Format::MySQL->format_datetime($cur_dt);

  my $cmgroup_name = $query->param('CMGroupName');

  if ($cmgroup_name ne $db_cmgrp_name) {

    if (record_existence($dbh_write, 'cmgroup', 'CMGroupName', $cmgroup_name)) {

      my $err_msg = "CMGroup ($cmgroup_name): already exists.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'CMGroupName' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $sql = 'UPDATE cmgroup SET ';
  $sql   .= 'CMGroupName=?, ';
  $sql   .= 'CMGroupStatus=?, ';
  $sql   .= 'CMGroupDateTime=?, ';
  $sql   .= 'CMGroupNote=? ';
  $sql   .= 'WHERE CMGroupId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($cmgroup_name, $cmgroup_status, $cur_dt, $cmgroup_note, $cmgroup_id);

  if ($dbh_write->err()) {

    $self->logger->debug("Update CMGroup failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "CMGroup ($cmgroup_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub delete_cmgroup_runmode {

=pod delete_cmgroup_HELP_START
{
"OperationName": "Delete crossingmeasurement group",
"Description": "Delete a crossingmeasurement group and its associated crossingmeasurement records.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><StatInfo ServerElapsedTime='0.075' Unit='second' /><Info Message='CMGroup (12) and its crossingmeasurement records have been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'StatInfo' : [{'ServerElapsedTime' : '0.074','Unit' : 'second'}],'Info' : [{'Message' : 'CMGroup (11) and its crossingmeasurement records have been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='CMGroup (7): not found.' /><StatInfo ServerElapsedTime='0.013' Unit='second' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'CMGroup (7): not found.'}],'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.013'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing CMGroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $cmgroup_id = $self->param('id');
  my $query      = $self->query();

  my $data_for_postrun_href = {};

  my $dbh_write = connect_kdb_write();

  my $chk_sql = 'SELECT TrialId, OperatorId, CMGroupName, CMGroupStatus, CMGroupNote ';
  $chk_sql   .= 'FROM cmgroup WHERE CMGroupId=?';

  my ($r_cmgrp_err, $r_cmgrp_msg, $cmgrp_data) = read_data($dbh_write, $chk_sql, [$cmgroup_id]);

  if ($r_cmgrp_err) {

    $self->logger->debug("Get info about existing cmgroup failed: $r_cmgrp_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$cmgrp_data}) == 0) {

    my $err_msg = "CMGroup ($cmgroup_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trial_id       = $cmgrp_data->[0]->{'TrialId'};
  my $operator_id    = $cmgrp_data->[0]->{'OperatorId'};

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_trial_ok, $trouble_trial_id_aref) = check_permission($dbh_write, 'trial', 'TrialId',
                                                               [$trial_id], $group_id, $gadmin_status,
                                                               $READ_WRITE_PERM);

  if (!$is_trial_ok) {

    my $trouble_trial_id = $trouble_trial_id_aref->[0];
    my $err_msg = "Permission denied: Group ($group_id) and trial ($trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $user_id = $self->authen->user_id();

  if ("$user_id" ne "0") {

    if ("$user_id" ne "$operator_id") {

      my $err_msg = "Permission denied: User ($user_id).";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $sql = 'DELETE FROM crossingmeasurement WHERE CMGroupId=?';

  my $sth = $dbh_write->prepare($sql);

  $sth->execute($cmgroup_id);

  if ($dbh_write->err()) {

    $self->logger->debug("Delete crossingmeasurement failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $sql = 'DELETE FROM cmgroup where CMGroupId=?';

  $sth = $dbh_write->prepare($sql);

  $sth->execute($cmgroup_id);

  if ($dbh_write->err()) {

    $self->logger->debug("Delete cmgroup failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "CMGroup ($cmgroup_id) and its crossingmeasurement records have been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub export_dkdata_summary_runmode {

=pod export_dkdata_summary_HELP_START
{
"OperationName": "Export trial data",
"Description": "Exports current phenotypic data summary for the trial.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><OutputFile csv='http://kddart-d.diversityarrays.com/data/admin/export_dkdata_7_9b96633c51925e8c74f2b87bdc10c785.csv' /></DATA>",
"SuccessMessageJSON": "{'OutputFile' : [{'csv' : 'http://kddart-d.diversityarrays.com/data/admin/export_dkdata_7_9b96633c51925e8c74f2b87bdc10c785.csv'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='SampleType (143) invalid.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'SampleType (143) invalid.'}]}"}],
"HTTPParameter": [{"Required": 1, "Name": "SampleTypeId", "Description": "Value for SampleTypeId. This value is needed to restrict the data in 2-dimensional."}, {"Required": 1, "Name": "TrialId", "Description": "Value for TrialId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();
  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $query = $self->query();
  my $trial_id = $query->param('TrialId');
  my $sample_type_id = $query->param('SampleTypeId');
  my $custom_format = $query->param('CustomFormat'); #Use summarised format when the value is '1', otherwise use the detailed format.

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  if (length($trial_id) > 0) {

    my ($trial_exist_err, $trial_rec_str) = record_exist_csv($dbh, 'trial', 'TrialId', $trial_id);

    if ($trial_exist_err) {

      my $err_msg = "Trial ($trial_rec_str) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (length($sample_type_id) > 0) {

    my ($stype_exist_err, $stype_rec_str) = type_existence_csv($dbh, 'sample', $sample_type_id);

    if ($stype_exist_err) {

      my $err_msg = "SampleType ($stype_rec_str) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  #Detailed format
  my $sql = "SELECT trial.TrialId, trial.TrialName, site.SiteName, genotype.GenotypeId, genotype.GenotypeName, specimen.SpecimenId, specimen.SpecimenName, ";
  $sql   .= "samplemeasurement.TrialUnitId, trait.TraitId, trait.TraitName, AVG(samplemeasurement.TraitValue) as AVG_TraitValue ";
  $sql   .= "FROM samplemeasurement ";
  $sql   .= "LEFT JOIN trait ON samplemeasurement.TraitId=trait.TraitId ";
  $sql   .= "LEFT JOIN trialunit ON samplemeasurement.TrialUnitId=trialunit.TrialUnitId ";
  $sql   .= "LEFT JOIN trial ON trialunit.TrialId=trial.TrialId ";
  $sql   .= "LEFT JOIN trialunitspecimen ON trialunit.TrialUnitId=trialunitspecimen.TrialUnitId ";
  $sql   .= "LEFT JOIN site ON trial.SiteId=site.SiteId ";
  $sql   .= "LEFT JOIN specimen ON trialunitspecimen.SpecimenId=specimen.SpecimenId ";
  $sql   .= "LEFT JOIN genotypespecimen ON specimen.SpecimenId=genotypespecimen.SpecimenId ";
  $sql   .= "LEFT JOIN genotype ON genotypespecimen.GenotypeId=genotype.GenotypeId ";
  $sql   .= "WHERE trial.TrialId IN ($trial_id) AND samplemeasurement.SampleTypeId IN ($sample_type_id) ";
  $sql   .= "GROUP BY trial.TrialId, trait.TraitId, genotype.GenotypeId ";
  $sql   .= "ORDER BY samplemeasurement.TrialUnitId";

  $self->logger->debug("SQL: $sql");

  my $sth_pheno_data = $dbh->prepare($sql);
  $sth_pheno_data->execute();
  
  my $detailed_data_aref = $sth_pheno_data->fetchall_arrayref({});

  if ($sth_pheno_data->err()) {
    my $err_msg = "Get phenotypic data from trial failed.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$detailed_data_aref}) == 0) {
    my $err_msg = "No data attached to Trial ($trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $pheno_data_aref = $detailed_data_aref;

  #Summarised format
  if ($custom_format eq '1') {
    my $genotype_id_list = [ map { $_->{'GenotypeId'} } @$detailed_data_aref ];

    $sql  = "SELECT AVG(TraitValue) as AVG_TraitValue, trait.TraitName, trait.TraitId, genotype.GenotypeId, genotype.GenotypeName ";
    $sql .= "FROM samplemeasurement ";
    $sql .= "LEFT JOIN trialunit on samplemeasurement.TrialUnitId=trialunit.TrialUnitId ";
    $sql .= "LEFT JOIN trialunitspecimen on trialunitspecimen.TrialUnitId=trialunit.TrialUnitId ";
    $sql .= "LEFT JOIN specimen on specimen.SpecimenId = trialunitspecimen.SpecimenId ";
    $sql .= "LEFT JOIN genotypespecimen on specimen.SpecimenId = genotypespecimen.SpecimenId ";
    $sql .= "LEFT JOIN genotype on genotype.GenotypeId = genotypespecimen.GenotypeId ";
    $sql .= "LEFT JOIN trait on samplemeasurement.TraitId=trait.TraitId ";
    $sql .= "WHERE genotype.GenotypeId IN (".join(',', @{$genotype_id_list}).") ";
    $sql .= "GROUP BY trait.TraitId, genotype.GenotypeId ";
    $sql .= "ORDER BY trait.TraitId";

    $self->logger->debug("SQL: $sql");

    $sth_pheno_data = $dbh->prepare($sql);
    $sth_pheno_data->execute();
  
    $pheno_data_aref = $sth_pheno_data->fetchall_arrayref({});
  }

  my %output_data_row;
  for my $pheno_rec (@{$pheno_data_aref}) {
    my $genotypeid = $pheno_rec->{'GenotypeId'};
    my $genotypename = $pheno_rec->{'GenotypeName'};
    my $traitname = $pheno_rec->{'TraitName'};
    my $avg = $pheno_rec->{'AVG_TraitValue'};

    my $output_data_row  = {};
    if (!exists $output_data_row{$genotypeid}) {
      $output_data_row{$genotypeid} = {
        "GenotypeName" => $genotypename,
        "GenotypeId"   => $genotypeid
      };

      if ($custom_format ne '1') {
        $output_data_row{$genotypeid}->{'TrialId'}   = $pheno_rec->{'TrialId'};
        $output_data_row{$genotypeid}->{'TrialName'} = $pheno_rec->{'TrialName'};
        $output_data_row{$genotypeid}->{'SiteName'}  = $pheno_rec->{'SiteName'};
      }
    }
    $output_data_row{$genotypeid}->{$traitname} = $avg;
  }

  my @output_data_aref = values %output_data_row;

  my $field_order_href = $custom_format eq '1' ? { 'GenotypeId' => 0, 'GenotypeName' => 1 } : { 'TrialId' => 0, 'TrialName' => 1, 'SiteName' => 2, 'GenotypeId' => 3, 'GenotypeName' => 4 };

  $sql    = "SELECT DISTINCT trialtrait.TraitId, trait.TraitName ";
  $sql   .= "FROM trialtrait ";
  $sql   .= "LEFT JOIN trait ON trialtrait.TraitId = trait.TraitId ";
  $sql   .= "LEFT JOIN samplemeasurement ON trialtrait.TraitId = samplemeasurement.TraitId ";
  $sql   .= "WHERE TrialId IN ($trial_id) AND SampleTypeId IN ($sample_type_id) ";
  $sql   .= "ORDER BY TraitId";

  my $sth_trait_data = $dbh->prepare($sql);
  $sth_trait_data->execute();

  my $trait_aref = $sth_trait_data->fetchall_arrayref({});

  if ($sth_trait_data->err()) {
    my $err_msg = "Get trialtrait failed.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$trait_aref}) == 0) {
    my $err_msg = "No trial trait attached to Trial ($trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $count_field_href = scalar(keys %{$field_order_href});

  for my $trait_rec (@{$trait_aref}) {
    my $trialtraitname = $trait_rec->{'TraitName'};
    $field_order_href->{$trialtraitname} = $count_field_href;
    $count_field_href++;
  }

  my $md5               = md5_hex($sql);
  my $username          = $self->authen->username();
  my $doc_root          = $ENV{'DOCUMENT_ROOT'};
  my $export_data_path  = "${doc_root}/data/$username";
  my $filename          = "export_dkdata_${trial_id}_$md5";
  my $csv_file          = "${export_data_path}/${filename}.csv";

  if (!(-e $export_data_path)) {
    mkdir($export_data_path);
  }

  arrayref2csvfile($csv_file, $field_order_href, \@output_data_aref);

  my $url = reconstruct_server_url();

  my $output_file_aref = [{ 'csv' => "$url/data/$username/${filename}.csv" }];

  $data_for_postrun_href->{'Error'} = 0;
  $data_for_postrun_href->{'Data'}  = {'OutputFile' => $output_file_aref};

  return $data_for_postrun_href;
};

sub get_genotypedata_runmode {

=pod get_genotypedata_HELP_START
{
"OperationName": "List summarised genotype data",
"Description": "List summarised sample measurements based on genotypes.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><StatInfo ServerElapsedTime='0.444' Unit='second' /><RecordMeta TagName='GenotypeData' /><GenotypeData SpecimenId='500' TraitUnitName='kg' GenotypeId='111' TrialUnitId='111' GenotypeName='Genotype_111' AVG_TraitValue='2.23' SpecimenName='Specimen_111' TrialName='Trial_111' TrialId='3' TraitId='111' SiteName='Site_111' TraitName='Trait_111'/></DATA>",
"SuccessMessageJSON": "{'StatInfo' : [{'Unit' : 'second', 'ServerElapsedTime' : '0.006'}],'RecordMeta' : [{'TagName' : 'GenotypeData'}],'GenotypeData' : [{ 'SpecimenId':'500', 'TraitUnitName':'kg', 'GenotypeId':'111', 'TrialUnitId':'111', 'GenotypeName':'Genotype_111', 'AVG_TraitValue':'2.23', 'SpecimenName':'Specimen_111', 'TrialName':'Trial_111', 'TrialId':'3', 'TraitId':'111', 'SiteName':'Site_111', 'TraitName':'Trait_111'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Genotype Id"}],
"HTTPParameter": [{"Required": 0, "Name": "Filtering", "Description": "Filtering parameter string consisting of filtering expressions which are separated by ampersand (&) which needs to be encoded if HTTP GET method is used. Each filtering expression is composed of a database field name, a filtering operator and the filtering value."}, {"Required": 0, "Name": "FieldList", "Description": "Comma separated value of wanted fields."}, {"Required": 0, "Name": "Sorting", "Description": "Comma separated value of SQL sorting phrases."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self    = shift;
  my $geno_id = $self->param('id');
  my $query         = $self->query();

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str      = permission_phrase($group_id, 0, $gadmin_status, 'genotype');

  my $geno_perm_sql = "SELECT $perm_str as UltimatePerm ";
  $geno_perm_sql   .= "FROM genotype ";
  $geno_perm_sql   .= "WHERE GenotypeId=?";

  my ($r_geno_perm_err, $geno_perm) = read_cell($dbh, $geno_perm_sql, [$geno_id]);

  if (length($geno_perm) == 0) {

    my $err_msg = "Genotype ($geno_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }
  elsif ( ($geno_perm & $READ_PERM) != $READ_PERM ) {

    my $err_msg = "Permission denied: genotype ($geno_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  #1 for detailed and 0 for summarised (i.e averaged across trials)
  my $out_put_format = 0;

  if (defined $query->param('CustomFormat')) {
    $out_put_format = $query->param('CustomFormat');
  }

  #Summarised format
  my $sql = "SELECT trial.TrialId, trial.TrialName, site.SiteName, genotype.GenotypeId, genotype.GenotypeName, specimen.SpecimenId, specimen.SpecimenName, generalunit.UnitName as TraitUnitName, ";

  if ($out_put_format == 1) {
    $sql .= "trialunit.TrialUnitBarcode, samplemeasurement.TraitValue as TraitValue, samplemeasurement.InstanceNumber, samplemeasurement.MeasureDateTime, ";
  }
  else {
    $sql .= "AVG(samplemeasurement.TraitValue) as AVG_TraitValue, ";
  }

  $sql   .= "samplemeasurement.TrialUnitId, trait.TraitId, trait.TraitName ";
  $sql   .= "FROM samplemeasurement ";
  $sql   .= "LEFT JOIN trait ON samplemeasurement.TraitId=trait.TraitId ";
  $sql   .= "LEFT JOIN trialunit ON samplemeasurement.TrialUnitId=trialunit.TrialUnitId ";
  $sql   .= "LEFT JOIN trial ON trialunit.TrialId=trial.TrialId ";
  $sql   .= "LEFT JOIN trialunitspecimen ON trialunit.TrialUnitId=trialunitspecimen.TrialUnitId ";
  $sql   .= "LEFT JOIN site ON trial.SiteId=site.SiteId ";
  $sql   .= "LEFT JOIN specimen ON trialunitspecimen.SpecimenId=specimen.SpecimenId ";
  $sql   .= "LEFT JOIN genotypespecimen ON specimen.SpecimenId=genotypespecimen.SpecimenId ";
  $sql   .= "LEFT JOIN genotype ON genotypespecimen.GenotypeId=genotype.GenotypeId ";
  $sql   .= "LEFT JOIN generalunit on trait.UnitId = generalunit.UnitId ";
  $sql   .= "WHERE genotype.GenotypeId IN ($geno_id) ";

  if ($out_put_format == 1) {

    $sql   .= "GROUP BY trialunit.TrialUnitId, trait.TraitId, genotype.GenotypeId ";
    $sql   .= "ORDER BY samplemeasurement.TrialUnitId";

  }
  else {
    $sql   .= "GROUP BY trial.TrialId, trait.TraitId, genotype.GenotypeId ";
    $sql   .= "ORDER BY samplemeasurement.TrialUnitId";
  }

  

  $self->logger->debug("SQL: $sql");

  my $sth_pheno_data = $dbh->prepare($sql);
  $sth_pheno_data->execute();
  
  my $detailed_data_aref = $sth_pheno_data->fetchall_arrayref({});

  if ($sth_pheno_data->err()) {
    my $err_msg = "Get phenotypic data from genotype failed.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$detailed_data_aref}) == 0) {
    my $err_msg = "No data attached to Genotype ($geno_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $pheno_data_aref = $detailed_data_aref;

  #Summarised format

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'GenotypeData'   => $pheno_data_aref,
                                           'RecordMeta' => [{'TagName' => 'GenotypeData'}],
  };

  return $data_for_postrun_href;
};




1;
