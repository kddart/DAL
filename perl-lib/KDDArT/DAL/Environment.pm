#$Id$
#$Author$

# Copyright (c) 2011, Diversity Arrays Technology, All rights reserved.

# Author    : Puthick Hok
# Created   : 02/06/2010
# Modified  :
# Purpose   : 
#          
#          

package KDDArT::DAL::Environment;

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
use File::Lockfile;
use Time::HiRes qw( tv_interval gettimeofday );
use Digest::MD5 qw(md5 md5_hex md5_base64);
use DateTime;
use Crypt::Random qw( makerandom );
use DateTime::Format::Pg;
use JSON::Validator;
use JSON::XS qw(decode_json);
use Text::CSV;
use File::Basename;
use File::Spec::Functions qw(catfile);
use File::Temp qw/ tempfile tempdir/;
use File::Copy::Recursive qw(dircopy);
use POSIX qw(ceil);
use List::Util qw(min);
use MIME::Base64 qw(encode_base64 decode_base64);
use File::Path;
use Data::Dumper;

sub setup {

  my $self = shift;

  CGI::Session->name("KDDArT_DAL_SESSID");

  __PACKAGE__->authen->init_config_parameters();
  __PACKAGE__->authen->check_login_runmodes(':all');
  __PACKAGE__->authen->check_content_type_runmodes(':all');
  __PACKAGE__->authen->check_rand_runmodes('add_layer_n_attrib',
                                           'register_device_gadmin',
                                           'map_device_param_gadmin',
                                           'update_device_param_mapping_gadmin',
                                           'log_environment_data',
                                           'add_layer',
                                           'add_layer_attribute',
                                           'add_layer_attribute_bulk',
                                           'import_layer_data_csv',
                                           'update_device_registration_gadmin',
                                           'del_device_registration_gadmin',
                                           'update_layer',
                                           'update_layer_attribute',
                                           'del_layer_gadmin',
                                           'del_layer_attribute_gadmin',
                                           'add_layer2d_data',
                                           'update_layer2d_data',
                                           'del_layer2d_data_gadmin',
                                           'add_layer_data',
                                           'update_layer_data_gadmin',
                                           'del_layer_data_gadmin',
      );
  __PACKAGE__->authen->count_session_request_runmodes(':all');
  __PACKAGE__->authen->check_signature_runmodes('register_device_gadmin',
                                                'map_device_param_gadmin',
                                                'update_device_param_mapping_gadmin',
                                                'add_layer',
                                                'add_layer_attribute',
                                                'update_device_registration_gadmin',
                                                'del_device_registration_gadmin',
                                                'update_layer',
                                                'update_layer_attribute',
                                                'del_layer_gadmin',
                                                'del_layer_attribute_gadmin',
                                                'add_layer2d_data',
                                                'update_layer2d_data',
                                                'del_layer2d_data_gadmin',
                                                'add_layer_data',
                                                'update_layer_data_gadmin',
                                                'del_layer_data_gadmin',
      );
  __PACKAGE__->authen->check_gadmin_runmodes('register_device_gadmin',
                                             'map_device_param_gadmin',
                                             'update_device_param_mapping_gadmin',
                                             'update_device_registration_gadmin',
                                             'del_device_registration_gadmin',
                                             'del_layer_gadmin',
                                             'del_layer_attribute_gadmin',
                                             'del_layer2d_data_gadmin',
                                             'update_layer_data_gadmin',
                                             'del_layer_data_gadmin',
      );
  __PACKAGE__->authen->check_sign_upload_runmodes('add_layer_n_attrib',
                                                  'log_environment_data',
                                                  'add_layer_attribute_bulk',
                                                  'import_layer_data_csv',
                                                  'add_tileset',
      );

  $self->run_modes(
    'add_layer'                            => 'add_layer_runmode',
    'add_layer_n_attrib'                   => 'add_layer_n_attrib_runmode',
    'register_device_gadmin'               => 'register_device_runmode',
    'map_device_param_gadmin'              => 'map_device_param_runmode',
    'update_device_param_mapping_gadmin'   => 'update_device_param_mapping_runmode',
    'log_environment_data'                 => 'log_environment_data_bulk_runmode',
    'list_layer_full'                      => 'list_layer_full_runmode',
    'get_layer'                            => 'get_layer_runmode',
    'list_parameter_mapping_full'          => 'list_parameter_mapping_full_runmode',
    'list_dev_registration_full'           => 'list_dev_registration_full_runmode',
    'list_layer_attribute'                 => 'list_layer_attribute_runmode',
    'get_parameter_mapping'                => 'get_parameter_mapping_runmode',
    'add_layer_attribute'                  => 'add_layer_attribute_runmode',
    'add_layer_attribute_bulk'             => 'add_layer_attribute_bulk_runmode',
    'export_layer_data_shape'              => 'export_layer_data_shape_runmode',
    'import_layer_data_csv'                => 'import_layer_data_csv_bulk_runmode',
    'update_device_registration_gadmin'    => 'update_device_registration_runmode',
    'del_device_registration_gadmin'       => 'del_device_registration_runmode',
    'update_layer'                         => 'update_layer_runmode',
    'update_layer_attribute'               => 'update_layer_attribute_runmode',
    'del_layer_gadmin'                     => 'del_layer_runmode',
    'del_layer_attribute_gadmin'           => 'del_layer_attribute_runmode',
    'add_layer2d_data'                     => 'add_layer2d_data_runmode',
    'update_layer2d_data'                  => 'update_layer2d_data_runmode',
    'list_layer2d_data_advanced'           => 'list_layer2d_data_runmode',
    'get_layer2d_data'                     => 'get_layer2d_data_runmode',
    'del_layer2d_data_gadmin'              => 'del_layer2d_data_runmode',
    'list_layer_data_advanced'             => 'list_layer_data_advanced_runmode',
    'add_layer_data'                       => 'add_layer_data_runmode',
    'update_layer_data_gadmin'             => 'update_layer_data_runmode',
    'del_layer_data_gadmin'                => 'del_layer_data_runmode',
    'add_tileset'                          => 'add_tileset_runmode',
    'get_tileset'                          => 'get_tileset_runmode',
    'update_tileset'                       => 'update_tileset_runmode',
    'get_tile'                             => 'get_tile_runmode',
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

  $XML::Checker::FAIL = sub { $self->xml_parse_failed(@_); };
}

sub add_layer_n_attrib_runmode {

=pod add_layer_n_attrib_HELP_START
{
"OperationName": "Add layer with attributes",
"Description": "Add a new layer with definition of attribute(s). It is extended version of add/layer call. This method does not import or creates any geo-referenced data.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "environment",
"KDDArTTable": "layer",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='2' ParaName='LayerId' /><Info Message='Layer (2) has been created successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '3','ParaName' : 'LayerId'}],'Info' : [{'Message' : 'Layer (3) has been created successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error geometrytype='TRIANGLE is unacceptable.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'geometrytype' : 'TRIANGLE is unacceptable.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "XML",
"UploadFileParameterName": "uploadfile",
"DTDFileNameForUploadXML": "layerattrib.dtd",
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_gis_read();

  my $skip_field = {'createuser'       => 1,
                    'createtime'       => 1,
                    'lastupdatetime'   => 1,
                    'lastupdateuser'   => 1,
                    'owngroupid'       => 1,
                    'srid'             => 1,
                   };

  my $field_name_translation = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'layer', $skip_field,
                                                                                $field_name_translation,
                                                                               );

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $parent_layer              = undef;

  if (defined $query->param('parent')) {

    if (length($query->param('parent')) > 0) {

      $parent_layer = $query->param('parent');
    }
  }

  my $layer_name                = $query->param('layername');

  my $layer_type                = $query->param('layertype');

  my $layer_mdata               = '';

  if (defined $query->param('layermetadata')) {

    $layer_mdata               = $query->param('layermetadata');
  }

  my $is_editable               = $query->param('iseditable');

  my $create_user               = $self->authen->user_id();
  my $create_time               = DateTime::Format::Pg->parse_datetime(DateTime->now());
  my $lupdate_user              = $self->authen->user_id();
  my $lupdate_time              = DateTime::Format::Pg->parse_datetime(DateTime->now());

  my $layer_srid                = 4326;

  if (defined $query->param('srid')) {

    $layer_srid = $query->param('srid');
  }

  my $geometry_type = $query->param('geometrytype');

  my $access_group              = $query->param('accessgroupid');
  my $own_perm                  = $query->param('owngroupperm');
  my $access_perm               = $query->param('accessgroupperm');
  my $other_perm                = $query->param('otherperm');

  my ($int_err, $int_msg_href) = check_integer_href( { 'srid'            => $layer_srid,
                                                       'accessgroupid'   => $access_group,
                                                       'owngroupperm'    => $own_perm,
                                                       'accessgroupperm' => $access_perm,
                                                       'otherperm'       => $other_perm,
                                                     } );

  if ($int_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$int_msg_href]};

    return $data_for_postrun_href;
  }

  my $layer_alias            = '';
  my $layer_description      = '';

  if ( length($query->param('alias')) > 0 ) { $layer_alias = $query->param('alias'); }

  if ( length($query->param('description')) > 0 ) { $layer_description = $query->param('description'); }

  my $ACCEPTABLE_GEOM_TYPE = { 'POINT'              => 1,
                               'LINESTRING'         => 1,
                               'POLYGON'            => 1,
                               'MULTIPOINT'         => 1,
                               'MULTILINESTRING'    => 1,
                               'MULTIPOLYGON'       => 1,
  };

  if (length($geometry_type) > 0) {

    if ( !($ACCEPTABLE_GEOM_TYPE->{uc($geometry_type)}) ) {

      my $err_msg = "$geometry_type is unacceptable.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'geometrytype' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $group_id = $self->authen->group_id();

  my $dbh_gis_write = connect_gis_write();

  my $layer_existence = record_existence($dbh_gis_write, 'layer', 'name', $layer_name);

  if ($layer_existence) {

    my $err_msg = "Layer name ($layer_name) already exists.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'name' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( defined $parent_layer ) {

    my $parent_layer_existence = record_existence($dbh_gis_write, 'layer', 'id', $parent_layer);

    if (!$parent_layer_existence) {

      my $err_msg = "Parent layer ($parent_layer) does not exist.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'parent' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $dbh_k_read = connect_kdb_read();

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

    my $err_msg = "AccessGroupPerm ($access_perm) is invalid.";
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

  my $attribute_xml_file = $self->authen->get_upload_file();
  my $attribute_dtd_file = $self->get_layer_attribute_dtd_file();

  add_dtd($attribute_dtd_file, $attribute_xml_file);

  $self->logger->debug("Attribute XML file: $attribute_xml_file");

  my $xml_checker_parser = new XML::Checker::Parser( Handlers => { } );

  eval {

    local $XML::Checker::FAIL = sub {

      my $code = shift;
      my $err_str = XML::Checker::error_string ($code, @_);
      $self->logger->debug("XML Parsing ERR: $code : $err_str");
      die $err_str;
    };
    $xml_checker_parser->parsefile($attribute_xml_file);
  };

  if ($@) {

    my $err_msg = $@;
    $self->logger->debug("Parsing XML error: $err_msg");
    my $user_err_msg = "Layer attribute xml file does not comply with its definition.\n";
    $user_err_msg   .= "Details: $err_msg";

    $data_for_postrun_href->{'Error'}       = 1;
    $data_for_postrun_href->{'Data'}        = {'Error' => [{'Message' => $user_err_msg}]};

    return $data_for_postrun_href;
  }

  my ($get_scol_err, $get_scol_msg, $scol_data, $pkey_data) = get_static_field($dbh_gis_write, 'layerattrib');

  if ($get_scol_err) {

    $self->logger->debug("Get static field info failed: $get_scol_msg");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $attribute_xml  = read_file($attribute_xml_file);
  my $attribute_aref = xml2arrayref($attribute_xml, 'layerattrib');

  my $colname_lookup = {};

  for my $layer_at (@{$attribute_aref}) {

    my $colsize_info          = {};
    my $chk_maxlen_field_href = {};

    for my $static_field (@{$scol_data}) {

      my $field_name  = $static_field->{'Name'};
      my $field_dtype = $static_field->{'DataType'};

      if (lc($field_dtype) eq 'text') {

        $colsize_info->{$field_name}           = $static_field->{'ColSize'};
        $chk_maxlen_field_href->{$field_name}  = $layer_at->{$field_name};
      }
    }

    my ($maxlen_err, $maxlen_msg) = check_maxlen($chk_maxlen_field_href, $colsize_info);

    if ($maxlen_err) {

      $maxlen_msg .= 'longer than its maximum length';

      $data_for_postrun_href->{'Error'}       = 1;
      $data_for_postrun_href->{'Data'}        = {'Error' => [{'Message' => $maxlen_msg}]};

      return $data_for_postrun_href;
    }

    my $unit_id = $layer_at->{'unitid'};

    if (!record_existence($dbh_k_read, 'generalunit', 'UnitId', $unit_id)) {

      my $err_msg = "unidid ($unit_id): not found.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $colname = $layer_at->{'colname'};

    if ( $colname !~ /^[a-zA-Z0-9_]+$/ ) {

      my $err_msg = "colname ($colname): invalid character.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if ($colname_lookup->{lc($colname)}) {

      my $err_msg = "colname ($colname): duplicate.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    else {

      $colname_lookup->{lc($colname)} = 1;
    }
  }

  $dbh_k_read->disconnect();

  my $sql = '';
  $sql   .= 'INSERT INTO layer ';
  $sql   .= '(parent, name, alias, layertype, layermetadata, iseditable, createuser, createtime, ';
  $sql   .= 'lastupdateuser, lastupdatetime, srid, geometrytype, description, owngroupid, ';
  $sql   .= 'accessgroupid, owngroupperm, accessgroupperm, otherperm) ';
  $sql   .= 'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';

  my $sth = $dbh_gis_write->prepare($sql);
  $sth->execute($parent_layer, $layer_name, $layer_alias, $layer_type, $layer_mdata, $is_editable,
                $create_user, $create_time, $lupdate_user, $lupdate_time, $layer_srid, $geometry_type,
                $layer_description, $group_id, $access_group, $own_perm, $access_perm, $other_perm);

  my $layer_id = '';

  if (!$dbh_gis_write->err()) {

    $layer_id = $dbh_gis_write->last_insert_id(undef, undef, 'layer', 'ID');
    $self->logger->debug("Layer Id: $layer_id");

    for my $layer_at (@{$attribute_aref}) {

      $sql  = 'INSERT INTO layerattrib ';
      $sql .= '(unitid, layer, colname, coltype, colsize, validation, colunits) ';
      $sql .= 'VALUES (?, ?, ?, ?, ?, ?, ?)';

      $sth = $dbh_gis_write->prepare($sql);
      $sth->execute($layer_at->{'unitid'}, $layer_id, lc($layer_at->{'colname'}),
                    $layer_at->{'coltype'}, $layer_at->{'colsize'},
                    $layer_at->{'validation'}, $layer_at->{'colunits'},
                   );

      if ($dbh_gis_write->err()) {

        $self->logger->debug('INSERT Data to layerattrib table failed');

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

        return $data_for_postrun_href;
      }
      $sth->finish();
    }

    if (uc($layer_type) eq '2D' ) {

      my ($err_status, $postrun_href) = $self->mk_2d_layer_data_table($dbh_gis_write,
                                                                      $geometry_type,
                                                                      $layer_srid,
                                                                      $layer_id
                                                                     );

      if ($err_status) {

        return $postrun_href;
      }
    }
    else {

      my %geo_data_tables = ("layer${layer_id}"        => 'layern',
                             "layer${layer_id}attrib"  => 'layernattrib',
          );

      my %geom_column = ("layer${layer_id}" => 'geometry');

      my ($err_status, $postrun_href) = $self->mk_normal_layer_data_tables($dbh_gis_write,
                                                                           $geometry_type,
                                                                           $layer_srid,
                                                                           \%geo_data_tables,
                                                                           \%geom_column
                                                                          );

      if ($err_status) {

        return $postrun_href;
      }
    }
  }
  else {

    $self->logger->debug("Insert record into layer table failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();
  $dbh_gis_write->disconnect();

  my $info_msg_aref  = [{'Message' => "Layer ($layer_id) has been created successfully."}];
  my $return_id_aref = [{'Value' => "$layer_id", 'ParaName' => 'LayerId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub add_layer_runmode {

=pod add_layer_HELP_START
{
"OperationName": "Add layer",
"Description": "Create a new GIS layer definition in the system. This method does not import or creates any geo-referenced data.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "environment",
"KDDArTTable": "layer",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='4' ParaName='id' /><Info Message='Layer (4) has been created successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '5','ParaName' : 'id'}], 'Info' : [{'Message' : 'Layer (5) has been created successfully.'}]}",
"ErrorMessageXML": [{"NameAlreadyExists": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error name='Layer name (Test) already exists.' /></DATA>"}],
"ErrorMessageJSON": [{"NameAlreadyExists": "{'Error' : [{'name' : 'Layer name (Test) already exists.'}]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_gis_read();

  my $skip_field = {'createuser'       => 1,
                    'createtime'       => 1,
                    'lastupdatetime'   => 1,
                    'lastupdateuser'   => 1,
                    'owngroupid'       => 1,
                    'srid'             => 1,
                   };

  my $field_name_translation = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'layer', $skip_field,
                                                                                $field_name_translation,
                                                                               );

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $parent_layer              = undef;

  if (defined $query->param('parent')) {

    if (length($query->param('parent')) > 0) {

      $parent_layer = $query->param('parent');
    }
  }

  my $layer_name                = $query->param('layername');
  my $layer_type                = $query->param('layertype');

  my $layer_mdata               = '';

  if (defined $query->param('layermetadata')) {

    $layer_mdata               = $query->param('layermetadata');
  }

  my $is_editable               = $query->param('iseditable');

  my $create_user               = $self->authen->user_id();
  my $create_time               = DateTime::Format::Pg->parse_datetime(DateTime->now());
  my $lupdate_user              = $self->authen->user_id();
  my $lupdate_time              = DateTime::Format::Pg->parse_datetime(DateTime->now());

  my $layer_srid                = 4326;

  if (defined $query->param('srid')) {

    $layer_srid = $query->param('srid');
  }

  my $geometry_type             = $query->param('geometrytype');
  my $access_group              = $query->param('accessgroupid');
  my $own_perm                  = $query->param('owngroupperm');
  my $access_perm               = $query->param('accessgroupperm');
  my $other_perm                = $query->param('otherperm');

  my ($int_err, $int_msg_href) = check_integer_href( { 'srid'            => $layer_srid,
                                                       'accessgroupid'   => $access_group,
                                                       'owngroupperm'    => $own_perm,
                                                       'accessgroupperm' => $access_perm,
                                                       'otherperm'       => $other_perm,
                                                     } );

  if ($int_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$int_msg_href]};

    return $data_for_postrun_href;
  }

  my $layer_alias            = '';
  my $layer_description      = '';

  if ( length($query->param('alias')) > 0 ) { $layer_alias = $query->param('alias'); }

  if ( length($query->param('description')) > 0 ) { $layer_description = $query->param('description'); }

  my $ACCEPTABLE_GEOM_TYPE = { 'POINT'              => 1,
                               'LINESTRING'         => 1,
                               'POLYGON'            => 1,
                               'MULTIPOINT'         => 1,
                               'MULTILINESTRING'    => 1,
                               'MULTIPOLYGON'       => 1,
  };

  if (length($geometry_type) > 0) {

    if ( !($ACCEPTABLE_GEOM_TYPE->{uc($geometry_type)}) ) {

      my $err_msg = "$geometry_type is unacceptable.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'geometrytype' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $dbh_gis_write = connect_gis_write();

  my $layer_existence = record_existence($dbh_gis_write, 'layer', 'name', $layer_name);

  if ($layer_existence) {

    my $err_msg = "Layer name ($layer_name) already exists.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'name' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( defined $parent_layer ) {

    my $parent_layer_existence = record_existence($dbh_gis_write, 'layer', 'id', $parent_layer);

    if (!$parent_layer_existence) {

      my $err_msg = "Parent layer ($parent_layer) does not exist.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'parent' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my ($is_link_ok, $trouble_player_id_aref) = check_permission($dbh_gis_write, 'layer', 'id', [$parent_layer],
                                                                 $group_id, $gadmin_status, $READ_LINK_PERM);

    if (!$is_link_ok) {

      my $err_msg = "Parent layer ($parent_layer) permission denied.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'parent' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $dbh_k_read = connect_kdb_read();

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

    my $err_msg = "AccessGroupPerm ($access_perm) is invalid.";
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

  my $sql = '';
  $sql   .= 'INSERT INTO layer ';
  $sql   .= '(parent, name, alias, layertype, layermetadata, iseditable, createuser, createtime, ';
  $sql   .= 'lastupdateuser, lastupdatetime, srid, geometrytype, description, owngroupid, ';
  $sql   .= 'accessgroupid, owngroupperm, accessgroupperm, otherperm) ';
  $sql   .= 'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';

  my $sth = $dbh_gis_write->prepare($sql);
  $sth->execute($parent_layer, $layer_name, $layer_alias, $layer_type, $layer_mdata, $is_editable,
                $create_user, $create_time, $lupdate_user, $lupdate_time, $layer_srid, $geometry_type,
                $layer_description, $group_id, $access_group, $own_perm, $access_perm, $other_perm);

  my $layer_id = '';

  if (!$dbh_gis_write->err()) {

    $layer_id = $dbh_gis_write->last_insert_id(undef, undef, 'layer', 'ID');
    $self->logger->debug("Layer Id: $layer_id");

    # add transfered attributes from the parent layer
    if (uc($layer_type) eq 'LAYERTILES') {
      
      my ($add_tileset_err, $add_tileset_msg) = $self->create_tileset($layer_id, $query);
      
      if ($add_tileset_err) {
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $add_tileset_msg}]};
        return $data_for_postrun_href;
      }
    }
    
    if (uc($layer_type) eq '2D' ) {

      my ($err_status, $postrun_href) = $self->mk_2d_layer_data_table($dbh_gis_write,
                                                                      $geometry_type,
                                                                      $layer_srid,
                                                                      $layer_id
                                                                     );

      if ($err_status) {

        return $postrun_href;
      }
    }
    else {

      my %geo_data_tables = ("layer${layer_id}"        => 'layern',
                             "layer${layer_id}attrib"  => 'layernattrib',
          );

      my %geom_column = ("layer${layer_id}" => 'geometry');

      my ($err_status, $postrun_href) = $self->mk_normal_layer_data_tables($dbh_gis_write,
                                                                           $geometry_type,
                                                                           $layer_srid,
                                                                           \%geo_data_tables,
                                                                           \%geom_column
          );

      if ($err_status) {

        return $postrun_href;
      }
    }
  }
  else {

    $self->logger->debug("Add layer record failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();
  $dbh_gis_write->disconnect();

  my $info_msg_aref  = [{'Message' => "Layer ($layer_id) has been created successfully."}];
  my $return_id_aref = [{'Value' => "$layer_id", 'ParaName' => 'id'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub get_environment_data_dtd_file {

  my $dtd_path = $ENV{DOCUMENT_ROOT} . '/' . $DTD_PATH;

  return "${dtd_path}/enviro_data.dtd";
}

sub register_device_runmode {

=pod register_device_gadmin_HELP_START
{
"OperationName": "Add device registration",
"Description": "Register a new device in the system. Device can be any measuring instrument or sensor later used to obtain some data.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "deviceregister",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='8' ParaName='DeviceRegisterId' /><Info Message='Device (8) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '9', 'ParaName' : 'DeviceRegisterId'}], 'Info' : [{'Message' : 'Device (9) has been added successfully.'}]}",
"ErrorMessageXML": [{"MissingParameter": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error DeviceTypeId='DeviceTypeId is missing.' /></DATA>"}],
"ErrorMessageJSON": [{"MissingParameter": "{'Error' : [{'DeviceTypeId' : 'DeviceTypeId is missing.'}]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};
  my $device_err_aref = [];
  my $device_err = 0;

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {};

  my $field_name_translation = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'deviceregister', $skip_field,
                                                                                $field_name_translation,
                                                                               );

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $device_id      = $query->param('DeviceId');
  my $device_type_id = $query->param('DeviceTypeId');

  $device_id = lc($device_id);

  if ($device_id =~ /[\/|\\]/) {

    my $err_msg = "DeviceId cannot have slash (/) or backslash (\\).";

    push(@{$device_err_aref}, {'DeviceId' => $err_msg});
    $device_err = 1;
  }

  my $note = undef;
  my $lng  = undef;
  my $lat  = undef;
  my $conf = undef;

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength, FactorValidRuleErrMsg, FactorValidRule  ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='deviceregisterfactor'";

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

  if (length($query->param('DeviceNote')) > 0) { $note = $query->param('DeviceNote'); }

  if (length($query->param('Longitude')) > 0) { $lng = $query->param('Longitude'); }

  if (length($query->param('Latitude')) > 0) { $lat = $query->param('Latitude'); }

  if (length($query->param('DeviceConf')) > 0) { $conf = $query->param('DeviceConf'); }

  my $dbh_write = connect_kdb_write();

  if ( !type_existence($dbh_write, 'deviceregister', $device_type_id) ) {

    my $err_msg = "DeviceTypeId ($device_type_id): not found or inactive.";

    push(@{$device_err_aref}, {'DeviceTypeId' => $err_msg});
    $device_err = 1;
  }

  my $dev_exist_status = record_existence($dbh_write, 'deviceregister', 'DeviceId', $device_id);

  if ($dev_exist_status) {

    my $err_msg = "Device ($device_id) already exists.";

    push(@{$device_err_aref}, {'Message' => $err_msg});
    $device_err = 1;
  }

  my ($vcol_error, $vcol_error_aref) = validate_all_factor_input($pre_validate_vcol);

  if ($vcol_error) {
    push(@{$device_err_aref}, @{$vcol_error_aref});
    $device_err = 1;
  }

  if ($device_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => $device_err_aref};
    return $data_for_postrun_href;

  }

  $sql  = 'INSERT INTO deviceregister SET ';
  $sql    .= 'DeviceTypeId = ?, ';
  $sql    .= 'DeviceId = ?, ';
  $sql    .= 'DeviceNote = ?, ';
  $sql    .= 'Latitude = ?, ';
  $sql    .= 'Longitude = ?, ';
  $sql    .= 'DeviceConf = ?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($device_type_id, $device_id, $note, $lat, $lng, $conf);

  my $device_reg_id = -1;
  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  else {

    $device_reg_id = $dbh_write->last_insert_id(undef, undef, 'deviceregister', 'DeviceRegisterId');
  }

  $sth->finish();

  for my $vcol_id (keys(%{$vcol_data})) {

    my $vcol_value = $query->param('VCol_' . "$vcol_id");

    if (length($vcol_value) > 0) {

      $sql  = 'INSERT INTO deviceregisterfactor SET ';
      $sql .= 'DeviceRegisterId=?, ';
      $sql .= 'FactorId=?, ';
      $sql .= 'FactorValue=?';

      my $vcol_sth = $dbh_write->prepare($sql);
      $vcol_sth->execute($device_reg_id, $vcol_id, $vcol_value);

      if ($dbh_write->err()) {

        $self->logger->debug("Add vcol $vcol_id - $vcol_value : failed");
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

        return $data_for_postrun_href;
      }
      $vcol_sth->finish();
    }
  }

  $dbh_write->disconnect();

  my $info_msg_aref  = [{'Message' => "Device ($device_reg_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$device_reg_id", 'ParaName' => 'DeviceRegisterId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_device_registration_runmode {

=pod update_device_registration_gadmin_HELP_START
{
"OperationName": "Update device",
"Description": "Update information about registered device specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "deviceregister",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Device registration (8) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Device registration (8) has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='DeviceRegisterId (10): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'DeviceRegisterId (10): not found.' }]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing DeviceRegisterId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self   = shift;
  my $reg_id = $self->param('id');
  my $query  = $self->query();

  my $data_for_postrun_href = {};
  my $device_err_aref = [];
  my $device_err = 0;


  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {};

  my $field_name_translation = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'deviceregister', $skip_field,
                                                                                $field_name_translation,
                                                                               );

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $device_id      = $query->param('DeviceId');
  my $device_type_id = $query->param('DeviceTypeId');

  my $dbh_write = connect_kdb_write();

  my $reg_exist = record_existence($dbh_write, 'deviceregister', 'DeviceRegisterId', $reg_id);

  if (!$reg_exist) {

    my $err_msg = "DeviceRegisterId ($reg_id): not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $device_id = lc($device_id);

  if ($device_id =~ /[\/|\\]/) {

    my $err_msg = "DeviceId cannot have slash (/) or backslash (\\).";

    push(@{$device_err_aref}, {'DeviceId' => $err_msg});
    $device_err = 1;
  }

  if ( !type_existence($dbh_write, 'deviceregister', $device_type_id) ) {

    my $err_msg = "DeviceTypeId ($device_type_id): not found or inactive.";

    push(@{$device_err_aref}, {'DeviceTypeId' => $err_msg});
    $device_err = 1;
  }

  my $chk_dev_id_sql = 'SELECT DeviceRegisterId FROM deviceregister ';
  $chk_dev_id_sql   .= 'WHERE DeviceId=? AND DeviceRegisterId<>?';

  my ($chk_dev_id_err, $db_dev_id) = read_cell($dbh_write, $chk_dev_id_sql,
                                               [$device_id, $reg_id]);

  if ($chk_dev_id_err) {

    $self->logger->debug("Check device id uniqueness failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  if (length($db_dev_id) > 0) {

    my $err_msg = "DeviceId ($device_id): already exists.";

    push(@{$device_err_aref}, {'Message' => $err_msg});
    $device_err = 1;
  }

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength, FactorValidRuleErrMsg, FactorValidRule  ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='deviceregisterfactor'";

  my $vcol_data = $dbh_write->selectall_hashref($sql, 'FactorId');

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

  my ($vcol_error, $vcol_error_aref) = validate_all_factor_input($pre_validate_vcol);

  if ($vcol_error) {
    push(@{$device_err_aref}, @{$vcol_error_aref});
    $device_err = 1;
  }

  if ($device_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => $device_err_aref};
    return $data_for_postrun_href;

  }


  my $read_device_sql  = 'SELECT DeviceNote, Longitude, Latitude, DeviceConf ';
  $read_device_sql    .= 'FROM deviceregister WHERE DeviceRegisterId=? ';

  my ($r_df_val_err, $r_df_val_msg, $device_df_val_data) = read_data($dbh_write, $read_device_sql, [$reg_id]);


  if ($r_df_val_err) {

    $self->logger->debug("Retrieve device default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $note  = undef;
  my $lng   = undef;
  my $lat   = undef;
  my $conf  = undef;

  my $nb_df_val_rec    =  scalar(@{$device_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve device default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $note     = $device_df_val_data->[0]->{'DeviceNote'};
  $lng      = $device_df_val_data->[0]->{'Longitude'};
  $lat      = $device_df_val_data->[0]->{'Latitude'};
  $conf     = $device_df_val_data->[0]->{'DeviceConf'};

  if (length($note) == 0) {

    $note = undef;
  }

  if (length($lng) == 0) {

    $lng = undef;
  }

  if (length($lat) == 0) {

    $lat = undef;
  }

  if (length($conf) == 0) {

    $conf = undef;
  }

  if (defined $query->param('DeviceNote')) {

    if (length($query->param('DeviceNote')) > 0) {

      $note = $query->param('DeviceNote');
    }
    else {

      $note = undef;
    }
  }

  if (defined $query->param('Longitude')) {

    if (length($query->param('Longitude')) > 0) {

      $lng = $query->param('Longitude');
    }
    else {

      $lng = undef;
    }
  }

  if (defined $query->param('Latitude')) {

    if (length($query->param('Latitude')) > 0) {

      $lat = $query->param('Latitude');
    }
    else {

      $lat = undef;
    }
  }

  if (defined $query->param('DeviceConf')) {

    if (length($query->param('DeviceConf')) > 0) {

      $conf = $query->param('DeviceConf');
    }
    else {

      $conf = undef;
    }
  }

  my $sql  = 'UPDATE deviceregister SET ';
  $sql    .= 'DeviceId = ?, ';
  $sql    .= 'DeviceTypeId = ?, ';
  $sql    .= 'DeviceNote = ?, ';
  $sql    .= 'Latitude = ?, ';
  $sql    .= 'Longitude = ?, ';
  $sql    .= 'DeviceConf = ? ';
  $sql    .= 'WHERE DeviceRegisterId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($device_id, $device_type_id, $note, $lat, $lng, $conf, $reg_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  for my $vcol_id (keys(%{$vcol_data})) {

    if (defined $query->param('VCol_' . "$vcol_id")) {

      my $factor_value = $query->param('VCol_' . "$vcol_id");

      my ($vcol_err, $vcol_msg) = update_factor_value($dbh_write, $vcol_id, $factor_value, 'deviceregisterfactor', 'DeviceRegisterId', $reg_id);

      if ($vcol_err) {

        $self->logger->debug("VCol_" . "$vcol_id => $vcol_msg" );

        push(@{$device_err_aref}, {'VCol_' . "$vcol_id" => $vcol_msg});

        $device_err = 1;
      }
    }
  }
  
  $dbh_write->disconnect();

  if ($device_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => $device_err_aref};
    return $data_for_postrun_href;

  }


  my $info_msg_aref = [{'Message' => "Device registration ($reg_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub map_device_param_runmode {

=pod map_device_param_gadmin_HELP_START
{
"OperationName": "Map device parameter",
"Description": "Map device or sensor to particular attribute defined for a GIS layer. Device can be mapped to one or more attributes and/or layers indicating where the data are coming from.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "environment",
"KDDArTTable": "datadevice",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info deviceparamname='temperature' deviceid='autotest-wst01' layerid='7' attributeid='12' Message='Device paramater (temperature) on device (autotest-wst01) is mapped to an attribute (12) on layer (7).' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'deviceid' : 'autotest-wst01','deviceparamname' : 'humidity','Message' : 'Device paramater (humidity) on device (autotest-wst01) is mapped to an attribute (13) on layer (7).','layerid' : '7','attributeid' : '13'}]}",
"ErrorMessageXML": [{"MissingParameter": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error layerattrib='layerattrib is missing.' active='active is missing.' /></DATA>"}],
"ErrorMessageJSON": [{"MissingParameter": "{'Error' : [{'layerattrib' : 'layerattrib is missing.', 'active' : 'active is missing.'}]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $device_id         = $query->param('deviceid');
  my $attribute_id      = $query->param('layerattrib');
  my $device_param_name = $query->param('deviceparam');
  my $active            = $query->param('active');

  my ($missing_err, $missing_href) = check_missing_href( {'deviceid'      => $device_id,
                                                          'layerattrib'   => $attribute_id,
                                                          'deviceparam'   => $device_param_name,
                                                          'active'        => $active,
                                                         } );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  if (!($active =~ /[0|1]/)) {

    my $err_msg = "active ($active) can be either 1 or 0 only.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'active' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $device_param_name = lc($device_param_name);

  my $dbh_k_read = connect_kdb_read();

  my $dev_exist_stat = record_existence($dbh_k_read, 'deviceregister', 'DeviceId', $device_id);

  if (!$dev_exist_stat) {

    my $err_msg = "DeviceId ($device_id) does not exits.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'DeviceId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_gis_write = connect_gis_write();

  my $attrib_exist_stat = record_existence($dbh_gis_write, 'layerattrib', 'id', $attribute_id);

  if (!$attrib_exist_stat) {

    my $err_msg = "layerattrib ($attribute_id) does not exits.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'layerattrib' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $layer_id = read_cell_value($dbh_gis_write, 'layerattrib', 'layer', 'id', $attribute_id);

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 1, $gadmin_status);

  my $effective_perm = read_cell_value($dbh_gis_write, 'layer', $perm_str, 'id', $layer_id);

  $self->logger->debug("Effectiver permission: $effective_perm");

  if (($effective_perm & $LINK_PERM) != $LINK_PERM) {

    my $err_msg = "Permission denied: layer ($layer_id).";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $layertype = read_cell_value($dbh_gis_write, 'layer', 'layertype', 'id', $layer_id);

  if (uc($layertype) eq '2D') {

    my $err_msg = "Layer ($layer_id) is a 2D layer.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $geometry_type = read_cell_value($dbh_gis_write, 'layer', 'geometrytype', 'id', $layer_id);

  if (length($geometry_type) > 0) {

    if (uc($geometry_type) ne 'POINT') {

      my $err_msg = "Layer ($layer_id) is not a POINT layer.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $msg = "(parameter name, device id)  (layer attribute id, layer id):\n";
  $msg   .= "($device_param_name, $device_id) ";
  $msg   .= "($attribute_id, $layer_id)";

  my $sql = '';
  $sql   .= 'SELECT deviceid FROM datadevice ';
  $sql   .= 'WHERE deviceid=? AND layerattrib=? AND deviceparam=? ';
  $sql   .= 'LIMIT 1';

  $self->logger->debug("SQL: $sql");

  my $sth = $dbh_gis_write->prepare($sql);
  $sth->execute($device_id, $attribute_id, $device_param_name);
  my $db_device_id;
  $sth->bind_col(1, \$db_device_id);
  $sth->fetch();
  $sth->finish();

  if (length($db_device_id) > 0) {

    my $err_msg = "$msg already exists.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql    = 'INSERT INTO datadevice ( ';
  $sql   .= 'deviceid, layerattrib, deviceparam, active ) ';
  $sql   .= 'VALUES ( ?, ?, ?, ? )';

  $sth = $dbh_gis_write->prepare($sql);
  $sth->execute($device_id, $attribute_id, $device_param_name, $active);

  if ($dbh_gis_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $dbh_gis_write->disconnect();
  $dbh_k_read->disconnect();

  $msg    = "Device paramater ($device_param_name) on device ($device_id) is mapped to ";
  $msg   .= "an attribute ($attribute_id) on layer ($layer_id).";

  my $info_msg_aref = [{'deviceparamname' => $device_param_name,
                        'deviceid'        => $device_id,
                        'attributeid'     => $attribute_id,
                        'layerid'         => $layer_id,
                        'Message'         => $msg,
                       }];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_device_param_mapping_runmode {

=pod update_device_param_mapping_gadmin_HELP_START
{
"OperationName": "Update parameter mapping",
"Description": "Update parameter mapping to the GIS attribute and the specified device id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "environment",
"KDDArTTable": "datadevice",
"SkippedField": ["layerattrib", "deviceid", "deviceparam"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info DeviceParamName='humidity' DeviceId='autotest-wst01' Message='Device paramater map (autotest-wst01, humidity) has been updated.' AttributeId='16' LayerId='8' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'DeviceParamName' : 'humidity', 'Message' : 'Device paramater map (autotest-wst01, humidity) has been updated.', 'DeviceId' : 'autotest-wst01', 'LayerId' : '8', 'AttributeId' : '18'}]}",
"ErrorMessageXML": [{"MissingParameter": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error active='active is missing.' /></DATA>"}],
"ErrorMessageJSON": [{"MissingParameter": "{'Error' : [{'active' : 'active is missing.'}]}"}],
"URLParameter": [{"ParameterName": "devid", "Description": "DeviceId"}, {"ParameterName": "para", "Description": "Parameter name"}, {"ParameterName": "atid", "Description": "Attribute id"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $cur_dev_id = $self->param('devid');
  my $cur_para   = $self->param('para');
  my $cur_at_id  = $self->param('atid');

  my $device_id         = $query->param('deviceid');
  my $attribute_id      = $query->param('layerattrib');
  my $device_param_name = $query->param('deviceparam');
  my $active            = $query->param('active');

  my ($missing_err, $missing_href) = check_missing_href( {'active' => $active} );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  if (!($active =~ /[0|1]/)) {

    my $err_msg = "active ($active) can be either 1 or 0 only.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'active' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $device_param_name = lc($device_param_name);

  my $dbh_k_read = connect_kdb_read();

  my $dev_exist_stat = record_existence($dbh_k_read, 'deviceregister', 'DeviceId', $device_id);

  if (!$dev_exist_stat) {

    my $err_msg = "deviceid ($device_id) does not exits.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_gis_write = connect_gis_write();

  my $attrib_exist_stat = record_existence($dbh_gis_write, 'layerattrib', 'id', $attribute_id);

  if (!$attrib_exist_stat) {

    my $err_msg = "layerattrib ($attribute_id) does not exits.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $layer_id = read_cell_value($dbh_gis_write, 'layerattrib', 'layer', 'id', $attribute_id);

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 1, $gadmin_status);

  my $effective_perm = read_cell_value($dbh_gis_write, 'layer', $perm_str, 'id', $layer_id);

  $self->logger->debug("Effectiver permission: $effective_perm");

  if (($effective_perm & $LINK_PERM) != $LINK_PERM) {

    my $err_msg = "Permission denied: layer ($layer_id).";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $read_dv_p_m_sql     =   'SELECT layertype, geometrytype ';
     $read_dv_p_m_sql    .=   'FROM layer WHERE id=? ';

  my ($r_df_val_err, $r_df_val_msg, $dv_p_m_df_val_data) = read_data($dbh_gis_write, $read_dv_p_m_sql, [$layer_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve device param mapping default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $layertype          =   undef;
  my $geometry_type      =   undef;

  my $nb_df_val_rec    =  scalar(@{$dv_p_m_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve device param mapping default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $layertype          =   $dv_p_m_df_val_data->[0]->{'layertype'};
  $geometry_type      =   $dv_p_m_df_val_data->[0]->{'geometrytype'};


  if (uc($layertype) eq '2D') {

    my $err_msg = "Layer ($layer_id) is a 2D layer.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }


  if (length($geometry_type) > 0) {

    if (uc($geometry_type) ne 'POINT') {

      my $err_msg = "Layer ($layer_id) is not a POINT layer.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $msg = "(parameter name, device id) -> (layer attribute id):\n";
  $msg   .= "($cur_para, $cur_dev_id) -> ";
  $msg   .= "($cur_at_id)";

  my $sql = '';
  $sql   .= 'SELECT deviceid FROM datadevice ';
  $sql   .= 'WHERE deviceid=? AND layerattrib=? AND deviceparam=? ';
  $sql   .= 'LIMIT 1';

  my $sth = $dbh_gis_write->prepare($sql);
  $sth->execute($cur_dev_id, $cur_at_id, $cur_para);
  my $db_device_id;
  $sth->bind_col(1, \$db_device_id);
  $sth->fetch();
  $sth->finish();

  if (length($db_device_id) == 0) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => "$msg does not exist."}]};

    return $data_for_postrun_href;
  }

  $sql    = 'UPDATE datadevice SET ';
  $sql   .= 'deviceid=?, layerattrib=?, deviceparam=?, active=? ';
  $sql   .= 'WHERE deviceid=? AND layerattrib=? AND deviceparam=?';

  $sth = $dbh_gis_write->prepare($sql);
  $sth->execute($device_id, $attribute_id, $device_param_name, $active, $cur_dev_id, $cur_at_id, $cur_para);

  if ($dbh_gis_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $dbh_gis_write->disconnect();
  $dbh_k_read->disconnect();

  $msg    = "Device paramater map ($cur_dev_id, $cur_para) has been updated.";

  my $info_msg_aref = [{'DeviceParamName' => $device_param_name,
                        'DeviceId'        => $device_id,
                        'AttributeId'     => $attribute_id,
                        'LayerId'         => $layer_id,
                        'Message'         => $msg,
                       }];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub log_environment_data_bulk_runmode {

=pod log_environment_data_HELP_START
{
"OperationName": "Log environment data",
"Description": "Insert a log entity into GIS layer. Mostly used as a log of spatio-temporal information where geo-location can already be known, but new entry is next record in time.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Environment Data has been saved successfully. Affected layer (1,7,9). Insertion time: 0.05847 seconds. Number of records: 8' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Environment Data has been saved successfully. Affected layer (1,7,9). Insertion time: 0.036854 seconds. Number of records: 8'}]}",
"ErrorMessageXML": [{"NoncomplianceXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Environment data xml file does not comply with its definition. Details: XML::Checker ERROR-159: unspecified value for #REQUIRED attribute [deviceid]  Context: Element EnviroData, Attr deviceid, line 3, column 6, byte 139 ' /></DATA>"}],
"ErrorMessageJSON": [{"NoncomplianceXML": "{'Error' : [{'Message' : 'Environment data xml file does not comply with its definition. Details: XML::Checker ERROR-159: unspecified value for #REQUIRED attribute [deviceid] Context: Element EnviroData, Attr deviceid, line 3, column 6, byte 139'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "XML",
"UploadFileParameterName": "uploadfile",
"DTDFileNameForUploadXML": "enviro_data.dtd",
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $env_data_xml_file = $self->authen->get_upload_file();

  $self->logger->debug("XML Data File: $env_data_xml_file");

  my $enviro_data_dtd_file = $self->get_environment_data_dtd_file();

  add_dtd($enviro_data_dtd_file, $env_data_xml_file);

  my $xml_checker_parser = new XML::Checker::Parser( Handlers => { } );

  eval {

    local $XML::Checker::FAIL = sub {

      my $code = shift;
      my $err_str = XML::Checker::error_string ($code, @_);
      $self->logger->debug("XML Parsing ERR: $code : $err_str");
      die $err_str;
    };
    $xml_checker_parser->parsefile($env_data_xml_file);
  };

  if ($@) {

    my $err_msg = $@;
    $self->logger->debug("Parsing XML error: $err_msg");
    my $user_err_msg = "Environment data xml file does not comply with its definition.\n";
    $user_err_msg   .= "Details: $err_msg";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $user_err_msg}]};

    return $data_for_postrun_href;
  }

  my $env_data_xml = read_file($env_data_xml_file);
  my $env_data     = xml2arrayref($env_data_xml, 'EnviroData');

  my $hierarchical_env_data = {};

  for my $env_entry_record (@{$env_data}) {

    my $device_id = lc($env_entry_record->{'deviceid'});

    my $dev_param_data = {};
    if ($hierarchical_env_data->{$device_id}) {

      $dev_param_data = $hierarchical_env_data->{$device_id};
    }

    my $param_name = $env_entry_record->{'param_name'};

    my $param_val_aref = [];
    if ($dev_param_data->{$param_name}) {

      $param_val_aref = $dev_param_data->{$param_name};
    }

    my $lng       = $env_entry_record->{'lng'};
    my $lat       = $env_entry_record->{'lat'};
    my $param_val = $env_entry_record->{'param_value'};
    my $dt        = $env_entry_record->{'dt'};

    #$self->logger->debug("Dt: $dt");

    push(@{$param_val_aref}, [$lng, $lat, $param_val, $dt]);

    $dev_param_data->{lc($param_name)}   = $param_val_aref;
    $hierarchical_env_data->{$device_id} = $dev_param_data;
  }

  $env_data_xml = '';    # Clear no longer in use data
  $env_data     = [];    # Clear no longer in use data

  my $dbh_gis_write = connect_gis_write();
  my $dbh_k_write   = connect_kdb_write();
  my $sql = '';
  my $sth_k;
  my $sth_gis;

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $layer_id_href = {};

  my $insert_start_time = [gettimeofday()];

  for my $dev_id (keys(%{$hierarchical_env_data})) {

    $self->logger->debug("Device Id: $dev_id");
    $sql  = 'SELECT DeviceRegisterId, Longitude, Latitude ';
    $sql .= 'FROM deviceregister ';
    $sql .= 'WHERE DeviceId=?';

    my $sth_k = $dbh_k_write->prepare($sql);
    $sth_k->execute($dev_id);

    if ($dbh_k_write->err()) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $dev_reg_id;
    my $dev_reg_lng;
    my $dev_reg_lat;

    $sth_k->bind_col(1, \$dev_reg_id);
    $sth_k->bind_col(2, \$dev_reg_lng);
    $sth_k->bind_col(3, \$dev_reg_lat);
    $sth_k->fetch();
    $sth_k->finish();

    if (length($dev_reg_id) == 0) {

      my $err_msg = "Device ($dev_id) has not been registered yet.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    #$self->logger->debug("Device reg lng: $dev_reg_lng");
    #$self->logger->debug("Device reg lat: $dev_reg_lat");

    $hierarchical_env_data->{"${dev_id}_DREG_DATA"} = [$dev_reg_lng, $dev_reg_lat];

    my $this_dev_data = $hierarchical_env_data->{$dev_id};

    for my $para_name (keys(%{$this_dev_data})) {

      $para_name = lc($para_name);

      $sql  = 'SELECT layerattrib, layer, colsize, validation, colname, layertype ';
      $sql .= 'FROM datadevice LEFT JOIN layerattrib ';
      $sql .= 'ON datadevice.layerattrib = layerattrib.id LEFT JOIN layer ';
      $sql .= 'ON layerattrib.layer = layer.id ';
      $sql .= 'WHERE deviceid=? AND deviceparam=? and active=1';

      $sth_gis = $dbh_gis_write->prepare($sql);
      $sth_gis->execute($dev_id, $para_name);

      if ($dbh_gis_write->err()) {

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

        return $data_for_postrun_href;
      }

      my $attrib_id_aref = $sth_gis->fetchall_arrayref();
      $sth_gis->finish();

      if (scalar(@{$attrib_id_aref}) == 0) {

        my $msg = "Parameter ($para_name) from device ($dev_id) ";
        $msg   .= 'has not been associated with any layer attribute.';

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $msg}]};

        return $data_for_postrun_href;
      }

      my $attrib_info = {};

      my $actual_env_data = $this_dev_data->{$para_name};
      for my $row_aref (@{$attrib_id_aref}) {

        my $attr_id         = $row_aref->[0];
        my $layer_id        = $row_aref->[1];
        my $colname         = $row_aref->[4];
        my $layertype       = $row_aref->[5];

        $layer_id_href->{$layer_id} = 1;

        # Nov 2014 - attempting to log environment data to 2D table which needs colname and layertype.
        # However, it turns out that it is unnecessary complex. So the idea of log sensor data
        # (data with timestamp) was abandoned. However, colname and layertype were left here.
        # layertype is later used in insert_data_into_layer but no colname.

        $attrib_info->{$attr_id} = [$layer_id, $colname, $layertype];

        my $attr_colsize    = $row_aref->[2];
        my $attr_validation = $row_aref->[3];

        for my $env_data_point (@{$actual_env_data}) {

          my $param_val = $env_data_point->[2];
          my $env_dt    = $env_data_point->[3];
          if (length($param_val) > $attr_colsize) {

            my $too_long_err_msg = "device id, parameter name, parameter value, datetime ";
            $too_long_err_msg   .= "($dev_id, $para_name, $param_val, $env_dt) ";
            $too_long_err_msg   .= "contains parameter value ($param_val) longer than the ";
            $too_long_err_msg   .= "column size definition of layer attribute ($attr_id) on layer ($layer_id).";

            $data_for_postrun_href->{'Error'} = 1;
            $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $too_long_err_msg}]};

            return $data_for_postrun_href;
          }

          #$self->logger->debug("Param val: $param_val, validation: $attr_validation");

          if (length($attr_validation) > 0) {

            if (!($param_val =~ /^$attr_validation$/)) {

              my $invalid_err_msg = "device id, parameter name, parameter value, datetime ";
              $invalid_err_msg   .= "($dev_id, $para_name, $param_val, $env_dt) ";
              $invalid_err_msg   .= "contains parameter value ($param_val) is invalid with ";
              $invalid_err_msg   .= "the validation rule of layer attribute ($attr_id) on layer ($layer_id).";

              $data_for_postrun_href->{'Error'} = 1;
              $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $invalid_err_msg}]};

              return $data_for_postrun_href;
            }
          }
        }
      }

      $this_dev_data->{"${para_name}_LATTR_INFO"} = $attrib_info;
    }
    $hierarchical_env_data->{$dev_id} = $this_dev_data;
  }

  my @layer_id_list = keys(%{$layer_id_href});
  my ($is_ok, $trouble_layer_id_aref) = check_permission($dbh_gis_write, 'layer', 'id',
                                                         \@layer_id_list, $group_id, $gadmin_status,
                                                         $LINK_PERM);

  if (!$is_ok) {

    my $trouble_layer_id_str = join(',', @{$trouble_layer_id_aref});

    my $perm_err_msg = '';
    $perm_err_msg   .= "Permission denied: Group ($group_id) and layer ($trouble_layer_id_str).";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $perm_err_msg}]};

    return $data_for_postrun_href;
  }

  my $layer_id_list_csv = join(',', @layer_id_list);
  $sql = "SELECT id FROM layer WHERE id IN ($layer_id_list_csv) AND UPPER(geometrytype) not like 'POINT'";

  my ($chk_point_layer_err, $chk_point_err_msg, $non_point_layer_aref) = read_data($dbh_gis_write, $sql, []);

  if ($chk_point_layer_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$non_point_layer_aref}) > 0) {

    my @non_point_layer_list;

    for my $non_point_layer (@{$non_point_layer_aref}) {

      push(@non_point_layer_list, $non_point_layer->{'id'});
    }

    my $non_point_layer_csv = join(',', @non_point_layer_list);
    my $err_msg = "Layer ($non_point_layer_csv): not POINT layer.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  # this loop is to save the data into the database. the previous
  # loop is for checking.

  my ($err_status, $num_row_inserted,
      $affected_layer_aref, $postrun_data_href) = $self->insert_data_into_layer($dbh_k_write, $dbh_gis_write,
                                                                                $hierarchical_env_data);

  my $insert_elapsed = tv_interval($insert_start_time);

  my $affected_layer_id = join(',', @{$affected_layer_aref});

  $dbh_k_write->disconnect();
  $dbh_gis_write->disconnect();

  my $info_msg = "Environment Data has been saved successfully. Affected layer ($affected_layer_id). ";
  $info_msg   .= "Insertion time: $insert_elapsed seconds. Number of records: $num_row_inserted";
  my $info_msg_aref = [{'Message' => $info_msg}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_layer {

  my $self            = $_[0];
  my $extra_attr_yes  = $_[1];
  my $exten_attr_yes  = $_[2];
  my $sql             = $_[3];
  my $where_para_aref = $_[4];

  my $err = 0;
  my $msg = '';
  my $data_aref = [];

  my $dbh = connect_gis_read();

  ($err, $msg, $data_aref) = read_data($dbh, $sql, $where_para_aref);

  if ($err) {

    return ($err, $msg, $data_aref);
  }

  if (scalar(@{$data_aref}) == 0) {

    return ($err, $msg, $data_aref);
  }

  my $extra_attr_layer_data = [];

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

    my $gadmin_status = $self->authen->gadmin_status();
    my $group_id      = $self->authen->group_id();

    my $layer_id_aref    = [];
    my $layer_table_aref = [];
    my $group_id_href    = {};

    for my $row (@{$data_aref}) {

      my $layer_id       = $row->{'layerid'};

      my $own_grp_id   = $row->{'owngroupid'};
      my $acc_grp_id   = $row->{'accessgroupid'};

      my $layer_data_table = "layer${layer_id}attrib";

      push(@{$layer_id_aref}, $layer_id);
      push(@{$layer_table_aref}, $layer_data_table);
      $group_id_href->{$own_grp_id} = 1;
      $group_id_href->{$acc_grp_id} = 1;
    }

    my $layer_data_table_exist_href = table_existence_bulk($dbh, $layer_table_aref);

    my $dbh_kdb = connect_kdb_read();
    my $group_sql    = 'SELECT SystemGroupId, SystemGroupName ';
    $group_sql      .= 'FROM systemgroup ';
    $group_sql      .= 'WHERE SystemGroupId IN (' . join(',', keys(%{$group_id_href})) . ')';

    my $group_lookup = $dbh_kdb->selectall_hashref($group_sql, 'SystemGroupId');
    $dbh_kdb->disconnect();

    my $chk_id_err        = 0;
    my $chk_id_msg        = '';
    my $used_id_href      = {};
    my $not_used_id_href  = {};

    if ($gadmin_status eq '1') {

      my $chk_table_aref = [{'TableName' => 'layer', 'FieldName' => 'parent'},
                            {'TableName' => 'layerattrib', 'FieldName' => 'layer'}
          ];

      ($chk_id_err, $chk_id_msg,
       $used_id_href, $not_used_id_href) = id_existence_bulk($dbh, $chk_table_aref, $layer_id_aref);

      if ($chk_id_err) {

        $self->logger->debug("Check id existence error: $chk_id_msg");
        $err = 1;
        $msg = $chk_id_msg;
      }
    }

    if ($err) {

      return ($err, $msg, $extra_attr_layer_data);
    }


    my $layerattrib_lookup    = {};

    if ($exten_attr_yes) {

      my $attrib_sql  = 'SELECT layer, id as layerattribid, colname, coltype, colsize, validation, ';
      $attrib_sql    .= 'colunits, unitid ';
      $attrib_sql    .= 'FROM layerattrib ';
      $attrib_sql    .= 'WHERE layer IN (' . join(',', @{$layer_id_aref}) . ')';

      my ($layerattr_err, $layerattr_msg, $layerattr_data) = read_data($dbh, $attrib_sql, []);

      if ($layerattr_err) {

        return ($layerattr_err, $layerattr_msg, []);
      }

      for my $layerattr_rec (@{$layerattr_data}) {

        my $layer_id = $layerattr_rec->{'layer'};

        if (defined $layerattrib_lookup->{$layer_id}) {

          my $layerattrib_aref = $layerattrib_lookup->{$layer_id};
          delete($layerattr_rec->{'layer'});
          push(@{$layerattrib_aref}, $layerattr_rec);
          $layerattrib_lookup->{$layer_id} = $layerattrib_aref;
        }
        else {

          delete($layerattr_rec->{'layer'});
          $layerattrib_lookup->{$layer_id} = [$layerattr_rec];
        }
      }
    }

    for my $row (@{$data_aref}) {

      my $layer_id       = $row->{'layerid'};

      my $own_grp_id   = $row->{'owngroupid'};
      my $acc_grp_id   = $row->{'accessgroupid'};
      my $own_perm     = $row->{'owngroupperm'};
      my $acc_perm     = $row->{'accessgroupperm'};
      my $oth_perm     = $row->{'otherperm'};
      my $ulti_perm    = $row->{'ultimateperm'};

      $row->{'owngroupname'}          = $group_lookup->{$own_grp_id}->{'SystemGroupName'};
      $row->{'accessgroupname'}       = $group_lookup->{$acc_grp_id}->{'SystemGroupName'};
      $row->{'owngrouppermission'}    = $perm_lookup->{$own_perm};
      $row->{'accessgrouppermission'} = $perm_lookup->{$acc_perm};
      $row->{'otherpermission'}       = $perm_lookup->{$oth_perm};
      $row->{'ultimatepermission'}    = $perm_lookup->{$ulti_perm};

      if (($ulti_perm & $WRITE_PERM) == $WRITE_PERM) {

        $row->{'update'}   = "update/layer/$layer_id";
      }

      if (($ulti_perm & $LINK_PERM) == $LINK_PERM) {

        $row->{'addAttr'} = "layer/${layer_id}/add/attribute";
      }

      if ($own_grp_id == $group_id) {

        $row->{'chgPerm'} = "layer/$layer_id/change/permission";

        if ($gadmin_status eq '1') {

          $row->{'chgOwner'} = "layer/$layer_id/change/owner";

          if ( $not_used_id_href->{$layer_id}  ) {

            $row->{'delete'}   = "delete/layer/$layer_id";
          }
        }
      }

      my $layer_data_table = "layer${layer_id}attrib";

      if ($layer_data_table_exist_href->{$layer_data_table}) {

        $sql  = "SELECT Count(*) FROM $layer_data_table";
        my ($count_rec_err, $record_count) = read_cell($dbh, $sql, []);

        $row->{'nrecord'} = $record_count;
        if ($record_count > 0) {

          $row->{'download'} = 1;
        }

        $sql  = "SELECT DISTINCT ON (layerattrib) layerattrib, dt FROM $layer_data_table ";
        $sql .= "ORDER BY layerattrib, dt DESC";

        my ($last_rec_date_err, $last_rec_data_msg, $last_record_date_data) = read_data($dbh, $sql, []);

        if ($last_rec_date_err) {

          return ($last_rec_date_err, $last_rec_data_msg, $last_record_date_data);
        }

        if (scalar(@{$last_record_date_data}) > 0) {

          $row->{'lastrecorddate'} = $last_record_date_data;
        }
      }

      if ($exten_attr_yes) {

        if (defined $layerattrib_lookup->{$layer_id}) {

          $row->{'layerattrib'} = $layerattrib_lookup->{$layer_id};
        }
      }

      push(@{$extra_attr_layer_data}, $row);
    }
  }
  else {

    $extra_attr_layer_data = $data_aref;
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_layer_data);
}

sub list_layer_full_runmode {

=pod list_layer_full_HELP_START
{
"OperationName": "List layers",
"Description": "Return list of GIS layers defined in the system.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><layer layername='Layer - 6944742' accessgroupperm='5' lastupdateuser='0' owngrouppermission='Read/Write/Link' chgPerm='layer/13/change/permission' nrecord='0' owngroupname='admin' owngroupid='0' accessgroupid='0' parentlayername='' srid='4326' ultimateperm='7' createuser='0' ultimatepermission='Read/Write/Link' description='Created by the automatic test.' accessgroupname='admin' alias='' layertype='NORMAL' layerid='13' otherpermission='Read/Link' createtime='2015-09-29 06:19:04' geometrytype='POINT' accessgrouppermission='Read/Link' otherperm='5' addAttr='layer/13/add/attribute' iseditable='1' owngroupperm='7' chgOwner='layer/13/change/owner' lastupdatetime='2015-09-29 06:19:04' layermetadata='Created from the test framework' parentlayer='' update='update/layer/13'><layerattrib layerattribid='17' colsize='20' colunits='percentage' coltype='Humidity' colname='humidity_9246561' validation='' unitid='6' /></layer><RecordMeta TagName='layer' /></DATA>",
"SuccessMessageJSON": "{'layer' : [{'layername' : 'Layer - 6944742', 'accessgroupperm' : 5, 'chgPerm' : 'layer/13/change/permission', 'owngrouppermission' : 'Read/Write/Link', 'lastupdateuser' : '0', 'nrecord' : '0', 'owngroupname' : 'admin', 'owngroupid' : '0', 'accessgroupid' : '0', 'parentlayername' : null, 'srid' : '4326', 'ultimateperm' : 7, 'createuser' : '0', 'ultimatepermission' : 'Read/Write/Link', 'description' : 'Created by the automatic test.', 'accessgroupname' : 'admin', 'alias' : '', 'layertype' : 'NORMAL', 'layerid' : 13, 'otherpermission' : 'Read/Link', 'createtime' : '2015-09-29 06:19:04', 'geometrytype' : 'POINT', 'accessgrouppermission' : 'Read/Link', 'otherperm' : 5, 'addAttr' : 'layer/13/add/attribute', 'iseditable' : 1, 'layerattrib' : [{'colunits' : 'percentage', 'colsize' : '20', 'layerattribid' : 17, 'coltype' : 'Humidity', 'validation' : null, 'colname' : 'humidity_9246561', 'unitid' : '6'}], 'owngroupperm' : 7, 'chgOwner' : 'layer/13/change/owner', 'lastupdatetime' : '2015-09-29 06:19:04', 'layermetadata' : 'Created from the test framework', 'parentlayer' : null, 'update' : 'update/layer/13'}], 'RecordMeta' : [{'TagName' : 'layer'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();
  
  my $filtering_csv = '';

  if (defined $query->param('Filtering')) {

    $filtering_csv = $query->param('Filtering');
  }

  my $data_for_postrun_href = {};

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 1, $gadmin_status, 'layer');

  my $dbh = connect_gis_read();

  my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'layer');

  if ($sfield_err) {

    $self->logger->debug("Get static field failed: $sfield_msg");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my @field_list_all;

  for my $sfield_rec (@{$sfield_data}) {

    push(@field_list_all, $sfield_rec->{'Name'});
  }

  for my $pkey_field (@{$pkey_data}) {

    push(@field_list_all, $pkey_field);
  }

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering('id',
                                                                              'layer',
                                                                              $filtering_csv,
                                                                              \@field_list_all);

  $self->logger->debug("Filter phrase: $filter_phrase");

  if ($filter_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $filter_msg}]};

    return $data_for_postrun_href;
  }

  my $filter_where_phrase = "WHERE (($perm_str) & $READ_PERM) = $READ_PERM ";

  if (length($filter_phrase)) {

    $filter_where_phrase .= " AND $filter_phrase ";
  }

  my $sql = "SELECT layer.id as layerid, ";
  $sql   .= "layer.name as layername, ";
  $sql   .= "layer.alias, ";
  $sql   .= "layer.layertype, ";
  $sql   .= "layer.layermetadata, ";
  $sql   .= "layer.iseditable, ";
  $sql   .= "layer.createuser, ";
  $sql   .= "layer.createtime, ";
  $sql   .= "layer.lastupdateuser, ";
  $sql   .= "layer.lastupdatetime, ";
  $sql   .= "layer.srid, ";
  $sql   .= "layer.geometrytype, ";
  $sql   .= "layer.parent as parentlayer, ";
  $sql   .= "layer.description, ";
  $sql   .= "layer.owngroupid, ";
  $sql   .= "layer.accessgroupid, ";
  $sql   .= "layer.owngroupperm, ";
  $sql   .= "layer.accessgroupperm, ";
  $sql   .= "layer.otherperm, ";
  $sql   .= "player.name as parentlayername, ";
  $sql   .= "$perm_str as ultimateperm ";
  $sql   .= "FROM layer LEFT JOIN layer as player ON layer.parent = player.id ";
  $sql   .= $filter_where_phrase;
  $sql   .= "ORDER BY layer.id DESC";

  my ($read_layer_err, $read_layer_msg, $layer_data_aref) = $self->list_layer(1, 1, $sql);

  if ($read_layer_err) {

    $self->logger->debug($read_layer_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'} = 0;
  $data_for_postrun_href->{'Data'}  = {'layer'      => $layer_data_aref,
                                       'RecordMeta' => [{'TagName' => 'layer'}],
  };

  return $data_for_postrun_href;
}

sub get_layer_runmode {

=pod get_layer_HELP_START
{
"OperationName": "Get layer",
"Description": "Return detailed information about GIS layer in the system specified by layer id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><layer layername='Layer - 6944742' accessgroupperm='5' lastupdateuser='0' owngrouppermission='Read/Write/Link' chgPerm='layer/13/change/permission' nrecord='0' owngroupname='admin' owngroupid='0' accessgroupid='0' parentlayername='' srid='4326' ultimateperm='7' createuser='0' ultimatepermission='Read/Write/Link' description='Created by the automatic test.' accessgroupname='admin' alias='' layertype='NORMAL' layerid='13' otherpermission='Read/Link' createtime='2015-09-29 06:19:04' geometrytype='POINT' accessgrouppermission='Read/Link' otherperm='5' addAttr='layer/13/add/attribute' iseditable='1' owngroupperm='7' chgOwner='layer/13/change/owner' lastupdatetime='2015-09-29 06:19:04' layermetadata='Created from the test framework' parentlayer='' update='update/layer/13'><layerattrib layerattribid='17' colsize='20' colunits='percentage' coltype='Humidity' colname='humidity_9246561' validation='' unitid='6' /></layer><RecordMeta TagName='layer' /></DATA>",
"SuccessMessageJSON": "{'layer' : [{'layername' : 'Layer - 6944742', 'accessgroupperm' : 5, 'chgPerm' : 'layer/13/change/permission', 'owngrouppermission' : 'Read/Write/Link', 'lastupdateuser' : '0', 'nrecord' : '0', 'owngroupname' : 'admin', 'owngroupid' : '0', 'accessgroupid' : '0', 'parentlayername' : null, 'srid' : '4326', 'ultimateperm' : 7, 'createuser' : '0', 'ultimatepermission' : 'Read/Write/Link', 'description' : 'Created by the automatic test.', 'accessgroupname' : 'admin', 'alias' : '', 'layertype' : 'NORMAL', 'layerid' : 13, 'otherpermission' : 'Read/Link', 'createtime' : '2015-09-29 06:19:04', 'geometrytype' : 'POINT', 'accessgrouppermission' : 'Read/Link', 'otherperm' : 5, 'addAttr' : 'layer/13/add/attribute', 'iseditable' : 1, 'layerattrib' : [{'colunits' : 'percentage', 'colsize' : '20', 'layerattribid' : 17, 'coltype' : 'Humidity', 'validation' : null, 'colname' : 'humidity_9246561', 'unitid' : '6'}], 'owngroupperm' : 7, 'chgOwner' : 'layer/13/change/owner', 'lastupdatetime' : '2015-09-29 06:19:04', 'layermetadata' : 'Created from the test framework', 'parentlayer' : null, 'update' : 'update/layer/13'}], 'RecordMeta' : [{'TagName' : 'layer'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Layer (15) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Layer (15) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing layerid"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self     = shift;
  my $layer_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_gis_read();
  my $layer_exist = record_existence($dbh, 'layer', 'id', $layer_id);
  $dbh->disconnect();

  if (!$layer_exist) {

    my $err_msg = "Layer ($layer_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 1, $gadmin_status, 'layer');

  my $sql = "SELECT layer.id as layerid, ";
  $sql   .= "layer.name as layername, ";
  $sql   .= "layer.alias, ";
  $sql   .= "layer.layertype, ";
  $sql   .= "layer.layermetadata, ";
  $sql   .= "layer.iseditable, ";
  $sql   .= "layer.createuser, ";
  $sql   .= "layer.createtime, ";
  $sql   .= "layer.lastupdateuser, ";
  $sql   .= "layer.lastupdatetime, ";
  $sql   .= "layer.srid, ";
  $sql   .= "layer.geometrytype, ";
  $sql   .= "layer.parent as parentlayer, ";
  $sql   .= "layer.description, ";
  $sql   .= "layer.owngroupid, ";
  $sql   .= "layer.accessgroupid, ";
  $sql   .= "layer.owngroupperm, ";
  $sql   .= "layer.accessgroupperm, ";
  $sql   .= "layer.otherperm, ";
  $sql   .= "player.name as parentlayername, ";
  $sql   .= "$perm_str as ultimateperm ";
  $sql   .= "FROM layer LEFT JOIN layer as player ON layer.parent = player.id ";
  $sql   .= "WHERE (($perm_str) & $READ_PERM) = $READ_PERM ";
  $sql   .= "AND layer.id=?";

  my ($read_layer_err, $read_layer_msg, $layer_data_aref) = $self->list_layer(1, 1, $sql, [$layer_id]);

  if ($read_layer_err) {

    $self->logger->debug($read_layer_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'} = 0;
  $data_for_postrun_href->{'Data'}  = {'layer'      => $layer_data_aref,
                                       'RecordMeta' => [{'TagName' => 'layer'}],
  };

  return $data_for_postrun_href;
}

sub list_parameter_mapping {

  my $self              = $_[0];
  my $extra_attr_yes    = $_[1];
  my $sql               = $_[2];
  my $where_para_aref   = $_[3];

  my $err = 0;
  my $msg = '';
  my $data_aref = [];

  my $dbh = connect_gis_read();

  ($err, $msg, $data_aref) = read_data($dbh, $sql, $where_para_aref);

  if ($err) {

    return ($err, $msg, $data_aref);
  }

  my $final_dev_mapping_data = [];

  if ($extra_attr_yes) {

    my $gadmin_status = $self->authen->gadmin_status();
    
    for my $dev_mapping_row (@{$data_aref}) {

      my $device_id   = $dev_mapping_row->{'deviceid'};
      my $para_name   = $dev_mapping_row->{'deviceparam'};
      my $attr_id     = $dev_mapping_row->{'layerattrib'};

      if ($gadmin_status eq '1') {

        $dev_mapping_row->{'update'}  = "update/parametermapping/$device_id/$para_name/$attr_id";
      }
      push(@{$final_dev_mapping_data}, $dev_mapping_row);
    }
  }
  else {

    $final_dev_mapping_data = $data_aref;
  }
 
  $dbh->disconnect();

  return ($err, $msg, $final_dev_mapping_data);
}

sub list_parameter_mapping_full_runmode {

=pod list_parameter_mapping_full_HELP_START
{
"OperationName": "List mapped parameters",
"Description": "Return current list of parameter mappings between GIS attributes and devices.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='datadevice' /><datadevice layername='Layer - 1530996' deviceid='autotest-wst01' colname='Humidity_1188455' ultimateperm='7' layerattrib='7' active='0' layer='1' deviceparam='humidity' update='update/parametermapping/autotest-wst01/humidity/7' /></DATA>",
"SuccessMessageJSON": "{ 'RecordMeta' : [{ 'TagName' : 'datadevice'} ], 'datadevice' : [{ 'layername' : 'Layer - 1530996', 'ultimateperm' : '7', 'deviceid' : 'autotest-wst01', 'layerattrib' : '7', 'active' : '0', 'colname' : 'Humidity_1188455', 'layer' : '1', 'deviceparam' : 'humidity', 'update' : 'update/parametermapping/autotest-wst01/humidity/7'} ]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = shift;

  my $data_for_postrun_href = {};

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 1, $gadmin_status, 'layer');

  my $sql = "SELECT deviceid, layerattrib, deviceparam, active, ";
  $sql   .= "colname, layer, layer.name as layername, $perm_str as ultimateperm ";
  $sql   .= "FROM datadevice LEFT JOIN layerattrib ON ";
  $sql   .= "datadevice.layerattrib = layerattrib.id ";
  $sql   .= "LEFT JOIN layer ON layerattrib.layer = layer.id ";
  $sql   .= "WHERE (($perm_str) & $READ_PERM) = $READ_PERM ";
  $sql   .= "ORDER BY deviceid, deviceparam ASC";

  $self->logger->debug("SQL: $sql");

  my ($para_mapping_err, $para_mapping_msg, $para_mapping_aref)  = $self->list_parameter_mapping(1, $sql);

  if ($para_mapping_err) {

    $self->logger->debug($para_mapping_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $rec_meta_aref = [{'TagName' => 'datadevice'}];

  $data_for_postrun_href->{'Error'} = 0;
  $data_for_postrun_href->{'Data'}  = {'datadevice' => $para_mapping_aref,
                                       'RecordMeta' => $rec_meta_aref,
  };

  return $data_for_postrun_href;
}

sub get_parameter_mapping_runmode {

=pod get_parameter_mapping_HELP_START
{
"OperationName": "Get mapped parameter",
"Description": "Return detailed information for mapped parameter to the GIS attribute and the specified device id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='datadevice' /><datadevice layer='7' deviceid='autotest-wst01' deviceparam='temperature' layerattrib='12' active='1' colname='Temperature_9835426' update='update/parametermapping/autotest-wst01/temperature/12' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'datadevice'}],'datadevice' : [{'layer' : '7','deviceid' : 'autotest-wst01','layerattrib' : '12','deviceparam' : 'temperature','active' : '1','colname' : 'Temperature_9835426','update' : 'update/parametermapping/autotest-wst01/temperature/12'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Mapping between parameter (temperature) on device (autotest-wst0) and attribute (12) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Mapping between parameter (temperature) on device (autotest-wst0) and attribute (12) not found.'}]}"}],
"URLParameter": [{"ParameterName": "devid", "Description": "DeviceId"}, {"ParameterName": "para", "Description": "Parameter name like tem for temperature and hum for humidity"}, {"ParameterName": "atid", "Description": "Layer attribute Id"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self    = shift;
  my $devid   = $self->param('devid');
  my $para    = $self->param('para');
  my $attr_id = $self->param('atid');

  my $data_for_postrun_href = {};

  if (!($attr_id =~ /^\d+$/)) {

    my $err_msg = "Attribute ($attr_id) not an integer.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh = connect_gis_read();
  my $sql = 'SELECT Count(*) FROM datadevice ';
  $sql   .= 'WHERE deviceid=? AND layerattrib=? AND deviceparam=?';
  my $sth = $dbh->prepare($sql);
  $sth->execute($devid, $attr_id, $para);
  my $count = 0;
  $sth->bind_col(1, \$count);
  $sth->fetch();
  $sth->finish();
  $dbh->disconnect();
  
  if ($count == 0) {

    my $msg = "Mapping between parameter ($para) on device ($devid) and attribute ($attr_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 1, $gadmin_status, 'layer');

  $sql    = "SELECT deviceid, layerattrib, deviceparam, active, colname, layer ";
  $sql   .= "FROM datadevice LEFT JOIN layerattrib ON ";
  $sql   .= "datadevice.layerattrib = layerattrib.id ";
  $sql   .= "LEFT JOIN layer ON layerattrib.layer = layer.id ";
  $sql   .= "WHERE (($perm_str) & $READ_LINK_PERM) = $READ_LINK_PERM AND ";
  $sql   .= "deviceid=? AND deviceparam=? AND layerattrib=?";
  
  $self->logger->debug("SQL: $sql");

  my ($para_mapping_err, $para_mapping_msg, $para_mapping_aref)  = $self->list_parameter_mapping(1,
                                                                                                 $sql,
                                                                                                 [$devid, $para, $attr_id],
      );

  if ($para_mapping_err) {

    $self->logger->debug($para_mapping_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $rec_meta_aref = [{'TagName' => 'datadevice'}];

  $data_for_postrun_href->{'Error'} = 0;
  $data_for_postrun_href->{'Data'}  = {'datadevice' => $para_mapping_aref,
                                       'RecordMeta' => $rec_meta_aref,
  };

  return $data_for_postrun_href;
}

sub list_dev_registration {

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

    return ($err, $msg, $data_aref);
  }

  my $final_dev_reg_data = [];

  my $gadmin_status = $self->authen->gadmin_status();

  if ( $extra_attr_yes && ($gadmin_status eq '1') ) {

    my $device_id_aref  = [];
    my $dev_reg_id_aref = [];

    for my $dev_reg_row (@{$data_aref}) {

      push(@{$dev_reg_id_aref}, $dev_reg_row->{'DeviceRegisterId'});

      if (defined $dev_reg_row->{'DeviceId'}) {

        push(@{$device_id_aref}, "'" . $dev_reg_row->{'DeviceId'} . "'");
      }
    }

    my $chk_id_err               = 0;
    my $chk_id_msg               = '';
    my $used_id_item_href        = {};
    my $not_used_id_item_href    = {};

    my $used_id_ddevice_href     = {};
    my $not_used_id_ddevice_href = {};

    if (scalar(@{$device_id_aref}) > 0) {

      my $chk_table_aref = [{'TableName' => 'item', 'FieldName' => 'ScaleId'}];

      ($chk_id_err, $chk_id_msg,
       $used_id_item_href, $not_used_id_item_href) = id_existence_bulk($dbh, $chk_table_aref,
                                                                       $dev_reg_id_aref);

      if ($chk_id_err) {

        $self->logger->debug("Check id existence error: $chk_id_msg");
        $err = 1;
        $msg = $chk_id_msg;
      }

      if ($err) {

        return ($err, $msg, $data_aref);
      }

      $self->logger->debug("Used id list: " . join(',', keys(%{$used_id_item_href})));
      $self->logger->debug("Not used id list: " . join(',', sort(keys(%{$not_used_id_item_href}))));

      my $dbh_gis = connect_gis_read();

      $chk_table_aref = [{'TableName' => 'datadevice', 'FieldName' => 'deviceid'}];

      ($chk_id_err, $chk_id_msg,
       $used_id_ddevice_href, $not_used_id_ddevice_href) = id_existence_bulk($dbh_gis, $chk_table_aref,
                                                                             $device_id_aref);

      if ($chk_id_err) {

        $self->logger->debug("Check id existence error: $chk_id_msg");
        $err = 1;
        $msg = $chk_id_msg;
      }

      $self->logger->debug("Used id list: " . join(',', keys(%{$used_id_ddevice_href})));
      $self->logger->debug("Not used id list: " . join(',', sort(keys(%{$not_used_id_ddevice_href}))));

      $dbh_gis->disconnect();
    }

    if ($err) {

      return ($err, $msg, $data_aref);
    }

    for my $dev_reg_row (@{$data_aref}) {

      my $reg_id   = $dev_reg_row->{'DeviceRegisterId'};

      $dev_reg_row->{'update'}  = "update/deviceregistration/$reg_id";

      if (defined $dev_reg_row->{'DeviceId'}) {

        my $dev_id = $dev_reg_row->{'DeviceId'};

        if ($not_used_id_item_href->{$reg_id} &&
            $not_used_id_ddevice_href->{$dev_id}) {

          $dev_reg_row->{'delete'}  = "delete/deviceregistration/$reg_id";
        }
      }

      push(@{$final_dev_reg_data}, $dev_reg_row);
    }
  }
  else {

    $final_dev_reg_data = $data_aref;
  }
 
  $dbh->disconnect();

  return ($err, $msg, $final_dev_reg_data);
}

sub list_dev_registration_full_runmode {

=pod list_dev_registration_full_HELP_START
{
"OperationName": "List devices",
"Description": "Return a list of registered devices.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='DeviceRegistration' /><DeviceRegistration Longitude='0.0000000000000' DeviceNote='Created by the automatic test.' DeviceTypeId='110' DeviceRegisterId='9' DeviceId='autotest-wst01_0487285' delete='delete/deviceregistration/9' update='update/deviceregistration/9' Latitude='0.00000000000000' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'DeviceRegistration'}],'DeviceRegistration' : [{'DeviceNote' : 'Created by the automatic test.','Longitude' : '0.0000000000000','DeviceRegisterId' : '9','DeviceTypeId' : '110','DeviceId' : 'autotest-wst01_0487285','delete' : 'delete/deviceregistration/9','update' : 'update/deviceregistration/9','Latitude' : '0.00000000000000'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = shift;

  my $group_id = $self->authen->group_id();

  my $data_for_postrun_href = {};

  my $sql = 'SELECT * ';
  $sql   .= 'FROM deviceregister ';
  $sql   .= 'ORDER BY DeviceRegisterId DESC';

  my ($dev_reg_err, $dev_reg_msg, $dev_reg_aref)  = $self->list_dev_registration(1, $sql);

  if ($dev_reg_err) {

    $self->logger->debug($dev_reg_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $rec_meta_aref = [{'TagName' => 'DeviceRegistration'}];

  $data_for_postrun_href->{'Error'} = 0;
  $data_for_postrun_href->{'Data'}  = {'DeviceRegistration' => $dev_reg_aref,
                                       'RecordMeta'         => $rec_meta_aref,
  };

  return $data_for_postrun_href;
}

sub list_layer_attribute {

  my $self              = $_[0];
  my $extra_attr_yes    = $_[1];
  my $sql               = $_[2];
  my $where_para_aref   = $_[3];

  my $data_for_postrun_href = {};

  my $err = 0;
  my $msg = '';
  my $data_aref = [];

  my $dbh = connect_gis_read();

  ($err, $msg, $data_aref) = read_data($dbh, $sql, $where_para_aref);

  if ($err) {

    return ($err, $msg, $data_aref);
  }

  my $final_attr_data = [];

  if ($extra_attr_yes) {

    my $gadmin_status = $self->authen->gadmin_status();
    
    for my $attr_row (@{$data_aref}) {

      my $attr_id   = $attr_row->{'id'};

      if ($gadmin_status eq '1') {

        $attr_row->{'update'}  = "update/layerattrib/$attr_id";
      }
      push(@{$final_attr_data}, $attr_row);
    }
  }
  else {

    $final_attr_data = $data_aref;
  }
 
  $dbh->disconnect();

  return ($err, $msg, $final_attr_data);
}

sub list_layer_attribute_runmode {

=pod list_layer_attribute_HELP_START
{
"OperationName": "List attributes",
"Description": "Return a list of all attributes for all available GIS layers.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><layerattrib colunits='percentage' colname='hum_15411235529' unitid='7' validation='' layer='11' coltype='Humidity' colsize='20' layerattribid='16' update='update/layerattrib/' /><layerattrib colunits='degree c' colname='temperature_33601405048' unitid='7' layer='11' validation='' coltype='Temperature' colsize='20' update='update/layerattrib/' layerattribid='15' /><RecordMeta TagName='layerattrib' /><StatInfo ServerElapsedTime='0.009' Unit='second' /></DATA>",
"SuccessMessageJSON": "{'layerattrib' : [{'colsize' : 20,'update' : 'update/layerattrib/','layerattribid' : 16,'coltype' : 'Humidity','unitid' : 7,'layer' : 11,'validation' : null,'colname' : 'hum_15411235529','colunits' : 'percentage'},{'unitid' : 7,'validation' : null,'layer' : 11,'colname' : 'temperature_33601405048','colunits' : 'degree c','colsize' : 20,'layerattribid' : 15,'update' : 'update/layerattrib/','coltype' : 'Temperature'}],'RecordMeta' : [{'TagName' : 'layerattrib'}],'StatInfo' : [{'ServerElapsedTime' : '0.012','Unit' : 'second'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing layer id", "Optional": 1}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = shift;

  my $where_args = [];

  my $data_for_postrun_href = {};

  my $sql = 'SELECT id as layerattribid, layer, colname, coltype, colsize, validation, colunits, unitid ';
  $sql   .= 'FROM layerattrib';

  if (defined $self->param('id')) {

    my $layer = $self->param('id');

    $sql .= ' WHERE layer=?';

    push(@{$where_args}, $layer);
  }

  my ($layer_attr_err, $layer_attr_msg, $layer_attr_aref)  = $self->list_layer_attribute(1, $sql, $where_args);

  if ($layer_attr_err) {

    $self->logger->debug($layer_attr_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $rec_meta_aref = [{'TagName' => 'layerattrib'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'layerattrib' => $layer_attr_aref,
                                           'RecordMeta'  => $rec_meta_aref,
  };

  return $data_for_postrun_href;
}

sub add_layer_attribute_runmode {

=pod add_layer_attribute_HELP_START
{
"OperationName": "Add attribute to the layer",
"Description": "Add a new attribute to the GIS layer",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "environment",
"KDDArTTable": "layerattrib",
"SkippedField": ["layer"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='21' ParaName='id' /><Info Message='Layer Attribute (21) has been added to Layer (9) successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '22','ParaName' : 'id'}],'Info' : [{'Message' : 'Layer Attribute (22) has been added to Layer (8) successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Layer (10) does not exist.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Layer (10) does not exist.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing layerid"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self     = shift;
  my $layer_id = $self->param('id');
  my $query    = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_gis_read();

  my $skip_field = {'layer'       => 1,
                   };

  my $field_name_translation = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'layerattrib', $skip_field,
                                                                                $field_name_translation,
                                                                               );

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $colname            = $query->param('colname');
  my $coltype            = $query->param('coltype');
  my $colsize            = $query->param('colsize');
  my $colunits           = $query->param('colunits');
  my $unit_id            = $query->param('unitid');

  $colname = lc($colname);

  my ($int_err, $int_href) = check_integer_href( { 'colsize' => $colsize } );

  if ($int_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $int_href}]};

    return $data_for_postrun_href;
  }

  my $validation = '';
  if ($query->param('validation')) {

    $validation = $query->param('validation');
  }

  if ( !($colname =~ /^[a-zA-Z0-9_]+$/) ) {

    my $err_msg = "colname ($colname): invalid character.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'colname' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $dbh_gis_write = connect_gis_write();

  my $layer_type = read_cell_value($dbh_gis_write, 'layer', 'layertype', 'id', $layer_id);

  if (length($layer_type) == 0) {

    my $err_msg = "Layer ($layer_id) does not exist.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT id from layerattrib WHERE layer=? AND colname=?';

  my ($chk_colname_err, $layerattrib_id) = read_cell($dbh_gis_write, $sql, [$layer_id, $colname]);

  if ($chk_colname_err) {

    $self->logger->debug("Check if colname exists failed");
    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($layerattrib_id) > 0) {

    my $err_msg = "colname ($colname) in layer ($layer_id): already exists.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'colname' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_k_read = connect_kdb_read();

  if (!record_existence($dbh_k_read, 'generalunit', 'UnitId', $unit_id)) {

    my $err_msg = "unitid ($unit_id): not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'unitid' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my ($is_layer_ok, $trouble_layer_id_aref) = check_permission($dbh_gis_write, 'layer', 'id',
                                                               [$layer_id], $group_id, $gadmin_status,
                                                               $LINK_PERM);

  if (!$is_layer_ok) {

    my $trouble_layer_id = $trouble_layer_id_aref->[0];
    my $err_msg = "Permission denied: Group ($group_id) and Layer ($trouble_layer_id).";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($validation) == 0) {

    $validation = undef;
  }

  $sql    = 'INSERT INTO layerattrib (layer, colname, coltype, colsize, validation, colunits, unitid) ';
  $sql   .= 'VALUES (?, ?, ?, ?, ?, ?, ?)';

  my $sth = $dbh_gis_write->prepare($sql);
  $sth->execute($layer_id, $colname, $coltype, $colsize, $validation, $colunits, $unit_id);

  if ($dbh_gis_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  my $l_attrib_id = $dbh_gis_write->last_insert_id(undef, undef, 'layerattrib', 'id');

  if (uc($layer_type) eq '2D') {

    my ($err_status, $postrun_href) = $self->add_layer2d_column($dbh_gis_write, $layer_id, [$colname]);

    if ($err_status) {

      return $postrun_href;
    }
  }

  $dbh_gis_write->disconnect();

  my $info_msg_aref  = [{'Message' => "Layer Attribute ($l_attrib_id) has been added to Layer ($layer_id) successfully."}];
  my $return_id_aref = [{'Value' => "$l_attrib_id", 'ParaName' => 'id', 'colname' => "$colname"}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub add_layer_attribute_bulk_runmode {

=pod add_layer_attribute_bulk_HELP_START
{
"OperationName": "Add layer attributes",
"Description": "Add a new set of attributes to a GIS layer specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Attribute(s) have been added to layer (9) successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Attribute(s) have been added to layer (8) successfully.'}]}",
"ErrorMessageXML": [{}],
"ErrorMessageJSON": [{}],
"RequiredUpload": 1,
"UploadFileFormat": "XML",
"UploadFileParameterName": "uploadfile",
"DTDFileNameForUploadXML": "layerattrib.dtd",
"URLParameter": [{"ParameterName": "id", "Description": "Existing LayerId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $layer_id = $self->param('id');

  my $dbh_gis_write = connect_gis_write();

  my $layer_type = read_cell_value($dbh_gis_write, 'layer', 'layertype', 'id', $layer_id);

  if (length($layer_type) == 0) {

    my $err_msg = "Layer ($layer_id) not found";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($get_scol_err, $get_scol_msg, $scol_data, $pkey_data) = get_static_field($dbh_gis_write, 'layerattrib');

  if ($get_scol_err) {

    $self->logger->debug("Get static field info failed: $get_scol_msg");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $attribute_xml_file = $self->authen->get_upload_file();
  my $attribute_dtd_file = $self->get_layer_attribute_dtd_file();

  add_dtd($attribute_dtd_file, $attribute_xml_file);

  $self->logger->debug("Attribute XML file: $attribute_xml_file");

  my $xml_checker_parser = new XML::Checker::Parser( Handlers => { } );

  eval {

    local $XML::Checker::FAIL = sub {

      my $code = shift;
      my $err_str = XML::Checker::error_string ($code, @_);
      $self->logger->debug("XML Parsing ERR: $code : $err_str");
      die $err_str;
    };
    $xml_checker_parser->parsefile($attribute_xml_file);
  };

  if ($@) {

    my $err_msg = $@;
    $self->logger->debug("Parsing XML error: $err_msg");
    my $user_err_msg = "Layer attribute xml file does not comply with its definition.\n";
    $user_err_msg   .= "Details: $err_msg";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $user_err_msg}]};

    return $data_for_postrun_href;
  }

  my $attribute_xml  = read_file($attribute_xml_file);
  my $attribute_aref = xml2arrayref($attribute_xml, 'layerattrib');

  my $sql = '';
  my $colname_lookup = {};

  my $dbh_k_read = connect_kdb_read();

  for my $layer_at (@{$attribute_aref}) {

    my $colsize_info          = {};
    my $chk_maxlen_field_href = {};

    for my $static_field (@{$scol_data}) {

      my $field_name  = $static_field->{'Name'};
      my $field_dtype = $static_field->{'DataType'};

      if (lc($field_dtype) eq 'text') {

        $colsize_info->{$field_name}           = $static_field->{'ColSize'};
        $chk_maxlen_field_href->{$field_name}  = $layer_at->{$field_name};
      }
    }

    my ($maxlen_err, $maxlen_msg) = check_maxlen($chk_maxlen_field_href, $colsize_info);

    if ($maxlen_err) {

      $maxlen_msg .= 'longer than its maximum length';

      $data_for_postrun_href->{'Error'}       = 1;
      $data_for_postrun_href->{'Data'}        = {'Error' => [{'Message' => $maxlen_msg}]};

      return $data_for_postrun_href;
    }

    my $unit_id = $layer_at->{'unitid'};

    if (!record_existence($dbh_k_read, 'generalunit', 'UnitId', $unit_id)) {

      my $err_msg = "unitid ($unit_id): not found";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $colname = $layer_at->{'colname'};

    if ( $colname !~ /^[a-zA-Z0-9_]+$/ ) {

      my $err_msg = "colname ($colname): invalid character.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    $sql = 'SELECT id FROM layerattrib WHERE layer=? AND colname=?';

    my ($chk_colname_err, $layerattrib_id) = read_cell($dbh_gis_write, $sql, [$layer_id, $colname]);

    if ($chk_colname_err) {

      $self->logger->debug("Check if colname exists failed");
      my $err_msg = "Unexpected Error.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if (length($layerattrib_id) > 0) {

      my $err_msg = "colname ($colname) in layer ($layer_id): already exists.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if ($colname_lookup->{lc($colname)}) {

      my $err_msg = "colname ($colname): duplicate.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    else {

      $colname_lookup->{lc($colname)} = 1;
    }
  }

  $dbh_k_read->disconnect();

  my $sth;
  for my $layer_at (@{$attribute_aref}) {

    $sql  = 'INSERT INTO layerattrib ';
    $sql .= '(layer, colname, coltype, colsize, validation, colunits, unitid) ';
    $sql .= 'VALUES (?, ?, ?, ?, ?, ?, ?)';

    $sth = $dbh_gis_write->prepare($sql);
    $sth->execute($layer_id, lc($layer_at->{'colname'}),
                  $layer_at->{'coltype'}, $layer_at->{'colsize'},
                  $layer_at->{'validation'}, $layer_at->{'colunits'},
                  $layer_at->{'unitid'});

    if ($dbh_gis_write->err()) {

      $self->logger->debug('INSERT Data to layerattrib table failed');

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }
    $sth->finish();
  }

  if (uc($layer_type) eq '2D') {

    my @colname_list = keys(%{$colname_lookup});

    my ($err_status, $postrun_href) = $self->add_layer2d_column($dbh_gis_write, $layer_id, \@colname_list);

    if ($err_status) {

      return $postrun_href;
    }
  }

  $dbh_gis_write->disconnect();

  my $info_msg_aref = [{'Message' => "Attribute(s) have been added to layer ($layer_id) successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub export_layer_data_shape_runmode {

=pod export_layer_data_shape_HELP_START
{
"OperationName": "Export GIS data",
"Description": "Export GIS dataset in either shape or csv format for the layer specified by id. CSV format contains description of geometric object using WKT (Well Known Text) notation.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><OutputFile shp='http://kddart-d.diversityarrays.com/data/admin/export_1_6_1_4_3_7_2_5__68fe6e93f44f5120d599477caef61d6a.shp' csv='http://kddart-d.diversityarrays.com/data/admin/export_1_6_1_4_3_7_2_5__68fe6e93f44f5120d599477caef61d6a.csv' dbf='http://kddart-d.diversityarrays.com/data/admin/export_1_6_1_4_3_7_2_5__68fe6e93f44f5120d599477caef61d6a.dbf' shx='http://kddart-d.diversityarrays.com/data/admin/export_1_6_1_4_3_7_2_5__68fe6e93f44f5120d599477caef61d6a.shx' /></DATA>",
"SuccessMessageJSON": "{'OutputFile' : [{'shp' : 'http://kddart-d.diversityarrays.com/data/admin/export_1_6_1_4_3_7_2_5__68fe6e93f44f5120d599477caef61d6a.shp','csv' : 'http://kddart-d.diversityarrays.com/data/admin/export_1_6_1_4_3_7_2_5__68fe6e93f44f5120d599477caef61d6a.csv','dbf' : 'http://kddart-d.diversityarrays.com/data/admin/export_1_6_1_4_3_7_2_5__68fe6e93f44f5120d599477caef61d6a.dbf','shx' : 'http://kddart-d.diversityarrays.com/data/admin/export_1_6_1_4_3_7_2_5__68fe6e93f44f5120d599477caef61d6a.shx'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPParameter": [{"Required": 0, "Name": "AttributeIdCSV", "Description": "Comma separated value of wanted layer attribute id list"}, {"Required": 0, "Name": "TimeFrom", "Description": "The starting time of wanted layer data. It is inclusive."}, {"Required": 0, "Name": "TimeTo", "Description": "The ending time of wanted layer data. It is inclusive"}, {"Required": 0, "Name": "AOITopLeftLong", "Description": "Area of Interest longitude. Area of Interest parameters define a rectangular geographic area where wanted data were recorded. If data over an area of interest is wanted, all four parameter must be provided."}, {"Required": 0, "Name": "AOITopLeftLat", "Description": "Area of Interest latitude"}, {"Required": 0, "Name": "AOIBottomRightLong", "Description": "Area of Interest bottom right longitude"}, {"Required": 0, "Name": "AOIBottomRightLat", "Description": "Area of Interest bottom right latitude"}, {"Required": 0, "Name": "DeviceIdCSV", "Description": "Comma separated value of wanted device ids."}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing LayerId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $layer_id = $self->param('id');

  my $selected_attr_csv      = $query->param('AttributeIdCSV');
  my $time_from              = $query->param('TimeFrom');
  my $time_to                = $query->param('TimeTo');
  my $aoi_topleft_long       = $query->param('AOITopLeftLong');
  my $aoi_topleft_lat        = $query->param('AOITopLeftLat');
  my $aoi_bottomright_long   = $query->param('AOIBottomRightLong');
  my $aoi_bottomright_lat    = $query->param('AOIBottomRightLat');
  my $device_id_csv          = $query->param('DeviceIdCSV');

  my $time_filter = '';
  if (length($time_from) > 0) {

    my ($time_from_err, $time_from_msg) = check_dt_value( { 'TimeFrom' => $time_from } );

    if ($time_from_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => "$time_from_msg not date/time."}]};

      return $data_for_postrun_href;
    }

    $time_filter .= " dt > '$time_from' ";
  }

  if (length($time_to) > 0) {

    my ($time_to_err, $time_to_msg) = check_dt_value( { 'TimeTo' => $time_to } );

    if ($time_to_err) {

      my $err_msg = "$time_to_msg not date/time.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if (length($time_filter) > 0) {

      $time_filter .= " AND dt <= '$time_to' ";
    }
    else {

      $time_filter .= " dt <= '$time_to' ";
    }
  }

  my $all_aoi_present = 1;
  my $all_aoi_absent  = 1;

  for my $aoi_param (($aoi_topleft_long, $aoi_topleft_lat, $aoi_bottomright_long, $aoi_bottomright_lat)) {

    if (length($aoi_param) == 0) {

      $all_aoi_present = 0;
    }

    if (length($aoi_param) != 0) {

      $all_aoi_absent = 0;
    }
  }

  if ( (!$all_aoi_present) && (!$all_aoi_absent) ) {

    my $msg = 'Area of Interest (AOI) parameters must be all present or all absent.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $msg}]};

    return $data_for_postrun_href;
  }

  if ($all_aoi_present) {

    my ($float_err, $float_msg) = check_float_value( {'AOITopLeftLong'     => $aoi_topleft_long,
                                                      'AOITopLeftLat'      => $aoi_topleft_lat,
                                                      'AOIBottomRightLong' => $aoi_bottomright_long,
                                                      'AOIBottomRightLat'  => $aoi_bottomright_lat,
                                                     });

    if ($float_err ) {

      $float_msg .= ' not compliant with the non-scientific floating point format.';
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $float_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $dbh = connect_gis_read();

  my $sql = '';

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 1, $gadmin_status);

  $sql    = "SELECT $perm_str AS UltimatePerm FROM layer WHERE lower(CAST(id AS VARCHAR(255)))=?";

  my ($read_perm_err, $perm_val) = read_cell($dbh, $sql, [$layer_id]);

  if (length($perm_val) == 0) {

    my $err_msg = "Layer ($layer_id) does not exist.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }
  else {

    $self->logger->debug("Perm val: $perm_val");

    if ( ($perm_val & $LINK_PERM) != $LINK_PERM ) {

      my $err_msg = "Permission denied: layer ($layer_id).";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $layertype = read_cell_value($dbh, 'layer', 'layertype', 'id', $layer_id);

  if (uc($layertype) eq '2D') {

    my $err_msg = "Layer ($layer_id) is 2D layer.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $db_device_id_csv = '';

  if (length($device_id_csv) > 0) {

    my $csv_parser = Text::CSV->new ( { binary => 1 } );

    my $success = $csv_parser->parse($device_id_csv);

    if (!$success) {

      my $err_msg = "DeviceIdCSV ($device_id_csv): not valid CSV.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my @device_id_list = $csv_parser->fields();

    my @db_device_id_list;

    foreach my $dev_id (@device_id_list) {

      $dev_id = trim($dev_id);
      $dev_id =~ s/^'//g;
      $dev_id =~ s/'$//g;

      push(@db_device_id_list, "'$dev_id'");
    }

    $db_device_id_csv = join(',', @db_device_id_list);
  }

  $sql    = 'SELECT id, colname, colsize FROM layerattrib WHERE layer=?';

  my $sth = $dbh->prepare($sql);
  $sth->execute($layer_id);

  if ($dbh->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $attr_info_href = $sth->fetchall_hashref('id');

  if (scalar(keys(%{$attr_info_href})) == 0) {

    my $msg_aref = [{'Message' => "There is no attribute defined for layer ($layer_id)."}];

    $data_for_postrun_href->{'Error'} = 0;
    $data_for_postrun_href->{'Data'}  = {'Info' => $msg_aref};

    return $data_for_postrun_href;
  }

  if (length($selected_attr_csv) == 0) {

    $selected_attr_csv = join(',', keys(%{$attr_info_href}));
  }

  $sth->finish();

  my @selected_attr = split(/,/, $selected_attr_csv);
  my $attr_list_str      = '';
  my $attr_csv_colheader = '';
  my $shp_fieldtype      = [];
  my $shp_fieldname      = [];
  my $csv_colnum         = [];

  push(@{$shp_fieldname}, 'dt');
  push(@{$shp_fieldtype}, 'String:19');      # for dt (datetime) field
  push(@{$csv_colnum}, 2);

  $sql = 'SELECT layerid, dt, deviceid, ST_AsText(geometry) AS geo, ';

  my $attr_counter = 1;
  for my $sel_attr (@selected_attr) {

    if (!$attr_info_href->{$sel_attr}) {

      my $err_msg = "Layer ($layer_id) does not contain attribute ($sel_attr).";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    $attr_list_str .= "${sel_attr}_";

    $attr_info_href->{$sel_attr}->{'colname'} =~ s/\s/_/g;

    my $attr_name = $attr_info_href->{$sel_attr}->{'colname'};
    my $attr_size = $attr_info_href->{$sel_attr}->{'colsize'};
    my $attr_sql = pg_case_st('=', 'layerattrib', $sel_attr, 'value', 'null');
    $attr_sql    = "group_concat($attr_sql) AS $attr_name,";

    $sql .= $attr_sql;
    $attr_csv_colheader .= "$attr_name,";
    push(@{$shp_fieldtype}, "String:$attr_size");
    push(@{$shp_fieldname}, $attr_name);
    push(@{$csv_colnum}, 3+$attr_counter);
    $attr_counter += 1;
  }

  chop($sql);                 # removing excessive trailing comma
  chop($attr_csv_colheader);  # removing excessive trailing comma

  $sql .= " FROM layer${layer_id} LEFT JOIN layer${layer_id}attrib ON ";
  $sql .= " layer${layer_id}.id = layer${layer_id}attrib.layerid ";
  $sql .= " GROUP BY layerid, dt, geometry, deviceid ";

  my $having = '';

  if (length($time_filter) > 0) {

    $having .= " $time_filter ";
  }

  if ($all_aoi_present) {

    if (length($having) > 0) {

      $having .= ' AND ';
    }

    my $aoi_polyring = "($aoi_topleft_long $aoi_topleft_lat, ";
    $aoi_polyring   .= "$aoi_bottomright_long $aoi_topleft_lat, ";
    $aoi_polyring   .= "$aoi_bottomright_long $aoi_bottomright_lat, ";
    $aoi_polyring   .= "$aoi_topleft_long $aoi_bottomright_lat, ";
    $aoi_polyring   .= "$aoi_topleft_long $aoi_topleft_lat)";

    my $aoi_polygon  = "ST_GeomFromText('POLYGON($aoi_polyring)')";
    $having .= " ST_Within(ST_GeomFromText(ST_AsText(geometry)), $aoi_polygon)";
  }

  if (length($db_device_id_csv) > 0) {

    if (length($having) > 0) {

      $having .= ' AND ';
    }

    $having .= " deviceid IN ($db_device_id_csv) ";
  }

  if (length($having) > 0) {

    $sql .= " HAVING $having ";
  }

  $sql .= " ORDER BY layerid, dt ASC ";

  $self->logger->debug("SQL: $sql");

  my $export_data_sql_md5 = md5_hex($sql);

  $self->logger->debug("SQL: $sql");

  my $username          = $self->authen->username();
  my $doc_root          = $ENV{'DOCUMENT_ROOT'};
  my $export_data_path  = "${doc_root}/data/$username";
  my $current_runmode   = $self->get_current_runmode();
  my $lock_filename     = "${current_runmode}.lock";
  my $filename          = "export_${layer_id}_${attr_list_str}_$export_data_sql_md5";
  my $shp_file          = "${export_data_path}/$filename";
  my $csv_file          = $shp_file . '.csv';

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

  $sth = $dbh->prepare($sql);
  $sth->execute();

  if ($dbh->err()) {

    $lockfile->remove();
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("csv: $csv_file");

  open(my $layer_csv_fh, ">$csv_file") or die "Can't open $csv_file for writing: $!";

  print $layer_csv_fh "#longitude,latitude,dt,deviceid,$attr_csv_colheader\n";

  my $data_in_csv_counter = 0;
  while ( my $row_aref = $sth->fetchrow_arrayref() ) {

    my $geo = $row_aref->[3];

    if ($geo =~ /POINT\((.+) (.+)\)/) {

      my $lng = $1;
      my $lat = $2;

      my $dt       = $row_aref->[1];
      my $dev_id   = $row_aref->[2];
      my $csv_line = "$lng,$lat,$dt,$dev_id,";

      for(my $i = 0; $i < scalar(@selected_attr); $i++) {

        # in theory, there could be duplicate records.
        # but in practice, duplicate records should be rare.
        my $unsplitted_attr_val = $row_aref->[4+$i];
        my @splited_attr_val = split(/ /, $unsplitted_attr_val);
        my $attr_val = $splited_attr_val[0];
        $csv_line .= "$attr_val,";
      }

      chop($csv_line);          # remove excessive trailing comma
      print $layer_csv_fh "$csv_line\n";
      $data_in_csv_counter += 1;
    }
  }

  close($layer_csv_fh);

  if ($data_in_csv_counter == 0) {

    $lockfile->remove();
    my $msg_aref = [{'Message' => "Layer ($layer_id): no POINT data matched the filtering criteria."}];

    $data_for_postrun_href->{'Error'}     = 0;
    $data_for_postrun_href->{'Data'}      = {'Info' => $msg_aref};
    $data_for_postrun_href->{'ExtraData'} = 0;

    return $data_for_postrun_href;
  }

  $self->logger->debug("CSV file: $csv_file - csv colnum: " . join(',', @{$csv_colnum}));

  csvfile2shp($csv_file, $shp_file, $csv_colnum, $shp_fieldname, $shp_fieldtype);

  $lockfile->remove();

  $sth->finish();

  $self->logger->debug("Document root: $doc_root");

  $dbh->disconnect();

  my $url = reconstruct_server_url();

  my $href_info = { 'csv' => "$url/data/$username/${filename}.csv",
                    'shp' => "$url/data/$username/${filename}.shp",
                    'dbf' => "$url/data/$username/${filename}.dbf",
                    'shx' => "$url/data/$username/${filename}.shx",
  };

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'OutputFile' => [$href_info] };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub import_layer_data_csv_bulk_runmode {

=pod import_layer_data_csv_HELP_START
{
"OperationName": "Import GIS data",
"Description": "Import GIS dataset from csv file into a layer specified by id. Geometry objects have to be described in WKT (Well Known Text) notation.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Data for attribute(s) (30,29) has been imported into layer (10). Data insertion took 0.231101 seconds.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Data for attribute(s) (30,29) has been imported into layer (10). Data insertion took 0.165007 seconds.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Layer (15) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Layer (15) not found.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "CSV",
"UploadFileParameterName": "uploadfile",
"HTTPParameter": [{"Required": 1, "Name": "geometry", "Description": "Column number starting from zero in the upload CSV file in which geometry well known text values locate."}, {"Required": 1, "Name": "timestamp", "Description": "Column number starting from zero in the upload CSV file in which timestamp values locate."}, {"Required": 1, "Name": "attrib_[layerattribid]", "Description": "[layerattribid] must be replaced with the actual value for the particular layer attribute id. This parameter represents a column number starting from zero in the upload CSV file in which attribute values (data) locate. There could be more than one of this column in the CSV file. If there is more than one column, all data column mapping parameters must be provided using this template that [layerattribid] must be replaced with the actual value for the corresponding layer attribute id."}, {"Required": 0, "Name": "deviceid", "Description": "Column number starting from zero in the upload CSV file in which deviceid values locate."}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing LayerId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $layer_id = $self->param('id');

  if ( !($layer_id =~ /^\d+$/) ) {

    my $err_msg = "Layer ($layer_id) is not an integer.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_gis_read = connect_gis_read();

  my $sql = 'SELECT layer.id as layerid, layerattrib.id as layerattribid ';
  $sql   .= 'FROM layer LEFT JOIN layerattrib ON layer.id = layerattrib.layer ';
  $sql   .= 'WHERE layer.id=?';

  my $sth = $dbh_gis_read->prepare($sql);
  $sth->execute($layer_id);

  if ($dbh_gis_read->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $layer_info = $sth->fetchall_arrayref({});

  $sth->finish();

  if (scalar(@{$layer_info}) == 0) {

    my $err_msg = "Layer ($layer_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$layer_info}) == 1 && length($layer_info->[0]->{'layerattribid'}) == 0) {

    my $err_msg = "Layer ($layer_id) does not have any attribute defined.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($perm_ok, $trouble_layer_aref) = check_permission($dbh_gis_read, 'layer', 'id',
                                                        [$layer_id], $group_id, $gadmin_status,
                                                        $LINK_PERM);

  if (!$perm_ok) {

    my $err_msg = "Permission denied: Group ($group_id) and layer ($layer_id).";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $layertype = read_cell_value($dbh_gis_read, 'layer', 'layertype', 'id', $layer_id);

  if (uc($layertype) eq '2D') {

    my $err_msg = "Layer ($layer_id) is 2D layer.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $data_csv_file = $self->authen->get_upload_file();

  my $num_of_col = get_csvfile_num_of_col($data_csv_file);

  $self->logger->debug("Number of columns: $num_of_col");

  my $matched_col    = {};
  my @matched_attrib;

  for my $layer_record (@{$layer_info}) {

    my $attrib_id        = $layer_record->{'layerattribid'};
    my $attrib_para_name = "attrib_${attrib_id}";
    my $attrib_col       = $query->param($attrib_para_name);

    if (length($attrib_col) > 0) {

      if ($attrib_col =~ /^\d+$/) {

        if ($attrib_col >= $num_of_col) {

          my $msg = "Parameter ($attrib_para_name) is not consistent with the number of columns in the csv file.";

          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $msg}]};

          return $data_for_postrun_href;
        }
        else {

          $matched_col->{$attrib_col} = $attrib_para_name;
          push(@matched_attrib, $attrib_id);
        }
      }
      else {

        my $msg = "Parameter ($attrib_para_name) is not an integer specifying the column in the csv file.";

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $msg}]};

        return $data_for_postrun_href;
      }
    }
  }

  if (scalar(@matched_attrib) == 0) {

    my $msg = "No layer ($layer_id) attribute matched.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $msg}]};

    return $data_for_postrun_href;
  }

  my $attrib_id_csv = join(',', @matched_attrib);

  $self->logger->debug("Matched attributes: $attrib_id_csv");

  $sql  = 'SELECT id, validation ';
  $sql .= 'FROM layerattrib ';
  $sql .= "WHERE id IN ($attrib_id_csv)";

  $sth = $dbh_gis_read->prepare($sql);

  $sth->execute();

  if ($dbh_gis_read->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $attrib_validation = $sth->fetchall_hashref('id');

  my $geometry_type = read_cell_value($dbh_gis_read, 'layer', 'geometrytype', 'id', $layer_id);

  $dbh_gis_read->disconnect();

  my $geometry_col  = $query->param('geometry');
  my $timestamp_col = $query->param('timestamp');

  my $chk_col_href = { 'geometry'  => $geometry_col,
                       'timestamp' => $timestamp_col };

  if (defined $query->param('deviceid')) {

    if (length($query->param('deviceid')) > 0) {

      my $deviceid_col = $query->param('deviceid');
      $matched_col->{$deviceid_col} = 'deviceid';

      $chk_col_href->{'deviceid'} = $deviceid_col;
    }
  }

  my ($col_def_err, $col_def_msg) = check_col_definition( $chk_col_href,
                                                          $num_of_col );

  if ($col_def_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $col_def_msg}]};

    return $data_for_postrun_href;
  }

  $matched_col->{$geometry_col}  = 'geometry';
  $matched_col->{$timestamp_col} = 'timestamp';

  my @fieldname_list;
  for (my $i = 0; $i < $num_of_col; $i++) {

    if ($matched_col->{$i}) {

      push(@fieldname_list, $matched_col->{$i});
    }
    else {

      push(@fieldname_list, 'null');
    }
  }

  $self->logger->debug("Fieldname list: " . join(',', @fieldname_list));

  my ($data_aref, $csv_err, $err_msg) = csvfile2arrayref($data_csv_file, \@fieldname_list);

  if ($csv_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_gis_write = connect_gis_write();

  my %inserted_attr_val_id;
  my $user_id = $self->authen->user_id();

  my $data_insertion_start_time = [gettimeofday()];

  my $uniq_deviceid_attr_href  = {};

  my $row_counter = 0;
  for my $data_row (@{$data_aref}) {

    my $geometry = $data_row->{'geometry'};

    my ($is_wkt_err, $wkt_err_href) = is_valid_wkt_href($dbh_gis_write,
                                                        {'geometry' => $geometry},
                                                        $geometry_type
        );

    if ($is_wkt_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [$wkt_err_href]};

      return $data_for_postrun_href;
    }

    my ($ts_datatype_err, $ts_datatype_msg) = check_dt_value( {'timestamp' => $data_row->{'timestamp'}} );

    if ($ts_datatype_err) {

      $ts_datatype_msg = "Row ($row_counter): " . $ts_datatype_msg . ' data type mismatched.';
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $ts_datatype_msg}]};

      return $data_for_postrun_href;
    }

    my $dev_id = undef;

    if (defined $data_row->{'deviceid'}) {

      $dev_id = $data_row->{'deviceid'};
    }

    for my $attr (@matched_attrib) {

      my $attr_para_name = "attrib_$attr";
      if (length($attrib_validation->{$attr}->{'validation'}) > 0) {

        my $validation = $attrib_validation->{$attr}->{'validation'};
        if ( !($data_row->{$attr_para_name} =~ /$validation/ ) ) {

          my $attr_datatype_msg = "Row ($row_counter): [$attr_para_name, ] validation rule mismatched.";

          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $attr_datatype_msg}]};

          return $data_for_postrun_href;
        }
      }

      if (defined $dev_id) {

        if (defined $uniq_deviceid_attr_href->{$dev_id}) {

          my $attr_href = $uniq_deviceid_attr_href->{$dev_id};
          $attr_href->{"$attr"} = 1;
          $uniq_deviceid_attr_href->{$dev_id} = $attr_href;
        }
        else {

          $uniq_deviceid_attr_href->{$dev_id} = { "$attr" => '1' };
        }
      }
    }

    $row_counter += 1;
  }

  my @uniq_dev_id_list;

  foreach my $dev_id (keys(%{$uniq_deviceid_attr_href})) {

    push(@uniq_dev_id_list, "'$dev_id'");
  }

  my $db_uniq_deviceid_attr_href = {};

  $self->logger->debug("Number of unique deviceid: " . scalar(@uniq_dev_id_list));

  if (scalar(@uniq_dev_id_list) > 0) {

    my $dev_id_csv = join(',', @uniq_dev_id_list);
    my $chk_dev_sql = "SELECT layerattrib, deviceid FROM datadevice ";
    $chk_dev_sql   .= "LEFT JOIN layerattrib ON datadevice.layerattrib = layerattrib.id ";
    $chk_dev_sql   .= "WHERE deviceid IN ($dev_id_csv) AND layer=?";

    $self->logger->debug("UNIQUE DEVICEID CSV: $dev_id_csv");

    my ($r_chk_dev_err, $r_chk_dev_msg, $device_attr_data) = read_data($dbh_gis_write, $chk_dev_sql, [$layer_id]);

    if ($r_chk_dev_err) {

      $self->logger->debug("Read attribute mapping failed: $r_chk_dev_msg");

      my $err_msg = 'Unexpected Error.';
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    foreach my $dev_attr_rec (@{$device_attr_data}) {

      my $dev_id  = $dev_attr_rec->{'deviceid'};
      my $attr_id = $dev_attr_rec->{'layerattrib'};

      if (defined $db_uniq_deviceid_attr_href->{$dev_id}) {

        my $attr_href = $db_uniq_deviceid_attr_href->{$dev_id};
        $attr_href->{"$attr_id"} = '1';
        $db_uniq_deviceid_attr_href->{$dev_id} = $attr_href;
      }
      else {

        $db_uniq_deviceid_attr_href->{$dev_id} = { "$attr_id" => '1' };
      }
    }
  }

  foreach my $dev_id (keys(%{$uniq_deviceid_attr_href})) {

    if (! defined $db_uniq_deviceid_attr_href->{"$dev_id"}) {

      my $err_msg = "DeviceId ($dev_id): not found in layer attribute mapping.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $attr_href = $uniq_deviceid_attr_href->{"$dev_id"};

    my $db_attr_href = $db_uniq_deviceid_attr_href->{"$dev_id"};

    foreach my $attr (keys(%{$attr_href})) {

      if (! defined $db_attr_href->{"$attr"}) {

        my $err_msg = "DeviceId ($dev_id) and layer attribute ($attr): not found in layer attribute mapping for layer ($layer_id).";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
  }

  my $bulk_sql = '';
  $bulk_sql   .= "INSERT INTO layer${layer_id}attrib ";
  $bulk_sql   .= "(layerid,layerattrib,value,dt,systemuserid,deviceid) ";
  $bulk_sql   .= "VALUES ";

  $row_counter = 0;
  for my $data_row (@{$data_aref}) {

    my $geometry = $data_row->{'geometry'};

    my $geo_obj_str = qq{ST_GeomFromText('$geometry', -1)};
    my $within_str  = "ST_DWithin($geo_obj_str, geometry, $GIS_BUFFER_DISTANCE)";

    $sql = "SELECT id from layer${layer_id} WHERE $within_str LIMIT 1";
    $sth = $dbh_gis_write->prepare($sql);
    $sth->execute();

    if ($dbh_gis_write->err()) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $geo_id = '';
    $sth->bind_col(1, \$geo_id);
    $sth->fetch();
    $sth->finish();

    if (length($geo_id) == 0) {

      $sql = "INSERT INTO layer${layer_id}(geometry) VALUES($geo_obj_str)";
      $sth = $dbh_gis_write->prepare($sql);
      $sth->execute();

      if ($dbh_gis_write->err()) {

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

        return $data_for_postrun_href;
      }

      $geo_id = $dbh_gis_write->last_insert_id(undef, undef, "layer${layer_id}", 'id');
      $sth->finish();
    }

    for my $attr (@matched_attrib) {

      my $attr_para_name = "attrib_$attr";
      my $para_val       = $data_row->{$attr_para_name};
      my $para_dt        = $data_row->{'timestamp'};

      #print $bulk_insert_fh "$geo_id,$attr,$para_val,$para_dt,$user_id\n";

      my $db_para_val = $dbh_gis_write->quote($para_val);

      my $db_deviceid = 'NULL';

      if (defined $data_row->{'deviceid'}) {

        if (length($data_row->{'deviceid'}) > 0) {

          $db_deviceid = $dbh_gis_write->quote($data_row->{'deviceid'});
        }
      }

      $bulk_sql .= "($geo_id,$attr,$db_para_val,'$para_dt',$user_id,$db_deviceid),";
    }

    $row_counter += 1;
  }

  #close($bulk_insert_fh);

  #$sql  = "COPY layer${layer_id}attrib ";
  #$sql .= "(layerid,layerattrib,value,dt,systemuserid) ";
  #$sql .= "FROM '${bulk_insert_fname}' WITH DELIMITER AS ','";

  chop($bulk_sql);

  $sth = $dbh_gis_write->prepare($bulk_sql);
  $sth->execute();

  $bulk_sql = '';

  if ($dbh_gis_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  my $data_insertion_elapsed = tv_interval($data_insertion_start_time);

  $dbh_gis_write->disconnect();

  my $attr_id_csv = join(',', @matched_attrib);

  my $msg = "Data for attribute(s) ($attr_id_csv) has been imported into layer ($layer_id). ";
  $msg   .= "Data insertion took $data_insertion_elapsed seconds.";

  my $info_msg_aref = [{'Message' => $msg}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub del_device_registration_runmode {

=pod del_device_registration_gadmin_HELP_START
{
"OperationName": "Delete device",
"Description": "Delete device from the system specified by id. Device can only be deleted if it is not attached to lower level records in the database.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='DeviceRegister (9) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'DeviceRegister (8) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdUsed": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='DeviceRegister (5) has attribute mapping assigned.' /></DATA>"}],
"ErrorMessageJSON": [{"IdUsed": "{'Error' : [{'Message' : 'DeviceRegister (5) has attribute mapping assigned.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing DeviceRegisterId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self   = shift;
  my $reg_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_k_read = connect_kdb_read();

  my $device_id = read_cell_value($dbh_k_read, 'deviceregister', 'DeviceId', 'DeviceRegisterId', $reg_id);

  if (length($device_id) == 0) {

    my $err_msg = "DeviceRegister ($reg_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (record_existence($dbh_k_read, 'item', 'ScaleId', $device_id)) {

    my $err_msg = "DeviceRegister ($reg_id) is used in item.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_gis_read = connect_gis_read();

  my $attr_map_exist = record_existence($dbh_gis_read, 'datadevice', 'DeviceId', $device_id);

  if ($attr_map_exist) {

    my $err_msg = "DeviceRegister ($reg_id) has attribute mapping assigned.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_gis_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $sql = 'DELETE FROM deviceregister WHERE DeviceRegisterId=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($reg_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref = [{'Message' => "DeviceRegister ($reg_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_layer_runmode {

=pod update_layer_HELP_START
{
"OperationName": "Update layer",
"Description": "Update GIS layer definition",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "environment",
"KDDArTTable": "layer",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Layer (11) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Layer (11) has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Layer (20) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Layer (20) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing LayerId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self        = shift;
  my $query       = $self->query();
  my $layer_id    = $self->param('id');

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_gis_read();

  my $skip_field = {'layertypetype'    => 1,
                    'createuser'       => 1,
                    'createtime'       => 1,
                    'lastupdatetime'   => 1,
                    'lastupdateuser'   => 1,
                    'owngroupid'       => 1,
                    'srid'             => 1,
                   };

  my $field_name_translation = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'layer', $skip_field,
                                                                                $field_name_translation,
                                                                               );

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $dbh_write = connect_gis_write();

  if (!record_existence($dbh_write, 'layer', 'id', $layer_id)) {

    my $err_msg = "Layer ($layer_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_write_ok, $trouble_layer_id_aref) = check_permission($dbh_write, 'layer', 'id', [$layer_id],
                                                               $group_id, $gadmin_status, $READ_WRITE_PERM);

  if (!$is_write_ok) {

    my $err_msg = "Layer ($layer_id) permission denied.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $read_layer_sql    =    'SELECT parent, layermetadata, srid, alias, ';
     $read_layer_sql   .=    'description, layertype, geometrytype ';
     $read_layer_sql   .=    'FROM layer WHERE id=? ';

  my ($r_df_val_err, $r_df_val_msg, $layer_df_val_data) = read_data($dbh_write, $read_layer_sql, [$layer_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve layer default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $parent_layer         =   undef;
  my $layer_mdata          =   undef;
  my $layer_srid           =   undef;
  my $layer_alias          =   undef;
  my $layer_description    =   undef;
  my $db_layer_type        =   undef;
  my $db_geometry_type     =   undef;

  my $nb_df_val_rec    =  scalar(@{$layer_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve layer default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $parent_layer         =   $layer_df_val_data->[0]->{'parent'};
  $layer_mdata          =   $layer_df_val_data->[0]->{'layermetadata'};
  $layer_srid           =   $layer_df_val_data->[0]->{'srid'};
  $layer_alias          =   $layer_df_val_data->[0]->{'alias'};
  $layer_description    =   $layer_df_val_data->[0]->{'description'};
  $db_layer_type        =   $layer_df_val_data->[0]->{'layertype'};
  $db_geometry_type     =   $layer_df_val_data->[0]->{'geometrytype'};


  if (length($parent_layer) == 0) {

    $parent_layer = undef;
  }

  if (defined $query->param('parent')) {

    if (length($query->param('parent')) > 0) {

      $parent_layer = $query->param('parent');
    }
  }

  my $layer_name = $query->param('layername');

  if (length($layer_mdata) == 0) {

    $layer_mdata = undef;
  }

  if (defined $query->param('layermetadata')) {

    if (length($query->param('layermetadata')) > 0) {

      $layer_mdata = $query->param('layermetadata');
    }
  }

  my $is_editable = $query->param('iseditable');

  if (length($layer_srid) == 0) {

    $layer_srid = undef;
  }

  if (defined $query->param('srid')) {

    if (length($query->param('srid')) > 0) {

      $layer_srid = $query->param('srid');
    }
  }

  if (length($layer_srid) > 0) {

    my ($int_err, $int_msg_href) = check_integer_href( { 'srid'            => $layer_srid } );

    if ($int_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [$int_msg_href]};

      return $data_for_postrun_href;
    }
  }


  if ( length($query->param('alias')) > 0 ) { $layer_alias = $query->param('alias'); }

  if ( length($query->param('description')) > 0 ) { $layer_description = $query->param('description'); }

  my $chk_layer_name_sql = 'SELECT name FROM layer WHERE name = ? AND id != ? LIMIT 1';

  my ($r_l_name_err, $layer_name_db) = read_cell($dbh_write, $chk_layer_name_sql, [$layer_name, $layer_id]);

  if ($r_l_name_err) {

    $self->logger->debug("Check layer name failed.");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  if (length($layer_name_db) > 0) {

    my $err_msg = "Layer name ($layer_name) already exists.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'name' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( defined $parent_layer ) {

    my $parent_layer_existence = record_existence($dbh_write, 'layer', 'id', $parent_layer);

    if (!$parent_layer_existence) {

      my $err_msg = "Parent layer ($parent_layer) does not exist.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'parent' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my ($is_link_ok, $trouble_player_id_aref) = check_permission($dbh_write, 'layer', 'id', [$parent_layer],
                                                                 $group_id, $gadmin_status, $READ_LINK_PERM);

    if (!$is_link_ok) {

      my $err_msg = "Parent layer ($parent_layer) permission denied.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'parent' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }


  my $chk_data_sql = '';

  if (uc($db_layer_type) eq '2D') {

    $chk_data_sql = "SELECT COUNT(*) FROM layer2d$layer_id";
  }
  else {

    $chk_data_sql = "SELECT COUNT(*) FROM layer${layer_id}attrib";
  }

  my ($read_count_err, $nb_record) = read_cell($dbh_write, $chk_data_sql, []);

  if ($read_count_err) {

    $self->logger->debug("Check if colname exists failed");
    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $layer_type = $db_layer_type;

  if (defined $query->param('layertype')) {

    if (length($query->param('layertype')) > 0) {

      $layer_type = $query->param('layertype');

      if ($nb_record > 0) {

        if (uc($layer_type) ne uc($db_layer_type)) {

          my $err_msg = "Layer ($layer_id) has data - layertype cannot be changed.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'layertype' => $err_msg}]};

          return $data_for_postrun_href;
        }
      }
    }
  }


  my $ACCEPTABLE_GEOM_TYPE = { 'POINT'              => 1,
                               'LINESTRING'         => 1,
                               'POLYGON'            => 1,
                               'MULTIPOINT'         => 1,
                               'MULTILINESTRING'    => 1,
                               'MULTIPOLYGON'       => 1,
  };

  my $geometry_type = $db_geometry_type;

  if (defined $query->param('geometrytype')) {

    if (length($query->param('geometrytype')) > 0) {

      $geometry_type = $query->param('geometrytype');

      if ( !($ACCEPTABLE_GEOM_TYPE->{uc($geometry_type)}) ) {

        my $err_msg = "$geometry_type is unacceptable.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'geometrytype' => $err_msg}]};

        return $data_for_postrun_href;
      }

      if ( $nb_record > 0 ) {

        if (uc($layer_type) ne uc($db_layer_type)) {

          my $err_msg = "Layer ($layer_id) has data - geometrytype cannot be changed.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'geometrytype' => $err_msg}]};

          return $data_for_postrun_href;
        }
      }
    }
  }

  my $sql = '';
  $sql   .= 'UPDATE layer SET ';
  $sql   .= 'parent = ?, ';
  $sql   .= 'name = ?, ';
  $sql   .= 'alias = ?, ';
  $sql   .= 'layertype = ?, ';
  $sql   .= 'layermetadata = ?, ';
  $sql   .= 'iseditable = ?, ';
  $sql   .= 'srid = ?, ';
  $sql   .= 'geometrytype = ?, ';
  $sql   .= 'description = ? ';
  $sql   .= 'WHERE id=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($parent_layer, $layer_name, $layer_alias, $layer_type, $layer_mdata,
                $is_editable, $layer_srid, $geometry_type, $layer_description, $layer_id);

  if ($dbh_write->err()) {

    $self->logger->debug("Update layer record failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  if (uc($layer_type) ne uc($db_layer_type)) {

    if (uc($layer_type) eq '2D') {

      my @drop_tname_list = ("layer$layer_id", "layer${layer_id}attrib");

      foreach my $table_name (@drop_tname_list) {

        $sql  = "DROP TABLE $table_name";

        $sth = $dbh_write->prepare($sql);
        $sth->execute();

        if ($dbh_write->err()) {

          $self->logger->debug("Drop table $table_name failed");

          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

          return $data_for_postrun_href;
        }

        $sth->finish();
      }

      my ($err_status, $postrun_href) = $self->mk_2d_layer_data_table($dbh_write,
                                                                      $geometry_type,
                                                                      $layer_srid,
                                                                      $layer_id
                                                                     );

      if ($err_status) {

        return $postrun_href;
      }
    }
    else {

      my $table_name = "layer2d$layer_id";

      $sql  = "DROP TABLE $table_name";

      $sth = $dbh_write->prepare($sql);
      $sth->execute();

      if ($dbh_write->err()) {

        $self->logger->debug("Drop table $table_name failed");

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

        return $data_for_postrun_href;
      }

      $sth->finish();

      my %geo_data_tables = ("layer${layer_id}"        => 'layern',
                             "layer${layer_id}attrib"  => 'layernattrib',
          );

      my %geom_column = ("layer${layer_id}" => 'geometry');

      my ($err_status, $postrun_href) = $self->mk_normal_layer_data_tables($dbh_write,
                                                                           $geometry_type,
                                                                           $layer_srid,
                                                                           \%geo_data_tables,
                                                                           \%geom_column
                                                                          );

      if ($err_status) {

        return $postrun_href;
      }
    }

    # Creating new tables will use the latest geometrytype which $geometry_type;
    # therefore, updating geometrytype is not necessary.

    $db_geometry_type = $geometry_type;
  }

  if (uc($geometry_type) ne uc($db_geometry_type)) {

    my $table_name = '';

    if (uc($layer_type) eq '2D') {

      $table_name = "layer2d$layer_id";
    }
    else {

      $table_name = "layer$layer_id";
    }

    $sql  = "ALTER TABLE $table_name ALTER COLUMN geometry TYPE GEOGRAPHY($geometry_type, $layer_srid)";

    $sth = $dbh_write->prepare($sql);
    $sth->execute();

    if ($dbh_write->err()) {

      $self->logger->debug("Change geometry type to $geometry_type in $table_name failed");

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    $sth->finish();
  }

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "Layer ($layer_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub rollback_cleanup {

  # This is a early rollback_cleanup programmed specifically to delete layer attribute records.
  # It takes a hash reference in the following format.
  # $inserted_id->{'layer_id'} = [layer attribute id 1, layer attribute id 2, ... ]

  my $self        = $_[0];
  my $dbh         = $_[1];
  my $inserted_id = $_[2];

  for my $l_id (keys(%{$inserted_id})) {

    my $id_str = join(',', @{$inserted_id->{$l_id}});
    $id_str =~ s/,$//;

    $self->logger->debug("Deleting $id_str from layer${l_id}attrib");

    my $sql = "DELETE FROM layer${l_id}attrib ";
    $sql   .= "WHERE id IN ($id_str)";

    my $sth = $dbh->prepare($sql);
    $sth->execute();
    $sth->finish();
  }
}

sub mk_normal_layer_data_tables {

  my $self                    = $_[0];
  my $dbh_gis_write           = $_[1];
  my $geometry_type           = $_[2];
  my $layer_srid              = $_[3];
  my $layer_data_table_lookup = $_[4];
  my $geometry_column_lookup  = $_[5];

  my $sql = '';
  my $sth;
  my $data_for_postrun_href = {};
  my $err = 0;

  if (length($geometry_type) == 0) {

    $self->logger->debug("Geometry type empty");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};
    $err = 1;

    return ($err, $data_for_postrun_href);
  }

  for my $dest_geo_table (keys(%{$layer_data_table_lookup})) {

    my $src_geo_table = $layer_data_table_lookup->{$dest_geo_table};

    $sql = "CREATE TABLE $dest_geo_table AS SELECT * FROM $src_geo_table WHERE 1=0";
    $sth = $dbh_gis_write->prepare($sql);
    $sth->execute();

    if ($dbh_gis_write->err()) {

      $self->logger->debug("Creating $dest_geo_table failed");

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};
      $err = 1;

      return ($err, $data_for_postrun_href);
    }

    if ($geometry_column_lookup->{$dest_geo_table}) {

      my $alter_column = $geometry_column_lookup->{$dest_geo_table};

      $sql  = "ALTER TABLE $dest_geo_table ALTER COLUMN $alter_column TYPE ";
      $sql .= "GEOGRAPHY($geometry_type, $layer_srid)";

      $sth = $dbh_gis_write->prepare($sql);
      $sth->execute();

      if ($dbh_gis_write->err()) {

        $self->logger->debug("Changing geometry field in $dest_geo_table failed");

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};
        $err = 1;

        return ($err, $data_for_postrun_href);
      }
    }

    $sql  = "CREATE SEQUENCE ${dest_geo_table}_id_seq START WITH 1 ";
    $sql .= "INCREMENT BY 1 NO MAXVALUE NO MINVALUE CACHE 1 ";
    $sql .= "OWNED BY ${dest_geo_table}.id";

    $sth = $dbh_gis_write->prepare($sql);
    $sth->execute();

    if ($dbh_gis_write->err()) {

      $self->logger->debug("Can't create sequence ${dest_geo_table}_id_seq");

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};
      $err = 1;

      return ($err, $data_for_postrun_href);
    }

    $sql  = "ALTER TABLE $dest_geo_table ";
    $sql .= "ALTER COLUMN id SET DEFAULT nextval('${dest_geo_table}_id_seq') ";

    $sth = $dbh_gis_write->prepare($sql);
    $sth->execute();

    if ($dbh_gis_write->err()) {

      $self->logger->debug("Can't make ${dest_geo_table}.id an auto number.");

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};
      $err = 1;

      return ($err, $data_for_postrun_href);
    }

    $sql  = "ALTER TABLE $dest_geo_table ";
    $sql .= "ADD PRIMARY KEY (id)";

    $sth = $dbh_gis_write->prepare($sql);
    $sth->execute();

    if ($dbh_gis_write->err()) {

      $self->logger->debug("Can't make ${dest_geo_table}.id the primary key.");

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};
      $err = 1;

      return ($err, $data_for_postrun_href);
    }

    $self->logger->debug("Reading POSTGRES Username");

    my ($gis_db_uname, ) = read_uname_pass($RPOSTGRES_UP_FILE->{$ENV{DOCUMENT_ROOT}});

    $self->logger->debug("GIS DB USERNAME: $gis_db_uname");

    $sql = "GRANT ALL ON ${dest_geo_table}_id_seq TO $gis_db_uname";
    $sth = $dbh_gis_write->prepare($sql);
    $sth->execute();

    if ($dbh_gis_write->err()) {

      $self->logger->debug("GRANT ${dest_geo_table}_id_seq to $gis_db_uname failed");

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};
      $err = 1;

      return ($err, $data_for_postrun_href);
    }

    $sql = "GRANT ALL ON $dest_geo_table TO $gis_db_uname";
    $sth = $dbh_gis_write->prepare($sql);
    $sth->execute();

    if ($dbh_gis_write->err()) {

      $self->logger->debug("GRANT $dest_geo_table to $gis_db_uname failed");

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};
      $err = 1;

      return ($err, $data_for_postrun_href);
    }

    if ($dest_geo_table =~ /layer\d+$/) {

      $sql  = "CREATE INDEX ${dest_geo_table}_sp_index ON $dest_geo_table ";
      $sql .= "USING GIST(geometry)";

      $sth = $dbh_gis_write->prepare($sql);
      $sth->execute();

      if ($dbh_gis_write->err()) {

        $self->logger->debug("Can't create a spatial index on $dest_geo_table");

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};
        $err = 1;

        return ($err, $data_for_postrun_href);
      }
    }
  }

  return ($err, $data_for_postrun_href);
}

sub mk_2d_layer_data_table {

  my $self                    = $_[0];
  my $dbh_gis_write           = $_[1];
  my $geometry_type           = $_[2];
  my $layer_srid              = $_[3];
  my $layer_id                = $_[4];

  my $sql = '';
  my $sth;
  my $data_for_postrun_href = {};
  my $err = 0;

  if (length($geometry_type) == 0) {

    $self->logger->debug("Geometry type empty");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};
    $err = 1;

    return ($err, $data_for_postrun_href);
  }

  my $dest_2d_table_name = "layer2d${layer_id}";
  my $src_2d_table_name  = 'layer2dn';

  $sql = "CREATE TABLE $dest_2d_table_name AS SELECT * FROM $src_2d_table_name WHERE 1=0";
  $sth = $dbh_gis_write->prepare($sql);
  $sth->execute();

  if ($dbh_gis_write->err()) {

    $self->logger->debug("Creating $dest_2d_table_name table failed");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};
    $err = 1;

    return ($err, $data_for_postrun_href);
  }

  $sth->finish();

  my $geometry_col_name = 'geometry';

  $sql  = "ALTER TABLE $dest_2d_table_name ";
  $sql .= "ALTER COLUMN $geometry_col_name TYPE GEOGRAPHY($geometry_type, $layer_srid)";

  $sth = $dbh_gis_write->prepare($sql);
  $sth->execute();

  if ($dbh_gis_write->err()) {

    $self->logger->debug("Changing geometry field in $dest_2d_table_name failed");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};
    $err = 1;

    return ($err, $data_for_postrun_href);
  }

  $sth->finish();

  $sql  = "ALTER TABLE $dest_2d_table_name ";
  $sql .= "ALTER COLUMN $geometry_col_name SET NOT NULL";

  $sth = $dbh_gis_write->prepare($sql);
  $sth->execute();

  if ($dbh_gis_write->err()) {

    $self->logger->debug("Changing geometry field in $dest_2d_table_name to NOT NULL failed");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};
    $err = 1;

    return ($err, $data_for_postrun_href);
  }

  $sth->finish();

  $sql  = "CREATE SEQUENCE ${dest_2d_table_name}_id_seq START WITH 1 ";
  $sql .= "INCREMENT BY 1 NO MAXVALUE NO MINVALUE CACHE 1 ";
  $sql .= "OWNED BY ${dest_2d_table_name}.id";

  $sth = $dbh_gis_write->prepare($sql);
  $sth->execute();

  if ($dbh_gis_write->err()) {

    $self->logger->debug("Can't create sequence ${dest_2d_table_name}_id_seq");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};
    $err = 1;

    return ($err, $data_for_postrun_href);
  }

  $sth->finish();

  $sql  = "ALTER TABLE $dest_2d_table_name ";
  $sql .= "ALTER COLUMN id SET DEFAULT nextval('${dest_2d_table_name}_id_seq') ";

  $sth = $dbh_gis_write->prepare($sql);
  $sth->execute();

  if ($dbh_gis_write->err()) {

    $self->logger->debug("Can't make ${dest_2d_table_name}.id an auto number.");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};
    $err = 1;

    return ($err, $data_for_postrun_href);
  }

  $sth->finish();

  $sql  = "ALTER TABLE $dest_2d_table_name ";
  $sql .= "ADD PRIMARY KEY (id)";

  $sth = $dbh_gis_write->prepare($sql);
  $sth->execute();

  if ($dbh_gis_write->err()) {

    $self->logger->debug("Can't make ${dest_2d_table_name}.id the primary key.");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};
    $err = 1;

    return ($err, $data_for_postrun_href);
  }

  $sth->finish();

  $self->logger->debug("Reading POSTGRES Username");

  my ($gis_db_uname, ) = read_uname_pass($RPOSTGRES_UP_FILE->{$ENV{DOCUMENT_ROOT}});

  $self->logger->debug("GIS DB USERNAME: $gis_db_uname");

  $sql = "GRANT ALL ON ${dest_2d_table_name}_id_seq TO $gis_db_uname";
  $sth = $dbh_gis_write->prepare($sql);
  $sth->execute();

  if ($dbh_gis_write->err()) {

    $self->logger->debug("GRANT ${dest_2d_table_name}_id_seq to $gis_db_uname failed");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};
    $err = 1;

    return ($err, $data_for_postrun_href);
  }

  $sth->finish();

  $sql = "GRANT ALL ON $dest_2d_table_name TO $gis_db_uname";
  $sth = $dbh_gis_write->prepare($sql);
  $sth->execute();

  if ($dbh_gis_write->err()) {

    $self->logger->debug("GRANT $dest_2d_table_name to $gis_db_uname failed");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};
    $err = 1;

    return ($err, $data_for_postrun_href);
  }

  $sth->finish();

  $sql  = "CREATE INDEX ${dest_2d_table_name}_sp_index ON $dest_2d_table_name ";
  $sql .= "USING GIST(geometry)";

  $sth = $dbh_gis_write->prepare($sql);
  $sth->execute();

  if ($dbh_gis_write->err()) {

    $self->logger->debug("Can't create a spatial index on $dest_2d_table_name");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};
    $err = 1;

    return ($err, $data_for_postrun_href);
  }

  $sth->finish();

  $sql  = "ALTER TABLE $dest_2d_table_name ";
  $sql .= "DROP COLUMN attributex";

  $sth = $dbh_gis_write->prepare($sql);
  $sth->execute();

  if ($dbh_gis_write->err()) {

    $self->logger->debug("Can't remove attributex from $dest_2d_table_name");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};
    $err = 1;

    return ($err, $data_for_postrun_href);
  }

  $sth->finish();

  $sql  = 'SELECT colname FROM layerattrib WHERE layer=?';

  my ($read_colname_err, $read_colname_msg, $colname_data) = read_data($dbh_gis_write, $sql, [$layer_id]);

  if ($read_colname_err) {

    $self->logger->debug("Read colname from layerattrib failed: $read_colname_msg");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};
    $err = 1;

    return ($err, $data_for_postrun_href);
  }

  if (scalar(@{$colname_data}) > 0) {

    my @colname_list;

    foreach my $colname_rec (@{$colname_data}) {

      push(@colname_list, $colname_rec->{'colname'});
    }

    ($err, $data_for_postrun_href) = $self->add_layer2d_column($dbh_gis_write, $layer_id, \@colname_list);
  }

  return ($err, $data_for_postrun_href);
}

sub add_layer2d_column {

  my $self                    = $_[0];
  my $dbh_gis_write           = $_[1];
  my $layer_id                = $_[2];
  my $colname_aref            = $_[3];

  my $sql = '';
  my $sth;
  my $data_for_postrun_href = {};
  my $err = 0;

  my $dest_2d_table_name = "layer2d${layer_id}";

  foreach my $colname (@{$colname_aref}) {

    if ($colname =~ /^\w+$/) {

      $sql  = "ALTER TABLE $dest_2d_table_name ";
      $sql .= "ADD COLUMN $colname CHARACTER VARYING(256) NOT NULL";

      $self->logger->debug("SQL: $sql");

      $sth = $dbh_gis_write->prepare($sql);
      $sth->execute();

      if ($dbh_gis_write->err()) {

        $self->logger->debug("Can't add a new field ($colname) in $dest_2d_table_name");

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};
        $err = 1;

        return ($err, $data_for_postrun_href);
      }

      $sth->finish();

      $sql = "CREATE INDEX layer${layer_id}_${colname}_index ON $dest_2d_table_name USING btree ($colname)";

      $sth = $dbh_gis_write->prepare($sql);
      $sth->execute();

      if ($dbh_gis_write->err()) {

        $self->logger->debug("Can't create an index for ($colname) in $dest_2d_table_name");

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};
        $err = 1;

        return ($err, $data_for_postrun_href);
      }

      $sth->finish();
    }
    else {

      $self->logger->debug("colname ($colname): invalid");

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};
      $err = 1;

      return ($err, $data_for_postrun_href);
    }
  }

  return ($err, $data_for_postrun_href);
}

sub update_layer_attribute_runmode {

=pod update_layer_attribute_HELP_START
{
"OperationName": "Update layer attribute",
"Description": "Update the definition of layer attribute",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "environment",
"KDDArTTable": "layerattrib",
"SkippedField": ["layer"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Layer attribute (18) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Layer attribute (18) has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Layer attribute (83) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Layer attribute (83) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing layer attribute id"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self            = shift;
  my $query           = $self->query();
  my $layer_attrib_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_write = connect_gis_write();

  # Generic required static field checking

  my $dbh_read = connect_gis_read();

  my $skip_field = {'layer'       => 1,
                   };

  my $field_name_translation = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'layerattrib', $skip_field,
                                                                                $field_name_translation,
                                                                               );

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $read_layer_attrib_sql   =   'SELECT layer, validation, coltype, colname ';
     $read_layer_attrib_sql  .=   'FROM layerattrib WHERE id=? ';

  my ($r_df_val_err, $r_df_val_msg, $layer_attrib_df_val_data) = read_data($dbh_write, $read_layer_attrib_sql, [$layer_attrib_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve layer attribute default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $layer_id       =   undef;
  my $validation     =   undef;
  my $db_coltype     =   undef;
  my $db_colname     =   undef;

  my $nb_df_val_rec    =  scalar(@{$layer_attrib_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve layer attribute default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $layer_id       =   $layer_attrib_df_val_data->[0]->{'layer'};;
  $validation     =   $layer_attrib_df_val_data->[0]->{'validation'};
  $db_coltype     =   $layer_attrib_df_val_data->[0]->{'coltype'};
  $db_colname     =   $layer_attrib_df_val_data->[0]->{'colname'};


  if (length($layer_id) == 0) {

    my $err_msg = "Layer attribute ($layer_attrib_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_write_ok, $trouble_layer_id_aref) = check_permission($dbh_write, 'layer', 'id', [$layer_id],
                                                               $group_id, $gadmin_status, $READ_WRITE_PERM);

  if (!$is_write_ok) {

    my $err_msg = "Layer ($layer_id) permission denied.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $unit_id         = $query->param('unitid');
  my $colname         = $query->param('colname');
  my $coltype         = $query->param('coltype');
  my $colsize         = $query->param('colsize');
  my $colunits        = $query->param('colunits');

  $colname = lc($colname);


  if (defined $query->param('validation')) {

    if (length($query->param('validation')) > 0) {

      $validation = $query->param('validation');
    }
  }

  my ($int_err, $int_href) = check_integer_href( { 'colsize' => $colsize } );

  if ($int_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$int_href]};

    return $data_for_postrun_href;
  }

  if ( !($colname =~ /^[a-zA-Z0-9_]+$/) ) {

    my $err_msg = "colname ($colname): invalid character.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'colname' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT id from layerattrib WHERE layer=? AND colname=? AND id<>?';

  my ($chk_colname_err, $layerattrib_id) = read_cell($dbh_write, $sql, [$layer_id, $colname, $layer_attrib_id]);

  if ($chk_colname_err) {

    $self->logger->debug("Check if colname exists failed");
    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($layerattrib_id) > 0) {

    my $err_msg = "colname ($colname) in layer ($layer_id): already exists.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'colname' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_k_read = connect_kdb_read();

  if (!record_existence($dbh_k_read, 'generalunit', 'UnitId', $unit_id)) {

    my $err_msg = "unitid ($unit_id): not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'unitid' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $layer_type = read_cell_value($dbh_write, 'layer', 'layertype', 'id', $layer_id);

  my $chk_data_sql = '';

  if (uc($layer_type) eq '2D') {

    $chk_data_sql = "SELECT COUNT(*) FROM layer2d$layer_id";
  }
  else {

    $chk_data_sql = "SELECT COUNT(*) FROM layer${layer_id}attrib";
  }

  my ($read_count_err, $nb_record) = read_cell($dbh_write, $chk_data_sql, []);

  if ($read_count_err) {

    $self->logger->debug("Check if colname exists failed");
    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (lc($coltype) ne lc($db_coltype)) {

    if ($nb_record > 0) {

      my $err_msg = "Layer ($layer_id) has data - coltype cannot be changed.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'coltype' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }


  if (lc($colname) ne lc($db_colname)) {

    if (record_existence($dbh_write, 'datadevice', 'layerattrib', $layer_attrib_id)) {

      my $err_msg = "Layer attribute ($layer_attrib_id) is mapped to a device.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'colname' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (length($validation) == 0) {

    $validation = undef;
  }

  $sql  = 'UPDATE layerattrib SET ';
  $sql .= 'unitid=?, ';
  $sql .= 'colname=?, ';
  $sql .= 'coltype=?, ';
  $sql .= 'colsize=?, ';
  $sql .= 'validation=?, ';
  $sql .= 'colunits=? ';
  $sql .= 'WHERE id=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($unit_id, $colname, $coltype, $colsize, $validation, $colunits, $layer_attrib_id);

  if ($dbh_write->err()) {

    $self->logger->debug("Update layerattrib record failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  if (uc($layer_type) eq '2D') {

    if (lc($db_colname) ne lc($colname)) {

      $sql  = "ALTER TABLE layer2d$layer_id ";
      $sql .= "DROP COLUMN $db_colname";

      $sth = $dbh_write->prepare($sql);
      $sth->execute();

      if ($dbh_write->err()) {

        $self->logger->debug("Drop column ($db_colname) failed");
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

        return $data_for_postrun_href;
      }

      $sth->finish();

      my ($err_status, $postrun_href) = $self->add_layer2d_column($dbh_write, $layer_id, [$colname]);

      if ($err_status) {

        return $postrun_href;
      }
    }
  }

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "Layer attribute ($layer_attrib_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub del_layer_runmode {

=pod del_layer_gadmin_HELP_START
{
"OperationName": "Delete layer",
"Description": "Delete layer definition and its data",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Layer (16) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Layer (18) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Layer (17) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Layer (17) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing LayerId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self        = shift;
  my $query       = $self->query();
  my $layer_id    = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_write = connect_gis_write();

  if (!record_existence($dbh_write, 'layer', 'id', $layer_id)) {

    my $err_msg = "Layer ($layer_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_write_ok, $trouble_layer_id_aref) = check_permission($dbh_write, 'layer', 'id', [$layer_id],
                                                               $group_id, $gadmin_status, $READ_WRITE_PERM);

  if (!$is_write_ok) {

    my $err_msg = "Layer ($layer_id) permission denied.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (record_existence($dbh_write, 'layer', 'parent', $layer_id)) {

    my $err_msg = "Layer ($layer_id) is a parent layer.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT deviceid FROM datadevice LEFT JOIN ';
  $sql   .= 'layerattrib ON datadevice.layerattrib=layerattrib.id ';
  $sql   .= 'WHERE layerattrib.layer=? LIMIT 1';

  my ($chk_datadevice_err, $deviceid) = read_cell($dbh_write, $sql, [$layer_id]);

  if ($chk_datadevice_err) {

    $self->logger->debug("Checking datadevice failed");
    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($deviceid) > 0) {

    my $err_msg = "Layer ($layer_id) has device mapped to it.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $layer_type = read_cell_value($dbh_write, 'layer', 'layertype', 'id', $layer_id);

  my @drop_table_list;

  if (uc($layer_type) eq 'LAYERTILES') {

    my ($err, $err_msg) = $self->delete_tileset($layer_id);
    if ($err) {
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};
      return $data_for_postrun_href;
    }
  }
  
  if (uc($layer_type) eq '2D') {

    push(@drop_table_list, "layer2d$layer_id");
  }
  else{

    push(@drop_table_list, "layer$layer_id");
    push(@drop_table_list, "layer${layer_id}attrib");
  }

  my $sth;

  foreach my $table_name (@drop_table_list) {

    $sql  = "DROP TABLE $table_name";

    $sth = $dbh_write->prepare($sql);
    $sth->execute();

    if ($dbh_write->err()) {

      $self->logger->debug("Drop table $table_name failed");

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    $sth->finish();
  }

  $sql = 'DELETE FROM layerattrib WHERE layer=?';

  $sth = $dbh_write->prepare($sql);
  $sth->execute($layer_id);

  if ($dbh_write->err()) {

    $self->logger->debug("Delete records in layerattrib failed");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $sql = 'DELETE FROM layer WHERE id=?';

  $sth = $dbh_write->prepare($sql);
  $sth->execute($layer_id);

  if ($dbh_write->err()) {

    $self->logger->debug("Delete records in layer failed");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "Layer ($layer_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub del_layer_attribute_runmode {

=pod del_layer_attribute_gadmin_HELP_START
{
"OperationName": "Delete layer attribute",
"Description": "Delete the definition of layer attribute and its data",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Layer attribute (20) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Layer attribute (21) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Layer attribute (23) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Layer attribute (23) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing layer attribute id"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self            = shift;
  my $query           = $self->query();
  my $layer_attrib_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_write = connect_gis_write();

  my $layer_id = read_cell_value($dbh_write, 'layerattrib', 'layer', 'id', $layer_attrib_id);

  if (length($layer_id) == 0) {

    my $err_msg = "Layer attribute ($layer_attrib_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_write_ok, $trouble_layer_id_aref) = check_permission($dbh_write, 'layer', 'id', [$layer_id],
                                                               $group_id, $gadmin_status, $READ_WRITE_PERM);

  if (!$is_write_ok) {

    my $err_msg = "Layer ($layer_id) permission denied.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (record_existence($dbh_write, 'datadevice', 'layerattrib', $layer_attrib_id)) {

    my $err_msg = "Layer attribute ($layer_attrib_id) is mapped to a device.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $layer_type = read_cell_value($dbh_write, 'layer', 'layertype', 'id', $layer_id);
  my $colname    = read_cell_value($dbh_write, 'layerattrib', 'colname', 'id', $layer_attrib_id);

  $colname = lc($colname);

  my $sql;
  my $sth;

  if (uc($layer_type) eq '2D') {

    $sql = "ALTER TABLE layer2d$layer_id DROP COLUMN $colname";

    $sth = $dbh_write->prepare($sql);
    $sth->execute();

    if ($dbh_write->err()) {

      $self->logger->debug("Drop column $colname in layer2d$layer_id failed");

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    $sth->finish();
  }
  else {

    $sql = "DELETE FROM layer${layer_id}attrib WHERE layerattrib=?";

    $sth = $dbh_write->prepare($sql);
    $sth->execute($layer_attrib_id);

    if ($dbh_write->err()) {

      $self->logger->debug("Delete records from layer${layer_id}attrib failed");

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    $sth->finish();
  }

  $sql = 'DELETE FROM layerattrib WHERE id=?';

  $sth = $dbh_write->prepare($sql);
  $sth->execute($layer_attrib_id);

  if ($dbh_write->err()) {

    $self->logger->debug("Delete layer attribute record failed");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "Layer attribute ($layer_attrib_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub insert_data_into_layer {

  my $self                    = $_[0];
  my $dbh_k_write             = $_[1];
  my $dbh_gis_write           = $_[2];
  my $hierarchical_env_data   = $_[3];

  my $err                        = 0;
  my $num_row_inserted           = 0;
  my $return_affected_layer_aref = [];
  my $data_for_postrun_href      = {};

  my $sql;
  my $sth_gis;
  my $sth_k;

  my %affected_layer;

  my $user_id = $self->authen->user_id();

  for my $dev_id (keys(%{$hierarchical_env_data})) {

    # Skip this because this key is refered to later
    if ($dev_id =~ /_DREG_DATA$/) { next; }

    my $dev_reg_lng = $hierarchical_env_data->{"${dev_id}_DREG_DATA"}->[0];
    my $dev_reg_lat = $hierarchical_env_data->{"${dev_id}_DREG_DATA"}->[1];

    my $store_dev_reg_position = 0;

    if ( ($dev_reg_lng == 0.0 && $dev_reg_lat == 0.0) ||
         (length($dev_reg_lng) == 0 && length($dev_reg_lat) == 0) ) {

      $store_dev_reg_position = 1;
    }

    my $this_dev_data = $hierarchical_env_data->{$dev_id};
    for my $para_name (keys(%{$this_dev_data})) {

      if ($para_name =~ /_LATTR_INFO$/) { next; }

      my $actual_env_data = $this_dev_data->{$para_name};
      my $at_info_href = $this_dev_data->{"${para_name}_LATTR_INFO"};

      for my $at_id (keys(%{$at_info_href})) {

        my $l_id      = $at_info_href->{$at_id}->[0];
        my $layertype = $at_info_href->{$at_id}->[2];

        if (uc($layertype) eq '2D') {

          my $err_msg = "Layer ($l_id) is 2D layer - cannot accept timestamp data.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          $err = 1;
          $num_row_inserted = -1;

          return ($err, $num_row_inserted, [], $data_for_postrun_href);
        }

        $affected_layer{$l_id} = 1;

        my $bulk_sql = '';
        $bulk_sql   .= "INSERT INTO layer${l_id}attrib ";
        $bulk_sql   .= "(layerid,layerattrib,value,dt,systemuserid,deviceid) ";
        $bulk_sql   .= "VALUES ";

        for my $env_data_point (@{$actual_env_data}) {

          my $lng      = $env_data_point->[0];
          my $lat      = $env_data_point->[1];
          my $para_val = $env_data_point->[2];
          my $para_dt  = $env_data_point->[3];

          my $geo_obj_str = "ST_GeomFromText('POINT($lng $lat)', -1)";
          my $within_str  = "ST_DWithin($geo_obj_str, geometry, $GIS_BUFFER_DISTANCE)";

          $sql = "SELECT id from layer${l_id} WHERE $within_str LIMIT 1";
          $sth_gis = $dbh_gis_write->prepare($sql);
          $sth_gis->execute();

          if ($dbh_gis_write->err()) {

            $data_for_postrun_href->{'Error'} = 1;
            $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

            $err = 1;
            $num_row_inserted = -1;

            return ($err, $num_row_inserted, [], $data_for_postrun_href);
          }

          my $layer_n_id = '';
          $sth_gis->bind_col(1, \$layer_n_id);
          $sth_gis->fetch();
          $sth_gis->finish();

          if (length($layer_n_id) == 0) {

            $sql = "INSERT INTO layer${l_id}(geometry) VALUES($geo_obj_str)";
            $sth_gis = $dbh_gis_write->prepare($sql);
            $sth_gis->execute();

            if ($dbh_gis_write->err()) {

              $data_for_postrun_href->{'Error'} = 1;
              $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

              $err = 1;
              $num_row_inserted = -1;

              return ($err, $num_row_inserted, [], $data_for_postrun_href);
            }

            $layer_n_id = $dbh_gis_write->last_insert_id(undef, undef, "layer${l_id}", 'id');
            $sth_gis->finish();
          }

          if ($store_dev_reg_position) {

            $sql  = 'UPDATE deviceregister SET ';
            $sql .= 'Longitude=?, ';
            $sql .= 'Latitude=? ';
            $sql .= 'WHERE DeviceId=?';

            $sth_k = $dbh_k_write->prepare($sql);
            $sth_k->execute($lng, $lat, $dev_id);

            if ($dbh_k_write->err()) {

              $data_for_postrun_href->{'Error'} = 1;
              $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

              $err = 1;
              $num_row_inserted = -1;

              return ($err, $num_row_inserted, [], $data_for_postrun_href);
            }

            $store_dev_reg_position = 0;
          }

          my $db_dev_id       = $dbh_gis_write->quote($dev_id);
          my $db_para_val     = $dbh_gis_write->quote($para_val);
          my $db_para_dt      = $dbh_gis_write->quote($para_dt);

          $bulk_sql .= "($layer_n_id,$at_id,$db_para_val,$db_para_dt,$user_id,$db_dev_id),";
          $num_row_inserted += 1;
        }

        chop($bulk_sql);   # remove excessive comma

        $sth_gis = $dbh_gis_write->prepare($bulk_sql);
        $sth_gis->execute();

        if ($dbh_gis_write->err()) {

          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

          $err = 1;
          $num_row_inserted = -1;

          return ($err, $num_row_inserted, [], $data_for_postrun_href);
        }

        $sth_gis->finish();
        $bulk_sql = '';
      }
    }
  }

  my @affected_layer_list = keys(%affected_layer);

  $return_affected_layer_aref = \@affected_layer_list;

  return ($err, $num_row_inserted, $return_affected_layer_aref, $data_for_postrun_href);
}

sub add_layer2d_data_runmode {

=pod add_layer2d_data_HELP_START
{
"OperationName": "Add data to 2D layer",
"Description": "Add data to a 2D layer table",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='1' ParaName='id' /><Info Message='Layer 2D record has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '1', 'ParaName' : 'id'}], 'Info' : [{'Message' : 'Layer 2D record has been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Layer (72) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Layer (72) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing layer 2D id."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self        = shift;
  my $query       = $self->query();
  my $layer_id    = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_write = connect_gis_write();

  my $layertype = read_cell_value($dbh_write, 'layer', 'layertype', 'id', $layer_id);

  if (length($layertype) == 0) {

    my $err_msg = "Layer ($layer_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (uc($layertype) ne '2D') {

    my $err_msg = "Layer ($layer_id) not 2D layer.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_write_ok, $trouble_layer_id_aref) = check_permission($dbh_write, 'layer', 'id', [$layer_id],
                                                               $group_id, $gadmin_status, $READ_WRITE_PERM);

  if (!$is_write_ok) {

    my $err_msg = "Layer ($layer_id) permission denied.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $geometry = $query->param('geometry');

  my ($col_missing_err, $col_missing_href) = check_missing_href( { 'geometry' => $geometry } );

  if ($col_missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$col_missing_href]};

    return $data_for_postrun_href;
  }

  my $geometry_type = read_cell_value($dbh_write, 'layer', 'geometrytype', 'id', $layer_id);

  my ($is_wkt_err, $wkt_err_href) = is_valid_wkt_href($dbh_write, {'geometry' => $geometry}, uc($geometry_type));

  if ($is_wkt_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$wkt_err_href]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT colname, colsize, validation FROM layerattrib WHERE layer=?';

  my ($r_col_def_err, $r_col_def_msg, $col_def_data) = read_data($dbh_write, $sql, [$layer_id]);

  if ($r_col_def_err) {

    $self->logger->debug("Read layer column definition failed: $r_col_def_msg");

    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $col_param_data        = {};
  my $col_len_info          = {};
  my $col_param_data_maxlen = {};
  my $col_validation_href   = {};

  for my $col_def (@{$col_def_data}) {

    my $col_param_name = $col_def->{'colname'};
    my $col_value      = $query->param($col_param_name);

    $col_param_data->{$col_param_name}        = $col_value;
    $col_len_info->{$col_param_name}          = $col_def->{'colsize'};
    $col_param_data_maxlen->{$col_param_name} = $col_value;
    $col_validation_href->{$col_param_name}   = $col_def->{'validation'};
  }

  ($col_missing_err, $col_missing_href) = check_missing_href( $col_param_data );

  if ($col_missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$col_missing_href]};

    return $data_for_postrun_href;
  }

  my ($col_maxlen_err, $col_maxlen_href) = check_maxlen_href($col_param_data_maxlen, $col_len_info);

  if ($col_maxlen_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$col_maxlen_href]};

    return $data_for_postrun_href;
  }

  my @col_name_list     = ('geometry');
  my @place_holder_list = ('ST_GeomFromText(?, -1)');
  my @col_val_list      = ($geometry);

  for my $colname (keys(%{$col_param_data})) {

    my $col_value  = $col_param_data->{$colname};

    if (defined $col_validation_href->{$colname}) {

      my $validation = $col_validation_href->{$colname};

      if ( $col_value !~ /$validation/ ) {

        my $err_msg = "colname ($col_value): invalid.";

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }

    push(@col_name_list, $colname);
    push(@col_val_list, $col_value);
    push(@place_holder_list, '?');
  }

  my $col_name_csv      = join(',', @col_name_list);
  my $place_holder_csv  = join(',', @place_holder_list);

  $sql  = "INSERT INTO layer2d$layer_id ";
  $sql .= "(${col_name_csv}) ";
  $sql .= "VALUES (${place_holder_csv})";

  my $sth = $dbh_write->prepare($sql);
  $sth->execute(@col_val_list);

  my $data_id = '';

  if (!$dbh_write->err()) {

    $data_id = $dbh_write->last_insert_id(undef, undef, "layer2d${layer_id}", 'id');
  }
  else {

    $self->logger->debug("Add layer 2d record failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();
  $dbh_write->disconnect();

  my $info_msg_aref  = [{'Message' => "Layer 2D record has been added successfully."}];
  my $return_id_aref = [{'Value' => "$data_id", 'ParaName' => 'id'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_layer2d_data_runmode {

=pod update_layer2d_data_HELP_START
{
"OperationName": "Update a record in 2D layer",
"Description": "Update a record in 2D layer table",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Layer 2D record (1) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Layer 2D record (1) has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Layer (72) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Layer (72) not found.'}]}"}],
"URLParameter": [{"ParameterName": "layerid", "Description": "Existing layer 2D id."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self        = shift;
  my $query       = $self->query();
  my $layer_id    = $self->param('layerid');
  my $rec_id      = $self->param('recid');

  my $data_for_postrun_href = {};

  my $dbh_write = connect_gis_write();

  my $read_layer2d_sql   =  'SELECT layertype, geometrytype ';
     $read_layer2d_sql  .=  'FROM layer WHERE id=? ';

  my ($r_df_val_err, $r_df_val_msg, $layer2d_df_val_data) = read_data($dbh_write, $read_layer2d_sql, [$layer_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve layer2d default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $layertype     =   undef;
  my $geometry_type =   undef;

  my $nb_df_val_rec    =  scalar(@{$layer2d_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve layer2d default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $layertype      =  $layer2d_df_val_data->[0]->{'layertype'}; 
  $geometry_type  =  $layer2d_df_val_data->[0]->{'geometrytype'};


  if (length($layertype) == 0) {

    my $err_msg = "Layer ($layer_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (uc($layertype) ne '2D') {

    my $err_msg = "Layer ($layer_id) not 2D layer.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_write_ok, $trouble_layer_id_aref) = check_permission($dbh_write, 'layer', 'id', [$layer_id],
                                                               $group_id, $gadmin_status, $READ_WRITE_PERM);

  if (!$is_write_ok) {

    my $err_msg = "Layer ($layer_id) permission denied.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (!record_existence($dbh_write, "layer2d${layer_id}", 'id', $rec_id)) {

    my $err_msg = "Record ($rec_id) not found in layer2d${layer_id}.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $geometry = $query->param('geometry');

  my ($col_missing_err, $col_missing_href) = check_missing_href( { 'geometry' => $geometry } );

  if ($col_missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$col_missing_href]};

    return $data_for_postrun_href;
  }


  my ($is_wkt_err, $wkt_err_href) = is_valid_wkt_href($dbh_write, {'geometry' => $geometry}, uc($geometry_type));

  if ($is_wkt_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$wkt_err_href]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT colname, colsize, validation FROM layerattrib WHERE layer=?';

  my ($r_col_def_err, $r_col_def_msg, $col_def_data) = read_data($dbh_write, $sql, [$layer_id]);

  if ($r_col_def_err) {

    $self->logger->debug("Read layer column definition failed: $r_col_def_msg");

    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $col_param_data        = {};
  my $col_len_info          = {};
  my $col_param_data_maxlen = {};
  my $col_validation_href   = {};

  for my $col_def (@{$col_def_data}) {

    my $col_param_name = $col_def->{'colname'};
    my $col_value      = $query->param($col_param_name);

    $col_param_data->{$col_param_name}        = $col_value;
    $col_len_info->{$col_param_name}          = $col_def->{'colsize'};
    $col_param_data_maxlen->{$col_param_name} = $col_value;
    $col_validation_href->{$col_param_name}   = $col_def->{'validation'};
  }

  ($col_missing_err, $col_missing_href) = check_missing_href( $col_param_data );

  if ($col_missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$col_missing_href]};

    return $data_for_postrun_href;
  }

  my ($col_maxlen_err, $col_maxlen_href) = check_maxlen_href($col_param_data_maxlen, $col_len_info);

  if ($col_maxlen_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$col_maxlen_href]};

    return $data_for_postrun_href;
  }

  my @place_holder_val_list = ($geometry);

  $sql  = "UPDATE layer2d${layer_id} SET ";
  $sql .= "geometry = ?, ";

  for my $colname (keys(%{$col_param_data})) {

    my $col_value  = $col_param_data->{$colname};

    if (defined $col_validation_href->{$colname}) {

      my $validation = $col_validation_href->{$colname};

      if ( $col_value !~ /$validation/ ) {

        my $err_msg = "colname ($col_value): invalid.";

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }

    $sql .= "$colname = ? ,";

    push(@place_holder_val_list, $col_value);
  }

  chop($sql);   # remove excess comma

  $sql .= 'WHERE id=?';
  push(@place_holder_val_list, $rec_id);

  my $sth = $dbh_write->prepare($sql);
  $sth->execute(@place_holder_val_list);

  my $data_id = '';

  if ($dbh_write->err()) {

    $self->logger->debug("Update layer 2d record failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();
  $dbh_write->disconnect();

  my $info_msg_aref  = [{'Message' => "Layer 2D record ($rec_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_layer2d_data_runmode {

=pod list_layer2d_data_advanced_HELP_START
{
"OperationName": "List records in 2D layer",
"Description": "Listing records from 2D layer table",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination NumOfRecords='1' NumOfPages='1' Page='1' NumPerPage='10' /><LayerAttrib layerattribid='42' colsize='20' colunits='degree c' coltype='Temperature' colname='temperature_7175803' validation='' unitid='22' /><LayerAttrib layerattribid='43' colsize='20' colunits='percentage' coltype='Humidity' colname='hum_8050934' validation='' unitid='22' /><RecordMeta TagName='Layer2D' /><Layer2D recordid='1' temperature_7175803='34' hum_8050934='70' geometry='POLYGON((148.99658 -35.48192,149.2067 -35.48192,149.2067 -35.19626,148.99658 -35.19626,148.99658 -35.48192))' /></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfRecords' : '1', 'NumOfPages' : 1, 'NumPerPage' : '10', 'Page' : '1'}], 'LayerAttrib' : [{'colunits' : 'degree c', 'colsize' : '20', 'layerattribid' : 42, 'coltype' : 'Temperature', 'validation' : null, 'colname' : 'temperature_7175803', 'unitid' : '22'},{'colunits' : 'percentage', 'colsize' : '20', 'layerattribid' : 43, 'coltype' : 'Humidity', 'validation' : null, 'colname' : 'hum_8050934', 'unitid' : '22'}], 'RecordMeta' : [{'TagName' : 'Layer2D'}], 'Layer2D' : [{'recordid' : 1, 'hum_8050934' : '70', 'temperature_7175803' : '34', 'geometry' : 'POLYGON((148.99658 -35.48192,149.2067 -35.48192,149.2067 -35.19626,148.99658 -35.19626,148.99658 -35.48192))'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Layer (44) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Layer (44) not found.'}]}"}],
"URLParameter": [{"ParameterName": "layerid", "Description": "Existing layer 2D id."}, {"ParameterName": "nperpage", "Description": "Number of records in a page for pagination"}, {"ParameterName": "num", "Description": "The page number of the pagination"}],
"HTTPParameter": [{"Required": 0, "Name": "Filtering", "Description": "Filtering parameter string consisting of filtering expressions which are separated by ampersand (&) which needs to be encoded if HTTP GET method is used. Each filtering expression is composed of a database field name, a filtering operator and the filtering value."}, {"Required": 0, "Name": "FieldList", "Description": "Comma separated value of wanted fields."}, {"Required": 0, "Name": "Sorting", "Description": "Comma separated value of SQL sorting phrases."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self        = shift;
  my $query       = $self->query();
  my $layer_id    = $self->param('layerid');

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

  my $dbh = connect_gis_read();

  my $layertype = read_cell_value($dbh, 'layer', 'layertype', 'id', $layer_id);

  if (length($layertype) == 0) {

    my $err_msg = "Layer ($layer_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (uc($layertype) ne '2D') {

    my $err_msg = "Layer ($layer_id) not 2D layer.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_read_ok, $trouble_layer_id_aref) = check_permission($dbh, 'layer', 'id', [$layer_id],
                                                               $group_id, $gadmin_status, $READ_PERM);

  if (!$is_read_ok) {

    my $err_msg = "Layer ($layer_id) permission denied.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT id as layerattribid, ';
  $sql   .= 'unitid, ';
  $sql   .= 'colname, ';
  $sql   .= 'coltype, ';
  $sql   .= 'colsize, ';
  $sql   .= 'validation, ';
  $sql   .= 'colunits ';
  $sql   .= 'FROM layerattrib WHERE layer=?';

  my ($r_col_def_err, $r_col_def_msg, $col_def_data) = read_data($dbh, $sql, [$layer_id]);

  if ($r_col_def_err) {

    $self->logger->debug("Read layer column definition failed: $r_col_def_msg");

    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my @field_list_all;

  for my $col_def (@{$col_def_data}) {

    push(@field_list_all, $col_def->{'colname'});
  }

  my $final_field_list     = \@field_list_all;

  if (length($field_list_csv) > 0) {

    my ($sel_field_err, $sel_field_msg, $sel_field_list) = parse_selected_field($field_list_csv,
                                                                                $final_field_list,
                                                                                'id as recordid');

    if ($sel_field_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;

    push(@{$final_field_list}, 'ST_AsText(geometry) AS geometry');
  }
  else {

    push(@{$final_field_list}, 'ST_AsText(geometry) AS geometry');
    push(@{$final_field_list}, 'id as recordid');
  }

  my $final_field_csv = join(',', @{$final_field_list});

  $sql = "SELECT $final_field_csv FROM layer2d$layer_id ";

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering('id',
                                                                              "layer2d$layer_id",
                                                                              $filtering_csv,
                                                                              $final_field_list,
                                                                              );

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

  $sql .= " $filtering_exp ";

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
       $nb_pages, $limit_clause, $rcount_time) = get_paged_filter($dbh,
                                                                  $nb_per_page,
                                                                  $page,
                                                                  "layer2d$layer_id",
                                                                  'id',
                                                                  $filtering_exp,
                                                                  $where_arg);


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

    $sql .= ' ORDER BY id DESC';
  }

  $sql .= " $paged_limit_clause ";

  $self->logger->debug("SQL: $sql");

  $self->logger->debug('Where arg: ' . join(',', @{$where_arg}));

  my ($read_layer2d_err, $read_layer2d_msg, $layer2d_data) = read_data($dbh, $sql, $where_arg);

  if ($read_layer2d_err) {

    $self->logger->debug("Read layer2d data for layer ($layer_id) failed: $read_layer2d_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  $data_for_postrun_href->{'Error'}     = 0;

  $data_for_postrun_href->{'Data'}      = {'Layer2D'     => $layer2d_data,
                                           'LayerAttrib' => $col_def_data,
                                           'Pagination'  => $pagination_aref,
                                           'RecordMeta'  => [{'TagName' => 'Layer2D'}],
  };

  return $data_for_postrun_href;
}

sub get_layer2d_data_runmode {

=pod get_layer2d_data_HELP_START
{
"OperationName": "Get a record in 2D layer",
"Description": "",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><LayerAttrib layerattribid='42' colsize='20' colunits='degree c' coltype='Temperature' colname='temperature_7175803' validation='' unitid='22' /><LayerAttrib layerattribid='43' colsize='20' colunits='percentage' coltype='Humidity' colname='hum_8050934' validation='' unitid='22' /><RecordMeta TagName='Layer2D' /><Layer2D recordid='1' temperature_7175803='34' hum_8050934='70' geometry='POLYGON((148.99658 -35.48192,149.2067 -35.48192,149.2067 -35.19626,148.99658 -35.19626,148.99658 -35.48192))' /></DATA>",
"SuccessMessageJSON": "{'LayerAttrib' : [{'colunits' : 'degree c', 'colsize' : '20', 'layerattribid' : 42, 'coltype' : 'Temperature', 'validation' : null, 'colname' : 'temperature_7175803', 'unitid' : '22'},{'colunits' : 'percentage', 'colsize' : '20', 'layerattribid' : 43, 'coltype' : 'Humidity', 'validation' : null, 'colname' : 'hum_8050934', 'unitid' : '22'}], 'RecordMeta' : [{'TagName' : 'Layer2D'}], 'Layer2D' : [{'recordid' : 1, 'hum_8050934' : '70', 'temperature_7175803' : '34', 'geometry' : 'POLYGON((148.99658 -35.48192,149.2067 -35.48192,149.2067 -35.19626,148.99658 -35.19626,148.99658 -35.48192))'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Layer (44) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Layer (44) not found.'}]}"}],
"URLParameter": [{"ParameterName": "layerid", "Description": "Existing layer 2D id."}, {"ParameterName": "recid", "Description": "Data record id."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self        = shift;
  my $query       = $self->query();
  my $layer_id    = $self->param('layerid');
  my $rec_id      = $self->param('recid');

  my $data_for_postrun_href = {};

  my $dbh = connect_gis_read();

  my $layertype = read_cell_value($dbh, 'layer', 'layertype', 'id', $layer_id);

  if (length($layertype) == 0) {

    my $err_msg = "Layer ($layer_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (uc($layertype) ne '2D') {

    my $err_msg = "Layer ($layer_id) not 2D layer.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_read_ok, $trouble_layer_id_aref) = check_permission($dbh, 'layer', 'id', [$layer_id],
                                                               $group_id, $gadmin_status, $READ_PERM);

  if (!$is_read_ok) {

    my $err_msg = "Layer ($layer_id) permission denied.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (!record_existence($dbh, "layer2d${layer_id}", 'id', $rec_id)) {

    my $err_msg = "Record ($rec_id) not found in layer2d${layer_id}.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT id as layerattribid, ';
  $sql   .= 'unitid, ';
  $sql   .= 'colname, ';
  $sql   .= 'coltype, ';
  $sql   .= 'colsize, ';
  $sql   .= 'validation, ';
  $sql   .= 'colunits ';
  $sql   .= 'FROM layerattrib WHERE layer=?';

  my ($r_col_def_err, $r_col_def_msg, $col_def_data) = read_data($dbh, $sql, [$layer_id]);

  if ($r_col_def_err) {

    $self->logger->debug("Read layer column definition failed: $r_col_def_msg");

    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my @field_list_all;

  for my $col_def (@{$col_def_data}) {

    push(@field_list_all, $col_def->{'colname'});
  }

  push(@field_list_all, 'ST_AsText(geometry) AS geometry');
  push(@field_list_all, 'id as recordid');

  my $field_list_csv = join(',', @field_list_all);

  $sql  = "SELECT $field_list_csv FROM layer2d$layer_id ";
  $sql .= "WHERE id=?";

  my ($read_layer2d_err, $read_layer2d_msg, $layer2d_data) = read_data($dbh, $sql, [$rec_id]);

  if ($read_layer2d_err) {

    $self->logger->debug("Read layer2d data for layer ($layer_id) failed: $read_layer2d_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  $data_for_postrun_href->{'Error'}     = 0;

  $data_for_postrun_href->{'Data'}      = {'Layer2D'     => $layer2d_data,
                                           'LayerAttrib' => $col_def_data,
                                           'RecordMeta'  => [{'TagName' => 'Layer2D'}],
  };

  return $data_for_postrun_href;
}

sub del_layer2d_data_runmode {

=pod del_layer2d_data_gadmin_HELP_START
{
"OperationName": "Delete a record in 2D layer",
"Description": "",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Record (1) in layer2d45 has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Record (1) in layer2d47 has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Record (1) not found in layer2d45.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Record (1) not found in layer2d45.'}]}"}],
"URLParameter": [{"ParameterName": "layerid", "Description": "Existing layer 2D id."}, {"ParameterName": "recid", "Description": "Data record id"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self        = shift;
  my $query       = $self->query();
  my $layer_id    = $self->param('layerid');
  my $rec_id      = $self->param('recid');

  my $data_for_postrun_href = {};

  my $dbh_write = connect_gis_write();

  my $layertype = read_cell_value($dbh_write, 'layer', 'layertype', 'id', $layer_id);

  if (length($layertype) == 0) {

    my $err_msg = "Layer ($layer_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (uc($layertype) ne '2D') {

    my $err_msg = "Layer ($layer_id) not 2D layer.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_write_ok, $trouble_layer_id_aref) = check_permission($dbh_write, 'layer', 'id', [$layer_id],
                                                               $group_id, $gadmin_status, $READ_WRITE_PERM);

  if (!$is_write_ok) {

    my $err_msg = "Layer ($layer_id) permission denied.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (!record_existence($dbh_write, "layer2d${layer_id}", 'id', $rec_id)) {

    my $err_msg = "Record ($rec_id) not found in layer2d${layer_id}.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = "DELETE FROM layer2d$layer_id WHERE id=?";
  my $sth = $dbh_write->prepare($sql);

  $sth->execute($rec_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "Record ($rec_id) in layer2d$layer_id has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_layer_data_advanced_runmode {

=pod list_layer_data_advanced_HELP_START
{
"OperationName": "List records in layer",
"Description": "",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination NumOfRecords='1414' NumOfPages='1414' Page='1' NumPerPage='1' /><Layer recordid='1414' layerattrib='44' value='24.21' dt='2010-11-23 23:00:00' systemuserid='0' layerattribname='temperature_0806866' geometry='POINT(149.094063 -35.30635)' /><RecordMeta TagName='Layer' /></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfRecords' : '1414', 'NumOfPages' : 1414, 'NumPerPage' : '1', 'Page' : '1'}], 'Layer' : [{'systemuserid' : '0', 'dt' : '2010-11-23 23:00:00', 'value' : '24.21', 'layerattrib' : '44', 'recordid' : 1414, 'layerattribname' : 'temperature_0806866', 'geometry' : 'POINT(149.094063 -35.30635)'}], 'RecordMeta' : [{'TagName' : 'Layer'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Layer (72) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Layer (72) not found.'}]}"}],
"URLParameter": [{"ParameterName": "layerid", "Description": "Existing layer id."}, {"ParameterName": "nperpage", "Description": "Number of records in a page for pagination"}, {"ParameterName": "num", "Description": "The page number of the pagination"}],
"HTTPParameter": [{"Required": 0, "Name": "Filtering", "Description": "Filtering parameter string consisting of filtering expressions which are separated by ampersand (&) which needs to be encoded if HTTP GET method is used. Each filtering expression is composed of a database field name, a filtering operator and the filtering value."}, {"Required": 0, "Name": "FieldList", "Description": "Comma separated value of wanted fields."}, {"Required": 0, "Name": "Sorting", "Description": "Comma separated value of SQL sorting phrases."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self        = shift;
  my $query       = $self->query();
  my $layer_id    = $self->param('id');

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

  my $dbh = connect_gis_read();

  my $layertype = read_cell_value($dbh, 'layer', 'layertype', 'id', $layer_id);

  if (length($layertype) == 0) {

    my $err_msg = "Layer ($layer_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (uc($layertype) eq '2D') {

    my $err_msg = "Layer ($layer_id):  2D layer.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_read_ok, $trouble_layer_id_aref) = check_permission($dbh, 'layer', 'id', [$layer_id],
                                                               $group_id, $gadmin_status, $READ_PERM);

  if (!$is_read_ok) {

    my $err_msg = "Layer ($layer_id) permission denied.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $final_field_list = [];

  push(@{$final_field_list}, "layer${layer_id}attrib.id as recordid");
  push(@{$final_field_list}, 'ST_AsText(geometry) AS geometry');
  push(@{$final_field_list}, 'layerattrib');
  push(@{$final_field_list}, 'layerattrib.colname AS layerattribname');
  push(@{$final_field_list}, 'value');
  push(@{$final_field_list}, 'dt');
  push(@{$final_field_list}, 'systemuserid');

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering("id",
                                                                              "layer${layer_id}attrib",
                                                                              $filtering_csv,
                                                                              $final_field_list,
                                                                              );

  $self->logger->debug("Filter phrase: $filter_phrase");
  $self->logger->debug("Where argument: " . join(',', @{$where_arg}));

  if ($filter_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $filter_msg}]};

    return $data_for_postrun_href;
  }

  my $filter_where_phrase = '';
  if (length($filter_phrase) > 0) {

    # We know that geometry is not in layer${layer_id}attrib table so
    $filter_phrase =~ s/layer${layer_id}attrib\.//g;

    $filter_where_phrase = " WHERE $filter_phrase ";
  }

  my $filtering_exp = $filter_where_phrase;

  my $final_field_csv = join(',', @{$final_field_list});

  my $sql = "SELECT $final_field_csv ";
  $sql   .= "FROM layer${layer_id}attrib ";
  $sql   .= "LEFT JOIN layer${layer_id} ON layer${layer_id}attrib.layerid = layer${layer_id}.id ";
  $sql   .= "LEFT JOIN layerattrib ON layer${layer_id}attrib.layerattrib = layerattrib.id ";

  $sql   .= " $filtering_exp ";

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

    # need count_sql because geometry is not in layer${layer_id}attrib

    my $count_sql = "SELECT COUNT(*) ";
    $count_sql   .= "FROM layer${layer_id}attrib ";
    $count_sql   .= "LEFT JOIN layer${layer_id} ON layer${layer_id}attrib.layerid = layer${layer_id}.id ";
    $count_sql   .= "LEFT JOIN layerattrib ON layer${layer_id}attrib.layerattrib = layerattrib.id ";
    $count_sql   .= "$filtering_exp";

    my ($pg_id_err, $pg_id_msg, $nb_records,
       $nb_pages, $limit_clause, $rcount_time) = get_paged_filter_sql($dbh,
                                                                      $nb_per_page,
                                                                      $page,
                                                                      $count_sql,
                                                                      $where_arg);


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

    $sql .= " ORDER BY layer${layer_id}attrib.id DESC";
  }

  $sql .= " $paged_limit_clause ";

  $self->logger->debug("SQL: $sql");

  $self->logger->debug('Where arg: ' . join(',', @{$where_arg}));

  my ($read_layer_err, $read_layer_msg, $layer_data) = read_data($dbh, $sql, $where_arg);

  if ($read_layer_err) {

    $self->logger->debug("Read layer data for layer ($layer_id) failed: $read_layer_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  $data_for_postrun_href->{'Error'}     = 0;

  $data_for_postrun_href->{'Data'}      = {'Layer'       => $layer_data,
                                           'Pagination'  => $pagination_aref,
                                           'RecordMeta'  => [{'TagName' => 'Layer'}],
  };

  return $data_for_postrun_href;
}

sub add_layer_data_runmode {

=pod add_layer_data_HELP_START
{
"OperationName": "Add data to layer",
"Description": "Add data into layer from a JSON string or blob",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Data of 2 records for attribute(s) (45,44) has been added into layer (43). ' /></DATA>",
"SuccessMessageJSON": "{ 'Info' : [{ 'Message' : 'Data of 2 records for attribute(s) (45,44) has been added into layer (43). '} ]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Layer (72) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Layer (72) not found.'}]}"}],
"HTTPParameter": [{"Required": 1, "Name": "data", "Description": "JSON string or blob in a structure as the following: {'DATA': [{'layerattrib' : '44', 'value' : '24.69', 'dt' : '2010-11-23 19:00:00', 'geometry' : 'POINT(149.094063 -35.30635)'},{'layerattrib' : '45', 'value' : '46.88', 'dt' : '2010-11-23 19:00:00', 'geometry' : 'POINT(149.094063 -35.30635)'}]}. The value of layerattrib attribute is an attribute id in the layer specified in the id URL parameter."}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing layer id."}],
"InputDataJSONSchema": "addlayerdata.schema.json",
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self        = shift;
  my $query       = $self->query();
  my $layer_id    = $self->param('id');

  my $err_if_exists = 0;

  if (defined $query->param('error_if_exists')) {

    if ($query->param('error_if_exists') eq '1') {

      $err_if_exists = $query->param('error_if_exists');
    }
  }

  my $data_for_postrun_href = {};

  my $dbh_write = connect_gis_write();

  my $layertype = read_cell_value($dbh_write, 'layer', 'layertype', 'id', $layer_id);

  if (length($layertype) == 0) {

    my $err_msg = "Layer ($layer_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (uc($layertype) eq '2D') {

    my $err_msg = "Layer ($layer_id): 2D layer.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_write_ok, $trouble_layer_id_aref) = check_permission($dbh_write, 'layer', 'id', [$layer_id],
                                                               $group_id, $gadmin_status, $READ_WRITE_PERM);

  if (!$is_write_ok) {

    my $err_msg = "Layer ($layer_id) permission denied.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $json_data_str = $query->param('data');

  my ($missing_err, $missing_href) = check_missing_href( {'data' => $json_data_str } );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  my $data_obj;

  eval {

    $data_obj = decode_json($json_data_str);
  };

  if ($@) {

    my $err_msg = "Invalid json string.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'data' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $json_schema_file = $self->get_add_layer_data_json_schema_file();

  my $json_schema = read_file($json_schema_file);

  my $schema_obj;

  eval {

    $schema_obj = decode_json($json_schema);
  };

  if ($@) {

    $self->logger->debug("Invalid JSON for the schema: $@");
    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'data' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $validator = JSON::Validator->new();

  $validator->schema($schema_obj);

  my @errors = $validator->validate($data_obj);

  if (scalar(@errors) > 0) {

    my $err_msg = join(' ', @errors);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT layerattrib.id as layerattribid, layer.id as layerid, validation ';
  $sql   .= 'FROM layerattrib LEFT JOIN layer ON layerattrib.layer = layer.id ';
  $sql   .= 'WHERE layer.id=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($layer_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $attrib_info_href = $sth->fetchall_hashref('layerattribid');

  $sth->finish();

  if (scalar(keys(%{$attrib_info_href})) == 0) {

    my $err_msg = "Layer ($layer_id) does not have any attribute defined.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $geometry_type = read_cell_value($dbh_write, 'layer', 'geometrytype', 'id', $layer_id);

  my $user_id = $self->authen->user_id();

  my $data_aref = $data_obj->{'DATA'};

  my @attrib_sql_row;
  my $uniq_attrib_id_href = {};

  my $uniq_deviceid_attr_href  = {};

  for my $row (@{$data_aref}) {

    my $attrib_id = $row->{'layerattrib'};

    $uniq_attrib_id_href->{$attrib_id} = 1;

    if ( !(defined $attrib_info_href->{$attrib_id}) ) {

      my $err_msg = "layerattrib ($attrib_id): not found.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $dt = $row->{'dt'};

    my ($dt_err, $dt_msg) = check_dt_value( {'dt' => $dt} );

    if ($dt_err) {

      my $err_msg = "dt ($dt): not correct format (yyyy-mm-dd hh:mm:ss).";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $geometry = $row->{'geometry'};

    my ($is_wkt_err, $wkt_err_href) = is_valid_wkt_href($dbh_write,
                                                        {'geometry' => $geometry},
                                                        $geometry_type
        );

    if ($is_wkt_err) {

      my $err_msg = "geometry ($geometry): is not a well known text of $geometry_type";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $db_dev_id = 'NULL';

    if (defined $row->{'deviceid'}) {

      my $dev_id = $row->{'deviceid'};
      $db_dev_id = $dbh_write->quote($dev_id);

      if (defined $uniq_deviceid_attr_href->{$dev_id}) {

        my $attr_href = $uniq_deviceid_attr_href->{$dev_id};
        $attr_href->{"$attrib_id"} = 1;
        $uniq_deviceid_attr_href->{$dev_id} = $attr_href;
      }
      else {

        $uniq_deviceid_attr_href->{$dev_id} = { "$attrib_id" => '1' };
      }
    }

    if (length($attrib_info_href->{$layer_id}->{'validation'}) > 0) {

      my $validation = $attrib_info_href->{$layer_id}->{'validation'};

      my $value = $row->{'value'};

      if ( $value !~ /$validation/ ) {

        my $err_msg = "value ($value): not matched with validation rule ($validation).";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }

    if ("$err_if_exists" eq '1') {

      $sql  = "SELECT COUNT(layer${layer_id}attrib.id) ";
      $sql .= "FROM layer${layer_id}attrib LEFT JOIN layer${layer_id} ON layer${layer_id}attrib.layerid = layer${layer_id}.id ";
      $sql .= "WHERE dt='$dt' AND layerattrib=? AND ";
      $sql .= "ST_DWithin(ST_GeomFromText('$geometry', -1), geometry, $GIS_BUFFER_DISTANCE)";

      my ($r_count_err, $count) = read_cell($dbh_write, $sql, [$attrib_id]);

      if ($r_count_err) {

        $self->logger->debug("SQL: $sql : $count");

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

        return $data_for_postrun_href;
      }

      if ($count > 0) {

        my $err_msg = "value for ( $attrib_id, Within('$geometry', '${GIS_BUFFER_DISTANCE}m') , '$dt' ): already exists.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }

    my $geometry_id = -1;

    $sql  = "SELECT id ";
    $sql .= "FROM layer${layer_id} WHERE geometry=ST_GeomFromText('$geometry', -1)";

    my ($r_geo_id_err, $r_geo_msg, $db_geo_data) = read_data($dbh_write, $sql, []);

    if ($r_geo_id_err) {

      $self->logger->debug("Read geometry id failed: $r_geo_msg");

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    if (scalar(@{$db_geo_data}) > 0) {

      $geometry_id = $db_geo_data->[0]->{'id'};
    }
    else {

      $sql = "INSERT INTO layer${layer_id}(geometry) VALUES(ST_GeomFromText('$geometry', -1))";
      $sth = $dbh_write->prepare($sql);
      $sth->execute();

      if ($dbh_write->err()) {

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

        return $data_for_postrun_href;
      }

      $geometry_id = $dbh_write->last_insert_id(undef, undef, "layer${layer_id}", 'id');
      $sth->finish();
    }

    my $value = $dbh_write->quote($row->{'value'});

    push(@attrib_sql_row, qq|($geometry_id,$attrib_id,$value,'$dt',$user_id,$db_dev_id)|);
  }

  my @uniq_dev_id_list;

  foreach my $dev_id (keys(%{$uniq_deviceid_attr_href})) {

    push(@uniq_dev_id_list, "'$dev_id'");
  }

  my $db_uniq_deviceid_attr_href = {};

  $self->logger->debug("Number of unique deviceid: " . scalar(@uniq_dev_id_list));

  if (scalar(@uniq_dev_id_list) > 0) {

    my $dev_id_csv = join(',', @uniq_dev_id_list);
    my $chk_dev_sql = "SELECT layerattrib, deviceid FROM datadevice ";
    $chk_dev_sql   .= "LEFT JOIN layerattrib ON datadevice.layerattrib = layerattrib.id ";
    $chk_dev_sql   .= "WHERE deviceid IN ($dev_id_csv) AND layer=?";

    $self->logger->debug("UNIQUE DEVICEID CSV: $dev_id_csv");

    my ($r_chk_dev_err, $r_chk_dev_msg, $device_attr_data) = read_data($dbh_write, $chk_dev_sql, [$layer_id]);

    if ($r_chk_dev_err) {

      $self->logger->debug("Read attribute mapping failed: $r_chk_dev_msg");

      my $err_msg = 'Unexpected Error.';
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    foreach my $dev_attr_rec (@{$device_attr_data}) {

      my $dev_id  = $dev_attr_rec->{'deviceid'};
      my $attr_id = $dev_attr_rec->{'layerattrib'};

      if (defined $db_uniq_deviceid_attr_href->{$dev_id}) {

        my $attr_href = $db_uniq_deviceid_attr_href->{$dev_id};
        $attr_href->{"$attr_id"} = '1';
        $db_uniq_deviceid_attr_href->{$dev_id} = $attr_href;
      }
      else {

        $db_uniq_deviceid_attr_href->{$dev_id} = { "$attr_id" => '1' };
      }
    }
  }

  foreach my $dev_id (keys(%{$uniq_deviceid_attr_href})) {

    if (! defined $db_uniq_deviceid_attr_href->{"$dev_id"}) {

      my $err_msg = "DeviceId ($dev_id): not found in layer attribute mapping.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $attr_href = $uniq_deviceid_attr_href->{"$dev_id"};

    my $db_attr_href = $db_uniq_deviceid_attr_href->{"$dev_id"};

    foreach my $attr (keys(%{$attr_href})) {

      if (! defined $db_attr_href->{"$attr"}) {

        my $err_msg = "DeviceId ($dev_id) and layer attribute ($attr): not found in layer attribute mapping for layer ($layer_id).";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
  }

  $sql  = "INSERT INTO layer${layer_id}attrib ";
  $sql .= "(layerid,layerattrib,value,dt,systemuserid,deviceid) ";
  $sql .= "VALUES " . join(',', @attrib_sql_row);

  $sth = $dbh_write->prepare($sql);
  $sth->execute();

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_write->disconnect();

  my $attr_id_csv = join(',', keys(%{$uniq_attrib_id_href}));
  my $nb_rec = scalar(@{$data_aref});

  my $msg = "Data of $nb_rec records for attribute(s) ($attr_id_csv) has been added into layer ($layer_id). ";

  my $info_msg_aref = [{'Message' => $msg}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_layer_data_runmode {

=pod update_layer_data_gadmin_HELP_START
{
"OperationName": "Update layer data",
"Description": "Update layer data from a JSON string or blob. The record must exist or DAL will return an error.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Data of 2 records with 2 unique record ID has been updated in layer (43).' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Data of 2 records with 2 unique record ID has been updated in layer (43).'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='recordid (1910): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'recordid (1910): not found.'}]}"}],
"HTTPParameter": [{"Required": 1, "Name": "data", "Description": "JSON string or blob in a structure as the following: {'DATA': [{'recordid' : 1409, 'layerattrib' : '45', 'value' : '34.48', 'dt' : '2010-11-23 22:00:00', 'geometry' : 'POINT(149.094063 -35.30235)'},{'recordid' : 1910, 'layerattrib' : '44', 'value' : '40.98', 'dt' : '2010-11-23 22:00:00', 'geometry' : 'POINT(149.094063 -35.30335)'}]}."}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing layer id."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self        = shift;
  my $query       = $self->query();
  my $layer_id    = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_write = connect_gis_write();

  my $read_layer2d_sql   =  'SELECT layertype, geometrytype ';
     $read_layer2d_sql  .=  'FROM layer WHERE id=? ';

  my ($r_df_val_err, $r_df_val_msg, $layer2d_df_val_data) = read_data($dbh_write, $read_layer2d_sql, [$layer_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve layer2d default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $layertype     =   undef;
  my $geometry_type =   undef;

  my $nb_df_val_rec    =  scalar(@{$layer2d_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve layer2d default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $layertype      =  $layer2d_df_val_data->[0]->{'layertype'};
  $geometry_type  =  $layer2d_df_val_data->[0]->{'geometrytype'};


  if (length($layertype) == 0) {

    my $err_msg = "Layer ($layer_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (uc($layertype) eq '2D') {

    my $err_msg = "Layer ($layer_id): 2D layer.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_write_ok, $trouble_layer_id_aref) = check_permission($dbh_write, 'layer', 'id', [$layer_id],
                                                               $group_id, $gadmin_status, $READ_WRITE_PERM);

  if (!$is_write_ok) {

    my $err_msg = "Layer ($layer_id) permission denied.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $json_data_str = $query->param('data');

  my ($missing_err, $missing_href) = check_missing_href( {'data' => $json_data_str } );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  my $data_obj;

  eval {

    $data_obj = decode_json($json_data_str);
  };

  if ($@) {

    my $err_msg = "Invalid json string.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'data' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $json_schema_file = $self->get_update_layer_data_json_schema_file();

  my $json_schema = read_file($json_schema_file);

  my $schema_obj;

  eval {

    $schema_obj = decode_json($json_schema);
  };

  if ($@) {

    $self->logger->debug("Invalid JSON for the schema: $@");
    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'data' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $validator = JSON::Validator->new();

  $validator->schema($schema_obj);

  my @errors = $validator->validate($data_obj);

  if (scalar(@errors) > 0) {

    my $err_msg = join(' ', @errors);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT layerattrib.id as layerattribid, layer.id as layerid, validation ';
  $sql   .= 'FROM layerattrib LEFT JOIN layer ON layerattrib.layer = layer.id ';
  $sql   .= 'WHERE layer.id=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($layer_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $attrib_info_href = $sth->fetchall_hashref('layerattribid');

  $sth->finish();

  if (scalar(keys(%{$attrib_info_href})) == 0) {

    my $err_msg = "Layer ($layer_id) does not have any attribute defined.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $data_aref = $data_obj->{'DATA'};

  my $uniq_id_href = {};

  my $dbh_k_read = connect_kdb_read();

  my $uniq_deviceid_attr_href = {};

  my $user_id = $self->authen->user_id();

  for my $row (@{$data_aref}) {

    my $rec_id = $row->{'recordid'};

    if (!record_existence($dbh_write, "layer${layer_id}attrib", "id", $rec_id)) {

      my $err_msg = "recordid ($rec_id): not found.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    $uniq_id_href->{$rec_id} = 1;

    my $attrib_id = $row->{'layerattrib'};

    if ( !(defined $attrib_info_href->{$attrib_id}) ) {

      my $err_msg = "layerattrib ($attrib_id): not found.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $dt = $row->{'dt'};

    my ($dt_err, $dt_msg) = check_dt_value( {'dt' => $dt} );

    if ($dt_err) {

      my $err_msg = "dt ($dt): not correct format (yyyy-mm-dd hh:mm:ss).";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $geometry = $row->{'geometry'};

    my ($is_wkt_err, $wkt_err_href) = is_valid_wkt_href($dbh_write,
                                                        {'geometry' => $geometry},
                                                        $geometry_type
                                                       );

    if ($is_wkt_err) {

      my $err_msg = "geometry ($geometry): is not a well known text of $geometry_type";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if (length($attrib_info_href->{$layer_id}->{'validation'}) > 0) {

      my $validation = $attrib_info_href->{$layer_id}->{'validation'};

      my $value = $row->{'value'};

      if ( $value !~ /$validation/ ) {

        my $err_msg = "value ($value): not matched with validation rule ($validation).";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }

    my $db_dev_id = undef;

    if (defined $row->{'deviceid'}) {

      my $dev_id = $row->{'deviceid'};
      $db_dev_id = $dev_id;

      if (! (defined $uniq_deviceid_attr_href->{"${dev_id}___attrib${attrib_id}"}) ) {

        my $chk_dev_sql = "SELECT layerattrib FROM datadevice ";
        $chk_dev_sql   .= "LEFT JOIN layerattrib ON datadevice.layerattrib = layerattrib.id ";
        $chk_dev_sql   .= "WHERE deviceid=? AND layerattrib=? AND layer=?";

        my ($chk_err, $db_attrib_id) = read_cell($dbh_write, $chk_dev_sql, [$dev_id, $attrib_id, $layer_id]);

        if ($chk_err) {

          $self->logger->debug("Read attribute mapping failed");

          my $err_msg = 'Unexpected Error.';
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }

        if (length($db_attrib_id) == 0) {

          my $err_msg = "DeviceId ($dev_id) and layer attribute ($attrib_id): not found in layer attribute mapping for layer ($layer_id).";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }

        $uniq_deviceid_attr_href->{"${dev_id}___attrib${attrib_id}"} = 1;
      }
    }

    my $geometry_id = -1;

    $sql  = "SELECT id ";
    $sql .= "FROM layer${layer_id} WHERE geometry=ST_GeomFromText('$geometry', -1)";

    my ($r_geo_id_err, $r_geo_msg, $db_geo_data) = read_data($dbh_write, $sql, []);

    if ($r_geo_id_err) {

      $self->logger->debug("Read geometry id failed: $r_geo_msg");

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    if (scalar(@{$db_geo_data}) > 0) {

      $geometry_id = $db_geo_data->[0]->{'id'};
    }
    else {

      $sql = "INSERT INTO layer${layer_id}(geometry) VALUES(ST_GeomFromText('$geometry', -1))";
      $sth = $dbh_write->prepare($sql);
      $sth->execute();

      if ($dbh_write->err()) {

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

        return $data_for_postrun_href;
      }

      $geometry_id = $dbh_write->last_insert_id(undef, undef, "layer${layer_id}", 'id');
      $sth->finish();
    }

    my $value = $row->{'value'};

    $sql  = "UPDATE layer${layer_id}attrib SET ";
    $sql .= "layerid=?, ";
    $sql .= "layerattrib=?, ";
    $sql .= "value=?, ";
    $sql .= "dt=?, ";
    $sql .= "systemuserid=?, ";
    $sql .= "deviceid=? ";
    $sql .= "WHERE id=?";

    $sth = $dbh_write->prepare($sql);
    $sth->execute($geometry_id, $attrib_id, $value, $dt, $user_id, $db_dev_id, $rec_id);

    if ($dbh_write->err()) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    $sth->finish();
  }

  $dbh_k_read->disconnect();

  $dbh_write->disconnect();

  my $nb_uniq_id = scalar(keys(%{$uniq_id_href}));
  my $nb_rec     = scalar(@{$data_aref});

  my $msg = "Data of $nb_rec records with $nb_uniq_id unique record ID has been updated in layer ($layer_id).";

  my $info_msg_aref = [{'Message' => $msg}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub del_layer_data_runmode {

=pod del_layer_data_gadmin_HELP_START
{
"OperationName": "Delete layer data",
"Description": "Delete data from layer for a particular attribute, for an exact geometry position and from a starting datetime to an ending datetime.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='16 records for layerattrib (45) from 2010-11-01 01:00:00 to 2010-11-09 17:00:00 in layer (43) have been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : '16 records for layerattrib (44) from 2010-11-01 01:00:00 to 2010-11-09 17:00:00 in layer (43) have been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Layer (72) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Layer (72) not found.'}]}"}],
"HTTPParameter": [{"Required": 1, "Name": "geometry", "Description": "GIS Well Known text for the exact position of the data to be deleted from layer specified in the URL parameter"}, {"Required": 1, "Name": "layerattrib", "Description": "Layer attribute id of the data to be deleted from the layer specified in the URL parameter"}, {"Required": 1, "Name": "startdt", "Description": "Starting datetime in yyyy-mm-dd hh:mm:ss format of the data to be deleted from the layer specified in the URL parameter."}, {"Required": 1, "Name": "enddt", "Description": "Ending datetime in yyyy-mm-dd hh:mm:ss format of the data to be deleted from the layer specified in the URL parameter."}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing layer id."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self        = shift;
  my $query       = $self->query();
  my $layer_id    = $self->param('id');

  my $geometry    = $query->param('geometry');
  my $attrib_id   = $query->param('layerattrib');
  my $start_time  = $query->param('startdt');
  my $end_time    = $query->param('enddt');

  my $data_for_postrun_href = {};

  my $dbh_write = connect_gis_write();

  my $layertype = read_cell_value($dbh_write, 'layer', 'layertype', 'id', $layer_id);

  if (length($layertype) == 0) {

    my $err_msg = "Layer ($layer_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (uc($layertype) eq '2D') {

    my $err_msg = "Layer ($layer_id): 2D layer.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_write_ok, $trouble_layer_id_aref) = check_permission($dbh_write, 'layer', 'id', [$layer_id],
                                                               $group_id, $gadmin_status, $READ_WRITE_PERM);

  if (!$is_write_ok) {

    my $err_msg = "Layer ($layer_id) permission denied.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($missing_err, $missing_href) = check_missing_href( {'layerattrib' => $attrib_id,
                                                          'startdt'     => $start_time,
                                                          'enddt'       => $end_time,
                                                          'geometry'    => $geometry,
                                                         } );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  my ($dt_err, $dt_href) = check_dt_value( {'startdt' => $start_time,
                                            'enddt'   => $end_time
                                           } );

  if ($dt_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$dt_href]};

    return $data_for_postrun_href;
  }

  my $geometry_type = read_cell_value($dbh_write, 'layer', 'geometrytype', 'id', $layer_id);

  my ($is_wkt_err, $wkt_err_href) = is_valid_wkt_href($dbh_write,
                                                      {'geometry' => $geometry},
                                                      $geometry_type
                                                     );

  if ($is_wkt_err) {

    my $err_msg = "geometry ($geometry): is not a well known text of $geometry_type";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (!record_existence($dbh_write, "layer${layer_id}attrib", "layerattrib", $attrib_id)) {

    my $err_msg = "layerattrib ($attrib_id): no data.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'layerattrib' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $geometry_id = -1;

  my $sql  = qq|SELECT id |;
  $sql    .= qq|FROM layer${layer_id} |;
  $sql    .= qq|WHERE geometry=ST_GeomFromText('$geometry', -1)|;

  my ($r_geo_id_err, $r_geo_msg, $db_geo_data) = read_data($dbh_write, $sql, []);

  if ($r_geo_id_err) {

    $self->logger->debug("Read geometry id failed: $r_geo_msg");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$db_geo_data}) == 1) {

    $geometry_id = $db_geo_data->[0]->{'id'};
  }
  elsif (scalar(@{$db_geo_data}) == 0) {

    my $err_msg = "geometry ($geometry): not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'geometry' => $err_msg}]};

    return $data_for_postrun_href;
  }
  else {

    my $err_msg = "geometry ($geometry): more than one object found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'geometry' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql    = qq|SELECT COUNT(id) |;
  $sql   .= qq|FROM layer${layer_id}attrib |;
  $sql   .= qq|WHERE layerattrib=? AND layerid=? AND dt>='$start_time' AND dt<='$end_time'|;

  my ($r_count_err, $nb_rec) = read_cell($dbh_write, $sql, [$attrib_id, $geometry_id]);

  if ($r_count_err) {

    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ($nb_rec == 0) {

    my $err_msg = "Data for layerattrib($attrib_id) from $start_time to $end_time: not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql  = qq|DELETE FROM layer${layer_id}attrib |;
  $sql .= qq|WHERE layerattrib=? AND layerid=? AND dt>='$start_time' AND dt<='$end_time'|;

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($attrib_id, $geometry_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_write->disconnect();

  my $msg = "$nb_rec records for layerattrib ($attrib_id) from $start_time to $end_time in layer ($layer_id) ";
  $msg   .= "have been deleted successfully.";

  my $info_msg_aref = [{'Message' => $msg}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub xml_parse_failed {

  my $self = shift;
  my $code = shift;

  if ($code < 300) {

    my $err_str = XML::Checker::error_string($code, @_);
    $err_str =~ s/XML::Checker ERROR\-//g;
    die $err_str;
  }
}

sub get_add_layer_data_json_schema_file {

  my $json_schema_path = $ENV{DOCUMENT_ROOT} . '/' . $JSON_SCHEMA_PATH;

  return "${json_schema_path}/addlayerdata.schema.json";
}

sub get_update_layer_data_json_schema_file {

  my $json_schema_path = $ENV{DOCUMENT_ROOT} . '/' . $JSON_SCHEMA_PATH;

  return "${json_schema_path}/updatelayerdata.schema.json";
}

sub get_layer_attribute_dtd {

  my $self = shift;

  my $dtd = '';

  my $dtd_file = $self->get_layer_attribute_dtd_file();

  open(DTD_FH, "<$dtd_file");
  while( my $line = <DTD_FH> ) {

    $dtd .= $line;
  }
  close(DTD_FH);

  return $dtd;
}

sub get_layer_attribute_dtd_file {

  my $dtd_path = $ENV{DOCUMENT_ROOT} . '/' . $DTD_PATH;

  return "${dtd_path}/layerattrib.dtd";
}

sub logger {

  my $self = shift;
  return $self->{logger};
}

sub add_tileset_runmode {

=pod add_tileset_HELP_START
{
"OperationName": "Add tileset",
"Description": "Add a set of tiles to an existing tileset.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "environment",
"KDDArTTable": "tileset",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Tileset (123) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Tileset (123) has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Tileset (123) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Tileset (123) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TilesetId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self        = $_[0];
  my $tileset_id  = $self->param('id');
  my $query       = $self->query();
  my $minzoom     = $query->param('minzoom');
  my $maxzoom     = $query->param('maxzoom');
  my $resolution  = $query->param('resolution');
  my $imagetype   = $query->param('imagetype');
  my $tilesjson   = $query->param('tilesjson');

  my $uploadfile  = $self->authen->get_upload_file();

  my $geometry    = $query->param("geometry") // "";
  my $description = $query->param('description') // "";
  my $spectrum    = $query->param('spectrum') // "";
  my $metadata    = $query->param("metadata") // "";
  my $source      = $query->param('source') // ""; 
  my $override    = $query->param('override') // 0;

  my ($missing_err, $missing_href) = check_missing_href({ 
                                                          'minzoom'     => $minzoom,
                                                          'maxzoom'     => $maxzoom,
                                                          'resolution'  => $resolution,
                                                          'imagetype'   => $imagetype,
                                                          'tilesjson'   => $tilesjson,
                                                         });
  if ($missing_err) {
    return _set_error([$missing_href]);
  }

  my ($int_err, $int_msg_href) = check_integer_href({ 'minzoom' => $minzoom, 'maxzoom' => $maxzoom, 'resolution' => $resolution });
  if ($int_err) {
    return _set_error([$int_msg_href]);
  }

  my $temp_tiles_dir = tempdir(CLEANUP=>1); # Create a temporary directory to store all the unzipped files
  {
    my ($temp_zip_fh, $temp_zip_fn) = tempfile(SUFFIX=>".tar.gz");
    my $encoded_content = do {
      local $/ = undef;
      open my $fh, "<", $uploadfile or die $!;
      <$fh>;
    };
    print $temp_zip_fh decode_base64($encoded_content);
    #
    my $cmd = sprintf("tar xf %s -C %s", $temp_zip_fn, $temp_tiles_dir);
    my $err = system($cmd);
    return _set_error("Unexpected error.") if ($err);
  }

  my $tiles_href;
  eval {
    eval {$tiles_href = decode_json($tilesjson); 1;} or do { die "tiles json is not a valid JSON string.\n"; };
    my @zooms = keys(%$tiles_href);
    my @sorted = sort { $a <=> $b } @zooms;
    if ($minzoom != $sorted[0] || $maxzoom != $sorted[scalar(@sorted)-1]) {
      die "json zoom levels not match.\n";
    }
    1;
  } or do {
    return _set_error($@);
  };

  if (!is_tiles_directory_match(read_layer_zooms_coordinates($temp_tiles_dir), $tiles_href)) {
    return _set_error("tiles json and upload file not match.");
  }

  if (length($metadata)) {
    my ($err, $errmsg) = validate_metadata($metadata);
    if ($err) {
      return _set_error($errmsg);
    }
  }

  eval {
    decode_json($source) if (length($source));
    1;
  } or do {
    return _set_error("Source is not a valid JSON string.");
  };

  my $data_for_postrun_href;

  my $dbh_write = connect_gis_write(1);
  eval {
    my $tileset;
    {
      my $sql = 'SELECT * FROM tileset WHERE id=?';
      my $sth = $dbh_write->prepare($sql);
      my $rv = $sth->execute($tileset_id);
      $tileset = $sth->fetchrow_hashref;
      if (!$tileset) {
        $data_for_postrun_href = _set_error("Tileset ($tileset_id) not found.");
        return 1;
      }
    }

    my $status = $tileset->{tilestatus};
    if (lc($status) eq "completed") {
      if (!$override) {
        $data_for_postrun_href = _set_error("Tileset ($tileset_id) is already completed.");
        return 1;
      }
      my $sql = "DELETE FROM tiles WHERE tileset=?";
      my $sth = $dbh_write->prepare($sql);
      my $rv = $sth->execute($tileset_id);
    }

    if (length($geometry)) {
      eval {
        is_valid_wkt_href($dbh_write, {'geometry' => $geometry});
      } or do {
        $data_for_postrun_href = _set_error("geometry is not valid.");
        return 1;
      }
    } else {
      $geometry = "POLYGON EMPTY";
    }

    my $tiles_public_path = "";
    {
      my $tilespath = catfile($TILES_PATH, $tileset_id);
      rmtree($tilespath) if (-e $tilespath);
      mkdir $tilespath;
      dircopy($temp_tiles_dir, $tilespath);
      $tiles_public_path = catfile($TILES_PUBLIC_PATH, $tileset_id);
    }

    {
      my $values = "";
      foreach my $zoom (keys(%$tiles_href)) {
        my $x_2y_href = $tiles_href->{$zoom};
        foreach my $x_coord (keys(%$x_2y_href)) {
          my $y_coords = $x_2y_href->{$x_coord};
          foreach my $y_coord (keys(%$y_coords)) {
            my $tile_coords_aref = $tiles_href->{$zoom}->{$x_coord}->{$y_coord};
            my $location = tomultipolygon($tile_coords_aref);
            $values .= qq|($tileset_id, $location, $x_coord, $y_coord, $zoom),|;
          }
        }
      }
      chop($values);
      my $sql = "";
      $sql .= "INSERT INTO tiles (tileset, geometry, xcoord, ycoord, zoomlevel) VALUES $values";
      my $sth = $dbh_write->prepare($sql);
      my $rv = $sth->execute();
    }

    my $sql = "";
    $sql   .= 'UPDATE tileset SET ';
    $sql   .= 'geometry = ?, ';
    $sql   .= 'resolution = ?, ';
    $sql   .= 'minzoom = ?, ';
    $sql   .= 'maxzoom = ?, ';
    $sql   .= 'tilepath = ?, ';
    $sql   .= 'spectrum = ?, ';
    $sql   .= 'tilestatus = ?, ';
    $sql   .= 'imagetype = ?, ';
    $sql   .= 'description = ?, ';
    $sql   .= 'metadata = ?, ';
    $sql   .= 'source = ? ';
    $sql   .= 'WHERE id=?';
    my $sth = $dbh_write->prepare($sql);
    my $rv = $sth->execute($geometry, $resolution, $minzoom, $maxzoom, $tiles_public_path, $spectrum, "completed", $imagetype, $description, $metadata, $source, $tileset_id);

    $dbh_write->commit;

    $data_for_postrun_href = {};
    my $info_msg_aref = [{'Message' => "Tileset ($tileset_id) has been updated successfully."}];
    $data_for_postrun_href->{'Error'}     = 0;
    $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
    $data_for_postrun_href->{'ExtraData'} = 0;

    1;
  } or do {
    $self->logger->debug($@);
    eval {$dbh_write->rollback};
    $data_for_postrun_href = _set_error("Unexpected error.");
  };

  $dbh_write->disconnect;
  return $data_for_postrun_href;
}

sub get_tileset_runmode {
  
=pod get_tileset_HELP_START
{
"OperationName": "Get tileset",
"Description": "Return detailed information about a tileset in the system specified by tileset id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Tileset id='123' geometry='POLYGON((30.2994731209255 -30.0858403095939,30.2843632260048 -30.1137608252837,30.3090885086023 -30.1137608252837,30.317330269468 -30.0923756052706,30.2994731209255 -30.0858403095939))' resolution='0' minzoom='0' maxzoom='0' tilepath='gis/tiles/123' spectrum='True Color' tilestatus='completed' imagetype='png' description='' metadata='' source='{'name':'Sentinel-2'}'/><RecordMeta TagName='Tileset' /></DATA>",
"SuccessMessageJSON": "{'Tileset' : [{'id': 123, 'geometry': 'POLYGON((30.2994731209255 -30.0858403095939,30.2843632260048 -30.1137608252837,30.3090885086023 -30.1137608252837,30.317330269468 -30.0923756052706,30.2994731209255 -30.0858403095939))', 'resolution': 0, 'minzoom': 0, 'maxzoom': 0, 'tilepath': 'gis/tiles/123', 'spectrum': 'True Color', 'tilestatus': 'completed', 'imagetype': 'png', 'description': '', 'metadata': '', 'source': {'name':'Sentinel-2'}}], 'RecordMeta' : [{'TagName' : 'Tileset'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Tileset (15) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Tileset (15) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing tileset id"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self        = shift;
  my $tileset_id  = $self->param('id');

  my $data_for_postrun_href;

  my $dbh_read = connect_gis_read();
  $dbh_read->{RaiseError} = 1;
  eval {

    my $sql = '';
    $sql .= 'SELECT id AS id, ST_AsText(geometry) AS geometry, resolution AS resolution, ';
    $sql .= 'minzoom AS minzoom, maxzoom AS maxzoom, tilepath AS tilepath, spectrum AS spectrum, ';
    $sql .= 'tilestatus AS tilestatus, imagetype AS imagetype, description AS description, ';
    $sql .= 'metadata AS metadata, source AS source FROM tileset WHERE id=?';

    my $sth = $dbh_read->prepare($sql);
    my $rv = $sth->execute($tileset_id);
    my $tileset = $sth->fetchrow_hashref;

    if (!defined($tileset)) {
      $data_for_postrun_href = _set_error("Tileset ($tileset_id) not found.");
      return 1;
    }

    $data_for_postrun_href            = {};
    $data_for_postrun_href->{'Error'} = 0;
    $data_for_postrun_href->{'Data'}  = {'Tileset'   => [$tileset],
                                        'RecordMeta'=> [{'TagName' => 'Tileset'}],};

    1;
  } or do {
    $self->logger->debug($@);
    $data_for_postrun_href = _set_error("Unexpected error.");
  };

  $dbh_read->disconnect;
  return $data_for_postrun_href;
}

sub update_tileset_runmode {

=pod update_tileset_HELP_START
{
"OperationName": "Update tileset",
"Description": "Update GIS tileset definition",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "environment",
"KDDArTTable": "tileset",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Tileset (123) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Tileset (123) has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Tileset (123) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Tileset (123) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TilesetId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self        = shift;
  my $tileset_id  = $self->param('id');
  my $query       = $self->query();

  my $data_for_postrun_href;

  my $dbh_write = connect_gis_write(1);
  eval {
    my $tileset;
    {
      my $sql = 'SELECT * FROM tileset WHERE id=?';
      my $sth = $dbh_write->prepare($sql);
      my $rv = $sth->execute($tileset_id);
      $tileset = $sth->fetchrow_hashref;
      if (!$tileset) {
        $data_for_postrun_href = _set_error("Tileset ($tileset_id) not found.");
        return 1;
      }
    }

    my $minzoom = $query->param('minzoom') // '';
    if (!length($minzoom)) {
      $minzoom = $tileset->{minzoom};
    } else {
      my ($int_err, $int_msg_href) = check_integer_href({ 'minzoom' => $minzoom });
      if ($int_err) { 
        $data_for_postrun_href = _set_error([$int_msg_href]);
        return 1;
      }
    }

    my $maxzoom = $query->param('maxzoom') // '';
    if (!length($maxzoom)) {
      $maxzoom = $tileset->{maxzoom};
    } else {
      my ($int_err, $int_msg_href) = check_integer_href({ 'maxzoom' => $maxzoom });
      if ($int_err) { 
        $data_for_postrun_href = _set_error([$int_msg_href]);
        return 1;
      }
    }

    my $resolution = $query->param('resolution') // '';
    if (!length($resolution)) {
      $resolution = $tileset->{resolution};
    } else {
      my ($int_err, $int_msg_href) = check_integer_href({ 'resolution' => $resolution });
      if ($int_err) { 
        $data_for_postrun_href = _set_error([$int_msg_href]);
        return 1;
      }
    }

    my $geometry = $query->param('geometry') // "";
    if (!length($geometry)) {
      $geometry = $tileset->{geometry};
    } else {
      eval {
        is_valid_wkt_href($dbh_write, {'geometry' => $geometry});
      } or do {
        $data_for_postrun_href = _set_error("geometry is not valid.");
        return 1;
      };
    }

    my $spectrum = $query->param('spectrum') // '';
    if (!length($spectrum)) {
      $spectrum = $tileset->{spectrum};
    }

    my $tilestatus = $query->param('tilestatus') // '';
    if (!length($tilestatus)) {
      $tilestatus = $tileset->{tilestatus};
    } else {
      my $status = lc($tilestatus);
      if ($status ne "created" && $status ne "processing" && $status ne "completed") {
        $data_for_postrun_href = _set_error("Tileset status ($tilestatus) not valid.");
        return 1;
      }
      $tilestatus = $status;
    }

    my $imagetype = $query->param('imagetype') // '';
    if (!length($imagetype)) {
      $imagetype = $tileset->{imagetype};
    }

    my $description = $query->param('description') // '';
    if (!length($description)) {
      $description = $tileset->{description};
    }

    my $metadata = $query->param('metadata') // '';
    if (!length($metadata)) {
      $metadata = $tileset->{metadata};
    } else {
      my ($err, $errmsg) = validate_metadata($metadata);
      if ($err) {
        $data_for_postrun_href = _set_error($errmsg);
        return 1;
      }
    }

    my $source = $query->param('source') // '';
    if (!length($source)) {
      $source = $tileset->{source};
    } else {
      eval {
        decode_json($source);
        1;
      } or do {
        $data_for_postrun_href = _set_error("Source is not a valid JSON");
        return 1;
      };
    }

    {
      my $sql = '';
      $sql   .= 'UPDATE tileset SET ';
      $sql   .= 'minzoom = ?, ';
      $sql   .= 'maxzoom = ?, ';
      $sql   .= 'resolution = ?, ';
      $sql   .= 'geometry = ?, ';
      $sql   .= 'spectrum = ?, ';
      $sql   .= 'tilestatus = ?, ';
      $sql   .= 'imagetype = ?, ';
      $sql   .= 'description = ?, ';
      $sql   .= 'metadata = ?, ';
      $sql   .= 'source = ? ';
      $sql   .= 'WHERE id=?';
      my $sth = $dbh_write->prepare($sql);
      my $rv = $sth->execute($minzoom, $maxzoom, $resolution, $geometry, $spectrum, $tilestatus, $imagetype, $description, $metadata, $source, $tileset_id);
    }

    $dbh_write->commit;

    $data_for_postrun_href = {};
    my $info_msg_aref = [{'Message' => "Tileset ($tileset_id) has been updated successfully."}];
    $data_for_postrun_href->{'Error'}     = 0;
    $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
    $data_for_postrun_href->{'ExtraData'} = 0;

    1;
  } or do {
    $self->logger->debug($@);
    $data_for_postrun_href = _set_error("Unexpected error.");
    eval {$dbh_write->rollback};
  };

  $dbh_write->disconnect;
  return $data_for_postrun_href;
}

sub get_tile_runmode {

=pod get_tile_HELP_START
{
"OperationName": "Get tile",
"Description": "Get the raster image of a tile specified by tileset id, z, x, and y.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"URLParameter": [{"ParameterName": "id", "Description": "tileset id"}, {"ParameterName": "z", "Description": "zoom level of the tile"}, {"ParameterName": "x", "Description": "vertical location offset of the tile (aka. row)"}, {"ParameterName": "y", "Description": "horizontal location offset of the tile (aka. column)"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 404}]
}
=cut

  my $self        = shift;
  my $tileset_id  = $self->param('id');
  my $z           = $self->param('z');
  my $x           = $self->param('x');
  my $y           = $self->param('y');

  my $image_dir = "$TILES_PATH/";

  $self->header_add(-status => 404);

  if ($tileset_id !~ /^ *(\d+) *$/) {
    return ""
  } else {
    $tileset_id = $1;
  }

  if ($z !~ /^ *(\d+) *$/) {
    return ""
  } else {
    $z = $1;
  }

  if ($x !~ /^ *(\d+) *$/) {
    return ""
  } else {
    $x = $1;
  }

  if ($y !~ /^ *(\d+) *$/) {
    return ""
  } else {
    $y = $1;
  }

  $image_dir .= $tileset_id;
  if (-d $image_dir) {
    $image_dir .= "/$z";
    if (-d $image_dir) {
      $image_dir .= "/$x";
      if (-d $image_dir) {
        opendir(my $tiles_fh, $image_dir) || die $!;
        my @image_files = grep {/^$y.(png|jpg)$/ && -f "$image_dir/$_"} readdir ($tiles_fh);
        closedir $tiles_fh;
        if (scalar(@image_files)) {
          my $image_name = $image_files[0];
          $image_dir .= "/$image_name";
          my $ext = substr($image_name, -3);
          open my $fh, '<', $image_dir or die $!;
          my $image_content =  do { local $/; <$fh> };
          $self->header_add(-status => 200);
          $self->header_add(-type => $ext eq "png" ? "image/png" : "image/jpg" );
          return $image_content
        }
      }
    }
  }

  return ""
}

sub _set_error {
  my $errmsg = $_[0] || "Unexpected error.";
  return {
    'Error' => 1,
    'Data'  => { 'Error' => [ { 'Message' => $errmsg } ] }
  };
}

sub read_layer_zooms_coordinates {
  my $path = shift;

  my $zooms_2coordinates_href = {};

  opendir(my $layer_dh, $path) || die $!;
  my @zooms = grep {/^\d+$/ && -d "$path/$_"} readdir ($layer_dh);
  closedir $layer_dh;

  foreach my $zoom (@zooms) {
    my $zoom_path = "$path/$zoom";

    $zoom = int($zoom);
    my $x_2y_href = {};
    $zooms_2coordinates_href->{$zoom} = $x_2y_href;

    opendir(my $zoom_dh, $zoom_path) || die $!;
    my @x_coords = grep {/^\d+$/ && -d "$zoom_path/$_"} readdir ($zoom_dh);
    closedir $zoom_dh;

    foreach my $x_coord (@x_coords) {
      my $x_path = "$zoom_path/$x_coord";

      $x_coord = int($x_coord);
      my $y_href = {};
      $x_2y_href->{$x_coord} = $y_href;

      opendir(my $x_dh, $x_path) || die $!;
      my @y_coords = grep {/^\d+.png$/ && -f "$x_path/$_"} readdir ($x_dh);
      closedir $x_dh;

      foreach my $y_coord (@y_coords) {
        $y_coord =~ /^(\d+).png$/;
        $y_coord = int($1);
		    $y_href->{$y_coord} = undef;
      }
    }
  }

  return $zooms_2coordinates_href
}

sub is_tiles_directory_match {
  my $truth = $_[0];
  my $test = $_[1];
  my @zooms = keys(%$truth);
  return 0 if (scalar(@zooms) != scalar(keys(%$test)));
  foreach my $zoom (@zooms) {
    return 0 if (!defined($test->{$zoom}));
    my @xcoords = keys(%{$truth->{$zoom}});
    return 0 if (scalar(@xcoords) != scalar(keys(%{$test->{$zoom}})));
    foreach my $xcoord (@xcoords) {
      return 0 if (!defined($test->{$zoom}->{$xcoord}));
      my @ycoords = keys(%{$truth->{$zoom}->{$xcoord}});
      return 0 if (scalar(@ycoords) != scalar(keys(%{$test->{$zoom}->{$xcoord}})));
      foreach my $ycoord (@ycoords) {
        return 0 if (!defined($test->{$zoom}->{$xcoord}->{$ycoord}));
      }
    }
  }
  return 1;
}

sub tomultipolygon {
  my $bound_aref = shift;
  my $lat_deg  = $bound_aref->[0];
  my $lon_deg  = $bound_aref->[1];
  my $lat_deg1 = $bound_aref->[2];
  my $lon_deg1 = $bound_aref->[3];
  return "ST_GeomFromText('GEOMETRYCOLLECTION(POLYGON(($lon_deg $lat_deg, $lon_deg1 $lat_deg, $lon_deg1 $lat_deg1, $lon_deg $lat_deg1, $lon_deg $lat_deg)))')"
}

sub validate_metadata {
  my $metadata = $_[0];
  my $ret;
  eval {
      my $metadata_href = decode_json($metadata);
      $ret = [0];
      1;
    } or do {
      $ret = [1, "Metadata is not a valid JSON"];
    };
    return $ret->[0], $ret->[1];
}

sub create_tileset {
  my $self      = $_[0];
  my $layer_id  = $_[1];
  my $query     = $_[2];

  my $ret;

  my $dbh_write = connect_gis_write(1);
  eval {
    my $layer_existence = record_existence($dbh_write, 'layer', 'id', $layer_id);
    if (!$layer_existence) {
      $ret = [1, "layer ($layer_id) does not exist."];
      return 1;
    }

    my $tileset_existence = record_existence($dbh_write, 'tileset', 'id', $layer_id);
    if ($tileset_existence) {
      $ret = [1, "tileset ($layer_id) already exists."];
      return 1;
    }

    my $layertype = read_cell_value($dbh_write, 'layer', 'layertype', 'id', $layer_id);
    if (lc($layertype) ne "layertiles") {
      $ret = [1, "layer type ($layertype) is not layertiles."];
      return 1;
    }

    my $minzoom = $query->param('minzoom') // '';
    if (!length($minzoom)) {
      $minzoom = -1;
    } else {
      my ($int_err, undef) = check_integer_href({ 'minzoom' => $minzoom });
      if ($int_err) { 
        $ret = [1, "minzoom is not an integer"];
        return 1;
      }
    }

    my $maxzoom = $query->param('maxzoom') // '';
    if (!length($maxzoom)) {
      $maxzoom = -1;
    } else {
      my ($int_err, undef) = check_integer_href({ 'maxzoom' => $maxzoom });
      if ($int_err) { 
        $ret = [1, "maxzoom is not an integer"];
        return 1;
      }
    }

    my $resolution = $query->param('resolution') // '';
    if (!length($resolution)) {
      $resolution = -1;
    } else {
      my ($int_err, undef) = check_integer_href({ 'resolution' => $resolution });
      if ($int_err) { 
        $ret = [1, "resolution is not an integer"];
        return 1;
      }
    }

    my $geometry = $query->param('geometry') // "";
    if (length($geometry)) {
      my ($is_wkt_err, undef) = is_valid_wkt_href($dbh_write, {'geometry' => $geometry}, 'polygon');
      if ($is_wkt_err) {
        $ret = [1, "geometry is not valid."];
        return 1;
      }
    } else {
      $geometry = undef;
    }

    my $spectrum = $query->param('spectrum') // '';

    my $imagetype = $query->param('imagetype') // '';

    my $description = $query->param('description') // '';

    my $metadata = $query->param('metadata') // '';
    if (length($metadata)) {
      my ($err, $errmsg) = validate_metadata($metadata);
      if ($err) {
        $ret = [1, $errmsg];
        return 1;
      }
    }

    my $source = $query->param('source') // '';
    if (length($source)) {
      eval {
        decode_json($source);
        1;
      } or do {
        $ret = [1, "Source is not a valid JSON"];
        return 1;
      };
    }

    my $sql = '';
    $sql .= 'INSERT INTO tileset ';
    $sql .= '(id, geometry, resolution, minzoom, maxzoom, tilepath, spectrum, ';
    $sql .= 'tilestatus, imagetype, description, metadata, source) ';
    $sql .= 'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';
    my $sth = $dbh_write->prepare($sql);
    my $rv = $sth->execute($layer_id, $geometry, $resolution, $minzoom, $maxzoom, '', $spectrum, 'created', $imagetype, $description, $metadata, $source);

    $dbh_write->commit;

    $ret = [0];

    1;
  } or do {
    $self->logger->debug($@);
    eval {$dbh_write->rollback};
    $ret = [1, "Unexpected error."];
  };

  $dbh_write->disconnect;
  return $ret->[0], $ret->[1];
}

sub delete_tileset {
  my $self        = $_[0];
  my $tileset_id  = $_[1];

  my $ret;

  my $dbh_write = connect_gis_write(1);
  eval {
    my $tileset_existence = record_existence($dbh_write, 'tileset', 'id', $tileset_id);
    if (!$tileset_existence) {
      $ret = [1, "tileset ($tileset_id) does not exist."];
      return 1;
    }

    {
      # Remove all tiles belonging to the tileset
      my $sql = '';
      $sql .= 'DELETE FROM tiles WHERE tileset=?';
      my $sth = $dbh_write->prepare($sql);
      my $rv = $sth->execute($tileset_id);
    }

    {
      # Remove the tiles folder
      my $tiles_path = catfile($TILES_PATH, $tileset_id);
      rmtree $tiles_path if (-e $tiles_path);
    }

    {
      # Remove the tileset
      my $sql = '';
      $sql .= 'DELETE FROM tileset WHERE id=?';
      my $sth = $dbh_write->prepare($sql);
      my $rv = $sth->execute($tileset_id);
    }

    $dbh_write->commit;

    $ret = [0];

    1;
  } or do {
    $self->logger->debug($@);
    eval {$dbh_write->rollback};
    $ret = [1, "Unexpected error."];
  };

  $dbh_write->disconnect;
  return $ret->[0], $ret->[1];
}

1;