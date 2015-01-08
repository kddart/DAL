#$Id: System.pm 785 2014-09-02 06:23:12Z puthick $
#$Author: puthick $

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
# Created   : 02/06/2010

package KDDArT::DAL::System;

use strict;
use warnings;

BEGIN {
  use File::Spec;

  my ($volume, $current_dir, $file) = File::Spec->splitpath(__FILE__);

  $main::kddart_base_dir = "${current_dir}../../..";
}

use lib "$main::kddart_base_dir/perl-lib";

use base 'KDDArT::DAL::Transformation';

use CGI::Application::Plugin::Session;
use KDDArT::DAL::Common;
use KDDArT::DAL::Security;
use Log::Log4perl qw(get_logger :levels);
use Digest::HMAC_SHA1 qw(hmac_sha1 hmac_sha1_hex);
use DateTime::Format::MySQL;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use Crypt::Random qw( makerandom );

sub setup {

  my $self = shift;

  CGI::Session->name("KDDArT_DAL_SESSID");

  __PACKAGE__->authen->init_config_parameters();
  __PACKAGE__->authen->check_login_runmodes(':all');
  __PACKAGE__->authen->check_content_type_runmodes(':all');
  __PACKAGE__->authen->count_session_request_runmodes(':all');
  __PACKAGE__->authen->ignore_group_assignment_runmodes('list_group');

  __PACKAGE__->authen->check_rand_runmodes('add_user_gadmin',
                                           'update_user_gadmin',
                                           'add_group_gadmin',
                                           'reset_user_password_gadmin',
                                           'change_user_password',
                                           'remove_group_member_gadmin',
                                           'remove_owner_status_gadmin',
                                           'change_permission',
                                           'change_owner',
                                           'add_barcodeconf_gadmin',
                                           'add_multimedia',
      );
  __PACKAGE__->authen->check_signature_runmodes('add_user_gadmin',
                                                'update_user_gadmin',
                                                'add_group_gadmin',
                                                'reset_user_password_gadmin',
                                                'change_user_password',
                                                'remove_group_member_gadmin',
                                                'remove_owner_status_gadmin',
                                                'change_permission',
                                                'change_owner',
                                                'add_barcodeconf_gadmin',
      );
  __PACKAGE__->authen->check_gadmin_runmodes('add_user_gadmin',
                                             'update_user_gadmin',
                                             'add_group_member_gadmin',
                                             'add_group_gadmin',
                                             'add_group_owner_gadmin',
                                             'reset_user_password_gadmin',
                                             'list_user_gadmin',
                                             'remove_group_member_gadmin',
                                             'remove_owner_status_gadmin',
                                             'get_group_gadmin',
                                             'add_barcodeconf_gadmin',
      );
  __PACKAGE__->authen->check_sign_upload_runmodes('add_multimedia',
      );

  $self->run_modes(
    'add_user_gadmin'              => 'add_user_runmode',
    'update_user_gadmin'           => 'update_user_runmode',
    'list_group'                   => 'list_group_default_runmode',
    'list_all_group'               => 'list_all_group_runmode',
    'list_operation'               => 'list_operation_runmode',
    'get_session_expiry'           => 'get_session_expiry_runmode',
    'add_group_member_gadmin'      => 'add_group_member_runmode',
    'add_group_gadmin'             => 'add_group_runmode',
    'add_group_owner_gadmin'       => 'add_group_owner_runmode',
    'reset_user_password_gadmin'   => 'reset_user_password_runmode',
    'list_user_gadmin'             => 'list_user_runmode',
    'change_user_password'         => 'change_user_password_runmode',
    'remove_group_member_gadmin'   => 'remove_group_member_runmode',
    'remove_owner_status_gadmin'   => 'remove_owner_status_runmode',
    'change_permission'            => 'change_permission_runmode',
    'change_owner'                 => 'change_owner_runmode',
    'get_group_gadmin'             => 'get_group_runmode',
    'get_user'                     => 'get_user_runmode',
    'get_permission'               => 'get_permission_runmode',
    'get_version'                  => 'get_version_runmode',
    'add_barcodeconf_gadmin'       => 'add_barcodeconf_runmode',
    'list_barcodeconf'             => 'list_barcodeconf_runmode',
    'get_barcodeconf'              => 'get_barcodeconf_runmode',
    'add_multimedia'               => 'add_multimedia_runmode',
    'list_multimedia'              => 'list_multimedia_runmode',
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
      );

  my $multimedia_href = {};

  $multimedia_href->{'genotype'}      = { 'ChkRecSql'     => 'SELECT GenotypeId FROM genotype WHERE GenotypeId=?',
                                          'ChkPermFunc'   => sub { return $self->check_geno_perm(@_); }
  };

  $multimedia_href->{'specimen'}      = { 'ChkRecSql'     => 'SELECT SpecimenId FROM specimen WHERE SpecimenId=?',
                                          'ChkPermFunc'   => sub { return $self->check_spec_perm(@_); }
  };

  $multimedia_href->{'site'}          = { 'ChkRecSql'     => 'SELECT SiteId FROM site WHERE SiteId=?'
  };

  $multimedia_href->{'trial'}         = { 'ChkRecSql'     => 'SELECT TrialId FROM trial WHERE TrialId=?',
                                          'ChkPermFunc'   => sub { return $self->check_trial_perm(@_); }
  };

  $multimedia_href->{'project'}       = { 'ChkRecSql'     => 'SELECT ProjectId FROM project WHERE ProjectId=?',
                                          'ChkPermFunc'   => sub { return $self->check_project_perm(@_); }
  };

  $multimedia_href->{'trialunit'}     = { 'ChkRecSql'     => 'SELECT TrialUnitId FROM trialunit WHERE TrialUnitId=?',
                                          'ChkPermFunc'   => sub { return $self->check_trialunit_perm(@_); }
  };

  $multimedia_href->{'item'}          = { 'ChkRecSql'     => 'SELECT ItemId FROM item WHERE ItemId=?',
                                          'ChkPermFunc'   => sub { return $self->check_item_perm(@_); }
  };

  $multimedia_href->{'extract'}       = { 'ChkRecSql'     => 'SELECT ExtractId FROM extract WHERE ExtractId=?',
                                          'ChkPermFunc'   => sub { return $self->check_extract_perm(@_); }
  };

  $self->{'multimedia'} = $multimedia_href;
}

sub add_user_runmode {

=pod add_user_gadmin_HELP_START
{
"OperationName" : "Add user",
"Description": "Add a new system user.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"SkippedField": ["PasswordSalt", "LastLoginDateTime", "UserPreference"],
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "systemuser",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='user1' ParaName='Username' /><Info Message='User (user1) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : 'user2', 'ParaName' : 'Username'}], 'Info' : [{'Message' : 'User (user2) has been added successfully.'}]}",
"ErrorMessageXML": [{"MissingParameter": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error ContactId='ContactId is missing.' /></DATA>"}],
"ErrorMessageJSON": [{"MissingParameter": "{'Error' : [{'ContactId' : 'ContactId is missing.'}]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();
  
  my $data_for_postrun_href = {};

  my $username   = $query->param('UserName');
  my $password   = $query->param('UserPassword');
  my $contact_id = $query->param('ContactId');
  my $usertype   = $query->param('UserType');

  my ($missing_err, $missing_href) = check_missing_href( { 'UserName'      => $username,
                                                           'UserPassword'  => $password,
                                                           'ContactId'     => $contact_id,
                                                           'UserType'      => $usertype,
                                                         } );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  if ($username =~ /\s+/) {

    my $err_msg = "Username cannot contain any space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'UserName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_write = connect_kdb_write();

  my $user_exist = record_existence($dbh_write, 'systemuser', 'UserName', $username);

  if ($user_exist) {

    my $err_msg = "Username ($username) already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'UserName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $contact_exist = record_existence($dbh_write, 'contact', 'ContactId', $contact_id);

  if (!$contact_exist) {

    my $err_msg = "Contact ($contact_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'ContactId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'INSERT INTO systemuser SET ';
  $sql   .= 'UserName=?, ';
  $sql   .= 'UserPassword=?, ';
  $sql   .= "PasswordSalt='', ";
  $sql   .= 'ContactId=?, ';
  $sql   .= "LastLoginDateTime='0000-00-00 00:00:00', ";
  $sql   .= "UserPreference='', ";
  $sql   .= 'UserType=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($username, $password, $contact_id, $usertype);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref  = [{'Message' => "User ($username) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$username", 'ParaName' => 'Username'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref,
                                           'ReturnId'  => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_user_runmode {

=pod update_user_gadmin_HELP_START
{
"OperationName" : "Update user",
"Description": "Update existing system user.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"SkippedField": ["UserName", "PasswordSalt", "LastLoginDateTime", "UserPreference", "UserPassword"],
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "systemuser",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='User (user1) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'User (user1) has been updated successfully.'}]}",
"ErrorMessageXML": [{"MissingParameter": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error ContactId='ContactId is missing.' /></DATA>"}],
"ErrorMessageJSON": [{"MissingParameter": "{'Error' : [{'ContactId' : 'ContactId is missing.'}]}"}],
"URLParameter": [{"ParameterName": "username", "Description": "Existing username"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self     = shift;
  my $username = $self->param('username');
  my $query    = $self->query();

  my $data_for_postrun_href = {};

  my $contact_id = $query->param('ContactId');
  my $usertype   = $query->param('UserType');

  my ($missing_err, $missing_href) = check_missing_href( {
                                                          'ContactId'     => $contact_id,
                                                           'UserType'     => $usertype,
                                                         } );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  my $dbh_write = connect_kdb_write();

  my $user_exist = record_existence($dbh_write, 'systemuser', 'UserName', $username);

  if (!$user_exist) {

    my $err_msg = "Username ($username) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $contact_exist = record_existence($dbh_write, 'contact', 'ContactId', $contact_id);

  if (!$contact_exist) {

    my $err_msg = "Contact ($contact_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'ContactId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'UPDATE systemuser SET ';
  $sql   .= 'ContactId=?, ';
  $sql   .= 'UserType=? ';
  $sql   .= 'WHERE UserName=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($contact_id, $usertype, $username);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "User ($username) has been updated successfully."}];
  
  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_group_default_runmode {

=pod list_group_HELP_START
{
"OperationName" : "List group(s)",
"Description": "Return list of groups, where currently logged in user is the member of.",
"AuthRequired": 1,
"GroupRequired": 0,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='SystemGroup' /><SystemGroup SystemGroupId='0' SystemGroupName='admin' SystemGroupDescription='Admin group' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'SystemGroup'}], 'SystemGroup' : [{'SystemGroupId' : '0', 'SystemGroupName' : 'admin', 'SystemGroupDescription' : 'Admin group'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = shift;

  my $data_for_postrun_href = {};

  my $user_id = $self->authen->user_id();
  my ($err, $msg, $group_data) = $self->authen->list_group($user_id);

  #$self->logger->debug("XML: $xml");

  if ($err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $msg}]};

    return $data_for_postrun_href;
  }
  else {

    $data_for_postrun_href->{'Error'}     = 0;
    $data_for_postrun_href->{'Data'}      = {'SystemGroup' => $group_data,
                                             'RecordMeta'  => [{'TagName' => 'SystemGroup'}],
    };
    $data_for_postrun_href->{'ExtraData'} = 0;

    return $data_for_postrun_href;
  }
}

sub list_all_group_runmode {

=pod list_all_group_HELP_START
{
"OperationName" : "List all groups",
"Description": "Return a list of all user groups defined in the database.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='SystemGroup' /><SystemGroup SystemGroupId='0' SystemGroupName='admin' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'SystemGroup'}], 'SystemGroup' : [{'SystemGroupId' : '0', 'SystemGroupName' : 'admin'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = shift;

  my $data_for_postrun_href = {};

  my ($err, $msg, $group_data) = $self->authen->list_all_group();

  #$self->logger->debug("XML: $xml");

  if ($err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $msg}]};

    return $data_for_postrun_href;
  }
  else {

    $data_for_postrun_href->{'Error'}     = 0;
    $data_for_postrun_href->{'Data'}      = {'SystemGroup' => $group_data,
                                             'RecordMeta'  => [{'TagName' => 'SystemGroup'}],
    };
    $data_for_postrun_href->{'ExtraData'} = 0;

    return $data_for_postrun_href;
  }
}

sub list_operation_runmode {

=pod list_operation_HELP_START
{
"OperationName" : "List operations",
"Description": "Return a list of all available operations in the DAL API.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='Operation' /><Operation REST='switch/group/_id' /><Operation REST='set/group/_id' /><Operation REST='logout' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'Operation'}], 'Operation' : [{'REST' : 'switch/group/_id'},{'REST' : 'set/group/_id'},{'REST' : 'logout'}]}",
"ErrorMessageXML": [{"LoginRequired": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='You need to login first.' /></DATA>"}],
"ErrorMessageJSON": [{"LoginRequired": "{'Error' : [{'Message' : 'You need to login first.'}]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = shift;

  my $data_for_postrun_href = {};

  my $index_script = $CGI_INDEX_SCRIPT;
  my $gadmin_status = $self->authen->gadmin_status();

  my $op_list_data = dispatch_table2arrayref($index_script, $gadmin_status);

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Operation'  => $op_list_data,
                                           'RecordMeta' => [{'TagName' => 'Operation'}],
  };

  return $data_for_postrun_href;
}

sub get_session_expiry_runmode {

=pod get_session_expiry_HELP_START
{
"OperationName" : "Get session expiry",
"Description": "Get information when current DAL session expires.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><SessionExpiry Duration='2700' Unit='Second' /></DATA>",
"SuccessMessageJSON": "{'SessionExpiry' : [{'Unit' : 'Second','Duration' : 2700}]}",
"ErrorMessageXML": [{"LoginRequired": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='You need to login first.' /></DATA>"}],
"ErrorMessageJSON": [{"LoginRequired": "{'Error' : [{'Message' : 'You need to login first.'}]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = shift;

  my $data_for_postrun_href = {};

  my $session_expiry = $self->authen->get_session_expiry();

  my $session_exp_aref = [{'Duration' => $session_expiry, 'Unit' => 'Second'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'SessionExpiry' => $session_exp_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub add_group_member_runmode {

=pod add_group_member_gadmin_HELP_START
{
"OperationName" : "Add group member (Out of date)",
"Description": "Add system user as an ordinary member of the system group. This interface is out of date and it will be redone.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "",
"SuccessMessageJSON": "",
"ErrorMessageXML": [],
"ErrorMessageJSON": [],
"URLParameter": [{"ParameterName": "id", "Description": "GroupId"}, {"ParameterName": "username", "Description": "Username of the user to be added as a member to the group"}, {"ParameterName": "random", "Description": "Random number"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = shift;
  
  return $self->add_group_member(0);
}

sub add_group_owner_runmode {

=pod add_group_owner_gadmin_HELP_START
{
"OperationName" : "Add group owner (Out of date)",
"Description": "Add a system user as an owner (admin) of the system group. This interface is out of date and it will be redone.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "",
"SuccessMessageJSON": "",
"ErrorMessageXML": [],
"ErrorMessageJSON": [],
"URLParameter": [{"ParameterName": "id", "Description": "GroupId"}, {"ParameterName": "username", "Description": "Username of the user to be added as an owner (group admin) to the group"}, {"ParameterName": "random", "Description": "Random number"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = shift;

  return $self->add_group_member(1);
}

sub add_group_member {

  my $self             = $_[0];
  my $is_group_owner   = $_[1];

  my $data_for_postrun_href = {};

  my $joining_group_id = $self->param('id');
  my $username         = $self->param('username');
  my $auth_random      = $self->param('random');

  my $query            = $self->query();
  my $auth_token       = $query->param('UserAuthorisationToken');
  my $submitted_url    = $query->param('url');

  my $running_user_id  = $self->authen->user_id();

  my ($missing_err, $missing_msg) = check_missing_value( { 'UserAuthorisationToken' => $auth_token,
                                                         } );

  if ($missing_err) {

    $missing_msg .= ' missing.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $missing_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_write = connect_kdb_write();

  my $sql = 'SELECT IsGroupOwner ';
  $sql   .= 'FROM authorisedsystemgroup ';
  $sql   .= 'WHERE UserId=? AND SystemGroupId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($running_user_id, $joining_group_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $is_login_group_owner = '';
  $sth->bind_col(1, \$is_login_group_owner);
  $sth->fetch();
  $sth->finish();

  if (length($is_login_group_owner) == 0) {

    my $err_msg = "Group ($joining_group_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }
  else {

    if ($is_login_group_owner == 0) {

      my $err_msg = "Login ($username) is not a group owner of group ($joining_group_id).";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $user_hash_pass = read_cell_value($dbh_write, 'systemuser', 'UserPassword', 'UserName', $username);

  if (length($user_hash_pass) == 0) {

    my $err_msg = "User ($username) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $recalc_user_auth_token = hmac_sha1_hex($submitted_url, $user_hash_pass);

  if ($auth_token ne $recalc_user_auth_token) {

    my $err_msg = "Failed user authorisation.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $user_id_on_request = read_cell_value($dbh_write, 'systemuser', 'UserId', 'UserName', $username);

  $sql  = 'SELECT AuthorisedSystemGroupId, IsGroupOwner FROM authorisedsystemgroup ';
  $sql .= 'WHERE UserId=? AND SystemGroupId=?';

  $sth = $dbh_write->prepare($sql);
  $sth->execute($user_id_on_request, $joining_group_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $authorised_system_group_id = -1;
  my $is_grp_owner               = 0;
  $sth->bind_col(1, \$authorised_system_group_id);
  $sth->bind_col(2, \$is_grp_owner);
  $sth->fetch();
  $sth->finish();

  my $return_msg = '';

  if ($authorised_system_group_id != -1) {

    if ($is_group_owner == 0) {

      my $err_msg = "User ($username) is already a member of group ($joining_group_id).";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    else {

      if ($is_grp_owner == 1) {

        my $err_msg = "User ($username) is already an owner of group ($joining_group_id).";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
      else {

        $sql  = 'UPDATE authorisedsystemgroup SET ';
        $sql .= 'IsGroupOwner=1 ';
        $sql .= 'WHERE AuthorisedSystemGroupId=?';

        $sth = $dbh_write->prepare($sql);
        $sth->execute($authorised_system_group_id);

        if ($dbh_write->err()) {

          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

          return $data_for_postrun_href;
        }

        $sth->finish();

        $return_msg = "User ($username) now becomes an owner of group ($joining_group_id).";
      }
    }
  }
  else {

    $sql  = 'INSERT INTO authorisedsystemgroup SET ';
    $sql .= 'UserId=?, ';
    $sql .= 'SystemGroupId=?, ';
    $sql .= 'IsGroupOwner=?';

    $sth = $dbh_write->prepare($sql);
    $sth->execute($user_id_on_request, $joining_group_id, $is_group_owner);

    if ($dbh_write->err()) {

      return $self->error_message('Unexpected error.');
    }

    $sth->finish();

    if ($is_group_owner == 0) {

      $return_msg = "User ($username) is now a member of group ($joining_group_id).";
    }
    else {

      $return_msg = "User ($username) is now an owner of group ($joining_group_id).";
    }
  }

  $dbh_write->disconnect();
  
  my $info_msg_aref = [{'Message' => $return_msg}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub add_group_runmode {

=pod add_group_gadmin_HELP_START
{
"OperationName" : "Add group",
"Description": "Create a new system group in the database.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "systemgroup",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='1' ParaName='GroupId' /><Info GroupId='1' Message='Group (group1) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '2', 'ParaName' : 'GroupId'}], 'Info' : [{'GroupId' : '2', 'Message' : 'Group (group2) has been added successfully.'}]}",
"ErrorMessageXML": [{"NameAlreadyExists": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Group (group2) already exists.' /></DATA>"}],
"ErrorMessageJSON": [{"NameAlreadyExists": "{'Error' : [{'Message' : 'Group (group2) already exists.'}]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $group_name        = $query->param('SystemGroupName');

  my ($missing_err, $missing_msg) = check_missing_value( { 'SystemGroupName'      => $group_name } );

  if ($missing_err) {

    $missing_msg .= ' missing.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $missing_msg}]};

    return $data_for_postrun_href;
  }

  if ($group_name =~ /\s+/) {

    my $err_msg = "Group name cannot contain any space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_description = '';

  if ( $query->param('SystemGroupDescription') ) {

    $group_description = $query->param('SystemGroupDescription');
  }

  my $dbh_write = connect_kdb_write();

  my $group_exist = record_existence($dbh_write, 'systemgroup', 'SystemGroupName', $group_name);

  if ($group_exist) {

    my $err_msg = "Group ($group_name) already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'INSERT INTO systemgroup SET ';
  $sql   .= 'SystemGroupName=?, ';
  $sql   .= 'SystemGroupDescription=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($group_name, $group_description);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $group_id = $dbh_write->last_insert_id(undef, undef, 'systemgroup', 'SystemGroupId');

  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref  = [{'Message' => "Group ($group_name) has been added successfully.", 'GroupId' => $group_id}];
  my $return_id_aref = [{'Value' => "$group_id", 'ParaName' => 'GroupId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub reset_user_password_runmode {

=pod reset_user_password_gadmin_HELP_START
{
"OperationName" : "Reset password",
"Description": "Reset current password into something new for the user. This functionality is only available for global administrator.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AdministratorRequired": 1,
"SkippedField": ["PasswordSalt", "LastLoginDateTime", "UserPreference", "UserName", "ContactId", "UserType"],
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "systemuser",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Password for user1 has been reset successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Password for user1 has been reset successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='user3 not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'user3 not found.'}]}"}],
"URLParameter": [{"ParameterName": "username", "Description": "Existing username"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self     = shift;
  my $username = $self->param('username');

  my $data_for_postrun_href = {};

  my $query    = $self->query();
  my $pass     = $query->param('UserPassword');

  my ($missing_err, $missing_msg) = check_missing_value( { 'UserPassword' => $pass } );

  if ($missing_err) {

    $missing_msg .= ' missing.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $missing_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_write = connect_kdb_write();

  my $user_id_on_request = read_cell_value($dbh_write, 'systemuser', 'UserId', 'UserName', $username);

  if (length($user_id_on_request) == 0) {

    my $err_msg = "$username not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();

  if ($group_id != 0) {

    my $err_msg = 'Permission denied.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql  = 'UPDATE systemuser SET ';
  $sql    .= 'UserPassword=? ';
  $sql    .= 'WHERE UserId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($pass, $user_id_on_request);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "Password for $username has been reset successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_user {

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

  my $extra_attr_user_data = [];

  if ($extra_attr_yes) {

    my $contact_id_aref = [];

    for my $row (@{$data_aref}) {

      push(@{$contact_id_aref}, $row->{'ContactId'});
    }

    my $contact_lookup = {};

    if (scalar(@{$contact_id_aref}) > 0) {

      my $contact_sql    = "SELECT ContactId, ";
      $contact_sql      .= "CONCAT(ContactFirstName, ' ', ContactLastName) AS ContactName ";
      $contact_sql      .= "FROM contact WHERE ContactId IN (" . join(',', @{$contact_id_aref}) . ")";

      $contact_lookup = $dbh->selectall_hashref($contact_sql, 'ContactId');
    }

    for my $row (@{$data_aref}) {

      my $username     = $row->{'UserName'};
      my $contact_id   = $row->{'ContactId'};

      $row->{'ContactName'}  = $contact_lookup->{$contact_id}->{'ContactName'};
      $row->{'resetpass'}    = "user/$username/reset/password";

      push(@{$extra_attr_user_data}, $row);
    }
  }
  else {

    $extra_attr_user_data = $data_aref;
  }
    
  $dbh->disconnect();

  return ($err, $msg, $extra_attr_user_data);
}

sub list_user_runmode {

=pod list_user_gadmin_HELP_START
{
"OperationName" : "List users in the current group",
"Description": "Return list of system users currently present in the group of the login session.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='User' /><User UserName='admin' resetpass='user/admin/reset/password' ContactId='1' ContactName='Diversity Arrays' UserType='human' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'User'}], 'User' : [{'UserName' : 'admin', 'resetpass' : 'user/admin/reset/password', 'ContactId' : '1', 'ContactName' : 'Diversity Arrays', 'UserType' : 'human'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = shift;

  my $data_for_postrun_href = {};

  my $group_id = $self->authen->group_id();
  my $user_id  = $self->authen->user_id();

  my $sql = 'SELECT UserName, ContactId, UserType ';
  $sql   .= 'FROM systemuser LEFT JOIN authorisedsystemgroup ';
  $sql   .= 'ON systemuser.UserId = authorisedsystemgroup.UserId ';
  $sql   .= 'WHERE authorisedsystemgroup.SystemGroupId=?';

  my ($read_user_err, $read_user_msg, $user_data) = $self->list_user(1, $sql, [$group_id]);

  if ($read_user_err) {

    $self->logger->debug($read_user_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'User'       => $user_data,
                                           'RecordMeta' => [{'TagName' => 'User'}],
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub change_user_password_runmode {

=pod change_user_password_HELP_START
{
"OperationName" : "Change password",
"Description": "Change current password into something new. Each user can change only his/her own password.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Your password has been changed successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Your password has been changed successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Incorrect username or password.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Incorrect username or password.'}]}"}],
"HTTPParameter": [{"Name": "CurrentUserPassword", "DataType": "varchar", "Required": "1", "ColSize": "128"}, {"Name": "NewUserPassword", "DataType": "varchar", "Required": "1", "ColSize": "128"}],
"URLParameter": [{"ParameterName": "username", "Description": "Existing username"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self                = shift;
  my $username_on_request = $self->param('username');
  my $query               = $self->query();
  my $current_pass        = $query->param('CurrentUserPassword');
  my $new_pass            = $query->param('NewUserPassword');

  my $data_for_postrun_href = {};

  my ($missing_err, $missing_href) = check_missing_href( { 'CurrentUserPassword' => $current_pass,
                                                           'NewUserPassword'     => $new_pass,
                                                         } );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  my $username = $self->authen->username();

  if ($username_on_request ne $username) {

    my $err_msg = 'Incorrect username or password.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_write = connect_kdb_write();

  my $db_hash_pass = read_cell_value($dbh_write, 'systemuser', 'UserPassword', 'UserName', $username);

  if ($current_pass ne $db_hash_pass) {

    my $err_msg = 'Incorrect username or password.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'UPDATE systemuser SET ';
  $sql   .= 'UserPassword=? ';
  $sql   .= 'WHERE UserName=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($new_pass, $username);

  if ($dbh_write->err()) {

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

sub remove_group_member_runmode {

=pod remove_group_member_gadmin_HELP_START
{
"OperationName" : "Remove user from a group",
"Description": "Remove user from a group. User is no longer a member of this group at all.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='user1 has been removed from group (0) successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'user2 has been removed from group (0) successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='user1 not a member of group (0).' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'user1 not a member of group (0).'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "GroupId to whom the username belongs"}, {"ParameterName": "username", "Description": "Username who is a member of the group"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self                = shift;
  my $group_id_on_request = $self->param('id');
  my $username_on_request = $self->param('username');

  my $data_for_postrun_href = {};

  my $group_id = $self->authen->group_id();

  if ($group_id_on_request != $group_id) {

    my $err_msg = 'Login group and requested group not matched.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_write = connect_kdb_write();

  my $user_id_on_request = read_cell_value($dbh_write, 'systemuser', 'UserId', 'UserName', $username_on_request);

  if (length($user_id_on_request) == 0) {

    my $err_msg = "$username_on_request not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT AuthorisedSystemGroupId ';
  $sql   .= 'FROM authorisedsystemgroup ';
  $sql   .= 'WHERE UserId=? AND SystemGroupId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($user_id_on_request, $group_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $authorised_sys_grp_id = -1;
  $sth->bind_col(1, \$authorised_sys_grp_id);
  $sth->fetch();
  $sth->finish();

  if ($authorised_sys_grp_id == -1) {

    my $err_msg = "$username_on_request not a member of group ($group_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql  = 'DELETE FROM authorisedsystemgroup ';
  $sql .= 'WHERE AuthorisedSystemGroupId=?';

  $sth = $dbh_write->prepare($sql);
  $sth->execute($authorised_sys_grp_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "$username_on_request has been removed from group ($group_id) successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub remove_owner_status_runmode {

=pod remove_owner_status_gadmin_HELP_START
{
"OperationName" : "Remove owner status",
"Description": "Remove ownership status from a user. User is no longer owner (admin) of the group. Group have to retain at least one owner, who can manage the group.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='user2 no longer an owner of group (0).' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'user2 no longer an owner of group (0).'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='user1 not a member of group (0).' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'user1 not a member of group (0).'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "GroupId whom the username is a group owner/admin."}, {"ParameterName": "username", "Description": "Username who is a member of the group"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self                = shift;
  my $group_id_on_request = $self->param('id');
  my $username_on_request = $self->param('username');

  my $data_for_postrun_href = {};

  my $group_id = $self->authen->group_id();

  if ($group_id_on_request != $group_id) {

    my $err_msg = 'Login group and requested group not matched.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_write = connect_kdb_write();

  my $user_id_on_request = read_cell_value($dbh_write, 'systemuser', 'UserId', 'UserName', $username_on_request);

  if (length($user_id_on_request) == 0) {

    my $err_msg = "$username_on_request not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT AuthorisedSystemGroupId, IsGroupOwner ';
  $sql   .= 'FROM authorisedsystemgroup ';
  $sql   .= 'WHERE UserId=? AND SystemGroupId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($user_id_on_request, $group_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $authorised_sys_grp_id = -1;
  my $is_group_owner        = 0;
  $sth->bind_col(1, \$authorised_sys_grp_id);
  $sth->bind_col(2, \$is_group_owner);
  $sth->fetch();
  $sth->finish();

  if ($authorised_sys_grp_id == -1) {

    my $err_msg = "$username_on_request not a member of group ($group_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ($is_group_owner == 0) {

    my $err_msg = "$username_on_request not an owner of group ($group_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql  = 'UPDATE authorisedsystemgroup SET ';
  $sql .= 'IsGroupOwner=0 ';
  $sql .= 'WHERE AuthorisedSystemGroupId=?';
  
  $sth = $dbh_write->prepare($sql);
  $sth->execute($authorised_sys_grp_id);
  
  if ($dbh_write->err()) {
    
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "$username_on_request no longer an owner of group ($group_id)."}];
  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub change_permission_runmode {

=pod change_permission_HELP_START
{
"OperationName" : "Change record permission",
"Description": "Change permission to the record id for the table. User doing the change needs to have appropriate permission to the record to make such a change. The HTTP parameters here are the new permission values.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Permission at record (1) in genotype has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Permission at record (1) in genotype has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Record (872612) not found in table (genotype).' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Record (872612) not found in table (genotype).'}]}"}],
"HTTPParameter": [{"Name": "OwnGroupPerm", "DataType": "tinyint", "Required": "1", "ColSize": "4"}, {"Name": "AccessGroupPerm", "DataType": "tinyint", "Required": "1", "ColSize": "4"}, {"Name": "OtherPerm", "DataType": "tinyint", "Required": "1", "ColSize": "4"}],
"URLParameter": [{"ParameterName": "tname", "Description": "Name of a table to which the record belongs"}, {"ParameterName": "recordid", "Description": "Id of the record whose permission needs to be changed. This Id is dependent on the table. For example, for genotype, this Id would be GenotypeId while for trial, this Id would be TrialId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self        = shift;
  my $table_name  = $self->param('tname');
  my $record_id   = $self->param('recordid');

  my $data_for_postrun_href = {};

  my $query       = $self->query();
  my $own_perm    = $query->param('OwnGroupPerm');
  my $access_perm = $query->param('AccessGroupPerm');
  my $other_perm  = $query->param('OtherPerm');

  my ($missing_err, $missing_href) = check_missing_href( {'OwnGroupPerm'    => $own_perm,
                                                          'AccessGroupPerm' => $access_perm,
                                                          'OtherPerm'       => $other_perm,
                                                         } );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  my ($perm_err, $perm_href) = check_perm_href( {'OwnGroupPerm'    => $own_perm,
                                                 'AccessGroupPerm' => $access_perm,
                                                 'OtherPerm'       => $other_perm,
                                                } );

  if ($perm_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$perm_href]};

    return $data_for_postrun_href;
  }

  my $tablename2idfield = { 'genotype'        => 'GenotypeId',
                            'trial'           => 'TrialId',
                            'trait'           => 'TraitId',
                            'trialanalysis'   => 'TrialAnalysisId',
                            'analysisgroup'   => 'AnalysisGroupId',
                            'layer'           => 'id',
  };

  my $dbh_kdb_write = connect_kdb_write();
  my $dbh_gis_write = connect_gis_write();
  my $dbh_mdb_write = connect_mdb_write();

  my $dbh = $dbh_kdb_write;

  my $id_field = '';
 
  if (defined $tablename2idfield->{$table_name}) {

    $id_field = $tablename2idfield->{$table_name};
  }

  my $perm_fields = ['OwnGroupId', 'AccessGroupId', 'OwnGroupPerm', 'AccessGroupPerm', 'OtherPerm'];

  my $table_exists_kdb = table_existence($dbh_kdb_write, $table_name);
  
  if ($table_exists_kdb == 0) {

    my $table_exists_gis = table_existence($dbh_gis_write, $table_name);

    if ($table_exists_gis) {

      $dbh = $dbh_gis_write;
      $id_field = 'id';
      $perm_fields = ['owngroupid', 'accessgroupid', 'owngroupperm', 'accessgroupperm', 'otherperm'];
    }
    else {

      my $table_exists_mdb = table_existence($dbh_mdb_write, $table_name);

      if ($table_exists_mdb) {

        $dbh = $dbh_mdb_write;
      }
      else {

        my $err_msg = "$table_name not found.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
  }

  my $is_table_with_perm = 1;

  for my $field (@{$perm_fields}) {

    my $field_exists = field_existence($dbh, $table_name, $field);

    if ($field_exists == 0) {

      $is_table_with_perm = 0;
    }
  }

  if ($is_table_with_perm == 0) {

    my $err_msg = 'Permission not applicable.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($id_field) == 0) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();

  my $rec_group_owner_id = read_cell_value($dbh, $table_name, $perm_fields->[0], $id_field, $record_id);

  if (length($rec_group_owner_id) == 0) {

    my $err_msg = "Record ($record_id) not found in table ($table_name).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }
  elsif ($rec_group_owner_id != $group_id) {

    my $err_msg = 'Permission denied.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = "UPDATE $table_name SET ";
  $sql   .= $perm_fields->[2] . '=?, ';
  $sql   .= $perm_fields->[3] . '=?, ';
  $sql   .= $perm_fields->[4] . '=? ';
  $sql   .= "WHERE ${id_field}=?";

  my $sth = $dbh->prepare($sql);
  $sth->execute($own_perm, $access_perm, $other_perm, $record_id);

  if ($dbh->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_mdb_write->disconnect();
  $dbh_kdb_write->disconnect();
  $dbh_gis_write->disconnect();

  my $msg = "Permission at record ($record_id) in $table_name has been updated successfully.";
  my $info_msg_aref = [{'Message' => $msg}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub change_owner_runmode {

=pod change_owner_HELP_START
{
"OperationName" : "Change owner",
"Description": "Change the ownership of the record in the table. User doing the change needs to have appropriate permission to the record to make such a change. The HTTP parameters here are the new owner and access group IDs.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Group ownership at record (1) in genotype has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Group ownership at record (2) in genotype has been updated successfully.'}]}",
"ErrorMessageXML": [{"PermissionDenied": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Permission denied.' /></DATA>"}],
"ErrorMessageJSON": [{"PermissionDenied": "{'Error' : [{'Message' : 'Permission denied.'}]}"}],
"HTTPParameter": [{"Name": "OwnGroupPerm", "DataType": "tinyint", "Required": "1", "ColSize": "4"}, {"Name": "AccessGroupPerm", "DataType": "tinyint", "Required": "1", "ColSize": "4"}, {"Name": "OtherPerm", "DataType": "tinyint", "Required": "1", "ColSize": "4"}],
"URLParameter": [{"ParameterName": "tname", "Description": "Name of a table to which the record belongs"}, {"ParameterName": "recordid", "Description": "Id of the record whose permission needs to be changed. This Id is dependent on the table. For example, for genotype, this Id would be GenotypeId while for trial, this Id would be TrialId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self        = shift;
  my $table_name  = $self->param('tname');
  my $record_id   = $self->param('recordid');

  my $data_for_postrun_href = {};

  my $query        = $self->query();
  my $own_group    = $query->param('OwnGroupId');
  my $access_group = $query->param('AccessGroupId');
  my $other_perm   = $query->param('OtherPerm');

  my ($missing_err, $missing_href) = check_missing_href( {'OwnGroupId'    => $own_group,
                                                          'AccessGroupId' => $access_group,
                                                         } );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  my ($int_err, $int_href) = check_integer_href( {'OwnGroupId'    => $own_group,
                                                  'AccessGroupId' => $access_group,
                                                 } );

  if ($int_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$int_href]};

    return $data_for_postrun_href;
  }

  my $tablename2idfield = { 'genotype'        => 'GenotypeId',
                            'multienvtrial'   => 'METId',
                            'trial'           => 'TrialId',
                            'trait'           => 'TraitId',
                            'trialanalysis'   => 'TrialAnalysisId',
                            'analysisgroup'   => 'AnalysisGroupId',
  };

  my $dbh_kdb_write = connect_kdb_write();
  my $dbh_gis_write = connect_gis_write();
  my $dbh_mdb_write = connect_mdb_write();

  my $dbh = $dbh_kdb_write;

  if (!record_existence($dbh, 'systemgroup', 'SystemGroupId', $own_group)) {

    my $err_msg = "OwnGroupId ($own_group): not found";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'OwnGroupId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (!record_existence($dbh, 'systemgroup', 'SystemGroupId', $access_group)) {

    my $err_msg = "AccessGroupId ($access_group): not found";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'AccessGroupId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $id_field = '';

  if (defined $tablename2idfield->{$table_name}) {

    $id_field = $tablename2idfield->{$table_name};
  }

  my $perm_fields = ['OwnGroupId', 'AccessGroupId', 'OwnGroupPerm', 'AccessGroupPerm', 'OtherPerm'];

  my $table_exists_kdb = table_existence($dbh_kdb_write, $table_name);
  
  if ($table_exists_kdb == 0) {

    my $table_exists_gis = table_existence($dbh_gis_write, $table_name);

    if ($table_exists_gis) {

      $dbh = $dbh_gis_write;
      $id_field = 'id';
      $perm_fields = ['owngroupid', 'accessgroupid', 'owngroupperm', 'accessgroupperm', 'otherperm'];
    }
    else {

      my $table_exists_mdb = table_existence($dbh_mdb_write, $table_name);

      if ($table_exists_mdb) {

        $dbh = $dbh_mdb_write;
      }
      else {

        my $err_msg = "$table_name not found.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
  }
 
  my $is_table_with_perm = 1;

  for my $field (@{$perm_fields}) {

    my $field_exists = field_existence($dbh, $table_name, $field);
    
    if ($field_exists == 0) {

      $is_table_with_perm = 0;
    }
  }

  if ($is_table_with_perm == 0) {

    my $err_msg = 'Permission not applicable.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($id_field) == 0) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();

  my $rec_group_owner_id = read_cell_value($dbh, $table_name, $perm_fields->[0], $id_field, $record_id);

  if (length($rec_group_owner_id) == 0) {

    my $err_msg = "Record ($record_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }
  elsif ($rec_group_owner_id != $group_id) {

    my $err_msg = 'Permission denied.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $gadmin_status = $self->authen->gadmin_status();

  if ($gadmin_status ne '1' && $rec_group_owner_id != $own_group) {

    my $err_msg = 'Permission denied.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = "UPDATE $table_name SET ";
  $sql   .= $perm_fields->[0] . '=?, ';
  $sql   .= $perm_fields->[1] . '=? ';
  $sql   .= "WHERE ${id_field}=?";

  my $sth = $dbh->prepare($sql);
  $sth->execute($own_group, $access_group, $record_id);

  if ($dbh->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_mdb_write->disconnect();
  $dbh_kdb_write->disconnect();
  $dbh_gis_write->disconnect();

  my $msg = "Group ownership at record ($record_id) in $table_name has been updated successfully.";
  my $info_msg_aref = [{'Message' => $msg}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub get_permission_runmode {

=pod get_permission_HELP_START
{
"OperationName" : "Get permission",
"Description": "Return detailed information about permission in the table for a specified record id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='Permission' /><Permission OwnGroupPermission='Read/Write/Link' AccessGroupPerm='5' AccessGroupId='2' OwnGroupName='group1' AccessGroupName='group2' AccessGroupPermission='Read/Link' OtherPermission='Read/Link' OwnGroupPerm='7' OtherPerm='5' UltimatePermission='Read/Write/Link' OwnGroupId='1' UltimatePerm='7' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'Permission'}],'Permission' : [{'OwnGroupPermission' : 'Read/Write/Link','AccessGroupPerm' : '5','OwnGroupName' : 'group1','AccessGroupId' : '2','OtherPermission' : 'Read/Link','AccessGroupPermission' : 'Read/Link','AccessGroupName' : 'group2','OtherPerm' : '5','OwnGroupPerm' : '7','UltimatePermission' : 'Read/Write/Link','OwnGroupId' : '1','UltimatePerm' : '7'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Record (82726) not found in table (genotype).' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Record (82726) not found in table (genotype).'}]}"}],
"URLParameter": [{"ParameterName": "tname", "Description": "Name of a table to which the record belongs"}, {"ParameterName": "recordid", "Description": "Id of the record whose permission needs to be changed. This Id is dependent on the table. For example, for genotype, this Id would be GenotypeId while for trial, this Id would be TrialId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self        = shift;
  my $table_name  = $self->param('tname');
  my $record_id   = $self->param('recordid');

  my $data_for_postrun_href = {};

  my $tablename2idfield = { 'genotype'        => 'GenotypeId',
                            'multienvtrial'   => 'METId',
                            'trial'           => 'TrialId',
                            'trait'           => 'TraitId',
                            'trialanalysis'   => 'TrialAnalysisId',
                            'analysisgroup'   => 'AnalysisGroupId',
  };

  my $dbh_kdb = connect_kdb_read();
  my $dbh_gis = connect_gis_read();
  my $dbh_mdb = connect_mdb_read();

  my $dbh = $dbh_kdb;

  my $id_field = '';
 
  if (defined $tablename2idfield->{$table_name}) {

    $id_field = $tablename2idfield->{$table_name};
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status);

  my $perm_fields = ['OwnGroupId', 'AccessGroupId', 'OwnGroupPerm', 'AccessGroupPerm', 'OtherPerm'];
  my $ulti_perm_field_name = 'UltimatePerm';

  my $table_exists_kdb = table_existence($dbh_kdb, $table_name);
  
  if ($table_exists_kdb == 0) {

    my $table_exists_gis = table_existence($dbh_gis, $table_name);

    if ($table_exists_gis) {

      $dbh = $dbh_gis;
      $id_field = 'id';
      $perm_fields = ['owngroupid', 'accessgroupid', 'owngroupperm', 'accessgroupperm', 'otherperm'];
      $perm_str = permission_phrase($group_id, 1, $gadmin_status);
      $ulti_perm_field_name = 'ultimateperm';
    }
    else {

      my $table_exists_mdb = table_existence($dbh_mdb, $table_name);

      if ($table_exists_mdb) {

        $dbh = $dbh_mdb;
      }
      else {

        my $err_msg = "$table_name not found.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
  }
 
  my $is_table_with_perm = 1;

  for my $field (@{$perm_fields}) {

    my $field_exists = field_existence($dbh, $table_name, $field);
    
    if ($field_exists == 0) {

      $is_table_with_perm = 0;
    }
  }

  if ($is_table_with_perm == 0) {

    my $err_msg = 'Permission not applicable.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($id_field) == 0) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $perm_fields_str = join(',', @{$perm_fields});
  my $own_grp_field_name = $perm_fields->[0];

  my $sql = '';
  $sql   .= "SELECT $perm_fields_str , ";
  $sql   .= "$perm_str AS $ulti_perm_field_name ";
  $sql   .= "FROM $table_name ";
  $sql   .= "WHERE ( ((($perm_str) & $READ_PERM) = $READ_PERM) OR $own_grp_field_name = $group_id) ";
  $sql   .= "AND $id_field = ?";

  my $perm_data = read_data($dbh, $sql, [$record_id]);
  
  if (scalar(@{$perm_data}) == 0) {

    my $err_msg = "Record ($record_id) not found in table ($table_name).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_sql    = 'SELECT SystemGroupId, SystemGroupName FROM systemgroup';
  my $group_lookup = $dbh_kdb->selectall_hashref($group_sql, 'SystemGroupId');

  my $perm_lookup  = {'0' => 'None',
                      '1' => 'Link',
                      '2' => 'Write',
                      '3' => 'Write/Link',
                      '4' => 'Read',
                      '5' => 'Read/Link',
                      '6' => 'Read/Write',
                      '7' => 'Read/Write/Link',
  };

  my @extra_attr_perm;

  for my $row (@{$perm_data}) {

    for my $perm_f (@{$perm_fields}) {

      if ($perm_f =~ /(id)$/i) {

        my $grp_id = $row->{$perm_f};

        if ($1 eq 'id') {

          $perm_f =~ s/id/name/;
        }
        else {

          $perm_f =~ s/Id/Name/;
        }

        my $group_name_field = $perm_f;
        $row->{$group_name_field} = $group_lookup->{$grp_id}->{'SystemGroupName'};
      }
      elsif ($perm_f =~ /(perm)$/i) {

        my $perm_val = $row->{$perm_f};

        my $perm_desc_field = $perm_f . 'ission';
        $row->{$perm_desc_field} = $perm_lookup->{$perm_val};
      }
    }

    my $ulti_perm = $row->{$ulti_perm_field_name};

    $row->{$ulti_perm_field_name . 'ission'} = $perm_lookup->{$ulti_perm};
    push(@extra_attr_perm, $row);
  }

  $dbh_mdb->disconnect();
  $dbh_kdb->disconnect();
  $dbh_gis->disconnect();

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Permission' => \@extra_attr_perm,
                                           'RecordMeta' => [{'TagName' => 'Permission'}],
  };

  return $data_for_postrun_href;
}

sub get_group_runmode {

=pod get_group_gadmin_HELP_START
{
"OperationName" : "Get group",
"Description": "Return detailed information about a group specified by id including list of group members.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='Group' /><Group SystemGroupId='1' SystemGroupName='group1' SystemGroupDescription='' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'Group'}], 'Group' : [{'SystemGroupId' : '1', 'SystemGroupName' : 'group1', 'SystemGroupDescription' : ''}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Group (4) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Group (4) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing GroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self     = shift;
  my $group_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  my $group_exist = record_existence($dbh, 'systemgroup', 'SystemGroupId', $group_id);

  if (!$group_exist) {

    my $err_msg = "Group ($group_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT SystemGroupId, ';
  $sql   .= 'SystemGroupName, ';
  $sql   .= 'SystemGroupDescription ';
  $sql   .= 'FROM systemgroup ';
  $sql   .= 'WHERE SystemGroupId=?';

  my ($read_group_err, $read_group_msg, $group_aref) = read_data($dbh, $sql, [$group_id]);

  if ($read_group_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sql  = 'SELECT systemuser.UserId, UserName, contact.ContactId, ContactFirstName, ';
  $sql .= 'ContactLastName, LastLoginDateTime, UserPreference, ';
  $sql .= 'UserType, IsGroupOwner ';
  $sql .= 'FROM (systemuser LEFT JOIN authorisedsystemgroup ';
  $sql .= 'ON systemuser.UserId = authorisedsystemgroup.UserId) ';
  $sql .= 'LEFT JOIN contact ON systemuser.ContactId = contact.ContactId ';
  $sql .= 'WHERE SystemGroupId=?';

  my ($read_user_err, $read_user_msg, $user_aref) = read_data($dbh, $sql, [$group_id]);

  $dbh->disconnect();

  if ($read_user_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$user_aref}) > 0) {

    $group_aref->[0]->{'SystemUser'} = $user_aref;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Group'      => $group_aref,
                                           'RecordMeta' => [{'TagName' => 'Group'}],
  };

  return $data_for_postrun_href;
}

sub get_user_runmode {

=pod get_user_HELP_START
{
"OperationName" : "Get user",
"Description": "Return detailed information aboutsystem user specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='User' /><User ContactFirstName='Diversity' ContactLastName='Arrays' UserId='0' UserType='human' LastLoginDateTime='2014-08-27 14:39:48' UserName='admin' resetpass='user/admin/reset/password' ContactId='1' ContactName='Diversity Arrays' ContactEMail='admin@example.com' UserPreference='' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'User'}], 'User' : [{'ContactFirstName' : 'Diversity', 'UserId' : '0', 'ContactLastName' : 'Arrays', 'LastLoginDateTime' : '2014-08-27 14:39:48', 'UserType' : 'human', 'UserName' : 'admin', 'resetpass' : 'user/admin/reset/password', 'ContactId' : '1', 'ContactName' : 'Diversity Arrays', 'ContactEMail' : 'admin@example.com', 'UserPreference' : ''}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='User (5) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'User (5) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "UserId which needs to match with the UserId of the current login session unless the current login session has a group administration privilege."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self    = shift;
  my $user_id = $self->param('id');

  my $login_user_id = $self->authen->user_id();

  my $gadmin_status = $self->authen->gadmin_status();

  my $data_for_postrun_href = {};

  if ($gadmin_status ne '1') {

    if ("$user_id" ne "$login_user_id") {

      my $err_msg = "Access denied: group administrator required.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $dbh = connect_kdb_read();
  my $user_exist = record_existence($dbh, 'systemuser', 'UserId', $user_id);
  $dbh->disconnect();

  if (!$user_exist) {

    my $err_msg = "User ($user_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();

  my $sql = 'SELECT UserId, UserName, systemuser.ContactId, ';
  $sql   .= 'ContactFirstName, ContactLastName, LastLoginDateTime, ContactEMail, ';
  $sql   .= 'UserPreference, UserType ';
  $sql   .= 'FROM systemuser LEFT JOIN contact ';
  $sql   .= 'ON systemuser.ContactId = contact.ContactId ';
  $sql   .= 'WHERE UserId=?';

  my ($read_user_err, $read_user_msg, $user_data) = $self->list_user(1, $sql, [$user_id]);

  if ($read_user_err) {

    $self->logger->debug($read_user_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'User'       => $user_data,
                                           'RecordMeta' => [{'TagName' => 'User'}],
  };

  return $data_for_postrun_href;
}

sub get_version_runmode {

=pod get_version_HELP_START
{
"OperationName" : "Get version",
"Description": "Get version information of the system.",
"AuthRequired": 1,
"GroupRequired": 1,
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

sub add_barcodeconf_runmode {

=pod add_barcodeconf_gadmin_HELP_START
{
"OperationName" : "Add barcode configuration",
"Description": "Add a new barcode configuration definition.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "barcodeconf",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='1' ParaName='BarcodeConfId' /><Info Message='BarcodeConf (1) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '2', 'ParaName' : 'BarcodeConfId'}], 'Info' : [{'Message' : 'BarcodeConf (2) has been added successfully.'}]}",
"ErrorMessageXML": [{"InvalidValue": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Field (TrialName) not a barcode field.' /></DATA>" }],
"ErrorMessageJSON": [{"InvalidValue": "{'Error' : [{'Message' : 'Field (TrialName) not a barcode field.'}]}" }],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();
  
  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {};

  my ($get_scol_err, $get_scol_msg, $scol_data, $pkey_data) = get_static_field($dbh_read, 'barcodeconf');

  if ($get_scol_err) {

    $self->logger->debug("Get static field info failed: $get_scol_msg");
    
    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $required_field_href = {};

  for my $static_field (@{$scol_data}) {

    my $field_name = $static_field->{'Name'};
    
    if ($skip_field->{$field_name}) { next; }

    if ($static_field->{'Required'} == 1) {

      $required_field_href->{$field_name} = $query->param($field_name);
    }
  }

  $dbh_read->disconnect();

  my ($missing_err, $missing_href) = check_missing_href( $required_field_href );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  # Finish generic required static field checking

  my $systable     = trim($query->param('SystemTable'));
  my $sysfield     = trim($query->param('SystemField'));
  my $barcode_code = $query->param('BarcodeCode');
  my $barcode_def  = $query->param('BarcodeDef');

  my $dbh_write = connect_kdb_write();

  my ($get_field_err, $get_field_msg, $field_aref, $k_pkey) = get_static_field($dbh_write, $systable);

  if ($get_field_err) {

    my $err_msg = "Table ($systable) does not exist.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $barcode_field_lookup = { 'ItemBarcode'       => 'item',
                               'SpecimenBarcode'   => 'specimen',
                               'StorageBarcode'    => 'storage',
                               'TrialUnitBarcode'  => 'trialunit',
  };

  if (!defined($barcode_field_lookup->{$sysfield})) {

    my $err_msg = "Field ($sysfield) not a barcode field.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }
  else {

    if ($barcode_field_lookup->{$sysfield} ne "$systable") {

      my $err_msg = "Field ($sysfield) is not a field in table ($systable).";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $sql = 'SELECT BarcodeConfId FROM barcodeconf WHERE SystemTable=? AND SystemField=? LIMIT 1';

  my ($read_err, $db_barcode_conf_id) = read_cell($dbh_write, $sql, [$systable, $sysfield]);

  if ($read_err) {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_barcode_conf_id) > 0) {

    my $err_msg = "Field ($sysfield) in table ($systable) already has the configuration.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql  = 'INSERT INTO barcodeconf SET ';
  $sql .= 'SystemTable=?, ';
  $sql .= 'SystemField=?, ';
  $sql .= 'BarcodeCode=?, ';
  $sql .= 'BarcodeDef=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($systable, $sysfield, $barcode_code, $barcode_def);

  my $barcode_conf_id = -1;

  if (!$dbh_write->err()) {

    $barcode_conf_id = $dbh_write->last_insert_id(undef, undef, 'barcodeconf', 'BarcodeConfId');
  }
  else {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref  = [{'Message' => "BarcodeConf ($barcode_conf_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$barcode_conf_id", 'ParaName' => 'BarcodeConfId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_barcodeconf {

  my $self         = shift;
  my $where_clause = qq{};
  $where_clause    = shift;

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

  my $sql = 'SELECT * FROM barcodeconf ';
  $sql   .= $where_clause;
  $sql   .= ' ORDER BY BarcodeConfId DESC';

  my $sth = $dbh->prepare($sql);
  # parameters provided by the caller
  # for example, ('WHERE FieldA=?', '1') 
  $sth->execute(@_);

  my $err = 0;
  my $msg = '';
  my $barcode_conf_data = [];

  if ( !$dbh->err() ) {

    my $array_ref = $sth->fetchall_arrayref({});

    if ( !$sth->err() ) {

      $barcode_conf_data = $array_ref;
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

  my @extra_attr_barcode_conf_data;

  my $gadmin_status = $self->authen->gadmin_status();

  for my $row (@{$barcode_conf_data}) {
      
    if ($gadmin_status eq '1') {

      my $barcode_conf_id = $row->{'BarcodeConfId'};

      $row->{'update'}   = "update/barcodeconf/$barcode_conf_id";
      $row->{'delete'}   = "delete/barcodeconf/$barcode_conf_id";
    }
    push(@extra_attr_barcode_conf_data, $row);
  }

  $dbh->disconnect();

  return ($err, $msg, \@extra_attr_barcode_conf_data);
}

sub list_barcodeconf_runmode {

=pod list_barcodeconf_HELP_START
{
"OperationName" : "List barcode configuration",
"Description": "List all current entries of barcode configuration.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='BarcodeConf' /><BarcodeConf SystemTable='item' BarcodeCode='EAN-13' BarcodeConfId='2' delete='delete/barcodeconf/2' BarcodeDef='Widely used in retails' update='update/barcodeconf/2' SystemField='ItemBarcode' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'BarcodeConf'}], 'BarcodeConf' : [{'SystemTable' : 'item', 'BarcodeCode' : 'EAN-13', 'delete' : 'delete/barcodeconf/2', 'BarcodeConfId' : '2', 'update' : 'update/barcodeconf/2', 'BarcodeDef' : 'Widely used in retails', 'SystemField' : 'ItemBarcode'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self         = shift;

  my $data_for_postrun_href = {};
  my $msg = '';

  $data_for_postrun_href->{'Error'}       = 0;

  my ($barcode_conf_err, $barcode_conf_msg, $barcode_conf_list_aref) = $self->list_barcodeconf('');

  if ($barcode_conf_err) {

    $msg = 'Unexpected error.';

    $data_for_postrun_href->{'Error'}       = 1;
    $data_for_postrun_href->{'Data'}        = {'Error' => [{'Message' => $msg}]};

    return $data_for_postrun_href;
  }
  
  $data_for_postrun_href->{'Data'}    = {'BarcodeConf' => $barcode_conf_list_aref,
                                         'RecordMeta'   => [{'TagName' => 'BarcodeConf'}]
  };

  return $data_for_postrun_href;
}

sub get_barcodeconf_runmode {

=pod get_barcodeconf_HELP_START
{
"OperationName" : "Get barcode configuration",
"Description": "Get detailed information about barcode configuration for specified id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='BarcodeConf' /><BarcodeConf SystemTable='trialunit' BarcodeCode='EAN-13' BarcodeConfId='1' delete='delete/barcodeconf/1' BarcodeDef='Widely used in retails' update='update/barcodeconf/1' SystemField='TrialUnitBarcode' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'BarcodeConf'}], 'BarcodeConf' : [{'SystemTable' : 'trialunit', 'BarcodeCode' : 'EAN-13', 'delete' : 'delete/barcodeconf/1', 'BarcodeConfId' : '1', 'update' : 'update/barcodeconf/1', 'BarcodeDef' : 'Widely used in retails', 'SystemField' : 'TrialUnitBarcode'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='BarcodeConf (3) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'BarcodeConf (3) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing BarcodeConfId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self               = shift;
  my $barcode_conf_id    = $self->param('id');

  my $dbh = connect_kdb_read();
  my $barcode_conf_exist = record_existence($dbh, 'barcodeconf', 'BarcodeConfId', $barcode_conf_id);
  $dbh->disconnect();

  my $data_for_postrun_href = {};

  if (!$barcode_conf_exist) {

    $data_for_postrun_href->{'Error'}       = 1;
    $data_for_postrun_href->{'Data'}        = {'Error' => [{'Message' => "BarcodeConf ($barcode_conf_id) not found."}]};

    return $data_for_postrun_href;
  } 

  my $where_clause = 'WHERE BarcodeConfId=?';
  my ($barcode_conf_err, $barcode_conf_msg, $barcode_conf_list_aref) = $self->list_barcodeconf($where_clause,
                                                                                               $barcode_conf_id);

  if ($barcode_conf_err) {

    $data_for_postrun_href->{'Error'}       = 1;
    $data_for_postrun_href->{'Data'}        = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Data'}    = {'BarcodeConf'  => $barcode_conf_list_aref,
                                         'RecordMeta'   => [{'TagName' => 'BarcodeConf'}]
  };

  return $data_for_postrun_href;
}

sub add_multimedia_runmode {

=pod add_multimedia_HELP_START
{
"OperationName" : "Add mulitmedia file",
"Description": "Attach multimedia file to the table and record in the table.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"SkippedField": ["SystemTable", "RecordId", "OperatorId", "OrigFileName", "HashFileName", "UploadTime", "FileExtension"],
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "multimedia",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='6' ParaName='MultimediaId' /><Info Message='Multimedia (6) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '7', 'ParaName' : 'MultimediaId'}], 'Info' : [{'Message' : 'Multimedia (7) has been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error FileType='FileType (75): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'FileType' : 'FileType (75): not found.'}]}"}],
"URLParameter": [{"ParameterName": "tablename", "Description": "Name of a table to which the multimedia file belongs"}, {"ParameterName": "recid", "Description": "Id of the record to which the multimedia file is related. This Id is dependent on the table. For example, for genotype, this Id would be GenotypeId while for trial, this Id would be TrialId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self   = shift;
  my $query  = $self->query();

  my $data_for_postrun_href = {};

  my $upload_file   = $query->param('uploadfile');
  my $content_type  = $query->uploadInfo($upload_file)->{'Content-Type'};

  my $file_type = $query->param('FileType');

  my ($missing_err, $missing_href) = check_missing_href( {'FileType' => $file_type} );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  my $org_up_fname  = "$upload_file";

  $self->logger->debug("Original upload filename: $org_up_fname");

  my $table_name = $self->param('tablename');
  my $rec_id     = $self->param('recid');

  my $multimedia_setting_href = $self->{'multimedia'};

  if (!defined $multimedia_setting_href->{$table_name}) {

    my $err_msg = "Table ($table_name): multimedia not supported";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_write = connect_kdb_write();

  my $dbh;

  if ($table_name eq 'extract') {

    $dbh = connect_mdb_read();
  }
  else {

    $dbh = connect_kdb_read();
  }

  my $chk_rec_sql = $multimedia_setting_href->{$table_name}->{'ChkRecSql'};

  my ($read_err, $db_rec_id) = read_cell($dbh, $chk_rec_sql, [$rec_id]);

  if ($read_err) {

    my $err_msg = "Unexpected Error";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_rec_id) == 0) {

    my $err_msg = "Record ($rec_id) in $table_name: not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (defined $multimedia_setting_href->{$table_name}->{'ChkPermFunc'}) {
  
    my $chk_perm_func = $multimedia_setting_href->{$table_name}->{'ChkPermFunc'};
    if (!$chk_perm_func->($dbh, $rec_id, $READ_WRITE_PERM)) {

      my $err_msg = "Record ($rec_id) in $table_name: permission denied.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  $dbh->disconnect();

  if (!type_existence($dbh_write, 'multimedia', $file_type)) {

    my $err_msg = "FileType ($file_type): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'FileType' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $cur_dt = DateTime->now( time_zone => $TIMEZONE );
  my $upload_time = DateTime::Format::MySQL->format_datetime($cur_dt);

  my $user_id = $self->authen->user_id();

  my $rand = makerandom(Size => 8, Strength => 0);

  my $hash_filename_msg = "$user_id";
  $hash_filename_msg   .= "$table_name";
  $hash_filename_msg   .= "${rec_id}-";
  $hash_filename_msg   .= "$cur_dt";
  $hash_filename_msg   .= "$rand";

  $self->logger->debug("Hash FileName Msg: $hash_filename_msg");

  my $file_extension = '';

  if ($org_up_fname =~ /\.([a-zA-Z]{3,4})$/) {

    $file_extension = $1;
  }

  my $hash_filename = md5_hex($hash_filename_msg);

  if (length($file_extension) == 0) {

    $file_extension = undef;
  }
  else {

    $hash_filename .= ".$file_extension";
  }

  $self->logger->debug("Hash FileName: $hash_filename");

  my $sql = 'INSERT INTO multimedia SET ';
  $sql   .= 'SystemTable=?, ';
  $sql   .= 'RecordId=?, ';
  $sql   .= 'OperatorId=?, ';
  $sql   .= 'FileType=?, ';
  $sql   .= 'OrigFileName=?, ';
  $sql   .= 'HashFileName=?, ';
  $sql   .= 'UploadTime=?, ';
  $sql   .= 'FileExtension=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($table_name, $rec_id, $user_id, $file_type, $org_up_fname,
                $hash_filename, $upload_time, $file_extension);

  my $multimedia_id = -1;

  if (!$dbh_write->err()) {

    $multimedia_id = $dbh_write->last_insert_id(undef, undef, 'multimedia', 'MultimediaId');
  }
  else {

    my $err_msg = 'Unexpected Error';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  my $dest_storage_path = $MULTIMEDIA_STORAGE_PATH . "$table_name";

  $self->logger->debug("Dest Storage PATH: $dest_storage_path");

  if ( !(-e $dest_storage_path) ) {

    mkdir($dest_storage_path);
  }

  my $stored_multimedia_file = "${dest_storage_path}/$hash_filename";
  my $tmp_multimedia_file = $self->authen->get_upload_file();
  copy_file($tmp_multimedia_file, $stored_multimedia_file, 1);

  if ( !(-e $stored_multimedia_file) ) {

    $self->logger->debug('File not copied');

    my $del_sql = 'DELETE FROM multimedia WHERE MultimediaId=?';
    my $del_sth = $dbh_write->prepare($del_sql);
    $del_sth->execute($multimedia_id);

    if ($dbh_write->err()) {

      $self->logger->debug("Delete Multimedia Failed: " . $dbh_write->errstr());

      my $err_msg = 'Unexpected Error';
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    $del_sth->finish();

    my $err_msg = 'Unexpected Error';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_write->disconnect();

  my $info_msg_aref  = [{'Message' => "Multimedia ($multimedia_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$multimedia_id", 'ParaName' => 'MultimediaId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref,
                                           'ReturnId'  => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_multimedia_runmode {

=pod list_multimedia_HELP_START
{
"OperationName" : "List multimedia files",
"Description": "List mulitmedia files for the table and record in the table.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info NumOfFile='2' /><OutputFile SystemTable='genotype' OperatorId='0' OrigFileName='kardinal.jpg' FileType='46' UploadTime='2014-08-28 11:00:27' FileExtension='jpg' MultimediaId='7' RecordId='1' url='http://kddart.example.com/storage/multimedia/genotype/a7afb2373498cc2b8575fcb08bd7c1fa.jpg' HashFileName='a7afb2373498cc2b8575fcb08bd7c1fa.jpg' /><OutputFile SystemTable='genotype' OperatorId='0' OrigFileName='kardinal.jpg' FileType='46' UploadTime='2014-08-28 10:59:27' FileExtension='jpg' MultimediaId='6' RecordId='1' url='http://kddart.example.com/storage/multimedia/genotype/b831c45db73c8ea51e4131824605a94c.jpg' HashFileName='b831c45db73c8ea51e4131824605a94c.jpg' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'NumOfFile' : 2}], 'OutputFile' : [{'SystemTable' : 'genotype', 'OperatorId' : '0', 'FileType' : '46', 'OrigFileName' : 'kardinal.jpg', 'UploadTime' : '2014-08-28 11:00:27', 'FileExtension' : 'jpg', 'MultimediaId' : '7', 'url' : 'http://kddart.example.com/storage/multimedia/genotype/a7afb2373498cc2b8575fcb08bd7c1fa.jpg', 'RecordId' : '1', 'HashFileName' : 'a7afb2373498cc2b8575fcb08bd7c1fa.jpg'},{'SystemTable' : 'genotype', 'OperatorId' : '0', 'FileType' : '46', 'OrigFileName' : 'kardinal.jpg', 'UploadTime' : '2014-08-28 10:59:27', 'FileExtension' : 'jpg', 'MultimediaId' : '6', 'url' : 'http://kddart.example.com/storage/multimedia/genotype/b831c45db73c8ea51e4131824605a94c.jpg', 'RecordId' : '1', 'HashFileName' : 'b831c45db73c8ea51e4131824605a94c.jpg'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Record (28273) in genotype: not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Record (28273) in genotype: not found.'}]}"}],
"URLParameter": [{"ParameterName": "tablename", "Description": "Name of a table which has multimedia capability"}, {"ParameterName": "recid", "Description": "Id of the record in the specified table. This Id is dependent on the table. For example, for genotype, this Id would be GenotypeId while for trial, this Id would be TrialId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self   = shift;
  my $query  = $self->query();

  my $data_for_postrun_href = {};

  my $multimedia_setting_href = $self->{'multimedia'};

  my $table_name = $self->param('tablename');
  my $rec_id     = $self->param('recid');

  if (!defined $multimedia_setting_href->{$table_name}) {

    my $err_msg = "Table ($table_name): multimedia not supported";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh = connect_kdb_read();

  my $chk_rec_sql = $multimedia_setting_href->{$table_name}->{'ChkRecSql'};

  my ($read_err, $db_rec_id) = read_cell($dbh, $chk_rec_sql, [$rec_id]);

  if ($read_err) {

    my $err_msg = "Unexpected Error";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_rec_id) == 0) {

    my $err_msg = "Record ($rec_id) in $table_name: not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (defined $multimedia_setting_href->{$table_name}->{'ChkPermFunc'}) {
  
    my $chk_perm_func = $multimedia_setting_href->{$table_name}->{'ChkPermFunc'};
    if (!$chk_perm_func->($dbh, $rec_id, $READ_PERM)) {

      my $err_msg = "Record ($rec_id) in $table_name: permission denied.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $sql = 'SELECT * FROM multimedia WHERE SystemTable=? AND RecordId=? ';
  $sql   .= 'ORDER BY UploadTime DESC';

  my ($read_data_err, $read_data_msg, $multimedia_data) = read_data($dbh, $sql, [$table_name, $rec_id]);

  if ($read_data_err) {

    $self->logger->debug("Read multimedia failed: $read_data_msg");

    my $err_msg = "Unexpected Error";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  my $url = reconstruct_server_url();

  my $output_file_aref = [];
  my $info_aref        = [];

  my $dest_storage_path = $MULTIMEDIA_STORAGE_PATH . "$table_name";

  if ( !(-e $dest_storage_path) ) {

    $info_aref = [{'NumOfFile' => 0}];
    $data_for_postrun_href->{'Error'}     = 0;
    $data_for_postrun_href->{'Data'}      = {'OutputFile'     => $output_file_aref,
                                             'Info'           => $info_aref,
    };

    $data_for_postrun_href->{'ExtraData'} = 0;

    return $data_for_postrun_href;
  }

  for my $multimedia_rec (@{$multimedia_data}) {

    my $hash_filename = $multimedia_rec->{'HashFileName'};

    if ( (-e "${dest_storage_path}/$hash_filename") ) {

      $multimedia_rec->{'url'} = "$url/storage/multimedia/$table_name/$hash_filename";
      push(@{$output_file_aref}, $multimedia_rec);
    }
  }

  $info_aref = [{'NumOfFile' => scalar(@{$output_file_aref})}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'OutputFile'     => $output_file_aref,
                                           'Info'           => $info_aref,
  };

  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub check_geno_perm {

  my $self    = $_[0];
  my $dbh     = $_[1];
  my $geno_id = $_[2];
  my $perm    = $_[3];

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status);

  my ($is_ok, $trouble_geno_id_aref) = check_permission($dbh, 'genotype', 'GenotypeId',
                                                        [$geno_id], $group_id, $gadmin_status,
                                                        $perm);

  if (!$is_ok) {

    my $trouble_geno_id_str = join(',', @{$trouble_geno_id_aref});

    my $perm_err_msg = '';
    $perm_err_msg   .= "Permission denied: Group ($group_id) and Genotype ($trouble_geno_id_str).";
    $self->logger->debug($perm_err_msg);

    return 0;
  }
  else {

    return 1;
  }
}

sub check_spec_perm {

  my $self    = $_[0];
  my $dbh     = $_[1];
  my $spec_id = $_[2];
  my $perm    = $_[3];

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str      = permission_phrase($group_id, 0, $gadmin_status, 'genotype');

  my $geno_perm_sql = "SELECT DISTINCT genotypespecimen.SpecimenId ";
  $geno_perm_sql   .= "FROM genotypespecimen LEFT JOIN genotype ON genotypespecimen.GenotypeId = genotype.GenotypeId ";
  $geno_perm_sql   .= "WHERE (($perm_str) & $READ_WRITE_PERM) = $READ_WRITE_PERM AND genotypespecimen.SpecimenId = ?";

  my ($r_spec_id_err, $db_spec_id) = read_cell($dbh, $geno_perm_sql, [$spec_id]);

  if ($r_spec_id_err) {

    $self->logger->debug("Read SpecimenId from database failed");
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

  my $self     = $_[0];
  my $dbh      = $_[1];
  my $trial_id = $_[2];
  my $perm     = $_[3];

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str      = permission_phrase($group_id, 0, $gadmin_status);

  my ($is_ok, $trouble_trial_id_aref) = check_permission($dbh, 'trial', 'TrialId',
                                                         [$trial_id], $group_id, $gadmin_status,
                                                         $perm);

  if (!$is_ok) {

    my $trouble_trial_id_str = join(',', @{$trouble_trial_id_aref});

    my $perm_err_msg = '';
    $perm_err_msg   .= "Permission denied: Group ($group_id) and Trial ($trouble_trial_id_str).";
    $self->logger->debug($perm_err_msg);

    return 0;
  }
  else {

    return 1;
  }
}

sub check_project_perm {

  my $self       = $_[0];
  my $dbh        = $_[1];
  my $project_id = $_[2];
  my $perm       = $_[3];

  my $gadmin_status = $self->authen->gadmin_status();

  if ($gadmin_status eq '1') {

    return 1;
  }
  else {

    return 0;
  }
}

sub check_item_perm {

  my $self       = $_[0];
  my $dbh        = $_[1];
  my $item_id    = $_[2];
  my $perm       = $_[3];

  my $gadmin_status = $self->authen->gadmin_status();

  if ($gadmin_status eq '1') {

    return 1;
  }
  else {

    return 0;
  }
}

sub check_extract_perm {

  my $self       = $_[0];
  my $dbh        = $_[1];
  my $extract_id = $_[2];
  my $perm       = $_[3];

  my $gadmin_status = $self->authen->gadmin_status();

  if ($gadmin_status eq '1') {

    return 1;
  }
  else {

    return 0;
  }
}

sub check_trialunit_perm {

  my $self          = $_[0];
  my $dbh           = $_[1];
  my $trial_unit_id = $_[2];
  my $perm          = $_[3];

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str      = permission_phrase($group_id, 0, $gadmin_status);

  my $trial_id = read_cell_value($dbh, 'trialunit', 'TrialId', 'TrialUnitId', $trial_unit_id);

  my ($is_ok, $trouble_trial_id_aref) = check_permission($dbh, 'trial', 'TrialId',
                                                         [$trial_id], $group_id, $gadmin_status,
                                                         $perm);

  if (!$is_ok) {

    my $trouble_trial_id_str = join(',', @{$trouble_trial_id_aref});

    my $perm_err_msg = '';
    $perm_err_msg   .= "Permission denied: Group ($group_id) and Trial ($trouble_trial_id_str).";
    $self->logger->debug($perm_err_msg);

    return 0;
  }
  else {

    return 1;
  }
}

sub logger {

  my $self = shift;
  return $self->{logger};
}

1;
