import 'dart:collection';

import 'package:binance_chain/src/utils/num_utils.dart';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:binance_chain/src/proto/gen/dex.pb.dart';
import 'package:binance_chain/src/utils/crypto.dart';

import '../utils/crypto.dart';
import '../wallet.dart';
import 'dart:typed_data';
import 'package:convert/convert.dart';

// An identifier for tools triggering broadcast transactions, set to zero if unwilling to disclose.
var BROADCAST_SOURCE = 0;

class Msg {
  final AMINO_MESSAGE_TYPE = '';
  bool INCLUDE_AMINO_LENGTH_PREFIX = false;
  Wallet _wallet;
  String memo;

  Msg(this._wallet, [this.memo = '']);

  Wallet get wallet => _wallet;

  Map to_map() => {};

  Map to_sign_map() => {};

  dynamic to_protobuf() => null;

  Uint8List to_amino() {
    var varint_length;
    var proto = to_protobuf();
    if (proto.runtimeType != Uint8List) {
      proto = proto.writeToBuffer();
    }

    var type_bytes = <int>[];
    if (AMINO_MESSAGE_TYPE.isNotEmpty) {
      type_bytes = hex.decode(AMINO_MESSAGE_TYPE);
      varint_length = varint_encode(proto.length + type_bytes.length);
    } else {
      varint_length = varint_encode(proto.length);
    }
    var msg = <int>[];
    if (INCLUDE_AMINO_LENGTH_PREFIX) {
      msg += (varint_length);
    }
    msg = msg + type_bytes + proto;

    return Uint8List.fromList(msg);
  }

  String to_hex_data() {
    return hex.encode(StdTxMsg(this).to_amino());
  }
}

class Signature {
  Msg _msg;
  var _chain_id;
  var _data;
  var _source;

  Signature(this._msg, [data]) {
    _chain_id = _msg.wallet.chainId;
    _data = data;
    _source = BROADCAST_SOURCE;
  }

  String to_json() {
    return {
      'account_number': _msg.wallet.accountNumber.toString(),
      'chain_id': _chain_id,
      'data': _data,
      'memo': _msg.memo,
      'msgs': [_msg.to_map()],
      'sequence': _msg.wallet.sequence.toString(),
      'source': _source
    }.toString();
  }

  Uint8List to_bytes_json() {
    return Uint8List.fromList(to_json().codeUnits);
  }

  Uint8List sign(Wallet wallet) {
    //generate string to sign
    var json_bytes = to_bytes_json();

    var signed = wallet.sign_message(json_bytes);
    //return signed;
    return signed;
  }
}

class SignatureMsg extends Msg {
  @override
  final AMINO_MESSAGE_TYPE = '';
  Signature _signature;

  SignatureMsg(msg) : super(msg.wallet) {
    _signature = Signature(msg);
  }

  StdSignature to_protobuf() {
    var pub_key_msg = PubKeyMsg(wallet);
    var std_sig = StdSignature();
    std_sig.sequence = fixnum.Int64(wallet.sequence);
    std_sig.accountNumber = fixnum.Int64(wallet.accountNumber);
    std_sig.pubKey = pub_key_msg.to_amino();
    std_sig.signature = _signature.sign(wallet);
    return std_sig;
  }
}

class StdTxMsg extends Msg {
  @override
  final AMINO_MESSAGE_TYPE = 'F0625DEE';

  @override
  final INCLUDE_AMINO_LENGTH_PREFIX = true;

  final Msg _msg;

  final _source = BROADCAST_SOURCE;

  String _data;

  SignatureMsg _signature;

  StdTxMsg(this._msg, [this._data = '']) : super(_msg.wallet) {
    _signature = SignatureMsg(_msg);
  }

  StdTx to_protobuf() {
    var stdtx = StdTx();
    stdtx.msgs.add(_msg.to_amino().toList());
    stdtx.signatures.add(_signature.to_amino().toList());
    stdtx.data = _data.codeUnits;
    stdtx.memo = _msg.memo;
    stdtx.source = fixnum.Int64(_source);

    return stdtx;
  }
}

class PubKeyMsg extends Msg {
  @override
  final AMINO_MESSAGE_TYPE = 'EB5AE987';

  PubKeyMsg(Wallet wallet) : super(wallet);

  @override
  Uint8List to_protobuf() {
    return Uint8List.fromList(wallet.publicKey.codeUnits);
  }

  @override
  Uint8List to_amino() {
    var proto = to_protobuf();

    var type_bytes = hex.decode(AMINO_MESSAGE_TYPE);

    var varint_length = varint_encode(proto.length);

    var msg = type_bytes + varint_length + proto;

    return Uint8List.fromList(msg);
  }
}

class TransferMsg extends Msg {
  @override
  final AMINO_MESSAGE_TYPE = '2A2C87FA';

  String _symbol;
  double _amount;
  int _amountAmino;
  String _from_address;
  String _to_address;

  TransferMsg(
    this._symbol,
    this._amount,
    this._to_address,
    memo,
    wallet,
  ) : super(wallet, memo) {
    _from_address = wallet.address;
    _amountAmino = (_amount * 10.pow(8)).toInt();
  }

  @override
  Map to_map() {
    return LinkedHashMap.from({
      'inputs': [
        LinkedHashMap.from({
          'address': _from_address,
          'coins': [
            LinkedHashMap.from({'amount': _amountAmino, 'denom': _symbol})
          ]
        })
      ],
      'outputs': [
        LinkedHashMap.from({
          'address': _to_address,
          'coins': [
            LinkedHashMap.from({'amount': _amountAmino, 'denom': _symbol})
          ]
        })
      ]
    });
  }

  @override
  Map to_sign_map() {
    return {'to_address': _to_address, 'amount': _amount, 'denom': _symbol};
  }

  @override
  Send to_protobuf() {
    var token = Send_Token();
    token.denom = _symbol;
    token.amount = fixnum.Int64(_amountAmino);

    var input_addr = Send_Input();
    input_addr.address = decode_address(_from_address).toList();
    input_addr.coins.add(token);

    var output_addr = Send_Output();
    output_addr.address = decode_address(_to_address).toList();
    output_addr.coins.add(token);

    var msg = Send();
    msg.inputs.add(input_addr);
    msg.outputs.add(output_addr);

    return msg;
  }
}
