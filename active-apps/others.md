1. explicit merkelization (celer)

In this approach the list of active apps is stored by each client and a merkle root of them is computed. When the list of active apps changes, the merkle root is re-computed and re-signed. In a dispute, at some point the merkle proof into the root is submitted on-chain to prove that the app being disputed is in the list of active apps.

To implement this approach in countefactual, the most direct approach would require the commitment to `StateChannelTransaction.sol` to have witness data (i.e., the merkle proof).

- explicitly put all active apps on chain (magmo)

In this approach there is an explicit list of active apps, together with unallocated funds, and the hash of this list is signed. In a dispute, the whole list is placed on-chain.