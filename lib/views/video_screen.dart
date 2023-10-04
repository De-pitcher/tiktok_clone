import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/video_controller.dart';

class VideoScreen extends StatelessWidget {
  VideoScreen({super.key});

  final VideoController videoController = Get.put(VideoController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => PageView.builder(
          itemCount: videoController.videoList.length,
          itemBuilder: (context, index) {
            final data = videoController.videoList[index];
            return Stack(
              children: [],
            );
          },
        ),
      ),
    );
  }
}
