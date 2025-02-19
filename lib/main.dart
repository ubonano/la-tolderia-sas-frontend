import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'controllers/expense_detail_controller.dart';
import 'controllers/paid_expenses_controller.dart';
import 'controllers/pending_expenses_controller.dart';
import 'firebase_options.dart';
import 'screens/paid_expenses_screen.dart';
import 'screens/validation_expenses_screen.dart';
import 'screens/registered_expenses_screen.dart';
import 'screens/pending_expenses_screen.dart';
import 'controllers/layout_controller.dart';
import 'controllers/registered_expenses_controller.dart';
import 'controllers/pdf_viewer_controller.dart';
import 'transitions/liquid_transition.dart';
import 'controllers/payment_categories_controller.dart';
import 'screens/payment_categories_screen.dart';

Future<void> ensurePaymentMethodsExist() async {
  final firestore = FirebaseFirestore.instance;
  final paymentMethodsCollection = firestore.collection('payment_methods');
  final List<String> paymentMethods = ['Efectivo', 'Mercado Pago'];

  for (final method in paymentMethods) {
    final querySnapshot = await paymentMethodsCollection.where('name', isEqualTo: method).limit(1).get();
    if (querySnapshot.docs.isEmpty) {
      await paymentMethodsCollection.add({'name': method});
    }
  }
}

Future<void> ensurePaymentCategoriesExist() async {
  final firestore = FirebaseFirestore.instance;
  final paymentCategoriesCollection = firestore.collection('payment_categories');
  final List<String> paymentCategories = [
    'No definido',
    'Insumos',
    'Sueldos',
    'Servicios',
    'Impuestos',
    'Sindicato',
    'Gasto empresa',
    'Deuda operativa',
    'Deuda financiera'
  ];

  for (final category in paymentCategories) {
    final querySnapshot = await paymentCategoriesCollection.where('name', isEqualTo: category).limit(1).get();
    if (querySnapshot.docs.isEmpty) {
      await paymentCategoriesCollection.add({'name': category});
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setUrlStrategy(PathUrlStrategy());
  await initializeDateFormatting('es_ES', null);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8382);
  FirebaseFunctions.instance.useFunctionsEmulator('localhost', 8381);
  // FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

  // Ejecutar el script para insertar métodos de pago si no existen
  // await ensurePaymentMethodsExist();
  // await ensurePaymentCategoriesExist();

  // Initialize the controllers lazily
  Get.lazyPut<LayoutController>(() => LayoutController(), fenix: true);
  Get.lazyPut<RegisteredExpensesController>(() => RegisteredExpensesController(), fenix: true);
  Get.lazyPut<PdfViewerController>(() => PdfViewerController(), fenix: true);
  Get.lazyPut<PendingExpensesController>(() => PendingExpensesController(), fenix: true);
  Get.lazyPut<ExpenseDetailController>(() => ExpenseDetailController(), fenix: true);
  Get.lazyPut<PaidExpensesController>(() => PaidExpensesController(), fenix: true);
  Get.lazyPut<PaymentCategoriesController>(() => PaymentCategoriesController(), fenix: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.noTransition,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
      ],
      locale: const Locale('es', 'ES'),
      initialRoute: '/pending-expenses',
      getPages: [
        GetPage(
          name: '/pending-expenses',
          page: () => const PendingExpensesScreen(),
          customTransition: LiquidCustomTransition(),
          transitionDuration: const Duration(milliseconds: 300),
        ),
        GetPage(
          name: '/paid-expenses',
          page: () => const PaidExpensesScreen(),
          customTransition: LiquidCustomTransition(),
          transitionDuration: const Duration(milliseconds: 300),
        ),
        GetPage(
          name: '/registered-expenses',
          page: () => const RegisteredExpensesScreen(),
          customTransition: LiquidCustomTransition(),
          transitionDuration: const Duration(milliseconds: 300),
        ),
        GetPage(
          name: '/validation-expenses',
          page: () => const ValidationExpensesScreen(),
          customTransition: LiquidCustomTransition(),
          transitionDuration: const Duration(milliseconds: 300),
        ),
        GetPage(
          name: '/payment-categories',
          page: () => const PaymentCategoriesScreen(),
          customTransition: LiquidCustomTransition(),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}
