import 'package:flutter/material.dart';
import '../../viewmodels/admin_detail_viewmodel.dart';
import '../../models/denuncia.dart';

class AdminDetailScreen extends StatefulWidget {
  final Denuncia denuncia;

  const AdminDetailScreen({
    super.key,
    required this.denuncia,
  });

  @override
  State<AdminDetailScreen> createState() => _AdminDetailScreenState();
}

class _AdminDetailScreenState extends State<AdminDetailScreen> {
  final _viewModel = AdminDetailViewModel();

  late Denuncia denuncia;

  @override
  void initState() {
    super.initState();
    denuncia = widget.denuncia;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalhes da denúncia"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // FOTO
            if (denuncia.fotoUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  denuncia.fotoUrl!,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),

            if (denuncia.fotoUrl != null)
              const SizedBox(height: 20),

            Text(
              denuncia.titulo,
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [

                    _infoRow("Categoria", denuncia.categoria.label),

                    _infoRow("Status", denuncia.status.label),

                    _infoRow("Autor", denuncia.autor),

                    _infoRow(
                      "Data",
                      denuncia.createdAt?.toString() ?? "-",
                    ),

                    _infoRow(
                      "Localização",
                      denuncia.localizacao,
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Descrição",
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 8),

            Text(
              denuncia.descricao,
            ),

            const SizedBox(height: 24),

            if (denuncia.respostaAdmin != null &&
                denuncia.respostaAdmin!.isNotEmpty) ...[
              Text(
                "Resposta do administrador",
                style: Theme.of(context).textTheme.titleMedium,
              ),

              const SizedBox(height: 8),

              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    denuncia.respostaAdmin!,
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],

            if (denuncia.setorResponsavel != null &&
                denuncia.setorResponsavel!.isNotEmpty) ...[
              Text(
                "Setor responsável",
                style: Theme.of(context).textTheme.titleMedium,
              ),

              const SizedBox(height: 8),

              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    denuncia.setorResponsavel!,
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _mostrarDialogoStatus,
                child: const Text("Atualizar status"),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _mostrarDialogoResposta,
                child: const Text("Responder ao autor"),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _mostrarDialogoSetor,
                child: const Text("Atribuir setor"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              titulo,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(valor),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarDialogoStatus() async {
    StatusDenuncia? novoStatus = denuncia.status;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Atualizar Status"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: StatusDenuncia.values.map((status) {
                  return RadioListTile<StatusDenuncia>(
                    title: Text(status.label),
                    value: status,
                    groupValue: novoStatus,
                    onChanged: (value) {
                      setDialogState(() {
                        novoStatus = value;
                      });
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (novoStatus == null) return;

                    final sucesso = await _viewModel.atualizarStatus(
                      denuncia.id!,
                      novoStatus!,
                    );

                    if (!mounted) return;

                    if (sucesso) {
                      setState(() {
                        denuncia = denuncia.copyWith(
                          status: novoStatus,
                        );
                      });

                      Navigator.pop(context);

                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text("Status atualizado com sucesso."),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _viewModel.erro ?? "Erro ao atualizar status.",
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("Salvar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _mostrarDialogoResposta() async {
    final controller = TextEditingController(
      text: denuncia.respostaAdmin ?? "",
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Responder ao autor"),
          content: TextField(
            controller: controller,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: "Digite a resposta...",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              child: const Text("Salvar"),
              onPressed: () async {
                final sucesso = await _viewModel.responderAutor(
                  denuncia.id!,
                  controller.text,
                );

                if (!mounted) return;

                if (sucesso) {
                  setState(() {
                    denuncia = denuncia.copyWith(
                      respostaAdmin: controller.text,
                    );
                  });

                  Navigator.pop(context);

                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(
                      content: Text("Resposta salva com sucesso."),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _viewModel.erro ??
                            "Erro ao salvar resposta.",
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _mostrarDialogoSetor() async {
    final List<String> setores = [
      "Infraestrutura",
      "Limpeza",
      "Segurança",
      "TI",
      "Prefeitura do Campus",
    ];

    String? setorSelecionado = denuncia.setorResponsavel ?? setores.first;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Atribuir setor"),

              content: DropdownButtonFormField<String>(
                value: setorSelecionado,
                decoration: const InputDecoration(
                  labelText: "Setor responsável",
                ),
                items: setores.map((setor) {
                  return DropdownMenuItem(
                    value: setor,
                    child: Text(setor),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    setorSelecionado = value;
                  });
                },
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),

                ElevatedButton(
                  onPressed: () async {
                    if (setorSelecionado == null) return;

                    final sucesso =
                        await _viewModel.atribuirSetor(
                      denuncia.id!,
                      setorSelecionado!,
                    );

                    if (!mounted) return;

                    if (sucesso) {
                      setState(() {
                        denuncia = denuncia.copyWith(
                          setorResponsavel: setorSelecionado,
                        );
                      });

                      Navigator.pop(context);

                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Setor atualizado com sucesso.",
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _viewModel.erro ??
                                "Erro ao atribuir setor.",
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("Salvar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

}