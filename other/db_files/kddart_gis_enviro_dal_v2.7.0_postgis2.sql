-- generated on: Fri Nov 25 15:18:14 2022
-- input file: ER_dbmodel_GIS_Enviro-2.7.0.xml


-- Copyright (C) 2022 by Diversity Arrays Technology Pty Ltd
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


-- model name: GIS enviro ER diagram
-- model version: 2.7.0


-- postgis definition for version 2.x
CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE "layer" (
  "id" serial NOT NULL,
  "parent" bigint,
  "name" character varying(100) NOT NULL,
  "alias" character varying(100),
  "layertype" character varying(30) DEFAULT 'layer' NOT NULL,
  "layermetadata" text,
  "iseditable" smallint DEFAULT 1 NOT NULL,
  "createuser" bigint DEFAULT 0 NOT NULL,
  "createtime" timestamp NOT NULL,
  "lastupdateuser" bigint NOT NULL,
  "lastupdatetime" timestamp NOT NULL,
  "srid" bigint DEFAULT 4326 NOT NULL,
  "geometrytype" character varying(30) NOT NULL,
  "description" character varying(254),
  "owngroupid" bigint NOT NULL,
  "accessgroupid" bigint DEFAULT 0 NOT NULL,
  "owngroupperm" smallint NOT NULL,
  "accessgroupperm" smallint DEFAULT 0 NOT NULL,
  "otherperm" smallint DEFAULT 0 NOT NULL,
  CONSTRAINT "xlayer_name" UNIQUE ("name"),
  PRIMARY KEY ("id")
);
CREATE INDEX "xlayer_parent" on "layer" ("parent");
CREATE INDEX "xlayer_owngroupid" on "layer" ("owngroupid");
CREATE INDEX "xlayer_accessgroupid" on "layer" ("accessgroupid");
CREATE INDEX "xlayer_owngroupperm" on "layer" ("owngroupperm");
CREATE INDEX "xlayer_accessgroupperm" on "layer" ("accessgroupperm");
CREATE INDEX "xlayer_otherperm" on "layer" ("otherperm");

CREATE TABLE "layerattrib" (
  "id" serial NOT NULL,
  "unitid" bigint NOT NULL,
  "layer" bigint NOT NULL,
  "colname" character varying(100) NOT NULL,
  "coltype" character varying(30) NOT NULL,
  "colsize" bigint NOT NULL,
  "validation" character varying(254),
  "colunits" character varying(100) NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "xlayerattrib_layer" on "layerattrib" ("layer");
CREATE INDEX "xlayerattrib_unitid" on "layerattrib" ("unitid");

CREATE TABLE "layern" (
  "id" serial NOT NULL,
  "geometry" geography(GEOMETRYCOLLECTION, 4326) NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "xln_geometry" on "layern" USING GIST  ("geometry");

CREATE TABLE "layernattrib" (
  "id" serial NOT NULL,
  "layerid" bigint NOT NULL,
  "layerattrib" bigint NOT NULL,
  "value" character varying(254),
  "dt" timestamp,
  "systemuserid" bigint,
  "deviceid" character varying(100),
  PRIMARY KEY ("id")
);
CREATE INDEX "xlayernattrib_dt" on "layernattrib" ("dt");
CREATE INDEX "xlayernattrib_sysuid" on "layernattrib" ("systemuserid");
CREATE INDEX "xlayernattrib_layerattrib" on "layernattrib" ("layerattrib");
CREATE INDEX "xlayernattrib_layerid" on "layernattrib" ("layerid");
CREATE INDEX "xlayernattrib_deviceid" on "layernattrib" ("deviceid");

CREATE TABLE "siteloc" (
  "sitelocid" serial NOT NULL,
  "siteid" bigint NOT NULL,
  "sitelocation" geography(MULTIPOLYGON, 4326) NOT NULL,
  "sitelocdt" timestamp NOT NULL,
  "currentloc" smallint NOT NULL,
  "description" character varying(254),
  PRIMARY KEY ("sitelocid")
);
CREATE INDEX "xsl_sitelocation" on "siteloc" USING GIST  ("sitelocation");
CREATE INDEX "xsl_siteid" on "siteloc" ("siteid");
CREATE INDEX "xsl_sitelocdt" on "siteloc" ("sitelocdt");
CREATE INDEX "xsl_currentloc" on "siteloc" ("currentloc");

CREATE TABLE "trialloc" (
  "triallocid" serial NOT NULL,
  "trialid" bigint NOT NULL,
  "triallocation" geography(MULTIPOLYGON, 4326) NOT NULL,
  "triallocdt" timestamp NOT NULL,
  "currentloc" smallint NOT NULL,
  "description" character varying(254),
  PRIMARY KEY ("triallocid")
);
CREATE INDEX "xtl_triallocation" on "trialloc" USING GIST  ("triallocation");
CREATE INDEX "xtl_trialid" on "trialloc" ("trialid");
CREATE INDEX "xtl_triallocdt" on "trialloc" ("triallocdt");
CREATE INDEX "xtl_currentloc" on "trialloc" ("currentloc");

CREATE TABLE "trialunitloc" (
  "trialunitlocid" serial NOT NULL,
  "trialunitid" bigint NOT NULL,
  "trialunitlocation" geography(GEOMETRYCOLLECTION, 4326) NOT NULL,
  "trialunitlocdt" timestamp NOT NULL,
  "currentloc" smallint NOT NULL,
  "description" character varying(254),
  PRIMARY KEY ("trialunitlocid")
);
CREATE INDEX "xtul_trialunitlocation" on "trialunitloc" USING GIST  ("trialunitlocation");
CREATE INDEX "xtul_trialunitid" on "trialunitloc" ("trialunitid");
CREATE INDEX "xtul_trialunitlocdt" on "trialunitloc" ("trialunitlocdt");
CREATE INDEX "xtul_currentloc" on "trialunitloc" ("currentloc");

CREATE TABLE "contactloc" (
  "contactlocid" serial NOT NULL,
  "contactid" bigint NOT NULL,
  "contactlocation" geography(MULTIPOINT, 4326) NOT NULL,
  "contactlocdt" timestamp NOT NULL,
  "currentloc" smallint NOT NULL,
  "description" character varying(254),
  PRIMARY KEY ("contactlocid")
);
CREATE INDEX "xcl_contactlocation" on "contactloc" USING GIST  ("contactlocation");
CREATE INDEX "xcl_contactid" on "contactloc" ("contactid");
CREATE INDEX "xcl_contactlocdt" on "contactloc" ("contactlocdt");
CREATE INDEX "xcl_currentloc" on "contactloc" ("currentloc");

CREATE TABLE "datadevice" (
  "layerattrib" bigint NOT NULL,
  "deviceid" character varying(100) NOT NULL,
  "deviceparam" character varying NOT NULL,
  "active" smallint DEFAULT 1 NOT NULL,
  CONSTRAINT "xdatadevice_unique" UNIQUE ("deviceid", "deviceparam", "layerattrib")
);
CREATE INDEX "xdatadevice_layerattrib" on "datadevice" ("layerattrib");

CREATE TABLE "layer2dn" (
  "id" serial NOT NULL,
  "geometry" geography(GEOMETRYCOLLECTION, 4326) NOT NULL,
  "attributex" bigint,
  PRIMARY KEY ("id")
);
CREATE INDEX "xl2d_geometry" on "layer2dn" USING GIST  ("geometry");

CREATE TABLE "specimenloc" (
  "specimenlocid" serial NOT NULL,
  "specimenid" bigint NOT NULL,
  "specimenlocation" geography(GEOMETRYCOLLECTION, 4326) NOT NULL,
  "specimenlocdt" timestamp NOT NULL,
  "currentloc" smallint NOT NULL,
  "description" character varying(254),
  PRIMARY KEY ("specimenlocid")
);
CREATE INDEX "xspl_specimenid" on "specimenloc" ("specimenid");
CREATE INDEX "xspl_specimenlocation" on "specimenloc" USING GIST  ("specimenlocation");
CREATE INDEX "xspl_specimenlocdt" on "specimenloc" ("specimenlocdt");
CREATE INDEX "xspl_currentloc" on "specimenloc" ("currentloc");

CREATE TABLE "surveyloc" (
  "surveylocid" serial NOT NULL,
  "surveyid" bigint NOT NULL,
  "surveylocation" geography(GEOMETRYCOLLECTION, 4326) NOT NULL,
  "surveylocdt" timestamp NOT NULL,
  "currentloc" smallint NOT NULL,
  "description" character varying(254),
  PRIMARY KEY ("surveylocid")
);
CREATE INDEX "xsul_surveyid" on "surveyloc" ("surveyid");
CREATE INDEX "xsul_surveylocation" on "surveyloc" USING GIST  ("surveylocation");
CREATE INDEX "xsul_surveylocdt" on "surveyloc" ("surveylocdt");
CREATE INDEX "xsul_currentloc" on "surveyloc" ("currentloc");

CREATE TABLE "storageloc" (
  "storagelocid" serial NOT NULL,
  "storageid" bigint NOT NULL,
  "storagelocation" geography(GEOMETRYCOLLECTION, 4326) NOT NULL,
  "storagelocdt" timestamp NOT NULL,
  "currentloc" smallint NOT NULL,
  "description" character varying(254),
  PRIMARY KEY ("storagelocid")
);
CREATE INDEX "xstl_storageid" on "storageloc" ("storageid");
CREATE INDEX "xstl_storagelocation" on "storageloc" USING GIST  ("storagelocation");
CREATE INDEX "xstl_storagelocdt" on "storageloc" ("storagelocdt");
CREATE INDEX "xstl_currentloc" on "storageloc" ("currentloc");

CREATE TABLE "tileset" (
  "id" bigint NOT NULL,
  "geometry" geometry,
  "resolution" bigint NOT NULL,
  "minzoom" bigint NOT NULL,
  "maxzoom" bigint NOT NULL,
  "tilepath" character varying(254) NOT NULL,
  "spectrum" character varying(254),
  "tilestatus" character varying(254) NOT NULL,
  "imagetype" character varying(245) NOT NULL,
  "description" text,
  "metadata" text,
  "source" text,
  PRIMARY KEY ("id")
);
CREATE INDEX "ts_resolution" on "tileset" ("resolution");
CREATE INDEX "ts_minzoom" on "tileset" ("minzoom");
CREATE INDEX "ts_maxzoom" on "tileset" ("maxzoom");
CREATE INDEX "ts_tilestatus" on "tileset" ("tilestatus");
CREATE INDEX "ts_geometry" on "tileset" USING GIST  ("geometry");

CREATE TABLE "tiles" (
  "id" serial NOT NULL,
  "tileset" bigint NOT NULL,
  "geometry" geography(GEOMETRYCOLLECTION, 4326) NOT NULL,
  "xcoord" bigint NOT NULL,
  "ycoord" bigint NOT NULL,
  "zoomlevel" bigint NOT NULL
);
CREATE INDEX "tiles_idx_1" on "tiles" ("id");
CREATE INDEX "tiles_tileset" on "tiles" ("tileset");
CREATE INDEX "tiles_geometry" on "tiles" USING GIST  ("geometry");
CREATE INDEX "tiles_xcoord" on "tiles" ("xcoord");
CREATE INDEX "tiles_ycoord" on "tiles" ("ycoord");
CREATE INDEX "tiles_zoomlevel" on "tiles" ("zoomlevel");

ALTER TABLE "layer" ADD FOREIGN KEY ("parent")
  REFERENCES "layer" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "layerattrib" ADD FOREIGN KEY ("layer")
  REFERENCES "layer" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "layernattrib" ADD FOREIGN KEY ("layerattrib")
  REFERENCES "layerattrib" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "layernattrib" ADD FOREIGN KEY ("layerid")
  REFERENCES "layern" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "datadevice" ADD FOREIGN KEY ("layerattrib")
  REFERENCES "layerattrib" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "tileset" ADD FOREIGN KEY ("id")
  REFERENCES "layer" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "tiles" ADD FOREIGN KEY ("tileset")
  REFERENCES "tileset" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;


-- field comments

COMMENT ON COLUMN layer.id IS 'internal id';

COMMENT ON COLUMN layer.parent IS 'id of the parent layer';

COMMENT ON COLUMN layer.name IS 'layer name';

COMMENT ON COLUMN layer.alias IS 'layer alias';

COMMENT ON COLUMN layer.layertype IS 'layer, layer2d, layerimg - these three values refer to the base name of the real layer';

COMMENT ON COLUMN layer.layermetadata IS 'metadata for a layer. Can be a piece of xml or some sort of other agreed convention to store info about data';

COMMENT ON COLUMN layer.iseditable IS '0|1 flag defining if layer can be edited. Set to 0 to disable edits.';

COMMENT ON COLUMN layer.createuser IS 'id of the system user, who created the layer';

COMMENT ON COLUMN layer.createtime IS 'date and time of the layer creation';

COMMENT ON COLUMN layer.lastupdateuser IS 'id of the system user, who last updated the layer info or field definition (not a data in the layer!)';

COMMENT ON COLUMN layer.lastupdatetime IS 'date and time of layer info or definition update';

COMMENT ON COLUMN layer.srid IS 'spatial reference id - refer to http://en.wikipedia.org/wiki/SRID';

COMMENT ON COLUMN layer.geometrytype IS 'for internal layers this is the type of the geometry column in LayerN table, have to match OGC standards (POINT, MULTIPOINT, POLYGON .. etc)';

COMMENT ON COLUMN layer.description IS 'layer description';

COMMENT ON COLUMN layer.owngroupid IS 'group id which owns the record';

COMMENT ON COLUMN layer.accessgroupid IS 'group id which can access the record (different than owngroup)';

COMMENT ON COLUMN layer.owngroupperm IS 'permission for the own group members';

COMMENT ON COLUMN layer.accessgroupperm IS 'permission for the other group members';

COMMENT ON COLUMN layer.otherperm IS 'permission for all the other system users';

COMMENT ON COLUMN layerattrib.id IS 'internal id';

COMMENT ON COLUMN layerattrib.unitid IS 'unitid (FK) to generalunit table in core structure';

COMMENT ON COLUMN layerattrib.layer IS 'layer id';

COMMENT ON COLUMN layerattrib.colname IS 'name of the attribute column';

COMMENT ON COLUMN layerattrib.coltype IS 'type of the column';

COMMENT ON COLUMN layerattrib.colsize IS 'size of the column';

COMMENT ON COLUMN layerattrib.validation IS 'rules for value validation';

COMMENT ON COLUMN layerattrib.colunits IS 'what units the value is in (e.g. deg Celsius, km, percent)';

COMMENT ON COLUMN layern.id IS 'internal id';

COMMENT ON COLUMN layern.geometry IS 'geo object of some geometrical type - should have spatial index GIST in PostGIS!!!';

COMMENT ON COLUMN layernattrib.id IS 'internal id';

COMMENT ON COLUMN layernattrib.layerid IS 'id of the geometric object in layern table';

COMMENT ON COLUMN layernattrib.layerattrib IS 'layer attribute id';

COMMENT ON COLUMN layernattrib.value IS 'value of the parameter';

COMMENT ON COLUMN layernattrib.dt IS 'date and time';

COMMENT ON COLUMN layernattrib.systemuserid IS 'system user, who inserted the data value (links to core database)';

COMMENT ON COLUMN layernattrib.deviceid IS 'device id used to measure this data point - one of the devices registered in the system';

COMMENT ON COLUMN siteloc.sitelocid IS 'internal id of the site location';

COMMENT ON COLUMN siteloc.siteid IS '(FK) site id from main database';

COMMENT ON COLUMN siteloc.sitelocation IS 'polygon geometry for site - should have spatial index GIST in PostGIS!!!';

COMMENT ON COLUMN siteloc.sitelocdt IS 'creation date of the site location';

COMMENT ON COLUMN siteloc.currentloc IS 'flag indicating if the location is current';

COMMENT ON COLUMN siteloc.description IS 'location description - optional';

COMMENT ON COLUMN trialloc.triallocid IS 'internal id of the site location';

COMMENT ON COLUMN trialloc.trialid IS '(FK) trial id from the main database';

COMMENT ON COLUMN trialloc.triallocation IS 'geometry object for the trial - should have spatial index GIST in PostGIS!!!';

COMMENT ON COLUMN trialloc.triallocdt IS 'creation date of the trial location';

COMMENT ON COLUMN trialloc.currentloc IS 'flag indicating if the location is current';

COMMENT ON COLUMN trialloc.description IS 'location description - optional';

COMMENT ON COLUMN trialunitloc.trialunitlocid IS 'internal id of the trial unit location';

COMMENT ON COLUMN trialunitloc.trialunitid IS '(FK) trial unit id from the main database';

COMMENT ON COLUMN trialunitloc.trialunitlocation IS 'geometry of the trial unit - should have spatial index GIST in PostGIS!!!';

COMMENT ON COLUMN trialunitloc.trialunitlocdt IS 'creation date of the trial unit location';

COMMENT ON COLUMN trialunitloc.currentloc IS 'flag indicating if the location is current';

COMMENT ON COLUMN trialunitloc.description IS 'location description - optional';

COMMENT ON COLUMN contactloc.contactlocid IS 'internal id of contact location';

COMMENT ON COLUMN contactloc.contactid IS '(FK) contact id from the main database';

COMMENT ON COLUMN contactloc.contactlocation IS 'contact location - should have spatial index GIST in PostGIS!!!';

COMMENT ON COLUMN contactloc.contactlocdt IS 'creation date of the contact location';

COMMENT ON COLUMN contactloc.currentloc IS 'flag indicating if the location is current';

COMMENT ON COLUMN contactloc.description IS 'location description - optional';

COMMENT ON COLUMN datadevice.layerattrib IS 'id of the attribute column of the layer where this device will be logging into';

COMMENT ON COLUMN datadevice.deviceid IS '(FK) Device Id from the core database - DeviceRegister table';

COMMENT ON COLUMN datadevice.deviceparam IS 'Name of the parameter from the device for that attribute';

COMMENT ON COLUMN datadevice.active IS '[0,1] flag to indicate if this definition is active. Definitions should not be removed';

COMMENT ON COLUMN layer2dn.id IS 'numeric id of the geometric object';

COMMENT ON COLUMN layer2dn.geometry IS 'geometric object';

COMMENT ON COLUMN layer2dn.attributex IS 'list of attributes defined in layerattrib table for this layer';

COMMENT ON COLUMN specimenloc.specimenlocid IS 'internal id of the specimen location';

COMMENT ON COLUMN specimenloc.specimenid IS '(FK) specimen id from main database';

COMMENT ON COLUMN specimenloc.specimenlocation IS 'geometry for the specimen - should have spatial index GIST in PostGIS!!!';

COMMENT ON COLUMN specimenloc.specimenlocdt IS 'creation date of the specimen location';

COMMENT ON COLUMN specimenloc.currentloc IS 'flag indicating if the location is current';

COMMENT ON COLUMN specimenloc.description IS 'location description - optional';

COMMENT ON COLUMN surveyloc.surveylocid IS 'internal id of the survey location';

COMMENT ON COLUMN surveyloc.surveyid IS '(FK) survey id from main database';

COMMENT ON COLUMN surveyloc.surveylocation IS 'geometry for survey - should have spatial index GIST in PostGIS!!!';

COMMENT ON COLUMN surveyloc.surveylocdt IS 'creation date of the survey location';

COMMENT ON COLUMN surveyloc.currentloc IS 'flag indicating if the location is current';

COMMENT ON COLUMN surveyloc.description IS 'location description - optional';

COMMENT ON COLUMN storageloc.storagelocid IS 'internal id of the storage location';

COMMENT ON COLUMN storageloc.storageid IS '(FK) storage id from main database';

COMMENT ON COLUMN storageloc.storagelocation IS 'geometry for storage - should have spatial index GIST in PostGIS!!! ';

COMMENT ON COLUMN storageloc.storagelocdt IS 'creation date of the storage location';

COMMENT ON COLUMN storageloc.currentloc IS 'flag indicating if the location is current';

COMMENT ON COLUMN storageloc.description IS 'location description - optional';

COMMENT ON COLUMN tileset.id IS 'internal id';

COMMENT ON COLUMN tileset.geometry IS 'bounding box of the entire tile set';

COMMENT ON COLUMN tileset.resolution IS 'primary resolution of the source image';

COMMENT ON COLUMN tileset.minzoom IS 'minimum zoom level for a tileset';

COMMENT ON COLUMN tileset.maxzoom IS 'maximum zoom level for the tileset';

COMMENT ON COLUMN tileset.tilepath IS 'path where the images are stored';

COMMENT ON COLUMN tileset.spectrum IS 'bandwidth spectrum that source image was taken';

COMMENT ON COLUMN tileset.tilestatus IS 'internal status of the tile set like pending or completed';

COMMENT ON COLUMN tileset.imagetype IS 'png or jpg or other';

COMMENT ON COLUMN tileset.description IS 'short description of the tile set - from user who imported the set into kddart';

COMMENT ON COLUMN tileset.metadata IS 'json object with relvant metadata information for the tileset like cloud coverage, vegetation etc';

COMMENT ON COLUMN tileset.source IS 'tile set source as json object';

COMMENT ON COLUMN tiles.id IS 'internal tile set id';

COMMENT ON COLUMN tiles.tileset IS 'tileset that this tile belongs to';

COMMENT ON COLUMN tiles.geometry IS 'geometry object - vector boundary of the raster image';

COMMENT ON COLUMN tiles.xcoord IS 'x coordinate of the tile';

COMMENT ON COLUMN tiles.ycoord IS 'y coordinate of the tile';

COMMENT ON COLUMN tiles.zoomlevel IS 'zoom level of this tile';


-- additional sql statements

--
-- Name: _group_concat(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION _group_concat(text, text) RETURNS text
    AS $_$
SELECT CASE
WHEN $2 IS NULL THEN $1
WHEN $1 IS NULL THEN $2
ELSE $1 operator(pg_catalog.||) ' ' operator(pg_catalog.||) $2
END
$_$
    LANGUAGE sql IMMUTABLE;

ALTER FUNCTION public._group_concat(text, text) OWNER TO postgres;

--
-- Name: group_concat(text); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE group_concat(text) (
    SFUNC = _group_concat,
    STYPE = text
);

ALTER AGGREGATE public.group_concat(text) OWNER TO postgres;


REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;