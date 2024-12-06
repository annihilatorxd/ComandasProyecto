import 'package:flutter/material.dart';
import 'ingreso_compra_drawer_screen.dart';

class MesasDisponiblesDrawerScreen extends StatefulWidget {
  const MesasDisponiblesDrawerScreen({super.key});

  @override
  State<MesasDisponiblesDrawerScreen> createState() =>
      _MesasDisponiblesDrawerScreenState();
}

class _MesasDisponiblesDrawerScreenState
    extends State<MesasDisponiblesDrawerScreen> {
  Map<int, List<Map<String, dynamic>>> carritosPorMesa = {};
  List<bool> mesasOcupadas = List.generate(6, (index) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Mesas',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 23, 91, 146),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.blue],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 20.0,
              mainAxisSpacing: 20.0,
              childAspectRatio: 1.0,
            ),
            itemCount: mesasOcupadas.length,
            itemBuilder: (context, index) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(
                    color: mesasOcupadas[index] ? Colors.red : Colors.green,
                    width: 5.0,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IngresoCompraDrawerScreen(
                          mesaNumero: index + 1,
                          carrito: carritosPorMesa[index + 1] ?? [],
                          onGuardarCompra: (carritoActualizado) {
                            setState(() {
                              carritosPorMesa[index + 1] = carritoActualizado;
                              mesasOcupadas[index] = true;
                            });
                          },
                          onFinalizarCompra: () {
                            setState(() {
                              carritosPorMesa.remove(index + 1);
                              mesasOcupadas[index] = false;
                            });
                          },
                        ),
                      ),
                    );
                  },
                  child: Center(
                    child: Text(
                      'Mesa ${index + 1}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
