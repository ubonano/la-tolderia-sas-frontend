import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/payment_category_service.dart';

class PendingExpensesController extends GetxController {
  // Filtros observables
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxInt selectedMonth = DateTime.now().month.obs;
  final RxString filterIssuer = "".obs;
  final RxString selectedCategoria = "".obs;

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
  final RxList<String> categoriaOptions = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPaymentCategories();
  }

  Future<void> loadPaymentCategories() async {
    List<String> categories = await PaymentCategoryService.getPaymentCategories();
    categoriaOptions.value = [''] + categories;
  }

  // Consulta para obtener los gastos pendientes ordenados por fecha de vencimiento
  Stream<QuerySnapshot> getPendingExpenses() {
    Query query = FirebaseFirestore.instance.collection('registered_expenses');

    // Filtrar por fecha de vencimiento en el rango seleccionado
    final startDue = DateTime(selectedYear.value, selectedMonth.value, 1);
    final endDue = DateTime(selectedYear.value, selectedMonth.value + 1, 0, 23, 59, 59);

    query = query
        .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDue))
        .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(endDue))
        .where('paymentStatus', isEqualTo: 'Pendiente');

    // Aplicar filtros adicionales si están seleccionados
    if (filterIssuer.isNotEmpty) {
      query = query.where('issuer', isEqualTo: filterIssuer.value);
    }
    if (selectedCategoria.isNotEmpty) {
      query = query.where('category', isEqualTo: selectedCategoria.value);
    }

    // Ordenar por fecha de vencimiento (ascendente)
    query = query.orderBy('dueDate');

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

  // Método para limpiar los filtros
  void clearFilters() {
    filterIssuer.value = "";
    selectedCategoria.value = "";
  }
}
