// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { LendingPool } from "./LendingPool.sol";
import { LendingPoolDeployerHook } from "./lib/LendingPoolDeployerHook.sol";

/**
 * @title LendingPoolDeployer
 * @author Supala Labs
 * @notice A factory contract for deploying new LendingPool instances
 * @dev This contract is responsible for creating new lending pools with specified parameters
 *
 * The LendingPoolDeployer allows the factory to create new lending pools with different
 * collateral and borrow token pairs, along with configurable loan-to-value (LTV) ratios.
 * Each deployed pool is a separate contract instance that manages lending and borrowing
 * operations for a specific token pair.
 */
contract LendingPoolDeployer is LendingPoolDeployerHook {
    // =============================================================
    //                       STATE VARIABLES
    // =============================================================

    /// @notice The address of the factory contract that is authorized to deploy lending pools
    address public factory;

    /// @notice The address of the contract owner who can set the factory address
    address public owner;

    // =============================================================
    //                       CONSTRUCTOR
    // =============================================================

    /**
     * @notice Initializes the LendingPoolDeployer contract
     * @dev Sets the deployer as the initial owner of the contract
     */
    constructor() {
        owner = msg.sender;
    }

    // =============================================================
    //                       MODIFIERS
    // =============================================================

    /**
     * @notice Restricts function access to only the factory contract
     * @dev Reverts with OnlyFactoryCanCall if caller is not the factory
     */
    modifier onlyFactory() {
        _onlyFactory();
        _;
    }

    /**
     * @notice Restricts function access to only the owner
     * @dev Reverts with OnlyOwnerCanCall if caller is not the owner
     */
    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    // =============================================================
    //                       INTERNAL FUNCTIONS
    // =============================================================

    /**
     * @notice Internal function to validate that the caller is the factory
     * @dev Reverts with OnlyFactoryCanCall error if the caller is not the factory address
     */
    function _onlyFactory() internal view {
        if (msg.sender != factory) revert OnlyFactoryCanCall();
    }

    /**
     * @notice Internal function to validate that the caller is the owner
     * @dev Reverts with OnlyOwnerCanCall error if the caller is not the owner address
     */
    function _onlyOwner() internal view {
        if (msg.sender != owner) revert OnlyOwnerCanCall();
    }

    // =============================================================
    //                       EXTERNAL FUNCTIONS
    // =============================================================

    /**
     * @notice Deploys a new LendingPool contract with specified parameters
     * @return The address of the newly deployed LendingPool contract
     *
     * @dev This function creates a new LendingPool instance with the provided parameters.
     * Only the factory contract should call this function to ensure proper pool management.
     *
     * Requirements:
     * - Caller must be the factory contract
     *
     * @custom:security This function should only be called by the factory contract
     */
    function deployLendingPool() public onlyFactory returns (address) {
        LendingPool lendingPool = new LendingPool();
        return address(lendingPool);
    }

    /**
     * @notice Sets the factory address that is authorized to deploy lending pools
     * @param _factory The address of the new factory contract
     *
     * @dev This function allows the owner to update the factory address.
     * Once set, only the new factory address will be able to deploy lending pools.
     *
     * Requirements:
     * - Caller must be the owner
     *
     * @custom:security Ensure the _factory address is a trusted contract before setting
     */
    function setFactory(address _factory) public onlyOwner {
        factory = _factory;
    }
}
