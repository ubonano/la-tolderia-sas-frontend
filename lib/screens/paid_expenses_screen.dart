import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../widgets/common/app_layout.dart';
import '../controllers/paid_expenses_controller.dart';
import '../widgets/expense/expense_detail_view.dart';

class PaidExpensesScreen extends GetView<PaidExpensesController> {
  const PaidExpensesScreen({super.key});

  // Función para abrir el detalle del gasto
  void _openExpenseDetailPopup(BuildContext context, QueryDocumentSnapshot expense) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.green.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        insetPadding: const EdgeInsets.all(16),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.9,
          child: ExpenseDetailView(
            expense: expense,
            isRegistered: true,
            backgroundColor: Colors.green.shade50,
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Filtro de columnas que incluye un dropdown para método de pago
  Widget _buildColumnFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Filtro por Emisor
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.only(right: 8.0),
              child: Obx(() => DropdownButton<String>(
                    isExpanded: true,
                    value: controller.filterIssuer.value,
                    hint: const Text("Todos", style: TextStyle(fontSize: 16)),
                    items: <String>["", "Emisor A", "Emisor B", "Emisor C"]
                        .map((issuer) => DropdownMenuItem<String>(
                              value: issuer,
                              child: Text(issuer.isEmpty ? "Todos" : issuer, style: const TextStyle(fontSize: 16)),
                            ))
                        .toList(),
                    onChanged: controller.updateIssuer,
                  )),
            ),
          ),
          // Columna Número (sin filtro)
          const Expanded(flex: 2, child: SizedBox()),
          // Columna Fecha (sin filtro)
          const Expanded(flex: 2, child: SizedBox()),
          // Columna Importe (sin filtro)
          const Expanded(flex: 2, child: SizedBox()),
          // Filtro por Categoría
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
          // Filtro por Método de pago
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.only(right: 8.0),
              child: Obx(() => DropdownButton<String>(
                    isExpanded: true,
                    value: controller.selectedPaymentMethod.value,
                    hint: const Text("Todos", style: TextStyle(fontSize: 16)),
                    items: controller.paymentMethodOptions
                        .map((option) => DropdownMenuItem<String>(
                              value: option,
                              child: Text(option.isEmpty ? "Todos" : option, style: const TextStyle(fontSize: 16)),
                            ))
                        .toList(),
                    onChanged: controller.updatePaymentMethod,
                  )),
            ),
          ),
          // Botón para limpiar filtros
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
          const Text("Gastos pagados para ", style: TextStyle(fontSize: 18)),
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
      currentRoute: '/paid-expenses',
      backgroundColor: Colors.green.shade50,
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
            return StreamBuilder<QuerySnapshot>(
              stream: controller.getPaidExpenses(),
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
                      key: const ValueKey('listViewPaid'),
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
                                  0: FlexColumnWidth(3), // Emisor
                                  1: FlexColumnWidth(2), // Número
                                  2: FlexColumnWidth(2), // Fecha de factura
                                  3: FlexColumnWidth(2), // Importe
                                  4: FlexColumnWidth(2), // Categoría
                                  5: FlexColumnWidth(2), // Método de pago
                                  6: FlexColumnWidth(1), // Acciones
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
                                              child: Text('Emisor', style: TextStyle(fontWeight: FontWeight.bold)))),
                                      TableCell(
                                          child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text('Número', style: TextStyle(fontWeight: FontWeight.bold)))),
                                      TableCell(
                                          child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold)))),
                                      TableCell(
                                          child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text('Importe', style: TextStyle(fontWeight: FontWeight.bold)))),
                                      TableCell(
                                          child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold)))),
                                      TableCell(
                                          child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text('Método de pago',
                                                  style: TextStyle(fontWeight: FontWeight.bold)))),
                                      TableCell(
                                          child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold)))),
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
                                                      ? const Text('No hay gastos pagados', textAlign: TextAlign.center)
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
                                              child: Text(data['issuer'] ?? ''),
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
                                                DateFormat('dd/MM/yyyy').format(data['date'].toDate()),
                                                textAlign: TextAlign.center,
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
                                              child: Text(
                                                data['paymentMethod'] == null ? 'No definido' : data['paymentMethod'],
                                                textAlign: TextAlign.center,
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
