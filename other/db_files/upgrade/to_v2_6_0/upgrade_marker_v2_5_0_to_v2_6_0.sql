
ALTER TABLE "analysisgroup" ADD COLUMN "AnalysisGroupMetaData" TEXT NULL;

ALTER TABLE "plate" ADD COLUMN "PlateMetaData" TEXT NULL;

INSERT INTO "fieldcomment" ("TableName", "FieldName", "FieldComment", "PrimaryKey") VALUES
  ('analysisgroup', 'AnalysisGroupMetaData', 'Meta data for analysis group in JSON serialize format', 0),
  ('plate', 'PlateMetaData', 'Meta data for plate in JSON serialized format', 0)
;

