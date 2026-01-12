// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

contract SetCoreFactoryConfig is Script, DeployCoreSupala {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();
        _setCoreFactoryConfig();
        vm.stopBroadcast();
    }
}

// RUN
// forge script SetCoreFactoryConfig --broadcast -vvv --verify --verifier oklink --verifier-url https://www.oklink.com/api/v5/explorer/contract/verify-source-code-plugin/kaia
// forge script SetCoreFactoryConfig --broadcast -vvv --verify
// forge script SetCoreFactoryConfig --broadcast -vvv
// forge script SetCoreFactoryConfig -vvv
