#!/usr/bin/perl -w

# DAL interactions
#   'export/genpedigree' to get stuff (no parameters)
#   list/genotype - to get detailed genotype information,
#   for more go listing germplasm in DAL reference at kddart.org
#   genotype/$genotype_id/list/ancestor?Level=5&ctype=json"
#
# Output is $result_file, which is json array, of $saved_parentage_aref
#

use strict;
use warnings;

use LWP::UserAgent;
use HTTP::Request::Common qw(POST GET);
use HTTP::Cookies;
use Time::HiRes qw( tv_interval gettimeofday );
use String::Random qw( random_string );
use Digest::MD5 qw(md5 md5_hex md5_base64);
use Digest::HMAC_SHA1 qw(hmac_sha1 hmac_sha1_hex);
use JSON::XS qw(decode_json encode_json);
use Text::CSV;
use Text::CSV::Simple;
use Storable;
use MCE;
use Getopt::Long;
use XML::Simple;

$ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'} = 0;

my $saved_parentage_aref = [];
my $genotype2nb_ancestor = {};

my $DEBUG = 0;

sub custom_gather {

  return sub {

    my ($chunk_id, $data, $genotype_id, $nb_ancestor) = @_;

    push(@{$saved_parentage_aref}, $data);
    $genotype2nb_ancestor->{$genotype_id} = $nb_ancestor;
	}
}

# Usage: perl -w $0 --dalbaseurl \"http://url.to/dal\" --workingdir \"/tmp\" --username \"kddartuser\" --password \"secret\" --kddartgroupid 1 --solrhost \"http://localhost\" --solrport 8983 --solrcorecsv \"db,monetdb,dal\"

my $help            = 0;
my $dalbaseurl      = '';
my $workingdir      = '';
my $username        = '';
my $password        = '';
my $group_id        = '';
my $solrhost        = '';
my $solrport        = '';
my $solrcorecsv     = '';

my $optres = GetOptions(
	"help|h|?"           => \$help,
  "dalbaseurl=s"       => \$dalbaseurl,
  "workingdir=s"       => \$workingdir,
  "username=s"         => \$username,
  "password=s"         => \$password,
  "kddartgroupid=i"    => \$group_id,
  "solrhost=s"         => \$solrhost,
  "solrport=s"         => \$solrport,
  "solrcorecsv=s"      => \$solrcorecsv,
);

if ($help) {

  print &Usage();
  exit 0;
}

if ( length($dalbaseurl) == 0 ||
     length($workingdir) == 0 ||
     length($username) == 0 ||
     length($password) == 0 ||
     length($group_id) == 0 ||
     length($solrhost) == 0 ||
     length($solrport) == 0 ||
     length($solrcorecsv) == 0 ) {

  print "dalbaseurl: $dalbaseurl - workingdir: $workingdir - username: $username - password: $password - group_id: $group_id - solrhost: $solrhost - solrport: $solrport - sorlcorecsv: $solrcorecsv\n";

  print &Usage();
  exit 0;
}

my @core_list = split(',', $solrcorecsv);

my $core_href = {};

foreach my $core (@core_list) {

  $core_href->{lc($core)} = 1;
}

my $solrurl = "${solrhost}:${solrport}";

$dalbaseurl =~ s/^\///; #remove trailing '/'

my $solr_http_client  = LWP::UserAgent->new();

my $inside_req_res;

my $inside_req;

if ($core_href->{'db'}) {

  my $reindex_url = "${solrurl}/solr/db/dataimport?command=full-import&clean=true&commit=true&wt=json";

  $inside_req_res = GET($reindex_url);

  $inside_req = $solr_http_client->request($inside_req_res);

  my $solr_reindex_content = $inside_req->content();

  print "Solr reindex result: $solr_reindex_content";

  if ( $inside_req->status_line ne '200 OK' ) {

    die "Solr $reindex_url failed\n";
  }
}

if ($core_href->{'monetdb'}) {

  my $reindex_url = "${solrurl}/solr/monetdb/dataimport?command=full-import&clean=true&commit=true&wt=json";

  $inside_req_res = GET($reindex_url);

  $inside_req = $solr_http_client->request($inside_req_res);

  my $solr_reindex_content = $inside_req->content();

  print "Solr reindex result: $solr_reindex_content";

  if ( $inside_req->status_line ne '200 OK' ) {

    die "Solr $reindex_url failed\n";
  }
}

if ($core_href->{'dal'}) {

  my $cookie_file = $workingdir . '/' . 'lwp_cookies.dat';

  my $browser  = LWP::UserAgent->new();

  my $cookie_jar = HTTP::Cookies->new(
                                      file => $cookie_file,
                                      autosave => 1,
                                     );

  $browser->cookie_jar($cookie_jar);

  my $url;

  my $parameter = [];

  $url = $dalbaseurl . "/login/${username}/no";

  my $hash_pass = hmac_sha1_hex($username, $password);

  my $rand           = make_random_number();
  my $session_pass   = hmac_sha1_hex($rand, $hash_pass);
  my $signature      = hmac_sha1_hex($url, $session_pass);

  $ parameter = [
                 rand_num      => "$rand",
                 url           => "$url",
                 signature     => "$signature",
                ];

  $inside_req_res = POST($url, $parameter);

  $inside_req = $browser->request($inside_req_res);

  print "Status line: " . $inside_req->status_line . "\n";

  if ( $inside_req->status_line ne '200 OK' ) {

    die "DAL $url failed: " . $inside_req->content() . "\n";
  }

  $url = $dalbaseurl . "/switch/group/${group_id}";

  $inside_req_res = POST($url);

  $inside_req = $browser->request($inside_req_res);

  if ( $inside_req->status_line ne '200 OK' ) {

    die "DAL $url failed: " . $inside_req->content() . "\n";
  }

  $cookie_jar->save($cookie_file);

  my $solr_query_url = "${solrurl}/solr/dal/select?q=*%3A*&sort=GenotypeId+DESC&start=0&rows=1&wt=json";

  $inside_req_res = GET( $solr_query_url );

  $inside_req = $solr_http_client->request($inside_req_res);

  $inside_req = $browser->request($inside_req_res);

  if ( $inside_req->status_line ne '200 OK' ) {

    die "Solr $solr_query_url failed: " . $inside_req->content() . "\n";
  }

  my $solr_largest_genotype_id = 0;

  my $solr_genotype_content = $inside_req->content();

  my $solr_geno_aref = undef;

  my $solr_data_obj = undef;

  eval { $solr_data_obj = decode_json($solr_genotype_content); };

  if ($@) {

    print "Solr Genotype content: $solr_genotype_content\n";
    die "Cannot decode solr genotype content: $@\n";
  }

  if (defined $solr_data_obj) {

    $solr_geno_aref = $solr_data_obj->{'response'}->{'docs'};
  }

  if (scalar(@{$solr_geno_aref}) > 0) {

    $solr_largest_genotype_id = $solr_geno_aref->[0]->{'GenotypeId'};
  }

  print "Solr Largest Genotype Id: $solr_largest_genotype_id\n";

  my $output_file_xml;
  my $output_file_aref;

  my $uniq_geno_href = {};

  my $gen_pedigree_fieldname_aref = ['GenPedigreeId', 'GenotypeId', 'ParentGenotypeId',
                                     'GenParentType', 'NumberOfGenotypes'];

  my $uniq_geno_start_time = [gettimeofday()];

  my $gen_pedigree_file   = $workingdir . '/' . 'gen_pedigree_file';

  my $geno_id_start  = 0;
  my $geno_id_end    = 0;

  $url       = $dalbaseurl . '/export/genpedigree';

  $parameter = [];

  $inside_req_res = POST ($url, $parameter);

  $inside_req = $browser->request($inside_req_res);

  if ( $inside_req->status_line ne '200 OK' ) {

    die "DAL $url failed: " . $inside_req->content() . "\n";
  }

  $output_file_xml  = $inside_req->content();
  $output_file_aref = xml2arrayref($output_file_xml, 'OutputFile');

  for my $item (@{$output_file_aref}) {

    for my $k (keys(%{$item})) {

      my $file_url = $item->{$k};

      my $download_response = $browser->get($file_url,
                                            ':content_file' => $gen_pedigree_file
                                           );
      print "Download header: " . $download_response->header('Set-Cookie') . "\n";
      print "Downloading $file_url: " . $download_response->content() . "\n";
      print "$k : $file_url\n";

      my ($gen_pedigree_aref, $csv_err, $csv_err_msg) = csvfile2arrayref("$gen_pedigree_file",
                                                                         $gen_pedigree_fieldname_aref,
                                                                         0);

      if ($csv_err) {

        print "CSV Error: $csv_err_msg\n";
        exit;
      }

      foreach my $gen_pedigree_href (@{$gen_pedigree_aref}) {

        my $genotype_id = $gen_pedigree_href->{'GenotypeId'};

        $uniq_geno_href->{"$genotype_id"} = 1;
      }
    }
  }

  my $uniq_geno_elapsed_time = tv_interval($uniq_geno_start_time);
  print "Generate unique genotype time: $uniq_geno_elapsed_time\n";

  my @all_uniq_geno_id_list = sort {$a <=> $b} keys(%{$uniq_geno_href});

  print "Number of genotypes: " . scalar(@all_uniq_geno_id_list) . "\n";

  if (scalar(@all_uniq_geno_id_list) == 0) {

    print "No pedigree record\n";
    exit 1;
  }

  my $dal_largest_genotype_id = $all_uniq_geno_id_list[-1];

  print "Solr largest genotype id: $solr_largest_genotype_id\n";
  print "DAL largest genotype id: $dal_largest_genotype_id\n";

  if ($dal_largest_genotype_id > $solr_largest_genotype_id) {

    $geno_id_start = $solr_largest_genotype_id;
    $geno_id_end   = $dal_largest_genotype_id;
  } else {

    # Commenting section to debug why the number of ancestor is not consistent
    # in every run

    print "Nothing to add to Solr index\n";
    exit 1;
  }

  my $nb_geno_processing_threshold = 100000;

  my $geno_id_end_j = 0;

  if ($geno_id_end < $nb_geno_processing_threshold) {

    $geno_id_end_j = $geno_id_end;
  }
  else {

    $geno_id_end_j = $nb_geno_processing_threshold;
  }

  my $result_file_stem    = 'ancestor_solr_doc';

  my $geno_id_start_j = 0;

  my $nb_solr_file    = 1;
  my @solr_file_list;

  # Need to reattach the cookie file otherwise it will fail

  sleep(5);

  $browser  = LWP::UserAgent->new();

  $cookie_jar = HTTP::Cookies->new(
                                   file => $cookie_file,
                                  );

  $browser->cookie_jar($cookie_jar);

  while ($geno_id_start_j <= $geno_id_end) {

    my @uniq_geno_id_list;

    print "GenoId Start J: $geno_id_start_j\n";
    print "GenoId End J: $geno_id_end_j\n";

    foreach my $genotype_id (@all_uniq_geno_id_list) {

      if ($genotype_id > $geno_id_start_j && $genotype_id <= $geno_id_end_j) {

        push(@uniq_geno_id_list, $genotype_id);
      }
    }

    #print "Unique GenotypeId List: " . join(',', @uniq_geno_id_list) . "\n";

    my $total_nb_geno = scalar(@uniq_geno_id_list);

    my $i = 0;

    print "Total number of genotype: $total_nb_geno\n";

    my $mce = MCE->new(
                       chunk_size => 1, max_workers => 10,
                       gather => custom_gather
                      );

    while ($i < $total_nb_geno) {

      #print "i = $i\n";
      my $loop_start_time = [gettimeofday()];
      my $j = $i + 1000;

      if ($j > ($total_nb_geno-1)) {
        $j = $total_nb_geno - 1;
      }

      my @sliced_uniq_geno_id_list = @uniq_geno_id_list[$i .. $j];

      my $geno_id_csv = join(',', @sliced_uniq_geno_id_list);
      my $list_genotype_url = "/list/genotype/1000/page/1?ctype=json&Filtering=GenotypeId IN ";
      $list_genotype_url   .= "($geno_id_csv)&FieldList=GenotypeName";

      $i += 1000;

      $list_genotype_url = $dalbaseurl . $list_genotype_url;

      my $genotype_req = GET($list_genotype_url);

      my $genotype_response = $browser->request($genotype_req);

      my $genotype_result = $genotype_response->content();

      my $genotype_data;

      eval {

        $genotype_data = decode_json($genotype_result);
      };

      if ($@) {

        print "Decode JSON for genotype error: $@\n";
        exit;
      }

      my $genotype_lookup_href = {};

      foreach my $genotype_href (@{$genotype_data->{'Genotype'}}) {

        my $genotype_id = $genotype_href->{'GenotypeId'};
        my $genotype_name = $genotype_href->{'GenotypeName'};
        $genotype_lookup_href->{$genotype_id} = $genotype_name;
      }

      #print "Sliced unique genotype id list: " . join(',', @sliced_uniq_geno_id_list) . "\n";

      $mce->foreach( \@sliced_uniq_geno_id_list, sub {

        my ($mce, $chunk_ref, $chunk_id) = @_;

        my $genotype_id = $_;

        #print "Chunk id: $chunk_id - GenotypeId: $genotype_id\n";

        my $parentage_url = $dalbaseurl . "/genotype/$genotype_id/list/ancestor?Level=5&ctype=json";

        my $parentage_req = GET($parentage_url);

        my $parentage_response = $browser->request($parentage_req);

        if ($parentage_response->status_line ne '200 OK' ) {

          print "Chunk id: $chunk_id - GenotypeId: $genotype_id\n";
          die "DAL $parentage_url failed: " . $inside_req->content() . "\n";
        }

        my $parentage_result = $parentage_response->content();

        #print "Parentage URL: $parentage_url - result $parentage_result\n";

        my $result_href;

        eval {

          $result_href = decode_json($parentage_result);
        };

        if ($@) {

          print "Decode JSON error: $@\n";
          exit;
        }

        my $genotype_name = $genotype_lookup_href->{$genotype_id};

        if (defined $result_href) {

          my $ancestor_aref = $result_href->{'Ancestor'};

          my $counter = 0;

          my $nb_ancestor = scalar(@{$ancestor_aref});

          foreach my $ancestor_href (@{$ancestor_aref}) {

            my $parent_genotype_id          = $ancestor_href->{'ParentGenotypeId'};
            my $parent_genotype_name        = $ancestor_href->{'ParentGenotypeName'};
            my $parent_type_name            = $ancestor_href->{'GenParentTypeName'};
            my $level                       = $ancestor_href->{'Level'};

            my $solr_id                     = "GA-$genotype_id-$counter";

            my $solr_ancestor_href = {'GenotypeId' => $genotype_id,
                                      'SolrId' => $solr_id,
                                      'entity_name' => 'gen_ancestor',
                                      'GenotypeName' => $genotype_name,
                                      'AncestorId' => $parent_genotype_id,
                                      'AncestorName' => $parent_genotype_name,
                                      'AncestorTypeName' => $parent_type_name,
                                      'Level' => $level};

            $counter += 1;

            MCE->gather($chunk_id, $solr_ancestor_href, $genotype_id, $nb_ancestor);
          }
        }
      });

      my $loop_elapsed_time = tv_interval($loop_start_time);
      print "Time for i: $i = $loop_elapsed_time\n";
    }

    my $json_encoder = JSON::XS->new();
    $json_encoder->pretty(1);

    print "Number of Solr docs: " . scalar(@{$saved_parentage_aref}) . "\n";

    my $saved_parentage_json = $json_encoder->encode($saved_parentage_aref);

    my $result_file = $workingdir . '/' . $result_file_stem . sprintf("%03d", $nb_solr_file) . '.json';

    my $saved_filehandle;

    open($saved_filehandle, ">$result_file");

    print $saved_filehandle $saved_parentage_json;

    close($saved_filehandle);

    push(@solr_file_list, $result_file);

    $geno_id_start_j = $geno_id_end_j + 1;

    $geno_id_end_j += $nb_geno_processing_threshold;
  }

  #
  # Output results, which are the contents of $saved_parentage_aref
  # which are written to by custom_gather, which is used by mce thing
  # above which parrallels the process to speed up for a medium to
  # large pedigree data.
  #
  # In general the process of generating csvs on the server, downloading
  # and processing with the ultimate goal of loading back up to the server
  # is due to the need to search genotype based on distant ancestor.
  # For example, 'a' is the parent of 'b', which is a parent of 'c' which
  # is a parent of 'd'. With this process, we can list 'b' (child),
  # 'c' (grand child), and 'd' (great grand child) genotypes for a search
  # query looking for genotypes that have 'a' as their ancestor.
  #

  my $solr_update_url = "${solrurl}/solr/dal/update";

  foreach my $result_file (@solr_file_list) {

    $parameter = [];

    push(@{$parameter}, 'uploadfile' => [$result_file]);
    push(@{$parameter}, 'overwrite' => 'true');
    push(@{$parameter}, 'commit' => 'true');

    $inside_req_res = POST($solr_update_url,
                           'Content_Type' => 'multipart/form-data',
                           'Content' => $parameter);

    $inside_req = $solr_http_client->request($inside_req_res);

    my $solr_update_content = $inside_req->content();

    print "Solr update result: $solr_update_content\n";

    if ( $inside_req->status_line ne '200 OK' ) {

      die "Solr $solr_update_url failed\n";
    }
  }

  my $solr_reload_url = "${solrurl}/solr/admin/cores?core=dal&action=reload";

  $inside_req_res = GET($solr_reload_url);

  $inside_req = $solr_http_client->request($inside_req_res);

  my $solr_reload_content = $inside_req->content();

  print "Solr reload result: $solr_reload_content";

  if ( $inside_req->status_line ne '200 OK' ) {

    die "Solr $solr_reload_url failed\n";
  }

  $browser  = LWP::UserAgent->new();

  $cookie_jar = HTTP::Cookies->new(
                                   file => $cookie_file,
                                  );

  $browser->cookie_jar($cookie_jar);

  $url = $dalbaseurl . '/logout';

  $inside_req_res = GET($url);

  $inside_req = $browser->request($inside_req_res);

  if ( $inside_req->status_line ne '200 OK' ) {

    die "DAL $url failed: " . $inside_req->content() . "\n";
  }

  if ($DEBUG) {

    my $prev_nb_ancestor_href = {};

    my $nb_ancestor_stat_file = $workingdir . '/nb_ancestor_stat_file.bin';

    if ( ! (-e $nb_ancestor_stat_file) ) {

      store($genotype2nb_ancestor, $nb_ancestor_stat_file);
    }
    else {

      if (-R $nb_ancestor_stat_file) {

        $prev_nb_ancestor_href = retrieve($nb_ancestor_stat_file);
      }
    }

    print "Number of ancestor stat: \n";

    my @geno_with_ancestor_list = sort {$a <=> $b} keys(%{$genotype2nb_ancestor});

    foreach my $geno_id (@geno_with_ancestor_list) {

      if ( (defined $prev_nb_ancestor_href->{$geno_id}) &&
           ($prev_nb_ancestor_href->{$geno_id} ne $genotype2nb_ancestor->{$geno_id}) ) {

        my $prev_nb_ancestor = $prev_nb_ancestor_href->{$geno_id};
        print "$geno_id => " . $genotype2nb_ancestor->{$geno_id} . " - previous number: $prev_nb_ancestor\n";
      }
      else {

        print "$geno_id => " . $genotype2nb_ancestor->{$geno_id} . "\n";
      }
    }
  }
}

exit 0;

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

# make_random_number( -len => 32 );
sub make_random_number {

  my $len = 32;
  my %args = @_;
  if ($args{-len}) { $len = $args{-len}; }
  my @chars2use = (0 .. 9);
  my $randstring = join("", map $chars2use[rand @chars2use], 0 .. $len);
  return $randstring;
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

sub Usage {

  return "
Usage: perl -w $0 --dalbaseurl \"http://url.to/dal\" --workingdir \"/tmp\" --username \"kddartuser\" --password \"secret\" --kddartgroup 1 --solrhost \"http://localhost\" --solrport 8983 --solrcorecsv \"db,monetdb,dal\"

  -h --help              print this help
  --dalbaseurl           kddart dal base url - it should include http or https protocol part
  --workingdir           working directory where this script uses to store temporary files
  --username             kddart username
  --password             password for the kddart username
  --kddartgroupid        kddart group number to which the kddart username belongs
  --solrhost             solr host - it should include http or https protocol part
  --solrport             port to which relevant solr instance is listening
  --solrcorecsv          comma separated string containing solr cores - db,moentdb,dal
  ";
}
