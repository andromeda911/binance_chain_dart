import 'dart:typed_data';
import 'package:pointycastle/export.dart';

import './utils/crypto.dart';
import './utils/num_utils.dart';
import 'package:bitcoin_flutter/bitcoin_flutter.dart' as b_f;
import 'package:bip39/bip39.dart' as bip39;
import './environment.dart';
import './http_client.dart';

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

  Uint8List sign_message(Uint8List message) {
    var dsaSigner = ECDSASigner(SHA256Digest(), HMac(SHA256Digest(), 64))
      ..init(
          true,
          PrivateKeyParameter(ECPrivateKey(BigInt.parse(privateKey, radix: 16),
              ECDomainParameters('secp256k1'))));

    ECSignature s = dsaSigner.generateSignature(message);

    var buffer = Uint8List(64);
    buffer.setRange(0, 32, encodeBigInt(s.r));
    buffer.setRange(32, 64, encodeBigInt(s.s));
    return buffer;
  }
}
