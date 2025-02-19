import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/payment_method_service.dart';
import '../services/payment_category_service.dart';

class PaidExpensesController extends GetxController {
  // Observables para los filtros
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxInt selectedMonth = DateTime.now().month.obs;
  final RxString filterIssuer = "".obs;
  final RxString selectedCategoria = "".obs;
  final RxString selectedPaymentMethod = "".obs;

  // Se reemplaza la lista estática por una lista observable para los métodos de pago
  final RxList<String> paymentMethodOptions = <String>[].obs;
  // Se reemplaza la lista estática de categorías por una lista observable
  final RxList<String> categoriaOptions = <String>[].obs;

  // Opciones para los filtros
  final List<int> years = [2021, 2022, 2023, 2024, 2025];
  final List<String> monthNames = [
    "Enero",
    "Febrero",
    "Marzo",
    "Abril",
    "Mayo",
    "Junio",
    "Julio",
    "Agosto",
    "Septiembre",
    "Octubre",
    "Noviembre",
    "Diciembre"
  ];

  @override
  void onInit() {
    super.onInit();
    loadPaymentMethods();
    loadPaymentCategories(); // Carga dinámica de categorías
  }

  Future<void> loadPaymentMethods() async {
    List<DocumentSnapshot> methods = await PaymentMethodService.getPaymentMethodsDocuments();
    List<String> methodsNames = methods.map((doc) => (doc.data() as Map<String, dynamic>)['name'].toString()).toList();
    // Se agrega una opción vacía para representar "Todos"
    paymentMethodOptions.value = [''] + methodsNames;
  }

  Future<void> loadPaymentCategories() async {
    List<DocumentSnapshot> docs = await PaymentCategoryService.getPaymentCategories();
    List<String> categories = docs.map((doc) => (doc.data() as Map<String, dynamic>)['name'].toString()).toList();
    // Se agrega una opción vacía para representar "Todos"
    categoriaOptions.value = [''] + categories;
  }

  // Stream para obtener los gastos pagados filtrados por año, mes y estado 'Pagado'
  Stream<QuerySnapshot> getPaidExpenses() {
    Query query = FirebaseFirestore.instance.collection('registered_expenses');
    // Filtrar por rango de fecha de la factura (campo 'date')
    final startDate = DateTime(selectedYear.value, selectedMonth.value, 1);
    final endDate = DateTime(selectedYear.value, selectedMonth.value + 1, 0, 23, 59, 59);
    query = query
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .where('paymentStatus', isEqualTo: 'Pagado');

    if (filterIssuer.isNotEmpty) {
      query = query.where('issuer', isEqualTo: filterIssuer.value);
    }
    if (selectedCategoria.isNotEmpty) {
      query = query.where('category', isEqualTo: selectedCategoria.value);
    }
    if (selectedPaymentMethod.isNotEmpty) {
      query = query.where('paymentMethod', isEqualTo: selectedPaymentMethod.value);
    }
    // Ordenar por fecha de factura: de la más reciente a la más antigua
    query = query.orderBy('date', descending: true);
    return query.snapshots();
  }

  // Métodos para actualizar filtros
  void updateYear(int? year) {
    if (year != null) selectedYear.value = year;
  }

  void updateMonth(int? month) {
    if (month != null) selectedMonth.value = month;
  }

  void updateIssuer(String? issuer) {
    if (issuer != null) filterIssuer.value = issuer;
  }

  void updateCategoria(String? categoria) {
    if (categoria != null) selectedCategoria.value = categoria;
  }

  void updatePaymentMethod(String? method) {
    if (method != null) selectedPaymentMethod.value = method;
  }

  // Método para limpiar los filtros
  void clearFilters() {
    filterIssuer.value = "";
    selectedCategoria.value = "";
    selectedPaymentMethod.value = "";
  }
}
