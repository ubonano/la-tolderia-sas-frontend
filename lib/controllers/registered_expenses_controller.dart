import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/payment_method_service.dart';
import '../services/payment_category_service.dart';
import '../services/beneficiary_service.dart';

class RegisteredExpensesController extends GetxController {
  // Estado observable para los filtros
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxInt selectedMonth = DateTime.now().month.obs;
  final RxString selectedPaymentMethod = "".obs;
  final RxString selectedEstado = "".obs;
  final RxString selectedCategoria = "".obs;
  final RxString selectedBeneficiary = "".obs;

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
  final RxList<String> beneficiaryOptions = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPaymentMethods();
    loadPaymentCategories();
    loadBeneficiaries();
  }

  Future<void> loadBeneficiaries() async {
    List<DocumentSnapshot> docs =
        await BeneficiaryService.getBeneficiariesDocuments();
    List<String> beneficiaries = docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['name'].toString())
        .toList();
    beneficiaryOptions.value = [''] + beneficiaries;
  }

  Future<void> loadPaymentMethods() async {
    List<DocumentSnapshot> methods =
        await PaymentMethodService.getPaymentMethodsDocuments();
    List<String> methodsNames = methods
        .map((doc) => (doc.data() as Map<String, dynamic>)['name'].toString())
        .toList();
    paymentMethodOptions.value = [''] + methodsNames;
  }

  Future<void> loadPaymentCategories() async {
    List<DocumentSnapshot> docs =
        await PaymentCategoryService.getPaymentCategories();
    List<String> categories = docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['name'].toString())
        .toList();
    categoriaOptions.value = [''] + categories;
  }

  // Stream para los gastos registrados
  Stream<QuerySnapshot> getRegisteredExpenses() {
    Query query = FirebaseFirestore.instance.collection('registered_expenses');

    // Filtrar por año y mes
    final startDate = DateTime(selectedYear.value, selectedMonth.value, 1);
    final endDate =
        DateTime(selectedYear.value, selectedMonth.value + 1, 0, 23, 59, 59);

    query = query
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

    // Actualización: usar selectedBeneficiary y campo 'beneficiary'
    if (selectedBeneficiary.isNotEmpty) {
      query =
          query.where('beneficiary', isEqualTo: selectedBeneficiary.value);
    }
    if (selectedPaymentMethod.isNotEmpty) {
      query = query.where('paymentMethod', isEqualTo: selectedPaymentMethod.value);
    }
    if (selectedEstado.isNotEmpty) {
      query = query.where('paymentStatus', isEqualTo: selectedEstado.value);
    }
    if (selectedCategoria.isNotEmpty) {
      query = query.where('category', isEqualTo: selectedCategoria.value);
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

  void updateBeneficiary(String? beneficiary) {
    if (beneficiary != null) selectedBeneficiary.value = beneficiary;
  }

  // Método para limpiar todos los filtros
  void clearFilters() {
    selectedPaymentMethod.value = "";
    selectedEstado.value = "";
    selectedCategoria.value = "";
    selectedBeneficiary.value = "";
  }
}
