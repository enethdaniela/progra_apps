import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_3/domain/entities/perfil.dart';
import 'package:flutter_application_3/domain/repositories/auth_repository.dart';
import 'package:flutter_application_3/domain/repositories/perfiles_repository.dart';
import 'package:flutter_application_3/domain/usecases/registrar_usuario.dart';
import 'package:flutter_application_3/presentation/pantallas/pantalla_ingreso.dart';
import 'package:flutter_application_3/presentation/pantallas/pantalla_usuarios.dart';
import 'package:flutter_application_3/presentation/providers/perfiles_provider.dart';
import 'package:flutter_application_3/presentation/providers/sesion_provider.dart';

class FakeAuthRepository implements AuthRepository {
  String? usuarioActual;
  String? errorIngreso;

  @override
  Future<String> registrar(String correo, String clave) async {
    usuarioActual = 'usuario-1';
    return usuarioActual!;
  }

  @override
  Future<void> ingresar(String correo, String clave) async {
    final error = errorIngreso;
    if (error != null) {
      throw FormatException(error);
    }
    usuarioActual = 'usuario-1';
  }

  @override
  Future<void> salir() async {
    usuarioActual = null;
  }

  @override
  String? obtenerIdActual() => usuarioActual;
}

class FakePerfilesRepository implements PerfilesRepository {
  final List<Perfil> perfilesCreados = [];
  List<Perfil> perfiles = [
    Perfil(id: 'usuario-1', nombre: 'Ana', creadoEn: DateTime.utc(2026, 1, 1)),
  ];

  @override
  Future<void> crear(String id, String nombre) async {
    final perfil = Perfil(
      id: id,
      nombre: nombre,
      creadoEn: DateTime.utc(2026, 1, 1),
    );
    perfilesCreados.add(perfil);
    perfiles = [...perfiles, perfil];
  }

  @override
  Future<List<Perfil>> obtenerTodos() async => perfiles;
}

Widget crearApp(
  FakeAuthRepository authRepository,
  FakePerfilesRepository perfilesRepository,
) {
  final registrarUsuario = RegistrarUsuario(authRepository, perfilesRepository);
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => SesionProvider(authRepository, registrarUsuario),
      ),
      ChangeNotifierProvider(
        create: (_) => PerfilesProvider(perfilesRepository),
      ),
    ],
    child: const MaterialApp(home: PantallaIngreso()),
  );
}

void main() {
  testWidgets('registra una cuenta y muestra la lista de perfiles', (
    tester,
  ) async {
    final authRepository = FakeAuthRepository();
    final perfilesRepository = FakePerfilesRepository();
    await tester.pumpWidget(crearApp(authRepository, perfilesRepository));

    await tester.enterText(
      find.byKey(const ValueKey('correo')),
      'ana@example.com',
    );
    await tester.enterText(find.byKey(const ValueKey('clave')), 'clave-segura');
    await tester.enterText(find.byKey(const ValueKey('nombre')), 'Ana nueva');
    await tester.tap(find.byKey(const ValueKey('crear-cuenta')));
    await tester.pumpAndSettle();

    expect(find.byType(PantallaUsuarios), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Ana nueva'), findsOneWidget);
    expect(perfilesRepository.perfilesCreados.single.nombre, 'Ana nueva');
  });

  testWidgets('muestra el error cuando falla el ingreso', (tester) async {
    final authRepository = FakeAuthRepository()
      ..errorIngreso = 'Credenciales inválidas';
    await tester.pumpWidget(crearApp(authRepository, FakePerfilesRepository()));

    await tester.enterText(
      find.byKey(const ValueKey('correo')),
      'ana@example.com',
    );
    await tester.enterText(find.byKey(const ValueKey('clave')), 'incorrecta');
    await tester.tap(find.byKey(const ValueKey('ingresar')));
    await tester.pumpAndSettle();

    expect(find.text('Credenciales inválidas'), findsOneWidget);
    expect(find.byType(PantallaIngreso), findsOneWidget);
  });

  testWidgets('carga perfiles y permite cerrar sesión', (tester) async {
    final authRepository = FakeAuthRepository()..usuarioActual = 'usuario-1';
    await tester.pumpWidget(crearApp(authRepository, FakePerfilesRepository()));
    await tester.pumpAndSettle();

    expect(find.byType(PantallaUsuarios), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget);
    await tester.tap(find.byTooltip('Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(find.byType(PantallaIngreso), findsOneWidget);
    expect(authRepository.usuarioActual, isNull);
  });
}
