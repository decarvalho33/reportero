import 'dart:html' as html;

import 'package:csv/csv.dart';

import '../models/denuncia.dart';

class ExportService {

  void exportarCSV(List<Denuncia> denuncias) {

    final linhas = <List<dynamic>>[];

    linhas.add([
      'Título',
      'Categoria',
      'Status',
      'Autor',
      'Localização',
      'Data',
      'Apoios',
      'Setor responsável',
      'Resposta do administrador',
    ]);

    for (final denuncia in denuncias) {

      linhas.add([
        denuncia.titulo,
        denuncia.categoria.label,
        denuncia.status.label,
        denuncia.autor,
        denuncia.localizacao,
        denuncia.createdAt?.toIso8601String() ?? '',
        denuncia.totalApoios,
        denuncia.setorResponsavel ?? '',
        denuncia.respostaAdmin ?? '',
      ]);

    }

    final csv = const ListToCsvConverter().convert(linhas);

    final bytes = html.Blob([csv]);

    final url = html.Url.createObjectUrlFromBlob(bytes);

    final anchor = html.AnchorElement(href: url)
      ..download = 'relatorio_denuncias.csv'
      ..click();

    html.Url.revokeObjectUrl(url);

  }

}