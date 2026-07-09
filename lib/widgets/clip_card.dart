import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
// Conditional import: uses dart:html on web, stub on other platforms
import 'video_helper_stub.dart'
    if (dart.library.html) 'video_helper_web.dart';
import '../core/api_client.dart';
import '../core/constants.dart';

/// Card displaying a generated short clip with thumbnail, inline video player,
/// viral score badge, timestamps, play button and download button.
class ClipCard extends StatefulWidget {
  final ClipItem clip;
  final int      index;
  final String   thumbnailUrl;
  final String   streamUrl;
  final String   downloadUrl;

  const ClipCard({
    super.key,
    required this.clip,
    required this.index,
    required this.thumbnailUrl,
    required this.streamUrl,
    required this.downloadUrl,
  });

  @override
  State<ClipCard> createState() => _ClipCardState();
}

class _ClipCardState extends State<ClipCard> {
  bool _hovered    = false;
  bool _previewing = false;
  bool _videoRegistered = false;
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'vid-${widget.clip.filename.hashCode.abs()}';
  }

  Color get _scoreColor {
    final s = widget.clip.viralScore;
    if (s >= 8) return AppColors.scoreHigh;
    if (s >= 5) return AppColors.scoreMid;
    return AppColors.scoreLow;
  }

  String get _scoreEmoji {
    final s = widget.clip.viralScore;
    if (s >= 9) return '🔥';
    if (s >= 7) return '⚡';
    if (s >= 5) return '✨';
    return '📹';
  }

  /// Download: opens the backend /download URL — browser triggers file save
  Future<void> _download() async {
    final uri = Uri.parse(widget.downloadUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Toggle inline video preview
  void _togglePreview() {
    // Register the view factory the first time Play is tapped
    if (!_videoRegistered) {
      registerVideoView(_viewId, widget.streamUrl);
      _videoRegistered = true;
    }
    setState(() => _previewing = !_previewing);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.bgCardHover : AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: _hovered
                ? AppColors.borderHover.withAlpha(180)
                : AppColors.border,
          ),
          boxShadow: _hovered
              ? [BoxShadow(
                  color: AppColors.accent.withAlpha(25),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                )]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMediaSection(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Clip label + viral score
                  Row(children: [
                    _TagChip(label: 'Clip ${widget.index + 1}', color: AppColors.accent),
                    const Spacer(),
                    _ScoreBadge(
                      score: widget.clip.viralScore,
                      color: _scoreColor,
                      emoji: _scoreEmoji,
                    ),
                  ]),

                  const SizedBox(height: 10),

                  // Title
                  Text(widget.clip.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary, height: 1.3,
                    )),

                  if (widget.clip.hook.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(widget.clip.hook,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic, height: 1.4,
                      )),
                  ],

                  const SizedBox(height: 10),

                  // Duration + timestamps
                  Row(children: [
                    _InfoChip(Icons.timer_outlined, widget.clip.formattedDuration()),
                    const SizedBox(width: 8),
                    _InfoChip(Icons.access_time,
                        '${_fmt(widget.clip.startSec)} → ${_fmt(widget.clip.endSec)}'),
                  ]),

                  const SizedBox(height: 14),

                  // Play + Download buttons
                  Row(children: [
                    Expanded(
                      child: _ActionButton(
                        icon:    _previewing ? Icons.stop_rounded : Icons.play_arrow_rounded,
                        label:   _previewing ? 'Stop'   : 'Play',
                        colors:  _previewing
                            ? [const Color(0xFF2E2E40), const Color(0xFF2E2E40)]
                            : [AppColors.accentViolet, AppColors.accent],
                        onTap:   _togglePreview,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionButton(
                        icon:   Icons.download_rounded,
                        label:  'Download',
                        colors: const [AppColors.primaryStart, AppColors.primaryEnd],
                        onTap:  _download,
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaSection() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      child: AspectRatio(
        aspectRatio: 9 / 16,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Thumbnail (hidden when video is playing) ──
            AnimatedOpacity(
              opacity: _previewing ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              child: Image.network(
                widget.thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.bgSurface,
                  child: const Icon(Icons.video_library_outlined,
                    color: AppColors.textMuted, size: 48),
                ),
              ),
            ),

            // ── HTML5 video player (shown when previewing) ──
            if (_previewing && _videoRegistered)
              HtmlElementView(viewType: _viewId),

            // ── Gradient overlay ──
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.55, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha(_previewing ? 80 : 190),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Centred Play button (only when not playing) ──
            if (!_previewing)
              Center(
                child: GestureDetector(
                  onTap: _togglePreview,
                  child: Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(150),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withAlpha(200), width: 2),
                    ),
                    child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 34),
                  ),
                ),
              ),

            // ── Duration badge ──
            Positioned(
              bottom: 10, left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(190),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(widget.clip.formattedDuration(),
                  style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),

            // ── 9:16 badge ──
            Positioned(
              top: 10, right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(220),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('9:16',
                  style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double sec) {
    final t = sec.round();
    return '${t ~/ 60}:${(t % 60).toString().padLeft(2, '0')}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ActionButton extends StatefulWidget {
  final IconData     icon;
  final String       label;
  final List<Color>  colors;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label,
    required this.colors, required this.onTap});

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hovered ? 1.04 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.colors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: _hovered && widget.colors.length > 1
                  ? [BoxShadow(
                      color: widget.colors.last.withAlpha(80),
                      blurRadius: 10, offset: const Offset(0, 4),
                    )]
                  : [],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, size: 17, color: Colors.white),
                const SizedBox(width: 6),
                Text(widget.label,
                  style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final double score; final Color color; final String emoji;
  const _ScoreBadge({required this.score, required this.color, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(score.toStringAsFixed(1),
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label; final Color color;
  const _TagChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20), borderRadius: BorderRadius.circular(100)),
      child: Text(label,
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon; final String label;
  const _InfoChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: AppColors.textMuted),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
    ]);
  }
}
