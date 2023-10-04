import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/video_controller.dart';

class VideoScreen extends StatelessWidget {
  VideoScreen({super.key});

  final VideoController videoController = Get.put(VideoController());

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
