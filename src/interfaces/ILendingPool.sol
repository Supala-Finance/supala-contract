// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { BorrowParams, RepayParams } from "../lib/LendingPoolHook.sol";
import { SwapHook } from "../lib/SwapHook.sol";

/**
 * @title ILendingPool
 * @notice Interface for lending pool functionality
 * @dev Defines the core lending pool operations including supply, borrow, and repay
 * @author Supala Labs
 * @custom:version 1.0.0
 */
interface ILendingPool {
    /**
     * @notice Returns the address of the lending pool router
     * @return Address of the router contract
     */
    function router() external view returns (address);

    /**
     * @notice Supplies collateral to the lending pool
     * @param _user Address of the user to supply collateral for
     * @param _amount Amount of collateral to supply
     * @dev Users must approve tokens before calling this function
     */
    function supplyCollateral(address _user, uint256 _amount) external payable;

    /**
     * @notice Supplies liquidity to the lending pool
     * @param _user Address of the user to supply liquidity for
     * @param _amount Amount of liquidity to supply
     * @dev Users must approve tokens before calling this function. Liquidity providers earn interest from borrowers.
     */
    function supplyLiquidity(address _user, uint256 _amount) external payable;

    /**
     * @notice Borrows debt from the lending pool (same chain only)
     * @param _amount Amount to borrow
     * @dev Users must have sufficient collateral to borrow. For cross-chain use borrowDebtCrossChain.
     */
    function borrowDebt(uint256 _amount) external payable;

    /**
     * @notice Borrows debt and sends to different chain via LayerZero
     * @param params Struct containing:
     *        - sendParam: LayerZero send parameters
     *        - fee: Messaging fee for cross-chain
     *        - amount: Amount to borrow
     *        - chainId: Destination chain ID (must differ from block.chainid)
     *        - addExecutorLzReceiveOption: LayerZero gas option
     * @dev Users must have sufficient collateral. Chain ID must differ from current chain.
     */
    function borrowDebtCrossChain(BorrowParams calldata params) external payable;

    /**
     * @notice Repays debt using selected token
     * @param params Struct containing:
     *        - user: Address of the user repaying the debt
     *        - token: Address of the token used for repayment
     *        - shares: Number of borrow shares to repay
     *        - amountOutMinimum: Minimum amount of borrow token expected from swap
     *        - fromPosition: Whether to repay from position balance or user wallet
     * @dev Users must approve tokens before calling this function. If token differs from borrow token, it will be swapped.
     */
    function repayWithSelectedToken(RepayParams calldata params) external payable;

    /**
     * @notice Withdraws supplied liquidity by redeeming shares
     * @param _shares Number of shares to redeem for underlying tokens
     * @dev Users must have sufficient shares to withdraw
     */
    function withdrawLiquidity(uint256 _shares) external payable;

    /**
     * @notice Withdraws supplied collateral from the user's position
     * @param _amount Amount of collateral to withdraw
     * @dev Users must have sufficient collateral and maintain healthy positions after withdrawal
     */
    function withdrawCollateral(uint256 _amount) external;

    /**
     * @notice Liquidates an unhealthy position
     * @param borrower The address of the borrower to liquidate
     * @dev Anyone can call this function to liquidate unhealthy positions and receive liquidation bonus
     */
    function liquidation(address borrower) external;

    /**
     * @notice Swaps tokens within a position
     * @param params Struct containing:
     *        - tokenIn: Address of the input token
     *        - tokenOut: Address of the output token
     *        - amountIn: Amount of input tokens to swap
     *        - amountOutMinimum: Slippage tolerance for the swap
     * @return amountOut Amount of output tokens received
     * @dev Allows users to rebalance their collateral by swapping tokens within their position
     */
    function swapTokenByPosition(SwapHook.SwapParams calldata params) external returns (uint256 amountOut);
}
