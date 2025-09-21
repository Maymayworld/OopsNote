// lib/screens/record/record_sheet.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:misslog/screens/record/widgets/category_chip_widget.dart';
import 'package:misslog/screens/record/widgets/category_detail_dialog.dart';
import 'package:misslog/screens/record/widgets/image_picker_dialog.dart';
import 'package:misslog/screens/record/record_dialog.dart';
import 'package:misslog/services/miss_data_service.dart';
import 'package:misslog/themes/app_theme.dart';

class RecordSheet extends HookConsumerWidget{
  const RecordSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final width = MediaQuery.of(context).size.width;

    final nameController = useTextEditingController();
    useListenable(nameController);
    final situationController = useTextEditingController();
    useListenable(situationController);
    final improvementController = useTextEditingController();
    useListenable(improvementController);

    final conditionValue = useState<int>(0);
    final categoryValue = useState<List<String>>([]);
    
    // 画像アップロード関連の状態管理
    final selectedImage = useState<File?>(null);
    final imagePicker = ImagePicker();

    // 画像選択のダイアログを表示する関数
    Future<void> showImageSourceDialog() async {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => ImagePickerDialog(
          onImageSourceSelected: (ImageSource source) async {
            final pickedFile = await imagePicker.pickImage(
              source: source,
              maxWidth: 1920,
              maxHeight: 1080,
              imageQuality: 85,
            );
            if (pickedFile != null) {
              selectedImage.value = File(pickedFile.path);
            }
          },
        ),
      );
    }

    // 画像を削除する関数
    void removeImage() {
      selectedImage.value = null;
    }

    // 保存処理
    Future<void> saveMissData() async {
      try {
        await MissDataService.saveMissData(
          name: nameController.text,
          imagePath: selectedImage.value?.path,
          tags: categoryValue.value,
          condition: conditionValue.value,
          reason: situationController.text.isEmpty ? null : situationController.text,
          improvement: improvementController.text.isEmpty ? null : improvementController.text,
        );
        
        // 保存成功後にダイアログを閉じて成功ダイアログを表示
        if (context.mounted) {
          Navigator.of(context).pop();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return RecordDialog();
            }
          );
        }
      } catch (e) {
        // エラー処理
        print('保存エラー: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('保存に失敗しました: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 1,
      maxChildSize: 1,
      builder: (context, scrollController) {
        return 
        Container(
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
                      'ミス記録',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.close)
                    )
                  ],
                ),
                
                SizedBox(height: 24),

                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      children: [
                        // 日付表示
                        
                        // ミス名入力欄
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
                  
                        TextField(
                          controller: nameController,
                          maxLines: 1,
                          cursorColor: primaryBlue,
                          decoration: InputDecoration(
                            hintText: '符号見間違い',
                            hintStyle: TextStyle(
                              color: textSecondaryGray.withOpacity(0.7),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: nameController.value.text.isEmpty
                                ? textSecondaryGray
                                : primaryBlue,
                                width: nameController.value.text.isEmpty
                                ? 1.0
                                : 2.0
                              ), // 入力前や通常時の枠
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: primaryBlue,
                                width: 2.0
                              ), // フォーカス時の枠
                            ),
                          ),
                        ),
                  
                        SizedBox(height: 12),
                  
                        // 画像添付欄
                        selectedImage.value == null
                          ? // 画像が選択されていない場合：アップロードボタンを表示
                          SizedBox(
                            width: double.infinity,
                            height: 36,
                            child: ElevatedButton(
                              onPressed: showImageSourceDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)
                                )
                              ),
                              child: Text(
                                '問題の画像を追加',
                                style: TextStyle(
                                color: cardGrey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                          : // 画像が選択されている場合：画像を表示
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: showImageSourceDialog,
                                child: Container(
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
                                      selectedImage.value!,
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                              ),
                              // 削除ボタン（×）
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: removeImage,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  
                        SizedBox(height: 12,),
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
                                  // 詳細説明ダイアログ
                                  showDialog(
                                    // ダイアログ外をタップで閉じるように
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

                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CategoryChip(
                                  categoryName: '計算',
                                  isSelected: categoryValue.value.contains('計算'),
                                  onTap: () {
                                    if (categoryValue.value.contains('計算')) {
                                    // すでに入っていたら削除
                                      categoryValue.value = List.from(categoryValue.value)..remove('計算');
                                    } else {
                                    // 入ってなかったら追加
                                      categoryValue.value = List.from(categoryValue.value)..add('計算');
                                    }
                                  },
                                ),
                                SizedBox(width: 8,),
                                CategoryChip(
                                  categoryName: '読解',
                                  isSelected: categoryValue.value.contains('読解'),
                                  onTap: () {
                                    if (categoryValue.value.contains('読解')) {
                                    // すでに入っていたら削除
                                      categoryValue.value = List.from(categoryValue.value)..remove('読解');
                                    } else {
                                    // 入ってなかったら追加
                                      categoryValue.value = List.from(categoryValue.value)..add('読解');
                                    }
                                  },
                                ),
                                SizedBox(width: 8,),
                                CategoryChip(
                                  categoryName: '論理',
                                  isSelected: categoryValue.value.contains('論理'),
                                  onTap: () {
                                    if (categoryValue.value.contains('論理')) {
                                    // すでに入っていたら削除
                                      categoryValue.value = List.from(categoryValue.value)..remove('論理');
                                    } else {
                                    // 入ってなかったら追加
                                      categoryValue.value = List.from(categoryValue.value)..add('論理');
                                    }
                                  },
                                ),
                                SizedBox(width: 8,),
                                CategoryChip(
                                  categoryName: '公式',
                                  isSelected: categoryValue.value.contains('公式'),
                                  onTap: () {
                                    if (categoryValue.value.contains('公式')) {
                                    // すでに入っていたら削除
                                      categoryValue.value = List.from(categoryValue.value)..remove('公式');
                                    } else {
                                    // 入ってなかったら追加
                                      categoryValue.value = List.from(categoryValue.value)..add('公式');
                                    }
                                  },
                                ),
                                SizedBox(width: 8,),
                                CategoryChip(
                                  categoryName: '表記',
                                  isSelected: categoryValue.value.contains('表記'),
                                  onTap: () {
                                    if (categoryValue.value.contains('表記')) {
                                    // すでに入っていたら削除
                                      categoryValue.value = List.from(categoryValue.value)..remove('表記');
                                    } else {
                                    // 入ってなかったら追加
                                      categoryValue.value = List.from(categoryValue.value)..add('表記');
                                    }
                                  },
                                ),
                                SizedBox(width: 8,),
                                CategoryChip(
                                  categoryName: '戦略',
                                  isSelected: categoryValue.value.contains('戦略'),
                                  onTap: () {
                                    if (categoryValue.value.contains('戦略')) {
                                    // すでに入っていたら削除
                                      categoryValue.value = List.from(categoryValue.value)..remove('戦略');
                                    } else {
                                    // 入ってなかったら追加
                                      categoryValue.value = List.from(categoryValue.value)..add('戦略');
                                    }
                                  },
                                ),
                                SizedBox(width: 8,),
                                CategoryChip(
                                  categoryName: 'その他',
                                  isSelected: categoryValue.value.contains('その他'),
                                  onTap: () {
                                    if (categoryValue.value.contains('その他')) {
                                    // すでに入っていたら削除
                                      categoryValue.value = List.from(categoryValue.value)..remove('その他');
                                    } else {
                                    // 入ってなかったら追加
                                      categoryValue.value = List.from(categoryValue.value)..add('その他');
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 12,),
                        Divider(color: Colors.grey[300],),
                        SizedBox(height: 12,),
                  
                        // 状況入力欄
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
                  
                        TextField(
                          controller: situationController,
                          maxLines: null,
                          cursorColor: primaryBlue,
                          decoration: InputDecoration(
                            hintText: '時間がなくて焦っていた',
                            hintStyle: TextStyle(
                              color: textSecondaryGray.withOpacity(0.7),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: situationController.value.text.isEmpty
                                ? textSecondaryGray
                                : primaryBlue,
                                width: situationController.value.text.isEmpty
                                ? 1.0
                                : 2.0
                              ), // 入力前や通常時の枠
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: primaryBlue,
                                width: 2.0
                              ), // フォーカス時の枠
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
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  conditionValue.value = 1;
                                },
                                child: Container(
                                  width: (width-192)/7 + 18,
                                  height: (width-192)/7 + 18,
                                  decoration: BoxDecoration(
                                    color: conditionValue.value == 1
                                    ? Colors.red
                                    : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.red,
                                      width: 2
                                    )
                                  ),
                                  child: conditionValue.value == 1
                                  ? Center(
                                      child: Icon(
                                        Icons.check,
                                        color: cardGrey,
                                        size: 24,
                                      )
                                    )
                                  : null,
                                ),
                              ),
                              SizedBox(width: 10,),
                              GestureDetector(
                                onTap: () {
                                  conditionValue.value = 2;
                                },
                                child: Container(
                                  width: (width-192)/7 + 12,
                                  height: (width-192)/7 + 12,
                                  decoration: BoxDecoration(
                                    color: conditionValue.value == 2
                                    ? Colors.red
                                    : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.red,
                                      width: 2
                                    )
                                  ),
                                  child: conditionValue.value == 2
                                  ? Center(
                                      child: Icon(
                                        Icons.check,
                                        color: cardGrey,
                                        size: 20,
                                      )
                                    )
                                  : null
                                ),
                              ),
                              SizedBox(width: 10,),
                              GestureDetector(
                                onTap: () {
                                  conditionValue.value = 3;
                                },
                                child: Container(
                                  width: (width-192)/7 + 6,
                                  height: (width-192)/7 + 6,
                                  decoration: BoxDecoration(
                                    color: conditionValue.value == 3
                                    ? Colors.red
                                    : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.red,
                                      width: 2
                                    )
                                  ),
                                  child: conditionValue.value == 3
                                  ? Center(
                                      child: Icon(
                                        Icons.check,
                                        color: cardGrey,
                                        size: 16,
                                      )
                                    )
                                  : null
                                ),
                              ),
                              SizedBox(width: 10,),
                              GestureDetector(
                                onTap: () {
                                  conditionValue.value = 4;
                                },
                                child: Container(
                                  width: (width-192)/7,
                                  height: (width-192)/7,
                                  decoration: BoxDecoration(
                                    color: conditionValue.value == 4
                                    ? Colors.grey
                                    : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 2
                                    )
                                  ),
                                  child: conditionValue.value == 4
                                  ? Center(
                                      child: Icon(
                                        Icons.check,
                                        color: cardGrey,
                                        size: 12,
                                      )
                                    )
                                  : null
                                ),
                              ),
                              SizedBox(width: 10,),
                              GestureDetector(
                                onTap: () {
                                  conditionValue.value = 5;
                                },
                                child: Container(
                                  width: (width-192)/7 + 6,
                                  height: (width-192)/7 + 6,
                                  decoration: BoxDecoration(
                                    color: conditionValue.value == 5
                                    ? primaryBlue
                                    : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: primaryBlue,
                                      width: 2
                                    )
                                  ),
                                  child: conditionValue.value == 5
                                  ? Center(
                                      child: Icon(
                                        Icons.check,
                                        color: cardGrey,
                                        size: 16,
                                      )
                                    )
                                  : null
                                ),
                              ),
                              SizedBox(width: 10,),
                              GestureDetector(
                                onTap: () {
                                  conditionValue.value = 6;
                                },
                                child: Container(
                                  width: (width-192)/7 + 12,
                                  height: (width-192)/7 + 12,
                                  decoration: BoxDecoration(
                                    color: conditionValue.value == 6
                                    ? primaryBlue
                                    : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: primaryBlue,
                                      width: 2
                                    )
                                  ),
                                  child: conditionValue.value == 6
                                  ? Center(
                                      child: Icon(
                                        Icons.check,
                                        color: cardGrey,
                                        size: 20,
                                      )
                                    )
                                  : null
                                ),
                              ),
                              SizedBox(width: 10,),
                              GestureDetector(
                                onTap: () {
                                  conditionValue.value = 7;
                                },
                                child: Container(
                                  width: (width-192)/7 + 18,
                                  height: (width-192)/7 + 18,
                                  decoration: BoxDecoration(
                                    color: conditionValue.value == 7
                                    ? primaryBlue
                                    : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: primaryBlue,
                                      width: 2
                                    )
                                  ),
                                  child: conditionValue.value == 7
                                  ? Center(
                                      child: Icon(
                                        Icons.check,
                                        color: cardGrey,
                                        size: 24,
                                      )
                                    )
                                  : null
                                ),
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
                  
                  
                        // 改善案入力欄
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
                  
                        TextField(
                          controller: improvementController,
                          maxLines: null,
                          cursorColor: primaryBlue,
                          decoration: InputDecoration(
                            hintText: '・時間配分を見直す\n・計算問題は符号チェック',
                            hintStyle: TextStyle(
                              color: textSecondaryGray.withOpacity(0.7),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: improvementController.value.text.isEmpty
                                ? textSecondaryGray
                                : primaryBlue,
                                width: improvementController.value.text.isEmpty
                                ? 1.0
                                : 2.0
                              ), // 入力前や通常時の枠
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: primaryBlue,
                                width: 2.0
                              ), // フォーカス時の枠
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24,),
                
                // 保存ボタン
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: ElevatedButton(
                      onPressed: (nameController.value.text.isEmpty || categoryValue.value.isEmpty)
                      ? null
                      : saveMissData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999)
                        )
                      ),
                      child: Text(
                        '保存',
                        style: TextStyle(
                          color: Color(0xFFfafafa),
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        );
      }
    );
  }
}