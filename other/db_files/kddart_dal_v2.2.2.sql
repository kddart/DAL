-- MySQL dump 10.11
--
-- Host: localhost    Database: kddart_v2_2_2
-- ------------------------------------------------------
-- Server version	5.0.67

-- Copyright (C) 2014 by Diversity Arrays Technology Pty Ltd
-- 
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `activitylog`
--

DROP TABLE IF EXISTS `activitylog`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `activitylog` (
  `ActivityLogId` int(11) NOT NULL auto_increment COMMENT 'activity log id',
  `UserId` int(11) NOT NULL COMMENT 'user id',
  `ActivityDateTime` datetime NOT NULL COMMENT 'date time of the activity',
  `ActivityLevel` int(10) NOT NULL COMMENT 'Logout=2,Incorrect Password=3, Edit=101,Delete=102',
  `ActivityText` varchar(254) NOT NULL COMMENT 'description of activity',
  PRIMARY KEY  (`ActivityLogId`),
  KEY `xal_UserId` (`UserId`),
  CONSTRAINT `activitylog_ibfk_1` FOREIGN KEY (`UserId`) REFERENCES `systemuser` (`UserId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `authorisedsystemgroup`
--

DROP TABLE IF EXISTS `authorisedsystemgroup`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `authorisedsystemgroup` (
  `AuthorisedSystemGroupId` int(11) NOT NULL auto_increment COMMENT 'authorised system group id',
  `UserId` int(11) NOT NULL COMMENT 'user id',
  `SystemGroupId` int(11) NOT NULL COMMENT 'system group id',
  `IsGroupOwner` tinyint(4) NOT NULL COMMENT 'flag [0|1] if the user group owner.',
  PRIMARY KEY  (`AuthorisedSystemGroupId`),
  KEY `xasg_UserId` (`UserId`),
  KEY `xasg_SystemGroupId` (`SystemGroupId`),
  KEY `xasg_IsGroupOwner` (`IsGroupOwner`),
  CONSTRAINT `authorisedsystemgroup_ibfk_1` FOREIGN KEY (`SystemGroupId`) REFERENCES `systemgroup` (`SystemGroupId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `authorisedsystemgroup_ibfk_2` FOREIGN KEY (`UserId`) REFERENCES `systemuser` (`UserId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `barcodeconf`
--

DROP TABLE IF EXISTS `barcodeconf`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `barcodeconf` (
  `BarcodeConfId` int(11) NOT NULL auto_increment COMMENT 'configuration id',
  `SystemTable` varchar(32) NOT NULL COMMENT 'configuration is for this table in the system',
  `SystemField` varchar(32) NOT NULL COMMENT 'configuration is for this field (in the SystemTable)',
  `BarcodeCode` varchar(12) NOT NULL COMMENT 'Name of barcode system (e.g. EAN13, Code39, QR, etc)',
  `BarcodeDef` mediumtext NOT NULL COMMENT 'String with barcode definition',
  PRIMARY KEY  (`BarcodeConfId`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `breedingmethod`
--

DROP TABLE IF EXISTS `breedingmethod`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `breedingmethod` (
  `BreedingMethodId` int(11) NOT NULL auto_increment COMMENT 'internal id',
  `BreedingMethodName` varchar(100) NOT NULL COMMENT 'breeding method name',
  `BreedingMethodNote` mediumtext COMMENT 'breeding method short description',
  PRIMARY KEY  (`BreedingMethodId`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `breedingmethodfactor`
--

DROP TABLE IF EXISTS `breedingmethodfactor`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `breedingmethodfactor` (
  `BreedingMethodId` int(11) NOT NULL COMMENT 'Breeding method id',
  `FactorId` int(11) NOT NULL COMMENT 'Factor id',
  `FactorValue` varchar(254) NOT NULL COMMENT 'Value of the virtual column for Breeding Method',
  PRIMARY KEY  (`BreedingMethodId`,`FactorId`),
  KEY `FactorId` (`FactorId`),
  CONSTRAINT `breedingmethodfactor_ibfk_1` FOREIGN KEY (`FactorId`) REFERENCES `factor` (`FactorId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `breedingmethodfactor_ibfk_2` FOREIGN KEY (`BreedingMethodId`) REFERENCES `breedingmethod` (`BreedingMethodId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `contact`
--

DROP TABLE IF EXISTS `contact`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `contact` (
  `ContactId` int(11) NOT NULL auto_increment COMMENT 'contact id',
  `ContactLastName` varchar(64) NOT NULL COMMENT 'last name',
  `ContactFirstName` varchar(32) NOT NULL COMMENT 'first name',
  `ContactAcronym` varchar(32) default NULL COMMENT 'acronym',
  `ContactAddress` varchar(128) default NULL COMMENT 'address',
  `ContactTelephone` varchar(14) default NULL COMMENT 'phone number',
  `ContactMobile` varchar(14) default NULL COMMENT 'mobile number',
  `ContactEMail` varchar(255) default NULL COMMENT 'e-mail',
  `OrganisationId` int(11) NOT NULL COMMENT 'organisation id',
  PRIMARY KEY  (`ContactId`),
  KEY `xc_LastFirstName` (`ContactLastName`,`ContactFirstName`),
  KEY `xc_OrganisationId` (`OrganisationId`),
  KEY `xc_ContactEMail` (`ContactEMail`),
  CONSTRAINT `contact_ibfk_1` FOREIGN KEY (`OrganisationId`) REFERENCES `organisation` (`OrganisationId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `contactfactor`
--

DROP TABLE IF EXISTS `contactfactor`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `contactfactor` (
  `ContactId` int(11) NOT NULL COMMENT 'contact id',
  `FactorId` int(11) NOT NULL COMMENT 'factor id',
  `FactorValue` varchar(255) NOT NULL COMMENT 'value',
  PRIMARY KEY  (`ContactId`,`FactorId`),
  KEY `FactorId` (`FactorId`),
  CONSTRAINT `contactfactor_ibfk_1` FOREIGN KEY (`ContactId`) REFERENCES `contact` (`ContactId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `contactfactor_ibfk_2` FOREIGN KEY (`FactorId`) REFERENCES `factor` (`FactorId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `designtype`
--

DROP TABLE IF EXISTS `designtype`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `designtype` (
  `DesignTypeId` int(11) NOT NULL auto_increment COMMENT 'design type id',
  `DesignTypeName` varchar(32) NOT NULL COMMENT 'design type name',
  `DesignSoftware` varchar(255) default NULL COMMENT 'The executable file of the Software (such as DiGGer) that is used to design the trial of this design type.',
  `DesignTemplateFile` varchar(255) default NULL COMMENT 'The template file defines how the parameter are required to be inserted in the input file for the design software.',
  `DesignGenotypeFormat` varchar(32) default NULL COMMENT 'Format in which the Specimen Name and Specimen Id will be exported into the trial design input file.',
  `DesignFactorAliasPrefix` varchar(16) default NULL COMMENT 'Prefix that will be used to find the factor for the Trial Design Parameter while importing trial design from the output file generated by the trial design software (such as DiGGer).',
  PRIMARY KEY  (`DesignTypeId`),
  UNIQUE KEY `xdt_DesignTypeName` (`DesignTypeName`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `deviceregister`
--

DROP TABLE IF EXISTS `deviceregister`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `deviceregister` (
  `DeviceRegisterId` int(11) NOT NULL auto_increment COMMENT 'Internal id',
  `DeviceTypeId` int(11) NOT NULL COMMENT 'device type id',
  `DeviceId` varchar(100) NOT NULL COMMENT 'Unique device name / id under which it is registered in database',
  `DeviceNote` varchar(255) default NULL COMMENT 'Description of the device',
  `Latitude` decimal(16,14) default NULL COMMENT 'Latitude of the device in decimal degrees (-90, 90)',
  `Longitude` decimal(16,13) default NULL COMMENT 'Longitude of the device in decimal degrees (-180, 180)',
  PRIMARY KEY  (`DeviceRegisterId`),
  UNIQUE KEY `xdr_DeviceId` (`DeviceId`),
  KEY `xdr_DeviceTypeId` (`DeviceTypeId`),
  CONSTRAINT `deviceregister_ibfk_1` FOREIGN KEY (`DeviceTypeId`) REFERENCES `generaltype` (`TypeId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `deviceregisterfactor`
--

DROP TABLE IF EXISTS `deviceregisterfactor`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `deviceregisterfactor` (
  `DeviceRegisterId` int(11) NOT NULL COMMENT 'device register id',
  `FactorId` int(11) NOT NULL COMMENT 'virtual column id',
  `FactorValue` varchar(254) NOT NULL COMMENT 'value for column and device id',
  PRIMARY KEY  (`DeviceRegisterId`,`FactorId`),
  KEY `FactorId` (`FactorId`),
  CONSTRAINT `deviceregisterfactor_ibfk_1` FOREIGN KEY (`DeviceRegisterId`) REFERENCES `deviceregister` (`DeviceRegisterId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `deviceregisterfactor_ibfk_2` FOREIGN KEY (`FactorId`) REFERENCES `factor` (`FactorId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `factor`
--

DROP TABLE IF EXISTS `factor`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `factor` (
  `FactorId` int(11) NOT NULL auto_increment COMMENT 'factor id',
  `FactorName` varchar(32) NOT NULL COMMENT 'column name',
  `FactorCaption` varchar(64) default NULL COMMENT 'caption (shorter version of name)',
  `FactorDescription` varchar(255) default NULL COMMENT 'what is stored in the column',
  `TableNameOfFactor` varchar(32) NOT NULL COMMENT 'which main table this factor refers to',
  `FactorDataType` varchar(8) NOT NULL COMMENT 'data type (e.g. VARCHAR)',
  `CanFactorHaveNull` tinyint(1) NOT NULL COMMENT 'can value be null (0|1)',
  `FactorValueMaxLength` int(10) NOT NULL COMMENT 'maximum size of value (e.g. 256) refers to the maximum length of FactorValue is VARCHAR in the factor data table like contactfactor',
  `FactorUnit` varchar(16) default NULL COMMENT 'value unit (e.g. kg, meters, etc)',
  `OwnGroupId` int(11) NOT NULL COMMENT 'the group that owns this virtual column definition',
  `Public` tinyint(4) NOT NULL default '0' COMMENT 'if public=1, it means other group administrators can edit and delete this definition',
  `FactorValidRule` varchar(100) default NULL COMMENT 'factor value validation rule (optional)',
  `FactorValidRuleErrMsg` varchar(254) default NULL COMMENT 'error message if value does not conform to validation rule',
  PRIMARY KEY  (`FactorId`),
  KEY `xf_FactorName` (`FactorName`),
  KEY `xf_FactorCaption` (`FactorCaption`),
  KEY `xf_TableNameOfFactor` (`TableNameOfFactor`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `factoralias`
--

DROP TABLE IF EXISTS `factoralias`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `factoralias` (
  `FactorAliasId` int(11) NOT NULL auto_increment COMMENT 'factoralias id',
  `FactorAliasName` varchar(64) NOT NULL COMMENT 'alternative name of the factor',
  `FactorId` int(11) NOT NULL COMMENT 'factor id',
  PRIMARY KEY  (`FactorAliasId`),
  KEY `xfa_FactorAliasName` (`FactorAliasName`),
  KEY `xfa_FactorId` (`FactorId`),
  CONSTRAINT `factoralias_ibfk_1` FOREIGN KEY (`FactorId`) REFERENCES `factor` (`FactorId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `generaltype`
--

DROP TABLE IF EXISTS `generaltype`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `generaltype` (
  `TypeId` int(11) NOT NULL auto_increment COMMENT 'general type id',
  `Class` set('site','item','container','deviceregister','trial','trialevent','sample','specimengroup','state','parent','itemparent','genotypespecimen','markerstate','markerquality','workflow','project','itemlog','plate','genmap','multimedia','tissue','genotypealias','genparent','genotypealiasstatus','traitgroup','unittype','multilocation') NOT NULL COMMENT 'class of type - possible values (site, item, container, deviceregister, trial, operation, sample, specimengroup, state, parent, itemparent, genotypespecimen, markerstate, markerquality, workflow, project, itemlog, plate, genmap, multimedia, tissue, genoty',
  `TypeName` varchar(100) NOT NULL COMMENT 'name of the type within notation',
  `TypeNote` varchar(254) default NULL COMMENT 'type description',
  `IsTypeActive` tinyint(1) NOT NULL default '1' COMMENT '0|1 flag to indicate if type is active (can be used)',
  PRIMARY KEY  (`TypeId`),
  UNIQUE KEY `xgt_ClassTypeName` (`Class`,`TypeName`),
  KEY `xgt_TypeName` (`TypeName`),
  KEY `xgt_IsTypeActive` (`IsTypeActive`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `generaltypefactor`
--

DROP TABLE IF EXISTS `generaltypefactor`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `generaltypefactor` (
  `TypeId` int(11) NOT NULL COMMENT 'type id',
  `FactorId` int(11) NOT NULL COMMENT 'virtual column id',
  `FactorValue` varchar(254) NOT NULL COMMENT 'value of the virtual column',
  PRIMARY KEY  (`TypeId`,`FactorId`),
  KEY `FactorId` (`FactorId`),
  CONSTRAINT `generaltypefactor_ibfk_1` FOREIGN KEY (`FactorId`) REFERENCES `factor` (`FactorId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `generaltypefactor_ibfk_2` FOREIGN KEY (`TypeId`) REFERENCES `generaltype` (`TypeId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `genotype`
--

DROP TABLE IF EXISTS `genotype`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `genotype` (
  `GenotypeId` int(11) NOT NULL auto_increment COMMENT 'genotype id',
  `GenotypeName` varchar(255) NOT NULL COMMENT 'genotype name',
  `GenusId` int(11) NOT NULL COMMENT 'genus / organism',
  `SpeciesName` varchar(255) default NULL COMMENT 'name in Latin - common naming conventions should be established - For use when using different species and a trial from another genus',
  `GenotypeAcronym` varchar(32) default NULL COMMENT 'short name of genotype',
  `OriginId` int(10) NOT NULL COMMENT 'Scource Identifier - possible Part of Plant Variety Rights Information - could refer to organisation or contact',
  `CanPublishGenotype` tinyint(1) NOT NULL COMMENT 'flag if publicly available',
  `GenotypeColor` varchar(32) default NULL COMMENT 'Possibly to utilise as Part of Plant Variety Rights Information',
  `GenotypeNote` varchar(6000) default NULL COMMENT 'description',
  `OwnGroupId` int(11) NOT NULL COMMENT 'group id which owns the record',
  `AccessGroupId` int(11) NOT NULL default '0' COMMENT 'group id with access to the record (different than own group)',
  `OwnGroupPerm` tinyint(4) NOT NULL COMMENT 'permission for the own group members',
  `AccessGroupPerm` tinyint(4) NOT NULL default '0' COMMENT 'permission for the other group members',
  `OtherPerm` tinyint(4) NOT NULL default '0' COMMENT 'permission for all the other system users',
  PRIMARY KEY  (`GenotypeId`),
  UNIQUE KEY `xg_GenotypeNameGenusId` (`GenotypeName`,`GenusId`),
  KEY `xg_GenusId` (`GenusId`),
  KEY `xg_OriginId` (`OriginId`),
  KEY `xg_SpeciesName` (`SpeciesName`),
  CONSTRAINT `genotype_ibfk_1` FOREIGN KEY (`GenusId`) REFERENCES `genus` (`GenusId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `genotypealias`
--

DROP TABLE IF EXISTS `genotypealias`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `genotypealias` (
  `GenotypeAliasId` int(11) NOT NULL auto_increment COMMENT 'genotype alias id',
  `GenotypeAliasName` varchar(255) NOT NULL COMMENT 'genotype alias name',
  `GenotypeId` int(11) NOT NULL COMMENT 'genotype id',
  `GenotypeAliasType` int(11) default NULL COMMENT 'genotype alias type from generaltype table class agenotypealiasa',
  `GenotypeAliasStatus` int(11) default NULL COMMENT 'status of the alias (e.g. used, preferred, old, etc)',
  `GenotypeAliasLang` varchar(15) default NULL COMMENT 'language of the genotype alias name',
  PRIMARY KEY  (`GenotypeAliasId`),
  KEY `xga_GenotypeAliasName` (`GenotypeAliasName`),
  KEY `xga_GenotypeId` (`GenotypeId`),
  KEY `xga_GenotypeAliasType` (`GenotypeAliasType`),
  KEY `xga_GenotypeAliasStatus` (`GenotypeAliasStatus`),
  KEY `xga_GenotypeAliasLang` (`GenotypeAliasLang`),
  CONSTRAINT `genotypealias_ibfk_1` FOREIGN KEY (`GenotypeId`) REFERENCES `genotype` (`GenotypeId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `genotypealias_ibfk_2` FOREIGN KEY (`GenotypeAliasType`) REFERENCES `generaltype` (`TypeId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `genotypealias_ibfk_3` FOREIGN KEY (`GenotypeAliasStatus`) REFERENCES `generaltype` (`TypeId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `genotypealiasfactor`
--

DROP TABLE IF EXISTS `genotypealiasfactor`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `genotypealiasfactor` (
  `GenotypeAliasId` int(11) NOT NULL COMMENT 'genotype alias id',
  `FactorId` int(11) NOT NULL COMMENT 'factor id',
  `FactorValue` varchar(255) NOT NULL COMMENT 'factor value',
  PRIMARY KEY  (`GenotypeAliasId`,`FactorId`),
  KEY `FactorId` (`FactorId`),
  CONSTRAINT `genotypealiasfactor_ibfk_1` FOREIGN KEY (`GenotypeAliasId`) REFERENCES `genotypealias` (`GenotypeAliasId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `genotypealiasfactor_ibfk_2` FOREIGN KEY (`FactorId`) REFERENCES `factor` (`FactorId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `genotypefactor`
--

DROP TABLE IF EXISTS `genotypefactor`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `genotypefactor` (
  `GenotypeId` int(11) NOT NULL COMMENT 'genotype id',
  `FactorId` int(11) NOT NULL COMMENT 'factor id',
  `FactorValue` varchar(255) NOT NULL COMMENT 'value',
  PRIMARY KEY  (`GenotypeId`,`FactorId`),
  KEY `FactorId` (`FactorId`),
  CONSTRAINT `genotypefactor_ibfk_1` FOREIGN KEY (`FactorId`) REFERENCES `factor` (`FactorId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `genotypefactor_ibfk_2` FOREIGN KEY (`GenotypeId`) REFERENCES `genotype` (`GenotypeId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `genotypespecimen`
--

DROP TABLE IF EXISTS `genotypespecimen`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `genotypespecimen` (
  `GenotypeSpecimenId` int(11) NOT NULL auto_increment COMMENT 'id of the group of genotype and plant combination',
  `SpecimenId` int(11) NOT NULL COMMENT 'id of the specimen',
  `GenotypeId` int(11) NOT NULL COMMENT 'id of the genotype',
  `GenotypeSpecimenType` int(11) default NULL COMMENT 'relation to type - useful when a few genotypes compose specimen and one is of type scion and the other is rootstock',
  PRIMARY KEY  (`GenotypeSpecimenId`),
  KEY `xgp_genotype` (`GenotypeId`),
  KEY `xgp_specimen` (`SpecimenId`),
  KEY `xgp_gst` (`GenotypeSpecimenType`),
  CONSTRAINT `genotypespecimen_ibfk_1` FOREIGN KEY (`SpecimenId`) REFERENCES `specimen` (`SpecimenId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `genotypespecimen_ibfk_2` FOREIGN KEY (`GenotypeId`) REFERENCES `genotype` (`GenotypeId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `genotypespecimen_ibfk_3` FOREIGN KEY (`GenotypeSpecimenType`) REFERENCES `generaltype` (`TypeId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `genotypetrait`
--

DROP TABLE IF EXISTS `genotypetrait`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `genotypetrait` (
  `GenotypeTraitId` int(10) NOT NULL auto_increment COMMENT 'genotype trait id',
  `GenotypeId` int(11) NOT NULL COMMENT 'genotype id',
  `TraitId` int(11) NOT NULL COMMENT 'trait id',
  `TraitValue` varchar(255) NOT NULL COMMENT 'known trait value, whatever the user specifies it to be, very generic',
  PRIMARY KEY  (`GenotypeTraitId`),
  KEY `xgt_GenotypeId` (`GenotypeId`),
  KEY `xgt_TraitId` (`TraitId`),
  CONSTRAINT `genotypetrait_ibfk_1` FOREIGN KEY (`GenotypeId`) REFERENCES `genotype` (`GenotypeId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `genotypetrait_ibfk_2` FOREIGN KEY (`TraitId`) REFERENCES `trait` (`TraitId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `genpedigree`
--

DROP TABLE IF EXISTS `genpedigree`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `genpedigree` (
  `GenPedigreeId` int(11) NOT NULL auto_increment COMMENT 'GenPedigree id',
  `GenotypeId` int(11) NOT NULL COMMENT 'id of the genotype',
  `ParentGenotypeId` int(11) NOT NULL COMMENT 'id of the parent genotype',
  `GenParentType` int(11) NOT NULL COMMENT 'what is the type of parent (e.g. male, female, self, etc)',
  `NumberOfGenotypes` int(11) default NULL COMMENT 'optional number of parent genotypes perhaps useful to store',
  PRIMARY KEY  (`GenPedigreeId`),
  UNIQUE KEY `xgp_GePaType` (`GenotypeId`,`ParentGenotypeId`,`GenParentType`),
  KEY `xgp_GenotypeId` (`GenotypeId`),
  KEY `xgp_ParentGenotypeId` (`ParentGenotypeId`),
  KEY `xgp_GenParentType` (`GenParentType`),
  CONSTRAINT `genpedigree_ibfk_1` FOREIGN KEY (`ParentGenotypeId`) REFERENCES `genotype` (`GenotypeId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `genpedigree_ibfk_2` FOREIGN KEY (`GenotypeId`) REFERENCES `genotype` (`GenotypeId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `genpedigree_ibfk_3` FOREIGN KEY (`GenParentType`) REFERENCES `generaltype` (`TypeId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `genus`
--

DROP TABLE IF EXISTS `genus`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `genus` (
  `GenusId` int(11) NOT NULL auto_increment COMMENT 'genus id',
  `GenusName` varchar(32) NOT NULL COMMENT 'genus name',
  PRIMARY KEY  (`GenusId`),
  UNIQUE KEY `xg_GenusName` (`GenusName`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `item`
--

DROP TABLE IF EXISTS `item`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `item` (
  `ItemId` int(11) NOT NULL auto_increment COMMENT 'Id of the stored item',
  `TrialUnitSpecimenId` int(11) default NULL COMMENT 'Id of the trial unit specimen - where the item (seeds) were harvested from in the field',
  `ItemSourceId` int(11) default NULL COMMENT 'Id of the contact (who is the external source)',
  `ContainerTypeId` int(11) default NULL COMMENT 'id of the container type',
  `SpecimenId` int(11) NOT NULL COMMENT 'id of the specimen (bit redundant with trial unit specimen, but since this it may not be present then at least specimen info is there)',
  `ScaleId` int(11) default NULL COMMENT 'id of the device used to take measurement',
  `StorageId` int(11) default NULL COMMENT 'id of the storage location',
  `ItemUnitId` int(11) default NULL COMMENT 'unit in which the measurement has been done',
  `ItemTypeId` int(11) NOT NULL COMMENT 'type of the item',
  `ItemStateId` int(11) default NULL COMMENT 'id of the state description (e.g. damaged, thrown away, etc)',
  `ItemBarcode` varchar(32) default NULL COMMENT 'barcode on the item container',
  `Amount` decimal(16,3) default NULL COMMENT 'amount of the item in container',
  `DateAdded` datetime NOT NULL COMMENT 'date time when added',
  `AddedByUserId` int(11) NOT NULL COMMENT 'who added',
  `LastMeasuredDate` datetime default NULL COMMENT 'date time when last updated',
  `LastMeasuredUserId` int(11) default NULL COMMENT 'who last updated',
  `ItemOperation` set('subsample','group') default NULL COMMENT 'in case item is derived from other items by taking sample or grouping (mixing) this can be defined here. Item parentage is defined in itemparent table',
  `ItemNote` varchar(254) default NULL COMMENT 'some comments',
  PRIMARY KEY  (`ItemId`),
  UNIQUE KEY `xi_ItemBarcode` (`ItemBarcode`),
  KEY `xi_ScaleId` (`ScaleId`),
  KEY `xi_StorageId` (`StorageId`),
  KEY `xi_ItemUnitId` (`ItemUnitId`),
  KEY `xi_ItemTypeId` (`ItemTypeId`),
  KEY `xi_AddedByUserId` (`AddedByUserId`),
  KEY `xi_LastMeasuredUserId` (`LastMeasuredUserId`),
  KEY `xi_DateAdded` (`DateAdded`),
  KEY `xi_LastMeasuredDate` (`LastMeasuredDate`),
  KEY `xi_ItemStateId` (`ItemStateId`),
  KEY `xi_TrialUnitSpecimenId` (`TrialUnitSpecimenId`),
  KEY `xi_ItemSourceId` (`ItemSourceId`),
  KEY `xi_ContainerTypeId` (`ContainerTypeId`),
  KEY `xi_SpecimenId` (`SpecimenId`),
  CONSTRAINT `item_ibfk_1` FOREIGN KEY (`SpecimenId`) REFERENCES `specimen` (`SpecimenId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `item_ibfk_2` FOREIGN KEY (`AddedByUserId`) REFERENCES `systemuser` (`UserId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `item_ibfk_3` FOREIGN KEY (`ItemTypeId`) REFERENCES `generaltype` (`TypeId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `itemfactor`
--

DROP TABLE IF EXISTS `itemfactor`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `itemfactor` (
  `ItemId` int(11) NOT NULL COMMENT 'item id',
  `FactorId` int(11) NOT NULL COMMENT 'virtual column id',
  `FactorValue` varchar(254) NOT NULL COMMENT 'value in column for an item id',
  PRIMARY KEY  (`ItemId`,`FactorId`),
  KEY `FactorId` (`FactorId`),
  CONSTRAINT `itemfactor_ibfk_1` FOREIGN KEY (`ItemId`) REFERENCES `item` (`ItemId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `itemfactor_ibfk_2` FOREIGN KEY (`FactorId`) REFERENCES `factor` (`FactorId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `itemgroup`
--

DROP TABLE IF EXISTS `itemgroup`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `itemgroup` (
  `ItemGroupId` int(11) NOT NULL auto_increment COMMENT 'Item group id',
  `ItemGroupName` varchar(64) NOT NULL COMMENT 'item group name',
  `ItemGroupNote` varchar(254) default NULL COMMENT 'comments about item group',
  `AddedByUser` int(11) default NULL COMMENT 'system user id, who created item group',
  `DateAdded` datetime NOT NULL COMMENT 'date time when item group added',
  `Active` tinyint(1) NOT NULL default '1' COMMENT 'flag if group active',
  PRIMARY KEY  (`ItemGroupId`),
  UNIQUE KEY `xig_ItemGroupName` (`ItemGroupName`),
  KEY `xig_AddedByUser` (`AddedByUser`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `itemgroupentry`
--

DROP TABLE IF EXISTS `itemgroupentry`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `itemgroupentry` (
  `ItemId` int(11) NOT NULL COMMENT 'item id',
  `ItemGroupId` int(11) NOT NULL COMMENT 'item group id',
  KEY `xige_ItemId` (`ItemId`),
  KEY `xige_ItemGroupId` (`ItemGroupId`),
  CONSTRAINT `itemgroupentry_ibfk_1` FOREIGN KEY (`ItemId`) REFERENCES `item` (`ItemId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `itemgroupentry_ibfk_2` FOREIGN KEY (`ItemGroupId`) REFERENCES `itemgroup` (`ItemGroupId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `itemlog`
--

DROP TABLE IF EXISTS `itemlog`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `itemlog` (
  `ItemLogId` int(11) NOT NULL auto_increment COMMENT 'item log id',
  `LogTypeId` int(11) NOT NULL COMMENT 'type, action to log',
  `SystemUserId` int(11) NOT NULL COMMENT 'who did/log that action',
  `ItemId` int(11) NOT NULL COMMENT 'item it was logged for',
  `LogDateTime` datetime NOT NULL COMMENT 'date time of action',
  `LogMessage` varchar(254) NOT NULL COMMENT 'message or info logged',
  PRIMARY KEY  (`ItemLogId`),
  KEY `xil_LogTypeId` (`LogTypeId`),
  KEY `xil_SystemUserId` (`SystemUserId`),
  KEY `xil_ItemId` (`ItemId`),
  KEY `xil_LogDateTime` (`LogDateTime`),
  CONSTRAINT `itemlog_ibfk_1` FOREIGN KEY (`ItemId`) REFERENCES `item` (`ItemId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `itemlog_ibfk_2` FOREIGN KEY (`SystemUserId`) REFERENCES `systemuser` (`UserId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `itemlog_ibfk_3` FOREIGN KEY (`LogTypeId`) REFERENCES `generaltype` (`TypeId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `itemparent`
--

DROP TABLE IF EXISTS `itemparent`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `itemparent` (
  `ItemParentId` int(11) NOT NULL auto_increment COMMENT 'internal id',
  `ItemParentType` int(11) NOT NULL COMMENT 'item parent type (different than parent type in generaltype table) class - itemparent',
  `ItemId` int(11) NOT NULL COMMENT 'newly created item id from other items',
  `ParentId` int(11) NOT NULL COMMENT 'item id of the parent item',
  PRIMARY KEY  (`ItemParentId`),
  UNIQUE KEY `xip_ItemIDParentID` (`ItemId`,`ParentId`),
  KEY `xip_ItemId` (`ItemId`),
  KEY `xip_ParentId` (`ParentId`),
  KEY `xip_ItemParentType` (`ItemParentType`),
  CONSTRAINT `itemparent_ibfk_1` FOREIGN KEY (`ItemId`) REFERENCES `item` (`ItemId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `itemparent_ibfk_2` FOREIGN KEY (`ParentId`) REFERENCES `item` (`ItemId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `itemparent_ibfk_3` FOREIGN KEY (`ItemParentType`) REFERENCES `generaltype` (`TypeId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `itemunit`
--

DROP TABLE IF EXISTS `itemunit`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `itemunit` (
  `ItemUnitId` int(11) NOT NULL auto_increment COMMENT 'item unit id',
  `UnitTypeId` int(11) default NULL COMMENT 'optional FK to type (e.g. weight, temperature, length etc) - class unittype',
  `ItemUnitName` varchar(12) NOT NULL COMMENT 'unit name (e.g. kg, dkg, etc)',
  `GramsConversionMultiplier` float NOT NULL default '1' COMMENT 'value to multiply to convert into grams (or any other multiplier into other units being commonly used in particular situation)',
  `ItemUnitNote` varchar(254) default NULL COMMENT 'some description',
  `ConversionRule` varchar(254) default NULL COMMENT 'function (sudo code or EXPR) to define possibly complex conversion from this unit to canonical unit',
  PRIMARY KEY  (`ItemUnitId`),
  UNIQUE KEY `xiu_ItemUnitName` (`ItemUnitName`),
  KEY `UnitTypeId` (`UnitTypeId`),
  CONSTRAINT `itemunit_ibfk_1` FOREIGN KEY (`UnitTypeId`) REFERENCES `generaltype` (`TypeId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `metgroup`
--

DROP TABLE IF EXISTS `metgroup`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `metgroup` (
  `METGroupId` int(11) NOT NULL auto_increment COMMENT 'met group id',
  `TraitId` int(11) NOT NULL COMMENT 'trait id (replacement of former variate id)',
  `METGroupName` varchar(255) NOT NULL COMMENT 'met group name',
  `METId` int(11) NOT NULL COMMENT 'met id',
  `AnalystId` int(11) NOT NULL COMMENT 'Id that identifies te analyst (contact) who analysed data.',
  `AnalysisDoneDate` datetime NOT NULL COMMENT 'when analysis done',
  `StatisticalModel` varchar(255) NOT NULL COMMENT 'Text representation of model formula (with covariate information)',
  `PercentVarianceExplained` decimal(16,6) default NULL COMMENT 'percentage of variance explained',
  `ControlGenotypeId` int(10) default NULL COMMENT 'shouldnat it be related to genotype idkMHgIt should be linked, it is in my schemak/MHg',
  `BiPlotImageFileName` varchar(255) default NULL COMMENT 'FileName(and Path) of Image File',
  `METGroupNote` varchar(6000) default NULL COMMENT 'met group description',
  PRIMARY KEY  (`METGroupId`),
  KEY `AlternateKey` (`METGroupName`,`METId`),
  KEY `METId` (`METId`),
  KEY `Contact_METGroup_FK1` (`AnalystId`),
  KEY `Genotype_METGroup_FK1` (`ControlGenotypeId`),
  KEY `TraitId` (`TraitId`),
  CONSTRAINT `metgroup_ibfk_1` FOREIGN KEY (`METId`) REFERENCES `multienvtrial` (`METId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `metgroup_ibfk_2` FOREIGN KEY (`TraitId`) REFERENCES `trait` (`TraitId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `metgroup_ibfk_3` FOREIGN KEY (`AnalystId`) REFERENCES `contact` (`ContactId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `metgroupegv`
--

DROP TABLE IF EXISTS `metgroupegv`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `metgroupegv` (
  `METGroupEGVId` int(11) NOT NULL auto_increment COMMENT 'met group egv id',
  `METGroupId` int(11) NOT NULL COMMENT 'met group id',
  `GenotypeId` int(11) NOT NULL COMMENT 'genotype id',
  `TreatmentId` int(11) default NULL COMMENT 'treatment id',
  `METSubGroupId` int(11) default NULL COMMENT 'met sub group id',
  `EGV` decimal(16,6) NOT NULL COMMENT 'EGV - Expected Genetic Value',
  PRIMARY KEY  (`METGroupEGVId`),
  KEY `AlternateKey` (`METGroupId`,`GenotypeId`,`TreatmentId`,`METSubGroupId`),
  KEY `GenotypeId` (`GenotypeId`),
  KEY `TreatmentId` (`TreatmentId`),
  KEY `METSubGroup_METGroupEGV_FK1` (`METSubGroupId`),
  CONSTRAINT `metgroupegv_ibfk_1` FOREIGN KEY (`GenotypeId`) REFERENCES `genotype` (`GenotypeId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `metgroupegv_ibfk_2` FOREIGN KEY (`METGroupId`) REFERENCES `metgroup` (`METGroupId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `metgroupegv_ibfk_3` FOREIGN KEY (`METSubGroupId`) REFERENCES `metsubgroup` (`METSubGroupId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `metgroupegv_ibfk_4` FOREIGN KEY (`TreatmentId`) REFERENCES `treatment` (`TreatmentId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `metgroupegvfactor`
--

DROP TABLE IF EXISTS `metgroupegvfactor`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `metgroupegvfactor` (
  `METGroupEGVId` int(11) NOT NULL COMMENT 'met group egv id',
  `FactorId` int(11) NOT NULL COMMENT 'factor id',
  `FactorValue` varchar(255) NOT NULL COMMENT 'value',
  PRIMARY KEY  (`METGroupEGVId`,`FactorId`),
  KEY `FactorId` (`FactorId`),
  KEY `METGroupEGV_METGroupEGVFactor_FK1` (`METGroupEGVId`),
  CONSTRAINT `metgroupegvfactor_ibfk_1` FOREIGN KEY (`FactorId`) REFERENCES `factor` (`FactorId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `metgroupegvfactor_ibfk_2` FOREIGN KEY (`METGroupEGVId`) REFERENCES `metgroupegv` (`METGroupEGVId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `metgrouptrial`
--

DROP TABLE IF EXISTS `metgrouptrial`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `metgrouptrial` (
  `METGroupTrialId` int(11) NOT NULL auto_increment COMMENT 'met group trial id',
  `METGroupId` int(11) NOT NULL COMMENT 'met group trial',
  `TrialId` int(11) NOT NULL COMMENT 'trial id',
  PRIMARY KEY  (`METGroupTrialId`),
  KEY `AlternateKey` (`METGroupId`,`TrialId`),
  KEY `TrialId` (`TrialId`),
  CONSTRAINT `metgrouptrial_ibfk_1` FOREIGN KEY (`METGroupId`) REFERENCES `metgroup` (`METGroupId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `metgrouptrial_ibfk_2` FOREIGN KEY (`TrialId`) REFERENCES `trial` (`TrialId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `metsubgroup`
--

DROP TABLE IF EXISTS `metsubgroup`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `metsubgroup` (
  `METSubGroupId` int(11) NOT NULL auto_increment COMMENT 'met sub group id',
  `METSubGroupText` varchar(255) NOT NULL COMMENT 'met sub group description',
  PRIMARY KEY  (`METSubGroupId`),
  KEY `AlternateKey` (`METSubGroupText`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `metsubgroupfactor`
--

DROP TABLE IF EXISTS `metsubgroupfactor`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `metsubgroupfactor` (
  `METSubGroupId` int(11) NOT NULL COMMENT 'met sub group id',
  `FactorId` int(11) NOT NULL COMMENT 'factor id',
  `FactorValue` varchar(255) NOT NULL COMMENT 'value',
  PRIMARY KEY  (`METSubGroupId`,`FactorId`),
  KEY `FactorId` (`FactorId`),
  KEY `METSubGroup_METSubGroupFactor_FK1` (`METSubGroupId`),
  CONSTRAINT `metsubgroupfactor_ibfk_1` FOREIGN KEY (`FactorId`) REFERENCES `factor` (`FactorId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `metsubgroupfactor_ibfk_2` FOREIGN KEY (`METSubGroupId`) REFERENCES `metsubgroup` (`METSubGroupId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `multienvtrial`
--

DROP TABLE IF EXISTS `multienvtrial`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `multienvtrial` (
  `METId` int(11) NOT NULL auto_increment COMMENT 'met id',
  `METName` varchar(255) NOT NULL COMMENT 'met name',
  `METStartYear` int(10) NOT NULL COMMENT 'met started (more precise date?) could be date or string(season?)',
  `METEndYear` int(10) NOT NULL COMMENT 'met finished (more precise date?) should be datetime',
  `METNote` varchar(6000) default NULL COMMENT 'description',
  `OwnGroupId` int(11) NOT NULL COMMENT 'group id which owns the record',
  `AccessGroupId` int(11) NOT NULL default '0' COMMENT 'group id which have some access to the record',
  `OwnGroupPerm` tinyint(4) NOT NULL COMMENT 'permission for the owner group',
  `AccessGroupPerm` tinyint(4) NOT NULL default '0' COMMENT 'permission for the other group',
  `OtherPerm` tinyint(4) NOT NULL default '0' COMMENT 'permission for the rest of system users',
  PRIMARY KEY  (`METId`),
  KEY `AlternateKey` (`METName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `multimedia`
--

DROP TABLE IF EXISTS `multimedia`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `multimedia` (
  `MultimediaId` int(11) NOT NULL auto_increment COMMENT 'internal id',
  `SystemTable` set('genotype','specimen','project','site','trial','trialunit','item','extract') NOT NULL COMMENT 'name of the supported system table, for which file is attached',
  `RecordId` int(11) NOT NULL COMMENT 'record id in the table',
  `OperatorId` int(11) NOT NULL COMMENT 'system user, who uploaded (updated) the file',
  `FileType` int(11) NOT NULL COMMENT 'file type (e.g. csv table, fasta sequence, image, video, etc)',
  `OrigFileName` varchar(254) NOT NULL COMMENT 'name of the original file',
  `HashFileName` varchar(64) NOT NULL COMMENT 'hash of the orignial file name',
  `UploadTime` datetime NOT NULL COMMENT 'time of upload, update of the file',
  `FileExtension` varchar(10) default NULL COMMENT 'file extension',
  PRIMARY KEY  (`MultimediaId`),
  KEY `xmme_SystemTable` (`SystemTable`),
  KEY `xmme_RecordId` (`RecordId`),
  KEY `xmme_OperatorId` (`OperatorId`),
  KEY `xmme_FileType` (`FileType`),
  CONSTRAINT `multimedia_ibfk_1` FOREIGN KEY (`FileType`) REFERENCES `generaltype` (`TypeId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `multimedia_ibfk_2` FOREIGN KEY (`OperatorId`) REFERENCES `systemuser` (`UserId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `organisation`
--

DROP TABLE IF EXISTS `organisation`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `organisation` (
  `OrganisationId` int(11) NOT NULL auto_increment COMMENT 'organisation id',
  `OrganisationName` varchar(64) NOT NULL COMMENT 'organisation name',
  PRIMARY KEY  (`OrganisationId`),
  UNIQUE KEY `xo_OrganisationName` (`OrganisationName`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `organisationfactor`
--

DROP TABLE IF EXISTS `organisationfactor`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `organisationfactor` (
  `OrganisationId` int(11) NOT NULL COMMENT 'organisation id',
  `FactorId` int(11) NOT NULL COMMENT 'factor id',
  `FactorValue` varchar(254) NOT NULL COMMENT 'factor value',
  PRIMARY KEY  (`OrganisationId`,`FactorId`),
  KEY `FactorId` (`FactorId`),
  CONSTRAINT `organisationfactor_ibfk_1` FOREIGN KEY (`OrganisationId`) REFERENCES `organisation` (`OrganisationId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `organisationfactor_ibfk_2` FOREIGN KEY (`FactorId`) REFERENCES `factor` (`FactorId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `pedigree`
--

DROP TABLE IF EXISTS `pedigree`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `pedigree` (
  `PedigreeId` int(11) NOT NULL auto_increment COMMENT 'internal record id',
  `SpecimenId` int(11) NOT NULL COMMENT 'id of the specimen',
  `ParentSpecimenId` int(11) NOT NULL COMMENT 'id of another specimen, which is its parent',
  `ParentType` int(11) NOT NULL COMMENT 'Parent type (male female self) or others as in generaltype table in class aparenta',
  `SelectionReason` varchar(100) default NULL COMMENT 'Short description (optional) why the selection was made',
  `NumberOfSpecimens` int(11) default NULL COMMENT 'Number of Specimens: The number of a specific parent specimen used in a breeding process to make progeny specimen. e.g. FemaleSpecimenName: F; MaleSpecimenName: M; 1xF is crossed with 20xM; Pedigree holds: NumberOfSpecimens Female F is 1; NumberOfSpecimen',
  PRIMARY KEY  (`PedigreeId`),
  UNIQUE KEY `xpe_SpPaType` (`SpecimenId`,`ParentSpecimenId`,`ParentType`),
  KEY `xpe_SpecimenId` (`SpecimenId`),
  KEY `xpe_ParentSpecimenId` (`ParentSpecimenId`),
  KEY `xpe_ParentType` (`ParentType`),
  CONSTRAINT `pedigree_ibfk_1` FOREIGN KEY (`ParentSpecimenId`) REFERENCES `specimen` (`SpecimenId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `pedigree_ibfk_2` FOREIGN KEY (`SpecimenId`) REFERENCES `specimen` (`SpecimenId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `pedigree_ibfk_3` FOREIGN KEY (`ParentType`) REFERENCES `generaltype` (`TypeId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `project`
--

DROP TABLE IF EXISTS `project`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `project` (
  `ProjectId` int(11) NOT NULL auto_increment COMMENT 'project id',
  `ProjectManagerId` int(11) NOT NULL COMMENT 'manager of the project, link to contact table',
  `TypeId` int(11) NOT NULL COMMENT 'project type, link to general type table class project',
  `ProjectName` varchar(254) NOT NULL COMMENT 'project name',
  `ProjectStatus` varchar(254) default NULL COMMENT 'project status (e.g. stage 2, confirmed, discontinued, etc)',
  `ProjectStartDate` datetime default NULL COMMENT 'start project date',
  `ProjectEndDate` datetime default NULL COMMENT 'end project date',
  `ProjectNote` mediumtext COMMENT 'project general description',
  PRIMARY KEY  (`ProjectId`),
  UNIQUE KEY `xp_ProjectName` (`ProjectName`),
  KEY `xp_ProjectManagerId` (`ProjectManagerId`),
  KEY `xp_TypeId` (`TypeId`),
  KEY `xp_ProjectStartDate` (`ProjectStartDate`),
  KEY `xp_ProjectEndDate` (`ProjectEndDate`),
  KEY `xp_ProjectStatus` (`ProjectStatus`),
  CONSTRAINT `project_ibfk_1` FOREIGN KEY (`TypeId`) REFERENCES `generaltype` (`TypeId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `project_ibfk_2` FOREIGN KEY (`ProjectManagerId`) REFERENCES `contact` (`ContactId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `projectfactor`
--

DROP TABLE IF EXISTS `projectfactor`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `projectfactor` (
  `ProjectId` int(11) NOT NULL COMMENT 'project id',
  `FactorId` int(11) NOT NULL COMMENT 'factor id',
  `FactorValue` varchar(254) NOT NULL COMMENT 'value for project factor',
  PRIMARY KEY  (`ProjectId`,`FactorId`),
  KEY `FactorId` (`FactorId`),
  CONSTRAINT `projectfactor_ibfk_1` FOREIGN KEY (`ProjectId`) REFERENCES `project` (`ProjectId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `projectfactor_ibfk_2` FOREIGN KEY (`FactorId`) REFERENCES `factor` (`FactorId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `reservedkeyword`
--

DROP TABLE IF EXISTS `reservedkeyword`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `reservedkeyword` (
  `KeywordName` varchar(64) NOT NULL COMMENT 'Keyword',
  `ApplicationName` varchar(255) NOT NULL COMMENT 'Application',
  PRIMARY KEY  (`KeywordName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `samplemeasurement`
--

DROP TABLE IF EXISTS `samplemeasurement`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `samplemeasurement` (
  `TrialUnitId` int(11) NOT NULL COMMENT 'trial unit id',
  `TraitId` int(11) NOT NULL COMMENT 'id of the trait being measured',
  `OperatorId` int(11) NOT NULL COMMENT 'user performing the measurement',
  `MeasureDateTime` datetime NOT NULL COMMENT 'date / time of the measurement',
  `InstanceNumber` tinyint(4) NOT NULL default '1' COMMENT 'next consecutive number of the measurement instance if all other values of primary key are the same',
  `SampleTypeId` int(11) NOT NULL COMMENT 'sample type id',
  `TraitValue` varchar(255) NOT NULL COMMENT 'measurement value',
  PRIMARY KEY  (`TrialUnitId`,`TraitId`,`OperatorId`,`MeasureDateTime`,`InstanceNumber`,`SampleTypeId`),
  KEY `xsm_OperatorId` (`OperatorId`),
  KEY `xsm_TraitId` (`TraitId`),
  KEY `xsm_MeasureDateTime` (`MeasureDateTime`),
  KEY `xsm_TrialUnitId` (`TrialUnitId`),
  KEY `xsm_SampleTypeId` (`SampleTypeId`),
  CONSTRAINT `samplemeasurement_ibfk_1` FOREIGN KEY (`TrialUnitId`) REFERENCES `trialunit` (`TrialUnitId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `samplemeasurement_ibfk_2` FOREIGN KEY (`TraitId`) REFERENCES `trait` (`TraitId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `samplemeasurement_ibfk_3` FOREIGN KEY (`OperatorId`) REFERENCES `systemuser` (`UserId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `samplemeasurement_ibfk_4` FOREIGN KEY (`SampleTypeId`) REFERENCES `generaltype` (`TypeId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `site`
--

DROP TABLE IF EXISTS `site`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `site` (
  `SiteId` int(11) NOT NULL auto_increment COMMENT 'site id',
  `SiteTypeId` int(11) NOT NULL COMMENT 'site type id',
  `SiteName` varchar(64) NOT NULL COMMENT 'name',
  `SiteAcronym` varchar(5) NOT NULL COMMENT 'short name of the site, can be used as e.g. part of the trial naming convention',
  `CurrentSiteManagerId` int(11) NOT NULL COMMENT 'person currently managing the site, not necessarily a user of this system, so linked to the contactId',
  `SiteStartDate` datetime default NULL COMMENT 'Date when site started to exist',
  `SiteEndDate` datetime default NULL COMMENT 'Date when site stopped to exist',
  PRIMARY KEY  (`SiteId`),
  KEY `xs_SiteName` (`SiteName`),
  KEY `xs_CurrentSiteManagerId` (`CurrentSiteManagerId`),
  KEY `xs_SiteAcronym` (`SiteAcronym`),
  KEY `xs_SiteStartDate` (`SiteStartDate`),
  KEY `xs_SiteEndDate` (`SiteEndDate`),
  KEY `SiteTypeId` (`SiteTypeId`),
  CONSTRAINT `site_ibfk_1` FOREIGN KEY (`CurrentSiteManagerId`) REFERENCES `contact` (`ContactId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `site_ibfk_2` FOREIGN KEY (`SiteTypeId`) REFERENCES `generaltype` (`TypeId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `sitefactor`
--

DROP TABLE IF EXISTS `sitefactor`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `sitefactor` (
  `SiteId` int(11) NOT NULL COMMENT 'site id',
  `FactorId` int(11) NOT NULL COMMENT 'factor id',
  `FactorValue` varchar(255) NOT NULL COMMENT 'value',
  PRIMARY KEY  (`SiteId`,`FactorId`),
  KEY `FactorId` (`FactorId`),
  CONSTRAINT `sitefactor_ibfk_1` FOREIGN KEY (`FactorId`) REFERENCES `factor` (`FactorId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `sitefactor_ibfk_2` FOREIGN KEY (`SiteId`) REFERENCES `site` (`SiteId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `specimen`
--

DROP TABLE IF EXISTS `specimen`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `specimen` (
  `SpecimenId` int(11) NOT NULL auto_increment COMMENT 'Individual specimen id',
  `BreedingMethodId` int(11) NOT NULL COMMENT 'id of the breeding method',
  `SpecimenName` varchar(254) NOT NULL COMMENT 'Specimen name',
  `SpecimenBarcode` varchar(64) default NULL COMMENT 'Optional specimen barcode - if assigned could be printed on label',
  `IsActive` tinyint(2) default '1' COMMENT 'Set to 0 if we want to indicate that it is no longer in production, program or some other binary switch',
  `Pedigree` mediumtext COMMENT 'Could be generated Purdy string from male and female parent ID (or some other than Purdy standard)',
  `SelectionHistory` varchar(254) default NULL COMMENT 'Can be siblings clones etc, where genotype name is the same. pulses use this a lot',
  `FilialGeneration` int(11) default NULL COMMENT 'Level of specimens being selfed, required when full selection history is not available',
  PRIMARY KEY  (`SpecimenId`),
  UNIQUE KEY `xs_SpecimenName` (`SpecimenName`),
  UNIQUE KEY `xs_SpecimenBarcode` (`SpecimenBarcode`),
  KEY `xs_BreedingMethodId` (`BreedingMethodId`),
  KEY `xs_IsActive` (`IsActive`),
  CONSTRAINT `specimen_ibfk_1` FOREIGN KEY (`BreedingMethodId`) REFERENCES `breedingmethod` (`BreedingMethodId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `specimenfactor`
--

DROP TABLE IF EXISTS `specimenfactor`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `specimenfactor` (
  `FactorId` int(11) NOT NULL,
  `SpecimenId` int(11) NOT NULL,
  `FactorValue` varchar(255) NOT NULL,
  PRIMARY KEY  (`FactorId`,`SpecimenId`),
  KEY `FactorId` (`FactorId`),
  KEY `SpecimenId` (`SpecimenId`),
  CONSTRAINT `specimenfactor_ibfk_1` FOREIGN KEY (`SpecimenId`) REFERENCES `specimen` (`SpecimenId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `specimenfactor_ibfk_2` FOREIGN KEY (`FactorId`) REFERENCES `factor` (`FactorId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `specimengroup`
--

DROP TABLE IF EXISTS `specimengroup`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `specimengroup` (
  `SpecimenGroupId` int(11) NOT NULL auto_increment COMMENT 'id of the group of specimens',
  `SpecimenGroupTypeId` int(11) NOT NULL COMMENT 'id of the specimen group type',
  `SpecimenGroupName` varchar(64) NOT NULL COMMENT 'group name',
  `SpecimenGroupNote` varchar(254) default NULL COMMENT 'description',
  PRIMARY KEY  (`SpecimenGroupId`),
  UNIQUE KEY `xsg_SpecimenGroupName` (`SpecimenGroupName`),
  KEY `xsg_SpecimenGroupTypeId` (`SpecimenGroupTypeId`),
  CONSTRAINT `specimengroup_ibfk_1` FOREIGN KEY (`SpecimenGroupTypeId`) REFERENCES `generaltype` (`TypeId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `specimengroupentry`
--

DROP TABLE IF EXISTS `specimengroupentry`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `specimengroupentry` (
  `SpecimenGroupEntryId` int(11) NOT NULL auto_increment COMMENT 'entry id',
  `SpecimenId` int(11) NOT NULL COMMENT 'specimen id',
  `SpecimenGroupId` int(11) NOT NULL COMMENT 'specimen group id',
  `SpecimenNote` varchar(254) default NULL COMMENT 'special note for this specimen in the group',
  PRIMARY KEY  (`SpecimenGroupEntryId`,`SpecimenId`,`SpecimenGroupId`),
  KEY `xsge_SpecimenId` (`SpecimenId`),
  KEY `xsge_SpecimenGroupId` (`SpecimenGroupId`),
  CONSTRAINT `specimengroupentry_ibfk_1` FOREIGN KEY (`SpecimenGroupId`) REFERENCES `specimengroup` (`SpecimenGroupId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `specimengroupentry_ibfk_2` FOREIGN KEY (`SpecimenId`) REFERENCES `specimen` (`SpecimenId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `storage`
--

DROP TABLE IF EXISTS `storage`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `storage` (
  `StorageId` int(11) NOT NULL auto_increment COMMENT 'id of the storage position',
  `StorageBarcode` varchar(64) default NULL COMMENT 'barcode of the storage position',
  `StorageLocation` varchar(32) NOT NULL COMMENT 'location of the storage (e.g. building, room, freezer, shelf, etc)',
  `StorageParentId` int(11) NOT NULL default '0' COMMENT 'id of the parent storage (e.g. for room parent storage could be building where the room is located)',
  `StorageDetails` varchar(254) default NULL COMMENT 'more info about a storage',
  `StorageNote` varchar(254) default NULL COMMENT 'detailed storage description',
  PRIMARY KEY  (`StorageId`),
  UNIQUE KEY `xs_StorageBarcode` (`StorageBarcode`),
  KEY `xs_StorageLocation` (`StorageLocation`),
  KEY `xs_StorageParentId` (`StorageParentId`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `systemgroup`
--

DROP TABLE IF EXISTS `systemgroup`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `systemgroup` (
  `SystemGroupId` int(11) NOT NULL auto_increment COMMENT 'system group id',
  `SystemGroupName` varchar(64) NOT NULL COMMENT 'system group name',
  `SystemGroupDescription` varchar(255) NOT NULL COMMENT 'system group description',
  PRIMARY KEY  (`SystemGroupId`),
  UNIQUE KEY `xsg_SystemGroupName` (`SystemGroupName`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `systemuser`
--

DROP TABLE IF EXISTS `systemuser`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `systemuser` (
  `UserId` int(11) NOT NULL auto_increment COMMENT 'user id',
  `UserName` varchar(32) NOT NULL COMMENT 'user name',
  `UserPassword` varchar(128) NOT NULL COMMENT 'user password',
  `PasswordSalt` varchar(64) NOT NULL COMMENT 'password salt (used to hash/encrypt password?)',
  `ContactId` int(11) NOT NULL COMMENT 'contact id',
  `LastLoginDateTime` datetime default NULL COMMENT 'date and time of last logon',
  `UserPreference` mediumtext COMMENT 'what preferences are stored here and in what format?',
  `UserType` varchar(20) NOT NULL COMMENT 'distinguish between humans and mechanical devices for data input or processing',
  PRIMARY KEY  (`UserId`),
  UNIQUE KEY `xsu_UserName` (`UserName`),
  KEY `xsu_ContactId` (`ContactId`),
  CONSTRAINT `systemuser_ibfk_1` FOREIGN KEY (`ContactId`) REFERENCES `contact` (`ContactId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `trait`
--

DROP TABLE IF EXISTS `trait`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `trait` (
  `TraitId` int(11) NOT NULL auto_increment COMMENT 'trait id',
  `TraitGroupTypeId` int(11) default NULL COMMENT 'optional - class traitgroup - (e.g. all plant height related traits can be grouped in aplantheighta type',
  `TraitName` varchar(32) NOT NULL COMMENT 'trait name',
  `TraitCaption` varchar(64) NOT NULL COMMENT 'trait name (e.g. to display) shorter version or e.g. name without spaces',
  `TraitDescription` varchar(255) NOT NULL COMMENT 'description about trait',
  `TraitDataType` varchar(8) NOT NULL COMMENT 'data type (e.g. varchar, integer, etc)',
  `TraitValueMaxLength` int(10) NOT NULL COMMENT 'max length of the value (e.g. 12)',
  `TraitUnit` int(11) NOT NULL COMMENT 'FK to unit definitions',
  `IsTraitUsedForAnalysis` tinyint(1) NOT NULL COMMENT 'flag - can be used to streamline export, e.g export all that need analysis',
  `TraitValRule` varchar(255) NOT NULL COMMENT 'validation rule for the value of the trait',
  `TraitValRuleErrMsg` varchar(255) NOT NULL COMMENT 'error message to display, when validation rule criteria are not met',
  `OwnGroupId` int(11) NOT NULL COMMENT 'group id owning the record',
  `AccessGroupId` int(11) NOT NULL default '0' COMMENT 'group id with some access to the record',
  `OwnGroupPerm` tinyint(4) NOT NULL COMMENT 'owning group permissions',
  `AccessGroupPerm` tinyint(4) NOT NULL default '0' COMMENT 'other group permissions',
  `OtherPerm` tinyint(4) NOT NULL default '0' COMMENT 'all system users permissions',
  PRIMARY KEY  (`TraitId`),
  UNIQUE KEY `xt_TraitName` (`TraitName`),
  KEY `xt_TraitCaption` (`TraitCaption`),
  KEY `xt_TraitGroupTypeId` (`TraitGroupTypeId`),
  KEY `xt_TraitUnit` (`TraitUnit`),
  CONSTRAINT `trait_ibfk_1` FOREIGN KEY (`TraitUnit`) REFERENCES `itemunit` (`ItemUnitId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `trait_ibfk_2` FOREIGN KEY (`TraitGroupTypeId`) REFERENCES `generaltype` (`TypeId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `traitalias`
--

DROP TABLE IF EXISTS `traitalias`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `traitalias` (
  `TraitAliasId` int(11) NOT NULL auto_increment COMMENT 'trait alias id',
  `TraitId` int(11) NOT NULL COMMENT 'trait id',
  `TraitAliasName` varchar(64) NOT NULL COMMENT 'name of trait alias',
  `TraitAliasCaption` varchar(64) default NULL COMMENT 'caption of the trait alias',
  `TraitAliasDescription` varchar(254) default NULL COMMENT 'description of the trait alias',
  `TraitAliasValueRuleErrMsg` varchar(254) default NULL COMMENT 'value rule error message of the trait alias',
  `TraitLang` varchar(6) default NULL COMMENT 'language code (e.g. en for English, sp for Spanish etc) in case trait alias is just a trait translation',
  PRIMARY KEY  (`TraitAliasId`),
  KEY `xta_TraitAliasName` (`TraitAliasName`),
  KEY `xta_TraitId` (`TraitId`),
  KEY `xta_TraitLang` (`TraitLang`),
  CONSTRAINT `traitalias_ibfk_1` FOREIGN KEY (`TraitId`) REFERENCES `trait` (`TraitId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `treatment`
--

DROP TABLE IF EXISTS `treatment`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `treatment` (
  `TreatmentId` int(11) NOT NULL auto_increment COMMENT 'treatment id',
  `TreatmentText` varchar(255) NOT NULL COMMENT 'treatment description',
  PRIMARY KEY  (`TreatmentId`),
  KEY `xt_TreatmentText` (`TreatmentText`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `treatmentfactor`
--

DROP TABLE IF EXISTS `treatmentfactor`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `treatmentfactor` (
  `TreatmentId` int(11) NOT NULL COMMENT 'treatment id',
  `FactorId` int(11) NOT NULL COMMENT 'factor id',
  `FactorValue` varchar(32) NOT NULL COMMENT 'value',
  PRIMARY KEY  (`TreatmentId`,`FactorId`),
  KEY `FactorId` (`FactorId`),
  CONSTRAINT `treatmentfactor_ibfk_1` FOREIGN KEY (`FactorId`) REFERENCES `factor` (`FactorId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `treatmentfactor_ibfk_2` FOREIGN KEY (`TreatmentId`) REFERENCES `treatment` (`TreatmentId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `trial`
--

DROP TABLE IF EXISTS `trial`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `trial` (
  `TrialId` int(11) NOT NULL auto_increment COMMENT 'trial id',
  `ProjectId` int(11) default NULL COMMENT 'id of the project that trial belongs to, it is optional',
  `CurrentWorkflowId` int(11) default NULL COMMENT 'current workflow id to identify which workflow is currently assigned to trial. Optional as trial may not have a workflow assigned at all.',
  `TrialTypeId` int(11) NOT NULL COMMENT 'trial type id (general type, different from design type, which is trial specific definition)',
  `SiteId` int(11) NOT NULL COMMENT 'site id, to which trial belongs to',
  `TrialName` varchar(100) NOT NULL COMMENT 'Trial name (can be created as concatenation of site, type, date, number)',
  `TrialNumber` int(11) NOT NULL COMMENT 'trial running number',
  `TrialAcronym` varchar(30) NOT NULL COMMENT 'alternative short name for a trial',
  `DesignTypeId` int(11) NOT NULL COMMENT 'design type - relation to design type table',
  `TrialManagerId` int(11) NOT NULL COMMENT 'person managing trial',
  `TrialStartDate` datetime NOT NULL COMMENT 'when started',
  `TrialEndDate` datetime default NULL COMMENT 'when finished',
  `TrialNote` varchar(6000) default NULL COMMENT 'description text',
  `OwnGroupId` int(11) NOT NULL COMMENT 'id of the group which owns the record',
  `AccessGroupId` int(11) NOT NULL default '0' COMMENT 'id of the group which have permissions to the record (different to the own group)',
  `OwnGroupPerm` tinyint(4) NOT NULL COMMENT 'permissions of the own group to the record',
  `AccessGroupPerm` tinyint(4) NOT NULL default '0' COMMENT 'permissions of the other group to the record',
  `OtherPerm` tinyint(4) NOT NULL default '0' COMMENT 'permissions for all registered users to the record',
  PRIMARY KEY  (`TrialId`),
  KEY `xtr_TrialName` (`TrialName`),
  KEY `xtr_TrialAcronym` (`TrialAcronym`),
  KEY `xtr_ContactId` (`TrialManagerId`),
  KEY `xtr_DesignTypeId` (`DesignTypeId`),
  KEY `xtr_SiteId` (`SiteId`),
  KEY `xtr_TrialTypeId` (`TrialTypeId`),
  KEY `xtr_TrialStartDate` (`TrialStartDate`),
  KEY `xtr_TrialEndDate` (`TrialEndDate`),
  KEY `xtr_CurrentWorkflowId` (`CurrentWorkflowId`),
  KEY `xtr_ProjectId` (`ProjectId`),
  CONSTRAINT `trial_ibfk_1` FOREIGN KEY (`DesignTypeId`) REFERENCES `designtype` (`DesignTypeId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `trial_ibfk_2` FOREIGN KEY (`SiteId`) REFERENCES `site` (`SiteId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `trial_ibfk_3` FOREIGN KEY (`TrialManagerId`) REFERENCES `contact` (`ContactId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `trial_ibfk_4` FOREIGN KEY (`TrialTypeId`) REFERENCES `generaltype` (`TypeId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `trial_ibfk_5` FOREIGN KEY (`ProjectId`) REFERENCES `project` (`ProjectId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `trialanalysis`
--

DROP TABLE IF EXISTS `trialanalysis`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `trialanalysis` (
  `TrialAnalysisId` int(11) NOT NULL auto_increment COMMENT 'trial analysis id',
  `AnalystId` int(11) NOT NULL,
  `TrialId` int(11) NOT NULL COMMENT 'trial id',
  `StatisticalModel` varchar(255) NOT NULL COMMENT 'statistical model used',
  `AnalysisDoneDate` datetime NOT NULL COMMENT 'date of analysis',
  `TrialAnalysisNote` varchar(6000) default NULL COMMENT 'some additional description',
  `OwnGroupId` int(11) NOT NULL COMMENT 'group id owning the record',
  `AccessGroupId` int(11) NOT NULL default '0' COMMENT 'group id with some access to the record',
  `OwnGroupPerm` tinyint(4) NOT NULL COMMENT 'owning group permissions',
  `AccessGroupPerm` tinyint(4) NOT NULL default '0' COMMENT 'other group permissions',
  `OtherPerm` tinyint(4) NOT NULL default '0' COMMENT 'all system users permissions',
  PRIMARY KEY  (`TrialAnalysisId`),
  KEY `AlternateKey` (`TrialId`,`StatisticalModel`),
  KEY `xanalystid_trialanalysis` (`AnalystId`),
  CONSTRAINT `trialanalysis_ibfk_1` FOREIGN KEY (`TrialId`) REFERENCES `trial` (`TrialId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `trialanalysis_ibfk_2` FOREIGN KEY (`AnalystId`) REFERENCES `contact` (`ContactId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `trialanalysisfactor`
--

DROP TABLE IF EXISTS `trialanalysisfactor`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `trialanalysisfactor` (
  `TrialAnalysisId` int(11) NOT NULL COMMENT 'trial analysis id',
  `FactorId` int(11) NOT NULL COMMENT 'factor id',
  `FactorValue` varchar(255) NOT NULL COMMENT 'value',
  PRIMARY KEY  (`TrialAnalysisId`,`FactorId`),
  KEY `FactorId` (`FactorId`),
  CONSTRAINT `trialanalysisfactor_ibfk_1` FOREIGN KEY (`FactorId`) REFERENCES `factor` (`FactorId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `trialanalysisfactor_ibfk_2` FOREIGN KEY (`TrialAnalysisId`) REFERENCES `trialanalysis` (`TrialAnalysisId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `trialaov`
--

DROP TABLE IF EXISTS `trialaov`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `trialaov` (
  `TrialAOVId` int(11) NOT NULL auto_increment COMMENT 'trial aov id',
  `TrialAnalysisId` int(11) NOT NULL COMMENT 'trial analysis id',
  `StatisticalMethod` varchar(255) NOT NULL COMMENT 'method ?kMHgGeneral text by the statistician about how the analysis was donek/MHg',
  `GeneralMean` decimal(16,6) default NULL COMMENT 'mean value',
  `LSD` decimal(16,6) default NULL COMMENT 'Least Significant Difference (Fisher test?)kMHgFisher Testk/MHg',
  `CoV` decimal(16,6) default NULL COMMENT 'Covariance',
  `EDF` decimal(16,6) default NULL COMMENT 'Expected Default Frequency kMHgNumber of Times it should have been replicatedk/MHg',
  `SED` decimal(16,6) default NULL COMMENT 'Standard Error of the Difference ???kMHgComponent of LSDk/MHg',
  PRIMARY KEY  (`TrialAOVId`),
  KEY `AlternateKey` (`TrialAnalysisId`),
  CONSTRAINT `trialaov_ibfk_1` FOREIGN KEY (`TrialAnalysisId`) REFERENCES `trialanalysis` (`TrialAnalysisId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `trialaovfactor`
--

DROP TABLE IF EXISTS `trialaovfactor`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `trialaovfactor` (
  `TrialAOVId` int(11) NOT NULL COMMENT 'trial aov id',
  `FactorId` int(11) NOT NULL COMMENT 'factor id',
  `FactorValue` varchar(255) NOT NULL COMMENT 'value',
  PRIMARY KEY  (`TrialAOVId`,`FactorId`),
  KEY `FactorId` (`FactorId`),
  CONSTRAINT `trialaovfactor_ibfk_1` FOREIGN KEY (`FactorId`) REFERENCES `factor` (`FactorId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `trialaovfactor_ibfk_2` FOREIGN KEY (`TrialAOVId`) REFERENCES `trialaov` (`TrialAOVId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `trialevent`
--

DROP TABLE IF EXISTS `trialevent`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `trialevent` (
  `TrialEventId` int(11) NOT NULL auto_increment COMMENT 'trial event id',
  `TrialEventUnit` int(11) default NULL COMMENT 'trial event unit id - definition of units for the value, can be null if value is descriptive',
  `EventTypeId` int(11) NOT NULL COMMENT 'trial event type id',
  `TrialId` int(11) NOT NULL COMMENT 'trial id',
  `OperatorId` int(11) NOT NULL COMMENT 'person who performed operation',
  `TrialEventValue` varchar(32) NOT NULL COMMENT 'event value (number in the units defined)',
  `TrialEventDate` datetime NOT NULL COMMENT 'operation date',
  `TrialEventNote` varchar(254) default NULL COMMENT 'additional description of the event',
  PRIMARY KEY  (`TrialEventId`),
  KEY `xte_OperatorId` (`OperatorId`),
  KEY `xte_TrialId` (`TrialId`),
  KEY `xte_EventTypeId` (`EventTypeId`),
  KEY `xte_TrialEventDate` (`TrialEventDate`),
  KEY `xte_TrialEventUnit` (`TrialEventUnit`),
  CONSTRAINT `trialevent_ibfk_1` FOREIGN KEY (`TrialId`) REFERENCES `trial` (`TrialId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `trialevent_ibfk_2` FOREIGN KEY (`EventTypeId`) REFERENCES `generaltype` (`TypeId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `trialevent_ibfk_3` FOREIGN KEY (`OperatorId`) REFERENCES `systemuser` (`UserId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `trialevent_ibfk_4` FOREIGN KEY (`TrialEventUnit`) REFERENCES `itemunit` (`ItemUnitId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `trialeventfactor`
--

DROP TABLE IF EXISTS `trialeventfactor`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `trialeventfactor` (
  `FactorId` int(11) NOT NULL COMMENT 'factor id',
  `TrialEventId` int(11) NOT NULL COMMENT 'trial event id',
  `FactorValue` varchar(255) NOT NULL COMMENT 'value',
  PRIMARY KEY  (`FactorId`,`TrialEventId`),
  KEY `FactorId` (`FactorId`),
  KEY `TrialEventId` (`TrialEventId`),
  CONSTRAINT `trialeventfactor_ibfk_1` FOREIGN KEY (`FactorId`) REFERENCES `factor` (`FactorId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `trialeventfactor_ibfk_2` FOREIGN KEY (`TrialEventId`) REFERENCES `trialevent` (`TrialEventId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `trialfactor`
--

DROP TABLE IF EXISTS `trialfactor`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `trialfactor` (
  `TrialId` int(11) NOT NULL COMMENT 'trial id',
  `FactorId` int(11) NOT NULL COMMENT 'factor id',
  `FactorValue` varchar(255) NOT NULL COMMENT 'value',
  PRIMARY KEY  (`TrialId`,`FactorId`),
  KEY `FactorId` (`FactorId`),
  CONSTRAINT `trialfactor_ibfk_1` FOREIGN KEY (`FactorId`) REFERENCES `factor` (`FactorId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `trialfactor_ibfk_2` FOREIGN KEY (`TrialId`) REFERENCES `trial` (`TrialId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `trialmean`
--

DROP TABLE IF EXISTS `trialmean`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `trialmean` (
  `TrialMeanId` int(11) NOT NULL auto_increment COMMENT 'trial mean id',
  `TrialAOVId` int(11) NOT NULL COMMENT 'trial aov id',
  `GenotypeId` int(11) NOT NULL COMMENT 'genotype id',
  `TreatmentId` int(11) default NULL COMMENT 'treatment id',
  `MeanValue` decimal(16,6) NOT NULL COMMENT 'mean value',
  `SuccessfulRep` decimal(6,2) NOT NULL COMMENT 'number of successful replications???kMHgnumber of non missing variations (incase animals ate some of the crop and a replicate could not be used)k/MHg',
  `Weight` decimal(16,6) NOT NULL COMMENT 'weight',
  `Rank` int(10) default NULL COMMENT 'rank',
  `EMS` decimal(16,6) default NULL COMMENT 'Expected Mean Square?kMHgError Mean Squared, Residue variation from analysisk/MHg',
  `StandardError` decimal(16,6) default NULL COMMENT 'standard error',
  PRIMARY KEY  (`TrialMeanId`),
  KEY `AlternateKey` (`TrialAOVId`,`GenotypeId`,`TreatmentId`),
  KEY `GenotypeId` (`GenotypeId`),
  KEY `TreatmentId` (`TreatmentId`),
  CONSTRAINT `trialmean_ibfk_1` FOREIGN KEY (`GenotypeId`) REFERENCES `genotype` (`GenotypeId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `trialmean_ibfk_2` FOREIGN KEY (`TreatmentId`) REFERENCES `treatment` (`TreatmentId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `trialmean_ibfk_3` FOREIGN KEY (`TrialAOVId`) REFERENCES `trialaov` (`TrialAOVId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `trialtrait`
--

DROP TABLE IF EXISTS `trialtrait`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `trialtrait` (
  `TrialTraitId` int(11) NOT NULL auto_increment COMMENT 'record id',
  `TrialId` int(11) NOT NULL COMMENT 'trial id',
  `TraitId` int(11) NOT NULL COMMENT 'trait id',
  `Compulsory` tinyint(1) NOT NULL default '0' COMMENT '0|1 flag indicating that this combination is compulsory to measure in the trial',
  PRIMARY KEY  (`TrialTraitId`),
  KEY `xtt_TraitId` (`TraitId`),
  KEY `xtt_TrialId` (`TrialId`),
  CONSTRAINT `trialtrait_ibfk_1` FOREIGN KEY (`TraitId`) REFERENCES `trait` (`TraitId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `trialtrait_ibfk_2` FOREIGN KEY (`TrialId`) REFERENCES `trial` (`TrialId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `trialunit`
--

DROP TABLE IF EXISTS `trialunit`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `trialunit` (
  `TrialUnitId` int(11) NOT NULL auto_increment COMMENT 'trial unit id',
  `TrialId` int(11) NOT NULL COMMENT 'trial id',
  `UnitPositionId` int(11) NOT NULL COMMENT 'unit position id',
  `TreatmentId` int(11) default NULL COMMENT 'treatment id',
  `SourceTrialUnitId` int(11) default '0' COMMENT 'Source Trial Unit that identifies the source of the sample used in the Trial Unit of the Trial. For example, the source trial unit for a wheat grain sample used in a milling trial can be a trial unit of a Wheat Variety Evaluation Trial. While importing da',
  `ReplicateNumber` int(10) NOT NULL COMMENT 'replicate number - next instance of the same specimen',
  `TrialUnitBarcode` varchar(254) default NULL COMMENT 'barcode of the trial unit (plot)',
  `TrialUnitNote` varchar(254) default NULL COMMENT 'additional description for the trial unit',
  `SampleSupplierId` int(10) default NULL COMMENT 'sample supplier id (contact or organisation, no defined relation here). Optional field to define who supplied the the seed. Choosing if this is contact or organisation is a matter for organisations convention.',
  PRIMARY KEY  (`TrialUnitId`),
  UNIQUE KEY `xtu_TrialUnitBarcode` (`TrialUnitBarcode`),
  KEY `xtu_TrialUnitPosition` (`TrialId`,`UnitPositionId`),
  KEY `xtu_SampleSupplierId` (`SampleSupplierId`),
  KEY `xtu_TreatmentId` (`TreatmentId`),
  KEY `xtu_UnitPositionId` (`UnitPositionId`),
  KEY `xtu_SourceTrialUnitId` (`SourceTrialUnitId`),
  CONSTRAINT `trialunit_ibfk_1` FOREIGN KEY (`TrialId`) REFERENCES `trial` (`TrialId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `trialunit_ibfk_2` FOREIGN KEY (`UnitPositionId`) REFERENCES `unitposition` (`UnitPositionId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `trialunitspecimen`
--

DROP TABLE IF EXISTS `trialunitspecimen`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `trialunitspecimen` (
  `TrialUnitSpecimenId` int(11) NOT NULL auto_increment COMMENT 'id of the group of specimens in trial unit',
  `SpecimenId` int(11) NOT NULL COMMENT 'id of the planted specimen',
  `TrialUnitId` int(11) NOT NULL COMMENT 'trial unit id',
  `ItemId` int(11) default NULL COMMENT 'source item (e.g. seed bag) for this particular trial unit - having it here allows to use different seed bags for each planted specimen if this is a case, link is optional as the seed source may come from other places',
  `PlantDate` date default NULL COMMENT 'date when specimen has been planted in the trial unit',
  `HarvestDate` date default NULL COMMENT 'date when specimen has been harvested from the trial unit',
  `HasDied` tinyint(4) default '0' COMMENT 'flag if specimen died',
  `Notes` varchar(254) default NULL COMMENT 'additional notes',
  PRIMARY KEY  (`TrialUnitSpecimenId`),
  KEY `xtus_TrialUnitId` (`TrialUnitId`),
  KEY `xtus_SpecimenId` (`SpecimenId`),
  KEY `xtus_PlantDate` (`PlantDate`),
  KEY `xtus_HarvestDate` (`HarvestDate`),
  KEY `xtus_ItemId` (`ItemId`),
  CONSTRAINT `trialunitspecimen_ibfk_1` FOREIGN KEY (`TrialUnitId`) REFERENCES `trialunit` (`TrialUnitId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `trialunitspecimen_ibfk_2` FOREIGN KEY (`SpecimenId`) REFERENCES `specimen` (`SpecimenId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `trialworkflow`
--

DROP TABLE IF EXISTS `trialworkflow`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `trialworkflow` (
  `TrialWorkflowId` int(11) NOT NULL auto_increment COMMENT 'internal id of trial workflow step',
  `WorkflowdefId` int(11) NOT NULL COMMENT 'id of workflow step',
  `TrialId` int(11) NOT NULL COMMENT 'id of the trial the workflow is attached to',
  `CompleteBy` datetime default NULL COMMENT 'optional deadline to complete step',
  `Completed` tinyint(4) NOT NULL default '0' COMMENT 'flag if completed - default 0',
  `ReminderAt` datetime default NULL COMMENT 'optional date and time of reminder',
  `ReminderTo` varchar(254) default NULL COMMENT 'optional e-mail list where to send reminders to',
  `Note` mediumtext COMMENT 'notes about this step',
  PRIMARY KEY  (`TrialWorkflowId`),
  KEY `twf_workflowdef` (`WorkflowdefId`),
  KEY `twf_trial` (`TrialId`),
  CONSTRAINT `trialworkflow_ibfk_1` FOREIGN KEY (`TrialId`) REFERENCES `trial` (`TrialId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `trialworkflow_ibfk_2` FOREIGN KEY (`WorkflowdefId`) REFERENCES `workflowdef` (`WorkflowdefId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `unitposition`
--

DROP TABLE IF EXISTS `unitposition`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `unitposition` (
  `UnitPositionId` int(11) NOT NULL auto_increment COMMENT 'unit position id',
  `UnitPositionText` varchar(255) NOT NULL COMMENT 'unit position description',
  PRIMARY KEY  (`UnitPositionId`),
  KEY `xup_UnitPositionText` (`UnitPositionText`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `unitpositionfactor`
--

DROP TABLE IF EXISTS `unitpositionfactor`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `unitpositionfactor` (
  `UnitPositionId` int(11) NOT NULL COMMENT 'unit position id',
  `FactorId` int(11) NOT NULL COMMENT 'factor id',
  `FactorValue` varchar(32) NOT NULL COMMENT 'value',
  PRIMARY KEY  (`UnitPositionId`,`FactorId`),
  KEY `FactorId` (`FactorId`),
  CONSTRAINT `unitpositionfactor_ibfk_1` FOREIGN KEY (`FactorId`) REFERENCES `factor` (`FactorId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `unitpositionfactor_ibfk_2` FOREIGN KEY (`UnitPositionId`) REFERENCES `unitposition` (`UnitPositionId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `workflow`
--

DROP TABLE IF EXISTS `workflow`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `workflow` (
  `WorkflowId` int(11) NOT NULL auto_increment COMMENT 'workflow internal id',
  `WorkflowName` varchar(100) NOT NULL COMMENT 'workflow name',
  `WorkflowType` int(11) NOT NULL COMMENT 'workflow type',
  `WorkflowNote` varchar(254) default NULL COMMENT 'some description about workflow',
  `IsActive` int(11) NOT NULL default '1' COMMENT 'flag if it is active',
  PRIMARY KEY  (`WorkflowId`),
  UNIQUE KEY `wf_name` (`WorkflowName`),
  KEY `wf_type` (`WorkflowType`),
  KEY `wf_active` (`IsActive`),
  CONSTRAINT `workflow_ibfk_1` FOREIGN KEY (`WorkflowType`) REFERENCES `generaltype` (`TypeId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `workflowdef`
--

DROP TABLE IF EXISTS `workflowdef`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `workflowdef` (
  `WorkflowdefId` int(11) NOT NULL auto_increment COMMENT 'workflow step id',
  `WorkflowId` int(11) NOT NULL COMMENT 'workflow id - this step is part of',
  `StepName` varchar(100) NOT NULL COMMENT 'step name',
  `StepOrder` tinyint(4) NOT NULL default '0' COMMENT 'step order',
  `StepNote` varchar(254) default NULL COMMENT 'step description',
  PRIMARY KEY  (`WorkflowdefId`),
  UNIQUE KEY `wfd_workflowname` (`WorkflowId`,`StepName`),
  KEY `wfd_workflow` (`WorkflowId`),
  KEY `wfd_name` (`StepName`),
  CONSTRAINT `workflowdef_ibfk_1` FOREIGN KEY (`WorkflowId`) REFERENCES `workflow` (`WorkflowId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

INSERT INTO `organisation` VALUES  (1,'Diversity Arrays Technology Pty Ltd');
INSERT INTO `contact` VALUES  (1,'Arrays','Diversity','','University of Canberra','02 6122 7300','','admin@example.com',1);
INSERT INTO `systemgroup` VALUES  (0,'admin','Admin group');
INSERT INTO `systemuser` VALUES  (0,'admin','dda375a9a8b5e9a809f1939a11a088e06862a253','',1,'2013-12-11 10:01:35','','human');
INSERT INTO `authorisedsystemgroup` VALUES  (1,0,0,1);

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-09-03  2:35:00
