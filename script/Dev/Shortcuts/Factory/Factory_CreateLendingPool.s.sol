// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script } from "forge-std/Script.sol";
import { LendingPoolFactory } from "@src/LendingPoolFactory.sol";
import { LendingPoolFactoryHook } from "@src/lib/LendingPoolFactoryHook.sol";
import { Helper } from "@script/DevTools/Helper.sol";
import { MOCKUSDT } from "@src/MockToken/MOCKUSDT.sol";
import { SelectRpc } from "@script/DevTools/SelectRpc.sol";

contract Factory_CreateLendingPool is Script, Helper, SelectRpc {
    LendingPoolFactory public factory;
    MOCKUSDT public mockUsdt;

    address public owner = vm.envAddress("PUBLIC_KEY");
    uint256 public privateKey = vm.envUint("PRIVATE_KEY");

    function setUp() public {
        selectRpc();
    }

    function run() public {
        mockUsdt = MOCKUSDT(KAIA_TESTNET_MOCK_USDT);
        factory = LendingPoolFactory(payable(KAIA_TESTNET_LENDING_POOL_FACTORY));

        vm.startBroadcast(privateKey);
        mockUsdt.mint(owner, 1e6);
        mockUsdt.approve(address(factory), 1e6);
        LendingPoolFactoryHook.LendingPoolParams memory lendingPoolParams = LendingPoolFactoryHook.LendingPoolParams({
            collateralToken: KAIA_TESTNET_MOCK_WETH,
            borrowToken: KAIA_TESTNET_MOCK_USDT,
            ltv: 70e16,
            supplyLiquidity: 1e6,
            baseRate: 0.05e16,
            rateAtOptimal: 6e16,
            optimalUtilization: 80e16,
            maxUtilization: 100e16,
            maxRate: 20e16,
            liquidationThreshold: 75e16,
            liquidationBonus: 10e16
        });
        factory.createLendingPool(lendingPoolParams);
        vm.stopBroadcast();
    }
}

// RUN
// forge script Factory_CreateLendingPool --broadcast -vvv
// forge script Factory_CreateLendingPool -vvv
