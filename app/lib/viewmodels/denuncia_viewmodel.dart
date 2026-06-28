import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/denuncia.dart';
import '../services/denuncia_service.dart';

class DenunciaViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final _service = DenunciaService();

  // Controllers que a View vai usar
  final tituloCtrl = TextEditingController();
  final localCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final autorCtrl = TextEditingController();

  // Estados para mídia e localização (Histórias 1.2 e 1.5)
  Uint8List? _fotoBytes;
  String? _nomeArquivoFoto;
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;
  String _categoriaSelecionada = 'Outros';

  Uint8List? get fotoBytes => _fotoBytes;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  bool get isLoading => _isLoading;
  String get categoriaSelecionada => _categoriaSelecionada;

  void selecionarCategoria(String categoria) {
    _categoriaSelecionada = categoria;
    notifyListeners();
  }

  // Atualiza a foto selecionada
  void definirFoto(Uint8List bytes, String nome) {
    _fotoBytes = bytes;
    _nomeArquivoFoto = nome;
    notifyListeners();
  }

  // Simula ou ativa a captura de coordenadas da Unicamp (História 1.2)
  void alternarLocalizacaoGps(bool ativar) {
    if (ativar) {
      _latitude = -22.8184; // Coordenadas do coração da Unicamp
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

      // 1. Se houver foto selecionada, faz o upload para o Storage primeiro (História 1.5)
      if (_fotoBytes != null && _nomeArquivoFoto != null) {
        urlPublicaFoto = await _service.subirFoto(_fotoBytes!, _nomeArquivoFoto!);
      }

      // 2. Monta o modelo completo unificado com fotos e GPS
      final novaDenuncia = Denuncia(
        titulo: tituloCtrl.text,
        localizacao: localCtrl.text,
        descricao: descCtrl.text,
        autor: autorCtrl.text.isEmpty ? "Anônimo" : autorCtrl.text,
        latitude: _latitude,
        longitude: _longitude,
        fotoUrl: urlPublicaFoto,
        categoria: _categoriaSelecionada,
      );

      // 3. Envia os dados finais ao Supabase
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
    _categoriaSelecionada = 'Outros';
    notifyListeners();
  }
}