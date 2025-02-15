import 'package:get/get.dart';

class PdfViewerController extends GetxController {
  // Flag que indica si se deben ignorar los eventos del PDF viewer
  RxBool isDisabled = false.obs;

  // Getter de conveniencia para acceder desde otros widgets
  static PdfViewerController get to => Get.find<PdfViewerController>();
} 