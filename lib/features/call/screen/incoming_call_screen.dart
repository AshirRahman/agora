import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/call_controller.dart';

class IncomingCallScreen extends StatelessWidget {
  IncomingCallScreen({super.key});

  final CallController controller = Get.find<CallController>();

  @override
  Widget build(BuildContext context) {
    final call = controller.incomingCall.value!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              call.callerName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Incoming Call...',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _btn(
                  icon: Icons.call_end,
                  color: Colors.red,
                  onTap: controller.endCall,
                ),
                _btn(
                  icon: Icons.call,
                  color: Colors.green,
                  onTap: controller.acceptCall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _btn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 32,
        backgroundColor: color,
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }
}
