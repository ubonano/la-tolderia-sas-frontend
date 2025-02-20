import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/beneficiaries_controller.dart';

class BeneficiaryDetailPanel extends StatefulWidget {
  final DocumentSnapshot beneficiary;
  const BeneficiaryDetailPanel({Key? key, required this.beneficiary}) : super(key: key);

  @override
  _BeneficiaryDetailPanelState createState() => _BeneficiaryDetailPanelState();
}

class _BeneficiaryDetailPanelState extends State<BeneficiaryDetailPanel> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _detailController;
  final BeneficiariesController controller = Get.find<BeneficiariesController>();
  bool editing = false;
  String _currentName = '';
  bool _isChanged = false;

  @override
  void initState() {
    super.initState();
    _currentName = widget.beneficiary['name'];
    _detailController = TextEditingController(text: _currentName);
    _isChanged = false;
  }

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  Widget _buildEditableField() {
    if (!editing) {
      return Row(
        children: [
          Expanded(
            child: Text(
              _currentName,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            tooltip: 'Editar',
            onPressed: () {
              setState(() {
                editing = true;
                _detailController.text = _currentName;
              });
            },
          ),
        ],
      );
    } else {
      return Form(
        key: _formKey,
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _detailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _isChanged = value.trim().toLowerCase() != _currentName.toLowerCase();
                  });
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingrese el nombre';
                  }
                  String newValue = value.trim().toLowerCase();
                  bool exists = controller.beneficiaries
                      .map((doc) => (doc.data() as Map<String, dynamic>)['name'].toString().toLowerCase())
                      .where((name) => name != _currentName.toLowerCase())
                      .any((name) => name == newValue);
                  if (exists) {
                    return 'El beneficiario ya existe';
                  }
                  return null;
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              tooltip: 'Guardar',
              onPressed: _isChanged
                  ? () async {
                      if (_formKey.currentState!.validate()) {
                        final newVal = _capitalize(_detailController.text.trim());
                        final firestore = FirebaseFirestore.instance;
                        final snapshot =
                            await firestore.collection('beneficiaries').where('name', isEqualTo: newVal).get();
                        bool duplicate = snapshot.docs.any((doc) => doc.id != widget.beneficiary.id);
                        if (duplicate) {
                          Get.snackbar(
                            'Error',
                            'Ya se encuentra un beneficiario registrado con ese nombre',
                            backgroundColor: Colors.red.shade100,
                          );
                        } else {
                          await widget.beneficiary.reference.update({'name': newVal});
                        }
                        await controller.loadBeneficiaries();
                        setState(() {
                          editing = false;
                          _currentName = newVal;
                          _isChanged = false;
                        });
                        Get.snackbar(
                          'Beneficiario actualizado',
                          'El beneficiario se actualizó a "$newVal"',
                          backgroundColor: Colors.green.shade100,
                        );
                      }
                    }
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              tooltip: 'Cancelar',
              onPressed: () {
                setState(() {
                  editing = false;
                });
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
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
                    'Detalle beneficiario',
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
              _buildEditableField(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
