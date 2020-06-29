import 'package:binance_chain/src/environment.dart';
import '../lib/src/utils/crypto.dart';
import 'package:convert/convert.dart';

import 'package:binance_chain/src/wallet.dart';

void main(List<String> args) {
  var w = Wallet.fromMnemonicPhrase(
      "glimpse please library cloth sea curtain level broom relief mind visa hard oyster wonder blind nephew slice oven garbage embark shaft clap zoo mass",
      BinanceEnvironment.getProductionEnv());

  //print(w.address);
  print(hex.encode(w.sign_message('aaaaa')));

  //print(w.privateKey);
  //print(w.publicKey);
}
