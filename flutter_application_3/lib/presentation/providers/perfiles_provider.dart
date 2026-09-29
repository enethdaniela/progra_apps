import 'package:flutter/foundation.dart';

import '../../domain/entities/perfil.dart';
import '../../domain/repositories/perfiles_repository.dart';

class PerfilesProvider extends ChangeNotifier {
  final PerfilesRepository _perfilesRepository;

  List<Perfil> perfiles = const [];
  bool cargando = false;
  String? error;

  PerfilesProvider(this._perfilesRepository);

  Future<void> cargar() async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      perfiles = await _perfilesRepository.obtenerTodos();
    } catch (exception) {
      error = exception.toString();
    } finally {
      cargando = false;
      notifyListeners();
    }
  }
}
