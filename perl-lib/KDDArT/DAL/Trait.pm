#$Id: Trait.pm 1016 2015-10-08 06:06:28Z puthick $
#$Author: puthick $

# Copyright (c) 2015, Diversity Arrays Technology, All rights reserved.

# COPYRIGHT AND LICENSE
# 
# Copyright (C) 2014 by Diversity Arrays Technology Pty Ltd
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# Author    : Puthick Hok
# Version   : 2.3.0 build 1040

package KDDArT::DAL::Trait;

use strict;
use warnings;

BEGIN {
  use File::Spec;

  my ($volume, $current_dir, $file) = File::Spec->splitpath(__FILE__);

  $main::kddart_base_dir = "${current_dir}../../..";
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

sub setup {

  my $self = shift;

  CGI::Session->name("KDDArT_DAL_SESSID");

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
      );
  __PACKAGE__->authen->check_gadmin_runmodes('add_treatment_gadmin',
                                             'update_treatment_gadmin',
                                             'del_trait_gadmin',
                                             'del_treatment_gadmin',
      );
  __PACKAGE__->authen->check_sign_upload_runmodes('import_samplemeasurement_csv',
                                                  'import_datakapture_data_csv',
      );

  $self->run_modes(
    'add_treatment_gadmin'             => 'add_treatment_runmode',
    'add_trait'                        => 'add_trait_runmode',
    'import_samplemeasurement_csv'     => 'import_samplemeasurement_csv_runmode',
    'get_treatment'                    => 'get_treatment_runmode',
    'update_treatment_gadmin'          => 'update_treatment_runmode',
    'list_trait'                       => 'list_trait_runmode',
    'get_trait'                        => 'get_trait_runmode',
    'update_trait'                     => 'update_trait_runmode',
    'add_trait_alias'                  => 'add_trait_alias_runmode',
    'remove_trait_alias'               => 'remove_trait_alias_runmode',
    'update_trait_alias'               => 'update_trait_alias_runmode',
    'list_trait_alias'                 => 'list_trait_alias_runmode',
    'export_samplemeasurement_csv'     => 'export_samplemeasurement_csv_runmode',
    'list_trait_advanced'              => 'list_trait_advanced_runmode',
    'list_treatment_advanced'          => 'list_treatment_advanced_runmode',
    'del_trait_gadmin'                 => 'del_trait_runmode',
    'del_treatment_gadmin'             => 'del_treatment_runmode',
    'export_datakapture_template'      => 'export_datakapture_template_runmode',
    'import_datakapture_data_csv'      => 'import_datakapture_data_csv_runmode',
    'export_datakapture_data'          => 'export_datakapture_data_runmode',
    'list_instancenumber'              => 'list_instancenumber_runmode',
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

  $self->authen->config(LOGIN_URL => '');
  $self->session_config(
          CGI_SESSION_OPTIONS => [ "driver:File", $self->query, {Directory=>$SESSION_STORAGE_PATH} ],
      );
}

sub add_treatment_runmode {

=pod add_treatment_gadmin_HELP_START
{
"OperationName" : "Add treatment",
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

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='treatmentfactor'";

  my $dbh_k_read = connect_kdb_read();
  my $vcol_data = $dbh_k_read->selectall_hashref($sql, 'FactorId');

  my $vcol_param_data = {};
  my $vcol_len_info   = {};
  my $vcol_param_data_maxlen = {};
  for my $vcol_id (keys(%{$vcol_data})) {

    my $vcol_param_name = "VCol_${vcol_id}";
    my $vcol_value      = $query->param($vcol_param_name);
    if ($vcol_data->{$vcol_id}->{'CanFactorHaveNull'} != 1) {

      $vcol_param_data->{$vcol_param_name} = $vcol_value;
    }
    $vcol_len_info->{$vcol_param_name} = $vcol_data->{$vcol_id}->{'FactorValueMaxLength'};
    $vcol_param_data_maxlen->{$vcol_param_name} = $vcol_value;
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

  if (record_existence($dbh_k_read, 'treatment', 'TreatmentText', $treatment_text)) {

    my $err_msg = "TreatmentText ($treatment_text): already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TreatmentText' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

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
"OperationName" : "Update treatment",
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

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='treatmentfactor'";

  my $vcol_data = $dbh_k_read->selectall_hashref($sql, 'FactorId');

  my $vcol_param_data = {};
  my $vcol_len_info   = {};
  my $vcol_param_data_maxlen = {};
  for my $vcol_id (keys(%{$vcol_data})) {

    my $vcol_param_name = "VCol_${vcol_id}";
    my $vcol_value      = $query->param($vcol_param_name);
    if ($vcol_data->{$vcol_id}->{'CanFactorHaveNull'} != 1) {

      $vcol_param_data->{$vcol_param_name} = $vcol_value;
    }
    $vcol_len_info->{$vcol_param_name} = $vcol_data->{$vcol_id}->{'FactorValueMaxLength'};
    $vcol_param_data_maxlen->{$vcol_param_name} = $vcol_value;
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
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TreatmentText' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

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

  for my $vcol_id (keys(%{$vcol_data})) {

    if (defined $query->param('VCol_' . "$vcol_id")) {

      my $factor_value = $query->param('VCol_' . "$vcol_id");

      $sql  = 'SELECT Count(*) ';
      $sql .= 'FROM treatmentfactor ';
      $sql .= 'WHERE TreatmentId=? AND FactorId=?';

      my ($read_err, $count) = read_cell($dbh_k_write, $sql, [$treatment_id, $vcol_id]);

      if (length($factor_value) > 0) {

        if ($count > 0) {
        
          $sql  = 'UPDATE treatmentfactor SET ';
          $sql .= 'FactorValue=? ';
          $sql .= 'WHERE TreatmentId=? AND FactorId=?';
          my $factor_sth = $dbh_k_write->prepare($sql);
          $factor_sth->execute($factor_value, $treatment_id, $vcol_id);
          
          if ($dbh_k_write->err()) {
        
            $data_for_postrun_href->{'Error'} = 1;
            $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

            return $data_for_postrun_href;
          }
          
          $factor_sth->finish();
        }
        else {

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
      else {

        if ($count > 0) {

          $sql  = 'DELETE FROM treatmentfactor ';
          $sql .= 'WHERE TreatmentId=? AND FactorId=?';

          my $factor_sth = $dbh_k_write->prepare($sql);
          $factor_sth->execute($treatment_id, $vcol_id);
      
          if ($dbh_k_write->err()) {
        
            $data_for_postrun_href->{'Error'} = 1;
            $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

            return $data_for_postrun_href;
          }
          $factor_sth->finish();
        }
      }
    }
  }

  $dbh_k_write->disconnect();

  my $info_msg_aref = [{'Message' => "Treatment ($treatment_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub add_trait_runmode {

=pod add_trait_HELP_START
{
"OperationName" : "Add trait",
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
  my $trait_unit             = $query->param('UnitId');
  my $trait_used_in_analysis = $query->param('IsTraitUsedForAnalysis');
  my $trait_val_rule         = $query->param('TraitValRule');
  my $trait_invalid_msg      = $query->param('TraitValRuleErrMsg');
  my $access_group           = $query->param('AccessGroupId');
  my $own_perm               = $query->param('OwnGroupPerm');
  my $access_perm            = $query->param('AccessGroupPerm');
  my $other_perm             = $query->param('OtherPerm');

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
  $sql   .= 'UnitId=?, ';
  $sql   .= 'IsTraitUsedForAnalysis=?, ';
  $sql   .= 'TraitValRule=?, ';
  $sql   .= 'TraitValRuleErrMsg=?, ';
  $sql   .= 'OwnGroupId=?, ';
  $sql   .= 'AccessGroupId=?, ';
  $sql   .= 'OwnGroupPerm=?, ';
  $sql   .= 'AccessGroupPerm=?, ';
  $sql   .= 'OtherPerm=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($trait_group_type, $trait_name, $trait_caption, $trait_description, $trait_data_type,
                $trait_val_maxlen, $trait_unit, $trait_used_in_analysis, $trait_val_rule, $trait_invalid_msg,
                $group_id, $access_group, $own_perm, $access_perm, $other_perm);

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
"OperationName" : "Import sample measurements",
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
"HTTPParameter": [{"Required": 1, "Name": "TrialUnitId", "Description": "Column number counting from zero for TrialUnitId column in the upload CSV file"}, {"Required": 1, "Name": "SampleTypeId", "Description": "Column number counting from zero for SampleTypeId column in the upload CSV file"}, {"Required": 1, "Name": "TraitId", "Description": "Column number counting from zero for TraitId column in the upload CSV file"}, {"Required": 1, "Name": "OperatorId", "Description": "Column number counting from zero for OperatorId column for the upload CSV file"}, {"Required": 1, "Name": "MeasureDateTime", "Description": "Column number counting from zero for MeasureDateTime column in the upload CSV file"}, {"Required": 1, "Name": "InstanceNumber", "Description": "Column number counting from zero for InstanceNumber column in the upload CSV file"}, {"Required": 1, "Name": "TraitValue", "Description": "Column number counting from zero for TraitValue column in the upload CSV file"}],
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

  my ($col_def_err, $col_def_err_href) = check_col_def_href( { 'TrialUnitId'     => $TrialUnitId_col,
                                                               'SampleTypeId'    => $SampleTypeId_col,
                                                               'TraitId'         => $TraitId_col,
                                                               'MeasureDateTime' => $MeasureDateTime_col,
                                                               'InstanceNumber'  => $InstanceNumber_col,
                                                               'TraitValue'      => $TraitValue_col,
                                                             },
                                                             $num_of_col
      );

  if ($col_def_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$col_def_err_href]};

    return $data_for_postrun_href;
  }

  my $matched_col = {};

  $matched_col->{$TrialUnitId_col}     = 'TrialUnitId';
  $matched_col->{$SampleTypeId_col}    = 'SampleTypeId';
  $matched_col->{$TraitId_col}         = 'TraitId';
  $matched_col->{$MeasureDateTime_col} = 'MeasureDateTime';
  $matched_col->{$InstanceNumber_col}  = 'InstanceNumber';
  $matched_col->{$TraitValue_col}      = 'TraitValue';

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
  $data_for_postrun_href = $self->insert_samplemeasurement_data($dbh_write,
                                                                $data_aref,
                                                                $check_non_trait_field,
                                                                $validate_trait_value
      );

  $dbh_write->disconnect();


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

      my $chk_table_aref = [{'TableName' => 'trialunit', 'FieldName' => 'TreatmentId'}];

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
"OperationName" : "Get treatment",
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

sub list_trait_runmode {

  my $self  = shift;

  my $data_for_postrun_href = {};

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status);

  my $sql = "SELECT *, $perm_str AS UltimatePerm ";
  $sql   .= 'FROM trait ';
  $sql   .= "WHERE (($perm_str) & $READ_PERM) = $READ_PERM ";
  $sql   .= 'ORDER BY trait.TraitId DESC';

  $self->logger->debug("SQL with VCol: $sql");

  my ($read_trait_err, $read_trait_msg, $trait_data) = $self->list_trait(1, $sql);

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

sub get_trait_runmode {

=pod get_trait_HELP_START
{
"OperationName" : "Get trait",
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

  my $sql = "SELECT *, generalunit.UnitName AS UnitName, $perm_str AS UltimatePerm ";
  $sql   .= 'FROM trait ';
  $sql   .= 'LEFT JOIN generalunit ON trait.UnitId = generalunit.UnitId ';
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
"OperationName" : "Update trait",
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

  my ($correct_validation_rule, $val_msg) = is_correct_validation_rule($trait_val_rule);

  if (!$correct_validation_rule) {

    my $err_msg = " $val_msg";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TraitValRule' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $db_trait_name = read_cell_value($dbh_k_read, 'trait', 'TraitName', 'TraitId', $trait_id);

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

  my $trait_group_type_id = read_cell_value($dbh_k_read, 'trait', 'TraitGroupTypeId', 'TraitId', $trait_id);

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

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $sql = '';

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
  $sql   .= 'TraitValRuleErrMsg=? ';
  $sql   .= 'WHERE TraitId=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($trait_name, $trait_group_type_id, $trait_caption, $trait_description, $trait_data_type,
                $trait_val_maxlen, $trait_unit, $trait_used_in_analysis, $trait_val_rule, $trait_invalid_msg,
                $trait_id);

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
"OperationName" : "Add trait alias",
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
"OperationName" : "Remove trait alias",
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
"OperationName" : "Update trait alias",
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

  my $trait_alias_name = $query->param('TraitAliasName');
  
  my $trait_alias_caption = read_cell_value($dbh_write, 'traitalias', 'TraitAliasCaption',
                                            'TraitAliasId', $trait_alias_id);

  if (defined $query->param('TraitAliasCaption')) {

    $trait_alias_caption = $query->param('TraitAlaisCaption');
  }

  my $trait_alias_description = read_cell_value($dbh_write, 'traitalias', 'TraitAliasDescription',
                                                'TraitAliasId', $trait_alias_id);

  if (defined $query->param('TraitAliasDescription')) {

    $trait_alias_description = $query->param('TraitAliasDescription');
  }

  my $trait_alias_value_rule_err_msg = read_cell_value($dbh_write, 'traitalias', 'TraitAliasValueRuleErrMsg',
                                                       'TraitAliasId', $trait_alias_id);

  if (defined $query->param('TraitAliasValueRuleErrMsg')) {

    $trait_alias_value_rule_err_msg = $query->param('TraitAliasValueRuleErrMsg');
  }

  my $trait_lang = read_cell_value($dbh_write, 'traitalias', 'TraitLang',
                                   'TraitAliasId', $trait_alias_id);

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
"OperationName" : "List trait aliases",
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
"OperationName" : "Export sample measurements",
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
"HTTPParameter": [{"Required": 0, "Name": "TrialUnitIdCSV", "Description": "Filtering parameter for TrialUnitId. The value is comma separated value of TrialUnitId."}, {"Required": 0, "Name": "SampleTypeIdCSV", "Description": "Filtering parameter for SampleTypeId. The value is comma separated value of SampleTypeId."}, {"Required": 0, "Name": "TraitIdCSV", "Description": "Filtering parameter for TraitId. The value is comma separated value of TraitId."}, {"Required": 0, "Name": "OperatorIdCSV", "Description": "Filtering parameter for OperatorId. The value is comma separated value of OperatorId."}, {"Required": 0, "Name": "MeasureDateTimeFrom", "Description": "Filtering parameter for MeasureDateTime. The value is correctly formatted date/time from which the sample measurement was recorded."}, {"Required": 0, "Name": "MeasureDateTimeTo", "Description": "Filtering parameter for MeasureDateTime. The value is correctly formatted date/time to which the sample measurement was recorded."}, {"Required": 0, "Name": "TrialIdCSV", "Description": "Filtering parameter for TrialId. The value is comma separated value of TrialId. This filtering parameter could be overridden by TrialUnitIdCSV if it is provided because filtering on TrialUnitId is at a lower level."}],
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

  my $sql = 'SELECT samplemeasurement.* ';
  $sql   .= 'FROM samplemeasurement LEFT JOIN trialunit ';
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

  my @field_headers;
  for (my $i = 0; $i < $sth->{NUM_OF_FIELDS}; $i++) {

    push(@field_headers, $sth->{NAME}->[$i]);
  }
  
  print $smeasure_csv_fh '#' . join(',', @field_headers) . "\n";

  while ( my $row_aref = $sth->fetchrow_arrayref() ) {

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
"OperationName" : "List traits",
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
  for my $fd_name (@{$final_field_list}) {

    $field_lookup->{$fd_name} = 1;
  }

  my $other_join = '';
  if ($field_lookup->{'TraitUnit'}) {

    push(@{$final_field_list}, 'itemunit.ItemUnitName AS TraitUnitName');
    $other_join = ' LEFT JOIN itemunit ON trait.TraitUnit = itemunit.ItemUnitId ';
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
"OperationName" : "List treatments",
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
"OperationName" : "Delete trait",
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
"OperationName" : "Delete treatment",
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

  my $treatment_used = record_existence($dbh_k_read, 'trialunit', 'TreatmentId', $treatment_id);

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

    return $self->error_message('Unexpected error.');
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
"OperationName" : "Export trial data template",
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
"OperationName" : "Import trial data",
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

      $db_trial_unit = $trialunit_lookup->{$dk_file_unitposition_txt};
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
  $bulk_sql   .= '(TrialUnitId,SampleTypeId,TraitId,OperatorId,MeasureDateTime,InstanceNumber,TraitValue) ';
  $bulk_sql   .= 'VALUES ';

  my $sql;
  my $sth;

  my $row_counter = 1;
  for my $data_row (@{$data_aref}) {

    my $effective_user_id = $user_id;
    my $trialunit_id      = $data_row->{'TrialUnitId'};
    my $samp_type_id      = $data_row->{'SampleTypeId'};
    my $trait_id          = $data_row->{'TraitId'};

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

        my $operator_exist = record_existence($dbh_write, 'systemuser', 'UserId', $operator_id);

        if (!$operator_exist) {

          my $err_msg = "Row ($row_counter): Operator ($operator_id) not a valid user ID.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }

        $effective_user_id = $operator_id;
      }

      $sql = 'SELECT TrialId FROM trialunit WHERE TrialUnitId=?';
      $sth = $dbh_write->prepare($sql);
      $sth->execute($trialunit_id);

      my $trial_id = -1;
      $sth->bind_col(1, \$trial_id);
      $sth->fetch();

      if ($trial_id == -1) {

        my $err_msg = "Row ($row_counter): TrialUnit ($trialunit_id) does not exist.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }

      $sql = 'SELECT TrialTraitId FROM trialtrait WHERE TrialId=? AND TraitId=?';
      $sth = $dbh_write->prepare($sql);
      $sth->execute($trial_id, $trait_id);

      my $trial_trait_id = -1;
      $sth->bind_col(1, \$trial_trait_id);
      $sth->fetch();

      if ($trial_trait_id == -1) {

        my $err_msg = "Row ($row_counter): Trait ($trait_id) is not attached to Trial ($trial_id).";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }

      my ($is_trial_perm_ok, $trouble_trial_id_aref) = check_permission($dbh_write, 'trial', 'TrialId',
                                                                        [$trial_id], $group_id, $gadmin_status,
                                                                        $LINK_PERM);

      if (!$is_trial_perm_ok) {

        my $perm_err_msg = "Row ($row_counter): Permission denied, Group ($group_id) and Trial ($trial_id).";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $perm_err_msg}]};

        return $data_for_postrun_href;
      }

      my $samp_type_exist = type_existence($dbh_write, 'sample', $samp_type_id);

      if (!$samp_type_exist) {

        my $err_msg = "Row ($row_counter): SampleType ($samp_type_id) does not exist.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }

      $sql = "SELECT TraitValRule, $perm_str As UltimatePerm FROM trait where TraitId=?";
      $sth = $dbh_write->prepare($sql);
      $sth->execute($trait_id);

      my $trait_val_rule = '';
      my $trait_perm     = 0;

      $sth->bind_col(1, \$trait_val_rule);
      $sth->bind_col(2, \$trait_perm);
      $sth->fetch();
      $sth->finish();

      if (length($trait_val_rule) == 0) {

        my $err_msg = "Row ($row_counter): Trait ($trait_id) not found.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
      else {

        if ( ($trait_perm & $LINK_PERM) != $LINK_PERM ) {

          my $perm_err_msg = "Row ($row_counter): Permission denied, Group ($group_id) and Trait ($trait_id).";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $perm_err_msg}]};

          return $data_for_postrun_href;
        }
      }
    }

    if (length($data_row->{'OperatorId'}) > 0) {

      $effective_user_id = $data_row->{'OperatorId'};
    }

    my $trait_val = $data_row->{'TraitValue'};

    if ($validate_trait) {

      my ($validate_trait_val_err, $validation_msg) = validate_trait_db($dbh_write, $trait_id, $trait_val);

      if ($validate_trait_val_err) {

        $self->logger->debug("Validation message: $validation_msg");
        my $err_msg = "Row ($row_counter): trait value ($trait_val) not valid for trait ($trait_id).";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
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

    $bulk_sql .= "($trialunit_id,$samp_type_id,$trait_id,$effective_user_id,";
    $bulk_sql .= "'$measure_dt',$instance_num,'$trait_val'),";

    $row_counter += 1;
  }

  chop($bulk_sql);      # remove excessive comma

  $self->logger->debug("Bulk SQL: $bulk_sql");

  my $nrows_inserted = $dbh_write->do($bulk_sql);

  if ($dbh_write->err()) {

    $self->logger->debug("Db err code: " . $dbh_write->err());

    if ($dbh_write->err() == 1062) {

      my $err_str = $dbh_write->errstr();

      if ( $err_str =~ /'(\d+)\-(\d+)\-(\d+)\-(\d+)\-(\d+\-\d+\-\d+ \d+\:\d+\:\d+)\-(\d+)'/ ) {

        my $dup_trialunit_id = $1;
        my $dup_samp_type_id = $2;
        my $dup_trait_id     = $3;
        my $dup_operator_id  = $4;
        my $dup_measure_dt   = $5;
        my $dup_inst_num     = $6;

        my $dup_msg = "(TrialUnitId:${dup_trialunit_id},SampleTypeId:${dup_samp_type_id},TraitId:${dup_trait_id},";
        $dup_msg   .= "OperatorId:${dup_operator_id},MeasureDateTime:${dup_measure_dt},InstanceNumber:${dup_inst_num}) ";
        $dup_msg   .= 'record already exists.';

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $dup_msg}]};

        return $data_for_postrun_href;
      }
      elsif ($err_str =~ /'(\d+)\-(\d+)\-(\d+)\-(\d+\-\d+\-\d+ \d+\:\d+\:\d+)\-(\d+)\-(\d+)'/) {

        my $dup_trialunit_id = $1;
        my $dup_samp_type_id = $6;
        my $dup_trait_id     = $2;
        my $dup_operator_id  = $3;
        my $dup_measure_dt   = $4;
        my $dup_inst_num     = $5;

        my $dup_msg = "(TrialUnitId:${dup_trialunit_id},SampleTypeId:${dup_samp_type_id},TraitId:${dup_trait_id},";
        $dup_msg   .= "OperatorId:${dup_operator_id},MeasureDateTime:${dup_measure_dt},InstanceNumber:${dup_inst_num}) ";
        $dup_msg   .= 'record already exists.';

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $dup_msg}]};

        return $data_for_postrun_href;
      }
      else {

        $err_str =~ /Duplicate entry '(.+)'/;
        my $err_msg = "Duplicate Entry: $1";

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
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
"OperationName" : "Export trial data",
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

    if ( !(defined $trialunit2specimen_lookup->{$trialunit_id}) ) { next; }

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

    for my $trial_data_field (keys(%{$trial_data_rec})) {

      $output_data_row->{$trial_data_field}  = $trial_data_rec->{$trial_data_field};
    }

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
"OperationName" : "List instance number",
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

sub logger {

  my $self = shift;
  return $self->{logger};
}

1;
