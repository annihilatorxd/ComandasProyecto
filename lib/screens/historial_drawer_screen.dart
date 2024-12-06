import 'package:flutter/material.dart';
import 'package:prueba/provider/productos_provider.dart';

class HistorialDrawerScreen extends StatefulWidget {
  const HistorialDrawerScreen({super.key});

  @override
  State<HistorialDrawerScreen> createState() => _HistorialDrawerScreenState();
}

class _HistorialDrawerScreenState extends State<HistorialDrawerScreen> {
  final ProductosProvider provider = ProductosProvider();
  List<dynamic> historialVentas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistorialVentas();
  }

  Future<void> _loadHistorialVentas() async {
    setState(() {
      isLoading = true;
    });
    try {
      historialVentas = await provider.getHistorialVentas();
    } catch (error) {
      print('Error al cargar el historial de ventas: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Historial',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 23, 91, 146),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : historialVentas.isEmpty
              ? const Center(
                  child: Text('No se encontraron ventas en el historial.'),
                )
              : ListView.builder(
                  itemCount: historialVentas.length,
                  itemBuilder: (context, index) {
                    final venta = historialVentas[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(
                          'Fecha: ${venta['fecha_compra']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Productos: ${venta['productos']}'),
                            Text('Monto total: \$${venta['monto_total']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
