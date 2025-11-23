import 'package:firebase_dart/firebase_dart.dart';

class Deletebranchdata {
  late FirebaseDatabase _dt;

  Deletebranchdata() {
    // Make sure Firebase.app() is initialized in main()
    final app = Firebase.app();
    _dt = FirebaseDatabase(app: app);
  }

  Future<void> deleteData(String idnum, String branchType) async {
    try {
      final ref = _dt.reference().child(branchType).child(idnum);
      await ref.remove();
      print('Data deleted successfully');
    } catch (e) {
      print('Error deleting data: $e');
    }
  }
}
