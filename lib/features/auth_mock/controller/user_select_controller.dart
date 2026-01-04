import 'package:course_online/features/auth_mock/model/user_session.dart';
import 'package:get/get.dart';

class UserSelectController extends GetxController {
  RxString myUid = ''.obs;
  RxString myName = ''.obs;

  void selectUser({
    required String uid,
    required String name,
  }) {
    myUid.value = uid;
    myName.value = name;

    Get.put(
        UserSession(
          uid: uid,
          name: name,
        ),
        permanent: true);
  }
}
