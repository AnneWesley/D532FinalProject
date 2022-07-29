from flask import Flask, render_template
import sqlite3


def get_db_connection():
    conn = sqlite3.connect('emission_rating.db')
    conn.row_factory = sqlite3.Row
    return conn

def get_db():
    conn1 = sqlite3.connect('emission_rating.db')
    #conn.row_factory = sqlite3.Row
    return conn1

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/show_cars')
def show():
    conn = get_db_connection()
    car1 = conn.execute('SELECT * FROM car where vehicle_class="SUV: Small" limit 5').fetchall()
    car2 = conn.execute('SELECT * FROM car where vehicle_class="Mid-size" limit 5').fetchall()
    car3 = conn.execute('SELECT * FROM car where vehicle_class="Compact" limit 5').fetchall()
    car4 = conn.execute('SELECT * FROM car where vehicle_class="Minicompact" limit 5').fetchall()
    car5 = conn.execute('SELECT * FROM car where vehicle_class="SUV: Standard" limit 5').fetchall()
    car6 = conn.execute('SELECT * FROM car where vehicle_class="Two-seater" limit 5').fetchall()
    car7 = conn.execute('SELECT * FROM car where vehicle_class="Subcompact" limit 5').fetchall()
    car8 = conn.execute('SELECT * FROM car where vehicle_class="Station wagon: Small" limit 5').fetchall()
    car9 = conn.execute('SELECT * FROM car where vehicle_class="Station wagon: Mid-size" limit 5').fetchall()
    car10 = conn.execute('SELECT * FROM car where vehicle_class="Full-size" limit 5').fetchall()
    car11 = conn.execute('SELECT * FROM car where vehicle_class="Pickup truck: Small" limit 5').fetchall()
    car12 = conn.execute('SELECT * FROM car where vehicle_class="Pickup truck: Standard" limit 5').fetchall()
    car13 = conn.execute('SELECT * FROM car where vehicle_class="Minivan" limit 5').fetchall()
    car14 = conn.execute('SELECT * FROM car where vehicle_class="Special purpose vehicle" limit 5').fetchall()
    conn.close()
    return render_template('show_cars.html', car1=car1,car2=car2,car3=car3,car4=car4,car5=car5,car6=car6,car7=car7,car8=car8,car9=car9,car10=car10,car11=car11,car12=car12,car13=car13,car14=car14)

def get_car(car_id):
    conn = get_db_connection()
    car = conn.execute('SELECT c.model_year,c.make,c.model, fc.fuel_consumption_combo_lp100km ,fc.fuel_consumption_combo_mpg, e.co2_emissions_gpkm,e.co2_rating, e.smog_rating FROM car AS c INNER JOIN fuel_consumption AS fc ON c.car_id = fc.car_id INNER JOIN emission AS e ON c.car_id = e.car_id WHERE c.car_id=?',
                        (car_id,)).fetchone()
    conn.close()
    #if car is None:
     #   abort(404)
    return car

@app.route('/<int:car_id>')
def car(car_id):
    car = get_car(car_id)
    return render_template('car.html', car=car)

@app.route('/bestco2')
def best():
    conn = get_db()
    b = conn.execute('SELECT c.make,c.model,c.model_year FROM car as c where c.car_id in (select car_id from emission where co2_rating= 10)').fetchall()
    conn.close()
    return render_template('best.html', best=b)

@app.route('/worstco2')
def worst():
    conn = get_db()
    w = conn.execute('SELECT c.make,c.model,c.model_year FROM car as c where c.car_id in (select car_id from emission where co2_rating= 1)').fetchall()
    conn.close()
    return render_template('worst.html', worst=w)

@app.route('/<string:make>')
def other(make):
    conn = get_db()
    o = conn.execute('SELECT c.make,c.model,c.model_year, e.co2_rating FROM car as c, emission as e where c.car_id = e.car_id and c.make=?', (make,)).fetchall()
    conn.close()
    return render_template('other.html', other=o)