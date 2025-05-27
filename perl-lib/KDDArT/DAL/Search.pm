#$Id$
#$Author$

# Copyright (c) 2025, Diversity Arrays Technology, All rights reserved.

# Author    : Puthick Hok
# Created   : 02/06/2010
# Modified  :
# Purpose   : 
#          
#          

package KDDArT::DAL::Search;

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
use Apache::Solr;


sub setup {

  my $self = shift;

  CGI::Session->name($COOKIE_NAME);

  __PACKAGE__->authen->init_config_parameters();
  __PACKAGE__->authen->check_login_runmodes(':all');
  __PACKAGE__->authen->check_content_type_runmodes(':all');
  __PACKAGE__->authen->check_rand_runmodes('');
  __PACKAGE__->authen->count_session_request_runmodes(':all');
  __PACKAGE__->authen->check_signature_runmodes('');
  __PACKAGE__->authen->check_gadmin_runmodes('');
  __PACKAGE__->authen->check_sign_upload_runmodes('');

  $self->run_modes(
    'search_solr'             => 'search_solr_runmode',
    'list_solr_core'          => 'list_solr_core_runmode',
    'list_solr_entity'        => 'list_solr_entity_runmode',
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

sub search_solr_runmode {

=pod search_solr_HELP_START
{
"OperationName": "Search KDDart databases",
"Description": "An interface to search KDDart databases via Solr enterprise search engine",
"AuthRequired": 1,
"GroupRequired": 0,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><specimen_genotype BreedingMethodId='11' GenusId='1' SpecimenName='GID:4830449' SpecimenBarcode='GID:4830449' SpecimenId='4830449' GenotypeId='4830449' FilialGeneration='0' IsActive='1' SolrId='SPEC4830449-GENO4830449' _version_='1545879440151543808' GenotypeName='GID:4830449' entity_name='specimen_genotype' /><Pagination Page='1' NumPerPage='1' NumOfPages='6412361' NumOfRecords='6412361' /><StatInfo ServerElapsedTime='0.082' Unit='second' /><RecordMeta TagName='specimen_genotype' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'specimen_genotype'}],'Pagination' : [{'Page' : '1','NumOfPages' : 6412361,'NumOfRecords' : '6412361','NumPerPage' : '1'}],'specimen_genotype' : [{'IsActive' : '1','FilialGeneration' : '0','SolrId' : 'SPEC4830449-GENO4830449','_version_' : '1545879440151543808','GenotypeName' : 'GID:4830449','entity_name' : 'specimen_genotype','BreedingMethodId' : '11','GenusId' : '1','SpecimenId' : '4830449','GenotypeId' : '4830449','SpecimenName' : 'GID:4830449','SpecimenBarcode' : 'GID:4830449'}],'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.063'}]}",
"ErrorMessageXML": [{"InvalidValue": "<?xml version='1.0' encoding='UTF-8'?><DATA><StatInfo Unit='second' ServerElapsedTime='0.058' /><Error Query='org.apache.solr.search.SyntaxError: Cannot parse 'entity_name:&quot;': Lexical error at line 1, column 14.  Encountered: &lt;EOF&gt; after : &quot;&quot;' /></DATA>"}],
"ErrorMessageJSON": [{"InvalidValue": "{'Error' : [{'Query' : 'org.apache.solr.search.SyntaxError: Cannot parse entity_name: Lexical error at line 1, column 14.  Encountered: EOF after :'}],'StatInfo' : [{'ServerElapsedTime' : '0.064','Unit' : 'second'}]}"}],
"URLParameter": [{"ParameterName": "core", "Description": "Name of Solr core whose indexes the search will use for the query"}, {"ParameterName": "nperpage", "Description": "Number of records in a page for pagination"}, {"ParameterName": "num", "Description": "The page number of the pagination"}],
"HTTPParameter": [{"Required": 1, "Name": "Query", "Description": "Solr querying string which must comply with Solr query syntax"}, {"Required": 0, "Name": "Sorting", "Description": "Solr sorting string which must comply with Solr query syntax. This filtering has no effect if the Solr core specified in the URL has no entity_name defined."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $nb_per_page = 1000;
  my $page        = 1;

  if ( (defined $self->param('nperpage')) && (defined $self->param('num')) ) {

    $nb_per_page = $self->param('nperpage');
    $page        = $self->param('num');
  }

  my $doc_root = $ENV{DOCUMENT_ROOT};

  $self->logger->debug("Document Root: $doc_root");

  my $solr_server_url = $SOLR_URL->{$doc_root};

  $self->logger->debug("Solr URL: $solr_server_url");

  my $solr_query_txt   = $query->param('Query');
  my $sorting          = $query->param('Sorting');
  my $field_list       = '';

  if (defined $query->param('FieldList')) {

    $field_list = $query->param('FieldList');
    $field_list .= ' entity_name';
  }

  if (length($solr_query_txt) == 0) {

    my $err_msg = "Query is missing";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Query' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $core = $self->param('core');

  my ($core_err, $core_msg, $core_href) = get_solr_cores();

  if ($core_err) {

    $self->logger->debug("Get Solr cores failed: $core_msg");

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( ! (defined $core_href->{lc($core)}) ) {

    my $err_msg = "Core ($core): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $solr = Apache::Solr->new(server => $solr_server_url,
                               core => $core,
                               autocommit => 1,
                               format => 'XML'
                              );

  my $solr_start = ($page - 1) * $nb_per_page;

  my $results = $solr->select(q => $solr_query_txt,
                              fl => $field_list,
                              sort => $sorting,
                              rows => $nb_per_page,
                              start => $solr_start
                             );

  if ( ! $results->success() ) {

    my $solr_err_msg  = $results->solrError();
    my $other_err_msg = $results->errors();

    my $err_msg = '';

    if (length($solr_err_msg) > 0) {

      $self->logger->debug("Solr is not successful: $solr_err_msg");
      $err_msg = $solr_err_msg;

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Query' => $err_msg}]};

      return $data_for_postrun_href;
    }
    else {

      $self->logger->debug("Solr is not successful: $other_err_msg");
      $err_msg = 'Unexpected Error';

      $data_for_postrun_href->{'Error'} = 1;
      $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

      return $data_for_postrun_href;
    }
  }

  my $results_href = $results->_getResults();

  my $data_aref = [];

  if (ref $results_href->{'doc'} eq 'HASH') {

    $data_aref = [$results_href->{'doc'}];
  }
  else {

    $data_aref = $results_href->{'doc'};
  }

  $self->logger->debug(join(',', keys(%{$results_href})));

  $data_for_postrun_href->{'Data'}                 = {};
  $data_for_postrun_href->{'Data'}->{'RecordMeta'} = [];

  foreach my $data_href (@{$data_aref}) {

    my $entity_name = $data_href->{'entity_name'};

    if ( !(defined($data_for_postrun_href->{'Data'}->{$entity_name})) ) {

      $data_for_postrun_href->{'Data'}->{$entity_name} = [$data_href];
      push(@{$data_for_postrun_href->{'Data'}->{'RecordMeta'}}, {'TagName' => $entity_name});
    }
    else {

      push(@{$data_for_postrun_href->{'Data'}->{$entity_name}}, $data_href);
    }
  }

  my $nb_found = $results_href->{'numFound'};
  my $start    = $results_href->{'start'};

  $self->logger->debug("Number found: $nb_found - start: $start");

  my $nb_pages = int($nb_found / $nb_per_page);

  if ( ($nb_found % $nb_per_page) ) {

    $nb_pages += 1;
  }

  my $pagination_href = {'NumOfRecords' => $nb_found,
                         'NumOfPages'   => $nb_pages,
                         'Page'         => $page,
                         'NumPerPage'   => $nb_per_page
                        };

  $data_for_postrun_href->{'Data'}->{'Pagination'} = [$pagination_href];

  $data_for_postrun_href->{'Error'}     = 0;

  return $data_for_postrun_href;
}

sub list_solr_core_runmode {

=pod list_solr_core_HELP_START
{
"OperationName": "List available cores in Solr",
"Description": "An interface to list all available Solr cores that DAL can use for the search",
"AuthRequired": 1,
"GroupRequired": 0,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='SolrCore' /><StatInfo ServerElapsedTime='0.015' Unit='second' /><SolrCore size='3.94 MB' current='1' uptime='89619806' startTime='2016-09-19T06:02:32.699Z' lastModified='2016-09-15T06:06:08.338Z' coreName='monetdb' maxDoc='23872' numDocs='23872' sizeInBytes='4129030' /><SolrCore sizeInBytes='2353056039' numDocs='20259866' maxDoc='20259866' coreName='db' lastModified='2016-09-19T06:26:45.835Z' uptime='89619804' startTime='2016-09-19T06:02:32.699Z' current='0' size='2.19 GB' /><SolrCore current='1' size='2.34 GB' startTime='2016-09-19T06:02:32.699Z' uptime='89619797' coreName='dal' lastModified='2016-08-04T05:51:33.669Z' numDocs='33887624' sizeInBytes='2513909378' maxDoc='33887624' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'SolrCore'}],'SolrCore' : [{'current' : false,'size' : '2.19 GB','uptime' : 89661752,'startTime' : '2016-09-19T06:02:32.699Z','coreName' : 'db','lastModified' : '2016-09-19T06:26:45.835Z','sizeInBytes' : 2353056039,'numDocs' : 20259866,'maxDoc' : 20259866},{'uptime' : 89661756,'startTime' : '2016-09-19T06:02:32.699Z','size' : '3.94 MB','current' : true,'maxDoc' : 23872,'sizeInBytes' : 4129030,'numDocs' : 23872,'lastModified' : '2016-09-15T06:06:08.338Z','coreName' : 'monetdb'},{'uptime' : 89661745,'startTime' : '2016-09-19T06:02:32.699Z','current' : true,'size' : '2.34 GB','numDocs' : 33887624,'sizeInBytes' : 2513909378,'maxDoc' : 33887624,'coreName' : 'dal','lastModified' : '2016-08-04T05:51:33.669Z'}],'StatInfo' : [{'ServerElapsedTime' : '0.017','Unit' : 'second'}]}",
"ErrorMessageXML": [{"UnexpectedError": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Message='Unexpected Error.' /></DATA>"}],
"ErrorMessageJSON": [{"UnexpectedError": "{'Error' : [{'Message' : 'Unexpected Error.' }]}"}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my ($core_err, $core_msg, $core_href) = get_solr_cores();

  if ($core_err) {

    $self->logger->debug("Get Solr cores failed: $core_msg");

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $core_aref = [];

  foreach my $core_name (keys(%{$core_href})) {

    push(@{$core_aref}, $core_href->{$core_name});
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'SolrCore'   => $core_aref,
                                           'RecordMeta' => [{'TagName' => 'SolrCore'}],
                                          };

  return $data_for_postrun_href;
}

sub list_solr_entity_runmode {

=pod list_solr_entity_HELP_START
{
"OperationName": "List available entities in a Solr core",
"Description": "An interface to list all available entities in the specified Solr core",
"AuthRequired": 1,
"GroupRequired": 0,
"GroupAdminRequired": 0,
"SignatureRequired": 0,
"AccessibleHTTPMethod": [{"MethodName": "POST"}, {"MethodName": "GET"}],
"SuccessMessageXML": "<?xml version='1.0' encoding='UTF-8'?><DATA><RecordMeta TagName='SolrEntity' /><SolrEntity query='select &apos;specimen_genotype&apos; as entity_name, concat(&apos;SPEC&apos;, specimen.SpecimenId, &apos;-GENO&apos;, genotype.GenotypeId) as SolrId, specimen.*, genotype.GenotypeId, GenotypeName, GenusId, SpeciesName, GenotypeAcronym, GenotypeNote from specimen left join genotypespecimen ON specimen.SpecimenId=genotypespecimen.SpecimenId left join genotype on genotypespecimen.GenotypeId=genotype.GenotypeId limit 6000000,1000000;' entity_name='specimen_genotype'><fields stored='1' indexed='1' name='GenotypeAcronym' type='string' multiValued='0' required='0' /><fields type='long' name='GenotypeId' required='0' multiValued='0' stored='1' indexed='1' /><fields indexed='1' stored='1' required='0' multiValued='0' type='text_general' name='GenotypeName' /><fields stored='1' indexed='1' name='GenotypeNote' type='text_general' required='0' multiValued='0' /><fields type='int' name='GenusId' multiValued='0' required='0' stored='1' indexed='1' /><fields required='1' multiValued='0' name='SolrId' type='text_general' indexed='1' stored='1' /><fields type='string' name='SpeciesName' required='0' multiValued='0' stored='1' indexed='1' /><fields name='SpecimenId' type='long' required='0' multiValued='0' stored='1' indexed='1' /><fields indexed='1' stored='1' multiValued='0' required='1' name='entity_name' type='text_general' /></SolrEntity><StatInfo Unit='second' ServerElapsedTime='0.031' /></DATA>",
"SuccessMessageJSON": "{'RecordMeta' : [{'TagName' : 'SolrEntity'}],'SolrEntity' : [{'entity_name' : 'specimen_genotype','query' : 'select &apos;specimen_genotype&apos; as entity_name, concat(&apos;SPEC&apos;, specimen.SpecimenId, &apos;-GENO&apos;, genotype.GenotypeId) as SolrId, specimen.*, genotype.GenotypeId, GenotypeName, GenusId, SpeciesName, GenotypeAcronym, GenotypeNote from specimen left join genotypespecimen ON specimen.SpecimenId=genotypespecimen.SpecimenId left join genotype on genotypespecimen.GenotypeId=genotype.GenotypeId limit 7000000,1000000;','fields' : [{'name' : 'GenotypeAcronym','type' : 'string','required' : false,'multiValued' : false,'stored' : true,'indexed' : true},{'type' : 'long','name' : 'GenotypeId','multiValued' : false,'required' : false,'stored' : true,'indexed' : true},{'type' : 'text_general','name' : 'GenotypeName','multiValued' : false,'required' : false,'stored' : true,'indexed' : true},{'name' : 'GenotypeNote','type' : 'text_general','multiValued' : false,'required' : false,'stored' : true,'indexed' : true},{'indexed' : true,'stored' : true,'multiValued' : false,'required' : false,'type' : 'int','name' : 'GenusId'},{'indexed' : true,'stored' : true,'required' : true,'multiValued' : false,'name' : 'SolrId','type' : 'text_general'},{'indexed' : true,'stored' : true,'required' : false,'multiValued' : false,'name' : 'SpeciesName','type' : 'string'},{'required' : false,'multiValued' : false,'name' : 'SpecimenId','type' : 'long','indexed' : true,'stored' : true},{'stored' : true,'indexed' : true,'type' : 'text_general','name' : 'entity_name','required' : true,'multiValued' : false}]}],'StatInfo' : [{'Unit' : 'second','ServerElapsedTime' : '0.044'}]}",
"ErrorMessageXML": [{"InvalidValue": "<?xml version='1.0' encoding='UTF-8'?><DATA><Error Filtering='Filtering (entity_name:&quot;specimen_genotype&quot;): invalid.' /><StatInfo ServerElapsedTime='0.002' Unit='second' /></DATA>"}],
"ErrorMessageJSON": [{"InvalidValue": "{'Error' : [{'Filtering' : 'Filtering (entity_name:&quot;specimen_genotype&quot;): invalid.'}],'StatInfo' : [{'ServerElapsedTime' : '0.002','Unit' : 'second'}]}"}],
"URLParameter": [{"ParameterName": "core", "Description": "Name of Solr core whose indexes the search will use for the query"}],
"HTTPParameter": [{"Required": 0, "Name": "Filtering", "Description": "Filtering for entity_name field. It supports equal and IN expression, for example, Filtering=entity_name='item_spec' or Filtering=entity_name IN ('item_spec')."}],
"HTTPReturnedErrorCode": [{"HTTPCode": 420}]
}
=cut

  my $self  = shift;
  my $query = $self->query();

  my $data_for_postrun_href = {};

  my $filtering = '';

  my @filter_entity_name_list;

  if (defined $query->param('Filtering')) {

    if (length($query->param('Filtering')) > 0) {

      $filtering = $query->param('Filtering');

      if ($filtering =~ /entity_name\s*=\s*(['|"])(\w+)\1/i) {

        my $en_name = $2;
        push(@filter_entity_name_list, $en_name);
      }
      elsif ($filtering =~ /entity_name\s+IN\s+\(((['|"])\w+\2(\s*,\s*\2\w+\2)*)\)/i) {

        my $entity_name_csv = $1;
        my $quote_char      = $2;

        $entity_name_csv =~ s/$quote_char//g;

        @filter_entity_name_list = split(',', $entity_name_csv);
      }
      else {

        my $err_msg = "Filtering ($filtering): invalid.";
        $data_for_postrun_href->{'Error'} = 1;
        $data_for_postrun_href->{'Data'}  = {'Error' => [{'Filtering' => $err_msg}]};

        return $data_for_postrun_href;
      }
    }
  }

  my $core = $self->param('core');

  my ($core_err, $core_msg, $core_href) = get_solr_cores();

  if ($core_err) {

    $self->logger->debug("Get Solr cores failed: $core_msg");

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  if ( ! (defined $core_href->{lc($core)}) ) {

    my $err_msg = "Core ($core): not found.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($get_en_err, $get_en_msg, $entity_href) = get_solr_entities($core);

  if ($get_en_err) {

    $self->logger->debug("Get entities failed: $get_en_msg");

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my ($get_f_err, $get_f_msg, $core_field_aref) = get_solr_fields($core);

  if ($get_f_err) {

    $self->logger->debug("Get fields failed: $get_f_msg");

    my $err_msg = "Unexpected Error.";
    $data_for_postrun_href->{'Error'} = 1;
    $data_for_postrun_href->{'Data'}  = {'Error' => [{'Message' => $err_msg}]};

    return $data_for_postrun_href;
  }

  my $entity_aref = [];

  my @entity_name_list = keys(%{$entity_href});

  if (scalar(@entity_name_list) > 0) {

    foreach my $entity_name (@entity_name_list) {

      my $do_work = 1;

      if (scalar(@filter_entity_name_list) > 0) {

        $do_work = 0;

        foreach my $filter_entity_name (@filter_entity_name_list) {

          if (lc($entity_name) eq trim(lc($filter_entity_name))) {

            $do_work = 1;
          }
        }
      }

      if ( !$do_work ) { next; }

      my $l_entity_href = $entity_href->{$entity_name};
      my $sql_query     = $l_entity_href->{'query'};

      my @sql_query_part = split(/from/i, $sql_query);

      my $select_field_csv = $sql_query_part[0];

      my $entity_field_aref = [];

      foreach my $field_href (@{$core_field_aref}) {

        my $field_name = $field_href->{'name'};
        my $field_type = $field_href->{'type'};

        if ( ($field_name eq 'text' && $field_type eq 'text_general') ||
             ($field_name eq 'text_rev' && $field_type eq 'text_general_rev') ||
             ($field_name eq '_root_') ) {

          next;
        }

        if ($select_field_csv =~ /$field_name/i) {

          push(@{$entity_field_aref}, $field_href);
        }
      }

      $l_entity_href->{'fields'} = $entity_field_aref;

      push(@{$entity_aref}, $l_entity_href);
    }
  }
  else {

    my $entity_field_aref = [];

    foreach my $field_href (@{$core_field_aref}) {

      my $field_name = $field_href->{'name'};
      my $field_type = $field_href->{'type'};

      if ( ($field_name eq 'text' && $field_type eq 'text_general') ||
           ($field_name eq 'text_rev' && $field_type eq 'text_general_rev') ||
           ($field_name eq '_root_') ) {

        next;
      }

      push(@{$entity_field_aref}, $field_href);
    }

    my $l_entity_href = {'fields' => $entity_field_aref};
    push(@{$entity_aref}, $l_entity_href);
  }

  $data_for_postrun_href->{'Error'}     = 0;
  $data_for_postrun_href->{'Data'}      = {'SolrEntity'   => $entity_aref,
                                           'RecordMeta'   => [{'TagName' => 'SolrEntity'}],
                                          };

  return $data_for_postrun_href;
}

1;
