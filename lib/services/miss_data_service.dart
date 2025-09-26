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
      String dateId = DateTime.now().toIso8601String();
      Map<String, dynamic> newMissData = {
        'id': dateId, // ユニークIDとして日時を使用
        'name': name,
        'imagePath': imagePath,
        'tags': tags,
        'condition': condition,
        'reason': reason,
        'improvement': improvement,
        'date': dateId,
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
      List<Map<String, dynamic>> dataList = jsonList.cast<Map<String, dynamic>>();
      
      // 既存データにIDがない場合は追加
      bool needsUpdate = false;
      for (var data in dataList) {
        if (data['id'] == null) {
          data['id'] = data['date'] ?? DateTime.now().toIso8601String();
          needsUpdate = true;
        }
      }
      
      // IDを追加した場合は保存し直す
      if (needsUpdate) {
        String updatedJsonString = jsonEncode(dataList);
        await prefs.setString(_missDataKey, updatedJsonString);
      }
      
      return dataList;
      
    } catch (e) {
      print('ミスデータの取得に失敗しました: $e');
      return [];
    }
  }

  // 特定のIDのミスデータを取得
  static Future<Map<String, dynamic>?> getMissDataById(String id) async {
    try {
      List<Map<String, dynamic>> dataList = await getMissDataList();
      return dataList.firstWhere(
        (data) => data['id'] == id,
        orElse: () => {},
      );
    } catch (e) {
      print('ミスデータの取得に失敗しました: $e');
      return null;
    }
  }

  // 特定のIDのミスデータを削除
  static Future<void> deleteMissDataById(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> dataList = await getMissDataList();
      
      // 削除対象のデータを探す
      int indexToDelete = dataList.indexWhere((data) => data['id'] == id);
      
      if (indexToDelete != -1) {
        // 画像ファイルも削除
        String? imagePath = dataList[indexToDelete]['imagePath'];
        if (imagePath != null) {
          File imageFile = File(imagePath);
          if (await imageFile.exists()) {
            await imageFile.delete();
          }
        }
        
        dataList.removeAt(indexToDelete);
        String jsonString = jsonEncode(dataList);
        await prefs.setString(_missDataKey, jsonString);
        
        print('ミスデータを削除しました (ID: $id)');
      } else {
        print('削除対象のデータが見つかりませんでした (ID: $id)');
      }
    } catch (e) {
      print('ミスデータの削除に失敗しました: $e');
      rethrow;
    }
  }

  // 特定のインデックスのミスデータを削除（後方互換性のため残す）
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