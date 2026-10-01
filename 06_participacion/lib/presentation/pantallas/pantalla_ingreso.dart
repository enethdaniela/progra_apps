import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sesion_provider.dart';
import 'pantalla_usuarios.dart';

class PantallaIngreso extends StatefulWidget {
  const PantallaIngreso({super.key});

  @override
  State<PantallaIngreso> createState() => _PantallaIngresoState();
}

class _PantallaIngresoState extends State<PantallaIngreso> {
  final correoController = TextEditingController();
  final claveController = TextEditingController();
  final nombreController = TextEditingController();
  bool _navegando = false;

  @override
  void dispose() {
    correoController.dispose();
    claveController.dispose();
    nombreController.dispose();
    super.dispose();
  }

  void _irAUsuarios() {
    if (_navegando || !mounted) {
      return;
    }

    _navegando = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PantallaUsuarios()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<SesionProvider>();

    if (sesion.idUsuario != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _irAUsuarios();
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ingresar')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: correoController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Correo'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: claveController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Contraseña'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nombreController,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          const SizedBox(height: 24),
          if (sesion.error != null) ...[
            Text(
              sesion.error!,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
          ],
          if (sesion.cargando)
            const Center(child: CircularProgressIndicator())
          else ...[
            ElevatedButton(
              onPressed: () => context.read<SesionProvider>().ingresar(
                    correoController.text,
                    claveController.text,
                  ),
              child: const Text('Ingresar'),
            ),
            ElevatedButton(
              onPressed: () => context.read<SesionProvider>().registrar(
                    correoController.text,
                    claveController.text,
                    nombreController.text,
                  ),
              child: const Text('Crear cuenta'),
            ),
          ],
        ],
      ),
    );
  }
}
