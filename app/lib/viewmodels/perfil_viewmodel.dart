import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/perfil_service.dart';

class PerfilViewModel extends ChangeNotifier {
  PerfilViewModel({PerfilService? perfilService, AuthService? authService})
      : _perfil = perfilService ?? PerfilService(),
        _auth = authService ?? AuthService();

  final PerfilService _perfil;
  final AuthService _auth;

  bool _isLoading = false;
  String? _erro;
  String? _nome;
  String? _fotoUrl;

  bool get isLoading => _isLoading;
  String? get erro => _erro;
  bool get estaLogado => _auth.estaLogado;
  String? get email => _auth.usuarioAtual?.email;

  /// Nome atual: usa o já carregado da tabela `profiles`, ou o do metadata
  /// de autenticação enquanto o carregamento não termina.
  String? get nome => _nome ?? _auth.nomeUsuario;

  /// URL da foto de perfil salva em `profiles`. `null` quando o usuário
  /// ainda não enviou uma foto (a UI mostra um placeholder nesse caso).
  String? get fotoUrl => _fotoUrl;

  /// Busca o nome e a foto salvos em `profiles` para o usuário autenticado.
  Future<void> carregar() async {
    final userId = _auth.usuarioAtual?.id;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();
    try {
      _nome = await _perfil.obterNome(userId);
      _fotoUrl = await _perfil.obterFotoPerfil(userId);
    } catch (_) {
      _erro = 'Não foi possível carregar o perfil.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Valida e persiste o novo nome (US 5.2). Retorna `true` em caso de sucesso.
  Future<bool> salvarNome(String novoNome) async {
    final userId = _auth.usuarioAtual?.id;
    if (userId == null) return false;

    _isLoading = true;
    _erro = null;
    notifyListeners();
    try {
      await _perfil.atualizarNome(userId: userId, nome: novoNome);
      _nome = novoNome.trim();
      return true;
    } catch (e) {
      _erro = e.toString().replaceFirst('Invalid argument(s): ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sobe a nova foto de perfil e persiste a URL (US 5.1). Retorna `true`
  /// em caso de sucesso.
  Future<bool> atualizarFotoPerfil(Uint8List fotoBytes, String nomeArquivo) async {
    final userId = _auth.usuarioAtual?.id;
    if (userId == null) return false;

    _isLoading = true;
    _erro = null;
    notifyListeners();
    try {
      final urlFoto = await _perfil.subirFotoPerfil(fotoBytes, nomeArquivo);
      if (urlFoto != null) {
        await _perfil.atualizarFotoPerfil(userId: userId, fotoUrl: urlFoto);
        _fotoUrl = urlFoto;
      }
      return true;
    } catch (e) {
      _erro = e.toString().replaceFirst('Invalid argument(s): ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
