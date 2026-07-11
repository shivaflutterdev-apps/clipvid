import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/clip_provider.dart';

class ProcessingScreen extends StatelessWidget {
  const ProcessingScreen({super.key});

  static const _steps = [
    _Step('Downloading', 'Fetching video from YouTube',   Icons.download_rounded,   0,  30),
    _Step('Transcribing', 'Converting speech to text',    Icons.mic_rounded,         30, 60),
    _Step('Scoring',     'AI finding viral moments',      Icons.auto_awesome,        60, 76),
    _Step('Clipping',    'Cutting your short clips',      Icons.content_cut_rounded, 76, 100),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ClipProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: context.colors.bgDark,
          body: Stack(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated logo pulse
                        _AnimatedLogo().animate(
                          onPlay: (c) => c.repeat(reverse: true),
                        ).scaleXY(begin: 0.95, end: 1.05, duration: 1200.ms, curve: Curves.easeInOut),

                        const SizedBox(height: 40),

                        // Title
                        Text('Processing Your Video',
                          style: GoogleFonts.inter(
                            fontSize: 28, fontWeight: FontWeight.w800,
                            color: context.colors.textPrimary,
                          )).animate().fadeIn(delay: 200.ms),

                        const SizedBox(height: 8),

                        // Video title if known
                        if (provider.videoTitle.isNotEmpty)
                          Text(provider.videoTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 14, color: context.colors.textSecondary,
                            )).animate().fadeIn(delay: 300.ms),

                        const SizedBox(height: 48),

                        // Step indicators
                        ..._steps.asMap().entries.map((e) {
                          return _StepRow(
                            step: e.value,
                            progress: provider.progress,
                          ).animate().fadeIn(delay: Duration(milliseconds: e.key * 100 + 300));
                        }),

                        const SizedBox(height: 40),

                        // Progress bar
                        _ProgressBar(progress: provider.progress),

                        const SizedBox(height: 16),

                        // Status message
                        Text(provider.statusMsg,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14, color: context.colors.textSecondary,
                          )).animate(key: ValueKey(provider.statusMsg))
                            .fadeIn(duration: 300.ms),

                        const SizedBox(height: 40),

                        // Cancel button
                        TextButton(
                          onPressed: () => provider.reset(),
                          child: Text('Cancel',
                            style: GoogleFonts.inter(color: context.colors.textMuted, fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 48,
                right: 24,
                child: IconButton(
                  onPressed: () => provider.reset(),
                  icon: Icon(Icons.close, color: context.colors.textMuted),
                  tooltip: 'Exit to Home',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Step {
  final String name;
  final String desc;
  final IconData icon;
  final int startProgress;
  final int endProgress;
  const _Step(this.name, this.desc, this.icon, this.startProgress, this.endProgress);

  bool isActive(int progress) => progress >= startProgress && progress < endProgress;
  bool isDone(int progress)   => progress >= endProgress;
  bool isPending(int progress)=> progress < startProgress;
}

class _StepRow extends StatelessWidget {
  final _Step step;
  final int   progress;
  const _StepRow({super.key, required this.step, required this.progress});

  @override
  Widget build(BuildContext context) {
    final isDone    = step.isDone(progress);
    final isActive  = step.isActive(progress);

    Color iconBg    = context.colors.bgSurface;
    Color iconColor = context.colors.textMuted;
    Color titleColor = context.colors.textMuted;

    if (isDone) {
      iconBg    = context.colors.success.withAlpha(30);
      iconColor = context.colors.success;
      titleColor = context.colors.textSecondary;
    } else if (isActive) {
      iconBg    = context.colors.accent.withAlpha(30);
      iconColor = context.colors.accent;
      titleColor = context.colors.textPrimary;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Icon circle
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? context.colors.accent : context.colors.border,
                width: isActive ? 2 : 1,
              ),
            ),
            child: isDone
                ? Icon(Icons.check_rounded, color: context.colors.success, size: 20)
                : isActive
                  ? _SpinIcon(step.icon, iconColor)
                  : Icon(step.icon, color: iconColor, size: 20),
          ),

          const SizedBox(width: 16),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                  child: Text(step.name),
                ),
                Text(step.desc,
                  style: GoogleFonts.inter(
                    fontSize: 12, color: context.colors.textMuted,
                  )),
              ],
            ),
          ),

          // Done badge
          if (isDone)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: context.colors.success.withAlpha(20),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text('Done',
                style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: context.colors.success,
                )),
            ),

          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: context.colors.accent.withAlpha(20),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text('Running…',
                style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: context.colors.accent,
                )),
            ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int progress;
  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Progress',
              style: GoogleFonts.inter(fontSize: 12, color: context.colors.textMuted)),
            Text('$progress%',
              style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: context.colors.accent,
              )),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress / 100),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: context.colors.border,
              valueColor: AlwaysStoppedAnimation(context.colors.accent),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80, height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.colors.primaryStart, context.colors.primaryEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: context.colors.accent.withAlpha(80),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 38),
    );
  }
}

class _SpinIcon extends StatefulWidget {
  final IconData icon;
  final Color    color;
  const _SpinIcon(this.icon, this.color);

  @override
  State<_SpinIcon> createState() => _SpinIconState();
}

class _SpinIconState extends State<_SpinIcon> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _ctrl,
      child: Icon(widget.icon, color: widget.color, size: 20),
    );
  }
}
