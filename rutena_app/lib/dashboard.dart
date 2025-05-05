import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header con logo y botón
            _buildHeader(context),
            
            // Lista de eventos
            Expanded(
              child: _buildEventsList(context),
            ),
            
            // Botón Cerrar Sesión
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo RuTEnA
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/logo.png', // Ajusta el nombre de tu archivo
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              // Botón Crear Evento
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/crearEvento');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Crear Evento',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildEventsList(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600), // Limita el ancho máximo
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _buildEventItem(
              time: "8:00",
              icon: "🥐",
              title: "Desayunar",
              color: Colors.green[100]!,
            ),
            _buildTimelineDivider(),
            _buildEventItem(
              time: "10:00",
              icon: "⚽",
              title: "Jugar al Fútbol",
              color: Colors.purple[100]!,
            ),
            _buildTimelineDivider(),
            _buildEventItem(
              time: "14:30",
              icon: "🍽️",
              title: "Comer con la abuela",
              color: Colors.red[100]!,
            ),
            _buildTimelineDivider(),
            _buildEventItem(
              time: "18:00",
              icon: "🌳",
              title: "Pasear por el campo",
              color: Colors.blue[100]!,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildEventItem({
  required String time,
  required String icon,
  required String title,
  required Color color,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Hora
      SizedBox(
        width: 50,
        child: Text(
          time,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // Línea vertical
      Container(
        width: 2,
        height: 100, // Reducido para no ocupar tanto espacio
        color: Colors.grey[300],
      ),
      
      // Tarjeta del evento
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 120, // Altura máxima fija
              maxWidth: 120, // Ancho máximo fijo
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      icon,
                      style: const TextStyle(fontSize: 28), // Reducido un poco
                    ),
                    const SizedBox(height: 8), // Reducido el espaciado
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14, // Reducido un poco
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      
      const SizedBox(width: 50),
    ],
  );
}

  Widget _buildTimelineDivider() {
    return Row(
      children: [
        const SizedBox(width: 50),
        Container(
          width: 2,
          height: 20,
          color: Colors.grey[300],
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}