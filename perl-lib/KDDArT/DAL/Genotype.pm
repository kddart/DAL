#$Id$
#$Author$

# Copyright (c) 2011, Diversity Arrays Technology, All rights reserved.

# Author    : Puthick Hok
# Created   : 02/06/2010
# Modified  :
# Purpose   :
#
#

package KDDArT::DAL::Genotype;

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
use Digest::MD5 qw(md5 md5_hex md5_base64);
use File::Lockfile;
use Crypt::Random qw( makerandom );
use Data::Dumper;

sub setup {

  my $self = shift;

  CGI::Session->name("KDDArT_DAL_SESSID");

  __PACKAGE__->authen->init_config_parameters();
  __PACKAGE__->authen->check_login_runmodes(':all');
  __PACKAGE__->authen->check_content_type_runmodes(':all');
  __PACKAGE__->authen->check_rand_runmodes('add_genotype',
                                           'add_genus_gadmin',
                                           'add_specimen',
                                           'add_taxonomy',
                                           'update_genotype',
                                           'update_specimen',
                                           'update_taxonomy',
                                           'add_genotype_to_specimen',
                                           'remove_genotype_from_specimen_gadmin',
                                           'add_genotype_alias',
                                           'update_genotype_alias',
                                           'delete_genotype_alias',
                                           'update_genus_gadmin',
                                           'add_trait2genotype',
                                           'update_genotype_trait',
                                           'add_specimen_group',
                                           'update_specimen_group_gadmin',
                                           'remove_specimen_from_specimen_group_gadmin',
                                           'remove_specimen_from_specimen_group_bulk_gadmin',
                                           'add_specimen2specimen_group_gadmin',
                                           'del_genus_gadmin',
                                           'del_specimen_gadmin',
                                           'del_specimen_group_gadmin',
                                           'del_genotype_gadmin',
                                           'del_taxonomy_gadmin',
                                           'import_genotype_csv',
                                           'import_specimen_csv',
                                           'add_breedingmethod_gadmin',
                                           'update_breedingmethod_gadmin',
                                           'del_breedingmethod_gadmin',
                                           'import_pedigree_csv',
                                           'update_pedigree_gadmin',
                                           'del_pedigree_gadmin',
                                           'add_pedigree',
                                           'remove_genotype_trait',
                                           'add_genpedigree',
                                           'add_keyword_to_specimen',
                                           'remove_specimen_keyword',
                                           'import_genpedigree_csv',
                                           'update_genpedigree_gadmin',
                                           'del_genpedigree_gadmin',
                                           'update_specimen_geography',
                                          );

  __PACKAGE__->authen->count_session_request_runmodes(':all');
  __PACKAGE__->authen->check_signature_runmodes('add_genotype',
                                                'add_genus_gadmin',
                                                'add_taxonomy',
                                                'update_genotype',
                                                'update_specimen',
                                                'update_taxonomy',
                                                'add_genotype_to_specimen',
                                                'remove_genotype_from_specimen_gadmin',
                                                'add_genotype_alias',
                                                'update_genotype_alias',
                                                'delete_genotype_alias',
                                                'update_genus_gadmin',
                                                'add_trait2genotype',
                                                'update_genotype_trait',
                                                'update_specimen_group_gadmin',
                                                'remove_specimen_from_specimen_group_gadmin',
                                                'del_genus_gadmin',
                                                'del_specimen_gadmin',
                                                'del_specimen_group_gadmin',
                                                'del_genotype_gadmin',
                                                'del_taxonomy_gadmin',
                                                'add_breedingmethod_gadmin',
                                                'update_breedingmethod_gadmin',
                                                'del_breedingmethod_gadmin',
                                                'update_pedigree_gadmin',
                                                'del_pedigree_gadmin',
                                                'add_pedigree',
                                                'remove_genotype_trait',
                                                'add_genpedigree',
                                                'add_keyword_to_specimen',
                                                'remove_specimen_keyword',
                                                'update_genpedigree_gadmin',
                                                'del_genpedigree_gadmin',
                                                'update_specimen_geography',
                                               );

  __PACKAGE__->authen->check_gadmin_runmodes('add_genus_gadmin',
                                             'remove_genotype_from_specimen_gadmin',
                                             'update_genus_gadmin',
                                             'update_specimen_group_gadmin',
                                             'remove_specimen_from_specimen_group_gadmin',
                                             'remove_specimen_from_specimen_group_bulk_gadmin',
                                             'add_specimen2specimen_group_gadmin',
                                             'del_genus_gadmin',
                                             'del_specimen_gadmin',
                                             'del_specimen_group_gadmin',
                                             'del_genotype_gadmin',
                                             'del_taxonomy_gadmin',
                                             'add_breedingmethod_gadmin',
                                             'update_breedingmethod_gadmin',
                                             'del_breedingmethod_gadmin',
                                             'update_pedigree_gadmin',
                                             'del_pedigree_gadmin',
                                             'update_genpedigree_gadmin',
                                             'del_genpedigree_gadmin',
                                             'update_specimen_geography',
                                            );

  __PACKAGE__->authen->check_sign_upload_runmodes('add_specimen',
                                                  'add_specimen_group',
                                                  'remove_specimen_from_specimen_group_bulk_gadmin',
                                                  'add_specimen2specimen_group_gadmin',
                                                  'import_genotype_csv',
                                                  'import_specimen_csv',
                                                  'import_pedigree_csv',
                                                  'import_genpedigree_csv',
                                                 );

  __PACKAGE__->authen->check_genotype_config_runmodes('add_genotype',
                                                      'import_genotype_csv',
                                                     );

  $self->run_modes(
    'add_genotype'                              => 'add_genotype_runmode',
    'add_genus_gadmin'                          => 'add_genus_runmode',
    'list_genus'                                => 'list_genus_runmode',
    'get_genotype'                              => 'get_genotype_runmode',
    'add_specimen'                              => 'add_specimen_runmode',
    'list_specimen_advanced'                    => 'list_specimen_advanced_runmode',
    'update_genotype'                           => 'update_genotype_runmode',
    'update_specimen'                           => 'update_specimen_runmode',
    'add_genotype_to_specimen'                  => 'add_genotype_to_specimen_runmode',
    'remove_genotype_from_specimen_gadmin'      => 'remove_genotype_from_specimen_runmode',
    'get_specimen'                              => 'get_specimen_runmode',
    'add_genotype_alias'                        => 'add_genotype_alias_runmode',
    'update_genotype_alias'                     => 'update_genotype_alias_runmode',
    'delete_genotype_alias'                     => 'delete_genotype_alias_runmode',
    'list_genotype_alias_advanced'              => 'list_genotype_alias_advanced_runmode',
    'get_genotype_alias'                        => 'get_genotype_alias_runmode',
    'update_genus_gadmin'                       => 'update_genus_runmode',
    'get_genus'                                 => 'get_genus_runmode',
    'add_trait2genotype'                        => 'add_trait2genotype_runmode',
    'update_genotype_trait'                     => 'update_genotype_trait_runmode',
    'list_genotype_trait'                       => 'list_genotype_trait_runmode',
    'get_genotype_trait'                        => 'get_genotype_trait_runmode',
    'add_specimen_group'                        => 'add_specimen_group_runmode',
    'list_specimen_group_advanced'              => 'list_specimen_group_advanced_runmode',
    'get_specimen_group'                        => 'get_specimen_group_runmode',
    'update_specimen_group_gadmin'              => 'update_specimen_group_runmode',
    'remove_specimen_from_specimen_group_gadmin'      => 'remove_specimen_from_specimen_group_runmode',
    'remove_specimen_from_specimen_group_bulk_gadmin' => 'remove_specimen_from_specimen_group_bulk_runmode',
    'add_specimen2specimen_group_gadmin'              => 'add_specimen2specimen_group_runmode',
    'list_genotype_advanced'                          => 'list_genotype_advanced_runmode',
    'del_genus_gadmin'                                => 'del_genus_runmode',
    'del_specimen_gadmin'                             => 'del_specimen_runmode',
    'del_specimen_group_gadmin'                       => 'del_specimen_group_runmode',
    'del_genotype_gadmin'                             => 'del_genotype_runmode',
    'list_genotype_in_specimen'                       => 'list_genotype_in_specimen_runmode',
    'import_genotype_csv'                             => 'import_genotype_csv_runmode',
    'export_genotype'                                 => 'export_genotype_runmode',
    'import_specimen_csv'                       => 'import_specimen_csv_runmode',
    'add_breedingmethod_gadmin'                 => 'add_breedingmethod_runmode',
    'list_breedingmethod'                       => 'list_breedingmethod_runmode',
    'update_breedingmethod_gadmin'              => 'update_breedingmethod_runmode',
    'get_breedingmethod'                        => 'get_breedingmethod_runmode',
    'del_breedingmethod_gadmin'                 => 'del_breedingmethod_runmode',
    'import_pedigree_csv'                       => 'import_pedigree_csv_runmode',
    'export_specimen'                           => 'export_specimen_runmode',
    'export_pedigree'                           => 'export_pedigree_runmode',
    'update_pedigree_gadmin'                    => 'update_pedigree_runmode',
    'del_pedigree_gadmin'                       => 'del_pedigree_runmode',
    'add_pedigree'                              => 'add_pedigree_runmode',
    'remove_genotype_trait'                     => 'remove_genotype_trait_runmode',
    'add_genpedigree'                           => 'add_genpedigree_runmode',
    'list_gen_ancestor'                         => 'list_gen_ancestor_runmode',
    'list_gen_descendant'                       => 'list_gen_descendant_runmode',
    'list_spec_ancestor'                        => 'list_spec_ancestor_runmode',
    'list_spec_descendant'                      => 'list_spec_descendant_runmode',
    'list_pedigree_advanced'                    => 'list_pedigree_advanced_runmode',
    'list_gen_pedigree_advanced'                => 'list_gen_pedigree_advanced_runmode',
    'add_keyword_to_specimen'                   => 'add_keyword_to_specimen_runmode',
    'list_specimen_keyword_advanced'            => 'list_specimen_keyword_advanced_runmode',
    'remove_specimen_keyword'                   => 'remove_specimen_keyword_runmode',
    'import_genpedigree_csv'                    => 'import_genpedigree_csv_runmode',
    'export_genpedigree'                        => 'export_genpedigree_runmode',
    'update_genpedigree_gadmin'                 => 'update_genpedigree_runmode',
    'del_genpedigree_gadmin'                    => 'del_genpedigree_runmode',
    'add_taxonomy'                              => 'add_taxonomy_runmode',
    'get_taxonomy'                              => 'get_taxonomy_runmode',
    'list_taxonomy'                             => 'list_taxonomy_runmode',
    'update_taxonomy'                           => 'update_taxonomy_runmode',
    'del_taxonomy_gadmin'                       => 'del_taxonomy_gadmin_runmode',
    'update_specimen_geography'                 => 'update_specimen_geography_runmode',
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

sub add_genotype_runmode {

=pod add_genotype_HELP_START
{
"OperationName": "Add Genotype",
"Description": "Add a new genotype record into the system",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "genotype",
"SkippedField": ["OwnGroupId"],
"KDDArTFactorTable": "genotypefactor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='1' ParaName='GenotypeId' /><Info Message='Genotype (1) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{ 'ReturnId' : [{ 'Value' : '1', 'ParaName' : 'GenotypeId' }], 'Info' : [{ 'Message' : 'Genotype (1) has been added successfully.' }]}",
"ErrorMessageXML": [{"NameAlreadyExists": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error GenotypeName='GenotypeName (kardinal): already exists.' /></DATA>", "MissingParameter": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error GenotypeName='GenotypeName is missing.' /></DATA>" }],
"ErrorMessageJSON": [{"NameAlreadyExists": "{'Error' : [ {'GenotypeName' : 'GenotypeName (kardinal): already exists.'} ] }", "MissingParameter": "{ 'Error' : [ { 'GenotypeName' : 'GenotypeName is missing.' } ] }" }],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'OwnGroupId' => 1};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'genotype', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $genotype_name       = $query->param('GenotypeName');
  my $genus_id            = $query->param('GenusId');

  my $origin_id           = $query->param('OriginId');
  my $can_publish         = $query->param('CanPublishGenotype');

  my $access_group        = $query->param('AccessGroupId');
  my $own_perm            = $query->param('OwnGroupPerm');
  my $access_perm         = $query->param('AccessGroupPerm');
  my $other_perm          = $query->param('OtherPerm');

  my $species_name        = '';

  if (defined $query->param('SpeciesName')) {

    $species_name = $query->param('SpeciesName');
  }

  my $acronym             = '';

  if (defined $query->param('GenotypeAcronym')) {

    $acronym = $query->param('GenotypeAcronym');
  }

  my $note                = '';

  if (defined $query->param('GenotypeNote')) {

    $note = $query->param('GenotypeNote');
  }

  my $genotype_color      = '';

  if (defined $query->param('GenotypeColor')) {

    $genotype_color = $query->param('GenotypeColor');
  }

  my ($int_err, $int_err_href) = check_integer_href( {'OriginId'           => $origin_id,
                                                      'CanPublishGenotype' => $can_publish,
                                                     });

  if ($int_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$int_err_href]};

    return $data_for_postrun_href;
  }

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='genotypefactor'";

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

  my $taxonomy_id = undef;

  if (defined $query->param('TaxonomyId')) {

    $taxonomy_id = $query->param('TaxonomyId');

    my $taxonomy_existence = record_existence($dbh_k_read, 'taxonomy', 'TaxonomyId', $taxonomy_id);

    if (!$taxonomy_existence) {

      my $err_msg = "TaxonomyId ($taxonomy_id) does not exist.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'TaxonomyId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $genus_existence = record_existence($dbh_k_read, 'genus', 'GenusId', $genus_id);

  if (!$genus_existence) {

    my $err_msg = "Genus ($genus_id) does not exist.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'GenusId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $geno_lookup_sql = 'SELECT GenotypeId FROM genotype WHERE GenotypeName=? AND GenusId=?';

  my ($lookp_err, $lookup_geno_id) = read_cell($dbh_k_read, $geno_lookup_sql, [$genotype_name, $genus_id]);

  if (length($lookup_geno_id) > 0) {

    my $err_msg = "GenotypeName ($genotype_name): already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'GenotypeName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $geno_lookup_sql = 'SELECT GenotypeId FROM genotypealias WHERE GenotypeAliasName=? AND GenusId=?';

  ($lookp_err, $lookup_geno_id) = read_cell($dbh_k_read, $geno_lookup_sql, [$genotype_name, $genus_id]);

  if (length($lookup_geno_id) > 0) {

    my $err_msg = "$genotype_name is already used as a Genotype Alias.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'GenotypeName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $access_grp_existence = record_existence($dbh_k_read, 'systemgroup', 'SystemGroupId', $access_group);

  if (!$access_grp_existence) {

    my $err_msg = "AccessGroup ($access_group) does not exist.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'AccessGroupId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( ($own_perm > 7 || $own_perm < 0) ) {

    my $err_msg = "OwnGroupPerm ($own_perm) is invalid.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'OwnGroupPerm' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( ($access_perm > 7 || $access_perm < 0) ) {

    my $err_msg = "AccessGroupPerm ($access_perm) is invalid.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'AccessGroupPerm' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( ($other_perm > 7 || $other_perm < 0) ) {

    my $err_msg = "OtherPerm ($other_perm) is invalid.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'OtherPerm' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $group_id = $self->authen->group_id();

  $sql    = 'INSERT INTO genotype SET ';
  $sql   .= 'TaxonomyId=?, ';
  $sql   .= 'GenotypeName=?, ';
  $sql   .= 'GenusId=?, ';
  $sql   .= 'SpeciesName=?, ';
  $sql   .= 'GenotypeAcronym=?, ';
  $sql   .= 'OriginId=?, ';
  $sql   .= 'CanPublishGenotype=?, ';
  $sql   .= 'GenotypeNote=?, ';
  $sql   .= 'GenotypeColor=?, ';
  $sql   .= 'OwnGroupId=?, ';
  $sql   .= 'AccessGroupId=?, ';
  $sql   .= 'OwnGroupPerm=?, ';
  $sql   .= 'AccessGroupPerm=?, ';
  $sql   .= 'OtherPerm=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($taxonomy_id, $genotype_name, $genus_id, $species_name, $acronym,
                $origin_id, $can_publish, $note, $genotype_color,
                $group_id, $access_group, $own_perm, $access_perm, $other_perm);

  my $genotype_id = -1;
  if (!$dbh_k_write->err()) {

    $genotype_id = $dbh_k_write->last_insert_id(undef, undef, 'genotype', 'GenotypeId');
    $self->logger->debug("GenotypeId: $genotype_id");
  }
  else {

    $self->logger->debug("SQL INSERT failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  for my $vcol_id (keys(%{$vcol_data})) {

    my $factor_value = $query->param('VCol_' . "$vcol_id");

    if (length($factor_value) > 0) {

      $sql  = 'INSERT INTO genotypefactor SET ';
      $sql .= 'GenotypeId=?, ';
      $sql .= 'FactorId=?, ';
      $sql .= 'FactorValue=?';
      my $factor_sth = $dbh_k_write->prepare($sql);
      $factor_sth->execute($genotype_id, $vcol_id, $factor_value);

      if ($dbh_k_write->err()) {

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

        return $data_for_postrun_href;
      }

      $factor_sth->finish();
    }
  }
  $dbh_k_write->disconnect();

  my $info_msg_aref  = [{'Message' => "Genotype ($genotype_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$genotype_id", 'ParaName' => 'GenotypeId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref,
                                           'ReturnId'  => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub add_genus_runmode {

=pod add_genus_gadmin_HELP_START
{
"OperationName": "Add Genus",
"Description": "This interface can be used to add a genus to KDDart",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "genus",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='1' ParaName='GenusId' /><Info Message='Genus (1) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{ 'ReturnId' : [{ 'Value' : '7', 'ParaName' : 'GenusId' }], 'Info' : [{ 'Message' : 'Genus (1) has been added successfully.' }]}",
"ErrorMessageXML": [{"NameAlreadyExists": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error GenusName='GenusName (rose): already exists.' /></DATA>", "MissingParameter": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error GenusName='GenusName is missing.' /></DATA>"}],
"ErrorMessageJSON": [{"NameAlreadyExists": "{'Error' : [ {'GenusName' : 'GenusName (rose): already exists.'} ] }", "MissingParameter": "{ 'Error' : [ { 'GenusName' : 'GenusName is missing.' } ] }"}],
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
                                                                                'genus', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $genus_name = $query->param('GenusName');

  my $dbh_k_write = connect_kdb_write();

  if (record_existence($dbh_k_write, 'genus', 'GenusName', $genus_name)) {

    my $err_msg = "GenusName ($genus_name): already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'GenusName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql  = 'INSERT INTO genus SET ';
  $sql    .= 'GenusName=?';

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute($genus_name);

  my $genus_id = -1;
  if (!$dbh_k_write->err()) {

    $genus_id = $dbh_k_write->last_insert_id(undef, undef, 'genus', 'GenusId');
    $self->logger->debug("GenusId: $genus_id");
  }
  else {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();
  $dbh_k_write->disconnect();

  my $info_msg_aref  = [{'Message' => "Genus ($genus_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$genus_id", 'ParaName' => 'GenusId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref,
                                           'ReturnId'  => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_genus {

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

  my $sql = 'SELECT * FROM genus ';
  $sql   .= $where_clause;
  $sql   .= ' ORDER BY GenusId DESC';

  my $sth = $dbh->prepare($sql);
  # parameters provided by the caller
  # for example, ('WHERE FieldA=?', '1')
  $sth->execute(@_);

  my $err = 0;
  my $msg = '';
  my $genus_data = [];

  if ( !$dbh->err() ) {

    my $array_ref = $sth->fetchall_arrayref({});

    if ( !$sth->err() ) {

      $genus_data = $array_ref;
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

  my $extra_attr_genus_data = [];

  if ($extra_attr_yes && ($gadmin_status eq '1')) {

    my $genus_id_aref = [];

    for my $row (@{$genus_data}) {

      push(@{$genus_id_aref}, $row->{'GenusId'});
    }

    my $chk_table_aref = [{'TableName' => 'genus', 'FieldName' => 'GenusId'}];

    my ($chk_id_err, $chk_id_msg,
        $used_id_href, $not_used_id_href) = id_existence_bulk($dbh, $chk_table_aref, $genus_id_aref);

    if ($chk_id_err) {

      $self->logger->debug("Check id existence error: $chk_id_msg");
      $err = 1;
      $msg = $chk_id_msg;

      return ($err, $msg, []);
    }

    for my $row (@{$genus_data}) {

      my $genus_id = $row->{'GenusId'};
      $row->{'update'}   = "update/genus/$genus_id";

      if ($not_used_id_href->{$genus_id}) {

        $row->{'delete'}   = "delete/genus/$genus_id";
      }

      push(@{$extra_attr_genus_data}, $row);
    }
  }
  else {

    $extra_attr_genus_data = $genus_data;
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_genus_data);
}

sub list_genotype {

  my $self            = $_[0];
  my $extra_attr_yes  = $_[1];
  my $sql             = $_[2];
  my $where_para_aref = $_[3];

  my $err = 0;
  my $msg = '';

  my $data_aref = [];

  my $dbh = connect_kdb_read();

  $self->logger->debug("GENO_SQL: $sql");

  ($err, $msg, $data_aref) = read_data($dbh, $sql, $where_para_aref);

  if ($err) {

    return ($err, "$msg", []);
  }

  $self->logger->debug("Number of records: " . scalar(@{$data_aref}));

  my $gadmin_status = $self->authen->gadmin_status();

  my $extra_attr_geno_data = [];

  if ($extra_attr_yes) {

    my $group_id_href = {};
    my $geno_id_aref  = [];
    my $genus_id_href = {};

    my $genus_lookup      = {};
    my $group_lookup      = {};
    my $geno_alias_lookup = {};

    my $chk_id_err        = 0;
    my $chk_id_msg        = '';
    my $used_id_href      = {};
    my $not_used_id_href  = {};

    for my $row (@{$data_aref}) {

      my $genotype_id = $row->{'GenotypeId'};

      push(@{$geno_id_aref}, $row->{'GenotypeId'});

      if (defined $row->{'GenusId'}) {

        $genus_id_href->{$row->{'GenusId'}} = 1;
      }

      if (defined $row->{'OwnGroupId'}) {

        $group_id_href->{$row->{'OwnGroupId'}} = 1;
      }

      if (defined $row->{'AccessGroupId'}) {

        $group_id_href->{$row->{'AccessGroupId'}} = 1;
      }
    }

    if (scalar(keys(%{$genus_id_href})) > 0) {

      my $genus_sql    = 'SELECT * FROM genus WHERE GenusId IN (' . join(',', keys(%{$genus_id_href})) . ')';

      $self->logger->debug("GENUS_SQL: $genus_sql");
      $genus_lookup = $dbh->selectall_hashref($genus_sql, 'GenusId');
    }

    if (scalar(keys(%{$group_id_href})) > 0) {

      my $group_sql    = 'SELECT SystemGroupId, SystemGroupName FROM systemgroup ';
      $group_sql      .= 'WHERE SystemGroupId IN (' . join(',', keys(%{$group_id_href})) . ')';

      $self->logger->debug("GROUP_SQL: $group_sql");
      $group_lookup = $dbh->selectall_hashref($group_sql, 'SystemGroupId');
    }

    if (scalar(@{$geno_id_aref}) > 0) {

      #include genotype alias as part of genotype response
      my $geno_alias_sql = 'SELECT genotypealias.GenotypeId, genotypealias.GenotypeAliasId, genotypealias.GenotypeAliasName, generaltype.TypeName, genotypealias.GenotypeAliasType, ';
      $geno_alias_sql   .= 'genotypealias.GenotypeAliasStatus, genotypealias.GenotypeAliasLang ';
      $geno_alias_sql   .= 'FROM genotypealias ';
      $geno_alias_sql   .= 'LEFT JOIN generaltype on genotypealias.GenotypeAliasType = generaltype.TypeId  ';
      $geno_alias_sql   .= 'WHERE GenotypeId IN (' . join(',', @{$geno_id_aref}) . ')';

      $self->logger->debug("GENO_ALIAS_SQL: $geno_alias_sql");

      my ($geno_alias_err, $geno_alias_msg, $geno_alias_data) = read_data($dbh, $geno_alias_sql, []);

      if ($geno_alias_err) {

        return ($geno_alias_err, "$geno_alias_msg", []);
      }

      for my $row (@{$geno_alias_data}) {

        my $geno_id = $row->{'GenotypeId'};

        if (defined $geno_alias_lookup->{$geno_id}) {

          my $alias_aref = $geno_alias_lookup->{$geno_id};
          delete($row->{'GenotypeId'});
          push(@{$alias_aref}, $row);
          $geno_alias_lookup->{$geno_id} = $alias_aref;
        }
        else {

          delete($row->{'GenotypeId'});
          $geno_alias_lookup->{$geno_id} = [$row];
        }
      }

      my $chk_table_aref = [{'TableName' => 'genotype', 'FieldName' => 'GenotypeId'}];

      ($chk_id_err, $chk_id_msg,
       $used_id_href, $not_used_id_href) = id_existence_bulk($dbh, $chk_table_aref, $geno_id_aref);

      if ($chk_id_err) {

        $self->logger->debug("Check id existence error: $chk_id_msg");
        $err = 1;
        $msg = $chk_id_msg;

        return ($err, $msg, []);
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

    my $group_id      = $self->authen->group_id();

    for my $row (@{$data_aref}) {

      my $geno_id      = $row->{'GenotypeId'};

      if (defined $geno_alias_lookup->{$geno_id}) {

        my $geno_alias_aref = [];
        my $geno_alias_data = $geno_alias_lookup->{$geno_id};
        for my $alias_info (@{$geno_alias_data}) {

          my $geno_alias_id = $alias_info->{'GenotypeAliasId'};
          $alias_info->{'removeAlias'} = "delete/genotypealias/$geno_alias_id";

          push(@{$geno_alias_aref}, $alias_info);
        }
        $row->{'Alias'} = $geno_alias_aref;
      }

      my $own_grp_id   = $row->{'OwnGroupId'};
      my $acc_grp_id   = $row->{'AccessGroupId'};
      my $own_perm     = $row->{'OwnGroupPerm'};
      my $acc_perm     = $row->{'AccessGroupPerm'};
      my $oth_perm     = $row->{'OtherPerm'};
      my $ulti_perm    = $row->{'UltimatePerm'};

      my $genus_id     = $row->{'GenusId'};

      if (defined $genus_lookup->{$genus_id}) {

        $row->{'GenusName'} = $genus_lookup->{$genus_id}->{'GenusName'};
      }

      $row->{'OwnGroupName'}          = $group_lookup->{$own_grp_id}->{'SystemGroupName'};
      $row->{'AccessGroupName'}       = $group_lookup->{$acc_grp_id}->{'SystemGroupName'};
      $row->{'OwnGroupPermission'}    = $perm_lookup->{$own_perm};
      $row->{'AccessGroupPermission'} = $perm_lookup->{$acc_perm};
      $row->{'OtherPermission'}       = $perm_lookup->{$oth_perm};
      $row->{'UltimatePermission'}    = $perm_lookup->{$ulti_perm};

      #$self->logger->debug("GenoId: $geno_id, GroupId: $group_id, UltiPerm: $ulti_perm, WritePerm: $WRITE_PERM");
      if (($ulti_perm & $READ_WRITE_PERM) == $READ_WRITE_PERM) {

        $row->{'update'}   = "update/genotype/$geno_id";
      }

      if (($ulti_perm & $LINK_PERM) == $LINK_PERM) {

        $row->{'addAlias'} = "genotype/${geno_id}/add/alias";
      }

      if ($own_grp_id == $group_id) {

        $row->{'chgPerm'} = "genotype/$geno_id/change/permission";

        if ($gadmin_status eq '1') {

          $row->{'chgOwner'} = "genotype/$geno_id/change/owner";

          if ( $not_used_id_href->{$geno_id} ) {

            $row->{'delete'}   = "delete/genotype/$geno_id";
          }
        }
      }

      push(@{$extra_attr_geno_data}, $row);
    }
  }
  else {

    $extra_attr_geno_data = $data_aref;
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_geno_data);
}


sub get_genotype_runmode {

=pod get_genotype_HELP_START
{
"OperationName": "Get Genotype",
"Description": "Return detailed information about genotype specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='Genotype' /><Genotype AccessGroupPerm='5' AccessGroupId='0' GenotypeName='Geno_9981601' GenotypeId='7247924' AccessGroupPermission='Read/Link' OtherPermission='None' addAlias='genotype/7247924/add/alias' chgPerm='genotype/7247924/change/permission' OtherPerm='0' OwnGroupPerm='7' CanPublishGenotype='0' OriginId='0' GenotypeNote='none' SpeciesName='Testing' GenotypeColor='black' OwnGroupPermission='Read/Write/Link' OwnGroupName='admin' GenusName='Genus_5477708' GenusId='30' AccessGroupName='admin' GenotypeAcronym='T' chgOwner='genotype/7247924/change/owner' UltimatePermission='Read/Write/Link' OwnGroupId='0' update='update/genotype/7247924' UltimatePerm='7' /></DATA>",
"SuccessMessageJSON": "{'VCol' : [], 'RecordMeta' : [{ 'TagName' : 'Genotype' } ], 'Genotype' : [ {'AccessGroupPerm' : '5', 'AccessGroupId' : '0', 'GenotypeId' : '7247924', 'GenotypeName' : 'Geno_9981601', 'addAlias' : 'genotype/7247924/add/alias', 'OtherPermission' : 'None', 'AccessGroupPermission' : 'Read/Link', 'chgPerm' : 'genotype/7247924/change/permission', 'OtherPerm' : '0', 'OwnGroupPerm' : '7', 'CanPublishGenotype' : '0', 'OriginId' : '0', 'SpeciesName' : 'Testing', 'GenotypeNote' : 'none', 'GenotypeColor' : 'black', 'OwnGroupPermission' : 'Read/Write/Link', 'OwnGroupName' : 'admin', 'GenusId' : '30', 'GenusName' : 'Genus_5477708', 'AccessGroupName' : 'admin', 'GenotypeAcronym' : 'T', 'chgOwner' : 'genotype/7247924/change/owner', 'UltimatePermission' : 'Read/Write/Link', 'update' : 'update/genotype/7247924', 'OwnGroupId' : '0', 'UltimatePerm' : '7'}] }",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Genotype (724792443) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Genotype (724792443) not found.' }]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing GenotypeId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self    = shift;
  my $geno_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str      = permission_phrase($group_id, 0, $gadmin_status, 'genotype');

  my $geno_perm_sql = "SELECT $perm_str as UltimatePerm ";
  $geno_perm_sql   .= "FROM genotype ";
  $geno_perm_sql   .= "WHERE GenotypeId=?";

  my ($r_geno_perm_err, $geno_perm) = read_cell($dbh, $geno_perm_sql, [$geno_id]);

  if (length($geno_perm) == 0) {

    my $err_msg = "Genotype ($geno_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }
  elsif ( ($geno_perm & $READ_PERM) != $READ_PERM ) {

    my $err_msg = "Permission denied: genotype ($geno_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $field_list = ['genotype.*', 'VCol*',
                    "$perm_str AS UltimatePerm",
      ];

  my $other_join = '';

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $field_list, 'genotype',
                                                                        'GenotypeId', $other_join);
  $dbh->disconnect();

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
  }

  $self->logger->debug('Number of vcols: ' . scalar(@{$vcol_list}));

  my $where_clause = " WHERE (($perm_str) & $READ_PERM) = $READ_PERM AND genotype.GenotypeId=? ";

  $sql =~ s/GROUP BY/ $where_clause GROUP BY /;

  $self->logger->debug("SQL with VCol: $sql");

  my ($read_geno_err, $read_geno_msg, $geno_data) = $self->list_genotype(1, $sql, [$geno_id]);

  if ($read_geno_err) {

    $self->logger->debug($read_geno_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Genotype'   => $geno_data,
                                           'VCol'       => $vcol_list,
                                           'RecordMeta' => [{'TagName' => 'Genotype'}],
  };

  return $data_for_postrun_href;
}

sub list_genus_runmode {

=pod list_genus_HELP_START
{
"OperationName": "List genus",
"Description": "Return list of genuses (organisms) in the system.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<DATA><RecordMeta TagName='Genus' /><Genus GenusName='Genus_5477708' GenusId='30' delete='delete/genus/30' update='update/genus/30' /><Genus GenusName='Genus_4085568' GenusId='29' delete='delete/genus/29' update='update/genus/29' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{ 'TagName' : 'Genus' }], 'Genus' : [{'delete' : 'delete/genus/30', 'GenusId' : '30', 'GenusName' : 'Genus_5477708', 'update' : 'update/genus/30'}, {'delete' : 'delete/genus/29', 'GenusId' : '29', 'GenusName' : 'Genus_4085568', 'update' : 'update/genus/29'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = shift;

  my $data_for_postrun_href = {};

  my $msg = '';

  my ($genus_err, $genus_msg, $genus_data) = $self->list_genus(1, '');

  if ($genus_err) {

    $msg = 'Unexpected error';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $msg}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Genus'      => $genus_data,
                                           'RecordMeta' => [{'TagName' => 'Genus'}],
  };

  return $data_for_postrun_href;
}

sub add_specimen_runmode {

=pod add_specimen_HELP_START
{
"OperationName": "Add Specimen",
"Description": "Adds a new specimen to the database. Specimen needs to be linked with at least one genotype. DAL has a configuration what relations are possible between genotypes and specimens: one-to-one, many-to-one, many-to-many.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "specimen",
"SkippedField": ["OwnGroupId","OwnGroupPerm","AccessGroupId","AccessGroupPerm","OtherPerm"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='1' ParaName='SpecimenId' /><Info Message='Specimen (1) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{ 'ReturnId' : [{ 'Value' : '1', 'ParaName' : 'SpecimenId' }], 'Info' : [{ 'Message' : 'Specimen (1) has been added successfully.' }]}",
"ErrorMessageXML": [{"NameAlreadyExists": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error SpecimenName='SpecimenName (kardinal): already exists.' /></DATA>", "MissingParameter": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error SpecimenName='SpecimenName is missing.' /></DATA>" }],
"ErrorMessageJSON": [{"NameAlreadyExists": "{'Error' : [ {'SpecimenName' : 'SpecimenName (kardinal): already exists.'} ] }", "MissingParameter": "{ 'Error' : [ { 'SpecimenName' : 'SpecimenName is missing.' } ] }" }],
"RequiredUpload": 1,
"UploadFileFormat": "XML",
"UploadFileParameterName": "uploadfile",
"DTDFileNameForUploadXML": "genotypespecimen.dtd",
"HTTPParameter": [{"Name": "specimenlocation", "DataType": "polygon_wkt", "Description": "GIS field defining the polygon geometry object of the specimen in a standard GIS well-known text.", "Type": "LCol", "Required": "0"},{"Name": "specimenlocdt", "DataType": "timestamp", "Description": "DateTime of specimen location", "Type": "LCol", "Required": "0"},{"Name": "currentloc", "DataType": "tinyint", "Description": "Flag to notify current location", "Type": "LCol", "Required": "0"},{"Name": "description", "DataType": "varchar", "Description": "Description for location", "Type": "LCol", "Required": "0"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $runmode_start_time = [gettimeofday()];

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {
                    'OwnGroupId'       => 1,
                    'OwnGroupPerm'     => 1,
                    'AccessGroupId'    => 1,
                    'AccessGroupPerm'  => 1,
                    'OtherPerm'        => 1,
                   };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'specimen', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $specimen_name         = $query->param('SpecimenName');
  my $breed_method_id       = $query->param('BreedingMethodId');

  my $specimen_barcode      = undef;
  my $is_active             = 1;
  my $pedigree              = '';
  my $selection_history     = '';
  my $filial_generation     = undef;
  my $specimen_note         = undef;
  my $source_crossing_id    = undef;

  my $chk_int_href = {};
  if ( length($query->param('IsActive')) > 0 ) {

    $is_active = $query->param('IsActive');
    $chk_int_href->{'IsActive'} = $is_active;
  }

  if ( length($query->param('Pedigree')) > 0 ) {

    $pedigree  = $query->param('Pedigree');
  }

  if ( length($query->param('SpecimenNote')) > 0) {

    $specimen_note = $query->param('SpecimenNote');
  }

  if ( length($query->param('SelectionHistory')) > 0 ) { $selection_history     = $query->param('SelectionHistory'); }

  if ( length($query->param('FilialGeneration')) > 0 ) {

    $filial_generation     = $query->param('FilialGeneration');
    $chk_int_href->{'FilialGeneration'} = $filial_generation;
  }

  if (length($query->param('SourceCrossingId')) > 0) {

    $source_crossing_id = $query->param('SourceCrossingId');
    $chk_int_href->{'SourceCrossingId'} = $source_crossing_id;
  }

  my ($int_err, $int_err_href) = check_integer_href( $chk_int_href );

  if ($int_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$int_err_href]};

    return $data_for_postrun_href;
  }

  my $dbh_write = connect_kdb_write();

  if ( !record_existence($dbh_write, 'breedingmethod', 'BreedingMethodId', $breed_method_id) ) {

    my $err_msg = "BreedingMethodId ($breed_method_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'BreedingMethodId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (defined($source_crossing_id)) {
    if ( !record_existence($dbh_write, 'crossing', 'CrossingId', $source_crossing_id) ) {
      my $err_msg = "CrossingId ($source_crossing_id) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'CrossingId' => $err_msg}]};
      return $data_for_postrun_href;
    }
  }

  my $barcode_start_time = [gettimeofday()];

  if ( length($query->param('SpecimenBarcode')) > 0 ) {

    $specimen_barcode = $query->param('SpecimenBarcode');

    if (record_existence($dbh_write, 'specimen', 'SpecimenBarcode', $specimen_barcode)) {

      my $err_msg = "SpecimenBarcode ($specimen_barcode): already exists.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'SpecimenBarcode' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $chk_barcode_elapsed = tv_interval($barcode_start_time);

  $self->logger->debug("Checking barcode time: $chk_barcode_elapsed");

  my $chk_name_start_time = [gettimeofday()];

  my $spec_name_exist = record_existence($dbh_write, 'specimen', 'SpecimenName', $specimen_name);

  if ($spec_name_exist) {

    my $err_msg = "SpecimenName ($specimen_name): already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'SpecimenName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $chk_name_elapsed = tv_interval($chk_name_start_time);

  $self->logger->debug("Checking name time: $chk_name_elapsed");

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='specimenfactor'";

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

  $dbh_k_read->disconnect();

  my $basic_chk_elapsed = tv_interval($runmode_start_time);

  $self->logger->debug("Basic Checking time: $basic_chk_elapsed");

  my $geno_info_xml_file = $self->authen->get_upload_file();
  my $geno_info_dtd_file = $self->get_genotype_specimen_dtd_file();

  $self->logger->debug("Genotype Info DTD: $geno_info_dtd_file");

  add_dtd($geno_info_dtd_file, $geno_info_xml_file);

  my $ginfo_xml = read_file($geno_info_xml_file);

  $self->logger->debug("XML file with DTD: $ginfo_xml");

  my $xml_checker_parser = new XML::Checker::Parser( Handlers => { } );

  eval {

    local $XML::Checker::FAIL = sub {

      my $code = shift;
      my $err_str = XML::Checker::error_string ($code, @_);
      $self->logger->debug("XML Parsing ERR: $code : $err_str");
      die $err_str;
    };
    $xml_checker_parser->parsefile($geno_info_xml_file);
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

  my $group_id  = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $geno_info_xml  = read_file($geno_info_xml_file);

  $self->logger->debug("Genotype Info: $geno_info_xml");

  my $geno_info_aref = xml2arrayref($geno_info_xml, 'genotypespecimen');

  my $nb_geno = scalar(@{$geno_info_aref});

  if ($GENOTYPE2SPECIMEN_CFG eq $GENO_SPEC_ONE2ONE || $GENOTYPE2SPECIMEN_CFG eq $GENO_SPEC_ONE2MANY) {

    if ($nb_geno > 1) {

      $self->logger->debug("Genotype 2 specimen CFG: $GENOTYPE2SPECIMEN_CFG (more than 1 genotype).");
      my $err_msg = "Genotype to specimen restriction ($GENOTYPE2SPECIMEN_CFG): more than 1 genotype.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @inherit_geno_id_list;

  my @geno_id_list;
  for my $geno_info (@{$geno_info_aref}) {

    my $geno_id = $geno_info->{'GenotypeId'};
    push(@geno_id_list, $geno_id);

    my $geno_existence = record_existence($dbh_write, 'genotype', 'GenotypeId', $geno_id);

    if (!$geno_existence) {

      my $err_msg = "Genotype ($geno_id) does not exist.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    if ($GENOTYPE2SPECIMEN_CFG eq $GENO_SPEC_ONE2ONE) {

      if (record_existence($dbh_write, 'genotypespecimen', 'GenotypeId', $geno_id)) {

        $self->logger->debug("Genotype 2 specimen CFG: $GENOTYPE2SPECIMEN_CFG (genotype already has specimen).");
        my $err_msg = "Genotype to specimen restriction ($GENOTYPE2SPECIMEN_CFG): specimen already exists.";

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }

    if (defined $geno_info->{'GenotypeSpecimenType'}) {

      if (length($geno_info->{'GenotypeSpecimenType'}) > 0) {

        my $geno_spec_type = $geno_info->{'GenotypeSpecimenType'};

        if (!type_existence($dbh_write, 'genotypespecimen', $geno_spec_type)) {

          my $err_msg = "GenotypeSpecimen ($geno_spec_type) does not exist.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
      }
    }

    if (defined $geno_info->{'InheritanceFlag'}) {

      if (length($geno_info->{'InheritanceFlag'}) > 0) {

        my $inheritance_flag = $geno_info->{'InheritanceFlag'};

        if ($inheritance_flag !~ /0|1/) {

          my $err_msg = "InheritanceFlag ($inheritance_flag) must be either 0 or 1.";
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }

        if ("$inheritance_flag" eq '1') {

          push(@inherit_geno_id_list, $geno_id);
        }
      }
    }
  }

  my $inherit_geno_id = undef;

  if ($nb_geno > 1) {

    my $nb_inherit_geno = scalar(@inherit_geno_id_list);

    if ($nb_inherit_geno == 1) {

      $inherit_geno_id = $inherit_geno_id_list[0];
    }
    elsif ($nb_inherit_geno == 0) {

      my $err_msg = "InheritanceFlag: missing for multi genotype specimen.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    elsif ($nb_inherit_geno > 1) {

      my $err_msg = "InheritanceFlag: more than one flag for multi genotype specimen.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }
  else {

    $inherit_geno_id = $geno_info_aref->[0]->{'GenotypeId'};
  }

  if ( !(defined $inherit_geno_id) ) {

    $self->logger->debug("Inheritance Genotype Id is missing.");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my ($is_ok, $trouble_geno_id_aref) = check_permission($dbh_write, 'genotype', 'GenotypeId',
                                                        \@geno_id_list, $group_id, $gadmin_status,
                                                        $LINK_PERM);

  if (!$is_ok) {

    my $trouble_geno_id_str = join(',', @{$trouble_geno_id_aref});

    my $perm_err_msg = '';
    $perm_err_msg   .= "Permission denied: Group ($group_id) and Genotype ($trouble_geno_id_str).";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $perm_err_msg}]};

    return $data_for_postrun_href;
  }

  $sql    = 'SELECT OwnGroupId, OwnGroupPerm, AccessGroupId, AccessGroupPerm, OtherPerm ';
  $sql   .= 'FROM genotype WHERE GenotypeId=?';

  my ($r_inh_perm_err, $r_inh_perm_msg, $inh_data_aref) = read_data($dbh_write, $sql, [$inherit_geno_id]);

  if ($r_inh_perm_err) {

    $self->logger->debug("Read inheritance permission info failed: $r_inh_perm_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$inh_data_aref}) == 0) {

    $self->logger->debug("No inheritance information retrieved.");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $inh_own_grp_id     = $inh_data_aref->[0]->{'OwnGroupId'};
  my $inh_own_grp_perm   = $inh_data_aref->[0]->{'OwnGroupPerm'};
  my $inh_acc_grp_id     = $inh_data_aref->[0]->{'AccessGroupId'};
  my $inh_acc_grp_perm   = $inh_data_aref->[0]->{'AccessGroupPerm'};
  my $inh_oth_perm       = $inh_data_aref->[0]->{'OtherPerm'};

  my $chk_elapsed = tv_interval($runmode_start_time);

  $self->logger->debug("Checking time: $chk_elapsed");

  $sql    = 'INSERT INTO specimen SET ';
  $sql   .= 'BreedingMethodId=?, ';
  $sql   .= 'SourceCrossingId=?, ';
  $sql   .= 'SpecimenName=?, ';
  $sql   .= 'SpecimenBarcode=?, ';
  $sql   .= 'IsActive=?, ';
  $sql   .= 'Pedigree=?, ';
  $sql   .= 'SelectionHistory=?, ';
  $sql   .= 'FilialGeneration=?, ';
  $sql   .= 'SpecimenNote=?, ';
  $sql   .= 'OwnGroupId=?, ';
  $sql   .= 'OwnGroupPerm=?, ';
  $sql   .= 'AccessGroupId=?, ';
  $sql   .= 'AccessGroupPerm=?, ';
  $sql   .= 'OtherPerm=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($breed_method_id, $source_crossing_id, $specimen_name, $specimen_barcode,
                $is_active, $pedigree, $selection_history, $filial_generation, $specimen_note,
                $inh_own_grp_id, $inh_own_grp_perm, $inh_acc_grp_id, $inh_acc_grp_perm, $inh_oth_perm
               );

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  my $specimen_id = $dbh_write->last_insert_id(undef, undef, 'specimen', 'SpecimenId');

  for my $vcol_id (keys(%{$vcol_data})) {

    my $vcol_value = $query->param('VCol_' . "$vcol_id");

    if (length($vcol_value) > 0) {

      $sql  = 'INSERT INTO specimenfactor SET ';
      $sql .= 'SpecimenId=?, ';
      $sql .= 'FactorId=?, ';
      $sql .= 'FactorValue=?';

      my $vcol_sth = $dbh_write->prepare($sql);
      $vcol_sth->execute($specimen_id, $vcol_id, $vcol_value);

      if ($dbh_write->err()) {

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

        return $data_for_postrun_href;
      }
      $vcol_sth->finish();
    }
  }

  if (length $query->param('specimenlocation')) {
    my $sub_PGIS_val_builder = sub {
      return "ST_ForceCollection(ST_GeomFromText(?, -1))";
    };
    my ($err, $err_msg) = append_geography_loc(
                                                "specimen",
                                                $specimen_id,
                                                'POINT',
                                                $query,
                                                $sub_PGIS_val_builder,
                                                $self->logger,
                                              );
    if ($err) {
      return $self->_set_error($err_msg);
    }
  }

  for my $geno_info (@{$geno_info_aref}) {

    my $geno_id = $geno_info->{'GenotypeId'};

    my $geno_spec_type = undef;

    if (defined $geno_info->{'GenotypeSpecimenType'}) {

      if (length($geno_info->{'GenotypeSpecimenType'}) > 0) {

        $geno_spec_type = $geno_info->{'GenotypeSpecimenType'};
      }
    }

    my $inheritance_flag = undef;

    if (defined $geno_info->{'InheritanceFlag'}) {

      if (length($geno_info->{'InheritanceFlag'}) > 0) {

        $inheritance_flag = $geno_info->{'InheritanceFlag'};
      }
    }

    $sql  = 'INSERT INTO genotypespecimen SET ';
    $sql .= 'GenotypeId=?, ';
    $sql .= 'SpecimenId=?, ';
    $sql .= 'GenotypeSpecimenType=?, ';
    $sql .= 'InheritanceFlag=?';

    my $geno_specimen_sth = $dbh_write->prepare($sql);
    $geno_specimen_sth->execute($geno_id, $specimen_id, $geno_spec_type, $inheritance_flag);

    if ($dbh_write->err()) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }
    $geno_specimen_sth->finish();
  }

  $dbh_write->disconnect();

  my $info_msg_aref  = [{'Message' => "Specimen ($specimen_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$specimen_id", 'ParaName' => 'SpecimenId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref,
                                           'ReturnId'  => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_specimen {

  my $self              = $_[0];
  my $extra_attr_yes    = $_[1];
  my $always_geno_data  = $_[2];
  my $sql               = $_[3];
  my $where_para_aref   = $_[4];

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

  my @extra_attr_specimen_data;

  my $breedingmeth_lookup = {};
  my $geno_spec_lookup    = {};
  my $parent_lookup       = {};
  my $keyword_lookup      = {};

  my $bmethod_id_href     = {};
  my $spec_id_aref        = [];

  my $genotype_factor_lookup = {};

  my $chk_id_err        = 0;
  my $chk_id_msg        = '';
  my $used_id_href      = {};
  my $not_used_id_href  = {};

  my $max_nb_genotype   = 0;

  if ($extra_attr_yes || $always_geno_data) {

    for my $specimen_row (@{$data_aref}) {

      push(@{$spec_id_aref}, $specimen_row->{'SpecimenId'});

      if (defined $specimen_row->{'BreedingMethodId'}) {

        $bmethod_id_href->{$specimen_row->{'BreedingMethodId'}} = 1;
      }
    }

    if (scalar(keys(%{$bmethod_id_href})) > 0) {

      my $breedingmeth_sql    = 'SELECT BreedingMethodId, BreedingMethodName FROM breedingmethod ';
      $breedingmeth_sql      .= 'WHERE BreedingMethodId IN (' . join(',', keys(%{$bmethod_id_href})) . ')';

      $self->logger->debug("BREEDINGMETH_SQL: $breedingmeth_sql");

      $breedingmeth_lookup = $dbh->selectall_hashref($breedingmeth_sql, 'BreedingMethodId');
    }

    if (scalar(@{$spec_id_aref}) > 0) {

      my $geno_specimen_sql = 'SELECT genotypespecimen.SpecimenId, genotype.GenotypeId, ';
      $geno_specimen_sql   .= 'genotype.GenotypeName, genotypespecimen.GenotypeSpecimenType, genotype.GenusId, genus.GenusName ';
      $geno_specimen_sql   .= 'FROM genotype LEFT JOIN genotypespecimen ON ';
      $geno_specimen_sql   .= 'genotype.GenotypeId = genotypespecimen.GenotypeId ';
      $geno_specimen_sql   .= 'LEFT JOIN genus ON ';
      $geno_specimen_sql   .= 'genotype.GenusId = genus.GenusId ';
      #$geno_specimen_sql   .= 'LEFT JOIN genotypefactor ON ';
      #$geno_specimen_sql   .= 'genotype.GenotypeId = genotypefactor.GenotypeId ';
      $geno_specimen_sql   .= 'WHERE genotypespecimen.SpecimenId IN (' . join(',', @{$spec_id_aref}) . ')';

      $self->logger->debug("GENO_SPECIMEN_SQL: $geno_specimen_sql");

      my ($geno_specimen_err, $geno_specimen_msg, $geno_specimen_data) = read_data($dbh, $geno_specimen_sql, []);


      if ($geno_specimen_err) {

        return ($geno_specimen_err, $geno_specimen_msg, []);
      }

      for my $geno_spec_row (@{$geno_specimen_data}) {

        my $spec_id = $geno_spec_row->{'SpecimenId'};

        if (defined $geno_spec_lookup->{$spec_id}) {

          my $geno_aref = $geno_spec_lookup->{$spec_id};
          delete($geno_spec_row->{'SpecimenId'});
          push(@{$geno_aref}, $geno_spec_row);
          $geno_spec_lookup->{$spec_id} = $geno_aref;
        }
        else {

          delete($geno_spec_row->{'SpecimenId'});
          $geno_spec_lookup->{$spec_id} = [$geno_spec_row];
        }
      }

      my $get_genotype_factor_sql = 'SELECT genotypespecimen.GenotypeId, genotypefactor.FactorValue, factor.FactorName, genotypefactor.FactorId ';
      $get_genotype_factor_sql   .= 'FROM genotypefactor LEFT JOIN factor ON ';
      $get_genotype_factor_sql   .= 'genotypefactor.FactorId = factor.FactorId ';
      $get_genotype_factor_sql   .= 'LEFT JOIN genotypespecimen ON ';
      $get_genotype_factor_sql   .= 'genotypespecimen.GenotypeId = genotypefactor.GenotypeId ';
      $get_genotype_factor_sql   .= 'WHERE genotypespecimen.SpecimenId IN (' . join(',', @{$spec_id_aref}) . ')';

      $self->logger->debug("Genotype Factor SQL: $get_genotype_factor_sql");

      my ($geno_factor_err, $geno_factor_msg, $geno_factor_data) = read_data($dbh, $get_genotype_factor_sql, []);
      #my $geno_factor_data = [];
      #my $geno_factor_err = 0;
      #my $geno_factor_msg = "";


      if ($geno_factor_err) {

        return ($geno_factor_err, $geno_factor_msg, []);
      }
      else {
        for my $factorrow (@{$geno_factor_data}) {

          my $genotype_id = $factorrow->{'GenotypeId'};

          if (!defined $genotype_factor_lookup->{$genotype_id}) {
            $genotype_factor_lookup->{$genotype_id} = [];
          }

          push(@{$genotype_factor_lookup->{$genotype_id}}, $factorrow);

        }
      }


      my $parent_sql = "SELECT pedigree.SpecimenId, ParentSpecimenId, ParentType, SelectionReason, ";
      $parent_sql   .= "generaltype.TypeName as ParentTypeName ";
      $parent_sql   .= "FROM pedigree LEFT JOIN generaltype ON ";
      $parent_sql   .= "pedigree.ParentType=generaltype.TypeId ";
      $parent_sql   .= "WHERE pedigree.SpecimenId IN (" . join(',', @{$spec_id_aref}) . ')';

      $self->logger->debug("PARENT_SQL: $parent_sql");

      my ($parent_err, $parent_msg, $parent_data) = read_data($dbh, $parent_sql, []);

      if ($parent_err) {

        return ($parent_err, $parent_msg, []);
      }

      for my $parent_row (@{$parent_data}) {

        my $spec_id = $parent_row->{'SpecimenId'};

        if (defined $parent_lookup->{$spec_id}) {

          my $parent_aref = $parent_lookup->{$spec_id};
          delete($parent_row->{'SpecimenId'});
          push(@{$parent_aref}, $parent_row);
          $parent_lookup->{$spec_id} = $parent_aref;
        }
        else {

          delete($parent_row->{'SpecimenId'});
          $parent_lookup->{$spec_id} = [$parent_row];
        }
      }

      my $keyword_sql = 'SELECT SpecimenId, keyword.KeywordId, KeywordName ';
      $keyword_sql   .= 'FROM specimenkeyword LEFT JOIN keyword ON ';
      $keyword_sql   .= 'specimenkeyword.KeywordId = keyword.KeywordId ';
      $keyword_sql   .= 'WHERE SpecimenId IN (' . join(',', @{$spec_id_aref}) . ')';

      $self->logger->debug("Specimen Keyword SQL: $keyword_sql");

      my $spec_kwd_data_aref = [];

      ($err, $msg, $spec_kwd_data_aref) = read_data($dbh, $keyword_sql, []);

      if ($err) {

        return ($err, $msg, []);
      }

      for my $spec_kwd_rec (@{$spec_kwd_data_aref}) {

        my $spec_id = $spec_kwd_rec->{'SpecimenId'};

        my $keyword_aref = [];

        if (defined($keyword_lookup->{$spec_id})) {

          $keyword_aref = $keyword_lookup->{$spec_id};
        }

        push(@{$keyword_aref}, $spec_kwd_rec);

        $keyword_lookup->{$spec_id} = $keyword_aref;
      }

      my $chk_table_aref = [{'TableName' => 'specimengroupentry', 'FieldName' => 'SpecimenId'},
                            {'TableName' => 'trialunitspecimen', 'FieldName' => 'SpecimenId'},
                            {'TableName' => 'pedigree', 'FieldName' => 'ParentSpecimenId'},
                            {'TableName' => 'item', 'FieldName' => 'SpecimenId'}
          ];

      ($chk_id_err, $chk_id_msg,
       $used_id_href, $not_used_id_href) = id_existence_bulk($dbh, $chk_table_aref, $spec_id_aref);

      if ($chk_id_err) {

        $self->logger->debug("Check id existence error: $chk_id_msg");
        $err = 1;
        $msg = $chk_id_msg;

        return ($err, $msg, []);
      }
    }
  }


  for my $specimen_row (@{$data_aref}) {

    my $specimen_id = $specimen_row->{'SpecimenId'};

    if ($always_geno_data || $extra_attr_yes) {

      if (defined $geno_spec_lookup->{$specimen_id}) {

        my $geno_specimen_data = $geno_spec_lookup->{$specimen_id};

        my $nb_genotype = scalar(@{$geno_specimen_data});

        if ($nb_genotype > $max_nb_genotype) {

          $max_nb_genotype = $nb_genotype;
        }

        if ( $extra_attr_yes ) {

          my $genotype_aref = [];

          for my $geno_info (@{$geno_specimen_data}) {

            my $geno_id = $geno_info->{'GenotypeId'};

            if (defined $genotype_factor_lookup->{$geno_id}) {
              my $factor_aref = $genotype_factor_lookup->{$geno_id};

              #$geno_info->{'Factor'} = $factor_aref;
              for my $factor_info (@{$factor_aref}) {
                my $factor_name = "Factor" . $factor_info->{"FactorName"};

                if (! defined $geno_info->{$factor_name}) {
                  $geno_info->{$factor_name} = $factor_info->{"FactorValue"};
                }
                else {
                  $geno_info->{$factor_name} = '';
                }

              }
            }

            if ($gadmin_status eq '1') {

              $geno_info->{'removeGenotype'} = "specimen/${specimen_id}/remove/genotype/$geno_id";
            }
            push(@{$genotype_aref}, $geno_info);
          }



          $specimen_row->{'Genotype'} = $genotype_aref;
        }
        else {

          $specimen_row->{'Genotype'} = $geno_specimen_data;
        }


      }
    }

    if ($extra_attr_yes) {

      if (defined $parent_lookup->{$specimen_id}) {

        $specimen_row->{'Parent'} = $parent_lookup->{$specimen_id};
      }

      if (defined $specimen_row->{'BreedingMethodId'}) {

        my $bmeth_id = $specimen_row->{'BreedingMethodId'};
        $specimen_row->{'BreedingMethodName'} = $breedingmeth_lookup->{$bmeth_id}->{'BreedingMethodName'};
      }

      if (defined $keyword_lookup->{$specimen_id}) {

        $specimen_row->{'Keyword'} = $keyword_lookup->{$specimen_id};
      }

      my $own_grp_id   = $specimen_row->{'OwnGroupId'};
      my $acc_grp_id   = $specimen_row->{'AccessGroupId'};
      my $own_perm     = $specimen_row->{'OwnGroupPerm'};
      my $acc_perm     = $specimen_row->{'AccessGroupPerm'};
      my $oth_perm     = $specimen_row->{'OtherPerm'};
      my $ulti_perm    = $specimen_row->{'UltimatePerm'};

      if ($gadmin_status eq '1') {

        #$self->logger->debug("GenoId: $geno_id, GroupId: $group_id, UltiPerm: $ulti_perm, WritePerm: $WRITE_PERM");
        $specimen_row->{'update'}   = "update/specimen/$specimen_id";
        $specimen_row->{'addGenotype'} = "specimen/${specimen_id}/add/genotype";


        if ($own_grp_id == $group_id) {
          #This following conditional will be able to hide the delete function in the API call if Specimen is used elsewhere
          #if ( $not_used_id_href->{$specimen_id} ) {
          #  $specimen_row->{'delete'}   = "delete/specimen/$specimen_id";
          #}

          $specimen_row->{'delete'}   = "delete/specimen/$specimen_id";
        }
      }
    }



    push(@extra_attr_specimen_data, $specimen_row);
  }

  if (scalar(@extra_attr_specimen_data)) {
    my $gis_read = connect_gis_read();
    
    my $specimen_ids = [];

    foreach my $specimen_href (@extra_attr_specimen_data) {
        push(@$specimen_ids, $specimen_href->{SpecimenId});
    }

    my $gis_where = "WHERE specimenid IN (" . join(',', @$specimen_ids) . ") AND currentloc = 1";

    my $specimen_loc = 'SELECT specimenid, specimenlocdt, description, ST_AsText(specimenlocation) AS specimenlocation ';
    $specimen_loc .= 'FROM specimenloc ';
    $specimen_loc .= $gis_where;

    $self->logger->debug("specimenloc sql: $specimen_loc");

    my $sth_gis = $gis_read->prepare($specimen_loc);
    $sth_gis->execute();

    if ($gis_read->err()) {
      $err = 1;
      $msg = 'Unexpected error';
      $self->logger->debug('Err: ' . $gis_read->errstr());
    } else {
      my $gis_href = $sth_gis->fetchall_hashref('specimenid');
      if ($sth_gis->err()) {
        $err = 1;
        $msg = 'Unexpected error';
        $self->logger->debug('Err: ' . $gis_read->errstr());
      } else {
        foreach my $specimen_href (@extra_attr_specimen_data) {
          my $specimen_id = $specimen_href->{SpecimenId};
          if (exists $gis_href->{$specimen_id}) {
            $specimen_href->{specimenlocdt} = $gis_href->{$specimen_id}->{specimenlocdt};
            $specimen_href->{specimenlocdescription} = $gis_href->{$specimen_id}->{description};
            $specimen_href->{specimenlocation} = $gis_href->{$specimen_id}->{specimenlocation};
          } else {
            $specimen_href->{specimenlocdt} = undef;
            $specimen_href->{specimenlocdescription} = undef;
            $specimen_href->{specimenlocation} = undef;
          }
        }
      }
    }

    $gis_read->disconnect();
  }

  $dbh->disconnect();

  # max_nb_genotype is used by the export specimen runmode so that it knows how many genotype columns to create
  return ($err, $msg, \@extra_attr_specimen_data, $max_nb_genotype);
}

# list specimen advanced starts

sub list_specimen_advanced_runmode {

=pod list_specimen_advanced_HELP_START
{
"OperationName": "List specimens",
"Description": "List specimens. This listing requires pagination information.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><StatInfo Unit='second' ServerElapsedTime='0.183'/><Pagination Page='1' NumOfPages='1' NumOfRecords='1' NumPerPage='50'/><Specimen SelectionHistory='Unknown' OwnGroupPerm='7' OtherPerm='0' Pedigree='Unknown' specimenlocdescription='' SpecimenName='Import_specimen2_22172874723' SourceCrossingId='' AccessGroupId='0' addGenotype='specimen/73/add/genotype' FilialGeneration='0' SpecimenBarcode='SPEC71235436161' OwnGroupId='0' SpecimenId='73' SpecimenNote='' AccessGroupPerm='5' BreedingMethodName='Updated BreedMethod_85131944473' update='update/specimen/73' IsActive='1' specimenlocation='GEOMETRYCOLLECTION(POINT(179.1057021617679 -38.317184619919445))' delete='delete/specimen/73' BreedingMethodId='7' specimenlocdt='2023-04-11 01:18:14'><Genotype removeGenotype='specimen/73/remove/genotype/580' GenusName='Genus_55261373609' GenotypeName='Geno_76016027367' GenotypeSpecimenType='' GenusId='4' GenotypeId='580'/><Genotype GenotypeSpecimenType='' GenotypeId='348' GenusId='4' GenotypeName='Geno_09720376369' GenusName='Genus_55261373609' removeGenotype='specimen/73/remove/genotype/348'/></Specimen><RecordMeta TagName='Specimen'/></DATA>",
"SuccessMessageJSON": "{'Specimen':[{'AccessGroupId':0,'SpecimenNote':'','AccessGroupPerm':5,'delete':'delete/specimen/73','OtherPerm':0,'IsActive':1,'OwnGroupPerm':7,'specimenlocation':'GEOMETRYCOLLECTION(POINT(179.1057021617679-38.317184619919445))','specimenlocdescription':'','Pedigree':'Unknown','specimenlocdt':'2023-04-1101:18:14','BreedingMethodId':'7','SpecimenBarcode':'SPEC71235436161','Genotype':[{'removeGenotype':'specimen/73/remove/genotype/580','GenusName':'Genus_55261373609','GenotypeName':'Geno_76016027367','GenusId':4,'GenotypeSpecimenType':null,'GenotypeId':580},{'GenusName':'Genus_55261373609','removeGenotype':'specimen/73/remove/genotype/348','GenotypeSpecimenType':null,'GenotypeId':348,'GenusId':4,'GenotypeName':'Geno_09720376369'}],'SourceCrossingId':null,'addGenotype':'specimen/73/add/genotype','FilialGeneration':0,'SpecimenId':73,'update':'update/specimen/73','OwnGroupId':0,'SpecimenName':'Import_specimen2_22172874723','SelectionHistory':'Unknown','BreedingMethodName':'UpdatedBreedMethod_85131944473'}],'Pagination':[{'NumPerPage':'50','Page':'1','NumOfPages':1,'NumOfRecords':1}],'VCol':[],'RecordMeta':[{'TagName':'Specimen'}]}",
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

  if (defined $self->param('genoid')) {

    my $geno_id = $self->param('genoid');

    if ($filtering_csv =~ /GenotypeId=(.*),?/) {

      if ( "$geno_id" ne "$1" ) {

        my $err_msg = 'Duplicate filtering condition for GenotypeId.';
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
    else {

      if (length($filtering_csv) > 0) {

        if ($filtering_csv =~ /&$/) {

          $filtering_csv .= "GenotypeId=$geno_id";
        }
        else {

          $filtering_csv .= "&GenotypeId=$geno_id";
        }
      }
      else {

        $filtering_csv .= "GenotypeId=$geno_id";
      }
    }
  }

  $self->logger->debug("Filtering csv: $filtering_csv");

  my $sorting = '';

  if (defined $query->param('Sorting')) {

    $sorting = $query->param('Sorting');
  }

  my $dbh = connect_kdb_read();
  my $field_list = ['specimen.*', 'VCol*'];
  my $pre_data_other_join = '';

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_columns_sql($dbh, $field_list, 'specimen',
                                                                        'SpecimenId', '');

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql   .= " LIMIT 1";

  $self->logger->debug("SQL with VCol: $sql");

  my ($sam_specimen_err, $sam_specimen_msg, $sam_specimen_data) = $self->list_specimen(0, 0, $sql);

  if ($sam_specimen_err) {

    $self->logger->debug($sam_specimen_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $sample_data_aref = $sam_specimen_data;

  my @field_list_all;

  if (scalar(@{$sample_data_aref}) == 1) {

    @field_list_all = keys(%{$sample_data_aref->[0]});
    #@field_list_all = ("BreedingMethodId","AccessGroupPerm", "SpecimenBarcode","AccessGroupId","IsActive","FilialGeneration","OwnGroupPerm","OtherPerm","SelectionHistory","SpecimenId", "Pedigree", "SpecimenName", "SpecimenNote", "OwnGroupId");
  }
  else {

    $self->logger->debug("It reaches here");
    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'specimen');

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

  $self->logger->debug("Field list: " . join(',', @field_list_all));

  my $final_field_list = \@field_list_all;

  my $sql_field_list   = [];

  if (length($field_list_csv) > 0) {

    my ($sel_field_err, $sel_field_msg, $sel_field_list) = parse_selected_field($field_list_csv,
                                                                                \@field_list_all,
                                                                                'SpecimenId');

    if ($sel_field_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;

    for my $fd_name (@{$final_field_list}) {

      # need to remove location field because generate_factor_sql does not understand these field
      if ( (!($fd_name =~ /specimenlocation/)) && (!($fd_name =~ /specimenlocdt/)) && (!($fd_name =~ /specimenlocdescription/))) {
        
        push(@{$sql_field_list}, $fd_name);
      }
    }

  } else {
    for my $fd_name (@{$final_field_list}) {

      # need to remove location field because generate_factor_sql does not understand these field
      if ( (!($fd_name =~ /specimenlocation/)) && (!($fd_name =~ /specimenlocdt/)) && (!($fd_name =~ /specimenlocdescription/))) {
        
        push(@{$sql_field_list}, $fd_name);
      }
    }
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'specimen');

  my $other_join = ' ';

  #change back to generate_factor_sql for normal use
  ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql_v3($dbh, $sql_field_list, 'specimen',
                                                                     'SpecimenId', $other_join);

  #change this back to if ($vcol_err) { if you want normal use
  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ($filtering_csv =~ /GenotypeId/) {

    push(@{$final_field_list}, 'GenotypeId');
    $other_join    = ' LEFT JOIN genotypespecimen ON specimen.SpecimenId = genotypespecimen.SpecimenId ';
    $other_join   .= ' LEFT JOIN genotype ON genotypespecimen.GenotypeId = genotype.GenotypeId ';
    $other_join   .= ' LEFT JOIN genotypefactor ON genotypespecimen.GenotypeId = genotypefactor.GenotypeId ';
  }

  my $field_name2table_name  = { 'GenotypeId' => 'genotypespecimen' };
  my $validation_func_lookup = {};

  $self->logger->debug("Filtering CSV: $filtering_csv");

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering('SpecimenId',
                                                                              'specimen',
                                                                              $filtering_csv,
                                                                              $final_field_list,
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

  my $filtering_exp = " WHERE (($perm_str) & $READ_PERM) = $READ_PERM $filter_where_phrase ";

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

    my $count_sql = "SELECT COUNT(*) ";
    $count_sql   .= "FROM specimen ";
    #$count_sql   .= "$other_join ";
    $count_sql   .= "$filtering_exp";

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

    $paged_limit_clause = $limit_clause;
  }

  $dbh->disconnect();

  $sql  =~ s/SELECT/SELECT DISTINCT /;
  $sql  =~ s/WHEREREPLACE GROUP BY/ $filtering_exp GROUP BY /;

  my ($sort_err, $sort_msg, $sort_sql) = parse_sorting($sorting, $final_field_list);

  if ($sort_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sort_msg}]};

    return $data_for_postrun_href;
  }

  my $final_sort_sql = "";

  if (length($sort_sql) > 0) {

    $final_sort_sql .= " ORDER BY $sort_sql ";
  }
  else {

    $final_sort_sql .= ' ORDER BY specimen.SpecimenId DESC';
  }

  $sql =~ s/ORDERINGSTRING/$final_sort_sql/;
  $sql =~ s/LIMITSTRING/$paged_limit_clause/;

  $self->logger->debug("SQL with VCol: $sql");

  # Genotype permission is checked in list_specimen

  my ($read_specimen_err, $read_specimen_msg, $specimen_data) = $self->list_specimen(1, 1, $sql, $where_arg);

  if ($read_specimen_err) {

    $self->logger->debug($read_specimen_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Specimen'   => $specimen_data,
                                           'VCol'       => $vcol_list,
                                           'Pagination' => $pagination_aref,
                                           'RecordMeta' => [{'TagName' => 'Specimen'}],
  };

  return $data_for_postrun_href;
}

# list specimen advanced ends

sub get_specimen_runmode {

=pod get_specimen_HELP_START
{
"OperationName": "Get specimen",
"Description": "Get detailed information about a specimen specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Specimen SelectionHistory='Unknown' OwnGroupPerm='7' OtherPerm='0' Pedigree='Unknown' specimenlocdescription='' SpecimenName='Import_specimen2_22172874723' SourceCrossingId='' AccessGroupId='0' addGenotype='specimen/73/add/genotype' FilialGeneration='0' SpecimenBarcode='SPEC71235436161' OwnGroupId='0' SpecimenId='73' SpecimenNote='' AccessGroupPerm='5' BreedingMethodName='Updated BreedMethod_85131944473' update='update/specimen/73' IsActive='1' specimenlocation='GEOMETRYCOLLECTION(POINT(179.1057021617679 -38.317184619919445))' delete='delete/specimen/73' BreedingMethodId='7' specimenlocdt='2023-04-11 01:18:14'><Genotype removeGenotype='specimen/73/remove/genotype/580' GenusName='Genus_55261373609' GenotypeName='Geno_76016027367' GenotypeSpecimenType='' GenusId='4' GenotypeId='580'/><Genotype GenotypeSpecimenType='' GenotypeId='348' GenusId='4' GenotypeName='Geno_09720376369' GenusName='Genus_55261373609' removeGenotype='specimen/73/remove/genotype/348'/></Specimen><RecordMeta TagName='Specimen'/></DATA>",
"SuccessMessageJSON": "{ 'Specimen' : [{'AccessGroupId':0,'SpecimenNote':'','AccessGroupPerm':5,'delete':'delete/specimen/73','OtherPerm':0,'IsActive':1,'OwnGroupPerm':7,'specimenlocation':'GEOMETRYCOLLECTION(POINT(179.1057021617679-38.317184619919445))','specimenlocdescription':'','Pedigree':'Unknown','specimenlocdt':'2023-04-1101:18:14','BreedingMethodId':'7','SpecimenBarcode':'SPEC71235436161','Genotype':[{'removeGenotype':'specimen/73/remove/genotype/580','GenusName':'Genus_55261373609','GenotypeName':'Geno_76016027367','GenusId':4,'GenotypeSpecimenType':null,'GenotypeId':580}] } ], 'VCol' : [], 'RecordMeta' : [{ 'TagName' : 'Specimen'} ]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Specimen (123) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Specimen (123) not found.' }]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SpecimenId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self     = shift;
  my $specimen_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  my $specimen_exist = record_existence($dbh, 'specimen', 'SpecimenId', $specimen_id);

  if (!$specimen_exist) {

    my $err_msg = "Specimen ($specimen_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_ok, $trouble_spec_id_aref) = check_permission($dbh, 'specimen', 'SpecimenId',
                                                        [$specimen_id], $group_id, $gadmin_status,
                                                        $READ_PERM);

  if (!$is_ok) {

    my $perm_err_msg = "Permission denied: Group ($group_id) and specimen ($specimen_id).";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $perm_err_msg}]};

    return $data_for_postrun_href;
  }

  my $field_list = ['*'];

  my $other_join = '';

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $field_list, 'specimen',
                                                                        'SpecimenId', $other_join);
  $dbh->disconnect();

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $filtering_exp = ' WHERE specimen.SpecimenId = ? ';

  $sql   =~ s/GROUP BY/ $filtering_exp GROUP BY /;

  $self->logger->debug("SQL with VCol: $sql");

  my ($read_specimen_err, $read_specimen_msg, $specimen_data) = $self->list_specimen(1, 1, $sql, [$specimen_id]);

  if ($read_specimen_err) {

    $self->logger->debug($read_specimen_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Specimen'   => $specimen_data,
                                           'VCol'       => $vcol_list,
                                           'RecordMeta' => [{'TagName' => 'Specimen'}],
  };

  return $data_for_postrun_href;
}

sub update_genotype_runmode {

=pod update_genotype_HELP_START
{
"OperationName": "Update genotype",
"Description": "Update information about the genotype specified by genotype id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "genotype",
"KDDArTFactorTable": "genotypefactor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Genotype (1) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{ 'Info' : [{ 'Message' : 'Genotype (1) has been updated successfully.' }]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Genotype (1) not found.' /></DATA>", "PermissionDenied": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Genotype (1) permission denied.' /></DATA>" }],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [ {'Message' : 'Genotype (1) not found.'} ] }", "PermissionDeined": "{ 'Error' : [ { 'Message' : 'Genotype (1) permission denied.' } ] }" }],
"URLParameter": [{"ParameterName": "id", "Description": "Existing GenotypeId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self        = shift;
  my $query       = $self->query();
  my $genotype_id = $self->param('id');

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = { 'OwnGroupId'      => 1,
                     'AccessGroupId'   => 1,
                     'OwnGroupPerm'    => 1,
                     'AccessGroupPerm' => 1,
                     'OtherPerm'       => 1,
  };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'genotype', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $genotype_name       = $query->param('GenotypeName');
  my $genus_id            = $query->param('GenusId');
  my $origin_id           = $query->param('OriginId');
  my $can_publish         = $query->param('CanPublishGenotype');

  my $dbh_k_read = connect_kdb_read();

  my $species_name   = undef;
  my $acronym        = undef;
  my $note           = undef;
  my $genotype_color = undef;
  my $taxonomy_id    = undef;

  my $df_val_start_time = [gettimeofday()];

  my $read_sql = 'SELECT SpeciesName, GenotypeAcronym, GenotypeNote, GenotypeColor ';
  $read_sql   .= 'FROM genotype WHERE GenotypeId=?';

  my ($r_df_val_err, $r_df_val_msg, $geno_df_val_data) = read_data($dbh_k_read, $read_sql, [$genotype_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve genotype default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $nb_df_val_rec = scalar(@{$geno_df_val_data});

  if ($nb_df_val_rec != 1) {

    $self->logger->debug("Retrieve specimen default values - number of records unacceptable: $nb_df_val_rec");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  $species_name   = $geno_df_val_data->[0]->{'SpecimenBarcode'};
  $acronym        = $geno_df_val_data->[0]->{'IsActive'};
  $note           = $geno_df_val_data->[0]->{'Pedigree'};
  $genotype_color = $geno_df_val_data->[0]->{'SelectionHistory'};
  $taxonomy_id    = $geno_df_val_data->[0]->{'TaxonomyId'};

  my $df_val_elapsed = tv_interval($df_val_start_time);

  $self->logger->debug("Retrieving default value time: $df_val_elapsed");

  if (defined $query->param('SpeciesName')) {

    $species_name = $query->param('SpeciesName');
  }

  if (defined $query->param('GenotypeAcronym')) {

    $acronym = $query->param('GenotypeAcronym');
  }

  if (defined $query->param('GenotypeNote')) {

    $note = $query->param('GenotypeNote');
  }

  if (defined $query->param('GenotypeColor')) {

    $genotype_color = $query->param('GenotypeColor');
  }

  if (length($query->param('TaxonomyId')) > 0) {

    $taxonomy_id = $query->param('TaxonomyId');

    my $taxonomy_existence = record_existence($dbh_k_read, 'taxonomy', 'TaxonomyId', $taxonomy_id);

    if (!$taxonomy_existence) {

      my $err_msg = "TaxonomyId ($taxonomy_id) does not exist.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'TaxonomyId' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }


  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status);

  my $sql = "SELECT $perm_str As UltimatePerm ";
  $sql   .= 'FROM genotype ';
  $sql   .= 'WHERE GenotypeId=?';

  my $sth = $dbh_k_read->prepare($sql);
  $sth->execute($genotype_id);

  my $permission = -1;
  $sth->bind_col(1, \$permission);
  $sth->fetch();
  $sth->finish();

  if ($permission == -1) {

    my $err_msg = "Genotype ($genotype_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }
  elsif (($permission & $READ_WRITE_PERM) != $READ_WRITE_PERM) {

    my $err_msg = "Genotype ($genotype_id) permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($int_err, $int_err_href) = check_integer_href( {'OriginId'           => $origin_id,
                                                      'CanPublishGenotype' => $can_publish,
                                                     });

  if ($int_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$int_err_href]};

    return $data_for_postrun_href;
  }

  $sql    = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='genotypefactor'";

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

  my $genus_existence = record_existence($dbh_k_read, 'genus', 'GenusId', $genus_id);

  if (!$genus_existence) {

    my $err_msg = "Genus ($genus_id) does not exist.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'GenusId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $geno_lookup_sql = 'SELECT GenotypeId FROM genotype WHERE GenotypeName=? AND GenusId=? AND GenotypeId<>?';

  my ($lookp_err, $lookup_geno_id) = read_cell($dbh_k_read, $geno_lookup_sql,
                                               [$genotype_name, $genus_id, $genotype_id]);

  if (length($lookup_geno_id) > 0) {

    my $err_msg = "$genotype_name already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'GenotypeName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $db_geno_name = read_cell_value($dbh_k_read, 'genotype', 'GenotypeName', 'GenotypeId', $genotype_id);

  $sql = 'SELECT GenotypeAliasId FROM genotypealias WHERE GenotypeId=? AND GenotypeAliasName=?';

  my ($geno_alias_err, $geno_alias_id) = read_cell($dbh_k_read, $sql, [$genotype_id, $genotype_name]);

  $geno_lookup_sql  = 'SELECT GenotypeId FROM genotypealias ';
  $geno_lookup_sql .= 'WHERE GenotypeAliasName=? AND GenusId=? AND GenotypeAliasId<>?';

  ($lookp_err, $lookup_geno_id) = read_cell($dbh_k_read, $geno_lookup_sql,
                                            [$genotype_name, $genus_id, $geno_alias_id]);


  if (length($lookup_geno_id) > 0) {

    my $err_msg = "$genotype_name is already used as a Genotype Alias.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'GenotypeName' => $err_msg}] };
    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  $sql    = 'UPDATE genotype SET ';
  $sql   .= 'TaxonomyId=?, ';
  $sql   .= 'GenotypeName=?, ';
  $sql   .= 'GenusId=?, ';
  $sql   .= 'SpeciesName=?, ';
  $sql   .= 'GenotypeAcronym=?, ';
  $sql   .= 'OriginId=?, ';
  $sql   .= 'CanPublishGenotype=?, ';
  $sql   .= 'GenotypeNote=?, ';
  $sql   .= 'GenotypeColor=? ';
  $sql   .= 'WHERE GenotypeId=?';

  $sth = $dbh_k_write->prepare($sql);
  $sth->execute($taxonomy_id, $genotype_name, $genus_id, $species_name, $acronym,
                $origin_id, $can_publish, $note, $genotype_color, $genotype_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  for my $vcol_id (keys(%{$vcol_data})) {

    if (defined $query->param('VCol_' . "$vcol_id")) {

      my $factor_value = $query->param('VCol_' . "$vcol_id");

      $sql  = 'SELECT Count(*) ';
      $sql .= 'FROM genotypefactor ';
      $sql .= 'WHERE GenotypeId=? AND FactorId=?';

      my ($read_err, $count) = read_cell($dbh_k_write, $sql, [$genotype_id, $vcol_id]);

      if (length($factor_value) > 0) {

        if ($count > 0) {

          $sql  = 'UPDATE genotypefactor SET ';
          $sql .= 'FactorValue=? ';
          $sql .= 'WHERE GenotypeId=? AND FactorId=?';
          my $factor_sth = $dbh_k_write->prepare($sql);
          $factor_sth->execute($factor_value, $genotype_id, $vcol_id);

          if ($dbh_k_write->err()) {

            $data_for_postrun_href->{'Error'} = 1;
            $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

            return $data_for_postrun_href;
          }
          $factor_sth->finish();
        }
        else {

          $sql  = 'INSERT INTO genotypefactor SET ';
          $sql .= 'GenotypeId=?, ';
          $sql .= 'FactorId=?, ';
          $sql .= 'FactorValue=?';
          my $factor_sth = $dbh_k_write->prepare($sql);
          $factor_sth->execute($genotype_id, $vcol_id, $factor_value);

          if ($dbh_k_write->err()) {

            $data_for_postrun_href->{'Error'} = 1;
            $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

            return $data_for_postrun_href;
          }

          $factor_sth->finish();
        }
      }
      else {

        if ($count > 0) {

          $sql  = 'DELETE FROM genotypefactor ';
          $sql .= 'WHERE GenotypeId=? AND FactorId=?';

          my $factor_sth = $dbh_k_write->prepare($sql);
          $factor_sth->execute($genotype_id, $vcol_id);

          if ($dbh_k_write->err()) {

            $data_for_postrun_href->{'Error'} = 1;
            $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

            return $data_for_postrun_href;
          }
          $factor_sth->finish();
        }
      }
    }
  }

  $dbh_k_write->disconnect();

  my $info_msg_aref = [{'Message' => "Genotype ($genotype_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}


sub update_specimen_runmode {

=pod update_specimen_HELP_START
{
"OperationName": "Update specimen",
"Description": "Updates information about the specimen specified by specimen id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "specimen",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Specimen (1) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{ 'Info' : [{ 'Message' : 'Specimen (1) has been updated successfully.' }]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Specimen (1) not found.' /></DATA>", "PermissionDenied": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Specimen (1) permission denied.' /></DATA>" }],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [ {'Message' : 'Specimen (1) not found.'} ] }", "PermissionDeined": "{ 'Error' : [ { 'Message' : 'Specimen (1) permission denied.' } ] }" }],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SpecimenId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self     = shift;
  my $query    = $self->query();
  my $specimen_id = $self->param('id');

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {
                    'OwnGroupId'       => 1,
                    'OwnGroupPerm'     => 1,
                    'AccessGroupId'    => 1,
                    'AccessGroupPerm'  => 1,
                    'OtherPerm'        => 1,
                   };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'specimen', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $dbh_k_read = connect_kdb_read();

  my $specimen_exist = record_existence($dbh_k_read, 'specimen', 'SpecimenId', $specimen_id);

  if (!$specimen_exist) {

    my $err_msg = "Specimen ($specimen_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'SpecimenId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'genotype');

  my $geno_perm_sql = "SELECT DISTINCT genotypespecimen.SpecimenId ";
  $geno_perm_sql   .= "FROM genotypespecimen LEFT JOIN genotype ON genotypespecimen.GenotypeId = genotype.GenotypeId ";
  $geno_perm_sql   .= "WHERE (($perm_str) & $READ_WRITE_PERM) = $READ_WRITE_PERM AND genotypespecimen.SpecimenId = ?";

  my ($r_spec_id_err, $db_spec_id) = read_cell($dbh_k_read, $geno_perm_sql, [$specimen_id]);

  if ($r_spec_id_err) {

    $self->logger->debug("Read SpecimenId from database failed");
    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_spec_id) == 0) {

    my $err_msg = "Permission denied: specimen ($specimen_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $specimen_name         = $query->param('SpecimenName');
  my $breed_method_id       = $query->param('BreedingMethodId');

  my $df_val_start_time = [gettimeofday()];

  my $read_sql = 'SELECT SpecimenBarcode, SourceCrossingId, IsActive, Pedigree, SelectionHistory, FilialGeneration, ';
  $read_sql   .= 'SpecimenNote FROM specimen WHERE SpecimenId=?';

  my ($r_df_val_err, $r_df_val_msg, $spec_df_val_data) = read_data($dbh_k_read, $read_sql, [$specimen_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve specimen default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $specimen_barcode      = undef;
  my $is_active             = undef;
  my $pedigree              = undef;
  my $selection_history     = undef;
  my $filial_generation     = undef;
  my $specimen_note         = undef;
  my $source_crossing_id    = undef;

  my $nb_df_val_rec = scalar(@{$spec_df_val_data});

  if ($nb_df_val_rec != 1) {

    $self->logger->debug("Retrieve specimen default values - number of records unacceptable: $nb_df_val_rec");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  $specimen_barcode   = $spec_df_val_data->[0]->{'SpecimenBarcode'};
  $is_active          = $spec_df_val_data->[0]->{'IsActive'};
  $pedigree           = $spec_df_val_data->[0]->{'Pedigree'};
  $selection_history  = $spec_df_val_data->[0]->{'SelectionHistory'};
  $filial_generation  = $spec_df_val_data->[0]->{'FilialGeneration'};
  $specimen_note      = $spec_df_val_data->[0]->{'SpecimenNote'};
  $source_crossing_id = $spec_df_val_data->[0]->{'SourceCrossingId'};

  my $df_val_elapsed = tv_interval($df_val_start_time);

  $self->logger->debug("Retrieving default value time: $df_val_elapsed");

  if (length($filial_generation) == 0) {

    $filial_generation = undef;
  }

  if (length($specimen_note) == 0) {

    $specimen_note = undef;
  }

  my $chk_int_href = {};
  if ( length($query->param('IsActive')) > 0 ) {

    $is_active = $query->param('IsActive');
    $chk_int_href->{'IsActive'} = $is_active;
  }

  if ( length($query->param('Pedigree')) > 0 ) {

    $pedigree  = $query->param('Pedigree');
  }

  if ( length($query->param('SpecimenNote')) > 0) {

    $specimen_note = $query->param('SpecimenNote');
  }

  if ( length($query->param('SelectionHistory')) > 0 ) {

    $selection_history     = $query->param('SelectionHistory');
  }

  if ( length($query->param('FilialGeneration')) > 0 ) {

    $filial_generation     = $query->param('FilialGeneration');
    $chk_int_href->{'FilialGeneration'} = $filial_generation;
  }

  if ( length($query->param('SourceCrossingId')) > 0 ) {

    $source_crossing_id = $query->param('SourceCrossingId');
    $chk_int_href->{'SourceCrossingId'} = $source_crossing_id;
  }


  my ($int_err, $int_err_href) = check_integer_href( $chk_int_href );

  if ($int_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$int_err_href]};

    return $data_for_postrun_href;
  }

  if ( !record_existence($dbh_k_read, 'breedingmethod', 'BreedingMethodId', $breed_method_id) ) {

    my $err_msg = "BreedingMethodId ($breed_method_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'BreedingMethodId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( length($query->param('SpecimenBarcode')) > 0 ) {

    $specimen_barcode = $query->param('SpecimenBarcode');

    my $barcode_sql = 'SELECT SpecimenBarcode ';
    $barcode_sql   .= 'FROM specimen ';
    $barcode_sql   .= 'WHERE SpecimenId != ? AND SpecimenBarcode = ' . $dbh_k_read->quote($specimen_barcode);
    $barcode_sql   .= ' LIMIT 1';

    my ($r_barcode_err, $spec_barcode_db) = read_cell($dbh_k_read, $barcode_sql, [$specimen_id]);

    if (length($spec_barcode_db) > 0) {

      my $err_msg = "SpecimenBarcode ($specimen_barcode): already exists.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'SpecimenBarcode' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }
  else {

    $specimen_barcode = undef;
  }

  if ( length($query->param('SourceCrossingId')) > 0 ) {
    if ( !record_existence($dbh_k_read, 'crossing', 'CrossingId', $source_crossing_id) ) {
      my $err_msg = "SourceCrossingId ($source_crossing_id) not found.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'SourceCrossingId' => $err_msg}]};
      return $data_for_postrun_href;
    }
  }


  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='specimenfactor'";

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

  $sql  = 'SELECT SpecimenName ';
  $sql .= 'FROM specimen ';
  $sql .= 'WHERE SpecimenId != ? AND SpecimenName = ' . $dbh_k_read->quote($specimen_name);
  $sql .= ' LIMIT 1';

  my ($r_spec_err, $spec_name_db) = read_cell($dbh_k_read, $sql, [$specimen_id]);

  if (length($spec_name_db) > 0) {

    my $err_msg = "SpecimenName ($specimen_name): already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'SpecimenName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_write = connect_kdb_write();

  $sql    = 'UPDATE specimen SET ';
  $sql   .= 'BreedingMethodId=?, ';
  $sql   .= 'SourceCrossingId=?, ';
  $sql   .= 'SpecimenName=?, ';
  $sql   .= 'SpecimenBarcode=?, ';
  $sql   .= 'IsActive=?, ';
  $sql   .= 'Pedigree=?, ';
  $sql   .= 'SelectionHistory=?, ';
  $sql   .= 'FilialGeneration=?, ';
  $sql   .= 'SpecimenNote=? ';
  $sql   .= 'WHERE SpecimenId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($breed_method_id, $source_crossing_id, $specimen_name, $specimen_barcode,
                $is_active, $pedigree, $selection_history, $filial_generation, $specimen_note,
                $specimen_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  for my $vcol_id (keys(%{$vcol_data})) {

    if (defined $query->param('VCol_' . "$vcol_id")) {

      my $vcol_value = $query->param('VCol_' . "$vcol_id");

      $sql  = 'SELECT Count(*) ';
      $sql .= 'FROM specimenfactor ';
      $sql .= 'WHERE SpecimenId=? AND FactorId=?';

      my ($read_err, $count) = read_cell($dbh_write, $sql, [$specimen_id, $vcol_id]);

      if (length($vcol_value) > 0) {

        if ($count > 0) {

          $sql  = 'UPDATE specimenfactor SET ';
          $sql .= 'FactorValue=? ';
          $sql .= 'WHERE SpecimenId=? AND FactorId=?';

          my $vcol_sth = $dbh_write->prepare($sql);
          $vcol_sth->execute($vcol_value, $specimen_id, $vcol_id);

          if ($dbh_write->err()) {

            $data_for_postrun_href->{'Error'} = 1;
            $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

            return $data_for_postrun_href;
          }
          $vcol_sth->finish();
        }
        else {

          $sql  = 'INSERT INTO specimenfactor SET ';
          $sql .= 'SpecimenId=?, ';
          $sql .= 'FactorId=?, ';
          $sql .= 'FactorValue=?';

          my $vcol_sth = $dbh_write->prepare($sql);
          $vcol_sth->execute($specimen_id, $vcol_id, $vcol_value);

          if ($dbh_write->err()) {

            $data_for_postrun_href->{'Error'} = 1;
            $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

            return $data_for_postrun_href;
          }
          $vcol_sth->finish();
        }
      }
      else {

        if ($count > 0) {

          $sql  = 'DELETE FROM specimenfactor ';
          $sql .= 'WHERE SpecimenId=? AND FactorId=?';

          my $factor_sth = $dbh_write->prepare($sql);
          $factor_sth->execute($specimen_id, $vcol_id);

          if ($dbh_write->err()) {

            $data_for_postrun_href->{'Error'} = 1;
            $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

            return $data_for_postrun_href;
          }
          $factor_sth->finish();
        }
      }
    }
  }

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "Specimen ($specimen_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub add_genotype_to_specimen_runmode {

=pod add_genotype_to_specimen_HELP_START
{
"OperationName": "Attach genotype to specimen",
"Description": "Adds genotype to the specimen specified by. In some crops (hybrid plants) one specimen can be composed of more than one genotype. Requires relevant (many-to-many) DAL configuration.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "genotypespecimen",
"SkippedField": ["SpecimenId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='464' ParaName='GenotypeSpecimenId' /><Info Message='Genotype (665) now part of specimen (442).' /></DATA>",
"SuccessMessageJSON": "{ 'ReturnId' : [  {   'Value' : '465',   'ParaName' : 'GenotypeSpecimenId'  } ], 'Info' : [  {   'Message' : 'Genotype (666) now part of specimen (442).'  } ]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Genotype (666876) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{ 'Error' : [  {   'Message' : 'Genotype (6668) not found.'  } ]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SpecimenId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self        = shift;
  my $specimen_id    = $self->param('id');
  my $query       = $self->query();

  my $data_for_postrun_href = {};

  if ($GENOTYPE2SPECIMEN_CFG ne $GENO_SPEC_MANY2MANY) {

    my $err_msg = "Genotype to specimen restriction ($GENOTYPE2SPECIMEN_CFG): need $GENO_SPEC_MANY2MANY";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_read = connect_kdb_read();

  my $specimen_exist = record_existence($dbh_read, 'specimen', 'SpecimenId', $specimen_id);

  if (!$specimen_exist) {

    my $err_msg = "Specimen ($specimen_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'genotype');

  my $geno_perm_sql = "SELECT DISTINCT genotypespecimen.SpecimenId ";
  $geno_perm_sql   .= "FROM genotypespecimen LEFT JOIN genotype ON genotypespecimen.GenotypeId = genotype.GenotypeId ";
  $geno_perm_sql   .= "WHERE (($perm_str) & $READ_WRITE_PERM) = $READ_WRITE_PERM AND genotypespecimen.SpecimenId = ?";

  my ($r_spec_id_err, $db_spec_id) = read_cell($dbh_read, $geno_perm_sql, [$specimen_id]);

  if ($r_spec_id_err) {

    $self->logger->debug("Read SpecimenId from database failed");
    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_spec_id) == 0) {

    my $err_msg = "Permission denied: specimen ($specimen_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $genotype_id = $query->param('GenotypeId');

  my ($missing_err, $missing_href) = check_missing_href( {'GenotypeId' => $genotype_id} );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  my $sql      = "SELECT $perm_str AS UltimatePermission ";
  $sql        .= 'FROM genotype ';
  $sql        .= 'WHERE LOWER(GenotypeId)=?';

  my ($read_err, $permission) = read_cell($dbh_read, $sql, [$genotype_id]);

  if (length($permission) == 0) {

    my $err_msg = "Genotype ($genotype_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }
  elsif ( ($permission & $READ_LINK_PERM) != $READ_LINK_PERM ) {

    my $err_msg = "Genotype ($genotype_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql    = 'SELECT Count(*) ';
  $sql   .= 'FROM genotypespecimen ';
  $sql   .= 'WHERE GenotypeId=? AND SpecimenId=?';

  my $sth = $dbh_read->prepare($sql);
  $sth->execute($genotype_id, $specimen_id);
  my $count = 0;
  $sth->bind_col(1, \$count);
  $sth->fetch();
  $sth->finish();

  if ($count > 0) {

    my $err_msg = "Genotype ($genotype_id) already part of specimen ($specimen_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_read->disconnect();

  my $dbh_write = connect_kdb_write();

  $sql  = 'INSERT INTO genotypespecimen SET ';
  $sql .= 'GenotypeId=?, ';
  $sql .= 'SpecimenId=?';

  $sth = $dbh_write->prepare($sql);
  $sth->execute($genotype_id, $specimen_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $geno_spec_id = $dbh_write->last_insert_id(undef, undef, 'genotypespecimen', 'GenotypeSpecimenId');

  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "Genotype ($genotype_id) now part of specimen ($specimen_id)."}];
  my $return_id_aref = [{'Value' => "$geno_spec_id", 'ParaName' => 'GenotypeSpecimenId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub remove_genotype_from_specimen_runmode {

=pod remove_genotype_from_specimen_gadmin_HELP_START
{
"OperationName": "Detach specimen from genotype",
"Description": "Removes genotype (genoid) from specimen specified by id. Genotype is no longer the 'parent' of the specimen. At least one genotype has to remain attached to the specimen.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Genotype (666) has been removed from specimen (442).' /></DATA>",
"SuccessMessageJSON": "{ 'Info' : [  {   'Message' : 'Genotype (665) has been removed from specimen (442).'  } ]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Genotype (665) not part of specimen (442).' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{ 'Error' : [  {   'Message' : 'Genotype (665) not part of specimen (442).'  } ]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SpecimenId"}, {"ParameterName": "genoid", "Description": "GenotypeId which is part of the specimen identified of id parameter"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self        = shift;
  my $specimen_id = $self->param('id');
  my $genotype_id = $self->param('genoid');

  my $data_for_postrun_href = {};

  if ($GENOTYPE2SPECIMEN_CFG ne $GENO_SPEC_MANY2MANY) {

    my $err_msg = "Genotype to specimen restriction ($GENOTYPE2SPECIMEN_CFG): need $GENO_SPEC_MANY2MANY";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_read = connect_kdb_read();

  my $specimen_exist = record_existence($dbh_read, 'specimen', 'SpecimenId', $specimen_id);

  if (!$specimen_exist) {

    my $err_msg = "Specimen ($specimen_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $genotype_exist = record_existence($dbh_read, 'genotype', 'GenotypeId', $genotype_id);

  if (!$genotype_exist) {

    my $err_msg = "Genotype ($genotype_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT GenotypeSpecimenId ';
  $sql   .= 'FROM genotypespecimen ';
  $sql   .= 'WHERE GenotypeId=? AND SpecimenId=?';

  my ($read_err, $genotype_specimen_id) = read_cell($dbh_read, $sql, [$genotype_id, $specimen_id]);

  if (length($genotype_specimen_id) == 0) {

    my $err_msg = "Genotype ($genotype_id) not part of specimen ($specimen_id).";

    $self->logger->debug($err_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql  = 'SELECT COUNT(GenotypeSpecimenId) ';
  $sql .= 'FROM genotypespecimen ';
  $sql .= 'WHERE SpecimenId=?';

  my ($count_err, $nb_geno) = read_cell($dbh_read, $sql, [$specimen_id]);

  if ($nb_geno == 1) {

    $self->logger->debug("Specimen ($specimen_id) has only one genotype.");

    my $err_msg = "Genotype ($genotype_id) cannot be removed from specimen ($specimen_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_read->disconnect();

  my $dbh_write = connect_kdb_write();

  $sql  = 'DELETE FROM genotypespecimen ';
  $sql .= 'WHERE GenotypeSpecimenId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($genotype_specimen_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "Genotype ($genotype_id) has been removed from specimen ($specimen_id)."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub add_genotype_alias_runmode {

=pod add_genotype_alias_HELP_START
{
"OperationName": "Add alias to the genotype",
"Description": "Add an alias (name) to the genotype specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "genotypealias",
"SkippedField": ["GenotypeId", "GenusId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='2' ParaName='GenotypeAliasId' /><Info Message='GenotypeAlias (2) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{ 'ReturnId' : [  {   'Value' : '3',   'ParaName' : 'GenotypeAliasId'  } ], 'Info' : [  {   'Message' : 'GenotypeAlias (3) has been added successfully.'  } ]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Genotype (66527) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{ 'Error' : [  {   'Message' : 'Genotype (66527) not found.'  } ]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing GenotypeId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self    = shift;
  my $geno_id = $self->param('id');
  my $query   = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'GenotypeId'     => 1,
                    'GenusId'        => 1,
                    'IsGenotypeName' => 1,
                   };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'genotypealias', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $dbh_write = connect_kdb_write();

  my $genus_id = read_cell_value($dbh_write, 'genotype', 'GenusId', 'GenotypeId', $geno_id);

  if (length($genus_id) == 0) {

    my $err_msg = "Genotype ($geno_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_geno_ok, $trouble_geno_id_aref) = check_permission($dbh_write, 'genotype', 'GenotypeId',
                                                             [$geno_id], $group_id, $gadmin_status,
                                                             $READ_WRITE_PERM);

  if (!$is_geno_ok) {

    my $trouble_geno_id = $trouble_geno_id_aref->[0];
    my $err_msg = "Permission denied: Group ($group_id) and genotype ($geno_id).";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $geno_alias_name   = $query->param('GenotypeAliasName');

  my $geno_alias_type   = undef;
  my $geno_alias_status = undef;
  my $geno_alias_lang   = undef;

  if (defined $query->param('GenotypeAliasType')) {

    if (length($query->param('GenotypeAliasType')) > 0) {

      $geno_alias_type = $query->param('GenotypeAliasType');
    }
  }

  if (defined $query->param('GenotypeAliasStatus')) {

    if (length($query->param('GenotypeAliasStatus')) > 0) {

      $geno_alias_status = $query->param('GenotypeAliasStatus');
    }
  }

  if (defined $query->param('GenotypeAliasLang')) {

    if (length($query->param('GenotypeAliasLang')) > 0) {

      $geno_alias_lang = $query->param('GenotypeAliasLang');
    }
  }

  if (defined $geno_alias_type) {

    if (!type_existence($dbh_write, 'genotypealias', $geno_alias_type)) {

      my $err_msg = "GenotypeAliasType ($geno_alias_type): not found.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'GenotypeAliasType' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  if (defined $geno_alias_status) {

    if (!type_existence($dbh_write, 'genotypealiasstatus', $geno_alias_status)) {

      my $err_msg = "GenotypeAliasStatus ($geno_alias_status): not found.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'GenotypeAliasStatus' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $sql = 'SELECT GenotypeAliasId FROM genotypealias WHERE GenotypeAliasName=? AND GenusId=?';

  my ($lookup_err, $alias_id) = read_cell($dbh_write, $sql, [$geno_alias_name, $genus_id]);

  if (length($alias_id) > 0) {

    my $err_msg = "GenotypeAliasName ($geno_alias_name): already exists.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'GenotypeAliasName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql = 'SELECT GenotypeId FROM genotype WHERE GenotypeName=? AND GenusId=?';

  my ($lookup_geno_err, $db_geno_id) = read_cell($dbh_write, $sql, [$geno_alias_name, $genus_id]);

  if (length($db_geno_id) > 0) {

    my $err_msg = "GenotypeAliasName ($geno_alias_name): already used as GenotypeName in genotype ($db_geno_id).";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'GenotypeAliasName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql    = 'INSERT INTO genotypealias SET ';
  $sql   .= 'GenotypeAliasName=?, ';
  $sql   .= 'GenotypeId=?, ';
  $sql   .= 'GenotypeAliasType=?, ';
  $sql   .= 'GenotypeAliasStatus=?, ';
  $sql   .= 'GenotypeAliasLang=?, ';
  $sql   .= 'GenusId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($geno_alias_name, $geno_id, $geno_alias_type, $geno_alias_status,
                $geno_alias_lang, $genus_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  my $geno_alias_id = $dbh_write->last_insert_id(undef, undef, 'genotypealias', 'GenotypeAliasId');

  $dbh_write->disconnect();

  my $info_msg_aref  = [{'Message' => "GenotypeAlias ($geno_alias_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$geno_alias_id", 'ParaName' => 'GenotypeAliasId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_genotype_alias_runmode {

=pod update_genotype_alias_HELP_START
{
"OperationName": "Update genotype alias",
"Description": "Updates genotype alias (alternative name) for specified alias id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "genotypealias",
"SkippedField": ["GenotypeId", "GenusId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='GenotypeAlias (1) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{ 'Info' : [  {   'Message' : 'GenotypeAlias (1) has been updated successfully.'  } ]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='GenotypeAlias (5) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{ 'Error' : [  {   'Message' : 'GenotypeAlias (5) not found.'  } ]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing GenotypeAliasId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self          = shift;
  my $geno_alias_id = $self->param('id');
  my $query         = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'GenotypeId'     => 1,
                    'GenusId'        => 1,
                    'IsGenotypeName' => 1,
                   };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'genotypealias', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  $self->logger->debug("Genotype alias id: $geno_alias_id");

  my $dbh_write = connect_kdb_write();

  my $read_sql  = 'SELECT GenotypeId, GenusId, GenotypeAliasType, GenotypeAliasStatus, GenotypeAliasLang ';
  $read_sql    .= 'FROM genotypealias WHERE GenotypeAliasId=? ';

  my ($r_df_val_err, $r_df_val_msg, $geno_df_val_data) = read_data($dbh_write, $read_sql, [$geno_alias_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve genoalias default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $geno_alias_name   = $query->param('GenotypeAliasName');

  my $geno_id            = undef;
  my $geno_alias_type    = undef;
  my $geno_alias_status  = undef;
  my $geno_alias_lang    = undef;

  my $nb_df_val_rec    =  scalar(@{$geno_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve genoalias default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $geno_id           = $geno_df_val_data->[0]->{'GenotypeId'};
  $geno_alias_type   = $geno_df_val_data->[0]->{'GenotypeAliasType'};
  $geno_alias_status = $geno_df_val_data->[0]->{'GenotypeAliasStatus'};
  $geno_alias_lang   = $geno_df_val_data->[0]->{'GenotypeAliasLang'};
  my $genus_id       = $geno_df_val_data->[0]->{'GenusId'};

  if (length($geno_alias_type) == 0) {

    $geno_alias_type = undef;
  }

  if (length($geno_alias_status) == 0) {

    $geno_alias_status = undef;
  }

  if (length($geno_alias_lang) == 0) {

    $geno_alias_lang = undef;
  }

  if (length($geno_id) == 0) {

    my $err_msg = "GenotypeAlias ($geno_alias_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_geno_ok, $trouble_geno_id_aref) = check_permission($dbh_write, 'genotype', 'GenotypeId',
                                                             [$geno_id], $group_id, $gadmin_status,
                                                             $READ_WRITE_PERM);

  if (!$is_geno_ok) {

    my $trouble_geno_id = $trouble_geno_id_aref->[0];
    my $err_msg = "Permission denied: Group ($group_id) and genotype ($geno_id).";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT GenotypeAliasId FROM genotypealias ';
  $sql   .= 'WHERE GenotypeAliasName=? AND GenusId=? AND GenotypeAliasId<>?';

  my ($chk_name_err, $db_geno_alias_id) = read_cell($dbh_write, $sql, [$geno_alias_name, $genus_id,
                                                                       $geno_alias_id]);

  if (length($db_geno_alias_id) > 0) {

    my $err_msg = "GenotypeAliasName ($geno_alias_name) - GenusId ($genus_id): already used.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql  = 'SELECT GenotypeId FROM genotype ';
  $sql .= 'WHERE GenotypeName=? AND GenusId=? AND GenotypeId<>?';

  my ($chk_geno_name_err, $db_geno_id) = read_cell($dbh_write, $sql, [$geno_alias_name, $genus_id,
                                                                      $geno_id]);

  if (length($db_geno_id) > 0) {

    my $err_msg = "GenotypeAliasName ($geno_alias_name): already used as GenotypeName in genotype ($db_geno_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (defined $query->param('GenotypeAliasType')) {

    if (length($query->param('GenotypeAliasType')) > 0) {

      $geno_alias_type = $query->param('GenotypeAliasType');
    }
    else {

      $geno_alias_type = undef;
    }
  }

  if (length($geno_alias_type) > 0) {

    if (!type_existence($dbh_write, 'genotypealias', $geno_alias_type)) {

      my $err_msg = "GenotypeAliasType ($geno_alias_type): not found.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'GenotypeAliasType' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }
  else {

    $geno_alias_type = undef;
  }

  if (defined $query->param('GenotypeAliasStatus')) {

    if (length($query->param('GenotypeAliasStatus')) > 0) {

      $geno_alias_status = $query->param('GenotypeAliasStatus');
    }
    else {

      $geno_alias_status = undef;
    }
  }

  if (length($geno_alias_status) > 0) {

    if (!type_existence($dbh_write, 'genotypealiasstatus', $geno_alias_status)) {

      my $err_msg = "GenotypeAliasStatus ($geno_alias_status): not found.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'GenotypeAliasStatus' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }
  else {

    $geno_alias_status = undef;
  }

  if (defined $query->param('GenotypeAliasLang')) {

    if (length($query->param('GenotypeAliasLang')) > 0) {

      $geno_alias_lang = $query->param('GenotypeAliasLang');
    }
    else {

      $geno_alias_lang = undef;
    }
  }

  if (length($geno_alias_lang) == 0) {

    $geno_alias_lang = undef;
  }

  $sql    = 'UPDATE genotypealias SET ';
  $sql   .= 'GenotypeAliasName=?, ';
  $sql   .= 'GenotypeAliasType=?, ';
  $sql   .= 'GenotypeAliasStatus=?, ';
  $sql   .= 'GenotypeAliasLang=? ';
  $sql   .= 'WHERE GenotypeAliasId=?';

  $self->logger->debug("SQL: $sql");

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($geno_alias_name, $geno_alias_type, $geno_alias_status, $geno_alias_lang, $geno_alias_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "GenotypeAlias ($geno_alias_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub delete_genotype_alias_runmode {

=pod delete_genotype_alias_HELP_START
{
"OperationName": "Delete genotype alias",
"Description": "Delete genotype alias (alternative name) for specified alias id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SkippedField": ["GenotypeId", "GenusId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='GenotypeAlias (1) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{ 'Info' : [  {   'Message' : 'GenotypeAlias (1) has been deleted successfully.'  } ]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='GenotypeAlias (5) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{ 'Error' : [  {   'Message' : 'GenotypeAlias (5) not found.'  } ]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing GenotypeAliasId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self          = shift;
  my $geno_alias_id = $self->param('id');
  my $query         = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  # Finish generic required static field checking

  $self->logger->debug("Genotype alias id: $geno_alias_id");

  my $dbh_write = connect_kdb_write();

  my $read_sql  = 'SELECT GenotypeId, IsGenotypeName, GenotypeAliasName ';
  $read_sql    .= 'FROM genotypealias WHERE GenotypeAliasId=? ';

  my ($r_df_val_err, $r_df_val_msg, $geno_df_val_data) = read_data($dbh_write, $read_sql, [$geno_alias_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve genoalias default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => "Unexpected Error"}]};

    return $data_for_postrun_href;
  }


  my $is_name_flag   = $geno_df_val_data->[0]->{'IsGenotypeName'};
  my $genotypealias_name   = $geno_df_val_data->[0]->{'GenotypeAliasName'};
  my $geno_id   = $geno_df_val_data->[0]->{'GenotypeId'};

  if ($is_name_flag == 1) {
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => "$genotypealias_name is the name of Genotype $geno_id and cannot be removed"}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_geno_ok, $trouble_geno_id_aref) = check_permission($dbh_write, 'genotype', 'GenotypeId',
                                                             [$geno_id], $group_id, $gadmin_status,
                                                             $READ_WRITE_PERM);


   if (!$is_geno_ok) {

     my $trouble_geno_id = $trouble_geno_id_aref->[0];
     my $err_msg = "Permission denied: Group ($group_id) and genotype ($geno_id).";

     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

     return $data_for_postrun_href;
   }

   my $dbh_write = connect_kdb_write();

   $self->logger->debug("Deleting Genotype ALias $geno_alias_id");

   my $sql = 'DELETE FROM genotypealias where GenotypeAliasId=?';

   my $sth = $dbh_write->prepare($sql);
   $sth->execute($geno_alias_id);

   if ($dbh_write->err()) {

     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error'}]};

     return $data_for_postrun_href;
   }

   $sth->finish();

   $dbh_write->disconnect();

   my $info_msg_aref = [{'Message' => "Genotype Alias ($geno_alias_id) has been deleted successfully."}];

   $data_for_postrun_href->{'Error'}     = 0;
   $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref};
   $data_for_postrun_href->{'ExtraData'} = 0;

   return $data_for_postrun_href;
}


sub list_genotype_alias {

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

  my $extra_attr_alias_data = [];

  if ($extra_attr_yes) {

    my $alias_type_sql           = "SELECT TypeId, TypeName FROM generaltype WHERE Class='genotypealias'";
    my $geno_alias_type_lookup   = $dbh->selectall_hashref($alias_type_sql, 'TypeId');

    my $alias_status_sql         = "SELECT TypeId, TypeName FROM generaltype WHERE Class='genotypealiasstatus'";
    my $geno_alias_status_lookup = $dbh->selectall_hashref($alias_status_sql, 'TypeId');

    for my $row (@{$data_aref}) {

      if (defined $row->{'GenotypeAliasType'}) {

        my $geno_alias_type             = $row->{'GenotypeAliasType'};
        $row->{'GenotypeAliasTypeName'} = $geno_alias_type_lookup->{$geno_alias_type}->{'TypeName'};
      }

      if (defined $row->{'GenotypeAliasStatus'}) {

        my $geno_alias_status             = $row->{'GenotypeAliasStatus'};
        $row->{'GenotypeAliasStatusName'} = $geno_alias_status_lookup->{$geno_alias_status}->{'TypeName'};
      }

      my $geno_perm     = $row->{'UltimatePerm'};

      if (($geno_perm & $READ_WRITE_PERM) == $READ_WRITE_PERM) {

        my $geno_alias_id = $row->{'GenotypeAliasId'};
        $row->{'update'}   = "update/genotypealias/$geno_alias_id";
        $row->{'delete'}   = "delete/genotypealias/$geno_alias_id";
      }
      push(@{$extra_attr_alias_data}, $row);
    }
  }
  else {

    $extra_attr_alias_data = $data_aref;
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_alias_data);
}

sub list_genotype_alias_advanced_runmode {

=pod list_genotype_alias_advanced_HELP_START
{
"OperationName": "List genotype aliases",
"Description": "Return a list of aliases (alternative names) for genotypes. This listing requires pagination definition.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination NumOfRecords='4' NumOfPages='2' Page='1' NumPerPage='2' /><GenotypeAlias GenotypeAliasType='' GenotypeId='665' GenotypeAliasName='Alias2' GenotypeAliasId='4' GenotypeAliasStatus='' GenotypeAliasLang='' delete='delete/genotypealias/4' update='update/genotypealias/4' UltimatePerm='7' /><GenotypeAlias GenotypeAliasType='' GenotypeId='665' GenotypeAliasName='Alias2' GenotypeAliasId='3' GenotypeAliasStatus='' delete='delete/genotypealias/3' GenotypeAliasLang='' update='update/genotypealias/3' UltimatePerm='7' /><RecordMeta TagName='GenotypeAlias' /></DATA>",
"SuccessMessageJSON": "{ 'Pagination' : [ {  'NumOfRecords' : '4',  'NumOfPages' : 2,  'NumPerPage' : '2',  'Page' : '1' } ], 'GenotypeAlias' : [ {  'GenotypeAliasType' : null,  'GenotypeAliasName' : 'Alias2',  'GenotypeId' : '665',  'GenotypeAliasId' : '4',  'GenotypeAliasStatus' : null,  'GenotypeAliasLang' : null,  'delete' : 'delete/genotypealias/4',  'update' : 'update/genotypealias/4',  'UltimatePerm' : '7' }, {  'GenotypeAliasType' : null,  'GenotypeAliasName' : 'Alias2',  'GenotypeId' : '665',  'GenotypeAliasId' : '3',  'GenotypeAliasStatus' : null,  'GenotypeAliasLang' : null,  'delete' : 'delete/genotypealias/3',  'update' : 'update/genotypealias/3',  'UltimatePerm' : '7' } ], 'VCol' : [], 'RecordMeta' : [ {  'TagName' : 'GenotypeAlias' } ]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"URLParameter": [{"ParameterName": "nperpage", "Description": "Number of records in a page for pagination"}, {"ParameterName": "num", "Description": "The page number of the pagination"}],
"HTTPParameter": [{"Required": 0, "Name": "Filtering", "Description": "Filtering parameter string consisting of filtering expressions which are separated by ampersand (&) which needs to be encoded if HTTP GET method is used. Each filtering expression is composed of a database field name, a filtering operator and the filtering value."}, {"Required": 0, "Name": "FieldList", "Description": "Comma separated value of wanted fields."}, {"Required": 0, "Name": "Sorting", "Description": "Comma separated value of SQL sorting phrases."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self    = shift;
  my $query   = $self->query();

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

  if (defined $self->param('genoid')) {

    my $geno_id = $self->param('genoid');

    if ($filtering_csv =~ /GenotypeId=(.*)&?/) {

      if ( "$geno_id" ne "$1" ) {

        my $err_msg = 'Duplicate filtering condition for GenotypeId.';
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
    else {

      if (length($filtering_csv) > 0) {

        if ($filtering_csv =~ /&$/) {

          $filtering_csv .= "GenotypeId=$geno_id";
        }
        else {

          $filtering_csv .= "&GenotypeId=$geno_id";
        }
      }
      else {

        $filtering_csv .= "GenotypeId=$geno_id";
      }
    }
  }

  $self->logger->debug("Filtering csv: $filtering_csv");

  my $sorting = '';

  if (defined $query->param('Sorting')) {

    $sorting = $query->param('Sorting');
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'genotype');

  my $dbh = connect_kdb_read();
  my $field_list = ['genotypealias.*', 'VCol*'];

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $field_list, 'genotypealias',
                                                                        'GenotypeAliasId', '');

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql   .= " LIMIT 1";

  $self->logger->debug("SQL with VCol: $sql");

  my ($sam_alias_err, $sam_alias_msg, $sam_alias_data) = $self->list_genotype_alias(0, $sql, []);

  if ($sam_alias_err) {

    $self->logger->debug("Get sample genotypealias failed: $sam_alias_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $sample_data_aref = $sam_alias_data;

  my @field_list_all;

  if (scalar(@{$sample_data_aref}) == 1) {

    @field_list_all = keys(%{$sample_data_aref->[0]});
  }
  else {

    $self->logger->debug("It reaches here");
    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'genotypealias');

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
                                                                                \@field_list_all,
                                                                                'GenotypeAliasId');

    if ($sel_field_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;
  }

  my $other_join = ' LEFT JOIN genotype ON genotypealias.GenotypeId = genotype.GenotypeId ';

  ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $final_field_list, 'genotypealias',
                                                                     'GenotypeAliasId', $other_join);

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ($filtering_csv =~ /GenotypeId/) {

    push(@{$final_field_list}, 'GenotypeId');
  }

  push(@{$final_field_list}, "$perm_str AS UltimatePerm");

  ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $final_field_list, 'genotypealias',
                                                                     'GenotypeAliasId', $other_join);

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering('GenotypeAliasId',
                                                                              'genotypealias',
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

    $self->logger->debug("Filtering expression: $filtering_exp");

    #my $count_sql = "SELECT COUNT(GenotypeAliasId) ";
    #$count_sql   .= "FROM genotypealias LEFT JOIN genotype ON ";
    #$count_sql   .= "genotypealias.GenotypeId = genotype.GenotypeId ";
    #$count_sql   .= "$filtering_exp";

    my $count_sql = "SELECT COUNT(GenotypeAliasId) ";
    $count_sql   .= "FROM genotypealias ";

    if (length($filter_phrase) > 0) {

      $count_sql .= "WHERE $filter_phrase";
    }

    my ($pg_id_err, $pg_id_msg, $nb_records,
        $nb_pages, $limit_clause, $rcount_time) = get_paged_filter_sql($dbh,
                                                                       $nb_per_page,
                                                                       $page,
                                                                       $count_sql,
                                                                       $where_arg
            );


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

  $sql  =~ s/GROUP BY/ $filtering_exp GROUP BY /;

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

    $sql .= ' ORDER BY GenotypeAliasId DESC';
  }

  $sql .= " $paged_limit_clause ";

  $self->logger->debug("SQL with VCol: $sql");

  # where_arg here in the list function because of the filtering
  my ($read_alias_err, $read_alias_msg, $alias_data) = $self->list_genotype_alias(1,
                                                                                  $sql,
                                                                                  $where_arg);

  if ($read_alias_err) {

    $self->logger->debug($read_alias_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'GenotypeAlias' => $alias_data,
                                           'VCol'          => $vcol_list,
                                           'Pagination'    => $pagination_aref,
                                           'RecordMeta'    => [{'TagName' => 'GenotypeAlias'}],
  };

  return $data_for_postrun_href;
}

sub get_genotype_alias_runmode {

=pod get_genotype_alias_HELP_START
{
"OperationName": "Get genotype alias",
"Description": "Returns detailed information for genotype alias specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><GenotypeAlias GenotypeAliasTypeName='GenoAliasType - 7045551' GenotypeAliasStatus='' GenotypeAliasType='51' GenotypeAliasLang='ENG' GenotypeId='3' GenotypeAliasName='Test1' GenotypeAliasId='1' /><RecordMeta TagName='GenotypeAlias' /></DATA>",
"SuccessMessageJSON": "{ 'GenotypeAlias' : [  {   'GenotypeAliasTypeName' : 'GenoAliasType - 7045551',   'GenotypeAliasType' : '51',   'GenotypeAliasStatus' : null,   'GenotypeAliasLang' : 'ENG',   'GenotypeAliasName' : 'Test1',   'GenotypeId' : '3',   'GenotypeAliasId' : '1'  } ], 'RecordMeta' : [  {   'TagName' : 'GenotypeAlias'  } ]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='GenotypeAlias (8) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{ 'Error' : [  {   'Message' : 'GenotypeAlias (8) not found.'  } ]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing genotype alias id."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self          = shift;
  my $geno_alias_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $geno_id = read_cell_value($dbh, 'genotypealias', 'GenotypeId', 'GenotypeAliasId', $geno_alias_id);

  if (length($geno_id) == 0) {

    my $err_msg = "GenotypeAlias ($geno_alias_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $perm_str = permission_phrase($group_id, 0, $gadmin_status);
  my $sql      = "SELECT $perm_str FROM genotype WHERE GenotypeId=?";

  my ($read_perm_err, $geno_perm) = read_cell($dbh, $sql, [$geno_id]);

  if ( ($geno_perm & $READ_PERM) != $READ_PERM ) {

    my $err_msg = "Permission denied: Group ($group_id) and genotype ($geno_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  $sql  = 'SELECT * ';
  $sql .= 'FROM genotypealias ';
  $sql .= 'WHERE GenotypeAliasId=?';

  my ($geno_alias_err, $geno_alias_msg, $geno_alias_data) = $self->list_genotype_alias(1, $sql, [$geno_alias_id]);

  if ($geno_alias_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'GenotypeAlias'  => $geno_alias_data,
                                           'RecordMeta'     => [{'TagName' => 'GenotypeAlias'}],
  };

  return $data_for_postrun_href;
}

sub update_genus_runmode {

=pod update_genus_gadmin_HELP_START
{
"OperationName": "Update genus",
"Description": "Update genus (organism) information using specified id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "genus",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Genus (1) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{ 'Info' : [  {   'Message' : 'Genus (1) has been updated successfully.'  } ]}",
"ErrorMessageXML": [{"NameAlreadyExists": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error GenusName='GenusName (triticum): already exists' /></DATA>"}],
"ErrorMessageJSON": [{"NameAlreadyExists": "{ 'Error' : [  {   'GenusName' : 'GenusName (triticum): already exists'  } ]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing GenusId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self      = shift;
  my $query     = $self->query();

  my $genus_id  = $self->param('id');

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'genus', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $genus_name = $query->param('GenusName');

  my $dbh = connect_kdb_write();

  my $genus_exist = record_existence($dbh, 'genus', 'GenusId', $genus_id);

  if (!$genus_exist) {

    my $err_msg = "Genus ($genus_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $chk_gname_sql = 'SELECT GenusId FROM genus WHERE GenusName=? AND GenusId <> ?';

  my ($read_err, $db_genus_id) = read_cell($dbh, $chk_gname_sql, [$genus_name, $genus_id]);

  if ($read_err) {

    $self->logger->debug("Read exististing genus name failed");

    my $err_msg = 'Unexpected Error.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_genus_id) > 0) {

    my $err_msg = "GenusName ($genus_name): already exists";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'GenusName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'UPDATE genus SET ';
  $sql   .= 'GenusName=? ';
  $sql   .= 'WHERE GenusId=?';

  my $sth = $dbh->prepare($sql);
  $sth->execute($genus_name, $genus_id);

  if ( $dbh->err() ) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();
  $dbh->disconnect();

  my $info_msg = "Genus ($genus_id) has been updated successfully.";
  my $info_msg_aref = [{'Message' => $info_msg}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub get_genus_runmode {

=pod get_genus_HELP_START
{
"OperationName": "Get genus",
"Description": "Return detailed information about a genus (organism) specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='Genus' /><Genus GenusName='triticum' GenusId='1' delete='delete/genus/1' update='update/genus/1' /></DATA>",
"SuccessMessageJSON": "{ 'RecordMeta' : [{'TagName' : 'Genus'} ], 'Genus' : [{'delete' : 'delete/genus/1', 'GenusId' : '1', 'GenusName' : 'triticum', 'update' : 'update/genus/1'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Genus (15) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{ 'Error' : [  {   'Message' : 'Genus (15) not found.'  } ]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing genus id."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self     = shift;
  my $genus_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();
  my $genus_exist = record_existence($dbh, 'genus', 'GenusId', $genus_id);
  $dbh->disconnect();

  if (!$genus_exist) {

    my $err_msg = "Genus ($genus_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $where_clause = 'WHERE GenusId=?';

  my ($genus_err, $genus_msg, $genus_data) = $self->list_genus(1, $where_clause, $genus_id);

  if ($genus_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Genus'      => $genus_data,
                                           'RecordMeta' => [{'TagName' => 'Genus'}],
  };

  return $data_for_postrun_href;
}

sub add_trait2genotype_runmode {

=pod add_trait2genotype_HELP_START
{
"OperationName": "Add trait value for genotype",
"Description": "Add known value of the trait for a genotype. Usually known feature/value of the particular genotype (not generated as a direct measurement).",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "genotypetrait",
"SkippedField": ["GenotypeId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='4' ParaName='GenotypeTraitId' /><Info Message='GenotypeTrait (4) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{ 'ReturnId' : [{'Value' : '5', 'ParaName' : 'GenotypeTraitId'}], 'Info' : [{'Message' : 'GenotypeTrait (5) has been added successfully.'} ]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Trait (100) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{ 'Error' : [ {  'Message' : 'Trait (100) not found.' } ]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing genotype id which is known for the adding trait."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self    = shift;
  my $geno_id = $self->param('id');
  my $query   = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'GenotypeId' => 1};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'genotypetrait', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $trait_id    = $query->param('TraitId');
  my $trait_value = $query->param('TraitValue');

  $dbh_read = connect_kdb_read();

  my $group_id  = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str  = permission_phrase($group_id, 0, $gadmin_status);

  my $sql      = "SELECT $perm_str AS UltimatePermission ";
  $sql        .= 'FROM genotype ';
  $sql        .= 'WHERE GenotypeId=?';

  my ($read_err, $geno_permission) = read_cell($dbh_read, $sql, [$geno_id]);

  if (length($geno_permission) == 0) {

    my $err_msg = "Genotype ($geno_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }
  else {

    if ( ($geno_permission & $READ_WRITE_PERM) != $READ_WRITE_PERM ) {

      my $err_msg = "Genotype ($geno_id): permission denied.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $trait_exist = record_existence($dbh_read, 'trait', 'TraitId', $trait_id);

  if (!$trait_exist) {

    my $err_msg = "Trait ($trait_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql  = "SELECT $perm_str AS UltimatePermission ";
  $sql .= 'FROM trait ';
  $sql .= 'WHERE TraitId=?';

  my $trait_permission;
  ($read_err, $trait_permission) = read_cell($dbh_read, $sql, [$trait_id]);

  if ( ($trait_permission & $LINK_PERM) != $LINK_PERM ) {

    my $err_msg = "Trait ($trait_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($trait_val_validation_err, $validation_msg) = validate_trait_db($dbh_read, $trait_id, $trait_value);

  if ($trait_val_validation_err) {

    $self->logger->debug("Validation msg: $validation_msg");
    my $err_msg = "Trait value ($trait_value) not valid for trait ($trait_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_read->disconnect();

  my $dbh_write = connect_kdb_write();

  $sql  = 'INSERT INTO genotypetrait SET ';
  $sql .= 'GenotypeId=?, ';
  $sql .= 'TraitId=?, ';
  $sql .= 'TraitValue=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($geno_id, $trait_id, $trait_value);

  my $geno_trait_id = -1;
  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $geno_trait_id = $dbh_write->last_insert_id(undef, undef, 'genotypetrait', 'GenotypeTraitId');
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref  = [{'Message' => "GenotypeTrait ($geno_trait_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$geno_trait_id", 'ParaName' => 'GenotypeTraitId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref,
                                           'ReturnId'  => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_genotype_trait {

  my $self            = shift;
  my $extra_attr_yes  = shift;
  my $geno_perm       = shift;
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

  my $sql = 'SELECT trait.TraitName, genotypetrait.GenotypeTraitId, genotypetrait.GenotypeId, genotypetrait.TraitId,genotypetrait.TraitValue, generalunit.UnitName ';
  $sql   .= 'FROM genotypetrait ';
  $sql   .= ' INNER JOIN trait on trait.TraitId=genotypetrait.TraitId ';
  $sql   .= ' INNER JOIN generalunit on trait.UnitId=generalunit.UnitId ';
  $sql   .= $where_clause . ' ';
  $sql   .= ' ORDER BY GenotypeTraitId DESC ';

  $self->logger->debug("SQL: $sql");

  my $sth = $dbh->prepare($sql);
  # parameters provided by the caller
  # for example, ('WHERE FieldA=?', '1')
  $sth->execute(@_);

  my $err = 0;
  my $msg = '';
  my $geno_trait_data = [];

  if ( !$dbh->err() ) {

    my $array_ref = $sth->fetchall_arrayref({});

    if ( !$sth->err() ) {

      $geno_trait_data = $array_ref;
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

  my $extra_attr_geno_trait_data;

  if ($extra_attr_yes) {

    for my $row (@{$geno_trait_data}) {

      if (($geno_perm & $READ_WRITE_PERM) == $READ_WRITE_PERM) {

        my $geno_trait_id  = $row->{'GenotypeTraitId'};
        my $geno_id        = $row->{'GenotypeId'};
        my $trait_id       = $row->{'TraitId'};
        $row->{'update'}   = "update/genotypetrait/$geno_trait_id";
        $row->{'delete'}   = "genotype/$geno_id/remove/trait/$trait_id";
      }
      push(@{$extra_attr_geno_trait_data}, $row);
    }
  }
  else {

    $extra_attr_geno_trait_data = $geno_trait_data;
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_geno_trait_data);
}

sub list_genotype_trait_runmode {

=pod list_genotype_trait_HELP_START
{
"OperationName": "List trait values for genotype",
"Description": "Returns full list of trait values for a genotype. Usually known feature/value of the particular genotype (not generated as a direct measurement).",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='GenotypeTrait' /><GenotypeTrait GenotypeTraitId='4' TraitValue='40' GenotypeId='442' delete='genotype/442/remove/trait/1' TraitId='1' 'TraitName': 'Yield' update='update/genotypetrait/4' /></DATA>",
"SuccessMessageJSON": "{ 'RecordMeta' : [ {  'TagName' : 'GenotypeTrait' } ], 'GenotypeTrait' : [ {  'GenotypeTraitId' : '4',  'TraitName' : 'Yield','TraitValue' : '40',  'delete' : 'genotype/442/remove/trait/1',  'GenotypeId' : '442',  'update' : 'update/genotypetrait/4',  'TraitId' : '1' } ]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Genotype (4426) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Genotype (4426) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "GenotypeId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self    = shift;
  my $geno_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  my $genotype_exist = record_existence($dbh, 'genotype', 'GenotypeId', $geno_id);

  if (!$genotype_exist) {

    my $err_msg = "Genotype ($geno_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_geno_ok, $trouble_geno_id_aref) = check_permission($dbh, 'genotype', 'GenotypeId',
                                                             [$geno_id], $group_id, $gadmin_status,
                                                             $READ_PERM);

  if (!$is_geno_ok) {

    my $trouble_geno_id = $trouble_geno_id_aref->[0];
    my $err_msg = "Permission denied: Group ($group_id) and genotype ($geno_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $perm_str = permission_phrase($group_id, 0, $gadmin_status);
  my $sql = "SELECT $perm_str FROM genotype WHERE GenotypeId=?";

  my ($read_perm_err, $geno_perm) = read_cell($dbh, $sql, [$geno_id]);

  $dbh->disconnect();

  my $where_clause = 'WHERE GenotypeId=?';
  my ($geno_trait_err, $geno_trait_msg, $geno_trait_data) = $self->list_genotype_trait(1,
                                                                                       $geno_perm,
                                                                                       $where_clause,
                                                                                       $geno_id);

  if ($geno_trait_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'GenotypeTrait' => $geno_trait_data,
                                           'RecordMeta'    => [{'TagName' => 'GenotypeTrait'}],
  };

  return $data_for_postrun_href;
}

sub get_genotype_trait_runmode {

=pod get_genotype_trait_HELP_START
{
"OperationName": "Get trait value for genotype",
"Description": "Returns known value of the trait for a genotype. Usually known feature/value of the particular genotype (not generated as a direct measurement).",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='GenotypeTrait' /><GenotypeTrait GenotypeTraitId='4' GenotypeId='442' delete='genotype/442/remove/trait/1' TraitValue='40' TraitId='1' update='update/genotypetrait/4' /></DATA>",
"SuccessMessageJSON": "{ 'RecordMeta' : [ {  'TagName' : 'GenotypeTrait' } ], 'GenotypeTrait' : [ {  'GenotypeTraitId' : '4',  'TraitValue' : '40',  'delete' : 'genotype/442/remove/trait/1',  'GenotypeId' : '442',  'update' : 'update/genotypetrait/4',  'TraitId' : '1' } ]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='GenotypeTrait (47) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{ 'Error' : [ {  'Message' : 'GenotypeTrait (47) not found.' } ]}"}],
"URLParameter": [{"ParameterName": "genotraitid", "Description": "Existing GenotypeTraitId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self          = shift;
  my $geno_trait_id = $self->param('genotraitid');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $geno_id = read_cell_value($dbh, 'genotypetrait', 'GenotypeId', 'GenotypeTraitId', $geno_trait_id);

  if (length($geno_id) == 0) {

    my $err_msg = "GenotypeTrait ($geno_trait_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $perm_str = permission_phrase($group_id, 0, $gadmin_status);
  my $sql      = "SELECT $perm_str FROM genotype WHERE GenotypeId=?";

  my ($read_perm_err, $geno_perm) = read_cell($dbh, $sql, [$geno_id]);

  if ( ($geno_perm & $READ_PERM) != $READ_PERM ) {

    my $err_msg = "Permission denied: Group ($group_id) and genotype ($geno_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  my $where_clause = 'WHERE GenotypeTraitId=?';
  my ($geno_trait_err, $geno_trait_msg, $geno_trait_data) = $self->list_genotype_trait(1,
                                                                                       $geno_perm,
                                                                                       $where_clause,
                                                                                       $geno_trait_id);

  if ($geno_trait_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'GenotypeTrait' => $geno_trait_data,
                                           'RecordMeta'    => [{'TagName' => 'GenotypeTrait'}],
  };

  return $data_for_postrun_href;
}

sub update_genotype_trait_runmode {

=pod update_genotype_trait_HELP_START
{
"OperationName": "Update trait value for genotype",
"Description": "Update known value of the trait for a genotype. Usually known feature/value of the particular genotype (not generated as a direct measurement).",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "genotypetrait",
"SkippedField": ["GenotypeId", "TraitId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='GenotypeTrait (4) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{ 'Info' : [ {  'Message' : 'GenotypeTrait (4) has been updated successfully.' } ]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='GenotypeTraitId (41) not found.' /></DATA>" }],
"ErrorMessageJSON": [{"IdNotFound": "{ 'Error' : [{'Message' : 'GenotypeTraitId (41) not found.'}]}" }],
"URLParameter": [{"ParameterName": "genotraitid", "Description": "Existing GenotypeTraitId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self          = shift;
  my $geno_trait_id = $self->param('genotraitid');
  my $query         = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'GenotypeId' => 1,
                    'TraitId'    => 1,
                   };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'genotypetrait', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $trait_value   = $query->param('TraitValue');

  $dbh_read = connect_kdb_read();

  my $sql = 'SELECT GenotypeId ';
  $sql   .= 'FROM genotypetrait ';
  $sql   .= 'WHERE GenotypeTraitId=?';

  my ($read_err, $geno_id) = read_cell($dbh_read, $sql, [$geno_trait_id]);

  if ( length($geno_id) == 0) {

    my $err_msg = "GenotypeTraitId ($geno_trait_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status);

  $sql  = "SELECT $perm_str AS UltimatePermission ";
  $sql .= 'FROM genotype ';
  $sql .= 'WHERE GenotypeId=?';

  my $geno_permission;
  ($read_err, $geno_permission) = read_cell($dbh_read, $sql, [$geno_id]);

  if ( ($geno_permission & $READ_WRITE_PERM) != $READ_WRITE_PERM ) {

    my $err_msg = "Genotype ($geno_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_read->disconnect();

  my $dbh_write = connect_kdb_write();

  $sql  = 'UPDATE genotypetrait SET ';
  $sql .= 'TraitValue=? ';
  $sql .= 'WHERE GenotypeTraitId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($trait_value, $geno_trait_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "GenotypeTrait ($geno_trait_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub remove_genotype_trait_runmode {

=pod remove_genotype_trait_HELP_START
{
"OperationName": "Delete trait value for genotype",
"Description": "Deletes known value of the trait for a genotype. Usually known feature/value of the particular genotype (not generated as a direct measurement).",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Trait (1) has been removed from genotype (443).' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{ 'Message' : 'Trait (1) has been removed from genotype (442).'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error TraitId='Trait (1) not part of genotype (443).' /></DATA>", "PermissionDenied": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Genotype (442): permission denied.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{ 'Error' : [ {  'TraitId' : 'Trait (1) not part of genotype (443).' } ]}", "PermissionDeined": "{ 'Error' : [ { 'Message' : 'Genotype (442): permission denied.'}] }"}],
"URLParameter": [{"ParameterName": "genoid", "Description": "GenotypeId"}, {"ParameterName": "traitid", "Description": "TraitId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self        = shift;
  my $genotype_id = $self->param('genoid');
  my $trait_id    = $self->param('traitid');

  my $data_for_postrun_href = {};

  my $dbh_read = connect_kdb_read();

  my $genotype_exist = record_existence($dbh_read, 'genotype', 'GenotypeId', $genotype_id);

  if (!$genotype_exist) {

    my $err_msg = "Genotype ($genotype_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'GenotypeId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status);

  my $sql = "SELECT $perm_str AS UltimatePermission ";
  $sql   .= 'FROM genotype ';
  $sql   .= 'WHERE GenotypeId=?';

  my ($read_err, $genotype_permission) = read_cell($dbh_read, $sql, [$genotype_id]);

  if ( ($genotype_permission & $READ_WRITE_PERM) != $READ_WRITE_PERM ) {

    my $err_msg = "Genotype ($genotype_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $trait_exist = record_existence($dbh_read, 'trait', 'TraitId', $trait_id);

  if (!$trait_exist) {

    my $err_msg = "Trait ($trait_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql    = 'SELECT GenotypeTraitId ';
  $sql   .= 'FROM genotypetrait ';
  $sql   .= 'WHERE GenotypeId=? AND TraitId=?';

  my $genotype_trait_id;
  ($read_err, $genotype_trait_id) = read_cell($dbh_read, $sql, [$genotype_id, $trait_id]);

  if (length($genotype_trait_id) == 0) {

    my $err_msg = "Trait ($trait_id) not part of genotype ($genotype_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message'=> $err_msg, 'TraitId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_read->disconnect();

  my $dbh_write = connect_kdb_write();

  $sql  = 'DELETE FROM genotypetrait ';
  $sql .= 'WHERE GenotypeId=? AND TraitId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($genotype_id,$trait_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "Trait ($trait_id) has been removed from genotype ($genotype_id)."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub add_specimen_group_runmode {

=pod add_specimen_group_HELP_START
{
"OperationName": "Add specimen group",
"Description": "Add a new specimen group.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "specimengroup",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='7' ParaName='SpecimenGroupId' /><Info Message='SpecimenGroup (7) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '8','ParaName' : 'SpecimenGroupId'}],'Info' : [{'Message' : 'SpecimenGroup (8) has been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error SpecimenGroupTypeId='SpecimenGroupTypeId (97): not found or active.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'SpecimenGroupTypeId' : 'SpecimenGroupTypeId (97): not found or active.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "XML",
"UploadFileParameterName": "uploadfile",
"DTDFileNameForUploadXML": "specimengroup.dtd",
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'OwnGroupId'           => 1};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'specimengroup', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $specimen_group_name         = $query->param('SpecimenGroupName');
  my $specimen_group_type         = $query->param('SpecimenGroupTypeId');
  my $date_created                = $query->param('SpecimenGroupCreated');

  my $group_id      = $self->authen->group_id();

  my $own_perm      = 7;
  my $access_group  = $group_id;
  my $access_perm   = 5;
  my $other_perm    = 0;

  if (length($query->param('OwnGroupPerm')) > 0) {

    $own_perm = $query->param('OwnGroupPerm');
  }

  if (length($query->param('AccessGroupId')) > 0) {

    $access_group = $query->param('AccessGroupId');
  }

  if (length($query->param('AccessGroupPerm')) > 0) {

    $access_perm = $query->param('AccessGroupPerm');
  }

  if (length($query->param('OtherPerm')) > 0) {

    $other_perm = $query->param('OtherPerm');
  }

  my $specimen_group_status       = undef;

  if (defined $query->param('SpecimenGroupStatus')) {

    if (length($query->param('SpecimenGroupStatus')) > 0) {

      $specimen_group_status = $query->param('SpecimenGroupStatus');
    }
  }

  my $specimen_group_note         = undef;

  if (length($query->param('SpecimenGroupNote')) > 0) {

    $specimen_group_note = $query->param('SpecimenGroupNote');
  }

  my $dbh_write = connect_kdb_write();

  if (!type_existence($dbh_write, 'specimengroup', $specimen_group_type)) {

    my $err_msg = "SpecimenGroupTypeId ($specimen_group_type): not found or active.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'SpecimenGroupTypeId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (record_existence($dbh_write, 'specimengroup', 'SpecimenGroupName', $specimen_group_name)) {

    my $err_msg = "SpecimenGroupName ($specimen_group_name): already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'SpecimenGroupName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (defined $specimen_group_status) {

    if (!type_existence($dbh_write, 'specimengroupstatus', $specimen_group_status)) {

      my $err_msg = "SpecimenGroupStatus ($specimen_group_status): not found or active.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'SpecimenGroupStatus' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $access_grp_existence = record_existence($dbh_write, 'systemgroup', 'SystemGroupId', $access_group);

  if (!$access_grp_existence) {

    my $err_msg = "AccessGroup ($access_group) does not exist.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'AccessGroupId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( ($own_perm > 7 || $own_perm < 0) ) {

    my $err_msg = "OwnGroupPerm ($own_perm) is invalid.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'OwnGroupPerm' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( ($access_perm > 7 || $access_perm < 0) ) {

    my $err_msg = "AccessGroupPerm ($access_perm) is invalid.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'AccessGroupPerm' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( ($other_perm > 7 || $other_perm < 0) ) {

    my $err_msg = "OtherPerm ($other_perm) is invalid.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'OtherPerm' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($date_err, $date_href) = check_dt_href( {'SpecimenGroupCreated' => $date_created} );

  if ($date_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$date_href]};

    return $data_for_postrun_href;
  }

  my $specimen_info_xml_file = $self->authen->get_upload_file();
  my $specimen_info_dtd_file = $self->get_specimen_group_dtd_file();

  add_dtd($specimen_info_dtd_file, $specimen_info_xml_file);

  my $xml_checker_parser = new XML::Checker::Parser( Handlers => { } );

  eval {

    local $XML::Checker::FAIL = sub {

      my $code = shift;
      my $err_str = XML::Checker::error_string ($code, @_);
      $self->logger->debug("XML Parsing ERR: $code : $err_str");
      die $err_str;
    };
    $xml_checker_parser->parsefile($specimen_info_xml_file);
  };

  if ($@) {

    my $err_msg = $@;
    $self->logger->debug("Parsing XML error: $err_msg");
    my $user_err_msg = "Specimen group xml file does not comply with its definition.\n";
    $user_err_msg   .= "Details: $err_msg";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $user_err_msg}]};

    return $data_for_postrun_href;
  }

  my $gadmin_status = $self->authen->gadmin_status();

  my $specimen_info_xml  = read_file($specimen_info_xml_file);
  my $specimen_info_aref = xml2arrayref($specimen_info_xml, 'specimengroupentry');

  my $geno_perm_str  = permission_phrase($group_id, 0, $gadmin_status, 'genotype');

  my $uniq_spec_id_href = {};

  for my $specimen_info (@{$specimen_info_aref}) {

    my $spec_id = $specimen_info->{'SpecimenId'};

    if (defined $uniq_spec_id_href->{$spec_id}) {

      my $err_msg = "Specimen ($spec_id): duplicate.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    else {

      $uniq_spec_id_href->{$spec_id} = 1;
    }
  }

  my @spec_id_list = keys(%{$uniq_spec_id_href});

  if (scalar(@spec_id_list) > 0) {

    my $specimen_geno_sql = 'SELECT genotypespecimen.SpecimenId, Count(genotypespecimen.GenotypeId) ';
    $specimen_geno_sql   .= 'FROM genotypespecimen LEFT JOIN genotype ON ';
    $specimen_geno_sql   .= 'genotypespecimen.GenotypeId = genotype.GenotypeId ';
    $specimen_geno_sql   .= 'WHERE genotypespecimen.SpecimenId IN (' . join(',', @spec_id_list) . ') ';
    $specimen_geno_sql   .= 'GROUP BY genotypespecimen.SpecimenId';

    my $normal_geno_count_lookup = $dbh_write->selectall_hashref($specimen_geno_sql, 'SpecimenId');

    if ($dbh_write->err()) {

      $self->logger->debug("Read genotype count failed: " . $dbh_write->errstr());

      my $err_msg = "Unexpected Error.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $not_found_specimen_id_aref = [];

    for my $spec_id (@spec_id_list) {

      if ( !(defined $normal_geno_count_lookup->{$spec_id}) ) {

        push(@{$not_found_specimen_id_aref}, $spec_id);
      }
    }

    if (scalar(@{$not_found_specimen_id_aref}) > 0) {

      my $err_msg = "Specimen (" . join(',', @{$not_found_specimen_id_aref}) . "): not found";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    $specimen_geno_sql    = 'SELECT genotypespecimen.SpecimenId, Count(genotypespecimen.GenotypeId) ';
    $specimen_geno_sql   .= 'FROM genotypespecimen LEFT JOIN genotype ON ';
    $specimen_geno_sql   .= 'genotypespecimen.GenotypeId = genotype.GenotypeId ';
    $specimen_geno_sql   .= 'WHERE genotypespecimen.SpecimenId IN (' . join(',', @spec_id_list) . ') ';
    $specimen_geno_sql   .= "AND ((($geno_perm_str) & $READ_PERM) = $READ_PERM) ";
    $specimen_geno_sql   .= 'GROUP BY genotypespecimen.SpecimenId';

    my $geno_with_perm_count_lookup = $dbh_write->selectall_hashref($specimen_geno_sql, 'SpecimenId');

    if ($dbh_write->err()) {

      $self->logger->debug("Read genotype with permission count failed: " . $dbh_write->errstr());

      my $err_msg = "Unexpected Error.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $perm_denied_specimen_id_aref = [];

    for my $spec_id (@spec_id_list) {

      if ( !(defined $geno_with_perm_count_lookup->{$spec_id}) ) {

        push(@{$perm_denied_specimen_id_aref}, $spec_id);
      }
    }

    if (scalar(@{$perm_denied_specimen_id_aref}) > 0) {

      my $err_msg = "Specimen (" . join(',', @{$perm_denied_specimen_id_aref}) . "): permission denied";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $sql = 'INSERT INTO specimengroup SET ';
  $sql   .= 'SpecimenGroupStatus=?, ';
  $sql   .= 'SpecimenGroupTypeId=?, ';
  $sql   .= 'SpecimenGroupName=?, ';
  $sql   .= 'SpecimenGroupNote=?, ';
  $sql   .= 'SpecimenGroupCreated=?, ';
  $sql   .= 'OwnGroupId=?, ';
  $sql   .= 'OwnGroupPerm=?, ';
  $sql   .= 'AccessGroupId=?, ';
  $sql   .= 'AccessGroupPerm=?, ';
  $sql   .= 'OtherPerm=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($specimen_group_status, $specimen_group_type, $specimen_group_name, $specimen_group_note,
               $date_created, $group_id, $own_perm, $access_group, $access_perm, $other_perm);

  if ($dbh_write->err()) {

    $self->logger->debug("SQL INSERT failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  my $specimen_group_id = $dbh_write->last_insert_id(undef, undef, 'specimengroup', 'SpecimenGroupId');

  my @spec_grp_entry_sql_list;

  for my $specimen_info (@{$specimen_info_aref}) {

    my $specimen_id   = $specimen_info->{'SpecimenId'};
    my $specimen_note = 'NULL';

    if (defined $specimen_info->{'SpecimenNote'}) {

      if (length($specimen_info->{'SpecimenNote'}) > 0) {

        $specimen_note = $dbh_write->quote($specimen_info->{'SpecimenNote'});
      }
    }

    push(@spec_grp_entry_sql_list, qq|(${specimen_group_id},${specimen_id},${specimen_note})|);
  }

  if (scalar(@spec_grp_entry_sql_list) > 0) {

    my $spec_grp_entry_sql = q|INSERT INTO specimengroupentry(SpecimenGroupId,SpecimenId,SpecimenNote) VALUES |;
    $spec_grp_entry_sql   .= join(',', @spec_grp_entry_sql_list);

    $self->logger->debug("Specimen Group Entry SQL: $spec_grp_entry_sql");

    my $specimen_group_sth = $dbh_write->prepare($spec_grp_entry_sql);
    $specimen_group_sth->execute();

    if ($dbh_write->err()) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }
    $specimen_group_sth->finish();
  }

  $dbh_write->disconnect();

  my $info_msg_aref  = [{'Message' => "SpecimenGroup ($specimen_group_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$specimen_group_id", 'ParaName' => 'SpecimenGroupId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_specimen_group {

  my $self              = $_[0];
  my $extra_attr_yes    = $_[1];
  my $sql               = $_[2];
  my $where_para_aref   = $_[3];
  my $extra_param       = 0;

  if (defined $_[4]) {

    $extra_param = $_[4];
  }

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

  my @extra_attr_specimen_group_data;

  my $spec_grp_id_aref = [];

  my $group_id_href    = {};

  my $group_lookup      = {};
  my $spec_lookup       = {};
  my $spec_count_lookup = {};

  if ($extra_attr_yes) {

    for my $specimen_group_row (@{$data_aref}) {

      push(@{$spec_grp_id_aref}, $specimen_group_row->{'SpecimenGroupId'});

      if (defined $specimen_group_row->{'OwnGroupId'}) {

        $group_id_href->{$specimen_group_row->{'OwnGroupId'}} = 1;
      }

      if (defined $specimen_group_row->{'AccessGroupId'}) {

        $group_id_href->{$specimen_group_row->{'AccessGroupId'}} = 1;
      }
    }

    if (scalar(keys(%{$group_id_href})) > 0) {

      my $group_sql    = 'SELECT SystemGroupId, SystemGroupName FROM systemgroup ';
      $group_sql      .= 'WHERE SystemGroupId IN (' . join(',', keys(%{$group_id_href})) . ')';

      $self->logger->debug("GROUP_SQL: $group_sql");
      $group_lookup = $dbh->selectall_hashref($group_sql, 'SystemGroupId');
    }

    if ( $extra_param ) {

      if (scalar(@{$spec_grp_id_aref}) > 0) {

        my $specimen_sql = 'SELECT SpecimenGroupId, specimengroupentry.SpecimenId, ';
        $specimen_sql   .= 'specimengroupentry.SpecimenNote, specimen.SpecimenName FROM specimengroupentry ';
        $specimen_sql   .= 'LEFT JOIN specimen ON specimengroupentry.SpecimenId = specimen.SpecimenId ';
        $specimen_sql   .= 'WHERE SpecimenGroupId IN (' . join(',', @{$spec_grp_id_aref}) . ')';

        my ($read_err, $read_msg, $specimen_id_aref) = read_data($dbh, $specimen_sql, []);

        if ($read_err) {

          return ($read_err, $read_msg, []);
        }

        for my $spec_row (@{$specimen_id_aref}) {

          my $spec_grp_id = $spec_row->{'SpecimenGroupId'};

          if (defined $spec_lookup->{$spec_grp_id}) {

            my $spec_aref = $spec_lookup->{$spec_grp_id};
            delete($spec_row->{'SpecimenGroupId'});
            push(@{$spec_aref}, $spec_row);
            $spec_lookup->{$spec_grp_id} = $spec_aref;
          }
          else {

            delete($spec_row->{'SpecimenGroupId'});
            $spec_lookup->{$spec_grp_id} = [$spec_row];
          }
        }
      }
    }

    if (scalar(@{$spec_grp_id_aref}) > 0) {

      my $count_spec_sql   = "SELECT SpecimenGroupId, COUNT(*) AS NumOfSpecimens ";
      $count_spec_sql     .= "FROM specimengroupentry ";
      $count_spec_sql     .= 'WHERE SpecimenGroupId IN (' . join(',', @{$spec_grp_id_aref}) . ')';

      $self->logger->debug("COUNT SPECIMEN: $count_spec_sql");
      $spec_count_lookup = $dbh->selectall_hashref($count_spec_sql, 'SpecimenGroupId');
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

  for my $specimen_group_row (@{$data_aref}) {

    my $specimen_group_id = $specimen_group_row->{'SpecimenGroupId'};

    my $own_grp_id   = $specimen_group_row->{'OwnGroupId'};
    my $acc_grp_id   = $specimen_group_row->{'AccessGroupId'};
    my $own_perm     = $specimen_group_row->{'OwnGroupPerm'};
    my $acc_perm     = $specimen_group_row->{'AccessGroupPerm'};
    my $oth_perm     = $specimen_group_row->{'OtherPerm'};
    my $ulti_perm    = $specimen_group_row->{'UltimatePerm'};

    if ($extra_attr_yes) {

      if ($extra_param) {

        if (defined $spec_lookup->{$specimen_group_id}) {

          my $specimen_aref  = [];

          my $specimen_id_aref = $spec_lookup->{$specimen_group_id};

          for my $specimen_info (@{$specimen_id_aref}) {

            my $specimen_id = $specimen_info->{'SpecimenId'};

            if ( ($ulti_perm & $READ_WRITE_PERM) == $READ_WRITE_PERM ) {

              $specimen_info->{'removeSpecimen'} = "specimengroup/${specimen_group_id}/remove/specimen/$specimen_id";
            }

            push(@{$specimen_aref}, $specimen_info);
          }

          $specimen_group_row->{'Specimen'} = $specimen_aref;
        }
      }

      if (defined $spec_count_lookup->{$specimen_group_id}->{'NumOfSpecimens'}) {

        $specimen_group_row->{'NumOfSpecimens'} = $spec_count_lookup->{$specimen_group_id}->{'NumOfSpecimens'};
      }
      else {

        $specimen_group_row->{'NumOfSpecimens'} = 0;
      }

      $specimen_group_row->{'OwnGroupName'}          = $group_lookup->{$own_grp_id}->{'SystemGroupName'};
      $specimen_group_row->{'AccessGroupName'}       = $group_lookup->{$acc_grp_id}->{'SystemGroupName'};
      $specimen_group_row->{'OwnGroupPermission'}    = $perm_lookup->{$own_perm};
      $specimen_group_row->{'AccessGroupPermission'} = $perm_lookup->{$acc_perm};
      $specimen_group_row->{'OtherPermission'}       = $perm_lookup->{$oth_perm};
      $specimen_group_row->{'UltimatePermission'}    = $perm_lookup->{$ulti_perm};

      if (($ulti_perm & $READ_WRITE_PERM) == $READ_WRITE_PERM) {

        $specimen_group_row->{'update'}      = "update/specimengroup/$specimen_group_id";
        $specimen_group_row->{'addSpecimen'} = "specimengroup/${specimen_group_id}/add/specimen";
      }

      if ($own_grp_id == $group_id) {

        $specimen_group_row->{'chgPerm'} = "specimengroup/${specimen_group_id}/change/permission";

        if ($gadmin_status eq '1') {

          $specimen_group_row->{'chgOwner'} = "specimengroup/${specimen_group_id}/change/owner";
          $specimen_group_row->{'delete'}   = "delete/specimengroup/$specimen_group_id";
        }
      }
    }

    push(@extra_attr_specimen_group_data, $specimen_group_row);
  }

  $dbh->disconnect();

  return ($err, $msg, \@extra_attr_specimen_group_data);
}

sub list_specimen_group_advanced_runmode {

=pod list_specimen_group_advanced_HELP_START
{
"OperationName": "List specimen groups",
"Description": "List existing specimen groups.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination NumPerPage='2' NumOfRecords='17' NumOfPages='9' Page='1' /><RecordMeta TagName='SpecimenGroup' /><SpecimenGroup SpecimenGroupNote='Testing Note' OtherPerm='0' AccessGroupId='0' NumOfSpecimens='4' addSpecimen='specimengroup/19/add/specimen' OwnGroupName='admin' AccessGroupPermission='Read/Link' SpecimenGroupName='UPDATE Specimen_41394913362' SpecimenGroupStatus='513' AccessGroupPerm='5' update='update/specimengroup/19' SpecimenGroupStatusName='SpecimenGroupStatus - 44488335532' chgPerm='specimengroup/19/change/permission' chgOwner='specimengroup/19/change/owner' SpecimenGroupTypeId='525' SpecimenGroupLastUpdate='2017-06-28 15:21:49' SpecimenGroupCreated='2015-08-07 00:00:00' SpecimenGroupTypeName='SpecimenGroupType - 00976892378' delete='delete/specimengroup/19' UltimatePermission='Read/Write/Link' OwnGroupId='0' AccessGroupName='admin' SpecimenGroupId='19' OtherPermission='None' OwnGroupPerm='7' OwnGroupPermission='Read/Write/Link' UltimatePerm='7' /><SpecimenGroup AccessGroupName='admin' SpecimenGroupId='18' OwnGroupId='0' OwnGroupPerm='7' OwnGroupPermission='Read/Write/Link' UltimatePerm='7' OtherPermission='None' SpecimenGroupName='SpecimenGroup_83626115868' SpecimenGroupStatus='513' AccessGroupPerm='5' update='update/specimengroup/18' OtherPerm='0' SpecimenGroupNote='' OwnGroupName='admin' NumOfSpecimens='0' AccessGroupId='0' addSpecimen='specimengroup/18/add/specimen' AccessGroupPermission='Read/Link' SpecimenGroupTypeName='SpecimenGroupType - 97389013571' SpecimenGroupCreated='2015-08-07 00:00:00' delete='delete/specimengroup/18' UltimatePermission='Read/Write/Link' chgOwner='specimengroup/18/change/owner' SpecimenGroupStatusName='SpecimenGroupStatus - 44488335532' chgPerm='specimengroup/18/change/permission' SpecimenGroupLastUpdate='' SpecimenGroupTypeId='512' /><StatInfo ServerElapsedTime='0.013' Unit='second' /></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'Page' : '1','NumOfPages' : 9,'NumPerPage' : '2','NumOfRecords' : '17'}],'RecordMeta' : [{'TagName' : 'SpecimenGroup'}],'SpecimenGroup' : [{'SpecimenGroupTypeId' : '525','SpecimenGroupLastUpdate' : '2017-06-28 15:21:49','chgPerm' : 'specimengroup/19/change/permission','chgOwner' : 'specimengroup/19/change/owner','SpecimenGroupStatusName' : 'SpecimenGroupStatus - 44488335532','UltimatePermission' : 'Read/Write/Link','delete' : 'delete/specimengroup/19','SpecimenGroupCreated' : '2015-08-07 00:00:00','SpecimenGroupTypeName' : 'SpecimenGroupType - 00976892378','addSpecimen' : 'specimengroup/19/add/specimen','OwnGroupName' : 'admin','AccessGroupPermission' : 'Read/Link','AccessGroupId' : '0','NumOfSpecimens' : '4','OtherPerm' : '0','SpecimenGroupNote' : 'Testing Note','update' : 'update/specimengroup/19','AccessGroupPerm' : '5','SpecimenGroupStatus' : '513','SpecimenGroupName' : 'UPDATE Specimen_41394913362','OtherPermission' : 'None','UltimatePerm' : '7','OwnGroupPermission' : 'Read/Write/Link','OwnGroupPerm' : '7','OwnGroupId' : '0','SpecimenGroupId' : '19','AccessGroupName' : 'admin'},{'SpecimenGroupStatus' : '513','SpecimenGroupName' : 'SpecimenGroup_83626115868','update' : 'update/specimengroup/18','AccessGroupPerm' : '5','OtherPerm' : '0','SpecimenGroupNote' : null,'OwnGroupName' : 'admin','addSpecimen' : 'specimengroup/18/add/specimen','AccessGroupPermission' : 'Read/Link','AccessGroupId' : '0','NumOfSpecimens' : 0,'delete' : 'delete/specimengroup/18','SpecimenGroupCreated' : '2015-08-07 00:00:00','SpecimenGroupTypeName' : 'SpecimenGroupType - 97389013571','UltimatePermission' : 'Read/Write/Link','chgPerm' : 'specimengroup/18/change/permission','chgOwner' : 'specimengroup/18/change/owner','SpecimenGroupStatusName' : 'SpecimenGroupStatus - 44488335532','SpecimenGroupLastUpdate' : null,'SpecimenGroupTypeId' : '512','SpecimenGroupId' : '18','AccessGroupName' : 'admin','OwnGroupId' : '0','OwnGroupPerm' : '7','OwnGroupPermission' : 'Read/Write/Link','UltimatePerm' : '7','OtherPermission' : 'None'}],'StatInfo' : [{'ServerElapsedTime' : '0.010','Unit' : 'second'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"URLParameter": [{"ParameterName": "nperpage", "Description": "Number of records in a page for pagination"}, {"ParameterName": "num", "Description": "The page number of the pagination"}],
"HTTPParameter": [{"Required": 0, "Name": "Filtering", "Description": "Filtering parameter string consisting of filtering expressions which are separated by ampersand (&) which needs to be encoded if HTTP GET method is used. Each filtering expression is composed of a database field name, a filtering operator and the filtering value."}, {"Required": 0, "Name": "FieldList", "Description": "Comma separated value of wanted fields."}, {"Required": 0, "Name": "Sorting", "Description": "Comma separated value of SQL sorting phrases."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self    = shift;

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

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'specimengroup');

  my $data_for_postrun_href = {};

  my $sql = 'SELECT * FROM specimengroup LIMIT 1';

  my ($samp_spec_grp_err, $samp_spec_grp_msg, $samp_spec_grp_data) = $self->list_specimen_group(0, $sql);

  if ($samp_spec_grp_err) {

    $self->logger->debug("Get sample specimen group failed: $samp_spec_grp_msg");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $dbh = connect_kdb_read();

  my $sample_data_aref = $samp_spec_grp_data;

  my @field_list_all;

  if (scalar(@{$sample_data_aref}) == 1) {

    @field_list_all = keys(%{$sample_data_aref->[0]});
  }
  else {

    $self->logger->debug("It reaches here");
    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'specimengroup');

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
                                                                                   'SpecimenGroupId' );
    if ($sel_field_err) {

      my $err_msg = $sel_field_msg;
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    $final_field_list = $sel_field_list;
  }

  my $field_lookup = {};
  for my $fd_name (@{$final_field_list}) {

    $field_lookup->{$fd_name} = 1;
  }

  my $join = ' LEFT JOIN specimengroupentry ON specimengroup.SpecimenGroupId = specimengroupentry.SpecimenGroupId ';

  for my $field (@{$final_field_list}) {

    if ($field eq 'SpecimenGroupTypeId') {

      push(@{$final_field_list}, 'generaltype.TypeName AS SpecimenGroupTypeName');
      $join .= ' LEFT JOIN generaltype ON specimengroup.SpecimenGroupTypeId = generaltype.TypeId';
    }

    if ($field eq 'SpecimenGroupStatus') {

      push(@{$final_field_list}, 'generaltypestatus.TypeName AS SpecimenGroupStatusName');
      $join .= ' LEFT JOIN generaltype AS generaltypestatus ON specimengroup.SpecimenGroupStatus = generaltypestatus.TypeId';
    }
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

  if ($filtering_csv =~ /SpecimenId/) {

    push(@{$final_field_list}, 'SpecimenId');
  }

  my $field_name2table_name  = { 'SpecimenId' => 'specimengroupentry' };
  my $validation_func_lookup = {};

  push(@{$final_field_list}, "$perm_str AS UltimatePerm");

  $self->logger->debug("Final field list: " . join(',', @{$final_field_list}));

  my @sql_field_list;

  for my $field_name (@{$final_field_list}) {

    if ($field_name ne 'SpecimenId') {

      push(@sql_field_list, $field_name);
    }
  }

  $sql  = 'SELECT ' . join(',', @sql_field_list) . ' ';

  # SpecimenGroupId is ambiguous so it needs a table name at the front

  $sql =~ s/SpecimenGroupId/specimengroup.SpecimenGroupId/;

  $sql .= "FROM specimengroup $join ";

  my ( $filter_err, $filter_msg, $filter_phrase, $where_arg ) = parse_filtering('SpecimenGroupId',
                                                                                'specimengroup',
                                                                                $filtering_csv,
                                                                                $final_field_list,
                                                                                $validation_func_lookup,
                                                                                $field_name2table_name);
  if ($filter_err) {

    $self->logger->debug("Parse filtering failed: $filter_msg");
    my $err_msg = $filter_msg;

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $filter_where_phrase = '';
  if (length($filter_phrase) > 0) {

    $filter_where_phrase = " AND $filter_phrase ";
  }

  my $filtering_exp = " WHERE (($perm_str) & $READ_PERM) = $READ_PERM $filter_where_phrase ";

  $sql .= " $filtering_exp ";

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

    my $count_sql = "SELECT COUNT(DISTINCT specimengroup.SpecimenGroupId) ";
    $count_sql   .= "FROM specimengroup ";
    $count_sql   .= "LEFT JOIN specimengroupentry ON specimengroup.SpecimenGroupId = specimengroupentry.SpecimenGroupId ";
    $count_sql   .= "$filtering_exp";

    $self->logger->debug("COUNT SQL: $count_sql");

    my ($paged_id_err, $paged_id_msg, $nb_records,
        $nb_pages, $limit_clause, $sql_count_time) = get_paged_filter_sql($dbh,
                                                                          $nb_per_page,
                                                                          $page,
                                                                          $count_sql,
                                                                          $where_arg);

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

  $sql  =~ s/SELECT/SELECT DISTINCT /;

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

    $sql .= " ORDER BY specimengroup.SpecimenGroupId DESC ";
  }

  $sql .= " $paged_limit_clause ";

  $self->logger->debug("Final list specimengroup SQL: $sql");

  my ($spec_grp_err, $spec_grp_msg, $spec_grp_data) = $self->list_specimen_group(1, $sql, $where_arg, 0);

  if ($spec_grp_err) {

    $self->logger->debug("Get specimen group failed: $spec_grp_msg");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'SpecimenGroup' => $spec_grp_data,
                                           'Pagination'    => $pagination_aref,
                                           'RecordMeta'    => [{'TagName' => 'SpecimenGroup'}],
  };

  return $data_for_postrun_href;
}

sub get_specimen_group_runmode {

=pod get_specimen_group_HELP_START
{
"OperationName": "Get specimen group",
"Description": "Get detailed information about specimen group specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><SpecimenGroup SpecimenGroupId='17' AccessGroupName='admin' OwnGroupId='0' OwnGroupPerm='7' OwnGroupPermission='Read/Write/Link' UltimatePerm='7' OtherPermission='None' SpecimenGroupStatus='SpecimenGroupStatus - 44488335532' SpecimenGroupName='SpecimenGroup_23466523131' update='update/specimengroup/17' AccessGroupPerm='5' OtherPerm='0' SpecimenGroupNote='' NumOfSpecimens='2' AccessGroupId='0' OwnGroupName='admin' AccessGroupPermission='Read/Link' addSpecimen='specimengroup/17/add/specimen' SpecimenGroupTypeName='SpecimenGroupType - 97389013571' SpecimenGroupCreated='2015-08-07 00:00:00' delete='delete/specimengroup/17' UltimatePermission='Read/Write/Link' chgOwner='specimengroup/17/change/owner' chgPerm='specimengroup/17/change/permission' SpecimenGroupLastUpdate='' SpecimenGroupTypeId='512'><Specimen SpecimenId='1770' SpecimenNote='TrialOrigin (testing)' SpecimenName='Specimen4TrialUnit_85773855213' removeSpecimen='specimengroup/17/remove/specimen/1770' /><Specimen SpecimenId='1771' SpecimenNote='' SpecimenName='Specimen4TrialUnit_92717617794' removeSpecimen='specimengroup/17/remove/specimen/1771' /></SpecimenGroup><StatInfo ServerElapsedTime='0.007' Unit='second' /><RecordMeta TagName='SpecimenGroup' /></DATA>",
"SuccessMessageJSON": "{'SpecimenGroup' : [{'SpecimenGroupId' : '17','AccessGroupName' : 'admin','OwnGroupId' : '0','Specimen' : [{'removeSpecimen' : 'specimengroup/17/remove/specimen/1770','SpecimenName' : 'Specimen4TrialUnit_85773855213','SpecimenId' : '1770','SpecimenNote' : 'TrialOrigin (testing)'},{'SpecimenNote' : null,'SpecimenId' : '1771','removeSpecimen' : 'specimengroup/17/remove/specimen/1771','SpecimenName' : 'Specimen4TrialUnit_92717617794'}],'OwnGroupPerm' : '7','UltimatePerm' : '7','OwnGroupPermission' : 'Read/Write/Link','OtherPermission' : 'None','SpecimenGroupStatus' : 'SpecimenGroupStatus - 44488335532','SpecimenGroupName' : 'SpecimenGroup_23466523131','AccessGroupPerm' : '5','update' : 'update/specimengroup/17','OtherPerm' : '0','SpecimenGroupNote' : null,'addSpecimen' : 'specimengroup/17/add/specimen','AccessGroupPermission' : 'Read/Link','OwnGroupName' : 'admin','AccessGroupId' : '0','NumOfSpecimens' : '2','SpecimenGroupTypeName' : 'SpecimenGroupType - 97389013571','delete' : 'delete/specimengroup/17','SpecimenGroupCreated' : '2015-08-07 00:00:00','UltimatePermission' : 'Read/Write/Link','chgPerm' : 'specimengroup/17/change/permission','chgOwner' : 'specimengroup/17/change/owner','SpecimenGroupLastUpdate' : null,'SpecimenGroupTypeId' : '512'}],'StatInfo' : [{'ServerElapsedTime' : '0.006','Unit' : 'second'}],'RecordMeta' : [{'TagName' : 'SpecimenGroup'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='SpecimenGroup (10) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'SpecimenGroup (10) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SpecimenGroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self         = shift;
  my $specimen_grp_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  my $specimen_grp_exist = record_existence($dbh, 'specimengroup', 'SpecimenGroupId', $specimen_grp_id);

  if (!$specimen_grp_exist) {

    my $err_msg = "SpecimenGroup ($specimen_grp_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str      = permission_phrase($group_id, 0, $gadmin_status, 'specimengroup');

  my $sql = "SELECT $perm_str as UltimatePerm ";
  $sql   .= "FROM specimengroup ";
  $sql   .= "WHERE SpecimenGroupId=?";

  my ($r_spec_grp_err, $spec_grp_perm) = read_cell($dbh, $sql, [$specimen_grp_id]);

  if ( ($spec_grp_perm & $READ_PERM) != $READ_PERM ) {

    my $err_msg = "SpecimenGroup ($specimen_grp_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  $sql    = 'SELECT specimengroup.*, generaltype.TypeName AS SpecimenGroupTypeName, ';
  $sql   .= 'generaltypestatus.TypeName AS SpecimenGroupStatus, ';
  $sql   .= "$perm_str AS UltimatePerm ";
  $sql   .= 'FROM specimengroup LEFT JOIN generaltype ON ';
  $sql   .= 'specimengroup.SpecimenGroupTypeId = generaltype.TypeId ';
  $sql   .= 'LEFT JOIN generaltype AS generaltypestatus ON specimengroup.SpecimenGroupStatus = generaltypestatus.TypeId ';
  $sql   .= "WHERE (($perm_str) & $READ_PERM) = $READ_PERM AND SpecimenGroupId=?";

  my ($specimen_grp_err, $specimen_grp_msg, $specimen_grp_data) = $self->list_specimen_group(1, $sql, [$specimen_grp_id], 1);

  if ($specimen_grp_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'SpecimenGroup' => $specimen_grp_data,
                                           'RecordMeta' => [{'TagName' => 'SpecimenGroup'}],
  };

  return $data_for_postrun_href;
}

sub update_specimen_group_runmode {

=pod update_specimen_group_gadmin_HELP_START
{
"OperationName": "Update specimen group",
"Description": "Update information about specimen group specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "specimengroup",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='SpecimenGroup (9) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'SpecimenGroup (9) has been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='SpecimenGroup (10): not found.' /></DATA>" }],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'SpecimenGroup (10): not found.'}]}" }],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SpecimenGroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self            = shift;
  my $specimen_grp_id = $self->param('id');
  my $query           = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = { 'OwnGroupId'           => 1,
                     'AccessGroupId'        => 1,
                     'OwnGroupPerm'         => 1,
                     'AccessGroupPerm'      => 1,
                     'OtherPerm'            => 1,
                     'SpecimenGroupCreated' => 1,
                   };

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'specimengroup', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $dbh_write = connect_kdb_write();

  my $specimen_grp_exist = record_existence($dbh_write, 'specimengroup', 'SpecimenGroupId', $specimen_grp_id);

  if (!$specimen_grp_exist) {

    my $err_msg = "SpecimenGroup ($specimen_grp_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str      = permission_phrase($group_id, 0, $gadmin_status);

  my $sql = "SELECT $perm_str As UltimatePerm ";
  $sql   .= 'FROM specimengroup ';
  $sql   .= 'WHERE SpecimenGroupId=?';

  my ($r_perm_err, $spec_grp_perm) = read_cell($dbh_write, $sql, [$specimen_grp_id]);

  if ($r_perm_err) {

    $self->logger->debug("Read specimen group permission failed.");
    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( ($spec_grp_perm & $READ_WRITE_PERM) != $READ_WRITE_PERM ) {

    my $err_msg = "SpecimenGroup ($specimen_grp_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $specimen_group_name         = $query->param('SpecimenGroupName');
  my $specimen_group_type_id      = $query->param('SpecimenGroupTypeId');

  if (!type_existence($dbh_write, 'specimengroup', $specimen_group_type_id)) {

    my $err_msg = "SpecimenGroupTypeId ($specimen_group_type_id): not found or active.";
    return $self->_set_error($err_msg);
  }

  my $chk_spec_grp_name_sql = 'SELECT SpecimenGroupId FROM specimengroup ';
  $chk_spec_grp_name_sql   .= 'WHERE SpecimenGroupId <> ? AND SpecimenGroupName = ?';

  my ($r_chk_spec_grp_name_err, $duplicate_spec_grp_id) = read_cell($dbh_write, $chk_spec_grp_name_sql,
                                                                    [$specimen_grp_id, $specimen_group_name]);

  if (length($duplicate_spec_grp_id) > 0) {

    my $err_msg = "SpecimenGroupName ($specimen_group_name): already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $read_sql     =  'SELECT SpecimenGroupNote, SpecimenGroupStatus ';
     $read_sql    .=  'FROM specimengroup WHERE SpecimenGroupId=? ';

  my ($r_df_val_err, $r_df_val_msg, $specimen_df_val_data) = read_data($dbh_write, $read_sql, [$specimen_grp_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve specimen group default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $specimen_group_note   = undef;
  my $specimen_group_status = undef;

  my $nb_df_val_rec      =  scalar(@{$specimen_df_val_data});

  if ($nb_df_val_rec != 1) {

     $self->logger->debug("Retrieve specimen group default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;

  }

  $specimen_group_note   =   $specimen_df_val_data->[0]->{'SpecimenGroupNote'};
  $specimen_group_status =   $specimen_df_val_data->[0]->{'SpecimenGroupStatus'};

  if (defined $query->param('SpecimenGroupNote')) {

    if (length($query->param('SpecimenGroupNote')) > 0) {

      $specimen_group_note = $query->param('SpecimenGroupNote');
    }
  }

  if (defined $query->param('SpecimenGroupStatus')) {

    if (length($query->param('SpecimenGroupStatus')) > 0) {

      $specimen_group_status = $query->param('SpecimenGroupStatus');
    }
  }

  if (defined $specimen_group_status) {

    if (!type_existence($dbh_write, 'specimengroupstatus', $specimen_group_status)) {

      my $err_msg = "SpecimenGroupStatus ($specimen_group_status): not found or active.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'SpecimenGroupStatus' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $cur_dt = DateTime->now( time_zone => $TIMEZONE );
  $cur_dt = DateTime::Format::MySQL->format_datetime($cur_dt);

  $sql    = 'UPDATE specimengroup SET ';
  $sql   .= 'SpecimenGroupStatus=?, ';
  $sql   .= 'SpecimenGroupTypeId=?, ';
  $sql   .= 'SpecimenGroupName=?, ';
  $sql   .= 'SpecimenGroupNote=?, ';
  $sql   .= 'SpecimenGroupLastUpdate=? ';
  $sql   .= 'WHERE SpecimenGroupId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($specimen_group_status, $specimen_group_type_id, $specimen_group_name, $specimen_group_note,
                $cur_dt, $specimen_grp_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "SpecimenGroup ($specimen_grp_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub remove_specimen_from_specimen_group_runmode {

=pod remove_specimen_from_specimen_group_gadmin_HELP_START
{
"OperationName": "Remove specimen from specimen group",
"Description": "Removes specimen specified by id from a specimen group.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Specimen (451) has been removed from SpecimenGroup (8) successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Specimen (450) has been removed from SpecimenGroup (8) successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='SpecimenId (450) not found in SpecimenGroup (8).' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'SpecimenId (450) not found in SpecimenGroup (8).'}]}"}],
"URLParameter": [{"ParameterName": "specgrpid", "Description": "Existing SpecimenGroupId"}, {"ParameterName": "specid", "Description": "SpecimenId which is part of the SpecimenGroupId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self         = shift;
  my $specimen_grp_id = $self->param('specgrpid');
  my $specimen_id     = $self->param('specid');

  my $data_for_postrun_href = {};

  my $dbh_write = connect_kdb_write();

  my $specimen_grp_exist = record_existence($dbh_write, 'specimengroup', 'SpecimenGroupId', $specimen_grp_id);

  if (!$specimen_grp_exist) {

    my $err_msg = "SpecimenGroup ($specimen_grp_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str      = permission_phrase($group_id, 0, $gadmin_status);

  my $sql = "SELECT $perm_str As UltimatePerm ";
  $sql   .= 'FROM specimengroup ';
  $sql   .= 'WHERE SpecimenGroupId=?';

  my ($r_perm_err, $spec_grp_perm) = read_cell($dbh_write, $sql, [$specimen_grp_id]);

  if ($r_perm_err) {

    $self->logger->debug("Read specimen group permission failed.");
    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( ($spec_grp_perm & $READ_WRITE_PERM) != $READ_WRITE_PERM ) {

    my $err_msg = "SpecimenGroup ($specimen_grp_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql    = 'SELECT Count(*) ';
  $sql   .= 'FROM specimengroupentry ';
  $sql   .= 'WHERE SpecimenGroupId=? AND SpecimenId=?';

  my ($read_err, $count) = read_cell($dbh_write, $sql, [$specimen_grp_id, $specimen_id]);

  if ($count == 0) {

    my $err_msg = "SpecimenId ($specimen_id) not found in SpecimenGroup ($specimen_grp_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql    = 'DELETE FROM specimengroupentry ';
  $sql   .= 'WHERE SpecimenGroupId=? AND SpecimenId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($specimen_grp_id, $specimen_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $msg = "Specimen ($specimen_id) has been removed from SpecimenGroup ($specimen_grp_id) successfully.";
  my $info_msg_aref = [{'Message' => $msg}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub remove_specimen_from_specimen_group_bulk_runmode {

=pod remove_specimen_from_specimen_group_bulk_gadmin_HELP_START
{
"OperationName": "Remove a number of specimens from specimen group",
"Description": "Remove specimens specified by their ids in an upload XML file from a specimen group.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='SpecimenId (450,451,452) have been removed from SpecimenGroup (9) successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'SpecimenId (450,451,452) have been removed from SpecimenGroup (9) successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='SpecimenGroup (6) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'SpecimenGroup (6) not found.'}]}"}],
"URLParameter": [{"ParameterName": "specgrpid", "Description": "Existing SpecimenGroupId"}],
"RequiredUpload": 1,
"UploadFileFormat": "XML",
"UploadFileParameterName": "uploadfile",
"DTDFileNameForUploadXML": "specimengroup.dtd",
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self         = shift;
  my $specimen_grp_id = $self->param('specgrpid');

  my $data_for_postrun_href = {};

  my $dbh_write = connect_kdb_write();

  my $specimen_grp_exist = record_existence($dbh_write, 'specimengroup', 'SpecimenGroupId', $specimen_grp_id);

  if (!$specimen_grp_exist) {

    my $err_msg = "SpecimenGroup ($specimen_grp_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $specimen_info_xml_file = $self->authen->get_upload_file();
  my $specimen_info_dtd_file = $self->get_specimen_group_dtd_file();

  add_dtd($specimen_info_dtd_file, $specimen_info_xml_file);

  my $xml_checker_parser = new XML::Checker::Parser( Handlers => { } );

  eval {

    local $XML::Checker::FAIL = sub {

      my $code = shift;
      my $err_str = XML::Checker::error_string ($code, @_);
      $self->logger->debug("XML Parsing ERR: $code : $err_str");
      die $err_str;
    };
    $xml_checker_parser->parsefile($specimen_info_xml_file);
  };

  if ($@) {

    my $err_msg = $@;
    $self->logger->debug("Parsing XML error: $err_msg");
    my $user_err_msg = "Specimen group xml file does not comply with its definition.\n";
    $user_err_msg   .= "Details: $err_msg";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $user_err_msg}]};

    return $data_for_postrun_href;
  }

  my $specimen_info_xml  = read_file($specimen_info_xml_file);
  my $specimen_info_aref = xml2arrayref($specimen_info_xml, 'specimengroupentry');

  my $sql = '';
  my @specimen_id_list;
  for my $specimen_info (@{$specimen_info_aref}) {

    my $specimen_id = $specimen_info->{'SpecimenId'};

    $sql  = 'SELECT Count(*) ';
    $sql .= 'FROM specimengroupentry ';
    $sql .= 'WHERE SpecimenGroupId=? AND SpecimenId=?';

    my ($read_err, $count) = read_cell($dbh_write, $sql, [$specimen_grp_id, $specimen_id]);

    if ($count == 0) {

      my $err_msg = "SpecimenId ($specimen_id) not found in SpecimenGroup ($specimen_grp_id).";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    push(@specimen_id_list, $specimen_id);
  }

  if (scalar(@specimen_id_list) == 0) {

    my $err_msg = 'No specimen to remove.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $specimen_id_str = join(',', @specimen_id_list);

  $sql  = 'DELETE FROM specimengroupentry ';
  $sql .= "WHERE SpecimenGroupId=? AND SpecimenId IN ($specimen_id_str)";

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($specimen_grp_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $msg = "SpecimenId ($specimen_id_str) have been removed from SpecimenGroup ($specimen_grp_id) successfully.";
  my $info_msg_aref = [{'Message' => $msg}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_genotype_advanced_runmode {

=pod list_genotype_advanced_HELP_START
{
"OperationName": "List genotypes",
"Description": "Return list of genotypes. This listing requires pagination definition.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination NumOfRecords='673' NumOfPages='673' Page='1' NumPerPage='1' /><RecordMeta TagName='Genotype' /><Genotype AccessGroupPerm='5' AccessGroupId='0' GenotypeName='Geno_9005297' GenotypeId='675' AccessGroupPermission='Read/Link' OtherPermission='None' addAlias='genotype/675/add/alias' chgPerm='genotype/675/change/permission' OwnGroupPerm='7' OtherPerm='0' CanPublishGenotype='0' OriginId='0' GenotypeNote='none' SpeciesName='Testing' GenotypeColor='black' OwnGroupPermission='Read/Write/Link' OwnGroupName='admin' GenusName='Genus_7695634' GenusId='10' AccessGroupName='admin' GenotypeAcronym='T' chgOwner='genotype/675/change/owner' UltimatePermission='Read/Write/Link' OwnGroupId='0' update='update/genotype/675' UltimatePerm='7' /></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfRecords' : '673','NumOfPages' : 673,'NumPerPage' : '1','Page' : '1'}],'VCol' : [],'RecordMeta' : [{'TagName' : 'Genotype'}],'Genotype' : [{'AccessGroupPerm' : '5','AccessGroupId' : '0','GenotypeId' : '675','GenotypeName' : 'Geno_9005297','addAlias' : 'genotype/675/add/alias','OtherPermission' : 'None','AccessGroupPermission' : 'Read/Link','chgPerm' : 'genotype/675/change/permission','OwnGroupPerm' : '7','OtherPerm' : '0','CanPublishGenotype' : '0','OriginId' : '0','SpeciesName' : 'Testing','GenotypeNote' : 'none','GenotypeColor' : 'black','OwnGroupPermission' : 'Read/Write/Link','OwnGroupName' : 'admin','GenusId' : '10','GenusName' : 'Genus_7695634','AccessGroupName' : 'admin','GenotypeAcronym' : 'T','chgOwner' : 'genotype/675/change/owner','UltimatePermission' : 'Read/Write/Link','update' : 'update/genotype/675','OwnGroupId' : '0','UltimatePerm' : '7'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"URLParameter": [{"ParameterName": "nperpage", "Description": "Number of records in a page for pagination"}, {"ParameterName": "num", "Description": "The page number of the pagination"}],
"HTTPParameter": [{"Required": 0, "Name": "Filtering", "Description": "Filtering parameter string consisting of filtering expressions which are separated by ampersand (&) which needs to be encoded if HTTP GET method is used. Each filtering expression is composed of a database field name, a filtering operator and the filtering value."}, {"Required": 0, "Name": "FieldList", "Description": "Comma separated value of wanted fields."}, {"Required": 0, "Name": "Sorting", "Description": "Comma separated value of SQL sorting phrases."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $runmode_start_time = [gettimeofday()];
  my $data_for_postrun_href = {};

  my $pagination  = 0;
  my $nb_per_page = -1;
  my $page        = -1;
  my $debug_sfield = [];

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

  if (defined $self->param('genusid')) {

    my $genus_id = $self->param('genusid');

    if ($filtering_csv =~ /GenusId=(.*)&?/) {

      if ( "$genus_id" ne "$1" ) {
        my $err_msg = 'Duplicate filtering condition for GenusId.';
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
    else {
      if (length($filtering_csv) > 0) {
        if ($filtering_csv =~ /&$/) {
          $filtering_csv .= "GenusId=$genus_id";
        }
        else {
          $filtering_csv .= "&GenusId=$genus_id";
        }
      }
      else {
        $filtering_csv .= "GenusId=$genus_id";
      }
    }
  }

  $self->logger->debug("Filtering csv: $filtering_csv");

  my $sorting = '';

  if (defined $query->param('Sorting')) {
    $sorting = $query->param('Sorting');
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'genotype');

  my $dbh = connect_kdb_read();
  my $field_list = ['*', 'VCol*'];
  my $pre_data_other_join = '';

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_columns_sql($dbh, $field_list, 'genotype',
                                                                        'GenotypeId', '');

  $self->logger->debug("SQL with VCol: $sql");

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql   .= " LIMIT 1";

  $self->logger->debug("SQL with VCol: $sql");

  my ($sam_genotype_err, $sam_genotype_msg, $sam_genotype_data) = $self->list_genotype(0, $sql);

  if ($sam_genotype_err) {

    $self->logger->debug($sam_genotype_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $sample_data_aref = $sam_genotype_data;

  my @field_list_all;

  if (scalar(@{$sample_data_aref}) == 1) {

    @field_list_all = keys(%{$sample_data_aref->[0]});
  }
  else {

    $self->logger->debug("It reaches here");
    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'genotype');
    #$debug_sfield = $sfield_data;

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

  if (length($field_list_csv) > 0) {

    my ($sel_field_err, $sel_field_msg, $sel_field_list) = parse_selected_field($field_list_csv,
                                                                                $final_field_list,
                                                                                'GenotypeId');

    if ($sel_field_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;

    if ($filtering_csv =~ /GenusId/) {

      push(@{$final_field_list}, 'GenusId');
    }

    $sql_field_list       = [];

    for my $fd_name (@{$final_field_list}) {
      push(@{$sql_field_list}, $fd_name);
    }
  }
  else {
    for my $fd_name (@{$final_field_list}) {
      push(@{$sql_field_list}, $fd_name);
    }
  }

  my $sql_field_lookup = {};

  for my $fd_name (@{$sql_field_list}) {

    $sql_field_lookup->{$fd_name} = 1;
  }

  my $other_join = '';
  #$other_join   .= ' LEFT JOIN genus ON genotype.GenusId = genus.GenusId ';
  #$other_join   .= ' LEFT JOIN genpedigree ON genotype.GenotypeId = genpedigree.GenotypeId ';
  #$other_join   .= ' LEFT JOIN genotypealias ON genotype.GenotypeId = genotypealias.GenotypeId ';

  my $compulsory_perm_fields = ['OwnGroupId',
                                'AccessGroupId',
                                'OwnGroupPerm',
                                'AccessGroupPerm',
                                'OtherPerm',
      ];

  for my $com_fd_name (@{$compulsory_perm_fields}) {

    if (length($sql_field_lookup->{$com_fd_name}) == 0) {

      push(@{$sql_field_list}, $com_fd_name);
    }
  }

  push(@{$sql_field_list}, "$perm_str AS UltimatePerm");

  my @filtering_exp = split(/&/, $filtering_csv);

  my $seen_expression_lookup = {};

  my $factor_filtering_flag = test_filtering_factor($filtering_csv);

  if (!$factor_filtering_flag) {
    ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql_v3($dbh, $sql_field_list, 'genotype',
                                                                       'GenotypeId', $other_join);
  }
  else {
    ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql_v2($dbh, $sql_field_list, 'genotype',
                                                                          'GenotypeId', $other_join);
  }

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($filter_err, $filter_msg,
      $filter_phrase, $where_arg,
      $having_phrase, $count_filter_phrase,
      $nb_filter_factor);

  if ($GENOTYPEFACTORFILTERING_CFG == 1) {
    ($filter_err, $filter_msg,
        $filter_phrase, $where_arg,
        $having_phrase, $count_filter_phrase,
        $nb_filter_factor) = parse_filtering_v2('GenotypeId',
                                                'genotype',
                                                $filtering_csv,
                                                $final_field_list,
                                                $vcol_list,
                                                );

  }
  else {
    ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering('GenotypeId',
                                                                              'genotype',
                                                                              $filtering_csv,
                                                                              $final_field_list);
  }

  $self->logger->debug("Filter phrase: $filter_phrase");
  $self->logger->debug("Where argument: " . join(',', @{$where_arg}));

  if ($filter_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => "$filter_msg", "VCol" => $vcol_list}]};

    return $data_for_postrun_href;
  }

  my $filter_where_phrase = '';
  if (length($filter_phrase) > 0) {

    $filter_where_phrase = " AND $filter_phrase ";
  }

  my $filtering_exp = " WHERE (($perm_str) & $READ_PERM) = $READ_PERM $filter_where_phrase ";

  if (length($having_phrase) > 0) {

    $sql =~ s/FACTORHAVING/ HAVING $having_phrase/;

    $sql  =~ s/WHEREREPLACE GROUP BY/ $filtering_exp GROUP BY /;
  }
  else {

    $sql  =~ s/WHEREREPLACE GROUP BY/ $filtering_exp GROUP BY /;
  }

  my $pagination_aref    = [];
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

    my ($pg_id_err, $pg_id_msg, $nb_records,
        $nb_pages, $limit_clause, $rcount_time);

    if (length($having_phrase) == 0) {

      $self->logger->debug("COUNT NB RECORD: NO FACTOR IN FILTERING");

      my $sql_pag = "";



      ($pg_id_err, $pg_id_msg, $nb_records,
       $nb_pages, $limit_clause, $rcount_time,$sql_pag) = get_paged_filter($dbh,
                                                                  $nb_per_page,
                                                                  $page,
                                                                  'genotype',
                                                                  'GenotypeId',
                                                                  $filtering_exp,
                                                                  $where_arg);
    }
    else {

      $self->logger->debug("COUNT NB RECORD: FACTOR IN FILTERING");

      my $count_sql = "SELECT COUNT(genotype.GenotypeId) ";
      $count_sql   .= "FROM genotype INNER JOIN ";
      $count_sql   .= " (SELECT GenotypeId, COUNT(GenotypeId) ";
      $count_sql   .= " FROM genotypefactor WHERE $count_filter_phrase ";
      $count_sql   .= " GROUP BY GenotypeId HAVING COUNT(GenotypeId)=$nb_filter_factor) AS subq ";
      $count_sql   .= "ON genotype.GenotypeId = subq.GenotypeId ";
      $count_sql   .= "$filtering_exp";



      $self->logger->debug("COUNT SQL: $count_sql");

      ($pg_id_err, $pg_id_msg, $nb_records,
       $nb_pages, $limit_clause, $rcount_time) = get_paged_filter_sql($dbh,
                                                                      $nb_per_page,
                                                                      $page,
                                                                      $count_sql,
                                                                      $where_arg);

      $self->logger->debug("COUNT WITH Factor TIME: $rcount_time");
    }

    $self->logger->debug("SQL Row count time: $rcount_time");

    if ($pg_id_err == 1) {

      $self->logger->debug($pg_id_msg);

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => "$pg_id_msg"}]};

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

  my ($sort_err, $sort_msg, $sort_sql) = parse_sorting($sorting, $sql_field_list);

  if ($sort_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sort_msg}]};

    return $data_for_postrun_href;
  }

  my $final_sort_sql = "";

  if (length($sort_sql) > 0) {

    $final_sort_sql .= " ORDER BY $sort_sql ";

  }
  else {
    $final_sort_sql .= ' ORDER BY genotype.GenotypeId DESC';
  }

  $sql =~ s/ORDERINGSTRING/$final_sort_sql/;

  if ($pagination == 0) {
    if (defined $self->param('nperpage')) {
      $nb_per_page = $self->param('nperpage');

      $sql =~ s/LIMITSTRING/LIMIT  $nb_per_page/;
    }
    else {
      $sql =~ s/LIMITSTRING/LIMIT 50/;
    }
  }
  else {
    $sql =~ s/LIMITSTRING/$paged_limit_clause/;
  }

  $self->logger->debug("SQL with VCol: $sql");

  $self->logger->debug('Where arg: ' . join(',', @{$where_arg}));

  # where_arg here in the list function because of the filtering

  my ($read_genotype_err, $read_genotype_msg, $genotype_data) = $self->list_genotype(1,
                                                                         $sql,
                                                                         $where_arg);

  if ($read_genotype_err) {

    $self->logger->debug($read_genotype_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $read_genotype_msg, 'Limit' => $pagination }]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}  = {'Genotype'   => $genotype_data,
                                       'VCol'       => $vcol_list,
                                       'Pagination' => $pagination_aref,
                                       'RecordMeta' => [{'TagName' => 'Genotype'}],
                                     };

  return $data_for_postrun_href;
}




sub add_specimen2specimen_group_runmode {

=pod add_specimen2specimen_group_gadmin_HELP_START
{
"OperationName": "Add specimens to specimen group",
"Description": "Add a number of specimens to a specimen group.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='SpecimenId (450,451) have been added to SpecimenGroup (8) successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'SpecimenId (450,451) have been added to SpecimenGroup (8) successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Specimen (45224,45387): not found' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Specimen (45224,45387): not found'}]}"}],
"URLParameter": [{"ParameterName": "specgrpid", "Description": "Existing SpecimenGroupId"}],
"RequiredUpload": 1,
"UploadFileFormat": "XML",
"UploadFileParameterName": "uploadfile",
"DTDFileNameForUploadXML": "specimengroup.dtd",
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self         = shift;
  my $specimen_grp_id = $self->param('specgrpid');

  my $data_for_postrun_href = {};

  my $dbh_write = connect_kdb_write();

  my $specimen_grp_exist = record_existence($dbh_write, 'specimengroup', 'SpecimenGroupId', $specimen_grp_id);

  if (!$specimen_grp_exist) {

    my $err_msg = "SpecimenGroup ($specimen_grp_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str      = permission_phrase($group_id, 0, $gadmin_status);

  my $sql = "SELECT $perm_str As UltimatePerm ";
  $sql   .= 'FROM specimengroup ';
  $sql   .= 'WHERE SpecimenGroupId=?';

  my ($r_perm_err, $spec_grp_perm) = read_cell($dbh_write, $sql, [$specimen_grp_id]);

  if ($r_perm_err) {

    $self->logger->debug("Read specimen group permission failed.");
    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( ($spec_grp_perm & $READ_WRITE_PERM) != $READ_WRITE_PERM ) {

    my $err_msg = "SpecimenGroup ($specimen_grp_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $specimen_info_xml_file = $self->authen->get_upload_file();
  my $specimen_info_dtd_file = $self->get_specimen_group_dtd_file();

  add_dtd($specimen_info_dtd_file, $specimen_info_xml_file);

  my $xml_checker_parser = new XML::Checker::Parser( Handlers => { } );

  eval {

    local $XML::Checker::FAIL = sub {

      my $code = shift;
      my $err_str = XML::Checker::error_string ($code, @_);
      $self->logger->debug("XML Parsing ERR: $code : $err_str");
      die $err_str;
    };
    $xml_checker_parser->parsefile($specimen_info_xml_file);
  };

  if ($@) {

    my $err_msg = $@;
    $self->logger->debug("Parsing XML error: $err_msg");
    my $user_err_msg = "Specimen group xml file does not comply with its definition.\n";
    $user_err_msg   .= "Details: $err_msg";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $user_err_msg}]};

    return $data_for_postrun_href;
  }

  my $specimen_info_xml  = read_file($specimen_info_xml_file);
  my $specimen_info_aref = xml2arrayref($specimen_info_xml, 'specimengroupentry');

  my $geno_perm_str  = permission_phrase($group_id, 0, $gadmin_status, 'genotype');

  my $spec_id_sql = 'SELECT SpecimenId, SpecimenGroupEntryId ';
  $spec_id_sql   .= 'FROM specimengroupentry ';
  $spec_id_sql   .= "WHERE SpecimenGroupId=$specimen_grp_id";

  my $spec_id_db_lookup = $dbh_write->selectall_hashref($spec_id_sql, 'SpecimenId');

  if ($dbh_write->err()) {

    $self->logger->debug("Read specimen id failed: " . $dbh_write->errstr());

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $uniq_spec_id_href = {};

  for my $specimen_info (@{$specimen_info_aref}) {

    my $spec_id = $specimen_info->{'SpecimenId'};

    if (defined $uniq_spec_id_href->{$spec_id}) {

      my $err_msg = "Specimen ($spec_id): duplicate.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    else {

      if (defined $spec_id_db_lookup->{$spec_id}) {

        my $err_msg = "Specimen ($spec_id): already exists in SpecimenGroup ($specimen_grp_id).";

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
      else {

        $uniq_spec_id_href->{$spec_id} = 1;
      }
    }
  }

  my @spec_id_list = keys(%{$uniq_spec_id_href});

  if (scalar(@spec_id_list) > 0) {

    my $specimen_geno_sql = 'SELECT genotypespecimen.SpecimenId, Count(genotypespecimen.GenotypeId) ';
    $specimen_geno_sql   .= 'FROM genotypespecimen LEFT JOIN genotype ON ';
    $specimen_geno_sql   .= 'genotypespecimen.GenotypeId = genotype.GenotypeId ';
    $specimen_geno_sql   .= 'WHERE genotypespecimen.SpecimenId IN (' . join(',', @spec_id_list) . ') ';
    $specimen_geno_sql   .= 'GROUP BY genotypespecimen.SpecimenId';

    my $normal_geno_count_lookup = $dbh_write->selectall_hashref($specimen_geno_sql, 'SpecimenId');

    if ($dbh_write->err()) {

      $self->logger->debug("Read genotype count failed: " . $dbh_write->errstr());

      my $err_msg = "Unexpected Error.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $not_found_specimen_id_aref = [];

    for my $spec_id (@spec_id_list) {

      if ( !(defined $normal_geno_count_lookup->{$spec_id}) ) {

        push(@{$not_found_specimen_id_aref}, $spec_id);
      }
    }

    if (scalar(@{$not_found_specimen_id_aref}) > 0) {

      my $err_msg = "Specimen (" . join(',', @{$not_found_specimen_id_aref}) . "): not found";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    $specimen_geno_sql    = 'SELECT genotypespecimen.SpecimenId, Count(genotypespecimen.GenotypeId) ';
    $specimen_geno_sql   .= 'FROM genotypespecimen LEFT JOIN genotype ON ';
    $specimen_geno_sql   .= 'genotypespecimen.GenotypeId = genotype.GenotypeId ';
    $specimen_geno_sql   .= 'WHERE genotypespecimen.SpecimenId IN (' . join(',', @spec_id_list) . ') ';
    $specimen_geno_sql   .= "AND ((($geno_perm_str) & $READ_PERM) = $READ_PERM) ";
    $specimen_geno_sql   .= 'GROUP BY genotypespecimen.SpecimenId';

    my $geno_with_perm_count_lookup = $dbh_write->selectall_hashref($specimen_geno_sql, 'SpecimenId');

    if ($dbh_write->err()) {

      $self->logger->debug("Read genotype with permission count failed: " . $dbh_write->errstr());

      my $err_msg = "Unexpected Error.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $perm_denied_specimen_id_aref = [];

    for my $spec_id (@spec_id_list) {

      if ( !(defined $geno_with_perm_count_lookup->{$spec_id}) ) {

        push(@{$perm_denied_specimen_id_aref}, $spec_id);
      }
    }

    if (scalar(@{$perm_denied_specimen_id_aref}) > 0) {

      my $err_msg = "Specimen (" . join(',', @{$perm_denied_specimen_id_aref}) . "): permission denied";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my @specimengroupentry_row;
  my @last_spec_id_list;

  for my $specimen_info (@{$specimen_info_aref}) {

    my $spec_id   = $specimen_info->{'SpecimenId'};
    my $spec_note = 'NULL';

    if (defined $specimen_info->{'SpecimenNote'}) {

      if (length($specimen_info->{'SpecimenNote'}) > 0) {

        $spec_note = qq|'$specimen_info->{'SpecimenNote'}'|;
      }
    }

    push(@specimengroupentry_row, "( $specimen_grp_id , $spec_id , $spec_note )");
    push(@last_spec_id_list, $spec_id);
  }

  if (scalar(@specimengroupentry_row) == 0) {

    $self->logger->debug("No record to add to specimengroupentry");

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $specimengroupentry_row_str = join(',', @specimengroupentry_row);

  $sql    = 'INSERT INTO specimengroupentry ';
  $sql   .= '(SpecimenGroupId, SpecimenId, SpecimenNote) ';
  $sql   .= "VALUES $specimengroupentry_row_str";

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

  my $specimen_id_str = join(',', @last_spec_id_list);

  my $msg = "SpecimenId ($specimen_id_str) have been added to SpecimenGroup ($specimen_grp_id) successfully.";
  my $info_msg_aref = [{'Message' => $msg}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub del_genus_runmode {

=pod del_genus_gadmin_HELP_START
{
"OperationName": "Delete genus",
"Description": "Delete genus (organism) using specified id. Genus can be deleted only if not attached to any lower level related record.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Genus (8) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Genus (6) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdUsed": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Genus (1) is used in genotype.' /></DATA>"}],
"ErrorMessageJSON": [{"IdUsed": "{'Error' : [{'Message' : 'Genus (1) is used in genotype.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing genus id."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $genus_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_k_read = connect_kdb_read();

  my $genus_exist = record_existence($dbh_k_read, 'genus', 'GenusId', $genus_id);

  if (!$genus_exist) {

    my $err_msg = "Genus ($genus_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $genus_used = record_existence($dbh_k_read, 'genotype', 'GenusId', $genus_id);

  if ($genus_used) {

    my $err_msg = "Genus ($genus_id) is used in genotype.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $sql = 'DELETE FROM genus WHERE GenusId=?';
  my $sth = $dbh_k_write->prepare($sql);

  $sth->execute($genus_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref = [{'Message' => "Genus ($genus_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub del_specimen_runmode {

=pod del_specimen_gadmin_HELP_START
{
"OperationName": "Delete specimen",
"Description": "Delete specimen using specified id. Specimen can be deleted only if not attached to any lower level related record.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Specimen (3) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Specimen (3) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdUsed": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Specimen (5) is used in trialunit.' /></DATA>"}],
"ErrorMessageJSON": [{"IdUsed": "{'Error' : [{'Message' : 'Specimen (5) is used in trialunit.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SpecimenId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $specimen_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_k_read = connect_kdb_read();

  my $group_id = $self->authen->group_id();

  my $specimen_owner_id = read_cell_value($dbh_k_read, 'specimen', 'OwnGroupId', 'SpecimenId', $specimen_id);

  my $specimen_exist = record_existence($dbh_k_read, 'specimen', 'SpecimenId', $specimen_id);

  if (!$specimen_exist) {

    my $err_msg = "Specimen ($specimen_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (record_existence($dbh_k_read, 'pedigree', 'ParentSpecimenId', $specimen_id)) {

    my $err_msg = "Specimen ($specimen_id) has some children specimens.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $specimen_trialunit = record_existence($dbh_k_read, 'trialunitspecimen', 'SpecimenId', $specimen_id);

  if ($specimen_trialunit) {

    my $err_msg = "Specimen ($specimen_id) is used in trialunit.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $specimen_group = record_existence($dbh_k_read, 'specimengroupentry', 'SpecimenId', $specimen_id);

  if ($specimen_group) {

    my $err_msg = "Specimen ($specimen_id) has a group.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (record_existence($dbh_k_read, 'item', 'SpecimenId', $specimen_id)) {

    my $err_msg = "Specimen ($specimen_id) has some items.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $sql = 'DELETE FROM specimenfactor WHERE SpecimenId=?';
  my $sth = $dbh_k_write->prepare($sql);

  $sth->execute($specimen_id);

  if ($dbh_k_write->err()) {

    $self->logger->debug("Delete specimenfactor failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $sql = 'DELETE FROM genotypespecimen WHERE SpecimenId=?';
  $sth = $dbh_k_write->prepare($sql);

  $sth->execute($specimen_id);

  if ($dbh_k_write->err()) {

    $self->logger->debug("Delete genotypespecimen failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $sql = 'DELETE FROM pedigree WHERE SpecimenId=?';
  $sth = $dbh_k_write->prepare($sql);

  $sth->execute($specimen_id);

  if ($dbh_k_write->err()) {

    $self->logger->debug("Delete pedigree failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $sql = 'DELETE FROM specimenkeyword WHERE SpecimenId=?';
  $sth = $dbh_k_write->prepare($sql);

  $sth->execute($specimen_id);

  if ($dbh_k_write->err()) {

    $self->logger->debug("Delete specimen keyword failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  my $dbh_gis_write = connect_gis_write();
  $sql = 'DELETE FROM specimenloc WHERE specimenid=?';
  $sth = $dbh_gis_write->prepare($sql);
  $sth->execute($specimen_id);
  if ($dbh_gis_write->err()) {
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};
    return $data_for_postrun_href;
  }
  $dbh_gis_write->disconnect();

  $sql = 'DELETE FROM specimen WHERE SpecimenId=?';
  $sth = $dbh_k_write->prepare($sql);

  $sth->execute($specimen_id);

  if ($dbh_k_write->err()) {

    $self->logger->debug("Delete specimen failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref = [{'Message' => "Specimen ($specimen_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub del_specimen_group_runmode {

=pod del_specimen_group_gadmin_HELP_START
{
"OperationName": "Delete specimen group",
"Description": "Delete specimen group specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='SpecimenGroup (2) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'SpecimenGroup (1) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='SpecimenGroup (10) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'SpecimenGroup (10) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SpecimenGroupId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $specimengroup_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_k_read = connect_kdb_read();

  my $specimengroup_exist = record_existence($dbh_k_read, 'specimengroup', 'SpecimenGroupId', $specimengroup_id);

  if (!$specimengroup_exist) {

    my $err_msg = "SpecimenGroup ($specimengroup_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $own_group_id = read_cell_value($dbh_k_read, 'specimengroup', 'OwnGroupId', 'SpecimenGroupId', $specimengroup_id);

  my $group_id = $self->authen->group_id();

  if ($group_id != $own_group_id) {

    my $err_msg = "SpecimenGroup ($specimengroup_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $sql = 'DELETE FROM specimengroupentry WHERE SpecimenGroupId=?';
  my $sth = $dbh_k_write->prepare($sql);

  $sth->execute($specimengroup_id);

  if ($dbh_k_write->err()) {

    $self->logger->debug("Delete specimengroupentry failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();


  $sql = 'DELETE FROM specimengroup WHERE SpecimenGroupId=?';
  $sth = $dbh_k_write->prepare($sql);

  $sth->execute($specimengroup_id);

  if ($dbh_k_write->err()) {

    $self->logger->debug("Delete specimengroup failed");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref = [{'Message' => "SpecimenGroup ($specimengroup_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub del_genotype_runmode {

=pod del_genotype_gadmin_HELP_START
{
"OperationName": "Delete genotype",
"Description": "Delete genotype specified by genotype id. Genotype can be deleted only if not attached to any lower level related record.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Genotype (10) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Genotype (10) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdUsed": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Genotype (1) is used in specimen.' /></DATA>"}],
"ErrorMessageJSON": [{"IdUsed": "{'Error' : [{'Message' : 'Genotype (1) is used in specimen.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing GenotypeId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $genotype_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_k_read = connect_kdb_read();

  my $genotype_owner_id = read_cell_value($dbh_k_read, 'genotype', 'OwnGroupId', 'GenotypeId', $genotype_id);

  if (length($genotype_owner_id) == 0) {

    my $err_msg = "Genotype ($genotype_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();

  if ($genotype_owner_id != $group_id) {

    my $err_msg = "Genotype ($genotype_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $geno_specimen = record_existence($dbh_k_read, 'genotypespecimen', 'GenotypeId', $genotype_id);

  if ($geno_specimen) {

    my $err_msg = "Genotype ($genotype_id) is used in specimen.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $genpedigree_parent = record_existence($dbh_k_read, 'genpedigree', 'ParentGenotypeId', $genotype_id);

  if ($genpedigree_parent) {

    my $err_msg = "Genotype ($genotype_id) is a parent for Genotype Pedigrees.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $del_from_table = ['genotypefactor', 'genotypealias', 'genotypetrait', 'genpedigree','genotype'];

  for my $from_table (@{$del_from_table}) {

    my $sql = "DELETE FROM $from_table  WHERE GenotypeId=?";
    my $sth = $dbh_k_write->prepare($sql);

    $sth->execute($genotype_id);

    if ($dbh_k_write->err()) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }

    $sth->finish();
  }

  $dbh_k_write->disconnect();

  my $info_msg_aref = [{'Message' => "Genotype ($genotype_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_genotype_in_specimen_runmode {

=pod list_genotype_in_specimen_HELP_START
{
"OperationName": "List genotypes for specimen",
"Description": "List which genotypes belong to specimen specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='Genotype' /><Genotype AccessGroupPerm='5' AccessGroupId='0' GenotypeName='Geno_5736568' GenotypeId='1' AccessGroupPermission='Read/Link' OtherPermission='None' addAlias='genotype/1/add/alias' chgPerm='genotype/1/change/permission' OwnGroupPerm='7' OtherPerm='0' CanPublishGenotype='0' OriginId='0' GenotypeNote='none' SpeciesName='Testing' GenotypeColor='black' OwnGroupPermission='Read/Write/Link' OwnGroupName='admin' GenusName='triticum' GenusId='1' AccessGroupName='admin' GenotypeAcronym='T' chgOwner='genotype/1/change/owner' UltimatePermission='Read/Write/Link' OwnGroupId='0' update='update/genotype/1' UltimatePerm='7' /><Genotype AccessGroupPerm='5' AccessGroupId='0' GenotypeName='Geno_5317468' GenotypeId='2' AccessGroupPermission='Read/Link' OtherPermission='None' addAlias='genotype/2/add/alias' chgPerm='genotype/2/change/permission' OwnGroupPerm='7' OtherPerm='0' CanPublishGenotype='0' OriginId='0' GenotypeNote='none' SpeciesName='Testing' GenotypeColor='black' OwnGroupPermission='Read/Write/Link' OwnGroupName='admin' GenusName='triticum' GenusId='1' AccessGroupName='admin' GenotypeAcronym='T' chgOwner='genotype/2/change/owner' UltimatePermission='Read/Write/Link' OwnGroupId='0' update='update/genotype/2' UltimatePerm='7' /></DATA>",
"SuccessMessageJSON": "{'VCol' : [],'RecordMeta' : [{'TagName' : 'Genotype'}],'Genotype' : [{'AccessGroupPerm' : '5','AccessGroupId' : '0','GenotypeId' : '1','GenotypeName' : 'Geno_5736568','addAlias' : 'genotype/1/add/alias','OtherPermission' : 'None','AccessGroupPermission' : 'Read/Link','chgPerm' : 'genotype/1/change/permission','OtherPerm' : '0','OwnGroupPerm' : '7','CanPublishGenotype' : '0','OriginId' : '0','SpeciesName' : 'Testing','GenotypeNote' : 'none','GenotypeColor' : 'black','OwnGroupPermission' : 'Read/Write/Link','OwnGroupName' : 'admin','GenusId' : '1','GenusName' : 'triticum','AccessGroupName' : 'admin','GenotypeAcronym' : 'T','chgOwner' : 'genotype/1/change/owner','UltimatePermission' : 'Read/Write/Link','update' : 'update/genotype/1','OwnGroupId' : '0','UltimatePerm' : '7'},{'AccessGroupPerm' : '5','AccessGroupId' : '0','GenotypeId' : '2','GenotypeName' : 'Geno_5317468','addAlias' : 'genotype/2/add/alias','OtherPermission' : 'None','AccessGroupPermission' : 'Read/Link','chgPerm' : 'genotype/2/change/permission','OtherPerm' : '0','OwnGroupPerm' : '7','CanPublishGenotype' : '0','OriginId' : '0','SpeciesName' : 'Testing','GenotypeNote' : 'none','GenotypeColor' : 'black','OwnGroupPermission' : 'Read/Write/Link','OwnGroupName' : 'admin','GenusId' : '1','GenusName' : 'triticum','AccessGroupName' : 'admin','GenotypeAcronym' : 'T','chgOwner' : 'genotype/2/change/owner','UltimatePermission' : 'Read/Write/Link','update' : 'update/genotype/2','OwnGroupId' : '0','UltimatePerm' : '7'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Specimen (500) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Specimen (500) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SpecimenId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self        = shift;
  my $specimen_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();

  $self->logger->debug("SpecimenId: $specimen_id");

  my $specimen_exist = record_existence($dbh, 'specimen', 'SpecimenId', $specimen_id);

  if (!$specimen_exist) {

    my $err_msg = "Specimen ($specimen_id) not found.";
    return $self->_set_error($err_msg);
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'genotype');

  my $geno_specimen_sql = 'SELECT genotype.GenotypeId ';
  $geno_specimen_sql   .= 'FROM genotype LEFT JOIN genotypespecimen ON ';
  $geno_specimen_sql   .= 'genotype.GenotypeId = genotypespecimen.GenotypeId ';
  $geno_specimen_sql   .= 'WHERE genotypespecimen.SpecimenId=?';

  my $read_geno_start_time = [gettimeofday()];

  my ($geno_specimen_err, $geno_specimen_msg, $geno_specimen_data) = read_data($dbh,
                                                                               $geno_specimen_sql,
                                                                               [$specimen_id]);

  my $read_geno_elapsed = tv_interval($read_geno_start_time);

  $self->logger->debug("Read genotype time: $read_geno_elapsed");

  if ($geno_specimen_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $geno_specimen_sql   .= " AND ((($perm_str) & $READ_PERM) = $READ_PERM)";

  $self->logger->debug("Genotype specimen permission SQL: $geno_specimen_sql");

  my ($geno_p_err, $geno_p_msg, $geno_p_data_perm) = read_data($dbh, $geno_specimen_sql, [$specimen_id]);

  if ($geno_p_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  if (scalar(@{$geno_specimen_data}) != scalar(@{$geno_p_data_perm})) {

    $self->logger->debug("Permission denied: specimen ($specimen_id)");
    my $err_msg = "Permission denied: specimen ($specimen_id)";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my @geno_id_list;
  for my $geno_rec (@{$geno_p_data_perm}) {

    push(@geno_id_list, $geno_rec->{'GenotypeId'});
  }

  if (scalar(@geno_id_list) == 0) {

    push(@geno_id_list, -1);
  }

  my $field_list = ['genotype.*', 'VCol*',
                    "$perm_str AS UltimatePerm",
      ];

  my $other_join = '';

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $field_list, 'genotype',
                                                                        'GenotypeId', $other_join);

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  $self->logger->debug('Number of vcols: ' . scalar(@{$vcol_list}));

  my $geno_id_csv = join(',', @geno_id_list);

  my $filtering_exp = " WHERE (($perm_str) & $READ_PERM) = $READ_PERM ";
  $filtering_exp   .= " AND genotype.GenotypeId IN ($geno_id_csv)";

  $sql  =~ s/GROUP BY/ $filtering_exp GROUP BY /;

  $self->logger->debug("SQL with VCol: $sql");

  my ($read_geno_err, $read_geno_msg, $geno_data) = $self->list_genotype(1, $sql);

  if ($read_geno_err) {

    $self->logger->debug($read_geno_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Genotype'   => $geno_data,
                                           'VCol'       => $vcol_list,
                                           'RecordMeta' => [{'TagName' => 'Genotype'}],
  };

  return $data_for_postrun_href;
}

sub import_genotype_csv_runmode {

=pod import_genotype_csv_HELP_START
{
"OperationName": "Import genotypes",
"Description": "Import genotype data using a csv file.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnIdFile xml='http://kddart-d.diversityarrays.com/data/admin/import_genotype_csv_return_id_172.xml' /><Info Message='43 genotypes have been inserted successfully. Total number of VCol records: 0. Time taken in seconds: 0.131511.' /></DATA>",
"SuccessMessageJSON": "{'ReturnIdFile' : [{'json' : 'http://kddart-d.diversityarrays.com/data/admin/import_genotype_csv_return_id_236.json'}],'Info' : [{'Message' : '1 genotypes have been inserted successfully. Total number of VCol records: 0. Time taken in seconds: 0.094262.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Row (43): genus (41) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Row (43): genus (41) not found.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "CSV",
"UploadFileParameterName": "uploadfile",
"HTTPParameter": [{"Required": 1, "Name": "GenotypeName", "Description": "The column number for GenotypeName column in the upload CSV file"}, {"Required": 1, "Name": "GenusId", "Description": "The column number for GenusId column in the upload CSV file"}, {"Required": 1, "Name": "SpeciesName", "Description": "The column number for SpeciesName column in the upload CSV file"}, {"Required": 1, "Name": "GenotypeAcronym", "Description": "The column number for GenotypeAcronym column in the upload CSV file"}, {"Required": 1, "Name": "OriginId", "Description": "The column number for OriginId column in the upload CSV file"}, {"Required": 1, "Name": "CanPublishGenotype", "Description": "The column number for CanPublishGenotype column in the upload CSV file"}, {"Required": 1, "Name": "GenotypeColor", "Description": "The column number for GenotypeColor column in the upload CSV file"},{"Required": 1, "Name": "GenotypeNote", "Description": "The column number for GenotypeNote column in the upload CSV file"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $start_time = [gettimeofday()];
  my $data_for_postrun_href = {};

  my $data_csv_file = $self->authen->get_upload_file();

  my $num_of_col = get_csvfile_num_of_col($data_csv_file);

  $self->logger->debug("Number of columns: $num_of_col");

  my $GenotypeName_col          = $query->param('GenotypeName');
  my $GenusId_col               = $query->param('GenusId');
  my $SpeciesName_col           = $query->param('SpeciesName');
  my $GenotypeAcronym_col       = $query->param('GenotypeAcronym');
  my $OriginId_col              = $query->param('OriginId');
  my $CanPublishGenotype_col    = $query->param('CanPublishGenotype');
  my $GenotypeColor_col         = $query->param('GenotypeColor');
  my $GenotypeNote_col          = $query->param('GenotypeNote');
  my $TaxonomyId_col            = $query->param('TaxonomyId');

  my $chk_col_def_data = { 'GenotypeName'          => $GenotypeName_col,
                           'GenusId'               => $GenusId_col,
                           'SpeciesName'           => $SpeciesName_col,
                           'GenotypeAcronym'       => $GenotypeAcronym_col,
                           'OriginId'              => $OriginId_col,
                           'CanPublishGenotype'    => $CanPublishGenotype_col,
                           'GenotypeColor'         => $GenotypeColor_col,
                           'GenotypeNote'          => $GenotypeNote_col,
                          #  'TaxonomyId'            => $TaxonomyId_col,
  };

  my $matched_col = {};

  $matched_col->{$GenotypeName_col}          = 'GenotypeName';
  $matched_col->{$GenusId_col}               = 'GenusId';
  $matched_col->{$SpeciesName_col}           = 'SpeciesName';
  $matched_col->{$GenotypeAcronym_col}       = 'GenotypeAcronym';
  $matched_col->{$OriginId_col}              = 'OriginId';
  $matched_col->{$CanPublishGenotype_col}    = 'CanPublishGenotype';
  $matched_col->{$GenotypeColor_col}         = 'GenotypeColor';
  $matched_col->{$GenotypeNote_col}          = 'GenotypeNote';
  $matched_col->{$TaxonomyId_col}            = 'TaxonomyId';


  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='genotypefactor'";

  my $dbh_k_read = connect_kdb_read();
  my $vcol_data = $dbh_k_read->selectall_hashref($sql, 'FactorId');

  my $vcol_req_field         = [];
  my $vcol_len_info          = {};
  my $any_vcol_defined       = 0;

  for my $vcol_id (keys(%{$vcol_data})) {

    $any_vcol_defined = 1;
    my $vcol_param_name = "VCol_${vcol_id}";

    if ( defined $query->param($vcol_param_name) ) {

      my $vcol_colnum                       = $query->param($vcol_param_name);
      $matched_col->{$vcol_colnum}          = $vcol_param_name;
      $chk_col_def_data->{$vcol_param_name} = $vcol_colnum;
    }

    if ($vcol_data->{$vcol_id}->{'CanFactorHaveNull'} != 1) {

      push(@{$vcol_req_field}, $vcol_param_name);
    }
    $vcol_len_info->{$vcol_param_name} = $vcol_data->{$vcol_id}->{'FactorValueMaxLength'};
  }

  $dbh_k_read->disconnect();

  $self->logger->debug("Any virtual column defined: $any_vcol_defined");

  my ($col_def_err, $col_def_msg) = check_col_definition( $chk_col_def_data, $num_of_col );

  if ($col_def_err) {

    return $self->_set_error($col_def_msg);
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

    return $self->_set_error($err_msg);
  }

  my $num_of_bulk_insert = $NB_RECORD_BULK_INSERT;

  my $dbh_write = connect_kdb_write();

  my $row_counter = 1;
  my $i = 0;
  my $num_of_rows = scalar(@{$data_aref});

  $self->logger->debug("Number of rows: $num_of_rows");

  my $unique_genotype = {};
  my $unique_genus    = {};
  my $inner_loop_max_j = 0;

  while( $i < $num_of_rows ) {

    my $j = $i;
    $inner_loop_max_j = $j + $num_of_bulk_insert;
    my $smallest_num = $num_of_rows > $inner_loop_max_j ? $inner_loop_max_j : $num_of_rows;

    my $uniq_geno_name_where     = '';
    my $uniq_taxonomy_id_href    = {};

    #$self->logger->debug("Checking: $i, $smallest_num");

    while( $j < $smallest_num ) {

      my $data_row = $data_aref->[$j];

      my $missing_para_chk_href = { 'GenotypeName'       => $data_row->{'GenotypeName'},
                                    'GenusId'            => $data_row->{'GenusId'},
                                    'OriginId'           => $data_row->{'OriginId'},
                                    'CanPublishGenotype' => $data_row->{'CanPublishGenotype'},
      };

      my $ctrl_char_chk_href    = { 'GenotypeName'    => $data_row->{'GenotypeName'},
                                    'SpeciesName'     => $data_row->{'SpeciesName'},
                                    'GenotypeAcronym' => $data_row->{'GenotypeAcronym'},
                                    'GenotypeColor'   => $data_row->{'GenotypeColor'},
                                    'GenotypeNote'    => $data_row->{'GenotypeNote'}
      };

      for my $vcol_name (@{$vcol_req_field}) {

        $missing_para_chk_href->{$vcol_name} = $data_row->{$vcol_name};
        $ctrl_char_chk_href->{$vcol_name}    = $data_row->{$vcol_name};
      }

      my ($missing_err, $missing_msg) = check_missing_value( $missing_para_chk_href );

      if ($missing_err) {

        my $err_msg = "Row ($row_counter): $missing_msg missing.";

        return $self->_set_error($err_msg);
      }

      my $int_chk_href = { 'GenusId'    => $data_row->{'GenusId'},
                           'OriginId'   => $data_row->{'OriginId'},
                        };

      my $taxonomy_id = $data_row->{'TaxonomyId'} // "";
      if (length($taxonomy_id)) {
        $int_chk_href->{'TaxonomyId'} = $taxonomy_id;
        $uniq_taxonomy_id_href->{$taxonomy_id} = $row_counter;
      }

      my ($int_id_err, $int_id_msg) = check_integer_value($int_chk_href);

      if ($int_id_err) {

        $int_id_msg = "Row ($row_counter): " . $int_id_msg . ' not integer.';

        return $self->_set_error($int_id_msg);
      }

      if ( !($data_row->{'CanPublishGenotype'} =~ /0|1/) ) {

        my $err_msg = "Row ($row_counter): CanPublishGenotype invalid value.";
        return $self->_set_error($err_msg);
      }

      my $ctrl_char_reg_exp = '[\x00-\x1f]|\x7f';
      my ($ctrl_char_err, $ctrl_char_msg) = check_char( $ctrl_char_chk_href, $ctrl_char_reg_exp );

      if ($ctrl_char_err) {

        $ctrl_char_msg = "Row ($row_counter): ' invalid character $ctrl_char_msg.";
        return $self->_set_error($ctrl_char_msg);
      }

      my $maxlen_chk_href = {};

      for my $vcol_name (keys(%{$vcol_len_info})) {

        $maxlen_chk_href->{$vcol_name} = $data_row->{$vcol_name};
      }

      my ($vcol_maxlen_err, $vcol_maxlen_msg) = check_maxlen($maxlen_chk_href, $vcol_len_info);

      if ($vcol_maxlen_err) {

        $vcol_maxlen_msg = $vcol_maxlen_msg . ' longer than maximum length.';
        return $self->_set_error($vcol_maxlen_msg);
      }

      my $geno_name = trim($data_row->{'GenotypeName'});
      my $genus_id  = $data_row->{'GenusId'};

      $unique_genus->{$genus_id} = $row_counter;

      if ($unique_genotype->{lc($geno_name)}) {

        my $err_msg = "Row ($row_counter): duplicate genotype name ($geno_name) in CSV.";
        return $self->_set_error($err_msg);
      }
      else {

        $unique_genotype->{lc($geno_name)} = $genus_id;
      }

      my $uniq_geno_name = $dbh_write->quote($geno_name . "_G_$genus_id");
      $uniq_geno_name_where .= "$uniq_geno_name,";

      $j += 1;
      $row_counter += 1;
    }

    if (length($uniq_geno_name_where) > 0) {

      chop($uniq_geno_name_where); # remove the last comma
      my $check_geno_name_sql = "SELECT GenotypeName FROM genotype ";
      $check_geno_name_sql   .= "WHERE CONCAT(GenotypeName, '_G_', GenusId) IN ($uniq_geno_name_where)";

      #$self->logger->debug("Check GenotypeName SQL: $check_geno_name_sql");

      my ($chk_geno_read_err, $chk_geno_read_msg, $geno_name_data) = read_data($dbh_write,
                                                                               $check_geno_name_sql);

      if ( scalar(@{$geno_name_data}) ) {

        my @duplicate_geno;
        for my $geno_row (@{$geno_name_data}) {

          push(@duplicate_geno, $geno_row->{'GenotypeName'});
        }

        my $start_row = $i + 1;
        my $end_row   = $smallest_num;
        my $err_msg = "Row ($start_row, $end_row): (" . join(',', @duplicate_geno) . ') genotypes already exist.';
        return $self->_set_error($err_msg);
      }

      my $check_alias_name_sql  = "SELECT GenotypeAliasName FROM genotypealias ";
      $check_alias_name_sql    .= "WHERE CONCAT(GenotypeAliasName, '_G_', GenusId) IN ";
      $check_alias_name_sql    .= "($uniq_geno_name_where)";

      my ($chk_alias_read_err, $chk_alias_read_msg, $alias_name_data) = read_data($dbh_write,
                                                                                  $check_alias_name_sql);

      if ( scalar(@{$alias_name_data}) ) {

        my @duplicate_geno;
        for my $alias_row (@{$alias_name_data}) {

          push(@duplicate_geno, $alias_row->{'GenotypeAliasName'});
        }

        my $start_row = $i + 1;
        my $end_row   = $smallest_num;
        my $err_msg = "Row ($start_row, $end_row): (" . join(',', @duplicate_geno) . ') genotypes already exist.';
        return $self->_set_error($err_msg);
      }
    }

    my @taxonomy_id_list = keys(%{$uniq_taxonomy_id_href});
    if (scalar(@taxonomy_id_list) > 0) {
      my $check_crossing_sql = "SELECT TaxonomyId FROM taxonomy ";
      $check_crossing_sql .= "WHERE TaxonomyId IN (" . join(',', @taxonomy_id_list) . ")";
      my $found_taxonomy_data = $dbh_write->selectall_hashref($check_crossing_sql, 'TaxonomyId');
      if (scalar(keys(%$found_taxonomy_data)) < scalar(@taxonomy_id_list)) {

        my @unknown_taxonomy_rownum;
        my @unknown_taxonomy_id;
        for my $taxonomy_id_in_csv (keys(%$uniq_taxonomy_id_href)) {
          if (!defined($found_taxonomy_data->{$taxonomy_id_in_csv})) {

            push(@unknown_taxonomy_id, $taxonomy_id_in_csv);
            push(@unknown_taxonomy_rownum, $uniq_taxonomy_id_href->{$taxonomy_id_in_csv});
          }
        }

        my $err_msg = 'Row (' . join(',', @unknown_taxonomy_rownum) . '): TaxonomyId (';
        $err_msg   .= join(',', @unknown_taxonomy_id) . ') not found.';
        return $self->_set_error($err_msg);
      }
    }

    $i += $num_of_bulk_insert;

    #$self->logger->debug("Smallest num: $smallest_num");
    #$self->logger->debug("I: $i");
  }

  my $check_genus_sql = 'SELECT GenusId FROM genus WHERE GenusId IN (' . join(',', keys(%{$unique_genus})) . ')';
  my $genus_data      = $dbh_write->selectall_hashref($check_genus_sql, 'GenusId');

  if ( scalar(keys(%{$genus_data})) < scalar(keys(%{$unique_genus})) ) {

    my @unknown_genus;
    my @unknown_genus_rownum;
    for my $csv_genus_id (keys(%{$unique_genus})) {

      if ( !(defined $genus_data->{$csv_genus_id}) ) {

        push(@unknown_genus, $csv_genus_id);
        push(@unknown_genus_rownum, $unique_genus->{$csv_genus_id});
      }
    }

    my $err_msg = 'Row (' . join(',', @unknown_genus_rownum) . '): genus (' . join(',', @unknown_genus) . ') not found.';
    return $self->_set_error($err_msg);
  }

  my $group_id = $self->authen->group_id();
  my $default_owner_perm = 7;
  my $default_acc_perm   = 5;
  my $default_oth_perm   = 5;

  my $total_affected_records = 0;
  my $total_vcol_records     = 0;
  $i = 0;

  $sql = 'SELECT GenotypeId FROM genotype ORDER BY GenotypeId DESC LIMIT 1';
  my $prior_last_geno_id = read_cell($dbh_write, $sql, []);

  while( $i < $num_of_rows ) {

    my $j = $i;
    my $inner_loop_max_j = $j + $num_of_bulk_insert;
    my $smallest_num     = $num_of_rows > $inner_loop_max_j ? $inner_loop_max_j : $num_of_rows;

    #$self->logger->debug("Composing: $i, $smallest_num");

    my $bulk_sql = 'INSERT INTO genotype ';
    $bulk_sql   .= '(TaxonomyId,GenotypeName,GenusId,SpeciesName,GenotypeAcronym,OriginId,CanPublishGenotype,GenotypeColor, ';
    $bulk_sql   .= 'GenotypeNote,OwnGroupId,AccessGroupId,OwnGroupPerm,AccessGroupPerm,OtherPerm) ';
    $bulk_sql   .= 'VALUES ';

    my $geno_name_where     = '';

    while( $j < $smallest_num ) {

      my $data_row = $data_aref->[$j];

      my $geno_name      = $dbh_write->quote(trim($data_row->{'GenotypeName'}));
      my $genus_id       = $data_row->{'GenusId'};
      my $species_name   = '';

      if (defined $data_row->{'SpeciesName'}) {

        $species_name = $dbh_write->quote($data_row->{'SpeciesName'});
      }

      my $geno_acronym   = '';

      if (defined $data_row->{'GenotypeAcronym'}) {

        $geno_acronym    = $dbh_write->quote($data_row->{'GenotypeAcronym'});
      }

      my $origin_id      = $data_row->{'OriginId'};
      my $can_publish    = $data_row->{'CanPublishGenotype'};

      my $geno_color     = '';

      if (defined $data_row->{'GenotypeColor'}) {

        $geno_color      = $dbh_write->quote($data_row->{'GenotypeColor'});
      }

      my $geno_note      = '';

      if (defined $data_row->{'GenotypeNote'}) {

        $geno_note = $dbh_write->quote($data_row->{'GenotypeNote'});
      }

      my $taxonomy_id = $data_row->{'TaxonomyId'} // "";
      if (!length($taxonomy_id)) {
        $taxonomy_id = 'NULL';
      }

      $geno_name_where .= "$geno_name,";

      $bulk_sql .= "($taxonomy_id,$geno_name,$genus_id,$species_name,$geno_acronym,$origin_id,$can_publish,$geno_color,";
      $bulk_sql .= "$geno_note,$group_id,$group_id,$default_owner_perm,$default_acc_perm,$default_oth_perm),";

      $j += 1;
    }

    chop($geno_name_where); # remove the last comma
    chop($bulk_sql);        # remove excessive trailling comma

    my $nrows_inserted = $dbh_write->do($bulk_sql);

    if ($dbh_write->err()) {

      $self->logger->debug('Error code: ' . $dbh_write->err());

      return $self->_set_error('Unexpected error.');
    }

    if ($any_vcol_defined) {

      my $geno_name2id_sql = "SELECT CONCAT(GenotypeName,'_G_', GenusId) AS ID, GenotypeId ";
      $geno_name2id_sql   .= "FROM genotype WHERE GenotypeName IN ($geno_name_where)";
      my $sth = $dbh_write->prepare($geno_name2id_sql);
      $sth->execute();
      my $geno_name2id_href = $sth->fetchall_hashref('ID');
      $sth->finish();

      my $bulk_vcol_sql = 'INSERT INTO genotypefactor ';
      $bulk_vcol_sql   .= '(GenotypeId,FactorId,FactorValue) ';
      $bulk_vcol_sql   .= 'VALUES ';

      my $any_vcol_record = 0;

      $j = $i;
      while( $j < $smallest_num ) {

        my $data_row = $data_aref->[$j];

        my $geno_name = $data_row->{'GenotypeName'};
        my $genus_id  = $data_row->{'GenusId'};
        my $geno_id   = $geno_name2id_href->{"${geno_name}_G_${genus_id}"}->{'GenotypeId'};

        for my $vcol_id (keys(%{$vcol_data})) {

          my $vcol_name = 'VCol_' . "$vcol_id";
          my $factor_value = $data_row->{$vcol_name};

          if (length($factor_value) > 0) {

            $any_vcol_record = 1;
            $factor_value = $dbh_write->quote($factor_value);
            $bulk_vcol_sql .= "($geno_id,$vcol_id,$factor_value),";
          }
        }

        $j += 1;
      }

      if ($any_vcol_record) {

        chop($bulk_vcol_sql);        # remove excessive trailling comma

        $self->logger->debug("Bulk insert for VCol: $bulk_vcol_sql");

        my $nrows_vcol_inserted = $dbh_write->do($bulk_vcol_sql);

        if ($dbh_write->err()) {

          $self->logger->debug('Error: ' . $dbh_write->errstr());
          $self->logger->debug('Error code: ' . $dbh_write->err());

          return $self->_set_error('Unexpected error.');
        }

        $total_vcol_records += $nrows_vcol_inserted;
      }
    }

    $total_affected_records += $nrows_inserted;


    $i += $num_of_bulk_insert;
  }

  $sql = 'SELECT GenotypeId FROM genotype ORDER BY GenotypeId DESC LIMIT 1';
  my $post_last_geno_id = read_cell($dbh_write, $sql, []);

  $self->logger->debug("PRIOR INSERT ID: $prior_last_geno_id | POST INSERT ID: $post_last_geno_id");

  $sql  = 'SELECT GenotypeId, GenotypeName, GenusId ';
  $sql .= 'FROM genotype WHERE GenotypeId > ? AND GenotypeId <= ?';

  my ($read_geno_id_err, $read_geno_id_msg, $new_geno_data) = read_data($dbh_write, $sql,
                                                                       [$prior_last_geno_id, $post_last_geno_id]);

  if ($read_geno_id_err) {

    $self->debug("Read Geno err: $read_geno_id_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $dbh_write->disconnect();

  my $just_inserted_id_data = [];

  for my $new_geno_rec (@{$new_geno_data}) {

    my $n_geno_name = $new_geno_rec->{'GenotypeName'};
    my $db_genus_id = $new_geno_rec->{'GenusId'};

    if (defined $unique_genotype->{lc($n_geno_name)}) {

      #$self->logger->debug("New Genotype Name: $n_geno_name");
      #$self->logger->debug("DB GenusID: $db_genus_id");
      #$self->logger->debug("GenusId file: " . $unique_genotype->{lc($n_geno_name)});

      if ($unique_genotype->{lc($n_geno_name)} == $db_genus_id) {

        push(@{$just_inserted_id_data}, $new_geno_rec);
      }
    }
  }

  my $return_id_data = {};
  $return_id_data->{'ReturnId'}     = $just_inserted_id_data;
  $return_id_data->{'AlternateKey'} = [{'FieldName' => 'GenotypeName'}, {'FieldName' => 'GenusId'}];

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

  my $elapsed_time = tv_interval($start_time);

  my $info_msg = "$total_affected_records genotypes have been inserted successfully. ";
  $info_msg   .= "Total number of VCol records: $total_vcol_records. ";
  $info_msg   .= "Time taken in seconds: $elapsed_time.";
  my $info_msg_aref = [{'Message' => $info_msg}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref, 'ReturnIdFile' => [$output_file_href]};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub export_genotype_runmode {

=pod export_genotype_HELP_START
{
"OperationName": "Export genotypes",
"Description": "Export genotype data into a csv file.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Time taken in seconds: 0.043529.' /><OutputFile csv='http://kddart-d.diversityarrays.com/data/admin/export_genotype_37fc0d4c85c74d3775f1786e86c906e7.csv' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Time taken in seconds: 0.026635.'}],'OutputFile' : [{'csv' : 'http://kddart-d.diversityarrays.com/data/admin/export_genotype_37fc0d4c85c74d3775f1786e86c906e7.csv'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPParameter": [{"Required": 0, "Name": "Filtering", "Description": "Filtering parameter string consisting of filtering expressions which are separated by ampersand (&) which needs to be encoded if HTTP GET method is used. Each filtering expression is composed of a database field name, a filtering operator and the filtering value."}, {"Required": 0, "Name": "FieldList", "Description": "Comma separated value of wanted fields."}, {"Required": 0, "Name": "Sorting", "Description": "Comma separated value of SQL sorting phrases."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $start_time = [gettimeofday()];
  my $data_for_postrun_href = {};

  my $field_list_csv = '';

  if (defined $query->param('FieldList')) {

    $field_list_csv = $query->param('FieldList');
  }

  my $filtering_csv = '';

  if (defined $query->param('Filtering')) {

    $filtering_csv = $query->param('Filtering');
  }

  if (defined $self->param('genusid')) {

    my $genus_id = $self->param('genusid');

    if ($filtering_csv =~ /GenusId=(.*),?/) {

      if ( "$genus_id" ne "$1" ) {

        my $err_msg = 'Duplicate filtering condition for GenusId.';
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
    else {

      if (length($filtering_csv) > 0) {

        if ($filtering_csv =~ /&$/) {

          $filtering_csv .= "GenusId=$genus_id";
        }
        else {

          $filtering_csv .= "&GenusId=$genus_id";
        }
      }
      else {

        $filtering_csv .= "GenusId=$genus_id";
      }
    }
  }

  $self->logger->debug("Filtering csv: $filtering_csv");

  my $sorting = '';

  if (defined $query->param('Sorting')) {

    $sorting = $query->param('Sorting');
  }

  my $username             = $self->authen->username();
  my $doc_root             = $ENV{'DOCUMENT_ROOT'};
  my $export_data_path     = "${doc_root}/data/$username";
  my $current_runmode      = $self->get_current_runmode();
  my $lock_filename        = "${current_runmode}.lock";

  if ( !(-e $export_data_path) ) {

    mkdir($export_data_path);
  }

  my $lockfile = File::Lockfile->new( $lock_filename, $export_data_path );
  my $pid = $lockfile->check();
  if ( $pid ) {
    $self->logger->debug("$lock_filename exists in $export_data_path");
    my $msg = 'Lockfile exists: either another process of this export is running or ';
    $msg   .= 'there was an unexpected error regarding clearing this lockfile.';
    return $self->_set_error( $msg );
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'genotype');

  my $dbh = connect_kdb_read();
  my $field_list = ['genotype.*', 'VCol*'];

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $field_list, 'genotype',
                                                                        'GenotypeId', '');

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql   .= " LIMIT 1";

  $self->logger->debug("SQL with VCol: $sql");

  my ($sam_geno_err, $sam_geno_msg, $sam_geno_data) = $self->list_genotype(0, $sql);

  if ($sam_geno_err) {

    $self->logger->debug($sam_geno_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $sample_geno_aref = $sam_geno_data;

  my @field_list_all = keys(%{$sample_geno_aref->[0]});

  #no field return, it means no record. error prevention
  if (scalar(@field_list_all) == 0) {

    push(@field_list_all, '*');
  }

  my $final_field_list = \@field_list_all;

  if (length($field_list_csv) > 0) {

    my ($sel_field_err, $sel_field_msg, $sel_field_list) = parse_selected_field($field_list_csv,
                                                                                $final_field_list,
                                                                                'GenotypeId');

    if ($sel_field_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;

    if ($filtering_csv =~ /GenusId/) {

      push(@{$final_field_list}, 'GenusId');
    }
  }

  my $field_lookup = {};
  for my $fd_name (@{$final_field_list}) {

    $field_lookup->{$fd_name} = 1;
  }

  my $other_join = '';
  if ($field_lookup->{'GenusId'}) {

    push(@{$final_field_list}, 'genus.GenusName');
    $other_join .= ' LEFT JOIN genus ON genotype.GenusId = genus.GenusId';
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

  push(@{$final_field_list}, "$perm_str AS UltimatePerm");

  ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $final_field_list, 'genotype',
                                                                     'GenotypeId', $other_join);
  $dbh->disconnect();

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering('GenotypeId',
                                                                              'genotype',
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

  $sql .= " HAVING (($perm_str) & $READ_PERM) = $READ_PERM $filter_where_phrase ";

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

    $sql .= ' ORDER BY genotype.GenotypeId DESC';
  }

  $self->logger->debug("SQL with VCol: $sql");

  my $sql2md5 = md5_hex($sql);

  my $genotype_filename    = "export_genotype_$sql2md5.csv";
  my $genotype_file        = "${export_data_path}/$genotype_filename";

  # where_arg here because of the filtering
  my ($read_geno_err, $read_geno_msg, $geno_data) = $self->list_genotype(0,
                                                                         $sql,
                                                                         $where_arg);

  if ($read_geno_err) {

    $self->logger->debug($read_geno_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $fieldname_order = { 'GenotypeId'       => 0,
                          'GenotypeName'     => 1,
                          'GenusId'          => 2,
                          'GenusName'        => 3,
                          'SpeciesName'      => 4,
                          'GenotypeAcronym'  => 5,
                          'GenotypeColor'    => 6,
                          'GenotypeNote'     => 7,
  };

  arrayref2csvfile($genotype_file, $fieldname_order, $geno_data);

  my $url = reconstruct_server_url();
  my $elapsed_time = tv_interval($start_time);

  my $href_info = { 'csv'  => "$url/data/$username/$genotype_filename" };

  my $time_info = { 'Message' => "Time taken in seconds: $elapsed_time." };

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'OutputFile' => [$href_info], 'Info' => [$time_info] };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub import_specimen_csv_runmode {

=pod import_specimen_csv_HELP_START
{
"OperationName": "Import specimens",
"Description": "Import specimens using a csv file.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnIdFile xml='http://kddart-d.diversityarrays.com/data/admin/import_specimen_csv_return_id_234.xml' /><Info Message='2 specimens have been inserted successfully. Total number of VColrecords: 0. Time taken in seconds: 0.049178.' /></DATA>",
"SuccessMessageJSON": "{'ReturnIdFile' : [{'json' : 'http://kddart-d.diversityarrays.com/data/admin/import_specimen_csv_return_id_200.json'}],'Info' : [{'Message' : '2 specimens have been inserted successfully. Total number of VCol records: 0. Time taken in seconds: 0.170086.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Row (43): BreedingMethod (41) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Row (43): BreedingMethod (41) not found.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "CSV",
"UploadFileParameterName": "uploadfile",
"HTTPParameter": [{"Required": 1, "Name": "SpecimenName", "Description": "The column number for SpecimenName column in the upload CSV file"},{"Required": 1, "Name": "SpecimenNote", "Description": "The column number for SpecimenNote column in the upload CSV file"}, {"Required": 1, "Name": "BreedingMethodId", "Description": "The column number for BreedingMethodId column in the upload CSV file"}, {"Required": 0, "Name": "SpecimenBarcode", "Description": "The column number for SpecimenBarcode column in the upload CSV file"}, {"Required": 0, "Name": "IsActive", "Description": "The column number for IsActive column in the upload CSV file"}, {"Required": 0, "Name": "Pedigree", "Description": "The column number for Pedigree column in the upload CSV file"}, {"Required": 0, "Name": "SelectionHistory", "Description": "The column number for SelectionHistory column in the upload CSV file"}, {"Required": 0, "Name": "FilialGeneration", "Description": "The column number for FilialGeneration column in the upload CSV file"}, {"Required": 1, "Name": "GenotypeId", "Description": "The column number for GenotypeId column in the upload CSV file"}, {"Required": 0, "Name": "GenotypeId1", "Description": "The column number for GenotypeId1 (2nd genotype) column in the upload CSV file"}, {"Required": 0, "Name": "GenotypeId2", "Description": "The column number for GenotypeId2 (3rd genotype) column in the upload CSV file"}, {"Required": 0, "Name": "GenotypeId3", "Description": "The column number for GenotypeId3 (4th genotype) column in the upload CSV file"}, {"Required": 0, "Name": "GenotypeId4", "Description": "The column number for GenotypeId4 (5th genotype) column in the upload CSV file"} ],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $start_time = [gettimeofday()];
  my $data_for_postrun_href = {};

  my $data_csv_file = $self->authen->get_upload_file();

  my $num_of_col = get_csvfile_num_of_col($data_csv_file);

  $self->logger->debug("Number of columns: $num_of_col");

  my $SpecimenName_col     = $query->param('SpecimenName');
  my $BreedingMethodId_col = $query->param('BreedingMethodId');

  my $chk_col_def_data = { 'SpecimenName'          => $SpecimenName_col,
                           'BreedingMethodId'      => $BreedingMethodId_col,
  };

  my $matched_col = {};

  $matched_col->{$SpecimenName_col}          = 'SpecimenName';
  $matched_col->{$BreedingMethodId_col}      = 'BreedingMethodId';

  if (defined $query->param('SpecimenBarcode')) {

    my $SpecimenBarcode_col = $query->param('SpecimenBarcode');
    $chk_col_def_data->{'SpecimenBarcode'} = $SpecimenBarcode_col;
    $matched_col->{$SpecimenBarcode_col}   = 'SpecimenBarcode';
  }

  if (defined $query->param('IsActive')) {

    my $IsActive_col = $query->param('IsActive');
    $chk_col_def_data->{'IsActive'} = $IsActive_col;
    $matched_col->{$IsActive_col}   = 'IsActive';
  }

  if (defined $query->param('Pedigree')) {

    my $Pedigree_col = $query->param('Pedigree');
    $chk_col_def_data->{'Pedigree'} = $Pedigree_col;
    $matched_col->{$Pedigree_col}   = 'Pedigree';
  }

  if (defined $query->param('SelectionHistory')) {

    my $SelectionHistory_col = $query->param('SelectionHistory');
    $chk_col_def_data->{'SelectionHistory'} = $SelectionHistory_col;
    $matched_col->{$SelectionHistory_col}   = 'SelectionHistory';
  }

  if (defined $query->param('FilialGeneration')) {

    my $FilialGeneration_col = $query->param('FilialGeneration');
    $chk_col_def_data->{'FilialGeneration'} = $FilialGeneration_col;
    $matched_col->{$FilialGeneration_col}   = 'FilialGeneration';
  }

  if (defined $query->param('SpecimenNote')) {

    my $SpecimenNote_col = $query->param('SpecimenNote');
    $chk_col_def_data->{'SpecimenNote'} = $SpecimenNote_col;
    $matched_col->{$SpecimenNote_col}   = 'SpecimenNote';
  }

  my $geno_info_provided = 0;
  my @genotypeid_field;

  if (defined $query->param('GenotypeId')) {

    $geno_info_provided += 1;
    my $geno_id_field_col = $query->param('GenotypeId');
    push(@genotypeid_field, 'GenotypeId');
    $chk_col_def_data->{'GenotypeId'} = $geno_id_field_col;
    $matched_col->{$geno_id_field_col}  = 'GenotypeId';
  }

  if (defined $query->param('SourceCrossingId')) {
    my $sourceCrossing_col = $query->param('SourceCrossingId');
    $chk_col_def_data->{'SourceCrossingId'} = $sourceCrossing_col;
    $matched_col->{$sourceCrossing_col} = 'SourceCrossingId';
  }

  my $geograph_provided = 0;

  if (defined $query->param('specimenlocation')) {
    
    my $specimenLocation_col = $query->param('specimenlocation');
    $chk_col_def_data->{'specimenlocation'} = $specimenLocation_col;
    $matched_col->{$specimenLocation_col} = 'specimenlocation';

    if (defined $query->param('specimenlocdt')) {
        my $locdt_col = $query->param('specimenlocdt');
        $chk_col_def_data->{'specimenlocdt'} = $locdt_col;
        $matched_col->{$locdt_col} = 'specimenlocdt';
    }

    if (defined $query->param('currentloc')) {
        my $iscur_col = $query->param('currentloc');
        $chk_col_def_data->{'currentloc'} = $iscur_col;
        $matched_col->{$iscur_col} = 'currentloc';
    }

    if (defined $query->param('description')) {
        my $des_col = $query->param('description');
        $chk_col_def_data->{'description'} = $des_col;
        $matched_col->{$des_col} = 'description';
    }

    $geograph_provided = 1;
  }

  my $geno_i = 1;
  my $geno_break_flag = 0;

  while ($geno_break_flag == 0) {

    my $geno_id_field   = "GenotypeId$geno_i";

    if (defined $query->param($geno_id_field)) {

      $geno_info_provided += 1;
      my $geno_id_field_col = $query->param($geno_id_field);
      push(@genotypeid_field, $geno_id_field);
      $chk_col_def_data->{$geno_id_field} = $geno_id_field_col;
      $matched_col->{$geno_id_field_col}  = $geno_id_field;
      $geno_i++;
    }
    else {
      $geno_break_flag = 1;
    }
  }

  if ($geno_info_provided == 0) {

    my $err_msg = 'No genotype information';
    return $self->_set_error($err_msg);
  }
  elsif ($geno_info_provided > 1) {

    if ($GENOTYPE2SPECIMEN_CFG eq $GENO_SPEC_ONE2ONE || $GENOTYPE2SPECIMEN_CFG eq $GENO_SPEC_ONE2MANY) {

      $self->logger->debug("Genotype 2 specimen CFG: $GENOTYPE2SPECIMEN_CFG (more than 1 genotype).");
      my $err_msg = "Genotype to specimen restriction ($GENOTYPE2SPECIMEN_CFG): more than 1 genotype.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }

    my $InheritanceGenotype_col = $query->param('InheritanceGenotype');

    $chk_col_def_data->{'InheritanceGenotype'} = $InheritanceGenotype_col;
    $matched_col->{$InheritanceGenotype_col}   = 'InheritanceGenotype';
  }

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='specimenfactor'";

  my $dbh_k_read = connect_kdb_read();
  my $vcol_data = $dbh_k_read->selectall_hashref($sql, 'FactorId');

  my $vcol_req_field         = [];
  my $vcol_len_info          = {};
  my $any_vcol_defined       = 0;

  for my $vcol_id (keys(%{$vcol_data})) {

    $any_vcol_defined = 1;
    my $vcol_param_name = "VCol_${vcol_id}";

    if ( defined $query->param($vcol_param_name) ) {

      my $vcol_colnum                       = $query->param($vcol_param_name);
      $matched_col->{$vcol_colnum}          = $vcol_param_name;
      $chk_col_def_data->{$vcol_param_name} = $vcol_colnum;
    }

    if ($vcol_data->{$vcol_id}->{'CanFactorHaveNull'} != 1) {

      push(@{$vcol_req_field}, $vcol_param_name);
    }
    $vcol_len_info->{$vcol_param_name} = $vcol_data->{$vcol_id}->{'FactorValueMaxLength'};
  }

  $dbh_k_read->disconnect();

  $self->logger->debug("Any virtual column defined: $any_vcol_defined");

  my ($col_def_err, $col_def_msg) = check_col_definition( $chk_col_def_data, $num_of_col );

  if ($col_def_err) {

    return $self->_set_error($col_def_msg);
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

    return $self->_set_error($err_msg);
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $num_of_bulk_insert = $NB_RECORD_BULK_INSERT;

  my $dbh_write = connect_kdb_write();

  my $row_counter = 1;
  my $i = 0;
  my $num_of_rows = scalar(@{$data_aref});

  $self->logger->debug("Number of rows: $num_of_rows");

  my $unique_specimen_href     = {};
  my $unique_bmeth_id_href     = {};
  my $unique_barcode_href      = {};

  my $inherit_perm_info_lookup = {};

  my $inner_loop_max_j = 0;

  my $gis_read = connect_gis_read();

  while( $i < $num_of_rows ) {

    my $j = $i;
    $inner_loop_max_j = $j + $num_of_bulk_insert;
    my $smallest_num = $num_of_rows > $inner_loop_max_j ? $inner_loop_max_j : $num_of_rows;

    my $specimen_name_where     = '';
    my $barcode_where           = '';
    my $crossing_where          = '';
    my $uniq_geno_href          = {};
    my $uniq_inherit_geno_href  = {};
    my $unique_crossing_id_href = {};

    #$self->logger->debug("Checking: $i, $smallest_num");

    while( $j < $smallest_num ) {

      my $data_row = $data_aref->[$j];

      my $missing_para_chk_href = { 'SpecimenName'       => $data_row->{'SpecimenName'},
                                    'BreedingMethodId'   => $data_row->{'BreedingMethodId'},
      };

      my $ctrl_char_chk_href    = { 'SpecimenName'    => $data_row->{'SpecimenName'} };

      for my $vcol_name (@{$vcol_req_field}) {

        $missing_para_chk_href->{$vcol_name} = $data_row->{$vcol_name};
        $ctrl_char_chk_href->{$vcol_name}    = $data_row->{$vcol_name};
      }

      my ($missing_err, $missing_msg) = check_missing_value( $missing_para_chk_href );

      if ($missing_err) {

        $missing_msg = "Row ($row_counter): $missing_msg missing.";
        return $self->_set_error($missing_msg);
      }

      my $int_chk_href = { 'BreedingMethodId' => $data_row->{'BreedingMethodId'} };

      if (defined $data_row->{'FilialGeneration'}) {

        $int_chk_href->{'FilialGeneration'} = $data_row->{'FilialGeneration'};
      }

      if (defined $data_row->{'SourceCrossingId'}) {

        $int_chk_href->{'SourceCrossingId'} = $data_row->{'SourceCrossingId'};
      }

      my ($int_id_err, $int_id_msg) = check_integer_value( $int_chk_href );

      if ($int_id_err) {

        $int_id_msg = "Row ($row_counter): " . $int_id_msg . ' not integer.';
        return $self->_set_error($int_id_msg);
      }

      if (defined $data_row->{'IsActive'}) {

        if ( !($data_row->{'IsActive'} =~ /0|1/) ) {

          my $err_msg = "Row ($row_counter): IsActive invalid value.";
          return $self->_set_error($err_msg);
        }
      }

      my $ctrl_char_reg_exp = '[\x00-\x1f]|\x7f';
      my ($ctrl_char_err, $ctrl_char_msg) = check_char( $ctrl_char_chk_href, $ctrl_char_reg_exp );

      if ($ctrl_char_err) {

        $ctrl_char_msg = "Row ($row_counter): ' invalid character $ctrl_char_msg.";
        return $self->_set_error($ctrl_char_msg);
      }

      my $maxlen_chk_href = {};

      for my $vcol_name (keys(%{$vcol_len_info})) {

        $maxlen_chk_href->{$vcol_name} = $data_row->{$vcol_name};
      }

      my ($vcol_maxlen_err, $vcol_maxlen_msg) = check_maxlen($maxlen_chk_href, $vcol_len_info);

      if ($vcol_maxlen_err) {

        $vcol_maxlen_msg = $vcol_maxlen_msg . ' longer than maximum length.';
        return $self->_set_error($vcol_maxlen_msg);
      }

      my $specimen_name = $data_row->{'SpecimenName'};
      my $bmeth_id      = $data_row->{'BreedingMethodId'};

      $unique_bmeth_id_href->{$bmeth_id} = $row_counter;

      if ($unique_specimen_href->{lc($specimen_name)}) {

        my $err_msg = "Row ($row_counter): duplicate specimen name ($specimen_name) in CSV.";
        return $self->_set_error($err_msg);
      }
      else {

        $unique_specimen_href->{lc($specimen_name)} = 1;
      }

      if (length($data_row->{'SpecimenBarcode'}) > 0) {

        my $specimen_barcode = $data_row->{'SpecimenBarcode'};
        if ($unique_barcode_href->{$specimen_barcode}) {

          my $err_msg = "Row ($row_counter): duplicate barcode ($specimen_barcode) in CSV.";
          return $self->_set_error($err_msg);
        }
        else {

          $unique_barcode_href->{$specimen_barcode} = $row_counter;
          $specimen_barcode = $dbh_write->quote($specimen_barcode);
          $barcode_where   .= "$specimen_barcode,";
        }
      }

      my $crossing_id = $data_row->{'SourceCrossingId'} // "";
      if (length($crossing_id) > 0) {
        $unique_crossing_id_href->{$crossing_id} = $row_counter;
      }

      my $missing_geno_data_href = {};
      my $int_chk_geno_data_href = {};

      for my $geno_id_field (@genotypeid_field) {

        my $geno_id = $data_row->{$geno_id_field};
        $missing_geno_data_href->{$geno_id_field} = $geno_id;
        $int_chk_geno_data_href->{$geno_id_field} = $geno_id;

        $uniq_geno_href->{$geno_id} = $row_counter;
      }

      my $inherit_geno_id = undef;

      if (scalar(@genotypeid_field) > 1) {

        $inherit_geno_id = $data_row->{'InheritanceGenotype'};
        $missing_geno_data_href->{'InheritanceGenotype'} = $inherit_geno_id;
        $int_chk_geno_data_href->{'InheritanceGenotype'} = $inherit_geno_id;

        my $is_inherit_geno_matched = 0;

        for my $geno_id_field (@genotypeid_field) {

          my $geno_id = $data_row->{$geno_id_field};

          if ($inherit_geno_id == $geno_id) {

            $is_inherit_geno_matched = 1;
            last;
          }
        }

        if ( !$is_inherit_geno_matched ) {

          my $err_msg = "Row ($row_counter): inheritance genotype is not one of the genotypes in this row.";
          return $self->_set_error($err_msg);
        }
      }
      elsif (scalar(@genotypeid_field) == 1)  {

        my $geno_id_field = $genotypeid_field[0];
        $inherit_geno_id  = $data_row->{$geno_id_field};
      }
      # else is impossible due to the checking of $geno_info_provided

      if ( !(defined $inherit_perm_info_lookup->{$inherit_geno_id}) ) {

        $uniq_inherit_geno_href->{$inherit_geno_id} = $row_counter;
      }

      my ($geno_missing_err, $geno_missing_msg) = check_missing_value( $missing_geno_data_href );

      if ($geno_missing_err) {

        $geno_missing_msg = "Row ($row_counter): $geno_missing_msg missing.";
        return $self->_set_error($err_msg);
      }

      my ($geno_int_id_err, $geno_int_id_msg) = check_integer_value($int_chk_geno_data_href);

      if ($geno_int_id_err) {

        $geno_int_id_msg = "Row ($row_counter): $geno_int_id_msg not integer.";
        return $self->_set_error($geno_int_id_msg);
      }

      $specimen_name = $dbh_write->quote(trim($specimen_name));
      $specimen_name_where .= "$specimen_name,";

      if ($geograph_provided) {
        my $location = $data_row->{'specimenlocation'};
        if (length $location) {
            my ($is_wkt_err, $wkt_err_href) = is_valid_wkt_href($gis_read, {"specimenlocation" => $location}, ['POINT']);
            if ($is_wkt_err) {
                return $self->_set_error("Row ($row_counter): invalid specimenlocation.");
            }
            $data_row->{'specimenlocation'} = "ST_ForceCollection(ST_GeomFromText('$location', -1))";
            my $locdt = $data_row->{'specimenlocdt'};
            if (!length $locdt) {
              $data_row->{'specimenlocdt'} = DateTime::Format::Pg->parse_datetime(DateTime->now());
            } else {
              my ($date_err, $date_href) = check_dt_href({"specimenlocdt" => $locdt});
              if ($date_err) {
                  return $self->_set_error("Row ($row_counter): invalid specimenlocdt.");
              }
            }
            my $currentloc = $data_row->{'currentloc'};
            if (!length $currentloc) {
              $data_row->{'currentloc'} = 1;
            } elsif ($currentloc !~ /^\s*([01])\s*$/) {
              return $self->_set_error("Row ($row_counter): currentloc can only be 0 or 1.");
            } else {
              $data_row->{'currentloc'} = $1 + 0;
            }
        }
      }

      $j += 1;
      $row_counter += 1;
    }

    $self->logger->debug("Specimen Name: $specimen_name_where");
    if (length($specimen_name_where) > 0) {

      chop($specimen_name_where); # remove the last comma
      my $check_specimen_name_sql = "SELECT SpecimenName FROM specimen ";
      $check_specimen_name_sql   .= "WHERE SpecimenName IN ($specimen_name_where)";

      #$self->logger->debug("Check GenotypeName SQL: $check_geno_name_sql");

      my ($chk_spec_read_err, $chk_spec_read_msg, $spec_name_data) = read_data($dbh_write, $check_specimen_name_sql);

      if ( scalar(@{$spec_name_data}) ) {

        my @duplicate_specimen;
        for my $spec_row (@{$spec_name_data}) {

          push(@duplicate_specimen, $spec_row->{'SpecimenName'});
        }

        my $start_row = $i + 1;
        my $end_row   = $smallest_num;
        my $err_msg = "Row ($start_row, $end_row): (" . join(',', @duplicate_specimen) . ') specimens already exist.';
        return $self->_set_error($err_msg);
      }
    }

    if (length($barcode_where) > 0) {

      chop($barcode_where); # remove the last comma
      my $check_barcode_sql = "SELECT SpecimenBarcode FROM specimen ";
      $check_barcode_sql   .= "WHERE SpecimenBarcode IN ($barcode_where)";

      #$self->logger->debug("Check Barcode SQL: $chk_barcode_sql");

      my ($chk_barcode_read_err, $chk_barcode_read_msg, $barcode_data) = read_data($dbh_write, $check_barcode_sql);

      if ( scalar(@{$barcode_data}) ) {

        my @duplicate_barcode;
        for my $barcode_row (@{$barcode_data}) {

          push(@duplicate_barcode, $barcode_row->{'SpecimenBarcode'});
        }

        my $start_row = $i + 1;
        my $end_row   = $smallest_num;
        my $err_msg = "Row ($start_row, $end_row): (" . join(',', @duplicate_barcode) . ') SpecimenBarcode already exist.';
        return $self->_set_error($err_msg);
      }
    }

    my @geno_list = keys(%{$uniq_geno_href});

    if (scalar(@geno_list) > 0) {

      my $check_geno_sql = "SELECT GenotypeId FROM genotype ";
      $check_geno_sql   .= "WHERE GenotypeId IN (" . join(',', @geno_list) . ")";

      my $found_geno_data = $dbh_write->selectall_hashref($check_geno_sql, 'GenotypeId');

      if ( scalar(keys(%{$found_geno_data})) < scalar(@geno_list) ) {

        my @unknown_geno;
        my @unknown_geno_rownum;
        for my $geno_id_in_csv (keys(%{$uniq_geno_href})) {

          if ( !(defined $found_geno_data->{$geno_id_in_csv}) ) {

            push(@unknown_geno, $geno_id_in_csv);
            push(@unknown_geno_rownum, $uniq_geno_href->{$geno_id_in_csv});
          }
        }

        my $err_msg = 'Row (' . join(',', @unknown_geno_rownum) . '): Genotype (';
        $err_msg   .= join(',', @unknown_geno) . ') not found.';
        return $self->_set_error($err_msg);
      }

      if ($GENOTYPE2SPECIMEN_CFG eq $GENO_SPEC_ONE2ONE) {

        my $chk_genospec_sql = 'SELECT GenotypeId FROM genotypespecimen ';
        $chk_genospec_sql   .= 'WHERE GenotypeId IN (' . join(',', @geno_list) . ')';

        my ($read_genospec_err, $read_genospec_msg, $geno_with_spec_data) = read_data($dbh_write, $chk_genospec_sql);

        if ($read_genospec_err) {

          $self->logger->debug("Read genotypespecimen failed: $read_genospec_msg");

          my $err_msg = 'Unexpected Error.';
          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }

        if ( scalar(@{$geno_with_spec_data}) > 0) {

          my @geno_already_has_spec;
          my @geno_already_has_spec_rownum;

          for my $has_spec_geno_rec (@{$geno_with_spec_data}) {

            push(@geno_already_has_spec, $has_spec_geno_rec->{'GenotypeId'});
            push(@geno_already_has_spec_rownum, $uniq_geno_href->{$has_spec_geno_rec->{'GenotypeId'}});
          }

          my $err_msg = "Genotype to specimen restriction ($GENOTYPE2SPECIMEN_CFG): specimen already exists. ";
          $err_msg   .= 'Row (' . join(',', @geno_already_has_spec_rownum) . '): ';
          $err_msg   .= 'Genotype (' . join(',', @geno_already_has_spec) . ').';

          $self->logger->debug($err_msg);

          $data_for_postrun_href->{'Error'} = 1;
          $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

          return $data_for_postrun_href;
        }
      }

      #$self->logger->debug("Check Genotype SQL: $chk_geno_sql");

      my ($is_perm_ok, $trouble_geno_id_aref) = check_permission($dbh_write, 'genotype', 'GenotypeId',
                                                                 \@geno_list, $group_id, $gadmin_status,
                                                                 $READ_LINK_PERM);

      if ( !$is_perm_ok ) {

        my $trouble_geno_id_str = join(',', @{$trouble_geno_id_aref});

        my $start_row = $i + 1;
        my $end_row   = $smallest_num;
        my $err_msg = "Row ($start_row, $end_row): Genotype ($trouble_geno_id_str) permission denied.";
        return $self->_set_error($err_msg);
      }
    }

    my @inherit_geno_id_list = keys(%{$uniq_inherit_geno_href});

    if (scalar(@inherit_geno_id_list) > 0) {

      my $inherit_perm_sql    = 'SELECT GenotypeId, OwnGroupId, OwnGroupPerm, AccessGroupId, AccessGroupPerm, ';
      $inherit_perm_sql      .= 'OtherPerm FROM genotype ';
      $inherit_perm_sql      .= 'WHERE GenotypeId IN (' . join(',', @inherit_geno_id_list) . ')';

      my ($r_inherit_perm_err, $r_inherit_perm_msg, $inherit_perm_data) = read_data($dbh_write,
                                                                                    $inherit_perm_sql, []);

      if ($r_inherit_perm_err) {

        $self->logger->debug("Read inherit permission failed: $r_inherit_perm_msg");

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

        return $data_for_postrun_href;
      }

      foreach my $inherit_perm_row (@{$inherit_perm_data}) {

        my $geno_id = $inherit_perm_row->{'GenotypeId'};
        $inherit_perm_info_lookup->{$geno_id} = $inherit_perm_row;
      }
    }

    my @crossing_id_list = keys(%{$unique_crossing_id_href});
    if (scalar(@crossing_id_list) > 0) {
      my $check_crossing_sql = "SELECT CrossingId FROM crossing ";
      $check_crossing_sql .= "WHERE CrossingId IN (" . join(',', @crossing_id_list) . ")";
      my $found_crossing_data = $dbh_write->selectall_hashref($check_crossing_sql, 'CrossingId');
      if (scalar(keys(%$found_crossing_data)) < scalar(@crossing_id_list)) {

        my @unknown_crossing_rownum;
        my @unknown_crossing_id;
        for my $crossing_id_in_csv (keys(%$unique_crossing_id_href)) {
          if (!defined($found_crossing_data->{$crossing_id_in_csv})) {

            push(@unknown_crossing_id, $crossing_id_in_csv);
            push(@unknown_crossing_rownum, $unique_crossing_id_href->{$crossing_id_in_csv});
          }
        }

        my $err_msg = 'Row (' . join(',', @unknown_crossing_rownum) . '): CrossingId (';
        $err_msg   .= join(',', @unknown_crossing_id) . ') not found.';
        return $self->_set_error($err_msg);
      }
    }


    $i += $num_of_bulk_insert;

    #$self->logger->debug("Smallest num: $smallest_num");
    #$self->logger->debug("I: $i");
  }

  $gis_read->disconnect;

  if (scalar(keys(%{$unique_bmeth_id_href}))) {

    my $check_bmeth_sql = 'SELECT BreedingMethodId FROM breedingmethod ';
    $check_bmeth_sql   .= 'WHERE BreedingMethodId IN (' . join(',', keys(%{$unique_bmeth_id_href})) . ')';

    my $bmeth_data      = $dbh_write->selectall_hashref($check_bmeth_sql, 'BreedingMethodId');

    if ( scalar(keys(%{$bmeth_data})) < scalar(keys(%{$unique_bmeth_id_href})) ) {

      my @unknown_bmeth;
      my @unknown_bmeth_rownum;
      for my $csv_bmeth_id (keys(%{$unique_bmeth_id_href})) {

        if ( !(defined $bmeth_data->{$csv_bmeth_id}) ) {

          push(@unknown_bmeth, $csv_bmeth_id);
          push(@unknown_bmeth_rownum, $unique_bmeth_id_href->{$csv_bmeth_id});
        }
      }

      my $err_msg = 'Row (' . join(',', @unknown_bmeth_rownum) . '): BreedingMethod (' . join(',', @unknown_bmeth) . ') not found.';
      return $self->_set_error($err_msg);
    }
  }

  # start adding records to database

  my $just_inserted_id_data = [];

  my $total_affected_records = 0;
  my $total_vcol_records     = 0;
  $i = 0;

  while( $i < $num_of_rows ) {

    my $j = $i;
    my $inner_loop_max_j = $j + $num_of_bulk_insert;
    my $smallest_num = $num_of_rows > $inner_loop_max_j ? $inner_loop_max_j : $num_of_rows;

    #$self->logger->debug("Composing: $i, $smallest_num");

    my $bulk_sql = 'INSERT INTO specimen ';
    $bulk_sql   .= '(SpecimenName,BreedingMethodId,SourceCrossingId,SpecimenBarcode,IsActive,Pedigree,';
    $bulk_sql   .= 'SelectionHistory,FilialGeneration,SpecimenNote,OwnGroupId,OwnGroupPerm,AccessGroupId,';
    $bulk_sql   .= 'AccessGroupPerm,OtherPerm) ';
    $bulk_sql   .= 'VALUES ';

    my $specimen_name_where     = '';

    while( $j < $smallest_num ) {

      my $data_row = $data_aref->[$j];

      my $specimen_name      = $dbh_write->quote(trim($data_row->{'SpecimenName'}));
      my $breeding_method_id = $data_row->{'BreedingMethodId'};

      my $specimen_barcode = "''";

      if (length($data_row->{'SpecimenBarcode'}) > 0) {

        $specimen_barcode = $dbh_write->quote($data_row->{'SpecimenBarcode'});
      }
      else {

        $specimen_barcode = 'NULL';
      }

      my $crossing_id;
      if (length($data_row->{'SourceCrossingId'}) > 0) {
        $crossing_id = $data_row->{'SourceCrossingId'};
      } else {
        $crossing_id = 'NULL';
      }

      my $is_active = 1;

      if (defined $data_row->{'IsActive'}) {

        $is_active = $data_row->{'IsActive'};
      }

      my $pedigree = $dbh_write->quote(q{});

      if (defined $data_row->{'Pedigree'}) {

        $pedigree = $dbh_write->quote($data_row->{'Pedigree'});
      }

      my $selection_history = $dbh_write->quote(q{});

      if (defined $data_row->{'SelectionHistory'}) {

        $selection_history = $dbh_write->quote($data_row->{'SelectionHistory'});
      }

      my $specimen_note = $dbh_write->quote(q{});

      if (defined $data_row->{'SpecimenNote'}) {

        $specimen_note = $dbh_write->quote($data_row->{'SpecimenNote'});
      }

      my $filial_generation = 0;

      if (defined $data_row->{'FilialGeneration'}) {

        $filial_generation = $data_row->{'FilialGeneration'};
      }

      $specimen_name_where .= "$specimen_name,";

      my $inherit_geno_id = undef;

      if (scalar(@genotypeid_field) > 1) {

        $inherit_geno_id = $data_row->{'InheritanceGenotype'};
      }
      elsif (scalar(@genotypeid_field) == 1)  {

        my $geno_id_field = $genotypeid_field[0];
        $inherit_geno_id  = $data_row->{$geno_id_field};
      }
      # else is impossible due to the checking of $geno_info_provided

      if ( !(defined $inherit_geno_id) ) {

        $self->logger->debug("Very strange: undefined inherit_geno_id");

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

        return $data_for_postrun_href;
      }

      if ( !(defined $inherit_perm_info_lookup) ) {

        $self->logger->debug("Another strange: inherited genotype permission info not found");

        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

        return $data_for_postrun_href;
      }

      my $own_grp_id    = $inherit_perm_info_lookup->{$inherit_geno_id}->{'OwnGroupId'};
      my $own_grp_perm  = $inherit_perm_info_lookup->{$inherit_geno_id}->{'OwnGroupPerm'};
      my $acc_grp_id    = $inherit_perm_info_lookup->{$inherit_geno_id}->{'AccessGroupId'};
      my $acc_grp_perm  = $inherit_perm_info_lookup->{$inherit_geno_id}->{'AccessGroupPerm'};
      my $oth_perm      = $inherit_perm_info_lookup->{$inherit_geno_id}->{'OtherPerm'};

      $bulk_sql .= "($specimen_name,$breeding_method_id,$crossing_id,$specimen_barcode,$is_active,$pedigree,";
      $bulk_sql .= "$selection_history,$filial_generation,$specimen_note,$own_grp_id,$own_grp_perm,$acc_grp_id,$acc_grp_perm,";
      $bulk_sql .= "$oth_perm),";

      $j += 1;
    }

    $self->logger->debug("Bulk SQL: $bulk_sql");

    chop($specimen_name_where); # remove the last comma
    chop($bulk_sql);            # remove excessive trailling comma

    my $nrows_inserted = $dbh_write->do($bulk_sql);

    if ($dbh_write->err()) {

      $self->logger->debug('Error code: ' . $dbh_write->err());
      $self->logger->debug('Error: ' . $dbh_write->errstr());

      return $self->_set_error('Unexpected error.');
    }

    my $spec_name2id_sql = "SELECT SpecimenId, SpecimenName ";
    $spec_name2id_sql   .= "FROM specimen WHERE SpecimenName IN ($specimen_name_where)";
    my $sth = $dbh_write->prepare($spec_name2id_sql);
    $sth->execute();
    my $spec_name2id_href = $sth->fetchall_hashref('SpecimenName');
    $sth->finish();

    if ($geograph_provided) {
        my $insert_geo_bulk_sql = 'INSERT INTO specimenloc ';
        $insert_geo_bulk_sql .= '(specimenid, specimenlocation, specimenlocdt, currentloc, description) ';
        $insert_geo_bulk_sql .= 'VALUES ';

        my $specimenloc_values = [];
        my $specimen_id_where = [];

        for ($j = $i; $j < $smallest_num; $j++) {
            my $data_row = $data_aref->[$j];
            my $specimen_name = $data_row->{'SpecimenName'};
            my $specimen_id   = $spec_name2id_href->{$specimen_name}->{'SpecimenId'};
            my $location = $data_row->{'specimenlocation'};
            if (length $location) {
                my $lodct = $data_row->{'specimenlocdt'};
                my $is_cur = $data_row->{'currentloc'};
                if ($is_cur) { push(@$specimen_id_where, $specimen_id); }
                my $description = $data_row->{'description'} // "";
                push(@$specimenloc_values, qq|('$specimen_id', $location, '$lodct', '$is_cur', '$description')|);
            }
        }

        if (scalar @$specimenloc_values) {
          my $gis_write = connect_gis_write(1);
          my $err = 0;
          eval {
              if (scalar @$specimen_id_where) {
                  my $unset_cur_bulk_sql = "UPDATE specimenloc SET currentloc=0 WHERE specimenid IN (";
                  $unset_cur_bulk_sql .= join(",", @$specimen_id_where);
                  $unset_cur_bulk_sql .= ")";
                  $self->logger->debug("Update GIS query: $unset_cur_bulk_sql");
                  my $sth = $gis_write->prepare($unset_cur_bulk_sql);
                  $sth->execute();
              }
              $insert_geo_bulk_sql .= join(',', @$specimenloc_values);
              $self->logger->debug("GIS query: $insert_geo_bulk_sql");
              my $sth = $gis_write->prepare($insert_geo_bulk_sql);
              $sth->execute();
              $gis_write->commit;
              1;
          } or do {
              $err = 1;
              eval {$gis_write->rollback;};
          };
          if ($err) { return $self->_set_error(); }
          $gis_write->disconnect;
        }
    }

    my $insert_geno_spec_bulk_sql = 'INSERT INTO genotypespecimen ';
    $insert_geno_spec_bulk_sql   .= '(SpecimenId,GenotypeId,InheritanceFlag) ';
    $insert_geno_spec_bulk_sql   .= 'VALUES ';

    $j = $i;
    while( $j < $smallest_num ) {

      my $data_row = $data_aref->[$j];

      my $specimen_name = $data_row->{'SpecimenName'};
      my $specimen_id   = $spec_name2id_href->{$specimen_name}->{'SpecimenId'};

      my $just_inserted_id_rec = {};
      $just_inserted_id_rec->{'SpecimenId'}   = $specimen_id;
      $just_inserted_id_rec->{'SpecimenName'} = $specimen_name;

      push(@{$just_inserted_id_data}, $just_inserted_id_rec);

      my $inherit_geno_id = undef;

      if (scalar(@genotypeid_field) > 1) {

        $inherit_geno_id = $data_row->{'InheritanceGenotype'};
      }
      elsif (scalar(@genotypeid_field) == 1)  {

        my $geno_id_field = $genotypeid_field[0];
        $inherit_geno_id  = $data_row->{$geno_id_field};
      }
      # else is impossible due to the checking of $geno_info_provided

      for my $geno_id_field (@genotypeid_field) {

        my $geno_id = $data_row->{$geno_id_field};

        my $inheritance_flag = 'NULL';

        if ($geno_id == $inherit_geno_id) {

          $inheritance_flag = '1';
        }

        $insert_geno_spec_bulk_sql .= "($specimen_id,$geno_id,$inheritance_flag),";
      }

      $j += 1;
    }

    chop($insert_geno_spec_bulk_sql);        # remove trailling comma

    $self->logger->debug("Genotype Specimen SQ: $insert_geno_spec_bulk_sql");

    my $nrow_spec_geno_inserted = $dbh_write->do($insert_geno_spec_bulk_sql);

    if ($dbh_write->err()) {

      $self->logger->debug('Error code: ' . $dbh_write->err());
      $self->logger->debug('Error: ' . $dbh_write->errstr());

      return $self->_set_error('Unexpected error.');
    }

    if ($any_vcol_defined) {

      my $bulk_vcol_sql = 'INSERT INTO specimenfactor ';
      $bulk_vcol_sql   .= '(SpecimenId,FactorId,FactorValue) ';
      $bulk_vcol_sql   .= 'VALUES ';

      my $any_vcol_record = 0;

      $j = $i;
      while( $j < $smallest_num ) {

        my $data_row = $data_aref->[$j];

        my $specimen_name = $data_row->{'SpecimenName'};
        my $specimen_id   = $spec_name2id_href->{$specimen_name}->{'SpecimenId'};

        for my $vcol_id (keys(%{$vcol_data})) {

          my $vcol_name = 'VCol_' . "$vcol_id";
          my $factor_value = $data_row->{$vcol_name};

          if (length($factor_value) > 0) {

            $any_vcol_record = 1;
            $factor_value = $dbh_write->quote($factor_value);
            $bulk_vcol_sql .= "($specimen_id,$vcol_id,$factor_value),";
          }
        }

        $j += 1;
      }

      if ($any_vcol_record) {

        chop($bulk_vcol_sql);        # remove excessive trailling comma

        $self->logger->debug("Bulk insert for VCol: $bulk_vcol_sql");

        my $nrows_vcol_inserted = $dbh_write->do($bulk_vcol_sql);

        if ($dbh_write->err()) {

          $self->logger->debug('Error: ' . $dbh_write->errstr());
          $self->logger->debug('Error code: ' . $dbh_write->err());

          return $self->_set_error('Unexpected error.');
        }

        $total_vcol_records += $nrows_vcol_inserted;
      }
    }

    $total_affected_records += $nrows_inserted;


    $i += $num_of_bulk_insert;
  }

  $dbh_write->disconnect();

  my $return_id_data = {};
  $return_id_data->{'ReturnId'}     = $just_inserted_id_data;
  $return_id_data->{'AlternateKey'} = [{'FieldName' => 'SpecimenName'}];

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

  my $elapsed_time = tv_interval($start_time);

  my $info_msg = "$total_affected_records specimens have been inserted successfully. ";
  $info_msg   .= "Total number of VCol records: $total_vcol_records. ";
  $info_msg   .= "Time taken in seconds: $elapsed_time.";
  my $info_msg_aref = [{'Message' => $info_msg}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref, 'ReturnIdFile' => [$output_file_href]};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub add_breedingmethod_runmode {

=pod add_breedingmethod_gadmin_HELP_START
{
"OperationName": "Add breeding method",
"Description": "Add a new breeding method definition to the system.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "breedingmethod",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='9' ParaName='BreedingMethodId' /><Info Message='BreedingMethodId (9) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '10','ParaName' : 'BreedingMethodId'}],'Info' : [{'Message' : 'BreedingMethodId (10) has been added successfully.'}]}",
"ErrorMessageXML": [{"MissingParameter": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error BreedingMethodName='BreedingMethodName is missing.' /></DATA>"}],
"ErrorMessageJSON": [{"MissingParameter": "{'Error' : [{'BreedingMethodName' : 'BreedingMethodName is missing.'}]}"}],
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
                                                                                'breedingmethod', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $breedingmethod_name = $query->param('BreedingMethodName');
  my $breedingmethod_type = $query->param('BreedingMethodTypeId');

  my $breedingmethod_acronym = undef;

  if (defined $query->param('BreedingMethodAcronym')) {

    if (length($query->param('BreedingMethodAcronym')) > 0) {

      $breedingmethod_acronym = $query->param('BreedingMethodAcronym');
    }
  }

  my $breedingmethod_note = undef;

  if (defined $query->param('BreedingMethodNote')) {

    $breedingmethod_note = $query->param('BreedingMethodNote');
  }

  my $breedingmethod_symbol = undef;

  if (defined $query->param('BreedingMethodSymbol')) {

    if (length($query->param('BreedingMethodSymbol')) > 0) {

      $breedingmethod_symbol = $query->param('BreedingMethodSymbol');
    }
  }

  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='breedingmethodfactor'";

  my $dbh_k_read = connect_kdb_read();
  my $vcol_data = $dbh_k_read->selectall_hashref($sql, 'FactorId');

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

  my $bmeth_type_existence = type_existence($dbh_k_read, 'breedingmethod', $breedingmethod_type);

  if (!$bmeth_type_existence) {

    my $err_msg = "BreedingMethodType ($breedingmethod_type) does not exist.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'BreedingMethodTypeId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (record_existence($dbh_k_read, 'breedingmethod', 'BreedingMethodName', $breedingmethod_name)) {

    my $err_msg = "BreedingMethodName ($breedingmethod_name) already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'BreedingMethodName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (defined $breedingmethod_acronym) {

    if (record_existence($dbh_k_read, 'breedingmethod', 'BreedingMethodAcronym', $breedingmethod_acronym)) {

      my $err_msg = "BreedingMethodAcronym ($breedingmethod_acronym) already exists.";
      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'BreedingMethodAcronym' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  $sql  = "INSERT INTO breedingmethod SET ";
  $sql .= "BreedingMethodTypeId=?, ";
  $sql .= "BreedingMethodName=?, ";
  $sql .= "BreedingMethodAcronym=?, ";
  $sql .= "BreedingMethodNote=?, ";
  $sql .= "BreedingMethodSymbol=?";

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute( $breedingmethod_type, $breedingmethod_name, $breedingmethod_acronym, $breedingmethod_note, $breedingmethod_symbol );

  if ( $dbh_k_write->err() ) {

    return $self->_set_error('Unexpected Error.');
  }

  my $breedingmethod_id = $dbh_k_write->last_insert_id( undef, undef, 'breedingmethod', 'BreedingMethodId' ) || -1;
  $self->logger->debug("BreedingMethodId: $breedingmethod_id");
  $sth->finish();

  for my $vcol_id ( keys( %{$vcol_data} ) ) {

    my $factor_value = $query->param( 'VCol_' . "$vcol_id" );
    if ( length($factor_value) > 0 ) {

      $sql = "
             INSERT INTO breedingmethodfactor SET
             FactorId=?,
             BreedingMethodId=?,
             FactorValue=?
             ";

      my $factor_sth = $dbh_k_write->prepare($sql);
      $factor_sth->execute( $vcol_id, $breedingmethod_id, $factor_value );

      if ( $dbh_k_write->err() ) {

        # Return undef if any error occur
        $self->logger->debug("Fail adding virtual column");
        return $self->_set_error('Unexpected Error.');
      }
      $factor_sth->finish();
    }
  }
  $dbh_k_write->disconnect();

  my $info_msg_aref  = [ { 'Message' => "BreedingMethodId ($breedingmethod_id) has been added successfully." } ];
  my $return_id_aref = [ { 'Value'   => "$breedingmethod_id", 'ParaName' => 'BreedingMethodId' } ];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref,
                                           'ReturnId'  => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_breedingmethod {

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

  my $get_data_time_start = [gettimeofday()];

  my $dbh = connect_kdb_read();
  my $sth = $dbh->prepare($sql);

  $sth->execute(@{$where_para_aref});

  my $err = 0;
  my $msg = '';
  my $breedingmethod_data = [];

  if ( !$dbh->err() ) {

    my $array_ref = $sth->fetchall_arrayref({});

    if ( !$sth->err() ) {

      $breedingmethod_data = $array_ref;
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

  my $get_data_elapsed = tv_interval($get_data_time_start);

  $self->logger->debug("Get breeding method data time: $get_data_elapsed");

  my $check_data_start_time = [gettimeofday()];

  my $extra_attr_breedingmethod_data = [];

  my $gadmin_status = $self->authen->gadmin_status();

  if ($extra_attr_yes && ($gadmin_status eq '1')) {

    my $breedingmethod_id_aref = [];

    for my $row (@{$breedingmethod_data}) {

      push(@{$breedingmethod_id_aref}, $row->{'BreedingMethodId'});
    }

    if (scalar(@{$breedingmethod_id_aref}) > 0) {

      my $chk_table_aref = [{'TableName' => 'specimen', 'FieldName' => 'BreedingMethodId'}];

      my ($chk_id_err, $chk_id_msg,
          $used_id_href, $not_used_id_href) = id_existence_bulk($dbh, $chk_table_aref, $breedingmethod_id_aref);

      if ($chk_id_err) {

        $self->logger->debug("Check id existence error: $chk_id_msg");
        $err = 1;
        $msg = $chk_id_msg;
      }
      else {

        $self->logger->debug("Used id list: " . join(',', keys(%{$used_id_href})));
        $self->logger->debug("Not used id list: " . join(',', sort(keys(%{$not_used_id_href}))));

        for my $row (@{$breedingmethod_data}) {

          my $breedingmethod_id = $row->{'BreedingMethodId'};
          $row->{'update'} = "update/breedingmethod/$breedingmethod_id";

          if ( $not_used_id_href->{$breedingmethod_id}) {

            $row->{'delete'} = "delete/breedingmethod/$breedingmethod_id";
          }

          push(@{$extra_attr_breedingmethod_data}, $row);
        }
      }
    }
  }
  else {

    $extra_attr_breedingmethod_data = $breedingmethod_data;
  }

  $dbh->disconnect();

  my $check_data_elapsed = tv_interval($check_data_start_time);

  $self->logger->debug("Check breeding method data time: $check_data_elapsed");

  return ($err, $msg, $extra_attr_breedingmethod_data);
}

sub list_breedingmethod_runmode {

=pod list_breedingmethod_HELP_START
{
"OperationName": "List breeding method",
"Description": "Lists all available breeding methods in the system. This listing does not require pagination information.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><BreedingMethod BreedingMethodName='BreedMethod_8545841' BreedingMethodId='1' BreedingMethodNote='Automatic testing breeding method' update='update/breedingmethod/1' /><RecordMeta TagName='BreedingMethod' /></DATA>",
"SuccessMessageJSON": "{'VCol' : [],'BreedingMethod' : [{'BreedingMethodName' : 'BreedMethod_8545841','BreedingMethodId' : '1','BreedingMethodNote' : 'Automatic testing breeding method','update' : 'update/breedingmethod/1'}],'RecordMeta' : [{'TagName' : 'BreedingMethod'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();
  my $field_list = ['breedingmethod.*', 'generaltype.TypeName AS BreedingMethodTypeName'];

  my $other_join = ' LEFT JOIN generaltype ON breedingmethod.BreedingMethodTypeId = generaltype.TypeId ';

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $field_list, 'breedingmethod',
                                                                        'BreedingMethodId', $other_join);
  $dbh->disconnect();

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql   .= ' ORDER BY breedingmethod.BreedingMethodId DESC';

  $self->logger->debug("SQL with VCol: $sql");

  my $list_start_time = [gettimeofday()];

  my ($read_breed_meth_err, $read_breed_meth_msg, $breedingmethod_data) = $self->list_breedingmethod(1, $sql);

  my $list_elapsed = tv_interval($list_start_time);

  $self->logger->debug("List breeding method time: $list_elapsed");

  if ($read_breed_meth_err) {

    $self->logger->debug($read_breed_meth_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'BreedingMethod'  => $breedingmethod_data,
                                           'VCol'       => $vcol_list,
                                           'RecordMeta' => [{'TagName' => 'BreedingMethod'}],
  };

  return $data_for_postrun_href;
}

sub update_breedingmethod_runmode {

=pod update_breedingmethod_gadmin_HELP_START
{
"OperationName": "Update breeding method",
"Description": "Update breeding method using specified id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "breedingmethod",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='BreedingMethod (10) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'BreedingMethod (10) has been updated successfully.'}]}",
"ErrorMessageXML": [{"MissingParameter": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error BreedingMethodName='BreedingMethodName is missing.' /></DATA>"}],
"ErrorMessageJSON": [{"MissingParameter": "{'Error' : [{'BreedingMethodName' : 'BreedingMethodName is missing.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing BreedingMethodId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self              = shift;
  my $breedingmethod_id = $self->param('id');
  my $query             = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'breedingmethod', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $dbh_k_read = connect_kdb_read();
  my $breedingmethod_exist = record_existence($dbh_k_read, 'breedingmethod',
                                              'BreedingmethodId', $breedingmethod_id);

  if (!$breedingmethod_exist) {

    my $err_msg = "BreedingMethod ($breedingmethod_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $breedingmethod_type = $query->param('BreedingMethodTypeId');
  my $breedingmethod_name = $query->param('BreedingMethodName');

  my $read_sql    =  'SELECT BreedingMethodNote, BreedingMethodAcronym, BreedingMethodSymbol ';
     $read_sql   .=  'FROM breedingmethod WHERE BreedingMethodId=? ';

  my ($r_df_val_err, $r_df_val_msg, $breed_df_val_data) = read_data($dbh_k_read, $read_sql, [$breedingmethod_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve breedingmethod default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'}  = 1;
    $data_for_postrun_href->{'Data'}   = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $breedingmethod_note      = undef;
  my $breedingmethod_acronym   = undef;
  my $breedingmethod_symbol    = undef;

  my $nb_df_val_rec     =   scalar(@{$breed_df_val_data});

  if ($nb_df_val_rec != 1)  {

     $self->logger->debug("Retrieve breedingmethod default values - number of records unacceptable: $nb_df_val_rec");
     $data_for_postrun_href->{'Error'} = 1;
     $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

     return $data_for_postrun_href;
  }

  $breedingmethod_note     =  $breed_df_val_data->[0]->{'BreedingMethodNote'};
  $breedingmethod_acronym  =  $breed_df_val_data->[0]->{'BreedingMethodAcronym'};
  $breedingmethod_symbol   =  $breed_df_val_data->[0]->{'BreedingMethodSymbol'};

  if (length($breedingmethod_note) == 0) {

    $breedingmethod_note = undef;
  }

  if (length($breedingmethod_acronym) == 0) {

    $breedingmethod_acronym = undef;
  }

  if (length($breedingmethod_symbol) == 0) {

    $breedingmethod_symbol = undef;
  }


  if (defined $query->param('BreedingMethodAcronym')) {

    if (length($query->param('BreedingMethodAcronym')) > 0) {

      $breedingmethod_acronym = $query->param('BreedingMethodAcronym');
    }
  }

  if (defined $query->param('BreedingMethodNote')) {

    if (length($query->param('BreedingMethodNote')) > 0) {

      $breedingmethod_note = $query->param('BreedingMethodNote');
    }
  }

  if (defined $query->param('BreedingMethodSymbol')) {

    if (length($query->param('BreedingMethodSymbol')) > 0) {

      $breedingmethod_symbol = $query->param('BreedingMethodSymbol');
    }
  }


  my $sql = "SELECT FactorId, CanFactorHaveNull, FactorValueMaxLength ";
  $sql   .= "FROM factor ";
  $sql   .= "WHERE TableNameOfFactor='breedingmethodfactor'";

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

  my $bmeth_type_existence = type_existence($dbh_k_read, 'breedingmethod', $breedingmethod_type);

  if (!$bmeth_type_existence) {

    my $err_msg = "BreedingMethodType ($breedingmethod_type) does not exist.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'BreedingMethodTypeId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $chk_bmeth_name_sql = 'SELECT BreedingMethodId FROM breedingmethod WHERE BreedingMethodName=? AND BreedingMethodId <> ?';

  my ($read_err, $db_bmeth_id) = read_cell($dbh_k_read, $chk_bmeth_name_sql, [$breedingmethod_id, $breedingmethod_name]);

  if ($read_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  if (length($db_bmeth_id) > 0) {

    my $err_msg = "BreedingMethodName ($breedingmethod_name): already exists.";
    $data_for_postrun_href->{'Error'}       = 1;
    $data_for_postrun_href->{'Data'}        = {'Error' => [{'BreedingMethodName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $chk_bmeth_acro_sql = 'SELECT BreedingMethodId FROM breedingmethod WHERE BreedingMethodAcronym=? AND BreedingMethodId <> ?';

  ($read_err, $db_bmeth_id) = read_cell($dbh_k_read, $chk_bmeth_name_sql, [$breedingmethod_id, $breedingmethod_name]);

  if ($read_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  if (length($db_bmeth_id) > 0) {

    my $err_msg = "BreedingMethodAcronym ($breedingmethod_acronym): already exists.";
    $data_for_postrun_href->{'Error'}       = 1;
    $data_for_postrun_href->{'Data'}        = {'Error' => [{'BreedingMethodAcronym' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  $sql  = "UPDATE breedingmethod SET ";
  $sql .= "BreedingMethodTypeId=?, ";
  $sql .= "BreedingMethodName=?, ";
  $sql .= "BreedingMethodAcronym=?, ";
  $sql .= "BreedingMethodNote=?, ";
  $sql .= "BreedingMethodSymbol=? ";
  $sql .= "WHERE BreedingMethodId=?";

  my $sth = $dbh_k_write->prepare($sql);
  $sth->execute( $breedingmethod_type, $breedingmethod_name, $breedingmethod_acronym,
                 $breedingmethod_note, $breedingmethod_symbol, $breedingmethod_id );

  if ($dbh_k_write->err()) {

    $self->logger->debug($dbh_k_write->errstr());
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  for my $vcol_id (keys(%{$vcol_data})) {

    if (defined $query->param('VCol_' . "$vcol_id")) {

      my $factor_value = $query->param('VCol_' . "$vcol_id");

      $sql  = 'SELECT Count(*) ';
      $sql .= 'FROM breedingmethodfactor ';
      $sql .= 'WHERE BreedingMethodId=? AND FactorId=?';

      my ($read_err, $count) = read_cell($dbh_k_write, $sql, [$breedingmethod_id, $vcol_id]);

      if (length($factor_value) > 0) {

        if ($count > 0) {

          $sql  = 'UPDATE breedingmethodfactor SET ';
          $sql .= 'FactorValue=? ';
          $sql .= 'WHERE BreedingMethodId=? AND FactorId=?';
          my $factor_sth = $dbh_k_write->prepare($sql);
          $factor_sth->execute($factor_value, $breedingmethod_id, $vcol_id);

          if ($dbh_k_write->err()) {

            $self->logger->debug($dbh_k_write->errstr());
            $data_for_postrun_href->{'Error'} = 1;
            $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

            return $data_for_postrun_href;
          }

          $factor_sth->finish();
        }
        else {

          $sql  = 'INSERT INTO breedingmethodfactor SET ';
          $sql .= 'BreedingMethodId=?, ';
          $sql .= 'FactorId=?, ';
          $sql .= 'FactorValue=?';
          my $factor_sth = $dbh_k_write->prepare($sql);
          $factor_sth->execute($breedingmethod_id, $vcol_id, $factor_value);

          if ($dbh_k_write->err()) {

            $self->logger->debug($dbh_k_write->errstr());
            $data_for_postrun_href->{'Error'} = 1;
            $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

            return $data_for_postrun_href;
          }

          $factor_sth->finish();
        }
      }
      else {

        if ($count > 0) {

          $sql  = 'DELETE FROM breedingmethodfactor ';
          $sql .= 'WHERE BreedingMethodId=? AND FactorId=?';

          my $factor_sth = $dbh_k_write->prepare($sql);
          $factor_sth->execute($breedingmethod_id, $vcol_id);

          if ($dbh_k_write->err()) {

            $self->logger->debug($dbh_k_write->errstr());
            $data_for_postrun_href->{'Error'} = 1;
            $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

            return $data_for_postrun_href;
          }
          $factor_sth->finish();
        }
      }
    }
  }

  $dbh_k_write->disconnect();

  my $info_msg_aref = [{'Message' => "BreedingMethod ($breedingmethod_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub get_breedingmethod_runmode {

=pod get_breedingmethod_HELP_START
{
"OperationName": "Get breeding method",
"Description": "Get detailed information about breeding method specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><BreedingMethod BreedingMethodName='BreedMethod_8545841' BreedingMethodId='1' BreedingMethodNote='Automatic testing breeding method' update='update/breedingmethod/1' /><RecordMeta TagName='BreedingMethod' /></DATA>",
"SuccessMessageJSON": "{'VCol' : [],'BreedingMethod' : [{'BreedingMethodName' : 'BreedMethod_8545841','BreedingMethodId' : '1','BreedingMethodNote' : 'Automatic testing breeding method','update' : 'update/breedingmethod/1'}],'RecordMeta' : [{'TagName' : 'BreedingMethod'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='BreedingMethod (11) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'BreedingMethod (11) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing BreedingMethodId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self              = shift;
  my $breedingmethod_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $group_id = $self->authen->group_id();

  my $dbh = connect_kdb_read();

  my $breedingmethod_exist = record_existence($dbh, 'breedingmethod', 'BreedingMethodId', $breedingmethod_id);

  if (!$breedingmethod_exist) {

    my $err_msg = "BreedingMethod ($breedingmethod_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $field_list = ['breedingmethod.*', 'generaltype.TypeName AS BreedingMethodTypeName'];

  my $other_join = ' LEFT JOIN generaltype ON breedingmethod.BreedingMethodTypeId = generaltype.TypeId ';

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $field_list, 'breedingmethod',
                                                                        'BreedingMethodId', $other_join);
  $dbh->disconnect();

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $where_exp = ' WHERE breedingmethod.BreedingMethodId=? ';

  $sql =~ s/GROUP BY/ $where_exp GROUP BY /;

  $sql   .= ' ORDER BY breedingmethod.BreedingMethodId DESC';

  $self->logger->debug("SQL with VCol: $sql");

  my ($read_breed_meth_err, $read_breed_meth_msg, $breed_meth_data) = $self->list_breedingmethod(1,
                                                                                                 $sql,
                                                                                                 [$breedingmethod_id]
      );

  if ($read_breed_meth_err) {

    $self->logger->debug($read_breed_meth_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'BreedingMethod'  => $breed_meth_data,
                                           'VCol'       => $vcol_list,
                                           'RecordMeta' => [{'TagName' => 'BreedingMethod'}],
  };

  return $data_for_postrun_href;
}

sub del_breedingmethod_runmode {

=pod del_breedingmethod_gadmin_HELP_START
{
"OperationName": "Delete breeding method",
"Description": "Delete breeding method specified by id. Breeding method can be deleted only if not attached to any lower level related record.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='BreedingMethod (10) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'BreedingMethod (9) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdUsed": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='BreedingMethod (8) is used in specimen.' /></DATA>"}],
"ErrorMessageJSON": [{"IdUsed": "{'Error' : [{'Message' : 'BreedingMethod (8) is used in specimen.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing BreedingMethodId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self              = shift;
  my $breedingmethod_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_k_read = connect_kdb_read();

  my $breedingmethod_exist = record_existence($dbh_k_read, 'breedingmethod', 'BreedingMethodId', $breedingmethod_id);

  if (!$breedingmethod_exist) {

    my $err_msg = "BreedingMethod ($breedingmethod_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $breedingmethod_used = record_existence($dbh_k_read, 'specimen', 'BreedingMethodId', $breedingmethod_id);

  if ($breedingmethod_used) {

    my $err_msg = "BreedingMethod ($breedingmethod_id) is used in specimen.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $sql = 'DELETE FROM breedingmethodfactor WHERE BreedingMethodId=?';
  my $sth = $dbh_k_write->prepare($sql);

  $sth->execute($breedingmethod_id);

  if ($dbh_k_write->err()) {

    $self->logger->debug($dbh_k_write->errstr());
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $sql = 'DELETE FROM breedingmethod WHERE BreedingMethodId=?';
  $sth = $dbh_k_write->prepare($sql);

  $sth->execute($breedingmethod_id);

  if ($dbh_k_write->err()) {

    $self->logger->debug($dbh_k_write->errstr());
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref = [{'Message' => "BreedingMethod ($breedingmethod_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub import_pedigree_csv_runmode {

=pod import_pedigree_csv_HELP_START
{
"OperationName": "Import pedigree",
"Description": "Import specimen pedigree information in bulk using csv file.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='1 pedigree records have been inserted successfully. Time taken in seconds: 0.00802.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : '1 pedigree records have been inserted successfully. Time taken in seconds: 0.008004.'}]}",
"ErrorMessageXML": [{"Duplicate": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Row (1, 1): ((462,463,87),) (SpecimenId,ParentSpecimenId,ParentType) parent type already exist.' /></DATA>"}],
"ErrorMessageJSON": [{"Duplicate": "{'Error' : [{'Message' : 'Row (1, 1): ((462,463,87),) (SpecimenId,ParentSpecimenId,ParentType) parent type already exist.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "CSV",
"UploadFileParameterName": "uploadfile",
"HTTPParameter": [{"Required": 1, "Name": "SpecimenId", "Description": "The column number for SpecimenId column in the upload CSV file"}, {"Required": 1, "Name": "ParentSpecimenId", "Description": "The column number for ParentSpecimenId column in the upload CSV file"}, {"Required": 1, "Name": "ParentType", "Description": "The column number for ParentType column in the upload CSV file"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $start_time = [gettimeofday()];
  my $data_for_postrun_href = {};

  my $data_csv_file = $self->authen->get_upload_file();

  my $num_of_col = get_csvfile_num_of_col($data_csv_file);

  $self->logger->debug("Number of columns: $num_of_col");

  my $SpecimenId_col            = $query->param('SpecimenId');
  my $ParentSpecimenId_col      = $query->param('ParentSpecimenId');
  my $ParentType_col            = $query->param('ParentType');

  my $chk_col_def_data = { 'SpecimenId'        => $SpecimenId_col,
                           'ParentSpecimenId'  => $ParentSpecimenId_col,
                           'ParentType'        => $ParentType_col,
  };

  my $matched_col = {};

  $matched_col->{$SpecimenId_col}          = 'SpecimenId';
  $matched_col->{$ParentSpecimenId_col}    = 'ParentSpecimenId';
  $matched_col->{$ParentType_col}          = 'ParentType';

  if (defined $query->param('SelectionReason')) {

    my $SelectionReason_col = $query->param('SelectionReason');
    $chk_col_def_data->{'SelectionReason'} = $SelectionReason_col;
    $matched_col->{$SelectionReason_col}   = 'SelectionReason';
  }

  if (defined $query->param('NumberOfSpecimens')) {

    my $NumberOfSpecimens_col = $query->param('NumberOfSpecimens');
    $chk_col_def_data->{'NumberOfSpecimens'} = $NumberOfSpecimens_col;
    $matched_col->{$NumberOfSpecimens_col}   = 'NumberOfSpecimens';
  }

  if (defined $query->param('ParentTrialUnitSpecimenId')) {

    my $ParentTrialUnitSpecimenId_col = $query->param('ParentTrialUnitSpecimenId');
    $chk_col_def_data->{'ParentTrialUnitSpecimenId'} = $ParentTrialUnitSpecimenId_col;
    $matched_col->{$ParentTrialUnitSpecimenId_col}   = 'ParentTrialUnitSpecimenId';
  }

  my ($col_def_err, $col_def_msg) = check_col_definition( $chk_col_def_data, $num_of_col );

  if ($col_def_err) {

    return $self->_set_error($col_def_msg);
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

    return $self->_set_error($err_msg);
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $num_of_bulk_insert = $NB_RECORD_BULK_INSERT;

  my $dbh_write = connect_kdb_write();

  my $row_counter = 1;
  my $i = 0;
  my $num_of_rows = scalar(@{$data_aref});

  $self->logger->debug("Number of rows: $num_of_rows");

  my $unique_parent_href      = {};
  my $unique_parent_type_href = {};
  my $unique_parent_trialunit_spec_href  = {};

  my $inner_loop_max_j = 0;

  while( $i < $num_of_rows ) {

    my $j = $i;
    $inner_loop_max_j = $j + $num_of_bulk_insert;
    my $smallest_num = $num_of_rows > $inner_loop_max_j ? $inner_loop_max_j : $num_of_rows;

    my $unique_specimen_href    = {};
    my $parent_where            = '';

    #$self->logger->debug("Checking: $i, $smallest_num");

    while( $j < $smallest_num ) {

      my $data_row = $data_aref->[$j];

      my $missing_para_chk_href = { 'SpecimenId'       => $data_row->{'SpecimenId'},
                                    'ParentSpecimenId' => $data_row->{'ParentSpecimenId'},
                                    'ParentType'       => $data_row->{'ParentType'},
      };

      my ($missing_err, $missing_msg) = check_missing_value( $missing_para_chk_href );

      if ($missing_err) {

        $missing_msg = "Row ($row_counter): $missing_msg missing.";
        return $self->_set_error($missing_msg);
      }

      my $int_chk_href = { 'SpecimenId'       => $data_row->{'SpecimenId'},
                           'ParentSpecimenId' => $data_row->{'ParentSpecimenId'},
                           'ParentType'       => $data_row->{'ParentType'},
      };

      if (defined $data_row->{'NumberOfSpecimens'}) {

        $int_chk_href->{'NumberOfSpecimens'} = $data_row->{'NumberOfSpecimens'};
      }

      if (defined $data_row->{'ParentTrialUnitSpecimenId'}) {

        $int_chk_href->{'ParentTrialUnitSpecimenId'} = $data_row->{'ParentTrialUnitSpecimenId'};
      }

      my ($int_id_err, $int_id_msg) = check_integer_value( $int_chk_href );

      if ($int_id_err) {

        $int_id_msg = "Row ($row_counter): " . $int_id_msg . ' not integer.';
        return $self->_set_error($int_id_msg);
      }

      my $ctrl_char_chk_href    = {};

      if (defined $data_row->{'SelectionReason'}) {

        $ctrl_char_chk_href->{'SelectionReason'} = $data_row->{'SelectionReason'};
      }

      my $ctrl_char_reg_exp = '[\x00-\x1f]|\x7f';
      my ($ctrl_char_err, $ctrl_char_msg) = check_char( $ctrl_char_chk_href, $ctrl_char_reg_exp );

      if ($ctrl_char_err) {

        $ctrl_char_msg = "Row ($row_counter): ' invalid character $ctrl_char_msg.";
        return $self->_set_error($ctrl_char_msg);
      }

      my $specimen_id        = $data_row->{'SpecimenId'};
      my $parent_specimen_id = $data_row->{'ParentSpecimenId'};
      my $parent_type        = $data_row->{'ParentType'};

      my $parent_key = "${specimen_id}_${parent_specimen_id}_${parent_type}";
      $parent_key = $dbh_write->quote($parent_key);

      if ($unique_parent_href->{$parent_key}) {

        my $err_msg = "Row ($row_counter): duplicate parent ";
        $err_msg   .= "($specimen_id, $parent_specimen_id, $parent_type) in CSV file.";
        return $self->_set_error($err_msg);
      }
      else {

        $unique_parent_href->{$parent_key} = 1;
      }

      my $parent_trialunit_spec = $data_row->{'ParentTrialUnitSpecimenId'};
      if (length($parent_trialunit_spec) > 0) {

        $unique_parent_trialunit_spec_href->{$parent_trialunit_spec} = $row_counter;
      }

      $unique_specimen_href->{$specimen_id}        = $row_counter;
      $unique_specimen_href->{$parent_specimen_id} = $row_counter;

      $unique_parent_type_href->{$parent_type} = $row_counter;

      $parent_where .= "$parent_key,";

      $j += 1;
      $row_counter += 1;
    }

    my @specimen_list = keys(%{$unique_specimen_href});

    if (scalar(@specimen_list)) {

      my $specimen_where = join(',', @specimen_list);
      my $chk_spec_sql = "SELECT SpecimenId FROM specimen ";
      $chk_spec_sql   .= "WHERE SpecimenId IN ($specimen_where)";

      my $found_spec_data = $dbh_write->selectall_hashref($chk_spec_sql, 'SpecimenId');

      if (scalar(keys(%{$found_spec_data})) < scalar(@specimen_list)) {

        my @unknown_spec;
        my @unknown_spec_rownum;

        for my $spec_id_in_csv (@specimen_list) {

          if ( !(defined $found_spec_data->{$spec_id_in_csv}) ) {

            push(@unknown_spec, $spec_id_in_csv);
            push(@unknown_spec_rownum, $unique_specimen_href->{$spec_id_in_csv});
          }
        }

        my $err_msg = 'Row (' . join(',', @unknown_spec_rownum) . '): Specimen (';
        $err_msg   .= join(',', @unknown_spec) . ') not found.';

        return $self->_set_error($err_msg);
      }

      my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'genotype');

      my $chk_geno_perm_sql = "SELECT DISTINCT SpecimenId FROM genotypespecimen LEFT JOIN genotype ";
      $chk_geno_perm_sql   .= "ON genotypespecimen.GenotypeId = genotype.GenotypeId ";
      $chk_geno_perm_sql   .= "WHERE SpecimenId IN ($specimen_where) AND ";
      $chk_geno_perm_sql   .= "(( ($perm_str) & $LINK_PERM ) = $LINK_PERM)";

      my $specimen_id_db_data = $dbh_write->selectall_hashref($chk_geno_perm_sql, 'SpecimenId');

      my @trouble_specimen_id_list;
      my $is_perm_ok = 1;

      for my $spec_id (@specimen_list) {

        if (!($specimen_id_db_data->{$spec_id})) {

          $is_perm_ok = 0;
          push(@trouble_specimen_id_list, $spec_id);
        }
      }

      if (!$is_perm_ok) {

        my $trouble_spec_id_str = join(',', @trouble_specimen_id_list);
        my $start_row = $i + 1;
        my $end_row   = $smallest_num;
        my $err_msg = "Row ($start_row, $end_row): Specimen ($trouble_spec_id_str) permission denied.";
        return $self->_set_error($err_msg);
      }
    }

    $self->logger->debug("Parent where: $parent_where");

    if (length($parent_where) > 0) {

      chop($parent_where); # remove the last comma
      my $check_parent_sql = "SELECT CONCAT(SpecimenId, '_', CONCAT(ParentSpecimenId, '_', ParentType)) AS ID ";
      $check_parent_sql   .= "FROM pedigree ";
      $check_parent_sql   .= "WHERE CONCAT(SpecimenId, '_', CONCAT(ParentSpecimenId, '_', ParentType)) ";
      $check_parent_sql   .= "IN ($parent_where)";

      #$self->logger->debug("Check Parent SQL: $check_parent_sql");

      my ($chk_parent_read_err, $chk_parent_read_msg, $parent_data) = read_data($dbh_write, $check_parent_sql);

      if ( scalar(@{$parent_data}) ) {

        my $duplicate_parent_str = '';
        for my $parent_row (@{$parent_data}) {

          my $duplicate_parent = $parent_row->{'ID'};
          $duplicate_parent =~ /^(\d+)_(\d+)_(\d+)$/;
          my $spec_id   = $1;
          my $p_spec_id = $2;
          my $p_type    = $3;

          $duplicate_parent_str .= "($spec_id,$p_spec_id,$p_type),";
        }

        my $start_row = $i + 1;
        my $end_row   = $smallest_num;
        my $err_msg = "Row ($start_row, $end_row): ($duplicate_parent_str) (SpecimenId,ParentSpecimenId,ParentType) ";
        $err_msg   .= "parent type already exist.";
        return $self->_set_error($err_msg);
      }
    }

    $i += $num_of_bulk_insert;

    #$self->logger->debug("Smallest num: $smallest_num");
    #$self->logger->debug("I: $i");
  }

  if (scalar(keys(%{$unique_parent_type_href}))) {

    my $chk_ptype_sql = 'SELECT TypeId FROM generaltype ';
    $chk_ptype_sql   .= 'WHERE TypeId IN (' . join(',', keys(%{$unique_parent_type_href})) . ') AND ';
    $chk_ptype_sql   .= "Class='parent' AND IsTypeActive=1";

    my $parent_type_data      = $dbh_write->selectall_hashref($chk_ptype_sql, 'TypeId');

    if ( scalar(keys(%{$parent_type_data})) < scalar(keys(%{$unique_parent_type_href})) ) {

      my @unknown_parent_type;
      my @unknown_parent_type_rownum;
      for my $parent_type_in_csv (keys(%{$unique_parent_type_href})) {

        if ( !(defined $parent_type_data->{$parent_type_in_csv}) ) {

          push(@unknown_parent_type, $parent_type_in_csv);
          push(@unknown_parent_type_rownum, $unique_parent_type_href->{$parent_type_in_csv});
        }
      }

      my $err_msg = 'Row (' . join(',', @unknown_parent_type_rownum) . '): ParentType (';
      $err_msg   .= join(',', @unknown_parent_type) . ') not found or inactive.';

      return $self->_set_error($err_msg);
    }
  }

  my @parent_trialunit_spec_list = keys(%{$unique_parent_trialunit_spec_href});

  if (scalar(@parent_trialunit_spec_list) > 0) {

    my $parent_trialunit_spec_where = join(',', @parent_trialunit_spec_list);

    my $chk_parent_trialunit_spec_sql = "SELECT TrialUnitSpecimenId FROM trialunitspecimen ";
    $chk_parent_trialunit_spec_sql   .= "WHERE TrialUnitSpecimenId IN ($parent_trialunit_spec_where)";

    my $found_parent_trialunit_spec_data = $dbh_write->selectall_hashref($chk_parent_trialunit_spec_sql, 'TrialUnitSpecimenId');

    if (scalar(keys(%{$found_parent_trialunit_spec_data})) < scalar(@parent_trialunit_spec_list)) {

      my @unknown_parent_trialunit_spec;
      my @unknown_parent_trialunit_spec_rownum;

      for my $parent_trialunit_spec_in_csv (keys(%$unique_parent_trialunit_spec_href)) {
        if (!(defined $found_parent_trialunit_spec_data->{$parent_trialunit_spec_in_csv})) {

          push(@unknown_parent_trialunit_spec, $parent_trialunit_spec_in_csv);
          push(@unknown_parent_trialunit_spec_rownum, $unique_parent_trialunit_spec_href->{$parent_trialunit_spec_in_csv});
        }
      }

      my $err_msg = 'Row (' . join(',', @unknown_parent_trialunit_spec_rownum) . '): TrialUnitSpecimenId (';
      $err_msg   .= join(',', @unknown_parent_trialunit_spec) . ') not found. ' . $chk_parent_trialunit_spec_sql;
      return $self->_set_error($err_msg);
    }
  }

  my $total_affected_records = 0;
  $i = 0;

  while( $i < $num_of_rows ) {

    my $j = $i;
    my $inner_loop_max_j = $j + $num_of_bulk_insert;
    my $smallest_num = $num_of_rows > $inner_loop_max_j ? $inner_loop_max_j : $num_of_rows;

    #$self->logger->debug("Composing: $i, $smallest_num");

    my $bulk_sql = 'INSERT INTO pedigree ';
    $bulk_sql   .= '(SpecimenId,ParentSpecimenId,ParentType,SelectionReason,NumberOfSpecimens,ParentTrialUnitSpecimenId) ';
    $bulk_sql   .= 'VALUES ';

    while( $j < $smallest_num ) {

      my $data_row = $data_aref->[$j];

      my $specimen_id        = $data_row->{'SpecimenId'};
      my $parent_specimen_id = $data_row->{'ParentSpecimenId'};
      my $parent_type        = $data_row->{'ParentType'};

      my $selection_reason = $dbh_write->quote(q{});

      if (defined $data_row->{'SelectionReason'}) {

        $selection_reason = $data_row->{'SelectionReason'};
      }

      my $number_of_specimens = 'NULL';

      if (defined $data_row->{'NumberOfSpecimens'}) {

        $number_of_specimens = $data_row->{'NumberOfSpecimens'};
      }

      my $parent_trial_unit_spec = 'NULL';

      if (length($data_row->{'ParentTrialUnitSpecimenId'}) > 0) {

        $parent_trial_unit_spec = $data_row->{'ParentTrialUnitSpecimenId'};
      }

      $bulk_sql .= "($specimen_id,$parent_specimen_id,$parent_type,$selection_reason,$number_of_specimens,$parent_trial_unit_spec),";

      $j += 1;
    }

    #$self->logger->debug("Bulk SQL: $bulk_sql");

    chop($bulk_sql);            # remove excessive trailling comma

    my $nrows_inserted = $dbh_write->do($bulk_sql);

    if ($dbh_write->err()) {

      $self->logger->debug('Error code: ' . $dbh_write->err());
      $self->logger->debug('Error: ' . $dbh_write->errstr());

      return $self->_set_error('Unexpected error.');
    }

    $total_affected_records += $nrows_inserted;

    $i += $num_of_bulk_insert;
  }

  $dbh_write->disconnect();

  my $elapsed_time = tv_interval($start_time);

  my $info_msg = "$total_affected_records pedigree records have been inserted successfully. ";
  $info_msg   .= "Time taken in seconds: $elapsed_time.";
  my $info_msg_aref = [{'Message' => $info_msg}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub export_specimen_runmode {

=pod export_specimen_HELP_START
{
"OperationName": "Export specimens",
"Description": "Export a list of specimens into a csv file",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Time taken in seconds: 0.08417.' /><OutputFile csv='http://kddart-d.diversityarrays.com/data/admin/export_specimen_4a1d0104cd67f2f3a20a8b35afd26d9f.csv' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Time taken in seconds: 0.02813.'}],'OutputFile' : [{'csv' : 'http://kddart-d.diversityarrays.com/data/admin/export_specimen_4a1d0104cd67f2f3a20a8b35afd26d9f.csv'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPParameter": [{"Required": 0, "Name": "Filtering", "Description": "Filtering parameter string consisting of filtering expressions which are separated by ampersand (&) which needs to be encoded if HTTP GET method is used. Each filtering expression is composed of a database field name, a filtering operator and the filtering value."}, {"Required": 0, "Name": "FieldList", "Description": "Comma separated value of wanted fields."}, {"Required": 0, "Name": "Sorting", "Description": "Comma separated value of SQL sorting phrases."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $start_time = [gettimeofday()];
  my $data_for_postrun_href = {};

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

  my $username             = $self->authen->username();
  my $doc_root             = $ENV{'DOCUMENT_ROOT'};
  my $export_data_path     = "${doc_root}/data/$username";
  my $current_runmode      = $self->get_current_runmode();
  my $lock_filename        = "${current_runmode}.lock";

  if ( !(-e $export_data_path) ) {

    mkdir($export_data_path);
  }

  my $lockfile = File::Lockfile->new( $lock_filename, $export_data_path );
  my $pid = $lockfile->check();
  if ( $pid ) {
    $self->logger->debug("$lock_filename exists in $export_data_path");
    my $msg = 'Lockfile exists: either another process of this export is running or ';
    $msg   .= 'there was an unexpected error regarding clearing this lockfile.';
    return $self->_set_error( $msg );
  }

  my $dbh = connect_kdb_read();
  my $field_list = ['specimen.*', 'VCol*'];
  my $pre_data_other_join = '';

  my ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $field_list, 'specimen',
                                                                        'SpecimenId', '');

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql   .= " LIMIT 1";

  $self->logger->debug("SQL with VCol: $sql");

  my ($sam_specimen_err, $sam_specimen_msg, $sam_specimen_data) = $self->list_specimen(0, 0, $sql);

  if ($sam_specimen_err) {

    $self->logger->debug($sam_specimen_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $sample_specimen_aref = $sam_specimen_data;

  my @field_list_all = keys(%{$sample_specimen_aref->[0]});

  my $sql_field_list = [];

  #no field return, it means no record. error prevention
  if (scalar(@field_list_all) == 0) {

    push(@field_list_all, '*');
  }

  my $final_field_list = \@field_list_all;

  if (length($field_list_csv) > 0) {

    my ($sel_field_err, $sel_field_msg, $sel_field_list) = parse_selected_field($field_list_csv,
                                                                                \@field_list_all,
                                                                                'SpecimenId');

    if ($sel_field_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;

    for my $fd_name (@{$final_field_list}) {

      # need to remove location field because generate_factor_sql does not understand these field
      if ( (!($fd_name =~ /specimenlocation/)) && (!($fd_name =~ /specimenlocdt/)) && (!($fd_name =~ /specimenlocdescription/))) {
        
        push(@{$sql_field_list}, $fd_name);
      }
    }
  } else {
    for my $fd_name (@{$final_field_list}) {

      # need to remove location field because generate_factor_sql does not understand these field
      if ( (!($fd_name =~ /specimenlocation/)) && (!($fd_name =~ /specimenlocdt/)) && (!($fd_name =~ /specimenlocdescription/))) {
        
        push(@{$sql_field_list}, $fd_name);
      }
    }
  }

  my $other_join = '';

  ($vcol_err, $trouble_vcol, $sql, $vcol_list) = generate_factor_sql($dbh, $sql_field_list, 'specimen',
                                                                     'SpecimenId', $other_join);
  $dbh->disconnect();

  if ($vcol_err) {

    my $err_msg = "Problem with virtual column ($trouble_vcol) containing space.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $field_name2table_name  = { 'GenotypeId' => 'genotypespecimen' };
  my $validation_func_lookup = {};

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering('SpecimenId',
                                                                              'specimen',
                                                                              $filtering_csv,
                                                                              $final_field_list,
                                                                              $validation_func_lookup,
                                                                              $field_name2table_name);

  $self->logger->debug("Filter phrase: $filter_phrase");

  if ($filter_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $filter_msg}]};

    return $data_for_postrun_href;
  }

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

    $sql .= ' ORDER BY specimen.SpecimenId DESC';
  }

  $self->logger->debug("SQL with VCol: $sql");

  my $sql2md5 = md5_hex($sql);

  my $specimen_filename    = "export_specimen_$sql2md5.csv";
  my $specimen_file        = "${export_data_path}/$specimen_filename";

  # Genotype permission is checked in list_specimen
  my ($read_spec_err, $read_spec_msg, $specimen_data, $max_nb_genotype) = $self->list_specimen(0, 1, $sql,
                                                                                               $where_arg);

  if ($read_spec_err) {

    $self->logger->debug($read_spec_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  # Flatter GenotypeId which is an arrayref into multiple columns
  my @flattered_spec_data;

  for my $specimen_row (@{$specimen_data}) {

    #if ( !(defined $specimen_row->{'Genotype'}) ) {

    #  $self->logger->debug("SpecimenId: " . $specimen_row->{'SpecimenId'} . " has no genotype record.");
    #  next;
    #}

    my $geno_data = $specimen_row->{'Genotype'};
    my $nb_genotype = scalar(@{$geno_data});

    for(my $i = 0; $i < $max_nb_genotype; $i++) {

      my $field_num = $i + 1;
      my $new_geno_field_name = "GenotypeId${field_num}";

      if ($i < $nb_genotype) {

        $specimen_row->{$new_geno_field_name} = $geno_data->[$i]->{'GenotypeId'};
      }
      else {

        $specimen_row->{$new_geno_field_name} = '';
      }
    }

    delete($specimen_row->{'Genotype'});
    push(@flattered_spec_data, $specimen_row);
  }

  my $fieldname_order = { 'SpecimenId'        => 0,
                          'SpecimenName'      => 1,
                          'SpecimenBarcode'   => 2,
                          'BreedingMethodId'  => 3,
                          'IsActive'          => 4,
                          'Pedigree'          => 5,
                          'SelectionHistory'  => 6,
                          'FilialGeneration'  => 7,
  };

  for(my $i = 1; $i <= $max_nb_genotype; $i++) {

    $fieldname_order->{"GenotypeId$i"} = $i + 7;
  }

  arrayref2csvfile($specimen_file, $fieldname_order, \@flattered_spec_data);

  my $url = reconstruct_server_url();
  my $elapsed_time = tv_interval($start_time);

  my $href_info = { 'csv'  => "$url/data/$username/$specimen_filename" };

  my $time_info = { 'Message' => "Time taken in seconds: $elapsed_time." };

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'OutputFile' => [$href_info], 'Info' => [$time_info] };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_pedigree {

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

  my $gadmin_status = $self->authen->gadmin_status();

  my $extra_attr_pedigree_data = [];

  if ($extra_attr_yes) {

    for my $pedigree_row (@{$data_aref}) {

      my $pedigree_id    = $pedigree_row->{'PedigreeId'};

      if ($gadmin_status eq '1') {

        $pedigree_row->{'update'} = "update/pedigree/$pedigree_id";
        $pedigree_row->{'delete'} = "delete/pedigree/$pedigree_id";
      }

      push(@{$extra_attr_pedigree_data}, $pedigree_row);
    }
  }
  else {

    $extra_attr_pedigree_data = $data_aref;
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_pedigree_data);
}

sub list_gen_pedigree {

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

  my $gadmin_status = $self->authen->gadmin_status();

  my $extra_attr_gen_pedigree_data = [];

  if ($extra_attr_yes) {

    for my $gen_pedigree_row (@{$data_aref}) {

      my $gen_pedigree_id    = $gen_pedigree_row->{'GenPedigreeId'};

      if ($gadmin_status eq '1') {

        $gen_pedigree_row->{'update'} = "update/genpedigree/$gen_pedigree_id";
        $gen_pedigree_row->{'delete'} = "delete/genpedigree/$gen_pedigree_id";
      }

      push(@{$extra_attr_gen_pedigree_data}, $gen_pedigree_row);
    }
  }
  else {

    $extra_attr_gen_pedigree_data = $data_aref;
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_gen_pedigree_data);
}

sub export_pedigree_runmode {

=pod export_pedigree_HELP_START
{
"OperationName": "Export pedigree",
"Description": "Export specimen pedigree into csv file.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Time taken in seconds: 0.02539.' /><OutputFile csv='http://kddart-d.diversityarrays.com/data/admin/export_pedigree_d126d2a41c9a5e7170be8df05dbd0a14.csv' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Time taken in seconds: 0.022992.'}],'OutputFile' : [{'csv' : 'http://kddart-d.diversityarrays.com/data/admin/export_pedigree_d126d2a41c9a5e7170be8df05dbd0a14.csv'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPParameter": [{"Required": 0, "Name": "Filtering", "Description": "Filtering parameter string consisting of filtering expressions which are separated by ampersand (&) which needs to be encoded if HTTP GET method is used. Each filtering expression is composed of a database field name, a filtering operator and the filtering value."}, {"Required": 0, "Name": "FieldList", "Description": "Comma separated value of wanted fields."}, {"Required": 0, "Name": "Sorting", "Description": "Comma separated value of SQL sorting phrases."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $start_time = [gettimeofday()];
  my $data_for_postrun_href = {};

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

  my $username             = $self->authen->username();
  my $doc_root             = $ENV{'DOCUMENT_ROOT'};
  my $export_data_path     = "${doc_root}/data/$username";
  my $current_runmode      = $self->get_current_runmode();
  my $lock_filename        = "${current_runmode}.lock";

  if ( !(-e $export_data_path) ) {

    mkdir($export_data_path);
  }

  my $lockfile = File::Lockfile->new( $lock_filename, $export_data_path );
  my $pid = $lockfile->check();
  if ( $pid ) {
    $self->logger->debug("$lock_filename exists in $export_data_path");
    my $msg = 'Lockfile exists: either another process of this export is running or ';
    $msg   .= 'there was an unexpected error regarding clearing this lockfile.';
    return $self->_set_error( $msg );
  }

  my $sql   = " SELECT * FROM pedigree LIMIT 1";

  my ($sam_pedigree_err, $sam_pedigree_msg, $sam_pedigree_data) = $self->list_pedigree(0, $sql);

  if ($sam_pedigree_err) {

    $self->logger->debug($sam_pedigree_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $sample_pedigree_aref = $sam_pedigree_data;

  my @field_list_all = keys(%{$sample_pedigree_aref->[0]});

  #no field return, it means no record. error prevention
  if (scalar(@field_list_all) == 0) {

    push(@field_list_all, '*');
  }

  my $final_field_list = \@field_list_all;

  $sql = 'SELECT ' . join(',',@{$final_field_list}) . ' FROM pedigree ';

  if (length($field_list_csv) > 0) {

    my ($sel_field_err, $sel_field_msg, $sel_field_list) = parse_selected_field($field_list_csv,
                                                                                \@field_list_all,
                                                                                'PedigreeId');

    if ($sel_field_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;
  }

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering('PedigreeId',
                                                                              'pedigree',
                                                                              $filtering_csv,
                                                                              $final_field_list,
                                                                              {},
                                                                              {});

  $self->logger->debug("Filter phrase: $filter_phrase");

  if ($filter_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $filter_msg}]};

    return $data_for_postrun_href;
  }

  if (length($filter_phrase) > 0) {

    $sql .= " WHERE $filter_phrase ";
  }

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

    $sql .= ' ORDER BY pedigree.PedigreeId DESC';
  }

  my $sql2md5 = md5_hex($sql);

  my $pedigree_filename    = "export_pedigree_$sql2md5.csv";
  my $pedigree_file        = "${export_data_path}/$pedigree_filename";

  # where_arg here because of the filtering
  my ($read_ped_err, $read_ped_msg, $pedigree_data) = $self->list_pedigree(0, $sql, $where_arg);

  if ($read_ped_err) {

    $self->logger->debug($read_ped_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $fieldname_order = { 'PedigreeId'        => 0,
                          'SpecimenId'        => 1,
                          'ParentSpecimenId'  => 2,
                          'ParentType'        => 3,
                          'SelectionReason'   => 4,
                          'NumberOfSpecimens' => 5,
  };

  arrayref2csvfile($pedigree_file, $fieldname_order, $pedigree_data);

  my $url = reconstruct_server_url();
  my $elapsed_time = tv_interval($start_time);

  my $href_info = { 'csv'  => "$url/data/$username/$pedigree_filename" };

  my $time_info = { 'Message' => "Time taken in seconds: $elapsed_time." };

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'OutputFile' => [$href_info], 'Info' => [$time_info] };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub add_pedigree_runmode {

=pod add_pedigree_HELP_START
{
"OperationName": "Add pedigree",
"Description": "Add a new specimen record into pedigree tree.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "pedigree",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='4' ParaName='PedigreeId' /><Info Message='Pedigree (4) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '3','ParaName' : 'PedigreeId'}],'Info' : [{'Message' : 'Pedigree (3) has been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error SpecimenId='SpecimenId (482): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'SpecimenId' : 'SpecimenId (482): not found.'}]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'OwnGroupId' => 1};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'pedigree', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $specimen_id           = $query->param('SpecimenId');
  my $p_specimen_id         = $query->param('ParentSpecimenId');
  my $parent_type           = $query->param('ParentType');

  my $select_reason         = undef;

  if ( length($query->param('SelectionReason')) > 0) {

    $select_reason = $query->param('SelectionReason');
  }

  my $chk_int_href = {};
  my $nb_of_specimens       = undef;

  if ( length($query->param('NumberOfSpecimens')) > 0) {

    $nb_of_specimens = $query->param('NumberOfSpecimens');
    $chk_int_href->{'NumberOfSpecimens'} = $nb_of_specimens;
  }

  my $parent_trialunit_spec = undef;

  if (length($query->param('ParentTrialUnitSpecimenId')) > 0) {

    $parent_trialunit_spec = $query->param('ParentTrialUnitSpecimenId');
    $chk_int_href->{'ParentTrialUnitSpecimenId'} = $parent_trialunit_spec;
  }

  my ($int_err, $int_err_href) = check_integer_href( $chk_int_href );

  if ($int_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $int_err_href}]};

    return $data_for_postrun_href;
  }

  my $dbh_write = connect_kdb_write();

  if (!type_existence($dbh_write, 'parent', $parent_type)) {

    my $err_msg = "ParentType ($parent_type): not found or inactive.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'ParentType' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (!record_existence($dbh_write, 'specimen', 'SpecimenId', $specimen_id)) {

    my $err_msg = "SpecimenId ($specimen_id): not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'SpecimenId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (!record_existence($dbh_write, 'specimen', 'SpecimenId', $p_specimen_id)) {

    my $err_msg = "ParentSpecimenId ($p_specimen_id): not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'ParentSpecimenId' => $err_msg}]};

    return $data_for_postrun_href;
  }
  
  my $group_id  = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'genotype');

  my $geno_specimen_sql = "SELECT genotype.GenotypeId ";
  $geno_specimen_sql   .= "FROM genotype LEFT JOIN genotypespecimen ON ";
  $geno_specimen_sql   .= "genotype.GenotypeId = genotypespecimen.GenotypeId ";
  $geno_specimen_sql   .= "WHERE genotypespecimen.SpecimenId IN ($specimen_id, $p_specimen_id)";

  my ($geno_err, $geno_msg, $geno_data) = read_data($dbh_write, $geno_specimen_sql);

  if ($geno_err) {

    $self->logger->debug($geno_msg);
    return $self->_set_error('Unexpected error.');
  }

  $geno_specimen_sql   .= " AND ((($perm_str) & $LINK_PERM) = $LINK_PERM)";

  $self->logger->debug("Genotype specimen permission SQL: $geno_specimen_sql");

  my ($geno_p_err, $geno_p_msg, $geno_p_data_perm) = read_data($dbh_write, $geno_specimen_sql);

  if ($geno_p_err) {

    $self->logger->debug($geno_p_msg);
    return $self->_set_error('Unexpected error.');
  }

  if (scalar(@{$geno_data}) != scalar(@{$geno_p_data_perm})) {

    my $err_msg = "SpecimenId ($specimen_id), ParentSpecimenId ($p_specimen_id): permission denied.";
    return $self->_set_error($err_msg);
  }

  my $sql = 'INSERT INTO pedigree SET ';
  $sql   .= 'SpecimenId=?, ';
  $sql   .= 'ParentSpecimenId=?, ';
  $sql   .= 'ParentType=?, ';
  $sql   .= 'SelectionReason=?, ';
  $sql   .= 'NumberOfSpecimens=?, ';
  $sql   .= 'ParentTrialUnitSpecimenId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($specimen_id, $p_specimen_id, $parent_type, $select_reason, $nb_of_specimens, $parent_trialunit_spec);

  if ($dbh_write->err()) {

    my $db_err = $dbh_write->err();

    $self->logger->debug("Err: $db_err");

    if ($db_err == 1062) {

      my $err_msg = "Duplicate entry (SpecimenId, ParentSpecimenId, ParentType): ";
      $err_msg   .= "($specimen_id, $p_specimen_id, $parent_type).";
      return $self->_set_error($err_msg);
    }
    else {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }
  }
  $sth->finish();

  my $pedigree_id = $dbh_write->last_insert_id(undef, undef, 'pedigree', 'PedigreeId');

  $dbh_write->disconnect();

  my $info_msg_aref  = [{'Message' => "Pedigree ($pedigree_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$pedigree_id", 'ParaName' => 'PedigreeId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref,
                                           'ReturnId'  => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_pedigree_runmode {

=pod update_pedigree_gadmin_HELP_START
{
"OperationName": "Update pedigree",
"Description": "Update specimen pedigree record specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "pedigree",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Pedigree (3) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Pedigree (4) has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error SpecimenId='SpecimenId (482): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'SpecimenId' : 'SpecimenId (482): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing PedigreeId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self        = shift;
  my $query       = $self->query();
  my $pedigree_id = $self->param('id');

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'OwnGroupId' => 1};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'pedigree', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $dbh_write = connect_kdb_write();

  if (!record_existence($dbh_write, 'pedigree', 'PedigreeId', $pedigree_id)) {

    my $err_msg = "PedigreeId ($pedigree_id): not found.";
    return $self->_set_error($err_msg);
  }

  my $specimen_id           = $query->param('SpecimenId');
  my $p_specimen_id         = $query->param('ParentSpecimenId');
  my $parent_type           = $query->param('ParentType');

  my $select_reason         = undef;

  if ( length($query->param('SelectionReason')) > 0) {

    $select_reason = $query->param('SelectionReason');
  }

  my $chk_int_href = {};
  my $nb_of_specimens       = undef;

  if ( length($query->param('NumberOfSpecimens')) > 0) {

    $nb_of_specimens = $query->param('NumberOfSpecimens');
    $chk_int_href->{'NumberOfSpecimens'} = $nb_of_specimens;
  }

  my $parent_trialunit_spec = undef;

  if (length($query->param('ParentTrialUnitSpecimenId')) > 0) {

    $parent_trialunit_spec = $query->param('ParentTrialUnitSpecimenId');
    $chk_int_href->{'ParentTrialUnitSpecimenId'} = $parent_trialunit_spec;
  }

  my ($int_err, $int_err_href) = check_integer_href( $chk_int_href );

  if ($int_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $int_err_href}]};

    return $data_for_postrun_href;
  }

  if (!type_existence($dbh_write, 'parent', $parent_type)) {

    my $err_msg = "ParentType ($parent_type): not found or inactive.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'ParentType' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (!record_existence($dbh_write, 'specimen', 'SpecimenId', $specimen_id)) {

    my $err_msg = "SpecimenId ($specimen_id): not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'SpecimenId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (!record_existence($dbh_write, 'specimen', 'SpecimenId', $p_specimen_id)) {

    my $err_msg = "ParentSpecimenId ($p_specimen_id): not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'ParentSpecimenId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (defined $parent_trialunit_spec && !record_existence($dbh_write, 'trialunitspecimen', 'TrialUnitSpecimenId', $parent_trialunit_spec)) {

    my $err_msg = "ParentTrialUnitSpecimenId ($parent_trialunit_spec): not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'ParentTrialUnitSpecimenId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id  = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'genotype');

  my $geno_specimen_sql = "SELECT genotype.GenotypeId ";
  $geno_specimen_sql   .= "FROM genotype LEFT JOIN genotypespecimen ON ";
  $geno_specimen_sql   .= "genotype.GenotypeId = genotypespecimen.GenotypeId ";
  $geno_specimen_sql   .= "WHERE genotypespecimen.SpecimenId IN ($specimen_id, $p_specimen_id)";

  my ($geno_err, $geno_msg, $geno_data) = read_data($dbh_write, $geno_specimen_sql);

  if ($geno_err) {

    $self->logger->debug($geno_msg);
    return $self->_set_error('Unexpected error.');
  }

  $geno_specimen_sql   .= " AND ((($perm_str) & $LINK_PERM) = $LINK_PERM)";

  $self->logger->debug("Genotype specimen permission SQL: $geno_specimen_sql");

  my ($geno_p_err, $geno_p_msg, $geno_p_data_perm) = read_data($dbh_write, $geno_specimen_sql);

  if ($geno_p_err) {

    $self->logger->debug($geno_p_msg);
    return $self->_set_error('Unexpected error.');
  }

  if (scalar(@{$geno_data}) != scalar(@{$geno_p_data_perm})) {

    my $err_msg = "SpecimenId ($specimen_id), ParentSpecimenId ($p_specimen_id): permission denied.";
    return $self->_set_error($err_msg);
  }

  my $sql = 'SELECT PedigreeId FROM pedigree WHERE SpecimenId=? AND ParentSpecimenId=? AND ParentType=?';

  my ($r_pedigree_err, $db_pedigree_id) = read_cell($dbh_write, $sql, [$specimen_id, $p_specimen_id, $parent_type]);

  if ($r_pedigree_err) {

    $self->logger->debug("Read PedigreeId failed");
    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_pedigree_id) > 0) {

    my $err_msg = "Specimen ($specimen_id), ParentSpecimen ($p_specimen_id), ParentType ($parent_type): already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql    = 'UPDATE pedigree SET ';
  $sql   .= 'SpecimenId=?, ';
  $sql   .= 'ParentSpecimenId=?, ';
  $sql   .= 'ParentType=?, ';
  $sql   .= 'SelectionReason=?, ';
  $sql   .= 'NumberOfSpecimens=?, ';
  $sql   .= 'ParentTrialUnitSpecimenId=? ';
  $sql   .= 'WHERE PedigreeId=?';


  my $sth = $dbh_write->prepare($sql);
  $sth->execute($specimen_id, $p_specimen_id, $parent_type, $select_reason, $nb_of_specimens, $parent_trialunit_spec, $pedigree_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref  = [{'Message' => "Pedigree ($pedigree_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub del_pedigree_runmode {

=pod del_pedigree_gadmin_HELP_START
{
"OperationName": "Delete pedigree",
"Description": "Delete specimen pedigree specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='PedigreeId (4) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'PedigreeId (3) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='PedigreeId (6) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'PedigreeId (6) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing PedigreeId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self             = shift;
  my $pedigree_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_k_read = connect_kdb_read();

  my $pedigree_exist = record_existence($dbh_k_read, 'pedigree', 'PedigreeId', $pedigree_id);

  if (!$pedigree_exist) {

    my $err_msg = "PedigreeId ($pedigree_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $sql = 'DELETE FROM pedigree WHERE PedigreeId=?';
  my $sth = $dbh_k_write->prepare($sql);

  $sth->execute($pedigree_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref = [{'Message' => "PedigreeId ($pedigree_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub add_genpedigree_runmode {

=pod add_genpedigree_HELP_START
{
"OperationName": "Add pedigree for genotype",
"Description": "Add a new pedigree record into genotype pedigree tree.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "genpedigree",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='3' ParaName='GenPedigreeId' /><Info Message='GenPedigree (3) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '4','ParaName' : 'GenPedigreeId'}],'Info' : [{'Message' : 'GenPedigree (4) has been added successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='GenotypeId (4): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'GenotypeId (4): not found.'}]}"}],
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
                                                                                'genpedigree', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $genotype_id           = $query->param('GenotypeId');
  my $p_genotype_id         = $query->param('ParentGenotypeId');
  my $parent_type           = $query->param('GenParentType');

  my $chk_int_href          = {};
  my $nb_of_genotypes       = undef;

  if ( length($query->param('NumberOfGenotypes')) > 0) {

    $nb_of_genotypes                     = $query->param('NumberOfGenotypes');
    $chk_int_href->{'NumberOfGenotypes'} = $nb_of_genotypes;
  }

  my ($int_err, $int_err_href) = check_integer_href( $chk_int_href );

  if ($int_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$int_err_href]};

    return $data_for_postrun_href;
  }

  my $dbh_write = connect_kdb_write();

  if (!type_existence($dbh_write, 'genparent', $parent_type)) {

    my $err_msg = "ParentType ($parent_type): not found or inactive.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (!record_existence($dbh_write, 'genotype', 'GenotypeId', $genotype_id)) {

    my $err_msg = "GenotypeId ($genotype_id): not found.";
    return $self->_set_error($err_msg);
  }

  if (!record_existence($dbh_write, 'genotype', 'GenotypeId', $p_genotype_id)) {

    my $err_msg = "ParentGenotypeId ($p_genotype_id): not found.";
    return $self->_set_error($err_msg);
  }

  my $group_id  = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_geno_ok, $trouble_geno_id_aref) = check_permission($dbh_write, 'genotype', 'GenotypeId',
                                                             [$genotype_id], $group_id, $gadmin_status,
                                                             $READ_WRITE_PERM);

  if (!$is_geno_ok) {

    my $err_msg = "Permission denied: Group ($group_id) and Genotype ($genotype_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'GenotypeId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($is_p_geno_ok, $trouble_p_geno_id_aref) = check_permission($dbh_write, 'genotype', 'GenotypeId',
                                                                 [$p_genotype_id], $group_id, $gadmin_status,
                                                                 $READ_LINK_PERM);

  if (!$is_geno_ok) {

    my $err_msg = "Permission denied: Group ($group_id) and Genotype ($p_genotype_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'ParentGenotypeId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'INSERT INTO genpedigree SET ';
  $sql   .= 'GenotypeId=?, ';
  $sql   .= 'ParentGenotypeId=?, ';
  $sql   .= 'GenParentType=?, ';
  $sql   .= 'NumberOfGenotypes=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($genotype_id, $p_genotype_id, $parent_type, $nb_of_genotypes);

  if ($dbh_write->err()) {

    my $db_err = $dbh_write->err();

    $self->logger->debug("Err: $db_err");

    if ($db_err == 1062) {

      my $err_msg = "Duplicate entry (GenotypeId, ParentGenotypeId, GenParentType): ";
      $err_msg   .= "($genotype_id, $p_genotype_id, $parent_type).";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
    else {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

      return $data_for_postrun_href;
    }
  }
  $sth->finish();

  my $gen_pedigree_id = $dbh_write->last_insert_id(undef, undef, 'genpedigree', 'GenPedigreeId');

  $dbh_write->disconnect();

  my $info_msg_aref  = [{'Message' => "GenPedigree ($gen_pedigree_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$gen_pedigree_id", 'ParaName' => 'GenPedigreeId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref,
                                           'ReturnId'  => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_gen_ancestor_runmode {

=pod list_gen_ancestor_HELP_START
{
"OperationName": "List genotype ancestors",
"Description": "List all ancestors of the genotype from pedigree tree.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='Ancestor' /><Ancestor NumberOfGenotypes='' ParentGenotypeId='2' GenotypeId='1' GenParentType='59' GenPedigreeId='5' Level='0' GenParentTypeName='GenParentType - 8659523' ParentGenotypeName='Geno_5317468' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'Ancestor'}],'Ancestor' : [{'ParentGenotypeId' : '2','NumberOfGenotypes' : null,'GenotypeId' : '1','GenParentType' : '59','GenPedigreeId' : '5','Level' : 0,'GenParentTypeName' : 'GenParentType - 8659523','ParentGenotypeName' : 'Geno_5317468'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPParameter": [{"Required": 0, "Name": "Level", "Description": "The number of recursions to retrieve the parentage records from the database"}, {"Required": 0, "Name": "OutputType", "Description": "Type of the structure of the genotype ancestor records that will be returned. The possible values are ALL and KEYANCESTOR. ALL is for returning all genotype ancestor records found by this recursive process. KEYANCESTOR is when DAL will separate the genotype pedigree records for genotypes that have been used as ancestors for more than once like being parents and grand parents from pedigree records of the genotypes that are used for as ancestors for only one time. ALL is the default value."}],
"URLParameter": [{"ParameterName": "genoid", "Description": "Existing GenotypeId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $genotype_id = $self->param('genoid');

  my $level = '';

  if (defined $query->param('Level')) {

    if (length($query->param('Level')) > 0) {

      $level = $query->param('Level');
    }
  }

  my $stopping_level = 0;

  if (length($level) > 0) {

    my ($int_err, $int_err_href) = check_integer_href( {'Level' => $level} );

    if ($int_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [$int_err_href]};

      return $data_for_postrun_href;
    }

    if ($level > $MAX_RECURSIVE_ANCESTOR_LEVEL) {

      $level = $MAX_RECURSIVE_ANCESTOR_LEVEL;
    }

    # Make it into integer
    $stopping_level = $level + 0;
  }

  my $structure_type = 'ALL';

  if (defined $query->param('OutputType')) {

    if ( uc($query->param('OutputType')) eq 'KEYANCESTOR' ) {

      $structure_type = 'KEYANCESTOR';
    }
  }

  my $dbh = connect_kdb_read();

  if (!record_existence($dbh, 'genotype', 'GenotypeId', $genotype_id)) {

    my $err_msg = "GenotypeId ($genotype_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id  = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_geno_ok, $trouble_geno_id_aref) = check_permission($dbh, 'genotype', 'GenotypeId',
                                                             [$genotype_id], $group_id, $gadmin_status,
                                                             $READ_PERM);

  if (!$is_geno_ok) {

    my $err_msg = "Permission denied: Group ($group_id) and Genotype ($genotype_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $top_level_sql = 'SELECT genpedigree.*, genotype.GenotypeName AS ParentGenotypeName, ';
  $top_level_sql   .= 'generaltype.TypeName AS GenParentTypeName ';
  $top_level_sql   .= 'FROM genpedigree LEFT JOIN genotype ON genpedigree.ParentGenotypeId = genotype.GenotypeId ';
  $top_level_sql   .= 'LEFT JOIN generaltype ON genpedigree.GenParentType = generaltype.TypeId ';
  $top_level_sql   .= 'WHERE genpedigree.GenotypeId=?';

  # ------------ Second Optimisation Edit number #2 -------------------------------

  my $frequency_href = {};

  my ($read_ancestor_err, $read_ancestor_msg,
      $finish_level, $ancestor_data) = recurse_read($dbh, $top_level_sql, [$genotype_id],
                                                    'ParentGenotypeId', 0, $stopping_level, $frequency_href);

  if ($read_ancestor_err) {

    $self->logger->debug("Recurse read failed: $read_ancestor_msg - finish level: $finish_level");

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  if ( uc($structure_type) eq 'KEYANCESTOR' ) {

    my $uniq_ancestor_data = [];
    my $key_ancestor_data  = [];

    my $uniq_key_ancestor_href = {};

    my $nb_rec = scalar(@{$ancestor_data});

    for (my $i = 0; $i < $nb_rec; $i += 1) {

      my $ancestor_rec = $ancestor_data->[$i];

      my $child_id   = $ancestor_rec->{'GenotypeId'};
      my $parent_id  = $ancestor_rec->{'ParentGenotypeId'};
      my $type_id    = $ancestor_rec->{'GenParentType'};

      if ( ! (defined $frequency_href->{$child_id}) ) {

        push(@{$uniq_ancestor_data}, $ancestor_rec);
        $self->logger->debug("Checking if this condition is true for CHILD: $child_id");
      }
      else {

        my $count = $frequency_href->{$child_id};

        $self->logger->debug("CHILD ID: $child_id - COUNT: $count");

        # if my child has been used as a parent more than once,
        # then i am very likely to be a grand parent more than once as well

        if ($count > 1) {

          if (! (defined $uniq_key_ancestor_href->{"${child_id}_${parent_id}_${type_id}"}) ) {

            delete($ancestor_rec->{'Level'});
            push(@{$key_ancestor_data}, $ancestor_rec);

            $uniq_key_ancestor_href->{"${child_id}_${parent_id}_${type_id}"} = 1;
          }
        }
        else {

          push(@{$uniq_ancestor_data}, $ancestor_rec);
        }
      }
    }

    my @sorted_uniq_ancestor_data = sort { $a->{'Level'} <=> $b->{'Level'} } @{$uniq_ancestor_data};
    my @sorted_key_ancestor_data  = sort { $a->{'GenotypeId'} <=> $b->{'GenotypeId'} } @{$key_ancestor_data};

    $data_for_postrun_href->{'Error'}     = 0;
    $data_for_postrun_href->{'Data'}      = {'Ancestor'    => \@sorted_uniq_ancestor_data,
                                             'KeyAncestor' => \@sorted_key_ancestor_data,
                                             'RecordMeta'  => [{'TagName' => 'Ancestor'}],
                                            };

    # ------------ Second Optimisation Edit number #2 -------------------------------
  }
  elsif ( uc($structure_type) eq 'ALL' ) {

    $data_for_postrun_href->{'Error'}     = 0;
    $data_for_postrun_href->{'Data'}      = {'Ancestor'    => $ancestor_data,
                                             'RecordMeta'  => [{'TagName' => 'Ancestor'}],
                                            };
  }

  return $data_for_postrun_href;
}

sub list_gen_descendant_runmode {

=pod list_gen_descendant_HELP_START
{
"OperationName": "List genotype descendants",
"Description": "List all descendants of the genotype from a pedigree tree.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='Descendant' /><Descendant NumberOfGenotypes='' ParentGenotypeId='2' GenotypeName='Geno_5736568' GenotypeId='1' Level='0' GenPedigreeId='5' GenParentType='59' GenParentTypeName='GenParentType - 8659523' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'Descendant'}],'Descendant' : [{'ParentGenotypeId' : '2','NumberOfGenotypes' : null,'GenotypeId' : '1','GenotypeName' : 'Geno_5736568','GenParentType' : '59','GenPedigreeId' : '5','Level' : 0,'GenParentTypeName' : 'GenParentType - 8659523'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPParameter": [{"Required": 0, "Name": "Level", "Description": "The number of recursions to retrieve the parentage records from the database"}],
"URLParameter": [{"ParameterName": "genoid", "Description": "Existing GenotypeId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $genotype_id = $self->param('genoid');

  my $level = '';

  if (defined $query->param('Level')) {

    if (length($query->param('Level')) > 0) {

      $level = $query->param('Level');
    }
  }

  my $stopping_level = 0;

  if (length($level) > 0) {

    my ($int_err, $int_err_href) = check_integer_href( {'Level' => $level} );

    if ($int_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [$int_err_href]};

      return $data_for_postrun_href;
    }

    if ($level > $MAX_RECURSIVE_DESCENDANT_LEVEL) {

      $level = $MAX_RECURSIVE_DESCENDANT_LEVEL;
    }

    $stopping_level = $level + 0;
  }

  my $dbh = connect_kdb_read();

  if (!record_existence($dbh, 'genotype', 'GenotypeId', $genotype_id)) {

    my $err_msg = "GenotypeId ($genotype_id): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id  = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_geno_ok, $trouble_geno_id_aref) = check_permission($dbh, 'genotype', 'GenotypeId',
                                                             [$genotype_id], $group_id, $gadmin_status,
                                                             $READ_PERM);

  if (!$is_geno_ok) {

    my $err_msg = "Permission denied: Group ($group_id) and Genotype ($genotype_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $top_level_sql = 'SELECT genpedigree.*, genotype.GenotypeName, ';
  $top_level_sql   .= 'generaltype.TypeName AS GenParentTypeName ';
  $top_level_sql   .= 'FROM genpedigree LEFT JOIN genotype ON genpedigree.GenotypeId = genotype.GenotypeId ';
  $top_level_sql   .= 'LEFT JOIN generaltype ON genpedigree.GenParentType = generaltype.TypeId ';
  $top_level_sql   .= 'WHERE genpedigree.ParentGenotypeId=?';

  my ($read_descendant_err, $read_descendant_msg,
      $finish_level, $descendant_data) = recurse_read($dbh, $top_level_sql, [$genotype_id],
                                                      'GenotypeId', 0, $stopping_level);

  if ($read_descendant_err) {

    $self->logger->debug("Recurse read failed: $read_descendant_msg - finish level: $finish_level");

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Descendant' => $descendant_data,
                                           'RecordMeta' => [{'TagName' => 'Descendant'}],
  };

  return $data_for_postrun_href;
}

sub list_spec_ancestor_runmode {

=pod list_spec_ancestor_HELP_START
{
"OperationName": "List ancestors",
"Description": "List all ancestors of the specimen specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='Ancestor' /><Ancestor NumberOfSpecimens='' ParentSpecimenId='11' SelectionReason='' ParentType='7' PedigreeId='6' Level='0' ParentSpecimenName='Import_specimen1_9161882' SpecimenId='10' ParentTypeName='Male-5673950' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'Ancestor'}],'Ancestor' : [{'ParentSpecimenId' : '11','NumberOfSpecimens' : null,'ParentType' : '7','SelectionReason' : null,'PedigreeId' : '6','Level' : 0,'ParentSpecimenName' : 'Import_specimen1_9161882','ParentTypeName' : 'Male-5673950','SpecimenId' : '10'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPParameter": [{"Required": 0, "Name": "Level", "Description": "The number of recursions to retrieve the parentage records from the database"}, {"Required": 0, "Name": "OutputType", "Description": "Type of the structure of the specimen ancestor records that will be returned. The possible values are ALL and KEYANCESTOR. ALL is for returning all specimen ancestor records found by this recursive process. KEYANCESTOR is when DAL will separate the specimen pedigree records for specimens that have been used as ancestors for more than once like being parents and grand parents from pedigree records of the specimens that are used for as ancestors for only one time. ALL is the default value."}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SpecimenId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self        = shift;
  my $query       = $self->query();
  my $specimen_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $level = '';

  if (defined $query->param('Level')) {

    if (length($query->param('Level')) > 0) {

      $level = $query->param('Level');
    }
  }

  my $stopping_level = 0;

  if (length($level) > 0) {

    my ($int_err, $int_err_href) = check_integer_href( {'Level' => $level} );

    if ($int_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [$int_err_href]};

      return $data_for_postrun_href;
    }

    if ($level > $MAX_RECURSIVE_ANCESTOR_LEVEL) {

      $level = $MAX_RECURSIVE_ANCESTOR_LEVEL;
    }

    $stopping_level = $level + 0;
  }

  my $structure_type = 'ALL';

  if (defined $query->param('OutputType')) {

    if ( uc($query->param('OutputType')) eq 'KEYANCESTOR' ) {

      $structure_type = 'KEYANCESTOR';
    }
  }

  my $dbh = connect_kdb_read();

  my $specimen_exist = record_existence($dbh, 'specimen', 'SpecimenId', $specimen_id);

  if (!$specimen_exist) {

    my $err_msg = "Specimen ($specimen_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'SpecimenId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'genotype');

  my $geno_perm_sql = "SELECT DISTINCT genotypespecimen.SpecimenId ";
  $geno_perm_sql   .= "FROM genotypespecimen LEFT JOIN genotype ON genotypespecimen.GenotypeId = genotype.GenotypeId ";
  $geno_perm_sql   .= "WHERE (($perm_str) & $READ_PERM) = $READ_PERM AND genotypespecimen.SpecimenId = ?";

  my ($r_spec_id_err, $db_spec_id) = read_cell($dbh, $geno_perm_sql, [$specimen_id]);

  if ($r_spec_id_err) {

    $self->logger->debug("Read SpecimenId from database failed");
    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_spec_id) == 0) {

    my $err_msg = "Permission denied: specimen ($specimen_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $top_level_sql = 'SELECT pedigree.*, specimen.SpecimenName AS ParentSpecimenName, ';
  $top_level_sql   .= 'generaltype.TypeName AS ParentTypeName ';
  $top_level_sql   .= 'FROM pedigree LEFT JOIN specimen ON pedigree.ParentSpecimenId = specimen.SpecimenId ';
  $top_level_sql   .= 'LEFT JOIN generaltype ON pedigree.ParentType = generaltype.TypeId ';
  $top_level_sql   .= 'WHERE pedigree.SpecimenId=?';

  my $frequency_href = {};

  my ($read_ancestor_err, $read_ancestor_msg,
      $finish_level, $ancestor_data) = recurse_read($dbh, $top_level_sql, [$specimen_id],
                                                    'ParentSpecimenId', 0, $stopping_level, $frequency_href);

  if ($read_ancestor_err) {

    $self->logger->debug("Recurse read failed: $read_ancestor_msg - finish level: $finish_level");

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  if ( uc($structure_type) eq 'KEYANCESTOR' ) {

    my $uniq_ancestor_data = [];
    my $key_ancestor_data  = [];

    my $uniq_key_ancestor_href = {};

    my $nb_rec = scalar(@{$ancestor_data});

    for (my $i = 0; $i < $nb_rec; $i += 1) {

      my $ancestor_rec = $ancestor_data->[$i];

      my $child_id   = $ancestor_rec->{'SpecimenId'};
      my $parent_id  = $ancestor_rec->{'ParentSpecimenId'};
      my $type_id    = $ancestor_rec->{'ParentType'};

      if ( ! (defined $frequency_href->{$child_id}) ) {

        push(@{$uniq_ancestor_data}, $ancestor_rec);
        $self->logger->debug("Checking if this condition is true for CHILD: $child_id");
      }
      else {

        my $count = $frequency_href->{$child_id};

        $self->logger->debug("CHILD ID: $child_id - COUNT: $count");

        # if my child has been used as a parent more than once,
        # then i am very likely to be a grand parent more than once as well

        if ($count > 1) {

          if (! (defined $uniq_key_ancestor_href->{"${child_id}_${parent_id}_${type_id}"}) ) {

            delete($ancestor_rec->{'Level'});
            push(@{$key_ancestor_data}, $ancestor_rec);

            $uniq_key_ancestor_href->{"${child_id}_${parent_id}_${type_id}"} = 1;
          }
        }
        else {

          push(@{$uniq_ancestor_data}, $ancestor_rec);
        }
      }
    }

    my @sorted_uniq_ancestor_data = sort { $a->{'Level'} <=> $b->{'Level'} } @{$uniq_ancestor_data};
    my @sorted_key_ancestor_data  = sort { $a->{'SpecimenId'} <=> $b->{'SpecimenId'} } @{$key_ancestor_data};

    $data_for_postrun_href->{'Error'}     = 0;
    $data_for_postrun_href->{'Data'}      = {'Ancestor'    => \@sorted_uniq_ancestor_data,
                                             'KeyAncestor' => \@sorted_key_ancestor_data,
                                             'RecordMeta'  => [{'TagName' => 'Ancestor'}],
                                            };

    # ------------ Second Optimisation Edit number #2 -------------------------------
  }
  elsif ( uc($structure_type) eq 'ALL' ) {

    $data_for_postrun_href->{'Error'}     = 0;
    $data_for_postrun_href->{'Data'}      = {'Ancestor'   => $ancestor_data,
                                             'RecordMeta' => [{'TagName' => 'Ancestor'}],
                                            };
  }

  return $data_for_postrun_href;
}

sub list_spec_descendant_runmode {

=pod list_spec_descendant_HELP_START
{
"OperationName": "List descendants",
"Description": "List all descendants of the specimen specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='Descendant' /><Descendant SpecimenName='Import_specimen2_4056954' NumberOfSpecimens='' ParentSpecimenId='11' SelectionReason='' ParentType='7' PedigreeId='6' Level='0' SpecimenId='10' ParentTypeName='Male-5673950' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'Descendant'}],'Descendant' : [{'ParentSpecimenId' : '11','NumberOfSpecimens' : null,'SpecimenName' : 'Import_specimen2_4056954','ParentType' : '7','SelectionReason' : null,'PedigreeId' : '6','Level' : 0,'ParentTypeName' : 'Male-5673950','SpecimenId' : '10'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPParameter": [{"Required": 0, "Name": "Level", "Description": "The number of recursions to retrieve the parentage records from the database"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SpecimenId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self        = shift;
  my $query       = $self->query();
  my $specimen_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $level = '';

  if (defined $query->param('Level')) {

    if (length($query->param('Level')) > 0) {

      $level = $query->param('Level');
    }
  }

  my $stopping_level = 0;

  if (length($level) > 0) {

    my ($int_err, $int_err_href) = check_integer_href( {'Level' => $level} );

    if ($int_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [$int_err_href]};

      return $data_for_postrun_href;
    }

    if ($level > $MAX_RECURSIVE_DESCENDANT_LEVEL) {

      $level = $MAX_RECURSIVE_DESCENDANT_LEVEL;
    }

    $stopping_level = $level + 0;
  }

  my $dbh = connect_kdb_read();

  my $specimen_exist = record_existence($dbh, 'specimen', 'SpecimenId', $specimen_id);

  if (!$specimen_exist) {

    my $err_msg = "Specimen ($specimen_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'SpecimenId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'genotype');

  my $geno_perm_sql = "SELECT DISTINCT genotypespecimen.SpecimenId ";
  $geno_perm_sql   .= "FROM genotypespecimen LEFT JOIN genotype ON genotypespecimen.GenotypeId = genotype.GenotypeId ";
  $geno_perm_sql   .= "WHERE (($perm_str) & $READ_PERM) = $READ_PERM AND genotypespecimen.SpecimenId = ?";

  my ($r_spec_id_err, $db_spec_id) = read_cell($dbh, $geno_perm_sql, [$specimen_id]);

  if ($r_spec_id_err) {

    $self->logger->debug("Read SpecimenId from database failed");
    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_spec_id) == 0) {

    my $err_msg = "Permission denied: specimen ($specimen_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $top_level_sql = 'SELECT pedigree.*, specimen.SpecimenName, ';
  $top_level_sql   .= 'generaltype.TypeName AS ParentTypeName ';
  $top_level_sql   .= 'FROM pedigree LEFT JOIN specimen ON pedigree.SpecimenId = specimen.SpecimenId ';
  $top_level_sql   .= 'LEFT JOIN generaltype ON pedigree.ParentType = generaltype.TypeId ';
  $top_level_sql   .= 'WHERE pedigree.ParentSpecimenId=?';

  my ($read_descendant_err, $read_descendant_msg,
      $finish_level, $descendant_data) = recurse_read($dbh, $top_level_sql, [$specimen_id],
                                                      'SpecimenId', 0, $stopping_level);

  if ($read_descendant_err) {

    $self->logger->debug("Recurse read failed: $read_descendant_msg - finish level: $finish_level");

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh->disconnect();

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Descendant' => $descendant_data,
                                           'RecordMeta' => [{'TagName' => 'Descendant'}],
  };

  return $data_for_postrun_href;
}

sub list_pedigree_advanced_runmode {

=pod list_pedigree_advanced_HELP_START
{
"OperationName": "List pedigree",
"Description": "Returns list of pedigree records. This listing requires pagination definition.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination Page='1' NumOfRecords='3' NumOfPages='3' NumPerPage='1' /><Pedigree NumberOfSpecimens='' ParentSpecimenId='11' SelectionReason='' ParentType='7' PedigreeId='6' delete='delete/pedigree/6' update='update/pedigree/6' SpecimenId='10' ParentTypeName='Male-5673950' /><RecordMeta TagName='Pedigree' /></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfRecords' : '3','NumOfPages' : 3,'NumPerPage' : '1','Page' : '1'}],'Pedigree' : [{'ParentSpecimenId' : '11','NumberOfSpecimens' : null,'ParentType' : '7','SelectionReason' : null,'PedigreeId' : '6','delete' : 'delete/pedigree/6','update' : 'update/pedigree/6','ParentTypeName' : 'Male-5673950','SpecimenId' : '10'}],'RecordMeta' : [{'TagName' : 'Pedigree'}]}",
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

  my $data_for_postrun_href = {};

  my $sql = 'SELECT * FROM pedigree LIMIT 1';

  my ($samp_pedigree_err, $samp_pedigree_msg, $samp_pedigree_data) = $self->list_pedigree(0, $sql);

  if ($samp_pedigree_err) {

    $self->logger->debug($samp_pedigree_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $dbh = connect_kdb_read();

  my $sample_data_aref = $samp_pedigree_data;

  my @field_list_all;

  if (scalar(@{$sample_data_aref}) == 1) {

    @field_list_all = keys(%{$sample_data_aref->[0]});
  }
  else {

    $self->logger->debug("It reaches here");
    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'pedigree');

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
                                                                                   'PedigreeId' );
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

    if ($field eq 'ParentType') {

      push(@{$final_field_list}, 'generaltype.TypeName AS ParentTypeName');
      $join = ' LEFT JOIN generaltype ON pedigree.ParentType = generaltype.TypeId ';
    }
  }

  $self->logger->debug("Final field list: " . join(',', @{$final_field_list}));

  $sql  = 'SELECT ' . join(',', @{$final_field_list}) . ' ';
  $sql .= "FROM pedigree $join ";

  my ( $filter_err, $filter_msg, $filter_phrase, $where_arg ) = parse_filtering('PedigreeId', 'pedigree',
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
                                                                        'pedigree',
                                                                        'PedigreeId',
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

    $sql .= " ORDER BY pedigree.PedigreeId DESC ";
  }

  $sql .= " $paged_limit_clause ";

  $self->logger->debug("Final list itemgroup SQL: $sql");

  my ($pedigree_err, $pedigree_msg, $pedigree_data) = $self->list_pedigree(1, $sql, $where_arg);

  if ($pedigree_err) {

    $self->logger->debug("Get pedigree failed: $pedigree_msg");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Pedigree'      => $pedigree_data,
                                           'Pagination'    => $pagination_aref,
                                           'RecordMeta'    => [{'TagName' => 'Pedigree'}],
  };

  return $data_for_postrun_href;
}

sub list_gen_pedigree_advanced_runmode {

=pod list_gen_pedigree_advanced_HELP_START
{
"OperationName": "List genotype pedigree",
"Description": "Return list of genotype pedigree records. This listing requires pagination definition.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Pagination NumOfRecords='5' NumOfPages='5' Page='1' NumPerPage='1' /><GenPedigree NumberOfGenotypes='' ParentGenotypeId='2' GenParentType='59' GenPedigreeId='5' delete='delete/genpedigree/5' GenotypeId='1' update='update/genpedigree/5' GenParentTypeName='GenParentType - 8659523' /><RecordMeta TagName='GenPedigree' /></DATA>",
"SuccessMessageJSON": "{'Pagination' : [{'NumOfRecords' : '5','NumOfPages' : 5,'NumPerPage' : '1','Page' : '1'}],'GenPedigree' : [{'ParentGenotypeId' : '2','NumberOfGenotypes' : null,'GenPedigreeId' : '5','GenParentType' : '59','delete' : 'delete/genpedigree/5','GenotypeId' : '1','update' : 'update/genpedigree/5','GenParentTypeName' : 'GenParentType - 8659523'}],'RecordMeta' : [{'TagName' : 'GenPedigree'}]}",
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

  $self->logger->debug("Filtering CSV: $filtering_csv");

  my $data_for_postrun_href = {};

  my $sql = 'SELECT * FROM genpedigree LIMIT 1';

  my ($samp_gen_pedigree_err, $samp_gen_pedigree_msg, $samp_gen_pedigree_data) = $self->list_gen_pedigree(0, $sql);

  if ($samp_gen_pedigree_err) {

    $self->logger->debug($samp_gen_pedigree_msg);

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $dbh = connect_kdb_read();

  my $sample_data_aref = $samp_gen_pedigree_data;

  my @field_list_all;

  if (scalar(@{$sample_data_aref}) == 1) {

    @field_list_all = keys(%{$sample_data_aref->[0]});
  }
  else {

    $self->logger->debug("It reaches here");
    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'genpedigree');

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
  my @filtering_field_list = ('GenotypeId','ParentGenotypeId', 'GenotypeName','ParentGenotypeName', 'GenParentTypeId','GenParentTypeName','GenPedigreeId', 'GenParentType');

  $self->logger->debug("Final field list: " . join(',', @{$final_field_list}));

  if ( length($field_list_csv) > 0 ) {

    my ( $sel_field_err, $sel_field_msg, $sel_field_list ) = parse_selected_field( $field_list_csv,
                                                                                   $final_field_list,
                                                                                   'GenPedigreeId' );
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

    if ($field eq 'GenParentType') {
      push(@{$final_field_list}, 'generaltype.TypeName AS GenParentTypeName');
      $join = ' LEFT JOIN generaltype ON genpedigree.GenParentType = generaltype.TypeId ';
    }

    if ($field eq 'GenotypeId') {
      push(@{$final_field_list}, 'g1.GenotypeId AS GenotypeId');
      $field = 'g1.GenotypeId';
    }

    if ($field eq 'ParentGenotypeId') {
      push(@{$final_field_list}, 'genpedigree.ParentGenotypeId AS ParentGenotypeId');
      $field = 'genpedigree.ParentGenotypeId';
    }


  }

  #get parent names
  push(@{$final_field_list}, 'g1.GenotypeName AS GenotypeName');
  push(@{$final_field_list}, 'g2.GenotypeName AS ParentGenotypeName');

  $join = ' LEFT JOIN generaltype ON genpedigree.GenParentType = generaltype.TypeId ';
  $join .= ' LEFT JOIN genotype g1 ON g1.GenotypeId = genpedigree.GenotypeId ';
  $join .= ' LEFT JOIN genotype g2 ON g2.GenotypeId = genpedigree.ParentGenotypeId ';

  $self->logger->debug("Final field list: " . join(',', @{$final_field_list}));

  $sql  = 'SELECT ' . join(',', @{$final_field_list}) . ' ';
  $sql .= "FROM genpedigree $join ";

  my ( $filter_err, $filter_msg, $filter_phrase, $where_arg, $debug_array ) = parse_filtering('GenPedigreeId', 'genpedigree',
                                                                                $filtering_csv, \@filtering_field_list );
  if ($filter_err) {

    $self->logger->debug("Parse filtering failed: $filter_msg");
    my $err_msg = $filter_msg;

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg }]};

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
                                                                        'genpedigree',
                                                                        'GenPedigreeId',
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

    $sql .= " ORDER BY genpedigree.GenPedigreeId DESC ";
  }

  $sql .= " $paged_limit_clause ";

  $self->logger->debug("Final list SQL: $sql");

  my ($gen_pedigree_err, $gen_pedigree_msg, $gen_pedigree_data) = $self->list_gen_pedigree(1, $sql, $where_arg);

  if ($gen_pedigree_err) {

    $self->logger->debug("Get gen_pedigree failed: $gen_pedigree_msg");

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'GenPedigree'   => $gen_pedigree_data,
                                           'Pagination'    => $pagination_aref,
                                           'RecordMeta'    => [{'TagName' => 'GenPedigree'}],
  };

  return $data_for_postrun_href;
}

sub add_keyword_to_specimen_runmode {

=pod add_keyword_to_specimen_HELP_START
{
"OperationName": "Attach keyword to specimen",
"Description": "Add keyword to the specimen specified by.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "specimenkeyword",
"SkippedField": ["SpecimenId"],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='2' ParaName='SpecimenKeywordId' /><Info Message='Keyword (29) now part of specimen (206).' /></DATA>",
"SuccessMessageJSON": "{'ReturnId' : [{'Value' : '3', 'ParaName' : 'SpecimenKeywordId'}], 'Info' : [{'Message' : 'Keyword (30) now part of specimen (206).'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Keyword (666876) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{ 'Error':[{'Message': 'Keyword (6668) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SpecimenId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self         = shift;
  my $specimen_id  = $self->param('id');
  my $query        = $self->query();

  my $data_for_postrun_href = {};

  my $dbh_read = connect_kdb_read();

  my $specimen_exist = record_existence($dbh_read, 'specimen', 'SpecimenId', $specimen_id);

  if (!$specimen_exist) {

    my $err_msg = "Specimen ($specimen_id) not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'genotype');

  my $geno_perm_sql = "SELECT DISTINCT genotypespecimen.SpecimenId ";
  $geno_perm_sql   .= "FROM genotypespecimen LEFT JOIN genotype ON genotypespecimen.GenotypeId = genotype.GenotypeId ";
  $geno_perm_sql   .= "WHERE (($perm_str) & $READ_WRITE_PERM) = $READ_WRITE_PERM AND genotypespecimen.SpecimenId = ?";

  my ($r_spec_id_err, $db_spec_id) = read_cell($dbh_read, $geno_perm_sql, [$specimen_id]);

  if ($r_spec_id_err) {

    $self->logger->debug("Read SpecimenId from database failed");
    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_spec_id) == 0) {

    my $err_msg = "Permission denied: specimen ($specimen_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $keyword_id = $query->param('KeywordId');

  my ($missing_err, $missing_href) = check_missing_href( {'KeywordId' => $keyword_id} );

  if ($missing_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$missing_href]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT SpecimenKeywordId ';
  $sql   .= 'FROM specimenkeyword ';
  $sql   .= 'WHERE KeywordId=? AND SpecimenId=?';

  my $sth = $dbh_read->prepare($sql);
  $sth->execute($keyword_id, $specimen_id);
  my $db_spec_kwd_id = -1;
  $sth->bind_col(1, \$db_spec_kwd_id);
  $sth->fetch();
  $sth->finish();

  if ($db_spec_kwd_id != -1) {

    my $err_msg = "Keyword ($keyword_id): already part of specimen ($specimen_id).";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_read->disconnect();

  my $dbh_write = connect_kdb_write();

  $sql  = 'INSERT INTO specimenkeyword SET ';
  $sql .= 'KeywordId=?, ';
  $sql .= 'SpecimenId=?';

  $sth = $dbh_write->prepare($sql);
  $sth->execute($keyword_id, $specimen_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $spec_kwd_id = $dbh_write->last_insert_id(undef, undef, 'specimenkeyword', 'SpecimenKeywordId');

  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "Keyword ($keyword_id) now part of specimen ($specimen_id)."}];
  my $return_id_aref = [{'Value' => "$spec_kwd_id", 'ParaName' => 'SpecimenKeywordId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'     => $info_msg_aref,
                                           'ReturnId' => $return_id_aref
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_specimen_keyword {

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

  $dbh->disconnect();

  my $extra_attr_tunit_keyword_data = [];

  if ($extra_attr_yes) {

    my $perm_lookup  = {'0' => 'None',
                        '1' => 'Link',
                        '2' => 'Write',
                        '3' => 'Write/Link',
                        '4' => 'Read',
                        '5' => 'Read/Link',
                        '6' => 'Read/Write',
                        '7' => 'Read/Write/Link',
    };

    for my $row (@{$data_aref}) {

      my $specimen_keyword_id      = $row->{'SpecimenKeywordId'};
      my $permission               = $row->{'UltimatePerm'};
      $row->{'UltimatePermission'} = $perm_lookup->{$permission};

      if ( ($permission & $READ_WRITE_PERM) == $READ_WRITE_PERM ) {

        $row->{'remove'} = "remove/specimenkeyword/$specimen_keyword_id";
      }

      push(@{$extra_attr_tunit_keyword_data}, $row);
    }
  }
  else {

    $extra_attr_tunit_keyword_data = $data_aref;
  }

  return ($err, $msg, $extra_attr_tunit_keyword_data);
}

sub list_specimen_keyword_advanced_runmode {

=pod list_specimen_keyword_advanced_HELP_START
{
"OperationName": "List keywords for specimen",
"Description": "List keywords associated for specimen specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='SpecimenKeyword' /><SpecimenKeyword SpecimenKeywordId='1' KeywordId='28' remove='remove/specimenkeyword/1' UltimatePermission='Read/Write/Link' KeywordName='Keyword_4972780' UltimatePerm='7' SpecimenId='206' /><SpecimenKeyword SpecimenKeywordId='2' KeywordId='29' remove='remove/specimenkeyword/2' UltimatePermission='Read/Write/Link' KeywordName='Keyword_6850702' UltimatePerm='7' SpecimenId='206' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'SpecimenKeyword'}], 'SpecimenKeyword' : [{'SpecimenKeywordId' : '1', 'remove' : 'remove/specimenkeyword/1', 'KeywordId' : '28', 'UltimatePermission' : 'Read/Write/Link', 'KeywordName' : 'Keyword_4972780', 'SpecimenId' : '206', 'UltimatePerm' : '7'},{'SpecimenKeywordId' : '2', 'remove' : 'remove/specimenkeyword/2', 'KeywordId' : '29', 'UltimatePermission' : 'Read/Write/Link', 'KeywordName' : 'Keyword_6850702', 'SpecimenId' : '206', 'UltimatePerm' : '7'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Specimen (500) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Specimen (500) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SpecimenId"},{"ParameterName": "nperpage", "Description": "Number of records in a page for pagination"}, {"ParameterName": "num", "Description": "The page number of the pagination"}],
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

  my $specimen_id          = -1;
  my $specimen_id_provided = 0;

  if (defined $self->param('id')) {

    $specimen_id          = $self->param('id');
    $specimen_id_provided = 1;

    if ($filtering_csv =~ /SpecimenId\s*=\s*(.*),?/) {

      if ( "$specimen_id" ne "$1" ) {

        my $err_msg = 'Duplicate filtering condition for SpecimenId.';
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
    else {

      if (length($filtering_csv) > 0) {

        if ($filtering_csv =~ /&$/) {

          $filtering_csv .= "SpecimenId=$specimen_id";
        }
        else {

          $filtering_csv .= "&SpecimenId=$specimen_id";
        }
      }
      else {

        $filtering_csv .= "SpecimenId=$specimen_id";
      }
    }
  }

  $self->logger->debug("Filtering csv: $filtering_csv");

  my $sorting = '';

  if (defined $query->param('Sorting')) {

    $sorting = $query->param('Sorting');
  }

  my $group_id      = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str      = permission_phrase($group_id, 0, $gadmin_status, 'specimen');

  my $sql = 'SELECT * FROM specimenkeyword LIMIT 1';

  my ($sample_tup_err, $sample_tup_msg, $sample_spec_key_data) = $self->list_specimen_keyword(0, $sql);

  if ($sample_tup_err) {

    $self->logger->debug($sample_tup_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $dbh = connect_kdb_read();

  my $sample_data_aref = $sample_spec_key_data;

  my @field_list_all;

  if (scalar(@{$sample_data_aref}) == 1) {

    @field_list_all = keys(%{$sample_data_aref->[0]});
  }
  else {

    $self->logger->debug("It reaches here");
    my ($sfield_err, $sfield_msg, $sfield_data, $pkey_data) = get_static_field($dbh, 'specimenkeyword');

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
                                                                                'SpecimenKeywordId',
                                                                               );

    if ($sel_field_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;

    if ($filtering_csv =~ /SpecimenId/) {

      push(@{$final_field_list}, 'SpecimenId');
    }
  }

  my $field_lookup = {};
  for my $fd_name (@{$final_field_list}) {

    $field_lookup->{$fd_name} = 1;
  }

  my $other_join = '';

  if ($field_lookup->{'KeywordId'}) {

    push(@{$final_field_list}, 'keyword.KeywordName');
    $other_join .= ' LEFT JOIN keyword ON specimenkeyword.KeywordId = keyword.KeywordId ';
  }

  $self->logger->debug("Final field list: " . join(', ', @{$final_field_list}));

  my $sql_field_list = [];
  for my $field_name (@{$final_field_list}) {

    my $full_field_name = $field_name;
    if (!($full_field_name =~ /\./)) {

      $full_field_name = 'specimenkeyword.' . $full_field_name;
    }

    push(@{$sql_field_list}, $full_field_name);
  }

  push(@{$sql_field_list}, "$perm_str AS UltimatePerm ");

  my $field_list_str = join(', ', @{$sql_field_list});

  $sql  = "SELECT $field_list_str ";
  $sql .= 'FROM specimenkeyword ';
  $sql .= 'LEFT JOIN specimen ON specimenkeyword.SpecimenId = specimen.SpecimenId ';
  $sql .= "$other_join ";

  my $validation_func_lookup = {};

  $self->logger->debug("Final field list: " . join(', ', @{$final_field_list}));

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering('SpecimenKeywordId',
                                                                              'specimenkeyword',
                                                                              $filtering_csv,
                                                                              $final_field_list,
                                                                              $validation_func_lookup,
                                                                             );

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

    my $page_where_phrase = '';
    $page_where_phrase   .= ' LEFT JOIN specimen ON specimenkeyword.SpecimenId = specimen.SpecimenId ';
    $page_where_phrase   .= " $filtering_exp ";

    my ($paged_id_err, $paged_id_msg, $nb_records,
        $nb_pages, $limit_clause, $rcount_time) = get_paged_filter($dbh,
                                                                   $nb_per_page,
                                                                   $page,
                                                                   'specimenkeyword',
                                                                   'SpecimenKeywordId',
                                                                   $page_where_phrase,
                                                                   $where_arg
                                                                  );

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

  $dbh->disconnect();

  $sql .= " $filtering_exp ";

  my ($sort_err, $sort_msg, $sort_sql) = parse_sorting($sorting, $final_field_list, 'specimenkeyword');

  if ($sort_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sort_msg}]};

    return $data_for_postrun_href;
  }

  if (length($sort_sql) > 0) {

    $sql .= " ORDER BY $sort_sql ";
  }
  else {

    $sql .= ' ORDER BY specimenkeyword.SpecimenkeywordId DESC';
  }

  $sql .= " $paged_limit_clause ";

  $self->logger->debug("Where arg: " . join(',', @{$where_arg}));

  $self->logger->debug("SQL: $sql");

  my ($read_spec_kwd_err, $read_spec_kwd_msg, $spec_kwd_data) = $self->list_specimen_keyword(1,
                                                                                             $sql,
                                                                                             $where_arg);

  if ($read_spec_kwd_err) {

    $self->logger->debug($read_spec_kwd_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'} = 0;
  $data_for_postrun_href->{'Data'}  = {'SpecimenKeyword'    => $spec_kwd_data,
                                       'Pagination'         => $pagination_aref,
                                       'RecordMeta'         => [{'TagName' => 'SpecimenKeyword'}],
  };

  return $data_for_postrun_href;
}

sub remove_specimen_keyword_runmode {

=pod remove_specimen_keyword_HELP_START
{
"OperationName": "Remove specimen keyword",
"Description": "Delete association between specimen and keyword specified by specimenkeyword id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='SpecimenKeyword (6) has been removed successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'SpecimenKeyword (5) has been removed successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='SpecimenKeyword (103) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'SpecimenKeyword (103) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SpecimenKeywordId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self                = shift;
  my $specimen_keyword_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_read = connect_kdb_read();
  my $specimen_id = read_cell_value($dbh_read, 'specimenkeyword', 'SpecimenId',
                                    'SpecimenKeywordId', $specimen_keyword_id);

  if (length($specimen_id) == 0) {

    my $err_msg = "SpecimenKeyword ($specimen_keyword_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();
  my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'genotype');

  my $sql      = "SELECT $perm_str AS UltimatePerm ";
  $sql        .= "FROM genotypespecimen LEFT JOIN genotype ON ";
  $sql        .= "genotypespecimen.GenotypeId = genotype.GenotypeId ";
  $sql        .= "WHERE genotypespecimen.SpecimenId=?";

  my ($r_geno_perm_err, $r_geno_perm_msg, $geno_perm_aref) = read_data($dbh_read, $sql, [$specimen_id]);

  if ($r_geno_perm_err) {

    $self->logger->debug("Read genotype permission failed: $r_geno_perm_msg");
    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $final_perm = 0;

  foreach my $geno_rec (@{$geno_perm_aref}) {

    my $geno_perm = $geno_rec->{'UltimatePerm'};

    if ($geno_perm > $final_perm) {

      $final_perm = $geno_perm;
    }
  }

  if ( ($final_perm & $READ_WRITE_PERM) != $READ_WRITE_PERM ) {

    my $err_msg = "Specimen ($specimen_id): permission denied.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $dbh_read->disconnect();

  my $dbh_write = connect_kdb_write();

  $sql = 'DELETE FROM specimenkeyword WHERE SpecimenKeywordId=?';

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($specimen_keyword_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref = [{'Message' => "SpecimenKeyword ($specimen_keyword_id) has been removed successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'       => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub import_genpedigree_csv_runmode {

=pod import_genpedigree_csv_HELP_START
{
"OperationName": "Import genpedigree",
"Description": "Import genotype pedigree information in bulk using csv file.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='1 genpedigree records have been inserted successfully. Time taken in seconds: 0.123427.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : '1 genpedigree records have been inserted successfully. Time taken in seconds: 0.122738.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Row (1): Genotype (91056) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Row (1): Genotype (91054) not found.'}]}"}],
"RequiredUpload": 1,
"UploadFileFormat": "CSV",
"UploadFileParameterName": "uploadfile",
"HTTPParameter": [{"Required": 1, "Name": "GenotypeId", "Description": "The column number for GenotypeId column in the upload CSV file"}, {"Required": 1, "Name": "ParentGenotypeId", "Description": "The column number for ParentGenotypeId column in the upload CSV file"}, {"Required": 1, "Name": "GenParentType", "Description": "The column number for GenParentType column in the upload CSV file"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $start_time = [gettimeofday()];
  my $data_for_postrun_href = {};

  my $data_csv_file = $self->authen->get_upload_file();

  my $num_of_col = get_csvfile_num_of_col($data_csv_file);

  $self->logger->debug("Number of columns: $num_of_col");

  my $GenotypeId_col            = $query->param('GenotypeId');
  my $ParentGenotypeId_col      = $query->param('ParentGenotypeId');
  my $GenParentType_col         = $query->param('GenParentType');

  my $chk_col_def_data = { 'GenotypeId'        => $GenotypeId_col,
                           'ParentGenotypeId'  => $ParentGenotypeId_col,
                           'GenParentType'     => $GenParentType_col,
  };

  my $matched_col = {};

  $matched_col->{$GenotypeId_col}          = 'GenotypeId';
  $matched_col->{$ParentGenotypeId_col}    = 'ParentGenotypeId';
  $matched_col->{$GenParentType_col}       = 'GenParentType';


  if (defined $query->param('NumberOfGenotypes')) {

    my $NumberOfGenotypes_col                = $query->param('NumberOfGenotypes');
    $chk_col_def_data->{'NumberOfGenotypes'} = $NumberOfGenotypes_col;
    $matched_col->{$NumberOfGenotypes_col}   = 'NumberOfGenotypes';
  }

  my ($col_def_err, $col_def_msg) = check_col_definition( $chk_col_def_data, $num_of_col );

  if ($col_def_err) {

    return $self->_set_error($col_def_msg);
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

    return $self->_set_error($err_msg);
  }

  my $group_id = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my $num_of_bulk_insert = $NB_RECORD_BULK_INSERT;

  my $dbh_write = connect_kdb_write();

  my $row_counter = 1;
  my $i = 0;
  my $num_of_rows = scalar(@{$data_aref});

  $self->logger->debug("Number of rows: $num_of_rows");

  my $unique_parent_href      = {};
  my $unique_parent_type_href = {};

  my $inner_loop_max_j = 0;

  while( $i < $num_of_rows ) {

    my $j = $i;
    $inner_loop_max_j = $j + $num_of_bulk_insert;
    my $smallest_num = $num_of_rows > $inner_loop_max_j ? $inner_loop_max_j : $num_of_rows;

    my $unique_genotype_href    = {};
    my $parent_where            = '';

    #$self->logger->debug("Checking: $i, $smallest_num");

    while( $j < $smallest_num ) {

      my $data_row = $data_aref->[$j];

      my $missing_para_chk_href = { 'GenotypeId'       => $data_row->{'GenotypeId'},
                                    'ParentGenotypeId' => $data_row->{'ParentGenotypeId'},
                                    'GenParentType'    => $data_row->{'GenParentType'},
      };

      my ($missing_err, $missing_msg) = check_missing_value( $missing_para_chk_href );

      if ($missing_err) {

        $missing_msg = "Row ($row_counter): $missing_msg missing.";
        return $self->_set_error($missing_msg);
      }

      my $int_chk_href = { 'GenotypeId'       => $data_row->{'GenotypeId'},
                           'ParentGenotypeId' => $data_row->{'ParentGenotypeId'},
                           'GenParentType'    => $data_row->{'GenParentType'},
      };

      if (defined $data_row->{'NumberOfGenotypes'}) {

        $int_chk_href->{'NumberOfGenotypes'} = $data_row->{'NumberOfGenotypes'};
      }

      my ($int_id_err, $int_id_msg) = check_integer_value( $int_chk_href );

      if ($int_id_err) {

        $int_id_msg = "Row ($row_counter): " . $int_id_msg . ' not integer.';
        return $self->_set_error($int_id_msg);
      }

      my $genotype_id        = $data_row->{'GenotypeId'};
      my $parent_genotype_id = $data_row->{'ParentGenotypeId'};
      my $parent_type        = $data_row->{'GenParentType'};

      my $parent_key = "${genotype_id}_${parent_genotype_id}_${parent_type}";
      $parent_key = $dbh_write->quote($parent_key);

      if ($unique_parent_href->{$parent_key}) {

        my $err_msg = "Row ($row_counter): duplicate parent ";
        $err_msg   .= "($genotype_id, $parent_genotype_id, $parent_type) in CSV file.";
        return $self->_set_error($err_msg);
      }
      else {

        $unique_parent_href->{$parent_key} = 1;
      }

      $unique_genotype_href->{$genotype_id}        = $row_counter;
      $unique_genotype_href->{$parent_genotype_id} = $row_counter;

      $unique_parent_type_href->{$parent_type}     = $row_counter;

      $parent_where .= "$parent_key,";

      $j += 1;
      $row_counter += 1;
    }

    my @genotype_list = keys(%{$unique_genotype_href});

    if (scalar(@genotype_list)) {

      my $genotype_where = join(',', @genotype_list);
      my $chk_spec_sql = "SELECT GenotypeId FROM genotype ";
      $chk_spec_sql   .= "WHERE GenotypeId IN ($genotype_where)";

      my $found_spec_data = $dbh_write->selectall_hashref($chk_spec_sql, 'GenotypeId');

      if (scalar(keys(%{$found_spec_data})) < scalar(@genotype_list)) {

        my @unknown_spec;
        my @unknown_spec_rownum;

        for my $spec_id_in_csv (@genotype_list) {

          if ( !(defined $found_spec_data->{$spec_id_in_csv}) ) {

            push(@unknown_spec, $spec_id_in_csv);
            push(@unknown_spec_rownum, $unique_genotype_href->{$spec_id_in_csv});
          }
        }

        my $err_msg = 'Row (' . join(',', @unknown_spec_rownum) . '): Genotype (';
        $err_msg   .= join(',', @unknown_spec) . ') not found.';

        return $self->_set_error($err_msg);
      }

      my $perm_str = permission_phrase($group_id, 0, $gadmin_status, 'genotype');

      my $chk_geno_perm_sql = "SELECT GenotypeId FROM genotype ";
      $chk_geno_perm_sql   .= "WHERE GenotypeId IN ($genotype_where) AND ";
      $chk_geno_perm_sql   .= "(( ($perm_str) & $READ_WRITE_PERM ) = $READ_WRITE_PERM)";

      my $genotype_id_db_data = $dbh_write->selectall_hashref($chk_geno_perm_sql, 'GenotypeId');

      my @trouble_genotype_id_list;
      my $is_perm_ok = 1;

      for my $spec_id (@genotype_list) {

        if (!($genotype_id_db_data->{$spec_id})) {

          $is_perm_ok = 0;
          push(@trouble_genotype_id_list, $spec_id);
        }
      }

      if (!$is_perm_ok) {

        my $trouble_spec_id_str = join(',', @trouble_genotype_id_list);
        my $start_row = $i + 1;
        my $end_row   = $smallest_num;
        my $err_msg = "Row ($start_row, $end_row): Genotype ($trouble_spec_id_str) permission denied.";
        return $self->_set_error($err_msg);
      }
    }

    $self->logger->debug("Parent where: $parent_where");

    if (length($parent_where) > 0) {

      chop($parent_where); # remove the last comma
      my $check_parent_sql = "SELECT CONCAT(GenotypeId, '_', CONCAT(ParentGenotypeId, '_', GenParentType)) AS ID ";
      $check_parent_sql   .= "FROM genpedigree ";
      $check_parent_sql   .= "WHERE CONCAT(GenotypeId, '_', CONCAT(ParentGenotypeId, '_', GenParentType)) ";
      $check_parent_sql   .= "IN ($parent_where)";

      #$self->logger->debug("Check Parent SQL: $check_parent_sql");

      my ($chk_parent_read_err, $chk_parent_read_msg, $parent_data) = read_data($dbh_write, $check_parent_sql);

      if ( scalar(@{$parent_data}) ) {

        my $duplicate_parent_str = '';
        for my $parent_row (@{$parent_data}) {

          my $duplicate_parent = $parent_row->{'ID'};
          $duplicate_parent =~ /^(\d+)_(\d+)_(\d+)$/;
          my $spec_id   = $1;
          my $p_spec_id = $2;
          my $p_type    = $3;

          $duplicate_parent_str .= "($spec_id,$p_spec_id,$p_type),";
        }

        my $start_row = $i + 1;
        my $end_row   = $smallest_num;
        my $err_msg = "Row ($start_row, $end_row): ($duplicate_parent_str) (GenotypeId,ParentGenotypeId,GenParentType) ";
        $err_msg   .= "parent type already exist.";
        return $self->_set_error($err_msg);
      }
    }

    $i += $num_of_bulk_insert;

    #$self->logger->debug("Smallest num: $smallest_num");
    #$self->logger->debug("I: $i");
  }

  if (scalar(keys(%{$unique_parent_type_href}))) {

    my $chk_ptype_sql = 'SELECT TypeId FROM generaltype ';
    $chk_ptype_sql   .= 'WHERE TypeId IN (' . join(',', keys(%{$unique_parent_type_href})) . ') AND ';
    $chk_ptype_sql   .= "Class='genparent' AND IsTypeActive=1";

    my $parent_type_data      = $dbh_write->selectall_hashref($chk_ptype_sql, 'TypeId');

    if ( scalar(keys(%{$parent_type_data})) < scalar(keys(%{$unique_parent_type_href})) ) {

      my @unknown_parent_type;
      my @unknown_parent_type_rownum;
      for my $parent_type_in_csv (keys(%{$unique_parent_type_href})) {

        if ( !(defined $parent_type_data->{$parent_type_in_csv}) ) {

          push(@unknown_parent_type, $parent_type_in_csv);
          push(@unknown_parent_type_rownum, $unique_parent_type_href->{$parent_type_in_csv});
        }
      }

      my $err_msg = 'Row (' . join(',', @unknown_parent_type_rownum) . '): GenParentType (';
      $err_msg   .= join(',', @unknown_parent_type) . ') not found or inactive.';

      return $self->_set_error($err_msg);
    }
  }

  my $total_affected_records = 0;
  $i = 0;

  while( $i < $num_of_rows ) {

    my $j = $i;
    my $inner_loop_max_j = $j + $num_of_bulk_insert;
    my $smallest_num = $num_of_rows > $inner_loop_max_j ? $inner_loop_max_j : $num_of_rows;

    #$self->logger->debug("Composing: $i, $smallest_num");

    my $bulk_sql = 'INSERT INTO genpedigree ';
    $bulk_sql   .= '(GenotypeId,ParentGenotypeId,GenParentType,NumberOfGenotypes) ';
    $bulk_sql   .= 'VALUES ';

    while( $j < $smallest_num ) {

      my $data_row = $data_aref->[$j];

      my $genotype_id        = $data_row->{'GenotypeId'};
      my $parent_genotype_id = $data_row->{'ParentGenotypeId'};
      my $parent_type        = $data_row->{'GenParentType'};

      my $number_of_genotypes = 'NULL';

      if (defined $data_row->{'NumberOfGenotypes'}) {

        $number_of_genotypes = $data_row->{'NumberOfGenotypes'};
      }

      $bulk_sql .= "($genotype_id,$parent_genotype_id,$parent_type,$number_of_genotypes),";

      $j += 1;
    }

    #$self->logger->debug("Bulk SQL: $bulk_sql");

    chop($bulk_sql);            # remove excessive trailling comma

    my $nrows_inserted = $dbh_write->do($bulk_sql);

    if ($dbh_write->err()) {

      $self->logger->debug('Error code: ' . $dbh_write->err());
      $self->logger->debug('Error: ' . $dbh_write->errstr());

      return $self->_set_error('Unexpected error.');
    }

    $total_affected_records += $nrows_inserted;

    $i += $num_of_bulk_insert;
  }

  $dbh_write->disconnect();

  my $elapsed_time = tv_interval($start_time);

  my $info_msg = "$total_affected_records genpedigree records have been inserted successfully. ";
  $info_msg   .= "Time taken in seconds: $elapsed_time.";
  my $info_msg_aref = [{'Message' => $info_msg}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub export_genpedigree_runmode {

=pod export_genpedigree_HELP_START
{
"OperationName": "Export genpedigree",
"Description": "Export genotype pedigree into csv file.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "FILTERING"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Time taken in seconds: 0.002039.' /><OutputFile csv='http://kddart-d.diversityarrays.com/data/admin/export_genpedigree_7bb14c3bbfba954c817bd3fd2fff29ac.csv' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Time taken in seconds: 0.002103.'}], 'OutputFile' : [{'csv' : 'http://kddart-d.diversityarrays.com/data/admin/export_genpedigree_7bb14c3bbfba954c817bd3fd2fff29ac.csv'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPParameter": [{"Required": 0, "Name": "Filtering", "Description": "Filtering parameter string consisting of filtering expressions which are separated by ampersand (&) which needs to be encoded if HTTP GET method is used. Each filtering expression is composed of a database field name, a filtering operator and the filtering value."}, {"Required": 0, "Name": "FieldList", "Description": "Comma separated value of wanted fields."}, {"Required": 0, "Name": "Sorting", "Description": "Comma separated value of SQL sorting phrases."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $start_time = [gettimeofday()];
  my $data_for_postrun_href = {};

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

  my $username             = $self->authen->username();
  my $doc_root             = $ENV{'DOCUMENT_ROOT'};
  my $export_data_path     = "${doc_root}/data/$username";
  my $current_runmode      = $self->get_current_runmode();
  my $lock_filename        = "${current_runmode}.lock";

  if ( !(-e $export_data_path) ) {

    mkdir($export_data_path);
  }

  my $lockfile = File::Lockfile->new( $lock_filename, $export_data_path );
  my $pid = $lockfile->check();
  if ( $pid ) {
    $self->logger->debug("$lock_filename exists in $export_data_path");
    my $msg = 'Lockfile exists: either another process of this export is running or ';
    $msg   .= 'there was an unexpected error regarding clearing this lockfile.';
    return $self->_set_error( $msg );
  }

  my $sql   = " SELECT * FROM genpedigree LIMIT 1";

  my ($sam_gen_pedigree_err, $sam_gen_pedigree_msg, $sam_gen_pedigree_data) = $self->list_gen_pedigree(0, $sql);

  if ($sam_gen_pedigree_err) {

    $self->logger->debug($sam_gen_pedigree_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $sample_gen_pedigree_aref = $sam_gen_pedigree_data;

  my @field_list_all = keys(%{$sample_gen_pedigree_aref->[0]});

  #no field return, it means no record. error prevention
  if (scalar(@field_list_all) == 0) {

    push(@field_list_all, '*');
  }

  my $final_field_list = \@field_list_all;

  $sql = 'SELECT ' . join(',',@{$final_field_list}) . ' FROM genpedigree ';

  if (length($field_list_csv) > 0) {

    my ($sel_field_err, $sel_field_msg, $sel_field_list) = parse_selected_field($field_list_csv,
                                                                                \@field_list_all,
                                                                                'GenPedigreeId');

    if ($sel_field_err) {

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $sel_field_msg}]};

      return $data_for_postrun_href;
    }

    $final_field_list = $sel_field_list;
  }

  my ($filter_err, $filter_msg, $filter_phrase, $where_arg) = parse_filtering('GenPedigreeId',
                                                                              'genpedigree',
                                                                              $filtering_csv,
                                                                              $final_field_list,
                                                                              {},
                                                                              {});

  $self->logger->debug("Filter phrase: $filter_phrase");

  if ($filter_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $filter_msg}]};

    return $data_for_postrun_href;
  }

  if (length($filter_phrase) > 0) {

    $sql .= " WHERE $filter_phrase ";
  }

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

    $sql .= ' ORDER BY genpedigree.GenPedigreeId DESC';
  }

  my $sql2md5 = md5_hex($sql);

  my $genpedigree_filename    = "export_genpedigree_$sql2md5.csv";
  my $genpedigree_file        = "${export_data_path}/$genpedigree_filename";

  # where_arg here because of the filtering
  my ($read_ped_err, $read_ped_msg, $gen_pedigree_data) = $self->list_gen_pedigree(0, $sql, $where_arg);

  if ($read_ped_err) {

    $self->logger->debug($read_ped_msg);
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  my $fieldname_order = { 'GenPedigreeId'     => 0,
                          'GenotypeId'        => 1,
                          'ParentGenotypeId'  => 2,
                          'GenParentType'     => 3,
                          'NumberOfGenotypes' => 4,
  };

  arrayref2csvfile($genpedigree_file, $fieldname_order, $gen_pedigree_data);

  my $url = reconstruct_server_url();
  my $elapsed_time = tv_interval($start_time);

  my $href_info = { 'csv'  => "$url/data/$username/$genpedigree_filename" };

  my $time_info = { 'Message' => "Time taken in seconds: $elapsed_time." };

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'OutputFile' => [$href_info], 'Info' => [$time_info] };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub update_genpedigree_runmode {

=pod update_genpedigree_gadmin_HELP_START
{
"OperationName": "Update genpedigree",
"Description": "Update genotype pedigree record specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "genpedigree",
"SuccessMessageXML": "",
"SuccessMessageJSON": "",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error GenotypeId='GenotypeId (482): not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'GenotypeId' : 'GenotypeId (482): not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing GenPedigreeId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self           = shift;
  my $query          = $self->query();
  my $genpedigree_id = $self->param('id');

  my $data_for_postrun_href = {};

  # Generic required static field checking

  my $dbh_read = connect_kdb_read();

  my $skip_field = {'OwnGroupId' => 1};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'genpedigree', $skip_field);

  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  # Finish generic required static field checking

  my $dbh_write = connect_kdb_write();

  if (!record_existence($dbh_write, 'genpedigree', 'GenPedigreeId', $genpedigree_id)) {

    my $err_msg = "GenPedigreeId ($genpedigree_id): not found.";
    return $self->_set_error($err_msg);
  }

  my $genotype_id           = $query->param('GenotypeId');
  my $p_genotype_id         = $query->param('ParentGenotypeId');
  my $parent_type           = $query->param('GenParentType');

  my $chk_int_href = {};
  my $nb_of_genotypes       = undef;

  if ( length($query->param('NumberOfGenotypes')) > 0) {

    $nb_of_genotypes = $query->param('NumberOfGenotypes');
    $chk_int_href->{'NumberOfGenotypes'} = $nb_of_genotypes;
  }

  my ($int_err, $int_err_href) = check_integer_href( $chk_int_href );

  if ($int_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $int_err_href}]};

    return $data_for_postrun_href;
  }

  if (!type_existence($dbh_write, 'genparent', $parent_type)) {

    my $err_msg = "GenParentType ($parent_type): not found or inactive.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'GenParentType' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (!record_existence($dbh_write, 'genotype', 'GenotypeId', $genotype_id)) {

    my $err_msg = "GenotypeId ($genotype_id): not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'GenotypeId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (!record_existence($dbh_write, 'genotype', 'GenotypeId', $p_genotype_id)) {

    my $err_msg = "ParentGenotypeId ($p_genotype_id): not found.";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'ParentGenotypeId' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $group_id  = $self->authen->group_id();
  my $gadmin_status = $self->authen->gadmin_status();

  my ($is_geno_ok, $trouble_geno_id_aref) = check_permission($dbh_write, 'genotype', 'GenotypeId',
                                                             [$genotype_id], $group_id, $gadmin_status,
                                                             $READ_WRITE_PERM);

  if (!$is_geno_ok) {

    my $perm_err_msg = '';
    $perm_err_msg   .= "Permission denied: Group ($group_id) and Genotype ($genotype_id).";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $perm_err_msg}]};

    return $data_for_postrun_href;
  }

  ($is_geno_ok, $trouble_geno_id_aref) = check_permission($dbh_write, 'genotype', 'GenotypeId',
                                                          [$p_genotype_id], $group_id, $gadmin_status,
                                                          $LINK_PERM);

  if (!$is_geno_ok) {

    my $perm_err_msg = '';
    $perm_err_msg   .= "Permission denied: Group ($group_id) and ParentGenotype ($p_genotype_id).";

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $perm_err_msg}]};

    return $data_for_postrun_href;
  }

  my $sql = 'SELECT GenPedigreeId FROM genpedigree WHERE GenotypeId=? AND ParentGenotypeId=? AND GenParentType=?';

  my ($r_gen_pedigree_err, $db_gen_pedigree_id) = read_cell($dbh_write, $sql, [$genotype_id, $p_genotype_id, $parent_type]);

  if ($r_gen_pedigree_err) {

    $self->logger->debug("Read GenPedigreeId failed");
    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_gen_pedigree_id) > 0) {

    my $err_msg = "Genotype ($genotype_id), ParentGenotype ($p_genotype_id), GenParentType ($parent_type): already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  $sql    = 'UPDATE genpedigree SET ';
  $sql   .= 'GenotypeId=?, ';
  $sql   .= 'ParentGenotypeId=?, ';
  $sql   .= 'GenParentType=?, ';
  $sql   .= 'NumberOfGenotypes=? ';
  $sql   .= 'WHERE GenPedigreeId=?';


  my $sth = $dbh_write->prepare($sql);
  $sth->execute($genotype_id, $p_genotype_id, $parent_type, $nb_of_genotypes, $genpedigree_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg_aref  = [{'Message' => "GenPedigree ($genpedigree_id) has been updated successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub del_genpedigree_runmode {

=pod del_genpedigree_gadmin_HELP_START
{
"OperationName": "Delete genpedigree",
"Description": "Delete genotype pedigree specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='GenPedigreeId (10) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'GenPedigreeId (11) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='GenPedigreeId (6) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'GenPedigreeId (6) not found.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing GenPedigreeId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self             = shift;
  my $gen_pedigree_id  = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_k_read = connect_kdb_read();

  my $gen_pedigree_exist = record_existence($dbh_k_read, 'genpedigree', 'GenPedigreeId', $gen_pedigree_id);

  if (!$gen_pedigree_exist) {

    my $err_msg = "GenPedigreeId ($gen_pedigree_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $dbh_k_write = connect_kdb_write();

  my $sql = 'DELETE FROM genpedigree WHERE GenPedigreeId=?';
  my $sth = $dbh_k_write->prepare($sql);

  $sth->execute($gen_pedigree_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref = [{'Message' => "GenPedigreeId ($gen_pedigree_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}


sub add_taxonomy_runmode {

=pod add_taxonomy_HELP_START
{
"OperationName": "Add Taxonomy",
"Description": "This interface can be used to add a taxonomy to KDDart",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "taxonomy",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><ReturnId Value='1' ParaName='TaxonomyId' /><Info Message='Taxonomy (1) has been added successfully.' /></DATA>",
"SuccessMessageJSON": "{ 'ReturnId' : [{ 'Value' : '7', 'ParaName' : 'TaxonomyId' }], 'Info' : [{ 'Message' : 'Taxonomy (1) has been added successfully.' }]}",
"ErrorMessageXML": [{"NameAlreadyExists": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error TaxonomyName='TaxonomyName (Triticeae): already exists.' /></DATA>", "MissingParameter": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error TaxonomyName='TaxonomyName is missing.' /></DATA>"}],
"ErrorMessageJSON": [{"NameAlreadyExists": "{'Error' : [ {'TaxonomyName' : 'TaxonomyName (Triticeae): already exists.'} ] }", "MissingParameter": "{ 'Error' : [ { 'TaxonomyName' : 'TaxonomyName is missing.' } ] }"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}

=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $dbh_read = connect_kdb_read();

  my $skip_field = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_read,
                                                                                'taxonomy', $skip_field);


  if ($chk_sfield_err) {

    $self->logger->debug($chk_sfield_msg);

    return $for_postrun_href;
  }

  $dbh_read->disconnect();

  my $taxonomy_name = $query->param('TaxonomyName');
  my $taxonomy_class = $query->param('TaxonomyClass');

  my $dbh_write = connect_kdb_write();

  my $taxonomy_name_exist = record_existence($dbh_write, 'taxonomy', 'TaxonomyName', $taxonomy_name);

  if ($taxonomy_name_exist) {

    my $err_msg = "TaxonomyName ($taxonomy_name): already exists.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TaxonomyName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $taxonomy_source = "";
  my $taxonomy_extid = "";
  my $taxonomy_url = "";
  my $taxonomy_note = "";

  my $chk_int_href = {};

  if ( length($query->param('TaxonomySource')) > 0 ) {

    $taxonomy_source  = $query->param('TaxonomySource');
  }

  if ( length($query->param('TaxonomyExtId')) > 0 ) {

    $taxonomy_extid  = $query->param('TaxonomyExtId');
  }

  if ( length($query->param('TaxonomyURL')) > 0 ) {

    $taxonomy_url  = $query->param('TaxonomyURL');
  }

  if ( length($query->param('TaxonomyNote')) > 0 ) {

    $taxonomy_note  = $query->param('TaxonomyNote');
  }

  my $parent_taxonomy_id = undef;

  if ( length($query->param('ParentTaxonomyId')) > 0 ) {

    $parent_taxonomy_id = $query->param('ParentTaxonomyId');
    $chk_int_href->{'ParentTaxonomyId'} = $parent_taxonomy_id;
  }

  my ($int_err, $int_err_href) = check_integer_href( $chk_int_href );

  if ($int_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$int_err_href]};

    return $data_for_postrun_href;
  }

  if ($parent_taxonomy_id eq '0') {

    $parent_taxonomy_id = undef;
  }


  if (defined $parent_taxonomy_id) {
    if (!record_existence($dbh_write, 'taxonomy', 'TaxonomyId', $parent_taxonomy_id)) {

      my $err_msg = "ParentTaxonomyId ($parent_taxonomy_id): not found.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'ParentTaxonomyId' => $err_msg}]};

      return $data_for_postrun_href;
    }

  }

  my $sql    = 'INSERT INTO taxonomy SET ';
  $sql   .= 'TaxonomyName=?, ';
  $sql   .= 'TaxonomyClass=?, ';
  $sql   .= 'TaxonomySource=?, ';
  $sql   .= 'TaxonomyExtId=?, ';
  $sql   .= 'TaxonomyURL=?, ';
  $sql   .= 'TaxonomyNote=?, ';
  $sql   .= 'ParentTaxonomyId=? ';

  my $sth = $dbh_write->prepare($sql);

  $sth->execute($taxonomy_name, $taxonomy_class,
              $taxonomy_source, $taxonomy_extid, $taxonomy_url, $taxonomy_note,
              $parent_taxonomy_id
              );

  if ($dbh_write->err()) {

    $self->logger->debug("SQL Error:" . $dbh_write->errstr());
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  my $taxonomy_id = $dbh_write->last_insert_id(undef, undef, 'taxonomy', 'TaxonomyId');

  $dbh_write->disconnect();

  my $info_msg_aref  = [{'Message' => "Taxonomy ($taxonomy_id) has been added successfully."}];
  my $return_id_aref = [{'Value' => "$taxonomy_id", 'ParaName' => 'TaxonomyId'}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info'      => $info_msg_aref,
                                           'ReturnId'  => $return_id_aref,
  };
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub get_taxonomy_runmode {

=pod get_taxonomy_HELP_START
{
"OperationName": "Get taxonomy",
"Description": "Return detailed information about a taxonomy specified by id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='Taxonomy' /><Taxonomy TaxonomyName='triticum' TaxonomyId='1' delete='delete/taxonomy/1' update='update/taxonomy/1' /></DATA>",
"SuccessMessageJSON": "{ 'RecordMeta' : [{'TagName' : 'Taxonomy'} ], 'Taxonomy' : [{'delete' : 'delete/taxonomy/1', 'TaxonomyId' : '1', 'TaxonomyName' : 'triticum', 'update' : 'update/taxonomy/1'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Taxonomy (15) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{ 'Error' : [  {   'Message' : 'Taxonomy (15) not found.'  } ]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing taxonomy id."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}

=cut

  my $self     = shift;
  my $taxonomy_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh = connect_kdb_read();
  my $taxonomy_exist = record_existence($dbh, 'taxonomy', 'TaxonomyId', $taxonomy_id);
  $dbh->disconnect();

  if (!$taxonomy_exist) {

    my $err_msg = "Taxonomy ($taxonomy_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $where_clause = 'WHERE TaxonomyId=?';

  my ($taxonomy_err, $taxonomy_msg, $taxonomy_data) = $self->list_taxonomy(1, $where_clause, $taxonomy_id);

  if ($taxonomy_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Taxonomy'      => $taxonomy_data,
                                           'RecordMeta' => [{'TagName' => 'Genus'}],
  };

  return $data_for_postrun_href;


}

sub list_taxonomy {

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

  my $sql = 'SELECT * FROM taxonomy ';
  $sql   .= $where_clause;
  $sql   .= ' ORDER BY TaxonomyId DESC';

  my $sth = $dbh->prepare($sql);
  # parameters provided by the caller
  # for example, ('WHERE FieldA=?', '1')
  $sth->execute(@_);

  my $err = 0;
  my $msg = '';
  my $taxonomy_data = [];

  if ( !$dbh->err() ) {

    my $array_ref = $sth->fetchall_arrayref({});

    if ( !$sth->err() ) {

      $taxonomy_data = $array_ref;
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

  my $extra_attr_taxonomy_data = [];

  if ($extra_attr_yes && ($gadmin_status eq '1')) {

    my $taxonomy_id_aref = [];

    for my $row (@{$taxonomy_data}) {

      push(@{$taxonomy_id_aref}, $row->{'TaxonomyId'});
    }

    my $chk_table_aref = [{'TableName' => 'taxonomy', 'FieldName' => 'TaxonomyId'}];

    my ($chk_id_err, $chk_id_msg,
        $used_id_href, $not_used_id_href) = id_existence_bulk($dbh, $chk_table_aref, $taxonomy_id_aref);

    if ($chk_id_err) {

      $self->logger->debug("Check id existence error: $chk_id_msg");
      $err = 1;
      $msg = $chk_id_msg;

      return ($err, $msg, []);
    }

    for my $row (@{$taxonomy_data}) {

      my $taxonomy_id = $row->{'TaxonomyId'};
      $row->{'update'}   = "update/taxonomy/$taxonomy_id";

      if ($not_used_id_href->{$taxonomy_id}) {

        $row->{'delete'}   = "delete/taxonomy/$taxonomy_id";
      }

      push(@{$extra_attr_taxonomy_data}, $row);
    }
  }
  else {

    $extra_attr_taxonomy_data = $taxonomy_data;
  }

  $dbh->disconnect();

  return ($err, $msg, $extra_attr_taxonomy_data);
}




sub update_taxonomy_runmode {

=pod update_taxonomy_HELP_START
{
"OperationName": "Update taxonomy",
"Description": "Update information about the taxonomy specified by taxonomy id.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"KDDArTModule": "main",
"KDDArTTable": "taxonomy",
"KDDArTFactorTable": "taxonomyfactor",
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Taxonomy (1) has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{ 'Info' : [{ 'Message' : 'Taxonomy (1) has been updated successfully.' }]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Taxonomy (1) not found.' /></DATA>", "PermissionDenied": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Taxonomy (1) permission denied.' /></DATA>" }],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [ {'Message' : 'Taxonomy (1) not found.'} ] }", "PermissionDeined": "{ 'Error' : [ { 'Message' : 'Taxonomy (1) permission denied.' } ] }" }],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TaxonomyId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut


  my $self        = shift;
  my $query       = $self->query();
  my $taxonomy_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_k_read = connect_kdb_read();

  my $skip_field = {};

  my ($chk_sfield_err, $chk_sfield_msg, $for_postrun_href) = check_static_field($query, $dbh_k_read,
                                                                                'taxonomy', $skip_field);



  # Generic required static field checking

  my $taxonomy_name = $query->param('TaxonomyName');
  my $taxonomy_class = $query->param('TaxonomyClass');

  my $taxonomy_exist = record_existence($dbh_k_read, 'taxonomy', 'TaxonomyId', $taxonomy_id);

  if (!$taxonomy_exist) {

    my $err_msg = "Taxonomy ($taxonomy_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $chk_gname_sql = 'SELECT TaxonomyId FROM taxonomy WHERE TaxonomyName=? AND TaxonomyId <> ?';

  my ($read_err, $db_taxonomy_id) = read_cell($dbh_k_read, $chk_gname_sql, [$taxonomy_name, $taxonomy_id]);

  if ($read_err) {

    $self->logger->debug("Read exististing taxonomy name failed");

    my $err_msg = 'Unexpected Error.';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if (length($db_taxonomy_id) > 0) {

    my $err_msg = "TaxonomyName ($taxonomy_name): already exists";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'TaxonomyName' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $df_val_start_time = [gettimeofday()];

  my $read_sql = 'SELECT TaxonomySource, TaxonomyExtId, TaxonomyURL, TaxonomyNote, ParentTaxonomyId ';
  $read_sql   .= 'FROM taxonomy WHERE TaxonomyId=?';

  my ($r_df_val_err, $r_df_val_msg, $taxonomy_df_val_data) = read_data($dbh_k_read, $read_sql, [$taxonomy_id]);

  if ($r_df_val_err) {

    $self->logger->debug("Retrieve taxonomy default values for optional fields failed: $r_df_val_msg");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  my $taxonomy_source = undef;
  my $taxonomy_extid = undef;
  my $taxonomy_url = undef;
  my $taxonomy_note = undef;

  my $nb_df_val_rec = scalar(@{$taxonomy_df_val_data});

  if ($nb_df_val_rec != 1) {

    $self->logger->debug("Retrieve taxonomy default values - number of records unacceptable: $nb_df_val_rec");
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected Error'}]};

    return $data_for_postrun_href;
  }

  $taxonomy_source = $taxonomy_df_val_data->[0]->{'TaxonomySource'};
  $taxonomy_extid = $taxonomy_df_val_data->[0]->{'TaxonomyExtId'};
  $taxonomy_url = $taxonomy_df_val_data->[0]->{'TaxonomyURL'};
  $taxonomy_note = $taxonomy_df_val_data->[0]->{'TaxonomyNote'};

  my $df_val_elapsed = tv_interval($df_val_start_time);

  $self->logger->debug("Retrieving default value time: $df_val_elapsed");

  if (length($taxonomy_source) == 0) {

    $taxonomy_source = undef;
  }

  if (length($taxonomy_extid) == 0) {

    $taxonomy_extid = undef;
  }

  if (length($taxonomy_url) == 0) {

    $taxonomy_url = undef;
  }

  if (length($taxonomy_note) == 0) {

    $taxonomy_note = undef;
  }


  my $chk_int_href = {};

  if ( length($query->param('TaxonomySource')) > 0 ) {

    $taxonomy_source  = $query->param('TaxonomySource');
  }

  if ( length($query->param('TaxonomyExtId')) > 0 ) {

    $taxonomy_extid  = $query->param('TaxonomyExtId');
  }

  if ( length($query->param('TaxonomyURL')) > 0 ) {

    $taxonomy_url  = $query->param('TaxonomyURL');
  }

  if ( length($query->param('TaxonomyNote')) > 0 ) {

    $taxonomy_note  = $query->param('TaxonomyNote');
  }

  my $parent_taxonomy_id = undef;


  if ( length($query->param('ParentTaxonomyId')) > 0 ) {

    $parent_taxonomy_id = $query->param('ParentTaxonomyId');
    $chk_int_href->{'ParentTaxonomyId'} = $parent_taxonomy_id;
  }

  my ($int_err, $int_err_href) = check_integer_href( $chk_int_href );

  if ($int_err) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [$int_err_href]};

    return $data_for_postrun_href;
  }


  if ($parent_taxonomy_id eq '0') {

    $parent_taxonomy_id = undef;
  }

  if (defined $parent_taxonomy_id) {
    if (!record_existence($dbh_k_read, 'taxonomy', 'TaxonomyId', $parent_taxonomy_id)) {

      my $err_msg = "ParentTaxonomyId ($parent_taxonomy_id): not found.";

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'ParentTaxonomyId' => $err_msg}]};

      return $data_for_postrun_href;
    }

  }

  $dbh_k_read->disconnect();

  my $dbh_write = connect_kdb_write();


  my $sql = 'UPDATE taxonomy SET ';
  $sql   .= 'TaxonomyName=?, ';
  $sql   .= 'TaxonomyClass=?, ';
  $sql   .= 'TaxonomySource=?, ';
  $sql   .= 'TaxonomyExtId=?, ';
  $sql   .= 'TaxonomyURL=?, ';
  $sql   .= 'TaxonomyNote=?, ';
  $sql   .= 'ParentTaxonomyId=? ';
  $sql   .= 'WHERE TaxonomyId=?';

  $self->logger->debug($sql);

  my $sth = $dbh_write->prepare($sql);
  $sth->execute($taxonomy_name, $taxonomy_class, $taxonomy_source, $taxonomy_extid, $taxonomy_url,$taxonomy_note,$parent_taxonomy_id,
                $taxonomy_id);

  if ($dbh_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }
  $sth->finish();

  $dbh_write->disconnect();

  my $info_msg = "Taxonomy ($taxonomy_id) has been updated successfully.";
  my $info_msg_aref = [{'Message' => $info_msg}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;
}

sub list_taxonomy_runmode {

=pod list_taxonomy_HELP_START
{
"OperationName": "List taxonomy",
"Description": "Return list of taxonomyes in the system.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<DATA><RecordMeta TagName='Taxonomy' /><Taxonomy TaxonomyName='Taxonomy_5477708' TaxonomyId='30' delete='delete/taxonomy/30' update='update/taxonomy/30' /><Taxonomy TaxonomyName='Taxonomy_4085568' TaxonomyId='29' delete='delete/taxonomy/29' update='update/taxonomy/29' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{ 'TagName' : 'Taxonomy' }], 'Taxonomy' : [{'delete' : 'delete/taxonomy/30', 'TaxonomyId' : '30', 'TaxonomyName' : 'Taxonomy_5477708', 'update' : 'update/taxonomy/30'}, {'delete' : 'delete/taxonomy/29', 'TaxonomyId' : '29', 'TaxonomyName' : 'Taxonomy_4085568', 'update' : 'update/taxonomy/29'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self = shift;

  my $data_for_postrun_href = {};

  my $msg = '';

  my ($taxonomy_err, $taxonomy_msg, $taxonomy_data) = $self->list_taxonomy(1, '');

  if ($taxonomy_err) {

    $self->logger->debug($taxonomy_msg);

    $msg = 'Unexpected error';
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $msg}]};

    return $data_for_postrun_href;
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Taxonomy'      => $taxonomy_data,
                                           'RecordMeta' => [{'TagName' => 'Taxonomy'}],
  };

  return $data_for_postrun_href;
}


sub del_taxonomy_gadmin_runmode {

=pod del_taxonomy_gadmin_HELP_START
{
"OperationName": "Delete taxonomy",
"Description": "Delete taxonomy using specified id. Taxonomy can be deleted only if not attached to any lower level related record.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 1,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Taxonomy (3) has been deleted successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Taxonomy (3) has been deleted successfully.'}]}",
"ErrorMessageXML": [{"IdUsed": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Taxonomy (5) is used in Genotype.' /></DATA>"}],
"ErrorMessageJSON": [{"IdUsed": "{'Error' : [{'Message' : 'Taxonomy (5) is used in Genotype.'}]}"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing TaxonomyId."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self       = shift;
  my $taxonomy_id = $self->param('id');

  my $data_for_postrun_href = {};

  my $dbh_k_read = connect_kdb_read();

  my $taxonomy_exist = record_existence($dbh_k_read, 'taxonomy', 'TaxonomyId', $taxonomy_id);

  if (!$taxonomy_exist) {

    my $err_msg = "Taxonomy ($taxonomy_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $taxonomy_used = record_existence($dbh_k_read, 'genotype', 'TaxonomyId', $taxonomy_id);

  if ($taxonomy_used) {

    my $err_msg = "Taxonomy ($taxonomy_id) is used in genotype.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $parent_taxonomy_used = record_existence($dbh_k_read, 'taxonomy', 'ParentTaxonomyId', $taxonomy_id);

  if ($parent_taxonomy_used) {

    my $err_msg = "Taxonomy ($taxonomy_id) is used as a parent for another Taxonomy.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }


  $dbh_k_read->disconnect();

  my $dbh_k_write = connect_kdb_write();

  my $sql = 'DELETE FROM taxonomy WHERE TaxonomyId=?';
  my $sth = $dbh_k_write->prepare($sql);

  $sth->execute($taxonomy_id);

  if ($dbh_k_write->err()) {

    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => 'Unexpected error.'}]};

    return $data_for_postrun_href;
  }

  $sth->finish();

  $dbh_k_write->disconnect();

  my $info_msg_aref = [{'Message' => "Taxonomy ($taxonomy_id) has been deleted successfully."}];

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
  $data_for_postrun_href->{'ExtraData'} = 0;

  return $data_for_postrun_href;


  my $data_for_postrun_href = {};

  return $data_for_postrun_href;
}

sub get_specimen_group_dtd_file {

  my $dtd_path = $ENV{DOCUMENT_ROOT} . '/' . $DTD_PATH;

  return "${dtd_path}/specimengroup.dtd";
}

sub get_genotype_specimen_dtd_file {

  my $dtd_path = $ENV{DOCUMENT_ROOT} . '/' . $DTD_PATH;

  return "${dtd_path}/genotypespecimen.dtd";
}

sub logger {

  my $self = shift;
  return $self->{logger};
}

sub update_specimen_geography_runmode {

=pod update_specimen_geography_HELP_START
{
"OperationName": "Update specimen location",
"Description": "Update specimen's geographical location.",
"AuthRequired": 1,
"GroupRequired": 1,
"GroupAdminRequired": 0,
"SignatureRequired": 1,
"AccessibleHTTPMethod": [{"MethodName": "POST", "Recommended": 1, "WHEN": "ALWAYS"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><Info Message='Specimen (1) location has been updated successfully.' /></DATA>",
"SuccessMessageJSON": "{'Info' : [{'Message' : 'Specimen (1) location has been updated successfully.'}]}",
"ErrorMessageXML": [{"IdNotFound": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Specimen (20) not found.' /></DATA>"}],
"ErrorMessageJSON": [{"IdNotFound": "{'Error' : [{'Message' : 'Specimen (20) not found.'}]}"}],
"HTTPParameter": [{"Name": "specimenlocation", "DataType": "polygon_wkt", "Description": "GIS field defining the polygon geometry object of the specimen in a standard GIS well-known text.", "Type": "LCol", "Required": "1"},{"Name": "specimenlocdt", "DataType": "timestamp", "Description": "DateTime of specimen location", "Type": "LCol", "Required": "0"},{"Name": "currentloc", "DataType": "tinyint", "Description": "Flag to notify current location", "Type": "LCol", "Required": "0"},{"Name": "description", "DataType": "varchar", "Description": "Description for location", "Type": "LCol", "Required": "0"}],
"URLParameter": [{"ParameterName": "id", "Description": "Existing SpecimenId"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self        = shift;
  my $specimen_id = $self->param('id');
  my $query       = $self->query();

  my $data_for_postrun_href = {};

  my $dbh_k_read = connect_kdb_read();
  my $specimen_exist = record_existence($dbh_k_read, 'specimen', 'SpecimenId', $specimen_id);
  $dbh_k_read->disconnect();

  if (!$specimen_exist) {

    my $err_msg = "Specimen ($specimen_id) not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $sub_PGIS_val_builder = sub {
    return "ST_ForceCollection(ST_GeomFromText(?, -1))";
  };

  my ($err, $err_msg) = append_geography_loc(
                                              "specimen",
                                              $specimen_id,
                                              'POINT',
                                              $query,
                                              $sub_PGIS_val_builder,
                                              $self->logger,
                                            );

  if ($err) {
    $data_for_postrun_href = $self->_set_error($err_msg);
  } else {
    my $info_msg_aref = [{'Message' => "Specimen ($specimen_id) location has been updated successfully."}];
    $data_for_postrun_href->{'Error'}     = 0;
    $data_for_postrun_href->{'Data'}      = {'Info' => $info_msg_aref};
    $data_for_postrun_href->{'ExtraData'} = 0;
  }

  return $data_for_postrun_href;
}

sub _set_error {

		my ( $self, $error_message ) = @_;
		return {
				'Error' => 1,
				'Data'	=> { 'Error' => [{'Message' => $error_message || 'Unexpected error.'}] }
		};
}

1;
