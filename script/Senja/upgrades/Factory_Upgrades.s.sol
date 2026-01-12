// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { LendingPoolFactory } from "@src/LendingPoolFactory.sol";
import { Helper } from "@script/DevTools/Helper.sol";
import { SelectRpc } from "@script/DevTools/SelectRpc.sol";

contract Factory_Upgrades is Script, Helper, SelectRpc {
    address public owner = vm.envAddress("PUBLIC_KEY");
    uint256 public privateKey = vm.envUint("PRIVATE_KEY");

    LendingPoolFactory public factory;
    LendingPoolFactory public newImplementation;

    function setUp() public {
        selectRpc();
    }

    function run() public {
        vm.startBroadcast(privateKey);
        newImplementation = new LendingPoolFactory();
        factory = LendingPoolFactory(payable(KAIA_TESTNET_LENDING_POOL_FACTORY));
        factory.upgradeToAndCall(address(newImplementation), "");

        console.log("Factory Address: ", address(factory));
        console.log("New Implementation Address: ", address(newImplementation));
        vm.stopBroadcast();
    }
}

// RUN
// forge script Factory_Upgrades --broadcast -vvv --verify
// forge script Factory_Upgrades -vvv
