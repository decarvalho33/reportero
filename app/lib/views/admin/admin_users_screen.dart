import 'package:flutter/material.dart';

import '../../viewmodels/admin_users_viewmodel.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final AdminUsersViewModel _viewModel = AdminUsersViewModel();

  @override
  void initState() {
    super.initState();

    _viewModel.addListener(_actualizar);
    _viewModel.carregarUsuarios();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_actualizar);
    _viewModel.dispose();
    super.dispose();
  }

  void _actualizar() {
    if (mounted) {
      setState(() {});
    }
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
          title: const Text("Gerenciar administradores"),
        ),
        body: Center(
          child: Text(_viewModel.erro!),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gerenciar administradores"),
      ),
      body: RefreshIndicator(
        onRefresh: _viewModel.carregarUsuarios,
        child: ListView.builder(
          itemCount: _viewModel.usuarios.length,
          itemBuilder: (context, index) {
            final usuario = _viewModel.usuarios[index];
            final isAdmin = usuario["is_admin"] == true;

            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(
                    (usuario["nome"] ?? "?")
                        .toString()
                        .substring(0, 1)
                        .toUpperCase(),
                  ),
                ),
                title: Text(usuario["nome"] ?? "Sem nome"),
                
                subtitle: Text(
                  isAdmin ? "Administrador" : "Usuário",
                  style: TextStyle(
                    color: isAdmin ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                trailing: ElevatedButton(
                  onPressed: () async {
                    final sucesso = await _viewModel.alterarPermissao(
                      usuario["id"],
                      !isAdmin,
                    );

                    if (!mounted) return;

                  if (sucesso) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isAdmin
                            ? "Administrador removido."
                            : "Administrador promovido.",
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _viewModel.erro ?? "Erro ao alterar permissões.",
                        ),
                      ),
                    );
                  }
                },
                  child: Text(
                    isAdmin ? "Remover" : "Promover",
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}