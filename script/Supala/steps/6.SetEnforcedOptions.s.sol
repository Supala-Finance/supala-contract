// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

contract SetEnforcedOptions is Script, DeployCoreSupala {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();
        _setEnforcedOptions();
        vm.stopBroadcast();
    }
}

// RUN
// forge script SetEnforcedOptions --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script SetEnforcedOptions --broadcast -vvv --verify
// forge script SetEnforcedOptions --broadcast -vvv
// forge script SetEnforcedOptions -vvv
