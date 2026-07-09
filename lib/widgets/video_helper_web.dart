// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

/// Registers an HTML5 <video> element as a Flutter platform view (web-only).
void registerVideoView(String viewId, String src) {
  ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
    final video = html.VideoElement()
      ..src = src
      ..autoplay = true
      ..controls = true
      ..style.width  = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover'
      ..style.background = '#000';
    return video;
  });
}
