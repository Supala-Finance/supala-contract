// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

contract SetSharesTokenDeployerConfig is Script, DeployCoreSupala {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();
        _setSharesTokenDeployerConfig();
        vm.stopBroadcast();
    }
}

// RUN
// forge script SetSharesTokenDeployerConfig --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script SetSharesTokenDeployerConfig --broadcast -vvv --verify
// forge script SetSharesTokenDeployerConfig --broadcast -vvv
// forge script SetSharesTokenDeployerConfig -vvv
