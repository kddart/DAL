#$Id$
#$Author$

# Copyright (c) 2024, Diversity Arrays Technology, All rights reserved.

# Author    : Puthick Hok
# Created   : 17/05/2014
# Modified  :
# Purpose   :
#
#

package KDDArT::DAL::Help;

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
use JSON::XS;


sub setup {

  my $self = shift;

  CGI::Session->name("HELP");

  __PACKAGE__->authen->init_config_parameters();
  __PACKAGE__->authen->check_login_runmodes();
  __PACKAGE__->authen->check_content_type_runmodes();
  __PACKAGE__->authen->check_rand_runmodes();
  __PACKAGE__->authen->count_session_request_runmodes();
  __PACKAGE__->authen->check_signature_runmodes();
  __PACKAGE__->authen->check_gadmin_runmodes();
  __PACKAGE__->authen->check_sign_upload_runmodes();

  $self->run_modes(
    'help'                              => 'help_runmode',
    'get_dal_error_info'                => 'get_dal_error_info_runmode',
    'list_dal_error_info'               => 'list_dal_error_info_runmode',
    'get_version'                       => 'get_version_runmode',
    'get_config'                        => 'get_config_runmode',
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

sub help_runmode {

=pod help_HELP_START
{
"OperationName": "Help",
"Description": "This interface is for DAL operation documentation.",
"AuthRequired": 0,
"GroupRequired": 0,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"HTTPParameter": [{"ParameterName": "operation", "Description": "DAL operation URI like 'add/genus' or 'get/genotype/:id'"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}],
"DALReturnedErrorCode": [{"ErrorId": 1}]
}
=cut

  my $self   = shift;
  my $query  = $self->query();

  my $operation = $query->param('operation');

  my $oper = $operation;

  my $data_for_postrun_href = {};

  my $dispatch_table_str = read_dispatch_table($CGI_INDEX_SCRIPT);

  $dispatch_table_str =~ s/:/_/g;
  my $dispatch_table;
  # content of this variable will be filled after the eval
  eval($dispatch_table_str);

  my $operation2app = {};

  my $i = 0;
  while ( $i < scalar(@{$dispatch_table->{'table'}}) ) {

    my $url_part     = $dispatch_table->{'table'}->[$i];
    my $pck_info_str = $dispatch_table->{'table'}->[$i+1]->{'app'};
    my $run_mode     = $dispatch_table->{'table'}->[$i+1]->{'rm'};

    $operation2app->{$url_part} = [$pck_info_str, $run_mode];

    $i += 2;
  }

  my $json_encoder = JSON::XS->new();

  #$self->logger->debug($json_encoder->encode($operation2app));

  if ( !(defined $operation2app->{$oper}) ) {

    my $err_msg = "Operation ($operation) not found. $oper";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg, 'ErrorId' => 1}]};

    return $data_for_postrun_href;
  }
  else {

    my $help_aref = [];

    my $perl_package_fname = $operation2app->{$oper}->[0];
    my $online_help_tag    = $operation2app->{$oper}->[1];

    $perl_package_fname  =~ s/__/\//g;
    $perl_package_fname  = "$main::kddart_base_dir/perl-lib/" . $perl_package_fname . '.pm';

    my $online_help_tag_start = '=pod ' . $online_help_tag . '_HELP_START';

    $self->logger->debug("DAL Perl Package file: $perl_package_fname");
    $self->logger->debug("HELP TAG: $online_help_tag_start");

    my $help_block = get_file_block($perl_package_fname, $online_help_tag_start, '=cut');

    if (length($help_block) == 0) {

      $self->logger->debug("No help text");

      my $err_msg = "Help is not available.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg, 'ErrorId' => 1}]};

      return $data_for_postrun_href;
    }

    my $help_href;

    eval { $help_href = $json_encoder->decode($help_block); };

    if ($help_href) {

      $help_href->{'URI'} = $operation;

      if (defined $help_href->{'KDDArTModule'}) {

        my $kddart_module = lc($help_href->{'KDDArTModule'});

        my $dbh;

        if ($kddart_module eq 'main') {

          $dbh = connect_kdb_read();
        }
        elsif ($kddart_module eq 'marker') {

          $dbh = connect_mdb_read();
        }
        elsif ($kddart_module eq 'environment') {

          $dbh = connect_gis_read();
        }
        else {

          $self->logger->debug("$kddart_module unknown");

          my $err_msg = "Help is not available.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg, 'ErrorId' => 1}]};

          return $data_for_postrun_href;
        }

        my $skip_field_aref = $help_href->{'SkippedField'};
        delete($help_href->{'SkippedField'});

        my $skip_lookup = {};

        for my $field_name (@{$skip_field_aref}) {

          $skip_lookup->{$field_name} = 1;
        }

        my $table_name = lc($help_href->{'KDDArTTable'});

        my ($sfield_err, $sfield_msg,
            $sfield_aref, $pkey) = get_static_field($dbh, $table_name);

        if ($sfield_err) {

          $self->logger->debug("$sfield_msg");

          my $err_msg = "Help is not available.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg, 'ErrorId' => 1}]};

          return $data_for_postrun_href;
        }

        my $help_field_aref = [];

        if (defined $help_href->{'HTTPParameter'}) {

          $help_field_aref = $help_href->{'HTTPParameter'};
        }

        for my $field_href (@{$sfield_aref}) {

          my $field_name = $field_href->{'Name'};

          if ( !(defined $skip_lookup->{$field_name}) ) {

            $field_href->{'Type'} = 'SCol';
            push(@{$help_field_aref}, $field_href);
          }
        }

        if (defined $help_href->{'KDDArTFactorTable'}) {

          my $factor_table = $help_href->{'KDDArTFactorTable'};

          my $sql = "SELECT FactorId, FactorName, FactorDataType, CanFactorHaveNull, ";
          $sql   .= "FactorDescription, FactorValueMaxLength ";
          $sql   .= "FROM factor ";
          $sql   .= "WHERE TableNameOfFactor='$factor_table'";

          my $vcol_data = $dbh->selectall_hashref($sql, 'FactorId');

          for my $vcol_id (keys(%{$vcol_data})) {

            my $vcol_href = {};
            my $vcol_param_name = "VCol_${vcol_id}";

            $vcol_href->{'Name'}          = $vcol_param_name;
            $vcol_href->{'Required'}      = $vcol_data->{$vcol_id}->{'CanFactorHaveNull'};
            $vcol_href->{'MaxLength'}     = $vcol_data->{$vcol_id}->{'FactorValueMaxLength'};
            $vcol_href->{'DataType'}      = $vcol_data->{$vcol_id}->{'FactorDataType'};

            my $vcol_name                 = $vcol_data->{$vcol_id}->{'FactorName'};
            my $vcol_desc                 = $vcol_data->{$vcol_id}->{'FactorDescription'};

            $vcol_href->{'Description'}   = "$vcol_name - $vcol_desc";
            $vcol_href->{'Type'}          = 'VCol';

            push(@{$help_field_aref}, $vcol_href);
          }
        }

        $dbh->disconnect();

        $help_href->{'HTTPParameter'} = $help_field_aref;
      }

      my $err_info_aref = $ERR_INFO_AREF;

      my $errid_lookup = {};

      for my $err_info_href (@{$err_info_aref}) {

        my $err_id  = $err_info_href->{'ErrorId'};

        $errid_lookup->{$err_id} = $err_info_href;
      }

      if (defined $help_href->{'DALReturnedErrorCode'}) {

        my $dal_return_err_id_aref = $help_href->{'DALReturnedErrorCode'};

        my $complete_dal_ret_err_id_aref = [];

        for my $err_id_href (@{$dal_return_err_id_aref}) {

          my $err_id = $err_id_href->{'ErrorId'};

          if ( defined $errid_lookup->{$err_id} ) {

            #$self->logger->debug("ErrorId: $err_id");

            my $err_msg = $errid_lookup->{$err_id}->{'Message'};
            $err_id_href->{'Message'} = $err_msg;

            push(@{$complete_dal_ret_err_id_aref}, $err_id_href);
          }
        }

        $help_href->{'DALReturnedErrorCode'} = $complete_dal_ret_err_id_aref;
      }

      if (defined $help_href->{'DTDFileNameForUploadXML'}) {

        my $dtd_file_name = $help_href->{'DTDFileNameForUploadXML'};

        my $url = reconstruct_server_url();

        my $dtd_url = "$url/$DTD_PATH/" . $dtd_file_name;
        $help_href->{'DTDURLForUploadXML'} = $dtd_url;

        my $dtd_full_path = $ENV{DOCUMENT_ROOT} . '/' . $DTD_PATH . '/' . $dtd_file_name;
        my $dtd_content   = read_file($dtd_full_path);

        $dtd_content =~ s/"/'/g;
        $dtd_content =~ s/\n//g;

        $help_href->{'DTDContentForUploadXML'} = $dtd_content;
      }

      if (defined $help_href->{'InputDataJSONSchema'}) {

        my $json_schema_file_name = $help_href->{'InputDataJSONSchema'};

        my $url = reconstruct_server_url();

        my $jschema_url = "$url/$JSON_SCHEMA_PATH/" . $json_schema_file_name;
        $help_href->{'InputDataJSONSchemaURL'} = $jschema_url;

        my $jschema_full_path = $ENV{DOCUMENT_ROOT} . '/' . $JSON_SCHEMA_PATH . '/' . $json_schema_file_name;
        my $jschema_content   = read_file($jschema_full_path);

        $jschema_content =~ s/"/'/g;
        $jschema_content =~ s/\n//g;

        $help_href->{'InputDataJSONSchema'} = $jschema_content;
      }

      $data_for_postrun_href->{'Error'}     = 0;
      $data_for_postrun_href->{'Data'}      = {'Help'       => [$help_href],
                                               'RecordMeta' => [{'TagName' => 'Help'}],
                                              };
      $data_for_postrun_href->{'ExtraData'} = 0;

      return $data_for_postrun_href;
    }
    else {

      $self->logger->debug("Cannot parse help text: $@");

      my $err_msg = "Help is not available.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg, 'ErrorId' => 1}]};

      return $data_for_postrun_href;
    }
  }
}

sub get_dal_error_info_runmode {

=pod get_dal_error_info_HELP_START
{
"OperationName": "Get DAL Error Code",
"Description": "This interface is for getting the details of a particular DAL error code.",
"AuthRequired": 0,
"GroupRequired": 0,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"URLParameter": [{"ParameterName": "id", "Description": "DAL error code id"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}],
"DALReturnedErrorCode": [{"ErrorId": 1}]
}
=cut

  my $self   = shift;
  my $query  = $self->query();

  my $err_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $err_info_aref = $ERR_INFO_AREF;

  my $errid_lookup = {};

  for my $err_info_href (@{$err_info_aref}) {

    my $err_id  = $err_info_href->{'ErrorId'};

    $errid_lookup->{$err_id} = $err_info_href;
  }

  if ( !(defined $errid_lookup->{$err_id}) ) {

    my $err_msg = "Error ($err_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg, 'ErrorId' => 1}]};

    return $data_for_postrun_href;
  }
  else {

    my $err_info_href = $errid_lookup->{$err_id};

    $data_for_postrun_href->{'Error'}     = 0;
    $data_for_postrun_href->{'Data'}      = {'ErrorInfo'  => [$err_info_href],
               'RecordMeta' => [{'TagName' => 'ErrorInfo'}],
    };
    $data_for_postrun_href->{'ExtraData'} = 0;

    return $data_for_postrun_href;
  }
}

sub list_dal_error_info_runmode {

=pod list_dal_error_info_HELP_START
{
"OperationName": "List all DAL Error Codes",
"Description": "This interface is for retrieving the details of all DAL error codes.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "",
"SuccessMessageJSON": "",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self   = shift;
  my $query  = $self->query();

  my $data_for_postrun_href = {};

  my $error_info_aref = $ERR_INFO_AREF;

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'ErrorInfo'  => $error_info_aref,
             'RecordMeta' => [{'TagName' => 'ErrorInfo'}],
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub get_version_runmode {

=pod get_version_HELP_START
{
"OperationName": "Get version",
"Description": "Get version information of the system.",
"AuthRequired": 0,
"GroupRequired": 0,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Version='2.2.4' Copyright='Copyright (c) 2011, Diversity Arrays Technology, All rights reserved.' About='Data Access Layer' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Version' : '2.2.4', 'Copyright' : 'Copyright (c) 2011, Diversity Arrays Technology, All rights reserved.', 'About' : 'Data Access Layer'}]}",
"ErrorMessageXML": [{"LoginRequired": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='You need to login first.' /></DATA>"}],
"ErrorMessageJSON": [{"LoginRequired": "{'Error' : [{'Message' : 'You need to login first.'}]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = shift;

  my $data_for_postrun_href = {};

  my $info_msg_aref = [{ 'Version'   => $DAL_VERSION,
                         'About'     => $DAL_ABOUT,
                         'Copyright' => $DAL_COPYRIGHT}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub get_config_runmode {

=pod get_config_HELP_START
{
"OperationName": "Get DAL configuration",
"Description": "Ask DAL to give its configuration.",
"AuthRequired": 0,
"GroupRequired": 0,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<DATA><Config WhoCanCreateGenotype='ANY' NurseryTypeListCSV=''/><StatInfo Unit='second' ServerElapsedTime='0.001'/><RecordMeta TagName='Config'/></DATA>",
"SuccessMessageJSON": "{'Config' : [{'NurseryTypeListCSV' : '','WhoCanCreateGenotype' : 'ANY'}],'RecordMeta' : [{'TagName' : 'Config'}],'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.001'}]}",
"ErrorMessageXML": [],
"ErrorMessageJSON": [],
"HTTPReturnedErrorCode": []
}
=cut

  my $self = shift;

  my $data_for_postrun_href = {};

  my $who_can_create_genotype  = $WHO_CAN_CREATE_GENOTYPE->{$ENV{DOCUMENT_ROOT}};
  my $nursery_type_list_csv    = '';

  if (defined $NURSERY_TYPE_LIST_CSV->{$ENV{DOCUMENT_ROOT}}) {

    $self->logger->debug("Nursery type list csv found");
    if (ref $NURSERY_TYPE_LIST_CSV->{$ENV{DOCUMENT_ROOT}} eq 'ARRAY') {

      $self->logger->debug("Nursery type list csv found as array");
      $nursery_type_list_csv = join(',', @{$NURSERY_TYPE_LIST_CSV->{$ENV{DOCUMENT_ROOT}}});
    }
    else {

      $self->logger->debug("Nursery type list csv found as scalar");
      $nursery_type_list_csv = $NURSERY_TYPE_LIST_CSV->{$ENV{DOCUMENT_ROOT}};
    }
  }
  else {

    $self->logger->debug("Nursery type list csv not found");
  }

  my $info_msg_aref = [{ 'NurseryTypeListCSV'       => $nursery_type_list_csv,
                         'WhoCanCreateGenotype'     => $who_can_create_genotype,
                       }];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Config'     => $info_msg_aref,
                                           'RecordMeta' => [{'TagName' => 'Config'}]
                                          };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

1;
