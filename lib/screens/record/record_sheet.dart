// lib/screens/record/record_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 1,
      maxChildSize: 1,
      builder: (context, scrollController) {
        return 
        Container(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: EdgeInsetsGeometry.all(24),
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
                
                SizedBox(height: 32,),

                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      children: [
                        // 日付表示


                        // ミスタグ選択欄
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'ミスタグ',
                            style: TextStyle(
                              color: textPrimaryGrey,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  
                        SizedBox(height: 8,),
                  
                        SizedBox(height: 24,),
                        
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
                  
                        SizedBox(height: 24),
                  
                        // 画像添付欄
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '画像添付',
                            style: TextStyle(
                              color: textPrimaryGrey,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  
                        SizedBox(height: 8,),
                  
                        SizedBox(height: 24,),
                  
                        // 状況入力欄
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'どんな状況だった？',
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
                  
                        SizedBox(height: 24),
                   
                        // コンディションメーター
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'あなたの調子は？',
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
                  
                        SizedBox(height: 24,),
                  
                  
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
                  
                        SizedBox(height: 32),
                  
                      
                      ],
                    ),
                  ),
                ),
                
                // 保存ボタン
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: ElevatedButton(
                        onPressed: nameController.value.text.isEmpty
                        ? null
                        : () {
                          Navigator.of(context).pop();
                        },
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
                          ),),
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