#$Id: VirtualColumn.pm 790 2014-09-03 06:43:00Z puthick $
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

package KDDArT::DAL::VirtualColumn;

use strict;
use warnings;

BEGIN {
  use File::Spec;

  my ($volume, $current_dir, $file) = File::Spec->splitpath(__FILE__);

  $main::kddart_base_dir = "${current_dir}../../..";
}

use lib "$main::kddart_base_dir/perl-lib";

use base 'KDDArT::DAL::Transformation';

use KDDArT::DAL::Common;
use KDDArT::DAL::Security;
use CGI::Application::Plugin::Session;
use Log::Log4perl qw(get_logger :levels);
use XML::Writer;

sub setup {

  my $self = shift;

  CGI::Session->name("KDDArT_DAL_SESSID");

  __PACKAGE__->authen->init_config_parameters();
  __PACKAGE__->authen->check_login_runmodes(':all');
  __PACKAGE__->authen->check_content_type_runmodes(':all');
  __PACKAGE__->authen->check_rand_runmodes('update_vcolumn_gadmin',
                                           'add_vcolumn_gadmin',
                                           'add_general_type_gadmin',
                                           'update_general_type_gadmin',
                                           'del_general_type_gadmin',
      );
  __PACKAGE__->authen->count_session_request_runmodes(':all');
  __PACKAGE__->authen->check_signature_runmodes('update_vcolumn_gadmin',
                                                'add_vcolumn_gadmin',
                                                'add_general_type_gadmin',
                                                'update_general_type_gadmin',
                                                'del_general_type_gadmin',
      );
  __PACKAGE__->authen->check_gadmin_runmodes('update_vcolumn_gadmin',
                                             'add_vcolumn_gadmin',
                                             'add_general_type_gadmin',
                                             'add_general_type_gadmin',
                                             'update_general_type_gadmin',
                                             'del_general_type_gadmin',
      );

  $self->run_modes(
    'list_factor_table'               => 'list_factor_table_runmode',
    'list_field'                      => 'list_field_runmode',
    'update_vcolumn_gadmin'           => 'update_vcolumn_runmode',
    'get_vcolumn'                     => 'get_vcolumn_runmode',
    'add_vcolumn_gadmin'              => 'add_vcolumn_runmode',
    'get_dtd'                         => 'get_dtd_runmode',
    'add_general_type_gadmin'         => 'add_general_type_runmode',
    'list_general_type'               => 'list_general_type_runmode',
    'get_general_type'                => 'get_general_type_runmode',
    'update_general_type_gadmin'      => 'update_general_type_runmode',
    'del_general_type_gadmin'         => 'del_general_type_runmode',
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
}

sub list_factor_table_runmode {

=pod list_factor_table_HELP_START
{
"OperationName" : "List factor columns",
"Description": "Return the list of factor (virtual) column types defined in the system. Each listed entity can be extended, so additional information not present in the base data model can be stored.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><FactorTable addVcol='factortable/genotypefactor/add/vcolumn' TableName='genotypefactor' Parent='genotype'></FactorTable><FactorTable addVcol='factortable/generaltypefactor/add/vcolumn' TableName='generaltypefactor' Parent='generaltype'></FactorTable><FactorTable addVcol='factortable/projectfactor/add/vcolumn' TableName='projectfactor' Parent='project'></FactorTable></DATA>",
"SuccessMessageJSON": "{'FactorTable' : [{'addVcol' : 'factortable/genotypefactor/add/vcolumn', 'TableName' : 'genotypefactor', 'VirtualColumn' : [], 'Parent' : 'genotype'},{'addVcol' : 'factortable/generaltypefactor/add/vcolumn', 'TableName' : 'generaltypefactor', 'VirtualColumn' : [], 'Parent' : 'generaltype'},{'addVcol' : 'factortable/projectfactor/add/vcolumn', 'TableName' : 'projectfactor', 'VirtualColumn' : [], 'Parent' : 'project'}], 'RecordMeta' : [{'TagName' : 'FactorTable'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = shift;

  my $data_for_postrun_href = {};

  my $gadmin_status = $self->authen->gadmin_status();
  my $group_id      = $self->authen->group_id();

  my $dbh   = connect_kdb_read();
  my $dbh_m = connect_mdb_read();

  my %table_name2dbh;

  # get list of tables in Katmandoo database
  my $sth = $dbh->table_info();
  $sth->execute();
  
  # need to lookup how to list all tables on the Internet
  while (my @row = $sth->fetchrow_array() ) {

    # check the Internet why table name is column number 3
    $table_name2dbh{$row[2]} = $dbh;
  }
  $sth->finish();

  # get list of tables in marker database
  $sth = $dbh_m->table_info();
  $sth->execute();

  while (my @row = $sth->fetchrow_array() ) {

    # check the Internet why table name is column number 3
    $table_name2dbh{$row[2]} = $dbh_m;
  }
  $sth->finish();

  my $factor_data_aref = [];

  for my $table_name (keys(%table_name2dbh)) {

    if ($table_name =~ /(.+)factor$/) {

      my $parent_table = $1;

      my $sql = 'SELECT factor.*, '; 
      $sql   .= 'systemgroup.SystemGroupName ';
      $sql   .= 'FROM factor LEFT JOIN systemgroup ON ';
      $sql   .= 'factor.OwnGroupId = systemgroup.SystemGroupId ';
      $sql   .= 'WHERE TableNameOfFactor=?';

      my $factor_sth = $dbh->prepare($sql);
      $factor_sth->execute($table_name);

      if (!$dbh->err()) {

        my $factor_data = $factor_sth->fetchall_arrayref({});

        my $ftable_attr = { 'TableName'   => $table_name,
                            'Parent'      => $parent_table, 
        };

        if ($gadmin_status eq '1') {

          $ftable_attr->{'addVcol'} = "factortable/$table_name/add/vcolumn";
        }

        my $vcol_aref = [];

        my $factor_id_aref      = [];
        my $factor_alias_lookup = {};

        for my $factor_row (@{$factor_data}) {

          push(@{$factor_id_aref}, $factor_row->{'FactorId'});
        }

        my $chk_id_err        = 0;
        my $chk_id_msg        = '';
        my $used_id_href      = {};
        my $not_used_id_href  = {};

        if (scalar(@{$factor_id_aref}) > 0) {

          my $factor_alias_sql = 'SELECT FactorId, FactorAliasId, FactorAliasName ';
          $factor_alias_sql   .= 'FROM factoralias ';
          $factor_alias_sql   .= 'WHERE FactorId IN (' . join(',', @{$factor_id_aref}) . ')';

          my ($read_falias_err, $read_falias_msg, $factor_alias_data) = read_data($dbh, $factor_alias_sql, []);

          if ($read_falias_err) {

            $self->logger->debug("Read factor alias failed: $read_falias_msg");

            $data_for_postrun_href->{'Error'} = 1;
            $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

            return $data_for_postrun_href;
          }

          for my $falias_row (@{$factor_alias_data}) {

            my $factor_id = $falias_row->{'FactorId'};

            if (defined $factor_alias_lookup->{$factor_id}) {

              my $factor_alias_aref = $factor_alias_lookup->{$factor_id};
              delete($falias_row->{'FactorId'});
              push(@{$factor_alias_aref}, $falias_row);
              $factor_alias_lookup->{$factor_id} = $factor_alias_aref;
            }
            else {

              delete($falias_row->{'FactorId'});
              $factor_alias_lookup->{$factor_id} = [$falias_row];
            }
          }

          my $dbh_record_exist = $table_name2dbh{$table_name};

          my $chk_table_aref = [{'TableName' => $table_name, 'FieldName' => 'FactorId'}];

          ($chk_id_err, $chk_id_msg,
           $used_id_href, $not_used_id_href) = id_existence_bulk($dbh_record_exist, $chk_table_aref, $factor_id_aref);

          if ($chk_id_err) {

            $self->logger->debug("Check id existence error: $chk_id_msg");

            $data_for_postrun_href->{'Error'} = 1;
            $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

            return $data_for_postrun_href;
          }
        }

        for my $factor_row (@{$factor_data}) {

          my $factor_id         = $factor_row->{'FactorId'};
          my $vcol_own_group_id = $factor_row->{'OwnGroupId'};
          my $is_vcol_public    = $factor_row->{'Public'};

          if (defined $factor_alias_lookup->{$factor_id}) {

            my $alias_data = $factor_alias_lookup->{$factor_id};

            my $alias_aref = [];

            for my $alias (@{$alias_data}) {

              if ( ($gadmin_status eq '1') && 
                   (($group_id eq $vcol_own_group_id) || $is_vcol_public) ) {

                my $alias_id = $alias->{'FactorAliasId'};
                $alias->{'update'}   = "update/vcolumnalias/$alias_id";
                $alias->{'delete'}   = "delete/vcolumnalias/$alias_id";
              }

              push(@{$alias_aref}, $alias);
            }

            $factor_row->{'Alias'} = $alias_aref;
          }

          if ( ($gadmin_status eq '1') && 
               (($group_id eq $vcol_own_group_id) || $is_vcol_public) ) {

            $factor_row->{'update'}     = "update/vcolumn/$factor_id";

            if ( $not_used_id_href->{$factor_id} ) {

              $factor_row->{'delete'}   = "delete/vcolumn/$factor_id";
              $factor_row->{'addAlias'} = "vcolumn/$factor_id/add/alias";
            }
          }

          push(@{$vcol_aref}, $factor_row);
        }

        $ftable_attr->{'VirtualColumn'} = $vcol_aref;
        push(@{$factor_data_aref}, $ftable_attr);
      }
      else {

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

        return $data_for_postrun_href;
      }

      $factor_sth->finish();
    }
  }

  $dbh->disconnect();
  $dbh_m->disconnect();

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'FactorTable' => $factor_data_aref,
                                           'RecordMeta'  => [{'TagName' => 'FactorTable'}],
  };

  return $data_for_postrun_href;
}

sub list_field_runmode {

=pod list_field_HELP_START
{
"OperationName" : "List fields for a table",
"Description": "Return detailed list of fields for a table with data definitions and requirements.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><SCol Required='1' ColSize='255' Name='GenotypeName' DataType='varchar' /><SCol Required='1' ColSize='11' Name='GenusId' DataType='integer' /><SCol Required='0' ColSize='255' Name='SpeciesName' DataType='varchar' /><SCol Required='0' ColSize='32' Name='GenotypeAcronym' DataType='varchar' /><SCol Required='1' ColSize='10' Name='OriginId' DataType='integer' /><SCol Required='1' ColSize='1' Name='CanPublishGenotype' DataType='tinyint' /><SCol Required='0' ColSize='32' Name='GenotypeColor' DataType='varchar' /><SCol Required='0' ColSize='6000' Name='GenotypeNote' DataType='varchar' /><SCol Required='1' ColSize='11' Name='OwnGroupId' DataType='integer' /><SCol Required='1' ColSize='11' Name='AccessGroupId' DataType='integer' /><SCol Required='1' ColSize='4' Name='OwnGroupPerm' DataType='tinyint' /><SCol Required='1' ColSize='4' Name='AccessGroupPerm' DataType='tinyint' /><SCol Required='1' ColSize='4' Name='OtherPerm' DataType='tinyint' /><RecordMeta TagName='SCol' /></DATA>",
"SuccessMessageJSON": "{'SCol' : [{'Required' : 1, 'DataType' : 'varchar', 'Name' : 'GenotypeName', 'ColSize' : 255},{'Required' : 1, 'DataType' : 'integer', 'Name' : 'GenusId', 'ColSize' : 11},{'Required' : 0, 'DataType' : 'varchar', 'Name' : 'SpeciesName', 'ColSize' : 255},{'Required' : 0, 'DataType' : 'varchar', 'Name' : 'GenotypeAcronym', 'ColSize' : 32},{'Required' : 1, 'DataType' : 'integer', 'Name' : 'OriginId', 'ColSize' : 10},{'Required' : 1, 'DataType' : 'tinyint', 'Name' : 'CanPublishGenotype', 'ColSize' : 1},{'Required' : 0, 'DataType' : 'varchar', 'Name' : 'GenotypeColor', 'ColSize' : 32},{'Required' : 0, 'DataType' : 'varchar', 'Name' : 'GenotypeNote', 'ColSize' : 6000},{'Required' : 1, 'DataType' : 'integer', 'Name' : 'OwnGroupId', 'ColSize' : 11},{'Required' : 1, 'DataType' : 'integer', 'Name' : 'AccessGroupId', 'ColSize' : 11},{'Required' : 1, 'DataType' : 'tinyint', 'Name' : 'OwnGroupPerm', 'ColSize' : 4},{'Required' : 1, 'DataType' : 'tinyint', 'Name' : 'AccessGroupPerm', 'ColSize' : 4},{'Required' : 1, 'DataType' : 'tinyint', 'Name' : 'OtherPerm', 'ColSize' : 4}], 'RecordMeta' : [{'TagName' : 'SCol'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"URLParameter": [{"ParameterName": "tname", "Description": "Table name in KDDart databases"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self         = shift;
  my $parent_table = $self->param('tname');

  my $data_for_postrun_href = {};

  if ($parent_table =~ /\s+/) {

    my $err_msg = "Error: table name ($parent_table) contains spaces.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $pure_gis_table = 0;
  my $table_with_loc = 0;

  my $dbh_gis = connect_gis_read();
  my $tbl_info_sth = $dbh_gis->table_info();
  $tbl_info_sth->execute();

  while( my @gis_table = $tbl_info_sth->fetchrow_array() ) {

    if ($gis_table[2] eq $parent_table) {

      $pure_gis_table = 1;
      last;
    }
    elsif ($gis_table[2] eq "${parent_table}loc") {

      $table_with_loc = 1;
    }
  }

  $tbl_info_sth->finish();

  my $vcol_aref = [];
  my $scol_aref = [];
  my $mcol_aref = [];
  my $lcol_aref = [];

  my $rec_meta_aref = [];

  if ($pure_gis_table) {

    my ($gis_sfield_err, $gis_sfield_msg, $gis_sfield_aref, $gis_pkey) = get_static_field($dbh_gis,
                                                                                          $parent_table);

    if ($gis_sfield_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    $scol_aref = $gis_sfield_aref;

    push(@{$rec_meta_aref}, {'TagName' => 'SCol'});
  }
  else {

    my $factor_table = $parent_table . 'factor';

    # genotypemarkermetaX uses the virtual column concept 
    # its actual table structure is different.

    if ($parent_table eq 'genotypemarkermetaX') {

       $factor_table = $parent_table;
    }

    my $dbh   = connect_kdb_read();
    my $dbh_m = connect_mdb_read();

    my $sql = 'SELECT FactorId, FactorName, FactorCaption, ';
    $sql   .= 'FactorDescription, FactorDataType, ';
    $sql   .= 'IF(CanFactorHaveNull=0,1,0) AS Required, ';
    $sql   .= 'FactorValueMaxLength, FactorUnit ';
    $sql   .= 'FROM factor ';
    $sql   .= 'WHERE TableNameOfFactor=?';
    
    my $sth = $dbh->prepare($sql);
    $sth->execute($factor_table);
    
    my $vcol_data = [];

    if (!$dbh->err()) {

      my $array_ref = $sth->fetchall_arrayref({});

      if (!$sth->err()) {

        $vcol_data = $array_ref;
      }
      else {
        
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

        return $data_for_postrun_href;
      }
    }
    else {
      
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }
    
    $sth->finish();

    if (scalar(@{$vcol_data}) > 0) {

      push(@{$rec_meta_aref}, {'TagName' => 'VCol'});
    }
    
    $vcol_aref = $vcol_data;

    my $static_field_aref = [];
    my $pkey              = [];

    my ($k_sfield_err, $k_sfield_msg, $k_sfield_aref, $k_pkey) = get_static_field($dbh,
                                                                                  $parent_table);
    
    if ($k_sfield_err) {

      # this table is not in the main database, maybe it is in the marker database.
      my ($m_sfield_err, $m_sfield_msg, $m_sfield_aref, $m_pkey) = get_static_field($dbh_m,
                                                                                    $parent_table);

      if ($m_sfield_err) {
      
        my $err_msg = "Table ($parent_table) does not exist.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
      else {

        $static_field_aref = $m_sfield_aref;
        $pkey = $m_pkey;
      }
    }
    else {

      $static_field_aref = $k_sfield_aref;
      $pkey = $k_pkey;
    }
    
    my @primary_key_names = @{$pkey};
    
    $scol_aref = $static_field_aref;

    if (scalar(@{$static_field_aref}) > 0) {

      push(@{$rec_meta_aref}, {'TagName' => 'SCol'});
    }
    
    my $many2many_info = $M2M_RELATION;
    
    if ($many2many_info->{$parent_table}) {
      
      my $m2m_field_aref = [];
      for my $m2m_table (@{$many2many_info->{$parent_table}}) {
        
        my @m2m_pkey_names = $dbh->primary_key( undef, undef, $m2m_table );
        
        $sql = "SELECT * FROM $m2m_table LIMIT 1";
        $sth = $dbh->prepare($sql);
        $sth->execute();
        
        if ($dbh->err()) {
          
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

          return $data_for_postrun_href;
        }
        
        my $m2m_nfield = $sth->{'NUM_OF_FIELDS'};
        
        for (my $i = 0; $i < $m2m_nfield; $i++) {
          
          my $m2m_fieldname = $sth->{'NAME'}->[$i];
          
          if (scalar(@m2m_pkey_names) == 1) {
            
            if ($m2m_fieldname eq $m2m_pkey_names[0]) {
              
              next;
            }
          }
          
          if (scalar(@primary_key_names) == 1) {
            
            if ($m2m_fieldname eq $primary_key_names[0]) {
              
              next;
            }
          }
          
          my $m2m_required = 1;
          
          if ($sth->{'NULLABLE'}->[$i] eq '1') {
            
            $m2m_required = 0;
          }
          else {
          
            $m2m_required = 1;
          }

          my $m2m_datatype   = $sth->{'TYPE'}->[$i];
          my @m2m_type_info  = $dbh->type_info([$m2m_datatype]);
          my $m2m_dtype_name = $m2m_type_info[0]->{'TYPE_NAME'};

          my $m2m_field    = {};
          $m2m_field->{'Name'}      = $m2m_fieldname;
          $m2m_field->{'Required'}  = $m2m_required;
          $m2m_field->{'TableName'} = $m2m_table;
          $m2m_field->{'DataType'}  = $m2m_dtype_name;
          
          push(@{$m2m_field_aref}, $m2m_field);
        }
        $sth->finish();
      }

      $mcol_aref = $m2m_field_aref;

      if (scalar(@{$m2m_field_aref}) > 0) {

        push(@{$rec_meta_aref}, {'TagName' => 'MCol'});
      }
    }
    
    $dbh->disconnect();
    $dbh_m->disconnect();

    if ($table_with_loc) {

      my $loc_table = $parent_table . 'loc';
      my $loc_field = $parent_table . 'location';

      $sql  = 'SELECT type ';
      $sql .= 'FROM geography_columns ';
      $sql .= 'WHERE f_table_name=? AND f_geography_column=?';

      $sth = $dbh_gis->prepare($sql);
      $sth->execute($loc_table, $loc_field);

      my $loc_geo_type = '';
      $sth->bind_col(1, \$loc_geo_type);
      $sth->fetch();
      $sth->finish();

      push(@{$lcol_aref}, {'Name' => 'Longitude'});
      push(@{$lcol_aref}, {'Name' => 'Latitude'});

      my $lcol_href = {'Type'      => $loc_geo_type,
                       'Name'      => $loc_field,
                       'Required'  => 1,
                       'TableName' => $loc_table,
      };

      if (lc($parent_table) eq 'contact') {

        $lcol_href->{'Required'} = 0;
      }

      push(@{$lcol_aref}, $lcol_href);

      if (scalar(@{$lcol_aref}) > 0) {
      
        push(@{$rec_meta_aref}, {'TagName' => 'LCol'});
      }
    }

    # area to revived ends
  }

  $dbh_gis->disconnect();

  $data_for_postrun_href->{'Data'} = {};

  if (scalar(@{$scol_aref}) > 0) {

    $data_for_postrun_href->{'Data'}->{'SCol'} = $scol_aref;
  }

  if (scalar(@{$vcol_aref}) > 0) {

    $data_for_postrun_href->{'Data'}->{'VCol'} = $vcol_aref;
  }

  if (scalar(@{$mcol_aref}) > 0) {

    $data_for_postrun_href->{'Data'}->{'MCol'} = $mcol_aref;
  }
  
  if (scalar(@{$lcol_aref}) > 0) {

    $data_for_postrun_href->{'Data'}->{'LCol'} = $lcol_aref;
  }
    
  $data_for_postrun_href->{'Error'}                = 0;
  $data_for_postrun_href->{'Data'}->{'RecordMeta'} = $rec_meta_aref;

  return $data_for_postrun_href;
}

sub update_vcolumn_runmode {

=pod update_vcolumn_gadmin_HELP_START
{
"OperationName" : "Update virtual column",
"Description": "Update definition of virtual column specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "factor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='VirtualColumn (19) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'VirtualColumn (19) has been updated successfully.'}]}",
"ErrorMessageXML": [{"NameAlreadyExists": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error FactorName='VirtualColumn (Postcode1) already exists.' /></DATA>"}],
"ErrorMessageJSON": [{"NameAlreadyExists": "{'Error' : [{'FactorName' : 'VirtualColumn (Postcode1) already exists.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing FactorId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $vcol_id       = $self->param('id');

  # Generic required field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = { 'TableNameOfFactor' => 1,
                     'OwnGroupId'        => 1
  };

  my ($get_scol_err, $get_scol_msg, $scol_data, $pkey_data) = get_static_field($dbh_read, 'factor');

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

  # Finish generic required field checking

  my $dbh_write = connect_kdb_write();

  my $vcol_name = $query->param('FactorName');

  my $vcol_caption = read_cell_value($dbh_write, 'factor', 'FactorCaption', 'FactorId', $vcol_id);

  if (defined $query->param('FactorCaption')) {

    $vcol_caption = $query->param('FactorCaption');
  }

  my $vcol_desc = read_cell_value($dbh_write, 'factor', 'FactorDescription', 'FactorId', $vcol_id);

  if (defined $query->param('FactorDescription')) {

    $vcol_desc = $query->param('FactorDescription');
  }

  my $vcol_datatype     = $query->param('FactorDataType');
  my $vcol_nullable     = $query->param('CanFactorHaveNull');
  my $vcol_maxlen       = $query->param('FactorValueMaxLength');

  my $vcol_unit = read_cell_value($dbh_write, 'factor', 'FactorUnit', 'FactorId', $vcol_id);

  if (defined $query->param('FactorUnit')) {

    if (length($query->param('FactorUnit')) > 0) {

      $vcol_unit = $query->param('FactorUnit');
    }
  }

  my $vcol_public       = $query->param('Public');

  my $vcol_validation_rule = read_cell_value($dbh_write, 'factor', 'FactorValidRule', 'FactorId', $vcol_id);

  if (defined $query->param('FactorValidRule')) {
    
    if (length($query->param('FactorValidRule')) > 0) {

      $vcol_validation_rule = $query->param('FactorValidRule');
    }
  }

  my $vcol_validation_err_msg = read_cell_value($dbh_write, 'factor', 'FactorValidRuleErrMsg', 'FactorId', $vcol_id);

  if (defined $query->param('FactorValidRuleErrMsg')) {

    if (length($query->param('FactorValidRuleErrMsg')) > 0) {

      $vcol_validation_err_msg = $query->param('FactorValidRuleErrMsg');
    }
  }

  if ($vcol_name =~ /\s+/) {

    my $err_msg = "VirtualColumn ($vcol_name) cannot contain space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($datatype_err, $datatype_href) = check_datatype_href( {'FactorDataType' => $vcol_datatype} );

  if ($datatype_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$datatype_href]};

    return $data_for_postrun_href;
  }

  my ($unsigned_int_err, $unsigned_int_href) = is_unsigned_int_href( {'FactorValueMaxLength' => $vcol_maxlen} );

  if ($unsigned_int_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$unsigned_int_href]};

    return $data_for_postrun_href;
  }

  my $chk_facname_sql = 'SELECT FactorId FROM factor WHERE FactorId<>? AND FactorName=?';

  my ($read_facname_err, $db_factor_id) = read_cell($dbh_write, $chk_facname_sql, [$vcol_id, $vcol_name]);

  if ($read_facname_err) {

    $self->logger->debug("Check if the factor name already exists failed");

    my $msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_factor_id) > 0) {

    my $err_msg = "VirtualColumn ($vcol_name) already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'FactorName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $vcol_existence = 0;
  my $owner_group_id = -99;
  my $is_public      = -99;

  my $sql = '';
  $sql    = 'SELECT FactorId, OwnGroupId, Public ';
  $sql   .= 'FROM factor ';
  $sql   .= 'WHERE FactorId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($vcol_id);

  if (!$dbh_write->err()) {

    my $data_href = $sth->fetchall_hashref('FactorId');
    if (!$sth->err()) {

      if ($data_href->{$vcol_id}->{'FactorId'}) {

        $vcol_existence = 1;
        $owner_group_id = $data_href->{$vcol_id}->{'OwnGroupId'};
        $is_public      = $data_href->{$vcol_id}->{'Public'};
      }
    }
    else {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }
  }
  else {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  if ( !$vcol_existence ) {

    my $err_msg = "VirtualColumn ($vcol_id) does not exist.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();

  if ( $is_public != 1 ) {

    if ( $group_id != $owner_group_id ) {

      my $msg = "VirtualColumn ($vcol_id) permission denied.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $msg}]};

      return $data_for_postrun_href;
    }
  }

  my ($compatible, $comp_msg) = $self->check_data_compatibility($dbh_write,
                                                                $vcol_id,
                                                                $vcol_datatype,
                                                                $vcol_maxlen);

  if (!$compatible) {
 
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $comp_msg}]};

    return $data_for_postrun_href;
  }

  $sql    = 'UPDATE factor SET ';
  $sql   .= 'FactorName = ?, ';
  $sql   .= 'FactorCaption = ?, ';
  $sql   .= 'FactorDescription = ?, ';
  $sql   .= 'FactorDataType = ?, ';
  $sql   .= 'CanFactorHaveNull = ?, ';
  $sql   .= 'FactorValueMaxLength = ?, ';
  $sql   .= 'FactorUnit = ?, ';
  $sql   .= 'Public = ?, ';
  $sql   .= 'FactorValidRule=?, ';
  $sql   .= 'FactorValidRuleErrMsg=? ';
  $sql   .= 'WHERE FactorId=?';

  $sth = $dbh_write->prepare($sql);
  $sth->execute($vcol_name, $vcol_caption, $vcol_desc, $vcol_datatype,
                $vcol_nullable, $vcol_maxlen, $vcol_unit,
                $vcol_public, $vcol_validation_rule, $vcol_validation_err_msg,
                $vcol_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "VirtualColumn ($vcol_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub check_data_compatibility {

  my $self      = $_[0];
  my $dbh       = $_[1];
  my $factor_id = $_[2];
  my $datatype  = $_[3];
  my $maxlen    = $_[4];

  my $sql = '';
  $sql   .= 'SELECT FactorId, FactorDataType, FactorValueMaxLength, TableNameOfFactor ';
  $sql   .= 'FROM factor ';
  $sql   .= 'WHERE FactorId = ?';

  my $sth = $dbh->prepare($sql);
  $sth->execute($factor_id);

  my $factor_info_href = $sth->fetchall_hashref('FactorId');
  $sth->finish();

  my $compatible = 1;
  my $comp_msg   = q{};

  my $datatype_conv_compatibility = {'STRING-STRING'     => 1,
                                     'INTEGER-INTEGER'   => 1,
                                     'INTEGER-STRING'    => 1,
  };

  my $datatype2regex              = {'INTEGER'          => '^[-|+]{0,1}\d+$', };

  my $old_datatype = $factor_info_href->{"$factor_id"}->{'FactorDataType'};
  my $old_maxlen   = $factor_info_href->{"$factor_id"}->{'FactorValueMaxLength'};

  $self->logger->debug("Old datatype: $old_datatype");
  $self->logger->debug("New datatype: $datatype");

  my $is_trivial_conversion = 0;
  if ( $datatype_conv_compatibility->{uc($old_datatype) . '-' . uc($datatype)} ) {

    $is_trivial_conversion = $datatype_conv_compatibility->{uc($old_datatype) . '-' . uc($datatype)};
  }

  if ( (!$is_trivial_conversion) || $old_maxlen > $maxlen ) {

    my $factor_table = $factor_info_href->{"$factor_id"}->{'TableNameOfFactor'};

    $sql  = "SELECT * FROM $factor_table ";
    $sql .= 'WHERE FactorId = ?';

    $sth = $dbh->prepare($sql);
    $sth->execute($factor_id);
    
    my $row_aref = [];
    my $regex = '';
    if ($datatype2regex->{uc($datatype)}) {

      $regex = $datatype2regex->{uc($datatype)};
    }

    my $factor_value;
    my $record_id;
    while( $row_aref = $sth->fetchrow_arrayref() ) {

      $factor_value = $row_aref->[2];
      $record_id    = $row_aref->[0];
      if (length($regex) > 0) {
        
        if ( !($factor_value =~ /$regex/) ) {

          $compatible = 0;
          $comp_msg  = "Record ($record_id, $factor_id, $factor_value) ";
          $comp_msg .= "in $factor_table not compatible with $datatype.";
          last;
        }
      }

      if (length($factor_value) > $maxlen) {

        $comp_msg  = "Record ($record_id, $factor_id, $factor_value) ";
        $comp_msg .= "in $factor_table longer than new max length ($maxlen).";
        $compatible = 0;
        last;
      }
    }

    $sth->finish();
  }

  return ($compatible, $comp_msg);
}

sub get_vcolumn_runmode {

=pod get_vcolumn_HELP_START
{
"OperationName" : "Get virtual column",
"Description": "Return detailed information about a virtual column definition specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='VirtualColumn' /><VirtualColumn SystemGroupName='admin' Public='1' FactorValidRule='' CanFactorHaveNull='1' FactorDescription='Number from 1 to 10 rating the coldest temperature' FactorId='20' FactorDataType='STRING' FactorValidRuleErrMsg='' FactorCaption='Cold Climate Zone' OwnGroupId='0' FactorUnit='' FactorValueMaxLength='2' TableNameOfFactor='contactfactor' FactorName='ColdClimateZone' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'VirtualColumn'}], 'VirtualColumn' : [{'Public' : '1', 'SystemGroupName' : 'admin', 'CanFactorHaveNull' : '1', 'FactorValidRule' : '', 'FactorId' : '20', 'FactorDescription' : 'Number from 1 to 10 rating the coldest temperature', 'FactorDataType' : 'STRING', 'FactorCaption' : 'Cold Climate Zone', 'FactorValidRuleErrMsg' : '', 'FactorName' : 'ColdClimateZone', 'TableNameOfFactor' : 'contactfactor', 'FactorValueMaxLength' : '2', 'FactorUnit' : '', 'OwnGroupId' : '0'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Virtual Column (21) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Virtual Column (21) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing FactorId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self    = shift;
  my $vcol_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  my $vcol_exist = record_existence($dbh, 'factor', 'FactorId', $vcol_id);

  if (!$vcol_exist) {

    my $err_msg = "Virtual Column ($vcol_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = '';
  $sql   .= 'SELECT factor.*, ';
  $sql   .= 'systemgroup.SystemGroupName ';
  $sql   .= 'FROM factor LEFT JOIN systemgroup ';
  $sql   .= 'ON factor.OwnGroupId = systemgroup.SystemGroupId ';
  $sql   .= 'WHERE FactorId = ?';

  my $sth = $dbh->prepare($sql);
  $sth->execute($vcol_id);

  my $vcol_data = [];
  if (!$dbh->err()) {

    my $array_ref = $sth->fetchall_arrayref({});

    if ( !$sth->err() ) {

      $vcol_data = $array_ref;
    }
    else {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }
  }
  else {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  $data_for_postrun_href->{'Error'} = 0;
  $data_for_postrun_href->{'Data'}  = {'VirtualColumn' => $vcol_data,
                                       'RecordMeta'    => [{'TagName' => 'VirtualColumn'}],
  };

  return $data_for_postrun_href;
}

sub add_vcolumn_runmode {

=pod add_vcolumn_gadmin_HELP_START
{
"OperationName" : "Add virtual column",
"Description": "Add a new virtual column to one of the factor tables.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "factor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='21' ParaName='FactorId' /><Info Message='Virtual column (HeatClimateZone) has been added to contactfactor successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '21', 'ParaName' : 'FactorId'}], 'Info' : [{'Message' : 'Virtual column (HeatClimateZone) has been added to contactfactor successfully.'}]}",
"ErrorMessageXML": [{"NameAlreadyExists": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error FactorName='VirtualColumn (HeatClimateZone) already exists.' /></DATA>"}],
"ErrorMessageJSON": [{"NameAlreadyExists": "{'Error' : [{'FactorName' : 'VirtualColumn (HeatClimateZone) already exists.'}]}"}],
"URLParameter": [{"ParameterName": "tname", "Description": "Factor table name like contactfactor, genotypefactor, sitefactor, etc."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self   = $_[0];

  my $data_for_postrun_href = {};
  
  my $query  = $self->query();
  my $ftable = lc($self->param('tname'));

  if (!($ftable =~ /^[a-z]+factor$/)) {

    my $err_msg = "$ftable is not a virtual column data table.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  # Generic required field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = { 'TableNameOfFactor' => 1,
                     'OwnGroupId'        => 1
  };

  my ($get_scol_err, $get_scol_msg, $scol_data, $pkey_data) = get_static_field($dbh_read, 'factor');

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

  # Finish generic required field checking

  my $vcol_name         = $query->param('FactorName');

  my $vcol_caption      = '';

  if (defined $query->param('FactorCaption')) {

    $vcol_caption = $query->param('FactorCaption');
  }

  my $vcol_desc         = '';

  if (defined $query->param('FactorDescription')) {

    $vcol_desc = $query->param('FactorDescription');
  }

  my $vcol_datatype     = $query->param('FactorDataType');
  my $vcol_nullable     = $query->param('CanFactorHaveNull');
  my $vcol_maxlen       = $query->param('FactorValueMaxLength');

  my $vcol_unit         = '';

  if (defined $query->param('FactorUnit')) {

    $vcol_unit = $query->param('FactorUnit');
  }

  my $vcol_public       = $query->param('Public');

  my $group_id = $self->authen->group_id();
  my $owner    = $group_id;

  my $vcol_validation_rule = '';

  if (defined $query->param('FactorValidRule')) {
    
    $vcol_validation_rule = $query->param('FactorValidRule');
  }

  my $vcol_validation_err_msg = '';

  if (defined $query->param('FactorValidRuleErrMsg')) {

    $vcol_validation_err_msg = $query->param('FactorValidRuleErrMsg');
  }

  if ($vcol_name =~ /\s+/) {

    my $err_msg = "VirtualColumn ($vcol_name) cannot contain space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'FactorName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($datatype_err, $datatype_href) = check_datatype_href( {'FactorDataType' => $vcol_datatype} );

  if ($datatype_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$datatype_href]};

    return $data_for_postrun_href;
  }

  my ($unsigned_int_err, $unsigned_int_href) = is_unsigned_int_href( {'FactorValueMaxLength' => $vcol_maxlen} );

  if ($unsigned_int_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$unsigned_int_href]};

    return $data_for_postrun_href;
  }

  my $dbh_write = connect_kdb_write();

  my $factor_exist_status = record_existence($dbh_write, 'factor', 'FactorName', $vcol_name);

  if ($factor_exist_status) {

    my $err_msg = "VirtualColumn ($vcol_name) already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'FactorName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $ftable_existence = table_existence($dbh_write, $ftable);

  if (!$ftable_existence) {

    my $dbh_m = connect_mdb_read();

    $ftable_existence = table_existence($dbh_m, $ftable);

    $dbh_m->disconnect();
  }

  if (!$ftable_existence) {

    my $err_msg = "$ftable does not exist.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'INSERT INTO factor SET ';
  $sql   .= 'FactorName=?, ';
  $sql   .= 'FactorCaption=?, ';
  $sql   .= 'FactorDescription=?, ';
  $sql   .= 'TableNameOfFactor=?, ';
  $sql   .= 'FactorDataType=?, ';
  $sql   .= 'CanFactorHaveNull=?, ';
  $sql   .= 'FactorValueMaxLength=?, ';
  $sql   .= 'FactorUnit=?, ';
  $sql   .= 'OwnGroupId=?, ';
  $sql   .= 'Public=?, ';
  $sql   .= 'FactorValidRule=?, ';
  $sql   .= 'FactorValidRuleErrMsg=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($vcol_name, $vcol_caption, $vcol_desc,
                $ftable, $vcol_datatype, $vcol_nullable,
                $vcol_maxlen, $vcol_unit, $owner, $vcol_public,
                $vcol_validation_rule, $vcol_validation_err_msg
      );

  my $vcol_id = -1;
  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  else {

    $vcol_id = $dbh_write->last_insert_id(undef, undef, 'factor', 'FactorId');
  }

  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg       = "Virtual column ($vcol_name) has been added to $ftable successfully.";
  my $info_msg_aref  = [{'Message' => $info_msg}];
  my $return_id_aref = [{'Value' => "$vcol_id", 'ParaName' => 'FactorId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref,
                                           'ReturnId'  => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub get_dtd_runmode {

=pod get_dtd_HELP_START
{
"OperationName" : "Get DTD",
"Description": "Get Document Type Definition for the table. This interface returns the content of the DTD file of the requrested table if the DTD is present.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<!ELEMENT DATA ( genotypespecimen+ ) ><!ELEMENT genotypespecimen EMPTY ><!ATTLIST genotypespecimen GenotypeId NMTOKEN #REQUIRED ><!ATTLIST genotypespecimen GenotypeSpecimenType NMTOKEN #IMPLIED >",
"SuccessMessageJSON": "<!ELEMENT DATA ( genotypespecimen+ ) ><!ELEMENT genotypespecimen EMPTY ><!ATTLIST genotypespecimen GenotypeId NMTOKEN #REQUIRED ><!ATTLIST genotypespecimen GenotypeSpecimenType NMTOKEN #IMPLIED >",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Table (specimen): no dtd file found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Table (specimen): no dtd file found.'}]}"}],
"URLParameter": [{"ParameterName": "tname", "Description": "Table name which may have DTD defined."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $table_name = $self->param('tname');

  my $data_for_postrun_href = {};
  
  my $dtd_file = "${DTD_PATH}/${table_name}.dtd";

  if ( !(-e $dtd_file) ) {

    my $err_msg = "Table ($table_name): no dtd file found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dtd = '';

  open(DTD_FH, "<$dtd_file") or die "Can't read $dtd_file: $!";
  while( my $line = <DTD_FH> ) {

    $dtd .= $line;
  }
  close(DTD_FH);

  return $dtd;
}

sub add_general_type_runmode {

=pod add_general_type_gadmin_HELP_START
{
"OperationName" : "Add type",
"Description": "Add a new entry into type dictionary for a class.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "generaltype",
"KDDArTFactorTable": "generaltypefactor",
"SkippedField": ["Class"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='224' ParaName='TypeId' /><Info Message='GeneralType (224) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '225', 'ParaName' : 'TypeId'}], 'Info' : [{'Message' : 'GeneralType (225) has been added successfully.'}]}",
"ErrorMessageXML": [{"NameAlreadyExists": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Type (Research Station) for class (site) already exists.' /></DATA>"}],
"ErrorMessageJSON": [{"NameAlreadyExists": "{'Error' : [{'Message' : 'Type (Research Station) for class (site) already exists.'}]}"}],
"URLParameter": [{"ParameterName": "class", "Description": "Value from a predefined list of values for classification of the type. This list of values is site, item, container, deviceregister, trial, trialevent, sample, specimengroup, state, parent, itemparent, genotypespecimen, markerstate, markerquality, workflow, project, itemlog, plate, genmap, multimedia, tissue, genotypealias, genparent, genotypealiasstatus, traitgroup, unittype and multilocation."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'Class' => 1};

  my ($get_scol_err, $get_scol_msg, $scol_data, $pkey_data) = get_static_field($dbh_read, 'generaltype');

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

  my $class            = $self->param('class');
  my $type_name        = $query->param('TypeName');
  
  my $is_active        = '1';

  if (defined $query->param('IsTypeActive')) {

    if (length($query->param('IsTypeActive')) > 0) {

      $is_active = $query->param('IsTypeActive');
    }
  }

  my $type_note        = '';
  if (defined $query->param('TypeNote')) {

    $type_note = $query->param('TypeNote');
  }

  if ( $is_active !~ /^(1|0){1}$/ ) {

    my $err_msg = "IsTypeActive ($is_active): invalid";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'IsTypeActive' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $class_lookup = { 'site'                 => 1,
                       'item'                 => 1,
                       'container'            => 1,
                       'deviceregister'       => 1,
                       'trial'                => 1,
                       'trialevent'           => 1,
                       'sample'               => 1,
                       'specimengroup'        => 1,
                       'state'                => 1,
                       'parent'               => 1,
                       'itemparent'           => 1,
                       'plate'                => 1,
                       'tissue'               => 1,
                       'markerstate'          => 1,
                       'markerquality'        => 1,
                       'workflow'             => 1,
                       'project'              => 1,
                       'itemlog'              => 1,
                       'genmap'               => 1,
                       'multimedia'           => 1,
                       'genotypealias'        => 1,
                       'genparent'            => 1,
                       'genotypealiasstatus'  => 1,
                       'genotypespecimen'     => 1,
                       'traitgroup'           => 1,
                       'unittype'             => 1,
                       'multilocation'        => 1,
  };

  if (!($class_lookup->{$class})) {

    my $err_msg = "Class ($class) not supported.";
    return $self->_set_error($err_msg);
  }

  my $dbh_k_read = connect_kdb_read();

  my $sql = 'SELECT TypeId FROM generaltype WHERE Class=? AND TypeName=?';
  my $read_err;
  my $check_type_id = '';

  ($read_err, $check_type_id) = read_cell($dbh_k_read, $sql, [$class, $type_name]);

  if (length($check_type_id) > 0) {

    my $err_msg = "Type ($type_name) for class ($class) already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql    = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='generaltypefactor'";

  my $vcol_data = $dbh_k_read->selectall_hashref($sql, 'FactorId');

  my $vcol_param_data = {};
  my $vcol_len_info   = {};
  my $vcol_param_data_maxlen = {};
  for my $vcol_id (keys(%{$vcol_data})) {

    my $vcol_param_name = "VCol_${vcol_id}";
    my $vcol_value      = $query->param($vcol_param_name);
    if ($vcol_data->{$vcol_id}->{'CanFactorHaveNull'} != 1) {

      $vcol_param_data->{$vcol_param_name} = $vcol_value;
    }
    $vcol_len_info->{$vcol_param_name} = $vcol_data->{$vcol_id}->{'FactorValueMaxLength'};
    $vcol_param_data_maxlen->{$vcol_param_name} = $vcol_value;
  }

  my ($vcol_missing_err, $vcol_missing_msg) = check_missing_value( $vcol_param_data );

  if ($vcol_missing_err) {

    $vcol_missing_msg = $vcol_missing_msg . ' missing';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $vcol_missing_msg}]};

    return $data_for_postrun_href;
  }

  my ($vcol_maxlen_err, $vcol_maxlen_msg) = check_maxlen($vcol_param_data_maxlen, $vcol_len_info);

  if ($vcol_maxlen_err) {

    $vcol_maxlen_msg = $vcol_maxlen_msg . ' longer than maximum length.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $vcol_maxlen_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $type_id = -1;
  my $dbh_k_write = connect_kdb_write();

  $sql  = 'INSERT INTO generaltype SET ';
  $sql .= 'Class=?, ';
  $sql .= 'TypeName=?, ';
  $sql .= 'TypeNote=?, ';
  $sql .= 'IsTypeActive=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($class, $type_name, $type_note, $is_active);

  if (!$dbh_k_write->err()) {

    $type_id = $dbh_k_write->last_insert_id(undef, undef, 'generaltype', 'TypeId');
  }
  else {

    return $self->_set_error('Unexpected Error.');
  }
  $sth->finish();

  for my $vcol_id (keys(%{$vcol_data})) {

    my $factor_value = $query->param('VCol_' . "$vcol_id");

    if (length($factor_value) > 0) {

      $sql  = 'INSERT INTO generaltypefactor SET ';
      $sql .= 'TypeId=?, ';
      $sql .= 'FactorId=?, ';
      $sql .= 'FactorValue=?';
      my $factor_sth = $dbh_k_write->prepare($sql);
      $factor_sth->execute($type_id, $vcol_id, $factor_value);
      
      if ($dbh_k_write->err()) {
        
        return $self->_set_error('Unexpected Error.');
      }

      $factor_sth->finish();
    }
  }

  $dbh_k_write->disconnect();

  my $info_msg_aref  = [{'Message' => "GeneralType ($type_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$type_id", 'ParaName' => 'TypeId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_general_type {

  my $self              = $_[0];
  my $extra_attr_yes    = $_[1];
  my $sql               = $_[2];
  my $where_para_aref   = [];

  if (defined $_[3]) {

    $where_para_aref   = $_[3];
  }

  my $err = 0;
  my $msg = '';

  my $data_aref = [];

  my $class2chk_table_lookup = { 'site'                => [{'TableName' => 'site' => 'FieldName' => 'SiteTypeId'}],
                                 'item'                => [{'TableName' => 'item', 'FieldName' => 'ItemTypeId'}],
                                 'container'           => [{'TableName' => 'item', 'FieldName' => 'ContainerTypeId'}],
                                 'deviceregister'      => [{'TableName' => 'deviceregister', 'FieldName' => 'DeviceTypeId'}],
                                 'trial'               => [{'TableName' => 'trial', 'FieldName' => 'TrialTypeId'}],
                                 'trialevent'          => [{'TableName' => 'trialevent', 'FieldName' => 'EventTypeId'}],
                                 'sample'              => [{'TableName' => 'samplemeasurement', 'FieldName' => 'SampleTypeId'}],
                                 'specimengroup'       => [{'TableName' => 'specimengroup', 'FieldName' => 'SpecimenGroupTypeId'}],
                                 'state'               => [{'TableName' => 'item', 'FieldName' => 'ItemStateId'}],
                                 'parent'              => [{'TableName' => 'pedigree', 'FieldName' => 'ParentType'}],
                                 'itemparent'          => [{'TableName' => 'itemparent', 'FieldName' => 'ItemParentType'}],
                                 'genotypespecimen'    => [{'TableName' => 'genotypespecimen', 'FieldName' => 'GenotypeSpecimenType'}],
                                 'markerstate'         => [{'TableName' => 'analysisgroup', 'FieldName' => 'MarkerStateType'}],
                                 'markerquality'       => [{'TableName' => 'analysisgroup', 'FieldName' => 'MarkerQualityType'}],
                                 'workflow'            => [{'TableName' => 'workflow', 'FieldName' => 'WorkflowType'}],
                                 'project'             => [{'TableName' => 'project', 'FieldName' => 'TypeId'}],
                                 'itemlog'             => [{'TableName' => 'itemlog', 'FieldName' => 'LogTypeId'}],
                                 'plate'               => [{'TableName' => 'plate', 'FieldName' => 'PlateType'}],
                                 'genmap'              => [{'TableName' => 'markermap', 'FieldName' => 'MapType'}],
                                 'multimedia'          => [{'TableName' => 'multimedia', 'FieldName' => 'FileType'}],
                                 'tissue'              => [{'TableName' => 'extract', 'FieldName' => 'Tissue'}],
                                 'genotypealias'       => [{'TableName' => 'genotypealias', 'FieldName' => 'GenotypeAliasType'}],
                                 'genparent'           => [{'TableName' => 'genpedigree', 'FieldName' => 'GenParentType'}],
                                 'genotypealiasstatus' => [{'TableName' => 'genotypealias', 'FieldName' => 'GenotypeAliasStatus'}],
                                 'traitgroup'          => [{'TableName' => 'trait', 'FieldName' => 'TraitGroupTypeId'}],
                                 'unittype'            => [{'TableName' => 'itemunit', 'FieldName' => 'UnitTypeId'}],
                                 'multilocation'       => [],
  };

  my $marker_class_lookup = {'markerstate'       => 1,
                             'markerquality'     => 1,
                             'plate'             => 1,
                             'genmap'            => 1,
                             'tissue'            => 1,
  };

  my $dbh = connect_kdb_read();

  ($err, $msg, $data_aref) = read_data($dbh, $sql, $where_para_aref);

  if ($err) {

    return ($err, $msg, []);
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $extra_attr_type_data = [];

  if ($extra_attr_yes && ($gadmin_status eq '1')) {

    my $dbh_m = connect_mdb_read();

    my $type_id_aref = [];
    my $type_class   = '';

    for my $type_row (@{$data_aref}) {

      push(@{$type_id_aref}, $type_row->{'TypeId'});
      $type_class = $type_row->{'Class'};
    }

    if (scalar(@{$type_id_aref}) > 0 && length($type_class) > 0) {

      my $right_dbh = $dbh;

      if ($marker_class_lookup->{$type_class}) {

        $right_dbh = $dbh_m;
      }

      my $chk_id_err        = 0;
      my $chk_id_msg        = '';
      my $used_id_href      = {};
      my $not_used_id_href  = {};

      if ( !(defined $class2chk_table_lookup->{$type_class}) ) {

        if (scalar(@{$class2chk_table_lookup->{$type_class}}) > 0) {

          my $chk_table_aref = $class2chk_table_lookup->{$type_class};

          ($chk_id_err, $chk_id_msg,
           $used_id_href, $not_used_id_href) = id_existence_bulk($right_dbh, $chk_table_aref, $type_id_aref);

          if ($chk_id_err) {

            $self->logger->debug("Check id existence error: $chk_id_msg");
            $err = 1;
            $msg = $chk_id_msg;

            return ($err, $msg, []);
          }
        }
      }

      for my $type_row (@{$data_aref}) {

        my $type_id       = $type_row->{'TypeId'};
        my $class         = $type_row->{'Class'};
    
        if ($gadmin_status eq '1') {
      
          $type_row->{'update'} = "update/type/$class/$type_id";
        
          if ( $not_used_id_href->{$type_id} ) {
        
            $type_row->{'delete'}   = "delete/type/$class/$type_id";
          }
        }
    
        push(@{$extra_attr_type_data}, $type_row);
      }
    }
    $dbh_m->disconnect();
  }
  else {

    $extra_attr_type_data = $data_aref;
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_type_data);
}

sub list_general_type_runmode {

=pod list_general_type_HELP_START
{
"OperationName" : "List types",
"Description": "List dictionary of types for a class and status.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='GeneralType' /><GeneralType IsTypeActive='0' TypeNote='' TypeId='225' TypeName='Farm' Class='site' update='update/type/site/225' /><GeneralType IsTypeActive='1' TypeNote='' TypeId='224' TypeName='Research Station' Class='site' update='update/type/site/224' /></DATA>",
"SuccessMessageJSON": "{'VCol' : [], 'RecordMeta' : [{'TagName' : 'GeneralType'}], 'GeneralType' : [{'IsTypeActive' : '0', 'TypeId' : '225', 'TypeName' : 'Farm', 'Class' : 'site', 'update' : 'update/type/site/225', 'TypeNote' : ''},{'IsTypeActive' : '1', 'TypeId' : '224', 'TypeName' : 'Research Station', 'Class' : 'site', 'update' : 'update/type/site/224', 'TypeNote' : ''}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Class (contact) not supported.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Class (contact) not supported.'}]}"}],
"URLParameter": [{"ParameterName": "class", "Description": "Value from a predefined list of values for classification of the type. This list of values is site, item, container, deviceregister, trial, trialevent, sample, specimengroup, state, parent, itemparent, genotypespecimen, markerstate, markerquality, workflow, project, itemlog, plate, genmap, multimedia, tissue, genotypealias, genparent, genotypealiasstatus, traitgroup, unittype and multilocation."}, {"ParameterName": "status", "Description": "Status filtering value which can be 'active', 'inactive' or 'all'."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self     = shift;
  my $class    = $self->param('class');
  my $status   = lc($self->param('status'));

  my $status_lookup = { 'active'   => 'IsTypeActive=1',
                        'inactive' => 'IsTypeActive=0',
                        'all'      => '1=1',
  };

  if ( !(defined $status_lookup->{$status}) ) {

    my $err_msg = "Status ($status) not supported";
    return $self->_set_error($err_msg);
  }

  my $data_for_postrun_href = {};

  my $class_lookup = { 'site'                 => 1,
                       'item'                 => 1,
                       'container'            => 1,
                       'deviceregister'       => 1,
                       'trial'                => 1,
                       'trialevent'           => 1,
                       'sample'               => 1,
                       'specimengroup'        => 1,
                       'state'                => 1,
                       'parent'               => 1,
                       'itemparent'           => 1,
                       'plate'                => 1,
                       'tissue'               => 1,
                       'markerstate'          => 1,
                       'markerquality'        => 1,
                       'workflow'             => 1,
                       'project'              => 1,
                       'itemlog'              => 1,
                       'genmap'               => 1,
                       'multimedia'           => 1,
                       'genotypealias'        => 1,
                       'genparent'            => 1,
                       'genotypealiasstatus'  => 1,
                       'genotypespecimen'     => 1,
                       'traitgroup'           => 1,
                       'unittype'             => 1,
                       'multilocation'        => 1,
                       'any'                  => 1,
  };

  if (!($class_lookup->{$class})) {

    my $err_msg = "Class ($class) not supported.";
    return $self->_set_error($err_msg);
  }

  my $dbh = connect_kdb_read();
  my $field_list = ['generaltype.*', 'VCol*'];
  
  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $field_list, 'generaltype',
                                                                        'TypeId', '');
  $dbh->disconnect();

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    return $self->_set_error($err_msg);
  }

  my $sql_where_arg = [];

  if ( lc($class) eq 'any' ) {

    $sql   .= ' HAVING ' . $status_lookup->{$status} . ' ';
    $sql   .= ' ORDER BY Class ASC, generaltype.TypeId DESC';
  }
  else {

    $sql   .= ' HAVING Class=? AND ' . $status_lookup->{$status} . ' ';
    $sql   .= ' ORDER BY generaltype.TypeId DESC';

    push(@{$sql_where_arg}, $class);
  }

  $self->logger->debug("SQL with VCol: $sql");

  my ($read_site_err, $read_site_msg, $type_data) = $self->list_general_type(1, $sql, $sql_where_arg);

  if ($read_site_err) {

    return $self->_set_error('Unexpected Error.');
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'GeneralType' => $type_data,
                                           'VCol'        => $vcol_list,
                                           'RecordMeta'  => [{'TagName' => 'GeneralType'}],
  };

  return $data_for_postrun_href;
}

sub get_general_type_runmode {

=pod get_general_type_HELP_START
{
"OperationName" : "Get type",
"Description": "Get detailed type definition for a class and specified id in the class.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='GeneralType' /><GeneralType IsTypeActive='0' TypeId='224' TypeName='Research Station' Class='site' update='update/type/site/224' TypeNote='' /></DATA>",
"SuccessMessageJSON": "{'VCol' : [], 'RecordMeta' : [{'TagName' : 'GeneralType'}], 'GeneralType' : [{'IsTypeActive' : '0', 'TypeId' : '224', 'TypeName' : 'Research Station', 'Class' : 'site', 'update' : 'update/type/site/224', 'TypeNote' : ''}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Type (228) for class (site) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Type (228) for class (site) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing GeneralTypeId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self     = shift;
  my $class    = $self->param('class');
  my $type_id  = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  my $check_sql = 'SELECT TypeId FROM generaltype WHERE Class=? AND TypeId=?';
  my $read_err;
  my $check_type_id = '';

  ($read_err, $check_type_id) = read_cell($dbh, $check_sql, [$class, $type_id]);

  if (length($check_type_id) == 0) {

    my $err_msg = "Type ($type_id) for class ($class) not found.";
    return $self->_set_error($err_msg);
  }

  my $field_list = ['generaltype.*', 'VCol*'];
  
  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $field_list, 'generaltype',
                                                                        'TypeId', '');
  $dbh->disconnect();

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    return $self->_set_error($err_msg);
  }

  $sql   .= ' HAVING Class=? AND TypeId=? ';
  $sql   .= ' ORDER BY generaltype.TypeId DESC';

  $self->logger->debug("SQL with VCol: $sql");

  my ($read_site_err, $read_site_msg, $type_data) = $self->list_general_type(1, $sql, [$class, $type_id]);

  if ($read_site_err) {

    return $self->_set_error('Unexpected Error.');
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'GeneralType' => $type_data,
                                           'VCol'        => $vcol_list,
                                           'RecordMeta'  => [{'TagName' => 'GeneralType'}],
  };

  return $data_for_postrun_href;
}

sub update_general_type_runmode {

=pod update_general_type_gadmin_HELP_START
{
"OperationName" : "Update type",
"Description": "Update type definition for a class and specified id within the class.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "generaltype",
"KDDArTFactorTable": "generaltypefactor",
"SkippedField": ["Class"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='GeneralType (224) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'GeneralType (224) has been updated successfully.'}]}",
"ErrorMessageXML": [{"NameAlreadyExists": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Type (Farm) for class (site) already exists.' /></DATA>"}],
"ErrorMessageJSON": [{"NameAlreadyExists": "{'Error' : [{'Message' : 'Type (Farm) for class (site) already exists.'}]}"}],
"URLParameter": [{"ParameterName": "class", "Description": "Value from a predefined list of values for classification of the type. This list of values is site, item, container, deviceregister, trial, trialevent, sample, specimengroup, state, parent, itemparent, genotypespecimen, markerstate, markerquality, workflow, project, itemlog, plate, genmap, multimedia, tissue, genotypealias, genparent, genotypealiasstatus, traitgroup, unittype and multilocation."}, {"ParameterName": "id", "Description": "Existing GeneralTypeId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'Class' => 1};

  my ($get_scol_err, $get_scol_msg, $scol_data, $pkey_data) = get_static_field($dbh_read, 'generaltype');

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

  my $class            = $self->param('class');
  my $type_id          = $self->param('id');

  my $type_name        = $query->param('TypeName');

  my $dbh_k_read = connect_kdb_read();

  my $type_note        = read_cell_value($dbh_k_read, 'generaltype', 'TypeNote', 'TypeId', $type_id);
  my $is_active        = read_cell_value($dbh_k_read, 'generaltype', 'IsTypeActive', 'TypeId', $type_id);

  if (defined $query->param('IsTypeActive')) {

    if (length($query->param('IsTypeActive')) > 0) {

      $is_active = $query->param('IsTypeActive');
    }
  }

  if (length($is_active) == 0) {

    $is_active = '1';
  }

  if ( $is_active !~ /^(1|0){1}$/ ) {

    my $err_msg = "IsTypeActive ($is_active): invalid";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'IsTypeActive' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (defined $query->param('TypeNote')) {

    $type_note = $query->param('TypeNote');
  }

  my $sql = 'SELECT TypeId FROM generaltype WHERE Class=? AND TypeId=?';
  my $read_err;
  my $check_type_id = '';

  ($read_err, $check_type_id) = read_cell($dbh_k_read, $sql, [$class, $type_id]);

  if (length($check_type_id) == 0) {

    my $err_msg = "Type ($type_id) for class ($class) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql = 'SELECT TypeId FROM generaltype WHERE Class=? AND TypeName=? AND TypeId<>?';
  $read_err;
  $check_type_id = '';

  ($read_err, $check_type_id) = read_cell($dbh_k_read, $sql, [$class, $type_name, $type_id]);

  if (length($check_type_id) > 0) {

    my $err_msg = "Type ($type_name) for class ($class) already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql    = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='generaltypefactor'";

  my $vcol_data = $dbh_k_read->selectall_hashref($sql, 'FactorId');

  my $vcol_param_data = {};
  my $vcol_len_info   = {};
  my $vcol_param_data_maxlen = {};
  for my $vcol_id (keys(%{$vcol_data})) {

    my $vcol_param_name = "VCol_${vcol_id}";
    my $vcol_value      = $query->param($vcol_param_name);
    if ($vcol_data->{$vcol_id}->{'CanFactorHaveNull'} != 1) {

      $vcol_param_data->{$vcol_param_name} = $vcol_value;
    }
    $vcol_len_info->{$vcol_param_name} = $vcol_data->{$vcol_id}->{'FactorValueMaxLength'};
    $vcol_param_data_maxlen->{$vcol_param_name} = $vcol_value;
  }

  my ($vcol_missing_err, $vcol_missing_msg) = check_missing_value( $vcol_param_data );

  if ($vcol_missing_err) {

    $vcol_missing_msg = $vcol_missing_msg . ' missing';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $vcol_missing_msg}]};

    return $data_for_postrun_href;
  }

  my ($vcol_maxlen_err, $vcol_maxlen_msg) = check_maxlen($vcol_param_data_maxlen, $vcol_len_info);

  if ($vcol_maxlen_err) {

    $vcol_maxlen_msg = $vcol_maxlen_msg . ' longer than maximum length.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $vcol_maxlen_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  $sql  = 'UPDATE generaltype SET ';
  $sql .= 'TypeName=?, ';
  $sql .= 'TypeNote=?, ';
  $sql .= 'IsTypeActive=? ';
  $sql .= 'WHERE Class=? AND TypeId=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($type_name, $type_note, $is_active, $class, $type_id);

  if ($dbh_k_write->err()) {

    $self->logger->debug('Unexpected error.');
    return $self->_set_error('Unexpected Error.');
  }
  $sth->finish();

  for my $vcol_id (keys(%{$vcol_data})) {

    if (defined $query->param('VCol_' . "$vcol_id")) {

      my $factor_value = $query->param('VCol_' . "$vcol_id");

      $sql  = 'SELECT Count(*) ';
      $sql .= 'FROM generaltypefactor ';
      $sql .= 'WHERE TypeId=? AND FactorId=?';

      my ($read_err, $count) = read_cell($dbh_k_write, $sql, [$type_id, $vcol_id]);

      if (length($factor_value) > 0) {

        if ($count > 0) {

          $sql  = 'UPDATE generaltypefactor SET ';
          $sql .= 'FactorValue=? ';
          $sql .= 'WHERE TypeId=? AND FactorId=?';

          my $factor_sth = $dbh_k_write->prepare($sql);
          $factor_sth->execute($factor_value, $type_id, $vcol_id);
      
          if ($dbh_k_write->err()) {

            $self->logger->debug('Unexpected error.');
            return $self->_set_error('Unexpected Error.');
          }
          $factor_sth->finish();
        }
        else {

          $sql  = 'INSERT INTO generaltypefactor SET ';
          $sql .= 'TypeId=?, ';
          $sql .= 'FactorId=?, ';
          $sql .= 'FactorValue=?';
          my $factor_sth = $dbh_k_write->prepare($sql);
          $factor_sth->execute($type_id, $vcol_id, $factor_value);
          
          if ($dbh_k_write->err()) {
        
            $self->logger->debug('Unexpected error.');
            return $self->_set_error('Unexpected Error.');
          }
          $factor_sth->finish();
        }
      }
      else {

        if ($count > 0) {

          $sql  = 'DELETE FROM generaltypefactor ';
          $sql .= 'WHERE TypeId=? AND FactorId=?';

          my $factor_sth = $dbh_k_write->prepare($sql);
          $factor_sth->execute($type_id, $vcol_id);
      
          if ($dbh_k_write->err()) {
        
            $self->logger->debug('Unexpected error.');
            return $self->_set_error('Unexpected Error.');
          }
          $factor_sth->finish();
        }
      }
    }
  }

  $dbh_k_write->disconnect();

  my $info_msg_aref  = [{'Message' => "GeneralType ($type_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub del_general_type_runmode {

=pod del_general_type_gadmin_HELP_START
{
"OperationName" : "Delete type",
"Description": "Delete type definition for a class and specified id within the class. Type can be deleted only if not attached to any lower level related record.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='GeneralType (224) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{ 'Info' : [{ 'Message' : 'GeneralType (225) has been deleted successfully.'} ]}",
"ErrorMessageXML": [{"IdUsed": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Type (9) used in trial table.' /></DATA>"}],
"ErrorMessageJSON": [{"IdUsed": "{ 'Error' : [{ 'Message' : 'Type (9) used in trial table.'} ]}"}],
"URLParameter": [{"ParameterName": "class", "Description": "Value from a predefined list of values for classification of the type. This list of values is site, item, container, deviceregister, trial, trialevent, sample, specimengroup, state, parent, itemparent, genotypespecimen, markerstate, markerquality, workflow, project, itemlog, plate, genmap, multimedia, tissue, genotypealias, genparent, genotypealiasstatus, traitgroup, unittype and multilocation."}, {"ParameterName": "id", "Description": "Existing GeneralTypeId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $class      = $self->param('class');
  my $type_id    = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_k_read = connect_kdb_read();

  my $sql = 'SELECT TypeId FROM generaltype WHERE Class=? AND TypeId=?';
  my $read_err;
  my $check_type_id = '';

  ($read_err, $check_type_id) = read_cell($dbh_k_read, $sql, [$class, $type_id]);

  if (length($check_type_id) == 0) {

    my $err_msg = "Type ($type_id) for class ($class) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my @fk_relationship = (
    { 'table' => 'trial',             'field' => 'TrialTypeId',          'value' => $type_id },
    { 'table' => 'item',              'field' => 'ContainerTypeId',      'value' => $type_id },
    { 'table' => 'item',              'field' => 'ItemTypeId',           'value' => $type_id },
    { 'table' => 'item',              'field' => 'ItemStateId',          'value' => $type_id },
    { 'table' => 'pedigree',          'field' => 'ParentType',           'value' => $type_id },
    { 'table' => 'site',              'field' => 'SiteTypeId',           'value' => $type_id },
    { 'table' => 'specimengroup',     'field' => 'SpecimenGroupTypeId',  'value' => $type_id },
    { 'table' => 'itemparent',        'field' => 'ItemParentType',       'value' => $type_id },
    { 'table' => 'deviceregister',    'field' => 'DeviceTypeId',         'value' => $type_id },
    { 'table' => 'samplemeasurement', 'field' => 'SampleTypeId',         'value' => $type_id },
    { 'table' => 'trialevent',        'field' => 'EventTypeId',          'value' => $type_id },
    { 'table' => 'workflow',          'field' => 'WorkflowType',         'value' => $type_id },
    { 'table' => 'genotypespecimen',  'field' => 'GenotypeSpecimenType', 'value' => $type_id },
    { 'table' => 'project',           'field' => 'TypeId',               'value' => $type_id },
    { 'table' => 'itemlog',           'field' => 'LogTypeId',            'value' => $type_id },
    { 'table' => 'multimedia',        'field' => 'FileType',             'value' => $type_id },
      );

  for my $relation (@fk_relationship) {

    my $fk_table = $relation->{'table'};
    my $is_type_id_used = record_existence($dbh_k_read, $fk_table,
                                           $relation->{'field'}, $relation->{'value'});
    if ($is_type_id_used) {

      my $err_msg = "Type ($type_id) used in $fk_table table.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  $dbh_k_read->disconnect();

  my $dbh_m = connect_mdb_read();

  @fk_relationship = (
    { 'table' => 'extract',           'field' => 'Tissue',              'value' => $type_id },
    { 'table' => 'plate',             'field' => 'PlateType',           'value' => $type_id },
    { 'table' => 'markermap',         'field' => 'MapType',             'value' => $type_id },
    { 'table' => 'analysisgroup',     'field' => 'MarkerStateType',     'value' => $type_id },
    { 'table' => 'analysisgroup',     'field' => 'MarkerQualityType',   'value' => $type_id },
      );

  for my $relation (@fk_relationship) {

    my $fk_table = $relation->{'table'};
    my $is_type_id_used = record_existence($dbh_m, $fk_table,
                                           $relation->{'field'}, $relation->{'value'});
    if ($is_type_id_used) {

      my $err_msg = "Type ($type_id) used in $fk_table table.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  $dbh_m->disconnect();

  my $dbh_k_write = connect_kdb_write();

  $sql = 'DELETE FROM generaltypefactor WHERE TypeId=?';
  my $sth = $dbh_k_write->prepare($sql);

  $sth->execute($type_id);

  if ($dbh_k_write->err()) {

    $self->logger->debug('Unexpected error.');
    return $self->_set_error('Unexpected Error.');
  }

  $sth->finish();

  $sql = 'DELETE FROM generaltype WHERE TypeId=?';
  $sth = $dbh_k_write->prepare($sql);

  $sth->execute($type_id);

  if ($dbh_k_write->err()) {

    $self->logger->debug('Unexpected error.');
    return $self->_set_error('Unexpected Error.');
  }

  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref = [{'Message' => "GeneralType ($type_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub _set_error {

		my ( $self, $error_message ) = @_;
		return {
				'Error' => 1,
				'Data'	=> { 'Error' => [{'Message' => $error_message || 'Unexpected error.'}] }
		};
}

sub logger {

  my $self = shift;
  return $self->{logger};
}


1;
