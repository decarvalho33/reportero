import '../models/denuncia.dart';

// Este serviço simula o envio de uma denúncia para um servidor
class DenunciaService {
  Future<void> enviarDenuncia(Denuncia denuncia) async {
    // simula o envio da denúncia para um servidor
    try {
      final dados = denuncia.toJson();

      print("BACKEND LOG");
      print("JSON estruturado para envio: $dados");

      await Future.delayed(Duration(seconds: 1)); // Simula o tempo de envio
      print("Denúncia enviada com sucesso!");
    } catch (e) {
      print("Erro ao enviar denúncia: $e");
    }
  }
}
