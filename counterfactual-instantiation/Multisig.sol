pragma solidity 0.4.24;


contract MinimumViableMultisig {

  mapping(bytes32 => bool) isExecuted;
  address[] public owners;

  mapping (address => bool) isOwner;

  function constructor(address[] _owners) public {
    owners = _owners;
  }

  function execTransaction(
    address to,
    bytes data,
    uint8[] v,
    bytes32[] r,
    bytes32[] s
  )
    public
  {
    bytes32 transactionHash = getTransactionHash(to, data);
    address lastOwner = address(0);
    for (uint256 i = 0; i < owners.length; i++) {
      require(
        owners[i] == ecrecover(transactionHash, v[i], r[i], s[i])
      );
    }

    require(executeDelegateCall(to, data));

    isExecuted[transactionHash] = true;
  }

  function getTransactionHash(
    address to,
    bytes data,
  )
    public
    view
    returns (bytes32)
  {
    return keccak256(abi.encodePacked(byte(0x19), this, to, value, data, operation));
  }

  function executeDelegateCall(address to, bytes data)
    internal
    returns (bool success)
  {
    assembly {
      success := delegatecall(not(0), to, add(data, 0x20), mload(data), 0, 0)
    }
  }

}
