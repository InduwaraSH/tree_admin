import 'package:firebase_database/firebase_database.dart';

class Deletebranchdata{

  
    FirebaseDatabase dt = FirebaseDatabase.instance;
    DatabaseReference new_Branch_Data_Reference = FirebaseDatabase.instance.ref().child("branches");



    Future<void> deleteData(String idnum) async {

        try {
            await dt.ref().child("branches").child(idnum).remove();
            print('Data deleted successfully');
        } catch (e) {
            print('Error deleting data: $e');
        }
    }
}
