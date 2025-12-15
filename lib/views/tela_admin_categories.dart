import 'package:flutter/material.dart';
import '../controllers/category_controller.dart';
import '../models/category.dart';

class TelaAdminCategories extends StatefulWidget {
  const TelaAdminCategories({super.key});

  @override
  State<TelaAdminCategories> createState() => _TelaAdminCategoriesState();
}

class _TelaAdminCategoriesState extends State<TelaAdminCategories> {
  final CategoryController _controller = CategoryController();
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    final categories = await _controller.getAll();
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  Future<String?> _selectDate(BuildContext context, String? initialDate) async {
    DateTime? selectedDate;
    if (initialDate != null && initialDate.isNotEmpty) {
      selectedDate = DateTime.tryParse(initialDate);
    }
    selectedDate ??= DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      return '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
    return null;
  }

  Future<void> _openForm({Category? category}) async {
    final titleController = TextEditingController(text: category?.title ?? '');
    final descriptionController = TextEditingController(text: category?.description ?? '');
    final startDateController = TextEditingController(text: category?.startDate ?? '');
    final endDateController = TextEditingController(text: category?.endDate ?? '');
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                category == null ? Icons.add_circle : Icons.edit,
                color: Colors.purple.shade700,
              ),
              const SizedBox(width: 12),
              Text(category == null ? 'Criar Categoria' : 'Editar Categoria'),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Título',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.emoji_events),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Preencha o título' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Descrição',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: startDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Data de Início',
                      hintText: 'YYYY-MM-DD',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.calendar_today),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_month),
                        onPressed: () async {
                          final date = await _selectDate(context, startDateController.text);
                          if (date != null) {
                            startDateController.text = date;
                          }
                        },
                      ),
                    ),
                    onTap: () async {
                      final date = await _selectDate(context, startDateController.text);
                      if (date != null) {
                        startDateController.text = date;
                      }
                    },
                    validator: (value) => (value == null || value.isEmpty) ? 'Preencha a data de início' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: endDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Data de Fim',
                      hintText: 'YYYY-MM-DD',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.event),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_month),
                        onPressed: () async {
                          final date = await _selectDate(context, endDateController.text);
                          if (date != null) {
                            endDateController.text = date;
                          }
                        },
                      ),
                    ),
                    onTap: () async {
                      final date = await _selectDate(context, endDateController.text);
                      if (date != null) {
                        endDateController.text = date;
                      }
                    },
                    validator: (value) => (value == null || value.isEmpty) ? 'Preencha a data de fim' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.purple.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (saved != true) return;

    final newCategory = Category(
      category?.id,
      1, 
      titleController.text,
      descriptionController.text,
      startDateController.text,
      endDateController.text,
    );

    if (category == null) {
      await _controller.insert(newCategory);
    } else {
      await _controller.update(newCategory);
    }

    _loadCategories();
  }

  Future<void> _deleteCategory(int id) async {
    await _controller.delete(id);
    _loadCategories();
  }

  Widget _buildCategoryCard(Category category) {
    final startDate = category.startDate != null
        ? DateTime.tryParse(category.startDate!)
        : null;
    final endDate = category.endDate != null
        ? DateTime.tryParse(category.endDate!)
        : null;
    
    final now = DateTime.now();
    final isActive = startDate != null &&
        endDate != null &&
        now.isAfter(startDate) &&
        now.isBefore(endDate);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openForm(category: category),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isActive
                  ? [Colors.purple.shade700, Colors.purple.shade900]
                  : [Colors.grey.shade700, Colors.grey.shade900],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category.title ?? 'Sem título',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green.shade400
                            : Colors.red.shade400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isActive ? 'ATIVA' : 'INATIVA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red.shade300),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Excluir Categoria'),
                            content: Text('Deseja realmente excluir "${category.title}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text('Excluir', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          _deleteCategory(category.id!);
                        }
                      },
                    ),
                  ],
                ),
                if (category.description != null &&
                    category.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    category.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      startDate != null
                          ? '${startDate.day}/${startDate.month}/${startDate.year}'
                          : 'Sem data',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.event, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      endDate != null
                          ? '${endDate.day}/${endDate.month}/${endDate.year}'
                          : 'Sem data',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade900,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Categorias',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gerenciar categorias de premiação',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FloatingActionButton(
                      onPressed: () => _openForm(),
                      backgroundColor: Colors.amber.shade600,
                      child: const Icon(Icons.add, size: 28),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Colors.amber.shade600,
                        ),
                      )
                    : _categories.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.emoji_events_outlined,
                                  size: 80,
                                  color: Colors.white30,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Nenhuma categoria cadastrada',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: () => _openForm(),
                                  icon: Icon(Icons.add),
                                  label: Text('Adicionar primeira categoria'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.amber.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadCategories,
                            color: Colors.amber.shade600,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(24),
                              itemCount: _categories.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                return _buildCategoryCard(_categories[index]);
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
