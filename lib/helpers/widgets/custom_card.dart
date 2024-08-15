import 'package:flutter/material.dart';
import 'package:map_app/helpers/constant/text.dart';
import 'package:map_app/models/job_model.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    required this.job,
    required this.text,
    required this.title,
    required this.subtitle,
    required this.row,
  });

  final JobModel job;
  final String text;
  final String title;
  final String subtitle;
  final List<Widget> row;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: job.isJobCompleted
            ? const Icon(Icons.check_circle_outline_outlined, color: Colors.green)
            : const Icon(Icons.update_outlined),
        trailing: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        title: Text(
          '${ConstantText.companyName}: $title',
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${ConstantText.packagePiece}: $subtitle',
              style: const TextStyle(fontSize: 18),
            ),
            Row(
              children: row,
            )
          ],
        ),
      ),
    );
  }
}
