import 'dart:io';
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
    final app = Firebase.app(); // Must initialize in main() first
    database = FirebaseDatabase(app: app);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<Event>(
        stream: ref.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final ds = snapshot.data!.snapshot;
          if (ds.value == null) {
            return const Center(child: Text("No employees found"));
          }

          final Map<String, dynamic> data = ds.value is Map
              ? Map<String, dynamic>.fromIterables(
                  (ds.value as Map).keys.map((k) => k.toString()),
                  (ds.value as Map).values,
                )
              : {'item': ds.value};

          final employeeKeys = data.keys.toList();

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
                // 🔍 Search Bar
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
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 20,
                          color: Colors.grey,
                        ),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
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
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void openEditSheet(BuildContext context, dynamic empKey, Map empData) {
    final officeOptions = [
      "Head Office",
      'Embilipitya',
      'Matara',
      'Galle',
      "Hambantota",
      "Colombo",
      "Tangalle",
      "Weligama",
      "Ahangama",
      "Kamburupitiya",
      "Akuressa",
      "Deniyaya",
      'Jaffna',
      'Ratnapura',
    ];
    final positionOptions = ["RM", "ARM", "CO", "AGM", "DGM"];

    String selectedOffice = officeOptions.contains(empData["employeeOffice"])
        ? empData["employeeOffice"]
        : officeOptions[0];
    String selectedPosition =
        positionOptions.contains(empData["employeePosition"])
        ? empData["employeePosition"]
        : positionOptions[0];

    bool isDisabled = empData["isDisabled"] == true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Text(
                    "Edit Employee ($empKey)",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _modernDropdown(
                    value: selectedOffice,
                    items: officeOptions,
                    label: "Employee Office",
                    onChanged: (val) => setState(() => selectedOffice = val!),
                  ),
                  const SizedBox(height: 14),
                  _modernDropdown(
                    value: selectedPosition,
                    items: positionOptions,
                    label: "Employee Position",
                    onChanged: (val) => setState(() => selectedPosition = val!),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 52,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                      onPressed: () async {
                        if (selectedOffice == "Head Office" &&
                            (selectedPosition == "RM" ||
                                selectedPosition == "ARM" ||
                                selectedPosition == "DRM")) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                title: const Text(
                                  "Invalid Position",
                                  style: TextStyle(color: Colors.red),
                                ),
                                backgroundColor: Colors.black,
                                content: const Text(
                                  "Please change the Selected Position for Head Office.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      "OK",
                                      style: TextStyle(
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        } else if ((selectedPosition == "AGM" ||
                                selectedPosition == "DGM") &&
                            selectedOffice != "Head Office") {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                title: const Text(
                                  "Invalid Position",
                                  style: TextStyle(color: Colors.red),
                                ),
                                backgroundColor: Colors.black,
                                content: const Text(
                                  "This location not valid for the selected Position. Please select Head Office.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      "OK",
                                      style: TextStyle(
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          await ref.child(empKey.toString()).update({
                            "employeeOffice": selectedOffice,
                            "employeePosition": selectedPosition,
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        "Save Changes",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // SizedBox(
                  //   width: double.infinity,
                  //   height: 52,
                  //   child: FilledButton(
                  //     style: FilledButton.styleFrom(
                  //       backgroundColor: isDisabled
                  //           ? Colors.grey
                  //           : Colors.redAccent,
                  //     ),
                  //     onPressed: isDisabled
                  //         ? null
                  //         : () async {
                  //             await ref.child(empKey.toString()).update({
                  //               "isDisabled": true,
                  //             });
                  //             Navigator.pop(context);
                  //           },
                  //     child: Text(
                  //       isDisabled
                  //           ? "Account Already Disabled"
                  //           : "Disable Account",
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _modernDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String label,
  }) => DropdownButtonHideUnderline(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down),
        onChanged: onChanged,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
      ),
    ),
  );
}
