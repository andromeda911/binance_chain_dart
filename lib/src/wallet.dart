import 'package:binance_chain/src/environment.dart';
import 'package:binance_chain/src/utils/crypto.dart';
import 'package:bitcoin_flutter/bitcoin_flutter.dart' as b_f;
import 'package:bip39/bip39.dart' as bip39;

class Wallet {
  String _privateKey;
  String _address;
  int accountNumber;

  BinanceEnvironment env;

  Wallet(String privateKey, BinanceEnvironment env) {
    if (privateKey.isNotEmpty) {
      _privateKey = privateKey;
      env = env;
      // bech32.segwit.encode()
    } else {
      throw ArgumentError('Private key can`t be empty');
    }
  }

  Wallet.fromMnemonicPhrase(String mnemonicPhrase, BinanceEnvironment env) {
    if (bip39.validateMnemonic(mnemonicPhrase)) {
      var w = b_f.HDWallet.fromSeed(bip39.mnemonicToSeed(mnemonicPhrase))
          .derivePath("44'/714'/0'/0/0");

      _privateKey = w.privKey;
      _address = getAddressFromPublicKey(w.privKey, env.hrp);
    } else {
      throw ArgumentError('Mnemonic Phrase is invalid');
    }
  }

  void initialize_wallet() {}
}
