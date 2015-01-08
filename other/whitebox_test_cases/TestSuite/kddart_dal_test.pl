#!/usr/bin/perl -w

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
# Created   : 18/12/2011
# Purpose   : This is a testing framework for the Data Access Layer.

use warnings;

use lib ".";
use Utils;

use XML::Simple;
use DateTime;
use Log::Log4perl qw(get_logger :levels);
use Time::HiRes qw( sleep );

if (scalar(@ARGV) != 2) {

  print "Usage: $0 <type of test: 1|2> <test case (test type 1) | test order file (test type 2)\n";
  exit 1;
}

$ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'} = 0;

print "Test Suite for KDDArT DAL\n";

my $run_type                     = $ARGV[0];
my $test_case_file_or_order_file = $ARGV[1];

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

my @failed_cases;

if ($run_type eq '1') {

  my $test_case_file = $test_case_file_or_order_file;
  $logger->debug("$test_case_file: run");

  print DateTime->now() . " $test_case_file: run\n";

  my $run_status = run_test_case($test_case_file, 1, $logger);

  $logger->debug("Finish test: $test_case_file");

  print DateTime->now() . " $test_case_file: finish\n";

  if ($run_status) {

    print "Test result: 1 FAILED\n";
  }
  else {

    print "Test result: 1 SUCCESSFUL\n";
  }
}
elsif ($run_type eq '2') {

  my $order_file = $test_case_file_or_order_file;

  my $order_file_content = read_file($order_file);

  my @case_files = split("\n", $order_file_content);

  my $num_failed     = 0;
  my $num_successful = 0;

  for my $test_case_file (@case_files) {

    if ($test_case_file =~ /^#/) {

      next;
    }

    $logger->debug("$test_case_file: run");

    print DateTime->now() . " $test_case_file: run\n";

    my $run_status = run_test_case($test_case_file, 1, $logger);

    $logger->debug("Finish test: $test_case_file");

    if ($run_status) {

      push(@failed_cases, $test_case_file);
      ++$num_failed;
    }
    else {

      ++$num_successful;
    }
    sleep(1);
  }

  print "Test result : $num_failed FAILED : $num_successful SUCCESSFUL\n";
  print "Failed cases:\n" . join("\n", @failed_cases) . "\n";
}

