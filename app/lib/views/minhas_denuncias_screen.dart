import 'package:flutter/material.dart';
import '../models/denuncia.dart';
import '../viewmodels/minhas_denuncias_viewmodel.dart';

/// Tela "Minhas denúncias" (US 5.3): lista, em resumo, apenas as denúncias
/// registradas pelo usuário autenticado.
///
/// Aceita um [MinhasDenunciasViewModel] via construtor para permitir testes
/// sem depender do Supabase real.
class MinhasDenunciasScreen extends StatefulWidget {
  const MinhasDenunciasScreen({super.key, MinhasDenunciasViewModel? viewModel})
      : _viewModelInjetado = viewModel;

  final MinhasDenunciasViewModel? _viewModelInjetado;

  @override
  State<MinhasDenunciasScreen> createState() => _MinhasDenunciasScreenState();
}

class _MinhasDenunciasScreenState extends State<MinhasDenunciasScreen> {
  late final MinhasDenunciasViewModel _viewModel =
      widget._viewModelInjetado ?? MinhasDenunciasViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
    if (!_viewModel.estaLogado) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pushReplacementNamed('/login');
      });
      return;
    }
    _viewModel.carregar();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Minhas denúncias'),
        backgroundColor: const Color(0xFF37474F),
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_viewModel.erro != null) {
      return Center(
        child: Text(_viewModel.erro!, style: TextStyle(color: Colors.grey[600])),
      );
    }

    if (_viewModel.denuncias.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_outlined, color: Colors.grey[400], size: 48),
              const SizedBox(height: 12),
              Text(
                'Você ainda não registrou nenhuma denúncia.',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _viewModel.denuncias.length,
      itemBuilder: (context, index) =>
          _MinhaDenunciaTile(denuncia: _viewModel.denuncias[index]),
    );
  }
}

class _MinhaDenunciaTile extends StatelessWidget {
  const _MinhaDenunciaTile({required this.denuncia});

  final Denuncia denuncia;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: ListTile(
        title: Text(
          denuncia.titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Chip(
                label: Text(denuncia.categoria.label),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Chip(
                label: Text(denuncia.status),
                backgroundColor: _corStatus(denuncia.status),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Text(
                _formatarData(denuncia.createdAt),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _corStatus(String status) {
    switch (status.toLowerCase()) {
      case 'resolvida':
        return Colors.green[100]!;
      case 'em andamento':
        return Colors.amber[100]!;
      default:
        return Colors.grey[200]!;
    }
  }

  String _formatarData(DateTime? data) {
    if (data == null) return '—';
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }
}
