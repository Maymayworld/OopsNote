// lib/screens/shop/widgets/purchase_sheet.dart
import 'package:flutter/material.dart';
import 'package:misslog/themes/app_theme.dart';

class PurchaseSheet extends StatelessWidget {
  const PurchaseSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ハンドルバー
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // コンテンツ
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // タイトル
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.star,
                              color: primaryBlue,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'プレミアム会員になろう',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: textPrimaryGrey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 課金案内文
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: backgroundGray,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'プレミアム会員の特典',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textPrimaryGrey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildFeatureItem(Icons.block, '広告の非表示'),
                            _buildFeatureItem(Icons.analytics, '詳細な統計分析'),
                            _buildFeatureItem(Icons.backup, 'データのクラウドバックアップ'),
                            _buildFeatureItem(Icons.palette, 'カスタムテーマ'),
                            _buildFeatureItem(Icons.notifications, 'リマインダー機能'),
                            _buildFeatureItem(Icons.cloud_sync, '複数デバイス間の同期'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // 料金プラン
                      Text(
                        '料金プラン',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textPrimaryGrey,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 月額プラン
                      _buildPlanCard(
                        title: '月額プラン',
                        price: '¥480',
                        period: '/月',
                        description: 'いつでもキャンセル可能',
                        isRecommended: false,
                        onTap: () {
                          _handlePurchase(context, 'monthly');
                        },
                      ),

                      const SizedBox(height: 12),

                      // 年額プラン（おすすめ）
                      _buildPlanCard(
                        title: '年額プラン',
                        price: '¥3,980',
                        period: '/年',
                        description: '2ヶ月分お得！（月額換算 ¥332）',
                        isRecommended: true,
                        onTap: () {
                          _handlePurchase(context, 'yearly');
                        },
                      ),

                      const SizedBox(height: 24),

                      // 注意事項
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '注意事項',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textSecondaryGray,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '• 購入後の返金はできません\n'
                              '• 自動更新されます\n'
                              '• 設定からいつでもキャンセル可能です\n'
                              '• キャンセル後も期間終了まで利用できます',
                              style: TextStyle(
                                fontSize: 12,
                                color: textSecondaryGray,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // 閉じるボタン
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Text(
                    '閉じる',
                    style: TextStyle(
                      fontSize: 16,
                      color: textSecondaryGray,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: primaryBlue,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: textPrimaryGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String period,
    required String description,
    required bool isRecommended,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isRecommended ? primaryBlue.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRecommended ? primaryBlue : Colors.grey[300]!,
            width: isRecommended ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimaryGrey,
                    ),
                  ),
                ),
                if (isRecommended)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'おすすめ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                Text(
                  period,
                  style: TextStyle(
                    fontSize: 16,
                    color: textSecondaryGray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: textSecondaryGray,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isRecommended ? primaryBlue : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '選択する',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isRecommended ? Colors.white : textSecondaryGray,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePurchase(BuildContext context, String planType) {
    // 実際の課金処理をここに実装
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('購入確認'),
        content: Text(
          planType == 'monthly' 
            ? '月額プラン（¥480/月）を購入しますか？'
            : '年額プラン（¥3,980/年）を購入しますか？'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              // 購入処理を実装
              _processPurchase(planType);
            },
            child: const Text('購入する'),
          ),
        ],
      ),
    );
  }

  void _processPurchase(String planType) {
    // 実際の課金処理（App Store Connect / Google Play Billing）
    print('Purchase initiated for: $planType');
  }
}