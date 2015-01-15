package Utils;
require Exporter;

use XML::Writer;
use XML::Simple;
use LWP::UserAgent;
use HTTP::Request::Common qw(POST GET);
use HTTP::Cookies;
use Time::HiRes qw( tv_interval gettimeofday );
use String::Random qw( random_string random_regex);
use Digest::HMAC_SHA1 qw(hmac_sha1 hmac_sha1_hex);
use Digest::MD5 qw(md5 md5_hex md5_base64);
use XML::XSLT;
use JSON::XS;

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
# Version   : 2.2.5 build 795

our @ISA      = qw(Exporter);
our @EXPORT   = qw(get_write_token switch_group standard_request add_record
                   logout run_test_case add_record_upload claim_grp_ownership
                   dal_base_url make_dal_url login is_add_case who_has_no_dependent
                   is_the_same delete_test_record read_file make_random_number
                  );

my $dal_base_url_file = 'dal_base_url.conf';

our $SESSION_TIME_SECOND  = 1200;

our $ACCEPT_HEADER_LOOKUP = {'JSON' => 'application/json',
                             'XML'  => 'text/xml',
                           };

our $HTTP_TIME_OUT        = 600;

sub make_dal_url {

  my $action_path = shift;

  $action_path =~ s/^\///;#remove leading '/'

  open(my $fh, '<', $dal_base_url_file) or die "Couldn't open $dal_base_url_file : $!";

  my $dal_base_url = <$fh>;
  close $fh;

  $dal_base_url =~ s/^\s+//;#remove leading whitespace
  $dal_base_url =~ s/\/*\s*$/\//;#remove trailing whitespace and ensure one trailing '/'

  return $dal_base_url . $action_path;
}

sub get_write_token {

  my $path2cfg = '.';

  if ($_[0]) { $path2cfg = $_[0]; }

  my $filename = 'write_token';

  open(WT_FHANDLE, "< ${path2cfg}/$filename") || die "Can't read write token file.";
  my $line = <WT_FHANDLE>;
  chomp($line);
  close(WT_FHANDLE);
  return $line;
}

sub dal_base_url {
  open(my $fh, '<', $dal_base_url_file) or die 'Couldn\'t open ' . $dal_base_url_file;

  my $url = <$fh>;
  close $fh;

  $url =~ s/^\s+//;#remove leading whitespace
  $url =~ s/\/*\s*$/\//;#remove trailing whitespace and ensure one trailing '/'

  return $url;
}

sub login {

  my $parameter     = $_[0];
  my $output_format = $_[1];
  my $match         = $_[2];
  my $logger        = $_[3];

  my $username   = $parameter->{'Username'};
  my $plain_pass = $parameter->{'Password'};
  my $url        = $parameter->{'URL'};

  my $browser  = LWP::UserAgent->new();

  if (defined $ACCEPT_HEADER_LOOKUP->{$output_format}) {

    $browser->default_header('Accept' => $ACCEPT_HEADER_LOOKUP->{$output_format});
  }

  my $cookie_jar = HTTP::Cookies->new(
    file => './lwp_cookies.dat',
    autosave => 1,
    );

  $logger->debug("username: $username");

  $browser->cookie_jar($cookie_jar);

  while($url =~ /:(\w+)\/?/ ) {

    my $para_name = $1;
    my $para_val  = $parameter->{$para_name};
    $url =~ s/:${para_name}/${para_val}/;
  }

  $logger->debug("URL: $url");

  my $hash_pass  = hmac_sha1_hex($username, $plain_pass);

  $logger->debug('Plain pass: ' . $plain_pass);
  $logger->debug("Hash pass: $hash_pass");

  my $rand           = make_random_number(-len => 16);
  my $session_pass   = hmac_sha1_hex($rand, $hash_pass);
  my $signature      = hmac_sha1_hex($url, $session_pass);

  my $start_time = [gettimeofday()];

  my $auth_req_res = POST($url,
                          [
                            rand_num      => "$rand",
                            url           => "$url",
                            signature     => "$signature",
                            ]);

  my $auth_response = $browser->request($auth_req_res);
  my $msg_xml       = '';

  $logger->debug("Code: " . $auth_response->code());

  if ($auth_response->is_success) {

    $logger->debug("Status line: " . $auth_response->status_line);
    $logger->debug("Successful");

    my $write_token_result = $auth_response->content();

    $logger->debug("Result: $write_token_result");
    my $write_token_aref = {};
    my $write_token = '';
    if (uc($output_format) eq 'XML') {

      $write_token_aref = XMLin($write_token_result, ForceArray => 1);
    }
    elsif (uc($output_format) eq 'JSON') {

      $write_token_aref = decode_json($write_token_result);
    }
    $write_token = $write_token_aref->{'WriteToken'}->[0]->{'Value'};
    chomp($write_token);
    $logger->debug("Write token: $write_token");

    open(WT_FHANDLE, ">./write_token") or die "Can't save write token to file.";
    print WT_FHANDLE $write_token;
    close(WT_FHANDLE);

    my $auth_req_elapsed = tv_interval($start_time);
    $logger->debug("Authentication request elapsed time: $auth_req_elapsed");
  }
  else {

    $msg_xml = $auth_response->content();

    $logger->debug("Status line: " . $auth_response->status_line);
    $logger->debug("Content: " . $msg_xml);
  }

  my @is_match_return = is_match($auth_response, $output_format, $match, $logger);

  if ($is_match_return[0] == 1) {

    print "$msg_xml\n";
  }

  return (@is_match_return, undef);
}

sub is_match {

  my $response      = $_[0];
  my $output_format = $_[1];
  my $match_aref    = $_[2];
  my $logger        = $_[3];

  my $err = 0;
  my $attr_csv = '';
  for my $match_info (@{$match_aref}) {

    my $attr_name = '';

    if (defined $match_info->{'Attr'}) {

      $attr_name = $match_info->{'Attr'};
    }
    elsif (defined $match_info->{'VirAttr'}) {

      my $vir_attr_case_file = $match_info->{'VirAttr'};
      my $vir_attr_ref = XMLin($vir_attr_case_file, ForceArray => 1);

      if (defined $vir_attr_ref->{'FactorName'}->[0]->{'Value'}) {

        $attr_name = 'Factor' . $vir_attr_ref->{'FactorName'}->[0]->{'Value'};
      }
    }

    my $tag_name = '';

    my $match_con = $match_info->{'Value'};

    if (defined $match_info->{'Tag'}) {

      $tag_name = $match_info->{'Tag'};
    }

    if ($match_info->{'Exception'}) {

      my $response_content = $response->content();
      my $data_ref = {};
      if (uc($output_format) eq 'XML') {

        $data_ref = XMLin($response_content, ForceArray => 1);
      }
      elsif (uc($output_format) eq 'JSON') {

        $data_ref = decode_json($response_content);
      }

      my $except_val = $match_info->{'Value'};

      $logger->debug("Exception value: $except_val");

      if (defined $data_ref->{$tag_name}->[0]->{$attr_name}) {

        my $data_item = $data_ref->{$tag_name}->[0]->{$attr_name};
        my $match_data_err = match_data($except_val, $data_item, $logger);

        $logger->debug("Match error: $match_data_err");
        if ($match_data_err == 0) {

          last;
        }
      }
      else {

        next;
      }
    }

    if ($attr_name eq 'StatusCode') {

      if ($response->code() != $match_con) {

        $err = 1;
        $attr_csv .= $attr_name . ',';
      }
    }
    else {

      my $target_data_type = 'SINGLE';

      if (defined $match_info->{'TargetDataType'}) {

        $target_data_type = $match_info->{'TargetDataType'};
      }

      my $response_content = $response->content();
      my $data_ref = {};
      if (uc($output_format) eq 'XML') {

        $data_ref = XMLin($response_content, ForceArray => 1);
      }
      elsif (uc($output_format) eq 'JSON') {

        $data_ref = decode_json($response_content);
      }

      $logger->debug("Number of keys: " . keys(%{$data_ref}));
      $logger->debug("Keys: " . join(',', keys(%{$data_ref})));

      if (uc($target_data_type) eq 'SINGLE') {

        my $data_item = '';

        if (defined $data_ref->{$attr_name}->[0]->{'Value'}) {

          $data_item = $data_ref->{$attr_name}->[0]->{'Value'};
        }
        elsif (defined $data_ref->{$tag_name}->[0]->{$attr_name}) {

          $data_item = $data_ref->{$tag_name}->[0]->{$attr_name};
        }

        $logger->debug("Match condition: $match_con, data item: $data_item");

        my $match_data_err = match_data($match_con, $data_item, $logger);

        if ($match_data_err) {

          $err = 1;
          $attr_csv .= $attr_name . ',';
        }
      }
      elsif (uc($target_data_type) eq 'CSV_FILE') {

        $logger->debug("CSV_FILE TAG: $tag_name, ATTRIBUTE: $attr_name");
        if (defined $data_ref->{$tag_name}->[0]->{$attr_name}) {

          my $csv_file_full  = $data_ref->{$tag_name}->[0]->{$attr_name};
          my @file_url_block = split('/', $csv_file_full);
          my $csv_filename   = $file_url_block[-1];

          $logger->debug("Downloaded CSV file URL: $csv_file_full");

          my $browser  = LWP::UserAgent->new();
          $browser->timeout($HTTP_TIME_OUT);

          my $cookie_jar = HTTP::Cookies->new(
            file => './lwp_cookies.dat',
            autosave => 1,
            );

          $browser->cookie_jar($cookie_jar);

          my $download_csv_response = $browser->get($csv_file_full,
                                                    ':content_file' => "./$csv_filename"
                                                      );

          if (defined $match_info->{'MatchingVar'}) {

            my $data_item = '';
            my $matching_var = $match_info->{'MatchingVar'};

            if (uc($matching_var) eq 'LINE_COUNT') {

              my $wc_line = `wc -l ./$csv_filename | gawk '{print \$1}'`;
              chomp($wc_line);
              $data_item = $wc_line;
            }

            my $match_data_err = match_data($match_con, $data_item, $logger);

            if ($match_data_err) {

              $err = 1;
              $attr_csv .= $attr_name . ',';
            }
          }
        }
        else {

          $err = 1;
          $attr_csv .= $attr_name . ',';
        }
      }
      elsif (uc($target_data_type) eq 'MULTI') {

        if (uc($attr_name) eq 'COUNT') {

          if (ref $data_ref->{$tag_name} eq 'ARRAY') {

            $data_item = scalar(@{$data_ref->{$tag_name}});

            $logger->debug("Count: $data_item");
          }
          else {

            $logger->debug("Number of keys: " . keys(%{$data_ref->{$tag_name}}));
            $logger->debug("Keys: " . join(',', keys(%{$data_ref->{$tag_name}})));
            $logger->debug('ref $data_ref->{$tag_name}: ' . ref($data_ref->{$tag_name}));
          }

          my $match_data_err = match_data($match_con, $data_item, $logger);

          if ($match_data_err) {

            $err = 1;
            $attr_csv .= $attr_name . ',';
          }
        }
        else {

          $err = 1;

          for my $data (@{$data_ref->{$tag_name}}) {

            if ( !(defined $data->{$attr_name}) ) {

              next;
            }

            $data_item = $data->{$attr_name};

            my $match_data_err = match_data($match_con, $data_item, $logger);

            if ($match_data_err == 0) {

              $err = 0;
            }
          }

          if ($err == 1) {

            $attr_csv .= $attr_name . ',';
          }
        }
      }
    }
  }

  $logger->debug("err: $err");

  return ($err, $attr_csv);
}

sub match_data {

  my $match_con = $_[0];
  my $data_item = $_[1];
  my $logger    = $_[2];

  my $boolex_operator_lookup = { 'AND'    => '&&',
                                 'OR'     => '||',
                                 '[^<>]=' => '==',
                               };

  my $err = 0;
  if ($match_con =~ /regex\((.+)\)/i) {

    my $regex_str = $1;
    $logger->debug("Regular expression: $regex_str");
    if ($data_item !~ /$regex_str/) {

      $err = 1;
    }
  }
  elsif ($match_con =~ /boolex\((.+)\)/i) {

    $logger->debug('Boolex case');

    my $boolex_str = $1;

    if ($boolex_str !~ /x/) {

      $err = 1;
    }
    else {

      $boolex_str =~ s/x/ $data_item /ig;

      for my $op (keys(%{$boolex_operator_lookup})) {

        my $perl_op = $boolex_operator_lookup->{$op};
        $boolex_str =~ s/$op/$perl_op/ig;
      }

      $logger->debug("Boolex str: $boolex_str");

      my $test_condition;

      eval(q{$test_condition = } . qq{($boolex_str) ? 1 : 0;});

      if ($@) {

        $err = 1;
      }
      else {

        if ($test_condition == 0) {

          $err = 1;
        }
      }
    }
  }
  else {

    if ("$data_item" ne "$match_con") {

      $err = 1;
    }
  }

  return $err;
}

sub standard_request {

  my $parameter     = $_[0];
  my $output_format = $_[1];
  my $match         = $_[2];
  my $logger        = $_[3];

  my $url        = $parameter->{'URL'};

  while($url =~ /:(\w+)\/?/ ) {

    my $para_name = $1;
    my $para_val  = $parameter->{$para_name};
    $url =~ s/:${para_name}/${para_val}/;
  }

  my $browser  = LWP::UserAgent->new();
  $browser->timeout($HTTP_TIME_OUT);

  if (defined $ACCEPT_HEADER_LOOKUP->{$output_format}) {

    $browser->default_header('Accept' => $ACCEPT_HEADER_LOOKUP->{$output_format});
  }

  my $cookie_jar = HTTP::Cookies->new(
    file => './lwp_cookies.dat',
    autosave => 1,
    );

  $browser->cookie_jar($cookie_jar);

  my $req = POST($url, $parameter);

  my $response = $browser->request($req);
  my $msg_xml  = $response->content();

  $logger->debug("Content: " . $msg_xml);
  $logger->debug("Response code: " . $response->code());

  my @is_match_return = is_match($response, $output_format, $match, $logger);

  if ($is_match_return[0] == 1) {

    print "$msg_xml\n";
  }

  return (@is_match_return, undef);
}

sub logout {

  my $parameter     = $_[0];
  my $output_format = $_[1];
  my $match         = $_[2];
  my $logger        = $_[3];

  my $login_case_file = $parameter->{'LoginCase'};

  if (-w $login_case_file) {

    my $login_case_ref = XMLin($login_case_file, ForceArray => 1);
    $login_case_ref->{'RunInfo'}->[0]->{'Time'} = "0";
    XMLout($login_case_ref, OutputFile => $login_case_file, RootName => 'TestCase');
  }
  else {

    $logger->debug("$login_case_file not found and not writable.");
    return (1, 'LoginCase');
  }

  return standard_request($parameter, $output_format, $match, $logger)
}

sub add_record_upload {

  my $parameter     = $_[0];
  my $output_format = $_[1];
  my $match         = $_[2];
  my $logger        = $_[3];

  my $url        = $parameter->{'URL'};

  while($url =~ /:(\w+)\/?/ ) {

    my $para_name = $1;
    my $para_val  = $parameter->{$para_name};
    $url =~ s/:${para_name}/${para_val}/;
  }

  my $browser  = LWP::UserAgent->new();
  $browser->timeout($HTTP_TIME_OUT);

  if (defined $ACCEPT_HEADER_LOOKUP->{$output_format}) {

    $browser->default_header('Accept' => $ACCEPT_HEADER_LOOKUP->{$output_format});
  }

  my $cookie_jar = HTTP::Cookies->new(
    file => './lwp_cookies.dat',
    autosave => 1,
    );

  $browser->cookie_jar($cookie_jar);

  my $excl_para_name = { 'URL'          => 1,
                         'uploadfile'   => 1,
                       };

  my $rand_num = make_random_number(-len => 16);

  my $atomic_data   = q{};
  my $para_order    = q{};
  my $sending_param = [];
  for my $param_name (keys(%{$parameter})) {

    if ($excl_para_name->{$param_name}) {

      next;
    }

    my $param_value = $parameter->{$param_name};
    $atomic_data   .= "$param_value";
    $para_order    .= "${param_name},";

    push(@{$sending_param}, $param_name => "$param_value");
  }

  my $start_time = [gettimeofday()];

  my $upload_content  = $parameter->{'uploadfile'};

  while($upload_content =~ /\|:(\w+):\|?/ ) {

    my $para_name = $1;
    my $para_val  = $parameter->{$para_name};
    $upload_content =~ s/\|:${para_name}:\|/${para_val}/;
  }

  my $elapsed_time_replace = tv_interval($start_time);
  $logger->debug("Finish replacing upload file: $elapsed_time_replace (seconds)");

  $logger->debug("Submitted upload file: $upload_content");

  my $elapsed_time = tv_interval($start_time);
  $logger->debug("Finish replacing upload file and print: $elapsed_time (seconds)");

  my $upload_file_md5 = md5_hex($upload_content);

  my $data2sign = q{};
  $data2sign   .= "$url";
  $data2sign   .= "$rand_num";
  $data2sign   .= "$atomic_data";
  $data2sign   .= "$upload_file_md5";

  my $write_token = get_write_token();

  my $signature = hmac_sha1_hex($data2sign, $write_token);

  push(@{$sending_param}, 'uploadfile'     => [undef, 'uploadfile', Content => $upload_content]);
  push(@{$sending_param}, 'rand_num'       => "$rand_num");
  push(@{$sending_param}, 'url'            => "$url");
  push(@{$sending_param}, 'signature'      => "$signature");
  push(@{$sending_param}, 'param_order'    => "$para_order");

  my $req = POST($url, Content_Type => 'multipart/form-data', Content => $sending_param);

  my $response = $browser->request($req);
  my $msg_xml  = $response->content();

  $logger->debug("Add ($url): $msg_xml");

  my $return_id_href = undef;

  if ($response->code() == 200) {

    my $return_data = {};
    if (uc($output_format) eq 'XML') {

      $return_data = XMLin($msg_xml, ForceArray => 1);
    }
    elsif (uc($output_format) eq 'JSON') {

      $return_data = decode_json($msg_xml);
    }
    $return_id_href = $return_data->{'ReturnId'}->[0];
  }

  my @is_match_return = is_match($response, $output_format, $match, $logger);

  if ($is_match_return[0] == 1) {

    print "$msg_xml\n";
  }

  return (@is_match_return, $return_id_href);
}

sub add_record {

  my $parameter     = $_[0];
  my $output_format = $_[1];
  my $match         = $_[2];
  my $logger        = $_[3];

  my $url        = $parameter->{'URL'};

  while($url =~ /:(\w+)\/?/ ) {

    my $para_name = $1;
    my $para_val  = $parameter->{$para_name};
    $url =~ s/:${para_name}/${para_val}/;
  }

  my $browser  = LWP::UserAgent->new();

  if (defined $ACCEPT_HEADER_LOOKUP->{$output_format}) {

    $browser->default_header('Accept' => $ACCEPT_HEADER_LOOKUP->{$output_format});
  }

  my $cookie_jar = HTTP::Cookies->new(
    file => './lwp_cookies.dat',
    autosave => 1,
    );

  $browser->cookie_jar($cookie_jar);

  my $excl_para_name = { 'URL'          => 1,
                       };

  my $rand_num = make_random_number(-len => 16);

  my $atomic_data   = q{};
  my $para_order    = q{};
  my $sending_param = [];
  for my $param_name (keys(%{$parameter})) {

    if ($excl_para_name->{$param_name}) {

      next;
    }

    my $param_value = $parameter->{$param_name};
    $atomic_data   .= "$param_value";
    $para_order    .= "${param_name},";

    push(@{$sending_param}, $param_name => "$param_value");
  }

  my $data2sign = q{};
  $data2sign   .= "$url";
  $data2sign   .= "$rand_num";
  $data2sign   .= "$atomic_data";

  my $write_token = get_write_token();

  my $signature = hmac_sha1_hex($data2sign, $write_token);

  push(@{$sending_param}, 'rand_num'       => "$rand_num");
  push(@{$sending_param}, 'url'            => "$url");
  push(@{$sending_param}, 'signature'      => "$signature");
  push(@{$sending_param}, 'param_order'    => "$para_order");

  my $req = POST($url, $sending_param);

  my $response = $browser->request($req);
  my $msg_xml  = $response->content();

  $logger->debug("Add ($url): $msg_xml");

  my $return_id_href = undef;

  if ($response->code() == 200) {

    my $return_data = {};
    if (uc($output_format) eq 'XML') {

      $return_data = XMLin($msg_xml, ForceArray => 1);
    }
    elsif (uc($output_format) eq 'JSON') {

      $return_data = decode_json($msg_xml);
    }
    $return_id_href = $return_data->{'ReturnId'}->[0];
  }

  my @is_match_return = is_match($response, $output_format, $match, $logger);

  if ($is_match_return[0] == 1) {

    print "$msg_xml\n";
  }

  return (@is_match_return, $return_id_href);
}

sub run_test_case {

  my $case_file = $_[0];
  my $force     = $_[1];
  my $logger    = $_[2];

  $logger->debug(" $case_file: run test");

  if ( !(-r $case_file) ) {

    die "$case_file cannot be read.";
  }

  my $start_time = [gettimeofday()];

  my $tcase_data_ref = XMLin($case_file, ForceArray => 1);

  if (defined $tcase_data_ref->{'CaseInfo'}->[0]->{'Description'}) {

    print DateTime->now() . " $case_file: " . $tcase_data_ref->{'CaseInfo'}->[0]->{'Description'} . "\n";
  }

  my $output_format = 'xml';

  if (defined $tcase_data_ref->{'CaseInfo'}->[0]->{'OutputFormat'}) {

    $output_format = $tcase_data_ref->{'CaseInfo'}->[0]->{'OutputFormat'};
  }

  if ($force != 1) {

    if (defined $tcase_data_ref->{'RunInfo'}) {

      my $last_run_time = $tcase_data_ref->{'RunInfo'}->[0]->{'Time'};
      my $cur_time      = time();

      my $second_ago = $cur_time - $last_run_time;
      if ( $second_ago < $SESSION_TIME_SECOND ) {

        print DateTime->now() . " $case_file: was successfully run $second_ago seconds ago.\n";
        return;
      }
    }
  }

  my @sorted_parent = map { $_->[1] }
                      sort { $a->[0] <=> $b->[0] }
                      map { [$_->{'Order'}, $_] } @{$tcase_data_ref->{'Parent'}};

  for my $parent (@sorted_parent) {

    if (defined $parent->{'Order'}) {

      $logger->debug("$case_file: parent order: " . $parent->{'Order'});
    }

    my $case_file = $parent->{'CaseFile'};
    my $case_force = 0;

    if (defined $parent->{'Force'}) {

      $case_force = $parent->{'Force'};
    }

    run_test_case($case_file, $case_force, $logger);
  }

  my $parameter = {};

  for my $input_href (@{$tcase_data_ref->{'INPUT'}}) {

    my $para_name = '';
    my $para_val  = '';

    if (defined $input_href->{'ParaName'}) {

      $para_name = $input_href->{'ParaName'};
    }
    else {

      if ($input_href->{'Virtual'}) {

        if (defined $input_href->{'SrcName'}) {

          my $src_name_case_file = $input_href->{'SrcName'};
          my $src_name_case_data_ref = XMLin($src_name_case_file, ForceArray => 1);
          my $src_name_prefix = 'VCol_';

          if (defined $input_href->{'PrefixName'}) {

            $src_name_prefix = $input_href->{'PrefixName'};
          }

          if (defined $src_name_case_data_ref->{'ReturnId'}) {

            my $vcol_id = $src_name_case_data_ref->{'ReturnId'}->[0]->{'Value'};
            $para_name = "$src_name_prefix" . "$vcol_id";
          }
          else {

            $logger->debug("$case_file: virtual column id missing");
            die "$case_file: virtual column id missing";
          }
        }
        else {

          $logger->debug("$case_file: src file for virtual column name missing");
          die "$case_file: src file for virtual column name missing";
        }
      }
    }

    if (defined $input_href->{'Value'}) {

      $para_val  = $input_href->{'Value'};
    }
    else {

      if (defined $input_href->{'SrcValue'}) {

        my $src_case_file = $input_href->{'SrcValue'};

        #print "Src case file: $src_case_file\n";

        my $src_case_data_ref = XMLin($src_case_file, ForceArray => 1);

        if (defined $src_case_data_ref->{'ReturnId'}->[0]->{'Value'}) {

          $para_val = $src_case_data_ref->{'ReturnId'}->[0]->{'Value'};
        }
        else {

          $logger->debug("$case_file: $para_name source case $src_case_file value not found");
          die "$case_file: $para_name source case $src_case_file value not found";
        }
      }

      if (defined $input_href->{'SrcFile'}) {

        my $src_file = $input_href->{'SrcFile'};

        if (-r $src_file) {

          $para_name = 'uploadfile';

          if ($input_href->{'Process'}) {

            my $main_tag = $input_href->{'ParaName'};

            my $src_file_ref = XMLin($src_file, ForceArray => 1);
            for (my $i = 0; $i < scalar(@{$src_file_ref->{$main_tag}}); ++$i) {

              my $src_file_rec = $src_file_ref->{$main_tag}->[$i];
              if (defined $src_file_rec->{'SrcValue'}) {

                my $src_val_file = $src_file_rec->{'SrcValue'};
                my $src_val_ref = XMLin($src_val_file, ForceArray => 1);

                my $target_para_name = '';

                if (defined $src_file_rec->{'ParaName'}) {

                  $target_para_name = $src_file_rec->{'ParaName'};
                  $src_file_rec->{$target_para_name} = $src_val_ref->{'ReturnId'}->[0]->{'Value'};
                  delete($src_file_rec->{'ParaName'});
                  delete($src_file_rec->{'SrcValue'});

                  $src_file_ref->{$main_tag}->[$i] = $src_file_rec;
                }
                else {

                  $logger->debug("$case_file: undefined ParaName in $src_file");
                  die "$case_file: undefined ParaName in $src_file";
                }
              }
              else {

                $logger->debug("$case_file: undefined SrcValue in $src_file");
                die "$case_file: undefined SrcValue in $src_file";
              }
            }

            $para_val = XMLout($src_file_ref, RootName => 'DATA');
            $logger->debug("Processed XML output: $para_val");
          }
          else {

            $para_val  = read_file($src_file);
          }
        }
        else {

          $logger->debug("$case_file: $para_name source file $src_file not readable.");
          die "$case_file: $para_name source file $src_file not readable.";
        }
      }

      if ($input_href->{'Transform'}) {

        if (!(defined $input_href->{'SrcXML'})) {

          $logger->debug("$case_file: $para_name source xml file not defined for transformation.");
          die "$case_file: $para_name source xml file not defined for transformation.";
        }

        if (!(defined $input_href->{'XSL'})) {

          $logger->debug("$case_file: $para_name XSL defined for transformation.");
          die "$case_file: $para_name XSL file not defined for transformation.";
        }

        my $src_xml_file = $input_href->{'SrcXML'};
        my $xsl_file     = $input_href->{'XSL'};

        if (!(-r $src_xml_file)) {

          $logger->debug("$case_file: $para_name source xml file $src_xml_file not readable.");
          die "$case_file: $para_name source xml file $src_xml_file not readable.";
        }

        if (!(-r $xsl_file)) {

          $logger->debug("$case_file: $para_name XSL file $xsl_file not readable.");
          die "$case_file: $para_name XSL file $xsl_file not readable.";
        }

        my $src_file_ref = XMLin($src_xml_file, ForceArray => 1);
        for my $level1_key (keys(%{$src_file_ref})) {

          #print "Level1 key: $level1_key\n";

          my $level1_aref = $src_file_ref->{$level1_key};
          for my $level1_ref (@{$level1_aref}) {

            for my $level2_key (keys(%{$level1_ref})) {

              #print "Level2 key: $level2_key\n";
              my $level2_aref = $level1_ref->{$level2_key};

              for my $level2_ref (@{$level2_aref}) {

                if (defined $level2_ref->{'SrcValue'}) {

                  my $src_value_file = $level2_ref->{'SrcValue'};

                  #print "Level2 key: $level2_key | source value file: $src_value_file\n";
                  my $src_value_ref = XMLin($src_value_file, ForceArray => 1);

                  if (!(defined $level2_ref->{'ParaName'})) {

                    $logger->debug("$case_file: $para_name source value file $src_value_file undefined ParaName.");
                    die "$case_file: $para_name source value file $src_value_file undefined ParaName.";
                  }

                  my $target_para_name = $level2_ref->{'ParaName'};
                  $level2_ref->{$target_para_name} = $src_value_ref->{'ReturnId'}->[0]->{'Value'};
                  delete($level2_ref->{'ParaName'});
                  delete($level2_ref->{'SrcValue'});
                }
              }
            }
          }
        }

        my $p_src_xml_file = $src_xml_file;
        $p_src_xml_file =~ s/\.xml/_p\.xml/;

        #print "Prcessed source xml file: $p_src_xml_file\n";

        XMLout($src_file_ref, OutputFile => $p_src_xml_file, RootName => 'DATA');

        my $xslt = XML::XSLT->new($xsl_file, warnings => 1);
        my $transofrm_result = $xslt->transform($p_src_xml_file);

        $para_name = 'uploadfile';
        $para_val  = $xslt->toString();

        print "Para val: $para_val\n";
      }

      if ($input_href->{'Random'}) {

        my $input_val_prefix = '';

        if (defined $input_href->{'PrefixVal'}) {

          $input_val_prefix = $input_href->{'PrefixVal'};
        }

        my $rand_str = random_regex('\d\d\d\d\d\d\d');
        $para_val = "${input_val_prefix}$rand_str";
      }
    }

    if ((defined $input_href->{'ParaName'}) && $input_href->{'ParaName'} eq 'FactorName') {

      $tcase_data_ref->{'FactorName'} = [{'Value' => "$para_val"}];
    }

    $parameter->{$para_name} = $para_val;
  }

  my $url = $tcase_data_ref->{'CaseInfo'}->[0]->{'TargetURL'};

  if ($url !~ /http\:\/\//i) {

    $url = make_dal_url($url);
  }

  $logger->debug("URL: $url");

  $parameter->{'URL'} = $url;

  my $unsorted_match = $tcase_data_ref->{'Match'};

  my @temp_sorted_match;

  for my $m (@{$unsorted_match}) {

    my $order = 0;

    if (defined $m->{'Order'}) {

      $order = $m->{'Order'};
    }

    push(@temp_sorted_match, [$order, $m]);
  }

  my @sorted_match = map { $_->[1] }
                     sort { $a->[0] <=> $b->[0] } @temp_sorted_match;

  my $case_err       = 0;
  my $attr_csv       = '';
  my $return_id_href = undef;
  if (defined $tcase_data_ref->{'CaseInfo'}->[0]->{'CustomMethod'}) {

    my $custom_method = $tcase_data_ref->{'CaseInfo'}->[0]->{'CustomMethod'};

    ($case_err, $attr_csv, $return_id_href) = $custom_method->($parameter, $output_format, \@sorted_match, $logger);
  }
  else {

    ($case_err, $attr_csv, $return_id_href) = standard_request($parameter, $output_format, \@sorted_match, $logger);
  }

  if (defined $return_id_href) {

    $tcase_data_ref->{'ReturnId'} = [$return_id_href];
  }

  my $case_type = $tcase_data_ref->{'CaseInfo'}->[0]->{'Type'};

  if (defined $tcase_data_ref->{'CaseInfo'}->[0]->{'Description'}) {

    print DateTime->now() . " $case_file: " . $tcase_data_ref->{'CaseInfo'}->[0]->{'Description'} . "\n";
  }

  if ($case_err == 0) {

    print DateTime->now() . " $case_file: succeeded\n";
    $tcase_data_ref->{'RunInfo'} = [{'Success' => 1, 'Time' => time()}];
  }
  else {

    print DateTime->now() . " $case_file: failed | $attr_csv\n";
    $tcase_data_ref->{'RunInfo'} = [{'Success' => 0, 'Time' => 0}];
  }

  XMLout($tcase_data_ref, OutputFile => $case_file, RootName => 'TestCase');

  if ($case_type eq 'BLOCKING') {

    if ($case_err) {

      print DateTime->now() . " $case_file: BLOCKING\n";
      die "STOP\n";
    }
  }

  my $elapsed_time = tv_interval($start_time);

  $logger->debug("Run time: $elapsed_time (seconds)");

  return $case_err;
}

sub claim_grp_ownership {

  my $parameter     = $_[0];
  my $output_format = $_[1];
  my $match         = $_[2];
  my $logger        = $_[3];

  my $group_id   = $parameter->{'GroupId'};
  my $group_name = $parameter->{'GroupName'};
  my $plain_pass = $parameter->{'GroupPassword'};
  my $url        = $parameter->{'URL'};

  my $browser  = LWP::UserAgent->new();

  if (defined $ACCEPT_HEADER_LOOKUP->{$output_format}) {

    $browser->default_header('Accept' => $ACCEPT_HEADER_LOOKUP->{$output_format});
  }

  my $cookie_jar = HTTP::Cookies->new(
    file => './lwp_cookies.dat',
    autosave => 1,
    );

  $browser->cookie_jar($cookie_jar);

  while($url =~ /:(\w+)\/?/ ) {

    my $para_name = $1;
    my $para_val  = $parameter->{$para_name};
    $url =~ s/:${para_name}/${para_val}/;
  }

  my $claim_owner_random = make_random_number(-len => 16);

  $url          .= "/claim/ownership/$claim_owner_random";

  my $hash_pass              = hmac_sha1_hex($group_name, $plain_pass);
  my $group_authorised_token = hmac_sha1_hex($url, $hash_pass);

  my $rand_num = make_random_number(-len => 16);

  my $atomic_data = '';
  $atomic_data   .= "$group_authorised_token";

  my $para_order = '';
  $para_order   .= 'GroupAuthorisationToken,';

  my $data2sign = '';
  $data2sign   .= "$url";
  $data2sign   .= "$rand_num";
  $data2sign   .= "$atomic_data";

  my $write_token = get_write_token();

  my $signature = hmac_sha1_hex($data2sign, $write_token);

  my $send_parameter = [];

  push(@{$send_parameter}, rand_num                => "$rand_num");
  push(@{$send_parameter}, url                     => "$url");
  push(@{$send_parameter}, GroupAuthorisationToken => "$group_authorised_token");
  push(@{$send_parameter}, param_order             => "$para_order");
  push(@{$send_parameter}, signature               => "$signature");

  my $inside_req_res = POST ($url, $send_parameter);

  my $inside_req = $browser->request($inside_req_res);
  my $msg_xml    = $inside_req->content();

  $logger->debug($msg_xml);

  my @is_match_return = is_match($inside_req, $output_format, $match, $logger);

  if ($is_match_return[0] == 1) {

    print "$msg_xml\n";
  }

  return (@is_match_return, undef);
}

sub read_file {

  my $file_name = $_[0];

  my $content = '';
  open(FHANDLE, "<$file_name");
  while(my $line = <FHANDLE>) {

    $content .= $line;
  }
  close(FHANDLE);

  return $content;
}

sub is_add_case {

  my $case_file = $_[0];

  my $status = 0;

  my $tcase_data_ref = XMLin($case_file, ForceArray => 1);

  if ( (defined $tcase_data_ref->{'Delete'}) && (defined $tcase_data_ref->{'ReturnId'}) ) {

    $status = 1;
  }

  return $status;
}

sub who_has_no_dependent {

  my $all_case_file_output = $_[0];

  my @all_case_files = split("\n", $all_case_file_output);

  my $who_i_depend_on_lookup = {};

  for my $case_file (@all_case_files) {

    #print "Case file: $case_file\n";

    if ($case_file =~ /^#/) {

      next;
    }

    $case_file =~ s/^\.\///;

    if (is_add_case($case_file)) {

      my %who_i_depend_on;

      my $tcase_data_ref = XMLin($case_file, ForceArray => 1);
      for my $input_tag (@{$tcase_data_ref->{'INPUT'}}) {

        if (defined $input_tag->{'SrcName'}) {

          my $src_name_case_file = $input_tag->{'SrcName'};
          $src_name_case_file =~ s/^\.\///;
          if (is_add_case($src_name_case_file)) {

            #print " depends on $src_name_case_file\n";
            $who_i_depend_on{$src_name_case_file} = 1;
          }
        }

        if (defined $input_tag->{'SrcValue'}) {

          my $src_value_case_file = $input_tag->{'SrcValue'};
          $src_value_case_file =~ s/^\.\///;
          if (is_add_case($src_value_case_file)) {

            #print " depends on src_value $src_value_case_file\n";
            $who_i_depend_on{$src_value_case_file} = 1;
          }
        }
      }

      for my $parent (@{$tcase_data_ref->{'Parent'}}) {

        my $parent_case_file = $parent->{'CaseFile'};
        $parent_case_file =~ s/^\.\///;

        #print "Parent: $parent_case_file\n";

        if (is_add_case($parent_case_file)) {

          #print " depends on parent $parent_case_file\n";
          $who_i_depend_on{$parent_case_file} = 1;
        }
      }

      #print " Whom i depend on : " . join(',', keys(%who_i_depend_on)) . "\n";

      $who_i_depend_on_lookup->{$case_file} = \%who_i_depend_on;
    }
  }

  my $who_depend_on_me_lookup = {};

  for my $dependent_file (keys(%{$who_i_depend_on_lookup})) {

    #my $who_i_depend_on_str = join("\n", keys(%{$who_i_depend_on_lookup->{$dependent_file}}));
    #print "Case dependent_file: $dependent_file depends on\n $who_i_depend_on_str\n";

    for my $supporter_file (keys(%{$who_i_depend_on_lookup->{$dependent_file}})) {

      if (defined $who_depend_on_me_lookup->{$supporter_file}) {

        my $who_depend_on_me = $who_depend_on_me_lookup->{$supporter_file};
        $who_depend_on_me->{$dependent_file} = 1;
        $who_depend_on_me_lookup->{$supporter_file} = $who_depend_on_me;

        my $num_dependent = scalar(keys(%{$who_depend_on_me}));
        #print "Defined $supporter_file: $num_dependent\n";
      }
      else {

        #print "Undefined $supporter_file\n";
        my %who_depend_on_me;
        $who_depend_on_me{$dependent_file} = 1;
        $who_depend_on_me_lookup->{$supporter_file} = \%who_depend_on_me;
      }
    }
  }

  #print "===================================\n\n";

  my @case_without_dependent;

  for my $case_file (keys(%{$who_i_depend_on_lookup})) {

    if (!(defined $who_depend_on_me_lookup->{$case_file})) {

      push(@case_without_dependent, $case_file);
    }
  }

  print "Case without dependent: " . join(", ", @case_without_dependent) . "\n";

  return \@case_without_dependent;
}

sub is_the_same {

  my $array1_ref = $_[0];
  my $array2_ref = $_[1];

  my $the_same = 1;

  my $array1_len = scalar(@{$array1_ref});
  my $array2_len = scalar(@{$array2_ref});

  if ($array1_len != $array2_len) {

    $the_same = 0;
    return $the_same;
  }

  my @sorted_array1 = sort(@{$array1_ref});
  my @sorted_array2 = sort(@{$array2_ref});

  for(my $i = 0; $i < $array1_len; ++$i) {

    my $item1 = $sorted_array1[$i];
    my $item2 = $sorted_array2[$i];

    if ("$item1" ne "$item2") {

      $the_same = 0;
      last;
    }
  }

  return $the_same;
}

sub delete_test_record {

  my $case_file = $_[0];

  my $browser  = LWP::UserAgent->new();

  my $cookie_jar = HTTP::Cookies->new(
    file => './lwp_cookies.dat',
    autosave => 1,
    );

  $browser->cookie_jar($cookie_jar);

  my $tcase_data_ref = XMLin($case_file, ForceArray => 1);

  print "Delete test record in case $case_file\n";

  my $output_format = 'xml';

  if (defined $tcase_data_ref->{'CaseInfo'}->[0]->{'OutputFormat'}) {

    $output_format = $tcase_data_ref->{'CaseInfo'}->[0]->{'OutputFormat'};
  }

  if (defined $ACCEPT_HEADER_LOOKUP->{$output_format}) {

    $browser->default_header('Accept' => $ACCEPT_HEADER_LOOKUP->{$output_format});
  }

  my $delete_err = 0;

  for my $delete_ref (@{$tcase_data_ref->{'Delete'}}) {

    my $return_id = $tcase_data_ref->{'ReturnId'}->[0]->{'Value'};
    my $url       = $delete_ref->{'TargetURL'};

    $url =~ s/:\w+(\/?)/${return_id}$1/;

    if ($url !~ /http\:\/\//i) {

      $url = make_dal_url($url);
    }

    print "Delete url: $url\n";

    my $rand_num = make_random_number(-len => 16);

    my $atomic_data = '';

    my $para_order = '';

    my $data2sign = '';
    $data2sign   .= "$url";
    $data2sign   .= "$rand_num";

    my $write_token = get_write_token();

    my $signature = hmac_sha1_hex($data2sign, $write_token);

    my $parameter = [];

    push(@{$parameter}, rand_num         => "$rand_num");
    push(@{$parameter}, url              => "$url");
    push(@{$parameter}, param_order      => "$para_order");
    push(@{$parameter}, signature        => "$signature");

    my $req = POST($url, $parameter);

    my $response = $browser->request($req);

    print "Content: " . $response->content() . "\n";
    print "Response code: " . $response->code() . "\n";

    if ($response->code() != 200) {

      $delete_err = 1;
      last;
    }
  }

  if ($delete_err == 0) {

    delete($tcase_data_ref->{'ReturnId'});
    XMLout($tcase_data_ref, OutputFile => $case_file, RootName => 'TestCase');
  }

  return $delete_err;
}

sub make_random_number {

  my $len = 8;
  my %args = @_;
  if ($args{-len}) { $len = $args{-len}; }
  my @chars2use = (0 .. 9);
  my $randstring = join("", map $chars2use[rand @chars2use], 0 .. $len);
  return $randstring;
}


1;
