// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { ContextUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ILPDeployer } from "./interfaces/ILPDeployer.sol";
import { ILPRouterDeployer } from "./interfaces/ILPRouterDeployer.sol";
import { ILendingPool } from "./interfaces/ILendingPool.sol";
import { ILPRouter } from "./interfaces/ILPRouter.sol";
import { IInterestRateModel } from "./interfaces/IInterestRateModel.sol";
import { IIsHealthy } from "./interfaces/IIsHealthy.sol";
import { IProxyDeployer } from "./interfaces/IProxyDeployer.sol";
import { ISupalaEmitter } from "./interfaces/ISupalaEmitter.sol";
import { LendingPoolRouter } from "./LendingPoolRouter.sol";
import { LendingPool } from "./LendingPool.sol";
import { LendingPoolFactoryHook } from "./lib/LendingPoolFactoryHook.sol";

/**
 * @title LendingPoolFactory
 * @author Supala Labs
 * @notice Factory contract for creating and managing lending pools
 * @dev This contract serves as the main entry point for creating new lending pools.
 * It maintains a registry of all created pools and manages token data streams,
 * cross-chain token senders, and various protocol configurations. The contract is
 * upgradeable using the UUPS pattern and includes pausable functionality for emergency stops.
 */
contract LendingPoolFactory is
    Initializable,
    ContextUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    AccessControlUpgradeable,
    OwnableUpgradeable,
    LendingPoolFactoryHook
{
    using SafeERC20 for IERC20;

    /// @notice The address of the IsHealthy contract for position health checks
    address public isHealthy;

    /// @notice The address of the lending pool deployer contract
    address public lendingPoolDeployer;

    /// @notice The address of the protocol contract
    address public protocol;

    /// @notice The address of the position deployer contract
    address public positionDeployer;

    /// @notice The address of the wrapped native token (e.g., WETH, WMATIC)
    address public wrappedNative;

    /// @notice The address of the DEX router for token swaps
    address public dexRouter;

    /// @notice The address of the lending pool router deployer contract
    address public lendingPoolRouterDeployer;

    /// @notice The address of the token data stream contract for price feeds
    address public tokenDataStream;

    /// @notice The address of the interest rate model contract
    address public interestRateModel;

    /// @notice The address of the proxy deployer contract for UUPS upgradeable deployments
    address public proxyDeployer;

    /// @notice The address of the shares token deployer contract
    address public sharesTokenDeployer;

    /// @notice Mapping of operator addresses to their active status
    mapping(address => bool) public operator;

    /// @notice Mapping of token addresses to their OFT (Omnichain Fungible Token) addresses
    mapping(address => address) public oftAddress;

    /// @notice Mapping of token addresses to their minimum initial supply liquidity requirements
    mapping(address => uint256) public minAmountSupplyLiquidity;

    /// @notice Mapping of blockchain chain IDs to LayerZero endpoint IDs
    mapping(uint256 => uint32) public chainIdToEid;

    /// @notice Mapping of lending pool router addresses to their creator fees
    mapping(address => uint256) public creatorFee;

    /// @notice The address of the SupalaEmitter contract
    address public supalaEmitter;

    /**
     * @notice Modifier to check if a token has an oracle configured
     * @param _token The address of the token to check
     */
    modifier checkOracleOnToken(address _token) {
        _checkOracleOnToken(_token);
        _;
    }

    /**
     * @notice Modifier to check if the supplied liquidity meets the minimum requirement
     * @param _borrowToken The address of the borrow token
     * @param _supplyLiquidity The amount of liquidity being supplied
     */
    modifier checkMinAmountSupplyLiquidity(address _borrowToken, uint256 _supplyLiquidity) {
        _checkMinAmountSupplyLiquidity(_borrowToken, _supplyLiquidity);
        _;
    }

    /**
     * @notice Constructor that disables initializers to prevent implementation contract initialization
     * @dev This is a security measure for UUPS upgradeable contracts
     */
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Pauses all contract operations
     * @dev Can only be called by addresses with PAUSER_ROLE
     */
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /**
     * @notice Unpauses all contract operations
     * @dev Can only be called by addresses with PAUSER_ROLE
     */
    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /**
     * @notice Initializes the contract with required addresses and roles
     * @dev This function can only be called once due to the initializer modifier
     */
    function initialize() public initializer {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();
        __Ownable_init(_msgSender());

        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(PAUSER_ROLE, _msgSender());
        _grantRole(UPGRADER_ROLE, _msgSender());
        _grantRole(OWNER_ROLE, _msgSender());
    }

    /**
     * @notice Creates a new lending pool with UUPS upgradeable proxies
     * @dev Implements complete lending pool deployment with proxy pattern:
     *      1. Deploys router implementation and proxy with initialization
     *      2. Deploys lending pool implementation and proxy with initialization
     *      3. Configures interest rate model parameters
     *      4. Configures liquidation threshold and bonus
     *      5. Links lending pool to router (bidirectional)
     *      6. Supplies initial liquidity to bootstrap the pool
     *
     * @param _lendingPoolParams Complete configuration including:
     *        - collateralToken: Token accepted as collateral
     *        - borrowToken: Token that can be borrowed
     *        - ltv: Loan-to-value ratio (e.g., 8e17 = 80%)
     *        - supplyLiquidity: Initial liquidity amount
     *        - baseRate: Base interest rate
     *        - rateAtOptimal: Interest rate at optimal utilization
     *        - optimalUtilization: Target utilization rate
     *        - maxUtilization: Maximum allowed utilization
     *        - maxRate: Maximum interest rate
     *        - liquidationThreshold: Threshold for liquidations
     *        - liquidationBonus: Bonus for liquidators
     *
     * @return lendingPool The address of the newly created lending pool proxy
     *
     * @custom:security Requires caller to have approved sufficient borrow tokens
     * @custom:emits LendingPoolCreated
     */
    function createLendingPool(LendingPoolParams memory _lendingPoolParams)
        public
        checkOracleOnToken(_lendingPoolParams.collateralToken)
        checkOracleOnToken(_lendingPoolParams.borrowToken)
        checkMinAmountSupplyLiquidity(_lendingPoolParams.borrowToken, _lendingPoolParams.supplyLiquidity)
        returns (address)
    {
        // Deploys implementation, creates proxy, and initializes
        (address router, address routerImplementation) =
            _deployRouterImplementation(_lendingPoolParams.collateralToken, _lendingPoolParams.borrowToken, _lendingPoolParams.ltv);

        // Deploys implementation, creates proxy, and initializes with router
        (address lendingPool, address lendingPoolImplementation) = _deployLendingPoolImplementation(router);

        _configInterestRateModel(
            router,
            _lendingPoolParams.baseRate,
            _lendingPoolParams.rateAtOptimal,
            _lendingPoolParams.optimalUtilization,
            _lendingPoolParams.maxUtilization,
            _lendingPoolParams.maxRate
        );

        _configHealthy(router, _lendingPoolParams.liquidationThreshold, _lendingPoolParams.liquidationBonus);
        ILPRouter(router).setLendingPool(lendingPool);

        // Emit sharesTokenDeployed event (moved from router initialization to here after roles are granted)
        ISupalaEmitter(supalaEmitter).sharesTokenDeployed(router, ILPRouter(router).sharesToken()); // TODO: Delete this line

        IERC20(_lendingPoolParams.borrowToken).safeTransferFrom(_msgSender(), address(this), _lendingPoolParams.supplyLiquidity);
        IERC20(_lendingPoolParams.borrowToken).approve(lendingPool, _lendingPoolParams.supplyLiquidity);
        ILendingPool(lendingPool).supplyLiquidity(_msgSender(), _lendingPoolParams.supplyLiquidity);

        ISupalaEmitter(supalaEmitter).grantRole(keccak256("ADMIN_ROLE"), lendingPool);

        emit LendingPoolCreated(_lendingPoolParams, router, routerImplementation, lendingPool, lendingPoolImplementation, _sharesToken(router));

        return lendingPool;
    }

    // =============================================================
    //                   ADMINISTRATIVE FUNCTIONS
    // =============================================================

    /**
     * @notice Sets the creator fee for a specific lending pool router
     * @dev Only callable by addresses with OWNER_ROLE
     * @param _lendingPoolRouter The address of the lending pool router
     * @param _creatorFee The creator fee to set
     */
    function setCreatorFee(address _lendingPoolRouter, uint256 _creatorFee) public onlyRole(OWNER_ROLE) {
        creatorFee[_lendingPoolRouter] = _creatorFee;
        emit CreatorFeeSet(_lendingPoolRouter, _creatorFee);
    }

    /**
     * @notice Sets the token data stream contract address for price feeds
     * @dev Only callable by addresses with OWNER_ROLE
     * @param _tokenDataStream The address of the data stream contract
     */
    function setTokenDataStream(address _tokenDataStream) public onlyRole(OWNER_ROLE) {
        tokenDataStream = _tokenDataStream;
        emit TokenDataStreamSet(_tokenDataStream);
    }

    /**
     * @notice Sets or updates the status of an operator
     * @dev Only callable by addresses with OWNER_ROLE
     * @param _operator The address of the operator to update
     * @param _status The new status for the operator (true for active, false for inactive)
     */
    function setOperator(address _operator, bool _status) public onlyRole(OWNER_ROLE) {
        operator[_operator] = _status;
        emit OperatorSet(_operator, _status);
    }

    /**
     * @notice Sets the OFT (Omnichain Fungible Token) address for a specific token
     * @dev Only callable by addresses with OWNER_ROLE. Used for cross-chain token transfers.
     * @param _token The address of the token
     * @param _oftAddress The address of the corresponding OFT wrapper
     */
    function setOftAddress(address _token, address _oftAddress) public onlyRole(OWNER_ROLE) {
        oftAddress[_token] = _oftAddress;
        emit OftAddressSet(_token, _oftAddress);
    }

    /**
     * @notice Sets the lending pool deployer contract address
     * @dev Only callable by addresses with OWNER_ROLE
     * @param _lendingPoolDeployer The address of the new lending pool deployer
     */
    function setLendingPoolDeployer(address _lendingPoolDeployer) public onlyRole(OWNER_ROLE) {
        lendingPoolDeployer = _lendingPoolDeployer;
        emit LendingPoolDeployerSet(_lendingPoolDeployer);
    }

    /**
     * @notice Sets the protocol contract address
     * @dev Only callable by addresses with OWNER_ROLE
     * @param _protocol The address of the new protocol contract
     */
    function setProtocol(address _protocol) public onlyRole(OWNER_ROLE) {
        protocol = _protocol;
        emit ProtocolSet(_protocol);
    }

    /**
     * @notice Sets the IsHealthy contract address for position health checks
     * @dev Only callable by addresses with OWNER_ROLE
     * @param _isHealthy The address of the new IsHealthy contract
     */
    function setIsHealthy(address _isHealthy) public onlyRole(OWNER_ROLE) {
        isHealthy = _isHealthy;
        emit IsHealthySet(_isHealthy);
    }

    /**
     * @notice Sets the position deployer contract address
     * @dev Only callable by addresses with OWNER_ROLE
     * @param _positionDeployer The address of the new position deployer contract
     */
    function setPositionDeployer(address _positionDeployer) public onlyRole(OWNER_ROLE) {
        positionDeployer = _positionDeployer;
        emit PositionDeployerSet(_positionDeployer);
    }

    /**
     * @notice Sets the lending pool router deployer contract address
     * @dev Only callable by addresses with OWNER_ROLE
     * @param _lendingPoolRouterDeployer The address of the new router deployer contract
     */
    function setLendingPoolRouterDeployer(address _lendingPoolRouterDeployer) public onlyRole(OWNER_ROLE) {
        lendingPoolRouterDeployer = _lendingPoolRouterDeployer;
        emit LendingPoolRouterDeployerSet(_lendingPoolRouterDeployer);
    }

    /**
     * @notice Sets the wrapped native token address
     * @dev Only callable by addresses with OWNER_ROLE. Examples: WETH, WMATIC, etc.
     * @param _wrappedNative The address of the wrapped native token
     */
    function setWrappedNative(address _wrappedNative) public onlyRole(OWNER_ROLE) {
        wrappedNative = _wrappedNative;
        emit WrappedNativeSet(_wrappedNative);
    }

    /**
     * @notice Sets the DEX router address for token swaps
     * @dev Only callable by addresses with OWNER_ROLE
     * @param _dexRouter The address of the DEX router contract
     */
    function setDexRouter(address _dexRouter) public onlyRole(OWNER_ROLE) {
        dexRouter = _dexRouter;
        emit DexRouterSet(_dexRouter);
    }

    /**
     * @notice Sets the minimum initial supply liquidity requirement for a token
     * @dev Only callable by addresses with OWNER_ROLE. This ensures pools have sufficient liquidity at creation.
     * @param _token The address of the token
     * @param _minAmountSupplyLiquidity The minimum amount of tokens required for initial liquidity
     */
    function setMinAmountSupplyLiquidity(address _token, uint256 _minAmountSupplyLiquidity) public onlyRole(OWNER_ROLE) {
        minAmountSupplyLiquidity[_token] = _minAmountSupplyLiquidity;
        emit MinAmountSupplyLiquiditySet(_token, _minAmountSupplyLiquidity);
    }

    /**
     * @notice Sets the interest rate model contract address
     * @dev Only callable by addresses with OWNER_ROLE
     * @param _interestRateModel The address of the new interest rate model contract
     */
    function setInterestRateModel(address _interestRateModel) public onlyRole(OWNER_ROLE) {
        interestRateModel = _interestRateModel;
        emit InterestRateModelSet(_interestRateModel);
    }

    /**
     * @notice Sets the LayerZero endpoint ID for a specific chain ID
     * @dev Only callable by addresses with OWNER_ROLE. Used for cross-chain messaging.
     * @param _chainId The blockchain chain ID
     * @param _eid The LayerZero endpoint ID corresponding to the chain
     */
    function setChainIdToEid(uint256 _chainId, uint32 _eid) public onlyRole(OWNER_ROLE) {
        chainIdToEid[_chainId] = _eid;
        emit ChainIdToEidSet(_chainId, _eid);
    }

    /**
     * @notice Sets the proxy deployer contract address
     * @dev Only callable by addresses with OWNER_ROLE. Used for UUPS upgradeable deployments.
     * @param _proxyDeployer The address of the proxy deployer contract
     */
    function setProxyDeployer(address _proxyDeployer) public onlyRole(OWNER_ROLE) {
        proxyDeployer = _proxyDeployer;
        emit ProxyDeployerSet(_proxyDeployer);
    }

    /**
     * @notice Sets the shares token deployer contract address
     * @dev Only callable by addresses with OWNER_ROLE
     * @param _sharesTokenDeployer The address of the shares token deployer contract
     */
    function setSharesTokenDeployer(address _sharesTokenDeployer) public onlyRole(OWNER_ROLE) {
        sharesTokenDeployer = _sharesTokenDeployer;
        emit SharesTokenDeployerSet(_sharesTokenDeployer);
    }

    function setSupalaEmitter(address _supalaEmitter) public onlyRole(OWNER_ROLE) {
        supalaEmitter = _supalaEmitter;
        emit SupalaEmitterSet(_supalaEmitter);
    }

    // =============================================================
    //                     INTERNAL FUNCTIONS
    // =============================================================

    /**
     * @notice Internal function to verify that a token has an oracle configured
     * @dev Reverts if the tokenDataStream is not set
     * @param _token The address of the token to check
     */
    function _checkOracleOnToken(address _token) internal view {
        if (tokenDataStream == address(0)) revert OracleOnTokenNotSet(_token);
    }

    /**
     * @notice Internal function to verify that supplied liquidity meets the minimum requirement
     * @dev Reverts if the supplied amount is less than the minimum or if minimum is not set
     * @param _borrowToken The address of the borrow token
     * @param _supplyLiquidity The amount of liquidity being supplied
     */
    function _checkMinAmountSupplyLiquidity(address _borrowToken, uint256 _supplyLiquidity) internal view {
        if (_supplyLiquidity < minAmountSupplyLiquidity[_borrowToken] || minAmountSupplyLiquidity[_borrowToken] == 0) {
            revert MinAmountSupplyLiquidityExceeded(_supplyLiquidity, minAmountSupplyLiquidity[_borrowToken]);
        }
    }

    /**
     * @notice Internal function to deploy router implementation
     * @return The address of the deployed router implementation
     */
    function _deployRouterImplementation(address _collateralToken, address _borrowToken, uint256 _ltv) internal returns (address, address) {
        address routerImplementation = ILPRouterDeployer(lendingPoolRouterDeployer).deployLendingPoolRouter();
        bytes memory routerData = abi.encodeWithSelector(LendingPoolRouter.initialize.selector, address(this), _collateralToken, _borrowToken, _ltv);
        address router = _deployProxy(routerImplementation, routerData);
        return (router, routerImplementation);
    }

    /**
     * @notice Internal function to deploy lending pool implementation
     * @return The address of the deployed lending pool implementation
     */
    function _deployLendingPoolImplementation(address _router) internal returns (address, address) {
        address lendingPoolImplementation = ILPDeployer(lendingPoolDeployer).deployLendingPool();
        bytes memory lendingPoolData = abi.encodeWithSelector(LendingPool.initialize.selector, _router, _msgSender());
        address lendingPool = _deployProxy(lendingPoolImplementation, lendingPoolData);
        return (lendingPool, lendingPoolImplementation);
    }

    /**
     * @notice Internal function to set interest rate model for a lending pool
     * @param _router The address of the router contract
     * @param _baseRate The base rate for the interest rate model
     * @param _rateAtOptimal The rate at optimal utilization for the interest rate model
     * @param _optimalUtilization The optimal utilization for the interest rate model
     */
    function _configInterestRateModel(
        address _router,
        uint256 _baseRate,
        uint256 _rateAtOptimal,
        uint256 _optimalUtilization,
        uint256 _maxUtilization,
        uint256 _maxRate
    )
        internal
    {
        IInterestRateModel(interestRateModel).setLendingPoolBaseRate(_router, _baseRate);
        IInterestRateModel(interestRateModel).setLendingPoolRateAtOptimal(_router, _rateAtOptimal);
        IInterestRateModel(interestRateModel).setLendingPoolOptimalUtilization(_router, _optimalUtilization);
        IInterestRateModel(interestRateModel).setLendingPoolMaxUtilization(_router, _maxUtilization);
        IInterestRateModel(interestRateModel).setLendingPoolMaxRate(_router, _maxRate);
    }

    function _configHealthy(address _router, uint256 _liquidationThreshold, uint256 _liquidationBonus) internal {
        IIsHealthy(isHealthy).setLiquidationThreshold(_router, _liquidationThreshold);
        IIsHealthy(isHealthy).setLiquidationBonus(_router, _liquidationBonus);
    }

    /**
     * @notice Internal function to deploy position implementation
     * @param _implementation The address of the implementation contract
     * @param _data The initialization data for the implementation contract
     * @return The address of the deployed position implementation
     */
    function _deployProxy(address _implementation, bytes memory _data) internal returns (address) {
        return IProxyDeployer(proxyDeployer).deployProxy(_implementation, _data);
    }

    function _sharesToken(address _router) internal view returns (address) {
        return ILPRouter(_router).sharesToken();
    }
    /**
     * @notice Fallback function to handle calls with empty data during upgrades
     * @dev This is needed for compatibility with UUPS upgrade mechanism
     */
    fallback() external { }

    /**
     * @notice Authorizes contract upgrades
     * @dev Only callable by addresses with UPGRADER_ROLE. Part of the UUPS upgrade pattern.
     * @param newImplementation The address of the new implementation contract
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) { }
}
