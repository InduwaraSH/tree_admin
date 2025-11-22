import 'package:admin/job_detail.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

/// ---------------- MODEL ----------------
class Job {
  final String serialNum;
  final String city;
  final String status;
  final String location;

  Job({
    required this.serialNum,
    required this.city,
    required this.status,
    required this.location,
  });

  factory Job.fromMap(
    String serialNum,
    String city,
    Map<String, dynamic> data,
  ) {
    return Job(
      serialNum: serialNum,
      city: city,
      status: data['Status'] ?? 'N/A',
      location: data['location'] ?? 'Unknown Location',
    );
  }
}

/// ---------------- MAIN PAGE ----------------
class AllJobsPage extends StatefulWidget {
  const AllJobsPage({super.key});

  @override
  State<AllJobsPage> createState() => _AllJobsPageState();
}

class _AllJobsPageState extends State<AllJobsPage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref(
    'Status_of_job',
  );
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String getFriendlyStatus(String statusKey) {
    const statusMap = {
      'RM_R_D_One': 'RM Received',
      'ARM_R_D_One': 'ARM Received',
      'CO_R_D_One': 'CO Received',
      'ARM_R_D_two': 'ARM Received (2nd)',
      'RM_R_D_two': 'RM Received (2nd)',
      'approved': 'Approved',
      'procurement': 'Procurement',
      'tree_removal': 'Tree Removal',
      'job_completed': 'Job Completed',
    };
    return statusMap[statusKey] ?? statusKey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F7FD),
      body: SafeArea(
        child: Column(
          children: [
            // 🔍 Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: "sfproRoundSemiB",
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by location, city, or status...',
                    prefixIcon: const Icon(
                      Icons.done,

                      size: 20,
                      color: Colors.grey,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.import_contacts,
                              size: 20,
                              color: Colors.grey,
                            ),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 8,
                    ),
                  ),
                ),
              ),
            ),

            // 🔄 Stream Content
            Expanded(
              child: StreamBuilder(
                stream: _databaseRef.onValue,
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0A7AFE),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData ||
                      snapshot.data!.snapshot.value == null) {
                    return const Center(child: Text('No jobs found.'));
                  }

                  final List<Job> allJobs = [];
                  final allCities = Map<String, dynamic>.from(
                    snapshot.data!.snapshot.value as Map,
                  );

                  allCities.forEach((cityName, cityJobs) {
                    final jobsMap = Map<String, dynamic>.from(cityJobs as Map);
                    jobsMap.forEach((serialNum, jobData) {
                      allJobs.add(
                        Job.fromMap(
                          serialNum,
                          cityName,
                          Map<String, dynamic>.from(jobData as Map),
                        ),
                      );
                    });
                  });

                  final List<Job> filteredJobs = _searchQuery.isEmpty
                      ? allJobs
                      : allJobs.where((job) {
                          final query = _searchQuery.toLowerCase();
                          final status = getFriendlyStatus(
                            job.status,
                          ).toLowerCase();
                          return job.location.toLowerCase().contains(query) ||
                              job.city.toLowerCase().contains(query) ||
                              status.contains(query);
                        }).toList();

                  return Column(
                    children: [
                      JobStatsRow(jobs: filteredJobs),
                      Expanded(
                        child: filteredJobs.isEmpty
                            ? const Center(
                                child: Text(
                                  'No results found.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontFamily: "sfproRoundSemiB",
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                itemCount: filteredJobs.length,
                                itemBuilder: (context, index) {
                                  final job = filteredJobs[index];
                                  return JobCard(
                                    job: job,
                                    getFriendlyStatus: getFriendlyStatus,
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- JOB CARD ----------------
class JobCard extends StatefulWidget {
  final Job job;
  final String Function(String) getFriendlyStatus;

  const JobCard({
    super.key,
    required this.job,
    required this.getFriendlyStatus,
  });

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _hover
                ? const Color(0xFF0A7AFE).withOpacity(0.2)
                : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: _hover
                  ? Colors.blue.withOpacity(0.08)
                  : Colors.black.withOpacity(0.03),
              blurRadius: _hover ? 18 : 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JobDetailsPage(
                  branchName: widget.job.city,
                  serialNum: widget.job.serialNum,
                ),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A7AFE).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.done,
                  color: Color(0xFF0A7AFE),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.job.serialNum,
                      style: const TextStyle(
                        fontSize: 17,
                        fontFamily: "sfproRoundSemiB",
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _InfoChip(Icons.done, widget.job.location),
                        const SizedBox(width: 8),
                        _InfoChip(Icons.done, widget.job.city),
                        const SizedBox(width: 8),
                        _InfoChip(
                          Icons.done,
                          widget.getFriendlyStatus(widget.job.status),
                          color: const Color(0xFF0A7AFE),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.done, size: 22, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _InfoChip(IconData icon, String text, {Color color = Colors.grey}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontFamily: "sfproRoundSemiB",
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------- JOB STATS ROW ----------------
class JobStatsRow extends StatelessWidget {
  final List<Job> jobs;
  const JobStatsRow({super.key, required this.jobs});

  @override
  Widget build(BuildContext context) {
    final totalCount = jobs.length;

    final statusMetrics = [
      {'statusKey': 'ARM_R_D_One', 'title': 'ARM Received'},
      {'statusKey': 'CO_R_D_One', 'title': 'CO Received'},
      {'statusKey': 'ARM_R_D_two', 'title': 'ARM 2nd'},
      {'statusKey': 'RM_R_D_two', 'title': 'RM 2nd'},
      {'statusKey': 'approved', 'title': 'Approved'},
      {'statusKey': 'procurement', 'title': 'Procurement'},
      {'statusKey': 'tree_removal', 'title': 'Tree Removal'},
    ];

    return SizedBox(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ActivityCard(
            title: 'Total Jobs',
            count: totalCount,
            total: totalCount,
            color: const Color(0xFF0A7AFE),
          ),
          ...statusMetrics.map((metric) {
            final count = jobs
                .where((job) => job.status == metric['statusKey'])
                .length;
            return ActivityCard(
              title: metric['title'] as String,
              count: count,
              total: totalCount,

              color: Colors.green,
            );
          }),
        ],
      ),
    );
  }
}

/// ---------------- ACTIVITY CARD (FIXED UI) ----------------
class ActivityCard extends StatelessWidget {
  final String title;
  final int count;
  final int total;
  final Color color;

  const ActivityCard({
    super.key,
    required this.title,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? count / total : 0.0;

    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            total == 0 ? 'No data available' : '$count of $total',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: SizedBox(
              width: 55,
              height: 55,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 6,
                    color: Colors.grey.shade800,
                  ),
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    strokeCap: StrokeCap.round,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                  Center(
                    child: Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
