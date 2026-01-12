// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

contract DeployDeployers is Script, DeployCoreSupala {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();
        _deployDeployer();
        vm.stopBroadcast();
    }
}

// RUN
// forge script DeployDeployers --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script DeployDeployers --broadcast -vvv --verify
// forge script DeployDeployers --broadcast -vvv
// forge script DeployDeployers -vvv
