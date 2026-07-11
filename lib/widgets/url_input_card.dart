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
  int _maxClips = 2;
  bool _autoCaptions = false;
  String _captionFont = 'Arial';
  int _captionSize = 24;
  String _captionColor = '#FFFFFF';
  String _language = '';
  
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
        maxClips: _maxClips,
        autoCaptions: _autoCaptions,
        captionFont: _captionFont,
        captionSize: _captionSize,
        captionColor: _captionColor,
        language: _language,
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
        color: context.colors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(
          color: _focused ? context.colors.accent : context.colors.border,
          width: _focused ? 2 : 1,
        ),
        boxShadow: _focused
            ? [BoxShadow(
                color: context.colors.accent.withAlpha(50),
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
                  color: _focused ? context.colors.accent : context.colors.textMuted,
                  size: 24),
              ),

              // Text field
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focus,
                  style: GoogleFonts.inter(
                    fontSize: 16, color: context.colors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Paste YouTube URL here…',
                    hintStyle: GoogleFonts.inter(
                      color: context.colors.textMuted, fontSize: 16,
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
                  Icon(Icons.error_outline, color: context.colors.error, size: 14),
                  const SizedBox(width: 6),
                  Text(_error!,
                    style: GoogleFonts.inter(
                      fontSize: 13, color: context.colors.error,
                    )),
                ],
              ),
            ),
            
          // Aspect Ratio Selector
          Divider(color: context.colors.border, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text('Format:', style: GoogleFonts.inter(color: context.colors.textSecondary, fontSize: 14)),
                const SizedBox(width: 8),
                _buildRatioChip('9:16', 'Shorts', Icons.crop_portrait),
                _buildRatioChip('3:4', 'Portrait', Icons.portrait),
                _buildRatioChip('1:1', 'Square', Icons.crop_square),
                _buildRatioChip('16:9', 'Original', Icons.crop_16_9),
              ],
            ),
          ),
          
          // Max Clips Selector
          Divider(color: context.colors.border, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.video_library, color: context.colors.textSecondary, size: 18),
                const SizedBox(width: 8),
                Text('Clips to Generate:', style: GoogleFonts.inter(color: context.colors.textSecondary, fontSize: 14)),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: context.colors.bgDark,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _maxClips,
                        isExpanded: true,
                        dropdownColor: context.colors.bgSurface,
                        icon: Icon(Icons.arrow_drop_down, color: context.colors.textSecondary),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        style: GoogleFonts.inter(color: context.colors.textPrimary, fontSize: 13),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('1 Clip')),
                          DropdownMenuItem(value: 2, child: Text('2 Clips')),
                          DropdownMenuItem(value: 4, child: Text('4 Clips')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _maxClips = val);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Audio Language
          Divider(color: context.colors.border, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.language, color: context.colors.textSecondary, size: 18),
                const SizedBox(width: 8),
                Text('Language (Optional):', style: GoogleFonts.inter(color: context.colors.textSecondary, fontSize: 14)),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: context.colors.bgDark,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _language,
                        isExpanded: true,
                        dropdownColor: context.colors.bgSurface,
                        icon: Icon(Icons.arrow_drop_down, color: context.colors.textSecondary),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        style: GoogleFonts.inter(color: context.colors.textPrimary, fontSize: 13),
                        items: const [
                          DropdownMenuItem(value: '', child: Text('Auto-Detect')),
                          DropdownMenuItem(value: 'en', child: Text('English')),
                          DropdownMenuItem(value: 'te', child: Text('Telugu')),
                          DropdownMenuItem(value: 'ta', child: Text('Tamil')),
                          DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                          DropdownMenuItem(value: 'es', child: Text('Spanish')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _language = val);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Auto-Captions Toggle
          Divider(color: context.colors.border, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.subtitles, color: context.colors.textSecondary, size: 18),
                    const SizedBox(width: 8),
                    Text('Add Auto-Captions (Beta)', style: GoogleFonts.inter(color: context.colors.textSecondary, fontSize: 14)),
                  ],
                ),
                SizedBox(
                  height: 30,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Switch(
                      value: _autoCaptions,
                      onChanged: (val) => setState(() => _autoCaptions = val),
                      activeColor: context.colors.accent,
                      activeTrackColor: context.colors.accent.withAlpha(40),
                      inactiveThumbColor: context.colors.textMuted,
                      inactiveTrackColor: context.colors.bgSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Caption Customization (Visible only if autoCaptions is true)
          if (_autoCaptions) ...[
            Divider(color: context.colors.border, height: 1),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: context.colors.bgSurface.withAlpha(50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Caption Style', style: GoogleFonts.inter(color: context.colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
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
                      Text('Color:', style: GoogleFonts.inter(color: context.colors.textSecondary, fontSize: 13)),
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
        Text(label, style: GoogleFonts.inter(color: context.colors.textSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: context.colors.border),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            color: context.colors.bgSurface,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: context.colors.bgCard,
              icon: Icon(Icons.arrow_drop_down, color: context.colors.textSecondary),
              style: GoogleFonts.inter(color: context.colors.textPrimary, fontSize: 13),
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
            color: isSelected ? context.colors.accent : Colors.black26,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: context.colors.accent.withAlpha(100), blurRadius: 4, spreadRadius: 1)
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
          color: isSelected ? context.colors.accent.withAlpha(40) : Colors.transparent,
          border: Border.all(color: isSelected ? context.colors.accent : context.colors.border),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isSelected ? context.colors.accent : context.colors.textMuted),
            const SizedBox(width: 6),
            Text('$ratio $label', style: GoogleFonts.inter(
              fontSize: 12, 
              color: isSelected ? context.colors.accent : context.colors.textSecondary,
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
              gradient: LinearGradient(
                colors: [context.colors.primaryStart, context.colors.primaryEnd],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: context.colors.accent.withAlpha(80),
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
