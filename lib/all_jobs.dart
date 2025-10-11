import 'package:admin/job_detail.dart'; // Make sure this import path is correct
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// Your Job data model (no changes needed here)
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

// Main page widget
class AllJobsPage extends StatefulWidget {
  const AllJobsPage({super.key});

  @override
  State<AllJobsPage> createState() => _AllJobsPageState();
}

class _AllJobsPageState extends State<AllJobsPage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref(
    'Status_of_job',
  );

  // ✅ --- ADDITIONS FOR SEARCH FUNCTIONALITY --- ✅
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Listener to update the search query state in real-time
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Moved this helper here to be accessible for filtering
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
  // ✅ --- END OF SEARCH ADDITIONS --- ✅

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F7FD),
      body: Column(
        children: [
          // ✅ --- SEARCH BAR UI --- ✅
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by location, city, or status...',
                prefixIcon: const Icon(Iconsax.search_normal_1, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Iconsax.close_circle, size: 20),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.green.shade400,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          // ✅ --- LIST WRAPPED IN EXPANDED --- ✅
          Expanded(
            child: StreamBuilder(
              stream: _databaseRef.onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
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

                // ✅ --- FILTERING LOGIC --- ✅
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

                if (filteredJobs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No results found.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: filteredJobs.length,
                  itemBuilder: (context, index) {
                    final job = filteredJobs[index];
                    return JobCard(
                      job: job,
                      getFriendlyStatus:
                          getFriendlyStatus, // Pass helper function
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class JobCard extends StatefulWidget {
  final Job job;
  // ✅ --- ADDED HELPER FUNCTION PARAMETER --- ✅
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
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? Colors.green.withOpacity(0.2)
                    : Colors.black.withOpacity(0.06),
                blurRadius: _isHovered ? 20 : 10,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.green.shade50,
                          child: Icon(
                            Iconsax.document_text,
                            color: Colors.green.shade700,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            widget.job.serialNum,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Divider(height: 1),
                    ),
                    _JobInfoRow('Location:', widget.job.location),
                    _JobInfoRow('City:', widget.job.city),
                    _JobInfoRow(
                      'Status:',
                      // ✅ --- USE THE PASSED-IN FUNCTION --- ✅
                      widget.getFriendlyStatus(widget.job.status),
                      statusColor: Colors.green.shade800,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Icon(
                Iconsax.arrow_right_3,
                color: _isHovered ? Colors.green : Colors.grey.shade300,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _JobInfoRow(String label, String value, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: statusColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
