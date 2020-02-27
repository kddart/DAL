-- generated on: Mon Feb 24 15:47:34 2020
-- input file: ER_dbmodel_Marker.xml


-- Copyright (C) 2020 by Diversity Arrays Technology Pty Ltd
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


-- model name: Marker ER diagram
-- model version: 2.6.0.101

-- table analysisgroup
CREATE TABLE "analysisgroup" (
  "AnalysisGroupId" INTEGER NOT NULL AUTO_INCREMENT,
  "AnalysisGroupName" VARCHAR(100) NOT NULL,
  "AnalysisGroupDescription" VARCHAR(254) NULL,
  "ContactId" INTEGER NULL,
  "AnalysisGroupMetaData" TEXT NULL,
  "OwnGroupId" INTEGER NOT NULL,
  "AccessGroupId" INTEGER NOT NULL DEFAULT '0',
  "OwnGroupPerm" TINYINT NOT NULL,
  "AccessGroupPerm" TINYINT NOT NULL DEFAULT '0',
  "OtherPerm" TINYINT NOT NULL DEFAULT '0',
  PRIMARY KEY("AnalysisGroupId")
);

CREATE UNIQUE INDEX "xag_AnalysisGroupName" ON "analysisgroup" ("AnalysisGroupName");

CREATE  INDEX "xag_OwnGroupId" ON "analysisgroup" ("OwnGroupId");

CREATE  INDEX "xag_AccessGroupId" ON "analysisgroup" ("AccessGroupId");

CREATE  INDEX "xag_OwnGroupPerm" ON "analysisgroup" ("OwnGroupPerm");

CREATE  INDEX "xag_AccessGroupPerm" ON "analysisgroup" ("AccessGroupPerm");

CREATE  INDEX "xag_OtherPerm" ON "analysisgroup" ("OtherPerm");

-- table extract
CREATE TABLE "extract" (
  "ExtractId" INTEGER NOT NULL AUTO_INCREMENT,
  "ParentExtractId" INTEGER NULL,
  "PlateId" INTEGER NULL,
  "ItemGroupId" INTEGER NULL,
  "GenotypeId" INTEGER NULL,
  "Tissue" INTEGER NOT NULL,
  "WellRow" VARCHAR(4) NULL,
  "WellCol" VARCHAR(4) NULL,
  "Quality" VARCHAR(30) NULL,
  "Status" VARCHAR(30) NULL,
  PRIMARY KEY("ExtractId")
);

CREATE  INDEX "xpe_PlateId" ON "extract" ("PlateId");

CREATE  INDEX "xpe_ItemGroupId" ON "extract" ("ItemGroupId");

CREATE  INDEX "xpe_GenotypeId" ON "extract" ("GenotypeId");

CREATE  INDEX "xpe_ParentExtractId" ON "extract" ("ParentExtractId");

CREATE  INDEX "xpe_Tissue" ON "extract" ("Tissue");

-- table analysisgroupmarker
CREATE TABLE "analysisgroupmarker" (
  "AnalysisGroupMarkerId" INTEGER NOT NULL AUTO_INCREMENT,
  "DataSetId" INTEGER NOT NULL,
  "MarkerName" VARCHAR(60) NOT NULL,
  "MarkerSequence" TEXT NULL,
  "MarkerDescription" VARCHAR(254) NULL,
  "MarkerExtRef" TEXT NULL,
  PRIMARY KEY("AnalysisGroupMarkerId")
);

CREATE  INDEX "xagm_MarkerName" ON "analysisgroupmarker" ("MarkerName");

CREATE  INDEX "xagm_DataSetId" ON "analysisgroupmarker" ("DataSetId");

-- table plate
CREATE TABLE "plate" (
  "PlateId" INTEGER NOT NULL AUTO_INCREMENT,
  "PlateName" VARCHAR(60) NOT NULL,
  "DateCreated" TIMESTAMP NOT NULL,
  "OperatorId" INTEGER NOT NULL,
  "PlateType" INTEGER NULL,
  "PlateDescription" VARCHAR(254) NULL,
  "StorageId" INTEGER NULL,
  "PlateWells" INTEGER NULL,
  "PlateStatus" VARCHAR(100) NULL,
  "PlateMetaData" TEXT NULL,
  PRIMARY KEY("PlateId")
);

CREATE UNIQUE INDEX "xp_PlateName" ON "plate" ("PlateName");

CREATE  INDEX "xp_StorageId" ON "plate" ("StorageId");

CREATE  INDEX "xp_OperatorId" ON "plate" ("OperatorId");

CREATE  INDEX "xp_PlateType" ON "plate" ("PlateType");

CREATE  INDEX "xp_DateCreated" ON "plate" ("DateCreated");

-- table markeralias
CREATE TABLE "markeralias" (
  "MarkerAliasId" INTEGER NOT NULL AUTO_INCREMENT,
  "AnalysisGroupMarkerId" INTEGER NOT NULL,
  "MarkerAliasName" VARCHAR(60) NOT NULL,
  PRIMARY KEY("MarkerAliasId")
);

CREATE  INDEX "xma_AliasName" ON "markeralias" ("MarkerAliasName");

CREATE  INDEX "xma_AnalysisGroupMarkerId" ON "markeralias" ("AnalysisGroupMarkerId");

-- table extractfactor
CREATE TABLE "extractfactor" (
  "ExtractId" INTEGER NOT NULL,
  "FactorId" INTEGER NOT NULL,
  "FactorValue" VARCHAR(254) NOT NULL,
  PRIMARY KEY("ExtractId", "FactorId")
);

CREATE  INDEX "xdef_FactorId" ON "extractfactor" ("FactorId");

-- table platefactor
CREATE TABLE "platefactor" (
  "PlateId" INTEGER NOT NULL,
  "FactorId" INTEGER NOT NULL,
  "FactorValue" VARCHAR(254) NOT NULL,
  PRIMARY KEY("PlateId", "FactorId")
);

CREATE  INDEX "xpf_FactorId" ON "platefactor" ("FactorId");

-- table analysisgroupfactor
CREATE TABLE "analysisgroupfactor" (
  "AnalysisGroupId" INTEGER NOT NULL,
  "FactorId" INTEGER NOT NULL,
  "FactorValue" VARCHAR(254) NOT NULL,
  PRIMARY KEY("AnalysisGroupId", "FactorId")
);

CREATE  INDEX "xagf_FactorId" ON "analysisgroupfactor" ("FactorId");

-- table analgroupextract
CREATE TABLE "analgroupextract" (
  "AnalGroupExtractId" INTEGER NOT NULL AUTO_INCREMENT,
  "ExtractId" INTEGER NOT NULL,
  "AnalysisGroupId" INTEGER NOT NULL,
  PRIMARY KEY("AnalGroupExtractId")
);

CREATE  INDEX "xagde_analysisgroupid" ON "analgroupextract" ("AnalysisGroupId");

CREATE  INDEX "xagde_extractid" ON "analgroupextract" ("ExtractId");

-- table markermap
CREATE TABLE "markermap" (
  "MarkerMapId" INTEGER NOT NULL AUTO_INCREMENT,
  "MapName" VARCHAR(254) NOT NULL,
  "MapType" INTEGER NOT NULL,
  "OperatorId" INTEGER NOT NULL,
  "ModelRef" TEXT NULL,
  "MapDescription" TEXT NULL,
  "MapSoftware" VARCHAR(254) NULL,
  "MapParameters" TEXT NULL,
  PRIMARY KEY("MarkerMapId")
);

CREATE UNIQUE INDEX "xmm_MapName" ON "markermap" ("MapName");

CREATE  INDEX "xmm_MapType" ON "markermap" ("MapType");

CREATE  INDEX "xmm_OperatorId" ON "markermap" ("OperatorId");

-- table markermapgroup
CREATE TABLE "markermapgroup" (
  "MarkerMapGroupId" INTEGER NOT NULL AUTO_INCREMENT,
  "GroupName" VARCHAR(254) NOT NULL,
  "ChildMapId" INTEGER NOT NULL,
  "ParentMapId" INTEGER NOT NULL,
  PRIMARY KEY("MarkerMapGroupId")
);

CREATE  INDEX "xmmg_ChildMapId" ON "markermapgroup" ("ChildMapId");

CREATE  INDEX "xmmg_ParentMapId" ON "markermapgroup" ("ParentMapId");

CREATE UNIQUE INDEX "xmmg_GroupName" ON "markermapgroup" ("GroupName");

-- table markermapposition
CREATE TABLE "markermapposition" (
  "MarkerMapPositionId" INTEGER NOT NULL AUTO_INCREMENT,
  "AnalysisGroupMarkerId" INTEGER NULL,
  "MarkerMapId" INTEGER NOT NULL,
  "MarkerName" VARCHAR(60) NULL,
  "ContigName" VARCHAR(60) NOT NULL,
  "ContigPosition" VARCHAR(60) NOT NULL,
  PRIMARY KEY("MarkerMapPositionId")
);

CREATE  INDEX "xagmm_MarkerMapId" ON "markermapposition" ("MarkerMapId");

CREATE  INDEX "xagmm_MarkerName" ON "markermapposition" ("MarkerName");

CREATE  INDEX "xagmm_ContigName" ON "markermapposition" ("ContigName");

CREATE  INDEX "xagmm_ContigPosition" ON "markermapposition" ("ContigPosition");

CREATE  INDEX "xagmm_AnalysisGroupMarkerId" ON "markermapposition" ("AnalysisGroupMarkerId");

-- table dataset
CREATE TABLE "dataset" (
  "DataSetId" INTEGER NOT NULL AUTO_INCREMENT,
  "AnalysisGroupId" INTEGER NOT NULL,
  "MarkerNameFieldName" VARCHAR(254) NULL,
  "MarkerSequenceFieldName" VARCHAR(254) NULL,
  "ParentDataSetId" INTEGER NULL,
  "DataSetType" INTEGER NOT NULL,
  "Description" VARCHAR(254) NULL,
  PRIMARY KEY("DataSetId")
);

CREATE  INDEX "xds_AnalysisGroupId" ON "dataset" ("AnalysisGroupId");

CREATE  INDEX "xds_ParentDataSetId" ON "dataset" ("ParentDataSetId");

-- table datasetmarkermeta
CREATE TABLE "datasetmarkermeta" (
  "DataSetMarkerMetaId" INTEGER NOT NULL AUTO_INCREMENT,
  "DataSetId" INTEGER NULL,
  "FactorId" INTEGER NULL,
  "FieldName" VARCHAR(254) NULL,
  PRIMARY KEY("DataSetMarkerMetaId")
);

CREATE  INDEX "xdsmm_DataSetId" ON "datasetmarkermeta" ("DataSetId");

CREATE  INDEX "xdsmm_FactorId" ON "datasetmarkermeta" ("FactorId");

-- table datasetextract
CREATE TABLE "datasetextract" (
  "DataSetExtractId" INTEGER NOT NULL AUTO_INCREMENT,
  "DataSetId" INTEGER NULL,
  "AnalGroupExtractId" INTEGER NULL,
  "FieldName" VARCHAR(254) NULL,
  PRIMARY KEY("DataSetExtractId")
);

CREATE  INDEX "xdse_DataSetId" ON "datasetextract" ("DataSetId");

CREATE  INDEX "xdse_AnalGroupExtractId" ON "datasetextract" ("AnalGroupExtractId");

-- table fieldcomment
CREATE TABLE "fieldcomment" (
  "TableName" VARCHAR(254) NOT NULL,
  "FieldName" VARCHAR(254) NOT NULL,
  "FieldComment" TEXT NOT NULL,
  "PrimaryKey" TINYINT NOT NULL,
  PRIMARY KEY("TableName", "FieldName")
);



ALTER TABLE "extract" ADD FOREIGN KEY ("PlateId")
  REFERENCES "plate" ("PlateId") 
  ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE "extractfactor" ADD FOREIGN KEY ("ExtractId")
  REFERENCES "extract" ("ExtractId") 
  ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE "platefactor" ADD FOREIGN KEY ("PlateId")
  REFERENCES "plate" ("PlateId") 
  ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE "analysisgroupfactor" ADD FOREIGN KEY ("AnalysisGroupId")
  REFERENCES "analysisgroup" ("AnalysisGroupId") 
  ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE "analgroupextract" ADD FOREIGN KEY ("AnalysisGroupId")
  REFERENCES "analysisgroup" ("AnalysisGroupId") 
  ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE "analgroupextract" ADD FOREIGN KEY ("ExtractId")
  REFERENCES "extract" ("ExtractId") 
  ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE "markeralias" ADD FOREIGN KEY ("AnalysisGroupMarkerId")
  REFERENCES "analysisgroupmarker" ("AnalysisGroupMarkerId") 
  ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE "markermapgroup" ADD FOREIGN KEY ("ChildMapId")
  REFERENCES "markermap" ("MarkerMapId") 
  ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE "analysisgroupmarker" ADD FOREIGN KEY ("DataSetId")
  REFERENCES "dataset" ("DataSetId") 
  ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE "dataset" ADD FOREIGN KEY ("AnalysisGroupId")
  REFERENCES "analysisgroup" ("AnalysisGroupId") 
  ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE "datasetmarkermeta" ADD FOREIGN KEY ("DataSetId")
  REFERENCES "dataset" ("DataSetId") 
  ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE "datasetextract" ADD FOREIGN KEY ("DataSetId")
  REFERENCES "dataset" ("DataSetId") 
  ON DELETE NO ACTION ON UPDATE NO ACTION;

-- field comments

INSERT INTO "fieldcomment" ("TableName", "FieldName", "FieldComment", "PrimaryKey") VALUES ('analysisgroup', 'AnalysisGroupId', 'id of the group', 1),
('analysisgroup', 'AnalysisGroupName', 'name of the group', 0),
('analysisgroup', 'AnalysisGroupDescription', 'description for the group', 0),
('analysisgroup', 'ContactId', '(FK) link to contact, who can be analyst, data owner or analysis manager', 0),
('analysisgroup', 'AnalysisGroupMetaData', 'Meta data for analysis group in JSON serialize format', 0),
('analysisgroup', 'OwnGroupId', 'group id which owns the record', 0),
('analysisgroup', 'AccessGroupId', 'group id which can access the record (different than owngroup)', 0),
('analysisgroup', 'OwnGroupPerm', 'permission for the own group members', 0),
('analysisgroup', 'AccessGroupPerm', 'permission for other group members', 0),
('analysisgroup', 'OtherPerm', 'permission for all other system users', 0),
('extract', 'ExtractId', 'DNA extract id', 1),
('extract', 'ParentExtractId', 'id of the parent extract (e.g. aliquote from another well)', 0),
('extract', 'PlateId', 'plate id', 0),
('extract', 'ItemGroupId', '(FK) to itemgroup table from the core database, which could be a single or group of samples, from which the extract has been derived', 0),
('extract', 'GenotypeId', '(FK) optional genotype id in case specimen has more than one genotype assigned', 0),
('extract', 'Tissue', '(FK) name of the tissue from which DNA has been extracted, class tissue in generaltype table', 0),
('extract', 'WellRow', 'optional information about well row position in the plate', 0),
('extract', 'WellCol', 'optional information about well col position in the plate', 0),
('extract', 'Quality', 'Quality description of this particular extract', 0),
('extract', 'Status', 'Status flag for this extract (e.g. dont use, old, usedup, etc)', 0),
('analysisgroupmarker', 'AnalysisGroupMarkerId', 'internal id', 1),
('analysisgroupmarker', 'DataSetId', 'data set id, where marker belongs to', 0),
('analysisgroupmarker', 'MarkerName', 'name of the marker', 0),
('analysisgroupmarker', 'MarkerSequence', 'sequence of the marker [e.g. ACGT]', 0),
('analysisgroupmarker', 'MarkerDescription', 'can be any additional information about the marker like e.g. SNP position (A\gT:30) or SSR primer or marker method description, etc', 0),
('analysisgroupmarker', 'MarkerExtRef', 'URL or other external reference where additional marker info can be found e.g. link to NCBI', 0),
('plate', 'PlateId', 'plate internal id', 1),
('plate', 'PlateName', 'can be a barcode or some arbitrary name', 0),
('plate', 'DateCreated', 'date when plate was created', 0),
('plate', 'OperatorId', '(FK) to system user, who created the plate in the system', 0),
('plate', 'PlateType', '(FK) type of plate (from general type class plate)', 0),
('plate', 'PlateDescription', 'some text describing it', 0),
('plate', 'StorageId', '(FK) to storage table in core database', 0),
('plate', 'PlateWells', 'Number of wells in the plate (will determine valid row and column names)', 0),
('plate', 'PlateStatus', 'Status (like destroyed, master copy, shipped for genotyping, etc)', 0),
('plate', 'PlateMetaData', 'Meta data for plate in JSON serialized format', 0),
('markeralias', 'MarkerAliasId', 'internal id', 1),
('markeralias', 'AnalysisGroupMarkerId', 'original marker id', 0),
('markeralias', 'MarkerAliasName', 'string with marker alias', 0),
('extractfactor', 'ExtractId', 'Extract id', 1),
('extractfactor', 'FactorId', 'factor column id', 1),
('extractfactor', 'FactorValue', 'factor value', 0),
('platefactor', 'PlateId', 'plate id', 1),
('platefactor', 'FactorId', '(FK) factor column id', 1),
('platefactor', 'FactorValue', 'factor value', 0),
('analysisgroupfactor', 'AnalysisGroupId', 'analysis group id', 1),
('analysisgroupfactor', 'FactorId', '(FK) id of factor column', 1),
('analysisgroupfactor', 'FactorValue', 'factor value', 0),
('analgroupextract', 'AnalGroupExtractId', 'internal id', 1),
('analgroupextract', 'ExtractId', 'extract id', 0),
('analgroupextract', 'AnalysisGroupId', 'analysis group id - associated with dna extract(s)', 0),
('markermap', 'MarkerMapId', 'internal map id', 1),
('markermap', 'MapName', 'name of the map', 0),
('markermap', 'MapType', '(FK) to generaltype table class genmap - type of the map (e.g. physical, genetic, consensus, etc)', 0),
('markermap', 'OperatorId', '(FK) to systemuser - user who created the map', 0),
('markermap', 'ModelRef', 'model reference info - for physical maps', 0),
('markermap', 'MapDescription', 'general description of the map', 0),
('markermap', 'MapSoftware', 'software (version) used to create the map', 0),
('markermap', 'MapParameters', 'map parameters (also software parameters) used for creation', 0),
('markermapgroup', 'MarkerMapGroupId', 'internal id', 1),
('markermapgroup', 'GroupName', 'group name', 0),
('markermapgroup', 'ChildMapId', 'id of the map, which is a part of the group', 0),
('markermapgroup', 'ParentMapId', 'id of the map, which is the parent for other maps', 0),
('markermapposition', 'MarkerMapPositionId', 'internal id', 1),
('markermapposition', 'AnalysisGroupMarkerId', 'analysis group marker id - if linked with particular marker', 0),
('markermapposition', 'MarkerMapId', 'which map this entry belongs to', 0),
('markermapposition', 'MarkerName', 'optional marker name in case record is not linked to analysisgroupmarker table (e.g. for consensus map)', 0),
('markermapposition', 'ContigName', 'name of contig (chromosome, linkage group, scaffold, etc)', 0),
('markermapposition', 'ContigPosition', 'genetic of physical position on contig', 0),
('dataset', 'DataSetId', 'internal id', 1),
('dataset', 'AnalysisGroupId', 'analysis group id', 0),
('dataset', 'MarkerNameFieldName', 'field name of the marker name in the actual data set table e.g. CloneId', 0),
('dataset', 'MarkerSequenceFieldName', 'field name of the marker sequence in the actual data set table e.g. Sequence', 0),
('dataset', 'ParentDataSetId', 'parent data set to which this data set is complement', 0),
('dataset', 'DataSetType', 'type of data set e.g. scoring, count or other quality data', 0),
('dataset', 'Description', 'optional description of the data set', 0),
('datasetmarkermeta', 'DataSetMarkerMetaId', 'internal id', 1),
('datasetmarkermeta', 'DataSetId', 'data set id', 0),
('datasetmarkermeta', 'FactorId', 'factor id - link to factor table in the core module', 0),
('datasetmarkermeta', 'FieldName', 'field name of the meta data in the actual data set table', 0),
('datasetextract', 'DataSetExtractId', 'internal id', 1),
('datasetextract', 'DataSetId', 'data set id', 0),
('datasetextract', 'AnalGroupExtractId', 'analysis group extract id', 0),
('datasetextract', 'FieldName', 'field name for the extract in the actual data set table', 0),
('fieldcomment', 'TableName', 'name of the table', 1),
('fieldcomment', 'FieldName', 'name of the field', 1),
('fieldcomment', 'FieldComment', 'comment for the field in the table', 0),
('fieldcomment', 'PrimaryKey', '[0|1] flag if field is primary key', 0);
