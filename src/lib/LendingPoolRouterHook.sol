// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * @title LendingPoolRouterHook
 * @author Supala Labs
 * @notice A hook contract for the LendingPoolRouter
 * @dev This contract is used to implement custom logic for the LendingPoolRouter
 */
abstract contract LendingPoolRouterHook {
    // =============================================================
    //                           ERRORS
    // =============================================================

    /// @notice Error thrown when amount is zero
    error ZeroAmount();

    /// @notice Error thrown when user has insufficient shares
    error InsufficientShares();

    /// @notice Error thrown when protocol has insufficient liquidity
    error InsufficientLiquidity();

    /// @notice Error thrown when caller is not the lending pool
    error NotLendingPool();

    /// @notice Error thrown when caller is not the factory
    error NotFactory();

    /// @notice Error thrown when position already exists
    error PositionAlreadyCreated();

    /// @notice Error thrown when ltv is invalid
    error InvalidLtv(uint256 ltv);

    /**
     * @notice Error thrown when total supply shares is zero
     * @param shares The shares being withdrawn
     * @param totalSupplyShares The current total supply shares (should be zero)
     */
    error TotalSupplySharesZero(uint256 shares, uint256 totalSupplyShares);

    /**
     * @notice Error thrown when user has insufficient collateral
     * @param amount The actual collateral amount
     * @param expectedAmount The expected collateral amount
     */
    error InsufficientCollateral(uint256 amount, uint256 expectedAmount);

    /**
     * @notice Error thrown when total borrow shares is zero
     * @param shares The shares being repaid
     * @param totalBorrowShares The current total borrow shares (should be zero)
     */
    error TotalBorrowSharesZero(uint256 shares, uint256 totalBorrowShares);

    /**
     * @notice Error thrown when user is not liquidatable
     * @param user The address of the user
     */
    error NotLiquidable(address user);

    /**
     * @notice Error thrown when asset is not liquidatable
     * @param collateralToken The address of the collateral token
     * @param collateralValue The value of the collateral
     * @param borrowValue The value of the borrow
     */
    error AssetNotLiquidatable(address collateralToken, uint256 collateralValue, uint256 borrowValue);

    /**
     * @notice Error thrown when maximum utilization is reached
     * @param borrowToken The address of the borrow token
     * @param newUtilization The new utilization rate
     * @param maxUtilization The maximum allowed utilization rate
     */
    error MaxUtilizationReached(address borrowToken, uint256 newUtilization, uint256 maxUtilization);

    error MinAmountSupplyLiquidity(uint256 amount, uint256 minAmountSupplyLiquidity);

    // =============================================================
    //                           EVENTS
    // =============================================================

    /**
     * @notice Event emitted when interest is accrued
     * @param interest The amount of interest accrued
     * @param supplyYield The yield generated from supply
     * @param reserveYield The yield generated from reserve
     */
    event InterestAccrued(uint256 interest, uint256 supplyYield, uint256 reserveYield);

    /**
     * @notice Event emitted when shares token is deployed
     * @param sharesToken The address of the shares token
     * @param sharesTokenImplementation The address of the shares token implementation
     */
    event SharesTokenDeployed(address sharesToken, address sharesTokenImplementation);

    // =============================================================
    //                           CONSTANTS
    // =============================================================

    /// @notice Role identifier for accounts that have owner privileges
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    /// @notice Role identifier for accounts that can upgrade the contract
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
}
