// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { ContextUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { IPriceFeed } from "./interfaces/IPriceFeed.sol";
import { TokenDataStreamHook } from "./lib/TokenDataStreamHook.sol";

/**
 * @title TokenDataStream
 * @author Supala Labs
 * @notice Contract that manages price feed mappings for tokens in the lending protocol
 * @dev This contract acts as a registry that maps token addresses to their corresponding
 *      price feed contracts. It provides a unified interface for accessing token price data
 *      from various oracle sources while maintaining Chainlink compatibility.
 *
 * Key Features:
 * - Token to price feed address mapping
 * - Chainlink-compatible price data interface
 * - Owner-controlled price feed configuration
 * - Decimal precision handling for different oracles
 * - Centralized price data access point for the protocol
 */
contract TokenDataStream is
    Initializable,
    ContextUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable,
    AccessControlUpgradeable,
    TokenDataStreamHook
{
    // =============================================================
    //                       STATE VARIABLES
    // =============================================================

    /// @notice Mapping of token addresses to their corresponding price feed contract addresses
    /// @dev token address => price feed contract address
    mapping(address => address) public tokenPriceFeed;

    // =============================================================
    //                           CONSTRUCTOR
    // =============================================================

    /// @notice Initializes the TokenDataStream contract
    /// @dev Sets up Ownable with the deployer as the initial owner
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializes the TokenDataStream contract
    /// @dev Sets up Ownable with the deployer as the initial owner
    function initialize() public initializer {
        __AccessControl_init();
        __Pausable_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(OWNER_ROLE, _msgSender());
        _grantRole(UPGRADER_ROLE, _msgSender());
    }

    // =============================================================
    //                   CONFIGURATION FUNCTIONS
    // =============================================================

    /// @notice Sets or updates the price feed contract for a token
    /// @dev Only the contract owner can call this function. Validates that neither the token
    ///      nor the price feed address is zero. Emits TokenPriceFeedSet event on success.
    /// @param _token The token address to configure
    /// @param _priceFeed The price feed contract address for this token
    function setTokenPriceFeed(address _token, address _priceFeed) public onlyRole(OWNER_ROLE) {
        if (_token == address(0)) revert ZeroAddress();
        if (_priceFeed == address(0)) revert ZeroAddress();
        tokenPriceFeed[_token] = _priceFeed;
        emit TokenPriceFeedSet(_token, _priceFeed);
    }

    // =============================================================
    //                        VIEW FUNCTIONS
    // =============================================================

    /// @notice Returns the number of decimals used by a token's price feed
    /// @dev Calls the decimals function on the configured price feed contract.
    ///      Reverts if no price feed is configured for the given token.
    /// @param _token The token address to get decimals for
    /// @return The number of decimals used by the token's price feed
    function decimals(address _token) public view returns (uint256) {
        if (tokenPriceFeed[_token] == address(0)) revert TokenPriceFeedNotSet(_token);
        return IPriceFeed(tokenPriceFeed[_token]).decimals();
    }

    /// @notice Returns the latest price data for a token in Chainlink-compatible format
    /// @dev Retrieves price data from the configured price feed and converts int256 price to uint256.
    ///      Validates that:
    ///      - A price feed is configured for the token
    ///      - The price data is not stale (updated within the last hour)
    ///      - The price is not negative
    ///      Note: startedAt and answeredInRound are returned as 0 for compatibility
    /// @param _token The token address to get price data for
    /// @return roundId The round ID from the price feed
    /// @return price The price value (converted from int256 to uint256)
    /// @return startedAt Timestamp when the round started (always returns 0)
    /// @return updatedAt Timestamp when the price was last updated
    /// @return answeredInRound The round when this answer was computed (always returns 0)
    function latestRoundData(address _token) public view returns (uint80, uint256, uint256, uint256, uint80) {
        if (tokenPriceFeed[_token] == address(0)) revert TokenPriceFeedNotSet(_token);
        address _priceFeed = tokenPriceFeed[_token];
        (uint80 idRound, int256 priceAnswer, uint256 updatedAt) = IPriceFeed(_priceFeed).latestRoundData();
        if (block.timestamp - updatedAt > 3600) revert PriceStale(_token, _priceFeed, updatedAt);
        if (priceAnswer < 0) revert NegativePriceAnswer(priceAnswer);

        // forge-lint: disable-next-line(unsafe-typecast)
        return (idRound, uint256(priceAnswer), 0, updatedAt, 0);
    }

    // =============================================================
    //                       UPGRADE FUNCTIONS
    // =============================================================

    /// @notice Authorizes contract upgrades
    /// @dev Only accounts with UPGRADER_ROLE can authorize upgrades.
    ///      This is required by the UUPSUpgradeable pattern.
    /// @param newImplementation The address of the new implementation contract
    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) { }
}
