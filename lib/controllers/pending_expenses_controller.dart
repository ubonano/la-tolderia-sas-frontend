import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/payment_category_service.dart';
import '../services/beneficiary_service.dart';

class PendingExpensesController extends GetxController {
  // Filtros observables
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxInt selectedMonth = DateTime.now().month.obs;
  final RxString selectedBeneficiary = "".obs;
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
  final RxList<String> beneficiaryOptions = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPaymentCategories();
    loadBeneficiaries();
  }

  Future<void> loadPaymentCategories() async {
    List<DocumentSnapshot> docs = await PaymentCategoryService.getPaymentCategories();
    List<String> categories = docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['name'].toString())
        .toList();
    categoriaOptions.value = [''] + categories;
  }

  Future<void> loadBeneficiaries() async {
    List<DocumentSnapshot> docs = await BeneficiaryService.getBeneficiariesDocuments();
    List<String> beneficiaries = docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['name'].toString())
        .toList();
    beneficiaryOptions.value = [''] + beneficiaries;
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
    if (selectedBeneficiary.isNotEmpty) {
      query = query.where('beneficiary', isEqualTo: selectedBeneficiary.value);
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

  void updateBeneficiary(String? beneficiary) {
    if (beneficiary != null) selectedBeneficiary.value = beneficiary;
  }

  void updateCategoria(String? categoria) {
    if (categoria != null) selectedCategoria.value = categoria;
  }

  // Método para limpiar los filtros
  void clearFilters() {
    selectedBeneficiary.value = "";
    selectedCategoria.value = "";
  }
}
