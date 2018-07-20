pragma solidity 0.4.24;

uint256 TIMEOUT = 100;

contract PaymentChannel {

  address owner;
  bytes32 nonceAddr;

  address[] beneficiaries;
  uint256[] balances;

  uint256 deadline;
  bool public finalized;

  function constructor(
    address _owner, address[] _beneficiaries, uint256[] _balances,
  ) public {
    owner = _owner;
    beneficiaries = _beneficiaries;
    balances = _balances;

    deadline = block.number + TIMEOUT;
    finalized = false;
  }

  function set(
    address[] _beneficiaries, uint256[] _balances
  )
    public
  {
    require(msg.sender == owner);
    require(block.number < deadline);
    require(!finalized);

    beneficiaries = _beneficiaries;
    balances = _balances;
    deadline = block.number + TIMEOUT;
  }

  function finalize() {
    require(block.number >= deadline);
    require(!finalized);

    finalized = true;
  }

}
