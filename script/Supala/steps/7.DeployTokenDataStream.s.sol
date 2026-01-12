// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

contract DeployTokenDataStream is Script, DeployCoreSupala {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();
        _deployTokenDataStream();
        vm.stopBroadcast();
    }
}

// RUN
// forge script DeployTokenDataStream --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script DeployTokenDataStream --broadcast -vvv --verify
// forge script DeployTokenDataStream --broadcast -vvv
// forge script DeployTokenDataStream -vvv
