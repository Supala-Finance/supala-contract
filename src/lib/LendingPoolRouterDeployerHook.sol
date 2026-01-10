// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

abstract contract LendingPoolRouterDeployerHook {
    // =============================================================
    //                        ERRORS
    // =============================================================

    /**
     * @notice Thrown when a caller other than the factory attempts to deploy a router
     */
    error OnlyFactoryCanCall();

    // =============================================================
    //                        EVENTS
    // =============================================================

    /**
     * @notice Emitted when a new LendingPoolRouter is successfully deployed
     * @param router The address of the newly deployed LendingPoolRouter contract
     * @param collateralToken The address of the collateral token used in the router
     * @param borrowToken The address of the borrow token used in the router
     * @param ltv The loan-to-value ratio configured for the router (in basis points or percentage)
     */
    event LendingPoolRouterDeployed(address indexed router, address indexed collateralToken, address indexed borrowToken, uint256 ltv);
}
