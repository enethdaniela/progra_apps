// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_2/main.dart';
import 'package:flutter_application_2/domain/entities/usuario.dart';
import 'package:flutter_application_2/domain/repositories/usuario_repository.dart';
import 'package:flutter_application_2/domain/usecases/obtener_usuarios_con_vocal.dart';

class RepositorioDePrueba implements UsuarioRepository {
  @override
  Future<List<Usuario>> obtener() async => const [];
}

void main() {
  testWidgets('Muestra la pantalla de usuarios', (WidgetTester tester) async {
    final casoDeUso = ObtenerUsuariosConVocal(RepositorioDePrueba());
    await tester.pumpWidget(MyApp(obtenerUsuariosConVocal: casoDeUso));

    expect(find.text('Usuarios cuyo nombre empieza con vocal'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
