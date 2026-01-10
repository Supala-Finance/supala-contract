// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { SendParam } from "@layerzerolabs/oft-evm/contracts/interfaces/IOFT.sol";
import { MessagingFee } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";

// =============================================================
//                           STRUCTS
// =============================================================

/// @notice Parameters for repaying debt with a selected token
struct RepayParams {
    address user; // User address
    address token; // Token to use for repayment
    uint256 shares; // Shares to repay
    uint256 amountOutMinimum; // Minimum output amount (slippage protection)
    bool fromPosition; // Whether to use tokens from position or wallet
    uint24 fee; // DEX fee tier (e.g., 1000 = 0.1%)
}

/// @notice Parameters for borrowing debt
struct BorrowParams {
    SendParam sendParam; // LayerZero send parameters
    MessagingFee fee; // Messaging fee for cross-chain
    uint256 amount; // Amount to borrow
    uint256 chainId; // Destination chain ID
    uint128 addExecutorLzReceiveOption; // LayerZero gas option
}

abstract contract LendingPoolHook {
    // =============================================================
    //                           ERRORS
    // =============================================================

    /// @notice Thrown when user has insufficient collateral for an operation
    /// @param amount Requested amount
    /// @param expectedAmount Required amount
    error InsufficientCollateral(uint256 amount, uint256 expectedAmount);

    /// @notice Thrown when zero amount is provided
    error ZeroAmount();

    /// @notice Thrown when caller is not authorized
    /// @param executor Address of unauthorized caller
    error NotAuthorized(address executor);

    /// @notice Thrown when token transfer fails
    /// @param amount Amount that failed to transfer
    error TransferFailed(uint256 amount);

    /// @notice Thrown when liquidity supply amount doesn't match expected
    /// @param amount Provided amount
    /// @param expectedAmount Expected amount
    error SupplyLiquidityWrongInputAmount(uint256 amount, uint256 expectedAmount);

    /// @notice Thrown when collateral amount doesn't match expected
    /// @param amount Provided amount
    /// @param expectedAmount Expected amount
    error CollateralWrongInputAmount(uint256 amount, uint256 expectedAmount);

    /// @notice Thrown when position already exists for user
    /// @param positionAddress Existing position address
    error PositionAlreadyCreated(address positionAddress);

    /// @notice Thrown when input amount is wrong
    /// @param expectedAmount Expected amount
    /// @param actualAmount Actual amount provided
    error WrongInputAmount(uint256 expectedAmount, uint256 actualAmount);

    /// @notice Thrown when borrowing on same chain
    error SameChain();

    // =============================================================
    //                           EVENTS
    // =============================================================

    /// @notice Emitted when user supplies liquidity
    /// @param user User address
    /// @param amount Amount supplied
    /// @param shares Shares received
    event SupplyLiquidity(address user, uint256 amount, uint256 shares);

    /// @notice Emitted when user withdraws liquidity
    /// @param user User address
    /// @param amount Amount withdrawn
    /// @param shares Shares burned
    event WithdrawLiquidity(address user, uint256 amount, uint256 shares);

    /// @notice Emitted when user supplies collateral
    /// @param positionAddress Position contract address
    /// @param user User address
    /// @param amount Amount of collateral supplied
    event SupplyCollateral(address positionAddress, address user, uint256 amount);

    /// @notice Emitted when user repays debt
    /// @param user User address
    /// @param amount Amount repaid
    /// @param shares Shares burned
    event RepayByPosition(address user, uint256 amount, uint256 shares);

    /// @notice Emitted when new position is created
    /// @param user User address
    /// @param positionAddress Position contract address
    event CreatePosition(address user, address positionAddress);

    /// @notice Emitted when user borrows assets
    /// @param user User address
    /// @param protocolFee Protocol fee taken
    /// @param userAmount Amount user receives
    /// @param shares Borrow shares received
    /// @param amount Amount borrowed (total)
    event BorrowDebt(address user, uint256 protocolFee, uint256 userAmount, uint256 shares, uint256 amount);

    /// @notice Emitted when user borrows assets cross-chain
    /// @param user User address
    /// @param protocolFee Protocol fee taken
    /// @param userAmount Amount user receives cross-chain
    /// @param shares Borrow shares received
    /// @param params Borrow parameters
    event BorrowDebtCrossChain(address user, uint256 protocolFee, uint256 userAmount, uint256 shares, BorrowParams params);

    /// @notice Emitted when user withdraws collateral
    /// @param user User address
    /// @param amount Amount withdrawn
    event WithdrawCollateral(address user, uint256 amount);

    /// @notice Emitted when a position is liquidated
    /// @param borrower Borrower address
    /// @param borrowToken Borrow token address
    /// @param collateralToken Collateral token address
    /// @param userBorrowAssets User's borrow assets
    /// @param liquidationBonus Liquidation bonus allocation
    event Liquidation(address borrower, address borrowToken, address collateralToken, uint256 userBorrowAssets, uint256 liquidationBonus);

    // =============================================================
    //                           CONSTANTS
    // =============================================================

    /// @notice Role identifier for accounts that have owner privileges
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    /// @notice Role identifier for accounts that can upgrade the contract
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
}
