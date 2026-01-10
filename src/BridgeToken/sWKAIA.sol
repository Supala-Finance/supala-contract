// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { ERC20Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { ContextUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

/**
 * @title sWKAIA
 * @notice Synthetic Wrapped KAIA token representing WKAIA deposits in the Supala protocol
 * @dev ERC20 token with operator-controlled minting and burning, fixed 18 decimals
 */
contract sWKAIA is Initializable, ContextUpgradeable, ERC20Upgradeable, PausableUpgradeable, UUPSUpgradeable, AccessControlUpgradeable {
    // =============================================================
    //                           CONSTANTS
    // =============================================================

    /// @notice Role identifier for accounts that have owner privileges
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    /// @notice Role identifier for accounts that can upgrade the contract
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @notice Role identifier for accounts that can mint tokens
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /// @notice Error thrown when a non-operator attempts to call operator-only functions
    error NotOperator();

    /**
     * @notice Initializes the sWKAIA token contract
     * @dev Initializes with name "Wrapped KAIA representative" and symbol "sWKAIA"
     */
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __ERC20_init("Wrapped KAIA representative", "sWKAIA");
        __AccessControl_init();
        __Pausable_init();
        __UUPSUpgradeable_init();

        _grantRole(OWNER_ROLE, _msgSender());
        _grantRole(UPGRADER_ROLE, _msgSender());
        _grantRole(MINTER_ROLE, _msgSender());
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
