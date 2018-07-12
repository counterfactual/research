pragma solidity ^0.4.17;

// empty state, scalar nonce,
contract EmptyCounterfactualObject {

    // parameters - fixed at deploy time
    address public ownerA;
    address public ownerB;
    uint256 public instanceNonce;

    bool isFinal;
    uint256 public finalizesAt;

    // nonce
    uint256 public latestNonce = 0;


    function recoverSigner(bytes32 digest, uint8 v, bytes32 r, bytes32 s) public pure returns (address) {
        return ecrecover(
            keccak256("\x19Ethereum Signed Message:\n32", digest),
            v, r, s);
    }

    // called by registry
    function EmptyCounterfactualObject(uint256 _instanceNonce, address _ownerA, address _ownerB) public {
        instanceNonce = _instanceNonce;
        ownerA = _ownerA;
        ownerB = _ownerB;
        finalizesAt = block.number + 10;
    }

    function update(uint256 nonce, uint8[] v, bytes32[] r, bytes32[] s) public {

        require(!isFinal);
        require(nonce > latestNonce);

        // todo: add salt
        bytes32 digest = keccak256(instanceNonce, nonce);

        require(ownerA == recoverSigner(digest, v[0], r[0], s[0]));
        require(ownerB == recoverSigner(digest, v[1], r[1], s[1]));

        latestNonce = nonce;
        finalizesAt = block.number + 10;
    }

    function finalize () public {
        require(block.number >= finalizesAt);
        isFinal = true;
    }

    function finalizedNonce() public view returns (uint256) {
        require(isFinal);
        return latestNonce;
    }

}
