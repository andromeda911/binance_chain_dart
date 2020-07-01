import 'dart:typed_data';

import 'package:binance_chain/src/environment.dart';
import 'package:binance_chain/src/http_client.dart';
import 'package:binance_chain/src/messages/messages.dart';
import 'package:binance_chain/src/utils/crypto.dart';
import 'package:pointycastle/export.dart';
import 'package:convert/convert.dart';

import 'package:binance_chain/src/wallet.dart';

void main(List<String> args) async {
  var w = Wallet.fromMnemonicPhrase(
      'leisure thumb smoke skull deputy axis ozone odor group remain roof pole citizen alcohol carbon include annual grain motion gravity baby nation silent wealth',
      BinanceEnvironment.getProductionEnv());

  var t = TransferMsg(
      'BNB', 2, 'bnb1s76hyee7xvxksxlkc4whsmc3gxuqhrqvd3y0zm', 'thanks', w);

  await t.wallet.initialize_wallet();

  print(t.wallet.accountNumber);
  //print(t.to_hex_data());

  //print(bech32_decode('bnb1s76hyee7xvxksxlkc4whsmc3gxuqhrqvd3y0zm'));
}
