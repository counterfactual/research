pragma solidity 0.4.23;

contract HashLadder {

    mapping(bytes32 => uint256) public height;
    mapping(bytes32 => bytes32) revealedPreimage;

    function kHash(bytes32 input) public pure returns (bytes32) {
        return keccak256(input);
    }

    function highestPreimage(bytes32 commitment) public view returns (bytes32) {
        if (height[commitment] == 0) return commitment;
        return revealedPreimage[commitment];
    }

    function emptyKeccak() public pure returns (bytes32) {
        return keccak256(uint256(0x0));
    }

    function reveal(bytes32 commitment, bytes32 preimage, uint256 rounds) public {
        bytes32 p = preimage;
        for (uint256 i = 0; i < rounds; i++) {
            p = keccak256(p);
        }

        require(p == highestPreimage(commitment));
        revealedPreimage[commitment] = preimage;
        height[commitment] += rounds;
    }

}
