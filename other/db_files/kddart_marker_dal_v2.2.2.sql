-- MySQL dump 10.11
--
-- Host: localhost    Database: kddart_marker_v2_2_2
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
-- Table structure for table `analgroupextract`
--

DROP TABLE IF EXISTS `analgroupextract`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `analgroupextract` (
  `AnalGroupExtractId` int(11) NOT NULL auto_increment COMMENT 'internal id',
  `ExtractId` int(11) NOT NULL COMMENT 'extract id',
  `AnalysisGroupId` int(11) NOT NULL COMMENT 'analysis group id - associated with dna extract(s)',
  `ColumnPosition` int(11) default NULL COMMENT 'column position of that extract in that analysis group in the storage file',
  PRIMARY KEY  (`AnalGroupExtractId`),
  KEY `xagde_analysisgroupid` (`AnalysisGroupId`),
  KEY `xagde_extractid` (`ExtractId`),
  CONSTRAINT `analgroupextract_ibfk_1` FOREIGN KEY (`AnalysisGroupId`) REFERENCES `analysisgroup` (`AnalysisGroupId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `analgroupextract_ibfk_2` FOREIGN KEY (`ExtractId`) REFERENCES `extract` (`ExtractId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `analysisgroup`
--

DROP TABLE IF EXISTS `analysisgroup`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `analysisgroup` (
  `AnalysisGroupId` int(11) NOT NULL auto_increment COMMENT 'id of the group',
  `AnalysisGroupName` varchar(100) NOT NULL COMMENT 'name of the group',
  `AnalysisGroupDescription` varchar(254) default NULL COMMENT 'description for the group',
  `GenotypeMarkerStateX` int(11) default NULL COMMENT 'index where the marker data are stored (X in GenotypeMarkerState table or file name for indexed flat file storage)',
  `MarkerStateType` int(11) NOT NULL default '0' COMMENT '(FK) link to general type table to markerstate class - this is best thought of as convention to decode (interpret) marker state',
  `MarkerQualityType` int(11) NOT NULL default '0' COMMENT '(FK) link to general type table to markerquality class - this is best thought of as convention to decode (interpret) marker quality value',
  `ContactId` int(11) default NULL COMMENT '(FK) link to contact, who can be analyst, data owner or analysis manager',
  `MarkerNameColumnPosition` int(11) default NULL COMMENT 'which is the column with marker name in the file',
  `MarkerSequenceColumnPosition` int(11) default NULL COMMENT 'which is the column with marker sequence in the file',
  `OwnGroupId` int(11) NOT NULL COMMENT 'group id which owns the record',
  `AccessGroupId` int(11) NOT NULL default '0' COMMENT 'group id which can access the record (different than owngroup)',
  `OwnGroupPerm` tinyint(4) NOT NULL COMMENT 'permission for the own group members',
  `AccessGroupPerm` tinyint(4) NOT NULL default '0' COMMENT 'permission for other group members',
  `OtherPerm` tinyint(4) NOT NULL default '0' COMMENT 'permission for all other system users',
  PRIMARY KEY  (`AnalysisGroupId`),
  UNIQUE KEY `xag_AnalysisGroupName` (`AnalysisGroupName`),
  KEY `xag_GenotypeMarkerState` (`GenotypeMarkerStateX`),
  KEY `xag_MarkerStateType` (`MarkerStateType`),
  KEY `xag_MarkerQualityType` (`MarkerQualityType`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `analysisgroupfactor`
--

DROP TABLE IF EXISTS `analysisgroupfactor`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `analysisgroupfactor` (
  `AnalysisGroupId` int(11) NOT NULL COMMENT 'analysis group id',
  `FactorId` int(11) NOT NULL COMMENT '(FK) id of factor column',
  `FactorValue` varchar(254) NOT NULL COMMENT 'factor value',
  PRIMARY KEY  (`AnalysisGroupId`,`FactorId`),
  KEY `xagf_FactorId` (`FactorId`),
  CONSTRAINT `analysisgroupfactor_ibfk_1` FOREIGN KEY (`AnalysisGroupId`) REFERENCES `analysisgroup` (`AnalysisGroupId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `analysisgroupmarker`
--

DROP TABLE IF EXISTS `analysisgroupmarker`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `analysisgroupmarker` (
  `AnalysisGroupMarkerId` int(11) NOT NULL auto_increment COMMENT 'internal id',
  `AnalysisGroupId` int(11) NOT NULL COMMENT 'marker was delivered in this analysis group',
  `MarkerName` varchar(60) NOT NULL COMMENT 'name of the marker',
  `MarkerSequence` mediumtext COMMENT 'sequence of the marker [ACGT]',
  `MarkerDescription` varchar(254) default NULL COMMENT 'can be any additional information about the marker like e.g. SNP position (AgT:30) or SSR primer or marker method description, etc',
  `MarkerExtRef` mediumtext COMMENT 'URL or other external reference where additional marker info can be found e.g. link to NCBI',
  `LineNumber` int(11) default NULL COMMENT 'record (line) number in the storage file in this analysis group',
  PRIMARY KEY  (`AnalysisGroupMarkerId`),
  KEY `xagm_AnalysisGroupId` (`AnalysisGroupId`),
  KEY `xagm_MarkerName` (`MarkerName`),
  CONSTRAINT `analysisgroupmarker_ibfk_1` FOREIGN KEY (`AnalysisGroupId`) REFERENCES `analysisgroup` (`AnalysisGroupId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `analysisgroupmarkerfactor`
--

DROP TABLE IF EXISTS `analysisgroupmarkerfactor`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `analysisgroupmarkerfactor` (
  `AnalysisGroupMarkerId` int(11) NOT NULL COMMENT 'Analysis group marker id',
  `FactorId` int(11) NOT NULL COMMENT '(FK) factor column id',
  `FactorValue` varchar(254) NOT NULL COMMENT 'factor value',
  PRIMARY KEY  (`AnalysisGroupMarkerId`,`FactorId`),
  KEY `xagmf_FactorId` (`FactorId`),
  CONSTRAINT `analysisgroupmarkerfactor_ibfk_1` FOREIGN KEY (`AnalysisGroupMarkerId`) REFERENCES `analysisgroupmarker` (`AnalysisGroupMarkerId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `analysisgroupmarkermap`
--

DROP TABLE IF EXISTS `analysisgroupmarkermap`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `analysisgroupmarkermap` (
  `AnalysisGroupMarkerMapId` int(11) NOT NULL auto_increment COMMENT 'internal id',
  `MarkerMapId` int(11) NOT NULL COMMENT 'which map this entry belongs to',
  `AnalysisGroupMarkerId` int(11) default NULL COMMENT 'optional relation to marker record in analysisgroupmaker table (useful when map is stand alone or it is a consensus map, where we want to refer to it through the name of the marker)',
  `MarkerName` varchar(60) default NULL COMMENT 'optional marker name in case record is not linked to analysisgroupmarker table (e.g. for consensus map)',
  `ContigName` varchar(60) NOT NULL COMMENT 'name of contig (chromosome, linkage group, scaffold, etc)',
  `ContigPosition` varchar(60) NOT NULL COMMENT 'genetic of physical position on contig',
  PRIMARY KEY  (`AnalysisGroupMarkerMapId`),
  KEY `xagmm_MarkerMapId` (`MarkerMapId`),
  KEY `xagmm_AnalysisGroupMarkerId` (`AnalysisGroupMarkerId`),
  KEY `xagmm_MarkerName` (`MarkerName`),
  KEY `xagmm_ContigName` (`ContigName`),
  KEY `xagmm_ContigPosition` (`ContigPosition`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `analysisgroupmarkermeta`
--

DROP TABLE IF EXISTS `analysisgroupmarkermeta`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `analysisgroupmarkermeta` (
  `AnalysisGroupMarkerMetaId` int(11) NOT NULL auto_increment COMMENT 'record id',
  `AnalysisGroupId` int(11) NOT NULL COMMENT 'analysis group id',
  `FactorId` int(11) NOT NULL COMMENT 'factor id - FK from factor table',
  `ColumnPosition` int(11) default NULL COMMENT 'column position - where this column is located in the file',
  PRIMARY KEY  (`AnalysisGroupMarkerMetaId`),
  KEY `xagmm_AnalysisGroupId` (`AnalysisGroupId`),
  KEY `xagmm_FactorId` (`FactorId`),
  CONSTRAINT `analysisgroupmarkermeta_ibfk_1` FOREIGN KEY (`AnalysisGroupId`) REFERENCES `analysisgroup` (`AnalysisGroupId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `extract`
--

DROP TABLE IF EXISTS `extract`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `extract` (
  `ExtractId` int(11) NOT NULL auto_increment COMMENT 'DNA extract id',
  `ParentExtractId` int(11) NOT NULL default '0' COMMENT 'id of the parent extract (e.g. aliquote from another well)',
  `PlateId` int(11) default NULL COMMENT 'plate id',
  `ItemGroupId` int(11) NOT NULL COMMENT '(FK) to itemgroup table from the core database, which could be a single or group of samples, from which the extract has been derived',
  `GenotypeId` int(11) default NULL COMMENT '(FK) optional genotype id in case specimen has more than one genotype assigned',
  `Tissue` int(11) NOT NULL COMMENT '(FK) name of the tissue from which DNA has been extracted, class atissuea in generaltype table',
  `WellRow` varchar(4) default NULL COMMENT 'optional information about well row position in the plate',
  `WellCol` varchar(4) default NULL COMMENT 'optional information about well col position in the plate',
  `Quality` varchar(30) default NULL COMMENT 'Quality description of this particular extract',
  `Status` varchar(30) default NULL COMMENT 'Status flag for this extract (e.g. dont use, old, usedup, etc)',
  PRIMARY KEY  (`ExtractId`),
  KEY `xpe_PlateId` (`PlateId`),
  KEY `xpe_ItemGroupId` (`ItemGroupId`),
  KEY `xpe_GenotypeGroupId` (`GenotypeId`),
  KEY `xpe_ParentExtractId` (`ParentExtractId`),
  KEY `xpe_Tissue` (`Tissue`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `extractfactor`
--

DROP TABLE IF EXISTS `extractfactor`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `extractfactor` (
  `ExtractId` int(11) NOT NULL COMMENT 'Extract id',
  `FactorId` int(11) NOT NULL COMMENT 'factor column id',
  `FactorValue` varchar(254) NOT NULL COMMENT 'factor value',
  PRIMARY KEY  (`ExtractId`,`FactorId`),
  KEY `xdef_FactorId` (`FactorId`),
  CONSTRAINT `extractfactor_ibfk_1` FOREIGN KEY (`ExtractId`) REFERENCES `extract` (`ExtractId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `genotypemarkermetaX`
--

DROP TABLE IF EXISTS `genotypemarkermetaX`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `genotypemarkermetaX` (
  `GenotypeMarkerMetaId` int(11) NOT NULL auto_increment COMMENT 'internal id',
  `AnalysisGroupMarkerId` int(11) NOT NULL COMMENT 'marker for which data are present',
  `FactorId` int(11) NOT NULL COMMENT '(FK) to factor table - column id',
  `Value` varchar(254) NOT NULL COMMENT 'value of the metadata for marker',
  PRIMARY KEY  (`GenotypeMarkerMetaId`),
  KEY `xgmm_AnalysisGroupMarkerId` (`AnalysisGroupMarkerId`),
  KEY `xgmm_FactorId` (`FactorId`),
  CONSTRAINT `genotypemarkermetaX_ibfk_1` FOREIGN KEY (`AnalysisGroupMarkerId`) REFERENCES `analysisgroupmarker` (`AnalysisGroupMarkerId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `genotypemarkerstateX`
--

DROP TABLE IF EXISTS `genotypemarkerstateX`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `genotypemarkerstateX` (
  `GenotypeMarkerStateId` int(11) NOT NULL auto_increment COMMENT 'record id',
  `AnalGroupExtractId` int(11) NOT NULL COMMENT 'id of analysis group extract',
  `AnalysisGroupMarkerId` int(11) NOT NULL COMMENT 'marker id from analysis group',
  `State` varchar(30) NOT NULL COMMENT 'allelic state',
  `Quality` float default NULL COMMENT 'optional quality measure',
  PRIMARY KEY  (`GenotypeMarkerStateId`),
  KEY `xgms_AnalysisGroupMarkerId` (`AnalysisGroupMarkerId`),
  KEY `xgms_AnalGroupExtractId` (`AnalGroupExtractId`),
  CONSTRAINT `genotypemarkerstateX_ibfk_1` FOREIGN KEY (`AnalGroupExtractId`) REFERENCES `analgroupextract` (`AnalGroupExtractId`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `genotypemarkerstateX_ibfk_2` FOREIGN KEY (`AnalysisGroupMarkerId`) REFERENCES `analysisgroupmarker` (`AnalysisGroupMarkerId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `markeralias`
--

DROP TABLE IF EXISTS `markeralias`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `markeralias` (
  `MarkerAliasId` int(11) NOT NULL auto_increment COMMENT 'internal id',
  `AnalysisGroupMarkerId` int(11) NOT NULL COMMENT 'marker id from analysis group',
  `MarkerAliasName` varchar(60) NOT NULL COMMENT 'string with marker alias',
  PRIMARY KEY  (`MarkerAliasId`),
  KEY `xma_AliasName` (`MarkerAliasName`),
  KEY `xma_AnalysisGroupMarkerId` (`AnalysisGroupMarkerId`),
  CONSTRAINT `markeralias_ibfk_1` FOREIGN KEY (`AnalysisGroupMarkerId`) REFERENCES `analysisgroupmarker` (`AnalysisGroupMarkerId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `markermap`
--

DROP TABLE IF EXISTS `markermap`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `markermap` (
  `MarkerMapId` int(11) NOT NULL auto_increment COMMENT 'internal map id',
  `MapName` varchar(254) NOT NULL COMMENT 'name of the map',
  `MapType` int(11) NOT NULL COMMENT '(FK) to generaltype table class agenmapa - type of the map (e.g. physical, genetic, consensus, etc)',
  `OperatorId` int(11) NOT NULL COMMENT '(FK) to systemuser - user who created the map',
  `ModelRef` mediumtext COMMENT 'model reference info - for physical maps',
  `MapDescription` mediumtext COMMENT 'general description of the map',
  `MapSoftware` varchar(254) default NULL COMMENT 'software (version) used to create the map',
  `MapParameters` mediumtext COMMENT 'map parameters (also software parameters) used for creation',
  PRIMARY KEY  (`MarkerMapId`),
  UNIQUE KEY `xmm_MapName` (`MapName`),
  KEY `xmm_MapType` (`MapType`),
  KEY `xmm_OperatorId` (`OperatorId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `markermapgroup`
--

DROP TABLE IF EXISTS `markermapgroup`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `markermapgroup` (
  `MarkerMapGroupId` int(11) NOT NULL auto_increment COMMENT 'internal id',
  `GroupName` varchar(254) NOT NULL COMMENT 'group name',
  `ChildMapId` int(11) NOT NULL COMMENT 'id of the map, which is a part of the group',
  `ParentMapId` int(11) NOT NULL COMMENT 'id of the map, which is the parent for other maps',
  PRIMARY KEY  (`MarkerMapGroupId`),
  UNIQUE KEY `xmmg_GroupName` (`GroupName`),
  KEY `xmmg_ChildMapId` (`ChildMapId`),
  KEY `xmmg_ParentMapId` (`ParentMapId`),
  CONSTRAINT `markermapgroup_ibfk_1` FOREIGN KEY (`ChildMapId`) REFERENCES `markermap` (`MarkerMapId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `plate`
--

DROP TABLE IF EXISTS `plate`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `plate` (
  `PlateId` int(11) NOT NULL auto_increment COMMENT 'plate internal id',
  `PlateName` varchar(60) NOT NULL COMMENT 'can be a barcode or some arbitrary name',
  `DateCreated` datetime NOT NULL COMMENT 'date when plate was created',
  `OperatorId` int(11) NOT NULL COMMENT '(FK) to system user, who created the plate in the system',
  `PlateType` int(11) default NULL COMMENT '(FK) type of plate (from general type class plate)',
  `PlateDescription` varchar(254) default NULL COMMENT 'some text describing it',
  `StorageId` int(11) default NULL COMMENT '(FK) to storage table in core database',
  `PlateWells` int(11) default NULL COMMENT 'Number of wells in the plate (will determine valid row and column names)',
  `PlateStatus` varchar(100) default NULL COMMENT 'Status (like destroyed, master copy, shipped for genotyping, etc)',
  PRIMARY KEY  (`PlateId`),
  UNIQUE KEY `xp_PlateName` (`PlateName`),
  KEY `xp_StorageId` (`StorageId`),
  KEY `xp_OperatorId` (`OperatorId`),
  KEY `xp_PlateType` (`PlateType`),
  KEY `xp_DateCreated` (`DateCreated`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `platefactor`
--

DROP TABLE IF EXISTS `platefactor`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `platefactor` (
  `PlateId` int(11) NOT NULL COMMENT 'plate id',
  `FactorId` int(11) NOT NULL COMMENT '(FK) factor column id',
  `FactorValue` varchar(254) NOT NULL COMMENT 'factor value',
  PRIMARY KEY  (`PlateId`,`FactorId`),
  KEY `xpf_FactorId` (`FactorId`),
  CONSTRAINT `platefactor_ibfk_1` FOREIGN KEY (`PlateId`) REFERENCES `plate` (`PlateId`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-09-03  2:35:19
