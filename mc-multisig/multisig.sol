pragma solidity 0.4.23;
pragma experimental ABIEncoderV2;

contract MCMultisig {

    address[] public owners;

    constructor(address[] _owners) public {
        owners = _owners;
    }

    function unorderedHash(bytes32 a, bytes32 b) public pure returns (bytes32) {
        if (a > b) return unorderedHash(b, a);
        return keccak256(a, b);
    }

    function verifyProof(bytes32[] _proof, bytes32 _root, bytes32 _leaf) pure returns (bool) {
        bytes32 computedHash = _leaf;

        for (uint256 i = 0; i < _proof.length; i++) {
            bytes32 proofElement = _proof[i];
            computedHash = unorderedHash(computedHash, proofElement);
        }

        return computedHash == _root;
    }

    /*from gnosis*/
    function executeDelegateCall(address to, bytes data) internal returns (bool success) {
		assembly {
			success := delegatecall(not(0), to, add(data, 0x20), mload(data), 0, 0)
		}
	}

    /*
    untested
    TBD: calldata write amplification in proofs[][]?
    */
    function checkAndExecuteDelegateCall(
            address[] to, bytes[] data,
            bytes32 root, bytes32[][] proofs,
            uint8[] v, bytes32[] r, bytes32[] s) {

        /* check that the root is signed */
        for (uint256 i = 0; i < v.length; i++) {
            require(owners[i] == ecrecover(root, v[i], r[i], s[i]));
        }

        for (uint256 j = 0; j < proofs.length; i++) {
            /* check and execute to[i], data[i] */

            bytes32 digest = keccak256(to[j], data[j]);
            require(verifyProof(proofs[j], root, digest));
            executeDelegateCall(to[j], data[j]);
        }

    }
}
