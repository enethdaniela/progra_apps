import 'package:flutter/material.dart';

import 'data/repositories/usuario_memoria.dart';
import 'domain/usecases/obtener_usuarios_con_vocal.dart';
import 'presentation/usuarios_page.dart';

void main() {
  runApp(
    MyApp(
      obtenerUsuariosConVocal: ObtenerUsuariosConVocal(UsuarioMemoria()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.obtenerUsuariosConVocal});

  final ObtenerUsuariosConVocal obtenerUsuariosConVocal;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Usuarios',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: UsuariosPage(obtenerUsuariosConVocal: obtenerUsuariosConVocal),
    );
  }
}
