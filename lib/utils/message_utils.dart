import 'package:flutter/material.dart';

class MessageUtils {
  static void showMessage(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    showMessage(context, message, isError: false);
  }

  static void showError(BuildContext context, String message) {
    showMessage(context, message, isError: true);
  }
} 