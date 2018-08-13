pragma solidity ^0.4.17;

import "./Registry.sol";
import "../mvsc/cf-instantiated-objects/RootNonce.sol";
import "../mvsc/cf-instantiated-objects/Payment.sol";


contract Commitments {

  function proxyCommitment(
    address registryA,
    bytes32 rootCA,
    bytes32 paymentCA,
    uint256 rootExpected,
    uint256 expiryBlock // the block number after which the intermediary can get his money back
  ) public {
    Registry registry = Registry(registryA);
    address rootA = registry.resolver(rootCA);
    RootNonce rootCO = RootNonce(rootA);
    require(rootCO.finalizedNonce() == rootExpected);
    address paymentA = registry.resolver(paymentCA);
    Payment paymentCO = Payment(paymentA);
    require(paymentCO.isFinal() || now > expiryBlock);
    for (uint256 i = 0; i < paymentCO.length; i++) {
      paymentCO.owners(i).transfer(paymentCO.balance(i));
    }
  }

}
