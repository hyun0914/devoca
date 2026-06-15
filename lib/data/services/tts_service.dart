import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  List<Map<String, String>> _voices = [];
  int _selectedIndex = 0;

  // 외부에서 목소리 목록 변경 감지용
  void Function()? onVoicesChanged;

  Future<void> _ensureReady() async {
    if (_ready) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.85);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _ready = true;
    // 목소리 로딩은 비동기 — 브라우저가 준비되는 데 시간이 걸림
    _loadVoices();
  }

  Future<void> _loadVoices() async {
    // Chrome은 목소리를 비동기로 로드하므로 최대 3회 재시도
    for (int attempt = 0; attempt < 3; attempt++) {
      final raw = await _tts.getVoices;
      if (raw != null && (raw as List).isNotEmpty) {
        _parseVoices(raw);
        return;
      }
      await Future.delayed(const Duration(milliseconds: 600));
    }
  }

  void _parseVoices(dynamic raw) {
    final all = (raw as List)
        .cast<Map>()
        .where((v) =>
            (v['locale'] as String? ?? '').toLowerCase().startsWith('en'))
        .map((v) => {
              'name': v['name']?.toString() ?? '',
              'locale': v['locale']?.toString() ?? 'en-US',
            })
        .where((v) => v['name']!.isNotEmpty)
        .toList();

    if (all.isEmpty) return;
    _voices = all;

    // 자동으로 최선의 목소리 선택
    _selectedIndex = _findBestVoiceIndex();
    _tts.setVoice(_voices[_selectedIndex]);

    onVoicesChanged?.call();
  }

  int _findBestVoiceIndex() {
    final checks = [
      (Map<String, String> v) =>
          v['name']!.toLowerCase().contains('google') &&
          v['locale'] == 'en-US',
      (Map<String, String> v) =>
          v['name']!.toLowerCase().contains('google') &&
          v['locale']!.startsWith('en'),
      (Map<String, String> v) =>
          v['name']!.toLowerCase().contains('microsoft') &&
          v['locale'] == 'en-US',
      (Map<String, String> v) => v['locale'] == 'en-US',
    ];

    for (final check in checks) {
      final idx = _voices.indexWhere(check);
      if (idx >= 0) return idx;
    }
    return 0;
  }

  List<Map<String, String>> get voices => List.unmodifiable(_voices);

  String get currentVoiceName =>
      _voices.isEmpty ? '기본 목소리' : (_voices[_selectedIndex]['name'] ?? '');

  Future<void> selectVoice(Map<String, String> voice) async {
    final idx = _voices.indexWhere((v) => v['name'] == voice['name']);
    if (idx < 0) return;
    _selectedIndex = idx;
    await _tts.setVoice(voice);
  }

  Future<void> speak(String text) async {
    try {
      await _ensureReady();
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
