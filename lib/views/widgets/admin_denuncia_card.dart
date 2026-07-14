import 'package:flutter/material.dart';

import '../../models/denuncia.dart';

class AdminDenunciaCard extends StatelessWidget {
  final Denuncia denuncia;
  final VoidCallback? onTap;

  const AdminDenunciaCard({
    super.key,
    required this.denuncia,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: ListTile(
        onTap: onTap,

        title: Text(
          denuncia.titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 8),

            Text(
              denuncia.categoria.label,
            ),

            const SizedBox(height: 4),

            Text(
              "Status: ${denuncia.status.label}",
            ),

            const SizedBox(height: 4),

            Text(
              denuncia.createdAt == null
                  ? ""
                  : denuncia.createdAt.toString(),
            ),
          ],
        ),

        trailing: const Icon(
          Icons.chevron_right,
        ),
      ),
    );
  }
}