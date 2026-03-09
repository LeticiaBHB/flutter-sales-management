import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../models/product.dart';
import '../../../providers/product_provider.dart';
import '../../widgets/image_display_widget.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  final Product? product;
  const ProductFormPage({super.key, this.product});
  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descController;
  late TextEditingController _valorController;
  late TextEditingController _estoqueController;
  List<String> _selectedImages = [];

  @override
  void initState() {
    super.initState();

    _descController =
        TextEditingController(text: widget.product?.descricao ?? '');
    _valorController =
        TextEditingController(text: widget.product?.valorVenda.toString() ?? '');
    _estoqueController =
        TextEditingController(text: widget.product?.estoque.toString() ?? '');
    _selectedImages = List<String>.from(widget.product?.imagens ?? []);
  }

  @override
  void dispose() {
    _descController.dispose();
    _valorController.dispose();
    _estoqueController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final images = await ref.read(productProvider.notifier).pickImages();
    setState(() {
      _selectedImages = images;
    });
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: widget.product?.id ?? const Uuid().v4(),
        descricao: _descController.text,
        valorVenda: double.tryParse(_valorController.text) ?? 0,
        estoque: int.tryParse(_estoqueController.text) ?? 0,
        imagens: _selectedImages,
      );
      ref.read(productProvider.notifier).saveProduct(product);
      Navigator.pop(context);
    }
  }

  Widget _buildImagePreview(String path) {
    if (kIsWeb) {
      return ImageDisplayWidget(imagePath: path);
    }
    try {
      final file = File(path);
      if (!file.existsSync()) {
        return const Icon(Icons.broken_image, size: 50);
      }
      return ImageDisplayWidget(imagePath: path);
    } catch (_) {
      return const Icon(Icons.broken_image, size: 50);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Novo Produto' : 'Editar Produto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                key: const Key('descricaoField'),
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              TextFormField(
                key: const Key('valorField'),
                controller: _valorController,
                decoration: const InputDecoration(labelText: 'Valor de Venda'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              TextFormField(
                key: const Key('estoqueField'),
                controller: _estoqueController,
                decoration: const InputDecoration(labelText: 'Estoque'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 20),
              const Text('Imagens'),
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.photo_library),
                label: const Text('Upload da Galeria'),
              ),
              const SizedBox(height: 10),
              Wrap(
                children: _selectedImages.map((path) {
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: SizedBox(
                      width: 70,
                      height: 70,
                      child: _buildImagePreview(path),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                key: const Key('saveProductButton'),
                onPressed: _save,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}