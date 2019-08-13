CREATE DATABASE IF NOT EXISTS `ISC_`;

CREATE USER `empUser`@`localhost` IDENTIFIED BY `my-secret-pw`;
GRANT ALL ON `TEST_EMP`.* TO `empUser`@`localhost`;
COMMIT;

use `TEST_EMP`;

-- -----------------------------------------------------
-- Table `InstitutionType`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `InstitutionType`
(
  `id` INT (11) NOT NULL AUTO_INCREMENT ,
  `createdOn` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
  `modifiedOn` TIMESTAMP NULL DEFAULT NULL ,
  `active` TINYINT (1) NOT NULL DEFAULT '1',
  `name` VARCHAR (50) NOT NULL ,
  `description` MEDIUMTEXT NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  UNIQUE INDEX `UNIQUE_institutiontype` (`name` ASC) )
ENGINE = InnoDB;

INSERT INTO `InstitutionType` (`name`) VALUES
    ("University"),
    ("College"),
    ("High school"),
    ("Middle school"),
    ("Elementary school"),
    ("Pre School");