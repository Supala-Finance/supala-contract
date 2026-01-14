// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { ILPRouter } from "@src/interfaces/ILPRouter.sol";
import { Helper } from "@script/DevTools/Helper.sol";
import { SelectRpc } from "@script/DevTools/SelectRpc.sol";

contract Router_WithdrawLiquidity is Script, Helper, SelectRpc {
    // Set the router address here
    address public router = 0xE8055Fe6E88056Fa86eE0f8653675B9b9b7A7d6D; // Replace with actual router address

    // Set the shares amount here
    uint256 public shares = 0; // Replace with actual shares amount

    // Set the user address here
    address public user = address(0); // Replace with actual user address

    function setUp() public {
        selectRpc();
    }

    function run() public {
        require(router != address(0), "Router address not set");
        require(shares > 0, "Shares must be greater than 0");
        require(user != address(0), "User address not set");

        ILPRouter lpRouter = ILPRouter(router);

        console.log("Router Address:", router);
        console.log("Shares:", shares);
        console.log("User:", user);

        vm.broadcast();
        uint256 amount = lpRouter.withdrawLiquidity(shares, user);

        console.log("Amount withdrawn:", amount);
        console.log("Liquidity withdrawn successfully");
    }
}

// RUN
// forge script Router_WithdrawLiquidity --rpc-url <RPC_URL> --broadcast --private-key <PRIVATE_KEY> -vvv
