import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'google_button_stub.dart' if (dart.library.html) 'google_button_web.dart';

Widget buildGoogleSignInButton() {
  if (kIsWeb) {
    return buildWebButton();
  }
  // Fallback for non-web
  return const SizedBox.shrink();
}
