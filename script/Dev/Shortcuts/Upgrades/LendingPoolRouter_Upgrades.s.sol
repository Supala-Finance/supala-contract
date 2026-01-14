// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { LendingPoolRouter } from "@src/LendingPoolRouter.sol";
import { Helper } from "@script/DevTools/Helper.sol";
import { SelectRpc } from "@script/DevTools/SelectRpc.sol";

contract LendingPoolRouter_Upgrades is Script, Helper, SelectRpc {
    address public owner = vm.envAddress("PUBLIC_KEY");
    uint256 public privateKey = vm.envUint("PRIVATE_KEY");

    LendingPoolRouter public router;
    LendingPoolRouter public newImplementation;

    // Set the router proxy address here
    address public routerProxy = address(0); // Replace with actual router proxy address

    function setUp() public {
        selectRpc();
    }

    function run() public {
        require(routerProxy != address(0), "Router proxy address not set");

        vm.startBroadcast(privateKey);

        // Deploy new implementation
        newImplementation = new LendingPoolRouter();

        // Get the proxy instance
        router = LendingPoolRouter(payable(routerProxy));

        // Upgrade to new implementation
        router.upgradeToAndCall(address(newImplementation), "");

        console.log("Router Proxy Address:", address(router));
        console.log("New Implementation Address:", address(newImplementation));

        vm.stopBroadcast();
    }
}

// RUN
// forge script LendingPoolRouter_Upgrades --broadcast -vvv --verify
// forge script LendingPoolRouter_Upgrades -vvv
// 18579380314391639
