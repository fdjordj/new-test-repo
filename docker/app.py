from flask import Flask, request, redirect, url_for
import psycopg2
from celery import Celery

app = Flask(__name__)

def get_db_connection():
    conn = psycopg2.connect(
        dbname="mydatabase",
        user="user",
        password="password",
        host="db", 
        port="5432"
    )
    return conn

def make_celery(app):
    celery = Celery(
        app.import_name,
        backend=app.config['CELERY_RESULT_BACKEND'],
        broker=app.config['CELERY_BROKER_URL']
    )
    celery.conf.update(app.config)
    return celery

# Flask konfiguracija za Celery
app.config['CELERY_BROKER_URL'] = 'redis://redis:6379/0'
app.config['CELERY_RESULT_BACKEND'] = 'redis://redis:6379/0'

celery = make_celery(app)

@app.route('/')
def home():
    return '''
        <html>
            <body>
                <h1>Dobrodošli na početnu stranicu!</h1>
                <button onclick="window.location.href='/allow';">Odvedi me na Allow</button>
            </body>
        </html>
    '''

@app.route('/allow', methods=['GET', 'POST'])
def allow():
    if request.method == 'POST':
        item_name = request.form['item_name']
        
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('INSERT INTO items (name) VALUES (%s);', (item_name,))
        conn.commit()
        conn.close()
        
        return redirect(url_for('allow', success='true'))

    return '''
        <html>
            <body>
                <h1>Dobrodošli na Allow stranicu!</h1>
                <form method="POST">
                    <label for="item_name">Unesite podatke:</label>
                    <input type="text" id="item_name" name="item_name" required>
                    <button type="submit">Dodaj u bazu</button>
                </form>
                <button onclick="window.location.href='/ispis';">Prikaži podatke</button>
                <button onclick="window.location.href='/obris';">Idi na stranicu za brisanje</button>
            </body>
        </html>
    '''

@app.route('/ispis')
def ispis():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM items;')
    items = cursor.fetchall()
    conn.close()

    html = '<h1>Podaci iz baze:</h1><ul>'
    for item in items:
        html += f'<li>{item[1]}</li>'
    html += '</ul>'
    return html

@app.route('/obris', methods=['GET', 'POST'])
def obris():
    if request.method == 'POST':
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('DELETE FROM items WHERE id = (SELECT MAX(id) FROM items);')
        conn.commit()
        conn.close()
        
        return redirect(url_for('obris'))

    return '''
        <html>
            <body>
                <h1>Stranica za brisanje</h1>
                <form method="POST">
                    <button type="submit">Obriši poslednji element</button>
                </form>
                <button onclick="window.location.href='/ispis';">Prikaži podatke</button>
            </body>
        </html>
    '''

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')