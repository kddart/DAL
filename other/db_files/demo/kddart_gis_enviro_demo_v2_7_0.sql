--
-- PostgreSQL database dump
--

-- Dumped from database version 15.1
-- Dumped by pg_dump version 15.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- Name: _group_concat(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public._group_concat(text, text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
SELECT CASE
WHEN $2 IS NULL THEN $1
WHEN $1 IS NULL THEN $2
ELSE $1 operator(pg_catalog.||) ' ' operator(pg_catalog.||) $2
END
$_$;


ALTER FUNCTION public._group_concat(text, text) OWNER TO postgres;

--
-- Name: group_concat(text); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE public.group_concat(text) (
    SFUNC = public._group_concat,
    STYPE = text
);


ALTER AGGREGATE public.group_concat(text) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: contactloc; Type: TABLE; Schema: public; Owner: kddart_dal
--

CREATE TABLE public.contactloc (
    contactid bigint NOT NULL,
    contactlocation public.geography(MultiPoint,4326) NOT NULL,
    contactlocid integer NOT NULL,
    contactlocdt timestamp without time zone DEFAULT now() NOT NULL,
    currentloc integer DEFAULT 0 NOT NULL,
    description character varying(254)
);


ALTER TABLE public.contactloc OWNER TO kddart_dal;

--
-- Name: COLUMN contactloc.contactid; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.contactloc.contactid IS '(FK) contact id from the main database';


--
-- Name: COLUMN contactloc.contactlocation; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.contactloc.contactlocation IS 'contact location - should have spatial index GIST in PostGIS!!!';


--
-- Name: contactloc_contactlocid_seq; Type: SEQUENCE; Schema: public; Owner: kddart_dal
--

CREATE SEQUENCE public.contactloc_contactlocid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.contactloc_contactlocid_seq OWNER TO kddart_dal;

--
-- Name: contactloc_contactlocid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kddart_dal
--

ALTER SEQUENCE public.contactloc_contactlocid_seq OWNED BY public.contactloc.contactlocid;


--
-- Name: datadevice; Type: TABLE; Schema: public; Owner: kddart_dal
--

CREATE TABLE public.datadevice (
    layerattrib bigint NOT NULL,
    deviceid character varying(100) NOT NULL,
    deviceparam character varying NOT NULL,
    active smallint DEFAULT 1 NOT NULL
);


ALTER TABLE public.datadevice OWNER TO kddart_dal;

--
-- Name: COLUMN datadevice.layerattrib; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.datadevice.layerattrib IS 'id of the attribute column of the layer where this device will be logging into';


--
-- Name: COLUMN datadevice.deviceid; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.datadevice.deviceid IS '(FK) Device Id from the core database - DeviceRegister table';


--
-- Name: COLUMN datadevice.deviceparam; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.datadevice.deviceparam IS 'Name of the parameter from the device for that attribute';


--
-- Name: COLUMN datadevice.active; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.datadevice.active IS '[0,1] flag to indicate if this definition is active. Definitions should not be removed';


--
-- Name: layer; Type: TABLE; Schema: public; Owner: kddart_dal
--

CREATE TABLE public.layer (
    id integer NOT NULL,
    parent bigint,
    name character varying(100) NOT NULL,
    alias character varying(100),
    layertype character varying(30) DEFAULT 'layer'::character varying NOT NULL,
    layermetadata text,
    iseditable smallint DEFAULT 1 NOT NULL,
    createuser bigint DEFAULT 0 NOT NULL,
    createtime timestamp without time zone NOT NULL,
    lastupdateuser bigint NOT NULL,
    lastupdatetime timestamp without time zone NOT NULL,
    srid bigint DEFAULT 4326 NOT NULL,
    geometrytype character varying(30) NOT NULL,
    description character varying(254),
    owngroupid bigint NOT NULL,
    accessgroupid bigint DEFAULT 0 NOT NULL,
    owngroupperm smallint NOT NULL,
    accessgroupperm smallint DEFAULT 0 NOT NULL,
    otherperm smallint DEFAULT 0 NOT NULL
);


ALTER TABLE public.layer OWNER TO kddart_dal;

--
-- Name: COLUMN layer.id; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layer.id IS 'internal id';


--
-- Name: COLUMN layer.parent; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layer.parent IS 'id of the parent layer';


--
-- Name: COLUMN layer.name; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layer.name IS 'layer name';


--
-- Name: COLUMN layer.alias; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layer.alias IS 'layer alias';


--
-- Name: COLUMN layer.layertype; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layer.layertype IS 'layer, layer2d, layerimg - these three values refer to the base name of the real layer';


--
-- Name: COLUMN layer.layermetadata; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layer.layermetadata IS 'metadata for a layer. Can be a piece of xml or some sort of other agreed convention to store info about data';


--
-- Name: COLUMN layer.iseditable; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layer.iseditable IS '0|1 flag defining if layer can be edited. Set to 0 to disable edits.';


--
-- Name: COLUMN layer.createuser; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layer.createuser IS 'id of the system user, who created the layer';


--
-- Name: COLUMN layer.createtime; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layer.createtime IS 'date and time of the layer creation';


--
-- Name: COLUMN layer.lastupdateuser; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layer.lastupdateuser IS 'id of the system user, who last updated the layer info or field definition (not a data in the layer!)';


--
-- Name: COLUMN layer.lastupdatetime; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layer.lastupdatetime IS 'date and time of layer info or definition update';


--
-- Name: COLUMN layer.srid; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layer.srid IS 'spatial reference id - refer to http://en.wikipedia.org/wiki/SRID';


--
-- Name: COLUMN layer.geometrytype; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layer.geometrytype IS 'for internal layers this is the type of the geometry column in LayerN table, have to match OGC standards (POINT, MULTIPOINT, POLYGON .. etc)';


--
-- Name: COLUMN layer.description; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layer.description IS 'layer description';


--
-- Name: COLUMN layer.owngroupid; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layer.owngroupid IS 'group id which owns the record';


--
-- Name: COLUMN layer.accessgroupid; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layer.accessgroupid IS 'group id which can access the record (different than owngroup)';


--
-- Name: COLUMN layer.owngroupperm; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layer.owngroupperm IS 'permission for the own group members';


--
-- Name: COLUMN layer.accessgroupperm; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layer.accessgroupperm IS 'permission for the other group members';


--
-- Name: COLUMN layer.otherperm; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layer.otherperm IS 'permission for all the other system users';


--
-- Name: layer2; Type: TABLE; Schema: public; Owner: kddart_dal
--

CREATE TABLE public.layer2 (
    id integer NOT NULL,
    geometry public.geography(Point,4326)
);


ALTER TABLE public.layer2 OWNER TO kddart_dal;

--
-- Name: layer2_id_seq; Type: SEQUENCE; Schema: public; Owner: kddart_dal
--

CREATE SEQUENCE public.layer2_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.layer2_id_seq OWNER TO kddart_dal;

--
-- Name: layer2_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kddart_dal
--

ALTER SEQUENCE public.layer2_id_seq OWNED BY public.layer2.id;


--
-- Name: layer2attrib; Type: TABLE; Schema: public; Owner: kddart_dal
--

CREATE TABLE public.layer2attrib (
    id integer NOT NULL,
    layerid bigint,
    layerattrib bigint,
    value character varying(254),
    dt timestamp without time zone,
    systemuserid bigint
);


ALTER TABLE public.layer2attrib OWNER TO kddart_dal;

--
-- Name: layer2attrib_id_seq; Type: SEQUENCE; Schema: public; Owner: kddart_dal
--

CREATE SEQUENCE public.layer2attrib_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.layer2attrib_id_seq OWNER TO kddart_dal;

--
-- Name: layer2attrib_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kddart_dal
--

ALTER SEQUENCE public.layer2attrib_id_seq OWNED BY public.layer2attrib.id;


--
-- Name: layer2dn; Type: TABLE; Schema: public; Owner: kddart_dal
--

CREATE TABLE public.layer2dn (
    id integer NOT NULL,
    geometry public.geography(GeometryCollection,4326) NOT NULL,
    attributex bigint
);


ALTER TABLE public.layer2dn OWNER TO kddart_dal;

--
-- Name: COLUMN layer2dn.id; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layer2dn.id IS 'numeric id of the geometric object';


--
-- Name: COLUMN layer2dn.geometry; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layer2dn.geometry IS 'geometric object';


--
-- Name: COLUMN layer2dn.attributex; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layer2dn.attributex IS 'list of attributes defined in layerattrib table for this layer';


--
-- Name: layer2dn_id_seq; Type: SEQUENCE; Schema: public; Owner: kddart_dal
--

CREATE SEQUENCE public.layer2dn_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.layer2dn_id_seq OWNER TO kddart_dal;

--
-- Name: layer2dn_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kddart_dal
--

ALTER SEQUENCE public.layer2dn_id_seq OWNED BY public.layer2dn.id;


--
-- Name: layer_id_seq; Type: SEQUENCE; Schema: public; Owner: kddart_dal
--

CREATE SEQUENCE public.layer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.layer_id_seq OWNER TO kddart_dal;

--
-- Name: layer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kddart_dal
--

ALTER SEQUENCE public.layer_id_seq OWNED BY public.layer.id;


--
-- Name: layerattrib; Type: TABLE; Schema: public; Owner: kddart_dal
--

CREATE TABLE public.layerattrib (
    id integer NOT NULL,
    unitid bigint NOT NULL,
    layer bigint NOT NULL,
    colname character varying(100) NOT NULL,
    coltype character varying(30) NOT NULL,
    colsize bigint NOT NULL,
    validation character varying(254),
    colunits character varying(100) NOT NULL
);


ALTER TABLE public.layerattrib OWNER TO kddart_dal;

--
-- Name: COLUMN layerattrib.id; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layerattrib.id IS 'internal id';


--
-- Name: COLUMN layerattrib.unitid; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layerattrib.unitid IS 'unitid (FK) to generalunit table in core structure';


--
-- Name: COLUMN layerattrib.layer; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layerattrib.layer IS 'layer id';


--
-- Name: COLUMN layerattrib.colname; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layerattrib.colname IS 'name of the attribute column';


--
-- Name: COLUMN layerattrib.coltype; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layerattrib.coltype IS 'type of the column';


--
-- Name: COLUMN layerattrib.colsize; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layerattrib.colsize IS 'size of the column';


--
-- Name: COLUMN layerattrib.validation; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layerattrib.validation IS 'rules for value validation';


--
-- Name: COLUMN layerattrib.colunits; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layerattrib.colunits IS 'what units the value is in (e.g. deg Celsius, km, percent)';


--
-- Name: layerattrib_id_seq; Type: SEQUENCE; Schema: public; Owner: kddart_dal
--

CREATE SEQUENCE public.layerattrib_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.layerattrib_id_seq OWNER TO kddart_dal;

--
-- Name: layerattrib_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kddart_dal
--

ALTER SEQUENCE public.layerattrib_id_seq OWNED BY public.layerattrib.id;


--
-- Name: layern; Type: TABLE; Schema: public; Owner: kddart_dal
--

CREATE TABLE public.layern (
    id integer NOT NULL,
    geometry public.geography(GeometryCollection,4326) NOT NULL
);


ALTER TABLE public.layern OWNER TO kddart_dal;

--
-- Name: COLUMN layern.id; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layern.id IS 'internal id';


--
-- Name: COLUMN layern.geometry; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layern.geometry IS 'geo object of some geometrical type - should have spatial index GIST in PostGIS!!!';


--
-- Name: layern_id_seq; Type: SEQUENCE; Schema: public; Owner: kddart_dal
--

CREATE SEQUENCE public.layern_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.layern_id_seq OWNER TO kddart_dal;

--
-- Name: layern_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kddart_dal
--

ALTER SEQUENCE public.layern_id_seq OWNED BY public.layern.id;


--
-- Name: layernattrib; Type: TABLE; Schema: public; Owner: kddart_dal
--

CREATE TABLE public.layernattrib (
    id integer NOT NULL,
    layerid bigint NOT NULL,
    layerattrib bigint NOT NULL,
    value character varying(254),
    dt timestamp without time zone,
    systemuserid bigint,
    deviceid character varying(100)
);


ALTER TABLE public.layernattrib OWNER TO kddart_dal;

--
-- Name: COLUMN layernattrib.id; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layernattrib.id IS 'internal id';


--
-- Name: COLUMN layernattrib.layerid; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layernattrib.layerid IS 'id of the geometric object in layern table';


--
-- Name: COLUMN layernattrib.layerattrib; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layernattrib.layerattrib IS 'layer attribute id';


--
-- Name: COLUMN layernattrib.value; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layernattrib.value IS 'value of the parameter';


--
-- Name: COLUMN layernattrib.dt; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layernattrib.dt IS 'date and time';


--
-- Name: COLUMN layernattrib.systemuserid; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.layernattrib.systemuserid IS 'system user, who inserted the data value (links to core database)';


--
-- Name: layernattrib_id_seq; Type: SEQUENCE; Schema: public; Owner: kddart_dal
--

CREATE SEQUENCE public.layernattrib_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.layernattrib_id_seq OWNER TO kddart_dal;

--
-- Name: layernattrib_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kddart_dal
--

ALTER SEQUENCE public.layernattrib_id_seq OWNED BY public.layernattrib.id;


--
-- Name: siteloc; Type: TABLE; Schema: public; Owner: kddart_dal
--

CREATE TABLE public.siteloc (
    siteid bigint NOT NULL,
    sitelocation public.geography(MultiPolygon,4326) NOT NULL,
    sitelocid integer NOT NULL,
    sitelocdt timestamp without time zone DEFAULT now() NOT NULL,
    currentloc integer DEFAULT 0 NOT NULL,
    description character varying(254)
);


ALTER TABLE public.siteloc OWNER TO kddart_dal;

--
-- Name: COLUMN siteloc.siteid; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.siteloc.siteid IS '(FK) site id from main database';


--
-- Name: COLUMN siteloc.sitelocation; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.siteloc.sitelocation IS 'polygon geometry for site - should have spatial index GIST in PostGIS!!!';


--
-- Name: siteloc_sitelocid_seq; Type: SEQUENCE; Schema: public; Owner: kddart_dal
--

CREATE SEQUENCE public.siteloc_sitelocid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.siteloc_sitelocid_seq OWNER TO kddart_dal;

--
-- Name: siteloc_sitelocid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kddart_dal
--

ALTER SEQUENCE public.siteloc_sitelocid_seq OWNED BY public.siteloc.sitelocid;


--
-- Name: specimenloc; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.specimenloc (
    specimenlocid integer NOT NULL,
    specimenid bigint NOT NULL,
    specimenlocation public.geography(GeometryCollection,4326) NOT NULL,
    specimenlocdt timestamp without time zone NOT NULL,
    currentloc smallint NOT NULL,
    description character varying(254)
);


ALTER TABLE public.specimenloc OWNER TO postgres;

--
-- Name: specimenloc_specimenlocid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.specimenloc_specimenlocid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.specimenloc_specimenlocid_seq OWNER TO postgres;

--
-- Name: specimenloc_specimenlocid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.specimenloc_specimenlocid_seq OWNED BY public.specimenloc.specimenlocid;


--
-- Name: storageloc; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.storageloc (
    storagelocid integer NOT NULL,
    storageid bigint NOT NULL,
    storagelocation public.geography(GeometryCollection,4326) NOT NULL,
    storagelocdt timestamp without time zone NOT NULL,
    currentloc smallint NOT NULL,
    description character varying(254)
);


ALTER TABLE public.storageloc OWNER TO postgres;

--
-- Name: storageloc_storagelocid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.storageloc_storagelocid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.storageloc_storagelocid_seq OWNER TO postgres;

--
-- Name: storageloc_storagelocid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.storageloc_storagelocid_seq OWNED BY public.storageloc.storagelocid;


--
-- Name: surveyloc; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.surveyloc (
    surveylocid integer NOT NULL,
    surveyid bigint NOT NULL,
    surverylocation public.geography(GeometryCollection,4326) NOT NULL,
    surverylocdt timestamp without time zone NOT NULL,
    currentloc smallint NOT NULL,
    description character varying(254)
);


ALTER TABLE public.surveyloc OWNER TO postgres;

--
-- Name: surveyloc_surveylocid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.surveyloc_surveylocid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.surveyloc_surveylocid_seq OWNER TO postgres;

--
-- Name: surveyloc_surveylocid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.surveyloc_surveylocid_seq OWNED BY public.surveyloc.surveylocid;


--
-- Name: tiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tiles (
    id integer NOT NULL,
    tileset bigint NOT NULL,
    geometry public.geography(GeometryCollection,4326) NOT NULL,
    xcoord bigint NOT NULL,
    ycoord bigint NOT NULL,
    zoomlevel bigint NOT NULL
);


ALTER TABLE public.tiles OWNER TO postgres;

--
-- Name: tiles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tiles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tiles_id_seq OWNER TO postgres;

--
-- Name: tiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tiles_id_seq OWNED BY public.tiles.id;


--
-- Name: tileset; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tileset (
    id bigint NOT NULL,
    geometry public.geometry,
    resolution bigint NOT NULL,
    minzoom bigint NOT NULL,
    maxzoom bigint NOT NULL,
    tilepath character varying(254) NOT NULL,
    spectrum character varying(254),
    tilestatus character varying(254) NOT NULL,
    imagetype character varying(245) NOT NULL,
    description text,
    metadata text,
    source text
);


ALTER TABLE public.tileset OWNER TO postgres;

--
-- Name: trialloc; Type: TABLE; Schema: public; Owner: kddart_dal
--

CREATE TABLE public.trialloc (
    trialid bigint NOT NULL,
    triallocation public.geography(MultiPolygon,4326) NOT NULL,
    triallocid integer NOT NULL,
    triallocdt timestamp without time zone DEFAULT now() NOT NULL,
    currentloc integer DEFAULT 0 NOT NULL,
    description character varying(254)
);


ALTER TABLE public.trialloc OWNER TO kddart_dal;

--
-- Name: COLUMN trialloc.trialid; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.trialloc.trialid IS '(FK) trial id from the main database';


--
-- Name: COLUMN trialloc.triallocation; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.trialloc.triallocation IS 'geometry object for the trial - should have spatial index GIST in PostGIS!!!';


--
-- Name: trialloc_triallocid_seq; Type: SEQUENCE; Schema: public; Owner: kddart_dal
--

CREATE SEQUENCE public.trialloc_triallocid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.trialloc_triallocid_seq OWNER TO kddart_dal;

--
-- Name: trialloc_triallocid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kddart_dal
--

ALTER SEQUENCE public.trialloc_triallocid_seq OWNED BY public.trialloc.triallocid;


--
-- Name: trialunitloc; Type: TABLE; Schema: public; Owner: kddart_dal
--

CREATE TABLE public.trialunitloc (
    trialunitid bigint NOT NULL,
    trialunitlocation public.geography(GeometryCollection,4326) NOT NULL,
    trialunitlocid integer NOT NULL,
    trialunitlocdt timestamp without time zone DEFAULT now() NOT NULL,
    currentloc integer DEFAULT 0 NOT NULL,
    description character varying(254)
);


ALTER TABLE public.trialunitloc OWNER TO kddart_dal;

--
-- Name: COLUMN trialunitloc.trialunitid; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.trialunitloc.trialunitid IS '(FK) trial unit id from the main database';


--
-- Name: COLUMN trialunitloc.trialunitlocation; Type: COMMENT; Schema: public; Owner: kddart_dal
--

COMMENT ON COLUMN public.trialunitloc.trialunitlocation IS 'geometry of the trial unit - should have spatial index GIST in PostGIS!!!';


--
-- Name: trialunitloc_trialunitlocid_seq; Type: SEQUENCE; Schema: public; Owner: kddart_dal
--

CREATE SEQUENCE public.trialunitloc_trialunitlocid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.trialunitloc_trialunitlocid_seq OWNER TO kddart_dal;

--
-- Name: trialunitloc_trialunitlocid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kddart_dal
--

ALTER SEQUENCE public.trialunitloc_trialunitlocid_seq OWNED BY public.trialunitloc.trialunitlocid;


--
-- Name: contactloc contactlocid; Type: DEFAULT; Schema: public; Owner: kddart_dal
--

ALTER TABLE ONLY public.contactloc ALTER COLUMN contactlocid SET DEFAULT nextval('public.contactloc_contactlocid_seq'::regclass);


--
-- Name: layer id; Type: DEFAULT; Schema: public; Owner: kddart_dal
--

ALTER TABLE ONLY public.layer ALTER COLUMN id SET DEFAULT nextval('public.layer_id_seq'::regclass);


--
-- Name: layer2 id; Type: DEFAULT; Schema: public; Owner: kddart_dal
--

ALTER TABLE ONLY public.layer2 ALTER COLUMN id SET DEFAULT nextval('public.layer2_id_seq'::regclass);


--
-- Name: layer2attrib id; Type: DEFAULT; Schema: public; Owner: kddart_dal
--

ALTER TABLE ONLY public.layer2attrib ALTER COLUMN id SET DEFAULT nextval('public.layer2attrib_id_seq'::regclass);


--
-- Name: layer2dn id; Type: DEFAULT; Schema: public; Owner: kddart_dal
--

ALTER TABLE ONLY public.layer2dn ALTER COLUMN id SET DEFAULT nextval('public.layer2dn_id_seq'::regclass);


--
-- Name: layerattrib id; Type: DEFAULT; Schema: public; Owner: kddart_dal
--

ALTER TABLE ONLY public.layerattrib ALTER COLUMN id SET DEFAULT nextval('public.layerattrib_id_seq'::regclass);


--
-- Name: layern id; Type: DEFAULT; Schema: public; Owner: kddart_dal
--

ALTER TABLE ONLY public.layern ALTER COLUMN id SET DEFAULT nextval('public.layern_id_seq'::regclass);


--
-- Name: layernattrib id; Type: DEFAULT; Schema: public; Owner: kddart_dal
--

ALTER TABLE ONLY public.layernattrib ALTER COLUMN id SET DEFAULT nextval('public.layernattrib_id_seq'::regclass);


--
-- Name: siteloc sitelocid; Type: DEFAULT; Schema: public; Owner: kddart_dal
--

ALTER TABLE ONLY public.siteloc ALTER COLUMN sitelocid SET DEFAULT nextval('public.siteloc_sitelocid_seq'::regclass);


--
-- Name: specimenloc specimenlocid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.specimenloc ALTER COLUMN specimenlocid SET DEFAULT nextval('public.specimenloc_specimenlocid_seq'::regclass);


--
-- Name: storageloc storagelocid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.storageloc ALTER COLUMN storagelocid SET DEFAULT nextval('public.storageloc_storagelocid_seq'::regclass);


--
-- Name: surveyloc surveylocid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.surveyloc ALTER COLUMN surveylocid SET DEFAULT nextval('public.surveyloc_surveylocid_seq'::regclass);


--
-- Name: tiles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tiles ALTER COLUMN id SET DEFAULT nextval('public.tiles_id_seq'::regclass);


--
-- Name: trialloc triallocid; Type: DEFAULT; Schema: public; Owner: kddart_dal
--

ALTER TABLE ONLY public.trialloc ALTER COLUMN triallocid SET DEFAULT nextval('public.trialloc_triallocid_seq'::regclass);


--
-- Name: trialunitloc trialunitlocid; Type: DEFAULT; Schema: public; Owner: kddart_dal
--

ALTER TABLE ONLY public.trialunitloc ALTER COLUMN trialunitlocid SET DEFAULT nextval('public.trialunitloc_trialunitlocid_seq'::regclass);


--
-- Data for Name: contactloc; Type: TABLE DATA; Schema: public; Owner: kddart_dal
--

COPY public.contactloc (contactid, contactlocation, contactlocid, contactlocdt, currentloc, description) FROM stdin;
\.


--
-- Data for Name: datadevice; Type: TABLE DATA; Schema: public; Owner: kddart_dal
--

COPY public.datadevice (layerattrib, deviceid, deviceparam, active) FROM stdin;
\.


--
-- Data for Name: layer; Type: TABLE DATA; Schema: public; Owner: kddart_dal
--

COPY public.layer (id, parent, name, alias, layertype, layermetadata, iseditable, createuser, createtime, lastupdateuser, lastupdatetime, srid, geometrytype, description, owngroupid, accessgroupid, owngroupperm, accessgroupperm, otherperm) FROM stdin;
2	\N	MyLayer01	ml01xy	layer	\N	1	0	2015-11-29 20:22:48	0	2015-11-29 20:22:48	0	POINT	desc ml01 mod	0	0	7	0	5
\.


--
-- Data for Name: layer2; Type: TABLE DATA; Schema: public; Owner: kddart_dal
--

COPY public.layer2 (id, geometry) FROM stdin;
\.


--
-- Data for Name: layer2attrib; Type: TABLE DATA; Schema: public; Owner: kddart_dal
--

COPY public.layer2attrib (id, layerid, layerattrib, value, dt, systemuserid) FROM stdin;
\.


--
-- Data for Name: layer2dn; Type: TABLE DATA; Schema: public; Owner: kddart_dal
--

COPY public.layer2dn (id, geometry, attributex) FROM stdin;
\.


--
-- Data for Name: layerattrib; Type: TABLE DATA; Schema: public; Owner: kddart_dal
--

COPY public.layerattrib (id, unitid, layer, colname, coltype, colsize, validation, colunits) FROM stdin;
3	1	2	attributeno2	Value	10	\N	Cdeg
4	1	2	attributeno1	Value	10	\N	Cdeg
\.


--
-- Data for Name: layern; Type: TABLE DATA; Schema: public; Owner: kddart_dal
--

COPY public.layern (id, geometry) FROM stdin;
\.


--
-- Data for Name: layernattrib; Type: TABLE DATA; Schema: public; Owner: kddart_dal
--

COPY public.layernattrib (id, layerid, layerattrib, value, dt, systemuserid, deviceid) FROM stdin;
\.


--
-- Data for Name: siteloc; Type: TABLE DATA; Schema: public; Owner: kddart_dal
--

COPY public.siteloc (siteid, sitelocation, sitelocid, sitelocdt, currentloc, description) FROM stdin;
1	0106000020E610000001000000010300000001000000120000006F0340E8C8B96240638B043D32423EC0600340E01BBA6240F70A638528423EC0BD0340D067BA624043AAF7D4A9443EC0DC03405051BA6240D0B4FCDB31453EC0630340A844BA624018321F0593453EC0FA0340D03ABA6240E0F90A9F4B463EC06C0340902FBA62400C919B3704473EC0600340E01BBA6240E0C28EA99F473EC061044038E2B96240D67955D410493EC08F034068B2B96240849D3FD5644A3EC0AE0340E89BB96240C9FFD841004B3EC0240440C87FB96240996C96D3304B3EC0D903401899B96240CC26B2C468463EC06D034020A0B96240E726B473A6453EC0A4034000B1B962401335F9B514453EC05B034050CAB96240E4E365F782443EC055044088CEB962402CA5A5842B443EC06F0340E8C8B96240638B043D32423EC0	1	2022-12-20 07:04:54.566067	0	\N
2	0106000020E6100000010000000103000000010000000E00000040A43F12FC54614088AC69C39B4141C05AA43F8E7F556140A356D920974141C0D7A43F1A11566140FD1A8F04D84141C014A53F6E175661405827F55DF74241C02AA43FEA8C556140364C5E00FC4241C05AA43F8E7F556140E791F456CB4241C0CFA43F6E63556140CD3D37CDB84241C046A43FA24D5561400B03DE0A964241C042A43FDA24556140234E58E34B4241C020A53F3E0C55614083CDDFE7184241C07CA43F6602556140A81A15AF084241C06BA43F42F9546140625A4AB3D54141C0FEA43FF6F9546140F3DAC092B74141C040A43F12FC54614088AC69C39B4141C0	2	2022-12-20 07:04:54.566067	0	\N
3	0106000020E61000000100000001030000000100000005000000FBD1BDB0A2C958C0DE86E47067B53240C9D3BD7032C558C013BA313212B53240ABD2BDF01BC558C0D272E038C0A53240F2D1BD701ECA58C0D1FD847FEAA73240FBD1BDB0A2C958C0DE86E47067B53240	3	2022-12-20 07:04:54.566067	0	\N
4	0106000020E61000000100000001030000000100000009000000718313E6C2B141401FD0C696A4140B40008313E662004440E2AAF9BE223807400E8313E682EF4340F1778551AD8407C0478313E6E2DB4240566BF713C7A703C02A8313E6822D4240E63FB148772400C0558313E6429B41404323BCD20226F7BF0E8313E6C25741400DC1B93FDEB76A3F558313E6429B4140143D5557929AE63F718313E6C2B141401FD0C696A4140B40	4	2022-12-20 07:04:54.566067	0	\N
5	0106000020E61000000100000001030000000100000006000000590487F081523D403E0B7949889732C0050487F001773E40B2A4CC1686A732C0D88143F8902A4040663A1B16763732C0210487F081F53F40E2D6C4FEA31031C0B00387F081AC3D40A9B1387C4CC530C0590487F081523D403E0B7949889732C0	5	2022-12-20 07:04:54.566067	0	\N
6	0106000020E61000000100000001030000000100000008000000DDFEFF9FB46B22405236E384C95B484022FFFF9F956C224098D600FEE95B484051FFFF3FA96D2240FA3A2D20F55B4840D8FDFF3F036E2240D9EF0AF1D05B4840B4FFFFBF466E224006BBFB67A45B48403BFEFFBFA06E2240FEFC5987625B484002FEFF1F256C22409AAE2AE6505B4840DDFEFF9FB46B22405236E384C95B4840	6	2022-12-20 07:04:54.566067	0	\N
7	0106000020E6100000010000000103000000010000000A000000ED8C3041852A63404B3465D5CBAB3CC0C98D30F99F2A6340E932B61C05A93CC0F48C30D1D62A634045965CB3F0A73CC04E8D30F9F92A6340BDDD4C3018A83CC0448D30110F2B6340697E9E7D66A73CC09E8D3039322B634028CE002A67A83CC0BC8C3061552B634093F194C784A83CC0B68D3099592B63400166502037AA3CC0AF8C30B1412B6340D122AD2A2FAD3CC0ED8C3041852A63404B3465D5CBAB3CC0	7	2022-12-20 07:04:54.566067	0	\N
\.


--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: kddart_dal
--

COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


--
-- Data for Name: specimenloc; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.specimenloc (specimenlocid, specimenid, specimenlocation, specimenlocdt, currentloc, description) FROM stdin;
\.


--
-- Data for Name: storageloc; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.storageloc (storagelocid, storageid, storagelocation, storagelocdt, currentloc, description) FROM stdin;
\.


--
-- Data for Name: surveyloc; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.surveyloc (surveylocid, surveyid, surverylocation, surverylocdt, currentloc, description) FROM stdin;
\.


--
-- Data for Name: tiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tiles (id, tileset, geometry, xcoord, ycoord, zoomlevel) FROM stdin;
\.


--
-- Data for Name: tileset; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tileset (id, geometry, resolution, minzoom, maxzoom, tilepath, spectrum, tilestatus, imagetype, description, metadata, source) FROM stdin;
\.


--
-- Data for Name: trialloc; Type: TABLE DATA; Schema: public; Owner: kddart_dal
--

COPY public.trialloc (trialid, triallocation, triallocid, triallocdt, currentloc, description) FROM stdin;
2	0106000020E610000001000000010300000001000000050000003973BF0C00BA62409E369CB512473EC03773BF5205BA6240578A3BE2EE463EC0EC723FED08BA62408175CDD00A473EC0EE723FA703BA6240F068CDD12C473EC03973BF0C00BA62409E369CB512473EC0	1	2022-12-20 07:04:54.566067	0	\N
4	0106000020E6100000010000000103000000010000000500000049A5FF3F4A5561406419F9B0234241C01FA5FF6C4A5561409D370A62E34141C034A4FF0980556140C42C6839E24141C034A4FF09805561407AB408F4214241C049A5FF3F4A5561406419F9B0234241C0	2	2022-12-20 07:04:54.566067	0	\N
5	0106000020E6100000010000000103000000010000000500000077733F08EEB962405051365C5A473EC04A733F7BF3B96240A3AE7DED35473EC009733FB3F7B96240F683522559473EC05F733F13F2B962403B5337267B473EC077733F08EEB962405051365C5A473EC0	3	2022-12-20 07:04:54.566067	0	\N
6	0106000020E61000000100000001030000000100000005000000CF733FC5E5B962400752534821473EC077733F65EBB962402789A0A2FB463EC0CA733F51F0B9624036D1377F22473EC0BA723FDEEAB9624096AAF7ED46473EC0CF733FC5E5B962400752534821473EC0	4	2022-12-20 07:04:54.566067	0	\N
7	0106000020E61000000100000001030000000100000005000000A7A53F63B95561401629DAC5594241C0A7A53F63B95561409DCCC37F994241C094A53F3182556140F04612149A4241C094A53F3182556140D505EC08584241C0A7A53F63B95561401629DAC5594241C0	5	2022-12-20 07:04:54.566067	0	\N
8	0106000020E61000000100000001030000000100000005000000FE03A0460ABA6240F37CC4DB72463EC0300420FD0FBA6240D94ED25278463EC0F103209211BA6240B01A621933463EC0710420C50BBA6240086E50A22D463EC0FE03A0460ABA6240F37CC4DB72463EC0	6	2022-12-20 07:04:54.566067	0	\N
10	0106000020E61000000100000001030000000100000005000000B315C0E7EFC658C0AE50A4E7D9AE3240A615C0DADEC658C03C55F23ED1AE3240AB13C0F6E0C658C0EFF03546B1AE3240CA14C030F2C658C02D76F143BBAE3240B315C0E7EFC658C0AE50A4E7D9AE3240	7	2022-12-20 07:04:54.566067	0	\N
9	0106000020E61000000100000001030000000100000005000000A382D3C5948A4240EC6B1701DBDCE8BFBE8253E49B8A424030C95E1F24DDE8BF8F82D3EC9A8A4240A9DE41F250DFE8BFA082D3B7938A4240040F95B318DFE8BFA382D3C5948A4240EC6B1701DBDCE8BF	8	2022-12-20 07:04:54.566067	0	\N
11	0106000020E610000001000000010300000001000000050000007A12C03BC9C658C0350C59E0F9AE3240E912C04ABAC658C093FB15E3EDAE32400B124031BDC658C0DD786E94D0AE32400B13C092CCC658C04226FD3BDEAE32407A12C03BC9C658C0350C59E0F9AE3240	9	2022-12-20 07:04:54.566067	0	\N
12	0106000020E610000001000000010300000001000000050000005E056717AD2D3F40919AA4BA7FDA31C08B05670F002E3F400962442191DA31C08F0567BBF92D3F40D1CFD19BB6DA31C0B505673FA32D3F4037A38DDCA1DA31C05E056717AD2D3F40919AA4BA7FDA31C0	10	2022-12-20 07:04:54.566067	0	\N
1	0106000020E6100000010000000103000000010000000600000063733FB6F4B96240FF344885BF463EC016743F83FAB96240DC1656169B463EC023743F61FEB96240FE593E0EBA463EC0AD73BF04F9B9624010F37C4FE0463EC0AD73BF04F9B9624010F37C4FE0463EC063733FB6F4B96240FF344885BF463EC0	11	2022-12-20 07:04:54.566067	0	\N
13	0106000020E610000001000000010300000001000000050000005914C0B6D5C658C0A51089006CAE32409113C022C4C658C0650BDAAC64AE32403C86BC2BC7C658C0608BAD5343AE32409A13C075DAC658C02492DC5B51AE32405914C0B6D5C658C0A51089006CAE3240	12	2022-12-20 07:04:54.566067	0	\N
14	0106000020E61000000100000001030000000100000005000000FD743FC602BA6240C658B07978463EC0E6743F7409BA62403C9F17C37F463EC0FB743F0C08BA6240AF66DBC4B2463EC0E9743F8B01BA624058F4DF9FA6463EC0FD743FC602BA6240C658B07978463EC0	13	2022-12-20 07:04:54.566067	0	\N
15	0106000020E610000001000000010300000001000000050000003D03403B0CBA6240EA6C277283463EC0660340B10EBA6240EF83677B86463EC04A02C0E60DBA624008D0C433B2463EC0530340D30ABA62404013862AAF463EC03D03403B0CBA6240EA6C277283463EC0	14	2022-12-20 07:04:54.566067	0	\N
16	0106000020E61000000100000001030000000100000005000000328D30D5F02A6340EB36F83B35AA3CC0BC8C305CF12A6340E09452FE6DAA3CC00A8D30EC152B6340E09452FE6DAA3CC00A8D30EC152B6340736D558831AA3CC0328D30D5F02A6340EB36F83B35AA3CC0	15	2022-12-20 07:04:54.566067	0	\N
\.


--
-- Data for Name: trialunitloc; Type: TABLE DATA; Schema: public; Owner: kddart_dal
--

COPY public.trialunitloc (trialunitid, trialunitlocation, trialunitlocid, trialunitlocdt, currentloc, description) FROM stdin;
3793	0107000020E61000000100000001010000001E166A4DF32A634027C286A757AA3CC0	1	2022-12-20 07:04:54.566067	0	\N
3794	0107000020E61000000100000001010000001E166A4DF32A63408A1F63EE5AAA3CC0	2	2022-12-20 07:04:54.566067	0	\N
3795	0107000020E61000000100000001010000001E166A4DF32A6340EE7C3F355EAA3CC0	3	2022-12-20 07:04:54.566067	0	\N
3796	0107000020E61000000100000001010000001E166A4DF32A634051DA1B7C61AA3CC0	4	2022-12-20 07:04:54.566067	0	\N
3797	0107000020E61000000100000001010000001E166A4DF32A6340B537F8C264AA3CC0	5	2022-12-20 07:04:54.566067	0	\N
3798	0107000020E61000000100000001010000001E166A4DF32A63401895D40968AA3CC0	6	2022-12-20 07:04:54.566067	0	\N
3799	0107000020E61000000100000001010000001E166A4DF32A63407CF2B0506BAA3CC0	7	2022-12-20 07:04:54.566067	0	\N
3800	0107000020E61000000100000001010000001E166A4DF32A6340DF4F8D976EAA3CC0	8	2022-12-20 07:04:54.566067	0	\N
3801	0107000020E61000000100000001010000001E166A4DF32A634043AD69DE71AA3CC0	9	2022-12-20 07:04:54.566067	0	\N
3802	0107000020E61000000100000001010000001E166A4DF32A6340A60A462575AA3CC0	10	2022-12-20 07:04:54.566067	0	\N
3803	0107000020E6100000010000000101000000D044D8F0F42A634027C286A757AA3CC0	11	2022-12-20 07:04:54.566067	0	\N
3804	0107000020E6100000010000000101000000D044D8F0F42A63408A1F63EE5AAA3CC0	12	2022-12-20 07:04:54.566067	0	\N
3805	0107000020E6100000010000000101000000D044D8F0F42A6340EE7C3F355EAA3CC0	13	2022-12-20 07:04:54.566067	0	\N
3806	0107000020E6100000010000000101000000D044D8F0F42A634051DA1B7C61AA3CC0	14	2022-12-20 07:04:54.566067	0	\N
3807	0107000020E6100000010000000101000000D044D8F0F42A6340B537F8C264AA3CC0	15	2022-12-20 07:04:54.566067	0	\N
3808	0107000020E6100000010000000101000000D044D8F0F42A63401895D40968AA3CC0	16	2022-12-20 07:04:54.566067	0	\N
3809	0107000020E6100000010000000101000000D044D8F0F42A63407CF2B0506BAA3CC0	17	2022-12-20 07:04:54.566067	0	\N
3810	0107000020E6100000010000000101000000D044D8F0F42A6340DF4F8D976EAA3CC0	18	2022-12-20 07:04:54.566067	0	\N
3811	0107000020E6100000010000000101000000D044D8F0F42A634043AD69DE71AA3CC0	19	2022-12-20 07:04:54.566067	0	\N
3812	0107000020E6100000010000000101000000D044D8F0F42A6340A60A462575AA3CC0	20	2022-12-20 07:04:54.566067	0	\N
3813	0107000020E610000001000000010100000082734694F64A634027C286A757AA3CC0	21	2022-12-20 07:04:54.566067	0	\N
3814	0107000020E610000001000000010100000082734694F64A63408A1F63EE5AAA3CC0	22	2022-12-20 07:04:54.566067	0	\N
3815	0107000020E610000001000000010100000082734694F64A6340EE7C3F355EAA3CC0	23	2022-12-20 07:04:54.566067	0	\N
3816	0107000020E610000001000000010100000082734694F64A634051DA1B7C61AA3CC0	24	2022-12-20 07:04:54.566067	0	\N
3817	0107000020E610000001000000010100000082734694F64A6340B537F8C264AA3CC0	25	2022-12-20 07:04:54.566067	0	\N
3818	0107000020E610000001000000010100000082734694F64A63401895D40968AA3CC0	26	2022-12-20 07:04:54.566067	0	\N
3819	0107000020E610000001000000010100000082734694F64A63407CF2B0506BAA3CC0	27	2022-12-20 07:04:54.566067	0	\N
3820	0107000020E610000001000000010100000082734694F64A6340DF4F8D976EAA3CC0	28	2022-12-20 07:04:54.566067	0	\N
3821	0107000020E610000001000000010100000082734694F64A634043AD69DE71AA3CC0	29	2022-12-20 07:04:54.566067	0	\N
3822	0107000020E610000001000000010100000082734694F64A6340A60A462575AA3CC0	30	2022-12-20 07:04:54.566067	0	\N
3823	0107000020E610000001000000010100000034A2B437F82A634027C286A757AA3CC0	31	2022-12-20 07:04:54.566067	0	\N
3824	0107000020E610000001000000010100000034A2B437F82A63408A1F63EE5AAA3CC0	32	2022-12-20 07:04:54.566067	0	\N
3825	0107000020E610000001000000010100000034A2B437F82A6340EE7C3F355EAA3CC0	33	2022-12-20 07:04:54.566067	0	\N
3826	0107000020E610000001000000010100000034A2B437F82A634051DA1B7C61AA3CC0	34	2022-12-20 07:04:54.566067	0	\N
3827	0107000020E610000001000000010100000034A2B437F82A6340B537F8C264AA3CC0	35	2022-12-20 07:04:54.566067	0	\N
3828	0107000020E610000001000000010100000034A2B437F82A63401895D40968AA3CC0	36	2022-12-20 07:04:54.566067	0	\N
3829	0107000020E610000001000000010100000034A2B437F82A63407CF2B0506BAA3CC0	37	2022-12-20 07:04:54.566067	0	\N
3830	0107000020E610000001000000010100000034A2B437F82A6340DF4F8D976EAA3CC0	38	2022-12-20 07:04:54.566067	0	\N
3831	0107000020E610000001000000010100000034A2B437F82A634043AD69DE71AA3CC0	39	2022-12-20 07:04:54.566067	0	\N
3832	0107000020E610000001000000010100000034A2B437F82A6340A60A462575AA3CC0	40	2022-12-20 07:04:54.566067	0	\N
3833	0107000020E6100000010000000101000000E5D022DBF92A634027C286A757AA3CC0	41	2022-12-20 07:04:54.566067	0	\N
3834	0107000020E6100000010000000101000000E5D022DBF92A63408A1F63EE5AAA3CC0	42	2022-12-20 07:04:54.566067	0	\N
3835	0107000020E6100000010000000101000000E5D022DBF92A6340EE7C3F355EAA3CC0	43	2022-12-20 07:04:54.566067	0	\N
3836	0107000020E6100000010000000101000000E5D022DBF92A634051DA1B7C61AA3CC0	44	2022-12-20 07:04:54.566067	0	\N
3837	0107000020E6100000010000000101000000E5D022DBF92A6340B537F8C264AA3CC0	45	2022-12-20 07:04:54.566067	0	\N
3838	0107000020E6100000010000000101000000E5D022DBF92A63401895D40968AA3CC0	46	2022-12-20 07:04:54.566067	0	\N
3839	0107000020E6100000010000000101000000E5D022DBF92A63407CF2B0506BAA3CC0	47	2022-12-20 07:04:54.566067	0	\N
3840	0107000020E6100000010000000101000000E5D022DBF92A6340DF4F8D976EAA3CC0	48	2022-12-20 07:04:54.566067	0	\N
3841	0107000020E6100000010000000101000000E5D022DBF92A634043AD69DE71AA3CC0	49	2022-12-20 07:04:54.566067	0	\N
3842	0107000020E6100000010000000101000000E5D022DBF92A6340A60A462575AA3CC0	50	2022-12-20 07:04:54.566067	0	\N
3843	0107000020E610000001000000010100000097FF907EFB2A634027C286A757AA3CC0	51	2022-12-20 07:04:54.566067	0	\N
3844	0107000020E610000001000000010100000097FF907EFB2A63408A1F63EE5AAA3CC0	52	2022-12-20 07:04:54.566067	0	\N
3845	0107000020E610000001000000010100000097FF907EFB2A6340EE7C3F355EAA3CC0	53	2022-12-20 07:04:54.566067	0	\N
3846	0107000020E610000001000000010100000097FF907EFB2A634051DA1B7C61AA3CC0	54	2022-12-20 07:04:54.566067	0	\N
3847	0107000020E610000001000000010100000097FF907EFB2A6340B537F8C264AA3CC0	55	2022-12-20 07:04:54.566067	0	\N
3848	0107000020E610000001000000010100000097FF907EFB2A63401895D40968AA3CC0	56	2022-12-20 07:04:54.566067	0	\N
3849	0107000020E610000001000000010100000097FF907EFB2A63407CF2B0506BAA3CC0	57	2022-12-20 07:04:54.566067	0	\N
3850	0107000020E610000001000000010100000097FF907EFB2A6340DF4F8D976EAA3CC0	58	2022-12-20 07:04:54.566067	0	\N
3851	0107000020E610000001000000010100000097FF907EFB2A634043AD69DE71AA3CC0	59	2022-12-20 07:04:54.566067	0	\N
3852	0107000020E610000001000000010100000097FF907EFB2A6340A60A462575AA3CC0	60	2022-12-20 07:04:54.566067	0	\N
3853	0107000020E6100000010000000101000000492EFF21FD2A634027C286A757AA3CC0	61	2022-12-20 07:04:54.566067	0	\N
3854	0107000020E6100000010000000101000000492EFF21FD2A63408A1F63EE5AAA3CC0	62	2022-12-20 07:04:54.566067	0	\N
3855	0107000020E6100000010000000101000000492EFF21FD2A6340EE7C3F355EAA3CC0	63	2022-12-20 07:04:54.566067	0	\N
3856	0107000020E6100000010000000101000000492EFF21FD2A634051DA1B7C61AA3CC0	64	2022-12-20 07:04:54.566067	0	\N
3857	0107000020E6100000010000000101000000492EFF21FD2A6340B537F8C264AA3CC0	65	2022-12-20 07:04:54.566067	0	\N
3858	0107000020E6100000010000000101000000492EFF21FD2A63401895D40968AA3CC0	66	2022-12-20 07:04:54.566067	0	\N
3859	0107000020E6100000010000000101000000492EFF21FD2A63407CF2B0506BAA3CC0	67	2022-12-20 07:04:54.566067	0	\N
3860	0107000020E6100000010000000101000000492EFF21FD2A6340DF4F8D976EAA3CC0	68	2022-12-20 07:04:54.566067	0	\N
3861	0107000020E6100000010000000101000000492EFF21FD2A634043AD69DE71AA3CC0	69	2022-12-20 07:04:54.566067	0	\N
3862	0107000020E6100000010000000101000000492EFF21FD2A6340A60A462575AA3CC0	70	2022-12-20 07:04:54.566067	0	\N
3863	0107000020E6100000010000000101000000FB5C6DC5FE2A634027C286A757AA3CC0	71	2022-12-20 07:04:54.566067	0	\N
3864	0107000020E6100000010000000101000000FB5C6DC5FE2A63408A1F63EE5AAA3CC0	72	2022-12-20 07:04:54.566067	0	\N
3865	0107000020E6100000010000000101000000FB5C6DC5FE2A6340EE7C3F355EAA3CC0	73	2022-12-20 07:04:54.566067	0	\N
3866	0107000020E6100000010000000101000000FB5C6DC5FE2A634051DA1B7C61AA3CC0	74	2022-12-20 07:04:54.566067	0	\N
3867	0107000020E6100000010000000101000000FB5C6DC5FE2A6340B537F8C264AA3CC0	75	2022-12-20 07:04:54.566067	0	\N
3868	0107000020E6100000010000000101000000FB5C6DC5FE2A63401895D40968AA3CC0	76	2022-12-20 07:04:54.566067	0	\N
3869	0107000020E6100000010000000101000000FB5C6DC5FE2A63407CF2B0506BAA3CC0	77	2022-12-20 07:04:54.566067	0	\N
3870	0107000020E6100000010000000101000000FB5C6DC5FE2A6340DF4F8D976EAA3CC0	78	2022-12-20 07:04:54.566067	0	\N
3871	0107000020E6100000010000000101000000FB5C6DC5FE2A634043AD69DE71AA3CC0	79	2022-12-20 07:04:54.566067	0	\N
3872	0107000020E6100000010000000101000000FB5C6DC5FE2A6340A60A462575AA3CC0	80	2022-12-20 07:04:54.566067	0	\N
3873	0107000020E6100000010000000101000000AC8BDB68002B634027C286A757AA3CC0	81	2022-12-20 07:04:54.566067	0	\N
3874	0107000020E6100000010000000101000000AC8BDB68002B63408A1F63EE5AAA3CC0	82	2022-12-20 07:04:54.566067	0	\N
3875	0107000020E6100000010000000101000000AC8BDB68002B6340EE7C3F355EAA3CC0	83	2022-12-20 07:04:54.566067	0	\N
3876	0107000020E6100000010000000101000000AC8BDB68002B634051DA1B7C61AA3CC0	84	2022-12-20 07:04:54.566067	0	\N
3877	0107000020E6100000010000000101000000AC8BDB68002B6340B537F8C264AA3CC0	85	2022-12-20 07:04:54.566067	0	\N
3878	0107000020E6100000010000000101000000AC8BDB68002B63401895D40968AA3CC0	86	2022-12-20 07:04:54.566067	0	\N
3879	0107000020E6100000010000000101000000AC8BDB68002B63407CF2B0506BAA3CC0	87	2022-12-20 07:04:54.566067	0	\N
3880	0107000020E6100000010000000101000000AC8BDB68002B6340DF4F8D976EAA3CC0	88	2022-12-20 07:04:54.566067	0	\N
3881	0107000020E6100000010000000101000000AC8BDB68002B634043AD69DE71AA3CC0	89	2022-12-20 07:04:54.566067	0	\N
3882	0107000020E61000000100000001010000005EBA490C022B6340A60A462575AA3CC0	90	2022-12-20 07:04:54.566067	0	\N
3883	0107000020E61000000100000001010000005EBA490C022B634027C286A757AA3CC0	91	2022-12-20 07:04:54.566067	0	\N
3884	0107000020E61000000100000001010000005EBA490C022B63408A1F63EE5AAA3CC0	92	2022-12-20 07:04:54.566067	0	\N
3885	0107000020E61000000100000001010000005EBA490C022B6340EE7C3F355EAA3CC0	93	2022-12-20 07:04:54.566067	0	\N
3886	0107000020E61000000100000001010000005EBA490C022B634051DA1B7C61AA3CC0	94	2022-12-20 07:04:54.566067	0	\N
3887	0107000020E61000000100000001010000005EBA490C022B6340B537F8C264AA3CC0	95	2022-12-20 07:04:54.566067	0	\N
3888	0107000020E61000000100000001010000005EBA490C022B63401895D40968AA3CC0	96	2022-12-20 07:04:54.566067	0	\N
3889	0107000020E61000000100000001010000005EBA490C022B63407CF2B0506BAA3CC0	97	2022-12-20 07:04:54.566067	0	\N
3890	0107000020E61000000100000001010000005EBA490C022B6340DF4F8D976EAA3CC0	98	2022-12-20 07:04:54.566067	0	\N
3891	0107000020E61000000100000001010000005EBA490C022B634043AD69DE71AA3CC0	99	2022-12-20 07:04:54.566067	0	\N
3892	0107000020E61000000100000001010000005EBA490C022B6340A60A462575AA3CC0	100	2022-12-20 07:04:54.566067	0	\N
3893	0107000020E610000001000000010100000010E9B7AF032B634027C286A757AA3CC0	101	2022-12-20 07:04:54.566067	0	\N
3894	0107000020E610000001000000010100000010E9B7AF032B63408A1F63EE5AAA3CC0	102	2022-12-20 07:04:54.566067	0	\N
3895	0107000020E610000001000000010100000010E9B7AF032B6340EE7C3F355EAA3CC0	103	2022-12-20 07:04:54.566067	0	\N
3896	0107000020E610000001000000010100000010E9B7AF032B634051DA1B7C61AA3CC0	104	2022-12-20 07:04:54.566067	0	\N
3897	0107000020E610000001000000010100000010E9B7AF032B6340B537F8C264AA3CC0	105	2022-12-20 07:04:54.566067	0	\N
3898	0107000020E610000001000000010100000010E9B7AF032B63401895D40968AA3CC0	106	2022-12-20 07:04:54.566067	0	\N
3899	0107000020E610000001000000010100000010E9B7AF032B63407CF2B0506BAA3CC0	107	2022-12-20 07:04:54.566067	0	\N
3900	0107000020E610000001000000010100000010E9B7AF032B6340DF4F8D976EAA3CC0	108	2022-12-20 07:04:54.566067	0	\N
3901	0107000020E610000001000000010100000010E9B7AF032B634043AD69DE71AA3CC0	109	2022-12-20 07:04:54.566067	0	\N
3902	0107000020E610000001000000010100000010E9B7AF032B6340A60A462575AA3CC0	110	2022-12-20 07:04:54.566067	0	\N
3903	0107000020E6100000010000000101000000C2172653052B634027C286A757AA3CC0	111	2022-12-20 07:04:54.566067	0	\N
3904	0107000020E6100000010000000101000000C2172653052B63408A1F63EE5AAA3CC0	112	2022-12-20 07:04:54.566067	0	\N
3905	0107000020E6100000010000000101000000C2172653052B6340EE7C3F355EAA3CC0	113	2022-12-20 07:04:54.566067	0	\N
3906	0107000020E6100000010000000101000000C2172653052B634051DA1B7C61AA3CC0	114	2022-12-20 07:04:54.566067	0	\N
3907	0107000020E6100000010000000101000000C2172653052B6340B537F8C264AA3CC0	115	2022-12-20 07:04:54.566067	0	\N
3908	0107000020E6100000010000000101000000C2172653052B63401895D40968AA3CC0	116	2022-12-20 07:04:54.566067	0	\N
3909	0107000020E6100000010000000101000000C2172653052B63407CF2B0506BAA3CC0	117	2022-12-20 07:04:54.566067	0	\N
3910	0107000020E6100000010000000101000000C2172653052B6340DF4F8D976EAA3CC0	118	2022-12-20 07:04:54.566067	0	\N
3911	0107000020E6100000010000000101000000C2172653052B634043AD69DE71AA3CC0	119	2022-12-20 07:04:54.566067	0	\N
3912	0107000020E6100000010000000101000000C2172653052B6340A60A462575AA3CC0	120	2022-12-20 07:04:54.566067	0	\N
3913	0107000020E6100000010000000101000000744694F6062B634027C286A757AA3CC0	121	2022-12-20 07:04:54.566067	0	\N
3914	0107000020E6100000010000000101000000744694F6062B63408A1F63EE5AAA3CC0	122	2022-12-20 07:04:54.566067	0	\N
3915	0107000020E6100000010000000101000000744694F6062B6340EE7C3F355EAA3CC0	123	2022-12-20 07:04:54.566067	0	\N
3916	0107000020E6100000010000000101000000744694F6062B634051DA1B7C61AA3CC0	124	2022-12-20 07:04:54.566067	0	\N
3917	0107000020E6100000010000000101000000744694F6062B6340B537F8C264AA3CC0	125	2022-12-20 07:04:54.566067	0	\N
3918	0107000020E6100000010000000101000000744694F6062B63401895D40968AA3CC0	126	2022-12-20 07:04:54.566067	0	\N
3919	0107000020E6100000010000000101000000744694F6062B63407CF2B0506BAA3CC0	127	2022-12-20 07:04:54.566067	0	\N
3920	0107000020E6100000010000000101000000744694F6062B6340DF4F8D976EAA3CC0	128	2022-12-20 07:04:54.566067	0	\N
3921	0107000020E6100000010000000101000000744694F6062B634043AD69DE71AA3CC0	129	2022-12-20 07:04:54.566067	0	\N
3922	0107000020E6100000010000000101000000744694F6062B6340A60A462575AA3CC0	130	2022-12-20 07:04:54.566067	0	\N
3923	0107000020E61000000100000001010000002575029A082B634027C286A757AA3CC0	131	2022-12-20 07:04:54.566067	0	\N
3924	0107000020E61000000100000001010000002575029A082B63408A1F63EE5AAA3CC0	132	2022-12-20 07:04:54.566067	0	\N
3925	0107000020E61000000100000001010000002575029A082B6340EE7C3F355EAA3CC0	133	2022-12-20 07:04:54.566067	0	\N
3926	0107000020E61000000100000001010000002575029A082B634051DA1B7C61AA3CC0	134	2022-12-20 07:04:54.566067	0	\N
3927	0107000020E61000000100000001010000002575029A082B6340B537F8C264AA3CC0	135	2022-12-20 07:04:54.566067	0	\N
3928	0107000020E61000000100000001010000002575029A082B63401895D40968AA3CC0	136	2022-12-20 07:04:54.566067	0	\N
3929	0107000020E61000000100000001010000002575029A082B63407CF2B0506BAA3CC0	137	2022-12-20 07:04:54.566067	0	\N
3930	0107000020E61000000100000001010000002575029A082B6340DF4F8D976EAA3CC0	138	2022-12-20 07:04:54.566067	0	\N
3931	0107000020E61000000100000001010000002575029A082B634043AD69DE71AA3CC0	139	2022-12-20 07:04:54.566067	0	\N
3932	0107000020E61000000100000001010000002575029A082B6340A60A462575AA3CC0	140	2022-12-20 07:04:54.566067	0	\N
3933	0107000020E6100000010000000101000000D7A3703D0A2B634027C286A757AA3CC0	141	2022-12-20 07:04:54.566067	0	\N
3934	0107000020E6100000010000000101000000D7A3703D0A2B63408A1F63EE5AAA3CC0	142	2022-12-20 07:04:54.566067	0	\N
3935	0107000020E6100000010000000101000000D7A3703D0A2B6340EE7C3F355EAA3CC0	143	2022-12-20 07:04:54.566067	0	\N
3936	0107000020E6100000010000000101000000D7A3703D0A2B634051DA1B7C61AA3CC0	144	2022-12-20 07:04:54.566067	0	\N
3937	0107000020E6100000010000000101000000D7A3703D0A2B6340B537F8C264AA3CC0	145	2022-12-20 07:04:54.566067	0	\N
3938	0107000020E6100000010000000101000000D7A3703D0A2B63401895D40968AA3CC0	146	2022-12-20 07:04:54.566067	0	\N
3939	0107000020E6100000010000000101000000D7A3703D0A2B63407CF2B0506BAA3CC0	147	2022-12-20 07:04:54.566067	0	\N
3940	0107000020E6100000010000000101000000D7A3703D0A2B6340DF4F8D976EAA3CC0	148	2022-12-20 07:04:54.566067	0	\N
3941	0107000020E6100000010000000101000000D7A3703D0A2B634043AD69DE71AA3CC0	149	2022-12-20 07:04:54.566067	0	\N
3942	0107000020E6100000010000000101000000D7A3703D0A2B6340A60A462575AA3CC0	150	2022-12-20 07:04:54.566067	0	\N
3943	0107000020E610000001000000010100000089D2DEE00B2B634027C286A757AA3CC0	151	2022-12-20 07:04:54.566067	0	\N
3944	0107000020E610000001000000010100000089D2DEE00B2B63408A1F63EE5AAA3CC0	152	2022-12-20 07:04:54.566067	0	\N
3945	0107000020E610000001000000010100000089D2DEE00B2B6340EE7C3F355EAA3CC0	153	2022-12-20 07:04:54.566067	0	\N
3946	0107000020E610000001000000010100000089D2DEE00B2B634051DA1B7C61AA3CC0	154	2022-12-20 07:04:54.566067	0	\N
3947	0107000020E610000001000000010100000089D2DEE00B2B6340B537F8C264AA3CC0	155	2022-12-20 07:04:54.566067	0	\N
3948	0107000020E610000001000000010100000089D2DEE00B2B63401895D40968AA3CC0	156	2022-12-20 07:04:54.566067	0	\N
3949	0107000020E610000001000000010100000089D2DEE00B2B63407CF2B0506BAA3CC0	157	2022-12-20 07:04:54.566067	0	\N
3950	0107000020E610000001000000010100000089D2DEE00B2B6340DF4F8D976EAA3CC0	158	2022-12-20 07:04:54.566067	0	\N
3951	0107000020E610000001000000010100000089D2DEE00B2B634043AD69DE71AA3CC0	159	2022-12-20 07:04:54.566067	0	\N
3952	0107000020E610000001000000010100000089D2DEE00B2B6340A60A462575AA3CC0	160	2022-12-20 07:04:54.566067	0	\N
3953	0107000020E61000000100000001010000003B014D840D2B634027C286A757AA3CC0	161	2022-12-20 07:04:54.566067	0	\N
3954	0107000020E61000000100000001010000003B014D840D2B63408A1F63EE5AAA3CC0	162	2022-12-20 07:04:54.566067	0	\N
3955	0107000020E61000000100000001010000003B014D840D2B6340EE7C3F355EAA3CC0	163	2022-12-20 07:04:54.566067	0	\N
3956	0107000020E61000000100000001010000003B014D840D2B634051DA1B7C61AA3CC0	164	2022-12-20 07:04:54.566067	0	\N
3957	0107000020E61000000100000001010000003B014D840D2B6340B537F8C264AA3CC0	165	2022-12-20 07:04:54.566067	0	\N
3958	0107000020E61000000100000001010000003B014D840D2B63401895D40968AA3CC0	166	2022-12-20 07:04:54.566067	0	\N
3959	0107000020E61000000100000001010000003B014D840D2B63407CF2B0506BAA3CC0	167	2022-12-20 07:04:54.566067	0	\N
3960	0107000020E61000000100000001010000003B014D840D2B6340DF4F8D976EAA3CC0	168	2022-12-20 07:04:54.566067	0	\N
3961	0107000020E61000000100000001010000003B014D840D2B634043AD69DE71AA3CC0	169	2022-12-20 07:04:54.566067	0	\N
3962	0107000020E61000000100000001010000003B014D840D2B6340A60A462575AA3CC0	170	2022-12-20 07:04:54.566067	0	\N
3963	0107000020E6100000010000000101000000EC2FBB270F2B634027C286A757AA3CC0	171	2022-12-20 07:04:54.566067	0	\N
3964	0107000020E6100000010000000101000000EC2FBB270F2B63408A1F63EE5AAA3CC0	172	2022-12-20 07:04:54.566067	0	\N
3965	0107000020E6100000010000000101000000EC2FBB270F2B6340EE7C3F355EAA3CC0	173	2022-12-20 07:04:54.566067	0	\N
3966	0107000020E6100000010000000101000000EC2FBB270F2B634051DA1B7C61AA3CC0	174	2022-12-20 07:04:54.566067	0	\N
3967	0107000020E6100000010000000101000000EC2FBB270F2B6340B537F8C264AA3CC0	175	2022-12-20 07:04:54.566067	0	\N
3968	0107000020E6100000010000000101000000EC2FBB270F2B63401895D40968AA3CC0	176	2022-12-20 07:04:54.566067	0	\N
3969	0107000020E6100000010000000101000000EC2FBB270F2B63407CF2B0506BAA3CC0	177	2022-12-20 07:04:54.566067	0	\N
3970	0107000020E6100000010000000101000000EC2FBB270F2B6340DF4F8D976EAA3CC0	178	2022-12-20 07:04:54.566067	0	\N
3971	0107000020E6100000010000000101000000EC2FBB270F2B634043AD69DE71AA3CC0	179	2022-12-20 07:04:54.566067	0	\N
3972	0107000020E6100000010000000101000000EC2FBB270F2B6340A60A462575AA3CC0	180	2022-12-20 07:04:54.566067	0	\N
3973	0107000020E61000000100000001010000009E5E29CB102B634027C286A757AA3CC0	181	2022-12-20 07:04:54.566067	0	\N
3974	0107000020E61000000100000001010000009E5E29CB102B63408A1F63EE5AAA3CC0	182	2022-12-20 07:04:54.566067	0	\N
3975	0107000020E61000000100000001010000009E5E29CB102B6340EE7C3F355EAA3CC0	183	2022-12-20 07:04:54.566067	0	\N
3976	0107000020E61000000100000001010000009E5E29CB102B634051DA1B7C61AA3CC0	184	2022-12-20 07:04:54.566067	0	\N
3977	0107000020E61000000100000001010000009E5E29CB102B6340B537F8C264AA3CC0	185	2022-12-20 07:04:54.566067	0	\N
3978	0107000020E61000000100000001010000009E5E29CB102B63401895D40968AA3CC0	186	2022-12-20 07:04:54.566067	0	\N
3979	0107000020E61000000100000001010000009E5E29CB102B63407CF2B0506BAA3CC0	187	2022-12-20 07:04:54.566067	0	\N
3980	0107000020E61000000100000001010000009E5E29CB102B6340DF4F8D976EAA3CC0	188	2022-12-20 07:04:54.566067	0	\N
3981	0107000020E61000000100000001010000009E5E29CB102B634043AD69DE71AA3CC0	189	2022-12-20 07:04:54.566067	0	\N
3982	0107000020E61000000100000001010000009E5E29CB102B6340A60A462575AA3CC0	190	2022-12-20 07:04:54.566067	0	\N
3983	0107000020E6100000010000000101000000508D976E122B634027C286A757AA3CC0	191	2022-12-20 07:04:54.566067	0	\N
3984	0107000020E6100000010000000101000000508D976E122B63408A1F63EE5AAA3CC0	192	2022-12-20 07:04:54.566067	0	\N
3985	0107000020E6100000010000000101000000508D976E122B6340EE7C3F355EAA3CC0	193	2022-12-20 07:04:54.566067	0	\N
3986	0107000020E6100000010000000101000000508D976E122B634051DA1B7C61AA3CC0	194	2022-12-20 07:04:54.566067	0	\N
3987	0107000020E6100000010000000101000000508D976E122B6340B537F8C264AA3CC0	195	2022-12-20 07:04:54.566067	0	\N
3988	0107000020E6100000010000000101000000508D976E122B63401895D40968AA3CC0	196	2022-12-20 07:04:54.566067	0	\N
3989	0107000020E6100000010000000101000000508D976E122B63407CF2B0506BAA3CC0	197	2022-12-20 07:04:54.566067	0	\N
3990	0107000020E6100000010000000101000000508D976E122B6340DF4F8D976EAA3CC0	198	2022-12-20 07:04:54.566067	0	\N
\.


--
-- Name: contactloc_contactlocid_seq; Type: SEQUENCE SET; Schema: public; Owner: kddart_dal
--

SELECT pg_catalog.setval('public.contactloc_contactlocid_seq', 1, false);


--
-- Name: layer2_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kddart_dal
--

SELECT pg_catalog.setval('public.layer2_id_seq', 1, false);


--
-- Name: layer2attrib_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kddart_dal
--

SELECT pg_catalog.setval('public.layer2attrib_id_seq', 1, false);


--
-- Name: layer2dn_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kddart_dal
--

SELECT pg_catalog.setval('public.layer2dn_id_seq', 1, false);


--
-- Name: layer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kddart_dal
--

SELECT pg_catalog.setval('public.layer_id_seq', 2, true);


--
-- Name: layerattrib_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kddart_dal
--

SELECT pg_catalog.setval('public.layerattrib_id_seq', 4, true);


--
-- Name: layern_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kddart_dal
--

SELECT pg_catalog.setval('public.layern_id_seq', 1, false);


--
-- Name: layernattrib_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kddart_dal
--

SELECT pg_catalog.setval('public.layernattrib_id_seq', 1, false);


--
-- Name: siteloc_sitelocid_seq; Type: SEQUENCE SET; Schema: public; Owner: kddart_dal
--

SELECT pg_catalog.setval('public.siteloc_sitelocid_seq', 7, true);


--
-- Name: specimenloc_specimenlocid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.specimenloc_specimenlocid_seq', 1, false);


--
-- Name: storageloc_storagelocid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.storageloc_storagelocid_seq', 1, false);


--
-- Name: surveyloc_surveylocid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.surveyloc_surveylocid_seq', 1, false);


--
-- Name: tiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tiles_id_seq', 1, false);


--
-- Name: trialloc_triallocid_seq; Type: SEQUENCE SET; Schema: public; Owner: kddart_dal
--

SELECT pg_catalog.setval('public.trialloc_triallocid_seq', 15, true);


--
-- Name: trialunitloc_trialunitlocid_seq; Type: SEQUENCE SET; Schema: public; Owner: kddart_dal
--

SELECT pg_catalog.setval('public.trialunitloc_trialunitlocid_seq', 198, true);


--
-- Name: contactloc contactloc_pkey; Type: CONSTRAINT; Schema: public; Owner: kddart_dal
--

ALTER TABLE ONLY public.contactloc
    ADD CONSTRAINT contactloc_pkey PRIMARY KEY (contactlocid);


--
-- Name: layer2 layer2_pkey; Type: CONSTRAINT; Schema: public; Owner: kddart_dal
--

ALTER TABLE ONLY public.layer2
    ADD CONSTRAINT layer2_pkey PRIMARY KEY (id);


--
-- Name: layer2attrib layer2attrib_pkey; Type: CONSTRAINT; Schema: public; Owner: kddart_dal
--

ALTER TABLE ONLY public.layer2attrib
    ADD CONSTRAINT layer2attrib_pkey PRIMARY KEY (id);


--
-- Name: layer2dn layer2dn_pkey; Type: CONSTRAINT; Schema: public; Owner: kddart_dal
--

ALTER TABLE ONLY public.layer2dn
    ADD CONSTRAINT layer2dn_pkey PRIMARY KEY (id);


--
-- Name: layer layer_pkey; Type: CONSTRAINT; Schema: public; Owner: kddart_dal
--

ALTER TABLE ONLY public.layer
    ADD CONSTRAINT layer_pkey PRIMARY KEY (id);


--
-- Name: layerattrib layerattrib_pkey; Type: CONSTRAINT; Schema: public; Owner: kddart_dal
--

ALTER TABLE ONLY public.layerattrib
    ADD CONSTRAINT layerattrib_pkey PRIMARY KEY (id);


--
-- Name: layern layern_pkey; Type: CONSTRAINT; Schema: public; Owner: kddart_dal
--

ALTER TABLE ONLY public.layern
    ADD CONSTRAINT layern_pkey PRIMARY KEY (id);


--
-- Name: layernattrib layernattrib_pkey; Type: CONSTRAINT; Schema: public; Owner: kddart_dal
--

ALTER TABLE ONLY public.layernattrib
    ADD CONSTRAINT layernattrib_pkey PRIMARY KEY (id);


--
-- Name: siteloc siteloc_pkey; Type: CONSTRAINT; Schema: public; Owner: kddart_dal
--

ALTER TABLE ONLY public.siteloc
    ADD CONSTRAINT siteloc_pkey PRIMARY KEY (sitelocid);


--
-- Name: specimenloc specimenloc_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.specimenloc
    ADD CONSTRAINT specimenloc_pkey PRIMARY KEY (specimenlocid);


--
-- Name: storageloc storageloc_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.storageloc
    ADD CONSTRAINT storageloc_pkey PRIMARY KEY (storagelocid);


--
-- Name: surveyloc surveyloc_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.surveyloc
    ADD CONSTRAINT surveyloc_pkey PRIMARY KEY (surveylocid);


--
-- Name: tileset tileset_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tileset
    ADD CONSTRAINT tileset_pkey PRIMARY KEY (id);


--
-- Name: trialloc trialloc_pkey; Type: CONSTRAINT; Schema: public; Owner: kddart_dal
--

ALTER TABLE ONLY public.trialloc
    ADD CONSTRAINT trialloc_pkey PRIMARY KEY (triallocid);


--
-- Name: trialunitloc trialunitloc_pkey; Type: CONSTRAINT; Schema: public; Owner: kddart_dal
--

ALTER TABLE ONLY public.trialunitloc
    ADD CONSTRAINT trialunitloc_pkey PRIMARY KEY (trialunitlocid);


--
-- Name: datadevice xdatadevice_unique; Type: CONSTRAINT; Schema: public; Owner: kddart_dal
--

ALTER TABLE ONLY public.datadevice
    ADD CONSTRAINT xdatadevice_unique UNIQUE (deviceid, deviceparam, layerattrib);


--
-- Name: layer xlayer_name; Type: CONSTRAINT; Schema: public; Owner: kddart_dal
--

ALTER TABLE ONLY public.layer
    ADD CONSTRAINT xlayer_name UNIQUE (name);


--
-- Name: layer2_sp_index; Type: INDEX; Schema: public; Owner: kddart_dal
--

CREATE INDEX layer2_sp_index ON public.layer2 USING gist (geometry);


--
-- Name: tiles_geometry; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tiles_geometry ON public.tiles USING gist (geometry);


--
-- Name: tiles_idx_1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tiles_idx_1 ON public.tiles USING btree (id);


--
-- Name: tiles_tileset; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tiles_tileset ON public.tiles USING btree (tileset);


--
-- Name: tiles_xcoord; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tiles_xcoord ON public.tiles USING btree (xcoord);


--
-- Name: tiles_ycoord; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tiles_ycoord ON public.tiles USING btree (ycoord);


--
-- Name: tiles_zoomlevel; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tiles_zoomlevel ON public.tiles USING btree (zoomlevel);


--
-- Name: ts_geometry; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ts_geometry ON public.tileset USING gist (geometry);


--
-- Name: ts_maxzoom; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ts_maxzoom ON public.tileset USING btree (maxzoom);


--
-- Name: ts_minzoom; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ts_minzoom ON public.tileset USING btree (minzoom);


--
-- Name: ts_resolution; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ts_resolution ON public.tileset USING btree (resolution);


--
-- Name: ts_tilestatus; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ts_tilestatus ON public.tileset USING btree (tilestatus);


--
-- Name: xcl_contactid; Type: INDEX; Schema: public; Owner: kddart_dal
--

CREATE INDEX xcl_contactid ON public.contactloc USING btree (contactid);


--
-- Name: xcl_contactlocation; Type: INDEX; Schema: public; Owner: kddart_dal
--

CREATE INDEX xcl_contactlocation ON public.contactloc USING gist (contactlocation);


--
-- Name: xcl_contactlocdt; Type: INDEX; Schema: public; Owner: kddart_dal
--

CREATE INDEX xcl_contactlocdt ON public.contactloc USING btree (contactlocdt);


--
-- Name: xcl_currentloc; Type: INDEX; Schema: public; Owner: kddart_dal
--

CREATE INDEX xcl_currentloc ON public.contactloc USING btree (currentloc);


--
-- Name: xdatadevice_layerattrib; Type: INDEX; Schema: public; Owner: kddart_dal
--

CREATE INDEX xdatadevice_layerattrib ON public.datadevice USING btree (layerattrib);


--
-- Name: xl2d_geometry; Type: INDEX; Schema: public; Owner: kddart_dal
--

CREATE INDEX xl2d_geometry ON public.layer2dn USING gist (geometry);


--
-- Name: xlayer_parent; Type: INDEX; Schema: public; Owner: kddart_dal
--

CREATE INDEX xlayer_parent ON public.layer USING btree (parent);


--
-- Name: xlayerattrib_layer; Type: INDEX; Schema: public; Owner: kddart_dal
--

CREATE INDEX xlayerattrib_layer ON public.layerattrib USING btree (layer);


--
-- Name: xlayerattrib_unitid; Type: INDEX; Schema: public; Owner: kddart_dal
--

CREATE INDEX xlayerattrib_unitid ON public.layerattrib USING btree (unitid);


--
-- Name: xlayernattrib_dt; Type: INDEX; Schema: public; Owner: kddart_dal
--

CREATE INDEX xlayernattrib_dt ON public.layernattrib USING btree (dt);


--
-- Name: xlayernattrib_layerattrib; Type: INDEX; Schema: public; Owner: kddart_dal
--

CREATE INDEX xlayernattrib_layerattrib ON public.layernattrib USING btree (layerattrib);


--
-- Name: xlayernattrib_layerid; Type: INDEX; Schema: public; Owner: kddart_dal
--

CREATE INDEX xlayernattrib_layerid ON public.layernattrib USING btree (layerid);


--
-- Name: xlayernattrib_sysuid; Type: INDEX; Schema: public; Owner: kddart_dal
--

CREATE INDEX xlayernattrib_sysuid ON public.layernattrib USING btree (systemuserid);


--
-- Name: xln_geometry; Type: INDEX; Schema: public; Owner: kddart_dal
--

CREATE INDEX xln_geometry ON public.layern USING gist (geometry);


--
-- Name: xsl_currentloc; Type: INDEX; Schema: public; Owner: kddart_dal
--

CREATE INDEX xsl_currentloc ON public.siteloc USING btree (currentloc);


--
-- Name: xsl_siteid; Type: INDEX; Schema: public; Owner: kddart_dal
--

CREATE INDEX xsl_siteid ON public.siteloc USING btree (siteid);


--
-- Name: xsl_sitelocation; Type: INDEX; Schema: public; Owner: kddart_dal
--

CREATE INDEX xsl_sitelocation ON public.siteloc USING gist (sitelocation);


--
-- Name: xsl_sitelocdt; Type: INDEX; Schema: public; Owner: kddart_dal
--

CREATE INDEX xsl_sitelocdt ON public.siteloc USING btree (sitelocdt);


--
-- Name: xspl_currentloc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX xspl_currentloc ON public.specimenloc USING btree (currentloc);


--
-- Name: xspl_specimenid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX xspl_specimenid ON public.specimenloc USING btree (specimenid);


--
-- Name: xspl_specimenlocation; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX xspl_specimenlocation ON public.specimenloc USING gist (specimenlocation);


--
-- Name: xspl_specimenlocdt; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX xspl_specimenlocdt ON public.specimenloc USING btree (specimenlocdt);


--
-- Name: xstl_currentloc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX xstl_currentloc ON public.storageloc USING btree (currentloc);


--
-- Name: xstl_storageid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX xstl_storageid ON public.storageloc USING btree (storageid);


--
-- Name: xstl_storagelocation; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX xstl_storagelocation ON public.storageloc USING gist (storagelocation);


--
-- Name: xstl_storagelocdt; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX xstl_storagelocdt ON public.storageloc USING btree (storagelocdt);


--
-- Name: xsul_currentloc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX xsul_currentloc ON public.surveyloc USING btree (currentloc);


--
-- Name: xsul_surveyid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX xsul_surveyid ON public.surveyloc USING btree (surveyid);


--
-- Name: xsul_surveylocation; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX xsul_surveylocation ON public.surveyloc USING gist (surverylocation);


--
-- Name: xsul_surveylocdt; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX xsul_surveylocdt ON public.surveyloc USING btree (surverylocdt);


--
-- Name: xtl_currentloc; Type: INDEX; Schema: public; Owner: kddart_dal
--

CREATE INDEX xtl_currentloc ON public.trialloc USING btree (currentloc);


--
-- Name: xtl_trialid; Type: INDEX; Schema: public; Owner: kddart_dal
--

CREATE INDEX xtl_trialid ON public.trialloc USING btree (trialid);


--
-- Name: xtl_triallocation; Type: INDEX; Schema: public; Owner: kddart_dal
--

CREATE INDEX xtl_triallocation ON public.trialloc USING gist (triallocation);


--
-- Name: xtl_triallocdt; Type: INDEX; Schema: public; Owner: kddart_dal
--

CREATE INDEX xtl_triallocdt ON public.trialloc USING btree (triallocdt);


--
-- Name: xtul_currentloc; Type: INDEX; Schema: public; Owner: kddart_dal
--

CREATE INDEX xtul_currentloc ON public.trialunitloc USING btree (currentloc);


--
-- Name: xtul_trialunitid; Type: INDEX; Schema: public; Owner: kddart_dal
--

CREATE INDEX xtul_trialunitid ON public.trialunitloc USING btree (trialunitid);


--
-- Name: xtul_trialunitlocation; Type: INDEX; Schema: public; Owner: kddart_dal
--

CREATE INDEX xtul_trialunitlocation ON public.trialunitloc USING gist (trialunitlocation);


--
-- Name: xtul_trialunitlocdt; Type: INDEX; Schema: public; Owner: kddart_dal
--

CREATE INDEX xtul_trialunitlocdt ON public.trialunitloc USING btree (trialunitlocdt);


--
-- Name: datadevice datadevice_layerattrib_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kddart_dal
--

ALTER TABLE ONLY public.datadevice
    ADD CONSTRAINT datadevice_layerattrib_fkey FOREIGN KEY (layerattrib) REFERENCES public.layerattrib(id) DEFERRABLE;


--
-- Name: layer layer_parent_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kddart_dal
--

ALTER TABLE ONLY public.layer
    ADD CONSTRAINT layer_parent_fkey FOREIGN KEY (parent) REFERENCES public.layer(id) DEFERRABLE;


--
-- Name: layerattrib layerattrib_layer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kddart_dal
--

ALTER TABLE ONLY public.layerattrib
    ADD CONSTRAINT layerattrib_layer_fkey FOREIGN KEY (layer) REFERENCES public.layer(id) DEFERRABLE;


--
-- Name: layernattrib layernattrib_layerattrib_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kddart_dal
--

ALTER TABLE ONLY public.layernattrib
    ADD CONSTRAINT layernattrib_layerattrib_fkey FOREIGN KEY (layerattrib) REFERENCES public.layerattrib(id) DEFERRABLE;


--
-- Name: layernattrib layernattrib_layerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: kddart_dal
--

ALTER TABLE ONLY public.layernattrib
    ADD CONSTRAINT layernattrib_layerid_fkey FOREIGN KEY (layerid) REFERENCES public.layern(id) DEFERRABLE;


--
-- Name: tiles tiles_tileset_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tiles
    ADD CONSTRAINT tiles_tileset_fkey FOREIGN KEY (tileset) REFERENCES public.tileset(id) DEFERRABLE;


--
-- Name: tileset tileset_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tileset
    ADD CONSTRAINT tileset_id_fkey FOREIGN KEY (id) REFERENCES public.layer(id) DEFERRABLE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: TABLE geography_columns; Type: ACL; Schema: public; Owner: kddart_dal
--

REVOKE ALL ON TABLE public.geography_columns FROM postgres;
REVOKE SELECT ON TABLE public.geography_columns FROM PUBLIC;
GRANT ALL ON TABLE public.geography_columns TO kddart_dal;
GRANT SELECT ON TABLE public.geography_columns TO PUBLIC;


--
-- Name: TABLE geometry_columns; Type: ACL; Schema: public; Owner: kddart_dal
--

REVOKE ALL ON TABLE public.geometry_columns FROM postgres;
REVOKE SELECT ON TABLE public.geometry_columns FROM PUBLIC;
GRANT ALL ON TABLE public.geometry_columns TO kddart_dal;
GRANT SELECT ON TABLE public.geometry_columns TO PUBLIC;


--
-- Name: TABLE spatial_ref_sys; Type: ACL; Schema: public; Owner: kddart_dal
--

REVOKE ALL ON TABLE public.spatial_ref_sys FROM postgres;
REVOKE SELECT ON TABLE public.spatial_ref_sys FROM PUBLIC;
GRANT ALL ON TABLE public.spatial_ref_sys TO kddart_dal;
GRANT SELECT ON TABLE public.spatial_ref_sys TO PUBLIC;


--
-- PostgreSQL database dump complete
--

