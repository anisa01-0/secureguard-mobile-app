import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// What happened when the app tried to place a call or send a message.
enum DialResult {
  /// The platform dialler / SMS app opened.
  launched,

  /// The platform has no dialler (desktop, web, most emulators). The caller
  /// shows a clearly labelled demo confirmation instead.
  unsupported,

  /// Something went wrong while opening the dialler.
  failed,
}

/// Opens the device dialler and SMS composer.
///
/// On a real phone the call button opens the dialler with the number already
/// entered - the app never dials automatically, so the user always stays in
/// control. On a desktop, a browser or an emulator without telephony the
/// service reports [DialResult.unsupported] and the UI falls back to a demo
/// dialog.
class DialerService {
  const DialerService();

  Future<DialResult> call(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: _clean(phoneNumber));
    return _launch(uri);
  }

  Future<DialResult> sendSms(String phoneNumber, String body) async {
    final Uri uri = Uri(
      scheme: 'sms',
      path: _clean(phoneNumber),
      queryParameters: <String, String>{'body': body},
    );
    return _launch(uri);
  }

  Future<DialResult> openLink(String url) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return DialResult.failed;
    return _launch(uri, mode: LaunchMode.externalApplication);
  }

  Future<DialResult> _launch(
    Uri uri, {
    LaunchMode mode = LaunchMode.platformDefault,
  }) async {
    try {
      if (!await canLaunchUrl(uri)) return DialResult.unsupported;
      final bool ok = await launchUrl(uri, mode: mode);
      return ok ? DialResult.launched : DialResult.failed;
    } on MissingPluginException {
      // Happens in widget tests and on platforms without the plugin.
      return DialResult.unsupported;
    } catch (error) {
      debugPrint('SecureGuard: could not open $uri ($error).');
      return DialResult.failed;
    }
  }

  /// Strips spaces, dashes and brackets so the dialler receives clean digits.
  String _clean(String phoneNumber) =>
      phoneNumber.replaceAll(RegExp(r'[\s\-()]'), '');
}
