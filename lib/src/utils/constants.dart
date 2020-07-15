class TimeInForce {
  int value;
  TimeInForce.GOOD_TILL_EXPIRE() {
    value = 1;
  }
  TimeInForce.IMMEDIATE_OR_CANCEL() {
    value = 3;
  }
}

class OrderSide {
  int value;
  OrderSide.BUY() {
    value = 1;
  }
  OrderSide.SELL() {
    value = 2;
  }
}

class OrderType {
  int value;
  OrderType.LIMIT() {
    value = 2;
  }
}
