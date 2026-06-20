import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/documento.dart';

class DocumentoService {
  static final _client = Supabase.instance.client;
  static const _bucket = 'documentos';

  /// Upload de documento para o Supabase Storage e registro na tabela
  static Future<void> upload({
    required int clienteId,
    required String nomeArquivo,
    required String tipo,
    required Uint8List bytes,
  }) async {
    // Caminho no storage: documentos/cliente_<id>/<nomeArquivo>
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = 'cliente_$clienteId/${timestamp}_$nomeArquivo';

    // Upload para o Storage
    await _client.storage.from(_bucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    // Gerar URL pública
    final url = _client.storage.from(_bucket).getPublicUrl(path);

    // Registrar na tabela documentos
    await _client.from('documentos').insert(
      Documento(
        clienteId: clienteId,
        nome: nomeArquivo,
        tipo: tipo,
        url: url,
      ).toJson(),
    );
  }

  /// Listar documentos de um cliente
  static Future<List<Documento>> listar(int clienteId) async {
    final dados = await _client
        .from('documentos')
        .select()
        .eq('cliente_id', clienteId)
        .order('created_at', ascending: false);

    return (dados as List)
        .map((json) => Documento.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Deletar documento (storage + banco)
  static Future<void> deletar(Documento doc) async {
    // Extrair o path do storage a partir da URL
    final uri = Uri.parse(doc.url);
    final segments = uri.pathSegments;
    // O path no storage começa após 'object/public/<bucket>/'
    final bucketIndex = segments.indexOf(_bucket);
    if (bucketIndex != -1 && bucketIndex + 1 < segments.length) {
      final storagePath = segments.sublist(bucketIndex + 1).join('/');
      try {
        await _client.storage.from(_bucket).remove([storagePath]);
      } catch (_) {
        // Ignora erro se arquivo não existe no storage
      }
    }

    // Remover do banco
    await _client.from('documentos').delete().eq('id', doc.id!);
  }
}
