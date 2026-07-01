import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/denuncia.dart';
import '../services/denuncia_service.dart';

class DenunciaViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final _service = DenunciaService();
  final tituloCtrl = TextEditingController();
  final localCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final autorCtrl = TextEditingController();

  Uint8List? _fotoBytes;
  String? _nomeArquivoFoto;
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;
  Categoria _categoriaSelecionada = Categoria.outros;

  Uint8List? get fotoBytes => _fotoBytes;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  bool get isLoading => _isLoading;
  Categoria get categoriaSelecionada => _categoriaSelecionada;

  void definirCategoria(Categoria novaCategoria) {
    _categoriaSelecionada = novaCategoria;
    notifyListeners();
  }

  void definirFoto(Uint8List bytes, String nome) {
    _fotoBytes = bytes;
    _nomeArquivoFoto = nome;
    notifyListeners();
  }

  void alternarLocalizacaoGps(bool ativar) {
    if (ativar) {
      _latitude = -22.8184;
      _longitude = -47.0647;
    } else {
      _latitude = null;
      _longitude = null;
    }
    notifyListeners();
  }

  String? validarObrigatorio(String? value) {
    if (value == null || value.isEmpty) return "Este campo é obrigatório";
    return null;
  }

  Future<bool> submeterFormulario() async {
    if (!formKey.currentState!.validate()) return false;

    _isLoading = true;
    notifyListeners();

    try {
      String? urlPublicaFoto;

      if (_fotoBytes != null && _nomeArquivoFoto != null) {
        urlPublicaFoto = await _service.subirFoto(_fotoBytes!, _nomeArquivoFoto!);
      }

      final novaDenuncia = Denuncia(
        titulo: tituloCtrl.text,
        localizacao: localCtrl.text,
        descricao: descCtrl.text,
        autor: autorCtrl.text.isEmpty ? "Anônimo" : autorCtrl.text,
        categoria: _categoriaSelecionada,
        latitude: _latitude,
        longitude: _longitude,
        fotoUrl: urlPublicaFoto,
      );

      await _service.enviarDenuncia(novaDenuncia);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Erro ao processar no backend: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void limpar() {
    tituloCtrl.clear();
    localCtrl.clear();
    descCtrl.clear();
    autorCtrl.clear();
    _fotoBytes = null;
    _nomeArquivoFoto = null;
    _latitude = null;
    _longitude = null;
    _categoriaSelecionada = Categoria.outros;
    notifyListeners();
  }
}
