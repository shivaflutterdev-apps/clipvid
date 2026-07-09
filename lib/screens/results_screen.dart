import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/api_client.dart';
import '../providers/clip_provider.dart';
import '../widgets/clip_card.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ClipProvider>(
      builder: (context, provider, _) {
        final clips = provider.clips;

        return Scaffold(
          backgroundColor: AppColors.bgDark,
          body: Column(
            children: [
              _buildTopBar(context, provider),
              Expanded(
                child: clips.isEmpty
                    ? _buildEmpty()
                    : _buildClipGrid(context, provider, clips),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, ClipProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryStart, AppColors.primaryEnd],
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text('ClipVid',
                style: GoogleFonts.inter(
                  fontSize: 18, fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                )),
            ],
          ),

          const SizedBox(width: 24),

          // Video title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Your Viral Clips',
                  style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  )),
                if (provider.videoTitle.isNotEmpty)
                  Text(provider.videoTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textSecondary,
                    )),
              ],
            ),
          ),

          // Badges
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(20),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColors.success.withAlpha(60)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 14),
                const SizedBox(width: 6),
                Text('${provider.clips.length} clips ready',
                  style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  )),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // New video button
          ElevatedButton.icon(
            onPressed: () => provider.reset(),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Video'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bgSurface,
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildClipGrid(BuildContext context, ClipProvider provider, List<ClipItem> clips) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sort info
          Row(
            children: [
              Text('${clips.length} clips',
                style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                )),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text('sorted by viral score',
                  style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.textSecondary,
                  )),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 24),

          // Clip cards grid
          LayoutBuilder(
            builder: (context, constraints) {
              // Responsive: 1 col on mobile, 2 on tablet, 3+ on desktop
              final crossAxisCount = constraints.maxWidth > 1200 ? 3
                  : constraints.maxWidth > 700 ? 2 : 1;
              return Wrap(
                spacing: 20,
                runSpacing: 20,
                children: clips.asMap().entries.map((e) {
                  final i    = e.key;
                  final clip = e.value;
                  return SizedBox(
                    width: (constraints.maxWidth - (crossAxisCount - 1) * 20) / crossAxisCount,
                    child: ClipCard(
                      clip:         clip,
                      index:        i,
                      thumbnailUrl: provider.thumbnailUrl(clip),
                      streamUrl:    provider.streamUrl(clip),
                      downloadUrl:  provider.downloadUrl(clip),
                    ).animate().fadeIn(delay: Duration(milliseconds: i * 100 + 200))
                     .slideY(begin: 0.15, end: 0),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.video_library_outlined,
            color: AppColors.textMuted, size: 64),
          const SizedBox(height: 16),
          Text('No clips generated',
            style: GoogleFonts.inter(
              fontSize: 18, fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            )),
          const SizedBox(height: 8),
          Text('The video may be too short or have no clear speech.',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
