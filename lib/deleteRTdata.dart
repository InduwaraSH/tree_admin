import 'package:firebase_database/firebase_database.dart';

class deleteRealtimeData {
  FirebaseDatabase dt = FirebaseDatabase.instance;
  DatabaseReference new_Employee_Data_Reference = FirebaseDatabase.instance
      .ref()
      .child("employee_data_saved");

  Future<void> deleteData(String idnum) async {
    try {
      await dt.ref().child("employees").child(idnum).remove();
      print('Data deleted successfully');
    } catch (e) {
      print('Error deleting data: $e');
    }
  }
}
