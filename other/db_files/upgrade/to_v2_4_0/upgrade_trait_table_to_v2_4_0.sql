DROP PROCEDURE IF EXISTS upgrade_trait_table;

DELIMITER //

CREATE PROCEDURE upgrade_trait_table()
BEGIN

DECLARE max_type_id, no_more_trait_dtype, is_t_dtype_exist, type_id INT default 0;

DECLARE t_dtype VARCHAR(255);

DECLARE cur_trait_dtype CURSOR FOR SELECT DISTINCT TraitDataType FROM trait;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET no_more_trait_dtype = 1;

SELECT MAX(TypeId) INTO max_type_id FROM generaltype;

SET max_type_id = max_type_id + 1;

SET foreign_key_checks=0;

CREATE TABLE trait_tmp LIKE trait;
INSERT trait_tmp SELECT * FROM trait;

OPEN cur_trait_dtype;

FETCH cur_trait_dtype INTO t_dtype;

REPEAT

SELECT COUNT(TypeId) INTO is_t_dtype_exist FROM generaltype WHERE TypeName=t_dtype AND Class='traitdatatype';

IF is_t_dtype_exist = 0 THEN

INSERT INTO generaltype(TypeId,TypeName,Class) VALUES(max_type_id,t_dtype,'traitdatatype');

SET type_id = max_type_id;

SET max_type_id = max_type_id + 1;

ELSE

SELECT TypeId INTO type_id FROM generaltype WHERE TypeName=t_dtype AND Class='traitdatatype';

END IF;

UPDATE trait_tmp SET TraitDataType=type_id WHERE TraitDataType=t_dtype;

FETCH cur_trait_dtype INTO t_dtype;

UNTIL no_more_trait_dtype = 1
END REPEAT;

CLOSE cur_trait_dtype;

ALTER TABLE trait_tmp ADD COLUMN TraitLevel set('trialunit', 'subtrialunit', 'notetrialunit') NOT NULL DEFAULT 'trialunit' comment 'level at which trait is being used (scored), additional global distinction',
                  CHANGE COLUMN TraitDataType TraitDataType integer(11) NOT NULL comment 'data type as per general type Class traitdatatype (e.g.  DATE, TEXT, CATEGORICAL, ELAPSED_DAYS, INTEGER, DECIMAL) possibly others',
                  ADD INDEX xt_TraitDataType (TraitDataType),
                  ADD INDEX xt_TraitLevel (TraitLevel),
                  ENGINE=InnoDB DEFAULT CHARACTER SET utf8 comment='Defines the measurement values for the genotype and trial. The specification of a validation rule is optional, however the format must adhere to either a regular or boolean expression. For example a validation rule could be: - Regular Expression TraitValRule=([A-Z]*) - Boolean Expression TraitValRule=(xg1 and xk50) ';

DROP TABLE IF EXISTS trait;

CREATE TABLE trait LIKE trait_tmp;
INSERT trait SELECT * FROM trait_tmp;

DROP TABLE IF EXISTS trait_tmp;

SET foreign_key_checks=1;

END//

DELIMITER ;

CALL upgrade_trait_table();
