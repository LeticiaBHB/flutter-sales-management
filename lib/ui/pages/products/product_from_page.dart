import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teste_vagacrud/ui/widgets/image_display_widget.dart';
import 'package:uuid/uuid.dart';
import '../../../models/product.dart';
import '../../../providers/product_provider.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  final Product? product; // Se for nulo, é criação. Se tiver valor, é edição.

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
    _descController = TextEditingController(text: widget.product?.descricao ?? '');
    _valorController = TextEditingController(text: widget.product?.valorVenda.toString() ?? '');
    _estoqueController = TextEditingController(text: widget.product?.estoque.toString() ?? '');
    _selectedImages = widget.product?.imagens ?? [];
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
        valorVenda: double.parse(_valorController.text),
        estoque: int.parse(_estoqueController.text),
        imagens: _selectedImages,
      );
      
      ref.read(productProvider.notifier).saveProduct(product);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product == null ? 'Novo Produto' : 'Editar Produto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              TextFormField(
                controller: _valorController,
                decoration: const InputDecoration(labelText: 'Valor de Venda'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              TextFormField(
                controller: _estoqueController,
                decoration: const InputDecoration(labelText: 'Estoque'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 20),
              const Text('Imagens'),
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.photo_library),
                label: const Text('Upload da Galeria'),
              ),
              // Preview simples das imagens
              Wrap(
                children: _selectedImages.map((path) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ImageDisplayWidget(imagePath: path)
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
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