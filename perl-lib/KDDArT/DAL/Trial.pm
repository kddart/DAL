#$Id$
#$Author$

# Copyright (c) 2024, Diversity Arrays Technology, All rights reserved.

# Author    : Puthick Hok
# Created   : 02/06/2010
# Modified  :
# Purpose   :
#
#

package KDDArT::DAL::Trial;

use strict;
use warnings;

use Digest::MD5 qw(md5 md5_hex md5_base64);

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
use Data::Dumper;

sub setup {

  my $self = shift;

  CGI::Session->name($COOKIE_NAME);

  __PACKAGE__->authen->init_config_parameters();
  __PACKAGE__->authen->check_login_runmodes(':all');
  __PACKAGE__->authen->check_content_type_runmodes(':all');
  __PACKAGE__->authen->check_rand_runmodes('add_site_gadmin',
                                           'add_designtype_gadmin',
                                           'add_trial',
                                           'add_trial_unit',
                                           'update_site_gadmin',
                                           'update_site_geography_gadmin',
                                           'update_designtype_gadmin',
                                           'update_trial',
                                           'update_trial_geography',
                                           'update_trial_unit',
                                           'update_trial_unit_geography',
                                           'add_trial_unit_specimen',
                                           'delete_trial_unit_specimen',
                                           'update_trial_unit_specimen',
                                           'del_designtype_gadmin',
                                           'del_site_gadmin',
                                           'del_trial_gadmin',
                                           'del_trial_unit_gadmin',
                                           'del_trial_crossing_gadmin',
                                           'add_trial_trait',
                                           'update_trial_trait',
                                           'remove_trial_trait',
                                           'add_trial_unit_bulk',
                                           'add_project_gadmin',
                                           'update_project_gadmin',
                                           'del_project_gadmin',
                                           'add_trial_dimension',
                                           'update_trial_dimension',
                                           'del_trial_dimension_gadmin',
                                           'add_trial_workflow',
                                           'update_trial_workflow',
                                           'del_trial_workflow_gadmin',
                                           'add_trialgroup',
                                           'update_trialgroup',
                                           'del_trialgroup',
                                           'add_trial2trialgroup',
                                           'remove_trial_from_trialgroup',
                                           'import_trialunitkeyword_csv',
                                           'add_trial_unit_keyword',
                                           'remove_trial_unit_keyword',
                                           'import_crossing_csv',
                                           'update_trial_unit_bulk',
                                           'add_crossing',
                                           'update_crossing',
      );
  __PACKAGE__->authen->count_session_request_runmodes(':all');
  __PACKAGE__->authen->check_signature_runmodes('add_designtype_gadmin',
                                                'update_site_gadmin',
                                                'update_designtype_gadmin',
                                                'update_trial',
                                                'update_trial_unit',
                                                'add_trial_unit_specimen',
                                                'delete_trial_unit_specimen',
                                                'update_trial_unit_specimen',
                                                'del_designtype_gadmin',
                                                'del_site_gadmin',
                                                'del_trial_gadmin',
                                                'del_trial_unit_gadmin',
                                                'del_trial_crossing_gadmin',
                                                'add_site_gadmin',
                                                'add_trial_trait',
                                                'update_trial_trait',
                                                'remove_trial_trait',
                                                'add_trial',
                                                'add_project_gadmin',
                                                'update_project_gadmin',
                                                'del_project_gadmin',
                                                'update_site_geography_gadmin',
                                                'add_trial_dimension',
                                                'update_trial_dimension',
                                                'del_trial_dimension_gadmin',
                                                'add_trial_workflow',
                                                'update_trial_workflow',
                                                'del_trial_workflow_gadmin',
                                                'update_trialgroup',
                                                'del_trialgroup',
                                                'remove_trial_from_trialgroup',
                                                'add_trial_unit_keyword',
                                                'remove_trial_unit_keyword',
                                                'add_crossing',
                                                'update_crossing',
      );

  __PACKAGE__->authen->check_gadmin_runmodes('add_designtype_gadmin',
                                             'update_site_geography_gadmin',
                                             'update_designtype_gadmin',
                                             'del_designtype_gadmin',
                                             'del_site_gadmin',
                                             'del_trial_gadmin',
                                             'del_trial_unit_gadmin',
                                             'del_trial_crossing_gadmin',
                                             'add_project_gadmin',
                                             'update_project_gadmin',
                                             'del_project_gadmin',
                                             'del_trial_dimension_gadmin',
                                             'del_trial_workflow_gadmin',
      );

  __PACKAGE__->authen->check_sign_upload_runmodes('add_trial_unit',
                                                  'add_trial_unit_bulk',
                                                  'add_trialgroup',
                                                  'add_trial2trialgroup',
                                                  'import_trialunitkeyword_csv',
                                                  'import_crossing_csv',
                                                  'update_trial_unit_bulk',
      );

  $self->run_modes(
    'add_site_gadmin'                        => 'add_site_runmode',
    'add_designtype_gadmin'                  => 'add_designtype_runmode',
    'add_trial'                              => 'add_trial_runmode',
    'add_trial_unit'                         => 'add_trial_unit_runmode',
    'list_site_advanced'                     => 'list_site_advanced_runmode',
    'get_site'                               => 'get_site_full_runmode',
    'update_site_gadmin'                     => 'update_site_runmode',
    'update_site_geography_gadmin'           => 'update_site_geography_runmode',
    'list_designtype'                        => 'list_designtype_runmode',
    'get_designtype'                         => 'get_designtype_runmode',
    'update_designtype_gadmin'               => 'update_designtype_runmode',
    'list_trial_advanced'                    => 'list_trial_advanced_runmode',
    'get_trial'                              => 'get_trial_runmode',
    'update_trial'                           => 'update_trial_runmode',
    'update_trial_geography'                 => 'update_trial_geography_runmode',
    'get_trial_unit'                         => 'get_trial_unit_runmode',
    'update_trial_unit'                      => 'update_trial_unit_runmode',
    'update_trial_unit_geography'            => 'update_trial_unit_geography_runmode',
    'add_trial_unit_specimen'                => 'add_trial_unit_specimen_runmode',
    'delete_trial_unit_specimen'             => 'delete_trial_unit_specimen_runmode',
    'update_trial_unit_specimen'             => 'update_trial_unit_specimen_runmode',
    'list_trial_unit_advanced'               => 'list_trial_unit_advanced_runmode',
    'list_trial_unit_specimen_advanced'      => 'list_trial_unit_specimen_advanced_runmode',
    'del_designtype_gadmin'                  => 'del_designtype_runmode',
    'del_site_gadmin'                        => 'del_site_runmode',
    'del_trial_gadmin'                       => 'del_trial_runmode',
    'del_trial_unit_gadmin'                  => 'del_trial_unit_runmode',
    'del_trial_crossing_gadmin'              => 'del_trial_crossing_runmode',
    'add_trial_trait'                        => 'add_trial_trait_runmode',
    'list_trial_trait'                       => 'list_trial_trait_runmode',
    'get_trial_trait'                        => 'get_trial_trait_runmode',
    'update_trial_trait'                     => 'update_trial_trait_runmode',
    'remove_trial_trait'                     => 'remove_trial_trait_runmode',
    'add_trial_unit_bulk'                    => 'add_trial_unit_bulk_runmode',
    'update_trial_unit_bulk'                 => 'update_trial_unit_bulk_runmode',
    'add_project_gadmin'                     => 'add_project_runmode',
    'update_project_gadmin'                  => 'update_project_runmode',
    'list_project_advanced'                  => 'list_project_advanced_runmode',
    'get_project'                            => 'get_project_runmode',
    'del_project_gadmin'                     => 'del_project_runmode',
    'get_trial_unit_specimen'                => 'get_trial_unit_specimen_runmode',
    'add_trial_dimension'                    => 'add_trial_dimension_runmode',
    'update_trial_dimension'                 => 'update_trial_dimension_runmode',
    'del_trial_dimension_gadmin'             => 'del_trial_dimension_runmode',
    'list_trial_dimension'                   => 'list_trial_dimension_runmode',
    'get_trial_dimension'                    => 'get_trial_dimension_runmode',
    'add_trial_workflow'                     => 'add_trial_workflow_runmode',
    'update_trial_workflow'                  => 'update_trial_workflow_runmode',
    'list_trial_workflow'                    => 'list_trial_workflow_runmode',
    'get_trial_workflow'                     => 'get_trial_workflow_runmode',
    'del_trial_workflow_gadmin'              => 'del_trial_workflow_runmode',
    'add_trialgroup'                         => 'add_trialgroup_runmode',
    'update_trialgroup'                      => 'update_trialgroup_runmode',
    'list_trialgroup_advanced'               => 'list_trialgroup_advanced_runmode',
    'get_trialgroup'                         => 'get_trialgroup_runmode',
    'del_trialgroup'                         => 'del_trialgroup_runmode',
    'add_trial2trialgroup'                   => 'add_trial2trialgroup_runmode',
    'remove_trial_from_trialgroup'           => 'remove_trial_from_trialgroup_runmode',
    'import_trialunitkeyword_csv'            => 'import_trialunitkeyword_csv_runmode',
    'list_trialunit_keyword_advanced'        => 'list_trialunit_keyword_advanced_runmode',
    'add_trial_unit_keyword'                 => 'add_trial_unit_keyword_runmode',
    'remove_trial_unit_keyword'              => 'remove_trial_unit_keyword_runmode',
    'import_crossing_csv'                    => 'import_crossing_csv_runmode',
    'list_crossing_advanced'                 => 'list_crossing_advanced_runmode',
    'get_crossing'                           => 'get_crossing_runmode',
    'add_crossing'                           => 'add_crossing_runmode',
    'update_crossing'                        => 'update_crossing_runmode',
    'add_trialunit_treatment'                => 'add_trialunit_treatment_runmode',
    'get_trialunit_treatment'                => 'get_trialunit_treatment_runmode',
    'remove_trialunit_treatment'             => 'remove_trialunit_treatment_runmode',
    'update_trialunit_treatment'             => 'update_trialunit_treatment_runmode'
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

sub add_site_runmode {

=pod add_site_gadmin_HELP_START
{
"OperationName": "Add site",
"Description": "Add a new site (breeding station, farm) to the system.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "site",
"KDDArTFactorTable": "sitefactor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='10' ParaName='SiteId' /><Info Message='Site (10) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '9','ParaName' : 'SiteId'}],'Info' : [{'Message' : 'Site (9) has been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error SiteTypeId='SiteType (111) does not exist.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'SiteTypeId' : 'SiteType (111) does not exist.'}]}"}],
"HTTPParameter": [{"Name": "sitelocation", "DataType": "polygon_wkt", "Description": "GIS field defining the polygon geometry object of the site in a standard GIS well-known text.", "Type": "LCol", "Required": "0"},{"Name": "sitelocdt", "DataType": "timestamp", "Description": "DateTime of site location", "Type": "LCol", "Required": "0"},{"Name": "currentloc", "DataType": "tinyint", "Description": "Flag to notify current location", "Type": "LCol", "Required": "0"},{"Name": "description", "DataType": "varchar", "Description": "Description for location", "Type": "LCol", "Required": "0"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};
  my $site_err = 0;
  my $site_err_aref = [];

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'site', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $site_name          = $query->param('SiteName');
  my $sitetype_id        = $query->param('SiteTypeId');
  my $site_acronym       = $query->param('SiteAcronym');
  my $cur_manager_id     = $query->param('CurrentSiteManagerId');
  my $site_location      = '';

  my $dbh_gis_read = connect_gis_read();

  if (defined $query->param('sitelocation')) {

    if (length($query->param('sitelocation')) > 0) {

      $site_location = $query->param('sitelocation');

      my ($missing_err, $missing_href) = check_missing_href( { 'sitelocation' => $site_location } );

      if ($missing_err) {

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

        push(@{$site_err_aref}, $missing_href);
        $site_err = 1;
      }

      my ($is_wkt_err, $wkt_err_href) = is_valid_wkt_href($dbh_gis_read, {'sitelocation' => $site_location},
                                                          ['POLYGON', 'MULTIPOLYGON', 'POINT']);

      if ($is_wkt_err) {

          push(@{$site_err_aref}, $wkt_err_href);
        $site_err = 1;
      }
    }
  }

  $dbh_gis_read->disconnect();

  my $site_sdate         = undef;
  if ($query->param('SiteStartDate')) {

    $site_sdate         = $query->param('SiteStartDate');
    my ($sdate_err, $sdate_href) = check_dt_href( {'SiteStartDate' => $site_sdate} );

    if ($sdate_err) {
      push(@{$site_err_aref}, $sdate_href);
      $site_err = 1;
    }
  }

  my $site_edate         = undef;
  if ($query->param('SiteEndDate')) {

    $site_edate         = $query->param('SiteEndDate');
    my ($edate_err, $edate_href) = check_dt_href( {'SiteEndDate' => $site_edate} );

    if ($edate_err) {

      push(@{$site_err_aref}, $edate_href);
      $site_err = 1;
    }
  }

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength, FactorValidRuleErrMsg, FactorValidRule  ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='sitefactor'";

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
      'CanFactorHaveNull' => $vcol_data->{$vcol_id}->{'CanFactorHaveNull'}
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

  my $sitetype_existence = type_existence($dbh_k_read, 'site', $sitetype_id);

  if (!$sitetype_existence) {

    my $err_msg = "SiteType ($sitetype_id) does not exist.";

    push(@{$site_err_aref}, {'SiteTypeId' => $err_msg});
    $site_err = 1;
  }

  my $cur_manager_existence = record_existence($dbh_k_read, 'contact', 'ContactId', $cur_manager_id);

  if (!$cur_manager_existence) {

    my $err_msg = "CurrentManager ($cur_manager_id) does not exist.";

    push(@{$site_err_aref}, {'SiteTypeId' => $err_msg});
    $site_err = 1;
  }

  $dbh_k_read->disconnect();

  #prevalidate values to be finished in later version

  my ($vcol_error, $vcol_error_aref) = validate_all_factor_input($pre_validate_vcol);

  if ($vcol_error) {
     push(@{$site_err_aref}, @{$vcol_error_aref});
     $site_err = 1;
  }

  if ($site_err != 0) {
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => $site_err_aref};
    return $data_for_postrun_href;
  }

  my $inserted_id = {};
  my $dbh_k_write = connect_kdb_write();

  $sql  = 'INSERT INTO site SET ';
  $sql .= 'SiteName=?, ';
  $sql .= 'SiteTypeId=?, ';
  $sql .= 'SiteAcronym=?, ';
  $sql .= 'CurrentSiteManagerId=?, ';
  $sql .= 'SiteStartDate=?, ';
  $sql .= 'SiteEndDate=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($site_name, $sitetype_id, $site_acronym,
                $cur_manager_id, $site_sdate, $site_edate);

  my $site_id = -1;
  if (!$dbh_k_write->err()) {

    $site_id = $dbh_k_write->last_insert_id(undef, undef, 'site', 'SiteId');
    $self->logger->debug("SiteId: $site_id");
    $inserted_id->{'site'} = ['SiteId', $site_id];
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

      $sql  = 'INSERT INTO sitefactor SET ';
      $sql .= 'SiteId=?, ';
      $sql .= 'FactorId=?, ';
      $sql .= 'FactorValue=?';
      my $factor_sth = $dbh_k_write->prepare($sql);
      $factor_sth->execute($site_id, $vcol_id, $factor_value);

      if ($dbh_k_write->err()) {

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

        return $data_for_postrun_href;
      }

      $inserted_id->{'sitefactor'} = ['SiteId', $site_id];
      $factor_sth->finish();
    }
  }

  if (length($site_location) > 0) {

    my $sub_PGIS_val_builder = sub {
      my $wkt = shift;
      my $st_buffer_val = $POINT2POLYGON_BUFFER4SITE->{$ENV{DOCUMENT_ROOT}};
      if ($wkt =~ /^POINT/i) {
        return "ST_Multi(ST_Buffer(ST_GeomFromText(?, -1), $st_buffer_val, 1))";
      } else {
        return "ST_Multi(ST_GeomFromText(?, -1))";
      }
    };

    my ($err, $err_msg) = append_geography_loc(
                                          "site",
                                          $site_id,
                                          ['POINT', 'POLYGON', 'MULTIPOLYGON'],
                                          $query,
                                          $sub_PGIS_val_builder,
                                          $self->logger,
                                        );

    if ($err) {
      my ($rollback_err, $rollback_msg) = $self->rollback_cleanup($dbh_k_write, $inserted_id);
      if ($rollback_err) {
        $self->logger->debug("Rollback error msg: $rollback_msg");
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};
        return $data_for_postrun_href;
      } else {
        $data_for_postrun_href = $self->_set_error($err_msg);
        return $data_for_postrun_href;
      }
    }
  }

  $dbh_k_write->disconnect();

  my $info_msg_aref  = [{'Message' => "Site ($site_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$site_id", 'ParaName' => 'SiteId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub add_designtype_runmode {

=pod add_designtype_gadmin_HELP_START
{
"OperationName": "Add design type",
"Description": "Add a new trial design type to the system.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "designtype",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='9' ParaName='DesignTypeId' /><Info Message='DesignType (9) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '11','ParaName' : 'DesignTypeId'}],'Info' : [{'Message' : 'DesignType (11) has been added successfully.'}]}",
"ErrorMessageXML": [{"NameAlreadyExists": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error DesignTypeName='DesignTypeName (Traditional): already exists.' /></DATA>"}],
"ErrorMessageJSON": [{"NameAlreadyExists": "{'Error' : [{'DesignTypeName' : 'DesignTypeName (Traditional): already exists.'}]}"}],
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
                                                                                'designtype', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $designtype_name                  = $query->param('DesignTypeName');

  my $design_software                  = '';

  if (defined $query->param('DesignSoftware')) {

    $design_software = $query->param('DesignSoftware');
  }

  my $design_template_file             = '';

  if (defined $query->param('DesignTemplateFile')) {

    $design_template_file = $query->param('DesignTemplateFile');
  }

  my $design_geno_format               = '';

  if (defined $query->param('DesignGenotypeFormat')) {

    $design_geno_format = $query->param('DesignGenotypeFormat');
  }

  my $design_factor_alias_prefix       = '';

  if (defined $query->param('DesignFactorAliasPrefix')) {

    $design_factor_alias_prefix = $query->param('DesignFactorAliasPrefix');
  }

  my $dbh_k_write = connect_kdb_write();

  if (record_existence($dbh_k_write, 'designtype', 'DesignTypeName', $designtype_name)) {

    my $err_msg = "DesignTypeName ($designtype_name): already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'DesignTypeName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'INSERT INTO designtype SET ';
  $sql   .= 'DesignTypeName=?, ';
  $sql   .= 'DesignSoftware=?, ';
  $sql   .= 'DesignTemplateFile=?, ';
  $sql   .= 'DesignGenotypeFormat=?, ';
  $sql   .= 'DesignFactorAliasPrefix=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($designtype_name, $design_software, $design_template_file,
                $design_geno_format, $design_factor_alias_prefix,
      );

  my $designtype_id = -1;
  if (!$dbh_k_write->err()) {

    $designtype_id = $dbh_k_write->last_insert_id(undef, undef, 'designtype', 'DesignTypeId');
  }
  else {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref  = [{'Message' => "DesignType ($designtype_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$designtype_id", 'ParaName' => 'DesignTypeId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub add_trial_runmode {

=pod add_trial_HELP_START
{
"OperationName": "Add trial",
"Description": "Add a new trial (e.g. field or nursery experiment) into the system.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "trial",
"SkippedField": ["OwnGroupId", "TULastUpdateTimeStamp"],
"KDDArTFactorTable": "trialfactor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='8' ParaName='TrialId' /><Info Message='Trial (8) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '9','ParaName' : 'TrialId'}],'Info' : [{'Message' : 'Trial (9) has been added successfully.'}]}",
"ErrorMessageXML": [{"MissingParameter": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error TrialName='TrialName is missing.' /></DATA>"}],
"ErrorMessageJSON": [{"MissingParameter": "{'Error' : [{'TrialName' : 'TrialName is missing.'}]}"}],
"HTTPParameter": [{"Name": "triallocation", "DataType": "polygon_wkt", "Description": "GIS field defining the polygon geometry object of the trial in a standard GIS well-known text.", "Type": "LCol", "Required": "0"},{"Name": "triallocdt", "DataType": "timestamp", "Description": "DateTime of trial location", "Type": "LCol", "Required": "0"},{"Name": "currentloc", "DataType": "tinyint", "Description": "Flag to notify current location", "Type": "LCol", "Required": "0"},{"Name": "description", "DataType": "varchar", "Description": "Description for location", "Type": "LCol", "Required": "0"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};
  my $trial_err = 0;
  my $trial_err_aref = [];

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'OwnGroupId'            => 1,
                    'TULastUpdateTimeStamp' => 1,
                   };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'trial', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $site_id             = $query->param('SiteId');
  my $season_id           = $query->param('SeasonId');
  my $trial_type_id       = $query->param('TrialTypeId');
  my $trial_name          = $query->param('TrialName');
  my $trial_number        = $query->param('TrialNumber');
  my $trial_acronym       = $query->param('TrialAcronym');
  my $design_type_id      = $query->param('DesignTypeId');
  my $trial_manager_id    = $query->param('TrialManagerId');
  my $trial_sdate         = $query->param('TrialStartDate');
  my $access_group        = $query->param('AccessGroupId');
  my $own_perm            = $query->param('OwnGroupPerm');
  my $access_perm         = $query->param('AccessGroupPerm');
  my $other_perm          = $query->param('OtherPerm');

  my $trial_layout        = undef;

  if ($ALLOWDUPLICATETRIALNAME_CFG != 1) {

    my $filtertrialname_sql = "SELECT * FROM trial WHERE TrialName=?";

    my ($filtertrialname_err, $filtertrialname_msg, $filtertrialname_data) = read_data($dbh_read, $filtertrialname_sql, [$trial_name]);

    if ($filtertrialname_err) {

      return ($filtertrialname_err, "$filtertrialname_msg", []);
    }

    for my $row (@{$filtertrialname_data}) {

      my $filtertrialname = $row->{'TrialName'};

      if ($filtertrialname eq $trial_name) {

          my $err_msg = "Duplicate ($trial_name) cannot be used.";

          push(@{$trial_err_aref}, {'TrialName' => $err_msg});
          $trial_err = 1;
      }
    }

  }

  if (defined $query->param('TrialLayout')) {

    if (length($query->param('TrialLayout')) > 0) {

      $trial_layout = $query->param('TrialLayout');
    }
  }

  my $project_id          = undef;

  if (defined $query->param('ProjectId')) {

    if (length($query->param('ProjectId')) > 0) {

      $project_id = $query->param('ProjectId');
    }
  }

  my $workflow_id         = undef;

  if (defined $query->param('CurrentWorkflowId')) {

    if (length($query->param('CurrentWorkflowId')) > 0) {

      $workflow_id = $query->param('CurrentWorkflowId');
    }
  }

  my $trial_edate         = '';

  if (defined $query->param('TrialEndDate')) {

    $trial_edate = $query->param('TrialEndDate');
  }

  my $trial_note          = '';

  if (defined $query->param('TrialNote')) {

    $trial_note = $query->param('TrialNote');
  }

  my $trial_location      = '';

  if (length($query->param('triallocation')) > 0) {

    $trial_location = $query->param('triallocation');
  }

  if (length($trial_location) > 0) {

    my $dbh_gis_read = connect_gis_read();
    my ($is_wkt_err, $wkt_err_href) = is_valid_wkt_href($dbh_gis_read, {'triallocation' => $trial_location},
                                                        ['POLYGON', 'MULTIPOLYGON', 'POINT']);
    $dbh_gis_read->disconnect();

    if ($is_wkt_err) {

      push(@{$trial_err_aref}, $wkt_err_href);
      $trial_err = 1;
    }
  }

  my ($date_err, $date_href) = check_dt_href( { 'TrialStartDate' => $trial_sdate } );

  if ($date_err) {

    push(@{$trial_err_aref}, $date_href);
    $trial_err = 1;
  }

  if (length($trial_edate) > 0) {

    ($date_err, $date_href) = check_dt_href( { 'TrialEndDate'   => $trial_edate } );

    if ($date_err) {

      push(@{$trial_err_aref}, $date_href);
      $trial_err = 1;
    }
  }
  else {

    $trial_edate = undef;
  }

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength, FactorValidRuleErrMsg, FactorValidRule  ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='trialfactor'";

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
      'CanFactorHaveNull' => $vcol_data->{$vcol_id}->{'CanFactorHaveNull'}
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

  if (defined $project_id) {

    my $project_existence = record_existence($dbh_k_read, 'project', 'ProjectId', $project_id);

    if (!$project_existence) {

      my $err_msg = "Project ($project_id) does not exist.";

      push(@{$trial_err_aref}, {'ProjectId' => $err_msg});
      $trial_err = 1;
    }
  }

  if (defined $workflow_id) {

    if (!record_existence($dbh_k_read, 'workflow', 'WorkflowId', $workflow_id)) {

      my $err_msg = "CurrentWorkflowId ($workflow_id) does not exist.";

      push(@{$trial_err_aref}, {'CurrentWorkflowId' => $err_msg});
      $trial_err = 1;
    }
  }

  my $site_existence = record_existence($dbh_k_read, 'site', 'SiteId', $site_id);

  if (!$site_existence) {

    my $err_msg = "Site ($site_id) does not exist.";

    push(@{$trial_err_aref}, {'SiteId' => $err_msg});
    $trial_err = 1;
  }

  my $trialtype_existence = type_existence($dbh_k_read, 'trial', $trial_type_id);

  if (!$trialtype_existence) {

    my $err_msg = "TrialType ($trial_type_id) does not exist.";

    push(@{$trial_err_aref}, {'TrialTypeId' => $err_msg});
    $trial_err = 1;
  }

  if (!type_existence($dbh_k_read, 'season', $season_id)) {

    my $err_msg = "Season ($season_id) does not exist.";

    push(@{$trial_err_aref}, {'SeasonId' => $err_msg});
    $trial_err = 1;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $perm_str       = permission_phrase($group_id, 0, $gadmin_status, 'genotype');

  my $design_type_existence = record_existence($dbh_k_read, 'designtype', 'DesignTypeId', $design_type_id);

  if (!$design_type_existence) {

    my $err_msg = "DesignType ($design_type_id) does not exist.";

    push(@{$trial_err_aref}, {'DesignTypeId' => $err_msg});
    $trial_err = 1;
  }

  my $trial_manager_existence = record_existence($dbh_k_read, 'contact', 'ContactId', $trial_manager_id);

  if (!$trial_manager_existence) {

    my $err_msg = "TrialManager ($trial_manager_id) does not exist.";

    push(@{$trial_err_aref}, {'TrialManagerId' => $err_msg});
    $trial_err = 1;
  }

  my $access_grp_existence = record_existence($dbh_k_read, 'systemgroup', 'SystemGroupId', $access_group);

  if (!$access_grp_existence) {

    my $err_msg = "AccessGroup ($access_group) does not exist.";

    push(@{$trial_err_aref}, {'AccessGroupId' => $err_msg});
    $trial_err = 1;
  }

  if ( ($own_perm > 7 || $own_perm < 0) ) {

    my $err_msg = "OwnGroupPerm ($own_perm) is invalid.";

    push(@{$trial_err_aref}, {'OwnGroupPerm' => $err_msg});
    $trial_err = 1;
  }

  if ( ($access_perm > 7 || $access_perm < 0) ) {

    my $err_msg = "AccesGroupPerm ($access_perm) is invalid.";

    push(@{$trial_err_aref}, {'AccessGroupPerm' => $err_msg});
    $trial_err = 1;
  }

  if ( ($other_perm > 7 || $other_perm < 0) ) {

    my $err_msg = "OtherPerm ($other_perm) is invalid.";
    
    push(@{$trial_err_aref}, {'OtherPerm' => $err_msg});
    $trial_err = 1;
  }

  $dbh_k_read->disconnect();

  my ($vcol_error, $vcol_error_aref) = validate_all_factor_input($pre_validate_vcol);

  if ($vcol_error) {
    push(@{$trial_err_aref}, @{$vcol_error_aref});
    $trial_err = 1;
  }

  if ($trial_err != 0) {
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => $trial_err_aref};
    return $data_for_postrun_href;
  }

  my $inserted_id = {};
  my $dbh_k_write = connect_kdb_write();

  my $cur_dt = DateTime->now( time_zone => $TIMEZONE );
  $cur_dt = DateTime::Format::MySQL->format_datetime($cur_dt);

  $sql    = 'INSERT INTO trial SET ';
  $sql   .= 'SeasonId=?, ';
  $sql   .= 'ProjectId=?, ';
  $sql   .= 'CurrentWorkflowId=?, ';
  $sql   .= 'SiteId=?, ';
  $sql   .= 'TrialTypeId=?, ';
  $sql   .= 'TrialNumber=?, ';
  $sql   .= 'TrialAcronym=?, ';
  $sql   .= 'DesignTypeId=?, ';
  $sql   .= 'TrialManagerId=?, ';
  $sql   .= 'TrialStartDate=?, ';
  $sql   .= 'TrialEndDate=?, ';
  $sql   .= 'TrialNote=?, ';
  $sql   .= 'TrialLayout=?, ';
  $sql   .= 'TULastUpdateTimeStamp=?, ';
  $sql   .= 'OwnGroupId=?, ';
  $sql   .= 'AccessGroupId=?, ';
  $sql   .= 'OwnGroupPerm=?, ';
  $sql   .= 'AccessGroupPerm=?, ';
  $sql   .= 'OtherPerm=?, ';
  $sql   .= 'TrialName=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($season_id, $project_id, $workflow_id, $site_id, $trial_type_id, $trial_number,
                $trial_acronym, $design_type_id, $trial_manager_id, $trial_sdate, $trial_edate,
                $trial_note, $trial_layout, $cur_dt, $group_id, $access_group, $own_perm, $access_perm,
                $other_perm, $trial_name);

  my $trial_id = -1;
  if (!$dbh_k_write->err()) {

    $trial_id = $dbh_k_write->last_insert_id(undef, undef, 'trial', 'TrialId');
    $self->logger->debug("TrialId: $trial_id");
    $inserted_id->{'trial'} = ['TrialId', $trial_id];
  }
  else {

    my $err_msg = 'Unexpected error: adding trial.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  for my $vcol_id (keys(%{$vcol_data})) {

    my $factor_value = $query->param('VCol_' . "$vcol_id");

    if (length($factor_value) > 0) {

      $sql  = 'INSERT INTO trialfactor SET ';
      $sql .= 'TrialId=?, ';
      $sql .= 'FactorId=?, ';
      $sql .= 'FactorValue=?';
      my $factor_sth = $dbh_k_write->prepare($sql);
      $factor_sth->execute($trial_id, $vcol_id, $factor_value);

      if ($dbh_k_write->err()) {

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

        return $data_for_postrun_href;
      }
      $inserted_id->{'trialfactor'} = ['TrialId', $trial_id];
      $factor_sth->finish();
    }
  }

  my $is_trial_within_site = 1;
  if (length($trial_location) > 0) {

    my $sub_PGIS_val_builder = sub {
      my $wkt = shift;
      my $st_buffer_val = $POINT2POLYGON_BUFFER4TRIAL->{$ENV{DOCUMENT_ROOT}};
      if ($wkt =~ /^POINT/i) {
        return "ST_Multi(ST_Buffer(ST_GeomFromText(?, -1), $st_buffer_val, 1))";
      } else {
        return "ST_Multi(ST_GeomFromText(?, -1))";
      }
    };

    my $sub_WKT_validator = sub {
      my $gis_write = $_[0];
      my $entity    = $_[1];
      my $entity_id = $_[2];
      my $wkt       = $_[3];

      my $site_id = read_cell_value($dbh_k_read, 'trial', 'SiteId', 'TrialId', $trial_id);

      my ($is_within_err, $is_within) = is_within($gis_write, 'siteloc', 'siteid',
                                                'sitelocation', $wkt, $site_id);

      if ($is_within_err) {
        return (1, "Unexpected error.");
      } elsif (!$is_within) {
        if ($GIS_ENFORCE_GEO_WITHIN) {
          return (1, "This trial geography is not within site ($site_id)'s geography.");
        } else {
          $is_trial_within_site = 0;
        }
      }
    };

    my ($err, $err_msg) = append_geography_loc(
                                            "trial",
                                            $trial_id,
                                            ['POINT', 'POLYGON', 'MULTIPOLYGON'],
                                            $query,
                                            $sub_PGIS_val_builder,
                                            $self->logger,
                                            $sub_WKT_validator,
                                          );

    if ($err) {
      my ($rollback_err, $rollback_msg) = $self->rollback_cleanup($dbh_k_write, $inserted_id);
      if ($rollback_err) {
        $self->logger->debug("Rollback error msg: $rollback_msg");
        return $self->_set_error($err_msg);
      }
      return $self->_set_error($err_msg);
    }
  }

  $dbh_k_write->disconnect();

  my $msg = "Trial ($trial_id) has been added successfully. ";
  if (!$is_trial_within_site) {
    $msg   .= "However, this trial's geography is not within site ($site_id)'s geography.";
  }

  my $info_msg_aref = [{'Message' => $msg}];
  my $return_id_aref = [{'Value' => "$trial_id", 'ParaName' => 'TrialId'}];
  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub add_trial_unit_runmode {

=pod add_trial_unit_HELP_START
{
"OperationName": "Add trial unit to the trial",
"Description": "Add a new trial unit to the trial specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "trialunit",
"SkippedField": ["TrialId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='70' ParaName='TrialUnitId' /><Info Message='TrialUnit (70) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '71','ParaName' : 'TrialUnitId'}],'Info' : [{'Message' : 'TrialUnit (71) has been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='ItemId (123) does not exist.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'ItemId (123) does not exist.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "XML",
"UploadFileParameterName": "uploadfile",
"DTDFileNameForUploadXML": "addtrialunit_upload.dtd",
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialId"}],
"HTTPParameter": [{"Name": "Force", "Description": "0|1 flag by default, it is 0. Under normal circumstances, DAL will check EntryId and X, Y, Z combination for uniqueness both in the upload data file and against existing records in the database. If only X and Y dimensions are defined. DAL will check X, Y uniqueness in normal mode. When force is set to 1, these uniqueness checkings will be ignored.", "Required": "0"}, {"Name": "trialunitlocation", "DataType": "polygon_wkt", "Description": "GIS field defining the polygon geometry object of the trial unit in a standard GIS well-known text.", "Type": "LCol", "Required": "0"},{"Name": "trialunitlocdt", "DataType": "timestamp", "Description": "DateTime of trial unit location", "Type": "LCol", "Required": "0"},{"Name": "currentloc", "DataType": "tinyint", "Description": "Flag to notify current location", "Type": "LCol", "Required": "0"},{"Name": "description", "DataType": "varchar", "Description": "Description for location", "Type": "LCol", "Required": "0"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $force = 0;

  if (defined $query->param('Force')) {

    if ( $query->param('Force') =~ /^0|1$/ ) {

      $force = $query->param('Force');
    }
  }

  my $data_for_postrun_href = {};
  my $trial_unit_err_aref = [];
  my $trial_unit_err = 0;

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'TrialId' => 1};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'trialunit', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $trial_id            = $self->param('id');

  my $replicate_number    = $query->param('ReplicateNumber');

  my $src_trial_unit_id   = undef;

  if (defined $query->param('SourceTrialUnitId')) {

    if (length($query->param('SourceTrialUnitId')) > 0) {

      $src_trial_unit_id = $query->param('SourceTrialUnitId');
    }
  }

  if ($src_trial_unit_id eq '0') {

    $src_trial_unit_id = undef;
  }

  my $sample_supplier_id  = '0';

  if (defined $query->param('SampleSupplierId')) {

    $sample_supplier_id = $query->param('SampleSupplierId');
  }

  my $barcode             = '0';

  my $trial_unit_comment  = '';

  if (defined $query->param('TrialUnitNote')) {

    $trial_unit_comment = $query->param('TrialUnitNote');
  }

  if (length($query->param('TrialUnitBarcode')) > 0) {

    $barcode = $query->param('TrialUnitBarcode');
  }

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength, FactorValidRuleErrMsg, FactorValidRule  ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='trialunitfactor'";

  my $dbh_k_read = connect_kdb_read();
  my $vcol_data = $dbh_k_read->selectall_hashref($sql, 'FactorId');
  my $vcol_param_data        = {};
  my $vcol_len_info          = {};
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
      'CanFactorHaveNull' => $vcol_data->{$vcol_id}->{'CanFactorHaveNull'}
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

  $dbh_k_read->disconnect();

  my $trialunit_info_xml_file = $self->authen->get_upload_file();
  my $add_trialunit_dtd_file  = $self->get_addtrialunit_dtd_file();

  add_dtd($add_trialunit_dtd_file, $trialunit_info_xml_file);

  my $xml_checker_parser = new XML::Checker::Parser( Handlers => { } );

  eval {

    local $XML::Checker::FAIL = sub {

      my $code = shift;
      my $err_str = XML::Checker::error_string ($code, @_);
      $self->logger->debug("XML Parsing ERR: $code : $err_str");
      die $err_str;
    };
    $xml_checker_parser->parsefile($trialunit_info_xml_file);
  };

  if ($@) {

    my $err_msg = $@;
    $self->logger->debug("Parsing XML error: $err_msg");
    my $user_err_msg = "Uploaded xml (trialunitspecimen) file does not comply with its definition.\n";
    $user_err_msg   .= "Details: $err_msg";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $user_err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $dbh_k_write = connect_kdb_write();

  my $treatment_id        = 0;

  if (length($query->param('TreatmentId')) > 0) {

    $treatment_id = $query->param('TreatmentId');
    my $treatment_existence = record_existence($dbh_k_write, 'treatment', 'TreatmentId', $treatment_id);

    if (!$treatment_existence) {

      my $err_msg = "Treatment ($treatment_id) does not exist.";

      push(@{$trial_unit_err_aref}, {'TreatmentId' => $err_msg});
      $trial_unit_err = 1;
    }
   }

  my $trial_existence = record_existence($dbh_k_write, 'trial', 'TrialId', $trial_id);

  if (!$trial_existence) {

    my $err_msg = "Trial ($trial_id) does not exist.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( $barcode ne '0' ) {

    if (record_existence($dbh_k_write, 'trialunit', 'TrialUnitBarcode', $barcode)) {

      my $err_msg = "TrialUnitBarcode ($barcode): already exists.";

      push(@{$trial_unit_err_aref}, {'TrialUnitBarcode' => $err_msg});
      $trial_unit_err = 1;
    }
  }

  if (defined $src_trial_unit_id) {

    if (!record_existence($dbh_k_write, 'trialunit', 'TrialUnitId', $src_trial_unit_id)) {

      my $err_msg = "SourceTrialUnitId ($src_trial_unit_id) not found.";

      push(@{$trial_unit_err_aref}, {'SourceTrialUnitId' => $err_msg});
      $trial_unit_err = 1;
    }
  }

  my $sql = 'SELECT Dimension FROM trialdimension WHERE TrialId=?';

  my ($r_di_err, $r_di_msg, $dimension_aref) = read_data($dbh_k_write, $sql, [$trial_id]);

  if ($r_di_err) {

    $self->logger->debug("Read trial dimension failed: $r_di_msg");
    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$dimension_aref}) == 0) {

    my $err_msg = "Trial ($trial_id): no dimension defined.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dimension_href = {};

  for my $dimension_rec (@{$dimension_aref}) {

    my $dimension = $dimension_rec->{'Dimension'};
    $dimension_href->{$dimension} = 1;
  }

  my $dimension_provided = 0;

  if ($force == 0) {

    my @coord_val_list;
    my @coord_dim_list;
    my @sql_coord_dim_list;

    foreach my $dim (('X', 'Y', 'Z')) {

      if (defined $dimension_href->{$dim}) {

        if (length($query->param("TrialUnit" . $dim)) == 0) {

          my $err_msg = "TrialUnit${dim} is missing while ${dim} dimension is defined.";

          push(@{$trial_unit_err_aref}, {"TrialUnit${dim}" => $err_msg});
          $trial_unit_err = 1;
        }
        else {

          my $dim_val = $query->param("TrialUnit" . $dim);

          push(@coord_val_list, $dim_val);
          push(@coord_dim_list, $dim);
          push(@sql_coord_dim_list, "TrialUnit${dim}=?");

          $self->logger->debug("Read cell: $dim -> $dim_val ");
        }
      }
    }

    if (scalar(@coord_val_list) > 0 && $trial_unit_err == 0) {

      $sql = 'SELECT TrialUnitId FROM trialunit WHERE TrialId=? AND ' . join(' AND ', @sql_coord_dim_list);
      $self->logger->debug("Read cell: $sql ");
      my ($r_tu_id_err, $db_trialunit_id) = read_cell($dbh_k_write, $sql, [$trial_id, @coord_val_list]);

      if ($r_tu_id_err) {

        my $err_msg = "Unexpected Error.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }

      if (length($db_trialunit_id) > 0) {

        my $err_msg = "Dimension (" . join(',', @coord_dim_list) . ") value (" . join(',', @coord_val_list) . '): ';
        $err_msg   .= 'already used.';

        foreach my $dim_name (@coord_dim_list) {
          #push(@{$trial_unit_err_aref}, {"TrialUnit${dim_name}" => $err_msg});
        }
        
        push(@{$trial_unit_err_aref}, {"Message" => $err_msg});

        $trial_unit_err = 1;
      }
    }
  }

  my @dimension_val_list;
  my @dimension_sql_list;
  my @user_dimension_list;

  if ($trial_unit_err == 0) {
    for my $dimension_rec (@{$dimension_aref}) {

      my $dimension = $dimension_rec->{'Dimension'};

      if (defined $query->param("TrialUnit${dimension}")) {

        if (length($query->param("TrialUnit${dimension}")) > 0) {

          $dimension_provided = 1;

          my $dimension_val = $query->param("TrialUnit${dimension}");

          if ($dimension ne 'Position') {

            if ( $dimension_val !~ /^\d+$/ ) {

              my $err_msg = "TrialUnit${dimension} ($dimension_val): not a positive integer.";

              push(@{$trial_unit_err_aref}, {"TrialUnit${dimension}"=> $err_msg});
              $trial_unit_err = 1;
            }
          }

          push(@dimension_val_list, $dimension_val);
          push(@dimension_sql_list, "TrialUnit${dimension}=?");
          push(@user_dimension_list, $dimension);

          $self->logger->debug("Read cell: $dimension -> $dimension_val ");
        }
      }

      if (lc($dimension) eq lc('EntryId')) {

        my $entry_id_val = $query->param('TrialUnitEntryId');

        if (length($entry_id_val) > 0) {

          if ($force == 0) {

            my $entry_id_sql = 'SELECT TrialUnitId FROM trialunit WHERE TrialId=? AND TrialUnitEntryId=?';
            
            $self->logger->debug("Read cell: $entry_id_sql ");
            my ($r_tu_id_err, $db_trialunit_id) = read_cell($dbh_k_write, $entry_id_sql, [$trial_id, $entry_id_val]);

            if ($r_tu_id_err) {

              my $err_msg = "Unexpected Error.";
              $data_for_postrun_href->{'Error'} = 1;
              $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

              return $data_for_postrun_href;
            }

            if (length($db_trialunit_id) > 0) {

              my $err_msg = "TrialUnitEntryId ($entry_id_val) is already used.";

              push(@{$trial_unit_err_aref}, {'TrialUnitEntryId' => $err_msg});
              $trial_unit_err = 1;
            }
          }
        }
        else {

          my $err_msg = "TrialUnitEntryId is missing while EntryId is defined.";

          push(@{$trial_unit_err_aref}, {"TrialUnitEntryId" => $err_msg});
          $trial_unit_err = 1;
        }
      }
    }

    if ($dimension_provided == 0) {

      my $err_msg = "No dimension value provided.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }
  else {
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => $trial_unit_err_aref};
    return $data_for_postrun_href;
  }
  

  $sql = 'SELECT TrialUnitId FROM trialunit WHERE TrialId=? AND ' . join(' AND ', @dimension_sql_list);
  $self->logger->debug("Read cell: $sql $trial_unit_err");


  my ($r_tu_id_err, $db_trialunit_id) = read_cell($dbh_k_write, $sql, [$trial_id, @dimension_val_list]);

  if ($r_tu_id_err) {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_trialunit_id) > 0) {

    my $err_msg = "Dimension (" . join(',', @user_dimension_list) . ") value (" . join(',', @dimension_val_list) . '): ';
    $err_msg   .= 'already used.';

    foreach my $dim_name (@user_dimension_list) {
      push(@{$trial_unit_err_aref}, {"TrialUnit${dim_name}" => $err_msg});
    }
    
    $trial_unit_err = 1;
  }

  my $trialunit_info_xml  = read_file($trialunit_info_xml_file);
  my $trialunit_info_aref = xml2arrayref($trialunit_info_xml, 'trialunitspecimen');

  my $uniq_spec_href = {};

  my @geno_id_list;
  $sql = '';

  my $specimen_count = 0;

  for my $trialunitspecimen (@{$trialunit_info_aref}) {

    my $specimen_id = $trialunitspecimen->{'SpecimenId'};

    my $spec_num = 0;

    if (defined $trialunitspecimen->{'SpecimenNumber'}) {

      if (length($trialunitspecimen->{'SpecimenNumber'}) > 0) {

        $spec_num = $trialunitspecimen->{'SpecimenNumber'};
      }
    }

    if (defined $uniq_spec_href->{"${specimen_id}_${spec_num}"}) {

      my $err_msg   = "Specimen ($specimen_id, $spec_num): duplicate.";
      
      push(@{$trial_unit_err_aref}, {"TrialUnitSpecimen${specimen_count}Specimen" => $err_msg});
      $trial_unit_err = 1;
    }
    else {

      $uniq_spec_href->{"${specimen_id}_${spec_num}"} = 1;
    }

    $sql = 'SELECT GenotypeId FROM genotypespecimen WHERE SpecimenId=?';
    my $sth = $dbh_k_write->prepare($sql);
    $sth->execute($specimen_id);
    my $genotype_id_href = $sth->fetchall_hashref('GenotypeId');
    $sth->finish();

    my @geno_id = keys(%{$genotype_id_href});
    if (scalar(@geno_id) == 0) {

      my $err_msg = "SpecimenId ($specimen_id) does not exist.";

      push(@{$trial_unit_err_aref}, {"TrialUnitSpecimen${specimen_count}Specimen" => $err_msg});
      $trial_unit_err = 1;

    }

    my $item_id = undef;

    if (length($trialunitspecimen->{'ItemId'}) > 0) {

      $item_id = $trialunitspecimen->{'ItemId'};
    }

    if ( length($item_id) > 0 ) {

      my $item_existence = record_existence($dbh_k_write, 'item', 'ItemId', $item_id);

      if (!$item_existence) {

        my $err_msg = "ItemId ($item_id) does not exist.";

        push(@{$trial_unit_err_aref}, {"TrialUnitSpecimen${specimen_count}ItemId" => $err_msg});
        $trial_unit_err = 1;
      }
    }

    push(@geno_id_list, @geno_id);

    my $plant_date = $trialunitspecimen->{'PlantDate'};

    if (length($plant_date) > 0 && (!($plant_date =~ /\d{4}\-\d{2}\-\d{2}/))) {

      my $err_msg = "PlantDate ($plant_date) is not an acceptable date: yyyy-mm-dd";

      push(@{$trial_unit_err_aref}, {"TrialUnitSpecimen${specimen_count}PlantDate" => $err_msg});
      $trial_unit_err = 1;
    }

    my $harvest_date = $trialunitspecimen->{'HarvestDate'};

    if (length($harvest_date) > 0 && (!($harvest_date =~ /\d{4}\-\d{2}\-\d{2}/))) {

      my $err_msg = "HarvestDate ($harvest_date) is not an acceptable date: yyyy-mm-dd";

      push(@{$trial_unit_err_aref}, {"TrialUnitSpecimen${specimen_count}HarvestDate" => $err_msg});
      $trial_unit_err = 1;
    }

    my $has_died = $trialunitspecimen->{'HasDied'};

    if (length($has_died) > 0 && (!($has_died =~ /^[0|1]$/))) {

      my $err_msg = "HasDied ($has_died) can be either 1 or 0 only.";

      push(@{$trial_unit_err_aref}, {"TrialUnitSpecimen${specimen_count}HasDied" => $err_msg});
      $trial_unit_err = 1;
    }

    $specimen_count++;
  }

  my ($is_trial_ok, $trouble_trial_id_aref) = check_permission($dbh_k_write, 'trial', 'TrialId',
                                                               [$trial_id], $group_id, $gadmin_status,
                                                               $READ_WRITE_PERM);

  if (!$is_trial_ok) {

    my $trouble_trial_id = $trouble_trial_id_aref->[0];

    my $err_msg = "Permission denied: Group ($group_id) and Trial ($trouble_trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($is_geno_ok, $trouble_geno_id_aref) = check_permission($dbh_k_write, 'genotype', 'GenotypeId',
                                                             \@geno_id_list, $group_id, $gadmin_status,
                                                             $LINK_PERM);

  if (!$is_geno_ok) {

    my $trouble_geno_id_str = join(',', @{$trouble_geno_id_aref});

    my $perm_err_msg = '';
    $perm_err_msg   .= "Permission denied: Group ($group_id) and Genotype ($trouble_geno_id_str).";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $perm_err_msg}]};

    return $data_for_postrun_href;
  }
  
  # Validate virtual column for factor
  my ( $vcol_missing_err, $vcol_missing_msg ) = check_missing_value($vcol_param_data);

  if ($vcol_missing_err) {

    $vcol_missing_msg = $vcol_missing_msg . ' missing';
    
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $vcol_missing_msg}]};

    return $data_for_postrun_href;
  }

  my ( $vcol_maxlen_err, $vcol_maxlen_msg ) = check_maxlen( $vcol_param_data_maxlen, $vcol_len_info );

  if ($vcol_maxlen_err) {

    $vcol_maxlen_msg = $vcol_maxlen_msg . ' longer than maximum length.';
    
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $vcol_maxlen_msg}]};

    return $data_for_postrun_href;
  }

  my ($vcol_error, $vcol_error_aref) = validate_all_factor_input($pre_validate_vcol);

  if ($vcol_error) {
    push(@{$trial_unit_err_aref}, @{$vcol_error_aref});
    $trial_unit_err = 1;
  }

   if ($trial_unit_err != 0) {
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => $trial_unit_err_aref};
    return $data_for_postrun_href;
  }

  $sql    = 'INSERT INTO trialunit SET ';
  $sql   .= 'TrialId=?, ';
  $sql   .= 'SampleSupplierId=?, ';
  $sql   .= 'ReplicateNumber=?, ';
  $sql   .= 'TrialUnitBarcode=?, ';
  $sql   .= 'TrialUnitNote=?, ';
  $sql   .= 'SourceTrialUnitId=?, ';
  $sql   .= join(',', @dimension_sql_list);

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($trial_id, $sample_supplier_id,
                $replicate_number, $barcode, $trial_unit_comment, $src_trial_unit_id,
                @dimension_val_list);

  if ($dbh_k_write->err()) {

    $self->logger->debug("SQL Error:" . $dbh_k_write->errstr());
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  my $trial_unit_id = $dbh_k_write->last_insert_id(undef, undef, 'trialunit', 'TrialUnitId');

  if (length $query->param('trialunitlocation')) {
    my $sub_PGIS_val_builder = sub {
      return "ST_ForceCollection(ST_GeomFromText(?, -1))";
    };
    my ($err, $err_msg) = append_geography_loc(
                                                "trialunit",
                                                $trial_unit_id,
                                                ['POINT', 'POLYGON', 'MULTIPOLYGON'],
                                                $query,
                                                $sub_PGIS_val_builder,
                                                $self->logger,
                                              );
    if ($err) {
      return $self->_set_error($err_msg);
    }
  }


  for my $trialunitspecimen (@{$trialunit_info_aref}) {

    my $specimen_id  = $trialunitspecimen->{'SpecimenId'};

    my $item_id      = undef;
    my $plant_date   = undef;
    my $harvest_date = undef;
    my $has_died     = undef;
    my $notes        = undef;
    my $tus_label    = undef;
    my $spec_num     = 0;

    if ( length($trialunitspecimen->{'PlantDate'}) > 0 ) {

      $plant_date = $trialunitspecimen->{'PlantDate'};
    }

    if ( length($trialunitspecimen->{'HarvestDate'}) > 0 ) {

      $harvest_date = $trialunitspecimen->{'HarvestDate'};
    }

    if ( length($trialunitspecimen->{'HasDied'}) > 0 ) {

      $has_died = $trialunitspecimen->{'HasDied'};
    }

    if ( length($trialunitspecimen->{'Notes'}) > 0 ) {

      $notes = $trialunitspecimen->{'Notes'};
    }

    if ( length($trialunitspecimen->{'ItemId'}) > 0) {

      $item_id = $trialunitspecimen->{'ItemId'};
    }

    if ( length($trialunitspecimen->{'SpecimenNumber'}) > 0 ) {

      $spec_num = $trialunitspecimen->{'SpecimenNumber'};
    }

    if ( length($trialunitspecimen->{'TUSLabel'}) > 0 ) {

      $tus_label = $trialunitspecimen->{'TUSLabel'};
    }

    $sql  = 'INSERT INTO trialunitspecimen SET ';
    $sql .= 'SpecimenId=?, ';
    $sql .= 'TrialUnitId=?, ';
    $sql .= 'PlantDate=?, ';
    $sql .= 'HarvestDate=?, ';
    $sql .= 'HasDied=?, ';
    $sql .= 'Notes=?, ';
    $sql .= 'SpecimenNumber=?, ';
    $sql .= 'TUSLabel=?';

    my $trialunit_specimen_sth = $dbh_k_write->prepare($sql);
    $trialunit_specimen_sth->execute($specimen_id, $trial_unit_id, $plant_date, $harvest_date,
                                     $has_died, $notes, $spec_num, $tus_label);

    if ($dbh_k_write->err()) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }
    $trialunit_specimen_sth->finish();
  }

  for my $vcol_id (keys(%{$vcol_data})) {

    $self->logger->debug("Vcolid: $vcol_id");

    my $factor_value = $query->param('VCol_' . "$vcol_id");

    $self->logger->debug("FactorValue: $factor_value");

    if (length($factor_value) > 0) {

      $sql  = 'INSERT INTO trialunitfactor SET ';
      $sql .= 'TrialUnitId=?, ';
      $sql .= 'FactorId=?, ';
      $sql .= 'FactorValue=?';

      my $factor_sth = $dbh_k_write->prepare($sql);
      $factor_sth->execute($trial_unit_id, $vcol_id, $factor_value);

      if ($dbh_k_write->err()) {

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

        return $data_for_postrun_href;
      }

      $factor_sth->finish();
    }
  }

  #add trial treatment
  if (length($query->param('TreatmentId')) > 0) {
    $sql = "INSERT INTO trialunittreatment (TreatmentId, TrialUnitId) ";
    $sql .= "VALUES (?, ?)";
    my $sth = $dbh_k_write->prepare($sql);
    $sth->execute($treatment_id, $trial_unit_id);

    if ($dbh_k_write->err()) {

      $self->logger->debug("SQL Error:" . $dbh_k_write->errstr());
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => "Unexpected error. $trial_unit_id $treatment_id"}]};

      return $data_for_postrun_href;
    }
    $sth->finish();
  }

  $dbh_k_write->disconnect();

  my $info_msg_aref  = [{'Message' => "TrialUnit ($trial_unit_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$trial_unit_id", 'ParaName' => 'TrialUnitId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}



sub add_trial_unit_bulk_runmode {

=pod add_trial_unit_bulk_HELP_START
{
"OperationName": "Add trial units to the trial",
"Description": "Add trial units in bulk to the trial specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='1 TrialUnits for Trial (1) have been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : '1 TrialUnits for Trial (3) have been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Treatment (1872) does not exist.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Treatment (1872) does not exist.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "XML",
"UploadFileParameterName": "uploadfile",
"DTDFileNameForUploadXML": "addtrialunitbulk_upload.dtd",
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialId"}],
"HTTPParameter": [{"Name": "Force", "Description": "0|1 flag by default, it is 0. Under normal circumstances, DAL will check EntryId and X, Y, Z combination for uniqueness both in the upload data file and against existing records in the database. If only X and Y dimensions are defined. DAL will check X, Y uniqueness in normal mode. When force is set to 1, these uniqueness checkings will be ignored.", "Required": "0"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $per_trialunit_error = {};

  my $trial_unit_err_aref = [];
  my $trial_unit_err = 0;

  my $trial_id = $self->param('id');

  my $force = 0;

  if (defined $query->param('Force')) {

    if ( $query->param('Force') =~ /^0|1$/ ) {

      $force = $query->param('Force');
    }
  }

  my $trialunit_info_xml_file = $self->authen->get_upload_file();
  my $add_trialunit_dtd_file  = $self->get_addtrialunit_bulk_dtd_file();

  $self->logger->debug("DOCUMENT_ROOT: " . $ENV{DOCUMENT_ROOT});
  $self->logger->debug("DTD FILE: $add_trialunit_dtd_file");

  add_dtd($add_trialunit_dtd_file, $trialunit_info_xml_file);

  my $xml_checker_parser = new XML::Checker::Parser( Handlers => { } );

  eval {

    local $XML::Checker::FAIL = sub {

      my $code = shift;
      my $err_str = XML::Checker::error_string ($code, @_);
      $self->logger->debug("XML Parsing ERR: $code : $err_str");
      die $err_str;
    };
    $xml_checker_parser->parsefile($trialunit_info_xml_file);
  };

  if ($@) {

    my $err_msg = $@;
    $self->logger->debug("Parsing XML error: $err_msg");
    my $user_err_msg = "Uploaded xml (trialunitspecimen) file does not comply with its definition.\n";
    $user_err_msg   .= "Details: $err_msg";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $user_err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_k_write   = connect_kdb_write(1);
  my $dbh_gis_write = connect_gis_write();

  eval {
    my $trial_existence = record_existence($dbh_k_write, 'trial', 'TrialId', $trial_id);

    if (!$trial_existence) {

      my $err_msg = "Trial ($trial_id) does not exist.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return 1;
    }

    my $sql = 'SELECT Dimension FROM trialdimension WHERE TrialId=?';

    my ($r_di_err, $r_di_msg, $dimension_aref) = read_data($dbh_k_write, $sql, [$trial_id]);

    if ($r_di_err) {

      $self->logger->debug("Read trial dimension failed: $r_di_msg");
      my $err_msg = "Unexpected Error.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return 1;
    }

    if (scalar(@{$dimension_aref}) == 0) {

      my $err_msg = "Trial ($trial_id): no dimension defined.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return 1;
    }

    my @dimension_list;
    my $dimension_href = {};

    for my $dimension_rec (@{$dimension_aref}) {

      my $dimension_name = $dimension_rec->{'Dimension'};

      $dimension_href->{$dimension_name} = 1;
      push(@dimension_list, $dimension_name);
    }

    my ($get_scol_err, $get_scol_msg, $scol_data, $pkey_data) = get_static_field($dbh_k_write, 'trialunit');

    if ($get_scol_err) {

      $self->logger->debug("Get static field info failed: $get_scol_msg");

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

      return 1;
    }

    my $group_id  = $self->authen->group_id();
    my $gadmin_status = $self->authen->gadmin_status();

    my ($is_trial_ok, $trouble_trial_id_aref) = check_permission($dbh_k_write, 'trial', 'TrialId',
                                                                [$trial_id], $group_id, $gadmin_status,
                                                                $READ_WRITE_PERM);

    if (!$is_trial_ok) {

      my $trouble_trial_id = $trouble_trial_id_aref->[0];

      my $err_msg = "Permission denied: Group ($group_id) and Trial ($trouble_trial_id).";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return 1;
    }

    my $trialunit_info_xml  = read_file($trialunit_info_xml_file);
    my $trialunit_info_aref = xml2arrayref($trialunit_info_xml, 'trialunit');

    my $uniq_unitposition  = {};
    my $uniq_barcode       = {};

    my $uniq_entry_id_href = {};
    my $uniq_coord_href    = {};

    my $trialunit_count = 0;

    for my $trialunit (@{$trialunit_info_aref}) {

      my $colsize_info          = {};
      my $chk_maxlen_field_href = {};

      for my $static_field (@{$scol_data}) {

        my $field_name  = $static_field->{'Name'};
        my $field_dtype = $static_field->{'DataType'};

        if (lc($field_dtype) eq 'varchar') {

          $colsize_info->{$field_name}           = $static_field->{'ColSize'};
          $chk_maxlen_field_href->{$field_name}  = $trialunit->{$field_name};
        }
      }

      my ($maxlen_err, $maxlen_msg) = check_maxlen($chk_maxlen_field_href, $colsize_info);

      if ($maxlen_err) {

        $maxlen_msg .= 'longer than its maximum length';

        $data_for_postrun_href->{'Error'}       = 1;
        $data_for_postrun_href->{'Data'}        = {'Error' => [{'Message' => $maxlen_msg}]};

        return 1;
      }

      my $replicate_number    = $trialunit->{'ReplicateNumber'};

      my $trial_unit_comment  = '';

      if (length($trialunit->{'TrialUnitNote'}) > 0) {

        $trial_unit_comment = $trialunit->{'TrialUnitNote'};
      }

      my $sample_supplier_id  = '0';

      if (length($trialunit->{'SampleSupplierId'}) > 0) {

        $sample_supplier_id = $trialunit->{'SampleSupplierId'};
      }

      my $treatment_id        = undef;

      if (length($trialunit->{'TreatmentId'}) > 0) {

        $treatment_id = $trialunit->{'TreatmentId'};
      }

      if (defined $treatment_id) {

        my $treatment_existence = record_existence($dbh_k_write, 'treatment', 'TreatmentId', $treatment_id);

        if (!$treatment_existence) {

          my $err_msg = "Treatment ($treatment_id) does not exist.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return 1;
        }
      }

      my $src_trial_unit_id = undef;

      if (length($trialunit->{'SourceTrialUnitId'}) > 0) {

        $src_trial_unit_id = $trialunit->{'SourceTrialUnitId'};
      }

      if (defined $src_trial_unit_id) {

        if (!record_existence($dbh_k_write, 'trialunit', 'TrialUnitId', $src_trial_unit_id)) {

          my $err_msg = "SourceTrialUnitId ($src_trial_unit_id): not found.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return 1;
        }
      }

      my $barcode = undef;

      if (length($trialunit->{'TrialUnitBarcode'}) > 0) {

        $barcode = $trialunit->{'TrialUnitBarcode'};
      }

      if ( defined $barcode ) {

        if (record_existence($dbh_k_write, 'trialunit', 'TrialUnitBarcode', $barcode)) {

          my $err_msg = "TrialUnitBarcode ($barcode): already exists.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return 1;
        }

        if (defined $uniq_barcode->{$barcode}) {

          my $err_msg = "TrialUnitBarcode ($barcode): duplicate.";
          $self->logger->debug("TrialUnitBarcode ($barcode) is duplicate in the XML file.");
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return 1;
        }
        else {

          $uniq_barcode->{$barcode} = 1;
        }
      }

      if ($force == 0) {

        my $coord_key = '';
        my @coord_val_list;
        my @coord_dim_list;
        my @sql_coord_dim_list;

        foreach my $dim (('X', 'Y', 'Z')) {

          if (defined $dimension_href->{$dim}) {

            if (length($trialunit->{"TrialUnit" . $dim}) == 0) {

              my $err_msg = "TrialUnit${dim} is missing while ${dim} dimension is defined.";
              $data_for_postrun_href->{'Error'} = 1;
              $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

              return 1;
            }
            else {

              my $dim_val = $trialunit->{"TrialUnit" . $dim};
              $coord_key .= "${dim}${dim_val}";

              push(@coord_val_list, $dim_val);
              push(@coord_dim_list, $dim);
              push(@sql_coord_dim_list, "TrialUnit${dim}=?");
            }
          }
        }

        if (scalar(@coord_val_list) > 0) {

          if (defined $uniq_coord_href->{$coord_key}) {

            my $err_msg = "Dimension (" . join(',', @coord_dim_list) . ") value (" . join(',', @coord_val_list) . '): ';
            $err_msg   .= 'duplicate. ';
            $data_for_postrun_href->{'Error'} = 1;
            $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

            return 1;
          }
          else {

            $uniq_coord_href->{$coord_key} = 1;
          }


          $sql = 'SELECT TrialUnitId FROM trialunit WHERE TrialId=? AND ' . join(' AND ', @sql_coord_dim_list);

          my ($r_tu_id_err, $db_trialunit_id) = read_cell($dbh_k_write, $sql, [$trial_id, @coord_val_list]);

          if ($r_tu_id_err) {

            my $err_msg = "Unexpected Error.";
            $data_for_postrun_href->{'Error'} = 1;
            $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

            return 1;
          }

          if (length($db_trialunit_id) > 0) {

            my $err_msg = "Dimension (" . join(',', @coord_dim_list) . ") value (" . join(',', @coord_val_list) . '): ';
            $err_msg   .= 'already used.';
            $data_for_postrun_href->{'Error'} = 1;
            $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

            return 1;
          }
        }
      }

      if (defined $dimension_href->{'EntryId'}) {

        if (length($trialunit->{'TrialUnitEntryId'}) == 0) {

          my $err_msg = "TrialUnitEntryId is missing while EntryId is defined.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return 1;
        }
        else {

          if ( $force == 0 ) {

            my $entry_id = $trialunit->{'TrialUnitEntryId'};

            if (defined $uniq_entry_id_href->{$entry_id}) {

              my $err_msg = "TrialUnitEntryId ($entry_id): duplicate.";
              $data_for_postrun_href->{'Error'} = 1;
              $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

              return 1;
            }
            else {

              $uniq_entry_id_href->{$entry_id} = 1;
            }

            $sql = 'SELECT TrialUnitId FROM trialunit WHERE TrialId=? AND TrialUnitEntryId=?';

            my ($r_tu_id_err, $db_trialunit_id) = read_cell($dbh_k_write, $sql, [$trial_id, $entry_id]);

            if ($r_tu_id_err) {

              my $err_msg = "Unexpected Error.";
              $data_for_postrun_href->{'Error'} = 1;
              $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

              return 1;
            }

            if (length($db_trialunit_id) > 0) {

              my $err_msg = "TrialUnitEntryId ($entry_id) is already used.";
              $data_for_postrun_href->{'Error'} = 1;
              $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

              return 1;
            }
          }
        }
      }

      my $unitpos_txt        = '';
      my $dimension_provided = 0;
      my @dimension_val_list;
      my @user_dimension_list;
      my @sql_dimension_list;

      for my $dimension (@dimension_list) {

        if (defined $trialunit->{"TrialUnit${dimension}"}) {

          if (length($trialunit->{"TrialUnit${dimension}"}) > 0) {

            $dimension_provided = 1;

            my $dimension_val = $trialunit->{"TrialUnit${dimension}"};

            push(@dimension_val_list, $dimension_val);
            push(@user_dimension_list, $dimension);
            push(@sql_dimension_list, "TrialUnit${dimension}=?");

            $unitpos_txt .= $dimension . lc($dimension_val) . "|";

            if ($dimension ne 'Position') {

              if ( $dimension_val !~ /^\d+$/ ) {

                my $err_msg = "TrialUnit${dimension} ($dimension_val): not a positive integer.";
                $data_for_postrun_href->{'Error'} = 1;
                $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

                return 1;
              }
            }
          }
        }
      }

      if ($dimension_provided == 0) {

        my $err_msg = "No dimension value provided.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $1;
      }

      if (defined $uniq_unitposition->{$unitpos_txt}) {

        my $err_msg = "Dimension (" . join(',', @user_dimension_list) . ") value (" . join(',', @dimension_val_list) . '): ';
        $err_msg   .= 'duplicate.';
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return 1;
      }
      else {

        $uniq_unitposition->{$unitpos_txt} = 1;
      }

      $sql = 'SELECT TrialUnitId FROM trialunit WHERE TrialId=? AND ' . join(' AND ', @sql_dimension_list);

      my ($r_tu_id_err, $db_trialunit_id) = read_cell($dbh_k_write, $sql, [$trial_id, @dimension_val_list]);

      if ($r_tu_id_err) {

        my $err_msg = "Unexpected Error.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return 1;
      }

      if (length($db_trialunit_id) > 0) {

        my $err_msg = "Dimension (" . join(',', @user_dimension_list) . ") value (" . join(',', @dimension_val_list) . '): ';
        $err_msg   .= 'already used.';
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return 1;
      }

      if ( !(defined($trialunit->{'trialunitspecimen'})) ) {

        my $err_msg = "Missing trialunitspecimen.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'uploadfile' => $err_msg}]};

        return 1;
      }
      elsif (ref($trialunit->{'trialunitspecimen'}) eq 'HASH') {

        my $tu_spec_href = $trialunit->{'trialunitspecimen'};
        my $tu_spec_aref = [];
        push(@{$tu_spec_aref}, $tu_spec_href);
        $trialunit->{'trialunitspecimen'} = $tu_spec_aref;
      }

      if (ref($trialunit->{'trialunitfactor'}) eq 'HASH') {
        my $tu_factor_href = $trialunit->{'trialunitfactor'};
        my $tu_factor_aref = [];
        push(@{$tu_factor_aref}, $tu_factor_href);
        $trialunit->{'trialunitfactor'} = $tu_factor_aref;

      }

      my $trialunit_location = '';

      if (length($trialunit->{'trialunitlocation'}) > 0) {

        $trialunit_location = $trialunit->{'trialunitlocation'};
        my ($is_wkt_err, $wkt_err_href) = is_valid_wkt_href($dbh_gis_write,
                                                            {'trialunitlocation' => $trialunit_location},
                                                            'POINT');

        if ($is_wkt_err) {

          $self->logger->debug("Trial unit location: $trialunit_location");

          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [$wkt_err_href]};

          return 1;
        }

        $trialunit_location = $trialunit->{'trialunitlocation'};
      }

      my $tu_specimen_aref = $trialunit->{'trialunitspecimen'};

      my @geno_id_list;

      my $uniq_spec_href = {};

      for my $trialunitspecimen (@{$tu_specimen_aref}) {

        my $specimen_id = $trialunitspecimen->{'SpecimenId'};

        my $spec_num = 0;

        if (defined $trialunitspecimen->{'SpecimenNumber'}) {

          if (length($trialunitspecimen->{'SpecimenNumber'}) > 0) {

            $spec_num = $trialunitspecimen->{'SpecimenNumber'};
          }
        }

        if (defined $uniq_spec_href->{"${specimen_id}_${spec_num}"}) {

          my $err_msg = "Specimen ($specimen_id, $spec_num): duplicate.";

          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return 1;
        }
        else {

          $uniq_spec_href->{"${specimen_id}_${spec_num}"} = 1;
        }

        $sql = 'SELECT GenotypeId FROM genotypespecimen WHERE SpecimenId=?';
        my $sth = $dbh_k_write->prepare($sql);
        $sth->execute($specimen_id);
        my $genotype_id_href = $sth->fetchall_hashref('GenotypeId');
        $sth->finish();

        my @geno_id = keys(%{$genotype_id_href});
        if (scalar(@geno_id) == 0) {

          my $err_msg = "Specimen ($specimen_id) does not exist.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return 1;
        }

        my $item_id = undef;

        if (length($trialunitspecimen->{'ItemId'}) > 0) {

          $item_id = $trialunitspecimen->{'ItemId'};
        }

        if ( defined $item_id ) {

          my $item_existence = record_existence($dbh_k_write, 'item', 'ItemId', $item_id);

          if (!$item_existence) {

            my $err_msg = "Item ($item_id) does not exist.";
            $data_for_postrun_href->{'Error'} = 1;
            $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

            return 1;
          }
        }

        push(@geno_id_list, @geno_id);

        my $plant_date = $trialunitspecimen->{'PlantDate'};

        if (length($plant_date) > 0 && (!($plant_date =~ /\d{4}\-\d{2}\-\d{2}/))) {

          my $err_msg = "PlantDate ($plant_date) is not an acceptable date: yyyy-mm-dd";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return 1;
        }

        my $harvest_date = $trialunitspecimen->{'HarvestDate'};

        if (length($harvest_date) > 0 && (!($harvest_date =~ /\d{4}\-\d{2}\-\d{2}/))) {

          my $err_msg = "HarvestDate ($harvest_date) is not an acceptable date: yyyy-mm-dd";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return 1;
        }

        my $has_died = $trialunitspecimen->{'HasDied'};

        if (length($has_died) > 0 && (!($has_died =~ /^[0|1]$/))) {

          my $err_msg = "HasDied ($has_died) can be either 1 or 0 only.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return 1;
        }
      }

      my ($is_geno_ok, $trouble_geno_id_aref) = check_permission($dbh_k_write, 'genotype', 'GenotypeId',
                                                                \@geno_id_list, $group_id, $gadmin_status,
                                                                $LINK_PERM);

      if (!$is_geno_ok) {

        my $trouble_geno_id_str = join(',', @{$trouble_geno_id_aref});

        my $perm_err_msg = '';
        $perm_err_msg   .= "Permission denied: Group ($group_id) and Genotype ($trouble_geno_id_str).";

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $perm_err_msg}]};

        return 1;
      }
    }

    my $dbh_k_read = connect_kdb_read();

    $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength, FactorValidRuleErrMsg, FactorValidRule  ";
    $sql   .= "FROM factor ";
    $sql   .= "WHERE TableNameOfFactor='trialunitfactor'";

    my $vcol_data = $dbh_k_read->selectall_hashref($sql, 'FactorId');

    my $vcol_param_data = {};
    my $vcol_len_info   = {};
    my $vcol_param_data_maxlen = {};
    my $pre_validate_vcol = {};

    for my $vcol_id (keys(%{$vcol_data})) {

      my $vcol_param_name = "VCol_${vcol_id}";

      $vcol_len_info->{$vcol_param_name} = $vcol_data->{$vcol_id}->{'FactorValueMaxLength'};

      $pre_validate_vcol->{$vcol_param_name} = {
        'Rule' => $vcol_data->{$vcol_id}->{'FactorValidRule'},
        'FactorId'=> $vcol_id,
        'RuleErrorMsg'=> $vcol_data->{$vcol_id}->{'FactorValidRuleErrMsg'},
        'CanFactorHaveNull' => $vcol_data->{$vcol_id}->{'CanFactorHaveNull'}
      };
    }
    #based on the vcol object above, we apply the values based on the input and try to validate and return an error per row.
    #this should be improved so that all trial unit errors are returned at once.

     for my $trialunit (@{$trialunit_info_aref}) {

      my $factor_aref = $trialunit->{'trialunitfactor'};
     
      my $vcol_error_aref = [];
    
      for my $factor_href (@{$factor_aref}) {

        my $vcol_id = $factor_href->{'FactorId'};
        my $vcol_value = $factor_href->{'FactorValue'};

        my $vcol_param_name = "VCol_${vcol_id}";

        $self->logger->debug("$vcol_param_name => $vcol_value");

        $vcol_len_info->{$vcol_param_name} = $vcol_data->{$vcol_id}->{'FactorValueMaxLength'};
        $vcol_param_data_maxlen->{$vcol_param_name} = $vcol_value;

        if ($vcol_data->{$vcol_id}->{'CanFactorHaveNull'} != 1) {
          $vcol_param_data->{$vcol_param_name} = $vcol_value;
        }

        $pre_validate_vcol->{$vcol_param_name}->{'Value'} = $vcol_value;
      }

      my ($vcol_missing_err, $vcol_missing_href) = check_missing_href( $vcol_param_data );

      if ($vcol_missing_err) {

        push(@{$trial_unit_err_aref},$vcol_missing_href);
        $trial_unit_err = 1;
      }

      my ($vcol_maxlen_err, $vcol_maxlen_href) = check_maxlen_href($vcol_param_data_maxlen, $vcol_len_info);

      if ($vcol_maxlen_err) {

        push(@{$trial_unit_err_aref},$vcol_maxlen_href);
        $trial_unit_err = 1;
      }

      my ($vcol_error, $vcol_error_aref) = validate_all_factor_input($pre_validate_vcol);

      if ($vcol_error) {

        push(@{$trial_unit_err_aref}, @{$vcol_error_aref});
        $trial_unit_err = 1;
      }

      if ($trial_unit_err) {

        push(@{$trial_unit_err_aref}, {'Message' => "VCol Errors in bulk add."});
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => $trial_unit_err_aref};

        return 1;
      }

    }


  
    $dbh_k_read->disconnect();

    # optimisation starts from here. the optimisation will use TrialUnitBarcode as the key for mapping
    # the data in memory to the record id inserted into the database after SQL bulk insert. The mapping is
    # used for trialunitspecimen and triallocation. Since TrialUnitBarcode is not compulsory, DAL will generate
    # temporary TrialUnitBarcodes if they are not provided in the trialunit data.

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

    $year = sprintf("%02d", $year % 100);
    $yday = sprintf("%03d", $yday);

    my $user_id  = sprintf("%02d", $self->authen->user_id());

    my @big_a_z_chars = ("A" .. "Z");

    my $rand3 = $big_a_z_chars[rand(26)] . $big_a_z_chars[rand(26)] . int(rand(10));

    my $dal_tmp_tu_barcode_prefix = qq|TU_${user_id}_${year}${yday}${hour}${min}${sec}_${rand3}_|;

    my @dimension_field_list;

    for my $dimension (@dimension_list) {

      push(@dimension_field_list, "TrialUnit${dimension}");
    }

    my $bulk_sql = 'INSERT INTO trialunit ';
    $bulk_sql   .= '(TrialId,SourceTrialUnitId,ReplicateNumber,TrialUnitBarcode,TrialUnitNote,SampleSupplierID,';
    $bulk_sql   .= join(',', @dimension_field_list) . ') VALUES ';

    my @tu_sql_rec_list;

    for (my $i = 0; $i < scalar(@{$trialunit_info_aref}); $i++) {

      my $trialunit_rec       = $trialunit_info_aref->[$i];

      my $replicate_number    = $trialunit_rec->{'ReplicateNumber'};
      my $trial_unit_comment  = $trialunit_rec->{'TrialUnitNote'};
      my $sample_supplier_id  = $trialunit_rec->{'SampleSupplierId'};

      my $src_trial_unit_id   = 'NULL';

      if (length($trialunit_rec->{'SourceTrialUnitId'}) > 0) {

        $src_trial_unit_id   = $trialunit_rec->{'SourceTrialUnitId'};
      }

      my $treatment_id        = 'NULL';

      if (length($trialunit_rec->{'TreatmentId'}) > 0) {

        $treatment_id = $trialunit_rec->{'TreatmentId'};
      }

      my @sql_dimension_list;

      for my $dimension (@dimension_list) {

        if (length($trialunit_rec->{"TrialUnit${dimension}"}) > 0) {

          my $dimension_val = $trialunit_rec->{"TrialUnit${dimension}"};

          if ($dimension_val !~ /^\d+$/) {

            $dimension_val = $dbh_k_write->quote($dimension_val);
          }

          push(@sql_dimension_list, $dimension_val);
        }
        else {

          push(@sql_dimension_list, 'NULL');
        }
      }

      my $tu_barcode = $dal_tmp_tu_barcode_prefix . $i;

      if (length($trialunit_rec->{'TrialUnitBarcode'}) == 0) {

        $trialunit_rec->{'TrialUnitBarcode'} = $tu_barcode;
        $trialunit_rec->{'RemoveBarcode'}    = 1;
      }
      else {

        $tu_barcode = $trialunit_rec->{'TrialUnitBarcode'};
        $trialunit_rec->{'RemoveBarcode'}    = 0;
      }

      # Issue9468
      my $tu_sql_rec_str = qq|(${trial_id},${src_trial_unit_id},${replicate_number},'${tu_barcode}','${trial_unit_comment}',${sample_supplier_id},|;
      # my $tu_sql_rec_str = qq|(${trial_id},${treatment_id},${src_trial_unit_id},${replicate_number},'${tu_barcode}','${trial_unit_comment}',${sample_supplier_id},|;
      $tu_sql_rec_str   .= join(',', @sql_dimension_list) . ')';

      $self->logger->debug("Trial Unit Rec SQL: $tu_sql_rec_str");

      push(@tu_sql_rec_list, $tu_sql_rec_str);

      $trialunit_info_aref->[$i] = $trialunit_rec;
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

      $self->logger->debug("Add trialunit in bulk failed");
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

    $sql  = 'SELECT TrialUnitId, TrialUnitBarcode FROM trialunit ';
    $sql .= "WHERE $before_clause AND $after_clause";

    $self->logger->debug("SQL: $sql");

    $sth = $dbh_k_write->prepare($sql);
    $sth->execute();

    if ($dbh_k_write->err()) {

      $self->logger->debug("Read TrialUnit in between before and after BULK insert");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return 1;
    }

    my $barcode2id_href = $sth->fetchall_hashref('TrialUnitBarcode');

    if ($sth->err()) {

      $self->logger->debug("Read TrialUnit rec into hash lookup in between before and after BULK insert");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return 1;
    }

    for (my $i = 0; $i < scalar(@{$trialunit_info_aref}); $i++) {

      my $trialunit  = $trialunit_info_aref->[$i];
      my $tu_barcode = $trialunit->{'TrialUnitBarcode'};

      if (!(defined $barcode2id_href->{$tu_barcode})) {

        $self->logger->debug("Missing TrialUnit barcode lookup");
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

        return 1;
      }

      my $tu_id = $barcode2id_href->{$tu_barcode}->{'TrialUnitId'};

      $self->logger->debug("Barcode: $tu_barcode - ID: $tu_id");

      $trialunit->{'TrialUnitId'} = $tu_id;

      $trialunit_info_aref->[$i] = $trialunit;
    }

    $bulk_sql  = 'INSERT INTO trialunitspecimen';
    $bulk_sql .= '(TrialUnitId,SpecimenId,ItemId,PlantDate,HarvestDate,HasDied,Notes,SpecimenNumber,TUSLabel) ';
    $bulk_sql .= 'VALUES';

    my $tu_loc_bulk_sql = 'INSERT INTO trialunitloc (trialunitid, trialunitlocation, trialunitlocdt, currentloc) VALUES';

    my @tu_spec_sql_list;
    my @tu_loc_sql_list;

    my $current_dt_pg = DateTime::Format::Pg->parse_datetime(DateTime->now());

    foreach my $trialunit (@{$trialunit_info_aref}) {

      my $trialunit_id        = $trialunit->{'TrialUnitId'};
      my $trialunit_location  = $trialunit->{'trialunitlocation'};

      my $tu_specimen_aref = $trialunit->{'trialunitspecimen'};

      for my $trialunitspecimen (@{$tu_specimen_aref}) {

        my $specimen_id  = $trialunitspecimen->{'SpecimenId'};

        my $spec_num = 0;

        if (defined $trialunitspecimen->{'SpecimenNumber'}) {

          if (length($trialunitspecimen->{'SpecimenNumber'}) > 0) {

            $spec_num = $trialunitspecimen->{'SpecimenNumber'};
          }
        }

        my $item_id      = 'NULL';
        my $plant_date   = 'NULL';
        my $harvest_date = 'NULL';
        my $has_died     = 'NULL';
        my $notes        = 'NULL';
        my $tus_label    = 'NULL';

        if (defined $trialunitspecimen->{'ItemId'}) {

          if ( length($trialunitspecimen->{'ItemId'}) > 0 ) {

            $item_id = $trialunitspecimen->{'ItemId'};
          }
        }

        if (defined $trialunitspecimen->{'PlantDate'}) {

          if ( length($trialunitspecimen->{'PlantDate'}) > 0 ) {

            $plant_date = $dbh_k_write->quote($trialunitspecimen->{'PlantDate'});
          }
        }

        if (defined $trialunitspecimen->{'HarvestDate'}) {

          if ( length($trialunitspecimen->{'HarvestDate'}) > 0 ) {

            $harvest_date = $dbh_k_write->quote($trialunitspecimen->{'HarvestDate'});
          }
        }

        if (defined $trialunitspecimen->{'HasDied'}) {

          if ( length($trialunitspecimen->{'HasDied'}) > 0 ) {

            $has_died = $trialunitspecimen->{'HasDied'};
          }
        }

        if (defined $trialunitspecimen->{'Notes'}) {

          if ( length($trialunitspecimen->{'Notes'}) > 0 ) {

            $notes = $dbh_k_write->quote($trialunitspecimen->{'Notes'});
          }
        }

        if (defined $trialunitspecimen->{'TUSLabel'}) {

          if ( length($trialunitspecimen->{'TUSLabel'}) > 0 ) {

            $tus_label = $dbh_k_write->quote($trialunitspecimen->{'TUSLabel'});
          }
        }

        my $tu_spec_rec_str = qq|(${trialunit_id},${specimen_id},${item_id},${plant_date},${harvest_date},${has_died},${notes},${spec_num},${tus_label})|;

        push(@tu_spec_sql_list, $tu_spec_rec_str);
      }

      if (length($trialunit_location) > 0) {

        my $tu_loc_sql_str = qq|(${trialunit_id},ST_ForceCollection(ST_GeomFromText('$trialunit_location', -1)), '${current_dt_pg}', 1)|;

        push(@tu_loc_sql_list, $tu_loc_sql_str);
      }
    }

    if (scalar(@tu_spec_sql_list) > 0) {

      $bulk_sql .= join(',', @tu_spec_sql_list);

      $sth = $dbh_k_write->prepare($bulk_sql);
      $sth->execute();

      if ($dbh_k_write->err()) {

        $self->logger->debug("INSERT TrialUnitSpecimen BULK failed");
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

        return 1;
      }

      $sth->finish();
    }

    if (scalar(@tu_loc_sql_list) > 0) {

      $tu_loc_bulk_sql .= join(',', @tu_loc_sql_list);

      $self->logger->debug("TU LOC SQL: $tu_loc_bulk_sql");

      $sth = $dbh_gis_write->prepare($tu_loc_bulk_sql);
      $sth->execute();

      if ($dbh_gis_write->err()) {

        $self->logger->debug("INSERT trialunitlocation BULK failed");
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

        return 1;
      }

      $sth->finish();
    }

    my @remove_tu_bar_tu_id;

    foreach my $trialunit (@{$trialunit_info_aref}) {

      if ($trialunit->{'RemoveBarcode'} == 1) {

        push(@remove_tu_bar_tu_id, $trialunit->{'TrialUnitId'});
      }
    }

    if (scalar(@remove_tu_bar_tu_id) > 0) {

      $sql = 'UPDATE trialunit SET TrialUnitBarcode=NULL WHERE TrialUnitId IN (' . join(',', @remove_tu_bar_tu_id) . ')';

      $sth = $dbh_k_write->prepare($sql);
      $sth->execute();

      if ($dbh_k_write->err()) {

        $self->logger->debug("Remove DAL temporary TrialUnitBarcode failed");
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

        return 1;
      }

      $sth->finish();
    }
    
    $bulk_sql = 'INSERT INTO trialunittreatment';
    $bulk_sql .= '(TreatmentId, TrialUnitId) ';
    $bulk_sql .= 'VALUES';

    my @tut_sql_list;

    foreach my $trialunit (@{$trialunit_info_aref}) {

        my $treatment_id = $trialunit->{'TreatmentId'};
        my $trialunit_id = $trialunit->{'TrialUnitId'};

        if (length($treatment_id) > 0) {
            my $tut_sql_str = qq|($treatment_id, $trialunit_id)|;
            push(@tut_sql_list, $tut_sql_str);
        }
    }

    if (scalar(@tut_sql_list) > 0) {
        $bulk_sql .= join(',', @tut_sql_list);
        $sth = $dbh_k_write->prepare($bulk_sql);
        $sth->execute();
        if ($dbh_k_write->err()) {
            $self->logger->debug("INSERT TrialUnitTreatment BULK failed");
            $data_for_postrun_href->{'Error'} = 1;
            $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};
            return 1;
        }
        $sth->finish();
    }

    $dbh_k_write->commit;

    $sql  = 'INSERT INTO trialunitfactor';
    $sql .= '(TrialUnitId, FactorId, FactorValue) ';
    $sql .= 'VALUES';

    my @tu_factor_sql_list;

    for my $trialunit (@{$trialunit_info_aref}) {

      my $trialunit_id = $trialunit->{'TrialUnitId'};

      my $factor_aref = $trialunit->{'trialunitfactor'};

      for my $factor_href (@{$factor_aref}) {
        my $factor_id = $factor_href->{'FactorId'};
        my $factor_value = $factor_href->{'FactorValue'};

        if (length($factor_value) > 0) {
          my $tut_sql_str = qq|(${trialunit_id}, ${factor_id}, '${factor_value}')|;
          push(@tu_factor_sql_list, $tut_sql_str);
        }
      }
     

     
    }

    if (scalar(@tu_factor_sql_list) > 0) {
      $sql .= join(',', @tu_factor_sql_list);

      $sth = $dbh_k_write->prepare($sql);
      $sth->execute();

      if ($dbh_k_write->err()) {
          $self->logger->debug("INSERT trialunitfactor BULK failed");
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};
          return 1;
      }
      $sth->finish();
    }

    $dbh_k_write->commit;

    my $nb_added_trial_unit = scalar(@{$trialunit_info_aref});
    my $info_msg = "$nb_added_trial_unit TrialUnits for Trial ($trial_id) have been added successfully.";

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
  $dbh_gis_write->disconnect;
  return $data_for_postrun_href;
}

sub list_site {

  my $self              = $_[0];
  my $extra_attr_yes    = $_[1];
  my $field_list        = $_[2];
  my $sql               = $_[3];
  my $where_para_aref   = [];

  if (defined $_[4]) {

    $where_para_aref   = $_[4];
  }

  my $err = 0;
  my $msg = '';

  my $data_aref = [];

  my $dbh = connect_kdb_read();

  ($err, $msg, $data_aref) = read_data($dbh, $sql, $where_para_aref);

  if ($err) {

    return ($err, $msg, {});
  }

  my $field_list_loc_href = {};

  for my $field (@{$field_list}) {

    if ($field eq 'Longitude' || $field eq 'Latitude' || $field eq 'LCol*' || $field eq 'sitelocation') {

      $field_list_loc_href->{$field} = 1;
    }
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $site_loc_gis = {};

  my $site_id_aref = [];

  for my $row (@{$data_aref}) {

    push(@{$site_id_aref}, $row->{'SiteId'});
  }

  if (scalar(keys(%{$field_list_loc_href})) > 0) {

    if (scalar(@{$site_id_aref}) > 0) {

      my $dbh_gis = connect_gis_read();

      my $gis_where = 'WHERE siteid IN (' . join(',', @{$site_id_aref}) . ') AND currentloc = 1';

      my $siteloc_sql = 'SELECT siteid, sitelocdt, description, ST_AsText(sitelocation) AS sitelocation, ';
      $siteloc_sql   .= 'ST_AsText(ST_Centroid(geometry(sitelocation))) AS sitecentroid ';
      $siteloc_sql   .= 'FROM siteloc ';
      $siteloc_sql   .= $gis_where;

      $self->logger->debug("siteloc_sql: $siteloc_sql");

      my $sth_gis = $dbh_gis->prepare($siteloc_sql);
      $sth_gis->execute();

      if (!$dbh_gis->err()) {

        my $gis_href = $sth_gis->fetchall_hashref('siteid');

        if (!$sth_gis->err()) {

          $site_loc_gis = $gis_href;
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

      $dbh_gis->disconnect();
    }
  }

  $dbh->disconnect();
  my $site_loc_gis_count = scalar(keys(%{$site_loc_gis}));
  $self->logger->debug("GIS site loc count: $site_loc_gis_count");

  my @extra_attr_site_data;

  my $chk_id_err        = 0;
  my $chk_id_msg        = '';
  my $used_id_href      = {};
  my $not_used_id_href  = {};

  if ($extra_attr_yes) {

    if (scalar(@{$site_id_aref}) > 0) {

      my $chk_table_aref = [{'TableName' => 'trial', 'FieldName' => 'SiteId'}];

      ($chk_id_err, $chk_id_msg,
       $used_id_href, $not_used_id_href) = id_existence_bulk($dbh, $chk_table_aref, $site_id_aref);

      if ($chk_id_err) {

        $self->logger->debug("Check id existence error: $chk_id_msg");
        $err = 1;
        $msg = $chk_id_msg;

        return ($err, $msg, []);
      }

    }
  }

  for my $site_row (@{$data_aref}) {

    my $site_id       = $site_row->{'SiteId'};
    my $site_centroid = $site_loc_gis->{$site_id}->{'sitecentroid'};

    $site_centroid    =~ /POINT\((.+) (.+)\)/;
    my $longitude     = $1;
    my $latitude      = $2;

    if ($field_list_loc_href->{'LCol*'} || $field_list_loc_href->{'Longitude'}) {

      $site_row->{'Longitude'} = $longitude;
    }

    if ($field_list_loc_href->{'LCol*'} || $field_list_loc_href->{'Latitude'}) {

      $site_row->{'Latitude'}  = $latitude;
    }

    if ($field_list_loc_href->{'LCol*'} || $field_list_loc_href->{'sitelocation'}) {

      $site_row->{'sitelocation'} = $site_loc_gis->{$site_id}->{'sitelocation'};
    }

    $site_row->{'sitelocdt'} = $site_loc_gis->{$site_id}->{'sitelocdt'};

    $site_row->{'sitelocdescription'} = $site_loc_gis->{$site_id}->{'description'};

    if ($extra_attr_yes) {

      if ($gadmin_status eq '1') {

        $site_row->{'update'} = "update/site/$site_id";

        if ( $not_used_id_href->{$site_id} ) {

          $site_row->{'delete'}   = "delete/site/$site_id";
        }
      }
    }

    push(@extra_attr_site_data, $site_row);
  }

  return ($err, $msg, \@extra_attr_site_data);
}

sub get_site_full_runmode {

=pod get_site_HELP_START
{
"OperationName": "Get site",
"Description": "Get detailed information about the site specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Site SiteStartDate='' delete='delete/site/18' CurrentSiteManagerId='41' SiteTypeName='SiteType - 22416809916' update='update/site/18' sitelocation='MULTIPOLYGON(((149.05803801025291 -35.28275454804866,149.06078459228328 -35.315257984493236,149.12120939696936 -35.31637855978221,149.05803801025291 -35.28275454804866)))' sitelocdt='2023-04-11 05:19:52' SiteAcronym='GH' Latitude='-35.3047970307747' SiteTypeId='46' SiteEndDate='' CurrentSiteManagerName='Testing User-25644445488' SiteId='18' SiteName='DArT Test Site' sitelocdescription='' Longitude='149.08001066650183'/></DATA>",
"SuccessMessageJSON": "{'VCol' : [],'Site' : [{ 'SiteName' : 'DArT Test Site', 'sitelocdescription' : '', 'Longitude' : '149.08001066650183', 'CurrentSiteManagerName' : 'Testing User-25644445488', 'SiteId' : 18, 'update' : 'update/site/18', 'Latitude' : '-35.3047970307747', 'SiteAcronym' : 'GH', 'sitelocdt' : '2023-04-11 05:19:52', 'sitelocation' : 'MULTIPOLYGON(((149.05803801025291 -35.28275454804866,149.06078459228328 -35.315257984493236,149.12120939696936 -35.31637855978221,149.05803801025291 -35.28275454804866)))', 'SiteEndDate' : null, 'SiteTypeId' : 46, 'delete' : 'delete/site/18', 'SiteStartDate' : null, 'CurrentSiteManagerId' : 41, 'SiteTypeName' : 'SiteType - 22416809916' }],'RecordMeta' : [{'TagName' : 'Site'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Site (20) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Site (20) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SiteId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self    = shift;
  my $site_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();
  my $site_exist = record_existence($dbh, 'site', 'SiteId', $site_id);

  if (!$site_exist) {

    my $err_msg = "Site ($site_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $field_list = ['site.*', 'generaltype.TypeName AS SiteTypeName', 'VCol*', 'LCol*',
                    "concat(contact.ContactFirstName, concat(' ', contact.ContactLastName)) As CurrentSiteManagerName"];

  my $other_join = ' LEFT JOIN generaltype ON site.SiteTypeId = generaltype.TypeId ';
  $other_join   .= ' LEFT JOIN contact ON site.CurrentSiteManagerId = contact.ContactId ';

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $field_list, 'site',
                                                                        'SiteId', $other_join);
  $dbh->disconnect();

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql   .= ' HAVING SiteId=?';

  $self->logger->debug("SQL with VCol: $sql");

  my ($read_site_err, $read_site_msg, $site_data) = $self->list_site(1, $field_list, $sql, [$site_id]);

  if ($read_site_err) {

    $self->logger->debug($read_site_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'geojson'}   = 1;
  $data_for_postrun_href->{'GJSonInfo'} = {'GeometryField' => 'sitelocation',
                                           'FeatureName'   => 'SiteName [ id: SiteId ]',
                                           'FeatureId'     => 'SiteId',
  };
  $data_for_postrun_href->{'Data'}      = {'Site'       => $site_data,
                                           'VCol'       => $vcol_list,
                                           'RecordMeta' => [{'TagName' => 'Site'}],
  };

  return $data_for_postrun_href;
}

sub update_site_runmode {

=pod update_site_gadmin_HELP_START
{
"OperationName": "Update site",
"Description": "Update information about the site using specified id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "site",
"KDDArTFactorTable": "sitefactor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Site (1) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Site (1) has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Site (20) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Site (20) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SiteId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self    = shift;
  my $site_id = $self->param('id');
  my $query   = $self->query();

  my $data_for_postrun_href = {};
  my $site_err = 0;
  my $site_err_aref = [];

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'site', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $dbh_k_read = connect_kdb_read();

  my $site_exist = record_existence($dbh_k_read, 'site', 'SiteId', $site_id);

  if (!$site_exist) {

    my $err_msg = "Site ($site_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $site_name          = $query->param('SiteName');
  my $sitetype_id        = $query->param('SiteTypeId');
  my $site_acronym       = $query->param('SiteAcronym');
  my $cur_manager_id     = $query->param('CurrentSiteManagerId');

  my $read_site_sql      =  'SELECT SiteStartDate, SiteEndDate ';
     $read_site_sql     .=  'FROM site WHERE SiteId=? ';

  my ($r_df_val_err, $r_df_val_msg, $site_df_val_data) = read_data($dbh_k_read, $read_site_sql, [$site_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve site default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $site_sdate    =  undef;
  my $site_edate    =  undef;

  my $nb_df_val_rec    =  scalar(@{$site_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve site default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $site_sdate    =   $site_df_val_data->[0]->{'SiteStartDate'};
  $site_edate    =   $site_df_val_data->[0]->{'SiteEndDate'};


  if (defined $query->param('SiteStartDate')) {
    if (length($query->param('SiteStartDate')) > 0) {
      $site_sdate         = $query->param('SiteStartDate');
      my ($sdate_err, $sdate_msg) = check_dt_value( {'SiteStartDate' => $site_sdate} );

      if ($sdate_err) {

        my $err_msg = "$sdate_msg not date/time.";

        push(@{$site_err_aref}, {'Message' => $err_msg});
        $site_err = 1;
      }
    }
  }

  # Unknown Start DateTime value from database 0000-00-00 00:00:00 which should be reset to undef,
  # and then null in the db

  if ($site_sdate eq '0000-00-00 00:00:00') {

    $site_sdate = undef;
  }

  if (length($site_sdate) == 0) {

    $site_sdate = undef;
  }


  if (defined $query->param('SiteEndDate')) {

    if (length($query->param('SiteEndDate')) > 0) {
      $site_edate         = $query->param('SiteEndDate');
      my ($edate_err, $edate_msg) = check_dt_value( {'SiteEndDate' => $site_edate} );

      if ($edate_err) {

        my $err_msg = "$edate_msg not date/time.";

        push(@{$site_err_aref}, {'Message' => $err_msg});
        $site_err = 1;
      }
    }


  }

  # Unknown End DateTime value from database 0000-00-00 00:00:00 which should be reset to undef,
  # and then null in the db

  if ($site_edate eq '0000-00-00 00:00:00') {

    $site_edate = undef;
  }

  if (length($site_edate) == 0) {

    $site_edate = undef;
  }

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength, FactorValidRuleErrMsg, FactorValidRule  ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='sitefactor'";


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
      'CanFactorHaveNull' => $vcol_data->{$vcol_id}->{'CanFactorHaveNull'}
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

  my $sitetype_existence = type_existence($dbh_k_read, 'site', $sitetype_id);

  if (!$sitetype_existence) {

    my $err_msg = "SiteType ($sitetype_id) does not exist.";
 
    push(@{$site_err_aref}, {'SiteTypeId' => $err_msg});
    $site_err = 1;
  }

  my $cur_manager_existence = record_existence($dbh_k_read, 'contact', 'ContactId', $cur_manager_id);

  if (!$cur_manager_existence) {

    my $err_msg = "CurrentManager ($cur_manager_id) does not exist.";

    push(@{$site_err_aref}, {'SiteTypeId' => $err_msg});
    $site_err = 1;
  }

  #prevalidate values to be finished in later version

  my ($vcol_error, $vcol_error_aref) = validate_all_factor_input($pre_validate_vcol);

  if ($vcol_error) {
    push(@{$site_err_aref}, @{$vcol_error_aref});
    $site_err = 1;
  }

  if ($site_err != 0) {
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => $site_err_aref};
    return $data_for_postrun_href;
  }


  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  $sql  = 'UPDATE site SET ';
  $sql .= 'SiteName=?, ';
  $sql .= 'SiteTypeId=?, ';
  $sql .= 'SiteAcronym=?, ';
  $sql .= 'CurrentSiteManagerId=?, ';
  $sql .= 'SiteStartDate=?, ';
  $sql .= 'SiteEndDate=? ';
  $sql .= 'WHERE SiteId=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($site_name, $sitetype_id, $site_acronym,
                $cur_manager_id, $site_sdate, $site_edate, $site_id);

  if ($dbh_k_write->err()) {

    $self->logger->debug("Update site failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  my $vcol_error = [];

  for my $vcol_id (keys(%{$vcol_data})) {

    if (defined $query->param('VCol_' . "$vcol_id")) {

      my $factor_value = $query->param('VCol_' . "$vcol_id");

      my ($vcol_err, $vcol_msg) = update_factor_value($dbh_k_write, $vcol_id, $factor_value, 'sitefactor', 'SiteId', $site_id);

      if ($vcol_err) {

        $self->logger->debug("VCol_" . "$vcol_id => $vcol_msg" );

        push(@{$site_err_aref}, {'VCol_' . "$vcol_id" => $vcol_msg});

        $site_err = 1;
      }
    }
  }

  if ($site_err != 0) {
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => $site_err_aref};
    return $data_for_postrun_href;
  }


  $dbh_k_write->disconnect();

  my $info_msg_aref = [{'Message' => "Site ($site_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_site_geography_runmode {

=pod update_site_geography_gadmin_HELP_START
{
"OperationName": "Update site location",
"Description": "Update site's geographical location.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Site (1) location has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Site (1) location has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Site (20) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Site (20) not found.'}]}"}],
"HTTPParameter": [{"Name": "sitelocation", "DataType": "polygon_wkt", "Description": "GIS field defining the polygon geometry object of the site in a standard GIS well-known text.", "Type": "LCol", "Required": "1"},{"Name": "sitelocdt", "DataType": "timestamp", "Description": "DateTime of site location", "Type": "LCol", "Required": "0"},{"Name": "currentloc", "DataType": "tinyint", "Description": "Flag to notify current location", "Type": "LCol", "Required": "0"},{"Name": "description", "DataType": "varchar", "Description": "Description for location", "Type": "LCol", "Required": "0"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SiteId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self    = shift;
  my $site_id = $self->param('id');
  my $query   = $self->query();

  my $data_for_postrun_href = {};

  my $dbh_k_read = connect_kdb_read();
  my $site_exist = record_existence($dbh_k_read, 'site', 'SiteId', $site_id);
  $dbh_k_read->disconnect();

  if (!$site_exist) {

    my $err_msg = "Site ($site_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sub_PGIS_val_builder = sub {
    my $wkt = shift;
    my $st_buffer_val = $POINT2POLYGON_BUFFER4SITE->{$ENV{DOCUMENT_ROOT}};
    if ($wkt =~ /^POINT/i) {
      return "ST_Multi(ST_Buffer(ST_GeomFromText(?, -1), $st_buffer_val, 1))";
    } else {
      return "ST_Multi(ST_GeomFromText(?, -1))";
    }
  };

  my ($err, $err_msg) = append_geography_loc(
                                              "site",
                                              $site_id,
                                              ['POINT', 'POLYGON', 'MULTIPOLYGON'],
                                              $query,
                                              $sub_PGIS_val_builder,
                                              $self->logger,
                                            );

  if ($err) {
    $data_for_postrun_href = $self->_set_error($err_msg);
  } else {
    my $info_msg_aref = [{'Message' => "Site ($site_id) location has been updated successfully."}];
    $data_for_postrun_href->{'Error'}     = 0;
    $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
    $data_for_postrun_href->{'ExtraData'} = 0;
  }

  return $data_for_postrun_href;
}

sub list_designtype {

  my $self           = shift;
  my $extra_attr_yes = shift;
  my $sql            = shift;

  my $count = 0;
  while ($sql =~ /\?/g) {

    $count += 1;
  }

  if ( scalar(@_) != $count ) {

    my $msg = 'Number of arguments does not match with ';
    $msg   .= 'number of SQL parameter.';
    return (1, $msg, []);
  }

  my $dbh = connect_kdb_read();
  my $sth = $dbh->prepare($sql);
  # parameters provided by the caller
  # for example, ('WHERE FieldA=?', '1')
  $sth->execute(@_);

  my $err = 0;
  my $msg = '';
  my $designtype_data = [];

  if ( !$dbh->err() ) {

    my $array_ref = $sth->fetchall_arrayref({});

    if ( !$sth->err() ) {

      $designtype_data = $array_ref;
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
  $dbh->disconnect();

  my $extra_attr_designtype_data = [];

  my $gadmin_status = $self->authen->gadmin_status();

  if ($extra_attr_yes && ($gadmin_status eq '1')) {

    my $designtype_id_aref = [];

    for my $row (@{$designtype_data}) {

      push(@{$designtype_id_aref}, $row->{'DesignTypeId'});
    }

    my $chk_id_err        = 0;
    my $chk_id_msg        = '';
    my $used_id_href      = {};
    my $not_used_id_href  = {};

    if (scalar(@{$designtype_id_aref}) > 0) {

      my $chk_table_aref = [{'TableName' => 'trial', 'FieldName' => 'DesignTypeId'}];

      ($chk_id_err, $chk_id_msg,
       $used_id_href, $not_used_id_href) = id_existence_bulk($dbh, $chk_table_aref, $designtype_id_aref);

      if ($chk_id_err) {

        $self->logger->debug("Check id existence error: $chk_id_msg");
        $err = 1;
        $msg = $chk_id_msg;

        return ($err, $msg, []);
      }
    }

    for my $row (@{$designtype_data}) {

      my $designtype_id = $row->{'DesignTypeId'};
      $row->{'update'}   = "update/designtype/$designtype_id";

      if ($not_used_id_href->{$designtype_id}) {

        $row->{'delete'}   = "delete/designtype/$designtype_id";
      }

      push(@{$extra_attr_designtype_data}, $row);
    }
  }
  else {

    $extra_attr_designtype_data = $designtype_data;
  }

  return ($err, $msg, $extra_attr_designtype_data);
}

sub list_designtype_runmode {

=pod list_designtype_HELP_START
{
"OperationName": "List design types",
"Description": "List all available trial design types in the system. This listing does not require pagination information.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><DesignType DesignTypeId='1' DesignTemplateFile='none' DesignFactorAliasPrefix='DiG' DesignGenotypeFormat='normal' DesignSoftware='Optimal Trial Design' DesignTypeName='Traditional - 6815031' delete='delete/designtype/1' update='update/designtype/1' /><RecordMeta TagName='DesignType' /></DATA>",
"SuccessMessageJSON": "{'DesignType' : [{'DesignTypeId' : '1','DesignTemplateFile' : 'none','DesignFactorAliasPrefix' : 'DiG','DesignGenotypeFormat' : 'normal','DesignSoftware' : 'Optimal Trial Design','DesignTypeName' : 'Traditional - 6815031','delete' : 'delete/designtype/1','update' : 'update/designtype/1'}],'RecordMeta' : [{'TagName' : 'DesignType'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = shift;

  my $data_for_postrun_href = {};

  my $msg = '';

  my $sql = 'SELECT * ';
  $sql   .= 'FROM designtype ';
  $sql   .= 'ORDER BY DesignTypeId DESC';

  my ($designtype_err, $designtype_msg, $designtype_data) = $self->list_designtype(1, $sql);

  if ($designtype_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'DesignType' => $designtype_data,
                                           'RecordMeta' => [{'TagName' => 'DesignType'}],
  };

  return $data_for_postrun_href;
}

sub get_designtype_runmode {

=pod get_designtype_HELP_START
{
"OperationName": "Get design type",
"Description": "Get detailed information about trial design type specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><DesignType DesignTypeId='1' DesignTemplateFile='none' DesignFactorAliasPrefix='DiG' DesignGenotypeFormat='normal' DesignSoftware='Optimal Trial Design' DesignTypeName='Traditional - 6815031' delete='delete/designtype/1' update='update/designtype/1' /><RecordMeta TagName='DesignType' /></DATA>",
"SuccessMessageJSON": "{'DesignType' : [{'DesignTypeId' : '1','DesignTemplateFile' : 'none','DesignFactorAliasPrefix' : 'DiG','DesignGenotypeFormat' : 'normal','DesignSoftware' : 'Optimal Trial Design','DesignTypeName' : 'Traditional - 6815031','delete' : 'delete/designtype/1','update' : 'update/designtype/1'}],'RecordMeta' : [{'TagName' : 'DesignType'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing DesignTypeId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self          = shift;
  my $designtype_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $msg = '';

  my $dbh = connect_kdb_read();
  my $designtype_exist = record_existence($dbh, 'designtype', 'DesignTypeId', $designtype_id);
  $dbh->disconnect();

  if (!$designtype_exist) {

    my $err_msg = "DesignType ($designtype_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT * ';
  $sql   .= 'FROM designtype ';
  $sql   .= 'WHERE DesignTypeId=? ';
  $sql   .= 'ORDER BY DesignTypeId DESC';

  my ($designtype_err, $designtype_msg, $designtype_data) = $self->list_designtype(1, $sql, $designtype_id);

  if ($designtype_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'DesignType' => $designtype_data,
                                           'RecordMeta' => [{'TagName' => 'DesignType'}],
  };

  return $data_for_postrun_href;
}

sub update_designtype_runmode {

=pod update_designtype_gadmin_HELP_START
{
"OperationName": "Update design type",
"Description": "Update definition of the trial design type.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='DesignType (1) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'DesignType (1) has been updated successfully.'}]}",
"ErrorMessageXML": [{"NameAlreadyExists": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error DesignTypeName='DesignTypeName (Traditional): already exists.' /></DATA>"}],
"ErrorMessageJSON": [{"NameAlreadyExists": "{'Error' : [{'DesignTypeName' : 'DesignTypeName (Traditional): already exists.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing DesignTypeId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self          = shift;
  my $designtype_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $query = $self->query();

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'designtype', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $dbh = connect_kdb_read();
  my $designtype_exist = record_existence($dbh, 'designtype', 'DesignTypeId', $designtype_id);

  if (!$designtype_exist) {

    my $err_msg = "DesignType ($designtype_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $designtype_name                  = $query->param('DesignTypeName');

  my $chk_designtype_name_sql = 'SELECT DesignTypeId FROM designtype WHERE DesignTypeName=? AND DesignTypeId<>?';

  my ($read_err, $db_designtype_id) = read_cell($dbh, $chk_designtype_name_sql, [$designtype_name, $designtype_id]);

  if ($read_err) {

    $self->logger->debug("Check DesignTypeName failed");

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_designtype_id) > 0) {

    my $err_msg = "DesignTypeName ($designtype_name): already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'DesignTypeName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $read_sql     =  'SELECT DesignSoftware, DesignTemplateFile, DesignGenotypeFormat, DesignFactorAliasPrefix ';
     $read_sql    .=  'FROM designtype ';
     $read_sql    .=  'WHERE DesignTypeId=? ';

  my ($r_df_val_err, $r_df_val_msg, $design_df_val_data) = read_data($dbh, $read_sql, [$designtype_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve designtype default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $design_software            =  undef;
  my $design_template_file       =  undef;
  my $design_geno_format         =  undef;
  my $design_factor_alias_prefix =  undef;

  my $nb_df_val_rec      =  scalar(@{$design_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve designtype default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $design_software            =  $design_df_val_data->[0]->{'DesignSoftware'};
  $design_template_file       =  $design_df_val_data->[0]->{'DesignTemplateFile'};
  $design_geno_format         =  $design_df_val_data->[0]->{'DesignGenotypeFormat'};
  $design_factor_alias_prefix =  $design_df_val_data->[0]->{'DesignFactorAliasPrefix'};

  if (defined $query->param('DesignSoftware')) {

     $design_software = $query->param('DesignSoftware');
  }

  if (defined $query->param('DesignTemplateFile')) {

     $design_template_file = $query->param('DesignTemplateFile');
  }

  if (defined $query->param('DesignGenotypeFormat')) {

     $design_geno_format = $query->param('DesignGenotypeFormat');
  }


  if (defined $query->param('DesignFactorAliasPrefix')) {

     $design_factor_alias_prefix = $query->param('DesignFactorAliasPrefix');
  }


  $dbh->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $sql = 'UPDATE designtype SET ';
  $sql   .= 'DesignTypeName=?, ';
  $sql   .= 'DesignSoftware=?, ';
  $sql   .= 'DesignTemplateFile=?, ';
  $sql   .= 'DesignGenotypeFormat=?, ';
  $sql   .= 'DesignFactorAliasPrefix=? ';
  $sql   .= 'WHERE DesignTypeId=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($designtype_name, $design_software, $design_template_file,
                $design_geno_format, $design_factor_alias_prefix, $designtype_id,
      );

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();
  $dbh_k_write->disconnect();

  my $info_msg_aref = [{'Message' => "DesignType ($designtype_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_trial {

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

    if ($field eq 'Longitude' || $field eq 'Latitude' || $field eq 'LCol*' || $field eq 'triallocation') {

      $field_list_loc_href->{$field} = 1;
    }
  }

  my $trial_loc_gis = {};

  my @trial_id_list;

  for my $trial_rec (@{$data_aref}) {

    push(@trial_id_list, $trial_rec->{'TrialId'});
  }

  my $trait_count_href       = {};
  my $trialunit_count_href   = {};
  my $trait_value_count_href = {};
  my $trial_dimension_href   = {};
  my $trial_workflow_href    = {};
  my $trial_event_href       = {};
  my $crossing_count_href    = {};

  my $chk_id_err        = 0;
  my $chk_id_msg        = '';
  my $used_id_href      = {};
  my $not_used_id_href  = {};

  if ($extra_attr_yes) {

    $self->logger->debug("Number of trial id: " . scalar(@trial_id_list));
    $self->logger->debug("TrialID list: " . join(',', @trial_id_list));

    if (scalar(@trial_id_list) > 0) {

      my $trial_trait_sql = 'SELECT trial.TrialId, count(TraitId) AS NumOfTrait ';
      $trial_trait_sql   .= 'FROM trial LEFT JOIN trialtrait ON trial.TrialId = trialtrait.TrialId ';
      $trial_trait_sql   .= 'WHERE trial.TrialId IN (' . join(',', @trial_id_list) . ') ';
      $trial_trait_sql   .= 'GROUP BY TrialId ';

      my $sth_trial_trait = $dbh->prepare($trial_trait_sql);
      $sth_trial_trait->execute();

      if (!$dbh->err()) {

        my $count_href = $sth_trial_trait->fetchall_hashref('TrialId');

        if (!$sth_trial_trait->err()) {

          $trait_count_href = $count_href;
        }
        else {

          $err = 1;
          $msg = 'Unexpected error';
          $self->logger->debug('Err: ' . $dbh->errstr());
          return ($err, $msg, []);
        }
      }
      else {

        $err = 1;
        $msg = 'Unexpected error';
        $self->logger->debug('Err: ' . $dbh->errstr());
        return ($err, $msg, []);
      }
      $sth_trial_trait->finish();

      my $trial_unit_sql = 'SELECT trial.TrialId, count(TrialUnitId) AS NumOfTrialUnit ';
      $trial_unit_sql   .= 'FROM trial LEFT JOIN trialunit ON trial.TrialId = trialunit.TrialId ';
      $trial_unit_sql   .= 'WHERE trial.TrialId IN (' . join(',', @trial_id_list) . ') ';
      $trial_unit_sql   .= 'GROUP BY TrialId ';

      my $sth_trial_unit = $dbh->prepare($trial_unit_sql);
      $sth_trial_unit->execute();

      if (!$dbh->err()) {

        my $count_href = $sth_trial_unit->fetchall_hashref('TrialId');

        if (!$sth_trial_unit->err()) {

          $trialunit_count_href = $count_href;
        }
        else {

          $err = 1;
          $msg = 'Unexpected error';
          $self->logger->debug('Err: ' . $dbh->errstr());
          return ($err, $msg, []);
        }
      }
      else {

        $err = 1;
        $msg = 'Unexpected error';
        $self->logger->debug('Err: ' . $dbh->errstr());
        return ($err, $msg, []);
      }
      $sth_trial_unit->finish();

      my $crossing_sql = 'SELECT TrialId, count(CrossingId) AS NumOfCross ';
      $crossing_sql   .= 'FROM crossing ';
      $crossing_sql   .= 'WHERE TrialId IN (' . join(',', @trial_id_list) . ') ';
      $crossing_sql   .= 'GROUP BY TrialId';

      my $sth_crossing = $dbh->prepare($crossing_sql);
      $sth_crossing->execute();

      if (!$dbh->err()) {

        my $count_href = $sth_crossing->fetchall_hashref('TrialId');

        if (!$sth_crossing->err()) {

          $crossing_count_href = $count_href;
        }
        else {

          $err = 1;
          $msg = 'Unexpected error';
          $self->logger->debug('Err: ' . $dbh->errstr());
          return ($err, $msg, []);
        }
      }
      else {

        $err = 1;
        $msg = 'Unexpected error';
        $self->logger->debug('Err: ' . $dbh->errstr());
        return ($err, $msg, []);
      }
      $sth_crossing->finish();

      my $trait_value_sql = 'SELECT TrialId, count(TraitValue) AS NumOfTraitValue ';
      $trait_value_sql   .= 'FROM trialunit LEFT JOIN samplemeasurement ';
      $trait_value_sql   .= 'ON trialunit.TrialUnitId = samplemeasurement.TrialUnitId ';
      $trait_value_sql   .= 'WHERE TrialId IN (' . join(',', @trial_id_list) . ') ';
      $trait_value_sql   .= 'GROUP BY TrialId';

      my $sth_trait_val = $dbh->prepare($trait_value_sql);
      $sth_trait_val->execute();

      if (!$dbh->err()) {

        my $count_href = $sth_trait_val->fetchall_hashref('TrialId');

        if (!$sth_trait_val->err()) {

          $trait_value_count_href = $count_href;
        }
        else {

          $err = 1;
          $msg = 'Unexpected error';
          $self->logger->debug('Err: ' . $dbh->errstr());
          return ($err, $msg, []);
        }
      }
      else {

        $err = 1;
        $msg = 'Unexpected error';
        $self->logger->debug('Err: ' . $dbh->errstr());
        return ($err, $msg, []);
      }
      $sth_trait_val->finish();

      my $trial_dimension_sql = 'SELECT * FROM trialdimension WHERE TrialId IN (' . join(',', @trial_id_list) . ')';

      my $sth_trial_dimension = $dbh->prepare($trial_dimension_sql);
      $sth_trial_dimension->execute();

      if (!$dbh->err()) {

        my $trial_dimension_aref = $sth_trial_dimension->fetchall_arrayref({});

        if (!$sth_trial_dimension->err()) {

          for my $t_dimension_rec (@{$trial_dimension_aref}) {

            my $t_id = $t_dimension_rec->{'TrialId'};
            my $dimension_aref = [];

            if (defined($trial_dimension_href->{$t_id})) {

              $dimension_aref = $trial_dimension_href->{$t_id};
            }

            push(@{$dimension_aref}, $t_dimension_rec);

            $trial_dimension_href->{$t_id} = $dimension_aref;
          }
        }
        else {

          $err = 1;
          $msg = 'Unexpected error';
          $self->logger->debug('Err: ' . $dbh->errstr());
          return ($err, $msg, []);
        }
      }
      else {

        $err = 1;
        $msg = 'Unexpected error';
        $self->logger->debug('Err: ' . $dbh->errstr());
        return ($err, $msg, []);
      }

      my $trial_workflow_sql = 'SELECT * FROM trialworkflow WHERE TrialId IN (' . join(',', @trial_id_list) . ')';

      my $sth_trial_workflow = $dbh->prepare($trial_workflow_sql);
      $sth_trial_workflow->execute();

      if (!$dbh->err()) {

        my $trial_workflow_aref = $sth_trial_workflow->fetchall_arrayref({});

        if (!$sth_trial_workflow->err()) {

          for my $t_workflow_rec (@{$trial_workflow_aref}) {

            my $t_id = $t_workflow_rec->{'TrialId'};
            my $workflow_aref = [];

            if (defined($trial_workflow_href->{$t_id})) {

              $workflow_aref = $trial_workflow_href->{$t_id};
            }

            push(@{$workflow_aref}, $t_workflow_rec);

            $trial_workflow_href->{$t_id} = $workflow_aref;
          }
        }
        else {

          $err = 1;
          $msg = 'Unexpected error';
          $self->logger->debug('Err: ' . $dbh->errstr());
          return ($err, $msg, []);
        }
      }
      else {

        $err = 1;
        $msg = 'Unexpected error';
        $self->logger->debug('Err: ' . $dbh->errstr());
        return ($err, $msg, []);
      }

      #

      my $trial_event_sql = 'SELECT * FROM trialevent WHERE TrialId IN (' . join(',', @trial_id_list) . ')';

      my $sth_trial_event = $dbh->prepare($trial_event_sql);
      $sth_trial_event->execute();

      if (!$dbh->err()) {

        my $trial_event_aref = $sth_trial_event->fetchall_arrayref({});

        if (!$sth_trial_event->err()) {

          for my $t_event_rec (@{$trial_event_aref}) {

            my $t_id = $t_event_rec->{'TrialId'};
            my $event_aref = [];

            if (defined($trial_event_href->{$t_id})) {

              $event_aref = $trial_event_href->{$t_id};
            }

            push(@{$event_aref}, $t_event_rec);

            $trial_event_href->{$t_id} = $event_aref;
          }
        }
        else {

          $err = 1;
          $msg = 'Unexpected error';
          $self->logger->debug('Err: ' . $dbh->errstr());
          return ($err, $msg, []);
        }
      }
      else {

        $err = 1;
        $msg = 'Unexpected error';
        $self->logger->debug('Err: ' . $dbh->errstr());
        return ($err, $msg, []);
      }

      #

      my $chk_table_aref = [{'TableName' => 'trialunit', 'FieldName' => 'TrialId'},
                            {'TableName' => 'trialevent', 'FieldName' => 'TrialId'},
                            {'TableName' => 'trialtrait', 'FieldName' => 'TrialId'},
                            {'TableName' => 'trialgroupentry', 'FieldName' => 'TrialId'},
                            {'TableName' => 'trialworkflow', 'FieldName' => 'TrialId'}
          ];

      ($chk_id_err, $chk_id_msg,
       $used_id_href, $not_used_id_href) = id_existence_bulk($dbh, $chk_table_aref, \@trial_id_list);

      if ($chk_id_err) {

        $self->logger->debug("Check id existence error: $chk_id_msg");
        $err = 1;
        $msg = $chk_id_msg;

        return ($err, $msg, []);
      }
    }
  }

  if (scalar(keys(%{$field_list_loc_href})) > 0) {

    my $dbh_gis = connect_gis_read();

    if (scalar(@trial_id_list) > 0) {

      my $gis_where = "WHERE trialid IN (" . join(',', @trial_id_list) . ") AND currentloc = 1";

      my $trialloc_sql = 'SELECT trialid, triallocdt, description, ST_AsText(triallocation) AS triallocation, ';
      $trialloc_sql   .= 'ST_AsText(ST_Centroid(geometry(triallocation))) AS trialcentroid ';
      $trialloc_sql   .= 'FROM trialloc ';
      $trialloc_sql   .= $gis_where;

      my $sth_gis = $dbh_gis->prepare($trialloc_sql);
      $sth_gis->execute();

      if (!$dbh_gis->err()) {

        my $gis_href = $sth_gis->fetchall_hashref('trialid');

        if (!$sth_gis->err()) {

          $trial_loc_gis = $gis_href;
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
    }

    $dbh_gis->disconnect();
  }

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

  my @extra_attr_trial_data;

  my $gadmin_status = $self->authen->gadmin_status();
  my $group_id      = $self->authen->group_id();

  for my $row (@{$data_aref}) {

    my $trial_id       = $row->{'TrialId'};
    my $trial_centroid = $trial_loc_gis->{$trial_id}->{'trialcentroid'};

    $trial_centroid   =~ /POINT\((.+) (.+)\)/;
    my $longitude     = $1;
    my $latitude      = $2;

    if ($field_list_loc_href->{'LCol*'} || $field_list_loc_href->{'Longitude'}) {

      $row->{'Longitude'} = $longitude;
    }

    if ($field_list_loc_href->{'LCol*'} || $field_list_loc_href->{'Latitude'}) {

      $row->{'Latitude'}  = $latitude;
    }

    if ($field_list_loc_href->{'LCol*'} || $field_list_loc_href->{'triallocation'}) {

      $row->{'triallocation'} = $trial_loc_gis->{$trial_id}->{'triallocation'};
    }

    $row->{'triallocdt'} = $trial_loc_gis->{$trial_id}->{'triallocdt'};

    $row->{'triallocdescription'} = $trial_loc_gis->{$trial_id}->{'description'};

    my $own_grp_id   = $row->{'OwnGroupId'};
    my $acc_grp_id   = $row->{'AccessGroupId'};
    my $own_perm     = $row->{'OwnGroupPerm'};
    my $acc_perm     = $row->{'AccessGroupPerm'};
    my $oth_perm     = $row->{'OtherPerm'};
    my $ulti_perm    = $row->{'UltimatePerm'};

    if ($extra_attr_yes) {

      $row->{'OwnGroupName'}          = $group_lookup->{$own_grp_id}->{'SystemGroupName'};
      $row->{'AccessGroupName'}       = $group_lookup->{$acc_grp_id}->{'SystemGroupName'};
      $row->{'OwnGroupPermission'}    = $perm_lookup->{$own_perm};
      $row->{'AccessGroupPermission'} = $perm_lookup->{$acc_perm};
      $row->{'OtherPermission'}       = $perm_lookup->{$oth_perm};
      $row->{'UltimatePermission'}    = $perm_lookup->{$ulti_perm};

      if (defined $trial_dimension_href->{$trial_id}) {

        $row->{'trialdimension'} = $trial_dimension_href->{$trial_id};
      }
      else {

        $row->{'trialdimension'} = [];
      }

      if (defined $trial_workflow_href->{$trial_id}) {

        $row->{'trialworkflow'} = $trial_workflow_href->{$trial_id};
      }
      else {

        $row->{'trialworkflow'} = [];
      }

      if (defined $trial_event_href->{$trial_id}) {

        $row->{'trialevent'} = $trial_event_href->{$trial_id};
      }
      else {

        $row->{'trialevent'} = [];
      }

      #$self->logger->debug("TrialId: $trial_id, GroupId: $group_id, UltiPerm: $ulti_perm, WritePerm: $WRITE_PERM");

      $row->{'map'}       = "trial/$trial_id/on/map";

      if ( $trait_count_href->{$trial_id}->{'NumOfTrait'} > 0 ) {

        $row->{'listTrait'} = "trial/$trial_id/list/trait";
      }

      if ( $crossing_count_href->{$trial_id}->{'NumOfCross'} > 0) {

        $row->{'listCrossing'} = "trial/$trial_id/list/crossing";
      }

      if ( ($trait_count_href->{$trial_id}->{'NumOfTrait'} > 0) &&
           ($trialunit_count_href->{$trial_id}->{'NumOfTrialUnit'} > 0) ) {

        $row->{'expDkTmpl'} = "trial/$trial_id/export/datakapturetemplate";
      }

      if ($trait_value_count_href->{$trial_id}->{'NumOfTraitValue'} > 0) {

        $row->{'expDkData'} = "trial/$trial_id/export/dkdata";
      }

      if ($trialunit_count_href->{$trial_id}->{'NumOfTrialUnit'} > 0) {

        $row->{'listTrialUnit'} = "trial/$trial_id/list/trialunit";
      }

      if (($ulti_perm & $WRITE_PERM) == $WRITE_PERM) {

        $row->{'update'}      = "update/trial/$trial_id";
        $row->{'addTrait'}    = "trial/$trial_id/add/trait";

        if (defined $row->{'CurrentWorkflowId'}) {

          if (length($row->{'CurrentWorkflowId'}) > 0) {

            $row->{'addWorkflow'} = "trial/$trial_id/add/workflow";
          }
        }

        if ($trait_count_href->{$trial_id}->{'NumOfTrait'} > 0) {

          $row->{'impDkData'} = "trial/$trial_id/import/datakapturedata/csv";
        }
      }

      if ($own_grp_id == $group_id) {

        $row->{'chgPerm'} = "trial/$trial_id/change/permission";

        if ($gadmin_status eq '1') {

          $row->{'chgOwner'} = "trial/$trial_id/change/owner";

          if ( $not_used_id_href->{$trial_id} ) {

            $row->{'delete'}   = "delete/trial/$trial_id";
          }
        }
      }
    }

    push(@extra_attr_trial_data, $row);
  }

  $dbh->disconnect();

  return ($err, $msg, \@extra_attr_trial_data);
}

sub list_trial_advanced_runmode {

=pod list_trial_advanced_HELP_START
{
"OperationName": "List trials",
"Description": "List trials available in the system. This listing requires pagination information.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination NumOfRecords='10' NumOfPages='10' Page='1' NumPerPage='1' /><RecordMeta TagName='Trial' /><Trial ProjectName='' AccessGroupName='admin' TrialLayout='{}' SeasonId='43' TrialTypeName='TrialType - 23515779554' UltimatePerm='7' map='trial/12/on/map' TrialStartDate='2010-10-15 00:00:00' UltimatePermission='Read/Write/Link' AccessGroupId='0' OtherPerm='5' AccessGroupPerm='5' TULastUpdateTimeStamp='2023-04-11 15:19:47' OwnGroupPermission='Read/Write/Link' TrialNote='none' TrialManagerId='38' TrialEndDate='2011-03-31 00:00:00' OwnGroupPerm='7' chgPerm='trial/12/change/permission' triallocation='MULTIPOLYGON(((149.05803801025291 -35.28275454804866,149.06078459228328 -35.315257984493236,149.12120939696936 -35.31637855978221,149.05803801025291 -35.28275454804866)))' addTrait='trial/12/add/trait' TrialTypeId='42' SiteName='DArT Test Site' OwnGroupId='0' CurrentWorkflowId='' TrialManagerName='Testing User-77999475926' triallocdt='2023-04-11 05:19:47' TrialId='12' TrialName='Trial_21200739082' update='update/trial/12' TrialNumber='1' Longitude='149.08001066650183' ProjectId='' AccessGroupPermission='Read/Link' OwnGroupName='admin' TrialAcronym='TEST' triallocdescription='' DesignTypeName='Traditional - 88649882141' delete='delete/trial/12' Latitude='-35.3047970307747' SeasonName='Season - 52508821522' SiteId='15' OtherPermission='Read/Link' DesignTypeId='12' chgOwner='trial/12/change/owner'/></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfRecords' : '10','NumOfPages' : 10,'NumPerPage' : '1','Page' : '1'}],'VCol' : [],'RecordMeta' : [{'TagName' : 'Trial'}],'Trial' : [{ 'triallocation' : 'MULTIPOLYGON(((149.05803801025291 -35.28275454804866,149.06078459228328 -35.315257984493236,149.12120939696936 -35.31637855978221,149.05803801025291 -35.28275454804866)))', 'chgPerm' : 'trial/12/change/permission', 'trialevent' : [], 'TrialTypeId' : 42, 'addTrait' : 'trial/12/add/trait', 'OtherPermission' : 'Read/Link', 'SiteName' : 'DArT Test Site', 'DesignTypeId' : 12, 'chgOwner' : 'trial/12/change/owner', 'SiteId' : 15, 'OwnGroupPerm' : 7, 'TrialEndDate' : '2011-03-31 00:00:00', 'TrialManagerId' : 38, 'Latitude' : '-35.3047970307747', 'TULastUpdateTimeStamp' : '2023-04-11 15:19:47', 'SeasonName' : 'Season - 52508821522', 'TrialNote' : 'none', 'OwnGroupPermission' : 'Read/Write/Link', 'AccessGroupPerm' : 5, 'triallocdescription' : '', 'TrialAcronym' : 'TEST', 'OwnGroupName' : 'admin', 'delete' : 'delete/trial/12', 'DesignTypeName' : 'Traditional - 88649882141', 'Longitude' : '149.08001066650183', 'AccessGroupPermission' : 'Read/Link', 'trialdimension' : [], 'ProjectId' : null, 'AccessGroupId' : 0, 'UltimatePermission' : 'Read/Write/Link', 'OtherPerm' : 5, 'UltimatePerm' : 7, 'TrialTypeName' : 'TrialType - 23515779554', 'TrialStartDate' : '2010-10-15 00:00:00', 'map' : 'trial/12/on/map', 'trialworkflow' : [], 'TrialNumber' : 1, 'triallocdt' : '2023-04-11 05:19:47', 'TrialManagerName' : 'Testing User-77999475926', 'TrialLayout' : '{}', 'TrialId' : 12, 'SeasonId' : 43, 'update' : 'update/trial/12', 'TrialName' : 'Trial_21200739082', 'OwnGroupId' : 0, 'ProjectName' : null, 'AccessGroupName' : 'admin', 'CurrentWorkflowId' : null }]}",
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

  if (defined $self->param('siteid')) {

    my $site_id = $self->param('siteid');

    if ($filtering_csv =~ /SiteId=(.*),?/) {

      if ( "$site_id" ne "$1" ) {

        my $err_msg = 'Duplicate filtering condition for SiteId.';
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
    else {

      if (length($filtering_csv) > 0) {

        if ($filtering_csv =~ /&$/) {

          $filtering_csv  .= "SiteId=$site_id";
        }
        else {

          $filtering_csv .= "&SiteId=$site_id";
        }
      }
      else {

        $filtering_csv .= "SiteId=$site_id";
      }
    }
  }

  $self->logger->debug("Filtering csv: $filtering_csv");

  my $sorting = '';

  if (defined $query->param('Sorting')) {

    $sorting = $query->param('Sorting');
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'trial');

  my $dbh = connect_kdb_read();
  my $field_list = ['trial.*', 'VCol*', 'LCol*'];
  my $pre_data_other_join = '';

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $field_list, 'trial',
                                                                        'TrialId', '');

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql   .= " LIMIT 1";

  $self->logger->debug("SQL with VCol: $sql");

  my ($sam_trial_err, $sam_trial_msg, $sam_trial_data) = $self->list_trial(0, $field_list, $sql);

  if ($sam_trial_err) {

    $self->logger->debug($sam_trial_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $sample_data_aref = $sam_trial_data;

  my @field_list_all;

  if (scalar(@{$sample_data_aref}) == 1) {

    @field_list_all = keys(%{$sample_data_aref->[0]});
  }
  else {

    $self->logger->debug("It reaches here");
    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'trial');

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
                                                                                'TrialId');

    if ($sel_field_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;

    if ($filtering_csv =~ /SiteId/) {

      push(@{$final_field_list}, 'SiteId');
    }

    $sql_field_list       = [];
    for my $fd_name (@{$final_field_list}) {

      # need to remove location field because generate_factor_sql does not understand these field
      if ( (!($fd_name =~ /Longitude/)) && (!($fd_name =~ /Latitude/)) && (!($fd_name =~ /triallocation/)) && (!($fd_name =~ /triallocdt/)) && (!($fd_name =~ /triallocdescription/))) {

        push(@{$sql_field_list}, $fd_name);
      }
    }
  }
  else {

    for my $fd_name (@{$final_field_list}) {

      # need to remove location field because generate_factor_sql does not understand these field
      if ( (!($fd_name =~ /Longitude/)) && (!($fd_name =~ /Latitude/)) && (!($fd_name =~ /triallocation/)) && (!($fd_name =~ /triallocdt/)) && (!($fd_name =~ /triallocdescription/))) {

        push(@{$sql_field_list}, $fd_name);
      }
    }
  }

  my $sql_field_lookup = {};

  for my $fd_name (@{$sql_field_list}) {

    $sql_field_lookup->{$fd_name} = 1;
  }

  my $other_join = '';
  if ($sql_field_lookup->{'SiteId'}) {

    push(@{$sql_field_list}, 'site.SiteName');
    $other_join .= ' LEFT JOIN site ON trial.SiteId = site.SiteId ';
  }

  if ($sql_field_lookup->{'TrialTypeId'}) {

    push(@{$sql_field_list}, 'generaltype.TypeName AS TrialTypeName');
    $other_join   .= ' LEFT JOIN generaltype ON trial.TrialTypeId = generaltype.TypeId ';
  }

  if ($sql_field_lookup->{'DesignTypeId'}) {

    push(@{$sql_field_list}, 'designtype.DesignTypeName');
    $other_join   .= ' LEFT JOIN designtype ON trial.DesignTypeId = designtype.DesignTypeId ';
  }

  if ($sql_field_lookup->{'TrialManagerId'}) {

    push(@{$sql_field_list}, "CONCAT(contact.ContactFirstName, ' ', contact.ContactLastName) AS TrialManagerName ");
    $other_join   .= ' LEFT JOIN contact ON trial.TrialManagerId = contact.ContactId ';
  }

  if ($sql_field_lookup->{'ProjectId'}) {

    push(@{$sql_field_list}, 'project.ProjectName');
    $other_join   .= ' LEFT JOIN project ON trial.ProjectId = project.ProjectId ';
  }

  if ($sql_field_lookup->{'SeasonId'}) {

    push(@{$sql_field_list}, 'seasontype.TypeName AS SeasonName');
    $other_join   .= ' LEFT JOIN generaltype AS seasontype ON trial.SeasonId = seasontype.TypeId ';
  }

  my $compulsory_perm_fields = ['OwnGroupId',
                                'AccessGroupId',
                                'OwnGroupPerm',
                                'AccessGroupPerm',
                                'OtherPerm',
      ];

  for my $com_fd_name (@{$compulsory_perm_fields}) {

    if (length($sql_field_lookup->{$com_fd_name}) == 0) {

      push(@{$sql_field_list}, $com_fd_name);
    }
  }

  push(@{$sql_field_list}, "$perm_str AS UltimatePerm");

  my $factor_filtering_flag = test_filtering_factor($filtering_csv);

  if (!$factor_filtering_flag) {

    ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $sql_field_list, 'trial',
                                                                       'TrialId', $other_join);
  }
  else {

    ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql_v2($dbh, $sql_field_list, 'trial',
                                                                          'TrialId', $other_join);
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
      $nb_filter_factor) = parse_filtering_v2('TrialId',
                                              'trial',
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

    $filter_where_phrase = " AND $filter_phrase ";
  }

  my $filtering_exp = " WHERE (($perm_str) & $READ_PERM) = $READ_PERM $filter_where_phrase ";

  if (length($having_phrase) > 0) {

    $sql =~ s/FACTORHAVING/ HAVING $having_phrase/;

    $sql .= " $filtering_exp ";
  }
  else {

    $sql =~ s/GROUP BY/ $filtering_exp GROUP BY /;
  }

  my $pagination_aref    = [];
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
                                                                  'trial',
                                                                  'TrialId',
                                                                  $filtering_exp,
                                                                  $where_arg);
    }
    else {

      $self->logger->debug("COUNT NB RECORD: FACTOR IN FILTERING");

      my $count_sql = "SELECT COUNT(trial.TrialId) ";
      $count_sql   .= "FROM trial INNER JOIN ";
      $count_sql   .= " (SELECT TrialId, COUNT(TrialId) ";
      $count_sql   .= " FROM trialfactor WHERE $count_filter_phrase ";
      $count_sql   .= " GROUP BY TrialId HAVING COUNT(TrialId)=$nb_filter_factor) AS subq ";
      $count_sql   .= "ON trial.TrialId = subq.TrialId ";
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

    $sql .= ' ORDER BY trial.TrialId DESC';
  }

  $sql .= " $paged_limit_clause ";

  $self->logger->debug("SQL with VCol: $sql");

  $self->logger->debug('Where arg: ' . join(',', @{$where_arg}));

  # where_arg here in the list function because of the filtering
  my ($read_trial_err, $read_trial_msg, $trial_data) = $self->list_trial(1,
                                                                         $final_field_list,
                                                                         $sql,
                                                                         $where_arg);

  if ($read_trial_err) {

    $self->logger->debug($read_trial_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'geojson'}   = 1;
  $data_for_postrun_href->{'GJSonInfo'} = {'GeometryField' => 'triallocation',
                                           'FeatureName'   => 'TrialName [ id: TrialId ]<BR>[ type: TrialTypeName ]<BR>[ start: TrialStartDate - end: TrialEndDate ]',
                                           'FeatureId'     => 'TrialId',
  };
  $data_for_postrun_href->{'Data'}  = {'Trial'      => $trial_data,
                                       'VCol'       => $vcol_list,
                                       'Pagination' => $pagination_aref,
                                       'RecordMeta' => [{'TagName' => 'Trial'}],
  };

  return $data_for_postrun_href;
}

sub get_trial_runmode {

=pod get_trial_HELP_START
{
"OperationName": "Get trial",
"Description": "Get detailed information about a trial specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='Trial' /><Trial ProjectName='' AccessGroupName='admin' TrialLayout='{}' SeasonId='43' TrialTypeName='TrialType - 23515779554' UltimatePerm='7' map='trial/12/on/map' TrialStartDate='2010-10-15 00:00:00' UltimatePermission='Read/Write/Link' AccessGroupId='0' OtherPerm='5' AccessGroupPerm='5' TULastUpdateTimeStamp='2023-04-11 15:19:47' OwnGroupPermission='Read/Write/Link' TrialNote='none' TrialManagerId='38' TrialEndDate='2011-03-31 00:00:00' OwnGroupPerm='7' chgPerm='trial/12/change/permission' triallocation='MULTIPOLYGON(((149.05803801025291 -35.28275454804866,149.06078459228328 -35.315257984493236,149.12120939696936 -35.31637855978221,149.05803801025291 -35.28275454804866)))' addTrait='trial/12/add/trait' TrialTypeId='42' SiteName='DArT Test Site' OwnGroupId='0' CurrentWorkflowId='' TrialManagerName='Testing User-77999475926' triallocdt='2023-04-11 05:19:47' TrialId='12' TrialName='Trial_21200739082' update='update/trial/12' TrialNumber='1' Longitude='149.08001066650183' ProjectId='' AccessGroupPermission='Read/Link' OwnGroupName='admin' TrialAcronym='TEST' triallocdescription='' DesignTypeName='Traditional - 88649882141' delete='delete/trial/12' Latitude='-35.3047970307747' SeasonName='Season - 52508821522' SiteId='15' OtherPermission='Read/Link' DesignTypeId='12' chgOwner='trial/12/change/owner'/></DATA>",
"SuccessMessageJSON": "{'VCol' : [],'RecordMeta' : [{'TagName' : 'Trial'}],'Trial' : [{ 'triallocation' : 'MULTIPOLYGON(((149.05803801025291 -35.28275454804866,149.06078459228328 -35.315257984493236,149.12120939696936 -35.31637855978221,149.05803801025291 -35.28275454804866)))', 'chgPerm' : 'trial/12/change/permission', 'trialevent' : [], 'TrialTypeId' : 42, 'addTrait' : 'trial/12/add/trait', 'OtherPermission' : 'Read/Link', 'SiteName' : 'DArT Test Site', 'DesignTypeId' : 12, 'chgOwner' : 'trial/12/change/owner', 'SiteId' : 15, 'OwnGroupPerm' : 7, 'TrialEndDate' : '2011-03-31 00:00:00', 'TrialManagerId' : 38, 'Latitude' : '-35.3047970307747', 'TULastUpdateTimeStamp' : '2023-04-11 15:19:47', 'SeasonName' : 'Season - 52508821522', 'TrialNote' : 'none', 'OwnGroupPermission' : 'Read/Write/Link', 'AccessGroupPerm' : 5, 'triallocdescription' : '', 'TrialAcronym' : 'TEST', 'OwnGroupName' : 'admin', 'delete' : 'delete/trial/12', 'DesignTypeName' : 'Traditional - 88649882141', 'Longitude' : '149.08001066650183', 'AccessGroupPermission' : 'Read/Link', 'trialdimension' : [], 'ProjectId' : null, 'AccessGroupId' : 0, 'UltimatePermission' : 'Read/Write/Link', 'OtherPerm' : 5, 'UltimatePerm' : 7, 'TrialTypeName' : 'TrialType - 23515779554', 'TrialStartDate' : '2010-10-15 00:00:00', 'map' : 'trial/12/on/map', 'trialworkflow' : [], 'TrialNumber' : 1, 'triallocdt' : '2023-04-11 05:19:47', 'TrialManagerName' : 'Testing User-77999475926', 'TrialLayout' : '{}', 'TrialId' : 12, 'SeasonId' : 43, 'update' : 'update/trial/12', 'TrialName' : 'Trial_21200739082', 'OwnGroupId' : 0, 'ProjectName' : null, 'AccessGroupName' : 'admin', 'CurrentWorkflowId' : null }]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Trial (20) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Trial (20) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self     = shift;
  my $trial_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'trial');

  my $trial_perm_sql = "SELECT $perm_str as UltimatePerm ";
  $trial_perm_sql   .= 'FROM trial ';
  $trial_perm_sql   .= 'WHERE TrialId=?';

  my $trial_perm = read_cell($dbh, $trial_perm_sql, [$trial_id]);

  if (length($trial_perm) == 0) {

    my $err_msg = "Trial ($trial_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }
  elsif ( ($trial_perm & $READ_PERM) != $READ_PERM ) {

    my $err_msg = "Permission denied: trial ($trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $field_list = ['trial.*', 'VCol*', 'LCol*',
                    'site.SiteName', 'generaltype.TypeName AS TrialTypeName',
                    'designtype.DesignTypeName', 'seasontype.TypeName AS SeasonName',
                    "CONCAT(contact.ContactFirstName, ' ', contact.ContactLastName) AS TrialManagerName ",
                    "$perm_str AS UltimatePerm",
      ];

  my $other_join = ' LEFT JOIN site ON trial.SiteId = site.SiteId ';
  $other_join   .= ' LEFT JOIN generaltype ON trial.TrialTypeId = generaltype.TypeId ';
  $other_join   .= ' LEFT JOIN designtype ON trial.DesignTypeId = designtype.DesignTypeId ';
  $other_join   .= ' LEFT JOIN contact ON trial.TrialManagerId = contact.Contactid ';
  $other_join   .= ' LEFT JOIN generaltype AS seasontype ON trial.SeasonId = seasontype.TypeId ';

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $field_list, 'trial',
                                                                        'TrialId', $other_join);
  $dbh->disconnect();

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $where_exp = " WHERE (($perm_str) & $READ_PERM) = $READ_PERM AND trial.TrialId=? ";

  $sql =~ s/GROUP BY/ $where_exp GROUP BY /;

  $self->logger->debug("SQL with VCol: $sql");

  my ($read_trial_err, $read_trial_msg, $trial_data) = $self->list_trial(1, $field_list, $sql, [$trial_id]);

  if ($read_trial_err) {

    $self->logger->debug($read_trial_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'geojson'}   = 1;
  $data_for_postrun_href->{'GJSonInfo'} = {'GeometryField' => 'triallocation',
                                           'FeatureName'   => 'TrialName [ id: TrialId ]<BR>[ type: TrialTypeName ]<BR>[ start: TrialStartDate - end: TrialEndDate ]',
                                           'FeatureId'     => 'TrialId',
  };
  $data_for_postrun_href->{'Data'}  = {'Trial'      => $trial_data,
                                       'VCol'       => $vcol_list,
                                       'RecordMeta' => [{'TagName' => 'Trial'}],
  };

  return $data_for_postrun_href;
}

sub update_trial_runmode {

=pod update_trial_HELP_START
{
"OperationName": "Update trial",
"Description": "Update information about a trial specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "trial",
"SkippedField": ["OwnGroupId", "AccessGroupId", "OwnGroupPerm", "AccessGroupPerm", "OtherPerm", "TULastUpdateTimeStamp"],
"KDDArTFactorTable": "trialfactor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Trial (1) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Trial (1) has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Trial (20) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Trial (20) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self     = shift;
  my $trial_id = $self->param('id');
  my $query    = $self->query();

  my $data_for_postrun_href = {};
  my $trial_err = 0;
  my $trial_err_aref = [];

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'OwnGroupId'             => 1,
                    'AccessGroupId'          => 1,
                    'OwnGroupPerm'           => 1,
                    'AccessGroupPerm'        => 1,
                    'OtherPerm'              => 1,
                    'TULastUpdateTimeStamp'  => 1,
                   };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'trial', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $trial_name          = $query->param('TrialName');
  my $site_id             = $query->param('SiteId');
  my $trial_type_id       = $query->param('TrialTypeId');
  my $trial_number        = $query->param('TrialNumber');
  my $trial_acronym       = $query->param('TrialAcronym');
  my $design_type_id      = $query->param('DesignTypeId');
  my $trial_manager_id    = $query->param('TrialManagerId');
  my $trial_sdate         = $query->param('TrialStartDate');
  my $season_id           = $query->param('SeasonId');

  my $dbh_k_read = connect_kdb_read();

  my $read_tr_sql     =  'SELECT ProjectId, CurrentWorkflowId, TrialEndDate, TrialNote, TrialLayout ';
     $read_tr_sql    .=  'FROM trial WHERE TrialId=? ';


  my ($r_df_val_err, $r_df_val_msg, $trial_df_val_data) = read_data($dbh_k_read, $read_tr_sql, [$trial_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve trial default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $project_id     = undef;
  my $workflow_id    = undef;
  my $trial_edate    = undef;
  my $trial_note     = undef;
  my $trial_layout   = undef;

  my $nb_df_val_rec    =  scalar(@{$trial_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve trial default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $project_id     = $trial_df_val_data->[0]->{'ProjectId'};
  $workflow_id    = $trial_df_val_data->[0]->{'CurrentWorkflowId'};
  $trial_edate    = $trial_df_val_data->[0]->{'TrialEndDate'};
  $trial_note     = $trial_df_val_data->[0]->{'TrialNote'};
  $trial_layout   = $trial_df_val_data->[0]->{'TrialLayout'};

  if ($ALLOWDUPLICATETRIALNAME_CFG != 1) {

    my $filter_trialname_sql = "SELECT * FROM trial WHERE TrialName=?";

    my ($filter_trialname_err, $filter_trialname_msg, $filter_trialname_data) = read_data($dbh_read, $filter_trialname_sql, [$trial_name]);

    if ($filter_trialname_err) {

      return ($filter_trialname_err, "$filter_trialname_msg", []);
    }

    for my $row (@{$filter_trialname_data}) {

      my $filter_trialname = $row->{'TrialName'};
      my $filter_trialid = $row->{'TrialId'};

      if ($filter_trialname eq $trial_name && $trial_id == $filter_trialid) {

          my $err_msg = "Duplicate ($trial_name) cannot be used.";
          
          push(@{$trial_err_aref}, {'TrialName' => $err_msg});
          $trial_err = 1;
      }
    }

  }

  # Unknown end DateTime value from database 0000-00-00 00:00:00 which should be reset to empty string, undef,
  # and then null in the db

  if ($trial_edate eq '0000-00-00 00:00:00') {

    $trial_edate = undef;
  }

  if (defined $query->param('ProjectId')) {

    if (length($query->param('ProjectId')) > 0) {

      $project_id = $query->param('ProjectId');

      my $project_existence = record_existence($dbh_k_read, 'project', 'ProjectId', $project_id);

      if (!$project_existence) {

        my $err_msg = "Project ($project_id) does not exist.";

        push(@{$trial_err_aref}, {'ProjectId' => $err_msg});
        $trial_err = 1;
      }
    }
    else {

      $project_id = undef;
    }
  }

  if (length($project_id) == 0) {

    $project_id = undef;
  }

  if (length($workflow_id) == 0) {

    $workflow_id = undef;
  }

  if (defined $query->param('CurrentWorkflowId')) {

    if (length($query->param('CurrentWorkflowId')) > 0) {

      $workflow_id = $query->param('CurrentWorkflowId');
    }
  }

  if (length($trial_layout) == 0) {

    $trial_layout = undef;
  }

  if (defined $query->param('TrialLayout')) {

    if (length($query->param('TrialLayout')) > 0) {

      $trial_layout = $query->param('TrialLayout');
    }
  }

  if (defined $query->param('TrialEndDate')) {

    if (length($query->param('TrialEndDate')) > 0) {

      $trial_edate = $query->param('TrialEndDate');
    }
  }

  # Unknown end DateTime value from database 0000-00-00 00:00:00 which should be reset to empty string, undef,
  # and then null in the db

  if ($trial_edate eq '0000-00-00 00:00:00') {

    $trial_edate = undef;
  }

  if (defined $query->param('TrialNote')) {

    $trial_note = $query->param('TrialNote');
  }


  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  if (!type_existence($dbh_k_read, 'season', $season_id)) {

    my $err_msg = "Season ($season_id) does not exist.";

    push(@{$trial_err_aref}, {'SeasonId' => $err_msg});
    $trial_err = 1;
  }

  my $sql;

  if (!(record_existence($dbh_k_read, 'trial', 'TrialId', $trial_id))) {

    my $err_msg = "Trial ($trial_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }
  else {

    my ($is_ok, $trouble_trial_id_aref) = check_permission($dbh_k_read, 'trial', 'TrialId',
                                                           [$trial_id], $group_id, $gadmin_status,
                                                           $READ_WRITE_PERM);

    if (!$is_ok) {

      my $err_msg = "Trial ($trial_id): permission denied.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [$err_msg]};

      return $data_for_postrun_href;
    }
  }

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength, FactorValidRuleErrMsg, FactorValidRule  ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='trialfactor'";

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
      'CanFactorHaveNull' => $vcol_data->{$vcol_id}->{'CanFactorHaveNull'}
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

  if (defined $workflow_id) {

    if (!record_existence($dbh_k_read, 'workflow', 'WorkflowId', $workflow_id)) {

      my $err_msg = "CurrentWorkflowId ($workflow_id) does not exist.";

      push(@{$trial_err_aref}, {'CurrentWorkflowId' => $err_msg});
      $trial_err = 1;
    }
  }

  my ($date_err, $date_href) = check_dt_href( { 'TrialStartDate'   => $trial_sdate } );

  if ($date_err) {

    push(@{$trial_err_aref}, $date_href);
    $trial_err = 1;
  }

  if (length($trial_edate) > 0) {

    ($date_err, $date_href) = check_dt_href( { 'TrialEndDate'   => $trial_edate } );

    if ($date_err) {

      push(@{$trial_err_aref}, $date_href);
      $trial_err = 1;
    }
  }
  else {

    $trial_edate = undef;
  }

  my $site_existence = record_existence($dbh_k_read, 'site', 'SiteId', $site_id);

  if (!$site_existence) {

    my $err_msg = "Site ($site_id) does not exist.";

    push(@{$trial_err_aref}, {'SiteId' => $err_msg});
    $trial_err = 1;
  }

  my $trialtype_existence = type_existence($dbh_k_read, 'trial', $trial_type_id);

  if (!$trialtype_existence) {

    my $err_msg = "TrialType ($trial_type_id) does not exist.";

    push(@{$trial_err_aref}, {'TrialTypeId' => $err_msg});
    $trial_err = 1;
  }

  my $design_type_existence = record_existence($dbh_k_read, 'designtype', 'DesignTypeId', $design_type_id);

  if (!$design_type_existence) {

    my $err_msg = "DesignType ($design_type_id) does not exist.";
    
    push(@{$trial_err_aref}, {'DesignTypeId' => $err_msg});
    $trial_err = 1;
  }

  my $trial_manager_existence = record_existence($dbh_k_read, 'contact', 'ContactId', $trial_manager_id);

  if (!$trial_manager_existence) {

    my $err_msg = "TrialManager ($trial_manager_id) does not exist.";

    push(@{$trial_err_aref}, {'TrialManagerId' => $err_msg});
    $trial_err = 1;
  }

  $dbh_k_read->disconnect();

  #prevalidate values to be finished in later version

  my ($vcol_error, $vcol_error_aref) = validate_all_factor_input($pre_validate_vcol);

  if ($vcol_error) {
    push(@{$trial_err_aref}, @{$vcol_error_aref});
    $trial_err = 1;
  }

  if ($trial_err != 0) {
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => $trial_err_aref};
    return $data_for_postrun_href;
  }

  my $dbh_k_write = connect_kdb_write();

  $sql    = 'UPDATE trial SET ';
  $sql   .= 'ProjectId=?, ';
  $sql   .= 'CurrentWorkflowId=?, ';
  $sql   .= 'TrialName=?, ';
  $sql   .= 'SiteId=?, ';
  $sql   .= 'TrialTypeId=?, ';
  $sql   .= 'TrialNumber=?, ';
  $sql   .= 'TrialAcronym=?, ';
  $sql   .= 'DesignTypeId=?, ';
  $sql   .= 'TrialManagerId=?, ';
  $sql   .= 'TrialStartDate=?, ';
  $sql   .= 'TrialEndDate=?, ';
  $sql   .= 'TrialNote=?, ';
  $sql   .= 'TrialLayout=?, ';
  $sql   .= 'SeasonId=? ';
  $sql   .= 'WHERE TrialId=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($project_id, $workflow_id, $trial_name, $site_id, $trial_type_id, $trial_number, $trial_acronym,
                $design_type_id, $trial_manager_id, $trial_sdate, $trial_edate, $trial_note, $trial_layout,
                $season_id, $trial_id);

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

      my ($vcol_err, $vcol_msg) = update_factor_value($dbh_k_write, $vcol_id, $factor_value, 'trialfactor', 'TrialId', $trial_id);

      if ($vcol_err) {

        $self->logger->debug("VCol_" . "$vcol_id => $vcol_msg" );

        push(@{$trial_err_aref}, {'VCol_' . "$vcol_id" => $vcol_msg});

        $trial_err = 1;
      }
    }
  }

  if ($trial_err != 0) {
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => $trial_err_aref};
    return $data_for_postrun_href;
  }

  my $info_msg_aref = [{'Message' => "Trial ($trial_id) has been updated successfully."}];

  $dbh_k_write->disconnect();

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'       => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}
sub update_trial_geography_runmode {

=pod update_trial_geography_HELP_START
{
"OperationName": "Update trial location",
"Description": "Update trial's geographical position.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Trial (1) geography has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Trial (1) geography has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Trial (20) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Trial (20) not found.'}]}"}],
"HTTPParameter": [{"Name": "triallocation", "DataType": "polygon_wkt", "Description": "GIS field defining the polygon geometry object of the trial in a standard GIS well-known text.", "Type": "LCol", "Required": "1"},{"Name": "triallocdt", "DataType": "timestamp", "Description": "DateTime of trial location", "Type": "LCol", "Required": "0"},{"Name": "currentloc", "DataType": "tinyint", "Description": "Flag to notify current location", "Type": "LCol", "Required": "0"},{"Name": "description", "DataType": "varchar", "Description": "Description for location", "Type": "LCol", "Required": "0"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self     = shift;
  my $trial_id = $self->param('id');
  my $query    = $self->query();

  my $data_for_postrun_href = {};

  my $dbh_k_read = connect_kdb_read();

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $sql;

  if (!(record_existence($dbh_k_read, 'trial', 'TrialId', $trial_id))) {

    my $err_msg = "Trial ($trial_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$err_msg]};

    return $data_for_postrun_href;
  }
  else {

    my ($is_ok, $trouble_trial_id_aref) = check_permission($dbh_k_read, 'trial', 'TrialId',
                                                           [$trial_id], $group_id, $gadmin_status,
                                                           $READ_WRITE_PERM);

    if (!$is_ok) {

      my $err_msg = "Trial ($trial_id): permission denied.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [$err_msg]};

      return $data_for_postrun_href;
    }
  }


  my $sub_PGIS_val_builder = sub {
    my $wkt = shift;
    my $st_buffer_val = $POINT2POLYGON_BUFFER4TRIAL->{$ENV{DOCUMENT_ROOT}};
    if ($wkt =~ /^POINT/i) {
      return "ST_Multi(ST_Buffer(ST_GeomFromText(?, -1), $st_buffer_val, 1))";
    } else {
      return "ST_Multi(ST_GeomFromText(?, -1))";
    }
  };

  my $is_trial_within_site = 1;
  my $site_id = read_cell_value($dbh_k_read, 'trial', 'SiteId', 'TrialId', $trial_id);

  my $sub_WKT_validator = sub {
    my $gis_write = $_[0];
    my $entity    = $_[1];
    my $entity_id = $_[2];
    my $wkt       = $_[3];

    my ($is_within_err, $is_within) = is_within($gis_write, 'siteloc', 'siteid',
                                              'sitelocation', $wkt, $site_id);

    if ($is_within_err) {
      return (1, "Unexpected error.");
    } elsif (!$is_within) {
      if ($GIS_ENFORCE_GEO_WITHIN) {
        return (1, "This trial geography is not within site ($site_id)'s geography.");
      } else {
        $is_trial_within_site = 0;
      }
    }
  };

  my ($err, $err_msg) = append_geography_loc(
                                              "trial",
                                              $trial_id,
                                              ['POINT', 'POLYGON', 'MULTIPOLYGON'],
                                              $query,
                                              $sub_PGIS_val_builder,
                                              $self->logger,
                                              $sub_WKT_validator,
                                            );

  if ($err) {
    $data_for_postrun_href = $self->_set_error($err_msg);
  } else {
    my $msg = "Trial ($trial_id) location has been updated successfully.";
    if (!$is_trial_within_site) {
      $msg .= " However, this trial's geography is not within site ($site_id)'s geography.";
    }
    my $info_msg_aref = [{'Message' => $msg}];
    $data_for_postrun_href->{'Error'}     = 0;
    $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
    $data_for_postrun_href->{'ExtraData'} = 0;
  }

  $dbh_k_read->disconnect();
  return $data_for_postrun_href;
}

sub list_trial_unit {

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

  my $dbh = connect_kdb_read();

  ($err, $msg, $data_aref) = read_data($dbh, $sql, $where_para_aref);

  if ($err) {

    return ($err, $msg, []);
  }

  my $field_list_loc_href = {};

  for my $field (@{$gis_field_list}) {

    if ($field eq 'Longitude' || $field eq 'Latitude' || $field eq 'LCol*' || $field eq 'trialunitlocation') {

      $field_list_loc_href->{$field} = 1;
    }
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $trial_unit_loc_gis = {};

  my @trial_unit_id_list;

  for my $trialunit_rec (@{$data_aref}) {

    push(@trial_unit_id_list, $trialunit_rec->{'TrialUnitId'});
  }

  my $chk_id_err        = 0;
  my $chk_id_msg        = '';
  my $used_id_href      = {};
  my $not_used_id_href  = {};

  my $tu_specimen_href = {};
  my $tu_keyword_href  = {};
  my $tu_treatment_href = {};

  if ($extra_attr_yes) {

    my $tu_specimen_sql = '';

    $self->logger->debug("Number of TrialUnitId: " . scalar(@trial_unit_id_list));
    $self->logger->debug("TrialUnitId list: " . join(',', @trial_unit_id_list));

    if (scalar(@trial_unit_id_list) > 0) {
         
      $tu_specimen_sql   .= 'SELECT trialunitspecimen.*, specimen.SpecimenName, specimen.Pedigree, specimen.SelectionHistory, specimen.FilialGeneration, breedingmethod.BreedingMethodId, breedingmethod.BreedingMethodName ';
      $tu_specimen_sql   .= 'FROM trialunitspecimen LEFT JOIN specimen ON ';
      $tu_specimen_sql   .= 'trialunitspecimen.SpecimenId = specimen.SpecimenId ';
      $tu_specimen_sql   .= 'LEFT JOIN breedingmethod ON ';
      $tu_specimen_sql   .= 'specimen.BreedingMethodId = breedingmethod.BreedingMethodId ';
      $tu_specimen_sql   .= 'WHERE TrialUnitId IN (' . join(',', @trial_unit_id_list) . ')';

      my $tu_spec_data_aref = [];

      ($err, $msg, $tu_spec_data_aref) = read_data($dbh, $tu_specimen_sql, []);

      if ($err) {

        return ($err, $msg, []);
      }

      for my $tu_spec_rec (@{$tu_spec_data_aref}) {

        my $tu_id = $tu_spec_rec->{'TrialUnitId'};

        my $specimen_aref = [];

        if (defined($tu_specimen_href->{$tu_id})) {

          $specimen_aref = $tu_specimen_href->{$tu_id};
        }

        push(@{$specimen_aref}, $tu_spec_rec);

        $tu_specimen_href->{$tu_id} = $specimen_aref;
      }

      my $tu_keyword_sql = 'SELECT TrialUnitId, keyword.KeywordId, KeywordName ';
      $tu_keyword_sql   .= 'FROM trialunitkeyword LEFT JOIN keyword ON ';
      $tu_keyword_sql   .= 'trialunitkeyword.KeywordId = keyword.KeywordId ';
      $tu_keyword_sql   .= 'WHERE TrialUnitId IN (' . join(',', @trial_unit_id_list) . ')';

      $self->logger->debug("Trial Unit Keyword SQL: $tu_keyword_sql");

      my $tu_kwd_data_aref = [];

      ($err, $msg, $tu_kwd_data_aref) = read_data($dbh, $tu_keyword_sql, []);

      if ($err) {

        return ($err, $msg, []);
      }

      for my $tu_kwd_rec (@{$tu_kwd_data_aref}) {

        my $tu_id = $tu_kwd_rec->{'TrialUnitId'};

        my $keyword_aref = [];

        if (defined($tu_keyword_href->{$tu_id})) {

          $keyword_aref = $tu_keyword_href->{$tu_id};
        }

        push(@{$keyword_aref}, $tu_kwd_rec);

        $tu_keyword_href->{$tu_id} = $keyword_aref;
      }

      my $chk_table_aref = [{'TableName' => 'samplemeasurement', 'FieldName' => 'TrialUnitId'},
                            {'TableName' => 'trialunitspecimen', 'FieldName' => 'TrialUnitId'},
                            {'TableName' => 'trialunitkeyword', 'FieldName' => 'TrialUnitId'}
          ];

      ($chk_id_err, $chk_id_msg,
       $used_id_href, $not_used_id_href) = id_existence_bulk($dbh, $chk_table_aref, \@trial_unit_id_list);

      # Issue9468
      my $tu_treatment_sql = "";
      $tu_treatment_sql .= "SELECT trialunittreatment.*, treatment.TreatmentText ";
      $tu_treatment_sql .= "FROM trialunittreatment LEFT JOIN treatment ON ";
      $tu_treatment_sql .= "trialunittreatment.TreatmentId = treatment.TreatmentId ";
      $tu_treatment_sql .= 'WHERE TrialUnitId IN (' . join(',', @trial_unit_id_list) . ')';
      my $tu_tm_data_aref;
      ($err, $msg, $tu_tm_data_aref) = read_data($dbh, $tu_treatment_sql, []);
      if ($err) {
        return ($err, $msg, []);
      }
      for my $tu_spec_rec (@{$tu_tm_data_aref}) {
        my $tu_id = $tu_spec_rec->{'TrialUnitId'};
        my $treatment_aref = $tu_treatment_href->{$tu_id};
        if (!defined($treatment_aref)) {
          $treatment_aref = [];
          $tu_treatment_href->{$tu_id} = $treatment_aref;
        }
        push(@$treatment_aref, $tu_spec_rec);
      }
    }
  }


  if (scalar(keys(%{$field_list_loc_href})) > 0) {

    if (scalar(@trial_unit_id_list) > 0) {

      my $dbh_gis = connect_gis_read();

      my $gis_where = "WHERE trialunitid IN (" . join(',', @trial_unit_id_list) . ") AND currentloc = 1";

      my $trialunitloc_sql = 'SELECT trialunitid, trialunitlocdt, description, ST_AsText(trialunitlocation) AS trialunitlocation, ';
      $trialunitloc_sql   .= 'ST_AsText(ST_Centroid(geometry(trialunitlocation))) AS trialunitcentroid ';
      $trialunitloc_sql   .= 'FROM trialunitloc ';
      $trialunitloc_sql   .= $gis_where;

      $self->logger->debug("Trial Unit Location $trialunitloc_sql");

      my $sth_gis = $dbh_gis->prepare($trialunitloc_sql);
      $sth_gis->execute();

      if (!$dbh_gis->err()) {

        my $gis_href = $sth_gis->fetchall_hashref('trialunitid');

        if (!$sth_gis->err()) {

          $trial_unit_loc_gis = $gis_href;
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

      $dbh_gis->disconnect();
    }
  }

  $dbh->disconnect();

  my $trial_unit_loc_gis_count = scalar(keys(%{$trial_unit_loc_gis}));
  $self->logger->debug("GIS trial unit loc count: $trial_unit_loc_gis_count");

  my $perm_lookup  = {'0' => 'None',
                      '1' => 'Link',
                      '2' => 'Write',
                      '3' => 'Write/Link',
                      '4' => 'Read',
                      '5' => 'Read/Link',
                      '6' => 'Read/Write',
                      '7' => 'Read/Write/Link',
  };

  my @extra_attr_trial_unit_data;

  for my $row (@{$data_aref}) {

    my $trial_unit_id = $row->{'TrialUnitId'};
    my $permission    = $row->{'UltimatePerm'};

    my $trial_unit_centroid = $trial_unit_loc_gis->{$trial_unit_id}->{'trialunitcentroid'};
    $trial_unit_centroid    =~ /POINT\((.+) (.+)\)/;
    my $longitude     = $1;
    my $latitude      = $2;

    if ($field_list_loc_href->{'LCol*'} || $field_list_loc_href->{'Longitude'}) {

      $row->{'Longitude'} = $longitude;
    }

    if ($field_list_loc_href->{'LCol*'} || $field_list_loc_href->{'Latitude'}) {

      $row->{'Latitude'}  = $latitude;
    }

    if ($field_list_loc_href->{'LCol*'} || $field_list_loc_href->{'trialunitlocation'}) {

      $row->{'trialunitlocation'} = $trial_unit_loc_gis->{$trial_unit_id}->{'trialunitlocation'};
    }

    $row->{'trialunitlocdt'} = $trial_unit_loc_gis->{$trial_unit_id}->{'trialunitlocdt'};

    $row->{'trialunitlocdescription'} = $trial_unit_loc_gis->{$trial_unit_id}->{'description'};

    if ($extra_attr_yes) {

      if (defined($tu_specimen_href->{$trial_unit_id})) {

        my $specimen_aref  = $tu_specimen_href->{$trial_unit_id};
        $row->{'Specimen'} = $specimen_aref;
      }

      if (defined($tu_keyword_href->{$trial_unit_id})) {

        my $keyword_aref  = $tu_keyword_href->{$trial_unit_id};
        $row->{'Keyword'} = $keyword_aref;
      }

      if (defined($tu_treatment_href->{$trial_unit_id})) {
        my $treatment_aref = $tu_treatment_href->{$trial_unit_id};
        $row->{'Treatment'} = $treatment_aref;
      }

      $row->{'UltimatePermission'} = $perm_lookup->{$permission};

      if ( ($permission & $READ_WRITE_PERM) == $READ_WRITE_PERM ) {

        $row->{'update'}       = "update/trialunit/$trial_unit_id";
        $row->{'addSpecimen'}  = "trialunit/$trial_unit_id/add/specimen";
        $row->{'listSpecimen'} = "trialunit/$trial_unit_id/list/specimen";
        $row->{'addKeyword'}   = "trialunit/$trial_unit_id/add/keyword";

        if ( $not_used_id_href->{$trial_unit_id} ) {

          $row->{'delete'}   = "delete/trialunit/$trial_unit_id";
        }
      }
    }
    push(@extra_attr_trial_unit_data, $row);
  }

  return ($err, $msg, \@extra_attr_trial_unit_data);
}



sub get_trial_unit_runmode {

=pod get_trial_unit_HELP_START
{
"OperationName": "Get trial unit",
"Description": "Get detailed information about trial unit specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='TrialUnit' /><TrialUnit SourceTrialUnitId='' update='update/trialunit/6' TrialUnitBarcode='BAR77863798194' TrialId='9' Latitude='-35.3047970307747' ReplicateNumber='2' TrialUnitZ='' TrialUnitEntryId='' listSpecimen='trialunit/6/list/specimen' TrialUnitTypeId='' trialunitlocation='GEOMETRYCOLLECTION(POLYGON((149.05803801025291 -35.28275454804866,149.06078459228328 -35.315257984493236,149.12120939696936 -35.31637855978221,149.05803801025291 -35.28275454804866)))' addSpecimen='trialunit/6/add/specimen' TrialUnitX='' TrialUnitPosition='' TrialUnitY='2745' SiteName='DArT Test Site' trialunitlocdt='2023-04-11 05:19:36' UltimatePermission='Read/Write/Link' trialunitlocdescription='' addKeyword='trialunit/6/add/keyword' TrialUnitId='6' Longitude='149.08001066650183' SampleSupplierId='1' TrialUnitNote='Trial unit part of automatic testing' SiteId='12' UltimatePerm='7'><Specimen PlantDate='2011-09-01' HarvestDate='2008-08-01' Notes='none' TrialUnitSpecimenId='26' TUSBarcode='' SpecimenNumber='0' Pedigree='' SpecimenName='Specimen4TrialUnit_94277815385' TUSLabel='' TrialUnitId='6' ItemId='' HasDied='' SpecimenId='7'/></TrialUnit></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'TrialUnit'}],'TrialUnit' : [{ 'TrialUnitZ' : null, 'ReplicateNumber' : 2, 'Latitude' : '-35.3047970307747', 'TrialUnitEntryId' : null, 'SourceTrialUnitId' : null, 'update' : 'update/trialunit/6', 'TrialId' : 9, 'TrialUnitBarcode' : 'BAR77863798194', 'Specimen' : [ { 'HarvestDate' : '2008-08-01', 'PlantDate' : '2011-09-01', 'Notes' : 'none', 'TrialUnitSpecimenId' : 26, 'TUSBarcode' : null, 'SpecimenNumber' : 0, 'Pedigree' : '', 'SpecimenName' : 'Specimen4TrialUnit_94277815385', 'TrialUnitId' : 6, 'TUSLabel' : null, 'ItemId' : null, 'HasDied' : null, 'SpecimenId' : 7 }], 'addSpecimen' : 'trialunit/6/add/specimen', 'TrialUnitX' : null, 'trialunitlocation' : 'GEOMETRYCOLLECTION(POLYGON((149.05803801025291 -35.28275454804866,149.06078459228328 -35.315257984493236,149.12120939696936 -35.31637855978221,149.05803801025291 -35.28275454804866)))', 'TrialUnitTypeId' : null, 'listSpecimen' : 'trialunit/6/list/specimen', 'TrialUnitPosition' : null, 'addKeyword' : 'trialunit/6/add/keyword', 'trialunitlocdescription' : '', 'TrialUnitId' : 6, 'Longitude' : '149.08001066650183', 'trialunitlocdt' : '2023-04-11 05:19:36', 'SiteName' : 'DArT Test Site', 'TrialUnitY' : 2745, 'UltimatePermission' : 'Read/Write/Link', 'TrialUnitNote' : 'Trial unit part of automatic testing', 'SiteId' : 12, 'UltimatePerm' : 7, 'SampleSupplierId' : 1 }]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TrialUnit (100) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'TrialUnit (100) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialUnitId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self          = shift;
  my $trial_unit_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();
  my $trial_id = read_cell_value($dbh, 'trialunit', 'TrialId', 'TrialUnitId', $trial_unit_id);

  if (length($trial_id) == 0) {

    my $err_msg = "TrialUnit ($trial_unit_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'trial');

  my $sql      = "SELECT $perm_str AS UltimatePermission ";
  $sql        .= 'FROM trial ';
  $sql        .= 'WHERE TrialId=?';

  my ($read_err, $permission) = read_cell($dbh, $sql, [$trial_id]);

  if ( ($permission & $READ_PERM) != $READ_PERM ) {

    my $err_msg = "Trial ($trial_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $field_list = ['trialunit.*', "site.SiteName", 'VCol*', "$perm_str AS UltimatePerm"];

  my $other_join = ' LEFT JOIN trial ON trialunit.TrialId = trial.TrialId ';
  $other_join   .= ' LEFT JOIN site ON trial.SiteId = site.SiteId ';

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $field_list, 'trialunit',
                                                                        'TrialUnitId', $other_join);

  $dbh->disconnect();

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
  }

  $self->logger->debug('Number of vcols: ' . scalar(@{$vcol_list}));

  my $where_clause = " WHERE (($perm_str) & $READ_PERM) = $READ_PERM AND trialunit.TrialUnitId=? ";

  $sql =~ s/GROUP BY/ $where_clause GROUP BY /;

  $self->logger->debug("SQL with VCol: $sql");

  my ($trial_unit_err, $trial_unit_msg, $trial_unit_data) = $self->list_trial_unit(1, ['LCol*'], $sql, [$trial_unit_id]);

  if ($trial_unit_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'geojson'}   = 1;
  $data_for_postrun_href->{'GJSonInfo'} = {'GeometryField' => 'trialunitlocation',
                                           'FeatureName'   => 'Specimen[0] [ name: Specimen->SpecimenName ]',
                                           'FeatureId'     => 'TrialUnitId',
  };
  $data_for_postrun_href->{'Data'}  = {'TrialUnit'  => $trial_unit_data,
                                       'VCol'       => $vcol_list,
                                       'RecordMeta' => [{'TagName' => 'TrialUnit'}],
  };

  return $data_for_postrun_href;
}

sub update_trial_unit_runmode {

=pod update_trial_unit_HELP_START
{
"OperationName": "Update trial unit",
"Description": "Update trial unit specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "trialunit",
"SkippedField": ["TrialId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='TrialUnit (1) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'TrialUnit (1) has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TrialUnit (100) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'TrialUnit (100) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialUnitId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self          = shift;
  my $trial_unit_id = $self->param('id');
  my $query         = $self->query();

  my $data_for_postrun_href = {};
  my $trial_unit_err_aref = [];
  my $trial_unit_err = 0;

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'TrialId' => 1};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'trialunit', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $dbh_k_write = connect_kdb_write();

  my $read_tr_u_sql    =   'SELECT TrialId, SourceTrialUnitId, SampleSupplierId, TrialUnitNote, TrialUnitBarcode ';
     $read_tr_u_sql   .=   'FROM trialunit WHERE TrialUnitId=? ';

  my ($r_df_val_err, $r_df_val_msg, $trial_u_df_val_data) = read_data($dbh_k_write, $read_tr_u_sql, [$trial_unit_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve trialunit default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $trial_id            =  undef;
  my $src_trial_unit_id   =  undef;
  my $sample_supplier_id  =  undef;
  my $trial_unit_comment  =  undef;
  my $barcode             =  undef;
  # Issue9468
  # my $treatment_id        =  undef;


  my $nb_df_val_rec    =  scalar(@{$trial_u_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve trialunit default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }


  $trial_id            =  $trial_u_df_val_data->[0]->{'TrialId'};
  $src_trial_unit_id   =  $trial_u_df_val_data->[0]->{'SourceTrialUnitId'};
  $sample_supplier_id  =  $trial_u_df_val_data->[0]->{'SampleSupplierId'};
  $trial_unit_comment  =  $trial_u_df_val_data->[0]->{'TrialUnitNote'};
  $barcode             =  $trial_u_df_val_data->[0]->{'TrialUnitBarcode'};


  if (length($trial_id) == 0) {

    my $err_msg = "TrialUnit ($trial_unit_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'trial');

  my $sql   = "SELECT $perm_str AS UltimatePermission ";
  $sql     .= 'FROM trial ';
  $sql     .= 'WHERE TrialId=?';

  my ($read_err, $permission) = read_cell($dbh_k_write, $sql, [$trial_id]);

  if ( ($permission & $READ_WRITE_PERM) != $READ_WRITE_PERM ) {

    my $err_msg = "Trial ($trial_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $replicate_number    = $query->param('ReplicateNumber');


  if (length($src_trial_unit_id) == 0) {

    $src_trial_unit_id = undef;
  }

  if (defined $query->param('SourceTrialUnitId')) {

    if (length($query->param('SourceTrialUnitId')) > 0) {

      $src_trial_unit_id = $query->param('SourceTrialUnitId');
    }
  }

  if (defined $query->param('SampleSupplierId')) {

    if (length($query->param('SampleSupplierId')) > 0) {

      $sample_supplier_id = $query->param('SampleSupplierId');
    }
  }

  if (defined $query->param('TrialUnitNote')) {

     $trial_unit_comment = $query->param('TrialUnitNote');
  }


  if (length($barcode) == 0) {

    $barcode = undef;
  }

  if (defined $query->param('TrialUnitBarcode')) {

    if (length($query->param('TrialUnitBarcode')) > 0) {

      $barcode = $query->param('TrialUnitBarcode');
    }
  }

  if ( defined $barcode ) {

    my $barcode_sql = 'SELECT TrialUnitId FROM trialunit WHERE TrialUnitId<>? AND TrialUnitBarcode=?';

    my ($r_barcode_err, $db_trial_unit_id) = read_cell($dbh_k_write, $barcode_sql, [$trial_unit_id, $barcode]);

    if ($r_barcode_err) {

      $self->logger->debug("Check barcode failed.");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    if (length($db_trial_unit_id) > 0) {

      my $err_msg = "TrialUnitBarcode ($barcode): already exists.";
      
      push(@{$trial_unit_err_aref}, {'TrialUnitBarcode' => $err_msg});
      $trial_unit_err = 1;
    }
  }

  if (defined $src_trial_unit_id) {

    if (!record_existence($dbh_k_write, 'trialunit', 'TrialUnitId', $src_trial_unit_id)) {

      my $err_msg = "SourceTrialUnitId ($src_trial_unit_id) not found.";

      push(@{$trial_unit_err_aref}, {'SourceTrialUnitId' => $err_msg});
      $trial_unit_err = 1;
    }
  }

  $sql = 'SELECT Dimension FROM trialdimension WHERE TrialId=?';

  my ($r_di_err, $r_di_msg, $dimension_aref) = read_data($dbh_k_write, $sql, [$trial_id]);

  if ($r_di_err) {

    $self->logger->debug("Read trial dimension failed: $r_di_msg");
    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$dimension_aref}) == 0) {

    my $err_msg = "Trial ($trial_id): no dimension defined.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dimension_provided = 0;

  my @dimension_val_list;
  my @dimension_sql_list;
  my @user_dimension_list;

  for my $dimension_rec (@{$dimension_aref}) {

    my $dimension = $dimension_rec->{'Dimension'};

    if (defined $query->param("TrialUnit${dimension}")) {

      if (length($query->param("TrialUnit${dimension}")) > 0) {

        $dimension_provided = 1;

        my $dimension_val = $query->param("TrialUnit${dimension}");

        if ($dimension ne 'Position') {

          if ( $dimension_val !~ /^\d+$/ ) {

            my $err_msg = "TrialUnit${dimension} ($dimension_val): not a positive integer.";

              push(@{$trial_unit_err_aref}, {"TrialUnit${dimension}"=> $err_msg});
              $trial_unit_err = 1;
          }
        }

        push(@dimension_val_list, $dimension_val);
        push(@dimension_sql_list, "TrialUnit${dimension}=?");
        push(@user_dimension_list, $dimension);
      }
    }
  }

  if ($dimension_provided == 0) {

    my $err_msg = "No dimension value provided.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_k_read = connect_kdb_read();

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength, FactorValidRuleErrMsg, FactorValidRule  ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='trialunitfactor'";

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
      'CanFactorHaveNull' => $vcol_data->{$vcol_id}->{'CanFactorHaveNull'}
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

  $dbh_k_read->disconnect();

  $sql = 'SELECT TrialUnitId FROM trialunit WHERE TrialId=? AND TrialUnitId <> ? AND ' . join(' AND ', @dimension_sql_list);

  my ($r_tu_id_err, $db_trialunit_id) = read_cell($dbh_k_write, $sql, [$trial_id, $trial_unit_id, @dimension_val_list]);

  if ($r_tu_id_err) {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_trialunit_id) > 0) {

    my $err_msg = "Dimension (" . join(',', @user_dimension_list) . ") value (" . join(',', @dimension_val_list) . '): ';
    $err_msg   .= 'already used.';

    foreach my $dim_name (@user_dimension_list) {
      push(@{$trial_unit_err_aref}, {"TrialUnit${dim_name}" => $err_msg});
    }
    
    $trial_unit_err = 1;
  }

  my ($vcol_error, $vcol_error_aref) = validate_all_factor_input($pre_validate_vcol);

  if ($vcol_error) {
    push(@{$trial_unit_err_aref}, @{$vcol_error_aref});
    $trial_unit_err = 1;
  }

   if ($trial_unit_err != 0) {
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => $trial_unit_err_aref};
    return $data_for_postrun_href;
  }


  $self->logger->debug("Parameter list: " . join(',', ($sample_supplier_id,
                                                      $replicate_number, $barcode, $trial_unit_comment,
                                                      $src_trial_unit_id, $trial_unit_id ) ) );

  $sql    = 'UPDATE trialunit SET ';
  $sql   .= 'SampleSupplierId=?, ';
  $sql   .= 'ReplicateNumber=?, ';
  $sql   .= 'TrialUnitBarcode=?, ';
  $sql   .= 'TrialUnitNote=?, ';
  $sql   .= 'SourceTrialUnitId=?, ';
  $sql   .= join(',', @dimension_sql_list);
  $sql   .= ' WHERE TrialUnitId=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($sample_supplier_id, $replicate_number,
                $barcode, $trial_unit_comment, $src_trial_unit_id, @dimension_val_list,
                $trial_unit_id
               );

  if ($dbh_k_write->err()) {

    $self->logger->debug("Update trialunit failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  for my $vcol_id (keys(%{$vcol_data})) {

    if (defined $query->param('VCol_' . "$vcol_id")) {

      my $factor_value = $query->param('VCol_' . "$vcol_id");

      my ($vcol_err, $vcol_msg) = update_factor_value($dbh_k_write, $vcol_id, $factor_value, 'trialunitfactor', 'TrialUnitId', $trial_unit_id);

      if ($vcol_err) {

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'} = {'Error' => [{'Message' => $vcol_msg}]};

        return $data_for_postrun_href;
      }
    }
  }

  $dbh_k_write->disconnect();

  my $info_msg_aref = [{'Message' => "TrialUnit ($trial_unit_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}


sub update_trial_unit_geography_runmode {
=pod update_trial_unit_geography_HELP_START
{
"OperationName": "Update trial unit location",
"Description": "Updates trial unit's geographical position.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='TrialUnit (1) geography has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'TrialUnit (1) geography has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TrialUnit (100) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'TrialUnit (100) not found.'}]}"}],
"HTTPParameter": [{"Name": "trialunitlocation", "DataType": "polygon_wkt", "Description": "GIS field defining the polygon geometry object of the trial unit in a standard GIS well-known text.", "Type": "LCol", "Required": "1"},{"Name": "trialunitlocationdt", "DataType": "timestamp", "Description": "DateTime of trial unit location", "Type": "LCol", "Required": "0"},{"Name": "currentloc", "DataType": "tinyint", "Description": "Flag to notify current location", "Type": "LCol", "Required": "0"},{"Name": "description", "DataType": "varchar", "Description": "Description for location", "Type": "LCol", "Required": "0"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialUnitId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self          = shift;
  my $trial_unit_id = $self->param('id');
  my $query         = $self->query();

  my $data_for_postrun_href = {};

  my $dbh_k_read = connect_kdb_read();

  my $trial_id = read_cell_value($dbh_k_read, 'trialunit', 'TrialId', 'TrialUnitId', $trial_unit_id);


  if (length($trial_id) == 0) {

    my $err_msg = "TrialUnit ($trial_unit_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'trial');
  my $sql      = "SELECT $perm_str AS UltimatePermission ";
  $sql        .= 'FROM trial ';
  $sql        .= 'WHERE TrialId=?';

  my ($read_err, $permission) = read_cell($dbh_k_read, $sql, [$trial_id]);

  $dbh_k_read->disconnect();

  if ( ($permission & $READ_WRITE_PERM) != $READ_WRITE_PERM ) {

    my $err_msg = "Trial ($trial_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sub_PGIS_val_builder = sub {
    return "ST_ForceCollection(ST_GeomFromText(?, -1))";
  };

  my ($err, $err_msg) = append_geography_loc(
                                              "trialunit",
                                              $trial_unit_id,
                                              ['POINT', 'POLYGON', 'MULTIPOLYGON'],
                                              $query,
                                              $sub_PGIS_val_builder,
                                              $self->logger,
                                            );

  if ($err) {
    $data_for_postrun_href = $self->_set_error($err_msg);
  } else {
    my $info_msg_aref = [{'Message' => "TrialUnit ($trial_unit_id) location has been updated successfully."}];
    $data_for_postrun_href->{'Error'}     = 0;
    $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
    $data_for_postrun_href->{'ExtraData'} = 0;
  }

  return $data_for_postrun_href;
}

sub list_trial_unit_specimen {

  my $self              = $_[0];
  my $extra_attr_yes    = $_[1];
  my $sql               = $_[2];
  my $where_para_aref   = $_[3];

  my $err = 0;
  my $msg = '';

  my $data_aref = [];

  my $dbh = connect_kdb_read();

  ($err, $msg, $data_aref) = read_data($dbh, $sql, $where_para_aref);

  if ($err) {

    return ($err, $msg, []);
  }

  $dbh->disconnect();

  my $extra_attr_tunit_specimen_data = [];

  if ($extra_attr_yes) {

    my $perm_lookup  = {'0' => 'None',
                        '1' => 'Link',
                        '2' => 'Write',
                        '3' => 'Write/Link',
                        '4' => 'Read',
                        '5' => 'Read/Link',
                        '6' => 'Read/Write',
                        '7' => 'Read/Write/Link',
    };

    my $tu_spec_id_aref = [];

    for my $row (@{$data_aref}) {

      push(@{$tu_spec_id_aref}, $row->{'TrialUnitSpecimenId'});
    }

    my $chk_id_err        = 0;
    my $chk_id_msg        = '';
    my $used_id_href      = {};
    my $not_used_id_href  = {};

    if (scalar(@{$tu_spec_id_aref}) > 0) {

      my $chk_table_aref = [{'TableName' => 'item', 'FieldName' => 'TrialUnitSpecimenId'}];

      ($chk_id_err, $chk_id_msg,
       $used_id_href, $not_used_id_href) = id_existence_bulk($dbh, $chk_table_aref, $tu_spec_id_aref);

      if ($chk_id_err) {

        $self->logger->debug("Check id existence error: $chk_id_msg");
        $err = 1;
        $msg = $chk_id_msg;

        return ($err, $msg, []);
      }
    }

    for my $row (@{$data_aref}) {

      my $trial_unit_specimen_id   = $row->{'TrialUnitSpecimenId'};
      my $permission               = $row->{'UltimatePerm'};
      $row->{'UltimatePermission'} = $perm_lookup->{$permission};

      if ( ($permission & $READ_WRITE_PERM) == $READ_WRITE_PERM ) {

        $row->{'update'} = "update/trialunitspecimen/$trial_unit_specimen_id";

        if ( $not_used_id_href->{$trial_unit_specimen_id} ) {

          $row->{'remove'} = "delete/trialunitspecimen/$trial_unit_specimen_id";
        }
      }

      push(@{$extra_attr_tunit_specimen_data}, $row);
    }
  }
  else {

    $extra_attr_tunit_specimen_data = $data_aref;
  }

  return ($err, $msg, $extra_attr_tunit_specimen_data);
}

sub update_trial_unit_bulk_runmode {

=pod update_trial_unit_bulk_HELP_START
{
"OperationName": "Update trial units in the trial in bulk",
"Description": "Update trial units in bulk in the trial specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='1 TrialUnits for Trial (1) have been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : '1 TrialUnits for Trial (3) have been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Treatment (1872) does not exist.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Treatment (1872) does not exist.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "XML",
"UploadFileParameterName": "uploadfile",
"DTDFileNameForUploadXML": "updatetrialunitbulk.dtd",
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialId"}],
"HTTPParameter": [{"Name": "Force", "Description": "0|1 flag. By default, it is 0. When force is set to 1, DAL will skip the checking of TULastUpdateTimeStamp. Only admin user can set this flag to 1.", "Required": "0"}, {"Name": "TULastUpdateTimeStamp", "Description": "Time stamp for the last update of trial units. This value is stored in the trial table and it must correctly matched for the update to succeed.", "Required": "1"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = shift;
  my $query = $self->query();
  my $trial_id = $self->param('id');
  my $force = 0;
  if (defined $query->param('Force')) {
    if ($query->param('Force') =~ /^0|1$/) {
      $force = $query->param('Force');
    }
  }

  my $data_for_postrun_href = {};
  my $per_trialunit_error = {};
  my $trial_unit_err_aref = [];
  my $trial_unit_err = 0;


  # Validate XML file
  my $trialunit_info_xml_file = $self->authen->get_upload_file();
  $self->logger->debug($trialunit_info_xml_file);
  my $update_trialunit_dtd_file = $self->get_updatetrialunit_bulk_dtd_file();
  $self->logger->debug('DOCUMENT_ROOT: ' . $ENV{DOCUMENT_ROOT});
  $self->logger->debug('DTD FILE: ' . $update_trialunit_dtd_file);
  add_dtd($update_trialunit_dtd_file, $trialunit_info_xml_file);
  my $xml_checker_parser = new XML::Checker::Parser( Handlers => { } );
  eval {
    local $XML::Checker::FAIL = sub {
      my $code = shift;
      my $err_str = XML::Checker::error_string ($code, @_);
      $self->logger->debug("XML Parsing ERR: $code : $err_str");
      die $err_str;
    };
    $xml_checker_parser->parsefile($trialunit_info_xml_file);
  };
  if ($@) {
    my $err_msg = $@;
    $self->logger->debug("Parsing XML error: $err_msg");
    my $user_err_msg = "Uploaded xml file does not comply with its definition.\n";
    $user_err_msg   .= "Details: $err_msg";
    $data_for_postrun_href = $self->_set_error($user_err_msg);
    return $data_for_postrun_href;
  }


  my $sql;
  my $bulk_sql;
  my $dbh_k_write = connect_kdb_write(1);
  my $dbh_gis_write = connect_gis_write();
  eval {

    if (!record_existence($dbh_k_write, 'trial', 'TrialId', $trial_id)) {
      $data_for_postrun_href = $self->_set_error("Trial ($trial_id) does not exist.");
      return 1;
    }
    my $group_id  = $self->authen->group_id();
    my $gadmin_status = $self->authen->gadmin_status();
    my ($is_trial_ok, $trouble_trial_id_aref) = check_permission($dbh_k_write, 'trial', 'TrialId',
                                                                  [$trial_id], $group_id, $gadmin_status,
                                                                  $READ_WRITE_PERM);
    if (!$is_trial_ok) {
      my $trouble_trial_id = $trouble_trial_id_aref->[0];
      $data_for_postrun_href = $self->_set_error("Permission denied: Group ($group_id) and Trial ($trouble_trial_id).");
      return 1;
    }


    my $dimension_href = {};
    my @dimension_field_list = ();
    $sql = 'SELECT Dimension FROM trialdimension WHERE TrialId=?';
    my ($r_di_err, $r_di_msg, $dimension_aref) = read_data($dbh_k_write, $sql, [$trial_id]);
    if ($r_di_err) {
      $self->logger->debug("Read trial dimension failed: $r_di_msg");
      $data_for_postrun_href = $self->_set_error();
      return 1;
    }
    if (!scalar(@$dimension_aref)) {
      $data_for_postrun_href = $self->_set_error("Trial ($trial_id): no dimension defined.");
      return 1;
    }
    for my $dimension (@$dimension_aref) {
      my $dimension_name = $dimension->{'Dimension'};
      push(@dimension_field_list, "TrialUnit${dimension_name}");
      $dimension_href->{"TrialUnit${dimension_name}"} = 1;
    }


    my $tu_last_update_ts = $query->param('TULastUpdateTimeStamp');
    my $shouldCheckAdmin = 0;
    if (length($tu_last_update_ts)) {
      my ($tu_last_update_ts_err, $tu_last_update_ts_href) = check_dt_href({'TULastUpdateTimeStamp' => $tu_last_update_ts});
      if ($tu_last_update_ts_err) {
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'} = {'Error' => [$tu_last_update_ts_href]};
        return 1;
      }
      $sql = "SELECT TULastUpdateTimeStamp FROM trial WHERE TrialId=?";
      my ($r_t_ts_err, $db_tu_last_update_ts) = read_cell($dbh_k_write, $sql, [$trial_id]);
      if ($r_t_ts_err) {
        $self->logger->debug($db_tu_last_update_ts);
        $data_for_postrun_href = $self->_set_error();
        return 1;
      } elsif ($tu_last_update_ts ne $db_tu_last_update_ts) {
        if ($force) {
          $shouldCheckAdmin = 1;
        } else {
          $data_for_postrun_href = $self->_set_error("Operation failed due to timestamp mismatched. $db_tu_last_update_ts vs $tu_last_update_ts");
          return 1;
        }
      }
    } elsif (!$force) {
      $data_for_postrun_href = $self->_set_error("TULastUpdateTimeStamp is missing.");
      return 1;
    } else {
      $shouldCheckAdmin = 1;
    }

    if ($shouldCheckAdmin && !$self->authen->gadmin_status()) {
      $data_for_postrun_href = $self->_set_error("Can't set a force flag. Not an admin.");
      return 1;
    }

    my $cur_dt = DateTime->now( time_zone => $TIMEZONE );
    $cur_dt = DateTime::Format::MySQL->format_datetime($cur_dt);
    $sql  = 'UPDATE trial SET ';
    $sql .= 'TULastUpdateTimeStamp=? ';
    $sql .= 'WHERE TrialId=?';
    my $sth = $dbh_k_write->prepare($sql);
    $sth->execute($cur_dt, $trial_id);
    if ($dbh_k_write->err()) {
      $data_for_postrun_href = $self->_set_error();
      return 1;
    }

    my ($get_scol_err, $get_scol_msg, $scol_data, $pkey_data) = get_static_field($dbh_k_write, 'trialunit');
    if ($get_scol_err) {
      $self->logger->debug("Get static field info failed: $get_scol_msg");
      $data_for_postrun_href = $self->_set_error();
      return 1;
    }


    my $trialunit_info_xml  = read_file($trialunit_info_xml_file);
    my $trialunit_info_aref = xml2arrayref($trialunit_info_xml, 'trialunit');

    # First pass
    my $uniq_barcode        = {};
    my $uniq_unitposition   = {};
    my $uniq_entry_id_href  = {};
    my $uniq_coord_href     = {};
    my $trialUnitId2XYZ     = {};
    my $isUpdating          = {};
    for my $trialunit (@$trialunit_info_aref) {

      my $colsize_info = {};
      my $chk_maxlen_field_href = {};
      for my $static_field (@$scol_data) {
        my $field_name  = $static_field->{'Name'};
        my $field_dtype = $static_field->{'DataType'};
        if (lc($field_dtype) eq 'varchar') {
          $chk_maxlen_field_href->{$field_name}  = $trialunit->{$field_name};
          $colsize_info->{$field_name} = $static_field->{'ColSize'};
        }
      }
      my ($maxlen_err, $maxlen_msg_href) = check_maxlen_href($chk_maxlen_field_href, $colsize_info);
      if ($maxlen_err) {
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'} = {'Error' => [$maxlen_msg_href]};
        return 1;
      }

      my $trialUnitId = $trialunit->{TrialUnitId};
      if (!length($trialUnitId)) {
        $data_for_postrun_href = $self->_set_error("TrialUnitId is missing.");
        return 1;
      }
      $sql = "SELECT TrialId FROM trialunit WHERE TrialUnitId = ?";
      my ($r_t_id_err, $db_trial_id) = read_cell($dbh_k_write, $sql, [$trialUnitId]);
      if ($r_t_id_err) {
        $self->logger->debug($db_trial_id);
        $data_for_postrun_href = $self->_set_error();
        return 1;
      } elsif (!length($db_trial_id)) {
        $data_for_postrun_href = $self->_set_error("Trialunit ($trialUnitId) not found.");
        return 1;
      } elsif ($db_trial_id != $trial_id) {
        $data_for_postrun_href = $self->_set_error("Trialunit ($trialUnitId) does not belong to trial ($trial_id).");
        return 1;
      }
      $isUpdating->{$trialUnitId} = 1;


      if (length($trialunit->{TreatmentId})) {
        my $treatment_id = $trialunit->{TreatmentId};
        if (!record_existence($dbh_k_write, 'treatment', 'TreatmentId', $treatment_id)) {
          $data_for_postrun_href = $self->_set_error("Treatment ($treatment_id) not found.");
          return 1;
        }
      }


      if (length($trialunit->{SourceTrialUnitId})) {
        my $src_trial_unit_id = $trialunit->{SourceTrialUnitId};
        if (!record_existence($dbh_k_write, 'trialunit', 'TrialUnitId', $src_trial_unit_id)) {
          $data_for_postrun_href = $self->_set_error("SourceTrialUnitId ($src_trial_unit_id): not found.");
          return 1;
        }
      }


      if (length($trialunit->{ReplicateNumber})) {
        my $replicate_number = $trialunit->{ReplicateNumber};
        if ($replicate_number !~ /^\d+$/) {
          $data_for_postrun_href = $self->_set_error("ReplicateNumber ($replicate_number): not a positive integer.");
          return 1;
        }
      } else {
        $data_for_postrun_href = $self->_set_error("ReplicateNumber is missing.");
        return 1;
      }


      if (length($trialunit->{SampleSupplierId})) {
        my $sample_supplier_id = $trialunit->{SampleSupplierId};
        if ($sample_supplier_id !~ /^\d+$/) {
          $data_for_postrun_href = $self->_set_error("SampleSupplierId ($sample_supplier_id): not a positive integer.");
          return 1;
        }
      }


      if (length($trialunit->{TrialUnitBarcode})) {
        my $barcode = $trialunit->{TrialUnitBarcode};
        if (exists $uniq_barcode->{$barcode}) {
          $data_for_postrun_href = $self->_set_error("TrialUnitBarcode ($barcode): duplicate in xml file.");
          return 1;
        } else {
          $uniq_barcode->{$barcode} = 1;
        }
      }


      my @dims = ();
      foreach my $dimension (@dimension_field_list) {
        if ($dimension eq "TrialUnitPosition") { next; }
        if (length($trialunit->{$dimension})) {
          my $dimVal = $trialunit->{$dimension};
          if ($dimVal !~ /^\d+$/) {
            $data_for_postrun_href = $self->_set_error("$dimension ($dimVal): not a positive integer.");
            return 1;
          }
          #
          if ($dimension eq "TrialUnitEntryId") {
            if (exists $uniq_entry_id_href->{$dimVal}) {
              $data_for_postrun_href = $self->_set_error("TrialUnitEntryId ($dimVal): duplicate in xml file.");
              return 1;
            } else {
              $uniq_entry_id_href->{$dimVal} = 1;
            }
          } else { # X, Y, Z
            push(@dims, "$dimension = $dimVal");
          }
        } else {
          $data_for_postrun_href = $self->_set_error("$dimension is missing.");
          return 1;
        }
      }
      if (scalar(@dims)) {
        my $dimStr = join(" AND ", @dims);
        if (exists $uniq_coord_href->{$dimStr}) {
          $data_for_postrun_href = $self->_set_error("Dimension duplicate in xml file.");
          return 1;
        } else {
          $uniq_coord_href->{$dimStr} = 1;
        }
        $trialUnitId2XYZ->{$trialUnitId} = $dimStr;
      }


      if (length($trialunit->{trialunitlocation})) {
        my $trialunit_location = $trialunit->{trialunitlocation};
        my ($is_wkt_err, $wkt_err_href) = is_valid_wkt_href($dbh_gis_write,
                                                            {'trialunitlocation' => $trialunit_location},
                                                            'POINT');
        if ($is_wkt_err) {
          $self->logger->debug("Trial unit location: $trialunit_location");
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [$wkt_err_href]};
          return 1;
        }
      }


      my $tu_specimen_aref = $trialunit->{trialunitspecimen};
      if (!defined($tu_specimen_aref)) { 
        next; # TODO: can we allow this ?
      } elsif (ref $tu_specimen_aref ne "ARRAY") {
        $tu_specimen_aref = [$tu_specimen_aref];
        $trialunit->{trialunitspecimen} = $tu_specimen_aref;
      }

      my $tu_factor_aref = $trialunit->{trialunitfactor};
      if (!defined($tu_factor_aref)) { 
        next; # TODO: can we allow this ?
      } elsif (ref $tu_factor_aref ne "ARRAY") {
        $tu_factor_aref = [$tu_factor_aref];
        $trialunit->{trialunitfactor} = $tu_factor_aref;
      }
 

      my @geno_id_list;
      my $uniq_spec_href = {};
      for my $trialunitspecimen (@$tu_specimen_aref) {

        my $specimen_id = $trialunitspecimen->{'SpecimenId'};

        # GenotypeId
        $sql = 'SELECT GenotypeId FROM genotypespecimen WHERE SpecimenId=?';
        my $sth = $dbh_k_write->prepare($sql);
        $sth->execute($specimen_id);
        if ($dbh_k_write->err()) {
          $data_for_postrun_href = $self->_set_error();
          return 1;
        }
        my $genotype_id_href = $sth->fetchall_hashref('GenotypeId');
        my @geno_id = keys(%$genotype_id_href);
        if (scalar(@geno_id) == 0) {
          $data_for_postrun_href = $self->_set_error("Specimen ($specimen_id) does not exist.");
          return 1;
        }
        push(@geno_id_list, @geno_id);


        # Specimen number
        my $spec_num = 0;
        if (length($trialunitspecimen->{SpecimenNumber})) {
          $spec_num = $trialunitspecimen->{SpecimenNumber};
        }
        if (exists $uniq_spec_href->{"${specimen_id}_${spec_num}"}) {
          $data_for_postrun_href = $self->_set_error("Specimen ($specimen_id, $spec_num): duplicate in xml file.");
          return 1;
        } else {
          $uniq_spec_href->{"${specimen_id}_${spec_num}"} = 1;
        }


        # ItemId
        if (length($trialunitspecimen->{ItemId})) {
          my $item_id = $trialunitspecimen->{ItemId};
          if (!record_existence($dbh_k_write, 'item', 'ItemId', $item_id)) {
            $data_for_postrun_href = $self->_set_error("Item ($item_id) does not exist.");
            return 1;
          }
        }


        # PlantDate
        my $plant_date = $trialunitspecimen->{'PlantDate'};
        if (length($plant_date) && (!($plant_date =~ /\d{4}\-\d{2}\-\d{2}/))) {
          $data_for_postrun_href = $self->_set_error("PlantDate ($plant_date) is not an acceptable date: yyyy-mm-dd");
          return 1;
        }


        # HarvestDate
        my $harvest_date = $trialunitspecimen->{'HarvestDate'};
        if (length($harvest_date) && (!($harvest_date =~ /\d{4}\-\d{2}\-\d{2}/))) {
          $data_for_postrun_href = $self->_set_error("HarvestDate ($harvest_date) is not an acceptable date: yyyy-mm-dd");
          return 1;
        }


        # HasDied
        my $has_died = $trialunitspecimen->{'HasDied'};
        if (length($has_died) && (!($has_died =~ /^[0|1]$/))) {
          $data_for_postrun_href = $self->_set_error("HasDied ($has_died) can be either 1 or 0 only.");
          return 1;
        }
      }

      my ($is_geno_ok, $trouble_geno_id_aref) = check_permission($dbh_k_write, 'genotype', 'GenotypeId',
                                                                \@geno_id_list, $group_id, $gadmin_status,
                                                                $LINK_PERM);

      if (!$is_geno_ok) {
        my $trouble_geno_id_str = join(',', @{$trouble_geno_id_aref});
        $data_for_postrun_href = $self->_set_error("Permission denied: Group ($group_id) and Genotype ($trouble_geno_id_str).");
        return 1;
      }
    }

    my $dbh_k_read = connect_kdb_read();

    $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength, FactorValidRuleErrMsg, FactorValidRule  ";
    $sql   .= "FROM factor ";
    $sql   .= "WHERE TableNameOfFactor='trialunitfactor'";

    my $vcol_data = $dbh_k_read->selectall_hashref($sql, 'FactorId');

    my $vcol_param_data = {};
    my $vcol_len_info   = {};
    my $vcol_param_data_maxlen = {};
    my $pre_validate_vcol = {};

    for my $vcol_id (keys(%{$vcol_data})) {

      my $vcol_param_name = "VCol_${vcol_id}";
      
      $vcol_len_info->{$vcol_param_name} = $vcol_data->{$vcol_id}->{'FactorValueMaxLength'};

      $pre_validate_vcol->{$vcol_param_name} = {
        'Rule' => $vcol_data->{$vcol_id}->{'FactorValidRule'},
        'FactorId'=> $vcol_id,
        'RuleErrorMsg'=> $vcol_data->{$vcol_id}->{'FactorValidRuleErrMsg'},
        'CanFactorHaveNull' => $vcol_data->{$vcol_id}->{'CanFactorHaveNull'}
      };
    }

     #based on the vcol object above, we apply the values based on the input and try to validate and return an error per row.
    #this should be improved so that all trial unit errors are returned at once.

     for my $trialunit (@{$trialunit_info_aref}) {

      my $factor_aref = $trialunit->{'trialunitfactor'};
     
      my $vcol_error_aref = [];
    
      for my $factor_href (@{$factor_aref}) {

        my $vcol_id = $factor_href->{'FactorId'};
        my $vcol_value = $factor_href->{'FactorValue'};

        my $vcol_param_name = "VCol_${vcol_id}";

        $self->logger->debug("$vcol_param_name -> $vcol_value");

        $vcol_len_info->{$vcol_param_name} = $vcol_data->{$vcol_id}->{'FactorValueMaxLength'};
        $vcol_param_data_maxlen->{$vcol_param_name} = $vcol_value;

        if ($vcol_data->{$vcol_id}->{'CanFactorHaveNull'} != 1) {
          $vcol_param_data->{$vcol_param_name} = $vcol_value;
        }

        $pre_validate_vcol->{$vcol_param_name}->{'Value'} = $vcol_value;
      }

      my ($vcol_missing_err, $vcol_missing_href) = check_missing_href( $vcol_param_data );

      if ($vcol_missing_err) {

        push(@{$trial_unit_err_aref},$vcol_missing_href);
        $trial_unit_err = 1;
      }

      my ($vcol_maxlen_err, $vcol_maxlen_href) = check_maxlen_href($vcol_param_data_maxlen, $vcol_len_info);

      if ($vcol_maxlen_err) {

        push(@{$trial_unit_err_aref},$vcol_maxlen_href);
        $trial_unit_err = 1;
      }

      my ($vcol_error, $vcol_error_aref) = validate_all_factor_input($pre_validate_vcol);

      if ($vcol_error) {
        foreach my $vcol_err_href (@{$vcol_error_aref}) {
            for my $error_key (keys(%{$vcol_err_href})) {

              $self->logger->debug("$error_key => ". $vcol_err_href->{$error_key});

            }

        }

        push(@{$trial_unit_err_aref}, @{$vcol_error_aref});
        $trial_unit_err = 1;
      }

      if ($trial_unit_err) {

        push(@{$trial_unit_err_aref}, {'Message' => "VCol Errors in bulk update."});
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => $trial_unit_err_aref};

        return 1;
      }

    }


    $dbh_k_read->disconnect();

    # Second pass
    # Consistency check for TrialUnitBarcode and Dimension
    # Example:
    # TrialUnitBarcode for trialunit A
    # 1: A's barcode is not found in db
    #   1.1: Other trialunit in file F has the same barcode => Error
    #   1.2: No other trialunit in file F has the same barcode => Pass
    # 2: A's barcode is found in db, and from the same trialunit
    #   2.1: Other trialunit in file F has the same barcode => Error
    #   2.2: No other trialunit in file F has the same barcode => Pass
    # 3: A's barcode is found in db, but it belongs to another trialunit B
    #   3.1: B is not in the file F => Error
    #   3.2: B is in the file F
    #       3.2.1: B is not updating barcode => Error
    #       3.2.2: B is updating barcode => Pass
    for my $trialunit (@$trialunit_info_aref) {
      # Consistency check for TrialUnitBarcode
      my $idA = $trialunit->{TrialUnitId};
      my $barcodeA = $trialunit->{TrialUnitBarcode};
      if (length($barcodeA)) {
          my $sql = "SELECT TrialUnitId FROM trialunit WHERE TrialUnitBarcode = ?";
          my $sth = $dbh_k_write->prepare($sql);
          $sth->execute($barcodeA);
          if ($dbh_k_write->err()) {
            $data_for_postrun_href = $self->_set_error();
            return 1;
          }
          my $ids = $sth->fetchall_arrayref();
          if (scalar(@$ids) == 1) {
            my $idB = $ids->[0]->[0];
            if ($idA != $idB) {
              if (exists($isUpdating->{$idB})) {
                $sql = "UPDATE trialunit SET TrialUnitBarcode = null WHERE TrialUnitId = ?";
                $sth = $dbh_k_write->prepare($sql);
                $sth->execute($idB);
                if ($dbh_k_write->err()) {
                  $data_for_postrun_href = $self->_set_error();
                  return 1;
                }
              } else {
                # Another trialunit B already owns this barcode
                # But B is not in the XML file
                $data_for_postrun_href = $self->_set_error("TrialUnitBarcode ($barcodeA) is found in database.");
                return 1;
              }
            }
          }
      }
      # Consistency check for EntryId
      if (exists($dimension_href->{TrialUnitEntryId})) {
        my $entryId = $trialunit->{TrialUnitEntryId};
        my $sql = "SELECT TrialUnitId FROM trialunit WHERE TrialId = ? AND TrialUnitEntryId = ?";
        my $sth = $dbh_k_write->prepare($sql);
        $sth->execute($trial_id, $entryId);
        if ($dbh_k_write->err()) {
          $data_for_postrun_href = $self->_set_error();
          return 1;
        }
        my $ids = $sth->fetchall_arrayref();
        foreach my $idB (@$ids) {
          $idB = $idB->[0];
          if ($idA != $idB && !exists($isUpdating->{$idB})) {
            $data_for_postrun_href = $self->_set_error("TrialUnitEntryId ($entryId) is found in database.");
            return 1;
          }
        }
      }
      # Consistency check for XYZ
      my $dimStr = $trialUnitId2XYZ->{$idA};
      if (length($dimStr)) {
        my $sql = "SELECT TrialUnitId FROM trialunit WHERE TrialId = ? AND $dimStr";
        my $sth = $dbh_k_write->prepare($sql);
        $sth->execute($trial_id);
        if ($dbh_k_write->err()) {
          $data_for_postrun_href = $self->_set_error();
          return 1;
        }
        my $ids = $sth->fetchall_arrayref();
        foreach my $idB (@$ids) {
          $idB = $idB->[0];
          if ($idA != $idB && !exists($isUpdating->{$idB})) {
            $self->logger->debug($idB);
            $data_for_postrun_href = $self->_set_error("Dimension ($dimStr) is found in database.");
            return 1;
          }
        }
      }
    }


    # Third pass
    my @tu_spec_sql_list = ();
    my @tu_loc_sql_list = ();
    my @tu_loc_ids = ();
    my $current_dt_pg = DateTime::Format::Pg->parse_datetime(DateTime->now());
    for my $trialunit_rec (@$trialunit_info_aref) {

      my $trialunit_id = $trialunit_rec->{TrialUnitId};

      my $data = {};
      $data->{ReplicateNumber} = $trialunit_rec->{ReplicateNumber};
      #
      $data->{TrialUnitBarcode} = $trialunit_rec->{TrialUnitBarcode};
      if (!length($data->{TrialUnitBarcode})) {
        $data->{TrialUnitBarcode} = undef;
      }
      $data->{TrialUnitNote} = $trialunit_rec->{TrialUnitNote};
      if (!length($data->{TrialUnitNote})) {
        $data->{TrialUnitNote} = undef;
      }
      $data->{SampleSupplierId} = $trialunit_rec->{SampleSupplierId};
      if (!length($data->{SampleSupplierId})) {
        $data->{SampleSupplierId} = undef;
      }
      $data->{SourceTrialUnitId} = $trialunit_rec->{SourceTrialUnitId};
      if (!length($data->{SourceTrialUnitId})) {
        $data->{SourceTrialUnitId} = undef;
      }
      foreach my $dimension (@dimension_field_list) {
        $data->{$dimension} = $trialunit_rec->{$dimension};
      }
      my $update_sql = "UPDATE trialunit SET";
      my @keys = keys(%$data);
      my @vals;
      for (my $i = 0; $i < scalar(@keys); $i++) {
        my $key = $keys[$i];
        $update_sql .= " $key = ?";
        if ($i != scalar(@keys) - 1) { $update_sql .= ","; }
        push(@vals, $data->{$key});
      }
      $update_sql .= " WHERE TrialUnitId = ?";
      push(@vals, $trialunit_id);
      $self->logger->debug("Update trial unit SQL: $update_sql");
      $sth = $dbh_k_write->prepare($update_sql);
      $sth->execute(@vals);
      if ($dbh_k_write->err()) {
        $data_for_postrun_href = $self->_set_error();
        return 1;
      }

      # TrialUnitPosition
      if (length($trialunit_rec->{trialunitlocation})) {
        my $location = $trialunit_rec->{trialunitlocation};
        my $tu_loc_sql_str = qq|($trialunit_id, ST_ForceCollection(ST_GeomFromText('$location', -1)), '$current_dt_pg', 1)|;
        push(@tu_loc_ids, $trialunit_id);
        push(@tu_loc_sql_list, $tu_loc_sql_str);
      }

      # TrialUnitSpecimen
      my $tu_specimen_aref = $trialunit_rec->{trialunitspecimen};
      for my $trialunitspecimen (@$tu_specimen_aref) {

        my $specimen_id  = $trialunitspecimen->{'SpecimenId'};
        my $spec_num     = 0;

        if (length $trialunitspecimen->{SpecimenNumber}) {
          $spec_num = $trialunitspecimen->{SpecimenNumber};
        }

        $sql = "SELECT TrialUnitSpecimenId FROM trialunitspecimen WHERE SpecimenId = ? AND SpecimenNumber = ? AND TrialUnitId = ?";
        my ($tu_id_err, $tus_id) = read_cell($dbh_k_write, $sql, [$specimen_id, $spec_num, $trialunit_id]);
        if ($tu_id_err) {
          $data_for_postrun_href = $self->_set_error();
          return 1;
        }
        if (length($tus_id)) {
          $sql  = 'UPDATE trialunitspecimen SET ';
          $sql .= 'ItemId=?, ';
          $sql .= 'PlantDate=?, ';
          $sql .= 'HarvestDate=?, ';
          $sql .= 'HasDied=?, ';
          $sql .= 'Notes=?, ';
          $sql .= 'TUSLabel=? ';
          $sql .= 'WHERE TrialUnitSpecimenId=?';
          my $item_id = undef;
          if (length($trialunitspecimen->{ItemId})) {
            $item_id = $trialunitspecimen->{ItemId};
          }
          my $plant_date = undef;
          if (length($trialunitspecimen->{PlantDate})) {
            $plant_date = $trialunitspecimen->{PlantDate};
          }
          my $harvest_date = undef;
          if (length($trialunitspecimen->{HarvestDate})) {
            $harvest_date = $trialunitspecimen->{HarvestDate};
          }
          my $has_died = undef;
          if (length($trialunitspecimen->{HasDied})) {
            $has_died = $trialunitspecimen->{HasDied};
          }
          my $notes = undef;
          if (length($trialunitspecimen->{Notes})) {
            $notes = $trialunitspecimen->{Notes};
          }
          my $tus_label = undef;
          if (length($trialunitspecimen->{TUSLabel})) {
            $tus_label = $trialunitspecimen->{TUSLabel};
          }
          my $sth = $dbh_k_write->prepare($sql);
          $sth->execute($item_id, $plant_date, $harvest_date, $has_died, $notes, $tus_label, $tus_id);
          if ($dbh_k_write->err()) {
            $data_for_postrun_href = $self->_set_error();
            return 1;
          }
        } else {
          my $item_id = 'NULL';
          if (length($trialunitspecimen->{ItemId})) {
            $item_id = $trialunitspecimen->{ItemId};
          }
          my $plant_date = 'NULL';
          if (length($trialunitspecimen->{PlantDate})) {
            $plant_date = $dbh_k_write->quote($trialunitspecimen->{PlantDate});
          }
          my $harvest_date = 'NULL';
          if (length($trialunitspecimen->{HarvestDate})) {
            $harvest_date = $dbh_k_write->quote($trialunitspecimen->{HarvestDate});
          }
          my $has_died = 'NULL';
          if (length($trialunitspecimen->{HasDied})) {
            $has_died = $trialunitspecimen->{HasDied};
          }
          my $notes = 'NULL';
          if (length($trialunitspecimen->{Notes})) {
            $notes = $dbh_k_write->quote($trialunitspecimen->{Notes});
          }
          my $tus_label    = 'NULL';
          if (length($trialunitspecimen->{TUSLabel})) {
            $tus_label = $dbh_k_write->quote($trialunitspecimen->{TUSLabel});
          }
          my $tu_spec_rec_str = qq|($trialunit_id,$specimen_id,$item_id,$plant_date,$harvest_date,$has_died,$notes,$spec_num,$tus_label)|;
          push(@tu_spec_sql_list, $tu_spec_rec_str);
        }
      }
    }

    if (scalar(@tu_spec_sql_list) > 0) {
      $bulk_sql  = 'INSERT INTO trialunitspecimen ';
      $bulk_sql .= '(TrialUnitId,SpecimenId,ItemId,PlantDate,HarvestDate,HasDied,Notes,SpecimenNumber,TUSLabel) ';
      $bulk_sql .= 'VALUES ';
      $bulk_sql .= join(',', @tu_spec_sql_list);
      $sth = $dbh_k_write->prepare($bulk_sql);
      $sth->execute();
      if ($dbh_k_write->err()) {
        $self->logger->debug("INSERT TrialUnitSpecimen BULK failed");
        $data_for_postrun_href = $self->_set_error();
        return 1;
      }
    }

    if (scalar(@tu_loc_sql_list)) {
      my $ids = join(",", @tu_loc_ids);
      $bulk_sql  = 'UPDATE trialunitloc ';
      $bulk_sql .= 'SET currentloc = 0 ';
      $bulk_sql .= 'WHERE trialunitid IN (?)';
      $sth = $dbh_gis_write->prepare($bulk_sql);
      $sth->execute($ids);
      if ($dbh_gis_write->err()) {
        $data_for_postrun_href = $self->_set_error();
        return 1;
      }

      $bulk_sql  = 'INSERT INTO trialunitloc ';
      $bulk_sql .= '(trialunitid, trialunitlocation, trialunitlocdt, currentloc) ';
      $bulk_sql .= 'VALUES ';
      $bulk_sql .= join(',', @tu_loc_sql_list);
      $sth = $dbh_gis_write->prepare($bulk_sql);
      $sth->execute();
      if ($dbh_gis_write->err()) {
        $self->logger->debug("INSERT trialunitlocation BULK failed");
        $data_for_postrun_href = $self->_set_error();
        return 1;
      }
    }

    # Treatment
    my @delete_list;
    my @tut_sql_list;
    foreach my $trialunit (@$trialunit_info_aref) {
      my $treatment_id = $trialunit->{'TreatmentId'};
      my $trialunit_id = $trialunit->{'TrialUnitId'};
      if (length($treatment_id) > 0) {
        push(@delete_list, $trialunit_id);
        my $tut_sql_str = qq|($treatment_id, $trialunit_id)|;
        push(@tut_sql_list, $tut_sql_str);
      }
    }

    if (scalar(@delete_list) > 0) {
      #
      my $delete_sql = "DELETE FROM trialunittreatment WHERE TrialUnitId IN (?)";
      my $sth = $dbh_k_write->prepare($delete_sql);
      $sth->execute(join(",", @delete_list));
      if ($dbh_k_write->err()) {
        $data_for_postrun_href = $self->_set_error();
        return 1;
      }
      $bulk_sql  = 'INSERT INTO trialunittreatment';
      $bulk_sql .= '(TreatmentId, TrialUnitId) ';
      $bulk_sql .= 'VALUES';
      $bulk_sql .= join(',', @tut_sql_list);
      $sth = $dbh_k_write->prepare($bulk_sql);
      $sth->execute();
      if ($dbh_k_write->err()) {
        $data_for_postrun_href = $self->_set_error();
        return 1;
      }
    }

    # Trial Unit Factor
    my @tu_factor_delete_list;
    my @tu_factor_sql_list;

    for my $trialunit (@{$trialunit_info_aref}) {
      my $trialunit_id = $trialunit->{'TrialUnitId'};

      my $factor_aref = $trialunit->{'trialunitfactor'};

      for my $factor_href (@{$factor_aref}) {

        my $factor_id = $factor_href->{'FactorId'};
        my $factor_value = $factor_href->{'FactorValue'};

         if (length($factor_value) > 0) {
            push(@tu_factor_delete_list, $trialunit_id);
            my $tut_sql_str = qq|(${trialunit_id}, ${factor_id}, '${factor_value}')|;
            push(@tu_factor_sql_list, $tut_sql_str);
        }
      }    
    }

    if (scalar(@tu_factor_delete_list) > 0) {
      my $factor_delete_sql = "DELETE FROM trialunitfactor WHERE TrialUnitId IN (?)";
      my $sth = $dbh_k_write->prepare($factor_delete_sql);
      $sth->execute(join(",", @tu_factor_delete_list));

      if ($dbh_k_write->err()) {
        $data_for_postrun_href = $self->_set_error();
        return 1;
      }
      $sql  = 'INSERT INTO trialunitfactor';
      $sql .= '(TrialUnitId, FactorId, FactorValue) ';
      $sql .= 'VALUES';
      $sql .= join(',', @tu_factor_sql_list);
      $sth = $dbh_k_write->prepare($sql);
      $sth->execute();

      if ($dbh_k_write->err()) {
          $self->logger->debug("INSERT trialunitfactor BULK failed");
          $data_for_postrun_href = $self->_set_error();
          return 1;
      }
      $sth->finish();
    }
    $dbh_k_write->commit;

    my $nb_added_trial_unit = scalar(@{$trialunit_info_aref});
    my $info_msg = "$nb_added_trial_unit TrialUnits for Trial ($trial_id) have been updated successfully.";

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
  $dbh_gis_write->disconnect;
  return $data_for_postrun_href;
}


sub add_trial_unit_specimen_runmode {

=pod add_trial_unit_specimen_HELP_START
{
"OperationName": "Add specimen to trial unit",
"Description": "Associate a new specimen with a trial unit specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "trialunitspecimen",
"SkippedField": ["TrialUnitId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='103' ParaName='TrialUnitSpecimenId' /><Info Message='TrialUnitSpecimen (103) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '104','ParaName' : 'TrialUnitSpecimenId'}],'Info' : [{'Message' : 'TrialUnitSpecimen (104) has been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TrialUnitId (123): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'TrialUnitId (123): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialUnitId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self          = shift;
  my $trial_unit_id = $self->param('id');
  my $query         = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'TrialUnitId'    => 1,
                    'SpecimenNumber' => 1,
                   };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'trialunitspecimen', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $specimen_id   = $query->param('SpecimenId');

  my $item_id       = undef;

  if (defined $query->param('ItemId')) {

    if (length($query->param('ItemId')) > 0) {

      $item_id = $query->param('ItemId');
    }
  }

  $dbh_read = connect_kdb_read();

  my $trial_id = read_cell_value($dbh_read, 'trialunit', 'TrialId', 'TrialUnitId', $trial_unit_id);

  if (length($trial_id) == 0) {

    my $err_msg = "TrialUnitId ($trial_unit_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'trial');
  my $sql      = "SELECT $perm_str AS UltimatePermission ";
  $sql        .= 'FROM trial ';
  $sql        .= 'WHERE TrialId=?';

  my ($read_err, $permission) = read_cell($dbh_read, $sql, [$trial_id]);

  if ( ($permission & $READ_WRITE_PERM) != $READ_WRITE_PERM ) {

    my $err_msg = "Trial ($trial_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $specimen_exist = record_existence($dbh_read, 'specimen', 'SpecimenId', $specimen_id);

  if (!$specimen_exist) {

    my $err_msg = "Specimen ($specimen_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'SpecimenId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $spec_num = 0;

  if (defined $query->param('SpecimenNumber')) {

    if (length($query->param('SpecimenNumber')) > 0) {

      $spec_num = $query->param('SpecimenNumber');

      if ($spec_num !~ /^\d+$/) {

        my $err_msg = "SpecimenNumber ($spec_num) not an unsigned integer.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'SpecimenNumber' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
  }

  $self->logger->debug("Specimen number: $spec_num");

  $sql  = 'SELECT TrialUnitSpecimenId FROM trialunitspecimen ';
  $sql .= 'WHERE TrialUnitId=? AND SpecimenId=? AND SpecimenNumber=?';

  my ($r_tu_spec_id_err, $tu_spec_id) = read_cell($dbh_read, $sql, [$trial_unit_id, $specimen_id, $spec_num]);

  if (length($tu_spec_id) > 0) {

    my $err_msg = "Specimen ($specimen_id, $spec_num): already exists in trialunit ($trial_unit_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'SpecimenId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $geno_specimen_sql = 'SELECT genotype.GenotypeId ';
  $geno_specimen_sql   .= 'FROM genotype LEFT JOIN genotypespecimen ON ';
  $geno_specimen_sql   .= 'genotype.GenotypeId = genotypespecimen.GenotypeId ';
  $geno_specimen_sql   .= 'WHERE genotypespecimen.SpecimenId=?';

  my ($geno_specimen_err, $geno_specimen_msg, $geno_specimen_data) = read_data($dbh_read,
                                                                      $geno_specimen_sql,
                                                                      [$specimen_id]);

  if ($geno_specimen_err) {

    $self->logger->debug("Read genotype failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $perm_str          = permission_phrase($group_id, 0, $gadmin_status, 'genotype');
  $geno_specimen_sql   .= " AND ((($perm_str) & $LINK_PERM) = $LINK_PERM)";

  $self->logger->debug("Genotype specimen permission SQL: $geno_specimen_sql");

  my ($geno_p_err, $geno_p_msg, $geno_p_data_perm) = read_data($dbh_read, $geno_specimen_sql, [$specimen_id]);

  if ($geno_p_err) {

    $self->logger->debug("Read genotype with permission failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$geno_specimen_data}) != scalar(@{$geno_p_data_perm})) {

    my $err_msg = "Permission denied: specimen ($specimen_id)";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'SpecimenId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($item_id) > 0) {

    if (!record_existence($dbh_read, 'item', 'ItemId', $item_id)) {

      my $err_msg = "ItemId ($item_id) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'ItemId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  $dbh_read->disconnect();

  if (length($item_id) == 0) {

    $item_id = undef;
  }

  my $planted_date = undef;
  if ($query->param('PlantDate')) {

    $planted_date = $query->param('PlantDate');
    my ($pdate_err, $pdate_msg) = check_dt_value( {'PlantDate' => $planted_date} );

    if ($pdate_err) {

      my $err_msg = "$pdate_msg not date/time.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'PlateDate' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $harvested_date = undef;
  if ($query->param('HarvestDate')) {

    $harvested_date = $query->param('HarvestDate');
    my ($hdate_err, $hdate_msg) = check_dt_value( {'HarvestDate' => $harvested_date} );

    if ($hdate_err) {

      my $err_msg = "$hdate_msg not date/time.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'HarvestDate' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $has_died = undef;
  if ($query->param('HasDied')) {

    $has_died = $query->param('HasDied');
    if (!($has_died =~ /[0|1]/)) {

      my $err_msg = "HasDied not 1 nor 0.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'HasDied' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $notes = undef;
  if (defined $query->param('Notes')) {

    if (length($query->param('Notes')) > 0) {

      $notes = $query->param('Notes');
    }
  }

  my $tus_label = undef;

  if (defined $query->param('TUSLabel')) {

    if (length($query->param('TUSLabel')) > 0) {

      $tus_label = $query->param('TUSLabel');
    }
  }

  my $dbh_write = connect_kdb_write();

  $sql  = 'INSERT INTO trialunitspecimen SET ';
  $sql .= 'SpecimenId=?, ';
  $sql .= 'ItemId=?, ';
  $sql .= 'TrialUnitId=?, ';
  $sql .= 'PlantDate=?, ';
  $sql .= 'HarvestDate=?, ';
  $sql .= 'HasDied=?, ';
  $sql .= 'Notes=?, ';
  $sql .= 'SpecimenNumber=?, ';
  $sql .= 'TUSLabel=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($specimen_id, $item_id, $trial_unit_id, $planted_date,
                $harvested_date, $has_died, $notes, $spec_num, $tus_label);

  my $tunit_specimen_id = -1;
  if ($dbh_write->err()) {

    $self->logger->debug("Insert into trialunitspecimen failed.");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $tunit_specimen_id = $dbh_write->last_insert_id(undef, undef, 'trialunitspecimen', 'TrialUnitSpecimenId');
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref  = [{'Message' => "TrialUnitSpecimen ($tunit_specimen_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$tunit_specimen_id", 'ParaName' => 'TrialUnitSpecimenId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'       => $info_msg_aref,
                                           'ReturnId'   => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub delete_trial_unit_specimen_runmode {

=pod delete_trial_unit_specimen_HELP_START
{
"OperationName": "Delete trial unit specimen",
"Description": "Delete association between trial unit and specimen specified by trialunitsepcimen id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='TrialUnitSpecimen (103) has been removed successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'TrialUnitSpecimen (104) has been removed successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TrialUnitSpecimen (103) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'TrialUnitSpecimen (103) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialUnitSpecimenId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self           = shift;
  my $tunit_specimen_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_read = connect_kdb_read();
  my $trial_unit_id = read_cell_value($dbh_read, 'trialunitspecimen', 'TrialUnitId',
                                      'TrialUnitSpecimenId', $tunit_specimen_id);

  if (length($trial_unit_id) == 0) {

    my $err_msg = "TrialUnitSpecimen ($tunit_specimen_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trial_id = read_cell_value($dbh_read, 'trialunit', 'TrialId', 'TrialUnitId', $trial_unit_id);

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'trial');
  my $sql      = "SELECT $perm_str AS UltimatePermission ";
  $sql        .= 'FROM trial ';
  $sql        .= 'WHERE TrialId=?';

  my ($read_err, $permission) = read_cell($dbh_read, $sql, [$trial_id]);

  if ( ($permission & $READ_WRITE_PERM) != $READ_WRITE_PERM ) {

    my $err_msg = "Trial ($trial_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (record_existence($dbh_read, 'item', 'TrialUnitSpecimenId', $tunit_specimen_id)) {

    my $err_msg = "TrialUnitSpecimenId ($tunit_specimen_id) is used in item.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_read->disconnect();

  my $dbh_write = connect_kdb_write();

  $sql = 'DELETE FROM trialunitspecimen WHERE TrialUnitSpecimenId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($tunit_specimen_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "TrialUnitSpecimen ($tunit_specimen_id) has been removed successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'       => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_trial_unit_specimen_runmode {

=pod update_trial_unit_specimen_HELP_START
{
"OperationName": "Update trial unit specimen",
"Description": "Update information about association between trial unit and specimen specified by trialunitsepcimen id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "trialunitspecimen",
"SkippedField": ["TrialUnitId", "SpecimenId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='TrialUnitSpecimen (109) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'TrialUnitSpecimen (109) has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TrialUnitSpecimen (103) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'TrialUnitSpecimen (103) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialUnitSpecimenId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self              = shift;
  my $tunit_specimen_id = $self->param('id');
  my $query             = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'TrialUnitId'    => 1,
                    'SpecimenNumber' => 1,
                   };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'trialunitspecimen', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  $dbh_read = connect_kdb_read();

  my $read_tru_sp_sql   = 'SELECT trialunitspecimen.TrialUnitId, trialunit.TrialId, SpecimenId, ItemId, ';
  $read_tru_sp_sql     .= 'PlantDate, HarvestDate, HasDied, Notes, SpecimenNumber, TUSLabel ';
  $read_tru_sp_sql     .= 'FROM trialunitspecimen LEFT JOIN trialunit ';
  $read_tru_sp_sql     .= 'ON trialunitspecimen.TrialUnitId = trialunit.TrialUnitId ';
  $read_tru_sp_sql     .= 'WHERE TrialUnitSpecimenId=? ';

  my ($r_df_val_err, $r_df_val_msg, $trail_usp_df_val_data) = read_data($dbh_read, $read_tru_sp_sql, [$tunit_specimen_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve trialunitspecimen default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $trial_unit_id      = undef;
  my $specimen_id        = undef;
  my $item_id            = undef;
  my $planted_date       = undef;
  my $harvested_date     = undef;
  my $has_died           = undef;
  my $notes              = undef;
  my $trial_id           = undef;
  my $spec_num           = undef;
  my $tus_label          = undef;

  my $nb_df_val_rec    =  scalar(@{$trail_usp_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve trialunitspecimen default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $trial_unit_id      =  $trail_usp_df_val_data->[0]->{'TrialUnitId'};
  $specimen_id        =  $trail_usp_df_val_data->[0]->{'SpecimenId'};
  $item_id            =  $trail_usp_df_val_data->[0]->{'ItemId'};
  $planted_date       =  $trail_usp_df_val_data->[0]->{'PlantDate'};
  $harvested_date     =  $trail_usp_df_val_data->[0]->{'HarvesDate'};
  $has_died           =  $trail_usp_df_val_data->[0]->{'HasDied'};
  $notes              =  $trail_usp_df_val_data->[0]->{'Notes'};
  $trial_id           =  $trail_usp_df_val_data->[0]->{'TrialId'};
  $spec_num           =  $trail_usp_df_val_data->[0]->{'SpecimenNumber'};
  $tus_label          =  $trail_usp_df_val_data->[0]->{'TUSLabel'};

  if (length($trial_unit_id) == 0) {

    my $err_msg = "TrialUnitSpecimen ($tunit_specimen_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'trial');

  my $sql = "SELECT $perm_str AS UltimatePermission ";
  $sql   .= 'FROM trial ';
  $sql   .= 'WHERE TrialId=?';

  my ($read_err, $permission) = read_cell($dbh_read, $sql, [$trial_id]);

  if ( ($permission & $READ_WRITE_PERM) != $READ_WRITE_PERM ) {

    my $err_msg = "Trial ($trial_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $data_submitted = 0;

  if (defined $query->param('SpecimenId')) {

    if (length($query->param('SpecimenId')) > 0) {

      $specimen_id = $query->param('SpecimenId');

      $sql = 'SELECT GenotypeId FROM genotypespecimen WHERE SpecimenId=?';
      my $sth = $dbh_read->prepare($sql);
      $sth->execute($specimen_id);
      my $genotype_id_href = $sth->fetchall_hashref('GenotypeId');
      $sth->finish();

      my @geno_id = keys(%{$genotype_id_href});
      if (scalar(@geno_id) == 0) {

        my $err_msg = "SpecimenId ($specimen_id) not found.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'SpecimenId' => $err_msg}]};

        return $data_for_postrun_href;
      }

      my ($is_geno_ok, $trouble_geno_id_aref) = check_permission($dbh_read, 'genotype', 'GenotypeId',
                                                                 \@geno_id, $group_id, $gadmin_status,
                                                                 $LINK_PERM);

      if (!$is_geno_ok) {

        my $trouble_geno_id_str = join(',', @{$trouble_geno_id_aref});

        my $perm_err_msg = '';
        $perm_err_msg   .= "Permission denied: Group ($group_id) and Genotype ($trouble_geno_id_str).";

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'SpecimenId' => $perm_err_msg}]};

        return $data_for_postrun_href;
      }

      $data_submitted = 1;
    }
  }

  $self->logger->debug("ItemId: $item_id");

  if (length($item_id) == 0) {

    $item_id = undef;
  }

  if (defined $query->param('ItemId')) {

    if (length($query->param('ItemId')) > 0) {

      $item_id = $query->param('ItemId');

      if ($item_id ne '0') {

        if (!record_existence($dbh_read, 'item', 'ItemId', $item_id)) {

          my $err_msg = "ItemId ($item_id) not found.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'ItemId' => $err_msg}]};

          return $data_for_postrun_href;
        }

        $data_submitted = 1;
      }
    }
  }

  if (defined $query->param('PlantDate')) {

    if (length($query->param('PlantDate')) > 0) {

      $planted_date = $query->param('PlantDate');

      my ($pdate_err, $pdate_msg) = check_dt_value( {'PlantDate' => $planted_date} );

      if ($pdate_err) {

        my $err_msg = "$pdate_msg not date/time.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'PlateDate' => $err_msg}]};

        return $data_for_postrun_href;
      }

      $data_submitted = 1;
    }
  }

  # Unknown planted DateTime value from database 0000-00-00 00:00:00 which should be reset to undef,
  # and then null in the db

  if ($planted_date eq '0000-00-000 00:00:00') {

    $planted_date = undef;
  }

  if (length($planted_date) == 0) {

    $planted_date = undef;
  }

  if (defined $query->param('HarvestDate')) {

    if (length($query->param('HarvestDate')) > 0) {

      $harvested_date = $query->param('HarvestDate');

      my ($hdate_err, $hdate_msg) = check_dt_value( {'HarvestDate' => $harvested_date} );

      if ($hdate_err) {

        my $err_msg = "$hdate_msg not date/time.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'HarvestDate' => $err_msg}]};

        return $data_for_postrun_href;
      }

      $data_submitted = 1;
    }
  }

  # Unknown harvested DateTime value from database 0000-00-00 00:00:00 which should be reset to undef,
  # and then null in the db

  if ($harvested_date eq '0000-00-00 00:00:00') {

    $harvested_date = undef;
  }

  if (length($harvested_date) == 0) {

    $harvested_date = undef;
  }


  if (defined $query->param('HasDied')) {

    if (length($query->param('HasDied')) > 0) {

      $has_died = $query->param('HasDied');
      if (!($has_died =~ /[0|1]/)) {

        my $err_msg = "HasDied not a binary value.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'HasDied' => $err_msg}]};

        return $data_for_postrun_href;
      }

      $data_submitted = 1;
    }
  }

  if (defined $query->param('SpecimenNumber')) {

    if (length($query->param('SpecimenNumber')) > 0) {

      $spec_num = $query->param('SpecimenNumber');

      $sql  = 'SELECT TrialUnitSpecimenId FROM trialunitspecimen ';
      $sql .= 'WHERE TrialUnitId=? AND SpecimenId=? AND SpecimenNumber=? AND TrialUnitSpecimenId<>?';

      my ($r_tu_spec_id_err, $tu_spec_id) = read_cell($dbh_read, $sql,
                                                      [$trial_unit_id, $specimen_id, $spec_num, $tunit_specimen_id]);

      if (length($tu_spec_id) > 0) {

        my $err_msg = "Specimen ($specimen_id, $spec_num): already exists in trialunit ($trial_unit_id).";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'SpecimenId' => $err_msg}]};

        return $data_for_postrun_href;
      }

      $data_submitted = 1;
    }
  }

  if (length($has_died) == 0) {

    $has_died = undef;
  }

  if (defined $query->param('Notes')) {

    $notes = $query->param('Notes');
    $data_submitted = 1;
  }

  if (defined $query->param('TUSLabel')) {

    $tus_label = $query->param('TUSLabel');
    $data_submitted = 1;
  }


  $dbh_read->disconnect();

  if ($data_submitted == 0) {

    my $err_msg = 'No data submitted.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_write = connect_kdb_write();

  $sql  = 'UPDATE trialunitspecimen SET ';
  $sql .= 'SpecimenId=?, ';
  $sql .= 'ItemId=?, ';
  $sql .= 'PlantDate=?, ';
  $sql .= 'HarvestDate=?, ';
  $sql .= 'HasDied=?, ';
  $sql .= 'Notes=?, ';
  $sql .= 'SpecimenNumber=?, ';
  $sql .= 'TUSLabel=? ';
  $sql .= 'WHERE TrialUnitSpecimenId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($specimen_id, $item_id, $planted_date, $harvested_date, $has_died, $notes,
                $spec_num, $tus_label, $tunit_specimen_id);

  if ($dbh_write->err()) {

    $self->logger->debug("Update SQL failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "TrialUnitSpecimen ($tunit_specimen_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'       => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_site_advanced_runmode {

=pod list_site_advanced_HELP_START
{
"OperationName": "List sites",
"Description": "List all the available sites in the system. This listing requires pagination information.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination NumOfRecords='15' NumOfPages='15' Page='1' NumPerPage='1' /><Site SiteStartDate='' delete='delete/site/18' CurrentSiteManagerId='41' SiteTypeName='SiteType - 22416809916' update='update/site/18' sitelocation='MULTIPOLYGON(((149.05803801025291 -35.28275454804866,149.06078459228328 -35.315257984493236,149.12120939696936 -35.31637855978221,149.05803801025291 -35.28275454804866)))' sitelocdt='2023-04-11 05:19:52' SiteAcronym='GH' Latitude='-35.3047970307747' SiteTypeId='46' SiteEndDate='' CurrentSiteManagerName='Testing User-25644445488' SiteId='18' SiteName='DArT Test Site' sitelocdescription='' Longitude='149.08001066650183'/><RecordMeta TagName='Site' /></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfRecords' : '15','NumOfPages' : 15,'NumPerPage' : '1','Page' : '1'}],'VCol' : [],'Site' : [{ 'SiteName' : 'DArT Test Site', 'sitelocdescription' : '', 'Longitude' : '149.08001066650183', 'CurrentSiteManagerName' : 'Testing User-25644445488', 'SiteId' : 18, 'update' : 'update/site/18', 'Latitude' : '-35.3047970307747', 'SiteAcronym' : 'GH', 'sitelocdt' : '2023-04-11 05:19:52', 'sitelocation' : 'MULTIPOLYGON(((149.05803801025291 -35.28275454804866,149.06078459228328 -35.315257984493236,149.12120939696936 -35.31637855978221,149.05803801025291 -35.28275454804866)))', 'SiteEndDate' : null, 'SiteTypeId' : 46, 'delete' : 'delete/site/18', 'SiteStartDate' : null, 'CurrentSiteManagerId' : 41, 'SiteTypeName' : 'SiteType - 22416809916' }],'RecordMeta' : [{'TagName' : 'Site'}]}",
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

  my $dbh = connect_kdb_read();
  my $field_list = ['site.*', 'VCol*', 'LCol*'];
  my $pre_data_other_join = '';

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $field_list, 'site',
                                                                        'SiteId', '');

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql   .= " LIMIT 1";

  $self->logger->debug("SQL with VCol: $sql");

  my ($sam_site_err, $sam_site_msg, $sam_site_data) = $self->list_site(0, $field_list, $sql);

  if ($sam_site_err) {

    $self->logger->debug($sam_site_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $sample_data_aref = $sam_site_data;

  my @field_list_all;

  if (scalar(@{$sample_data_aref}) == 1) {

    @field_list_all = keys(%{$sample_data_aref->[0]});
  }
  else {

    $self->logger->debug("It reaches here");
    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'site');

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
                                                                                'SiteId');

    if ($sel_field_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;

    if ($filtering_csv =~ /SiteId/) {

      push(@{$final_field_list}, 'SiteId');
    }

    $sql_field_list   = [];
    for my $fd_name (@{$final_field_list}) {

      # need to remove location field because generate_factor_sql does not understand these field
      if ( (!($fd_name =~ /Longitude/)) && (!($fd_name =~ /Latitude/)) && (!($fd_name =~ /sitelocation/)) && (!($fd_name =~ /sitelocdt/)) && (!($fd_name =~ /sitelocdescription/))) {

        push(@{$sql_field_list}, $fd_name);
      }
    }
  }
  else {

    for my $fd_name (@{$final_field_list}) {

      # need to remove location field because generate_factor_sql does not understand these field
      if ( (!($fd_name =~ /Longitude/)) && (!($fd_name =~ /Latitude/)) && (!($fd_name =~ /sitelocation/)) && (!($fd_name =~ /sitelocdt/)) && (!($fd_name =~ /sitelocdescription/))) {

        push(@{$sql_field_list}, $fd_name);
      }
    }
  }

  my $sql_field_lookup = {};

  for my $fd_name (@{$sql_field_list}) {

    $sql_field_lookup->{$fd_name} = 1;
  }

  my $other_join = '';
  if ($sql_field_lookup->{'SiteTypeId'}) {

    push(@{$sql_field_list}, 'generaltype.TypeName AS SiteTypeName');
    $other_join .= ' LEFT JOIN generaltype ON site.SiteTypeId = generaltype.TypeId ';
  }

  if ($sql_field_lookup->{'CurrentSiteManagerId'}) {

    my $cur_man = "CONCAT(contact.ContactFirstName, concat(' ', contact.ContactLastName)) As CurrentSiteManagerName";
    push(@{$sql_field_list}, $cur_man);
    $other_join .= ' LEFT JOIN contact ON site.CurrentSiteManagerId = contact.ContactId ';
  }

  my $factor_filtering_flag = test_filtering_factor($filtering_csv);

  if (!$factor_filtering_flag) {

    ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $sql_field_list, 'site',
                                                                       'SiteId', $other_join);
  }
  else {

    ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql_v2($dbh, $sql_field_list, 'site',
                                                                          'SiteId', $other_join);
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
      $nb_filter_factor) = parse_filtering_v2('SiteId',
                                              'site',
                                              $filtering_csv,
                                              $final_field_list,
                                              $vcol_list);

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

  my $filtering_exp = $filter_where_phrase;

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
                                                                  'site',
                                                                  'SiteId',
                                                                  $filtering_exp,
                                                                  $where_arg);
    }
    else {

      $self->logger->debug("COUNT NB RECORD: FACTOR IN FILTERING");

      my $count_sql = "SELECT COUNT(site.SiteId) ";
      $count_sql   .= "FROM site INNER JOIN ";
      $count_sql   .= " (SELECT SiteId, COUNT(SiteId) ";
      $count_sql   .= " FROM sitefactor WHERE $count_filter_phrase ";
      $count_sql   .= " GROUP BY SiteId HAVING COUNT(SiteId)=$nb_filter_factor) AS subq ";
      $count_sql   .= "ON site.SiteId = subq.SiteId ";
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

    $sql .= ' ORDER BY site.SiteId DESC';
  }

  $sql .= " $paged_limit_clause ";

  $self->logger->debug("SQL with VCol: $sql");

  $self->logger->debug('Where arg: ' . join(',', @{$where_arg}));

  my ($read_site_err, $read_site_msg, $site_data) = $self->list_site(1,
                                                                     $final_field_list,
                                                                     $sql,
                                                                     $where_arg);

  if ($read_site_err) {

    $self->logger->debug($read_site_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'geojson'}   = 1;
  $data_for_postrun_href->{'GJSonInfo'} = {'GeometryField' => 'sitelocation',
                                           'FeatureName'   => 'SiteName [ id: SiteId ]',
                                           'FeatureId'     => 'SiteId',
  };
  $data_for_postrun_href->{'Data'}      = {'Site'       => $site_data,
                                           'VCol'       => $vcol_list,
                                           'Pagination' => $pagination_aref,
                                           'RecordMeta' => [{'TagName' => 'Site'}],
  };

  return $data_for_postrun_href;
}

sub list_trial_unit_advanced_runmode {

=pod list_trial_unit_advanced_HELP_START
{
"OperationName": "List trial units",
"Description": "List trial units (e.g. plots). This listing does require pagination information.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination Page='1' NumOfRecords='75' NumOfPages='75' NumPerPage='1' /><RecordMeta TagName='TrialUnit' /><TrialUnit SourceTrialUnitId='' update='update/trialunit/6' TrialUnitBarcode='BAR77863798194' TrialId='9' Latitude='-35.3047970307747' ReplicateNumber='2' TrialUnitZ='' TrialUnitEntryId='' listSpecimen='trialunit/6/list/specimen' TrialUnitTypeId='' trialunitlocation='GEOMETRYCOLLECTION(POLYGON((149.05803801025291 -35.28275454804866,149.06078459228328 -35.315257984493236,149.12120939696936 -35.31637855978221,149.05803801025291 -35.28275454804866)))' addSpecimen='trialunit/6/add/specimen' TrialUnitX='' TrialUnitPosition='' TrialUnitY='2745' SiteName='DArT Test Site' trialunitlocdt='2023-04-11 05:19:36' UltimatePermission='Read/Write/Link' trialunitlocdescription='' addKeyword='trialunit/6/add/keyword' TrialUnitId='6' Longitude='149.08001066650183' SampleSupplierId='1' TrialUnitNote='Trial unit part of automatic testing' SiteId='12' UltimatePerm='7'><Specimen PlantDate='2011-09-01' HarvestDate='2008-08-01' Notes='none' TrialUnitSpecimenId='26' TUSBarcode='' SpecimenNumber='0' Pedigree='' SpecimenName='Specimen4TrialUnit_94277815385' TUSLabel='' TrialUnitId='6' ItemId='' HasDied='' SpecimenId='7'/></TrialUnit></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfRecords' : '75','NumOfPages' : 75,'NumPerPage' : '1','Page' : '1'}],'RecordMeta' : [{'TagName' : 'TrialUnit'}],'TrialUnit' : [{ 'TrialUnitZ' : null, 'ReplicateNumber' : 2, 'Latitude' : '-35.3047970307747', 'TrialUnitEntryId' : null, 'SourceTrialUnitId' : null, 'update' : 'update/trialunit/6', 'TrialId' : 9, 'TrialUnitBarcode' : 'BAR77863798194', 'Specimen' : [ { 'HarvestDate' : '2008-08-01', 'PlantDate' : '2011-09-01', 'Notes' : 'none', 'TrialUnitSpecimenId' : 26, 'TUSBarcode' : null, 'SpecimenNumber' : 0, 'Pedigree' : '', 'SpecimenName' : 'Specimen4TrialUnit_94277815385', 'TrialUnitId' : 6, 'TUSLabel' : null, 'ItemId' : null, 'HasDied' : null, 'SpecimenId' : 7 }], 'addSpecimen' : 'trialunit/6/add/specimen', 'TrialUnitX' : null, 'trialunitlocation' : 'GEOMETRYCOLLECTION(POLYGON((149.05803801025291 -35.28275454804866,149.06078459228328 -35.315257984493236,149.12120939696936 -35.31637855978221,149.05803801025291 -35.28275454804866)))', 'TrialUnitTypeId' : null, 'listSpecimen' : 'trialunit/6/list/specimen', 'TrialUnitPosition' : null, 'addKeyword' : 'trialunit/6/add/keyword', 'trialunitlocdescription' : '', 'TrialUnitId' : 6, 'Longitude' : '149.08001066650183', 'trialunitlocdt' : '2023-04-11 05:19:36', 'SiteName' : 'DArT Test Site', 'TrialUnitY' : 2745, 'UltimatePermission' : 'Read/Write/Link', 'TrialUnitNote' : 'Trial unit part of automatic testing', 'SiteId' : 12, 'UltimatePerm' : 7, 'SampleSupplierId' : 1 }]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"URLParameter": [{"ParameterName": "nperpage", "Description": "Number of records in a page for pagination", "Optional": 1}, {"ParameterName": "num", "Description": "The page number of the pagination", "Optional": 1}, {"ParameterName": "trialid", "Description": "Existing TrialId", "Optional": 1}],
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

  my $trial_id          = -1;
  my $trial_id_provided = 0;

  if (defined $self->param('trialid')) {

    $trial_id          = $self->param('trialid');
    $trial_id_provided = 1;

    if ($filtering_csv =~ /TrialId\s*=\s*(.*),?/) {

      if ( "$trial_id" ne "$1" ) {

        my $err_msg = 'Duplicate filtering condition for TrialId.';
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
    else {

      if (length($filtering_csv) > 0) {

        if ($filtering_csv =~ /&$/) {

          $filtering_csv .= "TrialId=$trial_id";
        }
        else {

          $filtering_csv .= "&TrialId=$trial_id";
        }
      }
      else {

        $filtering_csv .= "TrialId=$trial_id";
      }
    }
  }

  $self->logger->debug("Filtering csv: $filtering_csv");

  my $sorting = '';

  if (defined $query->param('Sorting')) {

    $sorting = $query->param('Sorting');
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'trial');

  my $dbh = connect_kdb_read();
  my $field_list = ['*', 'VCol*', 'LCol*'];

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_columns_sql($dbh, $field_list, 'trialunit',
                                                                                'TrialUnitId', '');

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql   .= " LIMIT 1";

  $self->logger->debug("SQL with VCol: $sql");

  my ($sample_tu_err, $sample_tu_msg, $sample_tu_data) = $self->list_trial_unit(0, ['LCol*'], $sql);

  if ($sample_tu_err) {

    $self->logger->debug($sample_tu_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $dbh = connect_kdb_read();

  if ($trial_id_provided == 1) {

    if (!record_existence($dbh, 'trial', 'TrialId', $trial_id)) {

      my $err_msg = "Trial ($trial_id): not found";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $sample_data_aref = $sample_tu_data;

  my @field_list_all;

  if (scalar(@{$sample_data_aref}) == 1) {

    @field_list_all = keys(%{$sample_data_aref->[0]});
  }
  else {

    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'trialunit');

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
  my $filtering_field_list = [];

  if (length($field_list_csv) > 0) {

    my ($sel_field_err, $sel_field_msg, $sel_field_list) = parse_selected_field($field_list_csv,
                                                                                $final_field_list,
                                                                                'TrialUnitId');

    if ($sel_field_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;

    if ($filtering_csv =~ /TrialId/) {

      push(@{$final_field_list}, 'TrialId');
    }

    $sql_field_list       = [];
    $filtering_field_list = [];
    for my $fd_name (@{$final_field_list}) {

      # need to remove location field because generate_factor_sql does not understand these field
      if ( (!($fd_name =~ /Longitude/)) && (!($fd_name =~ /Latitude/)) && (!($fd_name =~ /trialunitlocation/)) && (!($fd_name =~ /trialunitlocdt/)) && (!($fd_name =~ /trialunitlocdescription/))) {

        push(@{$sql_field_list}, $fd_name);
        push(@{$filtering_field_list}, $fd_name);
      }
    }
  }
  else {

    for my $fd_name (@{$final_field_list}) {

      # need to remove location field because generate_factor_sql does not understand these field
      if ( (!($fd_name =~ /Longitude/)) && (!($fd_name =~ /Latitude/)) && (!($fd_name =~ /trialunitlocation/)) && (!($fd_name =~ /trialunitlocdt/)) && (!($fd_name =~ /trialunitlocdescription/))) {

        push(@{$sql_field_list}, $fd_name);
        push(@{$filtering_field_list}, $fd_name);
      }
    }
  }

  my $field_lookup = {};
  for my $fd_name (@{$final_field_list}) {

    $field_lookup->{$fd_name} = 1;
  }

  my $other_join = 'LEFT JOIN trial ON trialunit.TrialId = trial.TrialId ';
  $other_join .= ' LEFT JOIN site ON trial.SiteId = site.SiteId ';

  if ($field_lookup->{'UnitPositionId'}) {

    push(@{$sql_field_list}, 'unitposition.UnitPositionText');
    $other_join .= ' LEFT JOIN unitposition ON trialunit.UnitPositionId = unitposition.UnitPositionId ';
  }

  if ($field_lookup->{'TreatmentId'}) {

    push(@{$sql_field_list}, 'treatment.TreatmentText');
    $other_join .= ' LEFT JOIN treatment ON trialunit.TreatmentId = treatment.TreatmentId ';
  }

  push(@{$sql_field_list}, 'site.SiteId');
  push(@{$sql_field_list}, 'site.SiteName');
  push(@{$sql_field_list}, "$perm_str AS UltimatePerm ");

  my @filtering_exp = split(/&/, $filtering_csv);

  ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql_v3($dbh, $sql_field_list, 'trialunit',
                                                                        'TrialUnitId', $other_join);

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  push(@{$filtering_field_list}, 'SpecimenId');
  push(@{$filtering_field_list}, 'PlantDate');
  push(@{$filtering_field_list}, 'HarvestDate');
  push(@{$filtering_field_list}, 'HasDied');
  push(@{$filtering_field_list}, 'Notes');

  my $field_name2table_name  = { 'SpecimenId'  => 'trialunitspecimen',
                                 'PlantDate'   => 'trialunitspecimen',
                                 'HarvestDate' => 'trialunitspecimen',
                                 'HasDied'     => 'trialunitspecimen',
                                 'Notes'       => 'trialunitspecimen',
  };

  my $validation_func_lookup = { 'TrialId' => sub { return $self->validate_trial_id(@_); } };

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg,
      $having_phrase, $count_filter_phrase, $nb_filter_factor);

  if ($TRIALUNITFACTORFILTERING_CFG == 1) {
    ($filter_err, $filter_msg, $filter_phrase, $where_arg,
     $having_phrase, $count_filter_phrase, $nb_filter_factor) = parse_filtering_v2('TrialUnitId',
                                                                                   'trialunit',
                                                                                   $filtering_csv,
                                                                                   $final_field_list,
                                                                                   $vcol_list);

  } 
  else {
    ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering('TrialUnitId',
                                                                              'trialunit',
                                                                              $filtering_csv,
                                                                              $filtering_field_list,
                                                                              $validation_func_lookup,
                                                                              $field_name2table_name);
  }

  $self->logger->debug("Filter phrase: $filter_phrase");
  $self->logger->debug("Where argument: " . join(',', @{$where_arg}));

  if ($filter_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => "$filter_msg", "VCol" => $vcol_list}]};

    return $data_for_postrun_href;
  }

  my $filter_where_phrase = '';
  if (length($filter_phrase) > 0) {

    $filter_where_phrase = " AND $filter_phrase ";
  }

  my $filtering_exp = " WHERE (($perm_str) & $READ_PERM) = $READ_PERM $filter_where_phrase ";

  if (length($having_phrase) > 0) {
    $sql =~ s/FACTORHAVING/ HAVING $having_phrase/;

    $sql  =~ s/WHEREREPLACE GROUP BY/ $filtering_exp GROUP BY /;
  }
  else {

    $sql =~ s/FACTORHAVING//;

    $sql  =~ s/WHEREREPLACE GROUP BY/ $filtering_exp GROUP BY /;
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

    my $page_where_phrase = '';
    $page_where_phrase   .= ' LEFT JOIN trial ON trialunit.TrialId = trial.TrialId ';
    $page_where_phrase   .= " $filtering_exp ";

    my ($paged_id_err, $paged_id_msg, $nb_records, $nb_pages, $limit_clause, $rcount_time);

    if (length($having_phrase) == 0) {
      $self->logger->debug("COUNT NB RECORD: NO FACTOR IN FILTERING");

      ($paged_id_err, $paged_id_msg, $nb_records, $nb_pages, $limit_clause, $rcount_time) = get_paged_filter($dbh,
                                                                                                             $nb_per_page,
                                                                                                             $page,
                                                                                                             'trialunit',
                                                                                                             'TrialUnitId',
                                                                                                             $page_where_phrase,
                                                                                                             $where_arg);

    } else {
      $self->logger->debug("COUNT NB RECORD: FACTOR IN FILTERING");

      my $count_sql = "SELECT COUNT(trialunit.TrialUnitId) ";
      $count_sql   .= "FROM trialunit INNER JOIN ";
      $count_sql   .= " (SELECT TrialUnitId, COUNT(TrialUnitId) ";
      $count_sql   .= " FROM trialunitfactor WHERE $count_filter_phrase ";
      $count_sql   .= " GROUP BY TrialUnitId HAVING COUNT(TrialUnitId)=$nb_filter_factor) AS subq ";
      $count_sql   .= " ON trialunit.TrialUnitId = subq.TrialUnitId ";
      $count_sql   .= " LEFT JOIN trial ON trialunit.TrialId = trial.TrialId ";
      $count_sql   .= "$filtering_exp";

      $self->logger->debug("COUNT SQL: $count_sql");

      ($paged_id_err, $paged_id_msg, $nb_records, $nb_pages, $limit_clause, $rcount_time) = get_paged_filter_sql($dbh,
                                                                                                                 $nb_per_page,
                                                                                                                 $page,
                                                                                                                 $count_sql,
                                                                                                                 $where_arg);
      $self->logger->debug("COUNT WITH Factor TIME: $rcount_time");
    }

    $self->logger->debug("SQL Row count time: $rcount_time");

    if ($paged_id_err == 1) {

      $self->logger->debug($paged_id_msg);

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => "$paged_id_msg"}]};

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

  my ($sort_err, $sort_msg, $sort_sql) = parse_sorting($sorting, $sql_field_list);

  if ($sort_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sort_msg}]};

    return $data_for_postrun_href;
  }

  my $final_sort_sql = "";

  if (length($sort_sql) > 0) {

    $final_sort_sql .= " ORDER BY $sort_sql ";
  }
  else {

    $final_sort_sql .= ' ORDER BY trialunit.TrialUnitId DESC';
  }

  $sql =~ s/ORDERINGSTRING/$final_sort_sql/;

  if ($pagination == 0) {
    $sql =~ s/LIMITSTRING//;
  }
  else {
    $sql =~ s/LIMITSTRING/$paged_limit_clause/;
  }

  $self->logger->debug("Where arg: " . join(',', @{$where_arg}));

  $self->logger->debug("SQL with VCol: $sql");

  my ($read_tu_err, $read_tu_msg, $tu_data) = $self->list_trial_unit(1,
                                                                     $final_field_list,
                                                                     $sql,
                                                                     $where_arg);

  if ($read_tu_err) {

    $self->logger->debug($read_tu_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $read_tu_msg, 'Limit' => $pagination }]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'geojson'}   = 1;
  $data_for_postrun_href->{'GJSonInfo'} = {'GeometryField' => 'trialunitlocation',
                                           'FeatureName'   => 'Specimen[0] [ name: Specimen->SpecimenName ]',
                                           'FeatureId'     => 'TrialUnitId',
  };
  $data_for_postrun_href->{'Data'}  = {'TrialUnit'  => $tu_data,
                                       'VCol'       => $vcol_list,
                                       'Pagination' => $pagination_aref,
                                       'RecordMeta' => [{'TagName' => 'TrialUnit'}],
  };

  return $data_for_postrun_href;
}

sub list_trial_unit_specimen_advanced_runmode {

=pod list_trial_unit_specimen_advanced_HELP_START
{
"OperationName": "List trial unit specimen",
"Description": "List the whole association of specimens with trial units. This listing requires pagination information. Use filtering criteria to return subset of interest.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination NumOfRecords='103' NumOfPages='103' Page='1' NumPerPage='1' /><RecordMeta TagName='TrialUnitSpecimen' /><TrialUnitSpecimen SpecimenName='Specimen_0435994' Notes='None' remove='remove/trialunitspecimen/109' ItemId='0' TrialUnitId='76' TrialUnitSpecimenId='109' HarvestDate='0000-00-00' UltimatePermission='Read/Write/Link' PlantDate='0000-00-00' HasDied='0' update='update/trialunitspecimen/109' UltimatePerm='7' SpecimenId='477' TrialId='1' /></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfRecords' : '103','NumOfPages' : 103,'NumPerPage' : '1','Page' : '1'}],'RecordMeta' : [{'TagName' : 'TrialUnitSpecimen'}],'TrialUnitSpecimen' : [{'SpecimenName' : 'Specimen_0435994','remove' : 'remove/trialunitspecimen/109','Notes' : 'None','ItemId' : '0','TrialUnitId' : '76','TrialUnitSpecimenId' : '109','HarvestDate' : '0000-00-00','UltimatePermission' : 'Read/Write/Link','PlantDate' : '0000-00-00','HasDied' : '0','update' : 'update/trialunitspecimen/109','SpecimenId' : '477','UltimatePerm' : '7', 'TrialId' : 1 }]}",
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

  my $trial_unit_id          = -1;
  my $trial_unit_id_provided = 0;

  if (defined $self->param('id')) {

    $trial_unit_id          = $self->param('id');
    $trial_unit_id_provided = 1;

    if ($filtering_csv =~ /TrialUnitId\s*=\s*(.*),?/) {

      if ( "$trial_unit_id" ne "$1" ) {

        my $err_msg = 'Duplicate filtering condition for TrialUnitId.';
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
    else {

      if (length($filtering_csv) > 0) {

        if ($filtering_csv =~ /&$/) {

          $filtering_csv .= "TrialUnitId=$trial_unit_id";
        }
        else {

          $filtering_csv .= "&TrialUnitId=$trial_unit_id";
        }
      }
      else {

        $filtering_csv .= "TrialUnitId=$trial_unit_id";
      }
    }
  }

  $self->logger->debug("Filtering csv: $filtering_csv");

  my $sorting = '';

  if (defined $query->param('Sorting')) {

    $sorting = $query->param('Sorting');
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'trial');

  my $sql = 'SELECT * FROM trialunitspecimen LIMIT 1';

  my ($sample_tup_err, $sample_tup_msg, $sample_tup_data) = $self->list_trial_unit_specimen(0, $sql);

  if ($sample_tup_err) {

    $self->logger->debug($sample_tup_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $dbh = connect_kdb_read();

  my $sample_data_aref = $sample_tup_data;

  my @field_list_all;

  if (scalar(@{$sample_data_aref}) == 1) {

    @field_list_all = keys(%{$sample_data_aref->[0]});
  }
  else {

    $self->logger->debug("It reaches here");
    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'trialunitspecimen');

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
                                                                                'TrialUnitSpecimenId',
        );

    if ($sel_field_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;

    if ($filtering_csv =~ /TrialUnitId/) {

      push(@{$final_field_list}, 'TrialUnitId');
    }
  }

  my $field_lookup = {};
  for my $fd_name (@{$final_field_list}) {

    $field_lookup->{$fd_name} = 1;
  }

  my $other_join = '';

  if ($field_lookup->{'SpecimenId'}) {

    push(@{$final_field_list}, 'specimen.SpecimenName, specimen.Pedigree, specimen.SelectionHistory ');
    $other_join .= ' LEFT JOIN specimen ON trialunitspecimen.SpecimenId = specimen.SpecimenId ';
    
  }

   push(@{$final_field_list}, 'breedingmethod.BreedingMethodId, breedingmethod.BreedingMethodName');
  $other_join .= ' LEFT JOIN breedingmethod ON specimen.BreedingMethodId = breedingmethod.BreedingMethodId ';


  push(@{$final_field_list}, 'trial.TrialId');
  $other_join .= ' LEFT JOIN trial ON trialunit.TrialId = trial.TrialId ';


  $self->logger->debug("Final field list: " . join(', ', @{$final_field_list}));

  my $sql_field_list = [];

  for my $field_name (@{$final_field_list}) {

    my $full_field_name = $field_name;
    if (!($full_field_name =~ /\./)) {

      $full_field_name = 'trialunitspecimen.' . $full_field_name;
    }

    push(@{$sql_field_list}, $full_field_name);
  }

  push(@{$sql_field_list}, "$perm_str AS UltimatePerm ");



  my $field_list_str = join(', ', @{$sql_field_list});

  $sql  = "SELECT $field_list_str ";
  $sql .= 'FROM trialunitspecimen ';
  $sql .= 'LEFT JOIN trialunit ON trialunitspecimen.TrialUnitId = trialunit.TrialUnitId ';
  #$sql .= 'LEFT JOIN trial ON trialunit.TrialId = trial.TrialId ';
  $sql .= "$other_join ";

  my $validation_func_lookup = { 'TrialUnitId' => sub { return $self->validate_trial_unit_id(@_); },
                                  'TrialId' => sub { return $self->validate_trial_id(@_); } };

  $self->logger->debug("Final field list: " . join(', ', @{$final_field_list}));

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering('TrialUnitSpecimenId',
                                                                              'trialunitspecimen',
                                                                              $filtering_csv,
                                                                              $final_field_list,
                                                                              $validation_func_lookup,
      );

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

  my $filtering_exp = " WHERE (($perm_str) & $READ_PERM) = $READ_PERM $filter_where_phrase ";

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

    my $page_where_phrase = '';
    $page_where_phrase   .= ' LEFT JOIN trialunit ON trialunitspecimen.TrialUnitId = trialunit.TrialUnitId ';
    $page_where_phrase   .= ' LEFT JOIN trial ON trialunit.TrialId = trial.TrialId ';
    $page_where_phrase   .= " $filtering_exp ";

    my ($paged_id_err, $paged_id_msg, $nb_records,
        $nb_pages, $limit_clause, $rcount_time) = get_paged_filter($dbh,
                                                                   $nb_per_page,
                                                                   $page,
                                                                   'trialunitspecimen',
                                                                   'TrialUnitSpecimenId',
                                                                   $page_where_phrase,
                                                                   $where_arg
                                                                  );

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

  $sql .= " $filtering_exp ";

  my ($sort_err, $sort_msg, $sort_sql) = parse_sorting($sorting, $final_field_list, 'trialunitspecimen');

  if ($sort_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sort_msg}]};

    return $data_for_postrun_href;
  }

  if (length($sort_sql) > 0) {

    $sql .= " ORDER BY $sort_sql ";
  }
  else {

    $sql .= ' ORDER BY trialunitspecimen.TrialunitspecimenId DESC';
  }

  $sql .= " $paged_limit_clause ";

  $self->logger->debug("Where arg: " . join(',', @{$where_arg}));

  $self->logger->debug("SQL: $sql");

  my ($read_tus_err, $read_tus_msg, $tus_data) = $self->list_trial_unit_specimen(1,
                                                                                 $sql,
                                                                                 $where_arg);

  if ($read_tus_err) {

    $self->logger->debug($read_tus_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'} = 0;
  $data_for_postrun_href->{'Data'}  = {'TrialUnitSpecimen'  => $tus_data,
                                       'Pagination'         => $pagination_aref,
                                       'RecordMeta'         => [{'TagName' => 'TrialUnitSpecimen'}],
  };

  return $data_for_postrun_href;
}

sub add_trial_trait_runmode {

=pod add_trial_trait_HELP_START
{
"OperationName": "Add trait to trial",
"Description": "Attach a trait to the trial definition specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "trialtrait",
"SkippedField": ["TrialId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='6' ParaName='TrialTraitId' /><Info Message='Trait (1) has been added to Trial (2) successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '5','ParaName' : 'TrialTraitId'}],'Info' : [{'Message' : 'Trait (1) has been added to Trial (1) successfully.'}]}",
"ErrorMessageXML": [{"MissingParameter": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error TraitId='TraitId is missing.' /></DATA>"}],
"ErrorMessageJSON": [{"MissingParameter": "{'Error' : [{'TraitId' : 'TraitId is missing.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $trial_id            = $self->param('id');
  my $trait_id            = $query->param('TraitId');
  my $compulsory          = $query->param('Compulsory');

  my $unit_id             = undef;

  if (defined $query->param('UnitId')) {

    if (length($query->param('UnitId')) > 0) {

      $unit_id = $query->param('UnitId');
    }
  }

  my ($missing_err, $missing_href) = check_missing_href( {'TraitId'         => $trait_id,
                                                          'Compulsory'      => $compulsory,
                                                         } );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  my $group_id  = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $dbh_k_write = connect_kdb_write();

  my $trial_existence = record_existence($dbh_k_write, 'trial', 'TrialId', $trial_id);

  if (!$trial_existence) {

    my $err_msg = "Trial ($trial_id) does not exist.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TrialId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( !($compulsory =~ /0|1/) ) {

    my $err_msg = "Compulsory ($compulsory) can be only either 1 or 0.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Compulsory' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($is_trial_ok, $trouble_trial_id_aref) = check_permission($dbh_k_write, 'trial', 'TrialId',
                                                               [$trial_id], $group_id, $gadmin_status,
                                                               $READ_WRITE_PERM);

  if (!$is_trial_ok) {

    my $trouble_trial_id = $trouble_trial_id_aref->[0];

    my $err_msg = "Permission denied: Group ($group_id) and Trial ($trouble_trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TrialId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($is_trait_ok, $trouble_trait_id_aref) = check_permission($dbh_k_write, 'trait', 'TraitId',
                                                               [$trait_id], $group_id, $gadmin_status,
                                                               $READ_LINK_PERM);

  if (!$is_trait_ok) {

    my $trouble_trait_id = $trouble_trait_id_aref->[0];

    my $err_msg = "Permission denied: Group ($group_id) and Trait ($trouble_trait_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TraitId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT TrialTraitId FROM trialtrait WHERE TrialId=? AND TraitId=?';

  my $exist_ttrait_id = read_cell($dbh_k_write, $sql, [$trial_id, $trait_id]);

  if (length($exist_ttrait_id) > 0) {

    my $err_msg = "TraitId ($trait_id) already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TraitId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (defined $unit_id) {

    if (!record_existence($dbh_k_write, 'generalunit', 'UnitId', $unit_id)) {

      my $err_msg = "UnitId ($unit_id): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'UnitId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  $sql    = 'INSERT INTO trialtrait SET ';
  $sql   .= 'TrialId=?, ';
  $sql   .= 'TraitId=?, ';
  $sql   .= 'UnitId=?, ';
  $sql   .= 'Compulsory=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($trial_id, $trait_id, $unit_id, $compulsory);

  if ($dbh_k_write->err()) {

    $self->logger->debug("SQL Error:" . $dbh_k_write->errstr());
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  my $trial_trait_id = $dbh_k_write->last_insert_id(undef, undef, 'trialtrait', 'TrialTraitId');

  $dbh_k_write->disconnect();

  my $info_msg_aref  = [{'Message' => "Trait ($trait_id) has been added to Trial ($trial_id) successfully."}];
  my $return_id_aref = [{'Value' => "$trial_trait_id", 'ParaName' => 'TrialTraitId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_trial_trait {

  my $self           = shift;
  my $extra_attr_yes = shift;
  my $trial_perm     = shift;
  my $where_clause   = qq{};
  $where_clause      = shift;

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

  my $sql = 'SELECT trialtrait.TrialTraitId, trialtrait.TrialId, trialtrait.TraitId, trialtrait.Compulsory, ';
  $sql   .= 'trialtrait.UnitId AS TrialTraitUnitId, trait.TraitLevel,';
  $sql   .= 'gu2.UnitName AS UnitName, ';
  $sql   .= 'gu1.UnitName AS TrialTraitUnitName, ';
  $sql   .= 'trait.UnitId AS TraitUnitId, ';
  $sql   .= 'TraitGroupTypeId, TraitName, TraitCaption, TraitDescription, TraitDataType, ';
  $sql   .= 'TraitValueMaxLength, IsTraitUsedForAnalysis, TraitValRule, TraitValRuleErrMsg ';
  $sql   .= 'FROM trialtrait ';
  $sql   .= 'LEFT JOIN trait ON trialtrait.TraitId = trait.TraitId ';
  $sql   .= 'LEFT JOIN generalunit gu1 ON trialtrait.UnitId = gu1.UnitId ';
  $sql   .= 'LEFT JOIN generalunit gu2 ON trait.UnitId = gu2  .UnitId ';
  $sql   .= $where_clause;

  my ($ttrait_err, $ttrait_msg, $no_perm_ttrait_data) = read_data($dbh, $sql, \@_);

  if ($ttrait_err) {

    return ($ttrait_err, $ttrait_msg, []);
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'trait');

  my $perm_where = '';

  if (length($where_clause) > 0) {

    $perm_where = ' AND ';
  }
  else {

    $perm_where = ' WHERE ';
  }

  $perm_where .= "((($perm_str) & $READ_PERM) = $READ_PERM)";

  $sql   .= $perm_where;
  $sql   .= ' ORDER BY TrialTraitId DESC';

  $self->logger->debug("SQL: $sql");

  my ($perm_ttrait_err, $perm_ttrait_msg, $trial_trait_data) = read_data($dbh, $sql, \@_);

  if ($perm_ttrait_err) {

    return ($perm_ttrait_err, $perm_ttrait_msg, []);
  }

  my $err = 0;
  my $msg = '';

  my $nb_no_perm_ttrait = scalar(@{$no_perm_ttrait_data});

  if (scalar(@{$trial_trait_data}) != $nb_no_perm_ttrait) {

    $err = 1;
    $msg = 'Permission denied.';

    return ($err, $msg, []);
  }

  my $unique_trait_id_href = {};

  for my $row (@{$trial_trait_data}) {
    my $trait_id = $row->{'TraitId'};

    $self->logger->debug("Trait Id: $trait_id");

    if (!defined $unique_trait_id_href->{$trait_id}) {
      $unique_trait_id_href->{$trait_id} = 1;
    }
  }



  my $trait_alias_lookup = {};

  my $trait_alias_sql = 'SELECT traitalias.TraitId, traitalias.TraitAliasId, traitalias.TraitAliasName, traitalias.TraitAliasCaption, traitalias.TraitAliasDescription, ';
  $trait_alias_sql   .= 'traitalias.TraitLang ';
  $trait_alias_sql   .= 'FROM traitalias ';
  $trait_alias_sql   .= 'LEFT JOIN trait ON traitalias.TraitId = trait.TraitId ';
  $trait_alias_sql   .= 'WHERE traitalias.TraitId IN (' . join(',', keys(%{$unique_trait_id_href})) . ')';

  $self->logger->debug("Trial Trait SQL: $trait_alias_sql");

  my $trait_alias_data_final = [];

  if (scalar(@{$trial_trait_data})) {
    my ($trait_alias_err, $trait_alias_msg, $trait_alias_data) = read_data($dbh, $trait_alias_sql, []);

    if ($trait_alias_err) {

      return ($trait_alias_err, "$trait_alias_msg", []);
    }

    $trait_alias_data_final = $trait_alias_data;
  }
  else {
    $trait_alias_data_final = [];
  }


  for my $row (@{$trait_alias_data_final}) {

    my $trait_id = $row->{'TraitId'};

    if (defined $trait_alias_lookup->{$trait_id}) {

      my $trait_alias_aref = $trait_alias_lookup->{$trait_id};

      delete($row->{'TraitId'});

      push(@{$trait_alias_aref}, $row);

      $trait_alias_lookup->{$trait_id} = $trait_alias_aref;
    }
    else {

      delete($row->{'TraitId'});

      $trait_alias_lookup->{$trait_id} = [$row];
    }
  }

  my $extra_attr_trial_trait_data = [];

  for my $row (@{$trial_trait_data}) {

    if ($extra_attr_yes) {

      if (($trial_perm & $READ_WRITE_PERM) == $READ_WRITE_PERM) {

        my $trial_trait_id = $row->{'TrialTraitId'};
        my $trial_id       = $row->{'TrialId'};
        my $trait_id       = $row->{'TraitId'};
        $row->{'update'}   = "update/trialtrait/$trial_trait_id";
        $row->{'delete'}   = "trial/$trial_id/remove/trait/$trait_id";

        if (defined $trait_alias_lookup->{$trait_id}) {

          my $trait_alias_aref = [];

          my $trait_alias_data = $trait_alias_lookup->{$trait_id};

          for my $trait_alias_info (@{$trait_alias_data}) {

            my $trait_alias_id = $trait_alias_info->{'TraitAliasId'};

            $trait_alias_info->{'removeAlias'} = "remove/traitalias/$trait_alias_id";

            push(@{$trait_alias_aref}, $trait_alias_info);
          }

          $row->{'TraitAlias'} = $trait_alias_aref;
        }
      }
    }

    push(@{$extra_attr_trial_trait_data}, $row);
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_trial_trait_data);
}

sub list_trial_trait_runmode {

=pod list_trial_trait_HELP_START
{
"OperationName": "List traits for trial",
"Description": "List all the traits attached to the trial specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><TrialTrait UnitName='g' UnitName='Trait_4102474' TrialTraitUnitName='Trait_4102474' TraitValRule='boolex(x &gt; 0 and x &lt; 500)' TraitDataType='INTEGER' TraitValueMaxLength='20' TraitUnit='2' TrialTraitId='5' delete='trial/1/remove/trait/1' TraitName='Trait_4102474' Compulsory='1' TraitId='1' update='update/trialtrait/5' TrialId='1' /><RecordMeta TagName='TrialTrait' /></DATA>",
"SuccessMessageJSON": "{'TrialTrait' : [{'TraitValRule' : 'boolex(x > 0 and x < 500)','TraitDataType' : 'INTEGER','TraitValueMaxLength' : '20','TraitUnit' : '2','TrialTraitId' : '5','delete' : 'trial/1/remove/trait/1','TraitName' : 'Trait_4102474','TrialTraitName' : 'Trait_4102474','Compulsory' : '1','update' : 'update/trialtrait/5','TraitId' : '1','TrialId' : '1'}],'RecordMeta' : [{'TagName' : 'TrialTrait'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self    = shift;
  my $trial_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  my $trial_exist = record_existence($dbh, 'trial', 'TrialId', $trial_id);

  if (!$trial_exist) {

    my $err_msg = "Trial ($trial_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TrialId' => $err_msg}]};

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
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TrialId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $perm_str = permission_phrase($group_id, 0, $gadmin_status);
  my $sql = "SELECT $perm_str FROM trial WHERE TrialId=?";

  my ($read_perm_err, $trial_perm) = read_cell($dbh, $sql, [$trial_id]);

  if ($read_perm_err) {

    my $err_msg = "Unexpected Error";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  my $where_clause = 'WHERE TrialId=?';
  my ($trial_trait_err, $trial_trait_msg, $trial_trait_data) = $self->list_trial_trait(1,
                                                                                       $trial_perm,
                                                                                       $where_clause,
                                                                                       $trial_id);

  if ($trial_trait_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $trial_trait_msg}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'TrialTrait' => $trial_trait_data,
                                           'RecordMeta'    => [{'TagName' => 'TrialTrait'}],
  };

  return $data_for_postrun_href;
}

sub get_trial_trait_runmode {

=pod get_trial_trait_HELP_START
{
"OperationName": "Get trial trait",
"Description": "Get detailed information about trial and trait association specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><TrialTrait TraitValRule='boolex(x &gt; 0 and x &lt; 500)' TraitDataType='INTEGER' TraitValueMaxLength='20' TraitUnit='2' TrialTraitId='5' delete='trial/1/remove/trait/1' TraitName='Trait_4102474' Compulsory='1' TraitId='1' update='update/trialtrait/5' TrialId='1' /><RecordMeta TagName='TrialTrait' /></DATA>",
"SuccessMessageJSON": "{'TrialTrait' : [{'TraitValRule' : 'boolex(x > 0 and x < 500)','TraitDataType' : 'INTEGER','TraitValueMaxLength' : '20','TraitUnit' : '2','TrialTraitId' : '5','delete' : 'trial/1/remove/trait/1','TraitName' : 'Trait_4102474','Compulsory' : '1','update' : 'update/trialtrait/5','TraitId' : '1','TrialId' : '1'}],'RecordMeta' : [{'TagName' : 'TrialTrait'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TrialTraitId (10) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'TrialTraitId (10) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialTraitId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self          = shift;
  my $trial_trait_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $trial_id = read_cell_value($dbh, 'trialtrait', 'TrialId', 'TrialTraitId', $trial_trait_id);

  if (length($trial_id) == 0) {

    my $err_msg = "TrialTraitId ($trial_trait_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $perm_str = permission_phrase($group_id, 0, $gadmin_status);
  my $sql      = "SELECT $perm_str FROM trial WHERE TrialId=?";

  my ($read_perm_err, $trial_perm) = read_cell($dbh, $sql, [$trial_id]);

  if ($read_perm_err) {

    my $err_msg = "Unexpected Error";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( ($trial_perm & $READ_PERM) != $READ_PERM ) {

    my $err_msg = "Permission denied: Group ($group_id) and trial ($trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  my $where_clause = 'WHERE TrialTraitId=?';
  my ($trial_trait_err, $trial_trait_msg, $trial_trait_data) = $self->list_trial_trait(1,
                                                                                       $trial_perm,
                                                                                       $where_clause,
                                                                                       $trial_trait_id);

  if ($trial_trait_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $trial_trait_msg}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'TrialTrait' => $trial_trait_data,
                                           'RecordMeta'    => [{'TagName' => 'TrialTrait'}],
  };

  return $data_for_postrun_href;
}

sub list_unitposition_field_runmode {

=pod list_unitposition_field_HELP_START
{
"OperationName": "List unit position fields",
"Description": "List all available unit position field types currently stored in unit position dictionary.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><UnitPositionField FieldName='block' /><UnitPositionField FieldName='row' /><UnitPositionField FieldName='column' /><UnitPositionField FieldName='GlassHouse' /><UnitPositionField FieldName='Bench' /><UnitPositionField FieldName='Row' /><UnitPositionField FieldName='Column' /><UnitPositionField FieldName='Pot' /><UnitPositionField FieldName='Range' /><RecordMeta TagName='UnitPositionField' /></DATA>",
"SuccessMessageJSON": "{'UnitPositionField' : [{'FieldName' : 'block'},{'FieldName' : 'row'},{'FieldName' : 'column'},{'FieldName' : 'GlassHouse'},{'FieldName' : 'Bench'},{'FieldName' : 'Row'},{'FieldName' : 'Column'},{'FieldName' : 'Pot'},{'FieldName' : 'Range'}],'RecordMeta' : [{'TagName' : 'UnitPositionField'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self     = shift;

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  my $sql = 'SELECT UnitPositionText ';
  $sql   .= 'FROM unitposition';

  my ($read_err, $read_msg, $unitposition_data) = read_data($dbh, $sql, []);

  if ($read_err) {

    $self->logger->debug($read_msg);
    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  my $unit_pos_text_splitter = "$UNIT_POSITION_SPLITTER";

  if ($unit_pos_text_splitter =~ /\|/) {

    $unit_pos_text_splitter = "\\$unit_pos_text_splitter";
  }

  my $unique_field = {};
  my $unitposition_field_aref = [];

  for my $unitposition_rec (@{$unitposition_data}) {

    my $unitposition_txt = $unitposition_rec->{'UnitPositionText'};
    my @unitposition_parts = split("$unit_pos_text_splitter", $unitposition_txt);

    for my $unitposition_field (@unitposition_parts) {

      $unitposition_field =~ s/^(\D+)(\d+)$/$1/g;

      if ($unique_field->{$unitposition_field}) { next; }

      my $up_href = {};
      $up_href->{'FieldName'} = $unitposition_field;
      $unique_field->{$unitposition_field} = 1;

      push(@{$unitposition_field_aref}, $up_href);
    }
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'UnitPositionField' => $unitposition_field_aref,
                                           'RecordMeta'        => [{'TagName' => 'UnitPositionField'}],
  };

  return $data_for_postrun_href;
}

sub update_trial_trait_runmode {

=pod update_trial_trait_HELP_START
{
"OperationName": "Update trial trait",
"Description": "Update trial and trait association for specified id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "trialtrait",
"SkippedField": ["TrialId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='TrialTrait (1) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'TrialTrait (1) has been updated successfully.'}]}",
"ErrorMessageXML": [{"MissingParameter": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error TraitId='TraitId is missing.' /></DATA>"}],
"ErrorMessageJSON": [{"MissingParameter": "{'Error' : [{'TraitId' : 'TraitId is missing.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialTraitId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self           = shift;
  my $trial_trait_id = $self->param('id');
  my $query          = $self->query();

  my $data_for_postrun_href = {};

  my $compulsory   = $query->param('Compulsory');

  my ($missing_err, $missing_href) = check_missing_href( { 'Compulsory' => $compulsory } );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  if ( !($compulsory =~ /0|1/) ) {

    my $err_msg = "Compulsory ($compulsory) can be only either 1 or 0.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Compulsory' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_read = connect_kdb_read();

  my $read_trial_trait_sql   =   'SELECT TrialId, UnitId ';
     $read_trial_trait_sql  .=   'FROM trialtrait WHERE TrialTraitId=? ';

  my ($r_df_val_err, $r_df_val_msg, $trialtrait_df_val_data) = read_data($dbh_read, $read_trial_trait_sql, [$trial_trait_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve trialtrait default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $trial_id      = undef;
  my $unit_id       = undef;

  my $nb_df_val_rec    =  scalar(@{$trialtrait_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve trialtrait default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $trial_id   =  $trialtrait_df_val_data->[0]->{'TrialId'};
  $unit_id    =  $trialtrait_df_val_data->[0]->{'UnitId'};


  if ( length($trial_id) == 0 ) {

    my $err_msg = "TrialTraitId ($trial_trait_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }


  if (length($unit_id) == 0) {

    $unit_id = undef;
  }

  if (defined $query->param('UnitId')) {

    if (length($query->param('UnitId')) > 0) {

      $unit_id = $query->param('UnitId');
    }
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status);

  my $sql  = "SELECT $perm_str AS UltimatePermission ";
  $sql    .= 'FROM trial ';
  $sql    .= 'WHERE TrialId=?';

  my ($read_err, $trial_permission) = read_cell($dbh_read, $sql, [$trial_id]);

  if ( ($trial_permission & $READ_WRITE_PERM) != $READ_WRITE_PERM ) {

    my $err_msg = "Trial ($trial_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_read->disconnect();

  my $dbh_write = connect_kdb_write();

  $sql  = 'UPDATE trialtrait SET ';
  $sql .= 'UnitId=?, ';
  $sql .= 'Compulsory=? ';
  $sql .= 'WHERE TrialTraitId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($unit_id, $compulsory, $trial_trait_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "TrialTrait ($trial_trait_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub remove_trial_trait_runmode {

=pod remove_trial_trait_HELP_START
{
"OperationName": "Delete trait for trial",
"Description": "Delete trait from being associated with the trial. If data for this trait already exists in the trial, this association can not be removed.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Trait (1) has been removed from trial (1).' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Trait (1) has been removed from trial (2).'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Trait (2) not part of trial (2).' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Trait (2) not part of trial (2).'}]}"}],
"URLParameter": [{"ParameterName": "trialid", "Description": "Existing TrialId"}, {"ParameterName": "traitid", "Description": "TraitId which is attached to the trial"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self     = shift;
  my $trial_id = $self->param('trialid');
  my $trait_id = $self->param('traitid');

  my $data_for_postrun_href = {};

  my $dbh_read = connect_kdb_read();

  my $trial_exist = record_existence($dbh_read, 'trial', 'TrialId', $trial_id);

  if (!$trial_exist) {

    my $err_msg = "Trial ($trial_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status);

  my $sql = "SELECT $perm_str AS UltimatePermission ";
  $sql   .= 'FROM trial ';
  $sql   .= 'WHERE TrialId=?';

  my ($read_err, $trial_permission) = read_cell($dbh_read, $sql, [$trial_id]);

  if ( ($trial_permission & $READ_WRITE_PERM) != $READ_WRITE_PERM ) {

    my $err_msg = "TrialId ($trial_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trait_exist = record_existence($dbh_read, 'trait', 'TraitId', $trait_id);

  if (!$trait_exist) {

    my $err_msg = "TraitId ($trait_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql    = 'SELECT TrialTraitId ';
  $sql   .= 'FROM trialtrait ';
  $sql   .= 'WHERE TrialId=? AND TraitId=?';

  my $trial_trait_id;
  ($read_err, $trial_trait_id) = read_cell($dbh_read, $sql, [$trial_id, $trait_id]);

  if (length($trial_trait_id) == 0) {

    my $err_msg = "Trait ($trait_id) not part of trial ($trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_read->disconnect();

  my $dbh_write = connect_kdb_write();

  $sql  = 'DELETE FROM trialtrait ';
  $sql .= 'WHERE TrialTraitId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($trial_trait_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "Trait ($trait_id) has been removed from trial ($trial_id)."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub del_designtype_runmode {

=pod del_designtype_gadmin_HELP_START
{
"OperationName": "Delete design type",
"Description": "Delete trial design type specified by id. Design type can be deleted only if not attached to any lower level related record.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='DesignType (18) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'DesignType (18) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdUsed": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='DesignType (17) is used in trial.' /></DATA>"}],
"ErrorMessageJSON": [{"IdUsed": "{'Error' : [{'Message' : 'DesignType (17) is used in trial.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing DesignTypeId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $designtype_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_k_read = connect_kdb_read();

  my $designtype_exist = record_existence($dbh_k_read, 'designtype', 'DesignTypeId', $designtype_id);

  if (!$designtype_exist) {

    my $err_msg = "DesignType ($designtype_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $designtype_used = record_existence($dbh_k_read, 'trial', 'DesignTypeId', $designtype_id);

  if ($designtype_used) {

    my $err_msg = "DesignType ($designtype_id) is used in trial.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $sql = 'DELETE FROM designtype WHERE DesignTypeId=?';
  my $sth = $dbh_k_write->prepare($sql);

  $sth->execute($designtype_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref = [{'Message' => "DesignType ($designtype_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub del_site_runmode {

=pod del_site_gadmin_HELP_START
{
"OperationName": "Delete site",
"Description": "Delete site specified by id. Site can be deleted only if not attached to any lower level related record.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Site (17) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Site (18) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdUsed": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Site (1) is used in trial.' /></DATA>"}],
"ErrorMessageJSON": [{"IdUsed": "{'Error' : [{'Message' : 'Site (1) is used in trial.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SiteId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $site_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_k_read = connect_kdb_read();

  my $site_exist = record_existence($dbh_k_read, 'site', 'SiteId', $site_id);

  if (!$site_exist) {

    my $err_msg = "Site ($site_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $site_in_trial = record_existence($dbh_k_read, 'trial', 'SiteId', $site_id);

  if ($site_in_trial) {

    my $err_msg = "Site ($site_id) is used in trial.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_gis_write = connect_gis_write();

  my $sql = 'DELETE FROM siteloc WHERE siteid=?';

  my $sth = $dbh_gis_write->prepare($sql);
  $sth->execute($site_id);

  if ($dbh_gis_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_gis_write->disconnect();

  my $dbh_k_write = connect_kdb_write();

  $sql = 'DELETE FROM sitefactor WHERE SiteId=?';
  $sth = $dbh_k_write->prepare($sql);

  $sth->execute($site_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $sql = 'DELETE FROM site WHERE SiteId=?';
  $sth = $dbh_k_write->prepare($sql);

  $sth->execute($site_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref = [{'Message' => "Site ($site_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub del_trial_runmode {

=pod del_trial_gadmin_HELP_START
{
"OperationName": "Delete trial",
"Description": "Delete trial for a specified id. Trial can be deleted only if not attached to any lower level related record.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Trial (14) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Trial (15) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdUsed": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Trial (1) has trialunit(s).' /></DATA>"}],
"ErrorMessageJSON": [{"IdUsed": "{'Error' : [{'Message' : 'Trial (1) has trialunit(s).'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $trial_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_k_read = connect_kdb_read();

  my $trial_owner_id = read_cell_value($dbh_k_read, 'trial', 'OwnGroupId', 'TrialId', $trial_id);

  if (length($trial_owner_id) == 0) {

    my $err_msg = "Trial ($trial_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();

  if ($trial_owner_id != $group_id) {

    my $err_msg = "Trial ($trial_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trial_trait = record_existence($dbh_k_read, 'trialtrait', 'TrialId', $trial_id);

  if ($trial_trait) {

    my $err_msg = "Trial ($trial_id) has trait(s).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trial_trialunit = record_existence($dbh_k_read, 'trialunit', 'TrialId', $trial_id);

  if ($trial_trialunit) {

    my $err_msg = "Trial ($trial_id) has trialunit(s).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (record_existence($dbh_k_read, 'trialworkflow', 'TrialId', $trial_id)) {

    my $err_msg = "Trial ($trial_id) has a workflow.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_gis_write = connect_gis_write();

  my $sql = 'DELETE FROM trialloc WHERE trialid=?';

  my $sth = $dbh_gis_write->prepare($sql);
  $sth->execute($trial_id);

  if ($dbh_gis_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_gis_write->disconnect();

  my $dbh_k_write = connect_kdb_write();

  $sql = "DELETE FROM trialfactor WHERE TrialId=?";
  $sth = $dbh_k_write->prepare($sql);

  $sth->execute($trial_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $sql = 'DELETE FROM trialdimension WHERE TrialId=?';

  $sth = $dbh_k_write->prepare($sql);

  $sth->execute($trial_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sql = "DELETE FROM trial WHERE TrialId=?";
  $sth = $dbh_k_write->prepare($sql);

  $sth->execute($trial_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref = [{'Message' => "Trial ($trial_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub del_trial_unit_runmode {

=pod del_trial_unit_gadmin_HELP_START
{
"OperationName": "Delete trial unit",
"Description": "Delete trial unit from the trial specified by id. If data for this trial unit already exists, than trial unit can not be deleted.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='TrialUnit (76) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'TrialUnit (75) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdUsed": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TrialUnit (77) has samplemeasurement record(s).' /></DATA>"}],
"ErrorMessageJSON": [{"IdUsed": "{'Error' : [{'Message' : 'TrialUnit (77) has samplemeasurement record(s).'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialUnitId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = shift;
  my $tunit_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status);

  my $dbh_k_read = connect_kdb_read();

  my $trial_id = read_cell_value($dbh_k_read, 'trialunit', 'TrialId', 'TrialUnitId', $tunit_id);

  if (length($trial_id) == 0) {

    my $err_msg = "TrialUnit ($tunit_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = "SELECT $perm_str AS UltimatePerm FROM trial WHERE TrialId=?";

  my $trial_perm = read_cell($dbh_k_read, $sql, [$trial_id]);

  if ( ($trial_perm & $READ_WRITE_PERM) != $READ_WRITE_PERM ) {

    my $err_msg = "TrialUnit ($tunit_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $tunit_measurement = record_existence($dbh_k_read, 'samplemeasurement', 'TrialUnitId', $tunit_id);

  if ($tunit_measurement) {

    my $err_msg = "TrialUnit ($tunit_id) has samplemeasurement record(s).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_gis_write = connect_gis_write();

  $sql = 'DELETE FROM trialunitloc WHERE trialunitid=?';

  my $sth = $dbh_gis_write->prepare($sql);
  $sth->execute($tunit_id);

  if ($dbh_gis_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_gis_write->disconnect();

  my $dbh_k_write = connect_kdb_write();

  $sql = "DELETE FROM trialunitspecimen WHERE TrialUnitId=?";
  $sth = $dbh_k_write->prepare($sql);

  $sth->execute($tunit_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $sql = "DELETE FROM trialunittreatment WHERE TrialUnitId=?";
  $sth = $dbh_k_write->prepare($sql);

  $sth->execute($tunit_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $sql = "DELETE FROM trialunitfactor WHERE TrialUnitId=?";
  $sth = $dbh_k_write->prepare($sql);

  $sth->execute($tunit_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $sql = "DELETE FROM trialunit WHERE TrialUnitId=?";
  $sth = $dbh_k_write->prepare($sql);

  $sth->execute($tunit_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref = [{'Message' => "TrialUnit ($tunit_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub del_trial_crossing_runmode {

=pod del_trial_crossing_gadmin_HELP_START
{
"OperationName": "Delete trial crossing",
"Description": "Delete trial crossing from the trial specified by id. ",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Crossing (76) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Crossing (75) has been deleted successfully.'}]}",
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialUnitId."}],
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error CrossingId='Crossing (269) does not exist.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'TypeId' : 'CrossingId (269) does not exist.'}]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = shift;
  my $crossing_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status);

  my $dbh_k_read = connect_kdb_read();

  my $trial_id = read_cell_value($dbh_k_read, 'crossing', 'TrialId', 'CrossingId', $crossing_id);

  if (length($trial_id) == 0) {

    my $err_msg = "Crossing ($crossing_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = "SELECT $perm_str AS UltimatePerm FROM trial WHERE TrialId=?";

  my $trial_perm = read_cell($dbh_k_read, $sql, [$trial_id]);

  if ( ($trial_perm & $READ_WRITE_PERM) != $READ_WRITE_PERM ) {

    my $err_msg = "Crossing ($crossing_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $crossing_has_measurements = record_existence( $dbh_k_read, 'crossingmeasurement', 'CrossingId', $crossing_id );

  if ($crossing_has_measurements) {

    my $err_msg = "Crossing ($crossing_id): has crossing measurements attached. ";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }


  my $specimen_has_crossing = record_existence( $dbh_k_read, 'specimen', 'SourceCrossingId', $crossing_id );

  if ($specimen_has_crossing) {

    my $err_msg = "Crossing ($crossing_id): a specimen contains this crossing, cannot delete. ";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_write = connect_kdb_write();

  $self->logger->debug($crossing_id);

  $sql = 'DELETE FROM crossing where CrossingId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($crossing_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error. Please contact database manager.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "Crossing ($crossing_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;



}


sub add_project_runmode {

=pod add_project_gadmin_HELP_START
{
"OperationName": "Add project",
"Description": "Add a new project to the system.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "project",
"KDDArTFactorTable": "projectfactor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='3' ParaName='ProjectId' /><Info Message='Project (3) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '2','ParaName' : 'ProjectId'}],'Info' : [{'Message' : 'Project (2) has been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error TypeId='ProjectType (269) does not exist.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'TypeId' : 'TypeId (269) does not exist.'}]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};
  my $project_err = 0;
  my $project_err_aref = [];

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'project', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $project_name          = $query->param('ProjectName');
  my $projecttype_id        = $query->param('TypeId');
  my $cur_manager_id        = $query->param('ProjectManagerId');

  my $project_sdate         = undef;
  if ($query->param('ProjectStartDate')) {

    if (length($query->param('ProjectStartDate')) > 0) {

      $project_sdate         = $query->param('ProjectStartDate');
      my ($sdate_err, $sdate_href) = check_dt_href( {'ProjectStartDate' => $project_sdate} );

      if ($sdate_err) {
        push(@{$project_err_aref}, $sdate_href);
        $project_err = 1;
      }

    }

  }

  my $project_edate         = undef;
  if ($query->param('ProjectEndDate')) {

    if (length($query->param('ProjectEndDate')) > 0) {

      $project_edate         = $query->param('ProjectEndDate');
      my ($edate_err, $edate_href) = check_dt_href( {'ProjectEndDate' => $project_edate} );

      if ($edate_err) {
        push(@{$project_err_aref}, $edate_href);
        $project_err = 1;
      }

    }

  }

  my $project_note   = undef;
  my $project_status = undef;

  if (defined $query->param('ProjectNote')) {
    if (length($query->param('ProjectNote')) > 0) {

     $project_note = $query->param('ProjectNote');

    }
  }

  if (defined $query->param('ProjectStatus')) {
    if (length($query->param('ProjectStatus')) > 0) {

     $project_status = $query->param('ProjectStatus');
    }
  }

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength, FactorValidRuleErrMsg, FactorValidRule  ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='projectfactor'";

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
      'CanFactorHaveNull' => $vcol_data->{$vcol_id}->{'CanFactorHaveNull'}
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

  if (record_existence($dbh_k_read, 'project', 'ProjectName', $project_name)) {

    my $err_msg = "ProjectName ($project_name) already exists.";

    push(@{$project_err_aref}, {'ProjectName' => $err_msg});
    $project_err = 1;
  }

  my $projecttype_existence = type_existence($dbh_k_read, 'project', $projecttype_id);

  if (!$projecttype_existence) {

    my $err_msg = "TypeId ($projecttype_id) does not exist.";
    
    push(@{$project_err_aref}, {'TypeId' => $err_msg});
    $project_err = 1;
  }

  my $cur_manager_existence = record_existence($dbh_k_read, 'contact', 'ContactId', $cur_manager_id);

  if (!$cur_manager_existence) {

    my $err_msg = "ProjectManagerId ($cur_manager_id) does not exist.";
    
    push(@{$project_err_aref}, {'ProjectManagerId' => $err_msg});
    $project_err = 1;
  }

  $dbh_k_read->disconnect();

  #check vcol validation

  my ($vcol_error, $vcol_error_aref) = validate_all_factor_input($pre_validate_vcol);

  if ($vcol_error) {
    push(@{$project_err_aref}, @{$vcol_error_aref});
    $project_err = 1;
  }

  if ($project_err != 0) {
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => $project_err_aref};
    return $data_for_postrun_href;
  }

  my $dbh_k_write = connect_kdb_write();

  $sql  = 'INSERT INTO project SET ';
  $sql .= 'ProjectName=?, ';
  $sql .= 'ProjectStatus=?, ';
  $sql .= 'TypeId=?, ';
  $sql .= 'ProjectManagerId=?, ';
  $sql .= 'ProjectStartDate=?, ';
  $sql .= 'ProjectEndDate=?, ';
  $sql .= 'ProjectNote=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($project_name, $project_status, $projecttype_id, $cur_manager_id,
                $project_sdate, $project_edate, $project_note);

  my $project_id = -1;
  if (!$dbh_k_write->err()) {

    $project_id = $dbh_k_write->last_insert_id(undef, undef, 'project', 'ProjectId');
    $self->logger->debug("ProjectId: $project_id");
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

      $sql  = 'INSERT INTO projectfactor SET ';
      $sql .= 'ProjectId=?, ';
      $sql .= 'FactorId=?, ';
      $sql .= 'FactorValue=?';
      my $factor_sth = $dbh_k_write->prepare($sql);
      $factor_sth->execute($project_id, $vcol_id, $factor_value);

      if ($dbh_k_write->err()) {

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

        return $data_for_postrun_href;
      }

      $factor_sth->finish();
    }
  }

  $dbh_k_write->disconnect();

  my $info_msg_aref  = [{'Message' => "Project ($project_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$project_id", 'ParaName' => 'ProjectId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}


sub update_project_runmode {

=pod update_project_gadmin_HELP_START
{
"OperationName": "Update project",
"Description": "Update information about a project specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "project",
"KDDArTFactorTable": "projectfactor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Project (2) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Project (2) has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error TypeId='TypeId (12) does not exist.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'TypeId' : 'TypeId (12) does not exist.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing ProjectId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = shift;
  my $query = $self->query();

  my $project_id = $self->param('id');

  my $data_for_postrun_href = {};
  my $project_err = 0;
  my $project_err_aref = [];

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'project', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $dbh_k_read = connect_kdb_read();

  if (!record_existence($dbh_k_read, 'project', 'ProjectId', $project_id)) {

    my $err_msg = "ProjectId ($project_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $project_name          = $query->param('ProjectName');
  my $projecttype_id        = $query->param('TypeId');
  my $cur_manager_id        = $query->param('ProjectManagerId');

  my $project_name_sql      = "SELECT ProjectId FROM project WHERE ProjectId<>? AND ProjectName=?";

  my ($r_proj_name_err, $db_proj_id) = read_cell($dbh_k_read, $project_name_sql, [$project_id, $project_name]);

  if (length($db_proj_id) > 0) {

    my $err_msg = "ProjectName ($project_name) already exists.";

    push(@{$project_err_aref}, {'ProjectName' => $err_msg});
    $project_err = 1;
  }

  my $read_proj_sql    =  'SELECT ProjectStartDate, ProjectEndDate, ProjectStatus, ProjectNote ';
     $read_proj_sql   .=  'FROM project WHERE ProjectId=? ';

  my ($r_df_val_err, $r_df_val_msg, $proj_df_val_data) = read_data($dbh_k_read, $read_proj_sql, [$project_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve project default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $project_sdate    = undef;
  my $project_edate    = undef;
  my $project_status   = undef;
  my $project_note     = undef;

  my $nb_df_val_rec    =  scalar(@{$proj_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve project default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $project_sdate      =  $proj_df_val_data->[0]->{'ProjectStartDate'};
  $project_edate      =  $proj_df_val_data->[0]->{'ProjectEndDate'};
  $project_status     =  $proj_df_val_data->[0]->{'ProjectStatus'};
  $project_note       =  $proj_df_val_data->[0]->{'ProjectNote'};


  if (defined $query->param('ProjectStartDate')) {

    if (length($query->param('ProjectStartDate')) > 0) {

      $project_sdate         = $query->param('ProjectStartDate');
      my ($sdate_err, $sdate_href) = check_dt_href( {'ProjectStartDate' => $project_sdate} );

      if ($sdate_err) {

        push(@{$project_err_aref}, $sdate_href);
        $project_err = 1;
      }
    }
  }

  # Unknown Start DateTime value from database 0000-00-00 00:00:00 which should be reset to undef,
  # and then null in the db

  if ($project_sdate eq '0000-00-00 00:00:00') {

    $project_sdate = undef;
  }

  if (length($project_sdate) == 0) {

    $project_sdate = undef;
  }


  if (defined $query->param('ProjectEndDate')) {

    if (length($query->param('ProjectEndDate')) > 0) {

      $project_edate         = $query->param('ProjectEndDate');
      my ($edate_err, $edate_href) = check_dt_href( {'ProjectEndDate' => $project_edate} );

      if ($edate_err) {

        push(@{$project_err_aref}, $edate_href);
        $project_err = 1;
      }
    }
  }

  # Unknown Start DateTime value from database 0000-00-00 00:00:00 which should be reset to undef,
  # and then null in the db

  if ($project_edate eq '0000-00-00 00:00:00') {

    $project_edate = undef;
  }

  if (length($project_edate) == 0) {

    $project_edate = undef;
  }


  if (defined $query->param('ProjectNote')) {
    if (length($query->param('ProjectNote')) > 0) {

       $project_note = $query->param('ProjectNote');

    }
  }

  if (defined $query->param('ProjectStatus')) {
    if (length($query->param('ProjectStatus')) > 0) {

       $project_status = $query->param('ProjectStatus');
    }
  }

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength, FactorValidRuleErrMsg, FactorValidRule  ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='projectfactor'";

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
      'CanFactorHaveNull' => $vcol_data->{$vcol_id}->{'CanFactorHaveNull'}
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

  my $projecttype_existence = type_existence($dbh_k_read, 'project', $projecttype_id);

  if (!$projecttype_existence) {

    my $err_msg = "ProjectTypeId ($projecttype_id) does not exist.";

    push(@{$project_err_aref}, {'TypeId' => $err_msg});
    $project_err = 1;
  }

  my $cur_manager_existence = record_existence($dbh_k_read, 'contact', 'ContactId', $cur_manager_id);

  if (!$cur_manager_existence) {

    my $err_msg = "ProjectManagerId ($cur_manager_id) does not exist.";

    push(@{$project_err_aref}, {'ProjectManagerId' => $err_msg});
    $project_err = 1;
  }

  #check vcol validation

  my ($vcol_error, $vcol_error_aref) = validate_all_factor_input($pre_validate_vcol);

  if ($vcol_error) {
    push(@{$project_err_aref}, @{$vcol_error_aref});
    $project_err = 1;
  }

  if ($project_err != 0) {
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => $project_err_aref};
    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  $sql  = 'UPDATE project SET ';
  $sql .= 'ProjectName=?, ';
  $sql .= 'TypeId=?, ';
  $sql .= 'ProjectManagerId=?, ';
  $sql .= 'ProjectStartDate=?, ';
  $sql .= 'ProjectEndDate=?, ';
  $sql .= 'ProjectStatus=?, ';
  $sql .= 'ProjectNote=? ';
  $sql .= 'WHERE ProjectId=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($project_name, $projecttype_id, $cur_manager_id,
                $project_sdate, $project_edate, $project_status, $project_note, $project_id);

  if ($dbh_k_write->err()) {

    $self->logger->debug("Update project failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

    my $vcol_error = [];

  for my $vcol_id (keys(%{$vcol_data})) {

    if (defined $query->param('VCol_' . "$vcol_id")) {

      my $factor_value = $query->param('VCol_' . "$vcol_id");

      my ($vcol_err, $vcol_msg) = update_factor_value($dbh_k_write, $vcol_id, $factor_value, 'projectfactor', 'ProjectId', $project_id);

      if ($vcol_err) {

        $self->logger->debug("VCol_" . "$vcol_id => $vcol_msg" );

        push(@{$project_err_aref}, {'VCol_' . "$vcol_id" => $vcol_msg});

        $project_err = 1;
      }
    }
  }

  if ($project_err != 0) {
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => $project_err_aref};
      return $data_for_postrun_href;
  }

  $dbh_k_write->disconnect();

  my $info_msg_aref  = [{'Message' => "Project ($project_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_project {

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
  # parameters provided by the caller
  # for example, ('WHERE FieldA=?', '1')
  $sth->execute(@{$where_para_aref});

  my $err = 0;
  my $msg = '';
  my $project_data = [];

  if ( !$dbh->err() ) {

    my $array_ref = $sth->fetchall_arrayref({});

    if ( !$sth->err() ) {

      $project_data = $array_ref;
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

  my $extra_attr_project_data = [];

  if ($extra_attr_yes) {

    my $project_id_aref = [];

    for my $row (@{$project_data}) {

      push(@{$project_id_aref}, $row->{'ProjectId'});
    }

    my $chk_id_err        = 0;
    my $chk_id_msg        = '';
    my $used_id_href      = {};
    my $not_used_id_href  = {};

    if (scalar(@{$project_id_aref}) > 0) {

      my $chk_table_aref = [{'TableName' => 'trial', 'FieldName' => 'ProjectId'}];

      ($chk_id_err, $chk_id_msg,
       $used_id_href, $not_used_id_href) = id_existence_bulk($dbh, $chk_table_aref, $project_id_aref);

      if ($chk_id_err) {

        $self->logger->debug("Check id existence error: $chk_id_msg");
        $err = 1;
        $msg = $chk_id_msg;

        return ($err, $msg, []);
      }
    }

    my $gadmin_status = $self->authen->gadmin_status();

    for my $row (@{$project_data}) {

      if ($gadmin_status eq '1') {

        my $project_id = $row->{'ProjectId'};
        $row->{'update'}   = "update/project/$project_id";

        if ( $not_used_id_href->{$project_id} ) {

          $row->{'delete'}   = "delete/project/$project_id";
        }
      }
      push(@{$extra_attr_project_data}, $row);
    }
  }
  else {

    $extra_attr_project_data = $project_data;
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_project_data);
}

sub list_project_advanced_runmode {

=pod list_project_advanced_HELP_START
{
"OperationName": "List projects",
"Description": "List available projects. This listing requires pagination information.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination NumOfRecords='3' NumOfPages='3' Page='1' NumPerPage='1' /><RecordMeta TagName='Project' /><Project ProjectManagerId='1' ProjectManagerName='Diversity Arrays' ProjectStartDate='0000-00-00 00:00:00' ProjectName='Test2' ProjectNote='' TypeId='11' ProjectStatus='' ProjectEndDate='0000-00-00 00:00:00' ProjectId='3' delete='delete/project/3' update='update/project/3' /></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfRecords' : '3','NumOfPages' : 3,'NumPerPage' : '1','Page' : '1'}],'VCol' : [],'RecordMeta' : [{'TagName' : 'Project'}],'Project' : [{'ProjectManagerId' : '1','ProjectManagerName' : 'Diversity Arrays','ProjectStartDate' : '0000-00-00 00:00:00','ProjectName' : 'Test2','ProjectNote' : '','TypeId' : '11','ProjectStatus' : null,'ProjectEndDate' : '0000-00-00 00:00:00','ProjectId' : '3','delete' : 'delete/project/3','update' : 'update/project/3'}]}",
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

  $self->logger->debug("Filtering: $filtering_csv");

  my $field_list = ['SCol*', 'VCol*', 'LCol*'];

  my $group_id = $self->authen->group_id();

  my $dbh = connect_kdb_read();

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $field_list, 'project',
                                                                        'ProjectId', '');

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql   .= " LIMIT 1";

  $self->logger->debug("SQL with VCol: $sql");

  my ($sam_project_err, $sam_project_msg, $sam_project_data) = $self->list_project(0, $sql);

  if ($sam_project_err) {

    $self->logger->debug($sam_project_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $sample_data_aref = $sam_project_data;

  my @field_list_all;

  if (scalar(@{$sample_data_aref}) == 1) {

    @field_list_all = keys(%{$sample_data_aref->[0]});
  }
  else {

    $self->logger->debug("It reaches here");
    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'project');

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

  if (length($field_list_csv) > 0) {

    my ($sel_field_err, $sel_field_msg, $sel_field_list) = parse_selected_field($field_list_csv,
                                                                                $final_field_list,
                                                                                'ProjectId');

    if ($sel_field_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;

    if ($filtering_csv =~ /ProjectManagerId/) {

      push(@{$final_field_list}, 'ProejectManagerId');
    }
  }

  my $field_lookup = {};
  for my $fd_name (@{$final_field_list}) {

    $field_lookup->{$fd_name} = 1;
  }

  my $other_join = '';
  if ($field_lookup->{'ProjectManagerId'}) {

    push(@{$final_field_list}, "CONCAT(contact.ContactFirstName, ' ', contact.ContactLastName) AS ProjectManagerName ");
    $other_join   .= ' LEFT JOIN contact ON project.ProjectManagerId = contact.ContactId ';
  }

  my $factor_filtering_flag = test_filtering_factor($filtering_csv);

  if (!$factor_filtering_flag) {

    ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $final_field_list, 'project',
                                                                       'ProjectId', $other_join);
  }
  else {

    ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql_v2($dbh, $final_field_list, 'project',
                                                                          'ProjectId', $other_join);
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
      $nb_filter_factor) = parse_filtering_v2('ProjectId',
                                              'project',
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

  my $filtering_exp = " $filter_where_phrase ";

  if (length($having_phrase) > 0) {

    $sql =~ s/FACTORHAVING/ HAVING $having_phrase/;

    $sql .= " $filtering_exp ";
  }
  else {

    $sql =~ s/GROUP BY/ $filtering_exp GROUP BY /;
  }

  my $pagination_aref    = [];
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
                                                                  'project',
                                                                  'ProjectId',
                                                                  $filtering_exp,
                                                                  $where_arg);
    }
    else {

      $self->logger->debug("COUNT NB RECORD: FACTOR IN FILTERING");

      my $count_sql = "SELECT COUNT(project.ProjectId) ";
      $count_sql   .= "FROM project INNER JOIN ";
      $count_sql   .= " (SELECT ProjectId, COUNT(ProjectId) ";
      $count_sql   .= " FROM projectfactor WHERE $count_filter_phrase ";
      $count_sql   .= " GROUP BY ProjectId HAVING COUNT(ProjectId)=$nb_filter_factor) AS subq ";
      $count_sql   .= "ON project.ProjectId = subq.ProjectId ";
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

    $sql .= ' ORDER BY project.ProjectId DESC';
  }

  $sql .= " $paged_limit_clause ";

  $self->logger->debug("SQL with VCol: $sql");

  $self->logger->debug('Where arg: ' . join(',', @{$where_arg}));

  # where_arg here in the list function because of the filtering
  my ($read_project_err, $read_project_msg, $project_data) = $self->list_project(1, $sql, $where_arg);

  if ($read_project_err) {

    $self->logger->debug($read_project_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'} = 0;
  $data_for_postrun_href->{'Data'}  = {'Project'    => $project_data,
                                       'VCol'       => $vcol_list,
                                       'Pagination' => $pagination_aref,
                                       'RecordMeta' => [{'TagName' => 'Project'}],
  };

  return $data_for_postrun_href;
}

sub get_project_runmode {

=pod get_project_HELP_START
{
"OperationName": "Get project",
"Description": "Get detailed information about the project specified by project id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='Project' /><Project ProjectManagerId='1' ProjectManagerName='Diversity Arrays' ProjectStartDate='0000-00-00 00:00:00' ProjectName='Test123' ProjectNote='' ProjectEndDate='0000-00-00 00:00:00' ProjectStatus='' TypeId='11' ProjectId='2' delete='delete/project/2' update='update/project/2' /></DATA>",
"SuccessMessageJSON": "{'VCol' : [],'RecordMeta' : [{'TagName' : 'Project'}],'Project' : [{'ProjectManagerId' : '1','ProjectManagerName' : 'Diversity Arrays','ProjectStartDate' : '0000-00-00 00:00:00','ProjectName' : 'Test123','ProjectNote' : '','TypeId' : '11','ProjectStatus' : null,'ProjectEndDate' : '0000-00-00 00:00:00','ProjectId' : '2','delete' : 'delete/project/2','update' : 'update/project/2'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='ProjectId (5) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'ProjectId (5) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing ProjectId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $project_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $group_id = $self->authen->group_id();

  my $dbh = connect_kdb_read();

  if (!record_existence($dbh, 'project', 'ProjectId', $project_id)) {

    my $err_msg = "ProjectId ($project_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $field_list = ['project.*', 'VCol*',
                    "CONCAT(contact.ContactFirstName, concat(' ', contact.ContactLastName)) As ProjectManagerName"
                   ];

  my $other_join = ' LEFT JOIN contact ON project.ProjectManagerId = contact.ContactId ';

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $field_list, 'project',
                                                                        'ProjectId', $other_join);
  $dbh->disconnect();

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $where_exp = ' WHERE project.ProjectId=? ';

  $sql =~ s/GROUP BY/ $where_exp GROUP BY /;

  $sql   .= ' ORDER BY project.ProjectId DESC';

  $self->logger->debug("SQL with VCol: $sql");

  my ($read_project_err, $read_project_msg, $project_data) = $self->list_project(1, $sql, [$project_id]);

  if ($read_project_err) {

    $self->logger->debug($read_project_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'} = 0;
  $data_for_postrun_href->{'Data'}  = {'Project'      => $project_data,
                                       'VCol'         => $vcol_list,
                                       'RecordMeta'   => [{'TagName' => 'Project'}],
  };

  return $data_for_postrun_href;
}

sub del_project_runmode {

=pod del_project_gadmin_HELP_START
{
"OperationName": "Delete project",
"Description": "Delete project from the system specified by id. Project can be deleted only if not attached to any lower level related record.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Project (2) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Project (3) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='ProjectId (1) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'ProjectId (1) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing ProjectId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $project_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_k_read = connect_kdb_read();

  my $project_exist = record_existence($dbh_k_read, 'project', 'ProjectId', $project_id);

  if (!$project_exist) {

    my $err_msg = "ProjectId ($project_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $project_used = record_existence($dbh_k_read, 'trial', 'ProjectId', $project_id);

  if ($project_used) {

    my $err_msg = "Project ($project_id) is used in trial.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $sql = 'DELETE FROM projectfactor WHERE ProjectId=?';
  my $sth = $dbh_k_write->prepare($sql);

  $sth->execute($project_id);

  if ($dbh_k_write->err()) {

    $self->logger->debug("Delete projectfactor failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $sql = 'DELETE FROM project WHERE ProjectId=?';
  $sth = $dbh_k_write->prepare($sql);

  $sth->execute($project_id);

  if ($dbh_k_write->err()) {

    $self->logger->debug("Delete project failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref = [{'Message' => "Project ($project_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub get_trial_unit_specimen_runmode {

=pod get_trial_unit_specimen_HELP_START
{
"OperationName": "Get trial unit specimen",
"Description": "Get detailed information about association between trial unit and specimen specified by trialunitspecimen id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='TrialUnitSpecimen' /><TrialUnitSpecimen ItemBarcode='' SpecimenName='Specimen4TrialUnit_8074320' Notes='none' ItemId='' TrialUnitId='2' TrialUnitSpecimenId='7' HarvestDate='0000-00-00' UltimatePermission='' PlantDate='2011-09-01' HasDied='0' SpecimenId='6' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'TrialUnitSpecimen'}],'TrialUnitSpecimen' : [{'SpecimenName' : 'Specimen4TrialUnit_8074320','ItemBarcode' : null,'Notes' : 'none','ItemId' : null,'TrialUnitId' : '2','TrialUnitSpecimenId' : '7','HarvestDate' : '0000-00-00','UltimatePermission' : null,'PlantDate' : '2011-09-01','HasDied' : '0','SpecimenId' : '6'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TrialUnitSpecimenId (3) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'TrialUnitSpecimenId (3) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialUnitSpecimenId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = $_[0];
  my $tu_spec_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  my $tu_spec_sql = "SELECT DISTINCT trialunit.TrialId ";
  $tu_spec_sql   .= "FROM trialunitspecimen LEFT JOIN trialunit ";
  $tu_spec_sql   .= "ON trialunitspecimen.TrialUnitId = trialunit.TrialUnitId ";
  $tu_spec_sql   .= "WHERE TrialUnitSpecimenId=?";

  my ($r_trial_id_err, $trial_id) = read_cell($dbh, $tu_spec_sql, [$tu_spec_id]);

  if ($r_trial_id_err) {

    $self->logger->debug("Read trial id failed");
    my $err_msg = "Unexpected Error. $tu_spec_sql";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($trial_id) == 0) {

    my $err_msg = "TrialUnitSpecimenId ($tu_spec_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'trial');

  my $sql      = "SELECT $perm_str AS UltimatePermission ";
  $sql        .= 'FROM trial ';
  $sql        .= 'WHERE TrialId=?';

  my ($read_err, $permission) = read_cell($dbh, $sql, [$trial_id]);
  $dbh->disconnect();

  if ( ($permission & $READ_PERM) != $READ_PERM ) {

    my $err_msg = "Trial ($trial_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql = 'SELECT trialunitspecimen.*, specimen.SpecimenName, specimen.FilialGeneration, specimen.Pedigree, specimen.SelectionHistory, item.ItemBarcode, breedingmethod.BreedingMethodId, breedingmethod.BreedingMethodName ';
  $sql .= 'FROM trialunitspecimen LEFT JOIN specimen ON trialunitspecimen.SpecimenId = specimen.SpecimenId ';
  $sql .= 'LEFT JOIN breedingmethod ON specimen.BreedingMethodId = breedingmethod.BreedingMethodId ';
  $sql .= 'LEFT JOIN item on trialunitspecimen.ItemId = item.ItemId ';
  $sql .= 'WHERE trialunitspecimen.TrialUnitSpecimenId= ? ';

  my ($read_tus_err, $read_tus_msg, $tus_data) = $self->list_trial_unit_specimen(1, $sql, [$tu_spec_id]);

  if ($read_tus_err) {

    $self->logger->debug($read_tus_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.' }]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'} = 0;
  $data_for_postrun_href->{'Data'}  = {'TrialUnitSpecimen'  => $tus_data,
                                       'RecordMeta'         => [{'TagName' => 'TrialUnitSpecimen'}],
  };

  return $data_for_postrun_href;
}

sub add_trial_dimension_runmode {

=pod add_trial_dimension_HELP_START
{
"OperationName": "Add dimension to trial",
"Description": "Attach a dimension to the trial definition specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "trialdimension",
"SkippedField": ["TrialId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='4' ParaName='TrialDimensionId' /><Info Message='Dimension (Y) has been added to Trial (5) successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '5', 'ParaName' : 'TrialDimensionId'}], 'Info' : [{'Message' : 'Dimension (Y) has been added to Trial (6) successfully.'}]}",
"ErrorMessageXML": [{"NameAlreadyExists": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Dimension='Dimension (Y): already exists.' /></DATA>"}],
"ErrorMessageJSON": [{"NameAlreadyExists": "{'Error' : [{'Dimension' : 'Dimension (Y): already exists.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $trial_id            = $self->param('id');

  my $dimension           = $query->param('Dimension');
  my $dimension_name      = $query->param('DimensionName');

  my ($missing_err, $missing_href) = check_missing_href( {'Dimension'         => $dimension,
                                                          'DimensionName'     => $dimension_name,
                                                         } );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $dbh_k_write = connect_kdb_write();

  my $trial_existence = record_existence($dbh_k_write, 'trial', 'TrialId', $trial_id);

  if (!$trial_existence) {

    my $err_msg = "Trial ($trial_id) does not exist.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TrialId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($is_trial_ok, $trouble_trial_id_aref) = check_permission($dbh_k_write, 'trial', 'TrialId',
                                                               [$trial_id], $group_id, $gadmin_status,
                                                               $READ_WRITE_PERM);

  if (!$is_trial_ok) {

    my $trouble_trial_id = $trouble_trial_id_aref->[0];

    my $err_msg = "Permission denied: Group ($group_id) and Trial ($trouble_trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TrialId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $acceptable_dimension_lookup = {'X'        => 1,
                                     'Y'        => 1,
                                     'Z'        => 1,
                                     'EntryId'  => 1,
                                     'Position' => 1
                                     };

  if ( !(defined $acceptable_dimension_lookup->{$dimension}) ) {

    my $err_msg = "Dimension ($dimension): invalid.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Dimension' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT TrialDimensionId FROM trialdimension WHERE TrialId=? AND Dimension=?';

  my $exist_dimension_id = read_cell($dbh_k_write, $sql, [$trial_id, $dimension]);

  if (length($exist_dimension_id) > 0) {

    my $err_msg = "Dimension ($dimension): already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Dimension' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql = 'SELECT TrialDimensionId FROM trialdimension WHERE TrialId=? AND DimensionName=?';

  $exist_dimension_id = read_cell($dbh_k_write, $sql, [$trial_id, $dimension_name]);

  if (length($exist_dimension_id) > 0) {

    my $err_msg = "DimensionName ($dimension_name): already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'DimensionName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql    = 'INSERT INTO trialdimension SET ';
  $sql   .= 'TrialId=?, ';
  $sql   .= 'Dimension=?, ';
  $sql   .= 'DimensionName=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($trial_id, $dimension, $dimension_name);

  if ($dbh_k_write->err()) {

    $self->logger->debug("SQL Error:" . $dbh_k_write->errstr());
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  my $trial_dimension_id = $dbh_k_write->last_insert_id(undef, undef, 'trialdimension', 'TrialDimensionId');

  $dbh_k_write->disconnect();

  my $info_msg_aref  = [{'Message' => "Dimension ($dimension) has been added to Trial ($trial_id) successfully."}];
  my $return_id_aref = [{'Value' => "$trial_dimension_id", 'ParaName' => 'TrialDimensionId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_trial_dimension_runmode {

=pod update_trial_dimension_HELP_START
{
"OperationName": "Update trial dimension",
"Description": "Update trial dimension association for specified trial id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "trialdimension",
"SkippedField": ["TrialId", "Dimension"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='TrialDimensions (6) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'TrialDimensions (6) has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TrialDimensionId (7): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'TrialDimensionId (7): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialDimensionId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self               = shift;
  my $trial_dimension_id = $self->param('id');
  my $query              = $self->query();

  my $data_for_postrun_href = {};

  my $dimension_name   = $query->param('DimensionName');

  my ($missing_err, $missing_href) = check_missing_href( { 'DimensionName' => $dimension_name } );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  my $dbh_read = connect_kdb_read();

  my $trial_id = read_cell_value($dbh_read, 'trialdimension', 'TrialId', 'TrialDimensionId', $trial_dimension_id);

  if ( length($trial_id) == 0 ) {

    my $err_msg = "TrialDimensionId ($trial_dimension_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str      = permission_phrase($group_id, 0, $gadmin_status);

  my $sql  = "SELECT $perm_str AS UltimatePermission ";
  $sql    .= 'FROM trial ';
  $sql    .= 'WHERE TrialId=?';

  my ($read_err, $trial_permission) = read_cell($dbh_read, $sql, [$trial_id]);

  if ($read_err) {

    my $err_msg = "Unexpected Error";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( ($trial_permission & $READ_WRITE_PERM) != $READ_WRITE_PERM ) {

    my $err_msg = "Trial ($trial_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql = 'SELECT TrialDimensionId FROM trialdimension WHERE TrialId=? AND DimensionName=? AND TrialDimensionId<>?';

  my ($r_d_name_err, $db_trial_dimension_id) = read_cell($dbh_read, $sql, [$trial_id, $dimension_name, $trial_dimension_id]);

  if ($r_d_name_err) {

    my $err_msg = "Unexpected Error";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_trial_dimension_id) > 0) {

    my $err_msg = "DimensionName ($dimension_name): already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_read->disconnect();

  my $dbh_write = connect_kdb_write();

  $sql  = 'UPDATE trialdimension SET ';
  $sql .= 'DimensionName=? ';
  $sql .= 'WHERE TrialDimensionId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($dimension_name, $trial_dimension_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "TrialDimension ($trial_dimension_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub del_trial_dimension_runmode {

=pod del_trial_dimension_gadmin_HELP_START
{
"OperationName": "Delete trial dimension",
"Description": "Delete trial dimension for specified trial dimension id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='TrialDimensions (7) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'TrialDimensions (8) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TrialDimensionId (10): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'TrialDimensionId (10): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialDimensionId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self               = shift;
  my $trial_dimension_id = $self->param('id');
  my $query              = $self->query();

  my $data_for_postrun_href = {};

  my $dbh_read = connect_kdb_read();

  my $trial_id = read_cell_value($dbh_read, 'trialdimension', 'TrialId', 'TrialDimensionId', $trial_dimension_id);

  if ( length($trial_id) == 0 ) {

    my $err_msg = "TrialDimensionId ($trial_dimension_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str      = permission_phrase($group_id, 0, $gadmin_status);

  my $sql  = "SELECT $perm_str AS UltimatePermission ";
  $sql    .= 'FROM trial ';
  $sql    .= 'WHERE TrialId=?';

  my ($read_err, $trial_permission) = read_cell($dbh_read, $sql, [$trial_id]);

  if ($read_err) {

    my $err_msg = "Unexpected Error";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( ($trial_permission & $READ_WRITE_PERM) != $READ_WRITE_PERM ) {

    my $err_msg = "Trial ($trial_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dimension = read_cell_value($dbh_read, 'trialdimension', 'Dimension', 'TrialDimensionId', $trial_dimension_id);

  my $trial_unit_dimension_field = "TrialUnit$dimension";

  $sql = "SELECT TrialUnitId FROM trialunit WHERE TrialId=? AND $trial_unit_dimension_field IS NOT NULL LIMIT 1";

  my ($r_tu_err, $db_trial_unit_id) = read_cell($dbh_read, $sql, [$trial_id]);

  if ($r_tu_err) {

    my $err_msg = "Unexpected Error";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_trial_unit_id) > 0) {

    my $err_msg = "Dimension ($dimension): in use.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_read->disconnect();

  my $dbh_write = connect_kdb_write();

  $sql  = 'DELETE FROM trialdimension WHERE TrialDimensionId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($trial_dimension_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "TrialDimension ($trial_dimension_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_trial_dimension {

  my $self           = shift;
  my $extra_attr_yes = shift;
  my $trial_perm     = shift;
  my $where_clause   = qq{};
  $where_clause      = shift;

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

  my $sql = 'SELECT trialdimension.* ';
  $sql   .= 'FROM trialdimension ';
  $sql   .= $where_clause;
  $sql   .= ' ORDER BY Dimension ASC';

  $self->logger->debug("SQL: $sql");

  my ($tdimension_err, $tdimension_msg, $tdimension_data) = read_data($dbh, $sql, \@_);

  if ($tdimension_err) {

    return ($tdimension_err, $tdimension_msg, []);
  }

  my ($perm_tdimension_err, $perm_tdimension_msg, $trial_dimension_data) = read_data($dbh, $sql, \@_);

  if ($perm_tdimension_err) {

    return ($perm_tdimension_err, $perm_tdimension_msg, []);
  }

  my $err = 0;
  my $msg = '';

  my $extra_attr_trial_dimension_data = [];

  my $gadmin_status = $self->authen->gadmin_status();

  if ($extra_attr_yes) {

    for my $row (@{$trial_dimension_data}) {

      if (($trial_perm & $READ_WRITE_PERM) == $READ_WRITE_PERM) {

        my $trial_dimension_id = $row->{'TrialDimensionId'};

        $row->{'update'}        = "update/trialdimension/$trial_dimension_id";

        if ($gadmin_status eq '1') {

          $row->{'delete'}        = "delete/trialdimension/$trial_dimension_id";
        }
      }
      push(@{$extra_attr_trial_dimension_data}, $row);
    }
  }
  else {

    $extra_attr_trial_dimension_data = $trial_dimension_data;
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_trial_dimension_data);
}

sub list_trial_dimension_runmode {

=pod list_trial_dimension_HELP_START
{
"OperationName": "List dimension for trial",
"Description": "List all the dimension attached to the trial specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='TrialDimensions' /><TrialDimensions TrialDimensionId='6' DimensionName='Block' Dimension='Y' delete='delete/trialdimension/6' update='update/trialdimension/6' TrialId='7' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'TrialDimensions'}], 'TrialDimensions' : [{'TrialDimensionId' : '6', 'DimensionName' : 'Block', 'delete' : 'delete/trialdimension/6', 'Dimension' : 'Y', 'update' : 'update/trialdimension/6', 'TrialId' : '7'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error TrialId='Trial (17) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'TrialId' : 'Trial (17) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self    = shift;
  my $trial_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  my $trial_exist = record_existence($dbh, 'trial', 'TrialId', $trial_id);

  if (!$trial_exist) {

    my $err_msg = "Trial ($trial_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TrialId' => $err_msg}]};

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
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TrialId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $perm_str = permission_phrase($group_id, 0, $gadmin_status);
  my $sql = "SELECT $perm_str FROM trial WHERE TrialId=?";

  my ($read_perm_err, $trial_perm) = read_cell($dbh, $sql, [$trial_id]);

  if ($read_perm_err) {

    my $err_msg = "Unexpected Error";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  my $where_clause = 'WHERE TrialId=?';
  my ($trial_dimension_err, $trial_dimension_msg, $trial_dimension_data) = $self->list_trial_dimension(1,
                                                                                                       $trial_perm,
                                                                                                       $where_clause,
                                                                                                       $trial_id);

  if ($trial_dimension_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $trial_dimension_msg}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'TrialDimension' => $trial_dimension_data,
                                           'RecordMeta'     => [{'TagName' => 'TrialDimension'}],
  };

  return $data_for_postrun_href;
}

sub get_trial_dimension_runmode {

=pod get_trial_dimension_HELP_START
{
"OperationName": "Get trial dimension",
"Description": "Get detailed information about trial and dimension association specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='TrialDimensions' /><TrialDimensions TrialDimensionId='6' DimensionName='Block' Dimension='Y' delete='delete/trialdimension/6' update='update/trialdimension/6' TrialId='7' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'TrialDimensions'}], 'TrialDimensions' : [{'TrialDimensionId' : '6', 'DimensionName' : 'Block', 'delete' : 'delete/trialdimension/6', 'Dimension' : 'Y', 'update' : 'update/trialdimension/6', 'TrialId' : '7'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TrialDimensionId (8) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'TrialDimensionId (8) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialDimensionId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self                = shift;
  my $trial_dimension_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $trial_id = read_cell_value($dbh, 'trialdimension', 'TrialId', 'TrialDimensionId', $trial_dimension_id);

  if (length($trial_id) == 0) {

    my $err_msg = "TrialDimensionId ($trial_dimension_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $perm_str = permission_phrase($group_id, 0, $gadmin_status);
  my $sql      = "SELECT $perm_str FROM trial WHERE TrialId=?";

  my ($read_perm_err, $trial_perm) = read_cell($dbh, $sql, [$trial_id]);

  if ($read_perm_err) {

    my $err_msg = "Unexpected Error";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( ($trial_perm & $READ_PERM) != $READ_PERM ) {

    my $err_msg = "Permission denied: Group ($group_id) and trial ($trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  my $where_clause = 'WHERE TrialDimensionId=?';
  my ($trial_dimension_err, $trial_dimension_msg, $trial_dimension_data) = $self->list_trial_dimension(1,
                                                                                                          $trial_perm,
                                                                                                          $where_clause,
                                                                                                          $trial_dimension_id);

  if ($trial_dimension_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $trial_dimension_msg}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'TrialDimension'  => $trial_dimension_data,
                                           'RecordMeta'      => [{'TagName' => 'TrialDimension'}],
  };

  return $data_for_postrun_href;
}

sub add_trial_workflow_runmode {

=pod add_trial_workflow_HELP_START
{
"OperationName": "Add trial workflow step",
"Description": "Record the detailed workflow step.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "trialworkflow",
"SkippedField": ["TrialId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='1' ParaName='TrialWorkflowId' /><Info Message='TrialWorkflow (1) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '2', 'ParaName' : 'TrialWorkflowId'}], 'Info' : [{'Message' : 'TrialWorkflow (2) has been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Trial (21) does not exist.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Trial (21) does not exist.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'TrialId'    => 1,
                    'Completed'  => 1,
                   };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'trialworkflow', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $trial_id            = $self->param('id');

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $dbh_k_write = connect_kdb_write();

  my $trial_existence = record_existence($dbh_k_write, 'trial', 'TrialId', $trial_id);

  if (!$trial_existence) {

    my $err_msg = "Trial ($trial_id) does not exist.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($is_trial_ok, $trouble_trial_id_aref) = check_permission($dbh_k_write, 'trial', 'TrialId',
                                                               [$trial_id], $group_id, $gadmin_status,
                                                               $READ_WRITE_PERM);

  if (!$is_trial_ok) {

    my $trouble_trial_id = $trouble_trial_id_aref->[0];

    my $err_msg = "Permission denied: Group ($group_id) and Trial ($trouble_trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $workflow_id = read_cell_value($dbh_k_write, 'trial', 'CurrentWorkflowId', 'TrialId', $trial_id);

  if (length($workflow_id) == 0) {

    my $err_msg = "Trial ($trial_id) has no workflow defined.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $workflow_def_id = $query->param('WorkflowdefId');

  my $db_workflow_id = read_cell_value($dbh_k_write, 'workflowdef', 'WorkflowId', 'WorkflowdefId', $workflow_def_id);

  if (length($db_workflow_id) == 0) {

    my $err_msg = "Workflowdef ($workflow_def_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'WorkflowdefId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ("$db_workflow_id" ne "$workflow_id") {

    $self->logger->debug("Trial workflow id: $workflow_id - Def workflow id: $db_workflow_id");

    my $err_msg = "Workflow definition workflow id ($db_workflow_id) mismatches with trial workflow ($workflow_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'WorkflowdefId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $complete_by = undef;
  my $completed   = 0;
  my $reminder_at = undef;
  my $reminder_to = undef;
  my $note        = undef;

  my $chk_date_href = {};

  if (defined $query->param('CompleteBy')) {

    if (length($query->param('CompleteBy')) > 0) {

      $complete_by = $query->param('CompleteBy');

      $chk_date_href->{'CompleteBy'} = $complete_by;
    }
  }

  if (defined $query->param('Completed')) {

    if (length($query->param('Completed')) > 0) {

      $completed = $query->param('Completed');
    }
  }

  if (defined $query->param('ReminderAt')) {

    if (length($query->param('ReminderAt')) > 0) {

      $reminder_at = $query->param('ReminderAt');

      $chk_date_href->{'ReminderAt'} = $reminder_at;
    }
  }

  my $chk_email_href = {};

  if (defined $query->param('ReminderTo')) {

    if (length($query->param('ReminderTo')) > 0) {

      $reminder_to = $query->param('ReminderTo');

      my @email_list = split(',', $reminder_to);

      for (my $i = 0; $i < scalar(@email_list); $i++) {

        $chk_email_href->{"EmailAddress$i"} = $email_list[$i];
      }
    }
  }

  if (defined $query->param('Note')) {

    if (length($query->param('Note')) > 0) {

      $note = $query->param('Note');
    }
  }

  my ($date_err, $date_href) = check_dt_href($chk_date_href);

  if ($date_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$date_href]};

    return $data_for_postrun_href;
  }

  my ($email_err,  $email_href) = check_email_href($chk_email_href);

  if ($email_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$email_href]};

    return $data_for_postrun_href;
  }

  my $sql = 'INSERT INTO trialworkflow SET ';
  $sql   .= 'WorkflowdefId=?, ';
  $sql   .= 'TrialId=?, ';
  $sql   .= 'CompleteBy=?, ';
  $sql   .= 'Completed=?, ';
  $sql   .= 'ReminderAt=?, ';
  $sql   .= 'ReminderTo=?, ';
  $sql   .= 'Note=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($workflow_def_id, $trial_id, $complete_by, $completed, $reminder_at, $reminder_to, $note);

  my $t_wf_id = -1;
  if (!$dbh_k_write->err()) {

    $t_wf_id = $dbh_k_write->last_insert_id(undef, undef, 'trialworkflow', 'TrialWorkflowId');
    $self->logger->debug("TrialWorkflowId: $t_wf_id");
  }
  else {

    my $err_msg = 'Unexpected error';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref  = [{'Message' => "TrialWorkflow ($t_wf_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$t_wf_id", 'ParaName' => 'TrialWorkflowId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_trial_workflow_runmode {

=pod update_trial_workflow_HELP_START
{
"OperationName": "Update trial workflow",
"Description": "Update the detailed workflow step.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "trialworkflow",
"SkippedField": ["TrialId", "WorkflowdefId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='TrialWorkflow (3) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'TrialWorkflow (3) has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TrialWorkflow (4): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'TrialWorkflow (4): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing trial workflow id"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'TrialId'        => 1,
                    'WorkflowdefId'  => 1,
                    'Completed'      => 1,
                   };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'trialworkflow', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $trial_wf_id            = $self->param('id');

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $dbh_k_write = connect_kdb_write();

  my $read_trial_wf_sql   =   'SELECT TrialId, CompleteBy, Completed, ReminderAt, ReminderTo, Note ';
     $read_trial_wf_sql  .=   'FROM trialworkflow WHERE TrialWorkflowId=? ';

  my ($r_df_val_err, $r_df_val_msg, $trial_wf_df_val_data) = read_data($dbh_k_write, $read_trial_wf_sql, [$trial_wf_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve trialworkflow default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $trial_id      = undef;
  my $complete_by   = undef;
  my $completed     = undef;
  my $reminder_at   = undef;
  my $reminder_to   = undef;
  my $note          = undef;

  my $nb_df_val_rec    =  scalar(@{$trial_wf_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve trialworkflow default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $trial_id        = $trial_wf_df_val_data->[0]->{'TrialId'};
  $complete_by     = $trial_wf_df_val_data->[0]->{'CompleteBy'};
  $completed       = $trial_wf_df_val_data->[0]->{'Completed'};
  $reminder_at     = $trial_wf_df_val_data->[0]->{'ReminderAt'};
  $reminder_to     = $trial_wf_df_val_data->[0]->{'ReminderTo'};
  $note            = $trial_wf_df_val_data->[0]->{'Note'};


  if (length($trial_id) == 0) {

    my $err_msg = "TrialWorkflow ($trial_wf_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($is_trial_ok, $trouble_trial_id_aref) = check_permission($dbh_k_write, 'trial', 'TrialId',
                                                               [$trial_id], $group_id, $gadmin_status,
                                                               $READ_WRITE_PERM);

  if (!$is_trial_ok) {

    my $trouble_trial_id = $trouble_trial_id_aref->[0];

    my $err_msg = "Permission denied: Group ($group_id) and Trial ($trouble_trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }


  if (length($complete_by) == 0) {

    $complete_by = undef;
  }


  if (length($reminder_at) == 0) {

    $reminder_at = undef;
  }


  if (length($reminder_to) == 0) {

    $reminder_to = undef;
  }


  if (length($note) == 0) {

    $note = undef;
  }

  my $chk_date_href = {};

  if (defined $query->param('CompleteBy')) {

    if (length($query->param('CompleteBy')) > 0) {

      $complete_by = $query->param('CompleteBy');

      $chk_date_href->{'CompleteBy'} = $complete_by;
    }
  }

  if (defined $query->param('Completed')) {

    if (length($query->param('Completed')) > 0) {

      $completed = $query->param('Completed');
    }
  }

  if (defined $query->param('ReminderAt')) {

    if (length($query->param('ReminderAt')) > 0) {

      $reminder_at = $query->param('ReminderAt');

      $chk_date_href->{'ReminderAt'} = $reminder_at;
    }
  }

  my $chk_email_href = {};

  if (defined $query->param('ReminderTo')) {

    if (length($query->param('ReminderTo')) > 0) {

      $reminder_to = $query->param('ReminderTo');

      my @email_list = split(',', $reminder_to);

      for (my $i = 0; $i < scalar(@email_list); $i++) {

        $chk_email_href->{"EmailAddress$i"} = $email_list[$i];
      }
    }
  }

  if (defined $query->param('Note')) {

    if (length($query->param('Note')) > 0) {

      $note = $query->param('Note');
    }
  }

  my ($date_err, $date_href) = check_dt_href($chk_date_href);

  if ($date_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$date_href]};

    return $data_for_postrun_href;
  }

  my ($email_err,  $email_href) = check_email_href($chk_email_href);

  if ($email_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$email_href]};

    return $data_for_postrun_href;
  }

  my $sql = 'UPDATE trialworkflow SET ';
  $sql   .= 'CompleteBy=?, ';
  $sql   .= 'Completed=?, ';
  $sql   .= 'ReminderAt=?, ';
  $sql   .= 'ReminderTo=?, ';
  $sql   .= 'Note=? ';
  $sql   .= 'WHERE TrialWorkflowId=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($complete_by, $completed, $reminder_at, $reminder_to, $note, $trial_wf_id);

  if ($dbh_k_write->err()) {

    my $err_msg = 'Unexpected error';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref  = [{'Message' => "TrialWorkflow ($trial_wf_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_trial_workflow {

  my $self           = $_[0];
  my $extra_attr_yes = $_[1];
  my $trial_perm     = $_[2];
  my $sql            = $_[3];

  my $where_para_aref = [];

  if (defined $_[4]) {

    $where_para_aref = $_[4];
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

  my $err = 0;
  my $msg = '';

  my $data_aref = [];

  my $dbh = connect_kdb_read();

  ($err, $msg, $data_aref) = read_data($dbh, $sql, $where_para_aref);

  if ($err) {

    return ($err, $msg, []);
  }

  my $gadmin_status = $self->authen->gadmin_status();

  my $extra_attr_t_wf_data = [];


  if ($extra_attr_yes) {

    for my $t_wf_row (@{$data_aref}) {

      my $t_wf_id = $t_wf_row->{'TrialWorkflowId'};

      if ( ($trial_perm & $WRITE_PERM) == $WRITE_PERM ) {

        $t_wf_row->{'update'} = "update/trialworkflow/$t_wf_id";

        if ($gadmin_status eq '1') {

          $t_wf_row->{'delete'} = "delete/trialworkflow/$t_wf_id";
        }
      }

      push(@{$extra_attr_t_wf_data}, $t_wf_row);
    }
  }
  else {

    $extra_attr_t_wf_data = $data_aref;
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_t_wf_data);
}

sub list_trial_workflow_runmode {

=pod list_trial_workflow_HELP_START
{
"OperationName": "List trial workflow",
"Description": "List recorded workflow steps for a trial specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='TrialWorkflow' /><TrialWorkflow TrialWorkflowId='3' Completed='1' ReminderTo='dart-it@kddart.org' WorkflowdefId='11' Note='Automatic testing framework - update' StepName='Step_0014415' StepNote='Testing framework' CompleteBy='' ReminderAt='' delete='delete/trialworkflow/3' update='update/trialworkflow/3' TrialId='13' StepOrder='0' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'TrialWorkflow'}], 'TrialWorkflow' : [{'Completed' : '1', 'TrialWorkflowId' : '3', 'ReminderTo' : 'dart-it@kddart.org', 'StepNote' : 'Testing framework', 'StepName' : 'Step_0014415', 'Note' : 'Automatic testing framework - update', 'WorkflowdefId' : '11', 'CompleteBy' : null, 'ReminderAt' : null, 'delete' : 'delete/trialworkflow/3', 'update' : 'update/trialworkflow/3', 'StepOrder' : '0', 'TrialId' : '13'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing trial id"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self      = shift;
  my $trial_id  = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  if (!record_existence($dbh, 'trial', 'TrialId', $trial_id)) {

    my $err_msg = "Trial ($trial_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str      = permission_phrase($group_id, 0, $gadmin_status, 'trial');

  my $sql      = "SELECT $perm_str AS UltimatePermission ";
  $sql        .= 'FROM trial ';
  $sql        .= 'WHERE TrialId=?';

  my ($read_err, $trial_permission) = read_cell($dbh, $sql, [$trial_id]);
  $dbh->disconnect();

  if ($read_err) {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( ($trial_permission & $READ_PERM) != $READ_PERM ) {

    my $err_msg = "Trial ($trial_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql    = 'SELECT trialworkflow.*, workflowdef.StepName, workflowdef.StepOrder, workflowdef.StepNote ';
  $sql   .= 'FROM trialworkflow ';
  $sql   .= 'LEFT JOIN workflowdef ON trialworkflow.WorkflowdefId = workflowdef.WorkflowdefId ';
  $sql   .= 'WHERE TrialId=? ';
  $sql   .= 'ORDER BY TrialWorkflowId DESC';

  my ($r_t_wf_err, $r_t_wf_msg, $t_wf_data) = $self->list_trial_workflow(1, $trial_permission, $sql, [$trial_id]);

  if ($r_t_wf_err) {

    $self->logger->debug($r_t_wf_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'TrialWorkflow'   => $t_wf_data,
                                           'RecordMeta'      => [{'TagName' => 'TrialWorkflow'}],
  };

  return $data_for_postrun_href;
}

sub get_trial_workflow_runmode {

=pod get_trial_workflow_HELP_START
{
"OperationName": "Get trial workflow",
"Description": "Get recorded trial workflow details specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='TrialWorkflow' /><TrialWorkflow TrialWorkflowId='3' Completed='1' ReminderTo='dart-it@kddart.org' WorkflowdefId='11' Note='Automatic testing framework - update' StepName='Step_0014415' StepNote='Testing framework' CompleteBy='' ReminderAt='' delete='delete/trialworkflow/3' update='update/trialworkflow/3' TrialId='13' StepOrder='0' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'TrialWorkflow'}], 'TrialWorkflow' : [{'Completed' : '1', 'TrialWorkflowId' : '3', 'ReminderTo' : 'dart-it@kddart.org', 'StepNote' : 'Testing framework', 'StepName' : 'Step_0014415', 'Note' : 'Automatic testing framework - update', 'WorkflowdefId' : '11', 'CompleteBy' : null, 'ReminderAt' : null, 'delete' : 'delete/trialworkflow/3', 'update' : 'update/trialworkflow/3', 'StepOrder' : '0', 'TrialId' : '13'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing trialworkflow id"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self      = shift;
  my $t_wf_id   = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  my $trial_id = read_cell_value($dbh, 'trialworkflow', 'TrialId', 'TrialWorkflowId', $t_wf_id);

  if (length($trial_id) == 0) {

    my $err_msg = "TrialWorkflow ($t_wf_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str      = permission_phrase($group_id, 0, $gadmin_status, 'trial');

  my $sql      = "SELECT $perm_str AS UltimatePermission ";
  $sql        .= 'FROM trial ';
  $sql        .= 'WHERE TrialId=?';

  my ($read_err, $trial_permission) = read_cell($dbh, $sql, [$trial_id]);
  $dbh->disconnect();

  if ($read_err) {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( ($trial_permission & $READ_PERM) != $READ_PERM ) {

    my $err_msg = "Trial ($trial_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql    = 'SELECT trialworkflow.*, workflowdef.StepName, workflowdef.StepOrder, workflowdef.StepNote ';
  $sql   .= 'FROM trialworkflow ';
  $sql   .= 'LEFT JOIN workflowdef ON trialworkflow.WorkflowdefId = workflowdef.WorkflowdefId ';
  $sql   .= 'WHERE TrialWorkflowId=? ';
  $sql   .= 'ORDER BY TrialWorkflowId DESC';

  my ($r_t_wf_err, $r_t_wf_msg, $t_wf_data) = $self->list_trial_workflow(1, $trial_permission, $sql, [$t_wf_id]);

  if ($r_t_wf_err) {

    $self->logger->debug($r_t_wf_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'TrialWorkflow'   => $t_wf_data,
                                           'RecordMeta'      => [{'TagName' => 'TrialWorkflow'}],
  };

  return $data_for_postrun_href;
}

sub del_trial_workflow_runmode {

=pod del_trial_workflow_gadmin_HELP_START
{
"OperationName": "Delete trial workflow",
"Description": "Delete trial workflow for specified trial workflow id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='TrialWorkflows (4) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'TrialWorkflows (5) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TrialWorkflowId (9): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'TrialWorkflowId (9): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing trial workflow id"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self               = shift;
  my $trial_workflow_id  = $self->param('id');
  my $query              = $self->query();

  my $data_for_postrun_href = {};

  my $dbh_read = connect_kdb_read();

  my $trial_id = read_cell_value($dbh_read, 'trialworkflow', 'TrialId', 'TrialWorkflowId', $trial_workflow_id);

  if ( length($trial_id) == 0 ) {

    my $err_msg = "TrialWorkflowId ($trial_workflow_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str      = permission_phrase($group_id, 0, $gadmin_status);

  my $sql  = "SELECT $perm_str AS UltimatePermission ";
  $sql    .= 'FROM trial ';
  $sql    .= 'WHERE TrialId=?';

  my ($read_err, $trial_permission) = read_cell($dbh_read, $sql, [$trial_id]);

  if ($read_err) {

    my $err_msg = "Unexpected Error";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( ($trial_permission & $READ_WRITE_PERM) != $READ_WRITE_PERM ) {

    my $err_msg = "Trial ($trial_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_read->disconnect();

  my $dbh_write = connect_kdb_write();

  $sql  = 'DELETE FROM trialworkflow WHERE TrialWorkflowId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($trial_workflow_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "TrialWorkflows ($trial_workflow_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub add_trialgroup_runmode {

=pod add_trialgroup_HELP_START
{
"OperationName": "Group existing trials together",
"Description": "Group existing trials together. This grouping could be multi environment trials.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "trialgroup",
"SkippedField": ["TrialGroupOwner"],
"KDDArTFactorTable": "trialgroupfactor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='1' ParaName='TrialGroupId' /><Info Message='TrialGroup (1) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '2', 'ParaName' : 'TrialGroupId'}], 'Info' : [{'Message' : 'TrialGroup (2) has been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error TrialGroupType='TrialGroupType (25): not found or inactive.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'TrialGroupType' : 'TrialGroupType (25): not found or inactive.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "XML",
"UploadFileParameterName": "uploadfile",
"DTDFileNameForUploadXML": "trialgroupentry.dtd",
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = $_[0];
  my $query = $self->query();

  my $data_for_postrun_href = {};
  my $trial_group_err_aref = [];
  my $trial_group_err = 0;

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'TrialGroupOwner' => 1};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'trialgroup', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $t_grp_name = $query->param('TrialGroupName');
  my $t_grp_type = $query->param('TrialGroupType');

  my $t_grp_start  = undef;
  my $t_grp_end    = undef;
  my $t_grp_note   = undef;
  my $t_grp_layout = undef;

  my $chk_date_href = {};

  if (defined $query->param('TrialGroupStart')) {

    if (length($query->param('TrialGroupStart')) > 0) {

      $t_grp_start = $query->param('TrialGroupStart');
      $chk_date_href->{'TrialGroupStart'} = $t_grp_start;
    }
  }

  if (defined $query->param('TrialGroupEnd')) {

    if (length($query->param('TrialGroupEnd')) > 0) {

      $t_grp_end = $query->param('TrialGroupEnd');
      $chk_date_href->{'TrialGroupEnd'} = $t_grp_end;
    }
  }

  if (defined $query->param('TrialGroupNote')) {

    if (length($query->param('TrialGroupNote')) > 0) {

      $t_grp_note = $query->param('TrialGroupNote');
    }
  }

  if (defined $query->param('TrialGroupLayout')) {

    if (length($query->param('TrialGroupLayout')) > 0) {

      $t_grp_layout = $query->param('TrialGroupLayout');
    }
  }

  my ($date_err, $date_href) = check_dt_href($chk_date_href);

  if ($date_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$date_href]};

    return $data_for_postrun_href;
  }

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength, FactorValidRuleErrMsg, FactorValidRule  ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='trialgroupfactor'";

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

  if (record_existence($dbh_k_read, 'trialgroup', 'TrialGroupName', $t_grp_name)) {

    my $err_msg = "TrialGroupName ($t_grp_name): already exists.";

    push(@{$trial_group_err_aref}, {'TrialGroupName' => $err_msg});
    $trial_group_err = 1;
  }


  if (!type_existence($dbh_k_read, 'trialgroup', $t_grp_type)) {

    my $err_msg = "TrialGroupType ($t_grp_type): not found or inactive.";
    
    push(@{$trial_group_err_aref}, {'TrialGroupType' => $err_msg});
    $trial_group_err = 1;
  }

  my $entry_xml_file           = $self->authen->get_upload_file();
  my $trialgroupentry_dtd_file = $self->get_trialgroupentry_dtd_file();

  $self->logger->debug("Trialgroupentry DTD: $trialgroupentry_dtd_file");

  add_dtd($trialgroupentry_dtd_file, $entry_xml_file);

  my $trialgroup_xml = read_file($entry_xml_file);

  $self->logger->debug("XML file with DTD: $trialgroup_xml");

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
    my $user_err_msg = "trialgroupentry xml file does not comply with its definition.\n";
    $user_err_msg   .= "Details: $err_msg";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $user_err_msg}]};

    return $data_for_postrun_href;
  }

  my $trial_entry_aref = xml2arrayref($trialgroup_xml, 'trialgroupentry');

  my $trial_id_aref      = [];
  my $uniq_trial_id_href = {};

  my $trial_id_duplicate_string = "";
  my $trial_id_notfound_string = "";
  my $trial_id_permission_string = "";

  my $trialgroup_error_msg = "";

  for my $trial_entry_info (@{$trial_entry_aref}) {

    my $trial_id = $trial_entry_info->{'TrialId'};

    if (defined $uniq_trial_id_href->{$trial_id}) {

      $trial_id_duplicate_string .= "$trial_id, ";
      $trial_group_err = 1;
    }
    else {

      $uniq_trial_id_href->{$trial_id} = 1;
    }

    push(@{$trial_id_aref}, $trial_id);
  }

  my ($trial_err, $trial_msg,
      $unfound_trial_aref, $found_trial_aref) = record_existence_bulk($dbh_k_read, 'trial',
                                                                      'TrialId', $trial_id_aref);

  if ($trial_err) {

    $self->logger->debug("Check recorod existence bulk failed: $trial_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$unfound_trial_aref}) > 0) {

    my $unfound_trial_csv = join(',', @{$unfound_trial_aref});

    $trial_id_notfound_string .= "$unfound_trial_csv";
    $trial_group_err = 1;
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_trial_ok, $trouble_trial_id_aref) = check_permission($dbh_k_read, 'trial', 'TrialId',
                                                               $trial_id_aref, $group_id, $gadmin_status,
                                                               $READ_LINK_PERM);

  if (!$is_trial_ok) {

    my $trouble_trial_id = join(',', @{$trouble_trial_id_aref});

    $trial_id_permission_string .= "$trouble_trial_id";
    $trial_group_err = 1;
  }

  $dbh_k_read->disconnect();

  my ($vcol_error, $vcol_error_aref) = validate_all_factor_input($pre_validate_vcol);

  if ($vcol_error) {
    push(@{$trial_group_err_aref}, @{$vcol_error_aref});
    $trial_group_err = 1;
  }

  if ($trial_group_err) {
    if (length($trial_id_permission_string) > 0) {
      $trialgroup_error_msg .= "Permission denied: $group_id and trials $trial_id_permission_string. ";
    }
    if (length($unfound_trial_aref) > 0) {
      $trialgroup_error_msg .= "Trials $unfound_trial_aref not found. ";
    }
    if (length($unfound_trial_aref) > 0) {
      $trialgroup_error_msg .= "Trials $unfound_trial_aref duplicate in trialgroup entry file. ";
    }

    push(@{$trial_group_err_aref}, {'Message' => $trialgroup_error_msg});

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => $trial_group_err_aref};
    return $data_for_postrun_href;

  }


  my $user_id = $self->authen->user_id();

  my $dbh_k_write = connect_kdb_write();

  $sql    = 'INSERT INTO trialgroup SET ';
  $sql   .= 'TrialGroupName=?, ';
  $sql   .= 'TrialGroupOwner=?, ';
  $sql   .= 'TrialGroupType=?, ';
  $sql   .= 'TrialGroupStart=?, ';
  $sql   .= 'TrialGroupEnd=?, ';
  $sql   .= 'TrialGroupNote=?, ';
  $sql   .= 'TrialGroupLayout=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($t_grp_name, $user_id, $t_grp_type, $t_grp_start, $t_grp_end, $t_grp_note, $t_grp_layout);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  my $t_grp_id = $dbh_k_write->last_insert_id(undef, undef, 'trialgroup', 'TrialGroupId');

  for my $vcol_id (keys(%{$vcol_data})) {

    my $vcol_value = $query->param('VCol_' . "$vcol_id");

    if (length($vcol_value) > 0) {

      $sql  = 'INSERT INTO trialgroupfactor SET ';
      $sql .= 'TrialGroupId=?, ';
      $sql .= 'FactorId=?, ';
      $sql .= 'FactorValue=?';

      my $vcol_sth = $dbh_k_write->prepare($sql);
      $vcol_sth->execute($t_grp_id, $vcol_id, $vcol_value);

      if ($dbh_k_write->err()) {

        $self->logger->debug("Add vcol $vcol_id - $vcol_value : failed");
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

        return $data_for_postrun_href;
      }
      $vcol_sth->finish();
    }
  }

  $sql  = 'INSERT INTO trialgroupentry ';
  $sql .= '(TrialGroupId,TrialId) ';
  $sql .= 'VALUES ';

  my @sql_val_list;

  for my $trial_id (@{$trial_id_aref}) {

    push(@sql_val_list, qq|($t_grp_id, $trial_id)|);
  }

  $sql .= join(',', @sql_val_list);

  $self->logger->debug("MultiLoc entry SQL: $sql");

  $sth = $dbh_k_write->prepare($sql);
  $sth->execute();

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref  = [{'Message' => "TrialGroup ($t_grp_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$t_grp_id", 'ParaName' => 'TrialGroupId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref,
                                           'ReturnId'  => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_trialgroup_runmode {

=pod update_trialgroup_HELP_START
{
"OperationName": "Update trial group meta information",
"Description": "Update detailed information of trial grouping",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "trialgroup",
"SkippedField": ["TrialGroupOwner"],
"KDDArTFactorTable": "trialgroupfactor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='TrialGroup (3) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'TrialGroup (3) has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TrialGroup (13): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'TrialGroup (13): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialGroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = $_[0];
  my $query = $self->query();

  my $data_for_postrun_href = {};
  my $trial_group_err_aref = [];
  my $trial_group_err = 0;

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'TrialGroupOwner' => 1};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'trialgroup', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $dbh_k_read = connect_kdb_read();

  my $t_grp_id = $self->param('id');

  if (!record_existence($dbh_k_read, 'trialgroup', 'TrialGroupId', $t_grp_id)) {

    my $err_msg = "TrialGroup ($t_grp_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trial_id_sql = 'SELECT TrialId FROM trialgroupentry WHERE TrialGroupId=?';

  my ($r_t_id_err, $r_t_id_msg, $trial_id_data) = read_data($dbh_k_read, $trial_id_sql, [$t_grp_id]);

  if ($r_t_id_err) {

    $self->logger->debug("Retrieve trial id failed: $r_t_id_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $trial_id_aref = [];

  for my $trial_rec (@{$trial_id_data}) {

    push(@{$trial_id_aref}, $trial_rec->{'TrialId'});
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_trial_ok, $trouble_trial_id_aref) = check_permission($dbh_k_read, 'trial', 'TrialId',
                                                               $trial_id_aref, $group_id, $gadmin_status,
                                                               $READ_WRITE_PERM);

  if (!$is_trial_ok) {

    my $trouble_trial_id = $trouble_trial_id_aref->[0];

    my $err_msg = "Permission denied: Group ($group_id) and Trial ($trouble_trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $t_grp_name = $query->param('TrialGroupName');
  my $t_grp_type = $query->param('TrialGroupType');

  my $read_t_grp_sql  =  'SELECT TrialGroupStart, TrialGroupEnd, TrialGroupNote, ';
  $read_t_grp_sql    .=  'TrialGroupLayout, TrialGroupOwner ';
  $read_t_grp_sql    .=  'FROM trialgroup WHERE TrialGroupId=? ';

  my ($r_df_val_err, $r_df_val_msg, $t_grp_df_val_data) = read_data($dbh_k_read, $read_t_grp_sql, [$t_grp_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve trialgroup default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $t_grp_start       =  undef;
  my $t_grp_end         =  undef;
  my $t_grp_note        =  undef;
  my $t_grp_owner       =  undef;
  my $t_grp_layout      =  undef;

  my $nb_df_val_rec     =  scalar(@{$t_grp_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve trialgroup default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $t_grp_start       =   $t_grp_df_val_data->[0]->{'TrialGroupStart'};
  $t_grp_end         =   $t_grp_df_val_data->[0]->{'TrialGroupEnd'};
  $t_grp_note        =   $t_grp_df_val_data->[0]->{'TrialGroupNote'};
  $t_grp_owner       =   $t_grp_df_val_data->[0]->{'TrialGroupOwner'};
  $t_grp_layout      =   $t_grp_df_val_data->[0]->{'TrialGroupLayout'};

  if (length($t_grp_start) == 0) {

    $t_grp_start = undef;
  }


  if (length($t_grp_end) == 0) {

    $t_grp_end = undef;
  }

  if (length($t_grp_note) == 0) {

    $t_grp_note = undef;
  }

  if (length($t_grp_layout) == 0) {

    $t_grp_layout = undef;
  }

  my $chk_date_href = {};

  if (defined $query->param('TrialGroupStart')) {

    if (length($query->param('TrialGroupStart')) > 0) {

      $t_grp_start = $query->param('TrialGroupStart');
      $chk_date_href->{'TrialGroupStart'} = $t_grp_start;
    }
    else {

      $t_grp_start = undef;
    }
  }

  if (defined $query->param('TrialGroupEnd')) {

    if (length($query->param('TrialGroupEnd')) > 0) {

      $t_grp_end = $query->param('TrialGroupEnd');
      $chk_date_href->{'TrialGroupEnd'} = $t_grp_end;
    }
    else {

      $t_grp_start = undef;
    }
  }

  if (defined $query->param('TrialGroupNote')) {

    if (length($query->param('TrialGroupNote')) > 0) {

      $t_grp_note = $query->param('TrialGroupNote');
    }
    else {

      $t_grp_note = undef;
    }
  }

  if (defined $query->param('TrialGroupLayout')) {

    if (length($query->param('TrialGroupLayout')) > 0) {

      $t_grp_layout = $query->param('TrialGroupLayout');
    }
    else {

      $t_grp_layout = undef;
    }
  }

  my ($date_err, $date_href) = check_dt_href($chk_date_href);

  if ($date_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$date_href]};

    return $data_for_postrun_href;
  }

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength, FactorValidRuleErrMsg, FactorValidRule  ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='trialgroupfactor'";

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

  $sql = 'SELECT TrialGroupId FROM trialgroup WHERE TrialGroupName=? AND TrialGroupId<>?';

  my ($r_t_grp_id_err, $db_t_grp_id) = read_cell($dbh_k_read, $sql, [$t_grp_name, $t_grp_id]);

  if ($r_t_grp_id_err) {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_t_grp_id) > 0) {

    my $err_msg = "TrialGroupName ($t_grp_name): already exists.";

    push(@{$trial_group_err_aref}, {'TrialGroupName' => $err_msg});
    $trial_group_err = 1;
  }

  if (!type_existence($dbh_k_read, 'trialgroup', $t_grp_type)) {

    my $err_msg = "TrialGroupType ($t_grp_type): not found or inactive.";

    push(@{$trial_group_err_aref}, {'TrialGroupType' => $err_msg});
    $trial_group_err = 1;
  }

  my $user_id = $self->authen->user_id();

  if ("$t_grp_owner" ne "$user_id") {

    my $err_msg = "TrialGroup ($t_grp_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($vcol_error, $vcol_error_aref) = validate_all_factor_input($pre_validate_vcol);

  if ($vcol_error) {
    push(@{$trial_group_err_aref}, @{$vcol_error_aref});
    $trial_group_err = 1;
  }

  if ($trial_group_err) {
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => $trial_group_err_aref};
    return $data_for_postrun_href;
  }


  $sql  = 'UPDATE trialgroup SET ';
  $sql .= 'TrialGroupName=?, ';
  $sql .= 'TrialGroupType=?, ';
  $sql .= 'TrialGroupStart=?, ';
  $sql .= 'TrialGroupEnd=?, ';
  $sql .= 'TrialGroupNote=?, ';
  $sql .= 'TrialGroupLayout=? ';
  $sql .= 'WHERE TrialGroupId=?';

  my $dbh_k_write = connect_kdb_write();

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($t_grp_name, $t_grp_type, $t_grp_start, $t_grp_end, $t_grp_note, $t_grp_layout, $t_grp_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  for my $vcol_id (keys(%{$vcol_data})) {

    if (defined $query->param('VCol_' . "$vcol_id")) {

      my $factor_value = $query->param('VCol_' . "$vcol_id");

      my ($vcol_err, $vcol_msg) = update_factor_value($dbh_k_write, $vcol_id, $factor_value, 'trialgroupfactor', 'TrialGroupId', $t_grp_id);

      if ($vcol_err) {

        $self->logger->debug("VCol_" . "$vcol_id => $vcol_msg" );

        push(@{$trial_group_err_aref}, {'VCol_' . "$vcol_id" => $vcol_msg});

        $trial_group_err = 1;
      }
    }
  }

  $dbh_k_write->disconnect();

  if ($trial_group_err != 0) {
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => $trial_group_err_aref};
    return $data_for_postrun_href;
  }


  my $info_msg_aref = [{'Message' => "TrialGroup ($t_grp_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_trialgroup {

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

      push(@{$t_grp_id_aref}, $row->{'TrialGroupId'});
    }

    if (scalar(@{$t_grp_id_aref}) > 0) {

      my $entry_sql = 'SELECT trialgroupentry.* ';
      $entry_sql   .= 'FROM trialgroupentry ';
      $entry_sql   .= 'WHERE TrialGroupId IN (' . join(',', @{$t_grp_id_aref}) . ')';

      my ($entry_err, $entry_msg, $entry_data) = read_data($dbh, $entry_sql, []);

      if ($entry_err) {

        return ($entry_err, $entry_msg, []);
      }

      for my $row (@{$entry_data}) {

        my $t_grp_id = $row->{'TrialGroupId'};

        if (defined $entry_lookup->{$t_grp_id}) {

          my $entry_aref = $entry_lookup->{$t_grp_id};

          push(@{$entry_aref}, $row);
          $entry_lookup->{$t_grp_id} = $entry_aref;
        }
        else {

          $entry_lookup->{$t_grp_id} = [$row];
        }
      }

      my $chk_table_aref = [{'TableName' => 'trialgroupentry', 'FieldName' => 'TrialGroupId'}];

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

      my $t_grp_id = $row->{'TrialGroupId'};
      my $owner  = $row->{'TrialGroupOwner'};

      if (defined $entry_lookup->{$t_grp_id}) {

        my $entry_aref = [];
        my $entry_data = $entry_lookup->{$t_grp_id};

        for my $entry_info (@{$entry_data}) {

          my $trial_id = $entry_info->{'TrialId'};
          $entry_info->{'removeTrial'} = "trialgroup/${t_grp_id}/remove/trial/$trial_id";

          push(@{$entry_aref}, $entry_info);
        }
        $row->{'trialgroupentry'} = $entry_aref;
      }


      if ("$owner" eq "$user_id") {

        $row->{'update'}   = "update/trialgroup/$t_grp_id";

        if ( $not_used_id_href->{$t_grp_id} ) {

          $row->{'delete'}   = "delete/trialgroup/$t_grp_id";
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

sub list_trialgroup_advanced_runmode {

=pod list_trialgroup_advanced_HELP_START
{
"OperationName": "List trialgroup",
"Description": "Return list of trialgroups. This listing requires pagination definition.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><StatInfo Unit='second' ServerElapsedTime='0.0123678892822266' /><Pagination NumOfRecords='11' Page='1' NumOfPages='6' NumPerPage='2' /><TrialGroup TrialGroupType='436' TrialGroupNote='' TrialGroupName='MultiLocTrialName_77706215649' update='update/trialgroup/11' TrialGroupTypeName='Trial Group Type - 45863861260' TrialGroupId='11' TrialGroupStart='' TrialGroupEnd='' TrialGroupOwner='0'><trialgroupentry TrialId='30' TrialGroupEntryId='25' removeTrial='trialgroup/11/remove/trial/30' TrialGroupId='11' /><trialgroupentry TrialGroupId='11' removeTrial='trialgroup/11/remove/trial/31' TrialGroupEntryId='26' TrialId='31' /></TrialGroup><TrialGroup TrialGroupName='UPDATE TrialGroupName_50034910480' TrialGroupNote='Upated by automatic testing framework' TrialGroupType='428' TrialGroupEnd='' TrialGroupOwner='0' update='update/trialgroup/10' TrialGroupTypeName='Trial Group Type - 87818871818' TrialGroupStart='2015-08-27' TrialGroupId='10'><trialgroupentry TrialGroupEntryId='23' TrialId='28' removeTrial='trialgroup/10/remove/trial/28' TrialGroupId='10' /><trialgroupentry TrialGroupId='10' removeTrial='trialgroup/10/remove/trial/29' TrialId='29' TrialGroupEntryId='24' /></TrialGroup><RecordMeta TagName='TrialGroup' /></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumPerPage' : '2','NumOfPages' : 6,'Page' : '1','NumOfRecords' : '11'}],'TrialGroup' : [{'trialgroupentry' : [{'TrialGroupEntryId' : '25','TrialId' : '30','removeTrial' : 'trialgroup/11/remove/trial/30','TrialGroupId' : '11'},{'TrialGroupId' : '11','removeTrial' : 'trialgroup/11/remove/trial/31','TrialId' : '31','TrialGroupEntryId' : '26'}],'TrialGroupName' : 'MultiLocTrialName_77706215649','TrialGroupNote' : null,'TrialGroupType' : '436','TrialGroupOwner' : '0','TrialGroupEnd' : null,'TrialGroupStart' : null,'TrialGroupId' : '11','update' : 'update/trialgroup/11','TrialGroupTypeName' : 'Trial Group Type - 45863861260'},{'TrialGroupId' : '10','TrialGroupStart' : '2015-08-27','TrialGroupTypeName' : 'Trial Group Type - 87818871818','update' : 'update/trialgroup/10','TrialGroupOwner' : '0','TrialGroupEnd' : null,'trialgroupentry' : [{'TrialGroupId' : '10','TrialGroupEntryId' : '23','TrialId' : '28','removeTrial' : 'trialgroup/10/remove/trial/28'},{'TrialGroupId' : '10','removeTrial' : 'trialgroup/10/remove/trial/29','TrialId' : '29','TrialGroupEntryId' : '24'}],'TrialGroupType' : '428','TrialGroupNote' : 'Upated by automatic testing framework','TrialGroupName' : 'UPDATE TrialGroupName_50034910480'}],'VCol' : [],'RecordMeta' : [{'TagName' : 'TrialGroup'}],'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.011975887802124'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><StatInfo Unit='second' ServerElapsedTime='0.00479598440551757' /><Error Message='TrialGroup (13) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.00476206193542483'}],'Error' : [{'Message' : 'TrialGroup (13) not found.'}]}"}],
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
  my $field_list = ['trialgroup.*', 'VCol*'];

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $field_list, 'trialgroup',
                                                                        'TrialGroupId', '');

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql   .= " LIMIT 1";

  $self->logger->debug("SQL with VCol: $sql");

  my ($sam_t_grp_err, $sam_t_grp_msg, $sam_t_grp_data) = $self->list_trialgroup(0, $sql);

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
    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'trialgroup');

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
                                                                                'TrialGroupId');

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

  if ($field_lookup->{'TrialGroupType'} == 1) {

    $other_join .= ' LEFT JOIN generaltype ON trialgroup.TrialGroupType = generaltype.TypeId ';
    push(@{$final_field_list}, q| generaltype.TypeName AS TrialGroupTypeName |);
  }

  if ($field_lookup->{'TrialGroupOwner'} == 1 ) {

    $other_join .= ' LEFT JOIN systemuser ON trialgroup.TrialGroupOwner = systemuser.UserId ';
    push(@{$final_field_list}, ' systemuser.UserName AS TrialGroupOwnerUserName ');
  }

  ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $final_field_list, 'trialgroup',
                                                                     'TrialGroupId', $other_join);

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("Filtering CSV: $filtering_csv");

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering('TrialGroupId',
                                                                              'trialgroup',
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
                                                                   'trialgroup',
                                                                   'TrialGroupId',
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

    $sql .= ' ORDER BY trialgroup.TrialGroupId DESC';
  }

  $sql .= " $paged_limit_clause ";

  $self->logger->debug("SQL with VCol: $sql");

  my ($read_t_grp_err, $read_t_grp_msg, $t_grp_data) = $self->list_trialgroup(1, $sql, $where_arg);

  if ($read_t_grp_err) {

    $self->logger->debug($read_t_grp_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'TrialGroup'   => $t_grp_data,
                                           'VCol'            => $vcol_list,
                                           'Pagination'      => $pagination_aref,
                                           'RecordMeta'      => [{'TagName' => 'TrialGroup'}],
                                          };

  return $data_for_postrun_href;
}

sub get_trialgroup_runmode {

=pod get_trialgroup_HELP_START
{
"OperationName": "Get trialgroup",
"Description": "Return detailed information about trialgroup specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><StatInfo Unit='second' ServerElapsedTime='0.00580689762878417' /><TrialGroup TrialGroupName='MultiLocTrialName_22953410170' TrialGroupType='472' TrialGroupNote='' TrialGroupEnd='' TrialGroupOwner='0' TrialGroupTypeName='Trial Group Type - 60699072215' update='update/trialgroup/19' TrialGroupId='19' TrialGroupStart=''><trialgroupentry TrialGroupEntryId='41' TrialId='42' removeTrial='trialgroup/19/remove/trial/42' TrialGroupId='19' /><trialgroupentry TrialGroupId='19' TrialGroupEntryId='42' TrialId='43' removeTrial='trialgroup/19/remove/trial/43' /></TrialGroup><RecordMeta TagName='TrialGroup' /></DATA>",
"SuccessMessageJSON": "{'StatInfo' : [{'ServerElapsedTime' : '0.00485303071594238','Unit' : 'second'}],'TrialGroup' : [{'trialgroupentry' : [{'TrialGroupId' : '19','TrialGroupEntryId' : '41','TrialId' : '42','removeTrial' : 'trialgroup/19/remove/trial/42'},{'TrialGroupId' : '19','removeTrial' : 'trialgroup/19/remove/trial/43','TrialGroupEntryId' : '42','TrialId' : '43'}],'TrialGroupNote' : null,'TrialGroupType' : '472','TrialGroupName' : 'MultiLocTrialName_22953410170','TrialGroupId' : '19','TrialGroupStart' : null,'TrialGroupTypeName' : 'Trial Group Type - 60699072215','update' : 'update/trialgroup/19','TrialGroupOwner' : '0','TrialGroupEnd' : null}],'RecordMeta' : [{'TagName' : 'TrialGroup'}],'VCol' : []}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><StatInfo Unit='second' ServerElapsedTime='0.00302692114257808' /><Error Message='TrialGroup (14) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'StatInfo' : [{'ServerElapsedTime' : '0.00553796977233889','Unit' : 'second'}],'Error' : [{'Message' : 'TrialGroup (15) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialGroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self    = shift;
  my $t_grp_id  = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  if (!record_existence($dbh, 'trialgroup', 'TrialGroupId', $t_grp_id)) {

    my $err_msg = "TrialGroup ($t_grp_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $field_list = ['trialgroup.*', 'VCol*', 'generaltype.TypeName AS TrialGroupTypeName'];

  my $other_join = ' LEFT JOIN generaltype ON trialgroup.TrialGroupType = generaltype.TypeId ';

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $field_list, 'trialgroup',
                                                                        'TrialGroupId', $other_join);
  $dbh->disconnect();

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
  }

  $self->logger->debug('Number of vcols: ' . scalar(@{$vcol_list}));

  my $where_clause = " WHERE trialgroup.TrialGroupId=? ";

  $sql =~ s/GROUP BY/ $where_clause GROUP BY /;

  $self->logger->debug("SQL with VCol: $sql");

  my ($read_t_grp_err, $read_t_grp_msg, $t_grp_data) = $self->list_trialgroup(1, $sql, [$t_grp_id]);

  if ($read_t_grp_err) {

    $self->logger->debug($read_t_grp_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'TrialGroup'   => $t_grp_data,
                                           'VCol'            => $vcol_list,
                                           'RecordMeta'      => [{'TagName' => 'TrialGroup'}],
  };

  return $data_for_postrun_href;
}

sub del_trialgroup_runmode {

=pod del_trialgroup_HELP_START
{
"OperationName": "Delete trialgroup",
"Description": "Delete trialgroup grouping specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='TrialGroup (5) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'TrialGroup (6) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TrialGroup (17): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'TrialGroup (17): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialGroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self               = shift;
  my $t_grp_id           = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_read = connect_kdb_read();

  my $owner = read_cell_value($dbh_read, 'trialgroup', 'TrialGroupOwner', 'TrialGroupId', $t_grp_id);

  if ( length($owner) == 0 ) {

    my $err_msg = "TrialGroup ($t_grp_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $user_id = $self->authen->user_id();

  if ("$owner" ne "$user_id") {

    my $err_msg = "TrialGroup ($t_grp_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (record_existence($dbh_read, 'trialgroupentry', 'TrialGroupId', $t_grp_id)) {

    my $err_msg = "TrialGroup ($t_grp_id): trialgroupentry records exist.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_read->disconnect();

  my $dbh_write = connect_kdb_write();

  my $sql  = 'DELETE FROM trialgroup WHERE TrialGroupId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($t_grp_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "TrialGroup ($t_grp_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub add_trial2trialgroup_runmode {

=pod add_trial2trialgroup_HELP_START
{
"OperationName": "Add more trials to a trial group",
"Description": "Add more trials into a trial group specified by id",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Trial (28,29) has been added to TrialGroup (8) successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Trial (28,29) has been added to TrialGroup (9) successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TrialGroup (24): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{ 'Error' : [{ 'Message' : 'TrialGroup (24): not found.'} ]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "XML",
"UploadFileParameterName": "uploadfile",
"DTDFileNameForUploadXML": "trialgroupentry.dtd",
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialGroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self   = $_[0];
  my $t_grp_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_read = connect_kdb_read();

  my $owner = read_cell_value($dbh_read, 'trialgroup', 'TrialGroupOwner', 'TrialGroupId', $t_grp_id);

  if ( length($owner) == 0 ) {

    my $err_msg = "TrialGroup ($t_grp_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $user_id = $self->authen->user_id();

  if ("$owner" ne "$user_id") {

    my $err_msg = "TrialGroup ($t_grp_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $entry_xml_file              = $self->authen->get_upload_file();
  my $trialgroupentry_dtd_file = $self->get_trialgroupentry_dtd_file();

  $self->logger->debug("Trialgroupentry DTD: $trialgroupentry_dtd_file");

  add_dtd($trialgroupentry_dtd_file, $entry_xml_file);

  my $trialgroup_xml = read_file($entry_xml_file);

  $self->logger->debug("XML file with DTD: $trialgroup_xml");

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
    my $user_err_msg = "trialgroupentry xml file does not comply with its definition.\n";
    $user_err_msg   .= "Details: $err_msg";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $user_err_msg}]};

    return $data_for_postrun_href;
  }

  my $trial_entry_aref = xml2arrayref($trialgroup_xml, 'trialgroupentry');

  my $trial_id_aref      = [];
  my $uniq_trial_id_href = {};

  my $sql = '';

  for my $trial_entry_info (@{$trial_entry_aref}) {

    my $trial_id = $trial_entry_info->{'TrialId'};

    $sql = 'SELECT TrialGroupEntryId FROM trialgroupentry WHERE TrialGroupId=? AND TrialId=?';

    my ($r_t_grp_entry_id, $db_t_grp_entry_id) = read_cell($dbh_read, $sql, [$t_grp_id, $trial_id]);

    if (length($db_t_grp_entry_id) > 0) {

      my $err_msg = "Trial ($trial_id): already in TrialGroup ($t_grp_id).";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if (defined $uniq_trial_id_href->{$trial_id}) {

      my $err_msg = "Trial ($trial_id): duplicate.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    else {

      $uniq_trial_id_href->{$trial_id} = 1;
    }

    push(@{$trial_id_aref}, $trial_id);
  }

  my $chk_table_aref = [{'TableName' => 'trial', 'FieldName' => 'TrialId'}];

  my ($chk_id_err, $chk_id_msg,
      $id_exist_href, $id_not_exist_href) = id_existence_bulk($dbh_read, $chk_table_aref, $trial_id_aref);

  if ($chk_id_err) {

    $self->logger->debug("Check id existence error: $chk_id_msg");

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (scalar(keys(%{$id_not_exist_href})) > 0) {

    my $err_msg = "Trial (" . join(',', keys(%{$id_not_exist_href})) . "): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_trial_ok, $trouble_trial_id_aref) = check_permission($dbh_read, 'trial', 'TrialId',
                                                               $trial_id_aref, $group_id, $gadmin_status,
                                                               $READ_LINK_PERM);

  if (!$is_trial_ok) {

    my $trouble_trial_id = $trouble_trial_id_aref->[0];

    my $err_msg = "Permission denied: Group ($group_id) and Trial ($trouble_trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  $sql  = 'INSERT INTO trialgroupentry ';
  $sql .= '(TrialGroupId,TrialId) ';
  $sql .= 'VALUES ';

  my @sql_val_list;

  for my $trial_id (@{$trial_id_aref}) {

    push(@sql_val_list, qq|($t_grp_id, $trial_id)|);
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

  my $info_msg_aref  = [{'Message' => "Trial (" . join(',', @{$trial_id_aref}) . ") has been added to TrialGroup ($t_grp_id) successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub remove_trial_from_trialgroup_runmode {

=pod remove_trial_from_trialgroup_HELP_START
{
"OperationName": "Remove trial from trialgroup",
"Description": "Remove trial specified by id from trialgroup specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Trial (34) has been removed from TrialGroup (12) successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Trial (34) has been removed from TrialGroup (13) successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Trial (34): not part of TrialGroup (13).' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Trial (34): not part of TrialGroup (13).'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing trialgroup id"}, {"ParameterName": "tid", "Description": "Trial id which is part of specified trialgroup"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self               = shift;
  my $t_grp_id             = $self->param('id');
  my $trial_id           = $self->param('tid');

  my $data_for_postrun_href = {};

  my $dbh_read = connect_kdb_read();

  my $owner = read_cell_value($dbh_read, 'trialgroup', 'TrialGroupOwner', 'TrialGroupId', $t_grp_id);

  if ( length($owner) == 0 ) {

    my $err_msg = "TrialGroup ($t_grp_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $user_id = $self->authen->user_id();

  if ("$owner" ne "$user_id") {

    my $err_msg = "TrialGroup ($t_grp_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT TrialGroupEntryId FROM trialgroupentry WHERE TrialGroupId=? AND TrialId=?';

  my ($r_t_grp_entry_err, $t_grp_entry_id) = read_cell($dbh_read, $sql, [$t_grp_id, $trial_id]);

  if ($r_t_grp_entry_err) {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($t_grp_entry_id) == 0) {

    my $err_msg = "Trial ($trial_id): not part of TrialGroup ($t_grp_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_read->disconnect();

  my $dbh_write = connect_kdb_write();

  $sql  = 'DELETE FROM trialgroupentry WHERE TrialGroupEntryId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($t_grp_entry_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "Trial ($trial_id) has been removed from TrialGroup ($t_grp_id) successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub import_trialunitkeyword_csv_runmode {

=pod import_trialunitkeyword_csv_HELP_START
{
"OperationName": "Import trialunit keyword",
"Description": "Import keyword for trialunit(s) from a csv file.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='2 records of trialunitkeyword have been inserted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : '2 records of trialunitkeyword have been inserted successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Row (1): TrialUnit (1) does not exist.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Row (1): TrialUnit (1) does not exist.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "CSV",
"UploadFileParameterName": "uploadfile",
"HTTPParameter": [{"Required": 1, "Name": "TrialUnitId", "Description": "Column number counting from zero for TrialUnitId column in the upload CSV file"}, {"Required": 1, "Name": "KeywordId", "Description": "Column number counting from zero for KeywordId column in the upload CSV file"}],
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
  my $KeywordId_col       = $query->param('KeywordId');

  my $chk_col_href = { 'TrialUnitId'     => $TrialUnitId_col,
                       'KeywordId'       => $KeywordId_col
                     };

  my $matched_col = {};

  $matched_col->{$TrialUnitId_col}     = 'TrialUnitId';
  $matched_col->{$KeywordId_col}       = 'KeywordId';

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

  my $dbh_write = connect_kdb_write();

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str      = permission_phrase($group_id, 0, $gadmin_status);

  if (scalar(@{$data_aref}) == 0) {

    $self->logger->debug("No data provided");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $bulk_sql = 'INSERT INTO trialunitkeyword ';
  $bulk_sql   .= '(TrialUnitId,KeywordId) ';
  $bulk_sql   .= 'VALUES ';

  my $sql;
  my $sth;

  my $uniq_keyword_href = {};

  my $row_counter = 1;
  for my $data_row (@{$data_aref}) {

    my $trialunit_id      = $data_row->{'TrialUnitId'};
    my $keyword_id        = $data_row->{'KeywordId'};

    my ($int_id_err, $int_id_msg) = check_integer_value( { 'TrialUnitId'    => $data_row->{'TrialUnitId'},
                                                           'KeywordId'      => $data_row->{'KeywordId'}
                                                         });

    if ($int_id_err) {

      $int_id_msg = "Row ($row_counter): " . $int_id_msg . ' not integer.';
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $int_id_msg}]};

      return $data_for_postrun_href;
    }

    $sql = 'SELECT TrialId FROM trialunit WHERE TrialUnitId=?';
    $sth = $dbh_write->prepare($sql);
    $sth->execute($trialunit_id);

    my $trial_id = -1;
    $sth->bind_col(1, \$trial_id);
    $sth->fetch();
    $sth->finish();

    if ($trial_id == -1) {

      my $err_msg = "Row ($row_counter): TrialUnit ($trialunit_id) does not exist.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    $sql = 'SELECT KeywordId FROM keyword WHERE KeywordId=?';
    $sth = $dbh_write->prepare($sql);
    $sth->execute($keyword_id);

    my $db_keyword_id = -1;
    $sth->bind_col(1, \$db_keyword_id);
    $sth->fetch();
    $sth->finish();

    if ($db_keyword_id == -1) {

      my $err_msg = "Row ($row_counter): Keyword ($db_keyword_id): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my ($is_trial_perm_ok, $trouble_trial_id_aref) = check_permission($dbh_write, 'trial', 'TrialId',
                                                                      [$trial_id], $group_id, $gadmin_status,
                                                                      $READ_WRITE_PERM);

    if (!$is_trial_perm_ok) {

      my $perm_err_msg = "Row ($row_counter): Permission denied, Group ($group_id) and Trial ($trial_id).";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $perm_err_msg}]};

      return $data_for_postrun_href;
    }

    if (defined $uniq_keyword_href->{"$trialunit_id _ $keyword_id"}) {

      my $err_msg = "Row ($row_counter): TrialUnitId ($trialunit_id) - Keyword ($keyword_id): duplicate.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    else {

      $uniq_keyword_href->{"$trialunit_id _ $keyword_id"} = 1;
    }

    $sql = 'SELECT TrialUnitKeywordId FROM trialunitkeyword WHERE TrialUnitId=? AND KeywordId=?';

    $sth = $dbh_write->prepare($sql);
    $sth->execute($trialunit_id, $keyword_id);

    my $tu_keyword_id = -1;
    $sth->bind_col(1, \$tu_keyword_id);
    $sth->fetch();
    $sth->finish();

    if ($tu_keyword_id != -1) {

      my $err_msg = "Row ($row_counter): Keyword ($keyword_id): already exists for TrialUnit ($trialunit_id).";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    $bulk_sql .= "($trialunit_id,$keyword_id),";

    $row_counter += 1;
  }

  chop($bulk_sql);      # remove excessive comma

  $self->logger->debug("Bulk SQL: $bulk_sql");

  my $nrows_inserted = $dbh_write->do($bulk_sql);

  if ($dbh_write->err()) {

    $self->logger->debug("Db err code: " . $dbh_write->err());
    my $err_str = $dbh_write->errstr();

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $info_msg = "$nrows_inserted records of trialunitkeyword have been inserted successfully.";
  my $info_msg_aref = [{'Message' => $info_msg}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  $dbh_write->disconnect();

  return $data_for_postrun_href;
}

sub list_trial_unit_keyword {

  my $self              = $_[0];
  my $extra_attr_yes    = $_[1];
  my $sql               = $_[2];
  my $where_para_aref   = $_[3];

  my $err = 0;
  my $msg = '';

  my $data_aref = [];

  my $dbh = connect_kdb_read();

  ($err, $msg, $data_aref) = read_data($dbh, $sql, $where_para_aref);

  if ($err) {

    return ($err, $msg, []);
  }

  $dbh->disconnect();

  my $extra_attr_tunit_keyword_data = [];

  if ($extra_attr_yes) {

    my $perm_lookup  = {'0' => 'None',
                        '1' => 'Link',
                        '2' => 'Write',
                        '3' => 'Write/Link',
                        '4' => 'Read',
                        '5' => 'Read/Link',
                        '6' => 'Read/Write',
                        '7' => 'Read/Write/Link',
    };

    for my $row (@{$data_aref}) {

      my $trial_unit_keyword_id    = $row->{'TrialUnitKeywordId'};
      my $permission               = $row->{'UltimatePerm'};
      $row->{'UltimatePermission'} = $perm_lookup->{$permission};

      if ( ($permission & $READ_WRITE_PERM) == $READ_WRITE_PERM ) {

        $row->{'remove'} = "remove/trialunitkeyword/$trial_unit_keyword_id";
      }

      push(@{$extra_attr_tunit_keyword_data}, $row);
    }
  }
  else {

    $extra_attr_tunit_keyword_data = $data_aref;
  }

  return ($err, $msg, $extra_attr_tunit_keyword_data);
}

sub list_trialunit_keyword_advanced_runmode {

=pod list_trialunit_keyword_advanced_HELP_START
{
"OperationName": "List trial unit keyword",
"Description": "List the whole association of keywords with trial units. This listing will require pagination if it is called without trialunit id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination NumOfRecords='2' NumOfPages='2' Page='1' NumPerPage='1' /><RecordMeta TagName='TrialUnitKeyword' /><TrialUnitKeyword TrialId='1' TrialUnitKeywordId='6' KeywordId='24' remove='remove/trialunitkeyword/6' UltimatePermission='Read/Write/Link' KeywordName='Keyword_6508061' TrialUnitId='41' UltimatePerm='7' /></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfRecords' : '2', 'NumOfPages' : 2, 'NumPerPage' : '1', 'Page' : '1'}], 'RecordMeta' : [{'TagName' : 'TrialUnitKeyword'}], 'TrialUnitKeyword' : [{'TrialUnitKeywordId' : '6', 'TrialId': 1,'remove' : 'remove/trialunitkeyword/6', 'KeywordId' : '24', 'UltimatePermission' : 'Read/Write/Link', 'KeywordName' : 'Keyword_6508061', 'TrialUnitId' : '41', 'UltimatePerm' : '7'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"URLParameter": [{"ParameterName": "nperpage", "Description": "Number of records in a page for pagination"}, {"ParameterName": "num", "Description": "The page number of the pagination"},{"ParameterName": "id", "Description": "Existing TrialUnitId"}],
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

  my $trial_unit_id          = -1;
  my $trial_unit_id_provided = 0;

  if (defined $self->param('id')) {

    $trial_unit_id          = $self->param('id');
    $trial_unit_id_provided = 1;

    if ($filtering_csv =~ /TrialUnitId\s*=\s*(.*),?/) {

      if ( "$trial_unit_id" ne "$1" ) {

        my $err_msg = 'Duplicate filtering condition for TrialUnitId.';
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
    else {

      if (length($filtering_csv) > 0) {

        if ($filtering_csv =~ /&$/) {

          $filtering_csv .= "TrialUnitId=$trial_unit_id";
        }
        else {

          $filtering_csv .= "&TrialUnitId=$trial_unit_id";
        }
      }
      else {

        $filtering_csv .= "TrialUnitId=$trial_unit_id";
      }
    }
  }

  $self->logger->debug("Filtering csv: $filtering_csv");

  my $sorting = '';

  if (defined $query->param('Sorting')) {

    $sorting = $query->param('Sorting');
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'trial');

  my $sql = 'SELECT * FROM trialunitkeyword LIMIT 1';

  my ($sample_tup_err, $sample_tup_msg, $sample_tup_data) = $self->list_trial_unit_keyword(0, $sql);

  if ($sample_tup_err) {

    $self->logger->debug($sample_tup_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $dbh = connect_kdb_read();

  my $sample_data_aref = $sample_tup_data;

  my @field_list_all;

  if (scalar(@{$sample_data_aref}) == 1) {

    @field_list_all = keys(%{$sample_data_aref->[0]});
  }
  else {

    $self->logger->debug("It reaches here");
    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'trialunitkeyword');

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
                                                                                'TrialUnitKeywordId',
        );

    if ($sel_field_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;

    if ($filtering_csv =~ /TrialUnitId/) {

      push(@{$final_field_list}, 'TrialUnitId');
    }
  }

  my $field_lookup = {};
  for my $fd_name (@{$final_field_list}) {

    $field_lookup->{$fd_name} = 1;
  }

  my $other_join = '';

  if ($field_lookup->{'KeywordId'}) {

    push(@{$final_field_list}, 'keyword.KeywordName');
    $other_join .= ' LEFT JOIN keyword ON trialunitkeyword.KeywordId = keyword.KeywordId ';
  }

  $self->logger->debug("Final field list: " . join(', ', @{$final_field_list}));

  my $sql_field_list = [];
  for my $field_name (@{$final_field_list}) {

    my $full_field_name = $field_name;
    if (!($full_field_name =~ /\./)) {

      $full_field_name = 'trialunitkeyword.' . $full_field_name;
    }

    push(@{$sql_field_list}, $full_field_name);
  }


  push(@{$sql_field_list}, "$perm_str AS UltimatePerm ");

  my $field_list_str = join(', ', @{$sql_field_list});

  $sql  = "SELECT $field_list_str ";
  $sql .= 'FROM trialunitkeyword ';
  $sql .= 'LEFT JOIN trialunit ON trialunitkeyword.TrialUnitId = trialunit.TrialUnitId ';
  $sql .= 'LEFT JOIN trial ON trialunit.TrialId = trial.TrialId ';
  $sql .= "$other_join ";

  my $validation_func_lookup = { 'TrialUnitId' => sub { return $self->validate_trial_unit_id(@_); } };

  $self->logger->debug("Final field list: " . join(', ', @{$final_field_list}));

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering('TrialUnitKeywordId',
                                                                              'trialunitkeyword',
                                                                              $filtering_csv,
                                                                              $final_field_list,
                                                                              $validation_func_lookup,
      );

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

  my $filtering_exp = " WHERE (($perm_str) & $READ_PERM) = $READ_PERM $filter_where_phrase ";

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

    my $page_where_phrase = '';
    $page_where_phrase   .= ' LEFT JOIN trialunit ON trialunitkeyword.TrialUnitId = trialunit.TrialUnitId ';
    $page_where_phrase   .= ' LEFT JOIN trial ON trialunit.TrialId = trial.TrialId ';
    $page_where_phrase   .= " $filtering_exp ";

    my ($paged_id_err, $paged_id_msg, $nb_records,
        $nb_pages, $limit_clause, $rcount_time) = get_paged_filter($dbh,
                                                                   $nb_per_page,
                                                                   $page,
                                                                   'trialunitkeyword',
                                                                   'TrialUnitKeywordId',
                                                                   $page_where_phrase,
                                                                   $where_arg
                                                                  );

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

  $sql .= " $filtering_exp ";

  my ($sort_err, $sort_msg, $sort_sql) = parse_sorting($sorting, $final_field_list, 'trialunitkeyword');

  if ($sort_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sort_msg}]};

    return $data_for_postrun_href;
  }

  if (length($sort_sql) > 0) {

    $sql .= " ORDER BY $sort_sql ";
  }
  else {

    $sql .= ' ORDER BY trialunitkeyword.TrialunitkeywordId DESC';
  }

  $sql .= " $paged_limit_clause ";

  $self->logger->debug("Where arg: " . join(',', @{$where_arg}));

  $self->logger->debug("SQL: $sql");

  my ($read_tu_kwd_err, $read_tu_kwd_msg, $tu_kwd_data) = $self->list_trial_unit_keyword(1,
                                                                                         $sql,
                                                                                         $where_arg);

  if ($read_tu_kwd_err) {

    $self->logger->debug($read_tu_kwd_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'} = 0;
  $data_for_postrun_href->{'Data'}  = {'TrialUnitKeyword'   => $tu_kwd_data,
                                       'Pagination'         => $pagination_aref,
                                       'RecordMeta'         => [{'TagName' => 'TrialUnitKeyword'}],
  };

  return $data_for_postrun_href;
}

sub add_trial_unit_keyword_runmode {

=pod add_trial_unit_keyword_HELP_START
{
"OperationName": "Add keyword to trial unit",
"Description": "Associate a new keyword with a trial unit specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "trialunitkeyword",
"SkippedField": ["TrialUnitId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='103' ParaName='TrialUnitKeywordId' /><Info Message='TrialUnitKeyword (103) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '104','ParaName' : 'TrialUnitKeywordId'}],'Info' : [{'Message' : 'TrialUnitKeyword (104) has been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TrialUnitId (123): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'TrialUnitId (123): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialUnitId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self          = shift;
  my $trial_unit_id = $self->param('id');
  my $query         = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'TrialUnitId' => 1};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'trialunitkeyword', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $keyword_id   = $query->param('KeywordId');

  $dbh_read = connect_kdb_read();

  my $trial_id = read_cell_value($dbh_read, 'trialunit', 'TrialId', 'TrialUnitId', $trial_unit_id);

  if (length($trial_id) == 0) {

    my $err_msg = "TrialUnitId ($trial_unit_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'trial');
  my $sql      = "SELECT $perm_str AS UltimatePermission ";
  $sql        .= 'FROM trial ';
  $sql        .= 'WHERE TrialId=?';

  my ($read_err, $permission) = read_cell($dbh_read, $sql, [$trial_id]);

  if ( ($permission & $READ_WRITE_PERM) != $READ_WRITE_PERM ) {

    my $err_msg = "Trial ($trial_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $keyword_exist = record_existence($dbh_read, 'keyword', 'KeywordId', $keyword_id);

  if (!$keyword_exist) {

    my $err_msg = "Keyword ($keyword_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'KeywordId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql = 'SELECT TrialUnitKeywordId FROM trialunitkeyword WHERE TrialUnitId=? AND KeywordId=?';

  my ($r_tu_kwd_id_err, $tu_kwd_id) = read_cell($dbh_read, $sql, [$trial_unit_id, $keyword_id]);

  if (length($tu_kwd_id) > 0) {

    my $err_msg = "Keyword ($keyword_id): already exists in trialunit ($trial_unit_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'KeywordId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_read->disconnect();

  my $dbh_write = connect_kdb_write();

  $sql  = 'INSERT INTO trialunitkeyword SET ';
  $sql .= 'KeywordId=?, ';
  $sql .= 'TrialUnitId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($keyword_id, $trial_unit_id);

  my $tunit_keyword_id = -1;
  if ($dbh_write->err()) {

    $self->logger->debug("Insert into trialunitkeyword failed.");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $tunit_keyword_id = $dbh_write->last_insert_id(undef, undef, 'trialunitkeyword', 'TrialUnitKeywordId');
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref  = [{'Message' => "TrialUnitKeyword ($tunit_keyword_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$tunit_keyword_id", 'ParaName' => 'TrialUnitKeywordId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'       => $info_msg_aref,
                                           'ReturnId'   => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub remove_trial_unit_keyword_runmode {

=pod remove_trial_unit_keyword_HELP_START
{
"OperationName": "Remove trial unit keyword",
"Description": "Delete association between trial unit and keyword specified by trialunitkeyword id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='TrialUnitKeyword (103) has been removed successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'TrialUnitKeyword (104) has been removed successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TrialUnitKeyword (103) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'TrialUnitKeyword (103) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialUnitKeywordId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self             = shift;
  my $tunit_keyword_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_read = connect_kdb_read();
  my $trial_unit_id = read_cell_value($dbh_read, 'trialunitkeyword', 'TrialUnitId',
                                      'TrialUnitKeywordId', $tunit_keyword_id);

  if (length($trial_unit_id) == 0) {

    my $err_msg = "TrialUnitKeyword ($tunit_keyword_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trial_id = read_cell_value($dbh_read, 'trialunit', 'TrialId', 'TrialUnitId', $trial_unit_id);

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'trial');
  my $sql      = "SELECT $perm_str AS UltimatePermission ";
  $sql        .= 'FROM trial ';
  $sql        .= 'WHERE TrialId=?';

  my ($read_err, $permission) = read_cell($dbh_read, $sql, [$trial_id]);

  if ( ($permission & $READ_WRITE_PERM) != $READ_WRITE_PERM ) {

    my $err_msg = "Trial ($trial_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_read->disconnect();

  my $dbh_write = connect_kdb_write();

  $sql = 'DELETE FROM trialunitkeyword WHERE TrialUnitKeywordId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($tunit_keyword_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "TrialUnitKeyword ($tunit_keyword_id) has been removed successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'       => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub import_crossing_csv_runmode {

=pod import_crossing_csv_HELP_START
{
"OperationName": "Import crossing records",
"Description": "Import crossings from a csv file formatted as a sparse matrix of crossing data at the trial unit level.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='2 of crossing records have been inserted successfully. ' /><StatInfo Unit='second' ServerElapsedTime='0.051' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : '2 of crossing records have been inserted successfully. '}],'StatInfo' : [{'ServerElapsedTime' : '0.049','Unit' : 'second'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><StatInfo Unit='second' ServerElapsedTime='0.015' /><Error Message='TrialUnitSpecimen (200): not found' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'TrialUnitSpecimen (200): not found'}],'StatInfo' : [{'ServerElapsedTime' : '0.015','Unit' : 'second'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "CSV",
"UploadFileParameterName": "uploadfile",
"HTTPParameter": [{"Name": "TrialId", "Description": "Column number starting from 0 in the CSV upload file for TrialId column", "Required": 1}, {"Name": "BreedingMethodId", "Description": "Column number starting from 0 in the CSV upload file for BreedingMethodId column", "Required": 1}, {"Name": "MaleParentId", "Description": "Column number starting from 0 for TrialUnitSpecimenId male parent column", "Required": 1}, {"Name": "FemaleParentId", "Description": "Column number starting from zero for TrialUnitSpecimenId female parent column", "Required": 1}, {"Name": "CrossingDateTime", "Description": "Column number starting from 0 for crossing date/time column", "Required": 0}, {"Name": "UserId", "Description": "Column number starting from 0 for UserId column", "Required": 0}, {"Name": "CrossingNote", "Description": "Column number starting from 0 for CrossingNote column", "Required": 0}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $start_time = [gettimeofday()];
  my $data_for_postrun_href = {};

  my $data_csv_file = $self->authen->get_upload_file();

  my $num_of_col = get_csvfile_num_of_col($data_csv_file);

  $self->logger->debug("Number of columns: $num_of_col");

  my $TrialId_col            = $query->param('TrialId');
  my $BreedingMethodId_col   = $query->param('BreedingMethodId');
  my $MaleParentId_col       = $query->param('MaleParentId');
  my $FemaleParentId_col     = $query->param('FemaleParentId');

  my $CrossingDateTime_col   = $query->param('CrossingDateTime');
  my $UserId_col             = $query->param('UserId');
  my $CrossingNote_col       = $query->param('CrossingNote');

  my $chk_col_def_data = { 'TrialId'                   => $TrialId_col,
                           'BreedingMethodId'          => $BreedingMethodId_col,
                           'MaleParentId'              => $MaleParentId_col,
                           'FemaleParentId'            => $FemaleParentId_col,
                         };

  my $matched_col = {};

  $matched_col->{$TrialId_col}          = 'TrialId';
  $matched_col->{$BreedingMethodId_col} = 'BreedingMethodId';
  $matched_col->{$MaleParentId_col}     = 'MaleParentId';
  $matched_col->{$FemaleParentId_col}   = 'FemaleParentId';

  if (defined $query->param('CrossingDateTime')) {

    if (length($query->param('CrossingDateTime')) > 0) {

      $chk_col_def_data->{'CrossingDateTime'} = $CrossingDateTime_col;
      $matched_col->{$CrossingDateTime_col} = 'CrossingDateTime';
    }
  }

  if (defined $query->param('UserId')) {

    if (length($query->param('UserId')) > 0) {

      $chk_col_def_data->{'UserId'} = $UserId_col;
      $matched_col->{$UserId_col} = 'UserId';
    }
  }

  if (defined $query->param('CrossingNote')) {

    if (length($query->param('CrossingNote')) > 0) {

      $chk_col_def_data->{'CrossingNote'} = $CrossingNote_col;
      $matched_col->{$CrossingNote_col} = 'CrossingNote';
    }
  }


  my ($col_def_err, $col_def_err_href) = check_col_def_href( $chk_col_def_data, $num_of_col );

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

  my $num_of_bulk_insert = $NB_RECORD_BULK_INSERT;

  my $dbh_write = connect_kdb_write();

  my $row_counter = 1;
  my $i = 0;
  my $num_of_rows = scalar(@{$data_aref});

  if (scalar(@{$data_aref}) == 0) {

    $self->logger->debug("No data provided");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("Number of rows: $num_of_rows");

  my $trial_id2tu_spec_id_href = {};
  my $uniq_bmeth_href          = {};
  my $uniq_user_id_href        = {};

  my @sql_values;

  foreach my $data_rec (@{$data_aref}) {

    my $TrialId            = $data_rec->{'TrialId'};
    my $BreedingMethodId   = $data_rec->{'BreedingMethodId'};
    my $MaleParentId       = $data_rec->{'MaleParentId'};
    my $FemaleParentId     = $data_rec->{'FemaleParentId'};

    my ( $missing_err, $missing_msg ) = check_missing_value( { 'TrialId' => $TrialId,
                                                               'BreedingMethodId' => $BreedingMethodId,
                                                               'MaleParentId' => $MaleParentId,
                                                               'FemaleParentId' => $FemaleParentId
                                                             } );

    if ($missing_err) {

      my $err_msg = "Row ($row_counter): " . $missing_msg . ": missing.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $CrossingDateTime = 'NULL';

    if (defined $data_rec->{'CrossingDateTime'}) {

      if (length($data_rec->{'CrossingDateTime'}) > 0) {

        $CrossingDateTime   = $data_rec->{'CrossingDateTime'};

        my ($crossing_dt_err, $crossing_dt_msg) = check_dt_value( {'CrossingDateTime' => $CrossingDateTime} );

        if ($crossing_dt_err) {

          my $err_msg = "Row ($row_counter): " . $crossing_dt_msg . ": not date/time.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }

        $CrossingDateTime = $dbh_write->quote($CrossingDateTime);
      }
    }

    #my $UserId             = 'NULL';
    my $UserId = $self->authen->user_id();

    if (defined $data_rec->{'UserId'}) {

      if (length($data_rec->{'UserId'}) > 0) {

        $UserId = $data_rec->{'UserId'};
        $uniq_user_id_href->{$UserId} = 1;
      }
    }

    my $CrossingNote       = 'NULL';

    if (defined $data_rec->{'CrossingNote'}) {

      if (length($data_rec->{'CrossingNote'}) > 0) {

        $CrossingNote = $dbh_write->quote($data_rec->{'CrossingNote'});
      }
    }

    $uniq_bmeth_href->{$BreedingMethodId} = 1;

    my $uniq_tu_spec_in_trial = {};

    if (defined $trial_id2tu_spec_id_href->{$TrialId}) {

      $uniq_tu_spec_in_trial = $trial_id2tu_spec_id_href->{$TrialId};
    }

    $uniq_tu_spec_in_trial->{$MaleParentId}   = 1;
    $uniq_tu_spec_in_trial->{$FemaleParentId} = 1;

    $trial_id2tu_spec_id_href->{$TrialId} = $uniq_tu_spec_in_trial;

    push(@sql_values, "(${TrialId},${BreedingMethodId},${MaleParentId},${FemaleParentId},${CrossingDateTime},${UserId},${CrossingNote})");

    $row_counter += 1;
  }

  my @trial_id_list = keys(%{$trial_id2tu_spec_id_href});

  if (scalar(@trial_id_list) == 0) {

    my $err_msg = "No trial found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_trial_ok, $trouble_trial_id_aref) = check_permission($dbh_write, 'trial', 'TrialId',
                                                               \@trial_id_list, $group_id, $gadmin_status,
                                                               $READ_WRITE_PERM);

  if (!$is_trial_ok) {

    my $trouble_trial_id = join(',', @{$trouble_trial_id_aref});

    my $err_msg = "Permission denied: Group ($group_id) and Trial ($trouble_trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my @bmeth_id_list = keys(%{$uniq_bmeth_href});
  my @user_id_list  = keys(%{$uniq_user_id_href});

  my ($bmeth_err, $bmeth_msg, $unfound_bmeth_aref, $found_bmeth_aref) = record_existence_bulk($dbh_write, 'breedingmethod',
                                                                                              'BreedingMethodId', \@bmeth_id_list);

  if ($bmeth_err) {

    $self->logger->debug("Check recorod existence bulk failed: $bmeth_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$unfound_bmeth_aref}) > 0) {

    my $unfound_bmeth_csv = join(',', @{$unfound_bmeth_aref});

    my $err_msg = "BreedingMethod ($unfound_bmeth_csv): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($user_err, $user_msg, $unfound_user_aref, $found_user_aref) = record_existence_bulk($dbh_write, 'systemuser',
                                                                                          'UserId', \@user_id_list);

  if ($user_err) {

    $self->logger->debug("Check recorod existence bulk failed: $user_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$unfound_user_aref}) > 0) {

    my $unfound_user_csv = join(',', @{$unfound_user_aref});

    my $err_msg = "User ($unfound_user_csv): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT TrialId, TrialUnitSpecimenId ';
  $sql   .= 'FROM trialunitspecimen LEFT JOIN trialunit ON trialunitspecimen.TrialUnitId = trialunit.TrialUnitId ';
  $sql   .= 'WHERE TrialId IN (' . join(',', @trial_id_list) . ')';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute();

  if ($dbh_write->err()) {

    $self->logger->debug("Read TrialUnitSpecimenId failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $tu_spec_href = $sth->fetchall_hashref('TrialUnitSpecimenId');

  if ($sth->err()) {

    $self->logger->debug("Read TrialUnitSpecimenId into hash ref failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  foreach my $trial_id (@trial_id_list) {

    my @spec_id_list = keys(%{$trial_id2tu_spec_id_href->{$trial_id}});

    foreach my $tu_spec_id (@spec_id_list) {

      if ( !(defined $tu_spec_href->{$tu_spec_id}) ) {

        my $err_msg = "TrialUnitSpecimen ($tu_spec_id): not found";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
      else {

        my $db_trial_id = $tu_spec_href->{$tu_spec_id}->{'TrialId'};

        if ($db_trial_id != $trial_id) {

          my $err_msg = "TrialUnitSpecimen ($tu_spec_id): not in trial ($trial_id).";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
      }
    }
  }

  if (scalar(@sql_values) == 0) {

    $self->logger->debug("No data");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error.'}]};

    return $data_for_postrun_href;
  }

  my $bulk_sql = 'INSERT INTO crossing ';
  $bulk_sql   .= '(TrialId,BreedingMethodId,MaleParentId,FemaleParentId,CrossingDateTime,UserId,CrossingNote) ';
  $bulk_sql   .= 'VALUES ' . join(',', @sql_values);

  $self->logger->debug("BULK SQL: $bulk_sql");

  my $nb_rows_inserted = $dbh_write->do($bulk_sql);

  if ($dbh_write->err()) {

    $self->logger->debug("Db err code: " . $dbh_write->err());

    if ($dbh_write->err() == 1062) {

      my $err_str = $dbh_write->errstr();

      if ( $err_str =~ /Duplicate entry '(.+)'/ ) {

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

  $dbh_write->disconnect();

  my $info_msg = "$nb_rows_inserted of crossing records have been inserted successfully. ";

  my $info_msg_aref = [{'Message' => $info_msg}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_crossing {

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

  $dbh->disconnect();

  my $perm_lookup  = {'0' => 'None',
                      '1' => 'Link',
                      '2' => 'Write',
                      '3' => 'Write/Link',
                      '4' => 'Read',
                      '5' => 'Read/Link',
                      '6' => 'Read/Write',
                      '7' => 'Read/Write/Link',
  };

  my @extra_attr_crossing_data;

  for my $row (@{$data_aref}) {

    my $crossing_id = $row->{'CrossingId'};
    my $permission    = $row->{'UltimatePerm'};

    if ($extra_attr_yes) {

      $row->{'UltimatePermission'} = $perm_lookup->{$permission};

      if ( ($permission & $READ_WRITE_PERM) == $READ_WRITE_PERM ) {

        $row->{'update'}       = "update/crossing/$crossing_id";
      }
    }
    push(@extra_attr_crossing_data, $row);
  }

  return ($err, $msg, \@extra_attr_crossing_data);
}

sub list_crossing_advanced_runmode {

=pod list_crossing_advanced_HELP_START
{
"OperationName": "List trial crossings",
"Description": "List trial crossings.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "",
"SuccessMessageJSON": "",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"URLParameter": [{"ParameterName": "nperpage", "Description": "Number of records in a page for pagination", "Optional": 1}, {"ParameterName": "num", "Description": "The page number of the pagination", "Optional": 1}, {"ParameterName": "trialid", "Description": "Existing TrialId", "Optional": 1}],
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

  my $trial_id          = -1;
  my $trial_id_provided = 0;

  if (defined $self->param('trialid')) {

    $trial_id          = $self->param('trialid');
    $trial_id_provided = 1;

    if ($filtering_csv =~ /TrialId\s*=\s*(.*),?/) {

      if ( "$trial_id" ne "$1" ) {

        my $err_msg = 'Duplicate filtering condition for TrialId.';
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
    else {

      if (length($filtering_csv) > 0) {

        if ($filtering_csv =~ /&$/) {

          $filtering_csv .= "TrialId=$trial_id";
        }
        else {

          $filtering_csv .= "&TrialId=$trial_id";
        }
      }
      else {

        $filtering_csv .= "TrialId=$trial_id";
      }
    }
  }

  $self->logger->debug("Filtering csv: $filtering_csv");

  my $sorting = '';

  if (defined $query->param('Sorting')) {

    $sorting = $query->param('Sorting');
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'trial');

  my $sql = 'SELECT * FROM crossing LIMIT 1';

  my ($sample_crossing_err, $sample_crossing_msg, $sample_crossing_data) = $self->list_crossing(0, $sql, []);

  if ($sample_crossing_err) {

    $self->logger->debug($sample_crossing_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $dbh = connect_kdb_read();

  if ($trial_id_provided == 1) {

    if (!record_existence($dbh, 'trial', 'TrialId', $trial_id)) {

      my $err_msg = "Trial ($trial_id): not found";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $sample_data_aref = $sample_crossing_data;

  my @field_list_all;

  if (scalar(@{$sample_data_aref}) == 1) {

    @field_list_all = keys(%{$sample_data_aref->[0]});
  }
  else {

    $self->logger->debug("It reaches here");
    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'crossing');

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
  my $filtering_field_list = [];

  if (length($field_list_csv) > 0) {

    my ($sel_field_err, $sel_field_msg, $sel_field_list) = parse_selected_field($field_list_csv,
                                                                                $final_field_list,
                                                                                'CrossingId');

    if ($sel_field_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;

    if ($filtering_csv =~ /TrialId/) {

      push(@{$final_field_list}, 'crossing.TrialId');
    }
  }

  foreach my $field_name (@{$final_field_list}) {

    push(@{$sql_field_list}, "crossing.${field_name}");
  }

  $filtering_field_list = $final_field_list;

  my $field_lookup = {};
  for my $fd_name (@{$final_field_list}) {

    $field_lookup->{$fd_name} = 1;
  }

  my $other_join = '';

  if ($field_lookup->{'MaleParentId'}) {

    push(@{$sql_field_list}, 'tuspec_male.SpecimenId AS MaleSpecimenId');
    push(@{$sql_field_list}, 'tuspec_male.TrialUnitId AS MaleTrialUnitId');
    push(@{$sql_field_list}, 'tuspec_male.SpecimenNumber AS MaleSpecimenNumber');
    push(@{$sql_field_list}, 'tuspec_male.HarvestDate AS MaleHarvestDate');

    $other_join .= ' LEFT JOIN trialunitspecimen as tuspec_male ON crossing.MaleParentId = tuspec_male.TrialUnitSpecimenId ';

    push(@{$sql_field_list}, 'spec_male.SpecimenName AS MaleSpecimenName');
    $other_join .= ' LEFT JOIN specimen as spec_male ON tuspec_male.SpecimenId = spec_male.SpecimenId ';
  }

  if ($field_lookup->{'FemaleParentId'}) {

    push(@{$sql_field_list}, 'tuspec_female.SpecimenId AS FemaleSpecimenId');
    push(@{$sql_field_list}, 'tuspec_female.TrialUnitId AS FemaleTrialUnitId');
    push(@{$sql_field_list}, 'tuspec_female.SpecimenNumber AS FemaleSpecimenNumber');
    push(@{$sql_field_list}, 'tuspec_female.HarvestDate AS FemaleHarvestDate');

    $other_join .= ' LEFT JOIN trialunitspecimen as tuspec_female ON crossing.FemaleParentId = tuspec_female.TrialUnitSpecimenId ';

    push(@{$sql_field_list}, 'spec_female.SpecimenName AS FemaleSpecimenName');
    $other_join .= ' LEFT JOIN specimen as spec_female ON tuspec_female.SpecimenId = spec_female.SpecimenId ';
  }

  if ($field_lookup->{'BreedingMethodId'}) {

    push(@{$sql_field_list}, 'breedingmethod.BreedingMethodName');
    $other_join .= ' LEFT JOIN breedingmethod ON crossing.BreedingMethodId = breedingmethod.BreedingMethodId ';
  }

  push(@{$sql_field_list}, 'trial.TrialName');

  push(@{$sql_field_list}, "$perm_str AS UltimatePerm ");

  my $field_list_str = join(', ', @{$sql_field_list});

  $sql  = "SELECT $field_list_str ";
  $sql .= 'FROM crossing ';
  $sql .= 'LEFT JOIN trial ON crossing.TrialId = trial.TrialId ';
  $sql .= "$other_join ";

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering('CrossingId',
                                                                              'crossing',
                                                                              $filtering_csv,
                                                                              $filtering_field_list
                                                                             );

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

  my $filtering_exp = "WHERE (($perm_str) & $READ_PERM) = $READ_PERM $filter_where_phrase ";

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

    my $page_where_phrase = '';
    $page_where_phrase   .= ' LEFT JOIN trial ON crossing.TrialId = trial.TrialId ';
    $page_where_phrase   .= " $filtering_exp ";

    my ($paged_id_err, $paged_id_msg, $nb_records,
        $nb_pages, $limit_clause, $rcount_time) = get_paged_filter($dbh,
                                                                   $nb_per_page,
                                                                   $page,
                                                                   'crossing',
                                                                   'CrossingId',
                                                                   $page_where_phrase,
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

  $sql .= " $filtering_exp ";

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

    $sql .= ' ORDER BY crossing.CrossingId DESC';
  }

  $sql .= " $paged_limit_clause ";

  $self->logger->debug("Where arg: " . join(',', @{$where_arg}));

  $self->logger->debug("SQL with VCol: $sql");

  my ($read_crossing_err, $read_crossing_msg, $crossing_data) = $self->list_crossing(1,
                                                                               $sql,
                                                                               $where_arg);

  if ($read_crossing_err) {

    $self->logger->debug($read_crossing_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;

  $data_for_postrun_href->{'Data'}  = {'Crossing'  => $crossing_data,
                                       'Pagination' => $pagination_aref,
                                       'RecordMeta' => [{'TagName' => 'Crossing'}],
  };

  return $data_for_postrun_href;
}

sub rollback_cleanup {

  # This method takes a hash reference for the records to delete in the following format.
  # $inserted_id->{'table_name'} = ['Id Field Name', record_id]. So the limitation
  # of this cleanup function is that it cannot delete multiple records in a table
  # whoses record id values are different. There is a better version of this
  # clean up function which can do this. It is called rollback_cleanup_multi which is
  # part of Common.pm package.

  my $self        = $_[0];
  my $dbh         = $_[1];
  my $inserted_id = $_[2];

  my $err     = 0;
  my $err_msg = q{};

  for my $table_name (keys(%{$inserted_id})) {

    my $field_info = $inserted_id->{$table_name};
    my $id_field   = $field_info->[0];
    my $id_val     = $field_info->[1];

    $self->logger->debug("Deleting ($id_field, $id_val) from $table_name");

    my $sql = "DELETE FROM $table_name ";
    $sql   .= "WHERE $id_field=?";

    my $sth = $dbh->prepare($sql);
    $sth->execute($id_val);

    if ($dbh->err()) {

      $err_msg = $dbh->errstr();
      $err = 1;
      last;
    }

    $sth->finish();
  }

  return ($err, $err_msg);
}

sub validate_trial_id {

  my $self         = $_[0];
  my $trial_id_str = $_[1];

  my $err = 0;
  my $msg = '';

  my $trial_id_aref = [];

  if ($trial_id_str =~ /^\(.*\)$/) {

    $trial_id_str =~ s/[\(|\)]//g;
    my @trial_id_list = split(/,/, $trial_id_str);
  }
  else {

    push(@{$trial_id_aref}, $trial_id_str);
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $dbh = connect_kdb_read();

  my ($is_ok, $trouble_trial_id_aref) = check_permission($dbh, 'trial', 'TrialId',
                                                         $trial_id_aref, $group_id, $gadmin_status,
                                                         $READ_PERM);

  if (!$is_ok) {

    $err = 1;
    $msg = "Trial (" . join(',', @{$trouble_trial_id_aref}) . "): permission denied.";
  }

  $dbh->disconnect();

  return ($err, $msg);
}

sub validate_trial_unit_id {

  my $self              = $_[0];
  my $trial_unit_id_str = $_[1];

  my $err = 0;
  my $msg = '';

  my $dbh = connect_kdb_read();

  my $where_phrase = '';

  $self->logger->debug("TrialUnitIdStr: $trial_unit_id_str");

  if ($trial_unit_id_str =~ /^\(.*\)$/) {

    $where_phrase = "TrialUnitId IN $trial_unit_id_str";
  }
  else {

    $where_phrase = "TrialUnitId = $trial_unit_id_str";
  }

  my $sql = "SELECT DISTINCT TrialId FROM trialunit WHERE $where_phrase";

  $self->logger->debug("DISTINCT TrialId SQL: $sql");

  my ($read_tid_err, $read_tid_msg, $trial_id_data) = read_data($dbh, $sql, []);

  if ($read_tid_err) {

    $self->logger->debug("Get DISTINCT TrialId failed: $read_tid_msg");
    $err = 1;
    $msg = 'Unexpected Error.';

    return ($err, $msg);
  }

  my $trial_id_aref = [];

  for my $trial_id_rec (@{$trial_id_data}) {

    push(@{$trial_id_aref}, $trial_id_rec->{'TrialId'});
  }

  $self->logger->debug("DISTINCT TrialId: " . join(',', @{$trial_id_aref}) );

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_ok, $trouble_trial_id_aref) = check_permission($dbh, 'trial', 'TrialId',
                                                         $trial_id_aref, $group_id, $gadmin_status,
                                                         $READ_PERM);

  if (!$is_ok) {

    $err = 1;
    $msg = "Trial (" . join(',', @{$trouble_trial_id_aref}) . "): permission denied";
  }

  $dbh->disconnect();

  return ($err, $msg);
}

sub add_crossing_runmode {

=pod add_crossing_HELP_START
{
"OperationName": "Add crossing for a trial",
"Description": "Add a new crossing in the trial specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "crossing",
"SkippedField": ["TrialId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><StatInfo ServerElapsedTime='0.046' Unit='second' /><Info Message='Crossing (1) has been added successfully.' /><ReturnId Value='1' ParaName='CrossingId' /></DATA>",
"SuccessMessageJSON": "{'StatInfo' : [{'ServerElapsedTime' : '0.043','Unit' : 'second'}],'Info' : [{'Message' : 'Crossing (2) has been added successfully.'}],'ReturnId' : [{'Value' : '2','ParaName' : 'CrossingId'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error UserId='UserId (92) does not exist.' /><StatInfo Unit='second' ServerElapsedTime='0.011' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.010'}],'Error' : [{'UserId' : 'UserId (92) does not exist.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'TrialId' => 1};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'crossing', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $trial_id            = $self->param('id');
  my $breeding_method_id  = $query->param('BreedingMethodId');
  my $male_parent_id      = $query->param('MaleParentId');
  my $female_parent_id    = $query->param('FemaleParentId');
  my $user_id             = $query->param('UserId');

  my $crossing_dt         = undef;
  my $crossing_note       = undef;

  if (defined $query->param('CrossingDateTime')) {

    if (length($query->param('CrossingDateTime')) > 0) {

      $crossing_dt = $query->param('CrossingDateTime');

      my ($crossing_err, $crossing_href) = check_dt_href( {'CrossingDateTime' => $crossing_dt} );

      if ($crossing_err) {

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [$crossing_href]};

        return $data_for_postrun_href;
      }
    }
  }

  if (defined $query->param('CrossingNote')) {

    if (length($query->param('CrossingNote')) > 0) {

      $crossing_note = $query->param('CrossingNote');
    }
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $dbh_k_write = connect_kdb_write();

  if (! record_existence($dbh_k_write, 'trial', 'TrialId', $trial_id) ) {

    my $err_msg = "Trial ($trial_id) does not exist.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($is_trial_ok, $trouble_trial_id_aref) = check_permission($dbh_k_write, 'trial', 'TrialId',
                                                               [$trial_id], $group_id, $gadmin_status,
                                                               $READ_WRITE_PERM);

  if (!$is_trial_ok) {

    my $trouble_trial_id = $trouble_trial_id_aref->[0];

    my $err_msg = "Permission denied: Group ($group_id) and Trial ($trouble_trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (! record_existence($dbh_k_write, 'breedingmethod', 'BreedingMethodId', $breeding_method_id) ) {

    my $err_msg = "BreedingMethodId ($breeding_method_id) does not exist.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'BreedingMethodId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT TrialUnitSpecimenId FROM trialunitspecimen ';
  $sql   .= 'LEFT JOIN trialunit ON trialunitspecimen.TrialUnitId = trialunit.TrialUnitId ';
  $sql   .= 'WHERE TrialUnitSpecimenId=? AND TrialId=?';

  my ($chk_m_parent_err, $db_m_parent_id) = read_cell($dbh_k_write, $sql, [$male_parent_id, $trial_id]);

  if (length($db_m_parent_id) == 0) {

    my $err_msg = "MaleParentId ($male_parent_id) does not exist.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'MaleParentId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($chk_f_parent_err, $db_f_parent_id) = read_cell($dbh_k_write, $sql, [$female_parent_id, $trial_id]);

  if (length($db_f_parent_id) == 0) {

    my $err_msg = "FemaleParentId ($female_parent_id) does not exist.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'FemaleParentId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (! record_existence($dbh_k_write, 'systemuser', 'UserId', $user_id) ) {

    my $err_msg = "UserId ($user_id) does not exist.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'UserId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql  = 'INSERT INTO crossing SET ';
  $sql .= 'TrialId=?, ';
  $sql .= 'BreedingMethodId=?, ';
  $sql .= 'MaleParentId=?, ';
  $sql .= 'FemaleParentId=?, ';
  $sql .= 'CrossingDateTime=?, ';
  $sql .= 'UserId=?, ';
  $sql .= 'CrossingNote=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($trial_id, $breeding_method_id, $male_parent_id, $female_parent_id, $crossing_dt,
                $user_id, $crossing_note);

  my $crossing_id = -1;
  if (!$dbh_k_write->err()) {

    $crossing_id = $dbh_k_write->last_insert_id(undef, undef, 'crossing', 'CrossingId');
  }
  else {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref  = [{'Message' => "Crossing ($crossing_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$crossing_id", 'ParaName' => 'CrossingId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub get_crossing_runmode {

=pod get_crossing_HELP_START
{
"OperationName": "Get crossing",
"Description": "Get detailed information about crossing specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Crossing MaleSpecimenName='Specimen_48515891289' CrossingDateTime='' MaleTrialUnitId='59' BreedingMethodId='78' update='update/crossing/10' FemaleSpecimenNumber='2' UserId='0' FemaleSpecimenName='Specimen_48515891289' TrialId='64' UltimatePerm='7' MaleSpecimenId='219' MaleSpecimenNumber='1' CrossingId='10' UltimatePermission='Read/Write/Link' TrialName='Trial_53042000463' FemaleParentId='258' FemaleSpecimenId='219' MaleParentId='257' MaleHarvestDate='2021-03-03' FemaleCrossingDate='2021-03-03' CrossingNote='' FemaleTrialUnitId='59' BreedingMethodName='BreedMethod_12601099940' /><StatInfo Unit='second' ServerElapsedTime='0.006' /><RecordMeta TagName='Crossing' /></DATA>",
"SuccessMessageJSON": "{'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.005'}],'RecordMeta' : [{'TagName' : 'Crossing'}],'Crossing' : [{'UltimatePerm' : '7','TrialId' : '65','UserId' : '0','FemaleSpecimenName' : 'Specimen_55860245756','FemaleSpecimenNumber' : '2','BreedingMethodId' : '79','update' : 'update/crossing/11','MaleTrialUnitId' : '60','CrossingDateTime' : null,'MaleSpecimenName' : 'Specimen_55860245756','BreedingMethodName' : 'BreedMethod_38887886960','FemaleTrialUnitId' : '60','CrossingNote' : null,'FemaleSpecimenId' : '224','MaleParentId' : '265','MaleHarvestDate' : '2021-03-03','FemaleHarvestDate' : '2021-03-03','TrialName' : 'Trial_44094358040','FemaleParentId' : '266','UltimatePermission' : 'Read/Write/Link','MaleSpecimenNumber' : '1','CrossingId' : '11','MaleSpecimenId' : '224'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Crossing (100) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Crossing (100) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing CrossingId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self          = shift;
  my $crossing_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();
  my $trial_id = read_cell_value($dbh, 'crossing', 'TrialId', 'CrossingId', $crossing_id);

  if (length($trial_id) == 0) {

    my $err_msg = "Crossing ($crossing_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'trial');

  my $sql      = "SELECT $perm_str AS UltimatePermission ";
  $sql        .= 'FROM trial ';
  $sql        .= 'WHERE TrialId=?';

  my ($read_err, $permission) = read_cell($dbh, $sql, [$trial_id]);
  $dbh->disconnect();

  if ( ($permission & $READ_PERM) != $READ_PERM ) {

    my $err_msg = "Trial ($trial_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $msg = '';

  $sql  = 'SELECT crossing.*, trial.TrialName, breedingmethod.BreedingMethodName, ';
  $sql .= 'tuspec_male.SpecimenId AS MaleSpecimenId, ';
  $sql .= 'tuspec_male.TrialUnitId AS MaleTrialUnitId, ';
  $sql .= 'tuspec_male.SpecimenNumber AS MaleSpecimenNumber, ';
  $sql .= 'spec_male.SpecimenName AS MaleSpecimenName, ';
  $sql .= 'tuspec_female.SpecimenId AS FemaleSpecimenId, ';
  $sql .= 'tuspec_female.TrialUnitId AS FemaleTrialUnitId, ';
  $sql .= 'tuspec_female.SpecimenNumber AS FemaleSpecimenNumber, ';
  $sql .= 'tuspec_female.HarvestDate AS FemaleHarvestDate, ';
  $sql .= 'tuspec_male.HarvestDate AS MaleHarvestDate, ';
  $sql .= 'spec_female.SpecimenName AS FemaleSpecimenName, ';
  $sql .= "$perm_str AS UltimatePerm ";
  $sql .= 'FROM crossing ';
  $sql .= 'LEFT JOIN trial ON crossing.TrialId = trial.TrialId ';
  $sql .= 'LEFT JOIN trialunitspecimen as tuspec_male ON crossing.MaleParentId = tuspec_male.TrialUnitSpecimenId ';
  $sql .= 'LEFT JOIN specimen as spec_male ON tuspec_male.SpecimenId = spec_male.SpecimenId ';
  $sql .= 'LEFT JOIN trialunitspecimen as tuspec_female ON crossing.FemaleParentId = tuspec_female.TrialUnitSpecimenId ';
  $sql .= 'LEFT JOIN specimen as spec_female ON tuspec_female.SpecimenId = spec_female.SpecimenId ';
  $sql .= 'LEFT JOIN breedingmethod ON crossing.BreedingMethodId = breedingmethod.BreedingMethodId ';
  $sql .= "WHERE crossing.CrossingId=? AND (($perm_str) & $READ_PERM) = $READ_PERM ";

  my ($crossing_err, $crossing_msg, $crossing_data) = $self->list_crossing(1, $sql, [$crossing_id]);

  if ($crossing_err) {

    $self->logger->debug("List crossing failed: $crossing_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;

  $data_for_postrun_href->{'Data'}  = {'Crossing'   => $crossing_data,
                                       'RecordMeta' => [{'TagName' => 'Crossing'}],
  };

  return $data_for_postrun_href;
}

sub update_crossing_runmode {

=pod update_crossing_HELP_START
{
"OperationName": "Update crossing",
"Description": "Update crossing information.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "crossing",
"SkippedField": ["TrialId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Crossing (4) has been updated successfully.' /><StatInfo ServerElapsedTime='0.039' Unit='second' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Crossing (6) has been updated successfully.'}],'StatInfo' : [{'ServerElapsedTime' : '0.039','Unit' : 'second'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error UserId='UserId (92) does not exist.' /><StatInfo Unit='second' ServerElapsedTime='0.011' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.010'}],'Error' : [{'UserId' : 'UserId (92) does not exist.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing CrossingId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'TrialId' => 1};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'crossing', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $crossing_id         = $self->param('id');
  my $breeding_method_id  = $query->param('BreedingMethodId');
  my $male_parent_id      = $query->param('MaleParentId');
  my $female_parent_id    = $query->param('FemaleParentId');
  my $user_id             = $query->param('UserId');

  my $crossing_dt         = undef;
  my $crossing_note       = undef;

  my $dbh_k_write = connect_kdb_write();

  my $trial_id = read_cell_value($dbh_k_write, 'crossing', 'TrialId', 'CrossingId', $crossing_id);

  if (length($trial_id) == 0) {

    my $err_msg = "CrossingId ($crossing_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_trial_ok, $trouble_trial_id_aref) = check_permission($dbh_k_write, 'trial', 'TrialId',
                                                               [$trial_id], $group_id, $gadmin_status,
                                                               $READ_WRITE_PERM);

  if (!$is_trial_ok) {

    my $trouble_trial_id = $trouble_trial_id_aref->[0];

    my $err_msg = "Permission denied: Group ($group_id) and Trial ($trouble_trial_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $read_tr_sql  = 'SELECT CrossingDateTime, CrossingNote ';
  $read_tr_sql    .= 'FROM crossing WHERE CrossingId=? ';

  my ($r_df_val_err, $r_df_val_msg, $crossing_df_val_data) = read_data($dbh_k_write, $read_tr_sql,
                                                                    [$crossing_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve trial default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $nb_df_val_rec    =  scalar(@{$crossing_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve crossing default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $crossing_dt   = $crossing_df_val_data->[0]->{'CrossingDateTime'};
  $crossing_note = $crossing_df_val_data->[0]->{'CrossingNote'};

  if (length($crossing_dt) == 0) {

    $crossing_dt = undef;
  }

  if (length($crossing_note) == 0) {

    $crossing_note = undef;
  }

  if (defined $query->param('CrossingDateTime')) {

    if (length($query->param('CrossingDateTime')) > 0) {

      $crossing_dt = $query->param('CrossingDateTime');

      my ($crossing_err, $crossing_href) = check_dt_href( {'CrossingDateTime' => $crossing_dt} );

      if ($crossing_err) {

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [$crossing_href]};

        return $data_for_postrun_href;
      }
    }
    else {

      $crossing_dt = undef;
    }
  }

  if (defined $query->param('CrossingNote')) {

    if (length($query->param('CrossingNote')) > 0) {

      $crossing_note = $query->param('CrossingNote');
    }
    else {

      $crossing_note = undef;
    }
  }

  if (! record_existence($dbh_k_write, 'breedingmethod', 'BreedingMethodId', $breeding_method_id) ) {

    my $err_msg = "BreedingMethodId ($breeding_method_id) does not exist.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'BreedingMethodId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT TrialUnitSpecimenId FROM trialunitspecimen ';
  $sql   .= 'LEFT JOIN trialunit ON trialunitspecimen.TrialUnitId = trialunit.TrialUnitId ';
  $sql   .= 'WHERE TrialUnitSpecimenId=? AND TrialId=?';

  my ($chk_m_parent_err, $db_m_parent_id) = read_cell($dbh_k_write, $sql, [$male_parent_id, $trial_id]);

  if (length($db_m_parent_id) == 0) {

    my $err_msg = "MaleParentId ($male_parent_id) does not exist.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'MaleParentId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($chk_f_parent_err, $db_f_parent_id) = read_cell($dbh_k_write, $sql, [$female_parent_id, $trial_id]);

  if (length($db_f_parent_id) == 0) {

    my $err_msg = "FemaleParentId ($female_parent_id) does not exist.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'FemaleParentId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (! record_existence($dbh_k_write, 'systemuser', 'UserId', $user_id) ) {

    my $err_msg = "UserId ($user_id) does not exist.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'UserId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql  = 'UPDATE crossing SET ';
  $sql .= 'BreedingMethodId=?, ';
  $sql .= 'MaleParentId=?, ';
  $sql .= 'FemaleParentId=?, ';
  $sql .= 'CrossingDateTime=?, ';
  $sql .= 'UserId=?, ';
  $sql .= 'CrossingNote=? ';
  $sql .= 'WHERE CrossingId=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($breeding_method_id, $male_parent_id, $female_parent_id, $crossing_dt,
                $user_id, $crossing_note, $crossing_id);


  if ($dbh_k_write->err()) {

    $self->logger->debug("Update crossing ($crossing_id): failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref  = [{'Message' => "Crossing ($crossing_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub add_trialunit_treatment_runmode {

=pod add_trialunit_treatment_HELP_START
{
"OperationName": "Add treatment to trial unit",
"Description": "Add a treatment to a trialunit",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "trialunittreatment",
"SkippedField": ["TrialUnitId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='103' ParaName='TrialUnitTreatmentId' /><Info Message='TrialUnitTreatmentId (103) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '104','ParaName' : 'TrialUnitTreatmentId'}],'Info' : [{'Message' : 'TrialUnitTreatment (104) has been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TrialUnitId (123): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'TrialUnitId (123): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialUnitId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self            = shift;
  my $trialunit_id    = $self->param('id');
  my $query           = $self->query();
  my $treatment_id    = $query->param('TreatmentId');
  my $treatment_dt    = $query->param('TreatmentDateTime');
  my $treatment_note  = $query->param('TrialUnitTreatmentNote');

  my ($int_err, $int_err_msg) = check_integer_value({
                                                      'TrialUnitId' => $trialunit_id,
                                                      'TreatmentId' => $treatment_id
                                                    });
  if ($int_err) {
      $int_err_msg .= ' not integer.';
      return $self->_set_error($int_err_msg);
  }

  my $data_for_postrun_href;

  my $dbh_write = connect_kdb_write(1);
  eval {

    my $trialunit_existence = record_existence($dbh_write, 'trialunit', 'TrialUnitId', $trialunit_id);
    if (!$trialunit_existence) {
      my $errmsg = "TrialUnit ($trialunit_id) does not exist.";
      $data_for_postrun_href = $self->_set_error($errmsg);
      return 1;
    }

    my $treatment_existence = record_existence($dbh_write, 'treatment', 'TreatmentId', $treatment_id);
    if (!$treatment_existence) {
      my $errmsg = "Treatment ($treatment_id) does not exist.";
      $data_for_postrun_href = $self->_set_error($errmsg);
      return 1;
    }

    if (length($treatment_dt)) {
      my ($date_err, $date_href) = check_dt_href({'TreatmentDateTime' => $treatment_dt});
      if ($date_err) {
        $data_for_postrun_href = {};
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [$date_href]};
        return 1;
      }
    }

    my $sql = "";
    $sql .= "INSERT INTO trialunittreatment (TreatmentId, TrialUnitId, TreatmentDateTime, TrialUnitTreatmentNote) ";
    $sql .= "VALUES (?, ?, ?, ?)";
    my $sth = $dbh_write->prepare($sql);
    $sth->execute($treatment_id, $trialunit_id, $treatment_dt, $treatment_note);

    my $trialunit_treatment_id = $dbh_write->last_insert_id(undef, undef, 'trialunittreatment', 'TrialUnitTreatmentId');

    $dbh_write->commit;

    my $info_msg_aref  = [{'Message' => "TrialUnitTreatment ($trialunit_treatment_id) has been added successfully."}];
    my $return_id_aref = [{'Value' => "$trialunit_treatment_id", 'ParaName' => 'TrialUnitTreatmentId'}];

    $data_for_postrun_href->{'Error'}     = 0;
    $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                            'ReturnId' => $return_id_aref,
    };
    $data_for_postrun_href->{'ExtraData'} = 0;

    1;
  } or do {
    $self->logger->debug($@);
    eval {$dbh_write->rollback;};
    $data_for_postrun_href = $self->_set_error();
  };

  $dbh_write->disconnect;
  return $data_for_postrun_href;
}


sub get_trialunit_treatment_runmode {

=pod get_trialunit_treatment_HELP_START
{
"OperationName": "Get trial unit treatment",
"Description": "Get detailed information about association between trial unit and treatment specified by trialunittreatment id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='TrialUnitTreatment' /><TrialUnitTreatment TreatmentName='Treatment4TrialUnit_8074320' Notes='none' ItemId='' TrialUnitId='2' TrialUnitTreatmentId='7' TreatmentId='6' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'TrialUnitTreatment'}],'TrialUnitTreatment' : [{'TreatmentText' : 'Treatment4TrialUnit_8074320','TrialUnitId' : '2','TrialUnitTreatmentId' : '7','TreatmentId' : '6'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TrialUnitTreatmentId (3) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'TrialUnitTreatmentId (3) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialUnitTreatmentId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = $_[0];
  my $tu_treatment_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  my $tu_treatment_sql = "SELECT DISTINCT trialunit.TrialId ";
  $tu_treatment_sql   .= "FROM trialunittreatment LEFT JOIN trialunit ";
  $tu_treatment_sql   .= "ON trialunittreatment.TrialUnitId = trialunit.TrialUnitId ";
  $tu_treatment_sql   .= "WHERE TrialUnitTreatmentId=?";

  my ($r_trialunit_id_err, $trialunit_id) = read_cell($dbh, $tu_treatment_sql, [$tu_treatment_id]);

  if ($r_trialunit_id_err) {

    $self->logger->debug("Read trial id failed");
    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($trialunit_id) == 0) {

    my $err_msg = "TrialUnitTreatmentId ($tu_treatment_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'trial');

  my $sql      = "SELECT $perm_str AS UltimatePermission ";
  $sql        .= 'FROM trial ';
  $sql        .= 'WHERE TrialId=?';

  my ($read_err, $permission) = read_cell($dbh, $sql, [$trialunit_id]);
  $dbh->disconnect();

  if ( ($permission & $READ_PERM) != $READ_PERM ) {

    my $err_msg = "Trial ($trialunit_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql  = "SELECT trialunittreatment.*, treatment.TreatmentText ";
  $sql .= "FROM trialunittreatment LEFT JOIN treatment ON trialunittreatment.TreatmentId = treatment.TreatmentId ";
  $sql .= "WHERE trialunittreatment.TrialUnitTreatmentId=?";

  $self->logger->debug($sql);

  my ($read_tut_err, $read_tut_msg, $tut_data) = $self->list_trial_unit_treatment(1, $sql, [$tu_treatment_id]);

  if ($read_tut_err) {

    $self->logger->debug($read_tut_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'} = 0;
  $data_for_postrun_href->{'Data'}  = {'TrialUnitTreatment'  => $tut_data,
                                       'RecordMeta'         => [{'TagName' => 'TrialUnitTreatment'}],
  };

  return $data_for_postrun_href;
}

sub list_trial_unit_treatment {

  my $self              = $_[0];
  my $extra_attr_yes    = $_[1];
  my $sql               = $_[2];
  my $where_para_aref   = $_[3];

  my $err = 0;
  my $msg = '';

  my $data_aref = [];

  my $dbh = connect_kdb_read();

  ($err, $msg, $data_aref) = read_data($dbh, $sql, $where_para_aref);

  if ($err) {

    return ($err, $msg, []);
  }

  $dbh->disconnect();

  my $extra_attr_tunit_treatment_data = [];

  if ($extra_attr_yes) {

    my $perm_lookup  = {'0' => 'None',
                        '1' => 'Link',
                        '2' => 'Write',
                        '3' => 'Write/Link',
                        '4' => 'Read',
                        '5' => 'Read/Link',
                        '6' => 'Read/Write',
                        '7' => 'Read/Write/Link',
    };

    my $tu_treatment_id_aref = [];

    for my $row (@{$data_aref}) {

      push(@{$tu_treatment_id_aref}, $row->{'TrialUnitTreatmentId'});
    }

    my $chk_id_err        = 0;
    my $chk_id_msg        = '';
    my $used_id_href      = {};
    my $not_used_id_href  = {};

    if (scalar(@{$tu_treatment_id_aref}) > 0) {

      my $chk_table_aref = [{'TableName' => 'trialunittreatment', 'FieldName' => 'TrialUnitTreatmentId'}];

      ($chk_id_err, $chk_id_msg,
       $used_id_href, $not_used_id_href) = id_existence_bulk($dbh, $chk_table_aref, $tu_treatment_id_aref);

      if ($chk_id_err) {

        $self->logger->debug("Check id existence error: $chk_id_msg");
        $err = 1;
        $msg = $chk_id_msg;

        return ($err, $msg, []);
      }
    }

    for my $row (@{$data_aref}) {

      my $trial_unit_treatment_id   = $row->{'TrialUnitTreatmentId'};
      my $permission               = $row->{'UltimatePerm'};
      $row->{'UltimatePermission'} = $perm_lookup->{$permission};

      if ( ($permission & $READ_WRITE_PERM) == $READ_WRITE_PERM ) {

        $row->{'update'} = "update/trialunittreatment/$trial_unit_treatment_id";

        if ( $not_used_id_href->{$trial_unit_treatment_id} ) {

          $row->{'remove'} = "delete/trialunittreatment/$trial_unit_treatment_id";
        }
      }

      push(@{$extra_attr_tunit_treatment_data}, $row);
    }
  }
  else {

    $extra_attr_tunit_treatment_data = $data_aref;
  }

  return ($err, $msg, $extra_attr_tunit_treatment_data);
}

sub remove_trialunit_treatment_runmode {

=pod remove_trialunit_treatment_HELP_START
{
"OperationName": "Delete trial unit treatment",
"Description": "Delete association between trial unit and treatment specified by trialunittreatment id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='TrialUnitTreatment (103) has been removed successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'TrialUnitTreatment (104) has been removed successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TrialUnitTreatment (103) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'TrialUnitTreatment (103) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialUnitTreatment"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut
  my $self            = shift;
  my $trialunit_t_id  = $self->param('id');

  my ($int_err, $int_err_msg) = check_integer_value({
                                                      'TrialUnitTreatmentId' => $trialunit_t_id,
                                                    });
  if ($int_err) {
      $int_err_msg .= ' not integer.';
      return $self->_set_error($int_err_msg);
  }

  my $data_for_postrun_href;

  my $dbh_write = connect_kdb_write();
  eval {
    my $trialunit_t_existence = record_existence($dbh_write, 'trialunittreatment', 'TrialUnitTreatmentId', $trialunit_t_id);
    if (!$trialunit_t_existence) {
      my $errmsg = "TrialUnitTreatmentId ($trialunit_t_id) does not exist.";
      $data_for_postrun_href = $self->_set_error($errmsg);
      return 1;
    }

    my $sql = "";
    $sql .= 'DELETE FROM trialunittreatment ';
    $sql .= 'WHERE TrialUnitTreatmentId=?';
    my $sth = $dbh_write->prepare($sql);
    $sth->execute($trialunit_t_id);
    if ($dbh_write->err()) {
      $data_for_postrun_href = $self->_set_error();
      return 1;
    }

    $data_for_postrun_href = {};
    my $info_msg_aref = [{'Message' => "TrialUnitTreatment ($trialunit_t_id) has been removed successfully."}];
    $data_for_postrun_href->{'Error'}     = 0;
    $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
    $data_for_postrun_href->{'ExtraData'} = 0;
  };

  $dbh_write->disconnect;
  return $data_for_postrun_href;
}

sub update_trialunit_treatment_runmode {

=pod update_trialunit_treatment_HELP_START
{
"OperationName": "Update trial unit treatment",
"Description": "Update information about association between trial unit and treatment specified by trialunittreatment id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "trialunittreatment",
"SkippedField": ["TrialUnitId", "TreatmentId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='TrialUnitTreatment (109) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'TrialUnitTreatment (109) has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TrialUnitTreatment (103) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'TrialUnitTreatment (103) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialUnitTreatmentId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut
  my $self            = shift;
  my $trialunit_t_id  = $self->param('id');
  my $query           = $self->query();
  my $treatment_dt    = $query->param('TreatmentDateTime');
  my $treatment_note  = $query->param('TrialUnitTreatmentNote');

  my ($int_err, $int_err_msg) = check_integer_value({
                                                      'TrialUnitTreatmentId' => $trialunit_t_id,
                                                    });
  if ($int_err) {
      $int_err_msg .= ' not integer.';
      return $self->_set_error($int_err_msg);
  }

  my $data_for_postrun_href;

  my $dbh_write = connect_kdb_write(1);
  eval {
    my $trialunit_t_existence = record_existence($dbh_write, 'trialunittreatment', 'TrialUnitTreatmentId', $trialunit_t_id);
    if (!$trialunit_t_existence) {
      my $errmsg = "TrialUnitTreatmentId ($trialunit_t_id) does not exist.";
      $data_for_postrun_href = $self->_set_error($errmsg);
      return 1;
    }

    if (length($treatment_dt)) {
      my ($date_err, $date_href) = check_dt_href({'TreatmentDateTime' => $treatment_dt});
      if ($date_err) {
        $data_for_postrun_href = {};
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [$date_href]};
        return 1;
      }
    }

    my $sql = "";
    $sql .= 'UPDATE trialunittreatment SET ';
    $sql .= 'TreatmentDateTime=?, ';
    $sql .= 'TrialUnitTreatmentNote=? ';
    $sql .= 'WHERE TrialUnitTreatmentId=?';
    my $sth = $dbh_write->prepare($sql);
    $sth->execute($treatment_dt, $treatment_note, $trialunit_t_id);

    $dbh_write->commit;

    $data_for_postrun_href = {};
    my $info_msg_aref  = [{'Message' => "TrialUnitTreatment ($trialunit_t_id) has been updated successfully."}];
    $data_for_postrun_href->{'Error'}     = 0;
    $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref};
    $data_for_postrun_href->{'ExtraData'} = 0;

    1;

  } or do {
    $self->logger->debug($@);
    eval {$dbh_write->rollback;};
    $data_for_postrun_href = $self->_set_error();
  };

  $dbh_write->disconnect;
  return $data_for_postrun_href;
}

sub get_siteloc_dtd_file {

  my $dtd_path = $ENV{DOCUMENT_ROOT} . '/' . $DTD_PATH;

  return "${dtd_path}/siteloc.dtd";
}

sub get_trialloc_dtd_file {

  my $dtd_path = $ENV{DOCUMENT_ROOT} . '/' . $DTD_PATH;

  return "${dtd_path}/trialloc.dtd";
}

sub get_trialunit_loc_dtd_file {

  my $dtd_path = $ENV{DOCUMENT_ROOT} . '/' . $DTD_PATH;

  return "${dtd_path}/trialunitloc.dtd";
}

sub get_addtrialunit_dtd_file {

  my $dtd_path = $ENV{DOCUMENT_ROOT} . '/' . $DTD_PATH;

  return "${dtd_path}/addtrialunit_upload.dtd";
}

sub get_addtrialunit_bulk_dtd_file {

  my $dtd_path = $ENV{DOCUMENT_ROOT} . '/' . $DTD_PATH;

  return "${dtd_path}/addtrialunitbulk_upload.dtd";
}

sub get_trialgroupentry_dtd_file {

  my $dtd_path = $ENV{DOCUMENT_ROOT} . '/' . $DTD_PATH;

  return "${dtd_path}/trialgroupentry.dtd";
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

sub get_updatetrialunit_bulk_dtd_file {

  my $dtd_path = $ENV{DOCUMENT_ROOT} . '/' . $DTD_PATH;

  return "${dtd_path}/updatetrialunitbulk.dtd";
}

1;
