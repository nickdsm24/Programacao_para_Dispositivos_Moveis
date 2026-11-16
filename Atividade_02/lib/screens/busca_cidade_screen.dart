import 'package:flutter/material.dart';

import '../models/cidade.dart';
import '../services/cptec_service.dart';
import '../services/storage_service.dart';

class BuscaCidadeScreen extends StatefulWidget {
  final CptecService cptecService;
  final StorageService storageService;

  const BuscaCidadeScreen({
    super.key,
    required this.cptecService,
    required this.storageService,
  });

  @override
  State<BuscaCidadeScreen> createState() => _BuscaCidadeScreenState();
}

class _BuscaCidadeScreenState extends State<BuscaCidadeScreen> {
  final TextEditingController _controller = TextEditingController();

  List<Cidade> _resultados = [];
  List<Cidade> _historico = [];
  bool _carregando = false;
  bool _pesquisaRealizada = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _carregarHistorico() async {
    final historico = await widget.storageService.carregarHistorico();
    if (!mounted) return;
    setState(() => _historico = historico);
  }

  Future<void> _buscar() async {
    final termo = _controller.text.trim();
    if (termo.length < 2) {
      setState(() {
        _erro = 'Digite pelo menos 2 caracteres para pesquisar.';
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _carregando = true;
      _erro = null;
      _pesquisaRealizada = true;
    });

    try {
      final cidades = await widget.cptecService.buscarCidades(termo);
      if (!mounted) return;
      setState(() {
        _resultados = cidades;
        _carregando = false;
      });
    } on CptecException catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.mensagem;
        _resultados = [];
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Ocorreu um erro inesperado ao consultar as cidades.';
        _resultados = [];
        _carregando = false;
      });
    }
  }

  Future<void> _selecionarCidade(Cidade cidade) async {
    await widget.storageService.salvarUltimaCidade(cidade);
    if (!mounted) return;
    Navigator.of(context).pop(cidade);
  }

  Future<void> _removerDoHistorico(Cidade cidade) async {
    await widget.storageService.removerDoHistorico(cidade.id);
    await _carregarHistorico();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesquisar Cidade'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _buscar(),
                    decoration: InputDecoration(
                      hintText: 'Ex.: São Paulo, Campinas, Curitiba...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _controller.clear();
                                setState(() {
                                  _resultados = [];
                                  _pesquisaRealizada = false;
                                  _erro = null;
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _carregando ? null : _buscar,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Buscar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _construirConteudo(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Fonte: CPTEC/INPE',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirConteudo() {
    if (_carregando) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Consultando localidades no CPTEC/INPE...'),
          ],
        ),
      );
    }

    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(
                _erro!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _buscar,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_pesquisaRealizada) {
      if (_resultados.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_off, size: 48, color: Colors.grey.shade500),
                const SizedBox(height: 12),
                const Text(
                  'Nenhuma cidade encontrada para a pesquisa informada.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.separated(
        itemCount: _resultados.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final cidade = _resultados[index];
          return ListTile(
            leading: const Icon(Icons.location_city),
            title: Text(cidade.nome),
            subtitle: Text('UF: ${cidade.uf} • Código: ${cidade.id}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _selecionarCidade(cidade),
          );
        },
      );
    }

    if (_historico.isNotEmpty) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              'Cidades consultadas recentemente',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          ..._historico.map(
            (cidade) => ListTile(
              leading: const Icon(Icons.history),
              title: Text('${cidade.nome} - ${cidade.uf}'),
              subtitle: Text('Código CPTEC: ${cidade.id}'),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 20),
                tooltip: 'Remover do histórico',
                onPressed: () => _removerDoHistorico(cidade),
              ),
              onTap: () => _selecionarCidade(cidade),
            ),
          ),
        ],
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Digite o nome de uma cidade brasileira para consultar a previsão do tempo.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
        ),
      ),
    );
  }
}
