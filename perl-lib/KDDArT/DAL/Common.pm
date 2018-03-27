#$Id$
#$Author$

# Copyright (c) 2011, Diversity Arrays Technology, All rights reserved.

# Author    : Puthick Hok
# Created   : 02/06/2010
# Modified  :
# Purpose   : 
#          
#          

package KDDArT::DAL::Common;
require Exporter;

use strict;
no strict 'refs';
use warnings;

BEGIN {
  use File::Spec;

  my ($volume, $current_dir, $file) = File::Spec->splitpath(__FILE__);

  my @current_dir_part = split('/perl-lib/KDDArT/DAL/', $current_dir);
  $main::kddart_base_dir = $current_dir_part[0];
}

use DBI;
use Digest::HMAC_SHA1 qw(hmac_sha1 hmac_sha1_hex);
use XML::Writer;
use XML::Simple;
use Geo::Coder::Google;
use Geo::Shapelib qw(:all);
use Text::CSV;
use Text::CSV_XS;
use Text::CSV::Simple;
use DateTime::Format::MySQL;
use Time::HiRes qw( tv_interval gettimeofday );
use Email::Valid;
use Config::Simple;
use LWP::UserAgent;
use HTTP::Request::Common qw(POST GET);
use JSON::XS qw(decode_json);


our @ISA      = qw(Exporter);
our @EXPORT   = qw($DTD_PATH $RPOSTGRES_UP_FILE $GIS_BUFFER_DISTANCE
                   $CGI_INDEX_SCRIPT $LINK_PERM $READ_PERM $WRITE_PERM
                   $READ_LINK_PERM $READ_WRITE_PERM $ALL_PERM $VALID_CTYPE
                   $GIS_ENFORCE_GEO_WITHIN $TMP_DATA_PATH $SESSION_STORAGE_PATH
                   $TIMEZONE $ACCEPT_HEADER_LOOKUP $COOKIE_DOMAIN
                   $DAL_VERSION $DAL_ABOUT $DAL_COPYRIGHT $NB_RECORD_BULK_INSERT
                   $UNIT_POSITION_SPLITTER $M2M_RELATION
                   $GENO_SPEC_ONE2ONE $GENO_SPEC_ONE2MANY $GENO_SPEC_MANY2MANY
                   $GENOTYPE2SPECIMEN_CFG $MULTIMEDIA_STORAGE_PATH $ERR_INFO_AREF
                   $CFG_FILE_PATH $DSN_KDB_READ $DSN_KDB_WRITE $DSN_MDB_READ
                   $DSN_MDB_WRITE $DSN_GIS_READ $DSN_GIS_WRITE $RMYSQL_UP_FILE
                   $MONETDB_UP_FILE $GENOTYPE2SPECIMEN_CFG $OAUTH2_SITE
                   $OAUTH2_AUTHORIZE_PATH $OAUTH2_CLIENT_ID $OAUTH2_CLIENT_SECRET
                   $OAUTH2_SCOPE $OAUTH2_ACCESS_TOKEN_URL $JSON_SCHEMA_PATH
                   $SOLR_URL $POINT2POLYGON_BUFFER4SITE $POINT2POLYGON_BUFFER4TRIAL
                   $MAX_RECURSIVE_ANCESTOR_LEVEL $MAX_RECURSIVE_DESCENDANT_LEVEL
                   $WHO_CAN_CREATE_GENOTYPE $NURSERY_TYPE_LIST_CSV
                   trim ltrim rtrim read_uname_pass connect_kdb_read
                   execute_sql read_cell permission_phrase
                   read_cookie arrayref2csvfile arrayref2xml reconstruct_server_url
                   read_dispatch_table dispatch_table2xml merge_xml
                   connect_kdb_write record_existence read_cell_value
                   generate_factor_sql make_empty_xml connect_gis_read connect_gis_write
                   geocode check_missing_value check_datatype is_unsigned_int
                   add_dtd read_file xml2arrayref check_permission read_data
                   recurse_arrayref2xml is_within check_integer_value
                   check_dt_value check_float_value csvfile2shp row2col_sql
                   pg_case_st check_maxlen csvfile2arrayref get_csvfile_num_of_col
                   check_col_definition get_paged_id get_paged_filter table_existence
                   field_existence check_perm_value record_exist_csv connect_mdb_read
                   connect_mdb_write validate_trait_db generate_mfactor_sql log_activity
                   parse_selected_field parse_filtering parse_sorting generate_vcol_helpers
                   check_group_id remove_dtd dispatch_table2arrayref check_char type_existence
                   type_existence_csv update_vcol_data check_missing_href check_integer_href
                   check_maxlen_href check_dt_href is_valid_wkt_href WKT2geoJSON check_col_def_href
                   csvfh2aref is_correct_validation_rule samplemeasure_row2col rollback_cleanup_multi
                   gen_mfactor_sql gen_paged_mkd_sql write_aref2csv write_href2csv check_float_href
                   get_static_field check_datatype_href is_unsigned_int_href get_paged_filter_sql
                   build_seek_index get_file_line csvfh2aref_index_lnl csvfh2aref_index_sline
                   copy_file filter_csv parse_marker_filtering recurse_read generate_factor_sql_v2
                   parse_filtering_v2 get_file_block id_existence_bulk table_existence_bulk check_perm_href
                   filter_csv_aref parse_marker_sorting get_sorting_function check_static_field
                   get_next_value_for check_bool_href check_email_href check_value_href load_config read_cookies
                   record_existence_bulk get_solr_cores get_solr_fields get_solr_entities
                   validate_trait_db_bulk
                 );

our $COOKIE_DOMAIN            = {};

our $DSN_KDB_READ             = {};

our $DSN_KDB_WRITE            = {};

our $DSN_MDB_READ             = {};

our $DSN_MDB_WRITE            = {};

our $DSN_GIS_READ             = {};

our $DSN_GIS_WRITE            = {};

our $RMYSQL_UP_FILE           = {};

our $MONETDB_UP_FILE          = {};

our $RPOSTGRES_UP_FILE        = {};

our $SOLR_URL                 = {};

our $OAUTH2_SITE              = {};

our $OAUTH2_AUTHORIZE_PATH    = {};

our $OAUTH2_CLIENT_ID         = {};

our $OAUTH2_CLIENT_SECRET     = {};

our $OAUTH2_SCOPE             = {};

our $OAUTH2_ACCESS_TOKEN_URL  = {};

our $MULTIMEDIA_STORAGE_PATH  = "FROM CFG_FILE";

our $DTD_PATH                 = "FROM CFG_FILE";

our $JSON_SCHEMA_PATH         = "FROM CFG_FILE";

our $TMP_DATA_PATH            = "FROM CFG_FILE";

our $SESSION_STORAGE_PATH     = "FROM CFG_FILE";

our $CFG_FILE_PATH            = "$main::kddart_base_dir/secure/kddart_dal.cfg";

our $NB_RECORD_BULK_INSERT    = 3000;

our $GIS_BUFFER_DISTANCE;
$GIS_BUFFER_DISTANCE            = 1; # 1 metre

our $GIS_ENFORCE_GEO_WITHIN     = 1;

# The buffer in fraction of degree for the ST_Buffer when sitelocation is provided as just a point
our $POINT2POLYGON_BUFFER4SITE  = {};

# The buffer in fraction of degree for the ST_Buffer when triallocation is provided as just a point
our $POINT2POLYGON_BUFFER4TRIAL = {};

our $CGI_INDEX_SCRIPT;
$CGI_INDEX_SCRIPT           = "$main::kddart_base_dir/cgi-bin/kddart/index.pl";

our $LINK_PERM              = 1;
our $READ_PERM              = 4;
our $WRITE_PERM             = 2;
our $READ_WRITE_PERM        = 6;
our $READ_LINK_PERM         = 5;
our $ALL_PERM               = 7;

our $TIMEZONE               = 'FROM CFG_FILE';

our $ACCEPT_HEADER_LOOKUP   = { 'application/json' => 'JSON',
                                'text/xml'         => 'XML',
};

our $VALID_CTYPE            = {'xml' => 1, 'json' => 1, 'geojson' => 1};

our $DAL_VERSION            = '2.5.2';
our $DAL_COPYRIGHT          = 'Copyright (c) 2018, Diversity Arrays Technology, All rights reserved.';
our $DAL_ABOUT              = 'Data Access Layer';

our $GENO_SPEC_ONE2ONE      = '1-TO-1';
our $GENO_SPEC_ONE2MANY     = '1-TO-M';
our $GENO_SPEC_MANY2MANY    = 'M-TO-M';

our $GENOTYPE2SPECIMEN_CFG  = "FROM CFG_FILE";

our $UNIT_POSITION_SPLITTER = "FROM CFG_FILE";

our $MAX_RECURSIVE_ANCESTOR_LEVEL     = "FROM CFG_FILE";
our $MAX_RECURSIVE_DESCENDANT_LEVEL   = "FROM CFG_FILE";

our $M2M_RELATION                = {};

$M2M_RELATION->{'specimen'}      = ['genotypespecimen'];
$M2M_RELATION->{'specimengroup'} = ['specimengroupentry'];
$M2M_RELATION->{'trialunit'}     = ['trialunitspecimen'];
$M2M_RELATION->{'itemgroup'}     = ['itemgroupentry'];

our $WHO_CAN_CREATE_GENOTYPE     = {};

our $NURSERY_TYPE_LIST_CSV       = {};

our $ERR_INFO_AREF = [];

push(@{$ERR_INFO_AREF}, {'ErrorId' => 1,  'Message' => 'Id not found'});
push(@{$ERR_INFO_AREF}, {'ErrorId' => 2,  'Message' => 'Value/data already exists'});
push(@{$ERR_INFO_AREF}, {'ErrorId' => 3,  'Message' => 'Missing parameters'});
push(@{$ERR_INFO_AREF}, {'ErrorId' => 4,  'Message' => 'Extra parameters'});
push(@{$ERR_INFO_AREF}, {'ErrorId' => 5,  'Message' => 'Signature verification fails'});
push(@{$ERR_INFO_AREF}, {'ErrorId' => 6,  'Message' => 'Access denied'});
push(@{$ERR_INFO_AREF}, {'ErrorId' => 7,  'Message' => 'Wrong data format'});
push(@{$ERR_INFO_AREF}, {'ErrorId' => 8,  'Message' => 'Invalid value'});
push(@{$ERR_INFO_AREF}, {'ErrorId' => 9,  'Message' => 'Missing internal record'});
push(@{$ERR_INFO_AREF}, {'ErrorId' => 10, 'Message' => 'Invalid upload file'});
push(@{$ERR_INFO_AREF}, {'ErrorId' => 11, 'Message' => 'Unexpected error'});
push(@{$ERR_INFO_AREF}, {'ErrorId' => 12, 'Message' => 'No data to return'});
push(@{$ERR_INFO_AREF}, {'ErrorId' => 13, 'Message' => 'Id is in use'});
push(@{$ERR_INFO_AREF}, {'ErrorId' => 14, 'Message' => 'Duplicate value in the data provided'});

# Perl trim function to remove whitespace from the start and end of the string
sub trim {

  my $string = shift;
  $string =~ s/^\s+//;
  $string =~ s/\s+$//;
  $string =~ s/\r$//g;
  $string =~ s/\n$//g;
  return $string;
}
# Left trim function to remove leading whitespace
sub ltrim {

  my $string = shift;
  $string =~ s/^\s+//;
  return $string;
}
# Right trim function to remove trailing whitespace
sub rtrim {

  my $string = shift;
  $string =~ s/\s+$//;
  return $string;
}

sub read_uname_pass  {

  my $fname = $_[0];

  my @lines;
  open(my $fhandler, "<", $fname) || die "Can't open $fname.";
  chop(@lines = <$fhandler>);
  close($fhandler);
  my $uname = 'text';
  my $pass  = 'text';
  my ($left, $right);
  my $line;
  foreach $line (@lines)
  {
    ($left, $right) = split(/=/, $line);
    $left = trim($left);
    $right = trim($right);
    if ($left eq 'username')
    {
      $uname = $right;
    }
    if ($left eq 'password')
    {
      $pass = $right;
    }
  }
  return ($uname, $pass);
}

sub connect_kdb_read {

  my ($mysql_uname, $mysql_pass) = read_uname_pass($RMYSQL_UP_FILE->{$ENV{DOCUMENT_ROOT}});
  my $dsn = $DSN_KDB_READ->{$ENV{DOCUMENT_ROOT}};
  my $dbh = DBI->connect($dsn, $mysql_uname, $mysql_pass);
  return $dbh;
}

sub connect_mdb_read {

  my ($monetdb_uname, $monetdb_pass) = read_uname_pass($MONETDB_UP_FILE->{$ENV{DOCUMENT_ROOT}});
  my $dsn = $DSN_MDB_READ->{$ENV{DOCUMENT_ROOT}};
  my $dbh = DBI->connect($dsn, $monetdb_uname, $monetdb_pass);
  return $dbh;
}

sub connect_gis_read {

  my ($pg_uname, $pg_pass) = read_uname_pass($RPOSTGRES_UP_FILE->{$ENV{DOCUMENT_ROOT}});
  my $dsn = $DSN_GIS_READ->{$ENV{DOCUMENT_ROOT}};
  my $dbh = DBI->connect($dsn, $pg_uname, $pg_pass);
  return $dbh;
}

sub connect_kdb_write {

  my $no_auto_commit = 0;

  if (defined $_[0]) {

    $no_auto_commit = $_[0];
  }

  my ($mysql_uname, $mysql_pass) = read_uname_pass($RMYSQL_UP_FILE->{$ENV{DOCUMENT_ROOT}});
  my $dsn = $DSN_KDB_WRITE->{$ENV{DOCUMENT_ROOT}};
  my $dbh;

  if (!$no_auto_commit) {

    $dbh = DBI->connect($dsn, $mysql_uname, $mysql_pass);
  }
  else {

    $dbh = DBI->connect($dsn, $mysql_uname, $mysql_pass, { 'RaiseError' => 1, 'AutoCommit' => 0});
  }

  return $dbh;
}

sub connect_mdb_write {

  my $no_auto_commit = 0;

  if (defined $_[0]) {

    $no_auto_commit = $_[0];
  }

  my ($monetdb_uname, $monetdb_pass) = read_uname_pass($MONETDB_UP_FILE->{$ENV{DOCUMENT_ROOT}});
  my $dsn = $DSN_MDB_WRITE->{$ENV{DOCUMENT_ROOT}};
  my $dbh;

  if (!$no_auto_commit) {
    $dbh = DBI->connect($dsn, $monetdb_uname, $monetdb_pass);
  }
  else {
    $dbh = DBI->connect($dsn, $monetdb_uname, $monetdb_pass, { 'RaiseError' => 1, 'AutoCommit' => 0});
  }


  return $dbh;
}

sub connect_gis_write {

  my $no_auto_commit = 0;

  if (defined $_[0]) {

    $no_auto_commit = $_[0];
  }

  my ($pg_uname, $pg_pass) = read_uname_pass($RPOSTGRES_UP_FILE->{$ENV{DOCUMENT_ROOT}});
  my $dsn = $DSN_GIS_WRITE->{$ENV{DOCUMENT_ROOT}};
  my $dbh;

  if (!$no_auto_commit) {

    $dbh = DBI->connect($dsn, $pg_uname, $pg_pass);
  }
  else {

    $dbh = DBI->connect($dsn, $pg_uname, $pg_pass, { 'RaiseError' => 1, 'AutoCommit' => 0 });
  }

  return $dbh;
}


sub execute_sql  {

  my $dbh = $_[0];
  my $sql = $_[1];

  my $para_arg_aref = [];
  if (defined $_[2]) {

    $para_arg_aref = $_[2];
  }

  my $err = 0;
  my $err_str = '';
  my $count = 0;

  # Trying to check string like GenotypeId >= ?, GenotypeId > ? or GenotypeId = ?.
  # This regular expression can match GenotypeId == ?, GenotypeId >> ?, GenotypeId << ?
  # which are invalid SQL logic operation syntaxes.
  while ($sql =~ /[>|<|=]{1,2}+\s*\?/g) {

    $count += 1;
  }

  $err = 0;
  if ( scalar(@{$para_arg_aref}) != $count ) {

    $err = 1;
    return ($err, 'Different number of arguments.');
  }

  my $sth = $dbh->prepare($sql);
  $sth->execute(@{$para_arg_aref});
  $err = $dbh->err();
  $err_str = $dbh->errstr();
  $sth->finish();

  return ($err, $err_str);
}

sub read_cell {

  my $dbh = $_[0];
  my $sql = $_[1];

  my $para_arg = [];
  if (defined $_[2]) {

    $para_arg = $_[2];
  }

  my $count = 0;

  # Trying to check string like GenotypeId >= ?, GenotypeId > ? or GenotypeId = ?.
  # This regular expression can match GenotypeId == ?, GenotypeId >> ?, GenotypeId << ?
  # which are invalid SQL logic operation syntaxes.

  while ($sql =~ /[>|<|=]{1,2}+\s*\?/g) {

    $count += 1;
  }

  my $err = 0;
  if ( scalar(@{$para_arg}) != $count ) {

    $err = 1;
    return ($err, 'Different number of arguments.');
  }

  my $cell_value;
  my $sth = $dbh->prepare($sql);
  $sth->execute(@{$para_arg});

  if ($dbh->err()) {

    $err = 1;
    return ($err, $dbh->errstr());
  }

  $sth->bind_col(1, \$cell_value);
  $sth->fetch();
  $sth->finish();

  if ( !(defined $cell_value) ) {

    $cell_value = '';
  }
  else {

    $cell_value = trim($cell_value);
  }

  return ($err, $cell_value);
}

sub permission_phrase {

  my $group_id        = $_[0];
  my $sql_type        = $_[1];
  my $gadmin          = $_[2];

  my $tablename = q{};
  if ($_[3]) {

    if ($sql_type == 2) {

      $tablename = '"' . $_[3] . '".';
    }
    else {

      $tablename = $_[3] . '.';
    }
  }

  my $sql_phrase = '';
  my $PERM_MASK = 7;   # 3 bits

  my $o_grp_id = $group_id;
  my $a_grp_id = $group_id;

  if ($group_id == 0) {

    if ($sql_type == 2) {

      $o_grp_id = qq|${tablename}"OwnGroupId"|;
      $a_grp_id = qq|${tablename}"AccessGroupId"|;
    }
    else {

      $o_grp_id = "${tablename}OwnGroupId";
      $a_grp_id = "${tablename}AccessGroupId";
    }
  }

  if ($gadmin eq '1') {

    if ($sql_type == 1) {#Postgres

      $sql_phrase .= "(( CAST( (${tablename}OwnGroupId = $o_grp_id) AS INTEGER) * $PERM_MASK ) | ";
      $sql_phrase .= "(( CAST( (${tablename}AccessGroupId = $a_grp_id) AS INTEGER) * $PERM_MASK ) & ${tablename}AccessGroupPerm) | ";
      $sql_phrase .= "${tablename}OtherPerm)";
    }
    elsif ($sql_type == 2) { # MonetDB

      $sql_phrase .= qq/(( (${tablename}"OwnGroupId" = $o_grp_id) * $PERM_MASK ) | /;
      $sql_phrase .= qq/(( (${tablename}"AccessGroupId" = $a_grp_id) * $PERM_MASK ) & ${tablename}"AccessGroupPerm") | /;
      $sql_phrase .= qq/${tablename}"OtherPerm")/;
    }
    elsif ($sql_type == 0) {#MySQL

      $sql_phrase .= "(( (${tablename}OwnGroupId = $o_grp_id) * $PERM_MASK ) | ";
      $sql_phrase .= "(( (${tablename}AccessGroupId = $a_grp_id) * $PERM_MASK ) & ${tablename}AccessGroupPerm) | ";
      $sql_phrase .= "${tablename}OtherPerm)";
    }
  }
  else {

    if ($sql_type == 1) {#Postgres

      $sql_phrase .= "((( CAST( (${tablename}OwnGroupId = $o_grp_id) AS INTEGER) * $PERM_MASK ) & ${tablename}OwnGroupPerm) | ";
      $sql_phrase .= "(( CAST( (${tablename}AccessGroupId = $a_grp_id) AS INTEGER) * $PERM_MASK ) & ${tablename}AccessGroupPerm) | ";
      $sql_phrase .= "${tablename}OtherPerm)";
    }
    elsif ($sql_type == 2) { # MonetDB

      $sql_phrase .= qq/((( (${tablename}"OwnGroupId" = $o_grp_id) * $PERM_MASK ) & ${tablename}"OwnGroupPerm") | /;
      $sql_phrase .= qq/(( (${tablename}"AccessGroupId" = $a_grp_id) * $PERM_MASK ) & ${tablename}"AccessGroupPerm") | /;
      $sql_phrase .= qq/${tablename}"OtherPerm")/;
    }
    elsif ($sql_type == 0) {#MySQL

      $sql_phrase .= "((( (${tablename}OwnGroupId = $o_grp_id) * $PERM_MASK ) & ${tablename}OwnGroupPerm) | ";
      $sql_phrase .= "(( (${tablename}AccessGroupId = $a_grp_id) * $PERM_MASK ) & ${tablename}AccessGroupPerm) | ";
      $sql_phrase .= "${tablename}OtherPerm)";
    }
  }

  return "($sql_phrase)";
}

sub read_cookie {

  my $HTTP_COOKIE = $_[0];
  my $CK_NAME     = $_[1];

  my @cookieArray = split("; ", $HTTP_COOKIE);
  my $desired_cookie_value = '';
  my ($cookie_name, $cookie_value);
  foreach (@cookieArray)
  {
    ($cookie_name, $cookie_value) = split("=", $_);
    if ($cookie_name eq $CK_NAME)
    {
      $desired_cookie_value = $cookie_value;
      last;
    }
  }
  return $desired_cookie_value;
}

sub read_cookies {

  my $HTTP_COOKIE = $_[0];
  my $CK_NAME     = $_[1];

  my @cookieArray = split("; ", $HTTP_COOKIE);
  my @desired_cookie_list;

  my ($cookie_name, $cookie_value);
  foreach (@cookieArray)
  {
    ($cookie_name, $cookie_value) = split("=", $_);
    if ($cookie_name eq $CK_NAME)
    {
      push(@desired_cookie_list, $cookie_value);
    }
  }
  return \@desired_cookie_list;
}

sub arrayref2csvfile {

  my $csvfile          = $_[0];
  my $field_order_href = $_[1];
  my $data_aref        = $_[2];

  my $csv = Text::CSV->new ( { binary => 1 } )  # should set binary attribute.
      or die "Cannot use CSV: ".Text::CSV->error_diag ();
  $csv->eol("\n");

  my @field_list;
  my @unorder_field_list;

  my $found_field_href = {};

  for my $field (keys(%{$data_aref->[0]})) {

    $found_field_href->{$field} = 1;

    if (defined $field_order_href->{$field}) {

      push(@unorder_field_list, [$field, $field_order_href->{$field}]);
    }
    else {

      push(@unorder_field_list, [$field, 999999]);
    }
  }

  for my $field (keys(%{$field_order_href})) {

    if ( !(defined $found_field_href->{$field}) ) {

      my $field_order = $field_order_href->{$field};
      push(@unorder_field_list, [$field, $field_order]);
    }
  }

  my @order_field_list = sort { $a->[1] <=> $b->[1] } @unorder_field_list;

  for my $tuple (@order_field_list) {

    push(@field_list, $tuple->[0]);
  }

  my $fh;
  open($fh, ">:encoding(utf8)", "$csvfile") or die "$csvfile: $!";

  if (scalar(@field_list) > 0) {

    my @header_field_list = @field_list;
    $csv->print($fh, \@header_field_list);
  }

  for my $record (@{$data_aref}) {

    my @row;
    for my $field (@field_list) {

      push(@row, $record->{$field});
    }
    $csv->print($fh, \@row);
  }

  close($fh);
}

sub make_empty_xml {

  my $xml;
  my $writer = new XML::Writer(OUTPUT => \$xml);
  $writer->xmlDecl('UTF-8');

  my $root_tag = 'DATA';
  $writer->startTag($root_tag);
  $writer->endTag($root_tag);
  $writer->end();
  return $xml;
}

sub arrayref2xml {

  my $data     = $_[0];
  my $tag_name = $_[1];
  my $xsl      = $_[2];

  my $xml;
  my $writer = new XML::Writer(OUTPUT => \$xml);
  $writer->xmlDecl('UTF-8');

  if ($xsl && length($xsl) > 0) {

    $writer->pi('xml-stylesheet', qq{href="$xsl" type="text/xsl"});
  }

  my $root_tag = 'DATA';

  $writer->startTag($root_tag);
  for my $row (@{$data}) {

    my %attributes;

    if (ref $row eq 'HASH') {

      for my $fieldname (keys(%{$row})) {

        my $value = $row->{$fieldname};
        $value =~ tr/\000-\037/ /;
        $attributes{$fieldname} = $value;
      }
    }
    else {

      if (ref $row ne 'ARRAY') {

        $attributes{'FieldValue'} = $row;
      }
    }

    $writer->emptyTag($tag_name, %attributes);
  }
  $writer->endTag($root_tag);
  $writer->end();
  return $xml;
}

sub recurse_arrayref2xml {

  my $data      = $_[0];
  my $tag_name  = $_[1];
  my $xsl       = $_[2];

  my $xml = '';
  my $writer = new XML::Writer(OUTPUT => \$xml);
  $writer->xmlDecl('UTF-8');

  if ($xsl && length($xsl) > 0) {

    $writer->pi('xml-stylesheet', qq{href="$xsl" type="text/xsl"});
  }

  my $root_tag = 'DATA';
  $writer->startTag($root_tag);
  make_xml_tag($data, $tag_name, $writer);
  $writer->endTag($root_tag);
  $writer->end();

  return $xml;
}


sub make_xml_tag {

  my $data     = $_[0];
  my $tag_name = $_[1];
  my $writer   = $_[2];

  if (!$writer) {

    return 1;
  }

  for my $row (@{$data}) {

    my $nested = 0;
    my %attributes;
    my @nested_field;

    if (ref $row eq 'HASH') {

      for my $fieldname (keys(%{$row})) {

        if (ref $row->{$fieldname} eq 'ARRAY') {

          $nested = 1;
          push(@nested_field, $fieldname);
        }
        else {

          $attributes{$fieldname} = $row->{$fieldname};
        }
      }
    }
    else {

      if (ref $row ne 'ARRAY') {

        $attributes{'FieldValue'} = $row;
      }
    }

    if ($nested) {

      $writer->startTag($tag_name, %attributes);
      for my $nested_fieldname (@nested_field) {

        make_xml_tag($row->{$nested_fieldname}, $nested_fieldname, $writer);
      }
      $writer->endTag($tag_name);
    }
    else {

      $writer->emptyTag($tag_name, %attributes);
    }
  }

  return 0;
}

sub reconstruct_server_url {

  my $url;
  if ($ENV{'HTTPS'} eq 'on') {

    $url .= "https://";
  }
  else {

    $url .= "http://";
  }

  $url .= $ENV{'HTTP_HOST'};
  return $url;
}

sub dispatch_table2xml {

  my $dispatch_file = $_[0];
  my $gadmin_status = $_[1];

  my $dispatch_table_str = read_dispatch_table($dispatch_file);

  $dispatch_table_str =~ s/:/_/g;
  my $dispatch_table;
  # content of this variable will be filled after the eval
  eval($dispatch_table_str);

  my $op_list_xml_output;
  my $op_list_xml_writer = new XML::Writer(OUTPUT => \$op_list_xml_output);
  $op_list_xml_writer->xmlDecl('UTF-8');
  $op_list_xml_writer->startTag('DATA');

  my $i = 0;
  while( $i < scalar(@{$dispatch_table->{'table'}}) ) {

    my $url_part     = $dispatch_table->{'table'}->[$i];
    my $pck_info_str = $dispatch_table->{'table'}->[$i+1]->{'app'};
    my $run_mode     = $dispatch_table->{'table'}->[$i+1]->{'rm'};

    my @pck_info = split(/::/, $pck_info_str);

    if ( !($run_mode =~ /_notlisted$/) ) {

      if ( $run_mode =~ /_gadmin$/ ) {

        if ( $gadmin_status ) {

          $op_list_xml_writer->emptyTag('Operation', 
                                        'REST'       => $url_part,
              );
        }
      }
      else {

        $op_list_xml_writer->emptyTag('Operation', 
                                      'REST'       => $url_part,
            );
      }
    }

    $i += 2;
  }

  $op_list_xml_writer->endTag('DATA');
  $op_list_xml_writer->end();

  return $op_list_xml_output;
}

sub dispatch_table2arrayref {

  my $dispatch_file = $_[0];
  my $gadmin_status = $_[1];

  my $dispatch_table_str = read_dispatch_table($dispatch_file);

  $dispatch_table_str =~ s/:/_/g;
  my $dispatch_table;
  # content of this variable will be filled after the eval
  eval($dispatch_table_str);

  my $opt_aref = [];

  my $i = 0;
  while( $i < scalar(@{$dispatch_table->{'table'}}) ) {

    my $url_part     = $dispatch_table->{'table'}->[$i];
    my $pck_info_str = $dispatch_table->{'table'}->[$i+1]->{'app'};
    my $run_mode     = $dispatch_table->{'table'}->[$i+1]->{'rm'};

    my @pck_info = split(/::/, $pck_info_str);

    if ( !($run_mode =~ /_notlisted$/) ) {

      if ( $run_mode =~ /_gadmin$/ ) {

        if ( $gadmin_status ) {

          push(@{$opt_aref}, {'REST' => $url_part});
        }
      }
      else {

        push(@{$opt_aref}, {'REST' => $url_part});
      }
    }

    $i += 2;
  }

  return $opt_aref;
}

sub read_dispatch_table {

  my $dispatch_file = $_[0];

  open(DISPATCH_FHANDLE, "<$dispatch_file") || die "Cannot open file: $dispatch_file ($!)";

  my $line;
  my $record = 0;
  my $output = '';
  while($line = <DISPATCH_FHANDLE>) {

    if ($record) {

      if ($line =~ m/\);/) {

        $record = 0;
      }
      else {

        $output .= $line;
      }
    }

    if ($line =~ m/CGI::Application::Dispatch->dispatch\((.*)/ ) {

      $output .= $1;
      $record = 1;
    }
  }

  close(DISPATCH_FHANDLE);

  $output = '$dispatch_table = {' . $output . '};';

  return $output;
}

sub merge_xml {

  my $src_xml      = $_[0];
  my $appended_xml = $_[1];

  $src_xml =~ m/(<\?xml\-stylesheet.*\?>){1}/i;
  my $src_xsl = '';

  if (defined $1) {

    $src_xsl = $1;
  }

  if (length($src_xsl) > 0) {

    $appended_xml =~ s/<DATA>/$src_xsl\n<DATA>/;
  }

  $src_xml =~ m/<DATA>(.*)<\/DATA>/;
  my $src_xml_tags = $1;
  $appended_xml =~ s/<\/DATA>/$src_xml_tags<\/DATA>/;

  return $appended_xml;
}

sub record_existence {

  my $dbh         = $_[0];
  my $table_name  = $_[1];
  my $field_name  = $_[2];
  my $field_value = $_[3];

  my $driver_name = $dbh->{'Driver'}->{'Name'};

  if (lc($driver_name) eq 'monetdb') {

    $field_name = qq|"$field_name"|;
    $table_name = qq|"$table_name"|;
  }

  $field_value = lc($field_value);

  my $sql = "SELECT $field_name ";
  $sql   .= "FROM $table_name ";

  if (lc($driver_name) eq 'pg') {

    # PostgreSQL is case sensitive by default
    $sql .= "WHERE lower(CAST($field_name AS VARCHAR(255)))=? ";
  }
  elsif (lc($driver_name) eq 'monetdb') {

    # MonetDB is case sensitive by default
    $sql .= "WHERE LOWER($field_name)=? ";
  }
  else {

    # MySQL or MariaDB is case insensitive by default
    $sql .= "WHERE $field_name=? ";
  }

  $sql   .= "LIMIT 1";

  my $new_field_value;
  my $sth = $dbh->prepare($sql);
  $sth->execute($field_value);
  $sth->bind_col(1, \$new_field_value);
  $sth->fetch();
  $sth->finish();

  my $found = 1;
  if ( !(defined $new_field_value) ) {

    $found = 0;
  }

  return $found;
}

sub id_existence_bulk {

  my $dbh               = $_[0];
  my $lookup_table_aref = $_[1];
  my $id_value_aref     = $_[2];

  my $driver_name = $dbh->{'Driver'}->{'Name'};

  my $id_value_txt  = '(' . join(',', @{$id_value_aref}) . ')';
  my $nb_id         = scalar(@{$id_value_aref});

  my $exist_href     = {};
  my $non_exist_href = {};
  my $err            = 0;
  my $msg            = '';

  for my $table_info (@{$lookup_table_aref}) {

    # no id record
    if ($nb_id == 0) {

      last;
    }

    my $table_name    = $table_info->{'TableName'};
    my $field_name    = $table_info->{'FieldName'};

    my $sql;

    if (lc($driver_name) eq 'monetdb') {

      $sql    = qq|SELECT DISTINCT "$field_name" |;
      $sql   .= qq|FROM "$table_name" |;
      $sql   .= qq|WHERE "$field_name" IN $id_value_txt|;
    }
    else {

      $sql = "SELECT DISTINCT $field_name ";
      $sql   .= "FROM $table_name ";
      $sql   .= "WHERE $field_name IN $id_value_txt";
    }

    my $sth = $dbh->prepare($sql);
    $sth->execute();

    if ( !$dbh->err() ) {

      my $hash_ref = $sth->fetchall_hashref($field_name);

      if ( !$sth->err() ) {

        for my $id_value (@{$id_value_aref}) {

          $id_value =~ s/^'//;
          $id_value =~ s/'$//;

          if (defined $hash_ref->{$id_value}) {

            $exist_href->{$id_value} = 1;
          }
        }
      }
      else {

        $err = 1;
        $msg = "SQL: $sql - " . $dbh->errstr();
        last;
      }
    }
    else {

      $err = 1;
      $msg = "SQL: $sql - " . $dbh->errstr();
      last;
    }

    $sth->finish();
  }

  for my $id_value (@{$id_value_aref}) {

    if ( !(defined $exist_href->{$id_value}) ) {

      $non_exist_href->{$id_value} = 1;
    }
  }

  return ($err, $msg, $exist_href, $non_exist_href);
}

sub type_existence {

  my $dbh         = $_[0];
  my $class       = $_[1];
  my $type_id     = $_[2];

  my $is_active   = 1;

  if (defined $_[3]) {

    $is_active = $_[3];
  }

  my $sql = "SELECT TypeId FROM generaltype ";
  $sql   .= "WHERE Class=? AND TypeId=? AND IsTypeActive=?";

  my $new_field_value;
  my $sth = $dbh->prepare($sql);
  $sth->execute($class, $type_id, $is_active);
  $sth->bind_col(1, \$new_field_value);
  $sth->fetch();
  $sth->finish();

  my $found = 1;
  if ( !defined($new_field_value) ) {

    $found = 0;
  }

  return $found;
}

sub type_existence_csv {

  my $dbh         = $_[0];
  my $class       = $_[1];
  my $type_id_csv = $_[2];

  my $is_active   = 1;

  if (defined $_[3]) {

    $is_active = $_[3];
  }

  my $err = 0;
  my $msg = '';
  my $return_val;

  my $sql = "SELECT TypeId FROM generaltype ";
  $sql   .= "WHERE Class=? AND TypeId=? AND IsTypeActive=?";

  my @type_id_list = split(/,/, $type_id_csv);

  for my $type_id (@type_id_list) {

    my $new_field_value;
    my $sth = $dbh->prepare($sql);
    $sth->execute($class, $type_id, $is_active);
    $sth->bind_col(1, \$new_field_value);
    $sth->fetch();
    $sth->finish();

    if ( !defined($new_field_value) ) {

      $err = 1;
      $return_val = $type_id;
      last;
    }
  }

  if ($err == 0) {

    # why not returning field_val_in_csv, because field_val_in_csv may have a trailing comma.
    # by using join, it guarantees that there is no trailing comma.
    $return_val = join(',', @type_id_list);
  }

  return ($err, $return_val);
}

sub read_cell_value {

  my $dbh         = $_[0];
  my $table_name  = $_[1];
  my $field_name  = $_[2];
  my $id_field    = $_[3];
  my $record_id   = $_[4];

  my $driver_name = $dbh->{'Driver'}->{'Name'};

  if (lc($driver_name) eq 'monetdb') {

    $id_field   = qq|"$id_field"|;
    $field_name = qq|"$field_name"|;
    $table_name = qq|"$table_name"|;
  }

  my $sql = "SELECT $field_name ";
  $sql   .= "FROM $table_name ";

  if (lc($driver_name) eq 'pg') {

    $sql .= "WHERE lower(CAST($id_field AS VARCHAR(255)))=? ";
  }
  else {

    $sql .= "WHERE LOWER($id_field)=? ";
  }

  $sql   .= "LIMIT 1";

  my $field_value;
  my $sth = $dbh->prepare($sql);
  $sth->execute($record_id);
  $sth->bind_col(1, \$field_value);
  $sth->fetch();
  $sth->finish();

  if ( !(defined $field_value) ) {

    $field_value = '';
  }
  else {

    $field_value = trim($field_value);
  }

  return $field_value;
}

# This function has been superseded by generate_factor_sql_v2 which returns
# the SQL statement that joins the main table and the factor table in a different
# way in order to make filtering on virtual columns possible.

sub generate_factor_sql {

  my $dbh           = $_[0];
  my $field_list    = $_[1];
  my $table_name    = $_[2];
  my $id_fieldname  = $_[3];
  my $other_join    = $_[4];

  my $field_list_href = {};

  for my $field (@{$field_list}) {

    $field_list_href->{$field} = 1;
  }

  my $factor_table = $table_name . 'factor';

  my $sql = "SELECT ${factor_table}.FactorId, FactorName, ";
  $sql   .= "FactorCaption, FactorDescription, FactorDataType, ";
  $sql   .= 'IF(CanFactorHaveNull=0,1,0) AS Required, ';
  $sql   .= 'FactorValueMaxLength, FactorUnit ';
  $sql   .= "FROM $factor_table LEFT JOIN factor ";
  $sql   .= "ON $factor_table.FactorId = factor.FactorId ";
  $sql   .= "GROUP BY factor.FactorId";

  my $sth = $dbh->prepare($sql);
  $sth->execute();

  my $vcol_field_part = q{};
  my @vcol_list;

  my $err = 0;
  my $trouble_vcol_str = '';

  while (my $row = $sth->fetchrow_hashref() ) {

    my $vcol_id       = $row->{'FactorId'};
    my $vcol_name     = $row->{'FactorName'};
    my $vcol_caption  = $row->{'FactorCaption'};
    my $vcol_datatype = $row->{'FactorDataType'};

    if ($vcol_name =~ /\s+/) {

      $err = 1;
      $trouble_vcol_str .= "$vcol_name,";
    }

    my $vcol_unit = q{};
    if ($row->{'FactorUnit'}) {

      $vcol_unit = qq/"$row->{'FactorUnit'}"/;
    }

    my $field_name = "Factor${vcol_name}";

    if ($field_list_href->{$field_name} || $field_list_href->{'VCol*'} || $field_list_href->{'*'}) {

      $vcol_field_part .= qq| GROUP_CONCAT(IF(FactorId = $vcol_id, FactorValue, NULL) SEPARATOR '') AS |;
      $vcol_field_part .= qq| \`${field_name}\`,|;

      push(@vcol_list, $row);
    }
  }

  # remove last character - last "," must not exist
  chop($vcol_field_part);

  $sth->finish();

  my $select_field_part = q{};
  for my $field (@{$field_list}) {

    if ($field =~ /Col\*$/) {

      if ($field eq 'SCol*') {

        $select_field_part .= "${table_name}.*,";
      }
    }
    else {

      # When the field name is not a wild card column like specific individual field name.
      # If the specific field name does not start with Factor. If it does start with
      # Factor, then virtual colum field selection has been done as part of vcol_field_part.

      if ($field !~ /Factor/) {

        if ($field =~ /\./) {

          $select_field_part .= "$field,";
        }
        else {

          $select_field_part .= "${table_name}.$field,";
        }
      }
    }
  }
  # remove last character - last "," must not exist
  chop($select_field_part);

  my $returned_sql = '';
  if (length($select_field_part) > 0) {

    if (length($vcol_field_part) > 0) {

      $returned_sql = "SELECT ${select_field_part}, ${vcol_field_part} ";
    }
    else {

      $returned_sql = "SELECT ${select_field_part} ";
    }
  }
  else {

    if (length($vcol_field_part) > 0) {

      $returned_sql = "SELECT ${vcol_field_part} ";
    }
    else {

      $returned_sql = "SELECT * ";
    }
  }

  $returned_sql   .= "FROM $table_name LEFT JOIN $factor_table ";
  $returned_sql   .= "ON ${table_name}.${id_fieldname} = ${factor_table}.${id_fieldname} ";
  $returned_sql   .= $other_join;
  $returned_sql   .= " GROUP BY ${table_name}.${id_fieldname} ";

  return ($err, $trouble_vcol_str, $returned_sql, \@vcol_list);
}

sub generate_mfactor_sql {

  my $dbh_m         = $_[0];          # handle to marker module database
  my $dbh_k         = $_[1];          # handle to core module database
  my $field_list    = $_[2];
  my $table_name    = $_[3];
  my $id_fieldname  = $_[4];
  my $other_join    = $_[5];

  my $field_list_href = {};

  for my $field (@{$field_list}) {

    $field_list_href->{$field} = 1;
  }

  my $factor_table = $table_name . 'factor';

  my $sql = qq|SELECT "FactorId" FROM "$factor_table" GROUP BY "FactorId"|;

  my ($read_err, $read_msg, $used_factor_data) = read_data($dbh_m, $sql);
  my @used_factor_ids;

  for my $used_factor (@{$used_factor_data}) {

    push(@used_factor_ids, $used_factor->{'FactorId'});
  }

  my $used_factor_id_str = join(',', @used_factor_ids);

  if (length($used_factor_id_str) == 0) {

    $used_factor_id_str = '-99';
  }

  $sql    = "SELECT FactorId, ";
  $sql   .= "FactorName, FactorCaption, FactorDataType, FactorUnit ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE FactorId IN ($used_factor_id_str)";

  my $sth = $dbh_k->prepare($sql);
  $sth->execute();

  my $vcol_field_part = q{};
  my @vcol_list;

  my $err = 0;
  my $trouble_vcol_str = '';

  while (my $row = $sth->fetchrow_hashref() ) {

    my $vcol_id       = $row->{'FactorId'};
    my $vcol_name     = $row->{'FactorName'};
    my $vcol_caption  = $row->{'FactorCaption'};
    my $vcol_datatype = $row->{'FactorDataType'};

    if ($vcol_name =~ /\s+/) {

      $err = 1;
      $trouble_vcol_str .= "$vcol_name,";
    }

    my $vcol_unit = q{};
    if ($row->{'FactorUnit'}) {

      $vcol_unit = qq/"$row->{'FactorUnit'}"/;
    }

    my $field_name = "Factor${vcol_name}";

    if ($field_list_href->{$field_name} || $field_list_href->{'VCol*'} || $field_list_href->{'*'}) {

      $vcol_field_part .= qq/ group_concat(CASE WHEN "FactorId"=$vcol_id THEN "FactorValue" ELSE '' END) AS /;
      $vcol_field_part .= qq/"$field_name",/;

      push(@vcol_list, {'Name'       => "Factor${vcol_name}",
                        'Caption'    => "$vcol_caption",
                        'DataType'   => "$vcol_datatype",
                        'Unit'       => "$vcol_unit",
           }
          );
    }
  }

  # remove last character - last "," must not exist
  chop($vcol_field_part);

  $sth->finish();

  my @select_field_list;
  for my $field (@{$field_list}) {

    if ($field =~ /\*$/) {

      if ($field ne 'VCol*') {

        my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh_m, $table_name);
        if ($sfield_err) {

          $err = 1;
          return ($err, $sfield_msg, '', []);
        }

        for my $sfield_info (@{$sfield_data}) {

          my $sfield_name = $sfield_info->{'Name'};
          push(@select_field_list, qq|"$table_name"."$sfield_name"|);
        }
      }
    }
    else {

      # When the field name is not a wild card column like specific individual field name.
      # If the specific field name does not start with Factor. If it does start with
      # Factor, then virtual colum field selection has been done as part of vcol_field_part.

      if ($field !~ /Factor/) {

        if ($field =~ /\./) {

          if ($field =~ /"/) {

            push(@select_field_list, qq|$field|);
          }
          else {

            push(@select_field_list, qq|"$field"|);
          }
        }
        else {

          if ($field =~ /"/) {

            push(@select_field_list, qq|"${table_name}".$field|);
          }
          else {

            push(@select_field_list, qq|"${table_name}"."$field"|);
          }
        }
      }
    }
  }

  if (scalar(@select_field_list) == 0) {

    push(@select_field_list, qq|"${table_name}"."$id_fieldname"|);
  }

  my $select_field_part = join(',', @select_field_list);

  my $returned_sql = '';

  if (length($vcol_field_part) > 0) {

    # Disable virtual column until a new virtual column for marker (monetdb) is in place

    #$returned_sql = "SELECT ${select_field_part}, ${vcol_field_part} ";
    $returned_sql = "SELECT ${select_field_part} ";
  }
  else {

    $returned_sql = "SELECT ${select_field_part} ";
  }

  my @group_by_field_list;

  for my $select_field_name (@select_field_list) {

    if ($select_field_name !~ /\s+AS\s+/i) {

      push(@group_by_field_list, $select_field_name);
    }
  }

  my $group_by_part = join(',', @group_by_field_list);

  $returned_sql   .= qq|FROM "$table_name" LEFT JOIN "$factor_table" |;
  $returned_sql   .= qq|ON "${table_name}"."${id_fieldname}" = "${factor_table}"."${id_fieldname}" |;
  $returned_sql   .= $other_join;

  # Disable virtual column until a new virtual column for marker (monetdb) is in place

  #$returned_sql   .= qq| GROUP BY $group_by_part |;

  return ($err, $trouble_vcol_str, $returned_sql, \@vcol_list);
}

sub gen_mfactor_sql {

  my $dbh_m          = $_[0];          # handle to marker module database
  my $dbh_k          = $_[1];          # handle to core module database
  my $field_list     = $_[2];
  my $factor_id_aref = $_[3];
  my $tname          = $_[4];
  my $factor_tname   = $_[5];
  my $id_fieldname   = $_[6];
  my $val_fieldname  = $_[7];

  my $other_join     = '';

  if (defined($_[8])) {

    $other_join = $_[8];
  }

  my $field_list_href = {};

  for my $field (@{$field_list}) {

    $field_list_href->{$field} = 1;
  }

  my $used_factor_id_str = join(',', @{$factor_id_aref});

  if (scalar(@{$factor_id_aref}) == 0) {

    $used_factor_id_str = '-99';
  }

  my $sql = "SELECT FactorId, ";
  $sql   .= "FactorName, FactorCaption, FactorDataType, FactorUnit ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE FactorId IN ($used_factor_id_str)";

  my $sth = $dbh_k->prepare($sql);
  $sth->execute();

  my $vcol_field_part = q{};
  my @vcol_list;

  my $err = 0;
  my $trouble_vcol_str = '';

  while (my $row = $sth->fetchrow_hashref() ) {

    my $vcol_id       = $row->{'FactorId'};
    my $vcol_name     = $row->{'FactorName'};
    my $vcol_caption  = $row->{'FactorCaption'};
    my $vcol_datatype = $row->{'FactorDataType'};

    if ($vcol_name =~ /\s+/) {

      $err = 1;
      $trouble_vcol_str .= "$vcol_name,";
    }

    my $vcol_unit = q{};
    if ($row->{'FactorUnit'}) {

      $vcol_unit = qq/"$row->{'FactorUnit'}"/;
    }

    my $field_name = "Factor${vcol_name}";

    if ($field_list_href->{$field_name} || $field_list_href->{'VCol*'} || $field_list_href->{'*'}) {

      $vcol_field_part .= qq/ GROUP_CONCAT(IF(FactorId = $vcol_id, $val_fieldname, NULL) SEPARATOR '') AS /;
      $vcol_field_part .= qq/$field_name,/;

      push(@vcol_list, {'Name'       => "Factor${vcol_name}",
                        'Caption'    => "$vcol_caption",
                        'DataType'   => "$vcol_datatype",
                        'Unit'       => "$vcol_unit",
           }
          );
    }
  }

  # remove last ","
  chop($vcol_field_part);

  $sth->finish();

  my $select_field_part = q{};
  for my $field (@{$field_list}) {

    if ($field =~ /Col\*$/) {

      if ($field eq 'SCol*') {

        $select_field_part .= "${tname}.*,";
      }
    }
    else {

      # When the field name is not a wild card column like specific individual field name.
      # If the specific field name does not start with Factor. If it does start with
      # Factor, then virtual colum field selection has been done as part of vcol_field_part.
      if (!($field =~ /Factor/)) {

        if ($field =~ /\./) {

          $select_field_part .= "$field,";
        }
        else {

          $select_field_part .= "${tname}.$field,";
        }
      }
    }
  }

  # remove last ","
  chop($select_field_part);

  my $returned_sql = '';
  if (length($select_field_part) > 0) {

    if (length($vcol_field_part) > 0) {

      $returned_sql = "SELECT ${select_field_part}, ${vcol_field_part} ";
    }
    else {

      $returned_sql = "SELECT ${select_field_part} ";
    }
  }
  else {

    if (length($vcol_field_part) > 0) {

      $returned_sql = "SELECT ${vcol_field_part} ";
    }
    else {

      $err = 1;
      $trouble_vcol_str = 'Neither static nor virtual column matched.';
    }
  }
  $returned_sql   .= "FROM $tname LEFT JOIN $factor_tname ";
  $returned_sql   .= "ON ${tname}.${id_fieldname} = ${factor_tname}.${id_fieldname} ";
  $returned_sql   .= $other_join;
  $returned_sql   .= " GROUP BY ${tname}.${id_fieldname} ";

  return ($err, $trouble_vcol_str, $returned_sql, \@vcol_list);
}

sub generate_vcol_helpers {

  my ($dbh_k_read, $factor_table) = @_;

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='$factor_table'";

  my $vcol_data = $dbh_k_read->selectall_hashref($sql, 'FactorId');

  my @required_vcols = ();
  my $vcol_len_info = {};
  for my $vcol_id (keys(%{$vcol_data})) {

    my $vcol_param_name = "VCol_${vcol_id}";
    if ($vcol_data->{$vcol_id}->{'CanFactorHaveNull'} != 1) {

      push(@required_vcols, $vcol_param_name);
    }
    $vcol_len_info->{$vcol_param_name} = $vcol_data->{$vcol_id}->{'FactorValueMaxLength'};
  }

  my $check_missing_sub = sub {
    my $vcol_params = shift;

    my %vcol_param_data;
    foreach my $col (@required_vcols) {
      if (exists $vcol_params->{$col}) {
        $vcol_param_data{$col} = $vcol_params->{$col};
      }
      else {
        $vcol_param_data{$col} = '';
      }
    }

    my ($vcol_missing_err, $vcol_missing_msg) = check_missing_value( \%vcol_param_data );
    my $long_missing_msg = $vcol_missing_msg;

    if ($vcol_missing_err) {
      $long_missing_msg = $vcol_missing_msg . ' missing';
    }
    return ($vcol_missing_err, $vcol_missing_msg, $long_missing_msg);
  };

  my $check_maxlength_sub = sub {
    my $param_data_maxlen = shift;

    my $vcol_param_data_maxlen = {};
    foreach my $col (keys %{$vcol_len_info}) {
      if (exists $param_data_maxlen->{$col}) {
        $vcol_param_data_maxlen->{$col} = $param_data_maxlen->{$col};
      }
    }

    my ($vcol_maxlen_err, $vcol_maxlen_msg) =
        check_maxlen($vcol_param_data_maxlen, $vcol_len_info);

    my $long_maxlen_msg = $vcol_maxlen_msg;

    if ($vcol_maxlen_err) {
      $long_maxlen_msg = $vcol_maxlen_msg . ' longer than maximum length.';
    }
    return ($vcol_maxlen_err, $vcol_maxlen_msg, $long_maxlen_msg);
  };

  return ($vcol_data, $check_missing_sub, $check_maxlength_sub);
}

sub geocode {

  my $address      = $_[0];
  my $country_code = $_[1];

  my $apikey = 'ABQIAAAAOPMG2BQ-ihBo7Qr3pAFa7hS7zDBWkOubIDDVH_r4Nb16Dzh7NxSlffodQ6B7U5jK2VTtbiUNL-3W_A';

  my $geocoder = Geo::Coder::Google->new(apikey => $apikey);

  my $location = $geocoder->geocode(location => $address);

  my $found     = 0;
  my $lng       = 0.0;
  my $lat       = 0.0;
  my $accuracy  = 0;

  if (defined($location->{'AddressDetails'}->{'Country'}->{'CountryNameCode'}) &&
      lc($location->{'AddressDetails'}->{'Country'}->{'CountryNameCode'}) eq lc($country_code)) {

    $lng       = $location->{'Point'}->{'coordinates'}->[0];
    $lat       = $location->{'Point'}->{'coordinates'}->[1];
    $accuracy  = $location->{'AddressDetails'}->{'Accuracy'};
    $found     = 1;
  }

  return ($found, $accuracy, $lng, $lat);
}

sub check_missing_value {

  my %args = %{$_[0]};

  my $err = 0;
  my $msg = q{};
  for my $param_name (keys(%args)) {

    if (length($args{$param_name}) == 0) {

      $err = 1;
      $msg .= "[$param_name], ";
    }
  }

  return ($err, $msg);
}

sub is_valid_wkt_href {

  my $dbh_gis         = $_[0];
  my %args            = %{$_[1]};
  my $geo_type_aref   = [];

  if ( defined($_[2]) ) {

    if (ref($_[2]) eq 'ARRAY') {

      $geo_type_aref = $_[2];
    }
    else {

      $geo_type_aref = [$_[2]];
    }
  }

  my $valid_geo_type_href = {};

  foreach my $geo_type (@{$geo_type_aref}) {

    $valid_geo_type_href->{'ST_' . uc($geo_type)} = 1;
  }

  my $err = 0;
  my $err_detail = {};

  for my $param_name (keys(%args)) {

    my $local_err = 0;
    my $well_known_text = $args{$param_name};
    my $check_wkt_sql = qq|SELECT ST_IsValid(ST_GeomFromText('$well_known_text'))|;

    my $sth = $dbh_gis->prepare($check_wkt_sql);
    $sth->execute();

    if ($dbh_gis->err()) {

      $local_err = 1;
    }
    else {

      my $wkt_status = '';
      $sth->bind_col(1, \$wkt_status);
      $sth->fetch();
      $sth->finish();

      if ($wkt_status ne '1') {

        $local_err = 1;
      }
    }

    if ($local_err) {

      $err = 1;
      $err_detail->{$param_name} = "$param_name is not a GIS well known text.";
    }
    else {

      if (scalar(@{$geo_type_aref}) > 0) {

        my $geo_type_sql = qq|SELECT ST_GeometryType(ST_GeomFromText('$well_known_text'))|;

        my $geo_type_sth = $dbh_gis->prepare($geo_type_sql);
        $geo_type_sth->execute();

        my $db_geo_type = '';

        $geo_type_sth->bind_col(1, \$db_geo_type);
        $geo_type_sth->fetch();
        $geo_type_sth->finish();

        if ( ! (defined $valid_geo_type_href->{uc($db_geo_type)}) ) {

          $err = 1;
          $err_detail->{$param_name} = "$param_name is not a geometry type of " . join(',', @{$geo_type_aref});
        }
      }
    }
  }

  return ($err, $err_detail);
}

sub check_missing_href {

  my %args = %{$_[0]};

  my $err = 0;
  my $err_detail = {};
  for my $param_name (keys(%args)) {

    if (length($args{$param_name}) == 0) {

      $err = 1;
      $err_detail->{$param_name} = "$param_name is missing.";
    }
  }

  return ($err, $err_detail);
}

sub check_value_href {

  my %args    = %{$_[0]};
  my %lookup  = %{$_[1]};

  my $err = 0;
  my $err_detail = {};
  for my $param_name (keys(%args)) {

    if (length($args{$param_name}) > 0) {

      if (!(defined $lookup{$args{$param_name}})) {

        $err = 1;
        $err_detail->{$param_name} = $args{$param_name} . ' value is not acceptable.';
      }
    }
  }

  return ($err, $err_detail);
}

sub check_maxlen {

  my %args     = %{$_[0]};
  my %len_info = %{$_[1]};

  my $err = 0;
  my $msg = q{};
  for my $param_name (keys(%args)) {

    if (length($args{$param_name}) > $len_info{$param_name}) {

      $err = 1;
      $msg .= "[$param_name], ";
    }
  }

  return ($err, $msg);
}

sub check_maxlen_href {

  my %args     = %{$_[0]};
  my %len_info = %{$_[1]};

  my $err = 0;
  my $err_detail = {};
  for my $param_name (keys(%args)) {

    if (length($args{$param_name}) > $len_info{$param_name}) {

      $err = 1;
      $err_detail->{$param_name} = "$param_name is longer than " . $len_info{$param_name} . ' characters.';
    }
  }

  return ($err, $err_detail);
}

sub check_integer_value {

  my %args = %{$_[0]};

  my $err = 0;
  my $msg = q{};
  for my $param_name (keys(%args)) {

    if (!($args{$param_name} =~ /^[-|+]?\d+$/)) {

      $err = 1;
      $msg .= "[$param_name], ";
    }
  }

  return ($err, $msg);
}

sub check_integer_href {

  my %args = %{$_[0]};

  my $err = 0;
  my $err_detail = {};
  for my $param_name (keys(%args)) {

    if (!($args{$param_name} =~ /^[-|+]?\d+$/)) {

      $err = 1;
      $err_detail->{$param_name} = "$param_name is not an integer.";
    }
  }

  return ($err, $err_detail);
}


sub check_char {

  my %args    = %{$_[0]};
  my $reg_exp = $_[1];

  my $err = 0;
  my $msg = q{};
  for my $param_name (keys(%args)) {

    if ( $args{$param_name} =~ /$reg_exp/ ) {

      $err = 1;
      $msg .= "[$param_name], ";
    }
  }

  return ($err, $msg);
}

sub check_group_id {

  my %args = %{$_[0]};

  my $err = 0;
  my $msg = q{};
  for my $param_name (keys(%args)) {

    if ($args{$param_name} == 0) {

      $err = 1;
      $msg .= "[$param_name], ";
    }
  }

  return ($err, $msg);
}


sub check_perm_value {

  my %args = %{$_[0]};

  my $err = 0;
  my $msg = q{};
  for my $param_name (keys(%args)) {

    if (!($args{$param_name} =~ /^[-|+]{0,1}\d+$/)) {

      $err = 1;
      $msg .= "[$param_name], ";
    }
    else {

      if ($args{$param_name} > 7 || $args{$param_name} < 0) {

        $err = 1;
        $msg .= "[$param_name], ";
      }
    }
  }

  return ($err, $msg);
}

sub check_perm_href {

  my %args = %{$_[0]};

  my $err = 0;
  my $err_detail = {};
  for my $param_name (keys(%args)) {

    if (!($args{$param_name} =~ /^\d+$/)) {

      $err = 1;
      $err_detail->{$param_name} = "$param_name is an integer.";
    }
    else {

      if ($args{$param_name} > 7 || $args{$param_name} < 0) {

        $err = 1;
        $err_detail->{$param_name} = "$param_name is an integer in 0 to 7 range.";
      }
    }
  }

  return ($err, $err_detail);
}

sub check_dt_value {

  my %args = %{$_[0]};

  my $err = 0;
  my $msg = q{};
  for my $param_name (keys(%args)) {

    if (!($args{$param_name} =~ /^\d{4}\-\d{2}\-\d{2}( \d{2}\:\d{2}\:\d{2})?$/)) {

      $err = 1;
      $msg .= "[$param_name], ";
    }
  }

  return ($err, $msg);
}


sub check_dt_href {

  my %args = %{$_[0]};

  my $err = 0;
  my $err_detail = {};
  for my $param_name (keys(%args)) {

    if (!($args{$param_name} =~ /^\d{4}\-\d{2}\-\d{2}( \d{2}\:\d{2}\:\d{2})?$/)) {

      $err = 1;
      $err_detail->{$param_name} = "$param_name is not in datetime (yyyy-mm-dd HH:MM:SS) format.";
    }
  }

  return ($err, $err_detail);
}

sub check_bool_href {

  my %args = %{$_[0]};

  my $err = 0;
  my $err_detail = {};
  for my $param_name (keys(%args)) {

    if (!($args{$param_name} =~ /^0|1$/)) {

      $err = 1;
      $err_detail->{$param_name} = "$param_name is not in boolean (0|1) format.";
    }
  }

  return ($err, $err_detail);
}

sub check_float_value {

  my %args = %{$_[0]};

  my $err = 0;
  my $msg = q{};
  for my $param_name (keys(%args)) {

    if ( !($args{$param_name} =~ /^[-|+]?\d+\.?\d+$/) &&
         !($args{$param_name} =~ /^\d+$/)
        ) {

      $err = 1;
      $msg .= "[$param_name], ";
    }
  }

  return ($err, $msg);
}

sub check_float_href {

  my %args = %{$_[0]};

  my $err = 0;
  my $err_detail = {};
  for my $param_name (keys(%args)) {

    if ( !($args{$param_name} =~ /^[-|+]?\d+\.?\d+$/) &&
         !($args{$param_name} =~ /^\d+$/)
        ) {

      $err = 1;
      $err_detail->{$param_name} = "$param_name is not a floating point number.";
    }
  }

  return ($err, $err_detail);
}

sub check_email_href {

  my %args = %{$_[0]};

  my $err = 0;
  my $err_detail = {};
  for my $param_name (keys(%args)) {

    my $is_valid = 0;

    eval {

      $is_valid = Email::Valid->address($args{$param_name});
    };

    if ($@) {

      $err = 1;
      $err_detail->{$param_name} = "$param_name is not a valid email.";
    }
    else {

      if ( !$is_valid ) {

        $err = 1;
        $err_detail->{$param_name} = "$param_name is not a valid email.";
      }
    }
  }

  return ($err, $err_detail);
}

sub check_datatype {

  my %args = %{$_[0]};

  my %datatype = ('STRING'  => 1,
                  'INTEGER' => 1,
      );

  my $err = 0;
  my $msg = q{};
  for my $param_name (keys(%args)) {

    if ( $datatype{uc($args{$param_name})} != 1 ) {

      $err = 1;
      $msg .= "[$param_name], ";
    }
  }

  return ($err, $msg);
}

sub check_datatype_href {

  my %args = %{$_[0]};

  my %datatype = ('STRING'  => 1,
                  'INTEGER' => 1,
      );

  my $err = 0;
  my $err_detail = {};
  for my $param_name (keys(%args)) {

    if ( $datatype{uc($args{$param_name})} != 1 ) {

      $err = 1;
      $err_detail->{$param_name} = "$param_name is not supported yet.";
    }
  }

  return ($err, $err_detail);
}

sub is_unsigned_int {

  my %args = %{$_[0]};

  my $err = 0;
  my $msg = q{};
  for my $param_name (keys(%args)) {

    if ( !($args{$param_name} =~ m/^\d+$/) ) {

      $err = 1;
      $msg .= "[$param_name], ";
    }
  }

  return ($err, $msg);
}

sub is_unsigned_int_href {

  my %args = %{$_[0]};

  my $err = 0;
  my $err_detail = {};
  for my $param_name (keys(%args)) {

    if ( !($args{$param_name} =~ m/^\d+$/) ) {

      $err = 1;
      $err_detail->{$param_name} = "$param_name is not a positive integer.";
    }
  }

  return ($err, $err_detail);
}

sub add_dtd {

  my $dtd_file_name = $_[0];
  my $xml_file_name = $_[1];

  open(READ_XML_FH, "<$xml_file_name") or
      die "Cannot open $xml_file_name.";
  my @lines = <READ_XML_FH>;
  close(READ_XML_FH);

  open(UPDATE_XML_FH, ">$xml_file_name") or 
      die "Cannot save $xml_file_name back.";

  my $dtd_added = 0;
  for my $line (@lines) {

    if ($line =~ /<\?xml.*\?>/i) {

      print UPDATE_XML_FH $line;
      my $doctype = qq/<!DOCTYPE DATA SYSTEM "file:$dtd_file_name" >\n/;
      print UPDATE_XML_FH $doctype;
      $dtd_added = 1;
    }
    elsif ($line =~ /<DATA>/i && (!$dtd_added)) {

      print UPDATE_XML_FH qq{<?xml version="1.0" encoding="UTF-8"?>\n};
      my $doctype = qq{<!DOCTYPE DATA SYSTEM "file:$dtd_file_name" >\n};
      print UPDATE_XML_FH $doctype;
      print UPDATE_XML_FH $line;
      $dtd_added = 1;
    }
    else {

      print UPDATE_XML_FH $line;
    }
  }
  close(UPDATE_XML_FH);
}

sub remove_dtd {

  my $xml_file_name = $_[0];

  open(READ_XML_FH, "<$xml_file_name") or
      die "Cannot open $xml_file_name.";
  my @lines = <READ_XML_FH>;
  close(READ_XML_FH);

  open(UPDATE_XML_FH, ">$xml_file_name") or 
      die "Cannot save $xml_file_name back.";
  for my $line (@lines) {

    if ($line =~ /<\!DOCTYPE DATA SYSTEM "file:.*" >/i) {

      next;
    }
    print UPDATE_XML_FH $line;
  }
  close(UPDATE_XML_FH);
}

sub read_file {

  my $file_name = $_[0];

  my $content = '';
  open(FHANDLE, "<$file_name");
  while(my $line = <FHANDLE>) {

    $content .= $line;
  }
  close(FHANDLE);

  return $content;
}

sub xml2arrayref {

  my $data_src = $_[0];
  my $tag_name = $_[1];

  my $data_ref = XMLin($data_src);

  my $data_row_ref = [];
  if ($data_ref->{$tag_name}) {

    # when there is only one tag inside the root tag, XMLin
    # returns a hash reference rather than array reference.
    if ( ref $data_ref->{$tag_name} eq 'HASH' ) {

      my @forced_aref;
      push(@forced_aref, $data_ref->{$tag_name});
      $data_row_ref = \@forced_aref;
    }
    elsif (ref $data_ref->{$tag_name} eq 'ARRAY') {

      $data_row_ref = $data_ref->{$tag_name};
    }
  }

  return $data_row_ref;
}

sub check_permission {

  my $dbh           = $_[0];
  my $table         = $_[1];
  my $id_field      = $_[2];
  my $id_value_aref = $_[3];
  my $group_id      = $_[4];
  my $gadmin_status = $_[5];
  my $perm          = $_[6];

  my $driver_name = $dbh->{'Driver'}->{'Name'};

  my $perm_str = '';

  my $id_list_str = join(',', @{$id_value_aref});

  if (lc($driver_name) eq 'pg') {

    $perm_str = permission_phrase($group_id, 1, $gadmin_status);
  }
  elsif (lc($driver_name) eq 'mysql') {

    $perm_str = permission_phrase($group_id, 0, $gadmin_status);
  }
  elsif (lc($driver_name) eq 'monetdb') {

    $perm_str = permission_phrase($group_id, 2, $gadmin_status);
  }

  my $sql = '';

  if (lc($driver_name) eq 'monetdb') {

    $sql   .= qq|SELECT "$id_field" |;
    $sql   .= qq|FROM "$table" |;
    $sql   .= qq|WHERE ((($perm_str) & $perm) = $perm) AND "$id_field" IN ($id_list_str)|;
  }
  else {

    $sql   .= "SELECT $id_field ";
    $sql   .= "FROM $table ";
    $sql   .= "WHERE ((($perm_str) & $perm) = $perm) AND $id_field IN ($id_list_str)";
  }

  my $n_id = scalar(@{$id_value_aref});
  my $count_from_db;

  my $sth = $dbh->prepare($sql);
  $sth->execute();
  my $id_db_href = $sth->fetchall_hashref($id_field);
  $sth->finish();

  my $is_everything_ok = 1;
  my $trouble_id_aref  = [];
  for my $id (@{$id_value_aref}) {

    if (length($id_db_href->{$id}->{$id_field}) == 0) {

      $is_everything_ok = 0;
      push(@{$trouble_id_aref}, $id);
    }
  }

  return ($is_everything_ok, $trouble_id_aref);
}

sub read_data {

  my $dbh             = $_[0];
  my $sql             = $_[1];
  my $where_para_aref = $_[2];

  if (!$where_para_aref) { $where_para_aref = []; }

  my $data = [];

  my $err = 0;
  my $msg = '';
  my $count = 0;

  # Trying to check string like GenotypeId >= ?, GenotypeId > ? or GenotypeId = ?.
  # This regular expression can match GenotypeId == ?, GenotypeId >> ?, GenotypeId << ?
  # which are invalid SQL logic operation syntaxes.

  while ($sql =~ /[>|<|=]{1,2}+\s*\?/g) {

    $count += 1;
  }

  if (scalar(@{$where_para_aref}) != $count) {

    $msg  = 'The number of arguments in the SQL does not match ';
    $msg .= 'the number of parameters.';

    $err = 1;
    return ($err, $msg, $data);
  }

  my $sth = $dbh->prepare($sql);
  # parameters provided by the caller
  # for example, ('WHERE FieldA=?', '1') 
  $sth->execute(@{$where_para_aref});

  if ( !$dbh->err() ) {

    my $array_ref = $sth->fetchall_arrayref({});

    if ( !$sth->err() ) {

      $data = $array_ref;
    }
    else {

      $err = 1;
      $msg = $dbh->errstr();
    }
  }
  else {

    $err = 1;
    $msg = $dbh->errstr();
  }

  $sth->finish();

  return ($err, $msg, $data);
}

sub is_within {

  # use this function with only a valid geometry.

  my $dbh         = $_[0];
  my $tname       = $_[1];
  my $id_fname    = $_[2];
  my $geo_fname   = $_[3];
  my $wkt         = $_[4];
  my $id_val      = $_[5];

  my $is_within = 0;
  my $err = 0;

  if ( ! record_existence($dbh, $tname, $id_fname, $id_val) ) {

    $is_within = 1;
    return ($err, $is_within);
  }

  my $sql = "SELECT ST_Within(ST_GeomFromText(?, 4326), CAST($geo_fname AS Geometry)) AS IsWithin ";
  $sql   .= "FROM $tname ";
  $sql   .= "WHERE $id_fname=?";

  my $sth = $dbh->prepare($sql);
  $sth->execute($wkt, $id_val);

  if ($dbh->err()) {

    $err = 1;
  }
  else {

    $sth->bind_col(1, \$is_within);
    $sth->fetch();
    $sth->finish();
  }

  return ($err, $is_within);
}

sub csvfile2shp {

  my $csv_filename    = $_[0];
  my $shp_filename    = $_[1];
  my $csv_colnum_list = $_[2];
  my $field_list      = $_[3];
  my $datatype_list   = $_[4];

  my $shapefile = new Geo::Shapelib {
    Name            => $shp_filename,
    Shapetype       => POINT,
    FieldNames      => $field_list,
    FieldTypes      => $datatype_list,
  };

  my $csv_parser = Text::CSV->new( { binary => 1 } );

  open(my $csv_fh, "$csv_filename");

  while (my $line = <$csv_fh>) {

    chomp($line);

    if ($line =~ /^#/) { next; }

    my $success = $csv_parser->parse($line);

    if (!$success) {

      die "Cannot parse CSV line: $line";
    }

    my @line_array = $csv_parser->fields();

    my $shp_x   = $line_array[0];
    my $shp_y   = $line_array[1];
    my $shp_record = [];

    for my $colnum (@{$csv_colnum_list}) {

      push(@{$shp_record}, $line_array[$colnum]);
    }

    push(@{$shapefile->{Shapes}}, { Vertices => [[$shp_x, $shp_y, 0, 0]] });
    push(@{$shapefile->{ShapeRecords}}, $shp_record);
  }

  close($csv_fh);

  $shapefile->save();
}

sub pg_case_st {

  my $test_op            = $_[0];
  my $test_varname       = $_[1];
  my $test_val           = $_[2];
  my $succeeded_val      = $_[3];
  my $failed_val         = $_[4];

  return "cast(case when $test_varname $test_op $test_val then $succeeded_val else $failed_val end as text)";
}

sub get_csvfile_num_of_col {

  my $csvfile = $_[0];

  my $num_of_col = -1;
  my $csv_parser = Text::CSV->new( { binary => 1 } );
  open(my $csv_fh, "$csvfile") or die "Can't read $csvfile: $!";

  # This assumes that file conversion to Unix in check_sign_upload in Security.pm succeeds.
  my $line = '';
  while ($line = <$csv_fh>) {

    chomp($line);
    if ($line =~ /^#/) { 

      next;
    }
    else {

      if (length($line) == 0) {

        next;
      }
      else {

        my $status = $csv_parser->parse($line);
        if ($status) {

          my @columns = $csv_parser->fields();
          $num_of_col = scalar(@columns);
          last;
        }
      }
    }
  }

  close($csv_fh);

  return $num_of_col;
}

sub csvfile2arrayref {

  my $csvfile        = $_[0];
  my $fieldname_aref = $_[1];

  my $check_empty_col = 1;
  if (defined($_[2])) {

    $check_empty_col = $_[2];
  }

  my $csv_parser = Text::CSV::Simple->new({binary => 1});

  $csv_parser->field_map(@{$fieldname_aref});

  my $err          = 0;
  my $err_line     = -1;
  my $err_msg      = '';
  my $num_of_col   = -1;
  my $line_counter = 0;

  $csv_parser->add_trigger(before_parse => sub { before_parse_checking(@_,
                                                                       $check_empty_col,
                                                                       \$err,
                                                                       \$err_line,
                                                                       \$err_msg,
                                                                       \$num_of_col,
                                                                       \$line_counter,
                                                                       $fieldname_aref,
                                                     ); });

  $csv_parser->add_trigger(on_failure => sub {
    my ($self, $csv) = @_;
    warn "DAL Failed on " . $csv->error_input . "\n";
    $err = 1;
    $err_msg = "Problem parsing.";
                           });

  my @data = $csv_parser->read_file($csvfile);

  my $ret_data = [];
  if (!$err) {

    $ret_data = \@data;
  }
  else {

    $err_msg = "Line $err_line: $err_msg";
  }

  return ($ret_data, $err, $err_msg);
}

sub before_parse_checking {

  my $self          = $_[0];
  my $line          = $_[1];
  my $chk_empty_col = $_[2];
  my $err           = $_[3];
  my $err_line      = $_[4];
  my $err_msg       = $_[5];
  my $num_of_col    = $_[6];
  my $line_counter  = $_[7];
  my $field_aref    = $_[8];

  ${$line_counter} += 1;

  #print "Error inside: $err\n";

  my $csv = Text::CSV->new( {binary => 1} ) or die "Cannot use CSV: " . Text::CSV->error_diag();

  my $value = 1;

  if ($line =~ /^#/) { die "Ignore comment line"; }

  my $status  = $csv->parse($line);

  if (!$status) {

    ${$err_msg}  = "Cannot parse $line";
    ${$err_line} = ${$line_counter};
    ${$err}      = 1;
  }

  my @columns = $csv->fields();
  my $cur_nb_col = scalar(@columns);

  if (${$line_counter} < 20) {

    for (my $i = 0; $i < $cur_nb_col; $i++) {

      if ($columns[$i] eq $field_aref->[$i]) { die "Ignore header line";  }
    }
  }

  if (${$num_of_col} == -1) {

    ${$num_of_col} = $cur_nb_col;
  }
  else {

    if (${$num_of_col} != $cur_nb_col) {

      my $prev_num_of_col = ${$num_of_col};
      my $cur_num_of_col  = $cur_nb_col;
      ${$err_msg}  = "The number of columns is different ($prev_num_of_col, $cur_num_of_col).";
      ${$err_line} = ${$line_counter};
      ${$err}      = 1;
    }
  }

  if ($chk_empty_col) {

    my $col_counter = 0;
    for my $col_val (@columns) {

      if (length($col_val) == 0) {

        ${$err_msg}  = "Column ($col_counter) is empty.";
        ${$err_line} = ${$line_counter};
        ${$err}      = 1;
      }

      $col_counter += 1;
    }
  }
}

sub csvfh2aref {

  my $csv_fhandle    = $_[0];
  my $fieldname_aref = $_[1];
  my $chk_empty_col  = $_[2];
  my $nb_line_wanted = $_[3];

  my $ignore_line0   = 0;

  if (defined $_[4]) {

    $ignore_line0 = $_[4];
  }

  my $ignore_header  = 1;

  if (defined $_[5]) {

    $ignore_header = $_[5];
  }

  my $start_line = 0;

  if (defined $_[6]) {

    $start_line = $_[6];
  }

  my $csv_parser = Text::CSV->new( { binary => 1 } );

  my $err          = 0;
  my $err_msg      = '';
  my $num_of_col   = -1;
  my $line_counter = 0;
  my $nb_line_read = 0;

  my $data = [];

  # This assumes that file conversion from DOS to UNIX in check_sign_upload in Security.pm succeeds.
  my $line = '';
  while ($line = <$csv_fhandle>) {

    if ($line_counter < $start_line) {

      $line_counter += 1;
      next;
    }

    if ( $ignore_line0 && ($line_counter == 0) ) {

      $line_counter += 1;
      next;
    }

    $line_counter += 1;
    $nb_line_read += 1;
    if (length($line) == 0) { next; }

    if ($line =~ /^#/) { next; }

    my $success = $csv_parser->parse($line);

    if (!$success) {

      $err = 1;
      $err_msg = "Line ($line_counter): cannot parse CSV line";
      last;
    }

    my @columns = $csv_parser->fields();

    if ($num_of_col == -1) {

      $num_of_col = scalar(@columns);
    }
    else {

      if ($num_of_col != scalar(@columns)) {

        my $prev_num_of_col = $num_of_col;
        my $cur_num_of_col  = scalar(@columns);
        $err_msg  = "Line ($line_counter): ";
        $err_msg .= "the number of columns is different ";
        $err_msg .= "($cur_num_of_col columns in this line compared to $prev_num_of_col).";

        $err      = 1;
      }
    }

    if ($ignore_header) {

      if ($line_counter < 20) {

        my $ignore_header_line = 0;
        for (my $i = 0; $i < $num_of_col; $i++) {

          if ($fieldname_aref->[$i] eq 'null') { next; }

          if ($columns[$i] eq $fieldname_aref->[$i]) {

            $ignore_header_line = 1;
            last;
          }
        }

        if ($ignore_header_line) { next; }
      }
    }

    if ($chk_empty_col) {

      my $col_counter = 0;
      for my $col_val (@columns) {

        if (length($col_val) == 0) {

          $err_msg  = "Line ($line_counter), Column ($col_counter): empty.";
          $err      = 1;
          last;
        }

        $col_counter += 1;
      }
    }

    my $row_href = { map { $_ => shift @columns } @{$fieldname_aref} };
    delete($row_href->{'null'});
    push(@{$data}, $row_href);

    # reach the number of lines wanted
    if ( $nb_line_read == $nb_line_wanted ) {

      last;
    }
  }

  return ($err, $err_msg, $data);
}

sub build_seek_index {

  my $data_file_handle  = $_[0];
  my $index_file_handle = $_[1];

  my $offset     = 0;

  my $line_counter = 0;
  while (<$data_file_handle>) {

    print $index_file_handle pack("N", $offset);
    $offset = tell($data_file_handle);

    $line_counter += 1;
  }

  return $line_counter;
}

sub get_file_line {

  my $data_file_handle  = $_[0];
  my $index_file_handle = $_[1];
  my $line_number       = $_[2];

  my $size;               # size of an index entry
  my $i_offset;           # offset into the index of the entry
  my $entry;              # index entry
  my $d_offset;           # offset into the data file

  $size = length(pack("N", 0));
  $i_offset = $size * ($line_number-1);

  # Error occurs
  seek($index_file_handle, $i_offset, 0) or return (-1, '');

  read($index_file_handle, $entry, $size);
  $d_offset = unpack("N", $entry);

  if (!defined($d_offset)) {

    return (-1, '');
  }

  seek($data_file_handle, $d_offset, 0);

  # No error
  return (0, scalar(<$data_file_handle>));
}

sub csvfh2aref_index_lnl {

  # The fist line is 1
  my $csv_fhandle    = $_[0];
  my $index_fhandle  = $_[1];
  my $fieldname_aref = $_[2];
  my $chk_empty_col  = $_[3];
  my $line_num_aref  = $_[4];

  my $csv_parser = Text::CSV->new( { binary => 1 } );

  my $err          = 0;
  my $err_msg      = '';
  my $num_of_col   = -1;

  my $data = [];

  for my $line_num (@{$line_num_aref}) {

    my ($read_err, $line) = get_file_line($csv_fhandle, $index_fhandle, $line_num);

    if ($read_err) {

      $err = 1;
      $err_msg = "Line ($line_num): cannot read.";
      last;
    }

    if (length($line) == 0) { next; }

    my $success = $csv_parser->parse($line);

    if (!$success) {

      $err = 1;
      $err_msg = "Line ($line_num): cannot parse CSV line";
      last;
    }

    my @columns = $csv_parser->fields();

    if ($num_of_col == -1) {

      $num_of_col = scalar(@columns);
    }
    else {

      if ($num_of_col != scalar(@columns)) {

        my $prev_num_of_col = $num_of_col;
        my $cur_num_of_col  = scalar(@columns);
        $err_msg  = "Line ($line_num): ";
        $err_msg .= "the number of columns is different ";
        $err_msg .= "($cur_num_of_col columns in this line compared to $prev_num_of_col in other lines).";

        $err      = 1;
      }
    }

    if ($chk_empty_col) {

      my $col_counter = 0;
      for my $col_val (@columns) {

        if (length($col_val) == 0) {

          $err_msg  = "Line ($line_num), Column ($col_counter): empty.";
          $err      = 1;
          last;
        }

        $col_counter += 1;
      }
    }

    my $row_href = { map { $_ => shift @columns } @{$fieldname_aref} };
    delete($row_href->{'null'});
    $row_href->{'Line'} = $line_num;
    push(@{$data}, $row_href);
  }

  return ($err, $err_msg, $data);
}

sub csvfh2aref_index_sline {

  # The fist line is 1
  my $csv_fhandle    = $_[0];
  my $index_fhandle  = $_[1];
  my $fieldname_aref = $_[2];
  my $chk_empty_col  = $_[3];
  my $start_at_line  = $_[4];
  my $nb_line        = $_[5];

  my $csv_parser = Text::CSV->new( { binary => 1 } );

  my $err          = 0;
  my $err_msg      = '';
  my $num_of_col   = -1;

  my $data = [];

  my $line_num = $start_at_line;

  while ($line_num < ($start_at_line + $nb_line)) {

    my ($read_err, $line) = get_file_line($csv_fhandle, $index_fhandle, $line_num);

    if ($read_err) {

      $err = 1;
      $err_msg = "Line ($line_num): cannot read.";
      last;
    }

    if (length($line) == 0) { $line_num += 1; next; }

    my $success = $csv_parser->parse($line);

    if (!$success) {

      $err = 1;
      $err_msg = "Line ($line_num): cannot parse CSV line";
      last;
    }

    my @columns = $csv_parser->fields();

    if ($num_of_col == -1) {

      $num_of_col = scalar(@columns);
    }
    else {

      if ($num_of_col != scalar(@columns)) {

        my $prev_num_of_col = $num_of_col;
        my $cur_num_of_col  = scalar(@columns);
        $err_msg  = "Line ($line_num): ";
        $err_msg .= "the number of columns is different ";
        $err_msg .= "($cur_num_of_col columns in this line compared to $prev_num_of_col in other lines).";

        $err      = 1;
      }
    }

    if ($chk_empty_col) {

      my $col_counter = 0;
      for my $col_val (@columns) {

        if (length($col_val) == 0) {

          $err_msg  = "Line ($line_num), Column ($col_counter): empty.";
          $err      = 1;
          last;
        }

        $col_counter += 1;
      }
    }

    my $row_href = { map { $_ => shift @columns } @{$fieldname_aref} };
    delete($row_href->{'null'});
    $row_href->{'LineNum'} = $line_num;
    push(@{$data}, $row_href);

    $line_num += 1;
  }

  return ($err, $err_msg, $data);
}

sub check_col_definition {

  my %args       = %{$_[0]};
  my $num_of_col = $_[1];

  my $err = 0;
  my $msg = q{};
  for my $param_name (keys(%args)) {

    if (length($args{$param_name}) == 0) {

      $err = 1;
      $msg = "$param_name column definition is missing.";
      last;
    }
    else {

      if ( !($args{$param_name} =~ /^\d+$/) ) {

        $err = 1;
        $msg = "$param_name parameter is not an integer.";
        last;
      }
      else {

        if ($args{$param_name} >= $num_of_col) {

          $err = 1;
          $msg = "$param_name is not consistent with the number of columns in the csv file.";
          last;
        }
      }
    }
  }

  return ($err, $msg);
}

sub check_col_def_href {

  my %args       = %{$_[0]};
  my $num_of_col = $_[1];

  my $err = 0;
  my $err_detail = {};

  for my $param_name (keys(%args)) {

    if (length($args{$param_name}) == 0) {

      $err = 1;
      my $msg = " is missing.";
      $err_detail->{$param_name} = $msg;
    }
    else {

      if ( !($args{$param_name} =~ /^[-|+]?\d+$/) ) {

        $err = 1;
        my $msg = " is not an integer.";
        $err_detail->{$param_name} = $msg;
      }
      else {

        if ($args{$param_name} >= $num_of_col) {

          my $param_val = $args{$param_name};
          $err = 1;
          my $msg = " is greater than the number of columns in the file ($num_of_col).";
          $err_detail->{$param_name} = $msg;
        }
      }
    }

    if ($err) {

      last;
    }
  }

  return ($err, $err_detail);  
}

# get_paged_id is obsolete. It is replaced by get_paged_filter.
# However due to the complex structure of the Marker module code,
# get_paged_id has not been replaced in Marker.pm. Therefore,
# get_paged_id has not been removed.

sub get_paged_id {

  my $dbh            = $_[0];
  my $nb_per_page    = $_[1];
  my $page           = $_[2];
  my $table_name     = $_[3];
  my $id_field_name  = $_[4];
  my $where_clause   = qq{};
  my $where_argument = [];

  if (defined $_[5]) {

    $where_clause = $_[5];
  }

  if (defined $_[6]) {

    $where_argument = $_[6];
  }

  my $err     = 0;
  my $err_msg = qq{};

  if (length($where_clause) > 0) {

    my $count = 0;

    # Trying to check string like GenotypeId >= ?, GenotypeId > ? or GenotypeId = ?.
    # This regular expression can match GenotypeId == ?, GenotypeId >> ?, GenotypeId << ?
    # which are invalid SQL logic operation syntaxes.

    while ($where_clause =~ /[>|<|=]{1,2}+\s*\?/g) {

      $count += 1;
    }

    if (scalar(@{$where_argument}) != $count) {

      $err     = 1;
      $err_msg = 'Inconsistent where clause and its arguments.';

      return ($err, $err_msg, -1, -1, []);
    }
  }

  if ($page < 1) {

    $err = 1;
    $err_msg = "Page number $page is not acceptable.";

    return ($err, $err_msg, -1, -1, []);
  }

  my $sql = 'SELECT Count(*) FROM ';
  $sql   .= "$table_name ";
  $sql   .= $where_clause;
  $sql   .= " ORDER BY $id_field_name DESC";

  my $sth = $dbh->prepare($sql);
  $sth->execute(@{$where_argument});

  if ($dbh->err()) {

    $err     = 1;
    $err_msg = $dbh->errstr();

    return ($err, $err_msg, -1, -1, []);
  }

  my $nb_records = 0;
  $sth->bind_col(1, \$nb_records);
  $sth->fetch();
  $sth->finish();

  if ($nb_records == 0) {

    $err     = 0;
    $err_msg = 'No record.';
    return ($err, $err_msg, 0, 0, []);
  }

  my $nb_pages = int($nb_records / $nb_per_page);

  if ( ($nb_records % $nb_per_page) ) {

    $nb_pages += 1;
  }

  if ( $page > $nb_pages ) {

    $err     = 2;
    $err_msg = 'Page unavailable.';
    return ($err, $err_msg, $nb_records, $nb_pages, []);
  }

  $sql  = "SELECT $id_field_name ";
  $sql .= "FROM $table_name ";
  $sql .= $where_clause;
  $sql .= " ORDER BY $id_field_name DESC";

  $sth = $dbh->prepare($sql);
  $sth->execute(@{$where_argument});

  if ($dbh->err()) {

    $err     = 1;
    $err_msg = $dbh->errstr();

    return ($err, $err_msg, -1, -1, []);
  }

  my $select_data = $sth->fetchall_arrayref({});

  if ($sth->err()) {

    $err = 1;
    $err_msg = $dbh->errstr();

    return ($err, $err_msg, -1, -1, []);
  }

  $sth->finish();

  my @data = @{$select_data};

  my $i = 0;
  my $id_aref = [];

  for ( $i = ($page-1)*$nb_per_page; $i < $page*$nb_per_page; $i++ ) {

    if ( length($data[$i]->{$id_field_name}) > 0 ) {

      push(@{$id_aref}, $data[$i]->{$id_field_name});
    }
    else {

      last;
    }
  }

  return ($err, $err_msg, $nb_records, $nb_pages, $id_aref);
}

sub get_paged_filter {

  my $dbh            = $_[0];
  my $nb_per_page    = $_[1];
  my $page           = $_[2];
  my $table_name     = $_[3];
  my $count_field    = $_[4];
  my $where_clause   = qq{};
  my $where_argument = [];

  if (defined $_[5]) {

    $where_clause = $_[5];
  }

  if (defined $_[6]) {

    $where_argument = $_[6];
  }

  my $driver_name = lc($dbh->{'Driver'}->{'Name'});

  my $err     = 0;
  my $err_msg = qq{};

  if (length($where_clause) > 0) {

    my $count = 0;

    # Trying to check string like GenotypeId >= ?, GenotypeId > ? or GenotypeId = ?.
    # This regular expression can match GenotypeId == ?, GenotypeId >> ?, GenotypeId << ?
    # which are invalid SQL logic operation syntaxes.

    while ($where_clause =~ /[>|<|=]{1,2}+\s*\?/g) {

      $count += 1;
    }

    if (scalar(@{$where_argument}) != $count) {

      $err     = 1;
      $err_msg = 'Inconsistent where clause and its arguments.';

      return ($err, $err_msg, -1, -1, '');
    }
  }

  if ($page < 1) {

    $err = 1;
    $err_msg = "Page number $page is not acceptable.";

    return ($err, $err_msg, -1, -1, '');
  }

  my $sql_count_start_time = [gettimeofday()];

  my $sql = "SELECT count($count_field) FROM ";
  $sql   .= "$table_name ";
  $sql   .= "$where_clause";

  my $sth = $dbh->prepare($sql);
  $sth->execute(@{$where_argument});
  my $sql_count_elapsed = tv_interval($sql_count_start_time);

  if ($dbh->err()) {

    $err     = 1;
    $err_msg = $dbh->errstr();

    return ($err, $err_msg, -1, -1, '', $sql_count_elapsed);
  }

  my $nb_records = 0;
  $sth->bind_col(1, \$nb_records);
  $sth->fetch();
  $sth->finish();

  if ($nb_records == 0) {

    $err     = 0;
    $err_msg = 'No record.';
    return ($err, $err_msg, 0, 0, '',  $sql_count_elapsed);
  }

  my $nb_pages = int($nb_records / $nb_per_page);

  if ( ($nb_records % $nb_per_page) ) {

    $nb_pages += 1;
  }

  if ( $page > $nb_pages ) {

    $err     = 2;
    $err_msg = 'Page unavailable.';
    return ($err, $err_msg, $nb_records, $nb_pages, 'LIMIT 0');
  }

  my $limit_start  = ($page-1)*$nb_per_page;
  my $limit_clause = '';

  if ($driver_name eq 'mysql') {

    $limit_clause = "LIMIT ${limit_start},${nb_per_page}";
  }
  elsif ($driver_name eq 'pg') {

    $limit_clause = "LIMIT ${nb_per_page} OFFSET ${limit_start}";
  }
  elsif ($driver_name eq 'monetdb') {

    $limit_clause = "LIMIT ${nb_per_page} OFFSET ${limit_start}";
  }
  else {

    $err     = 1;
    $err_msg = 'Unknown DBI driver';

    return ($err, $err_msg, -1, -1, '', $sql_count_elapsed);
  }

  return ($err, $err_msg, $nb_records, $nb_pages, $limit_clause, $sql_count_elapsed);
}

sub get_paged_filter_sql {

  my $dbh            = $_[0];
  my $nb_per_page    = $_[1];
  my $page           = $_[2];
  my $count_sql      = $_[3];

  my $where_argument = [];

  if (defined $_[4]) {

    $where_argument = $_[4];
  }

  my $driver_name = lc($dbh->{'Driver'}->{'Name'});

  my $err     = 0;
  my $err_msg = qq{};

  if ($page < 1) {

    $err = 1;
    $err_msg = "Page number $page is not acceptable.";

    return ($err, $err_msg, -1, -1, '');
  }

  my $sql_count_start_time = [gettimeofday()];

  my $sth = $dbh->prepare($count_sql);
  $sth->execute(@{$where_argument});
  my $sql_count_elapsed = tv_interval($sql_count_start_time);

  if ($dbh->err()) {

    $err     = 1;
    $err_msg = $dbh->errstr();

    return ($err, $err_msg, -1, -1, '', $sql_count_elapsed);
  }

  my $nb_records = 0;
  $sth->bind_col(1, \$nb_records);
  $sth->fetch();
  $sth->finish();

  if ($nb_records == 0) {

    $err     = 0;
    $err_msg = 'No record.';
    return ($err, $err_msg, 0, 0, '',  $sql_count_elapsed);
  }

  my $nb_pages = int($nb_records / $nb_per_page);

  if ( ($nb_records % $nb_per_page) ) {

    $nb_pages += 1;
  }

  if ( $page > $nb_pages ) {

    $err     = 2;
    $err_msg = 'Page unavailable.';
    return ($err, $err_msg, $nb_records, $nb_pages, 'LIMIT 0');
  }

  my $limit_start  = ($page-1)*$nb_per_page;
  my $limit_clause = '';

  if ($driver_name eq 'mysql') {

    $limit_clause = "LIMIT ${limit_start},${nb_per_page}";
  }
  elsif ($driver_name eq 'pg') {

    $limit_clause = "LIMIT ${nb_per_page} OFFSET ${limit_start}";
  }
  elsif ($driver_name eq 'monetdb') {

    $limit_clause = "LIMIT ${nb_per_page} OFFSET ${limit_start}";
  }
  else {

    $err     = 1;
    $err_msg = 'Unknown DBI driver';

    return ($err, $err_msg, -1, -1, '', $sql_count_elapsed);
  }

  return ($err, $err_msg, $nb_records, $nb_pages, $limit_clause, $sql_count_elapsed);
}

sub gen_paged_mkd_sql {

  my $dbh                 = $_[0];
  my $anal_id             = $_[1];
  my $marker_state_x      = $_[2];
  my $marker_data_field   = $_[3];
  my $extract_list_aref   = $_[4];
  my $nb_marker_per_page  = $_[5];
  my $page                = $_[6];

  my $err          = 0;
  my $err_msg      = '';
  my $nb_markers   = -1;
  my $nb_pages     = -1;
  my $return_sql   = '';

  my $sql = 'SELECT Count(*) FROM analysisgroupmarker where AnalysisGroupId = ?';

  my ($r_count_err, $db_nb_markers) = read_cell($dbh, $sql, [$anal_id]);

  if ($r_count_err) {

    $err          = 1;
    $err_msg      = 'Count the number of markers failed';
    $return_sql   = '';

    return ($err, $err_msg, $return_sql);
  }

  $nb_markers = $db_nb_markers;

  $nb_pages = int($nb_markers / $nb_marker_per_page);

  if ( ($nb_markers % $nb_marker_per_page) ) {

    $nb_pages += 1;
  }

  if ( $page > $nb_pages ) {

    $err     = 1;
    $err_msg = 'Page unavailable.';
    return ($err, $err_msg, '');
  }

  if (scalar(@{$extract_list_aref}) == 0) {

    $err     = 1;
    $err_msg = 'Extract Id list is empty.';
    return ($err, $err_msg, '');
  }

  my $extract_col_sql = '';
  for my $extract_id (@{$extract_list_aref}) {

    $extract_col_sql .= qq/ GROUP_CONCAT(IF(ExtractId = $extract_id, $marker_data_field, NULL) SEPARATOR '') AS /;
    $extract_col_sql .= qq/ '$extract_id',/;
  }

  # remove last ","
  chop($extract_col_sql);

  my $limit_start = ($page-1) * $nb_marker_per_page;
  my $limit_clause = "LIMIT ${limit_start},${nb_marker_per_page}";

  $return_sql  = qq/SELECT AnalysisGroupMarkerId, $extract_col_sql /;
  $return_sql .= qq/FROM genotypemarkerstate${marker_state_x} /;
  $return_sql .= qq/LEFT JOIN analgroupextract /;
  $return_sql .= qq/ON genotypemarkerstate${marker_state_x}.AnalGroupExtractId = analgroupextract.AnalGroupExtractId /;
  $return_sql .= qq/WHERE AnalysisGroupId = $anal_id /;
  $return_sql .= qq/GROUP BY AnalysisGroupMarkerId /;
  $return_sql .= qq/ORDER BY AnalysisGroupMarkerId /;
  $return_sql .= qq/$limit_clause/;

  return ($err, $err_msg, $return_sql);
}

sub field_existence {

  my $dbh        = $_[0];
  my $table_name = $_[1];
  my $field_name = $_[2];

  my $exist = 0;

  my $driver_name = $dbh->{'Driver'}->{'Name'};

  if (lc($driver_name) eq 'pg') {

    $field_name = lc($field_name);
  }

  my $sql = "SELECT * FROM $table_name LIMIT 1";
  my $sth = $dbh->prepare($sql);
  $sth->execute();

  if ($dbh->err()) {

    return 0;
  }

  my $num_of_fields = $sth->{'NUM_OF_FIELDS'};

  for (my $i = 0; $i < $num_of_fields; $i++) {

    if ($sth->{'NAME'}->[$i] eq $field_name) {

      $exist = 1;
      last;
    }
  }

  $sth->finish();

  return $exist;
}

sub record_exist_csv {

  my $dbh              = $_[0];
  my $table_name       = $_[1];
  my $field_name       = $_[2];
  my $field_val_in_csv = $_[3];

  my $err = 0;
  my $msg = '';
  my $return_val;

  my @selected_val = split(/,/, $field_val_in_csv);
  for my $val (@selected_val) {

    my $field_value = lc($val);

    my $sql = "SELECT $field_name ";
    $sql   .= "FROM $table_name ";

    my $driver_name = $dbh->{'Driver'}->{'Name'};

    if (lc($driver_name) eq 'pg') {

      $sql .= "WHERE lower(CAST($field_name AS VARCHAR(255)))=? ";
    }
    elsif (lc($driver_name) eq 'mysql') {

      $sql .= "WHERE LOWER($field_name)=? ";
    }

    $sql   .= "LIMIT 1";

    my $new_field_value;
    my $sth = $dbh->prepare($sql);
    $sth->execute($field_value);
    $sth->bind_col(1, \$new_field_value);
    $sth->fetch();
    $sth->finish();

    if ( !defined($new_field_value) ) {

      $err = 1;
      $return_val = $val;
      last;
    }
  }

  if ($err == 0) {

    # why not returning field_val_in_csv, because field_val_in_csv may have a trailing comma.
    # by using join, it guarantees that there is no trailing comma.
    $return_val = join(',', @selected_val);
  }

  return ($err, $return_val);
}

sub log_activity {

  my $dbh       = $_[0];
  my $user_id   = $_[1];
  my $log_level = $_[2];
  my $log_msg   = $_[3];

  my $cur_dt = DateTime->now( time_zone => $TIMEZONE );
  $cur_dt = DateTime::Format::MySQL->format_datetime($cur_dt);

  my $sql = '';
  $sql   .= 'INSERT INTO activitylog SET ';
  $sql   .= 'UserId=?, ';
  $sql   .= 'ActivityDateTime=?, ';
  $sql   .= 'ActivityLevel=?, ';
  $sql   .= 'ActivityText=?';

  my $sth = $dbh->prepare($sql);
  $sth->execute($user_id, $cur_dt, $log_level, $log_msg);
  my $err = $dbh->err();
  $sth->finish();

  return $err;
}

sub validate_trait_db {

  my $dbh         = $_[0];
  my $trait_id    = $_[1];
  my $trait_value = $_[2];

  my $sql = '';
  $sql   .= 'SELECT TraitValRule, TraitValRuleErrMsg ';
  $sql   .= 'FROM trait ';
  $sql   .= 'WHERE TraitId=?';

  my $sth = $dbh->prepare($sql);
  $sth->execute($trait_id);

  my $validation_rule    = '';
  my $validation_err_msg = '';
  $sth->bind_col(1, \$validation_rule);
  $sth->bind_col(2, \$validation_err_msg);
  $sth->fetch();
  $sth->finish();

  my $err     = 0;
  my $err_msg = '';

  # should it '[^<>=]=' => '=='
  my $operator_lookup = { 'AND'    => '&&',
                          'OR'     => '||',
                          '[^<>]=' => '==',
  };

  if ($validation_rule =~ /(\w+)\((.*)\)/) {

    my $validation_rule_prefix = $1;
    my $validation_rule_body   = $2;

    if (uc($validation_rule_prefix) eq 'REGEX') {

      if (!($trait_value =~ /$validation_rule_body/)) {

        $err = 1;
        $err_msg = $validation_err_msg;
      }
    }
    elsif (uc($validation_rule_prefix) eq 'BOOLEX') {

      if ($validation_rule_body !~ /x/) {

        $err = 1;
        $err_msg = 'No variable x in boolean expression.';
      }
      elsif ( ($validation_rule_body =~ /\&/) ||
                ($validation_rule_body =~ /\|/) ) {

        $err = 1;
        $err_msg = 'Contain forbidden characters';
      }
      elsif ( $validation_rule_body =~ /\d+\.?\d*\s*,/) {

        $err = 1;
        $err_msg = 'Contain a comma - invalid boolean expression';
      }
      else {

        if ($trait_value =~ /^[-+]?\d+\.?\d*$/) {

          $validation_rule_body =~ s/x/ $trait_value /ig;
        }
        else {

          $validation_rule_body =~ s/x/ '$trait_value' /ig;
        }

        for my $operator (keys(%{$operator_lookup})) {

          my $perl_operator = $operator_lookup->{$operator};
          $validation_rule_body =~ s/$operator/$perl_operator/ig;
        }

        my $test_condition;

        eval(q{$test_condition = } . qq{($validation_rule_body) ? 1 : 0;});

        if($@) {

          $err = 1;
          $err_msg = "Invalid boolean trait value validation expression ($validation_rule_body).";
        }
        else {

          if ($test_condition == 0) {

            $err = 1;
            $err_msg = $validation_err_msg;
          }
          else {

            $err = 0;
            $err_msg = '';
          }
        }
      }
    }
    elsif (uc($validation_rule_prefix) eq 'CHOICE') {

      if ($validation_rule_body =~ /^\[.*\]$/) {

        $err = 1;
        $err_msg = 'Invalid choice expression containing [].';
      }
      else {

        my @choice_list = split(/\|/, $validation_rule_body);

        $err     = 1;
        $err_msg = $validation_err_msg;

        foreach my $choice (@choice_list) {

          if (lc("$choice") eq lc("$trait_value")) {

            $err = 0;
            $err_msg = '';
            last;
          }
        }
      }
    }
    elsif ( (uc($validation_rule_prefix) eq 'DATE_RANGE') ) {

      if ($trait_value !~ /^\d{4}\-\d{2}\-\d{2}( \d{2}\:\d{2}\:\d{2})?$/) {

        $err     = 1;
        $err_msg = 'Invalid date';
      }
    }
    elsif ( (uc($validation_rule_prefix) eq 'RANGE')   ||
            (uc($validation_rule_prefix) eq 'LERANGE') ||
            (uc($validation_rule_prefix) eq 'RERANGE') ||
            (uc($validation_rule_prefix) eq 'BERANGE') ) {

      if ($validation_rule_body !~ /^[-+]?\d+\.?\d*\s*\.\.\s*[-+]?\d+\.?\d*$/) {

        $err     = 1;
        $err_msg = 'Invalid range expression';
      }
      else {

        $err     = 1;
        $err_msg = $validation_err_msg;

        if ($trait_value =~ /^[-+]?\d+\.?\d*$/) {

          my ($left_val, $right_val) = split(/\s*\.\.\s*/, $validation_rule_body);

          if (uc($validation_rule_prefix) eq 'RANGE') {

            if ($trait_value >= $left_val && $trait_value <= $right_val) {

              $err = 0;
              $err_msg = '';
            }
          }
          elsif (uc($validation_rule_prefix) eq 'LERANGE') {

            if ($trait_value > $left_val && $trait_value <= $right_val) {

              $err = 0;
              $err_msg = '';
            }
          }
          elsif (uc($validation_rule_prefix) eq 'RERANGE') {

            if ($trait_value >= $left_val && $trait_value < $right_val) {

              $err = 0;
              $err_msg = '';
            }
          }
          elsif (uc($validation_rule_prefix) eq 'BERANGE') {

            if ($trait_value > $left_val && $trait_value < $right_val) {

              $err = 0;
              $err_msg = '';
            }
          }
        }
        else {

          $err = 1;
          $err_msg = "Trait value ($trait_value) not a valid number";
        }
      }
    }
    else {

      $err = 1;
      $err_msg = 'Unknown trait value validation rule.';
    }
  }
  else {

    $err = 1;
    $err_msg = 'Unknown validation rule.';
  }

  return ($err, $err_msg);
}

sub is_correct_validation_rule {

  my $validation_rule = $_[0];

  my $dummy_trait_val = '0';

  my $correct = 1;
  my $msg     = '';

  # should it '[^<>=]=' => '=='
  my $operator_lookup = { 'AND'    => '&&',
                          'OR'     => '||',
                          '[^<>]=' => '==',
  };

  if ($validation_rule =~ /(\w+)\((.*)\)/) {

    my $validation_rule_prefix = $1;
    my $validation_rule_body   = $2;

    if (uc($validation_rule_prefix) eq 'BOOLEX') {

      if ($validation_rule_body !~ /x/) {

        $correct = 0;
        $msg     = 'No variable x in boolean expression.';
      }
      elsif ( ($validation_rule_body =~ /\&/) ||
                ($validation_rule_body =~ /\|/) ) {

        $correct = 0;
        $msg     = 'Contain forbidden characters';
      }
      elsif ( $validation_rule_body =~ /\d+\.?\d*\s*,/) {

        $correct = 0;
        $msg     = 'Contain a comma - invalid boolean expression';
      }
      else {

        $validation_rule_body =~ s/x/ $dummy_trait_val /ig;

        for my $operator (keys(%{$operator_lookup})) {

          my $perl_operator = $operator_lookup->{$operator};
          $validation_rule_body =~ s/$operator/$perl_operator/ig;
        }

        my $test_condition;

        eval(q{$test_condition = } . qq{($validation_rule_body) ? 1 : 0;});

        if($@) {

          $correct = 0;
          $msg     = 'Invalid boolean expression.';
        }
      }
    }
    elsif (uc($validation_rule_prefix) eq 'REGEX') {

      eval(qq{'x' =~ /$validation_rule_body/;});

      if($@) {

        $correct = 0;
        $msg     = 'Invalid regular expression.';
      }
    }
    elsif (uc($validation_rule_prefix) eq 'CHOICE') {

      if ($validation_rule_body =~ /^\[.*\]$/) {

        $correct = 0;
        $msg     = 'Invalid choice expression containing [].';
      }
    }
    elsif ( (uc($validation_rule_prefix) eq 'DATE_RANGE') ) {

      # No need to validate further
      $correct = 1;
    }
    elsif ( (uc($validation_rule_prefix) eq 'RANGE')   ||
            (uc($validation_rule_prefix) eq 'LERANGE') ||
            (uc($validation_rule_prefix) eq 'RERANGE') ||
            (uc($validation_rule_prefix) eq 'BERANGE') ) {

      warn("Validation rule body: $validation_rule_body");

      if ($validation_rule_body !~ /^[-+]?\d+\.?\d*\s*\.\.\s*[-+]?\d+\.?\d*$/) {

        $correct = 0;
        $msg     = 'Invalid range expression';
      }
      else {

        if ($validation_rule_body =~ /\.{3,}/) {

          $correct = 0;
          $msg = 'Invalid range expression (more than 2 consecutive dot characters).';
        }
      }
    }
    else {

      $correct = 0;
      $msg     = 'Unknown validation rule.';
    }
  }
  else {

    $correct = 0;
    $msg     = 'Invalid validation rule.';
  }

  return ($correct, $msg);
}

sub parse_selected_field {

  my $field_list_csv   = $_[0];
  my $field_list_all   = $_[1];
  my $id_field_name    = $_[2];

  my $field_href = {};

  for my $field (@{$field_list_all}) {

    $field_href->{$field} = 1;
  }

  my @sel_field = split(/,/, $field_list_csv);

  my $final_field_list = [];

  my $err     = 0;
  my $err_msg = '';

  my $seen_field_lookup = {};

  my $id_field_selected = 0;

  for my $field (@sel_field) {

    $field = trim($field);
    if (length($field) == 0) {

      next;
    }

    if ($field_href->{'*'}) {

      next;
    }

    if ($field_href->{$field}) {

      if ($field eq $id_field_name) {

        $id_field_selected = 1;
      }

      if (!($seen_field_lookup->{$field})) {

        push(@{$final_field_list}, "$field");
        $seen_field_lookup->{$field} = 1;
      }
    }
    else {

      $err     = 1;
      $err_msg = "$field unknown.";
      last;
    }
  }

  if (scalar(@{$final_field_list}) == 0) {

    push(@{$final_field_list}, '*');
  }
  else {

    if (!$id_field_selected) {

      if (length($id_field_name) > 0) {

        push(@{$final_field_list}, "$id_field_name");
      }
    }
  }

  return ($err, $err_msg, $final_field_list);
}

sub parse_marker_filtering {

  my $field_idx_lookup_href  = $_[0];
  my $fieldlist_aref         = $_[1];
  my $filtering_csv          = $_[2];

  my $err      = 0;
  my $err_msg  = '';
  my $perl_exp = '';

  my $field_href = {};

  for my $field (@{$fieldlist_aref}) {

    $field_href->{$field} = 1;
  }

  my @filtering_exp = split(/&/, $filtering_csv);

  my $seen_expression_lookup = {};

  for my $expression (@filtering_exp) {

    $expression = trim($expression);
    if (length($expression) == 0) {

      next;
    }

    my $operator         = '';
    my $field_name       = '';
    my $is_quote_arg_val = 0;

    if ($expression =~ /^(\w+)\s*([>|<])\s*[-+]?(\d+\.?\d*)$/) {

      $field_name       = $1;
      $operator         = $2;
    }
    elsif ($expression =~ /^(\w+)\s*(\!=)\s*[-+]?(\d+\.?\d*)$/) {

      $field_name       = $1;
      $operator         = $2;
    }
    elsif ($expression =~ /^(\w+)\s*([=|>|<]=)\s*[-+]?(\d+\.?\d*)$/) {

      $field_name       = $1;
      $operator         = $2;
    }
    # string field using single quote
    elsif ($expression =~ /^(\w+)\s+(eq)\s+'[^']*'$/i) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }
    elsif ($expression =~ /^(\w+)\s+(ne)\s+'[^']*'$/i) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }
    elsif ($expression =~ /^(\w*)\s*(=\~)\s*\/.*\/i?$/i) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }
    elsif ($expression =~ /^(\w+)\s*(\!\~)\s*\/.*\/i?$/i) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }

    if (length($operator) > 0) {

      my ($empty, $field_value) = split(/$field_name\s*$operator/, $expression);

      $field_name  = trim($field_name);
      $field_value = trim($field_value);

      if (length($field_value) > 0) {

        my $test_dummy_var;

        my $test_perl_exp = "\$test_dummy_var $operator $field_value";

        eval($test_perl_exp);

        if ($@) {

          $err = 1;
          $err_msg = "$test_perl_exp : $@";
          last;
        }

        my $col_num = $field_idx_lookup_href->{$field_name};

        my $new_exp = "\$COL[$col_num] $operator $field_value";

        if (!(defined($field_href->{$field_name}))) {

          $err     = 1;
          $err_msg = "Filtering field ($field_name) unknown.";
          last;
        }

        if (!$seen_expression_lookup->{$new_exp}) {

          $seen_expression_lookup->{$new_exp} = 1;
        }
      }
      else {

        $err = 1;
        $err_msg = "Field value empty";
        last;
      }
    }
    else {

      $err     = 1;
      $err_msg = "( $expression ): invalid filtering expression.";
      last;
    }
  }

  if (!$err) {

    $perl_exp = join(' && ', keys(%{$seen_expression_lookup}));
  }

  return ($err, $err_msg, $perl_exp);
}

sub parse_sorting {

  my $sorting_csv      = $_[0];
  my $field_list_all   = $_[1];

  my $table_name       = '';

  if (defined $_[2]) {

    $table_name = $_[2] . '.';
  }

  my $field_href = {};

  for my $field (@{$field_list_all}) {

    $field =~ s/"//g;

    if ($field =~ /ST_AsText\((.+)\)/) {

      my $geo_field = $1;
      $field_href->{$geo_field}     = 1;
    }
    else {

      $field_href->{$field} = 1;
    }
  }

  my $err     = 0;
  my $err_msg = '';

  my @sort_exp = split(/,/, $sorting_csv);

  my $sort_list = [];
  my $seen_sort_expression = {};

  for my $expression (@sort_exp) {

    $expression = trim($expression);
    if (length($expression) == 0) {

      next;
    }

    if ($expression =~ /(\w+)\s+(ASC|DESC)/i) {

      my ($field_name, $sort_order) = split(/\s+/, $expression);

      $field_name = trim($field_name);
      $sort_order = uc(trim($sort_order));

      if ($field_name eq 'Longitude' || $field_name eq 'Latitude' || $field_name =~ /location/) {

        $err = 1;
        $err_msg = "Field ($field_name) cannot be used for sorting.";
        last;
      }

      my $new_exp = '';

      if ($table_name =~ /\"/) {

        $new_exp = qq|${table_name}"$field_name" $sort_order|;
      }
      else {

        $new_exp = "${table_name}$field_name $sort_order";
      }

      if (!$seen_sort_expression->{$new_exp}) {

        $seen_sort_expression->{$new_exp} = 1;
        if (length($field_href->{$field_name}) > 0) {

          push(@{$sort_list}, $new_exp);
        }
        else {

          $err     = 1;
          $err_msg = "Field ($field_name) unknown.";
        }
      }
    }
    elsif ($expression =~ /(\w+)\s+(NASC|NDESC)/i) {

      my ($field_name, $sort_order) = split(/\s+/, $expression);

      $field_name = trim($field_name);
      $sort_order = uc(trim($sort_order));

      $sort_order =~ s/^N//;

      if ($field_name eq 'Longitude' || $field_name eq 'Latitude' || $field_name =~ /location/) {

        $err = 1;
        $err_msg = "Field ($field_name) cannot be used for sorting.";
        last;
      }

      my $new_exp = '';

      if ($table_name =~ /\"/) {

        $new_exp = qq|LENGTH(${table_name}"$field_name") $sort_order, ${table_name}"$field_name" $sort_order|;
      }
      else {

        $new_exp = "LENGTH(${table_name}$field_name) $sort_order, ${table_name}$field_name $sort_order";
      }

      if (!$seen_sort_expression->{$new_exp}) {

        $seen_sort_expression->{$new_exp} = 1;
        if (length($field_href->{$field_name}) > 0) {

          push(@{$sort_list}, $new_exp);
        }
        else {

          $err     = 1;
          $err_msg = "Field ($field_name) unknown.";
        }
      }
    }
    else {

      $err     = 1;
      $err_msg = "Expression ($expression) invalid.";
    }
  }

  my $sql_exp = join(',', @{$sort_list});

  return ($err, $err_msg, $sql_exp);
}

sub parse_marker_sorting {

  my $sorting_csv       = $_[0];
  my $field2col_lookup  = $_[1];

  my $err     = 0;
  my $err_msg = '';

  my @sort_exp = split(/,/, $sorting_csv);

  my $sort_function_text = '';

  my $sort_list            = [];
  my $seen_sort_expression = {};

  for my $expression (@sort_exp) {

    $expression = trim($expression);
    if (length($expression) == 0) {

      next;
    }

    if ($expression =~ /(\w+)\s+(ASC|DESC)/i) {

      my ($field_name, $sort_order) = split(/\s+/, $expression);

      $field_name = trim($field_name);
      $sort_order = uc(trim($sort_order));

      my $new_exp = "$field_name $sort_order";

      if (!$seen_sort_expression->{$new_exp}) {

        $seen_sort_expression->{$new_exp} = 1;

        if (defined $field2col_lookup->{$field_name}) {

          push(@{$sort_list}, {'FieldName' => $field_name, 'Order' => $sort_order});
        }
        else {

          $err     = 1;
          $err_msg = "Field ($field_name) unknown.";

          return ($err, $err_msg, []);
        }
      }
    }
    else {

      $err     = 1;
      $err_msg = "Expression ($expression) invalid.";

      return ($err, $err_msg, []);
    }
  }

  return ($err, $err_msg, $sort_list);
}

sub get_sorting_function {

  my $sort_aref         = $_[0];
  my $field2col_lookup  = $_[1];
  my $data_2sort_aref   = $_[2];

  my $field2numeric_lookup = {};

  my $log_msg = '';

  for my $field_name (keys(%{$field2col_lookup})) {

    my $data_index = $field2col_lookup->{$field_name};

    my $is_numeric = 1;

    for (my $i = 0; $i < scalar(@{$data_2sort_aref}); $i++) {

      my $data_point = $data_2sort_aref->[$i]->[$data_index];

      if ($data_point !~ /^[-|+]?\d+\.?\d+$/ && $data_point !~ /^\d+$/) {

        $log_msg .= "field: $field_name data index: $data_index - data_aref [ $i ]: ";
        $log_msg .= $data_point . " is not numeric.\n";

        $is_numeric = 0;
        last;
      }
    }

    $field2numeric_lookup->{$field_name} = $is_numeric;
  }

  my @sort_func_list;

  for my $sort_href (@{$sort_aref}) {

    my $field_name = $sort_href->{'FieldName'};
    my $sort_order = $sort_href->{'Order'};
    my $col_num    = $field2col_lookup->{$field_name};

    my $sort_oper = 'cmp';

    if ($field2numeric_lookup->{$field_name}) {

      $sort_oper = '<=>';
    }

    my $sort_func_txt = '';

    if (uc($sort_order) eq 'ASC') {

      $sort_func_txt = qq|\$a\-\>\[$col_num\] $sort_oper \$b\-\>\[$col_num\]|;
    }
    else {

      $sort_func_txt = qq|\$b\-\>\[$col_num\] $sort_oper \$a\-\>\[$col_num\]|;
    }

    push(@sort_func_list, $sort_func_txt);
  }

  my $sort_function_text = join(' || ', @sort_func_list);

  return ($sort_function_text, $log_msg);
}

sub update_vcol_data {

  my $dbh               = $_[0];
  my $vcol_info         = $_[1];
  my $vcol_data         = $_[2];
  my $factor_table_name = $_[3];
  my $id_field_name     = $_[4];
  my $record_id         = $_[5];

  my $dbh_k_write = $dbh;

  my $err = 0;
  my $err_msg = '';
  my $sql = '';

  for my $vcol_id (keys(%{$vcol_info})) {

    if (defined $vcol_data->{'VCol_' . "$vcol_id"}) {

      my $factor_value = $vcol_data->{'VCol_' . "$vcol_id"};

      $sql  = "SELECT Count(*) ";
      $sql .= "FROM $factor_table_name ";
      $sql .= "WHERE $id_field_name =? AND FactorId=?";

      my ($read_err, $count) = read_cell($dbh_k_write, $sql, [$record_id, $vcol_id]);

      if (length($factor_value) > 0) {

        if ($count > 0) {

          $sql  = "UPDATE $factor_table_name SET ";
          $sql .= "FactorValue=? ";
          $sql .= "WHERE $id_field_name =? AND FactorId=?";
          my $factor_sth = $dbh_k_write->prepare($sql);
          $factor_sth->execute($factor_value, $record_id, $vcol_id);

          if ($dbh_k_write->err()) {

            $err = 1;
            $err_msg = 'Database error';
            last;
          }
          $factor_sth->finish();
        }
        else {

          $sql  = "INSERT INTO $factor_table_name SET ";
          $sql .= "$id_field_name =?, ";
          $sql .= "FactorId=?, ";
          $sql .= "FactorValue=?";
          my $factor_sth = $dbh_k_write->prepare($sql);
          $factor_sth->execute($record_id, $vcol_id, $factor_value);

          if ($dbh_k_write->err()) {

            $err = 1;
            $err_msg = 'Database error';
            last;
          }

          $factor_sth->finish();
        }
      }
      else {

        if ($count > 0) {

          $sql  = "DELETE FROM $factor_table_name ";
          $sql .= "WHERE $id_field_name =? AND FactorId=?";

          my $factor_sth = $dbh_k_write->prepare($sql);
          $factor_sth->execute($record_id, $vcol_id);

          if ($dbh_k_write->err()) {

            $err = 1;
            $err_msg = 'Database error';
            last;
          }
          $factor_sth->finish();
        }
      }
    }
  }

  $dbh_k_write->disconnect();

  return ($err, $err_msg);
}

sub WKT2geoJSON {

  my $wkt = $_[0];

  my $geom = {};
  if ($wkt =~ /^POLYGON/) {

    $geom->{type} = "Polygon";
    $wkt =~ s/POLYGON//og;
    $wkt =~ s/\)/\]/og;
    $wkt =~ s/\(/\[/og;
    $wkt =~ s/(-?\d+(?:\.\d+)?)\s(-?\d+(?:\.\d+)?)/ [$1, $2]/og;
    $geom->{'coordinates'} = eval($wkt);
  }
  elsif ($wkt =~ /^MULTIPOLYGON/) {

    $geom->{type} = "MultiPolygon";
    $wkt =~ s/MULTIPOLYGON//og;
    $wkt =~ s/\)/\]/og;
    $wkt =~ s/\(/\[/og;
    $wkt =~ s/(-?\d+(?:\.\d+)?)\s(-?\d+(?:\.\d+)?)/ [$1, $2]/og;
    $geom->{'coordinates'} = eval($wkt);
  }
  elsif ($wkt =~ /^POINT/) {

    $geom->{type} = "Point";
    $wkt =~ s/POINT//og;
    $wkt =~ s/\)/\]/og;
    $wkt =~ s/\(/\[/og;
    $wkt =~ s/(-?\d+(?:\.\d+)?)\s(-?\d+(?:\.\d+)?)/ $1, $2/og;
    $geom->{'coordinates'} = eval($wkt);
  }
  elsif ($wkt =~ /^MULTIPOINT/) {

    $geom->{type} = "MultiPoint";
    $wkt =~ s/MULTIPOINT//og;
    $wkt =~ s/\)/\]/og;
    $wkt =~ s/\(/\[/og;
    $wkt =~ s/(-?\d+(?:\.\d+)?)\s(-?\d+(?:\.\d+)?)/ $1, $2/og;
    $geom->{'coordinates'} = eval($wkt);
  }
  elsif ($wkt =~ /^GEOMETRYCOLLECTION\(POINT/) {

    $geom->{type} = "Point";
    $wkt =~ s/GEOMETRYCOLLECTION\(POINT//og;
    $wkt =~ s/\)$//;
    $wkt =~ s/\)/\]/og;
    $wkt =~ s/\(/\[/og;
    $wkt =~ s/(-?\d+(?:\.\d+)?)\s(-?\d+(?:\.\d+)?)/ $1, $2/og;
    $geom->{'coordinates'} = eval($wkt);
  }

  return $geom;
}

sub samplemeasure_row2col {

  # This function converts trait data samplemeasurement from row into column using trait name from trait table
  # as the name of the column.

  my $dbh            = $_[0];
  my $trial_id       = $_[1];
  my $sample_type_id = $_[2];

  my $trait_id_aref  = [];

  if (defined $_[3]) {

    $trait_id_aref = $_[3];
  }

  my $instance_num_aref = [];

  if (defined $_[4]) {

    $instance_num_aref = $_[4];
  }

  my $err            = 0;
  my $err_msg        = '';

  my $trait_where    = '';
  my $tt_trait_where = '';

  if (scalar(@{$trait_id_aref}) > 0) {

    $trait_where    = ' AND TraitId IN (' . join(',', @{$trait_id_aref}) . ')';
    $tt_trait_where = ' AND trialtrait.TraitId IN (' . join(',', @{$trait_id_aref}) . ')';
  }

  my $sql = "SELECT samplemeasurement.InstanceNumber ";
  $sql   .= "FROM samplemeasurement LEFT JOIN trialunit ON ";
  $sql   .= "samplemeasurement.TrialUnitId = trialunit.TrialUnitId ";
  $sql   .= "WHERE TrialId=? AND SampleTypeId=? $trait_where ";
  $sql   .= "ORDER BY InstanceNumber DESC LIMIT 1";

  my ($max_inst_err, $max_instance_num) = read_cell($dbh, $sql, [$trial_id, $sample_type_id]);

  if ($max_inst_err) {

    $err = 1;
    $err_msg = "Unexpected error: $sql";

    return ($err, $err_msg, '', [], -1);
  }

  if (length($max_instance_num) == 0) {

    $err = 1;
    $err_msg = 'No samplemeasurement record matched.';

    return ($err, $err_msg, '', [], -1);
  }

  $sql    = "SELECT trialtrait.TraitId, trait.TraitName ";
  $sql   .= "FROM trialtrait LEFT JOIN trait ON trialtrait.TraitId = trait.TraitId ";
  $sql   .= "WHERE TrialId=? $tt_trait_where ";
  $sql   .= "ORDER BY TrialTraitId DESC";

  my ($read_trait_err, $read_trait_msg, $trait_aref) = read_data($dbh, $sql, [$trial_id]);

  if ($read_trait_err) {

    $err = 1;
    $err_msg = "Unexpected error: $sql";

    return ($err, $err_msg, '', [], -1);
  }

  if (scalar(@{$trait_aref}) == 0) {

    $err = 1;
    $err_msg = "No trialtrait record matched.";

    return ($err, $err_msg, '', [], -1);
  }

  my $return_sql       = 'SELECT samplemeasurement.TrialUnitId, systemuser.UserName, ';
  my $field_order_aref = [];

  my @sub_sql_list;

  my $inst_num_aref = [];

  if (scalar(@{$instance_num_aref}) > 0) {

    $inst_num_aref = $instance_num_aref;
  }
  else {

    for (my $i = 0; $i <= $max_instance_num; $i++) {

      push(@{$inst_num_aref}, $i);
    }
  }

  for my $trait_rec (@{$trait_aref}) {

    my $trait_name = $trait_rec->{'TraitName'};
    my $trait_id   = $trait_rec->{'TraitId'};

    for my $inst_num (@{$inst_num_aref}) {

      my $trait_val_field_name = '';
      my $date_field_name      = '';
      my $hum_inst_num         = $inst_num;

      # this means that there is only one instance, because instance number start from 0
      if ($max_instance_num == 0) {

        $trait_val_field_name = $trait_name;
        $date_field_name      = "Date_${trait_name}";
      }
      else {

        $trait_val_field_name = "${trait_name}__$hum_inst_num";;
        $date_field_name      = "Date_${trait_name}__$hum_inst_num";
      }

      my $chk_inst_num_sql = 'SELECT samplemeasurement.TrialUnitId ';
      $chk_inst_num_sql   .= 'FROM samplemeasurement LEFT JOIN trialunit ';
      $chk_inst_num_sql   .= 'ON samplemeasurement.TrialUnitId = trialunit.TrialUnitId ';
      $chk_inst_num_sql   .= 'WHERE TrialId=? AND TraitId=? AND SampleTypeId=? AND InstanceNumber=? ';
      $chk_inst_num_sql   .= 'LIMIT 1';

      my ($read_chk_inst_num_err, $found_trial_unit_id) = read_cell($dbh, $chk_inst_num_sql,
                                                                    [$trial_id, $trait_id, $sample_type_id, $inst_num]);

      if ($read_chk_inst_num_err) {

        $err = 1;
        $err_msg = "Unexpected error: checking instance number.";

        return ($err, $err_msg, '', [], -1);
      }

      # The instance number has no data
      if (length($found_trial_unit_id) == 0) { next; }

      my $sub_sql = qq| GROUP_CONCAT( IF(TraitId = $trait_id, IF(InstanceNumber = $inst_num, TraitValue , NULL) , NULL) SEPARATOR '' ) |;
      $sub_sql   .= qq|AS \`${trait_val_field_name}\` |;

      push(@sub_sql_list, $sub_sql);
      push(@{$field_order_aref}, $trait_val_field_name);

      $sub_sql    = qq| GROUP_CONCAT( IF(TraitId = $trait_id, IF(InstanceNumber = $inst_num, MeasureDateTime, NULL) , NULL) SEPARATOR '' ) |;
      $sub_sql   .= qq|AS \`${date_field_name}\` |;

      push(@sub_sql_list, $sub_sql);
      push(@{$field_order_aref}, $date_field_name);
    }
  }

  $return_sql .= join(',', @sub_sql_list);
  $return_sql .= ' FROM (samplemeasurement LEFT JOIN trialunit ON samplemeasurement.TrialUnitId = trialunit.TrialUnitId) ';
  $return_sql .= ' LEFT JOIN systemuser ON samplemeasurement.OperatorId = systemuser.UserId ';
  $return_sql .= ' WHERE TrialId=? AND SampleTypeId=? ';
  $return_sql .= ' GROUP BY samplemeasurement.TrialUnitId ';
  $return_sql .= ' ORDER BY samplemeasurement.TrialUnitId';

  $max_instance_num += 1; # it starts from zero

  return ($err, $err_msg, $return_sql, $field_order_aref, $max_instance_num);
}

sub rollback_cleanup_multi {

  # This method takes a hash reference for the records to delete in the following format.
  # $inserted_id->{'table_name'} = { 'IdField' => 'actual id field name',
  #                                  'IdValue' => [id val 1, id val 2, ... ] }

  my $logger      = $_[0];
  my $dbh         = $_[1];
  my $inserted_id = $_[2];

  my $err     = 0;
  my $err_msg = q{};

  my $driver_name = lc($dbh->{'Driver'}->{'Name'});

  for my $table_name (keys(%{$inserted_id})) {

    my $field_info  = $inserted_id->{$table_name};
    my $id_field    = $field_info->{'IdField'};
    my $id_val_aref = $field_info->{'IdValue'};

    if (scalar(@{$id_val_aref}) == 0) {

      $err     = 1;
      $err_msg = qq{No IdValue for field $id_field in $table_name.};

      $logger->debug($err_msg);

      return ($err, $err_msg);
    }

    my $id_val_csv = join(',', @{$id_val_aref});

    $logger->debug("Deleting ($id_field, $id_val_csv) from $table_name");

    my $sql = '';

    if ($driver_name eq 'monetdb') {

      $sql  = qq|DELETE FROM "$table_name" |;
      $sql .= qq|WHERE "$id_field" IN ($id_val_csv)|;
    }
    else {

      $sql  = "DELETE FROM $table_name ";
      $sql .= "WHERE $id_field IN ($id_val_csv)";
    }

    $logger->debug("DELETE SQL: $sql");

    my $sth = $dbh->prepare($sql);
    $sth->execute();

    if ($dbh->err()) {

      $err_msg = $dbh->errstr();
      $err = 1;
      last;
    }

    $sth->finish();
  }

  return ($err, $err_msg);
}

sub write_aref2csv {

  my $fh               = $_[0];
  my $field_order_href = $_[1];
  my $eol              = $_[2];
  my $data_aref        = $_[3];

  my $print_header     = 0;

  if (defined($_[4])) {

    $print_header = $_[4];
  }

  my $csv = Text::CSV->new ( { binary => 1 } )  # should set binary attribute.
      or die "Cannot use CSV: ".Text::CSV->error_diag ();
  $csv->eol($eol);

  my @field_list;
  my @unorder_field_list;

  for my $field (keys(%{$data_aref->[0]})) {

    if (defined $field_order_href->{$field}) {

      push(@unorder_field_list, [$field, $field_order_href->{$field}]);
    }
    else {

      push(@unorder_field_list, [$field, 999999]);
    }
  }

  my @order_field_list = sort { $a->[1] <=> $b->[1] } @unorder_field_list;

  for my $tuple (@order_field_list) {

    push(@field_list, $tuple->[0]);
  }

  if ($print_header) {

    if (scalar(@field_list) > 0) {

      my @header_field_list = @field_list;
      $csv->print($fh, \@header_field_list);
    }
  }

  for my $record (@{$data_aref}) {

    my @row;
    for my $field (@field_list) {

      push(@row, $record->{$field});
    }
    $csv->print($fh, \@row);
  }
}

sub write_href2csv {

  my $fh               = $_[0];
  my $field_order_href = $_[1];
  my $eol              = $_[2];
  my $data_href        = $_[3];

  my $csv = Text::CSV->new ( { binary => 1 } )  # should set binary attribute.
      or die "Cannot use CSV: ".Text::CSV->error_diag ();
  $csv->eol($eol);

  my @field_list;
  my @unorder_field_list;

  my @master_key = keys(%{$data_href});

  for my $field (keys(%{$data_href->{$master_key[0]}})) {

    if (defined $field_order_href->{$field}) {

      push(@unorder_field_list, [$field, $field_order_href->{$field}]);
    }
    else {

      push(@unorder_field_list, [$field, 999999]);
    }
  }

  my @order_field_list = sort { $a->[1] <=> $b->[1] } @unorder_field_list;

  for my $tuple (@order_field_list) {

    push(@field_list, $tuple->[0]);
  }

  if (scalar(@field_list) > 0) {

    my @header_field_list = @field_list;
    $csv->print($fh, \@header_field_list);
  }

  for my $k (sort(keys(%{$data_href}))) {

    my $record = $data_href->{$k};
    my @row;
    for my $field (@field_list) {

      push(@row, $record->{$field});
    }
    $csv->print($fh, \@row);
  }
}

sub get_static_field {

  my $dbh   = $_[0];
  my $tname = $_[1];

  my $driver_name = $dbh->{'Driver'}->{'Name'};

  if (lc($driver_name) eq 'monetdb') {

    my $sql = qq|SELECT name AS column_name, type as column_data_type, type_digits, |;
    $sql   .= qq|"null" as nullable, "default" |;
    $sql   .= qq|FROM "sys"."columns" |;
    $sql   .= qq|WHERE table_id = (SELECT id AS table_id FROM "sys"."tables" WHERE name = '$tname')|;

    my $sth = $dbh->prepare($sql);
    $sth->execute();

    my $err        = 0;
    my $msg        = '';
    my $field_data = [];
    my $pkey_data  = [];

    if ($dbh->err()) {

      $err = 1;
      $msg = $dbh->errstr();
      return ($err, $msg, $field_data, $pkey_data);
    }

    my $col_info_aref = $sth->fetchall_arrayref({});

    if ($sth->err()) {

      $err = 1;
      $msg = $dbh->errstr();
      return ($err, $msg, $field_data, $pkey_data);
    }

    if (scalar(@{$col_info_aref}) == 0) {

      $err = 1;
      $msg = 'Table not found';
      return ($err, $msg, $field_data, $pkey_data);
    }

    $sql  = qq|SELECT "FieldName", "PrimaryKey", "FieldComment" |;
    $sql .= qq|FROM fieldcomment |;
    $sql .= qq|WHERE "TableName" = '$tname'|;

    $sth = $dbh->prepare($sql);
    $sth->execute();

    if ($dbh->err()) {

      $err = 1;
      $msg = $dbh->errstr();
      return ($err, $msg, $field_data, $pkey_data);
    }

    my $col_info_lookup = $sth->fetchall_hashref('FieldName');

    if ($sth->err()) {

      $err = 1;
      $msg = $dbh->errstr();
      return ($err, $msg, $field_data, $pkey_data);
    }

    for my $col_info (@{$col_info_aref}) {

      my $field_name    = $col_info->{"column_name"};
      my $dtype_name    = $col_info->{"column_data_type"};
      my $col_size      = $col_info->{"type_digits"};
      my $field_comment = $col_info_lookup->{$field_name}->{'FieldComment'};

      if (defined($col_info_lookup->{$field_name}->{'PrimaryKey'})) {

        if ($col_info_lookup->{$field_name}->{'PrimaryKey'} eq '1') {

          push(@{$pkey_data}, $field_name);
        }
      }

      my $required_status;

      if ($col_info->{'nullable'} eq 'true') {

        $required_status = 0;
      }
      else {

        $required_status = 1;
      }

      if (defined($col_info->{'default'})) {

        if ($col_info->{'default'} =~ /next value for/) {

          # it's an auto number
          $required_status = 0;
        }
      }

      my $static_field = {};

      $static_field->{'Name'}        = $field_name;
      $static_field->{'Required'}    = $required_status;
      $static_field->{'DataType'}    = $dtype_name;
      $static_field->{'ColSize'}     = $col_size;
      $static_field->{'Description'} = $field_comment;

      push(@{$field_data}, $static_field);
    }

    return ($err, $msg, $field_data, $pkey_data);
  }
  else {

    my $sql   = "SELECT * FROM $tname LIMIT 1";

    my $sth = $dbh->prepare($sql);
    $sth->execute();

    my $err        = 0;
    my $msg        = '';
    my $field_data = [];
    my $pkey_data  = [];

    if ($dbh->err()) {

      $err = 1;
      $msg = $dbh->errstr();
      return ($err, $msg, $field_data, $pkey_data);
    }

    my @primary_key_names = $dbh->primary_key( undef, undef, $tname );

    my $static_field_aref = [];
    my $nfield = $sth->{'NUM_OF_FIELDS'};

    my $comment_lookup_href = {};

    if (lc($driver_name) eq 'pg') {

      my $comment_sql = 'SELECT c.table_name, c.column_name, pgd.description ';
      $comment_sql   .= 'FROM pg_catalog.pg_statio_all_tables AS st ';
      $comment_sql   .= 'INNER JOIN pg_catalog.pg_description pgd on (pgd.objoid=st.relid) ';
      $comment_sql   .= 'INNER JOIN information_schema.columns c on (pgd.objsubid=c.ordinal_position ';
      $comment_sql   .= 'AND c.table_schema=st.schemaname AND c.table_name=st.relname) ';
      $comment_sql   .= "WHERE c.table_name = '$tname'";

      $comment_lookup_href = $dbh->selectall_hashref($comment_sql, 'column_name');
    }
    else {

      my $comment_sql = "SHOW FULL COLUMNS IN $tname";

      $comment_lookup_href = $dbh->selectall_hashref($comment_sql, 'Field');
    }

    for (my $i = 0; $i < $nfield; $i++ ) {

      my $field_name = $sth->{'NAME'}->[$i];

      if (scalar(@primary_key_names) == 1) {

        if ($field_name eq $primary_key_names[0]) {

          # this column must be an auto number.
          # no other way to check if a column is an auto number.

          next;
        }
      }

      my $required_status;
      if ( $sth->{'NULLABLE'}->[$i] eq '1' ) {

        $required_status = 0;
      }
      else {

        $required_status = 1;
      }

      my $static_field = {};

      if ($field_name eq 'name' || $field_name eq 'id') {

        $field_name = "${tname}$field_name";
      }

      my $datatype   = $sth->{'TYPE'}->[$i];
      my @type_info  = $dbh->type_info([$datatype]);
      my $dtype_name = 'Unknown';

      if (defined $type_info[0]->{'TYPE_NAME'}) {

        $dtype_name = $type_info[0]->{'TYPE_NAME'};
      }

      my $col_size   = -1;

      if (lc($driver_name) eq 'pg') {

        $col_size   = $sth->{'PRECISION'}->[$i];

        if ($dtype_name eq 'text') {

          # somehow for text in Postgres the precision is 4 higher than what \d command display
          # in the psql client for the table
          $col_size -= 4;
        }

        if (defined $comment_lookup_href->{$field_name}->{'description'}) {

          $static_field->{'Description'} = $comment_lookup_href->{$field_name}->{'description'};
        }
      }
      else {

        if (defined $comment_lookup_href->{$field_name}->{'Comment'}) {

          $static_field->{'Description'} = $comment_lookup_href->{$field_name}->{'Comment'};
        }

        if (defined $comment_lookup_href->{$field_name}->{'Type'}) {

          my $sql_type_txt = $comment_lookup_href->{$field_name}->{'Type'};

          if ($sql_type_txt =~ /\w+\((\d+)\)/) {

            $col_size = $1;
          }
          elsif ($sql_type_txt =~ /set\((.*)\)/) {

            warn "SQL type: $sql_type_txt";
            my $set_option_csv = $1;
            $dtype_name = 'set';

            my @set_option_list = split(',', $set_option_csv);

            $col_size = length($set_option_list[0]);

            for (my $i = 1; $i < scalar(@set_option_list); $i++) {

              if (length($set_option_list[$i]) > $col_size) {

                $col_size = length($set_option_list[$i]);
              }
            }

            # Due to the 2 single quotes col_size is 2 more than what it really is
            $col_size -= 2; # make it as it is
          }
        }
      }

      $static_field->{'Name'}       = $field_name;
      $static_field->{'Required'}   = $required_status;
      $static_field->{'DataType'}   = $dtype_name;
      $static_field->{'ColSize'}    = $col_size;

      #warn "Field name: $field_name - col size: $col_size";

      push(@{$static_field_aref}, $static_field);
    }

    $sth->finish();

    $field_data = $static_field_aref;

    $pkey_data = \@primary_key_names;

    return ($err, $msg, $field_data, $pkey_data);
  }
}

sub table_existence {

  my $dbh   = $_[0];
  my $tname = $_[1];

  my $table_existence = 0;

  my $sth = $dbh->table_info();
  $sth->execute();

  if (!$dbh->err()) {

    while (my @row = $sth->fetchrow_array()) {

      if ($tname eq $row[2]) {

        $table_existence = 1;
        last;
      }
    }
    $sth->finish();
  }

  return $table_existence;
}

sub table_existence_bulk {

  my $dbh        = $_[0];
  my $tname_aref = $_[1];

  my $table_name_href = {};

  for my $tname (@{$tname_aref}) {

    $table_name_href->{$tname} = 1;
  }

  my $table_exist_href = {};

  my $sth = $dbh->table_info();
  $sth->execute();

  if (!$dbh->err()) {

    while (my @row = $sth->fetchrow_array()) {

      my $table_name = $row[2];

      if ($table_name_href->{$table_name}) {

        $table_exist_href->{$table_name} = 1;
      }
    }
    $sth->finish();
  }

  return $table_exist_href;
}

sub copy_file {

  my $from_filename  = $_[0];
  my $to_filename    = $_[1];
  my $from_line      = $_[2];  # the first line is 1

  my $write_mode = '>';

  if (defined($_[3])) {

    $write_mode = $_[3];
  }

  open(my $from_fileh, "<$from_filename") or return (1, "Read $from_filename failed: $!");
  close($from_fileh);

  my $cp_result = `perl -ne 'print if $from_line .. -1' $from_filename $write_mode $to_filename`;

  my $err     = 0;
  my $err_msg = '';

  if (length($cp_result) > 0) {

    $err     = 1;
    $err_msg = $cp_result;
  }

  return ($err, $err_msg);
}

sub filter_csv {

  my $input_filehandle      = $_[0];
  my $index_filehandle      = $_[1];
  my $output_filehandle     = $_[2];
  my $filtering             = $_[3];
  my $wanted_field_idx_aref = $_[4];
  my $eol                   = $_[5];
  my $access_by_line_yn     = $_[6];

  my $line_aref = [];

  if (defined($_[7])) {

    $line_aref = $_[7];
  }

  my $err     = 0;
  my $err_msg = '';

  my $csv = Text::CSV_XS->new ({ sep_char => ',', binary => 1 });

  my $nb_row_selected = 0;

  while(1) {

    my $line = undef;

    if ($access_by_line_yn) {

      my $line_num = shift(@{$line_aref});

      if (defined($line_num)) {

        my ($get_line_err, $line_result) = get_file_line($input_filehandle, $index_filehandle, $line_num);
        if ( !$get_line_err ) {

          $line = $line_result;
        }
      }
    }
    else {

      $line = <$input_filehandle>;
    }

    if (!defined($line)) { last; }

    $csv->parse($line);

    if ($csv->error_input) {

      $err_msg = "Error: while parsing csv file - line: $line";
      $err     = 1;
      last;
    }

    my @COL = $csv->fields();

    if (eval $filtering) {

      my @matched_selected_col = @COL[@{$wanted_field_idx_aref}];
      my $selected_row = join(',', @matched_selected_col);
      print $output_filehandle "${selected_row}${eol}";
      $nb_row_selected += 1;
    }
  }

  return ($err, $err_msg, $nb_row_selected);
}

sub filter_csv_aref {

  my $input_filehandle      = $_[0];
  my $index_filehandle      = $_[1];
  my $filtering             = $_[2];
  my $wanted_field_idx_aref = $_[3];
  my $access_by_line_yn     = $_[4];
  my $line_aref             = $_[5];

  my $start_from_line       = 1;

  if (defined $_[6]) {

    $start_from_line = $_[6];
  }

  my $err         = 0;
  my $err_msg     = '';
  my $output_aref = [];

  my $csv = Text::CSV_XS->new ({ sep_char => ',', binary => 1 });

  my $nb_row_selected = 0;

  my $line_counter = 0;

  while(1) {

    my $line = undef;

    if ($access_by_line_yn) {

      my $line_num = shift(@{$line_aref});

      if (defined($line_num)) {

        $line_counter = $line_num;

        my ($get_line_err, $line_result) = get_file_line($input_filehandle, $index_filehandle, $line_num);
        if ( !$get_line_err ) {

          $line = $line_result;
        }
      }
    }
    else {

      if ($start_from_line != -1) {

        my ($get_line_err, $line_result) = get_file_line($input_filehandle, $index_filehandle, $start_from_line);

        if ( !$get_line_err ) {

          $line = $line_result;
        }

        $line_counter = $start_from_line;
        $start_from_line = -1;
      }
      else {

        $line = <$input_filehandle>;
        $line_counter += 1;
      }
    }

    if (!defined($line)) { last; }

    $csv->parse($line);

    if ($csv->error_input) {

      $err_msg = "Error: while parsing csv file - line: $line";
      $err     = 1;
      last;
    }

    my @COL = $csv->fields();

    if (eval $filtering) {

      my @matched_selected_col = @COL[@{$wanted_field_idx_aref}];

      push(@matched_selected_col, $line_counter);
      push(@{$output_aref}, \@matched_selected_col);

      $nb_row_selected += 1;
    }
  }

  return ($err, $err_msg, $nb_row_selected, $output_aref);
}

sub recurse_read {

  my $dbh              = $_[0];
  my $sql              = $_[1];
  my $where_para_aref  = $_[2];
  my $seeking_id_field = $_[3];
  my $current_level    = $_[4];
  my $stopping_level   = $_[5];

  my $global_frequency_id_href = {};

  if (defined $_[6]) {

    $global_frequency_id_href = $_[6];
  }

  my $err          = 0;
  my $msg          = '';
  my $data         = [];
  my $finish_level = $current_level;

  my ($read_err, $read_msg, $read_data_aref) = read_data($dbh, $sql, $where_para_aref);

  if ($read_err) {

    $err = $read_err;
    $msg = $read_msg;

    return ($err, $msg, $finish_level, $data);
  }

  if ( (scalar(@{$read_data_aref}) == 0) ||
       ($current_level == $stopping_level) ) {

    $err          = 0;
    $msg          = '';
    $finish_level = $current_level;

    for my $read_data_rec (@{$read_data_aref}) {

      my $id = $read_data_rec->{$seeking_id_field};
      $read_data_rec->{'Level'} = $current_level;

      warn("ID: $id - LEVEL: $current_level");

      push(@{$data}, $read_data_rec);

      if (! (defined $global_frequency_id_href->{$id}) ) {

        $global_frequency_id_href->{$id} = 1;
      }
      else {

        $global_frequency_id_href->{$id} += 1;
      }
    }

    return ($err, $msg, $finish_level, $data);
  }

  my %next_level_id_dict;

  for my $read_data_rec (@{$read_data_aref}) {

    my $id = $read_data_rec->{$seeking_id_field};

    $read_data_rec->{'Level'} = $current_level;

    warn("ID: $id - LEVEL: $current_level");

    push(@{$data}, $read_data_rec);
    $next_level_id_dict{$id} = 1;

    if (! (defined $global_frequency_id_href->{$id}) ) {

      $global_frequency_id_href->{$id} = 1;
    }
    else {

      $global_frequency_id_href->{$id} += 1;
    }
  }

  for my $next_level_id (keys(%next_level_id_dict)) {

    my ($nlevel_err, $nlevel_msg, $nlevel_fl, $nlevel_data) = recurse_read($dbh, $sql, [$next_level_id],
                                                                           $seeking_id_field, $current_level+1,
                                                                           $stopping_level, $global_frequency_id_href);

    if ($nlevel_err) {

      $err          = $nlevel_err;
      $msg          = $nlevel_msg;
      $finish_level = $current_level;

      return ($err, $msg, $finish_level, $data);
    }

    $finish_level = $nlevel_fl;

    for my $nlevel_rec (@{$nlevel_data}) {

      push(@{$data}, $nlevel_rec);
    }
  }

  return ($err, $msg, $finish_level, $data);
}

# There is a similar function called parse_filtering_v2 which can filter filter virtual columns.
# However, this function can filter geometry column.

sub parse_filtering {

  my $id_field_name          = $_[0];
  my $main_tname             = $_[1];
  my $filtering_csv          = $_[2];
  my $field_list_all         = $_[3];

  my $validation_func_lookup = {};

  if (defined $_[4]) {

    $validation_func_lookup = $_[4];
  }

  my $field_name2table_name = {};

  if (defined $_[5]) {

    $field_name2table_name = $_[5];
  }

  my $err     = 0;
  my $err_msg = '';

  my $sql_exp   = '';
  my $where_exp = [];
  my $where_arg = [];

  if (scalar(@{$field_list_all}) == 1) {

    if ($field_list_all->[0] eq '*') {

      # Cannot parse filtering. It is likely that the table contain no record.
      return ($err, $err_msg, $sql_exp, $where_arg);
    }
  }

  my $field_href     = {};
  my $geo_field_href = {};

  for my $field (@{$field_list_all}) {

    $field =~ s/"//g;

    if ($field =~ /ST_AsText\((.+)\)/) {

      my $geo_field = $1;
      $geo_field_href->{$geo_field} = 1;
      $field_href->{$geo_field}     = 1;
    }
    else {

      $field_href->{$field} = 1;
    }
  }

  my @filtering_exp = split(/&/, $filtering_csv);

  my $seen_expression_lookup = {};

  for my $expression (@filtering_exp) {

    $expression = trim($expression);
    if (length($expression) == 0) {

      next;
    }

    my $operator         = '';
    my $field_name       = '';
    my $is_quote_arg_val = 0;

    if ($expression =~ /^(\w+)\s*([=|>|<])\s*[-+]?\d+\.?\d*$/) {

      $field_name       = $1;
      $operator         = $2;
    }
    elsif ($expression =~ /^(\w+)\s*(<>)\s*[-+]?\d+\.?\d*$/) {

      $field_name       = $1;
      $operator         = $2;
    }
    elsif ($expression =~ /^(\w+)\s*([>|<]=)\s*[-+]?\d+\.?\d*$/) {

      $field_name       = $1;
      $operator         = $2;
    }
    # string field using single quote
    elsif ($expression =~ /^(\w+)\s*(=)\s*'[^']*'$/i) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }
    # string field using double quote
    elsif ($expression =~ /^(\w+)\s*(=)\s*"[^"]*"$/i) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }
    # date time
    elsif ($expression =~ /^(\w+)\s*([=|>|<])\s*'\d{4}\-\d{2}\-\d{2}( \d{2}\:\d{2}\:\d{2})?'$/) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }
    # date time
    elsif ($expression =~ /^(\w+)\s*(<>)\s*'\d{4}\-\d{2}\-\d{2}( \d{2}\:\d{2}\:\d{2})?'$/) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }
    # date time
    elsif ($expression =~ /^(\w+)\s*([>|<]=)\s*'\d{4}\-\d{2}\-\d{2}( \d{2}\:\d{2}\:\d{2})?'$/) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }
    elsif ($expression =~ /^(\w+)\s+(IN)\s+\((\s*\d+\s*,?)+\)$/i) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }
    elsif ($expression =~ /^(\w+)\s+(IN)\s+\((\s*'\d{4}\-\d{2}\-\d{2}( \d{2}\:\d{2}\:\d{2})?'\s*,?)+\)$/i) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }
    elsif ($expression =~ /^(\w+)\s+(IN)\s+\((\s*'[\w|\s|\-|\(|\)|\^|\>|\<|\%|\:|\?|\+|\[|\]|\.|\*|\/|\\|\;|\|]+'\s*,?)+\)$/i) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }
    elsif ($expression =~ /^(\w+)\s+(NOT IN)\s+\((\s*\d+\s*,?)+\)$/i) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }
    elsif ($expression =~ /^(\w+)\s+(NOT IN)\s+\((\s*'\d{4}\-\d{2}\-\d{2}( \d{2}\:\d{2}\:\d{2})?'\s*,?)+\)$/i) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }
    elsif ($expression =~ /^(\w+)\s+(NOT IN)\s+\((\s*'[\w|\s|\-|\(|\)|\^|\>|\<|\%|\:|\?|\+|\[|\]|\.|\*|\/|\\|\;|\|]+'\s*,?)+\)$/i) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }
    elsif ($expression =~ /^(\w+)\s*(<>)\s*'[\w|\s|\-|\(|\)|\^|\>|\<|\%|\:|\?|\+|\[|\]|\.|\*|\/|\\|\;|\|]*'$/i) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }
    elsif ($expression =~ /^(\w+)\s+(LIKE)\s+'[^']+'$/i) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }
    elsif ($expression =~ /^(\w+)\s+(NOT LIKE)\s+'[^']+'$/i) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }
    elsif ($expression =~ /^(\w+)\s+(\-EQ)\s+\((\s*\d+\s*,?)+\)$/i) {

      $field_name       = $1;
      $operator         = $2;
    }
    elsif ($expression =~ /^(\w+)\s+(\-GBCGT)\s+\d+$/i) {

      $field_name       = $1;
      $operator         = $2;
    }
    elsif ($expression =~ /^(\w+)\s+(\-GBCLT)\s+\d+$/i) {

      $field_name       = $1;
      $operator         = $2;
    }
    elsif ($expression =~ /^(\w+)\s+(\-GEOEQ)\s+'.+'/i) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }

    if (length($operator) > 0) {

      my ($empty, $field_value) = split(/$field_name\s*$operator/, $expression);

      $field_name  = trim($field_name);
      $field_value = trim($field_value);
      $operator    = uc($operator);

      if ($field_name eq 'Longitude' ||
          $field_name eq 'Latitude' ||
          $field_name =~ /location/ ||
          $field_name =~ /^Factor/ ) {

        # Filtering on a virtual column was not allowed because it will complicate
        # get_paged_id which is used for pagination. If we want to allow filtering
        # on a virtual column, we need to modify get_paged_id to cope with GROUP_CONCAT
        # GROUP BY and JOIN that come with a virtual column.

        $err = 1;
        $err_msg = "Field ($field_name) cannot be used for filtering.";
        last;
      }

      if ($geo_field_href->{$field_name}) {

        if ($field_value =~ /^'([A-Z]+)\(.+\)'$/) {

          my $geo_type = $1;
          $field_value =~ s/'//g;

          my $dbh_gis = connect_gis_read();

          my ($is_wkt_err, $wkt_err_href) = is_valid_wkt_href($dbh_gis, {$field_name => $field_value}, $geo_type);

          if ($is_wkt_err) {

            $err     = 1;
            $err_msg = "Filtering field ($field_name): $field_value invalid well known text.";
            last;
          }
          else {

            if ($operator =~ /\-GEOEQ/i) {

              $operator = '=';
            }

            $field_value = qq|ST_GeomFromText('${field_value}', -1)|;
          }

          $dbh_gis->disconnect();
        }
        else {

          $err     = 1;
          $err_msg = "Filtering field ($field_name): unknown geometry text.";
          last;
        }
      }

      my $new_exp = "$field_name $operator $field_value";

      if (!$seen_expression_lookup->{$new_exp}) {

        # valid the filtering value
        if ( (defined $validation_func_lookup->{$field_name}) && ($operator !~ /\-EQ/i) ) {

          my $validation_func = $validation_func_lookup->{$field_name};
          my ($valid_err, $valid_msg) = $validation_func->($field_value);

          if ($valid_err) {

            return ($valid_err, $valid_msg, '', []);
          }
        }

        $seen_expression_lookup->{$new_exp} = 1;

        my $sub_query  = 0;
        my $table_name = '';
        if (length($field_name2table_name->{$field_name}) > 0) {

          $table_name    = $field_name2table_name->{$field_name};
          $sub_query     = 1;
        }

        if ($operator =~ /\-EQ/i && $sub_query == 0) {

          $err = 1;
          $err_msg = "$field_name does not support -EQ operator.";
          last;
        }

        if ($operator =~ /\-GBCGT/i && $sub_query == 0) {

          $err = 1;
          $err_msg = "$field_name does not support -GBCGT operator.";
          last;
        }

        if ($operator =~ /\-GBCLT/i && $sub_query == 0) {

          $err = 1;
          $err_msg = "$field_name does not support -GBCGT operator.";
          last;
        }

        if ($field_href->{$field_name}) {

          if ($is_quote_arg_val) {

            if ($sub_query) {

              my $sub_query_where = '';

              if ($main_tname =~ /\"/) {

                $sub_query_where   = "${main_tname}.${id_field_name} IN ";
                $sub_query_where  .= "(SELECT DISTINCT $id_field_name FROM $table_name ";
                $sub_query_where  .= qq|WHERE "${field_name}" $operator $field_value)|;
              }
              else {

                $sub_query_where   = "${main_tname}.${id_field_name} IN ";
                $sub_query_where  .= "(SELECT DISTINCT $id_field_name FROM $table_name ";
                $sub_query_where  .= "WHERE ${field_name} $operator $field_value)";
              }

              push(@{$where_exp}, $sub_query_where);
            }
            else {

              if ($main_tname =~ /\"/) {

                push(@{$where_exp}, qq|${main_tname}."${field_name}" $operator $field_value|);
              }
              else {

                push(@{$where_exp}, "${main_tname}.${field_name} $operator $field_value");
              }
            }
          }
          else {

            if ($sub_query) {

              my $sub_query_where = '';

              if ($operator =~ /\-EQ/i) {

                my $multi_field_val = $field_value;
                $multi_field_val    =~ s/\(|\)//g;

                my @field_val = split(/,/, $multi_field_val);

                for my $ind_field_val (@field_val) {

                  $ind_field_val = trim($ind_field_val);

                  $sub_query_where    = "${main_tname}.${id_field_name} IN ";
                  $sub_query_where   .= "(SELECT DISTINCT $id_field_name FROM $table_name ";
                  $sub_query_where   .= "WHERE ${field_name} = ?#${ind_field_val}#)";

                  push(@{$where_exp}, $sub_query_where);
                }
              }
              elsif ($operator =~ /\-GBC([G|L])T/i) {

                my $gbc_oper_sym = lc($1);

                my $gbc_oper     = '';

                if ($gbc_oper_sym eq 'l') {

                  $gbc_oper = '<';
                }
                else {

                  $gbc_oper = '>';
                }

                if ($main_tname =~ /\"/) {

                  $sub_query_where  = qq|${main_tname}."${field_name}" IN |;
                  $sub_query_where .= qq|(SELECT "${field_name}" |;
                  $sub_query_where .= qq|FROM $table_name GROUP BY "${field_name}" |;
                  $sub_query_where .= qq|HAVING COUNT("${field_name}") $gbc_oper ?#${field_value}#)|;

                  push(@{$where_exp}, $sub_query_where);
                }
                else {

                  $sub_query_where  = qq|${main_tname}.${field_name} IN |;
                  $sub_query_where .= qq|(SELECT ${field_name} |;
                  $sub_query_where .= qq|FROM $table_name GROUP BY ${field_name} |;
                  $sub_query_where .= qq|HAVING COUNT(${field_name}) $gbc_oper ?#${field_value}#)|;

                  push(@{$where_exp}, $sub_query_where);
                }
              }
              else {

                if ($main_tname =~ /\"/) {

                  $sub_query_where  = "${main_tname}.${id_field_name} IN ";
                  $sub_query_where .= "(SELECT DISTINCT $id_field_name FROM $table_name ";
                  $sub_query_where .= qq|WHERE "${field_name}" $operator ?#${field_value}#)|;

                  push(@{$where_exp}, $sub_query_where);
                }
                else {

                  $sub_query_where  = "${main_tname}.${id_field_name} IN ";
                  $sub_query_where .= "(SELECT DISTINCT $id_field_name FROM $table_name ";
                  $sub_query_where .= "WHERE ${field_name} $operator ?#${field_value}#)";

                  push(@{$where_exp}, $sub_query_where);
                }
              }
            }
            else {

              if ($main_tname =~ /\"/) {

                push(@{$where_exp}, qq|${main_tname}."${field_name}" $operator ?#${field_value}#|);
              }
              else {

                push(@{$where_exp}, "${main_tname}.${field_name} $operator ?#${field_value}#");
              }
            }
          }
        }
        else {

          $err     = 1;
          $err_msg = "Filtering field ($field_name) unknown.";
          last;
        }
      }
    }
    else {

      $err     = 1;
      $err_msg = "( $expression ): invalid filtering expression.";
      last;
    }
  }

  my $clean_where_exp = [];

  for (my $i = 0; $i < scalar(@{$where_exp}); ++$i) {

    my $exp = $where_exp->[$i];

    my $count_arg = 0;
    while ($exp =~ s/\#([-+]?\d+\.?\d*)\#//) {

      my $arg_val = $1;
      push(@{$where_arg}, $arg_val);
      $count_arg += 1;
    }

    if ($count_arg > 1) {

      my $prob_exp = $where_exp->[$i];
      $err     = 1;
      $err_msg = "$prob_exp is very strange.";
      return ($err, $err_msg, '', []);
    }

    if (length($exp) > 0) {

      push(@{$clean_where_exp}, $exp);
    }
  }

  $sql_exp = join(' AND ', @{$clean_where_exp});

  return ($err, $err_msg, $sql_exp, $where_arg);
}

sub generate_factor_sql_v2 {

  my $dbh           = $_[0];
  my $field_list    = $_[1];
  my $table_name    = $_[2];
  my $id_fieldname  = $_[3];
  my $other_join    = $_[4];

  my $field_list_href = {};

  for my $field (@{$field_list}) {

    $field_list_href->{$field} = 1;
  }

  my $factor_table = $table_name . 'factor';

  my $sql = "SELECT ${factor_table}.FactorId, FactorName, ";
  $sql   .= "FactorCaption, FactorDescription, FactorDataType, ";
  $sql   .= 'IF(CanFactorHaveNull=0,1,0) AS Required, ';
  $sql   .= 'FactorValueMaxLength, FactorUnit ';
  $sql   .= "FROM $factor_table LEFT JOIN factor ";
  $sql   .= "ON $factor_table.FactorId = factor.FactorId ";
  $sql   .= "GROUP BY factor.FactorId";

  my $sth = $dbh->prepare($sql);
  $sth->execute();

  my $vcol_field_part = q{};
  my @vcol_list;

  my @vcol_fieldname_list;;

  my $err = 0;
  my $trouble_vcol_str = '';

  while (my $row = $sth->fetchrow_hashref() ) {

    my $vcol_id       = $row->{'FactorId'};
    my $vcol_name     = $row->{'FactorName'};
    my $vcol_caption  = $row->{'FactorCaption'};
    my $vcol_datatype = $row->{'FactorDataType'};

    if ($vcol_name =~ /\s+/) {

      $err = 1;
      $trouble_vcol_str .= "$vcol_name,";
    }

    my $vcol_unit = q{};
    if ($row->{'FactorUnit'}) {

      $vcol_unit = qq/"$row->{'FactorUnit'}"/;
    }

    my $field_name = "Factor${vcol_name}";

    if ($field_list_href->{$field_name} || $field_list_href->{'VCol*'} || $field_list_href->{'*'}) {

      $vcol_field_part .= qq| GROUP_CONCAT(IF(FactorId = $vcol_id, FactorValue, NULL) SEPARATOR '') AS |;
      $vcol_field_part .= qq| \`${field_name}\`,|;

      push(@vcol_fieldname_list, "subq.\`${field_name}\`");
      push(@vcol_list, $row);
    }
  }

  # remove last character - last "," must not exist
  chop($vcol_field_part);

  $sth->finish();

  my $select_field_part = q{};
  for my $field (@{$field_list}) {

    if ($field =~ /Col\*$/) {

      if ($field eq 'SCol*') {

        $select_field_part .= "${table_name}.*,";
      }
    }
    else {

      # When the field name is not a wild card column like specific individual field name.
      # If the specific field name does not start with Factor. If it does start with
      # Factor, then virtual colum field selection has been done as part of vcol_field_part.

      if (!($field =~ /Factor/)) {

        if ($field =~ /\./) {

          $select_field_part .= "$field,";
        }
        else {

          $select_field_part .= "${table_name}.$field,";
        }
      }
    }
  }
  # remove last character - last "," must not exist
  chop($select_field_part);

  my $returned_sql = '';
  if (length($select_field_part) > 0) {

    $returned_sql = "SELECT ${select_field_part} ";
  }
  else {

    $returned_sql = "SELECT ${table_name}.* ";
  }

  if (length($vcol_field_part) > 0) {

    $returned_sql .= ", " . join(',', @vcol_fieldname_list) . " FROM ";
    $returned_sql .= " (SELECT $id_fieldname, $vcol_field_part FROM $factor_table ";
    $returned_sql .= " GROUP BY $id_fieldname ";
    $returned_sql .= " FACTORHAVING) AS subq ";
    $returned_sql .= " LEFT JOIN $table_name ON subq.${id_fieldname} = ${table_name}.${id_fieldname} ";
    $returned_sql .= " $other_join ";
  }
  else {

    $returned_sql .= " FROM $table_name $other_join ";
  }

  return ($err, $trouble_vcol_str, $returned_sql, \@vcol_list);
}

# It can filter on virtual (factor) columns
sub parse_filtering_v2 {

  my $id_field_name          = $_[0];
  my $main_tname             = $_[1];
  my $filtering_csv          = $_[2];
  my $field_list_all         = $_[3];
  my $vcol_aref              = $_[4];

  my $validation_func_lookup = {};

  if (defined $_[5]) {

    $validation_func_lookup = $_[5];
  }

  my $field_name2table_name = {};

  if (defined $_[6]) {

    $field_name2table_name = $_[6];
  }

  my $factorname2factorid_lookup = {};

  for my $vcol_row (@{$vcol_aref}) {

    my $vcol_id    = $vcol_row->{'FactorId'};
    my $vcol_name  = $vcol_row->{'FactorName'};

    $factorname2factorid_lookup->{"Factor$vcol_name"} = $vcol_id;
  }

  my $err        = 0;
  my $err_msg    = '';
  my $where_exp  = '';
  my $where_arg  = [];
  my $having_exp = '';

  my $scol_where_exp  = [];
  my $scol_where_arg  = [];

  my $vcol_where_exp  = [];
  my $vcol_having_exp = [];

  my $count_fac_aref  = [];
  my $count_nb_ffield = 0;

  if (scalar(@{$field_list_all}) == 1) {

    if ($field_list_all->[0] eq '*') {

      # Cannot parse filtering. It is likely that the table contain no record.
      return ($err, $err_msg, $where_exp, $where_arg, $having_exp);
    }
  }

  my $field_href = {};

  for my $field (@{$field_list_all}) {

    $field_href->{$field} = 1;
  }

  my @filtering_exp = split(/&/, $filtering_csv);

  my $seen_expression_lookup = {};

  for my $expression (@filtering_exp) {

    $expression = trim($expression);
    if (length($expression) == 0) {

      next;
    }

    my $operator         = '';
    my $field_name       = '';
    my $is_quote_arg_val = 0;

    if ($expression =~ /^(\w+)\s*([=|>|<])\s*[-+]?\d+\.?\d*$/) {

      $field_name       = $1;
      $operator         = $2;
    }
    elsif ($expression =~ /^(\w+)\s*(<>)\s*[-+]?\d+\.?\d*$/) {

      $field_name       = $1;
      $operator         = $2;
    }
    elsif ($expression =~ /^(\w+)\s*([>|<]=)\s*[-+]?\d+\.?\d*$/) {

      $field_name       = $1;
      $operator         = $2;
    }
    # string field using single quote
    elsif ($expression =~ /^(\w+)\s*(=)\s*'[^']*'$/i) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }
    # string field using double quote
    elsif ($expression =~ /^(\w+)\s*(=)\s*"[^"]*"$/i) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }
    # date time
    elsif ($expression =~ /^(\w+)\s*([=|>|<])\s*'\d{4}\-\d{2}\-\d{2}( \d{2}\:\d{2}\:\d{2})?'$/) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }
    # date time
    elsif ($expression =~ /^(\w+)\s*(<>)\s*'\d{4}\-\d{2}\-\d{2}( \d{2}\:\d{2}\:\d{2})?'$/) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }
    # date time
    elsif ($expression =~ /^(\w+)\s*([>|<]=)\s*'\d{4}\-\d{2}\-\d{2}( \d{2}\:\d{2}\:\d{2})?'$/) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }
    elsif ($expression =~ /^(\w+)\s+(IN)\s+\((\s*\d+\s*,?)+\)$/i) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }
    elsif ($expression =~ /^(\w+)\s+(IN)\s+\((\s*'\d{4}\-\d{2}\-\d{2}( \d{2}\:\d{2}\:\d{2})?'\s*,?)+\)$/i) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }
    elsif ($expression =~ /^(\w+)\s+(IN)\s+\((\s*'[\w|\s|\-|\(|\)|\^|\>|\<|\%|\:|\?|\+|\[|\]|\.|\*|\/|\\|\|]+'\s*,?)+\)$/i) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }

    #

    elsif ($expression =~ /^(\w+)\s+(NOT IN)\s+\((\s*\d+\s*,?)+\)$/i) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }
    elsif ($expression =~ /^(\w+)\s+(NOT IN)\s+\((\s*'\d{4}\-\d{2}\-\d{2}( \d{2}\:\d{2}\:\d{2})?'\s*,?)+\)$/i) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }
    elsif ($expression =~ /^(\w+)\s+(NOT IN)\s+\((\s*'[\w|\s|\-|\(|\)|\^|\>|\<|\%|\:|\?|\+|\[|\]|\.|\*|\/|\\|\|]+'\s*,?)+\)$/i) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }

    #

    elsif ($expression =~ /^(\w+)\s*(<>)\s*'[\w|\s|\-|\(|\)|\^|\>|\<|\%|\:|\?|\+|\[|\]|\.|\*|\/|\\|\|]*'$/i) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }
    elsif ($expression =~ /^(\w+)\s+(LIKE)\s+'[^']+'$/i) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }
    elsif ($expression =~ /^(\w+)\s+(NOT LIKE)\s+'[^']+'$/i) {

      $field_name       = $1;
      $operator         = $2;
      $is_quote_arg_val = 1;
    }
    elsif ($expression =~ /^(\w+)\s+(\-EQ)\s+\((\s*\d+\s*,?)+\)$/i) {

      $field_name       = $1;
      $operator         = $2;
    }
    elsif ($expression =~ /^(\w+)\s*(<>)\s*NULL$/) {

      $field_name       = $1;
      $operator         = $2;

      my $new_field_name = "ISNULL($field_name)";

      $expression =~ s/NULL/1/;
      $expression =~ s/$field_name/$new_field_name/;
      $field_name = $new_field_name;
    }
    elsif ($expression =~ /^(\w+)\s*(=)\s*NULL$/) {

      $field_name       = $1;
      $operator         = $2;

      my $new_field_name = "ISNULL($field_name)";

      $expression =~ s/NULL/1/;
      $expression =~ s/$field_name/$new_field_name/;
      $field_name = $new_field_name;
    }

    if (length($operator) > 0) {

      my ($empty, $field_value);

      if ($field_name =~ /^ISNULL/) {

        $field_value = 1;
      }
      else {

        ($empty, $field_value) = split(/$field_name\s*$operator/, $expression);
      }

      $field_name  = trim($field_name);
      $field_value = trim($field_value);
      $operator    = uc($operator);

      if ($field_name eq 'Longitude' ||
          $field_name eq 'Latitude' ||
          $field_name =~ /location/ ) {

        $err = 1;
        $err_msg = "Field ($field_name) cannot be used for filtering.";
        last;
      }

      if ($field_name =~ /^Factor/) {

        if ($operator eq '-EQ') {

          $err = 1;
          $err_msg = "Field ($field_name) cannot have -EQ Operator.";
          last;
        }

        my $new_exp = "$field_name $operator $field_value";

        if (!$seen_expression_lookup->{$new_exp}) {

          $seen_expression_lookup->{$new_exp} = 1;

          my $sub_query  = 0;
          my $table_name = '';

          if ($field_href->{$field_name}) {

            $count_nb_ffield += 1;
            my $vcol_id = $factorname2factorid_lookup->{$field_name};

            push(@{$count_fac_aref}, "(FactorId = $vcol_id AND FactorValue $operator $field_value)");
            push(@{$vcol_having_exp}, $new_exp);
          }
          else {

            $err     = 1;
            $err_msg = "Filtering field ($field_name) unknown.";
            last;
          }
        }
      }
      elsif ($field_name =~ /^ISNULL\((\w+)\)$/) {

        my $new_exp = "$field_name $operator $field_value";

        $field_name = $1;

        if (!$seen_expression_lookup->{$new_exp}) {

          if ($field_href->{$field_name}) {

            push(@{$scol_where_exp}, "ISNULL(${main_tname}.${field_name}) $operator ?#${field_value}#");
          }
          else {

            $err     = 1;
            $err_msg = "Filtering field ($field_name) unknown.";
            last;
          }

          $seen_expression_lookup->{$new_exp} = 1;
        }
      }
      else {

        my $new_exp = "$field_name $operator $field_value";

        if (!$seen_expression_lookup->{$new_exp}) {

          # valid the filtering value
          if ( (defined $validation_func_lookup->{$field_name}) && ($operator !~ /\-EQ/i) ) {

            my $validation_func = $validation_func_lookup->{$field_name};
            my ($valid_err, $valid_msg) = $validation_func->($field_value);

            if ($valid_err) {

              return ($valid_err, $valid_msg, '', [], '');
            }
          }

          $seen_expression_lookup->{$new_exp} = 1;

          my $sub_query  = 0;
          my $table_name = '';
          if (length($field_name2table_name->{$field_name}) > 0) {

            $table_name    = $field_name2table_name->{$field_name};
            $sub_query     = 1;
          }

          if ($operator =~ /\-EQ/i && $sub_query == 0) {

            $err = 1;
            $err_msg = "$field_name does not support -EQ operator.";
            last;
          }

          if ($field_href->{$field_name}) {

            if ($is_quote_arg_val) {

              if ($sub_query) {

                my $sub_query_where = '';

                $sub_query_where   = "${main_tname}.${id_field_name} IN ";
                $sub_query_where  .= "(SELECT DISTINCT $id_field_name FROM $table_name ";
                $sub_query_where  .= "WHERE ${field_name} $operator $field_value)";

                push(@{$scol_where_exp}, $sub_query_where);
              }
              else {

                push(@{$scol_where_exp}, "${main_tname}.${field_name} $operator $field_value");
              }
            }
            else {

              if ($sub_query) {

                my $sub_query_where = '';

                if ($operator =~ /\-EQ/i) {

                  my $multi_field_val = $field_value;
                  $multi_field_val    =~ s/\(|\)//g;

                  my @field_val = split(/,/, $multi_field_val);

                  for my $ind_field_val (@field_val) {

                    $ind_field_val = trim($ind_field_val);

                    my $sub_query_where = "${main_tname}.${id_field_name} IN ";
                    $sub_query_where   .= "(SELECT DISTINCT $id_field_name FROM $table_name ";
                    $sub_query_where   .= "WHERE ${field_name} = ?#${ind_field_val}#)";

                    push(@{$scol_where_exp}, $sub_query_where);
                  }
                }
                else {

                  $sub_query_where  = "${main_tname}.${id_field_name} IN ";
                  $sub_query_where .= "(SELECT DISTINCT $id_field_name FROM $table_name ";
                  $sub_query_where .= "WHERE ${field_name} $operator ?#${field_value}#)";

                  push(@{$scol_where_exp}, $sub_query_where);
                }
              }
              else {

                push(@{$scol_where_exp}, "${main_tname}.${field_name} $operator ?#${field_value}#");
              }
            }
          }
          else {

            $err     = 1;
            $err_msg = "Filtering field ($field_name) unknown.";
            last;
          }
        }
      }
    }
    else {

      $err     = 1;
      $err_msg = "( $expression ): invalid filtering expression.";
      last;
    }
  }

  my $clean_scol_where_exp = [];

  for (my $i = 0; $i < scalar(@{$scol_where_exp}); ++$i) {

    my $exp = $scol_where_exp->[$i];

    while ($exp =~ s/\#([-+]?\d+\.?\d*)\#//) {

      my $arg_val = $1;
      push(@{$scol_where_arg}, $arg_val);
    }

    if (length($exp) > 0) {

      push(@{$clean_scol_where_exp}, $exp);
    }
  }

  $where_exp  = join(' AND ', @{$clean_scol_where_exp});
  $having_exp = join(' AND ', @{$vcol_having_exp});
  $where_arg  = $scol_where_arg;

  my $count_where_exp = '';

  if (scalar(@{$count_fac_aref}) > 0) {

    $count_where_exp = join(' OR ', @{$count_fac_aref});
  }

  return ($err, $err_msg, $where_exp, $where_arg, $having_exp, $count_where_exp, $count_nb_ffield);
}

sub get_file_block {

  my $file_name = $_[0];
  my $start_tag = $_[1];
  my $end_tag   = $_[2];

  my $content = '';
  my $start   = 0;
  my $file_handle;
  open($file_handle, "<$file_name");
  my $line    = '';

  while($line = <$file_handle>) {

    if ($line =~ /^$start_tag/) {

      $start = 1;
      next;
    }

    if ($start == 1) {

      if ($line =~ /^$end_tag/) {

	last;
      }
      else {

	$content .= $line;
      }
    }
  }
  close($file_handle);

  return $content;
}

sub check_static_field {

  my $query      = $_[0];
  my $dbh_read   = $_[1];
  my $tname      = $_[2];
  my $skip_field = $_[3];

  my $fname_translation = {};

  if (defined $_[4]) {

    $fname_translation = $_[4];
  }

  my $data_for_postrun_href = {};

  my ($get_scol_err, $get_scol_msg, $scol_data, $pkey_data) = get_static_field($dbh_read, $tname);

  if ($get_scol_err) {

    my $err_msg = "Get static field info failed: $get_scol_msg";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return (1, $err_msg, $data_for_postrun_href);
  }

  my $required_field_href    = {};
  my $chk_maxlen_field_href  = {};
  my $colsize_info           = {};

  for my $static_field (@{$scol_data}) {

    my $field_name       = $static_field->{'Name'};
    my $field_dtype      = $static_field->{'DataType'};
    my $tran_field_name  = $field_name;

    if (defined $fname_translation->{$field_name}) {

      $tran_field_name = $fname_translation->{$field_name};
    }

    if ($skip_field->{$field_name}) { next; }

    if ($static_field->{'Required'} == 1) {

      $required_field_href->{$field_name} = $query->param($tran_field_name);
    }

    if (lc($field_dtype) eq 'varchar' || lc($field_dtype) eq 'text' || lc($field_dtype) eq 'char') {

      $colsize_info->{$field_name}           = $static_field->{'ColSize'};
      $chk_maxlen_field_href->{$field_name}  = $query->param($tran_field_name);
    }
  }

  $dbh_read->disconnect();

  my ($missing_err, $missing_href) = check_missing_href( $required_field_href );

  if ($missing_err) {

    my $err_msg = "Missing fields";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return (1, $err_msg, $data_for_postrun_href);
  }

  my ($maxlen_err, $maxlen_href) = check_maxlen_href($chk_maxlen_field_href, $colsize_info);

  if ($maxlen_err) {

    my $err_msg = "Longer than maximum length";

    $data_for_postrun_href->{'Error'}       = 1;
    $data_for_postrun_href->{'Data'}        = {'Error' => [$maxlen_href]};

    return (1, $err_msg, $data_for_postrun_href);
  }

  return (0, '', $data_for_postrun_href);
}

sub get_next_value_for {

  my $monetdb_dbh = $_[0];
  my $table_name  = $_[1];
  my $field_name  = $_[2];

  my $err     = 0;
  my $err_msg = '';

  my $sql = qq|SELECT "default" FROM "sys"."columns" |;
  $sql   .= qq|WHERE table_id=(SELECT id AS table_id FROM "sys"."tables" WHERE name=?) AND |;
  $sql   .= qq|name=?|;

  my ($r_default_err, $default_str) = read_cell($monetdb_dbh, $sql, [$table_name, $field_name]);

  if ($r_default_err) {

    $err = 1;
    $err_msg = "Retrieving default string for field $field_name in table $table_name failed.";

    return ($err, $err_msg, undef);
  }

  if (length($default_str) == 0) {

    $err = 1;
    $err_msg = "Field $field_name in table $table_name ($default_str) is not auto number.";

    return ($err, $err_msg, undef);
  }

  $sql = qq|SELECT $default_str|;

  my ($r_next_val_err, $next_val) = read_cell($monetdb_dbh, $sql, []);

  if ($r_next_val_err) {

    $err = 1;
    $err_msg = "Retrieving next value for field $field_name in table $table_name ($default_str) failed.";

    return ($err, $err_msg, undef);
  }

  return ($err, $err_msg, $next_val);
}

sub load_config {

  my $err = 0;
  my $msg = '';

  my $logger = undef;

  if (defined $_[0]) {

    $logger = $_[0];
  }

  if (-e $CFG_FILE_PATH) {

    if (-r $CFG_FILE_PATH) {

      my $config_hash = {};

      Config::Simple->import_from($CFG_FILE_PATH, $config_hash);

      my @block_param_list = keys(%{$config_hash});

      foreach my $block_param (@block_param_list) {

        if (defined $logger) { $logger->debug("BLOCK: $block_param"); }

        my $param_val = $config_hash->{$block_param};

        if ($block_param =~ /(\w+)\.(.*)/) {

          my $block_name = $1;
          my $param_name = $2;

          if (defined $logger) { $logger->debug("BLOCK NAME: $block_name - PARAM NAME: $param_name - PARAM VALUE: $param_val"); }

          if (defined $${block_name}) {

            # use plain text variable referencing
            my $variable_data_type = ref $${block_name};
            if (defined $logger) { $logger->debug("Variable data type: $variable_data_type"); }

            my $local_val = '';

            if ($variable_data_type eq 'HASH') {

              # need   no strict 'refs' to work

              if (defined $logger) { $logger->debug("Base DIR: " . $main::kddart_base_dir); }

              if (defined $${block_name}->{"$main::kddart_base_dir"}) {

                $local_val = $${block_name}->{"$main::kddart_base_dir/$param_name"};

                if (defined $logger) { $logger->debug("Block local before replacement: $local_val"); }

                if ($local_val eq 'FROM CFG_FILE') {

                  $${block_name}->{"$main::kddart_base_dir/$param_name"} = $param_val;
                }
              }
              else {

                $${block_name}->{"$main::kddart_base_dir/$param_name"} = $param_val;
              }
            }
            elsif (length($variable_data_type) == 0) {

              if (defined $${block_name}) {

                $local_val = $${block_name};

                if ($local_val eq 'FROM CFG_FILE') {

                  $${block_name} = $param_val;
                }
              }
              else {

                $${block_name} = $param_val;
              }
            }
            else {

              if (defined $logger) { $logger->debug("Variable data type: $variable_data_type for $block_name UNSUPPORTED"); }
              $msg = "Variable data type: $variable_data_type for $block_name UNSUPPORTED";
              $err = 1;
            }
          }
          else {

            if (defined $logger) { $logger->debug("$block_name is undefined."); }
            $msg = "$block_name is undefined.";
            $err = 1;
          }
        }
      }
    }
    else {

      if (defined $logger) { $logger->debug("Config file $CFG_FILE_PATH : NOT READABLE"); }
      $msg = "Config file $CFG_FILE_PATH : NOT READABLE";
      $err = 1;
    }
  }
  else {

    if (defined $logger) { $logger->debug("Config file $CFG_FILE_PATH : NOT FOUND"); }
    $msg = "Config file $CFG_FILE_PATH : NOT FOUND";
    $err = 1;
  }

  return ($err, $msg);
}

sub record_existence_bulk {

  my $dbh              = $_[0];
  my $table_name       = $_[1];
  my $field_name       = $_[2];
  my $field_value_aref = $_[3];
  my $other_where      = '';

  if (defined $_[4]) {

    $other_where = ' AND ' . $_[4];
  }

  my $err          = 0;
  my $msg          = '';
  my $unfound_aref = [];
  my $found_aref   = [];

  if (scalar(@{$field_value_aref}) == 0) {

    return ($err, $msg, $unfound_aref, $found_aref);
  }

  my $driver_name = $dbh->{'Driver'}->{'Name'};

  if (lc($driver_name) eq 'monetdb') {

    $field_name = qq|"$field_name"|;
    $table_name = qq|"$table_name"|;
  }

  my $field_val_csv = join(',', @{$field_value_aref});

  my $sql = "SELECT $field_name ";
  $sql   .= "FROM $table_name ";
  $sql   .= "WHERE $field_name IN ($field_val_csv) ";
  $sql   .= $other_where;


  my $sth = $dbh->prepare($sql);
  $sth->execute();

  $field_name =~ s/"//g;

  my $db_lookup_href = $sth->fetchall_hashref($field_name);

  if ($dbh->err() || $sth->err()) {

    $err = 1;
    $msg = "DB failed: $sql";

    return ($err, $msg, $unfound_aref, $found_aref);
  }

  $sth->finish();

  foreach my $field_val (@{$field_value_aref}) {

    my $cleaned_field_val = $field_val;
    $cleaned_field_val    =~ s/^'|'$//g;

    if ( !(defined $db_lookup_href->{$cleaned_field_val}) ) {

      push(@{$unfound_aref}, $field_val);
    }
    else {

      push(@{$found_aref}, $field_val);
    }
  }

  return ($err, $msg, $unfound_aref, $found_aref);
}

sub get_solr_cores {

  my $browser            = LWP::UserAgent->new();
  my $solr_server_url    = $SOLR_URL->{$ENV{DOCUMENT_ROOT}};
  my $solr_list_core_url = $solr_server_url . '/admin/cores?wt=json';

  my $get_req = GET($solr_list_core_url);
  my $get_res = $browser->request($get_req);

  if ( ! $get_res->is_success) {

    my $err     = 1;
    my $err_msg = "Error: " . $get_res->status_line() . " - message: " . $get_res->content();

    return ($err, $err_msg, {});
  }

  my $response_json_txt = $get_res->content();

  my $response_href = eval{ decode_json($response_json_txt); };

  if ( ! (defined $response_href) ) {

    my $err     = 1;
    my $err_msg = "Error: cannot decode json $@ - " . $response_json_txt;

    return ($err, $err_msg, {});
  }

  if ( ! (defined $response_href->{'status'}) ) {

    my $err     = 1;
    my $err_msg = "Error: cannot find Solr status data";

    return ($err, $err_msg, {});
  }

  my $status_href = $response_href->{'status'};

  my $core_href = {};

  foreach my $core_name (keys(%{$status_href})) {

    my $core_status_href   = $status_href->{$core_name};
    my $return_status_href = {};

    $return_status_href->{'coreName'}     = $core_name;
    $return_status_href->{'startTime'}    = $core_status_href->{'startTime'};
    $return_status_href->{'uptime'}       = $core_status_href->{'uptime'};
    $return_status_href->{'numDocs'}      = $core_status_href->{'index'}->{'numDocs'};
    $return_status_href->{'maxDoc'}       = $core_status_href->{'index'}->{'maxDoc'};
    $return_status_href->{'current'}      = $core_status_href->{'index'}->{'current'};
    $return_status_href->{'sizeInBytes'}  = $core_status_href->{'index'}->{'sizeInBytes'};
    $return_status_href->{'size'}         = $core_status_href->{'index'}->{'size'};
    $return_status_href->{'lastModified'} = $core_status_href->{'index'}->{'lastModified'};

    $core_href->{lc($core_name)} = $return_status_href;
  }

  return (0, '', $core_href);
}

sub get_solr_fields {

  my $core_name = $_[0];

  my $browser            = LWP::UserAgent->new();
  my $solr_server_url    = $SOLR_URL->{$ENV{DOCUMENT_ROOT}};
  my $solr_schema_url    = $solr_server_url . "/${core_name}/schema?wt=json";

  my $get_req = GET($solr_schema_url);
  my $get_res = $browser->request($get_req);

  if ( ! $get_res->is_success) {

    my $err     = 1;
    my $err_msg = "Error: " . $get_res->status_line() . " - message: " . $get_res->content();

    return ($err, $err_msg, []);
  }

  my $response_json_txt = $get_res->content();

  my $response_href = eval{ decode_json($response_json_txt); };

  if ( ! (defined $response_href) ) {

    my $err     = 1;
    my $err_msg = "Error: cannot decode json $@ - " . $response_json_txt;

    return ($err, $err_msg, []);
  }

  if ( ! (defined $response_href->{'schema'}) ) {

    my $err     = 1;
    my $err_msg = "Error: cannot find schema data";

    return ($err, $err_msg, []);
  }

  if ( ! (defined $response_href->{'schema'}->{'fields'}) ) {

    my $err     = 1;
    my $err_msg = "Error: cannot find field data";

    return ($err, $err_msg, []);
  }

  my $field_aref = $response_href->{'schema'}->{'fields'};

  return (0, '', $field_aref);
}

sub get_solr_entities {

  my $core_name = $_[0];

  my $browser            = LWP::UserAgent->new();
  my $solr_server_url    = $SOLR_URL->{$ENV{DOCUMENT_ROOT}};
  my $solr_config_url    = $solr_server_url . "/${core_name}/dataimport?command=show-config";

  my $get_req = GET($solr_config_url);
  my $get_res = $browser->request($get_req);

  if ( ! $get_res->is_success) {

    my $err     = 1;
    my $err_msg = "Error: " . $get_res->status_line() . " - message: " . $get_res->content();

    return ($err, $err_msg, {});
  }

  my $config_xml_txt = $get_res->content();

  my $solr_config_ref = eval{ XMLin($config_xml_txt, 'ForceArray' => 1); };

  if ( ! (defined $solr_config_ref) ) {

    my $err     = 1;
    my $err_msg = "Error: cannot decode XML $@ - " . $config_xml_txt;

    return ($err, $err_msg, {});
  }

  if ( ! (defined $solr_config_ref->{'document'}) ) {

    my $err     = 1;
    my $err_msg = "Error: cannot find document data";

    return ($err, $err_msg, {});
  }

  my $entity_name2query_href = {};

  my $document_aref = $solr_config_ref->{'document'};

  foreach my $entity_href (@{$document_aref}) {

    foreach my $entity_key (keys(%{$entity_href})) {

      warn "entity key: $entity_key";

      my $entity_data_href = $entity_href->{$entity_key};

      foreach my $data_key (keys(%{$entity_data_href})) {

        my $query_sql = $entity_data_href->{$data_key}->{'query'};
        warn "query: $query_sql";

        if ($query_sql =~ /'(\w+)' as "?entity_name"?/i) {

          my $entity_name = $1;
          $entity_name2query_href->{$entity_name} = {'query'       => $query_sql,
                                                     'entity_name' => $entity_name};
        }
        else {

          my $err     = 1;
          my $err_msg = "Error: $query_sql - no entity_name field";

          return ($err, $err_msg, {});
        }
      }
    }
  }

  return (0, '', $entity_name2query_href);
}

sub validate_trait_db_bulk {

  my $dbh                = $_[0];
  my $trait_id2val_href  = $_[1];

  my @trait_id_list = keys(%{$trait_id2val_href});

  my $err          = 0;
  my $err_msg      = '';
  my $err_trait_id = -1;
  my $err_val_idx  = -1;

  if (scalar(@trait_id_list) == 0) {

    $err = 1;
    $err_msg = 'No trait';

    return ($err, $err_msg, $err_trait_id, $err_val_idx);
  }

  my $sql = '';
  $sql   .= 'SELECT TraitId, TraitValRule, TraitValRuleErrMsg ';
  $sql   .= 'FROM trait ';
  $sql   .= 'WHERE TraitId IN (' . join(',', @trait_id_list) . ')';

  my ($r_trait_err, $r_trait_msg, $validation_data) = read_data($dbh, $sql, []);

  if ($r_trait_err) {

    $err = 1;
    $err_msg = 'Read trait validation rule failed: ' . $r_trait_msg;

    return ($err, $err_msg, $err_trait_id, $err_val_idx);
  }

  if (scalar(@{$validation_data}) != scalar(@trait_id_list)) {

    $err = 1;
    $err_msg = 'Some validation rules are missing';

    return ($err, $err_msg, $err_trait_id, $err_val_idx);
  }

  my $trait_id2validation_href = {};

  foreach my $valid_rec (@{$validation_data}) {

    my $trait_id = $valid_rec->{'TraitId'};
    my $val_rule = $valid_rec->{'TraitValRule'};
    my $val_msg  = $valid_rec->{'TraitValRuleErrMsg'};

    $trait_id2validation_href->{$trait_id} = [$val_rule, $val_msg];
  }

  # should it '[^<>=]=' => '=='
  my $operator_lookup = { 'AND'    => '&&',
                          'OR'     => '||',
                          '[^<>]=' => '==',
  };

  foreach my $trait_id (@trait_id_list) {

    my $validation_rule     = $trait_id2validation_href->{$trait_id}->[0];
    my $validation_err_msg  = $trait_id2validation_href->{$trait_id}->[1];

    my $value_aref      = $trait_id2val_href->{$trait_id};

    for (my $i = 0; $i < scalar(@{$value_aref}); $i++) {

      my $trait_value = $value_aref->[$i];

      if ($validation_rule =~ /(\w+)\((.*)\)/) {

        my $validation_rule_prefix = $1;
        my $validation_rule_body   = $2;

        if (uc($validation_rule_prefix) eq 'REGEX') {

          if (!($trait_value =~ /$validation_rule_body/)) {

            $err          = 1;
            $err_msg      = $validation_err_msg;
            $err_trait_id = $trait_id;
            $err_val_idx  = $i;
          }
        }
        elsif (uc($validation_rule_prefix) eq 'BOOLEX') {

          if ($validation_rule_body !~ /x/) {

            $err           = 1;
            $err_msg       = 'No variable x in boolean expression.';
            $err_trait_id  = $trait_id;
            $err_val_idx   = $i;
          }
          elsif ( ($validation_rule_body =~ /\&/) ||
                  ($validation_rule_body =~ /\|/) ) {

            $err           = 1;
            $err_msg       = 'Contain forbidden characters';
            $err_trait_id  = $trait_id;
            $err_val_idx   = $i;
          }
          elsif ( $validation_rule_body =~ /\d+\.?\d*\s*,/) {

            $err           = 1;
            $err_msg       = 'Contain a comma - invalid boolean expression';
            $err_trait_id  = $trait_id;
            $err_val_idx   = $i;
          }
          else {

            if ($trait_value =~ /^[-+]?\d+\.?\d*$/) {

              $validation_rule_body =~ s/x/ $trait_value /ig;
            }
            else {

              $validation_rule_body =~ s/x/ '$trait_value' /ig;
            }

            for my $operator (keys(%{$operator_lookup})) {

              my $perl_operator = $operator_lookup->{$operator};
              $validation_rule_body =~ s/$operator/$perl_operator/ig;
            }

            my $test_condition;

            eval(q{$test_condition = } . qq{($validation_rule_body) ? 1 : 0;});

            if($@) {

              $err           = 1;
              $err_msg       = "Invalid boolean trait value validation expression ($validation_rule_body).";
              $err_trait_id  = $trait_id;
              $err_val_idx   = $i;
            }
            else {

              if ($test_condition == 0) {

                $err          = 1;
                $err_msg      = $validation_err_msg;
                $err_trait_id = $trait_id;
                $err_val_idx  = $i;
              }
              else {

                $err          = 0;
                $err_msg      = '';
                $err_trait_id = -1;
                $err_val_idx  = -1;
              }
            }
          }
        }
        elsif (uc($validation_rule_prefix) eq 'CHOICE') {

          if ($validation_rule_body =~ /^\[.*\]$/) {

            $err          = 1;
            $err_msg      = 'Invalid choice expression containing [].';
            $err_trait_id = $trait_id;
            $err_val_idx  = $i;
          }
          else {

            my @choice_list = split(/\|/, $validation_rule_body);

            $err          = 1;
            $err_msg      = $validation_err_msg;
            $err_trait_id = $trait_id;
            $err_val_idx  = $i;

            foreach my $choice (@choice_list) {

              if (lc("$choice") eq lc("$trait_value")) {

                $err          = 0;
                $err_msg      = '';
                $err_trait_id = -1;
                $err_val_idx  = -1;
                last;
              }
            }
          }
        }
        elsif ( (uc($validation_rule_prefix) eq 'DATE_RANGE') ) {

          if ($trait_value !~ /^\d{4}\-\d{2}\-\d{2}( \d{2}\:\d{2}\:\d{2})?$/) {

            $err     = 1;
            $err_msg = 'Invalid date';
          }
        }
        elsif ( (uc($validation_rule_prefix) eq 'RANGE')   ||
                (uc($validation_rule_prefix) eq 'LERANGE') ||
                (uc($validation_rule_prefix) eq 'RERANGE') ||
                (uc($validation_rule_prefix) eq 'BERANGE') ) {

          if ($validation_rule_body !~ /^[-+]?\d+\.?\d*\s*\.\.\s*[-+]?\d+\.?\d*$/) {

            $err          = 1;
            $err_msg      = 'Invalid range expression';
            $err_trait_id = $trait_id;
            $err_val_idx  = $i;
          }
          else {

            $err          = 1;
            $err_msg      = $validation_err_msg;
            $err_trait_id = $trait_id;
            $err_val_idx  = $i;

            if ($trait_value =~ /^[-+]?\d+\.?\d*$/) {

              my ($left_val, $right_val) = split(/\s*\.\.\s*/, $validation_rule_body);

              if (uc($validation_rule_prefix) eq 'RANGE') {

                if ($trait_value >= $left_val && $trait_value <= $right_val) {

                  $err          = 0;
                  $err_msg      = '';
                  $err_trait_id = -1;
                  $err_val_idx  = -1;
                }
              }
              elsif (uc($validation_rule_prefix) eq 'LERANGE') {

                if ($trait_value > $left_val && $trait_value <= $right_val) {

                  $err          = 0;
                  $err_msg      = '';
                  $err_trait_id = -1;
                  $err_val_idx  = -1;
                }
              }
              elsif (uc($validation_rule_prefix) eq 'RERANGE') {

                if ($trait_value >= $left_val && $trait_value < $right_val) {

                  $err          = 0;
                  $err_msg      = '';
                  $err_trait_id = -1;
                  $err_val_idx  = -1;
                }
              }
              elsif (uc($validation_rule_prefix) eq 'BERANGE') {

                if ($trait_value > $left_val && $trait_value < $right_val) {

                  $err          = 0;
                  $err_msg      = '';
                  $err_trait_id = -1;
                  $err_val_idx  = -1;
                }
              }
            }
            else {

              $err          = 1;
              $err_msg      = "Trait value ($trait_value) not a valid number";
              $err_trait_id = $trait_id;
              $err_val_idx  = $i;
            }
          }
        }
        else {

          $err          = 1;
          $err_msg      = 'Unknown trait value validation rule.';
          $err_trait_id = $trait_id;
          $err_val_idx  = $i;
        }
      }
      else {

        $err          = 1;
        $err_msg      = "Unknown validation rule.";
        $err_trait_id = $trait_id;
        $err_val_idx  = $i;
      }

      if ($err) {

        return ($err, $err_msg, $err_trait_id, $err_val_idx);
      }
    }
  }

  return ($err, $err_msg, $err_trait_id, $err_val_idx);
}

1;
