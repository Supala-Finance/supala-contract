// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

/**
 * @title SetFactoryMinSupplyAmount
 * @notice Shortcut script to set minimum supply amounts for tokens in LendingPoolFactory
 * @dev Configures minimum liquidity amounts required for each supported token
 */
contract SetFactoryMinSupplyAmount is Script, DeployCoreSupala {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();
        // _setFactoryMinSupplyAmount(usdt, 1e6);
        // _setFactoryMinSupplyAmount(usdc, 1e6);
        // _setFactoryMinSupplyAmount(wNative, 0.1 ether);
        // _setFactoryMinSupplyAmount(native, 0.1 ether);
        // _setFactoryMinSupplyAmount(weth, 0.00005 ether);
        // _setFactoryMinSupplyAmount(wbtc, 0.00001e8);
        _setFactoryMinSupplyAmount(MANTLE_TESTNET_MOCK_AAPLX, 0.0001e18);
        _setFactoryMinSupplyAmount(MANTLE_TESTNET_MOCK_AMZNX, 0.0001e18);
        _setFactoryMinSupplyAmount(MANTLE_TESTNET_MOCK_MSFTX, 0.0001e18);

        console.log("========================================");
        console.log("Factory minimum supply amounts configured");
        console.log("========================================");

        vm.stopBroadcast();
    }
}

// RUN
// forge script SetFactoryMinSupplyAmount --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script SetFactoryMinSupplyAmount --broadcast -vvv --verify
// forge script SetFactoryMinSupplyAmount --broadcast -vvv
// forge script SetFactoryMinSupplyAmount -vvv
