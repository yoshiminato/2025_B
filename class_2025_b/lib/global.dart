import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

String replaceHostInUrl(String url, String newHost) {
  // http(s)://[IP or host]:[port]/
  final reg = RegExp(r'^(https?://)([^:/]+)(:\\d+)?');
  return url.replaceFirstMapped(reg, (m) {
    final scheme = m.group(1) ?? '';
    final port = m.group(3) ?? '';
    return '$scheme$newHost$port';
  });
}

// Web/Android用: 10.0.2.2→hostingIP 変換
String fixEmulatorUrlForWeb(String url) {
  if (kIsWeb) {
    // Webの場合はhostingIPに変換
    return replaceHostInUrl(url, hostingIP);
  } else {
    try {
      if (Platform.isAndroid) {
        // Android実機の場合もhostingIPに変換
        return replaceHostInUrl(url, hostingIPForAndroidEmulator);
      }
    } catch (_) {
      // WebではPlatformは使えないので例外を握りつぶす
    }
  }
  return url;
}

const hostingIP = "192.168.10.110";
const hostingIPForAndroidEmulator = "10.0.2.2";