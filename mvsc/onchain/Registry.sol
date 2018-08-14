pragma solidity 0.4.24;

contract Registry {
  mapping(bytes32 => address) public resolver;

  function deploy(bytes code) public {
    address newContract;
    bytes32 cfAddress = keccak256(abi.encode(msg.sender, code));

    require(resolver[cfAddress] == 0x0);

    assembly {
      newContract := create(0, add(code, 0x20), mload(code))
    }

    resolver[cfAddress] = newContract;
  }
}
