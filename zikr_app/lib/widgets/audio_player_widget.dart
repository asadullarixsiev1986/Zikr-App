import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';

/// Проигрывает аудио зикра — либо локальный файл из assets
/// (audioAsset), либо стримит напрямую по ссылке (audioUrl), например
/// с zikr.islom.uz. Если задано и то, и другое — приоритет у assets.
///
/// Если файл/ссылка недоступны, виджет покажет понятную ошибку вместо
/// падения приложения.
class AudioPlayerWidget extends StatefulWidget {
  final String? audioAsset;
  final String? audioUrl;

  const AudioPlayerWidget({super.key, this.audioAsset, this.audioUrl});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _player = AudioPlayer();
  PlayerState _state = PlayerState.stopped;
  bool _fileMissing = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _state = state);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _state = PlayerState.stopped);
    });
  }

  bool get _hasSource => widget.audioAsset != null || widget.audioUrl != null;

  Future<void> _togglePlay() async {
    if (!_hasSource) return;

    try {
      if (_state == PlayerState.playing) {
        await _player.pause();
        return;
      }

      setState(() => _loading = true);
      if (widget.audioAsset != null) {
        // AssetSource ожидает путь без префикса 'assets/'
        final assetPath = widget.audioAsset!.replaceFirst('assets/', '');
        await _player.play(AssetSource(assetPath));
      } else {
        await _player.play(UrlSource(widget.audioUrl!));
      }
      setState(() {
        _fileMissing = false;
        _loading = false;
      });
    } catch (e) {
      // Файл/URL недоступны (нет интернета, файл не добавлен и т.п.) —
      // не роняем приложение, просто показываем статус.
      setState(() {
        _fileMissing = true;
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocale.instance.t('audio_missing_snackbar'))),
        );
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme.primary;
    final isPlaying = _state == PlayerState.playing;

    if (!_hasSource) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _loading
            ? SizedBox(
                width: 40,
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2, color: themeColor),
                ),
              )
            : IconButton(
                iconSize: 40,
                color: _fileMissing ? Colors.grey : themeColor,
                icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
                onPressed: _togglePlay,
              ),
        Text(
          _fileMissing
              ? AppLocale.instance.t('audio_unavailable')
              : (isPlaying
                  ? AppLocale.instance.t('audio_playing')
                  : AppLocale.instance.t('audio_listen')),
          style: TextStyle(color: _fileMissing ? Colors.grey : themeColor),
        ),
      ],
    );
  }
}
