#$Id: ModIndex.pm 930 2015-06-23 06:04:26Z puthick $
#$Author: puthick $

# Copyright (c) 2015, Diversity Arrays Technology, All rights reserved.

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
# Version   : 2.3.0 build 1040

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
