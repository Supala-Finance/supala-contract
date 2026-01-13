// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { DeploySTokens } from "../DeploySTokens.s.sol";

contract DeployOft is DeploySTokens {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();

        // Deploy OFT Adapter - Update with the token address
        // Example: _deployOft(BASE_sUSDT);
        _deployOft(BASE_TESTNET_SUSDT); // Replace with actual token address
        _deployOft(BASE_TESTNET_SUSDC); // Replace with actual token address

        vm.stopBroadcast();
    }
}

// RUN
// forge script script/Supala/STokens/steps/0.1.DeployOft.s.sol:DeployOft --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script script/Supala/STokens/steps/0.1.DeployOft.s.sol:DeployOft --broadcast -vvv
// forge script script/Supala/STokens/steps/0.1.DeployOft.s.sol:DeployOft -vvv
