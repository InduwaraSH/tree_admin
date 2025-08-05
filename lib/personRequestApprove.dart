import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class personrequest extends StatefulWidget {
  const personrequest({super.key});

  @override
  State<personrequest> createState() => _personrequestState();
}

class _personrequestState extends State<personrequest> {
  Query personRequestDbref = FirebaseDatabase.instance.ref().child("managers");

  Widget requestItem({required Map request}) {
    final String personId = request['managerId'] ?? 'No ID';
    final String personName = request['Manager Name'] ?? 'No Name';
    final String personPassword = request['Manager Password'] ?? 'No Password';

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(30),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        width: double.infinity,
        height: 185,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_2_rounded, size: 20, color: Colors.blue),
                    SizedBox(width: 5),

                    Text(
                      (request['managerName'] ?? "No ID"),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'sfpro',
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  "Person Name: " + (request['managerName'] ?? "No Name"),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'sfpro',
                  ),
                ),
                Text(
                  "Person Password: " +
                      (request['managerPassword'] ?? "No Password"),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'sfpro',
                  ),
                ),
              ],
            ),
            SizedBox(width: 20),
            Column(
              children: [
                CupertinoButton(
                  child: Text(
                    "Confirm Request",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {},
                  color: Colors.green,
                ),
                SizedBox(height: 20),

                CupertinoButton(
                  child: Text(
                    "Decline Request",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {},
                  color: Colors.red,
                ),
              ],
            ),
          ],
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
