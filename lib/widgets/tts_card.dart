import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/api_client.dart';
import '../core/constants.dart';

class TtsCard extends StatefulWidget {
  const TtsCard({super.key});

  @override
  State<TtsCard> createState() => _TtsCardState();
}

class _TtsCardState extends State<TtsCard> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _audioUrl;
  String? _error;
  
  final _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _generateAudio() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _audioUrl = null;
    });

    try {
      final api = context.read<ApiClient>();
      final res = await api.generateTts(text);

      if (mounted) {
        setState(() {
          _loading = false;
          _audioUrl = res['url'] as String?;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Error: $e';
        });
      }
    }
  }

  void _togglePlay() async {
    if (_audioUrl == null) return;
    
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(_audioUrl!));
    }
  }

  Future<void> _download() async {
    if (_audioUrl == null) return;
    try {
      await launchUrl(Uri.parse(_audioUrl!), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.volume_up, color: context.colors.primary, size: 28),
              const SizedBox(width: 12),
              Text(
                'Text to Audio (TTS)',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Type or paste your script below to generate a natural-sounding AI voiceover.',
            style: GoogleFonts.inter(color: context.colors.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 24),
          
          Container(
            decoration: BoxDecoration(
              color: context.colors.bgDark,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: context.colors.borderHover),
            ),
            child: TextField(
              controller: _controller,
              maxLines: 6,
              style: GoogleFonts.inter(color: context.colors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Enter text here...',
                hintStyle: GoogleFonts.inter(color: context.colors.textMuted.withOpacity(0.5)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(_error!, style: GoogleFonts.inter(color: context.colors.error)),
            ),
            
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 16,
            children: [
              if (_audioUrl != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                      color: context.colors.primary,
                      iconSize: 48,
                      onPressed: _togglePlay,
                    ),
                    TextButton.icon(
                      onPressed: _download,
                      icon: Icon(Icons.download, color: context.colors.textPrimary),
                      label: Text('Download MP3', style: GoogleFonts.inter(color: context.colors.textPrimary)),
                    )
                  ],
                )
              else
                const SizedBox(),
                
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                onPressed: _loading ? null : _generateAudio,
                icon: _loading 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.auto_awesome, size: 18),
                label: Text(
                  _loading ? 'Generating...' : 'Generate Voice', 
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
