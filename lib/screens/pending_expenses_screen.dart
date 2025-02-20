import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../widgets/common/app_layout.dart';
import '../controllers/pending_expenses_controller.dart';
import '../widgets/expense/expense_detail_view.dart';

class PendingExpensesScreen extends GetView<PendingExpensesController> {
  const PendingExpensesScreen({super.key});

  // Función auxiliar para determinar el texto según la diferencia de días
  String _getDueDateInfo(DateTime dueDate) {
    final now = DateTime.now();
    // Usar solo la parte de la fecha sin horas
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

  // Función auxiliar para obtener el color del texto según la diferencia de días
  Color _getDueDateTextColor(DateTime dueDate) {
    final now = DateTime.now();
    final currentDate = DateTime(now.year, now.month, now.day);
    final diffDays = dueDate.difference(currentDate).inDays;
    if (diffDays < 0) {
      return Colors.red.shade700;
    } else if (diffDays == 0) {
      return Colors.amber.shade800;
    } else {
      return Colors.green.shade700;
    }
  }

  void _openExpenseDetailPopup(BuildContext context, QueryDocumentSnapshot expense) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.orange.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        insetPadding: const EdgeInsets.all(16),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.9,
          child: ExpenseDetailView(
            expense: expense,
            isRegistered: true,
            backgroundColor: Colors.orange.shade50,
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildColumnFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Columna Beneficiario (filtro)
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.only(right: 8.0),
              child: Obx(() => DropdownButton<String>(
                    isExpanded: true,
                    value: controller.selectedBeneficiary.value,
                    hint: const Text("Todos", style: TextStyle(fontSize: 16)),
                    items: controller.beneficiaryOptions
                        .map((beneficiary) => DropdownMenuItem<String>(
                              value: beneficiary,
                              child: Text(beneficiary.isEmpty ? "Todos" : beneficiary,
                                  style: const TextStyle(fontSize: 16)),
                            ))
                        .toList(),
                    onChanged: controller.updateBeneficiary,
                  )),
            ),
          ),
          // Columna Número sin filtro
          Expanded(flex: 2, child: Container()),
          // Columna Vencimiento sin filtro
          Expanded(flex: 2, child: Container()),
          // Columna Importe sin filtro
          Expanded(flex: 2, child: Container()),
          // Columna Categoría (filtro)
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.only(right: 8.0),
              child: Obx(() => DropdownButton<String>(
                    isExpanded: true,
                    value: controller.selectedCategoria.value,
                    hint: const Text("Todos", style: TextStyle(fontSize: 16)),
                    items: controller.categoriaOptions
                        .map((option) => DropdownMenuItem<String>(
                              value: option,
                              child: Text(option.isEmpty ? "Todos" : option, style: const TextStyle(fontSize: 16)),
                            ))
                        .toList(),
                    onChanged: controller.updateCategoria,
                  )),
            ),
          ),
          // Columna Acciones: botón para limpiar filtros
          Expanded(
            flex: 1,
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.clear),
                tooltip: 'Limpiar filtros',
                onPressed: controller.clearFilters,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      customTitle: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Gastos pendientes para ", style: TextStyle(fontSize: 18)),
          Obx(() => DropdownButton<int>(
                value: controller.selectedMonth.value,
                items: List.generate(12, (index) => index + 1)
                    .map((monthNumber) => DropdownMenuItem<int>(
                          value: monthNumber,
                          child: Text(controller.monthNames[monthNumber - 1], style: const TextStyle(fontSize: 18)),
                        ))
                    .toList(),
                onChanged: controller.updateMonth,
              )),
          const Text(" del ", style: TextStyle(fontSize: 18)),
          Obx(() => DropdownButton<int>(
                value: controller.selectedYear.value,
                items: controller.years
                    .map((year) => DropdownMenuItem<int>(
                          value: year,
                          child: Text(year.toString(), style: const TextStyle(fontSize: 18)),
                        ))
                    .toList(),
                onChanged: controller.updateYear,
              )),
        ],
      ),
      currentRoute: '/pending-expenses',
      backgroundColor: Colors.orange.shade50,
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
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Obx(() {
            // Forzamos la lectura de un valor observable para regenerar el stream
            // ignore: unused_local_variable
            final year = controller.selectedYear.value;
            return StreamBuilder<QuerySnapshot>(
              stream: controller.getPendingExpenses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final docs = snapshot.data?.docs ?? [];

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      key: const ValueKey('listViewPending'),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildColumnFilters(),
                              const SizedBox(height: 16),
                              Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(3),
                                  1: FlexColumnWidth(2),
                                  2: FlexColumnWidth(2),
                                  3: FlexColumnWidth(2),
                                  4: FlexColumnWidth(2),
                                  5: FlexColumnWidth(2),
                                  6: FlexColumnWidth(1),
                                },
                                border: TableBorder.all(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                children: [
                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                    ),
                                    children: const [
                                      TableCell(
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Beneficiario', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      TableCell(
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Número', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      TableCell(
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Vencimiento', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      TableCell(
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Tiempo', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      TableCell(
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Importe', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      TableCell(
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      TableCell(
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (docs.isEmpty)
                                    TableRow(
                                      children: List.generate(
                                          7,
                                          (index) => TableCell(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: index == 0
                                                      ? Text('No hay gastos pendientes', textAlign: TextAlign.center)
                                                      : const SizedBox.shrink(),
                                                ),
                                              )),
                                    )
                                  else
                                    ...docs.map((doc) {
                                      final data = doc.data() as Map<String, dynamic>;
                                      return TableRow(
                                        children: [
                                          TableCell(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(data['beneficiary'] ?? ''),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(data['number'] ?? ''),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                DateFormat('dd/MM/yyyy').format(data['dueDate'].toDate()),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                _getDueDateInfo(data['dueDate'].toDate()),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: _getDueDateTextColor(data['dueDate'].toDate()),
                                                ),
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                '\$ ${NumberFormat('#,##0.00', 'en_US').format(data['amount'])}',
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                (data['category'] == null || data['category'] == '')
                                                    ? 'No definido'
                                                    : data['category'],
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: IconButton(
                                                icon: const Icon(Icons.visibility),
                                                onPressed: () => _openExpenseDetailPopup(context, doc),
                                                tooltip: 'Ver detalle',
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
