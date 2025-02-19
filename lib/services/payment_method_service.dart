import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentMethodService {
  // Obtiene los documentos de la colección 'payment_methods'
  static Future<List<DocumentSnapshot>> getPaymentMethodsDocuments() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('payment_methods').get();
    return snapshot.docs;
  }

  // Elimina un método de pago dado su DocumentSnapshot
  static Future<void> deletePaymentMethod(DocumentSnapshot method) async {
    await method.reference.delete();
  }

  // Agrega un nuevo método de pago
  static Future<void> addPaymentMethod(String name) async {
    await FirebaseFirestore.instance.collection('payment_methods').add({'name': name});
  }

  // Actualiza el nombre de un método de pago
  static Future<void> updatePaymentMethod(DocumentSnapshot method, String newName) async {
    await method.reference.update({'name': newName});
  }
}
