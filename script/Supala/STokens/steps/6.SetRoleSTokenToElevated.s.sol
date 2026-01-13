// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { DeploySTokens } from "../DeploySTokens.s.sol";

contract SetRoleSTokenToElevated is DeploySTokens {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();

        // Grant MINTER_ROLE to ElevatedMinterBurner contracts
        _setRoleSTokenToElevated(BASE_TESTNET_SUSDC, BASE_TESTNET_SUSDC_ELEVATED_MINTER_BURNER);
        _setRoleSTokenToElevated(BASE_TESTNET_SUSDT, BASE_TESTNET_SUSDT_ELEVATED_MINTER_BURNER);

        vm.stopBroadcast();
    }
}

// RUN
// forge script script/Supala/STokens/steps/6.SetRoleSTokenToElevated.s.sol:SetRoleSTokenToElevated --broadcast -vvv --verify
// forge script script/Supala/STokens/steps/6.SetRoleSTokenToElevated.s.sol:SetRoleSTokenToElevated --broadcast -vvv
// forge script script/Supala/STokens/steps/6.SetRoleSTokenToElevated.s.sol:SetRoleSTokenToElevated -vvv
