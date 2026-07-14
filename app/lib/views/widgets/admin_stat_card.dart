import 'package:flutter/material.dart';

class AdminStatCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icone;

  const AdminStatCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icone,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              valor,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(titulo),
          ],
        ),
      ),
    );
  }
}