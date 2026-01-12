// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

contract DeployMockWETH is Script, DeployCoreSupala {
    function run() public override {
        vm.startBroadcast(privateKey);
        address deployedToken = _deployMockToken("WETH");
        console.log("WETH deployed at: %s", deployedToken);
        vm.stopBroadcast();
    }
}

// RUN
// forge script DeployMockWETH --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script DeployMockWETH --broadcast -vvv --verify
// forge script DeployMockWETH --broadcast -vvv
// forge script DeployMockWETH -vvv
