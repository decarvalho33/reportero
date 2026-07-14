import 'package:flutter/material.dart';
import '../widgets/admin_stat_card.dart';
import '../../viewmodels/admin_dashboard_viewmodel.dart';
import '../widgets/admin_denuncia_card.dart';
import '../../services/denuncia_service.dart';
import 'admin_detail_screen.dart';
import '../../models/denuncia.dart';
import '../../services/export_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _viewModel = AdminDashboardViewModel();
  final _exportService = ExportService();

  @override
  void initState() {
    super.initState();
    _verificarAcesso();
  }

  Future<void> _verificarAcesso() async {
    final isAdmin = await DenunciaService().verificarPrivilegioAdmin();

    if (!mounted) return;

    if (!isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Acesso restrito a administradores."),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/feed',
        (route) => false,
      );

      return;
    }

    _viewModel.addListener(_atualizarTela);

    await _viewModel.carregarDenuncias();
  }

  void _atualizarTela() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_atualizarTela);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_viewModel.erro != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Painel Administrativo"),
        ),
        body: Center(
          child: Text(_viewModel.erro!),
        ),
      );
    }

    if (_viewModel.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel Administrativo"),
        actions: [

          IconButton(
            icon: const Icon(Icons.download),
            tooltip: "Exportar CSV",
            onPressed: () {

              _exportService.exportarCSV(
                _viewModel.denuncias,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Relatório exportado com sucesso."),
                ),
              );

            }
          ),

        ],    
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [

                  AdminStatCard(
                    titulo: "Total",
                    valor: _viewModel.totalDenuncias.toString(),
                    icone: Icons.description,
                  ),

                  AdminStatCard(
                    titulo: "Pendentes",
                    valor: _viewModel.totalPendentes.toString(),
                    icone: Icons.pending_actions,
                  ),

                  AdminStatCard(
                    titulo: "Em análise",
                    valor: _viewModel.totalEmAnalise.toString(),
                    icone: Icons.search,
                  ),

                  AdminStatCard(
                    titulo: "Resolvidas",
                    valor: _viewModel.totalResolvidas.toString(),
                    icone: Icons.check_circle,
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: "Buscar denúncia...",
                  border: OutlineInputBorder(),
                ),
                onChanged: (texto) {
                  _viewModel.busca = texto;
                  _viewModel.aplicarFiltros();
                },
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
              children: [

                Expanded(
                  child: DropdownButtonFormField<Categoria?>(
                    decoration: const InputDecoration(
                      labelText: "Categoria",
                      border: OutlineInputBorder(),
                    ),
                    value: _viewModel.categoriaSelecionada,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text("Todas"),
                      ),

                      ...Categoria.values.map(
                        (categoria) => DropdownMenuItem(
                          value: categoria,
                          child: Text(categoria.label),
                        ),
                      ),
                    ],
                    onChanged: (valor) {
                      _viewModel.categoriaSelecionada = valor;
                      _viewModel.aplicarFiltros();
                    },
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: DropdownButtonFormField<StatusDenuncia?>(
                    decoration: const InputDecoration(
                      labelText: "Status",
                      border: OutlineInputBorder(),
                    ),
                    value: _viewModel.statusSelecionado,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text("Todos"),
                      ),

                      ...StatusDenuncia.values.map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.label),
                        ),
                      ),
                    ],
                    onChanged: (valor) {
                      _viewModel.statusSelecionado = valor;
                      _viewModel.aplicarFiltros();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
          
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final denuncia = _viewModel.denuncias[index];

                return AdminDenunciaCard(
                  denuncia: denuncia,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminDetailScreen(
                          denuncia: denuncia,
                        ),
                      ),
                    );

                    await _viewModel.carregarDenuncias();

                  },
                );
              },
              childCount: _viewModel.denuncias.length,
            ),
          ),// Aquí agregaremos la lista de denuncias
        ],
      ),
    );
  }
}
