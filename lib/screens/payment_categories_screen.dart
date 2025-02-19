import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/payment_categories_controller.dart';
import '../widgets/common/app_layout.dart';
import '../widgets/new_category_panel.dart';
import '../widgets/category_detail_panel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentCategoriesScreen extends GetView<PaymentCategoriesController> {
  const PaymentCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      customTitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Gestión de Categorías de Pago',
            style: TextStyle(fontSize: 18),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            tooltip: 'Crear nueva categoría',
            onPressed: () {
              showGeneralDialog(
                context: context,
                barrierLabel: 'Nueva categoría',
                barrierDismissible: true,
                barrierColor: Colors.black.withOpacity(0.5),
                transitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
                  return const NewCategoryPanel();
                },
                transitionBuilder: (context, animation, secondaryAnimation, child) {
                  var slideAnimation = Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(animation);
                  return SlideTransition(
                    position: slideAnimation,
                    child: child,
                  );
                },
              );
            },
          ),
        ],
      ),
      // Se utiliza la ruta '/payment-categories' para la pantalla actual
      currentRoute: '/payment-categories',
      backgroundColor: Colors.green.shade50,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(() {
                if (controller.paymentCategories.isEmpty) {
                  return const Center(child: Text('No hay categorías de pago'));
                }
                return ListView.builder(
                  itemCount: controller.paymentCategories.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot category = controller.paymentCategories[index];
                    return PaymentCategoryTile(
                      key: ValueKey(category.id),
                      category: category,
                      onDelete: () async {
                        await controller.deleteCategory(category);
                      },
                    );
                  },
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// Nuevo widget para mostrar cada categoría con botón de eliminación visible al pasar el cursor
class PaymentCategoryTile extends StatefulWidget {
  final DocumentSnapshot category;
  final VoidCallback onDelete;

  const PaymentCategoryTile({
    Key? key,
    required this.category,
    required this.onDelete,
  }) : super(key: key);

  @override
  _PaymentCategoryTileState createState() => _PaymentCategoryTileState();
}

class _PaymentCategoryTileState extends State<PaymentCategoryTile> {
  bool isHovered = false;
  bool confirming = false;
  FocusNode _focusNode = FocusNode();

  Widget _buildDefaultContent() {
    return ListTile(
      key: const ValueKey('default'),
      title: Text(widget.category['name']),
      trailing: isHovered
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.blue),
                  tooltip: 'Ver detalles',
                  onPressed: () {
                    // Mostrar el panel lateral para ver y editar detalles de la categoría.
                    showGeneralDialog(
                      context: context,
                      barrierLabel: 'Editar categoría',
                      barrierDismissible: true,
                      barrierColor: Colors.black.withOpacity(0.5),
                      transitionDuration: const Duration(milliseconds: 300),
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return CategoryDetailPanel(category: widget.category['name']);
                      },
                      transitionBuilder: (context, animation, secondaryAnimation, child) {
                        var slideAnimation = Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(animation);
                        return SlideTransition(
                          position: slideAnimation,
                          child: child,
                        );
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Eliminar categoría',
                  onPressed: () {
                    setState(() {
                      confirming = true;
                    });
                    _focusNode.requestFocus();
                  },
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildConfirmationContent() {
    return Container(
      key: const ValueKey('confirm'),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Text(
              '¿Está seguro que desea eliminar?',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 16.0),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            tooltip: 'Confirmar',
            onPressed: () {
              widget.onDelete();
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.red),
            tooltip: 'Cancelar',
            onPressed: () {
              setState(() {
                confirming = false;
              });
              _focusNode.unfocus();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onFocusChange: (hasFocus) {
        if (!hasFocus && confirming) {
          setState(() {
            confirming = false;
          });
        }
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 70.0,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: confirming ? Colors.red.shade100 : Colors.green.shade50,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: confirming ? _buildConfirmationContent() : _buildDefaultContent(),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
