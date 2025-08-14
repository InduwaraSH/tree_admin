import 'package:admin/deleteRTdata.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class AuthReg {
  //AuthReg(String s, String t);

  Future<void> registerUser(
    BuildContext context,
    String emailAddress,
    String password,
    String IDnum,
  ) async {
    bool result = await InternetConnection().hasInternetAccess;
    if (result == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
    } else {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
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
        
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailAddress,
          password: password,
        );
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
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
          //deleteRealtimeData().deleteData(IDnum);
      } on FirebaseAuthException catch (e) {
        print("FirebaseAuthException: ${e.code}");
        if (e.code == 'weak-password') {
          print('The password provided is too weak.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
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
          print('The account already exists for that email.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
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
        } else {
          
        }
      } catch (e) {
        print(e);
      }
    }
  }
}
