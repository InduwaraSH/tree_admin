import 'package:admin/deleteBranchdata.dart';
import 'package:admin/saveDataBeforDel_Branch_RM.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

// firebase_dart imports
import 'package:firebase_dart/firebase_dart.dart';
import 'package:firebase_dart/database.dart';

class Branchrequestapprove_RM_new extends StatefulWidget {
  const Branchrequestapprove_RM_new({super.key});

  @override
  State<Branchrequestapprove_RM_new> createState() =>
      _Branchrequestapprove_RM_newState();
}

class _Branchrequestapprove_RM_newState
    extends State<Branchrequestapprove_RM_new> {
  late FirebaseDatabase database;
  late DatabaseReference branchRequestRef;

  @override
  void initState() {
    super.initState();
    final app = Firebase.app();
    database = FirebaseDatabase(app: app);
    branchRequestRef = database.reference().child("RM_branches");
  }

  // Helper to normalize raw snapshot value into a Map<String, dynamic>
  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw == null) return {};
    // Ensure we cast to Map<dynamic, dynamic> first, then string keys
    if (raw is Map) {
      final out = <String, dynamic>{};
      raw.forEach((k, v) => out[k.toString()] = v);
      return out;
    }
    // If it's a simple value, wrap it (though your data seems to be objects)
    return {'value': raw};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FD),
      body: StreamBuilder<Event>(
        stream: branchRequestRef.onValue,
        builder: (context, AsyncSnapshot<Event> snapshot) {
          // 1. Check connection state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Check for errors
          if (snapshot.hasError) {
            print("Firebase Error: ${snapshot.error}"); // DEBUG PRINT
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // 3. Check for null data or null snapshot value
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            print("Snapshot is empty or null"); // DEBUG PRINT
            return const Center(child: Text('No requests found.'));
          }

          final raw = snapshot.data!.snapshot.value;
          print("Raw Data received: $raw"); // DEBUG PRINT

          final List<Map<String, dynamic>> requests = [];

          // 4. IMPROVED PARSING: Handle both Map (keys "id1", "id2") and List (keys 0, 1, 2)
          if (raw is Map) {
            raw.forEach((k, v) {
              final map = _asMap(v);
              map['key'] = k.toString();
              requests.add(map);
            });
          } else if (raw is List) {
            // Firebase returns a List if keys are sequential integers (0, 1, 2...)
            for (int i = 0; i < raw.length; i++) {
              if (raw[i] != null) {
                final map = _asMap(raw[i]);
                map['key'] = i.toString();
                requests.add(map);
              }
            }
          }

          if (requests.isEmpty) {
            return const Center(child: Text('No valid requests found.'));
          }

          return ListView.builder(
            itemCount: requests.length,
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemBuilder: (context, index) {
              final request = requests[index];
              return RMBranchCard(request: request);
            },
          );
        },
      ),
    );
  }
}

// ... The RMBranchCard and _HoverButton classes remain exactly the same as previous code ...
/// FIXED: Extracted Card to separate StatefulWidget to isolate hover state
class RMBranchCard extends StatefulWidget {
  final Map request;
  const RMBranchCard({super.key, required this.request});

  @override
  State<RMBranchCard> createState() => _RMBranchCardState();
}

class _RMBranchCardState extends State<RMBranchCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final String branchID = widget.request['branchId'] ?? 'No ID';
    final String branchTP = widget.request['mobileNumber'] ?? 'No TP';
    final String branchLocation =
        widget.request['branchLocation'] ?? 'No Location';
    final String branchManager =
        widget.request['branchManager'] ?? 'No Manager';

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()..scale(isHovered ? 1.01 : 1.0),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isHovered
                  ? Colors.blue.withOpacity(0.25)
                  : Colors.grey.withOpacity(0.15),
              blurRadius: isHovered ? 25 : 15,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(22),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(
                          Icons.location_city,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        branchLocation,
                        style: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'sfpro',
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _infoRow("Branch ID", branchID),
                  _infoRow("Manager", branchManager),
                  _infoRow("Telephone", branchTP),
                  _infoRow("Location", branchLocation),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                _HoverButton(
                  label: "Confirm",
                  color: Colors.green,
                  onPressed: () {
                    showCupertinoDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return CupertinoAlertDialog(
                          title: const Text(
                            'Confirm Request',
                            style: TextStyle(
                              fontFamily: 'sfpro',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            'Are you sure you want to confirm $branchLocation\'s request?',
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                            ),
                            CupertinoDialogAction(
                              child: const Text(
                                "Confirm",
                                style: TextStyle(color: Colors.green),
                              ),
                              onPressed: () async {
                                Navigator.of(dialogContext).pop();
                                bool result = await InternetConnection()
                                    .hasInternetAccess;
                                if (!result) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('No internet connection'),
                                      backgroundColor: Colors.grey,
                                    ),
                                  );
                                } else {
                                  Savedatabeforedel_branch().SaveData(
                                    branchID,
                                    branchLocation,
                                    branchManager,
                                    branchTP,
                                    context,
                                    'RM',
                                  );
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 14),
                _HoverButton(
                  label: "Decline",
                  color: Colors.red,
                  onPressed: () {
                    showCupertinoDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return CupertinoAlertDialog(
                          title: const Text(
                            'Decline Request',
                            style: TextStyle(
                              fontFamily: 'sfpro',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            'Are you sure you want to decline $branchLocation\'s request?',
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                            ),
                            CupertinoDialogAction(
                              child: const Text(
                                "Decline",
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                Deletebranchdata().deleteData(
                                  branchID,
                                  "RM_branches",
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$label:",
            style: TextStyle(
              fontSize: 15,
              fontFamily: 'sfpro',
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontFamily: 'sfpro',
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HoverButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;
  const _HoverButton({
    Key? key,
    required this.label,
    required this.color,
    required this.onPressed,
  }) : super(key: key);
  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: isHovered ? widget.color : widget.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: widget.color, width: 1.5),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: 'sfpro',
              fontWeight: FontWeight.bold,
              color: isHovered ? Colors.white : widget.color,
            ),
          ),
        ),
      ),
    );
  }
}
