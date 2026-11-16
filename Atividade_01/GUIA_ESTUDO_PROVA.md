# 🎓 Guia de Estudo e Teste de Mesa para a Prova Teórica
**Disciplina: Programação para Dispositivos Móveis I — Prof. Arley**
**Tema: Coleta e Visualização de Localizações (Flutter, SQLite, Streams e Geolocator)**

Este guia foi elaborado para você entender a lógica de cada linha de código, o fluxo dos dados e gabaritar a prova individual no papel com código de mesa e preenchimento de lacunas.

---

## 1. O Modelo: `Localizacao` (`models/localizacao.dart`)

### O que o professor pode pedir:
- Completar o método `toMap()` ou `fromMap()`.
- Por que usamos `toUtc()` na gravação e `toLocal()` na leitura.
- Formatação com casas decimais fixas.

### O Código-Chave:
```dart
class Localizacao {
  final int? id;
  final double latitude;
  final double longitude;
  final double precisao;
  final DateTime instante;

  Localizacao({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.precisao,
    required this.instante,
  });

  // Grava no banco com instante em UTC no formato ISO 8601:
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'precisao': precisao,
      'instante': instante.toUtc().toIso8601String(), // <-- LACUNA COMUM
    };
  }

  // Lê do banco e converte de volta para o horário local:
  factory Localizacao.fromMap(Map<String, dynamic> map) {
    return Localizacao(
      id: map['id'] as int?,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      precisao: (map['precisao'] as num).toDouble(),
      instante: DateTime.parse(map['instante'] as String).toLocal(), // <-- LACUNA COMUM
    );
  }

  // Formatação: 6 casas para coordenadas e 1 casa para precisão em metros
  String get latitudeFormatada => latitude.toStringAsFixed(6);
  String get longitudeFormatada => longitude.toStringAsFixed(6);
  String get precisaoFormatada => '${precisao.toStringAsFixed(1)} m';
}
```

---

## 2. Persistência: Banco e Repositório SQLite (`data/`)

### Banco de Dados (`banco_localizacoes.dart`)
- **Tabela**: `localizacoes`
- **Campos**:
  - `id INTEGER PRIMARY KEY AUTOINCREMENT`
  - `latitude REAL NOT NULL`
  - `longitude REAL NOT NULL`
  - `precisao REAL NOT NULL`
  - `instante TEXT NOT NULL`
- **Reutilização da conexão**: Se `_database != null && _database!.isOpen`, retorna a mesma instância aberta (padrão Singleton).

### Repositório (`repositorio_localizacoes.dart`)
Preste muita atenção nos 3 métodos exigidos:

```dart
// 1. Inserir:
Future<int> inserir(Localizacao localizacao) async {
  final db = await _banco.database;
  return await db.insert('localizacoes', localizacao.toMap());
}

// 2. Consultar as últimas 100 da mais recente para a mais antiga:
Future<List<Localizacao>> consultarUltimas({int limite = 100}) async {
  final db = await _banco.database;
  final List<Map<String, dynamic>> registros = await db.query(
    'localizacoes',
    orderBy: 'instante DESC', // <-- MAIS RECENTE PRIMEIRO
    limit: limite,            // <-- LIMITE DE 100
  );
  return registros.map((map) => Localizacao.fromMap(map)).toList();
}

// 3. Limpar todo o histórico sem apagar a tabela:
Future<int> excluirTodas() async {
  final db = await _banco.database;
  return await db.delete('localizacoes'); // <-- DELETE FROM sem DROP TABLE
}
```

---

## 3. Coleta Contínua e Streams (`services/servico_localizacao.dart`)

### Por que não usar `Timer.periodic` ou `workmanager`?
O professor proibiu explicitamente ambos no PDF. O motivo:
- `Timer.periodic` faz polling forçado (desperdiça bateria e não respeita eventos de hardware do GPS).
- O correto é usar **Streams reativos**: o sistema operacional notifica o app apenas quando há uma nova leitura de satélite.

### Como funciona o Stream no Geolocator:
```dart
Stream<Position> obterStreamPosicoes() {
  final androidSettings = AndroidSettings(
    accuracy: LocationAccuracy.high,
    intervalDuration: const Duration(seconds: 20), // 20 segundos
    distanceFilter: 0,
    foregroundNotificationConfig: const ForegroundNotificationConfig(
      notificationTitle: 'Coleta de Localizações Ativa',
      notificationText: 'Gravando posições continuamente...',
      enableWakeLock: true, // Mantém a CPU acordada para coletar
    ),
  );

  return Geolocator.getPositionStream(locationSettings: androidSettings);
}
```

---

## 4. Gerenciamento do Stream na Tela (`tela_coleta.dart`)

### O Ciclo de Vida:
1. **Evitar duplicidade**: Se `_coletando == true`, não cria novo listener.
2. **Evitar sobreposição de gravação**: Se já está executando o `insert`, uma variável de trava (`bool _gravando`) ignora leituras sobrepostas.
3. **Cancelar ao parar ou encerrar**:
   ```dart
   void _pararColeta() {
     _posicaoSubscription?.cancel();
     _posicaoSubscription = null;
     setState(() => _coletando = false);
   }

   @override
   void dispose() {
     _posicaoSubscription?.cancel(); // <-- SEMPRE liberar o stream para não vazar memória!
     super.dispose();
   }
   ```
4. **Proteção de Contexto Assíncrono (`if (!mounted) return;`)**:
   Sempre que fizer um `await` antes de chamar `setState` ou `ScaffoldMessenger`, verificar se o widget ainda está montado na tela.

---

## 5. Visualização em Mapa (`presentation/screens/tela_mapa.dart`)

### Requisitos Chave do Mapa:
- **Últimas 100 posições**: `consultarUltimas(limite: 100)`.
- **Destaque do mais recente**:
  Como a lista vem ordenada em `DESC`, o primeiro item (`localizacoes[0]`) é o mais recente. Ele recebe a cor **Vermelha** (`Colors.red`), e os outros pontos recebem cor azul.
- **Enquadramento com MapController**:
  ```dart
  final bounds = LatLngBounds.fromPoints(pontos);
  _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: EdgeInsets.all(50)));
  ```
- **Cache local em pasta privada (`cache_mapa.dart`)**:
  Usa `getApplicationSupportDirectory()` para salvar os arquivos de tiles (`tile_z_x_y.png`) localmente antes de recarregar da internet.
