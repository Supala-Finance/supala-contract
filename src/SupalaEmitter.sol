// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { ContextUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract SupalaEmitter is Initializable, ContextUpgradeable, PausableUpgradeable, UUPSUpgradeable, AccessControlUpgradeable {
    /// @notice Role identifier for accounts that have owner privileges
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    /// @notice Role identifier for accounts that can upgrade the contract
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @notice Role identifier for accounts that have owner privileges
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    event PositionCreated(address lendingPool, address lendingPoolRouter, address user, address position);

    event SharesTokenDeployed(address lendingPoolRouter, address sharesToken);

    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __Context_init();
        __AccessControl_init();
        __Pausable_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(OWNER_ROLE, _msgSender());
        _grantRole(ADMIN_ROLE, _msgSender());
        _grantRole(UPGRADER_ROLE, _msgSender());
    }

    function positionCreated(
        address _lendingPool,
        address _lendingPoolRouter,
        address _user,
        address _position
    )
        public
        onlyRole(ADMIN_ROLE)
        whenNotPaused
    {
        emit PositionCreated(_lendingPool, _lendingPoolRouter, _user, _position);
    }

    // TODO: Delete this function
    function sharesTokenDeployed(address _lendingPoolRouter, address _sharesToken) public onlyRole(ADMIN_ROLE) whenNotPaused {
        emit SharesTokenDeployed(_lendingPoolRouter, _sharesToken);
    }

    function pause() public onlyRole(OWNER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(OWNER_ROLE) {
        _unpause();
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) { }
}
