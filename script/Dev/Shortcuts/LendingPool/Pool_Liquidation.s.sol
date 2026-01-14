// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { ILendingPool } from "@src/interfaces/ILendingPool.sol";
import { Helper } from "@script/DevTools/Helper.sol";
import { SelectRpc } from "@script/DevTools/SelectRpc.sol";

contract Pool_Liquidation is Script, Helper, SelectRpc {
    // Set the lending pool address here
    address public lendingPool = address(0); // Replace with actual lending pool address

    // Set the borrower address here
    address public borrower = address(0); // Replace with actual borrower address

    function setUp() public {
        selectRpc();
    }

    function run() public {
        require(lendingPool != address(0), "Lending pool address not set");
        require(borrower != address(0), "Borrower address not set");

        ILendingPool pool = ILendingPool(lendingPool);

        console.log("Lending Pool Address:", lendingPool);
        console.log("Borrower:", borrower);

        vm.broadcast();
        pool.liquidation(borrower);

        console.log("Liquidation executed successfully");
    }
}

// RUN
// forge script Pool_Liquidation --rpc-url <RPC_URL> --broadcast --private-key <PRIVATE_KEY> -vvv
