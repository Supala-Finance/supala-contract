// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { ILendingPool } from "@src/interfaces/ILendingPool.sol";
import { BorrowParams } from "@src/lib/LendingPoolHook.sol";
import { SendParam } from "@layerzerolabs/oft-evm/contracts/interfaces/IOFT.sol";
import { MessagingFee } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import { Helper } from "@script/DevTools/Helper.sol";
import { SelectRpc } from "@script/DevTools/SelectRpc.sol";
import { HelperUtils } from "@src/HelperUtils.sol";

contract Pool_BorrowDebtCrossChain is Script, Helper, SelectRpc {
    address public owner = vm.envAddress("PUBLIC_KEY");
    uint256 public privateKey = vm.envUint("PRIVATE_KEY");
    // Set the lending pool address here
    address public lendingPool = 0xc635dB9f6A988eE1e83CB9fb786Eb3eC3670f991; // Replace with actual lending pool address

    // Set borrow parameters here
    uint256 public borrowAmount = 1e6; // Amount to borrow
    uint256 public destinationChainId = 84532; // Destination chain ID
    uint128 public gasOption = 200000; // LayerZero gas option

    // LayerZero parameters (need to be configured)
    uint32 public dstEid = 40245; // Destination endpoint ID
    bytes32 public toAddress = bytes32(uint256(uint160(owner))); // Recipient address on destination chain
    // uint256 public nativeFee = 0; // Native fee for messaging
    // uint256 public lzTokenFee = 0; // LZ token fee

    function setUp() public {
        selectRpc();
    }

    function run() public {
        require(lendingPool != address(0), "Lending pool address not set");
        require(borrowAmount > 0, "Borrow amount must be greater than 0");
        require(destinationChainId != 0, "Destination chain ID not set");
        require(dstEid != 0, "Destination endpoint ID not set");

        ILendingPool pool = ILendingPool(lendingPool);

        // Construct SendParam
        SendParam memory sendParam =
            SendParam({ dstEid: dstEid, to: toAddress, amountLD: borrowAmount, minAmountLD: 0, extraOptions: "", composeMsg: "", oftCmd: "" });

        // Construct MessagingFee
        MessagingFee memory fee = MessagingFee({ nativeFee: 0, lzTokenFee: 0 });

        // Construct BorrowParams
        BorrowParams memory params = BorrowParams({
            sendParam: sendParam, fee: fee, amount: borrowAmount, chainId: destinationChainId, addExecutorLzReceiveOption: gasOption
        });

        (uint256 nativeFee, uint256 lzTokenFee) = HelperUtils(MANTLE_TESTNET_HELPER_UTILS).getFee(params, lendingPool, false);

        params.fee = MessagingFee({ nativeFee: nativeFee, lzTokenFee: lzTokenFee });

        console.log("Native Fee:", nativeFee);
        console.log("LZ Token Fee:", lzTokenFee);

        console.log("Lending Pool Address:", lendingPool);
        console.log("Borrow Amount:", borrowAmount);
        console.log("Destination Chain ID:", destinationChainId);
        console.log("Destination EID:", dstEid);

        vm.broadcast(privateKey);
        pool.borrowDebtCrossChain{ value: nativeFee }(params);

        console.log("Cross-chain debt borrowed successfully");
    }
}

// RUN
// forge script Pool_BorrowDebtCrossChain --broadcast -vvv
// forge script Pool_BorrowDebtCrossChain -vvv
