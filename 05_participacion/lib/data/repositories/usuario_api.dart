import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/usuario.dart';
import '../../domain/repositories/usuario_repository.dart';

class UsuarioApi implements UsuarioRepository {
  static final Uri _url = Uri.parse(
    'https://jsonplaceholder.typicode.com/users',
  );

  @override
  Future<List<Usuario>> obtener() async {
    final respuesta = await http.get(_url);

    if (respuesta.statusCode != 200) {
      throw Exception('No se pudieron cargar los usuarios');
    }

    final datos = jsonDecode(respuesta.body) as List<dynamic>;
    return datos.map((dato) {
      final usuario = dato as Map<String, dynamic>;
      return Usuario(
        id: usuario['id'] as int,
        nombre: usuario['name'] as String,
        email: usuario['email'] as String,
      );
    }).toList();
  }
}
