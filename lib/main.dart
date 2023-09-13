import 'package:flutter/material.dart';
import 'package:sla_logger/sla_logger.dart';

void main() => runApp(const SLALoggerApp());

class SLALoggerApp extends StatefulWidget {
  const SLALoggerApp({super.key});

  @override
  State<SLALoggerApp> createState() => _SLALoggerAppState();
}

class _SLALoggerAppState extends State<SLALoggerApp> {
  final log = AppLog(SLALoggerApp);

  @override
  void initState() {
    const tag = "initState";
    super.initState();
    log.d(tag, "debug log");
    log.n(tag, "notice log");
    log.s(tag, "success log");
    log.w(tag, "warning log");
    log.e(tag, "error log", "exception");
    log.c(tag, "critical log", "exception");
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFFF7691F),
      ),
    );
  }
}
