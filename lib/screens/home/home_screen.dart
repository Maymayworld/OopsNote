// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:misslog/themes/app_theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:misslog/screens/record/record_sheet.dart';
import 'package:misslog/screens/mistake/widgets/mistake_tile_widget.dart';
import 'package:misslog/screens/mistake/mistake_detail_sheet.dart';
import 'package:misslog/services/miss_data_service.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayMissCount = useState<int>(0);
    final totalMissCount = useState<int>(0);
    final recentMistakes = useState<List<Map<String, dynamic>>>([]);
    final allMistakes = useState<List<Map<String, dynamic>>>([]);
    final isLoading = useState<bool>(true);

    // データを読み込む関数
    Future<void> loadMissData() async {
      try {
        final allData = await MissDataService.getMissDataList();
        
        // 今日の日付
        final today = DateTime.now();
        final todayStart = DateTime(today.year, today.month, today.day);
        final todayEnd = todayStart.add(Duration(days: 1));
        
        // 今日のミス数をカウント
        int todayCount = 0;
        for (var data in allData) {
          DateTime mistakeDate = DateTime.parse(data['date']);
          if (mistakeDate.isAfter(todayStart) && mistakeDate.isBefore(todayEnd)) {
            todayCount++;
          }
        }
        
        // 累計ミス数
        int totalCount = allData.length;
        
        // 最新3件のミスを取得（日付順）
        allData.sort((a, b) => 
          DateTime.parse(b['date']).compareTo(DateTime.parse(a['date']))
        );
        List<Map<String, dynamic>> recent = allData.take(3).toList();
        
        todayMissCount.value = todayCount;
        totalMissCount.value = totalCount;
        recentMistakes.value = recent;
        allMistakes.value = allData;
        isLoading.value = false;
      } catch (e) {
        print('データの読み込みに失敗しました: $e');
        isLoading.value = false;
      }
    }

    // 初期データ読み込み
    useEffect(() {
      loadMissData();
      return null;
    }, []);

    // 詳細画面を表示
    void showDetailSheet(Map<String, dynamic> data) {
      // 元のインデックスを取得
      final originalIndex = allMistakes.value.indexOf(data);
      
      if (originalIndex != -1) {
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
              mistakeIndex: originalIndex,
              onDataUpdated: () {
                // データ更新後にホーム画面のデータも再読み込み
                loadMissData();
              },
            );
          },
        );
      }
    }

    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        title: Text('OopsNote'),
        titleTextStyle: TextStyle(
          color: primaryBlue,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        color: primaryBlue,
        onRefresh: loadMissData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 24),

              // 統計表示カード
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    // 今日のミス数カード
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '今日のミス',
                              style: TextStyle(
                                fontSize: 14,
                                color: textSecondaryGray,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            isLoading.value
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: primaryBlue,
                                  ),
                                )
                              : Text(
                                  '${todayMissCount.value}',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: primaryBlue,
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(width: 16),
                    
                    // 累計ミス数カード
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '累計ミス',
                              style: TextStyle(
                                fontSize: 14,
                                color: textSecondaryGray,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            isLoading.value
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: primaryBlue,
                                  ),
                                )
                              : Text(
                                  '${totalMissCount.value}',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: primaryBlue,
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // 直近のミス3件
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    '最近のミス',
                    style: TextStyle(
                      color: textPrimaryGrey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ),
              ),
              
              SizedBox(height: 16),
              
              // 最近のミス一覧
              isLoading.value
                ? Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: primaryBlue,
                      ),
                    ),
                  )
                : recentMistakes.value.isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.sentiment_very_satisfied,
                              size: 48,
                              color: textSecondaryGray,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'まだミスが記録されていません',
                              style: TextStyle(
                                color: textSecondaryGray,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: recentMistakes.value
                          .map<Widget>((mistake) => Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: MistakeTileWidget(
                                  mistakeData: mistake,
                                  onTap: () => showDetailSheet(mistake),
                                ),
                              ))
                          .toList(),
                      ),
                    ),
              
              SizedBox(height: 24),
              // FABのための余白を確保
              SizedBox(height: 80),
            ]
          ),
        ),
      ),
      // 右下固定のFAB
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            backgroundColor: backgroundGray,
            builder: (context) {
              return RecordSheet();
            },
          ).then((_) {
            // モーダルが閉じられた後にデータを再読み込み
            loadMissData();
          });
        },
        label: Text(
          '新しくミスを記録',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}