#$Id: Inventory.pm 1020 2015-10-15 06:25:02Z puthick $
#$Author: puthick $

# Copyright (c) 2015, Diversity Arrays Technology, All rights reserved.

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
# Version   : 2.3.0 build 1040

package KDDArT::DAL::Inventory;

use strict;
use warnings;
use Data::Dumper;

BEGIN {
  use File::Spec;
  my ( $volume, $current_dir, $file ) = File::Spec->splitpath(__FILE__);
  $main::kddart_base_dir = "${current_dir}../../..";
}

use lib "$main::kddart_base_dir/perl-lib";

use base 'KDDArT::DAL::Transformation';

use KDDArT::DAL::Common;
use KDDArT::DAL::Security;
use CGI::Application::Plugin::Session;
use Log::Log4perl qw(get_logger :levels);
use XML::Checker::Parser;
use Crypt::Random qw( makerandom );
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
      );
  __PACKAGE__->authen->check_gadmin_runmodes('add_storage_gadmin',
                                             'update_storage_gadmin',
                                             'del_storage_gadmin',
                                             'update_item_gadmin',
                                             'del_item_gadmin',
                                             'add_itemparent_gadmin',
                                             'del_itemparent_gadmin',
                                             'add_itemgroup_gadmin',
                                             'del_itemgroup_gadmin',
                                             'add_item_to_group_gadmin',
                                             'remove_item_from_group_gadmin',
                                             'import_itemgroup_xml_gadmin',
                                             'import_item_csv_gadmin',
                                             'update_generalunit_gadmin',
                                             'del_generalunit_gadmin',
                                             'add_generalunit_gadmin',
                                             'add_conversionrule_gadmin',
                                             'del_conversionrule_gadmin',
                                             'update_conversionrule_gadmin',
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

  $self->authen->config( LOGIN_URL => '' );
  $self->session_config( CGI_SESSION_OPTIONS => [ "driver:File", $self->query, { Directory => $SESSION_STORAGE_PATH } ], );
}

# Managing item Parent
###########################################################################

sub del_itemparent_runmode {

=pod del_itemparent_gadmin_HELP_START
{
"OperationName" : "Delete item parent",
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
"OperationName" : "Add parent for item",
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
"OperationName" : "List item groups",
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

  my ( $filter_err, $filter_msg, $filter_phrase, $where_arg ) = parse_filtering('ItemGroupId', 'itemgroup',
                                                                                $filtering_csv, $final_field_list );
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
"OperationName" : "Get item group",
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
"OperationName" : "Add item group",
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
"OperationName" : "Update item group",
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
"OperationName" : "Delete item group",
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
"OperationName" : "List units --- updated needed",
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

  my ($read_generalunit_err, $read_generalunit_msg, $generalunit_data) = $self->list_general_unit(1, $sql);

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
"OperationName" : "Get unit",
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
"OperationName" : "Add unit",
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
"OperationName" : "Update unit",
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

  my $unit_type_id = read_cell_value($dbh_k_read, 'generalunit', 'UnitTypeId', 'UnitId', $unit_id);

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

  my $unit_note = read_cell_value($dbh_k_read, 'generalunit', 'UnitNote', 'UnitId', $unit_id);

  if (length($unit_note) == 0) {

    $unit_note = undef;
  }

  if (defined $query->param('UnitNote')) {

    if (length($query->param('UnitNote')) > 0) {

      $unit_note = $query->param('UnitNote');
    }
  }

  my $unit_src = read_cell_value($dbh_k_read, 'generalunit', 'UnitSource', 'UnitId', $unit_id);

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
"OperationName" : "Delete unit",
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
"OperationName" : "List items",
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

    given ( $field ) {

      when (/^ItemSourceId$/i) {

        push( @{$final_field_list}, 'CONCAT(contact.ContactFirstName, " ", contact.ContactLastName) AS ItemSource' );
        $join .= ' LEFT JOIN contact ON contact.ContactId = item.ItemSourceId ';
      }
      when (/^UnitId$/i) {

        push( @{$final_field_list}, 'generalunit.UnitName' );
        $join .= ' LEFT JOIN generalunit ON generalunit.UnitId = item.UnitId ';
      }
      when (/^SpecimenId$/i) {

        push( @{$final_field_list}, 'specimen.SpecimenName' );
        $join .= ' LEFT JOIN specimen ON specimen.SpecimenId = item.SpecimenId ';
      }
      when (/^StorageId$/i) {

        push( @{$final_field_list}, 'storage.StorageLocation' );
        $join .= ' LEFT JOIN storage ON storage.StorageId = item.StorageId ';
      }
      when (/^ItemTypeId$/i) {

        push( @{$final_field_list}, 'generaltype.TypeName as ItemType' );
        push( @{$final_field_list}, 'generaltype.TypeName as ItemState' );
        $join .= ' LEFT JOIN generaltype ON generaltype.TypeId = item.ItemTypeId ';
      }
      when (/^ScaleId$/i) {

        push( @{$final_field_list}, 'deviceregister.DeviceNote' );
        $join .= ' LEFT JOIN deviceregister ON deviceregister.DeviceRegisterId = item.ScaleId ';
      }
      when (/^AddedByUserId$/i) {

        push( @{$final_field_list}, 'systemuser.UserName as AddedByUser' );
        $join .= ' LEFT JOIN systemuser ON systemuser.UserId = item.AddedByUserId ';
      }
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
      return $self->error_message('Unexpected error.');
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
"OperationName" : "Get item",
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
                     'generaltype.TypeName as ItemType',
                     'generaltype.TypeName as ItemState',
                     'deviceregister.DeviceId',
                     'systemuser.UserName as AddedByUser'
      ];
  my $other_join = ' LEFT JOIN contact ON contact.ContactId = item.ItemSourceId';
  $other_join   .= ' LEFT JOIN generalunit ON generalunit.UnitId = item.UnitId';
  $other_join   .= ' LEFT JOIN specimen ON specimen.SpecimenId = item.SpecimenId';
  $other_join   .= ' LEFT JOIN storage ON storage.StorageId = item.StorageId';
  $other_join   .= ' LEFT JOIN generaltype ON generaltype.TypeId = item.ItemTypeId';
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
"OperationName" : "Delete item",
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

  my $statement = "DELETE FROM item WHERE ItemId=?";
  my $sth       = $dbh_k_write->prepare($statement);
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
"OperationName" : "Add item",
"Description": "Add a new inventory item to the system.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "item",
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

    if (!record_existence($dbh_k_write, 'trialunitspecimen', 'TrialUnitSpecimenId', $trial_unit_spec_id)) {

      my $err_msg = "TrialUnitSpecimen ($trial_unit_spec_id): not found.";

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
  my $perm_str      = permission_phrase($group_id, 0, $gadmin_status, 'genotype');

  my $geno_specimen_sql = "SELECT genotype.GenotypeId ";
  $geno_specimen_sql   .= "FROM genotype LEFT JOIN genotypespecimen ON ";
  $geno_specimen_sql   .= "genotype.GenotypeId = genotypespecimen.GenotypeId ";
  $geno_specimen_sql   .= "WHERE genotypespecimen.SpecimenId=?";

  my ($geno_err, $geno_msg, $geno_data) = read_data($dbh_k_write, $geno_specimen_sql, [$item_specimen]);

  if ($geno_err) {

    $self->logger->debug($geno_msg);
    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $geno_specimen_sql   .= " AND ((($perm_str) & $LINK_PERM) = $LINK_PERM)";

  $self->logger->debug("Genotype specimen permission SQL: $geno_specimen_sql");

  my ($geno_p_err, $geno_p_msg, $geno_p_data_perm) = read_data($dbh_k_write, $geno_specimen_sql, [$item_specimen]);

  if ($geno_p_err) {

    $self->logger->debug($geno_p_msg);
    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$geno_data}) != scalar(@{$geno_p_data_perm})) {

    my $err_msg = "SpecimenId ($item_specimen): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{"SpecimenId" => $err_msg}]};

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
            ItemNote=?
    ";

  my $sth = $dbh_k_write->prepare($insert_statement);
  $sth->execute( $trial_unit_spec_id, $item_source, $item_container_type, $item_specimen, $item_scale,
                 $item_storage, $item_unit, $item_type, $item_state, $item_barcode, $item_amount,
                 $item_added_date, $item_added_by_user, $item_measure_date, $item_measure_by_user,
                 $item_operation, $item_note
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

  my $info_msg_aref = [ { 'Message' => "Item ($item_id) has been added successfully." } ];
  my $return_id_aref = [ { 'Value' => "$item_id", 'ParaName' => 'ItemId' } ];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref,
                                           'ReturnId'  => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_item_runmode {

=pod update_item_gadmin_HELP_START
{
"OperationName" : "Update item",
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
  my $item_barcode         = $query->param('ItemBarcode');

  my $dbh_k_write = connect_kdb_write();

  if (!record_existence($dbh_k_write, 'item', 'ItemId', $item_id)) {

    my $err_msg = "Item ($item_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trial_unit_spec_id = read_cell_value($dbh_k_write, 'item', 'TrialUnitSpecimenId', 'ItemId', $item_id);

  if (length($trial_unit_spec_id) == 0) {

    $trial_unit_spec_id = undef;
  }

  if (defined $query->param('TrialUnitSpecimenId')) {

    if (length($query->param('TrialUnitSpecimenId')) > 0) {

      $trial_unit_spec_id = $query->param('TrialUnitSpecimenId');
    }
  }

  my $item_source          = read_cell_value($dbh_k_write, 'item', 'ItemSourceId', 'ItemId', $item_id);

  if (length($item_source) == 0) {

    $item_source = undef;
  }

  if (defined $query->param('ItemSourceId')) {

    if (length($query->param('ItemSourceId')) > 0) {

      $item_source = $query->param('ItemSourceId');
    }
  }

  if (length($item_source) == 0) {

    $item_source = '0';
  }

  my $item_container_type  = read_cell_value($dbh_k_write, 'item', 'ContainerTypeId', 'ItemId', $item_id);

  if (length($item_container_type) == 0) {

    $item_container_type = undef;
  }

  if (defined $query->param('ContainerTypeId')) {

    if (length($query->param('ContainerTypeId')) > 0) {

      $item_container_type = $query->param('ContainerTypeId');
    }
  }

  my $item_scale = read_cell_value($dbh_k_write, 'item', 'ScaleId', 'ItemId', $item_id);

  if (length($item_scale) == 0) {

    $item_scale = undef;
  }

  if (defined $query->param('ScaleId')) {

    if (length($query->param('ScaleId')) > 0) {

      $item_scale = $query->param('ScaleId');
    }
  }

  my $item_storage = read_cell_value($dbh_k_write, 'item', 'StorageId', 'ItemId', $item_id);

  if (length($item_storage) == 0) {

    $item_storage = undef;
  }

  if (defined $query->param('StorageId')) {

    if (length($query->param('StorageId')) > 0) {

      $item_storage = $query->param('StorageId');
    }
  }

  my $item_unit = read_cell_value($dbh_k_write, 'item', 'UnitId', 'ItemId', $item_id);

  if (length($item_unit) == 0) {

    $item_unit = undef;
  }

  if (defined $query->param('UnitId')) {

    if (length($query->param('UnitId')) > 0) {

      $item_unit = $query->param('UnitId');
    }
  }

  my $item_state = read_cell_value($dbh_k_write, 'item', 'ItemStateId', 'ItemId', $item_id);

  if (length($item_state) == 0) {

    $item_state = undef;
  }

  if (defined $query->param('ItemStateId')) {

    if (length($query->param('ItemStateId')) > 0) {

      $item_state = $query->param('ItemStateId');
    }
  }

  my $item_amount = read_cell_value($dbh_k_write, 'item', 'Amount', 'ItemId', $item_id);

  if (defined $query->param('Amount')) {

    if (length($query->param('Amount')) > 0) {

      $item_amount = $query->param('Amount');
    }
  }

  if (length($item_amount) == 0) {

    $item_amount = '0';
  }

  my $cur_dt = DateTime->now( time_zone => $TIMEZONE );
  $cur_dt = DateTime::Format::MySQL->format_datetime($cur_dt);

  my $item_measure_date = $cur_dt;

  if (defined $query->param('LastMeasuredDate')) {

    if (length($query->param('LastMeasuredDate')) > 0) {

      $item_measure_date = $query->param('LastMeasuredDate');
    }
  }

  my $item_measure_by_user = read_cell_value($dbh_k_write, 'item', 'LastMeasuredUserId', 'ItemId', $item_id);

  if (defined $query->param('LastMeasuredUserId')) {

    if (length($query->param('LastMeasuredUserId')) > 0) {

      $item_measure_by_user = $query->param('LastMeasuredUserId');
    }
  }

  if (length($item_measure_by_user) == 0) {

    $item_measure_by_user = '-1';
  }

  my $item_operation = read_cell_value($dbh_k_write, 'item', 'ItemOperation', 'ItemId', $item_id);

  if (defined $query->param('ItemOperation')) {

    if (length($query->param('ItemOperation')) > 0) {

      $item_operation = $query->param('ItemOperation');
    }
  }

  my $item_note = read_cell_value($dbh_k_write, 'item', 'ItemNote', 'ItemId', $item_id);

  if (defined $query->param('ItemNote')) {

    $item_note = $query->param('ItemNote');
  }

  my $item_added_date      = $cur_dt;
  my $item_added_by_user   = $self->authen->user_id();

  if (defined $trial_unit_spec_id) {

    if (!record_existence($dbh_k_write, 'trialunitspecimen', 'TrialUnitSpecimenId', $trial_unit_spec_id)) {

      my $err_msg = "TrialUnitSpecimen ($trial_unit_spec_id): not found.";

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
            ItemNote=?
        WHERE ItemId=?
    ";

  if (length($filter_phrase) > 0) {

    $update_statement .= " AND $filter_phrase";
  }

  my $sth = $dbh_k_write->prepare($update_statement);
  $sth->execute( $trial_unit_spec_id, $item_source, $item_container_type, $item_specimen, $item_scale,
                 $item_storage, $item_unit, $item_type, $item_state, $item_barcode, $item_amount,
                 $item_added_date, $item_added_by_user, $item_measure_date, $item_measure_by_user,
                 $item_operation, $item_note, $item_id, @{$where_arg}
      );

  if ( $dbh_k_write->err() ) {

    return $self->_set_error();
  }

  my $affected_rows = $sth->rows();

  if ($affected_rows != 1) {

    $self->logger->debug("Number of affected rows: $affected_rows");

    my $err_msg = "Operation is unsuccessful.";
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
"OperationName" : "Add item to item group",
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
"OperationName" : "Remove item from item group",
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
"OperationName" : "Add storage",
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

  my $skip_field = {};

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

  if (record_existence($dbh_k_write, 'storage', 'StorageBarcode', $storage_barcode)) {

    my $err_msg = "StorageBarcode ($storage_barcode): already used.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'StorageBarcode' => $err_msg}]};

    return $data_for_postrun_href;
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
"OperationName" : "Update storage",
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

  my $storage_barcode   = $query->param('StorageBarcode');
  my $storage_loc       = $query->param('StorageLocation');

  my $storage_details   = read_cell_value($dbh_k_write, 'storage', 'StorageDetails', 'StorageId', $storage_id);
  my $storage_note      = read_cell_value($dbh_k_write, 'storage', 'StorageNote', 'StorageId', $storage_id);
  my $storage_parent_id = read_cell_value($dbh_k_write, 'storage', 'StorageParentId', 'StorageId', $storage_id);

  if (length($storage_parent_id) == 0) {

    $storage_parent_id = undef;
  }

  if (defined $query->param('StorageParentId')) {

    if (length($query->param('StorageParentId')) > 0) {

      $storage_parent_id = $query->param('StorageParentId');
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
"OperationName" : "Delete storage",
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

  if ($extra_attr_yes) {

    my $gadmin_status = $self->authen->gadmin_status();

    my $storage_id_aref = [];

    for my $row (@{$storage_data}) {

      push(@{$storage_id_aref}, $row->{'StorageId'});
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
    
      if ($gadmin_status eq '1') {

        my $storage_id = $row->{'StorageId'};
        $row->{'update'} = "update/storage/$storage_id";

        if ( $not_used_id_href->{$storage_id}  ) {

          $row->{'delete'}   = "delete/storage/$storage_id";
        }
      }
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
"OperationName" : "List storage",
"Description": "List all storage locations.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='Storage' /><Storage StorageParentId='0' StorageDetails='Testing' StorageId='16' StorageBarcode='S_3304968' StorageNote='' StorageLocation='Non existing' delete='delete/storage/16' update='update/storage/16' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'Storage'}], 'Storage' : [{'StorageParentId' : '0', 'StorageDetails' : 'Testing', 'StorageId' : '16', 'delete' : 'delete/storage/16', 'StorageBarcode' : 'S_3304968', 'update' : 'update/storage/16', 'StorageLocation' : 'Non existing', 'StorageNote' : ''}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;

  my $data_for_postrun_href = {};

  my $group_id = $self->authen->group_id();

  my $sql = 'SELECT * FROM storage ';
  $sql   .= ' ORDER BY StorageId DESC';

  my ($read_storage_err, $read_storage_msg, $storage_data) = $self->list_storage(1, $sql);

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
"OperationName" : "Get storage",
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
"OperationName" : "List parentage information for items",
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
"OperationName" : "Get item parent",
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
"OperationName" : "Import items",
"Description": "Import items from a csv file formatted as a sparse matrix of item data.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='2 records of items have been inserted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : '2 records of items have been inserted successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Row (1): SpecimenId (872) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Row (1): SpecimenId (872) not found.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "CSV",
"UploadFileParameterName": "uploadfile",
"HTTPParameter": [{}],
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
  my $perm_str      = permission_phrase($group_id, 0, $gadmin_status, 'genotype');

  my $bulk_sql = 'INSERT INTO item ';
  $bulk_sql   .= '(TrialUnitSpecimenId,ItemSourceId,ContainerTypeId,SpecimenId,ScaleId,StorageId,UnitId,';
  $bulk_sql   .= 'ItemTypeId,ItemStateId,ItemBarcode,Amount,DateAdded,AddedByUserId,ItemOperation,ItemNote) ';
  $bulk_sql   .= 'VALUES ';

  my $sql;
  my $sth;

  my $geno_specimen_sql = "SELECT genotype.GenotypeId ";
  $geno_specimen_sql   .= "FROM genotype LEFT JOIN genotypespecimen ON ";
  $geno_specimen_sql   .= "genotype.GenotypeId = genotypespecimen.GenotypeId ";
  $geno_specimen_sql   .= "WHERE genotypespecimen.SpecimenId=?";

  my $cur_dt = DateTime->now( time_zone => $TIMEZONE );
  $cur_dt = DateTime::Format::MySQL->format_datetime($cur_dt);

  my $dbh_write = connect_kdb_write();

  my $row_counter = 1;
  for my $data_row (@{$data_aref}) {

    my $db_specimen_id     = '';
    my $trial_unit_spec_id = '';

    if (defined $data_row->{'TrialUnitSpecimenId'}) {

      if (length($data_row->{'TrialUnitSpecimenId'}) > 0) {

        $trial_unit_spec_id = $data_row->{'TrialUnitSpecimenId'};
        $db_specimen_id = read_cell_value($dbh_write, 'trialunitspecimen', 'SpecimenId',
                                          'TrialUnitSpecimenId', $trial_unit_spec_id);

        if (length($db_specimen_id) == 0) {

          my $err_msg = "Row ($row_counter): TrialUnitSpecimenId ($trial_unit_spec_id) not found.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
      }
    }

    my $item_src_id = '';

    if (defined $data_row->{'ItemSourceId'}) {

      if (length($data_row->{'ItemSourceId'}) > 0) {

        $item_src_id = $data_row->{'ItemSourceId'};

        if (!record_existence($dbh_write, 'contact', 'ContactId', $item_src_id)) {

          my $err_msg = "Row ($row_counter): ItemSourceId ($item_src_id) not found.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
      }
    }

    my $container_type_id = '';

    if (defined $data_row->{'ContainerTypeId'}) {

      if (length($data_row->{'ContainerTypeId'}) > 0) {

        $container_type_id = $data_row->{'ContainerTypeId'};

        if (!type_existence($dbh_write, 'container', $container_type_id)) {

          my $err_msg = "Row ($row_counter): ContainerTypeId ($container_type_id) not found or inactive.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
      }
    }

    my $specimen_id = '';

    if (defined $data_row->{'SpecimenId'}) {

      if (length($data_row->{'SpecimenId'}) > 0) {

        $specimen_id = $data_row->{'SpecimenId'};

        if (!record_existence($dbh_write, 'specimen', 'SpecimenId', $specimen_id)) {

          my $err_msg = "Row ($row_counter): SpecimenId ($specimen_id) not found.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }

        if (length($db_specimen_id) > 0) {

          if ($db_specimen_id != $specimen_id) {

            my $err_msg = "Row ($row_counter): SpecimenId ($specimen_id) with SpecimenId ($db_specimen_id) from TrialUnitSpecimenId.";
            $data_for_postrun_href->{'Error'} = 1;
            $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

            return $data_for_postrun_href;
          }
        }
      }
    }
    else {

      $specimen_id = $db_specimen_id;
    }

    if (length($specimen_id) == 0) {

      my $err_msg = "Row ($row_counter): SpecimenId is missing.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my ($geno_err, $geno_msg, $geno_data) = read_data($dbh_write, $geno_specimen_sql, [$specimen_id]);

    if ($geno_err) {

      $self->logger->debug($geno_msg);
      my $err_msg = "Unexpected Error.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    $geno_specimen_sql   .= " AND ((($perm_str) & $LINK_PERM) = $LINK_PERM)";

    $self->logger->debug("Genotype specimen permission SQL: $geno_specimen_sql");

    my ($geno_p_err, $geno_p_msg, $geno_p_data_perm) = read_data($dbh_write, $geno_specimen_sql, [$specimen_id]);

    if ($geno_p_err) {

      $self->logger->debug($geno_p_msg);
      my $err_msg = "Unexpected Error.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if (scalar(@{$geno_data}) != scalar(@{$geno_p_data_perm})) {

      my $err_msg = "Row ($row_counter): SpecimenId ($specimen_id): permission denied.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{"Message" => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $scale_id = '';

    if (defined $data_row->{'ScaleId'}) {

      if (length($data_row->{'ScaleId'}) > 0) {

        $scale_id = $data_row->{'ScaleId'};

        if (!record_existence($dbh_write, 'deviceregister', 'DeviceId', $scale_id)) {

          my $err_msg = "Row ($row_counter): ScaleId ($scale_id) not found.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
      }
    }

    my $storage_id = '';

    if (defined $data_row->{'StorageId'}) {

      if (length($data_row->{'StorageId'}) > 0) {

        $storage_id = $data_row->{'StorageId'};

        if (!record_existence($dbh_write, 'storage', 'StorageId', $storage_id)) {

          my $err_msg = "Row ($row_counter): StorageId ($storage_id) not found.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
      }
    }

    my $item_unit_id = '';

    if (defined $data_row->{'UnitId'}) {

      if (length($data_row->{'UnitId'}) > 0) {

        $item_unit_id = $data_row->{'UnitId'};

        if (!record_existence($dbh_write, 'generalunit', 'UnitId', $item_unit_id)) {

          my $err_msg = "Row ($row_counter): UnitId ($item_unit_id) not found.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
      }
    }

    if (length($item_unit_id) == 0) {

      my $err_msg = "Row ($row_counter): UnitId is missing.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $item_type_id = $data_row->{'ItemTypeId'};

    my ( $missing_err, $missing_href ) = check_missing_href( { 'ItemTypeId' => $item_type_id } );

    if ($missing_err) {

      my $err_msg = "Row ($row_counter): ItemTypeId missing";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if (!type_existence($dbh_write, 'item', $item_type_id)) {

      my $err_msg = "Row ($row_counter): ItemTypeId ($item_type_id) not found or inactive.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $item_state_id = '';

    if (defined $data_row->{'ItemStateId'}) {

      if (length($data_row->{'ItemStateId'}) > 0) {

        $item_state_id = $data_row->{'ItemStateId'};

        if (!type_existence($dbh_write, 'state', $item_state_id)) {

          my $err_msg = "Row ($row_counter): ItemStateId ($item_state_id) not found or inactive.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
      }
    }

    my $item_barcode = '';

    if (defined $data_row->{'ItemBarcode'}) {

      if (length($data_row->{'ItemBarcode'}) > 0) {

        $item_barcode = $data_row->{'ItemBarcode'};

        if (record_existence($dbh_write, 'item', 'ItemId', 'ItemBarcode', $item_barcode)) {

          my $err_msg = "Row ($row_counter): ItemBarcode ($item_barcode) already exists.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
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

        if (!record_existence($dbh_write, 'systemuser', 'UserId', $added_by_user_id)) {

          my $err_msg = "Row ($row_counter): AddedByUserId ($added_by_user_id) not found.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
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

    $date_added = qq|'$date_added'|;

    $bulk_sql .= qq|($trial_unit_spec_id,$item_src_id,$container_type_id,$specimen_id,$scale_id,$storage_id,$item_unit_id,|;
    $bulk_sql .= qq|$item_type_id,$item_state_id,$item_barcode,$amount,$date_added,$added_by_user_id,$item_operation,$item_note),|;

    $row_counter += 1;
  }

  chop($bulk_sql);      # remove excessive comma

  $self->logger->debug("Bulk SQL: $bulk_sql");

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

  $dbh_write->disconnect();

  my $info_msg      = "$nrows_inserted records of items have been inserted successfully.";
  my $info_msg_aref = [{'Message' => $info_msg}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub import_itemgroup_xml_runmode {

=pod import_itemgroup_xml_gadmin_HELP_START
{
"OperationName" : "Import item group",
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

  my $specimen_href = {};

  for my $item_group (@{$item_group_data}) {

    my $item_group_name = $item_group->{'ItemGroupName'};

    my ($missing_grpname_err, $missing_grpname_msg) = check_missing_value({ 'ItemGroupName' => $item_group_name });

    if ($missing_grpname_err) {

      my $err_msg = "ItemGroupName missing.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if (record_existence($dbh_read, 'itemgroup', 'ItemGroupName', $item_group_name)) {

      my $err_msg = "ItemGroupName ($item_group_name) already exists.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $item_source_id = '';

    if (defined($item_group->{'ItemSourceId'})) {

      $item_source_id = $item_group->{'ItemSourceId'};
    }

    if (length($item_source_id) > 0) {

      if (!record_existence($dbh_read, 'contact', 'ContactId', $item_source_id)) {

        my $err_msg = "ItemSourceId ($item_source_id) not found in contact.";

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }

    my $container_type_id = '';

    if (defined($item_group->{'ContainerTypeId'})) {

      $container_type_id = $item_group->{'ContainerTypeId'};
    }

    if (length($container_type_id) > 0) {

      if (!type_existence($dbh_read, 'container', $container_type_id)) {

        my $err_msg = "ContainerTypeId ($container_type_id) not found.";

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }

    my $scale_id = '';

    if (defined($item_group->{'ScaleId'})) {

      $scale_id = $item_group->{'ScaleId'};
    }

    if (length($scale_id) > 0) {

      if (!record_existence($dbh_read, 'deviceregister', 'DeviceRegisterId', $scale_id)) {

        my $err_msg = "ScaleId ($scale_id) not found.";

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }

    my $storage_id = '';

    if (defined($item_group->{'StorageId'})) {

      $storage_id = $item_group->{'StorageId'};
    }

    if (length($storage_id) > 0) {

      if (!record_existence($dbh_read, 'storage', 'StorageId', $storage_id)) {

        my $err_msg = "StorageId ($storage_id) not found.";

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }

    my $item_unit_id = '';

    if (defined($item_group->{'UnitId'})) {

      if (length($item_group->{'UnitId'}) > 0) {

        $item_unit_id = $item_group->{'UnitId'};
      }
    }

    if (length($item_unit_id) > 0) {

      if (!record_existence($dbh_read, 'generalunit', 'UnitId', $item_unit_id)) {

        my $err_msg = "UnitId ($item_unit_id) not found.";

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }

    my $item_state_id = '';

    if (defined($item_group->{'ItemStateId'})) {

      $item_state_id = $item_group->{'ItemStateId'};
    }

    if (length($item_state_id) > 0) {

      if (!type_existence($dbh_read, 'state', $item_state_id)) {

        my $err_msg = "ItemStateId ($item_state_id) not found.";

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }

    my $item_data = [];

    if (ref $item_group->{'Item'} eq 'HASH') {

      $item_data = [$item_group->{'Item'}];
    }
    elsif (ref $item_group->{'Item'} eq 'ARRAY') {

      $item_data = $item_group->{'Item'};
    }

    for my $item (@{$item_data}) {

      my $specimen_id      = $item->{'SpecimenId'};
      my $item_barcode     = $item->{'ItemBarcode'};
      my $item_type_id     = $item->{'ItemTypeId'};

      my ($missing_spec_id_err, $missing_spec_id_msg) = check_missing_value( {'SpecimenId'  => $specimen_id,
                                                                              'ItemBarcode' => $item_barcode,
                                                                              'ItemTypeId'  => $item_type_id,
                                                                             } );

      if ($missing_spec_id_err) {

        my $err_msg = $missing_spec_id_msg . ' missing.';

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }

      if (!record_existence($dbh_read, 'specimen', 'SpecimenId', $specimen_id)) {

        my $err_msg = "SpecimenId ($specimen_id) not found.";

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }

      if (record_existence($dbh_read, 'item', 'ItemBarcode', $item_barcode)) {

        my $err_msg = "ItemBarcode ($item_barcode) already exists.";

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }

      if (!type_existence($dbh_read, 'item', $item_type_id)) {

        my $err_msg = "ItemTypeId ($item_type_id) not found.";

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }

      if (defined($item->{'ItemStateId'})) {

        $item_state_id = $item->{'ItemStateId'};
      }

      if (length($item_state_id) > 0) {

        if (!type_existence($dbh_read, 'state', $item_state_id)) {

          my $err_msg = "ItemStateId ($item_state_id) not found.";

          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
      }

      if (defined($item->{'UnitId'})) {

        if (length($item->{'UnitId'}) > 0) {

          $item_unit_id = $item->{'UnitId'};
        }
      }

      if (length($item_unit_id) > 0) {

        if (!record_existence($dbh_read, 'generalunit', 'UnitId', $item_unit_id)) {

          my $err_msg = "UnitId ($item_unit_id) not found.";

          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
      }

      if (defined($item->{'StorageId'})) {

        $storage_id = $item->{'StorageId'};
      }

      if (length($storage_id) > 0) {

        if (!record_existence($dbh_read, 'storage', 'StorageId', $storage_id)) {

          my $err_msg = "StorageId ($storage_id) not found.";

          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
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


      $specimen_href->{$specimen_id} = 1;
    }

    if (length($item_unit_id) == 0) {

      my $err_msg = "UnitId is missing.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @geno_list;

  if (scalar(keys(%{$specimen_href})) > 0) {

    my $spec_id_str = join(',', keys(%{$specimen_href}));
    my $geno_sql = "SELECT GenotypeId FROM genotypespecimen WHERE SpecimenId IN ($spec_id_str)";

    my ($read_geno_err, $read_geno_msg, $geno_data) = read_data($dbh_read, $geno_sql, []);

    if ($read_geno_err) {

      my $err_msg = 'Unexpected Error.';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    for my $geno_rec (@{$geno_data}) {

      push(@geno_list, $geno_rec->{'GenotypeId'});
    }
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $user_id       = $self->authen->user_id();

  my $cur_dt = DateTime->now( time_zone => $TIMEZONE );
  $cur_dt    = DateTime::Format::MySQL->format_datetime($cur_dt);

  my ($is_ok, $trouble_geno_id_aref) = check_permission($dbh_read, 'genotype', 'GenotypeId',
                                                        \@geno_list, $group_id, $gadmin_status,
                                                        $READ_LINK_PERM);

  if (!$is_ok) {

    my $trouble_geno_id_str = join(',', @{$trouble_geno_id_aref});

    my $perm_err_msg = '';
    $perm_err_msg   .= "Permission denied: Group ($group_id) and Genotype ($trouble_geno_id_str).";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $perm_err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_read->disconnect();

  my $dbh_write = connect_kdb_write();

  my $sql;

  my $inserted_id          = {};
  my $return_data          = [];

  for my $item_group (@{$item_group_data}) {

    my $item_data = [];

    if (ref $item_group->{'Item'} eq 'HASH') {

      $item_data = [$item_group->{'Item'}];
    }
    elsif (ref $item_group->{'Item'} eq 'ARRAY') {

      $item_data = $item_group->{'Item'};
    }

    my @item_id_list;

    for my $item (@{$item_data}) {

      my $item_source_id     = $item_group->{'ItemSourceId'};
      my $container_type_id  = $item_group->{'ContainerTypeId'};
      my $specimen_id        = $item->{'SpecimenId'};
      my $scale_id           = $item_group->{'ScaleId'};

      my $storage_id         = $item_group->{'StorageId'};

      if (defined($item->{'StorageId'})) {

        $storage_id = $item->{'StorageId'};
      }

      my $item_unit_id       = $item_group->{'UnitId'};

      if (defined($item->{'UnitId'})) {

        $item_unit_id = $item->{'UnitId'};
      }

      my $item_type_id       = $item->{'ItemTypeId'};
      my $item_state_id      = $item_group->{'ItemStateId'};

      if (defined($item->{'ItemStateId'})) {

        $item_state_id = $item->{'ItemStateId'};
      }

      my $item_barcode       = $item->{'ItemBarcode'};
      my $amount             = $item->{'Amount'};
      my $date_added         = $cur_dt;
      my $added_by_user_id   = $user_id;
      my $item_note          = $item->{'ItemNote'};

      $sql    = 'INSERT INTO item SET ';
      $sql   .= 'ItemSourceId=?, ';
      $sql   .= 'ContainerTypeId=?, ';
      $sql   .= 'SpecimenId=?, ';
      $sql   .= 'ScaleId=?, ';
      $sql   .= 'StorageId=?, ';
      $sql   .= 'UnitId=?, ';
      $sql   .= 'ItemTypeId=?, ';
      $sql   .= 'ItemStateId=?, ';
      $sql   .= 'ItemBarcode=?, ';
      $sql   .= 'Amount=?, ';
      $sql   .= 'DateAdded=?, ';
      $sql   .= 'AddedByUserId=?, ';
      $sql   .= 'ItemNote=?';

      my $sth = $dbh_write->prepare($sql);
      $sth->execute($item_source_id, $container_type_id, $specimen_id, $scale_id, $storage_id, $item_unit_id,
                    $item_type_id, $item_state_id, $item_barcode, $amount, $date_added, $added_by_user_id,
                    $item_note);

      my $item_id = -1;
      if (!$dbh_write->err()) {

        $item_id = $dbh_write->last_insert_id(undef, undef, 'item', 'ItemId');
        $self->logger->debug("ItemId: $item_id");

        if ( !(defined($inserted_id->{'item'})) ) {

          $inserted_id->{'item'} = { 'IdField' => 'ItemId',
                                     'IdValue' => [$item_id] };
        }
        else {

          my $id_val_sofar_aref = $inserted_id->{'item'}->{'IdValue'};
          push(@{$id_val_sofar_aref}, $item_id);
          $inserted_id->{'item'}->{'IdValue'} = $id_val_sofar_aref;
        }
      }
      else {

        my ($rollback_err, $rollback_msg) = rollback_cleanup_multi($self->logger(), $dbh_write, $inserted_id);

        if ($rollback_err) {

          $self->logger->debug("Rollback error: $rollback_msg");

          my $err_msg = 'Unexpected Error.';

          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }

        my $err_msg = 'Unexpected Error.';

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
      $sth->finish();

      push(@item_id_list, $item_id);

    }

    my $item_group_name       = $item_group->{'ItemGroupName'};
    my $item_group_note       = $item_group->{'ItemGroupNote'};
    my $added_by_user         = $user_id;
    my $date_added            = $cur_dt;

    $sql  = 'INSERT INTO itemgroup SET ';
    $sql .= 'ItemGroupName=?, ';
    $sql .= 'ItemGroupNote=?, ';
    $sql .= 'AddedByUser=?, ';
    $sql .= 'DateAdded=?';

    my $item_group_sth = $dbh_write->prepare($sql);
    $item_group_sth->execute($item_group_name, $item_group_note, $added_by_user, $date_added);

    my $item_group_id = -1;
    if (!$dbh_write->err()) {

      $item_group_id = $dbh_write->last_insert_id(undef, undef, 'itemgroup', 'ItemGroupId');
      $self->logger->debug("ItemGroupId: $item_group_id");

      if ( !(defined($inserted_id->{'itemgroup'})) ) {

        $inserted_id->{'itemgroup'} = { 'IdField' => 'ItemGroupId',
                                        'IdValue' => [$item_group_id] };
      }
      else {

        my $id_val_sofar_aref = $inserted_id->{'itemgroup'}->{'IdValue'};
        push(@{$id_val_sofar_aref}, $item_group_id);
        $inserted_id->{'itemgroup'}->{'IdValue'} = $id_val_sofar_aref;
      }
    }
    else {

      my ($rollback_err, $rollback_msg) = rollback_cleanup_multi($self->logger(), $dbh_write, $inserted_id);

      if ($rollback_err) {

        $self->logger->debug("Rollback error: $rollback_msg");

        my $err_msg = 'Unexpected Error.';

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};
      
        return $data_for_postrun_href;
      }

      my $err_msg = 'Unexpected Error.';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};
      
      return $data_for_postrun_href;
    }
    $item_group_sth->finish();

    my $return_item_group_rec = {};
    $return_item_group_rec->{'ItemGroupId'}    = $item_group_id;
    $return_item_group_rec->{'ItemGroupName'}  = $item_group_name;

    my $return_item_data = [];

    $sql  = 'INSERT INTO itemgroupentry ';
    $sql .= '(ItemId,ItemGroupId) ';
    $sql .= 'VALUES ';

    my @sql_rows;

    for my $db_item_id (@item_id_list) {
    
      push(@sql_rows, "(${db_item_id}, ${item_group_id})" );

      my $return_item_rec = {'ItemId' => $db_item_id};
      push(@{$return_item_data}, $return_item_rec);
    }

    $sql .= join(',', @sql_rows);

    my $item_group_entry_sth = $dbh_write->prepare($sql);
    $item_group_entry_sth->execute();

    if (!$dbh_write->err()) {

      if ( !(defined($inserted_id->{'itemgroupentry'})) ) {

        $inserted_id->{'itemgroupentry'} = { 'IdField' => 'ItemGroupId',
                                             'IdValue' => [$item_group_id] };
      }
      else {

        my $id_val_sofar_aref = $inserted_id->{'itemgroupentry'}->{'IdValue'};
        push(@{$id_val_sofar_aref}, $item_group_id);
        $inserted_id->{'itemgroupentry'}->{'IdValue'} = $id_val_sofar_aref;
      } 
    }
    else {

      my ($rollback_err, $rollback_msg) = rollback_cleanup_multi($self->logger(), $dbh_write, $inserted_id);

      if ($rollback_err) {

        $self->logger->debug("Rollback error: $rollback_msg");

        my $err_msg = 'Unexpected Error.';

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};
      
        return $data_for_postrun_href;
      }

      my $err_msg = 'Unexpected Error.';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};
      
      return $data_for_postrun_href;
    }

    $item_group_entry_sth->finish();

    $return_item_group_rec->{'Item'} = $return_item_data;
    push(@{$return_data}, $return_item_group_rec);
  }

  $dbh_write->disconnect();

  my $return_id_data   = {};
  $return_id_data->{'ReturnId'}     = $return_data;
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
"OperationName" : "Record item log",
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
  $sql   .= "LogDateTime=?";

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($log_type_id, $system_user_id, $item_id, $log_dt);

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
"OperationName" : "Show item log",
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
"OperationName" : "Add conversionrule",
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
"OperationName" : "Delete conversionrule",
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
"OperationName" : "Update conversionrule",
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
"OperationName" : "List conversionrule",
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
"OperationName" : "Get conversionrule",
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


sub logger {

  my $self = shift;
  return $self->{logger};
}

1;
