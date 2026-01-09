// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * @title ILPRouterDeployer
 * @notice Interface for deploying lending pool router contracts
 * @dev Defines the contract for creating new lending pool router instances
 */
interface ILPRouterDeployer {
    /**
     * @notice Deploys a new lending pool router
     * @return Address of the newly deployed lending pool router
     */
    function deployLendingPoolRouter() external returns (address);
}
