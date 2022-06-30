-- create database

CREATE DATABASE fuel_consumption_data ;

-- set fuel_consumption_data as default schema

-- use table data import wizard to import fuel consumption dataset from Kaggle

-- after importing, test all_data table

SELECT * FROM all_data LIMIT 10 ;

-- add a primary key that will be used for later tables
ALTER TABLE all_data
ADD COLUMN car_id INT AUTO_INCREMENT NOT NULL PRIMARY KEY;

SELECT car_id FROM all_data limit 10; 

-- create fuel table
-- may remove this
-- CREATE TABLE IF NOT EXISTS fuel (
-- 	fuel_id CHAR(1) NOT NULL PRIMARY KEY,
-- -- using char(1) to prevent extraneous fuel types from being entered
-- 	scientific_name VARCHAR(45) NULL,
-- -- currently null
-- 	current_price DECIMAL NOT NULL,
--     average_price DECIMAL NOT NULL
-- ) ;

-- INSERT INTO fuel (current_price, average_price)

-- create car table
CREATE TABLE IF NOT EXISTS car (
	car_id INT NOT NULL,
    model_year INT NOT NULL, 
    make VARCHAR(45) NOT NULL,
    model VARCHAR(256) NOT NULL,
    vehicle_class VARCHAR(45) NOT NULL,
    engine_size_l DOUBLE NOT NULL,
    cylinders SMALLINT(2) NOT NULL,
    transmission VARCHAR(45) NOT NULL,
    fuel_type CHAR(1)
);

INSERT INTO car (car_id, model_year, make, model, vehicle_class, engine_size_l, cylinders, transmission, fuel_type)
SELECT 
	  car_id 
    , `Model Year`
	, Make
    , Model
    , `Vehicle Class`
    , `Engine Size(L)`
    , Cylinders
    , Transmission
    , `Fuel Type`
FROM all_data
;

ALTER TABLE car
ADD PRIMARY KEY (car_id) ; 

SELECT * FROM car LIMIT 10 ;

-- create fuel_consumption table
CREATE TABLE IF NOT EXISTS fuel_consumption (
	fuel_consumption_id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    date_reported DATETIME, -- for use in update statements
    source VARCHAR(4) NOT NULL CHECK(source IN('LAB','USER')), -- source should be LAB or USER, for use in update statements
    car_id INT NOT NULL,
    fuel_consumption_city_lp100km FLOAT NOT NULL,
    fuel_consumption_hwy_lp100km FLOAT NOT NULL,
    fuel_consumption_combo_lp100km FLOAT NOT NULL,
    fuel_consumption_city_mpg FLOAT GENERATED ALWAYS AS ((235.215*1.0) / fuel_consumption_city_lp100km),
	fuel_consumption_hwy_mpg FLOAT GENERATED ALWAYS AS ((235.215*1.0) / fuel_consumption_hwy_lp100km),
    fuel_consumption_combo_mpg FLOAT GENERATED ALWAYS AS ((235.215*1.0) / fuel_consumption_combo_lp100km)
);

INSERT INTO fuel_consumption (car_id, source, fuel_consumption_city_lp100km, fuel_consumption_hwy_lp100km, fuel_consumption_combo_lp100km)
SELECT 
	  car_id
	, 'lab' AS source
    , `Fuel Consumption (City (L/100 km)`
	, `Fuel Consumption(Hwy (L/100 km))`
    , `Fuel Consumption(Comb (L/100 km))`
FROM all_data 
;

SELECT * FROM fuel_consumption LIMIT 10 ;

-- create emission table
CREATE TABLE IF NOT EXISTS emission (
	emission_id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    car_id INT NOT NULL,
    co2_emissions_gpkm INT NOT NULL,
    co2_rating SMALLINT(2) NOT NULL,
    smog_rating SMALLINT(2) NOT NULL,
    CONSTRAINT fk_car FOREIGN KEY (car_id) REFERENCES car (car_id)
);

INSERT INTO emission (car_id, co2_emissions_gpkm, co2_rating, smog_rating)
SELECT 
	  car_id
	, `CO2 Emissions(g/km)`
    , `CO2 Rating`
    , `Smog Rating`
FROM all_data
;

-- drop all_data table
DROP TABLE IF EXISTS all_data ;

-- queries for analysis 

SELECT count(*)
FROM car as c
INNER JOIN fuel_consumption as fc 
	ON c.car_id = fc.car_id 
INNER JOIN emission as e 
	ON c.car_id = e.car_id
;

-- find mpg fuel combo consumption, co2 and smog rating for Fords
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

-- average mpg fuel consumption for general models of all makes
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

-- same for km
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

-- find all make/models with greater than 30 mpg or co2 rating greater than 8 or smog rating greater than 8 
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
WHERE (fc.fuel_consumption_combo_mpg >= 30 
	OR e.co2_rating >= 8
    OR e.smog_rating >= 8)
;

-- return top 5 makes for highest average fuel mpg, consumer should be able to select how many to show
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

-- same for km
SELECT 
	  c.make
	, ROUND(AVG(fc.fuel_consumption_combo_lp100km),0) as avg_combo_lp100km
    , ROUND(AVG(fc.fuel_consumption_hwy_lp100km),0) as average_hwy_lp100km
    , ROUND(AVG(fc.fuel_consumption_city_lp100km),0) as average_city_lp100km
FROM car as c
INNER JOIN fuel_consumption as fc 
	ON c.car_id = fc.car_id 
GROUP BY 1
ORDER BY avg_combo_lp100km DESC
LIMIT 5
;





