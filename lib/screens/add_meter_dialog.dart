import 'package:flutter/material.dart';

import '../models/meter.dart';
import '../viewmodels/home_view_model.dart';

class AddMeterDialog extends StatefulWidget {
  const AddMeterDialog({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  State<AddMeterDialog> createState() => _AddMeterDialogState();
}

class _AddMeterDialogState extends State<AddMeterDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();

  ResourceType _selectedType = ResourceType.water;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _saveMeter() async {
    if (_saving || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await widget.viewModel.addMeter(
        name: _nameController.text,
        type: _selectedType,
        number: _numberController.text,
      );

      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось сохранить счётчик: $error')),
      );

      setState(() {
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Новый счётчик'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Название',
                  hintText: 'Например, Холодная вода',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите название';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(labelText: 'Номер счётчика'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите номер';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ResourceType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'Тип ресурса'),
                items: ResourceType.values
                    .where((type) => type != ResourceType.all)
                    .map(
                      (type) => DropdownMenuItem<ResourceType>(
                        value: type,
                        child: Text(type.title),
                      ),
                    )
                    .toList(),
                onChanged: _saving
                    ? null
                    : (value) {
                        if (value == null) return;

                        setState(() {
                          _selectedType = value;
                        });
                      },
              ),
              const SizedBox(height: 12),
              const Text(
                'Тариф будет определён автоматически '
                'по региону и типу ресурса.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: _saving ? null : _saveMeter,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Сохранить'),
        ),
      ],
    );
  }
}
