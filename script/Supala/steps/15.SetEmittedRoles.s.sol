// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

contract SetEmittedRoles is Script, DeployCoreSupala {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();
        _setEmittedRoles();
        vm.stopBroadcast();
    }
}

// RUN
// forge script SetEmittedRoles --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script SetEmittedRoles --broadcast -vvv --verify
// forge script SetEmittedRoles --broadcast -vvv
// forge script SetEmittedRoles -vvv
