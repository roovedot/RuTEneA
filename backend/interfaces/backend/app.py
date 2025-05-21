from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from routes.auth import auth_bp
from routes.user import user_bp
from routes.event import event_bp
from middleware.jwt import SECRET_KEY
from db import db
from flask_migrate import Migrate

app = Flask(__name__)

app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///mi_base_de_datos.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SECRET_KEY'] = SECRET_KEY

db.init_app(app)

migrate = Migrate(app, db) 

app.register_blueprint(auth_bp, url_prefix='/auth')
app.register_blueprint(user_bp, url_prefix='/user')
app.register_blueprint(event_bp, url_prefix='/event')


if __name__ == '__main__':
    with app.app_context():
        db.create_all()  
    app.run(debug=True)
