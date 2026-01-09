// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * @title ILPDeployer
 * @dev Interface for lending pool deployment functionality
 * @notice This interface defines the contract for deploying new lending pools
 * @author Supala Labs
 * @custom:version 1.0.0
 */
interface ILPDeployer {
    /**
     * @dev Deploys a new lending pool with specified parametersen
     * @return Address of the newly deployed lending pool
     * @notice This function creates a new lending pool instance
     * @custom:security Only authorized addresses should be able to call this function
     */
    function deployLendingPool() external returns (address);

    /**
     * @dev Sets the factory address for the deployer
     * @param factory Address of the lending pool factory
     * @notice This function configures the factory reference for the deployer
     * @custom:security Only the owner should be able to set the factory address
     */
    function setFactory(address factory) external;
}
