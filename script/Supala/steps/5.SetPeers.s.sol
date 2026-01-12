// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

contract SetPeers is Script, DeployCoreSupala {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();
        _setPeers();
        vm.stopBroadcast();
    }
}

// RUN
// forge script SetPeers --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script SetPeers --broadcast -vvv --verify
// forge script SetPeers --broadcast -vvv
// forge script SetPeers -vvv
