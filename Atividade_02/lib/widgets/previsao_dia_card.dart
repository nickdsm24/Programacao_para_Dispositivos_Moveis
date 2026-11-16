import 'package:flutter/material.dart';

import '../models/previsao_dia.dart';
import '../utils/condicoes_tempo.dart';

class PrevisaoDiaCard extends StatelessWidget {
  final PrevisaoDia previsao;

  const PrevisaoDiaCard({super.key, required this.previsao});

  @override
  Widget build(BuildContext context) {
    final condicao = obterCondicaoTempo(previsao.tempoSigla);
    final diaSemana = obterDiaSemana(previsao.dia);
    final dataFormatada = formatarDataBr(previsao.dia);

    final minTexto = previsao.minima != null
        ? '${previsao.minima!.toStringAsFixed(0)}°C'
        : '--';
    final maxTexto = previsao.maxima != null
        ? '${previsao.maxima!.toStringAsFixed(0)}°C'
        : '--';

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: condicao.cor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                condicao.icone,
                color: condicao.cor,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    diaSemana.isNotEmpty
                        ? '$diaSemana • $dataFormatada'
                        : dataFormatada,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    condicao.descricao,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                  ),
                  if (previsao.iuv != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.wb_sunny_outlined,
                          size: 14,
                          color: Colors.amber.shade800,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'IUV: ${previsao.iuv!.toStringAsFixed(1)} (${classificarIuv(previsao.iuv!)})',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.amber.shade900,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.arrow_upward,
                      size: 14,
                      color: Color(0xFFE65100),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      maxTexto,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE65100),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.arrow_downward,
                      size: 14,
                      color: Color(0xFF1565C0),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      minTexto,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
