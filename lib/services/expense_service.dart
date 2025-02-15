import 'package:cloud_functions/cloud_functions.dart';
import 'package:get/get.dart';
import '../widgets/common/custom_dialog.dart';

class ExpenseService {
  static Future<bool> deleteExpense(String expenseId) async {
    CustomDialog.showProcessing();
    try {
      await FirebaseFunctions.instance.httpsCallable('deleteExpense').call({'id': expenseId});
      Get.back(); // Cierra el diálogo de procesamiento
      Get.back(); // Cierra el popup de detalle
      return true;
    } catch (e) {
      Get.back();
      CustomDialog.showError('Error al eliminar el gasto: $e');
      return false;
    }
  }

  static Future<bool> registerExpense(String expenseId) async {
    CustomDialog.showProcessing();
    try {
      await FirebaseFunctions.instance.httpsCallable('registerExpense').call({'id': expenseId});
      Get.back(); // Cierra el diálogo de procesamiento
      Get.back(); // Cierra el popup de detalle
      return true;
    } catch (e) {
      Get.back();
      CustomDialog.showError('Error al registrar el gasto: $e');
      return false;
    }
  }
}
