import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:map_app/helpers/constant/text.dart';
import 'package:map_app/models/job_model.dart';
import 'package:map_app/models/package_model.dart';
import 'package:map_app/services/controller/job_controller.dart';
import 'package:map_app/services/auth_repository.dart';
import 'package:map_app/helpers/widgets/custom_card.dart';
import 'package:map_app/helpers/widgets/custom_elevated_button.dart';
import 'package:map_app/helpers/widgets/custom_textfield.dart';
import 'package:map_app/helpers/constant/snack_bar.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with TickerProviderStateMixin {
  final companyNameController = TextEditingController();
  final packageController = TextEditingController();
  final priceController = TextEditingController();
  late TabController _tabController;
  int packageCount = 0;
  List<TextEditingController> recipientNameControllers = [];
  List<TextEditingController> recipientAddressControllers = [];
  List<TextEditingController> recipientPhoneControllers = [];
  String addressPattern = ConstantText.addressPatern;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    companyNameController.dispose();
    packageController.dispose();
    priceController.dispose();
    for (var controller in recipientNameControllers) {
      controller.dispose();
    }
    for (var controller in recipientAddressControllers) {
      controller.dispose();
    }
    for (var controller in recipientPhoneControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submitJob(WidgetRef ref) async {
    if (companyNameController.text.isNotEmpty && packageController.text.isNotEmpty && priceController.text.isNotEmpty) {
      setState(() {
        packageCount = int.tryParse(packageController.text) ?? 0;
      });
    } else {
      snackBar(context, ConstantText.allFieldsComplate);
    }
  }

  void _saveJob(WidgetRef ref) async {
    if (companyNameController.text.isNotEmpty &&
        packageController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        recipientNameControllers.every((controller) => controller.text.isNotEmpty) &&
        recipientAddressControllers.every((controller) => controller.text.isNotEmpty) &&
        recipientPhoneControllers.every((controller) => controller.text.isNotEmpty)) {
      bool allAddressesValid = recipientAddressControllers.every((controller) => isValidAddress(controller.text));

      if (!allAddressesValid) {
        snackBar(context, ConstantText.trueAdressFormat);
        return;
      }
      List<PackageModel> packages = List.generate(packageCount, (index) {
        return PackageModel(
          recipientName: recipientNameControllers[index].text,
          recipientAddress: recipientAddressControllers[index].text,
          recipientPhone: recipientPhoneControllers[index].text,
        );
      });

      JobModel job = JobModel(
        companyName: companyNameController.text,
        package: packageController.text,
        price: num.parse(priceController.text),
        takenBy: null,
        packages: packages,
        publisherId: ref.watch(authRepositoryProvider).auth.currentUser!.uid,
      );

      final userId = ref.watch(authRepositoryProvider).auth.currentUser!.uid;
      await ref.read(jobProvider.notifier).addJob(job, userId);

      snackBar(context, ConstantText.succesWorkSave, bgColor: Colors.green);

      companyNameController.clear();
      packageController.clear();
      priceController.clear();
      recipientNameControllers.clear();
      recipientAddressControllers.clear();
      recipientPhoneControllers.clear();
      setState(() {
        packageCount = 0;
      });
    } else {
      snackBar(context, ConstantText.allPackageFieldsComplate);
    }
  }

  bool isValidAddress(String address) {
    return RegExp(addressPattern).hasMatch(address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        bottom: TabBar(
          tabs: [
            Tab(text: ConstantText.addWork),
            Tab(text: ConstantText.publishedWork),
          ],
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer(
          builder: (context, ref, _) {
            final jobs = ref.watch(jobProvider);
            final userId = ref.watch(authRepositoryProvider).auth.currentUser!.uid;
            final publisher = jobs.where((job) => job.publisherId == userId).toList();
            return TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: companyNameController,
                        hintText: ConstantText.companyName,
                      ),
                      CustomTextField(
                        keyboardType: TextInputType.number,
                        controller: packageController,
                        hintText: ConstantText.packagePiece,
                      ),
                      CustomTextField(
                        keyboardType: TextInputType.number,
                        controller: priceController,
                        hintText: ConstantText.price,
                      ),
                      CustomElevatedButton(
                        onPressed: () => _submitJob(ref),
                        buttonText: ConstantText.add,
                      ),
                      if (packageCount > 0)
                        ...List.generate(packageCount, (index) {
                          recipientNameControllers.add(TextEditingController());
                          recipientAddressControllers.add(TextEditingController());
                          recipientPhoneControllers.add(TextEditingController());
                          return Column(
                            children: [
                              CustomTextField(
                                controller: recipientNameControllers[index],
                                hintText: '${index + 1}${ConstantText.customerName}',
                              ),
                              CustomTextField(
                                maxLines: 3,
                                controller: recipientAddressControllers[index],
                                hintText: '${index + 1}${ConstantText.customerAddress}',
                                helperText: Text(
                                  ConstantText.addressFormat,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                              CustomTextField(
                                maxLength: 11,
                                keyboardType: TextInputType.phone,
                                controller: recipientPhoneControllers[index],
                                hintText: '${index + 1}${ConstantText.customerPhone}',
                                helperText: Text(
                                  ConstantText.warning,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            ],
                          );
                        }),
                      if (packageCount > 0)
                        CustomElevatedButton(
                          onPressed: () {
                            _saveJob(ref);
                          },
                          buttonText: ConstantText.saveJob,
                        ),
                    ],
                  ),
                ),
                publisher.isEmpty
                    ? Center(child: Text(ConstantText.notPublishedJob))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: publisher.length,
                          itemBuilder: (context, index) {
                            final job = publisher[index];
                            final isJobActive = job.takenBy == null;
                            return CustomCard(
                              job: job,
                              text: '₺${job.price}',
                              title: job.companyName,
                              subtitle: job.package,
                              row: [
                                if (isJobActive) ...[
                                  CustomElevatedButton(
                                      onPressed: () async {
                                        await ref.read(jobProvider.notifier).deleteJob(job.id!);
                                        snackBar(context, ConstantText.succesDeleteJob, bgColor: Colors.green);
                                      },
                                      buttonText: ConstantText.deleteJob),
                                ]
                              ],
                            );
                          },
                        ),
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}
