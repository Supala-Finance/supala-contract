// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { ILPRouter } from "@src/interfaces/ILPRouter.sol";
import { Helper } from "@script/DevTools/Helper.sol";
import { SelectRpc } from "@script/DevTools/SelectRpc.sol";

contract Router_Liquidation is Script, Helper, SelectRpc {
    // Set the router address here
    address public router = 0xE8055Fe6E88056Fa86eE0f8653675B9b9b7A7d6D; // Replace with actual router address

    // Set the borrower address here
    address public borrower = address(0); // Replace with actual borrower address

    function setUp() public {
        selectRpc();
    }

    function run() public {
        require(router != address(0), "Router address not set");
        require(borrower != address(0), "Borrower address not set");

        ILPRouter lpRouter = ILPRouter(router);

        console.log("Router Address:", router);
        console.log("Borrower:", borrower);

        vm.broadcast();
        (uint256 userBorrowAssets, uint256 liquidationBonus, address userPosition) = lpRouter.liquidation(borrower);

        console.log("User Borrow Assets:", userBorrowAssets);
        console.log("Liquidation Bonus:", liquidationBonus);
        console.log("User Position:", userPosition);
        console.log("Liquidation executed successfully");
    }
}

// RUN
// forge script Router_Liquidation --rpc-url <RPC_URL> --broadcast --private-key <PRIVATE_KEY> -vvv
