/// HTTP client wrapper with retry and logging
library http_client;

import 'dart:async';
import 'package:http/http.dart' as http;

/// HTTP request method
enum HttpMethod { get, post, put, patch, delete }

/// HTTP response wrapper
class HttpResponse<T> {
  final int statusCode;
  final T body;
  final Map<String, String> headers;
  final DateTime timestamp;

  HttpResponse({
    required this.statusCode,
    required this.body,
    required this.headers,
  }) : timestamp = DateTime.now();

  /// Check if successful (200-299)
  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  /// Check if not found
  bool get isNotFound => statusCode == 404;

  /// Check if server error
  bool get isServerError => statusCode >= 500;
}

/// HTTP client with retry logic
class HttpClientWithRetry {
  final http.Client _client;
  final int maxRetries;
  final Duration retryDelay;

  HttpClientWithRetry({
    http.Client? client,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  }) : _client = client ?? http.Client();

  /// Make GET request
  Future<HttpResponse<String>> get(
    Uri url, {
    Map<String, String>? headers,
  }) async =>
      _retry(
        () => _client.get(url, headers: headers),
        url.toString(),
      );

  /// Make POST request
  Future<HttpResponse<String>> post(
    Uri url, {
    Map<String, String>? headers,
    dynamic body,
  }) async =>
      _retry(
        () => _client.post(url, headers: headers, body: body),
        url.toString(),
      );

  /// Make PUT request
  Future<HttpResponse<String>> put(
    Uri url, {
    Map<String, String>? headers,
    dynamic body,
  }) async =>
      _retry(
        () => _client.put(url, headers: headers, body: body),
        url.toString(),
      );

  /// Make DELETE request
  Future<HttpResponse<String>> delete(
    Uri url, {
    Map<String, String>? headers,
  }) async =>
      _retry(
        () => _client.delete(url, headers: headers),
        url.toString(),
      );

  /// Retry logic
  Future<HttpResponse<String>> _retry(
    Future<http.Response> Function() request,
    String url,
  ) async {
    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        final response = await request();
        return HttpResponse(
          statusCode: response.statusCode,
          body: response.body,
          headers: response.headers,
        );
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) rethrow;
        await Future.delayed(retryDelay * attempt);
      }
    }
    throw TimeoutException('Request failed after $maxRetries retries: $url');
  }

  /// Close client
  void close() => _client.close();
}
