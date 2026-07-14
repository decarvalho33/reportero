import 'package:csv/csv.dart';

import '../models/denuncia.dart';
import 'export/csv_exporter_stub.dart'
    if (dart.library.html) 'export/csv_exporter_web.dart' as csv_exporter;

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

    csv_exporter.baixarCsv(csv, 'relatorio_denuncias.csv');

  }

}
