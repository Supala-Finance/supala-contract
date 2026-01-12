// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

contract SetDeployerToFactory is Script, DeployCoreSupala {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();
        _setDeployerToFactory();
        vm.stopBroadcast();
    }
}

// RUN
// forge script SetDeployerToFactory --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script SetDeployerToFactory --broadcast -vvv --verify
// forge script SetDeployerToFactory --broadcast -vvv
// forge script SetDeployerToFactory -vvv
