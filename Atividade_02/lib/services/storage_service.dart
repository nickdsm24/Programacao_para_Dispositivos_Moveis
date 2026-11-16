import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cidade.dart';
import '../models/previsao_cidade.dart';

/// Gerencia a persistência local usando SharedPreferences:
/// - Última cidade selecionada
/// - Cache da última previsão consultada por cidade
/// - Histórico recente de cidades pesquisadas
class StorageService {
  static const String _keyUltimaCidade = 'ultima_cidade';
  static const String _keyHistoricoCidades = 'historico_cidades';
  static const String _prefixPrevisaoCache = 'previsao_cache_';
  static const int _maxHistorico = 8;

  Future<void> salvarUltimaCidade(Cidade cidade) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUltimaCidade, jsonEncode(cidade.toJson()));
    await adicionarAoHistorico(cidade);
  }

  Future<Cidade?> carregarUltimaCidade() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUltimaCidade);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        final cidade = Cidade.fromJson(decoded);
        return cidade.id > 0 && cidade.nome.isNotEmpty ? cidade : null;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<void> salvarPrevisaoCache(
    int cidadeId,
    PrevisaoCidade previsao,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_prefixPrevisaoCache$cidadeId',
      jsonEncode(previsao.toJson()),
    );
  }

  Future<PrevisaoCidade?> carregarPrevisaoCache(int cidadeId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefixPrevisaoCache$cidadeId');
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return PrevisaoCidade.fromJson(decoded);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<void> adicionarAoHistorico(Cidade cidade) async {
    final prefs = await SharedPreferences.getInstance();
    final listaAtual = await carregarHistorico();

    listaAtual.removeWhere((c) => c.id == cidade.id);
    listaAtual.insert(0, cidade);

    if (listaAtual.length > _maxHistorico) {
      listaAtual.removeRange(_maxHistorico, listaAtual.length);
    }

    final encoded = listaAtual.map((c) => c.toJson()).toList();
    await prefs.setString(_keyHistoricoCidades, jsonEncode(encoded));
  }

  Future<List<Cidade>> carregarHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyHistoricoCidades);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(Cidade.fromJson)
            .where((c) => c.id > 0 && c.nome.isNotEmpty)
            .toList();
      }
    } catch (_) {
      return [];
    }
    return [];
  }

  Future<void> removerDoHistorico(int cidadeId) async {
    final prefs = await SharedPreferences.getInstance();
    final listaAtual = await carregarHistorico();
    listaAtual.removeWhere((c) => c.id == cidadeId);
    final encoded = listaAtual.map((c) => c.toJson()).toList();
    await prefs.setString(_keyHistoricoCidades, jsonEncode(encoded));
  }
}
