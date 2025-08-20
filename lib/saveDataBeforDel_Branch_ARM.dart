import 'package:admin/deleteBranchdata.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Savedatabeforedel_branch_ARM {
  DatabaseReference new_Branch_Data_Reference_ARM = FirebaseDatabase.instance
      .ref()
      .child("ARM_branch_data_saved");

  DatabaseReference RM_to_ARM_Reference = FirebaseDatabase.instance
      .ref()
      .child("Connection RM_ARM");

  Future<void> SaveData(
    String idnum,
    String branchLocation,
    String RelevantRMbranch,
    BuildContext context,
  ) async {
    try {
      await new_Branch_Data_Reference_ARM
          .child(branchLocation)
          .set({
            'branchID': idnum,
            'branchLocation': branchLocation,
            'ReleventRMbranch': RelevantRMbranch,
          }).whenComplete(() => RM_to_ARM_Reference.child(RelevantRMbranch).child(branchLocation).set({
            'ARM_branchID': idnum,
            
          }))
          .whenComplete(() => Deletebranchdata().deleteData(idnum))
          .whenComplete(() {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
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
