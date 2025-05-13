from datetime import datetime
from flask import Blueprint, request, jsonify
from models.event import Event  # Importar el modelo Event
from db import db
from middleware.jwt import token_required

# Crear el Blueprint para las rutas de eventos
event_bp = Blueprint('event', __name__)

# Ruta para obtener todos los eventos
@event_bp.route('/all_events', methods=['GET'])
@token_required  # Esto asegurará que solo usuarios autenticados puedan acceder
def get_events(user_id):
    events = Event.query.all()  # Obtener todos los eventos

    # Crear una lista de diccionarios con los datos necesarios
    eventos_data = [
        {
            'nombre_evento': event.nombre_evento,
            'fecha_evento': event.fecha_evento.strftime('%Y-%m-%d %H:%M:%S'),  # Formatear la fecha a string
            'user_id': event.user_id
        }
        for event in events
    ]

    # Retornar la lista de eventos con los campos deseados
    return jsonify(eventos_data), 200

@event_bp.route('/events', methods=['GET'])
@token_required  
def get_user_events(user_id):
    events = Event.query.filter_by(user_id=user_id).all()

    if not events:
        return jsonify({'message': 'No hay eventos para este usuario.'}), 404

    eventos_data = [
        {
            'nombre_evento': event.nombre_evento,
            'fecha_evento': event.fecha_evento.strftime('%Y-%m-%d %H:%M:%S'),  # Formatear la fecha a string
            'user_id': event.user_id
        }
        for event in events
    ]

    return jsonify(eventos_data), 200

@event_bp.route('/event/<int:event_id>', methods=['GET'])
@token_required
def get_event(user_id, event_id):
    event = Event.query.get_or_404(event_id)

    if event.user_id != user_id:
        return jsonify({'message': 'No tienes permiso para ver este evento.'}), 403

    return jsonify({
        'nombre_evento': event.nombre_evento,
        'fecha_evento': event.fecha_evento.strftime('%Y-%m-%d %H:%M:%S'),  
        'user_id': event.user_id
    }), 200

@event_bp.route('/event', methods=['POST'])
@token_required
def create_event(user_id):
    data = request.get_json()
    if not data or 'nombre_evento' not in data or 'fecha_evento' not in data:
        return jsonify({'message': 'Datos inválidos o incompletos'}), 400

    try:
        # Intentar convertir la fecha al formato correcto (YYYY-MM-DD)
        fecha_evento = datetime.strptime(data['fecha_evento'], '%Y-%m-%d')
    except ValueError:
        return jsonify({'message': 'Formato de fecha incorrecto, debe ser YYYY-MM-DD'}), 400


    nuevo_evento = Event(
        nombre_evento=data['nombre_evento'],
        fecha_evento=fecha_evento,
        user_id=user_id  # Usar el user_id del token
    )

    db.session.add(nuevo_evento)
    db.session.commit()

    return jsonify({
        'message': 'Evento creado',
        'evento': {
            'nombre_evento': nuevo_evento.nombre_evento,
            'fecha_evento': nuevo_evento.fecha_evento,
            'user_id': nuevo_evento.user_id
        }
    }), 201


@event_bp.route('/event/<int:event_id>', methods=['PUT'])
@token_required
def update_event(user_id, event_id):
    # Obtener el evento de la base de datos por su ID
    event = Event.query.get_or_404(event_id)

    # Validar que el evento pertenece al usuario autenticado
    if event.user_id != user_id:
        return jsonify({'message': 'No tienes permiso para actualizar este evento.'}), 403

    # Obtener los datos enviados en el cuerpo de la solicitud
    data = request.get_json()

    # Actualizar los campos del evento si se proporcionan nuevos datos
    if 'nombre_evento' in data:
        event.nombre_evento = data['nombre_evento']
    if 'fecha_evento' in data:
        event.fecha_evento = data['fecha_evento']

    # Guardar los cambios en la base de datos
    db.session.commit()

    # Retornar la respuesta con los detalles del evento actualizado
    return jsonify({
        'message': 'Evento actualizado',
        'evento': {
            'nombre_evento': event.nombre_evento,
            'fecha_evento': event.fecha_evento,
            'user_id': event.user_id
        }
    }), 200

@event_bp.route('/event/<int:event_id>', methods=['DELETE'])
@token_required
def delete_event(user_id, event_id):
    try:
        event = Event.query.get_or_404(event_id)

        if event.user_id != user_id:
            return jsonify({'message': 'No tienes permiso para eliminar este evento.'}), 403

        db.session.delete(event)
        db.session.commit()

        return jsonify({'message': 'Evento eliminado'}), 200
    except Exception as e: 
        return jsonify({'message': 'Error al eliminar el evento'}), 500