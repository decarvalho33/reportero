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
  final _buscaCtrl = TextEditingController();

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
    _buscaCtrl.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _visualizarMudanca(Denuncia denuncia) async {
    await _viewModel.marcarComoVisto(denuncia);
  }

  Future<void> _editar(Denuncia denuncia) async {
    await Navigator.pushNamed(context, '/nova', arguments: denuncia);
    if (mounted) _viewModel.carregar();
  }

  Future<void> _confirmarExclusao(Denuncia denuncia) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir denúncia'),
        content: Text(
          'Tem certeza que deseja excluir "${denuncia.titulo}"? Essa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;

    final sucesso = await _viewModel.excluir(denuncia);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sucesso ? 'Denúncia excluída.' : (_viewModel.erro ?? 'Erro ao excluir.'),
        ),
        backgroundColor: sucesso ? null : Colors.redAccent,
      ),
    );
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
      body: Column(
        children: [
          if (_viewModel.temDenunciasCadastradas) _buildFiltros(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _buscaCtrl,
            onChanged: _viewModel.filtrarPorTexto,
            decoration: InputDecoration(
              hintText: 'Buscar nas minhas denúncias...',
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFiltroChip(
                  'Todas',
                  selecionado: _viewModel.filtroCategoria == null,
                  onSelected: () => _viewModel.filtrarPorCategoria(null),
                ),
                ...Categoria.values.map(
                  (c) => _buildFiltroChip(
                    c.label,
                    selecionado: _viewModel.filtroCategoria == c,
                    onSelected: () => _viewModel.filtrarPorCategoria(
                      _viewModel.filtroCategoria == c ? null : c,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_viewModel.statusDisponiveis.length > 1) ...[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFiltroChip(
                    'Todos os status',
                    selecionado: _viewModel.filtroStatus == null,
                    onSelected: () => _viewModel.filtrarPorStatus(null),
                  ),
                  ..._viewModel.statusDisponiveis.map(
                    (s) => _buildFiltroChip(
                      s.label,
                      selecionado: _viewModel.filtroStatus == s,
                      onSelected: () => _viewModel.filtrarPorStatus(
                        _viewModel.filtroStatus == s ? null : s,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFiltroChip(
    String label, {
    required bool selecionado,
    required VoidCallback onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selecionado,
        onSelected: (_) => onSelected(),
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
                _viewModel.temDenunciasCadastradas
                    ? 'Nenhuma denúncia encontrada com os filtros aplicados.'
                    : 'Você ainda não registrou nenhuma denúncia.',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (_viewModel.denunciasComMudancaDeStatus.isNotEmpty) _buildResumoMudancas(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _viewModel.denuncias.length,
            itemBuilder: (context, index) {
              final denuncia = _viewModel.denuncias[index];
              return _MinhaDenunciaTile(
                denuncia: denuncia,
                temMudancaDeStatus: _viewModel.temMudancaDeStatus(denuncia),
                onEditar: () => _editar(denuncia),
                onExcluir: () => _confirmarExclusao(denuncia),
                onVisualizarMudanca: () => _visualizarMudanca(denuncia),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Contagem discreta de quantas denúncias têm mudança de status pendente
  /// de visualização (US 5.5).
  Widget _buildResumoMudancas() {
    final quantidade = _viewModel.denunciasComMudancaDeStatus.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          const Icon(Icons.notifications_active, size: 16, color: Color(0xFF1565C0)),
          const SizedBox(width: 6),
          Text(
            quantidade == 1
                ? '1 denúncia com status atualizado'
                : '$quantidade denúncias com status atualizado',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF1565C0),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MinhaDenunciaTile extends StatelessWidget {
  const _MinhaDenunciaTile({
    required this.denuncia,
    required this.temMudancaDeStatus,
    required this.onEditar,
    required this.onExcluir,
    required this.onVisualizarMudanca,
  });

  final Denuncia denuncia;
  final bool temMudancaDeStatus;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;
  final VoidCallback onVisualizarMudanca;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: temMudancaDeStatus
            ? const BorderSide(color: Color(0xFF1565C0), width: 1.5)
            : BorderSide.none,
      ),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (temMudancaDeStatus) _buildBannerMudanca(),
          ListTile(
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
                    label: Text(denuncia.status.label),
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar',
                  onPressed: onEditar,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Excluir',
                  onPressed: onExcluir,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Banner que identifica a mudança de status (US 5.5): destaca a denúncia
  /// (borda + faixa colorida no card) e deixa o novo status explícito no
  /// texto, atendendo ao critério de aceitação da issue #68.
  ///
  /// O toque no banner é o gatilho de "visualizado" — marcar tudo como visto
  /// assim que a tela abre anularia a notificação, já que o usuário nunca
  /// teria chance de notar a mudança antes dela sumir.
  Widget _buildBannerMudanca() {
    return Material(
      color: const Color(0xFFE3F2FD),
      child: InkWell(
        onTap: onVisualizarMudanca,
        child: Tooltip(
          message: 'Marcar novo status como visto',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.notifications_active, size: 18, color: Color(0xFF1565C0)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Novo status: ${denuncia.status.label}',
                    style: const TextStyle(
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const Icon(Icons.close, size: 16, color: Color(0xFF1565C0)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _corStatus(StatusDenuncia status) {
    switch (status) {
      case StatusDenuncia.resolvida:
        return Colors.green[100]!;
      case StatusDenuncia.emAnalise:
        return Colors.amber[100]!;
      case StatusDenuncia.pendente:
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
