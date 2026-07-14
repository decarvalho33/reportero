import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/denuncia.dart';

class DenunciaCard extends StatelessWidget {
  final Denuncia denuncia;
  final String tempoRelativo;
  final VoidCallback onApoiar;

  const DenunciaCard({
    super.key,
    required this.denuncia,
    required this.tempoRelativo,
    required this.onApoiar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho: autor + tempo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFF37474F),
                      child: Icon(Icons.person, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      denuncia.autor.isEmpty ? 'Anônimo' : denuncia.autor,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF37474F),
                      ),
                    ),
                  ],
                ),
                Text(
                  tempoRelativo,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),

            const Divider(height: 20),

            // Título
            Text(
              denuncia.titulo,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF263238),
              ),
            ),
            const SizedBox(height: 6),

            if (denuncia.latitude != null && denuncia.longitude != null)
              InkWell(
                onTap: () => _mostrarOpcoesMapa(context),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.blueGrey[500],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              denuncia.localizacao,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blueGrey[700],
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.open_in_new,
                            size: 13,
                            color: Colors.blueGrey[400],
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 1),
                        child: Text(
                          'Toque para abrir no mapa',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Colors.blueGrey[400],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.blueGrey[500],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        denuncia.localizacao.isNotEmpty
                            ? denuncia.localizacao
                            : 'Coordenadas de GPS não informadas',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blueGrey[700],
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 6),

            // Metadados: GPS e categoria com tooltip descritivo
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Tooltip(
                  message: denuncia.categoria.descricao,
                  waitDuration: Duration.zero,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF37474F).withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  textStyle: const TextStyle(color: Colors.white, fontSize: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF37474F),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF37474F,
                          ).withValues(alpha: 0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sell, size: 13, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(
                          denuncia.categoria.label,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Imagem anexada via Supabase Storage — proporção fixa 2:1 para
            // manter os cards uniformes e evitar distorção entre fotos.
            if (denuncia.fotoUrl != null && denuncia.fotoUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 2 / 1,
                  child: Image.network(
                    denuncia.fotoUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: Colors.grey[100],
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[100],
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.broken_image_outlined,
                            color: Colors.grey[400],
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Erro ao carregar mídia',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Descrição (máx. 3 linhas)
            Text(
              denuncia.descricao,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),

            const SizedBox(height: 12),
            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: onApoiar,
                  icon: Icon(
                    denuncia.jaApoiei
                        ? Icons.thumb_up
                        : Icons.thumb_up_outlined,
                    color: denuncia.jaApoiei ? Colors.blue : Colors.grey,
                  ),
                ),
                Text(
                  '${denuncia.totalApoios}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Consulta usada no mapa: coordenadas se existirem, senão o texto da localização.
  String get _consultaMapa {
    if (denuncia.latitude != null && denuncia.longitude != null) {
      return '${denuncia.latitude},${denuncia.longitude}';
    }
    return denuncia.localizacao;
  }

  Uri get _googleMapsUri => Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(_consultaMapa)}',
  );

  Uri get _appleMapsUri {
    if (denuncia.latitude != null && denuncia.longitude != null) {
      return Uri.parse(
        'https://maps.apple.com/?ll=${denuncia.latitude},${denuncia.longitude}'
        '&q=${Uri.encodeComponent(denuncia.titulo)}',
      );
    }
    return Uri.parse(
      'https://maps.apple.com/?q=${Uri.encodeComponent(denuncia.localizacao)}',
    );
  }

  /// Menu inferior com as opções de aplicativo de mapa.
  void _mostrarOpcoesMapa(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.location_on, color: Colors.blueGrey[600]),
                title: const Text('Abrir localização em'),
                subtitle: Text(
                  denuncia.localizacao,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.map, color: Color(0xFF2E7D32)),
                title: const Text('Google Maps'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _abrirMapa(context, _googleMapsUri);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.map_outlined,
                  color: Color(0xFF37474F),
                ),
                title: const Text('Apple Maps'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _abrirMapa(context, _appleMapsUri);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Lança a URL do mapa em app externo; avisa se não for possível abrir.
  Future<void> _abrirMapa(BuildContext context, Uri uri) async {
    final aberto = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!aberto && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o mapa.')),
      );
    }
  }
}
