The basic goal of the high speed rail design is to allow individual payments to be:

one-way, no ack required (rails are deployed in pairs for bidirectionality, assuming two parties to the channel. multiparty versions are possible but out of scope for this document and are built up pairwise anyways)

very small message size

very easy and computationally fast to authenticate

resistant to dropped messages

still very cheap in the event of needing to go to chain

as well as for the computational load to be largely pre-generable and/or parallelisable (the "rails")

**Here is the basic outline of the strategy:**

"Rails" are long hash ladders, revealed in reverse order so that successively deeper pre-images increment the state (so the 0th increment is the final hash of the ladder, the 1st increment is the 0th increment's pre-image, the 2nd increment is the 1st's preimage, etc.).  Each hash is also used as the leaf of a merkle tree, so each leaf is addressable either incrementally from any of the leaves it hashes to or globally via merkle proof (the left, right combinations when descending from the root encoding the increment ID in binary).

Payments are individual hashes/pre-images and/or partial merkle proofs which can be verified incrementally with a single hash-and-check operation in the case of a single "increment" or a short merkle proof verification in the event of a "jump" in increments.

Each hash increments the payment by a small, fixed amount, with the unit decided at setup time.  Multiple units may be in play simultaneously if expected payments are variable in size.

Payer rates are limited only by upstream bandwidth, since all hashes can be pregen'd (in parallel on other cores if needed) and loaded into RAM.

Receiver rates are limited only by hashing performance, at a rate of one hash-and-check per increment or one merkle verification per jump.  Note however that since no ack is required incoming payments can just be cached until they are actually processed, so the instantaneous limit of receiving rates is also just downstream network bandwidth. Hash performance is only the limit on *authenticating* payments (still important in most applications). Some speedups in verifications of long chains (for closing) are possible, like computing individual branches in parallel, etc.  Sender can also reduce computation here by supplying more of the merkle tree's non-leaf nodes during setup, allowing entire parts of the rail to be skipped in favour of just computing the portion of the merkle tree which connects to the presupplied nodes. Multiple rails can be handled on different cores in parallel, etc.

**Here are the actual protocol steps the application needs to do:**

Step 0 (can be done in advance and cached, or at the same time as Step 1): pre-gen at least one rail per participant by computing a hash ladder of useful length, and then the merkle tree that has those hashes as leaves

Step 1: install the high speed rails "app" using normal state-machine-app methods, with a balance for each participant

Step 2: "load" rails in each direction, one for each desired unit size (wei, gigawei, whatever)

This involves each party sending signed updates to the other (containing at minimum the merkle root and proof down to 0th leaf for the rail, but possibly additional non-leaf nodes) agreeing to honor a given rail's preimages as payments, specifying the unit size and total rail length in increments. Only the root and unit size must be signed, all else is metadata for checking rail validity or for verifying future rail payments. The merkle proof of the 0th leaf (and the list of supplied nodes for the merkle tree) is checked against the root, and the tree depth is recorded.

Step 3: to make payments, either send

a) an "increment" message, which is a tuple consisting of 1) the pre-image for the *n*th hash in a rail of desired unit, where *n* is the id of the latest hash sent (and also the total value paid so far in units for that rail), and 2) the numerical id of that hash (the integer *n*+1), and 3) the rail identifier (probably just the first few bits of the merkle root)

or

b) a "jump" message, which increases the total sent by *k* units for a particular rail, and consists of 1) the hash with *n*+*k*th id, 2) a merkle proof from that leaf to the root (or a previously sent/computable node), and the 3) the rail identifier

obviously, payment optimisation would suggest that we decompose our send modulo the highest unit we have a rail for (recursively), and/or check if either the highest number of "outstanding" (that is, unmerkleable) increments within one unit type, or the total number of "outstanding" increments across all unit types, is larger than the tree depth of a given payment's divisor units (and so would be better served by just sending a jump message instead of individual increments).  A wide variety of more elaborate strategies are available, all of which make various tradeoffs between endpoints, various system resources, expected usage patterns, gas cost of submitting proofs, and so on. Example: sending jump messages when the merkle proofs for an increment would require nodes the receiver can't compute yet; or bumping the unit size of an existing rail with a new rail load message for the same root.

Step 4: when receiving a message, check the message type.

a) if it's an increment message the difference between the increment's id and the previously best known id for that rail (*n*) can be calculated, and the value hashed that number of times to verify it against *n* (note that this automatically corrects for lost increment messages on that rail). The new recorded state for that rail is then adjusted to set *n* = latest validated increment. If desired new merkle proofs can also be computed when enough leafs are received for new branches to be computed from the existing nodes.

b) if it's a jump message the merkle proof can be used to derive the leaf's increment id, and it can be compared against the latest known increment *n* for that rail. If it is higher, the proof can be verified and the recorded state adjusted to set *n* = latest validated increment (note that this also automatically corrects for any lost intermediate payments sent on this rail).

Step 5: to show the current balances (and to compute it in the state machine should we go to chain), we simply take the start balance for each user, multiply the unit size of each rail by the latest leaf *n* that was sent/received for that rail, and then subtract the combined total of sends while adding the combined total of receives to each user's balance.  Note that an arbitrary number of preloaded rails can be authorized, with lengths far longer than the actual balances available, and then just ignored unless needed. A further degree of optimisation is possible to decide lengths of rails (basically keeping merkle proofs short vs how frequently rails need to be swapped), unit sizes, total number of rails, etc.

Step 6: whenever a rail becomes fully used up (or at any other time) the rail can be closed (only the signature of the rail's receiver is needed to close if a merkle proof of the latest claimed increment is provided with the signed request, and only the sender's signature is needed to close at a max value, so the state machine can include those transitions if you want) and the balances adjusted accordingly.  Again lots of optimisation room here to decide how urgent/desired this is at any given time.

Step 7: closing the app:

a) for a cooperative close, just close all rails and close the rails app.  Technically we can do this atomically, but that sounds very similar to the normal "optimistic closure" stuff we are going to do sometime anyways, and I don't know the engineering implications of trying to do that right now, so probably just skip it.

b) for an uncooperative close, publish the rails app, have each party submit the "load" messages for rails they have received payments on, and then submit a merkle proof of the highest increment *i* they can compute a merkle proof for (may be equal to the latest increment *n*), plus the highest later increment (and its numerical id) if it exists. The state machine should first verify that all submitted load messages contain unique roots, then verify the supplied merkle proof for each, compute the increment id from it, and hash any later increment provided *n-*i times to verify that the proven leaf has been reached. After doing this for all rails, and multiplying the resulting state *n* by the unit size for each rail, it should compute final balances by the standard method of adding all received payments to each party's initial balance, and subtracting all sent payments.

That's it for a rough outline.  There are obviously many details skipped over, and many further enhancements that can be added (like eliminating keys for rail closure messages in favor of further pre-images, slight adjustments to rail/merkle structure, etc.).  This code is really very similar to that needed for keyless nonces, btw.  All it is really doing is efficiently computing a latest incremental value.  If every party to a state channel loaded one rail for every nonce they needed to handle, the same logic would do the job there (the only technical difference being that value tracking is cardinal while state tracking is ordinal, so the latter can benefit from slightly different hash structures).