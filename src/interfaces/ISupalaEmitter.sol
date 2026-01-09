// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

interface ISupalaEmitter {
    /// @notice Role identifier for accounts that have owner privileges
    function OWNER_ROLE() external view returns (bytes32);

    /// @notice Role identifier for accounts that can upgrade the contract
    function UPGRADER_ROLE() external view returns (bytes32);

    /// @notice Returns the factory address
    function factory() external view returns (address);

    /// @notice Initializes the SupalaEmitter contract
    /// @param _factory The address of the factory contract
    function initialize(address _factory) external;

    /// @notice Emits the PositionCreated event
    /// @param _lendingPool The address of the lending pool
    /// @param _lendingPoolRouter The address of the lending pool router
    /// @param _user The address of the user
    /// @param _position The address of the position
    function positionCreated(address _lendingPool, address _lendingPoolRouter, address _user, address _position) external;

    /// @notice Emits the SharesTokenDeployed event
    /// @param _lendingPoolRouter The address of the lending pool router
    /// @param _sharesToken The address of the shares token
    function sharesTokenDeployed(address _lendingPoolRouter, address _sharesToken) external;

    /// @notice Grants a role to an account
    /// @param role The role to grant
    /// @param account The address to grant the role to
    function grantRole(bytes32 role, address account) external;
}
