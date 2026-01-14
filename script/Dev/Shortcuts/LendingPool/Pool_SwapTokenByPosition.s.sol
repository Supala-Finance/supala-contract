// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { ILendingPool } from "@src/interfaces/ILendingPool.sol";
import { SwapHook } from "@src/lib/SwapHook.sol";
import { Helper } from "@script/DevTools/Helper.sol";
import { SelectRpc } from "@script/DevTools/SelectRpc.sol";

contract Pool_SwapTokenByPosition is Script, Helper, SelectRpc {
    // Set the lending pool address here
    address public lendingPool = address(0); // Replace with actual lending pool address

    // Set swap parameters here
    address public tokenIn = address(0); // Input token address
    address public tokenOut = address(0); // Output token address
    uint256 public amountIn = 0; // Input token amount
    uint256 public amountOutMinimum = 0; // Minimum output amount (slippage protection)
    uint24 public fee = 3000; // DEX fee tier (e.g., 3000 = 0.3%)

    function setUp() public {
        selectRpc();
    }

    function run() public {
        require(lendingPool != address(0), "Lending pool address not set");
        require(tokenIn != address(0), "Token in address not set");
        require(tokenOut != address(0), "Token out address not set");
        require(amountIn > 0, "Amount in must be greater than 0");

        ILendingPool pool = ILendingPool(lendingPool);

        // Construct SwapParams
        SwapHook.SwapParams memory params =
            SwapHook.SwapParams({ tokenIn: tokenIn, tokenOut: tokenOut, amountIn: amountIn, amountOutMinimum: amountOutMinimum, fee: fee });

        console.log("Lending Pool Address:", lendingPool);
        console.log("Token In:", tokenIn);
        console.log("Token Out:", tokenOut);
        console.log("Amount In:", amountIn);
        console.log("Min Amount Out:", amountOutMinimum);

        vm.broadcast();
        uint256 amountOut = pool.swapTokenByPosition(params);

        console.log("Amount Out:", amountOut);
        console.log("Token swapped successfully");
    }
}

// RUN
// forge script Pool_SwapTokenByPosition --rpc-url <RPC_URL> --broadcast --private-key <PRIVATE_KEY> -vvv
