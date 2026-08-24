import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../constants/app_colors.dart';

/// OpenStreetMap tap-to-select picker (no API key).
class OsmLocationPicker extends StatefulWidget {
  const OsmLocationPicker({
    super.key,
    this.initial,
    this.initialZoom = 13,
  });

  final LatLng? initial;
  final double initialZoom;

  /// Default center (Mogadishu) when no initial point.
  static const defaultCenter = LatLng(2.0469, 45.3182);

  static Future<LatLng?> show(BuildContext context, {LatLng? initial}) {
    return showModalBottomSheet<LatLng>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.78,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, scrollController) => OsmLocationPicker(
          initial: initial,
        ),
      ),
    );
  }

  @override
  State<OsmLocationPicker> createState() => _OsmLocationPickerState();
}

class _OsmLocationPickerState extends State<OsmLocationPicker> {
  late final MapController _mapController;
  LatLng? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
    _mapController = MapController();
  }

  void _onTap(TapPosition _, LatLng point) {
    setState(() => _selected = point);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.tortillaAlt,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Pick delivery location',
                    style: TextStyle(
                      color: AppColors.espresso,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppColors.espresso),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _selected == null
                  ? 'Tap the map to drop a pin. This is optional.'
                  : 'Lat ${_selected!.latitude.toStringAsFixed(5)}, '
                      'Lng ${_selected!.longitude.toStringAsFixed(5)}',
              style: const TextStyle(
                color: AppColors.textOnCardMuted,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selected ?? OsmLocationPicker.defaultCenter,
                    initialZoom: widget.initialZoom,
                    onTap: _onTap,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.amaano.bookverse',
                    ),
                    if (_selected != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selected!,
                            width: 44,
                            height: 44,
                            child: const Icon(
                              Icons.location_on,
                              color: AppColors.caramel,
                              size: 44,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.espresso,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selected == null
                        ? null
                        : () => Navigator.pop(context, _selected),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.caramel,
                      foregroundColor: AppColors.espressoDeep,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Use this location'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
