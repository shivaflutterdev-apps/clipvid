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
  String _aspectRatio = '9:16';
  bool _autoCaptions = false;
  String _captionFont = 'Arial';
  int _captionSize = 24;
  String _captionColor = '#FFFFFF';
  
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
      await context.read<ClipProvider>().submitUrl(
        url,
        aspectRatio: _aspectRatio,
        autoCaptions: _autoCaptions,
        captionFont: _captionFont,
        captionSize: _captionSize,
        captionColor: _captionColor,
      );
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
            
          // Aspect Ratio Selector
          const Divider(color: AppColors.border, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Text('Format:', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(width: 16),
                _buildRatioChip('9:16', 'Shorts', Icons.crop_portrait),
                const SizedBox(width: 8),
                _buildRatioChip('3:4', 'Portrait', Icons.portrait),
                const SizedBox(width: 8),
                _buildRatioChip('1:1', 'Square', Icons.crop_square),
              ],
            ),
          ),
          
          // Auto-Captions Toggle
          const Divider(color: AppColors.border, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.subtitles, color: AppColors.textSecondary, size: 18),
                    const SizedBox(width: 8),
                    Text('Add Auto-Captions (Beta)', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14)),
                  ],
                ),
                SizedBox(
                  height: 30,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Switch(
                      value: _autoCaptions,
                      onChanged: (val) => setState(() => _autoCaptions = val),
                      activeColor: AppColors.accent,
                      activeTrackColor: AppColors.accent.withAlpha(40),
                      inactiveThumbColor: AppColors.textMuted,
                      inactiveTrackColor: AppColors.bgSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Caption Customization (Visible only if autoCaptions is true)
          if (_autoCaptions) ...[
            const Divider(color: AppColors.border, height: 1),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: AppColors.bgSurface.withAlpha(50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Caption Style', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Font Family
                      Expanded(
                        child: _buildDropdown(
                          label: 'Font',
                          value: _captionFont,
                          items: ['Arial', 'Helvetica', 'Impact', 'Courier New', 'Times New Roman'],
                          onChanged: (val) => setState(() => _captionFont = val!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Font Size
                      Expanded(
                        child: _buildDropdown<int>(
                          label: 'Size',
                          value: _captionSize,
                          items: [18, 24, 32, 40],
                          itemLabel: (s) => s == 18 ? 'Small' : s == 24 ? 'Medium' : s == 32 ? 'Large' : 'X-Large',
                          onChanged: (val) => setState(() => _captionSize = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Color Picker
                  Row(
                    children: [
                      Text('Color:', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(width: 12),
                      _buildColorPicker('#FFFFFF', Colors.white),
                      _buildColorPicker('#FFFF00', Colors.yellow),
                      _buildColorPicker('#00FF00', Colors.green),
                      _buildColorPicker('#00FFFF', Colors.cyan),
                      _buildColorPicker('#FF00FF', Colors.pink),
                      _buildColorPicker('#FF0000', Colors.red),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
    String Function(T)? itemLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            color: AppColors.bgSurface,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.bgCard,
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13),
              onChanged: onChanged,
              items: items.map((T item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemLabel != null ? itemLabel(item) : item.toString()),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorPicker(String hex, Color color) {
    final isSelected = _captionColor == hex;
    return GestureDetector(
      onTap: () => setState(() => _captionColor = hex),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.black26,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: AppColors.accent.withAlpha(100), blurRadius: 4, spreadRadius: 1)
          ] : null,
        ),
      ),
    );
  }

  Widget _buildRatioChip(String ratio, String label, IconData icon) {
    final isSelected = _aspectRatio == ratio;
    return InkWell(
      onTap: () => setState(() => _aspectRatio = ratio),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withAlpha(40) : Colors.transparent,
          border: Border.all(color: isSelected ? AppColors.accent : AppColors.border),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isSelected ? AppColors.accent : AppColors.textMuted),
            const SizedBox(width: 6),
            Text('$ratio $label', style: GoogleFonts.inter(
              fontSize: 12, 
              color: isSelected ? AppColors.accent : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            )),
          ],
        ),
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
