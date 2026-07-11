import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
// http://localhost:8080
//Platform.isAndroid): 'http://10.0.2.2:8080';
//Oracle: 'http://68.233.104.158:8080';

/// Centralised HTTP client for all backend API calls.
class ApiClient {
  static String get baseUrl {
    // Return the Public IP of the Oracle Cloud server
    // return 'http://10.0.2.2:8080';
    return 'http://68.233.104.158:8080';
    // return 'http://localhost:8080';
  }


  final http.Client _client;
  String? _token;

  ApiClient() : _client = http.Client();

  void setToken(String token) => _token = token;
  void clearToken() => _token = null;

  Map<String, String> get _headers {
    final h = {'Content-Type': 'application/json'};
    if (_token != null) h['Authorization'] = 'Bearer $_token';
    return h;
  }

  // ── Auth ────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _client.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw ApiException(_parseError(res), res.statusCode);
  }

  Future<Map<String, dynamic>> register(String email, String password, String name) async {
    final res = await _client.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'name': name}),
    );
    if (res.statusCode == 201) return jsonDecode(res.body);
    throw ApiException(_parseError(res), res.statusCode);
  }

  Future<dynamic> getCurrentUser() async {
    final res = await _client.get(
      Uri.parse('$baseUrl/api/auth/me'),
      headers: _headers,
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw ApiException('Unauthorized', res.statusCode);
  }

  Future<void> logout() async {
    await _client.post(Uri.parse('$baseUrl/api/auth/logout'), headers: _headers);
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final res = await _client.post(
      Uri.parse('$baseUrl/api/auth/change-password'),
      headers: _headers,
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword
      }),
    );
    if (res.statusCode != 200) {
      throw ApiException(_parseError(res), res.statusCode);
    }
  }

  Future<void> deleteAccount() async {
    final res = await _client.delete(
      Uri.parse('$baseUrl/api/auth/account'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw ApiException(_parseError(res), res.statusCode);
    }
  }

  // ── Job submission ──────────────────────────────────────────────────────────

  /// Submit a YouTube URL for processing.
  /// Returns the jobId string.
  Future<String> submitJob({
    required String youtubeUrl,
    int? maxClips,
    int? minDurationSec,
    int? maxDurationSec,
    String aspectRatio = '9:16',
    bool autoCaptions = false,
    String captionFont = 'Arial',
    int captionSize = 24,
    String captionColor = '#FFFFFF',
    String? language,
  }) async {
    final body = <String, dynamic>{
      'youtubeUrl': youtubeUrl,
      'aspectRatio': aspectRatio,
      'autoCaptions': autoCaptions,
      'captionFont': captionFont,
      'captionSize': captionSize,
      'captionColor': captionColor,
    };
    if (language != null && language.trim().isNotEmpty) {
      body['language'] = language.trim();
    }
    if (maxClips       != null) body['maxClips']       = maxClips;
    if (minDurationSec != null) body['minDurationSec'] = minDurationSec;
    if (maxDurationSec != null) body['maxDurationSec'] = maxDurationSec;

    final response = await _client.post(
      Uri.parse('$baseUrl/api/clip'),
      headers: _headers,
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
      headers: _headers,
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
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return ClipResultsResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw ApiException('Failed to fetch results', response.statusCode);
    }
  }
  
  /// Fetch past jobs
  Future<List<dynamic>> getHistory() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/clip/history'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['jobs'] as List<dynamic>;
    }
    throw ApiException('Failed to load history', response.statusCode);
  }

  // ── Cleanup ──────────────────────────────────────────────────────────────────

  /// Delete a job and its files from the server.
  Future<void> deleteJob(String jobId) async {
    await _client.delete(Uri.parse('$baseUrl/api/clip/$jobId'), headers: _headers);
  }

  // ── Audio Tools ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> generateTts(String text) async {
    final res = await _client.post(
      Uri.parse('$baseUrl/api/audio/tts'),
      headers: _headers,
      body: jsonEncode({'text': text}),
    );
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      // Ensure the URL is absolute
      final url = json['url'] as String;
      json['url'] = url.startsWith('http') ? url : '$baseUrl$url';
      return json;
    }
    throw ApiException(_parseError(res), res.statusCode);
  }

  Future<Map<String, dynamic>> transcribeAudio(Uint8List bytes, String fileName) async {
    final uri = Uri.parse('$baseUrl/api/audio/stt');
    final request = http.MultipartRequest('POST', uri);
    
    if (_token != null) request.headers['Authorization'] = 'Bearer $_token';

    request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));

    final streamedResponse = await request.send();
    final res = await http.Response.fromStream(streamedResponse);

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw ApiException(_parseError(res), res.statusCode);
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
  final String           aspectRatio;
  final List<ClipItem>   clips;

  ClipResultsResponse({
    required this.ready,
    required this.jobId,
    required this.videoTitle,
    required this.aspectRatio,
    required this.clips,
  });

  factory ClipResultsResponse.fromJson(Map<String, dynamic> json) {
    final clipsJson = json['clips'] as List<dynamic>? ?? [];
    return ClipResultsResponse(
      ready:       json['ready']       as bool?   ?? false,
      jobId:       json['jobId']       as String? ?? '',
      videoTitle:  json['videoTitle']  as String? ?? '',
      aspectRatio: json['aspectRatio'] as String? ?? '9:16',
      clips:       clipsJson.map((c) => ClipItem.fromJson(c as Map<String, dynamic>)).toList(),
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
      downloadUrl:       _formatUrl(json['downloadUrl'] as String?),
      thumbnailUrl:      _formatUrl(json['thumbnailUrl'] as String?),
    );
  }

  static String _formatUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    // Prefix with local backend URL if it's a relative path (e.g. S3 fallback)
    return '${ApiClient.baseUrl}$url';
  }

  String formattedDuration() {
    final total = durationSec.round();
    final m = total ~/ 60;
    final s = total % 60;
    return '${m}:${s.toString().padLeft(2, '0')}';
  }
}
