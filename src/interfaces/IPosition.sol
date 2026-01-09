// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { SwapHook } from "../lib/SwapHook.sol";

/**
 * @title IPosition
 * @dev Interface for position management functionality
 * @notice This interface defines the contract for managing user positions and trading operations
 * @author Supala Labs
 * @custom:version 1.0.0
 */
interface IPosition {
    /**
     * @dev Returns the current counter value
     * @return The current counter value
     * @notice This function tracks the number of positions or operations
     */
    function counter() external view returns (uint256);

    /**
     * @dev Returns the owner address of the position
     * @return The owner's address
     */
    function owner() external view returns (address);

    /**
     * @dev Returns the lending pool address
     * @return The lending pool contract address
     */
    function lpAddress() external view returns (address);

    /**
     * @dev Returns the ID of a token in the token list
     * @param _token Address of the token
     * @return The ID of the token in the list
     */
    function tokenListsId(address _token) external view returns (uint256);

    /**
     * @dev Returns the token address at a specific index
     * @param _index The index in the token list
     * @return The address of the token at the specified index
     */
    function tokenLists(uint256 _index) external view returns (address);

    /**
     * @dev Withdraws collateral from a position
     * @param amount Amount of collateral to withdraw
     * @param _user Address of the user withdrawing collateral
     * @notice This function allows users to withdraw their collateral
     * @custom:security Users can only withdraw their own collateral
     */
    function withdrawCollateral(uint256 amount, address _user) external;

    /**
     * @dev Swaps tokens within a position
     * @param params Struct containing:
     *        - tokenIn: Address of the input token
     *        - tokenOut: Address of the output token
     *        - amountIn: Amount of input tokens to swap
     *        - amountOutMinimum: Slippage tolerance for the swap
     * @return amountOut Amount of output tokens received
     * @notice This function allows users to swap tokens within their position
     * @custom:security Users must have sufficient balance of the input token
     */
    function swapTokenByPosition(SwapHook.SwapParams calldata params) external returns (uint256 amountOut);

    /**
     * @notice Pauses all pausable functions in the contract
     * @dev Can only be called by accounts with OWNER_ROLE
     */
    function pause() external;

    /**
     * @notice Unpauses all pausable functions in the contract
     * @dev Can only be called by accounts with OWNER_ROLE
     */
    function unpause() external;

    /**
     * @dev Calculates token conversion rates using oracle prices
     * @param _tokenIn Address of the input token
     * @param _tokenOut Address of the output token
     * @param _amountIn Amount of input tokens
     * @return The calculated output amount
     * @notice This function performs price-based token calculations
     */
    function _tokenCalculator(address _tokenIn, address _tokenOut, uint256 _amountIn) external view returns (uint256);

    /**
     * @dev Repays debt using selected token
     * @param params Struct containing:
     *        - tokenIn: Address of the token used for repayment
     *        - tokenOut: Address of the borrow token (output)
     *        - amountIn: Amount to repay
     *        - amountOutMinimum: Minimum amount of output tokens expected from swap
     *        - fee: DEX fee tier
     * @notice This function allows users to repay their debt
     * @custom:security Users must approve tokens before calling this function
     */
    function repayWithSelectedToken(SwapHook.SwapParams calldata params) external payable;

    /**
     * @dev Returns the total collateral value in the position
     * @return The total collateral amount
     */
    function totalCollateral() external view returns (uint256);

    /**
     * @notice Liquidates a position and transfers collateral to the liquidator
     * @param _liquidator Address of the liquidator
     * @param _liquidationBonus Liquidation bonus allocation
     */
    function liquidation(address _liquidator, uint256 _liquidationBonus) external;

    /**
     * @notice Swaps a token to the borrow token
     * @param params Struct containing:
     *        - tokenIn: Address of the input token
     *        - tokenOut: Address of the borrow token (output)
     *        - amountIn: Amount of input tokens to swap
     *        - amountOutMinimum: Minimum amount of borrow tokens expected from swap
     *        - fee: DEX fee tier
     */
    function swapTokenToBorrow(SwapHook.SwapParams calldata params) external;
}
