#$Id$
#$Author$

# Copyright (c) 2011, Diversity Arrays Technology, All rights reserved.

# Author    : Puthick Hok
# Created   : 19/04/2012
# Modified  :
# Purpose   :import_itemgroup_xml_runmode
#
#

package KDDArT::DAL::Inventory;

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
use XML::Checker::Parser;
use Crypt::Random qw( makerandom );
use DateTime;
use DateTime::Format::MySQL;
use JSON::Validator;
use JSON::XS qw(decode_json);


use feature qw(switch);

sub setup {

  my $self   = shift;

  CGI::Session->name("KDDArT_DAL_SESSID");

  __PACKAGE__->authen->init_config_parameters();
  __PACKAGE__->authen->init_config_parameters();
  __PACKAGE__->authen->check_login_runmodes(':all');
  __PACKAGE__->authen->check_content_type_runmodes(':all');
  __PACKAGE__->authen->check_rand_runmodes('add_storage_gadmin',
                                           'update_storage_gadmin',
                                           'del_storage_gadmin',
                                           'add_item',
                                           'update_item_gadmin',
                                           'del_item_gadmin',
                                           'add_itemparent_gadmin',
                                           'del_itemparent_gadmin',
                                           'add_itemgroup_gadmin',
                                           'update_itemgroup_gadmin',
                                           'del_itemgroup_gadmin',
                                           'add_item_to_group_gadmin',
                                           'remove_item_from_group_gadmin',
                                           'import_item_csv_gadmin',
                                           'import_itemgroup_xml_gadmin',
                                           'add_item_log',
                                           'add_generalunit_gadmin',
                                           'update_generalunit_gadmin',
                                           'del_generalunit_gadmin',
                                           'add_conversionrule_gadmin',
                                           'del_conversionrule_gadmin',
                                           'update_conversionrule_gadmin',
                                           'update_item_bulk_gadmin',
      );
  __PACKAGE__->authen->count_session_request_runmodes(':all');

  __PACKAGE__->authen->check_signature_runmodes('add_storage_gadmin',
                                                'update_storage_gadmin',
                                                'del_storage_gadmin',
                                                'add_item',
                                                'update_item_gadmin',
                                                'del_item_gadmin',
                                                'add_itemparent_gadmin',
                                                'del_itemparent_gadmin',
                                                'update_itemgroup_gadmin',
                                                'del_itemgroup_gadmin',
                                                'add_item_to_group_gadmin',
                                                'remove_item_from_group_gadmin',
                                                'add_item_log',
                                                'add_generalunit_gadmin',
                                                'update_generalunit_gadmin',
                                                'del_generalunit_gadmin',
                                                'add_conversionrule_gadmin',
                                                'del_conversionrule_gadmin',
                                                'update_conversionrule_gadmin',
                                                'update_item_bulk_gadmin',
      );
  __PACKAGE__->authen->check_gadmin_runmodes(#'add_storage_gadmin',
                                             #'update_storage_gadmin',
                                             'del_storage_gadmin',
                                             #'update_item_gadmin',
                                             'del_item_gadmin',
                                             'add_itemparent_gadmin',
                                             'del_itemparent_gadmin',
                                             'add_itemgroup_gadmin',
                                             'del_itemgroup_gadmin',
                                             'add_item_to_group_gadmin',
                                             'remove_item_from_group_gadmin',
                                             'import_itemgroup_xml_gadmin',
                                             #'import_item_csv_gadmin',
                                             'update_generalunit_gadmin',
                                             'del_generalunit_gadmin',
                                             'add_generalunit_gadmin',
                                             'add_conversionrule_gadmin',
                                             'del_conversionrule_gadmin',
                                             'update_conversionrule_gadmin',
                                             #'update_item_bulk_gadmin',
      );
  __PACKAGE__->authen->check_sign_upload_runmodes('add_itemgroup_gadmin',
                                                  'import_item_csv_gadmin',
                                                  'import_itemgroup_xml_gadmin',
      );

  $self->run_modes(

    # Storage
    'add_storage_gadmin'            => 'add_storage_runmode',
    'update_storage_gadmin'         => 'update_storage_runmode',
    'del_storage_gadmin'            => 'del_storage_runmode',
    'list_storage'                  => 'list_storage_runmode',
    'get_storage'                   => 'get_storage_runmode',

    # Item
    'add_item'                      => 'add_item_runmode',
    'update_item_gadmin'            => 'update_item_runmode',
    'del_item_gadmin'               => 'del_item_runmode',
    'get_item'                      => 'get_item_runmode',
    'list_item_advanced'            => 'list_item_advanced_runmode',
    'import_item_csv_gadmin'        => 'import_item_csv_runmode',
    'update_item_bulk_gadmin'       => 'update_item_bulk_runmode',

    # Unit
    'add_generalunit_gadmin'        => 'add_general_unit_runmode',
    'del_generalunit_gadmin'        => 'del_general_unit_runmode',
    'update_generalunit_gadmin'     => 'update_general_unit_runmode',
    'get_generalunit'               => 'get_general_unit_runmode',
    'list_generalunit_advanced'     => 'list_general_unit_advanced_runmode',

    # Item Group
    'add_itemgroup_gadmin'          => 'add_itemgroup_runmode',
    'update_itemgroup_gadmin'       => 'update_itemgroup_runmode',
    'del_itemgroup_gadmin'          => 'del_itemgroup_runmode',
    'get_itemgroup'                 => 'get_itemgroup_runmode',
    'list_itemgroup_advanced'       => 'list_itemgroup_advanced_runmode',
    'import_itemgroup_xml_gadmin'   => 'import_itemgroup_xml_runmode',

    # Group Item
    'add_item_to_group_gadmin'      => 'add_item_to_group_runmode',
    'remove_item_from_group_gadmin' => 'remove_item_from_group_runmode',

    # Item Parent
    'add_itemparent_gadmin'         => 'add_itemparent_runmode',
    'del_itemparent_gadmin'         => 'del_itemparent_runmode',
    'list_itemparent'               => 'list_itemparent_runmode',
    'get_itemparent'                => 'get_itemparent_runmode',

    'add_item_log'                  => 'add_item_log_runmode',
    'show_item_log'                 => 'show_item_log_runmode',

    'add_conversionrule_gadmin'     => 'add_conversionrule_runmode',
    'del_conversionrule_gadmin'     => 'del_conversionrule_runmode',
    'update_conversionrule_gadmin'  => 'update_conversionrule_runmode',
    'list_conversionrule'           => 'list_conversionrule_runmode',
    'get_conversionrule'            => 'get_conversionrule_runmode',
      );

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

  my $domain_name = $COOKIE_DOMAIN->{$ENV{DOCUMENT_ROOT}};
  $self->logger->debug("COOKIE DOMAIN: $domain_name");

  $self->authen->config(LOGIN_URL => '');
  $self->session_config(
          CGI_SESSION_OPTIONS => [ "driver:File", $self->query, {Directory => $SESSION_STORAGE_PATH} ],
          SEND_COOKIE         => 0,
      );
}

# Managing item Parent
###########################################################################

sub del_itemparent_runmode {

=pod del_itemparent_gadmin_HELP_START
{
"OperationName": "Delete item parent",
"Description": "Delete inventory item parent information specified by id. Record can not be deleted if it breaks inventory tree.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Item Parent (1) has been removed successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Item Parent (2) has been removed successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='ItemParentId (2): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'ItemParentId (2): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing ItemParentId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my ($self) = @_;

  my $parent_item_id = $self->param('id');
  my $dbh_k_read     = connect_kdb_read();

  my $is_record_exists = record_existence( $dbh_k_read, 'itemparent', 'ItemParentId', $parent_item_id );
  if ( !$is_record_exists ) {

    my $message = "ItemParentId ($parent_item_id): not found.";
    return $self->_set_error($message);
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $delete_statement = "DELETE from itemparent WHERE ItemParentId=?";
  my $sth              = $dbh_k_write->prepare($delete_statement);
  $sth->execute($parent_item_id);

  if ( $dbh_k_write->err() ) {

    return $self->_set_error();
  }

  $sth->finish();
  $dbh_k_write->disconnect();

  my $info_msg_aref = [ { 'Message' => "Item Parent ($parent_item_id) has been removed successfully." } ];
  return {
    'Error'     => 0,
    'Data'      => { 'Info' => $info_msg_aref, },
    'ExtraData' => 0
  };
}

sub add_itemparent_runmode {

=pod add_itemparent_gadmin_HELP_START
{
"OperationName": "Add parent for item",
"Description": "Define parent for inventory item specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "itemparent",
"SkippedField": ["ItemId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='3' ParaName='ItemParentId' /><Info Message='ItemId (23) is now a parent of ItemId (22).' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '4','ParaName' : 'ItemParentId'}],'Info' : [{'Message' : 'ItemId (25) is now a parent of ItemId (24).'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error ItemParentType='ItemParentType (154): not found or inactive.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'ItemParentType' : 'ItemParentType (154): not found or inactive.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing ItemId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self   = $_[0];
  my $query  = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'ItemId' => 1};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'itemparent', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $item_id          = $self->param('id');
  my $parent_item_id   = $query->param('ParentId');
  my $parent_item_type = $query->param('ItemParentType');

  my $dbh_k_read = connect_kdb_read();

  if (!type_existence($dbh_k_read, 'itemparent', $parent_item_type)) {

    my $err_msg = "ItemParentType ($parent_item_type): not found or inactive.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'ItemParentType' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (!record_existence($dbh_k_read, 'item', 'ItemId', $item_id)) {

    my $err_msg = "ItemId ($item_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'ItemId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (!record_existence($dbh_k_read, 'item', 'ItemId', $parent_item_id)) {

    my $err_msg = "ParentId ($parent_item_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'ParentId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dup_chk_sql = "SELECT ItemParentId FROM itemparent ";
  $dup_chk_sql   .= "WHERE ItemId=? AND ParentId=?";

  my ($dup_chk_err, $dup_itemparent_id) = read_cell($dbh_k_read, $dup_chk_sql, [$item_id, $parent_item_id]);

  if (length($dup_itemparent_id) > 0) {

    my $err_msg = "ItemParentId ($parent_item_id), ItemId ($item_id), ItemParentType ($parent_item_type): already exists.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $insert_statement = "
        INSERT into itemparent SET
            ItemId=?,
            ParentId=?,
            ItemParentType=?
    ";
  my $sth = $dbh_k_write->prepare($insert_statement);
  $sth->execute( $item_id, $parent_item_id, $parent_item_type );

  if ( $dbh_k_write->err() ) {

    return $self->_set_error( $sth->err() );
  }

  my $parent_id = $dbh_k_write->last_insert_id( undef, undef, 'itemparent', 'ParentItemId' ) || -1;

  $sth->finish();
  $dbh_k_write->disconnect();

  my $info_msg_aref = [ { 'Message' => "ItemId ($parent_item_id) is now a parent of ItemId ($item_id)." } ];
  my $return_id_aref = [ { 'Value' => $parent_id, 'ParaName' => 'ItemParentId' } ];

  return {
    'Error' => 0,
    'Data'  => {
      'Info'     => $info_msg_aref,
      'ReturnId' => $return_id_aref,
    },
    'ExtraData' => 0
  };
}

# Managing item Groups
###########################################################################

sub list_itemgroup {

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
  my $itemgrp_data = [];

  if ( !$dbh->err() ) {

    my $array_ref = $sth->fetchall_arrayref({});

    if ( !$sth->err() ) {

      $itemgrp_data = $array_ref;
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

  my $extra_attr_itemgrp_data = [];

  if ($extra_attr_yes) {

    my $gadmin_status = $self->authen->gadmin_status();

    my $itm_grp_id_aref = [];

    my $item_lookup     = {};

    for my $row (@{$itemgrp_data}) {

      push(@{$itm_grp_id_aref}, $row->{'ItemGroupId'});
    }

    my $chk_id_err        = 0;
    my $chk_id_msg        = '';
    my $used_id_href      = {};
    my $not_used_id_href  = {};

    my $dbh_m = connect_mdb_read();

    if (scalar(@{$itm_grp_id_aref}) > 0) {

      my $sql = 'SELECT itemgroupentry.ItemGroupId, item.* ';
      $sql   .= 'FROM itemgroupentry LEFT JOIN item ON itemgroupentry.ItemId = item.ItemId ';
      $sql   .= 'WHERE ItemGroupId IN (' . join(',', @{$itm_grp_id_aref}) . ')';

      my ($read_grp_entry_err, $read_grp_entry_msg, $grp_entry_data) = read_data($dbh, $sql, []);

      if ($read_grp_entry_err) {

        return ($read_grp_entry_err, $read_grp_entry_msg, []);
      }

      for my $grp_entry_row (@{$grp_entry_data}) {

        my $itm_grp_id = $grp_entry_row->{'ItemGroupId'};

        if (defined $item_lookup->{$itm_grp_id}) {

          my $itm_aref = $item_lookup->{$itm_grp_id};
          delete($grp_entry_row->{'ItemGroupId'});
          push(@{$itm_aref}, $grp_entry_row);
          $item_lookup->{$itm_grp_id} = $itm_aref;
        }
        else {

          delete($grp_entry_row->{'ItemGroupId'});
          $item_lookup->{$itm_grp_id} = [$grp_entry_row];
        }
      }

      my $chk_table_aref = [{'TableName' => 'extract', 'FieldName' => 'ItemGroupId'}];

      ($chk_id_err, $chk_id_msg,
       $used_id_href, $not_used_id_href) = id_existence_bulk($dbh_m, $chk_table_aref, $itm_grp_id_aref);

      if ($chk_id_err) {

        $self->logger->debug("Check id existence error: $chk_id_msg");
        $err = 1;
        $msg = $chk_id_msg;

        return ($err, $msg, []);
      }
    }

    for my $row (@{$itemgrp_data}) {

      my $itemgrp_id = $row->{'ItemGroupId'};

      if (defined $item_lookup->{$itemgrp_id}) {

        my $grp_entry_data = $item_lookup->{$itemgrp_id};
        my $item_aref = [];

        for my $item_info (@{$grp_entry_data}) {

          my $item_id = $item_info->{'ItemId'};

          if ($gadmin_status eq '1') {

            $item_info->{'removeItem'} = "itemgroup/${itemgrp_id}/remove/item/$item_id";
          }
          push(@{$item_aref}, $item_info);
        }

        $row->{'Item'} = $item_aref;
      }

      if ($gadmin_status eq '1') {

        $row->{'update'} = "update/itemgroup/$itemgrp_id";

        if ( $not_used_id_href->{$itemgrp_id} && (!(defined $item_lookup->{$itemgrp_id}))  ) {

          $row->{'delete'}   = "delete/itemgroup/$itemgrp_id";
        }
      }
      push(@{$extra_attr_itemgrp_data}, $row);
    }

    $dbh_m->disconnect();
  }
  else {

    $extra_attr_itemgrp_data = $itemgrp_data;
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_itemgrp_data);
}

sub list_itemgroup_advanced_runmode {

=pod list_itemgroup_advanced_HELP_START
{
"OperationName": "List item groups",
"Description": "List item groups. This listing requires pagination.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination Page='1' NumOfRecords='8' NumOfPages='8' NumPerPage='1' /><ItemGroup DateAdded='2012-08-08 00:00:00' ItemGroupNote='Testing' UserName='admin' ItemGroupName='ITM_GRP0221890' AddedByUser='0' Active='1' update='update/itemgroup/8' ItemGroupId='8'><Item DateAdded='2014-08-06 12:39:45' ItemId='18' removeItem='itemgroup/8/remove/item/18' AddedByUserId='0' ItemTypeId='138' TrialUnitSpecimenId='0' ContainerTypeId='136' ItemNote='' ItemStateId='139' ScaleId='14' SpecimenId='486' ItemOperation='group' LastMeasuredUserId='0' ItemBarcode='I_7183475' UnitId='16' StorageId='8' Amount='5.000' LastMeasuredDate='2012-08-01 00:00:00' ItemSourceId='30' /><Item DateAdded='2014-08-06 12:39:45' ItemId='19' removeItem='itemgroup/8/remove/item/19' AddedByUserId='0' ItemTypeId='138' TrialUnitSpecimenId='0' ContainerTypeId='136' ItemStateId='139' ItemNote='' ScaleId='14' SpecimenId='486' ItemBarcode='I_8241179' LastMeasuredUserId='0' ItemOperation='group' UnitId='16' StorageId='8' Amount='5.000' LastMeasuredDate='2012-08-01 00:00:00' ItemSourceId='30' /></ItemGroup><RecordMeta TagName='ItemGroup' /></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfRecords' : '8','NumOfPages' : 8,'NumPerPage' : '1','Page' : '1'}],'ItemGroup' : [{'DateAdded' : '2012-08-08 00:00:00','Item' : [{'DateAdded' : '2014-08-06 12:39:45','ItemId' : '18','removeItem' : 'itemgroup/8/remove/item/18','AddedByUserId' : '0','TrialUnitSpecimenId' : '0','ItemTypeId' : '138','ContainerTypeId' : '136','ItemNote' : '','ItemStateId' : '139','SpecimenId' : '486','ScaleId' : '14','ItemOperation' : 'group','LastMeasuredUserId' : '0','ItemBarcode' : 'I_7183475','UnitId' : '16','StorageId' : '8','Amount' : '5.000','LastMeasuredDate' : '2012-08-01 00:00:00','ItemSourceId' : '30'},{'DateAdded' : '2014-08-06 12:39:45','ItemId' : '19','removeItem' : 'itemgroup/8/remove/item/19','AddedByUserId' : '0','TrialUnitSpecimenId' : '0','ItemTypeId' : '138','ContainerTypeId' : '136','ItemNote' : '','ItemStateId' : '139','SpecimenId' : '486','ScaleId' : '14','ItemOperation' : 'group','LastMeasuredUserId' : '0','ItemBarcode' : 'I_8241179','UnitId' : '16','StorageId' : '8','Amount' : '5.000','LastMeasuredDate' : '2012-08-01 00:00:00','ItemSourceId' : '30'}],'UserName' : 'admin','ItemGroupNote' : 'Testing','ItemGroupName' : 'ITM_GRP0221890','Active' : '1','AddedByUser' : '0','ItemGroupId' : '8','update' : 'update/itemgroup/8'}],'RecordMeta' : [{'TagName' : 'ItemGroup'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"URLParameter": [{"ParameterName": "nperpage", "Description": "Number of records in a page for pagination"}, {"ParameterName": "num", "Description": "The page number of the pagination"}],
"HTTPParameter": [{"Required": 0, "Name": "Filtering", "Description": "Filtering parameter string consisting of filtering expressions which are separated by ampersand (&) which needs to be encoded if HTTP GET method is used. Each filtering expression is composed of a database field name, a filtering operator and the filtering value."}, {"Required": 0, "Name": "FieldList", "Description": "Comma separated value of wanted fields."}, {"Required": 0, "Name": "Sorting", "Description": "Comma separated value of SQL sorting phrases."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;

  my $query = $self->query();

  my $pagination  = 0;
  my $nb_per_page = -1;
  my $page        = -1;

  if ( (defined $self->param('nperpage')) && (defined $self->param('num')) ) {

    $pagination  = 1;
    $nb_per_page = $self->param('nperpage');
    $page        = $self->param('num');
  }

  $self->logger->debug("Page number: $page");

  my $field_list_csv = $query->param('FieldList') ? $query->param('FieldList') : '';
  my $filtering_csv  = $query->param('Filtering') ? $query->param('Filtering') : '';
  my $sorting        = $query->param('Sorting')   ? $query->param('Sorting')   : '';

  $self->logger->debug("Filtering: $filtering_csv");

  my $data_for_postrun_href = {};

  my $sql = 'SELECT * FROM itemgroup LIMIT 1';

  my ($samp_itmgrp_err, $samp_itmgrp_msg, $samp_itmgrp_data) = $self->list_itemgroup(0, $sql);

  if ($samp_itmgrp_err) {

    $self->logger->debug($samp_itmgrp_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $dbh = connect_kdb_read();

  my $sample_data_aref = $samp_itmgrp_data;

  my @field_list_all;

  if (scalar(@{$sample_data_aref}) == 1) {

    @field_list_all = keys(%{$sample_data_aref->[0]});
  }
  else {

    $self->logger->debug("It reaches here");
    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'itemgroup');

    if ($sfield_err) {

      $self->logger->debug("Get static field failed: $sfield_msg");

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
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

  $self->logger->debug("Final field list: " . join(',', @{$final_field_list}));

  if ( length($field_list_csv) > 0 ) {

    my ( $sel_field_err, $sel_field_msg, $sel_field_list ) = parse_selected_field( $field_list_csv,
                                                                                   $final_field_list,
                                                                                   'ItemGroupId' );
    if ($sel_field_err) {

      my $err_msg = $sel_field_msg;
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    $final_field_list = $sel_field_list;
  }

  my $join = '';

  for my $field (@{$final_field_list}) {

    if ($field eq 'AddedByUser') {

      push(@{$final_field_list}, 'systemuser.UserName');
      $join = ' LEFT JOIN systemuser ON itemgroup.AddedByUser = systemuser.UserId ';
    }
  }

  $self->logger->debug("Final field list: " . join(',', @{$final_field_list}));

  $sql  = 'SELECT ' . join(',', @{$final_field_list}) . ' ';
  $sql .= "FROM itemgroup $join ";

  my $field_name2table_name  = { 'ItemId' => 'itemgroupentry' };
  my $validation_func_lookup = {};

  my ( $filter_err, $filter_msg, $filter_phrase, $where_arg ) = parse_filtering('ItemGroupId',
                                                                                'itemgroup',
                                                                                $filtering_csv,
                                                                                $final_field_list,
                                                                                $validation_func_lookup,
                                                                                $field_name2table_name
                                                                               );
  if ($filter_err) {

    $self->logger->debug("Parse filtering failed: $filter_msg");
    my $err_msg = $filter_msg;

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $filter_where_phrase = '';
  if (length($filter_phrase) > 0) {

    $filter_where_phrase = " WHERE $filter_phrase ";
  }

  my $filtering_exp = $filter_where_phrase;

  $sql .= " $filter_where_phrase ";

  my $pagination_aref = [];
  my $paged_limit_clause = '';

  if ($pagination) {

    my ( $int_err, $int_err_msg ) = check_integer_value( { 'nperpage' => $nb_per_page,
                                                           'num'      => $page
                                                         } );
    if ($int_err) {

      $int_err_msg .= ' not integer.';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $int_err_msg}]};

      return $data_for_postrun_href;
    }

    my ( $paged_id_err, $paged_id_msg, $nb_records,
         $nb_pages, $limit_clause, $sql_count_time ) = get_paged_filter($dbh,
                                                                        $nb_per_page,
                                                                        $page,
                                                                        'itemgroup',
                                                                        'ItemGroupId',
                                                                        $filtering_exp,
                                                                        $where_arg
             );

    $self->logger->debug("SQL Count time: $sql_count_time");

    if ( $paged_id_err == 1 ) {

      $self->logger->debug($paged_id_msg);
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error.'}]};

      return $data_for_postrun_href;
    }

    if ( $paged_id_err == 2 ) {

      $page = 0;
    }

    $pagination_aref = [ { 'NumOfRecords' => $nb_records,
                           'NumOfPages'   => $nb_pages,
                           'Page'         => $page,
                           'NumPerPage'   => $nb_per_page,
                         } ];

    $paged_limit_clause = $limit_clause;
  }

  $dbh->disconnect();

  my ( $sort_err, $sort_msg, $sort_sql ) = parse_sorting( $sorting, $final_field_list );

  if ($sort_err) {

    $self->logger->debug("Parse sorting failed: $sort_msg");

    my $err_msg = $sort_msg;

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($sort_sql) > 0) {

    $sql .= " ORDER BY $sort_sql ";
  }
  else {

    $sql .= " ORDER BY itemgroup.ItemGroupId DESC ";
  }

  $sql .= " $paged_limit_clause ";

  $self->logger->debug("Final list itemgroup SQL: $sql");

  my ($itmgrp_err, $itmgrp_msg, $itmgrp_data) = $self->list_itemgroup(1, $sql, $where_arg);

  if ($itmgrp_err) {

    $self->logger->debug("Get item group failed: $itmgrp_msg");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'ItemGroup'     => $itmgrp_data,
                                           'Pagination'    => $pagination_aref,
                                           'RecordMeta'    => [{'TagName' => 'ItemGroup'}],
  };

  return $data_for_postrun_href;
}

sub get_itemgroup_runmode {

=pod get_itemgroup_HELP_START
{
"OperationName": "Get item group",
"Description": "Get detailed information about item group specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ItemGroup DateAdded='2012-08-08 00:00:00' UserName='admin' ItemGroupNote='Testing1234' ItemGroupName='ITM_GRP6300825' Active='1' AddedByUser='0' ItemGroupId='1' update='update/itemgroup/1'><Item DateAdded='2014-07-01 13:16:19' ItemId='4' removeItem='itemgroup/1/remove/item/4' AddedByUserId='0' ItemTypeId='34' TrialUnitSpecimenId='0' ContainerTypeId='32' ItemNote='' ItemStateId='35' ScaleId='2' SpecimenId='13' ItemOperation='group' LastMeasuredUserId='0' ItemBarcode='I_1904016' UnitId='3' StorageId='1' Amount='5.000' ItemSourceId='7' LastMeasuredDate='2012-08-01 00:00:00' /><Item DateAdded='2014-07-01 13:16:19' ItemId='5' removeItem='itemgroup/1/remove/item/5' AddedByUserId='0' ItemTypeId='34' TrialUnitSpecimenId='0' ContainerTypeId='32' ItemStateId='35' ItemNote='' ScaleId='2' SpecimenId='13' ItemBarcode='I_2173480' LastMeasuredUserId='0' ItemOperation='group' UnitId='3' StorageId='1' Amount='5.000' ItemSourceId='7' LastMeasuredDate='2012-08-01 00:00:00' /><Item DateAdded='2014-07-01 13:16:25' ItemId='6' removeItem='itemgroup/1/remove/item/6' AddedByUserId='0' ItemTypeId='34' TrialUnitSpecimenId='0' ContainerTypeId='32' ItemStateId='35' ItemNote='' ScaleId='2' SpecimenId='13' ItemBarcode='I_5274114' LastMeasuredUserId='0' ItemOperation='group' UnitId='3' StorageId='1' Amount='5.000' ItemSourceId='7' LastMeasuredDate='2012-08-01 00:00:00' /><Item DateAdded='2014-07-01 13:16:29' ItemId='8' removeItem='itemgroup/1/remove/item/8' AddedByUserId='0' ItemTypeId='40' TrialUnitSpecimenId='0' ContainerTypeId='38' ItemStateId='41' ItemNote='' ScaleId='3' SpecimenId='13' ItemBarcode='I_1803002' LastMeasuredUserId='0' ItemOperation='group' UnitId='3' StorageId='1' Amount='5.000' ItemSourceId='7' LastMeasuredDate='2012-08-01 00:00:00' /></ItemGroup><RecordMeta TagName='ItemGroup' /></DATA>",
"SuccessMessageJSON": "{'ItemGroup' : [{'DateAdded' : '2012-08-08 00:00:00','Item' : [{'DateAdded' : '2014-07-01 13:16:19','ItemId' : '4','removeItem' : 'itemgroup/1/remove/item/4','AddedByUserId' : '0','TrialUnitSpecimenId' : '0','ItemTypeId' : '34','ContainerTypeId' : '32','ItemNote' : '','ItemStateId' : '35','SpecimenId' : '13','ScaleId' : '2','ItemOperation' : 'group','LastMeasuredUserId' : '0','ItemBarcode' : 'I_1904016','UnitId' : '3','StorageId' : '1','Amount' : '5.000','LastMeasuredDate' : '2012-08-01 00:00:00','ItemSourceId' : '7'},{'DateAdded' : '2014-07-01 13:16:19','ItemId' : '5','removeItem' : 'itemgroup/1/remove/item/5','AddedByUserId' : '0','TrialUnitSpecimenId' : '0','ItemTypeId' : '34','ContainerTypeId' : '32','ItemNote' : '','ItemStateId' : '35','SpecimenId' : '13','ScaleId' : '2','ItemOperation' : 'group','LastMeasuredUserId' : '0','ItemBarcode' : 'I_2173480','UnitId' : '3','StorageId' : '1','Amount' : '5.000','LastMeasuredDate' : '2012-08-01 00:00:00','ItemSourceId' : '7'},{'DateAdded' : '2014-07-01 13:16:25','ItemId' : '6','removeItem' : 'itemgroup/1/remove/item/6','AddedByUserId' : '0','TrialUnitSpecimenId' : '0','ItemTypeId' : '34','ContainerTypeId' : '32','ItemNote' : '','ItemStateId' : '35','SpecimenId' : '13','ScaleId' : '2','ItemOperation' : 'group','LastMeasuredUserId' : '0','ItemBarcode' : 'I_5274114','UnitId' : '3','StorageId' : '1','Amount' : '5.000','LastMeasuredDate' : '2012-08-01 00:00:00','ItemSourceId' : '7'},{'DateAdded' : '2014-07-01 13:16:29','ItemId' : '8','removeItem' : 'itemgroup/1/remove/item/8','AddedByUserId' : '0','TrialUnitSpecimenId' : '0','ItemTypeId' : '40','ContainerTypeId' : '38','ItemNote' : '','ItemStateId' : '41','SpecimenId' : '13','ScaleId' : '3','ItemOperation' : 'group','LastMeasuredUserId' : '0','ItemBarcode' : 'I_1803002','UnitId' : '3','StorageId' : '1','Amount' : '5.000','LastMeasuredDate' : '2012-08-01 00:00:00','ItemSourceId' : '7'}],'UserName' : 'admin','ItemGroupNote' : 'Testing1234','ItemGroupName' : 'ITM_GRP6300825','Active' : '1','AddedByUser' : '0','ItemGroupId' : '1','update' : 'update/itemgroup/1'}],'RecordMeta' : [{'TagName' : 'ItemGroup'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='ItemGroupId (10): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'ItemGroupId (10): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing ItemGroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self          = shift;
  my $item_group_id = $self->param('id');

  my $dbh = connect_kdb_read();
  my $grp_exist = record_existence($dbh, 'itemgroup', 'ItemGroupId', $item_group_id);
  $dbh->disconnect();

  if (!$grp_exist) {

    return $self->_set_error("ItemGroupId ($item_group_id): not found.");
  }

  my $data_for_postrun_href = {};

  my $sql = 'SELECT itemgroup.*, systemuser.UserName ';
  $sql   .= 'FROM itemgroup LEFT JOIN systemuser ON itemgroup.AddedByUser = systemuser.UserId ';
  $sql   .= 'WHERE itemgroup.ItemGroupId=? ';
  $sql   .= 'ORDER BY ItemGroupId DESC';

  my ($read_itemgroup_err, $read_itemgroup_msg, $itemgroup_data) = $self->list_itemgroup(1, $sql,
                                                                                         [$item_group_id]);

  if ($read_itemgroup_err) {

    $self->logger->debug($read_itemgroup_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'ItemGroup'    => $itemgroup_data,
                                           'RecordMeta' => [{'TagName' => 'ItemGroup'}],
  };

  return $data_for_postrun_href;
}

sub add_itemgroup_runmode {

=pod add_itemgroup_gadmin_HELP_START
{
"OperationName": "Add item group",
"Description": "Create an item group.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "itemgroup",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='9' ParaName='ItemGroupId' /><Info Message='Item group (9) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '10','ParaName' : 'ItemGroupId'}], 'Info' : [{'Message' : 'Item group (10) has been added successfully.'}]}",
"ErrorMessageXML": [{"NameAlreadyExists": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error ItemGroupName='ItemGroupName (ITM_GRP) already exists.' /></DATA>"}],
"ErrorMessageJSON": [{"NameAlreadyExists": "{'Error' : [{'ItemGroupName' : 'ItemGroupName (ITM_GRP) already exists.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "XML",
"UploadFileParameterName": "uploadfile",
"DTDFileNameForUploadXML": "itemgroupentry.dtd",
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
                                                                                'itemgroup', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $item_group_name     = $query->param('ItemGroupName');
  my $item_group_added_on = $query->param('DateAdded');
  my $item_group_active   = $query->param('Active');

  my $item_group_by_user  = $self->authen->user_id();

  my ( $mdt_to_err, $mdt_to_msg ) = check_dt_value( { 'DateAdded' => $item_group_added_on } );

  if ($mdt_to_err) {

    my $err_msg = "DateAdded ($item_group_added_on) unknown date format.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $item_group_note     = '';

  if (defined $query->param('ItemGroupNote')) {

    $item_group_note     = $query->param('ItemGroupNote');
  }

  my $dbh_k_read = connect_kdb_read();

  my $is_group_exist = record_existence( $dbh_k_read, 'itemgroup', 'ItemGroupName', $item_group_name );

  if ($is_group_exist) {

    my $err_msg = "ItemGroupName ($item_group_name) already exists.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'ItemGroupName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $grp_entry_xml_file = $self->authen->get_upload_file();
  my $grp_entry_dtd_file = $self->get_item_group_entry_dtd_file();

  add_dtd($grp_entry_dtd_file, $grp_entry_xml_file);

  my $xml_checker_parser = new XML::Checker::Parser( Handlers => { } );

  eval {

    local $XML::Checker::FAIL = sub {

      my $code = shift;
      my $err_str = XML::Checker::error_string ($code, @_);
      $self->logger->debug("XML Parsing ERR: $code : $err_str");
      die $err_str;
    };
    $xml_checker_parser->parsefile($grp_entry_xml_file);
  };

  if ($@) {

    my $err_msg = $@;
    $self->logger->debug("Parsing XML error: $err_msg");
    my $user_err_msg = "Item group entry xml file does not comply with its definition.\n";
    $user_err_msg   .= "Details: $err_msg";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $user_err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id  = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $grp_entry_xml  = read_file($grp_entry_xml_file);

  $self->logger->debug("Group Entry Info: $grp_entry_xml");

  # Make sure we don't insert invalid foriegn key ids
  my @fk_relation_validation;

  my $grp_entry_aref = xml2arrayref($grp_entry_xml, 'itemgroupentry');

  for my $grp_entry (@{$grp_entry_aref}) {

    my $item_id = $grp_entry->{'ItemId'};
    push(@fk_relation_validation, { 'table' => 'item', 'field' => 'ItemId', 'value' => $item_id } );
  }

  my $invalid_relation = $self->_validate_fk_relation(@fk_relation_validation);

  if ($invalid_relation) {

    my $field       = $invalid_relation->{'field'};
    my $field_value = $invalid_relation->{'value'};
    my $err_msg     = "$field ($field_value) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_k_write = connect_kdb_write();

  my $insert_statement = "
        INSERT into itemgroup SET
            ItemGroupName=?,
            ItemGroupNote=?,
            AddedByUser=?,
            DateAdded=?,
            Active=?
    ";

  my $sth = $dbh_k_write->prepare($insert_statement);
  $sth->execute( $item_group_name, $item_group_note, $item_group_by_user, $item_group_added_on, $item_group_active );

  if ( $dbh_k_write->err() ) {

    $self->logger->debug("Insert into itemgroup failed");
    my $err_msg     = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $item_group_id = $dbh_k_write->last_insert_id( undef, undef, 'itemgroup', 'ItemGroupId' ) || -1;
  $self->logger->debug("ItemGroupId: $item_group_id");
  $sth->finish();

  for my $grp_entry_info (@{$grp_entry_aref}) {

    my $item_id = $grp_entry_info->{'ItemId'};

    my $sql  = 'INSERT INTO itemgroupentry SET ';
    $sql    .= 'ItemGroupId=?, ';
    $sql    .= 'ItemId=?';

    my $grp_entry_sth = $dbh_k_write->prepare($sql);
    $grp_entry_sth->execute($item_group_id, $item_id);

    if ($dbh_k_write->err()) {

      $self->logger->debug("Database error");

      my $err_msg     = "Unexpected Error.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    $grp_entry_sth->finish();
  }

  $dbh_k_write->disconnect();

  my $info_msg_aref = [ { 'Message' => "Item group ($item_group_id) has been added successfully." } ];
  my $return_id_aref = [ { 'Value' => $item_group_id, 'ParaName' => 'ItemGroupId' } ];

  return {
    'Error' => 0,
    'Data'  => {
      'Info'     => $info_msg_aref,
      'ReturnId' => $return_id_aref,
    },
    'ExtraData' => 0
  };
}

sub update_itemgroup_runmode {

=pod update_itemgroup_gadmin_HELP_START
{
"OperationName": "Update item group",
"Description": "Update information about item group specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "itemgroup",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='ItemGroupId (13) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'ItemGroupId (13) has been updated successfully.'}]}",
"ErrorMessageXML": [{"NameAlreadyExists": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error ItemGroupName='ItemGroupName (ITM_GRP): already exists.' /></DATA>"}],
"ErrorMessageJSON": [{"NameAlreadyExists": "{'Error' : [{'ItemGroupName' : 'ItemGroupName (ITM_GRP): already exists.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing ItemGroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = $_[0];
  my $query = $self->query();

  my $item_group_id    = $self->param('id');

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'itemgroup', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $dbh_k_read       = connect_kdb_read();
  my $is_record_exists = record_existence( $dbh_k_read, 'itemgroup', 'ItemGroupId', $item_group_id );

  if ( !$is_record_exists ) {

    my $err_msg = "ItemGroupId ($item_group_id): not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $item_group_name     = $query->param('ItemGroupName');
  my $item_group_added_on = $query->param('DateAdded');
  my $item_group_active   = $query->param('Active');

  my $item_group_note     = read_cell_value($dbh_k_read, 'itemgroup', 'ItemGroupNote', 'ItemGroupId', $item_group_id);

  if (defined $query->param('ItemGroupNote')) {

    $item_group_note     = $query->param('ItemGroupNote');
  }

  my ( $mdt_to_err, $mdt_to_msg ) = check_dt_value( { 'DateAdded' => $item_group_added_on } );

  if ($mdt_to_err) {

    my $err_msg = "DateAdded ($item_group_added_on) unknown date format.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'DateAdded' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $chk_itm_grp_name_sql = "SELECT ItemGroupId FROM itemgroup WHERE ItemGroupName=? AND ItemGroupId <> ?";

  my ($read_err, $db_itm_grp_id) = read_cell($dbh_k_read, $chk_itm_grp_name_sql, [$item_group_name, $item_group_id]);

  if ($read_err) {

    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_itm_grp_id) > 0) {

    my $err_msg = "ItemGroupName ($item_group_name): already exists.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'ItemGroupName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $insert_statement = "
        UPDATE itemgroup SET
            ItemGroupName=?,
            ItemGroupNote=?,
            DateAdded=?,
            Active=?
        WHERE ItemGroupId=?
    ";

  my $sth = $dbh_k_write->prepare($insert_statement);
  $sth->execute( $item_group_name, $item_group_note, $item_group_added_on, $item_group_active, $item_group_id );

  if ( $dbh_k_write->err() ) {

    $self->logger->debug("Update failed");
    my $err_msg     = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sth->finish();
  $dbh_k_write->disconnect();

  my $info_msg_aref = [ { 'Message' => "ItemGroupId ($item_group_id) has been updated successfully." } ];

  return {
    'Error' => 0,
    'Data'  => {
      'Info'     => $info_msg_aref,
    },
    'ExtraData' => 0
  };
}

sub del_itemgroup_runmode {

=pod del_itemgroup_gadmin_HELP_START
{
"OperationName": "Delete item group",
"Description": "Delete item group specified by it. Item group can be deleted only if not attached to any lower level related record.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='ItemGroupId (11) has been successfully deleted.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'ItemGroupId (10) has been successfully deleted.'}]}",
"ErrorMessageXML": [{"IdUsed": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='ItemGroupId (5) has extract(s).' /></DATA>"}],
"ErrorMessageJSON": [{"IdUsed": "{'Error' : [{'Message' : 'ItemGroupId (5) has extract(s).'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing ItemGroupId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = $_[0];

  my $item_grp_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_k_read = connect_kdb_read();

  my $is_itemgroup_exist = record_existence( $dbh_k_read, 'itemgroup', 'ItemGroupId', $item_grp_id );

  if ( !$is_itemgroup_exist ) {

    my $err_msg = "ItemGroupId ($item_grp_id): not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_m_read = connect_mdb_read();

  if (record_existence($dbh_m_read, 'extract', 'ItemGroupId', $item_grp_id)) {

    my $err_msg = "ItemGroupId ($item_grp_id) has extract(s).";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_m_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $sql = 'DELETE FROM itemgroupentry WHERE ItemGroupId=?';
  my $sth = $dbh_k_write->prepare($sql);

  $sth->execute($item_grp_id);

  if ( $dbh_k_write->err() ) {

    $self->logger->debug("Delete itemgroupentry failed");
    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql = "DELETE FROM itemgroup WHERE ItemGroupId=?";
  $sth = $dbh_k_write->prepare($sql);
  $sth->execute($item_grp_id);

  if ( $dbh_k_write->err() ) {

    $self->logger->debug("Delete itemgroup failed");
    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("ItemGroupId: $item_grp_id deleted");
  $sth->finish();
  $dbh_k_write->disconnect();

  my $info_msg_aref = [ { 'Message' => "ItemGroupId ($item_grp_id) has been successfully deleted." } ];

  return {
    'Error'     => 0,
    'Data'      => { 'Info' => $info_msg_aref, },
    'ExtraData' => 0
  };
}

# Managing item units
###########################################################################

sub list_general_unit {

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

  my $dbh_gis = connect_gis_read();

  my $dbh = connect_kdb_read();
  my $sth = $dbh->prepare($sql);

  $sth->execute(@{$where_para_aref});

  my $err = 0;
  my $msg = '';
  my $unit_data = [];

  if ( !$dbh->err() ) {

    my $array_ref = $sth->fetchall_arrayref({});

    if ( !$sth->err() ) {

      $unit_data = $array_ref;
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

  my $extra_attr_unit_data = [];

  if ($extra_attr_yes) {

    my $gadmin_status = $self->authen->gadmin_status();

    my $unit_id_aref = [];

    for my $row (@{$unit_data}) {

      push(@{$unit_id_aref}, $row->{'UnitId'});
    }

    my $chk_id_err        = 0;
    my $chk_id_msg        = '';
    my $used_id_href      = {};
    my $not_used_id_href  = {};

    my $chk_gis_id_err        = 0;
    my $chk_gis_id_msg        = '';
    my $used_gis_id_href      = {};
    my $not_used_gis_id_href  = {};

    if (scalar(@{$unit_id_aref}) > 0) {

      my $chk_table_aref = [{'TableName' => 'item', 'FieldName' => 'UnitId'},
                            {'TableName' => 'trait', 'FieldName' => 'UnitId'},
                            {'TableName' => 'trialtrait', 'FieldName' => 'UnitId'},
                            {'TableName' => 'trialevent', 'FieldName' => 'UnitId'},
          ];

      ($chk_id_err, $chk_id_msg,
       $used_id_href, $not_used_id_href) = id_existence_bulk($dbh, $chk_table_aref, $unit_id_aref);

      if ($chk_id_err) {

        $self->logger->debug("Check id existence error: $chk_id_msg");
        $err = 1;
        $msg = $chk_id_msg;

        return ($err, $msg, []);
      }

      my $chk_gistable_aref = [{'TableName' => 'layerattrib', 'FieldName' => 'unitid'}];

      ($chk_gis_id_err, $chk_gis_id_msg,
       $used_gis_id_href, $not_used_gis_id_href) = id_existence_bulk($dbh_gis, $chk_gistable_aref, $unit_id_aref);

      if ($chk_gis_id_err) {

        $self->logger->debug("Check id existence error: $chk_gis_id_msg");
        $err = 1;
        $msg = $chk_gis_id_msg;

        return ($err, $msg, []);
      }

    }

    for my $row (@{$unit_data}) {

      if ($gadmin_status eq '1') {

        my $unit_id = $row->{'UnitId'};
        $row->{'update'} = "update/generalunit/$unit_id";

        if ( $not_used_id_href->{$unit_id} && $not_used_gis_id_href->{$unit_id} ) {

          $row->{'delete'}   = "delete/generalunit/$unit_id";
        }
      }
      push(@{$extra_attr_unit_data}, $row);
    }
  }
  else {

    $extra_attr_unit_data = $unit_data;
  }

  $dbh->disconnect();

  $dbh_gis->disconnect();

  return ($err, $msg, $extra_attr_unit_data);
}

sub list_general_unit_advanced_runmode {

=pod list_generalunit_advanced_HELP_START
{
"OperationName": "List units --- updated needed",
"Description": "List all available units in the system dictionary.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination Page='1' NumOfRecords='23' NumOfPages='23' NumPerPage='1' /><RecordMeta TagName='Unit' /><Unit UnitTypeName='' UseByTrialEvent='0' UnitSource='' UnitTypeId='' UnitId='24' UnitNote='' UnitName='U_5646096' UseByTrait='0' UseBylayerattrib='0' UseByItem='0' update='update/generalunit/24' /></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfRecords' : '23', 'NumOfPages' : 23, 'NumPerPage' : '1', 'Page' : '1'}], 'RecordMeta' : [{'TagName' : 'Unit'}], 'Unit' : [{'UnitTypeName' : null, 'UnitSource' : null, 'UseByTrialEvent' : '0', 'UnitTypeId' : null, 'UnitId' : '24', 'UnitNote' : null, 'UnitName' : 'U_5646096', 'UseByTrait' : '0', 'UseBylayerattrib' : '0', 'update' : 'update/generalunit/24', 'UseByItem' : '0'}]}",
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

  my $sql = 'SELECT * FROM generalunit LIMIT 1';

  my ($sample_gu_err, $sample_gu_msg, $sample_gu_data) = $self->list_general_unit(0, $sql);

  if ($sample_gu_err) {

    $self->logger->debug($sample_gu_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $sample_data_aref = $sample_gu_data;

  my @field_list_all;

  if (scalar(@{$sample_data_aref}) == 1) {

    @field_list_all = keys(%{$sample_data_aref->[0]});
  }
  else {

    $self->logger->debug("It reaches here");
    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'generalunit');

    if ($sfield_err) {

      $self->logger->debug("Get static field failed: $sfield_msg");

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    for my $sfield_rec (@{$sfield_data}) {

      push(@field_list_all, $sfield_rec->{'Name'});
    }

    for my $pkey_field (@{$pkey_data}) {

      push(@field_list_all, $pkey_field);
    }
  }

  $self->logger->debug("Field list all: " . join(',', @field_list_all));

  my $final_field_list     = \@field_list_all;

  if (length($field_list_csv) > 0) {

    my ($sel_field_err, $sel_field_msg, $sel_field_list) = parse_selected_field($field_list_csv,
                                                                                $final_field_list,
                                                                                'UnitId');

    if ($sel_field_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;
  }

  my $field_lookup = {};
  for my $fd_name (@{$final_field_list}) {

    $field_lookup->{$fd_name} = 1;
  }

  my $other_join = '';

  if ($field_lookup->{'UnitTypeId'}) {

    push(@{$final_field_list}, 'generaltype.TypeName AS UnitTypeName');
    $other_join .= ' LEFT JOIN generaltype ON generalunit.UnitTypeId = generaltype.TypeId ';
  }

  my $field_list_str = join(', ', @{$final_field_list});

  $sql    = "SELECT $field_list_str ";
  $sql   .= 'FROM generalunit ';
  $sql   .= " $other_join ";

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering('UnitId',
                                                                              'generalunit',
                                                                              $filtering_csv,
                                                                              $final_field_list);

  $self->logger->debug("Filter phrase: $filter_phrase");

  if ($filter_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $filter_msg}]};

    return $data_for_postrun_href;
  }

  my $filter_where_phrase = '';
  if (length($filter_phrase) > 0) {

    $filter_where_phrase = "WHERE $filter_phrase ";
  }

  my $filtering_exp = " $filter_where_phrase ";

  my $pagination_aref = [];
  my $paged_limit_clause = '';

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

    my ($paged_id_err, $paged_id_msg, $nb_records,
        $nb_pages, $limit_clause, $rcount_time) = get_paged_filter($dbh,
                                                                   $nb_per_page,
                                                                   $page,
                                                                   'generalunit',
                                                                   'UnitId',
                                                                   $filtering_exp,
                                                                   $where_arg
                                                                  );

    $self->logger->debug("SQL Row count time: $rcount_time");

    if ($paged_id_err == 1) {

      $self->logger->debug($paged_id_msg);

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    if ($paged_id_err == 2) {

      $page = 0;
    }

    $pagination_aref = [{'NumOfRecords' => $nb_records,
                         'NumOfPages'   => $nb_pages,
                         'Page'         => $page,
                         'NumPerPage'   => $nb_per_page,
                        }];

    $paged_limit_clause = $limit_clause;
  }

  $sql .= " $filtering_exp ";

  my ($sort_err, $sort_msg, $sort_sql) = parse_sorting($sorting, $final_field_list);

  if ($sort_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sort_msg}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  if (length($sort_sql) > 0) {

    $sql .= " ORDER BY $sort_sql ";
  }
  else {

    $sql .= ' ORDER BY generalunit.UnitId DESC';
  }

  $sql .= " $paged_limit_clause ";

  $self->logger->debug("Where arg: " . join(',', @{$where_arg}));

  $self->logger->debug("SQL with VCol: $sql");

  my ($read_generalunit_err, $read_generalunit_msg, $generalunit_data) = $self->list_general_unit(1, $sql, $where_arg);

  if ($read_generalunit_err) {

    $self->logger->debug($read_generalunit_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Unit'       => $generalunit_data,
                                           'Pagination' => $pagination_aref,
                                           'RecordMeta' => [{'TagName' => 'Unit'}],
  };

  return $data_for_postrun_href;
}

sub get_general_unit_runmode {

=pod get_generalunit_HELP_START
{
"OperationName": "Get unit",
"Description": "Get detailed information about unit specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='Unit' /><Unit UnitTypeName='' UnitSource='' UseByTrialEvent='0' UnitTypeId='' UnitId='24' UnitNote='' UnitName='U_5646096' UseByTrait='0' UseBylayerattrib='0' UseByItem='0' update='update/generalunit/24' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'Unit'}], 'Unit' : [{'UnitTypeName' : null, 'UseByTrialEvent' : '0', 'UnitSource' : null, 'UnitTypeId' : null, 'UnitId' : '24', 'UnitNote' : null, 'UnitName' : 'U_5646096', 'UseByTrait' : '0', 'UseBylayerattrib' : '0', 'update' : 'update/generalunit/24', 'UseByItem' : '0'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='UnitId (65): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error': [{'Message': 'UnitId (65): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing UnitId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;

  my $generalunit_id = $self->param('id');
  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();
  my $generalunit_exist = record_existence($dbh, 'generalunit', 'UnitId', $generalunit_id);
  $dbh->disconnect();

  if (!$generalunit_exist) {

    return $self->_set_error("UnitId ($generalunit_id): not found.");
  }

  my $sql = 'SELECT generalunit.*, generaltype.TypeName AS UnitTypeName FROM generalunit ';
  $sql   .= 'LEFT JOIN generaltype ON generalunit.UnitTypeId = generaltype.TypeId ';
  $sql   .= 'WHERE UnitId=?';

  my ($read_generalunit_err, $read_generalunit_msg, $generalunit_data) = $self->list_general_unit(1, $sql,
                                                                                                  [$generalunit_id]);

  if ($read_generalunit_err) {

    $self->logger->debug($read_generalunit_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Unit'       => $generalunit_data,
                                           'RecordMeta' => [{'TagName' => 'Unit'}],
                                          };

  return $data_for_postrun_href;
}

sub add_general_unit_runmode {

=pod add_generalunit_gadmin_HELP_START
{
"OperationName": "Add unit",
"Description": "Add a new unit definition into the system.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "generalunit",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='25' ParaName='UnitId' /><Info Message='Item unit (25) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '26', 'ParaName' : 'UnitId'}], 'Info' : [{'Message' : 'Item unit (26) has been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error UnitTypeId='UnitType (26): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'UnitTypeId' : 'UnitType (26): not found.'}]}"}],
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
                                                                                'generalunit', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $unit_name          = $query->param('UnitName');
  my $use_by_item        = $query->param('UseByItem');
  my $use_by_trait       = $query->param('UseByTrait');
  my $use_by_trial_event = $query->param('UseByTrialEvent');
  my $use_by_layerattrib = $query->param('UseBylayerattrib');

  my ($chk_bool_err, $bool_href) = check_bool_href( { 'UseByItem'          => $use_by_item,
                                                      'UseByTrait'         => $use_by_trait,
                                                      'UseByTrialEvent'    => $use_by_trial_event,
                                                      'UseBylayerattrib'   => $use_by_layerattrib } );

  if ($chk_bool_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$bool_href]};

    return $data_for_postrun_href;
  }

  my $unit_type_id      = undef;

  if (defined $query->param('UnitTypeId')) {

    if (length($query->param('UnitTypeId')) > 0) {

      $unit_type_id = $query->param('UnitTypeId');
    }
  }

  my $unit_note         = undef;

  if (defined $query->param('UnitNote')) {

    if (length($query->param('UnitNote')) > 0) {

      $unit_note = $query->param('UnitNote');
    }
  }

  my $unit_src          = undef;

  if (defined $query->param("UnitSource")) {

    if (length($query->param("UnitSource")) > 0) {

      $unit_src = $query->param("UnitSource");
    }
  }

  my $dbh_k_read = connect_kdb_read();

  my $is_unit_exist = record_existence( $dbh_k_read, 'generalunit', 'UnitName', $unit_name );

  if ($is_unit_exist) {

    my $err_msg = "UnitName ($unit_name) already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'UnitName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (defined $unit_type_id) {

    if (!type_existence($dbh_k_read, 'unittype', $unit_type_id)) {

      my $err_msg = "UnitType ($unit_type_id): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'UnitTypeId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $insert_statement = "
        INSERT into generalunit SET
            UnitTypeId=?,
            UnitName=?,
            UnitNote=?,
            UnitSource=?,
            UseByItem=?,
            UseByTrait=?,
            UseByTrialEvent=?,
            UseBylayerattrib=?
    ";

  my $sth = $dbh_k_write->prepare($insert_statement);
  $sth->execute( $unit_type_id, $unit_name, $unit_note, $unit_src,
                 $use_by_item, $use_by_trait, $use_by_trial_event, $use_by_layerattrib );

  if ( $dbh_k_write->err() ) {

    return $self->_set_error();
  }

  my $unit_id = $dbh_k_write->last_insert_id( undef, undef, 'generalunit', 'UnitId' )
      || -1;

  $self->logger->debug("UnitId: $unit_id");
  $sth->finish();
  $dbh_k_write->disconnect();

  my $info_msg_aref  = [ { 'Message' => "Item unit ($unit_id) has been added successfully." } ];
  my $return_id_aref = [ { 'Value' => $unit_id, 'ParaName' => 'UnitId' } ];

  return {
    'Error' => 0,
    'Data'  => {
      'Info'     => $info_msg_aref,
      'ReturnId' => $return_id_aref,
    },
    'ExtraData' => 0
  };
}

sub update_general_unit_runmode {

=pod update_generalunit_gadmin_HELP_START
{
"OperationName": "Update unit",
"Description": "Update unit specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "generalunit",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Unit (27) has been successfully updated.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Unit (27) has been successfully updated.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unit (72): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Unit (72): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing UnitId"}],
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
                                                                                'generalunit', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $unit_id           = $self->param('id');
  my $unit_name         = $query->param('UnitName');

  my $use_by_item        = $query->param('UseByItem');
  my $use_by_trait       = $query->param('UseByTrait');
  my $use_by_trial_event = $query->param('UseByTrialEvent');
  my $use_by_layerattrib = $query->param('UseBylayerattrib');

  my ($chk_bool_err, $bool_href) = check_bool_href( { 'UseByItem'          => $use_by_item,
                                                      'UseByTrait'         => $use_by_trait,
                                                      'UseByTrialEvent'    => $use_by_trial_event,
                                                      'UseBylayerattrib'   => $use_by_layerattrib } );

  if ($chk_bool_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$bool_href]};

    return $data_for_postrun_href;
  }

  my $dbh_k_read = connect_kdb_read();

  my $sql = 'SELECT UnitId FROM generalunit WHERE UnitName=? AND UnitId<>?';

  my ($r_unit_err, $db_unit_id) = read_cell($dbh_k_read, $sql, [$unit_name, $unit_id]);

  if ($r_unit_err) {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_unit_id) > 0) {

    my $err_msg = "UnitName ($unit_name) already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'UnitName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (!record_existence( $dbh_k_read, 'generalunit', 'UnitId', $unit_id )) {

    my $err_msg = "Unit ($unit_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }


  my $read_gu_sql    =   'SELECT UnitTypeId, UnitNote, UnitSource ';
     $read_gu_sql   .=   'FROM generalunit WHERE UnitId=? ';

  my ($r_df_val_err, $r_df_val_msg, $gu_df_val_data) = read_data($dbh_k_read, $read_gu_sql, [$unit_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve generalunit default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $unit_type_id     =   undef;
  my $unit_note        =   undef;
  my $unit_src         =   undef;

  my $nb_df_val_rec    =  scalar(@{$gu_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve generalunit default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $unit_type_id       =   $gu_df_val_data->[0]->{'UnitTypeId'};
  $unit_note          =   $gu_df_val_data->[0]->{'UnitNote'};
  $unit_src           =   $gu_df_val_data->[0]->{'UnitSource'};


  if (length($unit_type_id) == 0) {

    $unit_type_id = undef;
  }

  if (defined $query->param('UnitTypeId')) {

    if (length($query->param('UnitTypeId')) > 0) {

      $unit_type_id = $query->param('UnitTypeId');

      if (!type_existence($dbh_k_read, 'unittype', $unit_type_id)) {

        my $err_msg = "UnitType ($unit_type_id): not found.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'UnitTypeId' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
  }


  if (length($unit_note) == 0) {

    $unit_note = undef;
  }

  if (defined $query->param('UnitNote')) {

    if (length($query->param('UnitNote')) > 0) {

      $unit_note = $query->param('UnitNote');
    }
  }


  if (length($unit_src) == 0) {

    $unit_src = undef;
  }

  if (defined $query->param('UnitSource')) {

    if (length($query->param('UnitSource')) > 0) {

      $unit_src = $query->param('UnitSource');
    }
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  $sql    = "UPDATE generalunit SET ";
  $sql   .= "UnitTypeId=?, ";
  $sql   .= "UnitName=?, ";
  $sql   .= "UnitNote=?, ";
  $sql   .= "UnitSource=?, ";
  $sql   .= "UseByItem=?, ";
  $sql   .= "UseByTrait=?, ";
  $sql   .= "UseByTrialEvent=?, ";
  $sql   .= "UseBylayerattrib=? ";
  $sql   .= "WHERE UnitId=?";

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute( $unit_type_id, $unit_name, $unit_note, $unit_src,
                 $use_by_item, $use_by_trait, $use_by_trial_event, $use_by_layerattrib,
                 $unit_id );

  if ( $dbh_k_write->err() ) {

    return $self->_set_error();
  }

  $self->logger->debug("UnitId: $unit_id updated");
  $sth->finish();
  $dbh_k_write->disconnect();

  my $info_msg_aref = [ { 'Message' => "Unit ($unit_id) has been successfully updated." } ];

  return {
    'Error'     => 0,
    'Data'      => { 'Info' => $info_msg_aref, },
    'ExtraData' => 0
  };
}

sub del_general_unit_runmode {

=pod del_generalunit_gadmin_HELP_START
{
"OperationName": "Delete unit",
"Description": "Delete a unit definition from a system. Unit definition can be deleted only if not attached to any lower level related record.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Unit (27) has been successfully deleted.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Unit (29) has been successfully deleted.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unit (72): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Unit (72): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing UnitId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my ($self) = @_;

  my $data_for_postrun_href = {};

  my $unit_id = $self->param('id');

  my $dbh_k_read   = connect_kdb_read();

  my $dbh_gis_read = connect_gis_read();

  my $is_unit_id_exist = record_existence( $dbh_k_read, 'generalunit', 'UnitId', $unit_id );

  if ( !$is_unit_id_exist ) {

    return $self->_set_error("UnitId ($unit_id): not found.");
  }

  my $is_unit_attached_to_item = record_existence( $dbh_k_read, 'item', 'UnitId', $unit_id );

  if ($is_unit_attached_to_item) {

    return $self->_set_error("UnitId ($unit_id): is used in item.");
  }

  if (record_existence($dbh_k_read, 'trait', 'UnitId', $unit_id)) {

    my $err_msg = "Unit ($unit_id): is used in trait.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (record_existence($dbh_k_read, 'trialevent', 'UnitId', $unit_id)) {

    my $err_msg = "Unit ($unit_id): is used in trialevent.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (record_existence($dbh_gis_read, 'layerattrib', 'unitid', $unit_id)) {

    my $err_msg = "Unit ($unit_id): is used in layerattrib.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_gis_read->disconnect();

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $insert_statement = "DELETE FROM generalunit WHERE UnitId=?";
  my $sth              = $dbh_k_write->prepare($insert_statement);
  $sth->execute($unit_id);

  if ( $dbh_k_write->err() ) {

    return $self->_set_error();
  }

  $self->logger->debug("UnitId: $unit_id deleted");
  $sth->finish();
  $dbh_k_write->disconnect();

  my $info_msg_aref = [ { 'Message' => "Unit ($unit_id) has been successfully deleted." } ];

  return {
    'Error'     => 0,
    'Data'      => { 'Info' => $info_msg_aref, },
    'ExtraData' => 0
  };
}

# Managing items
###########################################################################

sub list_item_advanced_runmode {

=pod list_item_advanced_HELP_START
{
"OperationName": "List items",
"Description": "List inventory items in the system. Listing requires pagination definition.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination NumOfRecords='20' NumOfPages='20' Page='1' NumPerPage='1' /><Item DateAdded='2015-09-29 16:39:50' ItemId='20' ItemState='Seed - 0990613' AddedByUserId='0' ItemTypeId='134' TrialUnitSpecimenId='' ContainerTypeId='132' ItemNote='' ItemStateId='135' SpecimenId='30' ScaleId='12' LastMeasuredUserId='0' addParent='item/20/add/parent' DeviceNote='' SpecimenName='Specimen_5478572' ItemOperation='group' ItemBarcode='I_6356286' StorageId='6' ItemSource='Add Item' UnitId='11' StorageLocation='Non existing' Amount='5.000' ItemSourceId='12' LastMeasuredDate='2015-09-29 16:39:50' ItemType='Seed - 0990613' UnitName='U_1442236' AddedByUser='admin' delete='delete/item/20' update='update/item/20' /><RecordMeta TagName='Item' /></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfRecords' : '20', 'NumOfPages' : 20, 'NumPerPage' : '1', 'Page' : '1'}], 'VCol' : [], 'Item' : [{'DateAdded' : '2015-09-29 16:39:50', 'ItemId' : '20', 'ItemState' : 'Seed - 0990613', 'AddedByUserId' : '0', 'TrialUnitSpecimenId' : null, 'ItemTypeId' : '134', 'ContainerTypeId' : '132', 'ItemNote' : '', 'ItemStateId' : '135', 'ScaleId' : '12', 'SpecimenId' : '30', 'addParent' : 'item/20/add/parent', 'DeviceNote' : '', 'SpecimenName' : 'Specimen_5478572', 'ItemOperation' : 'group', 'ItemBarcode' : 'I_6356286', 'LastMeasuredUserId' : '0', 'StorageId' : '6', 'ItemSource' : 'Add Item', 'UnitId' : '11', 'StorageLocation' : 'Non existing', 'Amount' : '5.000', 'UnitName' : 'U_1442236', 'ItemType' : 'Seed - 0990613', 'LastMeasuredDate' : '2015-09-29 16:39:50', 'ItemSourceId' : '12', 'delete' : 'delete/item/20', 'AddedByUser' : 'admin', 'update' : 'update/item/20'}], 'RecordMeta' : [{'TagName' : 'Item'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"URLParameter": [{"ParameterName": "nperpage", "Description": "Number of records in a page for pagination"}, {"ParameterName": "num", "Description": "The page number of the pagination"}],
"HTTPParameter": [{"Required": 0, "Name": "Filtering", "Description": "Filtering parameter string consisting of filtering expressions which are separated by ampersand (&) which needs to be encoded if HTTP GET method is used. Each filtering expression is composed of a database field name, a filtering operator and the filtering value."}, {"Required": 0, "Name": "FieldList", "Description": "Comma separated value of wanted fields."}, {"Required": 0, "Name": "Sorting", "Description": "Comma separated value of SQL sorting phrases."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my ($self) = @_;

  my $query = $self->query();
  my $dbh   = connect_kdb_read();

  my $pagination  = 0;
  my $nb_per_page = -1;
  my $page        = -1;

  my $data_for_postrun_href = {};

  if ( (defined $self->param('nperpage')) && (defined $self->param('num')) ) {

    $pagination  = 1;
    $nb_per_page = $self->param('nperpage');
    $page        = $self->param('num');
  }

  $self->logger->debug("Page number: $page");

  my $field_list_csv = $query->param('FieldList') ? $query->param('FieldList') : '';
  my $filtering_csv  = $query->param('Filtering') ? $query->param('Filtering') : '';
  my $sorting        = $query->param('Sorting')   ? $query->param('Sorting')   : '';

  my $field_list = [ 'item.*', 'VCol*' ];
  my ( $vcol_err, $trouble_vcol, $sql, $vcol_list ) = generate_factor_sql( $dbh, $field_list,
                                                                           'item', 'ItemId', '' );

  return $self->_set_error("Problem with virtual column ($trouble_vcol) containing space.") if $vcol_err;

  $sql .= " LIMIT 1";

  $self->logger->debug("SQL with VCol: $sql");

  my ($samp_itm_d_err, $samp_itm_d_msg, $item_data) = $self->list_item(0, $sql);

  if ($samp_itm_d_err) {

    $self->logger->debug("Retrieve sample item data failed: $samp_itm_d_msg");
    return $self->_set_error();
  }

  my $sample_data_aref = $item_data;

  my @field_list_all;

  if (scalar(@{$sample_data_aref}) == 1) {

    @field_list_all = keys(%{$sample_data_aref->[0]});
  }
  else {

    $self->logger->debug("It reaches here");
    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'item');

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

  $self->logger->debug("Final field list: " . join(',', @{$final_field_list}));

  if ( length($field_list_csv) > 0 ) {

    my ( $sel_field_err, $sel_field_msg, $sel_field_list ) = parse_selected_field( $field_list_csv,
                                                                                   $final_field_list,
                                                                                   'ItemId' );
    if ($sel_field_err) {

      return $self->_set_error($sel_field_msg);
    }
    $final_field_list = $sel_field_list;
  }

  my $join = '';

  foreach my $field ( @{$final_field_list} ) {

    if ( $field =~ /^ItemSourceId$/i) {

      push( @{$final_field_list}, 'CONCAT(contact.ContactFirstName, " ", contact.ContactLastName) AS ItemSource' );
      $join .= ' LEFT JOIN contact ON contact.ContactId = item.ItemSourceId ';
    }
    elsif ($field =~ /^UnitId$/i) {

      push( @{$final_field_list}, 'generalunit.UnitName' );
      $join .= ' LEFT JOIN generalunit ON generalunit.UnitId = item.UnitId ';
    }
    elsif ($field =~ /^SpecimenId$/i) {

      push( @{$final_field_list}, 'specimen.SpecimenName' );
      $join .= ' LEFT JOIN specimen ON specimen.SpecimenId = item.SpecimenId ';
    }
    elsif ($field =~ /^StorageId$/i) {

      push( @{$final_field_list}, 'storage.StorageLocation' );
      push( @{$final_field_list}, 'storage.StorageBarcode' );
      $join .= ' LEFT JOIN storage ON storage.StorageId = item.StorageId ';
    }
    elsif ($field =~ /^ItemTypeId$/i) {

      push( @{$final_field_list}, 'gt_itemtype.TypeName as ItemTypeName' );
      push( @{$final_field_list}, 'gt_itemstate.TypeName as ItemStateName' );
      $join .= ' LEFT JOIN generaltype as gt_itemtype ON gt_itemtype.TypeId = item.ItemTypeId ';
      $join .= ' LEFT JOIN generaltype as gt_itemstate ON gt_itemstate.TypeId = item.ItemStateId ';
    }
    elsif ($field =~ /^ScaleId$/i) {

      push( @{$final_field_list}, 'deviceregister.DeviceNote' );
      $join .= ' LEFT JOIN deviceregister ON deviceregister.DeviceRegisterId = item.ScaleId ';
    }
    elsif ($field =~ /^AddedByUserId$/i) {

      push( @{$final_field_list}, 'systemuser.UserName as AddedByUser' );
      $join .= ' LEFT JOIN systemuser ON systemuser.UserId = item.AddedByUserId ';
    }
  }

  $self->logger->debug("Final field list: " . join(',', @{$final_field_list}));

  ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql(	$dbh, $final_field_list,
                                                                      'item', 'ItemId', $join );

  my ( $filter_err, $filter_msg, $filter_phrase, $where_arg ) = parse_filtering( 'ItemId', 'item',
                                                                                 $filtering_csv, $final_field_list );
  if ($filter_err) {

    return $self->_set_error($filter_msg);
  }

  my $filter_where_phrase = '';
  if (length($filter_phrase) > 0) {

    $filter_where_phrase = " WHERE $filter_phrase ";
  }

  my $filtering_exp = $filter_where_phrase;

  my $pagination_aref = [];
  my $paged_limit_clause = '';

  if ($pagination) {

    my ( $int_err, $int_err_msg ) = check_integer_value( { 'nperpage' => $nb_per_page,
                                                           'num'      => $page
                                                         } );
    if ($int_err) {

      $int_err_msg .= ' not integer.';
      return $self->_set_error($int_err_msg);
    }

    my ( $paged_id_err, $paged_id_msg, $nb_records,
         $nb_pages, $limit_clause, $sql_count_time ) = get_paged_filter($dbh,
                                                                        $nb_per_page,
                                                                        $page,
                                                                        'item',
                                                                        'ItemId',
                                                                        $filtering_exp,
                                                                        $where_arg
             );

    $self->logger->debug("SQL Count time: $sql_count_time");

    if ( $paged_id_err == 1 ) {

      $self->logger->debug($paged_id_msg);
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error.'}]};

      return $data_for_postrun_href;
    }

    if ( $paged_id_err == 2 ) {

      $page = 0;
    }

    $pagination_aref = [ { 'NumOfRecords' => $nb_records,
                           'NumOfPages'   => $nb_pages,
                           'Page'         => $page,
                           'NumPerPage'   => $nb_per_page,
                         } ];

    $paged_limit_clause = $limit_clause;
  }

  $dbh->disconnect();

  $sql  =~ s/GROUP BY/ $filtering_exp GROUP BY /;

  my ( $sort_err, $sort_msg, $sort_sql ) = parse_sorting( $sorting, $final_field_list );

  return $self->_set_error($sort_msg) if $sort_err;

  $sql .= length($sort_sql) > 0 ? " ORDER BY $sort_sql " : ' ORDER BY item.ItemId DESC';

  $sql .= " $paged_limit_clause ";

  $self->logger->debug("Final list item SQL: $sql");

  my ($list_item_err, $list_item_msg, $data_aref) = $self->list_item(1, $sql, $where_arg);

  if ($list_item_err) {

    $self->logger->debug("List item failed: $list_item_msg");
    return $self->_set_error('Unexpected error.');
  }

  return {
    'Error' => 0,
    'Data'  => {
      'Item'       => $data_aref,
      'VCol'       => $vcol_list,
      'Pagination' => $pagination_aref,
      'RecordMeta' => [ { 'TagName' => 'Item' } ],
    }
  };
}

sub get_item_runmode {

=pod get_item_HELP_START
{
"OperationName": "Get item",
"Description": "Get detailed information about an inventory item for specified id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Item DateAdded='2014-07-01 13:16:02' ItemId='1' ItemState='Seed - 3592281' AddedByUserId='0' ItemTypeId='34' TrialUnitSpecimenId='0' ContainerTypeId='32' ItemNote='Testing' ItemStateId='35' DeviceId='' ScaleId='2' SpecimenId='13' ItemBarcode='I_6498409' addParent='item/1/add/parent' SpecimenName='Specimen_7681379' ItemOperation='group' LastMeasuredUserId='0' UnitId='3' StorageId='1' ItemSource='Add Item' StorageLocation='Non existing' ItemUnitName='U_1281774' Amount='50.000' ItemType='Seed - 3592281' LastMeasuredDate='2012-08-01 00:00:00' ItemSourceId='7' AddedByUser='admin' delete='delete/item/1' update='update/item/1' /><RecordMeta TagName='Item' /></DATA>",
"SuccessMessageJSON": "{'VCol' : [], 'Item' : [{'DateAdded' : '2014-07-01 13:16:02', 'ItemId' : '1', 'ItemState' : 'Seed - 3592281', 'AddedByUserId' : '0', 'TrialUnitSpecimenId' : '0', 'ItemTypeId' : '34', 'ContainerTypeId' : '32', 'ItemNote' : 'Testing', 'ItemStateId' : '35', 'DeviceId' : null, 'SpecimenId' : '13', 'ScaleId' : '2', 'addParent' : 'item/1/add/parent', 'SpecimenName' : 'Specimen_7681379', 'ItemOperation' : 'group', 'LastMeasuredUserId' : '0', 'ItemBarcode' : 'I_6498409', 'UnitId' : '3', 'StorageId' : '1', 'ItemSource' : 'Add Item', 'StorageLocation' : 'Non existing', 'ItemUnitName' : 'U_1281774', 'Amount' : '50.000', 'ItemSourceId' : '7', 'LastMeasuredDate' : '2012-08-01 00:00:00', 'ItemType' : 'Seed - 3592281', 'delete' : 'delete/item/1', 'AddedByUser' : 'admin', 'update' : 'update/item/1'}], 'RecordMeta' : [{'TagName' : 'Item'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='ItemId (45) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'ItemId (45) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing ItemId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my ($self) = @_;

  my $id = $self->param('id');

  my $dbh = connect_kdb_read();

  if ( !record_existence( $dbh, 'item', 'ItemId', $id ) ) {

    return $self->_set_error("ItemId ($id) not found.");
  }

  my $field_list = [ 'item.*', 'VCol*',
                     'CONCAT(contact.ContactFirstName, " ", contact.ContactLastName) AS ItemSource',
                     'generalunit.UnitName',
                     'specimen.SpecimenName',
                     'storage.StorageLocation',
                     'storage.StorageBarcode',
                     'a.TypeName as ItemTypeName',
                     'b.TypeName as ItemStateName',
                     'deviceregister.DeviceId',
                     'systemuser.UserName as AddedByUser',
      ];

  my $other_join = ' LEFT JOIN contact ON contact.ContactId = item.ItemSourceId';
  $other_join   .= ' LEFT JOIN generalunit ON generalunit.UnitId = item.UnitId';
  $other_join   .= ' LEFT JOIN specimen ON specimen.SpecimenId = item.SpecimenId';
  $other_join   .= ' LEFT JOIN storage ON storage.StorageId = item.StorageId';
  $other_join   .= ' LEFT JOIN generaltype as a ON a.TypeId = item.ItemTypeId';
  $other_join   .= ' LEFT JOIN generaltype as b ON b.TypeId = item.ItemStateId';
  $other_join   .= ' LEFT JOIN deviceregister ON deviceregister.DeviceRegisterId = item.ScaleId';
  $other_join   .= ' LEFT JOIN systemuser ON systemuser.UserId = item.AddedByUserId';

  my ( $vcol_err, $trouble_vcol, $sql, $vcol_list ) = generate_factor_sql( $dbh, $field_list, 'item',
                                                                           'ItemId', $other_join );

  $dbh->disconnect();

  if ($vcol_err) {

    return $self->_set_error("Problem with virtual column ($trouble_vcol) containing space.");
  }

  my $filtering_exp = ' WHERE item.ItemId=? ';

  $sql  =~ s/GROUP BY/ $filtering_exp GROUP BY /;

  my ($list_item_err, $list_item_msg, $data_aref) = $self->list_item(1, $sql, [$id]);

  if ($list_item_err) {

    $self->logger->debug("List failed: $list_item_msg");
    return $self->_set_error('Unexpected error.');
  }

  return {
    'Error' => 0,
    'Data'  => {
      'Item'       => $data_aref,
      'VCol'       => $vcol_list,
      'RecordMeta' => [ { 'TagName' => 'Item' } ],
    }
  };
}

sub del_item_runmode {

=pod del_item_gadmin_HELP_START
{
"OperationName": "Delete item",
"Description": "Delete inventory item for specified id. Item can be deleted only if not attached to any lower level related record.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Item (20) has been successfully deleted.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Item (21) has been successfully deleted.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Item (45): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Item (45): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing ItemId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my ($self) = @_;
  my $item_id = $self->param('id');

  my $dbh_k_read = connect_kdb_read();

  my $data_for_postrun_href = {};

  if (!record_existence($dbh_k_read, 'item', 'ItemId', $item_id)) {

    my $err_msg = "Item ($item_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $is_item_has_trialunitspecimen = record_existence( $dbh_k_read, 'trialunitspecimen', 'ItemId', $item_id );

  if ($is_item_has_trialunitspecimen) {

    return $self->_set_error("Item ($item_id): used in trialunitspecimen.");
  }

  my $is_item_is_parent = record_existence( $dbh_k_read, 'itemparent', 'ParentId', $item_id );

  if ($is_item_is_parent) {

    return $self->_set_error("Item ($item_id): has a child item.");
  }

  my $is_item_child = record_existence( $dbh_k_read, 'itemparent', 'ItemId', $item_id );

  if ($is_item_child) {

    return $self->_set_error("Item ($item_id): has a parent item.");
  }

  my $is_item_in_group = record_existence( $dbh_k_read, 'itemgroupentry', 'ItemId', $item_id );

  if ($is_item_in_group) {

    return $self->_set_error("Item ($item_id): has a group.");
  }

  my $dbh_k_write = connect_kdb_write();

  my $statement = "DELETE FROM itemlog WHERE ItemId=?";
  my $sth       = $dbh_k_write->prepare($statement);
  $sth->execute($item_id);

  if ( $dbh_k_write->err() ) {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }


  $statement = "DELETE FROM item WHERE ItemId=?";
  $sth       = $dbh_k_write->prepare($statement);
  $sth->execute($item_id);

  if ( $dbh_k_write->err() ) {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("ItemId: $item_id deleted");
  $sth->finish();
  $dbh_k_write->disconnect();

  my $info_msg_aref = [ { 'Message' => "Item ($item_id) has been successfully deleted." } ];

  return {
    'Error'     => 0,
    'Data'      => { 'Info' => $info_msg_aref, },
    'ExtraData' => 0
  };
}

sub add_item_runmode {

=pod add_item_HELP_START
{
"OperationName": "Add item",
"Description": "Add a new inventory item to the system.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "item",
"SkippedField": ["DateAdded", "AddedByUserId", "LastUpdateTimeStamp"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='34' ParaName='ItemId' /><Info Message='Item (34) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '35','ParaName' : 'ItemId'}],'Info' : [{'Message' : 'Item (35) has been added successfully.'}]}",
"ErrorMessageXML": [{"MissingParameter": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error ItemBarcode='ItemBarcode is missing.' /></DATA>"}],
"ErrorMessageJSON": [{"MissingParameter": "{'Error' : [{'ItemBarcode' : 'ItemBarcode is missing.'}]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self     = shift;
  my $query    = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'DateAdded'           => 1,
                    'AddedByUserId'       => 1,
                    'LastUpdateTimeStamp' => 1,
                   };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'item', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $cur_dt = DateTime->now( time_zone => $TIMEZONE );
  $cur_dt = DateTime::Format::MySQL->format_datetime($cur_dt);

  my $item_specimen        = $query->param('SpecimenId');
  my $item_type            = $query->param('ItemTypeId');

  my $item_barcode         = undef;

  if (defined $query->param('ItemBarcode')) {

    if (length($query->param('ItemBarcode')) > 0) {

      $item_barcode = $query->param('ItemBarcode');
    }
  }

  my $trial_unit_spec_id   = undef;

  if (defined $query->param('TrialUnitSpecimenId')) {

    if (length($query->param('TrialUnitSpecimenId')) > 0) {

      $trial_unit_spec_id = $query->param('TrialUnitSpecimenId');
    }
  }

  my $item_source          = undef;

  if (defined $query->param('ItemSourceId')) {

    if (length($query->param('ItemSourceId')) > 0) {

      $item_source = $query->param('ItemSourceId');
    }
  }

  my $item_container_type  = undef;

  if (defined $query->param('ContainerTypeId')) {

    if (length($query->param('ContainerTypeId')) > 0) {

      $item_container_type = $query->param('ContainerTypeId');
    }
  }

  my $item_scale           = undef;

  if (defined $query->param('ScaleId')) {

    if (length($query->param('ScaleId')) > 0) {

      $item_scale = $query->param('ScaleId');
    }
  }

  my $item_storage         = undef;

  if (defined $query->param('StorageId')) {

    if (length($query->param('StorageId')) > 0) {

      $item_storage = $query->param('StorageId');
    }
  }

  my $item_unit            = undef;

  if (defined $query->param('UnitId')) {

    if (length($query->param('UnitId')) > 0) {

      $item_unit = $query->param('UnitId');
    }
  }

  my $item_state           = undef;

  if (defined $query->param('ItemStateId')) {

    if (length($query->param('ItemStateId')) > 0) {

      $item_state = $query->param('ItemStateId');
    }
  }

  my $item_amount          = '0';

  if (defined $query->param('Amount')) {

    if (length($query->param('Amount')) > 0) {

      $item_amount = $query->param('Amount');
    }
  }

  my $item_measure_date    = $cur_dt;

  if (defined $query->param('LastMeasuredDate')) {

    $item_measure_date = $query->param('LastMeasuredDate');
  }

  my $item_measure_by_user = '-1';

  if (defined $query->param('LastMeasuredUserId')) {

    if (length($query->param('LastMeasuredUserId')) > 0) {

      $item_measure_by_user = $query->param('LastMeasuredUserId');
    }
  }

  my $item_operation       = '';

  if (defined $query->param('ItemOperation')) {

    $item_operation = $query->param('ItemOperation');
  }

  my $item_note            = '';

  if (defined $query->param('ItemNote')) {

    $item_note = $query->param('ItemNote');
  }

  my $item_added_date      = $cur_dt;

  if (defined $query->param('DateAdded')) {

    if (length($query->param('DateAdded')) > 0) {

      $item_added_date = $query->param('DateAdded');

      my ( $mdt_err, $mdt_href ) = check_dt_href( { 'DateAdded' => $item_added_date } );

      if ($mdt_err) {

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [$mdt_href]};

        return $data_for_postrun_href;
      }
    }
  }

  my $item_added_by_user   = $self->authen->user_id();

  my $dbh_k_write = connect_kdb_write();

  if (defined $trial_unit_spec_id) {

    my $tuspec_specimen_id  = read_cell_value($dbh_k_write, 'trialunitspecimen', 'SpecimenId', 'TrialUnitSpecimenId', $trial_unit_spec_id);

    if (length($tuspec_specimen_id) == 0) {

      my $err_msg = "TrialUnitSpecimen ($trial_unit_spec_id): not found.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'TrialUnitSpecimenId' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if ("$item_specimen" ne "$tuspec_specimen_id") {

      my $err_msg = "TrialUnitSpecimen ($trial_unit_spec_id) and SpecimenId ($item_specimen): ambiguous.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'TrialUnitSpecimenId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (defined $item_source) {

    if (!record_existence($dbh_k_write, 'contact', 'ContactId', $item_source)) {

      my $err_msg = "ItemSource ($item_source): not found.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'ItemSourceId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (defined $item_container_type) {

    if (!type_existence($dbh_k_write, 'container', $item_container_type)) {

      my $err_msg = "ContainerTypeId ($item_container_type): not found or inactive.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'ContainerTypeId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (!record_existence($dbh_k_write, 'specimen', 'SpecimenId', $item_specimen)) {

    my $err_msg = "Specimen ($item_specimen): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'SpecimenId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (defined $item_scale) {

    if (!record_existence($dbh_k_write, 'deviceregister', 'DeviceRegisterId', $item_scale)) {

      my $err_msg = "Scale ($item_scale): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'ScaleId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (defined $item_storage) {

    if (!record_existence($dbh_k_write, 'storage', 'StorageId', $item_storage)) {

      my $err_msg = "Storage ($item_storage): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'StorageId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (defined $item_unit) {

    if (!record_existence($dbh_k_write, 'generalunit', 'UnitId', $item_unit)) {

      my $err_msg = "UnitId ($item_unit): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'UnitId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (!type_existence($dbh_k_write, 'item', $item_type)) {

    my $err_msg = "ItemTypeId ($item_type): not found or inactive.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'ItemTypeId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (defined $item_state) {

    if (!type_existence($dbh_k_write, 'state', $item_state)) {

      my $err_msg = "ItemStateId ($item_state): not found or inactive.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'ItemStateId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (defined $item_barcode) {

    if (record_existence($dbh_k_write, 'item', 'ItemBarcode', $item_barcode)) {

      my $err_msg = "ItemBarcode ($item_barcode): already exits.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'ItemBarcode' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if ($item_amount ne '0') {

    my ($afloat_err, $afloat_href) = check_float_href( { 'Amount' => $item_amount } );

    if ($afloat_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [$afloat_href]};

      return $data_for_postrun_href;
    }
  }

  if (length($item_measure_date) > 0) {

    my ( $mdt_err, $mdt_href ) = check_dt_href( { 'LastMeasuredDate' => $item_measure_date } );

    if ($mdt_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [$mdt_href]};

      return $data_for_postrun_href;
    }
  }

  if ($item_measure_by_user ne '-1') {

    if (!record_existence($dbh_k_write, 'systemuser', 'UserId', $item_measure_by_user)) {

      my $err_msg = "LastMeasuredUser ($item_measure_by_user): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'LastMeasuredUserId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (length($item_operation) > 0) {

    if ( $item_operation !~ /^subsample|^group/ ) {

      my $err_msg = ' can only be subsample or group.';;

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'ItemOperation' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  # Get the virtual col from the factor table
  my $vcol_data              = $self->_get_item_factor();
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
  my ( $vcol_missing_err, $vcol_missing_href ) = check_missing_href($vcol_param_data);

  if ($vcol_missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$vcol_missing_href]};

    return $data_for_postrun_href;
  }

  my ( $vcol_maxlen_err, $vcol_maxlen_href ) = check_maxlen_href( $vcol_param_data_maxlen, $vcol_len_info );

  if ($vcol_maxlen_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$vcol_maxlen_href]};

    return $data_for_postrun_href;
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str      = permission_phrase($group_id, 0, $gadmin_status, 'specimen');

  my $spec_perm_sql = "SELECT $perm_str AS UltimatePerm FROM specimen ";
  $spec_perm_sql   .= "WHERE SpecimenId=?";

  my ($r_spec_perm_err, $spec_perm) = read_cell($dbh_k_write, $spec_perm_sql, [$item_specimen]);

  if ($r_spec_perm_err) {

    $self->logger->debug("Read specimen permission faile");
    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($spec_perm) == 0) {

    my $err_msg = "SpecimenId ($item_specimen): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( ($spec_perm & $READ_PERM) != $READ_PERM ) {

    my $err_msg = "SpecimenId ($item_specimen): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $insert_statement = "
        INSERT into item SET
            TrialUnitSpecimenId=?,
	          ItemSourceId=?,
            ContainerTypeId=?,
            SpecimenId=?,
            ScaleId=?,
            StorageId=?,
            UnitId=?,
            ItemTypeId=?,
            ItemStateId=?,
            ItemBarcode=?,
            Amount=?,
            DateAdded=?,
            AddedByUserId=?,
            LastMeasuredDate=?,
            LastMeasuredUserId=?,
            ItemOperation=?,
            ItemNote=?,
            LastUpdateTimeStamp=?
    ";

  my $sth = $dbh_k_write->prepare($insert_statement);
  $sth->execute( $trial_unit_spec_id, $item_source, $item_container_type, $item_specimen, $item_scale,
                 $item_storage, $item_unit, $item_type, $item_state, $item_barcode, $item_amount,
                 $item_added_date, $item_added_by_user, $item_measure_date, $item_measure_by_user,
                 $item_operation, $item_note, $cur_dt
      );

  if ( $dbh_k_write->err() ) {

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $item_id = $dbh_k_write->last_insert_id( undef, undef, 'item', 'ItemId' )
      || -1;
  $self->logger->debug("ItemId: $item_id");
  $sth->finish();
  $dbh_k_write->disconnect();

  my $success = $self->_add_factor( $item_id, $vcol_data );
  if ( !$success ) {

    $self->logger->debug('Adding factor failed');
    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $cur_dt =~ s/T/ /; # MySQL format has T between date and time

  my $info_msg_aref      = [ { 'Message' => "Item ($item_id) has been added successfully." } ];
  my $return_id_aref     = [ { 'Value' => "$item_id", 'ParaName' => 'ItemId' } ];
  my $return_other_aref  = [ { 'Value' => "$cur_dt", 'ParaName' => 'LastUpdateTimeStamp' } ];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'        => $info_msg_aref,
                                           'ReturnId'    => $return_id_aref,
                                           'ReturnOther' => $return_other_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_item_runmode {

=pod update_item_gadmin_HELP_START
{
"OperationName": "Update item",
"Description": "Update inventory items for specified id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "item",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Item (34) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Item (34) has been updated successfully.'}]}",
"ErrorMessageXML": [{"MissingParameter": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error ItemBarcode='ItemBarcode is missing.' /></DATA>"}],
"ErrorMessageJSON": [{"MissingParameter": "{'Error' : [{'ItemBarcode' : 'ItemBarcode is missing.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing ItemId"}],
"HTTPParameter": [{"ParameterName": "Filtering", "Description": "Filtering parameter string consisting of filtering expressions which are separated by ampersand (&) which needs to be encoded if HTTP GET method is used. Each filtering expression is composed of a database field name, a filtering operator and the filtering value.", "Required": "0"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my ($self) = @_;

  my $item_id = $self->param('id');

  my $query                = $self->query();

  my $filtering_csv = '';

  if (defined $query->param('Filtering')) {

    $filtering_csv = $query->param('Filtering');
  }

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'DateAdded'     => 1,
                    'AddedByUserId' => 1,
                   };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'item', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $item_specimen        = $query->param('SpecimenId');
  my $item_type            = $query->param('ItemTypeId');
  my $last_update_ts       = $query->param('LastUpdateTimeStamp');

  my $dbh_k_write = connect_kdb_write();

  if (!record_existence($dbh_k_write, 'item', 'ItemId', $item_id)) {

    my $err_msg = "Item ($item_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $read_item_sql   =   'SELECT TrialUnitSpecimenId, ItemSourceId, ContainerTypeId, ScaleId, ItemBarcode, ';
  $read_item_sql     .=   'StorageId, UnitId, ItemStateId, Amount, LastMeasuredUserId, ItemOperation, ItemNote, DateAdded  ';
  $read_item_sql     .=   'FROM item WHERE ItemId=? ';

  my ($r_df_val_err, $r_df_val_msg, $item_df_val_data) = read_data($dbh_k_write, $read_item_sql, [$item_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve item default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $trial_unit_spec_id          =   undef;
  my $item_source                 =   undef;
  my $item_container_type         =   undef;
  my $item_scale                  =   undef;
  my $item_storage                =   undef;
  my $item_unit                   =   undef;
  my $item_state                  =   undef;
  my $item_amount                 =   undef;
  my $item_measure_by_user        =   undef;
  my $item_operation              =   undef;
  my $item_note                   =   undef;
  my $item_barcode                =   undef;
  my $item_date_added             =   undef;

  my $nb_df_val_rec    =  scalar(@{$item_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve item default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $trial_unit_spec_id          =   $item_df_val_data->[0]->{'TrialUnitSpecimenId'};
  $item_source                 =   $item_df_val_data->[0]->{'ItemSourceId'};
  $item_container_type         =   $item_df_val_data->[0]->{'ContainerTypeId'};
  $item_scale                  =   $item_df_val_data->[0]->{'ScaleId'};
  $item_storage                =   $item_df_val_data->[0]->{'StorageId'};
  $item_unit                   =   $item_df_val_data->[0]->{'UnitId'};
  $item_state                  =   $item_df_val_data->[0]->{'ItemStateId'};
  $item_operation              =   $item_df_val_data->[0]->{'ItemOperation'};
  $item_note                   =   $item_df_val_data->[0]->{'ItemNote'};
  $item_barcode                =   $item_df_val_data->[0]->{'ItemBarcode'};
  $item_amount                 =   $item_df_val_data->[0]->{'Amount'};
  $item_measure_by_user        =   $item_df_val_data->[0]->{'LastMeasuredUserId'};
  $item_date_added             =   $item_df_val_data->[0]->{'DateAdded'};

  if (length($item_barcode) == 0) {

    $item_barcode = undef;
  }

  if (defined $query->param('ItemBarcode')) {

    if (length($query->param('ItemBarcode')) > 0) {

      $item_barcode = $query->param('ItemBarcode');
    }
  }

  if (length($trial_unit_spec_id) == 0) {

    $trial_unit_spec_id = undef;
  }

  if (defined $query->param('TrialUnitSpecimenId')) {

    if (length($query->param('TrialUnitSpecimenId')) > 0) {

      $trial_unit_spec_id = $query->param('TrialUnitSpecimenId');
    }
  }


  if (length($item_source) == 0) {

    $item_source = undef;
  }

  if (defined $query->param('ItemSourceId')) {

    if (length($query->param('ItemSourceId')) > 0) {

      $item_source = $query->param('ItemSourceId');
    }
  }

  if (length($item_container_type) == 0) {

    $item_container_type = undef;
  }

  if (defined $query->param('ContainerTypeId')) {

    if (length($query->param('ContainerTypeId')) > 0) {

      $item_container_type = $query->param('ContainerTypeId');
    }
  }


  if (length($item_scale) == 0) {

    $item_scale = undef;
  }

  if (defined $query->param('ScaleId')) {

    if (length($query->param('ScaleId')) > 0) {

      $item_scale = $query->param('ScaleId');
    }
  }


  if (length($item_storage) == 0) {

    $item_storage = undef;
  }

  if (defined $query->param('StorageId')) {

    if (length($query->param('StorageId')) > 0) {

      $item_storage = $query->param('StorageId');
    }
  }


  if (length($item_unit) == 0) {

    $item_unit = undef;
  }

  if (defined $query->param('UnitId')) {

    if (length($query->param('UnitId')) > 0) {

      $item_unit = $query->param('UnitId');
    }
  }


  if (length($item_state) == 0) {

    $item_state = undef;
  }

  if (defined $query->param('ItemStateId')) {

    if (length($query->param('ItemStateId')) > 0) {

      $item_state = $query->param('ItemStateId');
    }
  }

  if (length($item_amount) == 0) {

    $item_amount = '0';
  }

  if (defined $query->param('Amount')) {

    if (length($query->param('Amount')) > 0) {

      $item_amount = $query->param('Amount');
    }
  }

  my $cur_dt = DateTime->now( time_zone => $TIMEZONE );
  $cur_dt = DateTime::Format::MySQL->format_datetime($cur_dt);

  my $item_measure_date = $cur_dt;

  if (defined $query->param('LastMeasuredDate')) {

    if (length($query->param('LastMeasuredDate')) > 0) {

      $item_measure_date = $query->param('LastMeasuredDate');
    }
  }

  if (length($item_measure_by_user) == 0) {

    $item_measure_by_user = '-1';
  }

  if (defined $query->param('LastMeasuredUserId')) {

    if (length($query->param('LastMeasuredUserId')) > 0) {

      $item_measure_by_user = $query->param('LastMeasuredUserId');
    }
  }

  if (length($item_operation) == 0) {

    $item_operation = undef;
  }

  if (defined $query->param('ItemOperation')) {

    if (length($query->param('ItemOperation')) > 0) {

      $item_operation = $query->param('ItemOperation');
    }
  }

  if (length($item_note) == 0) {

    $item_note = undef;
  }

  if (defined $query->param('ItemNote')) {

    if (length($query->param('ItemNote')) > 0) {

      $item_note = $query->param('ItemNote');
    }
  }

  #use database as default value
  my $item_added_date      = $item_date_added;

  if (defined $query->param('DateAdded')) {

    if (length($query->param('DateAdded')) > 0) {

      $item_added_date = $query->param('DateAdded');

      my ( $mdt_err, $mdt_href ) = check_dt_href( { 'DateAdded' => $item_added_date } );

      if ($mdt_err) {

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [$mdt_href]};

        return $data_for_postrun_href;
      }
    }
  }

  my $item_added_by_user   = $self->authen->user_id();

  if (defined $trial_unit_spec_id) {

    my $tuspec_specimen_id = read_cell_value($dbh_k_write, 'trialunitspecimen', 'SpecimenId', 'TrialUnitSpecimenId', $trial_unit_spec_id);

    if (length($tuspec_specimen_id) == 0) {

      my $err_msg = "TrialUnitSpecimen ($trial_unit_spec_id): not found.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'TrialUnitSpecimenId' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if ("$item_specimen" ne "$tuspec_specimen_id") {

      my $err_msg = "TrialUnitSpecimen ($trial_unit_spec_id) and SpecimenId ($item_specimen): ambiguous.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'TrialUnitSpecimenId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (defined $item_source) {

    if (!record_existence($dbh_k_write, 'contact', 'ContactId', $item_source)) {

      my $err_msg = "ItemSource ($item_source): not found.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'ItemSourceId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (defined $item_container_type) {

    if (!type_existence($dbh_k_write, 'container', $item_container_type)) {

      my $err_msg = "ContainerTypeId ($item_container_type): not found or inactive.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'ContainerTypeId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (!record_existence($dbh_k_write, 'specimen', 'SpecimenId', $item_specimen)) {

    my $err_msg = "Specimen ($item_specimen): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'SpecimenId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (defined $item_scale) {

    if (!record_existence($dbh_k_write, 'deviceregister', 'DeviceRegisterId', $item_scale)) {

      my $err_msg = "Scale ($item_scale): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'ScaleId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (defined $item_storage) {

    if (!record_existence($dbh_k_write, 'storage', 'StorageId', $item_storage)) {

      my $err_msg = "Storage ($item_storage): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'StorageId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (defined $item_unit) {

    if (!record_existence($dbh_k_write, 'generalunit', 'UnitId', $item_unit)) {

      my $err_msg = "UnitId ($item_unit): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'UnitId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (!type_existence($dbh_k_write, 'item', $item_type)) {

    my $err_msg = "ItemTypeId ($item_type): not found or inactive.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'ItemTypeId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (defined $item_state) {

    if (!type_existence($dbh_k_write, 'state', $item_state)) {

      my $err_msg = "ItemStateId ($item_state): not found or inactive.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'ItemStateId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (defined $item_barcode) {

    my $barcode_sql = 'SELECT ItemId FROM item WHERE ItemId<>? AND ItemBarcode=? LIMIT 1';
    my ($r_barcode_err, $found_item_id) = read_cell($dbh_k_write, $barcode_sql, [$item_id, $item_barcode]);

    if ($r_barcode_err) {

      $self->logger->debug("Lookup existing barcode failed");
      my $err_msg = "Unexpected Error.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'ItemStateId' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if (length($found_item_id) > 0) {

      my $err_msg = "ItemBarcode ($item_barcode): already exits.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'ItemBarcode' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }
  else {

    $item_barcode = undef;
  }

  if ($item_amount ne '0') {

    my ($afloat_err, $afloat_href) = check_float_href( { 'Amount' => $item_amount } );

    if ($afloat_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [$afloat_href]};

      return $data_for_postrun_href;
    }
  }

  my $chk_dt_input_href = { 'LastUpateTimeStamp' => $last_update_ts };

  if (length($item_measure_date) > 0) {

    $chk_dt_input_href->{'LastMeasuredDate'} = $item_measure_date;
  }

  my ( $mdt_err, $mdt_href ) = check_dt_href( $chk_dt_input_href );

  if ($mdt_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$mdt_href]};

    return $data_for_postrun_href;
  }

  if ($item_measure_by_user ne '-1') {

    if (!record_existence($dbh_k_write, 'systemuser', 'UserId', $item_measure_by_user)) {

      my $err_msg = "LastMeasuredUser ($item_measure_by_user): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'LastMeasuredUserId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (length($item_operation) > 0) {

    if ( $item_operation !~ /^subsample|^group/ ) {

      my $err_msg = ' can only be subsample or group.';;

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'ItemOperation' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  # Get the virtual col from the factor table
  my $vcol_data              = $self->_get_item_factor();
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
    $vcol_param_data->{$vcol_param_name} = $vcol_value;
    $vcol_len_info->{$vcol_param_name}          = $vcol_data->{$vcol_id}->{'FactorValueMaxLength'};
    $vcol_param_data_maxlen->{$vcol_param_name} = $vcol_value;
  }

  # Validate virtual column for factor
  my ( $vcol_missing_err, $vcol_missing_msg ) = check_missing_value($vcol_param_data_compul);

  if ($vcol_missing_err) {

    $vcol_missing_msg = $vcol_missing_msg . ' missing';
    return $self->_set_error($vcol_missing_msg);
  }

  my ( $vcol_maxlen_err, $vcol_maxlen_msg ) = check_maxlen( $vcol_param_data_maxlen, $vcol_len_info );

  if ($vcol_maxlen_err) {

    $vcol_maxlen_msg = $vcol_maxlen_msg . ' longer than maximum length.';
    return $self->_set_error($vcol_maxlen_msg);
  }

  my $group_id  = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'genotype');

  my $geno_specimen_sql = "SELECT genotype.GenotypeId ";
  $geno_specimen_sql   .= "FROM genotype LEFT JOIN genotypespecimen ON ";
  $geno_specimen_sql   .= "genotype.GenotypeId = genotypespecimen.GenotypeId ";
  $geno_specimen_sql   .= "WHERE genotypespecimen.SpecimenId=?";

  my ($geno_err, $geno_msg, $geno_data) = read_data($dbh_k_write, $geno_specimen_sql, [$item_specimen]);

  if ($geno_err) {

    $self->logger->debug($geno_msg);
    return $self->_set_error('Unexpected error.');
  }

  $geno_specimen_sql   .= " AND ((($perm_str) & $LINK_PERM) = $LINK_PERM)";

  $self->logger->debug("Genotype specimen permission SQL: $geno_specimen_sql");

  my ($geno_p_err, $geno_p_msg, $geno_p_data_perm) = read_data($dbh_k_write, $geno_specimen_sql, [$item_specimen]);

  if ($geno_p_err) {

    $self->logger->debug($geno_p_msg);
    return $self->_set_error('Unexpected error.');
  }

  if (scalar(@{$geno_data}) != scalar(@{$geno_p_data_perm})) {

    my $err_msg = "SpecimenId ($item_specimen): permission denied.";
    return $self->_set_error($err_msg);
  }

  my ($get_scol_err, $get_scol_msg, $scol_data, $pkey_data) = get_static_field($dbh_k_write, 'item');

  if ($get_scol_err) {

    $self->logger->debug("Get static field info failed: $get_scol_msg");

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my @field_list;

  for my $scol_rec (@{$scol_data}) {

    push(@field_list, $scol_rec->{'Name'});
  }

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering('ItemId',
                                                                              'item',
                                                                              $filtering_csv,
                                                                              \@field_list);

  $self->logger->debug("Filter phrase: $filter_phrase");

  if ($filter_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $filter_msg}]};

    return $data_for_postrun_href;
  }

  my $update_statement = "
        UPDATE item SET
            TrialUnitSpecimenId=?,
	          ItemSourceId=?,
            ContainerTypeId=?,
            SpecimenId=?,
            ScaleId=?,
            StorageId=?,
            UnitId=?,
            ItemTypeId=?,
            ItemStateId=?,
            ItemBarcode=?,
            Amount=?,
            DateAdded=?,
            AddedByUserId=?,
            LastMeasuredDate=?,
            LastMeasuredUserId=?,
            ItemOperation=?,
            ItemNote=?,
            LastUpdateTimeStamp=?
        WHERE ItemId=? AND LastUpdateTimeStamp=?
    ";

  if (length($filter_phrase) > 0) {

    $update_statement .= " AND $filter_phrase";
  }

  my $sth = $dbh_k_write->prepare($update_statement);
  $sth->execute( $trial_unit_spec_id, $item_source, $item_container_type, $item_specimen, $item_scale,
                 $item_storage, $item_unit, $item_type, $item_state, $item_barcode, $item_amount,
                 $item_added_date, $item_added_by_user, $item_measure_date, $item_measure_by_user,
                 $item_operation, $item_note, $cur_dt, $item_id, $last_update_ts, @{$where_arg}
      );

  if ( $dbh_k_write->err() ) {

    return $self->_set_error();
  }

  my $affected_rows = $sth->rows();

  if ($affected_rows != 1) {

    $self->logger->debug("Number of affected rows: $affected_rows");

    my $err_msg = "Operation failed due to timestamp mismatched.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($up_vcol_err, $up_vcol_err_msg) = update_vcol_data($dbh_k_write, $vcol_data, $vcol_param_data,
                                                         'itemfactor', 'ItemId', $item_id);

  if ($up_vcol_err) {

    $self->logger->debug($up_vcol_err_msg);
    return $self->_set_error('Unexpected error.');
  }

  $sth->finish();
  $dbh_k_write->disconnect();

  my $info_msg_aref = [ { 'Message' => "Item ($item_id) has been updated successfully." } ];

  return {
    'Error' => 0,
    'Data'  => {
      'Info'     => $info_msg_aref,
    },
    'ExtraData' => 0
  };
}

#########################################################
# Group for Item

sub add_item_to_group_runmode {

=pod add_item_to_group_gadmin_HELP_START
{
"OperationName": "Add item to item group",
"Description": "Add a new inventory item to defined group of items.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "itemgroupentry",
"SkippedField": ["ItemGroupId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='ItemId (38) has been added successfully to ItemGroupId (15).' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'ItemId (39) has been added successfully to ItemGroupId (15).'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error ItemId='ItemId (2) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'ItemId' : 'ItemId (2) not found.'}]}"}],
"URLParameter": [{"ParameterName": "groupid", "Description": "Existing ItemGroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self   = $_[0];

  my $query         = $self->query();
  my $item_group_id = $self->param('groupid');

  my $item_id       = $query->param('ItemId');

  my $data_for_postrun_href = {};

  my ( $missing_err, $missing_msg ) = check_missing_value({ 'ItemId' => $item_id });

  if ($missing_err) {

    my $err_msg = "ItemId is missing.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'ItemId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_k_write = connect_kdb_write();

  if (!record_existence($dbh_k_write, 'itemgroup', 'ItemGroupId', $item_group_id)) {

    my $err_msg = "ItemGroupId ($item_group_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (!record_existence($dbh_k_write, 'item', 'ItemId', $item_id)) {

    my $err_msg = "ItemId ($item_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'ItemId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $insert_statement = "
        INSERT into itemgroupentry SET
            ItemId=?,
            ItemGroupId=?
    ";
  my $sth = $dbh_k_write->prepare($insert_statement);
  $sth->execute( $item_id, $item_group_id, );

  if ( $dbh_k_write->err() ) {

    return $self->_set_error();
  }

  $sth->finish();
  $dbh_k_write->disconnect();

  my $msg = "ItemId ($item_id) has been added successfully to ItemGroupId ($item_group_id).";

  my $info_msg_aref = [ { 'Message' => $msg } ];

  return {
    'Error' => 0,
    'Data'  => {
      'Info'     => $info_msg_aref,
    },
    'ExtraData' => 0
  };
}

sub remove_item_from_group_runmode {

=pod remove_item_from_group_gadmin_HELP_START
{
"OperationName": "Remove item from item group",
"Description": "Delete item from the item group.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='ItemId (38) has been removed successfully from ItemGroupId (15).' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'ItemId (38) has been removed successfully from ItemGroupId (15).'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Item (38) not a member of ItemGroup (15).' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Item (38) not a member of ItemGroup (15).'}]}"}],
"URLParameter": [{"ParameterName": "groupid", "Description": "Existing ItemGroupId."}, {"ParameterName": "itemid", "Description": "ItemId which is a member of the ItemGroupId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my ($self) = @_;

  my $item_id       = $self->param('itemid');
  my $item_group_id = $self->param('groupid');

  my $data_for_postrun_href = {};

  my $dbh_k_write = connect_kdb_write();

  if (!record_existence($dbh_k_write, 'itemgroup', 'ItemGroupId', $item_group_id)) {

    my $err_msg = "ItemGroup ($item_group_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (!record_existence($dbh_k_write, 'item', 'ItemId', $item_id)) {

    my $err_msg = "Item ($item_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $chk_member_sql = 'SELECT ItemGroupId FROM itemgroupentry WHERE ItemGroupId=? AND ItemId=?';

  my ($read_err, $db_item_group_id) = read_cell($dbh_k_write, $chk_member_sql, [$item_group_id, $item_id]);

  if ($read_err) {

    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_item_group_id) == 0) {

    my $err_msg = "Item ($item_id) not a member of ItemGroup ($item_group_id).";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $del_statement = "
        DELETE from itemgroupentry WHERE
            ItemId=? AND ItemGroupId=?
    ";

  my $sth = $dbh_k_write->prepare($del_statement);
  $sth->execute( $item_id, $item_group_id, );

  if ( $dbh_k_write->err() ) {

    return $self->_set_error();
  }

  $sth->finish();
  $dbh_k_write->disconnect();

  my $msg = "ItemId ($item_id) has been removed successfully from ItemGroupId ($item_group_id).";

  my $info_msg_aref = [ { 'Message' => $msg } ];

  return {
    'Error' => 0,
    'Data'  => {
      'Info'     => $info_msg_aref,
    },
    'ExtraData' => 0
  };
}

sub add_storage_runmode {

=pod add_storage_gadmin_HELP_START
{
"OperationName": "Add storage",
"Description": "Add a new storage location information into a storage areas tree.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "storage",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='15' ParaName='StorageId' /><Info Message='StorageId (15) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '16', 'ParaName' : 'StorageId'}], 'Info' : [{'Message' : 'StorageId (16) has been added successfully.'}]}",
"ErrorMessageXML": [{"NameAlreadyExists": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error StorageBarcode='StorageBarcode (S_): already used.' /></DATA>"}],
"ErrorMessageJSON": [{"NameAlreadyExists": "{'Error' : [{'StorageBarcode' : 'StorageBarcode (S_): already used.'}]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = { 'StorageBarcode' => 1};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'storage', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $storage_barcode   = $query->param('StorageBarcode');
  my $storage_loc       = $query->param('StorageLocation');
  my $storage_parent_id = undef;

  if (defined $query->param('StorageParentId')) {

    if (length($query->param('StorageParentId')) > 0) {

      $storage_parent_id = $query->param('StorageParentId');
    }
  }

  my $storage_details   = '';
  my $storage_note      = '';

  if (defined $query->param('StorageDetails')) {

    $storage_details = $query->param('StorageDetails');
  }

  if (defined $query->param('StorageNote')) {

    $storage_note = $query->param('StorageNote');
  }

  my $dbh_k_write = connect_kdb_write();

  if (defined $storage_parent_id) {

    if (!record_existence($dbh_k_write, 'storage', 'StorageId', $storage_parent_id)) {

      my $err_msg = "StorageParentId ($storage_parent_id): not found.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (length($storage_barcode) > 0) {

    if (record_existence($dbh_k_write, 'storage', 'StorageBarcode', $storage_barcode)) {

      my $err_msg = "StorageBarcode ($storage_barcode): already used.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'StorageBarcode' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }
  else {

    $storage_barcode = undef;
  }

  my $sql = 'INSERT INTO storage SET ';
  $sql   .= 'StorageBarcode=?, ';
  $sql   .= 'StorageLocation=?, ';
  $sql   .= 'StorageParentId=?, ';
  $sql   .= 'StorageDetails=?, ';
  $sql   .= 'StorageNote=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($storage_barcode, $storage_loc, $storage_parent_id, $storage_details, $storage_note);

  my $storage_id = -1;
  if (!$dbh_k_write->err()) {

    $storage_id = $dbh_k_write->last_insert_id(undef, undef, 'storage', 'StorageId');
    $self->logger->debug("StorageId: $storage_id");
  }
  else {

    $data_for_postrun_href->{'Error'}       = 1;
    $data_for_postrun_href->{'Data'}        = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref  = [{'Message' => "StorageId ($storage_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$storage_id", 'ParaName' => 'StorageId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_storage_runmode {

=pod update_storage_gadmin_HELP_START
{
"OperationName": "Update storage",
"Description": "Update storage area information specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "storage",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='StorageId (18) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'StorageId (18) has been updated successfully.'}]}",
"ErrorMessageXML": [{"NameAlreadyExists": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error StorageBarcode='StorageBarcode (S_): already used.' /></DATA>"}],
"ErrorMessageJSON": [{"NameAlreadyExists": "{'Error' : [{'StorageBarcode' : 'StorageBarcode (S_): already used.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing StorageId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $storage_id = $self->param('id');

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'storage', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $dbh_k_write = connect_kdb_write();

  my $storage_barcode   = undef;
  my $storage_loc       = $query->param('StorageLocation');

  my $read_st_sql       =  'SELECT StorageDetails, StorageNote, StorageParentId, StorageBarcode ';
     $read_st_sql      .=  'FROM storage WHERE StorageId=? ';

  my ($r_df_val_err, $r_df_val_msg, $storage_df_val_data) = read_data($dbh_k_write, $read_st_sql, [$storage_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve storage default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $storage_details     =  undef;
  my $storage_note        =  undef;
  my $storage_parent_id   =  undef;

  my $nb_df_val_rec    =  scalar(@{$storage_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve storage default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $storage_details    =   $storage_df_val_data->[0]->{'StorageDetails'};
  $storage_note       =   $storage_df_val_data->[0]->{'StorageNote'};
  $storage_parent_id  =   $storage_df_val_data->[0]->{'StorageParentId'};
  $storage_barcode    =   $storage_df_val_data->[0]->{'StorageBarcode'};

  if (length($storage_parent_id) == 0) {

    $storage_parent_id = undef;
  }

  if (length($storage_barcode) == 0) {

    $storage_barcode = undef;
  }

  if (defined $query->param('StorageParentId')) {

    if (length($query->param('StorageParentId')) > 0) {

      $storage_parent_id = $query->param('StorageParentId');
    }
  }

  if (defined $query->param('StorageBarcode')) {

    if (length($query->param('StorageBarcode')) > 0) {

      $storage_barcode = $query->param('StorageBarcode');
    }
  }

  if (defined $query->param('StorageDetails')) {

    $storage_details = $query->param('StorageDetails');
  }

  if (defined $query->param('StorageNote')) {

    $storage_note = $query->param('StorageNote');
  }

  if (!record_existence($dbh_k_write, 'storage', 'StorageId', $storage_id)) {

    my $err_msg = "StorageId ($storage_id): not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'StorageId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (defined $storage_parent_id) {

    if (!record_existence($dbh_k_write, 'storage', 'StorageId', $storage_parent_id)) {

      my $err_msg = "StorageParentId ($storage_parent_id): not found.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'StorageParentId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (defined $storage_barcode) {

    my $storage_barcode_sql = 'SELECT StorageBarcode FROM storage WHERE StorageBarcode=? AND StorageId<>?';

    my ($r_storage_barcode_err, $db_storage_barcode) = read_cell($dbh_k_write, $storage_barcode_sql,
                                                                 [$storage_barcode, $storage_id]);

    if ($r_storage_barcode_err) {

      my $err_msg = "Unexpected Error.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if (length($db_storage_barcode) > 0) {

      my $err_msg = "StorageBarcode ($storage_barcode): already used.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'StorageBarcode' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $sql = 'UPDATE storage SET ';
  $sql   .= 'StorageBarcode=?, ';
  $sql   .= 'StorageLocation=?, ';
  $sql   .= 'StorageParentId=?, ';
  $sql   .= 'StorageDetails=?, ';
  $sql   .= 'StorageNote=? ';
  $sql   .= 'WHERE StorageId=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($storage_barcode, $storage_loc, $storage_parent_id, $storage_details, $storage_note, $storage_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'}       = 1;
    $data_for_postrun_href->{'Data'}        = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref  = [{'Message' => "StorageId ($storage_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub del_storage_runmode {

=pod del_storage_gadmin_HELP_START
{
"OperationName": "Delete storage",
"Description": "Delete storage location specified by id. Storage can be deleted only if not attached to any lower level related record. Deleting storage also can not break storage tree.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='StorageId (18) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'StorageId (17) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='StorageId (17): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'StorageId (17): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing StorageId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $storage_id = $self->param('id');

  my $dbh_k_write = connect_kdb_write();

  my $data_for_postrun_href = {};

  if (!record_existence($dbh_k_write, 'storage', 'StorageId', $storage_id)) {

    my $err_msg = "StorageId ($storage_id): not found.";
    return $self->_set_error($err_msg);
  }

  if (record_existence($dbh_k_write, 'storage', 'StorageParentId', $storage_id)) {

    my $err_msg = "StorageId ($storage_id) is a parent.";
    return $self->_set_error($err_msg);
  }

  if (record_existence($dbh_k_write, 'item', 'StorageId', $storage_id)) {

    my $err_msg = "StorageId ($storage_id): item(s) in this storage.";
    return $self->_set_error($err_msg);
  }

  my $sql = 'DELETE FROM storage ';
  $sql   .= 'WHERE StorageId=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($storage_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'}       = 1;
    $data_for_postrun_href->{'Data'}        = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref  = [{'Message' => "StorageId ($storage_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_storage {

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
  my $storage_data = [];

  if ( !$dbh->err() ) {

    my $array_ref = $sth->fetchall_arrayref({});

    if ( !$sth->err() ) {

      $storage_data = $array_ref;
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

  my $extra_attr_storage_data = [];
  my $storage_children_lookup = {};

  if ($extra_attr_yes) {

    my $gadmin_status = $self->authen->gadmin_status();

    my $storage_id_aref = [];
    for my $row (@{$storage_data}) {

      push(@{$storage_id_aref}, $row->{'StorageId'});

      my $storage_parentid =  $row->{'StorageParentId'};
      my $storage_id = $row->{'StorageId'};

      if (defined $storage_parentid) {

        if (!defined $storage_children_lookup->{$storage_parentid}) {
           $storage_children_lookup->{$storage_parentid}->{'StorageChildren'} = [];
        }

        my $new_child = {};
        $new_child->{'StorageId'} = $row->{'StorageId'};
        $new_child->{'StorageLocation'} = $row->{'StorageLocation'};
        $new_child->{'StorageBarcode'} = $row->{'StorageBarcode'};

        push(@{$storage_children_lookup->{$storage_parentid}->{'StorageChildren'}}, $new_child);
      }
    }

    my $chk_id_err        = 0;
    my $chk_id_msg        = '';
    my $used_id_href      = {};
    my $not_used_id_href  = {};

    if (scalar(@{$storage_id_aref}) > 0) {

      my $chk_table_aref = [{'TableName' => 'item', 'FieldName' => 'StorageId'}];

      ($chk_id_err, $chk_id_msg,
       $used_id_href, $not_used_id_href) = id_existence_bulk($dbh, $chk_table_aref, $storage_id_aref);

      if ($chk_id_err) {

        $self->logger->debug("Check id existence error: $chk_id_msg");
        $err = 1;
        $msg = $chk_id_msg;

        return ($err, $msg, []);
      }
    }

    for my $row (@{$storage_data}) {

      my $storage_id = $row->{'StorageId'};

      if ($gadmin_status eq '1') {
        $row->{'update'} = "update/storage/$storage_id";

        if ( $not_used_id_href->{$storage_id}  ) {

          $row->{'delete'}   = "delete/storage/$storage_id";
        }
      }

      $row->{'StorageChildren'} = $storage_children_lookup->{$storage_id}->{'StorageChildren'};

      push(@{$extra_attr_storage_data}, $row);
    }
  }
  else {

    $extra_attr_storage_data = $storage_data;
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_storage_data);
}

sub list_storage_runmode {

=pod list_storage_HELP_START
{
"OperationName": "List storage",
"Description": "List all storage locations.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='Storage' /><Storage StorageParentId='0' StorageDetails='Testing' StorageId='16' StorageBarcode='S_3304968' StorageNote='' StorageLocation='Non existing' delete='delete/storage/16' update='update/storage/16'><StorageChildren StorageId='310' StorageBarcode='2_00_1533112918_9' StorageLocation='Testing Child 1'/><StorageChildren StorageId='309' StorageBarcode='2_00_1533112918_8' StorageLocation='Testing Child 2'/></Storage></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'Storage'}], 'Storage' : [{'StorageParentId' : '0', 'StorageDetails' : 'Testing', 'StorageId' : '16', 'delete' : 'delete/storage/16', 'StorageBarcode' : 'S_3304968', 'update' : 'update/storage/16', 'StorageLocation' : 'Non existing', 'StorageNote' : '','StorageChildren' : [{'StorageId' : '26','StorageBarcode' : '2_00_1533112918_9','StorageLocation' : 'Testing Child 1'},{'StorageId' : '25',      'StorageBarcode' : '2_00_1533112918_8','StorageLocation' : 'Testing Child 2'}]}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPParameter": [{"Required": 0, "Name": "Filtering", "Description": "Filtering parameter string consisting of filtering expressions which are separated by ampersand (&) which needs to be encoded if HTTP GET method is used. Each filtering expression is composed of a database field name, a filtering operator and the filtering value."}, {"Required": 0, "Name": "Sorting", "Description": "Comma separated value of SQL sorting phrases."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $filtering_csv = '';

  if (defined $query->param('Filtering')) {

    $filtering_csv = $query->param('Filtering');
  }

  my $sorting = '';

  if (defined $query->param('Sorting')) {

    $sorting = $query->param('Sorting');
  }

  my $data_for_postrun_href = {};

  my $group_id = $self->authen->group_id();

  my $dbh = connect_kdb_read();

  my @field_list_all;

  my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'storage');

  if ($sfield_err) {

    $self->logger->debug("Get static field failed: $sfield_msg");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  for my $sfield_rec (@{$sfield_data}) {

    push(@field_list_all, $sfield_rec->{'Name'});
  }

  for my $pkey_field (@{$pkey_data}) {

    push(@field_list_all, $pkey_field);
  }

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering('StorageId',
                                                                              'storage',
                                                                              $filtering_csv,
                                                                              \@field_list_all);

  $self->logger->debug("Filter phrase: $filter_phrase");

  if ($filter_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $filter_msg}]};

    return $data_for_postrun_href;
  }

  my $filter_where_phrase = '';

  if (length($filter_phrase) > 0) {

    $filter_where_phrase = " WHERE $filter_phrase ";
  }

  $dbh->disconnect();

  my $sql = 'SELECT * FROM storage ';
  $sql   .= "$filter_where_phrase ";

  my ($sort_err, $sort_msg, $sort_sql) = parse_sorting($sorting, \@field_list_all);

  if ($sort_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sort_msg}]};

    return $data_for_postrun_href;
  }

  if (length($sort_sql) > 0) {

    $sql .= " ORDER BY $sort_sql ";
  }
  else {

    $sql .= ' ORDER BY storage.StorageId DESC';
  }

  $self->logger->debug("SQL: $sql");

  my ($read_storage_err, $read_storage_msg, $storage_data) = $self->list_storage(1, $sql, $where_arg);

  if ($read_storage_err) {

    $self->logger->debug($read_storage_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Storage'    => $storage_data,
                                           'RecordMeta' => [{'TagName' => 'Storage'}],
  };

  return $data_for_postrun_href;
}

sub get_storage_runmode {

=pod get_storage_HELP_START
{
"OperationName": "Get storage",
"Description": "Get detailed information about storage location specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='Storage' /><Storage StorageParentId='0' StorageDetails='Testing' StorageId='1' StorageBarcode='S_8734785' StorageNote='' StorageLocation='Non existing' update='update/storage/1' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'Storage'}], 'Storage' : [{'StorageParentId' : '0', 'StorageDetails' : 'Testing', 'StorageId' : '1', 'StorageBarcode' : 'S_8734785', 'update' : 'update/storage/1', 'StorageLocation' : 'Non existing', 'StorageNote' : ''}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='StorageId (18): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'StorageId (18): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing StorageId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;

  my $storage_id = $self->param('id');
  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();
  my $storage_exist = record_existence($dbh, 'storage', 'StorageId', $storage_id);
  $dbh->disconnect();

  if (!$storage_exist) {

    return $self->_set_error("StorageId ($storage_id): not found.");
  }

  my $sql = 'SELECT * FROM storage ';
  $sql   .= 'WHERE StorageId=?';

  my ($read_storage_err, $read_storage_msg, $storage_data) = $self->list_storage(1, $sql, [$storage_id]);

  if ($read_storage_err) {

    $self->logger->debug($read_storage_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Storage'    => $storage_data,
                                           'RecordMeta' => [{'TagName' => 'Storage'}],
  };

  return $data_for_postrun_href;
}

sub list_item {

  my $self              = $_[0];
  my $extra_attr_yes    = $_[1];
  my $sql               = $_[2];
  my $where_para_aref   = $_[3];

  my $err = 0;
  my $msg = '';

  my $data_aref = [];

  my $dbh = connect_kdb_read();

  ($err, $msg, $data_aref) = read_data($dbh, $sql, $where_para_aref);

  if ($err) {

    return ($err, $msg, []);
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'genotype');

  my $item_id_aref = [];

  my $genotype_lookup   = {};
  my $itm_parent_lookup = {};
  my $itm_group_lookup  = {};

  my $chk_id_err        = 0;
  my $chk_id_msg        = '';
  my $used_id_href      = {};
  my $not_used_id_href  = {};

  if ($extra_attr_yes) {

    for my $item_row (@{$data_aref}) {

      push(@{$item_id_aref}, $item_row->{'ItemId'});
    }

    if (scalar(@{$item_id_aref}) > 0) {

      my $geno_specimen_sql = "SELECT item.ItemId, genotype.GenotypeId ";
      $geno_specimen_sql   .= "FROM item LEFT JOIN genotypespecimen ON ";
      $geno_specimen_sql   .= "item.SpecimenId = genotypespecimen.SpecimenId ";
      $geno_specimen_sql   .= "LEFT JOIN genotype ON ";
      $geno_specimen_sql   .= "genotypespecimen.GenotypeId = genotype.GenotypeId ";
      $geno_specimen_sql   .= "WHERE item.ItemId IN (". join(',', @{$item_id_aref}) . ") ";
      $geno_specimen_sql   .= "AND ((($perm_str) & $READ_PERM) = $READ_PERM)";

      $self->logger->debug("Genotype specimen permission SQL: $geno_specimen_sql");

      my ($geno_p_err, $geno_p_msg, $geno_p_data_perm) = read_data($dbh, $geno_specimen_sql, []);

      if ($geno_p_err) {

        return ($geno_p_err, $geno_p_msg, []);
      }

      for my $geno_row (@{$geno_p_data_perm}) {

        my $item_id = $geno_row->{'ItemId'};

        if (defined $genotype_lookup->{$item_id}) {

          my $geno_aref = $genotype_lookup->{$item_id};
          delete($geno_row->{'ItemId'});
          push(@{$geno_aref}, $geno_row);
          $genotype_lookup->{$item_id} = $geno_aref;
        }
        else {

          delete($geno_row->{'ItemId'});
          $genotype_lookup->{$item_id} = [$geno_row];
        }
      }

      my $parent_sql = "SELECT itemparent.ItemId, ItemParentId, ParentId, ItemParentType, ";
      $parent_sql   .= "generaltype.TypeName as ItemParentTypeName ";
      $parent_sql   .= "FROM itemparent LEFT JOIN generaltype ON ";
      $parent_sql   .= "itemparent.ItemParentType = generaltype.TypeId ";
      $parent_sql   .= "WHERE itemparent.ItemId IN (" . join(',', @{$item_id_aref}) . ")";

      my ($read_parent_err, $read_parent_msg, $item_parent_data) = read_data($dbh, $parent_sql, []);

      if ($read_parent_err) {

        return ($read_parent_err, $read_parent_msg, []);
      }

      for my $itm_parent_row (@{$item_parent_data}) {

        my $item_id = $itm_parent_row->{'ItemId'};

        if (defined $itm_parent_lookup->{$item_id}) {

          my $parent_aref = $itm_parent_lookup->{$item_id};
          delete($itm_parent_row->{'ItemId'});
          push(@{$parent_aref}, $itm_parent_row);
          $itm_parent_lookup->{$item_id} = $parent_aref;
        }
        else {

          delete($itm_parent_row->{'ItemId'});
          $itm_parent_lookup->{$item_id} = [$itm_parent_row];
        }
      }

      my $item_group_sql = "SELECT itemgroupentry.ItemId, itemgroup.ItemGroupId, itemgroup.ItemGroupName ";
      $item_group_sql   .= "FROM itemgroup LEFT JOIN itemgroupentry ";
      $item_group_sql   .= "ON itemgroup.ItemGroupId = itemgroupentry.ItemGroupId ";
      $item_group_sql   .= "WHERE itemgroupentry.ItemId IN (" . join(',', @{$item_id_aref}) . ")";

      my ($read_grp_err, $read_grp_msg, $itm_grp_data) = read_data($dbh, $item_group_sql, []);

      if ($read_grp_err) {

        return ($read_grp_err, $read_grp_msg, []);
      }

      for my $itm_grp_row (@{$itm_grp_data}) {

        my $item_id = $itm_grp_row->{'ItemId'};

        if (defined $itm_group_lookup->{$item_id}) {

          my $itm_grp_aref = $itm_group_lookup->{$item_id};
          delete($itm_grp_row->{'ItemId'});
          push(@{$itm_grp_aref}, $itm_grp_row);
          $itm_group_lookup->{$item_id} = $itm_grp_aref;
        }
        else {

          delete($itm_grp_row->{'ItemId'});
          $itm_group_lookup->{$item_id} = [$itm_grp_row];
        }
      }

      my $chk_table_aref = [{'TableName' => 'itemparent', 'FieldName' => 'ItemId'},
                            {'TableName' => 'itemparent', 'FieldName' => 'ParentId'},
                            {'TableName' => 'itemgroupentry', 'FieldName' => 'ItemId'},
                            {'TableName' => 'trialunitspecimen', 'FieldName' => 'ItemId'}
          ];

      ($chk_id_err, $chk_id_msg,
       $used_id_href, $not_used_id_href) = id_existence_bulk($dbh, $chk_table_aref, $item_id_aref);

      if ($chk_id_err) {

        $self->logger->debug("Check id existence error: $chk_id_msg");
        $err = 1;
        $msg = $chk_id_msg;

        return ($err, $msg, []);
      }
    }
  }

  my @extra_attr_item_data;

  for my $item_row (@{$data_aref}) {

    my $item_id        = $item_row->{'ItemId'};

    if ($extra_attr_yes) {

      # Aneal does not want Genotype

      #if (defined $genotype_lookup->{$item_id}) {

      #  $item_row->{'Genotype'} = $genotype_lookup->{$item_id};
      #}

      if (defined $itm_parent_lookup->{$item_id}) {

        my $item_parent_data = $itm_parent_lookup->{$item_id};

        my $extra_item_parent_data = [];

        if ($gadmin_status eq '1') {

          for my $item_parent_row (@{$item_parent_data}) {

            my $item_parent_id = $item_parent_row->{'ItemParentId'};
            $item_parent_row->{'removeParent'} = "delete/itemparent/$item_parent_id";
            push(@{$extra_item_parent_data}, $item_parent_row);
          }
        }
        else {

          $extra_item_parent_data = $item_parent_data;
        }

        $item_row->{'ParentItem'} = $extra_item_parent_data;
      }

      if (defined $itm_group_lookup->{$item_id}) {

        $item_row->{'ItemGroup'} = $itm_group_lookup->{$item_id};
      }

      if ($gadmin_status eq '1') {

        $item_row->{'update'}    = "update/item/$item_id";
        $item_row->{'addParent'} = "item/${item_id}/add/parent";

        if ( $not_used_id_href->{$item_id} ) {

          $item_row->{'delete'} = "delete/item/$item_id";
        }
      }
    }
    push(@extra_attr_item_data, $item_row);
  }

  $dbh->disconnect();

  return ($err, $msg, \@extra_attr_item_data);
}

sub list_itemparent {

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
  my $itemparent_data = [];

  if ( !$dbh->err() ) {

    my $array_ref = $sth->fetchall_arrayref({});

    if ( !$sth->err() ) {

      $itemparent_data = $array_ref;
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

  my $extra_attr_itemparent_data = [];

  my $gadmin_status = $self->authen->gadmin_status();

  my $parent_item_id_aref = [];

  for my $row (@{$itemparent_data}) {

    push(@{$parent_item_id_aref}, $row->{'ParentId'});
  }

  my $item_parent_lookup = {};

  if ($extra_attr_yes && ($gadmin_status eq '1')) {

    if (scalar(@{$parent_item_id_aref}) > 0) {

      my $item_sql = "SELECT itemparent.ParentId, itemparent.ItemParentId, itemparent.ItemParentType, ";
      $item_sql   .= "generaltype.TypeName as ItemParentTypeName, item.* ";
      $item_sql   .= "FROM (itemparent LEFT JOIN generaltype ";
      $item_sql   .= "ON itemparent.ItemParentType = generaltype.TypeId) LEFT JOIN item ";
      $item_sql   .= "ON itemparent.ItemId = item.ItemId ";
      $item_sql   .= "WHERE itemparent.ParentId IN (" . join(',', @{$parent_item_id_aref}) . ")";

      my ($item_err, $item_msg, $item_data) = read_data($dbh, $item_sql, []);

      if ($item_err) {

        $self->logger->debug("Read child items failed: $item_msg");
        return ($item_err, $item_msg, []);
      }

      for my $item_row (@{$item_data}) {

        my $parent_id = $item_row->{'ParentId'};

        if (defined $item_parent_lookup->{$parent_id}) {

          my $item_aref = $item_parent_lookup->{$parent_id};
          delete($item_row->{'ParentId'});
          push(@{$item_aref}, $item_row);
          $item_parent_lookup->{$parent_id} = $item_aref;
        }
        else {

          delete($item_row->{'ParentId'});
          $item_parent_lookup->{$parent_id} = [$item_row];
        }
      }
    }
  }

  for my $row (@{$itemparent_data}) {

    delete $row->{'ItemId'};

    my $parent_id = $row->{'ParentId'};

    my $extra_item_data = [];

    my $item_data = [];

    if (defined $item_parent_lookup->{$parent_id}) {

      $item_data = $item_parent_lookup->{$parent_id};
    }

    if ( ($gadmin_status eq '1') && $extra_attr_yes) {

      for my $item_row (@{$item_data}) {

        my $item_parent_id = $item_row->{'ItemParentId'};
        $item_row->{'removeChild'} = "delete/itemparent/$item_parent_id";
        push(@{$extra_item_data}, $item_row);
      }
    }
    else {

      $extra_item_data = $item_data;
    }

    $row->{'ItemChild'} = $extra_item_data;

    push(@{$extra_attr_itemparent_data}, $row);
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_itemparent_data);
}

sub list_itemparent_runmode {

=pod list_itemparent_HELP_START
{
"OperationName": "List parentage information for items",
"Description": "List parentage information for inventory items.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ItemParent DateAdded='2014-08-06 15:15:58' AddedByUserId='0' ItemTypeId='148' TrialUnitSpecimenId='0' ContainerTypeId='146' ItemNote='' ItemStateId='149' ParentId='25' ScaleId='16' SpecimenId='488' ItemOperation='group' LastMeasuredUserId='0' ItemBarcode='I_1343739' UnitId='18' StorageId='10' Amount='5.000' ItemSourceId='32' LastMeasuredDate='2012-08-01 00:00:00'><ItemChild DateAdded='2014-08-06 15:15:58' ItemId='24' AddedByUserId='0' ItemParentType='150' ItemTypeId='148' TrialUnitSpecimenId='0' ContainerTypeId='146' ItemNote='' ItemStateId='149' ScaleId='16' SpecimenId='488' ItemOperation='group' LastMeasuredUserId='0' ItemBarcode='I_3423475' removeChild='delete/itemparent/4' UnitId='18' StorageId='10' ItemParentTypeName='Tower - 4888818' Amount='5.000' LastMeasuredDate='2012-08-01 00:00:00' ItemSourceId='32' ItemParentId='4' /></ItemParent></DATA>",
"SuccessMessageJSON": "{'ItemParent' : [{'DateAdded' : '2014-08-06 15:15:58', 'AddedByUserId' : '0', 'TrialUnitSpecimenId' : '0', 'ItemTypeId' : '148', 'ItemChild' : [{'DateAdded' : '2014-08-06 15:15:58', 'ItemId' : '24', 'ItemParentType' : '150', 'AddedByUserId' : '0', 'TrialUnitSpecimenId' : '0', 'ItemTypeId' : '148', 'ContainerTypeId' : '146', 'ItemNote' : '', 'ItemStateId' : '149', 'SpecimenId' : '488', 'ScaleId' : '16', 'ItemOperation' : 'group', 'LastMeasuredUserId' : '0', 'ItemBarcode' : 'I_3423475', 'removeChild' : 'delete/itemparent/4', 'UnitId' : '18', 'StorageId' : '10', 'ItemParentTypeName' : 'Tower - 4888818', 'Amount' : '5.000', 'ItemParentId' : '4', 'ItemSourceId' : '32', 'LastMeasuredDate' : '2012-08-01 00:00:00'}], 'ContainerTypeId' : '146', 'ItemNote' : '', 'ItemStateId' : '149', 'ParentId' : '25', 'SpecimenId' : '488', 'ScaleId' : '16', 'ItemOperation' : 'group', 'LastMeasuredUserId' : '0', 'ItemBarcode' : 'I_1343739', 'UnitId' : '18', 'StorageId' : '10', 'Amount' : '5.000', 'LastMeasuredDate' : '2012-08-01 00:00:00', 'ItemSourceId' : '32'}], 'RecordMeta' : [{'TagName' : 'ItemParent'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;

  my $data_for_postrun_href = {};

  my $sql = "SELECT itemparent.ParentId, item.* ";
  $sql   .= "FROM itemparent LEFT JOIN item ON itemparent.ParentId = item.ItemId ";
  $sql   .= "GROUP BY itemparent.ParentId ";
  $sql   .= "ORDER BY ItemParentId DESC";

  my ($read_itemparent_err, $read_itemparent_msg, $itemparent_data) = $self->list_itemparent(1, $sql);

  if ($read_itemparent_err) {

    $self->logger->debug($read_itemparent_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'ItemParent'  => $itemparent_data,
                                           'RecordMeta' => [{'TagName' => 'ItemParent'}],
  };

  return $data_for_postrun_href;
}

sub get_itemparent_runmode {

=pod get_itemparent_HELP_START
{
"OperationName": "Get item parent",
"Description": "Get detailed information for parent inventory item.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ItemParent DateAdded='2014-08-06 15:10:06' AddedByUserId='0' ItemTypeId='143' TrialUnitSpecimenId='0' ContainerTypeId='141' ItemNote='' ItemStateId='144' ParentId='23' SpecimenId='487' ScaleId='15' ItemOperation='group' LastMeasuredUserId='0' ItemBarcode='I_7440343' UnitId='17' StorageId='9' Amount='5.000' ItemSourceId='31' LastMeasuredDate='2012-08-01 00:00:00'><ItemChild DateAdded='2014-08-06 15:10:06' ItemId='22' AddedByUserId='0' ItemParentType='145' ItemTypeId='143' TrialUnitSpecimenId='0' ContainerTypeId='141' ItemNote='' ItemStateId='144' ScaleId='15' SpecimenId='487' ItemOperation='group' LastMeasuredUserId='0' ItemBarcode='I_5674613' removeChild='delete/itemparent/3' UnitId='17' StorageId='9' ItemParentTypeName='Tower - 6294191' Amount='5.000' LastMeasuredDate='2012-08-01 00:00:00' ItemSourceId='31' ItemParentId='3' /></ItemParent><RecordMeta TagName='ItemParent' /></DATA>",
"SuccessMessageJSON": "{'ItemParent' : [{'DateAdded' : '2014-08-06 15:10:06', 'AddedByUserId' : '0', 'TrialUnitSpecimenId' : '0', 'ItemTypeId' : '143', 'ItemChild' : [{'DateAdded' : '2014-08-06 15:10:06', 'ItemId' : '22', 'ItemParentType' : '145', 'AddedByUserId' : '0', 'TrialUnitSpecimenId' : '0', 'ItemTypeId' : '143', 'ContainerTypeId' : '141', 'ItemNote' : '', 'ItemStateId' : '144', 'SpecimenId' : '487', 'ScaleId' : '15', 'ItemOperation' : 'group', 'LastMeasuredUserId' : '0', 'ItemBarcode' : 'I_5674613', 'removeChild' : 'delete/itemparent/3', 'UnitId' : '17', 'StorageId' : '9', 'ItemParentTypeName' : 'Tower - 6294191', 'Amount' : '5.000', 'ItemParentId' : '3', 'ItemSourceId' : '31', 'LastMeasuredDate' : '2012-08-01 00:00:00'}], 'ContainerTypeId' : '141', 'ItemNote' : '', 'ItemStateId' : '144', 'ParentId' : '23', 'ScaleId' : '15', 'SpecimenId' : '487', 'ItemOperation' : 'group', 'LastMeasuredUserId' : '0', 'ItemBarcode' : 'I_7440343', 'UnitId' : '17', 'StorageId' : '9', 'Amount' : '5.000', 'LastMeasuredDate' : '2012-08-01 00:00:00', 'ItemSourceId' : '31'}], 'RecordMeta' : [{'TagName' : 'ItemParent'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='ItemParentId (1): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'ItemParentId (1): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing ItemParentId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self           = shift;
  my $item_parent_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();
  my $grp_exist = record_existence($dbh, 'itemparent', 'ItemParentId', $item_parent_id);
  $dbh->disconnect();

  if (!$grp_exist) {

    return $self->_set_error("ItemParentId ($item_parent_id): not found.");
  }

  my $sql = "SELECT itemparent.ParentId, item.* ";
  $sql   .= "FROM itemparent LEFT JOIN item ON itemparent.ParentId = item.ItemId ";
  $sql   .= "WHERE itemparent.ItemParentId=? ";
  $sql   .= "GROUP BY itemparent.ParentId ";

  my ($read_itemparent_err, $read_itemparent_msg, $itemparent_data) = $self->list_itemparent(1, $sql, [$item_parent_id]);

  if ($read_itemparent_err) {

    $self->logger->debug($read_itemparent_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'ItemParent'  => $itemparent_data,
                                           'RecordMeta' => [{'TagName' => 'ItemParent'}],
  };

  return $data_for_postrun_href;
}

sub import_item_csv_runmode {

=pod import_item_csv_gadmin_HELP_START
{
"OperationName": "Import items",
"Description": "Import items from a csv file formatted as a sparse matrix of item data.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='3 records of items have been inserted successfully.' /><StatInfo Unit='second' ServerElapsedTime='0.053' /><ReturnOther Value='2017-04-24 16:29:41' ParaName='LastUpdateTimeStamp' /><ReturnIdFile xml='http://blackbox.diversityarrays.com/data/admin/import_item_csv_gadmin_return_id_182.xml' /></DATA>",
"SuccessMessageJSON": "{'ReturnIdFile' : [{'json' : 'http://blackbox.diversityarrays.com/data/admin/import_item_csv_gadmin_return_id_206.json'}],'ReturnOther' : [{'Value' : '2017-04-24 16:36:21','ParaName' : 'LastUpdateTimeStamp'}],'StatInfo' : [{'ServerElapsedTime' : '0.064','Unit' : 'second'}],'Info' : [{'Message' : '3 records of items have been inserted successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Row (1): SpecimenId (872) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Row (1): SpecimenId (872) not found.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "CSV",
"UploadFileParameterName": "uploadfile",
"HTTPParameter": [{"Required": 1, "Name": "ItemTypeId", "Description": "Column number starting from zero for the column in the CSV file that contains ItemTypeId value"}, {"Required": 0, "Name": "SpecimenId", "Description": "Column number starting from zero for the column in the CSV file that contains SpecimenId value. This is required if TrialUnitSpecimenId column value is not provided"}, {"Required": 0, "Name": "UnitId", "Description": "Column number starting from zero for the column in the CSV file that contains UnitId value"}, {"Required": 0, "Name": "TrialUnitSpecimenId", "Description": "Column number starting from zero for the column in the CSV file that contains TrialUnitSpecimenId value. The value in this column must lead to the same SpecimenId if SpecimenId column is provided."}, {"Required": 0, "Name": "ItemSourceId", "Description": "Column number starting from zero for the column in the CSV file that contains ItemSourceId value"}, {"Required": 0, "Name": "ContainerTypeId", "Description": "Column number starting from zero for the column in the CSV file that contains ContainerTypeId value"}, {"Required": 0, "Name": "ScaleId", "Description": "Column number starting from zero for the column in the CSV file that contains ScaleId value"}, {"Required": 0, "Name": "StorageId", "Description": "Column number starting from zero for the column in the CSV file that contains StorageId value"}, {"Required": 0, "Name": "ItemStateId", "Description": "Column number starting from zero for the column in the CSV file that contains ItemStateId value"}, {"Required": 0, "Name": "ItemBarcode", "Description": "Column number starting from zero for the column in the CSV file that contains ItemBarcode value. If ItemBarcode is provided, it must be unique."}, {"Required": 0, "Name": "Amount", "Description": "Column number starting from zero for the column in the CSV file that contains Amount value"}, {"Required": 0, "Name": "DateAdded", "Description": "Column number starting from zero for the column in the CSV file that contains DateAdded value"}, {"Required": 0, "Name": "AddedByUserId", "Description": "Column number starting from zero for the column in the CSV file that contains AddedByUserId value"}, {"Required": 0, "Name": "ItemOperation", "Description": "Column number starting from zero for the column in the CSV file that contains ItemOperation value"}, {"Required": 0, "Name": "ItemNote", "Description": "Column number starting from zero for the column in the CSV file that contains ItemNote value"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $data_csv_file = $self->authen->get_upload_file();

  my $num_of_col = get_csvfile_num_of_col($data_csv_file);

  $self->logger->debug("Number of columns: $num_of_col");

  my $ItemTypeId_col = $query->param('ItemTypeId');

  my ($col_def_err, $col_def_err_href) = check_col_def_href( { 'ItemTypeId' => $ItemTypeId_col }, $num_of_col );

  if ($col_def_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$col_def_err_href]};

    return $data_for_postrun_href;
  }

  my $matched_col = {};

  $matched_col->{$ItemTypeId_col} = 'ItemTypeId';

  # Checking optional columns

  my $TrialUnitSpecimenId_col      = '';
  my $ItemSourceId_col             = '';
  my $ContainerTypeId_col          = '';
  my $SpecimenId_col               = '';
  my $ScaleId_col                  = '';
  my $StorageId_col                = '';
  my $UnitId_col                   = '';
  my $ItemStateId_col              = '';
  my $ItemBarcode_col              = '';
  my $Amount_col                   = '';
  my $DateAdded_col                = '';
  my $AddedByUserId_col            = '';
  my $ItemOperation_col            = '';
  my $ItemNote_col                 = '';

  my $chk_optional_col_href = {};

  if (defined $query->param('TrialUnitSpecimenId')) {

    if (length($query->param('TrialUnitSpecimenId')) > 0) {

      $TrialUnitSpecimenId_col = $query->param('TrialUnitSpecimenId');

      $chk_optional_col_href->{'TrialUnitSpecimenId'} = $TrialUnitSpecimenId_col;
      $matched_col->{$TrialUnitSpecimenId_col}        = 'TrialUnitSpecimenId';
    }
  }

  if (defined $query->param('ItemSourceId')) {

    if (length($query->param('ItemSourceId')) > 0) {

      $ItemSourceId_col = $query->param('ItemSourceId');

      $chk_optional_col_href->{'ItemSourceId'} = $ItemSourceId_col;
      $matched_col->{$ItemSourceId_col}        = 'ItemSourceId';
    }
  }

  if (defined $query->param('ContainerTypeId')) {

    if (length($query->param('ContainerTypeId')) > 0) {

      $ContainerTypeId_col = $query->param('ContainerTypeId');

      $chk_optional_col_href->{'ContainerTypeId'} = $ContainerTypeId_col;
      $matched_col->{$ContainerTypeId_col}        = 'ContainerTypeId';
    }
  }

  if (defined $query->param('SpecimenId')) {

    if (length($query->param('SpecimenId')) > 0) {

      $SpecimenId_col = $query->param('SpecimenId');

      $chk_optional_col_href->{'SpecimenId'} = $SpecimenId_col;
      $matched_col->{$SpecimenId_col}        = 'SpecimenId';
    }
  }

  if (defined $query->param('ScaleId')) {

    if (length($query->param('ScaleId')) > 0) {

      $ScaleId_col = $query->param('ScaleId');

      $chk_optional_col_href->{'ScaleId'} = $ScaleId_col;
      $matched_col->{$ScaleId_col}        = 'ScaleId';
    }
  }

  if (defined $query->param('StorageId')) {

    if (length($query->param('StorageId')) > 0) {

      $StorageId_col = $query->param('StorageId');

      $chk_optional_col_href->{'StorageId'} = $StorageId_col;
      $matched_col->{$StorageId_col}        = 'StorageId';
    }
  }

  if (defined $query->param('UnitId')) {

    if (length($query->param('UnitId')) > 0) {

      $UnitId_col = $query->param('UnitId');

      $chk_optional_col_href->{'UnitId'} = $UnitId_col;
      $matched_col->{$UnitId_col}        = 'UnitId';
    }
  }

  if (defined $query->param('ItemStateId')) {

    if (length($query->param('ItemStateId')) > 0) {

      $ItemStateId_col = $query->param('ItemStateId');

      $chk_optional_col_href->{'ItemStateId'} = $ItemStateId_col;
      $matched_col->{$ItemStateId_col}        = 'ItemStateId';
    }
  }

  if (defined $query->param('ItemBarcode')) {

    if (length($query->param('ItemBarcode')) > 0) {

      $ItemBarcode_col = $query->param('ItemBarcode');

      $chk_optional_col_href->{'ItemBarcode'} = $ItemBarcode_col;
      $matched_col->{$ItemBarcode_col}        = 'ItemBarcode';
    }
  }

  if (defined $query->param('Amount')) {

    if (length($query->param('Amount')) > 0) {

      $Amount_col = $query->param('Amount');

      $chk_optional_col_href->{'Amount'} = $Amount_col;
      $matched_col->{$Amount_col}        = 'Amount';
    }
  }

  if (defined $query->param('DateAdded')) {

    if (length($query->param('DateAdded')) > 0) {

      $DateAdded_col = $query->param('DateAdded');

      $chk_optional_col_href->{'DateAdded'} = $DateAdded_col;
      $matched_col->{$DateAdded_col}        = 'DateAdded';
    }
  }

  if (defined $query->param('AddedByUserId')) {

    if (length($query->param('AddedByUserId')) > 0) {

      $AddedByUserId_col = $query->param('AddedByUserId');

      $chk_optional_col_href->{'AddedByUserId'} = $AddedByUserId_col;
      $matched_col->{$AddedByUserId_col}        = 'AddedByUserId';
    }
  }

  if (defined $query->param('ItemOperation')) {

    if (length($query->param('ItemOperation')) > 0) {

      $ItemOperation_col = $query->param('ItemOperation');

      $chk_optional_col_href->{'ItemOperation'} = $ItemOperation_col;
      $matched_col->{$ItemOperation_col}        = 'ItemOperation';
    }
  }

  if (defined $query->param('ItemNote')) {

    if (length($query->param('ItemNote')) > 0) {

      $ItemNote_col = $query->param('ItemNote');

      $chk_optional_col_href->{'ItemNote'} = $ItemNote_col;
      $matched_col->{$ItemNote_col}        = 'ItemNote';
    }
  }

  ($col_def_err, $col_def_err_href) = check_col_def_href( $chk_optional_col_href, $num_of_col );

  if ($col_def_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$col_def_err_href]};

    return $data_for_postrun_href;
  }

  my @fieldname_list;

  for (my $i = 0; $i < $num_of_col; $i++) {

    if ($matched_col->{$i}) {

      push(@fieldname_list, $matched_col->{$i});
    }
    else {

      push(@fieldname_list, 'null');
    }
  }

  my ($data_aref, $csv_err, $err_msg) = csvfile2arrayref($data_csv_file, \@fieldname_list, 0);

  if ($csv_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$data_aref}) == 0) {

    $self->logger->debug("No data provided");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $user_id       = $self->authen->user_id();
  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str      = permission_phrase($group_id, 0, $gadmin_status, 'specimen');

  my $sql;
  my $sth;

  my $cur_dt = DateTime->now( time_zone => $TIMEZONE );
  $cur_dt = DateTime::Format::MySQL->format_datetime($cur_dt);

  my $dbh_write = connect_kdb_write();

  my $uniq_unit_id_href           = {};
  my $uniq_tu_spec_id_href        = {};
  my $uniq_itm_src_id_href        = {};
  my $uniq_container_type_id_href = {};
  my $uniq_spec_id_href           = {};
  my $uniq_scale_id_href          = {};
  my $uniq_storage_id_href        = {};
  my $uniq_itm_type_id_href       = {};
  my $uniq_itm_state_id_href      = {};
  my $uniq_itm_barcode_href       = {};
  my $uniq_user_id_href           = {};

  $cur_dt = DateTime->now( time_zone => $TIMEZONE );

  my $row_counter = 1;
  for my $data_row (@{$data_aref}) {

    my $db_specimen_id     = '';
    my $trial_unit_spec_id = '';

    if (defined $data_row->{'TrialUnitSpecimenId'}) {

      if (length($data_row->{'TrialUnitSpecimenId'}) > 0) {

        $trial_unit_spec_id = $data_row->{'TrialUnitSpecimenId'};
        $uniq_tu_spec_id_href->{$trial_unit_spec_id} = $row_counter;
      }
    }

    my $item_src_id = '';

    if (defined $data_row->{'ItemSourceId'}) {

      if (length($data_row->{'ItemSourceId'}) > 0) {

        $item_src_id = $data_row->{'ItemSourceId'};
        $uniq_itm_src_id_href->{$item_src_id} = $row_counter;
      }
    }

    my $container_type_id = '';

    if (defined $data_row->{'ContainerTypeId'}) {

      if (length($data_row->{'ContainerTypeId'}) > 0) {

        $container_type_id = $data_row->{'ContainerTypeId'};
        $uniq_container_type_id_href->{$container_type_id} = $row_counter;
      }
    }

    my $specimen_id = '';

    if (defined $data_row->{'SpecimenId'}) {

      if (length($data_row->{'SpecimenId'}) > 0) {

        $specimen_id = $data_row->{'SpecimenId'};
        $uniq_spec_id_href->{$specimen_id} = $row_counter;
      }
    }

    if (length($specimen_id) == 0 && length($trial_unit_spec_id) == 0) {

      my $err_msg = "Row ($row_counter): SpecimenId and TrialUnitSpecimenId are missing.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $scale_id = '';

    if (defined $data_row->{'ScaleId'}) {

      if (length($data_row->{'ScaleId'}) > 0) {

        $scale_id = $data_row->{'ScaleId'};
        $uniq_scale_id_href->{$scale_id} = $row_counter;
      }
    }

    my $storage_id = '';

    if (defined $data_row->{'StorageId'}) {

      if (length($data_row->{'StorageId'}) > 0) {

        $storage_id = $data_row->{'StorageId'};
        $uniq_storage_id_href->{$storage_id} = $row_counter;
      }
    }

    my $item_unit_id = '';

    if (defined $data_row->{'UnitId'}) {

      if (length($data_row->{'UnitId'}) > 0) {

        $item_unit_id = $data_row->{'UnitId'};
        $uniq_unit_id_href->{$item_unit_id} = $row_counter;
      }
    }

    if (length($item_unit_id) == 0) {

      my $err_msg = "Row ($row_counter): UnitId is missing.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $item_type_id = '';

    if (defined $data_row->{'ItemTypeId'}) {

      if (length($data_row->{'ItemTypeId'}) > 0) {

        $item_type_id = $data_row->{'ItemTypeId'};
        $uniq_itm_type_id_href->{$item_type_id} = $row_counter;
      }
    }

    if (length($item_type_id) == 0) {

      my $err_msg = "Row ($row_counter): ItemTypeId missing";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $item_state_id = '';

    if (defined $data_row->{'ItemStateId'}) {

      if (length($data_row->{'ItemStateId'}) > 0) {

        $item_state_id = $data_row->{'ItemStateId'};
        $uniq_itm_state_id_href->{$item_state_id} = $row_counter;
      }
    }

    my $item_barcode = '';

    if (defined $data_row->{'ItemBarcode'}) {

      if (length($data_row->{'ItemBarcode'}) > 0) {

        $item_barcode = uc($data_row->{'ItemBarcode'});

        if (defined $uniq_itm_barcode_href->{qq|'$item_barcode'|}) {

          my $dup_barcode_row = $uniq_itm_barcode_href->{qq|'$item_barcode'|};

          my $err_msg = "Row ($row_counter): ItemBarcode ($item_barcode) is already used ";
          $err_msg   .= "in row ($dup_barcode_row).";

          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
        else {

          $uniq_itm_barcode_href->{qq|'$item_barcode'|} = $row_counter;
        }
      }
    }

    my $amount = '';

    if (defined $data_row->{'Amount'}) {

      if (length($data_row->{'Amount'}) > 0) {

        $amount = $data_row->{'Amount'};

        my ($amount_err, $amount_msg) = check_float_value( {'Amount' => $amount} );

        if ($amount_err) {

          my $err_msg = "Row ($row_counter): Amount ($amount) invalid number.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
      }
    }

    my $date_added = $cur_dt;

    if (defined $data_row->{'DateAdded'}) {

      if (length($data_row->{'DateAdded'})) {

        $date_added = $data_row->{'DateAdded'};

        my ( $mdt_to_err, $mdt_to_msg ) = check_dt_value( { 'DateAdded' => $date_added } );

        if ($mdt_to_err) {

          my $err_msg = "Row ($row_counter): DateAdded ($date_added) unknown date format.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
      }
    }

    my $added_by_user_id = $user_id;

    if (defined $data_row->{'AddedByUserId'}) {

      if (length($data_row->{'AddedByUserId'}) > 0) {

        $added_by_user_id = $data_row->{'AddedByUserId'};
        $uniq_user_id_href->{$added_by_user_id} = $row_counter;
      }
    }

    my $item_operation = '';

    if (defined $data_row->{'ItemOperation'}) {

      if (length($data_row->{'ItemOperation'}) > 0) {

        $item_operation = $data_row->{'ItemOperation'};

        if ($item_operation !~ /^subsample|^group/ ) {

          my $err_msg = "Row ($row_counter): ItemOperation ($item_operation) not valid.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
      }
    }

    my $item_note = '';

    if (defined $data_row->{'ItemNote'}) {

      if (length($data_row->{'ItemNote'}) > 0) {

        $item_note = $data_row->{'ItemNote'};
      }
    }

    if (length($trial_unit_spec_id) == 0) {

      $trial_unit_spec_id = 'NULL';
    }

    if (length($item_src_id) == 0) {

      $item_src_id = 'NULL';
    }

    if (length($container_type_id) == 0) {

      $container_type_id = 'NULL';
    }

    if (length($scale_id) == 0) {

      $scale_id = 'NULL';
    }

    if (length($storage_id) == 0) {

      $storage_id = 'NULL';
    }

    if (length($item_state_id) == 0) {

      $item_state_id = 'NULL';
    }

    if (length($item_barcode) == 0) {

      $item_barcode = 'NULL';
    }
    else {

      $item_barcode = qq|'$item_barcode'|;
    }

    if (length($amount) == 0) {

      $amount = 'NULL';
    }

    if (length($item_operation) == 0) {

      $item_operation = 'NULL';
    }
    else {

      $item_operation = qq|'$item_operation'|;
    }

    if (length($item_note) == 0) {

      $item_note = 'NULL';
    }
    else {

      $item_note = qq|'$item_note'|;
    }

    $row_counter += 1;
  }

  my @uniq_unit_id_list = keys(%{$uniq_unit_id_href});

  if (scalar(@uniq_unit_id_list) > 0) {

    $sql = 'SELECT UnitId FROM generalunit WHERE UnitId IN (' . join(',', @uniq_unit_id_list) . ')';
    $sth = $dbh_write->prepare($sql);
    $sth->execute();

    if ($dbh_write->err()) {

      $self->logger->debug("Read UnitId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $db_unit_id_href = $sth->fetchall_hashref('UnitId');

    if ($sth->err()) {

      $self->logger->debug("Fetch UnitId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my @not_found_unit_id_list;
    my @not_found_row_list;

    foreach my $unit_id (@uniq_unit_id_list) {

      if (! (defined $db_unit_id_href->{$unit_id}) ) {

        push(@not_found_unit_id_list, $unit_id);
        push(@not_found_row_list, $uniq_unit_id_href->{$unit_id});
      }
    }

    if (scalar(@not_found_unit_id_list) > 0) {

      my $err_msg = "Row (" . join(',', @not_found_row_list) . ' UnitId (';
      $err_msg   .= join(',', @not_found_unit_id_list) . ') not found';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @uniq_tu_spec_id_list = keys(%{$uniq_tu_spec_id_href});

  if (scalar(@uniq_tu_spec_id_list) > 0) {

    $sql  = 'SELECT TrialUnitSpecimenId, SpecimenId ';
    $sql .= 'FROM trialunitspecimen WHERE TrialUnitSpecimenId IN (' . join(',', @uniq_tu_spec_id_list) . ')';

    $sth = $dbh_write->prepare($sql);
    $sth->execute();

    if ($dbh_write->err()) {

      $self->logger->debug("Read TrialUnitSpecimenId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $db_tu_spec_id_href = $sth->fetchall_hashref('TrialUnitSpecimenId');

    if ($sth->err()) {

      $self->logger->debug("Fetch TrialUnitSpecimenId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my @not_found_tu_spec_id_list;
    my @not_found_row_list;

    foreach my $tu_spec_id (@uniq_tu_spec_id_list) {

      my $tu_spec_row = $uniq_tu_spec_id_href->{$tu_spec_id};
      my $data_aref_i = $tu_spec_row - 1;

      if (! (defined $db_tu_spec_id_href->{$tu_spec_id}) ) {

        push(@not_found_tu_spec_id_list, $tu_spec_id);
        push(@not_found_row_list, $tu_spec_row);
      }
      else {

        my $db_spec_id = $db_tu_spec_id_href->{$tu_spec_id}->{'SpecimenId'};

        if (! (defined $data_aref->[$data_aref_i]->{'SpecimenId'}) ) {

          $data_aref->[$data_aref_i]->{'SpecimenId'} = $db_spec_id;
        }
        else {

          my $user_spec_id = $data_aref->[$data_aref_i]->{'SpecimenId'};

          if ($db_spec_id != $user_spec_id) {

            my $err_msg = "Row ($tu_spec_row): SpecimenId ($db_spec_id) from TrialUnitSpecimenId ($tu_spec_id) ";
            $err_msg   .= "different from SpecimenId ($user_spec_id) provided.";

            $data_for_postrun_href->{'Error'} = 1;
            $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

            return $data_for_postrun_href;
          }
        }
      }
    }

    if (scalar(@not_found_tu_spec_id_list) > 0) {

      my $err_msg = "Row (" . join(',', @not_found_row_list) . ' TrialUnitSpecimenId (';
      $err_msg   .= join(',', @not_found_tu_spec_id_list) . ') not found';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @uniq_itm_src_id_list = keys(%{$uniq_itm_src_id_href});

  if (scalar(@uniq_itm_src_id_list) > 0) {

    $sql = 'SELECT ContactId FROM contact WHERE ContactId IN (' . join(',', @uniq_itm_src_id_list) . ')';
    $sth = $dbh_write->prepare($sql);
    $sth->execute();

    if ($dbh_write->err()) {

      $self->logger->debug("Read ItemSourceId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $db_itm_src_id_href = $sth->fetchall_hashref('ContactId');

    if ($sth->err()) {

      $self->logger->debug("Fetch ItemSourceId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my @not_found_itm_src_id_list;
    my @not_found_row_list;

    foreach my $itm_src_id (@uniq_itm_src_id_list) {

      if (! (defined $db_itm_src_id_href->{$itm_src_id}) ) {

        push(@not_found_itm_src_id_list, $itm_src_id);
        push(@not_found_row_list, $uniq_itm_src_id_href->{$itm_src_id});
      }
    }

    if (scalar(@not_found_itm_src_id_list) > 0) {

      my $err_msg = "Row (" . join(',', @not_found_row_list) . ' ItemSourceId (';
      $err_msg   .= join(',', @not_found_itm_src_id_list) . ') not found';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @uniq_container_type_id_list = keys(%{$uniq_container_type_id_href});

  if (scalar(@uniq_container_type_id_list) > 0) {

    $sql  = 'SELECT TypeId FROM generaltype WHERE TypeId IN (' . join(',', @uniq_container_type_id_list) . ') ';
    $sql .= " AND IsTypeActive=1 AND Class='container'";

    $sth = $dbh_write->prepare($sql);
    $sth->execute();

    if ($dbh_write->err()) {

      $self->logger->debug("Read ContainerTypeId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $db_container_type_id_href = $sth->fetchall_hashref('TypeId');

    if ($sth->err()) {

      $self->logger->debug("Fetch ContainerTypeId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my @not_found_container_type_id_list;
    my @not_found_row_list;

    foreach my $container_type_id (@uniq_container_type_id_list) {

      if (! (defined $db_container_type_id_href->{$container_type_id}) ) {

        push(@not_found_container_type_id_list, $container_type_id);
        push(@not_found_row_list, $uniq_container_type_id_href->{$container_type_id});
      }
    }

    if (scalar(@not_found_container_type_id_list) > 0) {

      my $err_msg = "Row (" . join(',', @not_found_row_list) . ' ContainerTypeId (';
      $err_msg   .= join(',', @not_found_container_type_id_list) . ') not found';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @uniq_spec_id_list = keys(%{$uniq_spec_id_href});

  if (scalar(@uniq_spec_id_list) > 0) {

    $sql  = "SELECT SpecimenId, $perm_str AS UltimatePerm ";
    $sql .= 'FROM specimen WHERE SpecimenId IN (' . join(',', @uniq_spec_id_list) . ')';
    $sth = $dbh_write->prepare($sql);
    $sth->execute();

    if ($dbh_write->err()) {

      $self->logger->debug("Read SpecimenId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $db_spec_id_href = $sth->fetchall_hashref('SpecimenId');

    if ($sth->err()) {

      $self->logger->debug("Fetch SpecimenId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my @not_found_spec_id_list;
    my @not_found_row_list;

    my @perm_denied_spec_id_list;
    my @perm_denied_row_list;

    foreach my $spec_id (@uniq_spec_id_list) {

      my $row_num = $uniq_spec_id_href->{$spec_id};

      if (! (defined $db_spec_id_href->{$spec_id}) ) {

        push(@not_found_spec_id_list, $spec_id);
        push(@not_found_row_list, $row_num);
      }
      else {

        my $perm = $db_spec_id_href->{$spec_id}->{'UltimatePerm'};

        if (( $perm & $READ_PERM) != $READ_PERM ) {

          push(@perm_denied_spec_id_list, $spec_id);
          push(@perm_denied_row_list, $row_num);
        }
      }
    }

    if (scalar(@not_found_spec_id_list) > 0) {

      my $err_msg = "Row (" . join(',', @not_found_row_list) . ' SpecimenId (';
      $err_msg   .= join(',', @not_found_spec_id_list) . ') not found';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if (scalar(@perm_denied_spec_id_list) > 0) {

      my $err_msg = "Row (" . join(',', @perm_denied_row_list) . ' SpecimenId (';
      $err_msg   .= join(',', @perm_denied_spec_id_list) . ') permission denied.';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @uniq_scale_id_list = keys(%{$uniq_scale_id_href});

  if (scalar(@uniq_scale_id_list) > 0) {

    $sql  = 'SELECT DeviceRegisterId FROM deviceregister ';
    $sql .= 'WHERE DeviceRegisterId IN (' . join(',', @uniq_scale_id_list) . ')';
    $sth = $dbh_write->prepare($sql);
    $sth->execute();

    if ($dbh_write->err()) {

      $self->logger->debug("Read DeviceRegisterId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $db_scale_id_href = $sth->fetchall_hashref('DeviceRegisterId');

    if ($sth->err()) {

      $self->logger->debug("Fetch DeviceRegisterId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my @not_found_scale_id_list;
    my @not_found_row_list;

    foreach my $scale_id (@uniq_scale_id_list) {

      if (! (defined $db_scale_id_href->{$scale_id}) ) {

        push(@not_found_scale_id_list, $scale_id);
        push(@not_found_row_list, $uniq_scale_id_href->{$scale_id});
      }
    }

    if (scalar(@not_found_scale_id_list) > 0) {

      my $err_msg = "Row (" . join(',', @not_found_row_list) . ' ScaleId (';
      $err_msg   .= join(',', @not_found_scale_id_list) . ') not found';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @uniq_storage_id_list = keys(%{$uniq_storage_id_href});

  if (scalar(@uniq_storage_id_list) > 0) {

    $sql = 'SELECT StorageId FROM storage WHERE StorageId IN (' . join(',', @uniq_storage_id_list) . ')';
    $sth = $dbh_write->prepare($sql);
    $sth->execute();

    if ($dbh_write->err()) {

      $self->logger->debug("Read StorageId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $db_storage_id_href = $sth->fetchall_hashref('StorageId');

    if ($sth->err()) {

      $self->logger->debug("Fetch StorageId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my @not_found_storage_id_list;
    my @not_found_row_list;

    foreach my $storage_id (@uniq_storage_id_list) {

      if (! (defined $db_storage_id_href->{$storage_id}) ) {

        push(@not_found_storage_id_list, $storage_id);
        push(@not_found_row_list, $uniq_storage_id_href->{$storage_id});
      }
    }

    if (scalar(@not_found_storage_id_list) > 0) {

      my $err_msg = "Row (" . join(',', @not_found_row_list) . ' StorageId (';
      $err_msg   .= join(',', @not_found_storage_id_list) . ') not found';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }


  my @uniq_itm_type_id_list = keys(%{$uniq_itm_type_id_href});

  if (scalar(@uniq_itm_type_id_list) > 0) {

    $sql  = 'SELECT TypeId FROM generaltype WHERE TypeId IN (' . join(',', @uniq_itm_type_id_list) . ') ';
    $sql .= " AND IsTypeActive=1 AND Class='item'";

    $sth = $dbh_write->prepare($sql);
    $sth->execute();

    if ($dbh_write->err()) {

      $self->logger->debug("Read ItemTypeId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $db_itm_type_id_href = $sth->fetchall_hashref('TypeId');

    if ($sth->err()) {

      $self->logger->debug("Fetch ItemTypeId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my @not_found_itm_type_id_list;
    my @not_found_row_list;

    foreach my $itm_type_id (@uniq_itm_type_id_list) {

      if (! (defined $db_itm_type_id_href->{$itm_type_id}) ) {

        push(@not_found_itm_type_id_list, $itm_type_id);
        push(@not_found_row_list, $uniq_itm_type_id_href->{$itm_type_id});
      }
    }

    if (scalar(@not_found_itm_type_id_list) > 0) {

      my $err_msg = "Row (" . join(',', @not_found_row_list) . ' ItemTypeId (';
      $err_msg   .= join(',', @not_found_itm_type_id_list) . ') not found';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @uniq_itm_state_id_list = keys(%{$uniq_itm_state_id_href});

  if (scalar(@uniq_itm_state_id_list) > 0) {

    $sql  = 'SELECT TypeId FROM generaltype WHERE TypeId IN (' . join(',', @uniq_itm_state_id_list) . ') ';
    $sql .= " AND IsTypeActive=1 AND Class='state'";

    $sth = $dbh_write->prepare($sql);
    $sth->execute();

    if ($dbh_write->err()) {

      $self->logger->debug("Read ItemStateId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $db_itm_state_id_href = $sth->fetchall_hashref('TypeId');

    if ($sth->err()) {

      $self->logger->debug("Fetch ItemStateId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my @not_found_itm_state_id_list;
    my @not_found_row_list;

    foreach my $itm_state_id (@uniq_itm_state_id_list) {

      if (! (defined $db_itm_state_id_href->{$itm_state_id}) ) {

        push(@not_found_itm_state_id_list, $itm_state_id);
        push(@not_found_row_list, $uniq_itm_state_id_href->{$itm_state_id});
      }
    }

    if (scalar(@not_found_itm_state_id_list) > 0) {

      my $err_msg = "Row (" . join(',', @not_found_row_list) . ' ItemStateId (';
      $err_msg   .= join(',', @not_found_itm_state_id_list) . ') not found';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @uniq_itm_barcode_list = keys(%{$uniq_itm_barcode_href});

  if (scalar(@uniq_itm_barcode_list) > 0) {

    $sql = 'SELECT ItemBarcode FROM item WHERE ItemBarcode IN (' . join(',', @uniq_itm_barcode_list) . ')';
    $sth = $dbh_write->prepare($sql);
    $sth->execute();

    if ($dbh_write->err()) {

      $self->logger->debug("Read ItemBarcode failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $db_itm_barcode_href = $sth->fetchall_hashref('ItemBarcode');

    if ($sth->err()) {

      $self->logger->debug("Fetch ItemBarcode failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my @found_itm_barcode_list;
    my @found_row_list;

    foreach my $itm_barcode (@uniq_itm_barcode_list) {

      if ( defined $db_itm_barcode_href->{qq|'$itm_barcode'|} ) {

        push(@found_itm_barcode_list, $itm_barcode);
        push(@found_row_list, $uniq_itm_barcode_href->{qq|'$itm_barcode'|});
      }
    }

    if (scalar(@found_itm_barcode_list) > 0) {

      my $err_msg = "Row (" . join(',', @found_row_list) . ' ItemBarcode (';
      $err_msg   .= join(',', @found_itm_barcode_list) . ') already used.';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @uniq_user_id_list = keys(%{$uniq_user_id_href});

  if (scalar(@uniq_user_id_list) > 0) {

    $sql = 'SELECT UserId FROM systemuser WHERE UserId IN (' . join(',', @uniq_user_id_list) . ')';
    $sth = $dbh_write->prepare($sql);
    $sth->execute();

    if ($dbh_write->err()) {

      $self->logger->debug("Read UserId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $db_user_id_href = $sth->fetchall_hashref('UserId');

    if ($sth->err()) {

      $self->logger->debug("Fetch UserId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my @not_found_user_id_list;
    my @not_found_row_list;

    foreach my $user_id (@uniq_user_id_list) {

      if (! (defined $db_user_id_href->{$user_id}) ) {

        push(@not_found_user_id_list, $user_id);
        push(@not_found_row_list, $uniq_user_id_href->{$user_id});
      }
    }

    if (scalar(@not_found_user_id_list) > 0) {

      my $err_msg = "Row (" . join(',', @not_found_row_list) . ' AddedByUserId (';
      $err_msg   .= join(',', @not_found_user_id_list) . ') not found';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $bulk_sql = 'INSERT INTO item ';
  $bulk_sql   .= '(TrialUnitSpecimenId,ItemSourceId,ContainerTypeId,SpecimenId,ScaleId,StorageId,UnitId,';
  $bulk_sql   .= 'ItemTypeId,ItemStateId,ItemBarcode,Amount,DateAdded,AddedByUserId,ItemOperation,ItemNote,LastUpdateTimeStamp) ';
  $bulk_sql   .= 'VALUES ';

  for my $data_row (@{$data_aref}) {

    my $trial_unit_spec_id = '';

    if (defined $data_row->{'TrialUnitSpecimenId'}) {

      if (length($data_row->{'TrialUnitSpecimenId'}) > 0) {

        $trial_unit_spec_id = $data_row->{'TrialUnitSpecimenId'};
      }
    }

    my $item_src_id = '';

    if (defined $data_row->{'ItemSourceId'}) {

      if (length($data_row->{'ItemSourceId'}) > 0) {

        $item_src_id = $data_row->{'ItemSourceId'};
      }
    }

    my $container_type_id = '';

    if (defined $data_row->{'ContainerTypeId'}) {

      if (length($data_row->{'ContainerTypeId'}) > 0) {

        $container_type_id = $data_row->{'ContainerTypeId'};
      }
    }

    my $specimen_id = '';

    if (defined $data_row->{'SpecimenId'}) {

      if (length($data_row->{'SpecimenId'}) > 0) {

        $specimen_id = $data_row->{'SpecimenId'};
      }
    }

    my $scale_id = '';

    if (defined $data_row->{'ScaleId'}) {

      if (length($data_row->{'ScaleId'}) > 0) {

        $scale_id = $data_row->{'ScaleId'};
      }
    }

    my $storage_id = '';

    if (defined $data_row->{'StorageId'}) {

      if (length($data_row->{'StorageId'}) > 0) {

        $storage_id = $data_row->{'StorageId'};
      }
    }

    my $item_unit_id = $data_row->{'UnitId'};
    my $item_type_id = $data_row->{'ItemTypeId'};

    my $item_state_id = '';

    if (defined $data_row->{'ItemStateId'}) {

      if (length($data_row->{'ItemStateId'}) > 0) {

        $item_state_id = $data_row->{'ItemStateId'};
      }
    }

    my $item_barcode = '';

    if (defined $data_row->{'ItemBarcode'}) {

      if (length($data_row->{'ItemBarcode'}) > 0) {

        $item_barcode = $data_row->{'ItemBarcode'};
      }
    }

    my $amount = '';

    if (defined $data_row->{'Amount'}) {

      if (length($data_row->{'Amount'}) > 0) {

        $amount = $data_row->{'Amount'};
      }
    }

    my $date_added = $cur_dt;

    if (defined $data_row->{'DateAdded'}) {

      if (length($data_row->{'DateAdded'})) {

        $date_added = $data_row->{'DateAdded'};
      }
    }

    my $added_by_user_id = $user_id;

    if (defined $data_row->{'AddedByUserId'}) {

      if (length($data_row->{'AddedByUserId'}) > 0) {

        $added_by_user_id = $data_row->{'AddedByUserId'};
      }
    }

    my $item_operation = '';

    if (defined $data_row->{'ItemOperation'}) {

      if (length($data_row->{'ItemOperation'}) > 0) {

        $item_operation = $data_row->{'ItemOperation'};
      }
    }

    my $item_note = '';

    if (defined $data_row->{'ItemNote'}) {

      if (length($data_row->{'ItemNote'}) > 0) {

        $item_note = $data_row->{'ItemNote'};
      }
    }

    if (length($trial_unit_spec_id) == 0) {

      $trial_unit_spec_id = 'NULL';
    }

    if (length($item_src_id) == 0) {

      $item_src_id = 'NULL';
    }

    if (length($container_type_id) == 0) {

      $container_type_id = 'NULL';
    }

    if (length($scale_id) == 0) {

      $scale_id = 'NULL';
    }

    if (length($storage_id) == 0) {

      $storage_id = 'NULL';
    }

    if (length($item_state_id) == 0) {

      $item_state_id = 'NULL';
    }

    if (length($item_barcode) == 0) {

      $item_barcode = 'NULL';
    }
    else {

      $item_barcode = qq|'$item_barcode'|;
    }

    if (length($amount) == 0) {

      $amount = 'NULL';
    }

    if (length($item_operation) == 0) {

      $item_operation = 'NULL';
    }
    else {

      $item_operation = qq|'$item_operation'|;
    }

    if (length($item_note) == 0) {

      $item_note = 'NULL';
    }
    else {

      $item_note = qq|'$item_note'|;
    }

    $date_added = qq|'$date_added'|;

    my $last_update_ts = qq|'$cur_dt'|;

    $bulk_sql .= qq|($trial_unit_spec_id,$item_src_id,$container_type_id,$specimen_id,$scale_id,|;
    $bulk_sql .= qq|$storage_id,$item_unit_id,$item_type_id,$item_state_id,$item_barcode,|;
    $bulk_sql .= qq|$amount,$date_added,$added_by_user_id,$item_operation,$item_note,$last_update_ts),|;
  }

  chop($bulk_sql);        # remove excessive trailling comma

  $sql = 'SELECT ItemId FROM item ORDER BY ItemId DESC LIMIT 1';

  my $pre_last_item_id = read_cell($dbh_write, $sql, []);

  #$self->logger->debug("Bulk SQL: $bulk_sql");

  my $nrows_inserted = $dbh_write->do($bulk_sql);

  if ($dbh_write->err()) {

    $self->logger->debug("Db err code: " . $dbh_write->err());

    if ($dbh_write->err() == 1062) {

      my $err_str = $dbh_write->errstr();

      if ( $err_str =~ /Duplicate entry '(.+)'/ ) {

        my $err_msg = "Duplicate Entry: $1";

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
    else {

      $self->logger->debug('Error code: ' . $dbh_write->err());
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }
  }

  $sql = 'SELECT ItemId FROM item ORDER BY ItemId DESC LIMIT 1';

  my $post_last_item_id = read_cell($dbh_write, $sql, []);

  $sql  = 'SELECT ItemId, ItemBarcode FROM item WHERE ItemId > ? AND ItemId <= ? AND ISNULL(ItemBarcode) = FALSE';

  my ($r_itm_id_err, $r_itm_id_msg, $new_itm_data) = read_data($dbh_write, $sql,
                                                               [$pre_last_item_id, $post_last_item_id]);

  if ($r_itm_id_err) {

    $self->logger->debug("Get item id and item barcode failed: $r_itm_id_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $dbh_write->disconnect();

  my $just_inserted_id_data = [];

  for my $itm_rec (@{$new_itm_data}) {

    my $itm_id      = $itm_rec->{'ItemId'};
    my $itm_barcode = uc($itm_rec->{'ItemBarcode'});

    if (defined $uniq_itm_barcode_href->{qq|'$itm_barcode'|}) {

      push(@{$just_inserted_id_data}, $itm_rec);
    }
  }

  my $return_id_data = {};
  $return_id_data->{'ReturnId'}     = $just_inserted_id_data;
  $return_id_data->{'AlternateKey'} = [{'FieldName' => 'ItemBarcode'}];

  my $content_type = '';

  if ($self->authen->is_content_type_valid()) {

    $content_type = $self->authen->get_content_type();
  }

  if (length($content_type) == 0) {

    $content_type = 'xml';
  }
  else {

    $content_type = lc($content_type);
  }

  my $file_rand            = makerandom(Size => 8, Strength => 0);
  my $username             = $self->authen->username();
  my $doc_root             = $ENV{'DOCUMENT_ROOT'};
  my $export_data_path     = "${doc_root}/data/$username";
  my $return_id_filename   = $self->get_current_runmode() . "_return_id_${file_rand}.${content_type}";
  my $return_id_file       = "${export_data_path}/$return_id_filename";

  if ( !(-e $export_data_path) ) {

    mkdir($export_data_path);
  }

  my $return_id_content = '';

  $self->logger->debug("Content type: $content_type");

  if ($content_type eq 'xml') {

    $return_id_content = make_empty_xml();
    for my $xml_tag (keys(%{$return_id_data})) {

      my $this_xml_content = arrayref2xml($return_id_data->{$xml_tag}, $xml_tag);
      $return_id_content = merge_xml($this_xml_content, $return_id_content);
    }
  }
  elsif ($content_type eq 'json') {

    my $json_encoder = JSON::XS->new();
    $json_encoder->pretty(1);
    $json_encoder->utf8(1);
    $return_id_content = $json_encoder->encode($return_id_data);
  }

  #$self->logger->debug("Return ID content: $return_id_content");

  my $return_id_fh;
  open($return_id_fh, ">:encoding(utf8)", "$return_id_file") or die "$return_id_file: $!";
  print $return_id_fh $return_id_content;
  close($return_id_fh);

  my $url = reconstruct_server_url();
  my $output_file_href = { "$content_type"  => "$url/data/$username/$return_id_filename" };

  my $info_msg      = "$nrows_inserted records of items have been inserted successfully.";
  my $info_msg_aref = [{'Message' => $info_msg}];

  $cur_dt =~ s/T/ /; # MySQL format has T between date and time

  my $return_other_aref  = [ { 'Value' => "$cur_dt", 'ParaName' => 'LastUpdateTimeStamp' } ];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'         => $info_msg_aref,
                                           'ReturnOther'  => $return_other_aref,
                                           'ReturnIdFile' => [$output_file_href],
                                          };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub import_itemgroup_xml_runmode {

=pod import_itemgroup_xml_gadmin_HELP_START
{
"OperationName": "Import item group",
"Description": "Import item group with a definition of items belonging to the group. This definition has to be in xml format.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnIdFile xml='http://kddart-d.diversityarrays.com/data/admin/import_itemgroup_xml_gadmin_return_id_132.xml' /><Info Message='Number of ItemGroup imported: 1.' /></DATA>",
"SuccessMessageJSON": "{'ReturnIdFile' : [{'json' : 'http://kddart-d.diversityarrays.com/data/admin/import_itemgroup_xml_gadmin_return_id_253.json'}], 'Info' : [{'Message' : 'Number of ItemGroup imported: 1.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='SpecimenId (4927) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'SpecimenId (4927) not found.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "XML",
"UploadFileParameterName": "uploadfile",
"DTDFileNameForUploadXML": "itemgroup.dtd",
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $itemgroup_xml_file = $self->authen->get_upload_file();
  my $itemgroup_dtd_file = $self->get_itemgroup_dtd_file();

  $self->logger->debug("ItemGroup DTD: $itemgroup_dtd_file");

  add_dtd($itemgroup_dtd_file, $itemgroup_xml_file);

  my $itemgroup_xml = read_file($itemgroup_xml_file);

  $self->logger->debug("XML file with DTD: $itemgroup_xml");

  my $xml_checker_parser = new XML::Checker::Parser( Handlers => { } );

  eval {

    local $XML::Checker::FAIL = sub {

      my $code = shift;
      my $err_str = XML::Checker::error_string ($code, @_);
      $self->logger->debug("XML Parsing ERR: $code : $err_str");
      die $err_str;
    };
    $xml_checker_parser->parsefile($itemgroup_xml_file);
  };

  if ($@) {

    my $err_msg = $@;
    $self->logger->debug("Parsing XML error: $err_msg");
    my $user_err_msg = "Genotype xml file does not comply with its definition.\n";
    $user_err_msg   .= "Details: $err_msg";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $user_err_msg}]};

    return $data_for_postrun_href;
  }

  my $item_group_data = xml2arrayref($itemgroup_xml, 'ItemGroup');

  my $dbh_read = connect_kdb_read();

  my $specimen_href           = {};

  my $uniq_itm_grp_name_href      = {};
  my $uniq_unit_id_href           = {};
  my $uniq_tu_spec_id_href        = {};
  my $uniq_itm_src_id_href        = {};
  my $uniq_container_type_id_href = {};
  my $uniq_spec_id_href           = {};
  my $uniq_scale_id_href          = {};
  my $uniq_storage_id_href        = {};
  my $uniq_itm_type_id_href       = {};
  my $uniq_itm_state_id_href      = {};
  my $uniq_itm_barcode_href       = {};
  #to use existing items for itemgroups
  #my $item_id_list = [];
  my $uniq_item_href = {};

  my $i = 0;
  for my $item_group (@{$item_group_data}) {

    my $item_group_name = $item_group->{'ItemGroupName'};

    my ($missing_grpname_err, $missing_grpname_msg) = check_missing_value({ 'ItemGroupName' => $item_group_name });

    if ($missing_grpname_err) {

      my $err_msg = "ItemGroupName missing.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if (defined $uniq_itm_grp_name_href->{qq|'$item_group_name'|}) {

      my $err_msg = "ItemGroupName ($item_group_name): duplicate.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    else {

      $uniq_itm_grp_name_href->{qq|'$item_group_name'|} = $i;
    }

    my $item_source_id = '';

    if (defined($item_group->{'ItemSourceId'})) {

      $item_source_id = $item_group->{'ItemSourceId'};
    }

    if (length($item_source_id) > 0) {

      $uniq_itm_src_id_href->{$item_source_id} = $i;
    }

    my $container_type_id = '';

    if (defined($item_group->{'ContainerTypeId'})) {

      $container_type_id = $item_group->{'ContainerTypeId'};
    }

    if (length($container_type_id) > 0) {

      $uniq_container_type_id_href->{$container_type_id} = $i;
    }

    my $scale_id = '';

    if (defined($item_group->{'ScaleId'})) {

      $scale_id = $item_group->{'ScaleId'};
    }

    if (length($scale_id) > 0) {

      $uniq_scale_id_href->{$scale_id} = $i;
    }

    my $storage_id = '';

    if (defined($item_group->{'StorageId'})) {

      $storage_id = $item_group->{'StorageId'};
    }

    if (length($storage_id) > 0) {

      $uniq_storage_id_href->{$storage_id} = $i;
    }

    my $item_unit_id = '';

    if (defined($item_group->{'UnitId'})) {

      if (length($item_group->{'UnitId'}) > 0) {

        $item_unit_id = $item_group->{'UnitId'};
      }
    }

    if (length($item_unit_id) > 0) {

      $uniq_unit_id_href->{$item_unit_id} = $i;
    }

    my $item_state_id = '';

    if (defined($item_group->{'ItemStateId'})) {

      $item_state_id = $item_group->{'ItemStateId'};
    }

    if (length($item_state_id) > 0) {

      $uniq_itm_state_id_href->{$item_state_id} = $i;
    }

    if (defined $item_group->{'DateAdded'}) {

      if (length($item_group->{'DateAdded'})) {

        my $date_added = $item_group->{'DateAdded'};

        my ( $mdt_to_err, $mdt_to_msg ) = check_dt_value( { 'DateAdded' => $date_added } );

        if ($mdt_to_err) {

          my $err_msg = "DateAdded ($date_added) unknown date format.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
      }
    }

    if (defined $item_group->{'Active'}) {

      if (length($item_group->{'Active'}) > 0) {

        my $is_active = $item_group->{'Active'};

        if ($is_active !~ /^1|0$/) {

          my $err_msg = "Active ($is_active): must be either 0 or 1.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
      }
    }

    my $item_data = [];



    if (ref $item_group->{'Item'} eq 'HASH') {

      $item_data = [$item_group->{'Item'}];
    }
    elsif (ref $item_group->{'Item'} eq 'ARRAY') {

      $item_data = $item_group->{'Item'};
    }

    $item_group->{'Item'} = $item_data;

    my $j = 0;
    for my $item (@{$item_data}) {

      my $item_id = -1;

      if (defined $item->{'Itemid'}) {
        if (length($item->{'Itemid'}) > 0) {
          $item_id = $item->{'Itemid'};


        }
      }

      if ($item_id != -1) {

        if (!defined $uniq_item_href->{$item_id}) {
          #push(@{$item_id_list},$item_id);

          $uniq_item_href->{$item_id} = 1;
        }


      }
      else {
        my $specimen_id      = $item->{'SpecimenId'};
        my $item_barcode     = $item->{'ItemBarcode'};
        my $item_type_id     = $item->{'ItemTypeId'};

        my ($missing_spec_id_err, $missing_spec_id_msg) = check_missing_value( {'SpecimenId'  => $specimen_id,
                                                                                'ItemTypeId'  => $item_type_id,
                                                                               } );

        if ($missing_spec_id_err) {

          my $err_msg = $missing_spec_id_msg . ' missing.';

          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }

        $uniq_spec_id_href->{$specimen_id} = [$i, $j];

        if (length($item_barcode) > 0) {

          if (defined $uniq_itm_barcode_href->{qq|'$item_barcode'|}) {

            my $err_msg = "ItemBarcode ($item_barcode): duplicate";

            $data_for_postrun_href->{'Error'} = 1;
            $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

            return $data_for_postrun_href;
          }
          else {

            $uniq_itm_barcode_href->{qq|'$item_barcode'|} = [$i, $j];
          }
        }

        $uniq_itm_type_id_href->{$item_type_id} = [$i, $j];

        if (defined($item->{'ItemStateId'})) {

          $item_state_id = $item->{'ItemStateId'};
        }

        if (length($item_state_id) > 0) {

          $uniq_itm_state_id_href->{$item_state_id} = [$i, $j];
        }

        if (defined($item->{'UnitId'})) {

          if (length($item->{'UnitId'}) > 0) {

            $item_unit_id = $item->{'UnitId'};
          }
        }

        if (length($item_unit_id) > 0) {

          $uniq_unit_id_href->{$item_unit_id} = [$i, $j];
        }

        if (defined($item->{'StorageId'})) {

          $storage_id = $item->{'StorageId'};
        }

        if (length($storage_id) > 0) {

          $uniq_storage_id_href->{$storage_id} = [$i, $j];
        }

        my $tu_spec_id = '';

        if (defined($item->{'TrialUnitSpecimenId'})) {

          $tu_spec_id = $item->{'TrialUnitSpecimenId'};
        }

        if (length($tu_spec_id) > 0) {

          $uniq_tu_spec_id_href->{$tu_spec_id} = [$i, $j];
        }

        my $amount = '';

        if (defined($item->{'Amount'})) {

          $amount = $item->{'Amount'};
        }

        if (length($amount) > 0) {

          my ($ck_float_err, $ck_float_msg) = check_float_value({'Amount' => $amount});

          if ($ck_float_err) {

            my $err_msg = $ck_float_msg . ' not number.';

            $data_for_postrun_href->{'Error'} = 1;
            $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

            return $data_for_postrun_href;
          }
        }

        $j += 1;
      }

    }

    $i += 1;
  }

  my $sql;
  my $sth;

  my @uniq_item_id_list = keys(%{$uniq_item_href});

  if (scalar(@uniq_item_id_list) > 0) {

    $sql  = 'SELECT ItemId FROM item WHERE ItemId ';
    $sql .= 'IN (' . join(',', @uniq_item_id_list) . ')';

    $sth = $dbh_read->prepare($sql);
    $sth->execute();

    if ($dbh_read->err()) {

      $self->logger->debug("Read ItemGrouName failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $db_item_id_href = $sth->fetchall_hashref('ItemId');

    if ($sth->err()) {

      $self->logger->debug("Fetch ItemGrouName failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my @missing_item_id_list;

    foreach my $item_id (@uniq_item_id_list) {

      if (! defined $db_item_id_href->{qq|'$item_id'|} ) {

        push(@missing_item_id_list, $item_id);
      }
    }

    if (scalar(@missing_item_id_list) > 0) {

      my $err_msg = "ItemId (";
      $err_msg   .= join(',', @missing_item_id_list) . ') not found.';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

  }

  my @uniq_itm_grp_name_list = keys(%{$uniq_itm_grp_name_href});

  if (scalar(@uniq_itm_grp_name_list) > 0) {

    $sql  = 'SELECT ItemGroupName FROM itemgroup WHERE ItemGroupName ';
    $sql .= 'IN (' . join(',', @uniq_itm_grp_name_list) . ')';

    $sth = $dbh_read->prepare($sql);
    $sth->execute();

    if ($dbh_read->err()) {

      $self->logger->debug("Read ItemGrouName failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $db_itm_grp_name_href = $sth->fetchall_hashref('ItemGroupName');

    if ($sth->err()) {

      $self->logger->debug("Fetch ItemGrouName failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my @found_itm_grp_name_list;

    foreach my $itm_grp_name (@uniq_itm_grp_name_list) {

      if ( defined $db_itm_grp_name_href->{qq|'$itm_grp_name'|} ) {

        push(@found_itm_grp_name_list, $itm_grp_name);
      }
    }

    if (scalar(@found_itm_grp_name_list) > 0) {

      my $err_msg = "ItemGroupName (";
      $err_msg   .= join(',', @found_itm_grp_name_list) . ') already used.';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @uniq_unit_id_list = keys(%{$uniq_unit_id_href});

  if (scalar(@uniq_unit_id_list) > 0) {

    $sql = 'SELECT UnitId FROM generalunit WHERE UnitId IN (' . join(',', @uniq_unit_id_list) . ')';
    $sth = $dbh_read->prepare($sql);
    $sth->execute();

    if ($dbh_read->err()) {

      $self->logger->debug("Read UnitId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $db_unit_id_href = $sth->fetchall_hashref('UnitId');

    if ($sth->err()) {

      $self->logger->debug("Fetch UnitId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my @not_found_unit_id_list;

    foreach my $unit_id (@uniq_unit_id_list) {

      if (! (defined $db_unit_id_href->{$unit_id}) ) {

        push(@not_found_unit_id_list, $unit_id);
      }
    }

    if (scalar(@not_found_unit_id_list) > 0) {

      my $err_msg = 'UnitId (';
      $err_msg   .= join(',', @not_found_unit_id_list) . ') not found';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @uniq_tu_spec_id_list = keys(%{$uniq_tu_spec_id_href});

  if (scalar(@uniq_tu_spec_id_list) > 0) {

    $sql  = 'SELECT TrialUnitSpecimenId, SpecimenId ';
    $sql .= 'FROM trialunitspecimen WHERE TrialUnitSpecimenId IN (' . join(',', @uniq_tu_spec_id_list) . ')';

    $sth = $dbh_read->prepare($sql);
    $sth->execute();

    if ($dbh_read->err()) {

      $self->logger->debug("Read TrialUnitSpecimenId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $db_tu_spec_id_href = $sth->fetchall_hashref('TrialUnitSpecimenId');

    if ($sth->err()) {

      $self->logger->debug("Fetch TrialUnitSpecimenId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my @not_found_tu_spec_id_list;

    foreach my $tu_spec_id (@uniq_tu_spec_id_list) {

      if (! (defined $db_tu_spec_id_href->{$tu_spec_id}) ) {

        push(@not_found_tu_spec_id_list, $tu_spec_id);
      }
      else {

        if (ref $uniq_tu_spec_id_href->{$tu_spec_id} eq 'ARRAY') {

          my $db_spec_id = $db_tu_spec_id_href->{$tu_spec_id}->{'SpecimenId'};

          my $i = $uniq_tu_spec_id_href->{$tu_spec_id}->[0];
          my $j = $uniq_tu_spec_id_href->{$tu_spec_id}->[1];

          my $user_spec_id = $item_group_data->[$i]->{'Item'}->[$j]->{'SpecimenId'};

          if ($db_spec_id != $user_spec_id) {

            my $err_msg = "SpecimenId ($db_spec_id) from TrialUnitSpecimenId ($tu_spec_id) ";
            $err_msg   .= "different from SpecimenId ($user_spec_id) provided.";

            $data_for_postrun_href->{'Error'} = 1;
            $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

            return $data_for_postrun_href;
          }
        }
      }
    }

    if (scalar(@not_found_tu_spec_id_list) > 0) {

      my $err_msg = 'TrialUnitSpecimenId (';
      $err_msg   .= join(',', @not_found_tu_spec_id_list) . ') not found';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @uniq_container_type_id_list = keys(%{$uniq_container_type_id_href});

  if (scalar(@uniq_container_type_id_list) > 0) {

    $sql  = 'SELECT TypeId FROM generaltype WHERE TypeId IN (' . join(',', @uniq_container_type_id_list) . ') ';
    $sql .= " AND IsTypeActive=1 AND Class='container'";

    $sth = $dbh_read->prepare($sql);
    $sth->execute();

    if ($dbh_read->err()) {

      $self->logger->debug("Read ContainerTypeId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $db_container_type_id_href = $sth->fetchall_hashref('TypeId');

    if ($sth->err()) {

      $self->logger->debug("Fetch ContainerTypeId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my @not_found_container_type_id_list;

    foreach my $container_type_id (@uniq_container_type_id_list) {

      if (! (defined $db_container_type_id_href->{$container_type_id}) ) {

        push(@not_found_container_type_id_list, $container_type_id);
      }
    }

    if (scalar(@not_found_container_type_id_list) > 0) {

      my $err_msg = 'ContainerTypeId (';
      $err_msg   .= join(',', @not_found_container_type_id_list) . ') not found';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $user_id       = $self->authen->user_id();
  my $perm_str      = permission_phrase($group_id, 0, $gadmin_status, 'specimen');

  my @uniq_spec_id_list = keys(%{$uniq_spec_id_href});

  if (scalar(@uniq_spec_id_list) > 0) {

    $sql  = "SELECT SpecimenId, $perm_str AS UltimatePerm ";
    $sql .= 'FROM specimen WHERE SpecimenId IN (' . join(',', @uniq_spec_id_list) . ')';

    $sth = $dbh_read->prepare($sql);
    $sth->execute();

    if ($dbh_read->err()) {

      $self->logger->debug("Read SpecimenId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $db_spec_id_href = $sth->fetchall_hashref('SpecimenId');

    if ($sth->err()) {

      $self->logger->debug("Fetch SpecimenId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my @not_found_spec_id_list;

    my @perm_denied_spec_id_list;

    foreach my $spec_id (@uniq_spec_id_list) {

      my $row_num = $uniq_spec_id_href->{$spec_id};

      if (! (defined $db_spec_id_href->{$spec_id}) ) {

        push(@not_found_spec_id_list, $spec_id);
      }
      else {

        my $perm = $db_spec_id_href->{$spec_id}->{'UltimatePerm'};

        if (( $perm & $READ_PERM) != $READ_PERM ) {

          push(@perm_denied_spec_id_list, $spec_id);
        }
      }
    }

    if (scalar(@not_found_spec_id_list) > 0) {

      my $err_msg = 'SpecimenId (';
      $err_msg   .= join(',', @not_found_spec_id_list) . ') not found';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if (scalar(@perm_denied_spec_id_list) > 0) {

      my $err_msg = 'SpecimenId (';
      $err_msg   .= join(',', @perm_denied_spec_id_list) . ') permission denied.';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @uniq_scale_id_list = keys(%{$uniq_scale_id_href});

  if (scalar(@uniq_scale_id_list) > 0) {

    $sql  = 'SELECT DeviceRegisterId FROM deviceregister ';
    $sql .= 'WHERE DeviceRegisterId IN (' . join(',', @uniq_scale_id_list) . ')';

    $sth = $dbh_read->prepare($sql);
    $sth->execute();

    if ($dbh_read->err()) {

      $self->logger->debug("Read DeviceRegisterId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $db_scale_id_href = $sth->fetchall_hashref('DeviceRegisterId');

    if ($sth->err()) {

      $self->logger->debug("Fetch DeviceRegisterId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my @not_found_scale_id_list;

    foreach my $scale_id (@uniq_scale_id_list) {

      if (! (defined $db_scale_id_href->{$scale_id}) ) {

        push(@not_found_scale_id_list, $scale_id);
      }
    }

    if (scalar(@not_found_scale_id_list) > 0) {

      my $err_msg = 'ScaleId (';
      $err_msg   .= join(',', @not_found_scale_id_list) . ') not found';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @uniq_storage_id_list = keys(%{$uniq_storage_id_href});

  if (scalar(@uniq_storage_id_list) > 0) {

    $sql = 'SELECT StorageId FROM storage WHERE StorageId IN (' . join(',', @uniq_storage_id_list) . ')';

    $sth = $dbh_read->prepare($sql);
    $sth->execute();

    if ($dbh_read->err()) {

      $self->logger->debug("Read StorageId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $db_storage_id_href = $sth->fetchall_hashref('StorageId');

    if ($sth->err()) {

      $self->logger->debug("Fetch StorageId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my @not_found_storage_id_list;

    foreach my $storage_id (@uniq_storage_id_list) {

      if (! (defined $db_storage_id_href->{$storage_id}) ) {

        push(@not_found_storage_id_list, $storage_id);
      }
    }

    if (scalar(@not_found_storage_id_list) > 0) {

      my $err_msg = 'StorageId (';
      $err_msg   .= join(',', @not_found_storage_id_list) . ') not found';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @uniq_itm_type_id_list = keys(%{$uniq_itm_type_id_href});

  if (scalar(@uniq_itm_type_id_list) > 0) {

    $sql  = 'SELECT TypeId FROM generaltype WHERE TypeId IN (' . join(',', @uniq_itm_type_id_list) . ') ';
    $sql .= " AND IsTypeActive=1 AND Class='item'";

    $sth = $dbh_read->prepare($sql);
    $sth->execute();

    if ($dbh_read->err()) {

      $self->logger->debug("Read ItemTypeId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $db_itm_type_id_href = $sth->fetchall_hashref('TypeId');

    if ($sth->err()) {

      $self->logger->debug("Fetch ItemTypeId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my @not_found_itm_type_id_list;

    foreach my $itm_type_id (@uniq_itm_type_id_list) {

      if (! (defined $db_itm_type_id_href->{$itm_type_id}) ) {

        push(@not_found_itm_type_id_list, $itm_type_id);
      }
    }

    if (scalar(@not_found_itm_type_id_list) > 0) {

      my $err_msg = 'ItemTypeId (';
      $err_msg   .= join(',', @not_found_itm_type_id_list) . ') not found';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @uniq_itm_state_id_list = keys(%{$uniq_itm_state_id_href});

  if (scalar(@uniq_itm_state_id_list) > 0) {

    $sql  = 'SELECT TypeId FROM generaltype WHERE TypeId IN (' . join(',', @uniq_itm_state_id_list) . ') ';
    $sql .= " AND IsTypeActive=1 AND Class='state'";

    $sth = $dbh_read->prepare($sql);
    $sth->execute();

    if ($dbh_read->err()) {

      $self->logger->debug("Read ItemStateId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $db_itm_state_id_href = $sth->fetchall_hashref('TypeId');

    if ($sth->err()) {

      $self->logger->debug("Fetch ItemStateId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my @not_found_itm_state_id_list;

    foreach my $itm_state_id (@uniq_itm_state_id_list) {

      if (! (defined $db_itm_state_id_href->{$itm_state_id}) ) {

        push(@not_found_itm_state_id_list, $itm_state_id);
      }
    }

    if (scalar(@not_found_itm_state_id_list) > 0) {

      my $err_msg = 'ItemStateId (';
      $err_msg   .= join(',', @not_found_itm_state_id_list) . ') not found';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @uniq_itm_barcode_list = keys(%{$uniq_itm_barcode_href});

  if (scalar(@uniq_itm_barcode_list) > 0) {

    $sql = 'SELECT ItemBarcode FROM item WHERE ItemBarcode IN (' . join(',', @uniq_itm_barcode_list) . ')';

    $sth = $dbh_read->prepare($sql);
    $sth->execute();

    if ($dbh_read->err()) {

      $self->logger->debug("Read ItemBarcode failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $db_itm_barcode_href = $sth->fetchall_hashref('ItemBarcode');

    if ($sth->err()) {

      $self->logger->debug("Fetch ItemBarcode failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my @found_itm_barcode_list;

    foreach my $itm_barcode (@uniq_itm_barcode_list) {

      if ( defined $db_itm_barcode_href->{qq|'$itm_barcode'|} ) {

        push(@found_itm_barcode_list, $itm_barcode);
      }
    }

    if (scalar(@found_itm_barcode_list) > 0) {

      my $err_msg = 'ItemBarcode (';
      $err_msg   .= join(',', @found_itm_barcode_list) . ') already used.';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @uniq_itm_src_id_list = keys(%{$uniq_itm_src_id_href});

  if (scalar(@uniq_itm_src_id_list) > 0) {

    $sql = 'SELECT ContactId FROM contact WHERE ContactId IN (' . join(',', @uniq_itm_src_id_list) . ')';

    $sth = $dbh_read->prepare($sql);
    $sth->execute();

    if ($dbh_read->err()) {

      $self->logger->debug("Read ItemSourceId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $db_itm_src_id_href = $sth->fetchall_hashref('ContactId');

    if ($sth->err()) {

      $self->logger->debug("Fetch ItemSourceId failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my @not_found_itm_src_id_list;

    foreach my $itm_src_id (@uniq_itm_src_id_list) {

      if (! (defined $db_itm_src_id_href->{$itm_src_id}) ) {

        push(@not_found_itm_src_id_list, $itm_src_id);
      }
    }

    if (scalar(@not_found_itm_src_id_list) > 0) {

      my $err_msg = 'ItemSourceId (';
      $err_msg   .= join(',', @not_found_itm_src_id_list) . ') not found';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  $dbh_read->disconnect();

  my $dbh_write = connect_kdb_write();

  my $cur_dt = DateTime->now( time_zone => $TIMEZONE );
  $cur_dt    = DateTime::Format::MySQL->format_datetime($cur_dt);

  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

  $year = sprintf("%02d", $year % 100);
  $yday = sprintf("%03d", $yday);

  my $barcode_user_id  = sprintf("%02d", $user_id);

  my @big_a_z_chars = ("A" .. "Z");

  my $rand3 = $big_a_z_chars[rand(26)] . $big_a_z_chars[rand(26)] . int(rand(10));

  my $dal_tmp_itm_barcode_prefix = qq|ITM_${barcode_user_id}_${year}${yday}${hour}${min}${sec}_${rand3}_|;

  my $sql_bulk;

  $sql_bulk  = 'INSERT INTO item(UnitId,TrialUnitSpecimenId,ItemSourceId,ContainerTypeId,SpecimenId,ScaleId,StorageId,';
  $sql_bulk .= 'ItemTypeId,ItemStateId,ItemBarcode,Amount,DateAdded,AddedByUserId,ItemNote,LastUpdateTimeStamp) VALUES';

  my @item_sql_rec_list;

  my $num_new_items = 0;

  for (my $j = 0; $j < scalar(@{$item_group_data}); $j++) {

    my $item_group = $item_group_data->[$j];

    my $item_data = [];

    if (ref $item_group->{'Item'} eq 'HASH') {

      $item_data = [$item_group->{'Item'}];
    }
    elsif (ref $item_group->{'Item'} eq 'ARRAY') {

      $item_data = $item_group->{'Item'};
    }

    for (my $i = 0; $i < scalar(@{$item_data}); $i++) {

      my $item = $item_data->[$i];

      if (! defined $item->{'ItemId'}) {
        my $specimen_id        = $item->{'SpecimenId'};
        my $item_type_id       = $item->{'ItemTypeId'};

        my $item_source_id     = 'NULL';

        if (length($item_group->{'ItemSourceId'}) > 0) {

          $item_source_id     = $item_group->{'ItemSourceId'};
        }

        my $container_type_id  = 'NULL';

        if (length($item_group->{'ContainerTypeId'}) > 0) {

          $container_type_id  = $item_group->{'ContainerTypeId'};
        }

        my $scale_id           = 'NULL';

        if (length($item_group->{'ScaleId'}) > 0) {

          $scale_id           = $item_group->{'ScaleId'};
        }

        my $storage_id         = 'NULL';

        if (length($item_group->{'StorageId'}) > 0) {

          $storage_id         = $item_group->{'StorageId'};
        }

        if (length($item->{'StorageId'}) > 0) {

          $storage_id = $item->{'StorageId'};
        }

        my $item_unit_id       = 'NULL';

        if (length($item_group->{'UnitId'}) > 0) {

          $item_unit_id       = $item_group->{'UnitId'};
        }

        if (length($item->{'UnitId'}) > 0) {

          $item_unit_id = $item->{'UnitId'};
        }

        my $item_state_id      = 'NULL';

        if (length($item_group->{'ItemStateId'}) > 0) {

          $item_state_id      = $item_group->{'ItemStateId'};
        }

        if (length($item->{'ItemStateId'}) > 0) {

          $item_state_id = $item->{'ItemStateId'};
        }

        my $tu_spec_id          = 'NULL';

        if (length($item_group->{'TrialUnitSpecimenId'}) > 0) {

          $tu_spec_id = $item_group->{'TrialUnitSpecimenId'};
        }

        if (length($item->{'TrialUnitSpecimenId'}) > 0) {

          $tu_spec_id = $item->{'TrialUnitSpecimenId'};
        }

        my $item_barcode       = $dal_tmp_itm_barcode_prefix . "${j}_${i}";

        if (length($item->{'ItemBarcode'}) > 0) {

          $item_barcode = $item->{'ItemBarcode'};
          $item->{'RemoveBarcode'} = 0;
        }
        else {

          $item->{'RemoveBarcode'} = 1;
          $item->{'ItemBarcode'}   = $item_barcode;
        }

        $item_barcode = $dbh_write->quote($item_barcode);

        my $amount             = 'NULL';

        if (length($item->{'Amount'}) > 0) {

          $amount             = $item->{'Amount'};
        }

        my $date_added         = $dbh_write->quote($cur_dt);
        my $added_by_user_id   = $user_id;
        my $item_note          = 'NULL';

        if (length($item->{'ItemNote'}) > 0) {

          $item_note          = $dbh_write->quote($item->{'ItemNote'});
        }

        my $item_sql_rec_str = qq|(${item_unit_id},${tu_spec_id},${item_source_id},|;
        $item_sql_rec_str   .= qq|${container_type_id},${specimen_id},${scale_id},${storage_id},|;
        $item_sql_rec_str   .= qq|${item_type_id},${item_state_id},${item_barcode},|;
        $item_sql_rec_str   .= qq|${amount},${date_added},${added_by_user_id},${item_note},${date_added})|;

        $self->logger->debug("SQL REC: $item_sql_rec_str");

        $num_new_items++;

        push(@item_sql_rec_list, $item_sql_rec_str);


      }

      $item_data->[$i] = $item;
    }

    $item_group->{'Item'}  = $item_data;
    $item_group_data->[$j] = $item_group;
  }

  $sql_bulk .= join(',', @item_sql_rec_list);

  $sql = 'SELECT ItemId FROM item ORDER BY ItemId DESC LIMIT 1';

  my $r_itm_err;
  my $itm_id_before;
  my $itm_id_after;

  ($r_itm_err, $itm_id_before) = read_cell($dbh_write, $sql, []);

  if ($r_itm_err) {

    $self->logger->debug("Read ItemId before bulk INSERT failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    reitmrn $data_for_postrun_href;
  }

  my $before_clause = '1=1';

  if (length($itm_id_before) > 0) {

    $before_clause = " ItemId >= $itm_id_before ";
  }

  if (scalar(@item_sql_rec_list) > 0) {

    $self->logger->debug("BULK SQL: $sql_bulk");

    $sth = $dbh_write->prepare($sql_bulk);
    $sth->execute();

    if ($dbh_write->err()) {

      $self->logger->debug("Add item in bulk failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    $sth->finish();
  }

  $sql = 'SELECT ItemId FROM item ORDER BY ItemId DESC LIMIT 1';

  ($r_itm_err, $itm_id_after) = read_cell($dbh_write, $sql, []);

  if ($r_itm_err) {

    $self->logger->debug("Read ItemId after bulk INSERT failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $after_clause = '1=1';

  if (length($itm_id_after) > 0) {

    $after_clause = " ItemId <= $itm_id_after ";
  }

  $sql  = 'SELECT ItemId, ItemBarcode FROM item ';
  $sql .= "WHERE $before_clause AND $after_clause";

  $self->logger->debug("SQL: $sql");

  $sth = $dbh_write->prepare($sql);
  $sth->execute();

  if ($dbh_write->err()) {

    $self->logger->debug("Read Item in between before and after BULK insert");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $barcode2id_href = $sth->fetchall_hashref('ItemBarcode');

  if ($sth->err()) {

    $self->logger->debug("Read Item rec into hash lookup in between before and after BULK insert");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  for (my $j = 0; $j < scalar(@{$item_group_data}); $j++) {

    my $item_group = $item_group_data->[$j];

    my $item_data = $item_group->{'Item'};

    for (my $i = 0; $i < scalar(@{$item_data}); $i++) {

      my $item = $item_data->[$i];

      my $item_barcode = $item->{'ItemBarcode'};

      if (! $item->{'ItemId'}) {
        if (!(defined $barcode2id_href->{$item_barcode})) {

          $self->logger->debug("Barcode ($item_barcode) to id not found");
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

          return $data_for_postrun_href;
        }

        my $item_id = $barcode2id_href->{$item_barcode}->{'ItemId'};
        $item->{'ItemId'} = $item_id;
      }

      $item_data->[$i] = $item;
    }

    $item_group->{'Item'}  = $item_data;
    $item_group_data->[$j] = $item_group;
  }

  $sql_bulk = 'INSERT INTO itemgroup(ItemGroupName,ItemGroupNote,AddedByUser,DateAdded,Active) VALUES';

  my @itm_grp_sql_rec_list;

  for (my $j = 0; $j < scalar(@{$item_group_data}); $j++) {

    my $item_group = $item_group_data->[$j];

    my $item_data = $item_group->{'Item'};

    for (my $i = 0; $i < scalar(@{$item_data}); $i++) {

      my $item = $item_data->[$i];

      my $item_group_name       = $dbh_write->quote($item_group->{'ItemGroupName'});
      my $item_group_note       = 'NULL';

      if (length($item_group->{'ItemGroupNote'}) > 0) {

        $item_group_note       = $dbh_write->quote($item_group->{'ItemGroupNote'});
      }

      my $added_by_user         = $user_id;
      my $date_added            = $dbh_write->quote($cur_dt);

      if (length($item_group->{'DateAdded'}) > 0) {

        $date_added = $item_group->{'DateAdded'};
      }

      my $active = 1;

      if (length($item_group->{'Active'}) > 0) {

        $active = $item_group->{'Active'};
      }

      my $itm_grp_sql_rec_str = qq|(${item_group_name},${item_group_note},${added_by_user},${date_added},${active})|;
      push(@itm_grp_sql_rec_list, $itm_grp_sql_rec_str);
    }
  }

  $sql_bulk .= join(',', @itm_grp_sql_rec_list);

  $sql = 'SELECT ItemGroupId FROM itemgroup ORDER BY ItemGroupId DESC LIMIT 1';

  my $r_itm_grp_err;
  my $itm_grp_id_before;
  my $itm_grp_id_after;

  ($r_itm_grp_err, $itm_grp_id_before) = read_cell($dbh_write, $sql, []);

  if ($r_itm_grp_err) {

    $self->logger->debug("Read ItemGroupId before bulk INSERT failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    reitmrn $data_for_postrun_href;
  }

  $before_clause = '1=1';

  if (length($itm_grp_id_before) > 0) {

    $before_clause = " ItemGroupId >= $itm_grp_id_before ";
  }

  if (scalar(@itm_grp_sql_rec_list) > 0) {

    $self->logger->debug("BULK SQL: $sql_bulk");

    $sth = $dbh_write->prepare($sql_bulk);
    $sth->execute();

    if ($dbh_write->err()) {

      $self->logger->debug("Add item group in bulk failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    $sth->finish();
  }

  $sql = 'SELECT ItemGroupId FROM itemgroup ORDER BY ItemGroupId DESC LIMIT 1';

  ($r_itm_grp_err, $itm_grp_id_after) = read_cell($dbh_write, $sql, []);

  if ($r_itm_grp_err) {

    $self->logger->debug("Read ItemGroupId after bulk INSERT failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $after_clause = '1=1';

  if (length($itm_grp_id_after) > 0) {

    $after_clause = " ItemGroupId <= $itm_grp_id_after ";
  }

  $sql  = 'SELECT ItemGroupId, ItemGroupName FROM itemgroup ';
  $sql .= "WHERE $before_clause AND $after_clause";

  $self->logger->debug("SQL: $sql");

  $sth = $dbh_write->prepare($sql);
  $sth->execute();

  if ($dbh_write->err()) {

    $self->logger->debug("Read Item in between before and after BULK insert");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $itm_grp_name2id_href = $sth->fetchall_hashref('ItemGroupName');

  if ($sth->err()) {

    $self->logger->debug("Read ItemGroup rec into hash lookup in between before and after BULK insert");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  for (my $j = 0; $j < scalar(@{$item_group_data}); $j++) {

    my $item_group      = $item_group_data->[$j];
    my $item_group_name = $item_group->{'ItemGroupName'};

    if (!(defined $itm_grp_name2id_href->{$item_group_name})) {

      $self->logger->debug("ItemGroupName ($item_group_name) to id not found");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $item_group_id = $itm_grp_name2id_href->{$item_group_name}->{'ItemGroupId'};
    $item_group->{'ItemGroupId'} = $item_group_id;

    $item_group_data->[$j] = $item_group;
  }

  $sql_bulk = 'INSERT INTO itemgroupentry(ItemGroupId,ItemId) VALUES';

  my @itm_grp_entry_sql_rec_list;

  for (my $j = 0; $j < scalar(@{$item_group_data}); $j++) {

    my $item_group = $item_group_data->[$j];

    my $item_data = $item_group->{'Item'};

    for (my $i = 0; $i < scalar(@{$item_data}); $i++) {

      my $item = $item_data->[$i];

      my $item_group_id = $item_group->{'ItemGroupId'};
      my $item_id       = $item->{'ItemId'};

      my $itm_grp_entry_sql_rec_str = qq|(${item_group_id},${item_id})|;
      push(@itm_grp_entry_sql_rec_list, $itm_grp_entry_sql_rec_str);
    }
  }

  $sql_bulk .= join(',', @itm_grp_entry_sql_rec_list);

  if (scalar(@itm_grp_entry_sql_rec_list) > 0) {

    $self->logger->debug("BULK SQL: $sql_bulk");

    $sth = $dbh_write->prepare($sql_bulk);
    $sth->execute();

    if ($dbh_write->err()) {

      $self->logger->debug("Add item group entry in bulk failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    $sth->finish();
  }

  my $return_data          = [];

  my @remove_item_barcode_id_list;

  for (my $j = 0; $j < scalar(@{$item_group_data}); $j++) {

    my $item_group       = $item_group_data->[$j];
    my $item_group_id    = $item_group->{'ItemGroupId'};
    my $item_group_name  = $item_group->{'ItemGroupName'};

    my $item_data = $item_group->{'Item'};

    my $return_item_data = [];

    for (my $i = 0; $i < scalar(@{$item_data}); $i++) {

      my $item = $item_data->[$i];

      my $item_id         = $item->{'ItemId'};
      my $return_item_rec = {'ItemId' => $item_id};

      if ($item->{'RemoveBarcode'} == 1) {

        push(@remove_item_barcode_id_list, $item_id);
      }
      else {

        my $item_barcode = $item->{'ItemBarcode'};
        $return_item_rec->{'ItemBarcode'} = $item_barcode;
      }

      push(@{$return_item_data}, $return_item_rec);
    }

    my $return_item_group_rec = {'ItemGroupId' => $item_group_id, 'ItemGroupName' => $item_group_name};
    $return_item_group_rec->{'Item'} = $return_item_data;

    push(@{$return_data}, $return_item_group_rec);
  }

  if (scalar(@remove_item_barcode_id_list) > 0) {

    $sql = 'UPDATE item SET ItemBarcode=NULL WHERE ItemId IN (' . join(',', @remove_item_barcode_id_list) . ')';

    $sth = $dbh_write->prepare($sql);
    $sth->execute();

    if ($dbh_write->err()) {

      $self->logger->debug("SQL: $sql");
      $self->logger->debug("Remove item barcode failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }
  }

  $dbh_write->disconnect();

  my $return_id_data   = {};
  $return_id_data->{'ReturnId'}     = $return_data;
  $return_id_data->{'PrimaryKey'}   = [{'FieldName' => 'ItemGroupId'}];
  $return_id_data->{'AlternateKey'} = [{'FieldName' => 'ItemGroupName'}];

  my $content_type = '';

  if ($self->authen->is_content_type_valid()) {

    $content_type = $self->authen->get_content_type();
  }

  if (length($content_type) == 0) {

    $content_type = 'xml';
  }
  else {

    $content_type = lc($content_type);
  }

  my $file_rand            = makerandom(Size => 8, Strength => 0);
  my $username             = $self->authen->username();
  my $doc_root             = $ENV{'DOCUMENT_ROOT'};
  my $export_data_path     = "${doc_root}/data/$username";
  my $return_id_filename   = $self->get_current_runmode() . "_return_id_${file_rand}.${content_type}";
  my $return_id_file       = "${export_data_path}/$return_id_filename";

  if ( !(-e $export_data_path) ) {

    mkdir($export_data_path);
  }

  my $return_id_content = '';

  $self->logger->debug("Content type: $content_type");

  if ($content_type eq 'xml') {

    $return_id_content = make_empty_xml();
    for my $xml_tag (keys(%{$return_id_data})) {

      my $this_xml_content = recurse_arrayref2xml($return_id_data->{$xml_tag}, $xml_tag);
      $return_id_content = merge_xml($this_xml_content, $return_id_content);
    }
  }
  elsif ($content_type eq 'json') {

    my $json_encoder = JSON::XS->new();
    $json_encoder->pretty(1);
    $json_encoder->utf8(1);
    $return_id_content = $json_encoder->encode($return_id_data);
  }

  #$self->logger->debug("Return ID content: $return_id_content");

  my $return_id_fh;
  open($return_id_fh, ">:encoding(utf8)", "$return_id_file") or die "$return_id_file: $!";
  print $return_id_fh $return_id_content;
  close($return_id_fh);

  my $url = reconstruct_server_url();
  my $output_file_href = { "$content_type"  => "$url/data/$username/$return_id_filename" };

  my $nb_item_group = scalar(@{$item_group_data});

  my $info_msg = "Number of ItemGroup imported: $nb_item_group.";
  my $info_msg_aref = [{'Message' => $info_msg}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref, 'ReturnIdFile' => [$output_file_href]};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}


sub add_item_log_runmode {

=pod add_item_log_HELP_START
{
"OperationName": "Record item log",
"Description": "Add log record for an inventory item specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "itemlog",
"SkippedField": ["ItemId", "SystemUserId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='1' ParaName='ItemLogId' /><Info Message='Log (1) has been added for item (1).' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '2', 'ParaName' : 'ItemLogId'}], 'Info' : [{'Message' : 'Log (2) has been added for item (1).'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error LogTypeId='LogTypeId (183): not found or inactive.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'LogTypeId' : 'LogTypeId (183): not found or inactive.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing ItemId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self   = $_[0];
  my $query  = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'ItemId'       => 1,
                    'SystemUserId' => 1,
  };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'itemlog', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $item_id        = $self->param('id');
  my $log_type_id    = $query->param('LogTypeId');
  my $log_dt         = $query->param('LogDateTime');
  my $system_user_id = $self->authen->user_id();
  my $log_message    = $query->param('LogMessage');

  my $dbh_k_read = connect_kdb_read();

  if (!type_existence($dbh_k_read, 'itemlog', $log_type_id)) {

    my $err_msg = "LogTypeId ($log_type_id): not found or inactive.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'LogTypeId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (!record_existence($dbh_k_read, 'item', 'ItemId', $item_id)) {

    my $err_msg = "ItemId ($item_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'ItemId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($log_dt_err, $log_dt_href ) = check_dt_href( { 'LogDateTime' => $log_dt } );

  if ($log_dt_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$log_dt_href]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $sql = "INSERT INTO itemlog SET ";
  $sql   .= "LogTypeId=?, ";
  $sql   .= "SystemUserId=?, ";
  $sql   .= "ItemId=?, ";
  $sql   .= "LogDateTime=?, ";
  $sql   .= "LogMessage=?";

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($log_type_id, $system_user_id, $item_id, $log_dt, $log_message);

  my $item_log_id = -1;
  if ( $dbh_k_write->err() ) {

    $self->logger->debug("INSERT INTO itemlog failed");
    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $item_log_id = $dbh_k_write->last_insert_id( undef, undef, 'itemlog', 'ItemLogId' );

  $sth->finish();
  $dbh_k_write->disconnect();

  my $info_msg_aref  = [ { 'Message' => "Log ($item_log_id) has been added for item ($item_id)." } ];
  my $return_id_aref = [ { 'Value' => $item_log_id, 'ParaName' => 'ItemLogId' } ];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_item_log {

  my $self           = $_[0];
  my $sql            = $_[1];

  my $where_para_aref = [];

  if (defined $_[2]) {

    $where_para_aref = $_[2];
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
  # parameters provided by the caller
  # for example, ('WHERE FieldA=?', '1')
  $sth->execute(@{$where_para_aref});

  my $err = 0;
  my $msg = '';
  my $item_log_data = [];

  if ( !$dbh->err() ) {

    my $array_ref = $sth->fetchall_arrayref({});

    if ( !$sth->err() ) {

      $item_log_data = $array_ref;
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

  my $extra_attr_item_log_data = $item_log_data;

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_item_log_data);
}

sub show_item_log_runmode {

=pod show_item_log_HELP_START
{
"OperationName": "Show item log",
"Description": "List log records for an inventory item specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='ItemLog' /><ItemLog SystemUserId='0' LogTypeName='ItemLog - 5140617' LogMessage='Create item' ItemId='1' LogTypeId='182' UserName='admin' ItemLogId='2' LogDateTime='2013-12-10 15:58:08' /><ItemLog SystemUserId='0' LogTypeName='ItemLog - 5140617' LogMessage=Extract DNA from item'' ItemId='1' LogTypeId='182' UserName='admin' LogDateTime='2013-12-10 15:58:08' ItemLogId='1' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'ItemLog'}],'ItemLog' : [{'SystemUserId' : '0','LogMessage' : 'Create item','LogTypeName' : 'ItemLog - 5140617','LogTypeId' : '182','ItemId' : '1','UserName' : 'admin','LogDateTime' : '2013-12-10 15:58:08','ItemLogId' : '2'},{'SystemUserId' : '0','LogMessage' : 'Extract DNA from item','LogTypeName' : 'ItemLog - 5140617','LogTypeId' : '182','ItemId' : '1','UserName' : 'admin','LogDateTime' : '2013-12-10 15:58:08','ItemLogId' : '1'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='ItemId (77) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'ItemId (77) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing ItemId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self    = shift;
  my $item_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  if (!record_existence($dbh, 'item', 'ItemId', $item_id)) {

    my $err_msg = "ItemId ($item_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  my $sql = 'SELECT itemlog.*, systemuser.UserName, generaltype.TypeName AS LogTypeName ';
  $sql   .= 'FROM itemlog LEFT JOIN systemuser ON itemlog.SystemUserId = systemuser.UserId ';
  $sql   .= 'LEFT JOIN generaltype ON itemlog.LogTypeId = generaltype.TypeId ';
  $sql   .= 'WHERE ItemId = ? ';
  $sql   .= 'ORDER BY ItemLogId DESC';

  my ($read_itemlog_err, $read_itemlog_msg, $itemlog_data) = $self->list_item_log($sql, [$item_id]);

  if ($read_itemlog_err) {

    $self->logger->debug($read_itemlog_msg);
    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'} = 0;
  $data_for_postrun_href->{'Data'}  = {'ItemLog'      => $itemlog_data,
                                       'RecordMeta'   => [{'TagName' => 'ItemLog'}],
  };

  return $data_for_postrun_href;
}

sub add_conversionrule_runmode {

=pod add_conversionrule_gadmin_HELP_START
{
"OperationName": "Add conversionrule",
"Description": "Add conversionrule from one general unit to another unit",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "conversionrule",
"SkippedField": ["FromUnitId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='1' ParaName='ConversionRuleId' /><Info Message='ConversionRule (1) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '7', 'ParaName' : 'ConversionRuleId'}], 'Info' : [{'Message' : 'ConversionRule (7) has been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error ToUnitId='To Unit (72): not found' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'ToUnitId' : 'To Unit (72): not found'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "UnitId from which the conversionrule applies."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self          = shift;
  my $query         = $self->query();

  my $unit_id_from  = $self->param('id');

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'FromUnitId' => 1};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'conversionrule', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $unit_id_to  = $query->param('ToUnitId');
  my $formula     = $query->param('ConversionFormula');

  my $dbh_write = connect_kdb_write();

  if (!record_existence($dbh_write, 'generalunit', 'UnitId', $unit_id_from)) {

    my $err_msg = "From Unit ($unit_id_from): not found";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (!record_existence($dbh_write, 'generalunit', 'UnitId', $unit_id_to)) {

    my $err_msg = "To Unit ($unit_id_to): not found";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'ToUnitId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT ConversionRuleId FROM conversionrule WHERE FromUnitId=? AND ToUnitId=?';

  my ($r_crule_err, $db_crule_id) = read_cell($dbh_write, $sql, [$unit_id_from, $unit_id_to]);

  if ($r_crule_err) {

    $self->logger->debug("Check if conversion rule already exists");
    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_crule_id) > 0) {

    my $err_msg = "Conversionrule from Unit ($unit_id_from) to Unit ($unit_id_to): already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql    = 'INSERT INTO conversionrule SET ';
  $sql   .= 'FromUnitId=?, ';
  $sql   .= 'ToUnitId=?, ';
  $sql   .= 'ConversionFormula=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($unit_id_from, $unit_id_to, $formula);

  my $conversion_rule_id = -1;

  if (!$dbh_write->err()) {

    $conversion_rule_id = $dbh_write->last_insert_id(undef, undef, 'conversionrule', 'ConversionRuleId');
  }
  else {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref  = [{'Message' => "ConversionRule ($conversion_rule_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$conversion_rule_id", 'ParaName' => 'ConversionRuleId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref,
                                           'ReturnId'  => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub del_conversionrule_runmode {

=pod del_conversionrule_gadmin_HELP_START
{
"OperationName": "Delete conversionrule",
"Description": "Delete conversionrule",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='ConversionRule (8) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'ConversionRule (9) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='ConversionRule (11) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'ConversionRule (11) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing conversionrule id."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self              = shift;
  my $conversionrule_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_k_read = connect_kdb_read();

  my $conversionrule_exist = record_existence($dbh_k_read, 'conversionrule', 'ConversionRuleId', $conversionrule_id);

  if (!$conversionrule_exist) {

    my $err_msg = "ConversionRule ($conversionrule_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $sql = 'DELETE FROM conversionrule WHERE ConversionRuleId=?';
  my $sth = $dbh_k_write->prepare($sql);

  $sth->execute($conversionrule_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref = [{'Message' => "ConversionRule ($conversionrule_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_conversionrule_runmode {

=pod update_conversionrule_gadmin_HELP_START
{
"OperationName": "Update conversionrule",
"Description": "Update conversionrule",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "conversionrule",
"SkippedField": ["FromUnitId", "ToUnitId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='ConversionRule (11) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'ConversionRule (11) has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='ConversionRule (72): not found' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'ConversionRule (72): not found'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing conversionrule id."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self          = shift;
  my $query         = $self->query();

  my $conversionrule_id  = $self->param('id');

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'FromUnitId' => 1,
                    'ToUnitId'   => 1,
                   };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'conversionrule', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $formula     = $query->param('ConversionFormula');

  my $dbh_write = connect_kdb_write();

  if (!record_existence($dbh_write, 'conversionrule', 'ConversionRuleId', $conversionrule_id)) {

    my $err_msg = "ConversionRule ($conversionrule_id): not found";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'UPDATE conversionrule SET ';
  $sql   .= 'ConversionFormula=? ';
  $sql   .= 'WHERE ConversionRuleId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($formula, $conversionrule_id);


  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref  = [{'Message' => "ConversionRule ($conversionrule_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_conversionrule {

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
  my $conversionrule_data = [];

  if ( !$dbh->err() ) {

    my $array_ref = $sth->fetchall_arrayref({});

    if ( !$sth->err() ) {

      $conversionrule_data = $array_ref;
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

  my $extra_attr_conversionrule_data = [];

  if ($extra_attr_yes) {

    my $gadmin_status = $self->authen->gadmin_status();

    for my $row (@{$conversionrule_data}) {

      if ($gadmin_status eq '1') {

        my $conversionrule_id = $row->{'ConversionRuleId'};
        $row->{'update'} = "update/conversionrule/$conversionrule_id";
        $row->{'delete'} = "delete/conversionrule/$conversionrule_id";
      }
      push(@{$extra_attr_conversionrule_data}, $row);
    }
  }
  else {

    $extra_attr_conversionrule_data = $conversionrule_data;
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_conversionrule_data);
}

sub list_conversionrule_runmode {

=pod list_conversionrule_HELP_START
{
"OperationName": "List conversionrule",
"Description": "Return list of conversionrules for a unit specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='ConversionRule' /><ConversionRule ConversionFormula='1' FromUnitName='U_1498338' ToUnitName='U_1498338' ConversionRuleId='1' FromUnitId='31' delete='delete/conversionrule/1' update='update/conversionrule/1' ToUnitId='31' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'ConversionRule'}], 'ConversionRule' : [{'ConversionFormula' : '1', 'FromUnitName' : 'U_1498338', 'FromUnitId' : '31', 'delete' : 'delete/conversionrule/1', 'update' : 'update/conversionrule/1', 'ToUnitName' : 'U_1498338', 'ToUnitId' : '31', 'ConversionRuleId' : '1'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"HTTPParameter": [{"Required": 0, "Name": "FromUnitId", "Description": "Filtering parameter for the UnitId from which the conversion rules apply."}, {"Required": 0, "Name": "ToUnitId", "Description": "Filtering parameter for the UnitId to which the conversion rules apply."}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self     = shift;
  my $query    = $self->query();

  my $from_unit_id  = undef;
  my $to_unit_id    = undef;

  my @where_clause_list;
  my $where_arg = [];

  if (defined $query->param('FromUnitId')) {

    if (length($query->param('FromUnitId')) > 0) {

      $from_unit_id = $query->param('FromUnitId');

      push(@{$where_arg}, $from_unit_id);
      push(@where_clause_list, 'FromUnitId=?');
    }
  }

  if (defined $query->param('ToUnitId')) {

    if (length($query->param('ToUnitId')) > 0) {

      $to_unit_id = $query->param('ToUnitId');

      push(@{$where_arg}, $to_unit_id);
      push(@where_clause_list, 'ToUnitId=?');
    }
  }

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  if (defined $from_unit_id) {

    if (!record_existence($dbh, 'generalunit', 'UnitId', $from_unit_id)) {

      my $err_msg = "Unit ($from_unit_id): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'FromUnitId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (defined $to_unit_id) {

    if (!record_existence($dbh, 'generalunit', 'UnitId', $to_unit_id)) {

      my $err_msg = "Unit ($to_unit_id): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'ToUnitId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  $dbh->disconnect();

  my $sql = 'SELECT conversionrule.*, fromunit.UnitName AS FromUnitName, tounit.UnitName AS ToUnitName ';
  $sql   .= 'FROM conversionrule ';
  $sql   .= 'LEFT JOIN generalunit AS fromunit ON conversionrule.FromUnitId = fromunit.UnitId ';
  $sql   .= 'LEFT JOIN generalunit AS tounit ON conversionrule.ToUnitId = tounit.UnitId ';

  if (scalar(@where_clause_list) > 0) {

    $sql .= 'WHERE ' . join(' AND ', @where_clause_list);
  }

  $self->logger->debug("SQL: $sql");

  my ($conversionrule_err, $conversionrule_msg, $conversionrule_data) = $self->list_conversionrule(1, $sql, $where_arg);

  if ($conversionrule_err) {

    my $err_msg = 'Unexpected error';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'ConversionRule'      => $conversionrule_data,
                                           'RecordMeta'          => [{'TagName' => 'ConversionRule'}],
  };

  return $data_for_postrun_href;
}

sub get_conversionrule_runmode {

=pod get_conversionrule_HELP_START
{
"OperationName": "Get conversionrule",
"Description": "Return conversionrule details for specified conversionrule id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='ConversionRule' /><ConversionRule ConversionFormula='2' FromUnitName='U_3621603' ToUnitName='U_3621603' ConversionRuleId='11' FromUnitId='41' delete='delete/conversionrule/11' update='update/conversionrule/11' ToUnitId='41' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'ConversionRule'}], 'ConversionRule' : [{'ConversionFormula' : '2', 'FromUnitName' : 'U_3621603', 'FromUnitId' : '41', 'delete' : 'delete/conversionrule/11', 'update' : 'update/conversionrule/11', 'ToUnitName' : 'U_3621603', 'ToUnitId' : '41', 'ConversionRuleId' : '11'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing conversionrule id."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self         = shift;
  my $conv_rule_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  if (!record_existence($dbh, 'conversionrule', 'ConversionRuleId', $conv_rule_id)) {

    my $err_msg = "ConversionRule ($conv_rule_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }


  $dbh->disconnect();

  my $sql = 'SELECT conversionrule.*, fromunit.UnitName AS FromUnitName, tounit.UnitName AS ToUnitName ';
  $sql   .= 'FROM conversionrule ';
  $sql   .= 'LEFT JOIN generalunit AS fromunit ON conversionrule.FromUnitId = fromunit.UnitId ';
  $sql   .= 'LEFT JOIN generalunit AS tounit ON conversionrule.ToUnitId = tounit.UnitId ';
  $sql   .= 'WHERE ConversionRuleId=?';


  $self->logger->debug("SQL: $sql");

  my ($conversionrule_err, $conversionrule_msg, $conversionrule_data) = $self->list_conversionrule(1, $sql, [$conv_rule_id]);

  if ($conversionrule_err) {

    my $err_msg = 'Unexpected error';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'ConversionRule'      => $conversionrule_data,
                                           'RecordMeta'          => [{'TagName' => 'ConversionRule'}],
  };

  return $data_for_postrun_href;
}

sub update_item_bulk_runmode {

=pod update_item_bulk_gadmin_HELP_START
{
"OperationName": "Update item records in bulk",
"Description": "Update more than one item record in bulk from a JSON blob data",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Success Message='' Failed='0' Successful='1' ItemId='10' /><StatInfo ServerElapsedTime='0.047' Unit='second' /><Info Message='Number of items updated successfully: 1 - number of items not updated: 1.' /><Failure Successful='0' ItemId='2' Failed='1' Message='LastUpdateTimeStamp: not matched' /></DATA>",
"SuccessMessageJSON": "{'StatInfo' : [{'ServerElapsedTime' : '0.040','Unit' : 'second'}],'Success' : [{'ItemId' : '10','Successful' : 1,'Failed' : 0,'Message' : ''}],'Info' : [{'Message' : 'Number of items updated successfully: 1 - number of items not updated: 1.'}],'Failure' : [{'Successful' : 0,'Failed' : 1,'Message' : 'LastUpdateTimeStamp: not matched','ItemId' : '2'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='ItemId (11): not found' /><StatInfo ServerElapsedTime='0.012' Unit='second' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.012'}],'Error' : [{'Message' : 'ItemId (11): not found'}]}"}],
"HTTPParameter": [{"Required": 1, "Name": "data", "Description": "JSON string or blob in a structure as the following: {'DATA':[{'SpecimenId':20,'ItemId':10,'ItemTypeId':162,'LastUpdateTimeStamp':'2017-04-28 14:36:33','Amount':100,'ItemNote':'Testing update item bulk','ItemOperation':'subsample'},{'SpecimenId':20,'ItemId':11,'ItemTypeId':162,'LastUpdateTimeStamp':'2017-04-28 14:36:33','Amount':100,'ItemOperation':'subsample','ItemNote':'Testing update item bulk'}]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self        = shift;
  my $query       = $self->query();

  my $data_for_postrun_href = {};

  my $json_data_str = $query->param('data');

  $self->logger->debug("Data: $json_data_str");

  my ($missing_err, $missing_href) = check_missing_href( {'data' => $json_data_str } );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("JSON STR: $json_data_str");

  my $data_obj;

  eval {

    $data_obj = decode_json($json_data_str);
  };

  if ($@) {

    $self->logger->debug($@);
    my $err_msg = "Invalid json string.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'data' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $json_schema_file = $self->get_update_item_bulk_json_schema_file();

  my $json_schema = read_file($json_schema_file);

  my $schema_obj;

  eval {

    $schema_obj = decode_json($json_schema);
  };

  if ($@) {

    $self->logger->debug("Invalid JSON for the schema: $@");
    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'data' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $validator = JSON::Validator->new();

  $validator->schema($schema_obj);

  my @errors = $validator->validate($data_obj);

  if (scalar(@errors) > 0) {

    my $err_msg = join(' ', @errors);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_write = connect_kdb_write();

  my $data_aref = $data_obj->{'DATA'};

  my $uniq_item_id_href            = {};

  my $spec_id2itm_id_href          = {};
  my $itm_type_id2itm_id_href      = {};

  my $itm_src2itm_id_href          = {};
  my $tu_spec2itm_id_href          = {};

  my $tu_spec_spec_id_href         = {};

  my $con_type2itm_id_href         = {};
  my $scale_id2itm_id_href         = {};
  my $storage_id2itm_id_href       = {};
  my $unit_id2itm_id_href          = {};
  my $itm_state2itm_id_href        = {};

  my $lmeasured_usr_id2itm_id_href = {};

  for my $data_rec (@{$data_aref}) {

    my $item_id           = $data_rec->{'ItemId'};
    my $spec_id           = $data_rec->{'SpecimenId'};
    my $itm_type_id       = $data_rec->{'ItemTypeId'};
    my $last_up_ts        = $data_rec->{'LastUpdateTimeStamp'};

    if (defined $uniq_item_id_href->{$item_id}) {

      my $err_msg = "Item ($item_id): found in multiple entries.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    else {

      $uniq_item_id_href->{$item_id} = [$spec_id, 0];
    }

    if (defined $spec_id2itm_id_href->{$spec_id}) {

      my $itm_id_aref = $spec_id2itm_id_href->{$spec_id};
      push(@{$itm_id_aref}, $item_id);
      $spec_id2itm_id_href->{$spec_id} = $itm_id_aref;
    }
    else {

      $spec_id2itm_id_href->{$spec_id} = [$item_id];
    }

    if (defined $itm_type_id2itm_id_href->{$itm_type_id}) {

      my $itm_id_aref = $itm_type_id2itm_id_href->{$itm_type_id};
      push(@{$itm_id_aref}, $item_id);
      $itm_type_id2itm_id_href->{$itm_type_id} = $itm_id_aref;
    }
    else {

      $itm_type_id2itm_id_href->{$itm_type_id} = [$item_id];
    }

    my ($last_up_ts_err, $last_up_ts_ms) = check_dt_value( {'LastUpdateTimeStamp' => $last_up_ts} );

    if ($last_up_ts_err) {

      my $err_msg = "LastUpdateTimeStamp ($last_up_ts) for ItemId ($item_id): unknown date format.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if (defined $data_rec->{'LastMeasuredDate'}) {

      if (length($data_rec->{'LastMeasuredDate'}) > 0) {

        my $last_ms_dt = $data_rec->{'LastMeasuredDate'};

        my ($last_ms_dt_err, $last_ms_dt_ms) = check_dt_value( {'LastMeasuredDate' => $last_ms_dt} );

        if ($last_ms_dt_err) {

          my $err_msg = "LastMeasuredDate ($last_ms_dt) for ItemId ($item_id): unknown date format.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
      }
    }

    if (defined $data_rec->{'ItemOperation'}) {

      if (length($data_rec->{'ItemOperation'}) > 0) {

        my $itm_oper = $data_rec->{'ItemOperation'};

        if ( $itm_oper !~ /^subsample$|^group$|^null$/i ) {

          my $err_msg = 'ItemOperation ($itm_oper) for ItemId ($item_id) can only be subsample or group.';;

          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
      }
    }

    if (defined $data_rec->{'ItemBarcode'}) {

      if (length($data_rec->{'ItemBarcode'}) > 0) {

        my $barcode = $data_rec->{'ItemBarcode'};

        my $barcode_sql = 'SELECT ItemId FROM item WHERE ItemId<>? AND ItemBarcode=? LIMIT 1';
        my ($r_barcode_err, $found_item_id) = read_cell($dbh_write, $barcode_sql, [$item_id, $barcode]);

        if ($r_barcode_err) {

          $self->logger->debug("Lookup existing barcode failed");
          my $err_msg = "Unexpected Error.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'ItemStateId' => $err_msg}]};

          return $data_for_postrun_href;
        }

        if (length($found_item_id) > 0) {

          my $err_msg = "ItemBarcode ($barcode) for ItemId ($item_id): already exits.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
      }
    }

    if (defined $data_rec->{'ItemSourceId'}) {

      if (length($data_rec->{'ItemSourceId'}) > 0) {

        my $itm_src_id = $data_rec->{'ItemSourceId'};

        if (defined $itm_src2itm_id_href->{$itm_src_id}) {

          my $itm_id_aref = $itm_src2itm_id_href->{$itm_src_id};
          push(@{$itm_id_aref}, $item_id);
          $itm_src2itm_id_href->{$itm_src_id} = $itm_id_aref;
        }
        else {

          $itm_src2itm_id_href->{$itm_src_id} = [$item_id];
        }
      }
    }

    if (defined $data_rec->{'TrialUnitSpecimenId'}) {

      if (length($data_rec->{'TrialUnitSpecimenId'}) > 0) {

        my $tu_spec_id = $data_rec->{'TrialUnitSpecimenId'};

        $uniq_item_id_href->{$item_id} = [$spec_id, $tu_spec_id];

        $tu_spec_spec_id_href->{"${tu_spec_id}_${spec_id}"} = $item_id;

        if (defined $tu_spec2itm_id_href->{$tu_spec_id}) {

          my $itm_id_aref = $tu_spec2itm_id_href->{$tu_spec_id};
          push(@{$itm_id_aref}, $item_id);
          $tu_spec2itm_id_href->{$tu_spec_id} = $itm_id_aref;
        }
        else {

          $tu_spec2itm_id_href->{$tu_spec_id} = [$item_id];
        }
      }
    }

    if (defined $data_rec->{'ContainerTypeId'}) {

      if (length($data_rec->{'ContainerTypeId'}) > 0) {

        my $con_type_id = $data_rec->{'ContainerTypeId'};

        if (defined $con_type2itm_id_href->{$con_type_id}) {

          my $itm_id_aref = $con_type2itm_id_href->{$con_type_id};
          push(@{$itm_id_aref}, $item_id);
          $con_type2itm_id_href->{$con_type_id} = $itm_id_aref;
        }
        else {

          $con_type2itm_id_href->{$con_type_id} = [$item_id];
        }
      }
    }

    if (defined $data_rec->{'ScaleId'}) {

      if (length($data_rec->{'ScaleId'}) > 0) {

        my $scale_id = $data_rec->{'ScaleId'};

        if (defined $scale_id2itm_id_href->{$scale_id}) {

          my $itm_id_aref = $scale_id2itm_id_href->{$scale_id};
          push(@{$itm_id_aref}, $item_id);
          $scale_id2itm_id_href->{$scale_id} = $itm_id_aref;
        }
        else {

          $scale_id2itm_id_href->{$scale_id} = [$item_id];
        }
      }
    }

    if (defined $data_rec->{'StorageId'}) {

      if (length($data_rec->{'StorageId'}) > 0) {

        my $storage_id = $data_rec->{'StorageId'};

        if (defined $storage_id2itm_id_href->{$storage_id}) {

          my $itm_id_aref = $storage_id2itm_id_href->{$storage_id};
          push(@{$itm_id_aref}, $item_id);
          $storage_id2itm_id_href->{$storage_id} = $itm_id_aref;
        }
        else {

          $storage_id2itm_id_href->{$storage_id} = [$item_id];
        }
      }
    }

    if (defined $data_rec->{'UnitId'}) {

      if (length($data_rec->{'UnitId'}) > 0) {

        my $unit_id = $data_rec->{'UnitId'};

        if (defined $unit_id2itm_id_href->{$unit_id}) {

          my $itm_id_aref = $unit_id2itm_id_href->{$unit_id};
          push(@{$itm_id_aref}, $item_id);
          $unit_id2itm_id_href->{$unit_id} = $itm_id_aref;
        }
        else {

          $unit_id2itm_id_href->{$unit_id} = [$item_id];
        }
      }
    }

    if (defined $data_rec->{'ItemStateId'}) {

      if (length($data_rec->{'ItemStateId'}) > 0) {

        my $itm_state_id = $data_rec->{'ItemStateId'};

        if (defined $itm_state2itm_id_href->{$itm_state_id}) {

          my $itm_id_aref = $itm_state2itm_id_href->{$itm_state_id};
          push(@{$itm_id_aref}, $item_id);
          $itm_state2itm_id_href->{$itm_state_id} = $itm_id_aref;
        }
        else {

          $itm_state2itm_id_href->{$itm_state_id} = [$item_id];
        }
      }
    }

    if (defined $data_rec->{'LastMeasuredUserId'}) {

      if (length($data_rec->{'LastMeasuredUserId'}) > 0) {

        my $lmeasured_usr_id = $data_rec->{'LastMeasuredUserId'};

        if (defined $lmeasured_usr_id2itm_id_href->{$lmeasured_usr_id}) {

          my $itm_id_aref = $lmeasured_usr_id2itm_id_href->{$lmeasured_usr_id};
          push(@{$itm_id_aref}, $item_id);
          $lmeasured_usr_id2itm_id_href->{$lmeasured_usr_id} = $itm_id_aref;
        }
        else {

          $lmeasured_usr_id2itm_id_href->{$lmeasured_usr_id} = [$item_id];
        }
      }
    }

    if (defined $data_rec->{'DateAdded'}) {

      if (length($data_rec->{'DateAdded'}) > 0) {

        my $dateadded_dt = $data_rec->{'DateAdded'};

        my ($dateadded_dt_err, $dateadded_dt_ms) = check_dt_value( {'DateAdded' => $dateadded_dt} );

        if ($dateadded_dt_err) {

          my $err_msg = "DateAdded ($dateadded_dt) for ItemId ($item_id): unknown date format.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
      }
    }
  }

  my @item_id_list = keys(%{$uniq_item_id_href});

  if (scalar(@item_id_list) == 0) {

    $self->logger->debug("List of ItemId is empty");
    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT * FROM item WHERE ItemId IN (';
  $sql   .= join(',', @item_id_list) . ')';

  my $item_lookup = $dbh_write->selectall_hashref($sql, 'ItemId');

  if ($dbh_write->err()) {

    $self->logger->debug("Get item info failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my @unfound_item_id_list;

  my @item_specimen_id_list;

  for my $item_id (@item_id_list) {

    if (! (defined $item_lookup->{$item_id}) ) {

      push(@unfound_item_id_list, $item_id);
    }
    else {

      my $db_spec_id = $item_lookup->{$item_id}->{'SpecimenId'};
      push(@item_specimen_id_list, $db_spec_id);

      # Check the update when SpecimenId is changed for Item record that has TrialUnitSpecimenId
      # attached. This update is an error. When an item has TrialUnitSpecimenId attached,
      # if there is a change in either SpecimenId and TrialUnitSpecimenId, both has to be changed.

      my $db_tu_spec_id = 0;

      if (length($item_lookup->{$item_id}->{'TrialUnitSpecimenId'}) > 0) {

        $db_tu_spec_id = $item_lookup->{$item_id}->{'TrialUnitSpecimenId'};
      }

      my $user_spec_id    = $uniq_item_id_href->{$item_id}->[0];
      my $user_tu_spec_id = $uniq_item_id_href->{$item_id}->[1];

      if ($db_tu_spec_id != 0) {

        if ($user_tu_spec_id != 0) {

          if ($db_tu_spec_id == $user_tu_spec_id) {

            if ($db_spec_id != $user_spec_id) {

              $self->logger->debug("TrialUnitSpecimenId - SpecimenId checking case 1");
              my $err_msg = "ItemId ($item_id): TrialUnitSpecimenId (db: $db_tu_spec_id - user: $user_tu_spec_id) and SpecimenId (db: $db_spec_id - user: $user_spec_id): ambiguous.";
              $data_for_postrun_href->{'Error'} = 1;
              $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

              return $data_for_postrun_href;
            }
          }
          else {

            if ($db_spec_id == $user_spec_id) {

              $self->logger->debug("TrialUnitSpecimenId - SpecimenId checking case 2");
              my $err_msg = "ItemId ($item_id): TrialUnitSpecimenId (db: $db_tu_spec_id - user: $user_tu_spec_id) and SpecimenId (db: $db_spec_id - user: $user_spec_id): ambiguous.";
              $data_for_postrun_href->{'Error'} = 1;
              $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

              return $data_for_postrun_href;
            }
          }
        }
        else {

          if ($db_spec_id != $user_spec_id) {

            $self->logger->debug("TrialUnitSpecimenId - SpecimenId checking case 3");
            my $err_msg = "ItemId ($item_id): TrialUnitSpecimenId (db: $db_tu_spec_id - user: $user_tu_spec_id) and SpecimenId (db: $db_spec_id - user: $user_spec_id): ambiguous.";
            $data_for_postrun_href->{'Error'} = 1;
            $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

            return $data_for_postrun_href;
          }
        }
      }
      else {

        # When the item record in the database does not have TrialUnitSpecimenId, the consistency
        # checking between TrialUnitSpecimenId and SpecimenId is done in later part of this code.
      }
    }
  }

  if (scalar(@unfound_item_id_list) > 0) {

    my $err_msg = "ItemId (" . join(',', @unfound_item_id_list) . "): not found";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id  = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();


  my $is_spec_ok = 1;
  my $trouble_spec_id_aref = [];

  #my ($is_spec_ok, $trouble_spec_id_aref) = check_permission($dbh_write, 'specimen', 'SpecimenId',
  #                                                             \@item_specimen_id_list, $group_id,
  #                                                             $gadmin_status, $READ_WRITE_PERM);

  if (!$is_spec_ok) {

    my @trouble_item_id_list;
    for my $spec_id (@{$trouble_spec_id_aref}) {

      $self->logger->debug("Trouble Spec Id: $spec_id");
      push(@trouble_item_id_list, @{$spec_id2itm_id_href->{$spec_id}});
    }

    my $err_msg = "ItemId (" . join(',', @trouble_item_id_list) . "): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my @updated_spec_id_list = keys(%{$spec_id2itm_id_href});

  if (scalar(@updated_spec_id_list) == 0) {

    $self->logger->debug("List of SpecimenId is empty");
    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql  = 'SELECT SpecimenId, SpecimenName FROM specimen WHERE SpecimenId IN (';
  $sql .= join(',', @updated_spec_id_list) . ')';

  #

  my $spec_lookup = $dbh_write->selectall_hashref($sql, 'SpecimenId');

  if ($dbh_write->err()) {

    $self->logger->debug("Get specimen info failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my @unfound_spec_id_list;
  my @unfound_spec_item_id_list;

  for my $update_spec_id (@updated_spec_id_list) {

    if (! defined $spec_lookup->{$update_spec_id}) {

      push(@unfound_spec_id_list, $update_spec_id);
      push(@unfound_spec_item_id_list, @{$spec_id2itm_id_href->{$update_spec_id}});
    }
  }

  if (scalar(@unfound_spec_id_list) > 0) {

    my $unfound_spec_id_csv = join(',', @unfound_spec_id_list);
    my $unfound_spec_item_id_csv = join(',', @unfound_spec_item_id_list);

    my $err_msg = "SpecimenId ($unfound_spec_id_csv) for ItemId ($unfound_spec_item_id_csv): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  #

  #($is_spec_ok, $trouble_spec_id_aref) = check_permission($dbh_write, 'specimen', 'SpecimenId',
  #                                                        \@updated_spec_id_list, $group_id,
  #                                                        $gadmin_status, $READ_WRITE_PERM);

  if (!$is_spec_ok) {

    my @trouble_item_id_list;
    for my $spec_id (@{$trouble_spec_id_aref}) {

      $self->logger->debug("Permission denied trouble spec id: $spec_id");
      push(@trouble_item_id_list, @{$spec_id2itm_id_href->{$spec_id}});
    }

    my $err_msg = "ItemId (" . join(',', @trouble_item_id_list) . "): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my @itm_type_id_list = keys(%{$itm_type_id2itm_id_href});

  my $itm_type_id_csv = join(',', @itm_type_id_list);

  my ($chk_itm_type_id_err, $unfound_itm_type_id_csv) = type_existence_csv($dbh_write, 'item',
                                                                           $itm_type_id_csv);

  if ($chk_itm_type_id_err) {

    my @unfound_item_type_id_list = split(',', $unfound_itm_type_id_csv);

    my @trouble_item_id_list;
    for my $itm_type_id (@unfound_item_type_id_list) {

      push(@trouble_item_id_list, @{$itm_type_id2itm_id_href->{$itm_type_id}});
    }

    my $err_msg = "ItemTypeId ($unfound_itm_type_id_csv) for ItemId (" . join(',', @trouble_item_id_list) . "): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my @itm_src_id_list = keys(%{$itm_src2itm_id_href});

  if (scalar(@itm_src_id_list) > 0) {

    $sql  = 'SELECT ContactId, ContactFirstName FROM contact WHERE ContactId IN (';
    $sql .= join(',', @itm_src_id_list) . ')';

    my $contact_lookup = $dbh_write->selectall_hashref($sql, 'ContactId');

    if ($dbh_write->err()) {

      $self->logger->debug("Get contact info failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my @unfound_itm_src_item_id_list;
    my @unfound_itm_src_id_list;

    for my $itm_src_id (@itm_src_id_list) {

      if (! (defined $contact_lookup->{$itm_src_id}) ) {

        push(@unfound_itm_src_id_list, $itm_src_id);
        push(@unfound_itm_src_item_id_list, @{$itm_src2itm_id_href->{$itm_src_id}});
      }
    }

    if (scalar(@unfound_itm_src_id_list) > 0) {

      my $unfound_itm_src_id_csv = join(',', @unfound_itm_src_id_list);
      my $unfound_itm_src_item_id_csv = join(',', @unfound_itm_src_item_id_list);

      my $err_msg = "ItemSourceId ($unfound_itm_src_id_csv) for ItemId ($unfound_itm_src_item_id_csv): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @tu_spec_id_list = keys(%{$tu_spec2itm_id_href});

  if (scalar(@tu_spec_id_list) > 0) {

    $sql  = 'SELECT TrialUnitSpecimenId, SpecimenId FROM trialunitspecimen ';
    $sql .= 'WHERE TrialUnitSpecimenId IN (' . join(',', @tu_spec_id_list) . ')';

    my $tu_spec_lookup = $dbh_write->selectall_hashref($sql, 'TrialUnitSpecimenId');

    if ($dbh_write->err()) {

      $self->logger->debug("Get trial unit specimen info failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my @unfound_tu_spec_item_id_list;
    my @unfound_tu_spec_id_list;

    for my $tuspec_spec_id_str (keys(%{$tu_spec_spec_id_href})) {

      $self->logger->debug("TrialUnitSpecimenId SpecimenId STR: $tuspec_spec_id_str");

      my ($user_tu_spec_id, $user_spec_id) = split(/_/, $tuspec_spec_id_str);

      if (! (defined $tu_spec_lookup->{$user_tu_spec_id}) ) {

        push(@unfound_tu_spec_id_list, $user_tu_spec_id);
        push(@unfound_tu_spec_item_id_list, @{$tu_spec2itm_id_href->{$user_tu_spec_id}});
      }
      else {

        my $db_spec_id = $tu_spec_lookup->{$user_tu_spec_id}->{'SpecimenId'};

        if ("$user_spec_id" ne "$db_spec_id") {

          my $item_id = $tu_spec_spec_id_href->{$tuspec_spec_id_str};

          my $err_msg = "ItemId ($item_id): TrialUnitSpecimenId ($user_tu_spec_id) - SpecimenId (user: $user_spec_id - db: $db_spec_id): ambiguous.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
      }
    }

    if (scalar(@unfound_tu_spec_id_list) > 0) {

      my $unfound_tu_spec_id_csv      = join(',', @unfound_tu_spec_id_list);
      my $unfound_tu_spec_item_id_csv = join(',', @unfound_tu_spec_item_id_list);

      my $err_msg = "TrialUnitSpecimenId ($unfound_tu_spec_id_csv) for ItemId ($unfound_tu_spec_item_id_csv): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @con_type_id_list = keys(%{$con_type2itm_id_href});

  if (scalar(@con_type_id_list) > 0) {

    my $con_type_id_csv = join(',', @con_type_id_list);

    my ($chk_con_type_id_err, $unfound_con_type_id_csv) = type_existence_csv($dbh_write, 'container',
                                                                             $con_type_id_csv);

    if ($chk_con_type_id_err) {

      my @unfound_con_type_id_list = split(',', $unfound_con_type_id_csv);

      my @trouble_item_id_list;

      for my $con_type_id (@unfound_con_type_id_list) {

        push(@trouble_item_id_list, @{$con_type2itm_id_href->{$con_type_id}});
      }

      my $err_msg = "ContainerTypeId ($unfound_con_type_id_csv) for ItemId (" . join(',', @trouble_item_id_list) . "): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @scale_id_list = keys(%{$scale_id2itm_id_href});

  if (scalar(@scale_id_list) > 0) {

    $sql  = 'SELECT DeviceRegisterId, DeviceId FROM deviceregister ';
    $sql .= 'WHERE DeviceRegisterId IN (' . join(',', @scale_id_list) . ')';

    my $device_lookup = $dbh_write->selectall_hashref($sql, 'DeviceRegisterId');

    if ($dbh_write->err()) {

      $self->logger->debug("Get deviceregister info failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my @unfound_scale_item_id_list;
    my @unfound_scale_id_list;

    for my $scale_id (@scale_id_list) {

      if (! (defined $device_lookup->{$scale_id}) ) {

        push(@unfound_scale_id_list, $scale_id);
        push(@unfound_scale_item_id_list, @{$scale_id2itm_id_href->{$scale_id}});
      }
    }

    if (scalar(@unfound_scale_id_list) > 0) {

      my $unfound_scale_id_csv      = join(',', @unfound_scale_id_list);
      my $unfound_scale_item_id_csv = join(',', @unfound_scale_item_id_list);

      my $err_msg = "ScaleId ($unfound_scale_id_csv) for ItemId ($unfound_scale_item_id_csv): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @storage_id_list = keys(%{$storage_id2itm_id_href});

  if (scalar(@storage_id_list) > 0) {

    $sql  = 'SELECT StorageId, StorageLocation FROM storage ';
    $sql .= 'WHERE StorageId IN (' . join(',', @storage_id_list) . ')';

    my $storage_lookup = $dbh_write->selectall_hashref($sql, 'StorageId');

    if ($dbh_write->err()) {

      $self->logger->debug("Get storage info failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my @unfound_storage_item_id_list;
    my @unfound_storage_id_list;

    for my $storage_id (@storage_id_list) {

      if (! (defined $storage_lookup->{$storage_id}) ) {

        push(@unfound_storage_id_list, $storage_id);
        push(@unfound_storage_item_id_list, @{$storage_id2itm_id_href->{$storage_id}});
      }
    }

    if (scalar(@unfound_storage_id_list) > 0) {

      my $unfound_storage_id_csv      = join(',', @unfound_storage_id_list);
      my $unfound_storage_item_id_csv = join(',', @unfound_storage_item_id_list);

      my $err_msg = "StorageId ($unfound_storage_id_csv) for ItemId ($unfound_storage_item_id_csv): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @unit_id_list = keys(%{$unit_id2itm_id_href});

  if (scalar(@unit_id_list) > 0) {

    $sql  = 'SELECT UnitId, UnitName FROM generalunit ';
    $sql .= 'WHERE UnitId IN (' . join(',', @unit_id_list) . ')';

    my $unit_lookup = $dbh_write->selectall_hashref($sql, 'UnitId');

    if ($dbh_write->err()) {

      $self->logger->debug("Get generalunit info failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my @unfound_unit_item_id_list;
    my @unfound_unit_id_list;

    for my $unit_id (@unit_id_list) {

      if (! (defined $unit_lookup->{$unit_id}) ) {

        push(@unfound_unit_id_list, $unit_id);
        push(@unfound_unit_item_id_list, @{$unit_id2itm_id_href->{$unit_id}});
      }
    }

    if (scalar(@unfound_unit_id_list) > 0) {

      my $unfound_unit_id_csv      = join(',', @unfound_unit_id_list);
      my $unfound_unit_item_id_csv = join(',', @unfound_unit_item_id_list);

      my $err_msg = "UnitId ($unfound_unit_id_csv) for ItemId ($unfound_unit_item_id_csv): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @itm_state_id_list = keys(%{$itm_state2itm_id_href});

  if (scalar(@itm_state_id_list) > 0) {

    my $itm_state_id_csv = join(',', @itm_state_id_list);

    my ($chk_itm_state_id_err, $unfound_itm_state_id_csv) = type_existence_csv($dbh_write, 'state',
                                                                               $itm_state_id_csv);

    if ($chk_itm_state_id_err) {

      my @unfound_itm_state_id_list = split(',', $unfound_itm_state_id_csv);

      my @trouble_item_id_list;

      for my $itm_state_id (@unfound_itm_state_id_list) {

        push(@trouble_item_id_list, @{$itm_state2itm_id_href->{$itm_state_id}});
      }

      my $err_msg = "ItemStateId ($unfound_itm_state_id_csv) for ItemId (" . join(',', @trouble_item_id_list) . "): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @lmeasured_usr_id_list = keys(%{$lmeasured_usr_id2itm_id_href});

  if (scalar(@lmeasured_usr_id_list) > 0) {

    $sql  = 'SELECT UserId, UserName FROM systemuser ';
    $sql .= 'WHERE UserId IN (' . join(',', @lmeasured_usr_id_list) . ')';

    my $user_lookup = $dbh_write->selectall_hashref($sql, 'UserId');

    if ($dbh_write->err()) {

      $self->logger->debug("Get deviceregister info failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my @unfound_lmeasured_usr_item_id_list;
    my @unfound_lmeasured_usr_id_list;

    for my $lmeasured_usr_id (@lmeasured_usr_id_list) {

      if (! (defined $user_lookup->{$lmeasured_usr_id}) ) {

        push(@unfound_lmeasured_usr_id_list, $lmeasured_usr_id);
        push(@unfound_lmeasured_usr_item_id_list, @{$lmeasured_usr_id2itm_id_href->{$lmeasured_usr_id}});
      }
    }

    if (scalar(@unfound_lmeasured_usr_id_list) > 0) {

      my $unfound_lmeasured_usr_id_csv      = join(',', @unfound_lmeasured_usr_id_list);
      my $unfound_lmeasured_usr_item_id_csv = join(',', @unfound_lmeasured_usr_item_id_list);

      my $err_msg = "LastMeasuredUserId ($unfound_lmeasured_usr_id_csv) for ItemId ($unfound_lmeasured_usr_item_id_csv): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $successful_aref = [];
  my $failed_aref     = [];

  my $cur_dt = DateTime->now( time_zone => $TIMEZONE );
  $cur_dt = DateTime::Format::MySQL->format_datetime($cur_dt);

  #handling vcol

  # Get the virtual col from the factor table
  my $vcol_data              = $self->_get_item_factor();


  for my $data_rec (@{$data_aref}) {

    my $item_id           = $data_rec->{'ItemId'};
    my $spec_id           = $data_rec->{'SpecimenId'};
    my $item_type_id      = $data_rec->{'ItemTypeId'};
    my $last_up_ts        = $data_rec->{'LastUpdateTimeStamp'};

    my $last_ms_dt        = $cur_dt;

    if (defined $data_rec->{'LastMeasuredDate'}) {

      if (length($data_rec->{'LastMeasuredDate'}) > 0) {

        $last_ms_dt = $data_rec->{'LastMeasuredDate'};
      }
    }

    my $item_oper         = $item_lookup->{$item_id}->{'ItemOperation'};

    if (length($item_oper) == 0) {

      $item_oper = undef;
    }

    if (defined $data_rec->{'ItemOperation'}) {

      if (length($data_rec->{'ItemOperation'}) > 0) {

        $item_oper = $data_rec->{'ItemOperation'};
      }
      else {

        $item_oper = undef;
      }
    }

    my $item_barcode = $item_lookup->{$item_id}->{'ItemBarcode'};

    if (length($item_barcode) == 0) {

      $item_barcode = undef;
    }

    if (defined $data_rec->{'ItemBarcode'}) {

      if (length($data_rec->{'ItemBarcode'}) > 0) {

        $item_barcode = $data_rec->{'ItemBarcode'};
      }
      else {

        $item_barcode = undef;
      }
    }

    my $item_source_id = $item_lookup->{$item_id}->{'ItemSourceId'};

    if (length($item_source_id) == 0) {

      $item_source_id = undef;
    }

    if (defined $data_rec->{'ItemSourceId'}) {

      if (length($data_rec->{'ItemSourceId'}) > 0) {

        $item_source_id = $data_rec->{'ItemSourceId'};
      }
      else {

        $item_source_id = undef;
      }
    }

    my $tu_spec_id = $item_lookup->{$item_id}->{'TrialUnitSpecimenId'};

    if (length($tu_spec_id) == 0) {

      $tu_spec_id = undef;
    }

    if (defined $data_rec->{'TrialUnitSpecimenId'}) {

      if (length($data_rec->{'TrialUnitSpecimenId'}) > 0) {

        $tu_spec_id = $data_rec->{'TrialUnitSpecimenId'};
      }
      else {

        $tu_spec_id = undef;
      }
    }

    my $con_type_id = $item_lookup->{$item_id}->{'ContainerTypeId'};

    if (length($con_type_id) == 0) {

      $con_type_id = undef;
    }

    if (defined $data_rec->{'ContainerTypeId'}) {

      if (length($data_rec->{'ContainerTypeId'}) > 0) {

        $con_type_id = $data_rec->{'ContainerTypeId'};
      }
      else {

        $con_type_id = undef;
      }
    }

    my $scale_id = $item_lookup->{$item_id}->{'ScaleId'};

    if (length($scale_id) == 0) {

      $scale_id = undef;
    }

    if (defined $data_rec->{'ScaleId'}) {

      if (length($data_rec->{'ScaleId'}) > 0) {

        $scale_id = $data_rec->{'ScaleId'};
      }
      else {

        $scale_id = undef;
      }
    }

    my $storage_id = $item_lookup->{$item_id}->{'StorageId'};

    if (length($storage_id) == 0) {

      $storage_id = undef;
    }

    if (defined $data_rec->{'StorageId'}) {

      if (length($data_rec->{'StorageId'}) > 0) {

        $storage_id = $data_rec->{'StorageId'};
      }
      else {

        $storage_id = undef;
      }
    }

    my $unit_id = $item_lookup->{$item_id}->{'UnitId'};

    if (length($unit_id) == 0) {

      $unit_id = undef;
    }

    if (defined $data_rec->{'UnitId'}) {

      if (length($data_rec->{'UnitId'}) > 0) {

        $unit_id = $data_rec->{'UnitId'};
      }
      else {

        $unit_id = undef;
      }
    }

    my $item_state_id = $item_lookup->{$item_id}->{'ItemStateId'};

    if (length($item_state_id) == 0) {

      $item_state_id = undef;
    }

    if (defined $data_rec->{'ItemStateId'}) {

      if (length($data_rec->{'ItemStateId'}) > 0) {

        $item_state_id = $data_rec->{'ItemStateId'};
      }
      else {

        $item_state_id = undef;
      }
    }

    my $amount = $item_lookup->{$item_id}->{'Amount'};

    if (length($amount) == 0) {

      $amount = undef;
    }

    if (defined $data_rec->{'Amount'}) {

      if (length($data_rec->{'Amount'}) > 0) {

        $amount = $data_rec->{'Amount'};
      }
      else {

        $amount = undef;
      }
    }

    my $last_measured_user_id = $item_lookup->{$item_id}->{'LastMeasuredUserId'};

    if (length($last_measured_user_id) == 0) {

      $last_measured_user_id = undef;
    }

    if (defined $data_rec->{'LastMeasuredUserId'}) {

      if (length($data_rec->{'LastMeasuredUserId'}) > 0) {

        $last_measured_user_id = $data_rec->{'LastMeasuredUserId'};
      }
      else {

        $last_measured_user_id = undef;
      }
    }

    my $item_note = $item_lookup->{$item_id}->{'ItemNote'};

    if (length($item_note) == 0) {

      $item_note = undef;
    }

    if (defined $data_rec->{'ItemNote'}) {

      if (length($data_rec->{'ItemNote'}) > 0) {

        $item_note = $data_rec->{'ItemNote'};
      }
      else {

        $item_note = undef;
      }
    }

    my $dateadded_dt = $item_lookup->{$item_id}->{'DateAdded'};

    if (length($dateadded_dt) == 0) {

      $dateadded_dt = undef;
    }

    if (defined $data_rec->{'DateAdded'}) {

      if (length($data_rec->{'DateAdded'}) > 0) {

        $dateadded_dt = $data_rec->{'DateAdded'};
      }
      else {

        $dateadded_dt = undef;
      }
    }

    $sql  = 'UPDATE item SET ';
    $sql .= 'UnitId=?, ';
    $sql .= 'TrialUnitSpecimenId=?, ';
    $sql .= 'ItemSourceId=?, ';
    $sql .= 'ContainerTypeId=?, ';
    $sql .= 'SpecimenId=?, ';
    $sql .= 'ScaleId=?, ';
    $sql .= 'StorageId=?, ';
    $sql .= 'ItemTypeId=?, ';
    $sql .= 'ItemStateId=?, ';
    $sql .= 'ItemBarcode=?, ';
    $sql .= 'Amount=?, ';
    $sql .= 'LastMeasuredDate=?, ';
    $sql .= 'LastMeasuredUserId=?, ';
    $sql .= 'ItemOperation=?, ';
    $sql .= 'ItemNote=?, ';
    $sql .= 'DateAdded=?, ';
    $sql .= 'LastUpdateTimeStamp=? ';
    $sql .= 'WHERE ItemId=? AND LastUpdateTimeStamp=?';

    my $sth = $dbh_write->prepare($sql);
    $sth->execute($unit_id, $tu_spec_id, $item_source_id, $con_type_id,
                  $spec_id, $scale_id, $storage_id, $item_type_id, $item_state_id,
                  $item_barcode, $amount, $last_ms_dt, $last_measured_user_id,
                  $item_oper, $item_note,$dateadded_dt,$cur_dt, $item_id, $last_up_ts
                 );

    my $status_href = { 'ItemId'     => $item_id,
                        'Successful' => 0,
                        'Failed'     => 0,
                        'Message'    => ''
                      };

    if ($dbh_write->err()) {

      $status_href->{'Failed'}   = 1;
      $status_href->{'Message'}  = $dbh_write->errstr();

      push(@{$failed_aref}, $status_href);
    }
    else {

      my $nb_affected_row = $sth->rows();

      if ($nb_affected_row == 1) {

        $status_href->{'Successful'}   = 1;

        push(@{$successful_aref}, $status_href);
      }
      else {

        $status_href->{'Failed'}   = 1;
        $status_href->{'Message'}  = 'LastUpdateTimeStamp: not matched';

        push(@{$failed_aref}, $status_href);
      }
    }

    $sth->finish();

    #handle vcol here:
    my $vcol_param_data_compul = {};
    my $vcol_param_data        = {};
    my $vcol_len_info          = {};
    my $vcol_param_data_maxlen = {};

    for my $vcol_id ( keys( %{$vcol_data} ) ) {

      my $vcol_param_name = "VCol_${vcol_id}";
      my $vcol_value      = $data_rec->{$vcol_param_name};
      if ( $vcol_data->{$vcol_id}->{'CanFactorHaveNull'} != 1 ) {

        $vcol_param_data_compul->{$vcol_param_name} = $vcol_value;
      }
      $vcol_param_data->{$vcol_param_name} = $vcol_value;
      $vcol_len_info->{$vcol_param_name}          = $vcol_data->{$vcol_id}->{'FactorValueMaxLength'};
      $vcol_param_data_maxlen->{$vcol_param_name} = $vcol_value;
    }

    # Validate virtual column for factor
    my ( $vcol_missing_err, $vcol_missing_msg ) = check_missing_value($vcol_param_data_compul);

    if ($vcol_missing_err) {

      $vcol_missing_msg = $vcol_missing_msg . ' missing';
      return $self->_set_error($vcol_missing_msg);
    }

    my ( $vcol_maxlen_err, $vcol_maxlen_msg ) = check_maxlen( $vcol_param_data_maxlen, $vcol_len_info );

    if ($vcol_maxlen_err) {

      $vcol_maxlen_msg = $vcol_maxlen_msg . ' longer than maximum length.';
      #return $self->_set_error($vcol_maxlen_msg);
    }

    my $dbh_k_write = connect_kdb_write();

    my ($up_vcol_err, $up_vcol_err_msg) = update_vcol_data($dbh_k_write, $vcol_data, $vcol_param_data,
                                                           'itemfactor', 'ItemId', $item_id);

    if ($up_vcol_err) {

      $self->logger->debug($up_vcol_err_msg);
      return $self->_set_error('Unexpected error.');
    }

    $sth->finish();
    $dbh_k_write->disconnect();


  }

  $dbh_write->disconnect();

  my $nb_failed     = scalar(@{$failed_aref});
  my $nb_successful = scalar(@{$successful_aref});

  my $info_msg = "Number of items updated successfully: $nb_successful - number of items not updated: $nb_failed.";
  my $info_msg_aref = [{'Message' => $info_msg}];

  $data_for_postrun_href->{'Data'}      = {'Info'       => $info_msg_aref,
                                           'Success'    => $successful_aref,
                                           'Failure'    => $failed_aref
                                          };
  $data_for_postrun_href->{'ExtraData'} = 0;

  if ($nb_successful == 0) {

    $data_for_postrun_href->{'Error'}     = 1;
  }
  else {

    $data_for_postrun_href->{'Error'}     = 0;
  }

  return $data_for_postrun_href;
}




######################################################################
# Utility functions

sub _validate_fk_relation {

  my ( $self, @relations ) = @_;
  my $invalid_relation;
  my $dbh_k_read = connect_kdb_read();
  foreach my $relation (@relations) {

    my $is_valid_relationship = record_existence( $dbh_k_read, $relation->{'table'},
                                                  $relation->{'field'}, $relation->{'value'} );

    if ( !$is_valid_relationship ) {

      # Found invalid relationship id, end the loop and assign invalid relationship
      $invalid_relation = $relation;
      last;
    }
  }
  $dbh_k_read->disconnect();

  # return only if any error
  return $invalid_relation;
}

sub _set_error {

  my ( $self, $error_message ) = @_;
  return {
    'Error' => 1,
    'Data'  => { 'Error' => [ { 'Message' => $error_message || 'Unexpected error.' } ] }
  };
}

sub _get_item_factor {

  my ($self) = @_;
  my $query  = $self->query();
  my $sql    = "
        SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength
        FROM factor
        WHERE TableNameOfFactor='itemfactor'
    ";
  my $dbh_k_read = connect_kdb_read();
  my $vcol_data = $dbh_k_read->selectall_hashref( $sql, 'FactorId' ) || {};
  $dbh_k_read->disconnect();
  return $vcol_data;
}

sub _add_factor {

  my ( $self, $item_id, $vcol_data ) = @_;

  my $query       = $self->query();
  my $dbh_k_write = connect_kdb_write();

  for my $vcol_id ( keys( %{$vcol_data} ) ) {

    my $factor_value = $query->param( 'VCol_' . "$vcol_id" );

    if ( length($factor_value) > 0 ) {

      my $sql = "
                INSERT INTO itemfactor SET
                ItemId=?,
                FactorId=?,
                FactorValue=?
            ";
      my $factor_sth = $dbh_k_write->prepare($sql);
      $factor_sth->execute( $item_id, $vcol_id, $factor_value );

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

sub get_itemgroup_dtd_file {

  my $dtd_path = $ENV{DOCUMENT_ROOT} . '/' . $DTD_PATH;

  return "${dtd_path}/itemgroup.dtd";
}

sub get_item_group_entry_dtd_file {

  my $dtd_path = $ENV{DOCUMENT_ROOT} . '/' . $DTD_PATH;

  return "${dtd_path}/itemgroupentry.dtd";
}

sub get_update_item_bulk_json_schema_file {

  my $json_schema_path = $ENV{DOCUMENT_ROOT} . '/' . $JSON_SCHEMA_PATH;

  return "${json_schema_path}/updateitembulk.schema.json";
}


sub logger {

  my $self = shift;
  return $self->{logger};
}

1;
