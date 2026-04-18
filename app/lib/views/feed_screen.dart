import 'package:flutter/material.dart';
import '../viewmodels/feed_viewmodel.dart';
import 'widgets/denuncia_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _viewModel = FeedViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(() => setState(() {}));
    _viewModel.carregarDenuncias();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // Header igual ao formulário
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF37474F),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                tooltip: 'Nova Denúncia',
                onPressed: () => Navigator.pushNamed(context, '/nova'),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Reportero Unicamp',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              background: Image.asset(
                'assets/header.jpg',
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.3),
                colorBlendMode: BlendMode.darken,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: const Color(0xFF455A64)),
              ),
            ),
          ),

          // Conteúdo
          if (_viewModel.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_viewModel.erro != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.grey[400], size: 48),
                    const SizedBox(height: 12),
                    Text(_viewModel.erro!, style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _viewModel.carregarDenuncias,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            )
          else if (_viewModel.denuncias.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, color: Colors.grey[400], size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Nenhuma denúncia registrada ainda.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final denuncia = _viewModel.denuncias[index];
                  return DenunciaCard(
                    denuncia: denuncia,
                    tempoRelativo: _viewModel.formatarTempo(denuncia.createdAt),
                  );
                },
                childCount: _viewModel.denuncias.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),

      // FAB para nova denúncia
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/nova'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nova Denúncia'),
      ),
    );
  }
}
