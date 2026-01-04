import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../users/screen/user_list_screen.dart';
import '../controller/user_select_controller.dart';

class UserSelectScreen extends StatelessWidget {
  UserSelectScreen({super.key});

  final UserSelectController controller = Get.put(UserSelectController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select User')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _btn(
            name: 'Ashir',
            uid: 'user_1',
            color: Colors.blue,
          ),
          const SizedBox(height: 20),
          _btn(
            name: 'Rahim',
            uid: 'user_2',
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _btn({
    required String name,
    required String uid,
    required Color color,
  }) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 16,
          ),
        ),
        onPressed: () {
          controller.selectUser(uid: uid, name: name);
          Get.offAll(() => UserListScreen());
        },
        child: Text(
          'Login as $name',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
