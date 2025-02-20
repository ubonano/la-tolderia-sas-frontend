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
  // final _formKey = GlobalKey<FormState>();
  late TextEditingController _detailController;
  late TextEditingController _cbuController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  final BeneficiariesController controller = Get.find<BeneficiariesController>();

  bool editingName = false;
  bool editingCBU = false;
  bool editingPhone = false;
  bool editingEmail = false;

  String _currentName = '';
  String _currentCBU = '';
  String _currentPhone = '';
  String _currentEmail = '';

  @override
  void initState() {
    super.initState();
    final data = widget.beneficiary.data() as Map<String, dynamic>;
    _currentName = data['name'];
    _currentCBU = data['cbu'] ?? '';
    _currentPhone = data['phone'] ?? '';
    _currentEmail = data['email'] ?? '';
    _detailController = TextEditingController(text: _currentName);
    _cbuController = TextEditingController(text: _currentCBU);
    _phoneController = TextEditingController(text: _currentPhone);
    _emailController = TextEditingController(text: _currentEmail);
  }

  @override
  void dispose() {
    _detailController.dispose();
    _cbuController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }
  
  Future<void> _saveField(String field) async {
    String newName = _detailController.text.trim();
    String newCBU = _cbuController.text.trim();
    String newPhone = _phoneController.text.trim();
    String newEmail = _emailController.text.trim();

    if (field == 'name') {
      if (newName.isEmpty) {
        Get.snackbar('Error', 'Por favor ingrese el nombre', backgroundColor: Colors.red.shade100);
        return;
      }
      newName = _capitalize(newName);
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore.collection('beneficiaries').where('name', isEqualTo: newName).get();
      bool duplicate = snapshot.docs.any((doc) => doc.id != widget.beneficiary.id);
      if (duplicate) {
        Get.snackbar('Error', 'El beneficiario ya existe', backgroundColor: Colors.red.shade100);
        return;
      }
    } else if (field == 'cbu') {
      if (newCBU.isEmpty) {
        Get.snackbar('Error', 'Por favor ingrese el CBU', backgroundColor: Colors.red.shade100);
        return;
      }
    } else if (field == 'phone') {
      if (newPhone.isEmpty) {
        Get.snackbar('Error', 'Por favor ingrese el teléfono', backgroundColor: Colors.red.shade100);
        return;
      }
    } else if (field == 'email') {
      if (newEmail.isEmpty) {
        Get.snackbar('Error', 'Por favor ingrese el correo electrónico', backgroundColor: Colors.red.shade100);
        return;
      }
      if (!RegExp(r'\S+@\S+\.\S+').hasMatch(newEmail)) {
        Get.snackbar('Error', 'Ingrese un correo electrónico válido', backgroundColor: Colors.red.shade100);
        return;
      }
    }

    await widget.beneficiary.reference.update({
      'name': newName.isEmpty ? _currentName : newName,
      'cbu': newCBU.isEmpty ? _currentCBU : newCBU,
      'phone': newPhone.isEmpty ? _currentPhone : newPhone,
      'email': newEmail.isEmpty ? _currentEmail : newEmail,
    });

    await controller.loadBeneficiaries();

    setState(() {
      if (field == 'name') {
        _currentName = newName;
        editingName = false;
      } else if (field == 'cbu') {
        _currentCBU = newCBU;
        editingCBU = false;
      } else if (field == 'phone') {
        _currentPhone = newPhone;
        editingPhone = false;
      } else if (field == 'email') {
        _currentEmail = newEmail;
        editingEmail = false;
      }
    });

    Get.snackbar('Beneficiario actualizado', 'El $field se actualizó correctamente',
        backgroundColor: Colors.green.shade100);
  }

  Widget _buildNameRow() {
    if (!editingName) {
      return Row(
        children: [
          Expanded(
            child: Text('Nombre: $_currentName', style: const TextStyle(fontSize: 16)),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            tooltip: 'Editar Nombre',
            onPressed: () {
              setState(() {
                editingName = true;
              });
            },
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: _detailController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            tooltip: 'Guardar Nombre',
            onPressed: () => _saveField('name'),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            tooltip: 'Cancelar',
            onPressed: () {
              setState(() {
                editingName = false;
                _detailController.text = _currentName;
              });
            },
          ),
        ],
      );
    }
  }

  Widget _buildCBURow() {
    if (!editingCBU) {
      return Row(
        children: [
          Expanded(
            child: Text('CBU: $_currentCBU', style: const TextStyle(fontSize: 16)),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            tooltip: 'Editar CBU',
            onPressed: () {
              setState(() {
                editingCBU = true;
              });
            },
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: _cbuController,
              decoration: const InputDecoration(
                labelText: 'CBU',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            tooltip: 'Guardar CBU',
            onPressed: () => _saveField('cbu'),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            tooltip: 'Cancelar',
            onPressed: () {
              setState(() {
                editingCBU = false;
                _cbuController.text = _currentCBU;
              });
            },
          ),
        ],
      );
    }
  }

  Widget _buildPhoneRow() {
    if (!editingPhone) {
      return Row(
        children: [
          Expanded(
            child: Text('Teléfono: $_currentPhone', style: const TextStyle(fontSize: 16)),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            tooltip: 'Editar Teléfono',
            onPressed: () {
              setState(() {
                editingPhone = true;
              });
            },
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            tooltip: 'Guardar Teléfono',
            onPressed: () => _saveField('phone'),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            tooltip: 'Cancelar',
            onPressed: () {
              setState(() {
                editingPhone = false;
                _phoneController.text = _currentPhone;
              });
            },
          ),
        ],
      );
    }
  }

  Widget _buildEmailRow() {
    if (!editingEmail) {
      return Row(
        children: [
          Expanded(
            child: Text('Email: $_currentEmail', style: const TextStyle(fontSize: 16)),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            tooltip: 'Editar Email',
            onPressed: () {
              setState(() {
                editingEmail = true;
              });
            },
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo Electrónico',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            tooltip: 'Guardar Email',
            onPressed: () => _saveField('email'),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            tooltip: 'Cancelar',
            onPressed: () {
              setState(() {
                editingEmail = false;
                _emailController.text = _currentEmail;
              });
            },
          ),
        ],
      );
    }
  }

  Widget _buildDetailFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNameRow(),
        const SizedBox(height: 12),
        _buildCBURow(),
        const SizedBox(height: 12),
        _buildPhoneRow(),
        const SizedBox(height: 12),
        _buildEmailRow(),
      ],
    );
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
              _buildDetailFields(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
