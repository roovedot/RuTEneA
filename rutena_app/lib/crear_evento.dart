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
  final TextEditingController fechaController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  Future<void> crearEvento() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'No se encontró token de autenticación. Por favor, inicia sesión.';
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
          'fecha_evento': fechaController.text.trim(),
        }),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Evento creado exitosamente, navega al dashboard
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        setState(() {
          errorMessage = 'Error al crear evento: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error en la conexión: $e';
      });
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    fechaController.dispose();
    super.dispose();
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
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 48.0),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 100,
                      height: 100,
                    ),
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
                      const Text(
                        'Nombre',
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

                      const Text(
                        'Fecha (YYYY-MM-DD)',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: fechaController,
                        decoration: InputDecoration(
                          hintText: '2004-11-09',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),

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
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
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
