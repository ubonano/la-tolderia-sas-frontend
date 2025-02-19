import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/payment_method_service.dart';
import '../services/payment_category_service.dart';

class RegisteredExpensesController extends GetxController {
  // Estado observable para los filtros
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxInt selectedMonth = DateTime.now().month.obs;
  final RxString selectedPaymentMethod = "".obs;
  final RxString selectedEstado = "".obs;
  final RxString selectedCategoria = "".obs;
  final RxString filterIssuer = "".obs;

  // Lista de opciones para los filtros
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
  final RxList<String> paymentMethodOptions = <String>[].obs;
  final List<String> estadoOptions = ["", "Pendiente", "Pagado"];
  final RxList<String> categoriaOptions = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPaymentMethods();
    loadPaymentCategories();
  }

  Future<void> loadPaymentMethods() async {
    List<DocumentSnapshot> methods = await PaymentMethodService.getPaymentMethodsDocuments();
    List<String> methodsNames = methods.map((doc) => (doc.data() as Map<String, dynamic>)['name'].toString()).toList();
    // Se agrega una opción vacía para representar "Todos"
    paymentMethodOptions.value = [''] + methodsNames;
  }

  Future<void> loadPaymentCategories() async {
    List<DocumentSnapshot> docs = await PaymentCategoryService.getPaymentCategories();
    // Se obtiene el campo "name" de cada documento y se agrega una opción vacía para representar "Todos"
    List<String> categories = docs.map((doc) => (doc.data() as Map<String, dynamic>)['name'].toString()).toList();
    categoriaOptions.value = [''] + categories;
  }

  // Stream para los gastos registrados
  Stream<QuerySnapshot> getRegisteredExpenses() {
    Query query = FirebaseFirestore.instance.collection('registered_expenses');

    // Filtrar por año y mes
    final startDate = DateTime(selectedYear.value, selectedMonth.value, 1);
    final endDate = DateTime(selectedYear.value, selectedMonth.value + 1, 0, 23, 59, 59);

    query = query
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

    // Aplicar filtros adicionales si están seleccionados
    if (selectedPaymentMethod.isNotEmpty) {
      query = query.where('paymentMethod', isEqualTo: selectedPaymentMethod.value);
    }
    if (selectedEstado.isNotEmpty) {
      query = query.where('paymentStatus', isEqualTo: selectedEstado.value);
    }
    if (selectedCategoria.isNotEmpty) {
      query = query.where('category', isEqualTo: selectedCategoria.value);
    }
    if (filterIssuer.isNotEmpty) {
      query = query.where('issuer', isEqualTo: filterIssuer.value);
    }

    return query.snapshots();
  }

  // Métodos para actualizar filtros
  void updateYear(int? year) {
    if (year != null) selectedYear.value = year;
  }

  void updateMonth(int? month) {
    if (month != null) selectedMonth.value = month;
  }

  void updatePaymentMethod(String? method) {
    if (method != null) selectedPaymentMethod.value = method;
  }

  void updateEstado(String? estado) {
    if (estado != null) selectedEstado.value = estado;
  }

  void updateCategoria(String? categoria) {
    if (categoria != null) selectedCategoria.value = categoria;
  }

  void updateIssuer(String? issuer) {
    if (issuer != null) filterIssuer.value = issuer;
  }

  // Método para limpiar todos los filtros
  void clearFilters() {
    selectedPaymentMethod.value = "";
    selectedEstado.value = "";
    selectedCategoria.value = "";
    filterIssuer.value = "";
  }
}
