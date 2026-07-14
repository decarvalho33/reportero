import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel([AuthService? service]) : _auth = service ?? AuthService();

  final AuthService _auth;

  bool _isLoading = false;
  String? _erro;

  bool get isLoading => _isLoading;
  String? get erro => _erro;
  bool get estaLogado => _auth.estaLogado;
  String? get nomeUsuario => _auth.nomeUsuario;
  String? get primeiroNomeUsuario => _auth.nomeUsuario?.split(' ').first;
  String? get emailUsuario => _auth.usuarioAtual?.email;
  Stream<AuthState> get mudancasDeSessao => _auth.mudancasDeSessao;

  Future<bool> entrar(String email, String senha) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();
    try {
      await _auth.entrar(email: email, senha: senha);
      return true;
    } catch (e) {
      _erro = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cadastrar(String nome, String email, String senha) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();
    try {
      await _auth.cadastrar(nome: nome, email: email, senha: senha);
      return true;
    } catch (e) {
      _erro = e
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('Invalid argument(s): ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> recuperarSenha(String email) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();
    try {
      await _auth.recuperarSenha(email);
      return true;
    } catch (e) {
      _erro = e
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('Invalid argument(s): ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> atualizarSenha(String novaSenha) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();
    try {
      await _auth.atualizarSenha(novaSenha);
      return true;
    } catch (e) {
      _erro = e
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('Invalid argument(s): ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> trocarSenha({
    required String senhaAtual,
    required String novaSenha,
  }) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();
    try {
      await _auth.trocarSenha(senhaAtual: senhaAtual, novaSenha: novaSenha);
      return true;
    } catch (e) {
      _erro = e
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('Invalid argument(s): ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sair() async {
    await _auth.sair();
    notifyListeners();
  }
}
