import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class CarritoCompraScreen extends StatefulWidget {
  final List<Map<String, dynamic>> carrito;
  final Function(List<Map<String, dynamic>>) onGuardarCompra;
  final Function onFinalizarCompra;

  const CarritoCompraScreen({
    super.key,
    required this.carrito,
    required this.onGuardarCompra,
    required this.onFinalizarCompra,
  });

  @override
  State<CarritoCompraScreen> createState() => _CarritoCompraScreenState();
}

class _CarritoCompraScreenState extends State<CarritoCompraScreen> {
  Future<void> _guardarHistorial() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/historial_ventas');

    final productosFormateados = widget.carrito.map((item) {
      return '${item['nombre']}, Cantidad: ${item['cantidad']}, Comentarios: ${item['comentario'] ?? 'sin comentarios'}';
    }).join('\n');

    final total = widget.carrito.fold(0.0, (sum, item) {
      final precio = item['precio'] ?? 0;
      final cantidad = item['cantidad'] ?? 0;
      return sum + (precio * cantidad);
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'productos': productosFormateados,
          'monto_total': total,
          'fecha_compra': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        print('Historial guardado correctamente');
      } else {
        print('Error al guardar el historial: ${response.body}');
      }
    } catch (error) {
      print('Error al guardar el historial: $error');
    }
  }

  void _mostrarNotificacion(BuildContext context, String mensaje) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            color: Colors.green,
            padding: const EdgeInsets.all(16.0),
            child: Text(
              mensaje,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    
    overlay.insert(overlayEntry);

    
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
   
    double total = widget.carrito.fold(0, (sum, item) {
      return sum + (item['precio'] * item['cantidad']);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras',style: TextStyle(color: Colors.white,)),
        backgroundColor: const Color.fromARGB(255, 23, 91, 146),
      ),
      body: ListView.builder(
        itemCount: widget.carrito.length,
        itemBuilder: (context, index) {
          final item = widget.carrito[index];
          return ListTile(
            leading: const Icon(Icons.fastfood),
            title: Text(item['nombre']),
            subtitle: Text(
              'Cantidad: ${item['cantidad']}\nComentario: ${item['comentario'] ?? ''}',
            ),
            trailing: Text('\$${item['precio'] * item['cantidad']}'),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Total: \$${total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                widget.onGuardarCompra(widget.carrito); 
                _mostrarNotificacion(
                    context, 'Se ha realizado un pedido en la mesa seleccionada');
                Navigator.pop(context);
                Navigator.pop(context); 
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 23, 91, 146)),
              child: const Text('Guardar',style: TextStyle(color: Colors.white,)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await _guardarHistorial(); 
                widget.onFinalizarCompra(); 
                Navigator.pop(context); 
                Navigator.pop(context); 
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Finalizar Compra',style: TextStyle(color: Colors.white,)),
            ),
          ],
        ),
      ),
    );
  }
}
