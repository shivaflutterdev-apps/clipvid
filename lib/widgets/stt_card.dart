import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../core/api_client.dart';
import '../core/constants.dart';

class SttCard extends StatefulWidget {
  const SttCard({super.key});

  @override
  State<SttCard> createState() => _SttCardState();
}

class _SttCardState extends State<SttCard> {
  bool _loading = false;
  String? _textResult;
  String? _error;
  String? _fileName;

  Future<void> _pickAndUpload() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'mp4', 'mov'],
        withData: true, // Required for Flutter Web to populate file.bytes
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        setState(() => _error = 'Could not read file data. Please try again.');
        return;
      }

      setState(() {
        _fileName = file.name;
        _loading = true;
        _error = null;
        _textResult = null;
      });

      final api = context.read<ApiClient>();
      final res = await api.transcribeAudio(bytes, file.name);

      if (mounted) {
        setState(() {
          _loading = false;
          _textResult = res['text'] as String?;
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

  void _copyToClipboard() {
    if (_textResult != null) {
      Clipboard.setData(ClipboardData(text: _textResult!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copied to clipboard'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.mic, color: AppColors.accent, size: 28),
              const SizedBox(width: 12),
              Text(
                'Audio to Text (STT)',
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
            'Upload an audio or video file to extract highly accurate text transcripts using Whisper AI.',
            style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 24),
          
          if (_textResult == null && !_loading)
            InkWell(
              onTap: _pickAndUpload,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.borderHover, width: 2, style: BorderStyle.solid),
                  color: AppColors.bgDark,
                ),
                child: Column(
                  children: [
                    Icon(Icons.upload_file, size: 48, color: AppColors.accent),
                    const SizedBox(height: 12),
                    Text(
                      'Click to browse files',
                      style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Supports MP3, WAV, M4A, MP4',
                      style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            
          if (_loading)
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  const CircularProgressIndicator(color: AppColors.accent),
                  const SizedBox(height: 16),
                  Text('Transcribing "$_fileName"...', style: GoogleFonts.inter(color: AppColors.textPrimary)),
                ],
              ),
            ),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(_error!, style: GoogleFonts.inter(color: AppColors.error)),
            ),

          if (_textResult != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgDark,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: SelectableText(
                _textResult!,
                style: GoogleFonts.inter(color: AppColors.textPrimary, height: 1.5),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _textResult = null;
                      _fileName = null;
                    });
                  },
                  icon: const Icon(Icons.refresh, color: AppColors.textMuted),
                  label: Text('Upload Another', style: TextStyle(color: AppColors.textMuted)),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: _copyToClipboard,
                  icon: const Icon(Icons.copy, size: 18),
                  label: Text('Copy Text', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }
}
