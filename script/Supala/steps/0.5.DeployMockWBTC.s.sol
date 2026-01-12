// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

contract DeployMockWBTC is Script, DeployCoreSupala {
    function run() public override {
        vm.startBroadcast(privateKey);
        address deployedToken = _deployMockToken("WBTC");
        console.log("WBTC deployed at: %s", deployedToken);
        vm.stopBroadcast();
    }
}

// RUN
// forge script DeployMockWBTC --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script DeployMockWBTC --broadcast -vvv --verify
// forge script DeployMockWBTC --broadcast -vvv
// forge script DeployMockWBTC -vvv
