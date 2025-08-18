import 'package:admin/deleteBranchdata.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Savedatabeforedel_branch {
  DatabaseReference new_Branch_Data_Reference = FirebaseDatabase.instance
      .ref()
      .child("RO_branch_data_saved");

  Future<void> SaveData(
    String idnum,
    String location,
    String manager,
    String tp,
    BuildContext context,
  ) async {
    try {
      await new_Branch_Data_Reference
          .child(idnum)
          .set({
            'branchID': idnum,
            'branchLocation': location,
            'branchManager': manager,
            'branchTP': tp,
          })
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
