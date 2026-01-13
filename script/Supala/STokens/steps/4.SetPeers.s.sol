// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { DeploySTokens } from "../DeploySTokens.s.sol";

contract SetPeers is DeploySTokens {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();

        _setPeers(BASE_TESTNET_SUSDC_OFT_ADAPTER, MANTLE_TESTNET_USDC_OFT_ADAPTER);
        _setPeers(BASE_TESTNET_SUSDT_OFT_ADAPTER, MANTLE_TESTNET_USDT_OFT_ADAPTER);

        vm.stopBroadcast();
    }
}

// RUN
// forge script script/Supala/STokens/steps/4.SetPeers.s.sol:SetPeers --broadcast -vvv
// forge script script/Supala/STokens/steps/4.SetPeers.s.sol:SetPeers -vvv
