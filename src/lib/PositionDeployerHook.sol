// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

abstract contract PositionDeployerHook {
    // =============================================================
    //                        ERRORS
    // =============================================================

    /**
     * @notice Thrown when a caller other than the owner attempts to execute an owner-only function
     */
    error OnlyOwnerCanCall();
}
