import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/tts_service.dart';
import '../../data/word_data.dart';
import '../../domain/models/word_model.dart';
import '../cubits/progress/progress_cubit.dart';
import '../widgets/category_chip.dart';
import '../widgets/mastery_indicator.dart';

class WordCardScreen extends StatefulWidget {
  final String english;
  const WordCardScreen({super.key, required this.english});

  @override
  State<WordCardScreen> createState() => _WordCardScreenState();
}

class _WordCardScreenState extends State<WordCardScreen> {
  bool _isSpeaking = false;

  WordModel? get _word {
    try {
      return kWordList.firstWhere((w) => w.english == widget.english);
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    // 목소리 목록이 로드되면 UI 갱신
    TtsService.instance.onVoicesChanged = () {
      if (mounted) setState(() {});
    };
  }

  @override
  void dispose() {
    TtsService.instance.onVoicesChanged = null;
    super.dispose();
  }

  Future<void> _speak() async {
    setState(() => _isSpeaking = true);
    await TtsService.instance.speak(widget.english);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => _isSpeaking = false);
  }

  void _showVoicePicker() {
    final voices = TtsService.instance.voices;
    if (voices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용 가능한 목소리를 불러오는 중입니다. 잠시 후 다시 시도해 주세요.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _VoicePicker(
        voices: voices,
        currentName: TtsService.instance.currentVoiceName,
        onSelect: (voice) async {
          await TtsService.instance.selectVoice(voice);
          if (mounted) setState(() {});
          // 선택 즉시 들려줌
          await TtsService.instance.speak(widget.english);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final word = _word;
    if (word == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('단어를 찾을 수 없습니다')),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final catColor = CategoryChip.colorFor(word.category);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          BlocBuilder<ProgressCubit, ProgressState>(
            builder: (context, state) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: MasteryIndicator(
                progress: state.progressFor(word.english),
                showCount: true,
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 40 : 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CategoryChip(category: word.category),
                    const SizedBox(height: 24),

                    // 단어 + 재생 버튼
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            word.english,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Column(
                          children: [
                            IconButton.filled(
                              onPressed: _isSpeaking ? null : _speak,
                              icon: Icon(
                                _isSpeaking
                                    ? Icons.volume_up
                                    : Icons.play_arrow_rounded,
                              ),
                              tooltip: '발음 듣기',
                            ),
                            // 목소리 선택 버튼
                            GestureDetector(
                              onTap: _showVoicePicker,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.tune_rounded,
                                        size: 12,
                                        color: colorScheme.onSurfaceVariant),
                                    const SizedBox(width: 3),
                                    Text(
                                      _shortVoiceName(
                                          TtsService.instance.currentVoiceName),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Text(
                      word.koreanPronunciation,
                      style: TextStyle(
                        fontSize: 20,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _InfoCard(
                      icon: Icons.translate_rounded,
                      label: '한국어 의미',
                      color: catColor,
                      child: Text(
                        word.koreanMeaning,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _InfoCard(
                      icon: Icons.code_rounded,
                      label: '예문',
                      color: catColor,
                      child: Text(
                        word.exampleSentence,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () =>
                            context.push('/word/${word.english}/spelling'),
                        icon: const Icon(Icons.edit_rounded),
                        label: const Text('철자 연습하기'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // "Google US English" → "Google US"
  String _shortVoiceName(String name) {
    if (name.isEmpty) return '목소리';
    final parts = name.split(' ');
    return parts.take(2).join(' ');
  }
}

// ── 목소리 선택 바텀시트 ──────────────────────────────────────────────────────

class _VoicePicker extends StatefulWidget {
  final List<Map<String, String>> voices;
  final String currentName;
  final Future<void> Function(Map<String, String>) onSelect;

  const _VoicePicker({
    required this.voices,
    required this.currentName,
    required this.onSelect,
  });

  @override
  State<_VoicePicker> createState() => _VoicePickerState();
}

class _VoicePickerState extends State<_VoicePicker> {
  String _selectedName = '';

  @override
  void initState() {
    super.initState();
    _selectedName = widget.currentName;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '목소리 선택',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.voices.length,
              itemBuilder: (context, i) {
                final voice = widget.voices[i];
                final name = voice['name'] ?? '';
                final locale = voice['locale'] ?? '';
                final isSelected = name == _selectedName;

                return ListTile(
                  title: Text(
                    name,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  subtitle: Text(
                    locale,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_rounded,
                          color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () async {
                    setState(() => _selectedName = name);
                    Navigator.pop(context);
                    await widget.onSelect(voice);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── 정보 카드 ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Widget child;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
