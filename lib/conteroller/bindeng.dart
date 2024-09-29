import 'package:chat_app/conteroller/auth_controller.dart';
import 'package:get/get.dart';

class Bindeng implements Bindings{
  @override
  void dependencies() {
    Get.put(AuthController());
  }
}