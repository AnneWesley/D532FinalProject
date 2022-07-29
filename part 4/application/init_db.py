import sqlite3
import pandas as pd

connection = sqlite3.connect('emission_rating.db')



with open('schema.sql') as f:
    connection.executescript(f.read())

cur = connection.cursor()
read_raw = pd.read_csv(r'C:\Users\vajoshi\PycharmProjects\d532project\MY2022 Fuel Consumption Ratings.csv')
read_raw.to_sql('raw', connection, if_exists='append', index = False)

cur.execute("INSERT INTO fuel (fuel_id) SELECT DISTINCT `Fuel Type` FROM raw")
cur.execute("INSERT INTO car (car_id,model_year, make, model, vehicle_class, engine_size_l,cylinders, transmission, fuel_type) SELECT car_id,`Model Year`,`Make`,`Model`,`Vehicle Class`,`Engine Size(L)`,`Cylinders`,`Transmission`,`Fuel Type` FROM raw")
cur.execute("INSERT INTO fuel_consumption (source, car_id, fuel_consumption_city_lp100km, fuel_consumption_hwy_lp100km, fuel_consumption_combo_lp100km) SELECT 'LAB' AS source,car_id,`Fuel Consumption (City (L/100 km)`,`Fuel Consumption(Hwy (L/100 km))`,`Fuel Consumption(Comb (L/100 km))` FROM raw")
cur.execute("INSERT INTO emission (car_id, co2_emissions_gpkm, co2_rating, smog_rating) SELECT car_id,`CO2 Emissions(g/km)`,`CO2 Rating`,`Smog Rating` FROM raw")
connection.commit()
connection.close()