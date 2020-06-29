import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:bitcoin_flutter/bitcoin_flutter.dart' as b_f;
import 'package:bech32/bech32.dart' as bech32;
import 'package:bip32/bip32.dart' as bip32;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/digests/ripemd160.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:convert/convert.dart';

String CHARSET = "qpzry9x8gf2tvdw0s3jn54khce6mua7l";

int bech32_polymod(List values) {
  ///Internal function that computes the Bech32 checksum.

  final generator = [
    0x3b6a57b2,
    0x26508e6d,
    0x1ea119fa,
    0x3d4233dd,
    0x2a1462b3
  ];

  var chk = 1;
  int top;
  for (int value in values) {
    top = chk >> 25;
    chk = (chk & 0x1ffffff) << 5 ^ value;
    for (var i in [0, 1, 2, 3, 4]) {
      chk ^= ((top >> i) & 1) >= 1 ? generator[i] : 0;
    }
  }
  return chk;
}

Uint8List bech32_hrp_expand(String hrp) {
  /// Expand the HRP into values for checksum computation.

  var result = <int>[];
  result += List<int>.generate(hrp.length, (i) => hrp.codeUnitAt(i) >> 5);
  result += [0];
  result += List<int>.generate(hrp.length, (i) => hrp.codeUnitAt(i) & 31);

  return Uint8List.fromList(result);
}

Uint8List bech32_create_checksum(String hrp, Uint8List data) {
  ///Compute the checksum values given HRP and data.

  var values = bech32_hrp_expand(hrp) + data;

  var polymod = bech32_polymod(values + [0, 0, 0, 0, 0, 0]) ^ 1;

  var result = List<int>.generate(6, (i) => (polymod >> 5 * (5 - i)) & 31);

  return Uint8List.fromList(result);
}

String bech32_encode(String hrp, Uint8List data) {
  /// Compute a Bech32 string given HRP and data values.

  var combined = data + bech32_create_checksum(hrp, data);

  return hrp +
      '1' +
      List<String>.generate(combined.length, (i) => CHARSET[combined[i]])
          .join('');
}

Uint8List convertbits(Uint8List data, int frombits, int tobits, [pad = true]) {
  /// General power-of-2 base conversion.

  var acc = 0;
  var bits = 0;
  var result = <int>[];
  var maxv = (1 << tobits) - 1;
  var max_acc = (1 << (frombits + tobits - 1)) - 1;
  for (var value in data) {
    if (value < 0 || (value >> frombits) >= 1) {
      return null;
    }
    acc = ((acc << frombits) | value) & max_acc;
    bits += frombits;
    while (bits >= tobits) {
      bits -= tobits;
      result.add((acc >> bits) & maxv);
    }
  }
  if (pad) {
    if (bits != 0) {
      result.add((acc << (tobits - bits)) & maxv);
    }
  } else if (bits >= frombits || ((acc << (tobits - bits)) & maxv) >= 1) {
    return null;
  }
  return Uint8List.fromList(result);
}

String encode(String hrp, Uint8List witprog) {
  /// Encode a segwit address.

  return bech32_encode(hrp, convertbits(witprog, 8, 5));
}

dynamic getAddressFromPublicKey(String publicKey, [hrp = 'tbnb']) {
  final s = SHA256Digest().process(hex.decode(publicKey));
  final r = RIPEMD160Digest().process(s);

  return encode(hrp, r);
}

Uint8List varint_encode(int number) {
  var buf = <int>[];
  var towrite;
  while (true) {
    towrite = number & 0x7f;
    number >>= 7;
    if (number != 0) {
      buf += (towrite | 0x80);
    } else {
      buf += towrite;
      break;
    }
  }
  return buf;
}
