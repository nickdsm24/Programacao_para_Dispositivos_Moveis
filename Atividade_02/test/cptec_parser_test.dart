import 'package:flutter_test/flutter_test.dart';
import 'package:previsao_tempo/services/cptec_service.dart';
import 'package:previsao_tempo/utils/condicoes_tempo.dart';

void main() {
  group('CPTEC XML Parser', () {
    test('parseCidadesXml interpreta lista de cidades corretamente', () {
      const xml = '''
<?xml version='1.0' encoding='ISO-8859-1'?>
<cidades>
  <cidade>
    <nome>São Paulo</nome>
    <uf>SP</uf>
    <id>244</id>
  </cidade>
  <cidade>
    <nome>São José dos Campos</nome>
    <uf>SP</uf>
    <id>4992</id>
  </cidade>
</cidades>
''';

      final cidades = CptecService.parseCidadesXml(xml);

      expect(cidades.length, 2);
      expect(cidades[0].id, 244);
      expect(cidades[0].nome, 'São Paulo');
      expect(cidades[0].uf, 'SP');
      expect(cidades[1].id, 4992);
    });

    test('parseCidadesXml retorna lista vazia quando não há cidades', () {
      const xml = '''
<?xml version='1.0' encoding='ISO-8859-1'?>
<cidades></cidades>
''';

      final cidades = CptecService.parseCidadesXml(xml);
      expect(cidades, isEmpty);
    });

    test('parsePrevisaoXml interpreta 4 dias e trata IUV ausente sem erro', () {
      const xml = '''
<?xml version='1.0' encoding='ISO-8859-1'?>
<cidade>
  <nome>São Paulo</nome>
  <uf>SP</uf>
  <atualizacao>2026-11-16</atualizacao>
  <previsao>
    <dia>2026-11-17</dia>
    <tempo>pn</tempo>
    <maxima>26</maxima>
    <minima>17</minima>
    <iuv>8.0</iuv>
  </previsao>
  <previsao>
    <dia>2026-11-18</dia>
    <tempo>c</tempo>
    <maxima>22</maxima>
    <minima>16</minima>
  </previsao>
  <previsao>
    <dia>2026-11-19</dia>
    <tempo>cl</tempo>
    <maxima>28</maxima>
    <minima>18</minima>
    <iuv>nd</iuv>
  </previsao>
  <previsao>
    <dia>2026-11-20</dia>
    <tempo>ps</tempo>
    <maxima>29</maxima>
    <minima>19</minima>
    <iuv>10.5</iuv>
  </previsao>
</cidade>
''';

      final previsao = CptecService.parsePrevisaoXml(xml);

      expect(previsao.nome, 'São Paulo');
      expect(previsao.uf, 'SP');
      expect(previsao.atualizacao, '2026-11-16');
      expect(previsao.dias.length, 4);

      expect(previsao.dias[0].tempoSigla, 'pn');
      expect(previsao.dias[0].maxima, 26);
      expect(previsao.dias[0].minima, 17);
      expect(previsao.dias[0].iuv, 8.0);

      expect(previsao.dias[1].iuv, isNull);
      expect(previsao.dias[2].iuv, isNull);
    });

    test('parsePrevisaoXml lança CptecException para XML inválido', () {
      expect(
        () => CptecService.parsePrevisaoXml('<cidade><sem_fechar>'),
        throwsA(isA<CptecException>()),
      );
    });
  });

  group('Utilitários de condição do tempo', () {
    test('converte siglas oficiais do CPTEC para descrições legíveis', () {
      expect(obterCondicaoTempo('pn').descricao, 'Parcialmente Nublado');
      expect(obterCondicaoTempo('c').descricao, 'Chuva');
      expect(obterCondicaoTempo('cl').descricao, 'Céu Claro');
      expect(obterCondicaoTempo('nd').descricao, 'Não Definido');
    });

    test('remove acentos corretamente para consulta de cidades', () {
      expect(removerAcentos('São José dos Campos'), 'Sao Jose dos Campos');
      expect(removerAcentos('Florianópolis'), 'Florianopolis');
    });
  });
}
