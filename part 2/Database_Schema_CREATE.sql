-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`Fuel`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Fuel` (
  `Fuel_ID` CHAR(1) NOT NULL COMMENT 'Setting it to Char(1) means we cannot have more than 26 types of fuel in the system. It is future-proof for cars.',
  `Scientific_Name` VARCHAR(45) NULL,
  `Current_Price` DECIMAL NOT NULL,
  `Average_Price` DECIMAL NOT NULL,
  PRIMARY KEY (`Fuel_ID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Car`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Car` (
  `Car_ID` INT NOT NULL,
  `Model_Year` INT NOT NULL,
  `Make` VARCHAR(45) NOT NULL,
  `Model` VARCHAR(45) NOT NULL,
  `Vehicle_Class` VARCHAR(45) NOT NULL,
  `Engine_Size_L` DECIMAL NOT NULL,
  `Cylinders` SMALLINT(2) NOT NULL,
  `Transmission` VARCHAR(45) NOT NULL,
  `Fuel_Type` CHAR(1) NOT NULL,
  PRIMARY KEY (`Car_ID`),
  INDEX `FK_Fuel_idx` (`Fuel_Type` ASC) VISIBLE,
  CONSTRAINT `FK_Fuel`
    FOREIGN KEY (`Fuel_Type`)
    REFERENCES `mydb`.`Fuel` (`Fuel_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Fuel_Consumption`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Fuel_Consumption` (
  `Fuel_Consumption_ID` INT NOT NULL AUTO_INCREMENT,
  `Date_Reported` DATETIME NOT NULL,
  `Source` BINARY(4) NOT NULL COMMENT 'Source can be either LAB or USER',
  `Car_ID` INT NOT NULL,
  `Fuel_Consumption_City_Lp100km` FLOAT NOT NULL,
  `Fuel_Consumption_Hwy_Lp100km` FLOAT NOT NULL,
  `Fuel_Consumption_Combo_Lp100km` FLOAT NOT NULL,
  `Fuel_Consumption_Combo_MPG` FLOAT GENERATED ALWAYS AS () VIRTUAL COMMENT 'Value for this column is derived from column Fuel_Consumption_Combo_Lp100km',
  PRIMARY KEY (`Fuel_Consumption_ID`),
  INDEX `FK_Car_ID_idx` (`Car_ID` ASC) VISIBLE,
  CONSTRAINT `FK_Car_Fuel`
    FOREIGN KEY (`Car_ID`)
    REFERENCES `mydb`.`Car` (`Car_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Emission`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Emission` (
  `Emission_ID` INT NOT NULL,
  `Car_ID` INT NOT NULL,
  `CO2_Emissions_gpkm` INT NOT NULL,
  `CO2_Rating` SMALLINT(2) NOT NULL,
  `Smog_Rating` SMALLINT(2) NOT NULL,
  PRIMARY KEY (`Emission_ID`),
  INDEX `FK_Car_Emission_idx` (`Car_ID` ASC) VISIBLE,
  CONSTRAINT `FK_Car_Emission`
    FOREIGN KEY (`Car_ID`)
    REFERENCES `mydb`.`Car` (`Car_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
