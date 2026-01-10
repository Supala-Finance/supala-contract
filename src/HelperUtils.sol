// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { ILendingPool } from "./interfaces/ILendingPool.sol";
import { IPosition } from "./interfaces/IPosition.sol";
import { IFactory } from "./interfaces/IFactory.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IOracle } from "./interfaces/IOracle.sol";
import { ILPRouter } from "./interfaces/ILPRouter.sol";
import { OFTadapter } from "./layerzero/OFTadapter.sol";
import { OptionsBuilder } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";
import { MessagingFee } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import { ITokenDataStream } from "./interfaces/ITokenDataStream.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { BorrowParams } from "./lib/LendingPoolHook.sol";

/**
 * @title HelperUtils
 * @notice Utility contract providing helper functions for lending pool calculations and queries
 * @dev Aggregates data from lending pools, positions, oracles, and provides various metrics
 */
contract HelperUtils is Ownable {
    using OptionsBuilder for bytes;

    /// @notice Address of the factory contract
    address public factory;

    /**
     * @notice Constructs the HelperUtils contract
     * @param _factory Address of the factory contract
     */
    constructor(address _factory) Ownable(msg.sender) {
        factory = _factory;
    }

    /**
     * @notice Sets the factory contract address
     * @param _factory New factory contract address
     */
    function setFactory(address _factory) public onlyOwner {
        factory = _factory;
    }

    /**
     * @notice Calculates the maximum amount a user can borrow from a lending pool
     * @param _lendingPool Address of the lending pool
     * @param _user Address of the user
     * @return Maximum borrow amount available (limited by collateral and pool liquidity)
     * @dev Returns the minimum of: user's borrowing capacity based on collateral and LTV, or pool's available liquidity
     */
    function getMaxBorrowAmount(address _lendingPool, address _user) public view returns (uint256) {
        address borrowToken = _borrowToken(_lendingPool);
        uint256 totalLiquidity;

        if (borrowToken == _wrappedNative()) {
            // Handle Wrapped Native token
            totalLiquidity = IERC20(_wrappedNative()).balanceOf(_lendingPool);
        } else {
            // Handle ERC20 tokens
            totalLiquidity = IERC20(borrowToken).balanceOf(_lendingPool);
        }

        uint256 tokenValue = _calculateCollateralValue(_lendingPool, _user);
        uint256 borrowAmount = _calculateCurrentBorrowAmount(_lendingPool, _user);
        uint256 maxBorrowAmount = ((tokenValue * _ltv(_lendingPool)) / 1e18) - borrowAmount;
        return maxBorrowAmount < totalLiquidity ? maxBorrowAmount : totalLiquidity;
    }

    /**
     * @notice Calculates the exchange rate between two tokens
     * @param _tokenIn Address of the input token
     * @param _tokenOut Address of the output token
     * @param _amountIn Amount of input token
     * @param _position Address of the position contract for calculation
     * @return Exchange rate value
     * @dev Uses oracle prices to calculate conversion rate
     */
    function getExchangeRate(address _tokenIn, address _tokenOut, uint256 _amountIn, address _position) public view returns (uint256) {
        uint256 tokenValue = IPosition(_position)._tokenCalculator(_tokenIn, _tokenOut, _amountIn);

        return tokenValue;
    }

    /**
     * @notice Gets the current price of a token from the oracle
     * @param _token Address of the token
     * @return Current price of the token
     */
    function getTokenValue(address _token) public view returns (uint256) {
        address oracleAddress = _oracleAddress(_token);
        (, uint256 tokenPrice,,,) = IOracle(oracleAddress).latestRoundData();
        return uint256(tokenPrice);
    }

    /**
     * @notice Calculates the LayerZero messaging fee for a cross-chain token transfer
     * @param params BorrowParams struct containing parameters for the cross-chain transfer
     * @param _lendingPool Address of the lending pool
     * @param _payInLzToken Boolean indicating whether to pay in LZ token
     * @return Native fee required for the cross-chain transfer
     */
    function getFee(BorrowParams calldata params, address _lendingPool, bool _payInLzToken) public view returns (uint256, uint256) {
        OFTadapter oft = OFTadapter(_oftBorrowToken(_lendingPool));
        // bytes memory extraOptions = OptionsBuilder.newOptions().addExecutorLzReceiveOption(65000, 0);
        // SendParam memory sendParam = SendParam({
        //     dstEid: _dstEid,
        //     to: _addressToBytes32(_toAddress),
        //     amountLD: _tokensToSend,
        //     minAmountLD: _tokensToSend,
        //     extraOptions: extraOptions,
        //     composeMsg: "",
        //     oftCmd: ""
        // });

        // Get fee quote
        MessagingFee memory fee = oft.quoteSend(params.sendParam, _payInLzToken);

        return (fee.nativeFee, fee.lzTokenFee);
    }

    /**
     * @notice Gets the total available liquidity in a lending pool
     * @param _lendingPool Address of the lending pool
     * @return totalLiquidity Available liquidity amount
     */
    function getTotalLiquidity(address _lendingPool) public view returns (uint256 totalLiquidity) {
        address borrowToken = ILPRouter(_router(_lendingPool)).borrowToken();
        if (borrowToken == address(1)) {
            totalLiquidity = IERC20(_wrappedNative()).balanceOf(_lendingPool);
        } else {
            totalLiquidity = IERC20(borrowToken).balanceOf(_lendingPool);
        }
        return totalLiquidity;
    }

    /**
     * @notice Gets the collateral balance of a user in a lending pool
     * @param _lendingPool Address of the lending pool
     * @param _user Address of the user
     * @return collateralBalance User's collateral balance
     */
    function getCollateralBalance(address _lendingPool, address _user) public view returns (uint256 collateralBalance) {
        address collateralToken = ILPRouter(_router(_lendingPool)).collateralToken();
        address addressPosition = ILPRouter(_router(_lendingPool)).addressPositions(_user);
        if (collateralToken == address(1)) {
            collateralBalance = IERC20(_wrappedNative()).balanceOf(addressPosition);
        } else {
            collateralBalance = IERC20(collateralToken).balanceOf(addressPosition);
        }
        return collateralBalance;
    }

    /**
     * @notice Gets the router address for a lending pool
     * @param _lendingPool Address of the lending pool
     * @return Address of the lending pool router
     */
    function getRouter(address _lendingPool) public view returns (address) {
        return ILendingPool(_lendingPool).router();
    }

    /**
     * @notice Internal function to calculate the total value of user's collateral
     * @param _lendingPool Address of the lending pool
     * @param _user Address of the user
     * @return Total collateral value in borrow token terms
     */
    function _calculateCollateralValue(address _lendingPool, address _user) internal view returns (uint256) {
        address collateralToken = _collateralToken(_lendingPool);
        address borrowToken = _borrowToken(_lendingPool);
        address addressPosition = _addressPositions(_lendingPool, _user);

        uint256 collateralBalance;
        if (collateralToken == _wrappedNative()) {
            // Handle Wrapped Native token
            collateralBalance = IERC20(_wrappedNative()).balanceOf(addressPosition);
        } else {
            // Handle ERC20 tokens
            collateralBalance = IERC20(collateralToken).balanceOf(addressPosition);
        }

        IPosition position = IPosition(addressPosition);
        return position._tokenCalculator(collateralToken, borrowToken, collateralBalance);
    }

    /**
     * @notice Internal function to calculate user's current borrow amount
     * @param _lendingPool Address of the lending pool
     * @param _user Address of the user
     * @return Current borrow amount based on user's shares
     */
    function _calculateCurrentBorrowAmount(address _lendingPool, address _user) internal view returns (uint256) {
        uint256 totalBorrowAssets = _totalBorrowAssets(_lendingPool);
        uint256 totalBorrowShares = _totalBorrowShares(_lendingPool);
        uint256 userBorrowShares = _userBorrowShares(_lendingPool, _user);

        return totalBorrowAssets == 0 ? 0 : (userBorrowShares * totalBorrowAssets) / totalBorrowShares;
    }

    /**
     * @notice Internal function to get the router interface
     * @param _lendingPool Address of the lending pool
     * @return ILPRouter interface
     */
    function _router(address _lendingPool) internal view returns (ILPRouter) {
        return ILPRouter(ILendingPool(_lendingPool).router());
    }

    /**
     * @notice Internal function to get the borrow token address
     * @param _lendingPool Address of the lending pool
     * @return Address of the borrow token
     */
    function _borrowToken(address _lendingPool) internal view returns (address) {
        return _router(_lendingPool).borrowToken();
    }

    /**
     * @notice Internal function to get the collateral token address
     * @param _lendingPool Address of the lending pool
     * @return Address of the collateral token
     */
    function _collateralToken(address _lendingPool) internal view returns (address) {
        return _router(_lendingPool).collateralToken();
    }

    /**
     * @notice Internal function to get the loan-to-value ratio
     * @param _lendingPool Address of the lending pool
     * @return LTV ratio
     */
    function _ltv(address _lendingPool) internal view returns (uint256) {
        return _router(_lendingPool).ltv();
    }

    /**
     * @notice Internal function to get user's position address
     * @param _lendingPool Address of the lending pool
     * @param _user Address of the user
     * @return Address of the user's position contract
     */
    function _addressPositions(address _lendingPool, address _user) internal view returns (address) {
        return _router(_lendingPool).addressPositions(_user);
    }

    /**
     * @notice Internal function to get total borrow assets in the pool
     * @param _lendingPool Address of the lending pool
     * @return Total borrow assets
     */
    function _totalBorrowAssets(address _lendingPool) internal view returns (uint256) {
        return _router(_lendingPool).totalBorrowAssets();
    }

    /**
     * @notice Internal function to get total borrow shares in the pool
     * @param _lendingPool Address of the lending pool
     * @return Total borrow shares
     */
    function _totalBorrowShares(address _lendingPool) internal view returns (uint256) {
        return _router(_lendingPool).totalBorrowShares();
    }

    /**
     * @notice Internal function to get user's borrow shares
     * @param _lendingPool Address of the lending pool
     * @param _user Address of the user
     * @return User's borrow shares
     */
    function _userBorrowShares(address _lendingPool, address _user) internal view returns (uint256) {
        return _router(_lendingPool).userBorrowShares(_user);
    }

    /**
     * @notice Internal function to get the token data stream address
     * @return Address of the token data stream contract
     */
    function _tokenDataStream() internal view returns (address) {
        return IFactory(factory).tokenDataStream();
    }

    /**
     * @notice Internal function to get the oracle address for a token
     * @param _token Address of the token
     * @return Address of the token's price feed oracle
     */
    function _oracleAddress(address _token) internal view returns (address) {
        return ITokenDataStream(_tokenDataStream()).tokenPriceFeed(_token);
    }

    /**
     * @notice Internal function to convert address to bytes32
     * @param _address Address to convert
     * @return bytes32 representation of the address
     */
    function _addressToBytes32(address _address) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_address)));
    }

    /**
     * @notice Internal function to get the wrapped native token address
     * @return Address of the wrapped native token
     */
    function _wrappedNative() internal view returns (address) {
        return IFactory(factory).wrappedNative();
    }

    function _oftBorrowToken(address _lendingPool) internal view returns (address) {
        return IFactory(factory).oftAddress(_borrowToken(_lendingPool));
    }
}
