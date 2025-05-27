#$Id$
#$Author$

# Copyright (c) 2025, Diversity Arrays Technology, All rights reserved.

# Author    : Puthick Hok
# Created   : 20/10/2013
# Modified  :
# Purpose   :
#
#

package KDDArT::DAL::Marker;

use strict;
use warnings;

use Text::CSV;
use File::Lockfile;
use Crypt::Random qw( makerandom );
use DateTime;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use Storable;

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
use Time::HiRes qw( tv_interval gettimeofday );
use File::Lockfile;
use Crypt::Random qw( makerandom );


sub setup {

  my $self   = shift;

  CGI::Session->name($COOKIE_NAME);

  __PACKAGE__->authen->init_config_parameters();
  __PACKAGE__->authen->check_login_runmodes(':all');
  __PACKAGE__->authen->check_rand_runmodes('import_markerdata_dart',
                                           'add_markermap_gadmin',
                                           'update_markermap_gadmin',
                                           'import_markermap_position_gadmin',
                                           'append_markerdata_csv',
                                           'import_markermap_position_dataset_gadmin',
                                          );
  __PACKAGE__->authen->count_session_request_runmodes(':all');
  __PACKAGE__->authen->check_content_type_runmodes(':all');
  __PACKAGE__->authen->check_signature_runmodes('add_markermap_gadmin',
                                                'update_markermap_gadmin',
                                                'import_markermap_position_dataset_gadmin',
                                               );
  __PACKAGE__->authen->check_gadmin_runmodes('add_markermap_gadmin',
                                             'update_markermap_gadmin',
                                             'import_markermap_position_gadmin',
                                             'import_markermap_position_dataset_gadmin',
                                             'export_markermap_position_gadmin',
                                             );
  __PACKAGE__->authen->check_sign_upload_runmodes('import_markerdata_dart',
                                                  'import_markermap_position_gadmin',
                                                  'append_markerdata_csv',
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

  $self->run_modes(
    'export_marker_dart'                              => 'export_marker_dart_runmode',
    'import_markerdata_dart'                          => 'import_markerdata_dart_runmode',
    'list_marker_meta_field'                          => 'list_marker_meta_field_runmode',
    'list_marker'                                     => 'list_marker_runmode',
    'get_marker'                                      => 'get_marker_runmode',
    'list_marker_data'                                => 'list_marker_data_runmode',
    'add_markermap_gadmin'                            => 'add_markermap_runmode',
    'update_markermap_gadmin'                         => 'update_markermap_runmode',
    'list_markermap'                                  => 'list_markermap_runmode',
    'get_markermap'                                   => 'get_markermap_runmode',
    'import_markermap_position_gadmin'                => 'import_markermap_position_runmode',
    'list_markermap_position_advanced'                => 'list_markermap_position_advanced_runmode',
    'list_extract_marker_data'                        => 'list_extract_marker_data_advanced_runmode',
    'append_markerdata_csv'                           => 'append_markerdata_csv_runmode',
    'import_markermap_position_dataset_gadmin'        => 'import_markermap_position_dataset_runmode',
    'export_markermap_position_gadmin'                => 'export_markermap_position_runmode',
      );
}

sub import_markerdata_dart_runmode {

=pod import_markerdata_dart_HELP_START
{
"OperationName": "Import marker dataset",
"Description": "Import scoring marker dataset from a CSV file.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='17' ParaName='DataSetId' /><Info Message='Importing marker data for analysisgroup (23) into DataSet(17) is successful. Number of markers: 15621. Number of extracts: 264. Number of meta fields: 3' RunTime='2.258756' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '18', 'ParaName' : 'DataSetId'}], 'Info' : [{'Message' : 'Importing marker data for analysisgroup (24) into DataSet(18) is successful. Number of markers: 15621. Number of extracts: 264. Number of meta fields: 3', 'RunTime' : '2.225701'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='AnalysisGroup (18) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'AnalysisGroup (18) not found.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "CSV",
"UploadFileParameterName": "uploadfile",
"HTTPParameter": [{"Required": 1, "Name": "HeaderRow", "Description": "Line number in the CSV file counting from zero where column headers can be found."}, {"Required": 1, "Name": "MarkerNameCol", "Description": "Column number counting from zero which has marker names."}, {"Required": 1, "Name": "SequenceCol", "Description": "Column number counting from zero which has marker sequences."}, {"Required": 1, "Name": "MarkerMetaColStart", "Description": "Column number counting from zero for the starting of marker meta data column. Marker meta data columns must be adjacent to each other."}, {"Required": 1, "Name": "MarkerMetaColEnd", "Description": "Column number counting from zero for the last marker meta data column."}, {"Required": 1, "Name": "MarkerDataColStart", "Description": "Column number counting from zero for the starting of marker data column."}, {"Required": 1, "Name": "MarkerDataColEnd", "Description": "Column number counting from zero for the last marker data column."}, {"Required": 1, "Name": "DataSetType", "Description": "ID of dataset type which can represent scoring dataset, count dataset, or other marker quality dataset type."}, {"Required": 0, "Name": "ParentDataSetId", "Description": "ID of parent dataset if exists. Marker quality dataset like count needs a parent scoring dataset, to which the quality dataset complements."}, {"Required": 0, "Name": "Description", "Description": "Description of the dataset to be imported."}, {"Required": 0, "Name": "Forced", "Description": "0|1 switch to do forced importation on a dataset which already has data in the system. This parameter should be used for the importation to update the dataset."}],
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

  my $dataset_type          = $query->param('DataSetType');

  my $parent_dataset_id     = undef;

  if (defined $query->param('ParentDataSetId')) {

    if (length($query->param('ParentDataSetId')) > 0) {

      $parent_dataset_id     = $query->param('ParentDataSetId');
    }
  }

  my $description           = '';

  if (defined $query->param('Description')) {

    if (length($query->param('Description')) > 0) {

      $description           = $query->param('Description');
    }
  }

  my $is_forced = 0;

  if (defined($query->param('Forced'))) {

    if ($query->param('Forced') eq '1') {

      $is_forced = 1;
    }
  }

  $self->logger->debug("AnalysisGroupId: $anal_id");

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

  my ($missing_err, $missing_href) = check_missing_href( {'HeaderRow'     => $header_row,
                                                          'DataSetType'   => $dataset_type,
                                                         } );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  my $dbh_k_read = connect_kdb_read();

  if (!type_existence($dbh_k_read, 'markerdataset', $dataset_type)) {

    my $err_msg = "DataSetType ($dataset_type): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'DataSetType' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  if (defined $parent_dataset_id) {

    if (!record_existence($dbh_m_read, 'dataset', 'DataSetId', $parent_dataset_id)) {

      my $err_msg = "ParentDataSet ($parent_dataset_id): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'ParentDataSetId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $sql = '';

  my $delete_update_status = 0;
  my $dataset_id           = -1;

  $sql = 'SELECT "DataSetId" FROM "dataset" WHERE "AnalysisGroupId"=? AND "DataSetType"=?';

  my ($r_dataset_err, $existing_dataset_id) = read_cell($dbh_m_read, $sql, [$anal_id, $dataset_type]);

  if ($r_dataset_err) {

    $self->logger->debug("Check existing DataSetId failed");
    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($existing_dataset_id) > 0) {

    if ($is_forced == 1) {

      $delete_update_status = 1;
      $dataset_id = $existing_dataset_id;
    }
    else {

      my $err_msg = "DataSet of Type ($dataset_type): already exists.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $sth;

  $sql = 'SELECT "ExtractId", "AnalGroupExtractId" FROM "analgroupextract" WHERE "AnalysisGroupId"=?';

  $sth = $dbh_m_read->prepare($sql);
  $sth->execute($anal_id);
  my $extract_id2anal_grp_extract_id_href = $sth->fetchall_hashref('ExtractId');

  if ($dbh_m_read->err()) {

    $self->logger->debug("Retrieving ExtractId from analgroupextract failed");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_m_read->disconnect();

  my @first_fieldname_list;

  for (my $i = 0; $i < $num_of_col; $i++) {

    push(@first_fieldname_list, "Col$i");
  }

  my $csv_filehandle;
  open($csv_filehandle, "$data_csv_file") or die "Cannot open $data_csv_file: $!";

  my $check_empty_col   = 0;
  my $nb_line_wanted    = $header_row + 1 + 100; # get the top 100 lines plus the header
  my $ignore_line0      = 0;
  my $ignore_header     = 0;

  my ($csv_header_err, $csv_header_msg, $top100_section_aref) = csvfh2aref($csv_filehandle,
                                                                           \@first_fieldname_list,
                                                                           $check_empty_col,
                                                                           $nb_line_wanted,
                                                                           $ignore_line0,
                                                                           $ignore_header);

  if ($csv_header_err) {

    $self->logger->debug("Error reading header: $csv_header_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $csv_header_msg}]};

    return $data_for_postrun_href;
  }

  close($csv_filehandle);

  my $header_href = $top100_section_aref->[$header_row];

  my @empty_header_col_list;
  for (my $i = 0; $i < $num_of_col; $i++) {

    my $header_name = $header_href->{"Col$i"};
    if (length($header_name) == 0) {

      push(@empty_header_col_list, $i);
    }
  }

  if (scalar(@empty_header_col_list) > 0) {

    my $empty_header_col_csv = join(',', @empty_header_col_list);
    my $err_msg = "Column ($empty_header_col_csv): no header";

    $self->logger->debug("Empty header columns: $empty_header_col_csv");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $matched_col = {};

  $matched_col->{$marker_name_col}         = $header_href->{"Col$marker_name_col"};
  $matched_col->{$sequence_col}            = $header_href->{"Col$sequence_col"};

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
    $matched_col->{"$i"} = "E_" . "$extract_id";

    if ( !(defined($extract_id2anal_grp_extract_id_href->{$extract_id})) ) {

      my $err_msg = "Extract ($extract_id): not found in analysis group ($anal_id).";
      $self->logger->debug($err_msg);

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @unused_col_list;

  for (my $i = 0; $i < $num_of_col; $i++) {

    if (!defined($matched_col->{"$i"})) {

      push(@unused_col_list, $i);
    }
  }

  if (scalar(@unused_col_list) > 0) {

    my $unused_col_csv = join(',', @unused_col_list);

    my $err_msg = "Column ($unused_col_csv): unused - please remove these columns and import again.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $datatype_override_lookup = {};

  $datatype_override_lookup->{'int,str'}      = 'str';
  $datatype_override_lookup->{'float,str'}    = 'str';
  $datatype_override_lookup->{'str,int'}      = 'str';
  $datatype_override_lookup->{'str,float'}    = 'str';
  $datatype_override_lookup->{'int,float'}    = 'float';
  $datatype_override_lookup->{'float,int'}    = 'float';
  $datatype_override_lookup->{'int,int'}      = 'int';
  $datatype_override_lookup->{'float,float'}  = 'float';
  $datatype_override_lookup->{'str,str'}      = 'str';

  my $col_datatype_href = {};

  for (my $i = 0; $i < $num_of_col; $i++) {

    for (my $j = $header_row + 1; $j < scalar(@{$top100_section_aref}); $j++) {

      my $cell_data = $top100_section_aref->[$j]->{"Col$i"};
      my $datatype  = 'str';
      my $datalen   = length($cell_data);

      if ($cell_data =~ /^[-+]?\d+$/) {

        $datatype = 'int';
      }
      elsif ($cell_data =~ /^[-+]?\d+\.?\d*$/) {

        $datatype = 'float';
      }

      if ( !(defined $col_datatype_href->{"$i"}) ) {

        $col_datatype_href->{"$i"} = [$datatype, $datalen];
      }
      else {

        my $prev_data      = $col_datatype_href->{"$i"};
        my $prev_datatype  = $prev_data->[0];
        my $prev_datalen   = $prev_data->[1];

        my $new_datalen    = $datalen;

        if ($prev_datalen > $datalen) {

          $new_datalen = $prev_datalen;
        }

        my $new_datatype = '';

        if (defined $datatype_override_lookup->{"${prev_datatype},${datatype}"}) {

          $new_datatype = $datatype_override_lookup->{"${prev_datatype},${datatype}"};
        }
        else {

          $self->logger->debug("Data type override - old : $prev_datatype , new : $datatype - not found");
          my $err_msg = "Unexpected Error.";

          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }

        $col_datatype_href->{"$i"} = [$new_datatype, $new_datalen];
      }
    }
  }

  my $col_def_debug_txt = '';
  for (my $i = 0; $i < $num_of_col; $i++) {

    $col_def_debug_txt .= "Column definition: $i " . join(',', @{$col_datatype_href->{"$i"}}) . "\n";
  }

  $self->logger->debug("Column definition:\n$col_def_debug_txt");

  my $monetdb_col_datatype_href = {};

  for (my $i = 0; $i < $num_of_col; $i++) {

    my $datatype = '';
    my $datalen  = 0;

    if (defined $col_datatype_href->{"$i"}) {

      $datatype = $col_datatype_href->{"$i"}->[0];
      $datalen  = $col_datatype_href->{"$i"}->[1];
    }
    else {

      $self->logger->debug("Detected data type for column $i not found");
      my $err_msg = "Unexpected Error.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $monetdb_datatype = '';

    if ($i == $marker_name_col) {

      $monetdb_datatype = 'varchar(255)';
    }
    elsif ($i == $sequence_col) {

      $monetdb_datatype = 'string';
    }
    elsif ($i >= $marker_meta_scol && $i <= $marker_meta_ecol) {

      if ($datatype eq 'str') {

        $monetdb_datatype = 'varchar(255)';
      }
      elsif ($datatype eq 'int') {

        $monetdb_datatype = 'varchar(60)';
      }
      else {

        $monetdb_datatype = $datatype;
      }
    }
    elsif ($i >= $marker_data_scol && $i <= $marker_data_ecol) {

      if ($datalen == 1) {

        $monetdb_datatype = 'varchar(4)';
      }
      else {

        if ($datatype eq 'str') {

          $monetdb_datatype = 'varchar(40)';
        }
        else {

          $monetdb_datatype = $datatype;
        }
      }
    }
    else {

      $self->logger->debug("Unthink off: this should never be matched");
      my $err_msg = "Unexpected Error.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if (length($monetdb_datatype) > 0) {

      $monetdb_col_datatype_href->{"$i"} = $monetdb_datatype;
    }
    else {

      $self->logger->debug("Unthink off: monetdb datatype is empty");
      my $err_msg = "Unexpected Error.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $dbh_m_write = connect_mdb_write();

  my $mrk_name_field_name = $matched_col->{$marker_name_col};
  my $seq_field_name      = $matched_col->{$sequence_col};

  my $file_rand = makerandom(Size => 8, Strength => 0);

  my $tmp_markerdata_table_name = "markerdata${anal_id}_${file_rand}_tmp";

  if (table_existence($dbh_m_write, $tmp_markerdata_table_name)) {

    $self->logger->debug("$tmp_markerdata_table_name is not supposed to exist.");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $mk_tmp_markerdata_table_sql = qq|CREATE TABLE "$tmp_markerdata_table_name" (|;

  my @monetdb_col_sql_list;

  my $check_uniqueness = {};
  my @non_unique_columns;
  my $non_unique_err = 0;

  for (my $i = 0; $i < $num_of_col; $i++) {

    my $field_name        = $matched_col->{"$i"};
    my $monetdb_datatype  = $monetdb_col_datatype_href->{"$i"};

    my $sql_phrase        = qq|"$field_name" $monetdb_datatype NULL|;
    push(@monetdb_col_sql_list, $sql_phrase);

    if (defined $check_uniqueness->{$field_name}) {

      $self->logger->debug("$field_name already used as a column. Will cause crash.");
      $non_unique_err = 1;

      push(@non_unique_columns, $field_name);
    }

    $check_uniqueness->{$field_name} = $i;
  }

  if ($non_unique_err == 1) {
    my $err_msg = "Columns (" . join(',', @non_unique_columns) . ') in upload are not unique.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }



  my $field_sql = join(",\n", @monetdb_col_sql_list);

  $mk_tmp_markerdata_table_sql .= $field_sql . "\n";
  $mk_tmp_markerdata_table_sql .= ')';

  $self->logger->debug("CREATE TMP MARKERDATA SQL: $mk_tmp_markerdata_table_sql");

  my ($mk_mrkdata_err, $mk_mrkdata_msg) = execute_sql($dbh_m_write, $mk_tmp_markerdata_table_sql, []);

  if ($mk_mrkdata_err) {

    $self->logger->debug("Create temporary markerdata table failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $monetdb_csv_file = $TMP_DATA_PATH . "csv4monetdb${anal_id}_${file_rand}.csv";

  my $copy_file_start_time = [gettimeofday()];

  # first line is number one in copy_file
  copy_file($data_csv_file, $monetdb_csv_file, $header_row + 1 + 1);

  my $copy_file_elapsed_time = tv_interval($copy_file_start_time);

  $self->logger->debug("Copy file takes: $copy_file_elapsed_time");

  my $copy_into_start_time = [gettimeofday()];

  $sql  = qq|COPY INTO "$tmp_markerdata_table_name" FROM '$monetdb_csv_file' |;
  $sql .= q|USING DELIMITERS ',','\\n','"'|;

  my ($copy_into_err, $copy_into_msg) = execute_sql($dbh_m_write, $sql, []);

  my $copy_into_elapsed_time = tv_interval($copy_into_start_time);

  $self->logger->debug("MonetDB COPY INTO takes: $copy_into_elapsed_time");

  if ($copy_into_err) {

    $copy_into_msg =~ s/failed to import table at.*//g;

    $self->logger->debug("Loading data into table $tmp_markerdata_table_name failed: $copy_into_msg");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $copy_into_msg}]};

    return $data_for_postrun_href;
  }

  $sql  = qq|SELECT "$mrk_name_field_name", COUNT("$mrk_name_field_name") AS "NB_Copy" FROM |;
  $sql .= qq|"$tmp_markerdata_table_name" GROUP BY "$mrk_name_field_name" |;
  $sql .= qq|HAVING COUNT("$mrk_name_field_name") > 1 LIMIT 100|;

  my ($r_dup_err, $r_dup_msg, $dup_marker_data) = read_data($dbh_m_write, $sql, []);

  if ($r_dup_err) {

    $self->logger->debug("Count duplicate marker name failed: $r_dup_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  $dbh_m_write->disconnect();
  $dbh_m_write = connect_mdb_write();

  if (scalar(@{$dup_marker_data}) > 0) {

    $sql  = qq|SELECT COUNT(*) FROM ( |;
    $sql .= qq|SELECT "$mrk_name_field_name", COUNT("$mrk_name_field_name") AS "NB_Copy" FROM |;
    $sql .= qq|"$tmp_markerdata_table_name" GROUP BY "$mrk_name_field_name" |;
    $sql .= qq|HAVING COUNT("$mrk_name_field_name") > 1 ) "final"|;

    my ($r_nb_dup_mrk_err, $nb_dup_mrk) = read_cell($dbh_m_write, $sql, []);

    if ($r_nb_dup_mrk_err) {

      $self->logger->debug("Count the number of duplicate marker failed.");
      my $err_msg = "Unexpected Error.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    $sql = qq|DROP TABLE "$tmp_markerdata_table_name"|;

    my ($d_tmp_mrk_tbl_err, $d_tmp_mrk_tbl_msg) = execute_sql($dbh_m_write, $sql, []);

    if ($d_tmp_mrk_tbl_err) {

      $self->logger->debug("Drop tmp marker data table $tmp_markerdata_table_name failed: $d_tmp_mrk_tbl_msg");
      my $err_msg = "Unexpected Error.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my @dup_mrk_name_msg_list;

    foreach my $dup_marker_rec (@{$dup_marker_data}) {

      my $mrk_name = $dup_marker_rec->{$mrk_name_field_name};
      my $nb_copy  = $dup_marker_rec->{'NB_Copy'};
      push(@dup_mrk_name_msg_list, "$mrk_name");
    }

    my $err_msg = "$nb_dup_mrk markers are duplicate. First 100 of duplicate marker names ($mrk_name_field_name): (" . join(', ', @dup_mrk_name_msg_list) . ")";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_m_write->disconnect();
  $dbh_m_write = connect_mdb_write();

  if ($delete_update_status == 1) {

    $sql = 'DELETE FROM "datasetmarkermeta" WHERE "DataSetId"=?';

    my ($del_mrkmeta_err, $del_mrkmeta_msg) = execute_sql($dbh_m_write, $sql, [$dataset_id]);

    if ($del_mrkmeta_err) {

      $self->logger->debug("Delete datasetmarkermeta failed: $del_mrkmeta_msg");
      my $err_msg = "Unexpected Error.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    $sql = 'DELETE FROM "datasetextract" WHERE "DataSetId"=?';

    my ($del_ds_extract_err, $del_ds_extract_msg) = execute_sql($dbh_m_write, $sql, [$dataset_id]);

    if ($del_ds_extract_err) {

      $self->logger->debug("Delete datasetextract failed: $del_ds_extract_msg");
      my $err_msg = "Unexpected Error.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if (table_existence($dbh_m_write, "markerdata${dataset_id}")) {

      $sql = qq|DROP TABLE "markerdata${dataset_id}"|;
      my ($drop_dataset_err, $drop_dataset_msg) = execute_sql($dbh_m_write, $sql, []);

      if ($drop_dataset_err) {

        $self->logger->debug("Drop markerdata${dataset_id} failed: $drop_dataset_msg");
        my $err_msg = "Unexpected Error.";

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }

    my $cur_dt = DateTime->now( time_zone => $TIMEZONE );
    $cur_dt = DateTime::Format::MySQL->format_datetime($cur_dt);

    my $DateUpdated               = $cur_dt;

    if (defined($query->param('DateUpdated'))) {

      $DateUpdated = $query->param('DateUpdated');
    }

    $sql  = 'UPDATE "dataset" SET ';
    $sql .= '"MarkerNameFieldName"=?, ';
    $sql .= '"MarkerSequenceFieldName"=?, ';
    $sql .= '"ParentDataSetId"=?, ';
    $sql .= '"DataSetType"=?, ';
    $sql .= '"Description"=?, ';
    $sql .= '"DateUpdated"=? ';
    $sql .= 'WHERE "DataSetId"=?';

    $sth = $dbh_m_write->prepare($sql);
    $sth->execute($mrk_name_field_name, $seq_field_name, $parent_dataset_id, $dataset_type,
                  $description, $DateUpdated,$dataset_id);

    if ($dbh_m_write->err()) {

      $self->logger->debug("Update dataset failed");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }
  }
  else {

    my ($next_val_err, $next_val_msg, $ds_id) = get_next_value_for($dbh_m_write, 'dataset', 'DataSetId');

    if ($next_val_err) {

      $self->logger->debug($next_val_msg);

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $cur_dt = DateTime->now( time_zone => $TIMEZONE );
    $cur_dt = DateTime::Format::MySQL->format_datetime($cur_dt);

    my $DateCreated = $cur_dt;

    $sql  = 'INSERT INTO "dataset"(';
    $sql .= '"DataSetId", ';
    $sql .= '"AnalysisGroupId", ';
    $sql .= '"MarkerNameFieldName", ';
    $sql .= '"MarkerSequenceFieldName", ';
    $sql .= '"ParentDataSetId", ';
    $sql .= '"DataSetType", ';
    $sql .= '"Description",';
    $sql .= '"DateCreated") ';
    $sql .= 'VALUES (?, ?, ?, ?, ?, ?, ?,?)';

    my $debug_values = "($ds_id, $anal_id, $mrk_name_field_name, $seq_field_name, $parent_dataset_id, $dataset_type, $description, $DateCreated)";


    $sth = $dbh_m_write->prepare($sql);
    $sth->execute($ds_id, $anal_id, $mrk_name_field_name, $seq_field_name,
                  $parent_dataset_id, $dataset_type, $description,$DateCreated);

    if ($dbh_m_write->err()) {

      $self->logger->debug("Insert into dataset failed $sql");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }
    else {

      $dataset_id = $ds_id;
    }

    $sth->finish();
  }

  my $markerdata_table_name = "markerdata${dataset_id}";

  if (table_existence($dbh_m_write, $markerdata_table_name)) {

    $self->logger->debug("$markerdata_table_name is not supposed to exist yet.");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $copy_markerdata_table_sql = qq|CREATE TABLE "$markerdata_table_name" |;
  $copy_markerdata_table_sql   .= qq|AS SELECT * FROM "$tmp_markerdata_table_name" WITH DATA|;

  $self->logger->debug("COPY MARKERDATA SQL: $copy_markerdata_table_sql");

  my ($cp_mrkdata_err, $cp_mrkdata_msg) = execute_sql($dbh_m_write, $copy_markerdata_table_sql, []);

  if ($cp_mrkdata_err) {

    $self->logger->debug("Create markerdata table failed: $cp_mrkdata_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sql  = qq|DROP TABLE "$tmp_markerdata_table_name"|;

  $self->logger->debug("DROP TABLE $tmp_markerdata_table_name: $sql");

  my ($drop_table_err, $drop_table_msg) = execute_sql($dbh_m_write, $sql, []);

  if ($drop_table_err) {

    $self->logger->debug("Drop table $tmp_markerdata_table_name failed: $drop_table_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sql  = 'DELETE FROM "analysisgroupmarker" WHERE "DataSetId"=?';

  my ($del_mrk_err, $del_mrk_msg) = execute_sql($dbh_m_write, $sql, [$dataset_id]);

  if ($del_mrk_err) {

    $self->logger->debug("Delete markers failed: $del_mrk_msg");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sql  = qq|INSERT INTO "analysisgroupmarker"("DataSetId","MarkerName","MarkerSequence") |;
  $sql .= qq|SELECT $dataset_id AS "DataSetId", "$mrk_name_field_name", "$seq_field_name" |;
  $sql .= qq|FROM "markerdata${dataset_id}"|;

  my ($copy_mrk_err, $copy_mrk_msg) = execute_sql($dbh_m_write, $sql, []);

  if ($copy_mrk_err) {

    $self->logger->debug("Copy markers failed: $copy_mrk_msg");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
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

    #$self->logger->debug("$meta_field  - factorid: $factor_id");

    if (length($factor_id) == 0) {

      my $factor_caption = $meta_field;
      my $factor_desc    = "Created automatically by import/makerdata/csv for $meta_field";
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

  $sql  = 'INSERT INTO "datasetmarkermeta" ';
  $sql .= '("DataSetId", "FactorId", "FieldName") ';
  $sql .= 'VALUES ';

  for (my $i = $marker_meta_scol; $i <= $marker_meta_ecol; $i++) {

    my $meta_col_name  = $matched_col->{"$i"};
    my $meta_factor_id = $meta_fieldname2factor_id_href->{$meta_col_name};

    $sql .= qq|(${dataset_id},${meta_factor_id},'${meta_col_name}'),|;
  }

  #$self->logger->debug("Insert datasetmarkermeta SQL: $sql");

  $sql =~ s/\),$/\)/; # remove trailing comma

  my ($in_dsmrkmeta_err, $in_dsmrkmeta_msg) = execute_sql($dbh_m_write, $sql, []);

  if ($in_dsmrkmeta_err) {

    $self->logger->debug("Insert meta column info failed: $in_dsmrkmeta_msg");

    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql  = 'INSERT INTO "datasetextract" ';
  $sql .= '("DataSetId", "AnalGroupExtractId", "FieldName") ';
  $sql .= 'VALUES ';

  for (my $i = $marker_data_scol; $i <= $marker_data_ecol; $i++) {

    my $extract_id          = $header_href->{"Col$i"};
    my $field_name          = $matched_col->{"$i"};
    my $anal_grp_extract_id = $extract_id2anal_grp_extract_id_href->{$extract_id}->{'AnalGroupExtractId'};

    $sql .= qq|(${dataset_id},${anal_grp_extract_id},'${field_name}'),|;
  }

  #$self->logger->debug("Insert datasetextract SQL: $sql");

  $sql =~ s/\),$/\)/; # remove trailing comma

  my ($in_dsextract_err, $in_dsextract_msg) = execute_sql($dbh_m_write, $sql, []);

  if ($in_dsextract_err) {

    $self->logger->debug("Insert dataset extract failed: $in_dsextract_msg");

    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql = qq|SELECT COUNT(*) FROM "$markerdata_table_name"|;

  my ($r_nb_marker_err, $nb_marker) = read_cell($dbh_m_write, $sql, []);

  if ($r_nb_marker_err) {

    $self->logger->debug("Count the number of markers failed");

    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql = qq|SELECT COUNT(*) FROM "datasetextract" WHERE "DataSetId"=?|;

  my ($r_nb_extract_err, $nb_extract) = read_cell($dbh_m_write, $sql, [$dataset_id]);

  if ($r_nb_extract_err) {

    $self->logger->debug("Count the number of extracts failed");

    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql = qq|SELECT COUNT(*) FROM "datasetmarkermeta" WHERE "DataSetId"=?|;

  my ($r_nb_mrkmeta_err, $nb_mrkmeta) = read_cell($dbh_m_write, $sql, [$dataset_id]);

  if ($r_nb_mrkmeta_err) {

    $self->logger->debug("Count the number of marker meta");

    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_m_write->disconnect();

  my $elapsed_time = tv_interval($start_time);

  my $info_msg = "Importing marker data for analysisgroup ($anal_id) into DataSet($dataset_id) is successful. ";
  $info_msg   .= "Number of markers: $nb_marker. Number of extracts: $nb_extract. Number of meta fields: $nb_mrkmeta";

  my $return_id_aref = [{'Value' => "$dataset_id", 'ParaName' => 'DataSetId'}];

  my $info_msg_aref = [{'Message' => $info_msg, 'RunTime' => "$elapsed_time"}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref,
                                          };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub export_marker_dart_runmode {

=pod export_marker_dart_HELP_START
{
"OperationName": "Export marker dataset",
"Description": "Export analysis group marker dataset in a CSV form",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><OutputFileMeta MarkerDataColEnd='268' MarkerNameFieldName='markerName' MarkerMetaColEnd='4' LastHeaderRow='4' MarkerDataColStart='5' MarkerNameCol='0' MarkerSequenceCol='1' MarkerMetaColStart='2' MarkerSequenceFieldName='TrimmedSequence' NumberOfMarkers='15626' /><Info Message='Time taken in seconds: 1.70502.' /><OutputFile csv='http://kddart-d.diversityarrays.com/data/admin/export_marker_data_17.csv' /></DATA>",
"SuccessMessageJSON": "{'OutputFileMeta' : [{'MarkerNameFieldName' : 'markerName', 'MarkerDataColEnd' : 268, 'MarkerMetaColEnd' : 4, 'LastHeaderRow' : 4, 'MarkerDataColStart' : 5, 'MarkerSequenceCol' : 1, 'MarkerNameCol' : 0, 'MarkerMetaColStart' : 2, 'MarkerSequenceFieldName' : 'TrimmedSequence', 'NumberOfMarkers' : '15626'}], 'Info' : [{'Message' : 'Time taken in seconds: 1.66073.'}], 'OutputFile' : [{'csv' : 'http://kddart-d.diversityarrays.com/data/admin/export_marker_data_17.csv'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPParameter": [{"Required": 0, "Name": "Filtering", "Description": "Filtering parameter string consisting of filtering expressions which are separated by ampersand (&) which needs to be encoded if HTTP GET method is used. Each filtering expression is composed of a marker metadata field name or extract field name like E_6017, a filtering operator and the filtering value."}, {"Required": 0, "Name": "FieldList", "Description": "Comma separated value of wanted fields."}, {"Required": 0, "Name": "MarkerMetaFieldList", "Description": "CSV value for the list of wanted marker meta data columns if this parameter is not provided, DAL will export all marker meta data columns available in the dataset."}, {"Required": 0, "Name": "MarkerDataFieldList", "Description": "CSV value for the list of wanted sample/extract columns. If this parameter is not provided, DAL will export all samples/extracts available in the dataset."}, {"Required": 0, "Name": "ExtractFiltering", "Description": "Filtering parameter string consisting of filtering expressions which are separated by ampersand (&) which needs to be encoded if HTTP GET method is used. Each filtering expression is composed of a field in the extract table, a filtering operator and the filtering value"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing AnalysisGroupId if there is only one dataset"}, {"ParameterName": "datasetid", "Description": "Existing specific DataSetId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $query      = $self->query();
  my $anal_id    = '';

  if (defined $self->param('id')) {

    $anal_id = $self->param('id');
  }

  my $user_ds_id = $self->param('datasetid');

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

  my $extract_filtering_csv = '';

  if (defined $query->param('ExtractFiltering')) {

    $extract_filtering_csv = $query->param('ExtractFiltering');
  }

  $self->logger->debug("Filtering String: $filtering_csv");

  my $start_time = [gettimeofday()];

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $dataset_id    = undef;

  my $data_for_postrun_href = {};

  my $dbh_m_read = connect_mdb_read();

  my $sql = '';

  if (length($user_ds_id) > 0) {

    my $db_anal_id = read_cell_value($dbh_m_read, 'dataset', 'AnalysisGroupId', 'DataSetId', $user_ds_id);

    if (length($db_anal_id) == 0) {

      my $err_msg = "DataSet ($user_ds_id) not found.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    else {

      if (length($anal_id) == 0) {

        $anal_id     = $db_anal_id;
        $dataset_id  = $user_ds_id;
      }
      else {

        if ($anal_id == $db_anal_id) {

          $dataset_id  = $user_ds_id;
        }
        else {

          my $err_msg = "AnalysisGroup($anal_id) and DataSet ($user_ds_id): conflicting value - please remove one.";

          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
      }
    }
  }

  if (!record_existence($dbh_m_read, 'analysisgroup', 'AnalysisGroupId', $anal_id)) {

    my $err_msg = "AnalysisGroup ($anal_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($is_anal_ok, $trouble_anal_id_aref) = check_permission($dbh_m_read, 'analysisgroup', 'AnalysisGroupId',
                                                             [$anal_id], $group_id, $gadmin_status,
                                                             $READ_PERM);

  if (!$is_anal_ok) {

    my $err_msg = "Permission denied: Group ($group_id) and AnalysisGroup ($anal_id).";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (!(defined $dataset_id)) {

    $sql = 'SELECT COUNT(*) FROM "dataset" WHERE "AnalysisGroupId"=?';

    my ($r_count_ds_err, $nb_dataset) = read_cell($dbh_m_read, $sql, [$anal_id]);

    if ($r_count_ds_err) {

      $self->logger->debug("Count the number of datasets failed.");
      my $err_msg = "Unexpected Error.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if ($nb_dataset == 0) {

      my $err_msg = "AnalysisGroup ($anal_id): no data set available";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    elsif ($nb_dataset == 1) {

      my $ds_id = read_cell_value($dbh_m_read, 'dataset', 'DataSetId', 'AnalysisGroupId', $anal_id);
      $dataset_id = $ds_id;
    }
    else {

      my $err_msg = "AnalysisGroup ($anal_id): more than one data set available";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $field_idx_lookup_href       = {};

  my $dbh_k_read = connect_kdb_read();

  my $read_dataset_sql   = 'SELECT "MarkerNameFieldName", "MarkerSequenceFieldName" ';
     $read_dataset_sql  .= 'FROM dataset WHERE "DataSetId"=? ';

  my ($r_df_val_err, $r_df_val_msg, $dataset_df_val_data) = read_data($dbh_m_read, $read_dataset_sql, [$dataset_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve dataset default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $mrk_name_fieldname    = undef;
  my $seq_fieldname         = undef;

  my $nb_df_val_rec    =  scalar(@{$dataset_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve dataset default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $mrk_name_fieldname    = $dataset_df_val_data->[0]->{'MarkerNameFieldName'};
  $seq_fieldname         = $dataset_df_val_data->[0]->{'MarkerSequenceFieldName'};

  my @filterable_fieldlist = ($mrk_name_fieldname, $seq_fieldname);

  $sql  = 'SELECT "FieldName" FROM "datasetmarkermeta" WHERE "DataSetId"=? ORDER BY "FactorId" ASC';

  my ($r_factor_err, $r_factor_msg, $factor_data) = read_data($dbh_m_read, $sql, [$dataset_id]);

  if ($r_factor_err) {

    $self->logger->debug("Read FactorId for analysis group ($anal_id) failed");
    my $err_msg = "Unexpected error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my @meta_fieldname_list = ($mrk_name_fieldname, $seq_fieldname);

  $field_idx_lookup_href->{$mrk_name_fieldname} = 0;
  $field_idx_lookup_href->{$seq_fieldname}      = 1;

  my @field_idx_list = (0, 1);

  my $mrk_metafield_idx_start   = 2;

  my $mrk_metafield_idx_counter = 2;
  for my $factor_rec (@{$factor_data}) {

    my $meta_fieldname  = $factor_rec->{'FieldName'};

    $field_idx_lookup_href->{$meta_fieldname} = $mrk_metafield_idx_counter;

    push(@meta_fieldname_list, $meta_fieldname);
    push(@filterable_fieldlist, $meta_fieldname);
    push(@field_idx_list, $mrk_metafield_idx_counter);

    $mrk_metafield_idx_counter += 1;
  }

  my $mrk_metafield_idx_end = $mrk_metafield_idx_counter - 1;

  my $all_mrk_meta_field_csv = join(',', @filterable_fieldlist);

  # free up memory for factor id data
  $factor_data = [];

  my $header_row_aref = [];

  my $nb_marker_meta_col = scalar(@meta_fieldname_list);

  my @plate_header_row;
  my @well_header_row;
  my @itm_grp_header_row;
  my @geno_header_row;

  # leave one column for row labels
  for (my $i = 0; $i < $nb_marker_meta_col; $i++) {

    push(@plate_header_row, '*');
    push(@well_header_row, '*');
    push(@itm_grp_header_row, '*');
    push(@geno_header_row, '*');
  }

  my $extract_field_list = [];

  my ($ex_sfield_err, $ex_sfield_msg, $extract_sfield_data, $extract_pkey_data) = get_static_field($dbh_m_read, 'extract');

  if ($ex_sfield_err) {

    $self->logger->debug("Get static field failed: $ex_sfield_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  for my $sfield_rec (@{$extract_sfield_data}) {

    push(@{$extract_field_list}, $sfield_rec->{'Name'});
  }

  for my $pkey_field (@{$extract_pkey_data}) {

    push(@{$extract_field_list}, $pkey_field);
  }

  my ($ex_filter_err, $ex_filter_msg,
      $extract_filter_phrase, $extract_where_arg) = parse_filtering('"ExtractId"',
                                                                    '"extract"',
                                                                    $extract_filtering_csv,
                                                                    $extract_field_list
                                                                   );

  $self->logger->debug("Extract Filter phrase: $extract_filter_phrase");

  if ($ex_filter_err) {

    $self->logger->debug("Parsing extract filtering failed: $ex_filter_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $ex_filter_msg}]};

    return $data_for_postrun_href;
  }

  my $extract_filtering_exp = '';
  if (length($extract_filter_phrase) > 0) {

    $extract_filtering_exp = " AND $extract_filter_phrase ";
  }

  $sql  = qq|SELECT "analgroupextract"."ExtractId", "datasetextract"."FieldName", "plate"."PlateName", |;
  $sql .= qq|"extract"."ItemGroupId", "extract"."GenotypeId", |;
  $sql .= qq|CONCAT("extract"."WellRow", "extract"."WellCol") AS "WellPosition" |;
  $sql .= qq|FROM "datasetextract" LEFT JOIN "analgroupextract" |;
  $sql .= qq|ON "datasetextract"."AnalGroupExtractId" = "analgroupextract"."AnalGroupExtractId" |;
  $sql .= qq|LEFT JOIN "extract" ON "analgroupextract"."ExtractId" = "extract"."ExtractId" |;
  $sql .= qq|LEFT JOIN "plate" ON "extract"."PlateId" = "plate"."PlateId" |;
  $sql .= qq|WHERE "DataSetId" = ? $extract_filtering_exp |;
  $sql .= qq|ORDER BY "analgroupextract"."ExtractId" ASC|;

  $self->logger->debug("SQL: $sql");

  my $extract_start_time = [gettimeofday()];

  my ($r_extract_err, $r_extract_msg, $extract_data) = read_data($dbh_m_read, $sql, [$dataset_id, @{$extract_where_arg}]);

  my $extract_elapsed = tv_interval($extract_start_time);

  $self->logger->debug("Extract time: $extract_elapsed");

  if ($r_extract_err) {

    $self->logger->debug("Read extract failed: $r_extract_msg");
    my $err_msg = "Unexpected error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $nb_extract_returned = scalar(@{$extract_data});

  if ($nb_extract_returned == 0) {

    $self->logger->debug("Extract filtering for dataset ($dataset_id) returns no data");
    my $err_msg = "Extract filtering ($extract_filtering_csv) on dataset ($dataset_id): no extract found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my @extract_fieldname_list;

  my $extractfield_idx_start   = $mrk_metafield_idx_counter;

  my $extractfield_idx_counter = $mrk_metafield_idx_counter;

  $self->logger->debug("Extract Field Index Counter Start: $extractfield_idx_counter");

  my @itm_grp_id_list;
  my @geno_id_list;

  for my $extract_rec (@{$extract_data}) {

    if (defined $extract_rec->{'ItemGroupId'}) {

      push(@itm_grp_id_list, $extract_rec->{'ItemGroupId'});
    }

    if (defined $extract_rec->{'GenotypeId'}) {

      push(@geno_id_list, $extract_rec->{'GenotypeId'});
    }
  }

  my $itm_grp_lookup_href = {};
  my $geno_lookup_href    = {};

  if (scalar(@itm_grp_id_list) > 0) {

    my $itm_grp_sql = 'SELECT ItemGroupId, ItemGroupName FROM itemgroup WHERE ItemGroupId IN (';
    $itm_grp_sql   .= join(',', @itm_grp_id_list) . ')';

    my $itm_grp_sth = $dbh_k_read->prepare($itm_grp_sql);
    $itm_grp_sth->execute();

    $itm_grp_lookup_href = $itm_grp_sth->fetchall_hashref('ItemGroupId');

    if ($dbh_k_read->err()) {

      $self->logger->debug("Retrieving ItemGroupName failed");

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error.'}]};

      return $data_for_postrun_href;
    }
  }

  if (scalar(@geno_id_list) > 0) {

    my $geno_sql = 'SELECT GenotypeId, GenotypeName FROM genotype WHERE GenotypeId IN (';
    $geno_sql   .= join(',', @geno_id_list) . ')';

    my $geno_sth = $dbh_k_read->prepare($geno_sql);
    $geno_sth->execute();

    $geno_lookup_href = $geno_sth->fetchall_hashref('GenotypeId');

    if ($dbh_k_read->err()) {

      $self->logger->debug("Retrieving GenotypeName failed");

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error.'}]};

      return $data_for_postrun_href;
    }
  }

  for my $extract_rec (@{$extract_data}) {

    my $extract_id    = $extract_rec->{'ExtractId'};
    my $ext_fieldname = $extract_rec->{'FieldName'};

    my $plate_name    = $extract_rec->{'PlateName'};
    my $well_pos      = $extract_rec->{'WellPosition'};
    my $itm_grp_id    = $extract_rec->{'ItemGroupId'};
    my $geno_id       = $extract_rec->{'GenotypeId'};

    my $itm_grp_name = '';
    my $geno_name    = '';

    if (defined $itm_grp_id) {

      if (defined $itm_grp_lookup_href->{$itm_grp_id}) {

        $itm_grp_name = $itm_grp_lookup_href->{$itm_grp_id}->{'ItemGroupName'};
      }
    }

    if (defined $geno_id) {

      if (defined $geno_lookup_href->{$geno_id}) {

        $geno_name = $geno_lookup_href->{$geno_id}->{'GenotypeName'};
      }
    }

    push(@filterable_fieldlist, $ext_fieldname);

    push(@plate_header_row, $plate_name);
    push(@well_header_row, $well_pos);
    push(@itm_grp_header_row, $itm_grp_name);
    push(@geno_header_row, $geno_name);

    push(@extract_fieldname_list, $ext_fieldname);
    push(@field_idx_list, $extractfield_idx_counter);

    $field_idx_lookup_href->{$ext_fieldname} = $extractfield_idx_counter;

    $extractfield_idx_counter += 1;
  }

  my $extractfield_idx_end = $extractfield_idx_counter - 1;

  push(@{$header_row_aref}, \@plate_header_row);
  push(@{$header_row_aref}, \@well_header_row);
  push(@{$header_row_aref}, \@itm_grp_header_row);
  push(@{$header_row_aref}, \@geno_header_row);

  my @extract_header_row = (@meta_fieldname_list, @extract_fieldname_list);

  push(@{$header_row_aref}, \@extract_header_row);

  my $all_mrk_data_field_csv = join(',', @extract_fieldname_list);

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

  my $selected_field_idx_aref = \@field_idx_list;
  my $selected_field_aref     = \@extract_header_row;

  if (length($field_list_csv) > 0) {

    my @fieldname_list = keys(%{$field_idx_lookup_href});

    my ($sel_field_err, $sel_field_msg, $sel_field_list) = parse_selected_field($field_list_csv,
                                                                                \@fieldname_list,
                                                                                $mrk_name_fieldname);

    if ($sel_field_err) {

      $self->logger->debug("Parse selected fields error: $sel_field_msg");

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    my %sel_field_idx2name;

    my $nb_selected_extract;

    for my $sel_fieldname (@{$sel_field_list}) {

      if ($sel_fieldname =~ /^E_\d+$/) { $nb_selected_extract += 1; }

      my $field_idx = $field_idx_lookup_href->{$sel_fieldname};

      $sel_field_idx2name{$field_idx} = $sel_fieldname;
    }

    $nb_extract_returned = $nb_selected_extract;

    my $idx_sorted_sel_field_aref = [];
    my $sel_field_idx_aref = [];

    for my $idx (sort {$a <=> $b} keys(%sel_field_idx2name)) {

      push(@{$idx_sorted_sel_field_aref}, $sel_field_idx2name{$idx});
      push(@{$sel_field_idx_aref}, $idx);
    }

    $selected_field_idx_aref = $sel_field_idx_aref;
    $selected_field_aref     = $idx_sorted_sel_field_aref;
  }

  $self->logger->debug("Filtering str: $filtering_csv");

  my $field_name2table_name  = { $mrk_name_fieldname => qq|"markerdata${dataset_id}"|,
                                 $seq_fieldname      => qq|"markerdata${dataset_id}"| };
  my $validation_func_lookup = {};

  my ($filtering_err, $filtering_msg,
      $filter_phrase, $where_arg) = parse_filtering(qq|"$mrk_name_fieldname"|,
                                                    qq|"markerdata${dataset_id}"|,
                                                    $filtering_csv,
                                                    \@filterable_fieldlist,
                                                    $validation_func_lookup,
                                                    $field_name2table_name);

  if ($filtering_err) {

    $self->logger->debug("Parsing filtering failed: $filtering_msg");

    my $err_msg = $filtering_msg;

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $filtering_exp = '';
  if (length($filter_phrase) > 0) {

    $filtering_exp = " WHERE $filter_phrase ";
  }

  $self->logger->debug("SELECTED FIELDS: " . join(',', @{$selected_field_aref}));
  $self->logger->debug("SELECTED FIELD IDX: " . join(',', @{$selected_field_idx_aref}));

  # empty extract data to free up memory
  $extract_data = [];

  my $username          = $self->authen->username();
  my $doc_root          = $ENV{'DOCUMENT_ROOT'};
  my $export_data_path  = "${doc_root}/data/$username";
  my $filename          = "export_marker_data_${dataset_id}";
  my $csv_file          = "${export_data_path}/${filename}.csv";
  my $result_filename   = "${filename}.csv";

  my $user_id           = $self->authen->user_id();
  my $file_rand         = makerandom(Size => 8, Strength => 0);

  my $content_file      = "${TMP_DATA_PATH}${filename}_content_${user_id}_${file_rand}.csv";

  my $eol          = "\r\n";
  my $monetdb_eol  = '\\r\\n';

  if ( !(-e $export_data_path) ) {

    mkdir($export_data_path);
  }

  my $output_meta_href = {};

  my $mrk_meta_start_col_found = 0;
  my $mrk_data_start_col_found = 0;

  my $mrk_meta_start_col = -1;
  my $mrk_meta_end_col   = -1;

  my $mrk_data_start_col = -1;
  my $mrk_data_end_col   = -1;

  my $mrk_seq_col        = -1;

  $output_meta_href->{'MarkerNameCol'}     = 0;

  my $row_header_col = 0;

  my $new_idx_counter = 0;
  for my $field_name (@{$selected_field_aref}) {

    $self->logger->debug("Selected Field Name: $field_name");
    my $field_idx = $field_idx_lookup_href->{$field_name};

    if ($field_name eq $seq_fieldname) {

      $mrk_seq_col    = $new_idx_counter;
      $row_header_col = $field_idx;
    }

    if ($field_idx >= $mrk_metafield_idx_start && $field_idx <= $mrk_metafield_idx_end) {

      if (!$mrk_meta_start_col_found) {

        $mrk_meta_start_col = $new_idx_counter;
        $mrk_meta_start_col_found = 1;
      }

      $mrk_meta_end_col = $new_idx_counter;
      $row_header_col   = $field_idx;
    }

    if ($field_idx >= $extractfield_idx_start && $field_idx <= $extractfield_idx_end) {

      if (!$mrk_data_start_col_found) {

        $mrk_data_start_col = $new_idx_counter;
        $mrk_data_start_col_found = 1;
      }

      $mrk_data_end_col = $new_idx_counter;
    }

    $new_idx_counter += 1;
  }

  $header_row_aref->[0]->[$row_header_col] = 'PlateName';
  $header_row_aref->[1]->[$row_header_col] = 'WellPosition';
  $header_row_aref->[2]->[$row_header_col] = 'ItemGroupName';
  $header_row_aref->[3]->[$row_header_col] = 'GenotypeName';

  my $header_filehandle;

  open($header_filehandle, ">$csv_file") or die "Cannot write to $csv_file: $!";

  for my $header_rec (@{$header_row_aref}) {

    print $header_filehandle join(',', @{$header_rec}[@{$selected_field_idx_aref}]) . $eol;
  }

  close($header_filehandle);

  if ( -e $content_file ) {

    unlink $content_file or die "Could not unlink $content_file: $!";
  }

  my @sql_select_field_list;

  for my $ds_field (@{$selected_field_aref}) {

    push(@sql_select_field_list, qq|"$ds_field"|);
  }

  $sql = qq|SELECT COUNT(*) FROM "markerdata${dataset_id}"|;

  $self->logger->debug("SQL: $sql");

  my ($r_nb_marker_err, $nb_marker) = read_cell($dbh_m_read, $sql, []);

  if ($r_nb_marker_err) {

    $self->logger->debug("Count the number of markers failed");

    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql_select_field_csv = join(',', @sql_select_field_list);

  $sql  = qq|SELECT COUNT(*) FROM "markerdata${dataset_id}" $filtering_exp|;

  my ($r_nb_mrk_matched, $nb_mrk_matched) = read_cell($dbh_m_read, $sql, $where_arg);

  if ($r_nb_mrk_matched) {

    $self->logger->debug("Count the number of markers matched failed");

    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql  = qq/COPY (SELECT $sql_select_field_csv FROM "markerdata${dataset_id}" $filtering_exp) /;
  $sql .= qq/INTO '$content_file' USING DELIMITERS ',','$monetdb_eol',''/;

  $self->logger->debug("COPY INTO FILE SQL: $sql");

  my ($copy_to_file_err, $copy_to_file_msg) = execute_sql($dbh_m_read, $sql, $where_arg);

  $self->logger->debug($copy_to_file_msg);

  if ($copy_to_file_err) {

    $self->logger->debug("COPY INTO file failed: $copy_to_file_msg");

    my $err_msg = "Unexpected error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();
  $dbh_m_read->disconnect();

  my ($cp_err, $cp_msg) = copy_file($content_file, $csv_file, 1, '>>');

  if ($cp_err) {

    $self->logger->debug("Copy $content_file to $csv_file failed: $cp_msg");

    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  unlink $content_file or die "Cannot unlink $content_file: $!";

  $output_meta_href->{'MarkerSequenceCol'}       = $mrk_seq_col;
  $output_meta_href->{'MarkerMetaColStart'}      = $mrk_meta_start_col;
  $output_meta_href->{'MarkerMetaColEnd'}        = $mrk_meta_end_col;
  $output_meta_href->{'MarkerDataColStart'}      = $mrk_data_start_col;
  $output_meta_href->{'MarkerDataColEnd'}        = $mrk_data_end_col;

  $output_meta_href->{'NumberOfMarkersInFile'}   = $nb_mrk_matched;
  $output_meta_href->{'NumberOfExtractsInFile'}  = $nb_extract_returned;
  $output_meta_href->{'NumberOfMarkers'}         = $nb_marker;
  $output_meta_href->{'LastHeaderRow'}           = scalar(@{$header_row_aref}) - 1;
  $output_meta_href->{'MarkerNameFieldName'}     = $mrk_name_fieldname;
  $output_meta_href->{'MarkerSequenceFieldName'} = $seq_fieldname;

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

sub list_marker_meta_field_runmode {

=pod list_marker_meta_field_HELP_START
{
"OperationName": "List metadata fields",
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
"URLParameter": [{"ParameterName": "id", "Description": "Existing AnalysisGroupId"}, {"ParameterName": "dsid", "Description": "Existing DataSetId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self    = shift;
  my $query   = $self->query();
  my $anal_id;
  my $ds_id;

  if (defined $self->param('id')) {

    $anal_id = $self->param('id');
  }

  if (defined $self->param('dsid')) {

    $ds_id = $self->param('dsid');
  }

  my $data_for_postrun_href = {};

  my $dbh_m_read = connect_mdb_read();

  if (defined $anal_id) {

    if (!record_existence($dbh_m_read, 'analysisgroup', 'AnalysisGroupId', $anal_id)) {

      my $err_msg = "AnalysisGroup ($anal_id) not found.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (defined $ds_id) {

    $anal_id = read_cell_value($dbh_m_read, 'dataset', 'AnalysisGroupId', 'DataSetId', $ds_id);

    if (length($anal_id) == 0) {

      my $err_msg = "DataSet ($ds_id) not found.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
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

  my $sql;

  my $dataset_id_aref = [];

  if (defined $ds_id) {

    $dataset_id_aref = [$ds_id];
  }
  else {

    $sql = 'SELECT "DataSetId" FROM "dataset" WHERE "AnalysisGroupId"=?';

    my ($read_ds_err, $read_ds_msg, $ds_data) = read_data($dbh_m_read, $sql, [$anal_id]);

    if ($read_ds_err) {

      $self->logger->debug("Read dataset failed: $read_ds_msg");

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $nb_dataset = scalar(@{$ds_data});

    if ($nb_dataset == 0) {

      my $err_msg = "AnalysisGroup($anal_id): no dataset.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    elsif ($nb_dataset > 1) {

      my $err_msg = "AnalysisGroup($anal_id): more than one dataset.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    for my $ds_rec (@{$ds_data}) {

      push(@{$dataset_id_aref}, $ds_rec->{'DataSetId'});
    }
  }

  my $dataset_id_csv = join(',', @{$dataset_id_aref});

  $sql  = 'SELECT "FactorId" FROM "datasetmarkermeta" ';
  $sql .= qq|WHERE "DataSetId" IN ($dataset_id_csv)|;

  my ($read_mrk_meta_err, $read_mrk_meta_msg, $mrk_meta_data) = read_data($dbh_m_read, $sql, []);

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

sub list_marker_runmode {

=pod list_marker_HELP_START
{
"OperationName": "List markers",
"Description": "List marker information from an analysis group dataset.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination Page='1' NumOfRecords='15626' NumOfPages='3126' NumPerPage='5' /><RecordMeta TagName='Marker' /><Marker DataSetId='14' MarkerExtRef='' MarkerName='4168179_45:A&gt;G' MarkerDescription='' MarkerAliasName='' MarkerAliasId='' MarkerSequence='CTGCAGGAAGACAAACAGCCCCTGCACCGGCGGCCCCAGCTCCTGTACCCGATCTGCTTGGTGACTTGAT' AnalysisGroupMarkerId='578258' /><Marker DataSetId='14' MarkerExtRef='' MarkerName='4168169_51:C&gt;G' MarkerDescription='' MarkerAliasName='' MarkerAliasId='' MarkerSequence='CTGCAGAGGCTAGTGAAGAGTTGACTACGACTGTTGGTGGGTTGACCAAAGACGATATTAC' AnalysisGroupMarkerId='578257' /><Marker DataSetId='14' MarkerExtRef='' MarkerName='4168147_6:G&gt;T' MarkerDescription='' MarkerAliasName='' MarkerAliasId='' MarkerSequence='CTGCAGGGTTTTGCAACATAACACGATAGAAAGAAAAAATGATTAC' AnalysisGroupMarkerId='578256' /><Marker DataSetId='14' MarkerExtRef='' MarkerName='4117749_41:T&gt;C' MarkerDescription='' MarkerAliasName='' MarkerAliasId='' MarkerSequence='CTGCAGAATCGGGAGTCTTCGTTTGTGTTGCCCCATTGAGGCTGAGACTTTAC' AnalysisGroupMarkerId='578255' /><Marker DataSetId='14' MarkerExtRef='' MarkerName='4112450_20:A&gt;G' MarkerDescription='' MarkerAliasName='' MarkerAliasId='' MarkerSequence='CTGCAGCTAAATCCAGCGGCTAACAGAGGACCAGAATGTATTAC' AnalysisGroupMarkerId='578254' /></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfRecords' : '15626', 'NumOfPages' : 3126, 'NumPerPage' : '5', 'Page' : '1'}], 'RecordMeta' : [{'TagName' : 'Marker'}], 'Marker' : [{'MarkerAliasName' : null, 'DataSetId' : '14', 'MarkerSequence' : 'CTGCAGGAAGACAAACAGCCCCTGCACCGGCGGCCCCAGCTCCTGTACCCGATCTGCTTGGTGACTTGAT', 'MarkerAliasId' : null, 'MarkerExtRef' : null, 'MarkerName' : '4168179_45:A>G', 'AnalysisGroupMarkerId' : '578258', 'MarkerDescription' : null},{'MarkerAliasName' : null, 'DataSetId' : '14', 'MarkerSequence' : 'CTGCAGAGGCTAGTGAAGAGTTGACTACGACTGTTGGTGGGTTGACCAAAGACGATATTAC', 'MarkerAliasId' : null, 'MarkerExtRef' : null, 'MarkerName' : '4168169_51:C>G', 'AnalysisGroupMarkerId' : '578257', 'MarkerDescription' : null},{'MarkerAliasName' : null, 'DataSetId' : '14', 'MarkerSequence' : 'CTGCAGGGTTTTGCAACATAACACGATAGAAAGAAAAAATGATTAC', 'MarkerAliasId' : null, 'MarkerExtRef' : null, 'MarkerName' : '4168147_6:G>T', 'AnalysisGroupMarkerId' : '578256', 'MarkerDescription' : null},{'MarkerAliasName' : null, 'DataSetId' : '14', 'MarkerSequence' : 'CTGCAGAATCGGGAGTCTTCGTTTGTGTTGCCCCATTGAGGCTGAGACTTTAC', 'MarkerAliasId' : null, 'MarkerExtRef' : null, 'MarkerName' : '4117749_41:T>C', 'AnalysisGroupMarkerId' : '578255', 'MarkerDescription' : null},{'MarkerAliasName' : null, 'DataSetId' : '14', 'MarkerSequence' : 'CTGCAGCTAAATCCAGCGGCTAACAGAGGACCAGAATGTATTAC', 'MarkerAliasId' : null, 'MarkerExtRef' : null, 'MarkerName' : '4112450_20:A>G', 'AnalysisGroupMarkerId' : '578254', 'MarkerDescription' : null}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='AnalysisGroup (18) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'AnalysisGroup (18) not found.'}]}"}],
"HTTPParameter": [{"Required": 0, "Name": "Filtering", "Description": "Filtering parameter string consisting of filtering expressions which are separated by ampersand (&) which needs to be encoded if HTTP GET method is used. Each filtering expression is composed of a database field name, a filtering operator and the filtering value."}, {"Required": 0, "Name": "FieldList", "Description": "Comma separated value of wanted fields."}, {"Required": 0, "Name": "Sorting", "Description": "Comma separated value of SQL sorting phrases."}],
"URLParameter": [{"ParameterName": "analid", "Description": "Existing AnalysisGroupId"}, {"ParameterName": "dsid", "Description": "Existing DataSetId"}, {"ParameterName": "nperpage", "Description": "Number of records in a page for pagination"}, {"ParameterName": "num", "Description": "The page number of the pagination"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self   = shift;
  my $query  = $self->query();

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

  #get database handles
  my $dbh_k = connect_kdb_read();
  my $dbh_m = connect_mdb_read();

  my $anal_id;
  my $ds_id;

  if (defined $self->param('analid')) {

    $anal_id = $self->param('analid');
  }

  if (defined $self->param('dsid')) {

    $ds_id = $self->param('dsid');
  }

  if (defined $anal_id) {

    if (!record_existence($dbh_m, 'analysisgroup', 'AnalysisGroupId', $anal_id)) {

      my $err_msg = "AnalsysiGroup ($anal_id): not found.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (defined $ds_id) {

    $anal_id = read_cell_value($dbh_m, 'dataset', 'AnalysisGroupId', 'DataSetId', $ds_id);

    if (length($anal_id) == 0) {

      my $err_msg = "DataSet ($ds_id) not found.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_anal_grp_ok, $trouble_anal_id_aref) = check_permission($dbh_m, 'analysisgroup', 'AnalysisGroupId',
                                                                 [$anal_id], $group_id, $gadmin_status,
                                                                 $READ_PERM);

  if (!$is_anal_grp_ok) {

    my $err_msg = "AnalsysiGroup ($anal_id): permission denied.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql;

  my $dataset_id_aref = [];

  if (defined $ds_id) {

    $dataset_id_aref = [$ds_id];
  }
  else {

    $sql = 'SELECT "DataSetId" FROM "dataset" WHERE "AnalysisGroupId"=?';

    my ($read_ds_err, $read_ds_msg, $ds_data) = read_data($dbh_m, $sql, [$anal_id]);

    if ($read_ds_err) {

      $self->logger->debug("Read dataset failed: $read_ds_msg");

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $nb_dataset = scalar(@{$ds_data});

    if ($nb_dataset == 0) {

      my $err_msg = "AnalysisGroup($anal_id): no dataset.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    for my $ds_rec (@{$ds_data}) {

      push(@{$dataset_id_aref}, $ds_rec->{'DataSetId'});
    }
  }

  my $dataset_id_csv = join(',', @{$dataset_id_aref});

  $sql = 'SELECT * FROM "analysisgroupmarker" LIMIT 1';

  my ($sam_r_ana_mrk_err, $sam_r_ana_mrk_msg, $sam_ana_mrk_data) = read_data($dbh_m, $sql, []);

  if ($sam_r_ana_mrk_err) {

    $self->logger->debug("Read sample marker data failed: $sam_r_ana_mrk_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $sample_data_aref = $sam_ana_mrk_data;

  my @field_list_all;

  if (scalar(@{$sample_data_aref}) == 1) {

    @field_list_all = keys(%{$sample_data_aref->[0]});
  }
  else {

    $self->logger->debug("It reaches here");
    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh_m, 'analysisgroupmarker');

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

  my $other_join = '';

  my $final_field_list = \@field_list_all;

  if (length($field_list_csv) > 0) {

    my ($sel_field_err, $sel_field_msg, $sel_field_list) = parse_selected_field($field_list_csv,
                                                                                $final_field_list,
                                                                                'AnalysisGroupMarkerId');

    if ($sel_field_err) {

      $self->logger->debug("Parse selected field failed: $sel_field_msg");
      my $err_msg = $sel_field_msg;
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;
  }
  else {

    $other_join  = ' LEFT JOIN "markeralias" ON ';
    $other_join .= ' "analysisgroupmarker"."AnalysisGroupMarkerId" = "markeralias"."AnalysisGroupMarkerId" ';

    push(@{$final_field_list}, '"markeralias"."MarkerAliasId"');
    push(@{$final_field_list}, '"markeralias"."MarkerAliasName"');
  }

  my @sql_field_list;

  for my $field (@{$final_field_list}) {

    if ($field =~ /\*/ || $field =~ /\"/) {

      push(@sql_field_list, $field);
    }
    else {

      push(@sql_field_list, qq|"analysisgroupmarker"."${field}"|);
    }
  }

  my $sql_field_csv = join(',', @sql_field_list);

  $sql = qq|SELECT $sql_field_csv FROM "analysisgroupmarker" $other_join |;

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering('"AnalysisGroupMarkerId"',
                                                                              '"analysisgroupmarker"',
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

    $filter_where_phrase = " AND $filter_phrase ";
  }

  my $filtering_exp = qq| WHERE "DataSetId" IN ($dataset_id_csv) $filter_where_phrase |;

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

    my $paged_limit_start_time = [gettimeofday()];

    my ($pg_id_err, $pg_id_msg, $nb_records,
        $nb_pages, $limit_clause, $rcount_time) = get_paged_filter($dbh_m,
                                                                   $nb_per_page,
                                                                   $page,
                                                                   '"analysisgroupmarker"',
                                                                   '"AnalysisGroupMarkerId"',
                                                                   $filtering_exp,
                                                                   $where_arg
            );

    $paged_limit_elapsed = tv_interval($paged_limit_start_time);

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

  $sql  .= $filtering_exp;

  my ($sort_err, $sort_msg, $sort_sql) = parse_sorting($sorting, $final_field_list, '"analysisgroupmarker"');

  if ($sort_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sort_msg}]};

    return $data_for_postrun_href;
  }

  if (length($sort_sql) > 0) {

    $sql .= " ORDER BY $sort_sql ";
  }
  else {

    $sql .= ' ORDER BY "analysisgroupmarker"."AnalysisGroupMarkerId" DESC';
  }

  $sql .= " $paged_limit_clause ";

  $self->logger->debug("SQL with VCol: $sql");

  my ($r_marker_err, $r_marker_msg, $marker_data) = read_data($dbh_m, $sql, $where_arg);

  if ($r_marker_err) {

    $self->logger->debug($r_marker_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Marker'        => $marker_data,
                                           'Pagination'    => $pagination_aref,
                                           'RecordMeta'    => [{'TagName' => 'Marker'}],
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  $dbh_m->disconnect();
  $dbh_k->disconnect();

  return $data_for_postrun_href;
}

sub get_marker_runmode {

=pod get_marker_HELP_START
{
"OperationName": "Get marker information",
"Description": "Get an individual marker information",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='Marker' /><Marker DataSetId='14' MarkerExtRef='' MarkerName='4112450_20:A&gt;G' MarkerDescription='' MarkerAliasName='' MarkerAliasId='' MarkerSequence='CTGCAGCTAAATCCAGCGGCTAACAGAGGACCAGAATGTATTAC' AnalysisGroupMarkerId='578254' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'Marker'}], 'Marker' : [{'MarkerAliasName' : null, 'DataSetId' : '14', 'MarkerSequence' : 'CTGCAGCTAAATCCAGCGGCTAACAGAGGACCAGAATGTATTAC', 'MarkerAliasId' : null, 'MarkerExtRef' : null, 'MarkerName' : '4112450_20:A>G', 'AnalysisGroupMarkerId' : '578254', 'MarkerDescription' : null}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Marker (2761118) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Marker (2761118) not found.'}]}"}],
"URLParameter": [{"ParameterName": "analid", "Description": "Existing AnalysisGroupId"}, {"ParameterName": "dsid", "Description": "Existing DataSetId"}, {"ParameterName": "id", "Description": "Existing AnalysisGroupMarkerId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self   = shift;
  my $query  = $self->query();

  my $data_for_postrun_href = {};

  #get database handles
  my $dbh_k = connect_kdb_read();
  my $dbh_m = connect_mdb_read();

  my $marker_id  = $self->param('id');

  my $anal_id;
  my $ds_id;

  if (defined $self->param('analid')) {

    $anal_id = $self->param('analid');
  }

  if (defined $self->param('dsid')) {

    $ds_id = $self->param('dsid');
  }

  if (defined $anal_id) {

    if (!record_existence($dbh_m, 'analysisgroup', 'AnalysisGroupId', $anal_id)) {

      my $err_msg = "AnalsysiGroup ($anal_id): not found.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (defined $ds_id) {

    $anal_id = read_cell_value($dbh_m, 'dataset', 'AnalysisGroupId', 'DataSetId', $ds_id);

    if (length($anal_id) == 0) {

      my $err_msg = "DataSet ($ds_id) not found.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_anal_grp_ok, $trouble_anal_id_aref) = check_permission($dbh_m, 'analysisgroup', 'AnalysisGroupId',
                                                                 [$anal_id], $group_id, $gadmin_status,
                                                                 $READ_PERM);

  if (!$is_anal_grp_ok) {

    my $err_msg = "AnalsysiGroup ($anal_id): permission denied.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql;

  my $dataset_id_aref = [];

  if (defined $ds_id) {

    $dataset_id_aref = [$ds_id];
  }
  else {

    $sql = 'SELECT "DataSetId" FROM "dataset" WHERE "AnalysisGroupId"=?';

    my ($read_ds_err, $read_ds_msg, $ds_data) = read_data($dbh_m, $sql, [$anal_id]);

    if ($read_ds_err) {

      $self->logger->debug("Read dataset failed: $read_ds_msg");

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $nb_dataset = scalar(@{$ds_data});

    if ($nb_dataset == 0) {

      my $err_msg = "AnalysisGroup($anal_id): no dataset.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    for my $ds_rec (@{$ds_data}) {

      push(@{$dataset_id_aref}, $ds_rec->{'DataSetId'});
    }
  }

  my $dataset_id_csv = join(',', @{$dataset_id_aref});

  my $chk_mrk_sql = 'SELECT "AnalysisGroupMarkerId" FROM "analysisgroupmarker" ';
  $chk_mrk_sql   .= qq|WHERE "DataSetId" IN ($dataset_id_csv) AND "AnalysisGroupMarkerId"=?|;

  my ($r_chk_mrk_id_err, $db_marker_id) = read_cell($dbh_m, $chk_mrk_sql, [$marker_id]);

  if ($r_chk_mrk_id_err) {

    $self->logger->debug("Check marker id failed");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  if (length($db_marker_id) == 0) {

    my $err_msg = "MarkerId ($marker_id): not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql  = qq|SELECT "analysisgroupmarker".*, "markeralias"."MarkerAliasId", "markeralias"."MarkerAliasName" |;
  $sql .= qq|FROM "analysisgroupmarker" LEFT JOIN "markeralias" |;
  $sql .= qq|ON "analysisgroupmarker"."AnalysisGroupMarkerId" = "markeralias"."AnalysisGroupMarkerId" |;
  $sql .= qq|WHERE "analysisgroupmarker"."AnalysisGroupMarkerId"=?|;

  my ($r_marker_err, $r_marker_msg, $marker_data) = read_data($dbh_m, $sql, [$marker_id]);

  if ($r_marker_err) {

    $self->logger->debug($r_marker_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Marker'        => $marker_data,
                                           'RecordMeta'    => [{'TagName' => 'Marker'}],
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  $dbh_m->disconnect();
  $dbh_k->disconnect();

  return $data_for_postrun_href;
}

sub list_marker_data_runmode {

=pod list_marker_data_HELP_START
{
"OperationName": "List marker data",
"Description": "List analysis group dataset marker data with pagination limiting the number of markers and blocksination limiting the number of samples/extracts.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination Page='1' NumOfRecords='15626' NumOfPages='7813' NumPerPage='2' /><MetaDataField FieldName='markerName' /><MetaDataField FieldName='TrimmedSequence' /><MetaDataField FieldName='callrate' FactorId='19' /><MetaDataField FieldName='Chrom_Brassica_v41_napus' FactorId='20' /><MetaDataField FieldName='ChromPos_Brassica_v41_napus' FactorId='21' /><Extract PlateName='' GenotypeId='0' FieldName='E_1650' GenotypeName='' WellPosition='A1' ItemGroupName='ITM_GRPN8750251' ExtractId='1650' ItemGroupId='1595' /><Extract PlateName='' GenotypeId='0' FieldName='E_1649' GenotypeName='' WellPosition='A1' ItemGroupName='ITM_GRPN0980556' ExtractId='1649' ItemGroupId='1594' /><DataSet DataSetType='86' MarkerNameFieldName='markerName' AnalysisGroupId='17' DataSetId='14' MarkerSequenceFieldName='TrimmedSequence' ParentDataSetId='0' Description='' /><RecordMeta TagName='MarkerData' /><Blocksination Block='1' NumOfBlocks='132' NumOfExtracts='264' NumPerBlock='2' /><MarkerData E_1649='0' E_1650='0' callrate='1' markerName='3112443' ChromPos_Brassica_v41_napus='3549294' TrimmedSequence='CTGCAGACATGAGGATCCCATATCTCCGGTTTTGGTTTGTTCTGAGGCTTAGAGAAGAAAAACATTTAGG' Chrom_Brassica_v41_napus='chrA10' /><MarkerData E_1649='1' E_1650='1' callrate='1' markerName='3122247' ChromPos_Brassica_v41_napus='0' TrimmedSequence='CTGCAGTTACTAAACCAGATGGCACAGCCTCTAGAGCATCAAAATCTGGAACTTTATCTTTAC' Chrom_Brassica_v41_napus='' /></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfRecords' : '15626', 'NumOfPages' : 7813, 'NumPerPage' : '2', 'Page' : '1'}], 'MetaDataField' : [{'FieldName' : 'markerName'},{'FieldName' : 'TrimmedSequence'},{'FactorId' : '19', 'FieldName' : 'callrate'},{'FactorId' : '20', 'FieldName' : 'Chrom_Brassica_v41_napus'},{'FactorId' : '21', 'FieldName' : 'ChromPos_Brassica_v41_napus'}], 'Extract' : [{'PlateName' : null, 'GenotypeName' : '', 'FieldName' : 'E_1650', 'GenotypeId' : '0', 'WellPosition' : 'A1', 'ItemGroupName' : 'ITM_GRPN8750251', 'ExtractId' : '1650', 'ItemGroupId' : '1595'},{'PlateName' : null, 'GenotypeName' : '', 'FieldName' : 'E_1649', 'GenotypeId' : '0', 'WellPosition' : 'A1', 'ItemGroupName' : 'ITM_GRPN0980556', 'ExtractId' : '1649', 'ItemGroupId' : '1594'}], 'DataSet' : [{'MarkerNameFieldName' : 'markerName', 'MarkerSequenceFieldName' : 'TrimmedSequence', 'DataSetType' : '86', 'AnalysisGroupId' : '17', 'DataSetId' : '14', 'ParentDataSetId' : '0', 'Description' : ''}], 'RecordMeta' : [{'TagName' : 'MarkerData'}], 'Blocksination' : [{'Block' : '1', 'NumOfExtracts' : '264', 'NumPerBlock' : '2', 'NumOfBlocks' : 132}], 'MarkerData' : [{'markerName' : '3112443', 'ChromPos_Brassica_v41_napus' : '3549294', 'E_1649' : '0', 'TrimmedSequence' : 'CTGCAGACATGAGGATCCCATATCTCCGGTTTTGGTTTGTTCTGAGGCTTAGAGAAGAAAAACATTTAGG', 'callrate' : '1', 'E_1650' : '0', 'Chrom_Brassica_v41_napus' : 'chrA10'},{'markerName' : '3122247', 'ChromPos_Brassica_v41_napus' : '0', 'E_1649' : '1', 'TrimmedSequence' : 'CTGCAGTTACTAAACCAGATGGCACAGCCTCTAGAGCATCAAAATCTGGAACTTTATCTTTAC', 'callrate' : '1', 'E_1650' : '1', 'Chrom_Brassica_v41_napus' : ''}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='AnalysisGroup (18) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'AnalysisGroup (18) not found.'}]}"}],
"HTTPParameter": [{"Required": 0, "Name": "Filtering", "Description": "Filtering parameter string consisting of filtering expressions which are separated by ampersand (&) which needs to be encoded if HTTP GET method is used. Each filtering expression is composed of a marker metadata field name or extract field name like E_6017, a filtering operator and the filtering value."}, {"Required": 0, "Name": "MarkerMetaFieldList", "Description": "CSV value for the list of wanted marker meta data columns if this parameter is not provided, DAL will export all marker meta data columns available in the dataset."}, {"Required": 0, "Name": "MarkerDataFieldList", "Description": "CSV value for the list of wanted sample/extract columns. If this parameter is not provided, DAL will export all samples/extracts available in the dataset."}, {"Required": 0, "Name": "Sorting", "Description": "Sorting parameter string consisting of sorting expressions separated by comma. Each sorting expression is composed of a marker metadata field name and a sorting operation which can be either ASC (Ascending), DESC (Descending), NASC (Ascending order for text that works like sorting numbers - NASC will make '99' before '222') and NASC (Descending order for text that works like sorting nuumbers - NDESC will make '222' before '99'."}],
"URLParameter": [{"ParameterName": "analid", "Description": "Existing AnalysisGroupId"}, {"ParameterName": "dsid", "Description": "Existing DataSetId"}, {"ParameterName": "nperpage", "Description": "Number of records in a page for pagination"}, {"ParameterName": "num", "Description": "The page number of the pagination"}, {"ParameterName": "nperblock", "Description": "Number of extracts in the block"}, {"ParameterName": "bnum", "Description": "The page number of the block of extracts"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self   = shift;
  my $query  = $self->query();

  my $mrk_meta_field_list_csv = '';

  if (defined $query->param('MarkerMetaFieldList')) {

    $mrk_meta_field_list_csv = $query->param('MarkerMetaFieldList');
  }

  $self->logger->debug("Marker Meta Field List: $mrk_meta_field_list_csv");

  my $mrk_data_field_list_csv = '';

  if (defined $query->param('MarkerDataFieldList')) {

    $mrk_data_field_list_csv = $query->param('MarkerDataFieldList');
  }

  $self->logger->debug("Marker Data Field List: $mrk_data_field_list_csv");

  my $filtering_csv = '';

  if (defined $query->param('Filtering')) {

    $filtering_csv = $query->param('Filtering');
  }

  $self->logger->debug("Filtering: $filtering_csv");

  my $sorting_csv = '';

  if (defined $query->param('Sorting')) {

    $sorting_csv = $query->param('Sorting');
  }

  $self->logger->debug("Sorting CSV: $sorting_csv");

  my $nb_extract_per_block = $self->param('nperblock');
  my $block                = $self->param('bnum');

  my $data_for_postrun_href = {};

  my ($int_err, $int_err_msg) = check_integer_value( {'nperblock' => $nb_extract_per_block,
                                                      'num'       => $block
                                                       });

  if ($int_err) {

    $int_err_msg .= ' not integer.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $int_err_msg}]};

    return $data_for_postrun_href;
  }

  my $nb_per_page = $self->param('nperpage');
  my $page        = $self->param('num');

  ($int_err, $int_err_msg) = check_integer_value( {'nperpage' => $nb_per_page,
                                                   'num'      => $page
                                                  });

  if ($int_err) {

    $int_err_msg .= ' not integer.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $int_err_msg}]};

    return $data_for_postrun_href;
  }

  #get database handles
  my $dbh_k = connect_kdb_read();
  my $dbh_m = connect_mdb_read();

  my $anal_id;
  my $ds_id;

  if (defined $self->param('analid')) {

    $anal_id = $self->param('analid');
  }

  if (defined $self->param('dsid')) {

    $ds_id = $self->param('dsid');
  }

  if (defined $anal_id) {

    if (!record_existence($dbh_m, 'analysisgroup', 'AnalysisGroupId', $anal_id)) {

      my $err_msg = "AnalsysiGroup ($anal_id): not found.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (defined $ds_id) {

    $anal_id = read_cell_value($dbh_m, 'dataset', 'AnalysisGroupId', 'DataSetId', $ds_id);

    if (length($anal_id) == 0) {

      my $err_msg = "DataSet ($ds_id) not found.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_anal_grp_ok, $trouble_anal_id_aref) = check_permission($dbh_m, 'analysisgroup', 'AnalysisGroupId',
                                                                 [$anal_id], $group_id, $gadmin_status,
                                                                 $READ_PERM);

  if (!$is_anal_grp_ok) {

    my $err_msg = "AnalsysiGroup ($anal_id): permission denied.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql;

  my $dataset_id_aref = [];
  my $ds_data         = [];

  my $read_ds_err;
  my $read_ds_msg;

  if (defined $ds_id) {

    $dataset_id_aref = [$ds_id];

    $sql = 'SELECT * FROM "dataset" WHERE "DataSetId"=?';

    ($read_ds_err, $read_ds_msg, $ds_data) = read_data($dbh_m, $sql, [$ds_id]);

    if ($read_ds_err) {

      $self->logger->debug("Read dataset failed: $read_ds_msg");

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }
  }
  else {

    $sql = 'SELECT * FROM "dataset" WHERE "AnalysisGroupId"=?';

    ($read_ds_err, $read_ds_msg, $ds_data) = read_data($dbh_m, $sql, [$anal_id]);

    if ($read_ds_err) {

      $self->logger->debug("Read dataset failed: $read_ds_msg");

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $nb_dataset = scalar(@{$ds_data});

    if ($nb_dataset == 0) {

      my $err_msg = "AnalysisGroup($anal_id): no dataset.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    elsif ($nb_dataset > 1) {

      my $err_msg = "AnalysisGroup($anal_id): more than one dataset.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    for my $ds_rec (@{$ds_data}) {

      push(@{$dataset_id_aref}, $ds_rec->{'DataSetId'});
    }
  }

  my $dataset_id = $dataset_id_aref->[0];

  my $read_dataset_sql   = 'SELECT "MarkerNameFieldName", "MarkerSequenceFieldName" ';
     $read_dataset_sql  .= 'FROM dataset WHERE "DataSetId"=? ';

  my ($r_df_val_err, $r_df_val_msg, $dataset_df_val_data) = read_data($dbh_m, $read_dataset_sql, [$dataset_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve dataset markername and sequence fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $mrk_name_fieldname =  undef;
  my $seq_fieldname      =  undef;

  my $nb_df_val_rec    =  scalar(@{$dataset_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve dataset default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $mrk_name_fieldname =  $dataset_df_val_data->[0]->{'MarkerNameFieldName'};
  $seq_fieldname      =  $dataset_df_val_data->[0]->{'MarkerSequenceFieldName'};

  my @filterable_fieldlist = ($mrk_name_fieldname, $seq_fieldname);

  $sql  = 'SELECT "FieldName", "FactorId" FROM "datasetmarkermeta" WHERE "DataSetId"=? ORDER BY "FactorId" ASC';

  my ($r_factor_err, $r_factor_msg, $factor_data) = read_data($dbh_m, $sql, [$dataset_id]);

  if ($r_factor_err) {

    $self->logger->debug("Read FactorId for analysis group ($anal_id) failed");
    my $err_msg = "Unexpected error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $meta_fieldname2factor_id_href = {};

  for my $factor_rec (@{$factor_data}) {

    my $meta_fieldname  = $factor_rec->{'FieldName'};
    $meta_fieldname2factor_id_href->{$meta_fieldname} = $factor_rec->{'FactorId'};

    push(@filterable_fieldlist, $meta_fieldname);
  }

  my $all_mrk_meta_field_csv = join(',', @filterable_fieldlist);

  # free up memory for factor id data
  $factor_data = [];

  $self->logger->debug("First read of extract info");

  $sql  = 'SELECT "FieldName" ';
  $sql .= 'FROM "datasetextract" ';
  $sql .= 'WHERE "DataSetId" = ?';

  my $extract_first_start_time = [gettimeofday()];

  my ($r_ext_err, $r_ext_msg, $all_extract_data) = read_data($dbh_m, $sql, [$dataset_id]);

  my $extract_first_elapsed = tv_interval($extract_first_start_time);

  $self->logger->debug("Extract first time: $extract_first_elapsed");

  if ($r_ext_err) {

    $self->logger->debug("Read extract failed: $r_ext_msg");
    my $err_msg = "Unexpected error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my @extract_fieldname_list;

  for my $extract_rec (@{$all_extract_data}) {

    my $ext_fieldname = $extract_rec->{'FieldName'};

    push(@extract_fieldname_list, $ext_fieldname);
    push(@filterable_fieldlist, $ext_fieldname);
  }

  my $all_mrk_data_field_csv = join(',', @extract_fieldname_list);

  if (length($mrk_meta_field_list_csv) == 0) {

    $mrk_meta_field_list_csv = $all_mrk_meta_field_csv;
  }

  my ($sel_meta_field_err, $sel_meta_field_msg, $sel_meta_field_list) = parse_selected_field($mrk_meta_field_list_csv,
                                                                                             \@filterable_fieldlist,
                                                                                             $mrk_name_fieldname);

  if ($sel_meta_field_err) {

    $self->logger->debug("Parse selected fields error: $sel_meta_field_msg");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_meta_field_msg}]};

    return $data_for_postrun_href;
  }

  my ($sel_data_field_err, $sel_data_field_msg, $sel_data_field_list) = parse_selected_field($mrk_data_field_list_csv,
                                                                                             \@extract_fieldname_list,
                                                                                             '');

  if ($sel_data_field_err) {

    $self->logger->debug("Parse selected fields error: $sel_data_field_msg");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_data_field_msg}]};

    return $data_for_postrun_href;
  }

  my $extract_filtering_exp = qq|WHERE "DataSetId"=? |;

  my $asterik_found = 0;
  my @sql_data_field_list;

  for my $data_field (@{$sel_data_field_list}) {

    if ($data_field eq '*') { # no data field list is provided, no need for field list that's why it's *

      $asterik_found = 1;
      last;
    }

    push(@sql_data_field_list, qq|'$data_field'|);
  }

  if ($asterik_found == 0) {

    my $sql_sel_data_field_csv = join(',', @sql_data_field_list);

    $extract_filtering_exp .= qq| AND "FieldName" IN ($sql_sel_data_field_csv)|;
  }

  my $blocination_aref = [];

  $dbh_m->disconnect();
  $dbh_m = connect_mdb_read();
  # Need to disconnect and reconnect for the VM to work due to problem with Perl connector to Monetdb

  $self->logger->debug("Extract pagination: $extract_filtering_exp");

  my $extract_pg_start_time = [gettimeofday()];

  my ($pg_extract_err, $pg_extract_msg, $nb_extract,
      $nb_blocks, $extract_limit_clause, $extract_count_time) = get_paged_filter($dbh_m,
                                                                                 $nb_extract_per_block,
                                                                                 $block,
                                                                                 '"datasetextract"',
                                                                                 '"DataSetExtractId"',
                                                                                 $extract_filtering_exp,
                                                                                 [$dataset_id]);

  my $extract_pg_elapsed = tv_interval($extract_pg_start_time);

  $self->logger->debug("Extract count time: $extract_count_time");
  $self->logger->debug("Extract pagination time: $extract_pg_elapsed");

  if ($pg_extract_err == 1) {

    $self->logger->debug($pg_extract_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  if ($pg_extract_err == 2) {

    my $err_msg = "Block ($block): out of range";
    $self->logger->debug("Extract limit clause: $extract_limit_clause");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $blocination_aref = [{'NumOfExtracts' => $nb_extract,
                        'NumOfBlocks'   => $nb_blocks,
                        'Block'         => $block,
                        'NumPerBlock'   => $nb_extract_per_block,
                       }];

  $sql  = 'SELECT "analgroupextract"."ExtractId", "datasetextract"."FieldName", "plate"."PlateName", ';
  $sql .= '"extract"."ItemGroupId", "extract"."GenotypeId", ';
  $sql .= 'CONCAT("extract"."WellRow", "extract"."WellCol") AS "WellPosition" ';
  $sql .= 'FROM "datasetextract" LEFT JOIN "analgroupextract" ';
  $sql .= 'ON "datasetextract"."AnalGroupExtractId" = "analgroupextract"."AnalGroupExtractId" ';
  $sql .= 'LEFT JOIN "extract" ON "analgroupextract"."ExtractId" = "extract"."ExtractId" ';
  $sql .= 'LEFT JOIN "plate" ON "extract"."PlateId" = "plate"."PlateId" ';
  $sql .= " $extract_filtering_exp ";
  $sql .= 'ORDER BY "analgroupextract"."ExtractId" DESC ';
  $sql .= $extract_limit_clause;

  $dbh_m->disconnect();
  $dbh_m = connect_mdb_read();
  # Need to disconnect and reconnect for the VM to work due to problem with Perl connector to Monetdb

  #$self->logger->debug("Extract INFO SQL: $sql");

  my $extract_info_start_time = [gettimeofday()];

  my ($r_extract_err, $r_extract_msg, $extract_data) = read_data($dbh_m, $sql, [$dataset_id]);

  my $extract_info_elapsed = tv_interval($extract_info_start_time);

  $self->logger->debug("Extract INFO SQL time: $extract_info_elapsed");

  if ($r_extract_err) {

    $self->logger->debug("Read extract failed: $r_extract_msg");
    my $err_msg = "Unexpected error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my @selected_extract_fieldname_list;

  my $geno_item_lookup_start_time = [gettimeofday()];

  my $extract_info_aref = [];

  my $uniq_geno_id    = {};
  my $uniq_itm_grp_id = {};

  my $geno_lookup    = {};
  my $itm_grp_lookup = {};

  for my $extract_rec (@{$extract_data}) {

    my $itm_grp_id    = $extract_rec->{'ItemGroupId'};
    my $geno_id       = $extract_rec->{'GenotypeId'};

    $uniq_geno_id->{$geno_id}       = 1;
    $uniq_itm_grp_id->{$itm_grp_id} = 1;
  }

  if (scalar(keys(%{$uniq_geno_id})) > 0) {

    my $geno_sql = 'SELECT GenotyeId, GenotypeName ';
    $geno_sql   .= 'FROM genotype WHERE GenotypeId IN (' . join(',', keys(%{$uniq_geno_id})) . ')';

    $self->logger->debug("GENO SQL: $geno_sql");
    $geno_lookup = $dbh_k->selectall_hashref($geno_sql, 'GenotypeId');
  }

  if (scalar(keys(%{$uniq_itm_grp_id})) > 0) {

    my $itm_grp_sql = 'SELECT ItemGroupId, ItemGroupName ';
    $itm_grp_sql   .= 'FROM itemgroup WHERE ItemGroupId IN (' . join(',', keys(%{$uniq_itm_grp_id})) . ')';

    $self->logger->debug("ITM GRP SQL: $itm_grp_sql");
    $itm_grp_lookup = $dbh_k->selectall_hashref($itm_grp_sql, 'ItemGroupId');
  }

  for my $extract_rec (@{$extract_data}) {

    my $extract_id    = $extract_rec->{'ExtractId'};
    my $ext_fieldname = $extract_rec->{'FieldName'};

    my $plate_name    = $extract_rec->{'PlateName'};
    my $well_pos      = $extract_rec->{'WellPosition'};
    my $itm_grp_id    = $extract_rec->{'ItemGroupId'};
    my $geno_id       = $extract_rec->{'GenotypeId'};

    my $itm_grp_name = $itm_grp_lookup->{$itm_grp_id}->{'ItemGroupName'};
    my $geno_name    = $geno_lookup->{$geno_id}->{'GenotypeName'};

    $extract_rec->{'ItemGroupName'} = $itm_grp_name;
    $extract_rec->{'GenotypeName'}  = $geno_name;

    push(@{$extract_info_aref}, $extract_rec);
    push(@selected_extract_fieldname_list, $ext_fieldname);
  }

  my $geno_item_lookup_elapsed = tv_interval($geno_item_lookup_start_time);

  $self->logger->debug("Genotype and Item Lookup time: $geno_item_lookup_elapsed");

  my $field_name2table_name  = { $mrk_name_fieldname => qq|"markerdata${dataset_id}"|,
                                 $seq_fieldname      => qq|"markerdata${dataset_id}"| };
  my $validation_func_lookup = {};

  my ($filtering_err, $filtering_msg,
      $filter_phrase, $where_arg) = parse_filtering(qq|"$mrk_name_fieldname"|,
                                                    qq|"markerdata${dataset_id}"|,
                                                    $filtering_csv,
                                                    \@filterable_fieldlist,
                                                    $validation_func_lookup,
                                                    $field_name2table_name);

  if ($filtering_err) {

    $self->logger->debug("Parsing filtering failed: $filtering_msg");

    my $err_msg = $filtering_msg;

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $filtering_exp = '';
  if (length($filter_phrase) > 0) {

    $filtering_exp = " WHERE $filter_phrase ";
  }

  $self->logger->debug("Filtering EXP: $filtering_exp");

  my $pagination_aref    = [];
  my $paged_limit_clause = '';
  my $paged_limit_elapsed;

  my $paged_limit_start_time = [gettimeofday()];

  $self->logger->debug("Filtering EXP: $filtering_exp");

  my ($pg_id_err, $pg_id_msg, $nb_records,
      $nb_pages, $limit_clause, $rcount_time) = get_paged_filter($dbh_m,
                                                                 $nb_per_page,
                                                                 $page,
                                                                 qq|"markerdata${dataset_id}"|,
                                                                 qq|"$mrk_name_fieldname"|,
                                                                 $filtering_exp,
                                                                 $where_arg
                                                                );

  $paged_limit_elapsed = tv_interval($paged_limit_start_time);

  $self->logger->debug("SQL Row count time: $rcount_time");

  if ($pg_id_err == 1) {

    $self->logger->debug($pg_id_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  if ($pg_id_err == 2) {

    my $err_msg = "Page ($page): out of range";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $pagination_aref = [{'NumOfRecords' => $nb_records,
                       'NumOfPages'   => $nb_pages,
                       'Page'         => $page,
                       'NumPerPage'   => $nb_per_page,
                      }];

  my ($sort_err, $sort_msg, $sort_sql) = parse_sorting($sorting_csv, \@filterable_fieldlist, qq|"markerdata${dataset_id}"|);

  if ($sort_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sort_msg}]};

    return $data_for_postrun_href;
  }

  my $sorting_exp = '';

  if (length($sort_sql) > 0) {

    $sorting_exp = qq| ORDER BY $sort_sql |;
  }

  my $meta_field_info_aref = [];

  my @sql_final_meta_field_list;

  for my $meta_field (@{$sel_meta_field_list}) {

    my $meta_rec = {"FieldName" => $meta_field};

    if (defined $meta_fieldname2factor_id_href->{$meta_field}) {

      $meta_rec->{"FactorId"} = $meta_fieldname2factor_id_href->{$meta_field};
    }

    push(@{$meta_field_info_aref}, $meta_rec);
    push(@sql_final_meta_field_list, qq|"$meta_field"|);
  }

  my @sql_final_extract_field_list;

  for my $extract_field (@selected_extract_fieldname_list) {

    push(@sql_final_extract_field_list, qq|"$extract_field"|);
  }

  my @sql_all_field_list = (@sql_final_meta_field_list, @sql_final_extract_field_list);

  if (scalar(@sql_all_field_list) == 0) {

    $self->logger->debug("Number of final fields is zero");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $sql_all_field_csv = join(',', @sql_all_field_list);

  $sql  = qq|SELECT $sql_all_field_csv |;
  $sql .= qq|FROM "markerdata${dataset_id}" |;
  $sql .= qq|$filtering_exp |;
  $sql .= qq|$sorting_exp |;
  $sql .= qq|$limit_clause|;

  #$self->logger->debug("DATA SQL: $sql");

  my $data_start_time = [gettimeofday()];

  $dbh_m->disconnect();
  $dbh_m = connect_mdb_read();
  # Need to disconnect and reconnect for the VM to work due to problem with Perl connector to Monetdb

  # where_arg here in the list function because of the filtering
  my ($read_mrk_data_err, $read_mrk_data_msg, $mrk_data) = read_data($dbh_m, $sql, $where_arg);

  my $data_elapsed = tv_interval($data_start_time);

  $self->logger->debug("Read marker data takes: $data_elapsed seconds");

  if ($read_mrk_data_err) {

    $self->logger->debug($read_mrk_data_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $dbh_k->disconnect();
  $dbh_m->disconnect();

  $data_for_postrun_href->{'Error'} = 0;
  $data_for_postrun_href->{'Data'}  = {'MarkerData'      => $mrk_data,
                                       'Extract'         => $extract_info_aref,
                                       'MetaDataField'   => $meta_field_info_aref,
                                       'DataSet'         => $ds_data,
                                       'Blocksination'   => $blocination_aref,
                                       'Pagination'      => $pagination_aref,
                                       'RecordMeta'      => [{'TagName' => 'MarkerData'}],
  };

  return $data_for_postrun_href;
}

sub add_markermap_runmode {

=pod add_markermap_gadmin_HELP_START
{
"OperationName": "Add Marker Map",
"Description": "Create marker map definition",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "marker",
"KDDArTTable": "markermap",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='9' ParaName='MarkerMapId' /><Info Message='MarkerMap (9) been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '10', 'ParaName' : 'MarkerMapId'}], 'Info' : [{'Message' : 'MarkerMap (10) been added successfully.'}]}",
"ErrorMessageXML": [{"NameAlreadyExists": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error MapName='MapName (MarkerMap_) already exists.' /></DATA>"}],
"ErrorMessageJSON": [{"NameAlreadyExists": "{'Error' : [{'MapName' : 'MapName (MarkerMap_) already exists.'}]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_mdb_read();

  my $skip_field = {'OperatorId' => 1};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'markermap', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $map_name    = $query->param('MapName');
  my $map_type    = $query->param('MapType');

  my $model_ref   = undef;
  my $map_desc    = undef;
  my $map_soft    = undef;
  my $map_params  = undef;

  if (defined $query->param('ModelRef')) {

    $model_ref = $query->param('ModelRef');
  }

  if (defined $query->param('MapDescription')) {

    $map_desc = $query->param('MapDescription');
  }

  if (defined $query->param('MapSoftware')) {

    $map_soft = $query->param('MapSoftware');
  }

  if (defined $query->param('MapParameters')) {

    $map_params = $query->param('MapParameters');
  }

  my $dbh_k_read = connect_kdb_read();

  if (!type_existence($dbh_k_read, 'genmap', $map_type)) {

    my $err_msg = "MapType ($map_type) is not found or inactive.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'MapType' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_m_write = connect_mdb_write();

  if (record_existence($dbh_m_write, 'markermap', 'MapName', $map_name)) {

    my $err_msg = "MapName ($map_name) already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'MapName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($next_val_err, $next_val_msg, $mrk_map_id) = get_next_value_for($dbh_m_write, 'markermap', 'MarkerMapId');

  if ($next_val_err) {

    $self->logger->debug($next_val_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $user_id = $self->authen->user_id();

  my $sql = 'INSERT INTO "markermap"( ';
  $sql   .= '"MarkerMapId", ';
  $sql   .= '"MapName", ';
  $sql   .= '"MapType", ';
  $sql   .= '"OperatorId", ';
  $sql   .= '"ModelRef", ';
  $sql   .= '"MapDescription", ';
  $sql   .= '"MapSoftware", ';
  $sql   .= '"MapParameters") ';
  $sql   .= 'VALUES(?, ?, ?, ?, ?, ?, ?, ?)';

  my $sth = $dbh_m_write->prepare($sql);
  $sth->execute($mrk_map_id, $map_name, $map_type, $user_id, $model_ref, $map_desc, $map_soft, $map_params);

  my $marker_map_id = -1;

  if (!$dbh_m_write->err()) {

    $marker_map_id = $mrk_map_id;
  }
  else {

    $self->logger->debug("Add markermap failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_m_write->disconnect();

  my $info_msg_aref  = [{'Message' => "MarkerMap ($marker_map_id) been added successfully."}];
  my $return_id_aref = [{'Value' => "$marker_map_id", 'ParaName' => 'MarkerMapId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref,
                                           'ReturnId'  => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_markermap_runmode {

=pod update_markermap_gadmin_HELP_START
{
"OperationName": "Update Marker Map",
"Description": "Update marker map definition",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "marker",
"KDDArTTable": "markermap",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='MarkerMap (13) been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'MarkerMap (14) been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='MarkerMap (18) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'MarkerMap (18) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing MarkerMapId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_mdb_read();

  my $skip_field = {'OperatorId' => 1};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'markermap', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $marker_map_id = $self->param('id');

  my $map_name      = $query->param('MapName');
  my $map_type      = $query->param('MapType');

  my $dbh_m_write = connect_mdb_write();

  if (!record_existence($dbh_m_write, 'markermap', 'MarkerMapId', $marker_map_id)) {

    my $err_msg = "MarkerMap ($marker_map_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $read_markermap_sql    =  'SELECT "OperatorId", "ModelRef", "MapDescription", "MapSoftware", "MapParameters" ';
     $read_markermap_sql    .= 'FROM markermap WHERE "MarkerMapId"=? ';

  my ($r_df_val_err, $r_df_val_msg, $markermap_df_val_data) = read_data($dbh_m_write, $read_markermap_sql, [$marker_map_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve markermap default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $db_operator_id     =   undef;
  my $model_ref          =   undef;
  my $map_desc           =   undef;
  my $map_soft           =   undef;
  my $map_params         =   undef;

  my $nb_df_val_rec    =  scalar(@{$markermap_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve markermap default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $db_operator_id     =   $markermap_df_val_data->[0]->{'OperatorId'};
  $model_ref          =   $markermap_df_val_data->[0]->{'ModelRef'};
  $map_desc           =   $markermap_df_val_data->[0]->{'MapDescription'};
  $map_soft           =   $markermap_df_val_data->[0]->{'MapSoftware'};
  $map_params         =   $markermap_df_val_data->[0]->{'MapParameters'};


  my $user_id = $self->authen->user_id();

  if ("$db_operator_id" ne "$user_id") {

    my $err_msg = "MarkerMap ($marker_map_id) permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }


  if (defined $query->param('ModelRef')) {

    $model_ref = $query->param('ModelRef');
  }

  if (defined $query->param('MapDescription')) {

    $map_desc = $query->param('MapDescription');
  }

  if (defined $query->param('MapSoftware')) {

    $map_soft = $query->param('MapSoftware');
  }

  if (defined $query->param('MapParameters')) {

    $map_params = $query->param('MapParameters');
  }

  if (length($model_ref) == 0) { $model_ref = undef; }

  if (length($map_desc) == 0) { $map_desc = undef; }

  if (length($map_soft) == 0) { $map_soft = undef; }

  if (length($map_params) == 0) { $map_params = undef; }

  my $dbh_k_read = connect_kdb_read();

  if (!type_existence($dbh_k_read, 'genmap', $map_type)) {

    my $err_msg = "MapType ($map_type) is not found or inactive.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'MapType' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $sql = 'SELECT "MarkerMapId" FROM "markermap" WHERE "MarkerMapId"<>? AND "MapName"=?';

  my ($read_chk_map_name_err, $db_marker_map_id) = read_cell($dbh_m_write, $sql, [$marker_map_id, $map_name]);

  if ($read_chk_map_name_err) {

    $self->logger->debug("Check if MapName already exists failed");
    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_marker_map_id) > 0) {

    my $err_msg = "MapName ($map_name) already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'MapName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql    = 'UPDATE "markermap" SET ';
  $sql   .= '"MapName" = ?, ';
  $sql   .= '"MapType" = ?, ';
  $sql   .= '"ModelRef" = ?, ';
  $sql   .= '"MapDescription" = ?, ';
  $sql   .= '"MapSoftware" = ?, ';
  $sql   .= '"MapParameters" = ? ';
  $sql   .= 'WHERE "MarkerMapId" = ?';

  my $sth = $dbh_m_write->prepare($sql);
  $sth->execute($map_name, $map_type, $model_ref, $map_desc, $map_soft, $map_params, $marker_map_id);

  if ($dbh_m_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_m_write->disconnect();

  my $info_msg_aref  = [{'Message' => "MarkerMap ($marker_map_id) been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_markermap {

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

  my $dbh = connect_mdb_read();

  my $sql = 'SELECT * FROM "markermap" ';
  $sql   .= $where_clause;
  $sql   .= ' ORDER BY "MarkerMapId" DESC';

  my $sth = $dbh->prepare($sql);
  # parameters provided by the caller
  # for example, ('WHERE FieldA=?', '1')
  $sth->execute(@_);

  my $err = 0;
  my $msg = '';
  my $marker_map_data = [];

  if ( !$dbh->err() ) {

    my $array_ref = $sth->fetchall_arrayref({});

    if ( !$sth->err() ) {

      $marker_map_data = $array_ref;
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

  my $extra_attr_marker_map_data = [];

  if ($extra_attr_yes && ($gadmin_status eq '1')) {

    my $dbh_k = connect_kdb_read();

    my $operator_id_href = {};

    for my $row (@{$marker_map_data}) {

      $operator_id_href->{$row->{'OperatorId'}} = 1;
    }

    my $operator_lookup = {};

    if (scalar(keys(%{$operator_id_href})) > 0) {

      my $operator_sql = 'SELECT UserId, UserName FROM systemuser WHERE UserId IN (';
      $operator_sql   .= join(',', keys(%{$operator_id_href})) . ')';

      $self->logger->debug("Operator SQL: $operator_sql");

      my $oper_sth = $dbh_k->prepare($operator_sql);
      $oper_sth->execute();
      $operator_lookup = $oper_sth->fetchall_hashref('UserId');
      $oper_sth->finish();
    }

    for my $row (@{$marker_map_data}) {

      my $marker_map_id      = $row->{'MarkerMapId'};
      my $operator_id        = $row->{'OperatorId'};

      $row->{'OperatorName'} = $operator_lookup->{$operator_id}->{'UserName'};
      $row->{'update'}       = "update/markermap/$marker_map_id";
      $row->{'import'}       = "markermap/${marker_map_id}/import/mapposition/csv";
      $row->{'export'}       = "markermap/${marker_map_id}/export/mapposition/csv";

      push(@{$extra_attr_marker_map_data}, $row);
    }

    $dbh_k->disconnect();
  }
  else {

    $extra_attr_marker_map_data = $marker_map_data;
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_marker_map_data);
}

sub list_markermap_runmode {

=pod list_markermap_HELP_START
{
"OperationName": "List marker maps",
"Description": "List marker map position",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='MarkerMap' /><MarkerMap MapParameters='' OperatorId='0' MarkerMapId='14' OperatorName='admin' ModelRef='' MapName='MarkerMap_6792156' MapType='139' MapDescription='Updated marker map name' update='update/markermap/14' MapSoftware='' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'MarkerMap'}], 'MarkerMap' : [{'MapParameters' : null, 'MarkerMapId' : '14', 'OperatorId' : '0', 'OperatorName' : 'admin', 'MapName' : 'MarkerMap_6792156', 'ModelRef' : null, 'MapType' : '139', 'MapDescription' : 'Updated marker map name', 'update' : 'update/markermap/14', 'MapSoftware' : null}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = shift;

  my $data_for_postrun_href = {};

  my $msg = '';

  my ($markermap_err, $markermap_msg, $markermap_data) = $self->list_markermap(1, '');

  if ($markermap_err) {

    $msg = 'Unexpected error';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $msg}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'MarkerMap'  => $markermap_data,
                                           'RecordMeta' => [{'TagName' => 'MarkerMap'}],
  };

  return $data_for_postrun_href;
}

sub get_markermap_runmode {

=pod get_markermap_HELP_START
{
"OperationName": "Get Marker Map",
"Description": "Get marker map definition",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='MarkerMap' /><MarkerMap MapParameters='' OperatorId='0' MarkerMapId='11' OperatorName='admin' ModelRef='' MapName='MarkerMap_9414766' MapType='138' MapDescription='Automatic testing' update='update/markermap/11' MapSoftware='' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'MarkerMap'}], 'MarkerMap' : [{'MapParameters' : null, 'MarkerMapId' : '11', 'OperatorId' : '0', 'OperatorName' : 'admin', 'MapName' : 'MarkerMap_9414766', 'ModelRef' : null, 'MapType' : '138', 'MapDescription' : 'Automatic testing', 'update' : 'update/markermap/11', 'MapSoftware' : null}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing MarkerMapId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self         = shift;
  my $markermap_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_mdb_read();

  if (!record_existence($dbh, 'markermap', 'MarkerMapId', $markermap_id)) {

    my $err_msg = "MarkerMap ($markermap_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  my $where_clause = 'WHERE "MarkerMapId"=?';

  my ($markermap_err, $markermap_msg, $markermap_data) = $self->list_markermap(1, $where_clause, $markermap_id);

  if ($markermap_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'MarkerMap'  => $markermap_data,
                                           'RecordMeta' => [{'TagName' => 'MarkerMap'}],
  };

  return $data_for_postrun_href;
}

sub import_markermap_position_runmode {

=pod import_markermap_position_gadmin_HELP_START
{
"OperationName": "Import marker map position",
"Description": "Import marker map positions from a csv file",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='12642 records of marker map positions have been inserted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : '12642 records of marker map positions have been inserted successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='MarkerMap (18) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'MarkerMap (18) not found.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "CSV",
"UploadFileParameterName": "uploadfile",
"HTTPParameter": [{"Required": 1, "Name": "AnalysisGroupIdValue", "Description": "The ID value of the AnalysisGroupId where marker names can be found."}, {"Required": 1, "Name": "MarkerName", "Description": "Column number (counting from zero) in the upload CSV file which contains MarkerName."}, {"Required": 1, "Name": "ContigName", "Description": "Column number (counting from zero) in the upload CSV file which contains ContigName."}, {"Required": 1, "Name": "MarkerName", "Description": "Column number (counting from zero) in the upload CSV file which contains ContigPosition."}, {"Required": 0, "Name": "Forced", "Description": "Either 1 or 0. If value 1 is provided, marker name uniqueness requirement will be ignored."}],
"URLParameter": [{"ParameterName": "mrkmapid", "Description": "MarkerMapId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self    = shift;
  my $query   = $self->query();

  my $markermap_id = $self->param('mrkmapid');

  my $data_for_postrun_href = {};

  my $dbh_m_read = connect_mdb_read();

  if (!record_existence($dbh_m_read, 'markermap', 'MarkerMapId', $markermap_id)) {

    my $err_msg = "MarkerMap ($markermap_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $anal_id = '';

  if (defined $query->param('AnalysisGroupIdValue')) {

    $anal_id = $query->param('AnalysisGroupIdValue');
  }

  $self->logger->debug("AnalysisGroupId: $anal_id");

  if (length($anal_id) > 0) {

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

    my $count_ds_sql = 'SELECT COUNT(*) FROM "dataset" WHERE "AnalysisGroupId"=?';

    my ($r_count_ds_err, $nb_ds) = read_cell($dbh_m_read, $count_ds_sql, [$anal_id]);

    if ($r_count_ds_err) {

      $self->logger->debug("Count dataset failed");
      my $err_msg = "Unexpected Error.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if ($nb_ds eq '0') {

      my $err_msg = "AnalysisGroup ($anal_id): no dataset.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $forced                 = $query->param('Forced');

  my $marker_name_col        = $query->param('MarkerName');
  my $contig_name_col        = $query->param('ContigName');
  my $contig_pos_col         = $query->param('ContigPosition');

  my ($missing_err, $missing_href) = check_missing_href( {
                                                          'MarkerName'           => $marker_name_col,
                                                          'ContigName'           => $contig_name_col,
                                                          'ContigPosition'       => $contig_pos_col,
                                                          'AnalysisGroupIdValue' => $anal_id
                                                         } );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  my $data_csv_file = $self->authen->get_upload_file();

  my $num_of_col = get_csvfile_num_of_col($data_csv_file);

  $self->logger->debug("Number of columns: $num_of_col");

  my ($col_def_err, $col_def_err_href) = check_col_def_href( {
                                                              'MarkerName'          => $marker_name_col,
                                                              'ContigName'          => $contig_name_col,
                                                              'ContigPosition'      => $contig_pos_col,
                                                             },
                                                             $num_of_col);

  if ($col_def_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$col_def_err_href]};

    return $data_for_postrun_href;
  }

  $dbh_m_read->disconnect();
  $dbh_m_read = connect_mdb_read();
  # Disconnect and reconnect to fix problem with Perl connector to Monetdb in vm

  my $dbh_m_write = connect_mdb_write();

  my $count_sql = 'SELECT COUNT(*) FROM "markermapposition" WHERE "MarkerMapId"=?';

  my ($r_count_err, $nb_position) = read_cell($dbh_m_read, $count_sql, [$markermap_id]);

  if ($nb_position > 0) {

    if ($forced ne '1') {

      my $err_msg = "MarkerMap($markermap_id): data already exists - force is needed.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    else {

      my $del_sql = 'DELETE FROM "markermapposition" WHERE "MarkerMapId"=?';

      my ($del_err, $del_msg) = execute_sql($dbh_m_write, $del_sql, [$markermap_id]);

      if ($del_err) {

        $self->logger->debug("Delete failed: $del_msg");
        my $err_msg = "Unexpected Error.";

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
  }

  my $matched_col = {};

  $matched_col->{$marker_name_col}     = 'MarkerName';
  $matched_col->{$contig_name_col}     = 'ContigName';
  $matched_col->{$contig_pos_col}      = 'ContigPosition';

  my @fieldname_list;

  for (my $i = 0; $i < $num_of_col; $i++) {

    if ($matched_col->{$i}) {

      push(@fieldname_list, $matched_col->{$i});
    }
    else {

      push(@fieldname_list, 'null');
    }
  }

  my ($mrkmap_posdata_aref, $csv_err, $err_msg) = csvfile2arrayref($data_csv_file, \@fieldname_list, 0);

  if ($csv_err) {

    $self->logger->debug("Read CSV into aref failed: $err_msg");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $marker_name2id_lookup = {};

  my $line_counter = 1;

  my $nb_of_row         = scalar(@{$mrkmap_posdata_aref});
  my $row_increment     = 200;

  my $sql;

  my $i = 0;

  while ($i < $nb_of_row) {

    my $start_j = $i;
    my $end_j   = $i + $row_increment;

    if ($end_j > $nb_of_row) {

      $end_j = $nb_of_row;
    }

    my $marker_name_href = {};

    for (my $j = $start_j; $j < $end_j; $j++) {

      my $mrkmap_pos_rec = $mrkmap_posdata_aref->[$j];

      my $marker_name       = $mrkmap_pos_rec->{'MarkerName'};
      my $contig_name       = $mrkmap_pos_rec->{'ContigName'};
      my $contig_pos        = $mrkmap_pos_rec->{'ContigPosition'};

      my ($mis_data_err, $mis_data_msg) = check_missing_value( {
                                                                'MarkerName'          => $marker_name,
                                                                'ContigName'          => $contig_name,
                                                                'ContigPosition'      => $contig_pos,
                                                               } );

      if ($mis_data_err) {

        my $err_msg = "Row ($line_counter): $mis_data_msg is missing";

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{"Message" => $err_msg}]};

        return $data_for_postrun_href;
      }

      my ($int_id_err, $int_id_msg) = check_integer_value( {
                                                            'ContigPosition'    => $contig_pos,
                                                           });

      if ($int_id_err) {

        $int_id_msg = "Row ($line_counter): " . $int_id_msg . ' not integer.';
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $int_id_msg}]};

        return $data_for_postrun_href;
      }

      $marker_name_href->{"'" . $marker_name . "'"} = 1;

      $line_counter += 1;
    }

    my $chk_mrk_name_sql = 'SELECT "MarkerName", COUNT("AnalysisGroupMarkerId") AS "MarkerNameCount" ';
    $chk_mrk_name_sql   .= 'FROM "analysisgroupmarker" LEFT JOIN "dataset" ON ';
    $chk_mrk_name_sql   .= '"analysisgroupmarker"."DataSetId" = "dataset"."DataSetId" ';
    $chk_mrk_name_sql   .= qq|WHERE "AnalysisGroupId"=$anal_id AND "MarkerName" IN (|;
    $chk_mrk_name_sql   .= join(',', keys(%{$marker_name_href})) . ") ";
    $chk_mrk_name_sql   .= 'GROUP BY "MarkerName"';

    $self->logger->debug("Check SQL: $chk_mrk_name_sql");

    my $mrk_name_count_lookup = $dbh_m_read->selectall_hashref($chk_mrk_name_sql, 'MarkerName');

    $dbh_m_read->disconnect();
    $dbh_m_read = connect_mdb_read();
    # Disconnect and reconnect to fix problem with Perl connector to Monetdb in vm

    $sql  = 'SELECT "MarkerName", "AnalysisGroupMarkerId" ';
    $sql .= 'FROM "analysisgroupmarker" LEFT JOIN "dataset" ON ';
    $sql .= '"analysisgroupmarker"."DataSetId" = "dataset"."DataSetId" ';
    $sql .= qq|WHERE "AnalysisGroupId"=$anal_id AND "MarkerName" IN (|;
    $sql .= join(',', keys(%{$marker_name_href})) . ") ";

    $self->logger->debug("SQL map MarkerName 2 MarkerId: $sql");

    my $local_mrk_name_id_lookup = $dbh_m_read->selectall_hashref($sql, 'MarkerName');

    for my $mrk_name (keys(%{$marker_name_href})) {

      $mrk_name =~ s/'//g;

      if (defined $mrk_name_count_lookup->{$mrk_name}->{'MarkerNameCount'}) {

        if ($mrk_name_count_lookup->{$mrk_name}->{'MarkerNameCount'} > 1) {

          if ($forced ne '1') {

            my $err_msg = "MarkerName ($mrk_name) is not unique.";
            $data_for_postrun_href->{'Error'} = 1;
            $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

            return $data_for_postrun_href;
          }
          else {

            my $duplicate_mrk_id = $local_mrk_name_id_lookup->{$mrk_name}->{'AnalysisGroupMarkerId'};
            $self->logger->debug("DUPLICATE MARKER ID: $duplicate_mrk_id");
          }
        }
      }
      else {

        if (length($anal_id) > 0) {

          my $err_msg = "MarkerName ($mrk_name): not found.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
      }

      my $mrk_id = $local_mrk_name_id_lookup->{$mrk_name}->{'AnalysisGroupMarkerId'};

      $marker_name2id_lookup->{$mrk_name} = $mrk_id;
    }

    $i += $row_increment;
  }

  $dbh_m_read->disconnect();

  my $nb_bulk_insert = 10;

  $i = 0;

  my $total_row_inserted = 0;

  $dbh_m_write->disconnect();
  # Disconnect the write handler for reconnection inside the while loop to fix the problem with Perl connector to Monetdb for vm

  while ($i < $nb_of_row) {

    my $start_j = $i;
    my $end_j   = $i + $nb_bulk_insert;

    if ($end_j > $nb_of_row) {

      $end_j = $nb_of_row;
    }

    $sql  = 'INSERT INTO "markermapposition" ';
    $sql .= '("MarkerMapId","AnalysisGroupMarkerId","ContigName","ContigPosition") ';
    $sql .= 'VALUES ';

    my @insert_values;

    my $marker_name_href = {};

    for (my $j = $start_j; $j < $end_j; $j++) {

      my $mrkmap_pos_rec    = $mrkmap_posdata_aref->[$j];

      my $marker_name       = $mrkmap_pos_rec->{'MarkerName'};
      my $contig_name       = $mrkmap_pos_rec->{'ContigName'};
      my $contig_pos        = $mrkmap_pos_rec->{'ContigPosition'};
      my $marker_id;

      if ( defined $marker_name2id_lookup->{$marker_name} ) {

        $marker_id = $marker_name2id_lookup->{$marker_name};
      }
      else {

        #$self->logger->debug("MarkerId for MarkName ($marker_name) unknown");
        $marker_id = 0;
      }

      push(@insert_values, qq|(${markermap_id},${marker_id},'${contig_name}',${contig_pos})|);
    }

    $sql .= join(',', @insert_values);

    #$self->logger->debug("INSET Map position SQL: $sql");

    $dbh_m_write = connect_mdb_write();

    my $nbrow_inserted = $dbh_m_write->do($sql);

    if ($dbh_m_write->err()) {

      $self->logger->debug("Insert map position failed");
      my $err_msg = "Unexpected Error.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    $total_row_inserted += $nbrow_inserted;

    $i += $nb_bulk_insert;

    $dbh_m_write->disconnect();
    # Need to disconnect and reconnect inside the loop because Perl connector to Monetdb has a problem on vm
  }


  my $info_msg = "$total_row_inserted records of marker map positions have been inserted successfully.";
  my $info_msg_aref = [{'Message' => $info_msg}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_markermap_position_advanced_runmode {

=pod list_markermap_position_advanced_HELP_START
{
"OperationName": "List Marker Map position",
"Description": "List marker map positions in pagination with filtering and sorting ability",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination Page='1' NumOfRecords='12642' NumOfPages='6321' NumPerPage='2' /><MarkerMapPosition AnalysisGroupId='26' MarkerMapId='16' DataSetId='20' MarkerExtRef='' MarkerName='' MarkerDescription='' MarkerSequence='CTGCAGACATGAGGATCCCATATCTCCGGTTTTGGTTTGTTCTGAGGCTTAGAGAAGAAAAACATTTAGG' ContigName='chrA10' ContigPosition='3549294' AnalysisGroupMarkerId='656368' MarkerMapPositionId='218712' AnalysisGroupMarkerName='3112443' /><MarkerMapPosition AnalysisGroupId='26' MarkerMapId='16' DataSetId='20' MarkerExtRef='' MarkerName='' MarkerDescription='' MarkerSequence='CTGCAGAGCTCCTTGTCCGTTCATGAGAAGAAGTTTAC' ContigName='chrA03' ContigPosition='22372485' AnalysisGroupMarkerId='656370' MarkerMapPositionId='214894' AnalysisGroupMarkerName='3145772' /><RecordMeta TagName='MarkerMapPosition' /></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfRecords' : '12642', 'NumOfPages' : 6321, 'NumPerPage' : '2', 'Page' : '1'}], 'MarkerMapPosition' : [{'MarkerMapId' : '16', 'AnalysisGroupId' : '26', 'DataSetId' : '20', 'MarkerExtRef' : null, 'MarkerName' : null, 'MarkerDescription' : null, 'MarkerSequence' : 'CTGCAGACATGAGGATCCCATATCTCCGGTTTTGGTTTGTTCTGAGGCTTAGAGAAGAAAAACATTTAGG', 'ContigName' : 'chrA10', 'ContigPosition' : '3549294', 'MarkerMapPositionId' : '218712', 'AnalysisGroupMarkerId' : '656368', 'AnalysisGroupMarkerName' : '3112443'},{'MarkerMapId' : '16', 'AnalysisGroupId' : '26', 'DataSetId' : '20', 'MarkerExtRef' : null, 'MarkerName' : null, 'MarkerDescription' : null, 'MarkerSequence' : 'CTGCAGAGCTCCTTGTCCGTTCATGAGAAGAAGTTTAC', 'ContigName' : 'chrA03', 'ContigPosition' : '22372485', 'MarkerMapPositionId' : '214894', 'AnalysisGroupMarkerId' : '656370', 'AnalysisGroupMarkerName' : '3145772'}], 'RecordMeta' : [{'TagName' : 'MarkerMapPosition'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPParameter": [{"Required": 0, "Name": "Filtering", "Description": "Filtering parameter string consisting of filtering expressions which are separated by ampersand (&) which needs to be encoded if HTTP GET method is used. Each filtering expression is composed of a database field name, a filtering operator and the filtering value."}, {"Required": 0, "Name": "Sorting", "Description": "Comma separated value of SQL sorting phrases."}],
"URLParameter": [{"ParameterName": "mrkmapid", "Description": "Existing MarkerMapId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $markermap_id = $self->param('mrkmapid');

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

  my $filtering_csv = '';

  if (defined $query->param('Filtering')) {

    $filtering_csv = $query->param('Filtering');
  }

  $self->logger->debug("Filtering csv: $filtering_csv");

  my $sorting = '';

  if (defined $query->param('Sorting')) {

    $sorting = $query->param('Sorting');
  }

  my $dbh = connect_mdb_read();

  if (!record_existence($dbh, 'markermap', 'MarkerMapId', $markermap_id)) {

    my $err_msg = "MarkerMap ($markermap_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $field_list = ['MarkerMapId', 'AnalysisGroupMarkerId', 'MarkerName', 'ContigName', 'ContigPosition'];

  my $field_name2table_name  = { "MarkerName" => 'markermapposition' };
  my $validation_func_lookup = {};

  my ($filter_err, $filter_msg,
      $filter_phrase, $where_arg) = parse_filtering('"MarkerMapId"',
                                                    '"markermapposition"',
                                                    $filtering_csv,
                                                    $field_list,
                                                    $validation_func_lookup,
                                                    $field_name2table_name);

  $self->logger->debug("Filter phrase: $filter_phrase");

  if ($filter_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $filter_msg}]};

    return $data_for_postrun_href;
  }

  my $filter_where_phrase = '';

  if (length($filter_phrase) > 0) {

    $filter_where_phrase = " AND $filter_phrase ";
  }

  my $filtering_exp = qq| WHERE "MarkerMapId"=$markermap_id $filter_where_phrase |;

  my $pagination_aref    = [];

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
      $nb_pages, $limit_clause, $rcount_time) = get_paged_filter($dbh,
                                                                 $nb_per_page,
                                                                 $page,
                                                                 '"markermapposition"',
                                                                 '"MarkerMapId"',
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

  my $paged_limit_clause = $limit_clause;

  my ($sort_err, $sort_msg, $sort_sql) = parse_sorting($sorting, $field_list, '"markermapposition"');

  if ($sort_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sort_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT "markermapposition".*, ';
  $sql   .= '"AnalysisGroupId", "dataset"."DataSetId", "analysisgroupmarker"."MarkerName" AS "AnalysisGroupMarkerName", ';
  $sql   .= '"MarkerSequence", "MarkerDescription", "MarkerExtRef" ';
  $sql   .= 'FROM "markermapposition" LEFT JOIN "analysisgroupmarker" ON ';
  $sql   .= '"markermapposition"."AnalysisGroupMarkerId" = "analysisgroupmarker"."AnalysisGroupMarkerId" ';
  $sql   .= 'LEFT JOIN "dataset" ON "analysisgroupmarker"."DataSetId" = "dataset"."DataSetId" ';
  $sql   .= $filtering_exp;

  if (length($sort_sql) > 0) {

    $sql .= " ORDER BY $sort_sql ";
  }
  else {

    $sql .= ' ORDER BY "markermapposition"."MarkerMapPositionId" ASC';
  }

  $sql .= " $paged_limit_clause ";

  $self->logger->debug("SQL: $sql");
  $self->logger->debug("Where arg: " . join(',', @{$where_arg}));

  my $data_start_time = [gettimeofday()];

  # where_arg here in the list function because of the filtering
  my ($read_mappos_err, $read_mappos_msg, $mappos_data) = read_data($dbh, $sql, $where_arg);

  my $data_elapsed = tv_interval($data_start_time);

  if ($read_mappos_err) {

    $self->logger->debug($read_mappos_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'MarkerMapPosition'   => $mappos_data,
                                           'Pagination'          => $pagination_aref,
                                           'RecordMeta'          => [{'TagName' => 'MarkerMapPosition'}],
  };

  return $data_for_postrun_href;
}

sub list_extract_marker_data_advanced_runmode {

=pod list_extract_marker_data_HELP_START
{
"OperationName": "List marker data for extract",
"Description": "List marker data  for extract across all datasets that the user has read permission.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><MarkerData DataSetId='9' E_1125='0' CallrateSNP='1' MarkerName='1033160|F|0--35:C&gt;T' MarkerSequence='TGCAGTGTACAGTAGCCTACAAGTGGGAGTCCCTACGCGTCTGATACAGCTGCAAACACTGCTATGCGG' /><MarkerData DataSetId='9' MarkerName='1033160|F|0-35:C&gt;T-35:C&gt;T' MarkerSequence='TGCAGTGTACAGTAGCCTACAAGTGGGAGTCCCTACGCGTCTGATACAGCTGCAAACACTGCTATGCGG' CallrateSNP='1' E_1125='1' /><MarkerData E_1125='0' CallrateSNP='1' MarkerName='1034802|F|0--21:T&gt;C' MarkerSequence='TGCAGAGGGCAAGGCTATGATTTGCCAATCAGCAGATTTCTTGATTAAATATGCTGTGGAAACAAGACC' DataSetId='9' /><MarkerData CallrateSNP='1' MarkerSequence='TGCAGAGGGCAAGGCTATGATTTGCCAATCAGCAGATTTCTTGATTAAATATGCTGTGGAAACAAGACC' MarkerName='1034802|F|0-21:T&gt;C-21:T&gt;C' E_1125='1' DataSetId='9' /><MarkerData DataSetId='9' E_1125='0' CallrateSNP='0.98999999999999999' MarkerName='1020912|F|0--59:T&gt;C' MarkerSequence='TGCAGCCCACATGAGAGAAGACACAGGATGAGCAATGGACAGGTTCCACTTAAAACAAGTTTGTCCGAG' /><MarkerData DataSetId='9' MarkerSequence='TGCAGCCCACATGAGAGAAGACACAGGATGAGCAATGGACAGGTTCCACTTAAAACAAGTTTGTCCGAG' MarkerName='1020912|F|0-59:T&gt;C-59:T&gt;C' CallrateSNP='0.98999999999999999' E_1125='1' /><MarkerData DataSetId='9' E_1125='1' CallrateSNP='0.98999999999999999' MarkerName='1034428|F|0--35:A&gt;T' MarkerSequence='TGCAGGGCGAATCAATACACCCAGCTGTCATGCAAACACATAATGGCACCCAGAAAGCCATCAATGCAC' /><MarkerData MarkerName='1034428|F|0-35:A&gt;T-35:A&gt;T' MarkerSequence='TGCAGGGCGAATCAATACACCCAGCTGTCATGCAAACACATAATGGCACCCAGAAAGCCATCAATGCAC' CallrateSNP='0.98999999999999999' E_1125='0' DataSetId='9' /><MarkerData DataSetId='9' E_1125='0' MarkerName='1043194|F|0--59:C&gt;G' MarkerSequence='TGCAGTGTCGTCTCAGTCAGTCTTACTCGTTAGCAACTTAACATGACTGCCATTTTTCTCTGAATAAAA' CallrateSNP='0.98999999999999999' /><MarkerData DataSetId='9' E_1125='1' MarkerSequence='TGCAGTGTCGTCTCAGTCAGTCTTACTCGTTAGCAACTTAACATGACTGCCATTTTTCTCTGAATAAAA' MarkerName='1043194|F|0-59:C&gt;G-59:C&gt;G' CallrateSNP='0.98999999999999999' /><Extract GenotypeId='' WellPosition='A5' ExtractId='1125' ItemGroupId='1080' PlateName='' /><MetaDataField FactorCaption='CallrateSNP' FactorId='6' FactorName='CallrateSNP' FactorDescription='Created automatically by import/makerdata/csv for CallrateSNP' /><DataSet AnalysisGroupId='9' ParentDataSetId='' Description='' DataSetTypeName='DataSetType - 94884285523' DataSetType='487' AnalysisGroupName='Analsysigroup_37942843727' DataSetId='9' /><RecordMeta TagName='MarkerData' /><Blocksination Block='1' NumOfBlocks='1' NumPerBlock='10' NumOfExtracts='1' /><Pagination NumOfRecords='376' Page='1' NumOfPages='38' NumPerPage='10' /><StatInfo ServerElapsedTime='0.093' Unit='second' /></DATA>",
"SuccessMessageJSON": "{'Blocksination' : [{'NumOfBlocks' : 1,'Block' : '1','NumPerBlock' : '10','NumOfExtracts' : '1'}],'RecordMeta' : [{'TagName' : 'MarkerData'}],'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.079'}],'Pagination' : [{'NumPerPage' : '10','Page' : '1','NumOfRecords' : '376','NumOfPages' : 38}],'Extract' : [{'PlateName' : null,'ItemGroupId' : '1080','ExtractId' : '1125','WellPosition' : 'A5','GenotypeId' : null}],'MarkerData' : [{'DataSetId' : '9','E_1125' : '0','MarkerName' : '1033160|F|0--35:C>T','MarkerSequence' : 'TGCAGTGTACAGTAGCCTACAAGTGGGAGTCCCTACGCGTCTGATACAGCTGCAAACACTGCTATGCGG','CallrateSNP' : '1'},{'DataSetId' : '9','E_1125' : '1','MarkerName' : '1033160|F|0-35:C>T-35:C>T','MarkerSequence' : 'TGCAGTGTACAGTAGCCTACAAGTGGGAGTCCCTACGCGTCTGATACAGCTGCAAACACTGCTATGCGG','CallrateSNP' : '1'},{'DataSetId' : '9','MarkerSequence' : 'TGCAGAGGGCAAGGCTATGATTTGCCAATCAGCAGATTTCTTGATTAAATATGCTGTGGAAACAAGACC','MarkerName' : '1034802|F|0--21:T>C','CallrateSNP' : '1','E_1125' : '0'},{'CallrateSNP' : '1','MarkerName' : '1034802|F|0-21:T>C-21:T>C','MarkerSequence' : 'TGCAGAGGGCAAGGCTATGATTTGCCAATCAGCAGATTTCTTGATTAAATATGCTGTGGAAACAAGACC','E_1125' : '1','DataSetId' : '9'},{'DataSetId' : '9','E_1125' : '0','CallrateSNP' : '0.98999999999999999','MarkerName' : '1020912|F|0--59:T>C','MarkerSequence' : 'TGCAGCCCACATGAGAGAAGACACAGGATGAGCAATGGACAGGTTCCACTTAAAACAAGTTTGTCCGAG'},{'CallrateSNP' : '0.98999999999999999','MarkerName' : '1020912|F|0-59:T>C-59:T>C','MarkerSequence' : 'TGCAGCCCACATGAGAGAAGACACAGGATGAGCAATGGACAGGTTCCACTTAAAACAAGTTTGTCCGAG','E_1125' : '1','DataSetId' : '9'},{'CallrateSNP' : '0.98999999999999999','MarkerName' : '1034428|F|0--35:A>T','MarkerSequence' : 'TGCAGGGCGAATCAATACACCCAGCTGTCATGCAAACACATAATGGCACCCAGAAAGCCATCAATGCAC','E_1125' : '1','DataSetId' : '9'},{'CallrateSNP' : '0.98999999999999999','MarkerSequence' : 'TGCAGGGCGAATCAATACACCCAGCTGTCATGCAAACACATAATGGCACCCAGAAAGCCATCAATGCAC','MarkerName' : '1034428|F|0-35:A>T-35:A>T','E_1125' : '0','DataSetId' : '9'},{'MarkerName' : '1043194|F|0--59:C>G','MarkerSequence' : 'TGCAGTGTCGTCTCAGTCAGTCTTACTCGTTAGCAACTTAACATGACTGCCATTTTTCTCTGAATAAAA','CallrateSNP' : '0.98999999999999999','E_1125' : '0','DataSetId' : '9'},{'DataSetId' : '9','CallrateSNP' : '0.98999999999999999','MarkerSequence' : 'TGCAGTGTCGTCTCAGTCAGTCTTACTCGTTAGCAACTTAACATGACTGCCATTTTTCTCTGAATAAAA','MarkerName' : '1043194|F|0-59:C>G-59:C>G','E_1125' : '1'}],'DataSet' : [{'AnalysisGroupId' : '9','DataSetTypeName' : 'DataSetType - 94884285523','Description' : '','ParentDataSetId' : null,'DataSetId' : '9','DataSetType' : '487','AnalysisGroupName' : 'Analsysigroup_37942843727'}],'MetaDataField' : [{'FactorCaption' : 'CallrateSNP','FactorName' : 'CallrateSNP','FactorDescription' : 'Created automatically by import/makerdata/csv for CallrateSNP','FactorId' : '6'}]}",
"ErrorMessageXML": [{"MissingParameter": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error DataSetType='DataSetType is missing.' /><StatInfo ServerElapsedTime='0.003' Unit='second' /></DATA>"}],
"ErrorMessageJSON": [{"MissingParameter": "{'Error' : [{'DataSetType' : 'DataSetType is missing.'}],'StatInfo' : [{'ServerElapsedTime' : '0.002','Unit' : 'second'}]}"}],
"HTTPParameter": [{"Name": "ExtractFiltering", "Description": "Extract filtering parameter. It an ampersand (&) separated value consisting of DAL filtering express on extract table", "Required": 1}, {"Name": "MarkerFiltering", "Description": "Marker filtering parameter. It is an ampersand (&) separated value consisting of filtering expression. Each filtering expression is composed of a marker meta data field name, a filtering operator and the filtering value.", "Required": 1}, {"Name": "MarkerMetaFieldList", "Description": "Comma separated value of marker meta data field names", "Required": "1"}, {"Name": "DataSetType", "Description": "Single value for the marker dataset type", "Required": 1}],
"URLParameter": [{"ParameterName": "nperpage", "Description": "Number of records in a page for pagination"}, {"ParameterName": "num", "Description": "The page number of the pagination"}, {"ParameterName": "nperblock", "Description": "Number of extracts in the block"}, {"ParameterName": "bnum", "Description": "The page number of the block of extracts"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self   = shift;
  my $query  = $self->query();

  my $extract_filtering_csv      = $query->param('ExtractFiltering');
  my $marker_filtering_csv       = $query->param('MarkerFiltering');
  my $marker_meta_field_list_csv = $query->param('MarkerMetaFieldList');
  my $dataset_type               = $query->param('DataSetType');

  my $data_for_postrun_href = {};

  my $sorting_csv = '';

  if (defined $query->param('Sorting')) {

    $sorting_csv = $query->param('Sorting');
  }

  $self->logger->debug("Sorting CSV: $sorting_csv");

  my $nb_extract_per_block = $self->param('nperblock');
  my $block                = $self->param('bnum');

  my ($filtering_missing_err, $filtering_missing_href) = check_missing_href( { 'ExtractFiltering'    => $extract_filtering_csv,
                                                                               'MarkerFiltering'     => $marker_filtering_csv,
                                                                               'MarkerMetaFieldList' => $marker_meta_field_list_csv,
                                                                               'DataSetType'         => $dataset_type
                                                                             });

  if ($filtering_missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$filtering_missing_href]};

    return $data_for_postrun_href;
  }

  my ($int_err, $int_err_msg) = check_integer_value( {'nperblock' => $nb_extract_per_block,
                                                      'num'       => $block
                                                       });

  if ($int_err) {

    $int_err_msg .= ' not integer.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $int_err_msg}]};

    return $data_for_postrun_href;
  }

  my $nb_per_page = $self->param('nperpage');
  my $page        = $self->param('num');

  ($int_err, $int_err_msg) = check_integer_value( {'nperpage' => $nb_per_page,
                                                   'num'      => $page
                                                  });

  if ($int_err) {

    $int_err_msg .= ' not integer.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $int_err_msg}]};

    return $data_for_postrun_href;
  }

  #get database handles
  my $dbh_k = connect_kdb_read();
  my $dbh_m = connect_mdb_read();

  if (!type_existence($dbh_k, 'markerdataset', $dataset_type)) {

    my $err_msg = "DataSetType ($dataset_type): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'DataSetType' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT DISTINCT "FactorId", "FieldName" FROM "datasetmarkermeta"';

  my ($r_factor_err, $r_factor_msg, $factor_data) = read_data($dbh_m, $sql, []);

  if ($r_factor_err) {

    $self->logger->debug("Read factor failed: $r_factor_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $factor_name2id_href = {};

  foreach my $factor_rec (@{$factor_data}) {

    my $factor_name = $factor_rec->{'FieldName'};
    my $factor_id   = $factor_rec->{'FactorId'};

    $factor_name2id_href->{$factor_name} = $factor_id;
  }

  $factor_name2id_href->{'MarkerName'}     = -1;
  $factor_name2id_href->{'MarkerSequence'} = -1;

  my @marker_meta_field_list = split(',', $marker_meta_field_list_csv);

  my @invalid_meta_field_list;

  my @marker_meta_field_id_list;
  my $marker_meta_id2name_href = {};

  foreach my $marker_meta_field (@marker_meta_field_list) {

    if ( !(defined $factor_name2id_href->{$marker_meta_field}) ) {

      push(@invalid_meta_field_list, $marker_meta_field);
    }
    else {

      my $factor_id = $factor_name2id_href->{$marker_meta_field};
      $marker_meta_id2name_href->{$factor_id} = $marker_meta_field;
      push(@marker_meta_field_id_list, $factor_id);
    }
  }

  if (scalar(@invalid_meta_field_list) > 0) {

    my $invalid_meta_field_err_msg = "MarkerMetaField (" . join(',', @invalid_meta_field_list) . "): not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $invalid_meta_field_err_msg}]};

    return $data_for_postrun_href;
  }

  if (scalar(@marker_meta_field_id_list) > 0) {

    my $marker_meta_field_id_csv = join(',', @marker_meta_field_id_list);
    my $nb_meta_field            = scalar(@marker_meta_field_id_list);

    $sql  = qq|SELECT "DataSetId" FROM "datasetmarkermeta" WHERE "FactorId" IN ( $marker_meta_field_id_csv ) |;
    $sql .= qq|GROUP BY "DataSetId" HAVING COUNT("DataSetId")= $nb_meta_field|;
  }
  else {

    $sql = 'SELECT DISTINCT "DataSetId" FROM "datasetmarkermeta"';
  }

  my ($r_ds_meta_err, $r_ds_meta_msg, $ds_meta_data) = read_data($dbh_m, $sql, []);

  if ($r_ds_meta_err) {

    $self->logger->debug("Read DataSetId based on meta data field failed: $r_ds_meta_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$ds_meta_data}) == 0) {

    my $err_msg = "No marker dataset found for selected marker meta fields";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my @meta_field_ds_id_list;

  foreach my $ds_rec (@{$ds_meta_data}) {

    push(@meta_field_ds_id_list, $ds_rec->{'DataSetId'});
  }

  my $meta_field_ds_filtering = '';

  if (scalar(@meta_field_ds_id_list) > 0) {

    $meta_field_ds_filtering = qq|AND "DataSetId" IN (| . join(',', @meta_field_ds_id_list) . qq|)|;
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $perm_str = permission_phrase($group_id, 2, 'analysisgroup');

  $sql  = qq|SELECT "DataSetId" FROM "dataset" |;
  $sql .= qq|LEFT JOIN "analysisgroup" ON "dataset"."AnalysisGroupId" = "analysisgroup"."AnalysisGroupId" |;
  $sql .= qq|WHERE ( (($perm_str) & $READ_PERM) = $READ_PERM ) AND "dataset"."DataSetType" = $dataset_type |;
  $sql .= qq|$meta_field_ds_filtering|;

  $self->logger->debug("SQL: $sql");

  ($r_ds_meta_err, $r_ds_meta_msg, $ds_meta_data) = read_data($dbh_m, $sql, []);

  if ($r_ds_meta_err) {

    $self->logger->debug("Read DataSetId based on meta data field and permission failed: $r_ds_meta_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$ds_meta_data}) == 0) {

    my $err_msg = "No marker dataset found accessible for selected marker meta fields";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my @final_meta_field_ds_id_list;

  foreach my $ds_rec (@{$ds_meta_data}) {

    push(@final_meta_field_ds_id_list, $ds_rec->{'DataSetId'});
  }

  $self->logger->debug("List of dataset Id (markermeta): " . join(',', @final_meta_field_ds_id_list));

  my $extract_field_list = [];

  my ($ex_sfield_err, $ex_sfield_msg, $extract_sfield_data, $extract_pkey_data) = get_static_field($dbh_m, 'extract');

  if ($ex_sfield_err) {

    $self->logger->debug("Get static field failed: $ex_sfield_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  for my $sfield_rec (@{$extract_sfield_data}) {

    push(@{$extract_field_list}, $sfield_rec->{'Name'});
  }

  for my $pkey_field (@{$extract_pkey_data}) {

    push(@{$extract_field_list}, $pkey_field);
  }

  my ($ex_filter_err, $ex_filter_msg, $extract_filter_phrase, $extract_where_arg) = parse_filtering('"ExtractId"',
                                                                                                    '"extract"',
                                                                                                    $extract_filtering_csv,
                                                                                                    $extract_field_list
                                                                                                   );

  $self->logger->debug("Extract Filter phrase: $extract_filter_phrase");

  if ($ex_filter_err) {

    $self->logger->debug("Parsing extract filtering failed: $ex_filter_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $ex_filter_msg}]};

    return $data_for_postrun_href;
  }

  my $extract_filtering_exp = qq|WHERE ( (($perm_str) & $READ_PERM) = $READ_PERM ) AND "dataset"."DataSetType" = $dataset_type |;
  $extract_filtering_exp   .= qq|AND "dataset"."DataSetId" IN (| . join(',', @final_meta_field_ds_id_list) . qq|) |;
  if (length($extract_filter_phrase) > 0) {

    $extract_filtering_exp = " AND $extract_filter_phrase ";
  }

  # Do blocination

  my $count_sql = qq|SELECT COUNT(DISTINCT "extract"."ExtractId") |;
  $count_sql   .= qq|FROM "dataset" LEFT JOIN "analysisgroup" ON "dataset"."AnalysisGroupId" = "analysisgroup"."AnalysisGroupId" |;
  $count_sql   .= qq|LEFT JOIN "datasetextract" ON "dataset"."DataSetId" = "datasetextract"."DataSetId" |;
  $count_sql   .= qq|LEFT JOIN "analgroupextract" ON "datasetextract"."AnalGroupExtractId" = "analgroupextract"."AnalGroupExtractId" |;
  $count_sql   .= qq|LEFT JOIN "extract" ON "analgroupextract"."ExtractId" = "extract"."ExtractId" |;
  $count_sql   .= qq| $extract_filtering_exp |;

  my ($pg_extract_err, $pg_extract_msg, $nb_extract,
      $nb_blocks, $extract_limit_clause, $extract_count_time) = get_paged_filter_sql($dbh_m,
                                                                                     $nb_extract_per_block,
                                                                                     $block,
                                                                                     $count_sql,
                                                                                     $extract_where_arg);

  if ($pg_extract_err == 1) {

    $self->logger->debug("Paging extracts failed: $pg_extract_msg");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  if ($pg_extract_err == 2) {

    my $err_msg = "Block ($block): out of range";
    $self->logger->debug("Extract limit clause: $extract_limit_clause");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $blocination_aref = [{'NumOfExtracts' => $nb_extract,
                           'NumOfBlocks'   => $nb_blocks,
                           'Block'         => $block,
                           'NumPerBlock'   => $nb_extract_per_block,
                          }];

  $sql  = qq|SELECT "extract"."ExtractId", COUNT("extract"."ExtractId") |;
  $sql .= qq|FROM "dataset" INNER JOIN "analysisgroup" ON "dataset"."AnalysisGroupId" = "analysisgroup"."AnalysisGroupId" |;
  $sql .= qq|INNER JOIN "datasetextract" ON "dataset"."DataSetId" = "datasetextract"."DataSetId" |;
  $sql .= qq|INNER JOIN "analgroupextract" ON "datasetextract"."AnalGroupExtractId" = "analgroupextract"."AnalGroupExtractId" |;
  $sql .= qq|INNER JOIN "extract" ON "analgroupextract"."ExtractId" = "extract"."ExtractId" |;
  $sql .= qq| $extract_filtering_exp |;
  $sql .= qq|GROUP BY "extract"."ExtractId" |;
  $sql .= qq|ORDER BY "extract"."ExtractId" DESC |;
  $sql .= qq|$extract_limit_clause|;

  $self->logger->debug("SQL: $sql");

  my ($r_ext_err, $r_ext_msg, $extract_data) = read_data($dbh_m, $sql, $extract_where_arg);

  if ($r_ext_err) {

    $self->logger->debug("Read extract id based on extract filtering failed: $r_ext_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$extract_data}) == 0) {

    my $err_msg = "No extract found";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my @final_extract_field_list;
  my @final_extract_id_list;

  foreach my $extract_rec (@{$extract_data}) {

    if ( defined $extract_rec->{'ExtractId'} ) {

      push(@final_extract_field_list, q|E_| . $extract_rec->{'ExtractId'});
      push(@final_extract_id_list, $extract_rec->{'ExtractId'});
    }
    else {

      $self->logger->debug("ExtractId not defined");
    }
  }

  $self->logger->debug("Extract Field: " . join(',', @final_extract_field_list));

  $sql  = qq|SELECT "dataset"."DataSetId" |;
  $sql .= qq|FROM "dataset" INNER JOIN "analysisgroup" ON "dataset"."AnalysisGroupId" = "analysisgroup"."AnalysisGroupId" |;
  $sql .= qq|INNER JOIN "datasetextract" ON "dataset"."DataSetId" = "datasetextract"."DataSetId" |;
  $sql .= qq|INNER JOIN "analgroupextract" ON "datasetextract"."AnalGroupExtractId" = "analgroupextract"."AnalGroupExtractId" |;
  $sql .= qq|INNER JOIN "extract" ON "analgroupextract"."ExtractId" = "extract"."ExtractId" |;
  $sql .= qq| $extract_filtering_exp |;
  $sql .= qq|ORDER BY "extract"."ExtractId" DESC |;
  $sql .= qq|$extract_limit_clause|;

  $self->logger->debug("SQL: $sql");

  my ($r_ext_ds_err, $r_ext_ds_msg, $ext_dataset_id_data) = read_data($dbh_m, $sql, $extract_where_arg);

  if ($r_ext_ds_err) {

    $self->logger->debug("Read dataset id based on extract filtering failed: $r_ext_ds_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$ext_dataset_id_data}) == 0) {

    my $err_msg = "No marker dataset found for selected extracts";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $unique_ds_id_href = {};

  foreach my $ds_rec (@{$ext_dataset_id_data}) {

    $unique_ds_id_href->{$ds_rec->{"DataSetId"}} = 1;
  }

  my @final_ds_id_list = keys(%{$unique_ds_id_href});

  $self->logger->debug("List of dataset Id (extract filtering): " . join(',', @final_ds_id_list));

  if (scalar(@final_ds_id_list) == 0) {

    my $err_msg = "No marker dataset found for selected extracts and selected marker meta data fields";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql  = 'SELECT "extract"."ExtractId", "plate"."PlateName", ';
  $sql .= '"extract"."ItemGroupId", "extract"."GenotypeId", ';
  $sql .= 'CONCAT("extract"."WellRow", "extract"."WellCol") AS "WellPosition" ';
  $sql .= 'FROM "extract" LEFT JOIN "plate" ON "extract"."PlateId" = "plate"."PlateId" ';
  $sql .= 'WHERE "ExtractId" IN (' . join(',', @final_extract_id_list) . ')';

  my ($r_extract_err, $r_extract_msg, $final_extract_data) = read_data($dbh_m, $sql, []);

  if ($r_extract_err) {

    $self->logger->debug("Read final extract info failed: $r_extract_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  $sql  = qq|SELECT "DataSetId", "MarkerNameFieldName", "MarkerSequenceFieldName" |;
  $sql .= qq|FROM "dataset" |;
  $sql .= qq|WHERE "DataSetId" IN (| . join(',', @final_ds_id_list) . qq|)|;

  my $ds_id2mrk_name_seq_field_name_lookup = $dbh_m->selectall_hashref($sql, 'DataSetId');

  if ($dbh_m->err()) {

    $self->logger->debug("Get MarkerNameFieldName and MarkerSequenceFieldName failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  $sql  = qq|SELECT "DataSetId", "FactorId", "FieldName" |;
  $sql .= qq|FROM "datasetmarkermeta" |;
  $sql .= qq|WHERE "DataSetId" IN (| . join(',', @final_ds_id_list) . qq|)|;

  my ($r_fn_err, $r_fn_msg, $fieldname_data) = read_data($dbh_m, $sql, []);

  if ($r_fn_err) {

    $self->logger->debug("Read fieldname failed: $r_fn_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $ds_id_factor_id2field_name_href = {};

  foreach my $fn_rec (@{$fieldname_data}) {

    my $ds_id      = $fn_rec->{'DataSetId'};
    my $factor_id  = $fn_rec->{'FactorId'};
    my $field_name = $fn_rec->{'FieldName'};

    $ds_id_factor_id2field_name_href->{"(${ds_id},${factor_id})"} = $field_name;
  }

  $sql  = 'SELECT FactorId, FactorName, FactorCaption, FactorDescription ';
  $sql .= 'FROM factor WHERE FactorId IN (' . join(',', @marker_meta_field_id_list) . ')';

  $self->logger->debug("SQL: $sql");

  my ($r_finfo_err, $r_finfo_msg, $factor_info_aref) = read_data($dbh_k, $sql, []);

  if ($r_finfo_err) {

    $self->logger->debug("Read factor info failed: $r_finfo_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $dataset_type_name = read_cell_value($dbh_k, 'generaltype', 'TypeName', 'TypeId', $dataset_type);

  $sql  = qq|SELECT "DataSetId", "dataset"."AnalysisGroupId", "DataSetType", |;
  $sql .= qq|'$dataset_type_name' AS "DataSetTypeName", "Description", "ParentDataSetId", |;
  $sql .= qq|"AnalysisGroupName" |;
  $sql .= qq|FROM "dataset" LEFT JOIN "analysisgroup" ON "dataset"."AnalysisGroupId" = "analysisgroup"."AnalysisGroupId" |;
  $sql .= qq|WHERE "DataSetId" IN (| . join(',', @final_ds_id_list) . qq|)|;

  my ($r_ds_info_err, $r_ds_info_msg, $ds_info_aref) = read_data($dbh_m, $sql, []);

  if ($r_ds_info_err) {

    $self->logger->debug("Read dataset info failed: $r_ds_info_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $dataset_sql_n_arg_aref = [];

  my $final_field_list_aref  = [];

  foreach my $ds_id (sort(@final_ds_id_list)) {

    my ($ds_sfield_err, $ds_sfield_msg, $ds_sfield_data, $ds_pkey_data) = get_static_field($dbh_m, "markerdata${ds_id}");

    if ($ds_sfield_err) {

      $self->logger->debug("Get static field for markerdata${ds_id} failed: $ds_sfield_msg");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

      return $data_for_postrun_href;
    }

    my $ds_field_list = [];

    for my $sfield_rec (@{$ds_sfield_data}) {

      push(@{$ds_field_list}, $sfield_rec->{'Name'});
    }

    for my $pkey_field (@{$ds_pkey_data}) {

      push(@{$ds_field_list}, $pkey_field);
    }

    my $mrk_name_field_name = $ds_id2mrk_name_seq_field_name_lookup->{$ds_id}->{"MarkerNameFieldName"};
    my $mrk_seq_field_name  = $ds_id2mrk_name_seq_field_name_lookup->{$ds_id}->{"MarkerSequenceFieldName"};

    $self->logger->debug("DS: $ds_id - MarkerNameFieldName: $mrk_name_field_name");
    $self->logger->debug("DS: $ds_id - MarkerSequenceFieldName: $mrk_seq_field_name");

    my ($mrk_filter_err, $mrk_filter_msg, $mrk_filter_phrase, $mrk_where_arg) = parse_filtering(qq|"$mrk_name_field_name"|,
                                                                                                qq|"markerdata${ds_id}"|,
                                                                                                $marker_filtering_csv,
                                                                                                $ds_field_list
                                                                                               );

    $self->logger->debug("DS: $ds_id - Marker Filter phrase: $mrk_filter_phrase");

    if ($mrk_filter_err) {

      $self->logger->debug("Parsing marker filtering failed - ds: $ds_id : $mrk_filter_msg");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => "DS: $ds_id - $mrk_filter_msg"}]};

      return $data_for_postrun_href;
    }

    my $ds_sql = qq|SELECT "$mrk_name_field_name" AS "MarkerName", |;
    $ds_sql   .= qq|"$mrk_seq_field_name" AS "MarkerSequence", $ds_id AS "DataSetId", |;

    my $new_field_list_aref = [q|"MarkerName"|, q|"MarkerSequence"|, q|"DataSetId"|];

    my @ds_sql_field_list;

    foreach my $meta_field_id (@marker_meta_field_id_list) {

      my $ds_field_name   = $ds_id_factor_id2field_name_href->{"(${ds_id},${meta_field_id})"};
      my $user_field_name = $marker_meta_id2name_href->{$meta_field_id};

      push(@ds_sql_field_list, qq|"$ds_field_name" AS "$user_field_name"|);
      push(@{$new_field_list_aref}, qq|"$user_field_name"|);
    }

    foreach my $extract_fieldname (@final_extract_field_list) {

      push(@ds_sql_field_list, qq|"$extract_fieldname"|);
      push(@{$new_field_list_aref}, qq|"$extract_fieldname"|);
    }

    my $mrk_filter_exp = '';
    if (length($mrk_filter_phrase) > 0) {

      $mrk_filter_exp = "WHERE $mrk_filter_phrase";
    }

    $final_field_list_aref = $new_field_list_aref;

    $ds_sql  .= join(',', @ds_sql_field_list);
    $ds_sql  .= qq| FROM "markerdata${ds_id}" |;
    $ds_sql  .= $mrk_filter_exp;

    $self->logger->debug("DS: $ds_id - SQL: $ds_sql");
    $self->logger->debug("DS: $ds_id - ARG: " . join(',', @{$mrk_where_arg}));

    my $ds_sql_href = {'SQL' => $ds_sql,
                       'ARG' => $mrk_where_arg};

    push(@{$dataset_sql_n_arg_aref}, $ds_sql_href);
  }

  my $data4md5sum = '';
  foreach my $ds_sql_href (@{$dataset_sql_n_arg_aref}) {

    $data4md5sum .= $ds_sql_href->{'SQL'};
    $data4md5sum .= join('___', @{$ds_sql_href->{'ARG'}});
    $self->logger->debug("DS SQL: " . $ds_sql_href->{'SQL'});
  }

  $self->logger->debug("DATA 4 TMP TABLE NAME MD5SUM: $data4md5sum");

  my $tmp_table_name = "TMP_MRK_DATA_" . md5_hex($data4md5sum);

  $self->logger->debug("TMP MARKER DATA TABLE NAME: $tmp_table_name");

  if ( table_existence($dbh_m, $tmp_table_name ) ) {

    $self->logger->debug("Table $tmp_table_name already exists");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $first_sql      = $dataset_sql_n_arg_aref->[0]->{'SQL'};
  my $first_arg_aref = $dataset_sql_n_arg_aref->[0]->{'ARG'};

  my $create_tmp_sql = qq|CREATE LOCAL TEMPORARY TABLE "$tmp_table_name" |;
  $create_tmp_sql   .= qq|AS ($first_sql) WITH NO DATA ON COMMIT PRESERVE ROWS|;

  $self->logger->debug("CREATE SQL: $create_tmp_sql");

  my ($create_tbl_err, $create_tbl_msg) = execute_sql($dbh_m, $create_tmp_sql, $first_arg_aref);

  if ($create_tbl_err) {

    $self->logger->debug("CREATE TMP TABLE: $tmp_table_name failed: $create_tbl_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("CREATE SQL: $create_tmp_sql");

  foreach my $ds_sql_href (@{$dataset_sql_n_arg_aref}) {

    my $select_sql = $ds_sql_href->{'SQL'};
    my $arg_aref   = $ds_sql_href->{'ARG'};

    $sql  = qq|INSERT INTO "$tmp_table_name"(| . join(',', @{$final_field_list_aref}) . qq|) |;
    $sql .= $select_sql;

    $self->logger->debug("COPY SQL: $sql");

    my ($copy_mrk_data_err, $copy_mrk_data_msg) = execute_sql($dbh_m, $sql, $arg_aref);

    if ($copy_mrk_data_err) {

      $self->logger->debug("COPY MRK DATA failed: $copy_mrk_data_msg");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

      return $data_for_postrun_href;
    }
  }

  my ($sort_err, $sort_msg, $sort_sql) = parse_sorting($sorting_csv, $final_field_list_aref, qq|"$tmp_table_name"|);

  if ($sort_err) {

    $self->logger->debug("Parse sorting failed: $sort_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $sorting_exp = '';

  if (length($sort_sql) > 0) {

    $sorting_exp = "ORDER BY $sort_sql";
  }

  $self->logger->debug("Sorting SQL: $sort_sql");

  $sql = qq|SELECT COUNT(*) FROM "$tmp_table_name"|;

  my ($r_count_err, $count_mrk) = read_cell($dbh_m, $sql, []);

  if ($r_count_err) {

    $self->logger->debug("Count marker failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("Number of markers: $count_mrk");

  my ($final_mrk_filter_err, $final_mrk_filter_msg,
      $final_mrk_filter_phrase, $final_mrk_where_arg) = parse_filtering(qq|"MarkerName"|,
                                                                        qq|"$tmp_table_name"|,
                                                                        $marker_filtering_csv,
                                                                        $final_field_list_aref
                                                                       );

  if ($final_mrk_filter_err) {

    $self->logger->debug("Parsing filtering failed: $final_mrk_filter_msg");

    my $err_msg = $final_mrk_filter_msg;

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $final_mrk_filter_exp = '';

  if (length($final_mrk_filter_phrase) > 0) {

    $final_mrk_filter_exp = "WHERE $final_mrk_filter_phrase";
  }

  my ($pg_id_err, $pg_id_msg, $nb_records,
      $nb_pages, $limit_clause, $rcount_time) = get_paged_filter($dbh_m,
                                                                 $nb_per_page,
                                                                 $page,
                                                                 qq|"$tmp_table_name"|,
                                                                 qq|"MarkerName"|,
                                                                 $final_mrk_filter_exp,
                                                                 $final_mrk_where_arg
                                                                );

  if ($pg_id_err == 1) {

    $self->logger->debug($pg_id_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  if ($pg_id_err == 2) {

    my $err_msg = "Page ($page): out of range";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $pagination_aref = [{'NumOfRecords' => $nb_records,
                          'NumOfPages'   => $nb_pages,
                          'Page'         => $page,
                          'NumPerPage'   => $nb_per_page,
                         }];

  $sql  = qq|SELECT * FROM "$tmp_table_name" |;
  $sql .= qq|$final_mrk_filter_exp |;
  $sql .= qq|$sorting_exp |;
  $sql .= qq|$limit_clause|;

  $self->logger->debug("FINAL SQL: $sql");

  my ($read_mrk_data_err, $read_mrk_data_msg, $mrk_data) = read_data($dbh_m, $sql, $final_mrk_where_arg);

  if ($read_mrk_data_err) {

    $self->logger->debug($read_mrk_data_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $dbh_k->disconnect();
  $dbh_m->disconnect();

  $data_for_postrun_href->{'Error'} = 0;
  $data_for_postrun_href->{'Data'}  = {'MarkerData'      => $mrk_data,
                                       'Extract'         => $final_extract_data,
                                       'MetaDataField'   => $factor_info_aref,
                                       'DataSet'         => $ds_info_aref,
                                       'Blocksination'   => $blocination_aref,
                                       'Pagination'      => $pagination_aref,
                                       'RecordMeta'      => [{'TagName' => 'MarkerData'}],
  };

  return $data_for_postrun_href;
}

sub append_markerdata_csv_runmode {

=pod append_markerdata_csv_HELP_START
{
"OperationName": "Append markerdata into an existing dataset",
"Description": "Append markerdata into an existing dataset from a CSV file. If more than 10 of the top 100 lines in the upload CSV already exist, it will stop and return an error without appending the data into the dataset",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><StatInfo Unit='second' ServerElapsedTime='0.665' /><Info RunTime='0.485275' Message='Appending marker data into DataSet (9) is successful. Number of markers: 8382. Number of extracts: 6. Number of meta fields: 18' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Appending marker data into DataSet (9) is successful. Number of markers: 8382. Number of extracts: 6. Number of meta fields: 18','RunTime' : '4.023782'}],'StatInfo' : [{'ServerElapsedTime' : '4.182','Unit' : 'second'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><StatInfo Unit='second' ServerElapsedTime='0.166' /><Error Message='DataSet (10): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.211'}],'Error' : [{'Message' : 'DataSet (10): not found.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "CSV",
"UploadFileParameterName": "uploadfile",
"HTTPParameter": [{"Required": 1, "Name": "HeaderRow", "Description": "Line number in the CSV file counting from zero where column headers can be found."}, {"Required": 1, "Name": "MarkerNameCol", "Description": "Column number counting from zero which has marker names."}, {"Required": 1, "Name": "SequenceCol", "Description": "Column number counting from zero which has marker sequences."}, {"Required": 1, "Name": "MarkerMetaColStart", "Description": "Column number counting from zero for the starting of marker meta data column. Marker meta data columns must be adjacent to each other."}, {"Required": 1, "Name": "MarkerMetaColEnd", "Description": "Column number counting from zero for the last marker meta data column."}, {"Required": 1, "Name": "MarkerDataColStart", "Description": "Column number counting from zero for the starting of marker data column."}, {"Required": 1, "Name": "MarkerDataColEnd", "Description": "Column number counting from zero for the last marker data column."}, {"Required": 1, "Name": "DataSetType", "Description": "ID of dataset type which can represent scoring dataset, count dataset, or other marker quality dataset type."}, {"Required": 0, "Name": "ParentDataSetId", "Description": "ID of parent dataset if exists. Marker quality dataset like count needs a parent scoring dataset, to which the quality dataset complements."}, {"Required": 0, "Name": "Description", "Description": "Description of the dataset to be imported."}, {"Required": 0, "Name": "Forced", "Description": "0|1 switch to do forced importation on a dataset which already has data in the system. This parameter should be used for the importation to update the dataset."}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing DataSetId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self    = shift;
  my $query   = $self->query();

  my $dataset_id = $self->param('id');

  my $start_time = [gettimeofday()];

  my $header_row            = $query->param('HeaderRow');

  my $marker_name_col       = $query->param('MarkerNameCol');
  my $sequence_col          = $query->param('SequenceCol');

  my $marker_meta_scol      = $query->param('MarkerMetaColStart');
  my $marker_meta_ecol      = $query->param('MarkerMetaColEnd');

  my $marker_data_scol      = $query->param('MarkerDataColStart');
  my $marker_data_ecol      = $query->param('MarkerDataColEnd');

  my $data_for_postrun_href = {};

  my $dbh_m_read = connect_mdb_read();

  my $read_dataset_sql   = 'SELECT "AnalysisGroupId", "MarkerNameFieldName" ';
     $read_dataset_sql  .= 'FROM dataset WHERE "DataSetId"=? ';

  my ($r_df_val_err, $r_df_val_msg, $dataset_df_val_data) = read_data($dbh_m_read, $read_dataset_sql, [$dataset_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve dataset default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $anal_id                   =   undef;
  my $ds_mrk_name_fieldname     =   undef;

  my $nb_df_val_rec    =  scalar(@{$dataset_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve dataset default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $anal_id                   =   $dataset_df_val_data->[0]->{'AnalysisGroupId'};
  $ds_mrk_name_fieldname     =   $dataset_df_val_data->[0]->{'MarkerNameFieldName'};

  if (length($anal_id) == 0) {

    my $err_msg = "DataSet ($dataset_id): not found.";

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

  my ($missing_err, $missing_href) = check_missing_href( {'HeaderRow' => $header_row } );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  my $sql = '';

  $dbh_m_read->disconnect();

  my $dbh_m_write = connect_mdb_write();

  my $markerdata_tablename = "markerdata${dataset_id}";

  my ($mrk_tbl_sfield_err, $mrk_tbl_sfield_msg,
      $mrk_tbl_sfield_data, $mrk_tbl_pkey_data) = get_static_field($dbh_m_write, $markerdata_tablename);

  if ($mrk_tbl_sfield_err) {

    $self->logger->debug("Retrieve $markerdata_tablename static fields failed: $mrk_tbl_sfield_msg");
    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $fieldname2info_href = {};

  foreach my $sfield_rec (@{$mrk_tbl_sfield_data}) {

    my $field_name = $sfield_rec->{'Name'};
    $fieldname2info_href->{$field_name} = $sfield_rec;
  }

  my @first_fieldname_list;

  for (my $i = 0; $i < $num_of_col; $i++) {

    push(@first_fieldname_list, "Col$i");
  }

  my $csv_filehandle;
  open($csv_filehandle, "$data_csv_file") or die "Cannot open $data_csv_file: $!";

  my $check_empty_col   = 0;
  my $nb_line_wanted    = $header_row + 1 + 100; # get the top 100 lines plus the header
  my $ignore_line0      = 0;
  my $ignore_header     = 0;

  my ($csv_header_err, $csv_header_msg, $top100_section_aref) = csvfh2aref($csv_filehandle,
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

  my $header_href = $top100_section_aref->[$header_row];

  my @empty_header_col_list;
  for (my $i = 0; $i < $num_of_col; $i++) {

    my $header_name = $header_href->{"Col$i"};
    if (length($header_name) == 0) {

      push(@empty_header_col_list, $i);
    }
  }

  if (scalar(@empty_header_col_list) > 0) {

    my $empty_header_col_csv = join(',', @empty_header_col_list);
    my $err_msg = "Column ($empty_header_col_csv): no header";

    $self->logger->debug("Empty header columns: $empty_header_col_csv");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $matched_col = {};

  $matched_col->{$marker_name_col}         = $header_href->{"Col$marker_name_col"};
  $matched_col->{$sequence_col}            = $header_href->{"Col$sequence_col"};

  my $mrk_name_col_name = $header_href->{"Col${marker_name_col}"};
  my $mrk_seq_col_name  = $header_href->{"Col${sequence_col}"};

  if ( !(defined $fieldname2info_href->{$mrk_name_col_name}) ) {

    my $err_msg = "Marker name column ($mrk_name_col_name): not found in dataset ($dataset_id).";
    $self->logger->debug($err_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( !(defined $fieldname2info_href->{$mrk_seq_col_name}) ) {

    my $err_msg = "Marker sequence column ($mrk_seq_col_name): not found in dataset ($dataset_id).";
    $self->logger->debug($err_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my @marker_meta_field_list = (qq|"$mrk_name_col_name"|, qq|"$mrk_seq_col_name"|);

  for (my $i = $marker_meta_scol; $i <= $marker_meta_ecol; $i++) {

    my $col_name = $header_href->{"Col$i"};

    if ( !(defined $fieldname2info_href->{$col_name}) ) {

      my $err_msg = "Meta data column ($col_name): not found in dataset ($dataset_id).";
      $self->logger->debug($err_msg);

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    push(@marker_meta_field_list, qq|"$col_name"|);
    $matched_col->{"$i"} = $col_name;
  }

  $self->logger->debug("Marker meta field: " . join(',', @marker_meta_field_list));

  my @marker_data_field_list;

  for (my $i = $marker_data_scol; $i <= $marker_data_ecol; $i++) {

    my $extract_id = $header_href->{"Col$i"};
    my $field_name = "E_${extract_id}";

    if ( !(defined $fieldname2info_href->{$field_name}) ) {

      my $err_msg = "Extract ($extract_id): not found in dataset ($dataset_id).";
      $self->logger->debug($err_msg);

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    push(@marker_data_field_list, qq|"$field_name"|);
    $matched_col->{"$i"} = $field_name;
  }

  my @unused_col_list;

  for (my $i = 0; $i < $num_of_col; $i++) {

    if (!defined($matched_col->{"$i"})) {

      push(@unused_col_list, $i);
    }
  }

  if (scalar(@unused_col_list) > 0) {

    my $unused_col_csv = join(',', @unused_col_list);

    my $err_msg = "Column ($unused_col_csv): unused - please remove these columns and append again.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $uniq_mrk_name_href = {};

  for (my $j = $header_row + 1; $j < scalar(@{$top100_section_aref}); $j++) {

    my $marker_name = $top100_section_aref->[$j]->{"Col${marker_name_col}"};
    $uniq_mrk_name_href->{qq|'$marker_name'|} = 1;
  }

  if (scalar(keys(%{$uniq_mrk_name_href})) == 0) {

    my $err_msg = "No marker name found in the top 100 lines in the CSV file.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $uniq_mrk_name_csv = join(',', keys(%{$uniq_mrk_name_href}));

  $sql  = qq|SELECT COUNT(*) FROM "$markerdata_tablename" |;
  $sql .= qq|WHERE "$ds_mrk_name_fieldname" IN ($uniq_mrk_name_csv)|;

  my ($r_count_err, $dup_count) = read_cell($dbh_m_write, $sql, []);

  if ($r_count_err) {

    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ($dup_count > 10) {

    my $err_msg = "More than 10 markers from the top 100 lines already exist.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $tmp_tablename = "${markerdata_tablename}_tmp";

  my $create_tmp_sql = qq|CREATE LOCAL TEMPORARY TABLE "$tmp_tablename" (|;

  my @field_sql_def_list;
  my $check_uniqueness = {};
  my @non_unique_columns;
  my $non_unique_err = 0;

  for (my $i = 0; $i < $num_of_col; $i++) {

    my $fieldname      = $matched_col->{"$i"};

    my $field_datatype = $fieldname2info_href->{$fieldname}->{'DataType'};
    my $field_colsize  = $fieldname2info_href->{$fieldname}->{'ColSize'};

    my $full_datatype  = $field_datatype;

    if (lc($field_datatype) eq 'varchar') {

      $full_datatype = qq|${field_datatype}(${field_colsize})|;
    }

    if (defined $check_uniqueness->{$fieldname}) {

      $self->logger->debug("$fieldname already used as a column. Will cause crash.");
      $non_unique_err = 1;

      push(@non_unique_columns, $fieldname);
    }

    $check_uniqueness->{$fieldname} = $i;

    my $field_sql = qq|"$fieldname" $full_datatype NULL|;
    push(@field_sql_def_list, $field_sql);
  }

if ($non_unique_err == 1) {
    my $err_msg = "Columns (" . join(',', @non_unique_columns) . ') in marker data are not unique.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }


  $create_tmp_sql   .= join(',', @field_sql_def_list);

  $create_tmp_sql   .= qq|) ON COMMIT PRESERVE ROWS|;

  $self->logger->debug("CREATE TMP SQL: $create_tmp_sql");

  my ($mk_tmp_tbl_err, $mk_tmp_tbl_msg) = execute_sql($dbh_m_write, $create_tmp_sql, []);

  if ($mk_tmp_tbl_err) {

    $self->logger->debug("Create temporary table failed: $mk_tmp_tbl_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $monetdb_csv_file = $TMP_DATA_PATH . "csv4monetdb${dataset_id}.csv";

  my $copy_file_start_time = [gettimeofday()];

  # first line is number one in copy_file
  copy_file($data_csv_file, $monetdb_csv_file, $header_row + 1 + 1);

  my $copy_file_elapsed_time = tv_interval($copy_file_start_time);

  $self->logger->debug("Copy file takes: $copy_file_elapsed_time");

  my $copy_into_start_time = [gettimeofday()];

  $sql  = qq|COPY INTO "$tmp_tablename" FROM '$monetdb_csv_file' |;
  $sql .= q|USING DELIMITERS ',','\\n','"'|;

  $self->logger->debug("SQL: $sql");

  my ($copy_into_err, $copy_into_msg) = execute_sql($dbh_m_write, $sql, []);

  my $copy_into_elapsed_time = tv_interval($copy_into_start_time);

  $self->logger->debug("MonetDB COPY INTO takes: $copy_into_elapsed_time");

  if ($copy_into_err) {

    $copy_into_msg =~ s/failed to import table at.*//g;

    $self->logger->debug("Loading data into table $tmp_tablename failed: $copy_into_msg");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $copy_into_msg}]};

    return $data_for_postrun_href;
  }

  $sql = qq|SELECT COUNT(*) FROM "$tmp_tablename"|;

  my ($r_nb_rec_err, $nb_rec) = read_cell($dbh_m_write, $sql, []);

  if ($r_nb_rec_err) {

    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("NB REC: $nb_rec");

  if ($nb_rec == 0) {

    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql  = qq|INSERT INTO "analysisgroupmarker"("DataSetId","MarkerName","MarkerSequence") |;
  $sql .= qq|SELECT $dataset_id AS "DataSetId", "$mrk_name_col_name", "$mrk_seq_col_name" |;
  $sql .= qq|FROM "$tmp_tablename"|;

  $self->logger->debug("SQL: $sql");

  my ($copy_mrk_err, $copy_mrk_msg) = execute_sql($dbh_m_write, $sql, []);

  if ($copy_mrk_err) {

    $self->logger->debug("Copy markers failed: $copy_mrk_msg");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $all_field_csv = join(',', (@marker_meta_field_list, @marker_data_field_list));

  $sql  = qq|INSERT INTO "$markerdata_tablename" ( $all_field_csv ) |;
  $sql .= qq|SELECT $all_field_csv FROM "$tmp_tablename"|;

  $self->logger->debug("SQL: $sql");

  my ($copy_mrk_data_err, $copy_mrk_data_msg) = execute_sql($dbh_m_write, $sql, []);

  if ($copy_mrk_data_err) {

    $self->logger->debug("Copy marker data failed: $copy_mrk_data_msg");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $dbh_m_write->disconnect();

  my $elapsed_time = tv_interval($start_time);

  my $nb_extract = scalar(@marker_data_field_list);
  my $nb_mrkmeta = scalar(@marker_meta_field_list) - 2;

  my $info_msg = "Appending marker data into DataSet ($dataset_id) is successful. ";
  $info_msg   .= "Number of markers: $nb_rec. Number of extracts: $nb_extract. Number of meta fields: $nb_mrkmeta";

  my $info_msg_aref = [{'Message' => $info_msg, 'RunTime' => "$elapsed_time"}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub import_markermap_position_dataset_runmode {

=pod import_markermap_position_dataset_gadmin_HELP_START
{
"OperationName": "Import marker map position from a dataset",
"Description": "Import marker map positions from an existing dataset",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Marker map position records (35193,35193) have been imported into markermap (1) from dataset (1) successfully.' /><StatInfo ServerElapsedTime='0.222' Unit='second' /></DATA>",
"SuccessMessageJSON": "{'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.475'}],'Info' : [{'Message' : 'Marker map position records (35193,60116) have been imported into markermap (1) from dataset (1) successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='MarkerMap (18) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'MarkerMap (18) not found.'}]}"}],
"RequiredUpload": 0,
"HTTPParameter": [{"Required": 1, "Name": "ContigNameColumn", "Description": "Marker meta data column from the dataset which contains ContigName."}, {"Required": 1, "Name": "ContigPositionColumn", "Description": "Marker meta data column from the dataset which contains ContigPosition."}, {"Required": 0, "Name": "Forced", "Description": "Either 1 or 0. If value 1 is provided, DAL will override any existing position by removing them first. If other value is provided or no value is provided at all, DAL will return an error when the specified map already has any position record(s)."}, {"Required": 1, "Name": "Filtering", "Description": "Filtering expression to be applied to the marker data from the specified dataset for marker map position data."}],
"URLParameter": [{"ParameterName": "mrkmapid", "Description": "MarkerMapId"}, {"ParameterName": "dsid", "Description": "MarkerMapId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self    = shift;
  my $query   = $self->query();

  my $markermap_id = $self->param('mrkmapid');
  my $dsid         = $self->param('dsid');

  my $data_for_postrun_href = {};

  my $dbh_m_read = connect_mdb_read();

  my $map_operator_id = read_cell_value($dbh_m_read, 'markermap', 'OperatorId', 'MarkerMapId', $markermap_id);

  if (length($map_operator_id) == 0) {

    my $err_msg = "MarkerMap ($markermap_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $user_id = $self->authen->user_id();

  if ("$map_operator_id" ne "$user_id") {

    my $err_msg = "MarkerMap ($markermap_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $anal_id = read_cell_value($dbh_m_read, 'dataset', 'AnalysisGroupId', 'DataSetId', $dsid);

  if (length($anal_id) == 0) {

    my $err_msg = "DataSet ($dsid) not found.";

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

  my $force                  = $query->param('Forced');

  my $contig_name_colname    = $query->param('ContigNameColumn');
  my $contig_pos_colname     = $query->param('ContigPositionColumn');
  my $filtering              = $query->param('Filtering');

  my ($missing_err, $missing_href) = check_missing_href( {
                                                          'ContigNameColumn'           => $contig_name_colname,
                                                          'ContigPositionColumn'       => $contig_pos_colname,
                                                          'Filtering'                  => $filtering,
                                                         } );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  my $read_dataset_sql  = 'SELECT "MarkerNameFieldName", "MarkerSequenceFieldName" ';
  $read_dataset_sql    .= 'FROM dataset WHERE "DataSetId"=? ';

  my ($r_ds_err, $r_ds_msg, $dataset_data) = read_data($dbh_m_read, $read_dataset_sql, [$dsid]);

  if ($r_ds_err) {

    $self->logger->debug("Retrieve dataset markername and sequence fields failed: $r_ds_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $mrk_name_fieldname =  undef;
  my $seq_fieldname      =  undef;

  my $nb_ds_rec    =  scalar(@{$dataset_data});

  if ($nb_ds_rec != 1)  {

     $self->logger->debug("Retrieve dataset number of records not acceptable: $nb_ds_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $mrk_name_fieldname =  $dataset_data->[0]->{'MarkerNameFieldName'};
  $seq_fieldname      =  $dataset_data->[0]->{'MarkerSequenceFieldName'};

  my $sql = 'SELECT "FieldName" FROM "datasetmarkermeta" WHERE "DataSetId"=?';

  my ($r_factor_err, $r_factor_msg, $factor_data) = read_data($dbh_m_read, $sql, [$dsid]);

  if ($r_factor_err) {

    $self->logger->debug("Read FactorId for dataset ($dsid) failed");
    my $err_msg = "Unexpected error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my @filterable_fieldlist = ($mrk_name_fieldname, $seq_fieldname);

  for my $factor_rec (@{$factor_data}) {

    my $meta_fieldname  = $factor_rec->{'FieldName'};

    push(@filterable_fieldlist, $meta_fieldname);
  }

  my ($sel_meta_field_err,
      $sel_meta_field_msg,
      $sel_meta_field_list) = parse_selected_field("${contig_name_colname},${contig_pos_colname}",
                                                   \@filterable_fieldlist,
                                                   $mrk_name_fieldname);

  if ($sel_meta_field_err) {

    $self->logger->debug("Parse selected fields error: $sel_meta_field_msg");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_meta_field_msg}]};

    return $data_for_postrun_href;
  }

  my $field_name2table_name  = { $mrk_name_fieldname => qq|"markerdata${dsid}"|,
                                 $seq_fieldname      => qq|"markerdata${dsid}"| };
  my $validation_func_lookup = {};

  my ($filtering_err, $filtering_msg, $filter_phrase, $where_arg) = parse_filtering(qq|"$mrk_name_fieldname"|,
                                                                                    qq|"markerdata${dsid}"|,
                                                                                    $filtering,
                                                                                    \@filterable_fieldlist,
                                                                                    $validation_func_lookup,
                                                                                    $field_name2table_name);

  if ($filtering_err) {

    $self->logger->debug("Parsing filtering failed: $filtering_msg");

    my $err_msg = $filtering_msg;

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $filtering_exp = '';
  if (length($filter_phrase) > 0) {

    $filtering_exp = " WHERE $filter_phrase ";
  }

  $self->logger->debug("Filtering EXP: $filtering_exp");

  $sql = 'SELECT COUNT(*) FROM "markermapposition" WHERE "MarkerMapId"=?';

  my ($r_count_err, $mapposition_count) = read_cell($dbh_m_read, $sql, [$markermap_id]);

  if ($r_count_err) {

    $self->logger->debug("Count the number of markermapposition failed.");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error.'}]};

    return $data_for_postrun_href;
  }

  $dbh_m_read->disconnect();

  my $dbh_m_write = connect_mdb_write();

  $self->logger->debug("Number of markermap position: $mapposition_count");

  if ($mapposition_count > 0) {

    if ("$force" ne '1') {

      my $err_msg = "MarkerMap ($markermap_id): already has position(s).";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    else {

      $sql = 'DELETE FROM "markermapposition" WHERE "MarkerMapId"=?';

      my $sth = $dbh_m_write->prepare($sql);
      $sth->execute($markermap_id);

      if ($dbh_m_write->err()) {

        $self->logger->debug("Deleting markermap position failed");
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

        return $data_for_postrun_href;
      }

      $sth->finish();
    }
  }

  $sql = qq|SELECT COUNT(*) FROM markerdata${dsid} $filtering_exp|;

  my ($r_ds_count_err, $ds_rec_count) = read_cell($dbh_m_write, $sql, $where_arg);

  if ($r_ds_count_err) {

    $self->logger->debug("Count the number of records matched in markerdata${dsid} failed.");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error.'}]};

    return $data_for_postrun_href;
  }

  if ($ds_rec_count == 0) {

    my $err_msg = "No records from dataset ($dsid) matched with filtering ($filtering).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql  = qq|SELECT COUNT(*) FROM markerdata${dsid} |;
  $sql .= qq|$filtering_exp AND |;
  $sql .= qq|(length("$contig_name_colname") = 0 OR length("$contig_pos_colname") = 0)|;

  my ($r_empty_count_err, $empty_count) = read_cell($dbh_m_write, $sql, $where_arg);

  if ($r_empty_count_err) {

    $self->logger->debug("Count the number of records empty value in $contig_name_colname or $contig_pos_colname in markerdata${dsid} failed.");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error.'}]};

    return $data_for_postrun_href;
  }

  if ($empty_count > 0) {

    my $err_msg = "There are $empty_count records in dataset ($dsid) matching $filtering with empty value in $contig_name_colname or $contig_pos_colname fields.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_m_write->disconnect();

  $dbh_m_write = connect_mdb_write();

  $sql  = qq|INSERT INTO "markermapposition"("MarkerMapId","AnalysisGroupMarkerId", "MarkerName", |;
  $sql .= qq|"ContigName","ContigPosition") |;
  $sql .= qq|SELECT DISTINCT '$markermap_id', "AnalysisGroupMarkerId", |;
  $sql .= qq|"analysisgroupmarker"."MarkerName" AS "MarkerName", |;
  $sql .= qq|"$contig_name_colname" AS "ContigName", |;
  $sql .= qq|"$contig_pos_colname" AS "ContigPosition" from "markerdata${dsid}" LEFT JOIN |;
  $sql .= qq|"analysisgroupmarker" ON |;
  $sql .= qq|"markerdata${dsid}"."$mrk_name_fieldname" = "analysisgroupmarker"."MarkerName" |;
  $sql .= qq|$filtering_exp AND "analysisgroupmarker"."DataSetId"=$dsid |;
  $sql .= qq|ORDER BY LENGTH("markerdata${dsid}"."${contig_name_colname}") ASC, |;
  $sql .= qq|"markerdata${dsid}"."${contig_name_colname}" ASC, |;
  $sql .= qq|LENGTH("markerdata${dsid}"."${contig_pos_colname}") ASC, |;
  $sql .= qq|"markerdata${dsid}"."${contig_pos_colname}" ASC|;

  $self->logger->debug("SQL: $sql");

  my ($insert_pos_err, $insert_pos_msg) = execute_sql($dbh_m_write, $sql, $where_arg);

  if ($insert_pos_err) {

    $self->logger->debug("Inserting records into markermap position failed: $insert_pos_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sql = 'SELECT COUNT(*) FROM "markermapposition" WHERE "MarkerMapId"=?';

  ($r_count_err, $mapposition_count) = read_cell($dbh_m_write, $sql, [$markermap_id]);

  if ($r_count_err) {

    $self->logger->debug("Count the number of markermapposition failed.");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error.'}]};

    return $data_for_postrun_href;
  }

  $dbh_m_write->disconnect();

  my $info_msg = "Marker map position records ($ds_rec_count,$mapposition_count) have been imported into markermap ($markermap_id) from dataset ($dsid) successfully.";

  my $info_msg_aref = [{'Message' => $info_msg}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub export_markermap_position_runmode {

=pod export_markermap_position_gadmin_HELP_START
{
"OperationName": "Export marker map position",
"Description": "Export marker map positions in CSV format",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "",
"SuccessMessageJSON": "",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='MarkerMap (18) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'MarkerMap (18) not found.'}]}"}],
"RequiredUpload": 0,
"HTTPParameter": [{"Required": 1, "Name": "Filtering", "Description": "Filtering expression for the markermapposition"}],
"URLParameter": [{"ParameterName": "mrkmapid", "Description": "MarkerMapId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self    = shift;
  my $query   = $self->query();

  my $markermap_id   = $self->param('mrkmapid');
  my $filtering_csv  = $query->param('Filtering');

  my $data_for_postrun_href = {};

  my $dbh_m_read = connect_mdb_read();

  my $map_operator_id = read_cell_value($dbh_m_read, 'markermap', 'OperatorId', 'MarkerMapId', $markermap_id);

  if (length($map_operator_id) == 0) {

    my $err_msg = "MarkerMap ($markermap_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $user_id = $self->authen->user_id();

  if ("$map_operator_id" ne "$user_id") {

    my $err_msg = "MarkerMap ($markermap_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $field_list = ['MarkerMapId', 'AnalysisGroupMarkerId', 'MarkerName', 'ContigName', 'ContigPosition'];

  my $field_name2table_name  = { "MarkerName" => 'markermapposition' };
  my $validation_func_lookup = {};

  my ($filter_err, $filter_msg,
      $filter_phrase, $where_arg) = parse_filtering('"MarkerMapId"',
                                                    '"markermapposition"',
                                                    $filtering_csv,
                                                    $field_list,
                                                    $validation_func_lookup,
                                                    $field_name2table_name);

  $self->logger->debug("Filter phrase: $filter_phrase");

  if ($filter_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $filter_msg}]};

    return $data_for_postrun_href;
  }

  my $filter_where_phrase = '';

  if (length($filter_phrase) > 0) {

    $filter_where_phrase = " AND $filter_phrase ";
  }

  my $filtering_exp = qq| WHERE "MarkerMapId"=$markermap_id $filter_where_phrase |;

  my $username          = $self->authen->username();
  my $doc_root          = $ENV{'DOCUMENT_ROOT'};
  my $export_data_path  = "${doc_root}/data/$username";
  my $filename          = "export_markermapposition_${markermap_id}";
  my $csv_file          = "${export_data_path}/${filename}.csv";
  my $result_filename   = "${filename}.csv";

  my $file_rand         = makerandom(Size => 8, Strength => 0);

  my $content_file      = "${TMP_DATA_PATH}${filename}_content_${user_id}_${file_rand}.csv";

  my $eol          = "\r\n";
  my $monetdb_eol  = '\\r\\n';

  if ( !(-e $export_data_path) ) {

    mkdir($export_data_path);
  }

  my @header_list = ('MarkerMapPositionId', 'AnalysisGroupMarkerId',
                     'MarkerMapId', 'MarkerName', 'MarkerSequence',
                     'ContigName', 'ContigPosition');

  my $header_filehandle;

  open($header_filehandle, ">$csv_file") or die "Cannot write to $csv_file: $!";

  print $header_filehandle join(',', @header_list) . $eol;

  close($header_filehandle);

  if ( -e $content_file ) {

    unlink $content_file or die "Could not unlink $content_file: $!";
  }

  my $sql = qq|COPY (SELECT "MarkerMapPositionId", "markermapposition"."AnalysisGroupMarkerId", |;
  $sql   .= qq|"MarkerMapId", "markermapposition"."MarkerName", "MarkerSequence", |;
  $sql   .= qq|"ContigName", "ContigPosition" |;
  $sql   .= qq|FROM "markermapposition" LEFT JOIN "analysisgroupmarker" ON |;
  $sql   .= qq|"markermapposition"."AnalysisGroupMarkerId" = "analysisgroupmarker"."AnalysisGroupMarkerId" |;
  $sql   .= qq|$filtering_exp ORDER BY "MarkerMapPositionId" ASC) |;
  $sql   .= qq|INTO '$content_file' USING DELIMITERS ',','$monetdb_eol',''|;

  $self->logger->debug("SQL: $sql");

  my ($copy_to_file_err, $copy_to_file_msg) = execute_sql($dbh_m_read, $sql, $where_arg);

  $self->logger->debug($copy_to_file_msg);

  if ($copy_to_file_err) {

    $self->logger->debug("COPY INTO file failed: $copy_to_file_msg");

    my $err_msg = "Unexpected error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_m_read->disconnect();

  my ($cp_err, $cp_msg) = copy_file($content_file, $csv_file, 1, '>>');

  if ($cp_err) {

    $self->logger->debug("Copy $content_file to $csv_file failed: $cp_msg");

    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  unlink $content_file or die "Cannot unlink $content_file: $!";

  my $url = reconstruct_server_url();

  my $href_info = { 'csv' => "$url/data/$username/$result_filename" };

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'OutputFile'     => [$href_info]};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}



sub logger {

  my $self = shift;
  return $self->{logger};
}

1;
