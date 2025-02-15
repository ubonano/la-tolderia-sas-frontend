import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExpenseCard extends StatelessWidget {
  final QueryDocumentSnapshot expense;
  final Function(QueryDocumentSnapshot, bool) onTap;

  const ExpenseCard({
    super.key,
    required this.expense,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final expenseData = expense.data() as Map<String, dynamic>;
    // print(expenseData);
    final String fileName = expenseData['fileName'];
    final String titleText = fileName.contains('.') ? fileName.substring(0, fileName.lastIndexOf('.')) : fileName;
    final Icon leadingIcon = (expense['error'] != null && expense['error'].isNotEmpty)
        ? const Icon(Icons.error, color: Colors.red)
        : (expense['warnings'] != null && expense['warnings'].isNotEmpty)
            ? const Icon(Icons.warning, color: Colors.yellow)
            : const Icon(Icons.check_circle, color: Colors.green);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 2.0,
      child: ListTile(
        leading: leadingIcon,
        title: Text(titleText),
        onTap: () {
          onTap(expense, false);
        },
      ),
    );
  }
}
