// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

/**
 * @title DeployCustomOracle
 * @notice Shortcut script to deploy a custom Pricefeed oracle for a token
 * @dev Set the token address to deploy a Pricefeed oracle for
 */
contract DeployCustomOracle is Script, DeployCoreSupala {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();

        // Deploy custom oracle for specific tokens
        // Uncomment and modify as needed:
        // _deployCustomOracle(usdt);
        // _deployCustomOracle(wNative);
        // _deployCustomOracle(weth);
        // _deployCustomOracle(wbtc);
        _deployCustomOracle(MANTLE_TESTNET_MOCK_AAPLX);
        _deployCustomOracle(MANTLE_TESTNET_MOCK_AMZNX);
        _deployCustomOracle(MANTLE_TESTNET_MOCK_MSFTX);

        console.log("Custom oracle deployment completed");

        vm.stopBroadcast();
    }
}

// RUN
// forge script script/Supala/steps/7.2.DeployCustomOracle.s.sol:DeployCustomOracle --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script script/Supala/steps/7.2.DeployCustomOracle.s.sol:DeployCustomOracle --broadcast -vvv --verify
// forge script script/Supala/steps/7.2.DeployCustomOracle.s.sol:DeployCustomOracle --broadcast -vvv
// forge script script/Supala/steps/7.2.DeployCustomOracle.s.sol:DeployCustomOracle -vvv
