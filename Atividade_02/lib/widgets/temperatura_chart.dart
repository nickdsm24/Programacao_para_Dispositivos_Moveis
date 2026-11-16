import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/previsao_dia.dart';
import '../utils/condicoes_tempo.dart';

class TemperaturaChart extends StatelessWidget {
  final List<PrevisaoDia> dias;

  const TemperaturaChart({super.key, required this.dias});

  @override
  Widget build(BuildContext context) {
    final maxSpots = <FlSpot>[];
    final minSpots = <FlSpot>[];
    final todasTemperaturas = <double>[];

    for (var i = 0; i < dias.length; i++) {
      final dia = dias[i];
      if (dia.maxima != null) {
        maxSpots.add(FlSpot(i.toDouble(), dia.maxima!));
        todasTemperaturas.add(dia.maxima!);
      }
      if (dia.minima != null) {
        minSpots.add(FlSpot(i.toDouble(), dia.minima!));
        todasTemperaturas.add(dia.minima!);
      }
    }

    if (todasTemperaturas.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('Dados de temperatura indisponíveis para o gráfico.'),
          ),
        ),
      );
    }

    final menorTemp = todasTemperaturas.reduce(math.min);
    final maiorTemp = todasTemperaturas.reduce(math.max);
    final minY = (menorTemp - 3).floorToDouble();
    final maxY = (maiorTemp + 3).ceilToDouble();

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Variação de Temperatura (°C)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Row(
                  children: [
                    _LegendaItem(cor: Color(0xFFE65100), label: 'Máx'),
                    SizedBox(width: 12),
                    _LegendaItem(cor: Color(0xFF1565C0), label: 'Mín'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: math.max(1, dias.length - 1).toDouble(),
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: math.max(2, ((maxY - minY) / 4).roundToDouble()),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 38,
                        interval: math.max(2, ((maxY - minY) / 4).roundToDouble()),
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}°',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= dias.length || value != idx.toDouble()) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              formatarDataCurta(dias[idx].dia),
                              style: const TextStyle(fontSize: 11),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final isMax = spot.barIndex == 0 && maxSpots.isNotEmpty;
                          final prefixo = isMax ? 'Máx' : 'Mín';
                          return LineTooltipItem(
                            '$prefixo: ${spot.y.toStringAsFixed(0)}°C',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    if (maxSpots.isNotEmpty)
                      LineChartBarData(
                        spots: maxSpots,
                        isCurved: true,
                        color: const Color(0xFFE65100),
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color(0xFFE65100).withValues(alpha: 0.08),
                        ),
                      ),
                    if (minSpots.isNotEmpty)
                      LineChartBarData(
                        spots: minSpots,
                        isCurved: true,
                        color: const Color(0xFF1565C0),
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color(0xFF1565C0).withValues(alpha: 0.08),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendaItem extends StatelessWidget {
  final Color cor;
  final String label;

  const _LegendaItem({required this.cor, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
