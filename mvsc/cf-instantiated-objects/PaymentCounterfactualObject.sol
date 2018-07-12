pragma solidity ^0.4.17;

// balance state, scalar nonce, conditional on emptycounterfactualobject
// simplified: balanceX belongs to ownerX
contract PaymentCounterfactualObject {

    // parameters - fixed at deploy time
    address public ownerA;
    address public ownerB;

    // state
    uint256 public balanceA = 5 ether;
    uint256 public balanceB = 5 ether;

    bool public isFinal;
    uint256 public finalizesAt;

    // nonce
    uint256 latestNonce = 0;

    function recoverSigner(bytes32 digest, uint8 v, bytes32 r, bytes32 s) public pure returns (address) {
        return ecrecover(
            keccak256("\x19Ethereum Signed Message:\n32", digest),
            v, r, s);
    }

    // called by registry
    function PaymentCounterfactualObject(address _ownerA, address _ownerB) public {
        ownerA = _ownerA;
        ownerB = _ownerB;
        finalizesAt = block.number + 10;
    }

    function update(uint8[] v, bytes32[] r, bytes32[] s, uint256 _balanceA, uint256 _balanceB, uint256 nonce) public {

        require(!isFinal);
        require(nonce > latestNonce);

        require(_balanceA + _balanceB == balanceA + balanceB);

        // todo: add salt
        bytes32 digest = keccak256(_balanceA, _balanceB, nonce);

        require(ownerA == recoverSigner(digest, v[0], r[0], s[0]));
        require(ownerB == recoverSigner(digest, v[1], r[1], s[1]));

        balanceA = _balanceA;
        balanceB = _balanceB;

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
