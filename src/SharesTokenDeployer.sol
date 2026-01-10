// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { SupalaSharesToken } from "./SharesToken/SupalaSharesToken.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract SharesTokenDeployer is Ownable {
    /// @notice Error thrown when caller is not authorized
    error NotAuthorized();

    /// @notice Event emitted when factory is set
    event FactorySet(address indexed factory);

    /// @notice Event emitted when authorized address is set
    event AuthorizedSet(address indexed authorized, bool status);

    /// @notice Event emitted when shares token is deployed
    event DeployedSharesToken(address indexed sharesToken);

    /// @notice SupalaSharesToken contract address
    SupalaSharesToken public supalaSharesToken;

    /// @notice Factory contract address
    address public factory;

    /// @notice Mapping of authorized addresses that can deploy shares tokens
    mapping(address => bool) public authorized;

    /// @notice Constructor for SharesTokenDeployer
    constructor() Ownable(msg.sender) { }

    /// @notice Modifier to check if caller is authorized (factory or authorized address)
    modifier onlyAuthorized() {
        _onlyAuthorized();
        _;
    }

    /// @notice Deploy SupalaSharesToken function
    /// @dev This is called by LendingPoolRouter during initialization, which is only created by the factory
    function deploySharesToken() public returns (address) {
        supalaSharesToken = new SupalaSharesToken();
        emit DeployedSharesToken(address(supalaSharesToken));
        return address(supalaSharesToken);
    }

    /// @notice Set factory function
    function setFactory(address _factory) public onlyOwner {
        factory = _factory;
        emit FactorySet(_factory);
    }

    /// @notice Set authorized address function
    function setAuthorized(address _address, bool _status) public {
        if (msg.sender != factory && msg.sender != owner()) revert NotAuthorized();
        authorized[_address] = _status;
        emit AuthorizedSet(_address, _status);
    }

    /// @notice Internal function to check if caller is authorized
    function _onlyAuthorized() internal view {
        if (msg.sender != factory && !authorized[msg.sender]) revert NotAuthorized();
    }
}
