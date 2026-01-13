// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { DeploySTokens } from "../DeploySTokens.s.sol";

contract SetEnforcedOptions is DeploySTokens {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();

        _setEnforcedOptions(BASE_TESTNET_SUSDT_OFT_ADAPTER);
        _setEnforcedOptions(BASE_TESTNET_SUSDC_OFT_ADAPTER);

        vm.stopBroadcast();
    }
}

// RUN
// forge script script/Supala/STokens/steps/5.SetEnforcedOptions.s.sol:SetEnforcedOptions --broadcast -vvv
// forge script script/Supala/STokens/steps/5.SetEnforcedOptions.s.sol:SetEnforcedOptions -vvv
