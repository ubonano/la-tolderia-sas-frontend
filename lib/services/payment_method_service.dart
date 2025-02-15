import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentMethodService {
  static Future<List<String>> getPaymentMethods() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('payment_methods').get();
    return snapshot.docs.map((doc) => (doc.data() as Map<String, dynamic>)['name'] as String).toList();
  }
}
