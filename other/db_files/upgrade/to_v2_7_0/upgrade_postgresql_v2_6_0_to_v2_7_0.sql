-- Convert schema 'KDDart_enviro_doc-260.sql' to 'KDDart_enviro_doc-270.sql':;

BEGIN;

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

CREATE TABLE "surveyloc" (
  "surveylocid" serial NOT NULL,
  "surveyid" bigint NOT NULL,
  "surverylocation" geography(GEOMETRYCOLLECTION, 4326) NOT NULL,
  "surverylocdt" timestamp NOT NULL,
  "currentloc" smallint NOT NULL,
  "description" character varying(254),
  PRIMARY KEY ("surveylocid")
);

CREATE INDEX "xsul_surveyid" on "surveyloc" ("surveyid");
CREATE INDEX "xsul_surveylocation" on "surveyloc" USING GIST  ("surverylocation");
CREATE INDEX "xsul_surveylocdt" on "surveyloc" ("surverylocdt");
CREATE INDEX "xsul_currentloc" on "surveyloc" ("currentloc");

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

ALTER TABLE tiles ADD FOREIGN KEY (tileset)
  REFERENCES tileset (id) ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE tileset ADD FOREIGN KEY (id)
  REFERENCES layer (id) ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE contactloc DROP CONSTRAINT IF EXISTS contactloc_pkey;

ALTER TABLE contactloc ADD COLUMN contactlocid serial NOT NULL;

ALTER TABLE contactloc ADD COLUMN contactlocdt timestamp NOT NULL DEFAULT NOW();

ALTER TABLE contactloc ADD COLUMN currentloc integer NOT NULL DEFAULT 0;

ALTER TABLE contactloc ADD COLUMN description character varying(254);

CREATE INDEX xcl_contactid on contactloc (contactid);

CREATE INDEX xcl_contactlocdt on contactloc (contactlocdt);

CREATE INDEX xcl_currentloc on contactloc (currentloc);

ALTER TABLE contactloc ADD PRIMARY KEY (contactlocid);

ALTER TABLE siteloc DROP CONSTRAINT IF EXISTS siteloc_pkey;

ALTER TABLE siteloc ADD COLUMN sitelocid serial NOT NULL;

ALTER TABLE siteloc ADD COLUMN sitelocdt timestamp NOT NULL DEFAULT NOW();

ALTER TABLE siteloc ADD COLUMN currentloc integer NOT NULL DEFAULT 0;

ALTER TABLE siteloc ADD COLUMN description character varying(254);

CREATE INDEX xsl_siteid on siteloc (siteid);

CREATE INDEX xsl_sitelocdt on siteloc (sitelocdt);

CREATE INDEX xsl_currentloc on siteloc (currentloc);

ALTER TABLE siteloc ADD PRIMARY KEY (sitelocid);

ALTER TABLE trialloc DROP CONSTRAINT IF EXISTS trialloc_pkey;

ALTER TABLE trialloc ADD COLUMN triallocid serial NOT NULL;

ALTER TABLE trialloc ADD COLUMN triallocdt timestamp NOT NULL DEFAULT NOW();

ALTER TABLE trialloc ADD COLUMN currentloc integer NOT NULL DEFAULT 0;

ALTER TABLE trialloc ADD COLUMN description character varying(254);

CREATE INDEX xtl_trialid on trialloc (trialid);

CREATE INDEX xtl_triallocdt on trialloc (triallocdt);

CREATE INDEX xtl_currentloc on trialloc (currentloc);

ALTER TABLE trialloc ADD PRIMARY KEY (triallocid);

ALTER TABLE trialunitloc DROP CONSTRAINT IF EXISTS trialunitloc_pkey;

ALTER TABLE trialunitloc ADD COLUMN trialunitlocid serial NOT NULL;

ALTER TABLE trialunitloc ADD COLUMN trialunitlocdt timestamp NOT NULL DEFAULT NOW();

ALTER TABLE trialunitloc ADD COLUMN currentloc integer NOT NULL DEFAULT 0;

ALTER TABLE trialunitloc ADD COLUMN description character varying(254);

CREATE INDEX xtul_trialunitid on trialunitloc (trialunitid);

CREATE INDEX xtul_trialunitlocdt on trialunitloc (trialunitlocdt);

CREATE INDEX xtul_currentloc on trialunitloc (currentloc);

ALTER TABLE trialunitloc ADD PRIMARY KEY (trialunitlocid);

DROP TABLE layerimgn CASCADE;

COMMIT;

