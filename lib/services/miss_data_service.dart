// lib/services/miss_data_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class MissDataService {
  static const String _missDataKey = 'missData';

  // ミスデータを保存
  static Future<void> saveMissData({
    required String name,
    String? imagePath,
    required List<String> tags,
    required int condition,
    String? reason,
    String? improvement,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 既存のデータを取得
      List<Map<String, dynamic>> existingData = await getMissDataList();
      
      // 新しいデータを作成
      Map<String, dynamic> newMissData = {
        'name': name,
        'imagePath': imagePath,
        'tags': tags,
        'condition': condition,
        'reason': reason,
        'improvement': improvement,
        'date': DateTime.now().toIso8601String(),
      };
      
      // 新しいデータを追加
      existingData.add(newMissData);
      
      // JSON形式で保存
      String jsonString = jsonEncode(existingData);
      await prefs.setString(_missDataKey, jsonString);
      
      // デバッグ用のprint
      print('=== ミスデータが保存されました ===');
      print('保存されたデータ: $newMissData');
      print('全データ数: ${existingData.length}');
      print('===========================');
      
    } catch (e) {
      print('ミスデータの保存に失敗しました: $e');
      rethrow;
    }
  }

  // 全てのミスデータを取得
  static Future<List<Map<String, dynamic>>> getMissDataList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString(_missDataKey);
      
      if (jsonString == null) {
        return [];
      }
      
      List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.cast<Map<String, dynamic>>();
      
    } catch (e) {
      print('ミスデータの取得に失敗しました: $e');
      return [];
    }
  }

  // 特定のインデックスのミスデータを取得
  static Future<Map<String, dynamic>?> getMissData(int index) async {
    try {
      List<Map<String, dynamic>> dataList = await getMissDataList();
      if (index >= 0 && index < dataList.length) {
        return dataList[index];
      }
      return null;
    } catch (e) {
      print('ミスデータの取得に失敗しました: $e');
      return null;
    }
  }

  // 特定のインデックスのミスデータを削除
  static Future<void> deleteMissData(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> dataList = await getMissDataList();
      
      if (index >= 0 && index < dataList.length) {
        // 画像ファイルも削除
        String? imagePath = dataList[index]['imagePath'];
        if (imagePath != null) {
          File imageFile = File(imagePath);
          if (await imageFile.exists()) {
            await imageFile.delete();
          }
        }
        
        dataList.removeAt(index);
        String jsonString = jsonEncode(dataList);
        await prefs.setString(_missDataKey, jsonString);
        
        print('ミスデータを削除しました (インデックス: $index)');
      }
    } catch (e) {
      print('ミスデータの削除に失敗しました: $e');
      rethrow;
    }
  }

  // 全てのミスデータを削除
  static Future<void> clearAllMissData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // まず全ての画像ファイルを削除
      List<Map<String, dynamic>> dataList = await getMissDataList();
      for (var data in dataList) {
        String? imagePath = data['imagePath'];
        if (imagePath != null) {
          File imageFile = File(imagePath);
          if (await imageFile.exists()) {
            await imageFile.delete();
          }
        }
      }
      
      await prefs.remove(_missDataKey);
      print('全てのミスデータを削除しました');
    } catch (e) {
      print('ミスデータのクリアに失敗しました: $e');
      rethrow;
    }
  }

  // データ数を取得
  static Future<int> getMissDataCount() async {
    List<Map<String, dynamic>> dataList = await getMissDataList();
    return dataList.length;
  }
}