import 'package:course_online/features/auth_mock/screen/user_select_screen.dart';
import 'package:course_online/features/users/screen/user_list_screen.dart';
import 'package:get/get.dart';

class AppRoute {
  static String userListScreen = "/userListScreen";
  static String callScreen = "/callScreen";
  static String userSelectScreen = "/userSelectScreen";

  static String getUserListScreen() => userListScreen;
  static String getCallScreen() => callScreen;
  static String getUserSelectScreen() => userSelectScreen;

  static List<GetPage> routes = [
    GetPage(name: userSelectScreen, page: () => UserSelectScreen()),
  ];
}
