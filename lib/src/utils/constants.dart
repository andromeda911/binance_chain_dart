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

class VoteOption {
  String str_val;
  int int_val;

  VoteOption.YES() {
    str_val = 'Yes';
    int_val = 1;
  }
  VoteOption.ABSTAIN() {
    str_val = 'Abstain';
    int_val = 2;
  }
  VoteOption.NO() {
    str_val = 'No';
    int_val = 3;
  }
  VoteOption.NO_WITH_VETO() {
    str_val = 'NoWithVeto';
    int_val = 4;
  }
}

enum TxType { NEW_ORDER, ISSUE_TOKEN, BURN_TOKEN, LIST_TOKEN, CANCEL_ORDER, FREEZE_TOKEN, UN_FREEZE_TOKEN, TRANSFER, PROPOSAL, VOTE, MINT, DEPOSIT, CREATE_VALIDATOR, REMOVE_VALIDATOR, TIME_LOCK, TIME_UNLOCK, TIME_RELOCK, SET_ACCOUNT_FLAG, HTL_TRANSFER, CLAIM_HTL, DEPOSIT_HTL, REFUND_HTL }
enum TxSide { RECEIVE, SEND }
