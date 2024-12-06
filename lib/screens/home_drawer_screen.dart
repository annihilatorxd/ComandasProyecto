import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:prueba/screens/acerdade.dart';
import 'mesas_disponibles_drawer_screen.dart';
import 'guardar_drawer_screen.dart';
import 'historial_drawer_screen.dart';
import 'login_screen.dart';

class HomeDrawerScreen extends StatelessWidget {
  const HomeDrawerScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); 
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false, 
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesion: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Restaurant Comandas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 23, 91, 146),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              '¡Bienvenido a Restaurant Comandas!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'En esta aplicacion puedes:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  _buildTutorialItem(Icons.table_bar, 'Realizar comandas para las mesas.'),
                  _buildTutorialItem(Icons.fastfood, 'Agregar, editar y eliminar productos.'),
                  _buildTutorialItem(Icons.history, 'Ver el historial de ventas.'),
                  _buildTutorialItem(Icons.info, 'Consultar informacion acerca de la app.'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                padding: const EdgeInsets.all(20),
                children: [
                  Image.asset('assets/images/chorrillana.jpg', fit: BoxFit.cover),
                  Image.asset('assets/images/completo-italiano.jpg', fit: BoxFit.cover),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        image: AssetImage('assets/images/restaurant_icon.jpg'),
                      ),
                      border: Border.all(width: 2.0, color: Colors.blue),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      'Menú Administrativo',
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Mesas'),
              leading: const Icon(Icons.table_bar),
              onTap: () => _navegar(context, 1),
            ),
            const Divider(),
            ListTile(
              title: const Text('Administrar productos'),
              leading: const Icon(Icons.fastfood),
              onTap: () => _navegar(context, 2),
            ),
            const Divider(),
            ListTile(
              title: const Text('Historial'),
              leading: const Icon(Icons.history),
              onTap: () => _navegar(context, 3),
            ),
            const Divider(),
            ListTile(
              title: const Text('Acerca de'),
              leading: const Icon(Icons.info),
              onTap: () => _navegar(context, 4),
            ),
            const Divider(),
            ListTile(
              title: const Text('Cerrar sesion'),
              leading: const Icon(Icons.exit_to_app),
              onTap: () => _logout(context), 
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navegar(BuildContext context, int pagina) {
    List<Widget> paginas = [
      MesasDisponiblesDrawerScreen(),
      GuardarDrawerScreen(),
      HistorialDrawerScreen(),
      AcercaDeScreen(),
      LoginScreen(),
    ];

    if (pagina >= 1 && pagina <= paginas.length) {
      final route = MaterialPageRoute(builder: (context) {
        return paginas[pagina - 1];
      });
      Navigator.pop(context);
      Navigator.push(context, route);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pagina invalida seleccionada')),
      );
    }
  }
}
