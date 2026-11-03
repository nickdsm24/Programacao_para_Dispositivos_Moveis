import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/repositories/repositorio_localizacoes.dart';
import '../../models/localizacao.dart';
import '../../services/servico_localizacao.dart';
import 'tela_localizacoes.dart';
import 'tela_mapa.dart';

/// Tela inicial responsável por controlar a coleta, gerenciar a assinatura do stream
/// e navegar para histórico e mapa.
class TelaColeta extends StatefulWidget {
  final ServicoLocalizacao servicoLocalizacao;
  final RepositorioLocalizacoes repositorioLocalizacoes;

  const TelaColeta({
    super.key,
    required this.servicoLocalizacao,
    required this.repositorioLocalizacoes,
  });

  @override
  State<TelaColeta> createState() => _TelaColetaState();
}

class _TelaColetaState extends State<TelaColeta> {
  StreamSubscription<Position>? _posicaoSubscription;
  bool _coletando = false;
  bool _gravando = false;
  int _pontosColetadosSessao = 0;
  String? _statusMensagem;

  @override
  void dispose() {
    _posicaoSubscription?.cancel();
    super.dispose();
  }

  Future<void> _iniciarColeta() async {
    // Evita assinaturas duplicadas
    if (_coletando || _posicaoSubscription != null) {
      return;
    }

    setState(() {
      _statusMensagem = 'Verificando serviços e permissões...';
    });

    // 1. Verificar se o GPS está ativo
    final servicoAtivo = await widget.servicoLocalizacao.isServicoHabilitado();
    if (!mounted) return;
    if (!servicoAtivo) {
      _exibirDialogo(
        titulo: 'GPS Desativado',
        mensagem:
            'O serviço de localização (GPS) está desativado. Por favor, ative-o nas configurações do aparelho para iniciar a coleta.',
        exibirBotaoConfiguracoes: false,
      );
      setState(() => _statusMensagem = 'GPS desativado.');
      return;
    }

    // 2. Verificar permissão atual
    LocationPermission permissao =
        await widget.servicoLocalizacao.verificarPermissao();
    if (!mounted) return;

    if (permissao == LocationPermission.denied) {
      permissao = await widget.servicoLocalizacao.solicitarPermissao();
      if (!mounted) return;
    }

    if (permissao == LocationPermission.denied) {
      _exibirDialogo(
        titulo: 'Permissão Necessária',
        mensagem:
            'A permissão de localização foi negada. O aplicativo precisa dela para coletar suas coordenadas.',
        exibirBotaoConfiguracoes: false,
      );
      setState(() => _statusMensagem = 'Permissão negada.');
      return;
    }

    if (permissao == LocationPermission.deniedForever) {
      _exibirDialogo(
        titulo: 'Permissão Bloqueada',
        mensagem:
            'A permissão de localização está bloqueada permanentemente. Por favor, habilite-a nas configurações do aplicativo.',
        exibirBotaoConfiguracoes: true,
      );
      setState(() => _statusMensagem = 'Permissão bloqueada permanentemente.');
      return;
    }

    // 3. Iniciar Stream de Alta Precisão (20 segundos)
    try {
      final stream = widget.servicoLocalizacao.obterStreamPosicoes();
      _posicaoSubscription = stream.listen(
        _aoReceberPosicao,
        onError: (erro) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro na coleta de localização: $erro'),
              backgroundColor: Colors.red[800],
            ),
          );
          _pararColeta();
        },
      );

      setState(() {
        _coletando = true;
        _statusMensagem = 'Coleta ativa (intervalo: 20s).';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coleta iniciada com sucesso.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _statusMensagem = 'Falha ao iniciar: $e');
    }
  }

  Future<void> _aoReceberPosicao(Position position) async {
    // Evita gravações sobrepostas
    if (_gravando) return;
    _gravando = true;

    try {
      final novaLocalizacao = Localizacao(
        latitude: position.latitude,
        longitude: position.longitude,
        precisao: position.accuracy,
        instante: position.timestamp,
      );

      await widget.repositorioLocalizacoes.inserir(novaLocalizacao);

      if (mounted) {
        setState(() {
          _pontosColetadosSessao++;
          _statusMensagem =
              'Última posição salva: ${novaLocalizacao.latitudeFormatada}, ${novaLocalizacao.longitudeFormatada}';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha ao salvar localização no banco: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _gravando = false;
    }
  }

  void _pararColeta() {
    if (!_coletando && _posicaoSubscription == null) return;

    _posicaoSubscription?.cancel();
    _posicaoSubscription = null;

    setState(() {
      _coletando = false;
      _statusMensagem = 'Coleta interrompida.';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coleta interrompida.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _abrirConfiguracoes() async {
    await widget.servicoLocalizacao.abrirConfiguracoes();
  }

  void _exibirDialogo({
    required String titulo,
    required String mensagem,
    required bool exibirBotaoConfiguracoes,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          if (exibirBotaoConfiguracoes)
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _abrirConfiguracoes();
              },
              child: const Text('Abrir Configurações'),
            ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coleta de Localizações'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card de status da coleta
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        _coletando ? Icons.gps_fixed : Icons.gps_not_fixed,
                        size: 64,
                        color: _coletando ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _coletando ? 'COLETA EM ANDAMENTO' : 'COLETA PARADA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              _coletando ? Colors.green[800] : Colors.grey[700],
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _statusMensagem ??
                            'Pressione Iniciar coleta para começar.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87),
                      ),
                      if (_coletando) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Pontos salvos nesta sessão: $_pontosColetadosSessao',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Botão: Iniciar coleta
              ElevatedButton.icon(
                onPressed: !_coletando ? _iniciarColeta : null,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Iniciar coleta',
                    style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Botão: Parar coleta
              ElevatedButton.icon(
                onPressed: _coletando ? _pararColeta : null,
                icon: const Icon(Icons.stop_rounded),
                label:
                    const Text('Parar coleta', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Botão: Consultar histórico
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TelaLocalizacoes(
                        repositorio: widget.repositorioLocalizacoes,
                        isColetandoAtiva: () => _coletando,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.history_rounded),
                label: const Text('Consultar histórico',
                    style: TextStyle(fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Botão: Ver mapa
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TelaMapa(
                        repositorio: widget.repositorioLocalizacoes,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.map_rounded),
                label: const Text('Ver mapa', style: TextStyle(fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Botão: Configurações de permissão
              TextButton.icon(
                onPressed: _abrirConfiguracoes,
                icon: const Icon(Icons.settings_rounded),
                label: const Text('Configurações de permissão'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
