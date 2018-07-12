pragma solidity ^0.4.17;

contract Registry {
    mapping(bytes32 => address) public deployedAddressOf;

    // debug

    address public lastDeployed;
    bytes32 public lastCf;

    function recoverSigner(bytes32 digest, uint8 v, bytes32 r, bytes32 s) public pure returns (address) {
        return ecrecover(
            keccak256("\x19Ethereum Signed Message:\n32", digest),
            v, r, s);
    }

    /* calldata ABI:
     4 bytes: function signature
    32 bytes: ptr to code
    32 bytes: ptr to v
    32 bytes: ptr to r
    32 bytes: ptr to s
    32 bytes: length of code
     n bytes: code
    */
    function deploy(bytes code, uint8[] v, bytes32[] r, bytes32[] s) public {
        address deployedAddress;
        bytes32 cfAddress;

        // compute codeHash

        bytes32 codeHash = keccak256(code);

        // check signatures

        address a0 = recoverSigner(codeHash, v[0], r[0], s[0]);
        address a1 = recoverSigner(codeHash, v[1], r[1], s[1]);

        // compute counterfactual address

        cfAddress = keccak256(code, a0, a1);

        // deploy

        uint dataSize = code.length;

        assembly {
            // copy calldata[164, 164+s) into free memory
            calldatacopy(mload(0x40), 164, dataSize)
            // deploy contract, with s bytes of code from free memory, and forward all of msg.value
            deployedAddress := create(callvalue, mload(0x40), dataSize)
        }

        // set up pointer

        require(deployedAddressOf[cfAddress] == 0x0);
        deployedAddressOf[cfAddress] = deployedAddress;

        // debug

        lastDeployed = deployedAddress;
        lastCf = cfAddress;

    }

    function resolve(bytes32 cfAddress) constant public returns (address) {
        return deployedAddressOf[cfAddress];
    }
}
