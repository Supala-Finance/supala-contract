// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script } from "forge-std/Script.sol";
import { LendingPoolFactory } from "@src/LendingPoolFactory.sol";
import { Helper } from "@script/DevTools/Helper.sol";
import { SelectRpc } from "@script/DevTools/SelectRpc.sol";

contract Factory_GrantRole is Script, Helper, SelectRpc {
    LendingPoolFactory public factory;

    address public owner = vm.envAddress("PUBLIC_KEY");
    uint256 public privateKey = vm.envUint("PRIVATE_KEY");

    function setUp() public {
        selectRpc();
    }

    function run() public {
        factory = LendingPoolFactory(payable(KAIA_TESTNET_LENDING_POOL_FACTORY));

        vm.startBroadcast(privateKey);
        factory.grantRole(DEFAULT_ADMIN_ROLE, owner);
        factory.grantRole(PAUSER_ROLE, owner);
        factory.grantRole(UPGRADER_ROLE, owner);
        factory.grantRole(OWNER_ROLE, owner);
        vm.stopBroadcast();
    }
}

// RUN
// forge script Factory_GrantRole --broadcast -vvv
// forge script Factory_GrantRole -vvv
