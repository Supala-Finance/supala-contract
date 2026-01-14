// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { ILPRouter } from "@src/interfaces/ILPRouter.sol";
import { Helper } from "@script/DevTools/Helper.sol";
import { SelectRpc } from "@script/DevTools/SelectRpc.sol";

contract Router_AccrueInterest is Script, Helper, SelectRpc {
    // Set the router address here
    address public router = 0xE8055Fe6E88056Fa86eE0f8653675B9b9b7A7d6D; // Replace with actual router address

    function setUp() public {
        selectRpc();
    }

    function run() public {
        require(router != address(0), "Router address not set");

        ILPRouter lpRouter = ILPRouter(router);

        console.log("Router Address:", router);

        vm.broadcast();
        lpRouter.accrueInterest();

        console.log("Interest accrued successfully");
    }
}

// RUN
// forge script Router_AccrueInterest --rpc-url <RPC_URL> --broadcast --private-key <PRIVATE_KEY> -vvv
