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
# Purpose   : This is part of the testing framework for the Data Access Layer.
#             This script is for removing records added in kddart_dal_test.pl.

use warnings;
use strict;

use lib ".";
use Utils;

use XML::Simple;
use DateTime;
use Log::Log4perl qw(get_logger :levels);
use Time::HiRes qw (sleep);

if (scalar(@ARGV) != 3) {

  print "Usage: $0 <switch group case> <type of test: 1|2> <test case (test type 1) | test order file (test type 2)\n";
  exit 1;
}

$ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'} = 0;

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

my $login_case_file         = $ARGV[0];
my $test_type               = $ARGV[1];
my $case_file_or_order_file = $ARGV[2];

print "Remove test data from KDDArT DAL\n";

my $login_err = run_test_case($login_case_file, 0, $logger);

if ($login_err) {

  print "Login failed\n";
  exit 1;
}

my $i = 0;

my $case_without_dependent_old_aref = [];

my $num_failed     = 0;
my $num_successful = 0;

my $test_order_file_content = '';

if ($test_type eq '1') {

  $test_order_file_content .= "$case_file_or_order_file";
}
elsif ($test_type eq '2') {

  $test_order_file_content = read_file($case_file_or_order_file);
}

while(1) {

  my $case_without_dependent_new_aref = who_has_no_dependent($test_order_file_content);

  if (scalar(@{$case_without_dependent_new_aref}) == 0) {

    #print "Empty list\n";
    last;
  }
  else {

    if (is_the_same($case_without_dependent_old_aref, $case_without_dependent_new_aref)) {

      #print "The same list\n";
      last;
    }
  }

  for my $case2delete_file (@{$case_without_dependent_new_aref}) {

    my $delete_status = delete_test_record($case2delete_file);

    if ($delete_status) {

      ++$num_failed;
      print "Case $case2delete_file: problem deleting the test record\n";
    }
    else {

      ++$num_successful;
    }

    sleep(1);
  }

  $case_without_dependent_old_aref = $case_without_dependent_new_aref;

  ++$i;

  #print "Iteration number: $i\n";
}

print "Test result: $num_failed FAILED : $num_successful SUCCESSFUL\n";
