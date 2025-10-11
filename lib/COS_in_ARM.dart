import 'package:admin/deleteBranchdata.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CO_in_ARM {
  DatabaseReference new_Branch_Data_Reference_CO = FirebaseDatabase.instance
      .ref()
      .child("CO_branch_data_saved");

  DatabaseReference ARM_to_CO_Reference = FirebaseDatabase.instance.ref().child(
    "Connection ARM_CO",
  );

  Future<void> SaveData(
    String idnum,
    String name,
    String office,
    BuildContext context,
  ) async {
    try {
      await new_Branch_Data_Reference_CO
          .child(idnum)
          .set({"CO_location": office})
          .whenComplete(
            () => ARM_to_CO_Reference.child(
              office,
            ).child(idnum).set({'CO_Name': name, 'CO_ID': idnum}),
          )
          .whenComplete(() {
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     content: Text(
            //       'Branch data saved successfully',
            //       style: TextStyle(
            //         color: Colors.white,
            //         fontFamily: 'sfpro',
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //     duration: Duration(seconds: 2),
            //     backgroundColor: Colors.black,
            //   ),
            // );
            print("arm_CO done");
          });

      print('Data saved successfully');
    } catch (e) {
      print('Error saving data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error saving branch: $e',
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
    }
  }
}
