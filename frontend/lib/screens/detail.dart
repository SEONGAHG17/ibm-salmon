import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HistoryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  const HistoryDetailScreen({super.key, required this.item});

  Future<void> _openNaverMap(String addressQuery) async {
    final query = addressQuery.trim();
    if (query.isEmpty) return;

    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse('https://m.map.naver.com/search2/search.naver?query=$encodedQuery');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openBrowserUrl(String rawUrl) async {
    var cleanUrl = rawUrl.trim();
    if (cleanUrl.isEmpty) return;

    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      cleanUrl = 'https://$cleanUrl';
    }

    final url = Uri.parse(cleanUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  String _resolveSearchTarget() {
    final actionData = item['action_data']?.toString().trim() ?? '';
    if (actionData.isNotEmpty) return actionData;

    if (item['places'] is List && (item['places'] as List).isNotEmpty) {
      final firstPlace = item['places'][0];
      if (firstPlace is Map) {
        final address = firstPlace['address']?.toString().trim() ?? '';
        if (address.isNotEmpty) return address;

        final placeName = firstPlace['place_name']?.toString().trim() ?? '';
        if (placeName.isNotEmpty) return placeName;
      }
    }

    return item['summary']?.toString().trim() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final actionType = item['action_type'] ?? '해당없음';
    final isCalendarAction = actionType.contains('일정') || actionType.contains('캘린더');
    final isMapAction = actionType.contains('지도') || actionType.contains('매핑');
    final isLinkAction = actionType.contains('링크') || actionType.contains('웹');

    final searchTarget = _resolveSearchTarget();
    final rawActionData = item['action_data']?.toString().trim() ?? '';
    final isUrl = isLinkAction ||
        searchTarget.startsWith('http://') ||
        searchTarget.startsWith('https://') ||
        searchTarget.contains('.com') ||
        searchTarget.contains('.kr');

    return Scaffold(
      appBar: AppBar(title: const Text('분석 상세 정보')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['image_url'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item['image_url'],
                  width: double.infinity,
                  height: 260,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: Colors.grey.shade200,
                    child: const Center(child: Icon(Icons.broken_image, size: 48)),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (isMapAction && !isUrl)
              Card(
                color: Colors.green.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.green.shade200),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            '지도 검색 위치 (도로명 주소/상호명)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        searchTarget.isNotEmpty ? searchTarget : '등록된 주소 정보가 없습니다.',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: searchTarget.isNotEmpty ? () => _openNaverMap(searchTarget) : null,
                        icon: const Icon(Icons.map_outlined, color: Colors.white),
                        label: const Text('네이버 지도에서 위치 확인', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF03C75A)),
                      ),
                    ],
                  ),
                ),
              ),
            if (isCalendarAction)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.event_available, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('캘린더 일정으로 등록된 항목입니다.', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('카테고리', item['category'] ?? '-'),
                    const Divider(height: 24),
                    _buildInfoRow('액션 분류', actionType),
                    const Divider(height: 24),
                    _buildInfoRow('요약 내용', item['summary'] ?? '-'),
                    if (searchTarget.isNotEmpty) ...[
                      const Divider(height: 24),
                      if (actionType.contains('링크') || searchTarget.startsWith('http'))
                        _buildHyperlinkRow('바로가기 링크', searchTarget, () => _openBrowserUrl(searchTarget))
                      else
                        _buildInfoRow('검색 주소 / 장소', searchTarget),
                    ] else if (rawActionData.isNotEmpty) ...[
                      const Divider(height: 24),
                      if (rawActionData.startsWith('http'))
                        _buildHyperlinkRow('바로가기 링크', rawActionData, () => _openBrowserUrl(rawActionData))
                      else
                        _buildInfoRow('상세 데이터', rawActionData),
                    ],
                    if (item['created_at'] != null) ...[
                      const Divider(height: 24),
                      _buildInfoRow('분석 일시', item['created_at'].toString().split('.')[0].replaceAll('T', ' ')),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 15, height: 1.4)),
      ],
    );
  }

  Widget _buildHyperlinkRow(String label, String urlText, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    urlText,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blueAccent,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.open_in_new, size: 16, color: Colors.blueAccent),
              ],
            ),
          ),
        ),
      ],
    );
  }
}