pragma solidity ^0.4.17;

import "./Registry.sol";
import "../cf-instantiated-objects/EmptyCounterfactualObject.sol";
import "../cf-instantiated-objects/PaymentCounterfactualObject.sol";


contract DelegateTargets {

    function tx1(address registryA, bytes32 rootCA, address refundTo) public {
        require(this.balance == 5 ether);

        Registry registry = Registry(registryA);

        address rootA = registry.resolve(rootCA);

        // todo: compiler error if s/rootA/rootCA/g
        EmptyCounterfactualObject rootCO = EmptyCounterfactualObject(rootA);

        require(rootCO.finalizedNonce() == 0);
        refundTo.transfer(5 ether);
    }

    function tx2(address registryA, bytes32 rootCA, address refundToA, address refundToB) public {
        require(this.balance == 10 ether);

        Registry registry = Registry(registryA);

        address rootA = registry.resolve(rootCA);
        require(rootA != 0x0);

        EmptyCounterfactualObject rootCO = EmptyCounterfactualObject(rootA);

        require(rootCO.finalizedNonce() == 0);
        refundToA.transfer(5 ether);
        refundToB.transfer(5 ether);
    }

    function tx3(address registryA, bytes32 rootCA, bytes32 paymentCA, address payoutToA, address payoutToB) public {

        Registry registry = Registry(registryA);

        address rootA = registry.resolve(rootCA);

        EmptyCounterfactualObject rootCO = EmptyCounterfactualObject(rootA);

        require(rootCO.finalizedNonce() == 1);

        address paymentA = registry.resolve(paymentCA);

        PaymentCounterfactualObject paymentCO = PaymentCounterfactualObject(paymentA);

        require(paymentCO.isFinal());

        payoutToA.transfer(paymentCO.balanceA());
        payoutToB.transfer(paymentCO.balanceB());
    }

}
