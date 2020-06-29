import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import './utils/crypto.dart';
import 'package:bitcoin_flutter/bitcoin_flutter.dart' as b_f;
import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
//import 'package:bitcoin_flutter/src/utils/magic_hash.dart';
import './environment.dart';
import './http_client.dart';
import "package:pointycastle/ecc/curves/secp256k1.dart";

class Wallet {
  String _privateKey;
  String _publicKey;
  String _address;
  b_f.HDWallet _bip32hdwallet;
  int _accountNumber;
  String _chain_id;
  int _sequence;
  BinanceEnvironment _env;
  HttpApiClient _httpClient;

  BinanceEnvironment get env => _env;

  String get address => _address;

  int get sequence => _sequence;

  String get privateKey => _privateKey;

  String get publicKey => _publicKey;

  int get accountNumber => _accountNumber;

  String get chainId => _chain_id;

  HttpApiClient get httpClient {
    _httpClient = _httpClient ?? HttpApiClient(env: _env);
    return _httpClient;
  }

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
      _bip32hdwallet = w;
      _privateKey = w.privKey;
      _publicKey = w.pubKey;
      _address = getAddressFromPublicKey(w.pubKey, env.hrp);
    } else {
      throw ArgumentError('Mnemonic Phrase is invalid');
    }
  }

  void initialize_wallet() async {
    if (_accountNumber != null) {
      var account = await httpClient.getAccount(_address);
      _accountNumber = account.load.account_number;
      _sequence = account.load.sequence;

      var nodeInfo = await httpClient.getNodeInfo();
      _chain_id = nodeInfo.load.network;
    }
  }

  Uint8List sign_message(String message) {
    var s = Signer("ECDSA");
    //return _bip32hdwallet.sign(message);
  }
}
