from db import db

class Event(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    nombre_evento = db.Column(db.String(200), nullable=False)
    fecha_evento = db.Column(db.DateTime, nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    
    user = db.relationship('User', backref=db.backref('events', lazy=True))

    def __repr__(self):
        return f'<Event {self.nombre_evento}>'
