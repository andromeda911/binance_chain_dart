import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';

import 'environment.dart';
import 'messages/messages.dart';
import 'response_models.dart';

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

    return APIResponse(resp.statusCode,
        NodeInfo.fromJson(json.decode(resp.body)['node_info']));
  }

  Future<APIResponse> broadcastMsg(Msg msg) async {
    await msg.wallet.initialize_wallet();
    var resp = await _httpClient.post(_createFullPath('broadcast'),
        headers: <String, String>{'content-type': 'text/plain'},
        body: msg.to_hex_data());
    msg.wallet.increment_account_sequence();
    return APIResponse(resp.statusCode, json.decode(resp.body));
  }
}

class APIResponse {
  int status;
  dynamic load;
  APIResponse(this.status, this.load);
}
