import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/beneficiary_service.dart';
import 'package:flutter/material.dart';

class BeneficiariesController extends GetxController {
  final RxList<DocumentSnapshot> beneficiaries = <DocumentSnapshot>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadBeneficiaries();
  }

  Future<void> loadBeneficiaries() async {
    List<DocumentSnapshot> beneficiariesList = await BeneficiaryService.getBeneficiariesDocuments();
    beneficiaries.assignAll(beneficiariesList);
  }

  Future<void> deleteBeneficiary(DocumentSnapshot beneficiary) async {
    try {
      await BeneficiaryService.deleteBeneficiary(beneficiary);
      beneficiaries.remove(beneficiary);
      Get.snackbar(
        'Beneficiario eliminado',
        'El beneficiario "${beneficiary['name']}" fue eliminado',
        backgroundColor: Colors.red.shade100,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar el beneficiario: $e',
        backgroundColor: Colors.red.shade100,
      );
    }
  }
} 