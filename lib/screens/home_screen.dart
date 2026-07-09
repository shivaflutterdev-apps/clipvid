import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/clip_provider.dart';
import '../widgets/url_input_card.dart';
import 'processing_screen.dart';
import 'results_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ClipProvider>(
      builder: (context, provider, _) {
        // Navigate to processing or results based on state
        if (provider.isProcessing) {
          return const ProcessingScreen();
        }
        if (provider.isDone) {
          return const ResultsScreen();
        }
        return const _HomeContent();
      },
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Background gradient blobs
          Positioned(
            top: -200, left: -150,
            child: _GlowBlob(color: AppColors.accent.withAlpha(30), size: 600),
          ),
          Positioned(
            bottom: -100, right: -100,
            child: _GlowBlob(color: AppColors.accentViolet.withAlpha(25), size: 500),
          ),

          // Main content
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.height),
              child: Column(
                children: [
                  _buildNavBar(context),
                  _buildHero(context),
                  _buildHowItWorks(),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryStart, AppColors.primaryEnd],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text('ClipVid',
                style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                )),
            ],
          ).animate().fadeIn(duration: 400.ms),

          const Spacer(),

          // Nav links
          ...[('How it works', () {}), ('GitHub', () {})].map((item) =>
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: TextButton(
                onPressed: item.$2,
                child: Text(item.$1,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500,
                  )),
              ),
            )).toList(),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(100),
              color: AppColors.bgCard,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.accent, size: 14),
                const SizedBox(width: 6),
                Text('Powered by Whisper + GPT-4o-mini',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500,
                  )),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3, end: 0),

          const SizedBox(height: 32),

          // Headline with gradient
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.primaryStart, AppColors.primaryEnd],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: Text('Turn Long Videos\ninto Viral Shorts',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: MediaQuery.of(context).size.width > 768 ? 72 : 44,
                fontWeight: FontWeight.w900,
                height: 1.05,
                letterSpacing: -2,
                color: Colors.white, // masked by shader
              )),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 20),

          // Subheadline
          Text(
            'Paste any YouTube URL · AI finds the best moments · Download your clips',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 18, color: AppColors.textSecondary, height: 1.5,
            ),
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 48),

          // URL Input Card
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: const UrlInputCard(),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 20),

          // Trust signals
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 24,
            children: [
              _trustBadge(Icons.lock_outline,       'Free to use'),
              _trustBadge(Icons.flash_on,            'AI-powered scoring'),
              _trustBadge(Icons.download,            'Instant download'),
              _trustBadge(Icons.aspect_ratio,        '9:16 vertical format'),
            ],
          ).animate().fadeIn(delay: 700.ms),
        ],
      ),
    );
  }

  Widget _trustBadge(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.textMuted, size: 14),
        const SizedBox(width: 6),
        Text(label,
          style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13)),
      ],
    );
  }

  Widget _buildHowItWorks() {
    final steps = [
      (Icons.link, 'Paste URL', 'Drop any YouTube link'),
      (Icons.auto_awesome, 'AI Analyzes', 'GPT-4o-mini scores viral moments'),
      (Icons.content_cut, 'Clips Created', 'FFmpeg cuts 9:16 vertical shorts'),
      (Icons.download, 'Download', 'Save clips instantly'),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 40),
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: const Border(
          top:    BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        children: [
          Text('How It Works',
            style: GoogleFonts.inter(
              fontSize: 32, fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            )),
          const SizedBox(height: 8),
          Text('3 steps from long video to viral clips',
            style: GoogleFonts.inter(
              fontSize: 16, color: AppColors.textSecondary,
            )),
          const SizedBox(height: 48),

          Wrap(
            alignment: WrapAlignment.center,
            spacing: 24, runSpacing: 24,
            children: steps.asMap().entries.map((e) {
              final i    = e.key;
              final step = e.value;
              return _StepCard(
                number: i + 1,
                icon:   step.$1,
                title:  step.$2,
                desc:   step.$3,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Text('Built with Flutter · Spring Boot · Whisper · FFmpeg · OpenAI',
        style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13)),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int    number;
  final IconData icon;
  final String title;
  final String desc;

  const _StepCard({
    required this.number,
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color:  AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryStart, AppColors.primaryEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              Positioned(
                top: -4, right: -4,
                child: Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Text('$number',
                      style: GoogleFonts.inter(
                        fontSize: 10, fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      )),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(title,
            style: GoogleFonts.inter(
              fontSize: 15, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            )),
          const SizedBox(height: 8),
          Text(desc,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13, color: AppColors.textSecondary, height: 1.4,
            )),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color  color;
  final double size;
  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
