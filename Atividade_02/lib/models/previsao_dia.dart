import 'package:xml/xml.dart';

class PrevisaoDia {
  final String dia;
  final String tempoSigla;
  final double? minima;
  final double? maxima;
  final double? iuv;

  const PrevisaoDia({
    required this.dia,
    required this.tempoSigla,
    this.minima,
    this.maxima,
    this.iuv,
  });

  static double? _parseDoubleSeguro(String? valor) {
    if (valor == null) return null;
    final limpo = valor.trim().replaceAll(',', '.');
    if (limpo.isEmpty ||
        limpo.toLowerCase() == 'null' ||
        limpo.toLowerCase() == 'nd') {
      return null;
    }
    return double.tryParse(limpo);
  }

  factory PrevisaoDia.fromXml(XmlElement element) {
    final dia = element.getElement('dia')?.innerText.trim() ?? '';
    final tempo = element.getElement('tempo')?.innerText.trim() ?? 'nd';
    final minima = _parseDoubleSeguro(element.getElement('minima')?.innerText);
    final maxima = _parseDoubleSeguro(element.getElement('maxima')?.innerText);
    final iuv = _parseDoubleSeguro(element.getElement('iuv')?.innerText);

    return PrevisaoDia(
      dia: dia,
      tempoSigla: tempo.isEmpty ? 'nd' : tempo,
      minima: minima,
      maxima: maxima,
      iuv: iuv,
    );
  }

  factory PrevisaoDia.fromJson(Map<String, dynamic> json) {
    return PrevisaoDia(
      dia: (json['dia'] as String?) ?? '',
      tempoSigla: (json['tempoSigla'] as String?) ?? 'nd',
      minima: (json['minima'] as num?)?.toDouble(),
      maxima: (json['maxima'] as num?)?.toDouble(),
      iuv: (json['iuv'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'dia': dia,
        'tempoSigla': tempoSigla,
        'minima': minima,
        'maxima': maxima,
        'iuv': iuv,
      };
}
