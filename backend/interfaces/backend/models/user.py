from db import db 

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    nombre = db.Column(db.String(200), nullable=False)
    email = db.Column(db.String(200), nullable=False, unique=True)
    hash_pass = db.Column(db.String(500), nullable=False)
    def __repr__(self):
        return f'<User {self.nombre}>'