#$Id$
#$Author$

# Copyright (c) 2011, Diversity Arrays Technology, All rights reserved.

# Author    : Rakesh Kumar Shardiwal
# Created   : 19/05/2012
# Modified  :
# Purpose   :
#
#

package KDDArT::DAL::TrialEvent;

use strict;
use warnings;
use Data::Dumper;

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
use feature qw(switch);

sub setup {

  my $self   = shift;

  CGI::Session->name("KDDArT_DAL_SESSID");

  __PACKAGE__->authen->init_config_parameters();
  
  __PACKAGE__->authen->init_config_parameters();
  __PACKAGE__->authen->check_login_runmodes(':all');
  __PACKAGE__->authen->check_content_type_runmodes(':all');
  __PACKAGE__->authen->check_rand_runmodes('add_trialevent',
                                           'update_trialevent',
                                           'del_trialevent_gadmin',
      );
  __PACKAGE__->authen->count_session_request_runmodes(':all');
  
  __PACKAGE__->authen->check_signature_runmodes('add_trialevent',
                                                'update_trialevent',
                                                'del_trialevent_gadmin',
      );
  __PACKAGE__->authen->check_gadmin_runmodes('del_trialevent_gadmin');
  __PACKAGE__->authen->check_sign_upload_runmodes();

  my $logger = get_logger();
  Log::Log4perl::MDC->put('client_ip', $ENV{'REMOTE_ADDR'});

  if ( !$logger->has_appenders() ) {

    my $app = Log::Log4perl::Appender->new( "Log::Log4perl::Appender::Screen", utf8 => undef );

    my $layout = Log::Log4perl::Layout::PatternLayout->new("[%d] [%H] [%X{client_ip}] [%p] [%F{1}:%L] [%M] [%m]%n");

    $app->layout($layout);
    $logger->add_appender($app);
  }

  $logger->level($DEBUG);
  $self->{logger} = $logger;

  $self->authen->config( LOGIN_URL => '' );
  $self->session_config( CGI_SESSION_OPTIONS => [ "driver:File", $self->query, { Directory => $SESSION_STORAGE_PATH } ], );

  $self->run_modes(
    'add_trialevent'           => 'add_trialevent_runmode',
    'update_trialevent'        => 'update_trialevent_runmode',
    'get_trialevent'           => 'get_trialevent_runmode',
    'list_trialevent'          => 'list_trialevent_runmode',
    'del_trialevent_gadmin'    => 'del_trialevent_runmode',
      );
}

sub list_trialevent {

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

  my $dbh = connect_kdb_read();
  my $sth = $dbh->prepare($sql);

  $sth->execute(@{$where_para_aref});

  my $err = 0;
  my $msg = '';
  my $trialevent_data = [];

  if ( !$dbh->err() ) {

    my $array_ref = $sth->fetchall_arrayref({});

    if ( !$sth->err() ) {

      $trialevent_data = $array_ref;
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

  my $extra_attr_trialevent_data = [];

  if ($extra_attr_yes) {

    my $gadmin_status = $self->authen->gadmin_status();

    for my $row (@{$trialevent_data}) {

      my $trial_perm = $row->{'UltimatePerm'};

      if ( ($trial_perm & $WRITE_PERM) == $WRITE_PERM ) {

        my $trialevent_id = $row->{'TrialEventId'};
        $row->{'update'} = "update/trialevent/$trialevent_id";

        if ($gadmin_status eq '1') {

          $row->{'delete'} = "delete/trialevent/$trialevent_id";
        }
      }

      push(@{$extra_attr_trialevent_data}, $row);
    }
  }
  else {

    $extra_attr_trialevent_data = $trialevent_data;
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_trialevent_data);
}

sub list_trialevent_runmode {

=pod list_trialevent_HELP_START
{
"OperationName" : "List trial events for trial",
"Description": "List trial events for a trial specified by trial id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><TrialEvent TrialEventDate='2012-08-16 00:00:00' TrialEventValue='TEST' TrialEventUnit='' OperatorId='0' TrialEventNote='' EventTypeId='20' OperatorUserName='admin' TrialEventId='1' TrialName='Trial_9046042' EventTypeName='TEvent - 6830311' delete='delete/trialevent/1' update='update/trialevent/1' UltimatePerm='7' TrialId='2' /><RecordMeta TagName='TrialEvent' /></DATA>",
"SuccessMessageJSON": "{'VCol' : [], 'TrialEvent' : [{'TrialEventUnit' : null, 'TrialEventValue' : 'TEST', 'TrialEventDate' : '2012-08-16 00:00:00', 'OperatorId' : '0', 'EventTypeId' : '20', 'TrialEventNote' : '', 'OperatorUserName' : 'admin', 'TrialEventId' : '1', 'TrialName' : 'Trial_9046042', 'EventTypeName' : 'TEvent - 6830311', 'delete' : 'delete/trialevent/1', 'update' : 'update/trialevent/1', 'TrialId' : '2', 'UltimatePerm' : '7'}], 'RecordMeta' : [{'TagName' : 'TrialEvent'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"URLParameter": [{"ParameterName": "trialid", "Description": "Existing TrialId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self          = shift;

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'trial');

  my $trial_id;
  my $where_args = [];

  if (defined $self->param('trialid')) {

    $trial_id = $self->param('trialid');
    my $trial_existence = record_existence($dbh, 'trial', 'TrialId', $trial_id);

    if (!$trial_existence) {

      my $err_msg = "Trial ($trial_id): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $perm_sql  = "SELECT $perm_str AS UltimatePermission ";
    $perm_sql    .= 'FROM trial ';
    $perm_sql    .= 'WHERE LOWER(TrialId)=?';

    my ($read_err, $permission) = read_cell($dbh, $perm_sql, [$trial_id]);

    if ( ($permission & $READ_PERM) != $READ_PERM ) {

      my $err_msg = "Trial ($trial_id): permission denied.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    push(@{$where_args}, $trial_id);
  }

  my $field_list = ['trialevent.*', 'VCol*', 'trial.TrialId', 'trial.TrialName', 'generalunit.UnitName',
                    "$perm_str AS UltimatePerm",
                    'generaltype.TypeName AS EventTypeName',
                    'systemuser.UserName AS OperatorUserName',
      ];

  my $other_join = ' LEFT JOIN trial ON trialevent.TrialId = trial.TrialId ';
  $other_join   .= ' LEFT JOIN generaltype ON trialevent.EventTypeId = generaltype.TypeId ';
  $other_join   .= ' LEFT JOIN systemuser ON trialevent.OperatorId = systemuser.UserId ';
  $other_join   .= ' LEFT JOIN generalunit ON trialevent.UnitId = generalunit.UnitId ';

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $field_list, 'trialevent',
                                                                        'TrialEventId', $other_join);

  if (defined $trial_id) {

    $sql =~ s/GROUP BY/ WHERE (($perm_str & $READ_PERM) = $READ_PERM) AND trial.TrialId=? GROUP BY /;
  }
  else {

    $sql =~ s/GROUP BY/ WHERE ($perm_str & $READ_PERM) = $READ_PERM GROUP BY /;
  }

  $sql .= " ORDER BY trialevent.TrialEventId DESC";

  $dbh->disconnect();

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("SQL with VCol: $sql");

  my ($read_trialevent_err, $read_trialevent_msg, $trialevent_data) = $self->list_trialevent(1, $sql, $where_args);

  if ($read_trialevent_err) {

    $self->logger->debug($read_trialevent_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'TrialEvent'  => $trialevent_data,
                                           'VCol'        => $vcol_list,
                                           'RecordMeta'  => [{'TagName' => 'TrialEvent'}],
  };

  return $data_for_postrun_href;
}

sub get_trialevent_runmode {

=pod get_trialevent_HELP_START
{
"OperationName" : "Get trial event",
"Description": "Get detailed information for a trial event specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><TrialEvent TrialEventDate='2012-08-16 00:00:00' TrialEventValue='TEST' TrialEventUnit='' OperatorId='0' TrialEventNote='' EventTypeId='20' OperatorUserName='admin' TrialEventId='1' TrialName='Trial_9046042' EventTypeName='TEvent - 6830311' delete='delete/trialevent/1' update='update/trialevent/1' UltimatePerm='7' TrialId='2' /><RecordMeta TagName='TrialEvent' /></DATA>",
"SuccessMessageJSON": "{'VCol' : [], 'TrialEvent' : [{'TrialEventUnit' : null, 'TrialEventValue' : 'TEST', 'TrialEventDate' : '2012-08-16 00:00:00', 'OperatorId' : '0', 'EventTypeId' : '20', 'TrialEventNote' : '', 'OperatorUserName' : 'admin', 'TrialEventId' : '1', 'TrialName' : 'Trial_9046042', 'EventTypeName' : 'TEvent - 6830311', 'delete' : 'delete/trialevent/1', 'update' : 'update/trialevent/1', 'TrialId' : '2', 'UltimatePerm' : '7'}], 'RecordMeta' : [{'TagName' : 'TrialEvent'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TrialEvent (5): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'TrialEvent (5): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialEventId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self          = shift;
  my $trialevent_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  my $trial_id = read_cell_value($dbh, 'trialevent', 'TrialId', 'TrialEventId', $trialevent_id);

  if (length($trial_id) == 0) {

    my $err_msg = "TrialEvent ($trialevent_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'trial');

  my $perm_sql  = "SELECT $perm_str AS UltimatePermission ";
  $perm_sql    .= 'FROM trial ';
  $perm_sql    .= 'WHERE LOWER(TrialId)=?';

  my ($read_err, $permission) = read_cell($dbh, $perm_sql, [$trial_id]);

  if ( ($permission & $READ_PERM) != $READ_PERM ) {

    my $err_msg = "Trial ($trial_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $field_list = ['trialevent.*', 'VCol*', 'trial.TrialName', 'generalunit.UnitName',
                    "$perm_str AS UltimatePerm",
                    'generaltype.TypeName AS EventTypeName',
                    'systemuser.UserName AS OperatorUserName',
      ];

  my $other_join = ' LEFT JOIN trial ON trialevent.TrialId = trial.TrialId ';
  $other_join   .= ' LEFT JOIN generaltype ON trialevent.EventTypeId = generaltype.TypeId ';
  $other_join   .= ' LEFT JOIN systemuser ON trialevent.OperatorId = systemuser.UserId ';
  $other_join   .= ' LEFT JOIN generalunit ON trialevent.UnitId = generalunit.UnitId ';

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $field_list, 'trialevent',
                                                                        'TrialEventId', $other_join);

  $sql  =~ s/GROUP BY/ WHERE trialevent.TrialEventId=? AND ($perm_str & $READ_PERM) = $READ_PERM GROUP BY /;
  $sql .= " ORDER BY trialevent.TrialEventId DESC";

  $dbh->disconnect();

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("SQL with VCol: $sql");

  my ($read_trialevent_err, $read_trialevent_msg, $trialevent_data) = $self->list_trialevent(1, $sql, [$trialevent_id]);

  if ($read_trialevent_err) {

    $self->logger->debug($read_trialevent_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'TrialEvent'  => $trialevent_data,
                                           'VCol'       => $vcol_list,
                                           'RecordMeta' => [{'TagName' => 'TrialEvent'}],
  };

  return $data_for_postrun_href;
}

sub del_trialevent_runmode {

=pod del_trialevent_gadmin_HELP_START
{
"OperationName" : "Delete trial event",
"Description": "Delete trial event specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='TrialEventId (1) has been successfully deleted.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'TrialEventId (2) has been successfully deleted.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TrialEvent (2): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'TrialEvent (2): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialEventId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my ( $self )      = @_;
  my $trialevent_id = $self->param('id');

  my $dbh = connect_kdb_read();

  my $trial_id = read_cell_value($dbh, 'trialevent', 'TrialId', 'TrialEventId', $trialevent_id);

  if (length($trial_id) == 0) {

    my $err_msg = "TrialEvent ($trialevent_id): not found.";
    return $self->_set_error($err_msg);
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'trial');
  my $sql      = '';

  $sql  = "SELECT $perm_str AS UltimatePermission ";
  $sql .= 'FROM trial ';
  $sql .= 'WHERE LOWER(TrialId)=?';

  my ($read_err, $permission) = read_cell($dbh, $sql, [$trial_id]);

  if ( ($permission & $READ_WRITE_PERM) != $READ_WRITE_PERM ) {

    my $err_msg = "Trial ($trial_id): permission denied.";
    return $self->_set_error($err_msg);
  }

  $dbh->disconnect();

  my $dbh_k_write = connect_kdb_write();

  $sql    = "DELETE FROM trialeventfactor WHERE TrialEventId=?";
  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($trialevent_id);

  if ( $dbh_k_write->err() ) {

    return $self->_set_error();
  }

  $sql = "DELETE FROM trialevent WHERE TrialEventId=?";
  $sth = $dbh_k_write->prepare($sql);
  $sth->execute($trialevent_id);

  if ( $dbh_k_write->err() ) {

    return $self->_set_error();
  }

  $self->logger->debug("TrialEventId: $trialevent_id deleted");
  $sth->finish();
  $dbh_k_write->disconnect();

  my $info_msg_aref = [ { 'Message' => "TrialEventId ($trialevent_id) has been successfully deleted." } ];

  return {
    'Error'     => 0,
    'Data'      => { 'Info' => $info_msg_aref, },
    'ExtraData' => 0
  };
}

sub add_trialevent_runmode {

=pod add_trialevent_HELP_START
{
"OperationName" : "Add trial event",
"Description": "Define a new trial event for a trial specified by trial id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"SkippedField": ["TrialId", "OperatorId"],
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "trialevent",
"KDDArTFactorTable": "trialeventfactor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='4' ParaName='TrialEventId' /><Info Message='TrialEventId (4) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '5', 'ParaName' : 'TrialEventId'}], 'Info' : [{'Message' : 'TrialEventId (5) has been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TrialId (35): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'TrialId (35): not found.'}]}"}],
"URLParameter": [{"ParameterName": "trialid", "Description": "Existing TrialId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = $_[0];

  my $trialevent_trialid   = $self->param('trialid');
  my $query                = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'TrialId'    => 1,
                    'OperatorId' => 1,
  };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'trialevent', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $trialevent_typeid           = $query->param('EventTypeId');
  my $trialevent_trialevent_value = $query->param('TrialEventValue');
  my $trialevent_trialevent_date  = $query->param('TrialEventDate');
  my $unit_id                     = $query->param('UnitId');

  my $trialevent_trialevent_note  = '';

  if (defined $query->param('TrialEventNote')) {

    $trialevent_trialevent_note  = $query->param('TrialEventNote');
  }

  my $trialevent_operatorid       = $self->authen->user_id();

  my ( $te_date_err, $te_date_href ) = check_dt_href( { 'TrialEventDate' => $trialevent_trialevent_date } );

  if ($te_date_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$te_date_href]};

    return $data_for_postrun_href;
  }

  my $dbh_k_write = connect_kdb_write();

  if (!type_existence($dbh_k_write, 'trialevent', $trialevent_typeid)) {

    my $err_msg = "EventTypeId ($trialevent_typeid): not found or inactive.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'EventTypeId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (!record_existence($dbh_k_write, 'generalunit', 'UnitId', $unit_id)) {

    my $err_msg = "UnitId ($unit_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'UnitId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id  = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str  = permission_phrase($group_id, 0, $gadmin_status);

  my $sql      = "SELECT $perm_str AS UltimatePermission ";
  $sql        .= 'FROM trial ';
  $sql        .= 'WHERE TrialId=?';

  my ($read_err, $trial_permission) = read_cell($dbh_k_write, $sql, [$trialevent_trialid]);

  if (length($trial_permission) == 0) {

    my $err_msg = "TrialId ($trialevent_trialid): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }
  else {

    if ( ($trial_permission & $READ_WRITE_PERM) != $READ_WRITE_PERM ) {

      my $err_msg = "TrialId ($trialevent_trialid): permission denied.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  # Get the virtual col from the factor table

  my $vcol_sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength ";
  $vcol_sql   .= "FROM factor WHERE TableNameOfFactor='trialeventfactor'";

  my $vcol_data              = $dbh_k_write->selectall_hashref($vcol_sql, 'FactorId');
  my $vcol_param_data        = {};
  my $vcol_len_info          = {};
  my $vcol_param_data_maxlen = {};

  for my $vcol_id ( keys( %{$vcol_data} ) ) {

    my $vcol_param_name = "VCol_${vcol_id}";
    my $vcol_value      = $query->param($vcol_param_name);

    if ( $vcol_data->{$vcol_id}->{'CanFactorHaveNull'} != 1 ) {

      $vcol_param_data->{$vcol_param_name} = $vcol_value;
    }
    $vcol_len_info->{$vcol_param_name}          = $vcol_data->{$vcol_id}->{'FactorValueMaxLength'};
    $vcol_param_data_maxlen->{$vcol_param_name} = $vcol_value;
  }

  # Validate virtual column for factor
  my ( $vcol_missing_err, $vcol_missing_msg ) = check_missing_value($vcol_param_data);

  if ($vcol_missing_err) {

    $vcol_missing_msg = $vcol_missing_msg . ' missing';
    return $self->_set_error($vcol_missing_msg);
  }

  my ( $vcol_maxlen_err, $vcol_maxlen_msg ) = check_maxlen( $vcol_param_data_maxlen, $vcol_len_info );

  if ($vcol_maxlen_err) {

    $vcol_maxlen_msg = $vcol_maxlen_msg . ' longer than maximum length.';
    return $self->_set_error($vcol_maxlen_msg);
  }

  my $insert_statement = "
        INSERT INTO trialevent SET
            EventTypeId=?,
            TrialId=?,
            UnitId=?,
            OperatorId=?,
            TrialEventValue=?,
            TrialEventDate=?,
            TrialEventNote=?
    ";

  my $sth = $dbh_k_write->prepare($insert_statement);
  $sth->execute( $trialevent_typeid, $trialevent_trialid, $unit_id, $trialevent_operatorid,
                 $trialevent_trialevent_value, $trialevent_trialevent_date, $trialevent_trialevent_note );

  if ( $dbh_k_write->err() ) {

    $self->logger->debug("INSERT INTO trialevent failed");
    return $self->_set_error();
  }

  my $trialevent_id = $dbh_k_write->last_insert_id( undef, undef, 'trialevent', 'TrialEventId' ) || -1;
  $self->logger->debug("TrialEventId: $trialevent_id");
  $sth->finish();
  $dbh_k_write->disconnect();

  my $success = $self->_add_factor( $trialevent_id, $vcol_data );

  if ( !$success ) {

    return $self->_set_error('Adding factor failed');
  }

  my $info_msg_aref  = [ { 'Message' => "TrialEventId ($trialevent_id) has been added successfully." } ];
  my $return_id_aref = [ { 'Value'   => "$trialevent_id", 'ParaName' => 'TrialEventId' } ];

  return {
    'Error' => 0,
    'Data'  => {
      'Info'     => $info_msg_aref,
      'ReturnId' => $return_id_aref,
    },
    'ExtraData' => 0
  };
}

sub update_trialevent_runmode {

=pod update_trialevent_HELP_START
{
"OperationName" : "Update trial event",
"Description": "Update trial event specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"SkippedField": ["TrialId", "OperatorId"],
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "trialevent",
"KDDArTFactorTable": "trialeventfactor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='TrialEventId (7) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'TrialEventId (7) has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='TrialEventId (9): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'TrialEventId (9): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TrialEventId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = $_[0];
  my $query = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'TrialId'    => 1,
                    'OperatorId' => 1,
  };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'trialevent', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $dbh           = connect_kdb_read();
  my $trialevent_id = $self->param('id');

  my $trial_id = read_cell_value($dbh, 'trialevent', 'TrialId', 'TrialEventId', $trialevent_id);

  if ( length($trial_id) == 0 ) {

    my $err_msg = "TrialEventId ($trialevent_id): not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id  = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str  = permission_phrase($group_id, 0, $gadmin_status);

  my $sql      = "SELECT $perm_str AS UltimatePermission ";
  $sql        .= 'FROM trial ';
  $sql        .= 'WHERE TrialId=?';

  my ($read_err, $trial_permission) = read_cell($dbh, $sql, [$trial_id]);

  if ( ($trial_permission & $READ_WRITE_PERM) != $READ_WRITE_PERM ) {

    my $err_msg = "TrialId ($trial_id): permission denied.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trialevent_typeid           = $query->param('EventTypeId');
  my $trialevent_trialevent_value = $query->param('TrialEventValue');
  my $trialevent_trialevent_date  = $query->param('TrialEventDate');
  my $unit_id                     = $query->param('UnitId');

  my $trialevent_trialevent_note  = '';

  if (defined $query->param('TrialEventNote')) {

    $trialevent_trialevent_note  = $query->param('TrialEventNote');
  }

  if (!type_existence($dbh, 'trialevent', $trialevent_typeid)) {

    my $err_msg = "EventTypeId ($trialevent_typeid): not found or inactive.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'EventTypeId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (!record_existence($dbh, 'generalunit', 'UnitId', $unit_id)) {

    my $err_msg = "UnitId ($unit_id): not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'UnitId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ( $te_date_err, $te_date_href ) = check_dt_href( { 'TrialEventDate' => $trialevent_trialevent_date } );

  if ($te_date_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$te_date_href]};

    return $data_for_postrun_href;
  }

  # Get the virtual col from the factor table

  my $vcol_sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength ";
  $vcol_sql   .= "FROM factor WHERE TableNameOfFactor='trialeventfactor'";

  my $vcol_data              = $dbh->selectall_hashref($vcol_sql, 'FactorId');
  my $vcol_param_data_compul = {};
  my $vcol_param_data        = {};
  my $vcol_len_info          = {};
  my $vcol_param_data_maxlen = {};

  for my $vcol_id ( keys( %{$vcol_data} ) ) {

    my $vcol_param_name = "VCol_${vcol_id}";
    my $vcol_value      = $query->param($vcol_param_name);

    if ( $vcol_data->{$vcol_id}->{'CanFactorHaveNull'} != 1 ) {

      $vcol_param_data_compul->{$vcol_param_name} = $vcol_value;
    }
    $vcol_param_data->{$vcol_param_name}        = $vcol_value;
    $vcol_len_info->{$vcol_param_name}          = $vcol_data->{$vcol_id}->{'FactorValueMaxLength'};
    $vcol_param_data_maxlen->{$vcol_param_name} = $vcol_value;
  }

  # Validate virtual column for factor
  my ( $vcol_missing_err, $vcol_missing_msg ) = check_missing_value($vcol_param_data);

  if ($vcol_missing_err) {

    $vcol_missing_msg = $vcol_missing_msg . ' missing';
    return $self->_set_error($vcol_missing_msg);
  }

  my ( $vcol_maxlen_err, $vcol_maxlen_msg ) = check_maxlen( $vcol_param_data_maxlen, $vcol_len_info );

  if ($vcol_maxlen_err) {

    $vcol_maxlen_msg = $vcol_maxlen_msg . ' longer than maximum length.';
    return $self->_set_error($vcol_maxlen_msg);
  }

  $dbh->disconnect();

  my $dbh_k_write = connect_kdb_write();

  $sql = "
        UPDATE trialevent SET
            EventTypeId=?,
            UnitId=?,
            TrialEventValue=?,
            TrialEventDate=?,
            TrialEventNote=?
        WHERE TrialEventId=?
    ";

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute( $trialevent_typeid, $unit_id, $trialevent_trialevent_value,
                 $trialevent_trialevent_date, $trialevent_trialevent_note, $trialevent_id
      );

  if ( $dbh_k_write->err() ) {

    return $self->_set_error();
  }

  my ($up_vcol_err, $up_vcol_err_msg) = update_vcol_data($dbh_k_write, $vcol_data, $vcol_param_data,
                                                         'trialeventfactor', 'TrialEventId', $trialevent_id);

  if ($up_vcol_err) {

    $self->logger->debug($up_vcol_err_msg);
    return $self->_set_error('Unexpected error.');
  }

  $sth->finish();
  $dbh_k_write->disconnect();

  my $info_msg_aref  = [ { 'Message' => "TrialEventId ($trialevent_id) has been updated successfully." } ];

  return {
    'Error' => 0,
    'Data'  => {
      'Info'     => $info_msg_aref,
    },
    'ExtraData' => 0
  };
}


######################################################################
# Utility functions

sub _set_error {

  my ( $self, $error_message ) = @_;
  return {
    'Error' => 1,
    'Data'  => { 'Error' => [ { 'Message' => $error_message || 'Unexpected error.' } ] }
  };
}

sub _add_factor {

  my ( $self, $trialevent_id, $vcol_data ) = @_;

  my $query       = $self->query();
  my $dbh_k_write = connect_kdb_write();

  for my $vcol_id ( keys( %{$vcol_data} ) ) {

    my $factor_value = $query->param( 'VCol_' . "$vcol_id" );

    if ( length($factor_value) > 0 ) {

      my $sql = "
                INSERT INTO trialeventfactor SET
                FactorId=?,
                TrialEventId=?,
                FactorValue=?
            ";
      my $factor_sth = $dbh_k_write->prepare($sql);
      $factor_sth->execute( $vcol_id, $trialevent_id, $factor_value );

      if ( $dbh_k_write->err() ) {

        # Return undef if any error occur
        return undef;
      }
      $factor_sth->finish();
    }
  }
  $dbh_k_write->disconnect();

  # Return true on success
  return 1;
}

sub logger {

  my $self = shift;
  return $self->{logger};
}

1;
