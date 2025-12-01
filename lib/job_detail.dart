import 'package:flutter/material.dart';
import 'package:firebase_dart/firebase_dart.dart';
import 'package:firebase_dart/database.dart';

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
  late FirebaseDatabase _database;
  late DatabaseReference _jobRef;

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
    // Initialize firebase_dart database instance
    final app = Firebase.app();
    _database = FirebaseDatabase(app: app);

    // Define reference using .reference().child()
    _jobRef = _database.reference().child(
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

  // Helper to safely convert raw data to Map
  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw == null) return {};
    if (raw is Map) {
      final out = <String, dynamic>{};
      raw.forEach((k, v) => out[k.toString()] = v);
      return out;
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("")),
      backgroundColor: const Color(0xFFF8F7FD),
      // Changed Stream type to Event for firebase_dart
      body: StreamBuilder<Event>(
        stream: _jobRef.onValue,
        builder: (context, AsyncSnapshot<Event> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // In firebase_dart, check if value is null
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("Details not found for this job."));
          }

          final rawValue = snapshot.data!.snapshot.value;
          final jobData = _asMap(rawValue);
          final locationName = jobData['location'] ?? 'Unknown Location';

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6,
              ),
              child: SingleChildScrollView(
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
        },
      ),
    );
  }

  Widget buildInfoCard(Map<String, dynamic> jobData, String locationName) {
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
              const Icon(Icons.place, size: 24, color: Colors.green),
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
                  isCompleted ? Icons.done_all_rounded : Icons.done_rounded,
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
