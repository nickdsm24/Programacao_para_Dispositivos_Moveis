import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/localizacao.dart';

/// Widget reutilizável para apresentar os dados formatados de uma localização.
/// Utilizado tanto na lista de histórico quanto em detalhes/bottom sheet do mapa.
class ItemLocalizacao extends StatelessWidget {
  final Localizacao localizacao;
  final bool isMaisRecente;

  const ItemLocalizacao({
    super.key,
    required this.localizacao,
    this.isMaisRecente = false,
  });

  @override
  Widget build(BuildContext context) {
    final formatadorDataHora = DateFormat('dd/MM/yyyy HH:mm:ss');
    final dataHoraFormatada = formatadorDataHora.format(localizacao.instante);

    return Card(
      elevation: isMaisRecente ? 3 : 1,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isMaisRecente
            ? const BorderSide(color: Colors.redAccent, width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 18,
                      color:
                          isMaisRecente ? Colors.redAccent : Colors.grey[700],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dataHoraFormatada,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isMaisRecente
                            ? Colors.redAccent[700]
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
                if (isMaisRecente)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Mais recente',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  )
                else if (localizacao.id != null)
                  Text(
                    '#${localizacao.id}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
            const Divider(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Latitude:',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        localizacao.latitudeFormatada,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Longitude:',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        localizacao.longitudeFormatada,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.gps_fixed_rounded,
                    size: 16, color: Colors.blueGrey[600]),
                const SizedBox(width: 6),
                Text(
                  'Precisão estimada: ',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                Text(
                  localizacao.precisaoFormatada,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
