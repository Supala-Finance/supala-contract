// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

contract SetLibraries is Script, DeployCoreSupala {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();
        _setLibraries(MANTLE_TESTNET_USDT_OFT_ADAPTER);
        _setLibraries(MANTLE_TESTNET_USDC_OFT_ADAPTER);
        vm.stopBroadcast();
    }
}

// RUN
// forge script script/Supala/steps/2.SetLibraries.s.sol:SetLibraries --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script script/Supala/steps/2.SetLibraries.s.sol:SetLibraries --broadcast -vvv --verify
// forge script script/Supala/steps/2.SetLibraries.s.sol:SetLibraries --broadcast -vvv
// forge script script/Supala/steps/2.SetLibraries.s.sol:SetLibraries -vvv
