import 'package:firebase_dart/firebase_dart.dart';

class deleteRealtimeData {
  late FirebaseDatabase dt;
  late DatabaseReference new_Employee_Data_Reference;

  deleteRealtimeData() {
    final app = Firebase.app(); // Make sure Firebase.app() is initialized
    dt = FirebaseDatabase(app: app);
    new_Employee_Data_Reference = dt.reference().child("employee_data_saved");
  }

  Future<void> deleteData(String idnum) async {
    try {
      await dt.reference().child("employees").child(idnum).remove();
      print('Data deleted successfully');
    } catch (e) {
      print('Error deleting data: $e');
    }
  }
}
