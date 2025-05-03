import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../class/statusrequest.dart';

class Crud {
  // Default headers for API requests
  Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Update headers (useful for adding auth tokens)
  void updateHeaders(Map<String, String> newHeaders) {
    _headers.addAll(newHeaders);
  }

  // GET Request
  Future<Either<StatusRequest, dynamic>> getData(String linkurl) async {
    try {
      var response = await http.get(
        Uri.parse(linkurl),
        headers: _headers,
      );

      if (_isSuccessful(response.statusCode)) {
        // Parse response directly as it might be a List or Map
        var decodedBody = jsonDecode(response.body);
        return Right(decodedBody);
      } else {
        return _handleErrorResponse(response);
      }
    } catch (e) {
      return _handleException(e);
    }
  }
  // POST Request
  Future<Either<StatusRequest, Map>> postData(String linkurl, Map data) async {
    try {
      var response = await http.post(
        Uri.parse(linkurl),
        body: jsonEncode(data),
        headers: _headers,
      );

      if (_isSuccessful(response.statusCode)) {
        Map<String, dynamic> responsebody = jsonDecode(response.body);
        return Right(responsebody);
      } else {
        return _handleErrorResponse(response);
      }
    } catch (e) {
      return _handleException(e);
    }
  }

  // PUT Request
  Future<Either<StatusRequest, Map>> putData(String linkurl, Map data) async {
    try {
      var response = await http.put(
        Uri.parse(linkurl),
        body: jsonEncode(data),
        headers: _headers,
      );

      if (_isSuccessful(response.statusCode)) {
        Map<String, dynamic> responsebody = jsonDecode(response.body);
        return Right(responsebody);
      } else {
        return _handleErrorResponse(response);
      }
    } catch (e) {
      return _handleException(e);
    }
  }

  // DELETE Request
  Future<Either<StatusRequest, Map>> deleteData(String linkurl) async {
    try {
      var response = await http.delete(
        Uri.parse(linkurl),
        headers: _headers,
      );

      if (_isSuccessful(response.statusCode)) {
        Map<String, dynamic> responsebody = jsonDecode(response.body);
        return Right(responsebody);
      } else {
        return _handleErrorResponse(response);
      }
    } catch (e) {
      return _handleException(e);
    }
  }

  // Check if status code indicates success
  bool _isSuccessful(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  // Handle HTTP error responses
  Either<StatusRequest, Map> _handleErrorResponse(http.Response response) {
    print('HTTP Error: ${response.statusCode} - ${response.body}');
    switch (response.statusCode) {
      case 400:
        return const Left(StatusRequest.badRequest);
      case 401:
        return const Left(StatusRequest.unauthorized);
      case 403:
        return const Left(StatusRequest.forbidden);
      case 404:
        return const Left(StatusRequest.notFound);
      case 500:
        return const Left(StatusRequest.serverfailure);
      default:
        return const Left(StatusRequest.serverfailure);
    }
  }

  // Handle exceptions
  Either<StatusRequest, Map> _handleException(dynamic e) {
    print('Exception occurred: $e');
    if (e is http.ClientException) {
      return const Left(StatusRequest.offlinefailure);
    }
    return const Left(StatusRequest.error);
  }
}