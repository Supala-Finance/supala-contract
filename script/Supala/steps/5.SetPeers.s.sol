// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

contract SetPeers is Script, DeployCoreSupala {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();

        _setPeers(MANTLE_TESTNET_USDC_OFT_ADAPTER, BASE_TESTNET_SUSDC_OFT_ADAPTER);
        _setPeers(MANTLE_TESTNET_USDT_OFT_ADAPTER, BASE_TESTNET_SUSDT_OFT_ADAPTER);

        vm.stopBroadcast();
    }
}

// RUN
// forge script script/Supala/steps/5.SetPeers.s.sol:SetPeers --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script script/Supala/steps/5.SetPeers.s.sol:SetPeers --broadcast -vvv --verify
// forge script script/Supala/steps/5.SetPeers.s.sol:SetPeers --broadcast -vvv
// forge script script/Supala/steps/5.SetPeers.s.sol:SetPeers -vvv
