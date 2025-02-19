import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/layout_controller.dart';

class AppLayout extends GetView<LayoutController> {
  final Widget child;
  final String? title;
  final Widget? customTitle;
  final String currentRoute;
  final Color backgroundColor;

  const AppLayout({
    super.key,
    required this.child,
    this.title,
    this.customTitle,
    required this.currentRoute,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: customTitle ?? Text(title ?? "", style: Theme.of(context).textTheme.titleLarge),
        leading: Obx(() => IconButton(
              icon: Icon(controller.isDrawerCollapsed ? Icons.menu : Icons.menu_open),
              onPressed: controller.toggleDrawer,
            )),
      ),
      body: Row(
        children: [
          Obx(() {
            // Determinar el índice seleccionado basado en currentRoute
            int selectedIndex;
            if (currentRoute == '/pending-expenses') {
              selectedIndex = 0;
            } else if (currentRoute == '/paid-expenses') {
              selectedIndex = 1;
            } else if (currentRoute == '/validation-expenses') {
              selectedIndex = 2;
            } else if (currentRoute == '/registered-expenses') {
              selectedIndex = 3;
            } else if (currentRoute == '/payment-categories') {
              selectedIndex = 4;
            } else if (currentRoute == '/payment-methods') {
              selectedIndex = 5;
            } else {
              selectedIndex = 0;
            }

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: controller.isDrawerCollapsed ? 60 : 250,
              child: NavigationRail(
                extended: !controller.isDrawerCollapsed,
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) {
                  if (index == 0 && currentRoute != '/pending-expenses') {
                    Get.toNamed('/pending-expenses');
                  } else if (index == 1 && currentRoute != '/paid-expenses') {
                    Get.toNamed('/paid-expenses');
                  } else if (index == 2 && currentRoute != '/validation-expenses') {
                    Get.toNamed('/validation-expenses');
                  } else if (index == 3 && currentRoute != '/registered-expenses') {
                    Get.toNamed('/registered-expenses');
                  } else if (index == 4 && currentRoute != '/payment-categories') {
                    Get.toNamed('/payment-categories');
                  } else if (index == 5 && currentRoute != '/payment-methods') {
                    Get.toNamed('/payment-methods');
                  }
                },
                backgroundColor: backgroundColor,
                destinations: const [
                  NavigationRailDestination(
                    padding: EdgeInsets.zero,
                    icon: Tooltip(
                      message: 'Validación de gastos',
                      child: Icon(Icons.search),
                    ),
                    label: Text('Validación de gastos'),
                  ),
                  NavigationRailDestination(
                    padding: EdgeInsets.zero,
                    icon: Tooltip(
                      message: 'Gastos registrados',
                      child: Icon(Icons.assignment),
                    ),
                    label: Text('Gastos registrados'),
                  ),
                  NavigationRailDestination(
                    padding: EdgeInsets.zero,
                    icon: Tooltip(
                      message: 'Gastos pendientes',
                      child: Icon(Icons.pending_actions),
                    ),
                    label: Text('Gastos pendientes'),
                  ),
                  NavigationRailDestination(
                    padding: EdgeInsets.zero,
                    icon: Tooltip(
                      message: 'Gastos pagados',
                      child: Icon(Icons.payment),
                    ),
                    label: Text('Gastos pagados'),
                  ),
                  NavigationRailDestination(
                    padding: EdgeInsets.zero,
                    icon: Tooltip(
                      message: 'Gestión de categorías de pago',
                      child: Icon(Icons.category),
                    ),
                    label: Text('Categorías de pago'),
                  ),
                  NavigationRailDestination(
                    padding: EdgeInsets.zero,
                    icon: Tooltip(
                      message: 'Gestión de métodos de pago',
                      child: Icon(Icons.account_balance_wallet),
                    ),
                    label: Text('Métodos de pago'),
                  ),
                ],
              ),
            );
          }),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}
