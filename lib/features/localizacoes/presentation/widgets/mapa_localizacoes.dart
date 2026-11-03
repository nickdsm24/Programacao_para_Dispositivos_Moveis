import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/localizacao.dart';
import '../../services/cache_mapa.dart';
import 'item_localizacao.dart';

/// Widget responsável por renderizar o mapa interativo, os marcadores e a camada de ruas.
class MapaLocalizacoes extends StatefulWidget {
  final List<Localizacao> localizacoes;
  final Directory diretorioCache;
  final MapController mapController;

  const MapaLocalizacoes({
    super.key,
    required this.localizacoes,
    required this.diretorioCache,
    required this.mapController,
  });

  @override
  State<MapaLocalizacoes> createState() => _MapaLocalizacoesState();
}

class _MapaLocalizacoesState extends State<MapaLocalizacoes> {
  Localizacao? _localizacaoSelecionada;

  @override
  Widget build(BuildContext context) {
    if (widget.localizacoes.isEmpty) {
      return const Center(child: Text('Nenhuma localização para exibir.'));
    }

    final pontoInicial = LatLng(
      widget.localizacoes.first.latitude,
      widget.localizacoes.first.longitude,
    );

    return Stack(
      children: [
        FlutterMap(
          mapController: widget.mapController,
          options: MapOptions(
            initialCenter: pontoInicial,
            initialZoom: 15.0,
            onTap: (_, __) {
              if (_localizacaoSelecionada != null) {
                setState(() {
                  _localizacaoSelecionada = null;
                });
              }
            },
          ),
          children: [
            // Camada de ruas com cache local privado
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              tileProvider: CachedTileProvider(
                diretorioCache: widget.diretorioCache,
              ),
              userAgentPackageName: 'br.edu.fatec.app_localizacoes',
            ),

            // Camada de marcadores
            MarkerLayer(
              markers: _construirMarcadores(),
            ),

            // Atribuição do OpenStreetMap obrigatória
            const Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.all(4.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      '© OpenStreetMap contributors',
                      style: TextStyle(fontSize: 10, color: Colors.black87),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Detalhes da localização selecionada no mapa (reutilizando ItemLocalizacao)
        if (_localizacaoSelecionada != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 24,
            child: Dismissible(
              key: Key(
                  'detalhe_${_localizacaoSelecionada!.id ?? _localizacaoSelecionada!.instante}'),
              onDismissed: (_) {
                setState(() {
                  _localizacaoSelecionada = null;
                });
              },
              child: Stack(
                children: [
                  ItemLocalizacao(
                    localizacao: _localizacaoSelecionada!,
                    isMaisRecente:
                        _localizacaoSelecionada == widget.localizacoes.first,
                  ),
                  Positioned(
                    top: 10,
                    right: 20,
                    child: IconButton(
                      icon:
                          const Icon(Icons.close, size: 20, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _localizacaoSelecionada = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  List<Marker> _construirMarcadores() {
    final marcadores = <Marker>[];

    for (int i = 0; i < widget.localizacoes.length; i++) {
      final loc = widget.localizacoes[i];
      final isMaisRecente = (i == 0);

      marcadores.add(
        Marker(
          point: LatLng(loc.latitude, loc.longitude),
          width: isMaisRecente ? 44 : 34,
          height: isMaisRecente ? 44 : 34,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _localizacaoSelecionada = loc;
              });
            },
            child: Tooltip(
              message: '${loc.latitudeFormatada}, ${loc.longitudeFormatada}',
              child: Icon(
                Icons.location_on,
                size: isMaisRecente ? 44 : 34,
                // O ponto mais recente deve ser destacado em VERMELHO
                color: isMaisRecente ? Colors.red : Colors.blue[700],
                shadows: const [
                  Shadow(
                    offset: Offset(0, 2),
                    blurRadius: 4.0,
                    color: Colors.black45,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return marcadores;
  }
}
