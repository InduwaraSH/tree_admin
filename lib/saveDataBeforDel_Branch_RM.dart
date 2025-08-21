import 'package:admin/deleteBranchdata.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Savedatabeforedel_branch {
  DatabaseReference new_Branch_Data_Reference_RM = FirebaseDatabase.instance
      .ref()
      .child("RM_branch_data_saved");

  DatabaseReference RM_Details_Reference = FirebaseDatabase.instance
      .ref()
      .child("RM_Details");

  Future<void> SaveData(
    String idnum,
    String location,
    String manager,
    String tp,
    BuildContext context,
    String branchType,
  ) async {
    try {
      await new_Branch_Data_Reference_RM
          .child(location)
          .set({"Manager": manager})
          .whenComplete(() {
            RM_Details_Reference.child(location).set({
              'branchID': idnum,
              'branchLocation': location,
              'branchManager': manager,
              'branchTP': tp,
            });
          })
          .whenComplete(
            () => Deletebranchdata().deleteData(idnum, "RM_branches"),
          )
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
