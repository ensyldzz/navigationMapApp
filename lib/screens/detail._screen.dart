import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_app/helpers/constant/text.dart';
import 'package:map_app/services/auth_repository.dart';
import 'package:map_app/helpers/location_helper.dart';
import 'package:map_app/screens/map.dart';
import 'package:map_app/services/api.dart';
import 'package:ripple_wave/ripple_wave.dart';

class DetailPage extends ConsumerStatefulWidget {
  final LatLng sourceLocation;
  final LatLng destinationLocation;
  final bool redirectBack;
  final String jobId;

  const DetailPage(
      {super.key,
      required this.sourceLocation,
      required this.destinationLocation,
      this.redirectBack = true,
      required this.jobId});

  @override
  createState() => _DetailPageState();
}

class _DetailPageState extends ConsumerState<DetailPage> with TickerProviderStateMixin {
  late final MapController mapController;
  List<Polyline> polylinesCoordinate = [];
  bool hasNavigated = false;
  late LatLng depotLocation;
  LatLng? currentPosition;

  void getPolyPoint() async {
    List<LatLng>? polylines = await ApiOSRM().getRoutes(
      widget.sourceLocation.longitude.toString(),
      widget.sourceLocation.latitude.toString(),
      widget.destinationLocation.longitude.toString(),
      widget.destinationLocation.latitude.toString(),
    );
    if (mounted) {
      setState(() {
        if (polylines!.isNotEmpty) {
          polylinesCoordinate.add(Polyline(points: polylines, strokeWidth: 6, color: Colors.blue));
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    getPolyPoint();
    getPosition();
    depotLocation = const LatLng(39.89203, 32.93059);
  }

  @override
  void dispose() {
    super.dispose();
    mapController.dispose();
  }

  getPosition() async {
    final hasPermission = await LocationHelper.handleLocationPermission(context);
    if (hasPermission) {
      LocationHelper.getPositionStream().listen((position) {
        if (!mounted || hasNavigated) return;
        setState(() {
          currentPosition = position;
          _checkLocationMatch();
        });
      });
    }
  }

  void _checkLocationMatch() {
    const double tolerance = 0.0002; // 20 metre tölerans
    if (!hasNavigated &&
        (currentPosition!.latitude - depotLocation.latitude).abs() <= tolerance &&
        (currentPosition!.longitude - depotLocation.longitude).abs() <= tolerance &&
        widget.redirectBack) {
      hasNavigated = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreen(
            userId: ref.read(authRepositoryProvider).auth.currentUser!.uid,
            jobId: widget.jobId,
          ),
        ),
      );
    }
  }

  setBound() async {
    final bounds = LatLngBounds.fromPoints([widget.sourceLocation, widget.destinationLocation]);
    mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.only(left: 20, right: 20, bottom: 5, top: 20)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 75,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, top: 10),
          child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                size: 40,
              )),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: currentPosition == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialZoom: 13,
                initialCenter: currentPosition!,
                onMapReady: () {
                  setBound();
                  getPosition();
                  getPolyPoint();
                },
              ),
              children: [
                  TileLayer(
                    urlTemplate: ConstantText.urlTemplate,
                  ),
                  PolylineLayer(polylines: polylinesCoordinate),
                  MarkerLayer(markers: [
                    Marker(
                        width: 100,
                        height: 50,
                        point: currentPosition!,
                        child: RippleWave(
                          color: Colors.green,
                          child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.location_pin,
                                size: 30,
                              )),
                        )),
                    Marker(
                        alignment: Alignment.center,
                        point: widget.destinationLocation,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 30,
                        )),
                  ])
                ]),
    );
  }
}
