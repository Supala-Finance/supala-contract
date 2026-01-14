// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { ILendingPool } from "@src/interfaces/ILendingPool.sol";
import { RepayParams } from "@src/lib/LendingPoolHook.sol";
import { Helper } from "@script/DevTools/Helper.sol";
import { SelectRpc } from "@script/DevTools/SelectRpc.sol";

contract Pool_RepayWithSelectedToken is Script, Helper, SelectRpc {
    // Set the lending pool address here
    address public lendingPool = address(0); // Replace with actual lending pool address

    // Set repay parameters here
    address public user = address(0); // User address
    address public token = address(0); // Token to use for repayment
    uint256 public shares = 0; // Shares to repay
    uint256 public amountOutMinimum = 0; // Minimum output amount (slippage protection)
    bool public fromPosition = false; // Whether to use tokens from position or wallet
    uint24 public fee = 3000; // DEX fee tier (e.g., 3000 = 0.3%)

    function setUp() public {
        selectRpc();
    }

    function run() public {
        require(lendingPool != address(0), "Lending pool address not set");
        require(user != address(0), "User address not set");
        require(token != address(0), "Token address not set");
        require(shares > 0, "Shares must be greater than 0");

        ILendingPool pool = ILendingPool(lendingPool);

        // Construct RepayParams
        RepayParams memory params =
            RepayParams({ user: user, token: token, shares: shares, amountOutMinimum: amountOutMinimum, fromPosition: fromPosition, fee: fee });

        console.log("Lending Pool Address:", lendingPool);
        console.log("User:", user);
        console.log("Token:", token);
        console.log("Shares:", shares);
        console.log("From Position:", fromPosition);

        vm.broadcast();
        pool.repayWithSelectedToken(params);

        console.log("Debt repaid with selected token successfully");
    }
}

// RUN
// forge script Pool_RepayWithSelectedToken --rpc-url <RPC_URL> --broadcast --private-key <PRIVATE_KEY> -vvv
