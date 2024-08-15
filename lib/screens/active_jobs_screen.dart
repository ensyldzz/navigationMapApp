import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_app/helpers/constant/text.dart';
import 'package:map_app/services/controller/job_controller.dart';
import 'package:map_app/services/auth_repository.dart';
import 'package:map_app/helpers/widgets/custom_card.dart';
import 'package:map_app/helpers/widgets/custom_elevated_button.dart';
import 'package:map_app/helpers/location_helper.dart';
import 'package:map_app/helpers/constant/snack_bar.dart';
import 'package:map_app/screens/detail._screen.dart';
import 'package:map_app/screens/map.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActiveJobsScreen extends ConsumerStatefulWidget {
  const ActiveJobsScreen({super.key});

  @override
  createState() => _ActiveJobsScreenState();
}

class _ActiveJobsScreenState extends ConsumerState<ActiveJobsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late LatLng depotLocation;
  LatLng? currentPosition;

  Future<void> loadUserData() async {
    final userId = ref.read(authRepositoryProvider).auth.currentUser!.uid;
    final prefs = await SharedPreferences.getInstance();
    final wallet = prefs.getDouble('${userId}_wallet') ?? 0.0;
    final jobCompleted = prefs.getBool('${userId}_jobCompleted') ?? false;

    setState(() {
      myWallet = wallet;
      jobState = jobCompleted;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    depotLocation = const LatLng(39.89203, 32.93059);
    _getCurrentPosition();
    loadUserData();
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

  @override
  Widget build(BuildContext context) {
    final jobs = ref.watch(jobProvider);
    final userId = ref.watch(authRepositoryProvider).auth.currentUser!.uid;
    final activeJobs = jobs.where((job) => job.takenBy == null).toList();
    final takenJobs = jobs.where((job) => job.takenBy == userId).toList();
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        centerTitle: true,
        title: Text('${ConstantText.wallet} $myWallet ₺'),
        bottom: TabBar(
          tabs: [
            Tab(text: ConstantText.openWorks),
            Tab(text: ConstantText.myWorks),
          ],
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
        ),
      ),
      body: TabBarView(controller: _tabController, children: [
        activeJobs.isEmpty
            ? Center(child: Text(ConstantText.noWorks))
            : ListView.builder(
                itemCount: activeJobs.length,
                itemBuilder: (context, index) {
                  final job = activeJobs[index];
                  return CustomCard(
                    job: job,
                    text: '₺${job.price}',
                    title: job.companyName,
                    subtitle: job.package,
                    row: [
                      CustomElevatedButton(
                          onPressed: () async {
                            await ref.read(jobProvider.notifier).takeJob(job.id!, userId);
                            snackBar(context, ConstantText.succesGetWorks, bgColor: Colors.green);
                          },
                          buttonText: ConstantText.getWork),
                    ],
                  );
                },
              ),
        takenJobs.isEmpty
            ? Center(child: Text(ConstantText.haveNotWork))
            : ListView.builder(
                itemCount: takenJobs.length,
                itemBuilder: (context, index) {
                  final job = takenJobs[index];
                  return CustomCard(
                      job: job,
                      text: '₺${job.price}',
                      title: job.companyName,
                      subtitle: job.package,
                      row: job.isJobCompleted
                          ? []
                          : [
                              Expanded(
                                flex: 45,
                                child: CustomElevatedButton(
                                    onPressed: () async {
                                      await ref.read(jobProvider.notifier).releaseJob(job.id!);
                                      snackBar(context, ConstantText.succesCancelWork, bgColor: Colors.green);
                                    },
                                    buttonText: ConstantText.cancelWork),
                              ),
                              const Expanded(flex: 2, child: SizedBox()),
                              Expanded(
                                  flex: 45,
                                  child: CustomElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => DetailPage(
                                                sourceLocation: currentPosition!,
                                                destinationLocation: depotLocation,
                                                jobId: job.id!,
                                              ),
                                            ));
                                      },
                                      buttonText: ConstantText.getPackages))
                            ]);
                },
              ),
      ]),
    );
  }
}
