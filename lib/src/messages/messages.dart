import 'package:binance_chain/src/proto/gen/dex.pb.dart';
import 'package:binance_chain/src/utils/crypto.dart';

import '../wallet.dart';
import 'dart:typed_data';
import 'package:convert/convert.dart';

// An identifier for tools triggering broadcast transactions, set to zero if unwilling to disclose.
var BROADCAST_SOURCE = 0;

class Msg {
  final AMINO_MESSAGE_TYPE = '';
  bool INCLUDE_AMINO_LENGTH_PREFIX = false;
  Wallet wallet;
  String memo;

  Msg(this.wallet, {this.memo = ''});

  Map to_map() => {};

  Map to_sign_map() => {};

  dynamic to_protobuf() => null;

  Uint8List to_amino() {
    var varint_length;
    var proto = to_protobuf();
    //## if type(proto) != bytes:
    //##         proto = proto.SerializeToString()

    var type_bytes = <int>[];
    if (AMINO_MESSAGE_TYPE.isNotEmpty) {
      type_bytes = hex.decode('CE6DC043');
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
}

class Signature {
  Msg _msg;
  var _chain_id;
  var _data;
  var _source;

  Signature(this._msg, [data]) {
    _chain_id = _msg.wallet.chain_id;
    _data = data;
    _source = BROADCAST_SOURCE;
  }

  String to_json() {
    return {
      'account_number': _msg.wallet.accountNumber.toString(),
      'chain_id': _chain_id,
      'data': _data,
      'memo': _msg.memo,
      'msgs': [_msg.to_dict()],
      'sequence': _msg.wallet.sequence.toString(),
      'source': _source
    }.toString();
  }

  Uint8List to_bytes_json() {
    return Uint8List.fromList(to_json().codeUnits);
  }

  dynamic sign() {}
}

class SignatureMsg extends Msg {
  @override
  final AMINO_MESSAGE_TYPE = null;
  final Signature _signature;

  SignatureMsg(msg) : super(msg.wallet) {
    _signature = Signature(msg);
  }

  StdSignature to_protobuf() {
    var pub_key_msg = PubKeyMsg(wallet);
    var std_sig = StdSignature();
    std_sig.sequence = wallet.sequence;
    std_sig.accountNumber = wallet.accountNumber;
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

  final SignatureMsg _signature;

  StdTxMsg(this._msg) : super(_msg.wallet) {
    _signature = SignatureMsg(_msg);
  }
}

//class TransferMsg()
