from datetime import datetime
from flask import Blueprint, request, jsonify
from models.event import Event  
from db import db
from middleware.jwt import token_required

event_bp = Blueprint('event', __name__)

@event_bp.route('/all_events', methods=['GET'])
@token_required  
def get_events(user_id):
    events = Event.query.all()  

    eventos_data = [
        {
            'nombre_evento': event.nombre_evento,
            'fecha_evento': event.fecha_evento.strftime('%Y-%m-%d %H:%M:%S'), 
            'user_id': event.user_id,
            'descripcion': event.descripcion,
            'estado_emocional': event.estado_emocional 
        }
        for event in events
    ]

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
            'icon': event.icon,
            'descripcion': event.descripcion,   
            'estado_emocional': event.estado_emocional     
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
    if not data or 'nombre_evento' not in data or 'icon' not in data:
        return jsonify({'message': 'Datos inválidos o incompletos'}), 400

    fecha_evento = datetime.now()

    nuevo_evento = Event(
    nombre_evento=data['nombre_evento'],
    icon=data['icon'],
    descripcion=data.get('descripcion'),
    estado_emocional=data.get('estado_emocional'),  # NUEVO
    fecha_evento=fecha_evento,
    user_id=user_id
)


    db.session.add(nuevo_evento)
    db.session.commit()

    return jsonify({
        'message': 'Evento creado',
        'evento': {
            'nombre_evento': nuevo_evento.nombre_evento,
            'fecha_evento': nuevo_evento.fecha_evento.strftime('%Y-%m-%d %H:%M'),
            'icon' : nuevo_evento.icon,
            'descripcion': nuevo_evento.descripcion,
            'user_id': nuevo_evento.user_id
        }
    }), 201


@event_bp.route('/event/<int:event_id>', methods=['PUT'])
@token_required
def update_event(user_id, event_id):
    event = Event.query.get_or_404(event_id)

    if event.user_id != user_id:
        return jsonify({'message': 'No tienes permiso para actualizar este evento.'}), 403

    data = request.get_json()

    if 'nombre_evento' in data:
        event.nombre_evento = data['nombre_evento']
    if 'fecha_evento' in data:
        event.fecha_evento = data['fecha_evento']

    if 'estado_emocional' in data:
        event.estado_emocional = data['estado_emocional']

    db.session.commit()

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