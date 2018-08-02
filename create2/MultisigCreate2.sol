contract Create2Wrappers {
    /*
    Emulates CREATE2 with msg.sender fixed to `this.address`

    Overhead:
        700 gas for call to this contract
        ?? gas for decoding function sig
    */
    function fixedSenderCreate2(bytes code, bytes32 salt) public {
        assembly {
            create2(0, salt, add(code, 0x20), mload(code));
        }
    }
    /*
    Emulates CREATE2 with msg.sender as a multisig passed in

    Overhead:
        3000+ gas per address
    */
    function multisigCreate2(
            address[] owners, uint8[] v, bytes32[] r, bytes32[] s, bytes code, bytes32 salt
    ) public {
        bytes32 digest = keccak256(owners, code, salt);
        address lastSigner = address(0);
        for (uint256 i = 0; i < v.length; i++) {
          require(
            owners[i] == ecrecover(
              digest,
              v[i],
              r[i],
              s[i]
            )
          );
          require(_signingKeys[i] > lastSigner);
          lastSigner = _signingKeys[i];
        }
        fixedSenderCreate2(code, salt);
    }
}
