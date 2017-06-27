#$Id$
#$Author$

# Copyright (c) 2011, Diversity Arrays Technology, All rights reserved.

# Author    : Puthick Hok
# Created   : 02/09/2013
# Modified  :
# Purpose   : 
#          
#          

package KDDArT::DAL::Extract;

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
use XML::Checker::Parser;
use Time::HiRes qw( tv_interval gettimeofday );
use Crypt::Random qw( makerandom );

sub setup {

  my $self = shift;

  CGI::Session->name("KDDArT_DAL_SESSID");

  __PACKAGE__->authen->init_config_parameters();
  __PACKAGE__->authen->check_login_runmodes(':all');
  __PACKAGE__->authen->check_content_type_runmodes(':all');
  __PACKAGE__->authen->check_rand_runmodes('add_plate_gadmin',
                                           'update_plate_gadmin',
                                           'del_plate_gadmin',
                                           'add_extract_gadmin',
                                           'update_extract_gadmin',
                                           'del_extract_gadmin',
                                           'add_analysisgroup',
                                           'update_analysisgroup',
                                           'add_plate_n_extract_gadmin',
                                           'import_plate_n_extract_gadmin',
      );
  __PACKAGE__->authen->count_session_request_runmodes(':all');

  __PACKAGE__->authen->check_signature_runmodes('update_plate_gadmin',
                                                'del_plate_gadmin',
                                                'add_extract_gadmin',
                                                'update_extract_gadmin',
                                                'del_extract_gadmin',
      );
  __PACKAGE__->authen->check_gadmin_runmodes('add_plate_gadmin',
                                             'update_plate_gadmin',
                                             'del_plate_gadmin',
                                             'add_extract_gadmin',
                                             'update_extract_gadmin',
                                             'del_extract_gadmin',
                                             'add_plate_n_extract_gadmin',
                                             'add_plate_gadmin',
                                             'import_plate_n_extract_gadmin',

      );
  __PACKAGE__->authen->check_sign_upload_runmodes('add_analysisgroup',
                                                  'add_plate_n_extract_gadmin',
                                                  'add_plate_gadmin',
                                                  'import_plate_n_extract_gadmin',
      );

  $self->run_modes(
    'list_plate_advanced'           => 'list_plate_advanced_runmode',
    'add_plate_gadmin'              => 'add_plate_runmode',
    'update_plate_gadmin'           => 'update_plate_runmode',
    'del_plate_gadmin'              => 'del_plate_runmode',
    'get_plate'                     => 'get_plate_runmode',
    'list_extract_advanced'         => 'list_extract_advanced_runmode',
    'add_extract_gadmin'            => 'add_extract_runmode',
    'del_extract_gadmin'            => 'del_extract_runmode',
    'update_extract_gadmin'         => 'update_extract_runmode',
    'get_extract'                   => 'get_extract_runmode',
    'add_analysisgroup'             => 'add_analysisgroup_runmode',
    'update_analysisgroup'          => 'update_analysisgroup_runmode',
    'list_analysisgroup_advanced'   => 'list_analysisgroup_advanced_runmode',
    'get_analysisgroup'             => 'get_analysisgroup_runmode',
    'add_plate_n_extract_gadmin'    => 'add_plate_n_extract_runmode',
    'list_dataset'                  => 'list_dataset_runmode',
    'import_plate_n_extract_gadmin' => 'import_plate_n_extract_runmode',
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

sub list_plate_advanced_runmode {

=pod list_plate_advanced_HELP_START
{
"OperationName": "List plates",
"Description": "List DNA extract plates. This listing requires pagination information.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination NumOfRecords='1' NumOfPages='1' Page='1' NumPerPage='1' /><RecordMeta TagName='Plate' /><Plate PlateDescription='Plate Testing' OperatorId='0' DateCreated='2014-07-01 13:18:19' PlateName='Plate_8228736' PlateStatus='' StorageId='0' PlateWells='0' UserName='admin' PlateId='1' PlateType='56' update='update/plate/1'><Extract WellCol='1' WellRow='A' ExtractId='2' GenotypeId='0' ItemGroupId='1' /><Extract WellCol='2' WellRow='A' ExtractId='3' GenotypeId='0' ItemGroupId='1' /><Extract WellCol='3' WellRow='A' ExtractId='4' GenotypeId='0' ItemGroupId='1' /><Extract WellCol='6' WellRow='A' ExtractId='5' GenotypeId='0' ItemGroupId='1' /><Extract WellCol='4' WellRow='A' ExtractId='6' GenotypeId='0' ItemGroupId='1' /><Extract WellCol='5' WellRow='A' ExtractId='7' GenotypeId='0' ItemGroupId='1' /></Plate></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfRecords' : '1','NumOfPages' : 1,'NumPerPage' : '1','Page' : '1'}],'VCol' : [],'RecordMeta' : [{'TagName' : 'Plate'}],'Plate' : [{'PlateDescription' : 'Plate Testing','Extract' : [{'WellRow' : 'A','WellCol' : '1','ExtractId' : '2','GenotypeId' : '0','ItemGroupId' : '1'},{'WellRow' : 'A','WellCol' : '2','ExtractId' : '3','GenotypeId' : '0','ItemGroupId' : '1'},{'WellRow' : 'A','WellCol' : '3','ExtractId' : '4','GenotypeId' : '0','ItemGroupId' : '1'},{'WellRow' : 'A','WellCol' : '6','ExtractId' : '5','GenotypeId' : '0','ItemGroupId' : '1'},{'WellRow' : 'A','WellCol' : '4','ExtractId' : '6','GenotypeId' : '0','ItemGroupId' : '1'},{'WellRow' : 'A','WellCol' : '5','ExtractId' : '7','GenotypeId' : '0','ItemGroupId' : '1'}],'PlateName' : 'Plate_8228736','DateCreated' : '2014-07-01 13:18:19','OperatorId' : '0','StorageId' : '0','PlateStatus' : '','PlateWells' : '0','UserName' : 'admin','PlateId' : '1','update' : 'update/plate/1','PlateType' : '56'}]}",
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

  my $dbh_k = connect_kdb_read();
  my $dbh_m = connect_mdb_read();

  my $field_list = ['*'];

  my $other_join = '';

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_mfactor_sql($dbh_m, $dbh_k,
                                                                         $field_list, 'plate',
                                                                        'PlateId', $other_join);

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql .= " LIMIT 1";

  my ($sam_plate_err, $sam_plate_msg, $sam_plate_list_aref) = $self->list_plate(0, $sql, []);

  if ($sam_plate_err) {

    $self->logger->debug("List sample plate failed: $sam_plate_msg");
    my $err_msg = 'Unexpected Error.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sample_data_aref = $sam_plate_list_aref;

  my @field_list_all;

  if (scalar(@{$sample_data_aref}) == 1) {

    @field_list_all = keys(%{$sample_data_aref->[0]});
  }
  else {

    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh_m, 'plate');

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

  my $final_field_list = \@field_list_all;

  if (length($field_list_csv) > 0) {

    my ($sel_field_err, $sel_field_msg, $sel_field_list) = parse_selected_field($field_list_csv,
                                                                                $final_field_list,
                                                                                'PlateId');

    if ($sel_field_err) {

      $self->logger->debug("Parse selected field failed: $sel_field_msg");
      my $err_msg = $sel_field_msg;
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;
  }

  $other_join = '';

  ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_mfactor_sql($dbh_m, $dbh_k,
                                                                      $final_field_list, 'plate',
                                                                     'PlateId', $other_join);

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering('"PlateId"',
                                                                              '"plate"',
                                                                              $filtering_csv,
                                                                              $final_field_list);

  $self->logger->debug("Filter phrase: $filter_phrase");

  if ($filter_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $filter_msg}]};

    return $data_for_postrun_href;
  }

  my $filtering_exp = '';
  if (length($filter_phrase) > 0) {

    $filtering_exp = " WHERE $filter_phrase ";
  }

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
                                                                   '"plate"',
                                                                   '"PlateId"',
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

  $dbh_k->disconnect();
  $dbh_m->disconnect();

  $sql .= " $filtering_exp ";

  # Disable virtual column

  #$sql  =~ s/GROUP BY/ $filtering_exp GROUP BY /;

  my ($sort_err, $sort_msg, $sort_sql) = parse_sorting($sorting, $final_field_list, '"plate"');

  if ($sort_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sort_msg}]};

    return $data_for_postrun_href;
  }

  if (length($sort_sql) > 0) {

    $sql .= " ORDER BY $sort_sql ";
  }
  else {

    $sql .= ' ORDER BY "plate"."PlateId" DESC';
  }

  $sql .= " $paged_limit_clause ";

  $self->logger->debug("SQL with VCol: $sql");

  my $data_start_time = [gettimeofday()];

  # where_arg here in the list function because of the filtering 
  my ($read_plate_err, $read_plate_msg, $plate_data) = $self->list_plate(1,
                                                                         $sql,
                                                                         $where_arg);

  my $data_elapsed = tv_interval($data_start_time);

  if ($read_plate_err) {

    $self->logger->debug($read_plate_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'} = 0;
  $data_for_postrun_href->{'Data'}  = {'Plate'      => $plate_data,
                                       'VCol'       => $vcol_list,
                                       'Pagination' => $pagination_aref,
                                       'RecordMeta' => [{'TagName' => 'Plate'}],
  };

  return $data_for_postrun_href;
}

sub list_plate {

  my $self              = $_[0];
  my $extra_attr_yes    = $_[1];
  my $sql               = $_[2];
  my $where_para_aref   = $_[3];

  my $err = 0;
  my $msg = '';

  my $data_aref = [];

  my $dbh_m = connect_mdb_read();
  my $dbh_k = connect_kdb_read();

  ($err, $msg, $data_aref) = read_data($dbh_m, $sql, $where_para_aref);

  if ($err) {

    return ($err, $msg, []);
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $plate_id_aref        = [];
  my $user_id_href         = {};
  my $plate_type_id_href   = {};
  my $plate_status_href    = {};

  my $chk_id_err        = 0;
  my $chk_id_msg        = '';
  my $used_id_href      = {};
  my $not_used_id_href  = {};

  my $user_lookup         = {};
  my $plate_type_lookup   = {};
  my $plate_status_lookup = {};

  if ($extra_attr_yes) {

    for my $plate_row (@{$data_aref}) {

      push(@{$plate_id_aref}, $plate_row->{'PlateId'});

      if (defined $plate_row->{'OperatorId'}) {

        $user_id_href->{$plate_row->{'OperatorId'}} = 1;
      }

      if (defined $plate_row->{'PlateType'}) {

        $plate_type_id_href->{$plate_row->{'PlateType'}} = 1;
      }

      if (defined $plate_row->{'PlateStatus'}) {

        if (length($plate_row->{'PlateStatus'}) > 0) {

          if (uc($plate_row->{'PlateStatus'}) ne 'NULL') {

            $plate_status_href->{$plate_row->{'PlateStatus'}} = 1;
          }
        }
      }
    }

    if (scalar(@{$plate_id_aref}) > 0) {

      my $chk_table_aref = [{'TableName' => 'extract', 'FieldName' => 'PlateId'}];

      ($chk_id_err, $chk_id_msg,
       $used_id_href, $not_used_id_href) = id_existence_bulk($dbh_m, $chk_table_aref, $plate_id_aref);

      if ($chk_id_err) {

        $self->logger->debug("Check id existence error: $chk_id_msg");
        $err = 1;
        $msg = $chk_id_msg;

        return ($err, $msg, []);
      }
    }

    if (scalar(keys(%{$user_id_href})) > 0) {

      my $user_sql = 'SELECT UserId, UserName FROM systemuser ';
      $user_sql   .= 'WHERE UserId IN (' . join(',', keys(%{$user_id_href})) . ')';

      $self->logger->debug("USER_SQL: $user_sql");

      my $user_sth = $dbh_k->prepare($user_sql);
      $user_sth->execute();
      $user_lookup = $user_sth->fetchall_hashref('UserId');
      $user_sth->finish();
    }

    if (scalar(keys(%{$plate_type_id_href})) > 0) {

      my $ptype_sql = 'SELECT TypeId, TypeName FROM generaltype ';
      $ptype_sql   .= 'WHERE TypeId IN (' . join(',', keys(%{$plate_type_id_href})) . ')';

      $self->logger->debug("PLATE TYPE SQL: $ptype_sql");

      my $ptype_sth = $dbh_k->prepare($ptype_sql);
      $ptype_sth->execute();
      $plate_type_lookup = $ptype_sth->fetchall_hashref('TypeId');
      $ptype_sth->finish();
    }

    if (scalar(keys(%{$plate_status_href})) > 0) {

      my $pstatus_sql = 'SELECT TypeId, TypeName FROM generaltype ';
      $pstatus_sql   .= 'WHERE TypeId IN (' . join(',', keys(%{$plate_status_href})) . ')';

      $self->logger->debug("PLATE STATUS SQL: $pstatus_sql");

      my $pstatus_sth = $dbh_k->prepare($pstatus_sql);
      $pstatus_sth->execute();
      $plate_status_lookup = $pstatus_sth->fetchall_hashref->{'TypeId'};
      $pstatus_sth->finish();
    }
  }

  my @extra_attr_plate_data;

  for my $plate_row (@{$data_aref}) {

    my $plate_id    = $plate_row->{'PlateId'};
    my $operator_id = $plate_row->{'OperatorId'};

    if ($extra_attr_yes) {

      $plate_row->{'UserName'} = $user_lookup->{$operator_id}->{'UserName'};

      if (defined $plate_row->{'PlateType'}) {

        my $plate_type =  $plate_row->{'PlateType'};

        if (defined $plate_type_lookup->{$plate_type}) {

          my $plate_type_name = $plate_type_lookup->{$plate_type}->{'TypeName'};
          $plate_row->{'PlateTypeName'} = $plate_type_name;
        }
      }

      if (defined $plate_row->{'PlateStatus'}) {

        my $plate_status = $plate_row->{'PlateStatus'};

        if (defined $plate_status_lookup->{$plate_status}) {

          my $plate_status_name = $plate_status_lookup->{$plate_status}->{'TypeName'};
          $plate_row->{'PlateStatusName'} = $plate_status_name;
        }
      }

      if ($gadmin_status eq '1') {

        $plate_row->{'update'} = "update/plate/$plate_id";

        if ($not_used_id_href->{$plate_id}) {

          $plate_row->{'delete'} = "delete/plate/$plate_id";
        }
      }
    }
    push(@extra_attr_plate_data, $plate_row);
  }

  $dbh_k->disconnect();
  $dbh_m->disconnect();

  return ($err, $msg, \@extra_attr_plate_data);
}

sub del_plate_runmode {

=pod del_plate_gadmin_HELP_START
{
"OperationName": "Delete plate",
"Description": "Delete DNA plate for a specified plate id. Plate can be deleted only if not attached to any lower level related record.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Plate (5) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Plate (6) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdUsed": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Plate (1) is used in extract.' /></DATA>"}],
"ErrorMessageJSON": [{"IdUsed": "{'Error' : [{'Message' : 'Plate (1) is used in extract.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing PlateId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $plate_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_m_read = connect_mdb_read();

  my $plate_exist = record_existence($dbh_m_read, 'plate', 'PlateId', $plate_id);

  if (!$plate_exist) {

    my $err_msg = "Plate ($plate_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $plate_in_extract = record_existence($dbh_m_read, 'extract', 'PlateId', $plate_id);

  if ($plate_in_extract) {

    my $err_msg = "Plate ($plate_id) is used in extract.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_m_read->disconnect();

  my $dbh_m_write = connect_mdb_write();

  my $sql = 'DELETE FROM "platefactor" WHERE "PlateId"=?';
  my $sth = $dbh_m_write->prepare($sql);

  $sth->execute($plate_id);

  if ($dbh_m_write->err()) {

    $self->logger->debug("Delete platefactor failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $sql = 'DELETE FROM "plate" WHERE "PlateId"=?';
  $sth = $dbh_m_write->prepare($sql);

  $sth->execute($plate_id);

  if ($dbh_m_write->err()) {

    $self->logger->debug("Delete plate failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_m_write->disconnect();

  my $info_msg_aref = [{'Message' => "Plate ($plate_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_plate_runmode {

=pod update_plate_gadmin_HELP_START
{
"OperationName": "Update plate",
"Description": "Update DNA plate information specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "marker",
"KDDArTTable": "plate",
"KDDArTFactorTable": "platefactor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Plate (3) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Plate (3) has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error PlateType='PlateType (251) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'PlateType' : 'PlateType (251) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing PlateId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $plate_id = $self->param('id');
  my $query      = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_mdb_read();

  my $skip_field = {'DateCreated' => 1};

  my $field_name_translation = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'plate', $skip_field,
                                                                                $field_name_translation,
                                                                               );

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $dbh_k_read = connect_kdb_read();
  my $dbh_m_read = connect_mdb_read();

  my $plate_exist = record_existence($dbh_m_read, 'plate', 'PlateId', $plate_id);

  if (!$plate_exist) {

    my $err_msg = "Plate ($plate_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $PlateName        = $query->param('PlateName');
  my $OperatorId       = $query->param('OperatorId');

  my $read_p_sql       =  'SELECT "PlateType", "PlateDescription", "StorageId", "PlateWells", "PlateStatus" ';
     $read_p_sql      .=  'FROM plate WHERE "PlateId"=? ';


  my ($r_df_val_err, $r_df_val_msg, $p_df_val_data) = read_data($dbh_m_read, $read_p_sql, [$plate_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve plate default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $PlateType           =  undef;
  my $PlateDescription    =  undef;
  my $StorageId           =  undef;
  my $PlateWells          =  undef;
  my $PlateStatus         =  undef;

  my $nb_df_val_rec    =  scalar(@{$p_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve plate default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $PlateType             =   $p_df_val_data->[0]->{'PlateType'};
  $PlateDescription      =   $p_df_val_data->[0]->{'PlateDescription'};
  $StorageId             =   $p_df_val_data->[0]->{'StorageId'};
  $PlateWells            =   $p_df_val_data->[0]->{'PlateWells'};
  $PlateStatus           =   $p_df_val_data->[0]->{'PlateStatus'};


  if (defined($query->param('PlateType'))) {

    if (length($query->param('PlateType')) > 0) {

      $PlateType = $query->param('PlateType');
    }
  }

  if (length($PlateType) == 0) {

    $PlateType = '0';
  }


  if (defined($query->param('PlateDescription'))) {

    $PlateDescription = $query->param('PlateDescription');
  }


  if (defined($query->param('StorageId'))) {

    if (length($query->param('StorageId')) > 0) {

      $StorageId = $query->param('StorageId');
    }
  }

  if (length($StorageId) == 0) {

    $StorageId = '0';
  }


  if (defined($query->param('PlateWells'))) {

    if (legnth($query->param('PlateWells')) > 0) {

      $PlateWells = $query->param('PlateWells');
    }
  }


  if (defined($query->param('PlateStatus'))) {

    $PlateStatus = $query->param('PlateStatus');
  }

  if (length($PlateWells) > 0) {

    my ($int_err, $int_href) = check_integer_href( {'PlateWells' => $PlateWells} );

    if ($int_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [$int_href]};

      return $data_for_postrun_href;
    }
  }
  else {

    $PlateWells = undef;
  }

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='platefactor'";

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

  if (!record_existence($dbh_k_read, 'systemuser', 'UserId', $OperatorId)) {

    my $err_msg = "OperatorId ($OperatorId) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ($PlateType ne '0') {

    if (!type_existence($dbh_k_read, 'plate', $PlateType)) {

      my $err_msg = "PlateType ($PlateType) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'PlateType' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if ($StorageId ne '0') {

    if ( !record_existence($dbh_k_read, 'storage', 'StorageId', $StorageId) ) {

      my $err_msg = "StorageId ($StorageId) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $plate_sql = 'SELECT "PlateId" FROM "plate" WHERE "PlateId" <> ? AND "PlateName"=?';

  my ($read_plate_err, $exist_plate_id) = read_cell($dbh_m_read, $plate_sql, [$plate_id, $PlateName]);

  if (length($exist_plate_id) > 0) {

    my $err_msg = "($PlateName) already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'PlateName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();
  $dbh_m_read->disconnect();

  my $dbh_m_write = connect_mdb_write();

  $sql  = 'UPDATE "plate" SET ';
  $sql .= '"PlateName"=?, ';
  $sql .= '"OperatorId"=?, ';
  $sql .= '"PlateType"=?, ';
  $sql .= '"PlateDescription"=?, ';
  $sql .= '"StorageId"=?, ';
  $sql .= '"PlateWells"=?, ';
  $sql .= '"PlateStatus"=? ';
  $sql .= 'WHERE "PlateId"=?';

  my $sth = $dbh_m_write->prepare($sql);
  $sth->execute($PlateName, $OperatorId, $PlateType,
                $PlateDescription, $StorageId, $PlateWells, $PlateStatus, $plate_id);

  if ($dbh_m_write->err()) {

    $self->logger->debug("Update plate failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  for my $vcol_id (keys(%{$vcol_data})) {

    my $factor_value = $query->param('VCol_' . "$vcol_id");

    $sql  = 'SELECT Count(*) ';
    $sql .= 'FROM "platefactor" ';
    $sql .= 'WHERE "PlateId"=? AND "FactorId"=?';

    my ($read_err, $count) = read_cell($dbh_m_write, $sql, [$plate_id, $vcol_id]);

    if (length($factor_value) > 0) {

      if ($count > 0) {

        $sql  = 'UPDATE "platefactor" SET ';
        $sql .= '"FactorValue"=? ';
        $sql .= 'WHERE "PlateId"=? AND "FactorId"=?';

        my $factor_sth = $dbh_m_write->prepare($sql);
        $factor_sth->execute($factor_value, $plate_id, $vcol_id);

        if ($dbh_m_write->err()) {

          $self->logger->debug("Update platefactor failed");
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

          return $data_for_postrun_href;
        }

        $factor_sth->finish();
      }
      else {

        $sql  = 'INSERT INTO "platefactor"(';
        $sql .= '"PlateId", ';
        $sql .= '"FactorId", ';
        $sql .= '"FactorValue") ';
        $sql .= 'VALUES(?, ?, ?)';

        my $factor_sth = $dbh_m_write->prepare($sql);
        $factor_sth->execute($plate_id, $vcol_id, $factor_value);

        if ($dbh_m_write->err()) {

          $self->logger->debug("Insert into platefactor failed");
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

          return $data_for_postrun_href;
        }

        $factor_sth->finish();
      }
    }
    else {

      if ($count > 0) {

        $sql  = 'DELETE FROM "platefactor" ';
        $sql .= 'WHERE "PlateId"=? AND "FactorId"=?';

        my $factor_sth = $dbh_m_write->prepare($sql);
        $factor_sth->execute($plate_id, $vcol_id);

        if ($dbh_m_write->err()) {

          $self->logger->debug("Delete platefactor failed");
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

          return $data_for_postrun_href;
        }
        $factor_sth->finish();
      }
    }
  }

  $dbh_m_write->disconnect();

  my $info_msg_aref = [{'Message' => "Plate ($plate_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub get_plate_runmode {

=pod get_plate_HELP_START
{
"OperationName": "Get plate",
"Description": "Get detailed information about the DNA plate specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='Plate' /><Plate PlateDescription='Plate Testing' OperatorId='0' DateCreated='2014-07-01 13:18:19' PlateName='Plate_8228736' PlateStatus='' StorageId='0' PlateWells='0' UserName='admin' PlateId='1' PlateType='56' update='update/plate/1'><Extract WellCol='1' WellRow='A' ExtractId='2' GenotypeId='0' ItemGroupId='1' /><Extract WellCol='2' WellRow='A' ExtractId='3' GenotypeId='0' ItemGroupId='1' /><Extract WellCol='3' WellRow='A' ExtractId='4' GenotypeId='0' ItemGroupId='1' /><Extract WellCol='6' WellRow='A' ExtractId='5' GenotypeId='0' ItemGroupId='1' /><Extract WellCol='4' WellRow='A' ExtractId='6' GenotypeId='0' ItemGroupId='1' /><Extract WellCol='5' WellRow='A' ExtractId='7' GenotypeId='0' ItemGroupId='1' /></Plate></DATA>",
"SuccessMessageJSON": "{'VCol' : [],'RecordMeta' : [{'TagName' : 'Plate'}],'Plate' : [{'PlateDescription' : 'Plate Testing','Extract' : [{'WellRow' : 'A','WellCol' : '1','ExtractId' : '2','GenotypeId' : '0','ItemGroupId' : '1'},{'WellRow' : 'A','WellCol' : '2','ExtractId' : '3','GenotypeId' : '0','ItemGroupId' : '1'},{'WellRow' : 'A','WellCol' : '3','ExtractId' : '4','GenotypeId' : '0','ItemGroupId' : '1'},{'WellRow' : 'A','WellCol' : '6','ExtractId' : '5','GenotypeId' : '0','ItemGroupId' : '1'},{'WellRow' : 'A','WellCol' : '4','ExtractId' : '6','GenotypeId' : '0','ItemGroupId' : '1'},{'WellRow' : 'A','WellCol' : '5','ExtractId' : '7','GenotypeId' : '0','ItemGroupId' : '1'}],'PlateName' : 'Plate_8228736','DateCreated' : '2014-07-01 13:18:19','OperatorId' : '0','StorageId' : '0','PlateStatus' : '','PlateWells' : '0','UserName' : 'admin','PlateId' : '1','update' : 'update/plate/1','PlateType' : '56'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Plate (6) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Plate (6) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing PlateId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $plate_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_m = connect_mdb_read();
  my $plate_exist = record_existence($dbh_m, 'plate', 'PlateId', $plate_id);
  $dbh_m->disconnect();

  if (!$plate_exist) {

    my $err_msg = "Plate ($plate_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_k = connect_kdb_read();
  $dbh_m    = connect_mdb_read();

  my $field_list = ['*'];

  my $other_join = '';

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_mfactor_sql($dbh_m, $dbh_k,
                                                                         $field_list, 'plate',
                                                                        'PlateId', $other_join);

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $where_clause = qq| WHERE "plate"."PlateId"=? |;

  $sql .= " $where_clause ";

  # Disable virtual column
  #$sql =~ s/GROUP BY/ $where_clause GROUP BY /;

  $self->logger->debug("SQL: $sql");

  my ($plate_err, $plate_msg, $plate_list_aref) = $self->list_plate(1, $sql, [$plate_id]);

  if ($plate_err) {

    $self->logger->debug("List plate failed: $plate_msg");
    my $err_msg = 'Unexpected Error.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'} = 0;
  $data_for_postrun_href->{'Data'}  = {'Plate'      => $plate_list_aref,
                                       'VCol'       => $vcol_list,
                                       'RecordMeta' => [{'TagName' => 'Plate'}],
  };

  return $data_for_postrun_href;
}

sub logger {

  my $self = shift;
  return $self->{logger};
}

sub list_extract {

  my $self              = $_[0];
  my $extra_attr_yes    = $_[1];
  my $sql               = $_[2];
  my $where_para_aref   = $_[3];

  my $err = 0;
  my $msg = '';

  my $data_aref = [];

  my $dbh_m = connect_mdb_read();
  my $dbh_k = connect_kdb_read();

  $self->logger->debug("SQL: $sql");

  ($err, $msg, $data_aref) = read_data($dbh_m, $sql, $where_para_aref);

  if ($err) {

    return ($err, $msg, []);
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $extract_id_aref = [];
  my $itm_grp_id_href = {};
  my $geno_id_href    = {};
  my $tissue_href     = {};

  my $chk_id_err        = 0;
  my $chk_id_msg        = '';
  my $used_id_href      = {};
  my $not_used_id_href  = {};

  my $analysisgroup_lookup = {};
  my $item_group_lookup    = {};
  my $genotype_lookup      = {};
  my $tissue_lookup        = {};

  if ($extra_attr_yes) {

    for my $extract_row (@{$data_aref}) {

      push(@{$extract_id_aref}, $extract_row->{'ExtractId'});

      if (defined $extract_row->{'ItemGroupId'}) {

        $itm_grp_id_href->{$extract_row->{'ItemGroupId'}} = 1;
      }

      if (defined $extract_row->{'GenotypeId'}) {

        $geno_id_href->{$extract_row->{'GenotypeId'}} = 1;
      }

      if (defined $extract_row->{'Tissue'}) {

        $tissue_href->{$extract_row->{'Tissue'}} = 1;
      }
    }

    if (scalar(@{$extract_id_aref}) > 0) {

      my $chk_table_aref = [{'TableName' => 'analgroupextract', 'FieldName' => 'ExtractId'}];

      ($chk_id_err, $chk_id_msg,
       $used_id_href, $not_used_id_href) = id_existence_bulk($dbh_m, $chk_table_aref, $extract_id_aref);

      if ($chk_id_err) {

        $self->logger->debug("Check id existence error: $chk_id_msg");
        $err = 1;
        $msg = $chk_id_msg;

        return ($err, $msg, []);
      }

      my $perm_str = permission_phrase($group_id, 2, 'analysisgroup');

      my $analysis_grp_sql = 'SELECT "analgroupextract"."ExtractId", "analysisgroup"."AnalysisGroupId", ';
      $analysis_grp_sql   .= '"analysisgroup"."AnalysisGroupName" ';
      $analysis_grp_sql   .= 'FROM "analysisgroup" LEFT JOIN "analgroupextract" ON ';
      $analysis_grp_sql   .= '"analysisgroup"."AnalysisGroupId" = "analgroupextract"."AnalysisGroupId" ';
      $analysis_grp_sql   .= 'WHERE "analgroupextract"."ExtractId" IN (' . join(',', @{$extract_id_aref}) . ') ';
      $analysis_grp_sql   .= " AND ((($perm_str) & $READ_PERM) = $READ_PERM)";

      $self->logger->debug("AnalysisGroup permission SQL: $analysis_grp_sql");

      $dbh_m->disconnect();

      # Need to disconnect and reconnect again because on a VM the Perl DBD connector to Monetdb does not
      # work if this is not done this way.

      $dbh_m = connect_mdb_read();

      my ($analysis_grp_err, $analysis_grp_msg, $analysis_grp_data) = read_data($dbh_m, $analysis_grp_sql, []);

      if ($analysis_grp_err) {

        return ($analysis_grp_err, $analysis_grp_msg, []);
      }

      for my $anal_grp_row (@{$analysis_grp_data}) {

        my $extract_id = $anal_grp_row->{'ExtractId'};

        if (defined $analysisgroup_lookup->{$extract_id}) {

          my $anal_grp_aref = $analysisgroup_lookup->{$extract_id};
          delete($anal_grp_row->{'ExtractId'});
          push(@{$anal_grp_aref}, $anal_grp_row);
          $analysisgroup_lookup->{$extract_id} = $anal_grp_aref;
        }
        else {

          delete($anal_grp_row->{'ExtractId'});
          $analysisgroup_lookup->{$extract_id} = [$anal_grp_row];
        }
      }
    }

    if (scalar(keys(%{$itm_grp_id_href})) > 0) {

      my $itm_grp_sql = 'SELECT ItemGroupId, ItemGroupName ';
      $itm_grp_sql   .= 'FROM itemgroup WHERE ItemGroupId IN (' . join(',', keys(%{$itm_grp_id_href})) . ')';

      $self->logger->debug("ITM_GRP_SQL: $itm_grp_sql");

      my $itm_grp_sth = $dbh_k->prepare($itm_grp_sql);
      $itm_grp_sth->execute();
      $item_group_lookup = $itm_grp_sth->fetchall_hashref('ItemGroupId');
      $itm_grp_sth->finish();

      $self->logger->debug("ITEM_GROUP_LOOKUP KEY: " . join(',', keys(%{$item_group_lookup})));
    }

    if (scalar(keys(%{$geno_id_href})) > 0) {

      my $geno_sql = 'SELECT GenotypeId, GenotypeName ';
      $geno_sql   .= 'FROM genotype WHERE GenotypeId IN (' . join(',', keys(%{$geno_id_href})) . ')';

      $self->logger->debug("GENO_SQL: $geno_sql");

      my $geno_sth = $dbh_k->prepare($geno_sql);
      $geno_sth->execute();
      $genotype_lookup = $geno_sth->fetchall_hashref('GenotypeId');
      $geno_sth->finish();
    }

    if (scalar(keys(%{$tissue_href})) > 0) {

      my $tissue_sql = 'SELECT TypeId, TypeName FROM generaltype ';
      $tissue_sql   .= 'WHERE TypeId IN (' . join(',', keys(%{$tissue_href})) . ')';

      $self->logger->debug("TISSUE SQL: $tissue_sql");

      my $tissue_sth = $dbh_k->prepare($tissue_sql);
      $tissue_sth->execute();
      $tissue_lookup = $tissue_sth->fetchall_hashref('TypeId');
      $tissue_sth->finish();
    }
  }

  my @extra_attr_extract_data;

  for my $extract_row (@{$data_aref}) {

    my $extract_id    = $extract_row->{'ExtractId'};
    my $item_group_id = $extract_row->{'ItemGroupId'};
    my $genotype_id   = $extract_row->{'GenotypeId'};

    if ($extra_attr_yes) {

      if (defined $item_group_lookup->{$item_group_id}) {

        $extract_row->{'ItemGroupName'} = $item_group_lookup->{$item_group_id}->{'ItemGroupName'};
      }

      if ("$genotype_id" ne '0') {

        if (defined $genotype_lookup->{$genotype_id}) {

          $extract_row->{'GenotypeName'} = $genotype_lookup->{$genotype_id}->{'GenotypeName'};
        }
      }

      if (defined $extract_row->{'Tissue'}) {

        my $tissue = $extract_row->{'Tissue'};

        if (defined $tissue_lookup->{$tissue}) {

          my $tissue_name = $tissue_lookup->{$tissue}->{'TypeName'};
          $extract_row->{'TissueName'} = $tissue_name;
        }
      }

      if (defined $analysisgroup_lookup->{$extract_id}) {

        $extract_row->{'AnalysisGroup'} = $analysisgroup_lookup->{$extract_id};
      }

      if ($gadmin_status eq '1') {

        $extract_row->{'update'}      = "update/extract/$extract_id";

        if ( $not_used_id_href->{$extract_id} ) {

          $extract_row->{'delete'}   = "delete/extract/$extract_id";
        }
      }
    }
    push(@extra_attr_extract_data, $extract_row);
  }

  $dbh_k->disconnect();
  $dbh_m->disconnect();

  return ($err, $msg, \@extra_attr_extract_data);
}

sub list_extract_advanced_runmode {

=pod list_extract_advanced_HELP_START
{
"OperationName": "List extracts",
"Description": "List DNA extracts available in the system. Use filtering to retrieve desired subset or list current list of extracts attached to analysis group.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Extract PlateName='Plate_8228736' Status='' WellCol='1' WellRow='A' GenotypeId='0' Tissue='0' PlateId='1' Quality='' ItemGroupName='ITM_GRP6300825' ExtractId='2' delete='delete/extract/2' ParentExtractId='0' ItemGroupId='1' update='update/extract/2' /><Extract PlateName='' Status='' WellCol='1' WellRow='A' GenotypeId='0' Tissue='0' PlateId='0' Quality='' ItemGroupName='ITM_GRP6300825' ExtractId='1' delete='delete/extract/1' ParentExtractId='0' ItemGroupId='1' update='update/extract/1' /><RecordMeta TagName='Extract' /></DATA>",
"SuccessMessageJSON": "{'VCol' : [],'Extract' : [{'PlateName' : null,'WellRow' : 'A','WellCol' : '1','Status' : '','GenotypeId' : '0','Tissue' : '0','PlateId' : '0','ItemGroupName' : 'ITM_GRP6300825','Quality' : '','delete' : 'delete/extract/1','ExtractId' : '1','ParentExtractId' : '0','update' : 'update/extract/1','ItemGroupId' : '1'}],'RecordMeta' : [{'TagName' : 'Extract'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"URLParameter": [{"ParameterName": "analid", "Description": "Existing AnalysisGroupId", "Optional": 1}, {"ParameterName": "plateid", "Description": "Existing PlateId", "Optional": 1}, {"ParameterName": "nperpage", "Description": "Number of records in a page for pagination", "Optional": 1}, {"ParameterName": "num", "Description": "The page number of the pagination", "Optional": 1}, {"ParameterName": "dsid", "Description": "Existing DataSetId", "Optional": 1}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $pagination  = 0;
  my $nb_per_page = -1;
  my $page        = -1;

  if ( (defined $self->param('nperpage')) && (defined $self->param('num')) ) {

    $pagination = 1;
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

  my $anal_id          = -1;
  my $anal_id_provided = 0;
  my $anal_where       = '';

  if (defined $self->param('analid')) {

    $anal_id           = $self->param('analid');
    $anal_id_provided  = 1;
    $anal_where        = qq|"analgroupextract"."AnalysisGroupId"=$anal_id|;
  }

  my $dataset_id          = -1;
  my $dataset_id_provided = 0;
  my $ds_where            = '';

  if (defined $self->param('dsid')) {

    $dataset_id          = $self->param('dsid');
    $dataset_id_provided = 1;
    $ds_where            = qq|"datasetextract"."DataSetId"=$dataset_id|;
  }

  my $plate_id           = -1;
  my $plate_id_provided  = 0;

  if (defined $self->param('plateid')) {

    $plate_id           = $self->param('plateid');
    $plate_id_provided  = 1;

    if ($filtering_csv =~ /PlateId\s*=\s*(.*),?/) {

      if ( "$plate_id" ne "$1" ) {

        my $err_msg = 'Duplicate filtering condition for PlateId.';
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
    else {

      if (length($filtering_csv) > 0) {

        if ($filtering_csv =~ /&$/) {

          $filtering_csv .= "PlateId=$plate_id";
        }
        else {

          $filtering_csv .= "&PlateId=$plate_id";
        }
      }
      else {

        $filtering_csv .= "PlateId=$plate_id";
      }
    }
  }

  $self->logger->debug("Filtering csv: $filtering_csv");

  my $sorting = '';

  if (defined $query->param('Sorting')) {

    $sorting = $query->param('Sorting');
  }

  my $group_id  = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $dbh_k = connect_kdb_read();
  my $dbh_m = connect_mdb_read();

  if ($anal_id_provided) {

    if (!record_existence($dbh_m, 'analysisgroup', 'AnalysisGroupId', $anal_id)) {

      my $err_msg = "AnalsysiGroup ($anal_id): not found.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my ($is_anal_grp_ok, $trouble_anal_id_aref) = check_permission($dbh_m, 'analysisgroup', 'AnalysisGroupId',
                                                                   [$anal_id], $group_id, $gadmin_status,
                                                                   $READ_PERM);

    if (!$is_anal_grp_ok) {

      my $err_msg = "AnalsysiGroup ($anal_id): permission denied.";
      $self->logger->debug($err_msg);

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if ($dataset_id_provided) {

    if (!record_existence($dbh_m, 'dataset', 'DataSetId', $dataset_id)) {

      my $err_msg = "DataSet ($dataset_id): not found.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $db_anal_id = read_cell_value($dbh_m, 'dataset', 'AnalysisGroupId', 'DataSetId', $dataset_id);

    my ($is_anal_grp_ok, $trouble_anal_id_aref) = check_permission($dbh_m, 'analysisgroup', 'AnalysisGroupId',
                                                                   [$db_anal_id], $group_id, $gadmin_status,
                                                                   $READ_PERM);

    if (!$is_anal_grp_ok) {

      my $err_msg = "AnalsysiGroup ($db_anal_id) for DataSet ($dataset_id): permission denied.";
      $self->logger->debug($err_msg);

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if ($plate_id_provided) {

    if (!record_existence($dbh_m, 'plate', 'PlateId', $plate_id)) {

      my $err_msg = "PlateId ($plate_id): not found.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  $self->logger->debug("Before generate VCOL SQL");

  my $field_list = ['*'];

  my $other_join = ' LEFT JOIN "plate" ON "extract"."PlateId" = "plate"."PlateId" ';
  $other_join   .= ' LEFT JOIN "analgroupextract" ON "analgroupextract"."ExtractId" = "extract"."ExtractId" ';
  $other_join   .= ' LEFT JOIN "datasetextract" ON "datasetextract"."AnalGroupExtractId" = "analgroupextract"."AnalGroupExtractId" ';

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_mfactor_sql($dbh_m,
                                                                         $dbh_k,
                                                                         $field_list,
                                                                         'extract',
                                                                         'ExtractId',
                                                                         $other_join);

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql .= ' LIMIT 1';

  $self->logger->debug("SQL with VCol: $sql");

  $self->logger->debug("Before list_extract");

  my ($sam_extract_err, $sam_extract_msg, $sam_extract_data) = $self->list_extract(0, $sql);

  if ($sam_extract_err) {

    $self->logger->debug($sam_extract_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $sample_data_aref = $sam_extract_data;

  my @field_list_all;

  if (scalar(@{$sample_data_aref}) == 1) {

    @field_list_all = keys(%{$sample_data_aref->[0]});
  }
  else {

    $self->logger->debug("It reaches here");
    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh_m, 'extract');

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

  my $final_field_list     = \@field_list_all;
  my $sql_field_list       = [];
  my $filtering_field_list = [];

  if (length($field_list_csv) > 0) {

    my ($sel_field_err, $sel_field_msg, $sel_field_list) = parse_selected_field($field_list_csv,
                                                                                $final_field_list,
                                                                                'ExtractId');

    if ($sel_field_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;
  }

  my $sel_field_lookup = {};

  for my $field_name (@{$final_field_list}) {

    $sel_field_lookup->{$field_name} = 1;
  }

  if (defined $sel_field_lookup->{'PlateId'}) {

    push(@{$final_field_list}, '"plate"."PlateName"');
  }

  ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_mfactor_sql($dbh_m, $dbh_k,
                                                                      $final_field_list, 'extract',
                                                                     'ExtractId', $other_join);

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering('"ExtractId"',
                                                                              '"extract"',
                                                                              $filtering_csv,
                                                                              $final_field_list
                                                                              );

  $self->logger->debug("Filter phrase: $filter_phrase");

  if ($filter_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $filter_msg}]};

    return $data_for_postrun_href;
  }

  my $filtering_exp = '';
  if (length($filter_phrase) > 0) {

    $filtering_exp = " WHERE $filter_phrase ";
  }

  if (length($anal_where) > 0) {

    if (length($filtering_exp) > 0) {

      $filtering_exp .= " AND $anal_where";
    }
    else {

      $filtering_exp .= " WHERE $anal_where";
    }
  }

  if (length($ds_where) > 0) {

    if (length($filtering_exp) > 0) {

      $filtering_exp .= " AND $ds_where";
    }
    else {

      $filtering_exp .= " WHERE $ds_where";
    }
  }

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
                                                                   '"extract"',
                                                                   '"ExtractId"',
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

  $dbh_m->disconnect();
  $dbh_k->disconnect();

  $sql .= " $filtering_exp ";

  # Disable virtual column

  #$sql  =~ s/GROUP BY/ $filtering_exp GROUP BY /;

  my ($sort_err, $sort_msg, $sort_sql) = parse_sorting($sorting, $final_field_list, '"extract"');

  if ($sort_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sort_msg}]};

    return $data_for_postrun_href;
  }

  if (length($sort_sql) > 0) {

    $sql .= " ORDER BY $sort_sql ";
  }
  else {

    $sql .= ' ORDER BY "extract"."ExtractId" DESC';
  }

  $sql .= " $paged_limit_clause ";

  $self->logger->debug("SQL with VCol: $sql");

  my ($r_extract_err, $r_extract_msg, $extract_data) = $self->list_extract(1, $sql, $where_arg);

  if ($r_extract_err) {

    $self->logger->debug($r_extract_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Extract'      => $extract_data,
                                           'VCol'         => $vcol_list,
                                           'Pagination'   => $pagination_aref,
                                           'RecordMeta'   => [{'TagName' => 'Extract'}],
  };

  return $data_for_postrun_href;
}

sub add_extract_runmode {

=pod add_extract_gadmin_HELP_START
{
"OperationName": "Add extract",
"Description": "Add a new DNA extract into the system.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "marker",
"KDDArTTable": "extract",
"KDDArTFactorTable": "extractfactor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='21' ParaName='ExtractId' /><Info Message='Extract (21) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '22','ParaName' : 'ExtractId'}],'Info' : [{'Message' : 'Extract (22) has been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error GenotypeId='Genotype (460) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'GenotypeId' : 'Genotype (460) not found.'}]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_mdb_read();

  my $skip_field = {'ParentExtractId' => 1};

  my $field_name_translation = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'extract', $skip_field,
                                                                                $field_name_translation,
                                                                               );

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $ItemGroupId = undef;

  if (defined $query->param('ItemGroupId')) {

    if (length($query->param('ItemGroupId')) > 0) {

      $ItemGroupId = $query->param('ItemGroupId');
    }
  }

  my $ParentExtractId = undef;

  if (defined($query->param('ParentExtractId'))) {

    if (length($query->param('ParentExtractId')) > 0) {

      $ParentExtractId = $query->param('ParentExtractId');
    }
  }

  my $PlateId = undef;

  if (defined($query->param('PlateId'))) {

    if (length($query->param('PlateId')) > 0) {

      $PlateId = $query->param('PlateId');
    }
  }

  my $GenotypeId = undef;

  if (defined($query->param('GenotypeId'))) {

    if (length($query->param('GenotypeId')) > 0) {

      $GenotypeId = $query->param('GenotypeId');
    }
  }

  my $Tissue = undef;

  if (defined($query->param('Tissue'))) {

    if (length($query->param('Tissue')) > 0) {

      $Tissue = $query->param('Tissue');
    }
  }

  my $WellRow = '';

  if (defined($query->param('WellRow'))) {

    if (length($query->param('WellRow')) > 0) {

      $WellRow = $query->param('WellRow');
    }
  }

  my $WellCol = '';

  if (defined($query->param('WellCol'))) {

    if (length($query->param('WellCol')) > 0) {

      $WellCol = $query->param('WellCol');
    }
  }

  my $Quality = '';

  if (defined($query->param('Quality'))) {

    if (length($query->param('Quality')) > 0) {

      $Quality = $query->param('Quality');
    }
  }

  my $Status = '';

  if (defined($query->param('Status'))) {

    if (length($query->param('Status')) > 0) {

      $Status = $query->param('Status');
    }
  }

  if ( (!(defined $ItemGroupId)) && (!(defined $GenotypeId)) ) {

    my $err_msg = "Both ItemGroupId and GenotypeId are missing.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_k_read = connect_kdb_read();
  my $dbh_m_read = connect_mdb_read();

  if (defined $ParentExtractId) {

    if (!record_existence($dbh_m_read, 'extract', 'ExtractId', $ParentExtractId)) {

      my $err_msg = "ParentExtractId ($ParentExtractId) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'ParentExtractId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (defined $ItemGroupId) {

    if (!record_existence($dbh_k_read, 'itemgroup', 'ItemGroupId', $ItemGroupId)) {

      my $err_msg = "ItemGroupId ($ItemGroupId) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'ItemGroupId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  ### Need to copy

  my $get_geno_sql;

  my $seen_geno_id    = {};
  my $geno2itemgroup  = {};

  if (defined $GenotypeId) {

    if (defined $ItemGroupId) {

      $get_geno_sql    = 'SELECT genotypespecimen.GenotypeId ';
      $get_geno_sql   .= 'FROM itemgroupentry LEFT JOIN item ON itemgroupentry.ItemId = item.ItemId ';
      $get_geno_sql   .= 'LEFT JOIN genotypespecimen ON item.SpecimenId = genotypespecimen.SpecimenId ';
      $get_geno_sql   .= 'WHERE itemgroupentry.ItemGroupId=? AND genotypespecimen.GenotypeId=?';

      my ($verify_geno_err, $verified_geno_id) = read_cell($dbh_k_read, $get_geno_sql, [$ItemGroupId, $GenotypeId]);

      if (length($verified_geno_id) == 0) {

        my $err_msg = "Genotype ($GenotypeId) not found.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'GenotypeId' => $err_msg}]};

        return $data_for_postrun_href;
      }

      $get_geno_sql    = 'SELECT genotypespecimen.GenotypeId ';
      $get_geno_sql   .= 'FROM itemgroupentry LEFT JOIN item ON itemgroupentry.ItemId = item.ItemId ';
      $get_geno_sql   .= 'LEFT JOIN genotypespecimen ON item.SpecimenId = genotypespecimen.SpecimenId ';
      $get_geno_sql   .= 'WHERE itemgroupentry.ItemGroupId=?';

      my ($get_geno_err, $get_geno_msg, $geno_data) = read_data($dbh_k_read, $get_geno_sql, [$ItemGroupId]);

      if ($get_geno_err) {

        $self->logger->debug($get_geno_msg);

        my $err_msg = "Unexpected Error.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }

      for my $geno_rec (@{$geno_data}) {

        my $geno_id = $geno_rec->{'GenotypeId'};
        $seen_geno_id->{$geno_id} = 1;

        $geno2itemgroup->{$geno_id} = $ItemGroupId;
      }
    }
    else {

      if (!record_existence($dbh_k_read, 'genotype', 'GenotypeId', $GenotypeId)) {

        my $err_msg = "GenotypeId ($GenotypeId): not found.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'GenotypeId' => $err_msg}]};

        return $data_for_postrun_href;
      }

      $seen_geno_id->{$GenotypeId} = 1;
    }
  }
  else {

    if (defined $ItemGroupId) {

      $get_geno_sql    = 'SELECT genotypespecimen.GenotypeId ';
      $get_geno_sql   .= 'FROM itemgroupentry LEFT JOIN item ON itemgroupentry.ItemId = item.ItemId ';
      $get_geno_sql   .= 'LEFT JOIN genotypespecimen ON item.SpecimenId = genotypespecimen.SpecimenId ';
      $get_geno_sql   .= 'WHERE itemgroupentry.ItemGroupId=?';

      my ($get_geno_err, $get_geno_msg, $geno_data) = read_data($dbh_k_read, $get_geno_sql, [$ItemGroupId]);

      if ($get_geno_err) {

        $self->logger->debug($get_geno_msg);

        my $err_msg = "Unexpected Error.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }

      for my $geno_rec (@{$geno_data}) {

        my $geno_id = $geno_rec->{'GenotypeId'};
        $seen_geno_id->{$geno_id} = 1;

        $geno2itemgroup->{$geno_id} = $ItemGroupId;
      }
    }
  }

  my @geno_id_list = keys(%{$seen_geno_id});

  $self->logger->debug("Genotype list: " . join(',', @geno_id_list));

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_ok, $trouble_geno_id_aref) = check_permission($dbh_k_read, 'genotype', 'GenotypeId',
                                                        \@geno_id_list, $group_id, $gadmin_status,
                                                        $LINK_PERM);
  if (!$is_ok) {

    # Because a specimen can have more than one genotype, trouble item group id variable needs to be a hash
    # instead of an array so that there is no duplicate in the itemgroup id that DAL reports back to the user.
    my %trouble_itemgroup_id_list;

    for my $trouble_geno_id (@{$trouble_geno_id_aref}) {

      if (defined $geno2itemgroup->{$trouble_geno_id}) {

        my $trouble_ig_id = $geno2itemgroup->{$trouble_geno_id};
        $trouble_itemgroup_id_list{$trouble_ig_id} = 1;
      }
    }

    my $trouble_itemgroup_id_str = join(',', keys(%trouble_itemgroup_id_list));
    my $trouble_geno_id_str      = join(',', @{$trouble_geno_id_aref});

    my $err_msg = "Permission denied: ItemGroupId ( $trouble_itemgroup_id_str ) GenotypeId ( $trouble_geno_id_str )";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  # Finish copy

  if (defined $PlateId) {

    if (!record_existence($dbh_m_read, 'plate', 'PlateId', $PlateId)) {

      my $err_msg = "Plate ($PlateId) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'PlateId' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if (length($WellRow) == 0) {

      my $err_msg = "WellRow is missing.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'WellRow' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if (length($WellCol) == 0) {

      my $err_msg = "WellCol is missing.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'WellCol' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $well_pos_sql = 'SELECT CONCAT("WellRow","WellCol") AS "Well" FROM "extract" WHERE "PlateId"=?';
    my ($r_well_pos_err, $well_pos) = read_cell($dbh_m_read, $well_pos_sql, [$PlateId]);

    my $user_well_pos = $WellRow . $WellCol;

    if (uc($user_well_pos) eq uc($well_pos)) {

      my $err_msg = "Plate ($PlateId) already has $well_pos assigned.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (defined $Tissue) {

    if (!type_existence($dbh_k_read, 'tissue', $Tissue)) {

      my $err_msg = "Tissue ($Tissue) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Tissue' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='extractfactor'";

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

  my ($vcol_missing_err, $vcol_missing_href) = check_missing_href( $vcol_param_data );

  if ($vcol_missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$vcol_missing_href]};

    return $data_for_postrun_href;
  }

  my ($vcol_maxlen_err, $vcol_maxlen_href) = check_maxlen_href($vcol_param_data_maxlen, $vcol_len_info);

  if ($vcol_maxlen_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$vcol_maxlen_href]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();
  $dbh_m_read->disconnect();

  my $dbh_m_write = connect_mdb_write();

  my ($next_val_err, $next_val_msg, $extract_id) = get_next_value_for($dbh_m_write, 'extract', 'ExtractId');

  if ($next_val_err) {

    $self->logger->debug($next_val_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  #insert into main table
  $sql    = 'INSERT INTO "extract"(';
  $sql   .= '"ExtractId", ';
  $sql   .= '"ParentExtractId", ';
  $sql   .= '"PlateId", ';
  $sql   .= '"ItemGroupId", ';
  $sql   .= '"GenotypeId", ';
  $sql   .= '"Tissue", ';
  $sql   .= '"WellRow", ';
  $sql   .= '"WellCol", ';
  $sql   .= '"Quality", ';
  $sql   .= '"Status") ';
  $sql   .= 'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';

  my $sth = $dbh_m_write->prepare($sql);
  $sth->execute( $extract_id, $ParentExtractId, $PlateId, $ItemGroupId, $GenotypeId,
                 $Tissue, $WellRow, $WellCol, $Quality, $Status );

  my $ExtractId = -1;
  if (!$dbh_m_write->err()) {

    $ExtractId = $extract_id;
    $self->logger->debug("ExtractId: $ExtractId");
  }
  else {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  #insert into factor table
  for my $vcol_id (keys(%{$vcol_data})) {

    my $factor_value = $query->param('VCol_' . $vcol_id);

    if (length($factor_value) > 0) {

      $sql  = 'INSERT INTO "extractfactor"( ';
      $sql .= '"ExtractId", ';
      $sql .= '"FactorId", ';
      $sql .= '"FactorValue) ';
      $sql .= 'VALUES(?, ?, ?)';
      my $factor_sth = $dbh_m_write->prepare($sql);
      $factor_sth->execute($ExtractId, $vcol_id, $factor_value);

      if ($dbh_m_write->err()) {

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

        return $data_for_postrun_href;
      }

      $factor_sth->finish();
    }
  }

  $dbh_m_write->disconnect();

  my $info_msg_aref = [{'Message' => "Extract ($ExtractId) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$ExtractId", 'ParaName' => 'ExtractId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub del_extract_runmode {

=pod del_extract_gadmin_HELP_START
{
"OperationName": "Delete extract",
"Description": "Delete DNA extract specified by id. Extract can be deleted only if not attached to any lower level related record.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Extract (22) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Extract (21) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdUsed": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Extract (8) is used by an anaysisgroup.' /></DATA>"}],
"ErrorMessageJSON": [{"IdUsed": "{'Error' : [{'Message' : 'Extract (8) is used by an anaysisgroup.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing ExtractId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $ExtractId = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_m_read = connect_mdb_read();

  my $extract_exist = record_existence($dbh_m_read, 'extract', 'ExtractId', $ExtractId);

  if (!$extract_exist) {

    my $err_msg = "Extract ($ExtractId) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $extract_in_analysisgroup = record_existence($dbh_m_read, 'analgroupextract', 'ExtractId', $ExtractId);

  if ($extract_in_analysisgroup) {

    my $err_msg = "Extract ($ExtractId) is used by an anaysisgroup.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_m_read->disconnect();

  my $dbh_m_write = connect_mdb_write();

  my $sql = 'DELETE FROM "extractfactor" WHERE "ExtractId"=?';
  my $sth = $dbh_m_write->prepare($sql);

  $sth->execute($ExtractId);

  if ($dbh_m_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $sql = 'DELETE FROM "extract" WHERE "ExtractId"=?';
  $sth = $dbh_m_write->prepare($sql);

  $sth->execute($ExtractId);

  if ($dbh_m_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_m_write->disconnect();

  my $info_msg_aref = [{'Message' => "Extract ($ExtractId) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;

}

sub update_extract_runmode {

=pod update_extract_gadmin_HELP_START
{
"OperationName": "Update extract",
"Description": "Update DNA extract specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "marker",
"KDDArTTable": "extract",
"KDDArTFactorTable": "extractfactor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Extract (23) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Extract (23) has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error GenotypeId='GenotypeId (460) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'GenotypeId' : 'GenotypeId (460) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing ExtractId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self           = shift;
  my $ExtractId      = $self->param('id');
  my $query          = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_mdb_read();

  my $skip_field = {'ParentExtractId' => 1};

  my $field_name_translation = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'extract', $skip_field,
                                                                                $field_name_translation,
                                                                               );

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $dbh_k_read = connect_kdb_read();
  my $dbh_m_read = connect_mdb_read();

  if (!record_existence($dbh_m_read, 'extract', 'ExtractId', $ExtractId)) {

    my $err_msg = "Extract ($ExtractId) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $read_extract_sql    =  'SELECT "ItemGroupId", "ParentExtractId", "PlateId", "GenotypeId", "Tissue", ';
     $read_extract_sql   .=  '"WellRow", "WellCol", "Quality", "Status" ';
     $read_extract_sql   .=  'FROM "extract" WHERE "ExtractId"=? ';

  my ($r_df_val_err, $r_df_val_msg, $extract_df_val_data) = read_data($dbh_m_read, $read_extract_sql, [$ExtractId]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve extract default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $ItemGroupId           =  undef;
  my $ParentExtractId       =  undef;
  my $PlateId               =  undef;
  my $GenotypeId            =  undef;
  my $Tissue                =  undef;
  my $WellRow               =  undef;
  my $WellCol               =  undef;
  my $Quality               =  undef;
  my $Status                =  undef;

  my $nb_df_val_rec    =  scalar(@{$extract_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve extract default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $ItemGroupId           =  $extract_df_val_data->[0]->{'ItemGroupId'};
  $ParentExtractId       =  $extract_df_val_data->[0]->{'ParentExtractId'};
  $PlateId               =  $extract_df_val_data->[0]->{'PlateId'};
  $GenotypeId            =  $extract_df_val_data->[0]->{'GenotypeId'};
  $Tissue                =  $extract_df_val_data->[0]->{'Tissue'};
  $WellRow               =  $extract_df_val_data->[0]->{'WellRow'};
  $WellCol               =  $extract_df_val_data->[0]->{'WellCol'};
  $Quality               =  $extract_df_val_data->[0]->{'Quality'};
  $Status                =  $extract_df_val_data->[0]->{'Status'};


  if (defined $query->param('ItemGroupId')) {

    if (length($query->param('ItemGroupId')) > 0) {

      $ItemGroupId = $query->param('ItemGroupId');
    }
  }

  if (length($ItemGroupId) == 0) {

    $ItemGroupId = undef;
  }


  if (defined($query->param('ParentExtractId'))) {

    if ($query->param('ParentExtractId') ne '0') {

      $ParentExtractId = $query->param('ParentExtractId');
    }
  }

  if (length($ParentExtractId) == 0) {

    $ParentExtractId = undef;
  }


  if (defined($query->param('PlateId'))) {

    if (length($query->param('PlateId')) > 0) {

      $PlateId = $query->param('PlateId');
    }
  }

  if (length($PlateId) == 0) {

    $PlateId = undef;
  }


  if (defined($query->param('GenotypeId'))) {

    if (length($query->param('GenotypeId')) > 0) {

      $GenotypeId = $query->param('GenotypeId');
    }
  }

  if (length($GenotypeId) == 0) {

    $GenotypeId = undef;
  }


  if (defined($query->param('Tissue'))) {

    if (length($query->param('Tissue')) > 0) {

      $Tissue = $query->param('Tissue');
    }
  }

  if (length($Tissue) == 0) {

    $Tissue = undef;
  }


  if (defined($query->param('WellRow'))) {

    $WellRow = $query->param('WellRow');
  }


  if (defined($query->param('WellCol'))) {

    $WellCol = $query->param('WellCol');
  }


  if (defined($query->param('Quality'))) {

    $Quality = $query->param('Quality');
  }


  if (defined($query->param('Status'))) {

    $Status = $query->param('Status');
  }

  if (defined $ParentExtractId) {

    if (!record_existence($dbh_m_read, 'extract', 'ExtractId', $ParentExtractId)) {

      my $err_msg = "ParentExtractId ($ParentExtractId) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'ParentExtractId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if ( (!(defined $ItemGroupId)) && (!(defined $GenotypeId)) ) {

    my $err_msg = "Both ItemGroupId and GenotypeId are missing.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (defined $ItemGroupId) {

    if (!record_existence($dbh_k_read, 'itemgroup', 'ItemGroupId', $ItemGroupId)) {

      my $err_msg = "ItemGroupId ($ItemGroupId) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'ItemGroupId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  #####

  my $get_geno_sql;

  my $seen_geno_id    = {};
  my $geno2itemgroup  = {};

  if (defined $GenotypeId) {

    if (defined $ItemGroupId) {

      $get_geno_sql    = 'SELECT genotypespecimen.GenotypeId ';
      $get_geno_sql   .= 'FROM itemgroupentry LEFT JOIN item ON itemgroupentry.ItemId = item.ItemId ';
      $get_geno_sql   .= 'LEFT JOIN genotypespecimen ON item.SpecimenId = genotypespecimen.SpecimenId ';
      $get_geno_sql   .= 'WHERE itemgroupentry.ItemGroupId=? AND genotypespecimen.GenotypeId=?';

      my ($verify_geno_err, $verified_geno_id) = read_cell($dbh_k_read, $get_geno_sql, [$ItemGroupId, $GenotypeId]);

      if (length($verified_geno_id) == 0) {

        my $err_msg = "Genotype ($GenotypeId) not found.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'GenotypeId' => $err_msg}]};

        return $data_for_postrun_href;
      }

      $get_geno_sql    = 'SELECT genotypespecimen.GenotypeId ';
      $get_geno_sql   .= 'FROM itemgroupentry LEFT JOIN item ON itemgroupentry.ItemId = item.ItemId ';
      $get_geno_sql   .= 'LEFT JOIN genotypespecimen ON item.SpecimenId = genotypespecimen.SpecimenId ';
      $get_geno_sql   .= 'WHERE itemgroupentry.ItemGroupId=?';

      my ($get_geno_err, $get_geno_msg, $geno_data) = read_data($dbh_k_read, $get_geno_sql, [$ItemGroupId]);

      if ($get_geno_err) {

        $self->logger->debug($get_geno_msg);

        my $err_msg = "Unexpected Error.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }

      for my $geno_rec (@{$geno_data}) {

        my $geno_id = $geno_rec->{'GenotypeId'};
        $seen_geno_id->{$geno_id} = 1;

        $geno2itemgroup->{$geno_id} = $ItemGroupId;
      }
    }
    else {

      if (!record_existence($dbh_k_read, 'genotype', 'GenotypeId', $GenotypeId)) {

        my $err_msg = "GenotypeId ($GenotypeId): not found.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'GenotypeId' => $err_msg}]};

        return $data_for_postrun_href;
      }

      $seen_geno_id->{$GenotypeId} = 1;
    }
  }
  else {

    if (defined $ItemGroupId) {

      $get_geno_sql    = 'SELECT genotypespecimen.GenotypeId ';
      $get_geno_sql   .= 'FROM itemgroupentry LEFT JOIN item ON itemgroupentry.ItemId = item.ItemId ';
      $get_geno_sql   .= 'LEFT JOIN genotypespecimen ON item.SpecimenId = genotypespecimen.SpecimenId ';
      $get_geno_sql   .= 'WHERE itemgroupentry.ItemGroupId=?';

      my ($get_geno_err, $get_geno_msg, $geno_data) = read_data($dbh_k_read, $get_geno_sql, [$ItemGroupId]);

      if ($get_geno_err) {

        $self->logger->debug($get_geno_msg);

        my $err_msg = "Unexpected Error.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }

      for my $geno_rec (@{$geno_data}) {

        my $geno_id = $geno_rec->{'GenotypeId'};
        $seen_geno_id->{$geno_id} = 1;

        $geno2itemgroup->{$geno_id} = $ItemGroupId;
      }
    }
  }

  my @geno_id_list = keys(%{$seen_geno_id});

  $self->logger->debug("Genotype list: " . join(',', @geno_id_list));

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_ok, $trouble_geno_id_aref) = check_permission($dbh_k_read, 'genotype', 'GenotypeId',
                                                        \@geno_id_list, $group_id, $gadmin_status,
                                                        $LINK_PERM);
  if (!$is_ok) {

    # Because a specimen can have more than one genotype, trouble item group id variable needs to be a hash
    # instead of an array so that there is no duplicate in the itemgroup id that DAL reports back to the user.
    my %trouble_itemgroup_id_list;

    for my $trouble_geno_id (@{$trouble_geno_id_aref}) {

      if (defined $geno2itemgroup->{$trouble_geno_id}) {

        my $trouble_ig_id = $geno2itemgroup->{$trouble_geno_id};
        $trouble_itemgroup_id_list{$trouble_ig_id} = 1;
      }
    }

    my $trouble_itemgroup_id_str = join(',', keys(%trouble_itemgroup_id_list));
    my $trouble_geno_id_str      = join(',', @{$trouble_geno_id_aref});

    my $err_msg = "Permission denied: ItemGroupId ( $trouble_itemgroup_id_str ) GenotypeId ( $trouble_geno_id_str )";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  ####

  if (defined $PlateId) {

    if (!record_existence($dbh_m_read, 'plate', 'PlateId', $PlateId)) {

      my $err_msg = "Plate ($PlateId) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'PlateId' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if (length($WellRow) == 0) {

      my $err_msg = "WellRow is missing.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'WellRow' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if (length($WellCol) == 0) {

      my $err_msg = "WellCol is missing.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'WellCol' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $well_pos_sql = 'SELECT CONCAT("WellRow","WellCol") AS "Well" FROM "extract" WHERE "PlateId"=? AND "ExtractId" <>?';
    my ($r_well_pos_err, $well_pos) = read_cell($dbh_m_read, $well_pos_sql, [$PlateId, $ExtractId]);

    my $user_well_pos = $WellRow . $WellCol;

    if (uc($user_well_pos) eq uc($well_pos)) {

      my $err_msg = "Plate ($PlateId) already has $well_pos assigned.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }
  else {

    if (length($WellRow) > 0) {

      my $err_msg = "WellRow cannot be accepted while Plate is not provided.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'WellRow' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if (length($WellCol) > 0) {

      my $err_msg = "WellCol cannot be accepted while Plate is not provided.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'WellCol' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (defined $Tissue) {

    if (!type_existence($dbh_k_read, 'tissue', $Tissue)) {

      my $err_msg = "Tissue ($Tissue) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Tissue' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='extractfactor'";

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

  my ($vcol_missing_err, $vcol_missing_href) = check_missing_href( $vcol_param_data );

  if ($vcol_missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$vcol_missing_href]};

    return $data_for_postrun_href;
  }

  my ($vcol_maxlen_err, $vcol_maxlen_href) = check_maxlen_href($vcol_param_data_maxlen, $vcol_len_info);

  if ($vcol_maxlen_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$vcol_maxlen_href]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();
  $dbh_m_read->disconnect();

  my $dbh_m_write = connect_mdb_write();

  #update main table
  $sql    = 'UPDATE "extract" SET ';
  $sql   .= '"ParentExtractId"=?, ';
  $sql   .= '"PlateId"=?, ';
  $sql   .= '"ItemGroupId"=?, ';
  $sql   .= '"GenotypeId"=?, ';
  $sql   .= '"Tissue"=?, ';
  $sql   .= '"WellRow"=?, ';
  $sql   .= '"WellCol"=?, ';
  $sql   .= '"Quality"=?, ';
  $sql   .= '"Status"=?';
  $sql   .= 'WHERE "ExtractId"=?';

  my $sth = $dbh_m_write->prepare($sql);
  $sth->execute( $ParentExtractId, $PlateId, $ItemGroupId, $GenotypeId, $Tissue, $WellRow, $WellCol,
                 $Quality, $Status, $ExtractId );

  if ($dbh_m_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  for my $vcol_id (keys(%{$vcol_data})) {

    my $factor_value = $query->param('VCol_' . "$vcol_id");

    $sql  = 'SELECT Count(*) ';
    $sql .= 'FROM "extractfactor" ';
    $sql .= 'WHERE "ExtractId"=? AND "FactorId"=?';

    my ($read_err, $count) = read_cell($dbh_m_write, $sql, [$ExtractId, $vcol_id]);

    if (length($factor_value) > 0) {

      if ($count > 0) {

        $sql  = 'UPDATE "extractfactor" SET ';
        $sql .= '"FactorValue"=? ';
        $sql .= 'WHERE "ExtractId"=? AND "FactorId"=?';

        my $factor_sth = $dbh_m_write->prepare($sql);
        $factor_sth->execute($factor_value, $ExtractId, $vcol_id);

        if ($dbh_m_write->err()) {

          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

          return $data_for_postrun_href;
        }

        $factor_sth->finish();
      }
      else {

        $sql  = 'INSERT INTO "extractfactor"(';
        $sql .= '"ExtractId", ';
        $sql .= '"FactorId", ';
        $sql .= '"FactorValue") ';
        $sql .= 'VALUES(?, ?, ?)';

        my $factor_sth = $dbh_m_write->prepare($sql);
        $factor_sth->execute($ExtractId, $vcol_id, $factor_value);

        if ($dbh_m_write->err()) {

          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

          return $data_for_postrun_href;
        }

        $factor_sth->finish();
      }
    }
    else {

      if ($count > 0) {

        $sql  = 'DELETE FROM "extractfactor" ';
        $sql .= 'WHERE "ExtractId"=? AND "FactorId"=?';

        my $factor_sth = $dbh_m_write->prepare($sql);
        $factor_sth->execute($ExtractId, $vcol_id);

        if ($dbh_m_write->err()) {

          $self->logger->debug("Delete extractfactor failed");
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

          return $data_for_postrun_href;
        }
        $factor_sth->finish();
      }
    }
  }

  $dbh_m_write->disconnect();

  my $info_msg_aref = [{'Message' => "Extract ($ExtractId) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub get_extract_runmode {

=pod get_extract_HELP_START
{
"OperationName": "Get extract",
"Description": "Get detailed information about DNA extract specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Extract Status='' WellCol='1' WellRow='A' GenotypeId='0' Tissue='0' PlateId='7' ItemGroupName='ITM_GRP8407256' Quality='' ExtractId='23' delete='delete/extract/23' ParentExtractId='0' ItemGroupId='4' update='update/extract/23' /><RecordMeta TagName='Extract' /></DATA>",
"SuccessMessageJSON": "{'VCol' : [],'Extract' : [{'WellRow' : 'A','WellCol' : '1','Status' : '','GenotypeId' : '0','Tissue' : '0','PlateId' : '7','ItemGroupName' : 'ITM_GRP8407256','Quality' : '','delete' : 'delete/extract/23','ExtractId' : '23','ParentExtractId' : '0','update' : 'update/extract/23','ItemGroupId' : '4'}],'RecordMeta' : [{'TagName' : 'Extract'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Extract (24) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Extract (24) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing ExtractId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self         = shift;
  my $ExtractId    = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_m = connect_mdb_read();
  my $dbh_k = connect_kdb_read();

  my $extract_exist = record_existence($dbh_m, 'extract', 'ExtractId', $ExtractId);

  if (!$extract_exist) {

    my $err_msg = "Extract ($ExtractId) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $field_list = ['*'];
  my $other_join = '';

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_mfactor_sql($dbh_m,
                                                                         $dbh_k,
                                                                         $field_list,
                                                                         'extract',
                                                                         'ExtractId',
                                                                         $other_join);

  $dbh_m->disconnect();
  $dbh_k->disconnect();

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $where_clause = qq| WHERE "extract"."ExtractId"=? |;

  $sql .= " $where_clause ";

  # Disable virtual column

  #$sql =~ s/GROUP BY/ $where_clause GROUP BY /;

  my ($err, $msg, $extract_data) = $self->list_extract(1, $sql, [$ExtractId]);

  if ($err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Extract' => $extract_data,
                                           'VCol'         => $vcol_list,
                                           'RecordMeta'   => [{'TagName' => 'Extract'}],
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_analysisgroup {

  my $self              = $_[0];
  my $extra_attr_yes    = $_[1];
  my $sql               = $_[2];
  my $where_para_aref   = $_[3];

  #initialise variables
  my $err = 0;
  my $msg = '';
  my $data_aref = [];

  #get marker db handle
  my $dbh_m = connect_mdb_read();
  my $dbh_k = connect_kdb_read();

  #retrieve user's credentials
  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  $self->logger->debug("AnalysisGroup permission SQL: $sql");

  #query marker db handle using sql supplied
  ($err, $msg, $data_aref) = read_data($dbh_m, $sql, $where_para_aref);

  if ($err) {

    return ($err, $msg, []);
  }

  my $anal_grp_id_aref    = [];
  my $contact_id_href     = {};
  my $sys_grp_id_href     = {};

  my $group_lookup   = {};
  my $contact_lookup = {};

  my $chk_id_err        = 0;
  my $chk_id_msg        = '';
  my $used_id_href      = {};
  my $not_used_id_href  = {};

  if ($extra_attr_yes) {

    for my $analysisgroup_row (@{$data_aref}) {

      push(@{$anal_grp_id_aref}, $analysisgroup_row->{'AnalysisGroupId'});
      $sys_grp_id_href->{$analysisgroup_row->{'OwnGroupId'}} = 1;
      $sys_grp_id_href->{$analysisgroup_row->{'AccessGroupId'}} = 1;

      if (defined $analysisgroup_row->{'ContactId'}) {

        $contact_id_href->{$analysisgroup_row->{'ContactId'}} = 1;
      }
    }

    if (scalar(keys(%{$sys_grp_id_href})) > 0) {

      my $group_sql      = 'SELECT SystemGroupId, SystemGroupName FROM systemgroup ';
      $group_sql        .= 'WHERE SystemGroupId IN (' . join(',', keys(%{$sys_grp_id_href})) . ')';

      $self->logger->debug("GROUP_SQL: $group_sql");

      $group_lookup = $dbh_k->selectall_hashref($group_sql, 'SystemGroupId');

      $self->logger->debug("GROUP LOOKUP KEY: " . join(',', keys(%{$group_lookup})));
    }

    if (scalar(keys(%{$contact_id_href})) > 0) {

      my $contact_sql    = 'SELECT ContactId, ContactFirstName, ContactLastName, ';
      $contact_sql      .= "CONCAT(contact.ContactFirstName, ' ', contact.ContactLastName) AS ContactName ";
      $contact_sql      .= 'FROM contact ';
      $contact_sql      .= 'WHERE ContactId IN (' . join(',', keys(%{$contact_id_href})) . ')';

      $self->logger->debug("CONTACT_SQL: $contact_sql");

      $contact_lookup = $dbh_k->selectall_hashref($contact_sql, 'ContactId');
    }

    if (scalar(@{$anal_grp_id_aref}) > 0) {

      my $chk_table_aref = [{'TableName' => 'dataset', 'FieldName' => 'AnalysisGroupId'}];

      ($chk_id_err, $chk_id_msg,
       $used_id_href, $not_used_id_href) = id_existence_bulk($dbh_m, $chk_table_aref, $anal_grp_id_aref);

      if ($chk_id_err) {

        $self->logger->debug("Check id existence error: $chk_id_msg");
        $err = 1;
        $msg = $chk_id_msg;

        return ($err, $msg, []);
      }
    }
  }

  my $perm_lookup  = {'0' => 'None',
                      '1' => 'Link',
                      '2' => 'Write',
                      '3' => 'Write/Link',
                      '4' => 'Read',
                      '5' => 'Read/Link',
                      '6' => 'Read/Write',
                      '7' => 'Read/Write/Link',
  };

  my @extra_attr_analysisgroup_data;

  for my $analysisgroup_row (@{$data_aref}) {

    my $analysisgroup_id = $analysisgroup_row->{'AnalysisGroupId'};
    my $contact_id       = $analysisgroup_row->{'ContactId'};

    my $marker_state_type   = $analysisgroup_row->{'MarkerStateType'};
    my $marker_quality_type = $analysisgroup_row->{'MarkerQualityType'};

    my $own_grp_id   = $analysisgroup_row->{'OwnGroupId'};
    my $acc_grp_id   = $analysisgroup_row->{'AccessGroupId'};
    my $own_perm     = $analysisgroup_row->{'OwnGroupPerm'};
    my $acc_perm     = $analysisgroup_row->{'AccessGroupPerm'};
    my $oth_perm     = $analysisgroup_row->{'OtherPerm'};
    my $ulti_perm    = $analysisgroup_row->{'UltimatePerm'};

    #do we want extra info?
    if ($extra_attr_yes) {

      $analysisgroup_row->{'OwnGroupName'}          = $group_lookup->{$own_grp_id}->{'SystemGroupName'};
      $analysisgroup_row->{'AccessGroupName'}       = $group_lookup->{$acc_grp_id}->{'SystemGroupName'};
      $analysisgroup_row->{'OwnGroupPermission'}    = $perm_lookup->{$own_perm};
      $analysisgroup_row->{'AccessGroupPermission'} = $perm_lookup->{$acc_perm};
      $analysisgroup_row->{'OtherPermission'}       = $perm_lookup->{$oth_perm};
      $analysisgroup_row->{'UltimatePermission'}    = $perm_lookup->{$ulti_perm};

      if (defined $contact_lookup->{$contact_id}) {

        $analysisgroup_row->{'ContactFirstName'} = $contact_lookup->{$contact_id}->{'ContactFirstName'};
        $analysisgroup_row->{'ContactLastName'}  = $contact_lookup->{$contact_id}->{'ContactLastName'};
        $analysisgroup_row->{'ContactName'}      = $contact_lookup->{$contact_id}->{'ContactName'};
      }

      if (($ulti_perm & $WRITE_PERM) == $WRITE_PERM) {

        $analysisgroup_row->{'update'} = "update/analysisgroup/$analysisgroup_id";
      }

      if ($used_id_href->{$analysisgroup_id}) {

        $analysisgroup_row->{'listDataSet'} = "analysisgroup/$analysisgroup_id/list/dataset";
      }

      if ($own_grp_id == $group_id) {

        $analysisgroup_row->{'chgPerm'} = "analysisgroup/$analysisgroup_id/change/permission";

        if ($gadmin_status eq '1') {

          $analysisgroup_row->{'chgOwner'} = "analysisgroup/$analysisgroup_id/change/owner";

          if ( $not_used_id_href->{$analysisgroup_id} ) {

            $analysisgroup_row->{'delete'}  = "delete/analysisgroup/$analysisgroup_id";
          }
        }
      }
    }
    push(@extra_attr_analysisgroup_data, $analysisgroup_row);
  }

  $dbh_m->disconnect();
  $dbh_k->disconnect();

  return ($err, $msg, \@extra_attr_analysisgroup_data);
}

sub list_analysisgroup_advanced_runmode {

=pod list_analysisgroup_advanced_HELP_START
{
"OperationName": "List analysis groups",
"Description": "List analysis groups defined in the system. This listing requires pagination information.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination Page='1' NumOfRecords='1' NumOfPages='1' NumPerPage='1' /><RecordMeta TagName='AnalysisGroup' /><AnalysisGroup AnalysisGroupId='1' AccessGroupPerm='5' AccessGroupId='0' MarkerQualityType='58' MarkerStateTypeName='MarkerState Type - 3383618' MarkerQualityTypeName='MarkerQuality Type - 0659707' AccessGroupPermission='Read/Link' OtherPermission='None' chgPerm='analysisgroup/1/change/permission' OtherPerm='0' OwnGroupPerm='7' ContactId='0' OwnGroupPermission='Read/Write/Link' OwnGroupName='admin' MarkerNameColumnPosition='4' MarkerSequenceColumnPosition='1' AccessGroupName='admin' AnalysisGroupName='6089851' AnalysisGroupDescription='Testing' GenotypeMarkerStateX='-1' MarkerStateType='57' chgOwner='analysisgroup/1/change/owner' UltimatePermission='Read/Write/Link' OwnGroupId='0' update='update/analysisgroup/1' UltimatePerm='7'><Extract PlateName='' PlateId='0' WellCol='1' WellRow='A' ExtractId='8' GenotypeId='0' ItemGroupId='1' /><Extract PlateName='' PlateId='0' WellCol='2' WellRow='A' ExtractId='9' GenotypeId='0' ItemGroupId='1' /><Extract PlateName='' PlateId='0' WellCol='3' WellRow='A' ExtractId='10' GenotypeId='0' ItemGroupId='1' /><Extract PlateName='' PlateId='0' WellCol='6' WellRow='A' ExtractId='11' GenotypeId='0' ItemGroupId='1' /><Extract PlateName='' PlateId='0' WellCol='4' WellRow='A' ExtractId='12' GenotypeId='0' ItemGroupId='1' /><Extract PlateName='' PlateId='0' WellCol='5' WellRow='A' ExtractId='13' GenotypeId='0' ItemGroupId='1' /></AnalysisGroup></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfRecords' : '1','NumOfPages' : 1,'NumPerPage' : '1','Page' : '1'}],'VCol' : [],'RecordMeta' : [{'TagName' : 'AnalysisGroup'}],'AnalysisGroup' : [{'AnalysisGroupId' : '1','AccessGroupPerm' : '5','AccessGroupId' : '0','MarkerQualityType' : '58','OtherPermission' : 'None','AccessGroupPermission' : 'Read/Link','MarkerQualityTypeName' : 'MarkerQuality Type - 0659707','MarkerStateTypeName' : 'MarkerState Type - 3383618','chgPerm' : 'analysisgroup/1/change/permission','OwnGroupPerm' : '7','OtherPerm' : '0','ContactId' : '0','OwnGroupPermission' : 'Read/Write/Link','Extract' : [{'PlateName' : null,'PlateId' : '0','WellRow' : 'A','WellCol' : '1','ExtractId' : '8','GenotypeId' : '0','ItemGroupId' : '1'},{'PlateName' : null,'PlateId' : '0','WellRow' : 'A','WellCol' : '2','ExtractId' : '9','GenotypeId' : '0','ItemGroupId' : '1'},{'PlateName' : null,'PlateId' : '0','WellRow' : 'A','WellCol' : '3','ExtractId' : '10','GenotypeId' : '0','ItemGroupId' : '1'},{'PlateName' : null,'PlateId' : '0','WellRow' : 'A','WellCol' : '6','ExtractId' : '11','GenotypeId' : '0','ItemGroupId' : '1'},{'PlateName' : null,'PlateId' : '0','WellRow' : 'A','WellCol' : '4','ExtractId' : '12','GenotypeId' : '0','ItemGroupId' : '1'},{'PlateName' : null,'PlateId' : '0','WellRow' : 'A','WellCol' : '5','ExtractId' : '13','GenotypeId' : '0','ItemGroupId' : '1'}],'OwnGroupName' : 'admin','MarkerNameColumnPosition' : '4','AccessGroupName' : 'admin','MarkerSequenceColumnPosition' : '1','AnalysisGroupDescription' : 'Testing','AnalysisGroupName' : '6089851','chgOwner' : 'analysisgroup/1/change/owner','MarkerStateType' : '57','GenotypeMarkerStateX' : '-1','UltimatePermission' : 'Read/Write/Link','update' : 'update/analysisgroup/1','OwnGroupId' : '0','UltimatePerm' : '7'}]}",
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

  #get database handles
  my $dbh_k = connect_kdb_read();
  my $dbh_m = connect_mdb_read();

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str      = permission_phrase($group_id, 2, $gadmin_status, 'analysisgroup');

  my $field_list = ['*'];

  my $other_join = '';

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_mfactor_sql($dbh_m,
                                                                         $dbh_k,
                                                                         $field_list,
                                                                         'analysisgroup',
                                                                         'AnalysisGroupId',
                                                                         $other_join);


  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $where_perm = " WHERE ((($perm_str) & $READ_PERM) = $READ_PERM) ";

  $sql .= " $where_perm ";

  # Disable virtual column

  #$sql  =~ s/GROUP BY/ $where_perm GROUP BY /;

  $sql .= ' LIMIT 1';

  $self->logger->debug("SQL with VCol: $sql");

  my ($sam_r_ana_grp_err, $sam_r_ana_grp_msg, $sam_ana_grp_data) = $self->list_analysisgroup(0, $sql);

  if ($sam_r_ana_grp_err) {

    $self->logger->debug($sam_r_ana_grp_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my @field_list_all;

  if (scalar(@{$sam_ana_grp_data}) == 1) {

    @field_list_all = keys(%{$sam_ana_grp_data->[0]});
  }
  else {

    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh_m, 'analysisgroup');

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

  my $final_field_list = \@field_list_all;

  if (length($field_list_csv) > 0) {

    my ($sel_field_err, $sel_field_msg, $sel_field_list) = parse_selected_field($field_list_csv,
                                                                                $final_field_list,
                                                                                'AnalysisGroupId');

    if ($sel_field_err) {

      $self->logger->debug("Parse selected field failed: $sel_field_msg");
      my $err_msg = $sel_field_msg;
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;
  }

  $other_join = '';

  my $field_lookup = {};
  for my $fd_name (@{$final_field_list}) {

    $field_lookup->{$fd_name} = 1;
  }

  my $compulsory_perm_fields = ['OwnGroupId',
                                'AccessGroupId',
                                'OwnGroupPerm',
                                'AccessGroupPerm',
                                'OtherPerm',
      ];

  for my $com_fd_name (@{$compulsory_perm_fields}) {

    if (length($field_lookup->{$com_fd_name}) == 0) {

      push(@{$final_field_list}, $com_fd_name);
    }
  }

  push(@{$final_field_list}, qq|$perm_str AS "UltimatePerm"|);

  ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_mfactor_sql($dbh_m, $dbh_k,
                                                                      $final_field_list, 'analysisgroup',
                                                                     'AnalysisGroupId', $other_join);

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering('"AnalysisGroupId"',
                                                                              '"analysisgroup"',
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

  my $filtering_exp = " WHERE (($perm_str) & $READ_PERM) = $READ_PERM $filter_where_phrase ";

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
                                                                   '"analysisgroup"',
                                                                   '"AnalysisGroupId"',
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

  $dbh_k->disconnect();
  $dbh_m->disconnect();

  $sql .= " $filtering_exp ";

  # Disable virtual column

  #$sql  =~ s/GROUP BY/ $filtering_exp GROUP BY /;

  my ($sort_err, $sort_msg, $sort_sql) = parse_sorting($sorting, $final_field_list, '"analysisgroup"');

  if ($sort_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sort_msg}]};

    return $data_for_postrun_href;
  }

  if (length($sort_sql) > 0) {

    $sql .= " ORDER BY $sort_sql ";
  }
  else {

    $sql .= ' ORDER BY "analysisgroup"."AnalysisGroupId" DESC';
  }

  $sql .= " $paged_limit_clause ";

  $self->logger->debug("SQL with VCol: $sql");


  my ($r_ana_grp_err, $r_ana_grp_msg, $ana_grp_data) = $self->list_analysisgroup(1, $sql, $where_arg);

  if ($r_ana_grp_err) {

    $self->logger->debug($r_ana_grp_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'AnalysisGroup' => $ana_grp_data,
                                           'VCol'          => $vcol_list,
                                           'Pagination'    => $pagination_aref,
                                           'RecordMeta'    => [{'TagName' => 'AnalysisGroup'}],
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub get_analysisgroup_runmode {

=pod get_analysisgroup_HELP_START
{
"OperationName": "Get analysis group",
"Description": "Get detailed information about the analysis group specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='AnalysisGroup' /><AnalysisGroup AnalysisGroupId='1' AccessGroupPerm='5' AccessGroupId='0' MarkerQualityType='58' MarkerStateTypeName='MarkerState Type - 3383618' MarkerQualityTypeName='MarkerQuality Type - 0659707' AccessGroupPermission='Read/Link' OtherPermission='None' chgPerm='analysisgroup/1/change/permission' OwnGroupPerm='7' OtherPerm='0' ContactId='0' OwnGroupPermission='Read/Write/Link' OwnGroupName='admin' MarkerNameColumnPosition='4' MarkerSequenceColumnPosition='1' AccessGroupName='admin' AnalysisGroupDescription='Testing' AnalysisGroupName='6089851' MarkerStateType='57' GenotypeMarkerStateX='-1' chgOwner='analysisgroup/1/change/owner' UltimatePermission='Read/Write/Link' OwnGroupId='0' update='update/analysisgroup/1' UltimatePerm='7'><Extract PlateName='' PlateId='0' WellCol='1' WellRow='A' ExtractId='8' GenotypeId='0' ItemGroupId='1' /><Extract PlateName='' PlateId='0' WellCol='2' WellRow='A' ExtractId='9' GenotypeId='0' ItemGroupId='1' /><Extract PlateName='' PlateId='0' WellCol='3' WellRow='A' ExtractId='10' GenotypeId='0' ItemGroupId='1' /><Extract PlateName='' PlateId='0' WellCol='6' WellRow='A' ExtractId='11' GenotypeId='0' ItemGroupId='1' /><Extract PlateName='' PlateId='0' WellCol='4' WellRow='A' ExtractId='12' GenotypeId='0' ItemGroupId='1' /><Extract PlateName='' PlateId='0' WellCol='5' WellRow='A' ExtractId='13' GenotypeId='0' ItemGroupId='1' /></AnalysisGroup></DATA>",
"SuccessMessageJSON": "{'VCol' : [],'RecordMeta' : [{'TagName' : 'AnalysisGroup'}],'AnalysisGroup' : [{'AnalysisGroupId' : '1','AccessGroupPerm' : '5','AccessGroupId' : '0','MarkerQualityType' : '58','OtherPermission' : 'None','AccessGroupPermission' : 'Read/Link','MarkerQualityTypeName' : 'MarkerQuality Type - 0659707','MarkerStateTypeName' : 'MarkerState Type - 3383618','chgPerm' : 'analysisgroup/1/change/permission','OtherPerm' : '0','OwnGroupPerm' : '7','ContactId' : '0','OwnGroupPermission' : 'Read/Write/Link','Extract' : [{'PlateName' : null,'PlateId' : '0','WellRow' : 'A','WellCol' : '1','ExtractId' : '8','GenotypeId' : '0','ItemGroupId' : '1'},{'PlateName' : null,'PlateId' : '0','WellRow' : 'A','WellCol' : '2','ExtractId' : '9','GenotypeId' : '0','ItemGroupId' : '1'},{'PlateName' : null,'PlateId' : '0','WellRow' : 'A','WellCol' : '3','ExtractId' : '10','GenotypeId' : '0','ItemGroupId' : '1'},{'PlateName' : null,'PlateId' : '0','WellRow' : 'A','WellCol' : '6','ExtractId' : '11','GenotypeId' : '0','ItemGroupId' : '1'},{'PlateName' : null,'PlateId' : '0','WellRow' : 'A','WellCol' : '4','ExtractId' : '12','GenotypeId' : '0','ItemGroupId' : '1'},{'PlateName' : null,'PlateId' : '0','WellRow' : 'A','WellCol' : '5','ExtractId' : '13','GenotypeId' : '0','ItemGroupId' : '1'}],'OwnGroupName' : 'admin','MarkerNameColumnPosition' : '4','AccessGroupName' : 'admin','MarkerSequenceColumnPosition' : '1','AnalysisGroupName' : '6089851','AnalysisGroupDescription' : 'Testing','chgOwner' : 'analysisgroup/1/change/owner','GenotypeMarkerStateX' : '-1','MarkerStateType' : '57','UltimatePermission' : 'Read/Write/Link','update' : 'update/analysisgroup/1','OwnGroupId' : '0','UltimatePerm' : '7'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='AnalysisGroup (5): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'AnalysisGroup (5): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing AnalysisGroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self            = shift;
  my $analysis_grp_id = $self->param('id');

  my $data_for_postrun_href = {};

  #get database handles
  my $dbh_k = connect_kdb_read();
  my $dbh_m = connect_mdb_read();

  if (!record_existence($dbh_m, 'analysisgroup', 'AnalysisGroupId', $analysis_grp_id)) {

    my $err_msg = "AnalysisGroup ($analysis_grp_id): not found.";
    return $self->_set_error($err_msg);
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str      = permission_phrase($group_id, 2, $gadmin_status, 'analysisgroup');

  my $field_list = ['*', qq|$perm_str AS "UltimatePerm"|];

  my $other_join = '';

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_mfactor_sql($dbh_m,
                                                                         $dbh_k,
                                                                         $field_list,
                                                                         'analysisgroup',
                                                                         'AnalysisGroupId',
                                                                         $other_join);

  $dbh_m->disconnect();
  $dbh_k->disconnect();

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $where_clause = qq| WHERE ((($perm_str) & $READ_PERM) = $READ_PERM) AND "analysisgroup"."AnalysisGroupId"=? |;

  $sql .= " $where_clause ";

  # Disable virtual column

  #$sql   =~ s/GROUP BY/ $where_clause GROUP BY /;

  $self->logger->debug("SQL with VCol: $sql");

  my ($read_ana_grp_err, $read_ana_grp_msg, $ana_grp_data) = $self->list_analysisgroup(1, $sql,
                                                                                       [$analysis_grp_id] );

  if ($read_ana_grp_err) {

    $self->logger->debug($read_ana_grp_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'AnalysisGroup' => $ana_grp_data,
                                           'VCol'          => $vcol_list,
                                           'RecordMeta'    => [{'TagName' => 'AnalysisGroup'}],
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub add_analysisgroup_runmode {

=pod add_analysisgroup_HELP_START
{
"OperationName": "Add analysis group",
"Description": "Add a new analysis group definition. This groups DNA extracts which will undergo genotyping experiment together.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "marker",
"KDDArTTable": "analysisgroup",
"KDDArTFactorTable": "analysisgroupfactor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId ParaName='AnalysisGroupId' Value='2' /><Info Message='AnalysisGroup (2) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '3','ParaName' : 'AnalysisGroupId'}],'Info' : [{'Message' : 'AnalysisGroup (3) has been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error MarkerStateType='MarkerStateType (252) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'MarkerStateType' : 'MarkerStateType (252) not found.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "XML",
"UploadFileParameterName": "uploadfile",
"DTDFileNameForUploadXML": "analysisgroup.dtd",
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_mdb_read();

  my $skip_field = {'OwnGroupId' => 1};

  my $field_name_translation = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'analysisgroup', $skip_field,
                                                                                $field_name_translation,
                                                                               );

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $AnalysisGroupName         = $query->param('AnalysisGroupName');
  my $AccessGroupId             = $query->param('AccessGroupId');
  my $OwnGroupPerm              = $query->param('OwnGroupPerm');
  my $AccessGroupPerm           = $query->param('AccessGroupPerm');
  my $OtherPerm                 = $query->param('OtherPerm');

  my $AnalysisGroupDescription  = '';

  if (defined($query->param('AnalysisGroupDescription'))) {

    $AnalysisGroupDescription = $query->param('AnalysisGroupDescription');
  }

  my $ContactId                 = '0';

  if (defined($query->param('ContactId'))) {

    if (length($query->param('ContactId')) > 0) {

      $ContactId = $query->param('ContactId');
    }
  }

  $self->logger->debug('Adding Analysis Group');

  my $dbh_k_read = connect_kdb_read();
  my $dbh_m_read = connect_mdb_read();

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='analysisgroupfactor'";

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

  my ($vcol_missing_err, $vcol_missing_href) = check_missing_href( $vcol_param_data );

  if ($vcol_missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$vcol_missing_href]};

    return $data_for_postrun_href;
  }

  my ($vcol_maxlen_err, $vcol_maxlen_href) = check_maxlen_href($vcol_param_data_maxlen, $vcol_len_info);

  if ($vcol_maxlen_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$vcol_maxlen_href]};

    return $data_for_postrun_href;
  }

  my $chk_start_time = [gettimeofday()];

  $self->logger->debug("Checking AnalysisGroupName: $AnalysisGroupName");

  if (record_existence($dbh_m_read, 'analysisgroup', 'AnalysisGroupName', $AnalysisGroupName)) {

    my $err_msg = "AnalysisGroupName ($AnalysisGroupName) already exists.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'AnalysisGroupName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $chk_elapsed = tv_interval($chk_start_time);

  $self->logger->debug("Check analysisgroup name time: $chk_elapsed seconds");

  #check that supplied access group exists
  my $access_grp_existence = record_existence($dbh_k_read, 'systemgroup', 'SystemGroupId', $AccessGroupId);

  if (!$access_grp_existence) {

    my $err_msg = "AccessGroup ($AccessGroupId) does not exist.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'AccessGroupId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  #check that permission values fall within accepted constraints
  if ( $OwnGroupPerm > 7 || $OwnGroupPerm < 0 ||
       (($OwnGroupPerm & $READ_PERM) != $READ_PERM) ) {

    my $err_msg = "OwnGroupPerm ($OwnGroupPerm) is invalid.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'OwnGroupPerm' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( ($AccessGroupPerm > 7 || $AccessGroupPerm < 0) ) {

    my $err_msg = "AccessGroupPerm ($AccessGroupPerm) is invalid.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'AccessGroupPerm' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( ($OtherPerm > 7 || $OtherPerm < 0) ) {

    my $err_msg = "OtherPerm ($OtherPerm) is invalid.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'OtherPerm' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ($ContactId ne '0') {

    if (!record_existence($dbh_k_read, 'contact', 'ContactId', $ContactId)) {

      my $err_msg = "Contact ($ContactId) not found.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'ContactId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  $self->logger->debug("Loading XML file");
  my $chk_xml_start_time = [gettimeofday()];

  my $extract_xml_file = $self->authen->get_upload_file();

  my $analysisgroup_dtd_file = $self->get_analysisgroup_dtd_file();

  add_dtd($analysisgroup_dtd_file, $extract_xml_file);

  my $xml_checker_parser = new XML::Checker::Parser( Handlers => { } );

  eval {

    local $XML::Checker::FAIL = sub {

      my $code = shift;
      my $err_str = XML::Checker::error_string ($code, @_);
      $self->logger->debug("XML Parsing ERR: $code : $err_str");
      die $err_str;
    };
    $xml_checker_parser->parsefile($extract_xml_file);
  };

  if ($@) {

    my $err_msg = $@;
    $self->logger->debug("Parsing XML error: $err_msg");
    my $user_err_msg = "Analysis Group xml file does not comply with its definition.\n";
    $user_err_msg   .= "Details: $err_msg";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $user_err_msg}]};

    return $data_for_postrun_href;
  }

  my $chk_xml_elapsed = tv_interval($chk_xml_start_time);

  $self->logger->debug("Check xml time: $chk_xml_elapsed seconds");

  my $xml_start_time = [gettimeofday()];

  my $extract_xml  = read_file($extract_xml_file);
  my $extract_aref = xml2arrayref($extract_xml_file, 'extract');

  my $xml_elapsed = tv_interval($xml_start_time);

  $self->logger->debug("Final xml time: $xml_elapsed seconds");

  my $chk_id_start_time = [gettimeofday()];

  my @ExtractIds;
  my $seen_geno_id = {};
  my $geno2extract = {};

  my $uniq_extract_id_href = {};

  foreach my $extract_rec (@{$extract_aref}) {

    $uniq_extract_id_href->{$extract_rec->{'ExtractId'}} = 1;
  }

  my @extract_id_list = keys(%{$uniq_extract_id_href});

  if (scalar(@extract_id_list) == 0) {

    my $err_msg = "No extract";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($ext_exist_err, $ext_exist_msg,
      $unfound_ext_aref, $found_ext_aref) = record_existence_bulk($dbh_m_read, 'extract', 'ExtractId', \@extract_id_list);

  if ($ext_exist_err) {

    $self->logger->debug("Check recorod existence bulk failed: $ext_exist_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$unfound_ext_aref}) > 0) {

    my $unfound_ext_csv = join(',', @{$unfound_ext_aref});

    my $err_msg = "Extract ($unfound_ext_csv): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql = qq|SELECT "ExtractId", "ItemGroupId", "GenotypeId" FROM "extract" WHERE "ExtractId" IN (| . join(',', @extract_id_list) . ')';

  my ($db_ext_err, $db_ext_msg, $db_ext_data) = read_data($dbh_m_read, $sql, []);

  if ($db_ext_err) {

    $self->logger->debug("Read extract info failed: $db_ext_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $uniq_itm_grp_id_href = {};
  my $itm_grp2extract      = {};

  foreach my $db_ext_rec (@{$db_ext_data}) {

    my $extract_id = $db_ext_rec->{'ExtractId'};

    if (defined $db_ext_rec->{'ItemGroupId'}) {

      my $itm_grp_id = $db_ext_rec->{'ItemGroupId'};
      $uniq_itm_grp_id_href->{$itm_grp_id} = 1;

      if ( !(defined $itm_grp2extract->{$itm_grp_id}) ) {

        $itm_grp2extract->{$itm_grp_id} = [$extract_id];
      }
      else {

        my $extr_id_aref = $itm_grp2extract->{$itm_grp_id};
        push(@{$extr_id_aref}, $extract_id);
        $itm_grp2extract->{$itm_grp_id} = [$extract_id];
      }
    }

    if (defined $db_ext_rec->{'GenotypeId'}) {

      my $geno_id = $db_ext_rec->{'GenotypeId'};

      $seen_geno_id->{$geno_id} = 1;

      if ( !(defined $geno2extract->{$geno_id}) ) {

        $geno2extract->{$geno_id} = [$extract_id];
      }
      else {

        my $extr_id_aref = $geno2extract->{$geno_id};
        push(@{$extr_id_aref}, $extract_id);
        $geno2extract->{$geno_id} = $extr_id_aref;
      }
    }
  }

  my @itm_grp_id_list = keys(%{$uniq_itm_grp_id_href});

  if (scalar(@itm_grp_id_list) > 0) {

    $sql    = 'SELECT itemgroupentry.ItemGroupId, genotypespecimen.GenotypeId ';
    $sql   .= 'FROM itemgroupentry LEFT JOIN item ON itemgroupentry.ItemId = item.ItemId ';
    $sql   .= 'LEFT JOIN genotypespecimen ON item.SpecimenId = genotypespecimen.SpecimenId ';
    $sql   .= 'WHERE itemgroupentry.ItemGroupId IN (' . join(',', @itm_grp_id_list) . ')';

    my ($itm_grp_err, $itm_grp_msg, $itm_grp_data) = read_data($dbh_k_read, $sql, []);

    if ($itm_grp_err) {

      $self->logger->debug("Read item group failed: $itm_grp_msg");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

      return $data_for_postrun_href;
    }

    foreach my $itm_grp_rec (@{$itm_grp_data}) {

      my $itm_grp_id   = $itm_grp_rec->{'ItemGroupId'};
      my $ex_id_aref   = $itm_grp2extract->{$itm_grp_id};
      my $geno_id      = $itm_grp_rec->{'GenotypeId'};

      $seen_geno_id->{$geno_id} = 1;

      if ( !(defined $geno2extract->{$geno_id}) ) {

        $geno2extract->{$geno_id} = $ex_id_aref;
      }
      else {

        my $extr_id_aref = [@{$geno2extract->{$geno_id}}, @{$ex_id_aref}];
        $geno2extract->{$geno_id} = $extr_id_aref;
      }
    }
  }

  my @geno_id_list = keys(%{$seen_geno_id});

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  if (scalar(@geno_id_list) > 0) {

    my ($is_ok, $trouble_geno_id_aref) = check_permission($dbh_k_read, 'genotype', 'GenotypeId',
                                                          \@geno_id_list, $group_id, $gadmin_status,
                                                          $READ_LINK_PERM);

    if (!$is_ok) {

      my @trouble_ext_id_list;

      for my $trouble_geno_id (@{$trouble_geno_id_aref}) {

        my $trouble_ext_id_aref = $geno2extract->{$trouble_geno_id};
        push(@trouble_ext_id_list, @{$trouble_ext_id_aref});
      }

      my $trouble_ext_id_str = join(',', @trouble_ext_id_list);

      my $err_msg = "ExtractIds ( $trouble_ext_id_str ): permission denied";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  $dbh_k_read->disconnect();
  $dbh_m_read->disconnect();

  my $chk_id_elapsed = tv_interval($chk_id_start_time);

  $self->logger->debug("Check id time: $chk_id_elapsed seconds");

  my $dbh_m_write = connect_mdb_write();

  my ($next_val_err, $next_val_msg, $anal_id) = get_next_value_for($dbh_m_write, 'analysisgroup', 'AnalysisGroupId');

  if ($next_val_err) {

    $self->logger->debug($next_val_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("New analid: $anal_id");

  #insert into main table
  $sql    = 'INSERT INTO "analysisgroup"(';
  $sql   .= '"AnalysisGroupId", ';
  $sql   .= '"AnalysisGroupName", ';
  $sql   .= '"AnalysisGroupDescription", ';
  $sql   .= '"ContactId", ';
  $sql   .= '"OwnGroupId", ';
  $sql   .= '"AccessGroupId", ';
  $sql   .= '"OwnGroupPerm", ';
  $sql   .= '"AccessGroupPerm", ';
  $sql   .= '"OtherPerm") ';
  $sql   .= 'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)';

  my $sth = $dbh_m_write->prepare($sql);
  $sth->execute(
                $anal_id,
                $AnalysisGroupName,
                $AnalysisGroupDescription,
                $ContactId,
                $group_id,
                $AccessGroupId,
                $OwnGroupPerm,
                $AccessGroupPerm,
                $OtherPerm
   );

  my $AnalysisGroupId = -1;

  my $inserted_id = {};

  if (!$dbh_m_write->err()) {

    $AnalysisGroupId = $anal_id;
    $self->logger->debug("AnalysisGroupId: $AnalysisGroupId");

    if ( !(defined($inserted_id->{'analysisgroup'})) ) {

      $inserted_id->{'analysisgroup'} = { 'IdField' => 'AnalysisGroupId',
                                          'IdValue' => [$AnalysisGroupId] };
    }
  }
  else {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  #insert into factor table
  for my $vcol_id (keys(%{$vcol_data})) {

    my $factor_value = $query->param('VCol_' . $vcol_id);

    if (length($factor_value) > 0) {

      $sql  = 'INSERT INTO analysisgroupfactor SET ';
      $sql .= 'AnalysisGroupId=?, ';
      $sql .= 'FactorId=?, ';
      $sql .= 'FactorValue=?';
      my $factor_sth = $dbh_m_write->prepare($sql);
      $factor_sth->execute($AnalysisGroupId, $vcol_id, $factor_value);

      if ($dbh_m_write->err()) {

        my ($rollback_err, $rollback_msg) = rollback_cleanup_multi($self->logger(), $dbh_m_write, $inserted_id);

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

      if ( !(defined($inserted_id->{'analysisgroupfactor'})) ) {

        $inserted_id->{'analysisgroupfactor'} = { 'IdField' => 'AnalysisGroupId',
                                                  'IdValue' => [$AnalysisGroupId] };
      }

      $factor_sth->finish();
    }
  }

  my $nb_extract = scalar(@{$extract_aref});

  my $i = 0;

  while($i < $nb_extract) {

    my $i_start_time = [gettimeofday()];

    $sql  = 'INSERT INTO "analgroupextract" ';
    $sql .= '("AnalysisGroupId", "ExtractId") ';
    $sql .= 'VALUES ';

    my @sql_row;

    my $j = $i + 10000;

    if ($j > $nb_extract) { $j = $nb_extract; };

    for (my $k = $i; $k < $j; $k++) {

      my $extract_rec = $extract_aref->[$k];

      my $ExtractId = $extract_rec->{'ExtractId'};
      push(@sql_row, "($AnalysisGroupId, $ExtractId)" );
    }

    $sql .= join(',', @sql_row);

    my $extracts_sth = $dbh_m_write->prepare($sql);
    $extracts_sth->execute();

    if ($dbh_m_write->err()) {

      $self->logger->debug("SQL err: " . $dbh_m_write->errstr());

      my ($rollback_err, $rollback_msg) = rollback_cleanup_multi($self->logger(), $dbh_m_write, $inserted_id);

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

    my $i_elapsed = tv_interval($i_start_time);

    $self->logger->debug("I: $i - time: $i_elapsed seconds");

    $i += 10000;
  }

  $dbh_m_write->disconnect();

  my $info_msg_aref  = [{'Message' => "AnalysisGroup ($AnalysisGroupId) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$AnalysisGroupId", 'ParaName' => 'AnalysisGroupId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_analysisgroup_runmode {

=pod update_analysisgroup_HELP_START
{
"OperationName": "Update analysis group",
"Description": "Update analysis group definition. This groups DNA extracts which will undergo genotyping experiment together.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "marker",
"KDDArTTable": "analysisgroup",
"KDDArTFactorTable": "analysisgroupfactor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId ParaName='AnalysisGroupId' Value='55' /><Info Message='AnalysisGroup (55) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '55','ParaName' : 'AnalysisGroupId'}], 'StatInfo' : [{'ServerElapsedTime' : '0.086','Unit' : 'second'}],'Info' : [{'Message' : 'AnalysisGroup (55) has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error MarkerStateType='MarkerStateType (252) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'MarkerStateType' : 'MarkerStateType (252) not found.'}]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut
  my $self            = shift;
  my $AnalysisGroupId = $self->param('id');
  my $query           = $self->query();

  my $data_for_postrun_href    =  {};

   # Generic required static field checking

  my $dbh_read = connect_mdb_read();

  my $skip_field = {'OwnGroupId'      => 1,
                    'AccessGroupId'   => 1,
                    'OwnGroupPerm'    => 1,
                    'AccessGroupPerm' => 1,
                    'OtherPerm'       => 1,
                   };

  my $field_name_translation = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'analysisgroup', $skip_field,
                                                                                $field_name_translation,
                                                                               );
  if ($chk_sfield_err) {

     $self->logger->debug($chk_sfield_msg);

     return $for_postrun_href;
  }

  $dbh_read->disconnect();
  # Finish generic required static field checking

  my $AnalysisGroupName         = $query->param('AnalysisGroupName');
  my $AccessGroupId             = $query->param('AccessGroupId');

  my $dbh_k_read = connect_kdb_read();
  my $dbh_m_read = connect_mdb_read();

  my $read_anagroup_sql   =  'SELECT "AnalysisGroupDescription", "ContactId" ';
     $read_anagroup_sql  .=  'FROM "analysisgroup" ';
     $read_anagroup_sql  .=  'WHERE "AnalysisGroupId"=? ';

  my ($r_df_val_err, $r_df_val_msg, $anagroup_df_val_data) = read_data($dbh_m_read, $read_anagroup_sql, [$AnalysisGroupId]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve analysisgroup default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $AnalysisGroupDescription = undef;
  my $ContactId                = undef;

  my $nb_df_val_rec    =  scalar(@{$anagroup_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve analysisgroup default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $AnalysisGroupDescription  = $anagroup_df_val_data->[0]->{'AnalysisGroupDescription'};
  $ContactId                 = $anagroup_df_val_data->[0]->{'ContactId'};

  if (defined($query->param('AnalysisGroupDescription'))) {

    $AnalysisGroupDescription = $query->param('AnalysisGroupDescription');
  }

  if (defined($query->param('ContactId'))) {

    if (length($query->param('ContactId')) > 0) {

      $ContactId = $query->param('ContactId');
    }
  }

  $self->logger->debug('Adding Analysis Group');

  my $sql    = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength ";
     $sql   .= "FROM factor ";
     $sql   .= "WHERE TableNameOfFactor='analysisgroupfactor'";

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

  my ($vcol_missing_err, $vcol_missing_href) = check_missing_href( $vcol_param_data );

  if ($vcol_missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$vcol_missing_href]};

    return $data_for_postrun_href;
  }

  my ($vcol_maxlen_err, $vcol_maxlen_href) = check_maxlen_href($vcol_param_data_maxlen, $vcol_len_info);

  if ($vcol_maxlen_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$vcol_maxlen_href]};

    return $data_for_postrun_href;
  }

  my $chk_start_time = [gettimeofday()];

  $self->logger->debug("Checking AnalysisGroupName: $AnalysisGroupName");

  my $chk_elapsed = tv_interval($chk_start_time);

  $self->logger->debug("Check analysisgroup name time: $chk_elapsed seconds");

  #check that supplied access group exists
  my $access_grp_existence = record_existence($dbh_k_read, 'systemgroup', 'SystemGroupId', $AccessGroupId);

  if (!$access_grp_existence) {

     my $err_msg = "AccessGroup ($AccessGroupId) does not exist.";

     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'AccessGroupId' => $err_msg}]};

     return $data_for_postrun_href;
  }

  if ($ContactId ne '0') {

    if (!record_existence($dbh_k_read, 'contact', 'ContactId', $ContactId)) {

      my $err_msg = "Contact ($ContactId) not found.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'ContactId' => $err_msg}]};

      return $data_for_postrun_href;
    }
   }

  $dbh_k_read->disconnect();
  $dbh_m_read->disconnect();

  my $dbh_m_write = connect_mdb_write();

  #update main table
  $sql    = 'UPDATE "analysisgroup" SET ';
  $sql   .= '"AnalysisGroupName"=?, ';
  $sql   .= '"AnalysisGroupDescription"=?, ';
  $sql   .= '"ContactId"=? ';
  $sql   .= 'WHERE "AnalysisGroupId"=? ';

  my $sth = $dbh_m_write->prepare($sql);
     $sth->execute(
                $AnalysisGroupName,
                $AnalysisGroupDescription,
                $ContactId,
                $AnalysisGroupId
     );

  if ($dbh_m_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();
  
  #update factor table
  for my $vcol_id (keys(%{$vcol_data})) {

    my $factor_value = $query->param('VCol_' . $vcol_id);

    $sql    =    'SELECT Count(*) ';
    $sql   .=    'FROM "analysisgroupfactor" ';
    $sql   .=    'WHERE "AnalysisGroupId"=? AND "FactorId"=? ';

    my ($read_err, $count)   = read_cell($dbh_m_write, $sql, [$AnalysisGroupId, $vcol_id]);

    if (length($factor_value) > 0) {

       if ($count > 0)  {
       $sql     =   'UPDATE "analysisgroupfactor" SET ';
       $sql    .=   '"FactorValue"=? ';
       $sql    .=   'WHERE "AnalysisGroupId"=? AND "FactorId"=? ';

       my $factor_sth = $dbh_m_write->prepare($sql);
          $factor_sth->execute($factor_value, $AnalysisGroupId, $vcol_id);

        if ($dbh_m_write->err()) {

          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

          return $data_for_postrun_href;
        }

        $factor_sth->finish();
     }
     else {

         $sql   =  'INSERT INTO "analysisgroupfactor"(';
         $sql  .=  '"AnalysisGroupId", ';
         $sql  .=  '"FactorId", ';
         $sql  .=  '"FactorValue") ';
         $sql  .=  'VALUES(?, ?, ?)';

         my $factor_sth  =  $dbh_m_write->prepare($sql);
            $factor_sth->execute($AnalysisGroupId, $vcol_id, $factor_value);

         if ($dbh_m_write->err()) {

            $data_for_postrun_href->{'Error'}  = 1;
            $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected error.'}]};

            return $data_for_postrun_href;
         }

          $factor_sth->finish();
     }
   }

   else {

     if ($count > 0)  {

        $sql   =  'DELETE FROM "analysisgroup" ';
        $sql  .=  'WHERE "AnalysisGroupId"=? AND "FactorId"=? ';

        my $factor_sth = $dbh_m_write->prepare($sql);
            $factor_sth->execute($AnalysisGroupId, $vcol_id);

        if ($dbh_m_write->err()) {

          $self->logger->debug("Delete analysisgroupfactor failed");
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

          return $data_for_postrun_href;
        }
        $factor_sth->finish();
     }
    }
  }

  $dbh_m_write->disconnect();

  my $info_msg_aref = [{'Message' => "AnalysisGroup ($AnalysisGroupId) has been updated successfully."}];
  my $return_id_aref = [{'Value' => "$AnalysisGroupId", 'ParaName' => 'AnalysisGroupId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref,
                                           'ReturnId' => $return_id_aref,
  };

  $data_for_postrun_href->{'ExtractData'} = 0;

  return $data_for_postrun_href;
}

sub add_plate_n_extract_runmode {

=pod add_plate_n_extract_gadmin_HELP_START
{
"OperationName": "Add plate with extracts",
"Description": "Add DNA plate and extracts together. Allows to define entire plate and contents in one call.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "marker",
"KDDArTTable": "plate",
"KDDArTFactorTable": "platefactor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId ParaName='PlateId' Value='8' /><Info Message='Plate (8) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '9','ParaName' : 'PlateId'}],'Info' : [{'Message' : 'Plate (9) has been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error PlateType='PlateType (251) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'PlateType' : 'PlateType (251) not found.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "XML",
"UploadFileParameterName": "uploadfile",
"DTDFileNameForUploadXML": "extract_all_field.dtd",
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_mdb_read();

  my $skip_field = {};

  my $field_name_translation = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'plate', $skip_field,
                                                                                $field_name_translation,
                                                                               );

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $PlateName        = $query->param('PlateName');

  my $OperatorId       = $query->param('OperatorId');

  my $PlateType        = undef;

  if (defined($query->param('PlateType'))) {

    if (length($query->param('PlateType')) > 0) {

      $PlateType = $query->param('PlateType');
    }
  }

  my $PlateDescription = undef;

  if (defined($query->param('PlateDescription'))) {

    if (length($query->param('PlateDescription')) > 0) {

      $PlateDescription = $query->param('PlateDescription');
    }
  }

  my $StorageId        = undef;

  if (defined($query->param('StorageId'))) {

    if (length($query->param('StorageId')) > 0) {

      $StorageId = $query->param('StorageId');
    }
  }

  my $PlateWells       = undef;

  if (defined($query->param('PlateWells'))) {

    if (length($query->param('PlateWells')) > 0) {

      $PlateWells = $query->param('PlateWells');
    }
  }

  my $PlateStatus      = undef;

  if (defined($query->param('PlateStatus'))) {

    if (length($query->param('PlateStatus')) > 0) {

      $PlateStatus = $query->param('PlateStatus');
    }
  }

  my $cur_dt = DateTime->now( time_zone => $TIMEZONE );
  $cur_dt = DateTime::Format::MySQL->format_datetime($cur_dt);

  my $DateCreated = $cur_dt;

  if (defined($query->param('DateCreated'))) {

    if (length($query->param('DateCreated')) > 0) {

      $DateCreated = $query->param('DateCreated');
      my ($cdate_err, $cdate_href) = check_dt_href( {'DateCreated' => $DateCreated} );

      if ($cdate_err) {

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [$cdate_href]};

        return $data_for_postrun_href;
      }
    }
  }

  if (length($PlateWells) > 0) {

    my ($int_err, $int_href) = check_integer_href( {'PlateWells' => $PlateWells} );

    if ($int_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [$int_href]};

      return $data_for_postrun_href;
    }
  }

  $self->logger->debug("Plate name: $PlateName");

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='platefactor'";

  my $dbh_k_read = connect_kdb_read();
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

  my ($vcol_missing_err, $vcol_missing_href) = check_missing_href( $vcol_param_data );

  if ($vcol_missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$vcol_missing_href]};

    return $data_for_postrun_href;
  }

  my ($vcol_maxlen_err, $vcol_maxlen_href) = check_maxlen_href($vcol_param_data_maxlen, $vcol_len_info);

  if ($vcol_maxlen_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$vcol_maxlen_href]};

    return $data_for_postrun_href;
  }

  if (!record_existence($dbh_k_read, 'systemuser', 'UserId', $OperatorId)) {

    my $err_msg = "OperatorId ($OperatorId) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (defined $PlateType) {

    if (!type_existence($dbh_k_read, 'plate', $PlateType)) {

      my $err_msg = "PlateType ($PlateType) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'PlateType' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (defined $StorageId) {

    if ( !record_existence($dbh_k_read, 'storage', 'StorageId', $StorageId) ) {

      my $err_msg = "StorageId ($StorageId) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $dbh_m_read = connect_mdb_read();

  if (record_existence($dbh_m_read, 'plate', 'PlateName', $PlateName)) {

    my $err_msg = " ($PlateName) already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'PlateName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $extract_xml_file = $self->authen->get_upload_file();
  my $extract_dtd_file = $self->get_extract_all_field_dtd_file();

  add_dtd($extract_dtd_file, $extract_xml_file);

  $self->logger->debug("Extract XML file: $extract_xml_file");

  my $xml_checker_parser = new XML::Checker::Parser( Handlers => { } );

  eval {

    local $XML::Checker::FAIL = sub {

      my $code = shift;
      my $err_str = XML::Checker::error_string ($code, @_);
      $self->logger->debug("XML Parsing ERR: $code : $err_str");
      die $err_str;
    };
    $xml_checker_parser->parsefile($extract_xml_file);
  };

  if ($@) {

    my $err_msg = $@;
    $self->logger->debug("Parsing XML error: $err_msg");
    my $user_err_msg = "Extract xml file does not comply with its definition.\n";
    $user_err_msg   .= "Details: $err_msg";

    $data_for_postrun_href->{'Error'}       = 1;
    $data_for_postrun_href->{'Data'}        = {'Error' => [{'Message' => $user_err_msg}]};

    return $data_for_postrun_href;
  }

  my ($get_scol_err, $get_scol_msg, $scol_data, $pkey_data) = get_static_field($dbh_m_read, 'extract');

  if ($get_scol_err) {

    $self->logger->debug("Get static field info failed: $get_scol_msg");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $extract_xml  = read_file($extract_xml_file);
  my $extract_aref = xml2arrayref($extract_xml, 'extract');

  my $seen_geno_id    = {};
  my $geno2itemgroup  = {};

  my $uniq_well       = {};

  for my $extract_rec (@{$extract_aref}) {

    my $colsize_info          = {};
    my $chk_maxlen_field_href = {};

    for my $static_field (@{$scol_data}) {

      my $field_name  = $static_field->{'Name'};
      my $field_dtype = $static_field->{'DataType'};

      if (lc($field_dtype) eq 'varchar') {

        $colsize_info->{$field_name}           = $static_field->{'ColSize'};
        $chk_maxlen_field_href->{$field_name}  = $extract_rec->{$field_name};
      }
    }

    my ($maxlen_err, $maxlen_msg) = check_maxlen($chk_maxlen_field_href, $colsize_info);

    if ($maxlen_err) {

      $maxlen_msg .= 'longer than its maximum length';

      $data_for_postrun_href->{'Error'}       = 1;
      $data_for_postrun_href->{'Data'}        = {'Error' => [{'Message' => $maxlen_msg}]};

      return $data_for_postrun_href;
    }

    my $ItemGroupId = undef;

    if (defined($extract_rec->{'ItemGroupId'})) {

      if (length($extract_rec->{'ItemGroupId'}) > 0) {

        $ItemGroupId = $extract_rec->{'ItemGroupId'};
      }
    }

    my $ParentExtractId = undef;

    if (defined($extract_rec->{'ParentExtractId'})) {

      if (length($extract_rec->{'ParentExtractId'}) > 0) {

        $ParentExtractId = $extract_rec->{'ParentExtractId'};
      }
    }

    my $PlateId = undef;

    if (defined($extract_rec->{'PlateId'})) {

      if (length($extract_rec->{'PlateId'}) > 0) {

        $PlateId = $extract_rec->{'PlateId'};
      }
    }

    my $GenotypeId = undef;

    if (defined($extract_rec->{'GenotypeId'})) {

      if (length($extract_rec->{'GenotypeId'}) > 0) {

        $GenotypeId = $extract_rec->{'GenotypeId'};
      }
    }

    my $Tissue = $extract_rec->{'Tissue'};

    my $WellRow = undef;

    if (defined($extract_rec->{'WellRow'})) {

      if (length($extract_rec->{'WellRow'}) > 0) {

        $WellRow = $extract_rec->{'WellRow'};
      }
    }

    my $WellCol = undef;

    if (defined($extract_rec->{'WellCol'})) {

      if (length($extract_rec->{'WellCol'}) > 0) {

        $WellCol = $extract_rec->{'WellCol'};
      }
    }

    my $Quality = undef;

    if (defined($extract_rec->{'Quality'})) {

      if (length($extract_rec->{'Quality'}) > 0) {

        $Quality = $extract_rec->{'Quality'};
      }
    }

    my $Status = undef;

    if (defined($extract_rec->{'Status'})) {

      if (length($extract_rec->{'Status'}) > 0) {

        $Status = $extract_rec->{'Status'};
      }
    }

    my ($missing_err, $missing_msg) = check_missing_value( {'Tissue' => $Tissue} );

    if ($missing_err) {

      $missing_msg = 'ItemGroupId is missing.';
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $missing_msg}]};

      return $data_for_postrun_href;
    }

    if (defined $ParentExtractId) {

      if (!record_existence($dbh_m_read, 'extract', 'ExtractId', $ParentExtractId)) {

        my $err_msg = "ParentExtractId ($ParentExtractId) not found.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }

    if (defined $ItemGroupId) {

      if (!record_existence($dbh_k_read, 'itemgroup', 'ItemGroupId', $ItemGroupId)) {

        my $err_msg = "ItemGroupId ($ItemGroupId) not found.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }

    my $get_geno_sql = '';

    if (defined $GenotypeId ) {

      if (defined $ItemGroupId) {

        $get_geno_sql    = 'SELECT genotypespecimen.GenotypeId ';
        $get_geno_sql   .= 'FROM itemgroupentry LEFT JOIN item ON itemgroupentry.ItemId = item.ItemId ';
        $get_geno_sql   .= 'LEFT JOIN genotypespecimen ON item.SpecimenId = genotypespecimen.SpecimenId ';
        $get_geno_sql   .= 'WHERE itemgroupentry.ItemGroupId=? AND genotypespecimen.GenotypeId=?';

        my ($verify_geno_err, $verified_geno_id) = read_cell($dbh_k_read, $get_geno_sql, [$ItemGroupId, $GenotypeId]);

        if (length($verified_geno_id) == 0) {

          my $err_msg = "GenotypeId ($GenotypeId): not found";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }

        $get_geno_sql    = 'SELECT genotypespecimen.GenotypeId ';
        $get_geno_sql   .= 'FROM itemgroupentry LEFT JOIN item ON itemgroupentry.ItemId = item.ItemId ';
        $get_geno_sql   .= 'LEFT JOIN genotypespecimen ON item.SpecimenId = genotypespecimen.SpecimenId ';
        $get_geno_sql   .= 'WHERE itemgroupentry.ItemGroupId=?';

        my ($get_geno_err, $get_geno_msg, $geno_data) = read_data($dbh_k_read, $get_geno_sql, [$ItemGroupId]);

        if ($get_geno_err) {

          $self->logger->debug($get_geno_msg);

          my $err_msg = "Unexpected Error.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }

        for my $geno_rec (@{$geno_data}) {

          my $geno_id = $geno_rec->{'GenotypeId'};
          $seen_geno_id->{$geno_id} = 1;

          $geno2itemgroup->{$geno_id} = $ItemGroupId;
        }
      }
      else {

        if (!record_existence($dbh_k_read, 'genotype', 'GenotypeId', $GenotypeId)) {

          my $err_msg = "GenotypeId ($GenotypeId): not found.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'GenotypeId' => $err_msg}]};

          return $data_for_postrun_href;
        }

        $seen_geno_id->{$GenotypeId} = 1;
      }
    }
    else {

      if (defined $ItemGroupId) {

        $get_geno_sql    = 'SELECT genotypespecimen.GenotypeId ';
        $get_geno_sql   .= 'FROM itemgroupentry LEFT JOIN item ON itemgroupentry.ItemId = item.ItemId ';
        $get_geno_sql   .= 'LEFT JOIN genotypespecimen ON item.SpecimenId = genotypespecimen.SpecimenId ';
        $get_geno_sql   .= 'WHERE itemgroupentry.ItemGroupId=?';

        my ($get_geno_err, $get_geno_msg, $geno_data) = read_data($dbh_k_read, $get_geno_sql, [$ItemGroupId]);

        if ($get_geno_err) {

          $self->logger->debug($get_geno_msg);

          my $err_msg = "Unexpected Error.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }

        for my $geno_rec (@{$geno_data}) {

          my $geno_id = $geno_rec->{'GenotypeId'};
          $seen_geno_id->{$geno_id} = 1;

          $geno2itemgroup->{$geno_id} = $ItemGroupId;
        }
      }
    }

    if ( (defined $WellRow) && (defined $WellCol) ) {

      my $well = $WellRow . $WellCol;
      if (defined($uniq_well->{$well})) {

        my $err_msg = "Well ($well) has been used in more than one extract.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
      else {

        $uniq_well->{$well} = 1;
      }
    }

    if ( (!(defined $ItemGroupId)) && (!(defined $GenotypeId)) ) {

      my $err_msg = "GenotypeId and ItemGroupId: both missing.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @geno_id_list = keys(%{$seen_geno_id});

  my $group_id       = $self->authen->group_id();
  my $gadmin_status  = $self->authen->gadmin_status();

  my ($is_ok, $trouble_geno_id_aref) = check_permission($dbh_k_read, 'genotype', 'GenotypeId',
                                                        \@geno_id_list, $group_id, $gadmin_status,
                                                        $LINK_PERM);
  if (!$is_ok) {

    my %trouble_itemgroup_id;

    for my $trouble_geno_id (@{$trouble_geno_id_aref}) {

      if (defined $geno2itemgroup->{$trouble_geno_id}) {

        my $trouble_ig_id = $geno2itemgroup->{$trouble_geno_id};
        $trouble_itemgroup_id{$trouble_ig_id} = 1;
      }
    }

    my @trouble_itemgroup_id_list = keys(%trouble_itemgroup_id);

    my $trouble_itemgroup_id_str = join(',', @trouble_itemgroup_id_list);

    $self->logger->debug("Permission denied: ItemId $trouble_itemgroup_id_str");

    my $err_msg = 'Permission denied: GenotypeId (' . join(',', @{$trouble_geno_id_aref}) . ')';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_m_read->disconnect();
  $dbh_k_read->disconnect();

  my $dbh_m_write = connect_mdb_write();

  my ($next_val_err, $next_val_msg, $plt_id) = get_next_value_for($dbh_m_write, 'plate', 'PlateId');

  if ($next_val_err) {

    $self->logger->debug($next_val_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("Next plate id: $plt_id");

  my $inserted_id = {};

  $sql  = 'INSERT INTO "plate"( ';
  $sql .= '"PlateId", ';
  $sql .= '"PlateName", ';
  $sql .= '"DateCreated", ';
  $sql .= '"OperatorId", ';
  $sql .= '"PlateType", ';
  $sql .= '"PlateDescription", ';
  $sql .= '"StorageId", ';
  $sql .= '"PlateWells", ';
  $sql .= '"PlateStatus") ';
  $sql .= 'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)';

  my $sth = $dbh_m_write->prepare($sql);
  $sth->execute($plt_id, $PlateName, $DateCreated, $OperatorId, $PlateType,
                $PlateDescription, $StorageId, $PlateWells, $PlateStatus);

  $self->logger->debug("Add Plate SQL: $sql");

  my $plate_id = -1;
  if (!$dbh_m_write->err()) {

    $plate_id = $plt_id;
    $self->logger->debug("PlateId: $plate_id");

    if ( !(defined($inserted_id->{'plate'})) ) {

      $inserted_id->{'plate'} = { 'IdField' => 'PlateId',
                                  'IdValue' => [$plate_id] };
    }
  }
  else {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  for my $vcol_id (keys(%{$vcol_data})) {

    my $factor_value = $query->param('VCol_' . "$vcol_id");

    if (length($factor_value) > 0) {

      $sql  = 'INSERT INTO "platefactor"(';
      $sql .= '"PlateId", ';
      $sql .= '"FactorId", ';
      $sql .= '"FactorValue") ';
      $sql .= 'VALUES (?, ?, ?)';

      my $factor_sth = $dbh_m_write->prepare($sql);
      $factor_sth->execute($plate_id, $vcol_id, $factor_value);

      if ($dbh_m_write->err()) {

        my ($rollback_err, $rollback_msg) = rollback_cleanup_multi($self->logger(), $dbh_m_write, $inserted_id);

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

      if ( !(defined($inserted_id->{'platefactor'})) ) {

        $inserted_id->{'platefactor'} = { 'IdField' => 'PlateId',
                                          'IdValue' => [$plate_id] };
      }

      $factor_sth->finish();
    }
  }

  $sql  = q|INSERT INTO "extract"("ExtractId","ParentExtractId","PlateId","ItemGroupId","GenotypeId","Tissue",|;
  $sql .= q|"WellRow","WellCol","Quality","Status")|;
  $sql .= ' VALUES ';

  my @extract_sql_rec_list;

  for my $extract_rec (@{$extract_aref}) {

    my $ItemGroupId        = 'NULL';

    if (defined $extract_rec->{'ItemGroupId'}) {

      if (length($extract_rec->{'ItemGroupId'}) > 0) {

        $ItemGroupId        = $extract_rec->{'ItemGroupId'};
      }
    }

    my $ParentExtractId = 'NULL';

    if (defined($extract_rec->{'ParentExtractId'})) {

      if (length($extract_rec->{'ParentExtractId'}) > 0) {

        $ParentExtractId = $extract_rec->{'ParentExtractId'};
      }
    }

    my $GenotypeId = 'NULL';

    if (defined($extract_rec->{'GenotypeId'})) {

      if (length($extract_rec->{'GenotypeId'}) > 0) {

        $GenotypeId = $extract_rec->{'GenotypeId'};
      }
    }

    my $Tissue = $extract_rec->{'Tissue'};

    my $WellRow = 'NULL';

    if (defined($extract_rec->{'WellRow'})) {

      if (length($extract_rec->{'WellRow'}) > 0) {

        $WellRow = $dbh_m_write->quote($extract_rec->{'WellRow'});
      }
    }

    my $WellCol = 'NULL';

    if (defined($extract_rec->{'WellCol'})) {

      if (length($extract_rec->{'WellCol'}) > 0) {

        $WellCol = $dbh_m_write->quote($extract_rec->{'WellCol'});
      }
    }

    my $Quality = 'NULL';

    if (defined($extract_rec->{'Quality'})) {

      if (length($extract_rec->{'Quality'}) > 0) {

        $Quality = $dbh_m_write->quote($extract_rec->{'Quality'});
      }
    }

    my $Status = 'NULL';

    if (defined($extract_rec->{'Status'})) {

      if (length($extract_rec->{'Status'}) > 0) {

        $Status = $dbh_m_write->quote($extract_rec->{'Status'});
      }
    }

    my ($next_val_err, $next_val_msg, $ext_id) = get_next_value_for($dbh_m_write, 'extract', 'ExtractId');

    if ($next_val_err) {

      $self->logger->debug($next_val_msg);

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $extract_sql_rec_str = qq|(${ext_id},${ParentExtractId},${plate_id},${ItemGroupId},${GenotypeId},${Tissue},|;
    $extract_sql_rec_str   .= qq|${WellRow},${WellCol},${Quality},${Status})|;

    push(@extract_sql_rec_list, $extract_sql_rec_str);
  }

  if (scalar(@extract_sql_rec_list) > 0) {

    $sql .= join(',', @extract_sql_rec_list);

    $sth = $dbh_m_write->prepare($sql);
    $sth->execute();

    my $extract_id = -1;
    if ($dbh_m_write->err()) {

      $self->logger->debug("SQL err: " . $dbh_m_write->errstr());

      my ($rollback_err, $rollback_msg) = rollback_cleanup_multi($self->logger(), $dbh_m_write, $inserted_id);

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
  }

  $dbh_m_write->disconnect();

  my $info_msg_aref = [{'Message' => "Plate ($plate_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$plate_id", 'ParaName' => 'PlateId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub add_plate_runmode {

=pod add_plate_gadmin_HELP_START
{
"OperationName": "Add plate",
"Description": "Add plate definition to the system for grouping DNA extracts",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "marker",
"KDDArTTable": "plate",
"KDDArTFactorTable": "platefactor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='10' ParaName='PlateId' /><Info Message='Plate (10) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '11','ParaName' : 'PlateId'}], 'Info' : [{'Message' : 'Plate (11) has been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error PlateType='PlateType (251) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'PlateType' : 'PlateType (251) not found.'}]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_mdb_read();

  my $skip_field = {'DateCreated' => 1};

  my $field_name_translation = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'plate', $skip_field,
                                                                                $field_name_translation,
                                                                               );

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $PlateName        = $query->param('PlateName');
  my $OperatorId       = $query->param('OperatorId');

  my $PlateType        = '0';

  if (defined($query->param('PlateType'))) {

    if (length($query->param('PlateType')) > 0) {

      $PlateType = $query->param('PlateType');
    }
  }

  my $PlateDescription = '';

  if (defined($query->param('PlateDescription'))) {

    $PlateDescription = $query->param('PlateDescription');
  }

  my $StorageId        = '0';

  if (defined($query->param('StorageId'))) {

    if (length($query->param('StorageId')) > 0) {

      $StorageId = $query->param('StorageId');
    }
  }

  my $PlateWells       = undef;

  if (defined($query->param('PlateWells'))) {

    $PlateWells = $query->param('PlateWells');
  }

  my $PlateStatus      = '';

  if (defined($query->param('PlateStatus'))) {

    $PlateStatus = $query->param('PlateStatus');
  }

  my $dbh_k_read = connect_kdb_read();

  if (length($PlateWells) > 0) {

    my ($int_err, $int_href) = check_integer_href( {'PlateWells' => $PlateWells} );

    if ($int_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [$int_href]};

      return $data_for_postrun_href;
    }
  }

  $self->logger->debug("Plate name: $PlateName");

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='platefactor'";

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

  my ($vcol_missing_err, $vcol_missing_href) = check_missing_href( $vcol_param_data );

  if ($vcol_missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$vcol_missing_href]};

    return $data_for_postrun_href;
  }

  my ($vcol_maxlen_err, $vcol_maxlen_href) = check_maxlen_href($vcol_param_data_maxlen, $vcol_len_info);

  if ($vcol_maxlen_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$vcol_maxlen_href]};

    return $data_for_postrun_href;
  }

  if (!record_existence($dbh_k_read, 'systemuser', 'UserId', $OperatorId)) {

    my $err_msg = "OperatorId ($OperatorId) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ($PlateType ne '0') {

    if (!type_existence($dbh_k_read, 'plate', $PlateType)) {

      my $err_msg = "PlateType ($PlateType) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'PlateType' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if ($StorageId ne '0') {

    if ( !record_existence($dbh_k_read, 'storage', 'StorageId', $StorageId) ) {

      my $err_msg = "StorageId ($StorageId) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $dbh_m_read = connect_mdb_read();

  if (record_existence($dbh_m_read, 'plate', 'PlateName', $PlateName)) {

    my $err_msg = " ($PlateName) already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'PlateName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $cur_dt = DateTime->now( time_zone => $TIMEZONE );
  $cur_dt = DateTime::Format::MySQL->format_datetime($cur_dt);

  my $DateCreated = $cur_dt;

  my $extract_xml_file = $self->authen->get_upload_file();
  my $extract_dtd_file = $self->get_extract_dtd_file();

  add_dtd($extract_dtd_file, $extract_xml_file);

  $self->logger->debug("Extract XML file: $extract_xml_file");

  my $xml_checker_parser = new XML::Checker::Parser( Handlers => { } );

  eval {

    local $XML::Checker::FAIL = sub {

      my $code = shift;
      my $err_str = XML::Checker::error_string ($code, @_);
      $self->logger->debug("XML Parsing ERR: $code : $err_str");
      die $err_str;
    };
    $xml_checker_parser->parsefile($extract_xml_file);
  };

  if ($@) {

    my $err_msg = $@;
    $self->logger->debug("Parsing XML error: $err_msg");
    my $user_err_msg = "Extract xml file does not comply with its definition.\n";
    $user_err_msg   .= "Details: $err_msg";

    $data_for_postrun_href->{'Error'}       = 1;
    $data_for_postrun_href->{'Data'}        = {'Error' => [{'Message' => $user_err_msg}]};

    return $data_for_postrun_href;
  }

  my $extract_xml  = read_file($extract_xml_file);
  my $extract_aref = xml2arrayref($extract_xml, 'extract');

  my $uniq_well_href  = {};
  my $uniq_extract_id = {};

  for my $extract_rec (@{$extract_aref}) {

    my $extract_id = $extract_rec->{'ExtractId'};

    if (!record_existence($dbh_m_read, 'extract', 'ExtractId', $extract_id)) {

      my $err_msg = "Extract ($extract_id) not found.";
      $data_for_postrun_href->{'Error'}       = 1;
      $data_for_postrun_href->{'Data'}        = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $plate_id = read_cell_value($dbh_m_read, 'extract', 'PlateId', 'ExtractId', $extract_id);

    if (length($plate_id) > 0) {

      if ($plate_id != 0) {

        my $err_msg = "Extract ($extract_id) has a plate assigned already.";
        $data_for_postrun_href->{'Error'}       = 1;
        $data_for_postrun_href->{'Data'}        = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }

    $sql = 'SELECT CONCAT("WellRow","WellCol") AS "Well" FROM "extract" WHERE "ExtractId"=?';

    my ($read_well_err, $well) = read_cell($dbh_m_read, $sql, [$extract_id]);

    if (defined($uniq_well_href->{$well})) {

      my $dup_well_extract_id = $uniq_well_href->{$well};

      my $err_msg = "Extract ($extract_id) and extract ($dup_well_extract_id) have the same well position ($well).";
      $data_for_postrun_href->{'Error'}       = 1;
      $data_for_postrun_href->{'Data'}        = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    else {

      $uniq_well_href->{$well} = $extract_id;
    }

    if (defined($uniq_extract_id->{$extract_id})) {

      my $err_msg = "Extract ($extract_id): duplicate.";
      $data_for_postrun_href->{'Error'}       = 1;
      $data_for_postrun_href->{'Data'}        = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    else {

      $uniq_extract_id->{$extract_id} = 1;
    }
  }

  $dbh_m_read->disconnect();
  $dbh_k_read->disconnect();

  my $dbh_m_write = connect_mdb_write();

  my ($next_val_err, $next_val_msg, $plt_id) = get_next_value_for($dbh_m_write, 'plate', 'PlateId');

  if ($next_val_err) {

    $self->logger->debug($next_val_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $self->logger->debug("Plate ID: $plt_id");

  my $inserted_id = {};

  $sql  = 'INSERT INTO "plate"( ';
  $sql .= '"PlateId", ';
  $sql .= '"PlateName", ';
  $sql .= '"DateCreated", ';
  $sql .= '"OperatorId", ';
  $sql .= '"PlateType", ';
  $sql .= '"PlateDescription", ';
  $sql .= '"StorageId", ';
  $sql .= '"PlateWells", ';
  $sql .= '"PlateStatus") ';
  $sql .= 'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)';

  my $sth = $dbh_m_write->prepare($sql);
  $sth->execute($plt_id, $PlateName, $DateCreated, $OperatorId, $PlateType,
                $PlateDescription, $StorageId, $PlateWells, $PlateStatus);

  my $plate_id = -1;
  if (!$dbh_m_write->err()) {

    $plate_id = $plt_id;
    $self->logger->debug("PlateId: $plate_id");

    if ( !(defined($inserted_id->{'plate'})) ) {

      $inserted_id->{'plate'} = { 'IdField' => 'PlateId',
                                  'IdValue' => [$plate_id] };
    }
  }
  else {

    $self->logger->debug("Insert into plate failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  for my $vcol_id (keys(%{$vcol_data})) {

    my $factor_value = $query->param('VCol_' . "$vcol_id");

    if (length($factor_value) > 0) {

      $sql  = 'INSERT INTO "platefactor"( ';
      $sql .= '"PlateId", ';
      $sql .= '"FactorId", ';
      $sql .= '"FactorValue) ';
      $sql .= 'VALUES (?, ?, ?)';
      my $factor_sth = $dbh_m_write->prepare($sql);
      $factor_sth->execute($plate_id, $vcol_id, $factor_value);

      if ($dbh_m_write->err()) {

        my ($rollback_err, $rollback_msg) = rollback_cleanup_multi($self->logger(), $dbh_m_write, $inserted_id);

        if ($rollback_err) {

          $self->logger->debug("Rollback error: $rollback_msg");

          my $err_msg = 'Unexpected Error.';

          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }

        $self->logger->debug("Insert into platefactor failed");
        my $err_msg = 'Unexpected Error.';

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }

      if ( !(defined($inserted_id->{'platefactor'})) ) {

        $inserted_id->{'platefactor'} = { 'IdField' => 'PlateId',
                                          'IdValue' => [$plate_id] };
      }

      $factor_sth->finish();
    }
  }

  if (scalar(keys(%{$uniq_extract_id})) > 0) {

    my $extract_id_csv = join(',', keys(%{$uniq_extract_id}));

    $sql  = 'UPDATE "extract" SET ';
    $sql .= '"PlateId"=? ';
    $sql .= qq|WHERE "ExtractId" IN ($extract_id_csv)|;

    $sth = $dbh_m_write->prepare($sql);
    $sth->execute($plate_id);

    if ($dbh_m_write->err()) {

      my ($rollback_err, $rollback_msg) = rollback_cleanup_multi($self->logger(), $dbh_m_write, $inserted_id);

      if ($rollback_err) {

        $self->logger->debug("Rollback error: $rollback_msg");

        my $err_msg = 'Unexpected Error.';

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }

      $self->logger->debug("Update extract failed");
      my $err_msg = 'Unexpected Error.';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    $sth->finish();
  }

  $dbh_m_write->disconnect();

  my $info_msg_aref = [{'Message' => "Plate ($plate_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$plate_id", 'ParaName' => 'PlateId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_dataset_runmode {

=pod list_dataset_HELP_START
{
"OperationName": "List datasets",
"Description": "List datasets for a specified analysis group",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><DataSet MarkerNameFieldName='markerName' DataSetType='95' DataSetId='2' ParentDataSetId='' AnalysisGroupId='2' export='dataset/2/export/markerdata/csv' MarkerSequenceFieldName='TrimmedSequence' DataSetTypeName='DataSetType - 2971568' Description='' /><RecordMeta TagName='DataSet' /></DATA>",
"SuccessMessageJSON": "{  'DataSet' : [ { 'DataSetType' : '95', 'MarkerNameFieldName' : 'markerName', 'AnalysisGroupId' : '2', 'export' : 'dataset/2/export/markerdata/csv', 'DataSetId' : '2', 'MarkerSequenceFieldName' : 'TrimmedSequence', 'DataSetTypeName' : 'DataSetType - 2971568', 'ParentDataSetId' : null, 'Description' : ''}], 'RecordMeta' : [{'TagName' : 'DataSet'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing AnalysisGroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;

  my $data_for_postrun_href = {};

  my $anal_id = $self->param('id');

  my $dbh_m = connect_mdb_read();

  if (!record_existence($dbh_m, 'analysisgroup', 'AnalysisGroupId', $anal_id)) {

    my $err_msg = "AnalsysiGroup ($anal_id): not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id  = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_anal_grp_ok, $trouble_anal_id_aref) = check_permission($dbh_m, 'analysisgroup', 'AnalysisGroupId',
                                                                 [$anal_id], $group_id, $gadmin_status,
                                                                 $READ_PERM);

  if (!$is_anal_grp_ok) {

    my $err_msg = "AnalsysiGroup ($anal_id): permission denied.";
    $self->logger->debug($err_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_m->disconnect();

  my $sql = 'SELECT * from "dataset" WHERE "dataset"."AnalysisGroupId"=? ORDER BY "dataset"."DataSetId" DESC';

  $self->logger->debug("SQL: $sql");

  my ($read_dataset_err, $read_dataset_msg, $dataset_data) = $self->list_dataset(1, $sql, [$anal_id]);

  if ($read_dataset_err) {

    $self->logger->debug($read_dataset_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'DataSet'      => $dataset_data,
                                           'RecordMeta'   => [{'TagName' => 'DataSet'}],
  };

  return $data_for_postrun_href;
}

sub list_dataset {

  my $self              = $_[0];
  my $extra_attr_yes    = $_[1];
  my $sql               = $_[2];
  my $where_para_aref   = $_[3];

  #initialise variables
  my $err = 0;
  my $msg = '';
  my $data_aref = [];

  #get marker db handle
  my $dbh_m = connect_mdb_read();
  my $dbh_k = connect_kdb_read();

  ($err, $msg, $data_aref) = read_data($dbh_m, $sql, $where_para_aref);

  if ($err) {

    return ($err, $msg, []);
  }

  my $dataset_id_aref     = [];

  my $dataset_type_href   = {};

  my $dataset_type_lookup = {};

  if ($extra_attr_yes) {

    for my $dataset_row (@{$data_aref}) {

      push(@{$dataset_id_aref}, $dataset_row->{'DataSetId'});

      $dataset_type_href->{$dataset_row->{'DataSetType'}} = 1;
    }

    if (scalar(keys(%{$dataset_type_href})) > 0) {

      my $ds_type_sql      = 'SELECT TypeId, TypeName FROM generaltype ';
      $ds_type_sql        .= 'WHERE TypeId IN (' . join(',', keys(%{$dataset_type_href})) . ')';

      $self->logger->debug("DS_TYPE_SQL: $ds_type_sql");

      $dataset_type_lookup = $dbh_k->selectall_hashref($ds_type_sql, 'TypeId');
    }
  }

  my @extra_attr_dataset_data;

  for my $dataset_row (@{$data_aref}) {

    my $dataset_id = $dataset_row->{'DataSetId'};
    my $ds_type    = $dataset_row->{'DataSetType'};

    if ($extra_attr_yes) {

      $dataset_row->{'DataSetTypeName'} = $dataset_type_lookup->{$ds_type}->{'TypeName'};
      $dataset_row->{'export'}          = "dataset/${dataset_id}/export/markerdata/csv";
    }
    push(@extra_attr_dataset_data, $dataset_row);
  }

  $dbh_m->disconnect();
  $dbh_k->disconnect();

  return ($err, $msg, \@extra_attr_dataset_data);
}

sub import_plate_n_extract_runmode {

=pod import_plate_n_extract_gadmin_HELP_START
{
"OperationName": "Import plates and extracts at the same time",
"Description": "Import DNA plates and extracts together. Allows to define entire plate and contents in one call.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "marker",
"KDDArTTable": "plate",
"KDDArTFactorTable": "platefactor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='1 plates and 2 extracts have been inserted successfully.' /><ReturnIdFile xml='http://blackbox.diversityarrays.com/data/admin/import_plate_n_extract_gadmin_return_id_182.xml' /><StatInfo ServerElapsedTime='0.069' Unit='second' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : '1 plates and 2 extracts have been inserted successfully.'}],'ReturnIdFile' : [{'json' : 'http://blackbox.diversityarrays.com/data/admin/import_plate_n_extract_gadmin_return_id_190.json'}],'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.089'}]}",
"ErrorMessageXML": [{}],
"ErrorMessageJSON": [{}],
"RequiredUpload": 1,
"UploadFileFormat": "XML",
"UploadFileParameterName": "uploadfile",
"DTDFileNameForUploadXML": "import_plate_n_extract.dtd",
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $impt_plt_ext_xml_file = $self->authen->get_upload_file();
  my $impt_plt_ext_dtd_file = $self->get_import_plate_n_extract_dtd_file();

  add_dtd($impt_plt_ext_dtd_file, $impt_plt_ext_xml_file);

  $self->logger->debug("Impt_Plt_Ext XML file: $impt_plt_ext_xml_file");

  my $xml_checker_parser = new XML::Checker::Parser( Handlers => { } );

  eval {

    local $XML::Checker::FAIL = sub {

      my $code = shift;
      my $err_str = XML::Checker::error_string ($code, @_);
      $self->logger->debug("XML Parsing ERR: $code : $err_str");
      die $err_str;
    };
    $xml_checker_parser->parsefile($impt_plt_ext_xml_file);
  };

  if ($@) {

    my $err_msg = $@;
    $self->logger->debug("Parsing XML error: $err_msg");
    my $user_err_msg = "Import plate and extract xml upload file does not comply with its definition.\n";
    $user_err_msg   .= "Details: $err_msg";

    $data_for_postrun_href->{'Error'}       = 1;
    $data_for_postrun_href->{'Data'}        = {'Error' => [{'Message' => $user_err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_m_read = connect_mdb_read();
  my $dbh_k_read = connect_kdb_read();

  my ($get_ext_scol_err, $get_ext_scol_msg, $ext_scol_data, $ext_pkey_data) = get_static_field($dbh_m_read, 'extract');

  if ($get_ext_scol_err) {

    $self->logger->debug("Get static field info failed: $get_ext_scol_msg");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my ($get_plt_scol_err, $get_plt_scol_msg, $plt_scol_data, $plt_pkey_data) = get_static_field($dbh_m_read, 'plate');

  if ($get_plt_scol_err) {

    $self->logger->debug("Get static field info failed: $get_plt_scol_msg");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $impt_plt_ext_xml = read_file($impt_plt_ext_xml_file);
  my $plate_aref       = xml2arrayref($impt_plt_ext_xml, 'plate');

  my $cur_dt = DateTime->now( time_zone => $TIMEZONE );
  $cur_dt = DateTime::Format::MySQL->format_datetime($cur_dt);

  my $uniq_plate_name_href        = {};

  my $uniq_user_id_href           = {};
  my $uniq_plate_type_href        = {};
  my $uniq_storage_id_href        = {};

  my $uniq_itm_grp_id_geno_id_href     = {};
  my $uniq_itm_grp_id_href             = {};
  my $uniq_geno_id_href                = {};
  my $uniq_parent_extract_id_href      = {};

  my $user_id = $self->authen->user_id();

  my $all_extract_aref = [];

  foreach my $plate_rec (@{$plate_aref}) {

    my $uniq_well_href = {};

    my $PlateName       = $plate_rec->{'PlateName'};
    my $OperatorId      = $user_id;

    if (defined $plate_rec->{'OperatorId'}) {

      if (length($plate_rec->{'OperatorId'}) > 0) {

        $OperatorId = $plate_rec->{'OperatorId'};
      }
    }

    $uniq_user_id_href->{$OperatorId} = 1;

    my $PlateType        = undef;

    if ( defined($plate_rec->{'PlateType'}) ) {

      if (length($plate_rec->{'PlateType'}) > 0) {

        $PlateType = $plate_rec->{'PlateType'};
        $uniq_plate_type_href->{$PlateType} = 1;
      }
    }

    my $StorageId        = undef;

    if (defined($plate_rec->{'StorageId'})) {

      if (length($plate_rec->{'StorageId'}) > 0) {

        $StorageId = $plate_rec->{'StorageId'};
        $uniq_storage_id_href->{$StorageId} = 1;
      }
    }

    my $PlateWells       = undef;

    if (defined($plate_rec->{'PlateWells'})) {

      if (length($plate_rec->{'PlateWells'}) > 0) {

        $PlateWells = $plate_rec->{'PlateWells'};
      }
    }

    if (defined($plate_rec->{'DateCreated'})) {

      if (length($plate_rec->{'DateCreated'}) > 0) {

        my ($cdate_err, $cdate_href) = check_dt_href( {'DateCreated' => $plate_rec->{'DateCreated'}} );

        if ($cdate_err) {

          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [$cdate_href]};

          return $data_for_postrun_href;
        }
      }
    }

    if (length($PlateWells) > 0) {

      my ($int_err, $int_href) = check_integer_href( {'PlateWells' => $PlateWells} );

      if ($int_err) {

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [$int_href]};

        return $data_for_postrun_href;
      }
    }

    my $colsize_info          = {};
    my $chk_maxlen_field_href = {};

    for my $static_field (@{$plt_scol_data}) {

      my $field_name  = $static_field->{'Name'};
      my $field_dtype = $static_field->{'DataType'};

      if (lc($field_dtype) eq 'varchar') {

        $colsize_info->{$field_name}           = $static_field->{'ColSize'};
        $chk_maxlen_field_href->{$field_name}  = $plate_rec->{$field_name};
      }
    }

    my ($maxlen_err, $maxlen_msg) = check_maxlen($chk_maxlen_field_href, $colsize_info);

    if ($maxlen_err) {

      $maxlen_msg .= 'longer than its maximum length';

      $data_for_postrun_href->{'Error'}       = 1;
      $data_for_postrun_href->{'Data'}        = {'Error' => [{'Message' => $maxlen_msg}]};

      return $data_for_postrun_href;
    }

    $self->logger->debug("PlateName: $PlateName");

    if (defined $uniq_plate_name_href->{qq|'$PlateName'|}) {

      my $err_msg = "PlateName ($PlateName): duplicate";

      $data_for_postrun_href->{'Error'}       = 1;
      $data_for_postrun_href->{'Data'}        = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
    }
    else {

      $uniq_plate_name_href->{qq|'$PlateName'|} = 1;
    }

    my $extract_aref = $plate_rec->{'extract'};

    foreach my $extract_rec (@{$extract_aref}) {

      $extract_rec->{'PlateName'} = $PlateName;

      push(@{$all_extract_aref}, $extract_rec);

      my $colsize_info          = {};
      my $chk_maxlen_field_href = {};

      for my $static_field (@{$ext_scol_data}) {

        my $field_name  = $static_field->{'Name'};
        my $field_dtype = $static_field->{'DataType'};

        if (lc($field_dtype) eq 'varchar') {

          $colsize_info->{$field_name}           = $static_field->{'ColSize'};
          $chk_maxlen_field_href->{$field_name}  = $extract_rec->{$field_name};
        }
      }

      my ($maxlen_err, $maxlen_msg) = check_maxlen($chk_maxlen_field_href, $colsize_info);

      if ($maxlen_err) {

        $maxlen_msg .= 'longer than its maximum length';

        $data_for_postrun_href->{'Error'}       = 1;
        $data_for_postrun_href->{'Data'}        = {'Error' => [{'Message' => $maxlen_msg}]};

        return $data_for_postrun_href;
      }

      my $ItemGroupId = undef;

      if (defined($extract_rec->{'ItemGroupId'})) {

        if (length($extract_rec->{'ItemGroupId'}) > 0) {

          $ItemGroupId = $extract_rec->{'ItemGroupId'};
          $uniq_itm_grp_id_href->{$ItemGroupId} = 1;
        }
      }

      my $ParentExtractId = undef;

      if (defined($extract_rec->{'ParentExtractId'})) {

        if (length($extract_rec->{'ParentExtractId'}) > 0) {

          $ParentExtractId = $extract_rec->{'ParentExtractId'};
          $uniq_parent_extract_id_href->{$ParentExtractId} = 1;
        }
      }

      my $GenotypeId = undef;

      if (defined($extract_rec->{'GenotypeId'})) {

        if (length($extract_rec->{'GenotypeId'}) > 0) {

          $GenotypeId = $extract_rec->{'GenotypeId'};
          $uniq_geno_id_href->{$GenotypeId} = 1;
        }
      }

      my $Tissue = $extract_rec->{'Tissue'};

      my $WellRow = undef;

      if (defined($extract_rec->{'WellRow'})) {

        if (length($extract_rec->{'WellRow'}) > 0) {

          $WellRow = $extract_rec->{'WellRow'};
        }
      }

      my $WellCol = undef;

      if (defined($extract_rec->{'WellCol'})) {

        if (length($extract_rec->{'WellCol'}) > 0) {

          $WellCol = $extract_rec->{'WellCol'};
        }
      }

      if ( (defined $WellRow) && (defined $WellCol) ) {

        my $well = $WellRow . $WellCol;
        if (defined($uniq_well_href->{$well})) {

          my $err_msg = "PlateName ($PlateName) - Well ($well) has been used in more than one extract.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
        else {

          $uniq_well_href->{$well} = 1;
        }
      }

      if ( (!(defined $ItemGroupId)) && (!(defined $GenotypeId)) ) {

        my $err_msg = "GenotypeId and ItemGroupId: both missing.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
      elsif ( (defined $ItemGroupId) && (defined $GenotypeId) ) {

        $uniq_itm_grp_id_geno_id_href->{qq|($ItemGroupId,$GenotypeId)|} = 1;
      }
    }
  }

  my $group_id       = $self->authen->group_id();
  my $gadmin_status  = $self->authen->gadmin_status();

  my $sql = '';
  my $sth;

  my @user_id_list = keys(%{$uniq_user_id_href});

  $self->logger->debug("UserId list: " . join(',', @user_id_list));

  my ($user_id_exist_err, $user_id_exist_msg,
      $unfound_user_id_aref, $found_user_id_aref) = record_existence_bulk($dbh_k_read, 'systemuser', 'UserId', \@user_id_list);

  if ($user_id_exist_err) {

    $self->logger->debug("Check recorod existence bulk failed: $user_id_exist_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$unfound_user_id_aref}) > 0) {

    my $unfound_user_id_csv = join(',', @{$unfound_user_id_aref});

    my $err_msg = "UserId ($unfound_user_id_csv): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my @plate_name_list = keys(%{$uniq_plate_name_href});

  my ($plt_name_exist_err, $plt_name_exist_msg,
      $unfound_plt_name_aref, $found_plt_name_aref) = record_existence_bulk($dbh_m_read, 'plate', 'PlateName', \@plate_name_list);

  if ($plt_name_exist_err) {

    $self->logger->debug("Check recorod existence bulk failed: $plt_name_exist_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$found_plt_name_aref}) > 0) {

    my $found_plt_name_csv = join(',', @{$found_plt_name_aref});

    my $err_msg = "PlateName ($found_plt_name_csv): already exist.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my @plate_type_list = keys(%{$uniq_plate_type_href});

  my ($plt_type_exist_err, $plt_type_exist_msg,
      $unfound_plt_type_aref, $found_plt_type_aref) = record_existence_bulk($dbh_k_read, 'generaltype',
                                                                            'TypeId', \@plate_type_list, qq|Class='plate'|);

  if ($plt_type_exist_err) {

    $self->logger->debug("Check recorod existence bulk failed: $plt_type_exist_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$unfound_plt_type_aref}) > 0) {

    my $unfound_plt_type_csv = join(',', @{$unfound_plt_type_aref});

    my $err_msg = "PlateType ($unfound_plt_type_csv): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my @storage_id_list = keys(%{$uniq_storage_id_href});

  my ($storage_id_exist_err, $storage_id_exist_msg,
      $unfound_storage_id_aref, $found_storage_id_aref) = record_existence_bulk($dbh_k_read, 'storage',
                                                                                'StorageId', \@storage_id_list);

  if ($storage_id_exist_err) {

    $self->logger->debug("Check recorod existence bulk failed: $storage_id_exist_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$unfound_storage_id_aref}) > 0) {

    my $unfound_storage_id_csv = join(',', @{$unfound_storage_id_aref});

    my $err_msg = "StorageId ($unfound_storage_id_csv): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my @parent_ext_id_list = keys(%{$uniq_parent_extract_id_href});

  my ($parent_ext_id_exist_err, $parent_ext_id_exist_msg,
      $unfound_parent_ext_id_aref, $found_parent_ext_id_aref) = record_existence_bulk($dbh_m_read, 'storage',
                                                                                      'ExtractId', \@parent_ext_id_list);

  if ($parent_ext_id_exist_err) {

    $self->logger->debug("Check recorod existence bulk failed: $parent_ext_id_exist_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$unfound_parent_ext_id_aref}) > 0) {

    my $unfound_parent_ext_id_csv = join(',', @{$unfound_parent_ext_id_aref});

    my $err_msg = "ParentExtractId ($unfound_parent_ext_id_csv): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my @geno_id_list = keys(%{$uniq_geno_id_href});

  if (scalar(@geno_id_list) > 0) {

    my ($geno_id_exist_err, $geno_id_exist_msg,
        $unfound_geno_id_aref, $found_geno_id_aref) = record_existence_bulk($dbh_k_read, 'genotype', 'GenotypeId', \@geno_id_list);

    if ($geno_id_exist_err) {

      $self->logger->debug("Check recorod existence bulk failed: $geno_id_exist_msg");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

      return $data_for_postrun_href;
    }

    if (scalar(@{$unfound_geno_id_aref}) > 0) {

      my $unfound_geno_id_csv = join(',', @{$unfound_geno_id_aref});

      my $err_msg = "GenotypeId ($unfound_geno_id_csv): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my ($is_ok, $trouble_geno_id_aref) = check_permission($dbh_k_read, 'genotype', 'GenotypeId',
                                                          \@geno_id_list, $group_id, $gadmin_status,
                                                          $LINK_PERM);
    if (!$is_ok) {

      my $perm_denied_geno_id_csv = join(',', @{$trouble_geno_id_aref});

      my $err_msg = "GenotypeId ($perm_denied_geno_id_csv): permission denied.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @itm_grp_id_list = keys(%{$uniq_itm_grp_id_href});

  if (scalar(@itm_grp_id_list) > 0) {

    my ($itm_grp_id_exist_err, $itm_grp_id_exist_msg,
        $unfound_itm_grp_id_aref, $found_itm_grp_id_aref) = record_existence_bulk($dbh_k_read, 'itemgroup', 'ItemGroupId', \@itm_grp_id_list);

    if ($itm_grp_id_exist_err) {

      $self->logger->debug("Check recorod existence bulk failed: $itm_grp_id_exist_msg");
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

      return $data_for_postrun_href;
    }

    if (scalar(@{$unfound_itm_grp_id_aref}) > 0) {

      my $unfound_itm_grp_id_csv = join(',', @{$unfound_itm_grp_id_aref});

      my $err_msg = "ItemGroupId ($unfound_itm_grp_id_csv): not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $itm_grp_id_csv = join(',', @itm_grp_id_list);

    my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'genotype');

    $sql    = "SELECT itemgroupentry.ItemGroupId, genotypespecimen.GenotypeId ";
    $sql   .= "FROM itemgroupentry LEFT JOIN item ON itemgroupentry.ItemId = item.ItemId ";
    $sql   .= "LEFT JOIN genotypespecimen ON item.SpecimenId = genotypespecimen.SpecimenId ";
    $sql   .= "LEFT JOIN genotype ON genotypespecimen.GenotypeId = genotype.GenotypeId ";
    $sql   .= "WHERE itemgroupentry.ItemGroupId IN ($itm_grp_id_csv) AND ";
    $sql   .= "(($perm_str) & $READ_PERM) = $READ_PERM";

    $sth = $dbh_k_read->prepare($sql);
    $sth->execute();

    my $db_perm_itm_grp_id2geno_id_href = $sth->fetchall_hashref('ItemGroupId');

    if ($dbh_k_read->err()) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

      return $data_for_postrun_href;
    }

    $sth->finish();

    my @perm_denied_itm_grp_id_list;
    my @conflict_itm_grp_id_list;

    foreach my $itm_grp_id (@itm_grp_id_list) {

      if ( !(defined $db_perm_itm_grp_id2geno_id_href->{$itm_grp_id}) ) {

        push(@perm_denied_itm_grp_id_list, $itm_grp_id);
      }
      else {

        my $geno_id = $db_perm_itm_grp_id2geno_id_href->{$itm_grp_id}->{'GenotypeId'};

        if ( !(defined $uniq_itm_grp_id_geno_id_href->{qq|(${itm_grp_id},${geno_id})|}) ) {

          push(@conflict_itm_grp_id_list, $itm_grp_id);
        }
      }
    }

    if (scalar(@perm_denied_itm_grp_id_list) > 0) {

      my $perm_denied_itm_grp_id_csv = join(',', @perm_denied_itm_grp_id_list);

      my $err_msg = "ItemGroupId ($perm_denied_itm_grp_id_csv): permission denied.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if (scalar(@conflict_itm_grp_id_list) > 0) {

      my $conflict_itm_grp_id_csv = join(',', @conflict_itm_grp_id_list);

      my $err_msg = "ItemGroupId ($conflict_itm_grp_id_csv): conflicted genotype.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  $dbh_k_read->disconnect();
  $dbh_m_read->disconnect();

  my $dbh_m_write = connect_mdb_write();

  my @plate_sql_list;

  foreach my $plate_rec (@{$plate_aref}) {

    my $PlateName       = $plate_rec->{'PlateName'};
    my $OperatorId      = $user_id;

    if (defined $plate_rec->{'OperatorId'}) {

      if (length($plate_rec->{'OperatorId'}) > 0) {

        $OperatorId = $plate_rec->{'OperatorId'};
      }
    }

    my $PlateType       = 'NULL';

    if ( defined($plate_rec->{'PlateType'}) ) {

      if (length($plate_rec->{'PlateType'}) > 0) {

        $PlateType = $plate_rec->{'PlateType'};
      }
    }

    my $StorageId        = 'NULL';

    if (defined($plate_rec->{'StorageId'})) {

      if (length($plate_rec->{'StorageId'}) > 0) {

        $StorageId = $plate_rec->{'StorageId'};
      }
    }

    my $PlateWells       = 'NULL';

    if (defined($plate_rec->{'PlateWells'})) {

      if (length($plate_rec->{'PlateWells'}) > 0) {

        $PlateWells = $plate_rec->{'PlateWells'};
      }
    }

    my $DateCreated = $cur_dt;

    if (defined($plate_rec->{'DateCreated'})) {

      if (length($plate_rec->{'DateCreated'}) > 0) {

        $DateCreated = $plate_rec->{'DateCreated'};
      }
    }

    my $PlateDesc = 'NULL';

    if (defined($plate_rec->{'PlateDescription'})) {

      if (length($plate_rec->{'PlateDescription'}) > 0) {

        $PlateDesc = $dbh_m_write->quote($plate_rec->{'PlateDescription'});
      }
    }

    my $PlateStatus = 'NULL';

    if (defined($plate_rec->{'PlateStatus'})) {

      if (length($plate_rec->{'PlateStatus'}) > 0) {

        $PlateStatus = $dbh_m_write->quote($plate_rec->{'PlateStatus'});
      }
    }

    my ($next_val_err, $next_val_msg, $plt_id) = get_next_value_for($dbh_m_write, 'plate', 'PlateId');

    if ($next_val_err) {

      $self->logger->debug($next_val_msg);

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    $uniq_plate_name_href->{qq|'$PlateName'|} = $plt_id;

    my $plate_row_sql = qq|($plt_id,'$PlateName','$DateCreated',$OperatorId,$PlateType,$PlateDesc,$StorageId,$PlateWells,$PlateStatus)|;
    push(@plate_sql_list, $plate_row_sql);
  }

  $sql  = qq|INSERT INTO "plate" |;
  $sql .= qq|("PlateId","PlateName","DateCreated","OperatorId","PlateType","PlateDescription","StorageId","PlateWells","PlateStatus") |;
  $sql .= qq|VALUES | . join(',', @plate_sql_list);

  $self->logger->debug("SQL: $sql");

  my ($imp_plt_err, $imp_plt_msg) = execute_sql($dbh_m_write, $sql, []);

  if ($imp_plt_err) {

    $self->logger->debug("Import plate failed: $imp_plt_msg");
    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $return_id_aref = [];

  my @extract_sql_list;

  foreach my $extract_rec (@{$all_extract_aref}) {

    my $plt_name = $extract_rec->{'PlateName'};
    my $plt_id   = $uniq_plate_name_href->{qq|'$plt_name'|};

    my $ItemGroupId = 'NULL';

    if (defined($extract_rec->{'ItemGroupId'})) {

      if (length($extract_rec->{'ItemGroupId'}) > 0) {

        $ItemGroupId = $extract_rec->{'ItemGroupId'};
      }
    }

    my $ParentExtractId = 'NULL';

    if (defined($extract_rec->{'ParentExtractId'})) {

      if (length($extract_rec->{'ParentExtractId'}) > 0) {

        $ParentExtractId = $extract_rec->{'ParentExtractId'};
      }
    }

    my $GenotypeId = 'NULL';

    if (defined($extract_rec->{'GenotypeId'})) {

      if (length($extract_rec->{'GenotypeId'}) > 0) {

        $GenotypeId = $extract_rec->{'GenotypeId'};
      }
    }

    my $Tissue    = $extract_rec->{'Tissue'};
    my $WellRow   = $extract_rec->{'WellRow'};
    my $WellCol   = $extract_rec->{'WellCol'};

    my $Quality   = 'NULL';

    if (defined($extract_rec->{'Quality'})) {

      if (length($extract_rec->{'Quality'}) > 0) {

        $Quality = $dbh_m_write->quote($extract_rec->{'Quality'});
      }
    }

    my $Status = 'NULL';

    if (defined($extract_rec->{'Status'})) {

      if (length($extract_rec->{'Status'}) > 0) {

        $Status = $dbh_m_write->quote($extract_rec->{'Status'});
      }
    }

    my ($next_val_err, $next_val_msg, $ext_id) = get_next_value_for($dbh_m_write, 'extract', 'ExtractId');

    if ($next_val_err) {

      $self->logger->debug($next_val_msg);

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    my $returned_extract_rec = {'ExtractId' => $ext_id,
                                'PlateName' => $plt_name,
                                'PlateId'   => $plt_id,
                                'WellRow'   => $WellRow,
                                'WellCol'   => $WellCol
                                };

    my $ext_sql_row = qq|($ext_id,$ParentExtractId,$plt_id,$ItemGroupId,$GenotypeId,$Tissue,'$WellRow','$WellCol',$Quality,$Status)|;

    push(@{$return_id_aref}, $returned_extract_rec);
    push(@extract_sql_list, $ext_sql_row);
  }

  $sql  = qq|INSERT INTO "extract" |;
  $sql .= qq|("ExtractId","ParentExtractId","PlateId","ItemGroupId","GenotypeId","Tissue","WellRow","WellCol","Quality","Status") |;
  $sql .= qq|VALUES | . join(',', @extract_sql_list);

  $self->logger->debug("SQL: $sql");

  my ($imp_ext_err, $imp_ext_msg) = execute_sql($dbh_m_write, $sql, []);

  if ($imp_ext_err) {

    $self->logger->debug("Import extract failed: $imp_ext_msg");
    my $err_msg = "Unexpected Error.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_m_write->disconnect();

  my $nb_plate    = scalar(@{$plate_aref});
  my $nb_extract  = scalar(@{$all_extract_aref});

  my $return_id_data = {};
  $return_id_data->{'ReturnId'}     = $return_id_aref;
  $return_id_data->{'AlternateKey'} = [{'FieldName' => 'PlateId'}, {'FieldName' => 'WellRow'}, {'FieldName' => 'WellCol'}];

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

  my $info_msg = "$nb_plate plates and $nb_extract extracts have been inserted successfully.";

  my $info_msg_aref = [{'Message' => $info_msg}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref, 'ReturnIdFile' => [$output_file_href]};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub get_extract_dtd_file {

  my $dtd_path = $ENV{DOCUMENT_ROOT} . '/' . $DTD_PATH;

  return "${dtd_path}/extract.dtd";
}

sub get_extract_all_field_dtd_file {

  my $dtd_path = $ENV{DOCUMENT_ROOT} . '/' . $DTD_PATH;

  return "${dtd_path}/extract_all_field.dtd";
}

sub get_analysisgroup_dtd_file {

  my $dtd_path = $ENV{DOCUMENT_ROOT} . '/' . $DTD_PATH;

  return "${dtd_path}/analysisgroup.dtd";
}

sub get_import_plate_n_extract_dtd_file {

  my $dtd_path = $ENV{DOCUMENT_ROOT} . '/' . $DTD_PATH;

  return "${dtd_path}/import_plate_n_extract.dtd";
}

sub _set_error {

  my ( $self, $error_message ) = @_;
  return {
    'Error' => 1,
    'Data'  => { 'Error' => [ { 'Message' => $error_message || 'Unexpected error.' } ] }
  };
}

1;
