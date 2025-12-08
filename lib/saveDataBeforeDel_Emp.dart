import 'dart:math';

import 'package:firebase_dart/firebase_dart.dart';

class Savedatabeforedel {
  Future<void> SaveData(
    String idnum,
    String position,
    String office,
    String mobile,
    String name,
    String email,
    String nic,
  ) async {
    try {
      // 1. Get the initialized Firebase App
      final app = Firebase.app();

      // 2. Initialize Database with the app
      final database = FirebaseDatabase(app: app);

      // 3. Create the reference (using .reference() instead of .ref())
      final DatabaseReference new_Employee_Data_Reference = database
          .reference()
          .child("employee_data_saved");

      await new_Employee_Data_Reference
          .child(idnum)
          .set({
            'employeeName': name,
            'employeePosition': position,
            'employeeOffice': office,
            'employeeMobile': mobile,
            'employeeEmail': email,
            'employeeNIC': nic,
          })
          .then((_) {
            DatabaseReference id_to_mail = database.reference().child(
              "Id_to_mail",
            );

            id_to_mail.child(idnum).set({'email': email});
          })
          .then((_) {
            DatabaseReference mail_to_id = database.reference().child(
              "Email_to_id",
            );

            mail_to_id.child(email.replaceAll('.', '_').toString()).set({
              'id': idnum,
            });
          });
      print('Data saved successfully');
    } catch (e) {
      print('Error saving data: $e');
    }
  }
}
