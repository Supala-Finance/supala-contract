// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

contract DeployOFT is Script, DeployCoreSupala {
    function run() public override {
        vm.startBroadcast(privateKey);
        _getUtils();

        _deployOft(usdc);
        _deployOft(usdt);
        // _deployOft(wNative);
        // _deployOft(weth);
        // _deployOft(wbtc);

        vm.stopBroadcast();
    }
}

// RUN
// forge script script/Supala/steps/1.DeployOft.s.sol:DeployOFT --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script script/Supala/steps/1.DeployOft.s.sol:DeployOFT --broadcast -vvv --verify
// forge script script/Supala/steps/1.DeployOft.s.sol:DeployOFT --broadcast -vvv
// forge script script/Supala/steps/1.DeployOft.s.sol:DeployOFT -vvv
