ALTER TABLE `itemmeasurement`
DROP CONSTRAINT `itemmeasurement_ibfk_1`; 

ALTER TABLE `itemmeasurement`
DROP CONSTRAINT `itemmeasurement_ibfk_2`; 

ALTER TABLE `itemmeasurement`
DROP CONSTRAINT `itemmeasurement_ibfk_3`; 

ALTER TABLE `itemmeasurement`
DROP CONSTRAINT `itemmeasurement_ibfk_4`; 

ALTER TABLE `itemmeasurement`
DROP CONSTRAINT `itemmeasurement_ibfk_5`; 

ALTER TABLE `itemmeasurement` ADD FOREIGN KEY (`ItemId`)
  REFERENCES `item` (`ItemId`) 
  ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE `itemmeasurement` ADD FOREIGN KEY (`TraitId`)
  REFERENCES `trait` (`TraitId`) 
  ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE `itemmeasurement` ADD FOREIGN KEY (`OperatorId`)
  REFERENCES `systemuser` (`UserId`) 
  ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE `itemmeasurement` ADD FOREIGN KEY (`SampleTypeId`)
  REFERENCES `generaltype` (`TypeId`) 
  ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE `crossingmeasurement`
DROP CONSTRAINT `crossingmeasurement_ibfk_1`; 

ALTER TABLE `crossingmeasurement`
DROP CONSTRAINT `crossingmeasurement_ibfk_2`; 

ALTER TABLE `crossingmeasurement`
DROP CONSTRAINT `crossingmeasurement_ibfk_3`; 

ALTER TABLE `crossingmeasurement`
DROP CONSTRAINT `crossingmeasurement_ibfk_4`; 

ALTER TABLE `crossingmeasurement`
DROP CONSTRAINT `crossingmeasurement_ibfk_5`; 

ALTER TABLE `crossingmeasurement` ADD FOREIGN KEY (`TraitId`)
  REFERENCES `trait` (`TraitId`) 
  ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE `crossingmeasurement` ADD FOREIGN KEY (`OperatorId`)
  REFERENCES `systemuser` (`UserId`) 
  ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE `crossingmeasurement` ADD FOREIGN KEY (`SampleTypeId`)
  REFERENCES `generaltype` (`TypeId`) 
  ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE `crossingmeasurement` ADD FOREIGN KEY (`CrossingId`)
  REFERENCES `crossing` (`CrossingId`) 
  ON DELETE NO ACTION ON UPDATE NO ACTION;