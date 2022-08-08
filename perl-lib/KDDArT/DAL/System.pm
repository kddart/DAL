#$Id$
#$Author$

# Copyright (c) 2011, Diversity Arrays Technology, All rights reserved.

# Author    : Puthick Hok
# Created   : 02/06/2010
# Modified  :
# Purpose   : 
#          
#          

package KDDArT::DAL::System;

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
use KDDArT::DAL::Common;
use KDDArT::DAL::Security;
use Log::Log4perl qw(get_logger :levels);
use Digest::HMAC_SHA1 qw(hmac_sha1 hmac_sha1_hex);
use DateTime::Format::MySQL;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use Crypt::Random qw( makerandom );
use JSON::XS qw(encode_json decode_json);
use XML::Checker::Parser;
use Config::Simple;


sub setup {

  my $self = shift;

  CGI::Session->name("KDDArT_DAL_SESSID");

  __PACKAGE__->authen->init_config_parameters();
  __PACKAGE__->authen->check_login_runmodes(':all');
  __PACKAGE__->authen->check_content_type_runmodes(':all');
  __PACKAGE__->authen->count_session_request_runmodes(':all');
  __PACKAGE__->authen->ignore_group_assignment_runmodes('list_group',
                                                        'update_user_preference',
                                                        'get_user_preference'
                                                       );

  __PACKAGE__->authen->check_rand_runmodes('add_user_gadmin',
                                           'update_user_gadmin',
                                           'add_group_gadmin',
                                           'change_user_password',
                                           'remove_group_member_gadmin',
                                           'remove_owner_status_gadmin',
                                           'change_permission',
                                           'change_owner',
                                           'add_barcodeconf_gadmin',
                                           'add_multimedia',
                                           'update_multimedia',
                                           'del_multimedia_gadmin',
                                           'add_workflow_gadmin',
                                           'update_workflow_gadmin',
                                           'del_workflow_gadmin',
                                           'add_workflow_def_gadmin',
                                           'update_workflow_def_gadmin',
                                           'del_workflow_def_gadmin',
                                           'update_user_preference',
                                           'add_keyword_gadmin',
                                           'update_keyword_gadmin',
                                           'del_keyword_gadmin',
                                           'add_keyword_group_gadmin',
                                           'update_keyword_group_gadmin',
                                           'add_keyword2group_bulk_gadmin',
                                           'remove_keyword_from_group_gadmin',
                                           'del_keyword_group_gadmin',
                                           'update_group_gadmin',
                                           'update_nursery_type_list_csv_gadmin',
                                           'update_genotype_config_gadmin',
      );
  __PACKAGE__->authen->check_signature_runmodes('add_user_gadmin',
                                                'update_user_gadmin',
                                                'add_group_gadmin',
                                                'change_user_password',
                                                'remove_group_member_gadmin',
                                                'remove_owner_status_gadmin',
                                                'change_permission',
                                                'change_owner',
                                                'add_barcodeconf_gadmin',
                                                'update_multimedia',
                                                'del_multimedia_gadmin',
                                                'add_workflow_gadmin',
                                                'update_workflow_gadmin',
                                                'del_workflow_gadmin',
                                                'add_workflow_def_gadmin',
                                                'update_workflow_def_gadmin',
                                                'del_workflow_def_gadmin',
                                                'update_user_preference',
                                                'add_keyword_gadmin',
                                                'update_keyword_gadmin',
                                                'del_keyword_gadmin',
                                                'update_keyword_group_gadmin',
                                                'remove_keyword_from_group_gadmin',
                                                'del_keyword_group_gadmin',
                                                'update_group_gadmin',
                                                'update_nursery_type_list_csv_gadmin',
                                                'update_genotype_config_gadmin',
      );
  __PACKAGE__->authen->check_gadmin_runmodes('add_user_gadmin',
                                             'update_user_gadmin',
                                             'add_group_member_gadmin',
                                             'add_group_gadmin',
                                             'list_user_gadmin',
                                             'remove_group_member_gadmin',
                                             'remove_owner_status_gadmin',
                                             'get_group_gadmin',
                                             'add_barcodeconf_gadmin',
                                             'del_multimedia_gadmin',
                                             'add_workflow_gadmin',
                                             'update_workflow_gadmin',
                                             'del_workflow_gadmin',
                                             'add_workflow_def_gadmin',
                                             'update_workflow_def_gadmin',
                                             'del_workflow_def_gadmin',
                                             'add_keyword_gadmin',
                                             'update_keyword_gadmin',
                                             'del_keyword_gadmin',
                                             'add_keyword_group_gadmin',
                                             'update_keyword_group_gadmin',
                                             'add_keyword2group_bulk_gadmin',
                                             'remove_keyword_from_group_gadmin',
                                             'del_keyword_group_gadmin',
                                             'update_group_gadmin',
                                             'update_nursery_type_list_csv_gadmin',
                                             'update_genotype_config_gadmin',
      );
  __PACKAGE__->authen->check_sign_upload_runmodes('add_multimedia',
                                                  'add_keyword_group_gadmin',
                                                  'add_keyword2group_bulk_gadmin',
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
    'list_user_gadmin'             => 'list_user_runmode',
    'change_user_password'         => 'change_user_password_runmode',
    'remove_group_member_gadmin'   => 'remove_group_member_runmode',
    'remove_owner_status_gadmin'   => 'remove_owner_status_runmode',
    'change_permission'            => 'change_permission_runmode',
    'change_owner'                 => 'change_owner_runmode',
    'get_group_gadmin'             => 'get_group_runmode',
    'get_user'                     => 'get_user_runmode',
    'get_permission'               => 'get_permission_runmode',
    'add_barcodeconf_gadmin'       => 'add_barcodeconf_runmode',
    'list_barcodeconf'             => 'list_barcodeconf_runmode',
    'get_barcodeconf'              => 'get_barcodeconf_runmode',
    'add_multimedia'               => 'add_multimedia_runmode',
    'list_multimedia'              => 'list_multimedia_runmode',
    'get_multimedia'               => 'get_multimedia_runmode',
    'update_multimedia'            => 'update_multimedia_runmode',
    'del_multimedia_gadmin'               => 'del_multimedia_runmode',
    'add_workflow_gadmin'                 => 'add_workflow_runmode',
    'update_workflow_gadmin'              => 'update_workflow_runmode',
    'del_workflow_gadmin'                 => 'del_workflow_runmode',
    'list_workflow'                       => 'list_workflow_runmode',
    'get_workflow'                        => 'get_workflow_runmode',
    'add_workflow_def_gadmin'             => 'add_workflow_def_runmode',
    'update_workflow_def_gadmin'          => 'update_workflow_def_runmode',
    'list_workflow_def'                   => 'list_workflow_def_runmode',
    'get_workflow_def'                    => 'get_workflow_def_runmode',
    'del_workflow_def_gadmin'             => 'del_workflow_def_runmode',
    'get_user_preference'                 => 'get_user_preference_runmode',
    'update_user_preference'              => 'update_user_preference_runmode',
    'add_keyword_gadmin'                  => 'add_keyword_runmode',
    'update_keyword_gadmin'               => 'update_keyword_runmode',
    'list_keyword_advanced'               => 'list_keyword_advanced_runmode',
    'get_keyword'                         => 'get_keyword_runmode',
    'del_keyword_gadmin'                  => 'del_keyword_runmode',
    'add_keyword_group_gadmin'            => 'add_keyword_group_runmode',
    'update_keyword_group_gadmin'         => 'update_keyword_group_runmode',
    'list_keyword_group_advanced'         => 'list_keyword_group_runmode',
    'get_keyword_group'                   => 'get_keyword_group_runmode',
    'add_keyword2group_bulk_gadmin'       => 'add_keyword2group_bulk_runmode',
    'list_keyword_in_group'               => 'list_keyword_in_group_runmode',
    'remove_keyword_from_group_gadmin'    => 'remove_keyword_from_group_runmode',
    'del_keyword_group_gadmin'            => 'del_keyword_group_runmode',
    'update_group_gadmin'                 => 'update_group_runmode',
    'get_unique_number'                   => 'get_unique_number_runmode',
    'update_nursery_type_list_csv_gadmin' => 'update_nursery_type_list_csv_runmode',
    'update_genotype_config_gadmin'       => 'update_genotype_config_runmode',
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

  $multimedia_href->{'extract'}       = { 'ChkRecSql'     => 'SELECT "ExtractId" FROM "extract" WHERE "ExtractId"=?',
                                          'ChkPermFunc'   => sub { return $self->check_extract_perm(@_); }
  };

  $self->{'multimedia'} = $multimedia_href;
}

sub add_user_runmode {

=pod add_user_gadmin_HELP_START
{
"OperationName": "Add user",
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

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'PasswordSalt' => 1};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'systemuser', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $username   = $query->param('UserName');
  my $password   = $query->param('UserPassword');
  my $contact_id = $query->param('ContactId');
  my $usertype   = $query->param('UserType');

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
"OperationName": "Update user",
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

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'PasswordSalt' => 1,
                    'UserName'     => 1,
                    'UserPassword' => 1,
                   };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'systemuser', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $contact_id = $query->param('ContactId');
  my $usertype   = $query->param('UserType');

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
"OperationName": "List group(s)",
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
"OperationName": "List all groups",
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
"OperationName": "List operations",
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
"OperationName": "Get session expiry",
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
"OperationName": "Add group member",
"Description": "Add system user to a system group.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='14' ParaName='AuthorisedSystemGroupId' /><Info Message='User (user1) has been added to Group (2) successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '15', 'ParaName' : 'AuthorisedSystemGroupId'}], 'Info' : [{'Message' : 'User (user2) has been added to Group (2) successfully.'}]}",
"ErrorMessageXML": [{"AlreadyExists": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='User (user1) is already a member of Group (2).' /></DATA>"}],
"ErrorMessageJSON": [{"AlreadyExists": "{'Error' : [{'Message' : 'User (user2) is already a member of Group (2).'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "GroupId"}, {"ParameterName": "username", "Description": "Username of the user to be added to the group"}],
"HTTPParameter": [{"Required": 1, "Name": "IsGroupOwner", "Description": "Status value either 1 or 0 indicating if the user which is to be added to the group is a group admin or not. 1 is for a group admin and 0 is for not a group admin."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self      = shift;

  my $group_id  = $self->param('id');
  my $username  = $self->param('username');

  my $data_for_postrun_href = {};

  my $dbh_write = connect_kdb_write();

  if (!record_existence($dbh_write, 'systemgroup', 'SystemGroupId', $group_id)) {

    my $err_msg = "Group ($group_id): not found";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $login_group_id = $self->authen->group_id();
  my $login_user_id  = $self->authen->user_id();
  my $login_username = $self->authen->username();

  my $sql;

  $sql  = 'SELECT AuthorisedSystemGroupId ';
  $sql .= 'FROM authorisedsystemgroup ';
  $sql .= 'WHERE SystemGroupId=? AND UserId=? LIMIT 1';

  # This runmode is only for a group admin. Therefore, checking IsGroupOwner is not required.
  # If this SQL retuns a number, it can be deduced that the user is a group owner of this group.

  my ($r_sysgrp_err, $auth_sys_grp_id) = read_cell($dbh_write, $sql, [$group_id, $login_user_id]);

  if ($r_sysgrp_err) {

    $self->logger->debug("Checking if login user is a group admin of this group failed.");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  if ($login_group_id ne '0') {

    if (length($auth_sys_grp_id) == 0) {

      my $err_msg = "Group ($group_id) and User ($login_username): permission denied.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $user_id = read_cell_value($dbh_write, 'systemuser', 'UserId', 'UserName', $username);

  if (length($user_id) == 0) {

    my $err_msg = "User ($username): not found";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("Looked up UserId: $user_id - GroupId: $group_id");

  $sql  = 'SELECT AuthorisedSystemGroupId ';
  $sql .= 'FROM authorisedsystemgroup ';
  $sql .= 'WHERE SystemGroupId=? AND UserId=? LIMIT 1';

  ($r_sysgrp_err, $auth_sys_grp_id) = read_cell($dbh_write, $sql, [$group_id, $user_id]);

  if ($r_sysgrp_err) {

    $self->logger->debug("Checking if the user is already a member of the group failed.");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("Looked up AuthorisedSystemGroupId: $auth_sys_grp_id");

  if (length("$auth_sys_grp_id") > 0) {

    my $err_msg = "User ($username) is already a member of Group ($group_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $query = $self->query();

  my $is_group_owner = $query->param('IsGroupOwner');

  my ($missing_err, $missing_href) = check_missing_href( {'IsGroupOwner' => $is_group_owner} );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  if ($is_group_owner !~ /^0|1$/) {

    my $err_msg = "IsGroupOwner ($is_group_owner) is not 0 or 1.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'IsGroupOwner' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql  = 'INSERT INTO authorisedsystemgroup SET ';
  $sql .= 'UserId=?, ';
  $sql .= 'SystemGroupId=?, ';
  $sql .= 'IsGroupOwner=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($user_id, $group_id, $is_group_owner);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $authorised_sys_grp_id = $dbh_write->last_insert_id(undef, undef, 'authorisedsystemgroup', 'AuthorisedSystemGroupId');

  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref  = [{'Message' => "User ($username) has been added to Group ($group_id) successfully."}];
  my $return_id_aref = [{'Value' => "$authorised_sys_grp_id", 'ParaName' => 'AuthorisedSystemGroupId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref,
                                           'ReturnId'  => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
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

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error.'}]};

      return $data_for_postrun_href;
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
"OperationName": "Add group",
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

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'systemgroup', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $group_name        = $query->param('SystemGroupName');

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
"OperationName": "List users in the current group",
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

  my $sql = 'SELECT DISTINCT systemuser.UserId, UserName, ContactId, UserType ';
  $sql   .= 'FROM systemuser LEFT JOIN authorisedsystemgroup ';
  $sql   .= 'ON systemuser.UserId = authorisedsystemgroup.UserId ';
  $sql   .= 'ORDER BY systemuser.UserId DESC';

  my ($read_user_err, $read_user_msg, $user_data) = $self->list_user(1, $sql, []);

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
"OperationName": "Change password",
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

  my ($missing_err, $missing_href) = check_missing_href( { 'NewUserPassword'     => $new_pass } );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();

  my $username = $self->authen->username();

  my $dbh_write = connect_kdb_write();

  if (!record_existence($dbh_write, 'systemuser', 'UserName', $username_on_request)) {

    my $err_msg = "Username ($username_on_request): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ("$group_id" ne '0') {

    my ($missing_err, $missing_href) = check_missing_href( { 'CurrentUserPassword' => $current_pass } );

    if ($missing_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

      return $data_for_postrun_href;
    }

    if ($username_on_request ne $username) {

      my $err_msg = 'Incorrect username or password.';
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $db_hash_pass = read_cell_value($dbh_write, 'systemuser', 'UserPassword', 'UserName', $username);

    if ($current_pass ne $db_hash_pass) {

      my $err_msg = 'Incorrect username or password.';
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $sql = 'UPDATE systemuser SET ';
  $sql   .= 'UserPassword=? ';
  $sql   .= 'WHERE UserName=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($new_pass, $username_on_request);

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
"OperationName": "Remove user from a group",
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
"OperationName": "Remove owner status",
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
"OperationName": "Change record permission",
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
                            'specimengroup'   => 'SpecimenGroupId',
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
"OperationName": "Change owner",
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
                            'layer'           => 'id',
                            'specimengroup'   => 'SpecimenGroupId',
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
"OperationName": "Get permission",
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
"OperationName": "Get group",
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
"OperationName": "Get user",
"Description": "Return detailed information about system user specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='User' /><User ContactFirstName='Diversity' ContactLastName='Arrays' UserId='0' UserType='human' LastLoginDateTime='2014-08-27 14:39:48' UserName='admin' resetpass='user/admin/reset/password' ContactId='1' ContactName='Diversity Arrays' ContactEMail='dart-it@diversityarrays.com' UserPreference='' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'User'}], 'User' : [{'ContactFirstName' : 'Diversity', 'UserId' : '0', 'ContactLastName' : 'Arrays', 'LastLoginDateTime' : '2014-08-27 14:39:48', 'UserType' : 'human', 'UserName' : 'admin', 'resetpass' : 'user/admin/reset/password', 'ContactId' : '1', 'ContactName' : 'Diversity Arrays', 'ContactEMail' : 'dart-it@diversityarrays.com', 'UserPreference' : ''}]}",
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

sub add_barcodeconf_runmode {

=pod add_barcodeconf_gadmin_HELP_START
{
"OperationName": "Add barcode configuration",
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

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'barcodeconf', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

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
"OperationName": "List barcode configuration",
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
"OperationName": "Get barcode configuration",
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
"OperationName": "Add multimedia file",
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

  $self->logger->debug("adding multimedia...\n");

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

  my $note       = undef;

  if (defined $query->param('MultimediaNote')) {

    if (length($query->param('MultimediaNote')) > 0) {

      $note = $query->param('MultimediaNote');
    }
  }

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
  $sql   .= 'FileExtension=?, ';
  $sql   .= 'MultimediaNote=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($table_name, $rec_id, $user_id, $file_type, $org_up_fname,
                $hash_filename, $upload_time, $file_extension, $note);

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

  my $dest_storage_path = $ENV{DOCUMENT_ROOT} . '/' . $MULTIMEDIA_STORAGE_PATH . "$table_name";

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

sub list_multimedia {

  my $self            = $_[0];
  my $table_name      = $_[1];
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

  $dbh->disconnect();

  my $url = reconstruct_server_url();

  my $dest_storage_path = $ENV{DOCUMENT_ROOT} . '/' . $MULTIMEDIA_STORAGE_PATH . "$table_name";

  my $output_file_aref = [];

  for my $multimedia_rec (@{$data_aref}) {

    my $hash_filename = $multimedia_rec->{'HashFileName'};

    if ( (-e "${dest_storage_path}/$hash_filename") ) {

      $multimedia_rec->{'url'} = "$url/storage/multimedia/$table_name/$hash_filename";
      push(@{$output_file_aref}, $multimedia_rec);
    }
  }

  return ($err, $msg, $output_file_aref);
}

sub list_multimedia_runmode {

=pod list_multimedia_HELP_START
{
"OperationName": "List multimedia files",
"Description": "List multimedia files for the table and record in the table.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info NumOfFile='2' /><OutputFile SystemTable='genotype' OperatorId='0' OrigFileName='kardinal.jpg' FileType='46' UploadTime='2014-08-28 11:00:27' FileExtension='jpg' MultimediaId='7' RecordId='1' url='http://kddart-d.diversityarrays.com/storage/multimedia/genotype/a7afb2373498cc2b8575fcb08bd7c1fa.jpg' HashFileName='a7afb2373498cc2b8575fcb08bd7c1fa.jpg' /><OutputFile SystemTable='genotype' OperatorId='0' OrigFileName='kardinal.jpg' FileType='46' UploadTime='2014-08-28 10:59:27' FileExtension='jpg' MultimediaId='6' RecordId='1' url='http://kddart-d.diversityarrays.com/storage/multimedia/genotype/b831c45db73c8ea51e4131824605a94c.jpg' HashFileName='b831c45db73c8ea51e4131824605a94c.jpg' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'NumOfFile' : 2}], 'OutputFile' : [{'SystemTable' : 'genotype', 'OperatorId' : '0', 'FileType' : '46', 'OrigFileName' : 'kardinal.jpg', 'UploadTime' : '2014-08-28 11:00:27', 'FileExtension' : 'jpg', 'MultimediaId' : '7', 'url' : 'http://kddart-d.diversityarrays.com/storage/multimedia/genotype/a7afb2373498cc2b8575fcb08bd7c1fa.jpg', 'RecordId' : '1', 'HashFileName' : 'a7afb2373498cc2b8575fcb08bd7c1fa.jpg'},{'SystemTable' : 'genotype', 'OperatorId' : '0', 'FileType' : '46', 'OrigFileName' : 'kardinal.jpg', 'UploadTime' : '2014-08-28 10:59:27', 'FileExtension' : 'jpg', 'MultimediaId' : '6', 'url' : 'http://kddart-d.diversityarrays.com/storage/multimedia/genotype/b831c45db73c8ea51e4131824605a94c.jpg', 'RecordId' : '1', 'HashFileName' : 'b831c45db73c8ea51e4131824605a94c.jpg'}]}",
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

  my $monetdb_table_href = { 'extract' => 1 };

  my $dbh = undef;

  if ( $monetdb_table_href->{lc($table_name)} == 1 ) {

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
    if (!$chk_perm_func->($dbh, $rec_id, $READ_PERM)) {

      my $err_msg = "Record ($rec_id) in $table_name: permission denied.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  $dbh->disconnect();

  my $dest_storage_path = $ENV{DOCUMENT_ROOT} . '/' . $MULTIMEDIA_STORAGE_PATH . "$table_name";

  if ( !(-e $dest_storage_path) ) {

    $data_for_postrun_href->{'Error'}     = 0;
    $data_for_postrun_href->{'Data'}      = {'OutputFile'     => [],
                                             'RecordMeta'     => [{'TagName' => 'OutputFile'}]
    };

    $data_for_postrun_href->{'ExtraData'} = 0;

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT * FROM multimedia WHERE SystemTable=? AND RecordId=? ';
  $sql   .= 'ORDER BY UploadTime DESC';

  my ($multimedia_err, $multimedia_msg, $multimedia_data) = $self->list_multimedia($table_name, $sql, [$table_name, $rec_id]);

  if ($multimedia_err) {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'OutputFile'     => $multimedia_data,
                                           'RecordMeta'     => [{'TagName' => 'OutputFile'}]
  };

  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub get_multimedia_runmode {

=pod get_multimedia_HELP_START
{
"OperationName": "Get multimedia file meta data",
"Description": "Get meta data of a multimedia file specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='OutputFile' /><OutputFile SystemTable='genotype' OperatorId='0' MultimediaNote='' FileType='72' OrigFileName='uploadfile' UploadTime='2015-09-29 16:19:07' FileExtension='' MultimediaId='1' RecordId='7' url='http://sandbox.kddart.org/storage/multimedia/genotype/cdd5404419e035b3dbbe51112d5ad7a1' HashFileName='cdd5404419e035b3dbbe51112d5ad7a1' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'OutputFile'}], 'OutputFile' : [{'SystemTable' : 'genotype', 'MultimediaNote' : null, 'OperatorId' : '0', 'OrigFileName' : 'uploadfile', 'FileType' : '72', 'UploadTime' : '2015-09-29 16:19:07', 'FileExtension' : null, 'MultimediaId' : '1', 'url' : 'http://sandbox.kddart.org/storage/multimedia/genotype/cdd5404419e035b3dbbe51112d5ad7a1', 'RecordId' : '7', 'HashFileName' : 'cdd5404419e035b3dbbe51112d5ad7a1'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Multimedia (11): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Multimedia (11): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing multimedia id"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self   = shift;
  my $query  = $self->query();

  my $data_for_postrun_href = {};

  my $multimedia_setting_href = $self->{'multimedia'};

  my $dbh = connect_kdb_read();

  my $multimedia_id = $self->param('id');

  if (!record_existence($dbh, 'multimedia', 'MultimediaId', $multimedia_id)) {

    my $err_msg = "Multimedia ($multimedia_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $read_media_sql   = 'SELECT SystemTable, RecordId ';
     $read_media_sql  .= 'FROM multimedia WHERE MultimediaId=? ';

  my ($r_df_val_err, $r_df_val_msg, $media_df_val_data) = read_data($dbh, $read_media_sql, [$multimedia_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve multimedia default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $table_name   =   undef;
  my $rec_id       =   undef;

  my $nb_df_val_rec    =  scalar(@{$media_df_val_data});

  if ($nb_df_val_rec != 1)  {
  
     $self->logger->debug("Retrieve multimedia default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $table_name   =   $media_df_val_data->[0]->{'SystemTable'};
  $rec_id       =   $media_df_val_data->[0]->{'RecordId'};

  my $chk_rec_sql = $multimedia_setting_href->{$table_name}->{'ChkRecSql'};

  my ($read_err, $db_rec_id) = read_cell($dbh, $chk_rec_sql, [$rec_id]);

  if ($read_err) {

    my $err_msg = "Unexpected Error";
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

  $dbh->disconnect();

  my $dest_storage_path = $ENV{DOCUMENT_ROOT} . '/' . $MULTIMEDIA_STORAGE_PATH . "$table_name";

  if ( !(-e $dest_storage_path) ) {

    $data_for_postrun_href->{'Error'}     = 0;
    $data_for_postrun_href->{'Data'}      = {'OutputFile'     => [],
                                             'RecordMeta'     => [{'TagName' => 'OutputFile'}]
    };

    $data_for_postrun_href->{'ExtraData'} = 0;

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT * FROM multimedia WHERE MultimediaId=? ';
  $sql   .= 'ORDER BY UploadTime DESC';

  my ($multimedia_err, $multimedia_msg, $multimedia_data) = $self->list_multimedia($table_name, $sql, [$multimedia_id]);

  if ($multimedia_err) {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'OutputFile'     => $multimedia_data,
                                           'RecordMeta'     => [{'TagName' => 'OutputFile'}]
  };

  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_multimedia_runmode {

=pod update_multimedia_HELP_START
{
"OperationName": "Update multimedia meta data",
"Description": "Update multimedia meta data specified by id",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"SkippedField": ["SystemTable", "RecordId", "OperatorId", "OrigFileName", "HashFileName", "UploadTime", "FileExtension"],
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "multimedia",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Multimedia (6) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Multimedia (6) has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Multimedia (14): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Multimedia (14): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing multimedia id"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self   = shift;
  my $query  = $self->query();

  my $multimedia_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $file_type = $query->param('FileType');

  my ($missing_err, $missing_href) = check_missing_href( {'FileType' => $file_type} );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  my $dbh_write = connect_kdb_write();

  if (!record_existence($dbh_write, 'multimedia', 'MultimediaId', $multimedia_id)) {

    my $err_msg = "Multimedia ($multimedia_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $read_mm_sql     =   'SELECT SystemTable, RecordId, MultimediaNote ';
  $read_mm_sql       .=   'FROM multimedia WHERE MultimediaId=? ';

  my ($r_df_val_err, $r_df_val_msg, $mm_df_val_data) = read_data($dbh_write, $read_mm_sql, [$multimedia_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve multimedia default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $table_name     =  undef;
  my $rec_id         =  undef;
  my $note           =  undef;

  my $nb_df_val_rec    =  scalar(@{$mm_df_val_data});

  if ($nb_df_val_rec != 1)  {

    $self->logger->debug("Retrieve multimedia default values - number of records unacceptable: $nb_df_val_rec");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  $table_name      = $mm_df_val_data->[0]->{'SystemTable'};
  $rec_id          = $mm_df_val_data->[0]->{'RecordId'};
  $note            = $mm_df_val_data->[0]->{'MultimediaNote'};


  if (length($note) == 0) {

    $note = undef;
  }

  if (defined $query->param('MultimediaNote')) {

    if (length($query->param('MultimediaNote')) > 0) {

      $note = $query->param('MultimediaNote');
    }
  }

  my $new_rec_id = $rec_id;

  if (defined $query->param('RecordId')) {

    if (length($query->param('RecordId')) > 0) {

      $new_rec_id = $query->param('RecordId');
    }
  }

  my $multimedia_setting_href = $self->{'multimedia'};

  my $dbh;

  if ($table_name eq 'extract') {

    $dbh = connect_mdb_read();
  }
  else {

    $dbh = connect_kdb_read();
  }

  my $chk_rec_sql = $multimedia_setting_href->{$table_name}->{'ChkRecSql'};

  my ($read_err, $new_db_rec_id) = read_cell($dbh, $chk_rec_sql, [$new_rec_id]);

  if ($read_err) {

    my $err_msg = "Unexpected Error";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($new_db_rec_id) == 0) {

    my $err_msg = "Record ($new_rec_id) in $table_name: not found.";
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

    if (!$chk_perm_func->($dbh, $new_rec_id, $READ_WRITE_PERM)) {

      my $err_msg = "Record ($new_rec_id) in $table_name: permission denied.";
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

  my $sql = 'UPDATE multimedia SET ';
  $sql   .= 'RecordId=?, ';
  $sql   .= 'FileType=?, ';
  $sql   .= 'MultimediaNote=? ';
  $sql   .= 'WHERE MultimediaId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($new_rec_id, $file_type, $note, $multimedia_id);

  if ($dbh_write->err()) {

    my $err_msg = 'Unexpected Error';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }
  $sth->finish();


  $dbh_write->disconnect();

  my $info_msg_aref  = [{'Message' => "Multimedia ($multimedia_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub del_multimedia_runmode {

=pod del_multimedia_gadmin_HELP_START
{
"OperationName": "Delete multimedia",
"Description": "Delete multimedia",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Multimedia (8) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Multimedia (10) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Multimedia (12): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Multimedia (12): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing multimedia id"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self   = shift;
  my $query  = $self->query();

  my $multimedia_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_write = connect_kdb_write();

  if (!record_existence($dbh_write, 'multimedia', 'MultimediaId', $multimedia_id)) {

    my $err_msg = "Multimedia ($multimedia_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $read_media_sql   = 'SELECT SystemTable, RecordId ';
     $read_media_sql  .= 'FROM multimedia WHERE MultimediaId=? ';

  my ($r_df_val_err, $r_df_val_msg, $media_df_val_data) = read_data($dbh_write, $read_media_sql, [$multimedia_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve multimedia default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $table_name   =   undef;
  my $rec_id       =   undef;

  my $nb_df_val_rec    =  scalar(@{$media_df_val_data});

  if ($nb_df_val_rec != 1)  {
  
     $self->logger->debug("Retrieve multimedia default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $table_name   =   $media_df_val_data->[0]->{'SystemTable'};
  $rec_id       =   $media_df_val_data->[0]->{'RecordId'};

  my $multimedia_setting_href = $self->{'multimedia'};

  my $dbh;

  if ($table_name eq 'extract') {

    $dbh = connect_mdb_read();
  }
  else {

    $dbh = connect_kdb_read();
  }

  my $chk_rec_sql = $multimedia_setting_href->{$table_name}->{'ChkRecSql'};

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

  my $hash_filename = read_cell_value($dbh_write, 'multimedia', 'HashFileName', 'MultimediaId', $multimedia_id);

  my $dest_storage_path = $ENV{DOCUMENT_ROOT} . '/' . $MULTIMEDIA_STORAGE_PATH . "$table_name";

  my $stored_multimedia_file = "${dest_storage_path}/$hash_filename";

  if (!(-e $stored_multimedia_file)) {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $nb_deleted_file = unlink($stored_multimedia_file);

  if ($nb_deleted_file != 1) {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'DELETE FROM multimedia ';
  $sql   .= 'WHERE MultimediaId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($multimedia_id);

  if ($dbh_write->err()) {

    my $err_msg = 'Unexpected Error';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref  = [{'Message' => "Multimedia ($multimedia_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub add_workflow_runmode {

=pod add_workflow_gadmin_HELP_START
{
"OperationName": "Add workflow",
"Description": "Add a new workflow into the system",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "workflow",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='1' ParaName='WorkflowId' /><Info Message='Workflow (1) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '2', 'ParaName' : 'WorkflowId'}], 'Info' : [{'Message' : 'Workflow (2) has been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error WorkflowType='WorkflowType (11): not found or inactive.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'WorkflowType' : 'WorkflowType (11): not found or inactive.'}]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'workflow', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $workflow_name    = $query->param('WorkflowName');
  my $workflow_type    = $query->param('WorkflowType');
  my $is_active        = $query->param('IsActive');

  my $workflow_note    = undef;

  if (defined $query->param('WorkflowNote')) {

    if (length($query->param('WorkflowNote')) > 0) {

      $workflow_note = $query->param('WorkflowNote');
    }
  }

  my ($chk_bool_err, $bool_href) = check_bool_href( { 'IsActive' => $is_active } );

  if ($chk_bool_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$bool_href]};

    return $data_for_postrun_href;
  }

  my $dbh_k_read = connect_kdb_read();

  if (record_existence($dbh_k_read, 'workflow', 'WorkflowName', $workflow_name)) {

    my $err_msg = "WorkflowName ($workflow_name): already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'WorkflowName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (!type_existence($dbh_k_read, 'workflow', $workflow_type)) {

    my $err_msg = "WorkflowType ($workflow_type): not found or inactive.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'WorkflowType' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $sql = 'INSERT INTO workflow SET ';
  $sql   .= 'WorkflowName=?, ';
  $sql   .= 'WorkflowType=?, ';
  $sql   .= 'WorkflowNote=?, ';
  $sql   .= 'IsActive=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute( $workflow_name, $workflow_type, $workflow_note, $is_active );

  my $workflow_id = -1;
  if (!$dbh_k_write->err()) {

    $workflow_id = $dbh_k_write->last_insert_id(undef, undef, 'workflow', 'WorkflowId');
    $self->logger->debug("WorkflowId: $workflow_id");
  }
  else {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref  = [{'Message' => "Workflow ($workflow_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$workflow_id", 'ParaName' => 'WorkflowId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref,
                                           'ReturnId'  => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_workflow_runmode {

=pod update_workflow_gadmin_HELP_START
{
"OperationName": "Update workflow",
"Description": "Update workflow specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "workflow",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Workflow (3) has been successfully updated.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Workflow (3) has been successfully updated.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Workflow (19): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Workflow (19): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing workflow id"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = $_[0];
  my $query = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'workflow', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $workflow_id        = $self->param('id');
  my $workflow_name      = $query->param('WorkflowName');

  my $workflow_type      = $query->param('WorkflowType');
  my $is_active          = $query->param('IsActive');

  my ($chk_bool_err, $bool_href) = check_bool_href( { 'IsActive'          => $is_active } );

  if ($chk_bool_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$bool_href]};

    return $data_for_postrun_href;
  }

  my $dbh_k_read = connect_kdb_read();

  my $sql = 'SELECT WorkflowId FROM workflow WHERE WorkflowName=? AND WorkflowId<>?';

  my ($r_wf_err, $db_wf_id) = read_cell($dbh_k_read, $sql, [$workflow_name, $workflow_id]);

  if ($r_wf_err) {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_wf_id) > 0) {

    my $err_msg = "WorkflowName ($workflow_name) already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'WorkflowName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (!record_existence( $dbh_k_read, 'workflow', 'WorkflowId', $workflow_id )) {

    my $err_msg = "Workflow ($workflow_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $workflow_note = read_cell_value($dbh_k_read, 'workflow', 'WorkflowNote', 'WorkflowId', $workflow_id);

  if (length($workflow_note) == 0) {

    $workflow_note = undef;
  }

  if (defined $query->param('WorkflowNote')) {

    if (length($query->param('WorkflowNote')) > 0) {

      $workflow_note = $query->param('WorkflowNote');
    }
  }

  if (!type_existence($dbh_k_read, 'workflow', $workflow_type)) {

    my $err_msg = "WorkflowType ($workflow_type): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'WorkflowType' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  $sql    = "UPDATE workflow SET ";
  $sql   .= "WorkflowName=?, ";
  $sql   .= "WorkflowType=?, ";
  $sql   .= "WorkflowNote=?, ";
  $sql   .= "IsActive=? ";
  $sql   .= "WHERE WorkflowId=?";

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute( $workflow_name, $workflow_type, $workflow_note, $is_active, $workflow_id );

  if ( $dbh_k_write->err() ) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("WorkflowId: $workflow_id updated");
  $sth->finish();
  $dbh_k_write->disconnect();

  my $info_msg_aref = [ { 'Message' => "Workflow ($workflow_id) has been successfully updated." } ];

  return {
    'Error'     => 0,
    'Data'      => { 'Info' => $info_msg_aref, },
    'ExtraData' => 0
  };
}

sub del_workflow_runmode {

=pod del_workflow_gadmin_HELP_START
{
"OperationName": "Delete workflow",
"Description": "Delete workflow if it is not used and it does not have any definition.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Workflow (3) has been successfully deleted.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Workflow (4) has been successfully deleted.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='WorkflowId (7): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'WorkflowId (7): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing workflow id."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my ($self) = @_;

  my $data_for_postrun_href = {};

  my $workflow_id  = $self->param('id');

  my $dbh_k_read   = connect_kdb_read();

  my $is_workflow_id_exist = record_existence( $dbh_k_read, 'workflow', 'WorkflowId', $workflow_id );

  if ( !$is_workflow_id_exist ) {

    my $err_msg = "WorkflowId ($workflow_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (record_existence($dbh_k_read, 'trial', 'CurrentWorkflowId', $workflow_id)) {

    my $err_msg = "Workflow ($workflow_id): is used in trial.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (record_existence($dbh_k_read, 'workflowdef', 'WorkflowId', $workflow_id)) {

    my $err_msg = "Workflow ($workflow_id): has definitions.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $sql = "DELETE FROM workflow WHERE WorkflowId=?";
  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($workflow_id);

  if ( $dbh_k_write->err() ) {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("WorkflowId: $workflow_id deleted");
  $sth->finish();
  $dbh_k_write->disconnect();

  my $info_msg_aref = [ { 'Message' => "Workflow ($workflow_id) has been successfully deleted." } ];

  return {
    'Error'     => 0,
    'Data'      => { 'Info' => $info_msg_aref, },
    'ExtraData' => 0
  };
}

sub list_workflow {

  my $self           = $_[0];
  my $extra_attr_yes = $_[1];
  my $sql            = $_[2];

  my $where_para_aref = [];

  if (defined $_[3]) {

    $where_para_aref = $_[3];
  }

  my $count = 0;
  while ($sql =~ /\?/g) {

    $count += 1;
  }

  if ( scalar(@{$where_para_aref}) != $count ) {

    my $msg = 'Number of arguments does not match with ';
    $msg   .= 'number of SQL parameter.';
    return (1, $msg, []);
  }

  my $err = 0;
  my $msg = '';

  my $data_aref = [];

  my $dbh = connect_kdb_read();

  ($err, $msg, $data_aref) = read_data($dbh, $sql, $where_para_aref);

  if ($err) {

    return ($err, $msg, []);
  }

  my $gadmin_status = $self->authen->gadmin_status();

  my $extra_attr_workflow_data = [];

  my $workflow_id_aref      = [];

  my $workflow_def_lookup   = {};

  my $chk_id_err        = 0;
  my $chk_id_msg        = '';
  my $used_id_href      = {};
  my $not_used_id_href  = {};

  if ($extra_attr_yes) {

    for my $workflow_row (@{$data_aref}) {

      push(@{$workflow_id_aref}, $workflow_row->{'WorkflowId'});
    }

    if (scalar(@{$workflow_id_aref}) > 0) {

      my $def_sql = 'SELECT * FROM workflowdef WHERE WorkflowId IN (' . join(',', @{$workflow_id_aref}) . ')';

      my ($wf_def_err, $wf_def_msg, $wf_def_data) = read_data($dbh, $def_sql, []);

      if ($wf_def_err) {

        return ($wf_def_err, $wf_def_msg, []);
      }

      for my $wf_def_row (@{$wf_def_data}) {

        my $wf_id = $wf_def_row->{'WorkflowId'};

        if (defined $workflow_def_lookup->{$wf_id}) {

          my $wf_def_aref = $workflow_def_lookup->{$wf_id};
          push(@{$wf_def_aref}, $wf_def_row);
          $workflow_def_lookup->{$wf_id} = $wf_def_aref;
        }
        else {

          $workflow_def_lookup->{$wf_id} = [$wf_def_row];
        }
      }

      my $chk_table_aref = [{'TableName' => 'workflowdef', 'FieldName' => 'WorkflowId'},
                            {'TableName' => 'trial', 'FieldName' => 'CurrentWorkflowId'}
          ];

      ($chk_id_err, $chk_id_msg,
       $used_id_href, $not_used_id_href) = id_existence_bulk($dbh, $chk_table_aref, $workflow_id_aref);

      if ($chk_id_err) {

        $self->logger->debug("Check id existence error: $chk_id_msg");
        $err = 1;
        $msg = $chk_id_msg;

        return ($err, $msg, []);
      }
    }

    for my $workflow_row (@{$data_aref}) {

      my $workflow_id = $workflow_row->{'WorkflowId'};

      if (defined $workflow_def_lookup->{$workflow_id}) {

        my $wf_def_data = $workflow_def_lookup->{$workflow_id};

        my $wf_def_aref = [];

        for my $wf_def_info (@{$wf_def_data}) {

          if ($gadmin_status eq '1') {

            my $wf_def_id = $wf_def_info->{'WorkflowdefId'};

            $wf_def_info->{'remove'} = "remove/workflowdef/$wf_def_id";
          }

          push(@{$wf_def_aref}, $wf_def_info);
        }

        $workflow_row->{'workflowdef'} = $wf_def_aref;
      }

      if ($gadmin_status eq '1') {

        $workflow_row->{'addDef'} = "workflow/$workflow_id/add/definition";
      }

      push(@{$extra_attr_workflow_data}, $workflow_row);
    }
  }
  else {

    $extra_attr_workflow_data = $data_aref;
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_workflow_data);
}

sub list_workflow_runmode {

=pod list_workflow_HELP_START
{
"OperationName": "List workflow",
"Description": "List all available workflow in the system dictionary.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Workflow WorkflowTypeName='Workflow - 9681075' IsActive='0' addDef='workflow/6/add/definition' WorkflowType='145' WorkflowNote='' WorkflowName='Workflow_8667712' WorkflowId='6' /><RecordMeta TagName='Workflow' /></DATA>",
"SuccessMessageJSON": "{'Workflow' : [{'WorkflowTypeName' : 'Workflow - 9681075', 'WorkflowType' : '145', 'WorkflowNote' : null, 'IsActive' : '0', 'WorkflowName' : 'Workflow_8667712', 'addDef' : 'workflow/6/add/definition', 'WorkflowId' : '6'}], 'RecordMeta' : [{'TagName' : 'Workflow'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;

  my $data_for_postrun_href = {};

  my $sql = 'SELECT workflow.*, generaltype.TypeName AS WorkflowTypeName FROM workflow ';
  $sql   .= 'LEFT JOIN generaltype ON workflow.WorkflowType = generaltype.TypeId ';
  $sql   .= 'ORDER BY WorkflowId DESC';

  my ($read_wf_err, $read_wf_msg, $wf_data) = $self->list_workflow(1, $sql);

  if ($read_wf_err) {

    $self->logger->debug($read_wf_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Workflow'   => $wf_data,
                                           'RecordMeta' => [{'TagName' => 'Workflow'}],
  };

  return $data_for_postrun_href;
}

sub get_workflow_runmode {

=pod get_workflow_HELP_START
{
"OperationName": "Get workflow",
"Description": "Get detailed information about workflow specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Workflow WorkflowTypeName='Workflow - 4466097' WorkflowType='142' WorkflowNote='' WorkflowName='Workflow_0239750' IsActive='0' WorkflowId='1' addDef='workflow/1/add/definition' /><RecordMeta TagName='Workflow' /></DATA>",
"SuccessMessageJSON": "{'Workflow' : [{'WorkflowTypeName' : 'Workflow - 4466097', 'WorkflowType' : '142', 'WorkflowNote' : null, 'IsActive' : '0', 'WorkflowName' : 'Workflow_0239750', 'addDef' : 'workflow/1/add/definition', 'WorkflowId' : '1'}], 'RecordMeta' : [{'TagName' : 'Workflow'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='WorkflowId (11): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'WorkflowId (11): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing workflow id."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;

  my $workflow_id = $self->param('id');
  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();
  my $workflow_exist = record_existence($dbh, 'workflow', 'WorkflowId', $workflow_id);
  $dbh->disconnect();

  if (!$workflow_exist) {

    my $err_msg = "WorkflowId ($workflow_id): not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT workflow.*, generaltype.TypeName AS WorkflowTypeName FROM workflow ';
  $sql   .= 'LEFT JOIN generaltype ON workflow.WorkflowType = generaltype.TypeId ';
  $sql   .= 'WHERE WorkflowId=?';

  my ($read_workflow_err, $read_workflow_msg, $workflow_data) = $self->list_workflow(1, $sql, [$workflow_id]);

  if ($read_workflow_err) {

    $self->logger->debug($read_workflow_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Workflow'       => $workflow_data,
                                           'RecordMeta'     => [{'TagName' => 'Workflow'}],
                                          };

  return $data_for_postrun_href;
}

sub add_workflow_def_runmode {

=pod add_workflow_def_gadmin_HELP_START
{
"OperationName": "Add workflow definition",
"Description": "Add workflow definition.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "workflowdef",
"SkippedField": ["WorkflowId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='1' ParaName='WorkflowdefId' /><Info Message='Workflowdef (1) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '2', 'ParaName' : 'WorkflowdefId'}], 'Info' : [{'Message' : 'Workflowdef (2) has been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='WorkflowId (11): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'WorkflowId (11): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing workflow id."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my ($self) = @_;
  my $query  = $self->query();

  my $data_for_postrun_href = {};

  my $workflow_id  = $self->param('id');

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'WorkflowId' => 1,
                    'StepOrder'  => 1,
                   };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'workflowdef', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $dbh_write   = connect_kdb_write();

  my $is_workflow_id_exist = record_existence( $dbh_write, 'workflow', 'WorkflowId', $workflow_id );

  if ( !$is_workflow_id_exist ) {

    my $err_msg = "WorkflowId ($workflow_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $step_name = $query->param('StepName');

  my $sql = 'SELECT WorkflowdefId FROM workflowdef WHERE WorkflowId=? AND StepName=?';

  my ($r_wf_def_id, $db_wf_def_id) = read_cell($dbh_write, $sql, [$workflow_id, $step_name]);

  if ($r_wf_def_id) {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_wf_def_id) > 0) {

    my $err_msg = "StepName ($step_name): already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'StepName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $step_order = 0;

  if (defined $query->param('StepOrder')) {

    if (length($query->param('StepOrder')) > 0) {

      $step_order = $query->param('StepOrder');
    }
  }

  my ($int_err, $int_err_href) = check_integer_href( {'StepOrder' => $step_order} );

  if ($int_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$int_err_href]};

    return $data_for_postrun_href;
  }

  my $step_note = undef;

  if (defined $query->param('StepNote')) {

    if (length($query->param('StepNote')) > 0) {

      $step_note = $query->param('StepNote');
    }
  }

  $sql  = 'INSERT INTO workflowdef SET ';
  $sql .= 'WorkflowId=?, ';
  $sql .= 'StepName=?, ';
  $sql .= 'StepOrder=?, ';
  $sql .= 'StepNote=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute( $workflow_id, $step_name, $step_order, $step_note );

  my $workflow_def_id = -1;
  if (!$dbh_write->err()) {

    $workflow_def_id = $dbh_write->last_insert_id(undef, undef, 'workflowdef', 'WorkflowdefId');
    $self->logger->debug("WorkflowId: $workflow_id");
  }
  else {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref  = [{'Message' => "Workflowdef ($workflow_def_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$workflow_def_id", 'ParaName' => 'WorkflowdefId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref,
                                           'ReturnId'  => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_workflow_def_runmode {

=pod update_workflow_def_gadmin_HELP_START
{
"OperationName": "Update workflow definition",
"Description": "Update workflow definition details specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "workflowdef",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Workflowdef (3) has been successfully updated.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Workflowdef (3) has been successfully updated.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Workflowdef (21): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Workflowdef (21): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing workflowdef id"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = $_[0];
  my $query = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'WorkflowId' => 1,
                    'StepOrder'  => 1,
                   };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'workflowdef', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $workflow_def_id    = $self->param('id');
  my $step_name          = $query->param('StepName');

  my $dbh_k_read = connect_kdb_read();


  my $read_wfdef_sql   =  'SELECT StepOrder, StepNote, WorkflowId ';
     $read_wfdef_sql  .=  'FROM workflowdef WHERE WorkflowdefId=? ';

  my ($r_df_val_err, $r_df_val_msg, $wfdef_df_val_data) = read_data($dbh_k_read, $read_wfdef_sql, [$workflow_def_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve workflowdef default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $step_order     =  undef;
  my $step_note      =  undef;
  my $workflow_id    =  undef;

  my $nb_df_val_rec    =  scalar(@{$wfdef_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve workflowdef default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $step_order        =   $wfdef_df_val_data->[0]->{'StepOrder'};
  $step_note         =   $wfdef_df_val_data->[0]->{'StepNote'};
  $workflow_id       =   $wfdef_df_val_data->[0]->{'WorkflowId'};

  if (length($step_note) == 0) {

    $step_note = undef;
  }

  if (defined $query->param('StepOrder')) {

    if (length($query->param('StepOrder')) > 0) {

      $step_order = $query->param('StepOrder');
    }
  }

  if (defined $query->param('StepNote')) {

    if (length($query->param('StepNote')) > 0) {

      $step_note = $query->param('StepNote');
    }
  }


  my $sql = 'SELECT WorkflowdefId FROM workflowdef WHERE StepName=? AND WorkflowId=? AND WorkflowdefId<>?';

  my ($r_wf_def_err, $db_wf_def_id) = read_cell($dbh_k_read, $sql, [$step_name, $workflow_id, $workflow_def_id]);

  if ($r_wf_def_err) {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_wf_def_id) > 0) {

    my $err_msg = "StepName ($step_name) already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'StepName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  $sql    = "UPDATE workflowdef SET ";
  $sql   .= "StepName=?, ";
  $sql   .= "StepOrder=?, ";
  $sql   .= "StepNote=? ";
  $sql   .= "WHERE WorkflowdefId=?";

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute( $step_name, $step_order, $step_note, $workflow_def_id );

  if ( $dbh_k_write->err() ) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("WorkflowdefId: $workflow_def_id updated");
  $sth->finish();
  $dbh_k_write->disconnect();

  my $info_msg_aref = [ { 'Message' => "Workflowdef ($workflow_def_id) has been successfully updated." } ];

  return {
    'Error'     => 0,
    'Data'      => { 'Info' => $info_msg_aref, },
    'ExtraData' => 0
  };
}

sub list_workflow_def {

  my $self            = shift;
  my $extra_attr_yes  = shift;
  my $where_clause    = qq{};
  $where_clause       = shift;

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

  my $sql = 'SELECT * FROM workflowdef ';
  $sql   .= $where_clause;
  $sql   .= ' ORDER BY WorkflowdefId DESC';

  my $sth = $dbh->prepare($sql);
  # parameters provided by the caller
  # for example, ('WHERE FieldA=?', '1')
  $sth->execute(@_);

  my $err = 0;
  my $msg = '';
  my $wf_def_data = [];

  if ( !$dbh->err() ) {

    my $array_ref = $sth->fetchall_arrayref({});

    if ( !$sth->err() ) {

      $wf_def_data = $array_ref;
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

  my $gadmin_status = $self->authen->gadmin_status();

  my $extra_attr_wf_def_data = [];

  if ($extra_attr_yes && ($gadmin_status eq '1')) {

    my $wf_def_id_aref = [];

    for my $row (@{$wf_def_data}) {

      push(@{$wf_def_id_aref}, $row->{'WorkflowdefId'});
    }

    my $chk_table_aref = [{'TableName' => 'trialworkflow', 'FieldName' => 'WorkflowdefId'}];

    my ($chk_id_err, $chk_id_msg,
        $used_id_href, $not_used_id_href) = id_existence_bulk($dbh, $chk_table_aref, $wf_def_id_aref);

    if ($chk_id_err) {

      $self->logger->debug("Check id existence error: $chk_id_msg");
      $err = 1;
      $msg = $chk_id_msg;

      return ($err, $msg, []);
    }

    for my $row (@{$wf_def_data}) {

      my $wf_def_id = $row->{'WorkflowdefId'};
      $row->{'update'}   = "update/workflowdef/$wf_def_id";

      if ($not_used_id_href->{$wf_def_id}) {

        $row->{'delete'}   = "delete/workflowdef/$wf_def_id";
      }

      push(@{$extra_attr_wf_def_data}, $row);
    }
  }
  else {

    $extra_attr_wf_def_data = $wf_def_data;
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_wf_def_data);
}

sub list_workflow_def_runmode {

=pod list_workflow_def_HELP_START
{
"OperationName": "List workflow definition",
"Description": "List workflow definition for specified workflow id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='Workflowdef' /><Workflowdef WorkflowdefId='3' StepName='Step_7960440' StepNote='UPDATE - Testing framework' delete='delete/workflowdef/3' update='update/workflowdef/3' WorkflowId='8' StepOrder='1' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'Workflowdef'}], 'Workflowdef' : [{'delete' : 'delete/workflowdef/3', 'update' : 'update/workflowdef/3', 'StepNote' : 'UPDATE - Testing framework', 'StepName' : 'Step_7960440', 'WorkflowdefId' : '3', 'StepOrder' : '1', 'WorkflowId' : '8'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Workflow (4): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Workflow (4): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing workflow id"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self        = shift;
  my $workflow_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  if (!record_existence($dbh, 'workflow', 'WorkflowId', $workflow_id)) {

    my $err_msg = "Workflow ($workflow_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  my ($r_wf_def_err, $r_wf_def_msg, $wf_def_data) = $self->list_workflow_def(1, 'WHERE WorkflowId=?', $workflow_id);

  if ($r_wf_def_err) {

    $self->logger->debug($r_wf_def_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Workflowdef' => $wf_def_data,
                                           'RecordMeta'  => [{'TagName' => 'Workflowdef'}],
  };

  return $data_for_postrun_href;
}

sub get_workflow_def_runmode {

=pod get_workflow_def_HELP_START
{
"OperationName": "Get workflow definition",
"Description": "Get detailed information about workflow definition specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='Workflowdef' /><Workflowdef delete='delete/workflowdef/3' WorkflowdefId='3' StepName='Step_7960440' StepNote='UPDATE - Testing framework' update='update/workflowdef/3' WorkflowId='8' StepOrder='1' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'Workflowdef'}], 'Workflowdef' : [{'delete' : 'delete/workflowdef/3', 'update' : 'update/workflowdef/3', 'StepNote' : 'UPDATE - Testing framework', 'StepName' : 'Step_7960440', 'WorkflowdefId' : '3', 'StepOrder' : '1', 'WorkflowId' : '8'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='WorkflowdefId (6): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'WorkflowdefId (6): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing workflowdef id."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;

  my $workflow_def_id       = $self->param('id');
  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();
  my $workflow_def_exist = record_existence($dbh, 'workflowdef', 'WorkflowdefId', $workflow_def_id);
  $dbh->disconnect();

  if (!$workflow_def_exist) {

    my $err_msg = "WorkflowdefId ($workflow_def_id): not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($r_wf_def_err, $r_wf_def_msg, $wf_def_data) = $self->list_workflow_def(1, 'WHERE WorkflowdefId=?', $workflow_def_id);

  if ($r_wf_def_err) {

    $self->logger->debug($r_wf_def_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Workflowdef'    => $wf_def_data,
                                           'RecordMeta'     => [{'TagName' => 'Workflowdef'}],
                                          };

  return $data_for_postrun_href;
}

sub del_workflow_def_runmode {

=pod del_workflow_def_gadmin_HELP_START
{
"OperationName": "Delete workflow definition",
"Description": "Delete workflow definition if it is not used.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Workflowdef (3) has been successfully deleted.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Workflowdef (6) has been successfully deleted.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='WorkflowdefId (8): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'WorkflowdefId (8): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing workflowdef id."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my ($self) = @_;

  my $data_for_postrun_href = {};

  my $workflow_def_id  = $self->param('id');

  my $dbh_k_read   = connect_kdb_read();

  my $is_workflow_def_id_exist = record_existence( $dbh_k_read, 'workflowdef', 'WorkflowdefId', $workflow_def_id );

  if ( !$is_workflow_def_id_exist ) {

    my $err_msg = "WorkflowdefId ($workflow_def_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (record_existence($dbh_k_read, 'trialworkflow', 'WorkflowdefId', $workflow_def_id)) {

    my $err_msg = "Workflowdef ($workflow_def_id): is used in trialworkflow.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $sql = "DELETE FROM workflowdef WHERE WorkflowdefId=?";
  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($workflow_def_id);

  if ( $dbh_k_write->err() ) {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("WorkflowdefId: $workflow_def_id deleted");
  $sth->finish();
  $dbh_k_write->disconnect();

  my $info_msg_aref = [ { 'Message' => "Workflowdef ($workflow_def_id) has been successfully deleted." } ];

  return {
    'Error'     => 0,
    'Data'      => { 'Info' => $info_msg_aref, },
    'ExtraData' => 0
  };
}

sub get_user_preference_runmode {

=pod get_user_preference_HELP_START
{
"OperationName": "Get User Preference",
"Description": "Get user preference regarding, for example, field list, field description and so on.",
"AuthRequired": 1,
"GroupRequired": 0,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "",
"SuccessMessageJSON": "",
"ErrorMessageXML": [{}],
"ErrorMessageJSON": [{}],
"HTTPParameter": [{"Name": "EntityName", "Required": 0, "Description": "Filtering parameter for the name of entity to which the user preference applies."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = $_[0];
  my $query = $self->query();

  my $entity_name = '';

  if (defined $query->param('EntityName')) {

    if (length($query->param('EntityName')) > 0) {

      $entity_name = $query->param('EntityName');
    }
  }

  my $data_for_postrun_href = {};

  my $user_id = $self->authen->user_id();

  my $dbh = connect_kdb_read();

  my $user_pref_json_txt = read_cell_value($dbh, 'systemuser', 'UserPreference', 'UserId', $user_id);

  $self->logger->debug("User pref json txt: $user_pref_json_txt");

  my $user_pref_aref = [];

  if (length($user_pref_json_txt) > 0) {

    my $user_pref_href = {};

    eval {

      $user_pref_href = decode_json($user_pref_json_txt);
    };

    if ( !($@) ) {

      $self->logger->debug($user_pref_href->{'genotype'});

      if (length($entity_name) > 0) {

        if (defined $user_pref_href->{$entity_name}) {

          push(@{$user_pref_aref}, {$entity_name => $user_pref_href->{$entity_name}});
        }
      }
      else {

        push(@{$user_pref_aref}, $user_pref_href);
      }
    }
    else {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }
  }

  $dbh->disconnect();

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'UserPreference'  => $user_pref_aref,
                                           'RecordMeta'      => [{'TagName' => 'UserPreference'}],
  };
  $data_for_postrun_href->{'JSONONLY'}  = 1;

  return $data_for_postrun_href;
}

sub update_user_preference_runmode {

=pod update_user_preference_HELP_START
{
"OperationName": "Update User Preference",
"Description": "Update user preference regarding, for example, field list, field description and so on.",
"AuthRequired": 1,
"GroupRequired": 0,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "",
"SuccessMessageJSON": "",
"ErrorMessageXML": [{}],
"ErrorMessageJSON": [{}],
"HTTPParameter": [{"Name": "UserPreference", "Required": 1, "Description": "Hash JSON string for the user preference"}, {"Name": "EntityName", "Required": 1, "Description": "Name of entity to which the user preference applies."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = $_[0];
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $user_id = $self->authen->user_id();

  my $user_pref_json_txt = $query->param('UserPreference');
  my $entity_name        = lc($query->param('EntityName'));

  my ($missing_err, $missing_href) = check_missing_href( {'UserPreference' => $user_pref_json_txt,
                                                          'EntityName'     => $entity_name,
                                                         } );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  if ($entity_name != /\w+/) {

    my $err_msg = "EntityName ($entity_name): invalid character.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'EntityName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $user_pref_href = {};

  eval {

    $user_pref_href = decode_json($user_pref_json_txt);
  };

  if ( $@ ) {

    my $err_msg = "Invalid JSON string";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'UserPreference' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_write = connect_kdb_write();

  my $db_user_pref_json_txt = read_cell_value($dbh_write, 'systemuser', 'UserPreference', 'UserId', $user_id);

  my $db_user_pref_href = {};

  if (length($db_user_pref_json_txt) > 0) {

    eval {

      $db_user_pref_href = decode_json($db_user_pref_json_txt);
    };

    if ( $@ ) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }
  }

  $db_user_pref_href->{$entity_name} = $user_pref_href;

  my $final_json_txt = '';

  eval {

    $final_json_txt = encode_json($db_user_pref_href);
  };

  if ( $@ ) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $sql = 'UPDATE systemuser SET ';
  $sql   .= 'UserPreference=? ';
  $sql   .= 'WHERE UserId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($final_json_txt, $user_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "User preference for user ($user_id) on entity ($entity_name) been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
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

sub add_keyword_runmode {

=pod add_keyword_gadmin_HELP_START
{
"OperationName": "Add keyword",
"Description": "Add a new keyword into the system",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "keyword",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='1' ParaName='KeywordId' /><Info Message='Keyword (1) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '2', 'ParaName' : 'KeywordId'}], 'Info' : [{'Message' : 'Keyword (2) has been added successfully.'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'keyword', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $keyword_name    = $query->param('KeywordName');

  my $keyword_note    = undef;

  if (defined $query->param('KeywordNote')) {

    if (length($query->param('KeywordNote')) > 0) {

      $keyword_note = $query->param('KeywordNote');
    }
  }

  my $operator_id = undef;

  my $dbh_k_read = connect_kdb_read();

  my $user_id = $self->authen->user_id();

  my $uniq_name_sql = 'SELECT KeywordId FROM keyword WHERE KeywordName=?';
  my @uniq_name_arg = ($keyword_name);

  if (defined $query->param('OperatorId')) {

    if (length($query->param('OperatorId')) > 0) {

      $operator_id = $query->param('OperatorId');

      if ( ! record_existence($dbh_k_read, 'systemuser', 'UserId', $operator_id) ) {

        my $err_msg = "Operator ($operator_id): not found.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'OperatorId' => $err_msg}]};

        return $data_for_postrun_href;
      }

      $uniq_name_sql .= ' AND OperatorId=?';
      push(@uniq_name_arg, $operator_id);
    }
  }

  $uniq_name_sql .= ' LIMIT 1';

  my ($uniq_name_err, $db_keyword_id) = read_cell($dbh_k_read, $uniq_name_sql, \@uniq_name_arg);

  if ($uniq_name_err) {

    $self->logger->debug("Read unique keyword name failed");
    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'KeywordName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_keyword_id) > 0) {

    my $err_msg = "KeywordName ($keyword_name): already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'KeywordName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $sql = 'INSERT INTO keyword SET ';
  $sql   .= 'KeywordName=?, ';
  $sql   .= 'KeywordNote=?, ';
  $sql   .= 'OperatorId=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute( $keyword_name, $keyword_note, $operator_id );

  my $keyword_id = -1;
  if (!$dbh_k_write->err()) {

    $keyword_id = $dbh_k_write->last_insert_id(undef, undef, 'keyword', 'KeywordId');
    $self->logger->debug("KeywordId: $keyword_id");
  }
  else {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref  = [{'Message' => "Keyword ($keyword_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$keyword_id", 'ParaName' => 'KeywordId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref,
                                           'ReturnId'  => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_keyword_runmode {

=pod update_keyword_gadmin_HELP_START
{
"OperationName": "Update keyword",
"Description": "Update keyword specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "keyword",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Keyword (3) has been successfully updated.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Keyword (3) has been successfully updated.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Keyword (19): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Keyword (19): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing keyword id"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = $_[0];
  my $query = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'keyword', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $keyword_id        = $self->param('id');
  my $keyword_name      = $query->param('KeywordName');

  my $dbh_k_read = connect_kdb_read();

  if (!record_existence( $dbh_k_read, 'keyword', 'KeywordId', $keyword_id )) {

    my $err_msg = "Keyword ($keyword_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $operator_id = read_cell_value($dbh_k_read, 'keyword', 'OperatorId', 'KeywordId', $keyword_id);

  if (length($operator_id) == 0) {

    $operator_id = 'NULL';
  }

  if (defined $query->param('OperatorId')) {

    if (length($query->param('OperatorId')) > 0) {

      $operator_id = $query->param('OperatorId');
    }
  }

  my $sql = 'SELECT KeywordId FROM keyword WHERE KeywordName=? AND KeywordId<>?';
  my $sql_arg_aref = [$keyword_name, $keyword_id];

  if ("$operator_id" ne 'NULL') {

    $sql .= ' AND OperatorId=?';
    push(@{$sql_arg_aref}, $operator_id);

    if ( ! record_existence($dbh_k_read, 'systemuser', 'UserId', $operator_id) ) {

      my $err_msg = "Operator ($operator_id): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'OperatorId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my ($r_kwd_err, $db_kwd_id) = read_cell($dbh_k_read, $sql, $sql_arg_aref);

  if ($r_kwd_err) {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_kwd_id) > 0) {

    my $err_msg = "KeywordName ($keyword_name) already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'KeywordName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $keyword_note = read_cell_value($dbh_k_read, 'keyword', 'KeywordNote', 'KeywordId', $keyword_id);

  if (length($keyword_note) == 0) {

    $keyword_note = undef;
  }

  if (defined $query->param('KeywordNote')) {

    if (length($query->param('KeywordNote')) > 0) {

      $keyword_note = $query->param('KeywordNote');
    }
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  $sql    = "UPDATE keyword SET ";
  $sql   .= "KeywordName=?, ";
  $sql   .= "KeywordNote=?, ";
  $sql   .= "OperatorId=$operator_id ";
  $sql   .= "WHERE KeywordId=?";

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute( $keyword_name, $keyword_note, $keyword_id );

  if ( $dbh_k_write->err() ) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("KeywordId: $keyword_id updated");
  $sth->finish();
  $dbh_k_write->disconnect();

  my $info_msg_aref = [ { 'Message' => "Keyword ($keyword_id) has been successfully updated." } ];

  return {
    'Error'     => 0,
    'Data'      => { 'Info' => $info_msg_aref, },
    'ExtraData' => 0
  };
}

sub list_keyword {

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

  #$self->logger->debug("Number of records: " . scalar(@{$data_aref}));

  my $extra_attr_kwd_data = [];

  my $gadmin_status = $self->authen->gadmin_status();

  if ($extra_attr_yes && ($gadmin_status eq '1')) {

    my $kwd_id_aref = [];

    for my $row (@{$data_aref}) {

      push(@{$kwd_id_aref}, $row->{'KeywordId'});
    }

    if (scalar(@{$kwd_id_aref}) > 0) {

      my $chk_table_aref = [{'TableName' => 'keywordgroupentry', 'FieldName' => 'KeywordId'},
                            {'TableName' => 'trialunitkeyword', 'FieldName' => 'KeywordId'},
                            {'TableName' => 'specimenkeyword', 'FieldName' => 'KeywordId'}
                           ];

      my ($chk_id_err, $chk_id_msg,
          $used_id_href, $not_used_id_href) = id_existence_bulk($dbh, $chk_table_aref, $kwd_id_aref);

      if ($chk_id_err) {

        $self->logger->debug("Check id existence error: $chk_id_msg");
        $err = 1;
        $msg = $chk_id_msg;
      }
      else {

        for my $row (@{$data_aref}) {

          my $kwd_id = $row->{'KeywordId'};
          $row->{'update'}   = "update/keyword/$kwd_id";

          # delete link only if this keyword isn't used
          if ( $not_used_id_href->{$kwd_id} ) {

            $row->{'delete'}   = "delete/keyword/$kwd_id";
          }

          push(@{$extra_attr_kwd_data}, $row);
        }
      }
    }
  }
  else {

    $extra_attr_kwd_data = $data_aref;
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_kwd_data);
}

sub list_keyword_advanced_runmode {

=pod list_keyword_advanced_HELP_START
{
"OperationName": "List keyword(s)",
"Description": "Return a list of keywords currently present in the system.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination NumOfRecords='1' NumOfPages='1' Page='1' NumPerPage='10' /><RecordMeta TagName='Keyword' /><Keyword KeywordId='1' KeywordName='Keyword_5247457' delete='delete/keyword/1' KeywordNote='' update='update/keyword/1' /></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfRecords' : '1', 'NumOfPages' : 1, 'NumPerPage' : '10', 'Page' : '1'}], 'RecordMeta' : [{'TagName' : 'Keyword'}], 'Keyword' : [{'KeywordId' : '1', 'delete' : 'delete/keyword/1', 'KeywordName' : 'Keyword_5247457', 'KeywordNote' : null, 'update' : 'update/keyword/1'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"URLParameter": [{"ParameterName": "nperpage", "Description": "Number of records in a page for pagination"}, {"ParameterName": "num", "Description": "The page number of the pagination"}],
"HTTPParameter": [{"Required": 0, "Name": "Filtering", "Description": "Filtering parameter string consisting of filtering expressions which are separated by ampersand (&) which needs to be encoded if HTTP GET method is used. Each filtering expression is composed of a database field name, a filtering operator and the filtering value."}, {"Required": 0, "Name": "FieldList", "Description": "Comma separated value of wanted fields."}, {"Required": 0, "Name": "Sorting", "Description": "Comma separated value of SQL sorting phrases."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $pagination  = 0;
  my $nb_per_page = -1;
  my $page        = -1;

  $self->logger->debug("Base dir: $main::kddart_base_dir");

  if ( (defined $self->param('nperpage')) && (defined $self->param('num')) ) {

    $pagination  = 1;
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

  $self->logger->debug("Filtering csv: $filtering_csv");

  my $sorting = '';

  if (defined $query->param('Sorting')) {

    $sorting = $query->param('Sorting');
  }

  my $dbh = connect_kdb_read();

  my $sql = 'SELECT * FROM keyword LIMIT 1';

  my ($sam_kwd_err, $sam_kwd_msg, $sam_kwd_data) = $self->list_keyword(0, $sql);

  if ($sam_kwd_err) {

    $self->logger->debug($sam_kwd_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $sample_data_aref = $sam_kwd_data;

  my @field_list_all;

  if (scalar(@{$sample_data_aref}) == 1) {

    @field_list_all = keys(%{$sample_data_aref->[0]});
  }
  else {

    $self->logger->debug("It reaches here");
    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'keyword');

    if ($sfield_err) {

      $self->logger->debug("Get static field failed: $sfield_msg");
      return $self->_set_error();
    }

    for my $sfield_rec (@{$sfield_data}) {

      push(@field_list_all, $sfield_rec->{'Name'});
    }

    for my $pkey_field (@{$pkey_data}) {

      push(@field_list_all, $pkey_field);
    }
  }

  $self->logger->debug("Field list all: " . join(',', @field_list_all));

  my $final_field_list = \@field_list_all;

  if (length($field_list_csv) > 0) {

    my ($sel_field_err, $sel_field_msg, $sel_field_list) = parse_selected_field($field_list_csv,
                                                                                $final_field_list,
                                                                                'KeywordId');

    if ($sel_field_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;
  }

  my $sql_field_lookup = {};

  for my $field_name (@{$final_field_list}) {

    $sql_field_lookup->{$field_name} = 1;
  }

  my $other_join = '';

  if ($sql_field_lookup->{'OperatorId'}) {

    $other_join = ' LEFT JOIN systemuser ON keyword.OperatorId = systemuser.UserId ';
    push(@{$final_field_list}, 'systemuser.UserName AS OperatorUserName');
  }

  $sql  = 'SELECT ' . join(',', @{$final_field_list}) . ' ';
  $sql .= 'FROM keyword ';
  $sql .= $other_join;

  my ( $filter_err, $filter_msg, $filter_phrase, $where_arg ) = parse_filtering('KeywordId',
                                                                                'keyword',
                                                                                $filtering_csv,
                                                                                $final_field_list);
  if ($filter_err) {

    $self->logger->debug("Parse filtering failed: $filter_msg");
    my $err_msg = $filter_msg;

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $filtering_exp = '';

  if (length($filter_phrase) > 0) {

    $filtering_exp = " WHERE $filter_phrase ";
  }

  $sql .= " $filtering_exp ";

  my $pagination_aref    = [];
  my $paged_limit_clause = '';
  my $paged_limit_elapsed;

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

    $self->logger->debug("Filtering expression: $filtering_exp");

    my ($pg_id_err, $pg_id_msg, $nb_records,
        $nb_pages, $limit_clause, $rcount_time);

    $self->logger->debug("COUNT NB RECORD: NO FACTOR IN FILTERING");

    ($pg_id_err, $pg_id_msg, $nb_records,
     $nb_pages, $limit_clause, $rcount_time) = get_paged_filter($dbh,
                                                                $nb_per_page,
                                                                $page,
                                                                'keyword',
                                                                'KeywordId',
                                                                $filtering_exp,
                                                                $where_arg);

    $self->logger->debug("SQL Row count time: $rcount_time");

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

  $dbh->disconnect();

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

    $sql .= ' ORDER BY keyword.KeywordId DESC';
  }

  $sql .= " $paged_limit_clause ";

  $self->logger->debug("SQL with VCol: $sql");
  $self->logger->debug("Where arg: " . join(',', @{$where_arg}));

  # where_arg here in the list function because of the filtering 
  my ($read_kwd_err, $read_kwd_msg, $kwd_data) = $self->list_keyword(1, $sql, $where_arg);

  if ($read_kwd_err) {

    $self->logger->debug($read_kwd_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Keyword'      => $kwd_data,
                                           'Pagination'   => $pagination_aref,
                                           'RecordMeta'   => [{'TagName' => 'Keyword'}],
  };

  return $data_for_postrun_href;
}

sub get_keyword_runmode {

=pod get_keyword_HELP_START
{
"OperationName": "Get keyword",
"Description": "Get detailed information about keyword specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='Keyword' /><Keyword KeywordId='1' KeywordName='Keyword_5247457' delete='delete/keyword/1' KeywordNote='' update='update/keyword/1' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'Keyword'}], 'Keyword' : [{'KeywordId' : '1', 'delete' : 'delete/keyword/1', 'KeywordName' : 'Keyword_5247457', 'KeywordNote' : null, 'update' : 'update/keyword/1'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='KeywordId (11): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'KeywordId (11): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing keyword id."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;

  my $keyword_id = $self->param('id');
  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();
  my $keyword_exist = record_existence($dbh, 'keyword', 'KeywordId', $keyword_id);
  $dbh->disconnect();

  if (!$keyword_exist) {

    my $err_msg = "KeywordId ($keyword_id): not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT * FROM keyword ';
  $sql   .= 'WHERE KeywordId=?';

  my ($read_keyword_err, $read_keyword_msg, $keyword_data) = $self->list_keyword(1, $sql, [$keyword_id]);

  if ($read_keyword_err) {

    $self->logger->debug($read_keyword_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Keyword'        => $keyword_data,
                                           'RecordMeta'     => [{'TagName' => 'Keyword'}],
                                          };

  return $data_for_postrun_href;
}

sub del_keyword_runmode {

=pod del_keyword_gadmin_HELP_START
{
"OperationName": "Delete keyword",
"Description": "Delete keyword if it is not used and it is not part of any grouping.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Keyword (3) has been successfully deleted.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Keyword (4) has been successfully deleted.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='KeywordId (7): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'KeywordId (7): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing keyword id."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my ($self) = @_;

  my $data_for_postrun_href = {};

  my $keyword_id  = $self->param('id');

  my $dbh_k_read   = connect_kdb_read();

  my $is_keyword_id_exist = record_existence( $dbh_k_read, 'keyword', 'KeywordId', $keyword_id );

  if ( !$is_keyword_id_exist ) {

    my $err_msg = "KeywordId ($keyword_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (record_existence($dbh_k_read, 'keywordgroupentry', 'KeywordId', $keyword_id)) {

    my $err_msg = "Keyword ($keyword_id): part of a group.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (record_existence($dbh_k_read, 'trialunitkeyword', 'KeywordId', $keyword_id)) {

    my $err_msg = "Keyword ($keyword_id): used in trialunit.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (record_existence($dbh_k_read, 'specimenkeyword', 'KeywordId', $keyword_id)) {

    my $err_msg = "Keyword ($keyword_id): used in specimen.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $sql = "DELETE FROM keyword WHERE KeywordId=?";
  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($keyword_id);

  if ( $dbh_k_write->err() ) {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("KeywordId: $keyword_id deleted");
  $sth->finish();
  $dbh_k_write->disconnect();

  my $info_msg_aref = [ { 'Message' => "Keyword ($keyword_id) has been successfully deleted." } ];

  return {
    'Error'     => 0,
    'Data'      => { 'Info' => $info_msg_aref, },
    'ExtraData' => 0
  };
}

sub add_keyword_group_runmode {

=pod add_keyword_group_gadmin_HELP_START
{
"OperationName": "Add keyword group",
"Description": "Add a new keyword group.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "keywordgroup",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='7' ParaName='KeywordGroupId' /><Info Message='KeywordGroup (7) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '8','ParaName' : 'KeywordGroupId'}],'Info' : [{'Message' : 'KeywordGroup (8) has been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='KeywordId (97): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'KeywordId (97): not found.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "XML",
"UploadFileParameterName": "uploadfile",
"DTDFileNameForUploadXML": "keywordgroup.dtd",
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'keywordgroup', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $keyword_group_name         = $query->param('KeywordGroupName');

  my $dbh_write = connect_kdb_write();

  my $operator_id = undef;

  my $user_id = $self->authen->user_id();

  my $uniq_name_sql = 'SELECT KeywordGroupId FROM keywordgroup WHERE KeywordGroupName=?';
  my @uniq_name_arg = ($keyword_group_name);

  if (defined $query->param('OperatorId')) {

    if (length($query->param('OperatorId')) > 0) {

      $operator_id = $query->param('OperatorId');

      if ( ! record_existence($dbh_write, 'systemuser', 'UserId', $operator_id) ) {

        my $err_msg = "Operator ($operator_id): not found.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'OperatorId' => $err_msg}]};

        return $data_for_postrun_href;
      }

      $uniq_name_sql .= ' AND OperatorId=?';
      push(@uniq_name_arg, $operator_id);
    }
  }

  $uniq_name_sql .= ' LIMIT 1';

  my ($uniq_name_err, $db_keyword_group_id) = read_cell($dbh_write, $uniq_name_sql, \@uniq_name_arg);

  if ($uniq_name_err) {

    $self->logger->debug("Read unique keyword group name failed");
    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'KeywordName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_keyword_group_id) > 0) {

    my $err_msg = "KeywordGroupName ($keyword_group_name): already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'KeywordGroupName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $keyword_info_xml_file = $self->authen->get_upload_file();
  my $keyword_info_dtd_file = $self->get_keyword_group_dtd_file();

  add_dtd($keyword_info_dtd_file, $keyword_info_xml_file);

  my $xml_checker_parser = new XML::Checker::Parser( Handlers => { } );

  eval {

    local $XML::Checker::FAIL = sub {

      my $code = shift;
      my $err_str = XML::Checker::error_string ($code, @_);
      $self->logger->debug("XML Parsing ERR: $code : $err_str");
      die $err_str;
    };
    $xml_checker_parser->parsefile($keyword_info_xml_file);
  };

  if ($@) {

    my $err_msg = $@;
    $self->logger->debug("Parsing XML error: $err_msg");
    my $user_err_msg = "Keyword group xml file does not comply with its definition.\n";
    $user_err_msg   .= "Details: $err_msg";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $user_err_msg}]};

    return $data_for_postrun_href;
  }

  my $keyword_info_xml  = read_file($keyword_info_xml_file);
  my $keyword_info_aref = xml2arrayref($keyword_info_xml, 'keywordgroupentry');

  my $uniq_kwd_id_href = {};

  for my $keyword_info (@{$keyword_info_aref}) {

    my $kwd_id = $keyword_info->{'KeywordId'};

    if (defined $uniq_kwd_id_href->{$kwd_id}) {

      my $err_msg = "Keyword ($kwd_id): duplicate.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    else {

      $uniq_kwd_id_href->{$kwd_id} = 1;
    }
  }

  my @kwd_id_list = keys(%{$uniq_kwd_id_href});

  if (scalar(@kwd_id_list) > 0) {

    my $keyword_sql = 'SELECT KeywordId ';
    $keyword_sql   .= 'FROM keyword ';
    $keyword_sql   .= 'WHERE KeywordId IN (' . join(',', @kwd_id_list) . ') ';

    my $keyword_lookup = $dbh_write->selectall_hashref($keyword_sql, 'KeywordId');

    if ($dbh_write->err()) {

      $self->logger->debug("SELECT keyword failed: " . $dbh_write->errstr());

      my $err_msg = "Unexpected Error.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $not_found_keyword_id_aref = [];

    for my $kwd_id (@kwd_id_list) {

      if ( !(defined $keyword_lookup->{$kwd_id}) ) {

        push(@{$not_found_keyword_id_aref}, $kwd_id);
      }
    }

    if (scalar(@{$not_found_keyword_id_aref}) > 0) {

      my $err_msg = "Keyword (" . join(',', @{$not_found_keyword_id_aref}) . "): not found";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $sql = 'INSERT INTO keywordgroup SET ';
  $sql   .= 'KeywordGroupName=?, OperatorId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($keyword_group_name, $operator_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  my $keyword_group_id = $dbh_write->last_insert_id(undef, undef, 'keywordgroup', 'KeywordGroupId');

  $sql  = "INSERT INTO keywordgroupentry(KeywordGroupId,KeywordId) VALUES ";

  my @kwd_grp_entry_sql_list;

  for my $keyword_info (@{$keyword_info_aref}) {

    my $keyword_id   = $keyword_info->{'KeywordId'};

    my $sql_list = qq|($keyword_group_id, $keyword_id)|;

    push(@kwd_grp_entry_sql_list, $sql_list);
  }

  $sql .= join(',', @kwd_grp_entry_sql_list);

  $self->logger->debug("SQL: $sql");

  $sth = $dbh_write->prepare($sql);
  $sth->execute();

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref  = [{'Message' => "KeywordGroup ($keyword_group_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$keyword_group_id", 'ParaName' => 'KeywordGroupId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_keyword_group_runmode {

=pod update_keyword_group_gadmin_HELP_START
{
"OperationName": "Update keyword group",
"Description": "Update information about keyword group specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "keywordgroup",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='KeywordGroup (9) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'KeywordGroup (9) has been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='KeywordGroup (10) not found.' /></DATA>" }],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'KeywordGroup (10) not found.'}]}" }],
"URLParameter": [{"ParameterName": "id", "Description": "Existing KeywordGroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self            = shift;
  my $keyword_grp_id  = $self->param('id');
  my $query           = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'keywordgroup', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $dbh_write = connect_kdb_write();

  my $keyword_grp_exist = record_existence($dbh_write, 'keywordgroup', 'KeywordGroupId', $keyword_grp_id);

  if (!$keyword_grp_exist) {

    my $err_msg = "KeywordGroup ($keyword_grp_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $keyword_group_name         = $query->param('KeywordGroupName');

  my $operator_id = read_cell_value($dbh_write, 'keywordgroup', 'OperatorId',
                                    'KeywordGroupId', $keyword_grp_id);

  if (length($operator_id) == 0) {

    $operator_id = 'NULL';
  }

  if (defined $query->param('OperatorId')) {

    if (length($query->param('OperatorId')) > 0) {

      $operator_id = $query->param('OperatorId');
    }
  }

  my $sql = 'SELECT KeywordGroupId FROM keywordgroup WHERE KeywordGroupName=? AND KeywordGroupId<>?';
  my $sql_arg_aref = [$keyword_group_name, $keyword_grp_id];

  if ("$operator_id" ne 'NULL') {

    $sql .= ' AND OperatorId=?';
    push(@{$sql_arg_aref}, $operator_id);

    if ( ! record_existence($dbh_write, 'systemuser', 'UserId', $operator_id) ) {

      my $err_msg = "Operator ($operator_id): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'OperatorId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my ($r_kwd_grp_err, $db_kwd_grp_id) = read_cell($dbh_write, $sql, $sql_arg_aref);

  if ($r_kwd_grp_err) {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_kwd_grp_id) > 0) {

    my $err_msg = "KeywordGroupName ($keyword_group_name) already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'KeywordGroupName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql    = "UPDATE keywordgroup SET ";
  $sql   .= "KeywordGroupName=?, OperatorId=$operator_id ";
  $sql   .= 'WHERE KeywordGroupId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($keyword_group_name, $keyword_grp_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "KeywordGroup ($keyword_grp_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_keyword_group {

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

  #$self->logger->debug("Number of records: " . scalar(@{$data_aref}));

  my $extra_attr_kwd_grp_data = [];

  my $gadmin_status = $self->authen->gadmin_status();

  if ($extra_attr_yes && ($gadmin_status eq '1')) {

    for my $row (@{$data_aref}) {

      my $kwd_grp_id = $row->{'KeywordGroupId'};
      $row->{'update'}     = "update/keywordgroup/$kwd_grp_id";
      $row->{'delete'}     = "delete/keywordgroup/$kwd_grp_id";
      $row->{'addKeyword'} = "keywordgroup/$kwd_grp_id/add/keyword/bulk";

      push(@{$extra_attr_kwd_grp_data}, $row);
    }
  }
  else {

    $extra_attr_kwd_grp_data = $data_aref;
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_kwd_grp_data);
}

sub list_keyword_group_runmode {

=pod list_keyword_group_advanced_HELP_START
{
"OperationName": "List keyword group(s)",
"Description": "Return a list of keyword groups currently present in the system.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination NumOfRecords='4' NumOfPages='4' Page='1' NumPerPage='1' /><KeywordGroup KeywordGroupName='UPDATE Keyword_8149578' KeywordGroupId='4' delete='delete/keywordgroup/4' update='update/keywordgroup/4' /><RecordMeta TagName='KeywordGroup' /></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfRecords' : '4', 'NumOfPages' : 4, 'NumPerPage' : '1', 'Page' : '1'}], 'KeywordGroup' : [{'KeywordGroupName' : 'UPDATE Keyword_8149578', 'KeywordGroupId' : '4', 'delete' : 'delete/keywordgroup/4', 'update' : 'update/keywordgroup/4'}], 'RecordMeta' : [{'TagName' : 'KeywordGroup'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"URLParameter": [{"ParameterName": "nperpage", "Description": "Number of records in a page for pagination"}, {"ParameterName": "num", "Description": "The page number of the pagination"}],
"HTTPParameter": [{"Required": 0, "Name": "Filtering", "Description": "Filtering parameter string consisting of filtering expressions which are separated by ampersand (&) which needs to be encoded if HTTP GET method is used. Each filtering expression is composed of a database field name, a filtering operator and the filtering value."}, {"Required": 0, "Name": "FieldList", "Description": "Comma separated value of wanted fields."}, {"Required": 0, "Name": "Sorting", "Description": "Comma separated value of SQL sorting phrases."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $pagination  = 0;
  my $nb_per_page = -1;
  my $page        = -1;

  $self->logger->debug("Base dir: $main::kddart_base_dir");

  if ( (defined $self->param('nperpage')) && (defined $self->param('num')) ) {

    $pagination  = 1;
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

  $self->logger->debug("Filtering csv: $filtering_csv");

  my $sorting = '';

  if (defined $query->param('Sorting')) {

    $sorting = $query->param('Sorting');
  }

  my $dbh = connect_kdb_read();

  my $sql = 'SELECT * FROM keywordgroup LIMIT 1';

  my ($sam_kwd_grp_err, $sam_kwd_grp_msg, $sam_kwd_grp_data) = $self->list_keyword_group(0, $sql);

  if ($sam_kwd_grp_err) {

    $self->logger->debug($sam_kwd_grp_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $sample_data_aref = $sam_kwd_grp_data;

  my @field_list_all;

  if (scalar(@{$sample_data_aref}) == 1) {

    @field_list_all = keys(%{$sample_data_aref->[0]});
  }
  else {

    $self->logger->debug("It reaches here");
    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'keywordgroup');

    if ($sfield_err) {

      $self->logger->debug("Get static field failed: $sfield_msg");
      return $self->_set_error();
    }

    for my $sfield_rec (@{$sfield_data}) {

      push(@field_list_all, $sfield_rec->{'Name'});
    }

    for my $pkey_field (@{$pkey_data}) {

      push(@field_list_all, $pkey_field);
    }
  }

  $self->logger->debug("Field list all: " . join(',', @field_list_all));

  my $final_field_list = \@field_list_all;

  if (length($field_list_csv) > 0) {

    my ($sel_field_err, $sel_field_msg, $sel_field_list) = parse_selected_field($field_list_csv,
                                                                                $final_field_list,
                                                                                'KeywordGroupId');

    if ($sel_field_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;
  }

  my $sql_field_lookup = {};

  for my $field_name (@{$final_field_list}) {

    $sql_field_lookup->{$field_name} = 1;
  }

  my $other_join = '';

  if ($sql_field_lookup->{'OperatorId'}) {

    $other_join = ' LEFT JOIN systemuser ON keywordgroup.OperatorId = systemuser.UserId ';
    push(@{$final_field_list}, 'systemuser.UserName AS OperatorUserName');
  }

  $sql  = 'SELECT ' . join(',', @{$final_field_list}) . ' ';
  $sql .= 'FROM keywordgroup ';
  $sql .= $other_join;

  my ( $filter_err, $filter_msg, $filter_phrase, $where_arg ) = parse_filtering('KeywordGroupId',
                                                                                'keywordgroup',
                                                                                $filtering_csv,
                                                                                $final_field_list);
  if ($filter_err) {

    $self->logger->debug("Parse filtering failed: $filter_msg");
    my $err_msg = $filter_msg;

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $filtering_exp = '';

  if (length($filter_phrase) > 0) {

    $filtering_exp = " WHERE $filter_phrase ";
  }

  $sql .= " $filtering_exp ";

  my $pagination_aref    = [];
  my $paged_limit_clause = '';
  my $paged_limit_elapsed;

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

    $self->logger->debug("Filtering expression: $filtering_exp");

    my ($pg_id_err, $pg_id_msg, $nb_records,
        $nb_pages, $limit_clause, $rcount_time);

    $self->logger->debug("COUNT NB RECORD: NO FACTOR IN FILTERING");

    ($pg_id_err, $pg_id_msg, $nb_records,
     $nb_pages, $limit_clause, $rcount_time) = get_paged_filter($dbh,
                                                                $nb_per_page,
                                                                $page,
                                                                'keywordgroup',
                                                                'KeywordGroupId',
                                                                $filtering_exp,
                                                                $where_arg);

    $self->logger->debug("SQL Row count time: $rcount_time");

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

  $dbh->disconnect();

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

    $sql .= ' ORDER BY keywordgroup.KeywordGroupId DESC';
  }

  $sql .= " $paged_limit_clause ";

  $self->logger->debug("SQL with VCol: $sql");
  $self->logger->debug("Where arg: " . join(',', @{$where_arg}));

  # where_arg here in the list function because of the filtering 
  my ($read_kwd_grp_err, $read_kwd_grp_msg, $kwd_grp_data) = $self->list_keyword_group(1, $sql, $where_arg);

  if ($read_kwd_grp_err) {

    $self->logger->debug($read_kwd_grp_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'KeywordGroup' => $kwd_grp_data,
                                           'Pagination'   => $pagination_aref,
                                           'RecordMeta'   => [{'TagName' => 'KeywordGroup'}],
  };

  return $data_for_postrun_href;
}

sub get_keyword_group_runmode {

=pod get_keyword_group_HELP_START
{
"OperationName": "Get keyword group",
"Description": "Get detailed information about keyword group specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='KeywordGroup' /><Keyword KeywordGroupName='UPDATE Keyword_8149578' KeywordGroupId='4' delete='delete/keywordgroup/4' update='update/keywordgroup/4' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'KeywordGroup'}], 'Keyword' : [{'KeywordGroupName' : 'UPDATE Keyword_8149578', 'KeywordGroupId' : '4', 'delete' : 'delete/keywordgroup/4', 'update' : 'update/keywordgroup/4'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='KeywordGroupId (11): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'KeywordGroupId (11): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing keyword group id."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;

  my $kwd_grp_id = $self->param('id');
  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();
  my $kwd_grp_exist = record_existence($dbh, 'keywordgroup', 'KeywordGroupId', $kwd_grp_id);
  $dbh->disconnect();

  if (!$kwd_grp_exist) {

    my $err_msg = "KeywordGroupId ($kwd_grp_id): not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT * FROM keywordgroup ';
  $sql   .= 'WHERE KeywordGroupId=?';

  my ($read_kwd_grp_err, $read_kwd_grp_msg, $kwd_grp_data) = $self->list_keyword_group(1, $sql, [$kwd_grp_id]);

  if ($read_kwd_grp_err) {

    $self->logger->debug($read_kwd_grp_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'KeywordGroup'   => $kwd_grp_data,
                                           'RecordMeta'     => [{'TagName' => 'KeywordGroup'}],
                                          };

  return $data_for_postrun_href;
}

sub add_keyword2group_bulk_runmode {

=pod add_keyword2group_bulk_gadmin_HELP_START
{
"OperationName": "Add keyword to a group",
"Description": "Add a keyword to a keywordgroup.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='2 keyword(s) has been added to keywordgroup (4) successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : '2 keyword(s) has been added to keywordgroup (4) successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='KeywordId (97): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'KeywordId (97): not found.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "XML",
"UploadFileParameterName": "uploadfile",
"DTDFileNameForUploadXML": "keywordgroup.dtd",
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;

  my $kwd_grp_id = $self->param('id');
  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();
  my $kwd_grp_exist = record_existence($dbh, 'keywordgroup', 'KeywordGroupId', $kwd_grp_id);
  $dbh->disconnect();

  if (!$kwd_grp_exist) {

    my $err_msg = "KeywordGroupId ($kwd_grp_id): not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $keyword_info_xml_file = $self->authen->get_upload_file();
  my $keyword_info_dtd_file = $self->get_keyword_group_dtd_file();

  add_dtd($keyword_info_dtd_file, $keyword_info_xml_file);

  my $xml_checker_parser = new XML::Checker::Parser( Handlers => { } );

  eval {

    local $XML::Checker::FAIL = sub {

      my $code = shift;
      my $err_str = XML::Checker::error_string ($code, @_);
      $self->logger->debug("XML Parsing ERR: $code : $err_str");
      die $err_str;
    };
    $xml_checker_parser->parsefile($keyword_info_xml_file);
  };

  if ($@) {

    my $err_msg = $@;
    $self->logger->debug("Parsing XML error: $err_msg");
    my $user_err_msg = "Keyword group xml file does not comply with its definition.\n";
    $user_err_msg   .= "Details: $err_msg";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $user_err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_write = connect_kdb_write();

  my $keyword_info_xml  = read_file($keyword_info_xml_file);
  my $keyword_info_aref = xml2arrayref($keyword_info_xml, 'keywordgroupentry');

  my $uniq_kwd_id_href = {};

  for my $keyword_info (@{$keyword_info_aref}) {

    my $kwd_id = $keyword_info->{'KeywordId'};

    if (defined $uniq_kwd_id_href->{$kwd_id}) {

      my $err_msg = "Keyword ($kwd_id): duplicate.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    else {

      $uniq_kwd_id_href->{$kwd_id} = 1;
    }
  }

  my @kwd_id_list = keys(%{$uniq_kwd_id_href});

  if (scalar(@kwd_id_list) > 0) {

    my $keyword_sql = 'SELECT KeywordId ';
    $keyword_sql   .= 'FROM keyword ';
    $keyword_sql   .= 'WHERE KeywordId IN (' . join(',', @kwd_id_list) . ') ';

    my $keyword_lookup = $dbh_write->selectall_hashref($keyword_sql, 'KeywordId');

    if ($dbh_write->err()) {

      $self->logger->debug("SELECT keyword failed: " . $dbh_write->errstr());

      my $err_msg = "Unexpected Error.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $not_found_keyword_id_aref = [];

    for my $kwd_id (@kwd_id_list) {

      if ( !(defined $keyword_lookup->{$kwd_id}) ) {

        push(@{$not_found_keyword_id_aref}, $kwd_id);
      }
    }

    if (scalar(@{$not_found_keyword_id_aref}) > 0) {

      my $err_msg = "Keyword (" . join(',', @{$not_found_keyword_id_aref}) . "): not found";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    $keyword_sql  = qq|SELECT KeywordId FROM keywordgroupentry |;
    $keyword_sql .= qq|WHERE KeywordGroupId=$kwd_grp_id AND KeywordId IN (| . join(',', @kwd_id_list) . ')';

    $keyword_lookup = $dbh_write->selectall_hashref($keyword_sql, 'KeywordId');

    if ($dbh_write->err()) {

      $self->logger->debug("SELECT keyword failed: " . $dbh_write->errstr());

      my $err_msg = "Unexpected Error.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $already_in_group_aref = [];

    for my $kwd_id (@kwd_id_list) {

      if ( defined $keyword_lookup->{$kwd_id} ) {

        push(@{$already_in_group_aref}, $kwd_id);
      }
    }

    if (scalar(@{$already_in_group_aref}) > 0) {

      my $err_msg = "Keyword (" . join(',', @{$already_in_group_aref}) . "): already in keywordgroup ($kwd_grp_id).";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $sql = "INSERT INTO keywordgroupentry(KeywordGroupId,KeywordId) VALUES ";

  my @kwd_grp_entry_sql_list;

  for my $keyword_info (@{$keyword_info_aref}) {

    my $keyword_id   = $keyword_info->{'KeywordId'};

    my $sql_list = qq|($kwd_grp_id, $keyword_id)|;

    push(@kwd_grp_entry_sql_list, $sql_list);
  }

  my $nb_keyword = scalar(@kwd_grp_entry_sql_list);
  $sql .= join(',', @kwd_grp_entry_sql_list);

  $self->logger->debug("SQL: $sql");

  my $sth = $dbh_write->prepare($sql);
  $sth->execute();

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref  = [{'Message' => "$nb_keyword keyword(s) has been added to keywordgroup ($kwd_grp_id) successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_keyword_in_group {

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

  #$self->logger->debug("Number of records: " . scalar(@{$data_aref}));

  my $extra_attr_kwd_data = [];

  my $gadmin_status = $self->authen->gadmin_status();

  if ($extra_attr_yes && ($gadmin_status eq '1')) {

    for my $row (@{$data_aref}) {

      my $kwd_id     = $row->{'KeywordId'};
      my $kwd_grp_id = $row->{'KeywordGroupId'};
      $row->{'removeKeyword'} = "keywordgroup/$kwd_grp_id/remove/keyword/$kwd_id";

      push(@{$extra_attr_kwd_data}, $row);
    }

  }
  else {

    $extra_attr_kwd_data = $data_aref;
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_kwd_data);
}

sub list_keyword_in_group_runmode {

=pod list_keyword_in_group_HELP_START
{
"OperationName": "List keyword(s) in the specified group",
"Description": "Listing keywords in the group specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><KeywordGroupEntry KeywordGroupEntryId='5' removeKeyword='keywordgroup/4/remove/keyword/8' KeywordId='8' KeywordGroupId='4' KeywordName='Keyword_2667243' />RecordMeta TagName='KeywordGroupEntry' /></DATA>",
"SuccessMessageJSON": "{'KeywordGroupEntry' : [{'removeKeyword' : 'keywordgroup/4/remove/keyword/8', 'KeywordGroupEntryId' : '5', 'KeywordId' : '8', 'KeywordGroupId' : '4', 'KeywordName' : 'Keyword_2667243'}], 'RecordMeta' : [{'TagName' : 'KeywordGroupEntry'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='KeywordGroupId (11): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'KeywordGroupId (11): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing keyword group id."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;

  my $kwd_grp_id = $self->param('id');
  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();
  my $kwd_grp_exist = record_existence($dbh, 'keywordgroup', 'KeywordGroupId', $kwd_grp_id);
  $dbh->disconnect();

  if (!$kwd_grp_exist) {

    my $err_msg = "KeywordGroupId ($kwd_grp_id): not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT keywordgroupentry.*, keyword.KeywordName ';
  $sql   .= 'FROM keywordgroupentry ';
  $sql   .= 'LEFT JOIN keyword ON keywordgroupentry.KeywordId=keyword.KeywordId ';
  $sql   .= 'WHERE KeywordGroupId=?';

  my ($read_kwd_grp_entry_err, $read_kwd_grp_entry_msg, $kwd_grp_entry_data) = $self->list_keyword_in_group(1, $sql,
                                                                                                            [$kwd_grp_id]);

  if ($read_kwd_grp_entry_err) {

    $self->logger->debug($read_kwd_grp_entry_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'KeywordGroupEntry'     => $kwd_grp_entry_data,
                                           'RecordMeta'            => [{'TagName' => 'KeywordGroupEntry'}],
                                          };

  return $data_for_postrun_href;
}

sub remove_keyword_from_group_runmode {

=pod remove_keyword_from_group_gadmin_HELP_START
{
"OperationName": "Remove keyword from group",
"Description": "Remove specified keyword from keywordgroup specified by ids",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Keyword (18) has been removed from keywordgroup (6) successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Keyword (18) has been removed from keywordgroup (7) successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='KeywordGroupId (7): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'KeywordGroupId (7): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing keyword group id."}, {"ParameterName": "id", "Description": "keyword id which is part of the keyword group."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my ($self) = @_;

  my $data_for_postrun_href = {};

  my $kwd_grp_id  = $self->param('id');
  my $kwd_id      = $self->param('kwdid');

  my $dbh_k_read   = connect_kdb_read();

  if ( !record_existence( $dbh_k_read, 'keywordgroup', 'KeywordGroupId', $kwd_grp_id ) ) {

    my $err_msg = "KeywordGroupId ($kwd_grp_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT KeywordGroupEntryId FROM keywordgroupentry WHERE KeywordGroupId=? AND KeywordId=?';

  my ($r_kwd_grp_entry_err, $db_kwd_grp_entry_id) = read_cell($dbh_k_read, $sql, [$kwd_grp_id, $kwd_id]);

  if (length($db_kwd_grp_entry_id) == 0) {

    my $err_msg = "KeywordId ($kwd_id): not found in keywordgroup ($kwd_grp_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("KeywordGroupEntryId: $db_kwd_grp_entry_id");

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  $sql = "DELETE FROM keywordgroupentry WHERE KeywordGroupEntryId=?";
  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($db_kwd_grp_entry_id);

  if ( $dbh_k_write->err() ) {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sth->finish();
  $dbh_k_write->disconnect();

  my $info_msg_aref = [ { 'Message' => "Keyword ($kwd_id) has been removed from keywordgroup ($kwd_grp_id) successfully." } ];

  return {
    'Error'     => 0,
    'Data'      => { 'Info' => $info_msg_aref, },
    'ExtraData' => 0
  };
}

sub del_keyword_group_runmode {

=pod del_keyword_group_gadmin_HELP_START
{
"OperationName": "Delete keyword group",
"Description": "Delete keyword group if it does not have any member keyword.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='KeywordGroup (3) has been successfully deleted.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'KeywordGroup (4) has been successfully deleted.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='KeywordGroupId (7): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'KeywordGroupId (7): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing keyword group id."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my ($self) = @_;

  my $data_for_postrun_href = {};

  my $kwd_grp_id  = $self->param('id');

  my $dbh_k_read   = connect_kdb_read();

  if ( !record_existence( $dbh_k_read, 'keywordgroup', 'KeywordGroupId', $kwd_grp_id ) ) {

    my $err_msg = "KeywordGroupId ($kwd_grp_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (record_existence($dbh_k_read, 'keywordgroupentry', 'KeywordGroupId', $kwd_grp_id)) {

    my $err_msg = "KeywordGroup ($kwd_grp_id): still has member keyword(s).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $sql = "DELETE FROM keywordgroup WHERE KeywordGroupId=?";
  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($kwd_grp_id);

  if ( $dbh_k_write->err() ) {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("KeywordGroupId: $kwd_grp_id deleted");
  $sth->finish();
  $dbh_k_write->disconnect();

  my $info_msg_aref = [ { 'Message' => "KeywordGroup ($kwd_grp_id) has been successfully deleted." } ];

  return {
    'Error'     => 0,
    'Data'      => { 'Info' => $info_msg_aref, },
    'ExtraData' => 0
  };
}

sub update_group_runmode {

=pod update_group_gadmin_HELP_START
{
"OperationName": "Update group",
"Description": "Update existing system group.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "systemgroup",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Group (2) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Group (2) has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Group (3) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Group (3) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing GroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self     = shift;
  my $group_id = $self->param('id');
  my $query    = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'systemgroup', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $group_name   = $query->param('SystemGroupName');
  my $group_desc   = $query->param('SystemGroupDescription');

  my $dbh_write = connect_kdb_write();

  my $group_exist = record_existence($dbh_write, 'systemgroup', 'SystemGroupId', $group_id);

  if (!$group_exist) {

    my $err_msg = "Group ($group_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT SystemGroupId FROM systemgroup WHERE SystemGroupId <> ? AND SystemGroupName = ?';

  my ($r_grp_err, $db_grp_id) = read_cell($dbh_write, $sql, [$group_id, $group_name]);

  if ($r_grp_err) {

    $self->logger->debug("Checking if group name already exists failed.");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  if (length($db_grp_id) > 0) {

    my $err_msg = "Group ($group_name) already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'SystemGroupName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql    = 'UPDATE systemgroup SET ';
  $sql   .= 'SystemGroupName=?, ';
  $sql   .= 'SystemGroupDescription=? ';
  $sql   .= 'WHERE SystemGroupId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($group_name, $group_desc, $group_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "Group ($group_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub get_unique_number_runmode {

=pod get_unique_number_HELP_START
{
"OperationName": "Get Unique Number",
"Description": "Ask DAL to give a KDDart unique number that can be used in naming convention",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><StatInfo ServerElapsedTime='0.039' Unit='second'/><ReturnId ParaName='UniqueNumberId' Value='12'/><Info Message='Unique number is generated successfully.'/></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'ParaName' : 'UniqueNumberId','Value' : '13'}],'StatInfo' : [{'ServerElapsedTime' : '0.027','Unit' : 'second'}],'Info' : [{'Message' : 'Unique number is generated successfully.'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.'}]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = shift;

  my $data_for_postrun_href = {};

  my $dbh_write = connect_kdb_write();

  my $sql = 'INSERT INTO uniquenumber SET ';
  $sql   .= 'UniqueNumberId=0';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute();

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  my $unique_number = $dbh_write->last_insert_id(undef, undef, 'uniquenumber', 'UniqueNumberId');

  $dbh_write->disconnect();

  my $info_msg_aref  = [{'Message' => "Unique number is generated successfully."}];
  my $return_id_aref = [{'Value' => "$unique_number", 'ParaName' => 'UniqueNumberId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref,
                                           'ReturnId'  => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_nursery_type_list_csv_runmode {

=pod update_nursery_type_list_csv_gadmin_HELP_START
{
"OperationName": "Update the csv list of nursery trial types",
"Description": "Update the csv list of nursery trial types.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><StatInfo Unit='second' ServerElapsedTime='0.008' /><Info Message='NUSERY_TYPE_LIST_CSV has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'NUSERY_TYPE_LIST_CSV has been updated successfully.'}],'StatInfo' : [{'ServerElapsedTime' : '0.008','Unit' : 'second'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.'}]}"}],
"HTTPParameter": [{"Required": 1, "Name": "NurseryTypeListCSV", "Description": "Comma separated value of trial type id to be set as nursery types."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $nursery_type_list_csv = $query->param('NurseryTypeListCSV');

  my $data_for_postrun_href = {};

  if (length($nursery_type_list_csv) == 0) {

    my $err_msg = "NurseryTypeListCSV is missing.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'NurseryTypeListCSV' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ($nursery_type_list_csv !~ /(\d+,?)+/) {

    my $err_msg = "NurseryTypeListCSV must be comma separated value of unsigned integer.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'NurseryTypeListCSV' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my @nursery_type_list = split(',', $nursery_type_list_csv);

  my $uniq_nursery_type_href = {};

  foreach my $type_id (@nursery_type_list) {

    if (defined $uniq_nursery_type_href->{$type_id}) {

      my $err_msg = "Type ($type_id) is duplicate in $nursery_type_list_csv.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'NurseryTypeListCSV' => $err_msg}]};

      return $data_for_postrun_href;
    }
    else {

      $uniq_nursery_type_href->{$type_id} = 1;
    }
  }

  my $dbh = connect_kdb_read();

  my ($chk_trial_type_id_err, $unfound_trial_type_id_csv) = type_existence_csv($dbh, 'trial',
                                                                               $nursery_type_list_csv);

  if ($chk_trial_type_id_err) {


    my $err_msg = "Type ($unfound_trial_type_id_csv): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'NurseryTypeListCSV' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  my $config_file_path = $CFG_FILE_PATH;


  my $cfg = new Config::Simple($config_file_path);

  my $document_root = $ENV{DOCUMENT_ROOT};
  my $base_dir      = $main::kddart_base_dir;

  my $config_param_name = $document_root;
  $config_param_name =~ s/${base_dir}\///g;

  $cfg->param( -block => "NURSERY_TYPE_LIST_CSV",
               -value => { "$config_param_name" => "$nursery_type_list_csv" } );

  $cfg->save();

  load_config();

  my $info_msg_aref  = [{'Message' => "NUSERY_TYPE_LIST_CSV has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};

  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_genotype_config_runmode {

=pod update_genotype_config_gadmin_HELP_START
{
"OperationName": "Update DAL genotype creation setting",
"Description": "Update DAL configuration which controls the required privilege level for genotype creation.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><StatInfo ServerElapsedTime='0.007' Unit='second' /><Info Message='Creating genotype privilege setting has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'StatInfo' : [{'ServerElapsedTime' : '0.007','Unit' : 'second'}],'Info' : [{'Message' : 'Creating genotype privilege setting has been updated successfully.'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.'}]}"}],
"HTTPParameter": [{"Required": 1, "Name": "GenotypeConfig", "Description": "Setting which must be either ANY, GADMIN or ADMIN."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $user_id = $self->authen->user_id;

  if ( "$user_id" ne '0' ) {

    my $err_msg = "Permission denied: user not admin.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $genotype_config = $query->param('GenotypeConfig');

  if (length($genotype_config) == 0) {

    my $err_msg = "GenotypeConfig is missing.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'GenotypeConfig' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ($genotype_config !~ /^ADMIN|GADMIN|ANY$/i) {

    my $err_msg = "GenotypeConfig ($genotype_config): invalid.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'GenotypeConfig' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $config_file_path = $CFG_FILE_PATH;

  my $cfg = new Config::Simple($config_file_path);

  my $document_root = $ENV{DOCUMENT_ROOT};
  my $base_dir      = $main::kddart_base_dir;

  my $config_param_name = $document_root;
  $config_param_name =~ s/${base_dir}\///g;

  $cfg->param( -block => "WHO_CAN_CREATE_GENOTYPE",
               -value => { "$config_param_name" => uc("$genotype_config") } );

  $cfg->save();

  load_config();

  my $info_msg_aref  = [{'Message' => "Creating genotype privilege setting has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};

  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub get_keyword_group_dtd_file {

  my $dtd_path = $ENV{DOCUMENT_ROOT} . '/' . $DTD_PATH;

  return "${dtd_path}/keywordgroup.dtd";
}

sub logger {

  my $self = shift;
  return $self->{logger};
}

1;
