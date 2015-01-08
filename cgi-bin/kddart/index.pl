#!/usr/bin/perl -w

#$Id: index.pl 784 2014-09-02 02:58:04Z puthick $
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

use strict;
use warnings;

BEGIN {
  use File::Spec;

  my ($volume, $current_dir, $file) = File::Spec->splitpath(__FILE__);

  $main::kddart_base_dir_cgi = "${current_dir}../..";
}

use lib "$main::kddart_base_dir_cgi/perl-lib";
use CGI qw( :standard );


use CGI::Application::Dispatch;

$CGI::POST_MAX           = 4 * 1024 * 1024 * 1024;        # Limit post in MB (4GB)
$CGI::DISABLE_UPLOADS    = 0;                             # Allow file uploads

CGI::Application::Dispatch->dispatch( 
  table => [

    'login/:username/:rememberme'                       => { app => 'KDDArT::DAL::Authentication',
                                                             rm  => 'login' },

    'switch/group/:id'                                  => { app => 'KDDArT::DAL::Authentication',
                                                             rm  => 'switch_to_group' },

    'set/group/:id'                                     => { app => 'KDDArT::DAL::Authentication',
                                                             rm  => 'switch_to_group' },

    'logout'                                            => { app => 'KDDArT::DAL::Authentication',
                                                             rm  => 'logout' },

    'get/login/status'                                  => { app => 'KDDArT::DAL::Authentication',
                                                             rm  => 'get_login_status' },

    'add/organisation'                                  => { app => 'KDDArT::DAL::Contact',
                                                             rm  => 'add_organisation_gadmin' },

    'update/organisation/:id'                           => { app => 'KDDArT::DAL::Contact',
                                                             rm  => 'update_organisation_gadmin' },

    'delete/organisation/:id'                           => { app => 'KDDArT::DAL::Contact',
                                                             rm  => 'del_organisation_gadmin' },

    'list/organisation/:nperpage/page/:num'             => { app => 'KDDArT::DAL::Contact',
                                                             rm  => 'list_organisation_advanced' },

    'get/organisation/:id'                              => { app => 'KDDArT::DAL::Contact',
                                                             rm  => 'get_organisation' },

    'add/contact'                                       => { app => 'KDDArT::DAL::Contact',
                                                             rm  => 'add_contact_gadmin' },

    'update/contact/:id'                                => { app => 'KDDArT::DAL::Contact',
                                                             rm  => 'update_contact_gadmin' },

    'delete/contact/:id'                                => { app => 'KDDArT::DAL::Contact',
                                                             rm  => 'del_contact_gadmin' },

    'list/contact/:nperpage/page/:num'                  => { app => 'KDDArT::DAL::Contact',
                                                             rm  => 'list_contact_advanced' },

    'get/contact/:id'                                   => { app => 'KDDArT::DAL::Contact',
                                                             rm  => 'get_contact' },

    'add/user'                                          => { app => 'KDDArT::DAL::System',
                                                             rm  => 'add_user_gadmin' },

    'update/user/:username'                             => { app => 'KDDArT::DAL::System',
                                                             rm  => 'update_user_gadmin' },

    'user/:username/reset/password'                     => { app => 'KDDArT::DAL::System',
                                                             rm  => 'reset_user_password_gadmin' },

    'list/user'                                         => { app => 'KDDArT::DAL::System',
                                                             rm  => 'list_user_gadmin' },

    'get/user/:id'                                      => { app => 'KDDArT::DAL::System',
                                                             rm  => 'get_user' },

    'user/:username/change/password'                    => { app => 'KDDArT::DAL::System',
                                                             rm  => 'change_user_password' },

    'add/group'                                         => { app => 'KDDArT::DAL::System',
                                                             rm  => 'add_group_gadmin' },

    'group/:id/add/member/:username/:random'            => { app => 'KDDArT::DAL::System',
                                                             rm  => 'add_group_member_gadmin' },

    'group/:id/add/owner/:username/:random'             => { app => 'KDDArT::DAL::System',
                                                             rm  => 'add_group_owner_gadmin' },

    'group/:id/remove/user/:username'                   => { app => 'KDDArT::DAL::System',
                                                             rm  => 'remove_group_member_gadmin' },

    'group/:id/remove/owner/status/:username'           => { app => 'KDDArT::DAL::System',
                                                             rm  => 'remove_owner_status_gadmin' },

    ':tname/:recordid/change/permission'                => { app => 'KDDArT::DAL::System',
                                                             rm  => 'change_permission' },

    ':tname/:recordid/change/owner'                     => { app => 'KDDArT::DAL::System',
                                                             rm  => 'change_owner' },

    'get/permission/:tname/:recordid'                   => { app => 'KDDArT::DAL::System',
                                                             rm  => 'get_permission' },

    'list/group'                                        => { app => 'KDDArT::DAL::System',
                                                             rm  => 'list_group' },

    'get/group/:id'                                     => { app => 'KDDArT::DAL::System',
                                                             rm  => 'get_group_gadmin' },

    'list/all/group'                                    => { app => 'KDDArT::DAL::System',
                                                             rm  => 'list_all_group' },

    'list/operation'                                    => { app => 'KDDArT::DAL::System',
                                                             rm  => 'list_operation' },

    'switch/extradata/:switch'                          => { app => 'KDDArT::DAL::Authentication',
                                                             rm  => 'switch_extra_data' },

    'list/factor'                                       => { app => 'KDDArT::DAL::VirtualColumn',
                                                             rm  => 'list_factor_table' },

    ':tname/list/field'                                 => { app => 'KDDArT::DAL::VirtualColumn',
                                                             rm  => 'list_field' },

    'update/vcolumn/:id'                                => { app => 'KDDArT::DAL::VirtualColumn',
                                                             rm  => 'update_vcolumn_gadmin' },

    'get/vcolumn/:id'                                   => { app => 'KDDArT::DAL::VirtualColumn',
                                                             rm  => 'get_vcolumn' },

    'factortable/:tname/add/vcolumn'                    => { app => 'KDDArT::DAL::VirtualColumn',
                                                             rm  => 'add_vcolumn_gadmin' },

    'add/layer'                                         => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'add_layer' },

    'update/layer/:id'                                  => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'update_layer' },

    'add/layer/n/attribute'                             => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'add_layer_n_attrib' },

    'list/layerattrib/valuetype'                        => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'list_layer_attrib_valuetype' },

    'add/layerattrib/valuetype'                         => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'add_layer_attrib_valuetype_gadmin' },

    'update/layerattrib/valuetype/:id'                  => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'update_layer_attrib_valuetype_gadmin' },

    'get/layerattrib/valuetype/:id'                     => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'get_layer_attrib_valuetype' },

    'delete/layerattrib/valuetype/:id'                  => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'del_layer_attrib_valuetype_gadmin' },

    ':tname/get/dtd'                                    => { app => 'KDDArT::DAL::VirtualColumn',
                                                             rm  => 'get_dtd' },

    'register/device'                                   => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'register_device_gadmin' },

    'update/deviceregistration/:id'                    => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'update_device_registration_gadmin' },

    'delete/deviceregistration/:id'                    => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'del_device_registration_gadmin' },

    'list/deviceregistration'                          => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'list_dev_registration_full' },

    'map/deviceparameter'                              => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'map_device_param_gadmin' },

    'log/environment/data'                              => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'log_environment_data' },

    'list/layer'                                        => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'list_layer_full' },

    'get/layer/:id'                                     => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'get_layer' },

    'list/parametermapping'                             => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'list_parameter_mapping_full' },

    'get/parametermapping/:devid/:para/:atid'           => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'get_parameter_mapping' },

    'update/parametermapping/:devid/:para/:atid'        => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'update_device_param_mapping_gadmin' },

    'layer/:id/add/attribute'                           => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'add_layer_attribute' },

    'list/layerattrib'                                  => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'list_layer_attribute' },

    'layer/:id/list/layerattrib'                        => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'list_layer_attribute' },

    'layer/:id/add/attribute/bulk'                      => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'add_layer_attribute_bulk' },

    'layer/:id/export/shp'                              => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'export_layer_data_shape' },

    'layer/:id/import/csv'                              => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'import_layer_data_csv' },

    'add/genotype'                                      => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'add_genotype' },

    'genus/:genusid/list/genotype/:nperpage/page/:num'  => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'list_genotype_advanced' },

    'genus/:genusid/list/genotype'                      => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'list_genotype_advanced' },


    'list/genotype/:nperpage/page/:num'                 => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'list_genotype_advanced' },

    'update/genotype/:id'                               => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'update_genotype' },

    'delete/genotype/:id'                               => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'del_genotype_gadmin' },

    'get/genotype/:id'                                  => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'get_genotype' },

    'genotype/:id/add/alias'                            => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'add_genotype_alias' },

    'genotype/:genoid/list/alias'                       => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'list_genotype_alias_advanced' },

    'list/genotypealias/:nperpage/page/:num'            => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'list_genotype_alias_advanced' },

    'import/genotype/csv'                               => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'import_genotype_csv' },

    'export/genotype'                                   => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'export_genotype' },

    'update/genotypealias/:id'                          => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'update_genotype_alias' },

    'get/genotypealias/:id'                             => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'get_genotype_alias' },

    'add/genus'                                         => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'add_genus_gadmin' },

    'genotype/:id/add/trait'                            => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'add_trait2genotype' },

    'update/genotypetrait/:genotraitid'                 => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'update_genotype_trait' },

    'get/genotypetrait/:genotraitid'                    => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'get_genotype_trait' },

    'genotype/:id/list/trait'                           => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'list_genotype_trait' },

    'genotype/:genoid/remove/trait/:traitid'            => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'remove_genotype_trait' },

    'list/genus'                                        => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'list_genus' },

    'get/genus/:id'                                     => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'get_genus' },

    'update/genus/:id'                                  => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'update_genus_gadmin' },

    'delete/genus/:id'                                  => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'del_genus_gadmin' },

    'add/specimen'                                      => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'add_specimen' },

    'import/specimen/csv'                               => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'import_specimen_csv' },

    'export/specimen'                                   => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'export_specimen' },

    'update/specimen/:id'                               => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'update_specimen' },

    'delete/specimen/:id'                               => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'del_specimen_gadmin' },

    'specimen/:id/add/genotype'                         => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'add_genotype_to_specimen' },

    'specimen/:id/remove/genotype/:genoid'              => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'remove_genotype_from_specimen_gadmin' },

    'specimen/:id/list/genotype'                        => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'list_genotype_in_specimen' },

    'import/pedigree/csv'                               => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'import_pedigree_csv' },

    'export/pedigree'                                   => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'export_pedigree' },

    'update/pedigree/:id'                               => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'update_pedigree_gadmin' },

    'delete/pedigree/:id'                               => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'del_pedigree_gadmin' },

    'add/pedigree'                                      => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'add_pedigree' },

    'list/pedigree/:nperpage/page/:num'                 => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'list_pedigree_advanced' },

    'list/genpedigree/:nperpage/page/:num'              => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'list_gen_pedigree_advanced' },

    'specimen/:id/list/ancestor'                        => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'list_spec_ancestor' },

    'specimen/:id/list/descendant'                      => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'list_spec_descendant' },

    'add/specimengroup'                                 => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'add_specimen_group' },

    'list/specimengroup/:nperpage/page/:num'            => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'list_specimen_group_advanced' },

    'get/specimengroup/:id'                             => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'get_specimen_group' },

    'update/specimengroup/:id'                          => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'update_specimen_group_gadmin' },

    'delete/specimengroup/:id'                          => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'del_specimen_group_gadmin' },

    'specimengroup/:specgrpid/add/specimen'             => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'add_specimen2specimen_group_gadmin' },

    'specimengroup/:specgrpid/remove/specimen/:specid'  => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'remove_specimen_from_specimen_group_gadmin' },

    'specimengroup/:specgrpid/remove/specimen'          => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'remove_specimen_from_specimen_group_bulk_gadmin' },

    'get/session/expiry'                                => { app => 'KDDArT::DAL::System',
                                                             rm  => 'get_session_expiry' },

    'list/specimen/:nperpage/page/:num'                 => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'list_specimen_advanced' },

    'genotype/:genoid/list/specimen'                    => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'list_specimen_advanced' },

    'genotype/:genoid/list/specimen/:nperpage/page/:num'   => { app => 'KDDArT::DAL::Genotype',
                                                                rm  => 'list_specimen_advanced' },

    'get/specimen/:id'                                  => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'get_specimen' },

    'add/breedingmethod'                                => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'add_breedingmethod_gadmin' },

    'update/breedingmethod/:id'                         => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'update_breedingmethod_gadmin' },

    'delete/breedingmethod/:id'                         => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'del_breedingmethod_gadmin' },

    'list/breedingmethod'                               => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'list_breedingmethod' },

    'get/breedingmethod/:id'                            => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'get_breedingmethod' },

    'add/site'                                          => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'add_site_gadmin' },

    'list/site/:nperpage/page/:num'                     => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'list_site_advanced' },

    'get/site/:id'                                      => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'get_site' },

    'update/site/:id'                                   => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'update_site_gadmin' },

    'site/:id/update/geography'                         => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'update_site_geography_gadmin' },

    'delete/site/:id'                                   => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'del_site_gadmin' },

    'add/designtype'                                    => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'add_designtype_gadmin' },

    'list/designtype'                                   => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'list_designtype' },

    'get/designtype/:id'                                => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'get_designtype' },

    'update/designtype/:id'                             => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'update_designtype_gadmin' },

    'delete/designtype/:id'                             => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'del_designtype_gadmin' },

    'add/trial'                                         => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'add_trial' },

    'list/trial/:nperpage/page/:num'                    => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'list_trial_advanced' },

    'site/:siteid/list/trial'                           => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'list_trial_advanced' },

    'site/:siteid/list/trial/:nperpage/page/:num'       => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'list_trial_advanced' },

    'get/trial/:id'                                     => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'get_trial' },

    'update/trial/:id'                                  => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'update_trial' },

    'trial/:id/update/geography'                        => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'update_trial_geography' },

    'delete/trial/:id'                                  => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'del_trial_gadmin' },

    'trial/:id/add/trialunit'                           => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'add_trial_unit' },

    'trial/:id/add/trialunit/bulk'                      => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'add_trial_unit_bulk' },

    'trial/:id/add/trait'                               => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'add_trial_trait' },

    'trial/:id/list/trait'                              => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'list_trial_trait' },

    'trial/:id/export/datakapturetemplate'              => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'export_datakapture_template' },

    'trial/:id/export/dkdata'                           => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'export_datakapture_data' },

    'import/datakapturedata/csv'                        => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'import_datakapture_data_csv' },

    'trial/:id/import/datakapturedata/csv'              => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'import_datakapture_data_csv' },

    'trial/:trialid/list/instancenumber'                => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'list_instancenumber' },

    'get/trialtrait/:id'                                => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'get_trial_trait' },

    'update/trialtrait/:id'                             => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'update_trial_trait' },

    'trial/:trialid/remove/trait/:traitid'              => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'remove_trial_trait' },

    'delete/trialunit/:id'                              => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'del_trial_unit_gadmin' },

    'trial/:trialid/list/trialunit'                     => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'list_trial_unit_advanced' },

    'trial/:trialid/list/trialunit/:nperpage/page/:num' => { app => 'KDDArT::DAL::Trial',
                                                              rm  => 'list_trial_unit_advanced' },

    'list/trialunit/:nperpage/page/:num'                => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'list_trial_unit_advanced' },

    'get/trialunit/:id'                                 => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'get_trial_unit' },

    'update/trialunit/:id'                              => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'update_trial_unit' },

    'trialunit/:id/update/geography'                    => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'update_trial_unit_geography' },

    'trialunit/:id/list/specimen'                       => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'list_trial_unit_specimen_advanced' },

    'trialunit/:id/list/specimen/:nperpage/page/:num'   => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'list_trial_unit_specimen_advanced' },

    'list/trialunitspecimen/:nperpage/page/:num'        => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'list_trial_unit_specimen_advanced' },

    'get/trialunitspecimen/:id'                         => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'get_trial_unit_specimen' },

    'trialunit/:id/add/specimen'                        => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'add_trial_unit_specimen' },

    'remove/trialunitspecimen/:id'                      => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'remove_trial_unit_specimen' },

    'update/trialunitspecimen/:id'                      => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'update_trial_unit_specimen' },

    'add/unitposition'                                  => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'add_unit_position_gadmin' },

    'list/unitposition'                                 => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'list_unit_position' },

    'get/unitposition/:id'                              => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'get_unit_position' },

    'update/unitposition/:id'                           => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'update_unit_position_gadmin' },

    'list/unitpositionfield'                            => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'list_unitposition_field' },

    'delete/unitposition/:id'                           => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'del_unit_position_gadmin' },

    'add/project'                                       => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'add_project_gadmin' },

    'update/project/:id'                                => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'update_project_gadmin' },

    'list/project/:nperpage/page/:num'                  => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'list_project_advanced' },

    'get/project/:id'                                   => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'get_project' },

    'delete/project/:id'                                => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'del_project_gadmin' },

    'add/treatment'                                     => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'add_treatment_gadmin' },

    'list/treatment/:nperpage/page/:num'                => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'list_treatment_advanced' },

    'get/treatment/:id'                                 => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'get_treatment' },

    'update/treatment/:id'                              => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'update_treatment_gadmin' },

    'delete/treatment/:id'                              => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'del_treatment_gadmin' },

    'add/trait'                                         => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'add_trait' },

    'list/trait/:nperpage/page/:num'                    => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'list_trait_advanced' },

    'get/trait/:id'                                     => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'get_trait' },

    'update/trait/:id'                                  => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'update_trait' },

    'delete/trait/:id'                                  => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'del_trait_gadmin' },

    'trait/:id/add/alias'                               => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'add_trait_alias' },

    'remove/traitalias/:id'                             => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'remove_trait_alias' },

    'update/traitalias/:id'                             => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'update_trait_alias' },

    'trait/:id/list/alias'                              => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'list_trait_alias' },

    'import/samplemeasurement/csv'                      => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'import_samplemeasurement_csv' },

    'export/samplemeasurement/csv'                      => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'export_samplemeasurement_csv' },

    'add/plate'                                         => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'add_plate_gadmin' },

    'add/plate/n/extract'                               => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'add_plate_n_extract_gadmin' },

    'add/analysisgroup'                                 => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'add_analysisgroup' },

    'add/extract'                                       => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'add_extract_gadmin' },

    'update/extract/:id'                                => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'update_extract_gadmin' },

    'analysisgroup/:id/import/markerdata/dart'          => { app => 'KDDArT::DAL::Marker',
                                                             rm  => 'import_marker_dart_fs' },

    'analysisgroup/:id/export/markerdata/dart'          => { app => 'KDDArT::DAL::Marker',
                                                             rm  => 'export_marker_dart_fs' },

    'analysisgroup/:id/list/markermetafield'            => { app => 'KDDArT::DAL::Marker',
                                                             rm  => 'list_marker_meta_field' },

    'analysisgroup/:analid/list/extract'                => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'list_extract' },

    'list/plate/:nperpage/page/:num'                    => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'list_plate_advanced' },

    'list/analysisgroup/:nperpage/page/:num'            => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'list_analysisgroup_advanced' },

    'get/plate/:id'                                     => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'get_plate' },

    'update/plate/:id'                                  => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'update_plate_gadmin' },

    'delete/plate/:id'                                  => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'del_plate_gadmin' },

    'list/extract'                                      => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'list_extract' },

    'delete/extract/:id'                                => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'del_extract_gadmin' },

    'get/extract/:id'                                   => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'get_extract' },

    'get/analysisgroup/:id'                             => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'get_analysisgroup' },

    'add/storage'                                       => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'add_storage_gadmin' },

    'update/storage/:id'                                => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'update_storage_gadmin' },

    'list/storage'                                      => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'list_storage' },

    'get/storage/:id'                                   => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'get_storage' },

    'delete/storage/:id'                                => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'del_storage_gadmin' },

    'add/itemunit'                                      => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'add_itemunit_gadmin' },

    'delete/itemunit/:id'                               => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'del_itemunit_gadmin' },

    'update/itemunit/:id'                               => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'update_itemunit_gadmin' },

    'get/itemunit/:id'                                  => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'get_itemunit' },

    'list/itemunit'                                     => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'list_itemunit' },

    'item/:id/add/parent'                               => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'add_itemparent_gadmin' },

    'item/:id/log'                                      => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'add_item_log' },

    'item/:id/show/log'                                 => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'show_item_log' },

    'list/itemparent'                                   => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'list_itemparent' },

    'get/itemparent/:id'                                => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'get_itemparent' },

    'delete/itemparent/:id'                             => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'del_itemparent_gadmin' },

    'itemgroup/:groupid/add/item'                       => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'add_item_to_group_gadmin' },

    'import/itemgroup/xml'                              => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'import_itemgroup_xml_gadmin' },

    'itemgroup/:groupid/remove/item/:itemid'            => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'remove_item_from_group_gadmin' },

    'add/itemgroup'                                     => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'add_itemgroup_gadmin' },

    'update/itemgroup/:id'                              => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'update_itemgroup_gadmin' },

    'delete/itemgroup/:id'                              => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'del_itemgroup_gadmin' },

    'get/itemgroup/:id'                                 => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'get_itemgroup' },

    'list/itemgroup/:nperpage/page/:num'                => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'list_itemgroup_advanced' },

    'add/item'                                          => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'add_item' },

    'update/item/:id'                                   => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'update_item_gadmin' },

    'delete/item/:id'                                   => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'del_item_gadmin' },

    'get/item/:id'                                      => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'get_item' },

    'list/item/:nperpage/page/:num'                     => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'list_item_advanced' },

    'add/type/:class'                                   => { app => 'KDDArT::DAL::VirtualColumn',
                                                             rm  => 'add_general_type_gadmin' },

    'list/type/:class/:status'                          => { app => 'KDDArT::DAL::VirtualColumn',
                                                             rm  => 'list_general_type' },

    'get/type/:class/:id'                               => { app => 'KDDArT::DAL::VirtualColumn',
                                                             rm  => 'get_general_type' },

    'update/type/:class/:id'                            => { app => 'KDDArT::DAL::VirtualColumn',
                                                             rm  => 'update_general_type_gadmin' },

    'delete/type/:class/:id'                            => { app => 'KDDArT::DAL::VirtualColumn',
                                                             rm  => 'del_general_type_gadmin' },

    'get/version'                                       => { app => 'KDDArT::DAL::System',
                                                             rm  => 'get_version' },

    'trial/:trialid/add/trialevent'                     => { app => 'KDDArT::DAL::TrialEvent',
                                                             rm  => 'add_trialevent' },

    'trial/:trialid/list/trialevent'                    => { app => 'KDDArT::DAL::TrialEvent',
                                                             rm  => 'list_trialevent' },

    'list/trialevent'                                   => { app => 'KDDArT::DAL::TrialEvent',
                                                             rm  => 'list_trialevent' },

    'update/trialevent/:id'                             => { app => 'KDDArT::DAL::TrialEvent',
                                                             rm  => 'update_trialevent' },

    'delete/trialevent/:id'                             => { app => 'KDDArT::DAL::TrialEvent',
                                                             rm  => 'del_trialevent' },

    'get/trialevent/:id'                                => { app => 'KDDArT::DAL::TrialEvent',
                                                             rm  => 'get_trialevent' },

    'add/genpedigree'                                   => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'add_genpedigree' },

    'genotype/:genoid/list/ancestor'                    => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'list_gen_ancestor' },

    'genotype/:genoid/list/descendant'                  => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'list_gen_descendant' },

    'add/barcodeconf'                                   => { app => 'KDDArT::DAL::System',
                                                             rm  => 'add_barcodeconf_gadmin' },

    'list/barcodeconf'                                  => { app => 'KDDArT::DAL::System',
                                                             rm  => 'list_barcodeconf' },

    'get/barcodeconf/:id'                               => { app => 'KDDArT::DAL::System',
                                                             rm  => 'get_barcodeconf' },

    ':tablename/:recid/add/multimedia'                  => { app => 'KDDArT::DAL::System',
                                                             rm  => 'add_multimedia' },

    ':tablename/:recid/list/multimedia'                 => { app => 'KDDArT::DAL::System',
                                                             rm  => 'list_multimedia' },

    'help'                                              => { app => 'KDDArT::DAL::Help',
                                                             rm  => 'help' }

  ],
);
