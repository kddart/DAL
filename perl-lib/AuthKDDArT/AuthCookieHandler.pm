package AuthKDDArT::AuthCookieHandler;

use strict;
use warnings;

use KDDArT::DAL::Common;
use base 'Apache2_4::AuthCookie';

use Apache2::Const qw(:common HTTP_FORBIDDEN);
use Apache2_4::AuthCookie;
use Apache2::RequestRec;
use Apache2::RequestIO;
use Apache2::RequestUtil;
use CGI::Session;
use Digest::HMAC_SHA1 qw(hmac_sha1 hmac_sha1_hex);
use vars qw($VERSION @ISA);

sub authen_cred ($$\@) {
  my $self = shift;
  my $r = shift;
  my @creds = @_;

  $r->log_error($self->cookie_name($r));
  my $cookie = ($r->headers_in->get("Cookie") || "");
  my $session_token = '';
  return $session_token;
}

sub authen_ses_key ($$$) {

  my ($self, $r, $cookie) = @_;
  my $user = '';

  $cookie = ($r->headers_in->get("Cookie") || "");

  my $sess_id_cookie_name = $self->cookie_name($r);

  my $session_id = read_cookie($cookie, $sess_id_cookie_name);

  $r->log_error("FILEAUTH: SessionId: $session_id");
  $r->log_error("FILEAUTH: Cookie: $cookie");

  my $filename     = $r->filename();
  my $uri          = $r->uri();
  my $unparsed_uri = $r->unparsed_uri();

  my $document_root = $r->document_root();

  my $args_txt     = $r->args();

  my $args_txt_print = '';

  if (defined $args_txt) {

    $args_txt_print = $args_txt;
  }

  $r->log_error("FILEAUTH: DOCUMENT_ROOT: $document_root");
  $r->log_error("FILEAUTH: uri: $uri - unparsed_uri: $unparsed_uri - filename: $filename - args: $args_txt_print");

  $r->log_error("FILEAUTH: CFG FILE: $CFG_FILE_PATH");

  my ($load_conf_err, $load_conf_msg) = load_config();

  $r->log_error("LOAD CONFIG MSG: $load_conf_msg");

  if ($load_conf_err) {

    die "Cannot load config file: $CFG_FILE_PATH";
  }

  $r->log_error("FILEAUTH: SESSION STORAGE PATH: $SESSION_STORAGE_PATH");

  my $rememberme          = '';
  my $write_token         = '';
  my $group_id            = '';
  my $user_id             = '';
  my $gadmin_status       = '';

  if (length($session_id) > 0) {

    my $session = new CGI::Session("driver:file", $session_id, {Directory=>"$SESSION_STORAGE_PATH"});

    my $username = $session->param('USERNAME');

    if (length($username) > 0) {

      $rememberme          = $session->param('REMEMBER_ME');
      $write_token         = $session->param('WRITE_TOKEN');
      $group_id            = $session->param('GROUP_ID');
      $user_id             = $session->param('USER_ID');
      $gadmin_status       = $session->param('GADMIN_STATUS');

      my $sign_key_cookie_name = 'KDDArT_RANDOM_NUMBER';
      my $sign_key_aref        = read_cookies($cookie, $sign_key_cookie_name);

      foreach my $sign_key (@{$sign_key_aref}) {

        $r->log_error("SIGN KEY: $sign_key");

        my $stored_checksum = $session->param('CHECKSUM');

        my $hash_data = "$username";
        $hash_data   .= "$session_id";
        $hash_data   .= "$rememberme";
        $hash_data   .= "$write_token";
        $hash_data   .= "$group_id";
        $hash_data   .= "$user_id";
        $hash_data   .= "$gadmin_status";

        my $derived_checksum = hmac_sha1_hex($hash_data, $sign_key);

        $r->log_error("FILEAUTH: Stored checksum ($username) : $stored_checksum");
        $r->log_error("FILEAUTH: Derived checksum ($username): $derived_checksum");

        if ($derived_checksum eq $stored_checksum) {

          $user = $username;
          last;
        }
        else {

          $r->log_error("FILEAUTH: CHECKSUM MISMATCHED FOR $sign_key");
        }
      }

      $r->log_error("FILEAUTH: Username: $username");
      $r->log_error("FILEAUTH: SessionId: $session_id");
    }
    else {

      $r->log_error("FILEAUTH: Username not found from Session $session_id");
    }
  }
  else {

    $r->log_error("FILEAUTH: SESSIONID EMPTY");
  }

  $r->log_error("FILEAUTH: user in authen_ses_key: $user");
  $r->log_error("FILEAUTH: " . $self->cookie_name($r));

  $r->log_error("KDDArT BASE DIR:  $main::kddart_base_dir ");
  $r->log_error("FILEAUTH: ------ END CHECKING SESSION AND USER NAME --------");

  if (length($user) > 0) {

    if ($self->check_file_permission($r, $group_id, $gadmin_status)) {

      return $user;
    }
    else {

      return '';
    }
  }
  else {

    return '';
  }
}

sub dwarf {
  my $self = shift;
  my $r = shift;

  my $user = $r->user;
}

sub check_file_permission {

  my $self           = $_[0];
  my $r              = $_[1];
  my $group_id       = $_[2];
  my $gadmin_status  = $_[3];

  my $uri          = $r->uri();
  my $unparsed_uri = $r->unparsed_uri();

  my $args_txt     = $r->args();

  my $multimedia_href = {};

  $multimedia_href->{'genotype'}      = sub { return $self->check_geno_perm($r, @_); };
  $multimedia_href->{'specimen'}      = sub { return $self->check_spec_perm($r, @_); };
  $multimedia_href->{'trial'}         = sub { return $self->check_trial_perm($r, @_); };
  $multimedia_href->{'trialunit'}     = sub { return $self->check_trialunit_perm($r, @_); };
  $multimedia_href->{'site'}          = sub { return 1; };
  $multimedia_href->{'project'}       = sub { return 1; };
  $multimedia_href->{'item'}          = sub { return 1; };
  $multimedia_href->{'extract'}       = sub { return 1; };

  my @splitted_uri = split(/\//, $uri);

  my $nb_dir       = scalar(@splitted_uri);

  if ($nb_dir < 2) {

    return 1;
  }

  my $parent_dir   = $splitted_uri[1];

  if ($parent_dir eq 'data') {

    return 1;
  }
  elsif ($parent_dir eq 'storage') {

    if ($nb_dir < 3) {

      return 0;
    }

    my $document_root = $r->document_root();

    # Need to assign document root because Common.pm included in package
    # results in $ENV{DOCUMENT_ROOT} being empty. $ENV{DOCUMENT_ROOT} is empty
    # because AuthCookieHandler is loaded in the global server space instead of
    # virtual host space; therefore DOCUMENT_ROOT can only be retrieved only
    # from the actual request.

    #$r->log_error("FILEAUTH: DOCUMENT_ROOT: " . $ENV{DOCUMENT_ROOT});

    $ENV{DOCUMENT_ROOT} = $document_root;

    my $storage_type = $splitted_uri[2];

    if ($storage_type eq 'marker_data') {

      if ($nb_dir < 4) {

        return 0;
      }

      my $analgrp_id = $splitted_uri[3];

      my $dbh_m = connect_mdb_read();

      if (!record_existence($dbh_m, 'analysisgroup', 'AnalysisGroupId', $analgrp_id)) {

        $r->log_error("FILEAUTH: AnalysisGroupId ($analgrp_id) not found");

        return 0;
      }

      my ($is_anal_ok, $trouble_anal_id_aref) = check_permission($dbh_m, 'analysisgroup', 'AnalysisGroupId',
                                                                 [$analgrp_id], $group_id, $gadmin_status,
                                                                 $READ_PERM);

      if (!$is_anal_ok) {

        $r->log_error("FILEAUTH: analysisgroup: permission denied");

        return 0;
      }
      else {

        $r->log_error("FILEAUTH: analysisgroup permission is OK");
      }

      $dbh_m->disconnect();

      return 1;
    }
    elsif ($storage_type eq 'multimedia') {

      if ($nb_dir < 5) {

        return 0;
      }

      my $table_name     = $splitted_uri[3];
      my $hash_filename  = $splitted_uri[4];

      if ( !(defined $multimedia_href->{$table_name}) ) {

        $r->log_error("FILEAUTH: No reference how to check if the record exists");
        return 0;
      }

      my $dbh_k = connect_kdb_read();

      my $rec_id = read_cell_value($dbh_k, 'multimedia', 'RecordId', 'HashFileName', $hash_filename);

      $r->log_error("FILEAUTH: Table ($table_name) - RecordId: $rec_id");

      if (length($rec_id) == 0) {

        $r->log_error("FILEAUTH: Table ($table_name) - RecordId: $rec_id not found");
        return 0;
      }

      if ( !($multimedia_href->{$table_name}->($dbh_k, $rec_id, $READ_PERM, $group_id, $gadmin_status)) ) {

        $r->log_error("FILEAUTH: Table ($table_name) - RecordId: $rec_id permission denied");
        return 0;
      }

      my $saveas_orig_name = '';

      if (defined $args_txt) {

        if (length($args_txt) > 0) {

          my @args_pair_list = split(/\&/, $args_txt);
          my $first_arg_pair = $args_pair_list[0];

          my ($arg_name, $arg_val) = split(/=/, $first_arg_pair);

          if (lc($arg_name) eq 'saveas') {

            if ($arg_val eq '1') {

              my $org_name = read_cell_value($dbh_k, 'multimedia', 'OrigFileName', 'HashFileName', $hash_filename);

              if (length($org_name) == 0) {

                $saveas_orig_name = $hash_filename;
              }
              else {

                if (lc($org_name) eq 'uploadfile') {

                  $saveas_orig_name = $hash_filename;
                }
                else {

                  $saveas_orig_name = $org_name;
                }
              }
            }
          }
        }
      }

      $dbh_k->disconnect();

      if (length($saveas_orig_name) > 0) {

        my $headers_out = $r->headers_out();
        $headers_out->set('Content-Description'       => 'File Transfer');
        $headers_out->set('Content-Disposition'       => qq|attachment; filename="$saveas_orig_name"|);
        $headers_out->set('Content-Transfer-Encoding' => 'binary');

        $r->headers_out($headers_out);
      }

      return 1;
    }
    else {

      return 0;
    }
  }
  else {

    return 1;
  }
}

sub check_geno_perm {

  my $self          = $_[0];
  my $r             = $_[1];
  my $dbh           = $_[2];
  my $geno_id       = $_[3];
  my $perm          = $_[4];
  my $group_id      = $_[5];
  my $gadmin_status = $_[6];

  my $perm_str = permission_phrase($group_id, 0, $gadmin_status);

  my ($is_ok, $trouble_geno_id_aref) = check_permission($dbh, 'genotype', 'GenotypeId',
                                                        [$geno_id], $group_id, $gadmin_status,
                                                        $perm);

  if (!$is_ok) {

    my $trouble_geno_id_str = join(',', @{$trouble_geno_id_aref});

    my $perm_err_msg = '';
    $perm_err_msg   .= "Permission denied: Group ($group_id) and Genotype ($trouble_geno_id_str).";
    $r->log_error($perm_err_msg);

    return 0;
  }
  else {

    return 1;
  }
}

sub check_spec_perm {

  my $self          = $_[0];
  my $r             = $_[1];
  my $dbh           = $_[2];
  my $spec_id       = $_[3];
  my $perm          = $_[4];
  my $group_id      = $_[5];
  my $gadmin_status = $_[6];

  my $perm_str      = permission_phrase($group_id, 0, $gadmin_status, 'genotype');

  my $geno_perm_sql = "SELECT DISTINCT genotypespecimen.SpecimenId ";
  $geno_perm_sql   .= "FROM genotypespecimen LEFT JOIN genotype ON genotypespecimen.GenotypeId = genotype.GenotypeId ";
  $geno_perm_sql   .= "WHERE (($perm_str) & $READ_WRITE_PERM) = $READ_WRITE_PERM AND genotypespecimen.SpecimenId = ?";

  my ($r_spec_id_err, $db_spec_id) = read_cell($dbh, $geno_perm_sql, [$spec_id]);

  if ($r_spec_id_err) {

    $r->log_error("Read SpecimenId from database failed");
    return 0;
  }
  else {

    if (length($db_spec_id) == 0) {

      return 0;
    }
    else {

      return 1;
    }
  }
}

sub check_trial_perm {

  my $self          = $_[0];
  my $r             = $_[1];
  my $dbh           = $_[2];
  my $trial_id      = $_[3];
  my $perm          = $_[4];
  my $group_id      = $_[5];
  my $gadmin_status = $_[6];

  #$r->log_error("Testing");

  my $perm_str      = permission_phrase($group_id, 0, $gadmin_status);

  my ($is_ok, $trouble_trial_id_aref) = check_permission($dbh, 'trial', 'TrialId',
                                                         [$trial_id], $group_id, $gadmin_status,
                                                         $perm);

  if (!$is_ok) {

    my $trouble_trial_id_str = join(',', @{$trouble_trial_id_aref});

    my $perm_err_msg = '';
    $perm_err_msg   .= "Permission denied: Group ($group_id) and Trial ($trouble_trial_id_str).";
    $r->log_error($perm_err_msg);

    return 0;
  }
  else {

    return 1;
  }
}

sub check_trialunit_perm {

  my $self          = $_[0];
  my $r             = $_[1];
  my $dbh           = $_[2];
  my $trial_unit_id = $_[3];
  my $perm          = $_[4];
  my $group_id      = $_[5];
  my $gadmin_status = $_[6];

  my $perm_str      = permission_phrase($group_id, 0, $gadmin_status);

  my $trial_id = read_cell_value($dbh, 'trialunit', 'TrialId', 'TrialUnitId', $trial_unit_id);

  my ($is_ok, $trouble_trial_id_aref) = check_permission($dbh, 'trial', 'TrialId',
                                                         [$trial_id], $group_id, $gadmin_status,
                                                         $perm);

  if (!$is_ok) {

    my $trouble_trial_id_str = join(',', @{$trouble_trial_id_aref});

    my $perm_err_msg = '';
    $perm_err_msg   .= "Permission denied: Group ($group_id) and Trial ($trouble_trial_id_str).";
    $r->log_error($perm_err_msg);

    return 0;
  }
  else {

    return 1;
  }
}

1;
