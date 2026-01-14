// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

/**
 * @title SetOraclePrice
 * @notice Shortcut script to set the price on a custom Pricefeed oracle
 * @dev Set the oracle address and price value to configure
 */
contract SetOraclePrice is Script, DeployCoreSupala {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();

        // Set price for specific oracles
        // Price should be in 8 decimals (e.g., $1.00 = 1e8, $2000 = 2000e8)
        // Uncomment and modify as needed:
        // _setOraclePrice(USDT_USD, 1e8);         // $1.00
        // _setOraclePrice(NATIVE_USDT, 2000e8);   // $2000
        // _setOraclePrice(ETH_USDT, 3500e8);      // $3500
        // _setOraclePrice(BTC_USDT, 100000e8);    // $100,000

        _setOraclePrice(MANTLE_TESTNET_AAPLX_USD, 259.85e8);
        _setOraclePrice(MANTLE_TESTNET_AMZNX_USD, 237.61e8);
        _setOraclePrice(MANTLE_TESTNET_MSFTX_USD, 458.2e8);
        console.log("Oracle price set successfully");

        vm.stopBroadcast();
    }
}

// RUN
// forge script script/Supala/steps/7.3.SetOraclePrice.s.sol:SetOraclePrice --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script script/Supala/steps/7.3.SetOraclePrice.s.sol:SetOraclePrice --broadcast -vvv --verify
// forge script script/Supala/steps/7.3.SetOraclePrice.s.sol:SetOraclePrice --broadcast -vvv
// forge script script/Supala/steps/7.3.SetOraclePrice.s.sol:SetOraclePrice -vvv
