#$Id$
#$Author$

# Copyright (c) 2011, Diversity Arrays Technology, All rights reserved.

# Author    : Puthick Hok
# Created   : 02/06/2010
# Modified  :
# Purpose   : 
#          
#          

package KDDArT::DAL::ModIndex;

use strict;
use warnings;

BEGIN {
  use File::Spec;

  my ($volume, $current_dir, $file) = File::Spec->splitpath(__FILE__);

  my @current_dir_part = split('/perl-lib/KDDArT/DAL/', $current_dir);
  $main::kddart_base_dir = $current_dir_part[0];
}


use lib "$main::kddart_base_dir/perl-lib";
use CGI qw( :standard );


use KDDArT::DAL::Common;

use base 'CGI::Application::Dispatch';

$CGI::POST_MAX           = 4 * 1024 * 1024 * 1024; # Limit post in MB (4GB)
$CGI::DISABLE_UPLOADS    = 0;                      # Allow file uploads

sub dispatch_args {

  my $dispatch_table_str = read_dispatch_table($CGI_INDEX_SCRIPT);
  my $dispatch_table;
  eval($dispatch_table_str);

  return { table => $dispatch_table->{'table'} };
}

1;
