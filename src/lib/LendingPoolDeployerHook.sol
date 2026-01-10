// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

abstract contract LendingPoolDeployerHook {
    // =============================================================
    //                        ERRORS
    // =============================================================

    /**
     * @notice Thrown when a non-factory address attempts to call a factory-only function
     */
    error OnlyFactoryCanCall();

    /**
     * @notice Thrown when a non-owner address attempts to call an owner-only function
     */
    error OnlyOwnerCanCall();
}
