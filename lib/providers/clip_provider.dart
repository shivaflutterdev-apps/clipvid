import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/api_client.dart';

enum AppState { idle, processing, done, failed }

/// Central state for the clip generation workflow.
class ClipProvider extends ChangeNotifier {
  final ApiClient _api;

  ClipProvider(this._api);

  // ── State ───────────────────────────────────────────────────────────────────
  AppState      _appState    = AppState.idle;
  String        _jobId       = '';
  String        _statusMsg   = '';
  int           _progress    = 0;
  String        _jobStatus   = '';    // raw backend status string
  String        _videoTitle  = '';
  String        _errorMsg    = '';
  List<ClipItem> _clips      = [];
  Timer?        _pollTimer;

  // ── Getters ──────────────────────────────────────────────────────────────────
  AppState       get appState   => _appState;
  String         get jobId      => _jobId;
  String         get statusMsg  => _statusMsg;
  int            get progress   => _progress;
  String         get jobStatus  => _jobStatus;
  String         get videoTitle => _videoTitle;
  String         get errorMsg   => _errorMsg;
  List<ClipItem> get clips      => _clips;
  bool           get isIdle      => _appState == AppState.idle;
  bool           get isProcessing=> _appState == AppState.processing;
  bool           get isDone      => _appState == AppState.done;
  bool           get isFailed    => _appState == AppState.failed;

  // ── Submit ───────────────────────────────────────────────────────────────────

  Future<void> submitUrl(String youtubeUrl, {
    int? maxClips,
    int? minDurationSec,
    int? maxDurationSec,
  }) async {
    _reset();
    _appState  = AppState.processing;
    _statusMsg = 'Submitting job...';
    notifyListeners();

    try {
      _jobId = await _api.submitJob(
        youtubeUrl:    youtubeUrl,
        maxClips:      maxClips,
        minDurationSec:minDurationSec,
        maxDurationSec:maxDurationSec,
      );
      _startPolling();
    } catch (e) {
      _appState  = AppState.failed;
      _errorMsg  = e.toString();
      _statusMsg = 'Failed to submit';
      notifyListeners();
    }
  }

  // ── Polling ──────────────────────────────────────────────────────────────────

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
  }

  Future<void> _poll() async {
    if (_jobId.isEmpty) return;
    try {
      final status = await _api.getStatus(_jobId);
      _progress   = status.progress;
      _statusMsg  = status.statusMessage;
      _jobStatus  = status.status;
      _videoTitle = status.videoTitle;

      if (status.isDone) {
        _pollTimer?.cancel();
        await _fetchResults();
      } else if (status.isFailed) {
        _pollTimer?.cancel();
        _appState  = AppState.failed;
        _errorMsg  = status.error ?? 'Processing failed';
        notifyListeners();
      } else {
        notifyListeners();
      }
    } catch (e) {
      // Network blip — keep polling
      debugPrint('Poll error: $e');
    }
  }

  Future<void> _fetchResults() async {
    try {
      final results = await _api.getResults(_jobId);
      _clips    = results.clips;
      _appState = AppState.done;
      notifyListeners();
    } catch (e) {
      _appState = AppState.failed;
      _errorMsg = 'Failed to load results: $e';
      notifyListeners();
    }
  }

  // ── Reset ────────────────────────────────────────────────────────────────────

  void reset() {
    // Optionally delete server job
    if (_jobId.isNotEmpty) {
      _api.deleteJob(_jobId).catchError((_) {});
    }
    _reset();
    notifyListeners();
  }

  void _reset() {
    _pollTimer?.cancel();
    _pollTimer  = null;
    _appState   = AppState.idle;
    _jobId      = '';
    _statusMsg  = '';
    _progress   = 0;
    _jobStatus  = '';
    _videoTitle = '';
    _errorMsg   = '';
    _clips      = [];
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  // ── URL helpers ───────────────────────────────────────────────────────────────
  String thumbnailUrl(ClipItem clip) => _api.thumbnailUrl(_jobId, clip.thumbnailFilename);
  String downloadUrl(ClipItem clip)  => _api.downloadUrl(_jobId, clip.filename);
  String streamUrl(ClipItem clip)    => _api.streamUrl(_jobId, clip.filename);
}
