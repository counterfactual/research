pragma solidity ^0.4.17;

import "./Registry.sol";
import "../cf-instantiated-objects/RootNonce.sol";
import "../cf-instantiated-objects/Payment.sol";


contract Commitments {

  function refundCommitment(
    uint256 expectedBal,
    address registryAddr,
    bytes32 rootCA,
    uint256 rootExpected,
    address[] refundA,
    uint256[] refundAmt
  ) public {
    require(address(this).balance == expectedBal);
    Registry registry = Registry(registryAddr);
    address rootA = registry.resolver(rootCA);
    RootNonce rootCO = RootNonce(rootA);
    require(rootCO.finalizedNonce() == rootExpected);
    for (uint256 i = 0; i < refundA.length; i++) {
      refundA[i].transfer(refundAmt[i]);
    }
  }

  function paymentCommitment(
    address registryA,
    bytes32 rootCA,
    bytes32 paymentCA,
    uint256 rootExpected
  ) public {
    Registry registry = Registry(registryA);
    address rootA = registry.resolver(rootCA);
    RootNonce rootCO = RootNonce(rootA);
    require(rootCO.finalizedNonce() == rootExpected);
    address paymentA = registry.resolver(paymentCA);
    Payment paymentCO = Payment(paymentA);
    require(paymentCO.isFinal());
    for (uint256 i = 0; i < paymentCO.numOwners(); i++) {
      paymentCO.owners(i).transfer(paymentCO.balances(i));
    }
  }

}
