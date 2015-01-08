#!/usr/bin/perl -w

use strict;
use warnings;

use Digest::HMAC_SHA1 qw(hmac_sha1 hmac_sha1_hex);

my $num_arg = scalar(@ARGV);

if ($num_arg != 2) {

  print "Usage: $0 <username> <password>\n";
  exit 1;
}

my $username = $ARGV[0];
my $password = $ARGV[1];

my $hashed_pass = hmac_sha1_hex($username, $password);

print "SHA1 (password as secret, username as text): $hashed_pass\n";
