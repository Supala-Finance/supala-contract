// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

contract DeployMockWMNT is Script, DeployCoreSupala {
    function run() public override {
        vm.startBroadcast(privateKey);
        address deployedToken = _deployMockToken("WMNT");
        console.log("WMNT deployed at: %s", deployedToken);
        vm.stopBroadcast();
    }
}

// RUN
// forge script DeployMockWMNT --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script DeployMockWMNT --broadcast -vvv --verify
// forge script DeployMockWMNT --broadcast -vvv
// forge script DeployMockWMNT -vvv
