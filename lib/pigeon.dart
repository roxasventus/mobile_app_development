import 'package:pigeon/pigeon.dart';

class PigeonUserDetails {
  String? name;
  int? age;
}

@HostApi()
abstract class PigeonApi {
  PigeonUserDetails? getUserDetails(String uid);
}
