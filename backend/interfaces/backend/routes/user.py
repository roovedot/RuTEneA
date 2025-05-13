# /routes/user.py
from flask import Blueprint, jsonify, request
from models.user import User
from middleware.jwt import token_required
from db import db

user_bp = Blueprint('user', __name__)

@user_bp.route('/profile', methods=['GET'])
@token_required
def obtener_usuario(user_id):  # Usamos el user_id del token
    usuario = User.query.get(user_id)  # Buscamos al usuario usando el user_id
    if usuario is None:
        return jsonify({'message': 'Usuario no encontrado'}), 404
    
    return jsonify({'id': usuario.id, 'nombre': usuario.nombre, 'email': usuario.email})

@user_bp.route('/usuarios', methods=['GET'])
@token_required
def obtener_usuarios(user_id):  # Usamos el user_id del token
    usuarios = User.query.all()
    usuarios_list = [{'id': u.id, 'nombre': u.nombre, 'email': u.email} for u in usuarios]
    return jsonify(usuarios_list)

@user_bp.route('/actualizar', methods=['POST'])
@token_required
def actualizar_usuario(user_id):  # Usamos user_id del token
    usuario = User.query.get(user_id)  # Buscamos al usuario con el user_id del token
    
    if usuario is None:
        return jsonify({'message': 'Usuario no encontrado'}), 404

    datos_actualizados = request.get_json()

    # Actualizamos los campos solo si se pasan en el cuerpo de la solicitud
    if 'nombre' in datos_actualizados:
        usuario.nombre = datos_actualizados['nombre']
    
    if 'email' in datos_actualizados:
        usuario.email = datos_actualizados['email']
    
    db.session.commit()
    
    return jsonify({'message': 'Usuario actualizado exitosamente'})


@user_bp.route('/eliminar', methods=['DELETE'])
@token_required
def eliminar_usuario(user_id):  # Usamos user_id del token
    usuario = User.query.get(user_id)  # Buscamos al usuario con el user_id del token
    
    if usuario is None:
        return jsonify({'message': 'Usuario no encontrado'}), 404

    db.session.delete(usuario)
    db.session.commit()
    
    return jsonify({'message': 'Usuario eliminado exitosamente'})
