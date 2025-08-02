import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
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

    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(request['managerId'] ?? "No ID"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Person Requests')),
      body: FirebaseAnimatedList(
        query: personRequestDbref,
        itemBuilder: (BuildContext context, DataSnapshot datasnapshot, Animation<double> animation, int index) {
          if (datasnapshot.value != null) {
            Map request = Map<String, dynamic>.from(datasnapshot.value as Map);
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
