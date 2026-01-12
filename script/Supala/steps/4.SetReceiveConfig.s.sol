// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

contract SetReceiveConfig is Script, DeployCoreSupala {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();
        _setReceiveConfig(MANTLE_TESTNET_USDT_OFT_ADAPTER);
        _setReceiveConfig(MANTLE_TESTNET_USDC_OFT_ADAPTER);
        vm.stopBroadcast();
    }
}

// RUN
// forge script SetReceiveConfig --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script SetReceiveConfig --broadcast -vvv --verify
// forge script SetReceiveConfig --broadcast -vvv
// forge script SetReceiveConfig -vvv
