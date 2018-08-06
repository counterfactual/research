/*
on-chain payment channel
implementation choices mirror RROPayment where applicable

untested
*/
contract Payment {

  address[2] owners;
  uint256 balance; // amount of money owners[0] owns
  uint256 deposit; // amount of money owners[0] deposited
  uint256 finalizesAt = 0;
  uint256 nonce;

  constructor(address[2] _owners) {
    owners = _owners;
  }

  function () payable {
    if (msg.sender == owners[0]) {
      deposit += ms.value;
    }
  }

  function startDispute() {
    require(finalizesAt == 0);
    balance = deposit;
    finalizesAt = now + 100;
  }

  function progressDispute(
    uint256 _balance, uint256 _nonce,
    uint8[2] v, bytes32[2] r, bytes32[2] s
  ) {
    require(_nonce > nonce);
    bytes32 digest = keccak256(abi.encode(_balance, _nonce));
    for (uint256 i = 0; i < owners.length; i++) {
      require(owners[i] == ecrecover(digest, v[i], r[i], s[i]));
    }
    balance = _balance;
    nonce = _nonce;
  }

  function finalizeExit() {
    require(now > finalizesAt);
    owners[0].transfer(balance);
    owners[1].transfer(this.balance);
  }

  function unanimousClose(
    uint256[2] balances,
    uint8[2] v, bytes32[2] r, bytes32[2] s
  ) {

    bytes32 digest = keccak256(abi.encode(balances));

    for (uint256 i = 0; i < owners.length; i++) {
      require(owners[i] == ecrecover(digest, v[i], r[i], s[i]));
    }

    for (uint256 i = 0; i < owners.length; i++) {
      owners[i].transfer(balances[i]);
    }

  }

}
