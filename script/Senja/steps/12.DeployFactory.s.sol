// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

contract DeployFactory is Script, DeployCoreSupala {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();
        _deployFactory();
        vm.stopBroadcast();
    }
}

// RUN
// forge script DeployFactory --broadcast -vvv --verify --verifier oklink --verifier-url https://www.oklink.com/api/v5/explorer/contract/verify-source-code-plugin/kaia
// forge script DeployFactory --broadcast -vvv --verify
// forge script DeployFactory --broadcast -vvv
// forge script DeployFactory -vvv
