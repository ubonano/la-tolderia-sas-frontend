import 'package:flutter/material.dart';

class EditableDropdown extends StatefulWidget {
  final String label;
  final String initialValue;
  final List<String> options;
  final Future<void> Function(String) onSave;
  final TextStyle Function(String)? optionTextStyle;

  const EditableDropdown({
    super.key,
    required this.label,
    required this.initialValue,
    required this.options,
    required this.onSave,
    this.optionTextStyle,
  });

  @override
  _EditableDropdownState createState() => _EditableDropdownState();
}

class _EditableDropdownState extends State<EditableDropdown> {
  bool isEditing = false;
  late String currentValue;
  late String selectedValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.initialValue;
    selectedValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant EditableDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        currentValue = widget.initialValue;
        selectedValue = widget.initialValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isEditing) {
      return Row(
        mainAxisSize: MainAxisSize.min,
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
            child: Text(
              currentValue,
              style: widget.optionTextStyle != null
                  ? widget.optionTextStyle!(currentValue)
                  : const TextStyle(fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              setState(() {
                isEditing = true;
                selectedValue = currentValue;
              });
            },
          ),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
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
            child: DropdownButton<String>(
              value: selectedValue,
              isExpanded: true,
              items: widget.options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style:
                        widget.optionTextStyle != null ? widget.optionTextStyle!(value) : const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedValue = newValue;
                  });
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () async {
              await widget.onSave(selectedValue);
              setState(() {
                currentValue = selectedValue;
                isEditing = false;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () {
              setState(() {
                isEditing = false;
              });
            },
          ),
        ],
      );
    }
  }
} 