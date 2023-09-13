import 'dart:developer';
import 'package:sla_logger/src/data/data.dart';
import 'package:sla_logger/src/models/models.dart';

class LogService {
  final apiClient = ApiClient();

  Future uploadLogs(
    List<DBLog> logs, {
    String? uploadPath,
    String? xApiKey,
  }) async {
    const tag = "uploadLogs";
    try {
      if (uploadPath != null) {
        await Future.value(
          apiClient.request(
            body: logs,
            url: uploadPath,
            xApiKey: xApiKey,
            method: Method.POST,
          ),
        );
      }
    } catch (e) {
      log("$tag: upload logs failed: $e");
      rethrow;
    }
  }
}
