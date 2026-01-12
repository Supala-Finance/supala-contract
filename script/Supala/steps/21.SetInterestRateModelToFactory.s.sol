// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

contract SetInterestRateModelToFactory is Script, DeployCoreSupala {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();
        _setInterestRateModelToFactory();
        vm.stopBroadcast();
    }
}

// RUN
// forge script SetInterestRateModelToFactory --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script SetInterestRateModelToFactory --broadcast -vvv --verify
// forge script SetInterestRateModelToFactory --broadcast -vvv
// forge script SetInterestRateModelToFactory -vvv
