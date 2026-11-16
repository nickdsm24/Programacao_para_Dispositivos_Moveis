import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../data/repositories/repositorio_localizacoes.dart';
import '../../models/localizacao.dart';
import '../../services/cache_mapa.dart';
import '../widgets/mapa_localizacoes.dart';

/// Tela responsável por carregar os dados, gerenciar o estado da visualização e renderizar o mapa interativo.
class TelaMapa extends StatefulWidget {
  final RepositorioLocalizacoes repositorio;

  const TelaMapa({
    super.key,
    required this.repositorio,
  });

  @override
  State<TelaMapa> createState() => _TelaMapaState();
}

class _TelaMapaState extends State<TelaMapa> {
  final MapController _mapController = MapController();
  List<Localizacao> _localizacoes = [];
  Directory? _diretorioCache;
  bool _carregando = true;
  String? _mensagemErro;

  @override
  void initState() {
    super.initState();
    _carregarDadosEMapa();
  }

  Future<void> _carregarDadosEMapa() async {
    setState(() {
      _carregando = true;
      _mensagemErro = null;
    });

    try {
      // 1. Prepara a pasta privada para o cache local do mapa
      final dirCache = await CacheMapa.obterDiretorioCache();

      // 2. Consulta as últimas 100 posições salvas
      final pontos = await widget.repositorio.consultarUltimas(limite: 100);

      if (!mounted) return;

      setState(() {
        _diretorioCache = dirCache;
        _localizacoes = pontos;
        _carregando = false;
      });

      // 3. Enquadra os pontos logo após carregar os dados
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _enquadrarPontos();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _mensagemErro = 'Falha ao carregar mapa e localizações: $e';
        _carregando = false;
      });
    }
  }

  void _enquadrarPontos() {
    if (_localizacoes.isEmpty) return;

    if (_localizacoes.length == 1) {
      final ponto = LatLng(
        _localizacoes.first.latitude,
        _localizacoes.first.longitude,
      );
      _mapController.move(ponto, 16.0);
      return;
    }

    final pontos = _localizacoes
        .map((loc) => LatLng(loc.latitude, loc.longitude))
        .toList();

    final bounds = LatLngBounds.fromPoints(pontos);

    try {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50.0),
        ),
      );
    } catch (_) {
      // Ignora erro se widget ainda estiver dimensionando a viewport
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa Interativo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar registros',
            onPressed: _carregarDadosEMapa,
          ),
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            tooltip: 'Enquadrar todos os pontos',
            onPressed: _localizacoes.isNotEmpty ? _enquadrarPontos : null,
          ),
        ],
      ),
      body: _construirCorpo(),
    );
  }

  Widget _construirCorpo() {
    // 1. Estado de espera / carregamento
    if (_carregando) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando posições e mapa...'),
          ],
        ),
      );
    }

    // 2. Estado de erro
    if (_mensagemErro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                _mensagemErro!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _carregarDadosEMapa,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Estado de histórico vazio
    if (_localizacoes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.map_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 12),
              const Text(
                'Histórico vazio.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Não há posições salvas para exibir no mapa.\nInicie a coleta na tela anterior para registrar dados.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    // 4. Mapa com dados
    return MapaLocalizacoes(
      localizacoes: _localizacoes,
      diretorioCache: _diretorioCache!,
      mapController: _mapController,
    );
  }
}
