import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:energya_ind/core/helper/methods.dart';
import 'package:energya_ind/core/utils/global_functions.dart';
import 'package:flutter/material.dart';

class TagProvider with ChangeNotifier {
  Map<String, dynamic> tags = {}; //all tags
  Map<String, dynamic> filteredTags = {}; //tags with files
  bool load = false;

  fillFilteredTags(String projectName,
      Map<String, List<Map<String, dynamic>>> filteredOrders) {
    filteredTags[projectName] = filteredOrders;
    notifyListeners();
  }

  //to save in cache (shared_preferences)
  Future<void> addTag(
    context, {
    required String project,
    required String order,
    required String release,
  }) async {
    //tags = await SharedPrefs().getJsonFromString('tags');
    //notifyListeners();
    pr('projName: $project, orderName: $order, releaseName: $release');
    await addTagToFirestore(context, project, order, release);
  }

// save at Firestore
  Future<void> addTagToFirestore(
      context, String project, String order, String release) async {
    try {
      // الحصول على المرجعية لمجموعة الـ tags في Firestore
      CollectionReference tagsCollection =
          FirebaseFirestore.instance.collection('tags');

      // الحصول على مستند خاص بالمشروع والـ order
      DocumentReference projectDoc = tagsCollection.doc(project);

      CollectionReference ordersCollection = projectDoc.collection('orders');

      DocumentReference orderDoc = ordersCollection.doc(order);

      // إنشاء المستند الأب إذا لم يكن موجودًا
      await projectDoc.set(<String, dynamic>{}, SetOptions(merge: true));

      // استرجاع البيانات الحالية للـ order إذا كانت موجودة
      DocumentSnapshot orderSnapshot = await orderDoc.get();

      if (!orderSnapshot.exists) {
        // إذا لم يكن هناك مستند للـ order، أنشئ واحد جديد

        await orderDoc.set({
          'releases': [
            {'release': release, 'file': {}}, // إضافة الـ release كـ map
          ],
        });
        GlobalFunctions().showTopSnackBar(
          context,
          'New Release Was Created Successfully !',
          error: false,
        );
      } else {
        // إذا كان المستند موجودًا، أضف الـ release إذا لم يكن موجودًا
        List<dynamic> releases = List.from(orderSnapshot['releases']);

        // التحقق إذا كان الـ release موجودًا بالفعل
        bool releaseExists = releases
            .any((r) => r is Map<String, dynamic> && r['release'] == release);

        if (!releaseExists) {
          releases.add(
              {'release': release, 'file': {}}); // إضافة release جديد كـ map

          // تحديث المستند في Firestore
          await orderDoc.update({
            'releases': releases,
          });
          pr('&&&&&&&s');
          GlobalFunctions().showTopSnackBar(
            context,
            'New Release Was Created Successfully !',
            error: false,
          );
          pr('Tag added to Firestore successfully!');
        } else {
          GlobalFunctions().showTopSnackBar(
            context,
            'There is a release similar to the input !',
            error: true,
          );
          pr('Tag added to Firestore successfully!');
        }
      }
    } catch (e) {
      pr('Error adding tag to Firestore: $e');
    }
  }

//get list of Project_Names if key is 'Proj'
//get list of Order_Names if key is 'Ord'
  Future<List<String>> getTagsKeys(
    String key, {
    String? projectName,
    //String? orderName,
  }) async {
    //Map<String, dynamic> tags = await SharedPrefs().getJsonFromString('tags');
    tags = await getAllTagsData();
    pr('tags: $tags');
    //{Project1: {Order1: [Release1]}}
    if (key == 'Proj') {
      pr('projects: ${tags.keys.toList()}');
      return tags.keys.toList();
    } else if (key == 'Ord') {
      pr('orders:${tags[projectName]}');
      return (tags[projectName] as Map<String, dynamic>).keys.toList();
    } else {
      return [];
    }
  }

//get all tags from Firestore
  Future<Map<String, dynamic>> getAllTagsData() async {
    try {
      load = true;
      // الحصول على المرجعية لمجموعة الـ tags
      CollectionReference tagsCollection =
          FirebaseFirestore.instance.collection('tags');

      // جلب جميع الوثائق من مجموعة الـ tags
      QuerySnapshot tagsSnapshot = await tagsCollection.get();

      // إنشاء Map لتخزين البيانات المطلوبة
      Map<String, Map<String, List<Map<String, dynamic>>>> allTagsData = {};

      // التنقل عبر كل الوثائق في مجموعة الـ tags
      for (var tagDoc in tagsSnapshot.docs) {
        // التأكد من وجود الـ document
        if (!tagDoc.exists) {
          pr('Document ${tagDoc.id} does not exist!');
          continue; // تخطي هذا المستند إذا لم يكن موجودًا
        }

        // للحصول على بيانات الـ orders الخاصة بالـ tag
        CollectionReference ordersCollection =
            tagDoc.reference.collection('orders');
        QuerySnapshot ordersSnapshot = await ordersCollection.get();

        // إذا لم يكن هناك أي بيانات في orders
        if (ordersSnapshot.docs.isEmpty) {
          pr('No orders found for tag ${tagDoc.id}');
          continue;
        }

        // إنشاء Map لتخزين البيانات الخاصة بكل order ضمن الـ tag
        Map<String, List<Map<String, dynamic>>> ordersData = {};

        // التنقل عبر كل الوثائق في مجموعة الـ orders
        for (var orderDoc in ordersSnapshot.docs) {
          // التأكد من وجود الـ order
          if (!orderDoc.exists) {
            pr('Order document ${orderDoc.id} does not exist!');
            continue; // تخطي الـ order إذا لم يكن موجودًا
          }

          // استخراج الحقل 'releases' من الـ order
          var releases = orderDoc['releases'] ?? [];

          // التحقق إذا كانت releases قائمة وتحتوي على خرائط
          if (releases is List && releases.isNotEmpty) {
            // استخراج القيم من الخرائط
            List<Map<String, dynamic>> releaseValues = releases
                .where((r) =>
                    r is Map<String, dynamic> &&
                    r.containsKey('release') &&
                    r.containsKey('file'))
                .map((r) => {'release': r['release'], 'file': r['file']})
                .toList();

            if (releaseValues.isNotEmpty) {
              // إضافة الـ releases إلى الـ Map الخاص بـ order
              ordersData[orderDoc.id] = releaseValues;
            }
          }
        }

        // إذا تم العثور على بيانات للـ tag
        if (ordersData.isNotEmpty) {
          allTagsData[tagDoc.id] = ordersData;
        }
      }

      // طباعة البيانات النهائية
      // pr('All Tags Data: $allTagsData');
      tags = allTagsData; // تأكد من أن `tags` لديها نفس النوع الجديد
      load = false;
      notifyListeners();
      return allTagsData;
    } catch (e) {
      pr('Error getting data: $e');
      load = false;
      return {};
    }
  }
}
