// lib/screens/mistake/mistake_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:misslog/screens/mistake/widgets/mistake_tile_widget.dart';
import 'package:misslog/screens/mistake/mistake_detail_sheet.dart';
import 'package:misslog/services/miss_data_service.dart';
import 'package:misslog/themes/app_theme.dart';

class MistakeListScreen extends HookConsumerWidget {
  const MistakeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final selectedCategory = useState<String>('全て');
    final mistakeData = useState<List<Map<String, dynamic>>>([]);
    final filteredData = useState<List<Map<String, dynamic>>>([]);
    final isLoading = useState<bool>(true);

    // カテゴリーフィルターのオプション
    final categoryOptions = [
      '全て',
      '計算',
      '読解', 
      '論理',
      '公式',
      '表記',
      '戦略',
      'その他'
    ];

    // データを読み込む関数
    Future<void> loadData() async {
      try {
        isLoading.value = true;
        final data = await MissDataService.getMissDataList();
        // 日付順でソート（新しい順）
        data.sort((a, b) => 
          DateTime.parse(b['date']).compareTo(DateTime.parse(a['date']))
        );
        mistakeData.value = data;
        filteredData.value = data;
        isLoading.value = false;
      } catch (e) {
        print('データの読み込みに失敗しました: $e');
        isLoading.value = false;
      }
    }

    // 初回データ読み込み
    useEffect(() {
      loadData();
      return null;
    }, []);

    // フィルタリング処理
    void filterData() {
      String searchText = searchController.text.toLowerCase();
      String category = selectedCategory.value;
      
      List<Map<String, dynamic>> filtered = mistakeData.value.where((item) {
        // 検索テキストでのフィルタリング
        bool matchesSearch = searchText.isEmpty || 
          item['name'].toString().toLowerCase().contains(searchText) ||
          (item['reason']?.toString().toLowerCase().contains(searchText) ?? false) ||
          (item['improvement']?.toString().toLowerCase().contains(searchText) ?? false);
        
        // カテゴリーでのフィルタリング
        bool matchesCategory = category == '全て' || 
          (item['tags'] as List<dynamic>).contains(category);
        
        return matchesSearch && matchesCategory;
      }).toList();
      
      filteredData.value = filtered;
    }

    // 検索テキストの変更を監視
    useEffect(() {
      void listener() {
        filterData();
      }
      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    // カテゴリー変更時のフィルタリング
    useEffect(() {
      filterData();
      return null;
    }, [selectedCategory.value]);

    // 詳細画面を表示
    void showDetailSheet(Map<String, dynamic> data) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        backgroundColor: backgroundGray,
        builder: (context) {
          return MistakeDetailSheet(
            mistakeData: data,
            onDataUpdated: () {
              // データ更新後にリストを再読み込み
              loadData();
            },
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: backgroundGray,
      body: Column(
        children: [
          // 検索バー
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              cursorColor: primaryBlue,
              decoration: InputDecoration(
                hintText: 'ミス名や内容で検索...',
                hintStyle: TextStyle(
                  color: textSecondaryGray.withOpacity(0.7),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: textSecondaryGray,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: textSecondaryGray,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: primaryBlue,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          // フィルター選択欄
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categoryOptions.length,
              itemBuilder: (context, index) {
                final category = categoryOptions[index];
                final isSelected = selectedCategory.value == category;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      selectedCategory.value = category;
                    },
                    selectedColor: primaryBlue.withOpacity(0.1),
                    backgroundColor: Colors.transparent,
                    disabledColor: Colors.transparent,
                    checkmarkColor: primaryBlue,
                    labelStyle: TextStyle(
                      color: isSelected ? primaryBlue : textPrimaryGrey,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? primaryBlue : textSecondaryGray,
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 8),
          
          // ミス件数表示
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${filteredData.value.length}件のミス',
                style: TextStyle(
                  color: textSecondaryGray,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // ミスリスト
          Expanded(
            child: isLoading.value
              ? Center(
                  child: CircularProgressIndicator(
                    color: primaryBlue,
                  ),
                )
              : filteredData.value.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: textSecondaryGray,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchController.text.isNotEmpty || selectedCategory.value != '全て'
                            ? '条件に合うミスが見つかりません'
                            : 'まだミスが記録されていません',
                          style: TextStyle(
                            color: textSecondaryGray,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredData.value.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final mistake = filteredData.value[index];
                      
                      return MistakeTileWidget(
                        mistakeData: mistake,
                        onTap: () => showDetailSheet(mistake),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}