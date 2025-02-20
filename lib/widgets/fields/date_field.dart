import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import '../../controllers/pdf_viewer_controller.dart';

class DateField extends StatefulWidget {
  final DocumentSnapshot expense;
  final String collectionName;
  const DateField({super.key, required this.expense, required this.collectionName});

  @override
  _DateFieldState createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  late Timestamp date;

  @override
  void initState() {
    super.initState();
    date = widget.expense['date'] ?? Timestamp.now();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            'Fecha:',
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
              DateFormat('dd/MM/yyyy').format(date.toDate()),
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
              initialDate: date.toDate(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              locale: const Locale('es', 'ES'),
            );
            if (kIsWeb) {
              PdfViewerController.to.isDisabled.value = false;
            }
            if (picked != null) {
              await docRef.update({'date': Timestamp.fromDate(picked)});
              setState(() {
                date = Timestamp.fromDate(picked);
              });
            }
          },
        ),
      ],
    );
  }
} 