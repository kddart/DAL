#$Id: Marker.pm 785 2014-09-02 06:23:12Z puthick $
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
# Created   : 20/10/2013

package KDDArT::DAL::Marker;

use strict;
use warnings;

use Data::Dumper;
use Text::CSV;
use File::Lockfile;
use Crypt::Random qw( makerandom );
use DateTime;

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
use Time::HiRes qw( tv_interval gettimeofday );
use File::Lockfile;
use feature qw(switch);

sub setup {

  my $self   = shift;

  CGI::Session->name("KDDArT_DAL_SESSID");

  __PACKAGE__->authen->init_config_parameters();
  __PACKAGE__->authen->check_login_runmodes(':all');
  __PACKAGE__->authen->check_rand_runmodes('import_marker_dart',
                                           'import_marker_dart_fs',
      );
  __PACKAGE__->authen->count_session_request_runmodes(':all');
  __PACKAGE__->authen->check_content_type_runmodes(':all');
  __PACKAGE__->authen->check_sign_upload_runmodes('import_marker_dart',
                                                  'import_marker_dart_fs',
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
  
  $self->run_modes(
    'export_marker_dart'                              => 'export_marker_dart_runmode',
    'import_marker_dart'                              => 'import_marker_dart_runmode',
    'import_marker_dart_fs'                           => 'import_marker_dart_fs_runmode',
    'export_marker_dart_fs'                           => 'export_marker_dart_fs_runmode',
    'list_marker_meta_field'                          => 'list_marker_meta_field_runmode',
      ); 
}

sub import_marker_dart_runmode {

  my $self    = shift;
  my $query   = $self->query();
  my $anal_id = $self->param('id');

  my $start_time = [gettimeofday()];

  my $header_row            = $query->param('HeaderRow');

  my $marker_name_col       = $query->param('MarkerNameCol');
  my $sequence_col          = $query->param('SequenceCol');

  my $marker_meta_scol      = $query->param('MarkerMetaColStart');
  my $marker_meta_ecol      = $query->param('MarkerMetaColEnd');

  my $marker_data_scol      = $query->param('MarkerDataColStart');
  my $marker_data_ecol      = $query->param('MarkerDataColEnd');

  my $is_forced = 0;

  if (defined($query->param('Forced'))) {

    if ($query->param('Forced') eq '1') {

      $is_forced = 1;
    }
  }

  my $data_for_postrun_href = {};

  my $dbh_m_read = connect_mdb_read();

  if (!record_existence($dbh_m_read, 'analysisgroup', 'AnalysisGroupId', $anal_id)) {

    my $err_msg = "AnalysisGroup ($anal_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id  = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_anal_ok, $trouble_anal_id_aref) = check_permission($dbh_m_read, 'analysisgroup', 'AnalysisGroupId',
                                                             [$anal_id], $group_id, $gadmin_status,
                                                             $READ_WRITE_PERM);

  if (!$is_anal_ok) {

    my $err_msg = "Permission denied: Group ($group_id) and AnalysisGroup ($anal_id).";
    
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $data_csv_file = $self->authen->get_upload_file();

  my $num_of_col = get_csvfile_num_of_col($data_csv_file);

  $self->logger->debug("Number of columns: $num_of_col");

  my $chk_col_def_data = { 'MarkerNameCol'          => $marker_name_col,
                           'SequenceCol'            => $sequence_col,
                           'MarkerMetaColStart'     => $marker_meta_scol,
                           'MarkerMetaColEnd'       => $marker_meta_ecol,
                           'MarkerDataColStart'     => $marker_data_scol,
                           'MarkerDataColEnd'       => $marker_data_ecol,
  };

  my ($col_def_err, $col_def_err_href) = check_col_def_href( $chk_col_def_data, $num_of_col );

  if ($col_def_err) {

    $self->logger->debug("Check column definition error");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$col_def_err_href]};

    return $data_for_postrun_href;
  }

  my ($missing_err, $missing_href) = check_missing_href( {'HeaderRow' => $header_row} );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  my $sql = '';
  my $sth;

  $sql = 'SELECT ExtractId, AnalGroupExtractId FROM analgroupextract WHERE AnalysisGroupId=?';

  $sth = $dbh_m_read->prepare($sql);
  $sth->execute($anal_id);
  my $extract_id2anal_grp_extract_id_href = $sth->fetchall_hashref('ExtractId');
  $sth->finish();

  my @first_fieldname_list;

  for (my $i = 0; $i < $num_of_col; $i++) {

    push(@first_fieldname_list, "Col$i");
  }

  my $csv_filehandle;
  open($csv_filehandle, "$data_csv_file") or die "Cannot open $data_csv_file: $!";

  my $check_empty_col   = 0;
  my $nb_line_wanted    = $header_row + 1; # get data up to the header row
  my $ignore_line0      = 0;
  my $ignore_header     = 0;

  my ($csv_header_err, $csv_header_msg, $header_section_aref) = csvfh2aref($csv_filehandle,
                                                                           \@first_fieldname_list,
                                                                           $check_empty_col,
                                                                           $nb_line_wanted,
                                                                           $ignore_line0,
                                                                           $ignore_header);

  if ($csv_header_err) {

    $self->logger->debug("Error reading header");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $csv_header_msg}]};

    return $data_for_postrun_href;
  }

  close($csv_filehandle);

  my $header_href = $header_section_aref->[$header_row];

  my $matched_col = {};

  $matched_col->{$marker_name_col}         = 'MarkerName';
  $matched_col->{$sequence_col}            = 'Sequence';

  my @marker_meta_field_list;

  for (my $i = $marker_meta_scol; $i <= $marker_meta_ecol; $i++) {

    push(@marker_meta_field_list, $header_href->{"Col$i"});
    $matched_col->{"$i"} = $header_href->{"Col$i"};
  }

  $self->logger->debug("Marker meta field: " . join(',', @marker_meta_field_list));

  my @marker_data_field_list;

  for (my $i = $marker_data_scol; $i <= $marker_data_ecol; $i++) {

    my $extract_id = $header_href->{"Col$i"};
    push(@marker_data_field_list, $extract_id);
    $matched_col->{"$i"} = $extract_id;

    if ( !(defined($extract_id2anal_grp_extract_id_href->{$extract_id})) ) {

      my $err_msg = "Extract ($extract_id): not found in analysis group ($anal_id).";
      $self->logger->debug($err_msg);
    
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  $self->logger->debug("Marker data field: " . join(',', @marker_data_field_list));

  my $marker_state_x = read_cell_value($dbh_m_read, 'analysisgroup', 'GenotypeMarkerStateX', 'AnalysisGroupId', $anal_id);

  if (length($marker_state_x) == 0) {

    $self->logger->debug("GenotypeMarkerStateX cannot be empty.");
    my $err_msg = "Unexpected Error.";
    
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_m_read->disconnect();

  my $dbh_m_write = connect_mdb_write();

  if ($marker_state_x == 0) {

    $sql = 'SELECT GenotypeMarkerStateX FROM analysisgroup ORDER BY GenotypeMarkerStateX DESC LIMIT 1';
    my ($r_geno_marker_state_x_err, $highest_geno_marker_state_x) = read_cell($dbh_m_write, $sql, []);

    if (length($highest_geno_marker_state_x) == 0) {

      $self->logger->debug("GenotypeMarkerStateX cannot be empty.");
      my $err_msg = "Unexpected Error.";
    
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if ($highest_geno_marker_state_x == 0) {

      # Create genotypemarkermeta1 and genotypemarkerstate1
      $marker_state_x = 1;
      my ($create_geno_marker_table_err,
          $create_geno_marker_table_msg) = $self->create_genotypemarker_table($dbh_m_write, $marker_state_x);

      if ($create_geno_marker_table_err) {

        $self->logger->debug("Create genotypemarker table failed: $create_geno_marker_table_msg");

        my $err_msg = "Unexpected Error.";
    
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }

      $sql  = "UPDATE analysisgroup SET ";
      $sql .= "GenotypeMarkerStateX = ? ";
      $sql .= "WHERE AnalysisGroupId = ?";

      my ($update_anal_grp_err, $update_anal_grp_msg) = execute_sql($dbh_m_write, $sql, [$marker_state_x, $anal_id]);

      if ($update_anal_grp_err) {

        $self->logger->debug("Update analysisgroup failed: $update_anal_grp_msg");

        my $err_msg = "Unexpected Error.";
    
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
    else {

      my $threshold = $MARKER_TABLE_SIZE_THRESHOLD;
      $sql = "SELECT Count(*) FROM genotypemarkerstate${highest_geno_marker_state_x}";
      my ($r_marker_data_count_err, $marker_data_count) = read_cell($dbh_m_write, $sql, []);

      if ($r_marker_data_count_err) {

        $self->logger->debug("Count marker data failed");

        my $err_msg = "Unexpected Error.";
    
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }

      if ($marker_data_count < $threshold) {

        $marker_state_x = $highest_geno_marker_state_x;
      }
      else {

        $marker_state_x = $highest_geno_marker_state_x + 1;

        my ($create_geno_marker_table_err,
            $create_geno_marker_table_msg) = $self->create_genotypemarker_table($dbh_m_write, $marker_state_x);

        if ($create_geno_marker_table_err) {

          $self->logger->debug("Create genotypemarker table failed: $create_geno_marker_table_msg");

          my $err_msg = "Unexpected Error.";
    
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
      }

      $sql  = "UPDATE analysisgroup SET ";
      $sql .= "GenotypeMarkerStateX = ? ";
      $sql .= "WHERE AnalysisGroupId = ?";

      my ($update_anal_grp_err, $update_anal_grp_msg) = execute_sql($dbh_m_write, $sql, [$marker_state_x, $anal_id]);

      if ($update_anal_grp_err) {

        $self->logger->debug("Update analysisgroup failed: $update_anal_grp_msg");

        my $err_msg = "Unexpected Error.";
    
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
  }
  else {

    # this analysis group already has data
    $sql = 'SELECT Count(*) FROM analysisgroupmarker WHERE AnalysisGroupId=?';
    my ($r_marker_count_err, $marker_count) = read_cell($dbh_m_write, $sql, [$anal_id]);

    if ($marker_count > 0) {

      if (!$is_forced) {

        my $err_msg = "Forced ($is_forced): AnalysisGroup ($anal_id) already has data.";
    
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
      else {

        my ($del_anal_data_err, $del_anal_data_msg) = $self->delete_analysisgroup_data($dbh_m_write,
                                                                                       $anal_id,
                                                                                       $marker_state_x);

        if ($del_anal_data_err) {

          $self->logger->debug("Forced ($is_forced): delete analysisgroup data failed: $del_anal_data_msg");
          my $err_msg = "Unexpected error.";
    
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
      }
    }
  }

  my $dbh_k_write = connect_kdb_write();

  # Check marker meta data virtual column existence. if it does not exits, it will be created
  my $meta_fieldname2factor_id_href = {};

  for my $meta_field (@marker_meta_field_list) {

    $sql = 'SELECT FactorId FROM factor WHERE TableNameOfFactor=? AND FactorName=?';

    my ($r_factor_id_err, $factor_id) = read_cell($dbh_k_write, $sql, ['genotypemarkermetaX', "$meta_field"]);

    if ($r_factor_id_err) {

      $self->logger->debug("Read FactorId failed");

      my $err_msg = 'Unexpected error.';
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};
        
      return $data_for_postrun_href;
    }

    $self->logger->debug("$meta_field  - factorid: $factor_id");

    if (length($factor_id) == 0) {

      my $factor_caption = $meta_field;
      my $factor_desc    = "Created automatically by import/makerdata/dart for $meta_field";
      my $factor_dtype   = "STRING";
      my $can_be_null    = 1;
      my $max_length     = 32;
      # Automatically created virtual columns are owned by admin
      my $own_group_id   = 0;
      my $is_public      = 1;

      $sql  = 'INSERT INTO factor SET ';
      $sql .= 'FactorName=?, ';
      $sql .= 'FactorCaption=?, ';
      $sql .= 'FactorDescription=?, ';
      $sql .= 'TableNameOfFactor=?, ';
      $sql .= 'FactorDataType=?, ';
      $sql .= 'CanFactorHaveNull=?, ';
      $sql .= 'FactorValueMaxLength=?, ';
      $sql .= 'OwnGroupId=?, ';
      $sql .= 'Public=?';
      
      my $add_vcol_sth = $dbh_k_write->prepare($sql);
      $add_vcol_sth->execute($meta_field, $factor_caption, $factor_desc,
                             'genotypemarkermetaX', $factor_dtype, $can_be_null,
                             $max_length, $own_group_id, $is_public );
      

      if (!$dbh_k_write->err()) {

        $factor_id = $dbh_k_write->last_insert_id(undef, undef, 'factor', 'FactorId');
        $self->logger->debug("FactorId: $factor_id");
      }
      else {

        $self->logger->debug("Insert into factor failed");
        my $err_msg = 'Unexpected error.';
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};
        
        return $data_for_postrun_href;
      }
      $add_vcol_sth->finish();
    }
    
    $meta_fieldname2factor_id_href->{$meta_field} = $factor_id;
  }

  $dbh_k_write->disconnect();

  # mached_col variable should have been built. now it is time read the data from
  # the upload file again after all the tables are ready for data insert.

  my $fieldname_list_aref = [];
  
  for (my $i = 0; $i < $num_of_col; $i++) {

    if ($matched_col->{$i}) {

      push(@{$fieldname_list_aref}, $matched_col->{$i});
    }
    else {

      push(@{$fieldname_list_aref}, 'null');
    }
  }

  $self->logger->debug("Final field list: " . join(',', @{$fieldname_list_aref}));

  open($csv_filehandle, "$data_csv_file") or die "Cannot open $data_csv_file: $!";

  $check_empty_col   = 0;
  $nb_line_wanted    = -1;
  $ignore_line0      = 0;
  $ignore_header     = 0;
  my $start_line        = $header_row + 1;

  my ($csv_data_err, $csv_data_msg, $marker_data_aref) = csvfh2aref($csv_filehandle,
                                                                    $fieldname_list_aref,
                                                                    $check_empty_col,
                                                                    $nb_line_wanted,
                                                                    $ignore_line0,
                                                                    $ignore_header,
                                                                    $start_line);

  if ($csv_data_err) {
      
    $self->logger->debug("Error reading marker data.");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $csv_data_msg}]};

    return $data_for_postrun_href;
  }  

  close($csv_filehandle);

  my $nb_of_row         = scalar(@{$marker_data_aref});

  my $nb_extract        = scalar(@marker_data_field_list);
  my $nb_meta           = scalar(@marker_meta_field_list);
  my $nb_bulk_insert    = $NB_RECORD_BULK_INSERT;

  my $row_increment     = int($nb_bulk_insert / $nb_extract);
  my $column_increment  = $nb_extract;

  if ($row_increment < 1) {

    $row_increment = 1;
    $column_increment  = int($nb_extract / $nb_bulk_insert);
  }

  $self->logger->debug("Row increment: $row_increment");
  $self->logger->debug("Column increment: $column_increment");

  my $nb_data_point = 0;
  my $i = 0;
  while ($i < $nb_of_row) {

    my $meta_sql = "INSERT INTO genotypemarkermeta${marker_state_x} ";
    $meta_sql   .= "(AnalysisGroupMarkerId,FactorId,Value) ";
    $meta_sql   .= "VALUES ";

    my $j = $i;
    while ( ($j < ($i + $row_increment)) && ($j < $nb_of_row) ) {

      # insert marker to get AnalysisGroupMarkerId
      my $marker_row_href = $marker_data_aref->[$j];

      #$self->logger->debug("Row: $j - " . join(',', keys(%{$marker_row_href})));

      my $marker_name     = $marker_row_href->{'MarkerName'};
      my $marker_sequence = $marker_row_href->{'Sequence'};

      #$self->logger->debug("MarkerName: $marker_name");

      $sql  = 'INSERT INTO analysisgroupmarker SET ';
      $sql .= 'AnalysisGroupId = ?, ';
      $sql .= 'MarkerName = ?, ';
      $sql .= 'MarkerSequence = ?';

      $sth = $dbh_m_write->prepare($sql);

      $sth->execute($anal_id, $marker_name, $marker_sequence);

      if ($dbh_m_write->err()) {

        $self->logger->debug('Insert analysisgroupmarker failed');
        my $err_msg = 'Unexpected error.';
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};
        
        return $data_for_postrun_href;
      }

      my $anal_marker_id = $dbh_m_write->last_insert_id(undef, undef,
                                                        'analysisgroupmarker', 'AnalysisGroupMarkerId');

      $sth->finish();

      #$self->logger->debug("AnalysisGroupMarkerId: $anal_marker_id");

      # look through meta field list
      for my $meta_fieldname (@marker_meta_field_list) {

        my $meta_value = $dbh_m_write->quote($marker_row_href->{$meta_fieldname});
        my $factor_id  = $meta_fieldname2factor_id_href->{$meta_fieldname};
        $meta_sql .= "(${anal_marker_id},${factor_id},${meta_value}),";
      }

      my $k = 0;
      while ($k < $nb_extract) {

        my $state_sql = "INSERT INTO genotypemarkerstate${marker_state_x} ";
        $state_sql   .= "(AnalGroupExtractId,AnalysisGroupMarkerId,State) ";
        $state_sql   .= "VALUES ";

        my $l = $k;
        while ( ($l < ($k + $column_increment)) && ($l < $nb_extract) ) {

          my $extract_id            = $marker_data_field_list[$l];
          my $anal_group_extract_id = $extract_id2anal_grp_extract_id_href->{$extract_id}->{'AnalGroupExtractId'};
          my $state                 = $dbh_m_write->quote($marker_row_href->{$extract_id});

          $state_sql .= "(${anal_group_extract_id},${anal_marker_id},${state}),";
          $nb_data_point += 1;
          $l += 1;
        }

        # execute state_sql here
        $state_sql =~ s/\),$/\)/;

        my $mkd_start_time = [gettimeofday()];
        
        my ($insert_state_err, $insert_state_msg) = execute_sql($dbh_m_write, $state_sql);

        my $mkd_elapsed_time = tv_interval($mkd_start_time);

        $self->logger->debug("Insert marker data: $i - time: $mkd_elapsed_time");

        if ($insert_state_err) {
      
          my ($del_anal_data_err, $del_anal_data_msg) = $self->delete_analysisgroup_data($dbh_m_write,
                                                                                         $anal_id,
                                                                                         $marker_state_x);

          if ($del_anal_data_err) {

            $self->logger->debug("Delete analysisgroup data failed: $del_anal_data_msg");
            my $err_msg = "Unexpected error.";
    
            $data_for_postrun_href->{'Error'} = 1;
            $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};
        
            return $data_for_postrun_href;
          }

          $self->logger->debug("Insert marker state data failed: $insert_state_msg");
          my $err_msg = "Unexpected error.";
    
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};
        
          return $data_for_postrun_href;
        }

        $k += $column_increment;
      }

      $j += 1;
    }

    # execute meta_sql here

    # remove trailing coma
    $meta_sql =~ s/\),$/\)/;

    my $mkm_start_time = [gettimeofday()];

    my ($insert_meta_err, $insert_meta_msg) = execute_sql($dbh_m_write, $meta_sql);

    my $mkm_elapsed_time = tv_interval($mkm_start_time);

    $self->logger->debug("Insert marker meta data: $i - time: $mkm_elapsed_time");

    if ($insert_meta_err) {
      
      my ($del_anal_data_err, $del_anal_data_msg) = $self->delete_analysisgroup_data($dbh_m_write,
                                                                                     $anal_id,
                                                                                     $marker_state_x);

      if ($del_anal_data_err) {

        $self->logger->debug("Delete analysisgroup data failed: $del_anal_data_msg");
        my $err_msg = "Unexpected error.";
    
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};
        
        return $data_for_postrun_href;
      }

      $self->logger->debug("Insert marker meta data failed: $insert_meta_msg");
      my $err_msg = "Unexpected error.";
    
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};
        
      return $data_for_postrun_href;
    }

    $i += $row_increment;
  }

  $dbh_m_write->disconnect();

  my $elapsed_time = tv_interval($start_time);

  my $info_msg = "$nb_of_row markers for $nb_extract extracts ";
  $info_msg   .= "with $nb_meta marker meta data columns have been imported successfully. ";
  $info_msg   .= "Total number of marker data points is $nb_data_point ";
  $info_msg   .= "Time taken in seconds: $elapsed_time.";

  my $info_msg_aref = [{'Message' => $info_msg, 'RunTime' => "$elapsed_time"}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub export_marker_dart_runmode {

  my $self    = shift;
  my $query   = $self->query();
  my $anal_id = $self->param('id');

  my $start_time = [gettimeofday()];

  my $data_for_postrun_href = {};

  my $dbh_m_read = connect_mdb_read();

  if (!record_existence($dbh_m_read, 'analysisgroup', 'AnalysisGroupId', $anal_id)) {

    my $err_msg = "AnalysisGroup ($anal_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id  = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_anal_ok, $trouble_anal_id_aref) = check_permission($dbh_m_read, 'analysisgroup', 'AnalysisGroupId',
                                                             [$anal_id], $group_id, $gadmin_status,
                                                             $READ_PERM);

  if (!$is_anal_ok) {

    my $err_msg = "Permission denied: Group ($group_id) and AnalysisGroup ($anal_id).";
    
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $marker_state_x = read_cell_value($dbh_m_read, 'analysisgroup', 'GenotypeMarkerStateX', 'AnalysisGroupId', $anal_id);

  if ($marker_state_x == 0) {

    my $err_msg = "AnalysisGroup ($anal_id) has no data.";
    
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_k_read = connect_kdb_read();

  my $sql = '';

  $sql  = "SELECT FactorId ";
  $sql .= "FROM analysisgroupmarker LEFT JOIN genotypemarkermeta${marker_state_x} ";
  $sql .= "ON analysisgroupmarker.AnalysisGroupMarkerId = genotypemarkermeta${marker_state_x}.AnalysisGroupMarkerId ";
  $sql .= "WHERE AnalysisGroupId = ? ";
  $sql .= "GROUP BY FactorId";

  my ($r_factor_id_err, $r_factor_id_msg, $factor_id_data) = read_data($dbh_m_read, $sql, [$anal_id]);

  if ($r_factor_id_err) {

    $self->logger->debug("Read FactorId for analysis group ($anal_id) failed");
    my $err_msg = "Unexpected error.";
    
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};
        
    return $data_for_postrun_href;
  }

  my @factor_id_list;

  for my $factor_id_rec (@{$factor_id_data}) {

    my $factor_id = $factor_id_rec->{'FactorId'};
    push(@factor_id_list, $factor_id);
  }

  # free up memory for factor id data
  $factor_id_data = [];

  my $factor_id_str      = join(',', @factor_id_list);

  #$self->logger->debug("Marker meta factor id list: $factor_id_str");

  $sql = "SELECT FactorId, FactorName FROM factor WHERE FactorId IN ($factor_id_str)";

  my ($r_factor_name_err, $r_factor_name_msg, $factor_name_data) = read_data($dbh_k_read, $sql, []);

  if ($r_factor_name_err) {

    $self->logger->debug("Read factor name failed: $r_factor_name_msg");
    my $err_msg = "Unexpected error.";
    
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};
        
    return $data_for_postrun_href;
  }

  my $factor_id2name_href  = {};

  for my $factor_rec (@{$factor_name_data}) {
    
    my $factor_id   = $factor_rec->{'FactorId'};
    my $factor_name = $factor_rec->{'FactorName'};
    $factor_id2name_href->{$factor_id} = $factor_name;
  }

  # free up memory for factor name data
  $factor_name_data = [];

  my $header_row_aref = [];

  my $nb_marker_meta_col = scalar(@factor_id_list) + 2; # MarkerName and MarkerSequence columns

  my @plate_header_row;
  my @well_header_row;
  my @itm_grp_header_row;
  my @geno_header_row;

  for (my $i = 0; $i < ($nb_marker_meta_col - 1); $i++) {

    push(@plate_header_row, '*');
    push(@well_header_row, '*');
    push(@itm_grp_header_row, '*');
    push(@geno_header_row, '*');
  }

  push(@plate_header_row, 'PlateName');
  push(@well_header_row, 'WellPosition');
  push(@itm_grp_header_row, 'ItemGroupName');
  push(@geno_header_row, 'GenotypeName');
    
  $sql  = 'SELECT analgroupextract.ExtractId, AnalGroupExtractId, plate.PlateName, ';
  $sql .= 'extract.ItemGroupId, extract.GenotypeId, ';
  $sql .= 'CONCAT(extract.WellRow, extract.WellCol) AS WellPosition ';
  $sql .= 'FROM analgroupextract LEFT JOIN extract on analgroupextract.ExtractId = extract.ExtractId ';
  $sql .= 'LEFT JOIN plate ON extract.PlateId = plate.PlateId ';
  $sql .= 'WHERE AnalysisGroupId = ? ORDER BY analgroupextract.ExtractId';

  my ($r_extract_err, $r_extract_msg, $extract_data) = read_data($dbh_m_read, $sql, [$anal_id]);

  if ($r_extract_err) {

    $self->logger->debug("Read extract failed: $r_extract_msg");
    my $err_msg = "Unexpected error.";
    
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};
        
    return $data_for_postrun_href;
  }

  my $ext_id2anal_ext_id_href = {};
  my @extract_id_list;

  for my $extract_rec (@{$extract_data}) {

    my $extract_id  = $extract_rec->{'ExtractId'};
    my $anal_ext_id = $extract_rec->{'AnalGroupExtractId'};

    my $plate_name  = $extract_rec->{'PlateName'};
    my $well_pos    = $extract_rec->{'WellPosition'};
    my $itm_grp_id  = $extract_rec->{'ItemGroupId'};
    my $geno_id     = $extract_rec->{'GenotypeId'};

    my $itm_grp_name = read_cell_value($dbh_k_read, 'itemgroup', 'ItemGroupName', 'ItemGroupId', $itm_grp_id);
    my $geno_name    = read_cell_value($dbh_k_read, 'genotype', 'GenotypeName', 'GenotypeId', $geno_id);

    push(@plate_header_row, $plate_name);
    push(@well_header_row, $well_pos);
    push(@itm_grp_header_row, $itm_grp_name);
    push(@geno_header_row, $geno_name);

    push(@extract_id_list, $extract_id);
    $ext_id2anal_ext_id_href->{$extract_id} = $anal_ext_id;
  }

  push(@{$header_row_aref}, \@plate_header_row);
  push(@{$header_row_aref}, \@well_header_row);
  push(@{$header_row_aref}, \@itm_grp_header_row);
  push(@{$header_row_aref}, \@geno_header_row);

  # empty extract data to free up memory
  $extract_data = [];

  my $nb_extract = scalar(@extract_id_list);

  $self->logger->debug("Extract id list: " . join(',', @extract_id_list));

  $sql = 'SELECT Count(*) FROM analysisgroupmarker where AnalysisGroupId = ?';

  my ($r_count_err, $nb_markers) = read_cell($dbh_m_read, $sql, [$anal_id]);

  if ($r_count_err) {

    $self->logger->debug('Count the number of markers failed');
    my $err_msg = "Unexpected error.";
    
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};
        
    return $data_for_postrun_href;
  }

  my $result_data_href = {};

  $sql  = 'SELECT DISTINCT AnalysisGroupMarkerId, MarkerName, MarkerSequence ';
  $sql .= 'FROM analysisgroupmarker ';
  $sql .= 'WHERE AnalysisGroupId = ?';

  my ($r_mk_name_err, $r_mk_name_msg, $marker_name_data) = read_data($dbh_m_read, $sql, [$anal_id]);

  if ($r_mk_name_err) {

    $self->logger->debug("Read marker name failed: $r_mk_name_msg");
    my $err_msg = "Unexpected error.";
    
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};
        
    return $data_for_postrun_href;
  }

  my $output_meta_href = {};

  my @header_row;
  push(@header_row, 'MarkerName');
  push(@header_row, 'MarkerSequence');

  $output_meta_href->{'MarkerNameCol'}     = 0;
  $output_meta_href->{'MarkerSequenceCol'} = 1;

  my @marker_id_list;

  for my $marker_name_rec (@{$marker_name_data}) {

    my $marker_id    = $marker_name_rec->{'AnalysisGroupMarkerId'};
    my $marker_name  = $marker_name_rec->{'MarkerName'};
    my $marker_seq   = $marker_name_rec->{'MarkerSequence'};

    $result_data_href->{$marker_id} = "${marker_name},${marker_seq}";
    push(@marker_id_list, $marker_id);
  }

  # free up memory for marker name data
  $marker_name_data = [];

  # get marker meta data

  $sql  = "SELECT DISTINCT genotypemarkermeta${marker_state_x}.AnalysisGroupMarkerId, Value ";
  $sql .= "FROM genotypemarkermeta${marker_state_x} LEFT JOIN analysisgroupmarker ON ";
  $sql .= "genotypemarkermeta${marker_state_x}.AnalysisGroupMarkerId = analysisgroupmarker.AnalysisGroupMarkerId ";
  $sql .= "WHERE AnalysisGroupId = ? AND FactorId = ?";

  my $meta_col_start = 2;

  my $counter = 0;
  for my $factor_id (@factor_id_list) {

    my $mkm_start_time = [gettimeofday()];

    my ($r_mk_meta_err, $r_mk_meta_msg, $marker_meta_data) = read_data($dbh_m_read, $sql, [$anal_id, $factor_id]);

    my $mkm_elapsed_time = tv_interval($mkm_start_time);

    $self->logger->debug("Read marker meta data: $counter - time: $mkm_elapsed_time");
    
    if ($r_mk_meta_err) {

      $self->logger->debug("Read marker meta data failed: $r_mk_meta_msg");
      my $err_msg = "Unexpected error.";
    
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};
        
      return $data_for_postrun_href;
    }

    my $factor_name = $factor_id2name_href->{$factor_id};
    push(@header_row, $factor_name);

    if (scalar(@{$marker_meta_data}) == 0) {

      $self->logger->debug("Marker meta data has no record for factor ($factor_id)");

      for my $mrk_id (@marker_id_list) {

        my $marker_row_str = $result_data_href->{$mrk_id};
        $marker_row_str   .= ",";

        $result_data_href->{$mrk_id} = $marker_row_str;
      }
    }
    else {

      for my $marker_meta_rec (@{$marker_meta_data}) {

        my $marker_id       = $marker_meta_rec->{'AnalysisGroupMarkerId'};
        my $marker_meta_val = $marker_meta_rec->{'Value'};

        my $marker_row_str = $result_data_href->{$marker_id};
        $marker_row_str   .= ",${marker_meta_val}";

        $result_data_href->{$marker_id} = $marker_row_str;
      }
    }

    $counter += 1;
  }

  my $meta_col_end = $meta_col_start + $counter - 1;

  $output_meta_href->{'MarkerMetaColStart'} = $meta_col_start;
  $output_meta_href->{'MarkerMetaColEnd'}   = $meta_col_end;

  my $mdata_col_start = $meta_col_start + $counter;

  # Get marker data

  $sql  = "SELECT DISTINCT AnalysisGroupMarkerId, State FROM genotypemarkerstate${marker_state_x} ";
  $sql .= "WHERE AnalGroupExtractId = ?";

  $counter = 0;
  for my $extract_id (@extract_id_list) {

    my $anal_ext_id = $ext_id2anal_ext_id_href->{$extract_id};

    my $mkd_start_time = [gettimeofday()];

    my ($r_mk_data_err, $r_mk_data_msg, $marker_data_aref) = read_data($dbh_m_read, $sql, [$anal_ext_id]);

    my $mkd_elapsed_time = tv_interval($mkd_start_time);

    $self->logger->debug("Read marker data: $counter - time: $mkd_elapsed_time");

    if ($r_mk_data_err) {

      $self->logger->debug("Read marker data failed: $r_mk_data_msg");
      my $err_msg = "Unexpected error.";
    
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};
        
      return $data_for_postrun_href;
    }

    push(@header_row, $extract_id);

    if (scalar(@{$marker_data_aref}) == 0) {

      $self->logger->debug("Marker data has no record: AnalGroupExtract ($anal_ext_id) ExtractId ($extract_id)");

      for my $mrk_id (@marker_id_list) {

        my $marker_row_str = $result_data_href->{$mrk_id};
        $marker_row_str   .= ",";

        $result_data_href->{$mrk_id} = $marker_row_str;
      }
    }
    else {

      for my $marker_data_rec (@{$marker_data_aref}) {

        my $marker_id       = $marker_data_rec->{'AnalysisGroupMarkerId'};
        my $marker_state    = $marker_data_rec->{'State'};

        my $marker_row_str = $result_data_href->{$marker_id};
        $marker_row_str   .= ",${marker_state}";

        $result_data_href->{$marker_id} = $marker_row_str;
      }
    }

    $counter += 1;
  }

  $dbh_k_read->disconnect();
  $dbh_m_read->disconnect();

  push(@{$header_row_aref}, \@header_row);

  my $mdata_col_end = $mdata_col_start + $counter - 1;

  $output_meta_href->{'MarkerDataColStart'} = $mdata_col_start;
  $output_meta_href->{'MarkerDataColEnd'}   = $mdata_col_end;

  my $username          = $self->authen->username();
  my $doc_root          = $ENV{'DOCUMENT_ROOT'};
  my $export_data_path  = "${doc_root}/data/$username";
  my $current_runmode   = $self->get_current_runmode();
  my $lock_filename     = "${current_runmode}.lock";
  my $filename          = "export_marker_data_${anal_id}";
  my $csv_file          = "${export_data_path}/${filename}.csv";
  my $result_filename   = "${filename}.csv";

  if ( !(-e $export_data_path) ) {

    mkdir($export_data_path);
  }

  my $eol = "\r\n";

  my $result_filehandle;
  open($result_filehandle, ">:encoding(utf8)", "$csv_file") or die "$csv_file: $!";

  for my $this_header_row (@{$header_row_aref}) {

    print $result_filehandle join(',', @{$this_header_row}) . "$eol";
  }

  for my $marker_id (sort(keys(%{$result_data_href}))) {

    my $marker_row_str = $result_data_href->{$marker_id};
    print $result_filehandle "${marker_row_str}$eol";
  }

  close($result_filehandle);

  my $url = reconstruct_server_url();
  my $elapsed_time = tv_interval($start_time);

  my $href_info = { 'csv' => "$url/data/$username/$result_filename" };

  my $time_info = { 'Message' => "Time taken in seconds: $elapsed_time." };

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'OutputFile'     => [$href_info],
                                           'Info'           => [$time_info],
                                           'OutputFileMeta' => [$output_meta_href],
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub create_genotypemarker_table {

  my $self                      = $_[0];
  my $dbh                       = $_[1];
  my $genotype_marker_state_x   = $_[2];

  my $err = 0;
  my $msg = '';

  my $sql = "CREATE TABLE ";
  $sql   .= "IF NOT EXISTS genotypemarkermeta${genotype_marker_state_x} ";
  $sql   .= "LIKE genotypemarkermetaX";

  my ($create_meta_err, $create_meta_msg) = execute_sql($dbh, $sql);

  if ($create_meta_err) {

    $self->logger->debug("Create genotypemarkermeta${genotype_marker_state_x} failed: $create_meta_msg");
    $msg = $create_meta_msg;
    $err = 1;

    return ($err, $msg);
  }

  $sql  = "CREATE TABLE ";
  $sql .= "IF NOT EXISTS genotypemarkerstate${genotype_marker_state_x} ";
  $sql .= "LIKE genotypemarkerstateX";

  my ($create_state_err, $create_state_msg) = execute_sql($dbh, $sql);

  if ($create_state_err) {

    $self->logger->debug("Create genotypemarkerstate${genotype_marker_state_x} failed: $create_state_msg");
    $msg = $create_meta_msg;
    $err = 1;

    return ($err, $msg);
  }

  # Successful
  return ($err, $msg);
}

sub delete_analysisgroup_data {

  my $self           = $_[0];
  my $dbh            = $_[1];
  my $anal_id        = $_[2];
  my $marker_state_x = $_[3];

  my $sql = "DELETE FROM genotypemarkermeta${marker_state_x} ";
  $sql   .= "WHERE AnalysisGroupMarkerId IN ";
  $sql   .= "(SELECT AnalysisGroupMarkerId FROM analysisgroupmarker WHERE AnalysisGroupId = ?)";

  my $err = 0;
  my $msg = '';

  my $del_meta_start_time = [gettimeofday()];

  my $sth = $dbh->prepare($sql);
  $sth->execute($anal_id);
  my $nb_rows_affected = $sth->rows;

  my $del_meta_elapsed_time = tv_interval($del_meta_start_time);

  $self->logger->debug("Delete marker meta data time: $del_meta_elapsed_time");

  if ($dbh->err()) {

    my $del_marker_meta_msg = $dbh->errstr();
    $self->logger->debug("Delete genotypemarkermeta${marker_state_x} records failed: $del_marker_meta_msg");
    $err = 1;
    $msg = $del_marker_meta_msg;

    return ($err, $msg);
  }

  $self->logger->debug("Number of marker meta records deleted: $nb_rows_affected");

  if ($nb_rows_affected > $MARKER_META_OPT_THRESHOLD) {

    $sql = "OPTIMIZE TABLE genotypemarkermeta${marker_state_x}";

    my $opt_meta_start_time = [gettimeofday()];

    my ($opt_marker_meta_err, $opt_marker_meta_msg) = execute_sql($dbh, $sql, []);

    my $opt_meta_elapsed_time = tv_interval($opt_meta_start_time);

    $self->logger->debug("Optimise marker meta time: $opt_meta_elapsed_time");

    if ($opt_marker_meta_err) {

      $self->logger->debug("Optimise genotypemarkermeta${marker_state_x} failed: $opt_marker_meta_msg");
      $err = 1;
      $msg = $opt_marker_meta_msg;

      return ($err, $msg);
    }
  }
  else {

    $self->logger->debug("No need to optimise genotypemarkermeta${marker_state_x}");
  }

  $sql  = "DELETE FROM genotypemarkerstate${marker_state_x} ";
  $sql .= "WHERE AnalysisGroupMarkerId IN ";
  $sql .= "(SELECT AnalysisGroupMarkerId FROM analysisgroupmarker WHERE AnalysisGroupId = ?)";

  my $del_state_start_time = [gettimeofday()];

  $sth = $dbh->prepare($sql);
  $sth->execute($anal_id);
  $nb_rows_affected = $sth->rows;

  my $del_state_elapsed_time = tv_interval($del_state_start_time);

  $self->logger->debug("Delete marker state time: $del_state_elapsed_time");

  if ($dbh->err()) {

    my $del_marker_state_msg = $dbh->errstr();
    $self->logger->debug("Delete genotypemarkerstate${marker_state_x} records failed: $del_marker_state_msg");
    $err = 1;
    $msg = $del_marker_state_msg;

    return ($err, $msg);
  }

  $self->logger->debug("Number of marker data records deleted: $nb_rows_affected");

  if ($nb_rows_affected > $MARKER_STATE_OPT_THRESHOLD) {

    $sql = "OPTIMIZE TABLE genotypemarkerstate${marker_state_x}";

    my $opt_marker_state_start_time = [gettimeofday()];

    my ($opt_marker_state_err, $opt_marker_state_msg) = execute_sql($dbh, $sql, []);

    my $opt_marker_state_elapsed_time = tv_interval($opt_marker_state_start_time);

    $self->logger->debug("Optimise genotypemarkerstate${marker_state_x} time: $opt_marker_state_elapsed_time");

    if ($opt_marker_state_err) {

      $self->logger->debug("Optimise genotypemarkerstate${marker_state_x} failed: $opt_marker_state_msg");
      $err = 1;
      $msg = $opt_marker_state_msg;

      return ($err, $msg);
    }
  }
  else {

    $self->logger->debug("No need to optimise genotypemarkerstate${marker_state_x}");
  }

  $sql = 'DELETE FROM analysisgroupmarker WHERE AnalysisGroupId = ?';

  my $del_marker_start_time = [gettimeofday()];

  my ($del_marker_err, $del_marker_msg) = execute_sql($dbh, $sql, [$anal_id]);

  my $del_marker_elapsed_time = tv_interval($del_marker_start_time);

  $self->logger->debug("Delete marker time: $del_marker_elapsed_time");

  if ($del_marker_err) {

    $self->logger->debug("Delete analysisgroupmarker records failed: $del_marker_msg");
    $err = 1;
    $msg = $del_marker_msg;

    return ($err, $msg);
  }

  # Successful
  return ($err, $msg);
}

sub import_marker_dart_fs_runmode {

=pod import_marker_dart_fs_HELP_START
{
"OperationName" : "Import marker data",
"Description": "Import marker data from csv file for analysis group specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Importing marker data for analysisgroup (4) is successful. There are 8382 markers. The number of marker meta column without header: 0. The number of extract column without header: 0.' RunTime='2.652925' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Importing marker data for analysisgroup (4) is successful. There are 8382 markers. The number of marker meta column without header: 0. The number of extract column without header: 0.','RunTime' : '1.934151'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='AnalysisGroup (5) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'AnalysisGroup (5) not found.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "CSV",
"UploadFileParameterName": "uploadfile",
"HTTPParameter": [{"Required": 0, "Name": "Forced", "Description": "Override marker data if already exists for the AnalysisGroupId specified in the URL"}, {"Required": 1, "Name": "", "Description": ""}, {"Required": 1, "Name": "HeaderRow", "Description": "The row number counting from zero where the marker data csv header row can be round. The header row is, for example, like 'CloneID,Sequence,CloneID,Type,Markername,SNP,Chromosome,ChromosomePosition,NumOfAligns,CallrateREF,CallrateSNP,OneRatioREF,OneRatioSNP,NumofRefs,NumofSNPs,NumofHomozygotes,NumofHomozygotesSNP,NumofHomozygotesRef,NumofHeterozygotes,NumofNAzygotes,SNPcall,Rowsum,Countrowsums,46,47,48,49,50,51', where the number 41 to 51 are the DNA extract IDs."}, {"Required": 1, "Name": "MarkerNameCol", "Description": "The column number counting from zero for Marker Name column."}, {"Required": 1, "Name": "SequenceCol", "Description": "The column number counting from zero for Marker Sequence column."}, {"Required": 1, "Name": "MarkerMetaColStart", "Description": "The starting column number counting from zero for the staring Marker meta data columns like Chromosome, Rowsum and Countrowsums."}, {"Required": 1, "Name": "MarkerMetaColEnd", "Description": "The ending column number counting from zero for the ending Marker meta data column."}, {"Required": 1, "Name": "MarkerDataColStart", "Description": "The starting column number counting from zero for the starting Marker data column. Marker data columns have numbers as their headers. These numbers represent the DNA extract Id which is linked to Specimen or Genotype."}, {"Required": 1, "Name": "MarkerDataColEnd", "Description": "The ending column number counting from zero for the last Marker data column. Marker data columns have numbers as their headers. These numbers represent the DNA extract Id which is linked to Specimen or Genotype."} ],
"URLParameter": [{"ParameterName": "id", "Description": "Existing AnalysisGroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self    = shift;
  my $query   = $self->query();
  my $anal_id = $self->param('id');

  my $start_time = [gettimeofday()];

  my $header_row            = $query->param('HeaderRow');

  my $marker_name_col       = $query->param('MarkerNameCol');
  my $sequence_col          = $query->param('SequenceCol');

  my $marker_meta_scol      = $query->param('MarkerMetaColStart');
  my $marker_meta_ecol      = $query->param('MarkerMetaColEnd');

  my $marker_data_scol      = $query->param('MarkerDataColStart');
  my $marker_data_ecol      = $query->param('MarkerDataColEnd');

  my $is_forced = 0;

  if (defined($query->param('Forced'))) {

    if ($query->param('Forced') eq '1') {

      $is_forced = 1;
    }
  }

  my $data_for_postrun_href = {};

  my $dbh_m_read = connect_mdb_read();

  if (!record_existence($dbh_m_read, 'analysisgroup', 'AnalysisGroupId', $anal_id)) {

    my $err_msg = "AnalysisGroup ($anal_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id  = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_anal_ok, $trouble_anal_id_aref) = check_permission($dbh_m_read, 'analysisgroup', 'AnalysisGroupId',
                                                             [$anal_id], $group_id, $gadmin_status,
                                                             $READ_WRITE_PERM);

  if (!$is_anal_ok) {

    my $err_msg = "Permission denied: Group ($group_id) and AnalysisGroup ($anal_id).";
    
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $data_csv_file = $self->authen->get_upload_file();

  my $num_of_col = get_csvfile_num_of_col($data_csv_file);

  $self->logger->debug("Number of columns: $num_of_col");

  my $chk_col_def_data = { 'MarkerNameCol'          => $marker_name_col,
                           'SequenceCol'            => $sequence_col,
                           'MarkerMetaColStart'     => $marker_meta_scol,
                           'MarkerMetaColEnd'       => $marker_meta_ecol,
                           'MarkerDataColStart'     => $marker_data_scol,
                           'MarkerDataColEnd'       => $marker_data_ecol,
  };

  my ($col_def_err, $col_def_err_href) = check_col_def_href( $chk_col_def_data, $num_of_col );

  if ($col_def_err) {

    $self->logger->debug("Check column definition error");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$col_def_err_href]};

    return $data_for_postrun_href;
  }

  my ($missing_err, $missing_href) = check_missing_href( {'HeaderRow' => $header_row} );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  my $sql = '';
  my $sth;

  $sql = 'SELECT ExtractId, AnalGroupExtractId FROM analgroupextract WHERE AnalysisGroupId=?';

  $sth = $dbh_m_read->prepare($sql);
  $sth->execute($anal_id);
  my $extract_id2anal_grp_extract_id_href = $sth->fetchall_hashref('ExtractId');
  $sth->finish();

  my @first_fieldname_list;

  for (my $i = 0; $i < $num_of_col; $i++) {

    push(@first_fieldname_list, "Col$i");
  }

  my $csv_filehandle;
  open($csv_filehandle, "$data_csv_file") or die "Cannot open $data_csv_file: $!";

  my $check_empty_col   = 0;
  my $nb_line_wanted    = $header_row + 1; # get data up to the header row
  my $ignore_line0      = 0;
  my $ignore_header     = 0;

  my ($csv_header_err, $csv_header_msg, $header_section_aref) = csvfh2aref($csv_filehandle,
                                                                           \@first_fieldname_list,
                                                                           $check_empty_col,
                                                                           $nb_line_wanted,
                                                                           $ignore_line0,
                                                                           $ignore_header);

  if ($csv_header_err) {

    $self->logger->debug("Error reading header");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $csv_header_msg}]};

    return $data_for_postrun_href;
  }

  close($csv_filehandle);

  my $header_href = $header_section_aref->[$header_row];

  my $matched_col = {};

  $matched_col->{$marker_name_col}         = 'MarkerName';
  $matched_col->{$sequence_col}            = 'Sequence';

  my @marker_meta_field_list;
  my $nb_no_header_meta_col = 0;

  for (my $i = $marker_meta_scol; $i <= $marker_meta_ecol; $i++) {

    if (length($header_href->{"Col$i"}) == 0) {

      $nb_no_header_meta_col += 1;

      if (!$is_forced) {

        $self->logger->debug("MarkerMeata Column $i has no header");

        my $err_msg = "MarkerMeta Column ($i) has no header.";
      
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
      else {

        next;
      }
    }
    else {

      if ($header_href->{"Col$i"} =~ /\s+/) {

        $self->logger->debug("MarkerMeata Column $i " . $header_href->{"Col$i"} . 'contains space.');

        my $err_msg = "MarkerMeta Column $i (" . $header_href->{"Col$i"} . ') contains space.';
      
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }

    push(@marker_meta_field_list, $header_href->{"Col$i"});
  }

  $self->logger->debug("Marker meta field: " . join(',', @marker_meta_field_list));

  my @marker_data_field_list;
  my $nb_no_header_extract_col = 0;

  for (my $i = $marker_data_scol; $i <= $marker_data_ecol; $i++) {

    if (length($header_href->{"Col$i"}) == 0) {
      
      $nb_no_header_extract_col += 1;

      if (!$is_forced) {

        $self->logger->debug("Extract Column $i has no header");

        my $err_msg = "Extract Column ($i) has no header.";
      
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
      else {

        next;
      }
    }

    my $extract_id = $header_href->{"Col$i"};

    push(@marker_data_field_list, $extract_id);

    if ( !(defined($extract_id2anal_grp_extract_id_href->{$extract_id})) ) {

      my $err_msg = "Extract ($extract_id): not found in analysis group ($anal_id).";

      $self->logger->debug($err_msg);
    
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  $dbh_m_read->disconnect();

  my $dbh_m_write = connect_mdb_write();

  $self->logger->debug("Marker data field: " . join(',', @marker_data_field_list));

  # this analysis group already has data
  $sql = 'SELECT Count(*) FROM analysisgroupmarker WHERE AnalysisGroupId=?';

  my ($r_marker_count_err, $marker_count) = read_cell($dbh_m_write, $sql, [$anal_id]);

  if ($marker_count > 0) {

    if (!$is_forced) {

      my $err_msg = "Forced ($is_forced): AnalysisGroup ($anal_id) already has data.";
      
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    else {

      $sql = 'DELETE FROM analysisgroupmarkermeta WHERE AnalysisGroupId = ?';

      my ($del_analgrpmrkmeta_err, $del_analgrpmrkmeta_msg) = execute_sql($dbh_m_write, $sql, [$anal_id]);

      if ($del_analgrpmrkmeta_err) {

        $self->logger->debug("Delete analysisgroupmarkermeta failed: $del_analgrpmrkmeta_msg");
        my $err_msg = "Unexpected Error.";
    
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }

      $sql  = 'DELETE FROM analysisgroupmarkerfactor ';
      $sql .= 'WHERE AnalysisGroupMarkerId IN ';
      $sql .= '(SELECT AnalysisGroupMarkerId FROM analysisgroupmarker WHERE AnalysisGroupId=?)';

      my ($del_analgrpmrkfactor_err, $del_analgrpmrkfactor_msg) = execute_sql($dbh_m_write, $sql, [$anal_id]);

      if ($del_analgrpmrkfactor_err) {

        $self->logger->debug("Delete analysisgroupmarkerfactor failed: $del_analgrpmrkfactor_msg");
        my $err_msg = "Unexpected Error.";
    
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }

      $sql  = 'DELETE FROM markeralias ';
      $sql .= 'WHERE AnalysisGroupMarkerId IN ';
      $sql .= '(SELECT AnalysisGroupMarkerId FROM analysisgroupmarker WHERE AnalysisGroupId=?)';

      my ($del_mrkalias_err, $del_mrkalias_msg) = execute_sql($dbh_m_write, $sql, [$anal_id]);

      if ($del_mrkalias_err) {

        $self->logger->debug("Delete markeralias failed: $del_mrkalias_msg");

        my $err_msg = "Unexpected Error.";
    
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }

      $sql = 'DELETE FROM analysisgroupmarker WHERE AnalysisGroupId=?';

      my ($del_analmrk_err, $del_analmrk_msg) = execute_sql($dbh_m_write, $sql, [$anal_id]);

      if ($del_analmrk_err) {

        $self->logger->debug("Delete analysisgroupmarker failed: $del_analmrk_msg");

        my $err_msg = "Unexpected Error.";
    
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
  }

  $sql  = 'UPDATE analysisgroup SET ';
  $sql .= 'MarkerNameColumnPosition=?, ';
  $sql .= 'MarkerSequenceColumnPosition=?, ';
  $sql .= 'GenotypeMarkerStateX=-1 ';
  $sql .= 'WHERE AnalysisGroupId=?';

  my ($up_genomrkstate_x_err, $up_genomrkstate_x_msg) = execute_sql($dbh_m_write, $sql,
                                                                    [$marker_name_col, $sequence_col, $anal_id]);

  if ($up_genomrkstate_x_err) {

    $self->logger->debug("Update AnalysisGroupMarkerStateX failed: $up_genomrkstate_x_msg");

    my $err_msg = "Unexpected Error.";
    
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dest_storage_path = $MRK_DATA_STORAGE_PATH . "$anal_id";

  if ( !(-e $dest_storage_path) ) {

    mkdir($dest_storage_path);
  }

  my $marker_score_filename = $dest_storage_path . "/MarkerScore_${anal_id}.csv";

  my $marker_index_filename = $marker_score_filename . '.idx';

  if (-e $marker_score_filename) {

    if (!$is_forced) {

      $self->logger->debug("Marker score file ($marker_score_filename) already exists (need to be forced)");
      my $err_msg = "Marker score file already exists.";
    
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    $self->logger->debug("Fored: unlink/delete: $marker_score_filename");
    my $cnt = unlink($marker_score_filename);

    if ($cnt == 1) {

      $self->logger->debug("Unlink $marker_score_filename is successful");
    }
    else {

      $self->logger->debug("Unlink $marker_score_filename failed");
      my $err_msg = "Unexpected Error.";
    
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    $cnt = unlink($marker_index_filename);

    if ($cnt == 1) {

      $self->logger->debug("Unlink $marker_index_filename is successful");
    }
    else {

      $self->logger->debug("Unlink $marker_index_filename failed");
      my $err_msg = "Unexpected Error.";
    
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  # Update Column number in db

  for (my $i = $marker_data_scol; $i <= $marker_data_ecol; $i++) {

    if (length($header_href->{"Col$i"}) > 0) {

      my $extract_id = $header_href->{"Col$i"};

      $sql  = 'UPDATE analgroupextract SET ';
      $sql .= 'ColumnPosition = ? ';
      $sql .= 'WHERE AnalysisGroupId = ? AND ExtractId = ?';
    
      my ($up_anal_grp_ext_err, $up_anal_grp_ext_msg) = execute_sql($dbh_m_write, $sql, [$i, $anal_id, $extract_id]);

      if ($up_anal_grp_ext_err) {

        $self->logger->debug("Update analgroupextract failed: $up_anal_grp_ext_msg");

        my $err_msg = "Unexpected Error.";
    
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
  }

  my $dbh_k_write = connect_kdb_write();

  # Check marker meta data virtual column existence. if it does not exits, it will be created
  my $meta_fieldname2factor_id_href = {};

  for my $meta_field (@marker_meta_field_list) {

    $sql = 'SELECT FactorId FROM factor WHERE TableNameOfFactor=? AND FactorName=?';

    my ($r_factor_id_err, $factor_id) = read_cell($dbh_k_write, $sql, ['genotypemarkermetaX', "$meta_field"]);

    if ($r_factor_id_err) {

      $self->logger->debug("Read FactorId failed");

      my $err_msg = 'Unexpected error.';
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};
        
      return $data_for_postrun_href;
    }

    $self->logger->debug("$meta_field  - factorid: $factor_id");

    if (length($factor_id) == 0) {

      my $factor_caption = $meta_field;
      my $factor_desc    = "Created automatically by import/makerdata/dart for $meta_field";
      my $factor_dtype   = "STRING";
      my $can_be_null    = 1;
      my $max_length     = 32;
      # Automatically created virtual columns are owned by admin
      my $own_group_id   = 0;
      my $is_public      = 1;

      $sql  = 'INSERT INTO factor SET ';
      $sql .= 'FactorName=?, ';
      $sql .= 'FactorCaption=?, ';
      $sql .= 'FactorDescription=?, ';
      $sql .= 'TableNameOfFactor=?, ';
      $sql .= 'FactorDataType=?, ';
      $sql .= 'CanFactorHaveNull=?, ';
      $sql .= 'FactorValueMaxLength=?, ';
      $sql .= 'OwnGroupId=?, ';
      $sql .= 'Public=?';
      
      my $add_vcol_sth = $dbh_k_write->prepare($sql);
      $add_vcol_sth->execute($meta_field, $factor_caption, $factor_desc,
                             'genotypemarkermetaX', $factor_dtype, $can_be_null,
                             $max_length, $own_group_id, $is_public );
      

      if (!$dbh_k_write->err()) {

        $factor_id = $dbh_k_write->last_insert_id(undef, undef, 'factor', 'FactorId');
        $self->logger->debug("FactorId: $factor_id");
      }
      else {

        $self->logger->debug("Insert into factor failed");
        my $err_msg = 'Unexpected error.';
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};
        
        return $data_for_postrun_href;
      }
      $add_vcol_sth->finish();
    }
    
    $meta_fieldname2factor_id_href->{$meta_field} = $factor_id;
  }

  $dbh_k_write->disconnect();

  $sql  = 'INSERT INTO analysisgroupmarkermeta ';
  $sql .= '(AnalysisGroupId,FactorId,ColumnPosition) ';
  $sql .= 'VALUES ';

  for (my $i = $marker_meta_scol; $i <= $marker_meta_ecol; $i++) {

    if (length($header_href->{"Col$i"}) > 0) {

      my $meta_col_name  = $header_href->{"Col$i"};
      my $meta_factor_id = $meta_fieldname2factor_id_href->{$meta_col_name};

      $sql .= "(${anal_id},${meta_factor_id},${i}),";
    }
  }

  $self->logger->debug("Insert analysisgroupmarkermeta SQL: $sql");

  $sql =~ s/\),$/\)/; # remove trailing comma

  my ($in_analgrpmrkmeta_err, $in_analgrpmrkmeta_msg) = execute_sql($dbh_m_write, $sql, []);

  if ($in_analgrpmrkmeta_err) {

    $self->logger->debug("Insert meta column info failed: $in_analgrpmrkmeta_msg");

    my $err_msg = "Unexpected Error.";
    
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }
  
  # mached_col variable should have been built. now it is time read the data from
  # the upload file again after all the tables are ready for data insert.

  my $fieldname_list_aref = [];
  
  for (my $i = 0; $i < $num_of_col; $i++) {

    if ($matched_col->{$i}) {

      push(@{$fieldname_list_aref}, $matched_col->{$i});
    }
    else {

      push(@{$fieldname_list_aref}, 'null');
    }
  }

  $self->logger->debug("Final field list: " . join(',', @{$fieldname_list_aref}));

  
  # Copy the upload file from tmp to its proper location and keep only the last header row
  # header_row + 1 because copy_file works from 1 instead of 0 as its first line.

  my ($cp_err, $cp_msg) = copy_file($data_csv_file, $marker_score_filename, $header_row + 1);

  if ($cp_err) {

    $self->logger->debug("Copy file from $data_csv_file to $marker_score_filename (extra header rows) failed: $cp_msg");

    my $err_msg = "Unexpected Error.";
    
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $marker_score_filehandle;
  my $index_filehandle;

  open($index_filehandle, "+>$marker_index_filename") or 
      die "Cannot open $marker_index_filename for read/write: $!\n";

  open($marker_score_filehandle, "$marker_score_filename") or die "Cannot open $marker_score_filename: $!";

  my $total_nb_line = build_seek_index($marker_score_filehandle, $index_filehandle);

  $self->logger->debug("Total number of lines: $total_nb_line");

  $check_empty_col   = 0;
  $ignore_line0      = 0;
  $ignore_header     = 0;
  $nb_line_wanted    = $NB_RECORD_BULK_INSERT;

  if ($nb_line_wanted > $total_nb_line) {

    $nb_line_wanted = $total_nb_line;
  }

  my $total_marker_line = 0;
  
  # The first line is 1
  my $start_line = 2;

  while ($start_line <= $total_nb_line) {

    if ( ($start_line + $nb_line_wanted) > $total_nb_line ) {

      $nb_line_wanted = $total_nb_line - $start_line + 1;
    }

    $self->logger->debug("Start line: $start_line - Number of lines wanted: $nb_line_wanted");

    my ($csv_data_err, $csv_data_msg, $marker_data_aref) = csvfh2aref_index_sline($marker_score_filehandle,
                                                                                  $index_filehandle,
                                                                                  $fieldname_list_aref,
                                                                                  $check_empty_col,
                                                                                  $start_line,
                                                                                  $nb_line_wanted);

    if ($csv_data_err) {
      
      $self->logger->debug("Error reading marker data: $csv_data_msg.");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $csv_data_msg}]};

      return $data_for_postrun_href;
    }

    my $nb_marker_line_read = scalar(@{$marker_data_aref});

    $total_marker_line += $nb_marker_line_read;

    $sql  = 'INSERT INTO analysisgroupmarker ';
    $sql .= '(AnalysisGroupId,MarkerName,MarkerSequence,LineNumber) ';
    $sql .= 'VALUES ';

    for my $marker_def_href (@{$marker_data_aref}) {

      my $mrk_name = $marker_def_href->{'MarkerName'};
      my $mrk_seq  = $marker_def_href->{'Sequence'};
      my $line_num = $marker_def_href->{'LineNum'};

      $sql .= qq|(${anal_id},'${mrk_name}','${mrk_seq}',${line_num}),|;
    }

    $sql =~ s/\),$/\)/; # remove trailing comma

    my ($in_mrk_def_err, $in_mrk_def_msg) = execute_sql($dbh_m_write, $sql, []);

    if ($in_mrk_def_err) {

      $self->logger->debug("Insert marker definition failed: $in_mrk_def_msg");

      my $err_msg = "Unexpected Error.";
    
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    $self->logger->debug("Number of marker data lines: " . $nb_marker_line_read);


    $start_line += $NB_RECORD_BULK_INSERT;
  }

  $self->logger->debug("Total number marker line: $total_marker_line");

  close($csv_filehandle);
  close($index_filehandle);

  $dbh_m_write->disconnect();

  my $elapsed_time = tv_interval($start_time);

  my $info_msg = "Importing marker data for analysisgroup ($anal_id) is successful. ";
  $info_msg   .= "There are $total_marker_line markers. The number of marker meta column without header: ";
  $info_msg   .= "$nb_no_header_meta_col. The number of extract column without header: $nb_no_header_extract_col.";

  my $info_msg_aref = [{'Message' => $info_msg, 'RunTime' => "$elapsed_time"}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub export_marker_dart_fs_runmode {

=pod export_marker_dart_fs_HELP_START
{
"OperationName" : "Export marker data",
"Description": "Export marker data into csv file for analysis group specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><OutputFileMeta MarkerDataColEnd='25' MarkerMetaColEnd='19' LastHeaderRow='4' MarkerDataColStart='20' MarkerNameCol='1' MarkerSequenceCol='0' MarkerMetaColStart='2' NumberOfMarkers='2' /><Info Message='Time taken in seconds: 0.0241400000000001.' RunTime='0.0241400000000001' /><OutputFile csv='http://kddart.example.com/data/admin/export_marker_data_5_2014-08-12T110903-252.csv' /></DATA>",
"SuccessMessageJSON": "{'OutputFileMeta' : [{'MarkerDataColEnd' : 25,'NumberOfMarkers' : 2,'MarkerMetaColEnd' : 19,'LastHeaderRow' : 4,'MarkerDataColStart' : 20,'MarkerSequenceCol' : 0,'MarkerNameCol' : 1,'MarkerMetaColStart' : 2}],'Info' : [{'Message' : 'Time taken in seconds: 0.023848.','RunTime' : '0.023848'}],'OutputFile' : [{'csv' : 'http://kddart.example.com/data/admin/export_marker_data_5_2014-08-12T111114-145.csv'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='AnalysisGroup (5) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'AnalysisGroup (5) not found.'}]}"}],
"HTTPParameter": [{"Required": 0, "Name": "MarkerMetaFieldList", "Description": "Filtering parameter for marker meta fields"}, {"Required": 0, "Name": "MarkerDataFieldList", "Description": "Filtering parameter for marker data columns"}, {"Required": 0, "Name": "Filtering", "Description": "This is a parameter for marker filtering. It can filter on MarkerName, MarkerSequence, and the imported marker meta data fields."}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing AnalysisGroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self    = shift;
  my $query   = $self->query();
  my $anal_id = $self->param('id');

  my $mrk_meta_field_list_csv = '';

  if (defined $query->param('MarkerMetaFieldList')) {

    $mrk_meta_field_list_csv = $query->param('MarkerMetaFieldList');
  }

  my $mrk_data_field_list_csv = '';

  if (defined $query->param('MarkerDataFieldList')) {

    $mrk_data_field_list_csv = $query->param('MarkerDataFieldList');
  }

  my $filtering_csv = '';
  
  if (defined $query->param('Filtering')) {

    $filtering_csv = $query->param('Filtering');
  }

  $self->logger->debug("Filtering String: $filtering_csv");

  my $start_time = [gettimeofday()];

  my $data_for_postrun_href = {};

  my $dbh_m_read = connect_mdb_read();

  if (!record_existence($dbh_m_read, 'analysisgroup', 'AnalysisGroupId', $anal_id)) {

    my $err_msg = "AnalysisGroup ($anal_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id  = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_anal_ok, $trouble_anal_id_aref) = check_permission($dbh_m_read, 'analysisgroup', 'AnalysisGroupId',
                                                             [$anal_id], $group_id, $gadmin_status,
                                                             $READ_PERM);

  if (!$is_anal_ok) {

    my $err_msg = "Permission denied: Group ($group_id) and AnalysisGroup ($anal_id).";
    
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dest_storage_path = $MRK_DATA_STORAGE_PATH . "$anal_id";

  if ( !(-e $dest_storage_path) ) {

    $self->logger->debug("Storage directory $dest_storage_path: not found.");

    my $err_msg = "AnalysisGroup ($anal_id) has no data.";
    
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $marker_score_filename = $dest_storage_path . "/MarkerScore_${anal_id}.csv";

  my $marker_index_filename = $marker_score_filename . '.idx';

  if ( !(-e $marker_score_filename) ) {

    $self->logger->debug("No marker data file: $marker_score_filename.");

    my $err_msg = "Unexpected Error.";
    
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }
  else {

    if ( !(-e $marker_index_filename) ) {

      $self->logger->debug("Marker index file $marker_index_filename: not found.");

      my $err_msg = "Unexpected Error.";
    
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $field_idx_lookup_href       = {};

  my $dbh_k_read = connect_kdb_read();

  my $sql = 'SELECT analgroupextract.ExtractId, ColumnPosition, PlateName, ';
  $sql   .= 'CONCAT(WellRow,WellCol) AS WellPosition, ItemGroupId, GenotypeId ';
  $sql   .= 'FROM analgroupextract LEFT JOIN extract ON analgroupextract.ExtractId = extract.ExtractId ';
  $sql   .= 'LEFT JOIN plate ON extract.PlateId = plate.PlateId ';
  $sql   .= 'WHERE AnalysisGroupId=? ';
  $sql   .= 'ORDER BY ColumnPosition ASC';

  my ($read_ext_col_pos_err, $read_ext_col_pos_msg, $extract_col_data) = read_data($dbh_m_read, $sql, [$anal_id]);

  if ($read_ext_col_pos_err) {

    $self->logger->debug("Read extract column position failed: $read_ext_col_pos_msg");

    my $err_msg = "Unexpected Error.";
    
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $mrk_data_col_start = $extract_col_data->[0]->{'ColumnPosition'};
  my $mrk_data_col_end   = $extract_col_data->[-1]->{'ColumnPosition'};

  my @plate_name_header_row;
  my @well_pos_header_row;
  my @item_grp_name_header_row;
  my @geno_name_header_row;

  for (my $i = 0; $i <= $mrk_data_col_end; $i++) {

    push(@plate_name_header_row, '*');
    push(@well_pos_header_row, '*');
    push(@item_grp_name_header_row, '*');
    push(@geno_name_header_row, '*');
  }

  # Header row field names

  $plate_name_header_row[$mrk_data_col_start-1]    = 'PlateName';
  $well_pos_header_row[$mrk_data_col_start-1]      = 'WellPosition';
  $item_grp_name_header_row[$mrk_data_col_start-1] = 'ItemGroupName';
  $geno_name_header_row[$mrk_data_col_start-1]     = 'GenotypeName';

  for my $extract_rec (@{$extract_col_data}) {

    my $extract_id = $extract_rec->{'ExtractId'};
    my $col_pos    = $extract_rec->{'ColumnPosition'};
    my $itm_grp_id = $extract_rec->{'ItemGroupId'};
    my $plate_name = $extract_rec->{'PlateName'};
    my $well_pos   = $extract_rec->{'WellPosition'};

    my $item_group_name = read_cell_value($dbh_k_read, 'itemgroup', 'ItemGroupName', 'ItemGroupId', $itm_grp_id);

    my $geno_name = '';

    if (defined($extract_rec->{'GenotypeId'})) {

      my $geno_id = $extract_rec->{'GenotypeId'};
      $geno_name  = read_cell_value($dbh_k_read, 'genotype', 'GenotypeName', 'GenotypeId', $geno_id);
    }

    $plate_name_header_row[$col_pos]    = $plate_name;
    $well_pos_header_row[$col_pos]      = $well_pos;
    $item_grp_name_header_row[$col_pos] = $item_group_name;
    $geno_name_header_row[$col_pos]     = $geno_name;

    $field_idx_lookup_href->{"$extract_id"} = $col_pos;
  }

  my $all_mrk_data_field_csv = join(',', keys(%{$field_idx_lookup_href}));

  $sql    = 'SELECT MarkerNameColumnPosition, MarkerSequenceColumnPosition ';
  $sql   .= 'FROM analysisgroup ';
  $sql   .= 'WHERE AnalysisGroupId=?';

  my ($read_anal_col_pos_err, $read_anal_col_pos_msg, $marker_col_data) = read_data($dbh_m_read, $sql, [$anal_id]);

  if ($read_anal_col_pos_err) {

    $self->logger->debug("Read marker column position failed: $read_anal_col_pos_msg");

    my $err_msg = "Unexpected Error.";
    
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $marker_col   = $marker_col_data->[0]->{'MarkerNameColumnPosition'};
  my $sequence_col = $marker_col_data->[0]->{'MarkerSequenceColumnPosition'};

  $field_idx_lookup_href->{'MarkerName'}     = $marker_col;
  $field_idx_lookup_href->{'MarkerSequence'} = $sequence_col;

  $sql  = 'SELECT FactorId, ColumnPosition ';
  $sql .= 'FROM analysisgroupmarkermeta ';
  $sql .= 'WHERE AnalysisGroupId=? ';
  $sql .= 'ORDER BY ColumnPosition ASC';

  my ($read_meta_col_pos_err, $read_meta_col_pos_msg, $marker_meta_col_data) = read_data($dbh_m_read, $sql, [$anal_id]);

  if ($read_meta_col_pos_err) {

    $self->logger->debug("Read marker meta column position failed: $read_meta_col_pos_msg");

    my $err_msg = "Unexpected Error.";
    
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $mrk_meta_col_start = $marker_meta_col_data->[0]->{'ColumnPosition'};
  my $mrk_meta_col_end   = $marker_meta_col_data->[-1]->{'ColumnPosition'};

  my @filterable_fieldlist = ('MarkerName', 'MarkerSequence');

  for my $marker_meta_rec (@{$marker_meta_col_data}) {

    my $factor_id = $marker_meta_rec->{'FactorId'};
    my $col_pos   = $marker_meta_rec->{'ColumnPosition'};

    my $factor_name = read_cell_value($dbh_k_read, 'factor', 'FactorName', 'FactorId', $factor_id);

    $field_idx_lookup_href->{$factor_name}       = $col_pos;

    push(@filterable_fieldlist, $factor_name);
  }

  my $all_mrk_meta_field_csv = join(',', @filterable_fieldlist);

  $dbh_k_read->disconnect();

  my $output_meta_href = {};

  $output_meta_href->{'MarkerMetaColStart'} = $mrk_meta_col_start;
  $output_meta_href->{'MarkerMetaColEnd'}   = $mrk_meta_col_end;
  $output_meta_href->{'MarkerNameCol'}      = $marker_col;
  $output_meta_href->{'MarkerSequenceCol'}  = $sequence_col;
  $output_meta_href->{'MarkerDataColStart'} = $mrk_data_col_start;
  $output_meta_href->{'MarkerDataColEnd'}   = $mrk_data_col_end;
  $output_meta_href->{'LastHeaderRow'}      = 4;

  my $field_list_csv = '';

  if (length($mrk_meta_field_list_csv) > 0) {

    my @mrk_meta_field_list = split(',', $mrk_meta_field_list_csv);

    if (length($mrk_data_field_list_csv) > 0) {

      my @mrk_data_field_list = split(',', $mrk_data_field_list_csv);
      $field_list_csv = join(',', @mrk_meta_field_list) . ',' . join(',', @mrk_data_field_list);
    }
    else {

      $field_list_csv = join(',', @mrk_meta_field_list) . ',' . $all_mrk_data_field_csv;
    }
  }
  else {

    if (length($mrk_data_field_list_csv) > 0) {

      my @mrk_data_field_list = split(',', $mrk_data_field_list_csv);
      $field_list_csv = $all_mrk_meta_field_csv . ',' . join(',', @mrk_data_field_list);
    }
  }

  my @field_idx_list;

  if (length($field_list_csv) > 0) {
 
    my @fieldname_list = keys(%{$field_idx_lookup_href});

    my ($sel_field_err, $sel_field_msg, $sel_field_list) = parse_selected_field($field_list_csv,
                                                                                \@fieldname_list,
                                                                                'MarkerName');

    if ($sel_field_err) {

      $self->logger->debug("Parse selected fields error: $sel_field_msg");
    
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    for my $sel_fieldname (@{$sel_field_list}) {

      push(@field_idx_list, $field_idx_lookup_href->{$sel_fieldname});
    }
  }

  my $filtering_str = '';

  if (length($filtering_csv) > 0) {

    $self->logger->debug("Filtering str: $filtering_csv");

    my ($filtering_err, $filtering_msg, $perl_exp) = parse_marker_filtering($field_idx_lookup_href,
                                                                            \@filterable_fieldlist,
                                                                            $filtering_csv);

    if ($filtering_err) {

      $self->logger->debug("Parsing filtering failed: $filtering_msg");

      my $err_msg = $filtering_msg;

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    $self->logger->debug("Perl filtering exp: $perl_exp");

    $filtering_str = $perl_exp;
  }

  my $rand_num          = makerandom(Size => 8, Strength => 0);
  my $cur_dt            = DateTime->now( time_zone => $TIMEZONE );
  $cur_dt               =~ s/\://g;

  my $username          = $self->authen->username();
  my $doc_root          = $ENV{'DOCUMENT_ROOT'};
  my $export_data_path  = "${doc_root}/data/$username";
  my $current_runmode   = $self->get_current_runmode();
  my $lock_filename     = "${current_runmode}.lock";
  my $filename          = "export_marker_data_${anal_id}_${cur_dt}-${rand_num}";
  my $csv_file          = "${export_data_path}/${filename}.csv";
  my $result_filename   = "${filename}.csv";

  my $eol = "\r\n";

  my $result_filehandle;
  my $marker_filehandle;
  my $marker_idx_filehandle;

  my $nb_marker = 0;

  if (scalar(@field_idx_list) == 0 && length($filtering_str) == 0) {

    $self->logger->debug("No filtering and no field list");

    open($result_filehandle, ">$csv_file") or die "Cannot open $csv_file for writing: $!";

    print $result_filehandle join(',', @plate_name_header_row) . $eol;
    print $result_filehandle join(',', @well_pos_header_row) . $eol;
    print $result_filehandle join(',', @item_grp_name_header_row) . $eol;
    print $result_filehandle join(',', @geno_name_header_row) . $eol;

    close($result_filehandle);

    my ($cp_err, $cp_msg) = copy_file($marker_score_filename, $csv_file, 1, '>>');

    if ($cp_err) {

      $self->logger->debug("Copy $marker_score_filename to $result_filename failed: $cp_msg");

      my $err_msg = "Unexpected Error.";
    
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    $sql  = 'SELECT COUNT(AnalysisGroupId) FROM analysisgroupmarker ';
    $sql .= 'WHERE AnalysisGroupId=?';

    my ($read_nb_marker_err, $count_marker) = read_cell($dbh_m_read, $sql, [$anal_id]);

    if ($read_nb_marker_err) {

      $self->logger->debug("Count the number of markers failed");

      my $err_msg = "Unexpected Error.";
    
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    $nb_marker = $count_marker;
  }
  else {

    if (length($filtering_str) == 0) {

      $filtering_str = '1 == 1';
    }

    my $access_by_line_yn = 0;
    my $line_aref         = [];

    if ($filtering_csv =~ /MarkerName\s+eq\s+['|"](.*)['|"]/) {

      $self->logger->debug("Exact MarkerName retrieval");

      my $mrk_name = $1;
      $sql  = 'SELECT LineNumber ';
      $sql .= 'FROM analysisgroupmarker ';
      $sql .= "WHERE AnalysisGroupId=? AND MarkerName='$mrk_name' ";
      $sql .= 'ORDER BY LineNumber ASC';

      my ($read_lnum_err, $read_lnum_msg, $line_num_data) = read_data($dbh_m_read, $sql, [$anal_id]);

      if ($read_lnum_err) {

        $self->logger->debug("Read line number of exact match failed: $read_lnum_msg");

        my $err_msg = "Unexpected Error.";
        
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }

      $access_by_line_yn = 1;

      if (scalar(@{$line_num_data}) == 0) {

        # No marker match
        $filtering_str = '1 == 0';
        push(@{$line_aref}, 1);
      }
      else {

        for my $line_num_rec (@{$line_num_data}) {

          push(@{$line_aref}, $line_num_rec->{'LineNumber'});
        }
      }
    }

    if (scalar(@field_idx_list) == 0) {

      for my $field_name (keys(%{$field_idx_lookup_href})) {

        push(@field_idx_list, $field_idx_lookup_href->{$field_name});
      }
    }

    my @sorted_field_idx_list = sort {$a <=> $b} @field_idx_list;

    my $new_col_counter          = 0;

    my $mrk_name_col_found       = 0;
    my $mrk_seq_col_found        = 0;
    my $mrk_meta_scol_found      = 0;
    my $mrk_meta_ecol_found      = 0;
    my $mrk_data_scol_found      = 0;
    my $mrk_data_ecol_found      = 0;

    my $new_mrk_name_col         = -1;
    my $new_mrk_seq_col          = -1;
    my $new_mrk_meta_scol        = -1;
    my $new_mrk_meta_ecol        = -1;
    my $new_mrk_data_scol        = -1;
    my $new_mrk_data_ecol        = -1;

    my @header_field_idx_list = @sorted_field_idx_list;

    for my $field_idx (@sorted_field_idx_list) {

      if ($field_idx == $marker_col) {

        $new_mrk_name_col = $new_col_counter;
        $mrk_name_col_found = 1;
      }

      if ($field_idx == $sequence_col) {

        $new_mrk_seq_col = $new_col_counter;
        $mrk_seq_col_found = 1;
      }

      if ($field_idx >= $mrk_meta_col_start && $field_idx < $mrk_data_col_start) {

        if (!($mrk_meta_scol_found)) {

          $new_mrk_meta_scol = $new_col_counter;
          $mrk_meta_scol_found = 1;
        }

        if ($field_idx <= $mrk_meta_col_end) {

          $new_mrk_meta_ecol = $new_col_counter;
          $mrk_meta_ecol_found = 1;
        }
      }

      if ($field_idx >= $mrk_data_col_start) {

        if (!($mrk_data_scol_found)) {

          $new_mrk_data_scol = $new_col_counter;
          $mrk_data_scol_found = 1;
        }

        if ($field_idx <= $mrk_data_col_end) {

          $new_mrk_data_ecol = $new_col_counter;
          $mrk_data_ecol_found = 1;
        }
      }

      $new_col_counter += 1;
    }

    # This is to make sure header row field names are printed

    $header_field_idx_list[$new_mrk_data_scol-1] = $mrk_data_col_start-1;

    $output_meta_href->{'MarkerNameCol'} = $new_mrk_name_col;

    if ($mrk_seq_col_found) {

      $output_meta_href->{'MarkerSequenceCol'}  = $new_mrk_seq_col;
    }
    else {

      delete($output_meta_href->{'MarkerSequenceCol'});
    }

    if ($mrk_meta_scol_found && $mrk_meta_ecol_found) {

      $output_meta_href->{'MarkerMetaColStart'} = $new_mrk_meta_scol;
      $output_meta_href->{'MarkerMetaColEnd'}   = $new_mrk_meta_ecol;
    }
    elsif ( !($mrk_meta_scol_found) && !($mrk_meta_ecol_found) ) {

      delete($output_meta_href->{'MarkerMetaColStart'});
      delete($output_meta_href->{'MarkerMetaColEnd'});
    }
    else {

      $self->logger->debug("Inconsistent new marker meta start and end column found status");

      my $err_msg = "Unexpected Error.";
        
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if ($mrk_data_scol_found && $mrk_data_ecol_found) {

      $output_meta_href->{'MarkerDataColStart'} = $new_mrk_data_scol;
      $output_meta_href->{'MarkerDataColEnd'}   = $new_mrk_data_ecol;
    }
    elsif ( !($mrk_data_scol_found) && !($mrk_data_ecol_found) ) {

      delete($output_meta_href->{'MarkerDataColStart'});
      delete($output_meta_href->{'MarkerDataColEnd'});
    }
    else {

      $self->logger->debug("Inconsistent new marker data start and end column found status");

      my $err_msg = "Unexpected Error.";
        
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    $self->logger->debug("Field Index List: " . join(',', @sorted_field_idx_list));

    open($marker_filehandle, "< $marker_score_filename") or die "Cannot open $marker_score_filename for reading: $!";
    open($marker_idx_filehandle, "< $marker_index_filename") or die "Cannot open $marker_index_filename for reading: $!";

    open($result_filehandle, ">:encoding(utf8)", "$csv_file") or die "Cannot open $csv_file for writing: $!";

    # Header row field name is in a position marker data col start - 1 which is on top of the last marker meta
    # data column. If the last marker meta column is not selected, the header row field name is not printed neither.
    # These header row field names are 'PlateName', 'WellPosition', 'ItemGroupName', 'GenotypeName'.
    # The solution to make sure that these header row field names are printed to the output file in all cases,
    # is to makre sure that mkr_data_col_start-1 is in the separate field idx list which is used specifically 
    # for printing the headers.
    
    my @sorted_header_field_idx_list = sort {$a <=> $b} @header_field_idx_list;

    print $result_filehandle join(',', @plate_name_header_row[@sorted_header_field_idx_list]) . $eol;
    print $result_filehandle join(',', @well_pos_header_row[@sorted_header_field_idx_list]) . $eol;
    print $result_filehandle join(',', @item_grp_name_header_row[@sorted_header_field_idx_list]) . $eol;
    print $result_filehandle join(',', @geno_name_header_row[@sorted_header_field_idx_list]) . $eol;

    my $file_header_row_line = <$marker_filehandle>;

    chomp($file_header_row_line);

    my @COLS = split(',', $file_header_row_line);

    print $result_filehandle join(',', @COLS[@sorted_field_idx_list]) . $eol;

    # Now reading marker_filehandle will start from the second line if read_by_line is not set to 1
    my ($filter_mrk_err, $filter_mrk_msg, $nb_row_matched) = filter_csv($marker_filehandle,
                                                                        $marker_idx_filehandle,
                                                                        $result_filehandle,
                                                                        $filtering_str,
                                                                        \@sorted_field_idx_list,
                                                                        $eol,
                                                                        $access_by_line_yn,
                                                                        $line_aref
        );

    $nb_marker = $nb_row_matched;
    
    close($result_filehandle);

    close($marker_idx_filehandle);
    close($marker_filehandle);
  }

  $dbh_m_read->disconnect();

  my $url = reconstruct_server_url();
  my $elapsed_time = tv_interval($start_time);

  my $href_info = { 'csv' => "$url/data/$username/$result_filename" };

  my $time_info = { 'Message' => "Time taken in seconds: $elapsed_time.", 'RunTime' => "$elapsed_time" };

  $output_meta_href->{'NumberOfMarkers'}    = $nb_marker;

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'OutputFile'     => [$href_info],
                                           'Info'           => [$time_info],
                                           'OutputFileMeta' => [$output_meta_href],
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_marker_meta_field_runmode {

=pod list_marker_meta_field_HELP_START
{
"OperationName" : "List metadata fields",
"Description": "List metadata fields of marker table for analysis group specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><MarkerMetaField Required='0' FactorDescription='SNP' FactorId='1' FactorDataType='STRING' FactorCaption='SNP' FactorUnit='' FactorValueMaxLength='32' FactorName='SNP' /><MarkerMetaField Required='0' FactorDescription='Chromosome' FactorId='2' FactorDataType='STRING' FactorCaption='Chromosome' FactorName='Chromosome' FactorValueMaxLength='32' FactorUnit='' /><MarkerMetaField Required='0' FactorDescription='ChromosomePosition' FactorId='3' FactorDataType='STRING' FactorCaption='ChromosomePosition' FactorName='ChromosomePosition' FactorValueMaxLength='32' FactorUnit='' /><MarkerMetaField Required='0' FactorDescription='NumOfAligns' FactorId='4' FactorDataType='STRING' FactorCaption='NumOfAligns' FactorName='NumOfAligns' FactorValueMaxLength='32' FactorUnit='' /><MarkerMetaField Required='0' FactorDescription='CallrateREF' FactorId='5' FactorDataType='STRING' FactorCaption='CallrateREF' FactorName='CallrateREF' FactorValueMaxLength='32' FactorUnit='' /><MarkerMetaField Required='0' FactorDescription='CallrateSNP' FactorId='6' FactorDataType='STRING' FactorCaption='CallrateSNP' FactorName='CallrateSNP' FactorValueMaxLength='32' FactorUnit='' /><MarkerMetaField Required='0' FactorDescription='OneRatioREF' FactorId='7' FactorDataType='STRING' FactorCaption='OneRatioREF' FactorName='OneRatioREF' FactorValueMaxLength='32' FactorUnit='' /><MarkerMetaField Required='0' FactorDescription='OneRatioSNP' FactorId='8' FactorDataType='STRING' FactorCaption='OneRatioSNP' FactorName='OneRatioSNP' FactorValueMaxLength='32' FactorUnit='' /><MarkerMetaField Required='0' FactorDescription='NumofRefs' FactorId='9' FactorDataType='STRING' FactorCaption='NumofRefs' FactorName='NumofRefs' FactorValueMaxLength='32' FactorUnit='' /><MarkerMetaField Required='0' FactorDescription='NumofSNPs' FactorId='10' FactorDataType='STRING' FactorCaption='NumofSNPs' FactorName='NumofSNPs' FactorValueMaxLength='32' FactorUnit='' /><MarkerMetaField Required='0' FactorDescription='NumofHomozygotes' FactorId='11' FactorDataType='STRING' FactorCaption='NumofHomozygotes' FactorName='NumofHomozygotes' FactorValueMaxLength='32' FactorUnit='' /><MarkerMetaField Required='0' FactorDescription='NumofHomozygotesSNP' FactorId='12' FactorDataType='STRING' FactorCaption='NumofHomozygotesSNP' FactorName='NumofHomozygotesSNP' FactorValueMaxLength='32' FactorUnit='' /><MarkerMetaField Required='0' FactorDescription='NumofHomozygotesRef' FactorId='13' FactorDataType='STRING' FactorCaption='NumofHomozygotesRef' FactorName='NumofHomozygotesRef' FactorValueMaxLength='32' FactorUnit='' /><MarkerMetaField Required='0' FactorDescription='NumofHeterozygotes' FactorId='14' FactorDataType='STRING' FactorCaption='NumofHeterozygotes' FactorName='NumofHeterozygotes' FactorValueMaxLength='32' FactorUnit='' /><MarkerMetaField Required='0' FactorDescription='NumofNAzygotes' FactorId='15' FactorDataType='STRING' FactorCaption='NumofNAzygotes' FactorName='NumofNAzygotes' FactorValueMaxLength='32' FactorUnit='' /><MarkerMetaField Required='0' FactorDescription='SNPcall' FactorId='16' FactorDataType='STRING' FactorCaption='SNPcall' FactorName='SNPcall' FactorValueMaxLength='32' FactorUnit='' /><MarkerMetaField Required='0' FactorDescription='Rowsum' FactorId='17' FactorDataType='STRING' FactorCaption='Rowsum' FactorName='Rowsum' FactorValueMaxLength='32' FactorUnit='' /><MarkerMetaField Required='0' FactorDescription='Countrowsums' FactorId='18' FactorDataType='STRING' FactorCaption='Countrowsums' FactorName='Countrowsums' FactorValueMaxLength='32' FactorUnit='' /><RecordMeta TagName='MarkerMetaField' /></DATA>",
"SuccessMessageJSON": "{'MarkerMetaField' : [{'Required' : '0','FactorId' : '1','FactorDescription' : 'SNP','FactorDataType' : 'STRING','FactorCaption' : 'SNP','FactorUnit' : null,'FactorValueMaxLength' : '32','FactorName' : 'SNP'},{'Required' : '0','FactorId' : '2','FactorDescription' : 'Chromosome','FactorDataType' : 'STRING','FactorCaption' : 'Chromosome','FactorUnit' : null,'FactorValueMaxLength' : '32','FactorName' : 'Chromosome'},{'Required' : '0','FactorId' : '3','FactorDescription' : 'ChromosomePosition','FactorDataType' : 'STRING','FactorCaption' : 'ChromosomePosition','FactorUnit' : null,'FactorValueMaxLength' : '32','FactorName' : 'ChromosomePosition'},{'Required' : '0','FactorId' : '4','FactorDescription' : 'NumOfAligns','FactorDataType' : 'STRING','FactorCaption' : 'NumOfAligns','FactorUnit' : null,'FactorValueMaxLength' : '32','FactorName' : 'NumOfAligns'},{'Required' : '0','FactorId' : '5','FactorDescription' : 'CallrateREF','FactorDataType' : 'STRING','FactorCaption' : 'CallrateREF','FactorUnit' : null,'FactorValueMaxLength' : '32','FactorName' : 'CallrateREF'},{'Required' : '0','FactorId' : '6','FactorDescription' : 'CallrateSNP','FactorDataType' : 'STRING','FactorCaption' : 'CallrateSNP','FactorUnit' : null,'FactorValueMaxLength' : '32','FactorName' : 'CallrateSNP'},{'Required' : '0','FactorId' : '7','FactorDescription' : 'OneRatioREF','FactorDataType' : 'STRING','FactorCaption' : 'OneRatioREF','FactorUnit' : null,'FactorValueMaxLength' : '32','FactorName' : 'OneRatioREF'},{'Required' : '0','FactorId' : '8','FactorDescription' : 'OneRatioSNP','FactorDataType' : 'STRING','FactorCaption' : 'OneRatioSNP','FactorUnit' : null,'FactorValueMaxLength' : '32','FactorName' : 'OneRatioSNP'},{'Required' : '0','FactorId' : '9','FactorDescription' : 'NumofRefs','FactorDataType' : 'STRING','FactorCaption' : 'NumofRefs','FactorUnit' : null,'FactorValueMaxLength' : '32','FactorName' : 'NumofRefs'},{'Required' : '0','FactorId' : '10','FactorDescription' : 'NumofSNPs','FactorDataType' : 'STRING','FactorCaption' : 'NumofSNPs','FactorUnit' : null,'FactorValueMaxLength' : '32','FactorName' : 'NumofSNPs'},{'Required' : '0','FactorId' : '11','FactorDescription' : 'NumofHomozygotes','FactorDataType' : 'STRING','FactorCaption' : 'NumofHomozygotes','FactorUnit' : null,'FactorValueMaxLength' : '32','FactorName' : 'NumofHomozygotes'},{'Required' : '0','FactorId' : '12','FactorDescription' : 'NumofHomozygotesSNP','FactorDataType' : 'STRING','FactorCaption' : 'NumofHomozygotesSNP','FactorUnit' : null,'FactorValueMaxLength' : '32','FactorName' : 'NumofHomozygotesSNP'},{'Required' : '0','FactorId' : '13','FactorDescription' : 'NumofHomozygotesRef','FactorDataType' : 'STRING','FactorCaption' : 'NumofHomozygotesRef','FactorUnit' : null,'FactorValueMaxLength' : '32','FactorName' : 'NumofHomozygotesRef'},{'Required' : '0','FactorId' : '14','FactorDescription' : 'NumofHeterozygotes','FactorDataType' : 'STRING','FactorCaption' : 'NumofHeterozygotes','FactorUnit' : null,'FactorValueMaxLength' : '32','FactorName' : 'NumofHeterozygotes'},{'Required' : '0','FactorId' : '15','FactorDescription' : 'NumofNAzygotes','FactorDataType' : 'STRING','FactorCaption' : 'NumofNAzygotes','FactorUnit' : null,'FactorValueMaxLength' : '32','FactorName' : 'NumofNAzygotes'},{'Required' : '0','FactorId' : '16','FactorDescription' : 'SNPcall','FactorDataType' : 'STRING','FactorCaption' : 'SNPcall','FactorUnit' : null,'FactorValueMaxLength' : '32','FactorName' : 'SNPcall'},{'Required' : '0','FactorId' : '17','FactorDescription' : 'Rowsum','FactorDataType' : 'STRING','FactorCaption' : 'Rowsum','FactorUnit' : null,'FactorValueMaxLength' : '32','FactorName' : 'Rowsum'},{'Required' : '0','FactorId' : '18','FactorDescription' : 'Countrowsums','FactorDataType' : 'STRING','FactorCaption' : 'Countrowsums','FactorUnit' : null,'FactorValueMaxLength' : '32','FactorName' : 'Countrowsums'}],'RecordMeta' : [{'TagName' : 'MarkerMetaField'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='AnalysisGroup (5) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'AnalysisGroup (5) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing AnalysisGroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self    = shift;
  my $query   = $self->query();
  my $anal_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_m_read = connect_mdb_read();

  if (!record_existence($dbh_m_read, 'analysisgroup', 'AnalysisGroupId', $anal_id)) {

    my $err_msg = "AnalysisGroup ($anal_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id  = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_anal_ok, $trouble_anal_id_aref) = check_permission($dbh_m_read, 'analysisgroup', 'AnalysisGroupId',
                                                             [$anal_id], $group_id, $gadmin_status,
                                                             $READ_PERM);

  if (!$is_anal_ok) {

    my $err_msg = "Permission denied: Group ($group_id) and AnalysisGroup ($anal_id).";
    
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT FactorId FROM analysisgroupmarkermeta ';
  $sql   .= 'WHERE AnalysisGroupId=?';

  my ($read_mrk_meta_err, $read_mrk_meta_msg, $mrk_meta_data) = read_data($dbh_m_read, $sql, [$anal_id]);

  if ($read_mrk_meta_err) {

    $self->logger->debug("Read marker meta failed: $read_mrk_meta_msg");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my @mrk_meta_factor_id_list;

  for my $mrk_meta_rec (@{$mrk_meta_data}) {
  
    push(@mrk_meta_factor_id_list, $mrk_meta_rec->{'FactorId'});
  }

  if (scalar(@mrk_meta_factor_id_list) == 0) {

    push(@mrk_meta_factor_id_list, 0);
  }

  my $dbh_k_read = connect_kdb_read();

  $sql    = 'SELECT FactorId, FactorName, FactorCaption, ';
  $sql   .= 'FactorDescription, FactorDataType, ';
  $sql   .= 'IF(CanFactorHaveNull=0,1,0) AS Required, ';
  $sql   .= 'FactorValueMaxLength, FactorUnit ';
  $sql   .= 'FROM factor ';
  $sql   .= 'WHERE FactorId IN (' . join(',', @mrk_meta_factor_id_list) . ')';

  my ($r_mrk_meta_details_err, $r_mrk_meta_details_msg, $mrk_meta_details_data) = read_data($dbh_k_read, $sql, []);
  
  if ($r_mrk_meta_details_err) {

    $self->logger->debug("Read marker meta details failed: $r_mrk_meta_details_msg");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();
  $dbh_m_read->disconnect();

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'MarkerMetaField' => $mrk_meta_details_data,
                                           'RecordMeta'      => [{'TagName' => 'MarkerMetaField'}],
  };

  return $data_for_postrun_href;
}

sub logger {

  my $self = shift;
  return $self->{logger};
}

1;
