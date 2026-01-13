// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { DeploySTokens } from "../DeploySTokens.s.sol";

contract DeploySToken is DeploySTokens {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();

        // Deploy SToken - Update the parameters as needed
        _deploySToken("Senja USDC", "sUSDC", 6);
        _deploySToken("Senja USDT", "sUSDT", 6);

        vm.stopBroadcast();
    }
}

// RUN
// forge script script/Supala/STokens/steps/0.DeploySToken.s.sol:DeploySToken --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script script/Supala/STokens/steps/0.DeploySToken.s.sol:DeploySToken --broadcast -vvv
// forge script script/Supala/STokens/steps/0.DeploySToken.s.sol:DeploySToken -vvv
