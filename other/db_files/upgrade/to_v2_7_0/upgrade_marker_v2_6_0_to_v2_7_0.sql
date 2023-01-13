CREATE TABLE "extractdata" (
  "ExtractDataId" INTEGER NOT NULL AUTO_INCREMENT,
  "AnalGroupExtractId" INTEGER NOT NULL,
  "OperatorId" INTEGER NOT NULL,
  "DateCreated" TIMESTAMP NOT NULL,
  "ExternalId" VARCHAR(254) NULL,
  "ExtractDataMeta" text NULL,
  PRIMARY KEY ("ExtractDataId"),
  CONSTRAINT extractdata_fk FOREIGN KEY ("AnalGroupExtractId") REFERENCES analgroupextract ("AnalGroupExtractId") ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE  INDEX "xed_OperatorId" ON "extractdata" ("OperatorId");

CREATE  INDEX "xed_DateCreated" ON "extractdata" ("DateCreated");

CREATE  INDEX "xed_ExternalId" ON "extractdata" ("ExternalId");

CREATE  INDEX "xed_AnalGroupExtractId" ON "extractdata" ("AnalGroupExtractId");


CREATE TABLE "extractdatafile" (
  "ExtractDataFileId" INTEGER NOT NULL AUTO_INCREMENT,
  "ExtractDataId" INTEGER NOT NULL,
  "OperatorId" INTEGER NOT NULL,
  "FileType" INTEGER NOT NULL,
  "UploadTime" TIMESTAMP NOT NULL,
  "FileExtension" VARCHAR(10) NULL,
  "FileMeta" text NULL,
  PRIMARY KEY ("ExtractDataFileId")
);

CREATE  INDEX "xedf_ExtractDataId" ON "extractdatafile" ("ExtractDataId");

CREATE  INDEX "xedf_OperatorId" ON "extractdatafile" ("OperatorId");

CREATE  INDEX "xedf_FileType" ON "extractdatafile" ("FileType");

CREATE  INDEX "xedf_UploadTime" ON "extractdatafile" ("UploadTime");

CREATE  INDEX "xedf_FileExtension" ON "extractdatafile" ("FileExtension");

ALTER TABLE "analysisgroup" ADD COLUMN "DateCreated" TIMESTAMP NULL;
ALTER TABLE "analysisgroup" ADD COLUMN "DateUpdated" TIMESTAMP NULL;
CREATE INDEX "xag_DateCreated" ON "analysisgroup" ("DateCreated");
CREATE INDEX "xag_DateUpdated" ON "analysisgroup" ("DateUpdated");


ALTER TABLE "dataset" ADD COLUMN "DateCreated" TIMESTAMP NULL;
ALTER TABLE "dataset" ADD COLUMN "DateUpdated" TIMESTAMP NULL;
CREATE INDEX "xds_DateCreated" ON "dataset" ("DateCreated");
CREATE INDEX "xds_DateUpdated" ON "dataset" ("DateUpdated");