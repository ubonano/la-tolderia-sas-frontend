import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/beneficiaries_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewBeneficiaryPanel extends StatefulWidget {
  const NewBeneficiaryPanel({Key? key}) : super(key: key);

  @override
  _NewBeneficiaryPanelState createState() => _NewBeneficiaryPanelState();
}

class _NewBeneficiaryPanelState extends State<NewBeneficiaryPanel> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _beneficiaryController = TextEditingController();
  final TextEditingController _cbuController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final BeneficiariesController controller = Get.find<BeneficiariesController>();

  @override
  void dispose() {
    _beneficiaryController.dispose();
    _cbuController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      // Material with transparency to have shadow and white background
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
                    'Crear nuevo beneficiario',
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
                child: Column(
                  children: [
                    TextFormField(
                      controller: _beneficiaryController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del beneficiario',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingrese el nombre del beneficiario';
                        }
                        String newValue = value.trim().toLowerCase();
                        if (controller.beneficiaries
                            .map((doc) => (doc.data() as Map<String, dynamic>)['name'].toString().toLowerCase())
                            .any((name) => name == newValue)) {
                          return 'El beneficiario ya existe';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _cbuController,
                      decoration: const InputDecoration(
                        labelText: 'CBU',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingrese el CBU';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingrese el teléfono del beneficiario';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Correo Electrónico',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingrese el correo electrónico';
                        }
                        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                          return 'Ingrese un correo electrónico válido';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final newBeneficiary = _capitalize(_beneficiaryController.text.trim());
                    final newCBU = _cbuController.text.trim();
                    final newPhone = _phoneController.text.trim();
                    final newEmail = _emailController.text.trim();

                    // Consultar en Firestore si el beneficiario ya existe
                    final querySnapshot = await FirebaseFirestore.instance
                        .collection('beneficiaries')
                        .where('name', isEqualTo: newBeneficiary)
                        .limit(1)
                        .get();

                    if (querySnapshot.docs.isNotEmpty) {
                      Get.snackbar(
                        'Error',
                        'El beneficiario "$newBeneficiary" ya existe en la base de datos',
                        backgroundColor: Colors.red.shade100,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }

                    // Almacenar el nuevo beneficiario en Firestore con campos adicionales
                    await FirebaseFirestore.instance.collection('beneficiaries').add({
                      'name': newBeneficiary,
                      'cbu': newCBU,
                      'phone': newPhone,
                      'email': newEmail,
                    });
                    await controller.loadBeneficiaries();
                    Get.back(); // Cierra el diálogo
                    Get.snackbar(
                      'Beneficiario creado',
                      'El beneficiario "$newBeneficiary" fue creado',
                      backgroundColor: Colors.green.shade100,
                    );
                  }
                },
                child: const Text('Guardar beneficiario'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
