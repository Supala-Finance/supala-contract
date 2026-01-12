// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { InterestRateModel } from "@src/InterestRateModel.sol";
import { Helper } from "@script/DevTools/Helper.sol";
import { SelectRpc } from "@script/DevTools/SelectRpc.sol";

contract InterestRateModel_Upgrades is Script, Helper, SelectRpc {
    address public owner = vm.envAddress("PUBLIC_KEY");
    uint256 public privateKey = vm.envUint("PRIVATE_KEY");

    InterestRateModel public interestRateModel;
    InterestRateModel public newImplementation;

    function setUp() public {
        selectRpc();
        _getUtils();
    }

    function run() public {
        vm.startBroadcast(privateKey);
        newImplementation = new InterestRateModel();
        interestRateModel = InterestRateModel(payable(KAIA_TESTNET_INTEREST_RATE_MODEL));
        interestRateModel.upgradeToAndCall(address(newImplementation), "");

        console.log("InterestRateModel Address: ", address(interestRateModel));
        console.log("New Implementation Address: ", address(newImplementation));
        vm.stopBroadcast();
    }
}

// RUN
// forge script InterestRateModel_Upgrades --broadcast -vvv --verify
// forge script InterestRateModel_Upgrades -vvv
