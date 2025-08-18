import 'package:admin/deleteBranchdata.dart';
import 'package:admin/deleteRTdata.dart';
import 'package:admin/registration.dart';
import 'package:admin/saveDataBeforDel_Branch_ARM.dart';
import 'package:admin/saveDataBeforDel_Branch_RM.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class Branchrequestapprove_ARM extends StatefulWidget {
  const Branchrequestapprove_ARM({super.key});

  @override
  State<Branchrequestapprove_ARM> createState() => _Branchrequestapprove_ARMState();
}

class _Branchrequestapprove_ARMState extends State<Branchrequestapprove_ARM> {
  Query branchRequestDbref = FirebaseDatabase.instance.ref().child(
    "ARM_branches",
  );

  Widget requestItem({required Map request}) {
    final String branchID = request['branchId'] ?? 'No ID';
    final String ReleventRMbranch = request['Relevent RO Branch'] ?? 'No TP';
    final String branchLocation = request['branchLocation'] ?? 'No Location';
    //final String branchManager = request['branchManager'] ?? 'No Selected';

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
                  Container(
                    padding: EdgeInsets.only(
                      left: 10,
                      top: 5,
                      right: 10,
                      bottom: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 91, 91, 91),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_2_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                        SizedBox(width: 5),

                        Text(
                          (branchLocation),
                          style: TextStyle(
                            fontSize: 20,

                            fontFamily: 'sfpro',
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        "Branch Id                   ",
                        style: TextStyle(
                          fontSize: 18,

                          fontFamily: 'sfpro',
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        ":   $branchID",
                        style: TextStyle(fontSize: 18, fontFamily: 'sfpro'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Branch Location        ",
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'sfpro',
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        ":   $branchLocation",
                        style: TextStyle(fontSize: 18, fontFamily: 'sfpro'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "RM Location       ",
                        style: TextStyle(
                          fontSize: 18,

                          fontFamily: 'sfpro',
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        ":   $ReleventRMbranch",
                        style: TextStyle(fontSize: 18, fontFamily: 'sfpro'),
                      ),
                    ],
                  ),

                  // Row(
                  //   children: [
                  //     Text(
                  //       "Branch TP                  ",
                  //       style: TextStyle(
                  //         fontSize: 18,
                  //         fontStyle: FontStyle.italic,
                  //         fontFamily: 'sfpro',
                  //       ),
                  //     ),
                  //     Text(
                  //       ":   $branchTP",
                  //       style: TextStyle(fontSize: 18, fontFamily: 'sfpro'),
                  //     ),
                  //   ],
                  // ),
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
                              'Are you sure you want to confirm $branchLocation\'s request?',
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
                                  
                                  bool result = await InternetConnection()
                                      .hasInternetAccess;
                                  if (result == false) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
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
                                      context
                                      
                                    );
                                  }
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
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'sfpro',
                        fontWeight: FontWeight.bold,
                      ),
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
                              'Are you sure you want to decline $branchLocation\'s request?',
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
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                },
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
                                  Navigator.of(dialogContext).pop();
                                  Deletebranchdata().deleteData(branchID);
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
      appBar: AppBar(
        title: Text(
          'Branch Requests',
          style: TextStyle(fontFamily: 'sfpro', fontWeight: FontWeight.bold),
        ),
      ),
      body: FirebaseAnimatedList(
        query: branchRequestDbref,
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
