NitroAdjudicator - Without Guarantee Channels

enum CommitmentType { PreFundSetup, PostFundSetup, App, Conclude }

struct CommitmentStruct {
    address channelType;
    uint32 nonce;
    address[] participants;
    uint8 commitmentType;
    uint32 turnNum;
    uint32 commitmentCount;
    address[] destination;
    uint256[] allocation;
    bytes appAttributes;
}

struct Outcome {
    address[] destination;
    uint256 finalizedAt;
    Commitment.CommitmentStruct challengeCommitment;
    uint[] allocation;
}

mapping(address => uint) public holdings;
mapping(address => Outcome) public outcomes;



With Guarantee Channels

Outcome = Allocation [(address, uint256)] | Guarantee ...