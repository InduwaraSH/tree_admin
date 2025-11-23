import 'dart:io';
import 'package:admin/deleteBranchdata.dart';
import 'package:admin/saveDataBeforDel_Branch_ARM.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

// firebase_dart imports
import 'package:firebase_dart/firebase_dart.dart';
import 'package:firebase_dart/database.dart';

class Branchrequestapprove_ARM_new extends StatefulWidget {
  const Branchrequestapprove_ARM_new({super.key});

  @override
  State<Branchrequestapprove_ARM_new> createState() =>
      _Branchrequestapprove_ARM_newState();
}

class _Branchrequestapprove_ARM_newState
    extends State<Branchrequestapprove_ARM_new> {
  late FirebaseDatabase _database;
  late DatabaseReference branchRequestDbref;

  @override
  void initState() {
    super.initState();
    final app = Firebase.app();
    _database = FirebaseDatabase(app: app);
    branchRequestDbref = _database.reference().child("ARM_branches");
  }

  Map<String, dynamic> _asMap(dynamic raw) {
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
      backgroundColor: const Color(0xFFF8F7FD),
      body: StreamBuilder<Event>(
        stream: branchRequestDbref.onValue,
        builder: (context, AsyncSnapshot<Event> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text('No requests found.'));
          }

          final raw = snapshot.data!.snapshot.value;
          final Map<String, dynamic> entries = {};

          if (raw is Map) {
            raw.forEach((k, v) => entries[k.toString()] = v);
          } else {
            entries['0'] = raw;
          }

          final keys = entries.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: keys.length,
            itemBuilder: (context, index) {
              final key = keys[index];
              final value = entries[key];
              final Map request = _asMap(value);
              request['key'] = key;

              // FIXED: Using a separate Widget class here prevents the whole list
              // from rebuilding when you hover, fixing the button click issue.
              return BranchCard(request: request);
            },
          );
        },
      ),
    );
  }
}

/// FIXED: Extracted the Card into a separate StatefulWidget
class BranchCard extends StatefulWidget {
  final Map request;
  const BranchCard({super.key, required this.request});

  @override
  State<BranchCard> createState() => _BranchCardState();
}

class _BranchCardState extends State<BranchCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final String branchID = widget.request['branchId'] ?? 'No ID';
    final String ReleventRMbranch =
        widget.request['Relevent RO Branch'] ?? 'No RM';
    final String branchLocation =
        widget.request['branchLocation'] ?? 'No Location';

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        transformAlignment: Alignment.center,
        // Scale logic handles strictly within this widget now
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
            /// LEFT SIDE (branch info)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey.shade300,
                        child: const Icon(
                          Icons.business,
                          color: Colors.black87,
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
                  _infoRow("Location", branchLocation),
                  _infoRow("Relevant RM", ReleventRMbranch),
                ],
              ),
            ),

            /// RIGHT SIDE (actions)
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
                                      content: Text(
                                        'No internet connection',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'sfpro',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      duration: Duration(seconds: 5),
                                      backgroundColor: Colors.grey,
                                    ),
                                  );
                                  return;
                                } else {
                                  Savedatabeforedel_branch_ARM().SaveData(
                                    branchID,
                                    branchLocation,
                                    ReleventRMbranch,
                                    context,
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
                                  "ARM_branches",
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

/// Reusable Hover Button widget
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
        // FIXED: Ensure clicks are detected even if user clicks exactly on text or padding
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
