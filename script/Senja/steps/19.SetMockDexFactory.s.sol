// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

contract SetMockDexFactory is Script, DeployCoreSupala {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();
        _setMockDexFactory();
        vm.stopBroadcast();
    }
}

// RUN
// forge script SetMockDexFactory --broadcast -vvv --verify --verifier oklink --verifier-url https://www.oklink.com/api/v5/explorer/contract/verify-source-code-plugin/kaia
// forge script SetMockDexFactory --broadcast -vvv --verify
// forge script SetMockDexFactory --broadcast -vvv
// forge script SetMockDexFactory -vvv
