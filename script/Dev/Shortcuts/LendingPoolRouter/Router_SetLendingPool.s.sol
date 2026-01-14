// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { ILPRouter } from "@src/interfaces/ILPRouter.sol";
import { Helper } from "@script/DevTools/Helper.sol";
import { SelectRpc } from "@script/DevTools/SelectRpc.sol";

contract Router_SetLendingPool is Script, Helper, SelectRpc {
    // Set the router address here
    address public router = 0xE8055Fe6E88056Fa86eE0f8653675B9b9b7A7d6D; // Replace with actual router address

    // Set the new lending pool address here
    address public newLendingPool = address(0); // Replace with actual lending pool address

    function setUp() public {
        selectRpc();
    }

    function run() public {
        require(router != address(0), "Router address not set");
        require(newLendingPool != address(0), "Lending pool address not set");

        ILPRouter lpRouter = ILPRouter(router);

        console.log("Router Address:", router);
        console.log("New Lending Pool:", newLendingPool);

        vm.broadcast();
        lpRouter.setLendingPool(newLendingPool);

        console.log("Lending pool set successfully");
    }
}

// RUN
// forge script Router_SetLendingPool --rpc-url <RPC_URL> --broadcast --private-key <PRIVATE_KEY> -vvv
