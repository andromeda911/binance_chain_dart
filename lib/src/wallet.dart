import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:convert/convert.dart';
import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
//import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import './utils/crypto.dart';
import './utils/network.dart';
import './utils/num_utils.dart';
import './environment.dart';
import './http_client/http_client.dart';

class Wallet {
  String _privateKey;
  String _publicKey;
  String _address;
  bip32.BIP32 _bip32;
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
      _env = env;
      _bip32 = bip32.BIP32.fromPrivateKey(hex.decode(_privateKey), null);
      _publicKey = hex.encode(_bip32.publicKey);
      _address = getAddressFromPublicKey(_publicKey, env.hrp);
    } else {
      throw ArgumentError('Private key can`t be empty');
    }
  }

  Wallet.fromMnemonicPhrase(String mnemonicPhrase, BinanceEnvironment env) {
    if (bip39.validateMnemonic(mnemonicPhrase)) {
      var network = bitcoin;
      _bip32 = bip32.BIP32.fromSeed(bip39.mnemonicToSeed(mnemonicPhrase), bip32.NetworkType(bip32: bip32.Bip32Type(public: network.bip32.public, private: network.bip32.private), wif: network.wif)).derivePath("44'/714'/0'/0/0");

      _privateKey = hex.encode(_bip32.privateKey);
      _publicKey = hex.encode(_bip32.publicKey);
      _env = env;
      _address = getAddressFromPublicKey(_publicKey, env.hrp);
    } else {
      throw ArgumentError('Mnemonic Phrase is invalid');
    }
  }

  void initialize_wallet() async {
    if (_accountNumber == null) {
      var account = await httpClient.getAccount(_address);
      _accountNumber = account.load.accountNumber;
      _sequence = account.load.sequence;

      var nodeInfo = await httpClient.getNodeInfo();
      _chain_id = nodeInfo.load.network;
    }
  }

  Uint8List sign_message(Uint8List message) {
    var dsaSigner = ECDSASigner(SHA256Digest(), HMac(SHA256Digest(), 64))..init(true, PrivateKeyParameter(ECPrivateKey(BigInt.parse(privateKey, radix: 16), ECDomainParameters('secp256k1'))));

    ECSignature s = dsaSigner.generateSignature(message);

    var buffer = Uint8List(64);
    buffer.setRange(0, 32, encodeBigInt(s.r));
    buffer.setRange(32, 64, encodeBigInt(s.s));
    return buffer;
  }

  void increment_account_sequence() {
    if (_sequence != null) {
      _sequence += 1;
    }
  }
}
