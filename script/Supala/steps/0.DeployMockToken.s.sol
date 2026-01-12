// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

/**
 * @title DeployMockToken
 * @notice Shortcut script to deploy individual mock tokens
 * @dev Usage: Set TOKEN_NAME environment variable or modify the tokenName variable
 *      Supported tokens: USDT, USDC, WMNT, WETH
 */
contract DeployMockToken is Script, DeployCoreSupala {
    // Change this to deploy different tokens: "USDT", "USDC", "WMNT", "WETH"
    string public tokenName = "USDT";

    function run() public override {
        vm.startBroadcast(privateKey);

        // Deploy the specified mock token
        address deployedToken = _deployMockToken(tokenName);

        console.log("========================================");
        console.log("Mock Token Deployed:");
        console.log("Token Name: %s", tokenName);
        console.log("Token Address: %s", deployedToken);
        console.log("========================================");

        vm.stopBroadcast();
    }
}

// RUN EXAMPLES:
// Deploy USDT:
// forge script DeployMockToken --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script DeployMockToken --broadcast -vvv --verify
// forge script DeployMockToken --broadcast -vvv
// forge script DeployMockToken -vvv

// For other tokens, modify the tokenName variable in the contract or create separate scripts:
// DeployMockUSDC.s.sol, DeployMockWMNT.s.sol, DeployMockWETH.s.sol
