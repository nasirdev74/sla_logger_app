import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkUtils {
  /// check internet connection if available
  Future<bool> checkInternet() async {
    try {
      final status = await Connectivity().checkConnectivity();
      if (status == ConnectivityResult.mobile ||
          status == ConnectivityResult.wifi ||
          status == ConnectivityResult.ethernet) {
        return Future.value(true);
      }
      return Future.value(false);
    } catch (e) {
      log("checkInternet failed: $e");
      return Future.value(false);
    }
  }
}
