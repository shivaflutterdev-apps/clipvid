import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/clip_provider.dart';

/// Glassmorphism URL input card — the hero input on the home screen.
class UrlInputCard extends StatefulWidget {
  const UrlInputCard({super.key});

  @override
  State<UrlInputCard> createState() => _UrlInputCardState();
}

class _UrlInputCardState extends State<UrlInputCard> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _focused = false;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool _isValidYouTubeUrl(String url) {
    final regex = RegExp(
      r'^(https?://)?(www\.)?(youtube\.com/watch\?v=|youtu\.be/)[\w-]{11}',
    );
    return regex.hasMatch(url.trim());
  }

  Future<void> _submit() async {
    final url = _controller.text.trim();
    if (url.isEmpty) {
      setState(() => _error = 'Please enter a YouTube URL');
      return;
    }
    if (!_isValidYouTubeUrl(url)) {
      setState(() => _error = 'Please enter a valid YouTube URL');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      await context.read<ClipProvider>().submitUrl(url);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(
          color: _focused ? AppColors.accent : AppColors.border,
          width: _focused ? 2 : 1,
        ),
        boxShadow: _focused
            ? [BoxShadow(
                color: AppColors.accent.withAlpha(50),
                blurRadius: 24,
                spreadRadius: 0,
              )]
            : [],
      ),
      child: Column(
        children: [
          // Input row
          Row(
            children: [
              // YouTube icon
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Icon(Icons.play_circle_fill,
                  color: _focused ? AppColors.accent : AppColors.textMuted,
                  size: 24),
              ),

              // Text field
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focus,
                  style: GoogleFonts.inter(
                    fontSize: 16, color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Paste YouTube URL here…',
                    hintStyle: GoogleFonts.inter(
                      color: AppColors.textMuted, fontSize: 16,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 20,
                    ),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
              ),

              // CTA Button
              Padding(
                padding: const EdgeInsets.all(8),
                child: _loading
                    ? const SizedBox(
                        width: 48, height: 48,
                        child: Center(
                          child: SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : _GradientButton(
                        onTap: _submit,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Get Clips',
                              style: GoogleFonts.inter(
                                fontSize: 15, fontWeight: FontWeight.w700,
                                color: Colors.white,
                              )),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 18),
                          ],
                        ),
                      ),
              ),
            ],
          ),

          // Error message
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 14),
                  const SizedBox(width: 6),
                  Text(_error!,
                    style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.error,
                    )),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Gradient CTA button with hover scale effect.
class _GradientButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget       child;
  const _GradientButton({required this.onTap, required this.child});

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryStart, AppColors.primaryEnd],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withAlpha(80),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
