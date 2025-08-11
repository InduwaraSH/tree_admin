import 'package:admin/registration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class personrequest extends StatefulWidget {
  const personrequest({super.key});
  

  @override
  State<personrequest> createState() => _personrequestState();
}

class _personrequestState extends State<personrequest> {
  Query personRequestDbref = FirebaseDatabase.instance.ref().child("employees");

  Widget requestItem({required Map request}) {
    final String personId = request['employeeId'] ?? 'No ID';
    final String personName = request['employeeName'] ?? 'No Name';
    final String personPassword = request['employeePassword'] ?? 'No Password';
    final String mobileNumber = request['employeeMobile'] ?? 'No Mobile';
    final String jobPosition = request['employeePosition'] ?? 'No Job Position';

    

    return Align(
      alignment: Alignment.centerLeft,
      child: Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),

            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(31, 158, 158, 158),
                blurRadius: 10,
                offset: Offset(10, 10),
              ),
            ],
          ),
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_2_rounded,
                        size: 20,
                        color: Colors.black,
                      ),
                      SizedBox(width: 5),

                      Text(
                        (personName),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'sfpro',
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        "Id Number                ",
                        style: TextStyle(
                          fontSize: 18,

                          fontFamily: 'sfpro',
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        ":   $personId",
                        style: TextStyle(fontSize: 18, fontFamily: 'sfpro'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Password                 ",
                        style: TextStyle(
                          fontSize: 18,

                          fontFamily: 'sfpro',
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        ":   $personPassword",
                        style: TextStyle(fontSize: 18, fontFamily: 'sfpro'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Mobile Number        ",
                        style: TextStyle(
                          fontSize: 18,

                          fontFamily: 'sfpro',
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        ":   $mobileNumber",
                        style: TextStyle(fontSize: 18, fontFamily: 'sfpro'),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Text(
                        "Job Position             ",
                        style: TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'sfpro',
                        ),
                      ),
                      Text(
                        ":   $jobPosition",
                        style: TextStyle(fontSize: 18, fontFamily: 'sfpro'),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(width: 20),
              Column(
                children: [
                  CupertinoButton(
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
                                  'Cancel',
                                  style: TextStyle(
                                    fontFamily: 'sfpro',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(),
                              ),
                              CupertinoDialogAction(
                                child: Text(
                                  'Confirm',
                                  style: TextStyle(
                                    fontFamily: 'sfpro',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                onPressed: () async {
                                  // Add your confirm logic here
                                Navigator.of(dialogContext).pop();
                                 AuthReg().registerUser(context, "$personId@gmail.com", personPassword);
                                 
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    color: Colors.green,
                    child: Text(
                      "Confirm",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 20),

                  CupertinoButton(
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
                                  'Cancel',
                                  style: TextStyle(
                                    fontFamily: 'sfpro',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                onPressed: () async {},
                              ),
                              CupertinoDialogAction(
                                child: Text(
                                  'Decline',
                                  style: TextStyle(
                                    fontFamily: 'sfpro',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                onPressed: () {
                                  // Add your confirm logic here
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    color: Colors.red,
                    child: Text(
                      "Decline",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Person Requests')),
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
                return SizedBox(); // Placeholder if null
              }
            },
      ),
    );
  }
}
