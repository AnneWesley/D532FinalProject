CREATE TABLE IF NOT EXISTS fuel (
  `fuel_id` CHAR(1) NOT NULL,
  `scientific_name` VARCHAR(45) NULL,
  `current_price` DOUBLE NOT NULL DEFAULT 0.0,
  `average_price` DOUBLE NOT NULL DEFAULT 0.0,
  PRIMARY KEY (`fuel_id`));


-- -----------------------------------------------------
-- Table `vehicle_rating`.`car`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS car (
  `car_id` INT PRIMARY KEY,
  `model_year` INT(4) NOT NULL,
  `make` VARCHAR(50) NOT NULL,
  `model` VARCHAR(100) NOT NULL,
  `vehicle_class` VARCHAR(50) NOT NULL,
  `engine_size_l` DOUBLE NOT NULL,
  `cylinders` INT(2) NOT NULL,
  `transmission` VARCHAR(50) NOT NULL,
  `fuel_type` CHAR(1) NOT NULL,
   FOREIGN KEY (`fuel_type`) REFERENCES `fuel` (`fuel_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table `vehicle_rating`.`fuel_consumption`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS fuel_consumption (
  `fuel_consumption_id` INT PRIMARY KEY,
  `date_reported` DATETIME NULL,
  `source` VARCHAR(4) NOT NULL,
  `car_id` INT NOT NULL,
  `fuel_consumption_city_lp100km` DOUBLE NOT NULL,
  `fuel_consumption_hwy_lp100km` DOUBLE NOT NULL,
  `fuel_consumption_combo_lp100km` DOUBLE NOT NULL,
  `fuel_consumption_city_mpg` DOUBLE GENERATED ALWAYS AS (235.215 / fuel_consumption_city_lp100km) VIRTUAL,
  `fuel_consumption_hwy_mpg` DOUBLE GENERATED ALWAYS AS (235.215 / fuel_consumption_hwy_lp100km) VIRTUAL,
  `fuel_consumption_combo_mpg` DOUBLE GENERATED ALWAYS AS (235.215 / fuel_consumption_combo_lp100km) VIRTUAL,
   FOREIGN KEY (`car_id`) REFERENCES `car` (`car_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table `vehicle_rating`.`emission`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS emission (
  `emission_id` INT PRIMARY KEY,
  `car_id` INT NOT NULL UNIQUE,
  `co2_emissions_gpkm` INT(5) NOT NULL,
  `co2_rating` INT(2) NOT NULL,
  `smog_rating` INT(2) NOT NULL,
   FOREIGN KEY (`car_id`) references `car` (`car_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
