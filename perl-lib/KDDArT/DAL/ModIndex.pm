#$Id: ModIndex.pm 643 2014-02-04 06:16:08Z puthick $
#$Author: puthick $

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
# Created   : 02/06/2010

package KDDArT::DAL::ModIndex;

use strict;
use warnings;

BEGIN {
  use File::Spec;

  my ($volume, $current_dir, $file) = File::Spec->splitpath(__FILE__);

  $main::kddart_base_dir = "${current_dir}../../..";
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
