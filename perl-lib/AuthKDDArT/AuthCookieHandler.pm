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

package AuthKDDArT::AuthCookieHandler;

use strict;
use warnings;
#use lib "/srv/www/perl-lib";

use Apache2::Const qw(:common HTTP_FORBIDDEN);
use Apache2::AuthCookie;
use Apache2::RequestRec;
use Apache2::RequestIO;
use CGI::Session;
use Digest::HMAC_SHA1 qw(hmac_sha1 hmac_sha1_hex);
use vars qw($VERSION @ISA);

$VERSION = substr(q$Revision: 1.2 $, 10);
@ISA = qw(Apache2::AuthCookie);

sub authen_cred ($$\@) {
  my $self = shift;
  my $r = shift;
  my @creds = @_;
  
  $r->log_error($self->cookie_name($r));
  my $cookie = ($r->headers_in->get("Cookie") || "");
  my $session_token = '';
  return $session_token;
}

sub authen_ses_key ($$$) {
  
  my ($self, $r, $cookie) = @_;
  my $user = '';

  $cookie = ($r->headers_in->get("Cookie") || "");
  my $session_id = read_cookie($cookie, 'KDDArT_DOWNLOAD_SESSID');
  
  $r->log_error("FILEAUTH: Cookie: $cookie");

  if (length($session_id) > 0) {

    my $session = new CGI::Session("driver:file", $session_id, {Directory=>'/srv/www/session/kddart'});
    my $username = $session->param('USERNAME');

    if (length($username) > 0) {

      my $rememberme          = $session->param('REMEMBER_ME');
      my $write_token         = $session->param('WRITE_TOKEN');
      my $group_id            = $session->param('GROUP_ID');
      my $user_id             = $session->param('USER_ID');
      my $gadmin_status       = $session->param('GADMIN_STATUS');

      my $sign_key_cookie_name = $self->cookie_name($r);
      my $sign_key             = read_cookie($cookie, $sign_key_cookie_name);

      my $stored_checksum = $session->param('CHECKSUM');

      my $hash_data = "$username";
      $hash_data   .= "$session_id";
      $hash_data   .= "$rememberme";
      $hash_data   .= "$write_token";
      $hash_data   .= "$group_id";
      $hash_data   .= "$user_id";
      $hash_data   .= "$gadmin_status";
  
      my $derived_checksum = hmac_sha1_hex($hash_data, $sign_key);

      $r->log_error("FILEAUTH: Stored checksum ($username) : $stored_checksum");
      $r->log_error("FILEAUTH: Derived checksum ($username): $derived_checksum");

      if ($derived_checksum eq $stored_checksum) {

        $user = $username;
      }

      $r->log_error("FILEAUTH: Username: $username");
      $r->log_error("FILEAUTH: SessionId: $session_id");
    }
  }

  $r->log_error("FILEAUTH: user in authen_ses_key: $user");
  $r->log_error("FILEAUTH: " . $self->cookie_name($r));

  return $user;
}

sub dwarf {
  my $self = shift;
  my $r = shift;

  my $user = $r->user;
}

sub read_cookie
{
  my $HTTP_COOKIE = $_[0];
  my $CK_NAME     = $_[1];
  my @cookieArray = split("; ", $HTTP_COOKIE);
  my $wanted_cookie = '';
  my ($cookie_name, $cookie_value);
  foreach (@cookieArray)
  {
    ($cookie_name, $cookie_value) = split("=", $_);
    if ($cookie_name eq $CK_NAME) 
    { 
      $wanted_cookie = $cookie_value;
      last;
    }
  }
  return $wanted_cookie;
}


1;
