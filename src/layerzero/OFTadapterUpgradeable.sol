// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { OFTAdapterUpgradeable } from "@layerzerolabs/oft-evm-upgradeable/contracts/oft/OFTAdapterUpgradeable.sol";
import { IElevatedMintableBurnable } from "../interfaces/IElevatedMintableBurnable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { ChainSettlement } from "./ChainSettlement.sol";

/**
 * @title OFTadapterUpgradeable
 * @notice Upgradeable LayerZero OFT Adapter for token cross-chain transfers with configurable decimals
 * @dev Enables bridging of tokens between chains with lock/unlock on source chain and mint/burn on destination chains
 * @dev Uses UUPS proxy pattern for upgradeability
 */
contract OFTadapterUpgradeable is OFTAdapterUpgradeable, ReentrancyGuard, ChainSettlement {
    using SafeERC20 for IERC20;

    /// @custom:storage-location erc7201:supala.storage.SupalaOFTAdapterUpgradeable
    struct OftAdapterStorage {
        /// @notice Address of the OFT token being bridged
        address tokenOft;
        /// @notice Address of the elevated minter/burner contract
        address elevatedMinterBurner;
    }

    // keccak256(abi.encode(uint256(keccak256("supala.storage.SupalaOFTAdapterUpgradeable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant OFT_ADAPTER_STORAGE_LOCATION = 0x8f9d1c5e4b6a3d2f1e0c9b8a7d6e5f4c3b2a1d0e9f8c7b6a5d4e3f2c1b0a9d00;

    function _getOftAdapterStorage() private pure returns (OftAdapterStorage storage $) {
        assembly {
            $.slot := OFT_ADAPTER_STORAGE_LOCATION
        }
    }

    /// @notice Error thrown when contract has insufficient balance for transfer
    error InsufficientBalance();

    /// @notice Emitted when tokens are credited to a user on destination chain
    /// @param to Recipient address
    /// @param amount Amount of tokens credited
    event Credit(address to, uint256 amount);

    /// @notice Emitted when tokens are debited from a user on source chain
    /// @param from Sender address
    /// @param amount Amount of tokens debited
    event Debit(address from, uint256 amount);

    /**
     * @notice Constructs the upgradeable OFT Adapter
     * @param _token Address of the token to bridge
     * @param _lzEndpoint Address of the LayerZero endpoint
     * @dev Constructor sets immutable variables and disables initializers on implementation
     * @dev Shared decimals defaults to 6 as defined in OFTCoreUpgradeable base contract
     */
    constructor(address _token, address _lzEndpoint) OFTAdapterUpgradeable(_token, _lzEndpoint) {
        _disableInitializers();
    }

    /**
     * @notice Initializes the upgradeable OFT Adapter
     * @param _owner Address of the contract owner
     * @param _elevatedMinterBurner Address of the minter/burner contract
     * @dev Can only be called once due to initializer modifier
     */
    function initialize(address _owner, address _elevatedMinterBurner) public initializer {
        __OFTAdapter_init(_owner);

        OftAdapterStorage storage $ = _getOftAdapterStorage();
        $.tokenOft = token();
        $.elevatedMinterBurner = _elevatedMinterBurner;
    }

    /**
     * @notice Returns the OFT token address
     * @return Address of the token being bridged
     */
    function tokenOft() public view returns (address) {
        OftAdapterStorage storage $ = _getOftAdapterStorage();
        return $.tokenOft;
    }

    /**
     * @notice Returns the elevated minter/burner address
     * @return Address of the minter/burner contract
     */
    function elevatedMinterBurner() public view returns (address) {
        OftAdapterStorage storage $ = _getOftAdapterStorage();
        return $.elevatedMinterBurner;
    }

    /**
     * @notice Internal function to credit tokens to recipient on destination chain
     * @param _to Recipient address
     * @param _amountLd Amount in local decimals
     * @return amountReceivedLd Amount actually received
     * @dev On chain SETTLEMENT_CHAIN_ID, transfers from adapter. On other chains, mints tokens.
     */
    function _credit(address _to, uint256 _amountLd, uint32) internal virtual override returns (uint256 amountReceivedLd) {
        OftAdapterStorage storage $ = _getOftAdapterStorage();

        if (_to == address(0x0)) _to = address(0xdead);

        if (block.chainid == SETTLEMENT_CHAIN_ID) {
            if (IERC20($.tokenOft).balanceOf(address(this)) < _amountLd) revert InsufficientBalance();
            IERC20($.tokenOft).safeTransfer(_to, _amountLd);
        } else {
            IElevatedMintableBurnable($.elevatedMinterBurner).mint(_to, _amountLd);
        }

        emit Credit(_to, _amountLd);
        return _amountLd;
    }

    /**
     * @notice Internal function to debit tokens from sender on source chain
     * @param _from Sender address
     * @param _amountLd Amount in local decimals
     * @param _minAmountLd Minimum amount to receive
     * @param _dstEid Destination endpoint ID
     * @return amountSentLd Amount sent
     * @return amountReceivedLd Amount to be received on destination
     * @dev On chain SETTLEMENT_CHAIN_ID, locks tokens in adapter. On other chains, burns tokens.
     */
    function _debit(
        address _from,
        uint256 _amountLd,
        uint256 _minAmountLd,
        uint32 _dstEid
    )
        internal
        virtual
        override
        returns (uint256 amountSentLd, uint256 amountReceivedLd)
    {
        OftAdapterStorage storage $ = _getOftAdapterStorage();

        (amountSentLd, amountReceivedLd) = _debitView(_amountLd, _minAmountLd, _dstEid);

        if (block.chainid == SETTLEMENT_CHAIN_ID) {
            IERC20($.tokenOft).safeTransferFrom(_from, address(this), amountSentLd);
        } else {
            IERC20($.tokenOft).safeTransferFrom(_from, address(this), amountSentLd);
            IERC20($.tokenOft).approve($.elevatedMinterBurner, amountSentLd);
            IElevatedMintableBurnable($.elevatedMinterBurner).burn(_from, amountSentLd);
        }

        emit Debit(_from, _amountLd);
    }

    /**
     * @notice Sets the elevated minter/burner contract address
     * @param _elevatedMinterBurner New minter/burner address
     * @dev Only callable by contract owner
     */
    function setElevatedMinterBurner(address _elevatedMinterBurner) external onlyOwner {
        OftAdapterStorage storage $ = _getOftAdapterStorage();
        $.elevatedMinterBurner = _elevatedMinterBurner;
    }
}
