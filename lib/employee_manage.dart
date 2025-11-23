import 'package:flutter/material.dart';
import 'package:firebase_dart/firebase_dart.dart';
import 'package:firebase_dart/database.dart';

class Emp_Manage extends StatefulWidget {
  const Emp_Manage({super.key});

  @override
  State<Emp_Manage> createState() => _Emp_ManageState();
}

class _Emp_ManageState extends State<Emp_Manage> {
  late FirebaseDatabase database;
  late DatabaseReference ref;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();

    // Firebase app must be initialized in main() first
    final app = Firebase.app();
    database = FirebaseDatabase(app: app);

    // Path to employee data
    ref = database.reference().child("employee_data_saved");

    _searchController.addListener(() {
      setState(() => searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _normalize(dynamic raw) {
    if (raw == null) return {};
    if (raw is Map) {
      final out = <String, dynamic>{};
      raw.forEach((k, v) => out[k.toString()] = v);
      return out;
    }
    return {'value': raw};
  }

  DataSnapshot? _extractSnapshot(dynamic eventOrSnap) {
    if (eventOrSnap == null) return null;
    if (eventOrSnap is Event) return eventOrSnap.snapshot;
    if (eventOrSnap is DataSnapshot) return eventOrSnap;
    try {
      final maybeSnapshot = (eventOrSnap as dynamic).snapshot;
      if (maybeSnapshot is DataSnapshot) return maybeSnapshot;
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<dynamic>(
        stream: ref.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final ds = _extractSnapshot(snapshot.data);
          if (ds == null || ds.value == null) {
            return const Center(child: Text("No employees found"));
          }

          final dataRaw = ds.value;
          final Map<String, dynamic> data = dataRaw is Map
              ? Map<String, dynamic>.fromIterables(
                  dataRaw.keys.map((k) => k.toString()),
                  dataRaw.values,
                )
              : {'item': dataRaw};

          final employeeKeys = data.keys.toList();

          // Filter employees based on searchQuery
          final filteredKeys = employeeKeys.where((key) {
            final emp = _normalize(data[key]);
            final name = emp["employeeName"]?.toString().toLowerCase() ?? "";
            final office =
                emp["employeeOffice"]?.toString().toLowerCase() ?? "";
            final id = key.toString().toLowerCase();
            final query = searchQuery.toLowerCase();
            return name.contains(query) ||
                office.contains(query) ||
                id.contains(query);
          }).toList();

          return Container(
            color: const Color(0xFFF8F7FD),
            child: Column(
              children: [
                // 🔍 Modern Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 8),
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
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Search by Name, Office, or ID...',
                        hintStyle: const TextStyle(
                          fontFamily: "sfproRoundSemiB",
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                        prefixIcon: const Icon(
                          Icons.done,
                          size: 20,
                          color: Colors.grey,
                        ),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.done,
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
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    itemCount: filteredKeys.length,
                    itemBuilder: (context, index) {
                      final key = filteredKeys[index];
                      final emp = _normalize(data[key]);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => openEditSheet(context, key, emp),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(
                                    height: 46,
                                    width: 46,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF0A7AFE,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: Color(0xFF0A7AFE),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          emp["employeeName"] ?? "Unknown",
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontFamily: "sfproRoundSemiB",
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            _infoChip(
                                              Icons.apartment,
                                              emp["employeeOffice"] ?? "N/A",
                                            ),
                                            const SizedBox(width: 8),
                                            _infoChip(
                                              Icons.work,
                                              emp["employeePosition"] ?? "N/A",
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: "sfproRoundSemiB",
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // The openEditSheet and _modernDropdown stay exactly the same
  void openEditSheet(BuildContext context, dynamic empKey, Map empData) {
    /* unchanged */
  }

  //Widget _modernDropdown({required String value, required List<String> items, required ValueChanged<String?> onChanged, required String label}) { /* unchanged */ }
}
