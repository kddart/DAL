#$Id$
#$Author$

# Copyright (c) 2011, Diversity Arrays Technology, All rights reserved.

# Author    : Puthick Hok
# Created   : 02/06/2010
# Modified  :
# Purpose   : 
#          
#          

package KDDArT::DAL::Transformation;

use strict;
use warnings;

BEGIN {
  use File::Spec;

  my ($volume, $current_dir, $file) = File::Spec->splitpath(__FILE__);

  my @current_dir_part = split('/perl-lib/KDDArT/DAL/', $current_dir);
  $main::kddart_base_dir = $current_dir_part[0];
}

use lib "$main::kddart_base_dir/perl-lib";

use KDDArT::DAL::Common;
use base qw(CGI::Application);
use Log::Log4perl qw(get_logger :levels);
use JSON::XS;
use Hash::Merge qw( merge );
use Time::HiRes qw( tv_interval gettimeofday );


sub cgiapp_init {

  my $self = shift;
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

  $self->logger->debug("Initialising Transformation");

  $self->logger->debug("CFG FILE: $CFG_FILE_PATH");

  my $cfg_start_time = gettimeofday();

  my ($load_conf_err, $load_conf_msg) = load_config();

  my $cfg_elapsed_time = sprintf("%.3f", tv_interval([$cfg_start_time]));

  $self->logger->debug("LOAD CONFIG MSG: $load_conf_msg - time: $cfg_elapsed_time");

  if ($load_conf_err) {

    die "Cannot load config file: $CFG_FILE_PATH";
  }
}

sub cgiapp_postrun {

  my ( $self, $output_ref ) = @_;

  my $query = $self->query();

  if ( ref $output_ref eq 'SCALAR' ) {

    return;
  }

  my $url    = $query->url();
  my $uri    = $ENV{'REQUEST_URI'};

  $self->logger->debug("Start postrun ... $url $uri");

  my $complex_pass_data     = $$output_ref;
  my $error_status          = $complex_pass_data->{'Error'};
  my $runmode_data          = $complex_pass_data->{'Data'};

  my $geojson_ready         = 0;

  if (defined $complex_pass_data->{'geojson'}) {

    $geojson_ready = $complex_pass_data->{'geojson'};
  }

  my $is_extra_data         = $self->authen->is_extra_data();

  $self->logger->debug("Is Extra Data: $is_extra_data");

  my $http_err_code     = 420;
  my $output_text       = '';

  if (defined $complex_pass_data->{'ExtraData'}) {

    if (length($complex_pass_data->{'ExtraData'}) > 0) {

      $is_extra_data = $complex_pass_data->{'ExtraData'};
    }
  }

  if (defined $complex_pass_data->{'HTTPErrorCode'}) {

    if (length($complex_pass_data->{'HTTPErrorCode'}) > 0) {

      $http_err_code = $complex_pass_data->{'HTTPErrorCode'};
    }
  }

  my $content_type = '';

  if ($self->authen->is_content_type_valid()) {

    $content_type = $self->authen->get_content_type();
  }

  if (defined $complex_pass_data->{'JSONONLY'}) {

    $content_type = 'JSON';
  }

  $self->logger->debug("Content type: $content_type");

  my $transform_data = {};
  # The example data structre of this array ref is like:
  # {'Organisation' => [array ref of organisation records],
  #  'Group'        => [array ref of group records],
  #  'Operation'    => [array ref of operations records],
  # }
  # Inside the hash reference, there should be only one key.

  my $hash_merger = Hash::Merge->new('LEFT_PRECEDENT');

  my $is_err = 0;

  if (length($content_type) == 0) {

    $content_type = 'XML';
  }
  else {

    $content_type = uc($content_type);
  }

  if ($error_status) {

    $self->header_add(-status => $http_err_code);
    $transform_data = $runmode_data;
    $is_err = 1;
  }
  else {

    if (defined $runmode_data) {

      if (ref $runmode_data eq 'HASH') {

        $transform_data = $runmode_data;
      }
      else {

        $self->header_add(-status => $http_err_code);
        $transform_data = {'Error' => [{'Message' => 'Unexpected error.'}] };
        $is_err = 1;
      }
    }
    else {

      $self->header_add(-status => $http_err_code);
      $transform_data = {'Error' => [{'Message' => 'Unexpected error.'}] };
      $is_err = 1;
    }

    if (!$is_err) {

      if ($is_extra_data) {

        my $user_id = $self->authen->user_id();
        my ($list_group_err, $list_group_msg, $group_data) = $self->authen->list_group($user_id);

        if (!$list_group_err) {

          my $grp_transform_data = $hash_merger->merge({'SystemGroup' => $group_data}, $transform_data);
          $transform_data = $grp_transform_data;

          my $gadmin_status = $self->authen->gadmin_status();
          my $index_script = $CGI_INDEX_SCRIPT;

          my $operation_data = dispatch_table2arrayref($index_script, $gadmin_status);
          my $opt_transform_data = $hash_merger->merge({'Operation' => $operation_data}, $transform_data);
          $transform_data = $opt_transform_data;
        }
        else {

          $self->header_add(-status => $http_err_code);
          $transform_data = {'Error' => [{'Message' => 'Unexpected error.'}] };
          $is_err = 1;
        }
      }
    }
  }

  my $rm_start_time   = $self->authen->get_rm_start_time();
  my $rm_elapsed_time = sprintf("%.3f", tv_interval([$rm_start_time]));

  my $current_runmode = $self->authen->get_current_runmode();

  $self->logger->debug("Runmode $current_runmode elapsed time: $rm_elapsed_time second(s)");

  my $stat_transform_data = $hash_merger->merge({'StatInfo' => [{'ServerElapsedTime' => $rm_elapsed_time,
                                                                 'Unit' => 'second' }]},
                                                $transform_data);
  $transform_data = $stat_transform_data;

  if ($content_type eq 'GEOJSON') {

    if (!$geojson_ready && !$is_err) {

      $transform_data = {'Error' => [{'Message' => 'GeoJson is not available.'}] };
      $is_err = 1;
    }
    else {

      my $geojson_transform_data = $hash_merger->merge({'GJSonInfo' => $complex_pass_data->{'GJSonInfo'}},
                                                       $transform_data);
      $transform_data = $geojson_transform_data;
    }
  }

  my $transformation_func_lookup = { 'JSON'    => sub { return $self->json_transformation(@_); },
                                     'XML'     => sub { return $self->xml_transformation(@_); },
                                     'GEOJSON' => sub { return $self->geojson_transformation(@_); },
  };

  my $xsl = '';

  if (defined $complex_pass_data->{'XSL'}) {

    $xsl = $complex_pass_data->{'XSL'};
  }
  $self->logger->debug("XSL: $xsl");

  if (defined $transformation_func_lookup->{$content_type}) {

    $output_text = $transformation_func_lookup->{$content_type}->($transform_data, $is_err, $xsl);
  }
  else {

    $output_text = $self->error_message('Unexpected error.');
  }

  if ($output_text =~ /[\0|\000]/) {

    $self->logger->debug("Output contains null character!!!");

    if ($output_text =~ /^[\0|\000]/) {

      $self->logger->debug("Output contains null character at the start!!!");
    }
  }

  #$self->logger->debug("Output text: $output_text");

  $$output_ref = $output_text;
}

sub json_transformation {

  my $self           = $_[0];
  my $transform_data = $_[1];
  my $is_err         = $_[2];

  my $query = $self->query();

  $self->header_add(
    -cache_control => 'no-cache, no-store, must-revalidate, post-check=1, pre-check=2',
    -type          => 'application/json',
    -charset       => 'UTF-8'
      );

  # callback is related to JSONP. Please read on the Internet about JSONP.
  # JSONP does not support error handling. So this is the way to pass error
  # to browser via JSONP.

  if (defined $query->param('callback')) {

    $self->header_add(-status => 200);
    $transform_data->{'Err'} = $is_err;
  }

  my $json_encoder = JSON::XS->new();
  $json_encoder->pretty(1);
  #$json_encoder->utf8(1);

  # utf8 does not work for Polish and Spanish
  $json_encoder->latin1(1);

  my $content_json = $json_encoder->encode($transform_data);

  if (defined $query->param('callback')) {

    my $json_callback = $query->param('callback');
    $self->logger->debug("JSON Callback: $json_callback");
    $content_json = qq/$json_callback($content_json);/;
  }

  return $content_json;
}

sub xml_transformation {

  my $self           = $_[0];
  my $transform_data = $_[1];
  my $is_err         = $_[2];
  my $xsl            = $_[3];

  $self->header_add( -type => 'text/xml' );

  my $xml_content = make_empty_xml();
  for my $xml_tag (keys(%{$transform_data})) {

    my $this_xml_content = '';
    if ( !$is_err ) {

      $self->logger->debug('Get to this point');
      $this_xml_content = recurse_arrayref2xml($transform_data->{$xml_tag}, $xml_tag);
    }
    else {

      if (length($xsl) > 0) {

        $this_xml_content = arrayref2xml($transform_data->{$xml_tag}, $xml_tag, $xsl);
      }
      else {

        $this_xml_content = arrayref2xml($transform_data->{$xml_tag}, $xml_tag);
      }
    }

    $xml_content = merge_xml($this_xml_content, $xml_content);
  }

  return $xml_content;
}

sub geojson_transformation {

  my $self           = $_[0];
  my $transform_data = $_[1];
  my $is_err         = $_[2];

  my $query = $self->query();

  $self->header_add(
    -cache_control => 'no-cache, no-store, must-revalidate, post-check=1, pre-check=2',
    -type          => 'application/json',
    -charset       => 'UTF-8'
      );

  # callback is related to JSONP. Please read on the Internet about JSONP.
  # JSONP does not support error handling. So this is the way to pass error
  # to browser via JSONP.

  my $gjson_transform_data = {};

  if ($is_err) {

    $self->header_add(-status => 200);
    $gjson_transform_data = $transform_data;
    $gjson_transform_data->{'Err'} = $is_err;
  }
  else {

    my $gjson_info = $transform_data->{'GJSonInfo'};
    $gjson_transform_data->{'features'} = [];
    $gjson_transform_data->{'type'} = 'FeatureCollection';

    my $record_meta_aref = $transform_data->{'RecordMeta'};
    my $data_tag_name    = $record_meta_aref->[0]->{'TagName'};
    my $feature_data     = $transform_data->{$data_tag_name};

    my $geo_field                = $gjson_info->{'GeometryField'};
    my $feature_name_placeholder = $gjson_info->{'FeatureName'};
    my $feature_id_field         = $gjson_info->{'FeatureId'};

    for my $record (@{$feature_data}) {

      my $geom_wkt      = $record->{$geo_field};

      if (length($geom_wkt) == 0) {

        next;
      }

      $self->logger->debug("Well know text: $geom_wkt");

      my $geojson_href  = WKT2geoJSON($geom_wkt);
      my $property_href = {};

      my @feature_name_token_list = split(' ', $feature_name_placeholder);
      my $feature_name = $feature_name_placeholder;
      my $feature_id   = $record->{$feature_id_field};

      for my $token (@feature_name_token_list) {

        if (defined $record->{$token}) {

          my $token_value = $record->{$token};
          $feature_name =~ s/$token/$token_value/g;
        }
        else {

          if ($token =~ /->/) {

            my ($array_var, $array_hash_field_name) = split(/->/, $token);

            if (ref $record->{$array_var} eq 'ARRAY') {

              if (ref $record->{$array_var}->[0] eq 'HASH') {

                if (defined $record->{$array_var}->[0]->{$array_hash_field_name}) {

                  my $token_value = $record->{$array_var}->[0]->{$array_hash_field_name};
                  $feature_name =~ s/$token/$token_value/g;
                }
              }
            }
          }
        }
      }

      my $feature_href = {};
      $feature_href->{'geometry'}   = $geojson_href;
      $feature_href->{'type'}       = 'Feature';
      $feature_href->{'properties'} = { 'name' => $feature_name, 'id' => $feature_id};

      push(@{$gjson_transform_data->{'features'}}, $feature_href);
    }
  }

  my $json_encoder = JSON::XS->new();
  $json_encoder->pretty(1);
  #$json_encoder->utf8(1);

  # utf8 does not work for Polish and Spanish
  $json_encoder->latin1(1);

  my $content_json = $json_encoder->encode($gjson_transform_data);

  if (defined $query->param('callback')) {

    my $json_callback = $query->param('callback');
    $self->logger->debug("JSON Callback: $json_callback");
    $content_json = qq/$json_callback($content_json);/;
  }

  return $content_json;
}

sub logger {

  my $self = shift;
  return $self->{logger};
}

sub error_message {

  my $self  = $_[0];
  my $msg   = $_[1];
  my $query = $self->query();

  $self->header_add(-status => 420);

  my $err_msg_aref = [{'Message' => $msg}];

  return arrayref2xml($err_msg_aref, 'Error');
}


1;
