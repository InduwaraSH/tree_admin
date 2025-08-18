import 'package:firebase_database/firebase_database.dart';

class Deletebranchdata{

  
    FirebaseDatabase _dt = FirebaseDatabase.instance;
    //DatabaseReference new_Branch_Data_Reference = FirebaseDatabase.instance.ref().child("branches");



    Future<void> deleteData(String idnum) async {

        try {
            await _dt.ref().child("RO_branches").child(idnum).remove();
            print('Data deleted successfully');
        } catch (e) {
            print('Error deleting data: $e');
        }
    }
}
