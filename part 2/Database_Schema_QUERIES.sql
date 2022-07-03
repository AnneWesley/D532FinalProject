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

