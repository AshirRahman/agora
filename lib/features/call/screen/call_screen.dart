import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import '../controller/call_controller.dart';

class CallScreen extends StatelessWidget {
  final String channelId;

  const CallScreen({super.key, required this.channelId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CallController>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        return Stack(
          children: [
            // Remote video view
            controller.remoteUid.value != 0
                ? AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: controller.engine,
                      canvas: VideoCanvas(uid: controller.remoteUid.value),
                      connection: RtcConnection(channelId: channelId),
                    ),
                  )
                : const Center(
                    child: Text(
                      'Waiting for user...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

            // Local video view
            Positioned(
              top: 40,
              right: 20,
              width: 120,
              height: 160,
              child: AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: controller.engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              ),
            ),

            // End call button
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton(
                  backgroundColor: Colors.red,
                  onPressed: controller.endCall,
                  child: const Icon(Icons.call_end),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
