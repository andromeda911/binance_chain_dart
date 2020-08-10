import 'dart:convert';
import 'package:binance_chain/binance_chain.dart';
import 'package:binance_chain/src/websockets/ws_response_models.dart';
import 'package:web_socket_channel/io.dart';

class WebsocketBinanceListener {
  IOWebSocketChannel socket;
  BinanceEnvironment env;
  WebsocketBinanceListener(this.env);

  void _subscribe<DataModel>(String connectionJsonMessage, Function(WsBinanceMessage<DataModel> message) onMessage) {
    socket = IOWebSocketChannel.connect('${env.wssUrl}/ws');
    socket.stream.listen((message) {
      if (message.runtimeType == String) {
        if (message.contains('stream')) {
          if (onMessage != null) {
            onMessage(WsBinanceMessage<DataModel>()..fromJson(json.decode(message)));
          }
        }
      }
    });
    socket.sink.add(connectionJsonMessage);
  }

  void subscribeAccountOrders(String address, {Function(WsBinanceMessage<OrdersData> message) onMessage}) {
    _subscribe(json.encode({'method': 'subscribe', 'topic': 'orders', 'address': address}), onMessage);
  }

  void subscribeAccoutTransfers(String address, {Function(WsBinanceMessage<TransferData> message) onMessage}) {
    _subscribe(json.encode({'method': 'subscribe', 'topic': 'transfers', 'address': address}), onMessage);
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