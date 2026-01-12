// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

contract DeployHelperUtils is Script, DeployCoreSupala {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();
        _deployHelperUtils();
        vm.stopBroadcast();
    }
}

// RUN
// forge script DeployHelperUtils --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script DeployHelperUtils --broadcast -vvv --verify
// forge script DeployHelperUtils --broadcast -vvv
// forge script DeployHelperUtils -vvv
