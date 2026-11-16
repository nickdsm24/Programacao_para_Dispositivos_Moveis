import 'package:xml/xml.dart';
import 'previsao_dia.dart';

class PrevisaoCidade {
  final String nome;
  final String uf;
  final String atualizacao;
  final List<PrevisaoDia> dias;
  final DateTime? salvoEm;

  const PrevisaoCidade({
    required this.nome,
    required this.uf,
    required this.atualizacao,
    required this.dias,
    this.salvoEm,
  });

  factory PrevisaoCidade.fromXml(XmlElement cidadeElement) {
    final nome = cidadeElement.getElement('nome')?.innerText.trim() ?? '';
    final uf = cidadeElement.getElement('uf')?.innerText.trim() ?? '--';
    final atualizacao =
        cidadeElement.getElement('atualizacao')?.innerText.trim() ?? '';

    final previsoes = cidadeElement
        .findElements('previsao')
        .map(PrevisaoDia.fromXml)
        .toList();

    return PrevisaoCidade(
      nome: nome,
      uf: uf.isEmpty ? '--' : uf,
      atualizacao: atualizacao,
      dias: previsoes,
      salvoEm: DateTime.now(),
    );
  }

  factory PrevisaoCidade.fromJson(Map<String, dynamic> json) {
    final diasJson = (json['dias'] as List<dynamic>?) ?? [];
    return PrevisaoCidade(
      nome: (json['nome'] as String?) ?? '',
      uf: (json['uf'] as String?) ?? '--',
      atualizacao: (json['atualizacao'] as String?) ?? '',
      dias: diasJson
          .whereType<Map<String, dynamic>>()
          .map(PrevisaoDia.fromJson)
          .toList(),
      salvoEm: json['salvoEm'] != null
          ? DateTime.tryParse(json['salvoEm'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'uf': uf,
        'atualizacao': atualizacao,
        'dias': dias.map((d) => d.toJson()).toList(),
        'salvoEm': salvoEm?.toIso8601String(),
      };
}
