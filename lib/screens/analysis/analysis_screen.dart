// lib/screens/analysis/analysis_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:misslog/services/miss_data_service.dart';
import 'package:misslog/themes/app_theme.dart';

class AnalysisScreen extends HookConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPeriod = useState<int>(1); // 1=1週間, 2=1ヶ月, 3=3ヶ月, 4=6ヶ月, 5=1年
    final analysisData = useState<Map<String, dynamic>>({});
    final isLoading = useState<bool>(true);

    // 期間オプション
    final periodOptions = [
      {'label': '1週間', 'days': 7},
      {'label': '1ヶ月', 'days': 30},
      {'label': '3ヶ月', 'days': 90},
      {'label': '6ヶ月', 'days': 180},
      {'label': '1年', 'days': 365},
    ];

    // データ分析関数
    Future<void> analyzeData() async {
      isLoading.value = true;
      try {
        final allData = await MissDataService.getMissDataList();
        final days = periodOptions[selectedPeriod.value - 1]['days'] as int;
        final cutoffDate = DateTime.now().subtract(Duration(days: days));
        
        // 期間内のデータをフィルタリング
        final periodData = allData.where((data) {
          DateTime mistakeDate = DateTime.parse(data['date']);
          return mistakeDate.isAfter(cutoffDate);
        }).toList();

        // カテゴリー分析
        Map<String, int> categoryCount = {};
        for (var data in periodData) {
          List<dynamic> tags = data['tags'] ?? [];
          for (var tag in tags) {
            categoryCount[tag.toString()] = (categoryCount[tag.toString()] ?? 0) + 1;
          }
        }

        // コンディション分析
        Map<int, int> conditionCount = {};
        for (var data in periodData) {
          int condition = data['condition'] ?? 0;
          if (condition >= 1 && condition <= 7) {
            conditionCount[condition] = (conditionCount[condition] ?? 0) + 1;
          }
        }

        // 日別ミス数の推移（折れ線グラフ用）
        Map<DateTime, int> dailyMistakes = {};
        for (var data in periodData) {
          DateTime mistakeDate = DateTime.parse(data['date']);
          DateTime dayOnly = DateTime(mistakeDate.year, mistakeDate.month, mistakeDate.day);
          dailyMistakes[dayOnly] = (dailyMistakes[dayOnly] ?? 0) + 1;
        }

        // 総合フィードバック生成
        String feedback = _generateFeedback(periodData, categoryCount, conditionCount, days);

        analysisData.value = {
          'totalMistakes': periodData.length,
          'categoryCount': categoryCount,
          'conditionCount': conditionCount,
          'dailyMistakes': dailyMistakes,
          'feedback': feedback,
        };
      } catch (e) {
        print('分析データの取得に失敗しました: $e');
      }
      isLoading.value = false;
    }

    // 初期データ読み込み
    useEffect(() {
      analyzeData();
      return null;
    }, []);

    // 期間変更時の再分析
    useEffect(() {
      analyzeData();
      return null;
    }, [selectedPeriod.value]);

    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        title: Text('分析'),
        titleTextStyle: TextStyle(
          color: primaryBlue,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: isLoading.value
        ? Center(
            child: CircularProgressIndicator(color: primaryBlue),
          )
        : SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 期間選択UI（SegmentedControl風）
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardGrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '分析期間',
                        style: TextStyle(
                          color: textPrimaryGrey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: backgroundGray,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: textSecondaryGray.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: periodOptions.asMap().entries.map((entry) {
                            int index = entry.key;
                            Map<String, dynamic> option = entry.value;
                            bool isSelected = selectedPeriod.value == index + 1;
                            
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  selectedPeriod.value = index + 1;
                                },
                                child: Container(
                                  margin: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: isSelected ? primaryBlue : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Text(
                                      option['label'] as String,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : textPrimaryGrey,
                                        fontSize: 14,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // 総合フィードバック文
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardGrey,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '総合フィードバック',
                        style: TextStyle(
                          color: textPrimaryGrey,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        analysisData.value['feedback'] ?? '',
                        style: TextStyle(
                          color: textPrimaryGrey,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // ミスの種類分析レーダーチャート
                _buildCategoryRadarChart(analysisData.value['categoryCount'] ?? {}),

                SizedBox(height: 24),

                // コンディション分析円グラフ（詳細表示）
                _buildDetailedConditionPieChart(
                  Map<int, int>.from(analysisData.value['conditionCount'] ?? {})
                ),

                SizedBox(height: 24),

                // 折れ線グラフ
                _buildLineChart(
                  analysisData.value['dailyMistakes'] ?? {},
                  periodOptions[selectedPeriod.value - 1]['days'] as int,
                ),
              ],
            ),
          ),
    );
  }

  // 総合フィードバック生成
  String _generateFeedback(
    List<Map<String, dynamic>> periodData,
    Map<String, int> categoryCount,
    Map<int, int> conditionCount,
    int days,
  ) {
    if (periodData.isEmpty) {
      return '${days}日間でミスは記録されていません。素晴らしい調子を保てています！';
    }

    String period = days == 7 ? '1週間' : days == 30 ? '1ヶ月' : days == 90 ? '3ヶ月' : days == 180 ? '6ヶ月' : '1年';
    int totalMistakes = periodData.length;
    double averagePerDay = totalMistakes / days;

    String feedback = '${period}で${totalMistakes}件のミスが記録されました（1日平均${averagePerDay.toStringAsFixed(1)}件）。\n\n';

    // 最も多いカテゴリー
    if (categoryCount.isNotEmpty) {
      var sortedCategories = categoryCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      feedback += '最も多いミスの種類は「${sortedCategories.first.key}」です。';
      if (sortedCategories.first.value > totalMistakes * 0.4) {
        feedback += 'このカテゴリーに特に注意を向けることで改善が期待できます。\n\n';
      } else {
        feedback += '\n\n';
      }
    }

    // コンディション分析
    int badConditionCount = (conditionCount[1] ?? 0) + (conditionCount[2] ?? 0) + (conditionCount[3] ?? 0);
    int totalWithCondition = conditionCount.values.fold(0, (a, b) => a + b);
    if (totalWithCondition > 0) {
      double badConditionRate = badConditionCount / totalWithCondition;
      if (badConditionRate > 0.5) {
        feedback += '調子が悪い時のミスが多い傾向があります。体調管理にも注意を向けてみてください。';
      } else if (badConditionRate < 0.2) {
        feedback += '調子が良い時でもミスが発生しています。集中力や手順の見直しを検討してみてください。';
      } else {
        feedback += 'コンディションとミスの関係は適度なバランスです。';
      }
    }

    return feedback;
  }

  // カテゴリーレーダーチャート
  Widget _buildCategoryRadarChart(Map<String, int> categoryCount) {
    if (categoryCount.isEmpty) {
      return _buildEmptyChart('苦手分野分析', 'データなし');
    }

    // 固定のカテゴリーリスト（レーダーチャートの軸）
    final categories = ['計算', '読解', '論理', '公式', '表記', '戦略', 'その他'];
    final totalCount = categoryCount.values.fold(0, (a, b) => a + b);

    // レーダーチャート用のデータポイント作成（パーセンテージベース）
    List<RadarDataSet> dataSets = [
      RadarDataSet(
        dataEntries: categories.map((category) {
          int count = categoryCount[category] ?? 0;
          double percentage = totalCount > 0 ? (count / totalCount) * 100 : 0;
          return RadarEntry(value: percentage);
        }).toList(),
        fillColor: primaryBlue.withOpacity(0.2),
        borderColor: primaryBlue,
        borderWidth: 2,
        entryRadius: 3,
      ),
    ];

    // 詳細内訳用のリスト
    List<Widget> legendItems = [];
    var sortedEntries = categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (var entry in sortedEntries) {
      double percentage = totalCount > 0 ? (entry.value / totalCount) * 100 : 0;
      
      legendItems.add(
        Padding(
          padding: EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${entry.key}: ${entry.value}件 (${percentage.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    color: textPrimaryGrey,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '苦手分野分析',
            style: TextStyle(
              color: textPrimaryGrey,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'レーダーチャートで苦手分野を視覚化します。外側ほど割合の高い分野です。',
            style: TextStyle(
              color: textSecondaryGray,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 16),
          // レーダーチャート
          Container(
            height: 250,
            child: RadarChart(
              RadarChartData(
                dataSets: dataSets,
                radarBackgroundColor: Colors.transparent,
                borderData: FlBorderData(show: false),
                radarBorderData: BorderSide(color: textSecondaryGray.withOpacity(0.3), width: 1),
                titlePositionPercentageOffset: 0.15,
                titleTextStyle: TextStyle(
                  color: textPrimaryGrey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                getTitle: (index, angle) {
                  // 各軸のラベルを適切な角度で配置
                  double adjustedAngle = 0;
                  
                  // 0度（右）から時計回りに配置されるため、各位置に応じて角度調整
                  switch (index) {
                    case 0: // 右
                      adjustedAngle = 0;
                      break;
                    case 1: // 右下
                      adjustedAngle = -45;
                      break;
                    case 2: // 下
                      adjustedAngle = -90;
                      break;
                    case 3: // 左下
                      adjustedAngle = -135;
                      break;
                    case 4: // 左
                      adjustedAngle = 180;
                      break;
                    case 5: // 左上
                      adjustedAngle = 135;
                      break;
                    case 6: // 上
                      adjustedAngle = 90;
                      break;
                  }
                  
                  return RadarChartTitle(
                    text: categories[index],
                    angle: adjustedAngle * 3.14159 / 180, // ラジアンに変換
                  );
                },
                tickCount: 5,
                ticksTextStyle: TextStyle(
                  color: textSecondaryGray,
                  fontSize: 10,
                ),
                tickBorderData: BorderSide(color: textSecondaryGray.withOpacity(0.2), width: 1),
                gridBorderData: BorderSide(color: textSecondaryGray.withOpacity(0.2), width: 1),
              ),
            ),
          ),
          SizedBox(height: 16),
          // 凡例（下に配置）
          Text(
            '詳細内訳',
            style: TextStyle(
              color: textPrimaryGrey,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          ...legendItems,
        ],
      ),
    );
  }

  // コンディション詳細円グラフ
  Widget _buildDetailedConditionPieChart(Map<int, int> conditionCount) {
    if (conditionCount.isEmpty) {
      return _buildEmptyChart('コンディション分析', 'データなし');
    }

    List<PieChartSectionData> sections = [];
    List<Widget> legendItems = [];
    int total = conditionCount.values.fold(0, (a, b) => a + b);

    // 色の段階設定（1=最悪red → 4=普通grey → 7=最高primaryBlue）
    List<Color> getConditionColor(int level) {
      switch (level) {
        case 1:
          return [Colors.red];
        case 2:
          return [Colors.red[300]!];
        case 3:
          return [Colors.red[200]!];
        case 4:
          return [Colors.grey];
        case 5:
          return [primaryBlue.withOpacity(0.6)];
        case 6:
          return [primaryBlue.withOpacity(0.8)];
        case 7:
          return [primaryBlue];
        default:
          return [Colors.grey[300]!];
      }
    }

    String getConditionLabel(int level) {
      switch (level) {
        case 1:
          return '1 - 最悪';
        case 2:
          return '2 - かなり悪い';
        case 3:
          return '3 - 悪い';
        case 4:
          return '4 - 普通';
        case 5:
          return '5 - 良い';
        case 6:
          return '6 - かなり良い';
        case 7:
          return '7 - 最高';
        default:
          return '不明';
      }
    }

    String getConditionDescription(int level) {
      switch (level) {
        case 1:
        case 2:
        case 3:
          return '体調・精神状態が良くない時のミス';
        case 4:
          return '普通の状態での基本的なミス';
        case 5:
        case 6:
        case 7:
          return '調子が良い時でも発生するミス';
        default:
          return '';
      }
    }

    // 1-7の順序で処理
    for (int level = 1; level <= 7; level++) {
      if (conditionCount.containsKey(level)) {
        int count = conditionCount[level]!;
        double percentage = (count / total) * 100;
        Color color = getConditionColor(level)[0];

        sections.add(
          PieChartSectionData(
            value: count.toDouble(),
            title: '${percentage.toStringAsFixed(1)}%',
            color: color,
            radius: 60,
            titleStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );

        legendItems.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${getConditionLabel(level)}: ${count}件 (${percentage.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        color: textPrimaryGrey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: 24, top: 2),
                  child: Text(
                    getConditionDescription(level),
                    style: TextStyle(
                      color: textSecondaryGray,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'コンディション分析',
            style: TextStyle(
              color: textPrimaryGrey,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '体調や精神状態とミスの関係を分析します。7段階評価でパターンを把握しましょう。',
            style: TextStyle(
              color: textSecondaryGray,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 16),
          // 円グラフ
          Container(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          SizedBox(height: 16),
          // 凡例（下に配置）
          Text(
            '詳細内訳',
            style: TextStyle(
              color: textPrimaryGrey,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          ...legendItems,
        ],
      ),
    );
  }

  // 空のチャート表示
  Widget _buildEmptyChart(String title, String message) {
    return Container(
      height: 250,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textPrimaryGrey,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Icon(
            Icons.pie_chart_outline,
            size: 48,
            color: textSecondaryGray,
          ),
          SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: textSecondaryGray,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // 折れ線グラフ
  Widget _buildLineChart(Map<DateTime, int> dailyMistakes, int days) {
    if (dailyMistakes.isEmpty) {
      return Container(
        height: 250,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ミス数の推移',
              style: TextStyle(
                color: textPrimaryGrey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Icon(
              Icons.show_chart,
              size: 48,
              color: textSecondaryGray,
            ),
            SizedBox(height: 8),
            Text(
              'データがありません',
              style: TextStyle(
                color: textSecondaryGray,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // データポイントを作成
    List<FlSpot> spots = [];
    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(Duration(days: days));
    
    // 日付ラベル用のリスト
    List<String> dateLabels = [];

    for (int i = 0; i <= days; i++) {
      DateTime currentDate = startDate.add(Duration(days: i));
      DateTime dayOnly = DateTime(currentDate.year, currentDate.month, currentDate.day);
      int mistakeCount = dailyMistakes[dayOnly] ?? 0;
      spots.add(FlSpot(i.toDouble(), mistakeCount.toDouble()));
      
      // 週の最初の日や月の最初の日のラベルを作成
      if (i == 0 || i == days || currentDate.weekday == 1 || currentDate.day == 1) {
        dateLabels.add('${currentDate.month}/${currentDate.day}');
      }
    }

    // Y軸の最大値を設定
    double maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    if (maxY == 0) maxY = 1; // 最低でも1にする

    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'ミス数の推移',
            style: TextStyle(
              color: textPrimaryGrey,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY + 1,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: primaryBlue,
                    barWidth: 2,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: primaryBlue.withOpacity(0.1),
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: maxY > 5 ? (maxY / 5).ceil().toDouble() : 1,
                      getTitlesWidget: (value, meta) {
                        if (value < 0) return SizedBox.shrink();
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: textSecondaryGray,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: days > 30 ? days / 6 : days / 4, // 表示する間隔を調整
                      getTitlesWidget: (value, meta) {
                        int dayIndex = value.toInt();
                        if (dayIndex < 0 || dayIndex > days) return SizedBox.shrink();
                        
                        DateTime displayDate = startDate.add(Duration(days: dayIndex));
                        return Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            '${displayDate.month}/${displayDate.day}',
                            style: TextStyle(
                              color: textSecondaryGray,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 5 ? (maxY / 5).ceil().toDouble() : 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: textSecondaryGray.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: textSecondaryGray.withOpacity(0.3)),
                    left: BorderSide(color: textSecondaryGray.withOpacity(0.3)),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: primaryBlue,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        int dayIndex = spot.x.toInt();
                        DateTime date = startDate.add(Duration(days: dayIndex));
                        return LineTooltipItem(
                          '${date.month}/${date.day}\n${spot.y.toInt()}件',
                          TextStyle(color: Colors.white),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}