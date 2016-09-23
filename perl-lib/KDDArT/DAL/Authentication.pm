#$Id$
#$Author$

# Copyright (c) 2011, Diversity Arrays Technology, All rights reserved.

# Author    : Puthick Hok
# Created   : 02/06/2010
# Modified  :
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

BEGIN {

  IO::Socket::SSL::set_ctx_defaults(
                                    verify_mode => Net::SSLeay->VERIFY_PEER(),
                                    verifycn_scheme => 'http',
                                    ca_file => Mozilla::CA::SSL_ca_file()
                                   );
}

sub setup {

  my $self = shift;

  CGI::Session->name("KDDArT_DAL_SESSID");

  my $start_time = [gettimeofday()];

  __PACKAGE__->authen->init_config_parameters();
  __PACKAGE__->authen->check_content_type_runmodes(':all');
  __PACKAGE__->authen->check_login_runmodes('switch_to_group',
                                            'switch_extra_data'
                                           );
  __PACKAGE__->authen->check_active_login_runmodes('login');
  __PACKAGE__->authen->count_session_request_runmodes(':all');
  __PACKAGE__->authen->ignore_group_assignment_runmodes('switch_to_group');

  $self->run_modes(
    # DO TO: need to find out why login is not listed.
    'login'                     => 'login_runmode',
    'logout'                    => 'logout_runmode',
    'switch_to_group'           => 'switch_to_group_runmode',
    'get_login_status'          => 'get_login_status_runmode',
    'switch_extra_data'         => 'switch_extra_data_runmode',
    'oauth2_google'             => 'oauth2_google_runmode',
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
          COOKIE_PARAMS       => {
                                   -path      => '/',
                                   -expires   => '+10y',
                                 },
          SEND_COOKIE         => 1,
      );

  my $setup_elapsed = tv_interval($start_time);
  $logger->debug("Setup elapsed time: $setup_elapsed");
}

sub login_runmode {

=pod login_HELP_START
{
"OperationName" : "Login user into a system",
"Description": "Authenticate user in the KDDart system and issues security features allowing user to operate withing the system.",
"AuthRequired": 0,
"GroupRequired": 0,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><WriteToken Value='4f7f9a08a64a7dc85d2d61c8ca79f9871894de1c' /><User UserId='0' /></DATA>",
"SuccessMessageJSON": "{'WriteToken' : [{'Value' : '72511995dab16297994265b627700a82b88c72b0'}],'User' : [{'UserId' : '0'}]}",
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

  my $dbh = connect_kdb_read();
  my $sql;

  $sql  = 'SELECT systemuser.UserPassword, systemuser.UserId ';
  $sql .= 'FROM systemuser ';
  $sql .= 'WHERE systemuser.UserName=?';

  my $sth = $dbh->prepare($sql);
  $sth->execute($username);

  my $err = 0;
  my $err_msg = '';
  my $write_token;
  my $user_id;

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
        my $cookie_only_rand = makerandom(Size => 128, Strength => 0);
        my $f_rand_elapsed = tv_interval($start_time);
        $self->logger->debug("First random number elapsed: $f_rand_elapsed");

        $self->logger->debug("Password in DB: $pass_db");

        my $session_id = $self->session->id();

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
          -value       => "$cookie_only_rand",
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

        $self->header_add(-cookie => [$cookie]);
        $self->session_cookie();

        $self->logger->debug("$username");
        $self->logger->debug("random number: $cookie_only_rand");
        $self->logger->debug("checksum: $session_checksum");
      }
      else {

        my $now = time();

        my $cookie = $q->cookie(
          -name        => 'KDDArT_RANDOM_NUMBER',
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

        $self->header_add(-cookie => [$cookie]);
        $self->session_cookie();

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

  my $data_for_postrun_href = {};

  $data_for_postrun_href->{'Error'}       = 0;

  if ($err) {

    my $err_msg_aref                          = [{'Message' => $err_msg}];
    $data_for_postrun_href->{'Error'}         = 1;
    $data_for_postrun_href->{'HTTPErrorCode'} = 401;
    $data_for_postrun_href->{'Data'}          = {'Error' => $err_msg_aref};
  }
  else { 

    $self->logger->debug("Return WriteToken for Transformation");
    my $write_token_aref = [{'Value' => $write_token}];

    my $user_info_aref   = [{'UserId' => $user_id, 'UserName' => $username}];

    $data_for_postrun_href->{'Data'}      = {'WriteToken' => $write_token_aref,
                                             'User'       => $user_info_aref
    };
    $data_for_postrun_href->{'ExtraData'} = 0;
  }

  return $data_for_postrun_href;
}

sub switch_to_group_runmode {

=pod switch_to_group_HELP_START
{
"OperationName" : "Change group",
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
"OperationName" : "Logout user from a system",
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

  my $user_id = $self->authen->user_id();

  if (length($user_id) > 0) {

    my $dbh_write = connect_kdb_write();
    log_activity($dbh_write, $user_id, 0, 'LOGOUT');
    $dbh_write->disconnect();
  }

  $self->authen->logout();

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
"OperationName" : "Login status",
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
               'GroupAdminStatus'     => "$group_admin_status",
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
"OperationName" : "Switch extradata",
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
"OperationName" : "Login to DAL using Google Auth2",
"Description": "Login to DAL using Google Auth2 from a valid access token.",
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

sub logger {

  my $self = shift;

  return $self->{logger};
}

1;
