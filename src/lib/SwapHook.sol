// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * @title SwapHook
 * @notice Abstract contract containing swap-related errors, events, and structs
 * @dev Provides shared definitions for swap operations across the protocol
 */
abstract contract SwapHook {
    // =============================================================
    //                           ERRORS
    // =============================================================

    /// @notice Thrown when swap parameters are invalid
    /// @param tokenIn Input token address
    /// @param tokenOut Output token address
    error SwapTokenByPositionInvalidParameter(address tokenIn, address tokenOut);

    // =============================================================
    //                           EVENTS
    // =============================================================

    /// @notice Emitted when user swaps tokens in position
    /// @param user User address
    /// @param tokenIn Input token
    /// @param tokenOut Output token
    /// @param amountIn Input amount
    /// @param amountOut Output amount
    event SwapTokenByPosition(address user, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);

    // =============================================================
    //                           STRUCTS
    // =============================================================

    /// @notice Parameters for swapping tokens by position
    struct SwapParams {
        address tokenIn; // Input token address
        address tokenOut; // Output token address
        uint256 amountIn; // Input token amount
        uint256 amountOutMinimum; // Minimum output amount (slippage protection)
        uint24 fee; // Fee amount
    }
}
