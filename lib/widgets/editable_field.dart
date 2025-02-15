import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditableField extends StatefulWidget {
  final DocumentSnapshot expense;
  final String fieldName;
  final String label;
  final bool isNumber;
  final bool isCurrency;
  final String? Function(dynamic)? displayFormat;
  final Function(DocumentSnapshot) onUpdate;
  final String collectionName;
  final Future<bool>? validationFuture;
  final String? validationErrorMessage;

  const EditableField({
    super.key,
    required this.expense,
    required this.fieldName,
    required this.label,
    required this.onUpdate,
    required this.collectionName,
    this.isNumber = false,
    this.isCurrency = false,
    this.displayFormat,
    this.validationFuture,
    this.validationErrorMessage,
  });

  @override
  _EditableFieldState createState() => _EditableFieldState();
}

class _EditableFieldState extends State<EditableField> {
  bool isEditing = false;
  late TextEditingController controller;
  late FocusNode focusNode;
  dynamic currentValue;
  final currencyFormat = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 2,
  );
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    currentValue = (widget.expense.data() as Map<String, dynamic>?)?.containsKey(widget.fieldName) == true
        ? widget.expense[widget.fieldName]
        : '';
    String displayValue = _getDisplayValue(currentValue);
    controller = TextEditingController(text: displayValue);
    focusNode = FocusNode();
  }

  String _getDisplayValue(dynamic value) {
    if (widget.isCurrency && value != null) {
      return value.toString().replaceAll(RegExp(r'[^\d.]'), '');
    }
    return widget.isNumber && value != null ? value.toString().replaceAll(',', '') : (value?.toString() ?? '');
  }

  String _formatDisplayText(dynamic value) {
    if (widget.isCurrency && value != null) {
      final numValue = double.tryParse(value.toString()) ?? 0.0;
      return "\$${NumberFormat('#,##0.00', 'es_CO').format(numValue)}";
    }
    return widget.displayFormat != null
        ? widget.displayFormat!(value) ?? 'No disponible'
        : (value?.toString() ?? 'No disponible');
  }

  @override
  void didUpdateWidget(covariant EditableField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newValue = (widget.expense.data() as Map<String, dynamic>?)?.containsKey(widget.fieldName) == true
        ? widget.expense[widget.fieldName]
        : '';
    if (newValue != currentValue) {
      setState(() {
        currentValue = newValue;
        controller.text = _getDisplayValue(currentValue);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            widget.label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          child: isEditing
              ? Container(
                  padding: EdgeInsets.zero,
                  child: TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: widget.isNumber ? TextInputType.number : TextInputType.text,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: widget.fieldName == 'observations' ? 12 : 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      errorText: errorMessage,
                    ),
                    onFieldSubmitted: widget.fieldName == 'observations' ? null : (_) => saveChanges(),
                    onChanged: (value) {
                      if (widget.isNumber || widget.isCurrency) {
                        try {
                          double.parse(value.replaceAll(',', ''));
                          setState(() {
                            errorMessage = null;
                          });
                        } catch (e) {
                          setState(() {
                            errorMessage = "Valor inválido";
                          });
                        }
                      }
                    },
                  ),
                )
              : Padding(
                  padding: EdgeInsets.zero,
                  child: Text(
                    _formatDisplayText(currentValue),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
        ),
        if (widget.validationFuture != null)
          FutureBuilder<bool>(
            future: widget.validationFuture,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              bool isValid = snapshot.data ?? true;
              if (!isValid) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Tooltip(
                    message: widget.validationErrorMessage ?? 'Valor inválido',
                    child: const Icon(Icons.warning, color: Colors.red),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        if (isEditing) ...[
          IconButton(
            icon: Icon(Icons.check, color: errorMessage != null ? Colors.grey : Colors.green),
            onPressed: errorMessage != null ? null : saveChanges,
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () {
              setState(() {
                controller.text = _getDisplayValue(currentValue);
                isEditing = false;
                focusNode.unfocus();
              });
            },
          ),
        ] else
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              setState(() {
                isEditing = true;
                controller.text = _getDisplayValue(currentValue);
              });
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (focusNode.canRequestFocus) {
                  focusNode.requestFocus();
                }
              });
            },
          ),
      ],
    );
  }

  @override
  void dispose() {
    focusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<void> saveChanges() async {
    final docRef = FirebaseFirestore.instance.collection(widget.collectionName).doc(widget.expense.id);
    final value = widget.isNumber ? double.parse(controller.text.replaceAll(',', '')) : controller.text;
    await docRef.update({widget.fieldName: value});
    setState(() {
      currentValue = value;
      isEditing = false;
    });
  }
} 