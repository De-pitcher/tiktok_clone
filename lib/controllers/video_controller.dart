import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../constants.dart';
import '../models/video.dart';

class VideoController extends GetxController {
  final Rx<List<Video>> _videoList = Rx<List<Video>>([]);

  List<Video> get videoList => _videoList.value;

  @override
  void onInit() {
    super.onInit();
    _videoList
        .bindStream(firestore.collection('videos').snapshots().map((event) {
      List<Video> retVal = [];
      for (var snap in event.docs) {
        retVal.add(Video.fromSnap(snap));
      }
      return retVal;
    }));
  }

  likeVideo(String id) async {
    DocumentSnapshot doc = await firestore.collection('videos').doc(id).get();
    var uid = authController.user.uid;
    if ((doc.data()! as dynamic)['likes'].contains(uid)) {
      await firestore.collection('videos').doc(id).update({
        'likes': FieldValue.arrayRemove([uid]),
      });
    } else {
      await firestore.collection('videos').doc(id).update({
        'likes': FieldValue.arrayUnion([uid]),
      });
    }
  }
}
