#!/usr/bin/perl -w

#$Id$
#$Author$

# Copyright (c) 2011, Diversity Arrays Technology, All rights reserved.

# Author    : Puthick Hok
# Created   : 02/06/2010
# Modified  :
# Purpose   :
#
#

use strict;
use warnings;

BEGIN {
  use File::Spec;

  my ($volume, $current_dir, $file) = File::Spec->splitpath(__FILE__);

  my @current_dir_part = split('/perl-lib/KDDArT/DAL/', $current_dir);
  $main::kddart_base_dir = $current_dir_part[0];
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

    'clone/session'                                     => { app => 'KDDArT::DAL::Authentication',
                                                             rm  => 'clone' },

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

    'contact/:id/update/geography'                      => { app => 'KDDArT::DAL::Contact',
                                                             rm  => 'update_contact_geography' },

    'add/user'                                          => { app => 'KDDArT::DAL::System',
                                                             rm  => 'add_user_gadmin' },

    'update/user/:username'                             => { app => 'KDDArT::DAL::System',
                                                             rm  => 'update_user_gadmin' },

    'list/user'                                         => { app => 'KDDArT::DAL::System',
                                                             rm  => 'list_user_gadmin' },

    'get/user/:id'                                      => { app => 'KDDArT::DAL::System',
                                                             rm  => 'get_user' },

    'user/:username/change/password'                    => { app => 'KDDArT::DAL::System',
                                                             rm  => 'change_user_password' },

    'add/group'                                         => { app => 'KDDArT::DAL::System',
                                                             rm  => 'add_group_gadmin' },

    'group/:id/add/member/:username'                    => { app => 'KDDArT::DAL::System',
                                                             rm  => 'add_group_member_gadmin' },

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

    'update/group/:id'                                  => { app => 'KDDArT::DAL::System',
                                                             rm  => 'update_group_gadmin' },

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

    'delete/layer/:id'                                  => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'del_layer_gadmin' },

    'add/layer/n/attribute'                             => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'add_layer_n_attrib' },

    ':tname/get/dtd'                                    => { app => 'KDDArT::DAL::VirtualColumn',
                                                             rm  => 'get_dtd' },

    'register/device'                                   => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'register_device_gadmin' },

    'update/deviceregistration/:id'                     => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'update_device_registration_gadmin' },

    'delete/deviceregistration/:id'                     => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'del_device_registration_gadmin' },

    'list/deviceregistration'                           => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'list_dev_registration_full' },

    'map/deviceparameter'                               => { app => 'KDDArT::DAL::Environment',
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

    'update/layerattrib/:id'                            => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'update_layer_attribute' },

    'delete/layerattrib/:id'                            => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'del_layer_attribute_gadmin' },

    'layer/:id/export/shp'                              => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'export_layer_data_shape' },

    'layer/:id/list/data/:nperpage/page/:num'           => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'list_layer_data_advanced' },

    'layer/:id/add/data'                                => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'add_layer_data' },

    'layer/:id/update/data'                             => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'update_layer_data_gadmin' },

    'layer/:id/delete/data'                             => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'del_layer_data_gadmin' },

    'layer/:id/import/csv'                              => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'import_layer_data_csv' },

    'layer2d/:id/add/data'                              => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'add_layer2d_data' },

    'layer2d/:layerid/update/data/:recid'               => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'update_layer2d_data' },

    'layer2d/:layerid/list/data/:nperpage/page/:num'    => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'list_layer2d_data_advanced' },

    'layer2d/:layerid/get/data/:recid'                  => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'get_layer2d_data' },

    'layer2d/:layerid/delete/data/:recid'               => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'del_layer2d_data_gadmin' },

    'add/tileset/:id'                                   => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'add_tileset' },

    'get/tileset/:id'                                   => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'get_tileset' },

    'update/tileset/:id'                                => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'update_tileset' },

    'tileset/:id/get/tile/:z/:x/:y'                     => { app => 'KDDArT::DAL::Environment',
                                                             rm  => 'get_tile' },

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

    'delete/genotypealias/:id'                          => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'delete_genotype_alias' },

    'get/genotypealias/:id'                             => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'get_genotype_alias' },

    'add/taxonomy'                                      => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'add_taxonomy' },

    'get/taxonomy/:id'                                  => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'get_taxonomy' },

    'update/taxonomy/:id'                               => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'update_taxonomy' },

    'delete/taxonomy/:id'                               => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'del_taxonomy_gadmin' },

    'list/taxonomy'                                     => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'list_taxonomy' },

    'taxonomy/:taxonomyid/list/ancestor'                => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'list_taxonomy_ancestor' },

    'add/genus'                                         => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'add_genus_gadmin' },

    'genotype/:id/add/trait'                            => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'add_trait2genotype' },

    'update/genotypetrait/:genotraitid'                 => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'update_genotype_trait' },

    'get/genotypetrait/:genotraitid'                    => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'get_genotype_trait' },

    'list/genotypetrait/:nperpage/page/:num'            => { app => 'KDDArT::DAL::Genotype',
                                                              rm  => 'list_genotype_trait' },

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

    'specimen/:id/update/geography'                     => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'update_specimen_geography' },

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

    'trial/:id/add/workflow'                            => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'add_trial_workflow' },

    'update/trialworkflow/:id'                          => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'update_trial_workflow' },

    'trial/:id/list/workflow'                           => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'list_trial_workflow' },

    'get/trialworkflow/:id'                             => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'get_trial_workflow' },

    'delete/trialworkflow/:id'                          => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'del_trial_workflow_gadmin' },

    'trial/:id/add/trialunit'                           => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'add_trial_unit' },

    'trial/:id/add/trialunit/bulk'                      => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'add_trial_unit_bulk' },

    'trial/:id/update/trialunit/bulk'                   => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'update_trial_unit_bulk' },

    'trial/:id/add/trait'                               => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'add_trial_trait' },

    'trial/:id/add/dimension'                           => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'add_trial_dimension' },

    'trial/:id/list/trait'                              => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'list_trial_trait' },

    'add/traitgroup'                                    => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'add_traitgroup' },

    'update/traitgroup/:id'                             => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'update_traitgroup' },

    'list/traitgroup/:nperpage/page/:num'               => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'list_traitgroup_advanced' },

    'get/traitgroup/:id'                                => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'get_traitgroup' },

    'traitgroup/:id/add/trait'                          => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'add_trait2traitgroup' },

    'traitgroup/:id/remove/trait/:tid'                  => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'remove_trait_from_traitgroup' },

    'delete/traitgroup/:id'                             => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'del_traitgroup' },

    'trial/:id/list/dimension'                          => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'list_trial_dimension' },

    'add/trialgroup'                                    => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'add_trialgroup' },

    'update/trialgroup/:id'                             => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'update_trialgroup' },

    'list/trialgroup/:nperpage/page/:num'               => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'list_trialgroup_advanced' },

    'get/trialgroup/:id'                                => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'get_trialgroup' },

    'delete/trialgroup/:id'                             => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'del_trialgroup' },

    'trialgroup/:id/add/trial'                          => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'add_trial2trialgroup' },

    'trialgroup/:id/remove/trial/:tid'                  => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'remove_trial_from_trialgroup' },

    'trial/:id/export/datakapturetemplate'              => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'export_datakapture_template' },

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

    'get/trialdimension/:id'                            => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'get_trial_dimension' },

    'update/trialdimension/:id'                         => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'update_trial_dimension' },

    'delete/trialdimension/:id'                         => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'del_trial_dimension_gadmin' },

    'trial/:trialid/remove/trait/:traitid'              => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'remove_trial_trait' },

    'delete/trialunit/:id'                              => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'del_trial_unit_gadmin' },

    'delete/crossing/:id'                              => { app => 'KDDArT::DAL::Trial',
                                                          rm  => 'del_trial_crossing_gadmin' },

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

    'trialunit/:id/add/treatment'                       => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'add_trialunit_treatment' },

    'get/trialunittreatment/:id'                        => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'get_trialunit_treatment' },

    'delete/trialunittreatment/:id'                     => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'remove_trialunit_treatment' },

    'update/trialunittreatment/:id'                     => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'update_trialunit_treatment' },

    'list/trialunitspecimen/:nperpage/page/:num'        => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'list_trial_unit_specimen_advanced' },

    'get/trialunitspecimen/:id'                         => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'get_trial_unit_specimen' },

    'trialunit/:id/add/specimen'                        => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'add_trial_unit_specimen' },

    'delete/trialunitspecimen/:id'                      => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'delete_trial_unit_specimen' },

    'remove/trialunitspecimen/:id'                      => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'delete_trial_unit_specimen' },


    'update/trialunitspecimen/:id'                      => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'update_trial_unit_specimen' },

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

    'trial/:id/import/smgroupdata/csv'                  => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'import_smgroup_data_csv' },

    'trial/:id/list/smgroup'                            => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'list_smgroup' },

    'get/smgroup/:id'                                   => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'get_smgroup' },

    'update/smgroup/:id'                                => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'update_smgroup' },

    'delete/smgroup/:id'                                => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'del_smgroup' },

    'list/samplemeasurement/:nperpage/page/:num'        => { app => 'KDDArT::DAL::Trait',
                                                             rm  => 'list_samplemeasurement_advanced' },

    'add/plate'                                         => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'add_plate_gadmin' },

    'add/plate/n/extract'                               => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'add_plate_n_extract_gadmin' },

    'import/plate/n/extract/xml'                        => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'import_plate_n_extract_gadmin' },

    'update/analysisgroup/:id'                          => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'update_analysisgroup' },

    'add/analysisgroup'                                 => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'add_analysisgroup' },

    'add/extract'                                       => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'add_extract_gadmin' },

    'update/extract/:id'                                => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'update_extract_gadmin' },

    'analysisgroup/:id/add/extract'                     => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'add_extract_analgroup' },

    'analysisgroup/:id/import/markerdata/csv'           => { app => 'KDDArT::DAL::Marker',
                                                             rm  => 'import_markerdata_dart' },

    'dataset/:id/append/markerdata/csv'                 => { app => 'KDDArT::DAL::Marker',
                                                             rm  => 'append_markerdata_csv' },

    'analysisgroup/:id/export/markerdata/csv'           => { app => 'KDDArT::DAL::Marker',
                                                             rm  => 'export_marker_dart' },

    'dataset/:datasetid/export/markerdata/csv'          => { app => 'KDDArT::DAL::Marker',
                                                             rm  => 'export_marker_dart' },

    'analysisgroup/:id/list/markermetafield'            => { app => 'KDDArT::DAL::Marker',
                                                             rm  => 'list_marker_meta_field' },

    'dataset/:dsid/list/markermetafield'                => { app => 'KDDArT::DAL::Marker',
                                                             rm  => 'list_marker_meta_field' },

    'analysisgroup/:analid/list/extract'                => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'list_extract_advanced' },

    'analgroupextract/:id/add/extractdata'              => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'add_extractdata' },

    'analgroupextract/:id/list/extractdata'             => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'list_extractdata' },

    'get/extractdata/:id'                               => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'get_extractdata' },

    #'update/extractdata/:id'                           => { app => 'KDDArT::DAL::Extract',
    #                                                         rm  => 'update_extractdata' },
    # To come in 2.7.3

    'delete/extractdata/:id'                           => { app => 'KDDArT::DAL::Extract',
                                                            rm  => 'delete_extractdata' },

    #'delete/extractdatafile/:id'                       => { app => 'KDDArT::DAL::Extract',
    #                                                        rm  => 'delete_extractdatafile' },
    # TO come in 2.7.3

    #'update/extractdatafile/:id'                       => { app => 'KDDArT::DAL::Extract',
    #                                                        rm  => 'update_extractdatafile' },
    # TO come in 2.7.3


    'extractdata/:id/add/datafile'                      => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'add_extractdata_file' },


    #'get/extractdatafile/:id'                           => { app => 'KDDArT::DAL::Extract',
    #                                                         rm  => 'get_extractdata_file' },
    # to come in 2.7.3

    'analgroupextract/:id/list/extractdatafile'         => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'list_extractdata_file' },

    'list/extract/:nperpage/page/:num'                  => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'list_extract_advanced' },

    'plate/:plateid/list/extract'                       => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'list_extract_advanced' },

    'dataset/:dsid/list/extract'                        => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'list_extract_advanced' },

    'analysisgroup/:analid/list/marker/:nperpage/page/:num' => { app => 'KDDArT::DAL::Marker',
                                                                 rm  => 'list_marker' },

    'dataset/:dsid/list/marker/:nperpage/page/:num'     => { app => 'KDDArT::DAL::Marker',
                                                             rm  => 'list_marker' },

    'analysisgroup/:analid/get/marker/:id'              => { app => 'KDDArT::DAL::Marker',
                                                             rm  => 'get_marker' },

    'dataset/:dsid/get/marker/:id'                      => { app => 'KDDArT::DAL::Marker',
                                                             rm  => 'get_marker' },

    'analysisgroup/:analid/list/markerdata/:nperpage/page/:num/n/:nperblock/block/:bnum' => { app => 'KDDArT::DAL::Marker',
                                                                                              rm  => 'list_marker_data' },

    'dataset/:dsid/list/markerdata/:nperpage/page/:num/n/:nperblock/block/:bnum' => { app => 'KDDArT::DAL::Marker',
                                                                                      rm  => 'list_marker_data' },

    'analysisgroup/:id/list/dataset'                    => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'list_dataset' },

    'add/markermap'                                     => { app => 'KDDArT::DAL::Marker',
                                                             rm  => 'add_markermap_gadmin' },

    'update/markermap/:id'                              => { app => 'KDDArT::DAL::Marker',
                                                             rm  => 'update_markermap_gadmin' },

    'list/markermap'                                    => { app => 'KDDArT::DAL::Marker',
                                                             rm  => 'list_markermap' },

    'get/markermap/:id'                                 => { app => 'KDDArT::DAL::Marker',
                                                             rm  => 'get_markermap' },

    'markermap/:mrkmapid/import/mapposition/csv'        => { app => 'KDDArT::DAL::Marker',
                                                             rm  => 'import_markermap_position_gadmin' },

    'markermap/:mrkmapid/export/mapposition/csv'        => { app => 'KDDArT::DAL::Marker',
                                                             rm  => 'export_markermap_position_gadmin' },

    'markermap/:mrkmapid/import/mapposition/dataset/:dsid' => { app => 'KDDArT::DAL::Marker',
                                                                rm  => 'import_markermap_position_dataset_gadmin' },

    'markermap/:mrkmapid/list/mapposition/:nperpage/page/:num'        => { app => 'KDDArT::DAL::Marker',
                                                                           rm  => 'list_markermap_position_advanced' },

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

    'delete/extract/:id'                                => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'del_extract_gadmin' },

    'delete/analysisgroup/:id'                          => { app => 'KDDArT::DAL::Extract',
                                                             rm  => 'del_analysisgroup_gadmin' },

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

    'storage/:id/update/geography'                      => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'update_storage_geography' },

    'add/generalunit'                                   => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'add_generalunit_gadmin' },

    'delete/generalunit/:id'                            => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'del_generalunit_gadmin' },

    'update/generalunit/:id'                            => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'update_generalunit_gadmin' },

    'get/generalunit/:id'                               => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'get_generalunit' },

    'list/generalunit/:nperpage/page/:num'              => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'list_generalunit_advanced' },

    'generalunit/:id/add/conversionrule'                => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'add_conversionrule_gadmin' },

    'delete/conversionrule/:id'                         => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'del_conversionrule_gadmin' },

    'update/conversionrule/:id'                         => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'update_conversionrule_gadmin' },

    'list/conversionrule'                               => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'list_conversionrule' },

    'get/conversionrule/:id'                            => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'get_conversionrule' },

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

    'update/itembulk/json'                              => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'update_item_bulk_gadmin' },

    'delete/item/:id'                                   => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'del_item_gadmin' },

    'get/item/:id'                                      => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'get_item' },

    'import/item/csv'                                   => { app => 'KDDArT::DAL::Inventory',
                                                             rm  => 'import_item_csv_gadmin' },

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

    'get/version'                                       => { app => 'KDDArT::DAL::Help',
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
                                                             rm  => 'del_trialevent_gadmin' },

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

    'get/multimedia/:id'                                => { app => 'KDDArT::DAL::System',
                                                             rm  => 'get_multimedia' },

    'update/multimedia/:id'                             => { app => 'KDDArT::DAL::System',
                                                             rm  => 'update_multimedia' },

    'delete/multimedia/:id'                             => { app => 'KDDArT::DAL::System',
                                                             rm  => 'del_multimedia_gadmin' },

    'help'                                              => { app => 'KDDArT::DAL::Help',
                                                             rm  => 'help' },

    ':tname/countgroupby/:nperpage/page/:num'           => { app => 'KDDArT::DAL::VirtualColumn',
                                                             rm  => 'count_groupby' },

    'add/workflow'                                      => { app => 'KDDArT::DAL::System',
                                                             rm  => 'add_workflow_gadmin' },

    'update/workflow/:id'                               => { app => 'KDDArT::DAL::System',
                                                             rm  => 'update_workflow_gadmin' },

    'delete/workflow/:id'                               => { app => 'KDDArT::DAL::System',
                                                             rm  => 'del_workflow_gadmin' },

    'list/workflow'                                     => { app => 'KDDArT::DAL::System',
                                                             rm  => 'list_workflow' },

    'get/workflow/:id'                                  => { app => 'KDDArT::DAL::System',
                                                             rm  => 'get_workflow' },

    'workflow/:id/add/definition'                       => { app => 'KDDArT::DAL::System',
                                                             rm  => 'add_workflow_def_gadmin' },

    'update/workflowdef/:id'                            => { app => 'KDDArT::DAL::System',
                                                             rm  => 'update_workflow_def_gadmin' },

    'workflow/:id/list/definition'                      => { app => 'KDDArT::DAL::System',
                                                             rm  => 'list_workflow_def' },

    'get/workflowdef/:id'                               => { app => 'KDDArT::DAL::System',
                                                             rm  => 'get_workflow_def' },

    'delete/workflowdef/:id'                            => { app => 'KDDArT::DAL::System',
                                                             rm  => 'del_workflow_def_gadmin' },

    'get/userpreference'                                => { app => 'KDDArT::DAL::System',
                                                             rm  => 'get_user_preference' },

    'update/userpreference'                             => { app => 'KDDArT::DAL::System',
                                                             rm  => 'update_user_preference' },

    'oauth2google'                                      => { app => 'KDDArT::DAL::Authentication',
                                                             rm  => 'oauth2_google' },

    'add/keyword'                                       => { app => 'KDDArT::DAL::System',
                                                             rm  => 'add_keyword_gadmin' },

    'update/keyword/:id'                                => { app => 'KDDArT::DAL::System',
                                                             rm  => 'update_keyword_gadmin' },

    'list/keyword/:nperpage/page/:num'                  => { app => 'KDDArT::DAL::System',
                                                             rm  => 'list_keyword_advanced' },

    'get/keyword/:id'                                   => { app => 'KDDArT::DAL::System',
                                                             rm  => 'get_keyword' },

    'delete/keyword/:id'                                => { app => 'KDDArT::DAL::System',
                                                             rm  => 'del_keyword_gadmin' },

    'add/keywordgroup'                                  => { app => 'KDDArT::DAL::System',
                                                             rm  => 'add_keyword_group_gadmin' },

    'update/keywordgroup/:id'                           => { app => 'KDDArT::DAL::System',
                                                             rm  => 'update_keyword_group_gadmin' },

    'list/keywordgroup/:nperpage/page/:num'             => { app => 'KDDArT::DAL::System',
                                                             rm  => 'list_keyword_group_advanced' },

    'get/keywordgroup/:id'                              => { app => 'KDDArT::DAL::System',
                                                             rm  => 'get_keyword_group' },

    'keywordgroup/:id/add/keyword/bulk'                 => { app => 'KDDArT::DAL::System',
                                                             rm  => 'add_keyword2group_bulk_gadmin' },

    'keywordgroup/:id/list/keyword'                     => { app => 'KDDArT::DAL::System',
                                                             rm  => 'list_keyword_in_group' },

    'keywordgroup/:id/remove/keyword/:kwdid'            => { app => 'KDDArT::DAL::System',
                                                             rm  => 'remove_keyword_from_group_gadmin' },

    'delete/keywordgroup/:id'                           => { app => 'KDDArT::DAL::System',
                                                             rm  => 'del_keyword_group_gadmin' },

    'import/trialunitkeyword/csv'                       => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'import_trialunitkeyword_csv' },

    'trialunit/:id/list/keyword/:nperpage/page/:num'    => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'list_trialunit_keyword_advanced' },

    'trialunit/:id/list/keyword'                        => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'list_trialunit_keyword_advanced' },

    'list/trialunitkeyword/:nperpage/page/:num'         => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'list_trialunit_keyword_advanced' },

    'trialunit/:id/add/keyword'                         => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'add_trial_unit_keyword' },

    'remove/trialunitkeyword/:id'                       => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'remove_trial_unit_keyword' },

    'specimen/:id/add/keyword'                          => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'add_keyword_to_specimen' },

    'specimen/:id/list/keyword/:nperpage/page/:num'     => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'list_specimen_keyword_advanced' },

    'specimen/:id/list/keyword'                         => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'list_specimen_keyword_advanced' },

    'list/specimenkeyword/:nperpage/page/:num'          => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'list_specimen_keyword_advanced' },

    'remove/specimenkeyword/:id'                        => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'remove_specimen_keyword' },

    'import/genpedigree/csv'                            => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'import_genpedigree_csv' },

    'export/genpedigree'                                => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'export_genpedigree' },

    'update/genpedigree/:id'                            => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'update_genpedigree_gadmin' },

    'delete/genpedigree/:id'                            => { app => 'KDDArT::DAL::Genotype',
                                                             rm  => 'del_genpedigree_gadmin' },

    'list/extractmarkerdata/:nperpage/page/:num/n/:nperblock/block/:bnum' => { app => 'KDDArT::DAL::Marker',
                                                                               rm  => 'list_extract_marker_data' },

    'search/:core/:nperpage/page/:num'                  => { app => 'KDDArT::DAL::Search',
                                                             rm  => 'search_solr' },

    'import/crossing/csv'                               => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'import_crossing_csv' },

    'trial/:trialid/list/crossing'                      => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'list_crossing_advanced' },

    'trial/:id/add/crossing'                            => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'add_crossing' },

    'update/crossing/:id'                               => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'update_crossing' },

    'get/crossing/:id'                                  => { app => 'KDDArT::DAL::Trial',
                                                             rm  => 'get_crossing' },

    'user/:username/request/passwordreset'              => { app => 'KDDArT::DAL::System',
                                                             rm  => 'request_reset_password'},

    'user/:username/execute/passwordreset'              => { app => 'KDDArT::DAL::Authentication',
                                                             rm  => 'execute_reset_password'},

    'list/solrcore'                                     => { app => 'KDDArT::DAL::Search',
                                                             rm  => 'list_solr_core' },

    'solrcore/:core/list/entity'                        => { app => 'KDDArT::DAL::Search',
                                                             rm  => 'list_solr_entity' },

    'get/uniquenumber'                                  => { app => 'KDDArT::DAL::System',
                                                             rm  => 'get_unique_number' },

    'get/config'                                        => { app => 'KDDArT::DAL::Help',
                                                             rm  => 'get_config' },

    'update/nurserytypelistcsv'                         => { app => 'KDDArT::DAL::System',
                                                             rm  => 'update_nursery_type_list_csv_gadmin' },

    'update/genotypeconfig'                             => { app => 'KDDArT::DAL::System',
                                                             rm  => 'update_genotype_config_gadmin' },

    'add/survey'                                        => { app => 'KDDArT::DAL::Survey',
                                                             rm  => 'add_survey' },

    'get/survey/:id'                                    => { app => 'KDDArT::DAL::Survey',
                                                             rm  => 'get_survey' },

    'update/survey/:id'                                 => { app => 'KDDArT::DAL::Survey',
                                                             rm  => 'update_survey' },

    'delete/survey/:id'                                 => { app => 'KDDArT::DAL::Survey',
                                                             rm  => 'delete_survey' },

    'list/survey/:nperpage/page/:num'                    => { app => 'KDDArT::DAL::Survey',
                                                             rm  => 'list_survey_advanced' },

    'survey/:id/add/trialunit'                          => { app => 'KDDArT::DAL::Survey',
                                                             rm  => 'add_survey_trial_unit' },

    'survey/:id/add/trialunit/bulk'                     => { app => 'KDDArT::DAL::Survey',
                                                             rm  => 'add_survey_trial_unit_bulk' },

    'survey/:id/add/trait'                              => { app => 'KDDArT::DAL::Survey',
                                                             rm  => 'add_survey_trait' },

    'survey/:id/list/trait'                             => { app => 'KDDArT::DAL::Survey',
                                                             rm  => 'list_survey_trait' },

    'get/surveytrait/:id'                               => { app => 'KDDArT::DAL::Survey',
                                                             rm  => 'get_survey_trait' },

    'get/surveytrialunit/:id'                           => { app => 'KDDArT::DAL::Survey',
                                                             rm  => 'get_survey_trial_unit' },

    'survey/:id/list/trialunit'                         => { app => 'KDDArT::DAL::Survey',
                                                             rm  => 'list_survey_trial_unit' },

    'update/surveytrialunit/:id'                        => { app => 'KDDArT::DAL::Survey',
                                                             rm  => 'update_survey_trial_unit' },

    'delete/surveytrialunit/:id'                        => { app => 'KDDArT::DAL::Survey',
                                                             rm  => 'delete_survey_trial_unit' },

    'survey/:id/update/geography'                       => { app => 'KDDArT::DAL::Survey',
                                                             rm  => 'update_survey_geography' },

    'survey/:surveyid/delete/trait/:traitid'            => { app => 'KDDArT::DAL::Survey',
                                                             rm  => 'delete_survey_trait' },

    'update/surveytrait/:id'                            => { app => 'KDDArT::DAL::Survey',
                                                             rm  => 'update_survey_trait' },

  ],
);
