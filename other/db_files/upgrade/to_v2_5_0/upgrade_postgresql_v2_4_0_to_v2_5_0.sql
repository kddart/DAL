-- Convert schema 'kddart_gis_enviro_dal_v2.4.0_postgis2.sql' to 'kddart_gis_enviro_dal_v2.5.0_postgis2.sql':;

BEGIN;

ALTER TABLE layernattrib ADD COLUMN deviceid character varying(100);


COMMIT;

