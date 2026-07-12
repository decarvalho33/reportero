import 'package:flutter/material.dart';
import '../models/denuncia.dart';
import '../viewmodels/feed_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'widgets/denuncia_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _viewModel = FeedViewModel();
  final _authViewModel = AuthViewModel();
  final _scrollController = ScrollController();
  bool _isScrolled = false;

  /// Verifica se o usuário está logado. Se estiver, redireciona para a rota desejada.
  /// Se não estiver, envia para a tela de login.
  void _redirecionarParaAutenticados(String rota) {
    if (!_authViewModel.estaLogado) {
      Navigator.pushNamed(context, '/login');
    } else {
      Navigator.pushNamed(context, rota);
    }
  }

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(() => setState(() {}));
    _viewModel.carregarDenuncias();
    _scrollController.addListener(() {
      final isScrolled = _scrollController.offset > 80;
      if (_isScrolled != isScrolled) {
        setState(() => _isScrolled = isScrolled);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF37474F),
            actions: [
              StreamBuilder(
                stream: _authViewModel.mudancasDeSessao,
                builder: (context, snapshot) {
                  final logado = _authViewModel.estaLogado;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _isScrolled
                          ? IconButton(
                              onPressed: () {
                                if (!logado) {
                                  Navigator.pushNamed(context, '/login');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Tela de perfil'),
                                    ),
                                  );
                                }
                              },
                              tooltip: logado ? 'Perfil' : 'Entrar',
                              visualDensity: VisualDensity.compact,
                              icon: Icon(
                                logado ? Icons.account_circle : Icons.login,
                                color: Colors.white,
                                size: 28,
                              ),
                            )
                          : TextButton.icon(
                              onPressed: () {
                                if (!logado) {
                                  Navigator.pushNamed(context, '/login');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Tela de perfil'),
                                    ),
                                  );
                                }
                              },
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                              ),
                              icon: Icon(
                                logado ? Icons.account_circle : Icons.login,
                                color: Colors.white,
                              ),
                              label: Text(
                                logado
                                    ? (_authViewModel.nomeUsuario
                                              ?.split(' ')
                                              .first ??
                                          'Perfil')
                                    : 'Entrar',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                      if (logado)
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.logout, color: Colors.white),
                          tooltip: 'Sair',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Sair da conta'),
                                content: const Text(
                                  'Tem certeza que deseja sair do aplicativo?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.grey[700],
                                    ),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await _authViewModel.sair();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Você saiu da sua conta',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text('Sair'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  );
                },
              ),
              PopupMenuButton<TipoOrdenacao>(
                icon: const Icon(Icons.sort, color: Colors.white),
                onSelected: _viewModel.alternarOrdenacao,
                padding: EdgeInsets.zero,
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: TipoOrdenacao.recente,
                    child: Text("Mais recentes"),
                  ),
                  PopupMenuItem(
                    value: TipoOrdenacao.antiga,
                    child: Text("Mais antigas"),
                  ),
                  PopupMenuItem(
                    value: TipoOrdenacao.apoios,
                    child: Text("Mais apoiadas"),
                  ),
                ],
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                tooltip: 'Nova Denúncia',
                onPressed: () => Navigator.pushNamed(context, '/nova'),
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: EdgeInsets.only(
                left: 16,
                bottom: 16,
                right: _isScrolled
                    ? (_authViewModel.estaLogado ? 190 : 140)
                    : 16,
              ),
              title: const Text(
                'Reportero Unicamp',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
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

          // Chips de filtro por categoria
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoriaChip('Todas', null),
                    ...Categoria.values.map(
                      (c) => _buildCategoriaChip(c.label, c),
                    ),
                  ],
                ),
              ),
            ),
          ),

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
                    Icon(
                      Icons.error_outline,
                      color: Colors.grey[400],
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _viewModel.erro!,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
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
                    Icon(
                      Icons.inbox_outlined,
                      color: Colors.grey[400],
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _viewModel.filtroCategoria != null
                          ? 'Nenhuma denúncia encontrada para esta categoria.'
                          : 'Nenhuma denúncia registrada ainda.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final denuncia = _viewModel.denuncias[index];
                return DenunciaCard(
                  denuncia: denuncia,
                  tempoRelativo: _viewModel.formatarTempo(denuncia.createdAt),
                  onApoiar: () => _viewModel.alternarApoio(denuncia),
                );
              }, childCount: _viewModel.denuncias.length),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/nova'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nova Denúncia'),
      ),
    );
  }

  Widget _buildCategoriaChip(String label, Categoria? categoria) {
    final selecionado = _viewModel.filtroCategoria == categoria;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selecionado,
        onSelected: (_) =>
            _viewModel.filtrarPorCategoria(selecionado ? null : categoria),
        selectedColor: const Color(0xFF37474F),
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.blueGrey[200]!),
        labelStyle: TextStyle(
          color: selecionado ? Colors.white : const Color(0xFF37474F),
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        showCheckmark: false,
      ),
    );
  }
}
