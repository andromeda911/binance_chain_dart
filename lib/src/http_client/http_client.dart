import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import '../environment.dart';
import '../messages/messages.dart';
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

  Future<APIResponse> _request(String method, String path, {Map<String, String> headers, dynamic body}) async {
    var url = _createFullPath(path);
    var resp;
    switch (method) {
      case 'post':
        resp = await _httpClient.post(url, headers: headers, body: body);
        break;
      case 'get':
        resp = await _httpClient.get(url, headers: headers);
        break;
    }

    return _handle_response(resp);
  }

  APIResponse _handle_response(Response response) {
    if (response.statusCode.toString().startsWith('2')) {
      try {
        var res = json.decode(response.body);
        if (res.containsKey('code') && ![0, '200000'].contains(res['code'])) {
          throw BinanceChainAPIException();
        }
        if (res.containsKey('success') && !res['success']) {
          throw BinanceChainAPIException();
        }
        return APIResponse(response.statusCode, res.containsKey('data') ? res['data'] : res);
      } catch (e) {
        throw BinanceChainRequestException('InvalidResponse ${response.body}');
      }
    } else {
      throw BinanceChainAPIException(response.body);
    }
  }

  Future<APIResponse<dynamic>> _post(String path, {Map<String, String> headers = const {}, dynamic body = ''}) async {
    return _request('post', path, headers: headers, body: body);
  }

  Future<APIResponse<dynamic>> _get(String path, {Map<String, String> headers}) async {
    return _request('get', path, headers: headers);
  }

  Future<APIResponse<Account>> getAccount(String address) async {
    var res = await _get('account/$address');
    res.load = Account.fromJson(res.load);
    return APIResponse.fromOther(res);
  }

  Future<APIResponse<NodeInfo>> getNodeInfo() async {
    var res = await _get('node-info');
    res.load = NodeInfo.fromJson(res.load);
    return APIResponse.fromOther(res);
  }

  Future<APIResponse<Transaction>> broadcastMsg(Msg msg) async {
    await msg.wallet.initialize_wallet();
    var res = await _post('broadcast', headers: <String, String>{'content-type': 'text/plain'}, body: msg.to_hex_data());
    msg.wallet.increment_account_sequence();
    res.load = Transaction.fromJson(res.load);
    return APIResponse.fromOther(res);
  }

  Future<APIResponse<TxPage>> getTransactions({@required String address, int blockHeight, int endTime, int limit, int offset, TxSide side, int startTime, String txAsset, TxType txType}) async {
    var path = "transactions?address=$address"
        "${blockHeight != null ? '&blockHeight=$blockHeight' : ''}"
        "${endTime != null ? '&endTime=$endTime' : ''}"
        "${limit != null ? '&limit=$limit' : ''}"
        "${offset != null ? '&offset=$offset' : ''}"
        "${side != null ? '&side=' + side.toString().substring(side.toString().indexOf('.') + 1) : ''}"
        "${startTime != null ? '&startTime=$startTime' : ''}"
        "${txAsset != null ? '&txAsset=$txAsset' : ''}"
        "${txType != null ? '&txType=' + txType.toString().substring(txType.toString().indexOf('.') + 1) : ''}";

    var res = await _get('transactions');

    res.load = Transaction.fromJson(res.load);
    return APIResponse.fromOther(res);
  }
}

class APIResponse<DataModel_T> {
  int statusCode;
  DataModel_T load;
  APIResponse(this.statusCode, this.load);

  APIResponse.fromOther(APIResponse other) {
    statusCode = other.statusCode;
    load = load;
  }
}

class BinanceChainAPIException implements Exception {
  String message;
  BinanceChainAPIException([this.message]);

  @override
  String toString() {
    if (message == null) return 'Exception';
    return 'Exception: $message';
  }
}

class BinanceChainRequestException implements Exception {
  String message;
  BinanceChainRequestException([this.message]);
  @override
  String toString() {
    if (message == null) return 'Exception';
    return 'Exception: $message';
  }
}

enum TxType { NEW_ORDER, ISSUE_TOKEN, BURN_TOKEN, LIST_TOKEN, CANCEL_ORDER, FREEZE_TOKEN, UN_FREEZE_TOKEN, TRANSFER, PROPOSAL, VOTE, MINT, DEPOSIT, CREATE_VALIDATOR, REMOVE_VALIDATOR, TIME_LOCK, TIME_UNLOCK, TIME_RELOCK, SET_ACCOUNT_FLAG, HTL_TRANSFER, CLAIM_HTL, DEPOSIT_HTL, REFUND_HTL }
enum TxSide { RECEIVE, SEND }
