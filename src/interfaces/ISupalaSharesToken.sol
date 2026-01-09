// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title ISupalaSharesToken
 * @notice Interface for the SupalaSharesToken contract
 * @dev This interface defines the public functions for managing shares tokens in the Supala protocol
 */
interface ISupalaSharesToken is IERC20 {
    // =============================================================
    //                           EVENTS
    // =============================================================

    /// @notice Event emitted when the factory is set
    event FactorySet(address indexed factory);

    // =============================================================
    //                           CONSTANTS
    // =============================================================

    /// @notice Role identifier for accounts that have owner privileges
    function OWNER_ROLE() external view returns (bytes32);

    /// @notice Role identifier for accounts that can upgrade the contract
    function UPGRADER_ROLE() external view returns (bytes32);

    /// @notice Role identifier for accounts that can mint tokens
    function MINTER_ROLE() external view returns (bytes32);

    // =============================================================
    //                      STATE VARIABLES
    // =============================================================

    /// @notice The factory address
    function factory() external view returns (address);

    /// @notice The number of decimals for the underlying asset
    function underlyingDecimals() external view returns (uint8);

    // =============================================================
    //                      EXTERNAL FUNCTIONS
    // =============================================================

    /**
     * @notice Initializes the SupalaSharesToken token contract
     * @param _factory The address of the factory
     * @param _date The date timestamp for naming
     * @param _name The name of the underlying token
     * @param _symbol The symbol of the underlying token
     * @param _underlyingDecimals The number of decimals for the underlying asset
     * @param _minter The address that will receive MINTER_ROLE
     */
    function initialize(
        address _factory,
        uint256 _date,
        string memory _name,
        string memory _symbol,
        uint8 _underlyingDecimals,
        address _minter
    )
        external;

    /**
     * @notice Returns the number of decimals used for token amounts
     * @return Always returns 18 decimals
     */
    function decimals() external pure returns (uint8);

    /**
     * @notice Mints new tokens to a specified address
     * @dev Only callable by authorized operators with MINTER_ROLE
     * @param _to The address to receive the minted tokens
     * @param _amount The amount of tokens to mint
     */
    function mint(address _to, uint256 _amount) external;

    /**
     * @notice Burns tokens from a specified address
     * @param _from The address to burn tokens from
     * @param _amount The amount of tokens to burn
     */
    function burn(address _from, uint256 _amount) external;

    /**
     * @notice Sets the factory address
     * @dev Only callable by accounts with OWNER_ROLE
     * @param _factory The address of the factory
     */
    function setFactory(address _factory) external;

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
}
