import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomDialog {
  static Future<void> showConfirmation({
    required String title,
    required String content,
    required Future<void> Function() onConfirm,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    Color confirmColor = Colors.green,
  }) async {
    await Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: Text(cancelLabel),
            onPressed: () => Get.back(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: confirmColor),
            child: Text(confirmLabel),
            onPressed: () async {
              Get.back();
              await onConfirm();
            },
          ),
        ],
      ),
    );
  }

  static void showProcessing() {
    Get.dialog(
      const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Procesando...'),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
