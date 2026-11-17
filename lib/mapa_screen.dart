import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'supabase_client.dart';

const _teresinaCenter = LatLng(-5.0892, -42.8019);

const _clinicAreas = [
  (name: 'Centro', point: LatLng(-5.0892, -42.8019)),
  (name: 'Frei Serafim', point: LatLng(-5.0823, -42.7981)),
  (name: 'Jóquei', point: LatLng(-5.0777, -42.7878)),
  (name: 'Ininga', point: LatLng(-5.0598, -42.7871)),
  (name: 'São Cristóvão', point: LatLng(-5.0758, -42.7738)),
  (name: 'Matinha', point: LatLng(-5.0797, -42.8171)),
  (name: 'Noivos', point: LatLng(-5.0858, -42.7851)),
  (name: 'Ilhotas', point: LatLng(-5.0969, -42.7981)),
];

class _ClinicLocation {
  const _ClinicLocation({
    required this.name,
    required this.neighborhood,
    required this.point,
  });

  final String name;
  final String neighborhood;
  final LatLng point;
}

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final MapController _mapController = MapController();
  late Future<List<_ClinicLocation>> _clinics;
  Position? _position;
  _ClinicLocation? _selectedClinic;
  String? _locationMessage;
  bool _isLocating = false;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _clinics = _loadClinics();
    _updateLocation();
  }

  Future<List<_ClinicLocation>> _loadClinics() async {
    final rows = await supabase.from('clinicas').select('nome').limit(2000);
    return [
      for (var index = 0; index < rows.length; index++)
        _ClinicLocation(
          name: rows[index]['nome'] as String? ?? 'Clínica',
          neighborhood: _clinicAreas[index % _clinicAreas.length].name,
          point: _clinicAreas[index % _clinicAreas.length].point,
        ),
    ];
  }

  Future<void> _updateLocation() async {
    setState(() {
      _isLocating = true;
      _locationMessage = null;
    });

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        setState(() {
          _locationMessage =
              'Ative a localização do celular para ver sua posição.';
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _locationMessage = permission == LocationPermission.deniedForever
              ? 'Permita a localização nas configurações do celular.'
              : 'Permissão de localização não concedida.';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() => _position = position);
      if (_mapReady) _centerOnLocation(position);
    } catch (error) {
      if (mounted) {
        setState(
          () => _locationMessage =
              'Não foi possível obter sua localização: $error',
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _centerOnClinics() {
    _mapController.move(_teresinaCenter, 13);
  }

  void _centerOnLocation(Position position) {
    _mapController.move(LatLng(position.latitude, position.longitude), 13);
  }

  double? _distanceTo(_ClinicLocation clinic) {
    final position = _position;
    if (position == null) return null;
    return Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      clinic.point.latitude,
      clinic.point.longitude,
    );
  }

  String _distanceLabel(_ClinicLocation clinic) {
    final meters = _distanceTo(clinic);
    if (meters == null) return 'Ative a localização para ver a distância.';
    if (meters < 1000) {
      return 'A ${meters.round()} m de você (aprox.)';
    }
    return 'A ${(meters / 1000).toStringAsFixed(1).replaceAll('.', ',')} km de você (aprox.)';
  }

  void _showClinicList(BuildContext context, List<_ClinicLocation> clinics) {
    final orderedClinics = [...clinics]
      ..sort((first, second) {
        final firstDistance = _distanceTo(first);
        final secondDistance = _distanceTo(second);
        if (firstDistance == null || secondDistance == null) return 0;
        return firstDistance.compareTo(secondDistance);
      });

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.65,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  'Clínicas e distâncias',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: orderedClinics.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final clinic = orderedClinics[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.location_on,
                        color: Color(0xFF2743BA),
                      ),
                      title: Text(clinic.name),
                      subtitle: Text(
                        '${clinic.neighborhood}, Teresina - PI · localização fictícia\n'
                        '${_distanceLabel(clinic)}',
                      ),
                      isThreeLine: true,
                      onTap: () {
                        setState(() => _selectedClinic = clinic);
                        _mapController.move(clinic.point, 15);
                        Navigator.of(sheetContext).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Mapa de clínicas'),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<List<_ClinicLocation>>(
        future: _clinics,
        builder: (context, snapshot) {
          final clinics = snapshot.data ?? const <_ClinicLocation>[];
          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _teresinaCenter,
                  initialZoom: 13,
                  minZoom: 4,
                  maxZoom: 18,
                  onMapReady: () {
                    _mapReady = true;
                    if (_position case final position?) {
                      _centerOnLocation(position);
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.aplicativo_clinica',
                  ),
                  MarkerLayer(
                    markers: [
                      for (final clinic in clinics)
                        Marker(
                          point: clinic.point,
                          width: 48,
                          height: 56,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedClinic = clinic),
                            child: const Icon(
                              Icons.location_on,
                              color: Color(0xFF2743BA),
                              size: 44,
                            ),
                          ),
                        ),
                      if (_position case final position?)
                        Marker(
                          point: LatLng(position.latitude, position.longitude),
                          width: 44,
                          height: 44,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1687E8),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 8),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('OpenStreetMap contributors'),
                    ],
                  ),
                ],
              ),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(14),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Carregando clínicas...'),
                        ],
                      ),
                    ),
                  ),
                ),
              if (snapshot.hasError)
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Não foi possível carregar as clínicas: ${snapshot.error}',
                          ),
                          TextButton(
                            onPressed: () =>
                                setState(() => _clinics = _loadClinics()),
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_locationMessage != null)
                Positioned(
                  top:
                      snapshot.hasError ||
                          snapshot.connectionState == ConnectionState.waiting
                      ? 88
                      : 12,
                  left: 12,
                  right: 12,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(_locationMessage!),
                    ),
                  ),
                ),
              Positioned(
                right: 16,
                bottom: _selectedClinic == null ? 92 : 176,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'center_clinics',
                      tooltip: 'Ver clínicas em Teresina',
                      onPressed: _centerOnClinics,
                      child: const Icon(Icons.medical_services_outlined),
                    ),
                    const SizedBox(height: 10),
                    FloatingActionButton.small(
                      heroTag: 'center_location',
                      tooltip: 'Usar minha localização',
                      onPressed: _isLocating ? null : _updateLocation,
                      child: _isLocating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: _selectedClinic == null
                    ? Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  snapshot.hasData && clinics.isEmpty
                                      ? 'Nenhuma clínica cadastrada para exibir.'
                                      : 'Localizações fictícias em Teresina - PI.',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (clinics.isNotEmpty)
                                TextButton.icon(
                                  onPressed: () =>
                                      _showClinicList(context, clinics),
                                  icon: const Icon(Icons.list_alt),
                                  label: const Text('Distâncias'),
                                ),
                            ],
                          ),
                        ),
                      )
                    : Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Color(0xFF2743BA),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _selectedClinic!.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      '${_selectedClinic!.neighborhood}, Teresina - PI · localização fictícia',
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _distanceLabel(_selectedClinic!),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2743BA),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Fechar',
                                onPressed: () =>
                                    setState(() => _selectedClinic = null),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
