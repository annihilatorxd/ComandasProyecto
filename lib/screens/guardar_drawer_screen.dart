import 'package:flutter/material.dart';
import 'package:prueba/provider/productos_provider.dart';

class GuardarDrawerScreen extends StatefulWidget {
  const GuardarDrawerScreen({super.key});

  @override
  State<GuardarDrawerScreen> createState() => _GuardarDrawerScreenState();
}

class _GuardarDrawerScreenState extends State<GuardarDrawerScreen> {
  final ProductosProvider provider = ProductosProvider();
  Map<String, List<Map<String, dynamic>>> categoriasProductos = {};
  List<dynamic> categorias = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      categorias = await provider.getCategorias();
      final productos = await provider.getProductos();
      _organizarPorCategoria(productos);
    } catch (e) {
      print('Error cargando datos: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _organizarPorCategoria(List<dynamic> productos) {
    Map<String, List<Map<String, dynamic>>> tempCategorias = {};
    for (var producto in productos) {
      final categoria = producto['categoria']['nombre'] ?? 'Sin Categoria';
      if (!tempCategorias.containsKey(categoria)) {
        tempCategorias[categoria] = [];
      }
      tempCategorias[categoria]!.add({
        'id_producto': producto['id_producto'],
        'nombre': producto['nombre'],
        'precio': producto['precio'],
        'ingredientes': producto['ingredientes']
      });
    }
    setState(() {
      categoriasProductos = tempCategorias;
    });
  }

  Future<void> _addCategoria(String nombre) async {
    try {
      await provider.addCategoria(nombre);
      await _loadData();
    } catch (e) {
      print('Error agregando categoria: $e');
    }
  }

  Future<void> _updateCategoria(int id, String nombre) async {
    try {
      await provider.updateCategoria(id, nombre);
      await _loadData();
    } catch (e) {
      print('Error actualizando categoria: $e');
    }
  }

  Future<void> _deleteCategoria(int id) async {
    try {
      await provider.deleteCategoria(id);
      await _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categoria eliminada correctamente')),
      );
    } catch (e) {
      print('Error eliminando categoria: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar la categoria')),
      );
    }
  }

  

  Future<void> _addProducto(
      String nombre, String ingredientes, int precio, int categoriaId) async {
    try {
      await provider.addProducto(nombre, ingredientes, precio, categoriaId);
      await _loadData();
    } catch (e) {
      print('Error agregando producto: $e');
    }
  }

  Future<void> _updateProducto(int id, String nombre, String ingredientes,
      int precio, int categoriaId) async {
    try {
      await provider.updateProducto(id, nombre, ingredientes, precio, categoriaId);
      await _loadData();
    } catch (e) {
      print('Error actualizando producto: $e');
    }
  }

  Future<void> _deleteProducto(int id) async {
    try {
      await provider.deleteProducto(id);
      await _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado correctamente')),
      );
    } catch (e) {
      print('Error eliminando producto: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error eliminando producto')),
      );
    }
  }

  void _showAddCategoriaDialog() {
    final TextEditingController categoriaController = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Agregar Categoria'),
              content: TextField(
                controller: categoriaController,
                decoration: InputDecoration(
                  labelText: 'Nombre de categoria',
                  errorText: errorText,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final nombreCategoria = categoriaController.text.trim();
                    if (nombreCategoria.isEmpty) {
                      setState(() {
                        errorText = 'La categoria no puede estar vacia';
                      });
                    } else {
                      _addCategoria(nombreCategoria);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Agregar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddProductoDialog() {
    final TextEditingController nombreController = TextEditingController();
    final TextEditingController ingredientesController = TextEditingController();
    final TextEditingController precioController = TextEditingController();
    int selectedCategoriaId = categorias.isNotEmpty ? categorias[0]['id'] : 0;

    String? errorNombre;
    String? errorIngredientes;
    String? errorPrecio;
    String? errorCategoria;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Agregar Producto'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre del producto',
                        errorText: errorNombre,
                      ),
                    ),
                    TextField(
                      controller: ingredientesController,
                      decoration: InputDecoration(
                        labelText: 'Ingredientes',
                        errorText: errorIngredientes,
                      ),
                    ),
                    TextField(
                      controller: precioController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Precio',
                        errorText: errorPrecio,
                      ),
                    ),
                    DropdownButtonFormField<int>(
                      value: selectedCategoriaId,
                      decoration: InputDecoration(
                        errorText: errorCategoria,
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedCategoriaId = value!;
                          errorCategoria = null;
                        });
                      },
                      items: categorias.map<DropdownMenuItem<int>>((categoria) {
                        return DropdownMenuItem<int>(
                          value: categoria['id'],
                          child: Text(categoria['nombre']),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final nombreProducto = nombreController.text.trim();
                    final ingredientes = ingredientesController.text.trim();
                    final precio = int.tryParse(precioController.text);

                    bool hasError = false;

                    setState(() {
                      if (nombreProducto.isEmpty) {
                        errorNombre = 'El nombre no puede estar vacio';
                        hasError = true;
                      } else {
                        errorNombre = null;
                      }
                      if (ingredientes.isEmpty) {
                        errorIngredientes = 'Los ingredientes no pueden estar vacios';
                        hasError = true;
                      } else {
                        errorIngredientes = null;
                      }
                      if (precio == null || precio <= 0) {
                        errorPrecio = 'El precio debe ser mayor a 0';
                        hasError = true;
                      } else {
                        errorPrecio = null;
                      }
                      if (selectedCategoriaId == 0) {
                        errorCategoria = 'Debe seleccionar una categoria';
                        hasError = true;
                      } else {
                        errorCategoria = null;
                      }
                    });

                    if (!hasError) {
                      _addProducto(
                        nombreProducto,
                        ingredientes,
                        precio!,
                        selectedCategoriaId,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Agregar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditCategoriaDialog(int id, String nombreActual) {
    final TextEditingController categoriaController =
        TextEditingController(text: nombreActual);
    String? errorText;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Editar Categoria'),
              content: TextField(
                controller: categoriaController,
                decoration: InputDecoration(
                  labelText: 'Nombre de categoria',
                  errorText: errorText,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final nombreCategoria = categoriaController.text.trim();
                    if (nombreCategoria.isEmpty) {
                      setState(() {
                        errorText = 'La categoria no puede estar vacia';
                      });
                    } else {
                      _updateCategoria(id, nombreCategoria);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditProductoDialog(int id, String nombreActual,
      String ingredientesActual, int precioActual, int categoriaIdActual) {
    final TextEditingController nombreController =
        TextEditingController(text: nombreActual);
    final TextEditingController ingredientesController =
        TextEditingController(text: ingredientesActual);
    final TextEditingController precioController =
        TextEditingController(text: precioActual.toString());
    int selectedCategoriaId = categoriaIdActual;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Editar Producto'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                    ),
                    TextField(
                      controller: ingredientesController,
                      decoration: const InputDecoration(labelText: 'Ingredientes'),
                    ),
                    TextField(
                      controller: precioController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Precio'),
                    ),
                    DropdownButtonFormField<int>(
                      value: selectedCategoriaId,
                      items: categorias.map<DropdownMenuItem<int>>((categoria) {
                        return DropdownMenuItem<int>(
                          value: categoria['id'],
                          child: Text(categoria['nombre']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategoriaId = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final nombre = nombreController.text.trim();
                    final ingredientes = ingredientesController.text.trim();
                    final precio = int.tryParse(precioController.text);
                    if (nombre.isNotEmpty &&
                        ingredientes.isNotEmpty &&
                        precio != null &&
                        precio > 0) {
                      _updateProducto(
                          id, nombre, ingredientes, precio, selectedCategoriaId);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Administrar productos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 23, 91, 146),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text(
                  'Categorias',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                for (var categoria in categorias)
                  ListTile(
                    title: Text(categoria['nombre']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditCategoriaDialog(
                              categoria['id'], categoria['nombre']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCategoria(categoria['id']),
                        ),
                      ],
                    ),
                  ),
                ElevatedButton(
                  onPressed: _showAddCategoriaDialog,
                  child: const Text('Agregar Categoria'),
                ),
                const Divider(height: 40),
                const Text(
                  'Productos',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                for (var entry in categoriasProductos.entries)
                  ExpansionTile(
                    title: Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: entry.value.map((producto) {
                      return ListTile(
                        title: Text(producto['nombre']),
                        subtitle: Text(
                            'Ingredientes: ${producto['ingredientes']}\nPrecio: \$${producto['precio']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditProductoDialog(
                                producto['id_producto'],
                                producto['nombre'],
                                producto['ingredientes'],
                                producto['precio'],
                                categorias.firstWhere(
                                    (cat) => cat['nombre'] == entry.key)['id'],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _deleteProducto(producto['id_producto']),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ElevatedButton(
                  onPressed: _showAddProductoDialog,
                  child: const Text('Agregar Producto'),
                ),
              ],
            ),
    );
  }
}
