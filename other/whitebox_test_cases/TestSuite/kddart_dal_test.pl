#!/usr/bin/perl -w

# Copyright (c) 2025, Diversity Arrays Technology, All rights reserved.

# Author    : Puthick Hok
# Created   : 18/12/2011
# Modified  :
# Purpose   : This is a testing framework for the Data Access Layer.
#
#

use warnings;
use strict;

use lib ".";
use Utils;

use XML::Simple;
use DateTime;
use Log::Log4perl qw(get_logger :levels);
use Time::HiRes qw( sleep );
use Getopt::Long;
use MCE;
use MCE::Shared;

my $global_stat_href = {};

my $shared_time_stat_href = MCE::Shared->hash();

sub mce_gather {

  return sub {

    my ($test_case, $data) = @_;

    if (defined $global_stat_href->{$test_case}) {

      push(@{$global_stat_href->{$test_case}}, $data);
    }
    else {

      $global_stat_href->{$test_case} = [$data];
    }
  }
}

if (scalar(@ARGV) < 2) {

  print "Usage: $0 <type of test: 1|2> <test case (test type 1) | test order file (test type 2)\n";
  exit 1;
}

my $nb_repetition = 1;
my $nb_concurrent = 1;

$ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'} = 0;

print "Test Suite for KDDArT DAL\n";

my $run_type                     = $ARGV[0];
my $test_case_file_or_order_file = $ARGV[1];

my $optres = GetOptions(
                        "concurrency=i"  => \$nb_concurrent,
                        "repetition=i"   => \$nb_repetition
                       );

my $app = Log::Log4perl::Appender->new(
  "Log::Log4perl::Appender::File",
  utf8     => undef,
  filename => 'log.txt',
  );

my $layout = Log::Log4perl::Layout::PatternLayout->new("[%d] [%H] [%p] [%F{1}:%L] [%M] [%m]%n")
  ;

$app->layout($layout);

my $logger = get_logger();
$logger->level($DEBUG);
$logger->add_appender($app);

tie my @failed_cases, 'MCE::Shared';
tie my $num_failed, 'MCE::Shared', 0;
tie my $num_successful, 'MCE::Shared', 0;

my $mce = MCE->new(
                   chunk_size => 1,
                   max_workers => $nb_concurrent,
                   gather => mce_gather
                   );

my @parallelisation_queue = (0 .. ($nb_concurrent * $nb_repetition) -1);

if ($run_type eq '1') {

  $mce->foreach( \@parallelisation_queue, sub {

    my $process_id = $$;

    my $test_case_file = $test_case_file_or_order_file;
    $logger->debug("PID: $process_id - $test_case_file: run");

    print DateTime->now() . " PID: $process_id - $test_case_file: run\n";

    my $run_status = undef;

    eval {

      $run_status = run_test_case($test_case_file, 1, $logger, $shared_time_stat_href);
    };

    if ( ! (defined $run_status) ) {

      print "PID: $process_id - Test result: 1 FAILED\n";

      MCE->gather($test_case_file, [$process_id, 0]);
    }
    else {

      $logger->debug("PID: $process_id - Finish test: $test_case_file");

      print DateTime->now() . " PID: $process_id - $test_case_file: finish\n";

      if ($run_status) {

        print "PID: $process_id - Test result: 1 FAILED\n";

        MCE->gather($test_case_file, [$process_id, 0]);
      }
      else {

        print "PID: $process_id - Test result: 1 SUCCESSFUL\n";

        MCE->gather($test_case_file, [$process_id, 1]);
      }
    }
  });
}
elsif ($run_type eq '2') {

  my $order_file = $test_case_file_or_order_file;

  my $order_file_content = read_file($order_file);

  my @case_files = split("\n", $order_file_content);

  $mce->foreach( \@parallelisation_queue, sub {

    for my $test_case_file (@case_files) {

      if ($test_case_file =~ /^#/) {

        next;
      }

      my $process_id = $$;

      $logger->debug("$test_case_file: run");

      print DateTime->now() . " $test_case_file: run\n";

      my $run_status = undef;

      $run_status = run_test_case($test_case_file, 1, $logger, $shared_time_stat_href);

      if ( ! (defined $run_status) ) {

        MCE->gather($test_case_file, [$process_id, 0]);

        push(@failed_cases, $test_case_file);
        ++$num_failed;
      }
      else {

        $logger->debug("Finish test: $test_case_file");

        if ($run_status) {

          MCE->gather($test_case_file, [$process_id, 0]);

          push(@failed_cases, $test_case_file);
          ++$num_failed;
        }
        else {

          MCE->gather($test_case_file, [$process_id, 1]);

          ++$num_successful;
        }
      }
    }
  });

  print "Test result : $num_failed FAILED : $num_successful SUCCESSFUL\n";
  print "Failed cases:\n" . join("\n", @failed_cases) . "\n";
}

$logger->debug("--- Concurrency Results ---");
foreach my $test_case (keys(%{$global_stat_href})) {

  my $pid_aref   = $global_stat_href->{$test_case};
  my $nb_failed  = 0;
  my $nb_success = 0;

  $logger->debug("Test Case: $test_case");

  foreach my $stat_aref (@{$pid_aref}) {

    my $pid       = $stat_aref->[0];
    my $status    = $stat_aref->[1];

    my $status_full = '';

    if ($status == 0) {

      $status_full = 'FAILED';
      $nb_failed  += 1;
    }
    else {

      $status_full = 'SUCCESSFUL';
      $nb_success += 1;
    }

    $logger->debug("   PID: $pid - STATUS: $status $status_full");
  }

  my $nb_pid = scalar(@{$pid_aref});

  my $total_test_time = 0.0;
  my $total_dal_time  = 0.0;

  my $counter = 0;
  my $stat_time_aref = $shared_time_stat_href->{$test_case};

  foreach my $time_aref (@{$stat_time_aref}) {

    my $test_time = $time_aref->[1];
    my $dal_time  = $time_aref->[2];

    $total_test_time += $test_time;
    #$total_dal_time  += $dal_time;

    $counter += 1;
  }

  if ($counter > 0) {

    my $avg_test_time = $total_test_time / $counter;
    my $avg_dal_time  = $total_dal_time / $counter;

    $logger->debug("SUMMARY: $test_case - RUN: $nb_pid - FAILED: $nb_failed - SUCCESSFUL: $nb_success - AVG Test Time: $avg_test_time - AVG DAL Time: $avg_dal_time");
  }
}
