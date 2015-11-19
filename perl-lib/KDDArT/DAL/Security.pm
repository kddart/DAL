#$Id: Security.pm 924 2015-06-05 08:05:21Z puthick $
#$Author: puthick $

# Copyright (c) 2015, Diversity Arrays Technology

# Author    : Puthick Hok
# Created   : 02/06/2010

=head1 FORMER NAME

The entire code of this package was copied from CGI::Application::Plugin::Authentication.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2005, SiteSuite. All rights reserved.

This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

=cut

package KDDArT::DAL::Security;

use 5.006;
use strict;
use warnings;

our $VERSION = '0.17';

our %__CONFIG;

BEGIN {
  use File::Spec;

  my ($volume, $current_dir, $file) = File::Spec->splitpath(__FILE__);

  my @current_dir_part = split('/perl-lib/KDDArT/DAL/', $current_dir);
  $main::kddart_base_dir = $current_dir_part[0];
}

use lib "$main::kddart_base_dir/perl-lib";

use Class::ISA ();
use Scalar::Util ();
use UNIVERSAL::require;
use Carp;
use CGI ();
use Log::Log4perl qw(get_logger :levels);
use KDDArT::DAL::Common;
use Digest::HMAC_SHA1 qw(hmac_sha1 hmac_sha1_hex);
use Crypt::Random qw( makerandom );
use DateTime;
use Digest::MD5;

sub import {
  my $pkg     = shift;
  my $callpkg = caller;
  {
    no strict qw(refs);
    *{$callpkg.'::authen'} = \&KDDArT::DAL::_::Security::authen;
  }
  if ( ! UNIVERSAL::isa($callpkg, 'CGI::Application') ) {
    warn "Calling package is not a CGI::Application module so not setting up the prerun hook.  If you are using \@ISA instead of 'use base', make sure it is in a BEGIN { } block, and make sure these statements appear before the plugin is loaded";
  } elsif ( ! UNIVERSAL::can($callpkg, 'add_callback')) {
    warn "You are using an older version of CGI::Application that does not support callbacks, so the prerun method can not be registered automatically (Lookup the prerun_callback method in the docs for more info)";
  } else {
    $callpkg->add_callback( prerun => \&prerun_callback );
  }
}


use Attribute::Handlers;
my %RUNMODES;

sub CGI::Application::RequireAuthentication : ATTR(CODE) {
  my ( $package, $symbol, $referent, $attr, $data, $phase ) = @_;
  $RUNMODES{$referent} = $data || 1;
}
sub CGI::Application::Authen : ATTR(CODE) {
  my ( $package, $symbol, $referent, $attr, $data, $phase ) = @_;
  $RUNMODES{$referent} = $data || 1;
}


{ package # Hide from PAUSE
      KDDArT::DAL::_::Security;

  ##############################################
  ###
  ###   authen
  ###
  ##############################################
  #
  # Return an authen object that can be used
  # for managing authentication.
  #
  # This will return a class name if called
  # as a class name, and a singleton object
  # if called as an object method
  #
  sub authen {
    my $cgiapp = shift;
    
    if (ref($cgiapp)) {
      return KDDArT::DAL::Security->instance($cgiapp);
    } else {
      return 'KDDArT::DAL::Security';
    }
  }
}

package KDDArT::DAL::Security;

sub config {
  my $self  = shift;
  my $class = ref $self ? ref $self : $self;
  
  die "Calling config after the Authentication object has already been initialized"
      if ref $self && defined $self->{initialized};

  my $config = $self->_config;
  
  if (@_) {
    my $props;
    if ( ref( $_[0] ) eq 'HASH' ) {
      my $rthash = %{ $_[0] };
      $props = CGI::Application->_cap_hash( $_[0] );
    } else {
      $props = CGI::Application->_cap_hash( {@_} );
    }
    
    # Check for STORE
    if ( defined $props->{STORE} ) {
      croak "authen config error:  parameter STORE is not a string or arrayref"
          if ref $props->{STORE} && Scalar::Util::reftype( $props->{STORE} ) ne 'ARRAY';
      $config->{STORE} = delete $props->{STORE};
      # We will accept a string, but what we really want is an arrayref of the store driver,
      # and any custom options
      no warnings qw(uninitialized);
      $config->{STORE} = [ $config->{STORE} ] if Scalar::Util::reftype( $config->{STORE} ) ne 'ARRAY';
    }

    # Check for LOGIN_RUNMODE
    if ( defined $props->{LOGIN_RUNMODE} ) {
      croak "authen config error:  parameter LOGIN_RUNMODE is not a string"
          if ref $props->{LOGIN_RUNMODE};
      $config->{LOGIN_RUNMODE} = delete $props->{LOGIN_RUNMODE};
    }
    
    # Check for LOGIN_URL
    if ( defined $props->{LOGIN_URL} ) {
      carp "authen config warning:  parameter LOGIN_URL ignored since we already have LOGIN_RUNMODE"
          if $config->{LOGIN_RUNMODE};
      croak "authen config error:  parameter LOGIN_URL is not a string"
          if ref $props->{LOGIN_URL};
      $config->{LOGIN_URL} = delete $props->{LOGIN_URL};
    }

    # Check for ALREADY_LOGIN_RUNMODE
    if ( defined $props->{ALREADY_LOGIN_RUNMODE} ) {
      croak "authen config error:  parameter ALREADY_LOGIN_RUNMODE is not a string"
          if ref $props->{ALREADY_LOGIN_RUNMODE};
      $config->{ALREADY_LOGIN_RUNMODE} = delete $props->{ALREADY_LOGIN_RUNMODE};
    }
    
    # Check for ALREADY_LOGIN_URL
    if ( defined $props->{ALREADY_LOGIN_URL} ) {
      carp "authen config warning:  parameter ALREADY_LOGIN_URL ignored since we already have ALREADY_LOGIN_RUNMODE"
          if $config->{ALREADY_LOGIN_RUNMODE};
      croak "authen config error:  parameter ALREADY_LOGIN_URL is not a string"
          if ref $props->{ALREADY_LOGIN_URL};
      $config->{ALREADY_LOGIN_URL} = delete $props->{ALREADY_LOGIN_URL};
    }

    # Check for LOGOUT_RUNMODE
    if ( defined $props->{LOGOUT_RUNMODE} ) {
      croak "authen config error:  parameter LOGOUT_RUNMODE is not a string"
          if ref $props->{LOGOUT_RUNMODE};
      $config->{LOGOUT_RUNMODE} = delete $props->{LOGOUT_RUNMODE};
    }
    
    # Check for LOGOUT_URL
    if ( defined $props->{LOGOUT_URL} ) {
      carp "authen config warning:  parameter LOGOUT_URL ignored since we already have LOGOUT_RUNMODE"
          if $config->{LOGOUT_RUNMODE};
      croak "authen config error:  parameter LOGOUT_URL is not a string"
          if ref $props->{LOGOUT_URL};
      $config->{LOGOUT_URL} = delete $props->{LOGOUT_URL};
    }
    
    # Check for LOGIN_SESSION_TIMEOUT
    if ( defined $props->{LOGIN_SESSION_TIMEOUT} ) {
      croak "authen config error:  parameter LOGIN_SESSION_TIMEOUT is not a string or a hashref"
          if ref $props->{LOGIN_SESSION_TIMEOUT} && ref$props->{LOGIN_SESSION_TIMEOUT} ne 'HASH';
      my $options = {};
      if (! ref $props->{LOGIN_SESSION_TIMEOUT}) {
        $options->{IDLE_FOR} = _time_to_seconds( $props->{LOGIN_SESSION_TIMEOUT} );
        croak "authen config error: parameter LOGIN_SESSION_TIMEOUT is not a valid time string" unless defined $options->{IDLE_FOR};
      } else {
        if ($props->{LOGIN_SESSION_TIMEOUT}->{IDLE_FOR}) {
          $options->{IDLE_FOR} = _time_to_seconds( delete $props->{LOGIN_SESSION_TIMEOUT}->{IDLE_FOR} );
          croak "authen config error: IDLE_FOR option to LOGIN_SESSION_TIMEOUT is not a valid time string" unless defined $options->{IDLE_FOR};
        }
        if ($props->{LOGIN_SESSION_TIMEOUT}->{EVERY}) {
                    $options->{EVERY} = _time_to_seconds( delete $props->{LOGIN_SESSION_TIMEOUT}->{EVERY} );
                    croak "authen config error: EVERY option to LOGIN_SESSION_TIMEOUT is not a valid time string" unless defined $options->{EVERY};
        }
        if ($props->{LOGIN_SESSION_TIMEOUT}->{CUSTOM}) {
          $options->{CUSTOM} = delete $props->{LOGIN_SESSION_TIMEOUT}->{CUSTOM};
          croak "authen config error: CUSTOM option to LOGIN_SESSION_TIMEOUT must be a code reference" unless ref $options->{CUSTOM} eq 'CODE';
        }
        croak "authen config error: Invalid option(s) (" . join( ', ', keys %{$props->{LOGIN_SESSION_TIMEOUT}} ) . ") passed to LOGIN_SESSION_TIMEOUT" if %{$props->{LOGIN_SESSION_TIMEOUT}};
      }
      
      $config->{LOGIN_SESSION_TIMEOUT} = $options;
      delete $props->{LOGIN_SESSION_TIMEOUT};
    }

    # check session counter
    if ( defined $props->{SESSION_COUNTER} ) {

      my $options = {};
      $options->{NUM_OF_REQUEST} = $props->{SESSION_COUNTER}->{NUM_OF_REQUEST};
      $options->{INTERVAL}       = _time_to_seconds($props->{SESSION_COUNTER}->{INTERVAL});
      $options->{DELAY}          = _time_to_seconds($props->{SESSION_COUNTER}->{DELAY});

      $config->{SESSION_COUNTER} = $options;
      delete $props->{SESSION_COUNTER};
    }

    # check ip address counter
    if ( defined $props->{IP_ADDR_COUNTER} ) {

      my $options = {};
      $options->{NUM_OF_REQUEST} = $props->{IP_ADDR_COUNTER}->{NUM_OF_REQUEST};
      $options->{INTERVAL}       = _time_to_seconds($props->{IP_ADDR_COUNTER}->{INTERVAL});
      $options->{DELAY}          = _time_to_seconds($props->{IP_ADDR_COUNTER}->{DELAY});

      $config->{IP_ADDR_COUNTER} = $options;
      delete $props->{IP_ADDR_COUNTER};
    }

    # check login counter
    if ( defined $props->{LOGIN_COUNTER} ) {

      my $options = {};
      $options->{NUM_OF_REQUEST} = $props->{LOGIN_COUNTER}->{NUM_OF_REQUEST};
      $options->{INTERVAL}       = _time_to_seconds($props->{LOGIN_COUNTER}->{INTERVAL});
      $options->{DELAY}          = _time_to_seconds($props->{LOGIN_COUNTER}->{DELAY});

      $config->{LOGIN_COUNTER} = $options;
      delete $props->{LOGIN_COUNTER};
    }

    # Check for POST_LOGIN_CALLBACK
    if ( defined $props->{POST_LOGIN_CALLBACK} ) {
      croak "authen config error:  parameter POST_LOGIN_CALLBACK is not a coderef"
          unless( ref $props->{POST_LOGIN_CALLBACK} eq 'CODE' );
      $config->{POST_LOGIN_CALLBACK} = delete $props->{POST_LOGIN_CALLBACK};
    }

    # If there are still entries left in $props then they are invalid
    croak "Invalid option(s) (" . join( ', ', keys %$props ) . ") passed to config" if %$props;
  }
}

sub check_login_runmodes {

  my $self   = shift;
  my $config = $self->_config;

  if (@_) {

    $config->{LOGIN_RUNMODES} = [];
    push(@{$config->{LOGIN_RUNMODES}}, @_);
  }
  else {

    $config->{LOGIN_RUNMODES} ||= [];
  }
  
  return @{$config->{LOGIN_RUNMODES}};
}

sub check_content_type_runmodes {

  my $self   = shift;
  my $config = $self->_config;

  if (@_) {

    $config->{CONTENT_TYPE_RUNMODES} = [];
    push(@{$config->{CONTENT_TYPE_RUNMODES}}, @_);
  }
  else {

    $config->{CONTENT_TYPE_RUNMODES} ||= [];
  }
  
  return @{$config->{CONTENT_TYPE_RUNMODES}};
}


sub check_rand_runmodes {
  
  my $self   = shift;
  my $config = $self->_config;

  if (@_) {

    $config->{RAND_RUNMODES} = [];
    push(@{$config->{RAND_RUNMODES}}, @_);
  }
  else {

    $config->{RAND_RUNMODES} ||= [];
  }
  
  return @{$config->{RAND_RUNMODES}};
}

sub check_sign_upload_runmodes {
  
  my $self   = shift;
  my $config = $self->_config;
  
  if (@_) {

    $config->{SIGN_UPLOAD_RUNMODES} = [];
    push(@{$config->{SIGN_UPLOAD_RUNMODES}}, @_);
  }
  else {

    $config->{SIGN_UPLOAD_RUNMODES} ||= [];
  }
  
  return @{$config->{SIGN_UPLOAD_RUNMODES}};
}

sub check_signature_runmodes {
    
  my $self   = shift;
  my $config = $self->_config;
  
  if (@_) {

    $config->{SIGNATURE_RUNMODES} = [];
    push(@{$config->{SIGNATURE_RUNMODES}}, @_);
  }
  else {

    $config->{SIGNATURE_RUNMODES} ||= [];
  }

  return @{$config->{SIGNATURE_RUNMODES}};
}

sub check_active_login_runmodes {

  my $self   = shift;
  my $config = $self->_config;

  if (@_) {

    $config->{ACTIVE_LOGIN_RUNMODES} = [];
    push(@{$config->{ACTIVE_LOGIN_RUNMODES}}, @_);
  }
  else {

    $config->{ACTIVE_LOGIN_RUNMODES} ||= [];
  }
  
  return @{$config->{ACTIVE_LOGIN_RUNMODES}};
}

sub ignore_group_assignment_runmodes {

  my $self   = shift;
  my $config = $self->_config;
  
  if (@_) {

    $config->{IGNORE_GROUP_ASSIGNMENT} = [];
    push(@{$config->{IGNORE_GROUP_ASSIGNMENT}}, @_);
  }
  else {

    $config->{IGNORE_GROUP_ASSIGNMENT} ||= [];
  }
  
  return @{$config->{IGNORE_GROUP_ASSIGNMENT}};
}

sub ignore_ctrl_char_checking_runmodes {

  my $self   = shift;
  my $config = $self->_config;
  
  if (@_) {

    $config->{IGNORE_CTRL_CHAR_CHECKING} = [];
    push(@{$config->{IGNORE_CTRL_CHAR_CHECKING}}, @_);
  }
  else {

    $config->{IGNORE_CTRL_CHAR_CHECKING} ||= [];
  }
  
  return @{$config->{IGNORE_CTRL_CHAR_CHECKING}};
}

sub count_session_request_runmodes {

  my $self   = shift;
  my $config = $self->_config;
  
  if (@_) {

    $config->{SESSION_COUNTER_RUNMODES} = [];
    push(@{$config->{SESSION_COUNTER_RUNMODES}}, @_);
  }
  else {

    $config->{SESSION_COUNTER_RUNMODES} ||= [];
  }
  
  return @{$config->{SESSION_COUNTER_RUNMODES}};
}

sub check_gadmin_runmodes {

  my $self   = shift;
  my $config = $self->_config;
  
  if (@_) {

    $config->{CHECK_GADMIN_RUNMODES} = [];
    push(@{$config->{CHECK_GADMIN_RUNMODES}}, @_);
  }
  else {

    $config->{CHECK_GADMIN_RUNMODES} ||= [];
  }
  
  return @{$config->{CHECK_GADMIN_RUNMODES}};
}

sub transform_xml_error_message {

  my $self   = $_[0];
  my $para   = $_[1];

  my $config = $self->_config;

  if (defined $para) {

    $config->{TRANSFORM_ERROR_MESSAGE} = $para;
  }
  else {

    $config->{TRANSFORM_ERROR_MESSAGE} ||= '';
  }

  return $config->{TRANSFORM_ERROR_MESSAGE};
}

sub xsl_url {

  my $self   = $_[0];
  my $para   = $_[1];

  my $config = $self->_config;

  if (defined $para) {

    $config->{XSL_URL} = $para;
  }
  else {

    $config->{XSL_URL} ||= '';
  }

  return $config->{XSL_URL};
}

sub init_config_parameters {

  my $self   = shift;
  my $config = $self->_config;

  $self->check_login_runmodes('');
  $self->check_rand_runmodes('');
  $self->check_sign_upload_runmodes('');
  $self->check_signature_runmodes('');
  $self->check_active_login_runmodes('');
  $self->ignore_group_assignment_runmodes('');
  $self->ignore_ctrl_char_checking_runmodes('');
  $self->count_session_request_runmodes('');
  $self->check_gadmin_runmodes('');
  $self->transform_xml_error_message('');
  $self->check_content_type_runmodes('');
  $self->xsl_url('');
}

sub is_login_runmode {
  my $self = shift;
  my $runmode = shift;
  
  foreach my $runmode_test ($self->check_login_runmodes) {
    if (overload::StrVal($runmode_test) =~ /^Regexp=/) {
      # We were passed a regular expression
      return 1 if $runmode =~ $runmode_test;
    } elsif (ref $runmode_test && ref $runmode_test eq 'CODE') {
      # We were passed a code reference
      return 1 if $runmode_test->($runmode);
    } elsif ($runmode_test eq ':all') {
      # all runmodes are protected
      return 1;
    } else {
      # assume we were passed a string
      return 1 if $runmode eq $runmode_test;
    }
  }
  
  # See if the user is using attributes
  my $sub = $self->_cgiapp->can($runmode);
  return 1 if $sub && $RUNMODES{$sub};
  
  return;
}

sub is_content_type_runmode {
  my $self = shift;
  my $runmode = shift;
  
  foreach my $runmode_test ($self->check_content_type_runmodes) {
    if (overload::StrVal($runmode_test) =~ /^Regexp=/) {
      # We were passed a regular expression
      return 1 if $runmode =~ $runmode_test;
    } elsif (ref $runmode_test && ref $runmode_test eq 'CODE') {
      # We were passed a code reference
      return 1 if $runmode_test->($runmode);
    } elsif ($runmode_test eq ':all') {
      # all runmodes are protected
      return 1;
    } else {
      # assume we were passed a string
      return 1 if $runmode eq $runmode_test;
    }
  }
  
  # See if the user is using attributes
  my $sub = $self->_cgiapp->can($runmode);
  return 1 if $sub && $RUNMODES{$sub};
  
  return;
}

sub is_rand_runmode {
  
  my $self    = shift;
  my $runmode = shift;
  
  foreach my $runmode_test ($self->check_rand_runmodes) {
    
    if (overload::StrVal($runmode_test) =~ /^Regexp=/) {
      # We were passed a regular expression
      return 1 if $runmode =~ $runmode_test;
    } elsif (ref $runmode_test && ref $runmode_test eq 'CODE') {
      # We were passed a code reference
      return 1 if $runmode_test->($runmode);
    } elsif ($runmode_test eq ':all') {
      # all runmodes are protected
      return 1;
    } else {
      # assume we were passed a string
      return 1 if $runmode eq $runmode_test;
    }
  }
  
  # See if the user is using attributes
  my $sub = $self->_cgiapp->can($runmode);
  return 1 if $sub && $RUNMODES{$sub};
  
  return;
}

sub is_sign_upload_runmode {
  
  my $self    = shift;
  my $runmode = shift;
  
  foreach my $runmode_test ($self->check_sign_upload_runmodes) {
    
    if (overload::StrVal($runmode_test) =~ /^Regexp=/) {
      # We were passed a regular expression
      return 1 if $runmode =~ $runmode_test;
    } elsif (ref $runmode_test && ref $runmode_test eq 'CODE') {
      # We were passed a code reference
      return 1 if $runmode_test->($runmode);
    } elsif ($runmode_test eq ':all') {
      # all runmodes are protected
      return 1;
    } else {
      # assume we were passed a string
      return 1 if $runmode eq $runmode_test;
    }
  }
  
  # See if the user is using attributes
  my $sub = $self->_cgiapp->can($runmode);
  return 1 if $sub && $RUNMODES{$sub};

  return;
}

sub is_signature_runmode {
  
  my $self    = shift;
  my $runmode = shift;
  
  foreach my $runmode_test ($self->check_signature_runmodes) {
    
    if (overload::StrVal($runmode_test) =~ /^Regexp=/) {
      # We were passed a regular expression
      return 1 if $runmode =~ $runmode_test;
    } elsif (ref $runmode_test && ref $runmode_test eq 'CODE') {
      # We were passed a code reference
      return 1 if $runmode_test->($runmode);
    } elsif ($runmode_test eq ':all') {
      # all runmodes are protected
      return 1;
    } else {
      # assume we were passed a string
      return 1 if $runmode eq $runmode_test;
    }
  }
  
  # See if the user is using attributes
  my $sub = $self->_cgiapp->can($runmode);
  return 1 if $sub && $RUNMODES{$sub};

  return;
}

sub is_active_login_runmode {

  my $self    = shift;
  my $runmode = shift;
  
  foreach my $runmode_test ($self->check_active_login_runmodes) {
    
    if (overload::StrVal($runmode_test) =~ /^Regexp=/) {
      # We were passed a regular expression
      return 1 if $runmode =~ $runmode_test;
    } elsif (ref $runmode_test && ref $runmode_test eq 'CODE') {
      # We were passed a code reference
      return 1 if $runmode_test->($runmode);
    } elsif ($runmode_test eq ':all') {
      # all runmodes are protected
      return 1;
    } else {
      # assume we were passed a string
      return 1 if $runmode eq $runmode_test;
    }
  }
  
  # See if the user is using attributes
  my $sub = $self->_cgiapp->can($runmode);
  return 1 if $sub && $RUNMODES{$sub};

  return;
}

sub is_ignore_group_assignment_runmode {

  my $self    = shift;
  my $runmode = shift;
  
  foreach my $runmode_test ($self->ignore_group_assignment_runmodes) {
    
    if (overload::StrVal($runmode_test) =~ /^Regexp=/) {
      # We were passed a regular expression
      return 1 if $runmode =~ $runmode_test;
    } elsif (ref $runmode_test && ref $runmode_test eq 'CODE') {
      # We were passed a code reference
      return 1 if $runmode_test->($runmode);
    } elsif ($runmode_test eq ':all') {
      # all runmodes are protected
      return 1;
    } else {
      # assume we were passed a string
      return 1 if $runmode eq $runmode_test;
    }
  }
  
  # See if the user is using attributes
  my $sub = $self->_cgiapp->can($runmode);
  return 1 if $sub && $RUNMODES{$sub};

  return;
}

sub is_ignore_ctrl_char_checking_runmode {

  my $self    = shift;
  my $runmode = shift;
  
  foreach my $runmode_test ($self->ignore_ctrl_char_checking_runmodes) {
    
    if (overload::StrVal($runmode_test) =~ /^Regexp=/) {
      # We were passed a regular expression
      return 1 if $runmode =~ $runmode_test;
    } elsif (ref $runmode_test && ref $runmode_test eq 'CODE') {
      # We were passed a code reference
      return 1 if $runmode_test->($runmode);
    } elsif ($runmode_test eq ':all') {
      # all runmodes are protected
      return 1;
    } else {
      # assume we were passed a string
      return 1 if $runmode eq $runmode_test;
    }
  }
  
  # See if the user is using attributes
  my $sub = $self->_cgiapp->can($runmode);
  return 1 if $sub && $RUNMODES{$sub};

  return;
}

sub is_session_counter_runmode {

  my $self    = shift;
  my $runmode = shift;
  
  foreach my $runmode_test ($self->count_session_request_runmodes) {
    
    if (overload::StrVal($runmode_test) =~ /^Regexp=/) {
      # We were passed a regular expression
      return 1 if $runmode =~ $runmode_test;
    } elsif (ref $runmode_test && ref $runmode_test eq 'CODE') {
      # We were passed a code reference
      return 1 if $runmode_test->($runmode);
    } elsif ($runmode_test eq ':all') {
      # all runmodes are protected
      return 1;
    } else {
      # assume we were passed a string
      return 1 if $runmode eq $runmode_test;
    }
  }
  
  # See if the user is using attributes
  my $sub = $self->_cgiapp->can($runmode);
  return 1 if $sub && $RUNMODES{$sub};

  return;
}

sub is_gadmin_runmode {

  my $self    = shift;
  my $runmode = shift;
  
  foreach my $runmode_test ($self->check_gadmin_runmodes) {
    
    if (overload::StrVal($runmode_test) =~ /^Regexp=/) {
      # We were passed a regular expression
      return 1 if $runmode =~ $runmode_test;
    } elsif (ref $runmode_test && ref $runmode_test eq 'CODE') {
      # We were passed a code reference
      return 1 if $runmode_test->($runmode);
    } elsif ($runmode_test eq ':all') {
      # all runmodes are protected
      return 1;
    } else {
      # assume we were passed a string
      return 1 if $runmode eq $runmode_test;
    }
  }
  
  # See if the user is using attributes
  my $sub = $self->_cgiapp->can($runmode);
  return 1 if $sub && $RUNMODES{$sub};

  return;
}


sub setup_runmodes {
  my $self   = shift;
  my $config = $self->_config;
  
  $self->_cgiapp->run_modes( login_error => \&login_error_runmode )
      unless $config->{LOGIN_RUNMODE} || $config->{LOGIN_URL};
  
  $self->_cgiapp->run_modes( authen_logout => \&logout_runmode )
      unless $config->{LOGOUT_RUNMODE} || $config->{LOGOUT_URL};
  
  $self->_cgiapp->run_modes( do_nothing               => \&do_nothing_runmode );
  $self->_cgiapp->run_modes( rand_error               => \&rand_error_runmode );
  $self->_cgiapp->run_modes( signature_error          => \&signature_error_runmode );
  $self->_cgiapp->run_modes( upload_2large_error      => \&upload_2large_error_runmode );
  $self->_cgiapp->run_modes( already_login            => \&already_login_runmode );
  $self->_cgiapp->run_modes( over_session_quota       => \&over_session_quota_runmode );
  $self->_cgiapp->run_modes( defer_request            => \&defer_request_runmode );
  $self->_cgiapp->run_modes( require_group_assignment => \&require_group_assignment_runmode );
  $self->_cgiapp->run_modes( require_gadmin           => \&require_gadmin_runmode );
  $self->_cgiapp->run_modes( ctrl_char_not_allowed    => \&ctrl_char_not_allowed_runmode );
  $self->_cgiapp->run_modes( content_type_not_allowed => \&content_type_not_allowed_runmode );
  
  return;
}

sub last_login {
  my $self = shift;
  my $new  = shift;
  $self->initialize;
  
  return unless $self->username;
  my $old = $self->store->fetch('last_login');
  $self->store->save('last_login' => $new) if $new;
  return $old;
}

sub last_access {
  my $self = shift;
  my $new  = shift;
  $self->initialize;
  
  return unless $self->username;
  my $old = $self->store->fetch('last_access');
  $self->store->save('last_access' => $new) if $new;
  return $old;
}

sub is_login_timeout {
  my $self = shift;
  $self->initialize;
  
  return $self->{is_login_timeout} ? 1 : 0;
}

sub is_authenticated {
  my $self = shift;
  $self->initialize;
  
  return $self->username ? 1 : 0;
}

sub login_attempts {
  my $self = shift;
  $self->initialize;
  
  my $la = $self->store->fetch('login_attempts');
  return $la;
}

sub remember_me {
  
  my $self = shift;
  $self->initialize;
  
  my $rememberme = $self->store->fetch('remember_me');
  
  if ( $self->_verify_session_checksum ) {
    
    return $rememberme;
  }
  else {
    
    return '';
  }
}

sub username {
  my $self = shift;
  $self->initialize;
  
  my $u = $self->store->fetch('username');

  #$self->logger->debug("Retrieving the username");

  if ( $self->_verify_session_checksum ) {
    
    return $u;
  }
  else {
    
    return '';
  }
}

sub group_id {

  my $self = shift;
  $self->initialize;
  
  my $g = $self->store->fetch('group_id');
  
  if ( $self->_verify_session_checksum ) {
    
    return $g;
  }
  else {
    
    return '';
  }
}

sub gadmin_status {

  my $self = shift;
  $self->initialize;
  
  my $gadmin = $self->store->fetch('gadmin_status');
  
  if ( $self->_verify_session_checksum ) {
    
    if ($gadmin eq '1') {

      return '1';
    }
    else {

      return '';
    }
  }
  else {
    
    return '';
  }
}

sub user_id {

  my $self = shift;
  $self->initialize;
  
  my $uid = $self->store->fetch('user_id');
  
  if ( $self->_verify_session_checksum ) {
    
    return $uid;
  }
  else {
    
    return '';
  }
}

sub groupname {

  my $self = shift;
  $self->initialize;
  
  my $gname = $self->store->fetch('GROUPNAME');
  
  return $gname;
}

sub is_no_group {

  my $self = shift;

  if ( $self->group_id eq '-99') {

    return 1;
  }
  else {

    return 0;
  }
}

sub write_token {
  
  my $self = shift;
  $self->initialize;
  
  my $wt = $self->store->fetch('write_token');
  
  if ( $self->_verify_session_checksum ) {
    
    return $wt;
  }
  else {
    
    return '';
  }
}

sub is_extra_data {

  my $self = shift;

  my $extra_data = $self->store->fetch('EXTRA_DATA');

  if ( $extra_data eq '1' ) {

    return 1;
  }
  else {

    return 0;
  }
}

sub logout {

  my $self = shift;
  $self->initialize;

  $self->store->clear;
}

sub store {

  my $self = shift;
  
  if ( !$self->{store} ) {
    my $config = $self->_config;
    
    # Fetch the configuration parameters for the store
    my ($store_module, @store_config);
    ($store_module, @store_config) = @{ $config->{STORE} } if $config->{STORE} && ref $config->{STORE} eq 'ARRAY';
    if (!$store_module) {
      # No STORE configuration was provided
      if ($self->_cgiapp->can('session') && UNIVERSAL::isa($self->_cgiapp->session, 'CGI::Session')) {
        # The user is already using the Session plugin
        ($store_module, @store_config) = ( 'Session' );
      } else {
        # Fall back to the Cookie Store
        ($store_module, @store_config) = ( 'Cookie' );
      }
    }
    
    # Load the the class for this store
    my $store_class = _find_deligate_class(
      'KDDArT::DAL::' . $store_module,
      $store_module
        ) || die "Store $store_module can not be found";
    
    # Create the store object
    $self->{store} = $store_class->new( $self, @store_config )
        || die "Could not create new $store_class object";
  }
  
  return $self->{store};
}

sub initialize {

  my $self = shift;
  return 1 if $self->{initialized};
  
  # It would seem to make more sense to do this at the /end/ of the routine
  # but that causes an infinite loop. 
  $self->{initialized} = 1;
  
  my $config = $self->_config;
  
  # Check the user name last of all because only this check might create a session behind the scenes.
  # In other words if a website works perfectly well without authentication,
  # then adding a protected run mode should not add session to the unprotected modes.
  # See 60_parsimony.t for the test.
  if ($config->{LOGIN_SESSION_TIMEOUT} && $self->username) {
    
    $self->logger->debug("Session time out plus username");
    # This is not a fresh login, and there are time out rules, so make sure the login is still valid
    if ( $config->{LOGIN_SESSION_TIMEOUT}->{IDLE_FOR} && 
         ($self->remember_me ne 'YES') &&
         time() - $self->last_access >= $config->{LOGIN_SESSION_TIMEOUT}->{IDLE_FOR} ) {
      
      # this login has been idle for too long
      $self->logger->debug("Idle for too long");
      $self->{is_login_timeout} = 1;
      $self->logout;
      
    } elsif ( $config->{LOGIN_SESSION_TIMEOUT}->{EVERY} && 
              ($self->remember_me ne 'YES') &&
              time() - $self->last_login >=  $config->{LOGIN_SESSION_TIMEOUT}->{EVERY} ) {
      
      # it has been too long since the last login
      $self->logger->debug("Has been too long since the last login");
      $self->{is_login_timeout} = 1;
      $self->logout;
      
    } elsif ( $config->{LOGIN_SESSION_TIMEOUT}->{CUSTOM} && 
              ($self->remember_me ne 'YES') &&
              $config->{LOGIN_SESSION_TIMEOUT}->{CUSTOM}->($self) ) {
      
      # this login has timed out
      $self->logger->debug("This login has timed out");
      $self->{is_login_timeout} = 1;
      $self->logout;
      
    }
  }
  else {
    
    Log::Log4perl::MDC->put('client_ip', $ENV{'REMOTE_ADDR'});
    $self->logger->debug("Just session time out, no username");
  }
  
  return 1;
}

sub new {

  my $class  = shift;
  my $cgiapp = shift;
  my $self   = {};
  
  bless $self, $class;
  $self->{cgiapp} = $cgiapp;
  Scalar::Util::weaken($self->{cgiapp}); # weaken circular reference
  
  Log::Log4perl::MDC->put('client_ip', $ENV{'REMOTE_ADDR'});
  my $logger = get_logger();
  $logger->level($DEBUG);

  if ( ! $logger->has_appenders() ) {
    my $app = Log::Log4perl::Appender->new(
      "Log::Log4perl::Appender::Screen",
                                          utf8 => undef
        );

    my $layout = Log::Log4perl::Layout::PatternLayout->new("[%d] [%H] [%X{client_ip}] [%p] [%F{1}:%L] [%M] [%m]%n");

    $app->layout($layout);

    $logger->add_appender($app);
  }
  
  $self->{logger} = $logger;
  
  $self->config(
    STORE                  => 'Session',
    LOGIN_SESSION_TIMEOUT  => {
      IDLE_FOR => '45m',
    },
    SESSION_COUNTER        => { NUM_OF_REQUEST => 70000,  INTERVAL => '1s', DELAY => '1s' },
  );

  return $self;
}

sub instance {

  my $class  = shift;
  my $cgiapp = shift;
  die "KDDArT::DAL::Security->instance must be called with a CGI::Application object"
      unless defined $cgiapp && UNIVERSAL::isa( $cgiapp, 'CGI::Application' );
  
  $cgiapp->{__CAP_AUTHENTICATION_INSTANCE} = $class->new($cgiapp) unless defined $cgiapp->{__CAP_AUTHENTICATION_INSTANCE};
  return $cgiapp->{__CAP_AUTHENTICATION_INSTANCE};
}

sub prerun_callback {

  my $self   = shift;
  my $authen = $self->authen;
  
  $authen->initialize;

  #$authen->logger->debug("Prerun callback");
  
  # setup the default login and logout runmodes
  $authen->setup_runmodes;
  
  my $current_runmode = $self->get_current_runmode;
  my $query           = $self->query();
  my $config          = $authen->_config;
  my $rand            = $query->param('rand_num');

  if (!$authen->is_ignore_ctrl_char_checking_runmode($current_runmode)) {

    if ($authen->contain_ctrl_char($query)) {

      return $authen->redirect_to_ctrl_char_error();
    }
  }

  if ($authen->is_content_type_runmode($current_runmode)) {

    if (!$authen->is_content_type_valid()) {

      $self->logger->debug("Not a valid content type.");
      return $authen->redirect_to_content_type_error();
    }
  }

  if ($authen->is_session_counter_runmode($current_runmode)) {

    my $session_limit     = $config->{SESSION_COUNTER}->{NUM_OF_REQUEST};
    my $session_delay     = _time_to_seconds($config->{SESSION_COUNTER}->{DELAY});
    my $session_interval  = _time_to_seconds($config->{SESSION_COUNTER}->{INTERVAL});

    my $total_delay = $session_interval + $session_delay;
    $authen->update_counter($self->session, 'COUNTER', $total_delay);

    $authen->logger->debug("TOTAL DELAY: $total_delay");

    $authen->logger->debug("SESSION_COUNTER_LIMIT: $session_limit");

    if ( $authen->check_counter($self->session, 'COUNTER', $session_limit) ) {

      $authen->logger->debug("After check_counter");
      $authen->update_counter($self->session, 'DEFER_COUNTER', $total_delay);
      
      # This is a condition when the number of requests is double of what is allowed.
      # In this case, don't need to check much, just go to the error message.
      # This is to ensure that minimum computation is consumed.
      if ( $authen->check_counter($self->session, 'DEFER_COUNTER', $session_limit) ) {

        return $authen->redirect_to_over_session_quota();
      }

      if ( !(defined $rand) ) {

        # waiting message
        return $authen->redirect_to_over_session_quota();
      }
      else {

        $authen->logger->debug("Random number present: $rand");
        if ( !$authen->should_rand_be_done($self->session, $rand) ) {

          $authen->update_rand($self->session, $rand, $total_delay);
          
          $authen->logger->debug("$rand is in the deferred mode");
          # this random number has not waited long enough
          # waiting message 

          return $authen->redirect_to_defer_request();
        }
        # for the else clause which says it should be done, nothing
        # need to be done here since signature verification process
        # will take care of update the random number code to zero
        # meaning the random number is complete.
      }
    }
  }

  # Update any time out info
  if ( $config->{LOGIN_SESSION_TIMEOUT} ) {
    # update the last access time
    my $now = time;
    $authen->last_access($now);
  }
  
  if ($authen->is_login_runmode($current_runmode)) {

    # This runmode requires authentication and group selection

    my $env_cookie = $ENV{'HTTP_COOKIE'};

    $self->logger->debug("RECEIVED COOKIES: $env_cookie");

    $self->logger->debug("$current_runmode requires authentication");
    $self->logger->debug(join(' ', @{$authen->_config->{LOGIN_RUNMODES}}));

    if ( !$authen->is_authenticated ) {

      $authen->logger->debug("Not authenticated redirect to login");
      # This user is NOT logged in
      return $authen->redirect_to_login;
    }
    else {

      #$self->logger->debug("Before checking for group assignment");

      if ( $authen->is_no_group ) {

        #$self->logger->debug("Haven't chosen a group yet!");
        
        if ( !$authen->is_ignore_group_assignment_runmode($current_runmode) ) {

          return $authen->redirect_to_group_assignment;
        }
      }
    }
  }

  if ($authen->is_active_login_runmode($current_runmode)) {

    if ($authen->is_authenticated) {

      $self->logger->debug("Already login, should return 420 instead of 200");
      return $authen->redirect_to_already_login;
    }
  }

  # checking for group administrator should be done before checking for random number
  # and signature verification.
  if ($authen->is_gadmin_runmode($current_runmode)) {

    if ($authen->gadmin_status ne '1') {

      return $authen->redirect_to_gadmin_error;
    }
  }
  
  if ($authen->is_rand_runmode($current_runmode)) {
   
    $authen->logger->debug("Check $rand for completion");
    if ( $authen->is_rand_done($self->session, $rand) ) {
      
      return $authen->redirect_to_rand_error;
    }
    else {

      $authen->store->save( $rand => 0 );
    }
  }

  if ($authen->is_sign_upload_runmode($current_runmode)) {
    
    my $success = $authen->check_sign_upload($query, $current_runmode);
    if (!$success) {

      return $authen->redirect_to_sign_upload_error;
    }
    else {

      $authen->store->save( $rand => 0 );
    }
  }

  if ($authen->is_signature_runmode($current_runmode)) {
    
    my $success = $authen->check_signature($query, $current_runmode);
    if (!$success) {

      return $authen->redirect_to_signature_error;
    }
    else {

      $authen->store->save( $rand => 0 );
    }
  }
}

sub redirect_to_login {

  my $self = shift;
  my $cgiapp = $self->_cgiapp;
  my $config = $self->_config;
  
  if ($config->{LOGIN_RUNMODE}) {
    $cgiapp->prerun_mode($config->{LOGIN_RUNMODE});
  } elsif (length($config->{LOGIN_URL}) > 0) {

    my @splitted_uri = split(/$ENV{'SCRIPT_NAME'}\//, $ENV{'REQUEST_URI'});
    my $rest_part = $splitted_uri[-1];
    my $final_login_url = $config->{LOGIN_URL} . "?dest=$rest_part";

    $cgiapp->header_add(-location => $final_login_url);
    $cgiapp->header_type('redirect');
    $cgiapp->prerun_mode('do_nothing');
  } else {
    $cgiapp->prerun_mode('login_error');
  }
}

sub redirect_to_content_type_error {

  my $self   = shift;
  my $cgiapp = $self->_cgiapp;
  
  $cgiapp->prerun_mode('content_type_not_allowed');
}

sub redirect_to_group_assignment {

  my $self   = shift;
  my $cgiapp = $self->_cgiapp;
  
  $cgiapp->prerun_mode('require_group_assignment');
}

sub redirect_to_rand_error {
  
  my $self   = shift;
  my $cgiapp = $self->_cgiapp;
  
  $cgiapp->prerun_mode('rand_error');
}

sub redirect_to_sign_upload_error {
  
  my $self   = shift;
  my $cgiapp = $self->_cgiapp;
  
  $cgiapp->prerun_mode('signature_error');
}

sub redirect_to_signature_error {
  
  my $self   = shift;
  my $cgiapp = $self->_cgiapp;
  
  $cgiapp->prerun_mode('signature_error');
}


sub redirect_to_upload_2large_error {
  
  my $self   = shift;
  my $cgiapp = $self->_cgiapp;
  
  $cgiapp->prerun_mode('upload_2large_error');
}

sub redirect_to_gadmin_error {

  my $self   = shift;
  my $cgiapp = $self->_cgiapp;
  
  $cgiapp->prerun_mode('require_gadmin');
}

sub redirect_to_ctrl_char_error {

  my $self   = shift;
  my $cgiapp = $self->_cgiapp;
  
  $cgiapp->prerun_mode('ctrl_char_not_allowed');
}

sub redirect_to_already_login {

  my $self   = shift;
  my $cgiapp = $self->_cgiapp;
  my $config = $self->_config;
  
  #if ($config->{ALREADY_LOGIN_RUNMODE}) {

  #  $self->logger->debug("ALREADY_LOGIN_RUNMODE");
  #  $cgiapp->prerun_mode($config->{ALREADY_LOGIN_RUNMODE});
  #}
  #elsif ($config->{ALREADY_LOGIN_URL}) {
    
  #  $self->logger->debug("ALREADY_LOGIN_URL");
  #  $cgiapp->header_add(-location => $config->{ALREADY_LOGIN_URL});
  #  $cgiapp->header_type('redirect');
  #  $cgiapp->prerun_mode('do_nothing');
  #}
  #else {
    
    $self->logger->debug("Nothing defined");
    $cgiapp->prerun_mode('already_login');
  #}
}

sub redirect_to_over_session_quota {

  my $self   = shift;
  my $cgiapp = $self->_cgiapp;
  
  $cgiapp->prerun_mode('over_session_quota');
}

sub redirect_to_defer_request {

  my $self   = shift;
  my $cgiapp = $self->_cgiapp;
  
  $cgiapp->prerun_mode('defer_request');
}

sub redirect_to_logout {
  my $self = shift;
  my $cgiapp = $self->_cgiapp;
  my $config = $self->_config;
  $self->logout();
  
  if ($config->{LOGOUT_RUNMODE}) {
    $cgiapp->prerun_mode($config->{LOGOUT_RUNMODE});
  } elsif ($config->{LOGOUT_URL}) {
    $cgiapp->header_add(-location => $config->{LOGOUT_URL});
    $cgiapp->header_type('redirect');
    $cgiapp->prerun_mode('do_nothing');
  } else {
    $cgiapp->header_add(-location => '/');
    $cgiapp->header_type('redirect');
    $cgiapp->prerun_mode('do_nothing');
  }
}

sub login_error_runmode {
  
  my $self = shift;
  
  my $msg_aref = [{'Message' => 'You need to login first.'}];

  my $data_for_postrun_href = {};

  $data_for_postrun_href->{'Error'}         = 1;
  $data_for_postrun_href->{'HTTPErrorCode'} = 401;
  $data_for_postrun_href->{'Data'}          = {'Error' => $msg_aref};
  
  if (uc($self->authen->transform_xml_error_message()) eq 'YES') {

    $data_for_postrun_href->{'XSL'} = $self->authen->xsl_url();
  }

  return $data_for_postrun_href;
}

sub require_group_assignment_runmode {

  my $self = shift;

  my $msg_aref = [{'Message' => 'You need to choose your group first.'}];

  my $data_for_postrun_href = {};

  $data_for_postrun_href->{'Error'}         = 1;
  $data_for_postrun_href->{'HTTPErrorCode'} = 401;
  $data_for_postrun_href->{'Data'}          = {'Error' => $msg_aref};
  
  if (uc($self->authen->transform_xml_error_message()) eq 'YES') {

    $data_for_postrun_href->{'XSL'} = $self->authen->xsl_url();
  }

  return $data_for_postrun_href;
}

sub rand_error_runmode {
  
  my $self  = shift;
  my $query = $self->query();
  my $rand  = $query->param('rand_num');

  my $msg_aref = [{'Message' => "($rand): Random number has already been used."}];
  
  my $data_for_postrun_href = {};

  $data_for_postrun_href->{'Error'} = 1;
  $data_for_postrun_href->{'Data'}  = {'Error' => $msg_aref};
  
  if (uc($self->authen->transform_xml_error_message()) eq 'YES') {

    $data_for_postrun_href->{'XSL'} = $self->authen->xsl_url();
  }

  return $data_for_postrun_href;
}

sub signature_error_runmode {
  
  my $self = shift;

  my $msg_aref = [{'Message' => 'Data signature verification failed.'}];
  
  my $data_for_postrun_href = {};

  $data_for_postrun_href->{'Error'} = 1;
  $data_for_postrun_href->{'Data'}  = {'Error' => $msg_aref};
  
  if (uc($self->authen->transform_xml_error_message()) eq 'YES') {

    $data_for_postrun_href->{'XSL'} = $self->authen->xsl_url();
  }

  return $data_for_postrun_href;
}

sub upload_2large_error_runmode {
  
  my $self = shift;

  my $msg_aref = [{'Message' => 'File could be TOO large or upload file missing with CGI error.'}];

  my $data_for_postrun_href = {};

  $data_for_postrun_href->{'Error'} = 1;
  $data_for_postrun_href->{'Data'}  = {'Error' => $msg_aref};
  
  if (uc($self->authen->transform_xml_error_message()) eq 'YES') {

    $data_for_postrun_href->{'XSL'} = $self->authen->xsl_url();
  }

  return $data_for_postrun_href;
}

sub already_login_runmode {

  my $self = shift;

  my $msg_aref = [{'Message' => 'Already login.'}];

  my $data_for_postrun_href = {};

  $data_for_postrun_href->{'Error'} = 1;
  $data_for_postrun_href->{'Data'}  = {'Error' => $msg_aref};
  
  if (uc($self->authen->transform_xml_error_message()) eq 'YES') {

    $data_for_postrun_href->{'XSL'} = $self->authen->xsl_url();
  }

  return $data_for_postrun_href;
}

sub require_gadmin_runmode {

  my $self = shift;

  my $msg_aref = [{'Message' => 'Access denied: group administrator required.'}];

  my $data_for_postrun_href = {};

  $data_for_postrun_href->{'Error'}         = 1;
  $data_for_postrun_href->{'HTTPErrorCode'} = 401;
  $data_for_postrun_href->{'Data'}          = {'Error' => $msg_aref};
  
  if (uc($self->authen->transform_xml_error_message()) eq 'YES') {

    $data_for_postrun_href->{'XSL'} = $self->authen->xsl_url();
  }

  return $data_for_postrun_href;
}

sub ctrl_char_not_allowed_runmode {

  my $self = shift;

  my $msg_aref = [{'Message' => 'Control character not allowed.'}];

  my $data_for_postrun_href = {};

  $data_for_postrun_href->{'Error'} = 1;
  $data_for_postrun_href->{'Data'}  = {'Error' => $msg_aref};
  
  if (uc($self->authen->transform_xml_error_message()) eq 'YES') {

    $data_for_postrun_href->{'XSL'} = $self->authen->xsl_url();
  }

  return $data_for_postrun_href;
}

sub content_type_not_allowed_runmode {

  my $self  = shift;
  my $query = $self->query();

  my $content_type = $query->param('ctype');

  my $msg_aref = [{'Message' => "Content-type ($content_type): invalid."}];

  my $data_for_postrun_href = {};

  $data_for_postrun_href->{'Error'} = 1;
  $data_for_postrun_href->{'Data'}  = {'Error' => $msg_aref};
  
  if (uc($self->authen->transform_xml_error_message()) eq 'YES') {

    $data_for_postrun_href->{'XSL'} = $self->authen->xsl_url();
  }

  return $data_for_postrun_href;
}

sub over_session_quota_runmode {

  my $self = shift;

  my $config    = $self->authen->_config;
  my $interval  = $config->{SESSION_COUNTER}->{INTERVAL};
  my $delay     = $config->{SESSION_COUNTER}->{DELAY};

  my $waiting_time = $interval + $delay;

  my $msg = "${waiting_time} : Session request quota reaches. ";
  $msg   .= "This session has to wait for $waiting_time seconds before making the request again. ";
  $msg   .= "If waiting for $waiting_time seconds is not acceptable, please contact us.";

  my $msg_aref = [{'Message' => $msg}];

  my $data_for_postrun_href = {};

  $data_for_postrun_href->{'Error'} = 1;
  $data_for_postrun_href->{'Data'}  = {'Error' => $msg_aref};
  
  if (uc($self->authen->transform_xml_error_message()) eq 'YES') {

    $data_for_postrun_href->{'XSL'} = $self->authen->xsl_url();
  }

  return $data_for_postrun_href;
}

sub defer_request_runmode {

  my $self  = shift;
  my $query = $self->query();
  my $rand  = $query->param('rand_num');

  my $config    = $self->authen->_config;
  my $interval  = $config->{SESSION_COUNTER}->{INTERVAL};
  my $delay     = $config->{SESSION_COUNTER}->{DELAY};

  my $waiting_time = $interval + $delay;

  my $msg = "${waiting_time} : $rand random number has been deferred due to over limit session quota. ";
  $msg   .= "If after waiting for $waiting_time seconds, you can present this random number again and ";
  $msg   .= "your question will be served.";

  my $msg_aref = [{'Message' => $msg}];

  my $data_for_postrun_href = {};

  $data_for_postrun_href->{'Error'} = 1;
  $data_for_postrun_href->{'Data'}  = {'Error' => $msg_aref};
  
  if (uc($self->authen->transform_xml_error_message()) eq 'YES') {

    $data_for_postrun_href->{'XSL'} = $self->authen->xsl_url();
  }

  return $data_for_postrun_href;
}

sub do_nothing_runmode {
  
  # This run mode is required when users have not authenticated.
  # It returns an empty string. This run mode is executed when
  # the user is not authenticated.
  
  return '';
}

sub logout_runmode {

  my $self = shift;
  $self->logout();
}

###
### Helper methods
###

sub _cgiapp {

  return $_[0]->{cgiapp};
}

sub _find_deligate_class {

  foreach my $class (@_) {
    $class->require && return $class;
  }
  return;
}

sub _config {

  my $self  = shift;
  my $class = ref $self ? ref $self : $self;
  my $config;
  if ( ref $self ) {
    $config = $self->{__CAP_AUTHENTICATION_CONFIG} ||= $__CONFIG{$class} || {};
  } else {
    $__CONFIG{$class} ||= {};
    $config = $__CONFIG{$class};
  }
  return $config;
}

sub logger {
  
  my $self = shift;
  
  return $self->{logger};
}

###
### Helper functions
###

sub _time_to_seconds {

  my $time = shift;
  return unless defined $time;
  
  # Most of this function is borrowed from CGI::Util v1.4 by Lincoln Stein
  my (%mult) = (
    's' => 1,
    'm' => 60,
    'h' => 60 * 60,
    'd' => 60 * 60 * 24,
    'w' => 60 * 60 * 24 * 7,
    'M' => 60 * 60 * 24 * 30,
    'y' => 60 * 60 * 24 * 365
      );
  # format for time can be in any of the forms...
  # "180" -- in 180 seconds
  # "180s" -- in 180 seconds
  # "2m" -- in 2 minutes
  # "12h" -- in 12 hours
  # "1d"  -- in 1 day
  # "4w"  -- in 4 weeks
  # "3M"  -- in 3 months
  # "2y"  -- in 2 years
  my $offset;
  if ( $time =~ /^([+-]?(?:\d+|\d*\.\d*))([smhdwMy]?)$/ ) {
    return if (!$2 || $2 eq 's') && $1 != int $1; # 
    $offset = int ( ( $mult{$2} || 1 ) * $1 );
  }
  return $offset;
}

sub _verify_session_checksum {

  my $self = shift;
  
  my $username        = $self->store->fetch('username');
  
  if ( !$username ) { return 0; }
  
  my $session_id      = $self->_cgiapp->session->id();
  my $rememberme      = $self->store->fetch('remember_me');
  my $write_token     = $self->store->fetch('write_token');
  my $group_id        = $self->store->fetch('group_id');
  my $user_id         = $self->store->fetch('user_id');
  my $gadmin_status   = $self->store->fetch('gadmin_status');

  my $env_cookie      = $ENV{'HTTP_COOKIE'};
  
  my $cookie_key = read_cookie($env_cookie, 'KDDArT_RANDOM_NUMBER');
  
  my $stored_checksum = $self->store->fetch('checksum');
  
  my $hash_data = "$username";
  $hash_data   .= "$session_id";
  $hash_data   .= "$rememberme";
  $hash_data   .= "$write_token";
  $hash_data   .= "$group_id";
  $hash_data   .= "$user_id";
  $hash_data   .= "$gadmin_status";
  
  my $derived_checksum = hmac_sha1_hex($hash_data, $cookie_key);
  
  if ( $derived_checksum eq $stored_checksum ) {

    #$self->logger->debug("Stored checksum: $stored_checksum, Derived checksum: $derived_checksum");
    return 1;
  }
  else {

    $self->logger->debug("COOKIE: $env_cookie");
    $self->logger->debug("Checksum failed: $hash_data Key: $cookie_key");
    return 0;
  }
}

sub recalculate_session_checksum {

  my $self = shift;

  my $session_id      = $self->_cgiapp->session->id();

  my $username        = $self->store->fetch('username'); 
  my $rememberme      = $self->store->fetch('remember_me');
  my $write_token     = $self->store->fetch('write_token');
  my $group_id        = $self->store->fetch('group_id');
  my $user_id         = $self->store->fetch('user_id');
  my $gadmin_status   = $self->store->fetch('gadmin_status');
  
  my $cookie_key = read_cookie($ENV{'HTTP_COOKIE'}, 'KDDArT_RANDOM_NUMBER');

  my $hash_data = "$username";
  $hash_data   .= "$session_id";
  $hash_data   .= "$rememberme";
  $hash_data   .= "$write_token";
  $hash_data   .= "$group_id";
  $hash_data   .= "$user_id";
  $hash_data   .= "$gadmin_status";

  my $new_checksum = hmac_sha1_hex($hash_data, $cookie_key);

  $self->store->save('checksum' => $new_checksum);
}

sub contain_ctrl_char {

  my $self  = $_[0];
  my $query = $_[1];

  my $params      = $query->Vars();

  my $ctrl_char_found = 0;

  for my $para_name (keys(%{$params})) {

    my $para_val = $query->param($para_name);

    # Line feed, carriage return and horizontal tab should not be regarded as control characters
    # Horizontal tab: \x09, Line feed: \x0a and Carriage return: \x0d are excluded in the regular expression.

    if ($para_val =~ /[\x00-\x08]|\x0b|\x0c|[\x0e-\x1f]|\x7f/) {
      
      $self->logger->debug("$para_name value($para_val): containing a control character.");
      $ctrl_char_found = 1;
      last;
    }

    # prevent cross site script attack.
    if ($para_val =~ /<script[^>]*>.*?<\/script>/is) {

      $self->logger->debug("$para_name value($para_val): containing script tag.");
      $ctrl_char_found = 1;
      last;
    }

    # prevent other less obvious cross site script attack like <img src="alert('Test');">
    if ($para_val =~ /<.*\w+=['|"]?.*['|"]?.*>/is) {

      $self->logger->debug("$para_name value($para_val): containing suspicious tag.");
      $ctrl_char_found = 1;
      last;
    }
  }

  return $ctrl_char_found;
}

sub check_sign_upload {

  my $self            = $_[0];
  my $query           = $_[1];
  my $current_runmode = $_[2];

  my $upload_file = $query->param('uploadfile');

  if (!$upload_file && $query->cgi_error()) {
    
    return $self->redirect_to_upload_2large_error;
  }
  
  my $rand = makerandom(Size => 32, Strength => 0);
  my $cur_dt = DateTime->now( time_zone => $TIMEZONE );
  my $saved_upload_fn = "${TMP_DATA_PATH}" . "${current_runmode}-" . "$cur_dt-${rand}";
  
  $self->store->save( "${current_runmode}_upload" => $saved_upload_fn );
  
  my $saved_upload_fhandle;
  open($saved_upload_fhandle, ">$saved_upload_fn") or 
      die "Cannot save upload file to $saved_upload_fn: $!";
  
  while (my $line = <$upload_file>) {
    
    print $saved_upload_fhandle $line;
  }
  close($saved_upload_fhandle);
  
  open($saved_upload_fhandle, "$saved_upload_fn");
  binmode($saved_upload_fhandle);
  
  my $upfile_checksum = Digest::MD5->new->addfile(*$saved_upload_fhandle)->hexdigest();
  close($saved_upload_fhandle);

  $self->logger->debug("Upload file MD5: $upfile_checksum");
  
  $self->logger->debug("[$current_runmode] Upload file checksum: $upfile_checksum");

  if ( $current_runmode ne 'add_multimedia') {

    # convert to unix after doing the checksum. if conversion to unix is done before checksum
    # the checksum will fail for non unix files.
    my $dos2unix_result=`perl -pi -e 's/\r?\n|\r/\n/g' $saved_upload_fn 2>&1`;

    if (length($dos2unix_result) > 0) {

      # This should never fail. But who knows, that's why this condition is here
      $self->logger->debug("DOS to UNIX failed: $dos2unix_result");
    }
    else {

      $self->logger->debug("DOS to UNIX: successful");
    }
  }
  
  my $rand_num       = $query->param('rand_num');
  my $user_signature = $query->param('signature');
  my $signed_url     = $query->param('url');
  my $atomic_order   = $query->param('param_order');
  
  my $atomic_data = '';
  
  my @fields = split(/,/, $atomic_order);
  foreach my $field (@fields) {
    
    my $field_data = $query->param($field);
    if (length($field_data) == 0) {

      $self->logger->debug("$field : $field_data (believed to be empty)");
    }
    else {

      $self->logger->debug("$field : $field_data");
    }
    $atomic_data .= "$field_data";
  }
  
  my $data2sign = '';
  $data2sign   .= "$signed_url";
  $data2sign   .= "$rand_num";
  $data2sign   .= "$atomic_data";
  $data2sign   .= "$upfile_checksum";

  $self->logger->debug("data2sign: $data2sign");
  
  my $key = $self->write_token();
  my $cal_signature = hmac_sha1_hex($data2sign, $key);
  
  if ($user_signature ne $cal_signature) {
    
    $self->logger->debug("Signature verification failed: $user_signature | $cal_signature");
    return 0;
  }
  else {
    
    return 1;
  }
}

sub check_signature {

  my $self            = $_[0];
  my $query           = $_[1];
  my $current_runmode = $_[2];

  my $rand_num       = $query->param('rand_num');
  my $user_signature = $query->param('signature');
  my $signed_url     = $query->param('url');
  my $atomic_order   = $query->param('param_order');
  
  my $atomic_data = '';
  
  my @fields = split(/,/, $atomic_order);
  foreach my $field (@fields) {
    
    my $field_data = $query->param($field);
    if (length($field_data) == 0) {

      $self->logger->debug("$field : $field_data (believed to be empty)");
    }
    else {

      $self->logger->debug("$field : $field_data");
    }
    $atomic_data .= "$field_data";
  }
  
  my $data2sign = '';
  $data2sign   .= "$signed_url";
  $data2sign   .= "$rand_num";
  $data2sign   .= "$atomic_data";
  
  my $key = $self->write_token();
  my $cal_signature = hmac_sha1_hex($data2sign, $key);
  
  if ($user_signature ne $cal_signature) {
    
    $self->logger->debug("Signature verification failed: $user_signature | $cal_signature");
    return 0;
  }
  else {
    
    $self->logger->debug("Signature passed: $user_signature | $cal_signature");
    return 1;
  }
}

sub check_counter {

  my $self         = $_[0];
  my $storage      = $_[1];
  my $counter_name = $_[2];
  my $limit        = $_[3];

  my $counter = $storage->param($counter_name);

  if ( !(defined $counter) ) {

    return 0;
  }
  elsif ( $counter > $limit ) {

    return 1;
  }
  else {

    return 0;
  }
}

sub update_counter {

  my $self         = $_[0];
  my $storage      = $_[1];
  my $counter_name = $_[2];
  my $delay        = $_[3];

  my $count = $storage->param($counter_name);
  my $now = time();

  if ( !(defined $count) ) {

    $storage->param($counter_name, 1);
    $storage->param("${counter_name}_LAST_REQUEST", $now);
  }
  else {

    my $last_request = $storage->param("${counter_name}_LAST_REQUEST");
    if ( ($now - $delay) > $last_request ) {

      $storage->param($counter_name, 1);
      $storage->param("${counter_name}_LAST_REQUEST", $now);
    }
    else {

      $storage->param($counter_name, $count + 1);
      $storage->param("${counter_name}_LAST_REQUEST", $now);
    }
  }
}

sub update_rand {

  my $self     = $_[0];
  my $storage  = $_[1];
  my $rand     = $_[2];
  my $delay    = $_[3];

  my $now = time();

  $self->logger->debug("Passing delay parameter: $delay");

  $storage->param($rand, $delay);
  $storage->param("${rand}_LAST_SEEN", $now);
}

sub is_rand_done {

  my $self            = $_[0];
  my $storage         = $_[1];
  my $rand            = $_[2];

  my $rand_delay = $storage->param($rand);
 
  if ( !(defined $rand_delay)  ) {

    return 0;
  }
  elsif ( $rand_delay == 0 ) {

    return 1;
  }
  else {

    return 0;
  }
}

sub should_rand_be_done {

  my $self            = $_[0];
  my $storage         = $_[1];
  my $rand            = $_[2];

  my $rand_delay = $storage->param($rand);

  if ( !(defined $rand_delay) ) {

    # this random number should not be serviced
    # because we're in the deferred mode, and 
    # we haven't seen it before.

    return 0;
  }
  elsif ( $rand_delay == 0 ) {

    # this one should be dealt with because
    # this random is a duplicate, and it should
    # be dealt with because duplicate random number
    # is very cheap to deal with. No point to deferred
    # the message saying that this random number is
    # duplicate.

    return 1;
  }
  elsif ( $rand_delay > 0 ) {
    
    my $now = time();
    my $last_seen = $storage->param("${rand}_LAST_SEEN");
    if ( ($now - $rand_delay) >= $last_seen  ) {

      return 1;
    }
    else {

      return 0;
    }
  }
}

sub is_content_type_valid {

  my $self         = $_[0];
  my $query        = $self->_cgiapp->query();

  my $content_type  = '';
  my $accept_header = '';

  if (defined $query->http('Accept')) {

    $accept_header = $query->http('Accept');
    if (defined $ACCEPT_HEADER_LOOKUP->{lc($accept_header)}) {

      $content_type  = $ACCEPT_HEADER_LOOKUP->{lc($accept_header)};
    }
  }

  $self->logger->debug("Accept Header: $accept_header");

  if (defined $query->param('ctype')) {

    $content_type = lc($query->param('ctype'));
  }

  my $valid = 0;

  if (length($content_type) == 0) {

    $valid = 1;
  }
  else {

    if (defined $VALID_CTYPE->{lc($content_type)}) {

      $valid = 1;
    }
  }

  return $valid;
}

sub get_content_type {

  my $self         = $_[0];
  my $query        = $self->_cgiapp->query();

  my $content_type  = '';
  my $accept_header = '';

  if (defined $query->http('Accept')) {

    $accept_header = $query->http('Accept');
    if (defined $ACCEPT_HEADER_LOOKUP->{lc($accept_header)}) {

      $content_type  = $ACCEPT_HEADER_LOOKUP->{lc($accept_header)};
    }
  }

  $self->logger->debug("Accept Header: $accept_header");

  if (defined $query->param('ctype')) {

    $content_type = lc($query->param('ctype'));
  }

  return $content_type;
}

sub list_group {

  my $self    = $_[0];
  my $user_id = $_[1];

  my $dbh = connect_kdb_read();

  my $sql = 'SELECT systemgroup.SystemGroupId, ';
  $sql   .= 'systemgroup.SystemGroupName, ';
  $sql   .= 'systemgroup.SystemGroupDescription ';
  $sql   .= 'FROM authorisedsystemgroup LEFT JOIN ';
  $sql   .= 'systemgroup ON ';
  $sql   .= 'authorisedsystemgroup.SystemGroupId = systemgroup.SystemGroupId ';
  $sql   .= 'WHERE authorisedsystemgroup.UserId=?';

  #$self->logger->debug("SQL: $sql");

  my $sth = $dbh->prepare($sql);
  $sth->execute($user_id);

  my $err  = 0;
  my $msg  = '';
  my $group_data;

  if ( !$dbh->err() ) {

    my $array_ref = $sth->fetchall_arrayref({});

    if ( !$sth->err() ) {

      $group_data = $array_ref;
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
  $dbh->disconnect();

  return ($err, $msg, $group_data);
}

sub list_all_group {

  my $self    = $_[0];

  my $dbh = connect_kdb_read();

  my $sql = 'SELECT SystemGroupId, SystemGroupName ';
  $sql   .= 'FROM systemgroup';

  #$self->logger->debug("SQL: $sql");

  my $sth = $dbh->prepare($sql);
  $sth->execute();

  my $err  = 0;
  my $msg  = '';
  my $group_data;

  if ( !$dbh->err() ) {

    my $array_ref = $sth->fetchall_arrayref({});

    if ( !$sth->err() ) {

      $group_data = $array_ref;
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
  $dbh->disconnect();

  return ($err, $msg, $group_data);
}

sub get_upload_file {

  my $self = shift;

  my $current_runmode = $self->_cgiapp->get_current_runmode();

  my $saved_xml_fn = $self->store->fetch("${current_runmode}_upload");

  return $saved_xml_fn;
}

sub get_session_expiry {

  my $self = shift;

  return _time_to_seconds($self->_config->{'LOGIN_SESSION_TIMEOUT'}->{'IDLE_FOR'});
}


1;
