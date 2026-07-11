import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/api_client.dart';
import '../core/constants.dart';
import '../providers/clip_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'results_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _jobs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final client = context.read<ApiClient>();
      final jobs = await client.getHistory();
      setState(() {
        _jobs = jobs;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgDark,
      appBar: AppBar(
        title: Text('My History', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
          ? Center(child: CircularProgressIndicator(color: context.colors.primary))
          : _error != null 
              ? Center(child: Text(_error!, style: TextStyle(color: context.colors.error)))
              : _jobs.isEmpty 
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_toggle_off, size: 64, color: context.colors.textMuted),
                          const SizedBox(height: 16),
                          Text('No clips generated yet.', 
                            style: GoogleFonts.inter(color: context.colors.textSecondary, fontSize: 16)),
                        ],
                      ))
                  : RefreshIndicator(
                      onRefresh: _loadHistory,
                      color: context.colors.primary,
                      backgroundColor: context.colors.bgCard,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _jobs.length,
                        itemBuilder: (context, index) {
                          final job = _jobs[index];
                          final title = job['videoTitle']?.toString() ?? 'Processing Video...';
                          final status = job['status']?.toString() ?? 'QUEUED';
                          final clipsCount = job['clipsCount'] ?? 0;
                          final isDone = status == 'DONE';

                          return Card(
                            color: Colors.transparent,
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: context.colors.border),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                final provider = context.read<ClipProvider>();
                                if (isDone) {
                                  // Fix: use Silently to not trigger HomeScreen state swap
                                  provider.loadPastJobSilently(job['jobId']).then((_) {
                                    if (context.mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const ResultsScreen()),
                                      );
                                    }
                                  });
                                } else if (status != 'FAILED') {
                                  // Resume polling for pending jobs
                                  provider.resumePolling(job['jobId']);
                                  Navigator.of(context).pop(); // Go back to HomeScreen which will show ProcessingScreen
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Job failed in backend. Cannot resume.')),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: context.colors.bgCard,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Thumbnail
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: job['thumbnailUrl'] != null && job['thumbnailUrl'].isNotEmpty
                                          ? Image.network(
                                              job['thumbnailUrl'], 
                                              width: 120, 
                                              height: 68, // ~16:9 
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => _buildPlaceholder(),
                                            )
                                          : _buildPlaceholder(),
                                    ),
                                    const SizedBox(width: 16),
                                    // Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(title, 
                                            maxLines: 2, 
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14, height: 1.2)),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              _buildStatusChip(status),
                                              const SizedBox(width: 8),
                                              if (isDone) 
                                                Text('• $clipsCount clips', 
                                                  style: GoogleFonts.inter(color: context.colors.textSecondary, fontSize: 12)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isDone)
                                      Padding(
                                        padding: EdgeInsets.only(top: 24),
                                        child: Icon(Icons.chevron_right, color: context.colors.textMuted),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 120, height: 68,
      color: context.colors.bgDark,
      child: const Icon(Icons.video_file, color: Colors.white24, size: 32),
    );
  }

  Widget _buildStatusChip(String status) {
    final isDone = status == 'DONE';
    final isFailed = status == 'FAILED';
    final color = isDone ? context.colors.success : (isFailed ? context.colors.error : context.colors.warning);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(color: color, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}
