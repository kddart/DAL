#$Id$
#$Author$

# Copyright (c) 2025, Diversity Arrays Technology, All rights reserved.

# Author    : Puthick Hok
# Created   : 02/06/2010
# Modified  : 18/01/2024
# Purpose   :
#
#

package KDDArT::DAL::Authentication;

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

use CGI::Application::Plugin::Session;
use Crypt::Random qw( makerandom );
use Digest::HMAC_SHA1 qw(hmac_sha1 hmac_sha1_hex);
use Log::Log4perl qw(get_logger :levels);
use Time::HiRes qw( tv_interval gettimeofday );
use KDDArT::DAL::Security;
use KDDArT::DAL::Common;
use DateTime::Format::MySQL;
use Net::OAuth2::Client;
use Net::OAuth2::AccessToken;
use IO::Socket::SSL;
use Net::SSLeay;
use Mozilla::CA;
use LWP::UserAgent;
use HTTP::Request::Common qw(POST GET);
use JSON qw(decode_json);
use CGI::Session;

use Data::Dumper;
use Crypt::JWT qw(decode_jwt);

BEGIN {

  IO::Socket::SSL::set_ctx_defaults(
                                    verify_mode => Net::SSLeay->VERIFY_PEER(),
                                    verifycn_scheme => 'http',
                                    ca_file => Mozilla::CA::SSL_ca_file()
                                   );
}

sub setup {

  my $self = shift;

  CGI::Session->name($COOKIE_NAME);

  my $start_time = [gettimeofday()];

  __PACKAGE__->authen->init_config_parameters();
  __PACKAGE__->authen->check_content_type_runmodes(':all');
  __PACKAGE__->authen->check_login_runmodes('switch_to_group',
                                            'switch_extra_data',
                                            'clone',
                                           );
  __PACKAGE__->authen->check_active_login_runmodes('login');
  __PACKAGE__->authen->count_session_request_runmodes(':all');
  __PACKAGE__->authen->ignore_group_assignment_runmodes('switch_to_group');

  __PACKAGE__->authen->check_rand_runmodes('login');

  $self->run_modes(
    # DO TO: need to find out why login is not listed.
    'login'                     => 'login_runmode',
    'logout'                    => 'logout_runmode',
    'switch_to_group'           => 'switch_to_group_runmode',
    'get_login_status'          => 'get_login_status_runmode',
    'switch_extra_data'         => 'switch_extra_data_runmode',
    'oauth2_google'             => 'oauth2_google_runmode',
    'clone'                     => 'clone_runmode',
    'execute_reset_password'    => 'execute_reset_password_runmode',
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
  $self->logger->debug("COOKIE NAME: $COOKIE_NAME");

  $self->authen->config(LOGIN_URL => '');
  $self->session_config(
          CGI_SESSION_OPTIONS => [ "driver:File", $self->query,
                                   {
                                    Directory => $SESSION_STORAGE_PATH
                                   }
                                 ],
          SEND_COOKIE         => 0,
      );

  my $setup_elapsed = tv_interval($start_time);
  $logger->debug("Setup elapsed time: $setup_elapsed");
}



sub login_runmode {

=pod login_HELP_START
{
"OperationName": "Login user into a system",
"Description": "Authenticate user in the KDDart system and issues security features allowing user to operate within the system.",
"AuthRequired": 0,
"GroupRequired": 0,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><User UserName='admin' UserId='0' /><StatInfo Unit='second' ServerElapsedTime='0.071' /><RecordMeta TagName='SessionToken' /><WriteToken Value='2bb7602e3b6290ee2403df8c4445e8834b1d4676' /><SessionToken KDDArT_DAL_SESSID='b169d1deecdee4b731e63ac86f539f3a' KDDArT_RANDOM_NUMBER='2731032673' /></DATA>",
"SuccessMessageJSON": "{'WriteToken' : [{'Value' : 'dc9544d610dbb69bb7abc06b9aaed514abfa6789'}], 'SessionToken' : [{'KDDArT_RANDOM_NUMBER' : '3403500693', 'KDDArT_DAL_SESSID' : '27a5c4f66ca68f85fb21fcb54040052e'}], 'StatInfo' : [{'Unit' : 'second', 'ServerElapsedTime' : '0.077'}], 'User' : [{'UserId' : '0', 'UserName' : 'admin'}], 'RecordMeta' : [{'TagName' : 'SessionToken'}]}",
"ErrorMessageXML": [{"IncorrectCredential": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Incorrect username or password.' /></DATA>"}],
"ErrorMessageJSON": [{"IncorrectCredential": "{'Error' : [{'Message' : 'Incorrect username or password.'}]}"}],
"URLParameter": [{"ParameterName": "username", "Description": "Username"}, {"ParameterName": "rememberme", "Description": "A value either yes or no. If the value is yes, the login session will be permanent. If the value is no, the login session will expire due to inactivity."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 401}]
}
=cut


  my $self       = shift;

  my $username   = $self->param('username');
  my $rememberme = uc($self->param('rememberme'));
  my $q          = $self->query();
  my $rand       = $q->param('rand_num');
  my $url        = $q->param('url');
  my $signature  = $q->param('signature');

  $self->logger->debug("Username: $username");
  $self->logger->debug("Random number: $rand");

  my $data_for_postrun_href = {};

  my $write_token_aref    = [];
  my $session_token_aref  = [];
  my $user_info_aref      = [];

  my $domain_name = $COOKIE_DOMAIN->{$ENV{DOCUMENT_ROOT}};

  my $err = 0;
  my $err_msg = '';
  my $write_token;
  my $user_id;
  my $new_db_session_id = '';
  my $sess_id = '';
  my $rand_number = '';


  my $extra_data_status = 0;    # By default, DAL does not return SystemGroup and Operation tags.
                                # However, this can be switched on.

  my $session_id = $self->session->id();
  my $now = time();
  my $cur_dt = DateTime->now( time_zone => $TIMEZONE );
  $cur_dt = DateTime::Format::MySQL->format_datetime($cur_dt);


  if ( lc($AUTHENTICATOR_SOURCE) eq 'openid' ) {

    my $browser = LWP::UserAgent->new();
    my $open_id_param = [];

    push(@{$open_id_param}, 'grant_type' => 'password');
    push(@{$open_id_param}, 'client_id'  => $CLIENTID4OPENID_URL);
    push(@{$open_id_param}, 'username'   => $username);
    push(@{$open_id_param}, 'password'   => "${rand}:::${signature}");

    my $req = POST($OPENID_URL, $open_id_param);
    my $response = $browser->request($req);

    my $result = $response->content();
    $self->logger->debug("signature: $signature - random number: $rand");
    $self->logger->debug("response code: " . $response->code());
    $self->logger->debug("response : " . $result);

    if ( $response->is_success ) {

      my $success_data = undef;

      eval {

        $success_data = decode_json($result);
      };

      if ( ! defined $success_data ) {

        my $err_str = $result;
        $self->logger->debug("OpenId failure error and cannot parse json return: $err_str");
        $err = 1;
        $err_msg = "Unexpected error.";
      }
      else {

        my $access_token = $success_data->{"access_token"};
        my $refresh_token = $success_data->{"refresh_token"};

        my $access_token_json_txt = `jq -R 'split(".") | .[1] | \@base64d | fromjson' <<< \$(echo "$access_token")`;
        $self->logger->debug("access token json: $access_token_json_txt");
        #my ($jwt_access_token_header, $jwt_access_token_data) = decode_jwt(token => $access_token, decode_header => 1, key_from_jwk_header => 1);
        my $jwt_access_token_data = decode_json($access_token_json_txt);

        $new_db_session_id = $jwt_access_token_data->{"ONEDART_SESSION_TOKEN"};
        $write_token = $jwt_access_token_data->{"WRITE_TOKEN"};
        my $ecommerce_base_url = $jwt_access_token_data->{"ECOMMERCEBASEURL"};

        my $session_dbh = connect_session_db();

        my $sql = 'SELECT kddartuserid, kddartgroupid, kddartgroupadminstatus ';
        $sql   .= 'FROM Session WHERE onedartsession=?';

        my ($read_session_err, $read_session_msg, $session_aref) = read_data($session_dbh, $sql, [$new_db_session_id]);

        $session_dbh->disconnect();

        if ( $read_session_err ) {

          my $err_str = $read_session_msg;
          $self->logger->debug("Cannot read onedartsession from session db: $err_str");
          $err = 1;
          $err_msg = "Unexpected error.";
        }
        else {

          my $dbh_write = connect_kdb_write();
          $user_id = $session_aref->[0]->{"kddartuserid"};

          $sql = 'SELECT UserName FROM systemuser WHERE UserId=?';

          my ($kddart_username_err, $kddart_username) = read_cell($dbh_write, $sql, [$user_id]);

          if ( $kddart_username_err ) {

            $self->logger->debug("Cannot read UserName from kddart main database: $sql");
            $err = 1;
            $err_msg = "Unexpected error.";
          }
          else {

            $username = $kddart_username;
            my $group_id = $session_aref->[0]->{"kddartgroupid"};
            my $gadmin_status = $session_aref->[0]->{"kddartgroupadminstatus"};

            $self->authen->store->save( 'SESSION_TOKEN'  => $new_db_session_id,
                                        'USERNAME'       => $username,
                                        'LOGIN_ATTEMPTS' => 0,
                                        'LAST_LOGIN'     => $now,
                                        'LAST_ACCESS'    => $now,
                                        'REMEMBER_ME'    => $rememberme,
                                        'WRITE_TOKEN'    => $write_token,
                                        'GROUP_ID'       => $group_id,
                                        'USER_ID'        => $user_id,
                                        'GADMIN_STATUS'  => $gadmin_status,
                                        'EXTRA_DATA'     => $extra_data_status,
                                        'DELETE_FILE'    => '0'
                                      );

            my $sessid_cookie = $q->cookie(
                                           -name        => "$COOKIE_NAME",
                                           -domain      => $domain_name,
                                           -value       => "$session_id",
                                           -expires     => '+10y',
                                          );

            $sql  = 'UPDATE systemuser SET ';
            $sql .= 'LastLoginDateTime=? ';
            $sql .= 'WHERE UserId=?';

            my $sth = $dbh_write->prepare($sql);
            $sth->execute($cur_dt, $user_id);
            $sth->finish();

            log_activity($dbh_write, $user_id, 0, 'LOGIN');

            $self->header_add(-cookie => [$sessid_cookie]);

            $dbh_write->disconnect();

            $session_token_aref  = [{ "Value"    => "$new_db_session_id",
                                      "AccessToken" => $access_token,
                                      "RefreshToken" => $refresh_token,
                                      "eCommerceBaseUrl" => $ecommerce_base_url
                                    }];
          }
        }
      }

    }
    else {

      my $result_data = undef;

      eval {

        $result_data = decode_json($result);
      };

      if ( ! defined $result_data ) {

        my $err_str = $result;
        $self->logger->debug("OpenId failure error and cannot parse json return: $err_str");
        $err = 1;
        $err_msg = "Unexpected error.";
      }
      else {
        if ( defined $result_data->{'error'} ) {

          $self->logger->debug("OpenID error: $result");
          $err = 1;
          $err_msg = $result_data->{'error_description'};
        }
        else {

          my $err_str = "Very strange openid failed with json text but no error attribute";
          $self->logger->debug("OpenId failure error: $err_str");
          $err = 1;
          $err_msg = "Unexpected error.";
        }
      }
    }
    # Finish OpenID if
  }
  else {
    #standlone login

    $self->logger->debug(Dumper $self->query()->http('Definitely-Real-Header'));

    my $dbh = connect_kdb_read();
    my $sql;

    $sql  = 'SELECT systemuser.UserPassword, systemuser.UserId ';
    $sql .= 'FROM systemuser ';
    $sql .= 'WHERE systemuser.UserName=?';

    my $sth = $dbh->prepare($sql);
    $sth->execute($username);
    my $domain_name = $COOKIE_DOMAIN->{$ENV{DOCUMENT_ROOT}};
    $self->logger->debug("COOKIE DOMAIN: $domain_name");

    if ( !$dbh->err() ) {

      my $pass_db = '';
      my $gadmin_status;
      $sth->bind_col(1, \$pass_db);
      $sth->bind_col(2, \$user_id);

      $sth->fetch();
      $sth->finish();

      if (length($pass_db) > 0) {

        my $session_pass_db = hmac_sha1_hex($rand, $pass_db);
        my $signature_db = hmac_sha1_hex($url, $session_pass_db);

        if ($signature_db eq $signature) {

          my $start_time = [gettimeofday()];
          my $cookie_only_rand = makerandom(Size => 32, Strength => 0);

          $rand_number = $cookie_only_rand;

          my $f_rand_elapsed = tv_interval($start_time);
          $self->logger->debug("First random number elapsed: $f_rand_elapsed");

          $self->logger->debug("Password in DB: $pass_db");

          my $session_id = $self->session->id();

          $sess_id = $session_id;

          my $now = time();

          $start_time = [gettimeofday()];
          my $write_token_rand = makerandom(Size => 128, Strength => 0);
          my $s_rand_elapsed = tv_interval($start_time);
          $self->logger->debug("Second random number elapsed: $s_rand_elapsed");

          $write_token = hmac_sha1_hex("$cookie_only_rand", "$write_token_rand");

          my $group_id          = -99;  # Not set at this stage
          my $gadmin_status     = -99;  # But needs protection from modification from here on
          my $extra_data_status = 0;    # By default, DAL does not return SystemGroup and Operation tags.
                                        # However, this can be switched on.
          my $hash_data = '';
          $hash_data   .= "$username";
          $hash_data   .= "$session_id";
          $hash_data   .= "$rememberme";
          $hash_data   .= "$write_token";
          $hash_data   .= "$group_id";
          $hash_data   .= "$user_id";
          $hash_data   .= "$gadmin_status";

          my $session_checksum = hmac_sha1_hex($hash_data, "$cookie_only_rand");

          $self->authen->store->save( 'USERNAME'       => $username,
                                      'LOGIN_ATTEMPTS' => 0,
                                      'LAST_LOGIN'     => $now,
                                      'LAST_ACCESS'    => $now,
                                      'REMEMBER_ME'    => $rememberme,
                                      'CHECKSUM'       => $session_checksum,
                                      'WRITE_TOKEN'    => $write_token,
                                      'GROUP_ID'       => $group_id,
                                      'USER_ID'        => $user_id,
                                      'GADMIN_STATUS'  => $gadmin_status,
                                      'EXTRA_DATA'     => $extra_data_status,
              );

          my $cookie = $q->cookie(
            -name        => 'KDDArT_RANDOM_NUMBER',
            -domain      => $domain_name,
            -value       => "$cookie_only_rand",
            -expires     => '+10y',
              );

          my $sessid_cookie = $q->cookie(
                                        -name        => 'KDDArT_DAL_SESSID',
                                        -domain      => $domain_name,
                                        -value       => "$session_id",
                                        -expires     => '+10y',
                                        );

          my $dbh_write = connect_kdb_write();

          my $cur_dt = DateTime->now( time_zone => $TIMEZONE );
          $cur_dt = DateTime::Format::MySQL->format_datetime($cur_dt);

          $sql  = 'UPDATE systemuser SET ';
          $sql .= 'LastLoginDateTime=? ';
          $sql .= 'WHERE UserId=?';

          $sth = $dbh_write->prepare($sql);
          $sth->execute($cur_dt, $user_id);
          $sth->finish();

          log_activity($dbh_write, $user_id, 0, 'LOGIN');
          $dbh_write->disconnect();

          $self->header_add(-cookie => [$sessid_cookie, $cookie]);

          $self->logger->debug("$username");
          $self->logger->debug("random number: $cookie_only_rand");
          $self->logger->debug("checksum: $session_checksum");
        }
        else {

          my $now = time();

          my $sessid_cookie = $q->cookie(
                                        -name        => 'KDDArT_DAL_SESSID',
                                        -domain      => $domain_name,
                                        -value       => '',
                                        -expires     => '+10y',
              );

          my $cookie = $q->cookie(
            -name        => 'KDDArT_RANDOM_NUMBER',
            -domain      => $domain_name,
            -value       => '',
            -expires     => '+10y',
              );

          my $login_attemps = $self->authen->store->fetch('LOGIN_ATTEMPTS');
          $login_attemps += 1;

          $self->authen->store->save( 'USERNAME'       => '',
                                      'LOGIN_ATTEMPTS' => $login_attemps,
                                      'LAST_LOGIN'     => $now,
                                      'LAST_ACCESS'    => $now,
                                      'CHECKSUM'       => '',
                                      'GROUP_ID'       => '',
                                      'USER_ID'        => '',
                                      'GADMIN_STATUS'  => '',
                                      'EXTRA_DATA'     => '0',
              );

          $self->header_add(-cookie => [$sessid_cookie, $cookie]);

          $self->logger->debug("Password signature verification failed db: $signature_db, user: $signature");
          $err = 1;
          $err_msg = "Incorrect username or password.";
        }
      }
      else {

        $self->logger->debug("Fail to retrieve password. username and group id not found.");
        $err = 1;
        $err_msg = "Incorrect username or password.";
      }
    }
    else {

      my $err_str = $dbh->errstr();
      $self->logger->debug("SQL Error: $err_str");
      $err = 1;
      $err_msg = "Unexpected error.";
    }

    $dbh->disconnect();

    $data_for_postrun_href->{'Error'}       = 0;

    if ($err) {

      my $err_msg_aref                          = [{'Message' => $err_msg}];
      $data_for_postrun_href->{'Error'}         = 1;
      $data_for_postrun_href->{'HTTPErrorCode'} = 401;
      $data_for_postrun_href->{'Data'}          = {'Error' => $err_msg_aref};
    }
    else {

      $self->logger->debug("Return WriteToken for Transformation");
      my $write_token_aref    = [{'Value' => $write_token}];

      my $session_token_aref  = [{ 'KDDArT_DAL_SESSID'    => "$sess_id",
                                  'KDDArT_RANDOM_NUMBER' => "$rand_number" }];

      my $user_info_aref   = [{'UserId' => $user_id, 'UserName' => $username}];

      $data_for_postrun_href->{'ExtraData'} = 0;
    }



  }

  if ($err == 1) {
        my $err_msg_aref                          = [{'Message' => $err_msg}];
        $data_for_postrun_href->{'Error'}         = 1;
        $data_for_postrun_href->{'HTTPErrorCode'} = 401;
        $data_for_postrun_href->{'Data'}          = {'Error' => $err_msg_aref};
  }
  else {
        $write_token_aref    = [{ 'Value' => $write_token}];
        $user_info_aref      = [{ 'UserId' => $user_id, 'UserName' => $username}];

        $self->logger->debug("Return WriteToken for Transformation");

        $data_for_postrun_href->{'Data'}      = { 'WriteToken'   => $write_token_aref,
                                                'SessionToken' => $session_token_aref,
                                                'User'         => $user_info_aref,
                                                'RecordMeta'   => [{'TagName' => 'SessionToken'}]
                                                };

        $data_for_postrun_href->{'ExtraData'} = 0;
  }

      return $data_for_postrun_href;
}
sub switch_to_group_runmode {

=pod switch_to_group_HELP_START
{
"OperationName": "Change group",
"Description": "Change current group. Each user can be a member of more than one group and data access privileges depend on group membership and admin privileges within a group. This action is always required after user logs into a system.",
"AuthRequired": 1,
"GroupRequired": 0,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info GAdmin='TRUE' GroupName='admin' Message='You have been switched to 0 successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'You have been switched to 0 successfully.','GroupName' : 'admin','GAdmin' : 'TRUE'}]}",
"ErrorMessageXML": [{"InvalidValue": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Invalid group.' /></DATA>"}],
"ErrorMessageJSON": [{"InvalidValue": "{'Error' : [{'Message' : 'Invalid group.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Valid GroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $group_id  = $self->param('id');

  my $user_id = $self->authen->user_id();
  my $dbh = connect_kdb_read();

  my $sql = 'SELECT authorisedsystemgroup.IsGroupOwner, ';
  $sql   .= 'systemgroup.SystemGroupId, ';
  $sql   .= 'systemgroup.SystemGroupName ';
  $sql   .= 'FROM authorisedsystemgroup ';
  $sql   .= 'LEFT JOIN systemgroup ON ';
  $sql   .= 'authorisedsystemgroup.SystemGroupId = systemgroup.SystemGroupId ';
  $sql   .= 'WHERE authorisedsystemgroup.UserId=?';

  my $sth = $dbh->prepare($sql);
  $sth->execute($user_id);

  my $err = 0;
  my $msg = '';

  if ( !$dbh->err() ) {

    my $group_arrayref = $sth->fetchall_arrayref({});

    if ( scalar(@{$group_arrayref}) == 0 ) {

      $self->authen->store->save( 'GROUP_ID'      => '0',
                                  'GADMIN_STATUS' => '0',
                                  'GROUPNAME'     => 'NO_GROUP',
          );
      $self->authen->recalculate_session_checksum();
      $msg = 'FALSE,NO_GROUP';
      $self->logger->debug("User $user_id has no group");
    }
    else {

      my $is_gadmin = -99;
      my $group_name = '';
      my $admin_str = 'FALSE';

      for my $group_record (@{$group_arrayref}) {

        if ($group_record->{'SystemGroupId'} eq "$group_id") {

          $group_name = $group_record->{'SystemGroupName'};
          $is_gadmin  = $group_record->{'IsGroupOwner'};
          last;
        }
      }

      if (length($group_name) == 0) {

        $err = 1;
        $msg = 'Invalid group.';
        $self->logger->debug("User ($user_id), Group ($group_id): not found");
      }
      else {

        $self->logger->debug("IsGadmin: $is_gadmin");

        $self->authen->store->save( 'GROUP_ID'      => $group_id,
                                    'GADMIN_STATUS' => $is_gadmin,
                                    'GROUPNAME'     => $group_name,
            );
        $self->authen->recalculate_session_checksum();

        if ($is_gadmin) {

          $admin_str = 'TRUE';
        }

        $msg = "$admin_str,$group_name";
      }
    }
  }
  else {

    $err = 1;
    $msg = "Unexpected error.";
    my $err_str = $dbh->errstr();

    $self->logger->debug("SQL Error: $err_str");
  }

  $sth->finish();
  $dbh->disconnect();

  my $data_for_postrun_href = {};

  $data_for_postrun_href->{'Error'}       = 0;

  if ($err) {

    my $err_msg_aref                  = [{'Message' => $msg}];
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => $err_msg_aref};
  }
  else {

    my ($gadmin_st_str, $grp_name) = split(/,/, $msg);
    my $msg_aref = [{'GAdmin'    => $gadmin_st_str,
                     'GroupName' => $grp_name,
                     'Message'   => "You have been switched to $group_id successfully.",
                    }];

    $data_for_postrun_href->{'Data'}      = {'Info' => $msg_aref};
    $data_for_postrun_href->{'ExtraData'} = 0;
  }

  return $data_for_postrun_href;
}

sub logout_runmode {

=pod logout_HELP_START
{
"OperationName": "Logout user from a system",
"Description": "Securely logging out of the system and ending the current session.",
"AuthRequired": 0,
"GroupRequired": 0,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='You have logged out successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'You have logged out successfully.'}]}"
}
=cut

  my $self = shift;
  my $q    = $self->query();

  my $user_id = $self->authen->user_id();

  if (length($user_id) > 0) {

    my $dbh_write = connect_kdb_write();
    log_activity($dbh_write, $user_id, 0, 'LOGOUT');
    $dbh_write->disconnect();
  }

  $self->authen->logout();

  my $domain_name = $COOKIE_DOMAIN->{$ENV{DOCUMENT_ROOT}};
  $self->logger->debug("COOKIE DOMAIN: $domain_name");

  my $cookie_name = CGI::Session->name();

  my $cgisession_cookie = $q->cookie(
            -name      => "$cookie_name",
            -domain    => $domain_name,
            -values    => '',
            -expires   => '-1d',
        );

  my $kddart_cookie = $q->cookie(
            -name      => 'KDDArT_RANDOM_NUMBER',
            -domain    => $domain_name,
            -values    => '',
            -expires   => '-1d',
        );

  $self->header_add(-cookie => [$cgisession_cookie, $kddart_cookie]);

  my $msg_aref = [{'Message' => 'You have logged out successfully.'}];

  my $data_for_postrun_href = {};

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub get_login_status_runmode {

=pod get_login_status_HELP_START
{
"OperationName": "Login status",
"Description": "Return information about current login and group status",
"AuthRequired": 0,
"GroupRequired": 0,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info WriteToken='b13d8f18c56ee20df6615753c6348a4b419a5212' GroupSelectionStatus='1' LoginStatus='1' GroupId='0' UserId='0' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'WriteToken' : 'b13d8f18c56ee20df6615753c6348a4b419a5212', 'GroupSelectionStatus' : '1', 'GroupId' : '0', 'LoginStatus' : '1', 'UserId' : '0'}]}"
}
=cut

  my $self = shift;

  my $login_status          = $self->authen->is_authenticated();
  my $group_selected_status = 0;

  my $msg_href           = {};
  my $user_id            = -1;
  my $group_id           = -1;
  my $writetoken         = "";
  my $user_name          = "";
  my $group_name         = "";
  my $group_admin_status = 0;


  if ($login_status) {

    $user_id    = $self->authen->user_id();
    $writetoken = $self->authen->write_token();
    $user_name  = $self->authen->username();

    if ( !($self->authen->is_no_group()) ) {

      $group_selected_status = 1;
      $group_id              = $self->authen->group_id();
      $group_name            = $self->authen->groupname();
      $group_admin_status    = $self->authen->gadmin_status();
    }
  }

  $msg_href = {'LoginStatus'          => "$login_status",
               'GroupSelectionStatus' => "$group_selected_status",
               'UserId'               => "$user_id",
               'GroupId'              => "$group_id",
               'UserName'             => "$user_name",
               'GroupName'            => "$group_name",
               'WriteToken'           => "$writetoken",
               'GroupAdminStatus'     => "$group_admin_status"
              };

  my $msg_aref = [$msg_href];

  my $data_for_postrun_href = {};

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub switch_extra_data_runmode {

=pod switch_extra_data_HELP_START
{
"OperationName": "Switch extradata",
"Description": "Change a mode of the returned output. By switching to extradata ON there will be more information returned in get and list calls. By switching in OFF packets of data can be smaller, but as a trade off some system information will not be present in the output.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Extra data has been switch ON.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Extra data has been switch ON.'}]}",
"ErrorMessageXML": [{"InvalidValue": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Switch value must be either 1 or 0.' /></DATA>"}],
"ErrorMessageJSON": [{"InvalidValue": "{'Error' : [{'Message' : 'Switch value must be either 1 or 0.'}]}"}],
"URLParameter": [{"ParameterName": "switch", "Description": "Value switch indicating the level of extra data wanted. Valid values are 0 (extra data off) and 1 (extra data on)."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self              = shift;
  my $extra_data_switch = $self->param('switch');

  my $data_for_postrun_href = {};

  my $extra_data_status = '';

  if ($extra_data_switch eq '1') {

    $extra_data_status = 'ON';
  }
  elsif ($extra_data_switch eq '0') {

    $extra_data_status = 'OFF';
  }
  else {

    my $err_msg = "Switch value must be either 1 or 0.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $self->authen->store->save( 'EXTRA_DATA' => $extra_data_switch );

  my $extra_data = $self->authen->store->fetch('EXTRA_DATA');

  $self->logger->debug("Extra Data after switching: $extra_data");

  my $msg = "Extra data has been switch ${extra_data_status}.";
  my $info_msg_aref = [{'Message' => $msg}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub oauth2_google_runmode {

=pod oauth2_google_HELP_START
{
"OperationName": "Login to DAL using Google OAuth2",
"Description": "Login to DAL using Google OAuth2 from a valid access token.",
"AuthRequired": 0,
"GroupRequired": 0,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><WriteToken Value='4f7f9a08a64a7dc85d2d61c8ca79f9871894de1c' /><User UserId='0' /></DATA>",
"SuccessMessageJSON": "{'WriteToken' : [{'Value' : '72511995dab16297994265b627700a82b88c72b0'}],'User' : [{'UserId' : '0'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPParameter": [{"Required": 1, "Name": "access_token", "Description": "Valid Google OAuth2 access token"}, {"Required": 1, "Name": "redirect_url", "Description": "Google OAuth2 redirect url. This URL must be registered with Google OAuth2 project."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $access_token_code  = $query->param('access_token');
  my $redirect_uri       = $query->param('redirect_uri');

  my $local_oauth2_client_id     = $OAUTH2_CLIENT_ID->{$ENV{DOCUMENT_ROOT}};
  my $local_oauth2_secret        = $OAUTH2_CLIENT_SECRET->{$ENV{DOCUMENT_ROOT}};
  my $local_oauth2_site          = $OAUTH2_SITE->{$ENV{DOCUMENT_ROOT}};
  my $local_oauth2_auth_path     = $OAUTH2_AUTHORIZE_PATH->{$ENV{DOCUMENT_ROOT}};
  my $local_oauth2_scope         = $OAUTH2_SCOPE->{$ENV{DOCUMENT_ROOT}};
  my $local_oauth2_acc_token_url = $OAUTH2_ACCESS_TOKEN_URL->{$ENV{DOCUMENT_ROOT}};

  my $oauth2_client = Net::OAuth2::Client->new(
          $local_oauth2_client_id,   # client id or Facebook Application ID
          $local_oauth2_secret, # client secret
          site             => $local_oauth2_site,
          authorize_path   => $local_oauth2_auth_path,
          scope            => $local_oauth2_scope,
          access_token_url => $local_oauth2_acc_token_url)->web_server(redirect_uri => $redirect_uri);

  my $access_token = Net::OAuth2::AccessToken->new(client => $oauth2_client, access_token => $access_token_code);

  my $response = $access_token->get('https://www.googleapis.com/oauth2/v2/userinfo');

  if ($response->is_success) {

    my $user_info_href = eval{ decode_json($response->decoded_content); };

    if ($user_info_href) {

      if ($user_info_href->{'email'}) {

        my $user_email  = $user_info_href->{'email'};
        my $first_name  = $user_info_href->{'given_name'};

        my ($username, $domain) = split('@', $user_email);

        my $dbh_write = connect_kdb_write();

        my $user_id = read_cell_value($dbh_write, 'systemuser', 'UserId', 'UserName', $username);

        if (length("$user_id") == 0) {

          my $err_msg = "UserName ($username): unknown.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }

        my $start_time = [gettimeofday()];
        my $cookie_only_rand = makerandom(Size => 128, Strength => 0);
        my $f_rand_elapsed = tv_interval($start_time);
        $self->logger->debug("First random number elapsed: $f_rand_elapsed");

        my $session_id = $self->session->id();

        my $now = time();

        $start_time = [gettimeofday()];
        my $write_token_rand = makerandom(Size => 128, Strength => 0);
        my $s_rand_elapsed = tv_interval($start_time);
        $self->logger->debug("Second random number elapsed: $s_rand_elapsed");

        my $write_token = hmac_sha1_hex("$cookie_only_rand", "$write_token_rand");

        my $group_id          = -99;  # Not set at this stage
        my $gadmin_status     = -99;  # But needs protection from modification from here on
        my $extra_data_status = 0;    # By default, DAL does not return SystemGroup and Operation tags.
                                      # However, this can be switched on.

        my $rememberme = 'no';

        my $hash_data = '';
        $hash_data   .= "$username";
        $hash_data   .= "$session_id";
        $hash_data   .= "$rememberme";
        $hash_data   .= "$write_token";
        $hash_data   .= "$group_id";
        $hash_data   .= "$user_id";
        $hash_data   .= "$gadmin_status";

        my $session_checksum = hmac_sha1_hex($hash_data, "$cookie_only_rand");

        $self->authen->store->save( 'USERNAME'       => $username,
                                    'LOGIN_ATTEMPTS' => 0,
                                    'LAST_LOGIN'     => $now,
                                    'LAST_ACCESS'    => $now,
                                    'REMEMBER_ME'    => $rememberme,
                                    'CHECKSUM'       => $session_checksum,
                                    'WRITE_TOKEN'    => $write_token,
                                    'GROUP_ID'       => $group_id,
                                    'USER_ID'        => $user_id,
                                    'GADMIN_STATUS'  => $gadmin_status,
                                    'EXTRA_DATA'     => $extra_data_status,
            );

        my $cookie = $query->cookie(
          -name        => 'KDDArT_RANDOM_NUMBER',
          -value       => "$cookie_only_rand",
          -expires     => '+10y',
            );

        my $cur_dt = DateTime->now( time_zone => $TIMEZONE );
        $cur_dt = DateTime::Format::MySQL->format_datetime($cur_dt);

        my $sql = 'UPDATE systemuser SET ';
        $sql   .= 'LastLoginDateTime=? ';
        $sql   .= 'WHERE UserId=?';

        my $sth = $dbh_write->prepare($sql);
        $sth->execute($cur_dt, $user_id);
        $sth->finish();

        log_activity($dbh_write, $user_id, 0, 'LOGIN');

        $dbh_write->disconnect();

        $self->header_add(-cookie => [$cookie]);
        $self->session_cookie();

        $self->logger->debug("$username");
        $self->logger->debug("random number: $cookie_only_rand");
        $self->logger->debug("checksum: $session_checksum");

        my $write_token_aref = [{'Value' => $write_token}];

        my $user_info_aref   = [{'UserId' => $user_id, 'UserName' => $username}];

        $data_for_postrun_href->{'Data'}      = {'WriteToken' => $write_token_aref,
                                                 'User'       => $user_info_aref
                                                };
        $data_for_postrun_href->{'ExtraData'} = 0;

        return $data_for_postrun_href;
      }
      else {

        $self->logger->debug("No email in user info");

        my $err_msg = "Unexpected Error.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
    else {

      $self->logger->debug("Cannot decode OAuth2 user info content");

      my $err_msg = "Unexpected Error.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }
  else {

    $self->logger->debug("Cannot get OAuth2 user info content");

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }
}

sub clone_runmode {

=pod clone_HELP_START
{
"OperationName": "Clone session",
"Description": "Clone the current session.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><SessionToken KDDArT_RANDOM_NUMBER='2852333918' KDDArT_DAL_SESSID='6c107b3633dd7410bc67556192de63b9' /><RecordMeta TagName='SessionToken' /><WriteToken Value='6b7d92fe956da32fd581f5a8059f24f18390dcd1' /><StatInfo ServerElapsedTime='0.005' Unit='second' /><User UserId='0' UserName='admin' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'SessionToken'}],'SessionToken' : [{'KDDArT_DAL_SESSID' : '6f0437cebe4e587fd31a8f7bde7ecb02','KDDArT_RANDOM_NUMBER' : '2201862084'}],'WriteToken' : [{'Value' : 'f8e051b695ab4791813cada066b0984cbcd71730'}],'User' : [{'UserId' : '0','UserName' : 'admin'}],'StatInfo' : [{'ServerElapsedTime' : '0.005','Unit' : 'second'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self           = shift;
  my $query          = $self->query;

  my $user_id        = $self->authen->user_id();
  my $group_id       = $self->authen->group_id();
  my $gadmin_status  = $self->authen->gadmin_status();
  my $group_name     = $self->authen->groupname();
  my $username       = $self->authen->username();
  my $extra_data     = $self->authen->is_extra_data();

  my $rememberme     = 'YES';

  my $data_for_postrun_href = {};

  my $new_session = CGI::Session->new("driver:File", '', {Directory => "$SESSION_STORAGE_PATH"});

  my $session_id = $new_session->id();

  my $old_session_id = $self->session->id();

  if ("$session_id" eq "$old_session_id") {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("New session id: $session_id");

  my $start_time = [gettimeofday()];
  my $cookie_only_rand = makerandom(Size => 32, Strength => 0);

  my $rand_number = $cookie_only_rand;

  my $f_rand_elapsed = tv_interval($start_time);
  $self->logger->debug("First random number elapsed: $f_rand_elapsed");

  $start_time = [gettimeofday()];
  my $write_token_rand = makerandom(Size => 128, Strength => 0);
  my $s_rand_elapsed = tv_interval($start_time);
  $self->logger->debug("Second random number elapsed: $s_rand_elapsed");

  my $write_token = hmac_sha1_hex("$cookie_only_rand", "$write_token_rand");

  my $hash_data = '';
  $hash_data   .= "$username";
  $hash_data   .= "$session_id";
  $hash_data   .= "$rememberme";
  $hash_data   .= "$write_token";
  $hash_data   .= "$group_id";
  $hash_data   .= "$user_id";
  $hash_data   .= "$gadmin_status";

  $self->logger->debug("Hash data: $hash_data");

  my $session_checksum = hmac_sha1_hex($hash_data, "$cookie_only_rand");

  $self->logger->debug("New session checksum: $session_checksum");

  my $now = time();

  $new_session->param('USERNAME', $username);
  $new_session->param('LOGIN_ATTEMPTS', 0);
  $new_session->param('LAST_LOGIN', $now);
  $new_session->param('LAST_ACCESS', $now);
  $new_session->param('REMEMBER_ME', $rememberme);
  $new_session->param('CHECKSUM', $session_checksum);
  $new_session->param('WRITE_TOKEN', $write_token);
  $new_session->param('GROUP_ID', $group_id);
  $new_session->param('USER_ID', $user_id);
  $new_session->param('GADMIN_STATUS', $gadmin_status);
  $new_session->param('EXTRA_DATA', $extra_data);
  $new_session->save_param();

  my $write_token_aref    = [{'Value' => $write_token}];

  my $retrieve_write_token = $new_session->param('WRITE_TOKEN');

  $self->logger->debug("Write Token: $retrieve_write_token");

  my $session_token_aref  = [{ 'KDDArT_DAL_SESSID'    => "$session_id",
                               'KDDArT_RANDOM_NUMBER' => "$rand_number" }];

  my $user_info_aref   = [{'UserId' => $user_id, 'UserName' => $username}];

  $data_for_postrun_href->{'Data'}      = { 'WriteToken'   => $write_token_aref,
                                            'SessionToken' => $session_token_aref,
                                            'User'         => $user_info_aref,
                                            'RecordMeta'   => [{'TagName' => 'SessionToken'}]
                                          };

  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub execute_reset_password_runmode {

=pod execute_reset_password_HELP_START
{
"OperationName": "Execute a password reset",
"Description": "Upon validation with reset token, the password is updated to given parameters",
"AuthRequired": 0,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Your password has been changed successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Your password has been changed successfully.' }]}",
"ErrorMessageXML": [{"SystemUserName": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Passwords do not match.' /></DATA>"}],
"ErrorMessageJSON": [{"SystemUserName": "{'Error' : [{'Message' : 'Passwords do not match.'}]}"}],
"URLParameter": [{"ParameterName": "username", "Description": "Username of user having password reset"}],
"HTTPParameter": [{"Required": 1, "Name": "NewUserPassword", "Description": "Hashed (with HMAC SHA1) new password"}, {"Required": 1, "Name": "NewUserPasswordConfirmed", "Description": "Hashed (with HMAC SHA1) new password confirmed"}, {"Required": 1, "Name": "PasswordToken", "Description": "Token for validation"} ],
"HTTPReturnedErrorCode": [{"HTTPCode": 401}]
}
=cut
  my $self  = shift;
  my $query = $self->query();
  my $data_for_postrun_href = {};

  my $cur_dt = DateTime->now( time_zone => $TIMEZONE );
  $cur_dt = DateTime::Format::MySQL->format_datetime($cur_dt);

  my $username_on_request = $self->param('username');

  my $new_pass            = $query->param('NewUserPassword');
  my $new_pass_confirmed  = $query->param('NewUserPasswordConfirmed');
  my $password_reset_token= $query->param('PasswordToken');

  #$self->logger->debug("Param: $username_on_request, $new_pass , $new_pass_confirmed, $password_reset_token");

  my ($missing_err, $missing_href) = check_missing_href( { 'NewUserPassword'     => $new_pass, 'NewUserPasswordConfirmed' => $new_pass_confirmed, 'PasswordToken' => $password_reset_token } );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    $self->logger->debug("Fail because missing fields");

    return $data_for_postrun_href;
  }

  if ($new_pass ne $new_pass_confirmed) {
    my $err_msg = "Passwords do not match.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    $self->logger->debug("Fail because of password mismatch.");

    return $data_for_postrun_href;
  };

  #make sure user exists

  my $dbh_write = connect_kdb_write();

  if (!record_existence($dbh_write, 'systemuser', 'UserName', $username_on_request)) {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    $self->logger->debug("Fail because of database look up failed to return user.");

    return $data_for_postrun_href;
  }

  #check date is still valid and confirm token match
  my $failure_interval_mn = 30;
  my $nb_failure_limit = 5;

  my $dbh = connect_kdb_read();

  my $sql  = 'SELECT systemuser.UserId, systemuser.UserVerificationDT, systemuser.UserName, ';
  $sql .= 'contact.ContactLastName, contact.ContactEMail ';
  $sql .= 'FROM systemuser ';
  $sql .= 'LEFT JOIN contact ON systemuser.ContactId = contact.ContactId ';
  $sql .= 'WHERE systemuser.UserName=? AND systemuser.UserVerification=?';

  $self->logger->debug($sql);

  my ($read_user_err, $read_user_msg, $user_aref) = read_data($dbh, $sql, [$username_on_request,$password_reset_token]);

  $dbh->disconnect();

  if ($read_user_err) {

    $self->logger->debug("Fail because of database lookup with failed UserVerfication");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;

  }

  if (length($user_aref) < 1 || (!defined $user_aref->[0]->{'UserVerificationDT'})) {

    $self->logger->debug("Fail because of database model failure");

    $data_for_postrun_href->{'Error'} = 1;

    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => "Unexpected error."}]};

    return $data_for_postrun_href;

  }

  my $password_request_date   = $user_aref->[0]->{'UserVerificationDT'};

  $self->logger->debug("Date of initial password request: $password_request_date");

  my $req_dt = DateTime::Format::MySQL->parse_datetime($password_request_date);
  my $dur_in_mn = minute_diff($req_dt);


  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'UserDate'      => $password_request_date,
                                           'RecordMeta' => [{'TagName' => 'SystemUser'}],
  };

  # 1 hour token expiry
  if ($dur_in_mn > 60) {

    $self->logger->debug("Fail because of token expiring");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Token Expired'}]};

    return $data_for_postrun_href;

  }

  $sql = 'UPDATE systemuser SET ';
  $sql   .= 'UserPassword=?, UserVerification=? ';
  $sql   .= 'WHERE UserName=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($new_pass, "", $username_on_request);

  if ($dbh_write->err()) {

    $self->logger->debug("Fail resetting user password request information");


    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "Your password has been changed successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;

}

sub logger {

  my $self = shift;

  return $self->{logger};
}

1;
