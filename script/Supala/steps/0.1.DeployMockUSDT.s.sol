// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { DeployCoreSupala } from "../DeployCoreSupala.s.sol";

contract DeployMockUSDT is Script, DeployCoreSupala {
    function run() public override {
        vm.startBroadcast(privateKey);
        address deployedToken = _deployMockToken("USDT");
        console.log("USDT deployed at: %s", deployedToken);
        vm.stopBroadcast();
    }
}

// RUN
// forge script DeployMockUSDT --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script DeployMockUSDT --broadcast -vvv --verify
// forge script DeployMockUSDT --broadcast -vvv
// forge script DeployMockUSDT -vvv
