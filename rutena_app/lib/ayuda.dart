import 'package:flutter/material.dart';

class AyudaPage extends StatelessWidget {
  const AyudaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guía de la App'),
        backgroundColor: Colors.purple[200],
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSection(
            title: '1. Iniciar Sesión',
            description: 'Para entrar en la aplicación, escribe tu correo y contraseña y pulsa este botón:',
            child: _fakeButton('Iniciar Sesión', color: Colors.red),
          ),
          _buildDivider(),
          _buildSection(
            title: '2. Ver el Panel (Dashboard)',
            description: 'Una vez dentro, verás tu día. Aquí se mostrarán tus eventos. Puedes cambiar de día.',
            child: _fakeCard('29 mayo 2025', Icons.calendar_today),
          ),
          _buildDivider(),
          _buildSection(
            title: '3. Crear un Evento',
            description: 'Presiona este botón para añadir un nuevo evento:',
            child: _fakeButton('Crear Evento', color: Colors.red),
          ),
          const SizedBox(height: 12),
          const Text('Pasos para crear un evento:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _fakeStep('😊 Elige un emoji.'),
          _fakeStep('Escribe el título.'),
          _fakeStep('Puedes escribir una descripción.'),
          _fakeStep('Elige cómo te sentiste.'),
          _fakeStep('Presiona "Crear Evento".'),
          _buildDivider(),
          _buildSection(
            title: '4. Ver detalles',
            description: 'Toca un evento en el panel para ver más información, como esto:',
            child: _fakeEventDetail(),
          ),
          _buildDivider(),
          _buildSection(
            title: '5. Cerrar Sesión',
            description: 'Cuando termines, puedes salir con este botón:',
            child: _fakeButton('Cerrar Sesión', color: Colors.grey[400]!),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required String description, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        Text(description, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _fakeButton(String text, {Color color = Colors.blue}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _fakeCard(String date, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.purple[100], borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 32, color: Colors.black54),
          const SizedBox(width: 12),
          Text(date, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _fakeStep(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _fakeEventDetail() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: const [
          Text('🎉', style: TextStyle(fontSize: 36)),
          SizedBox(height: 8),
          Text('Fiesta en casa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('Me divertí mucho con mis amigos.', textAlign: TextAlign.center),
          SizedBox(height: 4),
          Text('Emoción: Feliz', style: TextStyle(fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Divider(thickness: 1),
    );
  }
}
