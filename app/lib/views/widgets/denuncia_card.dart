import 'package:flutter/material.dart';
import '../../models/denuncia.dart';

class DenunciaCard extends StatelessWidget {
  final Denuncia denuncia;
  final String tempoRelativo;

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
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFF37474F),
                      child: const Icon(Icons.person, color: Colors.white, size: 18),
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

            // Localização
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: Colors.blueGrey[400]),
                const SizedBox(width: 4),
                Text(
                  denuncia.localizacao,
                  style: TextStyle(fontSize: 13, color: Colors.blueGrey[600]),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Descrição (máx. 3 linhas)
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
