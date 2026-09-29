import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/perfil.dart';
import '../../domain/repositories/perfiles_repository.dart';

class SupabasePerfilesRepository implements PerfilesRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<void> crear(String id, String nombre) async {
    await _client.from('perfiles').insert({
      'id': id,
      'nombre': nombre,
    });
  }

  @override
  Future<List<Perfil>> obtenerTodos() async {
    final rows = await _client.from('perfiles').select();

    return rows.map((row) {
      return Perfil(
        id: row['id'] as String,
        nombre: row['nombre'] as String,
        creadoEn: DateTime.parse(row['creado_en'] as String),
      );
    }).toList();
  }
}
