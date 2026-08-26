import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/nevigate.dart';
import 'services/fcm.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    FcmService.isEnabled = true;
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint("Firebase 초기화를 건너뜀: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'T.Salmon',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'screens/main_navigation_screen.dart';
// import 'services/fcm_service.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'T.Salmon',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MainNavigationScreen(),
//     );
//   }
// }

// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:http_parser/http_parser.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'package:table_calendar/table_calendar.dart';
// // import 'package:url_launcher/url_launcher.dart';
// // import 'package:firebase_core/firebase_core.dart';
// // import 'package:firebase_messaging/firebase_messaging.dart';

// // // 로컬 환경에 맞게 서버 IP/포트 설정 (안드로이드 에뮬레이터 기준 10.0.2.2:8000, 실제 기기는 PC IP 입력)
// // const String baseUrl = "http://10.0.2.2:8000";

// // // 백그라운드 푸시 알림 핸들러 최상단 선언
// // @pragma('vm:entry-point')
// // Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
// //   await Firebase.initializeApp();
// //   debugPrint("📩 [FCM 백그라운드 수신]: ${message.notification?.title}");
// // }

// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await Firebase.initializeApp();
// //   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
// //   runApp(const MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'T.Salmon',
// //       theme: ThemeData(
// //         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
// //         useMaterial3: true,
// //       ),
// //       home: const MainNavigationScreen(),
// //     );
// //   }
// // }

// // class MainNavigationScreen extends StatefulWidget {
// //   const MainNavigationScreen({super.key});

// //   @override
// //   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// // }

// // class _MainNavigationScreenState extends State<MainNavigationScreen> {
// //   int _currentIndex = 0;

// //   final List<Widget> _screens = const [
// //     UploadScreen(),
// //     CalendarScreen(),
// //     HistoryScreen(),
// //   ];

// //   @override
// //   void initState() {
// //     super.initState();
// //     _initFCM();
// //   }

// //   // FCM 권한 요청 및 디바이스 토큰 백엔드 자동 등록
// //   Future<void> _initFCM() async {
// //     try {
// //       FirebaseMessaging messaging = FirebaseMessaging.instance;

// //       NotificationSettings settings = await messaging.requestPermission(
// //         alert: true,
// //         badge: true,
// //         sound: true,
// //       );

// //       if (settings.authorizationStatus == AuthorizationStatus.authorized) {
// //         String? token = await messaging.getToken();
// //         if (token != null) {
// //           debugPrint("🔑 [FCM Token 발급]: $token");
// //           await _registerTokenToBackend(token);
// //         }

// //         // 토큰 갱신 감지 리스너
// //         messaging.onTokenRefresh.listen((newToken) async {
// //           debugPrint("🔄 [FCM Token 갱신]: $newToken");
// //           await _registerTokenToBackend(newToken);
// //         });

// //         // 앱이 포그라운드(켜져 있는 상태)일 때 알림 수신
// //         FirebaseMessaging.onMessage.listen((RemoteMessage message) {
// //           if (message.notification != null && mounted) {
// //             ScaffoldMessenger.of(context).showSnackBar(
// //               SnackBar(
// //                 content: Text('[알림] ${message.notification!.title ?? ""}\n${message.notification!.body ?? ""}'),
// //                 duration: const Duration(seconds: 4),
// //                 behavior: SnackBarBehavior.floating,
// //               ),
// //             );
// //           }
// //         });
// //       }
// //     } catch (e) {
// //       debugPrint("❌ [FCM 초기화 오류]: $e");
// //     }
// //   }

// //   Future<void> _registerTokenToBackend(String token) async {
// //     try {
// //       final response = await http.post(
// //         Uri.parse('$baseUrl/api/v1/devices/token'),
// //         headers: {'Content-Type': 'application/json'},
// //         body: jsonEncode({
// //           'user_id': 'default_user',
// //           'fcm_token': token,
// //         }),
// //       );
// //       if (response.statusCode == 200) {
// //         debugPrint("✅ [디바이스 토큰 백엔드 저장 성공]");
// //       }
// //     } catch (e) {
// //       debugPrint("❌ [디바이스 토큰 백엔드 저장 실패]: $e");
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: _screens[_currentIndex],
// //       bottomNavigationBar: NavigationBar(
// //         selectedIndex: _currentIndex,
// //         onDestinationSelected: (index) => setState(() => _currentIndex = index),
// //         destinations: const [
// //           NavigationDestination(
// //             icon: Icon(Icons.cloud_upload_outlined),
// //             selectedIcon: Icon(Icons.cloud_upload),
// //             label: '업로드',
// //           ),
// //           NavigationDestination(
// //             icon: Icon(Icons.calendar_month_outlined),
// //             selectedIcon: Icon(Icons.calendar_month),
// //             label: '캘린더',
// //           ),
// //           NavigationDestination(
// //             icon: Icon(Icons.history_outlined),
// //             selectedIcon: Icon(Icons.history),
// //             label: '히스토리',
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // // -------------------------------------------------------------
// // // 1. 업로드 탭
// // // -------------------------------------------------------------
// // class UploadScreen extends StatefulWidget {
// //   const UploadScreen({super.key});

// //   @override
// //   State<UploadScreen> createState() => _UploadScreenState();
// // }

// // class _UploadScreenState extends State<UploadScreen> {
// //   File? _selectedImage;
// //   bool _isLoading = false;
// //   Map<String, dynamic>? _analysisResult;

// //   final ImagePicker _picker = ImagePicker();

// //   Future<void> _pickAndUploadImage() async {
// //     final pickedFile = await _picker.pickImage(
// //       source: ImageSource.gallery,
// //       imageQuality: 100,
// //       maxWidth: null,
// //       maxHeight: null,
// //     );
// //     if (pickedFile == null) return;

// //     if (!mounted) return;
// //     setState(() {
// //       _selectedImage = File(pickedFile.path);
// //       _isLoading = true;
// //       _analysisResult = null;
// //     });

// //     try {
// //       final uri = Uri.parse('$baseUrl/api/v1/analyze');
// //       final request = http.MultipartRequest('POST', uri);

// //       final ext = pickedFile.path.split('.').last.toLowerCase();
// //       final mimeType = (ext == 'png') ? 'image/png' : 'image/jpeg';

// //       request.files.add(await http.MultipartFile.fromPath(
// //         'file',
// //         pickedFile.path,
// //         contentType: MediaType.parse(mimeType),
// //       ));

// //       final streamedResponse = await request.send();
// //       final response = await http.Response.fromStream(streamedResponse);

// //       if (response.statusCode == 200) {
// //         final decoded = jsonDecode(utf8.decode(response.bodyBytes));
// //         if (mounted) {
// //           setState(() {
// //             _analysisResult = decoded['analysis'];
// //           });
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(content: Text('분석 및 저장이 완료되었습니다!')),
// //           );
// //         }
// //       } else {
// //         throw Exception('서버 응답 오류: ${response.statusCode}');
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('업로드 실패: $e')),
// //         );
// //       }
// //     } finally {
// //       if (mounted) {
// //         setState(() => _isLoading = false);
// //       }
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('스크린샷 분석')),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           children: [
// //             if (_selectedImage != null)
// //               ClipRRect(
// //                 borderRadius: BorderRadius.circular(12),
// //                 child: Image.file(_selectedImage!, height: 260, fit: BoxFit.cover),
// //               )
// //             else
// //               Container(
// //                 height: 200,
// //                 decoration: BoxDecoration(
// //                   color: Colors.grey.shade200,
// //                   borderRadius: BorderRadius.circular(12),
// //                 ),
// //                 child: const Center(child: Text('분석할 스크린샷을 선택하세요')),
// //               ),
// //             const SizedBox(height: 20),
// //             ElevatedButton.icon(
// //               onPressed: _isLoading ? null : _pickAndUploadImage,
// //               icon: const Icon(Icons.photo_library),
// //               label: Text(_isLoading ? '분석 중...' : '갤러리에서 선택 및 분석'),
// //               style: ElevatedButton.styleFrom(
// //                 minimumSize: const Size.fromHeight(50),
// //               ),
// //             ),
// //             const SizedBox(height: 24),
// //             if (_isLoading)
// //               const CircularProgressIndicator()
// //             else if (_analysisResult != null) ...[
// //               const Align(
// //                 alignment: Alignment.centerLeft,
// //                 child: Text('분석 결과', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// //               ),
// //               const SizedBox(height: 8),
// //               Card(
// //                 child: Padding(
// //                   padding: const EdgeInsets.all(16),
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text('카테고리: ${_analysisResult?['category'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold)),
// //                       const SizedBox(height: 6),
// //                       Text('액션 타입: ${_analysisResult?['action_type'] ?? '-'}'),
// //                       const SizedBox(height: 6),
// //                       Text('요약: ${_analysisResult?['summary'] ?? '-'}'),
// //                       if (_analysisResult?['action_data'] != null && _analysisResult?['action_data'] != "") ...[
// //                         const SizedBox(height: 6),
// //                         Text('상세: ${_analysisResult?['action_data']}'),
// //                       ],
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // // -------------------------------------------------------------
// // // 2. 캘린더 탭
// // // -------------------------------------------------------------
// // class CalendarScreen extends StatefulWidget {
// //   const CalendarScreen({super.key});

// //   @override
// //   State<CalendarScreen> createState() => _CalendarScreenState();
// // }

// // class _CalendarScreenState extends State<CalendarScreen> {
// //   CalendarFormat _calendarFormat = CalendarFormat.month;
// //   DateTime _focusedDay = DateTime.now();
// //   DateTime? _selectedDay;

// //   Map<DateTime, List<dynamic>> _eventsMap = {};
// //   bool _isLoading = true;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _selectedDay = _focusedDay;
// //     _fetchCalendarEvents();
// //   }

// //   DateTime _normalizeDate(DateTime dt) {
// //     return DateTime(dt.year, dt.month, dt.day);
// //   }

// //   Future<void> _fetchCalendarEvents() async {
// //     if (!mounted) return;
// //     setState(() => _isLoading = true);

// //     try {
// //       final response = await http.get(Uri.parse('$baseUrl/api/v1/calendar/'));
// //       if (response.statusCode == 200 && mounted) {
// //         final data = jsonDecode(utf8.decode(response.bodyBytes));
// //         final List<dynamic> rawEvents = data['events'] ?? [];

// //         final Map<DateTime, List<dynamic>> newMap = {};
// //         for (var item in rawEvents) {
// //           final dateStr = item['event_date'];
// //           if (dateStr != null) {
// //             try {
// //               final parts = dateStr.toString().substring(0, 10).split('-');
// //               final key = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
// //               if (newMap[key] == null) {
// //                 newMap[key] = [];
// //               }
// //               newMap[key]!.add(item);
// //             } catch (_) {}
// //           }
// //         }

// //         setState(() {
// //           _eventsMap = newMap;
// //         });
// //       }
// //     } catch (e) {
// //       // 에러 무시
// //     } finally {
// //       if (mounted) {
// //         setState(() => _isLoading = false);
// //       }
// //     }
// //   }

// //   List<dynamic> _getEventsForDay(DateTime day) {
// //     return _eventsMap[_normalizeDate(day)] ?? [];
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final selectedEvents = _selectedDay != null ? _getEventsForDay(_selectedDay!) : [];

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('등록된 일정'),
// //         actions: [
// //           IconButton(onPressed: _fetchCalendarEvents, icon: const Icon(Icons.refresh)),
// //         ],
// //       ),
// //       body: _isLoading
// //           ? const Center(child: CircularProgressIndicator())
// //           : Column(
// //               children: [
// //                 TableCalendar(
// //                   firstDay: DateTime.utc(2020, 1, 1),
// //                   lastDay: DateTime.utc(2030, 12, 31),
// //                   focusedDay: _focusedDay,
// //                   calendarFormat: _calendarFormat,
// //                   selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
// //                   eventLoader: _getEventsForDay,
// //                   onDaySelected: (selectedDay, focusedDay) {
// //                     if (!mounted) return;
// //                     setState(() {
// //                       _selectedDay = selectedDay;
// //                       _focusedDay = focusedDay;
// //                     });
// //                   },
// //                   onFormatChanged: (format) {
// //                     if (!mounted) return;
// //                     setState(() => _calendarFormat = format);
// //                   },
// //                   calendarStyle: const CalendarStyle(
// //                     markerDecoration: BoxDecoration(
// //                       color: Colors.deepPurple,
// //                       shape: BoxShape.circle,
// //                     ),
// //                   ),
// //                 ),
// //                 const Divider(),
// //                 Expanded(
// //                   child: selectedEvents.isEmpty
// //                       ? const Center(child: Text('해당 날짜에 등록된 일정이 없습니다.'))
// //                       : ListView.builder(
// //                           itemCount: selectedEvents.length,
// //                           itemBuilder: (context, index) {
// //                             final item = selectedEvents[index];
// //                             return Card(
// //                               margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
// //                               child: ListTile(
// //                                 leading: const Icon(Icons.event, color: Colors.deepPurple),
// //                                 title: Text(item['title'] ?? '일정 제목 없음', style: const TextStyle(fontWeight: FontWeight.bold)),
// //                                 subtitle: Text('날짜: ${item['event_date']}'),
// //                                 trailing: item['image_url'] != null
// //                                     ? ClipRRect(
// //                                         borderRadius: BorderRadius.circular(6),
// //                                         child: Image.network(
// //                                           item['image_url'],
// //                                           width: 45,
// //                                           height: 45,
// //                                           fit: BoxFit.cover,
// //                                           errorBuilder: (context, error, stackTrace) =>
// //                                               const Icon(Icons.broken_image, size: 30),
// //                                         ),
// //                                       )
// //                                     : null,
// //                               ),
// //                             );
// //                           },
// //                         ),
// //                 ),
// //               ],
// //             ),
// //     );
// //   }
// // }

// // // -------------------------------------------------------------
// // // 3. 히스토리 탭
// // // -------------------------------------------------------------
// // class HistoryScreen extends StatefulWidget {
// //   const HistoryScreen({super.key});

// //   @override
// //   State<HistoryScreen> createState() => _HistoryScreenState();
// // }

// // class _HistoryScreenState extends State<HistoryScreen> {
// //   List<dynamic> _historyList = [];
// //   bool _isLoading = true;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchHistory();
// //   }

// //   Future<void> _fetchHistory() async {
// //     if (!mounted) return;
// //     setState(() => _isLoading = true);

// //     try {
// //       final response = await http.get(Uri.parse('$baseUrl/api/v1/history/'));
// //       if (response.statusCode == 200 && mounted) {
// //         final data = jsonDecode(utf8.decode(response.bodyBytes));
// //         setState(() {
// //           _historyList = data['history'] ?? [];
// //         });
// //       }
// //     } catch (e) {
// //       // 에러 무시
// //     } finally {
// //       if (mounted) {
// //         setState(() => _isLoading = false);
// //       }
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('분석 히스토리'),
// //         actions: [
// //           IconButton(onPressed: _fetchHistory, icon: const Icon(Icons.refresh)),
// //         ],
// //       ),
// //       body: _isLoading
// //           ? const Center(child: CircularProgressIndicator())
// //           : _historyList.isEmpty
// //               ? const Center(child: Text('히스토리가 없습니다.'))
// //               : ListView.builder(
// //                   padding: const EdgeInsets.symmetric(vertical: 8),
// //                   itemCount: _historyList.length,
// //                   itemBuilder: (context, index) {
// //                     final item = _historyList[index];
// //                     final actionType = item['action_type'] ?? '';

// //                     return Card(
// //                       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //                       elevation: 2,
// //                       child: InkWell(
// //                         borderRadius: BorderRadius.circular(12),
// //                         onTap: () {
// //                           Navigator.push(
// //                             context,
// //                             MaterialPageRoute(
// //                               builder: (context) => HistoryDetailScreen(item: item),
// //                             ),
// //                           );
// //                         },
// //                         child: Padding(
// //                           padding: const EdgeInsets.all(12),
// //                           child: Row(
// //                             children: [
// //                               ClipRRect(
// //                                 borderRadius: BorderRadius.circular(8),
// //                                 child: item['image_url'] != null
// //                                     ? Image.network(
// //                                         item['image_url'],
// //                                         width: 65,
// //                                         height: 65,
// //                                         fit: BoxFit.cover,
// //                                         errorBuilder: (context, error, stackTrace) =>
// //                                             Container(width: 65, height: 65, color: Colors.grey.shade300, child: const Icon(Icons.broken_image)),
// //                                       )
// //                                     : Container(width: 65, height: 65, color: Colors.grey.shade300, child: const Icon(Icons.image)),
// //                               ),
// //                               const SizedBox(width: 14),
// //                               Expanded(
// //                                 child: Column(
// //                                   crossAxisAlignment: CrossAxisAlignment.start,
// //                                   children: [
// //                                     Row(
// //                                       children: [
// //                                         Container(
// //                                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
// //                                           decoration: BoxDecoration(
// //                                             color: Colors.deepPurple.shade50,
// //                                             borderRadius: BorderRadius.circular(6),
// //                                           ),
// //                                           child: Text(
// //                                             item['category'] ?? '미분류',
// //                                             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepPurple),
// //                                           ),
// //                                         ),
// //                                         const Spacer(),
// //                                         if (actionType.contains('일정') || actionType.contains('캘린더'))
// //                                           const Icon(Icons.calendar_month, size: 18, color: Colors.blueAccent)
// //                                         else if (actionType.contains('지도') || actionType.contains('매핑'))
// //                                           const Icon(Icons.location_on, size: 18, color: Colors.redAccent)
// //                                         else if (actionType.contains('링크'))
// //                                           const Icon(Icons.link, size: 18, color: Colors.orangeAccent),
// //                                       ],
// //                                     ),
// //                                     const SizedBox(height: 6),
// //                                     Text(
// //                                       item['summary'] ?? '요약 내용 없음',
// //                                       maxLines: 2,
// //                                       overflow: TextOverflow.ellipsis,
// //                                       style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ),
// //                               const Icon(Icons.chevron_right, color: Colors.grey),
// //                             ],
// //                           ),
// //                         ),
// //                       ),
// //                     );
// //                   },
// //                 ),
// //     );
// //   }
// // }

// // // -------------------------------------------------------------
// // // 4. 히스토리 상세 화면
// // // -------------------------------------------------------------
// // class HistoryDetailScreen extends StatelessWidget {
// //   final Map<String, dynamic> item;

// //   const HistoryDetailScreen({super.key, required this.item});

// //   Future<void> _openNaverMap(String addressQuery) async {
// //     final query = addressQuery.trim();
// //     if (query.isEmpty) return;

// //     final encodedQuery = Uri.encodeComponent(query);
// //     final url = Uri.parse('https://m.map.naver.com/search2/search.naver?query=$encodedQuery');
// //     if (await canLaunchUrl(url)) {
// //       await launchUrl(url, mode: LaunchMode.externalApplication);
// //     }
// //   }

// //   Future<void> _openBrowserUrl(String rawUrl) async {
// //     var cleanUrl = rawUrl.trim();
// //     if (cleanUrl.isEmpty) return;

// //     if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
// //       cleanUrl = 'https://$cleanUrl';
// //     }

// //     final url = Uri.parse(cleanUrl);
// //     if (await canLaunchUrl(url)) {
// //       await launchUrl(url, mode: LaunchMode.externalApplication);
// //     }
// //   }

// //   String _resolveSearchTarget() {
// //     final actionData = item['action_data']?.toString().trim() ?? '';
// //     if (actionData.isNotEmpty) return actionData;

// //     if (item['places'] is List && (item['places'] as List).isNotEmpty) {
// //       final firstPlace = item['places'][0];
// //       if (firstPlace is Map) {
// //         final address = firstPlace['address']?.toString().trim() ?? '';
// //         if (address.isNotEmpty) return address;

// //         final placeName = firstPlace['place_name']?.toString().trim() ?? '';
// //         if (placeName.isNotEmpty) return placeName;
// //       }
// //     }

// //     return item['summary']?.toString().trim() ?? '';
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final actionType = item['action_type'] ?? '해당없음';
// //     final isCalendarAction = actionType.contains('일정') || actionType.contains('캘린더');
// //     final isMapAction = actionType.contains('지도') || actionType.contains('매핑');
// //     final isLinkAction = actionType.contains('링크') || actionType.contains('웹');

// //     final searchTarget = _resolveSearchTarget();
// //     final rawActionData = item['action_data']?.toString().trim() ?? '';
// //     final isUrl = isLinkAction || searchTarget.startsWith('http://') || searchTarget.startsWith('https://') || searchTarget.contains('.com') || searchTarget.contains('.kr');

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('분석 상세 정보'),
// //       ),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             if (item['image_url'] != null)
// //               ClipRRect(
// //                 borderRadius: BorderRadius.circular(12),
// //                 child: Image.network(
// //                   item['image_url'],
// //                   width: double.infinity,
// //                   height: 260,
// //                   fit: BoxFit.contain,
// //                   errorBuilder: (context, error, stackTrace) =>
// //                       Container(height: 180, color: Colors.grey.shade200, child: const Center(child: Icon(Icons.broken_image, size: 48))),
// //                 ),
// //               ),
// //             const SizedBox(height: 16),

// //             if (isMapAction && !isUrl)
// //               Card(
// //                 color: Colors.green.shade50,
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(12),
// //                   side: BorderSide(color: Colors.green.shade200),
// //                 ),
// //                 margin: const EdgeInsets.only(bottom: 16),
// //                 child: Padding(
// //                   padding: const EdgeInsets.all(16),
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       const Row(
// //                         children: [
// //                           Icon(Icons.location_on, color: Colors.green),
// //                           SizedBox(width: 8),
// //                           Text('지도 검색 위치 (도로명 주소/상호명)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 8),
// //                       Text(
// //                         searchTarget.isNotEmpty ? searchTarget : '등록된 주소 정보가 없습니다.',
// //                         style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
// //                       ),
// //                       const SizedBox(height: 12),
// //                       ElevatedButton.icon(
// //                         onPressed: searchTarget.isNotEmpty ? () => _openNaverMap(searchTarget) : null,
// //                         icon: const Icon(Icons.map_outlined, color: Colors.white),
// //                         label: const Text('네이버 지도에서 위치 확인', style: TextStyle(color: Colors.white)),
// //                         style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF03C75A)),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),

// //             if (isCalendarAction)
// //               Container(
// //                 margin: const EdgeInsets.only(bottom: 16),
// //                 padding: const EdgeInsets.all(12),
// //                 decoration: BoxDecoration(
// //                   color: Colors.blue.shade50,
// //                   borderRadius: BorderRadius.circular(8),
// //                   border: Border.all(color: Colors.blue.shade200),
// //                 ),
// //                 child: const Row(
// //                   children: [
// //                     Icon(Icons.event_available, color: Colors.blue),
// //                     SizedBox(width: 8),
// //                     Expanded(
// //                       child: Text('캘린더 일정으로 등록된 항목입니다.', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
// //                     ),
// //                   ],
// //                 ),
// //               ),

// //             Card(
// //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //               child: Padding(
// //                 padding: const EdgeInsets.all(16),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     _buildInfoRow('카테고리', item['category'] ?? '-'),
// //                     const Divider(height: 24),
// //                     _buildInfoRow('액션 분류', actionType),
// //                     const Divider(height: 24),
// //                     _buildInfoRow('요약 내용', item['summary'] ?? '-'),
// //                     if (searchTarget.isNotEmpty) ...[
// //                       const Divider(height: 24),
// //                       if (actionType.contains('링크') || searchTarget.startsWith('http'))
// //                         _buildHyperlinkRow('바로가기 링크', searchTarget, () => _openBrowserUrl(searchTarget))
// //                       else
// //                         _buildInfoRow('검색 주소 / 장소', searchTarget),
// //                     ] else if (rawActionData.isNotEmpty) ...[
// //                       const Divider(height: 24),
// //                       if (rawActionData.startsWith('http'))
// //                         _buildHyperlinkRow('바로가기 링크', rawActionData, () => _openBrowserUrl(rawActionData))
// //                       else
// //                         _buildInfoRow('상세 데이터', rawActionData),
// //                     ],
// //                     if (item['created_at'] != null) ...[
// //                       const Divider(height: 24),
// //                       _buildInfoRow('분석 일시', item['created_at'].toString().split('.')[0].replaceAll('T', ' ')),
// //                     ],
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildInfoRow(String label, String value) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
// //         const SizedBox(height: 4),
// //         Text(value, style: const TextStyle(fontSize: 15, height: 1.4)),
// //       ],
// //     );
// //   }

// //   Widget _buildHyperlinkRow(String label, String urlText, VoidCallback onTap) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
// //         const SizedBox(height: 4),
// //         InkWell(
// //           onTap: onTap,
// //           borderRadius: BorderRadius.circular(4),
// //           child: Padding(
// //             padding: const EdgeInsets.symmetric(vertical: 2),
// //             child: Row(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 Flexible(
// //                   child: Text(
// //                     urlText,
// //                     style: const TextStyle(
// //                       fontSize: 15,
// //                       height: 1.4,
// //                       color: Colors.blueAccent,
// //                       fontWeight: FontWeight.w600,
// //                       decoration: TextDecoration.underline,
// //                       decorationColor: Colors.blueAccent,
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(width: 6),
// //                 const Icon(Icons.open_in_new, size: 16, color: Colors.blueAccent),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }

// // // import 'dart:convert';
// // // import 'dart:io';
// // // import 'package:flutter/material.dart';
// // // import 'package:http/http.dart' as http;
// // // import 'package:http_parser/http_parser.dart';
// // // import 'package:image_picker/image_picker.dart';
// // // import 'package:table_calendar/table_calendar.dart';
// // // import 'package:url_launcher/url_launcher.dart';

// // // // 로컬 환경에 맞게 서버 IP/포트 설정 (안드로이드 에뮬레이터 기준 10.0.2.2:8000, 실제 기기는 PC IP 입력)
// // // const String baseUrl = "http://10.0.2.2:8000";

// // // void main() {
// // //   runApp(const MyApp());
// // // }

// // // class MyApp extends StatelessWidget {
// // //   const MyApp({super.key});

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return MaterialApp(
// // //       title: 'T.Salmon',
// // //       theme: ThemeData(
// // //         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
// // //         useMaterial3: true,
// // //       ),
// // //       home: const MainNavigationScreen(),
// // //     );
// // //   }
// // // }

// // // class MainNavigationScreen extends StatefulWidget {
// // //   const MainNavigationScreen({super.key});

// // //   @override
// // //   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// // // }

// // // class _MainNavigationScreenState extends State<MainNavigationScreen> {
// // //   int _currentIndex = 0;

// // //   final List<Widget> _screens = const [
// // //     UploadScreen(),
// // //     CalendarScreen(),
// // //     HistoryScreen(),
// // //   ];

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       body: _screens[_currentIndex],
// // //       bottomNavigationBar: NavigationBar(
// // //         selectedIndex: _currentIndex,
// // //         onDestinationSelected: (index) => setState(() => _currentIndex = index),
// // //         destinations: const [
// // //           NavigationDestination(
// // //             icon: Icon(Icons.cloud_upload_outlined),
// // //             selectedIcon: Icon(Icons.cloud_upload),
// // //             label: '업로드',
// // //           ),
// // //           NavigationDestination(
// // //             icon: Icon(Icons.calendar_month_outlined),
// // //             selectedIcon: Icon(Icons.calendar_month),
// // //             label: '캘린더',
// // //           ),
// // //           NavigationDestination(
// // //             icon: Icon(Icons.history_outlined),
// // //             selectedIcon: Icon(Icons.history),
// // //             label: '히스토리',
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }

// // // // -------------------------------------------------------------
// // // // 1. 업로드 탭 (화질 저하 방지 & MIME Type 명시 적용)
// // // // -------------------------------------------------------------
// // // class UploadScreen extends StatefulWidget {
// // //   const UploadScreen({super.key});

// // //   @override
// // //   State<UploadScreen> createState() => _UploadScreenState();
// // // }

// // // class _UploadScreenState extends State<UploadScreen> {
// // //   File? _selectedImage;
// // //   bool _isLoading = false;
// // //   Map<String, dynamic>? _analysisResult;

// // //   final ImagePicker _picker = ImagePicker();

// // //   Future<void> _pickAndUploadImage() async {
// // //     final pickedFile = await _picker.pickImage(
// // //       source: ImageSource.gallery,
// // //       imageQuality: 100,
// // //       maxWidth: null,
// // //       maxHeight: null,
// // //     );
// // //     if (pickedFile == null) return;

// // //     if (!mounted) return;
// // //     setState(() {
// // //       _selectedImage = File(pickedFile.path);
// // //       _isLoading = true;
// // //       _analysisResult = null;
// // //     });

// // //     try {
// // //       final uri = Uri.parse('$baseUrl/api/v1/analyze');
// // //       final request = http.MultipartRequest('POST', uri);

// // //       final ext = pickedFile.path.split('.').last.toLowerCase();
// // //       final mimeType = (ext == 'png') ? 'image/png' : 'image/jpeg';

// // //       request.files.add(await http.MultipartFile.fromPath(
// // //         'file',
// // //         pickedFile.path,
// // //         contentType: MediaType.parse(mimeType),
// // //       ));

// // //       final streamedResponse = await request.send();
// // //       final response = await http.Response.fromStream(streamedResponse);

// // //       if (response.statusCode == 200) {
// // //         final decoded = jsonDecode(utf8.decode(response.bodyBytes));
// // //         if (mounted) {
// // //           setState(() {
// // //             _analysisResult = decoded['analysis'];
// // //           });
// // //           ScaffoldMessenger.of(context).showSnackBar(
// // //             const SnackBar(content: Text('분석 및 저장이 완료되었습니다!')),
// // //           );
// // //         }
// // //       } else {
// // //         throw Exception('서버 응답 오류: ${response.statusCode}');
// // //       }
// // //     } catch (e) {
// // //       if (mounted) {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           SnackBar(content: Text('업로드 실패: $e')),
// // //         );
// // //       }
// // //     } finally {
// // //       if (mounted) {
// // //         setState(() => _isLoading = false);
// // //       }
// // //     }
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: const Text('스크린샷 분석')),
// // //       body: SingleChildScrollView(
// // //         padding: const EdgeInsets.all(16),
// // //         child: Column(
// // //           children: [
// // //             if (_selectedImage != null)
// // //               ClipRRect(
// // //                 borderRadius: BorderRadius.circular(12),
// // //                 child: Image.file(_selectedImage!, height: 260, fit: BoxFit.cover),
// // //               )
// // //             else
// // //               Container(
// // //                 height: 200,
// // //                 decoration: BoxDecoration(
// // //                   color: Colors.grey.shade200,
// // //                   borderRadius: BorderRadius.circular(12),
// // //                 ),
// // //                 child: const Center(child: Text('분석할 스크린샷을 선택하세요')),
// // //               ),
// // //             const SizedBox(height: 20),
// // //             ElevatedButton.icon(
// // //               onPressed: _isLoading ? null : _pickAndUploadImage,
// // //               icon: const Icon(Icons.photo_library),
// // //               label: Text(_isLoading ? '분석 중...' : '갤러리에서 선택 및 분석'),
// // //               style: ElevatedButton.styleFrom(
// // //                 minimumSize: const Size.fromHeight(50),
// // //               ),
// // //             ),
// // //             const SizedBox(height: 24),
// // //             if (_isLoading)
// // //               const CircularProgressIndicator()
// // //             else if (_analysisResult != null) ...[
// // //               const Align(
// // //                 alignment: Alignment.centerLeft,
// // //                 child: Text('분석 결과', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // //               ),
// // //               const SizedBox(height: 8),
// // //               Card(
// // //                 child: Padding(
// // //                   padding: const EdgeInsets.all(16),
// // //                   child: Column(
// // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // //                     children: [
// // //                       Text('카테고리: ${_analysisResult?['category'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold)),
// // //                       const SizedBox(height: 6),
// // //                       Text('액션 타입: ${_analysisResult?['action_type'] ?? '-'}'),
// // //                       const SizedBox(height: 6),
// // //                       Text('요약: ${_analysisResult?['summary'] ?? '-'}'),
// // //                       if (_analysisResult?['action_data'] != null && _analysisResult?['action_data'] != "") ...[
// // //                         const SizedBox(height: 6),
// // //                         Text('상세: ${_analysisResult?['action_data']}'),
// // //                       ],
// // //                     ],
// // //                   ),
// // //                 ),
// // //               ),
// // //             ],
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }

// // // // -------------------------------------------------------------
// // // // 2. 캘린더 탭 (/api/v1/calendar/ 연동 및 날짜별 로컬 매핑)
// // // // -------------------------------------------------------------
// // // class CalendarScreen extends StatefulWidget {
// // //   const CalendarScreen({super.key});

// // //   @override
// // //   State<CalendarScreen> createState() => _CalendarScreenState();
// // // }

// // // class _CalendarScreenState extends State<CalendarScreen> {
// // //   CalendarFormat _calendarFormat = CalendarFormat.month;
// // //   DateTime _focusedDay = DateTime.now();
// // //   DateTime? _selectedDay;

// // //   Map<DateTime, List<dynamic>> _eventsMap = {};
// // //   bool _isLoading = true;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _selectedDay = _focusedDay;
// // //     _fetchCalendarEvents();
// // //   }

// // //   DateTime _normalizeDate(DateTime dt) {
// // //     return DateTime(dt.year, dt.month, dt.day);
// // //   }

// // //   Future<void> _fetchCalendarEvents() async {
// // //     if (!mounted) return;
// // //     setState(() => _isLoading = true);

// // //     try {
// // //       final response = await http.get(Uri.parse('$baseUrl/api/v1/calendar/'));
// // //       if (response.statusCode == 200 && mounted) {
// // //         final data = jsonDecode(utf8.decode(response.bodyBytes));
// // //         final List<dynamic> rawEvents = data['events'] ?? [];

// // //         final Map<DateTime, List<dynamic>> newMap = {};
// // //         for (var item in rawEvents) {
// // //           final dateStr = item['event_date'];
// // //           if (dateStr != null) {
// // //             try {
// // //               final parts = dateStr.toString().substring(0, 10).split('-');
// // //               final key = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
// // //               if (newMap[key] == null) {
// // //                 newMap[key] = [];
// // //               }
// // //               newMap[key]!.add(item);
// // //             } catch (_) {}
// // //           }
// // //         }

// // //         setState(() {
// // //           _eventsMap = newMap;
// // //         });
// // //       }
// // //     } catch (e) {
// // //       // 에러 핸들링
// // //     } finally {
// // //       if (mounted) {
// // //         setState(() => _isLoading = false);
// // //       }
// // //     }
// // //   }

// // //   List<dynamic> _getEventsForDay(DateTime day) {
// // //     return _eventsMap[_normalizeDate(day)] ?? [];
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final selectedEvents = _selectedDay != null ? _getEventsForDay(_selectedDay!) : [];

// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: const Text('등록된 일정'),
// // //         actions: [
// // //           IconButton(onPressed: _fetchCalendarEvents, icon: const Icon(Icons.refresh)),
// // //         ],
// // //       ),
// // //       body: _isLoading
// // //           ? const Center(child: CircularProgressIndicator())
// // //           : Column(
// // //               children: [
// // //                 TableCalendar(
// // //                   firstDay: DateTime.utc(2020, 1, 1),
// // //                   lastDay: DateTime.utc(2030, 12, 31),
// // //                   focusedDay: _focusedDay,
// // //                   calendarFormat: _calendarFormat,
// // //                   selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
// // //                   eventLoader: _getEventsForDay,
// // //                   onDaySelected: (selectedDay, focusedDay) {
// // //                     if (!mounted) return;
// // //                     setState(() {
// // //                       _selectedDay = selectedDay;
// // //                       _focusedDay = focusedDay;
// // //                     });
// // //                   },
// // //                   onFormatChanged: (format) {
// // //                     if (!mounted) return;
// // //                     setState(() => _calendarFormat = format);
// // //                   },
// // //                   calendarStyle: const CalendarStyle(
// // //                     markerDecoration: BoxDecoration(
// // //                       color: Colors.deepPurple,
// // //                       shape: BoxShape.circle,
// // //                     ),
// // //                   ),
// // //                 ),
// // //                 const Divider(),
// // //                 Expanded(
// // //                   child: selectedEvents.isEmpty
// // //                       ? const Center(child: Text('해당 날짜에 등록된 일정이 없습니다.'))
// // //                       : ListView.builder(
// // //                           itemCount: selectedEvents.length,
// // //                           itemBuilder: (context, index) {
// // //                             final item = selectedEvents[index];
// // //                             return Card(
// // //                               margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
// // //                               child: ListTile(
// // //                                 leading: const Icon(Icons.event, color: Colors.deepPurple),
// // //                                 title: Text(item['title'] ?? '일정 제목 없음', style: const TextStyle(fontWeight: FontWeight.bold)),
// // //                                 subtitle: Text('날짜: ${item['event_date']}'),
// // //                                 trailing: item['image_url'] != null
// // //                                     ? ClipRRect(
// // //                                         borderRadius: BorderRadius.circular(6),
// // //                                         child: Image.network(
// // //                                           item['image_url'],
// // //                                           width: 45,
// // //                                           height: 45,
// // //                                           fit: BoxFit.cover,
// // //                                           errorBuilder: (context, error, stackTrace) =>
// // //                                               const Icon(Icons.broken_image, size: 30),
// // //                                         ),
// // //                                       )
// // //                                     : null,
// // //                               ),
// // //                             );
// // //                           },
// // //                         ),
// // //                 ),
// // //               ],
// // //             ),
// // //     );
// // //   }
// // // }

// // // // -------------------------------------------------------------
// // // // 3. 히스토리 탭 (/api/v1/history/ 연동)
// // // // -------------------------------------------------------------
// // // class HistoryScreen extends StatefulWidget {
// // //   const HistoryScreen({super.key});

// // //   @override
// // //   State<HistoryScreen> createState() => _HistoryScreenState();
// // // }

// // // class _HistoryScreenState extends State<HistoryScreen> {
// // //   List<dynamic> _historyList = [];
// // //   bool _isLoading = true;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _fetchHistory();
// // //   }

// // //   Future<void> _fetchHistory() async {
// // //     if (!mounted) return;
// // //     setState(() => _isLoading = true);

// // //     try {
// // //       final response = await http.get(Uri.parse('$baseUrl/api/v1/history/'));
// // //       if (response.statusCode == 200 && mounted) {
// // //         final data = jsonDecode(utf8.decode(response.bodyBytes));
// // //         setState(() {
// // //           _historyList = data['history'] ?? [];
// // //         });
// // //       }
// // //     } catch (e) {
// // //       // 에러 핸들링
// // //     } finally {
// // //       if (mounted) {
// // //         setState(() => _isLoading = false);
// // //       }
// // //     }
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: const Text('분석 히스토리'),
// // //         actions: [
// // //           IconButton(onPressed: _fetchHistory, icon: const Icon(Icons.refresh)),
// // //         ],
// // //       ),
// // //       body: _isLoading
// // //           ? const Center(child: CircularProgressIndicator())
// // //           : _historyList.isEmpty
// // //               ? const Center(child: Text('히스토리가 없습니다.'))
// // //               : ListView.builder(
// // //                   padding: const EdgeInsets.symmetric(vertical: 8),
// // //                   itemCount: _historyList.length,
// // //                   itemBuilder: (context, index) {
// // //                     final item = _historyList[index];
// // //                     final actionType = item['action_type'] ?? '';

// // //                     return Card(
// // //                       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // //                       elevation: 2,
// // //                       child: InkWell(
// // //                         borderRadius: BorderRadius.circular(12),
// // //                         onTap: () {
// // //                           Navigator.push(
// // //                             context,
// // //                             MaterialPageRoute(
// // //                               builder: (context) => HistoryDetailScreen(item: item),
// // //                             ),
// // //                           );
// // //                         },
// // //                         child: Padding(
// // //                           padding: const EdgeInsets.all(12),
// // //                           child: Row(
// // //                             children: [
// // //                               ClipRRect(
// // //                                 borderRadius: BorderRadius.circular(8),
// // //                                 child: item['image_url'] != null
// // //                                     ? Image.network(
// // //                                         item['image_url'],
// // //                                         width: 65,
// // //                                         height: 65,
// // //                                         fit: BoxFit.cover,
// // //                                         errorBuilder: (context, error, stackTrace) =>
// // //                                             Container(width: 65, height: 65, color: Colors.grey.shade300, child: const Icon(Icons.broken_image)),
// // //                                       )
// // //                                     : Container(width: 65, height: 65, color: Colors.grey.shade300, child: const Icon(Icons.image)),
// // //                               ),
// // //                               const SizedBox(width: 14),
// // //                               Expanded(
// // //                                 child: Column(
// // //                                   crossAxisAlignment: CrossAxisAlignment.start,
// // //                                   children: [
// // //                                     Row(
// // //                                       children: [
// // //                                         Container(
// // //                                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
// // //                                           decoration: BoxDecoration(
// // //                                             color: Colors.deepPurple.shade50,
// // //                                             borderRadius: BorderRadius.circular(6),
// // //                                           ),
// // //                                           child: Text(
// // //                                             item['category'] ?? '미분류',
// // //                                             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepPurple),
// // //                                           ),
// // //                                         ),
// // //                                         const Spacer(),
// // //                                         if (actionType.contains('일정') || actionType.contains('캘린더'))
// // //                                           const Icon(Icons.calendar_month, size: 18, color: Colors.blueAccent)
// // //                                         else if (actionType.contains('지도') || actionType.contains('매핑'))
// // //                                           const Icon(Icons.location_on, size: 18, color: Colors.redAccent)
// // //                                         else if (actionType.contains('링크'))
// // //                                           const Icon(Icons.link, size: 18, color: Colors.orangeAccent),
// // //                                       ],
// // //                                     ),
// // //                                     const SizedBox(height: 6),
// // //                                     Text(
// // //                                       item['summary'] ?? '요약 내용 없음',
// // //                                       maxLines: 2,
// // //                                       overflow: TextOverflow.ellipsis,
// // //                                       style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
// // //                                     ),
// // //                                   ],
// // //                                 ),
// // //                               ),
// // //                               const Icon(Icons.chevron_right, color: Colors.grey),
// // //                             ],
// // //                           ),
// // //                         ),
// // //                       ),
// // //                     );
// // //                   },
// // //                 ),
// // //     );
// // //   }
// // // }

// // // // -------------------------------------------------------------
// // // // 4. 히스토리 상세 화면 (텍스트 하이퍼링크 직접 터치 지원)
// // // // -------------------------------------------------------------
// // // class HistoryDetailScreen extends StatelessWidget {
// // //   final Map<String, dynamic> item;

// // //   const HistoryDetailScreen({super.key, required this.item});

// // //   Future<void> _openNaverMap(String addressQuery) async {
// // //     final query = addressQuery.trim();
// // //     if (query.isEmpty) return;

// // //     final encodedQuery = Uri.encodeComponent(query);
// // //     final url = Uri.parse('https://m.map.naver.com/search2/search.naver?query=$encodedQuery');
// // //     if (await canLaunchUrl(url)) {
// // //       await launchUrl(url, mode: LaunchMode.externalApplication);
// // //     }
// // //   }

// // //   Future<void> _openBrowserUrl(String rawUrl) async {
// // //     var cleanUrl = rawUrl.trim();
// // //     if (cleanUrl.isEmpty) return;

// // //     if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
// // //       cleanUrl = 'https://$cleanUrl';
// // //     }

// // //     final url = Uri.parse(cleanUrl);
// // //     if (await canLaunchUrl(url)) {
// // //       await launchUrl(url, mode: LaunchMode.externalApplication);
// // //     }
// // //   }

// // //   String _resolveSearchTarget() {
// // //     final actionData = item['action_data']?.toString().trim() ?? '';
// // //     if (actionData.isNotEmpty) return actionData;

// // //     if (item['places'] is List && (item['places'] as List).isNotEmpty) {
// // //       final firstPlace = item['places'][0];
// // //       if (firstPlace is Map) {
// // //         final address = firstPlace['address']?.toString().trim() ?? '';
// // //         if (address.isNotEmpty) return address;

// // //         final placeName = firstPlace['place_name']?.toString().trim() ?? '';
// // //         if (placeName.isNotEmpty) return placeName;
// // //       }
// // //     }

// // //     return item['summary']?.toString().trim() ?? '';
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final actionType = item['action_type'] ?? '해당없음';
// // //     final isCalendarAction = actionType.contains('일정') || actionType.contains('캘린더');
// // //     final isMapAction = actionType.contains('지도') || actionType.contains('매핑');
// // //     final isLinkAction = actionType.contains('링크') || actionType.contains('웹');

// // //     final searchTarget = _resolveSearchTarget();
// // //     final rawActionData = item['action_data']?.toString().trim() ?? '';

// // //     // 링크인지 확인 (action_type이 링크이거나 URL 형식인 경우)
// // //     final isUrl = isLinkAction || searchTarget.startsWith('http://') || searchTarget.startsWith('https://') || searchTarget.contains('.com') || searchTarget.contains('.kr') || searchTarget.contains('.net');

// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: const Text('분석 상세 정보'),
// // //       ),
// // //       body: SingleChildScrollView(
// // //         padding: const EdgeInsets.all(16),
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           children: [
// // //             if (item['image_url'] != null)
// // //               ClipRRect(
// // //                 borderRadius: BorderRadius.circular(12),
// // //                 child: Image.network(
// // //                   item['image_url'],
// // //                   width: double.infinity,
// // //                   height: 260,
// // //                   fit: BoxFit.contain,
// // //                   errorBuilder: (context, error, stackTrace) =>
// // //                       Container(height: 180, color: Colors.grey.shade200, child: const Center(child: Icon(Icons.broken_image, size: 48))),
// // //                 ),
// // //               ),
// // //             const SizedBox(height: 16),

// // //             // 1. 네이버 지도 검색 연동 카드 (지도 액션일 때만 노출)
// // //             if (isMapAction && !isUrl)
// // //               Card(
// // //                 color: Colors.green.shade50,
// // //                 shape: RoundedRectangleBorder(
// // //                   borderRadius: BorderRadius.circular(12),
// // //                   side: BorderSide(color: Colors.green.shade200),
// // //                 ),
// // //                 margin: const EdgeInsets.only(bottom: 16),
// // //                 child: Padding(
// // //                   padding: const EdgeInsets.all(16),
// // //                   child: Column(
// // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // //                     children: [
// // //                       const Row(
// // //                         children: [
// // //                           Icon(Icons.location_on, color: Colors.green),
// // //                           SizedBox(width: 8),
// // //                           Text('지도 검색 위치 (도로명 주소/상호명)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
// // //                         ],
// // //                       ),
// // //                       const SizedBox(height: 8),
// // //                       Text(
// // //                         searchTarget.isNotEmpty ? searchTarget : '등록된 주소 정보가 없습니다.',
// // //                         style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
// // //                       ),
// // //                       const SizedBox(height: 12),
// // //                       ElevatedButton.icon(
// // //                         onPressed: searchTarget.isNotEmpty ? () => _openNaverMap(searchTarget) : null,
// // //                         icon: const Icon(Icons.map_outlined, color: Colors.white),
// // //                         label: const Text('네이버 지도에서 위치 확인', style: TextStyle(color: Colors.white)),
// // //                         style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF03C75A)),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //               ),

// // //             // 2. 캘린더 등록 알림 섹션
// // //             if (isCalendarAction)
// // //               Container(
// // //                 margin: const EdgeInsets.only(bottom: 16),
// // //                 padding: const EdgeInsets.all(12),
// // //                 decoration: BoxDecoration(
// // //                   color: Colors.blue.shade50,
// // //                   borderRadius: BorderRadius.circular(8),
// // //                   border: Border.all(color: Colors.blue.shade200),
// // //                 ),
// // //                 child: const Row(
// // //                   children: [
// // //                     Icon(Icons.event_available, color: Colors.blue),
// // //                     SizedBox(width: 8),
// // //                     Expanded(
// // //                       child: Text('캘린더 일정으로 등록된 항목입니다.', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ),

// // //             // 3. 요약 정보 카드 (내부 링크는 파란색 클릭 가능 하이퍼링크로 렌더링)
// // //             Card(
// // //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // //               child: Padding(
// // //                 padding: const EdgeInsets.all(16),
// // //                 child: Column(
// // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // //                   children: [
// // //                     _buildInfoRow('카테고리', item['category'] ?? '-'),
// // //                     const Divider(height: 24),
// // //                     _buildInfoRow('액션 분류', actionType),
// // //                     const Divider(height: 24),
// // //                     _buildInfoRow('요약 내용', item['summary'] ?? '-'),
                    
// // //                     // URL 링크 또는 지도 주소 항목
// // //                     if (searchTarget.isNotEmpty) ...[
// // //                       const Divider(height: 24),
// // //                       if (isUrl)
// // //                         _buildHyperlinkRow('바로가기 링크', searchTarget, () => _openBrowserUrl(searchTarget))
// // //                       else
// // //                         _buildInfoRow('검색 주소 / 장소', searchTarget),
// // //                     ] else if (rawActionData.isNotEmpty) ...[
// // //                       const Divider(height: 24),
// // //                       if (rawActionData.startsWith('http') || rawActionData.contains('.'))
// // //                         _buildHyperlinkRow('바로가기 링크', rawActionData, () => _openBrowserUrl(rawActionData))
// // //                       else
// // //                         _buildInfoRow('상세 데이터', rawActionData),
// // //                     ],

// // //                     if (item['created_at'] != null) ...[
// // //                       const Divider(height: 24),
// // //                       _buildInfoRow('분석 일시', item['created_at'].toString().split('.')[0].replaceAll('T', ' ')),
// // //                     ],
// // //                   ],
// // //                 ),
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // 일반 텍스트 정보 행
// // //   Widget _buildInfoRow(String label, String value) {
// // //     return Column(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
// // //         const SizedBox(height: 4),
// // //         Text(value, style: const TextStyle(fontSize: 15, height: 1.4)),
// // //       ],
// // //     );
// // //   }

// // //   // 클릭 가능한 파란색 하이퍼링크 행
// // //   Widget _buildHyperlinkRow(String label, String urlText, VoidCallback onTap) {
// // //     return Column(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
// // //         const SizedBox(height: 4),
// // //         InkWell(
// // //           onTap: onTap,
// // //           borderRadius: BorderRadius.circular(4),
// // //           child: Padding(
// // //             padding: const EdgeInsets.symmetric(vertical: 2),
// // //             child: Row(
// // //               mainAxisSize: MainAxisSize.min,
// // //               children: [
// // //                 Flexible(
// // //                   child: Text(
// // //                     urlText,
// // //                     style: const TextStyle(
// // //                       fontSize: 15,
// // //                       height: 1.4,
// // //                       color: Colors.blueAccent,
// // //                       fontWeight: FontWeight.w600,
// // //                       decoration: TextDecoration.underline,
// // //                       decorationColor: Colors.blueAccent,
// // //                     ),
// // //                   ),
// // //                 ),
// // //                 const SizedBox(width: 6),
// // //                 const Icon(Icons.open_in_new, size: 16, color: Colors.blueAccent),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }
// // // }

// // // // import 'dart:convert';
// // // // import 'dart:io';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:http/http.dart' as http;
// // // // import 'package:http_parser/http_parser.dart'; // 👈 MIME Type 지정을 위해 추가
// // // // import 'package:image_picker/image_picker.dart';
// // // // import 'package:table_calendar/table_calendar.dart';
// // // // import 'package:url_launcher/url_launcher.dart';

// // // // // 로컬 환경에 맞게 서버 IP/포트 설정 (안드로이드 에뮬레이터 기준 10.0.2.2:8000, 실제 기기는 PC IP 입력)
// // // // const String baseUrl = "http://10.0.2.2:8000";

// // // // void main() {
// // // //   runApp(const MyApp());
// // // // }

// // // // class MyApp extends StatelessWidget {
// // // //   const MyApp({super.key});

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return MaterialApp(
// // // //       title: 'T.Salmon',
// // // //       theme: ThemeData(
// // // //         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
// // // //         useMaterial3: true,
// // // //       ),
// // // //       home: const MainNavigationScreen(),
// // // //     );
// // // //   }
// // // // }

// // // // class MainNavigationScreen extends StatefulWidget {
// // // //   const MainNavigationScreen({super.key});

// // // //   @override
// // // //   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// // // // }

// // // // class _MainNavigationScreenState extends State<MainNavigationScreen> {
// // // //   int _currentIndex = 0;

// // // //   final List<Widget> _screens = const [
// // // //     UploadScreen(),
// // // //     CalendarScreen(),
// // // //     HistoryScreen(),
// // // //   ];

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       body: _screens[_currentIndex],
// // // //       bottomNavigationBar: NavigationBar(
// // // //         selectedIndex: _currentIndex,
// // // //         onDestinationSelected: (index) => setState(() => _currentIndex = index),
// // // //         destinations: const [
// // // //           NavigationDestination(
// // // //             icon: Icon(Icons.cloud_upload_outlined),
// // // //             selectedIcon: Icon(Icons.cloud_upload),
// // // //             label: '업로드',
// // // //           ),
// // // //           NavigationDestination(
// // // //             icon: Icon(Icons.calendar_month_outlined),
// // // //             selectedIcon: Icon(Icons.calendar_month),
// // // //             label: '캘린더',
// // // //           ),
// // // //           NavigationDestination(
// // // //             icon: Icon(Icons.history_outlined),
// // // //             selectedIcon: Icon(Icons.history),
// // // //             label: '히스토리',
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // // -------------------------------------------------------------
// // // // // 1. 업로드 탭 (화질 저하 방지 & MIME Type 명시 적용)
// // // // // -------------------------------------------------------------
// // // // class UploadScreen extends StatefulWidget {
// // // //   const UploadScreen({super.key});

// // // //   @override
// // // //   State<UploadScreen> createState() => _UploadScreenState();
// // // // }

// // // // class _UploadScreenState extends State<UploadScreen> {
// // // //   File? _selectedImage;
// // // //   bool _isLoading = false;
// // // //   Map<String, dynamic>? _analysisResult;

// // // //   final ImagePicker _picker = ImagePicker();

// // // //   Future<void> _pickAndUploadImage() async {
// // // //     // 1. 이미지 원본 화질 유지 옵션 적용
// // // //     final pickedFile = await _picker.pickImage(
// // // //       source: ImageSource.gallery,
// // // //       imageQuality: 100,
// // // //       maxWidth: null,
// // // //       maxHeight: null,
// // // //     );
// // // //     if (pickedFile == null) return;

// // // //     if (!mounted) return;
// // // //     setState(() {
// // // //       _selectedImage = File(pickedFile.path);
// // // //       _isLoading = true;
// // // //       _analysisResult = null;
// // // //     });

// // // //     try {
// // // //       final uri = Uri.parse('$baseUrl/api/v1/analyze');
// // // //       final request = http.MultipartRequest('POST', uri);

// // // //       // 2. 확장자 기반으로 정확한 MIME Type 할당 (octet-stream 방지)
// // // //       final ext = pickedFile.path.split('.').last.toLowerCase();
// // // //       final mimeType = (ext == 'png') ? 'image/png' : 'image/jpeg';

// // // //       request.files.add(await http.MultipartFile.fromPath(
// // // //         'file', 
// // // //         pickedFile.path,
// // // //         contentType: MediaType.parse(mimeType), // 👈 명시적 Content-Type 주입
// // // //       ));

// // // //       final streamedResponse = await request.send();
// // // //       final response = await http.Response.fromStream(streamedResponse);

// // // //       if (response.statusCode == 200) {
// // // //         final decoded = jsonDecode(utf8.decode(response.bodyBytes));
// // // //         if (mounted) {
// // // //           setState(() {
// // // //             _analysisResult = decoded['analysis'];
// // // //           });
// // // //           ScaffoldMessenger.of(context).showSnackBar(
// // // //             const SnackBar(content: Text('분석 및 저장이 완료되었습니다!')),
// // // //           );
// // // //         }
// // // //       } else {
// // // //         throw Exception('서버 응답 오류: ${response.statusCode}');
// // // //       }
// // // //     } catch (e) {
// // // //       if (mounted) {
// // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // //           SnackBar(content: Text('업로드 실패: $e')),
// // // //         );
// // // //       }
// // // //     } finally {
// // // //       if (mounted) {
// // // //         setState(() => _isLoading = false);
// // // //       }
// // // //     }
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       appBar: AppBar(title: const Text('스크린샷 분석')),
// // // //       body: SingleChildScrollView(
// // // //         padding: const EdgeInsets.all(16),
// // // //         child: Column(
// // // //           children: [
// // // //             if (_selectedImage != null)
// // // //               ClipRRect(
// // // //                 borderRadius: BorderRadius.circular(12),
// // // //                 child: Image.file(_selectedImage!, height: 260, fit: BoxFit.cover),
// // // //               )
// // // //             else
// // // //               Container(
// // // //                 height: 200,
// // // //                 decoration: BoxDecoration(
// // // //                   color: Colors.grey.shade200,
// // // //                   borderRadius: BorderRadius.circular(12),
// // // //                 ),
// // // //                 child: const Center(child: Text('분석할 스크린샷을 선택하세요')),
// // // //               ),
// // // //             const SizedBox(height: 20),
// // // //             ElevatedButton.icon(
// // // //               onPressed: _isLoading ? null : _pickAndUploadImage,
// // // //               icon: const Icon(Icons.photo_library),
// // // //               label: Text(_isLoading ? '분석 중...' : '갤러리에서 선택 및 분석'),
// // // //               style: ElevatedButton.styleFrom(
// // // //                 minimumSize: const Size.fromHeight(50),
// // // //               ),
// // // //             ),
// // // //             const SizedBox(height: 24),
// // // //             if (_isLoading)
// // // //               const CircularProgressIndicator()
// // // //             else if (_analysisResult != null) ...[
// // // //               const Align(
// // // //                 alignment: Alignment.centerLeft,
// // // //                 child: Text('분석 결과', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // //               ),
// // // //               const SizedBox(height: 8),
// // // //               Card(
// // // //                 child: Padding(
// // // //                   padding: const EdgeInsets.all(16),
// // // //                   child: Column(
// // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // //                     children: [
// // // //                       Text('카테고리: ${_analysisResult?['category'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold)),
// // // //                       const SizedBox(height: 6),
// // // //                       Text('액션 타입: ${_analysisResult?['action_type'] ?? '-'}'),
// // // //                       const SizedBox(height: 6),
// // // //                       Text('요약: ${_analysisResult?['summary'] ?? '-'}'),
// // // //                       if (_analysisResult?['action_data'] != null && _analysisResult?['action_data'] != "") ...[
// // // //                         const SizedBox(height: 6),
// // // //                         Text('상세: ${_analysisResult?['action_data']}'),
// // // //                       ],
// // // //                     ],
// // // //                   ),
// // // //                 ),
// // // //               ),
// // // //             ],
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // // -------------------------------------------------------------
// // // // // 2. 캘린더 탭 (/api/v1/calendar/ 연동 및 날짜별 로컬 매핑)
// // // // // -------------------------------------------------------------
// // // // class CalendarScreen extends StatefulWidget {
// // // //   const CalendarScreen({super.key});

// // // //   @override
// // // //   State<CalendarScreen> createState() => _CalendarScreenState();
// // // // }

// // // // class _CalendarScreenState extends State<CalendarScreen> {
// // // //   CalendarFormat _calendarFormat = CalendarFormat.month;
// // // //   DateTime _focusedDay = DateTime.now();
// // // //   DateTime? _selectedDay;
  
// // // //   Map<DateTime, List<dynamic>> _eventsMap = {};
// // // //   bool _isLoading = true;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _selectedDay = _focusedDay;
// // // //     _fetchCalendarEvents();
// // // //   }

// // // //   DateTime _normalizeDate(DateTime dt) {
// // // //     return DateTime(dt.year, dt.month, dt.day);
// // // //   }

// // // //   Future<void> _fetchCalendarEvents() async {
// // // //     if (!mounted) return;
// // // //     setState(() => _isLoading = true);

// // // //     try {
// // // //       final response = await http.get(Uri.parse('$baseUrl/api/v1/calendar/'));
// // // //       if (response.statusCode == 200 && mounted) {
// // // //         final data = jsonDecode(utf8.decode(response.bodyBytes));
// // // //         final List<dynamic> rawEvents = data['events'] ?? [];

// // // //         final Map<DateTime, List<dynamic>> newMap = {};
// // // //         for (var item in rawEvents) {
// // // //           final dateStr = item['event_date'];
// // // //           if (dateStr != null) {
// // // //             try {
// // // //               final parts = dateStr.toString().substring(0, 10).split('-');
// // // //               final key = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
// // // //               if (newMap[key] == null) {
// // // //                 newMap[key] = [];
// // // //               }
// // // //               newMap[key]!.add(item);
// // // //             } catch (_) {}
// // // //           }
// // // //         }

// // // //         setState(() {
// // // //           _eventsMap = newMap;
// // // //         });
// // // //       }
// // // //     } catch (e) {
// // // //       // 에러 핸들링
// // // //     } finally {
// // // //       if (mounted) {
// // // //         setState(() => _isLoading = false);
// // // //       }
// // // //     }
// // // //   }

// // // //   List<dynamic> _getEventsForDay(DateTime day) {
// // // //     return _eventsMap[_normalizeDate(day)] ?? [];
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final selectedEvents = _selectedDay != null ? _getEventsForDay(_selectedDay!) : [];

// // // //     return Scaffold(
// // // //       appBar: AppBar(
// // // //         title: const Text('등록된 일정'),
// // // //         actions: [
// // // //           IconButton(onPressed: _fetchCalendarEvents, icon: const Icon(Icons.refresh)),
// // // //         ],
// // // //       ),
// // // //       body: _isLoading
// // // //           ? const Center(child: CircularProgressIndicator())
// // // //           : Column(
// // // //               children: [
// // // //                 TableCalendar(
// // // //                   firstDay: DateTime.utc(2020, 1, 1),
// // // //                   lastDay: DateTime.utc(2030, 12, 31),
// // // //                   focusedDay: _focusedDay,
// // // //                   calendarFormat: _calendarFormat,
// // // //                   selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
// // // //                   eventLoader: _getEventsForDay,
// // // //                   onDaySelected: (selectedDay, focusedDay) {
// // // //                     if (!mounted) return;
// // // //                     setState(() {
// // // //                       _selectedDay = selectedDay;
// // // //                       _focusedDay = focusedDay;
// // // //                     });
// // // //                   },
// // // //                   onFormatChanged: (format) {
// // // //                     if (!mounted) return;
// // // //                     setState(() => _calendarFormat = format);
// // // //                   },
// // // //                   calendarStyle: const CalendarStyle(
// // // //                     markerDecoration: BoxDecoration(
// // // //                       color: Colors.deepPurple,
// // // //                       shape: BoxShape.circle,
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //                 const Divider(),
// // // //                 Expanded(
// // // //                   child: selectedEvents.isEmpty
// // // //                       ? const Center(child: Text('해당 날짜에 등록된 일정이 없습니다.'))
// // // //                       : ListView.builder(
// // // //                           itemCount: selectedEvents.length,
// // // //                           itemBuilder: (context, index) {
// // // //                             final item = selectedEvents[index];
// // // //                             return Card(
// // // //                               margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
// // // //                               child: ListTile(
// // // //                                 leading: const Icon(Icons.event, color: Colors.deepPurple),
// // // //                                 title: Text(item['title'] ?? '일정 제목 없음', style: const TextStyle(fontWeight: FontWeight.bold)),
// // // //                                 subtitle: Text('날짜: ${item['event_date']}'),
// // // //                                 trailing: item['image_url'] != null
// // // //                                     ? ClipRRect(
// // // //                                         borderRadius: BorderRadius.circular(6),
// // // //                                         child: Image.network(
// // // //                                           item['image_url'],
// // // //                                           width: 45,
// // // //                                           height: 45,
// // // //                                           fit: BoxFit.cover,
// // // //                                           errorBuilder: (context, error, stackTrace) =>
// // // //                                               const Icon(Icons.broken_image, size: 30),
// // // //                                         ),
// // // //                                       )
// // // //                                     : null,
// // // //                               ),
// // // //                             );
// // // //                           },
// // // //                         ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //     );
// // // //   }
// // // // }

// // // // // -------------------------------------------------------------
// // // // // 3. 히스토리 탭 (/api/v1/history/ 연동)
// // // // // -------------------------------------------------------------
// // // // class HistoryScreen extends StatefulWidget {
// // // //   const HistoryScreen({super.key});

// // // //   @override
// // // //   State<HistoryScreen> createState() => _HistoryScreenState();
// // // // }

// // // // class _HistoryScreenState extends State<HistoryScreen> {
// // // //   List<dynamic> _historyList = [];
// // // //   bool _isLoading = true;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _fetchHistory();
// // // //   }

// // // //   Future<void> _fetchHistory() async {
// // // //     if (!mounted) return;
// // // //     setState(() => _isLoading = true);

// // // //     try {
// // // //       final response = await http.get(Uri.parse('$baseUrl/api/v1/history/'));
// // // //       if (response.statusCode == 200 && mounted) {
// // // //         final data = jsonDecode(utf8.decode(response.bodyBytes));
// // // //         setState(() {
// // // //           _historyList = data['history'] ?? [];
// // // //         });
// // // //       }
// // // //     } catch (e) {
// // // //       // 에러 핸들링
// // // //     } finally {
// // // //       if (mounted) {
// // // //         setState(() => _isLoading = false);
// // // //       }
// // // //     }
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       appBar: AppBar(
// // // //         title: const Text('분석 히스토리'),
// // // //         actions: [
// // // //           IconButton(onPressed: _fetchHistory, icon: const Icon(Icons.refresh)),
// // // //         ],
// // // //       ),
// // // //       body: _isLoading
// // // //           ? const Center(child: CircularProgressIndicator())
// // // //           : _historyList.isEmpty
// // // //               ? const Center(child: Text('히스토리가 없습니다.'))
// // // //               : ListView.builder(
// // // //                   padding: const EdgeInsets.symmetric(vertical: 8),
// // // //                   itemCount: _historyList.length,
// // // //                   itemBuilder: (context, index) {
// // // //                     final item = _historyList[index];
// // // //                     final actionType = item['action_type'] ?? '';

// // // //                     return Card(
// // // //                       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // // //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // // //                       elevation: 2,
// // // //                       child: InkWell(
// // // //                         borderRadius: BorderRadius.circular(12),
// // // //                         onTap: () {
// // // //                           Navigator.push(
// // // //                             context,
// // // //                             MaterialPageRoute(
// // // //                               builder: (context) => HistoryDetailScreen(item: item),
// // // //                             ),
// // // //                           );
// // // //                         },
// // // //                         child: Padding(
// // // //                           padding: const EdgeInsets.all(12),
// // // //                           child: Row(
// // // //                             children: [
// // // //                               ClipRRect(
// // // //                                 borderRadius: BorderRadius.circular(8),
// // // //                                 child: item['image_url'] != null
// // // //                                     ? Image.network(
// // // //                                         item['image_url'],
// // // //                                         width: 65,
// // // //                                         height: 65,
// // // //                                         fit: BoxFit.cover,
// // // //                                         errorBuilder: (context, error, stackTrace) =>
// // // //                                             Container(width: 65, height: 65, color: Colors.grey.shade300, child: const Icon(Icons.broken_image)),
// // // //                                       )
// // // //                                     : Container(width: 65, height: 65, color: Colors.grey.shade300, child: const Icon(Icons.image)),
// // // //                               ),
// // // //                               const SizedBox(width: 14),
// // // //                               Expanded(
// // // //                                 child: Column(
// // // //                                   crossAxisAlignment: CrossAxisAlignment.start,
// // // //                                   children: [
// // // //                                     Row(
// // // //                                       children: [
// // // //                                         Container(
// // // //                                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
// // // //                                           decoration: BoxDecoration(
// // // //                                             color: Colors.deepPurple.shade50,
// // // //                                             borderRadius: BorderRadius.circular(6),
// // // //                                           ),
// // // //                                           child: Text(
// // // //                                             item['category'] ?? '미분류',
// // // //                                             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepPurple),
// // // //                                           ),
// // // //                                         ),
// // // //                                         const Spacer(),
// // // //                                         if (actionType.contains('일정') || actionType.contains('캘린더'))
// // // //                                           const Icon(Icons.calendar_month, size: 18, color: Colors.blueAccent)
// // // //                                         else if (actionType.contains('지도') || actionType.contains('매핑'))
// // // //                                           const Icon(Icons.location_on, size: 18, color: Colors.redAccent),
// // // //                                       ],
// // // //                                     ),
// // // //                                     const SizedBox(height: 6),
// // // //                                     Text(
// // // //                                       item['summary'] ?? '요약 내용 없음',
// // // //                                       maxLines: 2,
// // // //                                       overflow: TextOverflow.ellipsis,
// // // //                                       style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
// // // //                                     ),
// // // //                                   ],
// // // //                                 ),
// // // //                               ),
// // // //                               const Icon(Icons.chevron_right, color: Colors.grey),
// // // //                             ],
// // // //                           ),
// // // //                         ),
// // // //                       ),
// // // //                     );
// // // //                   },
// // // //                 ),
// // // //     );
// // // //   }
// // // // }

// // // // // -------------------------------------------------------------
// // // // // 4. 히스토리 상세 화면 (action_data 주소 최우선 네이버 지도 연동)
// // // // // -------------------------------------------------------------
// // // // class HistoryDetailScreen extends StatelessWidget {
// // // //   final Map<String, dynamic> item;

// // // //   const HistoryDetailScreen({super.key, required this.item});

// // // //   Future<void> _openNaverMap(String addressQuery) async {
// // // //     final query = addressQuery.trim();
// // // //     if (query.isEmpty) return;

// // // //     final encodedQuery = Uri.encodeComponent(query);
// // // //     final url = Uri.parse('https://m.map.naver.com/search2/search.naver?query=$encodedQuery');
// // // //     if (await canLaunchUrl(url)) {
// // // //       await launchUrl(url, mode: LaunchMode.externalApplication);
// // // //     }
// // // //   }

// // // //   String _resolveSearchTarget() {
// // // //     // 1. action_data (도로명 주소 우선)
// // // //     final actionData = item['action_data']?.toString().trim() ?? '';
// // // //     if (actionData.isNotEmpty) return actionData;

// // // //     // 2. places 구조가 있을 경우
// // // //     if (item['places'] is List && (item['places'] as List).isNotEmpty) {
// // // //       final firstPlace = item['places'][0];
// // // //       if (firstPlace is Map) {
// // // //         final address = firstPlace['address']?.toString().trim() ?? '';
// // // //         if (address.isNotEmpty) return address;

// // // //         final placeName = firstPlace['place_name']?.toString().trim() ?? '';
// // // //         if (placeName.isNotEmpty) return placeName;
// // // //       }
// // // //     }

// // // //     // 3. 마지막 fallback: summary
// // // //     return item['summary']?.toString().trim() ?? '';
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     final actionType = item['action_type'] ?? '해당없음';
// // // //     final isCalendarAction = actionType.contains('일정') || actionType.contains('캘린더');
// // // //     final isMapAction = actionType.contains('지도') || actionType.contains('매핑');
    
// // // //     final searchTarget = _resolveSearchTarget();
// // // //     final rawActionData = item['action_data']?.toString().trim() ?? '';

// // // //     return Scaffold(
// // // //       appBar: AppBar(
// // // //         title: const Text('분석 상세 정보'),
// // // //       ),
// // // //       body: SingleChildScrollView(
// // // //         padding: const EdgeInsets.all(16),
// // // //         child: Column(
// // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // //           children: [
// // // //             if (item['image_url'] != null)
// // // //               ClipRRect(
// // // //                 borderRadius: BorderRadius.circular(12),
// // // //                 child: Image.network(
// // // //                   item['image_url'],
// // // //                   width: double.infinity,
// // // //                   height: 260,
// // // //                   fit: BoxFit.contain,
// // // //                   errorBuilder: (context, error, stackTrace) =>
// // // //                       Container(height: 180, color: Colors.grey.shade200, child: const Center(child: Icon(Icons.broken_image, size: 48))),
// // // //                 ),
// // // //               ),
// // // //             const SizedBox(height: 16),

// // // //             // 1. 네이버 지도 검색 연동 카드
// // // //             if (isMapAction)
// // // //               Card(
// // // //                 color: Colors.green.shade50,
// // // //                 shape: RoundedRectangleBorder(
// // // //                   borderRadius: BorderRadius.circular(12),
// // // //                   side: BorderSide(color: Colors.green.shade200),
// // // //                 ),
// // // //                 margin: const EdgeInsets.only(bottom: 16),
// // // //                 child: Padding(
// // // //                   padding: const EdgeInsets.all(16),
// // // //                   child: Column(
// // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // //                     children: [
// // // //                       const Row(
// // // //                         children: [
// // // //                           Icon(Icons.location_on, color: Colors.green),
// // // //                           SizedBox(width: 8),
// // // //                           Text('지도 검색 위치 (도로명 주소/상호명)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
// // // //                         ],
// // // //                       ),
// // // //                       const SizedBox(height: 8),
// // // //                       Text(
// // // //                         searchTarget.isNotEmpty ? searchTarget : '등록된 주소 정보가 없습니다.',
// // // //                         style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
// // // //                       ),
// // // //                       const SizedBox(height: 12),
// // // //                       ElevatedButton.icon(
// // // //                         onPressed: searchTarget.isNotEmpty ? () => _openNaverMap(searchTarget) : null,
// // // //                         icon: const Icon(Icons.map_outlined, color: Colors.white),
// // // //                         label: const Text('네이버 지도에서 위치 확인', style: TextStyle(color: Colors.white)),
// // // //                         style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF03C75A)),
// // // //                       ),
// // // //                     ],
// // // //                   ),
// // // //                 ),
// // // //               ),

// // // //             // 2. 캘린더 등록 알림 섹션
// // // //             if (isCalendarAction)
// // // //               Container(
// // // //                 margin: const EdgeInsets.only(bottom: 16),
// // // //                 padding: const EdgeInsets.all(12),
// // // //                 decoration: BoxDecoration(
// // // //                   color: Colors.blue.shade50,
// // // //                   borderRadius: BorderRadius.circular(8),
// // // //                   border: Border.all(color: Colors.blue.shade200),
// // // //                 ),
// // // //                 child: const Row(
// // // //                   children: [
// // // //                     Icon(Icons.event_available, color: Colors.blue),
// // // //                     SizedBox(width: 8),
// // // //                     Expanded(
// // // //                       child: Text('캘린더 일정으로 등록된 항목입니다.', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
// // // //                     ),
// // // //                   ],
// // // //                 ),
// // // //               ),

// // // //             // 3. 요약 정보 카드
// // // //             Card(
// // // //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // // //               child: Padding(
// // // //                 padding: const EdgeInsets.all(16),
// // // //                 child: Column(
// // // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // // //                   children: [
// // // //                     _buildInfoRow('카테고리', item['category'] ?? '-'),
// // // //                     const Divider(height: 24),
// // // //                     _buildInfoRow('액션 분류', actionType),
// // // //                     const Divider(height: 24),
// // // //                     _buildInfoRow('요약 내용', item['summary'] ?? '-'),
// // // //                     if (searchTarget.isNotEmpty) ...[
// // // //                       const Divider(height: 24),
// // // //                       _buildInfoRow('추출 주소 / 상세 데이터', searchTarget),
// // // //                     ] else if (rawActionData.isNotEmpty) ...[
// // // //                       const Divider(height: 24),
// // // //                       _buildInfoRow('상세 데이터', rawActionData),
// // // //                     ],
// // // //                     if (item['created_at'] != null) ...[
// // // //                       const Divider(height: 24),
// // // //                       _buildInfoRow('분석 일시', item['created_at'].toString().split('.')[0].replaceAll('T', ' ')),
// // // //                     ],
// // // //                   ],
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _buildInfoRow(String label, String value) {
// // // //     return Column(
// // // //       crossAxisAlignment: CrossAxisAlignment.start,
// // // //       children: [
// // // //         Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
// // // //         const SizedBox(height: 4),
// // // //         Text(value, style: const TextStyle(fontSize: 15, height: 1.4)),
// // // //       ],
// // // //     );
// // // //   }
// // // // }

// // // // // import 'dart:convert';
// // // // // import 'dart:io';
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:http/http.dart' as http;
// // // // // import 'package:image_picker/image_picker.dart';
// // // // // import 'package:table_calendar/table_calendar.dart';
// // // // // import 'package:url_launcher/url_launcher.dart';

// // // // // // 로컬 환경에 맞게 서버 IP/포트 설정 (안드로이드 에뮬레이터 기준 10.0.2.2:8000, 실제 기기는 PC IP 입력)
// // // // // const String baseUrl = "http://10.0.2.2:8000";

// // // // // void main() {
// // // // //   runApp(const MyApp());
// // // // // }

// // // // // class MyApp extends StatelessWidget {
// // // // //   const MyApp({super.key});

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return MaterialApp(
// // // // //       title: 'T.Salmon',
// // // // //       theme: ThemeData(
// // // // //         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
// // // // //         useMaterial3: true,
// // // // //       ),
// // // // //       home: const MainNavigationScreen(),
// // // // //     );
// // // // //   }
// // // // // }

// // // // // class MainNavigationScreen extends StatefulWidget {
// // // // //   const MainNavigationScreen({super.key});

// // // // //   @override
// // // // //   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// // // // // }

// // // // // class _MainNavigationScreenState extends State<MainNavigationScreen> {
// // // // //   int _currentIndex = 0;

// // // // //   final List<Widget> _screens = const [
// // // // //     UploadScreen(),
// // // // //     CalendarScreen(),
// // // // //     HistoryScreen(),
// // // // //   ];

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Scaffold(
// // // // //       body: _screens[_currentIndex],
// // // // //       bottomNavigationBar: NavigationBar(
// // // // //         selectedIndex: _currentIndex,
// // // // //         onDestinationSelected: (index) => setState(() => _currentIndex = index),
// // // // //         destinations: const [
// // // // //           NavigationDestination(
// // // // //             icon: Icon(Icons.cloud_upload_outlined),
// // // // //             selectedIcon: Icon(Icons.cloud_upload),
// // // // //             label: '업로드',
// // // // //           ),
// // // // //           NavigationDestination(
// // // // //             icon: Icon(Icons.calendar_month_outlined),
// // // // //             selectedIcon: Icon(Icons.calendar_month),
// // // // //             label: '캘린더',
// // // // //           ),
// // // // //           NavigationDestination(
// // // // //             icon: Icon(Icons.history_outlined),
// // // // //             selectedIcon: Icon(Icons.history),
// // // // //             label: '히스토리',
// // // // //           ),
// // // // //         ],
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }

// // // // // // -------------------------------------------------------------
// // // // // // 1. 업로드 탭 (스크린샷 원본 화질 유지 선택 및 /api/v1/analyze 호출)
// // // // // // -------------------------------------------------------------
// // // // // class UploadScreen extends StatefulWidget {
// // // // //   const UploadScreen({super.key});

// // // // //   @override
// // // // //   State<UploadScreen> createState() => _UploadScreenState();
// // // // // }

// // // // // class _UploadScreenState extends State<UploadScreen> {
// // // // //   File? _selectedImage;
// // // // //   bool _isLoading = false;
// // // // //   Map<String, dynamic>? _analysisResult;

// // // // //   final ImagePicker _picker = ImagePicker();

// // // // //   Future<void> _pickAndUploadImage() async {
// // // // //     // 👈 화질 저하 방지를 위해 imageQuality 및 해상도 제한 해제 옵션 적용
// // // // //     final pickedFile = await _picker.pickImage(
// // // // //       source: ImageSource.gallery,
// // // // //       imageQuality: 100,
// // // // //       maxWidth: null,
// // // // //       maxHeight: null,
// // // // //     );
// // // // //     if (pickedFile == null) return;

// // // // //     if (!mounted) return;
// // // // //     setState(() {
// // // // //       _selectedImage = File(pickedFile.path);
// // // // //       _isLoading = true;
// // // // //       _analysisResult = null;
// // // // //     });

// // // // //     try {
// // // // //       final uri = Uri.parse('$baseUrl/api/v1/analyze');
// // // // //       final request = http.MultipartRequest('POST', uri);
// // // // //       request.files.add(await http.MultipartFile.fromPath('file', pickedFile.path));

// // // // //       final streamedResponse = await request.send();
// // // // //       final response = await http.Response.fromStream(streamedResponse);

// // // // //       if (response.statusCode == 200) {
// // // // //         final decoded = jsonDecode(utf8.decode(response.bodyBytes));
// // // // //         if (mounted) {
// // // // //           setState(() {
// // // // //             _analysisResult = decoded['analysis'];
// // // // //           });
// // // // //           ScaffoldMessenger.of(context).showSnackBar(
// // // // //             const SnackBar(content: Text('분석 및 저장이 완료되었습니다!')),
// // // // //           );
// // // // //         }
// // // // //       } else {
// // // // //         throw Exception('서버 응답 오류: ${response.statusCode}');
// // // // //       }
// // // // //     } catch (e) {
// // // // //       if (mounted) {
// // // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // // //           SnackBar(content: Text('업로드 실패: $e')),
// // // // //         );
// // // // //       }
// // // // //     } finally {
// // // // //       if (mounted) {
// // // // //         setState(() => _isLoading = false);
// // // // //       }
// // // // //     }
// // // // //   }

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Scaffold(
// // // // //       appBar: AppBar(title: const Text('스크린샷 분석')),
// // // // //       body: SingleChildScrollView(
// // // // //         padding: const EdgeInsets.all(16),
// // // // //         child: Column(
// // // // //           children: [
// // // // //             if (_selectedImage != null)
// // // // //               ClipRRect(
// // // // //                 borderRadius: BorderRadius.circular(12),
// // // // //                 child: Image.file(_selectedImage!, height: 260, fit: BoxFit.cover),
// // // // //               )
// // // // //             else
// // // // //               Container(
// // // // //                 height: 200,
// // // // //                 decoration: BoxDecoration(
// // // // //                   color: Colors.grey.shade200,
// // // // //                   borderRadius: BorderRadius.circular(12),
// // // // //                 ),
// // // // //                 child: const Center(child: Text('분석할 스크린샷을 선택하세요')),
// // // // //               ),
// // // // //             const SizedBox(height: 20),
// // // // //             ElevatedButton.icon(
// // // // //               onPressed: _isLoading ? null : _pickAndUploadImage,
// // // // //               icon: const Icon(Icons.photo_library),
// // // // //               label: Text(_isLoading ? '분석 중...' : '갤러리에서 선택 및 분석'),
// // // // //               style: ElevatedButton.styleFrom(
// // // // //                 minimumSize: const Size.fromHeight(50),
// // // // //               ),
// // // // //             ),
// // // // //             const SizedBox(height: 24),
// // // // //             if (_isLoading)
// // // // //               const CircularProgressIndicator()
// // // // //             else if (_analysisResult != null) ...[
// // // // //               const Align(
// // // // //                 alignment: Alignment.centerLeft,
// // // // //                 child: Text('분석 결과', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // //               ),
// // // // //               const SizedBox(height: 8),
// // // // //               Card(
// // // // //                 child: Padding(
// // // // //                   padding: const EdgeInsets.all(16),
// // // // //                   child: Column(
// // // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // // //                     children: [
// // // // //                       Text('카테고리: ${_analysisResult?['category'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // //                       const SizedBox(height: 6),
// // // // //                       Text('액션 타입: ${_analysisResult?['action_type'] ?? '-'}'),
// // // // //                       const SizedBox(height: 6),
// // // // //                       Text('요약: ${_analysisResult?['summary'] ?? '-'}'),
// // // // //                       if (_analysisResult?['action_data'] != null && _analysisResult?['action_data'] != "") ...[
// // // // //                         const SizedBox(height: 6),
// // // // //                         Text('상세: ${_analysisResult?['action_data']}'),
// // // // //                       ],
// // // // //                     ],
// // // // //                   ),
// // // // //                 ),
// // // // //               ),
// // // // //             ],
// // // // //           ],
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }

// // // // // // -------------------------------------------------------------
// // // // // // 2. 캘린더 탭 (/api/v1/calendar/ 연동 및 날짜별 로컬 매핑)
// // // // // // -------------------------------------------------------------
// // // // // class CalendarScreen extends StatefulWidget {
// // // // //   const CalendarScreen({super.key});

// // // // //   @override
// // // // //   State<CalendarScreen> createState() => _CalendarScreenState();
// // // // // }

// // // // // class _CalendarScreenState extends State<CalendarScreen> {
// // // // //   CalendarFormat _calendarFormat = CalendarFormat.month;
// // // // //   DateTime _focusedDay = DateTime.now();
// // // // //   DateTime? _selectedDay;
  
// // // // //   Map<DateTime, List<dynamic>> _eventsMap = {};
// // // // //   bool _isLoading = true;

// // // // //   @override
// // // // //   void initState() {
// // // // //     super.initState();
// // // // //     _selectedDay = _focusedDay;
// // // // //     _fetchCalendarEvents();
// // // // //   }

// // // // //   DateTime _normalizeDate(DateTime dt) {
// // // // //     return DateTime(dt.year, dt.month, dt.day);
// // // // //   }

// // // // //   Future<void> _fetchCalendarEvents() async {
// // // // //     if (!mounted) return;
// // // // //     setState(() => _isLoading = true);

// // // // //     try {
// // // // //       final response = await http.get(Uri.parse('$baseUrl/api/v1/calendar/'));
// // // // //       if (response.statusCode == 200 && mounted) {
// // // // //         final data = jsonDecode(utf8.decode(response.bodyBytes));
// // // // //         final List<dynamic> rawEvents = data['events'] ?? [];

// // // // //         final Map<DateTime, List<dynamic>> newMap = {};
// // // // //         for (var item in rawEvents) {
// // // // //           final dateStr = item['event_date'];
// // // // //           if (dateStr != null) {
// // // // //             try {
// // // // //               final parts = dateStr.toString().substring(0, 10).split('-');
// // // // //               final key = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
// // // // //               if (newMap[key] == null) {
// // // // //                 newMap[key] = [];
// // // // //               }
// // // // //               newMap[key]!.add(item);
// // // // //             } catch (_) {}
// // // // //           }
// // // // //         }

// // // // //         setState(() {
// // // // //           _eventsMap = newMap;
// // // // //         });
// // // // //       }
// // // // //     } catch (e) {
// // // // //       // 에러 핸들링
// // // // //     } finally {
// // // // //       if (mounted) {
// // // // //         setState(() => _isLoading = false);
// // // // //       }
// // // // //     }
// // // // //   }

// // // // //   List<dynamic> _getEventsForDay(DateTime day) {
// // // // //     return _eventsMap[_normalizeDate(day)] ?? [];
// // // // //   }

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     final selectedEvents = _selectedDay != null ? _getEventsForDay(_selectedDay!) : [];

// // // // //     return Scaffold(
// // // // //       appBar: AppBar(
// // // // //         title: const Text('등록된 일정'),
// // // // //         actions: [
// // // // //           IconButton(onPressed: _fetchCalendarEvents, icon: const Icon(Icons.refresh)),
// // // // //         ],
// // // // //       ),
// // // // //       body: _isLoading
// // // // //           ? const Center(child: CircularProgressIndicator())
// // // // //           : Column(
// // // // //               children: [
// // // // //                 TableCalendar(
// // // // //                   firstDay: DateTime.utc(2020, 1, 1),
// // // // //                   lastDay: DateTime.utc(2030, 12, 31),
// // // // //                   focusedDay: _focusedDay,
// // // // //                   calendarFormat: _calendarFormat,
// // // // //                   selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
// // // // //                   eventLoader: _getEventsForDay,
// // // // //                   onDaySelected: (selectedDay, focusedDay) {
// // // // //                     if (!mounted) return;
// // // // //                     setState(() {
// // // // //                       _selectedDay = selectedDay;
// // // // //                       _focusedDay = focusedDay;
// // // // //                     });
// // // // //                   },
// // // // //                   onFormatChanged: (format) {
// // // // //                     if (!mounted) return;
// // // // //                     setState(() => _calendarFormat = format);
// // // // //                   },
// // // // //                   calendarStyle: const CalendarStyle(
// // // // //                     markerDecoration: BoxDecoration(
// // // // //                       color: Colors.deepPurple,
// // // // //                       shape: BoxShape.circle,
// // // // //                     ),
// // // // //                   ),
// // // // //                 ),
// // // // //                 const Divider(),
// // // // //                 Expanded(
// // // // //                   child: selectedEvents.isEmpty
// // // // //                       ? const Center(child: Text('해당 날짜에 등록된 일정이 없습니다.'))
// // // // //                       : ListView.builder(
// // // // //                           itemCount: selectedEvents.length,
// // // // //                           itemBuilder: (context, index) {
// // // // //                             final item = selectedEvents[index];
// // // // //                             return Card(
// // // // //                               margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
// // // // //                               child: ListTile(
// // // // //                                 leading: const Icon(Icons.event, color: Colors.deepPurple),
// // // // //                                 title: Text(item['title'] ?? '일정 제목 없음', style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // //                                 subtitle: Text('날짜: ${item['event_date']}'),
// // // // //                                 trailing: item['image_url'] != null
// // // // //                                     ? ClipRRect(
// // // // //                                         borderRadius: BorderRadius.circular(6),
// // // // //                                         child: Image.network(
// // // // //                                           item['image_url'],
// // // // //                                           width: 45,
// // // // //                                           height: 45,
// // // // //                                           fit: BoxFit.cover,
// // // // //                                           errorBuilder: (context, error, stackTrace) =>
// // // // //                                               const Icon(Icons.broken_image, size: 30),
// // // // //                                         ),
// // // // //                                       )
// // // // //                                     : null,
// // // // //                               ),
// // // // //                             );
// // // // //                           },
// // // // //                         ),
// // // // //                 ),
// // // // //               ],
// // // // //             ),
// // // // //     );
// // // // //   }
// // // // // }

// // // // // // -------------------------------------------------------------
// // // // // // 3. 히스토리 탭 (/api/v1/history/ 연동)
// // // // // // -------------------------------------------------------------
// // // // // class HistoryScreen extends StatefulWidget {
// // // // //   const HistoryScreen({super.key});

// // // // //   @override
// // // // //   State<HistoryScreen> createState() => _HistoryScreenState();
// // // // // }

// // // // // class _HistoryScreenState extends State<HistoryScreen> {
// // // // //   List<dynamic> _historyList = [];
// // // // //   bool _isLoading = true;

// // // // //   @override
// // // // //   void initState() {
// // // // //     super.initState();
// // // // //     _fetchHistory();
// // // // //   }

// // // // //   Future<void> _fetchHistory() async {
// // // // //     if (!mounted) return;
// // // // //     setState(() => _isLoading = true);

// // // // //     try {
// // // // //       final response = await http.get(Uri.parse('$baseUrl/api/v1/history/'));
// // // // //       if (response.statusCode == 200 && mounted) {
// // // // //         final data = jsonDecode(utf8.decode(response.bodyBytes));
// // // // //         setState(() {
// // // // //           _historyList = data['history'] ?? [];
// // // // //         });
// // // // //       }
// // // // //     } catch (e) {
// // // // //       // 에러 핸들링
// // // // //     } finally {
// // // // //       if (mounted) {
// // // // //         setState(() => _isLoading = false);
// // // // //       }
// // // // //     }
// // // // //   }

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Scaffold(
// // // // //       appBar: AppBar(
// // // // //         title: const Text('분석 히스토리'),
// // // // //         actions: [
// // // // //           IconButton(onPressed: _fetchHistory, icon: const Icon(Icons.refresh)),
// // // // //         ],
// // // // //       ),
// // // // //       body: _isLoading
// // // // //           ? const Center(child: CircularProgressIndicator())
// // // // //           : _historyList.isEmpty
// // // // //               ? const Center(child: Text('히스토리가 없습니다.'))
// // // // //               : ListView.builder(
// // // // //                   padding: const EdgeInsets.symmetric(vertical: 8),
// // // // //                   itemCount: _historyList.length,
// // // // //                   itemBuilder: (context, index) {
// // // // //                     final item = _historyList[index];
// // // // //                     final actionType = item['action_type'] ?? '';

// // // // //                     return Card(
// // // // //                       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // // // //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // // // //                       elevation: 2,
// // // // //                       child: InkWell(
// // // // //                         borderRadius: BorderRadius.circular(12),
// // // // //                         onTap: () {
// // // // //                           Navigator.push(
// // // // //                             context,
// // // // //                             MaterialPageRoute(
// // // // //                               builder: (context) => HistoryDetailScreen(item: item),
// // // // //                             ),
// // // // //                           );
// // // // //                         },
// // // // //                         child: Padding(
// // // // //                           padding: const EdgeInsets.all(12),
// // // // //                           child: Row(
// // // // //                             children: [
// // // // //                               ClipRRect(
// // // // //                                 borderRadius: BorderRadius.circular(8),
// // // // //                                 child: item['image_url'] != null
// // // // //                                     ? Image.network(
// // // // //                                         item['image_url'],
// // // // //                                         width: 65,
// // // // //                                         height: 65,
// // // // //                                         fit: BoxFit.cover,
// // // // //                                         errorBuilder: (context, error, stackTrace) =>
// // // // //                                             Container(width: 65, height: 65, color: Colors.grey.shade300, child: const Icon(Icons.broken_image)),
// // // // //                                       )
// // // // //                                     : Container(width: 65, height: 65, color: Colors.grey.shade300, child: const Icon(Icons.image)),
// // // // //                               ),
// // // // //                               const SizedBox(width: 14),
// // // // //                               Expanded(
// // // // //                                 child: Column(
// // // // //                                   crossAxisAlignment: CrossAxisAlignment.start,
// // // // //                                   children: [
// // // // //                                     Row(
// // // // //                                       children: [
// // // // //                                         Container(
// // // // //                                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
// // // // //                                           decoration: BoxDecoration(
// // // // //                                             color: Colors.deepPurple.shade50,
// // // // //                                             borderRadius: BorderRadius.circular(6),
// // // // //                                           ),
// // // // //                                           child: Text(
// // // // //                                             item['category'] ?? '미분류',
// // // // //                                             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepPurple),
// // // // //                                           ),
// // // // //                                         ),
// // // // //                                         const Spacer(),
// // // // //                                         if (actionType.contains('일정') || actionType.contains('캘린더'))
// // // // //                                           const Icon(Icons.calendar_month, size: 18, color: Colors.blueAccent)
// // // // //                                         else if (actionType.contains('지도') || actionType.contains('매핑'))
// // // // //                                           const Icon(Icons.location_on, size: 18, color: Colors.redAccent),
// // // // //                                       ],
// // // // //                                     ),
// // // // //                                     const SizedBox(height: 6),
// // // // //                                     Text(
// // // // //                                       item['summary'] ?? '요약 내용 없음',
// // // // //                                       maxLines: 2,
// // // // //                                       overflow: TextOverflow.ellipsis,
// // // // //                                       style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
// // // // //                                     ),
// // // // //                                   ],
// // // // //                                 ),
// // // // //                               ),
// // // // //                               const Icon(Icons.chevron_right, color: Colors.grey),
// // // // //                             ],
// // // // //                           ),
// // // // //                         ),
// // // // //                       ),
// // // // //                     );
// // // // //                   },
// // // // //                 ),
// // // // //     );
// // // // //   }
// // // // // }

// // // // // // -------------------------------------------------------------
// // // // // // 4. 히스토리 상세 화면 (action_data 주소 최우선 네이버 지도 연동)
// // // // // // -------------------------------------------------------------
// // // // // class HistoryDetailScreen extends StatelessWidget {
// // // // //   final Map<String, dynamic> item;

// // // // //   const HistoryDetailScreen({super.key, required this.item});

// // // // //   Future<void> _openNaverMap(String addressQuery) async {
// // // // //     final query = addressQuery.trim();
// // // // //     if (query.isEmpty) return;

// // // // //     final encodedQuery = Uri.encodeComponent(query);
// // // // //     final url = Uri.parse('https://m.map.naver.com/search2/search.naver?query=$encodedQuery');
// // // // //     if (await canLaunchUrl(url)) {
// // // // //       await launchUrl(url, mode: LaunchMode.externalApplication);
// // // // //     }
// // // // //   }

// // // // //   String _resolveSearchTarget() {
// // // // //     // 1. action_data (도로명 주소 우선)
// // // // //     final actionData = item['action_data']?.toString().trim() ?? '';
// // // // //     if (actionData.isNotEmpty) return actionData;

// // // // //     // 2. places 구조가 있을 경우
// // // // //     if (item['places'] is List && (item['places'] as List).isNotEmpty) {
// // // // //       final firstPlace = item['places'][0];
// // // // //       if (firstPlace is Map) {
// // // // //         final address = firstPlace['address']?.toString().trim() ?? '';
// // // // //         if (address.isNotEmpty) return address;

// // // // //         final placeName = firstPlace['place_name']?.toString().trim() ?? '';
// // // // //         if (placeName.isNotEmpty) return placeName;
// // // // //       }
// // // // //     }

// // // // //     // 3. 마지막 fallback: summary
// // // // //     return item['summary']?.toString().trim() ?? '';
// // // // //   }

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     final actionType = item['action_type'] ?? '해당없음';
// // // // //     final isCalendarAction = actionType.contains('일정') || actionType.contains('캘린더');
// // // // //     final isMapAction = actionType.contains('지도') || actionType.contains('매핑');
    
// // // // //     final searchTarget = _resolveSearchTarget();
// // // // //     final rawActionData = item['action_data']?.toString().trim() ?? '';

// // // // //     return Scaffold(
// // // // //       appBar: AppBar(
// // // // //         title: const Text('분석 상세 정보'),
// // // // //       ),
// // // // //       body: SingleChildScrollView(
// // // // //         padding: const EdgeInsets.all(16),
// // // // //         child: Column(
// // // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // // //           children: [
// // // // //             if (item['image_url'] != null)
// // // // //               ClipRRect(
// // // // //                 borderRadius: BorderRadius.circular(12),
// // // // //                 child: Image.network(
// // // // //                   item['image_url'],
// // // // //                   width: double.infinity,
// // // // //                   height: 260,
// // // // //                   fit: BoxFit.contain,
// // // // //                   errorBuilder: (context, error, stackTrace) =>
// // // // //                       Container(height: 180, color: Colors.grey.shade200, child: const Center(child: Icon(Icons.broken_image, size: 48))),
// // // // //                 ),
// // // // //               ),
// // // // //             const SizedBox(height: 16),

// // // // //             // 1. 네이버 지도 검색 연동 카드
// // // // //             if (isMapAction)
// // // // //               Card(
// // // // //                 color: Colors.green.shade50,
// // // // //                 shape: RoundedRectangleBorder(
// // // // //                   borderRadius: BorderRadius.circular(12),
// // // // //                   side: BorderSide(color: Colors.green.shade200),
// // // // //                 ),
// // // // //                 margin: const EdgeInsets.only(bottom: 16),
// // // // //                 child: Padding(
// // // // //                   padding: const EdgeInsets.all(16),
// // // // //                   child: Column(
// // // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // // //                     children: [
// // // // //                       const Row(
// // // // //                         children: [
// // // // //                           Icon(Icons.location_on, color: Colors.green),
// // // // //                           SizedBox(width: 8),
// // // // //                           Text('지도 검색 위치 (도로명 주소/상호명)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
// // // // //                         ],
// // // // //                       ),
// // // // //                       const SizedBox(height: 8),
// // // // //                       Text(
// // // // //                         searchTarget.isNotEmpty ? searchTarget : '등록된 주소 정보가 없습니다.',
// // // // //                         style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
// // // // //                       ),
// // // // //                       const SizedBox(height: 12),
// // // // //                       ElevatedButton.icon(
// // // // //                         onPressed: searchTarget.isNotEmpty ? () => _openNaverMap(searchTarget) : null,
// // // // //                         icon: const Icon(Icons.map_outlined, color: Colors.white),
// // // // //                         label: const Text('네이버 지도에서 위치 확인', style: TextStyle(color: Colors.white)),
// // // // //                         style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF03C75A)),
// // // // //                       ),
// // // // //                     ],
// // // // //                   ),
// // // // //                 ),
// // // // //               ),

// // // // //             // 2. 캘린더 등록 알림 섹션
// // // // //             if (isCalendarAction)
// // // // //               Container(
// // // // //                 margin: const EdgeInsets.only(bottom: 16),
// // // // //                 padding: const EdgeInsets.all(12),
// // // // //                 decoration: BoxDecoration(
// // // // //                   color: Colors.blue.shade50,
// // // // //                   borderRadius: BorderRadius.circular(8),
// // // // //                   border: Border.all(color: Colors.blue.shade200),
// // // // //                 ),
// // // // //                 child: const Row(
// // // // //                   children: [
// // // // //                     Icon(Icons.event_available, color: Colors.blue),
// // // // //                     SizedBox(width: 8),
// // // // //                     Expanded(
// // // // //                       child: Text('캘린더 일정으로 등록된 항목입니다.', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
// // // // //                     ),
// // // // //                   ],
// // // // //                 ),
// // // // //               ),

// // // // //             // 3. 요약 정보 카드
// // // // //             Card(
// // // // //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // // // //               child: Padding(
// // // // //                 padding: const EdgeInsets.all(16),
// // // // //                 child: Column(
// // // // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // // // //                   children: [
// // // // //                     _buildInfoRow('카테고리', item['category'] ?? '-'),
// // // // //                     const Divider(height: 24),
// // // // //                     _buildInfoRow('액션 분류', actionType),
// // // // //                     const Divider(height: 24),
// // // // //                     _buildInfoRow('요약 내용', item['summary'] ?? '-'),
// // // // //                     if (searchTarget.isNotEmpty) ...[
// // // // //                       const Divider(height: 24),
// // // // //                       _buildInfoRow('추출 주소 / 상세 데이터', searchTarget),
// // // // //                     ] else if (rawActionData.isNotEmpty) ...[
// // // // //                       const Divider(height: 24),
// // // // //                       _buildInfoRow('상세 데이터', rawActionData),
// // // // //                     ],
// // // // //                     if (item['created_at'] != null) ...[
// // // // //                       const Divider(height: 24),
// // // // //                       _buildInfoRow('분석 일시', item['created_at'].toString().split('.')[0].replaceAll('T', ' ')),
// // // // //                     ],
// // // // //                   ],
// // // // //                 ),
// // // // //               ),
// // // // //             ),
// // // // //           ],
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   Widget _buildInfoRow(String label, String value) {
// // // // //     return Column(
// // // // //       crossAxisAlignment: CrossAxisAlignment.start,
// // // // //       children: [
// // // // //         Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
// // // // //         const SizedBox(height: 4),
// // // // //         Text(value, style: const TextStyle(fontSize: 15, height: 1.4)),
// // // // //       ],
// // // // //     );
// // // // //   }
// // // // // }

// // // // // // import 'dart:convert';
// // // // // // import 'dart:io';
// // // // // // import 'package:flutter/material.dart';
// // // // // // import 'package:http/http.dart' as http;
// // // // // // import 'package:image_picker/image_picker.dart';
// // // // // // import 'package:table_calendar/table_calendar.dart';
// // // // // // import 'package:url_launcher/url_launcher.dart';

// // // // // // // 로컬 환경에 맞게 서버 IP/포트 설정 (안드로이드 에뮬레이터 기준 10.0.2.2:8000, 실제 기기는 PC IP 입력)
// // // // // // const String baseUrl = "http://10.0.2.2:8000";

// // // // // // void main() {
// // // // // //   runApp(const MyApp());
// // // // // // }

// // // // // // class MyApp extends StatelessWidget {
// // // // // //   const MyApp({super.key});

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     return MaterialApp(
// // // // // //       title: 'T.Salmon',
// // // // // //       theme: ThemeData(
// // // // // //         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
// // // // // //         useMaterial3: true,
// // // // // //       ),
// // // // // //       home: const MainNavigationScreen(),
// // // // // //     );
// // // // // //   }
// // // // // // }

// // // // // // class MainNavigationScreen extends StatefulWidget {
// // // // // //   const MainNavigationScreen({super.key});

// // // // // //   @override
// // // // // //   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// // // // // // }

// // // // // // class _MainNavigationScreenState extends State<MainNavigationScreen> {
// // // // // //   int _currentIndex = 0;

// // // // // //   final List<Widget> _screens = const [
// // // // // //     UploadScreen(),
// // // // // //     CalendarScreen(),
// // // // // //     HistoryScreen(),
// // // // // //   ];

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     return Scaffold(
// // // // // //       body: _screens[_currentIndex],
// // // // // //       bottomNavigationBar: NavigationBar(
// // // // // //         selectedIndex: _currentIndex,
// // // // // //         onDestinationSelected: (index) => setState(() => _currentIndex = index),
// // // // // //         destinations: const [
// // // // // //           NavigationDestination(
// // // // // //             icon: Icon(Icons.cloud_upload_outlined),
// // // // // //             selectedIcon: Icon(Icons.cloud_upload),
// // // // // //             label: '업로드',
// // // // // //           ),
// // // // // //           NavigationDestination(
// // // // // //             icon: Icon(Icons.calendar_month_outlined),
// // // // // //             selectedIcon: Icon(Icons.calendar_month),
// // // // // //             label: '캘린더',
// // // // // //           ),
// // // // // //           NavigationDestination(
// // // // // //             icon: Icon(Icons.history_outlined),
// // // // // //             selectedIcon: Icon(Icons.history),
// // // // // //             label: '히스토리',
// // // // // //           ),
// // // // // //         ],
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // // }

// // // // // // // -------------------------------------------------------------
// // // // // // // 1. 업로드 탭 (스크린샷 수동 선택 및 /api/v1/analyze 호출)
// // // // // // // -------------------------------------------------------------
// // // // // // class UploadScreen extends StatefulWidget {
// // // // // //   const UploadScreen({super.key});

// // // // // //   @override
// // // // // //   State<UploadScreen> createState() => _UploadScreenState();
// // // // // // }

// // // // // // class _UploadScreenState extends State<UploadScreen> {
// // // // // //   File? _selectedImage;
// // // // // //   bool _isLoading = false;
// // // // // //   Map<String, dynamic>? _analysisResult;

// // // // // //   final ImagePicker _picker = ImagePicker();

// // // // // //   Future<void> _pickAndUploadImage() async {
// // // // // //     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
// // // // // //     if (pickedFile == null) return;

// // // // // //     if (!mounted) return;
// // // // // //     setState(() {
// // // // // //       _selectedImage = File(pickedFile.path);
// // // // // //       _isLoading = true;
// // // // // //       _analysisResult = null;
// // // // // //     });

// // // // // //     try {
// // // // // //       final uri = Uri.parse('$baseUrl/api/v1/analyze');
// // // // // //       final request = http.MultipartRequest('POST', uri);
// // // // // //       request.files.add(await http.MultipartFile.fromPath('file', pickedFile.path));

// // // // // //       final streamedResponse = await request.send();
// // // // // //       final response = await http.Response.fromStream(streamedResponse);

// // // // // //       if (response.statusCode == 200) {
// // // // // //         final decoded = jsonDecode(utf8.decode(response.bodyBytes));
// // // // // //         if (mounted) {
// // // // // //           setState(() {
// // // // // //             _analysisResult = decoded['analysis'];
// // // // // //           });
// // // // // //           ScaffoldMessenger.of(context).showSnackBar(
// // // // // //             const SnackBar(content: Text('분석 및 저장이 완료되었습니다!')),
// // // // // //           );
// // // // // //         }
// // // // // //       } else {
// // // // // //         throw Exception('서버 응답 오류: ${response.statusCode}');
// // // // // //       }
// // // // // //     } catch (e) {
// // // // // //       if (mounted) {
// // // // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // // // //           SnackBar(content: Text('업로드 실패: $e')),
// // // // // //         );
// // // // // //       }
// // // // // //     } finally {
// // // // // //       if (mounted) {
// // // // // //         setState(() => _isLoading = false);
// // // // // //       }
// // // // // //     }
// // // // // //   }

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     return Scaffold(
// // // // // //       appBar: AppBar(title: const Text('스크린샷 분석')),
// // // // // //       body: SingleChildScrollView(
// // // // // //         padding: const EdgeInsets.all(16),
// // // // // //         child: Column(
// // // // // //           children: [
// // // // // //             if (_selectedImage != null)
// // // // // //               ClipRRect(
// // // // // //                 borderRadius: BorderRadius.circular(12),
// // // // // //                 child: Image.file(_selectedImage!, height: 260, fit: BoxFit.cover),
// // // // // //               )
// // // // // //             else
// // // // // //               Container(
// // // // // //                 height: 200,
// // // // // //                 decoration: BoxDecoration(
// // // // // //                   color: Colors.grey.shade200,
// // // // // //                   borderRadius: BorderRadius.circular(12),
// // // // // //                 ),
// // // // // //                 child: const Center(child: Text('분석할 스크린샷을 선택하세요')),
// // // // // //               ),
// // // // // //             const SizedBox(height: 20),
// // // // // //             ElevatedButton.icon(
// // // // // //               onPressed: _isLoading ? null : _pickAndUploadImage,
// // // // // //               icon: const Icon(Icons.photo_library),
// // // // // //               label: Text(_isLoading ? '분석 중...' : '갤러리에서 선택 및 분석'),
// // // // // //               style: ElevatedButton.styleFrom(
// // // // // //                 minimumSize: const Size.fromHeight(50),
// // // // // //               ),
// // // // // //             ),
// // // // // //             const SizedBox(height: 24),
// // // // // //             if (_isLoading)
// // // // // //               const CircularProgressIndicator()
// // // // // //             else if (_analysisResult != null) ...[
// // // // // //               const Align(
// // // // // //                 alignment: Alignment.centerLeft,
// // // // // //                 child: Text('분석 결과', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // // //               ),
// // // // // //               const SizedBox(height: 8),
// // // // // //               Card(
// // // // // //                 child: Padding(
// // // // // //                   padding: const EdgeInsets.all(16),
// // // // // //                   child: Column(
// // // // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //                     children: [
// // // // // //                       Text('카테고리: ${_analysisResult?['category'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // // //                       const SizedBox(height: 6),
// // // // // //                       Text('액션 타입: ${_analysisResult?['action_type'] ?? '-'}'),
// // // // // //                       const SizedBox(height: 6),
// // // // // //                       Text('요약: ${_analysisResult?['summary'] ?? '-'}'),
// // // // // //                       if (_analysisResult?['action_data'] != null && _analysisResult?['action_data'] != "") ...[
// // // // // //                         const SizedBox(height: 6),
// // // // // //                         Text('상세: ${_analysisResult?['action_data']}'),
// // // // // //                       ],
// // // // // //                     ],
// // // // // //                   ),
// // // // // //                 ),
// // // // // //               ),
// // // // // //             ],
// // // // // //           ],
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // // }

// // // // // // // -------------------------------------------------------------
// // // // // // // 2. 캘린더 탭 (/api/v1/calendar/ 연동 및 날짜별 로컬 매핑)
// // // // // // // -------------------------------------------------------------
// // // // // // class CalendarScreen extends StatefulWidget {
// // // // // //   const CalendarScreen({super.key});

// // // // // //   @override
// // // // // //   State<CalendarScreen> createState() => _CalendarScreenState();
// // // // // // }

// // // // // // class _CalendarScreenState extends State<CalendarScreen> {
// // // // // //   CalendarFormat _calendarFormat = CalendarFormat.month;
// // // // // //   DateTime _focusedDay = DateTime.now();
// // // // // //   DateTime? _selectedDay;
  
// // // // // //   // 날짜별 일정 매핑 Map (Key: DateTime(년, 월, 일), Value: 해당 날짜의 일정 리스트)
// // // // // //   Map<DateTime, List<dynamic>> _eventsMap = {};
// // // // // //   bool _isLoading = true;

// // // // // //   @override
// // // // // //   void initState() {
// // // // // //     super.initState();
// // // // // //     _selectedDay = _focusedDay;
// // // // // //     _fetchCalendarEvents();
// // // // // //   }

// // // // // //   // 로컬 기준 년/월/일 정규화 함수
// // // // // //   DateTime _normalizeDate(DateTime dt) {
// // // // // //     return DateTime(dt.year, dt.month, dt.day);
// // // // // //   }

// // // // // //   Future<void> _fetchCalendarEvents() async {
// // // // // //     if (!mounted) return;
// // // // // //     setState(() => _isLoading = true);

// // // // // //     try {
// // // // // //       final response = await http.get(Uri.parse('$baseUrl/api/v1/calendar/'));
// // // // // //       if (response.statusCode == 200 && mounted) {
// // // // // //         final data = jsonDecode(utf8.decode(response.bodyBytes));
// // // // // //         final List<dynamic> rawEvents = data['events'] ?? [];

// // // // // //         // RDB에서 가져온 이벤트를 로컬 날짜 키 기준으로 매핑
// // // // // //         final Map<DateTime, List<dynamic>> newMap = {};
// // // // // //         for (var item in rawEvents) {
// // // // // //           final dateStr = item['event_date'];
// // // // // //           if (dateStr != null) {
// // // // // //             try {
// // // // // //               final parts = dateStr.toString().substring(0, 10).split('-');
// // // // // //               final key = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
// // // // // //               if (newMap[key] == null) {
// // // // // //                 newMap[key] = [];
// // // // // //               }
// // // // // //               newMap[key]!.add(item);
// // // // // //             } catch (_) {}
// // // // // //           }
// // // // // //         }

// // // // // //         setState(() {
// // // // // //           _eventsMap = newMap;
// // // // // //         });
// // // // // //       }
// // // // // //     } catch (e) {
// // // // // //       // 에러 핸들링
// // // // // //     } finally {
// // // // // //       if (mounted) {
// // // // // //         setState(() => _isLoading = false);
// // // // // //       }
// // // // // //     }
// // // // // //   }

// // // // // //   // 특정 날짜의 일정 목록 가져오기 (마커 렌더링 및 하단 리스트용)
// // // // // //   List<dynamic> _getEventsForDay(DateTime day) {
// // // // // //     return _eventsMap[_normalizeDate(day)] ?? [];
// // // // // //   }

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     final selectedEvents = _selectedDay != null ? _getEventsForDay(_selectedDay!) : [];

// // // // // //     return Scaffold(
// // // // // //       appBar: AppBar(
// // // // // //         title: const Text('등록된 일정'),
// // // // // //         actions: [
// // // // // //           IconButton(onPressed: _fetchCalendarEvents, icon: const Icon(Icons.refresh)),
// // // // // //         ],
// // // // // //       ),
// // // // // //       body: _isLoading
// // // // // //           ? const Center(child: CircularProgressIndicator())
// // // // // //           : Column(
// // // // // //               children: [
// // // // // //                 TableCalendar(
// // // // // //                   firstDay: DateTime.utc(2020, 1, 1),
// // // // // //                   lastDay: DateTime.utc(2030, 12, 31),
// // // // // //                   focusedDay: _focusedDay,
// // // // // //                   calendarFormat: _calendarFormat,
// // // // // //                   selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
// // // // // //                   eventLoader: _getEventsForDay, // 캘린더 날짜에 이벤트 마커 표시
// // // // // //                   onDaySelected: (selectedDay, focusedDay) {
// // // // // //                     if (!mounted) return;
// // // // // //                     setState(() {
// // // // // //                       _selectedDay = selectedDay;
// // // // // //                       _focusedDay = focusedDay;
// // // // // //                     });
// // // // // //                   },
// // // // // //                   onFormatChanged: (format) {
// // // // // //                     if (!mounted) return;
// // // // // //                     setState(() => _calendarFormat = format);
// // // // // //                   },
// // // // // //                   calendarStyle: const CalendarStyle(
// // // // // //                     markerDecoration: BoxDecoration(
// // // // // //                       color: Colors.deepPurple,
// // // // // //                       shape: BoxShape.circle,
// // // // // //                     ),
// // // // // //                   ),
// // // // // //                 ),
// // // // // //                 const Divider(),
// // // // // //                 // 선택한 날짜의 일정 목록 표시
// // // // // //                 Expanded(
// // // // // //                   child: selectedEvents.isEmpty
// // // // // //                       ? const Center(child: Text('해당 날짜에 등록된 일정이 없습니다.'))
// // // // // //                       : ListView.builder(
// // // // // //                           itemCount: selectedEvents.length,
// // // // // //                           itemBuilder: (context, index) {
// // // // // //                             final item = selectedEvents[index];
// // // // // //                             return Card(
// // // // // //                               margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
// // // // // //                               child: ListTile(
// // // // // //                                 leading: const Icon(Icons.event, color: Colors.deepPurple),
// // // // // //                                 title: Text(item['title'] ?? '일정 제목 없음', style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // // //                                 subtitle: Text('날짜: ${item['event_date']}'),
// // // // // //                                 trailing: item['image_url'] != null
// // // // // //                                     ? ClipRRect(
// // // // // //                                         borderRadius: BorderRadius.circular(6),
// // // // // //                                         child: Image.network(
// // // // // //                                           item['image_url'],
// // // // // //                                           width: 45,
// // // // // //                                           height: 45,
// // // // // //                                           fit: BoxFit.cover,
// // // // // //                                           errorBuilder: (context, error, stackTrace) =>
// // // // // //                                               const Icon(Icons.broken_image, size: 30),
// // // // // //                                         ),
// // // // // //                                       )
// // // // // //                                     : null,
// // // // // //                               ),
// // // // // //                             );
// // // // // //                           },
// // // // // //                         ),
// // // // // //                 ),
// // // // // //               ],
// // // // // //             ),
// // // // // //     );
// // // // // //   }
// // // // // // }

// // // // // // // -------------------------------------------------------------
// // // // // // // 3. 히스토리 탭 (/api/v1/history/ 연동)
// // // // // // // -------------------------------------------------------------
// // // // // // class HistoryScreen extends StatefulWidget {
// // // // // //   const HistoryScreen({super.key});

// // // // // //   @override
// // // // // //   State<HistoryScreen> createState() => _HistoryScreenState();
// // // // // // }

// // // // // // class _HistoryScreenState extends State<HistoryScreen> {
// // // // // //   List<dynamic> _historyList = [];
// // // // // //   bool _isLoading = true;

// // // // // //   @override
// // // // // //   void initState() {
// // // // // //     super.initState();
// // // // // //     _fetchHistory();
// // // // // //   }

// // // // // //   Future<void> _fetchHistory() async {
// // // // // //     if (!mounted) return;
// // // // // //     setState(() => _isLoading = true);

// // // // // //     try {
// // // // // //       final response = await http.get(Uri.parse('$baseUrl/api/v1/history/'));
// // // // // //       if (response.statusCode == 200 && mounted) {
// // // // // //         final data = jsonDecode(utf8.decode(response.bodyBytes));
// // // // // //         setState(() {
// // // // // //           _historyList = data['history'] ?? [];
// // // // // //         });
// // // // // //       }
// // // // // //     } catch (e) {
// // // // // //       // 에러 핸들링
// // // // // //     } finally {
// // // // // //       if (mounted) {
// // // // // //         setState(() => _isLoading = false);
// // // // // //       }
// // // // // //     }
// // // // // //   }

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     return Scaffold(
// // // // // //       appBar: AppBar(
// // // // // //         title: const Text('분석 히스토리'),
// // // // // //         actions: [
// // // // // //           IconButton(onPressed: _fetchHistory, icon: const Icon(Icons.refresh)),
// // // // // //         ],
// // // // // //       ),
// // // // // //       body: _isLoading
// // // // // //           ? const Center(child: CircularProgressIndicator())
// // // // // //           : _historyList.isEmpty
// // // // // //               ? const Center(child: Text('히스토리가 없습니다.'))
// // // // // //               : ListView.builder(
// // // // // //                   padding: const EdgeInsets.symmetric(vertical: 8),
// // // // // //                   itemCount: _historyList.length,
// // // // // //                   itemBuilder: (context, index) {
// // // // // //                     final item = _historyList[index];
// // // // // //                     final actionType = item['action_type'] ?? '';

// // // // // //                     return Card(
// // // // // //                       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // // // // //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // // // // //                       elevation: 2,
// // // // // //                       child: InkWell(
// // // // // //                         borderRadius: BorderRadius.circular(12),
// // // // // //                         onTap: () {
// // // // // //                           Navigator.push(
// // // // // //                             context,
// // // // // //                             MaterialPageRoute(
// // // // // //                               builder: (context) => HistoryDetailScreen(item: item),
// // // // // //                             ),
// // // // // //                           );
// // // // // //                         },
// // // // // //                         child: Padding(
// // // // // //                           padding: const EdgeInsets.all(12),
// // // // // //                           child: Row(
// // // // // //                             children: [
// // // // // //                               ClipRRect(
// // // // // //                                 borderRadius: BorderRadius.circular(8),
// // // // // //                                 child: item['image_url'] != null
// // // // // //                                     ? Image.network(
// // // // // //                                         item['image_url'],
// // // // // //                                         width: 65,
// // // // // //                                         height: 65,
// // // // // //                                         fit: BoxFit.cover,
// // // // // //                                         errorBuilder: (context, error, stackTrace) =>
// // // // // //                                             Container(width: 65, height: 65, color: Colors.grey.shade300, child: const Icon(Icons.broken_image)),
// // // // // //                                       )
// // // // // //                                     : Container(width: 65, height: 65, color: Colors.grey.shade300, child: const Icon(Icons.image)),
// // // // // //                               ),
// // // // // //                               const SizedBox(width: 14),
// // // // // //                               Expanded(
// // // // // //                                 child: Column(
// // // // // //                                   crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //                                   children: [
// // // // // //                                     Row(
// // // // // //                                       children: [
// // // // // //                                         Container(
// // // // // //                                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
// // // // // //                                           decoration: BoxDecoration(
// // // // // //                                             color: Colors.deepPurple.shade50,
// // // // // //                                             borderRadius: BorderRadius.circular(6),
// // // // // //                                           ),
// // // // // //                                           child: Text(
// // // // // //                                             item['category'] ?? '미분류',
// // // // // //                                             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepPurple),
// // // // // //                                           ),
// // // // // //                                         ),
// // // // // //                                         const Spacer(),
// // // // // //                                         if (actionType.contains('일정') || actionType.contains('캘린더'))
// // // // // //                                           const Icon(Icons.calendar_month, size: 18, color: Colors.blueAccent)
// // // // // //                                         else if (actionType.contains('지도') || actionType.contains('매핑'))
// // // // // //                                           const Icon(Icons.location_on, size: 18, color: Colors.redAccent),
// // // // // //                                       ],
// // // // // //                                     ),
// // // // // //                                     const SizedBox(height: 6),
// // // // // //                                     Text(
// // // // // //                                       item['summary'] ?? '요약 내용 없음',
// // // // // //                                       maxLines: 2,
// // // // // //                                       overflow: TextOverflow.ellipsis,
// // // // // //                                       style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
// // // // // //                                     ),
// // // // // //                                   ],
// // // // // //                                 ),
// // // // // //                               ),
// // // // // //                               const Icon(Icons.chevron_right, color: Colors.grey),
// // // // // //                             ],
// // // // // //                           ),
// // // // // //                         ),
// // // // // //                       ),
// // // // // //                     );
// // // // // //                   },
// // // // // //                 ),
// // // // // //     );
// // // // // //   }
// // // // // // }

// // // // // // // -------------------------------------------------------------
// // // // // // // 4. 히스토리 상세 화면 (action_data 주소 최우선 네이버 지도 연동)
// // // // // // // -------------------------------------------------------------
// // // // // // class HistoryDetailScreen extends StatelessWidget {
// // // // // //   final Map<String, dynamic> item;

// // // // // //   const HistoryDetailScreen({super.key, required this.item});

// // // // // //   Future<void> _openNaverMap(String addressQuery) async {
// // // // // //     final query = addressQuery.trim();
// // // // // //     if (query.isEmpty) return;

// // // // // //     final encodedQuery = Uri.encodeComponent(query);
// // // // // //     final url = Uri.parse('https://m.map.naver.com/search2/search.naver?query=$encodedQuery');
// // // // // //     if (await canLaunchUrl(url)) {
// // // // // //       await launchUrl(url, mode: LaunchMode.externalApplication);
// // // // // //     }
// // // // // //   }

// // // // // //   // 검색할 최적의 주소/장소명 추출 (action_data -> places[0].address -> summary 순)
// // // // // //   String _resolveSearchTarget() {
// // // // // //     // 1. 백엔드에서 places의 주소로 채워 전달한 action_data를 1순위로 확인
// // // // // //     final actionData = item['action_data']?.toString().trim() ?? '';
// // // // // //     if (actionData.isNotEmpty) return actionData;

// // // // // //     // 2. places 배열이 직접 넘어온 경우
// // // // // //     if (item['places'] is List && (item['places'] as List).isNotEmpty) {
// // // // // //       final firstPlace = item['places'][0];
// // // // // //       if (firstPlace is Map) {
// // // // // //         final address = firstPlace['address']?.toString().trim() ?? '';
// // // // // //         if (address.isNotEmpty) return address;

// // // // // //         final placeName = firstPlace['place_name']?.toString().trim() ?? '';
// // // // // //         if (placeName.isNotEmpty) return placeName;
// // // // // //       }
// // // // // //     }

// // // // // //     // 3. 마지막 fallback: summary
// // // // // //     return item['summary']?.toString().trim() ?? '';
// // // // // //   }

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     final actionType = item['action_type'] ?? '해당없음';
// // // // // //     final isCalendarAction = actionType.contains('일정') || actionType.contains('캘린더');
// // // // // //     final isMapAction = actionType.contains('지도') || actionType.contains('매핑');
    
// // // // // //     final searchTarget = _resolveSearchTarget();
// // // // // //     final rawActionData = item['action_data']?.toString().trim() ?? '';

// // // // // //     return Scaffold(
// // // // // //       appBar: AppBar(
// // // // // //         title: const Text('분석 상세 정보'),
// // // // // //       ),
// // // // // //       body: SingleChildScrollView(
// // // // // //         padding: const EdgeInsets.all(16),
// // // // // //         child: Column(
// // // // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //           children: [
// // // // // //             if (item['image_url'] != null)
// // // // // //               ClipRRect(
// // // // // //                 borderRadius: BorderRadius.circular(12),
// // // // // //                 child: Image.network(
// // // // // //                   item['image_url'],
// // // // // //                   width: double.infinity,
// // // // // //                   height: 260,
// // // // // //                   fit: BoxFit.contain,
// // // // // //                   errorBuilder: (context, error, stackTrace) =>
// // // // // //                       Container(height: 180, color: Colors.grey.shade200, child: const Center(child: Icon(Icons.broken_image, size: 48))),
// // // // // //                 ),
// // // // // //               ),
// // // // // //             const SizedBox(height: 16),

// // // // // //             // 1. 네이버 지도 검색 연동 카드 (추출된 주소 기준)
// // // // // //             if (isMapAction)
// // // // // //               Card(
// // // // // //                 color: Colors.green.shade50,
// // // // // //                 shape: RoundedRectangleBorder(
// // // // // //                   borderRadius: BorderRadius.circular(12),
// // // // // //                   side: BorderSide(color: Colors.green.shade200),
// // // // // //                 ),
// // // // // //                 margin: const EdgeInsets.only(bottom: 16),
// // // // // //                 child: Padding(
// // // // // //                   padding: const EdgeInsets.all(16),
// // // // // //                   child: Column(
// // // // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //                     children: [
// // // // // //                       const Row(
// // // // // //                         children: [
// // // // // //                           Icon(Icons.location_on, color: Colors.green),
// // // // // //                           SizedBox(width: 8),
// // // // // //                           Text('지도 검색 위치 (도로명 주소/상호명)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
// // // // // //                         ],
// // // // // //                       ),
// // // // // //                       const SizedBox(height: 8),
// // // // // //                       Text(
// // // // // //                         searchTarget.isNotEmpty ? searchTarget : '등록된 주소 정보가 없습니다.',
// // // // // //                         style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
// // // // // //                       ),
// // // // // //                       const SizedBox(height: 12),
// // // // // //                       ElevatedButton.icon(
// // // // // //                         onPressed: searchTarget.isNotEmpty ? () => _openNaverMap(searchTarget) : null,
// // // // // //                         icon: const Icon(Icons.map_outlined, color: Colors.white),
// // // // // //                         label: const Text('네이버 지도에서 위치 확인', style: TextStyle(color: Colors.white)),
// // // // // //                         style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF03C75A)),
// // // // // //                       ),
// // // // // //                     ],
// // // // // //                   ),
// // // // // //                 ),
// // // // // //               ),

// // // // // //             // 2. 캘린더 등록 알림 섹션
// // // // // //             if (isCalendarAction)
// // // // // //               Container(
// // // // // //                 margin: const EdgeInsets.only(bottom: 16),
// // // // // //                 padding: const EdgeInsets.all(12),
// // // // // //                 decoration: BoxDecoration(
// // // // // //                   color: Colors.blue.shade50,
// // // // // //                   borderRadius: BorderRadius.circular(8),
// // // // // //                   border: Border.all(color: Colors.blue.shade200),
// // // // // //                 ),
// // // // // //                 child: const Row(
// // // // // //                   children: [
// // // // // //                     Icon(Icons.event_available, color: Colors.blue),
// // // // // //                     SizedBox(width: 8),
// // // // // //                     Expanded(
// // // // // //                       child: Text('캘린더 일정으로 등록된 항목입니다.', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
// // // // // //                     ),
// // // // // //                   ],
// // // // // //                 ),
// // // // // //               ),

// // // // // //             // 3. 요약 정보 카드
// // // // // //             Card(
// // // // // //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // // // // //               child: Padding(
// // // // // //                 padding: const EdgeInsets.all(16),
// // // // // //                 child: Column(
// // // // // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //                   children: [
// // // // // //                     _buildInfoRow('카테고리', item['category'] ?? '-'),
// // // // // //                     const Divider(height: 24),
// // // // // //                     _buildInfoRow('액션 분류', actionType),
// // // // // //                     const Divider(height: 24),
// // // // // //                     _buildInfoRow('요약 내용', item['summary'] ?? '-'),
// // // // // //                     if (searchTarget.isNotEmpty) ...[
// // // // // //                       const Divider(height: 24),
// // // // // //                       _buildInfoRow('추출 주소 / 상세 데이터', searchTarget),
// // // // // //                     ] else if (rawActionData.isNotEmpty) ...[
// // // // // //                       const Divider(height: 24),
// // // // // //                       _buildInfoRow('상세 데이터', rawActionData),
// // // // // //                     ],
// // // // // //                     if (item['created_at'] != null) ...[
// // // // // //                       const Divider(height: 24),
// // // // // //                       _buildInfoRow('분석 일시', item['created_at'].toString().split('.')[0].replaceAll('T', ' ')),
// // // // // //                     ],
// // // // // //                   ],
// // // // // //                 ),
// // // // // //               ),
// // // // // //             ),
// // // // // //           ],
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   Widget _buildInfoRow(String label, String value) {
// // // // // //     return Column(
// // // // // //       crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //       children: [
// // // // // //         Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
// // // // // //         const SizedBox(height: 4),
// // // // // //         Text(value, style: const TextStyle(fontSize: 15, height: 1.4)),
// // // // // //       ],
// // // // // //     );
// // // // // //   }
// // // // // // }

// // // // // // // import 'dart:convert';
// // // // // // // import 'dart:io';
// // // // // // // import 'package:flutter/material.dart';
// // // // // // // import 'package:http/http.dart' as http;
// // // // // // // import 'package:image_picker/image_picker.dart';
// // // // // // // import 'package:table_calendar/table_calendar.dart';
// // // // // // // import 'package:url_launcher/url_launcher.dart';

// // // // // // // // 로컬 환경에 맞게 서버 IP/포트 설정 (안드로이드 에뮬레이터 기준 10.0.2.2:8000, 실제 기기는 PC IP 입력)
// // // // // // // const String baseUrl = "http://10.0.2.2:8000";

// // // // // // // void main() {
// // // // // // //   runApp(const MyApp());
// // // // // // // }

// // // // // // // class MyApp extends StatelessWidget {
// // // // // // //   const MyApp({super.key});

// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     return MaterialApp(
// // // // // // //       title: 'T.Salmon',
// // // // // // //       theme: ThemeData(
// // // // // // //         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
// // // // // // //         useMaterial3: true,
// // // // // // //       ),
// // // // // // //       home: const MainNavigationScreen(),
// // // // // // //     );
// // // // // // //   }
// // // // // // // }

// // // // // // // class MainNavigationScreen extends StatefulWidget {
// // // // // // //   const MainNavigationScreen({super.key});

// // // // // // //   @override
// // // // // // //   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// // // // // // // }

// // // // // // // class _MainNavigationScreenState extends State<MainNavigationScreen> {
// // // // // // //   int _currentIndex = 0;

// // // // // // //   final List<Widget> _screens = const [
// // // // // // //     UploadScreen(),
// // // // // // //     CalendarScreen(),
// // // // // // //     HistoryScreen(),
// // // // // // //   ];

// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     return Scaffold(
// // // // // // //       body: _screens[_currentIndex],
// // // // // // //       bottomNavigationBar: NavigationBar(
// // // // // // //         selectedIndex: _currentIndex,
// // // // // // //         onDestinationSelected: (index) => setState(() => _currentIndex = index),
// // // // // // //         destinations: const [
// // // // // // //           NavigationDestination(
// // // // // // //             icon: Icon(Icons.cloud_upload_outlined),
// // // // // // //             selectedIcon: Icon(Icons.cloud_upload),
// // // // // // //             label: '업로드',
// // // // // // //           ),
// // // // // // //           NavigationDestination(
// // // // // // //             icon: Icon(Icons.calendar_month_outlined),
// // // // // // //             selectedIcon: Icon(Icons.calendar_month),
// // // // // // //             label: '캘린더',
// // // // // // //           ),
// // // // // // //           NavigationDestination(
// // // // // // //             icon: Icon(Icons.history_outlined),
// // // // // // //             selectedIcon: Icon(Icons.history),
// // // // // // //             label: '히스토리',
// // // // // // //           ),
// // // // // // //         ],
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }
// // // // // // // }

// // // // // // // // -------------------------------------------------------------
// // // // // // // // 1. 업로드 탭 (스크린샷 수동 선택 및 /api/v1/analyze 호출)
// // // // // // // // -------------------------------------------------------------
// // // // // // // class UploadScreen extends StatefulWidget {
// // // // // // //   const UploadScreen({super.key});

// // // // // // //   @override
// // // // // // //   State<UploadScreen> createState() => _UploadScreenState();
// // // // // // // }

// // // // // // // class _UploadScreenState extends State<UploadScreen> {
// // // // // // //   File? _selectedImage;
// // // // // // //   bool _isLoading = false;
// // // // // // //   Map<String, dynamic>? _analysisResult;

// // // // // // //   final ImagePicker _picker = ImagePicker();

// // // // // // //   Future<void> _pickAndUploadImage() async {
// // // // // // //     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
// // // // // // //     if (pickedFile == null) return;

// // // // // // //     if (!mounted) return;
// // // // // // //     setState(() {
// // // // // // //       _selectedImage = File(pickedFile.path);
// // // // // // //       _isLoading = true;
// // // // // // //       _analysisResult = null;
// // // // // // //     });

// // // // // // //     try {
// // // // // // //       final uri = Uri.parse('$baseUrl/api/v1/analyze');
// // // // // // //       final request = http.MultipartRequest('POST', uri);
// // // // // // //       request.files.add(await http.MultipartFile.fromPath('file', pickedFile.path));

// // // // // // //       final streamedResponse = await request.send();
// // // // // // //       final response = await http.Response.fromStream(streamedResponse);

// // // // // // //       if (response.statusCode == 200) {
// // // // // // //         final decoded = jsonDecode(utf8.decode(response.bodyBytes));
// // // // // // //         if (mounted) {
// // // // // // //           setState(() {
// // // // // // //             _analysisResult = decoded['analysis'];
// // // // // // //           });
// // // // // // //           ScaffoldMessenger.of(context).showSnackBar(
// // // // // // //             const SnackBar(content: Text('분석 및 저장이 완료되었습니다!')),
// // // // // // //           );
// // // // // // //         }
// // // // // // //       } else {
// // // // // // //         throw Exception('서버 응답 오류: ${response.statusCode}');
// // // // // // //       }
// // // // // // //     } catch (e) {
// // // // // // //       if (mounted) {
// // // // // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // // // // //           SnackBar(content: Text('업로드 실패: $e')),
// // // // // // //         );
// // // // // // //       }
// // // // // // //     } finally {
// // // // // // //       if (mounted) {
// // // // // // //         setState(() => _isLoading = false);
// // // // // // //       }
// // // // // // //     }
// // // // // // //   }

// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     return Scaffold(
// // // // // // //       appBar: AppBar(title: const Text('스크린샷 분석')),
// // // // // // //       body: SingleChildScrollView(
// // // // // // //         padding: const EdgeInsets.all(16),
// // // // // // //         child: Column(
// // // // // // //           children: [
// // // // // // //             if (_selectedImage != null)
// // // // // // //               ClipRRect(
// // // // // // //                 borderRadius: BorderRadius.circular(12),
// // // // // // //                 child: Image.file(_selectedImage!, height: 260, fit: BoxFit.cover),
// // // // // // //               )
// // // // // // //             else
// // // // // // //               Container(
// // // // // // //                 height: 200,
// // // // // // //                 decoration: BoxDecoration(
// // // // // // //                   color: Colors.grey.shade200,
// // // // // // //                   borderRadius: BorderRadius.circular(12),
// // // // // // //                 ),
// // // // // // //                 child: const Center(child: Text('분석할 스크린샷을 선택하세요')),
// // // // // // //               ),
// // // // // // //             const SizedBox(height: 20),
// // // // // // //             ElevatedButton.icon(
// // // // // // //               onPressed: _isLoading ? null : _pickAndUploadImage,
// // // // // // //               icon: const Icon(Icons.photo_library),
// // // // // // //               label: Text(_isLoading ? '분석 중...' : '갤러리에서 선택 및 분석'),
// // // // // // //               style: ElevatedButton.styleFrom(
// // // // // // //                 minimumSize: const Size.fromHeight(50),
// // // // // // //               ),
// // // // // // //             ),
// // // // // // //             const SizedBox(height: 24),
// // // // // // //             if (_isLoading)
// // // // // // //               const CircularProgressIndicator()
// // // // // // //             else if (_analysisResult != null) ...[
// // // // // // //               const Align(
// // // // // // //                 alignment: Alignment.centerLeft,
// // // // // // //                 child: Text('분석 결과', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // // // //               ),
// // // // // // //               const SizedBox(height: 8),
// // // // // // //               Card(
// // // // // // //                 child: Padding(
// // // // // // //                   padding: const EdgeInsets.all(16),
// // // // // // //                   child: Column(
// // // // // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // //                     children: [
// // // // // // //                       Text('카테고리: ${_analysisResult?['category'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // // // //                       const SizedBox(height: 6),
// // // // // // //                       Text('액션 타입: ${_analysisResult?['action_type'] ?? '-'}'),
// // // // // // //                       const SizedBox(height: 6),
// // // // // // //                       Text('요약: ${_analysisResult?['summary'] ?? '-'}'),
// // // // // // //                       if (_analysisResult?['action_data'] != null && _analysisResult?['action_data'] != "") ...[
// // // // // // //                         const SizedBox(height: 6),
// // // // // // //                         Text('상세: ${_analysisResult?['action_data']}'),
// // // // // // //                       ],
// // // // // // //                     ],
// // // // // // //                   ),
// // // // // // //                 ),
// // // // // // //               ),
// // // // // // //             ],
// // // // // // //           ],
// // // // // // //         ),
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }
// // // // // // // }

// // // // // // // // -------------------------------------------------------------
// // // // // // // // 2. 캘린더 탭 (/api/v1/calendar/ 연동 및 날짜별 로컬 매핑)
// // // // // // // // -------------------------------------------------------------
// // // // // // // class CalendarScreen extends StatefulWidget {
// // // // // // //   const CalendarScreen({super.key});

// // // // // // //   @override
// // // // // // //   State<CalendarScreen> createState() => _CalendarScreenState();
// // // // // // // }

// // // // // // // class _CalendarScreenState extends State<CalendarScreen> {
// // // // // // //   CalendarFormat _calendarFormat = CalendarFormat.month;
// // // // // // //   DateTime _focusedDay = DateTime.now();
// // // // // // //   DateTime? _selectedDay;
  
// // // // // // //   // 날짜별 일정 매핑 Map (Key: DateTime(년, 월, 일), Value: 해당 날짜의 일정 리스트)
// // // // // // //   Map<DateTime, List<dynamic>> _eventsMap = {};
// // // // // // //   bool _isLoading = true;

// // // // // // //   @override
// // // // // // //   void initState() {
// // // // // // //     super.initState();
// // // // // // //     _selectedDay = _focusedDay;
// // // // // // //     _fetchCalendarEvents();
// // // // // // //   }

// // // // // // //   // 로컬 기준 년/월/일 정규화 함수
// // // // // // //   DateTime _normalizeDate(DateTime dt) {
// // // // // // //     return DateTime(dt.year, dt.month, dt.day);
// // // // // // //   }

// // // // // // //   Future<void> _fetchCalendarEvents() async {
// // // // // // //     if (!mounted) return;
// // // // // // //     setState(() => _isLoading = true);

// // // // // // //     try {
// // // // // // //       final response = await http.get(Uri.parse('$baseUrl/api/v1/calendar/'));
// // // // // // //       if (response.statusCode == 200 && mounted) {
// // // // // // //         final data = jsonDecode(utf8.decode(response.bodyBytes));
// // // // // // //         final List<dynamic> rawEvents = data['events'] ?? [];

// // // // // // //         // RDB에서 가져온 이벤트를 로컬 날짜 키 기준으로 매핑
// // // // // // //         final Map<DateTime, List<dynamic>> newMap = {};
// // // // // // //         for (var item in rawEvents) {
// // // // // // //           final dateStr = item['event_date'];
// // // // // // //           if (dateStr != null) {
// // // // // // //             try {
// // // // // // //               final parts = dateStr.toString().substring(0, 10).split('-');
// // // // // // //               final key = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
// // // // // // //               if (newMap[key] == null) {
// // // // // // //                 newMap[key] = [];
// // // // // // //               }
// // // // // // //               newMap[key]!.add(item);
// // // // // // //             } catch (_) {}
// // // // // // //           }
// // // // // // //         }

// // // // // // //         setState(() {
// // // // // // //           _eventsMap = newMap;
// // // // // // //         });
// // // // // // //       }
// // // // // // //     } catch (e) {
// // // // // // //       // 에러 핸들링
// // // // // // //     } finally {
// // // // // // //       if (mounted) {
// // // // // // //         setState(() => _isLoading = false);
// // // // // // //       }
// // // // // // //     }
// // // // // // //   }

// // // // // // //   // 특정 날짜의 일정 목록 가져오기 (마커 렌더링 및 하단 리스트용)
// // // // // // //   List<dynamic> _getEventsForDay(DateTime day) {
// // // // // // //     return _eventsMap[_normalizeDate(day)] ?? [];
// // // // // // //   }

// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     final selectedEvents = _selectedDay != null ? _getEventsForDay(_selectedDay!) : [];

// // // // // // //     return Scaffold(
// // // // // // //       appBar: AppBar(
// // // // // // //         title: const Text('등록된 일정'),
// // // // // // //         actions: [
// // // // // // //           IconButton(onPressed: _fetchCalendarEvents, icon: const Icon(Icons.refresh)),
// // // // // // //         ],
// // // // // // //       ),
// // // // // // //       body: _isLoading
// // // // // // //           ? const Center(child: CircularProgressIndicator())
// // // // // // //           : Column(
// // // // // // //               children: [
// // // // // // //                 TableCalendar(
// // // // // // //                   firstDay: DateTime.utc(2020, 1, 1),
// // // // // // //                   lastDay: DateTime.utc(2030, 12, 31),
// // // // // // //                   focusedDay: _focusedDay,
// // // // // // //                   calendarFormat: _calendarFormat,
// // // // // // //                   selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
// // // // // // //                   eventLoader: _getEventsForDay, // 캘린더 날짜에 이벤트 마커 표시
// // // // // // //                   onDaySelected: (selectedDay, focusedDay) {
// // // // // // //                     if (!mounted) return;
// // // // // // //                     setState(() {
// // // // // // //                       _selectedDay = selectedDay;
// // // // // // //                       _focusedDay = focusedDay;
// // // // // // //                     });
// // // // // // //                   },
// // // // // // //                   onFormatChanged: (format) {
// // // // // // //                     if (!mounted) return;
// // // // // // //                     setState(() => _calendarFormat = format);
// // // // // // //                   },
// // // // // // //                   calendarStyle: const CalendarStyle(
// // // // // // //                     markerDecoration: BoxDecoration(
// // // // // // //                       color: Colors.deepPurple,
// // // // // // //                       shape: BoxShape.circle,
// // // // // // //                     ),
// // // // // // //                   ),
// // // // // // //                 ),
// // // // // // //                 const Divider(),
// // // // // // //                 // 선택한 날짜의 일정 목록 표시
// // // // // // //                 Expanded(
// // // // // // //                   child: selectedEvents.isEmpty
// // // // // // //                       ? const Center(child: Text('해당 날짜에 등록된 일정이 없습니다.'))
// // // // // // //                       : ListView.builder(
// // // // // // //                           itemCount: selectedEvents.length,
// // // // // // //                           itemBuilder: (context, index) {
// // // // // // //                             final item = selectedEvents[index];
// // // // // // //                             return Card(
// // // // // // //                               margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
// // // // // // //                               child: ListTile(
// // // // // // //                                 leading: const Icon(Icons.event, color: Colors.deepPurple),
// // // // // // //                                 title: Text(item['title'] ?? '일정 제목 없음', style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // // // //                                 subtitle: Text('날짜: ${item['event_date']}'),
// // // // // // //                                 trailing: item['image_url'] != null
// // // // // // //                                     ? ClipRRect(
// // // // // // //                                         borderRadius: BorderRadius.circular(6),
// // // // // // //                                         child: Image.network(
// // // // // // //                                           item['image_url'],
// // // // // // //                                           width: 45,
// // // // // // //                                           height: 45,
// // // // // // //                                           fit: BoxFit.cover,
// // // // // // //                                           errorBuilder: (context, error, stackTrace) =>
// // // // // // //                                               const Icon(Icons.broken_image, size: 30),
// // // // // // //                                         ),
// // // // // // //                                       )
// // // // // // //                                     : null,
// // // // // // //                               ),
// // // // // // //                             );
// // // // // // //                           },
// // // // // // //                         ),
// // // // // // //                 ),
// // // // // // //               ],
// // // // // // //             ),
// // // // // // //     );
// // // // // // //   }
// // // // // // // }

// // // // // // // // -------------------------------------------------------------
// // // // // // // // 3. 히스토리 탭 (/api/v1/history/ 연동)
// // // // // // // // -------------------------------------------------------------
// // // // // // // class HistoryScreen extends StatefulWidget {
// // // // // // //   const HistoryScreen({super.key});

// // // // // // //   @override
// // // // // // //   State<HistoryScreen> createState() => _HistoryScreenState();
// // // // // // // }

// // // // // // // class _HistoryScreenState extends State<HistoryScreen> {
// // // // // // //   List<dynamic> _historyList = [];
// // // // // // //   bool _isLoading = true;

// // // // // // //   @override
// // // // // // //   void initState() {
// // // // // // //     super.initState();
// // // // // // //     _fetchHistory();
// // // // // // //   }

// // // // // // //   Future<void> _fetchHistory() async {
// // // // // // //     if (!mounted) return;
// // // // // // //     setState(() => _isLoading = true);

// // // // // // //     try {
// // // // // // //       final response = await http.get(Uri.parse('$baseUrl/api/v1/history/'));
// // // // // // //       if (response.statusCode == 200 && mounted) {
// // // // // // //         final data = jsonDecode(utf8.decode(response.bodyBytes));
// // // // // // //         setState(() {
// // // // // // //           _historyList = data['history'] ?? [];
// // // // // // //         });
// // // // // // //       }
// // // // // // //     } catch (e) {
// // // // // // //       // 에러 핸들링
// // // // // // //     } finally {
// // // // // // //       if (mounted) {
// // // // // // //         setState(() => _isLoading = false);
// // // // // // //       }
// // // // // // //     }
// // // // // // //   }

// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     return Scaffold(
// // // // // // //       appBar: AppBar(
// // // // // // //         title: const Text('분석 히스토리'),
// // // // // // //         actions: [
// // // // // // //           IconButton(onPressed: _fetchHistory, icon: const Icon(Icons.refresh)),
// // // // // // //         ],
// // // // // // //       ),
// // // // // // //       body: _isLoading
// // // // // // //           ? const Center(child: CircularProgressIndicator())
// // // // // // //           : _historyList.isEmpty
// // // // // // //               ? const Center(child: Text('히스토리가 없습니다.'))
// // // // // // //               : ListView.builder(
// // // // // // //                   padding: const EdgeInsets.symmetric(vertical: 8),
// // // // // // //                   itemCount: _historyList.length,
// // // // // // //                   itemBuilder: (context, index) {
// // // // // // //                     final item = _historyList[index];
// // // // // // //                     final actionType = item['action_type'] ?? '';

// // // // // // //                     return Card(
// // // // // // //                       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // // // // // //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // // // // // //                       elevation: 2,
// // // // // // //                       child: InkWell(
// // // // // // //                         borderRadius: BorderRadius.circular(12),
// // // // // // //                         onTap: () {
// // // // // // //                           Navigator.push(
// // // // // // //                             context,
// // // // // // //                             MaterialPageRoute(
// // // // // // //                               builder: (context) => HistoryDetailScreen(item: item),
// // // // // // //                             ),
// // // // // // //                           );
// // // // // // //                         },
// // // // // // //                         child: Padding(
// // // // // // //                           padding: const EdgeInsets.all(12),
// // // // // // //                           child: Row(
// // // // // // //                             children: [
// // // // // // //                               ClipRRect(
// // // // // // //                                 borderRadius: BorderRadius.circular(8),
// // // // // // //                                 child: item['image_url'] != null
// // // // // // //                                     ? Image.network(
// // // // // // //                                         item['image_url'],
// // // // // // //                                         width: 65,
// // // // // // //                                         height: 65,
// // // // // // //                                         fit: BoxFit.cover,
// // // // // // //                                         errorBuilder: (context, error, stackTrace) =>
// // // // // // //                                             Container(width: 65, height: 65, color: Colors.grey.shade300, child: const Icon(Icons.broken_image)),
// // // // // // //                                       )
// // // // // // //                                     : Container(width: 65, height: 65, color: Colors.grey.shade300, child: const Icon(Icons.image)),
// // // // // // //                               ),
// // // // // // //                               const SizedBox(width: 14),
// // // // // // //                               Expanded(
// // // // // // //                                 child: Column(
// // // // // // //                                   crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // //                                   children: [
// // // // // // //                                     Row(
// // // // // // //                                       children: [
// // // // // // //                                         Container(
// // // // // // //                                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
// // // // // // //                                           decoration: BoxDecoration(
// // // // // // //                                             color: Colors.deepPurple.shade50,
// // // // // // //                                             borderRadius: BorderRadius.circular(6),
// // // // // // //                                           ),
// // // // // // //                                           child: Text(
// // // // // // //                                             item['category'] ?? '미분류',
// // // // // // //                                             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepPurple),
// // // // // // //                                           ),
// // // // // // //                                         ),
// // // // // // //                                         const Spacer(),
// // // // // // //                                         if (actionType.contains('일정') || actionType.contains('캘린더'))
// // // // // // //                                           const Icon(Icons.calendar_month, size: 18, color: Colors.blueAccent)
// // // // // // //                                         else if (actionType.contains('지도') || actionType.contains('매핑'))
// // // // // // //                                           const Icon(Icons.location_on, size: 18, color: Colors.redAccent),
// // // // // // //                                       ],
// // // // // // //                                     ),
// // // // // // //                                     const SizedBox(height: 6),
// // // // // // //                                     Text(
// // // // // // //                                       item['summary'] ?? '요약 내용 없음',
// // // // // // //                                       maxLines: 2,
// // // // // // //                                       overflow: TextOverflow.ellipsis,
// // // // // // //                                       style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
// // // // // // //                                     ),
// // // // // // //                                   ],
// // // // // // //                                 ),
// // // // // // //                               ),
// // // // // // //                               const Icon(Icons.chevron_right, color: Colors.grey),
// // // // // // //                             ],
// // // // // // //                           ),
// // // // // // //                         ),
// // // // // // //                       ),
// // // // // // //                     );
// // // // // // //                   },
// // // // // // //                 ),
// // // // // // //     );
// // // // // // //   }
// // // // // // // }

// // // // // // // // -------------------------------------------------------------
// // // // // // // // 4. 히스토리 상세 화면 (places 주소 최우선 매핑 네이버 지도 연동)
// // // // // // // // -------------------------------------------------------------
// // // // // // // class HistoryDetailScreen extends StatelessWidget {
// // // // // // //   final Map<String, dynamic> item;

// // // // // // //   const HistoryDetailScreen({super.key, required this.item});

// // // // // // //   Future<void> _openNaverMap(String addressQuery) async {
// // // // // // //     final query = addressQuery.trim();
// // // // // // //     if (query.isEmpty) return;

// // // // // // //     final encodedQuery = Uri.encodeComponent(query);
// // // // // // //     final url = Uri.parse('https://m.map.naver.com/search2/search.naver?query=$encodedQuery');
// // // // // // //     if (await canLaunchUrl(url)) {
// // // // // // //       await launchUrl(url, mode: LaunchMode.externalApplication);
// // // // // // //     }
// // // // // // //   }

// // // // // // //   // 검색할 최적의 주소/장소명 추출 (address -> place_name -> action_data -> summary 순)
// // // // // // //   String _resolveSearchTarget() {
// // // // // // //     // 1. places 배열이 있는 경우 address 또는 place_name 우선 확인
// // // // // // //     if (item['places'] is List && (item['places'] as List).isNotEmpty) {
// // // // // // //       final firstPlace = item['places'][0];
// // // // // // //       if (firstPlace is Map) {
// // // // // // //         final address = firstPlace['address']?.toString().trim() ?? '';
// // // // // // //         if (address.isNotEmpty) return address;

// // // // // // //         final placeName = firstPlace['place_name']?.toString().trim() ?? '';
// // // // // // //         if (placeName.isNotEmpty) return placeName;
// // // // // // //       }
// // // // // // //     }

// // // // // // //     // 2. action_data 값 확인
// // // // // // //     final actionData = item['action_data']?.toString().trim() ?? '';
// // // // // // //     if (actionData.isNotEmpty) return actionData;

// // // // // // //     // 3. 마지막 fallback: summary
// // // // // // //     return item['summary']?.toString().trim() ?? '';
// // // // // // //   }

// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     final actionType = item['action_type'] ?? '해당없음';
// // // // // // //     final isCalendarAction = actionType.contains('일정') || actionType.contains('캘린더');
// // // // // // //     final isMapAction = actionType.contains('지도') || actionType.contains('매핑');
    
// // // // // // //     final searchTarget = _resolveSearchTarget();
// // // // // // //     final rawActionData = item['action_data']?.toString().trim() ?? '';

// // // // // // //     return Scaffold(
// // // // // // //       appBar: AppBar(
// // // // // // //         title: const Text('분석 상세 정보'),
// // // // // // //       ),
// // // // // // //       body: SingleChildScrollView(
// // // // // // //         padding: const EdgeInsets.all(16),
// // // // // // //         child: Column(
// // // // // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // //           children: [
// // // // // // //             if (item['image_url'] != null)
// // // // // // //               ClipRRect(
// // // // // // //                 borderRadius: BorderRadius.circular(12),
// // // // // // //                 child: Image.network(
// // // // // // //                   item['image_url'],
// // // // // // //                   width: double.infinity,
// // // // // // //                   height: 260,
// // // // // // //                   fit: BoxFit.contain,
// // // // // // //                   errorBuilder: (context, error, stackTrace) =>
// // // // // // //                       Container(height: 180, color: Colors.grey.shade200, child: const Center(child: Icon(Icons.broken_image, size: 48))),
// // // // // // //                 ),
// // // // // // //               ),
// // // // // // //             const SizedBox(height: 16),

// // // // // // //             // 1. 네이버 지도 검색 연동 카드 (추출된 주소 기준)
// // // // // // //             if (isMapAction)
// // // // // // //               Card(
// // // // // // //                 color: Colors.green.shade50,
// // // // // // //                 shape: RoundedRectangleBorder(
// // // // // // //                   borderRadius: BorderRadius.circular(12),
// // // // // // //                   side: BorderSide(color: Colors.green.shade200),
// // // // // // //                 ),
// // // // // // //                 margin: const EdgeInsets.only(bottom: 16),
// // // // // // //                 child: Padding(
// // // // // // //                   padding: const EdgeInsets.all(16),
// // // // // // //                   child: Column(
// // // // // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // //                     children: [
// // // // // // //                       const Row(
// // // // // // //                         children: [
// // // // // // //                           Icon(Icons.location_on, color: Colors.green),
// // // // // // //                           SizedBox(width: 8),
// // // // // // //                           Text('지도 검색 위치 (도로명 주소)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
// // // // // // //                         ],
// // // // // // //                       ),
// // // // // // //                       const SizedBox(height: 8),
// // // // // // //                       Text(
// // // // // // //                         searchTarget.isNotEmpty ? searchTarget : '등록된 주소 정보가 없습니다.',
// // // // // // //                         style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
// // // // // // //                       ),
// // // // // // //                       const SizedBox(height: 12),
// // // // // // //                       ElevatedButton.icon(
// // // // // // //                         onPressed: searchTarget.isNotEmpty ? () => _openNaverMap(searchTarget) : null,
// // // // // // //                         icon: const Icon(Icons.map_outlined, color: Colors.white),
// // // // // // //                         label: const Text('네이버 지도에서 위치 확인', style: TextStyle(color: Colors.white)),
// // // // // // //                         style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF03C75A)),
// // // // // // //                       ),
// // // // // // //                     ],
// // // // // // //                   ),
// // // // // // //                 ),
// // // // // // //               ),

// // // // // // //             // 2. 캘린더 등록 알림 섹션
// // // // // // //             if (isCalendarAction)
// // // // // // //               Container(
// // // // // // //                 margin: const EdgeInsets.only(bottom: 16),
// // // // // // //                 padding: const EdgeInsets.all(12),
// // // // // // //                 decoration: BoxDecoration(
// // // // // // //                   color: Colors.blue.shade50,
// // // // // // //                   borderRadius: BorderRadius.circular(8),
// // // // // // //                   border: Border.all(color: Colors.blue.shade200),
// // // // // // //                 ),
// // // // // // //                 child: const Row(
// // // // // // //                   children: [
// // // // // // //                     Icon(Icons.event_available, color: Colors.blue),
// // // // // // //                     SizedBox(width: 8),
// // // // // // //                     Expanded(
// // // // // // //                       child: Text('캘린더 일정으로 등록된 항목입니다.', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
// // // // // // //                     ),
// // // // // // //                   ],
// // // // // // //                 ),
// // // // // // //               ),

// // // // // // //             // 3. 요약 정보 카드
// // // // // // //             Card(
// // // // // // //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // // // // // //               child: Padding(
// // // // // // //                 padding: const EdgeInsets.all(16),
// // // // // // //                 child: Column(
// // // // // // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // //                   children: [
// // // // // // //                     _buildInfoRow('카테고리', item['category'] ?? '-'),
// // // // // // //                     const Divider(height: 24),
// // // // // // //                     _buildInfoRow('액션 분류', actionType),
// // // // // // //                     const Divider(height: 24),
// // // // // // //                     _buildInfoRow('요약 내용', item['summary'] ?? '-'),
// // // // // // //                     if (searchTarget.isNotEmpty) ...[
// // // // // // //                       const Divider(height: 24),
// // // // // // //                       _buildInfoRow('검색 주소 / 장소', searchTarget),
// // // // // // //                     ] else if (rawActionData.isNotEmpty) ...[
// // // // // // //                       const Divider(height: 24),
// // // // // // //                       _buildInfoRow('상세 데이터', rawActionData),
// // // // // // //                     ],
// // // // // // //                     if (item['created_at'] != null) ...[
// // // // // // //                       const Divider(height: 24),
// // // // // // //                       _buildInfoRow('분석 일시', item['created_at'].toString().split('.')[0].replaceAll('T', ' ')),
// // // // // // //                     ],
// // // // // // //                   ],
// // // // // // //                 ),
// // // // // // //               ),
// // // // // // //             ),
// // // // // // //           ],
// // // // // // //         ),
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }

// // // // // // //   Widget _buildInfoRow(String label, String value) {
// // // // // // //     return Column(
// // // // // // //       crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // //       children: [
// // // // // // //         Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
// // // // // // //         const SizedBox(height: 4),
// // // // // // //         Text(value, style: const TextStyle(fontSize: 15, height: 1.4)),
// // // // // // //       ],
// // // // // // //     );
// // // // // // //   }
// // // // // // // }


// // // // // // // // import 'dart:convert';
// // // // // // // // import 'dart:io';
// // // // // // // // import 'package:flutter/material.dart';
// // // // // // // // import 'package:http/http.dart' as http;
// // // // // // // // import 'package:image_picker/image_picker.dart';
// // // // // // // // import 'package:table_calendar/table_calendar.dart';
// // // // // // // // import 'package:url_launcher/url_launcher.dart';

// // // // // // // // // 로컬 환경에 맞게 서버 IP/포트 설정 (안드로이드 에뮬레이터 기준 10.0.2.2:8000, 실제 기기는 PC IP 입력)
// // // // // // // // const String baseUrl = "http://10.0.2.2:8000";

// // // // // // // // void main() {
// // // // // // // //   runApp(const MyApp());
// // // // // // // // }

// // // // // // // // class MyApp extends StatelessWidget {
// // // // // // // //   const MyApp({super.key});

// // // // // // // //   @override
// // // // // // // //   Widget build(BuildContext context) {
// // // // // // // //     return MaterialApp(
// // // // // // // //       title: 'T.Salmon',
// // // // // // // //       theme: ThemeData(
// // // // // // // //         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
// // // // // // // //         useMaterial3: true,
// // // // // // // //       ),
// // // // // // // //       home: const MainNavigationScreen(),
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // // }

// // // // // // // // class MainNavigationScreen extends StatefulWidget {
// // // // // // // //   const MainNavigationScreen({super.key});

// // // // // // // //   @override
// // // // // // // //   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// // // // // // // // }

// // // // // // // // class _MainNavigationScreenState extends State<MainNavigationScreen> {
// // // // // // // //   int _currentIndex = 0;

// // // // // // // //   final List<Widget> _screens = const [
// // // // // // // //     UploadScreen(),
// // // // // // // //     CalendarScreen(),
// // // // // // // //     HistoryScreen(),
// // // // // // // //   ];

// // // // // // // //   @override
// // // // // // // //   Widget build(BuildContext context) {
// // // // // // // //     return Scaffold(
// // // // // // // //       body: _screens[_currentIndex],
// // // // // // // //       bottomNavigationBar: NavigationBar(
// // // // // // // //         selectedIndex: _currentIndex,
// // // // // // // //         onDestinationSelected: (index) => setState(() => _currentIndex = index),
// // // // // // // //         destinations: const [
// // // // // // // //           NavigationDestination(
// // // // // // // //             icon: Icon(Icons.cloud_upload_outlined),
// // // // // // // //             selectedIcon: Icon(Icons.cloud_upload),
// // // // // // // //             label: '업로드',
// // // // // // // //           ),
// // // // // // // //           NavigationDestination(
// // // // // // // //             icon: Icon(Icons.calendar_month_outlined),
// // // // // // // //             selectedIcon: Icon(Icons.calendar_month),
// // // // // // // //             label: '캘린더',
// // // // // // // //           ),
// // // // // // // //           NavigationDestination(
// // // // // // // //             icon: Icon(Icons.history_outlined),
// // // // // // // //             selectedIcon: Icon(Icons.history),
// // // // // // // //             label: '히스토리',
// // // // // // // //           ),
// // // // // // // //         ],
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // // }

// // // // // // // // // -------------------------------------------------------------
// // // // // // // // // 1. 업로드 탭 (스크린샷 수동 선택 및 /api/v1/analyze 호출)
// // // // // // // // // -------------------------------------------------------------
// // // // // // // // class UploadScreen extends StatefulWidget {
// // // // // // // //   const UploadScreen({super.key});

// // // // // // // //   @override
// // // // // // // //   State<UploadScreen> createState() => _UploadScreenState();
// // // // // // // // }

// // // // // // // // class _UploadScreenState extends State<UploadScreen> {
// // // // // // // //   File? _selectedImage;
// // // // // // // //   bool _isLoading = false;
// // // // // // // //   Map<String, dynamic>? _analysisResult;

// // // // // // // //   final ImagePicker _picker = ImagePicker();

// // // // // // // //   Future<void> _pickAndUploadImage() async {
// // // // // // // //     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
// // // // // // // //     if (pickedFile == null) return;

// // // // // // // //     if (!mounted) return;
// // // // // // // //     setState(() {
// // // // // // // //       _selectedImage = File(pickedFile.path);
// // // // // // // //       _isLoading = true;
// // // // // // // //       _analysisResult = null;
// // // // // // // //     });

// // // // // // // //     try {
// // // // // // // //       final uri = Uri.parse('$baseUrl/api/v1/analyze');
// // // // // // // //       final request = http.MultipartRequest('POST', uri);
// // // // // // // //       request.files.add(await http.MultipartFile.fromPath('file', pickedFile.path));

// // // // // // // //       final streamedResponse = await request.send();
// // // // // // // //       final response = await http.Response.fromStream(streamedResponse);

// // // // // // // //       if (response.statusCode == 200) {
// // // // // // // //         final decoded = jsonDecode(utf8.decode(response.bodyBytes));
// // // // // // // //         if (mounted) {
// // // // // // // //           setState(() {
// // // // // // // //             _analysisResult = decoded['analysis'];
// // // // // // // //           });
// // // // // // // //           ScaffoldMessenger.of(context).showSnackBar(
// // // // // // // //             const SnackBar(content: Text('분석 및 저장이 완료되었습니다!')),
// // // // // // // //           );
// // // // // // // //         }
// // // // // // // //       } else {
// // // // // // // //         throw Exception('서버 응답 오류: ${response.statusCode}');
// // // // // // // //       }
// // // // // // // //     } catch (e) {
// // // // // // // //       if (mounted) {
// // // // // // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // // // // // //           SnackBar(content: Text('업로드 실패: $e')),
// // // // // // // //         );
// // // // // // // //       }
// // // // // // // //     } finally {
// // // // // // // //       if (mounted) {
// // // // // // // //         setState(() => _isLoading = false);
// // // // // // // //       }
// // // // // // // //     }
// // // // // // // //   }

// // // // // // // //   @override
// // // // // // // //   Widget build(BuildContext context) {
// // // // // // // //     return Scaffold(
// // // // // // // //       appBar: AppBar(title: const Text('스크린샷 분석')),
// // // // // // // //       body: SingleChildScrollView(
// // // // // // // //         padding: const EdgeInsets.all(16),
// // // // // // // //         child: Column(
// // // // // // // //           children: [
// // // // // // // //             if (_selectedImage != null)
// // // // // // // //               ClipRRect(
// // // // // // // //                 borderRadius: BorderRadius.circular(12),
// // // // // // // //                 child: Image.file(_selectedImage!, height: 260, fit: BoxFit.cover),
// // // // // // // //               )
// // // // // // // //             else
// // // // // // // //               Container(
// // // // // // // //                 height: 200,
// // // // // // // //                 decoration: BoxDecoration(
// // // // // // // //                   color: Colors.grey.shade200,
// // // // // // // //                   borderRadius: BorderRadius.circular(12),
// // // // // // // //                 ),
// // // // // // // //                 child: const Center(child: Text('분석할 스크린샷을 선택하세요')),
// // // // // // // //               ),
// // // // // // // //             const SizedBox(height: 20),
// // // // // // // //             ElevatedButton.icon(
// // // // // // // //               onPressed: _isLoading ? null : _pickAndUploadImage,
// // // // // // // //               icon: const Icon(Icons.photo_library),
// // // // // // // //               label: Text(_isLoading ? '분석 중...' : '갤러리에서 선택 및 분석'),
// // // // // // // //               style: ElevatedButton.styleFrom(
// // // // // // // //                 minimumSize: const Size.fromHeight(50),
// // // // // // // //               ),
// // // // // // // //             ),
// // // // // // // //             const SizedBox(height: 24),
// // // // // // // //             if (_isLoading)
// // // // // // // //               const CircularProgressIndicator()
// // // // // // // //             else if (_analysisResult != null) ...[
// // // // // // // //               const Align(
// // // // // // // //                 alignment: Alignment.centerLeft,
// // // // // // // //                 child: Text('분석 결과', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // // // // //               ),
// // // // // // // //               const SizedBox(height: 8),
// // // // // // // //               Card(
// // // // // // // //                 child: Padding(
// // // // // // // //                   padding: const EdgeInsets.all(16),
// // // // // // // //                   child: Column(
// // // // // // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // //                     children: [
// // // // // // // //                       Text('카테고리: ${_analysisResult?['category'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // // // // //                       const SizedBox(height: 6),
// // // // // // // //                       Text('액션 타입: ${_analysisResult?['action_type'] ?? '-'}'),
// // // // // // // //                       const SizedBox(height: 6),
// // // // // // // //                       Text('요약: ${_analysisResult?['summary'] ?? '-'}'),
// // // // // // // //                       if (_analysisResult?['action_data'] != null && _analysisResult?['action_data'] != "") ...[
// // // // // // // //                         const SizedBox(height: 6),
// // // // // // // //                         Text('상세: ${_analysisResult?['action_data']}'),
// // // // // // // //                       ],
// // // // // // // //                     ],
// // // // // // // //                   ),
// // // // // // // //                 ),
// // // // // // // //               ),
// // // // // // // //             ],
// // // // // // // //           ],
// // // // // // // //         ),
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // // }

// // // // // // // // // -------------------------------------------------------------
// // // // // // // // // 2. 캘린더 탭 (/api/v1/calendar/ 연동 및 날짜별 매핑)
// // // // // // // // // -------------------------------------------------------------
// // // // // // // // class CalendarScreen extends StatefulWidget {
// // // // // // // //   const CalendarScreen({super.key});

// // // // // // // //   @override
// // // // // // // //   State<CalendarScreen> createState() => _CalendarScreenState();
// // // // // // // // }

// // // // // // // // class _CalendarScreenState extends State<CalendarScreen> {
// // // // // // // //   CalendarFormat _calendarFormat = CalendarFormat.month;
// // // // // // // //   DateTime _focusedDay = DateTime.now();
// // // // // // // //   DateTime? _selectedDay;
  
// // // // // // // //   Map<DateTime, List<dynamic>> _eventsMap = {};
// // // // // // // //   bool _isLoading = true;

// // // // // // // //   @override
// // // // // // // //   void initState() {
// // // // // // // //     super.initState();
// // // // // // // //     _selectedDay = _focusedDay;
// // // // // // // //     _fetchCalendarEvents();
// // // // // // // //   }

// // // // // // // //   DateTime _normalizeDate(DateTime dt) {
// // // // // // // //     return DateTime.utc(dt.year, dt.month, dt.day);
// // // // // // // //   }

// // // // // // // //   Future<void> _fetchCalendarEvents() async {
// // // // // // // //     if (!mounted) return;
// // // // // // // //     setState(() => _isLoading = true);

// // // // // // // //     try {
// // // // // // // //       final response = await http.get(Uri.parse('$baseUrl/api/v1/calendar/'));
// // // // // // // //       if (response.statusCode == 200 && mounted) {
// // // // // // // //         final data = jsonDecode(utf8.decode(response.bodyBytes));
// // // // // // // //         final List<dynamic> rawEvents = data['events'] ?? [];

// // // // // // // //         final Map<DateTime, List<dynamic>> newMap = {};
// // // // // // // //         for (var item in rawEvents) {
// // // // // // // //           final dateStr = item['event_date'];
// // // // // // // //           if (dateStr != null) {
// // // // // // // //             try {
// // // // // // // //               final parsed = DateTime.parse(dateStr.toString().substring(0, 10));
// // // // // // // //               final key = _normalizeDate(parsed);
// // // // // // // //               if (newMap[key] == null) {
// // // // // // // //                 newMap[key] = [];
// // // // // // // //               }
// // // // // // // //               newMap[key]!.add(item);
// // // // // // // //             } catch (_) {}
// // // // // // // //           }
// // // // // // // //         }

// // // // // // // //         setState(() {
// // // // // // // //           _eventsMap = newMap;
// // // // // // // //         });
// // // // // // // //       }
// // // // // // // //     } catch (e) {
// // // // // // // //       // 에러 핸들링
// // // // // // // //     } finally {
// // // // // // // //       if (mounted) {
// // // // // // // //         setState(() => _isLoading = false);
// // // // // // // //       }
// // // // // // // //     }
// // // // // // // //   }

// // // // // // // //   List<dynamic> _getEventsForDay(DateTime day) {
// // // // // // // //     return _eventsMap[_normalizeDate(day)] ?? [];
// // // // // // // //   }

// // // // // // // //   @override
// // // // // // // //   Widget build(BuildContext context) {
// // // // // // // //     final selectedEvents = _selectedDay != null ? _getEventsForDay(_selectedDay!) : [];

// // // // // // // //     return Scaffold(
// // // // // // // //       appBar: AppBar(
// // // // // // // //         title: const Text('등록된 일정'),
// // // // // // // //         actions: [
// // // // // // // //           IconButton(onPressed: _fetchCalendarEvents, icon: const Icon(Icons.refresh)),
// // // // // // // //         ],
// // // // // // // //       ),
// // // // // // // //       body: _isLoading
// // // // // // // //           ? const Center(child: CircularProgressIndicator())
// // // // // // // //           : Column(
// // // // // // // //               children: [
// // // // // // // //                 TableCalendar(
// // // // // // // //                   firstDay: DateTime.utc(2020, 1, 1),
// // // // // // // //                   lastDay: DateTime.utc(2030, 12, 31),
// // // // // // // //                   focusedDay: _focusedDay,
// // // // // // // //                   calendarFormat: _calendarFormat,
// // // // // // // //                   selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
// // // // // // // //                   eventLoader: _getEventsForDay,
// // // // // // // //                   onDaySelected: (selectedDay, focusedDay) {
// // // // // // // //                     if (!mounted) return;
// // // // // // // //                     setState(() {
// // // // // // // //                       _selectedDay = selectedDay;
// // // // // // // //                       _focusedDay = focusedDay;
// // // // // // // //                     });
// // // // // // // //                   },
// // // // // // // //                   onFormatChanged: (format) {
// // // // // // // //                     if (!mounted) return;
// // // // // // // //                     setState(() => _calendarFormat = format);
// // // // // // // //                   },
// // // // // // // //                   calendarStyle: const CalendarStyle(
// // // // // // // //                     markerDecoration: BoxDecoration(
// // // // // // // //                       color: Colors.deepPurple,
// // // // // // // //                       shape: BoxShape.circle,
// // // // // // // //                     ),
// // // // // // // //                   ),
// // // // // // // //                 ),
// // // // // // // //                 const Divider(),
// // // // // // // //                 Expanded(
// // // // // // // //                   child: selectedEvents.isEmpty
// // // // // // // //                       ? const Center(child: Text('해당 날짜에 등록된 일정이 없습니다.'))
// // // // // // // //                       : ListView.builder(
// // // // // // // //                           itemCount: selectedEvents.length,
// // // // // // // //                           itemBuilder: (context, index) {
// // // // // // // //                             final item = selectedEvents[index];
// // // // // // // //                             return Card(
// // // // // // // //                               margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
// // // // // // // //                               child: ListTile(
// // // // // // // //                                 leading: const Icon(Icons.event, color: Colors.deepPurple),
// // // // // // // //                                 title: Text(item['title'] ?? '일정 제목 없음', style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // // // // //                                 subtitle: Text('날짜: ${item['event_date']}'),
// // // // // // // //                                 trailing: item['image_url'] != null
// // // // // // // //                                     ? ClipRRect(
// // // // // // // //                                         borderRadius: BorderRadius.circular(6),
// // // // // // // //                                         child: Image.network(
// // // // // // // //                                           item['image_url'],
// // // // // // // //                                           width: 45,
// // // // // // // //                                           height: 45,
// // // // // // // //                                           fit: BoxFit.cover,
// // // // // // // //                                           errorBuilder: (context, error, stackTrace) =>
// // // // // // // //                                               const Icon(Icons.broken_image, size: 30),
// // // // // // // //                                         ),
// // // // // // // //                                       )
// // // // // // // //                                     : null,
// // // // // // // //                               ),
// // // // // // // //                             );
// // // // // // // //                           },
// // // // // // // //                         ),
// // // // // // // //                 ),
// // // // // // // //               ],
// // // // // // // //             ),
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // // }

// // // // // // // // // -------------------------------------------------------------
// // // // // // // // // 3. 히스토리 탭 (/api/v1/history/ 연동)
// // // // // // // // // -------------------------------------------------------------
// // // // // // // // class HistoryScreen extends StatefulWidget {
// // // // // // // //   const HistoryScreen({super.key});

// // // // // // // //   @override
// // // // // // // //   State<HistoryScreen> createState() => _HistoryScreenState();
// // // // // // // // }

// // // // // // // // class _HistoryScreenState extends State<HistoryScreen> {
// // // // // // // //   List<dynamic> _historyList = [];
// // // // // // // //   bool _isLoading = true;

// // // // // // // //   @override
// // // // // // // //   void initState() {
// // // // // // // //     super.initState();
// // // // // // // //     _fetchHistory();
// // // // // // // //   }

// // // // // // // //   Future<void> _fetchHistory() async {
// // // // // // // //     if (!mounted) return;
// // // // // // // //     setState(() => _isLoading = true);

// // // // // // // //     try {
// // // // // // // //       final response = await http.get(Uri.parse('$baseUrl/api/v1/history/'));
// // // // // // // //       if (response.statusCode == 200 && mounted) {
// // // // // // // //         final data = jsonDecode(utf8.decode(response.bodyBytes));
// // // // // // // //         setState(() {
// // // // // // // //           _historyList = data['history'] ?? [];
// // // // // // // //         });
// // // // // // // //       }
// // // // // // // //     } catch (e) {
// // // // // // // //       // 에러 핸들링
// // // // // // // //     } finally {
// // // // // // // //       if (mounted) {
// // // // // // // //         setState(() => _isLoading = false);
// // // // // // // //       }
// // // // // // // //     }
// // // // // // // //   }

// // // // // // // //   @override
// // // // // // // //   Widget build(BuildContext context) {
// // // // // // // //     return Scaffold(
// // // // // // // //       appBar: AppBar(
// // // // // // // //         title: const Text('분석 히스토리'),
// // // // // // // //         actions: [
// // // // // // // //           IconButton(onPressed: _fetchHistory, icon: const Icon(Icons.refresh)),
// // // // // // // //         ],
// // // // // // // //       ),
// // // // // // // //       body: _isLoading
// // // // // // // //           ? const Center(child: CircularProgressIndicator())
// // // // // // // //           : _historyList.isEmpty
// // // // // // // //               ? const Center(child: Text('히스토리가 없습니다.'))
// // // // // // // //               : ListView.builder(
// // // // // // // //                   padding: const EdgeInsets.symmetric(vertical: 8),
// // // // // // // //                   itemCount: _historyList.length,
// // // // // // // //                   itemBuilder: (context, index) {
// // // // // // // //                     final item = _historyList[index];
// // // // // // // //                     final actionType = item['action_type'] ?? '';

// // // // // // // //                     return Card(
// // // // // // // //                       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // // // // // // //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // // // // // // //                       elevation: 2,
// // // // // // // //                       child: InkWell(
// // // // // // // //                         borderRadius: BorderRadius.circular(12),
// // // // // // // //                         onTap: () {
// // // // // // // //                           Navigator.push(
// // // // // // // //                             context,
// // // // // // // //                             MaterialPageRoute(
// // // // // // // //                               builder: (context) => HistoryDetailScreen(item: item),
// // // // // // // //                             ),
// // // // // // // //                           );
// // // // // // // //                         },
// // // // // // // //                         child: Padding(
// // // // // // // //                           padding: const EdgeInsets.all(12),
// // // // // // // //                           child: Row(
// // // // // // // //                             children: [
// // // // // // // //                               ClipRRect(
// // // // // // // //                                 borderRadius: BorderRadius.circular(8),
// // // // // // // //                                 child: item['image_url'] != null
// // // // // // // //                                     ? Image.network(
// // // // // // // //                                         item['image_url'],
// // // // // // // //                                         width: 65,
// // // // // // // //                                         height: 65,
// // // // // // // //                                         fit: BoxFit.cover,
// // // // // // // //                                         errorBuilder: (context, error, stackTrace) =>
// // // // // // // //                                             Container(width: 65, height: 65, color: Colors.grey.shade300, child: const Icon(Icons.broken_image)),
// // // // // // // //                                       )
// // // // // // // //                                     : Container(width: 65, height: 65, color: Colors.grey.shade300, child: const Icon(Icons.image)),
// // // // // // // //                               ),
// // // // // // // //                               const SizedBox(width: 14),
// // // // // // // //                               Expanded(
// // // // // // // //                                 child: Column(
// // // // // // // //                                   crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // //                                   children: [
// // // // // // // //                                     Row(
// // // // // // // //                                       children: [
// // // // // // // //                                         Container(
// // // // // // // //                                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
// // // // // // // //                                           decoration: BoxDecoration(
// // // // // // // //                                             color: Colors.deepPurple.shade50,
// // // // // // // //                                             borderRadius: BorderRadius.circular(6),
// // // // // // // //                                           ),
// // // // // // // //                                           child: Text(
// // // // // // // //                                             item['category'] ?? '미분류',
// // // // // // // //                                             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepPurple),
// // // // // // // //                                           ),
// // // // // // // //                                         ),
// // // // // // // //                                         const Spacer(),
// // // // // // // //                                         if (actionType.contains('일정') || actionType.contains('캘린더'))
// // // // // // // //                                           const Icon(Icons.calendar_month, size: 18, color: Colors.blueAccent)
// // // // // // // //                                         else if (actionType.contains('지도') || actionType.contains('매핑'))
// // // // // // // //                                           const Icon(Icons.location_on, size: 18, color: Colors.redAccent),
// // // // // // // //                                       ],
// // // // // // // //                                     ),
// // // // // // // //                                     const SizedBox(height: 6),
// // // // // // // //                                     Text(
// // // // // // // //                                       item['summary'] ?? '요약 내용 없음',
// // // // // // // //                                       maxLines: 2,
// // // // // // // //                                       overflow: TextOverflow.ellipsis,
// // // // // // // //                                       style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
// // // // // // // //                                     ),
// // // // // // // //                                   ],
// // // // // // // //                                 ),
// // // // // // // //                               ),
// // // // // // // //                               const Icon(Icons.chevron_right, color: Colors.grey),
// // // // // // // //                             ],
// // // // // // // //                           ),
// // // // // // // //                         ),
// // // // // // // //                       ),
// // // // // // // //                     );
// // // // // // // //                   },
// // // // // // // //                 ),
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // // }

// // // // // // // // // -------------------------------------------------------------
// // // // // // // // // 4. 히스토리 상세 화면 (places 주소 최우선 매핑 네이버 지도 연동)
// // // // // // // // // -------------------------------------------------------------
// // // // // // // // class HistoryDetailScreen extends StatelessWidget {
// // // // // // // //   final Map<String, dynamic> item;

// // // // // // // //   const HistoryDetailScreen({super.key, required this.item});

// // // // // // // //   Future<void> _openNaverMap(String addressQuery) async {
// // // // // // // //     final query = addressQuery.trim();
// // // // // // // //     if (query.isEmpty) return;

// // // // // // // //     final encodedQuery = Uri.encodeComponent(query);
// // // // // // // //     final url = Uri.parse('https://m.map.naver.com/search2/search.naver?query=$encodedQuery');
// // // // // // // //     if (await canLaunchUrl(url)) {
// // // // // // // //       await launchUrl(url, mode: LaunchMode.externalApplication);
// // // // // // // //     }
// // // // // // // //   }

// // // // // // // //   // 검색할 최적의 주소/장소명 추출 (address -> place_name -> action_data -> summary 순)
// // // // // // // //   String _resolveSearchTarget() {
// // // // // // // //     // 1. places 배열이 있는 경우 address 또는 place_name 우선 확인
// // // // // // // //     if (item['places'] is List && (item['places'] as List).isNotEmpty) {
// // // // // // // //       final firstPlace = item['places'][0];
// // // // // // // //       if (firstPlace is Map) {
// // // // // // // //         final address = firstPlace['address']?.toString().trim() ?? '';
// // // // // // // //         if (address.isNotEmpty) return address;

// // // // // // // //         final placeName = firstPlace['place_name']?.toString().trim() ?? '';
// // // // // // // //         if (placeName.isNotEmpty) return placeName;
// // // // // // // //       }
// // // // // // // //     }

// // // // // // // //     // 2. action_data 값 확인
// // // // // // // //     final actionData = item['action_data']?.toString().trim() ?? '';
// // // // // // // //     if (actionData.isNotEmpty) return actionData;

// // // // // // // //     // 3. 마지막 fallback: summary
// // // // // // // //     return item['summary']?.toString().trim() ?? '';
// // // // // // // //   }

// // // // // // // //   @override
// // // // // // // //   Widget build(BuildContext context) {
// // // // // // // //     final actionType = item['action_type'] ?? '해당없음';
// // // // // // // //     final isCalendarAction = actionType.contains('일정') || actionType.contains('캘린더');
// // // // // // // //     final isMapAction = actionType.contains('지도') || actionType.contains('매핑');
    
// // // // // // // //     final searchTarget = _resolveSearchTarget();
// // // // // // // //     final rawActionData = item['action_data']?.toString().trim() ?? '';

// // // // // // // //     return Scaffold(
// // // // // // // //       appBar: AppBar(
// // // // // // // //         title: const Text('분석 상세 정보'),
// // // // // // // //       ),
// // // // // // // //       body: SingleChildScrollView(
// // // // // // // //         padding: const EdgeInsets.all(16),
// // // // // // // //         child: Column(
// // // // // // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // //           children: [
// // // // // // // //             if (item['image_url'] != null)
// // // // // // // //               ClipRRect(
// // // // // // // //                 borderRadius: BorderRadius.circular(12),
// // // // // // // //                 child: Image.network(
// // // // // // // //                   item['image_url'],
// // // // // // // //                   width: double.infinity,
// // // // // // // //                   height: 260,
// // // // // // // //                   fit: BoxFit.contain,
// // // // // // // //                   errorBuilder: (context, error, stackTrace) =>
// // // // // // // //                       Container(height: 180, color: Colors.grey.shade200, child: const Center(child: Icon(Icons.broken_image, size: 48))),
// // // // // // // //                 ),
// // // // // // // //               ),
// // // // // // // //             const SizedBox(height: 16),

// // // // // // // //             // 1. 네이버 지도 검색 연동 카드 (추출된 주소 기준)
// // // // // // // //             if (isMapAction)
// // // // // // // //               Card(
// // // // // // // //                 color: Colors.green.shade50,
// // // // // // // //                 shape: RoundedRectangleBorder(
// // // // // // // //                   borderRadius: BorderRadius.circular(12),
// // // // // // // //                   side: BorderSide(color: Colors.green.shade200),
// // // // // // // //                 ),
// // // // // // // //                 margin: const EdgeInsets.only(bottom: 16),
// // // // // // // //                 child: Padding(
// // // // // // // //                   padding: const EdgeInsets.all(16),
// // // // // // // //                   child: Column(
// // // // // // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // //                     children: [
// // // // // // // //                       const Row(
// // // // // // // //                         children: [
// // // // // // // //                           Icon(Icons.location_on, color: Colors.green),
// // // // // // // //                           SizedBox(width: 8),
// // // // // // // //                           Text('지도 검색 위치 (도로명 주소)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
// // // // // // // //                         ],
// // // // // // // //                       ),
// // // // // // // //                       const SizedBox(height: 8),
// // // // // // // //                       Text(
// // // // // // // //                         searchTarget.isNotEmpty ? searchTarget : '등록된 주소 정보가 없습니다.',
// // // // // // // //                         style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
// // // // // // // //                       ),
// // // // // // // //                       const SizedBox(height: 12),
// // // // // // // //                       ElevatedButton.icon(
// // // // // // // //                         onPressed: searchTarget.isNotEmpty ? () => _openNaverMap(searchTarget) : null,
// // // // // // // //                         icon: const Icon(Icons.map_outlined, color: Colors.white),
// // // // // // // //                         label: const Text('네이버 지도에서 위치 확인', style: TextStyle(color: Colors.white)),
// // // // // // // //                         style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF03C75A)),
// // // // // // // //                       ),
// // // // // // // //                     ],
// // // // // // // //                   ),
// // // // // // // //                 ),
// // // // // // // //               ),

// // // // // // // //             // 2. 캘린더 등록 알림 섹션
// // // // // // // //             if (isCalendarAction)
// // // // // // // //               Container(
// // // // // // // //                 margin: const EdgeInsets.only(bottom: 16),
// // // // // // // //                 padding: const EdgeInsets.all(12),
// // // // // // // //                 decoration: BoxDecoration(
// // // // // // // //                   color: Colors.blue.shade50,
// // // // // // // //                   borderRadius: BorderRadius.circular(8),
// // // // // // // //                   border: Border.all(color: Colors.blue.shade200),
// // // // // // // //                 ),
// // // // // // // //                 child: const Row(
// // // // // // // //                   children: [
// // // // // // // //                     Icon(Icons.event_available, color: Colors.blue),
// // // // // // // //                     SizedBox(width: 8),
// // // // // // // //                     Expanded(
// // // // // // // //                       child: Text('캘린더 일정으로 등록된 항목입니다.', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
// // // // // // // //                     ),
// // // // // // // //                   ],
// // // // // // // //                 ),
// // // // // // // //               ),

// // // // // // // //             // 3. 요약 정보 카드
// // // // // // // //             Card(
// // // // // // // //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // // // // // // //               child: Padding(
// // // // // // // //                 padding: const EdgeInsets.all(16),
// // // // // // // //                 child: Column(
// // // // // // // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // //                   children: [
// // // // // // // //                     _buildInfoRow('카테고리', item['category'] ?? '-'),
// // // // // // // //                     const Divider(height: 24),
// // // // // // // //                     _buildInfoRow('액션 분류', actionType),
// // // // // // // //                     const Divider(height: 24),
// // // // // // // //                     _buildInfoRow('요약 내용', item['summary'] ?? '-'),
// // // // // // // //                     if (searchTarget.isNotEmpty) ...[
// // // // // // // //                       const Divider(height: 24),
// // // // // // // //                       _buildInfoRow('검색 주소 / 장소', searchTarget),
// // // // // // // //                     ] else if (rawActionData.isNotEmpty) ...[
// // // // // // // //                       const Divider(height: 24),
// // // // // // // //                       _buildInfoRow('상세 데이터', rawActionData),
// // // // // // // //                     ],
// // // // // // // //                     if (item['created_at'] != null) ...[
// // // // // // // //                       const Divider(height: 24),
// // // // // // // //                       _buildInfoRow('분석 일시', item['created_at'].toString().split('.')[0].replaceAll('T', ' ')),
// // // // // // // //                     ],
// // // // // // // //                   ],
// // // // // // // //                 ),
// // // // // // // //               ),
// // // // // // // //             ),
// // // // // // // //           ],
// // // // // // // //         ),
// // // // // // // //       ),
// // // // // // // //     );
// // // // // // // //   }

// // // // // // // //   Widget _buildInfoRow(String label, String value) {
// // // // // // // //     return Column(
// // // // // // // //       crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // //       children: [
// // // // // // // //         Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
// // // // // // // //         const SizedBox(height: 4),
// // // // // // // //         Text(value, style: const TextStyle(fontSize: 15, height: 1.4)),
// // // // // // // //       ],
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // // }

// // // // // // // // // import 'dart:convert';
// // // // // // // // // import 'dart:io';
// // // // // // // // // import 'package:flutter/material.dart';
// // // // // // // // // import 'package:http/http.dart' as http;
// // // // // // // // // import 'package:image_picker/image_picker.dart';
// // // // // // // // // import 'package:table_calendar/table_calendar.dart';
// // // // // // // // // import 'package:url_launcher/url_launcher.dart';

// // // // // // // // // // 로컬 환경에 맞게 서버 IP/포트 설정 (안드로이드 에뮬레이터 기준 10.0.2.2:8000, 실제 기기는 PC IP 입력)
// // // // // // // // // const String baseUrl = "http://10.0.2.2:8000";

// // // // // // // // // void main() {
// // // // // // // // //   runApp(const MyApp());
// // // // // // // // // }

// // // // // // // // // class MyApp extends StatelessWidget {
// // // // // // // // //   const MyApp({super.key});

// // // // // // // // //   @override
// // // // // // // // //   Widget build(BuildContext context) {
// // // // // // // // //     return MaterialApp(
// // // // // // // // //       title: 'T.Salmon',
// // // // // // // // //       theme: ThemeData(
// // // // // // // // //         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
// // // // // // // // //         useMaterial3: true,
// // // // // // // // //       ),
// // // // // // // // //       home: const MainNavigationScreen(),
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // // }

// // // // // // // // // class MainNavigationScreen extends StatefulWidget {
// // // // // // // // //   const MainNavigationScreen({super.key});

// // // // // // // // //   @override
// // // // // // // // //   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// // // // // // // // // }

// // // // // // // // // class _MainNavigationScreenState extends State<MainNavigationScreen> {
// // // // // // // // //   int _currentIndex = 0;

// // // // // // // // //   final List<Widget> _screens = const [
// // // // // // // // //     UploadScreen(),
// // // // // // // // //     CalendarScreen(),
// // // // // // // // //     HistoryScreen(),
// // // // // // // // //   ];

// // // // // // // // //   @override
// // // // // // // // //   Widget build(BuildContext context) {
// // // // // // // // //     return Scaffold(
// // // // // // // // //       body: _screens[_currentIndex],
// // // // // // // // //       bottomNavigationBar: NavigationBar(
// // // // // // // // //         selectedIndex: _currentIndex,
// // // // // // // // //         onDestinationSelected: (index) => setState(() => _currentIndex = index),
// // // // // // // // //         destinations: const [
// // // // // // // // //           NavigationDestination(
// // // // // // // // //             icon: Icon(Icons.cloud_upload_outlined),
// // // // // // // // //             selectedIcon: Icon(Icons.cloud_upload),
// // // // // // // // //             label: '업로드',
// // // // // // // // //           ),
// // // // // // // // //           NavigationDestination(
// // // // // // // // //             icon: Icon(Icons.calendar_month_outlined),
// // // // // // // // //             selectedIcon: Icon(Icons.calendar_month),
// // // // // // // // //             label: '캘린더',
// // // // // // // // //           ),
// // // // // // // // //           NavigationDestination(
// // // // // // // // //             icon: Icon(Icons.history_outlined),
// // // // // // // // //             selectedIcon: Icon(Icons.history),
// // // // // // // // //             label: '히스토리',
// // // // // // // // //           ),
// // // // // // // // //         ],
// // // // // // // // //       ),
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // // }

// // // // // // // // // // -------------------------------------------------------------
// // // // // // // // // // 1. 업로드 탭 (스크린샷 수동 선택 및 /api/v1/analyze 호출)
// // // // // // // // // // -------------------------------------------------------------
// // // // // // // // // class UploadScreen extends StatefulWidget {
// // // // // // // // //   const UploadScreen({super.key});

// // // // // // // // //   @override
// // // // // // // // //   State<UploadScreen> createState() => _UploadScreenState();
// // // // // // // // // }

// // // // // // // // // class _UploadScreenState extends State<UploadScreen> {
// // // // // // // // //   File? _selectedImage;
// // // // // // // // //   bool _isLoading = false;
// // // // // // // // //   Map<String, dynamic>? _analysisResult;

// // // // // // // // //   final ImagePicker _picker = ImagePicker();

// // // // // // // // //   Future<void> _pickAndUploadImage() async {
// // // // // // // // //     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
// // // // // // // // //     if (pickedFile == null) return;

// // // // // // // // //     if (!mounted) return;
// // // // // // // // //     setState(() {
// // // // // // // // //       _selectedImage = File(pickedFile.path);
// // // // // // // // //       _isLoading = true;
// // // // // // // // //       _analysisResult = null;
// // // // // // // // //     });

// // // // // // // // //     try {
// // // // // // // // //       final uri = Uri.parse('$baseUrl/api/v1/analyze');
// // // // // // // // //       final request = http.MultipartRequest('POST', uri);
// // // // // // // // //       request.files.add(await http.MultipartFile.fromPath('file', pickedFile.path));

// // // // // // // // //       final streamedResponse = await request.send();
// // // // // // // // //       final response = await http.Response.fromStream(streamedResponse);

// // // // // // // // //       if (response.statusCode == 200) {
// // // // // // // // //         final decoded = jsonDecode(utf8.decode(response.bodyBytes));
// // // // // // // // //         if (mounted) {
// // // // // // // // //           setState(() {
// // // // // // // // //             _analysisResult = decoded['analysis'];
// // // // // // // // //           });
// // // // // // // // //           ScaffoldMessenger.of(context).showSnackBar(
// // // // // // // // //             const SnackBar(content: Text('분석 및 저장이 완료되었습니다!')),
// // // // // // // // //           );
// // // // // // // // //         }
// // // // // // // // //       } else {
// // // // // // // // //         throw Exception('서버 응답 오류: ${response.statusCode}');
// // // // // // // // //       }
// // // // // // // // //     } catch (e) {
// // // // // // // // //       if (mounted) {
// // // // // // // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // // // // // // //           SnackBar(content: Text('업로드 실패: $e')),
// // // // // // // // //         );
// // // // // // // // //       }
// // // // // // // // //     } finally {
// // // // // // // // //       if (mounted) {
// // // // // // // // //         setState(() => _isLoading = false);
// // // // // // // // //       }
// // // // // // // // //     }
// // // // // // // // //   }

// // // // // // // // //   @override
// // // // // // // // //   Widget build(BuildContext context) {
// // // // // // // // //     return Scaffold(
// // // // // // // // //       appBar: AppBar(title: const Text('스크린샷 분석')),
// // // // // // // // //       body: SingleChildScrollView(
// // // // // // // // //         padding: const EdgeInsets.all(16),
// // // // // // // // //         child: Column(
// // // // // // // // //           children: [
// // // // // // // // //             if (_selectedImage != null)
// // // // // // // // //               ClipRRect(
// // // // // // // // //                 borderRadius: BorderRadius.circular(12),
// // // // // // // // //                 child: Image.file(_selectedImage!, height: 260, fit: BoxFit.cover),
// // // // // // // // //               )
// // // // // // // // //             else
// // // // // // // // //               Container(
// // // // // // // // //                 height: 200,
// // // // // // // // //                 decoration: BoxDecoration(
// // // // // // // // //                   color: Colors.grey.shade200,
// // // // // // // // //                   borderRadius: BorderRadius.circular(12),
// // // // // // // // //                 ),
// // // // // // // // //                 child: const Center(child: Text('분석할 스크린샷을 선택하세요')),
// // // // // // // // //               ),
// // // // // // // // //             const SizedBox(height: 20),
// // // // // // // // //             ElevatedButton.icon(
// // // // // // // // //               onPressed: _isLoading ? null : _pickAndUploadImage,
// // // // // // // // //               icon: const Icon(Icons.photo_library),
// // // // // // // // //               label: Text(_isLoading ? '분석 중...' : '갤러리에서 선택 및 분석'),
// // // // // // // // //               style: ElevatedButton.styleFrom(
// // // // // // // // //                 minimumSize: const Size.fromHeight(50),
// // // // // // // // //               ),
// // // // // // // // //             ),
// // // // // // // // //             const SizedBox(height: 24),
// // // // // // // // //             if (_isLoading)
// // // // // // // // //               const CircularProgressIndicator()
// // // // // // // // //             else if (_analysisResult != null) ...[
// // // // // // // // //               const Align(
// // // // // // // // //                 alignment: Alignment.centerLeft,
// // // // // // // // //                 child: Text('분석 결과', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // // // // // //               ),
// // // // // // // // //               const SizedBox(height: 8),
// // // // // // // // //               Card(
// // // // // // // // //                 child: Padding(
// // // // // // // // //                   padding: const EdgeInsets.all(16),
// // // // // // // // //                   child: Column(
// // // // // // // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //                     children: [
// // // // // // // // //                       Text('카테고리: ${_analysisResult?['category'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // // // // // //                       const SizedBox(height: 6),
// // // // // // // // //                       Text('액션 타입: ${_analysisResult?['action_type'] ?? '-'}'),
// // // // // // // // //                       const SizedBox(height: 6),
// // // // // // // // //                       Text('요약: ${_analysisResult?['summary'] ?? '-'}'),
// // // // // // // // //                       if (_analysisResult?['action_data'] != null && _analysisResult?['action_data'] != "") ...[
// // // // // // // // //                         const SizedBox(height: 6),
// // // // // // // // //                         Text('상세: ${_analysisResult?['action_data']}'),
// // // // // // // // //                       ],
// // // // // // // // //                     ],
// // // // // // // // //                   ),
// // // // // // // // //                 ),
// // // // // // // // //               ),
// // // // // // // // //             ],
// // // // // // // // //           ],
// // // // // // // // //         ),
// // // // // // // // //       ),
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // // }

// // // // // // // // // // -------------------------------------------------------------
// // // // // // // // // // 2. 캘린더 탭 (/api/v1/calendar/ 연동 및 날짜별 매핑)
// // // // // // // // // // -------------------------------------------------------------
// // // // // // // // // class CalendarScreen extends StatefulWidget {
// // // // // // // // //   const CalendarScreen({super.key});

// // // // // // // // //   @override
// // // // // // // // //   State<CalendarScreen> createState() => _CalendarScreenState();
// // // // // // // // // }

// // // // // // // // // class _CalendarScreenState extends State<CalendarScreen> {
// // // // // // // // //   CalendarFormat _calendarFormat = CalendarFormat.month;
// // // // // // // // //   DateTime _focusedDay = DateTime.now();
// // // // // // // // //   DateTime? _selectedDay;
  
// // // // // // // // //   // 날짜별 일정 매핑 Map (Key: DateTime(년, 월, 일), Value: 해당 날짜의 일정 리스트)
// // // // // // // // //   Map<DateTime, List<dynamic>> _eventsMap = {};
// // // // // // // // //   bool _isLoading = true;

// // // // // // // // //   @override
// // // // // // // // //   void initState() {
// // // // // // // // //     super.initState();
// // // // // // // // //     _selectedDay = _focusedDay;
// // // // // // // // //     _fetchCalendarEvents();
// // // // // // // // //   }

// // // // // // // // //   // YYYY-MM-DD 날짜를 시간 정보 없는 DateTime(UTC/Local 표준화)으로 변환
// // // // // // // // //   DateTime _normalizeDate(DateTime dt) {
// // // // // // // // //     return DateTime.utc(dt.year, dt.month, dt.day);
// // // // // // // // //   }

// // // // // // // // //   Future<void> _fetchCalendarEvents() async {
// // // // // // // // //     if (!mounted) return;
// // // // // // // // //     setState(() => _isLoading = true);

// // // // // // // // //     try {
// // // // // // // // //       final response = await http.get(Uri.parse('$baseUrl/api/v1/calendar/'));
// // // // // // // // //       if (response.statusCode == 200 && mounted) {
// // // // // // // // //         final data = jsonDecode(utf8.decode(response.bodyBytes));
// // // // // // // // //         final List<dynamic> rawEvents = data['events'] ?? [];

// // // // // // // // //         // RDB에서 가져온 이벤트를 날짜 키 기준으로 그룹핑
// // // // // // // // //         final Map<DateTime, List<dynamic>> newMap = {};
// // // // // // // // //         for (var item in rawEvents) {
// // // // // // // // //           final dateStr = item['event_date'];
// // // // // // // // //           if (dateStr != null) {
// // // // // // // // //             try {
// // // // // // // // //               final parsed = DateTime.parse(dateStr.toString().substring(0, 10));
// // // // // // // // //               final key = _normalizeDate(parsed);
// // // // // // // // //               if (newMap[key] == null) {
// // // // // // // // //                 newMap[key] = [];
// // // // // // // // //               }
// // // // // // // // //               newMap[key]!.add(item);
// // // // // // // // //             } catch (_) {}
// // // // // // // // //           }
// // // // // // // // //         }

// // // // // // // // //         setState(() {
// // // // // // // // //           _eventsMap = newMap;
// // // // // // // // //         });
// // // // // // // // //       }
// // // // // // // // //     } catch (e) {
// // // // // // // // //       // 에러 핸들링
// // // // // // // // //     } finally {
// // // // // // // // //       if (mounted) {
// // // // // // // // //         setState(() => _isLoading = false);
// // // // // // // // //       }
// // // // // // // // //     }
// // // // // // // // //   }

// // // // // // // // //   // 특정 날짜의 일정 목록 가져오기 (마커 렌더링 및 하단 리스트용)
// // // // // // // // //   List<dynamic> _getEventsForDay(DateTime day) {
// // // // // // // // //     return _eventsMap[_normalizeDate(day)] ?? [];
// // // // // // // // //   }

// // // // // // // // //   @override
// // // // // // // // //   Widget build(BuildContext context) {
// // // // // // // // //     final selectedEvents = _selectedDay != null ? _getEventsForDay(_selectedDay!) : [];

// // // // // // // // //     return Scaffold(
// // // // // // // // //       appBar: AppBar(
// // // // // // // // //         title: const Text('등록된 일정'),
// // // // // // // // //         actions: [
// // // // // // // // //           IconButton(onPressed: _fetchCalendarEvents, icon: const Icon(Icons.refresh)),
// // // // // // // // //         ],
// // // // // // // // //       ),
// // // // // // // // //       body: _isLoading
// // // // // // // // //           ? const Center(child: CircularProgressIndicator())
// // // // // // // // //           : Column(
// // // // // // // // //               children: [
// // // // // // // // //                 TableCalendar(
// // // // // // // // //                   firstDay: DateTime.utc(2020, 1, 1),
// // // // // // // // //                   lastDay: DateTime.utc(2030, 12, 31),
// // // // // // // // //                   focusedDay: _focusedDay,
// // // // // // // // //                   calendarFormat: _calendarFormat,
// // // // // // // // //                   selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
// // // // // // // // //                   eventLoader: _getEventsForDay, // 👈 캘린더 날짜에 이벤트 점(마커) 표시
// // // // // // // // //                   onDaySelected: (selectedDay, focusedDay) {
// // // // // // // // //                     if (!mounted) return;
// // // // // // // // //                     setState(() {
// // // // // // // // //                       _selectedDay = selectedDay;
// // // // // // // // //                       _focusedDay = focusedDay;
// // // // // // // // //                     });
// // // // // // // // //                   },
// // // // // // // // //                   onFormatChanged: (format) {
// // // // // // // // //                     if (!mounted) return;
// // // // // // // // //                     setState(() => _calendarFormat = format);
// // // // // // // // //                   },
// // // // // // // // //                   calendarStyle: const CalendarStyle(
// // // // // // // // //                     markerDecoration: BoxDecoration(
// // // // // // // // //                       color: Colors.deepPurple,
// // // // // // // // //                       shape: BoxShape.circle,
// // // // // // // // //                     ),
// // // // // // // // //                   ),
// // // // // // // // //                 ),
// // // // // // // // //                 const Divider(),
// // // // // // // // //                 // 선택한 날짜의 일정 목록 표시
// // // // // // // // //                 Expanded(
// // // // // // // // //                   child: selectedEvents.isEmpty
// // // // // // // // //                       ? const Center(child: Text('해당 날짜에 등록된 일정이 없습니다.'))
// // // // // // // // //                       : ListView.builder(
// // // // // // // // //                           itemCount: selectedEvents.length,
// // // // // // // // //                           itemBuilder: (context, index) {
// // // // // // // // //                             final item = selectedEvents[index];
// // // // // // // // //                             return Card(
// // // // // // // // //                               margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
// // // // // // // // //                               child: ListTile(
// // // // // // // // //                                 leading: const Icon(Icons.event, color: Colors.deepPurple),
// // // // // // // // //                                 title: Text(item['title'] ?? '일정 제목 없음', style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // // // // // //                                 subtitle: Text('날짜: ${item['event_date']}'),
// // // // // // // // //                                 trailing: item['image_url'] != null
// // // // // // // // //                                     ? ClipRRect(
// // // // // // // // //                                         borderRadius: BorderRadius.circular(6),
// // // // // // // // //                                         child: Image.network(
// // // // // // // // //                                           item['image_url'],
// // // // // // // // //                                           width: 45,
// // // // // // // // //                                           height: 45,
// // // // // // // // //                                           fit: BoxFit.cover,
// // // // // // // // //                                           errorBuilder: (context, error, stackTrace) =>
// // // // // // // // //                                               const Icon(Icons.broken_image, size: 30),
// // // // // // // // //                                         ),
// // // // // // // // //                                       )
// // // // // // // // //                                     : null,
// // // // // // // // //                               ),
// // // // // // // // //                             );
// // // // // // // // //                           },
// // // // // // // // //                         ),
// // // // // // // // //                 ),
// // // // // // // // //               ],
// // // // // // // // //             ),
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // // }


// // // // // // // // // // -------------------------------------------------------------
// // // // // // // // // // 3. 히스토리 탭 (/api/v1/history/ 연동)
// // // // // // // // // // -------------------------------------------------------------
// // // // // // // // // class HistoryScreen extends StatefulWidget {
// // // // // // // // //   const HistoryScreen({super.key});

// // // // // // // // //   @override
// // // // // // // // //   State<HistoryScreen> createState() => _HistoryScreenState();
// // // // // // // // // }

// // // // // // // // // class _HistoryScreenState extends State<HistoryScreen> {
// // // // // // // // //   List<dynamic> _historyList = [];
// // // // // // // // //   bool _isLoading = true;

// // // // // // // // //   @override
// // // // // // // // //   void initState() {
// // // // // // // // //     super.initState();
// // // // // // // // //     _fetchHistory();
// // // // // // // // //   }

// // // // // // // // //   Future<void> _fetchHistory() async {
// // // // // // // // //     if (!mounted) return;
// // // // // // // // //     setState(() => _isLoading = true);

// // // // // // // // //     try {
// // // // // // // // //       final response = await http.get(Uri.parse('$baseUrl/api/v1/history/'));
// // // // // // // // //       if (response.statusCode == 200 && mounted) {
// // // // // // // // //         final data = jsonDecode(utf8.decode(response.bodyBytes));
// // // // // // // // //         setState(() {
// // // // // // // // //           _historyList = data['history'] ?? [];
// // // // // // // // //         });
// // // // // // // // //       }
// // // // // // // // //     } catch (e) {
// // // // // // // // //       // 에러 핸들링
// // // // // // // // //     } finally {
// // // // // // // // //       if (mounted) {
// // // // // // // // //         setState(() => _isLoading = false);
// // // // // // // // //       }
// // // // // // // // //     }
// // // // // // // // //   }

// // // // // // // // //   @override
// // // // // // // // //   Widget build(BuildContext context) {
// // // // // // // // //     return Scaffold(
// // // // // // // // //       appBar: AppBar(
// // // // // // // // //         title: const Text('분석 히스토리'),
// // // // // // // // //         actions: [
// // // // // // // // //           IconButton(onPressed: _fetchHistory, icon: const Icon(Icons.refresh)),
// // // // // // // // //         ],
// // // // // // // // //       ),
// // // // // // // // //       body: _isLoading
// // // // // // // // //           ? const Center(child: CircularProgressIndicator())
// // // // // // // // //           : _historyList.isEmpty
// // // // // // // // //               ? const Center(child: Text('히스토리가 없습니다.'))
// // // // // // // // //               : ListView.builder(
// // // // // // // // //                   padding: const EdgeInsets.symmetric(vertical: 8),
// // // // // // // // //                   itemCount: _historyList.length,
// // // // // // // // //                   itemBuilder: (context, index) {
// // // // // // // // //                     final item = _historyList[index];
// // // // // // // // //                     final actionType = item['action_type'] ?? '';

// // // // // // // // //                     return Card(
// // // // // // // // //                       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // // // // // // // //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // // // // // // // //                       elevation: 2,
// // // // // // // // //                       child: InkWell(
// // // // // // // // //                         borderRadius: BorderRadius.circular(12),
// // // // // // // // //                         onTap: () {
// // // // // // // // //                           Navigator.push(
// // // // // // // // //                             context,
// // // // // // // // //                             MaterialPageRoute(
// // // // // // // // //                               builder: (context) => HistoryDetailScreen(item: item),
// // // // // // // // //                             ),
// // // // // // // // //                           );
// // // // // // // // //                         },
// // // // // // // // //                         child: Padding(
// // // // // // // // //                           padding: const EdgeInsets.all(12),
// // // // // // // // //                           child: Row(
// // // // // // // // //                             children: [
// // // // // // // // //                               ClipRRect(
// // // // // // // // //                                 borderRadius: BorderRadius.circular(8),
// // // // // // // // //                                 child: item['image_url'] != null
// // // // // // // // //                                     ? Image.network(
// // // // // // // // //                                         item['image_url'],
// // // // // // // // //                                         width: 65,
// // // // // // // // //                                         height: 65,
// // // // // // // // //                                         fit: BoxFit.cover,
// // // // // // // // //                                         errorBuilder: (context, error, stackTrace) =>
// // // // // // // // //                                             Container(width: 65, height: 65, color: Colors.grey.shade300, child: const Icon(Icons.broken_image)),
// // // // // // // // //                                       )
// // // // // // // // //                                     : Container(width: 65, height: 65, color: Colors.grey.shade300, child: const Icon(Icons.image)),
// // // // // // // // //                               ),
// // // // // // // // //                               const SizedBox(width: 14),
// // // // // // // // //                               Expanded(
// // // // // // // // //                                 child: Column(
// // // // // // // // //                                   crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //                                   children: [
// // // // // // // // //                                     Row(
// // // // // // // // //                                       children: [
// // // // // // // // //                                         Container(
// // // // // // // // //                                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
// // // // // // // // //                                           decoration: BoxDecoration(
// // // // // // // // //                                             color: Colors.deepPurple.shade50,
// // // // // // // // //                                             borderRadius: BorderRadius.circular(6),
// // // // // // // // //                                           ),
// // // // // // // // //                                           child: Text(
// // // // // // // // //                                             item['category'] ?? '미분류',
// // // // // // // // //                                             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepPurple),
// // // // // // // // //                                           ),
// // // // // // // // //                                         ),
// // // // // // // // //                                         const Spacer(),
// // // // // // // // //                                         if (actionType.contains('일정') || actionType.contains('캘린더'))
// // // // // // // // //                                           const Icon(Icons.calendar_month, size: 18, color: Colors.blueAccent)
// // // // // // // // //                                         else if (actionType.contains('지도') || actionType.contains('매핑'))
// // // // // // // // //                                           const Icon(Icons.location_on, size: 18, color: Colors.redAccent),
// // // // // // // // //                                       ],
// // // // // // // // //                                     ),
// // // // // // // // //                                     const SizedBox(height: 6),
// // // // // // // // //                                     Text(
// // // // // // // // //                                       item['summary'] ?? '요약 내용 없음',
// // // // // // // // //                                       maxLines: 2,
// // // // // // // // //                                       overflow: TextOverflow.ellipsis,
// // // // // // // // //                                       style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
// // // // // // // // //                                     ),
// // // // // // // // //                                   ],
// // // // // // // // //                                 ),
// // // // // // // // //                               ),
// // // // // // // // //                               const Icon(Icons.chevron_right, color: Colors.grey),
// // // // // // // // //                             ],
// // // // // // // // //                           ),
// // // // // // // // //                         ),
// // // // // // // // //                       ),
// // // // // // // // //                     );
// // // // // // // // //                   },
// // // // // // // // //                 ),
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // // }

// // // // // // // // // // -------------------------------------------------------------
// // // // // // // // // // 4. 히스토리 상세 화면 (상세 정보 및 네이버 지도 연동 뷰)
// // // // // // // // // // -------------------------------------------------------------
// // // // // // // // // class HistoryDetailScreen extends StatelessWidget {
// // // // // // // // //   final Map<String, dynamic> item;

// // // // // // // // //   const HistoryDetailScreen({super.key, required this.item});

// // // // // // // // //   Future<void> _openNaverMap(String query) async {
// // // // // // // // //     final encodedQuery = Uri.encodeComponent(query);
// // // // // // // // //     final url = Uri.parse('https://map.naver.com/v5/search/$encodedQuery');
// // // // // // // // //     if (await canLaunchUrl(url)) {
// // // // // // // // //       await launchUrl(url, mode: LaunchMode.externalApplication);
// // // // // // // // //     }
// // // // // // // // //   }

// // // // // // // // //   @override
// // // // // // // // //   Widget build(BuildContext context) {
// // // // // // // // //     final actionType = item['action_type'] ?? '해당없음';
// // // // // // // // //     final isCalendarAction = actionType.contains('일정') || actionType.contains('캘린더');
// // // // // // // // //     final isMapAction = actionType.contains('지도') || actionType.contains('매핑');
// // // // // // // // //     final actionData = item['action_data']?.toString() ?? '';

// // // // // // // // //     return Scaffold(
// // // // // // // // //       appBar: AppBar(
// // // // // // // // //         title: const Text('분석 상세 정보'),
// // // // // // // // //       ),
// // // // // // // // //       body: SingleChildScrollView(
// // // // // // // // //         padding: const EdgeInsets.all(16),
// // // // // // // // //         child: Column(
// // // // // // // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //           children: [
// // // // // // // // //             if (item['image_url'] != null)
// // // // // // // // //               ClipRRect(
// // // // // // // // //                 borderRadius: BorderRadius.circular(12),
// // // // // // // // //                 child: Image.network(
// // // // // // // // //                   item['image_url'],
// // // // // // // // //                   width: double.infinity,
// // // // // // // // //                   height: 260,
// // // // // // // // //                   fit: BoxFit.contain,
// // // // // // // // //                   errorBuilder: (context, error, stackTrace) =>
// // // // // // // // //                       Container(height: 180, color: Colors.grey.shade200, child: const Center(child: Icon(Icons.broken_image, size: 48))),
// // // // // // // // //                 ),
// // // // // // // // //               ),
// // // // // // // // //             const SizedBox(height: 16),

// // // // // // // // //             // 네이버 지도 연동 섹션
// // // // // // // // //             if (isMapAction)
// // // // // // // // //               Card(
// // // // // // // // //                 color: Colors.green.shade50,
// // // // // // // // //                 shape: RoundedRectangleBorder(
// // // // // // // // //                   borderRadius: BorderRadius.circular(12),
// // // // // // // // //                   side: BorderSide(color: Colors.green.shade200),
// // // // // // // // //                 ),
// // // // // // // // //                 margin: const EdgeInsets.only(bottom: 16),
// // // // // // // // //                 child: Padding(
// // // // // // // // //                   padding: const EdgeInsets.all(16),
// // // // // // // // //                   child: Column(
// // // // // // // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //                     children: [
// // // // // // // // //                       const Row(
// // // // // // // // //                         children: [
// // // // // // // // //                           Icon(Icons.location_on, color: Colors.green),
// // // // // // // // //                           SizedBox(width: 8),
// // // // // // // // //                           Text('네이버 지도 매핑 장소', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
// // // // // // // // //                         ],
// // // // // // // // //                       ),
// // // // // // // // //                       const SizedBox(height: 8),
// // // // // // // // //                       Text(
// // // // // // // // //                         actionData.isNotEmpty ? actionData : item['summary'] ?? '장소 정보',
// // // // // // // // //                         style: const TextStyle(fontSize: 14, color: Colors.black87),
// // // // // // // // //                       ),
// // // // // // // // //                       const SizedBox(height: 12),
// // // // // // // // //                       ElevatedButton.icon(
// // // // // // // // //                         onPressed: () {
// // // // // // // // //                           final target = actionData.isNotEmpty ? actionData : item['summary'] ?? '';
// // // // // // // // //                           _openNaverMap(target);
// // // // // // // // //                         },
// // // // // // // // //                         icon: const Icon(Icons.map_outlined, color: Colors.white),
// // // // // // // // //                         label: const Text('네이버 지도에서 위치 확인', style: TextStyle(color: Colors.white)),
// // // // // // // // //                         style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF03C75A)),
// // // // // // // // //                       ),
// // // // // // // // //                     ],
// // // // // // // // //                   ),
// // // // // // // // //                 ),
// // // // // // // // //               ),

// // // // // // // // //             // 캘린더 등록 알림 섹션
// // // // // // // // //             if (isCalendarAction)
// // // // // // // // //               Container(
// // // // // // // // //                 margin: const EdgeInsets.only(bottom: 16),
// // // // // // // // //                 padding: const EdgeInsets.all(12),
// // // // // // // // //                 decoration: BoxDecoration(
// // // // // // // // //                   color: Colors.blue.shade50,
// // // // // // // // //                   borderRadius: BorderRadius.circular(8),
// // // // // // // // //                   border: Border.all(color: Colors.blue.shade200),
// // // // // // // // //                 ),
// // // // // // // // //                 child: const Row(
// // // // // // // // //                   children: [
// // // // // // // // //                     Icon(Icons.event_available, color: Colors.blue),
// // // // // // // // //                     SizedBox(width: 8),
// // // // // // // // //                     Expanded(
// // // // // // // // //                       child: Text('캘린더 일정으로 등록된 항목입니다.', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
// // // // // // // // //                     ),
// // // // // // // // //                   ],
// // // // // // // // //                 ),
// // // // // // // // //               ),

// // // // // // // // //             // 요약 정보 카드
// // // // // // // // //             Card(
// // // // // // // // //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // // // // // // // //               child: Padding(
// // // // // // // // //                 padding: const EdgeInsets.all(16),
// // // // // // // // //                 child: Column(
// // // // // // // // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //                   children: [
// // // // // // // // //                     _buildInfoRow('카테고리', item['category'] ?? '-'),
// // // // // // // // //                     const Divider(height: 24),
// // // // // // // // //                     _buildInfoRow('액션 분류', actionType),
// // // // // // // // //                     const Divider(height: 24),
// // // // // // // // //                     _buildInfoRow('요약 내용', item['summary'] ?? '-'),
// // // // // // // // //                     if (actionData.isNotEmpty) ...[
// // // // // // // // //                       const Divider(height: 24),
// // // // // // // // //                       _buildInfoRow('상세 데이터', actionData),
// // // // // // // // //                     ],
// // // // // // // // //                     if (item['created_at'] != null) ...[
// // // // // // // // //                       const Divider(height: 24),
// // // // // // // // //                       _buildInfoRow('분석 일시', item['created_at'].toString().split('.')[0].replaceAll('T', ' ')),
// // // // // // // // //                     ],
// // // // // // // // //                   ],
// // // // // // // // //                 ),
// // // // // // // // //               ),
// // // // // // // // //             ),
// // // // // // // // //           ],
// // // // // // // // //         ),
// // // // // // // // //       ),
// // // // // // // // //     );
// // // // // // // // //   }

// // // // // // // // //   Widget _buildInfoRow(String label, String value) {
// // // // // // // // //     return Column(
// // // // // // // // //       crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // //       children: [
// // // // // // // // //         Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
// // // // // // // // //         const SizedBox(height: 4),
// // // // // // // // //         Text(value, style: const TextStyle(fontSize: 15, height: 1.4)),
// // // // // // // // //       ],
// // // // // // // // //     );
// // // // // // // // //   }
// // // // // // // // // }

// // // // // // // // // // import 'dart:convert';
// // // // // // // // // // import 'dart:io';
// // // // // // // // // // import 'package:flutter/material.dart';
// // // // // // // // // // import 'package:http/http.dart' as http;
// // // // // // // // // // import 'package:image_picker/image_picker.dart';
// // // // // // // // // // import 'package:table_calendar/table_calendar.dart';
// // // // // // // // // // import 'package:url_launcher/url_launcher.dart';

// // // // // // // // // // // 로컬 환경에 맞게 서버 IP/포트 설정 (안드로이드 에뮬레이터 기준 10.0.2.2:8000, 실제 기기는 PC IP 입력)
// // // // // // // // // // const String baseUrl = "http://10.0.2.2:8000";

// // // // // // // // // // void main() {
// // // // // // // // // //   runApp(const MyApp());
// // // // // // // // // // }

// // // // // // // // // // class MyApp extends StatelessWidget {
// // // // // // // // // //   const MyApp({super.key});

// // // // // // // // // //   @override
// // // // // // // // // //   Widget build(BuildContext context) {
// // // // // // // // // //     return MaterialApp(
// // // // // // // // // //       title: 'T.Salmon',
// // // // // // // // // //       theme: ThemeData(
// // // // // // // // // //         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
// // // // // // // // // //         useMaterial3: true,
// // // // // // // // // //       ),
// // // // // // // // // //       home: const MainNavigationScreen(),
// // // // // // // // // //     );
// // // // // // // // // //   }
// // // // // // // // // // }

// // // // // // // // // // class MainNavigationScreen extends StatefulWidget {
// // // // // // // // // //   const MainNavigationScreen({super.key});

// // // // // // // // // //   @override
// // // // // // // // // //   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// // // // // // // // // // }

// // // // // // // // // // class _MainNavigationScreenState extends State<MainNavigationScreen> {
// // // // // // // // // //   int _currentIndex = 0;

// // // // // // // // // //   final List<Widget> _screens = const [
// // // // // // // // // //     UploadScreen(),
// // // // // // // // // //     CalendarScreen(),
// // // // // // // // // //     HistoryScreen(),
// // // // // // // // // //   ];

// // // // // // // // // //   @override
// // // // // // // // // //   Widget build(BuildContext context) {
// // // // // // // // // //     return Scaffold(
// // // // // // // // // //       body: _screens[_currentIndex],
// // // // // // // // // //       bottomNavigationBar: NavigationBar(
// // // // // // // // // //         selectedIndex: _currentIndex,
// // // // // // // // // //         onDestinationSelected: (index) => setState(() => _currentIndex = index),
// // // // // // // // // //         destinations: const [
// // // // // // // // // //           NavigationDestination(
// // // // // // // // // //             icon: Icon(Icons.cloud_upload_outlined),
// // // // // // // // // //             selectedIcon: Icon(Icons.cloud_upload),
// // // // // // // // // //             label: '업로드',
// // // // // // // // // //           ),
// // // // // // // // // //           NavigationDestination(
// // // // // // // // // //             icon: Icon(Icons.calendar_month_outlined),
// // // // // // // // // //             selectedIcon: Icon(Icons.calendar_month),
// // // // // // // // // //             label: '캘린더',
// // // // // // // // // //           ),
// // // // // // // // // //           NavigationDestination(
// // // // // // // // // //             icon: Icon(Icons.history_outlined),
// // // // // // // // // //             selectedIcon: Icon(Icons.history),
// // // // // // // // // //             label: '히스토리',
// // // // // // // // // //           ),
// // // // // // // // // //         ],
// // // // // // // // // //       ),
// // // // // // // // // //     );
// // // // // // // // // //   }
// // // // // // // // // // }

// // // // // // // // // // // -------------------------------------------------------------
// // // // // // // // // // // 1. 업로드 탭 (스크린샷 수동 선택 및 /api/v1/analyze 호출)
// // // // // // // // // // // -------------------------------------------------------------
// // // // // // // // // // class UploadScreen extends StatefulWidget {
// // // // // // // // // //   const UploadScreen({super.key});

// // // // // // // // // //   @override
// // // // // // // // // //   State<UploadScreen> createState() => _UploadScreenState();
// // // // // // // // // // }

// // // // // // // // // // class _UploadScreenState extends State<UploadScreen> {
// // // // // // // // // //   File? _selectedImage;
// // // // // // // // // //   bool _isLoading = false;
// // // // // // // // // //   Map<String, dynamic>? _analysisResult;

// // // // // // // // // //   final ImagePicker _picker = ImagePicker();

// // // // // // // // // //   Future<void> _pickAndUploadImage() async {
// // // // // // // // // //     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
// // // // // // // // // //     if (pickedFile == null) return;

// // // // // // // // // //     setState(() {
// // // // // // // // // //       _selectedImage = File(pickedFile.path);
// // // // // // // // // //       _isLoading = true;
// // // // // // // // // //       _analysisResult = null;
// // // // // // // // // //     });

// // // // // // // // // //     try {
// // // // // // // // // //       final uri = Uri.parse('$baseUrl/api/v1/analyze');
// // // // // // // // // //       final request = http.MultipartRequest('POST', uri);
// // // // // // // // // //       request.files.add(await http.MultipartFile.fromPath('file', pickedFile.path));

// // // // // // // // // //       final streamedResponse = await request.send();
// // // // // // // // // //       final response = await http.Response.fromStream(streamedResponse);

// // // // // // // // // //       if (response.statusCode == 200) {
// // // // // // // // // //         final decoded = jsonDecode(utf8.decode(response.bodyBytes));
// // // // // // // // // //         setState(() {
// // // // // // // // // //           _analysisResult = decoded['analysis'];
// // // // // // // // // //         });
// // // // // // // // // //         if (mounted) {
// // // // // // // // // //           ScaffoldMessenger.of(context).showSnackBar(
// // // // // // // // // //             const SnackBar(content: Text('분석 및 저장이 완료되었습니다!')),
// // // // // // // // // //           );
// // // // // // // // // //         }
// // // // // // // // // //       } else {
// // // // // // // // // //         throw Exception('서버 응답 오류: ${response.statusCode}');
// // // // // // // // // //       }
// // // // // // // // // //     } catch (e) {
// // // // // // // // // //       if (mounted) {
// // // // // // // // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // // // // // // // //           SnackBar(content: Text('업로드 실패: $e')),
// // // // // // // // // //         );
// // // // // // // // // //       }
// // // // // // // // // //     } finally {
// // // // // // // // // //       setState(() => _isLoading = false);
// // // // // // // // // //     }
// // // // // // // // // //   }

// // // // // // // // // //   @override
// // // // // // // // // //   Widget build(BuildContext context) {
// // // // // // // // // //     return Scaffold(
// // // // // // // // // //       appBar: AppBar(title: const Text('스크린샷 분석')),
// // // // // // // // // //       body: SingleChildScrollView(
// // // // // // // // // //         padding: const EdgeInsets.all(16),
// // // // // // // // // //         child: Column(
// // // // // // // // // //           children: [
// // // // // // // // // //             if (_selectedImage != null)
// // // // // // // // // //               ClipRRect(
// // // // // // // // // //                 borderRadius: BorderRadius.circular(12),
// // // // // // // // // //                 child: Image.file(_selectedImage!, height: 260, fit: BoxFit.cover),
// // // // // // // // // //               )
// // // // // // // // // //             else
// // // // // // // // // //               Container(
// // // // // // // // // //                 height: 200,
// // // // // // // // // //                 decoration: BoxDecoration(
// // // // // // // // // //                   color: Colors.grey.shade200,
// // // // // // // // // //                   borderRadius: BorderRadius.circular(12),
// // // // // // // // // //                 ),
// // // // // // // // // //                 child: const Center(child: Text('분석할 스크린샷을 선택하세요')),
// // // // // // // // // //               ),
// // // // // // // // // //             const SizedBox(height: 20),
// // // // // // // // // //             ElevatedButton.icon(
// // // // // // // // // //               onPressed: _isLoading ? null : _pickAndUploadImage,
// // // // // // // // // //               icon: const Icon(Icons.photo_library),
// // // // // // // // // //               label: Text(_isLoading ? '분석 중...' : '갤러리에서 선택 및 분석'),
// // // // // // // // // //               style: ElevatedButton.styleFrom(
// // // // // // // // // //                 minimumSize: const Size.fromHeight(50),
// // // // // // // // // //               ),
// // // // // // // // // //             ),
// // // // // // // // // //             const SizedBox(height: 24),
// // // // // // // // // //             if (_isLoading)
// // // // // // // // // //               const CircularProgressIndicator()
// // // // // // // // // //             else if (_analysisResult != null) ...[
// // // // // // // // // //               const Align(
// // // // // // // // // //                 alignment: Alignment.centerLeft,
// // // // // // // // // //                 child: Text('분석 결과', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // // // // // // //               ),
// // // // // // // // // //               const SizedBox(height: 8),
// // // // // // // // // //               Card(
// // // // // // // // // //                 child: Padding(
// // // // // // // // // //                   padding: const EdgeInsets.all(16),
// // // // // // // // // //                   child: Column(
// // // // // // // // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // // //                     children: [
// // // // // // // // // //                       Text('카테고리: ${_analysisResult?['category'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // // // // // // //                       const SizedBox(height: 6),
// // // // // // // // // //                       Text('액션 타입: ${_analysisResult?['action_type'] ?? '-'}'),
// // // // // // // // // //                       const SizedBox(height: 6),
// // // // // // // // // //                       Text('요약: ${_analysisResult?['summary'] ?? '-'}'),
// // // // // // // // // //                       if (_analysisResult?['action_data'] != null && _analysisResult?['action_data'] != "") ...[
// // // // // // // // // //                         const SizedBox(height: 6),
// // // // // // // // // //                         Text('상세: ${_analysisResult?['action_data']}'),
// // // // // // // // // //                       ],
// // // // // // // // // //                     ],
// // // // // // // // // //                   ),
// // // // // // // // // //                 ),
// // // // // // // // // //               ),
// // // // // // // // // //             ],
// // // // // // // // // //           ],
// // // // // // // // // //         ),
// // // // // // // // // //       ),
// // // // // // // // // //     );
// // // // // // // // // //   }
// // // // // // // // // // }

// // // // // // // // // // // -------------------------------------------------------------
// // // // // // // // // // // 2. 캘린더 탭 (/api/v1/calendar/ 연동)
// // // // // // // // // // // -------------------------------------------------------------
// // // // // // // // // // class CalendarScreen extends StatefulWidget {
// // // // // // // // // //   const CalendarScreen({super.key});

// // // // // // // // // //   @override
// // // // // // // // // //   State<CalendarScreen> createState() => _CalendarScreenState();
// // // // // // // // // // }

// // // // // // // // // // class _CalendarScreenState extends State<CalendarScreen> {
// // // // // // // // // //   CalendarFormat _calendarFormat = CalendarFormat.month;
// // // // // // // // // //   DateTime _focusedDay = DateTime.now();
// // // // // // // // // //   DateTime? _selectedDay;
// // // // // // // // // //   List<dynamic> _events = [];
// // // // // // // // // //   bool _isLoading = true;

// // // // // // // // // //   @override
// // // // // // // // // //   void initState() {
// // // // // // // // // //     super.initState();
// // // // // // // // // //     _fetchCalendarEvents();
// // // // // // // // // //   }

// // // // // // // // // //   Future<void> _fetchCalendarEvents() async {
// // // // // // // // // //     setState(() => _isLoading = true);
// // // // // // // // // //     try {
// // // // // // // // // //       final response = await http.get(Uri.parse('$baseUrl/api/v1/calendar/'));
// // // // // // // // // //       if (response.statusCode == 200) {
// // // // // // // // // //         final data = jsonDecode(utf8.decode(response.bodyBytes));
// // // // // // // // // //         setState(() {
// // // // // // // // // //           _events = data['events'] ?? [];
// // // // // // // // // //         });
// // // // // // // // // //       }
// // // // // // // // // //     } catch (e) {
// // // // // // // // // //       // 에러 핸들링
// // // // // // // // // //     } finally {
// // // // // // // // // //       setState(() => _isLoading = false);
// // // // // // // // // //     }
// // // // // // // // // //   }

// // // // // // // // // //   @override
// // // // // // // // // //   Widget build(BuildContext context) {
// // // // // // // // // //     return Scaffold(
// // // // // // // // // //       appBar: AppBar(
// // // // // // // // // //         title: const Text('등록된 일정'),
// // // // // // // // // //         actions: [
// // // // // // // // // //           IconButton(onPressed: _fetchCalendarEvents, icon: const Icon(Icons.refresh)),
// // // // // // // // // //         ],
// // // // // // // // // //       ),
// // // // // // // // // //       body: _isLoading
// // // // // // // // // //           ? const Center(child: CircularProgressIndicator())
// // // // // // // // // //           : Column(
// // // // // // // // // //               children: [
// // // // // // // // // //                 TableCalendar(
// // // // // // // // // //                   firstDay: DateTime.utc(2020, 1, 1),
// // // // // // // // // //                   lastDay: DateTime.utc(2030, 12, 31),
// // // // // // // // // //                   focusedDay: _focusedDay,
// // // // // // // // // //                   calendarFormat: _calendarFormat,
// // // // // // // // // //                   selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
// // // // // // // // // //                   onDaySelected: (selectedDay, focusedDay) {
// // // // // // // // // //                     setState(() {
// // // // // // // // // //                       _selectedDay = selectedDay;
// // // // // // // // // //                       _focusedDay = focusedDay;
// // // // // // // // // //                     });
// // // // // // // // // //                   },
// // // // // // // // // //                   onFormatChanged: (format) {
// // // // // // // // // //                     setState(() => _calendarFormat = format);
// // // // // // // // // //                   },
// // // // // // // // // //                 ),
// // // // // // // // // //                 const Divider(),
// // // // // // // // // //                 Expanded(
// // // // // // // // // //                   child: _events.isEmpty
// // // // // // // // // //                       ? const Center(child: Text('등록된 일정이 없습니다.'))
// // // // // // // // // //                       : ListView.builder(
// // // // // // // // // //                           itemCount: _events.length,
// // // // // // // // // //                           itemBuilder: (context, index) {
// // // // // // // // // //                             final item = _events[index];
// // // // // // // // // //                             return ListTile(
// // // // // // // // // //                               leading: const Icon(Icons.event_note, color: Colors.deepPurple),
// // // // // // // // // //                               title: Text(item['summary'] ?? '제목 없음'),
// // // // // // // // // //                               subtitle: Text(item['action_data'] ?? item['category'] ?? ''),
// // // // // // // // // //                             );
// // // // // // // // // //                           },
// // // // // // // // // //                         ),
// // // // // // // // // //                 ),
// // // // // // // // // //               ],
// // // // // // // // // //             ),
// // // // // // // // // //     );
// // // // // // // // // //   }
// // // // // // // // // // }

// // // // // // // // // // // -------------------------------------------------------------
// // // // // // // // // // // 3. 히스토리 탭 (/api/v1/history/ 연동)
// // // // // // // // // // // -------------------------------------------------------------
// // // // // // // // // // class HistoryScreen extends StatefulWidget {
// // // // // // // // // //   const HistoryScreen({super.key});

// // // // // // // // // //   @override
// // // // // // // // // //   State<HistoryScreen> createState() => _HistoryScreenState();
// // // // // // // // // // }

// // // // // // // // // // class _HistoryScreenState extends State<HistoryScreen> {
// // // // // // // // // //   List<dynamic> _historyList = [];
// // // // // // // // // //   bool _isLoading = true;

// // // // // // // // // //   @override
// // // // // // // // // //   void initState() {
// // // // // // // // // //     super.initState();
// // // // // // // // // //     _fetchHistory();
// // // // // // // // // //   }

// // // // // // // // // //   Future<void> _fetchHistory() async {
// // // // // // // // // //     setState(() => _isLoading = true);
// // // // // // // // // //     try {
// // // // // // // // // //       final response = await http.get(Uri.parse('$baseUrl/api/v1/history/'));
// // // // // // // // // //       if (response.statusCode == 200) {
// // // // // // // // // //         final data = jsonDecode(utf8.decode(response.bodyBytes));
// // // // // // // // // //         setState(() {
// // // // // // // // // //           _historyList = data['history'] ?? [];
// // // // // // // // // //         });
// // // // // // // // // //       }
// // // // // // // // // //     } catch (e) {
// // // // // // // // // //       // 에러 핸들링
// // // // // // // // // //     } finally {
// // // // // // // // // //       setState(() => _isLoading = false);
// // // // // // // // // //     }
// // // // // // // // // //   }

// // // // // // // // // //   @override
// // // // // // // // // //   Widget build(BuildContext context) {
// // // // // // // // // //     return Scaffold(
// // // // // // // // // //       appBar: AppBar(
// // // // // // // // // //         title: const Text('분석 히스토리'),
// // // // // // // // // //         actions: [
// // // // // // // // // //           IconButton(onPressed: _fetchHistory, icon: const Icon(Icons.refresh)),
// // // // // // // // // //         ],
// // // // // // // // // //       ),
// // // // // // // // // //       body: _isLoading
// // // // // // // // // //           ? const Center(child: CircularProgressIndicator())
// // // // // // // // // //           : _historyList.isEmpty
// // // // // // // // // //               ? const Center(child: Text('히스토리가 없습니다.'))
// // // // // // // // // //               : ListView.builder(
// // // // // // // // // //                   padding: const EdgeInsets.symmetric(vertical: 8),
// // // // // // // // // //                   itemCount: _historyList.length,
// // // // // // // // // //                   itemBuilder: (context, index) {
// // // // // // // // // //                     final item = _historyList[index];
// // // // // // // // // //                     final actionType = item['action_type'] ?? '';

// // // // // // // // // //                     return Card(
// // // // // // // // // //                       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // // // // // // // // //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // // // // // // // // //                       elevation: 2,
// // // // // // // // // //                       child: InkWell(
// // // // // // // // // //                         borderRadius: BorderRadius.circular(12),
// // // // // // // // // //                         onTap: () {
// // // // // // // // // //                           Navigator.push(
// // // // // // // // // //                             context,
// // // // // // // // // //                             MaterialPageRoute(
// // // // // // // // // //                               builder: (context) => HistoryDetailScreen(item: item),
// // // // // // // // // //                             ),
// // // // // // // // // //                           );
// // // // // // // // // //                         },
// // // // // // // // // //                         child: Padding(
// // // // // // // // // //                           padding: const EdgeInsets.all(12),
// // // // // // // // // //                           child: Row(
// // // // // // // // // //                             children: [
// // // // // // // // // //                               ClipRRect(
// // // // // // // // // //                                 borderRadius: BorderRadius.circular(8),
// // // // // // // // // //                                 child: item['image_url'] != null
// // // // // // // // // //                                     ? Image.network(
// // // // // // // // // //                                         item['image_url'],
// // // // // // // // // //                                         width: 65,
// // // // // // // // // //                                         height: 65,
// // // // // // // // // //                                         fit: BoxFit.cover,
// // // // // // // // // //                                         errorBuilder: (context, error, stackTrace) =>
// // // // // // // // // //                                             Container(width: 65, height: 65, color: Colors.grey.shade300, child: const Icon(Icons.broken_image)),
// // // // // // // // // //                                       )
// // // // // // // // // //                                     : Container(width: 65, height: 65, color: Colors.grey.shade300, child: const Icon(Icons.image)),
// // // // // // // // // //                               ),
// // // // // // // // // //                               const SizedBox(width: 14),
// // // // // // // // // //                               Expanded(
// // // // // // // // // //                                 child: Column(
// // // // // // // // // //                                   crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // // //                                   children: [
// // // // // // // // // //                                     Row(
// // // // // // // // // //                                       children: [
// // // // // // // // // //                                         Container(
// // // // // // // // // //                                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
// // // // // // // // // //                                           decoration: BoxDecoration(
// // // // // // // // // //                                             color: Colors.deepPurple.shade50,
// // // // // // // // // //                                             borderRadius: BorderRadius.circular(6),
// // // // // // // // // //                                           ),
// // // // // // // // // //                                           child: Text(
// // // // // // // // // //                                             item['category'] ?? '미분류',
// // // // // // // // // //                                             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepPurple),
// // // // // // // // // //                                           ),
// // // // // // // // // //                                         ),
// // // // // // // // // //                                         const Spacer(),
// // // // // // // // // //                                         if (actionType.contains('일정') || actionType.contains('캘린더'))
// // // // // // // // // //                                           const Icon(Icons.calendar_month, size: 18, color: Colors.blueAccent)
// // // // // // // // // //                                         else if (actionType.contains('지도') || actionType.contains('매핑'))
// // // // // // // // // //                                           const Icon(Icons.location_on, size: 18, color: Colors.redAccent),
// // // // // // // // // //                                       ],
// // // // // // // // // //                                     ),
// // // // // // // // // //                                     const SizedBox(height: 6),
// // // // // // // // // //                                     Text(
// // // // // // // // // //                                       item['summary'] ?? '요약 내용 없음',
// // // // // // // // // //                                       maxLines: 2,
// // // // // // // // // //                                       overflow: TextOverflow.ellipsis,
// // // // // // // // // //                                       style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
// // // // // // // // // //                                     ),
// // // // // // // // // //                                   ],
// // // // // // // // // //                                 ),
// // // // // // // // // //                               ),
// // // // // // // // // //                               const Icon(Icons.chevron_right, color: Colors.grey),
// // // // // // // // // //                             ],
// // // // // // // // // //                           ),
// // // // // // // // // //                         ),
// // // // // // // // // //                       ),
// // // // // // // // // //                     );
// // // // // // // // // //                   },
// // // // // // // // // //                 ),
// // // // // // // // // //     );
// // // // // // // // // //   }
// // // // // // // // // // }

// // // // // // // // // // // -------------------------------------------------------------
// // // // // // // // // // // 4. 히스토리 상세 화면 (상세 정보 및 네이버 지도 연동 뷰)
// // // // // // // // // // // -------------------------------------------------------------
// // // // // // // // // // class HistoryDetailScreen extends StatelessWidget {
// // // // // // // // // //   final Map<String, dynamic> item;

// // // // // // // // // //   const HistoryDetailScreen({super.key, required this.item});

// // // // // // // // // //   // 네이버 지도 웹/앱 검색 링크 실행
// // // // // // // // // //   Future<void> _openNaverMap(String query) async {
// // // // // // // // // //     final encodedQuery = Uri.encodeComponent(query);
// // // // // // // // // //     final url = Uri.parse('https://map.naver.com/v5/search/$encodedQuery');
// // // // // // // // // //     if (await canLaunchUrl(url)) {
// // // // // // // // // //       await launchUrl(url, mode: LaunchMode.externalApplication);
// // // // // // // // // //     }
// // // // // // // // // //   }

// // // // // // // // // //   @override
// // // // // // // // // //   Widget build(BuildContext context) {
// // // // // // // // // //     final actionType = item['action_type'] ?? '해당없음';
// // // // // // // // // //     final isCalendarAction = actionType.contains('일정') || actionType.contains('캘린더');
// // // // // // // // // //     final isMapAction = actionType.contains('지도') || actionType.contains('매핑');
// // // // // // // // // //     final actionData = item['action_data']?.toString() ?? '';

// // // // // // // // // //     return Scaffold(
// // // // // // // // // //       appBar: AppBar(
// // // // // // // // // //         title: const Text('분석 상세 정보'),
// // // // // // // // // //       ),
// // // // // // // // // //       body: SingleChildScrollView(
// // // // // // // // // //         padding: const EdgeInsets.all(16),
// // // // // // // // // //         child: Column(
// // // // // // // // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // // //           children: [
// // // // // // // // // //             // 원본 스크린샷 이미지
// // // // // // // // // //             if (item['image_url'] != null)
// // // // // // // // // //               ClipRRect(
// // // // // // // // // //                 borderRadius: BorderRadius.circular(12),
// // // // // // // // // //                 child: Image.network(
// // // // // // // // // //                   item['image_url'],
// // // // // // // // // //                   width: double.infinity,
// // // // // // // // // //                   height: 260,
// // // // // // // // // //                   fit: BoxFit.contain,
// // // // // // // // // //                   errorBuilder: (context, error, stackTrace) =>
// // // // // // // // // //                       Container(height: 180, color: Colors.grey.shade200, child: const Center(child: Icon(Icons.broken_image, size: 48))),
// // // // // // // // // //                 ),
// // // // // // // // // //               ),
// // // // // // // // // //             const SizedBox(height: 16),

// // // // // // // // // //             // 1. 지도 매핑 활성화 섹션 (네이버 지도 연동)
// // // // // // // // // //             if (isMapAction)
// // // // // // // // // //               Card(
// // // // // // // // // //                 color: Colors.green.shade50,
// // // // // // // // // //                 shape: RoundedRectangleBorder(
// // // // // // // // // //                   borderRadius: BorderRadius.circular(12),
// // // // // // // // // //                   side: BorderSide(color: Colors.green.shade200),
// // // // // // // // // //                 ),
// // // // // // // // // //                 margin: const EdgeInsets.only(bottom: 16),
// // // // // // // // // //                 child: Padding(
// // // // // // // // // //                   padding: const EdgeInsets.all(16),
// // // // // // // // // //                   child: Column(
// // // // // // // // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // // //                     children: [
// // // // // // // // // //                       const Row(
// // // // // // // // // //                         children: [
// // // // // // // // // //                           Icon(Icons.location_on, color: Colors.green),
// // // // // // // // // //                           SizedBox(width: 8),
// // // // // // // // // //                           Text('네이버 지도 매핑 장소', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
// // // // // // // // // //                         ],
// // // // // // // // // //                       ),
// // // // // // // // // //                       const SizedBox(height: 8),
// // // // // // // // // //                       Text(
// // // // // // // // // //                         actionData.isNotEmpty ? actionData : item['summary'] ?? '장소 정보',
// // // // // // // // // //                         style: const TextStyle(fontSize: 14, color: Colors.black87),
// // // // // // // // // //                       ),
// // // // // // // // // //                       const SizedBox(height: 12),
// // // // // // // // // //                       ElevatedButton.icon(
// // // // // // // // // //                         onPressed: () {
// // // // // // // // // //                           final target = actionData.isNotEmpty ? actionData : item['summary'] ?? '';
// // // // // // // // // //                           _openNaverMap(target);
// // // // // // // // // //                         },
// // // // // // // // // //                         icon: const Icon(Icons.map_outlined, color: Colors.white),
// // // // // // // // // //                         label: const Text('네이버 지도에서 위치 확인', style: TextStyle(color: Colors.white)),
// // // // // // // // // //                         style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF03C75A)),
// // // // // // // // // //                       ),
// // // // // // // // // //                     ],
// // // // // // // // // //                   ),
// // // // // // // // // //                 ),
// // // // // // // // // //               ),

// // // // // // // // // //             // 2. 캘린더 등록 알림 섹션
// // // // // // // // // //             if (isCalendarAction)
// // // // // // // // // //               Container(
// // // // // // // // // //                 margin: const EdgeInsets.only(bottom: 16),
// // // // // // // // // //                 padding: const EdgeInsets.all(12),
// // // // // // // // // //                 decoration: BoxDecoration(
// // // // // // // // // //                   color: Colors.blue.shade50,
// // // // // // // // // //                   borderRadius: BorderRadius.circular(8),
// // // // // // // // // //                   border: Border.all(color: Colors.blue.shade200),
// // // // // // // // // //                 ),
// // // // // // // // // //                 child: const Row(
// // // // // // // // // //                   children: [
// // // // // // // // // //                     Icon(Icons.event_available, color: Colors.blue),
// // // // // // // // // //                     SizedBox(width: 8),
// // // // // // // // // //                     Expanded(
// // // // // // // // // //                       child: Text('캘린더 일정으로 등록된 항목입니다.', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
// // // // // // // // // //                     ),
// // // // // // // // // //                   ],
// // // // // // // // // //                 ),
// // // // // // // // // //               ),

// // // // // // // // // //             // 기본 요약 정보 카드
// // // // // // // // // //             Card(
// // // // // // // // // //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // // // // // // // // //               child: Padding(
// // // // // // // // // //                 padding: const EdgeInsets.all(16),
// // // // // // // // // //                 child: Column(
// // // // // // // // // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // // //                   children: [
// // // // // // // // // //                     _buildInfoRow('카테고리', item['category'] ?? '-'),
// // // // // // // // // //                     const Divider(height: 24),
// // // // // // // // // //                     _buildInfoRow('액션 분류', actionType),
// // // // // // // // // //                     const Divider(height: 24),
// // // // // // // // // //                     _buildInfoRow('요약 내용', item['summary'] ?? '-'),
// // // // // // // // // //                     if (actionData.isNotEmpty) ...[
// // // // // // // // // //                       const Divider(height: 24),
// // // // // // // // // //                       _buildInfoRow('상세 데이터', actionData),
// // // // // // // // // //                     ],
// // // // // // // // // //                     if (item['created_at'] != null) ...[
// // // // // // // // // //                       const Divider(height: 24),
// // // // // // // // // //                       _buildInfoRow('분석 일시', item['created_at'].toString().split('.')[0].replaceAll('T', ' ')),
// // // // // // // // // //                     ],
// // // // // // // // // //                   ],
// // // // // // // // // //                 ),
// // // // // // // // // //               ),
// // // // // // // // // //             ),
// // // // // // // // // //           ],
// // // // // // // // // //         ),
// // // // // // // // // //       ),
// // // // // // // // // //     );
// // // // // // // // // //   }

// // // // // // // // // //   Widget _buildInfoRow(String label, String value) {
// // // // // // // // // //     return Column(
// // // // // // // // // //       crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // // //       children: [
// // // // // // // // // //         Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
// // // // // // // // // //         const SizedBox(height: 4),
// // // // // // // // // //         Text(value, style: const TextStyle(fontSize: 15, height: 1.4)),
// // // // // // // // // //       ],
// // // // // // // // // //     );
// // // // // // // // // //   }
// // // // // // // // // // }

// // // // // // // // // // // import 'dart:convert';
// // // // // // // // // // // import 'dart:io';
// // // // // // // // // // // import 'package:flutter/material.dart';
// // // // // // // // // // // import 'package:http/http.dart' as http;
// // // // // // // // // // // import 'package:image_picker/image_picker.dart';
// // // // // // // // // // // import 'package:table_calendar/table_calendar.dart';

// // // // // // // // // // // // 로컬 환경에 맞게 서버 IP/포트 설정 (안드로이드 에뮬레이터 기준 10.0.2.2:8000, 실제 기기는 PC IP 입력)
// // // // // // // // // // // const String baseUrl = "http://10.0.2.2:8000";

// // // // // // // // // // // void main() {
// // // // // // // // // // //   runApp(const MyApp());
// // // // // // // // // // // }

// // // // // // // // // // // class MyApp extends StatelessWidget {
// // // // // // // // // // //   const MyApp({super.key});

// // // // // // // // // // //   @override
// // // // // // // // // // //   Widget build(BuildContext context) {
// // // // // // // // // // //     return MaterialApp(
// // // // // // // // // // //       title: 'T.Salmon',
// // // // // // // // // // //       theme: ThemeData(
// // // // // // // // // // //         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
// // // // // // // // // // //         useMaterial3: true,
// // // // // // // // // // //       ),
// // // // // // // // // // //       home: const MainNavigationScreen(),
// // // // // // // // // // //     );
// // // // // // // // // // //   }
// // // // // // // // // // // }

// // // // // // // // // // // class MainNavigationScreen extends StatefulWidget {
// // // // // // // // // // //   const MainNavigationScreen({super.key});

// // // // // // // // // // //   @override
// // // // // // // // // // //   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// // // // // // // // // // // }

// // // // // // // // // // // class _MainNavigationScreenState extends State<MainNavigationScreen> {
// // // // // // // // // // //   int _currentIndex = 0;

// // // // // // // // // // //   final List<Widget> _screens = const [
// // // // // // // // // // //     UploadScreen(),
// // // // // // // // // // //     CalendarScreen(),
// // // // // // // // // // //     HistoryScreen(),
// // // // // // // // // // //   ];

// // // // // // // // // // //   @override
// // // // // // // // // // //   Widget build(BuildContext context) {
// // // // // // // // // // //     return Scaffold(
// // // // // // // // // // //       body: _screens[_currentIndex],
// // // // // // // // // // //       bottomNavigationBar: NavigationBar(
// // // // // // // // // // //         selectedIndex: _currentIndex,
// // // // // // // // // // //         onDestinationSelected: (index) => setState(() => _currentIndex = index),
// // // // // // // // // // //         destinations: const [
// // // // // // // // // // //           NavigationDestination(icon: Icon(Icons.cloud_upload_outlined), selectedIcon: Icon(Icons.cloud_upload), label: '업로드'),
// // // // // // // // // // //           NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: '캘린더'),
// // // // // // // // // // //           NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: '히스토리'),
// // // // // // // // // // //         ],
// // // // // // // // // // //       ),
// // // // // // // // // // //     );
// // // // // // // // // // //   }
// // // // // // // // // // // }

// // // // // // // // // // // // -------------------------------------------------------------
// // // // // // // // // // // // 1. 업로드 탭 (스크린샷 수동 선택 및 /api/v1/analyze 호출)
// // // // // // // // // // // // -------------------------------------------------------------
// // // // // // // // // // // class UploadScreen extends StatefulWidget {
// // // // // // // // // // //   const UploadScreen({super.key});

// // // // // // // // // // //   @override
// // // // // // // // // // //   State<UploadScreen> createState() => _UploadScreenState();
// // // // // // // // // // // }

// // // // // // // // // // // class _UploadScreenState extends State<UploadScreen> {
// // // // // // // // // // //   File? _selectedImage;
// // // // // // // // // // //   bool _isLoading = false;
// // // // // // // // // // //   Map<String, dynamic>? _analysisResult;

// // // // // // // // // // //   final ImagePicker _picker = ImagePicker();

// // // // // // // // // // //   Future<void> _pickAndUploadImage() async {
// // // // // // // // // // //     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
// // // // // // // // // // //     if (pickedFile == null) return;

// // // // // // // // // // //     setState(() {
// // // // // // // // // // //       _selectedImage = File(pickedFile.path);
// // // // // // // // // // //       _isLoading = true;
// // // // // // // // // // //       _analysisResult = null;
// // // // // // // // // // //     });

// // // // // // // // // // //     try {
// // // // // // // // // // //       final uri = Uri.parse('$baseUrl/api/v1/analyze');
// // // // // // // // // // //       final request = http.MultipartRequest('POST', uri);
// // // // // // // // // // //       request.files.add(await http.MultipartFile.fromPath('file', pickedFile.path));

// // // // // // // // // // //       final streamedResponse = await request.send();
// // // // // // // // // // //       final response = await http.Response.fromStream(streamedResponse);

// // // // // // // // // // //       if (response.statusCode == 200) {
// // // // // // // // // // //         final decoded = jsonDecode(utf8.decode(response.bodyBytes));
// // // // // // // // // // //         setState(() {
// // // // // // // // // // //           _analysisResult = decoded['analysis'];
// // // // // // // // // // //         });
// // // // // // // // // // //         if (mounted) {
// // // // // // // // // // //           ScaffoldMessenger.of(context).showSnackBar(
// // // // // // // // // // //             const SnackBar(content: Text('분석 및 저장이 완료되었습니다!')),
// // // // // // // // // // //           );
// // // // // // // // // // //         }
// // // // // // // // // // //       } else {
// // // // // // // // // // //         throw Exception('서버 응답 오류: ${response.statusCode}');
// // // // // // // // // // //       }
// // // // // // // // // // //     } catch (e) {
// // // // // // // // // // //       if (mounted) {
// // // // // // // // // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // // // // // // // // //           SnackBar(content: Text('업로드 실패: $e')),
// // // // // // // // // // //         );
// // // // // // // // // // //       }
// // // // // // // // // // //     } finally {
// // // // // // // // // // //       setState(() => _isLoading = false);
// // // // // // // // // // //     }
// // // // // // // // // // //   }

// // // // // // // // // // //   @override
// // // // // // // // // // //   Widget build(BuildContext context) {
// // // // // // // // // // //     return Scaffold(
// // // // // // // // // // //       appBar: AppBar(title: const Text('스크린샷 분석')),
// // // // // // // // // // //       body: SingleChildScrollView(
// // // // // // // // // // //         padding: const EdgeInsets.all(16),
// // // // // // // // // // //         child: Column(
// // // // // // // // // // //           children: [
// // // // // // // // // // //             if (_selectedImage != null)
// // // // // // // // // // //               ClipRRect(
// // // // // // // // // // //                 borderRadius: BorderRadius.circular(12),
// // // // // // // // // // //                 child: Image.file(_selectedImage!, height: 260, fit: BoxFit.cover),
// // // // // // // // // // //               )
// // // // // // // // // // //             else
// // // // // // // // // // //               Container(
// // // // // // // // // // //                 height: 200,
// // // // // // // // // // //                 decoration: BoxDecoration(
// // // // // // // // // // //                   color: Colors.grey.shade200,
// // // // // // // // // // //                   borderRadius: BorderRadius.circular(12),
// // // // // // // // // // //                 ),
// // // // // // // // // // //                 child: const Center(child: Text('분석할 스크린샷을 선택하세요')),
// // // // // // // // // // //               ),
// // // // // // // // // // //             const SizedBox(height: 20),
// // // // // // // // // // //             ElevatedButton.icon(
// // // // // // // // // // //               onPressed: _isLoading ? null : _pickAndUploadImage,
// // // // // // // // // // //               icon: const Icon(Icons.photo_library),
// // // // // // // // // // //               label: Text(_isLoading ? '분석 중...' : '갤러리에서 선택 및 분석'),
// // // // // // // // // // //               style: ElevatedButton.styleFrom(
// // // // // // // // // // //                 minimumSize: const Size.fromHeight(50),
// // // // // // // // // // //               ),
// // // // // // // // // // //             ),
// // // // // // // // // // //             const SizedBox(height: 24),
// // // // // // // // // // //             if (_isLoading)
// // // // // // // // // // //               const CircularProgressIndicator()
// // // // // // // // // // //             else if (_analysisResult != null) ...[
// // // // // // // // // // //               const Align(
// // // // // // // // // // //                 alignment: Alignment.centerLeft,
// // // // // // // // // // //                 child: Text('분석 결과', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // // // // // // // //               ),
// // // // // // // // // // //               const SizedBox(height: 8),
// // // // // // // // // // //               Card(
// // // // // // // // // // //                 child: Padding(
// // // // // // // // // // //                   padding: const EdgeInsets.all(16),
// // // // // // // // // // //                   child: Column(
// // // // // // // // // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // // // //                     children: [
// // // // // // // // // // //                       Text('카테고리: ${_analysisResult?['category'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold)),
// // // // // // // // // // //                       const SizedBox(height: 6),
// // // // // // // // // // //                       Text('액션 타입: ${_analysisResult?['action_type'] ?? '-'}'),
// // // // // // // // // // //                       const SizedBox(height: 6),
// // // // // // // // // // //                       Text('요약: ${_analysisResult?['summary'] ?? '-'}'),
// // // // // // // // // // //                       if (_analysisResult?['action_data'] != null && _analysisResult?['action_data'] != "") ...[
// // // // // // // // // // //                         const SizedBox(height: 6),
// // // // // // // // // // //                         Text('상세: ${_analysisResult?['action_data']}'),
// // // // // // // // // // //                       ],
// // // // // // // // // // //                     ],
// // // // // // // // // // //                   ),
// // // // // // // // // // //                 ),
// // // // // // // // // // //               ),
// // // // // // // // // // //             ],
// // // // // // // // // // //           ],
// // // // // // // // // // //         ),
// // // // // // // // // // //       ),
// // // // // // // // // // //     );
// // // // // // // // // // //   }
// // // // // // // // // // // }

// // // // // // // // // // // // -------------------------------------------------------------
// // // // // // // // // // // // 2. 캘린더 탭 (/api/v1/calendar 연동)
// // // // // // // // // // // // -------------------------------------------------------------
// // // // // // // // // // // class CalendarScreen extends StatefulWidget {
// // // // // // // // // // //   const CalendarScreen({super.key});

// // // // // // // // // // //   @override
// // // // // // // // // // //   State<CalendarScreen> createState() => _CalendarScreenState();
// // // // // // // // // // // }

// // // // // // // // // // // class _CalendarScreenState extends State<CalendarScreen> {
// // // // // // // // // // //   CalendarFormat _calendarFormat = CalendarFormat.month;
// // // // // // // // // // //   DateTime _focusedDay = DateTime.now();
// // // // // // // // // // //   DateTime? _selectedDay;
// // // // // // // // // // //   List<dynamic> _events = [];
// // // // // // // // // // //   bool _isLoading = true;

// // // // // // // // // // //   @override
// // // // // // // // // // //   void initState() {
// // // // // // // // // // //     super.initState();
// // // // // // // // // // //     _fetchCalendarEvents();
// // // // // // // // // // //   }

// // // // // // // // // // //   Future<void> _fetchCalendarEvents() async {
// // // // // // // // // // //     setState(() => _isLoading = true);
// // // // // // // // // // //     try {
// // // // // // // // // // //       final response = await http.get(Uri.parse('$baseUrl/api/v1/calendar'));
// // // // // // // // // // //       if (response.statusCode == 200) {
// // // // // // // // // // //         final data = jsonDecode(utf8.decode(response.bodyBytes));
// // // // // // // // // // //         setState(() {
// // // // // // // // // // //           _events = data['events'] ?? [];
// // // // // // // // // // //         });
// // // // // // // // // // //       }
// // // // // // // // // // //     } catch (e) {
// // // // // // // // // // //       // 에러 핸들링
// // // // // // // // // // //     } finally {
// // // // // // // // // // //       setState(() => _isLoading = false);
// // // // // // // // // // //     }
// // // // // // // // // // //   }

// // // // // // // // // // //   @override
// // // // // // // // // // //   Widget build(BuildContext context) {
// // // // // // // // // // //     return Scaffold(
// // // // // // // // // // //       appBar: AppBar(
// // // // // // // // // // //         title: const Text('등록된 일정'),
// // // // // // // // // // //         actions: [
// // // // // // // // // // //           IconButton(onPressed: _fetchCalendarEvents, icon: const Icon(Icons.refresh)),
// // // // // // // // // // //         ],
// // // // // // // // // // //       ),
// // // // // // // // // // //       body: _isLoading
// // // // // // // // // // //           ? const Center(child: CircularProgressIndicator())
// // // // // // // // // // //           : Column(
// // // // // // // // // // //               children: [
// // // // // // // // // // //                 TableCalendar(
// // // // // // // // // // //                   firstDay: DateTime.utc(2020, 1, 1),
// // // // // // // // // // //                   lastDay: DateTime.utc(2030, 12, 31),
// // // // // // // // // // //                   focusedDay: _focusedDay,
// // // // // // // // // // //                   calendarFormat: _calendarFormat,
// // // // // // // // // // //                   selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
// // // // // // // // // // //                   onDaySelected: (selectedDay, focusedDay) {
// // // // // // // // // // //                     setState(() {
// // // // // // // // // // //                       _selectedDay = selectedDay;
// // // // // // // // // // //                       _focusedDay = focusedDay;
// // // // // // // // // // //                     });
// // // // // // // // // // //                   },
// // // // // // // // // // //                   onFormatChanged: (format) {
// // // // // // // // // // //                     setState(() => _calendarFormat = format);
// // // // // // // // // // //                   },
// // // // // // // // // // //                 ),
// // // // // // // // // // //                 const Divider(),
// // // // // // // // // // //                 Expanded(
// // // // // // // // // // //                   child: _events.isEmpty
// // // // // // // // // // //                       ? const Center(child: Text('등록된 일정이 없습니다.'))
// // // // // // // // // // //                       : ListView.builder(
// // // // // // // // // // //                           itemCount: _events.length,
// // // // // // // // // // //                           itemBuilder: (context, index) {
// // // // // // // // // // //                             final item = _events[index];
// // // // // // // // // // //                             return ListTile(
// // // // // // // // // // //                               leading: const Icon(Icons.event_note, color: Colors.deepPurple),
// // // // // // // // // // //                               title: Text(item['summary'] ?? '제목 없음'),
// // // // // // // // // // //                               subtitle: Text(item['action_data'] ?? item['category'] ?? ''),
// // // // // // // // // // //                             );
// // // // // // // // // // //                           },
// // // // // // // // // // //                         ),
// // // // // // // // // // //                 ),
// // // // // // // // // // //               ],
// // // // // // // // // // //             ),
// // // // // // // // // // //     );
// // // // // // // // // // //   }
// // // // // // // // // // // }

// // // // // // // // // // // // -------------------------------------------------------------
// // // // // // // // // // // // 3. 히스토리 탭 (/api/v1/history 연동)
// // // // // // // // // // // // -------------------------------------------------------------
// // // // // // // // // // // class HistoryScreen extends StatefulWidget {
// // // // // // // // // // //   const HistoryScreen({super.key});

// // // // // // // // // // //   @override
// // // // // // // // // // //   State<HistoryScreen> createState() => _HistoryScreenState();
// // // // // // // // // // // }

// // // // // // // // // // // class _HistoryScreenState extends State<HistoryScreen> {
// // // // // // // // // // //   List<dynamic> _historyList = [];
// // // // // // // // // // //   bool _isLoading = true;

// // // // // // // // // // //   @override
// // // // // // // // // // //   void initState() {
// // // // // // // // // // //     super.initState();
// // // // // // // // // // //     _fetchHistory();
// // // // // // // // // // //   }

// // // // // // // // // // //   Future<void> _fetchHistory() async {
// // // // // // // // // // //     setState(() => _isLoading = true);
// // // // // // // // // // //     try {
// // // // // // // // // // //       final response = await http.get(Uri.parse('$baseUrl/api/v1/history'));
// // // // // // // // // // //       if (response.statusCode == 200) {
// // // // // // // // // // //         final data = jsonDecode(utf8.decode(response.bodyBytes));
// // // // // // // // // // //         setState(() {
// // // // // // // // // // //           _historyList = data['history'] ?? [];
// // // // // // // // // // //         });
// // // // // // // // // // //       }
// // // // // // // // // // //     } catch (e) {
// // // // // // // // // // //       // 에러 핸들링
// // // // // // // // // // //     } finally {
// // // // // // // // // // //       setState(() => _isLoading = false);
// // // // // // // // // // //     }
// // // // // // // // // // //   }

// // // // // // // // // // //   @override
// // // // // // // // // // //   Widget build(BuildContext context) {
// // // // // // // // // // //     return Scaffold(
// // // // // // // // // // //       appBar: AppBar(
// // // // // // // // // // //         title: const Text('분석 히스토리'),
// // // // // // // // // // //         actions: [
// // // // // // // // // // //           IconButton(onPressed: _fetchHistory, icon: const Icon(Icons.refresh)),
// // // // // // // // // // //         ],
// // // // // // // // // // //       ),
// // // // // // // // // // //       body: _isLoading
// // // // // // // // // // //           ? const Center(child: CircularProgressIndicator())
// // // // // // // // // // //           : _historyList.isEmpty
// // // // // // // // // // //               ? const Center(child: Text('히스토리가 없습니다.'))
// // // // // // // // // // //               : ListView.builder(
// // // // // // // // // // //                   padding: const EdgeInsets.symmetric(vertical: 8),
// // // // // // // // // // //                   itemCount: _historyList.length,
// // // // // // // // // // //                   itemBuilder: (context, index) {
// // // // // // // // // // //                     final item = _historyList[index];
// // // // // // // // // // //                     final actionType = item['action_type'] ?? '';

// // // // // // // // // // //                     return Card(
// // // // // // // // // // //                       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // // // // // // // // // //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // // // // // // // // // //                       elevation: 2,
// // // // // // // // // // //                       child: InkWell(
// // // // // // // // // // //                         borderRadius: BorderRadius.circular(12),
// // // // // // // // // // //                         onTap: () {
// // // // // // // // // // //                           // 상세 페이지로 이동
// // // // // // // // // // //                           Navigator.push(
// // // // // // // // // // //                             context,
// // // // // // // // // // //                             MaterialPageRoute(
// // // // // // // // // // //                               builder: (context) => HistoryDetailScreen(item: item),
// // // // // // // // // // //                             ),
// // // // // // // // // // //                           );
// // // // // // // // // // //                         },
// // // // // // // // // // //                         child: Padding(
// // // // // // // // // // //                           padding: const EdgeInsets.all(12),
// // // // // // // // // // //                           child: Row(
// // // // // // // // // // //                             children: [
// // // // // // // // // // //                               ClipRRect(
// // // // // // // // // // //                                 borderRadius: BorderRadius.circular(8),
// // // // // // // // // // //                                 child: item['image_url'] != null
// // // // // // // // // // //                                     ? Image.network(
// // // // // // // // // // //                                         item['image_url'],
// // // // // // // // // // //                                         width: 65,
// // // // // // // // // // //                                         height: 65,
// // // // // // // // // // //                                         fit: BoxFit.cover,
// // // // // // // // // // //                                         errorBuilder: (context, error, stackTrace) =>
// // // // // // // // // // //                                             Container(width: 65, height: 65, color: Colors.grey.shade300, child: const Icon(Icons.broken_image)),
// // // // // // // // // // //                                       )
// // // // // // // // // // //                                     : Container(width: 65, height: 65, color: Colors.grey.shade300, child: const Icon(Icons.image)),
// // // // // // // // // // //                               ),
// // // // // // // // // // //                               const SizedBox(width: 14),
// // // // // // // // // // //                               Expanded(
// // // // // // // // // // //                                 child: Column(
// // // // // // // // // // //                                   crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // // // //                                   children: [
// // // // // // // // // // //                                     Row(
// // // // // // // // // // //                                       children: [
// // // // // // // // // // //                                         Container(
// // // // // // // // // // //                                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
// // // // // // // // // // //                                           decoration: BoxDecoration(
// // // // // // // // // // //                                             color: Colors.deepPurple.shade50,
// // // // // // // // // // //                                             borderRadius: BorderRadius.circular(6),
// // // // // // // // // // //                                           ),
// // // // // // // // // // //                                           child: Text(
// // // // // // // // // // //                                             item['category'] ?? '미분류',
// // // // // // // // // // //                                             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepPurple),
// // // // // // // // // // //                                           ),
// // // // // // // // // // //                                         ),
// // // // // // // // // // //                                         const Spacer(),
// // // // // // // // // // //                                         // 기능 태그 표시
// // // // // // // // // // //                                         if (actionType.contains('일정') || actionType.contains('캘린더'))
// // // // // // // // // // //                                           const Icon(Icons.calendar_month, size: 18, color: Colors.blueAccent)
// // // // // // // // // // //                                         else if (actionType.contains('지도') || actionType.contains('매핑'))
// // // // // // // // // // //                                           const Icon(Icons.location_on, size: 18, color: Colors.redAccent),
// // // // // // // // // // //                                       ],
// // // // // // // // // // //                                     ),
// // // // // // // // // // //                                     const SizedBox(height: 6),
// // // // // // // // // // //                                     Text(
// // // // // // // // // // //                                       item['summary'] ?? '요약 내용 없음',
// // // // // // // // // // //                                       maxLines: 2,
// // // // // // // // // // //                                       overflow: TextOverflow.ellipsis,
// // // // // // // // // // //                                       style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
// // // // // // // // // // //                                     ),
// // // // // // // // // // //                                   ],
// // // // // // // // // // //                                 ),
// // // // // // // // // // //                               ),
// // // // // // // // // // //                               const Icon(Icons.chevron_right, color: Colors.grey),
// // // // // // // // // // //                             ],
// // // // // // // // // // //                           ),
// // // // // // // // // // //                         ),
// // // // // // // // // // //                       ),
// // // // // // // // // // //                     );
// // // // // // // // // // //                   },
// // // // // // // // // // //                 ),
// // // // // // // // // // //     );
// // // // // // // // // // //   }
// // // // // // // // // // // }

// // // // // // // // // // // // -------------------------------------------------------------
// // // // // // // // // // // // 4. 히스토리 상세 화면 (상세 정보 및 연동 기능 뷰)
// // // // // // // // // // // // -------------------------------------------------------------
// // // // // // // // // // // class HistoryDetailScreen extends StatelessWidget {
// // // // // // // // // // //   final Map<String, dynamic> item;

// // // // // // // // // // //   const HistoryDetailScreen({super.key, required this.item});

// // // // // // // // // // //   @override
// // // // // // // // // // //   Widget build(BuildContext context) {
// // // // // // // // // // //     final actionType = item['action_type'] ?? '해당없음';
// // // // // // // // // // //     final isCalendarAction = actionType.contains('일정') || actionType.contains('캘린더');
// // // // // // // // // // //     final isMapAction = actionType.contains('지도') || actionType.contains('매핑');

// // // // // // // // // // //     return Scaffold(
// // // // // // // // // // //       appBar: AppBar(
// // // // // // // // // // //         title: const Text('분석 상세 정보'),
// // // // // // // // // // //       ),
// // // // // // // // // // //       body: SingleChildScrollView(
// // // // // // // // // // //         padding: const EdgeInsets.all(16),
// // // // // // // // // // //         child: Column(
// // // // // // // // // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // // // //           children: [
// // // // // // // // // // //             // 원본 스크린샷 이미지
// // // // // // // // // // //             if (item['image_url'] != null)
// // // // // // // // // // //               ClipRRect(
// // // // // // // // // // //                 borderRadius: BorderRadius.circular(12),
// // // // // // // // // // //                 child: Image.network(
// // // // // // // // // // //                   item['image_url'],
// // // // // // // // // // //                   width: double.infinity,
// // // // // // // // // // //                   height: 280,
// // // // // // // // // // //                   fit: BoxFit.contain,
// // // // // // // // // // //                   errorBuilder: (context, error, stackTrace) =>
// // // // // // // // // // //                       Container(height: 200, color: Colors.grey.shade200, child: const Center(child: Icon(Icons.broken_image, size: 48))),
// // // // // // // // // // //                 ),
// // // // // // // // // // //               ),
// // // // // // // // // // //             const SizedBox(height: 20),

// // // // // // // // // // //             // 활성화된 기능 안내 배너
// // // // // // // // // // //             if (isCalendarAction)
// // // // // // // // // // //               Container(
// // // // // // // // // // //                 margin: const EdgeInsets.only(bottom: 16),
// // // // // // // // // // //                 padding: const EdgeInsets.all(12),
// // // // // // // // // // //                 decoration: BoxDecoration(
// // // // // // // // // // //                   color: Colors.blue.shade50,
// // // // // // // // // // //                   borderRadius: BorderRadius.circular(8),
// // // // // // // // // // //                   border: Border.all(color: Colors.blue.shade200),
// // // // // // // // // // //                 ),
// // // // // // // // // // //                 child: const Row(
// // // // // // // // // // //                   children: [
// // // // // // // // // // //                     Icon(Icons.event_available, color: Colors.blue),
// // // // // // // // // // //                     SizedBox(width: 8),
// // // // // // // // // // //                     Expanded(
// // // // // // // // // // //                       child: Text(
// // // // // // // // // // //                         '캘린더 일정 자동 등록 기능이 활성화된 항목입니다.',
// // // // // // // // // // //                         style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
// // // // // // // // // // //                       ),
// // // // // // // // // // //                     ),
// // // // // // // // // // //                   ],
// // // // // // // // // // //                 ),
// // // // // // // // // // //               )
// // // // // // // // // // //             else if (isMapAction)
// // // // // // // // // // //               Container(
// // // // // // // // // // //                 margin: const EdgeInsets.only(bottom: 16),
// // // // // // // // // // //                 padding: const EdgeInsets.all(12),
// // // // // // // // // // //                 decoration: BoxDecoration(
// // // // // // // // // // //                   color: Colors.red.shade50,
// // // // // // // // // // //                   borderRadius: BorderRadius.circular(8),
// // // // // // // // // // //                   border: Border.all(color: Colors.red.shade200),
// // // // // // // // // // //                 ),
// // // // // // // // // // //                 child: const Row(
// // // // // // // // // // //                   children: [
// // // // // // // // // // //                     Icon(Icons.pin_drop, color: Colors.redAccent),
// // // // // // // // // // //                     SizedBox(width: 8),
// // // // // // // // // // //                     Expanded(
// // // // // // // // // // //                       child: Text(
// // // // // // // // // // //                         '지도 위치 매핑 기능이 활성화된 항목입니다.',
// // // // // // // // // // //                         style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
// // // // // // // // // // //                       ),
// // // // // // // // // // //                     ),
// // // // // // // // // // //                   ],
// // // // // // // // // // //                 ),
// // // // // // // // // // //               ),

// // // // // // // // // // //             // 요약 정보 카드
// // // // // // // // // // //             Card(
// // // // // // // // // // //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // // // // // // // // // //               child: Padding(
// // // // // // // // // // //                 padding: const EdgeInsets.all(16),
// // // // // // // // // // //                 child: Column(
// // // // // // // // // // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // // // //                   children: [
// // // // // // // // // // //                     _buildInfoRow('카테고리', item['category'] ?? '-'),
// // // // // // // // // // //                     const Divider(height: 24),
// // // // // // // // // // //                     _buildInfoRow('액션 분류', actionType),
// // // // // // // // // // //                     const Divider(height: 24),
// // // // // // // // // // //                     _buildInfoRow('요약 내용', item['summary'] ?? '-'),
// // // // // // // // // // //                     if (item['action_data'] != null && item['action_data'].toString().isNotEmpty) ...[
// // // // // // // // // // //                       const Divider(height: 24),
// // // // // // // // // // //                       _buildInfoRow('참고/액션 데이터', item['action_data'].toString()),
// // // // // // // // // // //                     ],
// // // // // // // // // // //                     if (item['created_at'] != null) ...[
// // // // // // // // // // //                       const Divider(height: 24),
// // // // // // // // // // //                       _buildInfoRow('분석 일시', item['created_at'].toString().split('.')[0].replaceAll('T', ' ')),
// // // // // // // // // // //                     ],
// // // // // // // // // // //                   ],
// // // // // // // // // // //                 ),
// // // // // // // // // // //               ),
// // // // // // // // // // //             ),
// // // // // // // // // // //           ],
// // // // // // // // // // //         ),
// // // // // // // // // // //       ),
// // // // // // // // // // //     );
// // // // // // // // // // //   }

// // // // // // // // // // //   Widget _buildInfoRow(String label, String value) {
// // // // // // // // // // //     return Column(
// // // // // // // // // // //       crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // // // // // //       children: [
// // // // // // // // // // //         Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
// // // // // // // // // // //         const SizedBox(height: 4),
// // // // // // // // // // //         Text(value, style: const TextStyle(fontSize: 15, height: 1.4)),
// // // // // // // // // // //       ],
// // // // // // // // // // //     );
// // // // // // // // // // //   }
// // // // // // // // // // // }

// // // // // // // // // // // // // -------------------------------------------------------------
// // // // // // // // // // // // // 3. 히스토리 탭 (/api/v1/history 연동)
// // // // // // // // // // // // // -------------------------------------------------------------
// // // // // // // // // // // // class HistoryScreen extends StatefulWidget {
// // // // // // // // // // // //   const HistoryScreen({super.key});

// // // // // // // // // // // //   @override
// // // // // // // // // // // //   State<HistoryScreen> createState() => _HistoryScreenState();
// // // // // // // // // // // // }

// // // // // // // // // // // // class _HistoryScreenState extends State<HistoryScreen> {
// // // // // // // // // // // //   List<dynamic> _historyList = [];
// // // // // // // // // // // //   bool _isLoading = true;

// // // // // // // // // // // //   @override
// // // // // // // // // // // //   void initState() {
// // // // // // // // // // // //     super.initState();
// // // // // // // // // // // //     _fetchHistory();
// // // // // // // // // // // //   }

// // // // // // // // // // // //   Future<void> _fetchHistory() async {
// // // // // // // // // // // //     setState(() => _isLoading = true);
// // // // // // // // // // // //     try {
// // // // // // // // // // // //       final response = await http.get(Uri.parse('$baseUrl/api/v1/history'));
// // // // // // // // // // // //       if (response.statusCode == 200) {
// // // // // // // // // // // //         final data = jsonDecode(utf8.decode(response.bodyBytes));
// // // // // // // // // // // //         setState(() {
// // // // // // // // // // // //           _historyList = data['history'] ?? [];
// // // // // // // // // // // //         });
// // // // // // // // // // // //       }
// // // // // // // // // // // //     } catch (e) {
// // // // // // // // // // // //       // 에러 핸들링
// // // // // // // // // // // //     } finally {
// // // // // // // // // // // //       setState(() => _isLoading = false);
// // // // // // // // // // // //     }
// // // // // // // // // // // //   }

// // // // // // // // // // // //   @override
// // // // // // // // // // // //   Widget build(BuildContext context) {
// // // // // // // // // // // //     return Scaffold(
// // // // // // // // // // // //       appBar: AppBar(
// // // // // // // // // // // //         title: const Text('분석 히스토리'),
// // // // // // // // // // // //         actions: [
// // // // // // // // // // // //           IconButton(onPressed: _fetchHistory, icon: const Icon(Icons.refresh)),
// // // // // // // // // // // //         ],
// // // // // // // // // // // //       ),
// // // // // // // // // // // //       body: _isLoading
// // // // // // // // // // // //           ? const Center(child: CircularProgressIndicator())
// // // // // // // // // // // //           : _historyList.isEmpty
// // // // // // // // // // // //               ? const Center(child: Text('히스토리가 없습니다.'))
// // // // // // // // // // // //               : ListView.builder(
// // // // // // // // // // // //                   itemCount: _historyList.length,
// // // // // // // // // // // //                   itemBuilder: (context, index) {
// // // // // // // // // // // //                     final item = _historyList[index];
// // // // // // // // // // // //                     return Card(
// // // // // // // // // // // //                       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // // // // // // // // // // //                       child: ListTile(
// // // // // // // // // // // //                         leading: item['image_url'] != null
// // // // // // // // // // // //                             ? ClipRRect(
// // // // // // // // // // // //                                 borderRadius: BorderRadius.circular(8),
// // // // // // // // // // // //                                 child: Image.network(
// // // // // // // // // // // //                                   item['image_url'],
// // // // // // // // // // // //                                   width: 50,
// // // // // // // // // // // //                                   height: 50,
// // // // // // // // // // // //                                   fit: BoxFit.cover,
// // // // // // // // // // // //                                 ),
// // // // // // // // // // // //                               )
// // // // // // // // // // // //                             : const Icon(Icons.image),
// // // // // // // // // // // //                         title: Text(item['summary'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
// // // // // // // // // // // //                         subtitle: Text('[${item['category']}] ${item['action_type']}'),
// // // // // // // // // // // //                       ),
// // // // // // // // // // // //                     );
// // // // // // // // // // // //                   },
// // // // // // // // // // // //                 ),
// // // // // // // // // // // //     );
// // // // // // // // // // // //   }
// // // // // // // // // // // // }

// // // // // // // // // // // // // import 'package:flutter/material.dart';

// // // // // // // // // // // // // void main() {
// // // // // // // // // // // // //   runApp(const MyApp());
// // // // // // // // // // // // // }

// // // // // // // // // // // // // class MyApp extends StatelessWidget {
// // // // // // // // // // // // //   const MyApp({super.key});

// // // // // // // // // // // // //   // This widget is the root of your application.
// // // // // // // // // // // // //   @override
// // // // // // // // // // // // //   Widget build(BuildContext context) {
// // // // // // // // // // // // //     return MaterialApp(
// // // // // // // // // // // // //       title: 'Flutter Demo',
// // // // // // // // // // // // //       theme: ThemeData(
// // // // // // // // // // // // //         // This is the theme of your application.
// // // // // // // // // // // // //         //
// // // // // // // // // // // // //         // TRY THIS: Try running your application with "flutter run". You'll see
// // // // // // // // // // // // //         // the application has a purple toolbar. Then, without quitting the app,
// // // // // // // // // // // // //         // try changing the seedColor in the colorScheme below to Colors.green
// // // // // // // // // // // // //         // and then invoke "hot reload" (save your changes or press the "hot
// // // // // // // // // // // // //         // reload" button in a Flutter-supported IDE, or press "r" if you used
// // // // // // // // // // // // //         // the command line to start the app).
// // // // // // // // // // // // //         //
// // // // // // // // // // // // //         // Notice that the counter didn't reset back to zero; the application
// // // // // // // // // // // // //         // state is not lost during the reload. To reset the state, use hot
// // // // // // // // // // // // //         // restart instead.
// // // // // // // // // // // // //         //
// // // // // // // // // // // // //         // This works for code too, not just values: Most code changes can be
// // // // // // // // // // // // //         // tested with just a hot reload.
// // // // // // // // // // // // //         colorScheme: .fromSeed(seedColor: Colors.deepPurple),
// // // // // // // // // // // // //       ),
// // // // // // // // // // // // //       home: const MyHomePage(title: 'Flutter Demo Home Page'),
// // // // // // // // // // // // //     );
// // // // // // // // // // // // //   }
// // // // // // // // // // // // // }

// // // // // // // // // // // // // class MyHomePage extends StatefulWidget {
// // // // // // // // // // // // //   const MyHomePage({super.key, required this.title});

// // // // // // // // // // // // //   // This widget is the home page of your application. It is stateful, meaning
// // // // // // // // // // // // //   // that it has a State object (defined below) that contains fields that affect
// // // // // // // // // // // // //   // how it looks.

// // // // // // // // // // // // //   // This class is the configuration for the state. It holds the values (in this
// // // // // // // // // // // // //   // case the title) provided by the parent (in this case the App widget) and
// // // // // // // // // // // // //   // used by the build method of the State. Fields in a Widget subclass are
// // // // // // // // // // // // //   // always marked "final".

// // // // // // // // // // // // //   final String title;

// // // // // // // // // // // // //   @override
// // // // // // // // // // // // //   State<MyHomePage> createState() => _MyHomePageState();
// // // // // // // // // // // // // }

// // // // // // // // // // // // // class _MyHomePageState extends State<MyHomePage> {
// // // // // // // // // // // // //   int _counter = 0;

// // // // // // // // // // // // //   void _incrementCounter() {
// // // // // // // // // // // // //     setState(() {
// // // // // // // // // // // // //       // This call to setState tells the Flutter framework that something has
// // // // // // // // // // // // //       // changed in this State, which causes it to rerun the build method below
// // // // // // // // // // // // //       // so that the display can reflect the updated values. If we changed
// // // // // // // // // // // // //       // _counter without calling setState(), then the build method would not be
// // // // // // // // // // // // //       // called again, and so nothing would appear to happen.
// // // // // // // // // // // // //       _counter++;
// // // // // // // // // // // // //     });
// // // // // // // // // // // // //   }

// // // // // // // // // // // // //   @override
// // // // // // // // // // // // //   Widget build(BuildContext context) {
// // // // // // // // // // // // //     // This method is rerun every time setState is called, for instance as done
// // // // // // // // // // // // //     // by the _incrementCounter method above.
// // // // // // // // // // // // //     //
// // // // // // // // // // // // //     // The Flutter framework has been optimized to make rerunning build methods
// // // // // // // // // // // // //     // fast, so that you can just rebuild anything that needs updating rather
// // // // // // // // // // // // //     // than having to individually change instances of widgets.
// // // // // // // // // // // // //     return Scaffold(
// // // // // // // // // // // // //       appBar: AppBar(
// // // // // // // // // // // // //         // TRY THIS: Try changing the color here to a specific color (to
// // // // // // // // // // // // //         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
// // // // // // // // // // // // //         // change color while the other colors stay the same.
// // // // // // // // // // // // //         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
// // // // // // // // // // // // //         // Here we take the value from the MyHomePage object that was created by
// // // // // // // // // // // // //         // the App.build method, and use it to set our appbar title.
// // // // // // // // // // // // //         title: Text(widget.title),
// // // // // // // // // // // // //       ),
// // // // // // // // // // // // //       body: Center(
// // // // // // // // // // // // //         // Center is a layout widget. It takes a single child and positions it
// // // // // // // // // // // // //         // in the middle of the parent.
// // // // // // // // // // // // //         child: Column(
// // // // // // // // // // // // //           // Column is also a layout widget. It takes a list of children and
// // // // // // // // // // // // //           // arranges them vertically. By default, it sizes itself to fit its
// // // // // // // // // // // // //           // children horizontally, and tries to be as tall as its parent.
// // // // // // // // // // // // //           //
// // // // // // // // // // // // //           // Column has various properties to control how it sizes itself and
// // // // // // // // // // // // //           // how it positions its children. Here we use mainAxisAlignment to
// // // // // // // // // // // // //           // center the children vertically; the main axis here is the vertical
// // // // // // // // // // // // //           // axis because Columns are vertical (the cross axis would be
// // // // // // // // // // // // //           // horizontal).
// // // // // // // // // // // // //           //
// // // // // // // // // // // // //           // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
// // // // // // // // // // // // //           // action in the IDE, or press "p" in the console), to see the
// // // // // // // // // // // // //           // wireframe for each widget.
// // // // // // // // // // // // //           mainAxisAlignment: .center,
// // // // // // // // // // // // //           children: [
// // // // // // // // // // // // //             const Text('You have pushed the button this many times:'),
// // // // // // // // // // // // //             Text(
// // // // // // // // // // // // //               '$_counter',
// // // // // // // // // // // // //               style: Theme.of(context).textTheme.headlineMedium,
// // // // // // // // // // // // //             ),
// // // // // // // // // // // // //           ],
// // // // // // // // // // // // //         ),
// // // // // // // // // // // // //       ),
// // // // // // // // // // // // //       floatingActionButton: FloatingActionButton(
// // // // // // // // // // // // //         onPressed: _incrementCounter,
// // // // // // // // // // // // //         tooltip: 'Increment',
// // // // // // // // // // // // //         child: const Icon(Icons.add),
// // // // // // // // // // // // //       ),
// // // // // // // // // // // // //     );
// // // // // // // // // // // // //   }
// // // // // // // // // // // // // }
