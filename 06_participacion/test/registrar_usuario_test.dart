import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_3/domain/entities/perfil.dart';
import 'package:flutter_application_3/domain/repositories/auth_repository.dart';
import 'package:flutter_application_3/domain/repositories/perfiles_repository.dart';
import 'package:flutter_application_3/domain/usecases/registrar_usuario.dart';

class AuthRepositoryFalso implements AuthRepository {
  final List<String> eventos;

  AuthRepositoryFalso(this.eventos);

  @override
  Future<String> registrar(String correo, String clave) async {
    eventos.add('registrar:$correo:$clave');
    return 'id-123';
  }

  @override
  Future<void> ingresar(String correo, String clave) async {}

  @override
  Future<void> salir() async {}

  @override
  String? obtenerIdActual() => null;
}

class PerfilesRepositoryFalso implements PerfilesRepository {
  final List<String> eventos;

  PerfilesRepositoryFalso(this.eventos);

  @override
  Future<void> crear(String id, String nombre) async {
    eventos.add('crear-perfil:$id:$nombre');
  }

  @override
  Future<List<Perfil>> obtenerTodos() async => const [];
}

void main() {
  test('crea primero la cuenta y luego el perfil con el id devuelto', () async {
    final eventos = <String>[];
    final casoDeUso = RegistrarUsuario(
      AuthRepositoryFalso(eventos),
      PerfilesRepositoryFalso(eventos),
    );

    await casoDeUso('ana@example.com', 'clave-segura', 'Ana');

    expect(eventos, [
      'registrar:ana@example.com:clave-segura',
      'crear-perfil:id-123:Ana',
    ]);
  });
}
