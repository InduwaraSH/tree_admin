import 'package:firebase_database/firebase_database.dart';

class Savedatabeforedel{

  
   
    DatabaseReference new_Employee_Data_Reference = FirebaseDatabase.instance.ref().child("employee_data_saved");



    Future<void> SaveData(String idnum,String position,String office,String mobile,String name) async {

       try {
           await new_Employee_Data_Reference.child(idnum).set({
               'employeeName': name,
               'employeePosition': position,
               'employeeOffice': office,
               'employeeMobile': mobile,
               
           });
           print('Data saved successfully');
       } catch (e) {
           print('Error saving data: $e');
       }
    }
}
