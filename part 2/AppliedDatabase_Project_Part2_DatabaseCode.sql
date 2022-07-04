-- Create Database and Tables

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
  `current_price` DOUBLE NOT NULL DEFAULT 0.0,
  `average_price` DOUBLE NOT NULL DEFAULT 0.0,
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
  `car_id` INT NOT NULL UNIQUE,
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


-- Insert into tables

-- -----------------------------------------------------
-- PART II - Insert data and populate all tables
-- -----------------------------------------------------
-- Use the MySQL Workbench Table Data Import Wizard to import the Kaggle data CSV file 
-- https://www.kaggle.com/datasets/rinichristy/2022-fuel-consumption-ratings/
-- and load it into a table named raw_data
-- -----------------------------------------------------
-- 1. Right click any existing table in the object browser and select 'Table Data Import Wizard'
-- 2. Select the CSV file downloaded from Kaggle link and click Next
-- 3. Select 'Create new table' and provide the name as raw_data (the schema should be `vehicle_rating`)
-- 4. Leave default values for column datatypes and click next
-- 5. Click Next to execute
-- 6. Wait for the import to finish and click next to continue
-- 7. 946 records should be imported
-- -----------------------------------------------------
ALTER TABLE vehicle_rating.raw_data
  ADD COLUMN car_id INT AUTO_INCREMENT PRIMARY KEY;

-- SELECT * FROM vehicle_rating.raw_data;  -- Verify that car_id column has been introduced as PK with auto incremented values


-- -----------------------------------------------------
-- Taking backup of DB settings to restore after database creation
-- -----------------------------------------------------
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';


-- -----------------------------------------------------
-- Populating the fuel table
-- -----------------------------------------------------
INSERT INTO fuel (fuel_id)
  SELECT DISTINCT `Fuel Type` 
  FROM vehicle_rating.raw_data;


-- -----------------------------------------------------
-- Populating the car table
-- -----------------------------------------------------
INSERT INTO car (car_id, model_year, make, model, vehicle_class, engine_size_l, 
  cylinders, transmission, fuel_type)
  SELECT car_id,
    `Model Year`,
	`Make`,
	`Model`,
	`Vehicle Class`,
	`Engine Size(L)`,
	`Cylinders`,
	`Transmission`,
	`Fuel Type`
  FROM vehicle_rating.raw_data;


-- -----------------------------------------------------
-- Populating the fuel_consumption table
-- -----------------------------------------------------
INSERT INTO fuel_consumption (source, car_id, fuel_consumption_city_lp100km, fuel_consumption_hwy_lp100km, fuel_consumption_combo_lp100km)
  SELECT 'LAB' AS source,
    car_id,
	`Fuel Consumption (City (L/100 km)`,
	`Fuel Consumption(Hwy (L/100 km))`,
	`Fuel Consumption(Comb (L/100 km))`
  FROM vehicle_rating.raw_data;


-- -----------------------------------------------------
-- Populating the emission table
-- -----------------------------------------------------
INSERT INTO emission (car_id, co2_emissions_gpkm, co2_rating, smog_rating)
  SELECT car_id,
	`CO2 Emissions(g/km)`,
	`CO2 Rating`,
	`Smog Rating`
  FROM vehicle_rating.raw_data;


-- -----------------------------------------------------
-- Populating the emission table
-- -----------------------------------------------------
DROP TABLE IF EXISTS vehicle_rating.raw_data;


-- -----------------------------------------------------
-- Restoring all DB settings
-- -----------------------------------------------------
SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


-- Queries

-- Join test (should return 946 rows after initial insert)
SELECT count(*)
FROM car as c
INNER JOIN fuel_consumption as fc 
	ON c.car_id = fc.car_id 
INNER JOIN emission as e 
	ON c.car_id = e.car_id
;


-- Fuel consumption, CO2 emission and Smog ratings for filtered cars (as identified by user input)
SET @model_year = 2022;
SET @make = "Nissan";
SET @model = "%Rogue%";

SELECT c.model_year AS 'Model Year', 
  c.make AS 'Make', 
  c.model AS 'Model', 
  fc.fuel_consumption_combo_lp100km AS 'Fuel Consumption Combo (L/100km)',
  fc.fuel_consumption_combo_mpg AS 'Fuel Consumption Combo (MPG)',
  e.co2_emissions_gpkm AS 'CO2 Emissions (g/km)',
  e.co2_rating AS 'CO2 Rating',
  e.smog_rating AS 'Smog Rating'
FROM car AS c
INNER JOIN fuel_consumption AS fc 
	ON c.car_id = fc.car_id 
INNER JOIN emission AS e 
	ON c.car_id = e.car_id
WHERE c.car_id IN (
	SELECT car_id 
    FROM car
    WHERE model_year = @model_year
      AND make = @make
      AND model LIKE @model
	)
;


-- Find mpg fuel combo consumption, co2 and smog rating for all Fords
SELECT 
	  c.make
	, SUBSTRING_INDEX(c.model, ' ', 1) as model
	, c.model as model_detail
    , fc.fuel_consumption_combo_mpg
    , fc.fuel_consumption_combo_lp100km
    , e.co2_rating
    , e.smog_rating
FROM car as c
INNER JOIN fuel_consumption as fc 
	ON c.car_id = fc.car_id 
INNER JOIN emission as e 
	ON c.car_id = e.car_id
WHERE make like '%Ford%'
;


-- Average fuel consumption (MPG) for general models of all makes
SELECT 
	  c.make
	, SUBSTRING_INDEX(c.model, ' ', 1) as model
    , ROUND(AVG(fc.fuel_consumption_combo_mpg),0) as average_combo_mpg
    , ROUND(AVG(fc.fuel_consumption_hwy_mpg),0) as average_hwy_mpg
    , ROUND(AVG(fc.fuel_consumption_city_mpg),0) as average_city_mpg
    , ROUND(AVG(e.co2_rating)) AS average_co2_rating
    , ROUND(AVG(e.smog_rating)) AS average_smog_rating
FROM car as c
INNER JOIN fuel_consumption as fc 
	ON c.car_id = fc.car_id 
INNER JOIN emission as e 
	ON c.car_id = e.car_id
GROUP BY 1, 2
ORDER BY 1, 2
;


-- Average fuel consumption (L/100km) for general models of all makes
SELECT 
	  c.make
	, SUBSTRING_INDEX(c.model, ' ', 1) as model
    , ROUND(AVG(fc.fuel_consumption_combo_lp100km),0) as average_combo_lp100km
    , ROUND(AVG(fc.fuel_consumption_hwy_lp100km),0) as average_hwy_lp100km
    , ROUND(AVG(fc.fuel_consumption_city_lp100km),0) as average_city_lp100km
    , ROUND(AVG(e.co2_rating)) AS average_co2_rating
    , ROUND(AVG(e.smog_rating)) AS average_smog_rating
FROM car as c
INNER JOIN fuel_consumption as fc 
	ON c.car_id = fc.car_id 
INNER JOIN emission as e 
	ON c.car_id = e.car_id
GROUP BY 1, 2
ORDER BY 1, 2
;


-- Find all make/models with less than equals 25 mpg or co2 rating greater than 8 or smog rating greater than 8 
SELECT 
	  c.make
	, SUBSTRING_INDEX(c.model, ' ', 1) as model
	, c.model as model_detail
    , fc.fuel_consumption_combo_mpg 
    , fc.fuel_consumption_combo_lp100km
    , e.co2_rating
    , e.smog_rating
FROM car as c
INNER JOIN fuel_consumption as fc 
	ON c.car_id = fc.car_id 
INNER JOIN emission as e 
	ON c.car_id = e.car_id
WHERE (fc.fuel_consumption_combo_mpg <= 25 
	OR e.co2_rating >= 8
    OR e.smog_rating >= 8)
;


-- Return top 5 makes for highest average fuel mpg, consumer should be able to select how many to show
SELECT 
	  c.make
	, ROUND(AVG(fc.fuel_consumption_combo_mpg),0) as avg_mpg
    , ROUND(AVG(fc.fuel_consumption_hwy_mpg),0) as average_hwy_mpg
    , ROUND(AVG(fc.fuel_consumption_city_mpg),0) as average_city_mpg
FROM car as c
INNER JOIN fuel_consumption as fc 
	ON c.car_id = fc.car_id 
GROUP BY 1
ORDER BY avg_mpg DESC
LIMIT 5
;


-- Return top 5 makes for highest average fuel (L/100km), consumer should be able to select how many to show
SELECT 
	  c.make
	, ROUND(AVG(fc.fuel_consumption_combo_lp100km),0) as avg_combo_lp100km
    , ROUND(AVG(fc.fuel_consumption_hwy_lp100km),0) as average_hwy_lp100km
    , ROUND(AVG(fc.fuel_consumption_city_lp100km),0) as average_city_lp100km
FROM car as c
INNER JOIN fuel_consumption as fc 
	ON c.car_id = fc.car_id 
GROUP BY 1
ORDER BY avg_combo_lp100km ASC  -- less is better for L/100km
LIMIT 5
;

