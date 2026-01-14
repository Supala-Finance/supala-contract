// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { ILendingPool } from "@src/interfaces/ILendingPool.sol";
import { Helper } from "@script/DevTools/Helper.sol";
import { SelectRpc } from "@script/DevTools/SelectRpc.sol";

contract Pool_WithdrawCollateral is Script, Helper, SelectRpc {
    // Set the lending pool address here
    address public lendingPool = address(0); // Replace with actual lending pool address

    // Set the amount here
    uint256 public amount = 0; // Replace with actual amount

    function setUp() public {
        selectRpc();
    }

    function run() public {
        require(lendingPool != address(0), "Lending pool address not set");
        require(amount > 0, "Amount must be greater than 0");

        ILendingPool pool = ILendingPool(lendingPool);

        console.log("Lending Pool Address:", lendingPool);
        console.log("Amount:", amount);

        vm.broadcast();
        pool.withdrawCollateral(amount);

        console.log("Collateral withdrawn successfully");
    }
}

// RUN
// forge script Pool_WithdrawCollateral --rpc-url <RPC_URL> --broadcast --private-key <PRIVATE_KEY> -vvv
