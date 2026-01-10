// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

abstract contract PositionHook {
    // =============================================================
    //                           ERRORS
    // =============================================================

    /**
     * @notice Error thrown when there are insufficient tokens for an operation
     */
    error InsufficientBalance();

    /**
     * @notice Error thrown when attempting to process a zero amount
     */
    error ZeroAmount();

    /**
     * @notice Error thrown when a withdrawal operation is not authorized
     */
    error NotForWithdraw();

    /**
     * @notice Error thrown when a swap operation is not authorized
     */
    error NotForSwap();

    /**
     * @notice Error thrown when a native token transfer fails
     */
    error TransferFailed();

    /**
     * @notice Error thrown when an invalid parameter is provided
     */
    error InvalidParameter();

    /**
     * @notice Error thrown when oracle on token is not set
     */
    error OracleOnTokenNotSet();

    /**
     * @notice Error thrown when attempting to swap the same token
     */
    error SameToken();

    /**
     * @notice Error thrown when a function is called by unauthorized address
     */
    error OnlyForLendingPool();

    /**
     * @notice Error thrown when the output amount is less than the minimum amount
     * @param amountOut The actual output amount received
     * @param amountOutMinimum The minimum expected output amount
     */
    error InsufficientOutputAmount(uint256 amountOut, uint256 amountOutMinimum);

    // =============================================================
    //                           EVENTS
    // =============================================================

    /**
     * @notice Emitted when collateral is withdrawn from the position
     * @param user The address of the user withdrawing collateral
     * @param amount The amount of collateral withdrawn
     */
    event WithdrawCollateral(address indexed user, uint256 amount);

    // =============================================================
    //                           CONSTANTS
    // =============================================================

    /// @notice Role identifier for accounts that have owner privileges
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    /// @notice Role identifier for accounts that can upgrade the contract
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
}
