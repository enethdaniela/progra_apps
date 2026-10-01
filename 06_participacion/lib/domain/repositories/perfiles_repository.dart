import '../entities/perfil.dart';

abstract class PerfilesRepository {
  Future<void> crear(String id, String nombre);
  Future<List<Perfil>> obtenerTodos();
}
