// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

contract DeployInterestRateModel is Script, DeployCoreSupala {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();
        _deployInterestRateModel();
        vm.stopBroadcast();
    }
}

// RUN
// forge script DeployInterestRateModel --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script DeployInterestRateModel --broadcast -vvv --verify
// forge script DeployInterestRateModel --broadcast -vvv
// forge script DeployInterestRateModel -vvv
