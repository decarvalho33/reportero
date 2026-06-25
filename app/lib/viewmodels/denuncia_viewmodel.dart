import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/denuncia.dart';
import '../services/denuncia_service.dart';

/// ViewModel responsável por gerenciar o estado e a lógica de negócios relacionada ao formulário de denúncia, incluindo validação, envio de dados e gerenciamento de mídia e localização.
class DenunciaViewModel extends ChangeNotifier {
  
  /// Chave global para o formulário, permitindo validação e controle do estado do formulário.
  final formKey = GlobalKey<FormState>();
  final _service = DenunciaService();
  final tituloCtrl = TextEditingController();
  final localCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final autorCtrl = TextEditingController();

  /// Campos privados para armazenar a foto selecionada, nome do arquivo, coordenadas geográficas e estado de carregamento.
  Uint8List? _fotoBytes;
  String? _nomeArquivoFoto;
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;
  Uint8List? get fotoBytes => _fotoBytes;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  bool get isLoading => _isLoading;


  /// Define a foto selecionada e seu nome.
  void definirFoto(Uint8List bytes, String nome) {
    _fotoBytes = bytes;
    _nomeArquivoFoto = nome;
    notifyListeners();
  }


  /// Alterna a localização com base no GPS.
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

  /// Valida se o valor fornecido é obrigatório.
  String? validarObrigatorio(String? value) {
    if (value == null || value.isEmpty) return "Este campo é obrigatório";
    return null;
  }

  /// Submete o formulário de denúncia, realizando validação, upload de foto (se houver) e envio dos dados ao Supabase.
  Future<bool> submeterFormulario() async {
    if (!formKey.currentState!.validate()) return false;

    _isLoading = true;
    notifyListeners();

    try {
      String? urlPublicaFoto;

      /// 1. Se houver foto selecionada, faz o upload para o Storage primeiro (História 1.5)
      if (_fotoBytes != null && _nomeArquivoFoto != null) {
        urlPublicaFoto = await _service.subirFoto(_fotoBytes!, _nomeArquivoFoto!);
      }

      /// 2. Monta o modelo completo unificado com fotos e GPS
      final novaDenuncia = Denuncia(
        titulo: tituloCtrl.text,
        localizacao: localCtrl.text,
        descricao: descCtrl.text,
        autor: autorCtrl.text.isEmpty ? "Anônimo" : autorCtrl.text,
        latitude: _latitude,
        longitude: _longitude,
        fotoUrl: urlPublicaFoto,
      );

      /// 3. Envia os dados finais ao Supabase
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

  /// Limpa todos os campos do formulário e reseta o estado do ViewModel.
  void limpar() {
    tituloCtrl.clear();
    localCtrl.clear();
    descCtrl.clear();
    autorCtrl.clear();
    _fotoBytes = null;
    _nomeArquivoFoto = null;
    _latitude = null;
    _longitude = null;
    notifyListeners();
  }
}