import 'package:firebase_dart/firebase_dart.dart';
import 'package:flutter/material.dart';

class CO_in_ARM {
  Future<void> SaveData(
    String idnum,
    String name,
    String office,
    BuildContext context,
  ) async {
    try {
      // 1. Initialize Database instance using the app
      final app = Firebase.app();
      final database = FirebaseDatabase(app: app);

      // 2. Define References
      final DatabaseReference new_Branch_Data_Reference_CO = database
          .reference()
          .child("CO_branch_data_saved");

      final DatabaseReference ARM_to_CO_Reference = database.reference().child(
        "Connection ARM_CO",
      );

      // 3. Perform Operations
      await new_Branch_Data_Reference_CO
          .child(idnum)
          .set({"CO_location": office})
          .whenComplete(() async {
            // Nested write operation on completion
            await ARM_to_CO_Reference.child(
              office,
            ).child(idnum).set({'CO_Name': name, 'CO_ID': idnum});

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
