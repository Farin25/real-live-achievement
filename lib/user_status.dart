import 'user_data_services.dart';
import 'location_service.dart';


class UserStatusService {

  static Future<Map<String, dynamic>> getUserStatus() async {

    final age = await UserDataServices.getUserAge();

    final country = await LocationService.getCurrentCountry();
    final distanceFromHome = await LocationService.getDistanceFromHome();

    return {
      "age": age ?? 0,
      "steps": 0,
      "logins": 0,
      "distance": 0
    };

  }

}