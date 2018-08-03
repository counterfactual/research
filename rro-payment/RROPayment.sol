/*
receiver read-only payment channel
*/
contract RROPayment {

  address[2] owners;
  uint256[2] payments;
  uint256 deposit; // amount of money owners[0] deposited
  uint256 finalizesAt = 0;

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
    finalizesAt = now + 100;
  }

  function progressDispute(
    uint256 idx, uint256 amount,
    uint8 v, bytes32 r, bytes32 s
  ) {
    bytes32 digest = keccak256(abi.encode(idx, amount));
    require(owners[idx] == ecrecover(digest, v, r, s));
    payments[idx] = amount;
  }

  function finalize() {
    require(now > finalizesAt);
    uint256 balDiff = payments[0] - payments[1];
    uint256 bal = deposit + balDiff;

    owners[0].transfer(bal);
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
