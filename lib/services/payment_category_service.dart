import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentCategoryService {
  static Future<List<String>> getPaymentCategories() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('payment_categories').get();
    final categories = snapshot.docs.map((doc) => (doc.data() as Map<String, dynamic>)['name'] as String).toList();
    return categories;
  }
}
