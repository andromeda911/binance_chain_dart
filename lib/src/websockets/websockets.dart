import 'dart:async';
import 'dart:convert';
import 'package:binance_chain/binance_chain.dart';
import 'package:binance_chain/src/websockets/ws_response_models.dart';
import 'package:web_socket_channel/io.dart';

class WebsocketBinanceListener {
  IOWebSocketChannel socket;
  BinanceEnvironment env;
  WebsocketBinanceListener(this.env);
  Stream<dynamic> stream;
  Timer _keepAliveTimer;
  void _subscribe<DataModel>(String connectionJsonMessage, Function(WsBinanceMessage<DataModel> message) onMessage) {
    socket = IOWebSocketChannel.connect('${env.wssUrl}/ws');
    stream = socket.stream.asBroadcastStream();

    stream.listen((message) {
      if (message.runtimeType == String) {
        if (message.contains('stream')) {
          if (onMessage != null) {
            onMessage(WsBinanceMessage<DataModel>()..fromJson(json.decode(message)));
          }
        }
      }
    });

    socket.sink.add(connectionJsonMessage);
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(Duration(minutes: 25), (timer) {
      socket.sink.add(json.encode({'method': 'keepAlive'}));
    });
  }

  void subscribeAccountUpdates(String address, {Function(WsBinanceMessage<AccountData> message) onMessage}) {
    _subscribe<AccountData>(json.encode({'method': 'subscribe', 'topic': 'accounts', 'address': address}), onMessage);
  }

  void subscribeAccountOrders(String address, {Function(WsBinanceMessage<List<OrdersData>> message) onMessage}) {
    _subscribe<List<OrdersData>>(json.encode({'method': 'subscribe', 'topic': 'orders', 'address': address}), onMessage);
  }

  void subscribeAccoutTransfers(String address, {Function(WsBinanceMessage<TransferData> message) onMessage}) {
    _subscribe<TransferData>(json.encode({'method': 'subscribe', 'topic': 'transfers', 'address': address}), onMessage);
  }

  void subscribeOrderBook(String marketPairSymbol, {Function(WsBinanceMessage<MarketDepthData> message) onMessage}) {
    _subscribe<MarketDepthData>(
        json.encode({
          'method': 'subscribe',
          'topic': 'marketDepth',
          'symbols': [marketPairSymbol]
        }),
        onMessage);
  }
}

class WebsocketBinanceManager {
  Map<String, WebsocketBinanceListener> sockets;

  WebsocketBinanceManager();
}
