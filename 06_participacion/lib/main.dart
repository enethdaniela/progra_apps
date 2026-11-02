import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/repositories/supabase_auth_repository.dart';
import 'data/repositories/supabase_perfiles_repository.dart';
import 'domain/usecases/registrar_usuario.dart';
import 'presentation/pantallas/pantalla_ingreso.dart';
import 'presentation/providers/perfiles_provider.dart';
import 'presentation/providers/sesion_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  final supabaseUrl = dotenv.env['SUPABASE_URL']?.trim();
  final supabaseKey = dotenv.env['SUPABASE_KEY']?.trim();
  if (supabaseUrl == null ||
      supabaseUrl.isEmpty ||
      supabaseKey == null ||
      supabaseKey.isEmpty) {
    throw StateError(
      'Configura SUPABASE_URL y SUPABASE_KEY en el archivo .env.',
    );
  }

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseKey,
  );

  final authRepo = SupabaseAuthRepository();
  final perfilesRepo = SupabasePerfilesRepository();
  final registrarUsuario = RegistrarUsuario(authRepo, perfilesRepo);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SesionProvider(authRepo, registrarUsuario),
        ),
        ChangeNotifierProvider(
          create: (_) => PerfilesProvider(perfilesRepo),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Usuarios USFQ',
      home: const PantallaIngreso(),
    );
  }
}
