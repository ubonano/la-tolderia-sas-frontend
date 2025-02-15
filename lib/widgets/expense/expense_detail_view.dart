import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/expense_detail_controller.dart';
import '../common/custom_dialog.dart';
import 'file_viewer.dart';
import '../date_field.dart';
import '../editable_dropdown.dart';
import '../editable_field.dart';
import '../due_date_field.dart';
import '../payment_date_field.dart';
import '../../services/payment_method_service.dart';
import '../../services/payment_category_service.dart';

class ExpenseDetailView extends GetView<ExpenseDetailController> {
  final QueryDocumentSnapshot expense;
  final bool isRegistered;
  final Color backgroundColor;

  const ExpenseDetailView({
    super.key,
    required this.expense,
    required this.isRegistered,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final String collectionName = isRegistered ? 'registered_expenses' : 'expenses';
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection(collectionName).doc(expense.id).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final updatedExpense = snapshot.data!;
        if (!updatedExpense.exists) {
          return const Center(
            child: Text("El gasto ya fue registrado o eliminado"),
          );
        }

        controller.initData(expense.id, collectionName);
        controller.loadFromSnapshot(updatedExpense);

        return _buildContent(context, updatedExpense);
      },
    );
  }

  Widget _buildContent(BuildContext context, DocumentSnapshot expense) {
    return Column(
      children: [
        _buildHeader(context, expense),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: FileViewer(
                      fileUrl: expense['fileUrl'],
                      fileName: expense['fileName'],
                    ),
                  ),
                  _buildDetailsSection(expense),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, DocumentSnapshot expense) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            iconSize: 32.0,
            icon: const Icon(Icons.close),
            onPressed: () => Get.back(),
          ),
          IconButton(
            iconSize: 32.0,
            icon: Icon(Icons.delete, color: isRegistered ? Colors.grey : Colors.red),
            onPressed: isRegistered ? null : () => _confirmDelete(expense),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(DocumentSnapshot expense) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormFields(expense),
            if (!isRegistered)
              _buildRegisterButton(expense)
            else
              Obx(() {
                return controller.paymentStatus.value == 'Pendiente'
                    ? _buildPayButton(expense)
                    : const SizedBox.shrink();
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields(DocumentSnapshot expense) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DateField(expense: expense, collectionName: controller.collectionName),
          const SizedBox(height: 16),
          DueDateField(
            expense: expense,
            collectionName: controller.collectionName,
          ),
          const SizedBox(height: 16),
          _buildBasicFields(expense),
          const SizedBox(height: 16),
          _buildCategoryDropdown(expense),
          const SizedBox(height: 16),
          Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EditableDropdown(
                    label: 'Estado:',
                    initialValue: controller.paymentStatus.value,
                    options: ['Pendiente', 'Pagado'],
                    onSave: (newValue) async {
                      if (newValue == 'Pendiente') {
                        await controller.setPaymentAsPending();
                      } else {
                        await controller.setPaymentAsPaid();
                      }
                    },
                    optionTextStyle: (value) => TextStyle(
                      color: value == 'Pagado' ? Colors.green : Colors.orange,
                      fontSize: 16,
                    ),
                  ),
                  if (controller.paymentStatus.value == 'Pagado') ...[
                    const SizedBox(height: 16),
                    FutureBuilder<List<String>>(
                      future: PaymentMethodService.getPaymentMethods(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        final methods = snapshot.data!;
                        return EditableDropdown(
                          label: 'Método:',
                          initialValue: controller.paymentMethod.value ?? (methods.isNotEmpty ? methods[0] : ''),
                          options: methods,
                          onSave: (newValue) async {
                            await controller.updatePaymentMethod(newValue);
                          },
                          optionTextStyle: (value) => TextStyle(
                            color: value == 'Efectivo' ? Colors.lightGreen : Colors.blue,
                            fontSize: 16,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    PaymentDateField(
                      expense: expense,
                      collectionName: controller.collectionName,
                    ),
                  ]
                ],
              )),
          const Spacer(),
          EditableField(
            expense: expense,
            fieldName: 'observations',
            label: 'Observaciones:',
            onUpdate: (updatedDoc) {},
            collectionName: controller.collectionName,
          ),
        ],
      ),
    );
  }

  Future<bool> _checkIssuerExists(String issuer) async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('issuers').where('name', isEqualTo: issuer).limit(1).get();
    return querySnapshot.docs.isNotEmpty;
  }

  Widget _buildBasicFields(DocumentSnapshot expense) {
    return Column(
      children: [
        EditableField(
          expense: expense,
          fieldName: 'number',
          label: 'Número:',
          onUpdate: (updatedDoc) {},
          collectionName: controller.collectionName,
        ),
        const SizedBox(height: 16),
        EditableField(
          expense: expense,
          fieldName: 'issuer',
          label: 'Emisor:',
          onUpdate: (updatedDoc) {},
          collectionName: controller.collectionName,
          validationFuture: _checkIssuerExists(expense['issuer']),
          validationErrorMessage: 'El emisor no está registrado',
        ),
        const SizedBox(height: 16),
        EditableField(
          expense: expense,
          fieldName: 'amount',
          label: 'Importe:',
          isNumber: true,
          isCurrency: true,
          onUpdate: (updatedDoc) {},
          collectionName: controller.collectionName,
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(DocumentSnapshot expense) {
    return FutureBuilder<List<String>>(
      future: PaymentCategoryService.getPaymentCategories(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        final categories = snapshot.data!;
        return EditableDropdown(
          label: 'Categoría:',
          initialValue: _getCategoryValue(expense),
          options: categories,
          onSave: (newValue) => _updateCategory(newValue, expense.id),
        );
      },
    );
  }

  String _getCategoryValue(DocumentSnapshot expense) {
    final data = expense.data() as Map<String, dynamic>;
    final String category = data['category']?.toString().trim() ?? '';
    return category.isEmpty ? 'No definido' : category;
  }

  Future<void> _updateCategory(String newValue, String expenseId) async {
    final docRef = FirebaseFirestore.instance.collection(controller.collectionName).doc(expenseId);
    if (newValue == 'No definido') {
      await docRef.update({'category': FieldValue.delete()});
    } else {
      await docRef.update({'category': newValue});
    }
  }

  Widget _buildRegisterButton(DocumentSnapshot expense) {
    final data = expense.data() as Map<String, dynamic>;
    DateTime expenseDate = (data['date'] as Timestamp).toDate();
    DateTime due = data.containsKey('dueDate') ? (data['dueDate'] as Timestamp).toDate() : DateTime.now();
    bool disableByDate = due.isBefore(expenseDate);
    return FutureBuilder<bool>(
      future: _checkIssuerExists(data['issuer']),
      builder: (context, snapshot) {
        bool issuerExists = snapshot.data ?? false;
        bool disableRegister = disableByDate || !issuerExists;
        return Column(
          children: [
            const SizedBox(height: 16),
            const Divider(height: 32),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: disableRegister ? Colors.grey : Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Registrar', style: TextStyle(fontSize: 16)),
                onPressed: disableRegister ? null : () => _confirmRegister(expense),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPayButton(DocumentSnapshot expense) {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Divider(height: 32),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
            icon: const Icon(Icons.payment, size: 20),
            label: const Text('Pagar', style: TextStyle(fontSize: 16)),
            onPressed: () async {
              await controller.setPaymentAsPaid();
            },
          ),
        ),
      ],
    );
  }

  void _confirmDelete(DocumentSnapshot expense) {
    CustomDialog.showConfirmation(
      title: 'Confirmar eliminación',
      content: '¿Está seguro que desea eliminar este gasto?',
      confirmLabel: 'Eliminar',
      cancelLabel: 'Cancelar',
      confirmColor: Colors.red,
      onConfirm: () => controller.deleteExpense(),
    );
  }

  void _confirmRegister(DocumentSnapshot expense) {
    CustomDialog.showConfirmation(
      title: 'Confirmar registro',
      content: '¿Está seguro de que desea registrar este gasto?',
      confirmLabel: 'Registrar',
      cancelLabel: 'Cancelar',
      onConfirm: () => controller.registerExpense(),
    );
  }
}
