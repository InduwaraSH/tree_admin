import 'package:admin/deleteBranchdata.dart';
import 'package:firebase_dart/firebase_dart.dart';
import 'package:flutter/material.dart';

class Savedatabeforedel_branch {
  late DatabaseReference new_Branch_Data_Reference_RM;
  late DatabaseReference RM_Details_Reference;

  Savedatabeforedel_branch() {
    final app = Firebase.app(); // Ensure Firebase.app() is initialized
    final db = FirebaseDatabase(app: app);

    new_Branch_Data_Reference_RM = db.reference().child("RM_branch_data_saved");
    RM_Details_Reference = db.reference().child("RM_Details");
  }

  Future<void> SaveData(
    String idnum,
    String location,
    String manager,
    String tp,
    BuildContext context,
    String branchType,
  ) async {
    try {
      // Save basic branch data
      await new_Branch_Data_Reference_RM.child(location).set({
        "Manager": manager,
      });

      // Save detailed branch info
      await RM_Details_Reference.child(location).set({
        'branchID': idnum,
        'branchLocation': location,
        'branchManager': manager,
        'branchTP': tp,
      });

      // Delete original request
      await Deletebranchdata().deleteData(idnum, "RM_branches");

      // Show success notification
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
