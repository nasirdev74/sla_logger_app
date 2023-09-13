import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// http methods
enum Method { POST, GET, PUT, DELETE, PATCH }

/// api client class
/// used to make http request
class ApiClient {
  /// make an http request
  Future<dynamic> request({
    String? xApiKey,
    required String url,
    required dynamic body,
    method = Method.POST,
  }) async {
    const tag = "request";
    final client = http.Client();
    final Map<String, String> header = {
      "x-api-key": xApiKey ?? "",
      "Accept": "application/json",
      "Content-Type": "application/json",
    };

    try {
      /// http response holder
      http.Response? response;

      /// add base url
      final uri = Uri.parse(url);

      /// convert body to string
      final _body = json.encode(body);

      /// make the request based on method
      switch (method) {
        case Method.GET:
          response = await client.get(uri, headers: header);
          break;
        case Method.POST:
          response = await client.post(uri, headers: header, body: _body);
          break;
        case Method.PUT:
          response = await client.put(uri, headers: header, body: _body);
          break;
        case Method.DELETE:
          response = await client.delete(uri, headers: header, body: _body);
          break;
        case Method.PATCH:
          response = await client.patch(uri, headers: header, body: _body);
          break;
        default:
          response = await client.get(uri, headers: header);
          break;
      }

      /// print on console
      _showData(
        url: url,
        response: response.body,
        body: _body,
        method: method,
        header: header,
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 401 ||
          response.statusCode == 404 ||
          response.statusCode == 422 ||
          response.statusCode == 400) {
        var data = json.decode(response.body);
        client.close();
        if (data != null) {
          log("$tag: ------- [${url.split("/").lastOrNull}] [${response.statusCode}] : ${response.body}");
          return Future.value(data);
        }
        log("$tag: ------- [${url.split("/").lastOrNull}] [${response.statusCode}] failed: ${response.body}");
        throw Exception("request failed");
      } else {
        log("$tag: ------- [${url.split("/").lastOrNull}] [${response.statusCode}] server error: ${response.body}");
        throw Exception("server error");
      }
    } on TimeoutException catch (e) {
      log("$tag: request timeout: $e");
      throw Exception("Weak Connection");
    } on SocketException catch (e) {
      log("$tag: socket broken: $e");
      throw Exception("No Internet");
    } on Error catch (e) {
      log("$tag: catch error: $e");
      throw Exception("Error Occurred");
    }
  }

  /// print on console
  static void _showData({
    required String url,
    dynamic body,
    required Map<String, dynamic> header,
    required String response,
    required Method method,
  }) {
    const tag = "_showData";
    try {
      if (kDebugMode) {
        print('URL = $url');
        print('BODY = $body');
        print('HEADER = $header');
        print('METHOD = $method');
        print('RESPONSE = $response');
      }
    } catch (e) {
      log("$tag: print on console failed: $e");
    }
  }
}
