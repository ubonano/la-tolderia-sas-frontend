import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'stat_card.dart';

class StatsRow extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;
  final bool showPaymentMethods;

  const StatsRow({
    super.key,
    required this.docs,
    this.showPaymentMethods = true,
  });

  @override
  Widget build(BuildContext context) {
    final totalAmount = docs.fold(0.0, (sum, doc) {
      final data = doc.data() as Map<String, dynamic>;
      return sum + (data['amount'] ?? 0.0);
    });

    final paidDocs = docs.where((doc) => doc['paymentStatus'] == 'Pagado');
    final pendingDocs = docs.where((doc) => doc['paymentStatus'] != 'Pagado');

    final paidAmount = paidDocs.fold(0.0, (sum, doc) => sum + (doc['amount'] ?? 0.0));
    final pendingAmount = pendingDocs.fold(0.0, (sum, doc) => sum + (doc['amount'] ?? 0.0));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard(
                'Total comprometido',
                '\$ ${NumberFormat('#,##0.00', 'es_CO').format(totalAmount)}',
                backgroundColor: Colors.blue.shade100,
              ),
              _buildStatCard(
                'Total pagado (${(paidAmount / totalAmount * 100).toStringAsFixed(1)}%) (${paidDocs.length})',
                '\$ ${NumberFormat('#,##0.00', 'es_CO').format(paidAmount)}',
                backgroundColor: Colors.blue.shade100,
              ),
              _buildStatCard(
                'Total pendiente (${(pendingAmount / totalAmount * 100).toStringAsFixed(1)}%) (${pendingDocs.length})',
                '\$ ${NumberFormat('#,##0.00', 'es_CO').format(pendingAmount)}',
                backgroundColor: Colors.blue.shade100,
              ),
            ],
          ),
        ),
        if (showPaymentMethods)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.spaceEvenly,
              children: _buildPaymentMethodStats(docs),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.spaceEvenly,
            children: _buildCategoryStats(docs),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildPaymentMethodStats(List<QueryDocumentSnapshot> docs) {
    final totalGastado = docs.fold(0.0, (sum, doc) {
      final data = doc.data() as Map<String, dynamic>;
      return sum + (data['amount'] ?? 0.0);
    });

    final Map<String, double> totals = {};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final method = data['paymentMethod'] ?? 'No definido';
      totals[method] = (totals[method] ?? 0.0) + (data['amount'] ?? 0.0);
    }

    final sortedEntries = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.map((entry) {
      final percentage = (entry.value / totalGastado * 100);
      return StatCard(
        title: '${entry.key} (${percentage.toStringAsFixed(1)}%)',
        value: '\$ ${NumberFormat('#,##0.00', 'es_CO').format(entry.value)}',
        titleColor: entry.key == 'No definido' ? Colors.grey : null,
        backgroundColor: Colors.green.shade100,
      );
    }).toList();
  }

  List<Widget> _buildCategoryStats(List<QueryDocumentSnapshot> docs) {
    final totalAmount = docs.fold(0.0, (sum, doc) {
      final data = doc.data() as Map<String, dynamic>;
      return sum + (data['amount'] ?? 0.0);
    });

    final Map<String, double> totals = {};
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      String category = data['category'] ?? 'No definido';
      if (category.isEmpty) {
        category = 'No definido';
      }
      totals[category] = (totals[category] ?? 0.0) + (data['amount'] ?? 0.0);
    }

    final sortedEntries = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.map((entry) {
      final percentage = (entry.value / totalAmount) * 100;
      return StatCard(
        title: '${entry.key} (${percentage.toStringAsFixed(1)}%)',
        value: '\$ ${NumberFormat('#,##0.00', 'es_CO').format(entry.value)}',
        backgroundColor: Colors.amber.shade100,
        titleColor: entry.key == 'No definido' ? Colors.grey : null,
      );
    }).toList();
  }

  Widget _buildStatCard(String title, String value, {Color? backgroundColor}) {
    final RegExp regex = RegExp(r'(.*?)(\s*\(([\d.]+)%\))?\s*\((\d+)\)');
    final match = regex.firstMatch(title);
    final mainTitle = match?.group(1) ?? title;
    final percentage = match?.group(3);
    final count = match?.group(4);

    return StatCard(
      title: mainTitle,
      value: value,
      percentage: percentage,
      count: count,
      backgroundColor: backgroundColor,
    );
  }
} 