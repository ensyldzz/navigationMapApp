import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocode/geocode.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_app/helpers/constant/text.dart';
import 'package:map_app/helpers/map_animated_helper.dart';
import 'package:map_app/services/controller/job_controller.dart';
import 'package:map_app/services/auth_repository.dart';
import 'package:map_app/helpers/widgets/custom_elevated_button.dart';
import 'package:map_app/helpers/location_helper.dart';
import 'package:map_app/helpers/constant/sizes.dart';
import 'package:map_app/helpers/constant/snack_bar.dart';
import 'package:map_app/screens/active_jobs_screen.dart';
import 'package:map_app/screens/detail._screen.dart';
import 'package:ripple_wave/ripple_wave.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends ConsumerStatefulWidget {
  final String userId;
  final String jobId;
  const MapScreen({
    super.key,
    required this.userId,
    required this.jobId,
  });

  @override
  createState() => _MapScreenState();
}

bool jobState = false;
double myWallet = 0;

class _MapScreenState extends ConsumerState<MapScreen> with TickerProviderStateMixin {
  late final MapController mapController;
  List<Marker> markers = [];
  List<dynamic> userPackages = [];
  LatLng? currentPosition;
  List<LatLng> packageCoordinatesList = [];

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    loadMarkers();
    _getCurrentPosition();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentPosition() async {
    bool hasPermission = await LocationHelper.handleLocationPermission(context);
    if (hasPermission) {
      LocationHelper.getPositionStream().listen((position) {
        setState(() {
          currentPosition = LatLng(position.latitude, position.longitude);
        });
      });
    }
  }

  Future<LatLng?> _getLatLngFromAddress(String address) async {
    try {
      final coordinates = await GeoCode().forwardGeocoding(address: address);
      if (coordinates.latitude != null && coordinates.longitude != null) {
        return LatLng(coordinates.latitude!, coordinates.longitude!);
      } else {
        snackBar(context, '${ConstantText.openWorks} $address');
        return null;
      }
    } catch (e) {
      snackBar(context, "${ConstantText.errorGeocode} $e");
      return null;
    }
  }

  Future<void> loadMarkers() async {
    final currentUserId = ref.read(authRepositoryProvider).currentUserId;
    final jobs = await FirebaseFirestore.instance.collection('jobs').doc(widget.jobId).get();
    List<dynamic> allPackages = [];
    if (jobs.exists && jobs['takenBy'] == currentUserId) {
      if (jobs['packages'] != null) {
        allPackages.addAll(jobs['packages']);
      }
    }

    List<Marker> loadedMarkers = [];
    List<LatLng> loadedCoordinates = [];
    for (var package in allPackages) {
      final packageAddress = package['recipientAddress'];
      if (packageAddress != null) {
        final packageCoordinates = await _getLatLngFromAddress(packageAddress);
        if (packageCoordinates != null) {
          loadedCoordinates.add(packageCoordinates);
          loadedMarkers.add(
            Marker(
              point: packageCoordinates,
              child: const Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 30,
              ),
            ),
          );
        } else {
          debugPrint("${ConstantText.mistakeGeocode} $packageAddress");
          snackBar(context, "${ConstantText.notFoundCoordinates} $packageAddress");
        }
      }
    }
    setState(() {
      markers = loadedMarkers;
      userPackages = allPackages;
      packageCoordinatesList = loadedCoordinates;
    });
  }

  void changeWallet() async {
    final userId = ref.watch(authRepositoryProvider).auth.currentUser!.uid;
    final prefs = await SharedPreferences.getInstance();
    final currentWallet = prefs.getDouble('${userId}_wallet') ?? 0.0;
    final jobs = ref.watch(jobProvider);
    final job = jobs.firstWhere((job) => job.id == widget.jobId && job.takenBy == userId);
    final newWallet = currentWallet + job.price;
    setState(() {
      myWallet = newWallet;
    });
    prefs.setDouble('${userId}_wallet', newWallet);
  }

  void _toggleJobCompletion() async {
    final currentUserId = ref.read(authRepositoryProvider).currentUserId;
    final jobNotifier = ref.read(jobProvider.notifier);
    final jobs = await FirebaseFirestore.instance.collection('jobs').doc(widget.jobId).get();

    if (jobs.exists && jobs['takenBy'] == currentUserId) {
      jobNotifier.updateJobCompletion(widget.jobId, !jobState);
    }

    saveDevice(currentUserId);
    changeWallet();

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ActiveJobsScreen()));
  }

  void saveDevice(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('${userId}_complatedJob', jobState);
    prefs.setDouble('${userId}_wallet', myWallet);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox.shrink(),
        toolbarHeight: 75,
        elevation: 0,
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            Text(ConstantText.deliverPackage),
            Checkbox(
              value: jobState,
              onChanged: (value) {
                setState(() {
                  _toggleJobCompletion();
                });
              },
            ),
          ],
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          currentPosition == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: currentPosition!,
                    initialZoom: 13,
                    onMapReady: loadMarkers,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: ConstantText.urlTemplate,
                    ),
                    MarkerLayer(
                      markers: [
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
                              ),
                            ),
                          ),
                        ),
                        ...markers,
                      ],
                    ),
                  ],
                ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: ScreenUtil.getWidth(context) * 0.96,
              height: ScreenUtil.getHeight(context) * 0.27,
              child: userPackages.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: userPackages.length,
                      itemBuilder: (context, index) {
                        if (index >= userPackages.length || index >= packageCoordinatesList.length) {
                          return const SizedBox.shrink();
                        }
                        final package = userPackages[index];
                        final recipientName = package['recipientName'];
                        final packageAddress = package['recipientAddress'];
                        final customerPhone = package['recipientPhone'];
                        final packageCoordinates = packageCoordinatesList[index];
                        final distance = const Distance().as(
                          LengthUnit.Meter,
                          currentPosition!,
                          packageCoordinates,
                        );
                        return InkWell(
                          onTap: () {
                            MapHelper.animatedMapMove(
                                mapController, this, packageCoordinates, mapController.camera.zoom);
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                            child: Container(
                              width: 300,
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${ConstantText.buyerName} $recipientName',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text('${ConstantText.address} $packageAddress'),
                                  const SizedBox(height: 10),
                                  Text('${ConstantText.distance} ${(distance / 1000).toStringAsFixed(1)} km'),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      const Expanded(flex: 10, child: Icon(Icons.route)),
                                      Expanded(
                                        flex: 40,
                                        child: CustomElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => DetailPage(
                                                  redirectBack: false,
                                                  sourceLocation: currentPosition!,
                                                  destinationLocation: packageCoordinates,
                                                  jobId: widget.jobId,
                                                ),
                                              ),
                                            );
                                          },
                                          buttonText: ConstantText.start,
                                        ),
                                      ),
                                      const Expanded(flex: 10, child: SizedBox()),
                                      const Expanded(flex: 10, child: Icon(Icons.phone)),
                                      Expanded(
                                        flex: 30,
                                        child: CustomElevatedButton(
                                          onPressed: () async {
                                            final String phoneNumber = customerPhone.toString();
                                            final Uri url = Uri(scheme: ConstantText.tel, path: phoneNumber);
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(url);
                                            } else {
                                              snackBar(context, ConstantText.errorState);
                                            }
                                          },
                                          buttonText: ConstantText.call,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
