class Error {
  int code;
  String message;

  Error({this.code, this.message});
}

class Times {
  String ap_time;
  String block_time;

  Times({this.ap_time, this.block_time});

  Times.fromJson(var json) {
    ap_time = json['ap_time'];
    block_time = json['block_time'];
  }
}

class Validator {
  String address;
  List<int> pub_key;
  int voting_power;
  int accum;

  Validator({this.address, this.pub_key, this.voting_power, this.accum});

  Validator.fromJson(var json) {
    address = json['address'];
    pub_key = json['pub_key'].cast<int>();
    voting_power = json['voting_power'];
    accum = json[accum];
  }
}

class Validators {
  int blockHeight;
  List<Validator> validators;

  Validators({this.blockHeight, this.validators});

  Validators.fromJson(var json) {
    blockHeight = json['block_height'];
    if (json['validators' != null]) {
      validators = [
        for (var validatorInfo in json['validators'])
          Validator.fromJson(validatorInfo)
      ];
    }
  }
}

class Peer {
  bool accelerated;
  String accessAddr;
  List<String> capabilities;
  String id;
  String listenAddr;
  String moniker;
  String network;
  String originalListenAddr;
  String streamAddr;
  String version;

  Peer(
      {this.accelerated,
      this.accessAddr,
      this.capabilities,
      this.id,
      this.listenAddr,
      this.moniker,
      this.network,
      this.originalListenAddr,
      this.streamAddr,
      this.version});

  Peer.fromJson(Map<String, dynamic> json) {
    accelerated = json['accelerated'];
    accessAddr = json['access_addr'];
    capabilities = json['capabilities'].cast<String>();
    id = json['id'];
    listenAddr = json['listen_addr'];
    moniker = json['moniker'];
    network = json['network'];
    originalListenAddr = json['original_listen_addr'];
    streamAddr = json['stream_addr'];
    version = json['version'];
  }
}

class NodeInfo {
  ProtocolVersion protocolVersion;
  String id;
  String listenAddr;
  String network;
  String version;
  String channels;
  String moniker;
  Other other;

  NodeInfo(
      {this.protocolVersion,
      this.id,
      this.listenAddr,
      this.network,
      this.version,
      this.channels,
      this.moniker,
      this.other});

  NodeInfo.fromJson(Map<String, dynamic> json) {
    json = json['node_info'];
    protocolVersion = json['protocol_version'] != null
        ? ProtocolVersion.fromJson(json['protocol_version'])
        : null;
    id = json['id'];
    listenAddr = json['listen_addr'];
    network = json['network'];
    version = json['version'];
    channels = json['channels'];
    moniker = json['moniker'];
    other = json['other'] != null ? Other.fromJson(json['other']) : null;
  }
}

class ProtocolVersion {
  int p2p;
  int block;
  int app;

  ProtocolVersion({this.p2p, this.block, this.app});

  ProtocolVersion.fromJson(Map<String, dynamic> json) {
    p2p = json['p2p'];
    block = json['block'];
    app = json['app'];
  }
}

class Other {
  String txIndex;
  String rpcAddress;

  Other({this.txIndex, this.rpcAddress});

  Other.fromJson(Map<String, dynamic> json) {
    txIndex = json['tx_index'];
    rpcAddress = json['rpc_address'];
  }
}

class SyncInfo {
  String latestBlockHash;
  String latestAppHash;
  int latestBlockHeight;
  String latestBlockTime;
  bool catchingUp;

  SyncInfo(
      {this.latestBlockHash,
      this.latestAppHash,
      this.latestBlockHeight,
      this.latestBlockTime,
      this.catchingUp});

  SyncInfo.fromJson(Map<String, dynamic> json) {
    latestBlockHash = json['latest_block_hash'];
    latestAppHash = json['latest_app_hash'];
    latestBlockHeight = json['latest_block_height'];
    latestBlockTime = json['latest_block_time'];
    catchingUp = json['catching_up'];
  }
}

class ValidatorInfo {
  String address;
  List<int> pubKey;
  int votingPower;

  ValidatorInfo({this.address, this.pubKey, this.votingPower});

  ValidatorInfo.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    pubKey = json['pub_key'].cast<int>();
    votingPower = json['voting_power'];
  }
}

class ResultStatus {
  NodeInfo nodeInfo;
  SyncInfo syncInfo;
  ValidatorInfo validatorInfo;

  ResultStatus({this.nodeInfo, this.syncInfo, this.validatorInfo});

  ResultStatus.fromJson(Map<String, dynamic> json) {
    nodeInfo =
        json['node_info'] != null ? NodeInfo.fromJson(json['node_info']) : null;
    syncInfo =
        json['sync_info'] != null ? SyncInfo.fromJson(json['sync_info']) : null;
    validatorInfo = json['validator_info'] != null
        ? ValidatorInfo.fromJson(json['validator_info'])
        : null;
  }
}

class Account {
  int accountNumber;
  String address;
  List<Balance> balances;
  int flags;
  List<int> publicKey;
  int sequence;

  Account(
      {this.accountNumber,
      this.address,
      this.balances,
      this.flags,
      this.publicKey,
      this.sequence});

  Account.fromJson(Map<String, dynamic> json) {
    accountNumber = json['account_number'];
    address = json['address'];
    if (json['balances'] != null) {
      balances = <Balance>[];
      json['balances'].forEach((v) {
        balances.add(Balance.fromJson(v));
      });
    }
    flags = json['flags'];
    publicKey = json['public_key'].cast<int>();
    sequence = json['sequence'];
  }
}

class Balance {
  String free;
  String frozen;
  String locked;
  String symbol;

  Balance({this.free, this.frozen, this.locked, this.symbol});

  Balance.fromJson(Map<String, dynamic> json) {
    free = json['free'];
    frozen = json['frozen'];
    locked = json['locked'];
    symbol = json['symbol'];
  }
}

class AccountSequence {
  int sequence;

  AccountSequence({this.sequence});

  AccountSequence.fromJson(Map<String, dynamic> json) {
    sequence = json['sequence'];
  }
}

class Transaction {
  String hash;
  String log;
  String data;
  String height;
  int code;
  bool ok;

  Transaction(
      {this.hash, this.log, this.data, this.height, this.code, this.ok});

  Transaction.fromJson(Map<String, dynamic> json) {
    hash = json['hash'];
    log = json['log'];
    data = json['data'];
    height = json['height'];
    code = json['code'];
    ok = json['ok'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['hash'] = this.hash;
    data['log'] = this.log;
    data['data'] = this.data;
    data['height'] = this.height;
    data['code'] = this.code;
    data['ok'] = this.ok;
    return data;
  }
}
