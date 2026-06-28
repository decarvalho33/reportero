import 'package:flutter/material.dart';
import '../../models/denuncia.dart';

/// Widget que representa visualmente uma denúncia, exibindo informações como título, descrição, localização, autor, tempo relativo e imagem anexada (se houver).
class DenunciaCard extends StatelessWidget {
  final Denuncia denuncia;
  final String tempoRelativo;
  /// Construtor do widget DenunciaCard, que recebe uma denúncia e o tempo relativo para exibição.
  const DenunciaCard({
    super.key,
    required this.denuncia,
    required this.tempoRelativo,
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

            /// Título
            Text(
              denuncia.titulo,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF263238),
              ),
            ),
            const SizedBox(height: 6),

            /// Localização textual
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: Colors.blueGrey[400]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    denuncia.localizacao,
                    style: TextStyle(fontSize: 13, color: Colors.blueGrey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            /// METADADOS ROW: Coordenadas GPS e Categoria com Tooltip explicativo
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                /// Tag Extra: Coordenadas exatas (Se existirem)
                if (denuncia.latitude != null && denuncia.longitude != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.explore_outlined, size: 12, color: Colors.green[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Lat: ${denuncia.latitude!.toStringAsFixed(5)}, Lon: ${denuncia.longitude!.toStringAsFixed(5)}',
                          style: TextStyle(fontSize: 11, color: Colors.green[700], fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),

                /// Categoria com Tooltip Dinâmico
                Tooltip(
                  message: denuncia.categoria.descricao, // Pega o texto explicativo de João Pedro
                  waitDuration: Duration.zero, // Abre imediatamente ao passar o ponteiro do mouse
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF37474F).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  textStyle: const TextStyle(color: Colors.white, fontSize: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sell_outlined, size: 12, color: Colors.blueGrey[700]),
                        const SizedBox(width: 4),
                        Text(
                          denuncia.categoria.label, // Exibe o texto amigável: "Infraestrutura", "Limpeza", etc.
                          style: TextStyle(fontSize: 11, color: Colors.blueGrey[800], fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 10),

            /// Imagem anexada via Supabase Storage (Se existir)
            if (denuncia.fotoUrl != null && denuncia.fotoUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  denuncia.fotoUrl!,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 40,
                    color: Colors.grey[100],
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        Icon(Icons.broken_image_outlined, color: Colors.grey[400], size: 16),
                        const SizedBox(width: 4),
                        Text('Erro ao carregar mídia', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            /// Descrição (máx. 3 linhas)
            Text(
              denuncia.descricao,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}