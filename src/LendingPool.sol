// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { ContextUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { OFTadapter } from "./layerzero/OFTadapter.sol";
import { IFactory } from "./interfaces/IFactory.sol";
import { IPosition } from "./interfaces/IPosition.sol";
import { ILPRouter } from "./interfaces/ILPRouter.sol";
import { IWrappedNative } from "./interfaces/IWrappedNative.sol";
import { ISupalaEmitter } from "./interfaces/ISupalaEmitter.sol";
import { LendingPoolHook } from "./lib/LendingPoolHook.sol";
import { BorrowParams, RepayParams } from "./lib/LendingPoolHook.sol";
import { SwapHook } from "./lib/SwapHook.sol";

/**
 * @title LendingPool
 * @notice Core lending pool contract for supplying liquidity, borrowing, and managing collateral
 * @dev Implements lending pool functionality with cross-chain borrowing via LayerZero and position-based collateral management
 */
contract LendingPool is
    Initializable,
    ContextUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable,
    AccessControlUpgradeable,
    LendingPoolHook,
    SwapHook
{
    using SafeERC20 for IERC20;

    /// @notice Address of the lending pool router contract
    address public router;

    /// @notice Address of the creator of the lending pool
    address public creator;

    /// @dev Track if we're in a withdrawal operation to avoid auto-wrapping
    bool private _withdrawing;

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
    function initialize(address _router, address _creator) public initializer {
        __AccessControl_init();
        __Pausable_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();

        router = _router;
        creator = _creator;

        _grantRole(DEFAULT_ADMIN_ROLE, _ownerFactory());
        _grantRole(OWNER_ROLE, _ownerFactory());
        _grantRole(UPGRADER_ROLE, _ownerFactory());
    }

    /**
     * @notice Modifier to ensure user has a position contract
     * @param _user User address to check
     * @dev Creates position if it doesn't exist
     */
    modifier positionRequired(address _user) {
        _positionRequired(_user);
        _;
    }

    /**
     * @notice Modifier for access control checks
     * @param _user User address to validate
     * @dev Allows operators or the user themselves
     */
    modifier accessControl(address _user) {
        _accessControl(_user);
        _;
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
    //                      EXTERNAL FUNCTIONS
    // =============================================================

    /**
     * @notice Supply liquidity to the lending pool by depositing borrow tokens.
     * @dev Users receive shares proportional to their deposit. Shares represent ownership in the pool. Accrues interest before deposit.
     * @param _user The address of the user to supply liquidity.
     * @param _amount The amount of borrow tokens to supply as liquidity.
     * @custom:emits SupplyLiquidity when liquidity is supplied.
     */
    function supplyLiquidity(address _user, uint256 _amount) public payable whenNotPaused nonReentrant accessControl(_user) {
        uint256 shares = _supplyLiquidity(_amount, _user);
        _supplyLiquidityTransfer(_amount);
        emit SupplyLiquidity(_user, _amount, shares);
    }

    /**
     * @notice Withdraw supplied liquidity by redeeming shares for underlying tokens.
     * @dev Calculates the corresponding asset amount based on the proportion of total shares. Accrues interest before withdrawal.
     * @param _shares The number of supply shares to redeem for underlying tokens.
     * @custom:throws TransferFailed if the transfer fails.
     * @custom:emits WithdrawLiquidity when liquidity is withdrawn.
     */
    function withdrawLiquidity(uint256 _shares) public payable whenNotPaused nonReentrant {
        uint256 amount = _withdrawLiquidity(_shares);
        _withdrawLiquidityTransfer(amount);
        emit WithdrawLiquidity(_msgSender(), amount, _shares);
    }

    /**
     * @notice Supply collateral tokens to the user's position in the lending pool.
     * @dev Transfers collateral tokens from user to their Position contract. Accrues interest before deposit.
     * @param _user The address of the user to supply collateral.
     * @param _amount The amount of collateral tokens to supply.
     * @custom:throws ZeroAmount if amount is 0.
     * @custom:emits SupplyCollateral when collateral is supplied.
     */
    function supplyCollateral(address _user, uint256 _amount) public payable whenNotPaused nonReentrant positionRequired(_user) accessControl(_user) {
        if (_amount == 0) revert ZeroAmount();
        _accrueInterest();
        _supplyCollateralTransfer(_user, _amount);
        emit SupplyCollateral(_addressPositions(_user), _user, _amount);
    }

    /**
     * @notice Withdraw supplied collateral from the user's position.
     * @dev Transfers collateral tokens from Position contract back to user. Accrues interest before withdrawal.
     * @param _amount The amount of collateral tokens to withdraw.
     * @custom:throws ZeroAmount if amount is 0.
     * @custom:throws InsufficientCollateral if user has insufficient collateral balance.
     */
    function withdrawCollateral(uint256 _amount) public whenNotPaused nonReentrant positionRequired(_msgSender()) accessControl(_msgSender()) {
        if (_amount == 0) revert ZeroAmount();
        _accrueInterest();
        _withdrawCollateralTransfer(_amount);
        emit WithdrawCollateral(_msgSender(), _amount);
    }

    /**
     * @notice Borrow assets using supplied collateral on the same chain
     * @dev Calculates shares, checks liquidity, and handles local transfers. Accrues interest before borrowing.
     * @param _amount Amount of tokens to borrow
     * @custom:throws InsufficientLiquidity if protocol lacks liquidity
     * @custom:emits BorrowDebt when borrow is successful
     */
    function borrowDebt(uint256 _amount) public payable nonReentrant whenNotPaused {
        (uint256 creatorFee, uint256 protocolFee, uint256 userAmount, uint256 shares) = _borrowDebt(_amount, _msgSender());
        _borrowDebtTransfer(userAmount, creatorFee, protocolFee);
        emit BorrowDebt(_msgSender(), protocolFee, userAmount, shares, _amount);
    }

    /**
     * @notice Borrow assets and send them to a different chain via LayerZero
     * @dev Calculates shares, checks liquidity, and handles cross-chain transfers
     * @param params Struct containing:
     *        - sendParam: LayerZero send parameters
     *        - fee: Messaging fee for cross-chain
     *        - amount: Amount to borrow
     *        - chainId: Destination chain ID (must differ from block.chainid)
     *        - addExecutorLzReceiveOption: LayerZero gas option
     * @custom:throws InsufficientLiquidity if protocol lacks liquidity
     * @custom:emits BorrowDebt when borrow is successful
     */
    function borrowDebtCrossChain(BorrowParams calldata params) public payable nonReentrant whenNotPaused {
        (uint256 creatorFee, uint256 protocolFee, uint256 userAmount, uint256 shares) = _borrowDebt(params.amount, _msgSender());
        if (params.chainId == block.chainid) revert SameChain();
        // LAYERZERO IMPLEMENTATION
        _borrowDebtCrosschain(userAmount, creatorFee, protocolFee, params);
        emit BorrowDebtCrossChain(_msgSender(), protocolFee, userAmount, shares, params);
    }

    /**
     * @notice Swaps tokens within a user's position
     * @param params Struct containing:
     *        - tokenIn: Address of the input token
     *        - tokenOut: Address of the output token
     *        - amountIn: Amount of input tokens
     *        - amountOutMinimum: Minimum output amount (slippage protection)
     * @return amountOut Amount of output tokens received
     * @dev Oracle validation done in Position contract
     */
    function swapTokenByPosition(SwapParams calldata params)
        public
        whenNotPaused
        nonReentrant
        positionRequired(_msgSender())
        accessControl(_msgSender())
        returns (uint256 amountOut)
    {
        amountOut = IPosition(_addressPositions(_msgSender())).swapTokenByPosition(params);
        emit SwapTokenByPosition(_msgSender(), params.tokenIn, params.tokenOut, params.amountIn, amountOut);
    }

    /**
     * @notice Repays debt using a selected token. Can swap collateral to borrow token for repayment.
     * @dev Allows flexible repayment using any configured token. Checks health after repayment.
     * @param params Struct containing:
     *        - user: The user whose debt is being repaid
     *        - token: The token to use for repayment (can be borrow token or collateral token)
     *        - shares: The amount of shares to repay
     *        - amountOutMinimum: The slippage tolerance in basis points (e.g., 500 = 5%)
     *        - fromPosition: Whether to use tokens from the position contract (true) or from the user's wallet (false)
     * @custom:throws ZeroAmount if shares is 0.
     * @custom:emits RepayByPosition when repayment is successful.
     */
    function repayWithSelectedToken(RepayParams calldata params)
        public
        payable
        whenNotPaused
        nonReentrant
        positionRequired(params.user)
        accessControl(params.user)
    {
        uint256 borrowAmount = _repayWithSelectedToken(params.shares, params.user);
        _repayWithSelectedTokenTransfer(params, borrowAmount);
        emit RepayByPosition(params.user, borrowAmount, params.shares);
    }

    /**
     * @notice Liquidates an unhealthy borrower's position
     * @param _borrower The address of the borrower to liquidate
     * @dev Transfers borrow token from liquidator, sends collateral bonus to liquidator
     */
    function liquidation(address _borrower) public nonReentrant {
        (uint256 userBorrowAssets, uint256 liquidationBonus, address userPosition) = ILPRouter(router).liquidation(_borrower);

        _isNativeTransferFrom(_msgSender(), _borrowToken(), userBorrowAssets);
        IPosition(userPosition).liquidation(_msgSender(), liquidationBonus);

        emit Liquidation(_borrower, _borrowToken(), _collateralToken(), userBorrowAssets, liquidationBonus);
    }

    // =============================================================
    //                    INTERNAL HELPER FUNCTIONS
    // =============================================================

    /**
     * @notice Creates a new Position contract for the caller if one does not already exist.
     * @dev Each user can have only one Position contract. The Position contract manages collateral and borrowed assets for the user.
     * @param _user The address of the user to create a position.
     * @custom:throws PositionAlreadyCreated if the caller already has a Position contract.
     * @custom:emits CreatePosition when a new Position is created.
     */
    function _createPosition(address _user) internal {
        if (_addressPositions(_user) != address(0)) revert PositionAlreadyCreated(_addressPositions(_user));
        ILPRouter(router).createPosition(_user);
        ISupalaEmitter(_supalaEmitter()).positionCreated(address(this), router, _user, _addressPositions(_user));
    }

    /**
     * @notice Internal function to calculate and apply accrued interest to the protocol.
     * @dev Uses dynamic interest rate model based on utilization. Updates total supply and borrow assets and last accrued timestamp.
     */
    function _accrueInterest() internal {
        ILPRouter(router).accrueInterest();
    }

    // =============================================================
    //                      ROUTER DELEGATIONS
    // =============================================================

    /**
     * @notice Gets the borrow token address from router
     * @return Address of the borrow token
     */
    function _borrowToken() internal view returns (address) {
        return ILPRouter(router).borrowToken();
    }

    /**
     * @notice Gets the collateral token address from router
     * @return Address of the collateral token
     */
    function _collateralToken() internal view returns (address) {
        return ILPRouter(router).collateralToken();
    }

    /**
     * @notice Gets user's borrow shares from router
     * @param _user User address
     * @return User's borrow shares
     */
    function _userBorrowShares(address _user) internal view returns (uint256) {
        return ILPRouter(router).userBorrowShares(_user);
    }

    /**
     * @notice Gets user's position contract address from router
     * @param _user User address
     * @return Address of user's position contract
     */
    function _addressPositions(address _user) internal view returns (address) {
        return ILPRouter(router).addressPositions(_user);
    }

    /**
     * @notice Internal function to supply liquidity via router
     * @param _amount Amount to supply
     * @param _user User address
     * @return Shares minted
     */
    function _supplyLiquidity(uint256 _amount, address _user) internal returns (uint256) {
        return ILPRouter(router).supplyLiquidity(_amount, _user);
    }

    /**
     * @notice Internal function to withdraw liquidity via router
     * @param _shares Shares to burn
     * @return Amount withdrawn
     */
    function _withdrawLiquidity(uint256 _shares) internal returns (uint256) {
        return ILPRouter(router).withdrawLiquidity(_shares, _msgSender());
    }

    /**
     * @notice Internal function to process borrow request via router
     * @param _amount Amount to borrow
     * @param _user User address
     * @return protocolFee Protocol fee amount
     * @return userAmount Amount user receives
     * @return shares Borrow shares minted
     */
    function _borrowDebt(uint256 _amount, address _user) internal returns (uint256, uint256, uint256, uint256) {
        return ILPRouter(router).borrowDebt(_amount, _user);
    }

    /**
     * @notice Gets factory contract address from router
     * @return Factory address
     */
    function _factory() internal view returns (address) {
        return ILPRouter(router).factory();
    }

    // =============================================================
    //                   FACTORY & PROTOCOL GETTERS
    // =============================================================

    /**
     * @notice Gets protocol address from factory
     * @return Protocol address
     */
    function _protocol() internal view returns (address) {
        return IFactory(_factory()).protocol();
    }

    /**
     * @notice Gets wrapped native token address from factory
     * @return Wrapped native token address
     */
    function _wrappedNative() internal view returns (address) {
        return IFactory(_factory()).wrappedNative();
    }

    /**
     * @notice Converts chain ID to LayerZero endpoint ID
     * @param _chainId Chain ID to convert
     * @return LayerZero endpoint ID
     */
    function _chainIdToEid(uint256 _chainId) internal view returns (uint32) {
        return IFactory(_factory()).chainIdToEid(_chainId);
    }

    /**
     * @notice Gets OFT adapter address for borrow token
     * @return OFT adapter address
     */
    function _oftBorrowToken() internal view returns (address) {
        return IFactory(_factory()).oftAddress(_borrowToken());
    }

    /**
     * @notice Gets the owner address from factory
     * @dev Internal view function that queries the factory for the owner address
     * @return The address of the owner
     */
    function _ownerFactory() internal view returns (address) {
        return IFactory(_factory()).owner();
    }

    /**
     * @notice Gets the SupalaEmitter address from factory
     * @return SupalaEmitter address
     */
    function _supalaEmitter() internal view returns (address) {
        return IFactory(_factory()).supalaEmitter();
    }

    // =============================================================
    //                      TRANSFER HANDLERS
    // =============================================================

    /**
     * @notice Internal function to handle liquidity supply token transfer
     * @param _amount Amount to transfer
     * @dev Handles both native and ERC20 tokens
     */
    function _supplyLiquidityTransfer(uint256 _amount) internal {
        if (_borrowToken() == address(1)) {
            if (msg.value != _amount) revert SupplyLiquidityWrongInputAmount(msg.value, _amount);
            IWrappedNative(_wrappedNative()).deposit{ value: _amount }();
        } else {
            IERC20(_borrowToken()).safeTransferFrom(_msgSender(), address(this), _amount);
        }
    }

    /**
     * @notice Internal function to handle liquidity withdrawal token transfer
     * @param amount Amount to withdraw
     * @dev Handles both native and ERC20 tokens, unwraps native tokens
     */
    function _withdrawLiquidityTransfer(uint256 amount) internal {
        if (_borrowToken() == address(1)) {
            _withdrawing = true;
            IWrappedNative(_wrappedNative()).withdraw(amount);
            (bool sent,) = _msgSender().call{ value: amount }("");
            if (!sent) revert TransferFailed(amount);
            _withdrawing = false;
        } else {
            IERC20(_borrowToken()).safeTransfer(_msgSender(), amount);
        }
    }

    /**
     * @notice Internal function to handle collateral supply token transfer
     * @param _user User address
     * @param _amount Amount to supply
     * @dev Transfers tokens from user to their position contract
     */
    function _supplyCollateralTransfer(address _user, uint256 _amount) internal {
        if (_collateralToken() == address(1)) {
            if (msg.value != _amount) revert CollateralWrongInputAmount(msg.value, _amount);
            IWrappedNative(_wrappedNative()).deposit{ value: msg.value }();
            IERC20(_wrappedNative()).approve(_addressPositions(_user), _amount);
            IERC20(_wrappedNative()).safeTransfer(_addressPositions(_user), _amount);
        } else {
            IERC20(_collateralToken()).safeTransferFrom(_user, _addressPositions(_user), _amount);
        }
    }

    /**
     * @notice Internal function to handle collateral withdrawal token transfer
     * @param _amount Amount to withdraw
     * @dev Withdraws tokens from position contract to user
     */
    function _withdrawCollateralTransfer(uint256 _amount) internal {
        address tokenToCheck = _collateralToken() == address(1) ? _wrappedNative() : _collateralToken();
        uint256 userCollateralBalance = IERC20(tokenToCheck).balanceOf(_addressPositions(_msgSender()));
        if (_amount > userCollateralBalance) revert InsufficientCollateral(_amount, userCollateralBalance);
        IPosition(_addressPositions(_msgSender())).withdrawCollateral(_amount, _msgSender());
    }

    /**
     * @notice Internal function to handle cross-chain borrow via LayerZero
     * @param _userAmount Amount user receives
     * @param _protocolFee Protocol fee amount
     * @param params Struct containing:
     *        - sendParam: LayerZero send parameters
     *        - fee: Messaging fee for cross-chain
     *        - amount: Amount to borrow
     *        - chainId: Destination chain ID (must differ from block.chainid)
     *        - addExecutorLzReceiveOption: LayerZero gas option
     * @dev Sends tokens via OFT adapter to destination chain
     */
    function _borrowDebtCrosschain(uint256 _userAmount, uint256 _creatorFee, uint256 _protocolFee, BorrowParams memory params) internal {
        IERC20(_borrowToken()).safeTransfer(_protocol(), _protocolFee);
        IERC20(_borrowToken()).safeTransfer(creator, _creatorFee);
        IERC20(_borrowToken()).approve(_oftBorrowToken(), _userAmount);
        params.sendParam.amountLD = _userAmount;
        params.sendParam.minAmountLD = 0;
        if (params.fee.nativeFee > 0) {
            OFTadapter(_oftBorrowToken()).send{ value: params.fee.nativeFee }(params.sendParam, params.fee, _msgSender());
        } else {
            revert("Fee only native allowed");
        }
    }

    /**
     * @notice Internal function to handle local borrow token transfer
     * @param _userAmount Amount to send to user
     * @param _creatorFee Fee amount to send to creator
     * @param _protocolFee Fee amount to send to protocol
     * @dev Handles both native and ERC20 tokens
     */
    function _borrowDebtTransfer(uint256 _userAmount, uint256 _creatorFee, uint256 _protocolFee) internal {
        if (_borrowToken() == address(1)) {
            _withdrawing = true;
            uint256 totalToWithdraw = _userAmount + _protocolFee + _creatorFee;
            IWrappedNative(_wrappedNative()).withdraw(totalToWithdraw);
            (bool sent,) = _protocol().call{ value: _protocolFee }("");
            if (!sent) revert TransferFailed(_protocolFee);
            (bool sent2,) = creator.call{ value: _creatorFee }("");
            if (!sent2) revert TransferFailed(_creatorFee);
            (bool sent3,) = _msgSender().call{ value: _userAmount }("");
            if (!sent3) revert TransferFailed(_userAmount);
            _withdrawing = false;
        } else {
            IERC20(_borrowToken()).safeTransfer(_protocol(), _protocolFee);
            IERC20(_borrowToken()).safeTransfer(creator, _creatorFee);
            IERC20(_borrowToken()).safeTransfer(_msgSender(), _userAmount);
        }
    }

    /**
     * @notice Internal function to handle repayment token transfer
     * @param params Repayment parameters struct
     * @dev Handles token swap if needed and transfers from appropriate source
     */
    function _repayWithSelectedTokenTransfer(RepayParams memory params, uint256 borrowAmount) internal {
        // Construct SwapParams for Position calls
        SwapParams memory swapParams = SwapParams({
            tokenIn: params.token, tokenOut: _borrowToken(), amountIn: borrowAmount, amountOutMinimum: params.amountOutMinimum, fee: params.fee
        });

        if (params.fromPosition) {
            IPosition(_addressPositions(params.user)).repayWithSelectedToken(swapParams);
        } else {
            if (params.token != _borrowToken()) {
                // Transfer selected token from user, then swap to borrow token
                _isNativeTransferFrom(params.user, params.token, borrowAmount);
                IERC20(params.token).approve(_addressPositions(params.user), borrowAmount);
                IPosition(_addressPositions(params.user)).swapTokenToBorrow(swapParams);
            } else {
                // Transfer borrow token directly from user
                _isNativeTransferFrom(params.user, _borrowToken(), borrowAmount);
            }
        }
    }

    // =============================================================
    //                       REPAY LOGIC
    // =============================================================

    /**
     * @notice Internal function to process repayment with selected token via router
     * @param _shares Shares to repay
     * @param _user User address
     * @return borrowAmount Borrow amount repaid
     */
    function _repayWithSelectedToken(uint256 _shares, address _user) internal returns (uint256) {
        return ILPRouter(router).repayWithSelectedToken(_shares, _user);
    }

    /**
     * @notice Internal function to handle native token transfer from user
     * @param _user User address
     * @param _token Token address (address(1) for native)
     * @param _amount Amount to transfer
     * @dev Wraps native tokens or transfers ERC20
     */
    function _isNativeTransferFrom(address _user, address _token, uint256 _amount) internal {
        if (_token == address(1)) {
            if (msg.value != _amount) revert WrongInputAmount(msg.value, _amount);
            IWrappedNative(_wrappedNative()).deposit{ value: msg.value }();
        } else {
            IERC20(_token).safeTransferFrom(_user, address(this), _amount);
        }
    }

    // =============================================================
    //                    ACCESS CONTROL HELPERS
    // =============================================================

    /**
     * @notice Internal function for access control validation
     * @param _user User address to validate
     * @dev Allows operators or the user themselves
     */
    function _accessControl(address _user) internal view {
        if (!IFactory(_factory()).operator(_msgSender())) {
            if (_msgSender() != _user) revert NotAuthorized(_msgSender());
        }
    }

    /**
     * @notice Internal function to ensure user has a position
     * @param _user User address
     * @dev Creates position if it doesn't exist
     */
    function _positionRequired(address _user) internal {
        if (_addressPositions(_user) == address(0)) {
            _createPosition(_user);
        }
    }

    // =============================================================
    //                    RECEIVE & FALLBACK
    // =============================================================

    /**
     * @notice Receive function to handle incoming native tokens
     * @dev Auto-wraps native tokens when appropriate, rejects during withdrawals
     */
    receive() external payable {
        // Only auto-wrap if this is the native token lending pool and not during withdrawal
        if (msg.value > 0 && !_withdrawing && (_borrowToken() == address(1) || _collateralToken() == address(1))) {
            IWrappedNative(_wrappedNative()).deposit{ value: msg.value }();
        } else if (msg.value > 0 && _withdrawing) {
            // During withdrawal, don't wrap - just pass through
            return;
        } else if (msg.value > 0) {
            // Unexpected native token - revert to prevent loss
            revert("Unexpected native token");
        }
    }

    /**
     * @notice Fallback function to prevent accidental native token loss
     * @dev Always reverts to protect users
     */
    fallback() external payable {
        // Fallback should not accept native tokens to prevent accidental loss
        revert("Fallback not allowed");
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
