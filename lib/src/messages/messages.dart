import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:convert/convert.dart';

import '../utils/num_utils.dart';
import '../utils/constants.dart';
import '../utils/crypto.dart';
import '../wallet.dart';
import './proto/gen/dex.pb.dart';

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
    return json.encode(LinkedHashMap.from({
      'account_number': _msg.wallet.accountNumber.toString(),
      'chain_id': _chain_id,
      'data': _data,
      'memo': _msg.memo,
      'msgs': [_msg.to_map()],
      'sequence': _msg.wallet.sequence.toString(),
      'source': _source.toString()
    }));
  }

  Uint8List to_bytes_json() {
    return Uint8List.fromList(utf8.encode(to_json()));
  }

  Uint8List sign(Wallet wallet) {
    //generate string to sign
    var json_bytes = to_bytes_json();

    var signed = wallet.sign_message(json_bytes);
    return signed;
  }
}

class SignatureMsg extends Msg {
  @override
  final AMINO_MESSAGE_TYPE = '';
  Signature _signature;
  Signature get signature => _signature;
  SignatureMsg(msg) : super(msg.wallet) {
    _signature = Signature(msg);
  }

  StdSignature to_protobuf() {
    var pub_key_msg = PubKeyMsg(wallet);
    var std_sig = StdSignature()
      ..sequence = fixnum.Int64(wallet.sequence)
      ..accountNumber = fixnum.Int64(wallet.accountNumber)
      ..pubKey = pub_key_msg.to_amino()
      ..signature = _signature.sign(wallet);
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
  SignatureMsg get signature => _signature;
  SignatureMsg _signature;
  StdTxMsg(this._msg, [this._data = '']) : super(_msg.wallet) {
    _signature = SignatureMsg(_msg);
  }

  StdTx to_protobuf() {
    var stdtx = StdTx()
      ..msgs.add(_msg.to_amino().toList())
      ..signatures.add(_signature.to_amino().toList())
      ..data = _data.codeUnits
      ..memo = _msg.memo
      ..source = fixnum.Int64(_source);

    return stdtx;
  }
}

class PubKeyMsg extends Msg {
  @override
  final AMINO_MESSAGE_TYPE = 'EB5AE987';

  PubKeyMsg(Wallet wallet) : super(wallet);

  @override
  Uint8List to_protobuf() {
    return Uint8List.fromList(hex.decode(wallet.publicKey));
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
  String _memo;

  TransferMsg({
    String symbol,
    double amount,
    String to_address,
    String memo,
    Wallet wallet,
  }) : super(wallet, memo) {
    _symbol = symbol;
    _amount = amount;
    _to_address = to_address;
    _wallet = wallet;
    _memo = memo ?? '';
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
    var token = Send_Token()
      ..denom = _symbol
      ..amount = fixnum.Int64(_amountAmino);

    var input_addr = Send_Input()
      ..address = decode_address(_from_address).toList()
      ..coins.add(token);

    var output_addr = Send_Output()
      ..address = decode_address(_to_address).toList()
      ..coins.add(token);

    var msg = Send()..inputs.add(input_addr)..outputs.add(output_addr);

    return msg;
  }
}

class NewOrderMsg extends Msg {
  @override
  final AMINO_MESSAGE_TYPE = 'CE6DC043';

  String _symbol;
  int _time_in_force;
  int _order_type;
  int _side;
  double _price;
  int _price_encoded;
  double _quantity;
  int _quantity_encoded;

  NewOrderMsg({String symbol, TimeInForce time_in_force, OrderType order_type, OrderSide side, double price, double quantity, Wallet wallet}) : super(wallet) {
    _symbol = symbol;
    _time_in_force = time_in_force.value;
    _order_type = order_type.value;
    _side = side.value;
    _price = price;
    _price_encoded = (_price * 10.pow(8)).toInt();
    _quantity = quantity;
    _quantity_encoded = (_quantity * 10.pow(8)).toInt();
  }
  @override
  Map to_map() {
    return LinkedHashMap.from({
      'id': _wallet.generate_order_id(),
      'ordertype': _order_type,
      'price': _price_encoded,
      'quantity': _quantity_encoded,
      'sender': _wallet.address,
      'side': _side,
      'symbol': _symbol,
      'timeinforce': _time_in_force,
    });
  }

  @override
  Map to_sign_map() {
    return {'order_type': _order_type, 'price': _price, 'quantity': _quantity, 'side': _side, 'symbol': _symbol, 'time_in_force': _time_in_force};
  }

  @override
  NewOrder to_protobuf() {
    var pb = NewOrder()
      ..sender = decode_address(_wallet.address)
      ..id = _wallet.generate_order_id()
      ..symbol = _symbol
      ..timeinforce = fixnum.Int64(_time_in_force)
      ..ordertype = fixnum.Int64(_order_type)
      ..side = fixnum.Int64(_side)
      ..price = fixnum.Int64(_price_encoded)
      ..quantity = fixnum.Int64(_quantity_encoded);
    return pb;
  }
}
