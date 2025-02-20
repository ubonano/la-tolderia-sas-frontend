import 'package:cloud_firestore/cloud_firestore.dart';

class BeneficiaryService {
  // Obtiene los documentos de la colección 'beneficiaries'
  static Future<List<DocumentSnapshot>> getBeneficiariesDocuments() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('beneficiaries').get();
    return snapshot.docs;
  }

  // Elimina un beneficiario dado su DocumentSnapshot
  static Future<void> deleteBeneficiary(DocumentSnapshot beneficiary) async {
    await beneficiary.reference.delete();
  }

  // Agrega un nuevo beneficiario
  static Future<void> addBeneficiary(String name) async {
    await FirebaseFirestore.instance.collection('beneficiaries').add({'name': name});
  }

  // Actualiza el nombre de un beneficiario
  static Future<void> updateBeneficiary(DocumentSnapshot beneficiary, String newName) async {
    await beneficiary.reference.update({'name': newName});
  }
} 