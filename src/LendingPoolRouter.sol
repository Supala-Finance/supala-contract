// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { ContextUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { IFactory } from "./interfaces/IFactory.sol";
import { IPositionDeployer } from "./interfaces/IPositionDeployer.sol";
import { IPosition } from "./interfaces/IPosition.sol";
import { IIsHealthy } from "./interfaces/IIsHealthy.sol";
import { IInterestRateModel } from "./interfaces/IInterestRateModel.sol";
import { IProtocol } from "./interfaces/IProtocol.sol";
import { IProxyDeployer } from "./interfaces/IProxyDeployer.sol";
import { Position } from "./Position.sol";
import { LendingPoolRouterHook } from "./lib/LendingPoolRouterHook.sol";
import { ISharesTokenDeployer } from "./interfaces/ISharesTokenDeployer.sol";
import { SupalaSharesToken } from "./SharesToken/SupalaSharesToken.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { ISupalaSharesToken } from "./interfaces/ISupalaSharesToken.sol";

/**
 * @title LendingPoolRouter
 * @author Supala Labs
 * @notice Router contract that manages lending pool operations and state
 * @dev This contract handles the core logic for supply, borrow, repay, liquidation operations,
 *      and interest calculations. It maintains the state of all user positions and implements
 *      a dynamic interest rate model based on pool utilization. The contract works in tandem
 *      with the LendingPool contract which handles token transfers and external interactions.
 */
contract LendingPoolRouter is
    LendingPoolRouterHook,
    Initializable,
    ContextUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable,
    AccessControlUpgradeable
{
    // =============================================================
    //                        STATE VARIABLES
    // =============================================================

    /// @notice Total supply assets in the pool
    uint256 public totalSupplyAssets;

    /// @notice Total borrowed assets from the pool
    uint256 public totalBorrowAssets;

    /// @notice Total borrow shares issued
    uint256 public totalBorrowShares;

    /// @notice Total reserve assets in the pool
    uint256 public totalReserveAssets;

    /// @notice Timestamp of last interest accrual
    uint256 public lastAccrued;

    /// @notice Mapping of user to their borrow shares
    mapping(address => uint256) public userBorrowShares;

    /// @notice Mapping of user to their position contract address
    mapping(address => address) public addressPositions;

    /// @notice Address of the lending pool contract
    address public lendingPool;

    /// @notice Address of the factory contract
    address public factory;

    /// @notice Address of the collateral token
    address public collateralToken;

    /// @notice Address of the borrow token
    address public borrowToken;

    /// @notice Address of the shares token
    address public sharesToken;

    /// @notice Loan-to-value ratio in basis points (e.g., 8e17 = 80%)
    uint256 public ltv;

    // =============================================================
    //                           CONSTRUCTOR
    // =============================================================

    /// @notice Initializes the LendingPool contract with a router address
    /// @dev Sets up Ownable with deployer as owner and configures the router
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializes the upgradeable contract with default settings and roles
    /// @dev This function replaces the constructor for upgradeable contracts.
    ///      Sets up default scaled percentage to 1e18 (100% in basis points)
    /// @param _factory The address of the factory contract
    /// @param _collateralToken The address of the collateral token
    /// @param _borrowToken The address of the borrow token
    /// @param _ltv The loan-to-value ratio in basis points (e.g., 8e17 = 80%)
    function initialize(address _factory, address _collateralToken, address _borrowToken, uint256 _ltv) public initializer {
        __AccessControl_init();
        __Pausable_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();

        factory = _factory;
        collateralToken = _collateralToken;
        borrowToken = _borrowToken;
        lastAccrued = block.timestamp;
        _setLtv(_ltv);

        _grantRole(DEFAULT_ADMIN_ROLE, _ownerFactory());
        _grantRole(OWNER_ROLE, _ownerFactory());
        _grantRole(UPGRADER_ROLE, _ownerFactory());

        _deploySharesToken();
    }

    // =============================================================
    //                      PAUSABLE FUNCTIONS
    // =============================================================

    /**
     * @notice Pauses all pausable functions in the contract
     * @dev Can only be called by accounts with OWNER_ROLE
     */
    function pause() external onlyRole(OWNER_ROLE) {
        _pause();
    }

    /**
     * @notice Unpauses all pausable functions in the contract
     * @dev Can only be called by accounts with OWNER_ROLE
     */
    function unpause() external onlyRole(OWNER_ROLE) {
        _unpause();
    }

    // =============================================================
    //                        MODIFIERS
    // =============================================================

    /**
     * @notice Restricts function access to factory contract only
     * @dev Reverts with NotFactory if caller is not the factory
     */
    modifier onlyFactory() {
        _onlyFactory();
        _;
    }

    /**
     * @notice Restricts function access to lending pool contract only
     * @dev Reverts with NotLendingPool if caller is not the lending pool
     */
    modifier onlyLendingPool() {
        _onlyLendingPool();
        _;
    }

    // =============================================================
    //                      INTERNAL GUARD FUNCTIONS
    // =============================================================

    /**
     * @notice Internal function to check if caller is the factory
     * @dev Reverts with NotFactory if msg.sender is not the factory address
     */
    function _onlyFactory() internal view {
        if (msg.sender != factory) revert NotFactory();
    }

    /**
     * @notice Internal function to check if caller is the lending pool
     * @dev Reverts with NotLendingPool if msg.sender is not the lending pool address
     */
    function _onlyLendingPool() internal view {
        if (msg.sender != lendingPool) revert NotLendingPool();
    }

    // =============================================================
    //                      ADMIN FUNCTIONS
    // =============================================================

    /**
     * @notice Sets a new lending pool address
     * @dev Only callable by factory contract
     * @param _lendingPool The new lending pool address
     */
    function setLendingPool(address _lendingPool) public onlyFactory {
        lendingPool = _lendingPool;
    }

    // =============================================================
    //                    SUPPLY/WITHDRAW LOGIC
    // =============================================================

    /**
     * @notice Supplies liquidity to the pool and mints shares to the user
     * @dev Only callable by lending pool. Uses a shares-based accounting system.
     *      First depositor receives shares equal to amount (1:1).
     *      Subsequent depositors receive shares proportional to their contribution.
     * @param _amount The amount of assets to supply
     * @param _user The address of the user supplying liquidity
     * @return shares The number of shares to the user (Decimals by borrow token)
     */
    function supplyLiquidity(uint256 _amount, address _user) public onlyLendingPool whenNotPaused nonReentrant returns (uint256 shares) {
        if (_amount == 0) revert ZeroAmount();
        accrueInterest();
        shares = 0;
        if (totalSupplyAssets == 0) {
            if (_amount < _minAmountSupplyLiquidity()) revert MinAmountSupplyLiquidity(_amount, _minAmountSupplyLiquidity());
            shares = _amount;
        } else {
            shares = _amount * _totalSupplyShares() / totalSupplyAssets;
        }
        totalSupplyAssets += _amount;

        uint256 mintToShares = shares * 10 ** _sharesTokenDecimals() / 10 ** _underlyingDecimals();
        ISupalaSharesToken(sharesToken).mint(_user, mintToShares);

        return shares;
    }

    /**
     * @notice Withdraws liquidity from the pool by burning shares
     * @dev Only callable by lending pool. Converts shares back to assets proportionally.
     *      Ensures sufficient liquidity remains after withdrawal.
     * @param _shares The number of shares to burn (Decimals by shares token)
     * @param _user The address of the user withdrawing liquidity
     * @return amount The amount of assets withdrawn
     */
    function withdrawLiquidity(uint256 _shares, address _user) public onlyLendingPool whenNotPaused nonReentrant returns (uint256 amount) {
        if (_shares == 0) revert ZeroAmount();
        if (_shares > _userSupplyShares(_user)) revert InsufficientShares();
        if (_totalSupplyShares() == 0) revert TotalSupplySharesZero(_shares, _totalSupplyShares());
        accrueInterest();

        uint256 burnFromShares = _shares * 10 ** _underlyingDecimals() / 10 ** _sharesTokenDecimals();
        amount = (burnFromShares * totalSupplyAssets) / _totalSupplyShares();

        // Ensure calculated amount is not zero (indicates wrong decimals were used)
        if (amount == 0) revert ZeroAmount();

        ISupalaSharesToken(sharesToken).burn(_user, _shares);
        totalSupplyAssets -= amount;

        if (totalSupplyAssets < totalBorrowAssets) {
            revert InsufficientLiquidity();
        }

        return amount;
    }

    // =============================================================
    //                      BORROW/REPAY LOGIC
    // =============================================================

    /**
     * @notice Borrows assets from the pool
     * @dev Only callable by lending pool. Mints borrow shares to the user and applies
     *      a 0.1% protocol fee. Checks maximum utilization to prevent over-borrowing.
     * @param _amount The amount of assets to borrow
     * @param _user The address of the user borrowing
     * @return creatorFee The creator fee taken
     * @return protocolFee The protocol fee taken (0.1% of borrow amount)
     * @return userAmount The amount user receives after fee
     * @return shares The number of borrow shares minted
     */
    function borrowDebt(
        uint256 _amount,
        address _user
    )
        public
        onlyLendingPool
        whenNotPaused
        nonReentrant
        returns (uint256 creatorFee, uint256 protocolFee, uint256 userAmount, uint256 shares)
    {
        if (_amount == 0) revert ZeroAmount();
        accrueInterest();
        shares = 0;
        if (totalBorrowShares == 0) {
            shares = _amount;
        } else {
            shares = ((_amount * totalBorrowShares) / totalBorrowAssets);
        }
        userBorrowShares[_user] += shares;
        totalBorrowShares += shares;
        totalBorrowAssets += _amount;

        uint256 newUtilization = (totalBorrowAssets * 1e18) / totalSupplyAssets;

        if (newUtilization >= _maxUtilization()) {
            revert MaxUtilizationReached(borrowToken, newUtilization, _maxUtilization());
        }

        protocolFee = (_amount * _protocolFee(borrowToken)) / 1e18;
        creatorFee = (_amount * _creatorFee()) / 1e18;
        userAmount = _amount - (protocolFee + creatorFee);

        if (totalBorrowAssets > totalSupplyAssets) {
            revert InsufficientLiquidity();
        }

        _checkHealthy(_user);
    }

    /**
     * @notice Repays borrowed assets by burning borrow shares
     * @dev Only callable by lending pool. Converts borrow shares to assets and burns them.
     * @param _shares The number of borrow shares to burn
     * @param _user The address of the user repaying
     * @return borrowAmount The amount of assets repaid
     */
    function repayWithSelectedToken(uint256 _shares, address _user) public onlyLendingPool whenNotPaused nonReentrant returns (uint256) {
        if (_shares == 0) revert ZeroAmount();
        if (_shares > userBorrowShares[_user]) revert InsufficientShares();
        if (totalBorrowShares == 0) revert TotalBorrowSharesZero(_shares, totalBorrowShares);

        accrueInterest();

        uint256 borrowAmount = ((_shares * totalBorrowAssets) / totalBorrowShares);
        userBorrowShares[_user] -= _shares;
        totalBorrowShares -= _shares;
        totalBorrowAssets -= borrowAmount;

        return borrowAmount;
    }

    // =============================================================
    //                         LIQUIDATION LOGIC
    // =============================================================

    /**
     * @notice Liquidates an undercollateralized position
     * @dev Only callable by lending pool. Checks if position is liquidatable via health check,
     *      accrues interest before liquidation, and clears borrower's position.
     *      Liquidator receives most of the collateral while a portion goes to protocol.
     * @param _borrower The address of the borrower being liquidated
     * @return userBorrowAssets The total borrow assets of the borrower
     * @return liquidationBonus The amount allocated to protocol
     * @return userPosition The address of the borrower's position contract
     */
    function liquidation(address _borrower) public onlyLendingPool whenNotPaused nonReentrant returns (uint256, uint256, address) {
        // Check if borrower is authorized (has position)
        if (userBorrowShares[_borrower] == 0 && _userCollateral(_borrower) == 0) {
            revert NotLiquidable(_borrower);
        }

        // Check if position is liquidatable
        (bool isLiquidatable, uint256 borrowValue, uint256 collateralValue, uint256 liquidationBonus) =
            IIsHealthy(_isHealthy()).checkLiquidatable(_borrower, address(this));

        if (!isLiquidatable) {
            revert AssetNotLiquidatable(collateralToken, collateralValue, borrowValue);
        }

        // Accrue interest before liquidation
        accrueInterest();

        // Get borrower's state
        uint256 userBorrowAssets = _borrowSharesToAmount(userBorrowShares[_borrower]);
        address userPosition = addressPositions[_borrower];

        // Update state: clear borrower's position
        totalBorrowAssets -= userBorrowAssets;
        totalBorrowShares -= userBorrowShares[_borrower];
        userBorrowShares[_borrower] = 0;
        addressPositions[_borrower] = address(0);

        return (userBorrowAssets, liquidationBonus, userPosition);
    }

    // =============================================================
    //                      INTEREST RATE CALCULATIONS
    // =============================================================

    /**
     * @notice Accrues interest to the pool
     * @dev Calculates interest based on elapsed time since last accrual and adds it
     *      to both totalSupplyAssets and totalBorrowAssets. This increases the value
     *      of supply shares and borrow shares proportionally.
     */
    function accrueInterest() public {
        uint256 elapsedTime = block.timestamp - lastAccrued;
        if (elapsedTime == 0) return; // No time elapsed, skip
        lastAccrued = block.timestamp;
        if (totalBorrowAssets == 0) return;
        (uint256 interest, uint256 supplyYield, uint256 reserveYield) =
            IInterestRateModel(_interestRateModel()).calculateInterest(address(this), elapsedTime);
        totalBorrowAssets += interest;
        totalSupplyAssets += supplyYield;
        totalReserveAssets += reserveYield;
        emit InterestAccrued(interest, supplyYield, reserveYield);
    }

    // =============================================================
    //                    SHARES MANAGEMENT
    // =============================================================

    /**
     * @notice Internal function to deploy shares token for a lending pool
     * @return The address of the deployed shares token
     */
    function _deploySharesToken() internal returns (address, address) {
        string memory tokenName = IERC20Metadata(borrowToken).name();
        string memory tokenSymbol = IERC20Metadata(borrowToken).symbol();
        uint8 underlyingDecimals = IERC20Metadata(borrowToken).decimals();
        uint256 date = block.timestamp;

        address sharesTokenImplementation = ISharesTokenDeployer(_sharesTokenDeployer()).deploySharesToken();
        bytes memory sharesTokenData =
            abi.encodeWithSelector(SupalaSharesToken.initialize.selector, factory, date, tokenName, tokenSymbol, underlyingDecimals, address(this));
        address sharesTokenProxy = _deployProxy(sharesTokenImplementation, sharesTokenData);

        sharesToken = sharesTokenProxy;
        emit SharesTokenDeployed(sharesTokenProxy, sharesTokenImplementation);
        return (sharesTokenProxy, sharesTokenImplementation);
    }

    // =============================================================
    //                    POSITION MANAGEMENT
    // =============================================================

    /**
     * @notice Creates a new position contract for a user
     * @dev Only callable by lending pool. Deploys a new Position contract via factory
     *      and stores it in addressPositions mapping. Reverts if position already exists.
     * @param _user The address of the user
     * @return The address of the newly created position contract
     */
    function createPosition(address _user) public onlyLendingPool whenNotPaused nonReentrant returns (address) {
        if (addressPositions[_user] != address(0)) revert PositionAlreadyCreated();
        address positionImplementation = IPositionDeployer(_positionDeployer()).deployPosition();
        bytes memory positionData = abi.encodeWithSelector(Position.initialize.selector, lendingPool, _user);
        address position = _deployProxy(positionImplementation, positionData);
        addressPositions[_user] = position;
        return position;
    }

    // =============================================================
    //                    INTERNAL HELPER FUNCTIONS
    // =============================================================

    /**
     * @notice Converts borrow shares to borrow assets
     * @dev Internal view function for shares-to-assets conversion
     * @param _shares The number of borrow shares
     * @return The equivalent amount of borrow assets
     */
    function _borrowSharesToAmount(uint256 _shares) internal view returns (uint256) {
        return (_shares * totalBorrowAssets) / totalBorrowShares;
    }

    /// @notice Sets the loan-to-value ratio
    /// @dev Can only be called by accounts with OWNER_ROLE
    /// @param _ltv The loan-to-value ratio in basis points (e.g., 8e17 = 80%)
    function _setLtv(uint256 _ltv) internal {
        if (_ltv == 0 || _ltv > 1e18) revert InvalidLtv(_ltv);
        ltv = _ltv;
    }

    // =============================================================
    //                         POSITIONS
    // =============================================================
    /**
     * @notice Gets the total collateral of a user from their position
     * @dev Internal view function that queries the user's position contract
     * @param _user The address of the user
     * @return The total collateral amount held in user's position
     */
    function _userCollateral(address _user) internal view returns (uint256) {
        return IPosition(addressPositions[_user]).totalCollateral();
    }

    // =============================================================
    //                          FACTORY
    // =============================================================
    /**
     * @notice Gets the protocol contract address from factory
     * @dev Internal view function that queries the factory for the protocol contract
     * @return The address of the protocol contract
     */
    function _protocol() internal view returns (address) {
        return IFactory(factory).protocol();
    }

    /**
     * @notice Gets the health checker contract address from factory
     * @dev Internal view function that queries the factory for the IsHealthy contract
     * @return The address of the IsHealthy contract
     */
    function _isHealthy() internal view returns (address) {
        return IFactory(factory).isHealthy();
    }

    /**
     * @notice Gets the position deployer address from factory
     * @dev Internal view function that queries the factory for the PositionDeployer contract
     * @return The address of the position deployer contract
     */
    function _positionDeployer() internal view returns (address) {
        return IFactory(factory).positionDeployer();
    }

    /**
     * @notice Gets the interest rate model contract address from factory
     * @dev Internal view function that queries the factory
     * @return The address of the interest rate model contract
     */
    function _interestRateModel() internal view returns (address) {
        return IFactory(factory).interestRateModel();
    }

    /**
     * @notice Gets the owner address from factory
     * @dev Internal view function that queries the factory for the owner address
     * @return The address of the owner
     */
    function _ownerFactory() internal view returns (address) {
        return IFactory(factory).owner();
    }

    /**
     * @notice Gets the proxy deployer address from factory
     * @dev Internal view function that queries the factory for the ProxyDeployer contract
     * @return The address of the proxy deployer contract
     */
    function _proxyDeployer() internal view returns (address) {
        return IFactory(factory).proxyDeployer();
    }

    /**
     * @notice Gets the creator fee from factory
     * @dev Internal view function that queries the factory for the creator fee
     * @return The creator fee
     */
    function _creatorFee() internal view returns (uint256) {
        uint256 creatorFee = IFactory(factory).creatorFee(address(this));
        return creatorFee == 0 ? 1e14 : creatorFee;
    }

    /**
     * @notice Gets the shares token deployer address from factory
     * @dev Internal view function that queries the factory for the SharesTokenDeployer contract
     * @return The address of the shares token deployer contract
     */
    function _sharesTokenDeployer() internal view returns (address) {
        return IFactory(factory).sharesTokenDeployer();
    }

    /**
     * @notice Gets the minimum amount of liquidity from factory
     * @dev Internal view function that queries the factory for the minimum amount of liquidity
     * @return The minimum amount of liquidity
     */
    function _minAmountSupplyLiquidity() internal view returns (uint256) {
        return IFactory(factory).minAmountSupplyLiquidity(borrowToken);
    }

    // =============================================================
    //                  SHARES TOKEN FUNCTIONS
    // =============================================================

    /**
     * @notice Gets the total supply of shares token
     * @dev Internal view function that queries the shares token for the total supply
     * @return The total supply of shares token
     */
    function _totalSupply() internal view returns (uint256) {
        return ISupalaSharesToken(sharesToken).totalSupply();
    }

    /**
     * @notice Gets the user's supply of shares token
     * @dev Internal view function that queries the shares token for the user's supply
     * @param _user The address of the user
     * @return The user's supply of shares token
     */
    function _userSupplyShares(address _user) internal view returns (uint256) {
        return ISupalaSharesToken(sharesToken).balanceOf(_user);
    }

    /**
     * @notice Gets the total supply of shares token in underlying
     * @dev Internal view function that queries the shares token for the total supply in underlying
     * @return The total supply of shares token in underlying
     */
    function _totalSupplyShares() internal view returns (uint256) {
        return _totalSupply() * 10 ** _underlyingDecimals() / 10 ** _sharesTokenDecimals();
    }

    /**
     * @notice Gets the decimals of shares token
     * @dev Internal view function that queries the shares token for the decimals
     * @return The decimals of shares token
     */
    function _sharesTokenDecimals() internal view returns (uint8) {
        return ISupalaSharesToken(sharesToken).decimals();
    }

    /**
     * @notice Gets the decimals of underlying token
     * @dev Internal view function that queries the shares token for the decimals of underlying token
     * @return The decimals of underlying token
     */
    function _underlyingDecimals() internal view returns (uint8) {
        return ISupalaSharesToken(sharesToken).underlyingDecimals();
    }

    // =============================================================
    //                         PROTOCOL
    // =============================================================

    /**
     * @notice Gets the protocol fee for a token from protocol contract
     * @dev Internal view function that queries the protocol contract for the protocol fee
     * @param _token The address of the token
     * @return The protocol fee for the token
     */
    function _protocolFee(address _token) internal view returns (uint256) {
        return IProtocol(_protocol()).getProtocolFee(_token);
    }

    // =============================================================
    //                    INTEREST RATE MODEL
    // =============================================================

    /**
     * @notice Gets the maximum utilization allowed for this lending pool
     * @dev Internal view function that queries the interest rate model
     * @return The maximum utilization rate (scaled by 1e18)
     */
    function _maxUtilization() internal view returns (uint256) {
        return IInterestRateModel(_interestRateModel()).lendingPoolMaxUtilization(address(this));
    }

    // =============================================================
    //                          ISHEALTHY
    // =============================================================
    /**
     * @notice Internal function to check if user is healthy
     * @param _user User address
     */
    function _checkHealthy(address _user) internal view {
        IIsHealthy(_isHealthy()).isHealthy(_user, address(this));
    }

    // =============================================================
    //                          PROXY
    // =============================================================
    function _deployProxy(address _implementation, bytes memory _data) internal returns (address) {
        return IProxyDeployer(_proxyDeployer()).deployProxy(_implementation, _data);
    }

    // =============================================================
    //                       UPGRADE FUNCTIONS
    // =============================================================

    /// @notice Authorizes contract upgrades
    /// @dev Only accounts with UPGRADER_ROLE can authorize upgrades.
    ///      This is required by the UUPSUpgradeable pattern.
    /// @param newImplementation The address of the new implementation contract
    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) { }
}
