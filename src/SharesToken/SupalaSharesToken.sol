// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { ERC20Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { ContextUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { IFactory } from "../interfaces/IFactory.sol";

/**
 * @title SupalaSharesToken
 * @notice SharesToken token representing deposits in the Supala protocol
 * @dev ERC20 token with operator-controlled minting and burning, fixed 18 decimals
 */
contract SupalaSharesToken is Initializable, ContextUpgradeable, ERC20Upgradeable, PausableUpgradeable, UUPSUpgradeable, AccessControlUpgradeable {
    // =============================================================
    //                           CONSTANTS
    // =============================================================

    /// @notice Role identifier for accounts that have owner privileges
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    /// @notice Role identifier for accounts that can upgrade the contract
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @notice Role identifier for accounts that can mint tokens
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /// @notice Event emitted when the factory is set
    event FactorySet(address indexed factory);

    /// @notice The factory address
    address public factory;

    /// @notice The number of decimals for the underlying asset
    uint8 public underlyingDecimals;

    /**
     * @notice Initializes the SupalaSharesToken token contract
     * @dev Initializes with dynamic name based on date parameter
     */
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _factory,
        uint256 _date,
        string memory _name,
        string memory _symbol,
        uint8 _underlyingDecimals,
        address _minter
    )
        public
        initializer
    {
        __ERC20_init(
            string.concat("Supala ", _name, " Token - ", Strings.toString(_date)), string.concat("Supala", _symbol, "-", Strings.toString(_date))
        );
        __AccessControl_init();
        __Pausable_init();
        __UUPSUpgradeable_init();

        factory = _factory;
        underlyingDecimals = _underlyingDecimals;

        _grantRole(DEFAULT_ADMIN_ROLE, _ownerFactory());
        _grantRole(OWNER_ROLE, _ownerFactory());
        _grantRole(UPGRADER_ROLE, _ownerFactory());
        _grantRole(MINTER_ROLE, _minter); // Grant MINTER_ROLE to the specified minter (router)
    }

    /**
     * @notice Returns the number of decimals used for token amounts
     * @return Always returns 18 decimals
     */
    function decimals() public pure override returns (uint8) {
        return 18;
    }

    /**
     * @notice Mints new tokens to a specified address
     * @dev Only callable by authorized operators
     * @param _to The address to receive the minted tokens
     * @param _amount The amount of tokens to mint
     */
    function mint(address _to, uint256 _amount) public onlyRole(MINTER_ROLE) {
        _mint(_to, _amount);
    }

    /**
     * @notice Burns tokens from a specified address
     * @dev Only callable by authorized operators
     * @param _from The address to burn tokens from
     * @param _amount The amount of tokens to burn
     */
    function burn(address _from, uint256 _amount) public onlyRole(MINTER_ROLE) {
        _burn(_from, _amount);
    }

    // =============================================================
    //                      OWNER FUNCTIONS
    // =============================================================
    /**
     * @notice Sets the factory address
     * @dev Only callable by accounts with OWNER_ROLE
     * @param _factory The address of the factory
     */
    function setFactory(address _factory) public onlyRole(OWNER_ROLE) {
        factory = _factory;
        emit FactorySet(_factory);
    }

    // =============================================================
    //                      PAUSABLE FUNCTIONS
    // =============================================================

    /**
     * @notice Pauses all pausable functions in the contract
     * @dev Can only be called by accounts with OWNER_ROLE
     */
    function pause() external onlyRole(OWNER_ROLE) {
        _pause();
    }

    /**
     * @notice Unpauses all pausable functions in the contract
     * @dev Can only be called by accounts with OWNER_ROLE
     */
    function unpause() external onlyRole(OWNER_ROLE) {
        _unpause();
    }

    function _ownerFactory() internal view returns (address) {
        return IFactory(factory).owner();
    }

    // =============================================================
    //                       UPGRADE FUNCTIONS
    // =============================================================

    /**
     * @notice Authorizes contract upgrades
     * @dev Only accounts with UPGRADER_ROLE can authorize upgrades.
     *      This is required by the UUPSUpgradeable pattern.
     * @param newImplementation The address of the new implementation contract
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) { }
}
