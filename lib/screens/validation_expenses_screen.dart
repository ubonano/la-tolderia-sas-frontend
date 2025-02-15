import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/expense/expense_card.dart';
import '../widgets/expense/expense_detail_view.dart';
import '../widgets/common/app_layout.dart';

// Esta pantalla muestra la lista de gastos en validación
class ValidationExpensesScreen extends StatefulWidget {
  const ValidationExpensesScreen({super.key});

  @override
  _ValidationExpensesScreenState createState() => _ValidationExpensesScreenState();
}

class _ValidationExpensesScreenState extends State<ValidationExpensesScreen> {
  void _openExpenseDetailPopup(QueryDocumentSnapshot expense, bool isRegistered) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.lightGreen.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        insetPadding: const EdgeInsets.all(16),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.9,
          child: ExpenseDetailView(
            expense: expense,
            isRegistered: isRegistered,
            backgroundColor: Colors.lightGreen.shade50,
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Validacion de gastos',
      currentRoute: '/validation-expenses',
      backgroundColor: Colors.lightGreen.shade50,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: StreamBuilder<QuerySnapshot>(
            key: const ValueKey('listViewValidation'),
            stream:
                FirebaseFirestore.instance.collection('expenses').orderBy('createdAt', descending: false).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No hay gastos disponibles'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  final expense = snapshot.data!.docs[index];
                  return ExpenseCard(
                    expense: expense,
                    onTap: _openExpenseDetailPopup,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
