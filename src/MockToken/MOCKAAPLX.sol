// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title MOCKAAPLX
 * @notice Mock Apple Inc. Synthetic Token stock token for testing purposes
 * @dev Extends OpenZeppelin's ERC20 with 18 decimals and public mint/burn functions
 */
contract MOCKAAPLX is ERC20 {
    /**
     * @notice Constructs a new mock AAPLX token
     * @dev Initializes with name "Apple Inc. Synthetic Token" and symbol "AAPLX"
     */
    constructor() ERC20("Apple Inc. Synthetic Token", "AAPLX") { }

    /**
     * @notice Mints tokens to a specified address
     * @param _to Address to receive the minted tokens
     * @param _amount Amount of tokens to mint
     * @dev Public function for testing - no access control
     */
    function mint(address _to, uint256 _amount) public {
        _mint(_to, _amount);
    }

    /**
     * @notice Burns tokens from a specified address
     * @param _from Address to burn tokens from
     * @param _amount Amount of tokens to burn
     * @dev Public function for testing - no access control
     */
    function burn(address _from, uint256 _amount) public {
        _burn(_from, _amount);
    }
}
