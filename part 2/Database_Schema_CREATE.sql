-- MySQL Workbench Forward Engineering

-- -----------------------------------------------------
-- Taking backup of DB settings to restore after database creation
-- -----------------------------------------------------
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- PART I - Create schema and all tables
-- -----------------------------------------------------
-- Create Schema vehicle_rating
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `vehicle_rating` DEFAULT CHARACTER SET utf8 ;
USE `vehicle_rating` ;  -- Ensure 'vehicle_rating` is now the default schema


-- -----------------------------------------------------
-- Table `vehicle_rating`.`fuel`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `vehicle_rating`.`fuel` (
  `fuel_id` CHAR(1) NOT NULL COMMENT 'Setting it to Char(1) means we cannot have more than 26 types of fuel in the system. It is future-proof for cars.',
  `scientific_name` VARCHAR(45) NULL,
  `current_price` DECIMAL NOT NULL DEFAULT 0.0,
  `average_price` DECIMAL NOT NULL DEFAULT 0.0,
  PRIMARY KEY (`fuel_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `vehicle_rating`.`car`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `vehicle_rating`.`car` (
  `car_id` INT NOT NULL AUTO_INCREMENT,
  `model_year` INT(4) NOT NULL,
  `make` VARCHAR(50) NOT NULL,
  `model` VARCHAR(100) NOT NULL,
  `vehicle_class` VARCHAR(50) NOT NULL,
  `engine_size_l` DOUBLE NOT NULL,
  `cylinders` INT(2) NOT NULL,
  `transmission` VARCHAR(50) NOT NULL,
  `fuel_type` CHAR(1) NOT NULL,
  PRIMARY KEY (`car_id`),
  INDEX `FK_Fuel_idx` (`fuel_type` ASC),
  CONSTRAINT `FK_Fuel`
    FOREIGN KEY (`fuel_type`)
    REFERENCES `vehicle_rating`.`fuel` (`fuel_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `vehicle_rating`.`fuel_consumption`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `vehicle_rating`.`fuel_consumption` (
  `fuel_consumption_id` INT NOT NULL AUTO_INCREMENT,
  `date_reported` DATETIME NULL,
  `source` VARCHAR(4) NOT NULL COMMENT 'Source can be either LAB or USER' CHECK(source IN('LAB','USER')),
  `car_id` INT NOT NULL,
  `fuel_consumption_city_lp100km` DOUBLE NOT NULL,
  `fuel_consumption_hwy_lp100km` DOUBLE NOT NULL,
  `fuel_consumption_combo_lp100km` DOUBLE NOT NULL,
  `fuel_consumption_city_mpg` DOUBLE GENERATED ALWAYS AS (235.215 / fuel_consumption_city_lp100km) VIRTUAL COMMENT 'Value derived from column fuel_consumption_city_lp100km',
  `fuel_consumption_hwy_mpg` DOUBLE GENERATED ALWAYS AS (235.215 / fuel_consumption_hwy_lp100km) VIRTUAL COMMENT 'Value derived from column fuel_consumption_hwy_lp100km',
  `fuel_consumption_combo_mpg` DOUBLE GENERATED ALWAYS AS (235.215 / fuel_consumption_combo_lp100km) VIRTUAL COMMENT 'Value derived from column fuel_consumption_combo_lp100km',
  PRIMARY KEY (`fuel_consumption_id`),
  INDEX `FK_Car_ID_idx` (`car_id` ASC),
  CONSTRAINT `FK_Car_Fuel`
    FOREIGN KEY (`car_id`)
    REFERENCES `vehicle_rating`.`car` (`car_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `vehicle_rating`.`emission`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `vehicle_rating`.`emission` (
  `emission_id` INT NOT NULL AUTO_INCREMENT,
  `car_id` INT NOT NULL,
  `co2_emissions_gpkm` INT(5) NOT NULL,
  `co2_rating` INT(2) NOT NULL,
  `smog_rating` INT(2) NOT NULL,
  PRIMARY KEY (`emission_id`),
  INDEX `FK_Car_Emission_idx` (`car_id` ASC),
  CONSTRAINT `FK_Car_Emission`
    FOREIGN KEY (`car_id`)
    REFERENCES `vehicle_rating`.`car` (`car_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Restoring all DB settings
-- -----------------------------------------------------
SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
