import 'dart:html' as html;

void baixarCsv(String csv, String nomeArquivo) {
  final bytes = html.Blob([csv]);
  final url = html.Url.createObjectUrlFromBlob(bytes);

  html.AnchorElement(href: url)
    ..download = nomeArquivo
    ..click();

  html.Url.revokeObjectUrl(url);
}
