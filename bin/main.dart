import 'dart:typed_data';

import 'package:binance_chain/src/environment.dart';
import 'package:binance_chain/src/http_client.dart';
import 'package:binance_chain/src/messages/messages.dart';
import 'package:binance_chain/src/utils/crypto.dart';
import 'package:pointycastle/export.dart';
import 'package:convert/convert.dart';

import 'package:binance_chain/src/wallet.dart';

void main(List<String> args) async {
  //var env = BinanceEnvironment.getTestnetEnv();
  var env = BinanceEnvironment.getProductionEnv();
  var client = HttpApiClient(env: env);
  var w = Wallet.fromMnemonicPhrase(
      'leisure thumb smoke skull deputy axis ozone odor group remain roof pole citizen alcohol carbon include annual grain motion gravity baby nation silent wealth',
      env);

  var t = TransferMsg(
      'BNB', 0.01, 'bnb1s76hyee7xvxksxlkc4whsmc3gxuqhrqvd3y0zm', 'thanks', w);

  print(w.address);
}
