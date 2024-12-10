import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_mvvm/data/app_exception.dart';
import 'package:flutter_mvvm/data/network/base_api_services.dart';
import 'package:flutter_mvvm/shared/shared.dart';
import 'package:http/http.dart' as http;

// untuk request dan nerima response dari api

class NetworkApiServices implements BaseApiServices {
  @override
  Future getApiResponse(String endpoint) async {
    dynamic responseJSON;
    try {
      final response = await http.get(
          //tergantung dia http atau https
          Uri.https(Const.baseUrl, endpoint),
          headers: <String, String>{
            // untuk nerima sesuai kebutuhan api masing masing
            'Content-Type': 'application/json;charset=UTF-8',
            'key': Const.apiKey,
          });
      responseJSON = returnResponse(response);
    } on SocketException {
      throw NoInternetException('');
    } on TimeoutException {
      throw FetchDataException('Network rew=quest data timeout!');
    }

    return responseJSON;
  }

  @override
  Future postApiResponse(String url, data) {
    throw UnimplementedError();
  }

  dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 500:
      case 404:
        throw UnauthorisedException(response.body.toString());
      default:
        throw FetchDataException(
            'Error occured while communicating with server');
    }
  }
}
