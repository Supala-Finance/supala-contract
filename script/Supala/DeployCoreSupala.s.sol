// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

// ======================= LIB =======================
import { Script, console } from "forge-std/Script.sol";
import { SelectRpc } from "../DevTools/SelectRpc.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
// ======================= Core Source =======================
import { LendingPoolFactory } from "@src/LendingPoolFactory.sol";
import { IsHealthy } from "@src/IsHealthy.sol";
import { LendingPoolDeployer } from "@src/LendingPoolDeployer.sol";
import { Protocol } from "@src/Protocol.sol";
import { Oracle } from "@src/Oracle.sol";
import { OFTadapter } from "@src/layerzero/OFTadapter.sol";
import { OFTKAIAadapter } from "@src/layerzero/OFTKAIAAdapter.sol";
import { OFTUSDTadapter } from "@src/layerzero/OFTUSDTAdapter.sol";
import { ElevatedMinterBurner } from "@src/layerzero/ElevatedMinterBurner.sol";
import { HelperUtils } from "@src/HelperUtils.sol";
import { PositionDeployer } from "@src/PositionDeployer.sol";
import { LendingPoolRouterDeployer } from "@src/LendingPoolRouterDeployer.sol";
import { TokenDataStream } from "@src/TokenDataStream.sol";
import { InterestRateModel } from "@src/InterestRateModel.sol";
import { ProxyDeployer } from "@src/ProxyDeployer.sol";
import { SharesTokenDeployer } from "@src/SharesTokenDeployer.sol";
import { SupalaEmitter } from "@src/SupalaEmitter.sol";
// ======================= Helper =======================
import { Helper } from "../DevTools/Helper.sol";
// ======================= MockDex =======================
import { MockDex } from "@src/MockDex/MockDex.sol";
// ======================= MockToken =======================
import { MOCKUSDT } from "@src/MockToken/MOCKUSDT.sol";
import { MOCKUSDC } from "@src/MockToken/MOCKUSDC.sol";
import { MOCKWMNT } from "@src/MockToken/MOCKWMNT.sol";
import { MOCKWETH } from "@src/MockToken/MOCKWETH.sol";
import { MOCKWBTC } from "@src/MockToken/MOCKWBTC.sol";
// ======================= LayerZero =======================
import { MyOApp } from "@src/layerzero/MyOApp.sol";
import { ILayerZeroEndpointV2 } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import { SetConfigParam } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";
import { UlnConfig } from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";
import { ExecutorConfig } from "@layerzerolabs/lz-evm-messagelib-v2/contracts/SendLibBase.sol";
import { EnforcedOptionParam } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";
import { OptionsBuilder } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";
// ======================= Interfaces =======================
import { IFactory } from "@src/interfaces/IFactory.sol";
import { IIsHealthy } from "@src/interfaces/IIsHealthy.sol";
import { Orakl } from "@src/MockOrakl/Orakl.sol";

contract DeployCoreSupala is Script, SelectRpc, Helper {
    using OptionsBuilder for bytes;

    IsHealthy public isHealthy;
    LendingPoolRouterDeployer public lendingPoolRouterDeployer;
    LendingPoolDeployer public lendingPoolDeployer;
    Protocol public protocol;
    PositionDeployer public positionDeployer;
    LendingPoolFactory public lendingPoolFactory;
    Oracle public oracle;
    OFTadapter public oftadapter;
    OFTUSDTadapter public oftusdtadapter;
    OFTKAIAadapter public oftkaiaadapter;
    ElevatedMinterBurner public elevatedminterburner;
    HelperUtils public helperUtils;
    ERC1967Proxy public proxy;
    ProxyDeployer public proxyDeployer;
    MOCKUSDT public mockUsdt;
    MOCKUSDC public mockUsdc;
    MOCKWMNT public mockWmnt;
    MOCKWETH public mockWeth;
    MOCKWBTC public mockWbtc;
    MockDex public mockDex;
    Orakl public mockOrakl;
    TokenDataStream public tokenDataStream;
    InterestRateModel public interestRateModel;
    SharesTokenDeployer public sharesTokenDeployer;
    SupalaEmitter public supalaEmitter;

    address public owner = vm.envAddress("PUBLIC_KEY");
    uint256 public privateKey = vm.envUint("PRIVATE_KEY");

    function setUp() public {
        selectRpc();
    }

    function run() public virtual {
        vm.startPrank(owner);

        _getUtils();
        // *************** layerzero ***************
        _deployOft(address(0));
        _setLibraries(address(0));
        _setSendConfig(address(0));
        _setReceiveConfig(address(0));
        _setPeers();
        _setEnforcedOptions();

        // *****************************************

        _deployTokenDataStream();
        _setTokenDataStream(address(0), address(0));
        _deployInterestRateModel();
        _deployDeployer();
        _deployIsHealthy();
        _deployProtocol();
        _deployFactory();
        _deploySupalaEmitter();
        _setDeployerToFactory();
        _setEmittedRoles();
        _setCoreFactoryConfig();
        _setSharesTokenDeployerConfig();
        _setFactoryConfig();
        _setMockDexFactory();
        _configIsHealthy();
        _setInterestRateModelToFactory();
        _setInterestRateModelTokenReserveFactor(address(0), 0);
        _deployHelperUtils();
        _setOftAddress();

        vm.stopPrank();
    }

    function _getUtils() internal override {
        super._getUtils();
        // usdt = _deployMockToken("USDT");
        // wNative = _deployMockToken(WMNT");
        // weth = _deployMockToken("WETH");
        // dexRouter = _deployMockDex();

        if (block.chainid == 5003) {
            mockDex = MockDex(MANTLE_TESTNET_MOCK_DEX);
            tokenDataStream = TokenDataStream(MANTLE_TESTNET_TOKEN_DATA_STREAM);
            interestRateModel = InterestRateModel(MANTLE_TESTNET_INTEREST_RATE_MODEL);
            lendingPoolDeployer = LendingPoolDeployer(MANTLE_TESTNET_LENDING_POOL_DEPLOYER);
            lendingPoolRouterDeployer = LendingPoolRouterDeployer(MANTLE_TESTNET_LENDING_POOL_ROUTER_DEPLOYER);
            positionDeployer = PositionDeployer(MANTLE_TESTNET_POSITION_DEPLOYER);
            proxyDeployer = ProxyDeployer(MANTLE_TESTNET_PROXY_DEPLOYER);
            sharesTokenDeployer = SharesTokenDeployer(MANTLE_TESTNET_SHARES_TOKEN_DEPLOYER);
            isHealthy = IsHealthy(MANTLE_TESTNET_IS_HEALTHY);
            protocol = Protocol(payable(MANTLE_TESTNET_PROTOCOL));
            lendingPoolFactory = LendingPoolFactory(MANTLE_TESTNET_LENDING_POOL_FACTORY);
            supalaEmitter = SupalaEmitter(MANTLE_TESTNET_SUPALA_EMITTER);
        } else {
            revert("Invalid chainid");
        }
    }

    function _deployMockToken(string memory _name) internal returns (address) {
        if (keccak256(abi.encodePacked(_name)) == keccak256(abi.encodePacked("USDT"))) {
            mockUsdt = new MOCKUSDT();
            return address(mockUsdt);
        } else if (keccak256(abi.encodePacked(_name)) == keccak256(abi.encodePacked("USDC"))) {
            mockUsdc = new MOCKUSDC();
            return address(mockUsdc);
        } else if (keccak256(abi.encodePacked(_name)) == keccak256(abi.encodePacked("WMNT"))) {
            mockWmnt = new MOCKWMNT();
            return address(mockWmnt);
        } else if (keccak256(abi.encodePacked(_name)) == keccak256(abi.encodePacked("WETH"))) {
            mockWeth = new MOCKWETH();
            return address(mockWeth);
        } else if (keccak256(abi.encodePacked(_name)) == keccak256(abi.encodePacked("WBTC"))) {
            mockWbtc = new MOCKWBTC();
            return address(mockWbtc);
        }
        revert("Invalid token name");
    }

    function _deployMockDex() internal virtual returns (address) {
        mockDex = new MockDex();
        console.log("address public constant %s_MOCK_DEX = %s;", chainName, address(mockDex));
        return address(mockDex);
    }

    function _deployOft(address _token) internal virtual {
        elevatedminterburner = new ElevatedMinterBurner(_token, owner);
        string memory tokenTicker = IERC20Metadata(_token).symbol();
        console.log("address public constant %s_%s_ELEVATED_MINTER_BURNER = %s;", chainName, tokenTicker, address(elevatedminterburner));
        oftadapter = new OFTadapter(_token, address(elevatedminterburner), endpoint, owner, _tokenDecimals(_token));
        console.log("address public constant %s_%s_OFT_ADAPTER = %s;", chainName, tokenTicker, address(oftadapter));
        oftUsdtAdapter = address(oftadapter);
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
            requiredDVNCount: block.chainid == 5003 ? 1 : 2,
            optionalDVNCount: type(uint8).max,
            optionalDVNThreshold: 0,
            requiredDVNs: _toDynamicArray([dvn1, dvn2]),
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
            requiredDVNCount: block.chainid == 5003 ? 1 : 2,
            optionalDVNCount: type(uint8).max,
            optionalDVNThreshold: 0,
            requiredDVNs: _toDynamicArray([dvn1, dvn2]),
            optionalDVNs: new address[](0)
        });
        bytes memory encodedUln = abi.encode(uln);
        SetConfigParam[] memory params = new SetConfigParam[](2);
        params[0] = SetConfigParam({ eid: eid0, configType: RECEIVE_CONFIG_TYPE, config: encodedUln });
        params[1] = SetConfigParam({ eid: eid1, configType: RECEIVE_CONFIG_TYPE, config: encodedUln });

        ILayerZeroEndpointV2(endpoint).setConfig(_oapp, receiveLib, params);
    }

    function _setPeers() internal virtual {
        bytes32 oftPeerSrc = bytes32(uint256(uint160(address(oapp)))); // oappSrc
        bytes32 oftPeerDst = bytes32(uint256(uint160(address(oapp)))); // oappDst
        OFTadapter(oapp).setPeer(eid0, oftPeerSrc);
        OFTadapter(oapp).setPeer(eid1, oftPeerDst);

        bytes32 oftPeerSrc2 = bytes32(uint256(uint160(address(oapp2)))); // oappSrc2
        bytes32 oftPeerDst2 = bytes32(uint256(uint160(address(oapp2)))); // oappDst2
        OFTKAIAadapter(oapp2).setPeer(eid0, oftPeerSrc2);
        OFTKAIAadapter(oapp2).setPeer(eid1, oftPeerDst2);

        bytes32 oftPeerSrc3 = bytes32(uint256(uint160(address(oapp3)))); // oappSrc3
        bytes32 oftPeerDst3 = bytes32(uint256(uint160(address(oapp3)))); // oappDst3
        OFTKAIAadapter(oapp3).setPeer(eid0, oftPeerSrc3);
        OFTKAIAadapter(oapp3).setPeer(eid1, oftPeerDst3);
    }

    function _setEnforcedOptions() internal virtual {
        bytes memory options1 = OptionsBuilder.newOptions().addExecutorLzReceiveOption(80000, 0);
        bytes memory options2 = OptionsBuilder.newOptions().addExecutorLzReceiveOption(100000, 0);

        EnforcedOptionParam[] memory enforcedOptions = new EnforcedOptionParam[](2);
        enforcedOptions[0] = EnforcedOptionParam({ eid: eid0, msgType: SEND, options: options1 });
        enforcedOptions[1] = EnforcedOptionParam({ eid: eid1, msgType: SEND, options: options2 });

        MyOApp(oapp).setEnforcedOptions(enforcedOptions);
        MyOApp(oapp2).setEnforcedOptions(enforcedOptions);
        MyOApp(oapp3).setEnforcedOptions(enforcedOptions);
    }

    function _deployTokenDataStream() internal virtual {
        tokenDataStream = new TokenDataStream();
        console.log("address public constant %s_TOKEN_DATA_STREAM_IMPLEMENTATION = %s;", chainName, address(tokenDataStream));
        bytes memory data = abi.encodeWithSelector(tokenDataStream.initialize.selector);
        proxy = new ERC1967Proxy(address(tokenDataStream), data);
        tokenDataStream = TokenDataStream(address(proxy));
        console.log("address public constant %s_TOKEN_DATA_STREAM = %s;", chainName, address(tokenDataStream));
    }

    function _setTokenDataStream(address _token, address _oracle) internal virtual {
        if (address(tokenDataStream) == address(0)) revert("TokenDataStream not deployed");
        if (_token == address(0)) revert("Token address cannot be zero");
        if (_oracle == address(0)) revert("Oracle address cannot be zero");
        tokenDataStream.setTokenPriceFeed(_token, _oracle);
    }

    function _deployInterestRateModel() internal virtual {
        interestRateModel = new InterestRateModel();
        console.log("address public constant %s_INTEREST_RATE_MODEL_IMPLEMENTATION = %s;", chainName, address(interestRateModel));
        bytes memory data = abi.encodeWithSelector(interestRateModel.initialize.selector);
        proxy = new ERC1967Proxy(address(interestRateModel), data);
        interestRateModel = InterestRateModel(address(proxy));
        console.log("address public constant %s_INTEREST_RATE_MODEL = %s;", chainName, address(interestRateModel));
    }

    function _deployDeployer() internal virtual {
        lendingPoolDeployer = new LendingPoolDeployer();
        console.log("address public constant %s_LENDING_POOL_DEPLOYER = %s;", chainName, address(lendingPoolDeployer));
        lendingPoolRouterDeployer = new LendingPoolRouterDeployer();
        console.log("address public constant %s_LENDING_POOL_ROUTER_DEPLOYER = %s;", chainName, address(lendingPoolRouterDeployer));
        positionDeployer = new PositionDeployer();
        console.log("address public constant %s_POSITION_DEPLOYER = %s;", chainName, address(positionDeployer));
        proxyDeployer = new ProxyDeployer();
        console.log("address public constant %s_PROXY_DEPLOYER = %s;", chainName, address(proxyDeployer));
        sharesTokenDeployer = new SharesTokenDeployer();
        console.log("address public constant %s_SHARES_TOKEN_DEPLOYER = %s;", chainName, address(sharesTokenDeployer));
    }

    function _deployIsHealthy() internal virtual {
        isHealthy = new IsHealthy();
        console.log("address public constant %s_IS_HEALTHY_IMPLEMENTATION = %s;", chainName, address(isHealthy));
        bytes memory data = abi.encodeWithSelector(isHealthy.initialize.selector);
        proxy = new ERC1967Proxy(address(isHealthy), data);
        isHealthy = IsHealthy(address(proxy));
        console.log("address public constant %s_IS_HEALTHY = %s;", chainName, address(isHealthy));
    }

    function _deployProtocol() internal virtual {
        protocol = new Protocol();
        console.log("address public constant %s_PROTOCOL = %s;", chainName, address(protocol));
    }

    function _deployFactory() internal virtual {
        lendingPoolFactory = new LendingPoolFactory();
        console.log("address public constant %s_LENDING_POOL_FACTORY_IMPLEMENTATION = %s;", chainName, address(lendingPoolFactory));
        bytes memory data = abi.encodeWithSelector(lendingPoolFactory.initialize.selector);
        proxy = new ERC1967Proxy(address(lendingPoolFactory), data);
        lendingPoolFactory = LendingPoolFactory(address(proxy));
        console.log("address public constant %s_LENDING_POOL_FACTORY = %s;", chainName, address(lendingPoolFactory));
    }

    function _deploySupalaEmitter() internal {
        supalaEmitter = new SupalaEmitter();
        console.log("address public constant %s_SUPALA_EMITTER_IMPLEMENTATION = %s;", chainName, address(supalaEmitter));
        bytes memory data = abi.encodeWithSelector(supalaEmitter.initialize.selector);
        proxy = new ERC1967Proxy(address(supalaEmitter), data);
        supalaEmitter = SupalaEmitter(address(proxy));
        console.log("address public constant %s_SUPALA_EMITTER = %s;", chainName, address(supalaEmitter));
    }

    function _setCoreFactoryConfig() internal virtual {
        IFactory(address(lendingPoolFactory)).setIsHealthy(address(isHealthy));
        IFactory(address(lendingPoolFactory)).setLendingPoolRouterDeployer(address(lendingPoolRouterDeployer));
        IFactory(address(lendingPoolFactory)).setLendingPoolDeployer(address(lendingPoolDeployer));
        IFactory(address(lendingPoolFactory)).setProtocol(address(protocol));
        IFactory(address(lendingPoolFactory)).setPositionDeployer(address(positionDeployer));
        IFactory(address(lendingPoolFactory)).setProxyDeployer(address(proxyDeployer));
        IFactory(address(lendingPoolFactory)).setDexRouter(dexRouter);
        IFactory(address(lendingPoolFactory)).setSharesTokenDeployer(address(sharesTokenDeployer));
        IFactory(address(lendingPoolFactory)).setSupalaEmitter(address(supalaEmitter));
    }

    function _setEmittedRoles() internal {
        supalaEmitter.grantRole(DEFAULT_ADMIN_ROLE, address(lendingPoolFactory));
        supalaEmitter.grantRole(ADMIN_ROLE, address(lendingPoolFactory));
    }

    function _setSharesTokenDeployerConfig() internal {
        sharesTokenDeployer.setFactory(address(lendingPoolFactory));
    }

    function _setDeployerToFactory() internal virtual {
        lendingPoolDeployer.setFactory(address(lendingPoolFactory));
        lendingPoolRouterDeployer.setFactory(address(lendingPoolFactory));
        isHealthy.setFactory(address(lendingPoolFactory));
    }

    function _setFactoryConfig() internal virtual {
        IFactory(address(lendingPoolFactory)).setOperator(address(lendingPoolFactory), true);
        IFactory(address(lendingPoolFactory)).setTokenDataStream(address(tokenDataStream));
        IFactory(address(lendingPoolFactory)).setWrappedNative(wNative);
        IFactory(address(lendingPoolFactory)).setInterestRateModel(address(interestRateModel));
    }

    function _setFactoryMinSupplyAmount(address _token, uint256 _amount) internal virtual {
        IFactory(address(lendingPoolFactory)).setMinAmountSupplyLiquidity(_token, _amount);
    }

    function _setMockDexFactory() internal virtual {
        // Set the factory address on MockDex after proxy is created
        // This is needed because MockDex is created before the factory proxy in _getUtils()
        if (address(mockDex) != address(0) && block.chainid == 5003) {
            mockDex.setFactory(address(lendingPoolFactory));
        }
    }

    function _setInterestRateModelToFactory() internal virtual {
        interestRateModel.grantRole(OWNER_ROLE, address(lendingPoolFactory));
    }

    function _setInterestRateModelTokenReserveFactor(address _token, uint256 _reserveFactor) internal virtual {
        // interestRateModel.setTokenReserveFactor(usdt, 10e16);
        // interestRateModel.setTokenReserveFactor(wNative, 10e16);
        // interestRateModel.setTokenReserveFactor(native, 10e16);
        // interestRateModel.setTokenReserveFactor(weth, 10e16);

        interestRateModel.setTokenReserveFactor(_token, _reserveFactor);
    }

    function _configIsHealthy() internal virtual {
        IIsHealthy(address(isHealthy)).setFactory(address(lendingPoolFactory));
    }

    function _deployHelperUtils() internal virtual {
        helperUtils = new HelperUtils(address(lendingPoolFactory));
        console.log("address public constant %s_HELPER_UTILS = %s;", chainName, address(helperUtils));
    }

    function _setOftAddress() internal virtual {
        IFactory(address(lendingPoolFactory)).setOftAddress(usdt, oapp);
        IFactory(address(lendingPoolFactory)).setOftAddress(wNative, oapp2);
        IFactory(address(lendingPoolFactory)).setOftAddress(native, oapp2);
        IFactory(address(lendingPoolFactory)).setOftAddress(weth, oapp3);
    }

    function _toDynamicArray(address[2] memory fixedArray) internal view virtual returns (address[] memory) {
        if (block.chainid == 5003) {
            address[] memory dynamicArray = new address[](1);
            dynamicArray[0] = fixedArray[0];
            return dynamicArray;
        } else {
            address[] memory dynamicArray = new address[](2);
            dynamicArray[0] = fixedArray[0];
            dynamicArray[1] = fixedArray[1];
            return dynamicArray;
        }
    }

    function _tokenDecimals(address _token) internal view virtual returns (uint8) {
        return IERC20Metadata(_token).decimals();
    }
}
