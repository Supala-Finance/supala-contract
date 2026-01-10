// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { ERC20Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { ContextUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

/**
 * @title SupalaTOKEN
 * @notice ERC20 token with operator-controlled minting and burning capabilities
 * @dev Extends OpenZeppelin's ERC20Upgradeable with custom decimal support using ERC-7201 storage
 */
contract SupalaTOKEN is Initializable, ContextUpgradeable, ERC20Upgradeable, PausableUpgradeable, UUPSUpgradeable, AccessControlUpgradeable {
    // =============================================================
    //                           CONSTANTS
    // =============================================================

    /// @notice Role identifier for accounts that have owner privileges
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    /// @notice Role identifier for accounts that can upgrade the contract
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @notice Role identifier for accounts that can mint tokens
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /// @dev keccak256(abi.encode(uint256(keccak256("supala.storage.SUPALATOKEN")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant SUPALATOKENSTORAGELOCATION = 0x5d3e2e8c88f3e0c8f5b0e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e500;

    /// @notice Error thrown when a non-operator attempts to call operator-only functions
    error NotOperator();

    /// @custom:storage-location erc7201:supala.storage.SUPALATOKEN
    struct SupalaTokenStorage {
        uint8 _decimals;
    }

    /**
     * @dev Returns a pointer to the storage namespace
     */
    function _getSupalaTokenStorage() private pure returns (SupalaTokenStorage storage $) {
        assembly {
            $.slot := SUPALATOKENSTORAGELOCATION
        }
    }

    /**
     * @notice Initializes the SupalaTOKEN contract
     * @dev Disabled in favor of the parameterized initialize function
     */
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the SupalaTOKEN token contract
     * @param _date The date string to append to the token name and symbol
     * @param _decimals The number of decimal places for the token
     */
    function initialize(string memory _date, uint8 _decimals) public initializer {
        __ERC20_init(string.concat("SupalaTOKEN-", _date), string.concat("SupalaTOKEN-", _date));
        __AccessControl_init();
        __Pausable_init();
        __UUPSUpgradeable_init();

        _grantRole(OWNER_ROLE, _msgSender());
        _grantRole(UPGRADER_ROLE, _msgSender());
        _grantRole(MINTER_ROLE, _msgSender());

        SupalaTokenStorage storage $ = _getSupalaTokenStorage();
        $._decimals = _decimals;
    }

    /**
     * @notice Returns the number of decimals used for token amounts
     * @return The number of decimal places
     */
    function decimals() public view override returns (uint8) {
        SupalaTokenStorage storage $ = _getSupalaTokenStorage();
        return $._decimals;
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
    function burn(address _from, uint256 _amount) public {
        _burn(_from, _amount);
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

    // =============================================================
    //                       UPGRADE FUNCTIONS
    // =============================================================

    /// @notice Authorizes contract upgrades
    /// @dev Only accounts with UPGRADER_ROLE can authorize upgrades.
    ///      This is required by the UUPSUpgradeable pattern.
    /// @param newImplementation The address of the new implementation contract
    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) { }
}

