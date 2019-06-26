Active app mechanisms

|        Field         |             cf-now             |            cf-next             |                     nitro                     | cf-future |
| -------------------- | ------------------------------ | ------------------------------ | --------------------------------------------- | --------- |
| Supported Assets     | User-defined                   | ETH,ERC-20                     | ETH,ERC-20                                    | ?         |
| State Deposit Holder | Multisig                       | Multisig                       | Adjudicator                                   | ?         |
| AAL Stored In        | Implicit                       | Part of LB                     | Part of ledger channel                        | ?         |
| AAL Dispute Ends By  | Uninstall/Root nonce finalizes | LB outcome finalizes           | ledger channel sends                          | ?         |
| AAL <-> AA           | AA checks Uninstall/Root nonce | AA checks LB outcome           | Adjudicator checks that app channel is funded | ?         |
| Inactive App effect  | Uninstall/Root nonce fails     | LB outcome check fails         | app channel is unfunded                       | ?         |
| UB stored in         | FB                             | Part of LB                     | part of ledger channel                        | ?         |
| UB effect            | FB executes effect             | LB executes partial (?) effect | ledger channel sends                          | ?         |

# Terminology: AAL, LB, UB, ledger channel, free balance

The active app list (AAL) between two participants is defined as the list of channelized complex contracts between them, and the assets those contracts control. We exclude ownership from the AAL.

The unallocated balances (UB) between two participants is defined as the list of channelized ownerships between them.

The Free Balance (FB) is an an app definition that only exists in cf-now. Its latest state is the UB.

The latest state of the top-level ledger channel in Nitro contains both the AAL and the UB. Note that the design allows for the AAL and UB to be spread out in a tree of ledger channels, but the nitro implementation does not do this.

The ledger balance (LB) is something in cf-next that contains both the AAL and the UB.

In cf-now, the AAL is not explicitly stored as the latest state of anything, rather it can be derived from the latest states of the root nonce, uninstall nonces, and commitments. Hence we say it is stored implicitly.

# AAL <-> Active App

In all mechanisms, we can abstractly say that there is some mechanism for the blockchain to find out the AAL, a mechanism for the blockchain to find out the outcome of an active app, and some way to combine those two to achieve some effect.

```
[ AAL ] <----> [ AA ]
```

# cf-now registries

```
RootNonceRegistry: owner -> salt -> timeout -> finalizesAt -> value
UninstallNonceRegistry: owner -> salt -> finalizesAt -> value
ChallengeRegistry.sol/appOutcomes: owner -> signingKeys -> appDefinition -> defaultTimeout -> bytes
```

The first four fields in ChallengeRegistry (`owner -> signingKeys -> appDefinition -> defaultTimeout`) are hashed to form the appIdentityHash.

# cf-next registries

```
OutcomeRegistry: owner -> signingKeys -> appDefinition -> defaultTimeout -> bytes
LedgerBalanceRegistry: owner -> (beneficiary | someKindOfAppInstanceId) -> assetType -> amount
```

# nitro registries

```
NitroAdjudicator/holdings: (address | owners[] -> nonce) -> amount
NitroAdjudicator/outcome: (address | owners[] -> nonce) -> Outcome (what is this)
```
