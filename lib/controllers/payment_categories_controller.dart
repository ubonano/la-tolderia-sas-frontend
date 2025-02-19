import 'package:get/get.dart';
import '../services/payment_category_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentCategoriesController extends GetxController {
  final RxList<DocumentSnapshot> paymentCategories = <DocumentSnapshot>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPaymentCategories();
  }

  Future<void> loadPaymentCategories() async {
    // Se obtiene la lista de categorías de pago desde el servicio
    List<DocumentSnapshot> categories = await PaymentCategoryService.getPaymentCategories();
    paymentCategories.assignAll(categories);
  }

  // Nuevo método para eliminar una categoría de pago.
  Future<void> deleteCategory(DocumentSnapshot category) async {
    try {
      await PaymentCategoryService.deletePaymentCategory(category);
      paymentCategories.remove(category);
      Get.snackbar(
        'Categoría eliminada',
        'La categoría "${category['name']}" fue eliminada',
        backgroundColor: Colors.red.shade100,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar la categoría: $e',
        backgroundColor: Colors.red.shade100,
      );
    }
  }
} 