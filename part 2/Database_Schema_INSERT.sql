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
