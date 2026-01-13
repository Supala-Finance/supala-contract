// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { DeploySTokens } from "../DeploySTokens.s.sol";

contract SetLibraries is DeploySTokens {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();

        // Update with the OApp address - use address(0) to use the default oapp from Helper
        _setLibraries(BASE_TESTNET_SUSDC_OFT_ADAPTER);
        _setLibraries(BASE_TESTNET_SUSDT_OFT_ADAPTER);

        vm.stopBroadcast();
    }
}

// RUN
// forge script script/Supala/STokens/steps/1.SetLibraries.s.sol:SetLibraries --broadcast -vvv
// forge script script/Supala/STokens/steps/1.SetLibraries.s.sol:SetLibraries -vvv
