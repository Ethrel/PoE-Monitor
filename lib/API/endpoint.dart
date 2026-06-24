import 'dart:convert';
import 'package:html/parser.dart';
import 'package:http/http.dart';

// ignore: constant_identifier_names
enum HTTPMethod { GET, POST }

class Endpoint {
  Endpoint({
    required String urlString,
    required HTTPMethod httpMethod,
  })  : _httpMethod = httpMethod,
        _urlString = urlString;

  final String _urlString;
  final HTTPMethod _httpMethod;

  Future<dynamic> getJSON({
    Map<String, String>? headers,
    Map<String, String>? body,
    Map<String, String>? urlReplacements,
    bool canRetry = true,
  }) async {
    headers ??= {};
    headers["accept"] = "application/json";

    Response? res = await _getResponse(headers: headers, body: body, urlReplacements: urlReplacements, canRetry: canRetry);
    if (res == null) return null;

    return jsonDecode(res.body);
  }

  Future<dynamic> getDOM({
    Map<String, String>? headers,
    Map<String, String>? body,
    Map<String, String>? urlReplacements,
    bool canRetry = true,
  }) async {
    headers ??= {};
    headers["accept"] = "text/html";

    Response? res = await _getResponse(headers: headers, body: body, urlReplacements: urlReplacements, canRetry: canRetry);
    if (res == null) return null;

    return parse(res.body);
  }

  Future<dynamic> _getResponse({
    Map<String, String>? headers,
    Map<String, String>? body,
    Map<String, String>? urlReplacements,
    bool canRetry = true,
  }) async {
    Uri url = Uri.parse(_interpolateNamed(_urlString, urlReplacements));
    headers ??= {};
    headers["user-agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36";

    Response res = await _sendRequest(url, headers, body, canRetry);
    if (res.statusCode == 200) {
      return res;
    } else {
      return null;
    }
  }

  Future<Response> _sendRequest(Uri url, Map<String, String>? headers, Map<String, String>? body, bool canRetry) async {
    Response res;
    do {
      switch (_httpMethod) {
        case HTTPMethod.POST:
          res = await _postRequest(url, headers, body);
          break;

        default:
          res = await _getRequest(url, headers);
          break;
      }
      if (res.statusCode == 429) {
        await Future.delayed(const Duration(seconds: 30));
      }
    } while (canRetry && res.statusCode == 429);
    return res;
  }

  String _interpolateNamed(String string, Map<String, String>? params) {
    String result = string;
    params?.forEach((String key, dynamic value) => result = result.replaceAll('%$key\$', value.toString()));

    return result;
  }

  Future<Response> _getRequest(Uri url, Map<String, String>? headers) async {
    Response res;
    res = await get(url, headers: headers);
    return res;
  }

  Future<Response> _postRequest(Uri url, Map<String, String>? headers, Map<String, dynamic>? body) async {
    Response res;

    headers ??= {};
    headers["Content-type"] = "application/json";
    res = await post(
      url,
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
    return res;
  }
}
