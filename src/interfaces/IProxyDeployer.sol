// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * @title IProxyDeployer
 * @author Supala Labs
 * @notice Interface for proxy deployer contract
 * @dev This interface defines the functions required for deploying proxies
 */
interface IProxyDeployer {
    /**
     * @notice Deploys a new proxy contract
     * @param _implementation The address of the implementation contract
     * @param _data The initialization data for the proxy contract
     * @return The address of the deployed proxy contract
     */
    function deployProxy(address _implementation, bytes memory _data) external returns (address);
}
