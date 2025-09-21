// lib/screens/mistake/widgets/mistake_detail_sheet.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:misslog/screens/record/widgets/category_chip_widget.dart';
import 'package:misslog/screens/record/widgets/category_detail_dialog.dart';
import 'package:misslog/screens/record/widgets/image_picker_dialog.dart';
import 'package:misslog/services/miss_data_service.dart';
import 'package:misslog/themes/app_theme.dart';

class MistakeDetailSheet extends HookConsumerWidget {
  final Map<String, dynamic> mistakeData;
  final int mistakeIndex;
  final VoidCallback? onDataUpdated;

  const MistakeDetailSheet({
    super.key,
    required this.mistakeData,
    required this.mistakeIndex,
    this.onDataUpdated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;

    // データの表示用変数
    String name = mistakeData['name'] ?? 'ミス名なし';
    String? imagePath = mistakeData['imagePath'];
    List<String> tags = List<String>.from(mistakeData['tags'] ?? []);
    int condition = mistakeData['condition'] ?? 0;
    String? reason = mistakeData['reason'];
    String? improvement = mistakeData['improvement'];

    // 削除処理
    Future<void> deleteMissData() async {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: cardGrey,
            title: Text(
              '削除確認',
              style: TextStyle(color: textPrimaryGrey),
            ),
            content: Text(
              'このミスデータを削除しますか？\nこの操作は元に戻せません。',
              style: TextStyle(color: textPrimaryGrey),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'キャンセル',
                  style: TextStyle(color: textSecondaryGray),
                ),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await MissDataService.deleteMissData(mistakeIndex);
                    if (context.mounted) {
                      Navigator.of(context).pop(); // ダイアログを閉じる
                      Navigator.of(context).pop(); // 詳細シートを閉じる
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('ミスデータを削除しました'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      onDataUpdated?.call();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('削除に失敗しました: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  '削除',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      );
    }

    // 日付のフォーマット
    String formatDate(String dateString) {
      try {
        DateTime date = DateTime.parse(dateString);
        return '${date.year}年${date.month}月${date.day}日 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        return '日付不明';
      }
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 1,
      maxChildSize: 1,
      builder: (context, scrollController) {
        return Container(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                // 画面最上部
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ミス詳細・編集',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Row(
                      children: [
                        // 削除ボタン
                        IconButton(
                          onPressed: deleteMissData,
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                        ),
                        // 閉じるボタン
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.close),
                        ),
                      ],
                    ),
                  ],
                ),
                
                SizedBox(height: 8),
                
                // 記録日時表示
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '記録日時: ${formatDate(mistakeData['date'] ?? '')}',
                    style: TextStyle(
                      color: textSecondaryGray,
                      fontSize: 14,
                    ),
                  ),
                ),
                
                SizedBox(height: 24),

                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      children: [
                        // ミス名表示
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'ミス名',
                            style: TextStyle(
                              color: textPrimaryGrey,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  
                        SizedBox(height: 8,),
                  
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardGrey,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: textSecondaryGray,
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            name,
                            style: TextStyle(
                              color: textPrimaryGrey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                  
                        SizedBox(height: 12),
                  
                        // 画像表示欄（画像がある場合のみ）
                        if (imagePath != null) ...[
                          Container(
                            width: double.infinity,
                            constraints: BoxConstraints(
                              minHeight: 120,
                              maxHeight: 300,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(imagePath),
                                fit: BoxFit.contain,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 120,
                                    child: Center(
                                      child: Text(
                                        '画像が見つかりません',
                                        style: TextStyle(
                                          color: textSecondaryGray,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                        ],
                        Divider(color: Colors.grey[300],),
                        SizedBox(height: 12,),

                        // ミスハッシュタグ
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'ミスの種類は？',
                                style: TextStyle(
                                  color: textPrimaryGrey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    barrierDismissible: true,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CategoryDetailDialog();
                                    }
                                  );
                                },
                                child: Center(
                                  child: Icon(
                                    Icons.info_outline_rounded,
                                    color: Colors.grey[400],
                                    size: 18,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                  
                        SizedBox(height: 8,),

                        // ミスの種類（タグ）表示
                        if (tags.isNotEmpty) ...[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              alignment: WrapAlignment.start,
                              spacing: 8,
                              runSpacing: 8,
                              children: tags.map<Widget>((tag) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: primaryBlue,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      color: primaryBlue,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],

                        SizedBox(height: 12,),
                        Divider(color: Colors.grey[300],),
                        SizedBox(height: 12,),
                  
                        // 状況表示欄
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'なぜミスをしてしまった？',
                            style: TextStyle(
                              color: textPrimaryGrey,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  
                        SizedBox(height: 8,),
                  
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardGrey,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: textSecondaryGray,
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            reason ?? '記録なし',
                            style: TextStyle(
                              color: reason != null ? textPrimaryGrey : textSecondaryGray,
                              fontSize: 16,
                            ),
                          ),
                        ),
                  
                        SizedBox(height: 12,),
                        Divider(color: Colors.grey[300],),
                        SizedBox(height: 12,),
                   
                        // コンディションメーター
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '調子はどうだった？',
                            style: TextStyle(
                              color: textPrimaryGrey,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  
                        SizedBox(height: 8,),

                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                width: (width-192)/7 + 18,
                                height: (width-192)/7 + 18,
                                decoration: BoxDecoration(
                                  color: condition == 1
                                  ? Colors.red
                                  : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.red,
                                    width: 2
                                  )
                                ),
                                child: condition == 1
                                ? Center(
                                    child: Icon(
                                      Icons.check,
                                      color: cardGrey,
                                      size: 24,
                                    )
                                  )
                                : null,
                              ),
                              SizedBox(width: 10,),
                              Container(
                                width: (width-192)/7 + 12,
                                height: (width-192)/7 + 12,
                                decoration: BoxDecoration(
                                  color: condition == 2
                                  ? Colors.red
                                  : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.red,
                                    width: 2
                                  )
                                ),
                                child: condition == 2
                                ? Center(
                                    child: Icon(
                                      Icons.check,
                                      color: cardGrey,
                                      size: 20,
                                    )
                                  )
                                : null
                              ),
                              SizedBox(width: 10,),
                              Container(
                                width: (width-192)/7 + 6,
                                height: (width-192)/7 + 6,
                                decoration: BoxDecoration(
                                  color: condition == 3
                                  ? Colors.red
                                  : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.red,
                                    width: 2
                                  )
                                ),
                                child: condition == 3
                                ? Center(
                                    child: Icon(
                                      Icons.check,
                                      color: cardGrey,
                                      size: 16,
                                    )
                                  )
                                : null
                              ),
                              SizedBox(width: 10,),
                              Container(
                                width: (width-192)/7,
                                height: (width-192)/7,
                                decoration: BoxDecoration(
                                  color: condition == 4
                                  ? Colors.grey
                                  : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 2
                                  )
                                ),
                                child: condition == 4
                                ? Center(
                                    child: Icon(
                                      Icons.check,
                                      color: cardGrey,
                                      size: 12,
                                    )
                                  )
                                : null
                              ),
                              SizedBox(width: 10,),
                              Container(
                                width: (width-192)/7 + 6,
                                height: (width-192)/7 + 6,
                                decoration: BoxDecoration(
                                  color: condition == 5
                                  ? primaryBlue
                                  : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: primaryBlue,
                                    width: 2
                                  )
                                ),
                                child: condition == 5
                                ? Center(
                                    child: Icon(
                                      Icons.check,
                                      color: cardGrey,
                                      size: 16,
                                    )
                                  )
                                : null
                              ),
                              SizedBox(width: 10,),
                              Container(
                                width: (width-192)/7 + 12,
                                height: (width-192)/7 + 12,
                                decoration: BoxDecoration(
                                  color: condition == 6
                                  ? primaryBlue
                                  : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: primaryBlue,
                                    width: 2
                                  )
                                ),
                                child: condition == 6
                                ? Center(
                                    child: Icon(
                                      Icons.check,
                                      color: cardGrey,
                                      size: 20,
                                    )
                                  )
                                : null
                              ),
                              SizedBox(width: 10,),
                              Container(
                                width: (width-192)/7 + 18,
                                height: (width-192)/7 + 18,
                                decoration: BoxDecoration(
                                  color: condition == 7
                                  ? primaryBlue
                                  : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: primaryBlue,
                                    width: 2
                                  )
                                ),
                                child: condition == 7
                                ? Center(
                                    child: Icon(
                                      Icons.check,
                                      color: cardGrey,
                                      size: 24,
                                    )
                                  )
                                : null
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '最悪',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red
                              ),
                            ),
                            Text(
                              '最高',
                              style: TextStyle(
                                fontSize: 16,
                                color: primaryBlue
                              ),
                            ),
                          ],
                        ),
                  
                        SizedBox(height: 12,),
                        Divider(color: Colors.grey[300],),
                        SizedBox(height: 12,),
                  
                        // 改善案表示欄
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'ミスの改善方法は？',
                            style: TextStyle(
                              color: textPrimaryGrey,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  
                        SizedBox(height: 8,),
                  
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardGrey,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: textSecondaryGray,
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            improvement ?? '記録なし',
                            style: TextStyle(
                              color: improvement != null ? textPrimaryGrey : textSecondaryGray,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24,),
                
                // ボタン群
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: textSecondaryGray),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999)
                      )
                    ),
                    child: Text(
                      '閉じる',
                      style: TextStyle(
                        color: textPrimaryGrey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        );
      }
    );
  }
}