import 'package:flutter/material.dart';

import '../models/cidade.dart';
import '../models/previsao_cidade.dart';
import '../services/cptec_service.dart';
import '../services/storage_service.dart';
import '../utils/condicoes_tempo.dart';
import '../widgets/previsao_dia_card.dart';
import '../widgets/temperatura_chart.dart';
import 'busca_cidade_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CptecService _cptecService = CptecService();
  final StorageService _storageService = StorageService();

  Cidade? _cidadeAtual;
  PrevisaoCidade? _previsao;
  bool _carregando = false;
  bool _usandoCache = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    final ultimaCidade = await _storageService.carregarUltimaCidade();
    if (!mounted) return;

    if (ultimaCidade == null) {
      return;
    }

    setState(() => _cidadeAtual = ultimaCidade);

    final cache = await _storageService.carregarPrevisaoCache(ultimaCidade.id);
    if (mounted && cache != null) {
      setState(() {
        _previsao = cache;
        _usandoCache = true;
      });
    }

    await _carregarPrevisao(ultimaCidade);
  }

  Future<void> _carregarPrevisao(Cidade cidade) async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final novaPrevisao = await _cptecService.buscarPrevisao(cidade.id);
      await _storageService.salvarPrevisaoCache(cidade.id, novaPrevisao);

      if (!mounted) return;
      setState(() {
        _previsao = novaPrevisao;
        _usandoCache = false;
        _carregando = false;
      });
    } on CptecException catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.mensagem;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Erro inesperado ao buscar a previsão do tempo.';
        _carregando = false;
      });
    }
  }

  Future<void> _abrirBuscaCidade() async {
    final cidadeSelecionada = await Navigator.of(context).push<Cidade>(
      MaterialPageRoute(
        builder: (_) => BuscaCidadeScreen(
          cptecService: _cptecService,
          storageService: _storageService,
        ),
      ),
    );

    if (cidadeSelecionada == null || !mounted) return;

    setState(() {
      _cidadeAtual = cidadeSelecionada;
      _previsao = null;
      _usandoCache = false;
      _erro = null;
    });

    final cache =
        await _storageService.carregarPrevisaoCache(cidadeSelecionada.id);
    if (mounted && cache != null) {
      setState(() {
        _previsao = cache;
        _usandoCache = true;
      });
    }

    await _carregarPrevisao(cidadeSelecionada);
  }

  @override
  Widget build(BuildContext context) {
    final titulo = _cidadeAtual != null
        ? '${_cidadeAtual!.nome} - ${_cidadeAtual!.uf}'
        : 'Previsão do Tempo';

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        actions: [
          if (_cidadeAtual != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Atualizar previsão',
              onPressed:
                  _carregando ? null : () => _carregarPrevisao(_cidadeAtual!),
            ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Pesquisar cidade',
            onPressed: _abrirBuscaCidade,
          ),
        ],
      ),
      body: _construirCorpo(),
    );
  }

  Widget _construirCorpo() {
    if (_cidadeAtual == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_outlined,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Consulte a previsão do tempo',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Pesquise uma cidade brasileira para visualizar a previsão para 4 dias e o gráfico de temperaturas.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _abrirBuscaCidade,
                icon: const Icon(Icons.search),
                label: const Text('Pesquisar cidade'),
              ),
              const SizedBox(height: 32),
              Text(
                'Fonte: CPTEC/INPE',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    if (_carregando && _previsao == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Carregando previsão do tempo...'),
          ],
        ),
      );
    }

    if (_erro != null && _previsao == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 56, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(
                _erro!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _carregarPrevisao(_cidadeAtual!),
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _abrirBuscaCidade,
                child: const Text('Escolher outra cidade'),
              ),
            ],
          ),
        ),
      );
    }

    final previsao = _previsao!;

    return RefreshIndicator(
      onRefresh: () => _carregarPrevisao(_cidadeAtual!),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_carregando) const LinearProgressIndicator(),
          if (_erro != null && _previsao != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade400),
              ),
              child: Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.amber.shade900),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$_erro Exibindo dados salvos localmente.',
                      style: TextStyle(
                        color: Colors.amber.shade900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_usandoCache && _erro == null && !_carregando)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Dados em cache local',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          Card(
            elevation: 0,
            color: Theme.of(context)
                .colorScheme
                .primaryContainer
                .withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${previsao.nome.isNotEmpty ? previsao.nome : _cidadeAtual!.nome} - ${previsao.uf}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Atualizado pelo serviço em: ${formatarDataBr(previsao.atualizacao)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          TemperaturaChart(dias: previsao.dias),
          const SizedBox(height: 18),
          Text(
            'Previsão para ${previsao.dias.length} dias',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 10),
          ...previsao.dias.map((dia) => PrevisaoDiaCard(previsao: dia)),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Dados meteorológicos fornecidos pelo CPTEC/INPE',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
