import 'package:admin/deleteRTdata.dart';
import 'package:admin/emp_reg.dart';
import 'package:admin/registration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_dart/firebase_dart.dart';

class personrequest_new extends StatefulWidget {
  const personrequest_new({super.key});

  @override
  State<personrequest_new> createState() => _personrequest_newState();
}

class _personrequest_newState extends State<personrequest_new> {
  late FirebaseDatabase _database;
  late DatabaseReference personRequestDbref;

  @override
  void initState() {
    super.initState();
    // Ensure Firebase.app() is initialized in main()
    final app = Firebase.app();
    _database = FirebaseDatabase(app: app);
    personRequestDbref = _database.reference().child("employees");
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
        stream: personRequestDbref.onValue,
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

              // FIXED: Use the isolated Widget class
              return PersonRequestCard(request: request);
            },
          );
        },
      ),
    );
  }
}

/// FIXED: Extracted Card to separate StatefulWidget to isolate hover state
class PersonRequestCard extends StatefulWidget {
  final Map request;
  const PersonRequestCard({super.key, required this.request});

  @override
  State<PersonRequestCard> createState() => _PersonRequestCardState();
}

class _PersonRequestCardState extends State<PersonRequestCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final String personId = widget.request['employeeId'] ?? 'No ID';
    final String personName = widget.request['employeeName'] ?? 'No Name';
    final String personPassword =
        widget.request['employeePassword'] ?? 'No Password';
    final String mobileNumber = widget.request['employeeMobile'] ?? 'No Mobile';
    final String jobPosition =
        widget.request['employeePosition'] ?? 'No Job Position';
    final String office_location =
        widget.request['employeeLocation'] ?? 'No Office';

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        // Scale handled strictly within this widget now
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()..scale(isHovered ? 1.01 : 1.0),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
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
            /// Left Section - User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Name Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(Icons.person, color: Colors.blue.shade700),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        personName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontFamily: "sfproRoundSemiB",
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  /// Info rows
                  _infoRow("ID Number", personId),
                  _infoRow("Password", personPassword),
                  _infoRow("Mobile Number", mobileNumber),
                  _infoRow("Job Position", jobPosition),
                  _infoRow("Working Office", office_location),
                ],
              ),
            ),

            /// Right Section - Buttons
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
                              fontFamily: "sfproRoundSemiB",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            'Are you sure you want to confirm $personName\'s request?',
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
                                if (jobPosition == "CO") {
                                  AuthReg_EMP_ONLY().registerUser(
                                    context,
                                    "$personId@gmail.com",
                                    personPassword,
                                    personId,
                                    jobPosition,
                                    office_location,
                                    mobileNumber,
                                    personName,
                                  );
                                } else {
                                  AuthReg().registerUser(
                                    context,
                                    "$personId@gmail.com",
                                    personPassword,
                                    personId,
                                    jobPosition,
                                    office_location,
                                    mobileNumber,
                                    personName,
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
                              fontFamily: "sfproRoundSemiB",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            'Are you sure you want to decline $personName\'s request?',
                            style: const TextStyle(
                              fontFamily: "sfproRoundSemiB",
                            ),
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "sfproRoundSemiB",
                                ),
                              ),
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                            ),
                            CupertinoDialogAction(
                              child: const Text(
                                "Decline",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontFamily: "sfproRoundSemiB",
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                deleteRealtimeData().deleteData(personId);
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
              fontFamily: "sfproRoundSemiB",
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
                fontFamily: 'sfproRoundSemiB',
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

/// Independent hoverable button widget
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
        // Added opaque behavior to ensure clicks are caught even on padding
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
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
              fontFamily: 'sfproRoundSemiB',
              fontWeight: FontWeight.bold,
              color: isHovered ? Colors.white : widget.color,
            ),
          ),
        ),
      ),
    );
  }
}
