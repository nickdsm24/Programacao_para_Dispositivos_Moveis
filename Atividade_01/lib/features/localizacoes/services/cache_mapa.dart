import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Prepara e gerencia o armazenamento local em cache das imagens do mapa (tiles),
/// utilizando um diretório privado da aplicação.
class CacheMapa {
  static Directory? _diretorioCache;

  /// Obtém e prepara o diretório privado para armazenamento dos tiles do mapa.
  static Future<Directory> obterDiretorioCache() async {
    if (_diretorioCache != null && await _diretorioCache!.exists()) {
      return _diretorioCache!;
    }

    final suporte = await getApplicationSupportDirectory();
    final pastaTiles = Directory(p.join(suporte.path, 'cache_tiles_mapa'));
    if (!await pastaTiles.exists()) {
      await pastaTiles.create(recursive: true);
    }
    _diretorioCache = pastaTiles;
    return _diretorioCache!;
  }

  /// Limpa todos os tiles em cache se necessário.
  static Future<void> limparCache() async {
    final dir = await obterDiretorioCache();
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      _diretorioCache = null;
    }
  }
}

/// TileProvider customizado que armazena os tiles em disco no diretório privado
/// do app antes de carregá-los, respeitando as boas práticas de uso do provedor.
class CachedTileProvider extends TileProvider {
  final Directory diretorioCache;

  CachedTileProvider({
    required this.diretorioCache,
    super.headers,
  });

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final url = getTileUrl(coordinates, options);
    final nomeArquivo =
        'tile_${coordinates.z}_${coordinates.x}_${coordinates.y}.png';
    final arquivoLocal = File(p.join(diretorioCache.path, nomeArquivo));

    return _CachedFileImageProvider(
      url: url,
      arquivoLocal: arquivoLocal,
      headers: headers,
    );
  }
}

class _CachedFileImageProvider extends ImageProvider<_CachedFileImageProvider> {
  final String url;
  final File arquivoLocal;
  final Map<String, String> headers;

  const _CachedFileImageProvider({
    required this.url,
    required this.arquivoLocal,
    this.headers = const {},
  });

  @override
  Future<_CachedFileImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<_CachedFileImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    _CachedFileImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _carregarCodec(decode),
      scale: 1.0,
      debugLabel: key.url,
      informationCollector: () sync* {
        yield DiagnosticsProperty<ImageProvider>('Image provider', this);
        yield DiagnosticsProperty<String>('URL', url);
        yield DiagnosticsProperty<File>('Arquivo Local', arquivoLocal);
      },
    );
  }

  Future<ui.Codec> _carregarCodec(ImageDecoderCallback decode) async {
    // 1. Verifica se já existe em cache local
    if (await arquivoLocal.exists()) {
      try {
        final bytes = await arquivoLocal.readAsBytes();
        final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
        return await decode(buffer);
      } catch (_) {
        // Se arquivo corrompido, tenta buscar novamente na rede
      }
    }

    // 2. Busca na rede com User-Agent apropriado
    final client = http.Client();
    try {
      final requestHeaders = {
        'User-Agent':
            'FatecAppLocalizacoes/1.0 (br.edu.fatec.app_localizacoes)',
        ...headers,
      };
      final resposta =
          await client.get(Uri.parse(url), headers: requestHeaders);

      if (resposta.statusCode == 200) {
        final bytes = resposta.bodyBytes;
        // Salva no cache privado local
        await arquivoLocal.writeAsBytes(bytes, flush: true);
        final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
        return await decode(buffer);
      } else {
        throw Exception('Erro ao carregar tile: status ${resposta.statusCode}');
      }
    } finally {
      client.close();
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _CachedFileImageProvider &&
        other.url == url &&
        other.arquivoLocal.path == arquivoLocal.path;
  }

  @override
  int get hashCode => Object.hash(url, arquivoLocal.path);
}
