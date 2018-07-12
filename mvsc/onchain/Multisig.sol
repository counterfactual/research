pragma solidity ^0.4.17;

contract Multisig {

    address public ownerA;
    address public ownerB;

    function recoverSigner(bytes32 digest, uint8 v, bytes32 r, bytes32 s) public pure returns (address) {
        return ecrecover(
            keccak256("\x19Ethereum Signed Message:\n32", digest),
            v, r, s);
        }

    function () public payable {}

    function Multisig(address _ownerA, address _ownerB) public {
        ownerA = _ownerA;
        ownerB = _ownerB;
    }

    /* calldata ABI:
     4 bytes: function signature
    32 bytes: delegateAddress
    32 bytes: ptr to callData
    32 bytes: ptr to v
    32 bytes: ptr to r
    32 bytes: ptr to s
    32 bytes: length of callData
     n bytes: callData
    */
    function executeDelegate(address delegatee, bytes callData, uint8[] v, bytes32[] r, bytes32[] s) public {

        // compute callHash

        bytes32 callDigest = keccak256(delegatee, callData);

        // check signatures

        require(ownerA == recoverSigner(callDigest, v[0], r[0], s[0]));
        require(ownerB == recoverSigner(callDigest, v[1], r[1], s[1]));

        uint256 dataSize = callData.length;
        bool ret;

        assembly {
            // copy callData into free memory
            calldatacopy(mload(0x40), 196, dataSize)
            // issue delegatecall
            ret := delegatecall(gas, delegatee, mload(0x40), dataSize, 0, 0)
        }

        require(ret);


    }

}
