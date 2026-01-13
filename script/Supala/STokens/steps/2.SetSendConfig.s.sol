// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { DeploySTokens } from "../DeploySTokens.s.sol";

contract SetSendConfig is DeploySTokens {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();

        // Update with the OApp address - use address(0) to use the default oapp from Helper
        _setSendConfig(BASE_TESTNET_SUSDC_OFT_ADAPTER);
        _setSendConfig(BASE_TESTNET_SUSDT_OFT_ADAPTER);

        vm.stopBroadcast();
    }
}

// RUN
// forge script script/Supala/STokens/steps/2.SetSendConfig.s.sol:SetSendConfig --broadcast -vvv
// forge script script/Supala/STokens/steps/2.SetSendConfig.s.sol:SetSendConfig -vvv
