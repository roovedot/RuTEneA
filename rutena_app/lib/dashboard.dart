import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// Modelo de Evento
class Evento {
  final String nombreEvento;
  final String icon;
  final DateTime fechaEvento;
  final String? descripcion;
  final String? estadoEmocional; // ← NUEVO

  Evento({
    required this.nombreEvento,
    required this.icon,
    required this.fechaEvento,
    this.descripcion,
    this.estadoEmocional,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      nombreEvento: json['nombre_evento'],
      icon: json['icon'],
      fechaEvento: DateTime.parse(json['fecha_evento']),
      descripcion: json['descripcion'],
      estadoEmocional: json['estado_emocional'], // ← NUEVO
    );
  }
}


class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Evento> allEvents = [];
  bool isLoading = false;
  String? errorMessage;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'No se encontró token. Inicia sesión.';
      });
      return;
    }
    final url = Uri.parse('http://127.0.0.1:5000/event/events');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final events = data.map((e) => Evento.fromJson(e)).toList();
        setState(() {
          allEvents = events;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Error al cargar eventos: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error de conexión: $e';
      });
    }
  }

  List<Evento> get _eventsForSelectedDate {
    final fmt = DateFormat('yyyy-MM-dd');
    final sel = fmt.format(selectedDate);
    return allEvents.where((e) => fmt.format(e.fechaEvento) == sel).toList();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

void _showEventDetail(Evento event) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(event.icon, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(event.nombreEvento,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(DateFormat('yyyy-MM-dd HH:mm').format(event.fechaEvento),
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            if (event.descripcion != null)
              Text(event.descripcion!,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center),
            const SizedBox(height: 16),
            if (event.estadoEmocional != null && event.estadoEmocional!.isNotEmpty)
              Column(
                children: [
                  const Text('Estado emocional:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(event.estadoEmocional!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),
                ],
              ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isToday = selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildDateSelector(isToday),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? Center(child: Text(errorMessage!))
                      : _eventsForSelectedDate.isEmpty
                          ? Center(
                              child: Text('No hay eventos para ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
                            )
                          : _buildEventsList(_eventsForSelectedDate),
            ),
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
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/crearEvento'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Crear Evento', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(bool isToday) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(icon: const Icon(Icons.arrow_left), onPressed: () {
            setState(() => selectedDate = selectedDate.subtract(const Duration(days: 1)));
          }),
          TextButton(onPressed: _pickDate, child: Text(DateFormat('yyyy-MM-dd').format(selectedDate), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          IconButton(icon: const Icon(Icons.arrow_right), onPressed: isToday ? null : () {
            setState(() => selectedDate = selectedDate.add(const Duration(days: 1)));
          }),
        ],
      ),
    );
  }

  Widget _buildEventsList(List<Evento> events) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: events.length,
          separatorBuilder: (_, __) => _buildTimelineDivider(),
          itemBuilder: (context, i) {
            final event = events[i];
            return GestureDetector(
              onTap: () => _showEventDetail(event),
              child: _buildEventItem(
                time: DateFormat.Hm().format(event.fechaEvento),
                icon: event.icon,
                title: event.nombreEvento,
                descripcion: event.descripcion ?? '',
                color: Colors.blue[100]!,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTimelineDivider() {
    return Row(
      children: [
        const SizedBox(width: 50),
        Container(width: 2, height: 20, color: Colors.grey[300]),
      ],
    );
  }

  Widget _buildEventItem({required String time, required String icon, required String title, required descripcion, required Color color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 50, child: Text(time, style: const TextStyle(fontWeight: FontWeight.bold))),
        Container(width: 2, height: 100, color: Colors.grey[300]),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 120, maxWidth: 120),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(icon, style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 8),
                      Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
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

  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('jwt_token');
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300], padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
            ),
          ),
        ),
      ),
    );
  }
}