import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/perfiles_provider.dart';
import '../providers/sesion_provider.dart';
import 'pantalla_ingreso.dart';

class PantallaUsuarios extends StatefulWidget {
  const PantallaUsuarios({super.key});

  @override
  State<PantallaUsuarios> createState() => _PantallaUsuariosState();
}

class _PantallaUsuariosState extends State<PantallaUsuarios> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PerfilesProvider>().cargar();
      }
    });
  }

  Future<void> _cerrarSesion() async {
    final sesion = context.read<SesionProvider>();
    await sesion.salir();
    if (!mounted) {
      return;
    }
    if (sesion.idUsuario != null) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PantallaIngreso()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PerfilesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios registrados'),
        actions: [
          IconButton(
            onPressed: provider.cargando
                ? null
                : () => context.read<PerfilesProvider>().cargar(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
          ),
          IconButton(
            onPressed: provider.cargando ? null : _cerrarSesion,
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: _contenido(provider),
    );
  }

  Widget _contenido(PerfilesProvider provider) {
    if (provider.cargando && provider.perfiles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.perfiles.isEmpty && provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            provider.error!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (provider.perfiles.isEmpty) {
      return const Center(child: Text('No hay usuarios registrados.'));
    }

    return RefreshIndicator(
      onRefresh: context.read<PerfilesProvider>().cargar,
      child: ListView(
        children: [
          if (provider.error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                provider.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ...provider.perfiles.map(
            (perfil) => ListTile(
              leading: const Icon(Icons.person),
              title: Text(perfil.nombre),
              subtitle: Text(perfil.creadoEn.toLocal().toString()),
            ),
          ),
        ],
      ),
    );
  }
}
