// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { ILPRouter } from "@src/interfaces/ILPRouter.sol";
import { Helper } from "@script/DevTools/Helper.sol";
import { SelectRpc } from "@script/DevTools/SelectRpc.sol";

contract Router_BorrowDebt is Script, Helper, SelectRpc {
    // Set the router address here
    address public router = 0xE8055Fe6E88056Fa86eE0f8653675B9b9b7A7d6D; // Replace with actual router address

    // Set the borrow amount here
    uint256 public amount = 0; // Replace with actual amount

    // Set the user address here
    address public user = address(0); // Replace with actual user address

    function setUp() public {
        selectRpc();
    }

    function run() public {
        require(router != address(0), "Router address not set");
        require(amount > 0, "Amount must be greater than 0");
        require(user != address(0), "User address not set");

        ILPRouter lpRouter = ILPRouter(router);

        console.log("Router Address:", router);
        console.log("Amount:", amount);
        console.log("User:", user);

        vm.broadcast();
        (uint256 creatorFee, uint256 protocolFee, uint256 userAmount, uint256 shares) = lpRouter.borrowDebt(amount, user);

        console.log("Creator Fee:", creatorFee);
        console.log("Protocol Fee:", protocolFee);
        console.log("User Amount:", userAmount);
        console.log("Shares minted:", shares);
        console.log("Debt borrowed successfully");
    }
}

// RUN
// forge script Router_BorrowDebt --rpc-url <RPC_URL> --broadcast --private-key <PRIVATE_KEY> -vvv
