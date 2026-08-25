import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/constants.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedImage;
  bool _isLoading = false;
  Map<String, dynamic>? _analysisResult;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      maxWidth: null,
      maxHeight: null,
    );
    if (pickedFile == null) return;

    if (!mounted) return;
    setState(() {
      _selectedImage = File(pickedFile.path);
      _isLoading = true;
      _analysisResult = null;
    });

    try {
      final uri = Uri.parse('$baseUrl/api/v1/analyze');
      final request = http.MultipartRequest('POST', uri);

      final ext = pickedFile.path.split('.').last.toLowerCase();
      final mimeType = (ext == 'png') ? 'image/png' : 'image/jpeg';

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        pickedFile.path,
        contentType: MediaType.parse(mimeType),
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            _analysisResult = decoded['analysis'];
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('분석 및 저장이 완료되었습니다!')),
          );
        }
      } else {
        throw Exception('서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('업로드 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('스크린샷 분석')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_selectedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_selectedImage!, height: 260, fit: BoxFit.cover),
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text('분석할 스크린샷을 선택하세요')),
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickAndUploadImage,
              icon: const Icon(Icons.photo_library),
              label: Text(_isLoading ? '분석 중...' : '갤러리에서 선택 및 분석'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_analysisResult != null) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('분석 결과', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('카테고리: ${_analysisResult?['category'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('액션 타입: ${_analysisResult?['action_type'] ?? '-'}'),
                      const SizedBox(height: 6),
                      Text('요약: ${_analysisResult?['summary'] ?? '-'}'),
                      if (_analysisResult?['action_data'] != null && _analysisResult?['action_data'] != "") ...[
                        const SizedBox(height: 6),
                        Text('상세: ${_analysisResult?['action_data']}'),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}