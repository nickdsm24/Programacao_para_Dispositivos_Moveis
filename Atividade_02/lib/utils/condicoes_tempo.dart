import 'package:flutter/material.dart';

class CondicaoTempoInfo {
  final String descricao;
  final IconData icone;
  final Color cor;

  const CondicaoTempoInfo({
    required this.descricao,
    required this.icone,
    required this.cor,
  });
}

/// Mapeamento das siglas oficiais de condições do tempo do CPTEC/INPE.
const Map<String, CondicaoTempoInfo> _mapaCondicoesTempo = {
  'ec': CondicaoTempoInfo(
    descricao: 'Encoberto com Chuvas Isoladas',
    icone: Icons.grain,
    cor: Color(0xFF5C6BC0),
  ),
  'ci': CondicaoTempoInfo(
    descricao: 'Chuvas Isoladas',
    icone: Icons.water_drop_outlined,
    cor: Color(0xFF42A5F5),
  ),
  'c': CondicaoTempoInfo(
    descricao: 'Chuva',
    icone: Icons.water_drop,
    cor: Color(0xFF1E88E5),
  ),
  'in': CondicaoTempoInfo(
    descricao: 'Instável',
    icone: Icons.cloud_queue,
    cor: Color(0xFF78909C),
  ),
  'pp': CondicaoTempoInfo(
    descricao: 'Possibilidade de Pancadas de Chuva',
    icone: Icons.umbrella_outlined,
    cor: Color(0xFF4FC3F7),
  ),
  'cm': CondicaoTempoInfo(
    descricao: 'Chuva pela Manhã',
    icone: Icons.water_drop,
    cor: Color(0xFF29B6F6),
  ),
  'cn': CondicaoTempoInfo(
    descricao: 'Chuva à Noite',
    icone: Icons.nights_stay,
    cor: Color(0xFF3949AB),
  ),
  'pt': CondicaoTempoInfo(
    descricao: 'Pancadas de Chuva à Tarde',
    icone: Icons.thunderstorm_outlined,
    cor: Color(0xFF1976D2),
  ),
  'pm': CondicaoTempoInfo(
    descricao: 'Pancadas de Chuva pela Manhã',
    icone: Icons.thunderstorm_outlined,
    cor: Color(0xFF1976D2),
  ),
  'np': CondicaoTempoInfo(
    descricao: 'Nublado e Pancadas de Chuva',
    icone: Icons.thunderstorm,
    cor: Color(0xFF3F51B5),
  ),
  'pc': CondicaoTempoInfo(
    descricao: 'Pancadas de Chuva',
    icone: Icons.thunderstorm,
    cor: Color(0xFF1565C0),
  ),
  'pn': CondicaoTempoInfo(
    descricao: 'Parcialmente Nublado',
    icone: Icons.wb_cloudy_outlined,
    cor: Color(0xFFFB8C00),
  ),
  'cv': CondicaoTempoInfo(
    descricao: 'Chuvisco',
    icone: Icons.grain,
    cor: Color(0xFF64B5F6),
  ),
  'ch': CondicaoTempoInfo(
    descricao: 'Chuvoso',
    icone: Icons.beach_access,
    cor: Color(0xFF0288D1),
  ),
  't': CondicaoTempoInfo(
    descricao: 'Tempestade',
    icone: Icons.flash_on,
    cor: Color(0xFF4527A0),
  ),
  'ps': CondicaoTempoInfo(
    descricao: 'Predomínio de Sol',
    icone: Icons.wb_sunny,
    cor: Color(0xFFF9A825),
  ),
  'e': CondicaoTempoInfo(
    descricao: 'Encoberto',
    icone: Icons.cloud,
    cor: Color(0xFF607D8B),
  ),
  'n': CondicaoTempoInfo(
    descricao: 'Nublado',
    icone: Icons.cloud_outlined,
    cor: Color(0xFF78909C),
  ),
  'cl': CondicaoTempoInfo(
    descricao: 'Céu Claro',
    icone: Icons.wb_sunny,
    cor: Color(0xFFFFB300),
  ),
  'nv': CondicaoTempoInfo(
    descricao: 'Nevoeiro',
    icone: Icons.blur_on,
    cor: Color(0xFF90A4AE),
  ),
  'g': CondicaoTempoInfo(
    descricao: 'Geada',
    icone: Icons.ac_unit,
    cor: Color(0xFF00ACC1),
  ),
  'ne': CondicaoTempoInfo(
    descricao: 'Neve',
    icone: Icons.ac_unit,
    cor: Color(0xFF26C6DA),
  ),
  'nd': CondicaoTempoInfo(
    descricao: 'Não Definido',
    icone: Icons.help_outline,
    cor: Color(0xFF9E9E9E),
  ),
  'pnt': CondicaoTempoInfo(
    descricao: 'Pancadas de Chuva à Noite',
    icone: Icons.thunderstorm,
    cor: Color(0xFF283593),
  ),
  'psc': CondicaoTempoInfo(
    descricao: 'Possibilidade de Chuva',
    icone: Icons.umbrella_outlined,
    cor: Color(0xFF4FC3F7),
  ),
  'pcm': CondicaoTempoInfo(
    descricao: 'Possibilidade de Chuva pela Manhã',
    icone: Icons.umbrella_outlined,
    cor: Color(0xFF4FC3F7),
  ),
  'pct': CondicaoTempoInfo(
    descricao: 'Possibilidade de Chuva à Tarde',
    icone: Icons.umbrella_outlined,
    cor: Color(0xFF4FC3F7),
  ),
  'pcn': CondicaoTempoInfo(
    descricao: 'Possibilidade de Chuva à Noite',
    icone: Icons.nights_stay,
    cor: Color(0xFF3949AB),
  ),
  'npt': CondicaoTempoInfo(
    descricao: 'Nublado com Pancadas à Tarde',
    icone: Icons.thunderstorm_outlined,
    cor: Color(0xFF5C6BC0),
  ),
  'npn': CondicaoTempoInfo(
    descricao: 'Nublado com Pancadas à Noite',
    icone: Icons.thunderstorm_outlined,
    cor: Color(0xFF3F51B5),
  ),
  'ncn': CondicaoTempoInfo(
    descricao: 'Nublado com Possibilidade de Chuva à Noite',
    icone: Icons.cloud,
    cor: Color(0xFF546E7A),
  ),
  'nct': CondicaoTempoInfo(
    descricao: 'Nublado com Possibilidade de Chuva à Tarde',
    icone: Icons.cloud,
    cor: Color(0xFF546E7A),
  ),
  'ncm': CondicaoTempoInfo(
    descricao: 'Nublado com Possibilidade de Chuva pela Manhã',
    icone: Icons.cloud,
    cor: Color(0xFF546E7A),
  ),
  'npm': CondicaoTempoInfo(
    descricao: 'Nublado com Pancadas pela Manhã',
    icone: Icons.thunderstorm_outlined,
    cor: Color(0xFF5C6BC0),
  ),
  'npp': CondicaoTempoInfo(
    descricao: 'Nublado com Possibilidade de Chuva',
    icone: Icons.cloud_queue,
    cor: Color(0xFF607D8B),
  ),
  'vn': CondicaoTempoInfo(
    descricao: 'Variação de Nebulosidade',
    icone: Icons.filter_drama,
    cor: Color(0xFF8D6E63),
  ),
  'ct': CondicaoTempoInfo(
    descricao: 'Chuva à Tarde',
    icone: Icons.water_drop,
    cor: Color(0xFF1E88E5),
  ),
  'ppn': CondicaoTempoInfo(
    descricao: 'Possibilidade de Pancadas de Chuva à Noite',
    icone: Icons.nights_stay,
    cor: Color(0xFF3949AB),
  ),
  'ppt': CondicaoTempoInfo(
    descricao: 'Possibilidade de Pancadas de Chuva à Tarde',
    icone: Icons.umbrella_outlined,
    cor: Color(0xFF29B6F6),
  ),
  'ppm': CondicaoTempoInfo(
    descricao: 'Possibilidade de Pancadas de Chuva pela Manhã',
    icone: Icons.umbrella_outlined,
    cor: Color(0xFF29B6F6),
  ),
};

CondicaoTempoInfo obterCondicaoTempo(String? sigla) {
  final chave = (sigla ?? '').trim().toLowerCase();
  if (chave.isEmpty) {
    return _mapaCondicoesTempo['nd']!;
  }
  return _mapaCondicoesTempo[chave] ??
      CondicaoTempoInfo(
        descricao: 'Condição desconhecida (${chave.toUpperCase()})',
        icone: Icons.wb_cloudy_outlined,
        cor: const Color(0xFF757575),
      );
}

/// Remove acentos e caracteres especiais para consulta no endpoint listaCidades.
String removerAcentos(String texto) {
  const comAcento = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ';
  const semAcento = 'AAAAAAaaaaaaOOOOOOooooooEEEEeeeeCcIIIIiiiiUUUUuuuuyNn';

  var resultado = texto;
  for (var i = 0; i < comAcento.length; i++) {
    resultado = resultado.replaceAll(comAcento[i], semAcento[i]);
  }
  return resultado;
}

/// Formata data ISO (yyyy-MM-dd) para dd/MM/yyyy com fallback seguro.
String formatarDataBr(String? dataIso) {
  if (dataIso == null || dataIso.trim().isEmpty) return 'Data indisponível';
  final dt = DateTime.tryParse(dataIso.trim());
  if (dt == null) return dataIso;
  final dia = dt.day.toString().padLeft(2, '0');
  final mes = dt.month.toString().padLeft(2, '0');
  return '$dia/$mes/${dt.year}';
}

/// Formata data ISO (yyyy-MM-dd) para dd/MM (usado no eixo do gráfico).
String formatarDataCurta(String? dataIso) {
  if (dataIso == null || dataIso.trim().isEmpty) return '--/--';
  final dt = DateTime.tryParse(dataIso.trim());
  if (dt == null) return dataIso;
  final dia = dt.day.toString().padLeft(2, '0');
  final mes = dt.month.toString().padLeft(2, '0');
  return '$dia/$mes';
}

/// Retorna o nome abreviado do dia da semana em português.
String obterDiaSemana(String? dataIso) {
  if (dataIso == null || dataIso.trim().isEmpty) return '';
  final dt = DateTime.tryParse(dataIso.trim());
  if (dt == null) return '';
  const dias = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo',
  ];
  return dias[dt.weekday - 1];
}

/// Classificação simplificada do Índice Ultravioleta (IUV).
String classificarIuv(double iuv) {
  if (iuv < 3) return 'Baixo';
  if (iuv < 6) return 'Moderado';
  if (iuv < 8) return 'Alto';
  if (iuv < 11) return 'Muito Alto';
  return 'Extremo';
}
