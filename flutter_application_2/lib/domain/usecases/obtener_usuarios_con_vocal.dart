import '../repositories/usuario_repository.dart';
import '../entities/usuario.dart';

class ObtenerUsuariosConVocal {
  const ObtenerUsuariosConVocal(this._repository);

  final UsuarioRepository _repository;

  Future<List<Usuario>> call() async {
    final usuarios = await _repository.obtener();

    return usuarios.where((usuario) {
      final nombre = usuario.nombre.trim().toUpperCase();
      return nombre.isNotEmpty && 'AEIOU'.contains(nombre[0]);
    }).toList();
  }
}
