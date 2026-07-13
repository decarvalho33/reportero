import '../models/denuncia.dart';

/// Predicados de filtro por texto, categoria e status, reaproveitados pelo
/// feed público (Épico 3) e por "minhas denúncias" (US 5.4).
class FiltroDenuncias {
  static bool passaTexto(Denuncia denuncia, String textoFiltro) {
    if (textoFiltro.isEmpty) return true;
    final texto = textoFiltro.toLowerCase();
    return denuncia.titulo.toLowerCase().contains(texto) ||
        denuncia.descricao.toLowerCase().contains(texto) ||
        denuncia.localizacao.toLowerCase().contains(texto);
  }

  static bool passaCategoria(Denuncia denuncia, Categoria? categoria) =>
      categoria == null || denuncia.categoria == categoria;

  static bool passaStatus(Denuncia denuncia, StatusDenuncia? status) =>
      status == null || denuncia.status == status;

  static List<Denuncia> aplicar(
    List<Denuncia> lista, {
    String texto = '',
    Categoria? categoria,
    StatusDenuncia? status,
  }) {
    return lista
        .where((d) =>
            passaTexto(d, texto) &&
            passaCategoria(d, categoria) &&
            passaStatus(d, status))
        .toList();
  }
}
