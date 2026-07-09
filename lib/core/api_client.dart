import 'dart:convert';
import 'package:http/http.dart' as http;

/// Centralised HTTP client for all backend API calls.
class ApiClient {
  // Change this to your Spring Boot backend URL
  static const String baseUrl = 'http://localhost:8080';

  final http.Client _client;

  ApiClient() : _client = http.Client();

  // ── Job submission ──────────────────────────────────────────────────────────

  /// Submit a YouTube URL for processing.
  /// Returns the jobId string.
  Future<String> submitJob({
    required String youtubeUrl,
    int? maxClips,
    int? minDurationSec,
    int? maxDurationSec,
  }) async {
    final body = <String, dynamic>{'youtubeUrl': youtubeUrl};
    if (maxClips       != null) body['maxClips']       = maxClips;
    if (minDurationSec != null) body['minDurationSec'] = minDurationSec;
    if (maxDurationSec != null) body['maxDurationSec'] = maxDurationSec;

    final response = await _client.post(
      Uri.parse('$baseUrl/api/clip'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 202) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['jobId'] as String;
    } else {
      final err = _parseError(response);
      throw ApiException('Failed to submit job: $err', response.statusCode);
    }
  }

  // ── Status polling ──────────────────────────────────────────────────────────

  /// Poll job status. Returns a [JobStatusResponse].
  Future<JobStatusResponse> getStatus(String jobId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/clip/$jobId/status'),
    );

    if (response.statusCode == 200) {
      return JobStatusResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else if (response.statusCode == 404) {
      throw ApiException('Job not found', 404);
    } else {
      throw ApiException('Status check failed', response.statusCode);
    }
  }

  // ── Results ─────────────────────────────────────────────────────────────────

  /// Fetch the list of generated clips for a DONE job.
  Future<ClipResultsResponse> getResults(String jobId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/clip/$jobId/results'),
    );

    if (response.statusCode == 200) {
      return ClipResultsResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw ApiException('Failed to fetch results', response.statusCode);
    }
  }

  // ── Cleanup ──────────────────────────────────────────────────────────────────

  /// Delete a job and its files from the server.
  Future<void> deleteJob(String jobId) async {
    await _client.delete(Uri.parse('$baseUrl/api/clip/$jobId'));
  }

  // ── URL helpers ──────────────────────────────────────────────────────────────

  String thumbnailUrl(String jobId, String filename) =>
      '$baseUrl/api/clip/$jobId/thumbnail/$filename';

  String downloadUrl(String jobId, String filename) =>
      '$baseUrl/api/clip/$jobId/download/$filename';

  String streamUrl(String jobId, String filename) =>
      '$baseUrl/api/clip/$jobId/stream/$filename';

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _parseError(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['message'] ?? data['error'] ?? response.body;
    } catch (_) {
      return response.body;
    }
  }
}

// ── Response models ──────────────────────────────────────────────────────────

class ApiException implements Exception {
  final String message;
  final int    statusCode;
  ApiException(this.message, this.statusCode);
  @override String toString() => 'ApiException[$statusCode]: $message';
}

class JobStatusResponse {
  final String jobId;
  final String status;          // QUEUED | DOWNLOADING | TRANSCRIBING | SCORING | CLIPPING | DONE | FAILED
  final int    progress;        // 0-100
  final String statusMessage;
  final String videoTitle;
  final String thumbnailUrl;
  final int    videoDuration;
  final String? error;

  JobStatusResponse({
    required this.jobId,
    required this.status,
    required this.progress,
    required this.statusMessage,
    required this.videoTitle,
    required this.thumbnailUrl,
    required this.videoDuration,
    this.error,
  });

  factory JobStatusResponse.fromJson(Map<String, dynamic> json) {
    return JobStatusResponse(
      jobId:         json['jobId']         as String? ?? '',
      status:        json['status']        as String? ?? 'QUEUED',
      progress:      json['progress']      as int?    ?? 0,
      statusMessage: json['statusMessage'] as String? ?? '',
      videoTitle:    json['videoTitle']    as String? ?? '',
      thumbnailUrl:  json['thumbnailUrl']  as String? ?? '',
      videoDuration: json['videoDuration'] as int?    ?? 0,
      error:         json['error']         as String?,
    );
  }

  bool get isDone   => status == 'DONE';
  bool get isFailed => status == 'FAILED';
}

class ClipResultsResponse {
  final bool             ready;
  final String           jobId;
  final String           videoTitle;
  final List<ClipItem>   clips;

  ClipResultsResponse({
    required this.ready,
    required this.jobId,
    required this.videoTitle,
    required this.clips,
  });

  factory ClipResultsResponse.fromJson(Map<String, dynamic> json) {
    final clipsJson = json['clips'] as List<dynamic>? ?? [];
    return ClipResultsResponse(
      ready:      json['ready']      as bool?   ?? false,
      jobId:      json['jobId']      as String? ?? '',
      videoTitle: json['videoTitle'] as String? ?? '',
      clips:      clipsJson.map((c) => ClipItem.fromJson(c as Map<String, dynamic>)).toList(),
    );
  }
}

class ClipItem {
  final String filename;
  final String thumbnailFilename;
  final double startSec;
  final double endSec;
  final double durationSec;
  final double viralScore;
  final String title;
  final String hook;
  final String downloadUrl;
  final String thumbnailUrl;

  ClipItem({
    required this.filename,
    required this.thumbnailFilename,
    required this.startSec,
    required this.endSec,
    required this.durationSec,
    required this.viralScore,
    required this.title,
    required this.hook,
    required this.downloadUrl,
    required this.thumbnailUrl,
  });

  factory ClipItem.fromJson(Map<String, dynamic> json) {
    return ClipItem(
      filename:          json['filename']          as String? ?? '',
      thumbnailFilename: json['thumbnailFilename'] as String? ?? '',
      startSec:          (json['startSec']         as num?    ?? 0).toDouble(),
      endSec:            (json['endSec']            as num?    ?? 0).toDouble(),
      durationSec:       (json['durationSec']       as num?    ?? 0).toDouble(),
      viralScore:        (json['viralScore']        as num?    ?? 0).toDouble(),
      title:             json['title']             as String? ?? 'Viral Clip',
      hook:              json['hook']              as String? ?? '',
      downloadUrl:       json['downloadUrl']       as String? ?? '',
      thumbnailUrl:      json['thumbnailUrl']      as String? ?? '',
    );
  }

  String formattedDuration() {
    final total = durationSec.round();
    final m = total ~/ 60;
    final s = total % 60;
    return '${m}:${s.toString().padLeft(2, '0')}';
  }
}
