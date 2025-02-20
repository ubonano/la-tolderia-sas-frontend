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

  // Agrega un nuevo beneficiario con campos adicionales: CBU, Telefono, Email
  static Future<void> addBeneficiary(String name, String cbu, String phone, String email) async {
    await FirebaseFirestore.instance.collection('beneficiaries').add({
      'name': name,
      'cbu': cbu,
      'phone': phone,
      'email': email,
    });
  }

  // Actualiza los datos de un beneficiario
  static Future<void> updateBeneficiary(DocumentSnapshot beneficiary, String newName, String newCBU, String newPhone, String newEmail) async {
    await beneficiary.reference.update({
      'name': newName,
      'cbu': newCBU,
      'phone': newPhone,
      'email': newEmail,
    });
  }
} 