import 'package:cloud_firestore/cloud_firestore.dart';

class CloudFirestoreHelper {
  CloudFirestoreHelper._();
  static final CloudFirestoreHelper cloudFirestoreHelper =
      CloudFirestoreHelper._();

  static final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  late CollectionReference authorkepperRef;
  void connectwithCollection() {
    authorkepperRef = firebaseFirestore.collection('author');
  }

  Future<void> insertrecord({required Map<String, dynamic> data}) async {
    connectwithCollection();
    await authorkepperRef.doc().set(data);
  }

  Stream<QuerySnapshot> selectrecord() {
    connectwithCollection();
    return authorkepperRef.snapshots();
  }

  Future<void> updateRecords(
      {required String id, required Map<String, dynamic> data}) async {
    connectwithCollection();
    await authorkepperRef.doc(id).update(data);
  }

  Future<void> deleterecord({required String id}) async {
    connectwithCollection();

    await authorkepperRef.doc(id).delete();
  }
}
