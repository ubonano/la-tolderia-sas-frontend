import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Se importa el servicio de gastos para delegar la lógica de registro y eliminación
import '../services/expense_service.dart';

class ExpenseDetailController extends GetxController {
  // Ahora se usan variables que se pueden asignar mediante el método initData()
  String expenseId = '';
  String collectionName = '';

  // Observables para el estado del pago
  RxString paymentStatus = 'Pendiente'.obs;
  RxnString paymentMethod = RxnString();
  Rxn<DateTime> paymentAt = Rxn<DateTime>();

  // Método para inicializar el controller con los datos del gasto actual
  void initData(String newExpenseId, String newCollectionName) {
    expenseId = newExpenseId;
    collectionName = newCollectionName;
  }

  // Método para cargar los datos del snapshot de Firestore y actualizar el estado
  void loadFromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    paymentStatus.value = data['paymentStatus'] ?? 'Pendiente';
    paymentMethod.value = data['paymentMethod'];
    if (data['paymentAt'] != null) {
      paymentAt.value = (data['paymentAt'] as Timestamp).toDate();
    } else {
      paymentAt.value = null;
    }
  }

  // Lógica compartida para marcar el gasto como pagado
  Future<void> setPaymentAsPaid({String method = 'Efectivo'}) async {
    final docRef = FirebaseFirestore.instance.collection(collectionName).doc(expenseId);
    final now = DateTime.now();
    await docRef.update({
      'paymentStatus': 'Pagado',
      'paymentMethod': method,
      'paymentAt': now,
    });
    paymentStatus.value = 'Pagado';
    paymentMethod.value = method;
    paymentAt.value = now;
  }

  // Lógica compartida para revertir el estado a pendiente
  Future<void> setPaymentAsPending() async {
    final docRef = FirebaseFirestore.instance.collection(collectionName).doc(expenseId);
    await docRef.update({
      'paymentStatus': 'Pendiente',
      'paymentMethod': FieldValue.delete(),
      'paymentAt': FieldValue.delete(),
    });
    paymentStatus.value = 'Pendiente';
    paymentMethod.value = null;
    paymentAt.value = null;
  }

  // Método para actualizar el método de pago por separado si es necesario
  Future<void> updatePaymentMethod(String newMethod) async {
    final docRef = FirebaseFirestore.instance.collection(collectionName).doc(expenseId);
    await docRef.update({'paymentMethod': newMethod});
    paymentMethod.value = newMethod;
  }

  // Nuevo método para registrar el gasto utilizando la lógica del servicio
  Future<void> registerExpense() async {
    await ExpenseService.registerExpense(expenseId);
  }

  // Nuevo método para eliminar el gasto utilizando la lógica del servicio
  Future<void> deleteExpense() async {
    await ExpenseService.deleteExpense(expenseId);
  }
}
