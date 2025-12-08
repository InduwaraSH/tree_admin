import 'package:admin/COS_in_ARM.dart';
import 'package:admin/deleteRTdata.dart';
import 'package:admin/saveDataBeforeDel_Emp.dart';
import 'package:firebase_dart/firebase_dart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class AuthReg_EMP_ONLY {
  Future<void> registerUser(
    BuildContext context,
    String id,
    String password,
    String IDnum,
    String position,
    String office,
    String mobile,
    String name,
    email,
    nic,
  ) async {
    bool result = await InternetConnection().hasInternetAccess;
    if (!result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No internet connection',
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
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Waiting...',
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

      // Initialize Firebase app
      final app = Firebase.app();
      final auth = FirebaseAuth.instanceFor(app: app);

      // Create user
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save data before deletion
      await Savedatabeforedel()
          .SaveData(IDnum, position, office, mobile, name, email, nic)
          .whenComplete(() async {
            await CO_in_ARM().SaveData(IDnum, name, office, context);
          })
          .whenComplete(() async {
            await deleteRealtimeData().deleteData(IDnum);
          })
          .whenComplete(() {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'This Account Verification is Completed!',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'sfpro',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                duration: Duration(seconds: 5),
                backgroundColor: Colors.green,
              ),
            );
          });
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.code}");
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The password provided is too weak.',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'sfpro',
                fontWeight: FontWeight.bold,
              ),
            ),
            duration: Duration(seconds: 5),
            backgroundColor: Colors.red,
          ),
        );
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The account already exists for that email.',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'sfpro',
                fontWeight: FontWeight.bold,
              ),
            ),
            duration: Duration(seconds: 5),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }
}
