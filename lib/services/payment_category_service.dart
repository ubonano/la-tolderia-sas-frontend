import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentCategoryService {
  static Future<List<DocumentSnapshot>> getPaymentCategories() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('payment_categories').get();
    return snapshot.docs;
  }

  static Future<void> deletePaymentCategory(DocumentSnapshot category) async {
    await category.reference.delete();
  }
}
