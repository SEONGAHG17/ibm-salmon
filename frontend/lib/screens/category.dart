import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/constants.dart';
import 'detail.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<dynamic> _allHistory = [];
  List<dynamic> _filteredList = [];
  Set<String> _categories = {'전체'};
  String _selectedCategory = '전체';
  String _searchQuery = '';
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchHistoryData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchHistoryData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final response = await http.get(Uri.parse('$baseUrl/api/v1/history/'));
      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> history = data['history'] ?? [];

        // 고유 카테고리 추출
        final Set<String> categories = {'전체'};
        for (var item in history) {
          final cat = item['category']?.toString().trim();
          if (cat != null && cat.isNotEmpty) {
            categories.add(cat);
          }
        }

        setState(() {
          _allHistory = history;
          _categories = categories;
          _applyFilter();
        });
      }
    } catch (e) {
      debugPrint("❌ [카테고리 데이터 조회 실패]: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredList = _allHistory.where((item) {
        final category = item['category']?.toString() ?? '';
        final summary = item['summary']?.toString().toLowerCase() ?? '';
        final actionData = item['action_data']?.toString().toLowerCase() ?? '';
        final actionType = item['action_type']?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();

        // 카테고리 칩 필터링
        final matchesCategory = (_selectedCategory == '전체') || (category == _selectedCategory);

        // 검색어(키워드) 필터링
        final matchesQuery = query.isEmpty ||
            summary.contains(query) ||
            actionData.contains(query) ||
            actionType.contains(query) ||
            category.toLowerCase().contains(query);

        return matchesCategory && matchesQuery;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('키워드 / 카테고리 분류'),
        actions: [
          IconButton(
            onPressed: _fetchHistoryData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 1. 검색창 (키워드 실시간 검색)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '키워드나 내용으로 검색...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _applyFilter();
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      _searchQuery = value;
                      _applyFilter();
                    },
                  ),
                ),

                // 2. 카테고리 칩 목록
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          selectedColor: Colors.deepPurple,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategory = category;
                                _applyFilter();
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const Divider(height: 16),

                // 3. 필터링된 분석 결과 카드 목록
                Expanded(
                  child: _filteredList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.category_outlined, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                '해당 키워드/카테고리의 분석 결과가 없습니다.',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: _filteredList.length,
                          itemBuilder: (context, index) {
                            final item = _filteredList[index];
                            final actionType = item['action_type'] ?? '';

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 1.5,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HistoryDetailScreen(item: item),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: item['image_url'] != null
                                            ? Image.network(
                                                item['image_url'],
                                                width: 70,
                                                height: 70,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => Container(
                                                  width: 70,
                                                  height: 70,
                                                  color: Colors.grey.shade300,
                                                  child: const Icon(Icons.broken_image),
                                                ),
                                              )
                                            : Container(
                                                width: 70,
                                                height: 70,
                                                color: Colors.grey.shade300,
                                                child: const Icon(Icons.image),
                                              ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.deepPurple.shade50,
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    item['category'] ?? '미분류',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.deepPurple,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  actionType,
                                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              item['summary'] ?? '요약 내용 없음',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                            ),
                                            if (item['action_data'] != null && item['action_data'].toString().isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                item['action_data'].toString(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right, color: Colors.grey),
                                    ],
                                  ),
                                ),
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