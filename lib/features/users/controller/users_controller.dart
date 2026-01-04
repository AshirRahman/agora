import 'package:course_online/features/auth_mock/model/user_session.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/app_user.dart';
import '../../call/controller/call_controller.dart';

class UsersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final UserSession session;

  RxList<AppUser> users = <AppUser>[].obs;

  @override
  void onInit() {
    super.onInit();
    session = Get.find<UserSession>();

    fetchUsers();

    Get.put(CallController(
      myUid: session.uid,
      myName: session.name,
    ));
  }

  void fetchUsers() {
    _firestore.collection('users').snapshots().listen((snapshot) {
      users.value = snapshot.docs
          .map((doc) => AppUser.fromJson(doc.data(), doc.id))
          .where((u) => u.uid != session.uid)
          .toList();
    });
  }

  void callUser(AppUser user) {
    Get.find<CallController>().startCall(
      receiverId: user.uid,
      receiverName: user.name,
    );
  }
}
