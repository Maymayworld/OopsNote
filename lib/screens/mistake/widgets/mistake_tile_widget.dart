// lib/screens/mistake/widgets/mistake_tile_widget.dart
import 'package:flutter/material.dart';
import 'package:misslog/themes/app_theme.dart';

class MistakeTileWidget extends StatelessWidget {
  final Map<String, dynamic> mistakeData;
  final VoidCallback onTap;

  const MistakeTileWidget({
    super.key,
    required this.mistakeData,
    required this.onTap,
  });

  // 統一アイコンを取得
  IconData _getUnifiedIcon() {
    return Icons.error_outline;
  }

  // 統一色を取得
  Color _getUnifiedColor() {
    return primaryBlue;
  }

  // 日付をフォーマット
  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      DateTime now = DateTime.now();
      Duration difference = now.difference(date);
      
      if (difference.inDays == 0) {
        return '今日';
      } else if (difference.inDays == 1) {
        return '昨日';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}日前';
      } else {
        return '${date.month}/${date.day}';
      }
    } catch (e) {
      return '日付不明';
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> tags = mistakeData['tags'] ?? [];
    String name = mistakeData['name'] ?? 'ミス名なし';
    String date = mistakeData['date'] ?? '';
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardGrey,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 左側アイコン（統一）
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getUnifiedColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getUnifiedIcon(),
                  color: _getUnifiedColor(),
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // 中央の情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ミス名
                    Text(
                      name,
                      style: TextStyle(
                        color: textPrimaryGrey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // ミスの種類（タグ）
                    if (tags.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: tags.take(3).map<Widget>((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getUnifiedColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tag.toString(),
                              style: TextStyle(
                                color: _getUnifiedColor(),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              
              // 右側の矢印アイコン
              Icon(
                Icons.chevron_right,
                color: textSecondaryGray,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}