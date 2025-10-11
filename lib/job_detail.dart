import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:iconsax/iconsax.dart';

class JobDetailsPage extends StatefulWidget {
  final String branchName;
  final String serialNum;

  const JobDetailsPage({
    super.key,
    required this.branchName,
    required this.serialNum,
  });

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  late final DatabaseReference _jobRef;

  final List<String> steps = [
    'RM_R_D_One',
    'ARM_R_D_One',
    'CO_R_D_One',
    'ARM_R_D_two',
    'RM_R_D_two',
    'approved',
    'procurement',
    'tree_removal',
    'job_completed',
  ];

  final List<String> stepDisplayNames = [
    'RM Received',
    'ARM Received',
    'CO Received',
    'ARM Received 2nd',
    'RM Received 2nd',
    'Approved',
    'Procurement',
    'Tree Removal',
    'Job Completed',
  ];

  @override
  void initState() {
    super.initState();
    _jobRef = FirebaseDatabase.instance.ref(
      'Status_of_job/${widget.branchName}/${widget.serialNum}',
    );
  }

  Color getStepColor(String step, Map<String, dynamic> jobData) {
    String currentStatus = jobData['Status'] ?? '';
    int stepIndex = steps.indexOf(step);
    int statusIndex = steps.indexOf(currentStatus);

    if (stepIndex != -1 && statusIndex != -1 && stepIndex <= statusIndex) {
      return Colors.green;
    }
    return Colors.grey.shade300;
  }

  String getStepDate(String step, Map<String, dynamic> jobData) {
    return jobData[step] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("")),
      backgroundColor: Color(0xFFF8F7FD),
      body: StreamBuilder(
        stream: _jobRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.snapshot.exists) {
            return const Center(child: Text("Details not found for this job."));
          }

          final jobData = Map<String, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );
          final locationName = jobData['location'] ?? 'Unknown Location';

          // ✅ --- MODIFICATION STARTS HERE --- ✅

          // 1. We wrap the content with a 'Center' widget to center it horizontally.
          return Center(
            // 2. We use 'ConstrainedBox' to limit the width of the child.
            child: ConstrainedBox(
              constraints: BoxConstraints(
                // 3. Set the maximum width to 60% of the screen's total width.
                maxWidth: MediaQuery.of(context).size.width * 0.6,
              ),
              child: SingleChildScrollView(
                // 4. Add some vertical padding for better spacing.
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Job Timeline",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    buildInfoCard(jobData, locationName),
                    const SizedBox(height: 24),
                    buildTimeline(jobData),
                  ],
                ),
              ),
            ),
          );

          // ✅ --- MODIFICATION ENDS HERE --- ✅
        },
      ),
    );
  }

  Widget buildInfoCard(Map<String, dynamic> jobData, String locationName) {
    // This widget remains unchanged
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(36, 107, 238, 111),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.location5, size: 24, color: Colors.green),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  locationName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: steps.map((step) {
              return Expanded(
                child: Container(
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2.0),
                  decoration: BoxDecoration(
                    color: getStepColor(step, jobData),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget buildTimeline(Map<String, dynamic> jobData) {
    // This widget remains unchanged
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
        final date = getStepDate(step, jobData);
        final isCompleted = getStepColor(step, jobData) == Colors.green;

        return TimelineStep(
          stepName: stepDisplayNames[index],
          date: date.isNotEmpty ? date : "Pending",
          isCompleted: isCompleted,
          isFirst: index == 0,
          isLast: index == steps.length - 1,
        );
      },
    );
  }
}

// This TimelineStep widget remains the same as before
class TimelineStep extends StatelessWidget {
  final String stepName;
  final String date;
  final bool isCompleted;
  final bool isFirst;
  final bool isLast;

  const TimelineStep({
    super.key,
    required this.stepName,
    required this.date,
    required this.isCompleted,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted ? Colors.green : Colors.grey.shade300,
                    ),
                  )
                else
                  const Spacer(),
                Icon(
                  isCompleted ? Iconsax.tick_circle : Iconsax.minus_cirlce,
                  color: isCompleted ? Colors.green : Colors.grey.shade400,
                  size: 28,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: Colors.grey.shade300),
                  )
                else
                  const Spacer(),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green.withOpacity(0.05)
                    : Colors.grey.withOpacity(0.05),
                border: Border.all(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    stepName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                          ? Colors.black87
                          : Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 14,
                      color: isCompleted ? Colors.green : Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
