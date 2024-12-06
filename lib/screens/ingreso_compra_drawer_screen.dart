import 'package:flutter/material.dart';
import 'package:prueba/provider/productos_provider.dart';
import 'carrito_compra_screen.dart';

class IngresoCompraDrawerScreen extends StatefulWidget {
  final int mesaNumero;
  final List<Map<String, dynamic>> carrito;
  final Function(List<Map<String, dynamic>>) onGuardarCompra;
  final Function onFinalizarCompra;

  const IngresoCompraDrawerScreen({
    Key? key,
    required this.mesaNumero,
    required this.carrito,
    required this.onGuardarCompra,
    required this.onFinalizarCompra,
  }) : super(key: key);

  @override
  State<IngresoCompraDrawerScreen> createState() =>
      _IngresoCompraDrawerScreenState();
}

class _IngresoCompraDrawerScreenState extends State<IngresoCompraDrawerScreen> {
  late List<Map<String, dynamic>> carrito;
  final ProductosProvider provider = ProductosProvider();

  Map<String, List<Map<String, dynamic>>> categorias = {};
  bool isLoading = true;

  
  @override
  void initState() {
    super.initState();
    carrito = List.from(widget.carrito);
    _loadProductos();
  }

  Future<void> _loadProductos() async {
    setState(() {
      isLoading = true;
    });
    try {
      final productos = await provider.getProductos();
      _organizarPorCategoria(productos);
    } catch (error) {
      print('Error al cargar productos: $error');
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
        'id': producto['id_producto'],
        'nombre': producto['nombre'],
        'precio': producto['precio'],
        'ingredientes': producto['ingredientes']
      });
    }
    setState(() {
      categorias = tempCategorias;
    });
  }

  void _showAddToCartDialog(String titulo, int precio, String ingredientes) {
    TextEditingController cantidadController = TextEditingController(text: '1');
    TextEditingController comentarioController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar $titulo al carrito'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cantidadController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cantidad'),
              ),
              TextField(
                controller: comentarioController,
                decoration: const InputDecoration(labelText: 'Comentario'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  carrito.add({
                    'nombre': titulo,
                    'precio': precio,
                    'cantidad': int.tryParse(cantidadController.text) ?? 1,
                    'comentario': comentarioController.text,
                  });
                });
                Navigator.pop(context);
              },
              child: const Text('Agregar al carrito'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mesa ${widget.mesaNumero}'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 255, 255, 255), Color.fromARGB(255, 255, 255, 255)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CarritoCompraScreen(
                        carrito: carrito,
                        onGuardarCompra: (carritoActualizado) {
                          setState(() {
                            carrito = carritoActualizado;
                          });
                          widget.onGuardarCompra(carritoActualizado);
                        },
                        onFinalizarCompra: widget.onFinalizarCompra,
                      ),
                    ),
                  );
                },
              ),
              if (carrito.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '${carrito.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color.fromARGB(255, 255, 255, 255)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: ListView(
                children: categorias.entries.map((entry) {
                  final categoria = entry.key;
                  final productos = entry.value;

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    color:  const Color.fromARGB(255, 22, 174, 201),
                    child: ExpansionTile(
                      title: Text(
                        categoria,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      children: productos.map((producto) {
                        return ListTile(
                          title: Text(
                            producto['nombre'],
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            producto['ingredientes'],
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: Text(
                            '\$${producto['precio']}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            _showAddToCartDialog(
                              producto['nombre'],
                              producto['precio'],
                              producto['ingredientes'],
                            );
                          },
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }
}
