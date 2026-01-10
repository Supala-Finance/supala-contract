// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { LendingPoolRouter } from "./LendingPoolRouter.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { LendingPoolRouterDeployerHook } from "./lib/LendingPoolRouterDeployerHook.sol";

/**
 * @title LendingPoolRouterDeployer
 * @notice Factory contract responsible for deploying new LendingPoolRouter instances
 * @dev This contract is owned and only the designated factory address can trigger router deployments.
 * The deployer pattern separates deployment logic from the factory contract, allowing for upgradeable deployment strategies.
 */
contract LendingPoolRouterDeployer is Ownable, LendingPoolRouterDeployerHook {
    // =============================================================
    //                        STATE VARIABLES
    // =============================================================

    /// @notice The most recently deployed LendingPoolRouter instance
    LendingPoolRouter public router;

    /// @notice The authorized factory address that can trigger router deployments
    address public factory;

    // =============================================================
    //                        CONSTRUCTOR
    // =============================================================

    /**
     * @notice Initializes the LendingPoolRouterDeployer contract
     * @dev Sets the deployer (msg.sender) as the initial owner via Ownable constructor
     */
    constructor() Ownable(msg.sender) { }

    // =============================================================
    //                        MODIFIERS
    // =============================================================

    /**
     * @notice Restricts function access to only the factory address
     * @dev Calls internal _onlyFactory() function to validate caller
     */
    modifier onlyFactory() {
        _onlyFactory();
        _;
    }

    // =============================================================
    //                        EXTERNAL FUNCTIONS
    // =============================================================

    /**
     * @notice Deploys a new LendingPoolRouter contract with specified parameters
     * @dev Can only be called by the authorized factory address. The router is deployed with
     * @return The address of the newly deployed LendingPoolRouter
     */
    function deployLendingPoolRouter() public onlyFactory returns (address) {
        router = new LendingPoolRouter();
        return address(router);
    }

    /**
     * @notice Updates the authorized factory address
     * @dev Can only be called by the contract owner. This allows changing which address
     * can trigger router deployments.
     * @param _factory The new factory address to authorize
     */
    function setFactory(address _factory) public onlyOwner {
        factory = _factory;
    }

    // =============================================================
    //                        INTERNAL FUNCTIONS
    // =============================================================

    /**
     * @notice Internal validation function that ensures caller is the factory
     * @dev Reverts with OnlyFactoryCanCall error if msg.sender is not the factory address
     */
    function _onlyFactory() internal view {
        if (msg.sender != factory) revert OnlyFactoryCanCall();
    }
}
