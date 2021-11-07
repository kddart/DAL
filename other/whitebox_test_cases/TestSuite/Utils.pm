package Utils;
require Exporter;

use strict;
no strict 'refs';

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
use Cwd;
use Data::Dumper;

our @ISA      = qw(Exporter);
our @EXPORT   = qw(get_write_token switch_group standard_request add_record
                   logout run_test_case add_record_upload claim_grp_ownership
                   dal_base_url make_dal_url login is_add_case who_has_no_dependent
                   is_the_same delete_test_record read_file make_random_number
                   $STORAGE
                  );

my $dal_base_url_file     = 'dal_base_url.conf';

# This variable is no longer relevant since the test data is saved in memory
# instead of hard disk so data from previous session is irrelevant.
our $SESSION_TIME_SECOND  = 600000000000000;

our $ACCEPT_HEADER_LOOKUP = {'JSON' => 'application/json',
                             'XML'  => 'text/xml',
                           };

our $HTTP_TIME_OUT        = 6000;

our $STORAGE              = {};

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

  my $process_id = $$;

  my $filename = "write_token_${process_id}";

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

  my $process_id = $$;

  if (defined $ACCEPT_HEADER_LOOKUP->{$output_format}) {

    $browser->default_header('Accept' => $ACCEPT_HEADER_LOOKUP->{$output_format});
  }

  my $cookie_jar = HTTP::Cookies->new(
    file => "./lwp_cookies_${process_id}.dat",
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

    open(WT_FHANDLE, ">./write_token_${process_id}") or die "Can't save write token to file.";
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

    #print "$msg_xml\n";
  }

  return (@is_match_return, undef);
}

sub is_match {

  my $response      = $_[0];
  my $output_format = $_[1];
  my $match_aref    = $_[2];
  my $logger        = $_[3];

  my $process_id = $$;

  my $err = 0;
  my $attr_csv = '';
  for my $match_info (@{$match_aref}) {

    my $attr_name = '';

    if (defined $match_info->{'Attr'}) {

      $attr_name = $match_info->{'Attr'};
    }
    elsif (defined $match_info->{'VirAttr'}) {

      my $vir_attr_case_file = $match_info->{'VirAttr'};

      my $vir_attr_ref = undef;

      if (defined $STORAGE->{"${vir_attr_case_file}_${process_id}"}) {

        $vir_attr_ref = $STORAGE->{"${vir_attr_case_file}_${process_id}"};
      }
      else {

        die "No STORAGE data for ${vir_attr_case_file}_${process_id}";
      }

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
          my $csv_filename   = $file_url_block[-1] . '_' . "$process_id";

          $logger->debug("Downloaded CSV file URL: $csv_file_full");

          my $browser  = LWP::UserAgent->new();
          $browser->timeout($HTTP_TIME_OUT);

          my $cookie_jar = HTTP::Cookies->new(
            file => "./lwp_cookies_${process_id}.dat",
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
          my $data_item;

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

            my $data_item = $data->{$attr_name};

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

sub get_case_parameter {

  my $tcase_data_ref = $_[0];
  my $logger         = $_[1];
  my $case_file      = $_[2];

  my $input_aref = $tcase_data_ref->{'INPUT'};

  my $process_id = $$;

  my $parameter = {};

  my $start_time;

  my $id_data_lookup_href       = {};
  my $src_case_data_lookup_href = {};

  for my $input_href (@{$input_aref}) {

    $start_time = [gettimeofday()];

    my $para_name = '';
    my $para_val  = '';

    if (defined $input_href->{'ParaName'}) {

      $para_name = $input_href->{'ParaName'};
    }
    else {
      if ($input_href->{'Virtual'}) {

        if (defined $input_href->{'SrcName'}) {

          my $src_name_case_file = $input_href->{'SrcName'};
          my $src_name_case_data_ref = undef;

          if (defined $STORAGE->{"${src_name_case_file}_${process_id}"}) {

            $src_name_case_data_ref = $STORAGE->{"${src_name_case_file}_${process_id}"};
          }
          else {

            die "No STORAGE data for ${src_name_case_file}_${process_id}";
          }

          if (defined $input_href->{'SrcNameAttribute'}) {

            my $src_name_attribute = $input_href->{'SrcNameAttribute'};

            if (defined $src_name_case_data_ref->{'ReturnId'}->[0]->{$src_name_attribute}) {

              $para_name = $src_name_case_data_ref->{'ReturnId'}->[0]->{$src_name_attribute};
            }
            else {

              $logger->debug("SrcNameAttribute is missing in $src_name_case_file");
              die "$src_name_case_file missing SrcNameAttribute";
            }
          }
          else {

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
        }
        else {

          $logger->debug("$case_file: src file for virtual column name missing");
          die "$case_file: src file for virtual column name missing";
        }
      }
      #Filtering and standard VCol parameters are treated different. Mostly because VCol Filtering is done by name while normal additions are done by VCol_[VColId]
      if ($input_href->{'FilteringVirtual'}) {

        if (defined $input_href->{'SrcName'}) {

          my $src_name_case_file = $input_href->{'SrcName'};
          my $src_name_case_data_ref = undef;

          if (defined $STORAGE->{"${src_name_case_file}_${process_id}"}) {

            $src_name_case_data_ref = $STORAGE->{"${src_name_case_file}_${process_id}"};

            #print(Dumper($src_name_case_data_ref));

            #$para_name = "Factor".$src_name_case_data_ref->{'FactorName'}->[0]->{'Value'};
            $para_name = "Filtering";
            my $filtering_value = $input_href->{"Value"};
            $para_val = "Factor".$src_name_case_data_ref->{'FactorName'}->[0]->{'Value'}."='$filtering_value'";

            $parameter->{$para_name} = $para_val;
          }
          else {

            die "No STORAGE data for ${src_name_case_file}_${process_id}";
          }

          if (defined $input_href->{'SrcNameAttribute'}) {

            my $src_name_attribute = $input_href->{'SrcNameAttribute'};

            if (defined $src_name_case_data_ref->{'ReturnId'}->[0]->{$src_name_attribute}) {

              $para_name = $src_name_case_data_ref->{'ReturnId'}->[0]->{$src_name_attribute};
            }
            else {

              $logger->debug("SrcNameAttribute is missing in $src_name_case_file");
              die "$src_name_case_file missing SrcNameAttribute";
            }
          }
          else {

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
        }
        else {

          $logger->debug("$case_file: src file for virtual column name missing");
          die "$case_file: src file for virtual column name missing";
        }
      }
      elsif ($input_href->{'Virtual'}) {
        if (defined $input_href->{'SrcName'}) {

          my $src_name_case_file = $input_href->{'SrcName'};
          my $src_name_case_data_ref = undef;

          if (defined $STORAGE->{"${src_name_case_file}_${process_id}"}) {

            $src_name_case_data_ref = $STORAGE->{"${src_name_case_file}_${process_id}"};

            #print(Dumper($src_name_case_data_ref));

            $para_name = "Factor".$src_name_case_data_ref->{'FactorName'}->[0]->{'Value'};

            $parameter->{$para_name} = $para_val;

          }
          else {

            die "No STORAGE data for ${src_name_case_file}_${process_id}";
          }

          if (defined $input_href->{'SrcNameAttribute'}) {

            my $src_name_attribute = $input_href->{'SrcNameAttribute'};

            if (defined $src_name_case_data_ref->{'ReturnId'}->[0]->{$src_name_attribute}) {

              $para_name = $src_name_case_data_ref->{'ReturnId'}->[0]->{$src_name_attribute};
            }
            else {

              $logger->debug("SrcNameAttribute is missing in $src_name_case_file");
              die "$src_name_case_file missing SrcNameAttribute";
            }
          }
          else {

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

        my $src_case_data_ref = undef;

        if (defined $src_case_data_lookup_href->{$src_case_file}) {

          $src_case_data_ref = $src_case_data_lookup_href->{$src_case_file};
        }
        else {

          if (defined $STORAGE->{"${src_case_file}_${process_id}"}) {

            $src_case_data_ref = $STORAGE->{"${src_case_file}_${process_id}"};
          }
          else {

            # This is for static file like permission and group file
            if ($src_case_file !~ /case_\d+_\w+\.xml$/) {

              $src_case_data_ref = XMLin($src_case_file, ForceArray => 1);
            }
            else {

              die "No STORAGE for ${src_case_file}_${process_id} - Case: $case_file";
            }
          }

          $src_case_data_lookup_href->{$src_case_file} = $src_case_data_ref;
        }



        my $src_tag = 'ReturnId';

        if (defined $input_href->{'SrcTag'}) {

          $src_tag = $input_href->{'SrcTag'};
        }

        my $val_attr      = 'Value';

        if (defined $input_href->{'Attr'}) {

          $val_attr   = $input_href->{'Attr'};
        }

        if (defined $src_case_data_ref->{"$src_tag"}->[0]->{$val_attr}) {

          $para_val = $src_case_data_ref->{"$src_tag"}->[0]->{$val_attr};
        }
        elsif (defined $src_case_data_ref->{"$src_tag"}->[0]->{'IdFile'}) {

          if ( ! ((defined $input_href->{'Idx'}) && (defined $input_href->{'Attr'})) ) {

            $logger->debug("$case_file: $para_name source value 'Idx' and 'Attr' missing.");
            die "$case_file: $para_name source value 'Idx' and 'Attr' missing.";
          }

          my $file_format     = $src_case_data_ref->{"$src_tag"}->[0]->{'FileFormat'};
          my $id_file         = $src_case_data_ref->{"$src_tag"}->[0]->{'IdFile'};
          my $id_data         = undef;

          my $record_idx = $input_href->{'Idx'};

          if (defined $id_data_lookup_href->{$id_file}) {

            $id_data = $id_data_lookup_href->{$id_file};
          }
          else {

            $logger->debug("Read IdFile: $id_file");

            my $id_file_content = read_file($id_file);

            my $xml_con_start_time = [gettimeofday()];

            if (uc($file_format) eq 'XML') {

              $id_data = XMLin($id_file_content, ForceArray => 1);
            }
            elsif (uc($file_format) eq 'JSON') {

              $id_data = decode_json($id_file_content);
            }

            $id_data_lookup_href->{$id_file} = $id_data;

            my $xml_con_elapsed_time = tv_interval($xml_con_start_time);

            $logger->debug("Convert XML time: $xml_con_elapsed_time seconds");
          }

          my $lookup_start_time = [gettimeofday()];

          $para_val = $id_data->{"$src_tag"}->[$record_idx]->{$val_attr};

          my $lookup_elapsed_time = tv_interval($lookup_start_time);

          $logger->debug("Lookup time: $lookup_elapsed_time seconds");
        }
        else {

          $logger->debug("$case_file: $para_name source case $src_case_file: $src_tag - $val_attr : value not found");
          die "$case_file: $para_name source case $src_case_file value not found";
        }

        if ( (defined $input_href->{'FinalValURL'}) && (defined $input_href->{'FinalValRetrievalStep'}) ) {

          my $derived_url = $input_href->{'FinalValURL'};
          $derived_url =~ s/:\w+\/?/${para_val}/;

           if ($derived_url !~ /http\:\/\//i) {

             $derived_url = make_dal_url($derived_url);
           }

          $logger->debug("Final value URL: $derived_url");

          my $derived_req_param_href = {'URL' => $derived_url};

          my ($final_val_err, $final_val_msg,
              $dummy_return_id, $final_val_ret_data) = standard_request($derived_req_param_href,
                                                                        'XML', [], $logger);

          if ($final_val_err) {

            $logger->debug("$case_file: get the final value from the source case failed: $final_val_msg");
            die "$case_file: get the final value from the source case failed: $final_val_msg";
          }

          my $retrieval_step = $input_href->{'FinalValRetrievalStep'};

          my @retrieval_step_list = split(/,/, $retrieval_step);

          my $step_data = $final_val_ret_data;

          my $nb_step = scalar(@retrieval_step_list);

          for (my $s = 0; $s < $nb_step; $s++) {

            my $step = $retrieval_step_list[$s];

            if ( defined $step_data->{$step} ) {

              my $step_dtype = ref($step_data->{$step});

              $logger->debug("$case_file: data type for step ($step): $step_dtype");

              if ( length($step_dtype) == 0 ) {

                if ($s == ($nb_step-1)) {

                  $para_val = $step_data->{$step};
                  $logger->debug("$case_file: final param val from final val URL: $derived_url : $para_val");
                }
                else {

                  $logger->debug("$case_file: get the final value - data for non-last step($step) is scalar.");
                  die "$case_file: get the final value - data for non-last step($step) is scalar.";
                }
              }
              else {

                if ( $step_dtype eq 'ARRAY' ) {

                  if ($s < ($nb_step-1)) {

                    my $tmp_data = $step_data->{$step}->[0];
                    $step_data = $tmp_data;
                  }
                  else {

                    $logger->debug("$case_file: get the final value - data from last $step is an array.");
                    die "$case_file: get the final value - data from last $step is an array.";
                  }
                }
                else {

                  $logger->debug("$case_file: get the final value - unknown data type from $step");
                  die "$case_file: get the final value - unknown data type from $step";
                }
              }
            }
            else {

              $logger->debug("$case_file: get the final value - cannot find $step tag");
              die "$case_file: get the final value - cannot find $step tag";
            }
          }
        }
      }

      if (defined $input_href->{'SrcFile'}) {

        my $src_file = $input_href->{'SrcFile'};

        if (-r $src_file) {

          $para_name = 'uploadfile';

          # Proccess condition

          if ($input_href->{'Process'}) {

            my $main_tag = $input_href->{'ParaName'};

            my $src_file_ref = XMLin($src_file, ForceArray => 1);
            for (my $i = 0; $i < scalar(@{$src_file_ref->{$main_tag}}); ++$i) {

              my $src_file_rec = $src_file_ref->{$main_tag}->[$i];
              if (defined $src_file_rec->{'SrcValue'}) {

                my $src_val_file = $src_file_rec->{'SrcValue'};
                my $src_val_ref  = undef;

                if (defined $STORAGE->{"${src_val_file}_${process_id}"}) {

                  $src_val_ref = $STORAGE->{"${src_val_file}_${process_id}"};
                }
                else {

                  die "No STORAGE for ${src_val_file}_${process_id}";
                }

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
                }
              }
              else {

                $logger->debug("$case_file: undefined SrcValue in $src_file");
              }

              if (defined $src_file_rec->{'NextLevelProccessTag'}) {

                my $next_l_proc_tagname = $src_file_rec->{'NextLevelProccessTag'};
                my $next_l_recs         = $src_file_rec->{$next_l_proc_tagname};

                my $new_next_l_recs = [];

                for (my $j = 0; $j < scalar(@{$next_l_recs}); $j++) {

                  my $next_l_rec = $next_l_recs->[$j];

                  if (defined $next_l_rec->{'SrcValue'}) {

                    my $next_l_src_val_file = $next_l_rec->{'SrcValue'};
                    my $next_l_src_val_ref  = undef;

                    if (defined $STORAGE->{"${next_l_src_val_file}_${process_id}"}) {

                      $next_l_src_val_ref = $STORAGE->{"${next_l_src_val_file}_${process_id}"};
                    }
                    else {

                      die "No STORAGE for ${next_l_src_val_file}_${process_id}";
                    }

                    my $next_l_target_para_name = '';

                    if (defined $next_l_rec->{'ParaName'}) {

                      $next_l_target_para_name                = $next_l_rec->{'ParaName'};
                      $next_l_rec->{$next_l_target_para_name} = $next_l_src_val_ref->{'ReturnId'}->[0]->{'Value'};
                      delete($next_l_rec->{'ParaName'});
                      delete($next_l_rec->{'SrcValue'});
                    }
                    else {

                      $logger->debug("$case_file: undefined ParaName in $src_file");
                      die "$case_file: undefined ParaName in $src_file";
                    }
                  }

                  push(@{$new_next_l_recs}, $next_l_rec);
                }

                delete($src_file_rec->{'NextLevelProccessTag'});
                $src_file_rec->{$next_l_proc_tagname} = $new_next_l_recs;
              }
            }

            $para_val = XMLout($src_file_ref, RootName => 'DATA');
            $logger->debug("Processed XML output: $para_val");
          }
          else {

            # instead of reading the file, pass the file path and other para in a hash if DirectReplacement="1"

            if ($input_href->{'DirectReplacement'}) {

              if ($input_href->{'DirectReplacement'} eq '1') {

                if ( !(defined $input_href->{'HeaderRow'}) ) {

                  die "$case_file: $para_name source xml file $src_file with direct replacement set without header row.";
                }

                $para_val = {'FilePath' => $src_file, 'HeaderRow' => $input_href->{'HeaderRow'}, 'DirectReplacement' => 1};
              }
              else {

                $para_val  = read_file($src_file);
              }
            }
            elsif ($input_href->{'MemoryReplacementXML'}) {

              if ($input_href->{'MemoryReplacementXML'} eq '1') {

                if ( ! defined($input_href->{'ParaName'}) ) {

                  $logger->debug("$case_file: $para_name - XMLin source file $src_file ParaName not defined.");
                  die "$case_file: $para_name - XMLin source file $src_file ParaName not defined.";
                }

                my $input_para_name = $input_href->{'ParaName'};

                my $xml_content  = read_file($src_file);

                my $src_file_aref = xml2arrayref($xml_content, $input_para_name);

                $logger->debug("MemoryReplacementXML: $input_para_name");

                if (ref($src_file_aref) ne 'ARRAY') {

                  $logger->debug("$case_file: $para_name - XMLin source file $src_file doesn't return arrayref.");
                  die "$case_file: $para_name - XMLin source file $src_file doesn't return arrayref.";
                }

                $para_val = {'MemoryReplacementXML' => 1, 'DATA' => $src_file_aref, 'DATATAG' => $input_para_name};
              }
            }
            else {

              $para_val  = read_file($src_file);
            }
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
                  my $src_value_ref = undef;

                  if (defined $STORAGE->{"${src_value_file}_${process_id}"}) {

                    $src_value_ref = $STORAGE->{"${src_value_file}_${process_id}"};
                  }
                  else {

                    die "No STORAGE for ${src_value_file}_${process_id} - Case: $case_file";
                  }

                  if (!(defined $level2_ref->{'ParaName'})) {

                    $logger->debug("$case_file: $para_name source value file $src_value_file undefined ParaName.");
                    die "$case_file: $para_name source value file $src_value_file undefined ParaName.";
                  }

                  my $target_para_name = $level2_ref->{'ParaName'};
                  $level2_ref->{$target_para_name} = $src_value_ref->{'ReturnId'}->[0]->{'Value'};
                  delete($level2_ref->{'ParaName'});
                  delete($level2_ref->{'SrcValue'});
                }

                if (defined $level2_ref->{'Random'}) {

                  my $prefix = '';

                  if (defined $level2_ref->{'PrefixVal'}) {

                    $prefix = $level2_ref->{'PrefixVal'};
                    delete($level2_ref->{'PrefixVal'});
                  }

                  my $rand_val_size = 11;

                  if (defined $level2_ref->{'Size'}) {

                    $rand_val_size = $level2_ref->{'Size'} - length($prefix);
                    delete($level2_ref->{'Size'});
                  }

                  my $rand_str = random_regex('\d' x $rand_val_size);
                  my $target_para_name = $level2_ref->{'ParaName'};
                  $level2_ref->{$target_para_name} = $rand_str;
                  delete($level2_ref->{'ParaName'});
                  delete($level2_ref->{'Random'});
                }
              }
            }
          }
        }

        my $p_src_xml_file = $src_xml_file;
        $p_src_xml_file    =~ s/\.xml/_p_${process_id}\.xml/;

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

        my $rand_val_size = 11;

        if (defined $input_href->{'Size'}) {

          $rand_val_size = $input_href->{'Size'} - length($input_val_prefix);
        }

        my $rand_str = random_regex('\d' x $rand_val_size);
        $para_val = "${input_val_prefix}$rand_str";

        #print "Random - para name: $para_name - para val: $para_val\n";
      }
    }

    if ((defined $input_href->{'ParaName'}) && $input_href->{'ParaName'} eq 'FactorName') {

      $tcase_data_ref->{'FactorName'} = [{'Value' => "$para_val"}];
    }

    $parameter->{$para_name} = $para_val;

    $logger->debug("Para name: $para_name - val: $para_val");

    my $elapsed_time = tv_interval($start_time);
    $logger->debug("$case_file - $para_name - $elapsed_time seconds");
  }

  return $parameter;
}

sub standard_request {

  my $parameter     = $_[0];
  my $output_format = $_[1];
  my $match         = $_[2];
  my $logger        = $_[3];

  my $url        = $parameter->{'URL'};

  my $process_id = $$;

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
    file => "./lwp_cookies_${process_id}.dat",
    );

  $browser->cookie_jar($cookie_jar);

  my $req = POST($url, $parameter);

  my $response     = $browser->request($req);
  my $msg_content  = $response->content();

  $logger->debug("Content: " . $msg_content);
  $logger->debug("Response code: " . $response->code());

  my $return_data    = {};

  if ($response->code() == 200) {

    if (uc($output_format) eq 'XML') {

      $return_data = XMLin($msg_content, ForceArray => 1);
    }
    elsif (uc($output_format) eq 'JSON') {

      $return_data = decode_json($msg_content);
    }
  }

  my @is_match_return = is_match($response, $output_format, $match, $logger);

  if ($is_match_return[0] == 1) {

    #print "$msg_content\n";
  }

  return (@is_match_return, undef, $return_data);
}

sub logout {

  my $parameter     = $_[0];
  my $output_format = $_[1];
  my $match         = $_[2];
  my $logger        = $_[3];

  my $url        = $parameter->{'URL'};

  my $process_id = $$;

  my $browser  = LWP::UserAgent->new();
  $browser->timeout($HTTP_TIME_OUT);

  if (defined $ACCEPT_HEADER_LOOKUP->{$output_format}) {

    $browser->default_header('Accept' => $ACCEPT_HEADER_LOOKUP->{$output_format});
  }

  my $cookie_jar = HTTP::Cookies->new(
    file => "./lwp_cookies_${process_id}.dat",
    autosave => 1,
    );

  $browser->cookie_jar($cookie_jar);

  my $req = POST($url, $parameter);

  my $response     = $browser->request($req);
  my $msg_content  = $response->content();
  my $header_href  = $response->headers();

  $logger->debug("Content: " . $msg_content);
  $logger->debug("Response code: " . $response->code());

  foreach my $header_key (keys(%{$header_href})) {

    my $header_val = $header_href->{$header_key};
    $logger->debug("Header val data type: " . ref($header_val));

    if (ref $header_val eq 'HASH') {

      $logger->debug("Header : $header_key");
      foreach my $sub_header_key (keys(%{$header_val})) {

        my $sub_header_val = $header_val->{$sub_header_key};
        $logger->debug("Sub header key: $sub_header_key - $sub_header_val");
      }
    }
    elsif (ref $header_val eq 'ARRAY') {

      $logger->debug("Header : $header_key - " . join(',', @{$header_val}));
    }
    else {

      $logger->debug("Header : $header_key - $header_val");
    }
  }

  my $return_data    = {};

  if ($response->code() == 200) {

    if (uc($output_format) eq 'XML') {

      $return_data = XMLin($msg_content, ForceArray => 1);
    }
    elsif (uc($output_format) eq 'JSON') {

      $return_data = decode_json($msg_content);
    }
  }

  my @is_match_return = is_match($response, $output_format, $match, $logger);

  if ($is_match_return[0] == 1) {

    #print "$msg_content\n";
  }

  return (@is_match_return, undef, $return_data);
}

sub add_record_upload {

  my $parameter     = $_[0];
  my $output_format = $_[1];
  my $match         = $_[2];
  my $logger        = $_[3];

  my $url        = $parameter->{'URL'};

  my $process_id = $$;

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
    file => "./lwp_cookies_${process_id}.dat",
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

    while ($param_value =~ /\|:(\w+):\|/ ) {

      my $lookup_param_name = $1;
      my $lookup_param_val  = $parameter->{$lookup_param_name};

      $param_value =~ s/\|:${lookup_param_name}:\|/${lookup_param_val}/;
    }

    $atomic_data   .= "$param_value";
    $para_order    .= "${param_name},";

    push(@{$sending_param}, $param_name => "$param_value");
  }

  my $start_time = [gettimeofday()];

  my $upload_file_md5 = '';

  if (ref($parameter->{'uploadfile'}) eq 'HASH') {

    if (defined $parameter->{'uploadfile'}->{'DirectReplacement'}) {

      if ($parameter->{'uploadfile'}->{'DirectReplacement'} eq '1') {

        my $header_row = $parameter->{'uploadfile'}->{'HeaderRow'} + 1;
        my $file_path  = $parameter->{'uploadfile'}->{'FilePath'};

        my $sed_cmd    = qq|sed -n '${header_row}p' $file_path|;

        my $old_header = `$sed_cmd`;
        my $new_header = $old_header;

        while($new_header =~ /\|:(\w+):\|/ ) {

          my $para_name = $1;
          my $para_val  = $parameter->{$para_name};
          $new_header   =~ s/\|:${para_name}:\|/${para_val}/;
        }

        $logger->debug("OLD HEADER: $old_header");
        $logger->debug("NEW HEADER: $new_header");

        my @file_path_split = split('/', $file_path);

        my $file_name = $file_path_split[-1];

        my $new_file_name = 'newfile_' . random_regex('\d\d\d\d\d\d\d') . '_' . $file_name . '_' . $process_id;

        my $last_path_element = scalar(@file_path_split) - 2;

        my $just_path = join('/', @file_path_split[0..$last_path_element]);

        my $upload_file_path = cwd() . '/' . $just_path . '/' . $new_file_name;

        my $before_header_row = $header_row - 1;

        $sed_cmd = qq|sed -n '1,${before_header_row}'p $file_path > $upload_file_path|;

        my $cmd_result = `$sed_cmd`;

        $logger->debug("RESULT OF $sed_cmd : $cmd_result");

        my $upload_filehandle;

        open($upload_filehandle, ">$upload_file_path");

        print $upload_filehandle "$new_header";

        close($upload_filehandle);

        my $next_line_number = $header_row + 1;

        $sed_cmd = qq|sed -n '$next_line_number,\$'p $file_path >> $upload_file_path|;

        $cmd_result = `$sed_cmd`;

        $logger->debug("RESULT OF $sed_cmd : $cmd_result");

        open(my $upload_fh, "$upload_file_path");

        my $md5_engine = Digest::MD5->new();
        $md5_engine->addfile($upload_fh);

        close($upload_fh);

        $upload_file_md5 = $md5_engine->hexdigest();

        push(@{$sending_param}, 'uploadfile' => [$upload_file_path]);
      }
    }
    elsif (defined $parameter->{'uploadfile'}->{'MemoryReplacementXML'}) {

      $logger->debug("Memory replacement in XML mode");

      if ($parameter->{'uploadfile'}->{'MemoryReplacementXML'} eq '1') {

        my $upload_data_aref = $parameter->{'uploadfile'}->{'DATA'};
        my $upload_tag       = $parameter->{'uploadfile'}->{'DATATAG'};

        my $transformed_data_aref = [];

        foreach my $upload_data_href (@{$upload_data_aref}) {

          foreach my $up_param (keys(%{$upload_data_href})) {

            my $upload_data_val = $upload_data_href->{$up_param};

            if (ref $upload_data_val eq 'ARRAY') {

              my $next_data_aref = [];

              foreach my $next_rec_href (@{$upload_data_val}) {

                foreach my $next_param (keys(%{$next_rec_href})) {

                  my $next_val = $next_rec_href->{$next_param};

                  if ($next_val =~ /\|:(\w+):\|/) {

                    my $p_name = $1;
                    my $p_val  = $parameter->{$p_name};

                    $logger->debug("XML upload param name: $p_name - $p_val");

                    $next_val =~ s/\|:${p_name}:\|/${p_val}/;

                    $next_rec_href->{$next_param} = $next_val;
                  }
                }

                push(@{$next_data_aref}, $next_rec_href);
              }

              $upload_data_href->{$up_param} = $next_data_aref;
            }
            else {

              $logger->debug("XML upload param val: $up_param - $upload_data_val");

              if ( $upload_data_val =~ /\|:(\w+):\|/ ) {

                my $p_name = $1;
                my $p_val  = $parameter->{$p_name};

                $logger->debug("XML upload param name: $p_name - $p_val");

                $upload_data_val =~ s/\|:${p_name}:\|/${p_val}/;

                $logger->debug("XML upload param val: $up_param - $upload_data_val");

                $upload_data_href->{$up_param} = $upload_data_val;
              }
            }
          }

          push(@{$transformed_data_aref}, $upload_data_href);
        }

        my $upload_content = recurse_arrayref2xml($transformed_data_aref, $upload_tag);

        $upload_file_md5 = md5_hex($upload_content);

        push(@{$sending_param}, 'uploadfile'     => [undef, 'uploadfile', Content => $upload_content]);

        $logger->debug("Submitted upload file: $upload_content");
      }
    }
  }
  else {

    my $upload_content  = $parameter->{'uploadfile'};

    while($upload_content =~ /\|:(\w+):\|/ ) {

      my $para_name = $1;
      my $para_val  = $parameter->{$para_name};
      $upload_content =~ s/\|:${para_name}:\|/${para_val}/;
    }

    $upload_file_md5 = md5_hex($upload_content);

    push(@{$sending_param}, 'uploadfile'     => [undef, 'uploadfile', Content => $upload_content]);

    $logger->debug("Submitted upload file: $upload_content");
  }

  my $elapsed_time_replace = tv_interval($start_time);
  $logger->debug("Finish replacing upload file: $elapsed_time_replace (seconds)");

  my $elapsed_time = tv_interval($start_time);
  $logger->debug("Finish replacing upload file and print: $elapsed_time (seconds)");

  my $data2sign = q{};
  $data2sign   .= "$url";
  $data2sign   .= "$rand_num";
  $data2sign   .= "$atomic_data";
  $data2sign   .= "$upload_file_md5";

  my $write_token = get_write_token();

  my $signature = hmac_sha1_hex($data2sign, $write_token);

  push(@{$sending_param}, 'rand_num'       => "$rand_num");
  push(@{$sending_param}, 'url'            => "$url");
  push(@{$sending_param}, 'signature'      => "$signature");
  push(@{$sending_param}, 'param_order'    => "$para_order");

  my $req = POST($url, Content_Type => 'multipart/form-data', Content => $sending_param);

  my $response     = $browser->request($req);
  my $msg_content  = $response->content();

  $logger->debug("Add ($url): $msg_content");

  my $return_id_href = undef;
  my $return_data    = {};

  if ($response->code() == 200) {

    if (uc($output_format) eq 'XML') {

      $return_data = XMLin($msg_content, ForceArray => 1);
    }
    elsif (uc($output_format) eq 'JSON') {

      $return_data = decode_json($msg_content);
    }

    if (defined $return_data->{'ReturnId'}) {

      $return_id_href = $return_data->{'ReturnId'}->[0];
    }
    elsif (defined $return_data->{'ReturnIdFile'}) {

      $logger->debug("Output Format: $output_format");

      my $return_id_f_href   = $return_data->{'ReturnIdFile'}->[0];
      my $return_id_file_url = $return_id_f_href->{lc($output_format)};

      $logger->debug("Return ID file URL: $return_id_file_url");

      my @file_url_block = split('/', $return_id_file_url);
      my $filename = $file_url_block[-1] . '_' . $process_id;

      $logger->debug("ID filename: $filename");

      sleep(10);

      $browser->default_header('Cache-Control' => 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0');

      my $download_response = $browser->get($return_id_file_url,
                                            ':content_file' => "./$filename"
                                            );

      if (!$download_response->is_success) {

        #debug("Status code: " . $download_response->code());
        # return (err, msg, err_aref)
        die "$url - $return_id_file_url - Cannot download return id file";
      }

      $return_id_href = {
        'IdFile' => "./$filename",
        'FileFormat' => lc($output_format)
        };
    }
  }

  my @is_match_return = is_match($response, $output_format, $match, $logger);

  if ($is_match_return[0] == 1) {

    print "$msg_content\n";
  }

  return (@is_match_return, $return_id_href, $return_data);
}

sub add_record {

  my $parameter     = $_[0];
  my $output_format = $_[1];
  my $match         = $_[2];
  my $logger        = $_[3];

  my $url        = $parameter->{'URL'};

  my $process_id = $$;

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
    file => "./lwp_cookies_${process_id}.dat",
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

    while ($param_value =~ /\|:(\w+):\|/ ) {

      my $lookup_param_name = $1;
      my $lookup_param_val  = $parameter->{$lookup_param_name};

      $param_value =~ s/\|:${lookup_param_name}:\|/${lookup_param_val}/;
    }

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

  my $response     = $browser->request($req);
  my $msg_content  = $response->content();

  $logger->debug("Add ($url): $msg_content");

  my $return_id_href = undef;
  my $return_data    = {};

  if ($response->code() == 200) {

    if (uc($output_format) eq 'XML') {

      $return_data = XMLin($msg_content, ForceArray => 1);
    }
    elsif (uc($output_format) eq 'JSON') {

      $return_data = decode_json($msg_content);
    }

    if (defined $return_data->{'ReturnId'}) {

      $return_id_href = $return_data->{'ReturnId'}->[0];
    }
  }

  my @is_match_return = is_match($response, $output_format, $match, $logger);

  if ($is_match_return[0] == 1) {

    print "$msg_content\n";
  }

  return (@is_match_return, $return_id_href, $return_data);
}

sub run_test_case {

  my $case_file      = $_[0];
  my $force          = $_[1];
  my $logger         = $_[2];
  my $time_stat_href = $_[3];

  $logger->debug(" $case_file: run test");

  my $process_id = $$;

  if ( !(-r $case_file) ) {
    print "$case_file cannot be read.";
    die "$case_file cannot be read.";
  }

  my $start_time = [gettimeofday()];

  my $tcase_data_ref = XMLin($case_file, ForceArray => 1);

  if (defined $STORAGE->{"${case_file}_${process_id}"}) {

    $tcase_data_ref = $STORAGE->{"${case_file}_${process_id}"};
  }

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

    run_test_case($case_file, $case_force, $logger, $time_stat_href);
  }

  my $parameter = get_case_parameter($tcase_data_ref, $logger, $case_file);

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
  my $return_data    = undef;

  if (defined $tcase_data_ref->{'CaseInfo'}->[0]->{'CustomMethod'}) {

    my $custom_method = $tcase_data_ref->{'CaseInfo'}->[0]->{'CustomMethod'};

    ($case_err, $attr_csv, $return_id_href, $return_data) = $custom_method->($parameter, $output_format, \@sorted_match, $logger);
  }
  else {

    ($case_err, $attr_csv, $return_id_href, $return_data) = standard_request($parameter, $output_format, \@sorted_match, $logger);
  }

  if (defined $return_id_href) {

    $tcase_data_ref->{'ReturnId'} = [$return_id_href];
  }
  else {

    if (defined $return_data) {

      if (defined $tcase_data_ref->{'CaseInfo'}->[0]->{'CaptureFieldName'}) {

        my $capture_field_name = $tcase_data_ref->{'CaseInfo'}->[0]->{'CaptureFieldName'};

        if (defined $return_data->{'RecordMeta'}) {

          my $ret_tag_name = $return_data->{'RecordMeta'}->[0]->{'TagName'};
          $return_id_href = {};

          if (defined $return_data->{$ret_tag_name}) {

            $return_id_href->{'ParaName'} = $capture_field_name;

            my $cap_idx = 0;

            if (defined $tcase_data_ref->{'CaseInfo'}->[0]->{'CaptureIndex'}) {

              $cap_idx = $tcase_data_ref->{'CaseInfo'}->[0]->{'CaptureIndex'};
            }

            if (defined $return_data->{$ret_tag_name}->[$cap_idx]->{$capture_field_name}) {

              $return_id_href->{'Value'}    = $return_data->{$ret_tag_name}->[$cap_idx]->{$capture_field_name};
              $tcase_data_ref->{'ReturnId'} = [$return_id_href];
            }
            else {

              die "$capture_field_name is not found.\n";
            }
          }
          else {

            die "$ret_tag_name is not exists.\n";
          }
        }
      }
    }
  }

  if (defined $return_data->{'ReturnOther'}) {

    $tcase_data_ref->{'ReturnOther'} = $return_data->{'ReturnOther'};
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

  $logger->debug("${case_file}_${process_id} : " . Dumper($tcase_data_ref));
  $STORAGE->{"${case_file}_${process_id}"} = $tcase_data_ref;

  if ($case_type eq 'BLOCKING') {

    if ($case_err) {

      print DateTime->now() . " $case_file: BLOCKING\n";
      die "STOP\n";
    }
  }

  my $elapsed_time = tv_interval($start_time);
  my $dal_time = "00:00";

  if (defined $return_data->{'StatInfo'}->[0]->{'ServerElapsedTime'}) {

    $dal_time = $return_data->{'StatInfo'}->[0]->{'ServerElapsedTime'};
  }

  $logger->debug("Run time: $elapsed_time (seconds) - DAL time: $dal_time");

  if (defined $dal_time) {

    if (defined $time_stat_href->{$case_file}) {

      push(@{$time_stat_href->{$case_file}}, [$process_id, $elapsed_time, $dal_time]);
    }
    else {

      $time_stat_href->{$case_file} = [[$process_id, $elapsed_time, $dal_time]];
    }
  }

  print "PID: $process_id - $case_file - Test time: $elapsed_time - DAL time: $dal_time\n";

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

  my $process_id = $$;

  my $browser  = LWP::UserAgent->new();

  if (defined $ACCEPT_HEADER_LOOKUP->{$output_format}) {

    $browser->default_header('Accept' => $ACCEPT_HEADER_LOOKUP->{$output_format});
  }

  my $cookie_jar = HTTP::Cookies->new(
    file => "./lwp_cookies_${process_id}.dat",
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

  my $inside_req     = $browser->request($inside_req_res);
  my $msg_content    = $inside_req->content();

  $logger->debug($msg_content);

  my $return_data    = {};

  if ($inside_req_res->code() == 200) {

    if (uc($output_format) eq 'XML') {

      $return_data = XMLin($msg_content, ForceArray => 1);
    }
    elsif (uc($output_format) eq 'JSON') {

      $return_data = decode_json($msg_content);
    }
  }

  my @is_match_return = is_match($inside_req, $output_format, $match, $logger);

  if ($is_match_return[0] == 1) {

    #print "$msg_content\n";
  }

  return (@is_match_return, undef, $return_data);
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

  my $process_id = $$;

  my $status = 0;

  my $tcase_data_ref = XMLin($case_file, ForceArray => 1);

  if (defined $STORAGE->{"${case_file}_${process_id}"}) {

    $tcase_data_ref = $STORAGE->{"${case_file}_${process_id}"};
  }

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
  my $logger    = $_[1];

  my $browser  = LWP::UserAgent->new();

  my $process_id = $$;

  my $cookie_jar = HTTP::Cookies->new(
    file => "./lwp_cookies_${process_id}.dat",
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

    my $case_parameter = get_case_parameter($tcase_data_ref, $logger, $url);

    for my $para_name (keys(%{$case_parameter})) {

      my $para_val  = $case_parameter->{$para_name};
      $url =~ s/:${para_name}/${para_val}/;
    }

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

    #print "Content: " . $response->content() . "\n";
    #print "Response code: " . $response->code() . "\n";

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

sub make_xml_tag {

  my $data     = $_[0];
  my $tag_name = $_[1];
  my $writer   = $_[2];

  if (!$writer) {

    return 1;
  }

  for my $row (@{$data}) {

    my $nested = 0;
    my %attributes;
    my @nested_field;
    for my $fieldname (keys(%{$row})) {

      if (ref $row->{$fieldname} eq 'ARRAY') {

        $nested = 1;
        push(@nested_field, $fieldname);
      }
      else {

        $attributes{$fieldname} = $row->{$fieldname};
      }
    }

    if ($nested) {

      $writer->startTag($tag_name, %attributes);
      for my $nested_fieldname (@nested_field) {

        make_xml_tag($row->{$nested_fieldname}, $nested_fieldname, $writer);
      }
      $writer->endTag($tag_name);
    }
    else {

      $writer->emptyTag($tag_name, %attributes);
    }
  }

  return 0;
}

sub recurse_arrayref2xml {

  my $data      = $_[0];
  my $tag_name  = $_[1];
  my $xsl       = $_[2];

  my $xml = '';
  my $writer = new XML::Writer(OUTPUT => \$xml, DATA_MODE => 1);
  $writer->xmlDecl('UTF-8');

  if ($xsl && length($xsl) > 0) {

    $writer->pi('xml-stylesheet', qq{href="$xsl" type="text/xsl"});
  }

  my $root_tag = 'DATA';
  $writer->startTag($root_tag);
  make_xml_tag($data, $tag_name, $writer);
  $writer->endTag($root_tag);
  $writer->end();

  return $xml;
}

sub xml2arrayref {

  my $data_src = $_[0];
  my $tag_name = $_[1];

  my $data_ref = XMLin($data_src, ForceArray => 1);

  my $data_row_ref = [];
  if ($data_ref->{$tag_name}) {

    # when there is only one tag inside the root tag, XMLin
    # returns a hash reference rather than array reference.
    if ( ref $data_ref->{$tag_name} eq 'HASH' ) {

      my @forced_aref;
      push(@forced_aref, $data_ref->{$tag_name});
      $data_row_ref = \@forced_aref;
    }
    elsif (ref $data_ref->{$tag_name} eq 'ARRAY') {

      $data_row_ref = $data_ref->{$tag_name};
    }
  }

  return $data_row_ref;
}

1;
