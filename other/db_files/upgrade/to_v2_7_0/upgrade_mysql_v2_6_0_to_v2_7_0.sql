-- Convert schema 'KDDart_core_doc-260.sql' to 'KDDart_core_doc-270.sql':;

BEGIN;

SET foreign_key_checks=0;

CREATE TABLE cmgroup (
  CMGroupId integer(11) NOT NULL comment 'internal group id' auto_increment,
  CMGroupName VARCHAR(255) NOT NULL comment 'group name - has to be unique',
  TrialId integer(11) NOT NULL comment 'trial id measurements belong to - this is a constrain that grouping measurements between trials is not possible',
  OperatorId integer(11) NOT NULL comment 'user - owner of the group',
  CMGroupStatus VARCHAR(20) NULL comment 'status of the group',
  CMGroupDateTime datetime NOT NULL comment 'date and time of the group - possibly creation time or last update',
  CMGroupNote text NULL comment 'general comments for the group',
  UNIQUE INDEX xcmg_CMGroupName (CMGroupName),
  INDEX xcmg_TrialId (TrialId),
  INDEX xcmg_OperatorId (OperatorId),
  INDEX xcmg_CMGroupStatus (CMGroupStatus),
  INDEX xcmg_CMGroupDateTime (CMGroupDateTime),
  PRIMARY KEY (CMGroupId),
  CONSTRAINT cmgroup_fk FOREIGN KEY (TrialId) REFERENCES trial (TrialId) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT cmgroup_fk_1 FOREIGN KEY (OperatorId) REFERENCES systemuser (UserId) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB comment='Crossing measurements for some portions of the trials may be grouped to distinct them from the same measurements, which were done before, but need to be retained or to have two sets which can be compared. It can also be used as means to keep several versions of the same dataset.';

CREATE TABLE crossingmeasurement (
  CrossingId integer(11) NOT NULL comment 'crossing id' auto_increment,
  TraitId integer(11) NOT NULL comment 'id of the trait being measured',
  OperatorId integer(11) NOT NULL comment 'user performing the measurement',
  InstanceNumber TINYINT(4) NOT NULL comment 'next consecutive number of the measurement instance if all other values of primary key are the same',
  SampleTypeId integer(11) NOT NULL comment 'sample type id',
  CMGroupId integer(11) NOT NULL comment 'crossing measurement group the measurement if part of - if any',
  MeasureDateTime datetime NULL comment 'date / time of the measurement',
  TraitValue VARCHAR(255) NULL comment 'measurement value',
  StateReason VARCHAR(30) NULL comment 'optional value state e.g. reason for rejection',
  INDEX xcm_TraitId (TraitId),
  INDEX xcm_OperatorId (OperatorId),
  INDEX xcm_SampleTypeId (SampleTypeId),
  INDEX xcm_MeasureDateTime (MeasureDateTime),
  INDEX xcm_CMGroupId (CMGroupId),
  INDEX (CrossingId),
  PRIMARY KEY (CrossingId, TraitId, OperatorId, InstanceNumber, SampleTypeId, CMGroupId),
  CONSTRAINT crossingmeasurement_fk_1 FOREIGN KEY (TraitId) REFERENCES trait (TraitId) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT crossingmeasurement_fk_2 FOREIGN KEY (OperatorId) REFERENCES systemuser (UserId) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT crossingmeasurement_fk_3 FOREIGN KEY (SampleTypeId) REFERENCES generaltype (TypeId) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT crossingmeasurement_fk_4 FOREIGN KEY (CrossingId) REFERENCES crossing (CrossingId) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB comment='Measurement of the sample from crossing for a particular trait/variate, by the operator on certain date/time. Measurement can be done for sample type if it does not refer to the entire crossing.';

CREATE TABLE imgroup (
  IMGroupId integer(11) NOT NULL comment 'internal group id' auto_increment,
  IMGroupName VARCHAR(255) NOT NULL comment 'group name - has to be unique',
  OperatorId integer(11) NOT NULL comment 'user - owner of the group',
  IMGroupStatus VARCHAR(20) NULL comment 'status of the group',
  IMGroupDateTime datetime NOT NULL comment 'date and time of the group - possibly creation time or last update',
  IMGroupNote text NULL comment 'general comments for the group',
  UNIQUE INDEX ximg_IMGroupName (IMGroupName),
  INDEX ximg_OperatorId (OperatorId),
  INDEX ximg_IMGroupStatus (IMGroupStatus),
  INDEX ximg_IMGroupDateTime (IMGroupDateTime),
  PRIMARY KEY (IMGroupId),
  CONSTRAINT imgroup_fk FOREIGN KEY (OperatorId) REFERENCES systemuser (UserId) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB comment='Item measurements for some portions of the item data may be grouped to distinct them from the same measurements, which were done before, but need to be retained or to have two sets which can be compared. It can also be used as means to keep several versions of the same dataset.';

CREATE TABLE itemmeasurement (
  ItemId integer(11) NOT NULL comment 'item id',
  TraitId integer(11) NOT NULL comment 'id of the trait being measured',
  OperatorId integer(11) NOT NULL comment 'user performing the measurement',
  InstanceNumber integer(11) NOT NULL DEFAULT 1 comment 'next consecutive number of the measurement instance if all other values of primary key are the same',
  SampleTypeId integer(11) NOT NULL comment 'sample type id',
  IMGroupId integer(11) NOT NULL DEFAULT 0 comment 'sample measurement group the measurement if part of - if any',
  MeasureDateTime datetime NULL comment 'date / time of the measurement',
  TraitValue VARCHAR(255) NULL comment 'measurement value',
  StateReason VARCHAR(255) NULL comment 'optional value state e.g. reason for rejection',
  INDEX xim_TraitId (TraitId),
  INDEX xim_OperatorId (OperatorId),
  INDEX xim_SampleTypeId (SampleTypeId),
  INDEX xim_IMGroupId (IMGroupId),
  INDEX xim_MeasureDateTime (MeasureDateTime),
  INDEX (ItemId),
  PRIMARY KEY (ItemId, TraitId, OperatorId, InstanceNumber, SampleTypeId, IMGroupId),
  CONSTRAINT itemmeasurement_fk_1 FOREIGN KEY (ItemId) REFERENCES item (ItemId) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT itemmeasurement_fk_2 FOREIGN KEY (TraitId) REFERENCES trait (TraitId) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT itemmeasurement_fk_3 FOREIGN KEY (OperatorId) REFERENCES systemuser (UserId) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT itemmeasurement_fk_4 FOREIGN KEY (SampleTypeId) REFERENCES generaltype (TypeId) ON DELETE NO ACTION ON UPDATE NO ACTION,
) ENGINE=InnoDB comment='Measurement of the sample from item inventory for a particular trait/variate, by the operator on certain date/time. Measurement can be done for sample type if it does not refer to the entire inventory item.';

CREATE TABLE survey (
  SurveyId integer(11) NOT NULL comment 'Internal survey id' auto_increment,
  SurveyManagerId integer(11) NOT NULL comment 'Contact that is assigned as a survey manager',
  SurveyName VARCHAR(255) NOT NULL comment 'Survey name',
  SurveyStartTime datetime NOT NULL comment 'Survey start time',
  SurveyEndTime datetime NULL comment 'Survey end time',
  SurveyNote text NULL comment 'Survey notes and comments',
  SurveyTypeId integer(11) NULL comment 'Type of Survey',
  UNIQUE INDEX xs_SurveryName (SurveyName),
  INDEX xs_SurveryStartTime (SurveyStartTime),
  INDEX xs_SurveryEndTime (SurveyEndTime),
  INDEX xs_SurveyManagerId (SurveyManagerId),
  INDEX (SurveyTypeId),
  PRIMARY KEY (SurveyId),
  CONSTRAINT survey_fk FOREIGN KEY (SurveyManagerId) REFERENCES contact (ContactId) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT survey_fk_1 FOREIGN KEY (SurveyTypeId) REFERENCES generaltype (TypeId) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB comment='Survey entity represents field data collection expedition. System users may arbitrary select points of interest (trial units) to visit in arbitrary order. This entity is for planning physical data collection events as well as for calculating an effort in such events.';

CREATE TABLE surveyfactor (
  SurveyId integer(11) NOT NULL comment 'Survey Id',
  FactorId integer(11) NOT NULL comment 'Factor Id',
  FactorValue VARCHAR(254) NOT NULL comment 'value',
  INDEX FactorId (FactorId),
  INDEX (SurveyId),
  PRIMARY KEY (SurveyId, FactorId),
  CONSTRAINT surveyfactor_fk FOREIGN KEY (SurveyId) REFERENCES survey (SurveyId) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT surveyfactor_fk_1 FOREIGN KEY (FactorId) REFERENCES factor (FactorId) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB comment='Additional virtual columns for genotype descriptions. ';

CREATE TABLE surveytrait (
  SurveyTraitId integer(11) NOT NULL comment 'Internal survey trait id' auto_increment,
  SurveyId integer(11) NOT NULL comment 'Survey Id',
  TraitId integer(11) NOT NULL comment 'Trait Id',
  Compulsory TINYINT(4) NOT NULL DEFAULT 0 comment 'Flag if scoring the trait is compulsory - by default it is not',
  INDEX xst_SurveryId (SurveyId),
  INDEX xst_TraitId (TraitId),
  PRIMARY KEY (SurveyTraitId),
  CONSTRAINT surveytrait_fk FOREIGN KEY (SurveyId) REFERENCES survey (SurveyId) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT surveytrait_fk_1 FOREIGN KEY (TraitId) REFERENCES trait (TraitId) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB comment='Linking survey and traits - which traits will be scored during the survey. Can be a subset of traits for trials (experiments) involved, but can also be an arbitrary selection.';

CREATE TABLE surveytrialunit (
  SurveyTrialUnitId integer(11) NOT NULL comment 'internal survey trial unit id' auto_increment,
  SurveyId integer(11) NOT NULL comment 'survey id',
  TrialUnitId integer(11) NOT NULL comment 'trial unit',
  VisitTime datetime NOT NULL comment 'visit time',
  VisitOrder integer(11) NULL comment 'consecutive order number during the visit',
  CollectorId integer(11) NULL comment 'id of the person who collected data',
  INDEX xstu_SurveyId (SurveyId),
  INDEX xstu_TrialUnitId (TrialUnitId),
  INDEX xstu_VisitTime (VisitTime),
  INDEX xstu_VisitOrder (VisitOrder),
  INDEX xstu_CollectorId (CollectorId),
  PRIMARY KEY (SurveyTrialUnitId),
  CONSTRAINT surveytrialunit_fk FOREIGN KEY (SurveyId) REFERENCES survey (SurveyId) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT surveytrialunit_fk_1 FOREIGN KEY (TrialUnitId) REFERENCES trialunit (TrialUnitId) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT surveytrialunit_fk_2 FOREIGN KEY (CollectorId) REFERENCES contact (ContactId) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB comment='Linking survey with trial unit visited during the survey.';

CREATE TABLE taxonomy (
  TaxonomyId integer(11) NOT NULL comment 'taxonomy id - internal id of this database' auto_increment,
  ParentTaxonomyId integer(11) NULL comment 'parent taxonomy id - what is directly above in hierarchy',
  TaxonomyName VARCHAR(255) NOT NULL comment 'main name used',
  TaxonomyClass VARCHAR(255) NOT NULL comment 'class - species, genera, kingdom',
  TaxonomySource VARCHAR(255) NULL comment 'source of taxonomy data - e.g. NCBI, AviBase, World Flora Onlie',
  TaxonomyExtId VARCHAR(254) NULL comment 'id in the external source - e.g. tax_id from NCBI',
  TaxonomyURL VARCHAR(254) NULL comment 'api endpoint or permalink to fetch information',
  TaxonomyNote text NULL comment 'aliased name and extra information',
  INDEX xtax_ParentTaxonomyId (ParentTaxonomyId),
  INDEX xtax_TaxonomyName (TaxonomyName),
  INDEX xtax_TaxonomyClass (TaxonomyClass),
  PRIMARY KEY (TaxonomyId),
  CONSTRAINT taxonomy_fk FOREIGN KEY (ParentTaxonomyId) REFERENCES taxonomy (TaxonomyId) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB comment='Taxonomy hierarchy. Store simple internal taxonomy information from species up and/or link to external taxonomy resources.';

CREATE TABLE trialunitfactor (
  TrialUnitId integer(11) NOT NULL comment 'trial unit id',
  FactorId integer(11) NOT NULL comment 'factor id',
  FactorValue VARCHAR(255) NOT NULL comment 'value',
  INDEX FactorId (FactorId),
  INDEX (TrialUnitId),
  PRIMARY KEY (TrialUnitId, FactorId),
  CONSTRAINT trialunitfactor_fk FOREIGN KEY (TrialUnitId) REFERENCES trialunit (TrialUnitId) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT trialunitfactor_fk_1 FOREIGN KEY (FactorId) REFERENCES factor (FactorId) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB comment='Additional virtual columns for trial units.';

CREATE TABLE trialunittreatment (
  TrialUnitTreatmentId integer(11) NOT NULL comment 'internal id' auto_increment,
  TreatmentId integer(11) NOT NULL comment 'treatment id - which treatment was used inside the unit',
  TrialUnitId integer(11) NOT NULL comment 'trial unit id - which trial unit is affected by a treatment',
  TreatmentDateTime datetime NULL comment 'date time of the treatment',
  TrialUnitTreatmentNote text NULL comment 'note for treatment inside this trial unit',
  INDEX xttr_TreatmentId (TreatmentId),
  INDEX xttr_TrialUnitId (TrialUnitId),
  PRIMARY KEY (TrialUnitTreatmentId),
  CONSTRAINT trialunittreatment_fk FOREIGN KEY (TreatmentId) REFERENCES treatment (TreatmentId) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT trialunittreatment_fk_1 FOREIGN KEY (TrialUnitId) REFERENCES trialunit (TrialUnitId) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB comment='List of treatments for a trial unit.';

INSERT INTO trialunittreatment (TrialUnitId, TreatmentId) SELECT TrialUnitId, TreatmentId from trialunit WHERE TreatmentId IS NOT NULL;

SET foreign_key_checks=1;

ALTER TABLE generaltype ADD COLUMN TypeMetaData text NULL comment 'metadata of type to better describe usage of type',
                        CHANGE COLUMN Class Class SET('site', 'item', 'container', 'deviceregister', 'trial', 'trialevent', 'sample', 'specimengroup', 'specimengroupstatus', 'state', 'parent', 'itemparent', 'genotypespecimen', 'markerdataset', 'workflow', 'project', 'itemlog', 'plate', 'genmap', 'multimedia', 'tissue', 'genotypealias', 'genparent', 'genotypealiasstatus', 'traitgroup', 'unittype', 'trialgroup', 'breedingmethod', 'traitdatatype', 'season', 'trialunit', 'survey', 'extractdatatype') NOT NULL comment 'class of type - possible values (site, item, container, deviceregister, trial, operation, sample, specimengroup, specimengroupstatus, state, parent, itemparent, genotypespecimen, markerdataset, workflow, project, itemlog, plate, genmap, multimedia, tissue, genotypealias, genparent, genotypealiasstatus, traitgroup, unittype, trialgroup, breedingmethod, traitdatatype, season, trialunit, survey, extractdatatype)';

ALTER TABLE genotype ADD COLUMN TaxonomyId integer(11) NULL comment 'taxonomy id',
                     ADD CONSTRAINT genotype_fk_1 FOREIGN KEY (TaxonomyId) REFERENCES taxonomy (TaxonomyId) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE multimedia CHANGE COLUMN SystemTable SystemTable SET('genotype', 'specimen', 'project', 'site', 'trial', 'trialunit', 'item', 'extract', 'survey') NOT NULL comment 'name of the supported system table, for which file is attached';

ALTER TABLE pedigree ADD COLUMN ParentTrialUnitSpecimenId integer(11) NULL comment 'id of the trial unit specimen',
                     ADD INDEX xpe_ParentTrialUnitSpecimenId (ParentTrialUnitSpecimenId),
                     ADD CONSTRAINT pedigree_fk_3 FOREIGN KEY (ParentTrialUnitSpecimenId) REFERENCES trialunitspecimen (TrialUnitSpecimenId) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE samplemeasurement ADD COLUMN SurveyId integer(11) NULL comment 'optional value of survey id - if data point comes from a particular survey',
                              ADD INDEX xsm_SurveyId (SurveyId),
                              ADD CONSTRAINT samplemeasurement_fk_4 FOREIGN KEY (SurveyId) REFERENCES survey (SurveyId) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE specimen ADD COLUMN SourceCrossingId integer(11) NULL comment 'id of the crossing - optional this specimen is a product of this particular cross',
                     ADD INDEX xs_SourceCrossingId (SourceCrossingId),
                     ADD CONSTRAINT specimen_fk_1 FOREIGN KEY (SourceCrossingId) REFERENCES crossing (CrossingId) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE systemuser ADD COLUMN UserVerification VARCHAR(255) NULL comment 'token for password reset',
                       ADD COLUMN UserVerificationDT datetime NULL comment 'password reset date and time';

ALTER TABLE trialunit DROP FOREIGN KEY trialunit_ibfk_1,
                      DROP FOREIGN KEY trialunit_ibfk_2,
                      DROP FOREIGN KEY trialunit_ibfk_3;

ALTER TABLE trialunit DROP INDEX xtu_TreatmentId,
                      DROP COLUMN TreatmentId,
                      ADD COLUMN TrialUnitTypeId integer(11) NULL comment 'type of trial unit',
                      ADD CONSTRAINT trialunit_fk FOREIGN KEY (TrialId) REFERENCES trial (TrialId) ON DELETE NO ACTION ON UPDATE NO ACTION,
                      ADD CONSTRAINT trialunit_fk_1 FOREIGN KEY (SourceTrialUnitId) REFERENCES trialunit (TrialUnitId) ON DELETE NO ACTION ON UPDATE NO ACTION,
                      ADD CONSTRAINT trialunit_fk_2 FOREIGN KEY (TrialUnitTypeId) REFERENCES generaltype (TypeId) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE trialunitspecimen ADD COLUMN TUSBarcode VARCHAR(254) NULL comment 'barcode for trial unit specimen - if exists must be unique - labelling individual specimen in trial unit',
                              ADD UNIQUE INDEX xtus_TUSBarcode (TUSBarcode);

ALTER TABLE workflowdef ADD UNIQUE INDEX wfd_workfloworder (WorkflowId, StepOrder);

ALTER TABLE factor MODIFY FactorName varchar(255);


COMMIT;

