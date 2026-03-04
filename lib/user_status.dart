import 'user_data_services.dart';

class UserStatusService {

  static Future<Map<String, dynamic>> getUserStatus() async {

    final age = await UserDataServices.getUserAge();

    return {
      "age": age ?? 0,
      "steps": 0,
      "logins": 0,
      "distance": 0
    };

  }

}