import 'package:flutter/foundation.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/registrar_usuario.dart';

class SesionProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final RegistrarUsuario _registrarUsuario;

  String? idUsuario;
  bool cargando = false;
  String? error;

  SesionProvider(this._authRepository, this._registrarUsuario)
      : idUsuario = _authRepository.obtenerIdActual();

  Future<void> registrar(String correo, String clave, String nombre) async {
    _iniciarCarga();

    try {
      await _registrarUsuario(correo, clave, nombre);
      idUsuario = _authRepository.obtenerIdActual();
    } catch (exception) {
      error = exception.toString();
    } finally {
      _terminarCarga();
    }
  }

  Future<void> ingresar(String correo, String clave) async {
    _iniciarCarga();

    try {
      await _authRepository.ingresar(correo, clave);
      idUsuario = _authRepository.obtenerIdActual();
    } catch (exception) {
      error = exception.toString();
    } finally {
      _terminarCarga();
    }
  }

  Future<void> salir() async {
    _iniciarCarga();

    try {
      await _authRepository.salir();
      idUsuario = null;
    } catch (exception) {
      error = exception.toString();
    } finally {
      _terminarCarga();
    }
  }

  void _iniciarCarga() {
    cargando = true;
    error = null;
    notifyListeners();
  }

  void _terminarCarga() {
    cargando = false;
    notifyListeners();
  }
}
