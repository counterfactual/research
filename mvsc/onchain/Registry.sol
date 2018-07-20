pragma solidity ^0.4.17;

contract Registry {
  mapping(bytes32 => address) public deployedAddressOf;

  function deploy(bytes code) public {
    address newContract;
    bytes32 cfAddress = keccak256(msg.sender, code);

    require(deployedAddressOf[cfAddress] == 0x0);

    assembly {
      newContract := create(0, add(code, 0x20), mload(code))
    }

    deployedAddressOf[cfAddress] = newContract;
  }

  function resolve(bytes32 cfAddress) constant public returns (address) {
    return deployedAddressOf[cfAddress];
  }
}
