import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CrearEventoPage extends StatefulWidget {
  const CrearEventoPage({super.key});

  @override
  _CrearEventoPageState createState() => _CrearEventoPageState();
}

class _CrearEventoPageState extends State<CrearEventoPage> {
  final TextEditingController nombreController = TextEditingController();
  String? selectedEmoji;
  final TextEditingController descripcionController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  // Lista de emojis de ejemplo
  final List<String> emojis = [
    "😀", "😂", "😍", "👍", "🎉", "🥳", "🔥", "🐱", "🌟", "🚀",
    // puedes añadir más...
  ];

  Future<void> crearEvento() async {
    if (selectedEmoji == null) {
      setState(() {
        errorMessage = 'Por favor, selecciona un emoji.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'No se encontró token. Por favor, inicia sesión.';
      });
      return;
    }

    final url = Uri.parse('http://localhost:5000/event/event');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nombre_evento': nombreController.text.trim(),
          'icon': selectedEmoji,
          'descripcion': descripcionController.text.trim(), 
        }),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        setState(() {
          errorMessage = 'Error al crear evento: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error de conexión: $e';
      });
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    super.dispose();
  }

  Future<void> _pickEmoji() async {
    final emoji = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: emojis.length,
          itemBuilder: (_, i) {
            return GestureDetector(
              onTap: () => Navigator.pop(context, emojis[i]),
              child: Center(child: Text(emojis[i], style: const TextStyle(fontSize: 24))),
            );
          },
        );
      },
    );

    if (emoji != null) {
      setState(() {
        selectedEmoji = emoji;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo vuelve al dashboard
                GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 48.0),
                    child: Image.asset('assets/logo.png', width: 100, height: 100),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Nombre
                      const Text(
                        'Nombre del Evento',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nombreController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Selector de Emoji
                      const Text(
                        'Icono (Emoji)',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                selectedEmoji ?? 'Ninguno seleccionado',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: selectedEmoji == null ? Colors.grey : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _pickEmoji,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            child: const Text('Elegir'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Descripción
                      const Text(
                        'Descripción',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descripcionController,            // ← aquí
                        maxLines: 3,                                  // permitir varias líneas
                        decoration: InputDecoration(
                          hintText: 'Escribe una descripción...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),


                      // Mensaje de error
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Botón Crear Evento
                      ElevatedButton(
                        onPressed: isLoading ? null : crearEvento,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
