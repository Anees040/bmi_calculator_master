import 'dart:convert';

import 'package:bmi_calculator/features/bmi/domain/bmi_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {
  static const String _historyKey = 'bmi_history_v1';
  static const String _gameKey = 'bmi_game_state_v1';

  Future<List<BmiRecord>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) {
      return <BmiRecord>[];
    }
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((dynamic e) => BmiRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveHistory(List<BmiRecord> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _historyKey,
      jsonEncode(history.map((e) => e.toJson()).toList()),
    );
  }

  Future<GameState> loadGameState() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_gameKey);
    if (raw == null || raw.isEmpty) {
      return GameState.empty;
    }
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return GameState.fromJson(map);
  }

  Future<void> saveGameState(GameState game) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_gameKey, jsonEncode(game.toJson()));
  }
}
