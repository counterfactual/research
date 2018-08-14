# research

- mvsc: simple counterfactually instantiated payment channel
- create2: replace some uses of the registry with CREATE2
- hash-ladder-nonce: make nonces incrementable via hash revelation instead of ecrecover
- mc-multisig: allow the multisig to have a "multisend" transaction type that stores individual transactions in the leaves of a merkle tree and just authenticates the root
- metachannel-payment: a simple metachannel implementation of payment channels, intended to be compared vs sprites and perun. uses code from mvsc
- multisig-owner: mvsc with multisig owner. likely outdated.
- rro-payment: a payment channel where the receiver need not countersign
- t-metachannel: a metachannel that allows users to enter contracts that last beyond the collateral lockup period. supports 2 endpoints and multihop. only supports eth (supported collateral type must be explicitly built into the TMetachannelMultisig.sol file)

## tbd

- "SIGHASH_NOINPUT" mechanism for allowing witness data in commitments
- store all timeout state in root nonce - (nonce, block nonce was set)
- figure out the metachannel stuff for the case where there are >2 participants
