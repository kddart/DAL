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
use Apache2::Const qw(:common M_GET HTTP_FORBIDDEN HTTP_MOVED_TEMPORARILY HTTP_OK);
use Apache::AuthCookie::Util qw(is_blank);
use Apache2::AuthCookie::Params;
use Apache2::Log;
use Apache2::Access;
use Apache2::Response;
use Apache2::Util;
use APR::Table;

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

sub authenticate {

  my ($auth_type, $r) = @_;

  my $debug = $r->dir_config("AuthCookieDebug") || 0;

  $r->server->log_error("authenticate() entry - Overriding the default authenticate method") if ($debug >= 3);
  $r->server->log_error("auth_type " . $auth_type) if ($debug >= 3);

  my $args_txt     = $r->args();

  my $args_txt_print = '';

  if (defined $args_txt) {

    $args_txt_print = $args_txt;
  }

  $r->log_error("authenticate args: $args_txt_print");

  my $session_id = '';

  if (defined $args_txt) {

    if (length($args_txt) > 0) {

      my @args_pair_list = split(/\&/, $args_txt);

      foreach my $args_pair (@args_pair_list) {

        my ($arg_name, $arg_val) = split(/=/, $args_pair);

        if (uc($arg_name) eq 'KDDART_DAL_SESSID') {

          $session_id = $arg_val;
        }
      }
    }
  }

  $r->log_error("session id: $session_id");

  if (my $prev = ($r->prev || $r->main)) {

    # we are in a subrequest or internal redirect.  Just copy user from the
    # previous or main request if its is present
    if (defined $prev->user) {

      $r->server->log_error('authenticate() is in a subrequest or internal redirect.') if $debug >= 3;
      $r->user( $prev->user );
      return OK;
    }
  }

  if ($debug >= 3) {

    $r->server->log_error("r=$r authtype=". $r->auth_type);
  }

  if ($r->auth_type ne $auth_type) {

    # This location requires authentication because we are being called,
    # but we don't handle this AuthType.
    $r->server->log_error("AuthType mismatch: $auth_type =/= ".$r->auth_type) if $debug >= 3;
    return DECLINED;
  }

  # Ok, the AuthType is $auth_type which we handle, what's the authentication
  # realm's name?
  my $auth_name = $r->auth_name;
  $r->server->log_error("auth_name $auth_name") if $debug >= 2;

  unless ($auth_name) {

    $r->server->log_error("AuthName not set, AuthType=$auth_type", $r->uri);
    return SERVER_ERROR;
  }

  # Get the Cookie header. If there is a session key for this realm, strip
  # off everything but the value of the cookie.

  my $ses_key_cookie = $session_id || $auth_type->key($r);

  $r->server->log_error("ses_key_cookie: $ses_key_cookie");

  $r->server->log_error("ses_key_cookie " . $ses_key_cookie) if $debug >= 1;
  $r->server->log_error("uri " . $r->uri) if $debug >= 2;

  if ($ses_key_cookie) {

    my ($auth_user, @args) = $auth_type->authen_ses_key($r, $ses_key_cookie);

    if (!is_blank($auth_user) and scalar @args == 0) {

      # We have a valid session key, so we return with an OK value.
      # Tell the rest of Apache what the authentication method and
      # user is.

      $r->ap_auth_type($auth_type);
      $r->user($auth_user);
      $r->server->log_error("user authenticated as $auth_user")
        if $debug >= 1;

      return OK;
    }
    elsif (scalar @args > 0 and $auth_type->can('custom_errors')) {

      return $auth_type->custom_errors($r, $auth_user, @args);
    }
    else {

      # There was a session key set, but it's invalid for some reason. So,
      # remove it from the client now so when the credential data is posted
      # we act just like it's a new session starting.

      #$auth_type->remove_cookie($r);
      #$r->subprocess_env('AuthCookieReason', 'bad_cookie');

      $r->server->log_error("Bad session");
    }
  }
  else {

    $r->subprocess_env('AuthCookieReason', 'no_cookie');
  }

  # This request is not authenticated, but tried to get a protected
  # document.  Send client the authen form.
  return $auth_type->login_form($r);
}

sub authen_ses_key ($$$) {

  my ($self, $r, $session_id) = @_;
  my $user = '';

  my $args_txt     = $r->args();

  my $args_txt_print = '';

  if (defined $args_txt) {

    $args_txt_print = $args_txt;
  }

  my $cookie = ($r->headers_in->get("Cookie") || "");

  my $sign_key_cookie_name = 'KDDArT_RANDOM_NUMBER';
  my $sign_key_aref        = read_cookies($cookie, $sign_key_cookie_name);

  if (defined $args_txt) {

    if (length($args_txt) > 0) {

      my @args_pair_list = split(/\&/, $args_txt);

      foreach my $args_pair (@args_pair_list) {

        my ($arg_name, $arg_val) = split(/=/, $args_pair);

        if (uc($arg_name) eq 'KDDART_RANDOM_NUMBER') {

          $sign_key_aref = [$arg_val];
        }
      }
    }
  }

  $r->log_error("FILEAUTH: SessionId: $session_id");
  $r->log_error("FILEAUTH: Cookie: $cookie");

  my $filename     = $r->filename();
  my $uri          = $r->uri();
  my $unparsed_uri = $r->unparsed_uri();

  my $document_root = $r->document_root();

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

          foreach my $args_pair (@args_pair_list) {

            my ($arg_name, $arg_val) = split(/=/, $args_pair);

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
