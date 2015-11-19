-- generated on: Wed Oct 14 10:45:59 2015
-- input file: ER_dbmodel_GIS_Enviro.xml


-- Copyright (C) 2015 by Diversity Arrays Technology Pty Ltd
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
-- model version: 2.3.74

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
  PRIMARY KEY ("id")
);
CREATE INDEX "xlayernattrib_dt" on "layernattrib" ("dt");
CREATE INDEX "xlayernattrib_sysuid" on "layernattrib" ("systemuserid");
CREATE INDEX "xlayernattrib_layerattrib" on "layernattrib" ("layerattrib");
CREATE INDEX "xlayernattrib_layerid" on "layernattrib" ("layerid");

CREATE TABLE "siteloc" (
  "siteid" bigint NOT NULL,
  "sitelocation" geography(MULTIPOLYGON, 4326) NOT NULL,
  PRIMARY KEY ("siteid")
);
CREATE INDEX "xsl_sitelocation" on "siteloc" USING GIST  ("sitelocation");

CREATE TABLE "trialloc" (
  "trialid" bigint NOT NULL,
  "triallocation" geography(MULTIPOLYGON, 4326) NOT NULL,
  PRIMARY KEY ("trialid")
);
CREATE INDEX "xtl_triallocation" on "trialloc" USING GIST  ("triallocation");

CREATE TABLE "trialunitloc" (
  "trialunitid" bigint NOT NULL,
  "trialunitlocation" geography(GEOMETRYCOLLECTION, 4326) NOT NULL,
  PRIMARY KEY ("trialunitid")
);
CREATE INDEX "xtul_trialunitlocation" on "trialunitloc" USING GIST  ("trialunitlocation");

CREATE TABLE "contactloc" (
  "contactid" bigint NOT NULL,
  "contactlocation" geography(MULTIPOINT, 4326) NOT NULL,
  PRIMARY KEY ("contactid")
);
CREATE INDEX "xcl_contactlocation" on "contactloc" USING GIST  ("contactlocation");

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

CREATE TABLE "layerimgn" (
  "id" serial NOT NULL,
  "geometry" geography(GEOMETRYCOLLECTION, 4326) NOT NULL,
  "imgfile" character varying(1000) NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "xlin_geometry" on "layerimgn" USING GIST  ("geometry");

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

COMMENT ON COLUMN siteloc.siteid IS '(FK) site id from main database';

COMMENT ON COLUMN siteloc.sitelocation IS 'polygon geometry for site - should have spatial index GIST in PostGIS!!!';

COMMENT ON COLUMN trialloc.trialid IS '(FK) trial id from the main database';

COMMENT ON COLUMN trialloc.triallocation IS 'geometry object for the trial - should have spatial index GIST in PostGIS!!!';

COMMENT ON COLUMN trialunitloc.trialunitid IS '(FK) trial unit id from the main database';

COMMENT ON COLUMN trialunitloc.trialunitlocation IS 'geometry of the trial unit - should have spatial index GIST in PostGIS!!!';

COMMENT ON COLUMN contactloc.contactid IS '(FK) contact id from the main database';

COMMENT ON COLUMN contactloc.contactlocation IS 'contact location - should have spatial index GIST in PostGIS!!!';

COMMENT ON COLUMN datadevice.layerattrib IS 'id of the attribute column of the layer where this device will be logging into';

COMMENT ON COLUMN datadevice.deviceid IS '(FK) Device Id from the core database - DeviceRegister table';

COMMENT ON COLUMN datadevice.deviceparam IS 'Name of the parameter from the device for that attribute';

COMMENT ON COLUMN datadevice.active IS '[0,1] flag to indicate if this definition is active. Definitions should not be removed';

COMMENT ON COLUMN layer2dn.id IS 'numeric id of the geometric object';

COMMENT ON COLUMN layer2dn.geometry IS 'geometric object';

COMMENT ON COLUMN layer2dn.attributex IS 'list of attributes defined in layerattrib table for this layer';

COMMENT ON COLUMN layerimgn.id IS 'numeric id of the geometric object';

COMMENT ON COLUMN layerimgn.geometry IS 'geometric object (polygon - usually rectangle - defined by corners of the image)';

COMMENT ON COLUMN layerimgn.imgfile IS 'path to the georeferenced image file. Geometry column in this case defines rectangle with the image boundaries';


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
