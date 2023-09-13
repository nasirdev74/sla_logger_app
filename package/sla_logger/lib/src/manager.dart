import 'dart:async';
import 'package:sla_logger/.env.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sla_logger/src/data/data.dart';
import 'package:sla_logger/src/utils/utils.dart';
import 'package:sla_logger/src/models/models.dart';

import 'app_log.dart';

class LogManager {
  static String? _xApiKey;
  static String? _uploadPath;
  static final _log = AppLog(LogManager);
  static const _interval = Duration(seconds: 2);
  static final _database = LogDatabase.instance;
  static final _logService = LogService();
  static final _networkUtils = NetworkUtils();
  static final _periodicSubscription = Stream.periodic(_interval).listen((_) async {
    const tag = "_periodicSubscription";
    final logs = await _database.getAllLog();
    if (logs.length >= MAX_LOG_LIMIT && await _networkUtils.checkInternet()) {
      try {
        /// pause checking
        pause();

        /// upload logs
        await _uploadLogs(logs);

        /// resume the checking
        resume();
      } catch (e) {
        _log.e(tag, "pause - upload - resume failed", e);
      }
    }
  });

  /// pause checking
  static void pause() {
    const tag = "pause";
    try {
      _periodicSubscription.pause();
    } catch (e) {
      _log.e(tag, "pause checking failed", e);
    }
  }

  /// resume checking
  static void resume() {
    const tag = "resume";
    try {
      if (_periodicSubscription.isPaused) {
        _periodicSubscription.resume();
        _log.d(tag, "checking subscription resumed");
      }
    } catch (e) {
      _log.e(tag, "resume checking failed", e);
    }
  }

  /// upload logs
  static Future _uploadLogs(List<DBLog> logs) async {
    const tag = "_uploadLogs";
    try {
      /// upload it
      await _logService.uploadLogs(
        logs,
        xApiKey: _xApiKey,
        uploadPath: _uploadPath,
      );
      _log.s(tag, "${logs.length} logs uploaded");

      /// delete it
      await _deleteLogs(logs);

      /// resume
      resume();
    } catch (e) {
      _log.e(tag, "upload logs failed", e);
    }
  }

  /// delete logs
  static Future _deleteLogs(List<DBLog> logs) async {
    const tag = "_deleteLogs";
    try {
      for (var log in logs) {
        if (log.id != null) {
          await _database.deleteLogById(log.id!);
        }
      }
    } catch (e) {
      _log.e(tag, "delete logs failed", e);
    }
  }

  /// initiate log manager
  static void init({String? uploadPath, String? xApiKey}) {
    const tag = "init";
    _xApiKey = xApiKey;
    _uploadPath = uploadPath;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kIsWeb) return;
      try {
        resume();
        _log.s(tag, "log manager initiated");
      } catch (e) {
        _log.e(tag, "log manager init failed", e);
      }
    });
  }
}
