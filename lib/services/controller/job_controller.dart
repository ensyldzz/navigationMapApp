import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:map_app/models/job_model.dart';

class JobStateNotifier extends StateNotifier<List<JobModel>> {
  JobStateNotifier() : super([]) {
    _loadJobs();
  }

  final db = FirebaseFirestore.instance.collection('jobs');

  Future<void> _loadJobs() async {
    final snapshot = await db.get();
    state = snapshot.docs.map((doc) => JobModel.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> addJob(JobModel job, String userId) async {
    final jobWithPublisher = job.copyWith(publisherId: userId);
    final docRef = await db.add(jobWithPublisher.toMap());
    final newJob = jobWithPublisher.copyWith(id: docRef.id);
    state = [...state, newJob];
  }

  Future<void> deleteJob(String jobId) async {
    await db.doc(jobId).delete();
    state = state.where((job) => job.id != jobId).toList();
  }

  Future<void> takeJob(String jobId, String userId) async {
    await db.doc(jobId).update({'takenBy': userId});
    _loadJobs();
  }

  Future<void> releaseJob(String jobId) async {
    await db.doc(jobId).update({'takenBy': null});
    _loadJobs();
  }

  Future<void> updateJobCompletion(String jobId, bool isCompleted) async {
    await db.doc(jobId).update({'isJobCompleted': isCompleted});
    _loadJobs();
  }
}

final jobProvider = StateNotifierProvider<JobStateNotifier, List<JobModel>>((ref) {
  return JobStateNotifier();
});
