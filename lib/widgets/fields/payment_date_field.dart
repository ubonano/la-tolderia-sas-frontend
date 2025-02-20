import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import '../../controllers/pdf_viewer_controller.dart';

class PaymentDateField extends StatefulWidget {
  final DocumentSnapshot expense;

  final String collectionName;

  const PaymentDateField({
    super.key,
    required this.expense,
    required this.collectionName,
  });

  @override
  _PaymentDateFieldState createState() => _PaymentDateFieldState();
}

class _PaymentDateFieldState extends State<PaymentDateField> {
  late Timestamp paymentAt;

  @override
  void initState() {
    super.initState();
    final data = widget.expense.data() as Map<String, dynamic>;
    paymentAt = data['paymentAt'] ?? Timestamp.fromDate(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            'Fecha de pago:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.zero,
            child: Text(
              DateFormat('dd/MM/yyyy').format(paymentAt.toDate().toLocal()),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            if (kIsWeb) {
              PdfViewerController.to.isDisabled.value = true;
            }
            final docRef = FirebaseFirestore.instance.collection(widget.collectionName).doc(widget.expense.id);
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: paymentAt.toDate(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              locale: const Locale('es', 'ES'),
            );
            if (kIsWeb) {
              PdfViewerController.to.isDisabled.value = false;
            }
            if (picked != null) {
              await docRef.update({'paymentAt': Timestamp.fromDate(picked)});
              setState(() {
                paymentAt = Timestamp.fromDate(picked);
              });
            }
          },
        ),
      ],
    );
  }
}
