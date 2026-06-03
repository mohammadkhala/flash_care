import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/json_utils.dart';
import '../../../../core/l10n/s.dart';

String _resolveUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  return url.replaceAll('localhost', '192.168.1.10')
            .replaceAll('127.0.0.1', '192.168.1.10');
}

class TherapistListPage extends StatefulWidget {
  const TherapistListPage({super.key});

  @override
  State<TherapistListPage> createState() => _TherapistListPageState();
}

class _TherapistListPageState extends State<TherapistListPage> {
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _therapists = [];
  List<Map<String, dynamic>> _specializations = [];
  bool _loading = true;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _loadingMore = false;
  final _scroll = ScrollController();

  int? _selectedSpec;
  String? _selectedGender;
  String? _selectedType; // online / in_person
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadSpecializations();
    _loadTherapists(reset: true);
    _scroll.addListener(_onScroll);
    _searchCtrl.addListener(() {
      final v = _searchCtrl.text.trim();
      if (v != _search) {
        _search = v;
        _debounceSearch();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200
        && !_loadingMore && _hasMore) {
      _loadTherapists();
    }
  }

  Future<void> _loadSpecializations() async {
    try {
      final res = await ApiClient.instance.get('/specializations');
      if (!mounted) return;
      final list = (res.data as List?) ?? [];
      setState(() => _specializations = list.cast<Map<String, dynamic>>());
    } catch (_) {}
  }

  Future<void> _loadTherapists({bool reset = false}) async {
    if (reset) {
      setState(() { _loading = true; _currentPage = 1; _hasMore = true; _therapists = []; });
    } else {
      if (_loadingMore || !_hasMore) return;
      setState(() => _loadingMore = true);
    }
    try {
      final params = <String, dynamic>{
        'page': reset ? 1 : _currentPage,
        'per_page': 15,
        if (_search.isNotEmpty) 'search': _search,
        if (_selectedSpec != null) 'specialization_id': _selectedSpec,
        if (_selectedGender != null) 'gender': _selectedGender,
        if (_selectedType == 'online') 'accepts_online': 1,
        if (_selectedType == 'in_person') 'accepts_in_person': 1,
      };
      final res = await ApiClient.instance.get('/therapists', queryParameters: params);
      if (!mounted) return;
      final list = ((res.data['data'] ?? res.data) as List?)?.cast<Map<String, dynamic>>() ?? [];
      final meta = res.data['meta'] as Map<String, dynamic>?;
      final lastPage = jsonInt(meta?['last_page'], 1);
      setState(() {
        if (reset) {
          _therapists = list;
          _currentPage = 2;
        } else {
          _therapists.addAll(list);
          _currentPage++;
        }
        _hasMore = (reset ? 1 : _currentPage - 1) < lastPage;
        _loading = false;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _loadingMore = false; });
    }
  }

  void _debounceSearch() => Future.delayed(
    const Duration(milliseconds: 400), () {
      if (_search == _searchCtrl.text.trim()) _loadTherapists(reset: true);
    });

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _FiltersSheet(
        specializations: _specializations,
        selectedSpec: _selectedSpec,
        selectedGender: _selectedGender,
        selectedType: _selectedType,
        onApply: (spec, gender, type) {
          setState(() {
            _selectedSpec = spec;
            _selectedGender = gender;
            _selectedType = type;
          });
          _loadTherapists(reset: true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      title: Text(S.therapists),
      backgroundColor: AppColors.surface,
      actions: [
        IconButton(
          icon: const Icon(Icons.map_rounded),
          tooltip: S.mapLabel,
          onPressed: () => context.push('/map'),
        ),
        IconButton(
          icon: const Icon(Icons.tune_rounded),
          onPressed: _showFilters),
      ],
    ),
    body: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: TextField(
          controller: _searchCtrl,
          decoration: InputDecoration(
            hintText: S.searchHint,
            prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
          ),
        ),
      ),
      if (_selectedSpec != null || _selectedGender != null || _selectedType != null)
        _buildActiveFilters(),
      Expanded(child: _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () => _loadTherapists(reset: true),
            child: _therapists.isEmpty
              ? Center(child: Text(S.noTherapists,
                  style: const TextStyle(color: AppColors.textSecondary)))
              : ListView.separated(
                  controller: _scroll,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _therapists.length + (_loadingMore ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    if (i == _therapists.length) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator()));
                    }
                    return _TherapistListCard(therapist: _therapists[i]);
                  },
                ),
          )),
    ]),
  );

  Widget _buildActiveFilters() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
    child: Wrap(spacing: 8, children: [
      if (_selectedSpec != null) _FilterChip(
        label: _specializations.firstWhere(
          (s) => s['id'] == _selectedSpec,
          orElse: () => {'name_ar': 'تخصص'},
        )['name_ar'] as String? ?? 'تخصص',
        onRemove: () { setState(() => _selectedSpec = null); _loadTherapists(reset: true); },
      ),
      if (_selectedGender != null) _FilterChip(
        label: _selectedGender == 'male' ? S.male : S.female,
        onRemove: () { setState(() => _selectedGender = null); _loadTherapists(reset: true); },
      ),
      if (_selectedType != null) _FilterChip(
        label: _selectedType == 'online' ? S.online : S.inPerson,
        onRemove: () { setState(() => _selectedType = null); _loadTherapists(reset: true); },
      ),
    ]),
  );
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) => Chip(
    label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    backgroundColor: AppColors.primary.withOpacity(0.1),
    labelStyle: const TextStyle(color: AppColors.primary),
    deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.primary),
    onDeleted: onRemove,
    padding: EdgeInsets.zero,
    side: BorderSide.none,
  );
}

class _TherapistListCard extends StatelessWidget {
  final Map<String, dynamic> therapist;
  const _TherapistListCard({required this.therapist});

  @override
  Widget build(BuildContext context) {
    final id = therapist['id'];
    final avatar = _resolveUrl(therapist['avatar'] as String?);
    final rating = jsonDouble(therapist['rating_average']);
    final ratingCount = jsonInt(therapist['rating_count']);
    final specs = (therapist['specializations'] as List?) ?? [];
    final price = therapist['online_session_price'] ?? therapist['in_person_session_price'];
    return GestureDetector(
      onTap: () => context.push('/therapists/$id'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.surfaceAlt,
            backgroundImage: avatar.isNotEmpty ? CachedNetworkImageProvider(avatar) : null,
            child: avatar.isEmpty
              ? const Icon(Icons.person, size: 30, color: AppColors.textHint) : null,
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(therapist['full_name'] as String? ?? '',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15,
                color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(therapist['title'] as String? ?? '',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            if (specs.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(spacing: 4, children: specs.take(2).map((s) {
                final name = (s as Map)['name_ar'] as String? ?? '';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(name,
                    style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
                );
              }).toList()),
            ],
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.star_rounded, color: AppColors.warning, size: 14),
              const SizedBox(width: 3),
              Text('${'${rating.toStringAsFixed(1)}'} ($ratingCount)',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
              const SizedBox(width: 10),
              if (therapist['city'] != null) ...[
                const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
                Text(therapist['city'] as String? ?? '',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ]),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            if (price != null) ...[
              Text('$price ₪', style: const TextStyle(
                fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primary)),
              Text(S.perSession, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            ],
            const SizedBox(height: 8),
            const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.textHint),
          ]),
        ]),
      ),
    );
  }
}

class _FiltersSheet extends StatefulWidget {
  final List<Map<String, dynamic>> specializations;
  final int? selectedSpec;
  final String? selectedGender;
  final String? selectedType;
  final Function(int?, String?, String?) onApply;

  const _FiltersSheet({
    required this.specializations,
    required this.selectedSpec,
    required this.selectedGender,
    required this.selectedType,
    required this.onApply,
  });

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  int? _spec;
  String? _gender;
  String? _type;

  @override
  void initState() {
    super.initState();
    _spec = widget.selectedSpec;
    _gender = widget.selectedGender;
    _type = widget.selectedType;
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(20, 20, 20,
        MediaQuery.of(context).viewInsets.bottom + 20),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(S.filterResults,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 20),
      Text(S.specialization, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        GestureDetector(
          onTap: () => setState(() => _spec = null),
          child: _chip(S.all, _spec == null)),
        ...widget.specializations.map((s) {
          final id = s['id'] as int?;
          final name = s['name_ar'] as String? ?? '';
          return GestureDetector(
            onTap: () => setState(() => _spec = id),
            child: _chip(name, _spec == id));
        }),
      ]),
      const SizedBox(height: 16),
      Text(S.genderLabel, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, children: [
        GestureDetector(onTap: () => setState(() => _gender = null), child: _chip(S.all, _gender == null)),
        GestureDetector(onTap: () => setState(() => _gender = 'male'), child: _chip(S.male, _gender == 'male')),
        GestureDetector(onTap: () => setState(() => _gender = 'female'), child: _chip(S.female, _gender == 'female')),
      ]),
      const SizedBox(height: 16),
      Text(S.sessionType, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, children: [
        GestureDetector(onTap: () => setState(() => _type = null), child: _chip(S.all, _type == null)),
        GestureDetector(onTap: () => setState(() => _type = 'online'), child: _chip(S.online, _type == 'online')),
        GestureDetector(onTap: () => setState(() => _type = 'in_person'), child: _chip(S.inPerson, _type == 'in_person')),
      ]),
      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: () { Navigator.pop(context); widget.onApply(_spec, _gender, _type); },
        child: Text(S.applyFilter),
      ),
    ]),
  );

  Widget _chip(String label, bool selected) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: selected ? AppColors.primary : AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: selected ? AppColors.primary : AppColors.border),
    ),
    child: Text(label, style: TextStyle(
      fontSize: 13, fontWeight: FontWeight.w600,
      color: selected ? Colors.white : AppColors.textSecondary)),
  );
}
