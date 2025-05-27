#$Id$
#$Author$

# Copyright (c) 2025, Diversity Arrays Technology, All rights reserved.

# Author    : Puthick Hok
# Created   : 02/06/2010
# Modified  :
# Purpose   :
#
#

package KDDArT::DAL::VirtualColumn;

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

use KDDArT::DAL::Common;
use KDDArT::DAL::Security;
use CGI::Application::Plugin::Session;
use Log::Log4perl qw(get_logger :levels);
use XML::Writer;


sub setup {

  my $self = shift;

  CGI::Session->name($COOKIE_NAME);

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
    'count_groupby'                   => 'count_groupby_runmode',
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
}

sub list_factor_table_runmode {

=pod list_factor_table_HELP_START
{
"OperationName": "List factor columns",
"Description": "Return the list of factor (virtual) column types defined in the system. Each listed entity can be extended, so additional information not present in the base data model can be stored.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><FactorTable addVcol='factortable/genotypefactor/add/vcolumn' TableName='genotypefactor' Parent='genotype'><VirtualColumn Public='0' SystemGroupName='admin' CanFactorHaveNull='1' FactorValidRule='' FactorId='34' FactorDescription='' FactorDataType='STRING' FactorValidRuleErrMsg='' FactorCaption='GenoFactor1' update='update/vcolumn/34' FactorValueMaxLength='1000' FactorUnit='' FactorName='GenoFactor1' OwnGroupId='0' TableNameOfFactor='genotypefactor'/></FactorTable><FactorTable addVcol='factortable/generaltypefactor/add/vcolumn' TableName='generaltypefactor' Parent='generaltype'><VirtualColumn Public='0' SystemGroupName='admin' CanFactorHaveNull='1' FactorValidRule='' FactorId='35' FactorDescription='' FactorDataType='STRING' FactorValidRuleErrMsg='' FactorCaption='GTFactor1' update='update/vcolumn/35' FactorValueMaxLength='1000' FactorUnit='' FactorName='GTFactor1' OwnGroupId='0' TableNameOfFactor='generaltypefactor'/></FactorTable><FactorTable addVcol='factortable/projectfactor/add/vcolumn' TableName='projectfactor' Parent='project'><VirtualColumn Public='0' SystemGroupName='admin' CanFactorHaveNull='1' FactorValidRule='' FactorId='36' FactorDescription='' FactorDataType='STRING' FactorValidRuleErrMsg='' FactorCaption='ProjectFactor1' update='update/vcolumn/36' FactorValueMaxLength='1000' FactorUnit='' FactorName='ProjectFactor1' OwnGroupId='0' TableNameOfFactor='projectfactor'/></FactorTable></DATA>",
"SuccessMessageJSON": "{'FactorTable' : [{'addVcol' : 'factortable/genotypefactor/add/vcolumn', 'TableName' : 'genotypefactor', 'VirtualColumn' : [{               'SystemGroupName' : 'admin','Public' : '0','FactorValidRule' : '','CanFactorHaveNull' : '1','FactorDescription' : '','FactorId' : '34','FactorDataType' : 'STRING','FactorCaption' : 'GenoFactor1','FactorValidRuleErrMsg' : '','FactorUnit' : '','FactorValueMaxLength' : '1000','FactorName' : 'GenoFactor1',       'OwnGroupId' : '0','TableNameOfFactor' : 'genotypefactor','update' : 'update/vcolumn/34'}], 'Parent' : 'genotype'},{'addVcol' : 'factortable/generaltypefactor/add/vcolumn', 'TableName' : 'generaltypefactor', 'VirtualColumn' : [{               'SystemGroupName' : 'admin','Public' : '0','FactorValidRule' : '','CanFactorHaveNull' : '1','FactorDescription' : '','FactorId' : '35','FactorDataType' : 'STRING','FactorCaption' : 'GTFactor1','FactorValidRuleErrMsg' : '','FactorUnit' : '','FactorValueMaxLength' : '1000','FactorName' : 'GTFactor1',       'OwnGroupId' : '0','TableNameOfFactor' : 'generaltypefactor','update' : 'update/vcolumn/35'}], 'Parent' : 'generaltype'},{'addVcol' : 'factortable/projectfactor/add/vcolumn', 'TableName' : 'projectfactor', 'VirtualColumn' : [{ 'SystemGroupName' : 'admin','Public' : '0','FactorValidRule' : '','CanFactorHaveNull' : '1','FactorDescription' : '','FactorId' : '36','FactorDataType' : 'STRING','FactorCaption' : 'ProjectFactor1','FactorValidRuleErrMsg' : '','FactorUnit' : '','FactorValueMaxLength' : '1000','FactorName' : 'ProjectFactor1',       'OwnGroupId' : '0','TableNameOfFactor' : 'projectfactor','update' : 'update/vcolumn/36'}], 'Parent' : 'project'}], 'RecordMeta' : [{'TagName' : 'FactorTable'}]}",
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
"OperationName": "List fields for a table",
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

  my $vcol_aref        = [];
  my $scol_aref        = [];
  my $mcol_aref        = [];
  my $lcol_aref        = [];
  my $primary_key_aref = [];

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

    my $dbh   = connect_kdb_read();
    my $dbh_m = connect_mdb_read();

    my $sql = 'SELECT FactorId, FactorName, FactorCaption, ';
    $sql   .= 'FactorDescription, FactorDataType, Public, ';
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

    $self->logger->debug("Get static field error message: $k_sfield_msg");

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

    foreach my $pkey_name (@primary_key_names) {

      push(@{$primary_key_aref}, {'Name' => $pkey_name});
    }

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
                       'Required'  => 0,
                       'TableName' => $loc_table,
      };

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

  if (scalar(@{$primary_key_aref}) > 0) {

    $data_for_postrun_href->{'Data'}->{'PrimaryKey'} = $primary_key_aref;
  }

  $data_for_postrun_href->{'Error'}                = 0;
  $data_for_postrun_href->{'Data'}->{'RecordMeta'} = $rec_meta_aref;

  return $data_for_postrun_href;
}

sub update_vcolumn_runmode {

=pod update_vcolumn_gadmin_HELP_START
{
"OperationName": "Update virtual column",
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

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'factor', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required field checking

  my $dbh_write = connect_kdb_write();

  my $vcol_name = $query->param('FactorName');

  my $read_vcol_sql   =  'SELECT FactorCaption, FactorDescription, FactorUnit, FactorValidRule, FactorValidRuleErrMsg ';
     $read_vcol_sql  .=  'FROM factor WHERE FactorId=? ';

  my ($r_df_val_err, $r_df_val_msg, $vcol_df_val_data) = read_data($dbh_write, $read_vcol_sql, [$vcol_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve vcolumn default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $vcol_caption              =  undef;
  my $vcol_desc                 =  undef;
  my $vcol_unit                 =  undef;
  my $vcol_validation_rule      =  undef;
  my $vcol_validation_err_msg   =  undef;

  my $nb_df_val_rec    =  scalar(@{$vcol_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve vcol default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $vcol_caption                  =  $vcol_df_val_data->[0]->{'FactorCaption'};
  $vcol_desc                     =  $vcol_df_val_data->[0]->{'FactorDescription'};
  $vcol_unit                     =  $vcol_df_val_data->[0]->{'FactorUnit'};
  $vcol_validation_rule          =  $vcol_df_val_data->[0]->{'FactorValidRule'};
  $vcol_validation_err_msg       =  $vcol_df_val_data->[0]->{'FactorValidRuleErrMsg'};


  if (defined $query->param('FactorCaption')) {

    $vcol_caption = $query->param('FactorCaption');
  }


  if (defined $query->param('FactorDescription')) {

    $vcol_desc = $query->param('FactorDescription');
  }

  my $vcol_datatype     = $query->param('FactorDataType');
  my $vcol_nullable     = $query->param('CanFactorHaveNull');
  my $vcol_maxlen       = $query->param('FactorValueMaxLength');


  if (defined $query->param('FactorUnit')) {

    if (length($query->param('FactorUnit')) > 0) {

      $vcol_unit = $query->param('FactorUnit');
    }
  }

  my $vcol_public       = $query->param('Public');


  if (defined $query->param('FactorValidRule')) {

    if (length($query->param('FactorValidRule')) > 0) {

      $vcol_validation_rule = $query->param('FactorValidRule');
    }
  }


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
"OperationName": "Get virtual column",
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
"OperationName": "Add virtual column",
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

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'factor', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required field checking

  my $vcol_name         = $query->param('FactorName');

  #check vcol name from a list of forbidden names to avoid breaking

  if (length($RESTRICTEDFACTORNAME_CFG) > 0) {
    my @restricted_names = split(/\//, $RESTRICTEDFACTORNAME_CFG);

    my $vcol_nowhite = $vcol_name;
    $vcol_nowhite =~ s/\s+//g;

    foreach my $name (@restricted_names) {
      if ($name eq $vcol_nowhite) {
        my $err_msg = "VirtualColumn ($vcol_name) cannot be used.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'FactorName' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
  }

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
"OperationName": "Get DTD",
"Description": "Get Document Type Definition for the table. This interface returns the content of the DTD file of the requested table if the DTD is present.",
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

  my $dtd_path = $ENV{DOCUMENT_ROOT} . '/' . $DTD_PATH;

  my $dtd_file = "${dtd_path}/${table_name}.dtd";

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
"OperationName": "Add type",
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
"URLParameter": [{"ParameterName": "class", "Description": "Value from a predefined list of values for classification of the type. This list of values is site, item, container, deviceregister, trial, trialevent, sample, specimengroup, state, parent, itemparent, genotypespecimen, dataset, workflow, project, itemlog, plate, genmap, multimedia, tissue, genotypealias, genparent, genotypealiasstatus, traitgroup, unittype, trialgroup and season."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};
  my $general_type_err_aref = [];
  my $general_type_err = 0;

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'Class'   => 1};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'generaltype', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

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

    push(@{$general_type_err_aref}, {'IsTypeActive' => $err_msg});
    $general_type_err = 1;
  }

  my $is_fixed = $query->param('IsFixed');

  if ( $is_fixed !~ /^(1|0){1}$/ ) {

    my $err_msg = "IsFixed ($is_fixed): invalid";

    push(@{$general_type_err_aref}, {'IsFixed' => $err_msg});
    $general_type_err = 1;
  }

  my $type_metadata = "";

  if (defined $query->param('TypeMetaData')) {
    if (length($query->param('TypeMetaData')) > 0) {
      $type_metadata = $query->param('TypeMetaData');
    }
  }


  my $class_lookup = { 'site'                 => 1,
                       'item'                 => 1,
                       'container'            => 1,
                       'deviceregister'       => 1,
                       'trial'                => 1,
                       'trialevent'           => 1,
                       'sample'               => 1,
                       'specimengroup'        => 1,
                       'specimengroupstatus'  => 1,
                       'state'                => 1,
                       'parent'               => 1,
                       'itemparent'           => 1,
                       'genotypespecimen'     => 1,
                       'markerdataset'        => 1,
                       'workflow'             => 1,
                       'project'              => 1,
                       'itemlog'              => 1,
                       'plate'                => 1,
                       'genmap'               => 1,
                       'multimedia'           => 1,
                       'tissue'               => 1,
                       'genotypealias'        => 1,
                       'genparent'            => 1,
                       'genotypealiasstatus'  => 1,
                       'traitgroup'           => 1,
                       'unittype'             => 1,
                       'trialgroup'           => 1,
                       'breedingmethod'       => 1,
                       'traitdatatype'        => 1,
                       'season'               => 1,
                       'survey'               => 1,
                       'trialunit'            => 1,
  };

  if (!($class_lookup->{$class})) {

    my $err_msg = "Class ($class) not supported.";

    push(@{$general_type_err_aref}, {'Message' => $err_msg});
    $general_type_err = 1;
  }

  my $dbh_k_read = connect_kdb_read();

  my $sql = 'SELECT TypeId FROM generaltype WHERE Class=? AND TypeName=?';
  my $read_err;
  my $check_type_id = '';

  ($read_err, $check_type_id) = read_cell($dbh_k_read, $sql, [$class, $type_name]);

  if (length($check_type_id) > 0) {

    my $err_msg = "Type ($type_name) for class ($class) already exists.";

    push(@{$general_type_err_aref}, {'TypeName' => $err_msg});
    $general_type_err = 1;
  }

  $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength, FactorValidRuleErrMsg, FactorValidRule  ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='generaltypefactor'";

  my $vcol_data = $dbh_k_read->selectall_hashref($sql, 'FactorId');

  my $vcol_param_data = {};
  my $vcol_len_info   = {};
  my $vcol_param_data_maxlen = {};
  my $pre_validate_vcol = {};

  for my $vcol_id (keys(%{$vcol_data})) {

    my $vcol_param_name = "VCol_${vcol_id}";
    my $vcol_value      = $query->param($vcol_param_name) ;
    if ($vcol_data->{$vcol_id}->{'CanFactorHaveNull'} != 1) {

      $vcol_param_data->{$vcol_param_name} = $vcol_value;
    }

    $vcol_len_info->{$vcol_param_name} = $vcol_data->{$vcol_id}->{'FactorValueMaxLength'};
    $vcol_param_data_maxlen->{$vcol_param_name} = $vcol_value;

    $pre_validate_vcol->{$vcol_param_name} = {
      'Rule' => $vcol_data->{$vcol_id}->{'FactorValidRule'},
      'Value'=> $vcol_value,
      'FactorId'=> $vcol_id,
      'RuleErrorMsg'=> $vcol_data->{$vcol_id}->{'FactorValidRuleErrMsg'},
      'CanFactorHaveNull' => $vcol_data->{$vcol_id}->{'CanFactorHaveNull'},
    };
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

  my ($vcol_error, $vcol_error_aref) = validate_all_factor_input($pre_validate_vcol);

  if ($vcol_error) {
    push(@{$general_type_err}, @{$vcol_error_aref});
    $general_type_err = 1;
  }

  if ($general_type_err != 0) {
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => $general_type_err};
    return $data_for_postrun_href;
  }

  my $type_id = -1;
  my $dbh_k_write = connect_kdb_write();

  $sql  = 'INSERT INTO generaltype SET ';
  $sql .= 'Class=?, ';
  $sql .= 'TypeName=?, ';
  $sql .= 'TypeNote=?, ';
  $sql .= 'IsTypeActive=?, ';
  $sql .= 'IsFixed=?, ' ;
  $sql .= 'TypeMetaData=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($class, $type_name, $type_note, $is_active, $is_fixed, $type_metadata);

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

  my $class2chk_table_lookup = { 'breedingmethod'      => [{'TableName' => 'breedingmethod', 'FieldName' => 'BreedingMethodTypeId'}],
                                 'deviceregister'      => [{'TableName' => 'deviceregister', 'FieldName' => 'DeviceTypeId'}],
                                 'markerdataset'       => [{'TableName' => 'dataset', 'FieldName' => 'DataSetType'}],
                                 'tissue'              => [{'TableName' => 'extract', 'FieldName' => 'Tissue'}],
                                 'unittype'            => [{'TableName' => 'generalunit', 'FieldName' => 'UnitTypeId'}],
                                 'genotypealias'       => [{'TableName' => 'genotypealias', 'FieldName' => 'GenotypeAliasType'}],
                                 'genotypealiasstatus' => [{'TableName' => 'genotypealias', 'FieldName' => 'GenotypeAliasStatus'}],
                                 'genotypespecimen'    => [{'TableName' => 'genotypespecimen', 'FieldName' => 'GenotypeSpecimenType'}],
                                 'genparent'           => [{'TableName' => 'genpedigree', 'FieldName' => 'GenParentType'}],
                                 'item'                => [{'TableName' => 'item', 'FieldName' => 'ItemTypeId'}],
                                 'state'               => [{'TableName' => 'item', 'FieldName' => 'ItemStateId'}],
                                 'container'           => [{'TableName' => 'item', 'FieldName' => 'ContainerTypeId'}],
                                 'itemlog'             => [{'TableName' => 'itemlog', 'FieldName' => 'LogTypeId'}],
                                 'itemparent'          => [{'TableName' => 'itemparent', 'FieldName' => 'ItemParentType'}],
                                 'unittype'            => [{'TableName' => 'itemunit', 'FieldName' => 'UnitTypeId'}],
                                 'genmap'              => [{'TableName' => 'markermap', 'FieldName' => 'MapType'}],
                                 'multimedia'          => [{'TableName' => 'multimedia', 'FieldName' => 'FileType'}],
                                 'project'             => [{'TableName' => 'project', 'FieldName' => 'TypeId'}],
                                 'plate'               => [{'TableName' => 'plate', 'FieldName' => 'PlateType'}],
                                 'parent'              => [{'TableName' => 'pedigree', 'FieldName' => 'ParentType'}],
                                 'site'                => [{'TableName' => 'site' => 'FieldName' => 'SiteTypeId'}],
                                 'sample'              => [{'TableName' => 'samplemeasurement', 'FieldName' => 'SampleTypeId'}],
                                 'specimengroup'       => [{'TableName' => 'specimengroup', 'FieldName' => 'SpecimenGroupTypeId'}],
                                 'specimengroupstatus' => [{'TableName' => 'specimengroup', 'FieldName' => 'SpecimenGroupStatus'}],
                                 'traitgroup'          => [{'TableName' => 'trait', 'FieldName' => 'TraitGroupTypeId'}],
                                 'traitdatatype'       => [{'TableName' => 'trait', 'FieldName' => 'TraitDataType'}],
                                 'survey'          => [{'TableName' => 'survey', 'FieldName' => 'SurveyType'}],
                                 'season'              => [{'TableName' => 'trial', 'FieldName' => 'SeasonId'}],
                                 'trial'               => [{'TableName' => 'trial', 'FieldName' => 'TrialTypeId'}],
                                 'trialevent'          => [{'TableName' => 'trialevent', 'FieldName' => 'EventTypeId'}],
                                 'trialgroup'          => [{'TableName' => 'trialgroup', 'FieldName' => 'TrialGroupType'}],
                                 'workflow'            => [{'TableName' => 'workflow', 'FieldName' => 'WorkflowType'}],
  };

  my $marker_class_lookup = {'markerdataset'     => 1,
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

        $self->logger->debug("Type class -> $type_class");


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
"OperationName": "List types",
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
"URLParameter": [{"ParameterName": "class", "Description": "Value from a predefined list of values for classification of the type. This list of values is site, item, container, deviceregister, trial, trialevent, sample, specimengroup, state, parent, itemparent, genotypespecimen, dataset, workflow, project, itemlog, plate, genmap, multimedia, tissue, genotypealias, genparent, genotypealiasstatus, traitgroup, unittype, trialgroup, traitgroup, traitdatatype and season."}, {"ParameterName": "status", "Description": "Status filtering value which can be 'active', 'inactive' or 'all'."}],
"HTTPParameter": [{"Required": 0, "Name": "Filtering", "Description": "Filtering parameter string consisting of filtering expressions which are separated by ampersand (&) which needs to be encoded if HTTP GET method is used. Each filtering expression is composed of a database field name, a filtering operator and the filtering value."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self     = shift;
  my $query    = $self->query();
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

  my $filtering_csv = '';

  if (defined $query->param('Filtering')) {

    $filtering_csv = $query->param('Filtering');
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
                       'specimengroupstatus'  => 1,
                       'state'                => 1,
                       'parent'               => 1,
                       'itemparent'           => 1,
                       'genotypespecimen'     => 1,
                       'markerdataset'        => 1,
                       'workflow'             => 1,
                       'project'              => 1,
                       'itemlog'              => 1,
                       'plate'                => 1,
                       'genmap'               => 1,
                       'multimedia'           => 1,
                       'tissue'               => 1,
                       'genotypealias'        => 1,
                       'genparent'            => 1,
                       'genotypealiasstatus'  => 1,
                       'traitgroup'           => 1,
                       'unittype'             => 1,
                       'trialgroup'           => 1,
                       'breedingmethod'       => 1,
                       'traitdatatype'        => 1,
                       'season'               => 1,
                       'survey'               => 1,
                       'any'                  => 1
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

  my $filter_field_list = ['TypeId', 'TypeName', 'TypeNote', 'IsFixed'];

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering('TypeId',
                                                                              'generaltype',
                                                                              $filtering_csv,
                                                                              $filter_field_list);

  if ($filter_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $filter_msg}]};

    return $data_for_postrun_href;
  }

  my $sql_where_arg = [];

  if (length($filter_phrase) > 0) {

    $sql =~ s/GROUP BY/ WHERE $filter_phrase GROUP BY /;

    $sql_where_arg = $where_arg;
  }

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
"OperationName": "Get type",
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
"OperationName": "Update type",
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
"URLParameter": [{"ParameterName": "class", "Description": "Value from a predefined list of values for classification of the type. This list of values is site, item, container, deviceregister, trial, trialevent, sample, specimengroup, state, parent, itemparent, genotypespecimen, dataset, workflow, project, itemlog, plate, genmap, multimedia, tissue, genotypealias, genparent, genotypealiasstatus, traitgroup, unittype, trialgroup and season."}, {"ParameterName": "id", "Description": "Existing GeneralTypeId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};
  my $general_type_err_aref = [];
  my $general_type_err = 0;

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'Class' => 1};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'generaltype', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $class            = $self->param('class');
  my $type_id          = $self->param('id');

  my $type_name        = $query->param('TypeName');
  my $is_fixed         = $query->param('IsFixed');

  my $dbh_k_read = connect_kdb_read();

  my $read_general_type_sql    =   'SELECT TypeNote, IsTypeActive, IsFixed, TypeName, TypeMetaData ';
     $read_general_type_sql   .=   'FROM generaltype WHERE TypeId=? ';

  my ($r_df_val_err, $r_df_val_msg, $general_df_val_data) = read_data($dbh_k_read, $read_general_type_sql, [$type_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve general type default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $type_note          = undef;
  my $is_active          = undef;
  my $db_is_fixed        = undef;
  my $db_type_name       = undef;
  my $type_metadata      = undef;

  my $nb_df_val_rec    =  scalar(@{$general_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve general type default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $type_note          =  $general_df_val_data->[0]->{'TypeNote'};
  $is_active          =  $general_df_val_data->[0]->{'IsTypeActive'};
  $db_is_fixed        =  $general_df_val_data->[0]->{'IsFixed'};
  $db_type_name       =  $general_df_val_data->[0]->{'TypeName'};
  $type_metadata      =   $general_df_val_data->[0]->{'TypeMetaData'};


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

    push(@{$general_type_err_aref}, {'IsTypeActive' => $err_msg});
    $general_type_err = 1;
  }

  if ( $is_fixed !~ /^(1|0){1}$/ ) {

    my $err_msg = "IsFixed ($is_fixed): invalid";

    push(@{$general_type_err_aref}, {'IsFixed' => $err_msg});
    $general_type_err = 1;
  }

  if (defined $query->param('TypeNote')) {

    $type_note = $query->param('TypeNote');
  }

  if (defined $query->param('TypeMetaData')) {
    if (length($query->param('TypeMetaData')) > 0) {
      $type_metadata = $query->param('TypeMetaData');
    }
  }

  my $sql = 'SELECT TypeId FROM generaltype WHERE Class=? AND TypeId=?';
  my $read_err;
  my $check_type_id = '';

  ($read_err, $check_type_id) = read_cell($dbh_k_read, $sql, [$class, $type_id]);

  if (length($check_type_id) == 0) {

    my $err_msg = "Type ($type_id) for class ($class) not found.";

    push(@{$general_type_err_aref}, {'Message' => $err_msg});
    $general_type_err = 1;
  }

  if ("$db_is_fixed" eq '1') {

    if ($type_name ne $db_type_name) {

      my $err_msg = "Type ($type_name) cannot be changed.";
 
      push(@{$general_type_err_aref}, {'Message' => $err_msg});
      $general_type_err = 1;
    }
  }

  $sql = 'SELECT TypeId FROM generaltype WHERE Class=? AND TypeName=? AND TypeId<>?';
  $read_err      = 0;
  $check_type_id = '';

  ($read_err, $check_type_id) = read_cell($dbh_k_read, $sql, [$class, $type_name, $type_id]);

  if (length($check_type_id) > 0) {

    my $err_msg = "Type ($type_name) for class ($class) already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength, FactorValidRuleErrMsg, FactorValidRule  ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='generaltypefactor'";

  my $vcol_data = $dbh_k_read->selectall_hashref($sql, 'FactorId');

  my $vcol_param_data = {};
  my $vcol_len_info   = {};
  my $vcol_param_data_maxlen = {};
  my $pre_validate_vcol = {};

  for my $vcol_id (keys(%{$vcol_data})) {

    my $vcol_param_name = "VCol_${vcol_id}";
    my $vcol_value      = $query->param($vcol_param_name) ;
    if ($vcol_data->{$vcol_id}->{'CanFactorHaveNull'} != 1) {

      $vcol_param_data->{$vcol_param_name} = $vcol_value;
    }

    $vcol_len_info->{$vcol_param_name} = $vcol_data->{$vcol_id}->{'FactorValueMaxLength'};
    $vcol_param_data_maxlen->{$vcol_param_name} = $vcol_value;

    $pre_validate_vcol->{$vcol_param_name} = {
      'Rule' => $vcol_data->{$vcol_id}->{'FactorValidRule'},
      'Value'=> $vcol_value,
      'FactorId'=> $vcol_id,
      'RuleErrorMsg'=> $vcol_data->{$vcol_id}->{'FactorValidRuleErrMsg'},
      'CanFactorHaveNull' => $vcol_data->{$vcol_id}->{'CanFactorHaveNull'},
    };
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

  my ($vcol_error, $vcol_error_aref) = validate_all_factor_input($pre_validate_vcol);

  if ($vcol_error) {
    push(@{$general_type_err}, @{$vcol_error_aref});
    $general_type_err = 1;
  }

  if ($general_type_err != 0) {
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => $general_type_err};
    return $data_for_postrun_href;
  }

  my $dbh_k_write = connect_kdb_write();

  $sql  = 'UPDATE generaltype SET ';
  $sql .= 'TypeName=?, ';
  $sql .= 'TypeNote=?, ';
  $sql .= 'IsTypeActive=?, ';
  $sql .= 'IsFixed=?, ';
  $sql .= 'TypeMetaData=? ';
  $sql .= 'WHERE Class=? AND TypeId=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($type_name, $type_note, $is_active, $is_fixed, $type_metadata, $class, $type_id);

  if ($dbh_k_write->err()) {

    $self->logger->debug('Unexpected error.');
    return $self->_set_error('Unexpected Error.');
  }
  $sth->finish();

  my $vcol_error = [];

  for my $vcol_id (keys(%{$vcol_data})) {

    if (defined $query->param('VCol_' . "$vcol_id")) {

      my $factor_value = $query->param('VCol_' . "$vcol_id");

      $self->logger->debug("Updating $vcol_id => $factor_value");

      my ($vcol_err, $vcol_msg) = update_factor_value($dbh_k_write, $vcol_id, $factor_value, 'generaltypefactor', 'TypeId', $type_id);

      if ($vcol_err) {

        $self->logger->debug("VCol_" . "$vcol_id => $vcol_msg" );

        push(@{$general_type_err_aref}, {'VCol_' . "$vcol_id" => $vcol_msg});

        $general_type_err = 1;
      }
    }
  }
  $dbh_k_write->disconnect();

  if ($general_type_err != 0) {
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => $general_type_err_aref};
    return $data_for_postrun_href;
  }

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
"OperationName": "Delete type",
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
"URLParameter": [{"ParameterName": "class", "Description": "Value from a predefined list of values for classification of the type. This list of values is site, item, container, deviceregister, trial, trialevent, sample, specimengroup, state, parent, itemparent, genotypespecimen, dataset, workflow, project, itemlog, plate, genmap, multimedia, tissue, genotypealias, genparent, genotypealiasstatus, traitgroup, unittype, trialgroup and season."}, {"ParameterName": "id", "Description": "Existing GeneralTypeId"}],
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
    { 'table' => 'breedingmethod',    'field' => 'BreedingMethodTypeId', 'value' => $type_id },
    { 'table' => 'deviceregister',    'field' => 'DeviceTypeId',         'value' => $type_id },
    { 'table' => 'generalunit',       'field' => 'UnitTypeId',           'value' => $type_id },
    { 'table' => 'genotypespecimen',  'field' => 'GenotypeSpecimenType', 'value' => $type_id },
    { 'table' => 'genotypealias',     'field' => 'GenotypeAliasType',    'value' => $type_id },
    { 'table' => 'genotypealias',     'field' => 'GenotypeAliasStatus',  'value' => $type_id },
    { 'table' => 'genpedigree',       'field' => 'GenParentType',        'value' => $type_id },
    { 'table' => 'item',              'field' => 'ContainerTypeId',      'value' => $type_id },
    { 'table' => 'item',              'field' => 'ItemTypeId',           'value' => $type_id },
    { 'table' => 'item',              'field' => 'ItemStateId',          'value' => $type_id },
    { 'table' => 'itemlog',           'field' => 'LogTypeId',            'value' => $type_id },
    { 'table' => 'itemparent',        'field' => 'ItemParentType',       'value' => $type_id },
    { 'table' => 'multimedia',        'field' => 'FileType',             'value' => $type_id },
    { 'table' => 'pedigree',          'field' => 'ParentType',           'value' => $type_id },
    { 'table' => 'project',           'field' => 'TypeId',               'value' => $type_id },
    { 'table' => 'site',              'field' => 'SiteTypeId',           'value' => $type_id },
    { 'table' => 'specimengroup',     'field' => 'SpecimenGroupTypeId',  'value' => $type_id },
    { 'table' => 'specimengroup',     'field' => 'SpecimenGroupStatus',  'value' => $type_id },
    { 'table' => 'samplemeasurement', 'field' => 'SampleTypeId',         'value' => $type_id },
    { 'table' => 'trait',             'field' => 'TraitGroupTypeId',     'value' => $type_id },
    { 'table' => 'trait',             'field' => 'TraitDataType',        'value' => $type_id },
    { 'table' => 'trial',             'field' => 'TrialTypeId',          'value' => $type_id },
    { 'table' => 'trial',             'field' => 'SeasonId',             'value' => $type_id },
    { 'table' => 'trialevent',        'field' => 'EventTypeId',          'value' => $type_id },
    { 'table' => 'trialgroup',        'field' => 'TrialGroupType',       'value' => $type_id },
    { 'table' => 'workflow',          'field' => 'WorkflowType',         'value' => $type_id },
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
    { 'table' => 'dataset',           'field' => 'DataSetType',         'value' => $type_id },
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

sub count_groupby_runmode {

=pod count_groupby_HELP_START
{
"OperationName": "Count records with GROUP BY",
"Description": "Count records in the specified table based on the submitted group by fields. It supports pagination, filtering and sorting",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination NumOfRecords='4' NumOfPages='1' Page='1' NumPerPage='10' /><RecordMeta TagName='CountGroupBy' /><CountGroupBy GenusId='2' CountResult='227' /><CountGroupBy GenusId='4' CountResult='4' /><CountGroupBy GenusId='3' CountResult='2' /><CountGroupBy GenusId='1' CountResult='1' /></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfRecords' : '4', 'NumOfPages' : 1, 'NumPerPage' : '10', 'Page' : '1'}], 'RecordMeta' : [{'TagName' : 'CountGroupBy'}], 'CountGroupBy' : [{'GenusId' : '2', 'CountResult' : '227'},{'GenusId' : '4', 'CountResult' : '4'},{'GenusId' : '3', 'CountResult' : '2'},{'GenusId' : '1', 'CountResult' : '1'}]}",
"ErrorMessageXML": [{"InvalidValue": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Table name (samplemeasurement) does not support counting.' /></DATA>"}],
"ErrorMessageJSON": [{"InvalidValue": "{'Error' : [{'Message' : 'Table name (samplemeasurement) does not support counting.'}]}"}],
"URLParameter": [{"ParameterName": "nperpage", "Description": "Number of records in a page for pagination"}, {"ParameterName": "num", "Description": "The page number of the pagination"}, {"ParameterName": "tname", "Description": "Table name in which record count operation is executed. Most tables in KDDart are supported. However, tables that stores the lowest level data like samplemeasurement or virtual column storage tables are not supported."}],
"HTTPParameter": [{"Required": 1, "Name": "GroupByField", "Description": "Comma separated value of group by fields in the specified table (tname in the URL parameter)."}, {"Required": 0, "Name": "Filtering", "Description": "Filtering parameter string consisting of filtering expressions which are separated by ampersand (&) which needs to be encoded if HTTP GET method is used. Each filtering expression is composed of a database field name, a filtering operator and the filtering value. This filtering will be applied before counting. The other filtering that applies after counting is called CountFiltering."}, {"Required": 0, "Name": "Sorting", "Description": "Comma separated value of SQL sorting phrases. Fields that are applicable for sorting are those specified in the GroupByField parameter and the count field which is named CountResult"}, {"Required": 0, "Name": "CountFiltering", "Description": "Filtering that gets applied after counting. This filtering can be used to know the uniqueness on  the combination of the fields provided in the GroupByField. This CountFiltering Parameter has a different syntax from the normal filtering. Its syntax is [eq|ne|gt|lt|ge|lt|le] followed by spaces  then followed by a signed or unsigned number."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self              = shift;
  my $query             = $self->query();
  my $table_name        = $self->param('tname');

  my $nb_per_page       = $self->param('nperpage');
  my $page              = $self->param('num');

  my $groupby_field_csv = $query->param('GroupByField');

  my $filtering_csv = '';

  if (defined $query->param('Filtering')) {

    $filtering_csv = $query->param('Filtering');
  }

  my $sorting = '';

  if (defined $query->param('Sorting')) {

    $sorting = $query->param('Sorting');
  }

  my $count_filtering = '';

  if (defined $query->param('CountFiltering')) {

    $count_filtering = $query->param('CountFiltering');
  }

  my $data_for_postrun_href = {};

  my $count_filtering_oper = '';
  my $count_filtering_val  = '';

  $self->logger->debug("Count filtering: $count_filtering");

  if (length($count_filtering) > 0) {

    if ($count_filtering =~ /^(eq|ne|gt|ge|lt|le)\s+([-+]?\d+)$/i) {

      $count_filtering_oper = lc($1);
      $count_filtering_val  = $2;
    }
    else {

      my $err_msg = "CountFiltering ($count_filtering) invalid.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'CountFiltering' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @restricted_table_list = ('samplemeasurement', '.+factor', '.+loc', 'layer\d+',
                               'layer\d+attrib', 'markerdata\d+');

  for my $restricted_table (@restricted_table_list) {

    if ($table_name =~ /$restricted_table/) {

      my $err_msg = "Table name ($table_name) does not support counting.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my ($missing_err, $missing_href) = check_missing_href( {'GroupByField' => $groupby_field_csv} );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  my ($int_err, $int_err_msg) = check_integer_value( {'nperpage' => $nb_per_page,
                                                      'num'      => $page
                                                     });

  if ($int_err) {

    $int_err_msg .= ' not integer.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $int_err_msg}]};

    return $data_for_postrun_href;
  }

  if ($table_name =~ /\s+/) {

    my $err_msg = "Table name ($table_name) contains spaces.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $other_join_lookup = {};

  $other_join_lookup->{'specimen'}  = ' LEFT JOIN genotypespecimen ON specimen.SpecimenId = genotypespecimen.SpecimenId ';
  $other_join_lookup->{'specimen'} .= ' LEFT JOIN genotype ON genotypespecimen.GenotypeId = genotype.GenotypeId ';

  $other_join_lookup->{'trialunit'} = ' LEFT JOIN trial ON trialunit.TrialId = trial.TrialId ';

  $other_join_lookup->{'trialunitspecimen'}  = ' LEFT JOIN trialunit ON trialunitspecimen.TrialUnitId = trialunit.TrialUnitId ';
  $other_join_lookup->{'trialunitspecimen'} .= ' LEFT JOIN trial ON trialunit.TrialId = trial.TrialId ';

  $other_join_lookup->{'analgroupextract'}   = ' LEFT JOIN analysisgroup ON ';
  $other_join_lookup->{'analgroupextract'}  .= 'analgroupextract.AnalysisGroupId = analysisgroup.AnalysisGroupId ';

  $other_join_lookup->{'analysisgroupmarker'}  = ' LEFT JOIN analysisgroup ON ';
  $other_join_lookup->{'analysisgroupmarker'} .= 'analysisgroupmarker.AnalysisGroupId = analysisgroup.AnalysisGroupId ';

  $other_join_lookup->{'genotypealias'}   = ' LEFT JOIN genotype ON genotypealias.GenotypeId = genotype.GenotypeId ';

  $other_join_lookup->{'genotypetrait'}   = ' LEFT JOIN genotype ON genotypetrait.GenotypeId = genotype.GenotypeId ';

  $other_join_lookup->{'traitalias'}      = ' LEFT JOIN trait ON traitalias.TraitId = trait.TraitId ';

  $other_join_lookup->{'trialtrait'}      = ' LEFT JOIN trial ON trialtrait.TrialId = trial.TrialId ';

  $other_join_lookup->{'layerattrib'}     = ' LEFT JOIN layer ON layerattrib.layer = layer.id ';

  $other_join_lookup->{'trialdimension'}  = ' LEFT JOIN trial ON trialdimension.TrialId = trial.TrialId ';

  $other_join_lookup->{'trialunit'}       = ' LEFT JOIN trial ON trialunit.TrialId = trial.TrialId ';

  $other_join_lookup->{'trialworkflow'}   = ' LEFT JOIN trial ON trialworkflow.TrialId = trial.TrialId ';

  $other_join_lookup->{'trialevent'}      = ' LEFT JOIN trial ON trialevent.TrialId = trial.TrialId ';

  my @table_name_list = ($table_name);

  my $other_join = '';

  if (defined $other_join_lookup->{$table_name}) {

    $other_join = $other_join_lookup->{$table_name};
  }

  if ($other_join =~ /LEFT JOIN (\w+) ON/) {

    my $other_table = $1;
    push(@table_name_list, $other_table);
  }

  my $gis_table = 0;

  my $dbh;

  my $dbh_gis = connect_gis_read();
  my $dbh_k = connect_kdb_read();
  my $dbh_m = connect_mdb_read();

  my $field_name_lookup = {};

  my $first_primary_key = '';

  my $field_name2table_name = {};

  foreach my $tbl_name (@table_name_list) {

    my $tbl_info_sth = $dbh_gis->table_info();
    $tbl_info_sth->execute();

    while( my @gis_table = $tbl_info_sth->fetchrow_array() ) {

      if ($gis_table[2] eq $tbl_name) {

        $gis_table = 1;
        last;
      }
    }

    $tbl_info_sth->finish();

    my $scol_aref = [];
    my $pkey_aref = [];

    if ($gis_table) {

      my ($gis_sfield_err, $gis_sfield_msg, $gis_sfield_aref, $gis_pkey) = get_static_field($dbh_gis, $tbl_name);

      if ($gis_sfield_err) {

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

        return $data_for_postrun_href;
      }

      $scol_aref = $gis_sfield_aref;
      $pkey_aref = $gis_pkey;

      $dbh = $dbh_gis;
    }
    else {

      my ($k_sfield_err, $k_sfield_msg, $k_sfield_aref, $k_pkey) = get_static_field($dbh_k, $tbl_name);

      if ($k_sfield_err) {

        # this table is not in the main database, maybe it is in the marker database.
        my ($m_sfield_err, $m_sfield_msg, $m_sfield_aref, $m_pkey) = get_static_field($dbh_m, $tbl_name);

        if ($m_sfield_err) {

          my $err_msg = "Table ($tbl_name) does not exist.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
        else {

          $scol_aref = $m_sfield_aref;
          $pkey_aref = $m_pkey;

          $dbh = $dbh_m;
        }
      }
      else {

        $scol_aref = $k_sfield_aref;
        $pkey_aref = $k_pkey;

        $dbh = $dbh_k;
      }
    }


    if (length($first_primary_key) == 0) {

      $first_primary_key = $pkey_aref->[0];
    }

    $self->logger->debug("Primary key [0]: $first_primary_key");

    for my $scol_rec (@{$scol_aref}) {

      my $field_name = $scol_rec->{'Name'};
      $field_name_lookup->{$field_name} = 1;
      $field_name2table_name->{$field_name} = $tbl_name;
    }

    for my $pkey_name (@{$pkey_aref}) {

      $field_name_lookup->{$pkey_name} = 1;
      $field_name2table_name->{$pkey_name} = $tbl_name;
    }
  }

  my @groupby_field_list = split(',', $groupby_field_csv);

  my @full_groupby_field_list;

  for my $groupby_field (@groupby_field_list) {

    if ( !(defined $field_name_lookup->{$groupby_field}) ) {

      my $err_msg = "Field ($groupby_field) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'GroupByField' => $err_msg}]};

      return $data_for_postrun_href;
    }

    push(@full_groupby_field_list, "${table_name}.${groupby_field}");
  }

  my $table_with_perm_lookup = {
                                'genotype'             => 'genotype',
                                'specimen'             => 'genotype',
                                'trial'                => 'trial',
                                'trialunit'            => 'trial',
                                'trialunitspecimen'    => 'trial',
                                'layer'                => 'layer',
                                'trait'                => 'trait',
                                'analysisgroup'        => 'analysisgroup',
                                'analgroupextract'     => 'analysisgroup',
                                'analysisgroupmarker'  => 'analysisgroup',
                                'genotypealias'        => 'genotype',
                                'genotypetrait'        => 'genotype',
                                'traitalias'           => 'trait',
                                'trialtrait'           => 'trial',
                                'layerattrib'          => 'layer',
                                };

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str      = '';

  if (defined $table_with_perm_lookup->{$table_name}) {

    my $src_perm_table = $table_with_perm_lookup->{$table_name};
    $perm_str = permission_phrase($group_id, 0, $gadmin_status, $src_perm_table);
  }

  my $filtering_exp = '';

  my @field_list = keys(%{$field_name_lookup});

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering($first_primary_key,
                                                                              $table_name,
                                                                              $filtering_csv,
                                                                              \@field_list);

  if ($filter_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $filter_msg}]};

    return $data_for_postrun_href;
  }

  #
  # Put table name replacement in here
  #

  if (length($filter_phrase) > 0) {

    my $test_filter_phrase = $filter_phrase;

    while ( $test_filter_phrase =~ /${table_name}\.(\w+)/ ) {

      my $fld_name = $1;

      my $correct_tbl_name = $field_name2table_name->{$fld_name};

      $filter_phrase =~ s/${table_name}\.${fld_name}/${correct_tbl_name}\.$fld_name/;
      $test_filter_phrase =~ s/${table_name}\.${fld_name}//;
    }

    if (length($perm_str) > 0) {

      $filtering_exp = " WHERE (($perm_str) & $READ_PERM) = $READ_PERM AND $filter_phrase ";
    }
    else {

      $filtering_exp = " WHERE $filter_phrase ";
    }
  }

  $self->logger->debug("Filter phrase: $filter_phrase");

  my $valid_groupby_field_csv = join(',', @full_groupby_field_list);

  my $having_exp = '';

  my $oper_lookup = { 'eq' => '=',
                      'ne' => '<>',
                      'gt' => '>',
                      'ge' => '>=',
                      'lt' => '<',
                      'le' => '<='
                    };

  if (length($count_filtering) > 0) {

    if (length($count_filtering_oper) > 0 && length($count_filtering_val) > 0) {

      $having_exp  = " HAVING COUNT(DISTINCT ${table_name}.${first_primary_key}) ";
      $having_exp .= $oper_lookup->{$count_filtering_oper} . " $count_filtering_val";
    }
    else {

      $self->logger->debug("Count filtering not right ($count_filtering : $count_filtering_oper - $count_filtering_val");

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }
  }

  my $pagination_aref = [];

  my $count_sql  = "SELECT COUNT(subq.CountResult) FROM ( ";
  $count_sql    .= "SELECT COUNT(DISTINCT ${table_name}.${first_primary_key}) AS CountResult FROM $table_name ";
  $count_sql    .= "$other_join ";
  $count_sql    .= "$filtering_exp ";
  $count_sql    .= "GROUP BY $valid_groupby_field_csv";
  $count_sql    .= "$having_exp ) AS subq";

  $self->logger->debug("COUNT SQL: $count_sql");

  my ($paged_id_err, $paged_id_msg, $nb_records,
      $nb_pages, $limit_clause, $sql_count_time) = get_paged_filter_sql($dbh,
                                                                        $nb_per_page,
                                                                        $page,
                                                                        $count_sql,
                                                                        $where_arg);

  $self->logger->debug("SQL Count time: $sql_count_time");

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

  push(@groupby_field_list, 'CountResult');

  my $field_list_with_count = \@groupby_field_list;

  my ($sort_err, $sort_msg, $sort_sql) = parse_sorting($sorting, $field_list_with_count);

  if ($sort_err) {

    $self->logger->debug("Parsing sort failed: $sort_msg");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sort_msg}]};

    return $data_for_postrun_href;
  }

  my $sql  = "SELECT $valid_groupby_field_csv , COUNT(DISTINCT ${table_name}.$first_primary_key) AS `CountResult` ";
  $sql    .= "FROM $table_name ";
  $sql    .= "$other_join ";
  $sql    .= "$filtering_exp ";
  $sql    .= "GROUP BY $valid_groupby_field_csv ";
  $sql    .= "$having_exp ";

  if (length($sort_sql) > 0) {

    $sql .= " ORDER BY $sort_sql ";
  }
  else {

    $sql .= " ORDER BY CountResult DESC ";
  }

  $sql    .= "$limit_clause";

  $self->logger->debug("SQL: $sql");

  my ($count_err, $count_msg, $count_data) = read_data($dbh, $sql, $where_arg);

  if ($count_err) {

    $self->logger->debug("Read count data failed: $count_msg");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $dbh_k->disconnect();
  $dbh_m->disconnect();

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'CountGroupBy' => $count_data,
                                           'Pagination'   => $pagination_aref,
                                           'RecordMeta'   => [{'TagName' => 'CountGroupBy'}],
  };

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
