import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../widgets/common/app_layout.dart';
import '../controllers/registered_expenses_controller.dart';
import '../widgets/expense/expense_detail_view.dart';

class RegisteredExpensesScreen extends GetView<RegisteredExpensesController> {
  const RegisteredExpensesScreen({super.key});

  void _openExpenseDetailPopup(BuildContext context, QueryDocumentSnapshot expense) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.lightBlue.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        insetPadding: const EdgeInsets.all(16),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.9,
          child: ExpenseDetailView(
            expense: expense,
            isRegistered: true,
            backgroundColor: Colors.lightBlue.shade50,
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      customTitle: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Gastos registrados en ", style: TextStyle(fontSize: 18)),
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
      currentRoute: '/registered-expenses',
      backgroundColor: Colors.lightBlue.shade50,
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
            // Forzamos la lectura de un valor observable para re-generar el stream
            // ignore: unused_local_variable
            final year = controller.selectedYear.value;
            return StreamBuilder<QuerySnapshot>(
              stream: controller.getRegisteredExpenses(),
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
                      key: const ValueKey('listViewRegistered'),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildColumnFilters(controller),
                              const SizedBox(height: 16),
                              Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(3),
                                  1: FlexColumnWidth(2),
                                  2: FlexColumnWidth(2),
                                  3: FlexColumnWidth(2),
                                  4: FlexColumnWidth(2),
                                  5: FlexColumnWidth(2),
                                  6: FlexColumnWidth(2),
                                  7: FlexColumnWidth(1),
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
                                          child: Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                          child: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      TableCell(
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Método', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                          8,
                                          (index) => TableCell(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: index == 0
                                                      ? Text('No hay gastos registrados', textAlign: TextAlign.center)
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
                                                DateFormat('dd/MM/yyyy').format(data['date'].toDate()),
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                '\$ ${NumberFormat('#,##0.00', 'es_CO').format(data['amount'])}',
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                data['category'] == null || data['category'] == ''
                                                    ? 'No definido'
                                                    : data['category'],
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                data['paymentStatus'] ?? '',
                                                style: TextStyle(
                                                  color:
                                                      data['paymentStatus'] == 'Pagado' ? Colors.green : Colors.orange,
                                                ),
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                data['paymentMethod'] ?? 'No definido',
                                                style: const TextStyle(fontSize: 16),
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

  Widget _buildColumnFilters(RegisteredExpensesController controller) {
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
          Expanded(flex: 2, child: Container()), // Columna Fecha
          Expanded(flex: 2, child: Container()), // Columna Importe
          // Columna Categoría (flex 2)
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
                              child: Text(option.isEmpty ? "Todos" : option,
                                  style: const TextStyle(fontSize: 16)),
                            ))
                        .toList(),
                    onChanged: controller.updateCategoria,
                  )),
            ),
          ),
          // Columna Estado (flex 2)
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.only(right: 8.0),
              child: Obx(() => DropdownButton<String>(
                    isExpanded: true,
                    value: controller.selectedEstado.value,
                    hint: const Text("Todos", style: TextStyle(fontSize: 16)),
                    items: controller.estadoOptions
                        .map((option) => DropdownMenuItem<String>(
                              value: option,
                              child: Text(option.isEmpty ? "Todos" : option,
                                  style: const TextStyle(fontSize: 16)),
                            ))
                        .toList(),
                    onChanged: controller.updateEstado,
                  )),
            ),
          ),
          // Columna Método de pago (flex 2)
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
                              child: Text(option.isEmpty ? "Todos" : option,
                                  style: const TextStyle(fontSize: 16)),
                            ))
                        .toList(),
                    onChanged: controller.updatePaymentMethod,
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
}
