// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { ILendingPool } from "@src/interfaces/ILendingPool.sol";
import { Helper } from "@script/DevTools/Helper.sol";
import { SelectRpc } from "@script/DevTools/SelectRpc.sol";

contract Pool_Router is Script, Helper, SelectRpc {
    // Set the lending pool address here
    address public lendingPool = address(0); // Replace with actual lending pool address

    function setUp() public {
        selectRpc();
    }

    function run() public view {
        require(lendingPool != address(0), "Lending pool address not set");

        ILendingPool pool = ILendingPool(lendingPool);
        address router = pool.router();

        console.log("Lending Pool Address:", lendingPool);
        console.log("Router Address:", router);
    }
}

// RUN
// forge script Pool_Router -vvv
