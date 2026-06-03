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

class _TherapistMapPageState extends State<TherapistMapPage>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  Position? _myPosition;
  List<Map<String, dynamic>> _therapists = [];
  Map<String, dynamic>? _selected;
  bool _loading = true;
  bool _locating = false;

  // Card animation
  late AnimationController _cardAnim;
  late Animation<Offset> _slideAnim;

  static const LatLng _palestineCenter = LatLng(31.9, 35.2);

  @override
  void initState() {
    super.initState();
    _cardAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardAnim, curve: Curves.easeOutCubic));
    _init();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _cardAnim.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await _getLocation();
    await _loadNearby();
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
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) {
          _showSnack('لم يتم منح صلاحية الموقع');
          setState(() { _locating = false; _loading = false; });
          return;
        }
      }
      if (perm == LocationPermission.deniedForever) {
        _showSnack('صلاحية الموقع محظورة — افتح الإعدادات');
        setState(() { _locating = false; _loading = false; });
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      setState(() { _myPosition = pos; _locating = false; });
    } catch (_) {
      setState(() { _locating = false; _loading = false; });
    }
  }

  Future<void> _loadNearby() async {
    setState(() => _loading = true);
    final lat = _myPosition?.latitude  ?? _palestineCenter.latitude;
    final lng = _myPosition?.longitude ?? _palestineCenter.longitude;
    try {
      final r = await ApiClient.instance.get('/therapists/nearby', queryParameters: {
        'lat': lat, 'lng': lng, 'radius': 50,
      });
      if (!mounted) return;
      setState(() {
        _therapists = (r.data as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
      _fitMap();
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _fitMap() {
    if (_mapController == null || _therapists.isEmpty) return;
    double minLat = _myPosition?.latitude  ?? _palestineCenter.latitude;
    double maxLat = minLat;
    double minLng = _myPosition?.longitude ?? _palestineCenter.longitude;
    double maxLng = minLng;

    for (final t in _therapists) {
      final lat = (t['latitude']  as num?)?.toDouble();
      final lng = (t['longitude'] as num?)?.toDouble();
      if (lat == null || lng == null) continue;
      minLat = math.min(minLat, lat);
      maxLat = math.max(maxLat, lat);
      minLng = math.min(minLng, lng);
      maxLng = math.max(maxLng, lng);
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - 0.02, minLng - 0.02),
          northeast: LatLng(maxLat + 0.02, maxLng + 0.02),
        ),
        60,
      ),
    );
  }

  void _selectTherapist(Map<String, dynamic> t) {
    setState(() => _selected = t);
    _cardAnim.forward(from: 0);
    // Animate camera to marker
    final lat = (t['latitude']  as num?)?.toDouble();
    final lng = (t['longitude'] as num?)?.toDouble();
    if (lat != null && lng != null) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat, lng), zoom: 15),
        ),
      );
    }
  }

  void _closeCard() {
    _cardAnim.reverse().then((_) {
      if (mounted) setState(() => _selected = null);
    });
  }

  void _goToMe() {
    if (_myPosition == null) { _getLocation(); return; }
    _mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(_myPosition!.latitude, _myPosition!.longitude),
      zoom: 14,
    )));
  }

  void _goToNearest() {
    if (_therapists.isEmpty) return;
    _selectTherapist(_therapists.first);
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.primary));
  }

  LatLng get _center => _myPosition != null
      ? LatLng(_myPosition!.latitude, _myPosition!.longitude)
      : _palestineCenter;

  Set<Marker> get _markers {
    final markers = <Marker>{};

    // My location
    if (_myPosition != null) {
      markers.add(Marker(
        markerId: const MarkerId('me'),
        position: LatLng(_myPosition!.latitude, _myPosition!.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'موقعي'),
      ));
    }

    // Therapists
    for (final t in _therapists) {
      final lat = (t['latitude']  as num?)?.toDouble();
      final lng = (t['longitude'] as num?)?.toDouble();
      if (lat == null || lng == null) continue;
      final id         = t['id'].toString();
      final isSelected = _selected?['id'] == t['id'];

      markers.add(Marker(
        markerId: MarkerId(id),
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isSelected ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueViolet,
        ),
        // No InfoWindow — the card below is the UI
        onTap: () {
          if (isSelected) {
            _closeCard();
          } else {
            _selectTherapist(t);
          }
        },
      ));
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final hasCard = _selected != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('الأخصائيون القريبون',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          if (_therapists.isNotEmpty)
            Text('${_therapists.length} أخصائي في نطاق 50 كم',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _init),
        ],
      ),
      body: Stack(children: [

        // ── Google Map ──────────────────────────────────────────────────
        GoogleMap(
          initialCameraPosition: CameraPosition(target: _center, zoom: 12),
          onMapCreated: (c) {
            _mapController = c;
            if (_therapists.isNotEmpty) _fitMap();
          },
          markers: _markers,
          myLocationEnabled: _myPosition != null,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          // Tap on map background → close card
          onTap: (_) { if (hasCard) _closeCard(); },
        ),

        // ── Loading overlay ─────────────────────────────────────────────
        if (_loading)
          Container(
            color: Colors.black26,
            child: const Center(
                child: CircularProgressIndicator(color: Colors.white)),
          ),

        // ── FABs ────────────────────────────────────────────────────────
        AnimatedPositioned(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          bottom: hasCard ? 260 : 24,
          right: 16,
          child: Column(children: [
            _Fab(
              tag: 'nearest',
              icon: Icons.near_me_rounded,
              tooltip: 'الأقرب',
              onTap: _goToNearest,
            ),
            const SizedBox(height: 8),
            _Fab(
              tag: 'me',
              icon: Icons.my_location_rounded,
              tooltip: 'موقعي',
              loading: _locating,
              onTap: _goToMe,
            ),
          ]),
        ),

        // ── Therapist Card (slide-up) ────────────────────────────────────
        if (_selected != null)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: SlideTransition(
              position: _slideAnim,
              child: _TherapistCard(
                therapist: _selected!,
                onClose: _closeCard,
                onView: () => context.push('/therapists/${_selected!['id']}'),
              ),
            ),
          ),
      ]),
    );
  }
}

// ── Small FAB ───────────────────────────────────────────────────────────────
class _Fab extends StatelessWidget {
  final String tag;
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool loading;
  const _Fab({
    required this.tag,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) => FloatingActionButton.small(
    heroTag: tag,
    backgroundColor: AppColors.surface,
    onPressed: onTap,
    tooltip: tooltip,
    elevation: 4,
    child: loading
        ? const SizedBox(width: 18, height: 18,
            child: CircularProgressIndicator(strokeWidth: 2))
        : Icon(icon, color: AppColors.primary),
  );
}

// ── Therapist Card ───────────────────────────────────────────────────────────
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
    final name     = therapist['full_name'] as String? ?? '';
    final rating   = (therapist['rating_average'] as num?)?.toStringAsFixed(1) ?? '0';
    final ratingN  = (therapist['rating_average'] as num?)?.toDouble() ?? 0.0;
    final distance = therapist['distance_km'];
    final online   = therapist['accepts_online']    as bool? ?? false;
    final inPerson = therapist['accepts_in_person'] as bool? ?? false;
    final city     = therapist['city']              as String?;
    final specs    = (therapist['specializations']  as List? ?? []).cast<String>();
    final initials = name.trim().isNotEmpty ? name.trim()[0] : '?';

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        // Tap anywhere on the card → go to profile
        onTap: onView,
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            // ── Drag handle ──────────────────────────────────────────
            const SizedBox(height: 10),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 4),

            // ── Header row ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Avatar
                Container(
                  width: 58, height: 58,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(initials,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 14),

                // Name + meta
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(children: [
                    // Stars
                    ...List.generate(5, (i) => Icon(
                      i < ratingN.floor()
                          ? Icons.star_rounded
                          : (i < ratingN ? Icons.star_half_rounded : Icons.star_outline_rounded),
                      size: 14,
                      color: Colors.amber,
                    )),
                    const SizedBox(width: 4),
                    Text(rating,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary)),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    if (distance != null) ...[
                      const Icon(Icons.place_rounded, size: 13, color: AppColors.textHint),
                      const SizedBox(width: 2),
                      Text('$distance كم',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(width: 8),
                    ],
                    if (city != null) ...[
                      const Icon(Icons.location_city_rounded, size: 13, color: AppColors.textHint),
                      const SizedBox(width: 2),
                      Flexible(child: Text(city,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis)),
                    ],
                  ]),
                ])),

                // Close button
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textHint),
                  onPressed: onClose,
                  splashRadius: 20,
                ),
              ]),
            ),

            // ── Specializations ──────────────────────────────────────
            if (specs.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 30,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: specs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(specs[i],
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],

            // ── Footer: type badges + CTA ────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(children: [
                if (inPerson) _TypeBadge(label: '🏥 حضوري', color: AppColors.primary),
                if (online) ...[
                  if (inPerson) const SizedBox(width: 8),
                  _TypeBadge(label: '🎥 أونلاين', color: AppColors.accent),
                ],
                const Spacer(),
                // CTA button
                ElevatedButton.icon(
                  onPressed: onView,
                  icon: const Icon(Icons.person_rounded, size: 16, color: Colors.white),
                  label: const Text('عرض الملف',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    elevation: 0,
                  ),
                ),
              ]),
            ),

            // ── Hint ────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app_rounded, size: 13, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text('اضغط على الكارد للانتقال للملف الشخصي',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Type Badge ───────────────────────────────────────────────────────────────
class _TypeBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _TypeBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(label,
        style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600)),
  );
}
