// lib/screens/record/widgets/category_detail_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:misslog/themes/app_theme.dart';

class CategoryDetailDialog extends HookConsumerWidget {
  const CategoryDetailDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTabIndex = useState(0);

    final categories = [
      {'title': '計算', 'description': '足し算・掛け算の誤り/符号の書き間違いなど'},
      {'title': '読解', 'description': '問題文の読み間違い/図やグラフの読み取り違いなど'},
      {'title': '論理', 'description': '間違った論理/場合分け漏れなど'},
      {'title': '公式', 'description': '公式の覚え間違い/定理の条件忘れなど'},
      {'title': '表記', 'description': '単位や次元のミス/記号の取り違えなど'},
      {'title': '戦略', 'description': '解法選択の誤り/時間配分のミスなど'},
    ];

    return Dialog(
      backgroundColor: backgroundGray,
      child: IntrinsicHeight(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 上段：固定タイトル
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'ミスの種類について',
                    style: TextStyle(
                      color: textPrimaryGrey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Divider(color: Colors.grey[300],),
                ),
                const SizedBox(height: 8),

                // 中段：横スクロール可能なタブコンテンツ
                SizedBox(
                  height: 100,
                  child: PageView.builder(
                    onPageChanged: (index) => currentTabIndex.value = index,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              categories[index]['title']!,
                              style: TextStyle(
                                color: textPrimaryGrey,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              categories[index]['description']!,
                              style: TextStyle(
                                color: textPrimaryGrey,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // タブインジケーター（丸）
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    categories.length,
                    (index) => GestureDetector(
                      onTap: () => currentTabIndex.value = index,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == currentTabIndex.value
                              ? primaryBlue
                              : textSecondaryGray.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 下部：閉じるボタン
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); 
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                        )
                      ),
                      child: Text(
                        '閉じる',
                        style: TextStyle(
                          color: cardGrey,
                          fontSize: 14,
                        ),
                      ),
                    ),
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