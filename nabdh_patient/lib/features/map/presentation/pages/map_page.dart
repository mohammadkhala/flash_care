import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';

class TherapistMapPage extends StatefulWidget {
  const TherapistMapPage({super.key});

  @override
  State<TherapistMapPage> createState() => _TherapistMapPageState();
}

class _TherapistMapPageState extends State<TherapistMapPage> {
  GoogleMapController? _mapController;
  Position? _myPosition;
  List<Map<String, dynamic>> _therapists = [];
  Map<String, dynamic>? _selected;
  bool _loading = true;
  bool _locating = false;

  Set<Marker> get _markers {
    final Set<Marker> markers = {};

    // My location marker
    if (_myPosition != null) {
      markers.add(Marker(
        markerId: const MarkerId('me'),
        position: LatLng(_myPosition!.latitude, _myPosition!.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'موقعي'),
      ));
    }

    // Therapist markers
    for (final t in _therapists) {
      final lat = (t['latitude'] as num?)?.toDouble();
      final lng = (t['longitude'] as num?)?.toDouble();
      if (lat == null || lng == null) continue;

      markers.add(Marker(
        markerId: MarkerId('t_${t['id']}'),
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _selected?['id'] == t['id']
              ? BitmapDescriptor.hueGreen
              : BitmapDescriptor.hueRed,
        ),
        infoWindow: InfoWindow(
          title: t['full_name'] as String? ?? '',
          snippet: '⭐ ${t['rating_average']} • ${t['distance_km']} كم',
          onTap: () => setState(() => _selected = t),
        ),
        onTap: () => setState(() => _selected = t),
      ));
    }

    return markers;
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _getLocation();
    if (_myPosition != null) await _loadNearby();
  }

  Future<void> _getLocation() async {
    setState(() => _locating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack('خدمة الموقع غير مفعّلة');
        setState(() { _locating = false; _loading = false; });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnack('لم يتم منح صلاحية الموقع');
          setState(() { _locating = false; _loading = false; });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showSnack('صلاحية الموقع محظورة — افتح الإعدادات');
        setState(() { _locating = false; _loading = false; });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      setState(() { _myPosition = pos; _locating = false; });
    } catch (e) {
      _showSnack('تعذّر الحصول على الموقع');
      setState(() { _locating = false; _loading = false; });
    }
  }

  Future<void> _loadNearby() async {
    if (_myPosition == null) return;
    setState(() => _loading = true);
    try {
      final r = await ApiClient.instance.get('/therapists/nearby', queryParameters: {
        'lat': _myPosition!.latitude,
        'lng': _myPosition!.longitude,
        'radius': 50,
      });
      setState(() {
        _therapists = (r.data as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
      _fitMap();
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _fitMap() {
    if (_therapists.isEmpty || _myPosition == null || _mapController == null) return;

    double minLat = _myPosition!.latitude, maxLat = _myPosition!.latitude;
    double minLng = _myPosition!.longitude, maxLng = _myPosition!.longitude;

    for (final t in _therapists) {
      final lat = (t['latitude'] as num?)?.toDouble();
      final lng = (t['longitude'] as num?)?.toDouble();
      if (lat == null || lng == null) continue;
      minLat = math.min(minLat, lat);
      maxLat = math.max(maxLat, lat);
      minLng = math.min(minLng, lng);
      maxLng = math.max(maxLng, lng);
    }

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: LatLng(minLat - 0.01, minLng - 0.01),
        northeast: LatLng(maxLat + 0.01, maxLng + 0.01),
      ),
      60,
    ));
  }

  void _goToMe() {
    if (_myPosition == null) { _getLocation(); return; }
    _mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(_myPosition!.latitude, _myPosition!.longitude),
        zoom: 14,
      ),
    ));
  }

  void _goToNearest() {
    if (_therapists.isEmpty) return;
    final nearest = _therapists.first;
    final lat = (nearest['latitude'] as num?)?.toDouble();
    final lng = (nearest['longitude'] as num?)?.toDouble();
    if (lat == null || lng == null) return;
    setState(() => _selected = nearest);
    _mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(lat, lng), zoom: 15),
    ));
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.primary));
  }

  @override
  Widget build(BuildContext context) {
    final initialPos = _myPosition != null
        ? LatLng(_myPosition!.latitude, _myPosition!.longitude)
        : const LatLng(31.9, 35.2); // Palestine center

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('الأخصائيون القريبون',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          if (_therapists.isNotEmpty)
            Text('${_therapists.length} أخصائي في نطاق 50 كم',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _init,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: Stack(children: [
        // ── Google Map ─────────────────────────────────────────────────
        GoogleMap(
          onMapCreated: (c) {
            _mapController = c;
            if (_myPosition != null && _therapists.isNotEmpty) _fitMap();
          },
          initialCameraPosition: CameraPosition(target: initialPos, zoom: 12),
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapType: MapType.normal,
        ),

        // ── Loading overlay ────────────────────────────────────────────
        if (_loading)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator(color: Colors.white)),
          ),

        // ── FABs ───────────────────────────────────────────────────────
        Positioned(
          bottom: _selected != null ? 200 : 20,
          left: 16,
          child: Column(children: [
            FloatingActionButton.small(
              heroTag: 'nearest',
              backgroundColor: AppColors.surface,
              onPressed: _goToNearest,
              tooltip: 'الأقرب',
              child: const Icon(Icons.near_me_rounded, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            FloatingActionButton.small(
              heroTag: 'me',
              backgroundColor: AppColors.surface,
              onPressed: _goToMe,
              tooltip: 'موقعي',
              child: _locating
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location_rounded, color: AppColors.primary),
            ),
          ]),
        ),

        // ── Selected therapist card ────────────────────────────────────
        if (_selected != null)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _TherapistCard(
              therapist: _selected!,
              onClose: () => setState(() => _selected = null),
              onView: () => context.push(
                '/therapists/${_selected!['id']}',
              ),
            ),
          ),
      ]),
    );
  }
}

// ─── Therapist bottom card ───────────────────────────────────────────────────
class _TherapistCard extends StatelessWidget {
  final Map<String, dynamic> therapist;
  final VoidCallback onClose;
  final VoidCallback onView;

  const _TherapistCard({
    required this.therapist,
    required this.onClose,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final name       = therapist['full_name'] as String? ?? '';
    final rating     = (therapist['rating_average'] as num?)?.toStringAsFixed(1) ?? '0';
    final distance   = therapist['distance_km'];
    final online     = therapist['accepts_online'] as bool? ?? false;
    final inPerson   = therapist['accepts_in_person'] as bool? ?? false;
    final specs      = (therapist['specializations'] as List? ?? []).cast<String>();

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(name.isNotEmpty ? name[0] : '?',
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            Row(children: [
              const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
              const SizedBox(width: 3),
              Text(rating,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(width: 10),
              const Icon(Icons.place_rounded, size: 14, color: AppColors.textHint),
              const SizedBox(width: 3),
              Text('$distance كم',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ]),
          ])),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.textHint),
            onPressed: onClose,
          ),
        ]),
        if (specs.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 28,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: specs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(specs[i],
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Row(children: [
          if (inPerson)
            _TypeBadge(label: '🏥 حضوري', color: AppColors.primary),
          if (online) ...[
            if (inPerson) const SizedBox(width: 8),
            _TypeBadge(label: '🎥 أونلاين', color: AppColors.accent),
          ],
          const Spacer(),
          ElevatedButton(
            onPressed: onView,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: const Text('عرض الملف',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ]),
      ]),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _TypeBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
  );
}
