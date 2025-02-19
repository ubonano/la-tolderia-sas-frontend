import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/payment_categories_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewCategoryPanel extends StatefulWidget {
  const NewCategoryPanel({Key? key}) : super(key: key);

  @override
  _NewCategoryPanelState createState() => _NewCategoryPanelState();
}

class _NewCategoryPanelState extends State<NewCategoryPanel> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryController = TextEditingController();

  final PaymentCategoriesController controller = Get.find<PaymentCategoriesController>();

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      // Material con transparencia para poder tener sombra y fondo blanco
      type: MaterialType.transparency,
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.4,
          height: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(-2, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Crear nueva categoría',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Cerrar',
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la categoría',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingrese el nombre de la categoría';
                    }
                    String newValue = value.trim().toLowerCase();
                    if (controller.paymentCategories
                        .map((doc) => (doc.data() as Map<String, dynamic>)['name']
                            .toString()
                            .toLowerCase())
                        .any((name) => name == newValue)) {
                      return 'La categoría ya existe';
                    }
                    return null;
                  },
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final newCategory = _capitalize(_categoryController.text.trim());
                    
                    // Consultar en Firestore si la categoría ya existe
                    final querySnapshot = await FirebaseFirestore.instance
                        .collection('payment_categories')
                        .where('name', isEqualTo: newCategory)
                        .limit(1)
                        .get();
                    
                    if (querySnapshot.docs.isNotEmpty) {
                      // La categoría ya existe en la base de datos, se muestra un error
                      Get.snackbar(
                        'Error',
                        'La categoría "$newCategory" ya existe en la base de datos',
                        backgroundColor: Colors.red.shade100,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }
                    
                    // Almacenar la nueva categoría en Firestore
                    await FirebaseFirestore.instance
                        .collection('payment_categories')
                        .add({'name': newCategory});
                    // Actualizar el listado observable
                    await controller.loadPaymentCategories();
                    Get.back(); // Cierra el diálogo
                    Get.snackbar(
                      'Categoría creada',
                      'La categoría "$newCategory" fue creada',
                      backgroundColor: Colors.green.shade100,
                    );
                  }
                },
                child: const Text('Guardar categoría'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
