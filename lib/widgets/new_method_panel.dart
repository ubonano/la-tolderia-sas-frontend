import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/payment_methods_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewMethodPanel extends StatefulWidget {
  const NewMethodPanel({Key? key}) : super(key: key);

  @override
  _NewMethodPanelState createState() => _NewMethodPanelState();
}

class _NewMethodPanelState extends State<NewMethodPanel> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _methodController = TextEditingController();

  final PaymentMethodsController controller = Get.find<PaymentMethodsController>();

  @override
  void dispose() {
    _methodController.dispose();
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
                    'Crear nuevo método',
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
                  controller: _methodController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del método',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingrese el nombre del método';
                    }
                    String newValue = value.trim().toLowerCase();
                    if (controller.paymentMethods
                        .map((doc) => (doc.data() as Map<String, dynamic>)['name'].toString().toLowerCase())
                        .any((name) => name == newValue)) {
                      return 'El método ya existe';
                    }
                    return null;
                  },
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final newMethod = _capitalize(_methodController.text.trim());
                    
                    // Consultar en Firestore si el método ya existe
                    final querySnapshot = await FirebaseFirestore.instance
                        .collection('payment_methods')
                        .where('name', isEqualTo: newMethod)
                        .limit(1)
                        .get();
                    
                    if (querySnapshot.docs.isNotEmpty) {
                      // El método ya existe en la base de datos, se muestra un error
                      Get.snackbar(
                        'Error',
                        'El método "$newMethod" ya existe en la base de datos',
                        backgroundColor: Colors.red.shade100,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }
                    
                    // Almacenar el nuevo método en Firestore
                    await FirebaseFirestore.instance
                        .collection('payment_methods')
                        .add({'name': newMethod});
                    // Actualizar el listado observable
                    await controller.loadPaymentMethods();
                    Get.back(); // Cierra el diálogo
                    Get.snackbar(
                      'Método creado',
                      'El método "$newMethod" fue creado',
                      backgroundColor: Colors.green.shade100,
                    );
                  }
                },
                child: const Text('Guardar método'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
