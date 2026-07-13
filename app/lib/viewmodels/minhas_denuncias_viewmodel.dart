import 'package:flutter/material.dart';
import '../models/denuncia.dart';
import '../services/auth_service.dart';
import '../services/denuncia_service.dart';

class MinhasDenunciasViewModel extends ChangeNotifier {
  MinhasDenunciasViewModel({
    Future<List<Denuncia>> Function()? buscarDenuncias,
    AuthService? authService,
  })  : _buscarDenuncias = buscarDenuncias ?? DenunciaService().obterMinhasDenuncias,
        _auth = authService ?? AuthService();

  final Future<List<Denuncia>> Function() _buscarDenuncias;
  final AuthService _auth;

  List<Denuncia> _denuncias = [];
  bool _isLoading = false;
  String? _erro;

  List<Denuncia> get denuncias => _denuncias;
  bool get isLoading => _isLoading;
  String? get erro => _erro;
  bool get estaLogado => _auth.estaLogado;

  Future<void> carregar() async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _denuncias = await _buscarDenuncias();
    } catch (e) {
      _erro = 'Não foi possível carregar suas denúncias.';
    }

    _isLoading = false;
    notifyListeners();
  }
}
