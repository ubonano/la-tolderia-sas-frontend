import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import '../../controllers/pdf_viewer_controller.dart';

class DueDateField extends StatefulWidget {
  final DocumentSnapshot expense;
  final String collectionName;

  const DueDateField({
    Key? key,
    required this.expense,
    required this.collectionName,
  }) : super(key: key);

  @override
  _DueDateFieldState createState() => _DueDateFieldState();
}

class _DueDateFieldState extends State<DueDateField> {
  late Timestamp dueDate;

  @override
  void initState() {
    super.initState();
    final data = widget.expense.data() as Map<String, dynamic>;
    // Si no existe 'dueDate', se usa la fecha actual
    dueDate = data['dueDate'] ?? Timestamp.fromDate(DateTime.now());
  }

  // Función auxiliar para obtener el estado de la fecha de vencimiento
  String _getDueDateInfo(DateTime dueDate) {
    final now = DateTime.now();
    // Considerar solo año, mes y día
    final currentDate = DateTime(now.year, now.month, now.day);
    final diffDays = dueDate.difference(currentDate).inDays;
    if (diffDays > 0) {
      return "Vence en $diffDays día${diffDays > 1 ? 's' : ''}";
    } else if (diffDays < 0) {
      return "Vencida (${diffDays.abs()} día${diffDays.abs() > 1 ? 's' : ''})";
    } else {
      return "Vence hoy";
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.expense.data() as Map<String, dynamic>;
    DateTime expenseDate = (data['date'] as Timestamp).toDate();
    DateTime currentDueDate = dueDate.toDate();
    bool dateError = currentDueDate.isBefore(expenseDate);
    return Row(
      children: [
        const SizedBox(
          width: 120,
          child: Text(
            'Vencimiento:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Expanded(
          child: Text(
            DateFormat('dd/MM/yyyy').format(currentDueDate.toLocal()),
            style: const TextStyle(fontSize: 16),
          ),
        ),
        // Se agrega texto al costado que muestre el estado de la fecha de vencimiento
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            _getDueDateInfo(currentDueDate),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        if (dateError)
          Tooltip(
            message: 'La fecha de vencimiento no puede ser menor a la fecha del gasto',
            child: const Icon(Icons.error, color: Colors.red, size: 20),
          ),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            if (kIsWeb) {
              PdfViewerController.to.isDisabled.value = true;
            }
            final docRef = FirebaseFirestore.instance
                .collection(widget.collectionName)
                .doc(widget.expense.id);
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: currentDueDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              locale: const Locale('es', 'ES'),
            );
            if (kIsWeb) {
              PdfViewerController.to.isDisabled.value = false;
            }
            if (picked != null) {
              await docRef.update({'dueDate': Timestamp.fromDate(picked)});
              setState(() {
                dueDate = Timestamp.fromDate(picked);
              });
            }
          },
        ),
      ],
    );
  }
} 