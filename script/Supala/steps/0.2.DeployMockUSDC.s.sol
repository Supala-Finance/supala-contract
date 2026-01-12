// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

contract DeployMockUSDC is Script, DeployCoreSupala {
    function run() public override {
        vm.startBroadcast(privateKey);
        address deployedToken = _deployMockToken("USDC");
        console.log("USDC deployed at: %s", deployedToken);
        vm.stopBroadcast();
    }
}

// RUN
// forge script DeployMockUSDC --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script DeployMockUSDC --broadcast -vvv --verify
// forge script DeployMockUSDC --broadcast -vvv
// forge script DeployMockUSDC -vvv
