# /middleware/jwt.py
import jwt
from flask import request, jsonify
from models.user import User
from functools import wraps

SECRET_KEY = ":ESe-UlJ{8_SN+u#!67Uo(S9%_8/2n"

def token_required(f):
    @wraps(f)
    def decorator(*args, **kwargs):
        token = request.headers.get('Authorization')

        if not token:
            return jsonify({'message': 'Token de autorización faltante'}), 403

        try:
            if token.startswith("Bearer "):
                token = token.split(" ")[1]
            else:
                return jsonify({'message': 'Token de autorización mal formado'}), 403

            decoded_token = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
            user_id = decoded_token.get('user_id')
            
            if not user_id:
                return jsonify({'message': 'ID de usuario no encontrado en el token'}), 401
            
            kwargs['user_id'] = user_id
        except jwt.ExpiredSignatureError:
            return jsonify({'message': 'El token ha expirado'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'message': 'Token inválido'}), 401
        
        return f(*args, **kwargs)

    return decorator