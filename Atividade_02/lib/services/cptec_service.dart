import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../models/cidade.dart';
import '../models/previsao_cidade.dart';
import '../utils/condicoes_tempo.dart';

class CptecException implements Exception {
  final String mensagem;

  const CptecException(this.mensagem);

  @override
  String toString() => mensagem;
}

class CptecService {
  static const String _host = 'servicos.cptec.inpe.br';
  static const Duration _timeout = Duration(seconds: 12);

  final http.Client _client;

  CptecService({http.Client? client}) : _client = client ?? http.Client();

  /// Decodifica bytes da resposta respeitando ISO-8859-1 (padrão do CPTEC/INPE)
  /// ou UTF-8 caso indicado no cabeçalho XML.
  static String _decodificarResposta(List<int> bytes) {
    final preview = latin1.decode(bytes.take(120).toList());
    if (preview.toLowerCase().contains('encoding="utf-8"') ||
        preview.toLowerCase().contains("encoding='utf-8'")) {
      return utf8.decode(bytes, allowMalformed: true);
    }
    return latin1.decode(bytes);
  }

  /// Faz o parse do XML retornado por /XML/listaCidades.
  static List<Cidade> parseCidadesXml(String xmlContent) {
    final trimmed = xmlContent.trim();
    if (trimmed.isEmpty) {
      throw const CptecException('O serviço retornou uma resposta vazia.');
    }

    try {
      final document = XmlDocument.parse(trimmed);
      final root = document.rootElement;
      if (root.name.local != 'cidades') {
        throw const CptecException('Formato de resposta inválido do serviço.');
      }

      return root
          .findElements('cidade')
          .map(Cidade.fromXml)
          .whereType<Cidade>()
          .toList();
    } on XmlException {
      throw const CptecException(
        'Não foi possível interpretar os dados XML retornados pelo serviço.',
      );
    }
  }

  /// Faz o parse do XML retornado por /XML/cidade/{id}/previsao.xml.
  static PrevisaoCidade parsePrevisaoXml(String xmlContent) {
    final trimmed = xmlContent.trim();
    if (trimmed.isEmpty) {
      throw const CptecException('O serviço retornou uma resposta vazia.');
    }

    try {
      final document = XmlDocument.parse(trimmed);
      final root = document.rootElement;
      if (root.name.local != 'cidade') {
        throw const CptecException('Formato de previsão inválido do serviço.');
      }

      final previsao = PrevisaoCidade.fromXml(root);
      if (previsao.dias.isEmpty) {
        throw const CptecException(
          'Nenhuma previsão disponível para esta localidade no momento.',
        );
      }

      return previsao;
    } on XmlException {
      throw const CptecException(
        'Não foi possível interpretar o XML de previsão do tempo.',
      );
    }
  }

  Future<String> _executarGet(Uri uri) async {
    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        throw CptecException(
          'Serviço do CPTEC/INPE indisponível (HTTP ${response.statusCode}).',
        );
      }

      return _decodificarResposta(response.bodyBytes);
    } on SocketException {
      throw const CptecException(
        'Sem conexão com a internet. Verifique sua rede e tente novamente.',
      );
    } on TimeoutException {
      throw const CptecException(
        'Tempo limite excedido ao consultar o CPTEC/INPE. Tente novamente.',
      );
    } on http.ClientException {
      throw const CptecException(
        'Falha na comunicação com o serviço do CPTEC/INPE.',
      );
    }
  }

  /// Consulta cidades pelo nome no CPTEC/INPE.
  Future<List<Cidade>> buscarCidades(String nomeCidade) async {
    final queryLimpa = removerAcentos(nomeCidade.trim());
    if (queryLimpa.isEmpty) {
      return [];
    }

    final uri = Uri.http(
      _host,
      '/XML/listaCidades',
      {'city': queryLimpa},
    );

    final xmlString = await _executarGet(uri);
    return parseCidadesXml(xmlString);
  }

  /// Consulta a previsão de 4 dias para a cidade informada pelo ID.
  Future<PrevisaoCidade> buscarPrevisao(int cidadeId) async {
    final uri = Uri.http(
      _host,
      '/XML/cidade/$cidadeId/previsao.xml',
    );

    final xmlString = await _executarGet(uri);
    return parsePrevisaoXml(xmlString);
  }
}
