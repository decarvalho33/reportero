import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/denuncia.dart';
import '../services/denuncia_service.dart';

class DenunciaViewModel extends ChangeNotifier {
  /// Sem [denunciaExistente], o formulário funciona no modo de criação
  /// (US 4.x/Épico 3). Com ela, entra em modo de edição (US 5.6/5.7): os
  /// campos são pré-preenchidos e o envio atualiza a denúncia em vez de
  /// criar uma nova.
  DenunciaViewModel({Denuncia? denunciaExistente})
      : _denunciaOriginal = denunciaExistente {
    if (denunciaExistente != null) {
      tituloCtrl.text = denunciaExistente.titulo;
      localCtrl.text = denunciaExistente.localizacao;
      descCtrl.text = denunciaExistente.descricao;
      autorCtrl.text =
          denunciaExistente.autor == 'Anônimo' ? '' : denunciaExistente.autor;
      _categoriaSelecionada = denunciaExistente.categoria;
      _latitude = denunciaExistente.latitude;
      _longitude = denunciaExistente.longitude;
      _fotoUrlExistente = denunciaExistente.fotoUrl;
    }
  }

  final formKey = GlobalKey<FormState>();
  final _service = DenunciaService();
  final tituloCtrl = TextEditingController();
  final localCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final autorCtrl = TextEditingController();

  final Denuncia? _denunciaOriginal;
  String? _fotoUrlExistente;

  Uint8List? _fotoBytes;
  String? _nomeArquivoFoto;
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;
  Categoria _categoriaSelecionada = Categoria.outros;

  bool get emEdicao => _denunciaOriginal != null;
  String? get fotoUrlExistente => _fotoUrlExistente;
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
      String? urlFoto = _fotoUrlExistente;
      if (_fotoBytes != null && _nomeArquivoFoto != null) {
        urlFoto = await _service.subirFoto(_fotoBytes!, _nomeArquivoFoto!);
      }

      if (emEdicao) {
        final original = _denunciaOriginal!;
        final atualizada = Denuncia(
          id: original.id,
          titulo: tituloCtrl.text,
          localizacao: localCtrl.text,
          descricao: descCtrl.text,
          autor: autorCtrl.text.isEmpty ? "Anônimo" : autorCtrl.text,
          autorId: original.autorId,
          categoria: _categoriaSelecionada,
          latitude: _latitude,
          longitude: _longitude,
          fotoUrl: urlFoto,
          status: original.status,
        );
        await _service.editarDenuncia(atualizada);
      } else {
        final novaDenuncia = Denuncia(
          titulo: tituloCtrl.text,
          localizacao: localCtrl.text,
          descricao: descCtrl.text,
          autor: autorCtrl.text.isEmpty ? "Anônimo" : autorCtrl.text,
          categoria: _categoriaSelecionada,
          latitude: _latitude,
          longitude: _longitude,
          fotoUrl: urlFoto,
        );
        await _service.enviarDenuncia(novaDenuncia);
      }

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
