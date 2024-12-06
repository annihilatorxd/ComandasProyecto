import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductosProvider {
  final String apiURL = 'http://10.0.2.2:8000/api';

  Future<List<dynamic>> getProductos() async {
    var uri = Uri.parse('$apiURL/productos');
    var respuesta = await http.get(uri);
    if (respuesta.statusCode == 200) {
      return json.decode(respuesta.body);
    } else {
      throw Exception('Error al obtener productos: ${respuesta.body}');
    }
  }

  Future<List<dynamic>> getCategorias() async {
    var uri = Uri.parse('$apiURL/categorias');
    var respuesta = await http.get(uri);
    if (respuesta.statusCode == 200) {
      return json.decode(respuesta.body);
    } else {
      throw Exception('Error al obtener categorías: ${respuesta.body}');
    }
  }

  Future<void> addCategoria(String nombre) async {
    var uri = Uri.parse('$apiURL/categorias');
    var respuesta = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'nombre': nombre}),
    );

    if (respuesta.statusCode != 201) {
      throw Exception('Error al agregar categoría: ${respuesta.body}');
    }
  }
  
  Future<void> updateCategoria(int id, String nombre) async {
    try {
      var uri = Uri.parse('$apiURL/categorias/$id');
      var respuesta = await http.put(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'nombre': nombre}),
      );

      if (respuesta.statusCode != 200) {
        throw Exception('Error al modificar categoría: ${respuesta.body}');
      }
    } catch (e) {
      throw Exception('Error al conectar con la API: $e');
    }
  }

 
  Future<void> deleteCategoria(int id) async {
  final uri = Uri.parse('$apiURL/categorias/$id');
  final response = await http.delete(uri, headers: {"Content-Type": "application/json"});

  if (response.statusCode != 200) {
    print('Error al eliminar categoría: ${response.body}');
    throw Exception('Error al eliminar categoría');
  }

  print('Respuesta del servidor: ${response.body}');
}




  
  Future<void> addProducto(String nombre, String ingredientes, int precio, int categoriaId) async {
    var uri = Uri.parse('$apiURL/productos');
    var respuesta = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'nombre': nombre,
        'ingredientes': ingredientes,
        'precio': precio,
        'categoria_id': categoriaId,
      }),
    );

    if (respuesta.statusCode != 201) {
      throw Exception('Error al agregar producto: ${respuesta.body}');
    }
  }

  
  Future<void> updateProducto(int id, String nombre, String ingredientes,
      int precio, int categoriaId) async {
    try {
      var uri = Uri.parse('$apiURL/productos/$id');
      var respuesta = await http.put(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'nombre': nombre,
          'ingredientes': ingredientes,
          'precio': precio,
          'categoria_id': categoriaId,
        }),
      );

      if (respuesta.statusCode != 200) {
        throw Exception('Error al modificar producto: ${respuesta.body}');
      }
    } catch (e) {
      throw Exception('Error al conectar con la API: $e');
    }
  }

  
  Future<void> deleteProducto(int id) async {
  final uri = Uri.parse('$apiURL/productos/$id');
  final response = await http.delete(uri, headers: {"Content-Type": "application/json"});

  print('Respuesta del servidor: ${response.body}');

  if (response.statusCode != 200) {
    throw Exception('Error al eliminar producto: ${response.body}');
  }
}





  
  Future<void> guardarHistorial(
      List<Map<String, dynamic>> productos, double montoTotal) async {
    try {
      var uri = Uri.parse('$apiURL/historial_ventas');
      var respuesta = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'productos': productos.map((p) => p['nombre']).toList(),
          'monto_total': montoTotal,
          'fecha_compra': DateTime.now().toIso8601String(),
        }),
      );

      if (respuesta.statusCode != 201) {
        throw Exception('Error al guardar el historial: ${respuesta.body}');
      }
    } catch (e) {
      throw Exception('Error al conectar con la API: $e');
    }
  }

  
  Future<List<dynamic>> getHistorialVentas() async {
    try {
      var uri = Uri.parse('$apiURL/historial_ventas');
      var respuesta = await http.get(uri);
      if (respuesta.statusCode == 200) {
        return json.decode(respuesta.body);
      } else {
        throw Exception(
            'Error al obtener el historial de ventas: ${respuesta.body}');
      }
    } catch (e) {
      throw Exception('Error al conectar con la API: $e');
    }
  }
}
