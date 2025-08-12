import 'package:firebase_database/firebase_database.dart';

class deleteRealtimeData{
    FirebaseDatabase dt = FirebaseDatabase.instance;

    Future<void> deleteData(String path) async {
        try {
            await dt.ref().child("employees").child(path).remove();
            print('Data deleted successfully');
        } catch (e) {
            print('Error deleting data: $e');
        }
    }
}
