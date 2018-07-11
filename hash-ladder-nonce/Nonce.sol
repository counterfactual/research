pragma solidity 0.4.23;

import "./HashLadder.sol";

contract Nonce {

    bytes32[] commitments;
    address hlAddr;

    constructor(bytes32[] _commitments, address _hlAddr) public {
        require(_commitments.length > 0);
        commitments = _commitments;
        hlAddr = _hlAddr;
    }

    function min(uint256 a, uint256 b) public pure returns (uint256) {
        if (a < b) return a;
        return b;
    }

    function getLatestNonce() public view returns (uint256) {

        HashLadder hashLadder = HashLadder(hlAddr);

        uint256 ret = 2**256 - 1;
        for (uint256 i = 0; i < commitments.length; i++) {
            ret = min(ret, hashLadder.height(commitments[i]));
        }

        return ret;
    }

}
