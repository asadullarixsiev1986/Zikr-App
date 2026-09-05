import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import '../l10n/app_strings.dart';
import '../widgets/glass_container.dart';
import '../widgets/islamic_scaffold.dart';

/// Координаты Каабы (Мекка), используются как точка назначения.
const double _kaabaLat = 21.4225;
const double _kaabaLng = 39.8262;

enum _LoadState { loading, noPermission, noService, ready, error }

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  _LoadState _state = _LoadState.loading;
  String? _errorMessage;
  double? _qiblaBearing; // азимут на Каабу от текущей точки (0-360, от севера)
  double? _distanceKm;
  StreamSubscription<CompassEvent>? _compassSub;
  double? _heading; // текущее направление устройства (0-360, от севера)
  bool _compassTimedOut = false; // датчик компаса не отозвался вовремя
  Timer? _compassTimeoutTimer;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() => _state = _LoadState.loading);

    // 1. Проверяем, включена ли служба геолокации на устройстве.
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _state = _LoadState.noService);
      return;
    }

    // 2. Проверяем и запрашиваем разрешение на геолокацию.
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() => _state = _LoadState.noPermission);
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      final bearing = _calculateQiblaBearing(position.latitude, position.longitude);
      final distance = _calculateDistanceKm(
          position.latitude, position.longitude, _kaabaLat, _kaabaLng);

      setState(() {
        _qiblaBearing = bearing;
        _distanceKm = distance;
        _state = _LoadState.ready;
      });

      if (FlutterCompass.events == null) {
        _compassTimedOut = true;
      } else {
        _compassSub = FlutterCompass.events?.listen((event) {
          if (mounted && event.heading != null) {
            _compassTimeoutTimer?.cancel();
            setState(() {
              _heading = event.heading;
              _compassTimedOut = false;
            });
          }
        });
        // Если за 2 секунды ни одного показания не пришло — считаем,
        // что на устройстве нет магнитометра, и переключаемся на
        // статичный азимут вместо "живой" стрелки.
        _compassTimeoutTimer = Timer(const Duration(seconds: 2), () {
          if (mounted && _heading == null) {
            setState(() => _compassTimedOut = true);
          }
        });
      }
    } catch (e) {
      setState(() {
        _state = _LoadState.error;
        _errorMessage = e.toString();
      });
    }
  }

  /// Азимут по дуге большого круга от точки (lat1, lng1) до Каабы.
  double _calculateQiblaBearing(double lat1, double lng1) {
    final phi1 = _deg2rad(lat1);
    final phi2 = _deg2rad(_kaabaLat);
    final deltaLambda = _deg2rad(_kaabaLng - lng1);

    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

    final theta = math.atan2(y, x);
    return (_rad2deg(theta) + 360) % 360;
  }

  double _calculateDistanceKm(
      double lat1, double lng1, double lat2, double lng2) {
    const earthRadiusKm = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLng = _deg2rad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) *
            math.cos(_deg2rad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _deg2rad(double deg) => deg * math.pi / 180;
  double _rad2deg(double rad) => rad * 180 / math.pi;

  String _t(String key) => AppLocale.instance.t(key);
  String _tp(String key, Map<String, Object> params) =>
      AppLocale.instance.tp(key, params);

  @override
  void dispose() {
    _compassSub?.cancel();
    _compassTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppLocale.instance,
      builder: (context, _) => IslamicScaffold(
        title: _t('qibla_title'),
        body: Center(child: _buildBody(context)),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_state) {
      case _LoadState.loading:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(_t('qibla_loading')),
          ],
        );

      case _LoadState.noService:
        return _buildMessage(
          icon: Icons.location_off,
          title: _t('qibla_no_service_title'),
          message: _t('qibla_no_service_message'),
          onRetry: _init,
        );

      case _LoadState.noPermission:
        return _buildMessage(
          icon: Icons.location_disabled,
          title: _t('qibla_no_permission_title'),
          message: _t('qibla_no_permission_message'),
          onRetry: _init,
        );

      case _LoadState.error:
        return _buildMessage(
          icon: Icons.error_outline,
          title: _t('qibla_error_title'),
          message: _errorMessage ?? _t('qibla_error_retry'),
          onRetry: _init,
        );

      case _LoadState.ready:
        return _buildCompass(context);
    }
  }

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String message,
    required VoidCallback onRetry,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(_t('retry_button')),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: Geolocator.openLocationSettings,
            child: Text(_t('open_location_settings')),
          ),
        ],
      ),
    );
  }

  Widget _buildCompass(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme.primary;
    final bearing = _qiblaBearing ?? 0;

    // Если есть живые показания компаса — стрелка показывает разницу
    // между направлением на Каабу и текущим направлением устройства.
    // Если компаса нет — показываем просто статичный азимут от севера.
    final rotation = _heading != null
        ? _deg2rad(bearing - _heading!)
        : _deg2rad(bearing);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_compassTimedOut)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              _t('qibla_no_sensor_warning'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        SizedBox(
          width: 270,
          height: 270,
          child: Stack(
            alignment: Alignment.center,
            children: [
              GlassContainer(
                borderRadius: 999,
                padding: EdgeInsets.zero,
                blurSigma: 16,
                child: const SizedBox(width: 260, height: 260),
              ),
              Positioned(top: 18, child: Text(_t('compass_n'), style: const TextStyle(fontWeight: FontWeight.bold))),
              Positioned(bottom: 18, child: Text(_t('compass_s'), style: const TextStyle(fontWeight: FontWeight.bold))),
              Positioned(left: 18, child: Text(_t('compass_w'), style: const TextStyle(fontWeight: FontWeight.bold))),
              Positioned(right: 18, child: Text(_t('compass_e'), style: const TextStyle(fontWeight: FontWeight.bold))),
              Transform.rotate(
                angle: rotation,
                child: Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: const Alignment(-0.3, -0.4),
                      colors: [
                        Colors.white.withValues(alpha: 0.7),
                        themeColor,
                      ],
                    ),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 1.4),
                    boxShadow: [
                      BoxShadow(
                        color: themeColor.withValues(alpha: 0.6),
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.navigation, size: 46, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GlassContainer(
          borderRadius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _tp('qibla_bearing_label', {'bearing': bearing.toStringAsFixed(1)}),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (_distanceKm != null) ...[
                const SizedBox(height: 4),
                Text(
                  _tp('qibla_distance_label', {'distance': _distanceKm!.toStringAsFixed(0)}),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            _heading != null
                ? _t('qibla_instruction_live')
                : _t('qibla_instruction_static'),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }
}
