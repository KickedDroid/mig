import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

Future<String> checkMachines() async {
  var box = Hive.box('myBox');
  var docs = await Firestore.instance
      .collection(box.get('companyId'))
      .orderBy('coolant-percent')
      .getDocuments();

  var doc = docs.documents.first;
  return doc.data['name'];
}
