import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import '../constants/constants.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<dynamic>> _eventsMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchCalendarEvents();
  }

  DateTime _normalizeDate(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  Future<void> _fetchCalendarEvents() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final response = await http.get(Uri.parse('$baseUrl/api/v1/calendar/'));
      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> rawEvents = data['events'] ?? [];

        final Map<DateTime, List<dynamic>> newMap = {};
        for (var item in rawEvents) {
          final dateStr = item['event_date'];
          if (dateStr != null) {
            try {
              final parts = dateStr.toString().substring(0, 10).split('-');
              final key = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
              if (newMap[key] == null) {
                newMap[key] = [];
              }
              newMap[key]!.add(item);
            } catch (_) {}
          }
        }

        setState(() {
          _eventsMap = newMap;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _eventsMap[_normalizeDate(day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final selectedEvents = _selectedDay != null ? _getEventsForDay(_selectedDay!) : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('등록된 일정'),
        actions: [
          IconButton(onPressed: _fetchCalendarEvents, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: _getEventsForDay,
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!mounted) return;
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    if (!mounted) return;
                    setState(() => _calendarFormat = format);
                  },
                  calendarStyle: const CalendarStyle(
                    markerDecoration: BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: selectedEvents.isEmpty
                      ? const Center(child: Text('해당 날짜에 등록된 일정이 없습니다.'))
                      : ListView.builder(
                          itemCount: selectedEvents.length,
                          itemBuilder: (context, index) {
                            final item = selectedEvents[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              child: ListTile(
                                leading: const Icon(Icons.event, color: Colors.deepPurple),
                                title: Text(item['title'] ?? '일정 제목 없음', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('날짜: ${item['event_date']}'),
                                trailing: item['image_url'] != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.network(
                                          item['image_url'],
                                          width: 45,
                                          height: 45,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Icon(Icons.broken_image, size: 30),
                                        ),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}