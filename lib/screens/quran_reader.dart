import 'dart:async';

import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import '../core/common.dart';
import '../services/quran_api.dart';

class QuranReader extends StatefulWidget {
  final int surah;
  final int ayah;
  const QuranReader({super.key, required this.surah, this.ayah = 1});
  @override
  State<QuranReader> createState() => _QuranReaderState();
}

class _QuranReaderState extends State<QuranReader> {
  late Future<List<Ayah>> _f = QuranApi.surah(widget.surah);
  final _player = AudioPlayer();
  final List<StreamSubscription> _subs = [];
  List<Ayah> _ayahs = [];
  List<GlobalKey> _keys = [];
  int _sel = -1;
  bool _playing = false;
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    _subs.add(_player.currentIndexStream.listen((i) {
      if (i != null && mounted && _ayahs.isNotEmpty && i < _ayahs.length) {
        setState(() => _sel = i);
        _remember(i);
        _reveal(i);
      }
    }));
    _subs.add(_player.playerStateStream.listen((st) {
      if (mounted) setState(() => _playing = st.playing && st.processingState != ProcessingState.completed);
    }));
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _player.dispose();
    super.dispose();
  }

  void _remember(int i) {
    final s = AppState.instance;
    s.update(() {
      s.lastSurah = widget.surah;
      s.lastAyah = _ayahs[i].inSurah;
    });
  }

  void _reveal(int i) {
    if (i < 0 || i >= _keys.length) return;
    final ctx = _keys[i].currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 350), alignment: 0.2);
    }
  }

  Future<void> _playFrom(int i) async {
    try {
      final s = AppState.instance;
      final src = ConcatenatingAudioSource(children: [
        for (final a in _ayahs) AudioSource.uri(Uri.parse(QuranApi.audioUrl(s.reciter, a.number))),
      ]);
      await _player.setAudioSource(src, initialIndex: i);
      _player.play();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('no_connection'))));
      }
    }
  }

  void _toggle() {
    if (_playing) {
      _player.pause();
    } else if (_player.audioSource == null) {
      _playFrom(_sel < 0 ? 0 : _sel);
    } else {
      _player.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<Ayah>>(
          future: _f,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return Center(child: CircularProgressIndicator(strokeWidth: 2, color: p.accent));
            }
            if (snap.hasError || snap.data == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(t('no_connection'), style: NourText.body(14, p.muted)),
                    TextButton(
                      onPressed: () => setState(() => _f = QuranApi.surah(widget.surah)),
                      child: Text(t('retry'), style: NourText.body(15, p.accent, w: FontWeight.w600)),
                    ),
                  ],
                ),
              );
            }
            if (_ayahs.isEmpty) {
              _ayahs = snap.data!;
              _keys = List.generate(_ayahs.length, (_) => GlobalKey());
              final start = (widget.ayah - 1).clamp(0, _ayahs.length - 1).toInt();
              if (widget.ayah > 1 && !_scrolled) {
                _scrolled = true;
                WidgetsBinding.instance.addPostFrameCallback((_) => _reveal(start));
              }
            }
            return _content(context);
          },
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final p = context.pal;
    final s = AppState.instance;
    final size = s.quranSize;
    final showBasmala = widget.surah != 1 && widget.surah != 9;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
          child: Row(
            children: [
              IconBtn(icon: Icons.arrow_forward, label: t('back'), onTap: () => Navigator.pop(context)),
              Expanded(
                child: Text('${t('surah')} ${nd(widget.surah)} · ${_ayahs.isEmpty ? '' : '${t('juz')} ${nd(_ayahs.first.juz)}'}',
                    textAlign: TextAlign.center, style: NourText.body(13, p.muted)),
              ),
              IconBtn(
                icon: Icons.text_fields,
                label: t('font_size'),
                onTap: () => s.update(() => s.quranSize = s.quranSize >= 38 ? 22 : s.quranSize + 4),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              if (showBasmala)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                      textAlign: TextAlign.center, style: NourText.quran(size + 2, p.accent)),
                ),
              for (var i = 0; i < _ayahs.length; i++)
                InkWell(
                  key: _keys[i],
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    setState(() => _sel = i);
                    _remember(i);
                    _ayahSheet(i);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: i == _sel ? p.accent.withOpacity(0.12) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(text: _ayahs[i].text),
                        TextSpan(
                          text: ' ﴿${_arNum(_ayahs[i].inSurah)}﴾ ',
                          style: NourText.body(size * 0.55, p.accent),
                        ),
                      ]),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: NourText.quran(size, p.ink),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: p.line))),
          child: Row(
            children: [
              InkWell(
                customBorder: const CircleBorder(),
                onTap: _toggle,
                child: Semantics(
                  button: true,
                  label: _playing ? t('pause') : t('play'),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: p.accent, shape: BoxShape.circle),
                    child: Icon(_playing ? Icons.pause : Icons.play_arrow, color: p.onAccent),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: InkWell(
                  onTap: _reciters,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_reciterName(s), style: NourText.body(14, p.ink, w: FontWeight.w500)),
                      Text(
                        _sel < 0 ? t('tap_ayah') : '${t('ayah')} ${nd(_ayahs[_sel].inSurah)} / ${nd(_ayahs.length)}',
                        style: NourText.body(12.5, p.muted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _reciterName(AppState s) {
    final r = kReciters.firstWhere((r) => r.id == s.reciter, orElse: () => kReciters.first);
    return s.lang == 'ar' ? r.ar : r.en;
  }

  String _arNum(int n) {
    const d = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return '$n'.split('').map((c) => d[int.parse(c)]).join();
  }

  void _reciters() {
    final s = AppState.instance;
    showModalBottomSheet(
      context: context,
      backgroundColor: context.pal.bg,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final r in kReciters)
              ListTile(
                title: Text(s.lang == 'ar' ? r.ar : r.en),
                trailing: s.reciter == r.id ? Icon(Icons.check, color: context.pal.accent) : null,
                onTap: () {
                  s.update(() => s.reciter = r.id);
                  Navigator.pop(context);
                  if (_player.audioSource != null) _playFrom(_sel < 0 ? 0 : _sel);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _ayahSheet(int i) {
    final a = _ayahs[i];
    final p = context.pal;
    final s = AppState.instance;
    final key = '${widget.surah}:${a.inSurah}';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: p.bg,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final marked = s.bookmarks.contains(key);
          return SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.75),
              child: ListView(
                padding: const EdgeInsets.all(24),
                shrinkWrap: true,
                children: [
                  Text(a.text,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: NourText.quran(26, p.ink)),
                  const SizedBox(height: 16),
                  const Hairline(),
                  SectionLabel(t('tafsir')),
                  Text(a.tafsir, textDirection: TextDirection.rtl, style: NourText.body(15, p.ink, h: 1.9)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _playFrom(i);
                          },
                          child: Text(t('play_from_here'), style: NourText.body(14, p.accent, w: FontWeight.w600)),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            s.update(() {
                              if (!s.bookmarks.remove(key)) s.bookmarks.add(key);
                            });
                            setSheet(() {});
                          },
                          child: Text(marked ? t('remove_bookmark') : t('add_bookmark'),
                              style: NourText.body(14, p.accent, w: FontWeight.w600)),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: '${a.text} ﴿${_arNum(a.inSurah)}﴾'));
                            Navigator.pop(ctx);
                          },
                          child: Text(t('copy'), style: NourText.body(14, p.accent, w: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
