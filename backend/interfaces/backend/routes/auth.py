# /routes/auth.py
from flask import Blueprint, jsonify, request
from werkzeug.security import generate_password_hash, check_password_hash
import jwt
import datetime
from models.user import db, User
from middleware.jwt import SECRET_KEY

# Creamos un blueprint para la autenticación
auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/login', methods=['POST'])
def login():
    login_data = request.get_json()
    email = login_data['email']
    password = login_data['password']
    
    usuario = User.query.filter_by(email=email).first()

    if usuario is None:
        return jsonify({'message': 'Usuario no encontrado'}), 404
    
    if check_password_hash(usuario.hash_pass, password):
        token = jwt.encode({
            'user_id': usuario.id,
            'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=1)
        }, SECRET_KEY, algorithm="HS256")
        
        return jsonify({'message': 'Login exitoso', 'token': token})
    else:
        return jsonify({'message': 'Contraseña incorrecta'}), 401

@auth_bp.route('/register',methods=['POST'])
def agregar_usuario():
    nuevo_usuario = request.get_json()
    nombre = nuevo_usuario['nombre']
    email = nuevo_usuario['email']
    password = nuevo_usuario['password']
    
    hash_pass = generate_password_hash(password)

    usuario = User(nombre=nombre, email=email, hash_pass=hash_pass)

    db.session.add(usuario)
    db.session.commit()
    
    return jsonify({'message': 'Usuario agregado exitosamente'}), 201