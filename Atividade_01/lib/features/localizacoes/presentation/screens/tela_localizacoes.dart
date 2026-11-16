import 'package:flutter/material.dart';
import '../../data/repositories/repositorio_localizacoes.dart';
import '../../models/localizacao.dart';
import '../widgets/item_localizacao.dart';

/// Tela responsável por listar o histórico de localizações e gerenciar a limpeza do banco.
class TelaLocalizacoes extends StatefulWidget {
  final RepositorioLocalizacoes repositorio;
  final bool Function() isColetandoAtiva;

  const TelaLocalizacoes({
    super.key,
    required this.repositorio,
    required this.isColetandoAtiva,
  });

  @override
  State<TelaLocalizacoes> createState() => _TelaLocalizacoesState();
}

class _TelaLocalizacoesState extends State<TelaLocalizacoes> {
  List<Localizacao> _listaLocalizacoes = [];
  bool _carregando = true;
  String? _mensagemErro;

  @override
  void initState() {
    super.initState();
    _carregarRegistros();
  }

  Future<void> _carregarRegistros() async {
    setState(() {
      _carregando = true;
      _mensagemErro = null;
    });

    try {
      final resultado = await widget.repositorio.consultarUltimas(limite: 100);
      if (!mounted) return;
      setState(() {
        _listaLocalizacoes = resultado;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _mensagemErro = 'Falha ao consultar localizações: $e';
        _carregando = false;
      });
    }
  }

  Future<void> _confirmarExclusao() async {
    final coletaAtiva = widget.isColetandoAtiva();

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpar histórico'),
        content: Text(
          'Esta operação é permanente e removerá todas as localizações gravadas no histórico.'
          '${coletaAtiva ? '\n\nAviso: A coleta está ativa no momento; novos registros continuarão sendo salvos normalmente.' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Limpar histórico'),
          ),
        ],
      ),
    );

    if (confirmou == true) {
      await _executarExclusao();
    }
  }

  Future<void> _executarExclusao() async {
    try {
      await widget.repositorio.excluirTodas();
      if (!mounted) return;

      await _carregarRegistros();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Histórico limpo com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao limpar histórico: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Localizações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar registros',
            onPressed: _carregarRegistros,
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Limpar histórico',
            onPressed: _listaLocalizacoes.isEmpty ? null : _confirmarExclusao,
          ),
        ],
      ),
      body: _construirCorpo(),
    );
  }

  Widget _construirCorpo() {
    if (_carregando) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando histórico...'),
          ],
        ),
      );
    }

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
                onPressed: _carregarRegistros,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_listaLocalizacoes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_off_rounded,
                  size: 64, color: Colors.grey[400]),
              const SizedBox(height: 12),
              const Text(
                'Nenhuma localização registrada.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                'Inicie a coleta na tela inicial para registrar posições.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey[200],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Exibindo as últimas ${_listaLocalizacoes.length} localizações',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Mais recente -> Mais antiga',
                style: TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _carregarRegistros,
            child: ListView.builder(
              itemCount: _listaLocalizacoes.length,
              itemBuilder: (context, index) {
                final loc = _listaLocalizacoes[index];
                return ItemLocalizacao(
                  localizacao: loc,
                  isMaisRecente: (index == 0),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
