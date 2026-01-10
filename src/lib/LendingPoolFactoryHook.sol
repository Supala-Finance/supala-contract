// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

abstract contract LendingPoolFactoryHook {
    // =============================================================
    //                           STRUCTS
    // =============================================================
    /**
     * @notice Parameters required for creating a new lending pool
     * @dev This struct encapsulates all configuration parameters needed to deploy a lending pool
     * @param collateralToken The address of the token used as collateral
     * @param borrowToken The address of the token that can be borrowed
     * @param ltv The Loan-to-Value ratio (e.g., 8e17 for 80%)
     * @param supplyLiquidity The initial amount of borrow tokens to supply to the pool
     * @param baseRate The base interest rate when utilization is 0
     * @param rateAtOptimal The interest rate at optimal utilization
     * @param optimalUtilization The target utilization rate for the pool
     * @param maxUtilization The maximum allowed utilization rate
     * @param liquidationThreshold The threshold at which positions become liquidatable
     * @param liquidationBonus The bonus awarded to liquidators
     */
    struct LendingPoolParams {
        address collateralToken;
        address borrowToken;
        uint256 ltv;
        uint256 supplyLiquidity;
        uint256 baseRate;
        uint256 rateAtOptimal;
        uint256 optimalUtilization;
        uint256 maxUtilization;
        uint256 maxRate;
        uint256 liquidationThreshold;
        uint256 liquidationBonus;
    }

    // =============================================================
    //                           EVENTS
    // =============================================================

    /**
     * @notice Emitted when a new lending pool is created
     * @param lendingPoolParams The parameters of the created lending pool
     * @param router The address of the router for the created lending pool
     * @param routerImplementation The address of the router implementation for the created lending pool
     * @param lendingPool The address of the created lending pool
     * @param lendingPoolImplementation The address of the lending pool implementation for the created lending pool
     */
    event LendingPoolCreated(
        LendingPoolParams lendingPoolParams,
        address router,
        address routerImplementation,
        address lendingPool,
        address lendingPoolImplementation,
        address sharesToken
    );

    /**
     * @notice Emitted when an operator status is updated
     * @param operator The address of the operator
     * @param status The new status of the operator (true for active, false for inactive)
     */
    event OperatorSet(address indexed operator, bool status);

    /**
     * @notice Emitted when an OFT (Omnichain Fungible Token) address is set for a token
     * @param token The address of the token
     * @param oftAddress The address of the OFT wrapper for cross-chain transfers
     */
    event OftAddressSet(address indexed token, address indexed oftAddress);

    /**
     * @notice Emitted when the token data stream address is updated
     * @param tokenDataStream The address of the new token data stream contract
     */
    event TokenDataStreamSet(address indexed tokenDataStream);

    /**
     * @notice Emitted when the lending pool deployer address is updated
     * @param lendingPoolDeployer The address of the new lending pool deployer contract
     */
    event LendingPoolDeployerSet(address indexed lendingPoolDeployer);

    /**
     * @notice Emitted when the protocol address is updated
     * @param protocol The address of the new protocol contract
     */
    event ProtocolSet(address indexed protocol);

    /**
     * @notice Emitted when the IsHealthy contract address is updated
     * @param isHealthy The address of the new IsHealthy contract
     */
    event IsHealthySet(address indexed isHealthy);

    /**
     * @notice Emitted when the position deployer address is updated
     * @param positionDeployer The address of the new position deployer contract
     */
    event PositionDeployerSet(address indexed positionDeployer);

    /**
     * @notice Emitted when the lending pool router deployer address is updated
     * @param lendingPoolRouterDeployer The address of the new router deployer contract
     */
    event LendingPoolRouterDeployerSet(address indexed lendingPoolRouterDeployer);

    /**
     * @notice Emitted when the wrapped native token address is updated
     * @param wrappedNative The address of the new wrapped native token
     */
    event WrappedNativeSet(address indexed wrappedNative);

    /**
     * @notice Emitted when the DEX router address is updated
     * @param dexRouter The address of the new DEX router
     */
    event DexRouterSet(address indexed dexRouter);

    /**
     * @notice Emitted when the minimum supply liquidity amount is set for a token
     * @param token The address of the token
     * @param minAmountSupplyLiquidity The minimum amount required for initial liquidity supply
     */
    event MinAmountSupplyLiquiditySet(address indexed token, uint256 indexed minAmountSupplyLiquidity);

    /**
     * @notice Emitted when the interest rate model address is updated
     * @param interestRateModel The address of the new interest rate model contract
     */
    event InterestRateModelSet(address indexed interestRateModel);

    /**
     * @notice Emitted when a chain ID to endpoint ID mapping is set
     * @param chainId The blockchain chain ID
     * @param eid The LayerZero endpoint ID
     */
    event ChainIdToEidSet(uint256 indexed chainId, uint32 indexed eid);

    /**
     * @notice Emitted when the proxy deployer address is updated
     * @param proxyDeployer The address of the new proxy deployer contract
     */
    event ProxyDeployerSet(address indexed proxyDeployer);

    /**
     * @notice Emitted when the shares token deployer address is updated
     * @param sharesTokenDeployer The address of the new shares token deployer contract
     */
    event SharesTokenDeployerSet(address indexed sharesTokenDeployer);

    /**
     * @notice Emitted when the creator fee is set for a lending pool router
     * @param lendingPoolRouter The lending pool router address
     * @param creatorFee The creator fee amount
     */
    event CreatorFeeSet(address indexed lendingPoolRouter, uint256 indexed creatorFee);

    /**
     * @notice Emitted when the SupalaEmitter address is set
     * @param supalaEmitter The address of the SupalaEmitter contract
     */
    event SupalaEmitterSet(address indexed supalaEmitter);

    // =============================================================
    //                           ERRORS
    // =============================================================

    /**
     * @notice Thrown when attempting to use a token without a configured oracle
     * @param token The address of the token missing an oracle configuration
     */
    error OracleOnTokenNotSet(address token);

    /**
     * @notice Thrown when the supplied liquidity is below the minimum required amount
     * @param amount The amount of liquidity provided
     * @param minAmountSupplyLiquidity The minimum required liquidity amount
     */
    error MinAmountSupplyLiquidityExceeded(uint256 amount, uint256 minAmountSupplyLiquidity);

    // =============================================================
    //                           ROLES
    // =============================================================

    /// @notice Role identifier for addresses that can pause the contract
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /// @notice Role identifier for addresses that can upgrade the contract implementation
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @notice Role identifier for addresses that have owner privileges
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
}
