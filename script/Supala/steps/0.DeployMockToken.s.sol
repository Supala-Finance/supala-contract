// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

/**
 * @title DeployMockToken
 * @notice Shortcut script to deploy individual mock tokens
 * @dev Usage: Set TOKEN_NAME environment variable or modify the tokenName variable
 *      Supported tokens: USDT, USDC, WMNT, WETH, AAPLX, AMZNX, MSFTX
 */
contract DeployMockToken is Script, DeployCoreSupala {
    // Change this to deploy different tokens: "USDT", "USDC", "WMNT", "WETH", "AAPLX", "AMZNX", "MSFTX"
    string public tokenName1 = "AAPLX";
    string public tokenName2 = "AMZNX";
    string public tokenName3 = "MSFTX";

    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();
        // Deploy the specified mock token
        address deployedToken1 = _deployMockToken(tokenName1);
        console.log("address public constant %s_MOCK_%s = %s;", chainName, tokenName1, deployedToken1);

        address deployedToken2 = _deployMockToken(tokenName2);
        console.log("address public constant %s_MOCK_%s = %s;", chainName, tokenName2, deployedToken2);

        address deployedToken3 = _deployMockToken(tokenName3);
        console.log("address public constant %s_MOCK_%s = %s;", chainName, tokenName3, deployedToken3);

        vm.stopBroadcast();
    }
}

// RUN EXAMPLES:
// Deploy:
// forge script DeployMockToken --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script DeployMockToken --broadcast -vvv --verify
// forge script DeployMockToken --broadcast -vvv
// forge script DeployMockToken -vvv

// For other tokens, modify the tokenName variable in the contract or create separate scripts:
// DeployMockUSDC.s.sol, DeployMockWMNT.s.sol, DeployMockWETH.s.sol
