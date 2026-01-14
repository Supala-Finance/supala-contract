// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { LendingPool } from "@src/LendingPool.sol";
import { Helper } from "@script/DevTools/Helper.sol";
import { SelectRpc } from "@script/DevTools/SelectRpc.sol";

contract LendingPool_Upgrades is Script, Helper, SelectRpc {
    address public owner = vm.envAddress("PUBLIC_KEY");
    uint256 public privateKey = vm.envUint("PRIVATE_KEY");

    LendingPool public lendingPool;
    LendingPool public newImplementation;

    // Set the lending pool proxy address here
    address public lendingPoolProxy = 0xc635dB9f6A988eE1e83CB9fb786Eb3eC3670f991; // Replace with actual lending pool proxy address

    function setUp() public {
        selectRpc();
    }

    function run() public {
        require(lendingPoolProxy != address(0), "Lending pool proxy address not set");

        vm.startBroadcast(privateKey);

        // Deploy new implementation
        newImplementation = new LendingPool();

        // Get the proxy instance
        lendingPool = LendingPool(payable(lendingPoolProxy));

        // Upgrade to new implementation
        lendingPool.upgradeToAndCall(address(newImplementation), "");

        console.log("Lending Pool Proxy Address:", address(lendingPool));
        console.log("New Implementation Address:", address(newImplementation));

        vm.stopBroadcast();
    }
}

// RUN
// forge script LendingPool_Upgrades --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script LendingPool_Upgrades -vvv
