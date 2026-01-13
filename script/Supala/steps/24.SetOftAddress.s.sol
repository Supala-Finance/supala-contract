// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

contract SetOftAddress is Script, DeployCoreSupala {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();
        _setOftAddress(usdt, MANTLE_TESTNET_USDT_OFT_ADAPTER);
        _setOftAddress(usdc, MANTLE_TESTNET_USDC_OFT_ADAPTER);
        vm.stopBroadcast();
    }
}

// RUN
// forge script SetOftAddress --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script SetOftAddress --broadcast -vvv --verify
// forge script SetOftAddress --broadcast -vvv
// forge script SetOftAddress -vvv
