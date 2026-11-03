import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Gerencia a conexão com o banco de dados SQLite localizacoes.db.
class BancoLocalizacoes {
  static const String nomeBanco = 'localizacoes.db';
  static const int versaoBanco = 1;
  static const String tabelaLocalizacoes = 'localizacoes';

  static Database? _database;
  static final BancoLocalizacoes instance = BancoLocalizacoes._internal();

  BancoLocalizacoes._internal();

  /// Retorna a instância ativa do banco de dados, inicializando-a se necessário.
  /// Caso uma tentativa anterior tenha falhado, permite uma nova tentativa.
  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    try {
      _database = await _inicializarBanco();
      return _database!;
    } catch (e) {
      _database = null;
      rethrow;
    }
  }

  Future<Database> _inicializarBanco() async {
    final basePath = await getDatabasesPath();
    final caminhoBanco = p.join(basePath, nomeBanco);

    return await openDatabase(
      caminhoBanco,
      version: versaoBanco,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tabelaLocalizacoes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            precisao REAL NOT NULL,
            instante TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Fecha a conexão caso esteja aberta.
  Future<void> fechar() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
}
