class PaymentCategory {
  final String id;
  final String name;

  PaymentCategory({required this.id, required this.name});

  factory PaymentCategory.fromSnapshot(dynamic doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentCategory(
      id: doc.id,
      name: data['name'] ?? '',
    );
  }
}
