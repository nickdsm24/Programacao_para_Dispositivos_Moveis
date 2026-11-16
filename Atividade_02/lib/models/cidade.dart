import 'package:xml/xml.dart';

class Cidade {
  final int id;
  final String nome;
  final String uf;

  const Cidade({
    required this.id,
    required this.nome,
    required this.uf,
  });

  static Cidade? fromXml(XmlElement element) {
    final idStr = element.getElement('id')?.innerText.trim() ?? '';
    final id = int.tryParse(idStr);
    final nome = element.getElement('nome')?.innerText.trim() ?? '';
    final uf = element.getElement('uf')?.innerText.trim() ?? '';

    if (id == null || nome.isEmpty) {
      return null;
    }

    return Cidade(
      id: id,
      nome: nome,
      uf: uf.isEmpty ? '--' : uf,
    );
  }

  factory Cidade.fromJson(Map<String, dynamic> json) {
    return Cidade(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nome: (json['nome'] as String?) ?? '',
      uf: (json['uf'] as String?) ?? '--',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'uf': uf,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cidade && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
