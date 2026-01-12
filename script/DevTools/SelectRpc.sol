// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script } from "forge-std/Script.sol";

contract SelectRpc is Script {
    function selectRpc() public {
        vm.createSelectFork(vm.rpcUrl("kaia_testnet"));
    }
}
