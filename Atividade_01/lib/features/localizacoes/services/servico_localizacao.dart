import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Serviço responsável por verificar GPS, gerenciar permissões e fornecer o stream de localização.
class ServicoLocalizacao {
  /// Verifica se o serviço de localização (GPS) está ativado no dispositivo.
  Future<bool> isServicoHabilitado() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Verifica o status atual da permissão de localização.
  Future<LocationPermission> verificarPermissao() async {
    return await Geolocator.checkPermission();
  }

  /// Solicita ao usuário a permissão de localização.
  Future<LocationPermission> solicitarPermissao() async {
    return await Geolocator.requestPermission();
  }

  /// Abre as configurações do sistema para o usuário alterar permissões manualmente.
  Future<bool> abrirConfiguracoes() async {
    return await Geolocator.openAppSettings();
  }

  /// Fornece o stream de posições com alta precisão e intervalo de 20 segundos.
  /// No Android, ativa o serviço em primeiro plano com notificação visível.
  Stream<Position> obterStreamPosicoes() {
    LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        intervalDuration: const Duration(seconds: 20),
        distanceFilter: 0,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Coleta de Localizações Ativa',
          notificationText: 'Gravando posições continuamente em segundo plano.',
          notificationIcon: AndroidResource(
            name: 'icone_localizacoes',
            defType: 'drawable',
          ),
          enableWakeLock: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      );
    }

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }
}
