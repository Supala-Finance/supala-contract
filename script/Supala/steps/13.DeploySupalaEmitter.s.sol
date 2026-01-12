// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

contract DeploySupalaEmitter is Script, DeployCoreSupala {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();
        _deploySupalaEmitter();
        vm.stopBroadcast();
    }
}

// RUN
// forge script DeploySupalaEmitter --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script DeploySupalaEmitter --broadcast -vvv --verify
// forge script DeploySupalaEmitter --broadcast -vvv
// forge script DeploySupalaEmitter -vvv
