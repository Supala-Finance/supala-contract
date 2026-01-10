// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract TokenDataStreamHook {
    // =============================================================
    //                           ERRORS
    // =============================================================

    /// @notice Thrown when attempting to access price data for a token without a configured price feed
    /// @param token The token address that doesn't have a price feed configured
    error TokenPriceFeedNotSet(address token);

    /// @notice Thrown when the price feed returns a negative price value
    /// @param price The negative price value that was returned
    error NegativePriceAnswer(int256 price);

    /// @notice Thrown when a zero address is provided as a parameter
    error ZeroAddress();

    /// @notice Thrown when the price data is stale (older than 1 hour)
    /// @param token The token address for which the price is stale
    /// @param priceFeed The price feed contract address that returned stale data
    /// @param updatedAt The timestamp when the price was last updated
    error PriceStale(address token, address priceFeed, uint256 updatedAt);

    // =============================================================
    //                           EVENTS
    // =============================================================

    /// @notice Emitted when a token's price feed is configured or updated
    /// @param token The token address that was configured
    /// @param priceFeed The price feed contract address that was set
    event TokenPriceFeedSet(address token, address priceFeed);

    // =============================================================
    //                           CONSTANTS
    // =============================================================

    /// @notice Role identifier for accounts that have owner privileges
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    /// @notice Role identifier for accounts that can upgrade the contract
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
}
