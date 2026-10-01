import '../repositories/auth_repository.dart';
import '../repositories/perfiles_repository.dart';

class RegistrarUsuario {
  final AuthRepository _authRepository;
  final PerfilesRepository _perfilesRepository;

  const RegistrarUsuario(this._authRepository, this._perfilesRepository);

  Future<void> call(String correo, String clave, String nombre) async {
    final id = await _authRepository.registrar(correo, clave);
    await _perfilesRepository.crear(id, nombre);
  }
}
