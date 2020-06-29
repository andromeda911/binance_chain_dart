import 'dart:convert';
import 'dart:io';

import 'package:binance_chain/src/environment.dart';
import 'package:binance_chain/src/response_models.dart';
import 'package:http/http.dart';

class HttpApiClient {
  BinanceEnvironment _env;
  final Client _httpClient = Client();

  HttpApiClient({BinanceEnvironment env}) {
    _env = env ?? BinanceEnvironment.getProductionEnv();
  }

  BinanceEnvironment get env => _env;

  String _createFullPath(String path) {
    return '${_env.apiUrl}/v1/$path';
  }

  Future<APIResponse> _request(String method, String path) async {
    //
    // switch (method) {
    //   case 'post':
    //     var resp = _httpClient.post(path);
    //     break;
    //   default:
    // }
    // await _httpClient.get(path)
  }

  Future<APIResponse> getAccount(String address) async {
    var resp = await _httpClient.get(_createFullPath('account/$address'));
    return APIResponse(
        resp.statusCode, Account.fromJson(json.decode(resp.body)));
  }

  Future<APIResponse> getNodeInfo() async {
    var resp = await _httpClient.get(_createFullPath('node-info'));
    return APIResponse(
        resp.statusCode, NodeInfo.fromJson(json.decode(resp.body)));
  }
}

class APIResponse {
  int status;
  dynamic load;
  APIResponse(this.status, this.load);
}
