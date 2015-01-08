#!/usr/bin/perl -w

# Author:   Puthick Hok, Grzegorz Uszynski
# Purpose:  Test DAL installation or user access
# Usage:    dal_access_test.pl <dal_url> <username> <password> <groupid>

use strict;
use warnings;
use lib ".";

use LWP::UserAgent;
use HTTP::Request::Common qw(POST GET);
use HTTP::Cookies;
use Time::HiRes qw( tv_interval gettimeofday );

use Digest::HMAC_SHA1 qw(hmac_sha1 hmac_sha1_hex);
use String::Escape qw( backslash );

# --------------------------------------------------

$ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'} = 0;

my $browser  = LWP::UserAgent->new();

#$browser->default_header('Accept' => 'application/json');

my $cookie_jar = HTTP::Cookies->new(
                        file => './lwp_cookies.dat',
                        autosave => 1,
                          );

$browser->cookie_jar($cookie_jar);

my $dalurl         = $ARGV[0];
my $username       = $ARGV[1];
my $plain_pass     = $ARGV[2];
my $groupid        = $ARGV[3];

my $url            = $dalurl . "/login/${username}/no" ;
my $hash_pass      = hmac_sha1_hex($username, $plain_pass);

print 'Plain pass: ' . $plain_pass . "\n";
print "Hash pass: $hash_pass\n";
print "Full login url: $url\n";

# Login process
my @numbers        = (0 .. 9);
my $rand           = join("", map $numbers[rand @numbers], 0 .. 12);
my $session_pass   = hmac_sha1_hex($rand, $hash_pass);
my $signature      = hmac_sha1_hex($url, $session_pass);

my $start_time = [gettimeofday()];

my $auth_req_res = POST($url,
                        [
                          rand_num      => "$rand",
                          url           => "$url",
                          signature     => "$signature",
                        ]);

my $auth_response = $browser->request($auth_req_res);

print "Code: " . $auth_response->code() . "\n";

if ($auth_response->is_success) {

  print "Status line: " . $auth_response->status_line . "\n";
  print "Successful login\n";
  
} else {

  print "Status line: " . $auth_response->status_line . "\n";
  die "Status msg: " . $auth_response->content() . "\n";
  
}

my $write_token_xml = $auth_response->content();
print "Login result: $write_token_xml\n";

my $auth_req_elapsed = tv_interval($start_time);
print "Authentication request elapsed time: $auth_req_elapsed\n\n";

# switch group
my $sg_url        = $dalurl . "/switch/group/$groupid" ;
my $sg_req        = GET($sg_url);
my $sg_response   = $browser->request($sg_req);
print "Result of switch group: " . $sg_response->content() . "\n\n";

# check dal version
my $dv_url        = $dalurl . "/get/version" ;
my $dv_req        = GET($dv_url);
my $dv_response   = $browser->request($dv_req);
print "DAL version: " . $dv_response->content() . "\n\n";


# logout
my $logout_url        = $dalurl . "/logout" ;
my $logout_req        = GET($logout_url);
my $logout_response   = $browser->request($logout_req);
print "Result of logout: " . $logout_response->content() . "\n\n";

unlink 'lwp_cookies.dat';
