import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressRepository {
  ProgressRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const _historyKey = 'logic_history';
  final FirebaseFirestore _firestore;

  Future<List<String>> loadLocalHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_historyKey) ?? const [];
  }

  Future<void> saveLocalHistory(List<String> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, history);
  }

  Future<void> syncCloudHistory({
    required String playerId,
    required List<String> history,
  }) async {
    await _firestore.collection('players').doc(playerId).set(
      <String, dynamic>{
        'history': history,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
