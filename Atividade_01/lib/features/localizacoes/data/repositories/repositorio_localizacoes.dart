import '../../models/localizacao.dart';
import '../database/banco_localizacoes.dart';

/// Centraliza operações de inserção, consulta e exclusão de localizações.
class RepositorioLocalizacoes {
  final BancoLocalizacoes _banco;

  RepositorioLocalizacoes({BancoLocalizacoes? banco})
      : _banco = banco ?? BancoLocalizacoes.instance;

  /// Insere um novo registro de localização e retorna o id gerado.
  Future<int> inserir(Localizacao localizacao) async {
    final db = await _banco.database;
    return await db.insert(
      BancoLocalizacoes.tabelaLocalizacoes,
      localizacao.toMap(),
    );
  }

  /// Consulta as últimas localizações salvas, ordenadas da mais recente para a mais antiga.
  /// O limite padrão é 100 registros conforme especificado.
  Future<List<Localizacao>> consultarUltimas({int limite = 100}) async {
    final db = await _banco.database;
    final List<Map<String, dynamic>> registros = await db.query(
      BancoLocalizacoes.tabelaLocalizacoes,
      orderBy: 'instante DESC',
      limit: limite,
    );

    return registros.map((map) => Localizacao.fromMap(map)).toList();
  }

  /// Exclui todas as linhas da tabela preservando sua estrutura e o arquivo do banco.
  Future<int> excluirTodas() async {
    final db = await _banco.database;
    return await db.delete(BancoLocalizacoes.tabelaLocalizacoes);
  }

  /// Retorna o total de registros salvos na tabela.
  Future<int> contarTotal() async {
    final db = await _banco.database;
    final resultado = await db.rawQuery(
      'SELECT COUNT(*) as total FROM ${BancoLocalizacoes.tabelaLocalizacoes}',
    );
    if (resultado.isNotEmpty) {
      return (resultado.first['total'] as int?) ?? 0;
    }
    return 0;
  }
}
