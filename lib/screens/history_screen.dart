import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/api_client.dart';
import '../core/constants.dart';
import 'package:google_fonts/google_fonts.dart';

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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('My History', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent))
          : _error != null 
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _jobs.isEmpty 
                  ? Center(
                      child: Text('No clips generated yet.', 
                        style: GoogleFonts.inter(color: Colors.white70, fontSize: 16)))
                  : ListView.builder(
                      itemCount: _jobs.length,
                      itemBuilder: (context, index) {
                        final job = _jobs[index];
                        final title = job['videoTitle']?.toString() ?? 'Processing Video...';
                        final status = job['status']?.toString() ?? 'QUEUED';
                        final clipsCount = job['clipsCount'] ?? 0;
                        final isDone = status == 'DONE';

                        return Card(
                          color: AppColors.bgSurface,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: job['thumbnailUrl'] != null && job['thumbnailUrl'].isNotEmpty
                                ? Image.network(
                                    job['thumbnailUrl'], 
                                    width: 80, 
                                    height: 45, 
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.video_file, color: Colors.white54, size: 40)
                                  )
                                : const Icon(Icons.video_file, color: Colors.white54, size: 40),
                            title: Text(title, 
                              maxLines: 1, 
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            subtitle: Text('Status: $status • Clips: $clipsCount', 
                              style: const TextStyle(color: Colors.white70)),
                            trailing: isDone 
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : const Icon(Icons.hourglass_empty, color: Colors.orange),
                          ),
                        );
                      },
                    ),
    );
  }
}
