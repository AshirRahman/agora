import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/users_controller.dart';
import '../model/app_user.dart';

class UserListScreen extends StatelessWidget {
  UserListScreen({super.key});

  final UsersController controller = Get.put(UsersController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: Obx(() {
        if (controller.users.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        return ListView.builder(
          itemCount: controller.users.length,
          itemBuilder: (context, index) {
            final AppUser user = controller.users[index];

            return ListTile(
              leading: CircleAvatar(
                child: Text(user.name[0]),
              ),
              title: Text(user.name),
              subtitle: Text(
                user.online ? 'Online' : 'Offline',
                style: TextStyle(
                  color: user.online ? Colors.green : Colors.grey,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.call),
                color: Colors.green,
                onPressed: () => controller.callUser(user),
              ),
            );
          },
        );
      }),
    );
  }
}
