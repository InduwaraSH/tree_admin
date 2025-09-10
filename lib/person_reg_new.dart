import 'package:admin/deleteRTdata.dart';
import 'package:admin/registration.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class personrequest_new extends StatefulWidget {
  const personrequest_new({super.key});

  @override
  State<personrequest_new> createState() => _personrequest_newState();
}

class _personrequest_newState extends State<personrequest_new> {
  Query personRequestDbref = FirebaseDatabase.instance.ref().child("employees");

  String? hoveredKey; // Track hovered card

  Widget requestItem({required Map request}) {
    final String personId = request['employeeId'] ?? 'No ID';
    final String personName = request['employeeName'] ?? 'No Name';
    final String personPassword = request['employeePassword'] ?? 'No Password';
    final String mobileNumber = request['employeeMobile'] ?? 'No Mobile';
    final String jobPosition = request['employeePosition'] ?? 'No Job Position';
    final String office_location = request['employeeLocation'] ?? 'No Office';

    final String cardKey = request['key'];
    final bool isHovered = hoveredKey == cardKey;

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredKey = cardKey),
      onExit: (_) => setState(() => hoveredKey = null),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(isHovered ? 1.01 : 0.99),
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isHovered
                  ? Colors.blue.withOpacity(0.25)
                  : Colors.grey.withOpacity(0.15),
              blurRadius: isHovered ? 25 : 15,
              offset: Offset(0, 10),
            ),
          ],
        ),
        padding: EdgeInsets.all(22),
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
                      SizedBox(width: 10),
                      Text(
                        personName,
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'sfpro',
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18),

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
                _actionButton(
                  label: "Confirm",
                  color: Colors.green,
                  onPressed: () {
                    showCupertinoDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return CupertinoAlertDialog(
                          title: Text(
                            'Confirm Request',
                            style: TextStyle(
                              fontFamily: 'sfpro',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            'Are you sure you want to confirm $personName\'s request?',
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child: Text(
                                "Cancel",
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                            ),
                            CupertinoDialogAction(
                              child: Text(
                                "Confirm",
                                style: TextStyle(color: Colors.green),
                              ),
                              onPressed: () async {
                                Navigator.of(dialogContext).pop();
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
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: 14),
                _actionButton(
                  label: "Decline",
                  color: Colors.red,
                  onPressed: () {
                    showCupertinoDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return CupertinoAlertDialog(
                          title: Text(
                            'Decline Request',
                            style: TextStyle(
                              fontFamily: 'sfpro',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            'Are you sure you want to decline $personName\'s request?',
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child: Text(
                                "Cancel",
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                            ),
                            CupertinoDialogAction(
                              child: Text(
                                "Decline",
                                style: TextStyle(color: Colors.red),
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
              fontFamily: 'sfpro',
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
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

  Widget _actionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return _HoverButton(
      label: label,
      color: color,
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F7FD),
      body: FirebaseAnimatedList(
        query: personRequestDbref,
        itemBuilder:
            (
              BuildContext context,
              DataSnapshot datasnapshot,
              Animation<double> animation,
              int index,
            ) {
          if (datasnapshot.value != null) {
            Map request = Map<String, dynamic>.from(
              datasnapshot.value as Map,
            );
            request['key'] = datasnapshot.key;
            return requestItem(request: request);
          } else {
            return SizedBox();
          }
        },
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
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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