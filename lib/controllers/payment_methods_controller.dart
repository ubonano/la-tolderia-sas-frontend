import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/payment_method_service.dart';
import 'package:flutter/material.dart';

class PaymentMethodsController extends GetxController {
  final RxList<DocumentSnapshot> paymentMethods = <DocumentSnapshot>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPaymentMethods();
  }

  Future<void> loadPaymentMethods() async {
    List<DocumentSnapshot> methods = await PaymentMethodService.getPaymentMethodsDocuments();
    paymentMethods.assignAll(methods);
  }

  Future<void> deleteMethod(DocumentSnapshot method) async {
    try {
      await PaymentMethodService.deletePaymentMethod(method);
      paymentMethods.remove(method);
      Get.snackbar(
        'Método eliminado',
        'El método "${method['name']}" fue eliminado',
        backgroundColor: Colors.red.shade100,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar el método: $e',
        backgroundColor: Colors.red.shade100,
      );
    }
  }
}
