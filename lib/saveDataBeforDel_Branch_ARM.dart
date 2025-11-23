import 'package:admin/deleteBranchdata.dart';
import 'package:firebase_dart/firebase_dart.dart';
import 'package:flutter/material.dart';

class Savedatabeforedel_branch_ARM {
  late DatabaseReference new_Branch_Data_Reference_ARM;
  late DatabaseReference RM_to_ARM_Reference;
  late DatabaseReference ARM_Details_Reference;

  Savedatabeforedel_branch_ARM() {
    final app = Firebase.app(); // Make sure Firebase.app() is initialized
    final db = FirebaseDatabase(app: app);

    new_Branch_Data_Reference_ARM = db.reference().child(
      "ARM_branch_data_saved",
    );
    RM_to_ARM_Reference = db.reference().child("Connection RM_ARM");
    ARM_Details_Reference = db.reference().child("ARM_Details");
  }

  Future<void> SaveData(
    String idnum,
    String branchLocation,
    String RelevantRMbranch,
    BuildContext context,
  ) async {
    try {
      // Save in ARM_branch_data_saved
      await new_Branch_Data_Reference_ARM.child(branchLocation).set({
        "ARM_branchID": idnum,
      });

      // Save connection RM -> ARM
      await RM_to_ARM_Reference.child(
        RelevantRMbranch,
      ).child(branchLocation).set({'ARM_branchID': idnum});

      // Save branch details
      await ARM_Details_Reference.child(idnum).set({
        'branchID': idnum,
        'branchLocation': branchLocation,
        'ReleventRMbranch': RelevantRMbranch,
      });

      // Delete original request
      await Deletebranchdata().deleteData(idnum, "ARM_branches");

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Branch data saved successfully',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'sfpro',
              fontWeight: FontWeight.bold,
            ),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.black,
        ),
      );

      print('Data saved successfully');
    } catch (e) {
      print('Error saving data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error saving branch: $e',
            style: const TextStyle(
              color: Colors.black,
              fontFamily: 'sfpro',
              fontWeight: FontWeight.bold,
            ),
          ),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.grey,
        ),
      );
    }
  }
}
