// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:misslog/themes/app_theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:misslog/screens/record/record_sheet.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      body: Center(
        child: Column(
          children: [

            SizedBox(height: 32,),

            // 今日のミス数, 累計ミス数
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: primaryBlue,
                    width: 2
                  ),
                  borderRadius: BorderRadius.circular(999)
                ),
                child: Padding(
                  padding: EdgeInsetsGeometry.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(width: 0),
                      Row(
                        children: [
                          Text('今日のミス数:'),
                          SizedBox(width: 12,),
                          Text(
                            '0',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),
                          )
                        ],
                      ),
                      SizedBox(width: 0,),
                      Row(
                        children: [
                          Text('累計ミス数:'),
                          SizedBox(width: 12,),
                          Text(
                            '0',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),
                          )
                        ],
                      ),
                      SizedBox(width: 0)
                    ],
                  ),
                ),
              )
            ),

            SizedBox(height: 16),

            // ミスった！ボタン
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                width: double.infinity,
                child: FloatingActionButton.extended(
                  backgroundColor: Colors.red,
                  onPressed: (){
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
                    );
                  },
                  label: Text(
                    'ミスった！',
                    style: TextStyle(
                      color: Color(0xFFfafafa),
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    )
                  ),
                ),
              ),
            ),

            SizedBox(height: 32),

            // 直近のミス3件
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 24),
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
          ]
        ),
      )
    );
  }
}