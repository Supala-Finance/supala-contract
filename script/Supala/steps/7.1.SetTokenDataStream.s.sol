// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

/**
 * @title SetTokenDataStream
 * @notice Shortcut script to configure token price feeds in TokenDataStream
 * @dev Set the token and oracle addresses in the run() function
 */
contract SetTokenDataStream is Script, DeployCoreSupala {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();

        // Example: Configure multiple tokens
        // _setTokenDataStream(usdt, USDT_USD);
        // _setTokenDataStream(wNative, NATIVE_USDT);
        // _setTokenDataStream(native, NATIVE_USDT);
        // _setTokenDataStream(weth, ETH_USDT);
        // _setTokenDataStream(wbtc, BTC_USDT);

        _setTokenDataStream(MANTLE_TESTNET_MOCK_AAPLX, MANTLE_TESTNET_AAPLX_USD);
        _setTokenDataStream(MANTLE_TESTNET_MOCK_AMZNX, MANTLE_TESTNET_AMZNX_USD);
        _setTokenDataStream(MANTLE_TESTNET_MOCK_MSFTX, MANTLE_TESTNET_MSFTX_USD);

        console.log("TokenDataStream price feeds configured successfully");

        vm.stopBroadcast();
    }
}

// RUN
// forge script SetTokenDataStream --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script SetTokenDataStream --broadcast -vvv --verify
// forge script SetTokenDataStream --broadcast -vvv
// forge script SetTokenDataStream -vvv
