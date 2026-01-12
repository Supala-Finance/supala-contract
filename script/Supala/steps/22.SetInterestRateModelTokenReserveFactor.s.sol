// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

contract SetInterestRateModelTokenReserveFactor is Script, DeployCoreSupala {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();
        _setInterestRateModelTokenReserveFactor(usdt, 10e16);
        _setInterestRateModelTokenReserveFactor(usdc, 10e16);
        _setInterestRateModelTokenReserveFactor(wNative, 10e16);
        _setInterestRateModelTokenReserveFactor(native, 10e16);
        _setInterestRateModelTokenReserveFactor(weth, 10e16);
        _setInterestRateModelTokenReserveFactor(wbtc, 10e16);
        vm.stopBroadcast();
    }
}

// RUN
// forge script SetInterestRateModelTokenReserveFactor --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script SetInterestRateModelTokenReserveFactor --broadcast -vvv --verify
// forge script SetInterestRateModelTokenReserveFactor --broadcast -vvv
// forge script SetInterestRateModelTokenReserveFactor -vvv
