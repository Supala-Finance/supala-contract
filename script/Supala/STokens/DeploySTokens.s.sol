// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { SelectRpc } from "@script/DevTools/SelectRpc.sol";
import { STOKEN } from "@src/BridgeToken/STOKEN.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { OFTadapter } from "@src/layerzero/OFTadapter.sol";
import { ElevatedMinterBurner } from "@src/layerzero/ElevatedMinterBurner.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { Helper } from "@script/DevTools/Helper.sol";
// ======================= LayerZero =======================
import { MyOApp } from "@src/layerzero/MyOApp.sol";
import { ILayerZeroEndpointV2 } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import { SetConfigParam } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";
import { UlnConfig } from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";
import { ExecutorConfig } from "@layerzerolabs/lz-evm-messagelib-v2/contracts/SendLibBase.sol";
import { EnforcedOptionParam } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";
import { OptionsBuilder } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";

contract DeploySTokens is Script, SelectRpc, Helper {
    using OptionsBuilder for bytes;

    STOKEN public stoken;
    ERC1967Proxy public proxy;
    ElevatedMinterBurner public elevatedminterburner;
    OFTadapter public oftadapter;

    address public owner = vm.envAddress("PUBLIC_KEY");
    uint256 public privateKey = vm.envUint("PRIVATE_KEY");

    function setUp() public {
        selectDstRpc();
    }

    function run() public virtual {
        vm.startBroadcast(privateKey);
        _getUtils();
        // _deploySToken("Senja USDC", "sUSDC", 6);
        _deploySToken("", "", 6);
        _setLibraries(address(0));
        _setSendConfig(address(0));
        _setReceiveConfig(address(0));
        _setPeers(address(0), address(0));
        _setEnforcedOptions(address(0));
        vm.stopBroadcast();
    }

    function _deploySToken(string memory _name, string memory _symbol, uint8 _decimals) internal {
        stoken = new STOKEN();
        console.log("address public constant %s_%s_IMPLEMENTATION = %s;", chainName, _symbol, address(stoken));
        bytes memory data = abi.encodeWithSelector(stoken.initialize.selector, _name, _symbol, _decimals);
        proxy = new ERC1967Proxy(address(stoken), data);
        stoken = STOKEN(address(proxy));
        console.log("address public constant %s_%s = %s;", chainName, _symbol, address(proxy));
    }

    function _deployOft(address _token) internal virtual {
        elevatedminterburner = new ElevatedMinterBurner(_token, owner);
        string memory tokenTicker = IERC20Metadata(_token).symbol();
        console.log("address public constant %s_%s_ELEVATED_MINTER_BURNER = %s;", chainName, tokenTicker, address(elevatedminterburner));
        oftadapter = new OFTadapter(_token, address(elevatedminterburner), endpoint, owner, _tokenDecimals(_token));
        console.log("address public constant %s_%s_OFT_ADAPTER = %s;", chainName, tokenTicker, address(oftadapter));
        oapp = address(oftadapter);
        elevatedminterburner.setOperator(oapp, true);
    }

    function _setLibraries(address _oapp) internal virtual {
        ILayerZeroEndpointV2(endpoint).setSendLibrary(_oapp, eid0, sendLib);
        ILayerZeroEndpointV2(endpoint).setSendLibrary(_oapp, eid1, sendLib);
        ILayerZeroEndpointV2(endpoint).setReceiveLibrary(_oapp, srcEid, receiveLib, gracePeriod);
    }

    function _setSendConfig(address _oapp) internal virtual {
        UlnConfig memory uln = UlnConfig({
            confirmations: 15,
            requiredDVNCount: _getRequiredDvnCount(),
            optionalDVNCount: type(uint8).max,
            optionalDVNThreshold: 0,
            requiredDVNs: _toDynamicDvnArray([dvn1, dvn2]),
            optionalDVNs: new address[](0)
        });

        ExecutorConfig memory exec = ExecutorConfig({ maxMessageSize: 10000, executor: executor });
        bytes memory encodedUln = abi.encode(uln);
        bytes memory encodedExec = abi.encode(exec);
        SetConfigParam[] memory params = new SetConfigParam[](4);
        params[0] = SetConfigParam({ eid: eid0, configType: EXECUTOR_CONFIG_TYPE, config: encodedExec });
        params[1] = SetConfigParam({ eid: eid0, configType: ULN_CONFIG_TYPE, config: encodedUln });
        params[2] = SetConfigParam({ eid: eid1, configType: EXECUTOR_CONFIG_TYPE, config: encodedExec });
        params[3] = SetConfigParam({ eid: eid1, configType: ULN_CONFIG_TYPE, config: encodedUln });

        ILayerZeroEndpointV2(endpoint).setConfig(_oapp, sendLib, params);
    }

    function _setReceiveConfig(address _oapp) internal virtual {
        UlnConfig memory uln = UlnConfig({
            confirmations: 15,
            requiredDVNCount: _getRequiredDvnCount(),
            optionalDVNCount: type(uint8).max,
            optionalDVNThreshold: 0,
            requiredDVNs: _toDynamicDvnArray([dvn1, dvn2]),
            optionalDVNs: new address[](0)
        });
        bytes memory encodedUln = abi.encode(uln);
        SetConfigParam[] memory params = new SetConfigParam[](2);
        params[0] = SetConfigParam({ eid: eid0, configType: RECEIVE_CONFIG_TYPE, config: encodedUln });
        params[1] = SetConfigParam({ eid: eid1, configType: RECEIVE_CONFIG_TYPE, config: encodedUln });

        ILayerZeroEndpointV2(endpoint).setConfig(_oapp, receiveLib, params);
    }

    function _setPeers(address _oappSrc, address _oappDst) internal virtual {
        bytes32 oftPeerSrc = bytes32(uint256(uint160(address(_oappSrc)))); // oappSrc
        bytes32 oftPeerDst = bytes32(uint256(uint160(address(_oappDst)))); // oappDst
        OFTadapter(_oappSrc).setPeer(eid0, oftPeerSrc);
        OFTadapter(_oappSrc).setPeer(eid1, oftPeerDst);
    }

    function _setEnforcedOptions(address _oapp) internal virtual {
        bytes memory options1 = OptionsBuilder.newOptions().addExecutorLzReceiveOption(80000, 0);
        bytes memory options2 = OptionsBuilder.newOptions().addExecutorLzReceiveOption(100000, 0);

        EnforcedOptionParam[] memory enforcedOptions = new EnforcedOptionParam[](2);
        enforcedOptions[0] = EnforcedOptionParam({ eid: eid0, msgType: SEND, options: options1 });
        enforcedOptions[1] = EnforcedOptionParam({ eid: eid1, msgType: SEND, options: options2 });

        MyOApp(_oapp).setEnforcedOptions(enforcedOptions);
    }

    function _setRoleSTokenToElevated(address _stoken, address _elevated) internal virtual {
        STOKEN(_stoken).grantRole(MINTER_ROLE, _elevated);
    }

    function _tokenDecimals(address _token) internal view virtual returns (uint8) {
        return IERC20Metadata(_token).decimals();
    }
}

// RUN
// forge script DeploySTokens --broadcast -vvv --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
// forge script DeploySTokens --broadcast -vvv --verify
// forge script DeploySTokens --broadcast -vvv
// forge script DeploySTokens -vvv
