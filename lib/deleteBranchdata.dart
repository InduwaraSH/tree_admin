import 'package:firebase_database/firebase_database.dart';

class Deletebranchdata{

  
    final FirebaseDatabase _dt = FirebaseDatabase.instance;
    //DatabaseReference new_Branch_Data_Reference = FirebaseDatabase.instance.ref().child("branches");



    Future<void> deleteData(String idnum, String branchType) async {

        try {
            await _dt.ref().child(branchType).child(idnum).remove();
            print('Data deleted successfully');
        } catch (e) {
            print('Error deleting data: $e');
        }
    }
}
