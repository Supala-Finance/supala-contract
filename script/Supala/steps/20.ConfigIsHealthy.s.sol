// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

contract ConfigIsHealthy is Script, DeployCoreSupala {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();
        _configIsHealthy();
        vm.stopBroadcast();
    }
}

// RUN
// forge script ConfigIsHealthy --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script ConfigIsHealthy --broadcast -vvv --verify
// forge script ConfigIsHealthy --broadcast -vvv
// forge script ConfigIsHealthy -vvv
