// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

// ======================= LIB =======================
import { Test, console } from "forge-std/Test.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
// ======================= Core Source =======================
import { LendingPoolFactory } from "../src/LendingPoolFactory.sol";
import { IsHealthy } from "../src/IsHealthy.sol";
import { LendingPoolDeployer } from "../src/LendingPoolDeployer.sol";
import { Protocol } from "../src/Protocol.sol";
import { Oracle } from "../src/Oracle.sol";
import { OFTKAIAadapter } from "../src/layerzero/OFTKAIAAdapter.sol";
import { OFTUSDTadapter } from "../src/layerzero/OFTUSDTAdapter.sol";
import { ElevatedMinterBurner } from "../src/layerzero/ElevatedMinterBurner.sol";
import { HelperUtils } from "../src/HelperUtils.sol";
import { PositionDeployer } from "../src/PositionDeployer.sol";
import { LendingPoolRouterDeployer } from "../src/LendingPoolRouterDeployer.sol";
import { TokenDataStream } from "../src/TokenDataStream.sol";
import { InterestRateModel } from "../src/InterestRateModel.sol";
import { ProxyDeployer } from "../src/ProxyDeployer.sol";
import { SharesTokenDeployer } from "../src/SharesTokenDeployer.sol";
import { SupalaEmitter } from "../src/SupalaEmitter.sol";
// ======================= Helper =======================
import { Helper } from "../script/DevTools/Helper.sol";
import { BorrowParams, RepayParams } from "../src/lib/LendingPoolHook.sol";
import { LendingPoolFactoryHook } from "../src/lib/LendingPoolFactoryHook.sol";
// ======================= MockDex =======================
import { MockDex } from "../src/MockDex/MockDex.sol";
// ======================= MockToken =======================
import { MOCKUSDT } from "../src/MockToken/MOCKUSDT.sol";
import { MOCKWKAIA } from "../src/MockToken/MOCKWKAIA.sol";
import { MOCKWETH } from "../src/MockToken/MOCKWETH.sol";
// ======================= LayerZero =======================
import { MyOApp } from "../src/layerzero/MyOApp.sol";
import { ILayerZeroEndpointV2 } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import { SetConfigParam } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";
import { UlnConfig } from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";
import { ExecutorConfig } from "@layerzerolabs/lz-evm-messagelib-v2/contracts/SendLibBase.sol";
import { EnforcedOptionParam } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";
import { OptionsBuilder } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";
import { MessagingFee } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import { SendParam } from "@layerzerolabs/oft-evm/contracts/interfaces/IOFT.sol";
// ======================= Interfaces =======================
import { ILendingPool } from "../src/interfaces/ILendingPool.sol";
import { ILPRouter } from "../src/interfaces/ILPRouter.sol";
import { IFactory } from "../src/interfaces/IFactory.sol";
import { IIsHealthy } from "../src/interfaces/IIsHealthy.sol";
import { ITokenDataStream } from "../src/interfaces/ITokenDataStream.sol";
import { SwapHook } from "../src/lib/SwapHook.sol";
import { Orakl } from "../src/MockOrakl/Orakl.sol";

// RUN
// forge test --match-contract SupalaTest -vvv
contract SupalaTest is Test, Helper {
    using OptionsBuilder for bytes;

    IsHealthy public isHealthy;
    LendingPoolRouterDeployer public lendingPoolRouterDeployer;
    LendingPoolDeployer public lendingPoolDeployer;
    Protocol public protocol;
    PositionDeployer public positionDeployer;
    LendingPoolFactory public lendingPoolFactory;
    LendingPoolFactory public newImplementation;
    Oracle public oracle;
    OFTUSDTadapter public oftusdtadapter;
    OFTKAIAadapter public oftkaiaadapter;
    ElevatedMinterBurner public elevatedminterburner;
    HelperUtils public helperUtils;
    ERC1967Proxy public proxy;
    ProxyDeployer public proxyDeployer;
    MOCKUSDT public mockUsdt;
    MOCKWKAIA public mockWkaia;
    MOCKWETH public mockWeth;
    MockDex public mockDex;
    Orakl public mockOrakl;
    TokenDataStream public tokenDataStream;
    InterestRateModel public interestRateModel;
    SharesTokenDeployer public sharesTokenDeployer;
    SupalaEmitter public supalaEmitter;

    address public lendingPool;
    address public lendingPool2;
    address public lendingPool3;

    address public owner = makeAddr("owner");
    address public alice = makeAddr("alice");

    uint256 supplyLiquidity;
    uint256 withdrawLiquidity;
    uint256 supplyCollateral;
    uint256 withdrawCollateral;
    uint256 borrowAmount;
    uint256 repayDebt;

    uint256 amountStartSupply1 = 1_000e6;
    uint256 amountStartSupply2 = 1_000 ether;
    uint256 amountStartSupply3 = 1_000e6;

    function setUp() public {
        // vm.createSelectFork(vm.rpcUrl("kaia_mainnet"));
        // vm.createSelectFork(vm.rpcUrl("base_mainnet"));
        vm.createSelectFork(vm.rpcUrl("kaia_testnet"));
        // vm.createSelectFork(vm.rpcUrl("moonbeam_mainnet"));
        vm.startPrank(owner);

        _getUtils();
        deal(usdt, alice, 100_000e6);
        deal(wNative, alice, 100_000 ether);
        vm.deal(alice, 100_000 ether);

        deal(usdt, owner, 100_000e6);
        deal(wNative, owner, 100_000 ether);
        vm.deal(owner, 100_000 ether);
        // *************** layerzero ***************

        _deployOft();
        _setLibraries();
        _setSendConfig();
        _setReceiveConfig();
        _setPeers();
        _setEnforcedOptions();

        // *****************************************

        _deployTokenDataStream();
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
        _setMockDexFactory(); // Set factory address on MockDex after proxy is created
        _configIsHealthy();
        _setInterestRateModelToFactory();
        _setInterestRateModelTokenReserveFactor();
        _createLendingPool();
        helperUtils = new HelperUtils(address(lendingPoolFactory));
        _setOftAddress();

        vm.stopPrank();
    }

    function _deployInterestRateModel() internal {
        interestRateModel = new InterestRateModel();
        bytes memory data = abi.encodeWithSelector(interestRateModel.initialize.selector);
        proxy = new ERC1967Proxy(address(interestRateModel), data);
        interestRateModel = InterestRateModel(address(proxy));
    }

    function _getUtils() internal override {
        super._getUtils();
        usdt = _deployMockToken("USDT");
        wNative = _deployMockToken("WKAIA");
        dexRouter = _deployMockDex();
    }

    function _deployMockToken(string memory _name) internal returns (address) {
        if (keccak256(abi.encodePacked(_name)) == keccak256(abi.encodePacked("USDT"))) {
            mockUsdt = new MOCKUSDT();
            return address(mockUsdt);
        } else if (keccak256(abi.encodePacked(_name)) == keccak256(abi.encodePacked("WKAIA"))) {
            mockWkaia = new MOCKWKAIA();
            return address(mockWkaia);
        } else if (keccak256(abi.encodePacked(_name)) == keccak256(abi.encodePacked("WETH"))) {
            mockWeth = new MOCKWETH();
            return address(mockWeth);
        }
        revert("Invalid token name");
    }

    function _deployMockDex() internal returns (address) {
        mockDex = new MockDex();
        return address(mockDex);
    }

    function _deployOft() internal {
        elevatedminterburner = new ElevatedMinterBurner(usdt, owner);
        oftusdtadapter = new OFTUSDTadapter(usdt, address(elevatedminterburner), endpoint, owner);
        oftUsdtAdapter = address(oftusdtadapter);
        oapp = address(oftusdtadapter);
        elevatedminterburner.setOperator(oapp, true);

        elevatedminterburner = new ElevatedMinterBurner(wNative, owner);
        oftkaiaadapter = new OFTKAIAadapter(wNative, address(elevatedminterburner), endpoint, owner);
        oftNativeAdapter = address(oftkaiaadapter);
        oapp2 = address(oftkaiaadapter);
        elevatedminterburner.setOperator(oapp2, true);

        elevatedminterburner = new ElevatedMinterBurner(wNative, owner);
        oftkaiaadapter = new OFTKAIAadapter(wNative, address(elevatedminterburner), endpoint, owner);
        oftNativeOriAdapter = address(oftkaiaadapter);
        oapp3 = address(oftkaiaadapter);
        elevatedminterburner.setOperator(oapp3, true);
    }

    function _setLibraries() internal {
        ILayerZeroEndpointV2(endpoint).setSendLibrary(oapp, eid0, sendLib);
        ILayerZeroEndpointV2(endpoint).setSendLibrary(oapp, eid1, sendLib);
        ILayerZeroEndpointV2(endpoint).setReceiveLibrary(oapp, srcEid, receiveLib, gracePeriod);

        ILayerZeroEndpointV2(endpoint).setSendLibrary(oapp2, eid0, sendLib);
        ILayerZeroEndpointV2(endpoint).setSendLibrary(oapp2, eid1, sendLib);
        ILayerZeroEndpointV2(endpoint).setReceiveLibrary(oapp2, srcEid, receiveLib, gracePeriod);

        ILayerZeroEndpointV2(endpoint).setSendLibrary(oapp3, eid0, sendLib);
        ILayerZeroEndpointV2(endpoint).setSendLibrary(oapp3, eid1, sendLib);
        ILayerZeroEndpointV2(endpoint).setReceiveLibrary(oapp3, srcEid, receiveLib, gracePeriod);
    }

    function _setSendConfig() internal {
        UlnConfig memory uln = UlnConfig({
            confirmations: 15,
            requiredDVNCount: block.chainid == 1001 ? 1 : 2,
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

        ILayerZeroEndpointV2(endpoint).setConfig(oapp, sendLib, params);
        ILayerZeroEndpointV2(endpoint).setConfig(oapp2, sendLib, params);
        ILayerZeroEndpointV2(endpoint).setConfig(oapp3, sendLib, params);
    }

    function _setReceiveConfig() internal {
        UlnConfig memory uln = UlnConfig({
            confirmations: 15,
            requiredDVNCount: block.chainid == 1001 ? 1 : 2,
            optionalDVNCount: type(uint8).max,
            optionalDVNThreshold: 0,
            requiredDVNs: _toDynamicArray([dvn1, dvn2]),
            optionalDVNs: new address[](0)
        });
        bytes memory encodedUln = abi.encode(uln);
        SetConfigParam[] memory params = new SetConfigParam[](2);
        params[0] = SetConfigParam({ eid: eid0, configType: RECEIVE_CONFIG_TYPE, config: encodedUln });
        params[1] = SetConfigParam({ eid: eid1, configType: RECEIVE_CONFIG_TYPE, config: encodedUln });

        ILayerZeroEndpointV2(endpoint).setConfig(oapp, receiveLib, params);
        ILayerZeroEndpointV2(endpoint).setConfig(oapp2, receiveLib, params);
        ILayerZeroEndpointV2(endpoint).setConfig(oapp3, receiveLib, params);
    }

    function _setPeers() internal {
        bytes32 oftPeerSrc = bytes32(uint256(uint160(address(oapp)))); // oappSrc
        bytes32 oftPeerDst = bytes32(uint256(uint160(address(oapp)))); // oappDst
        OFTUSDTadapter(oapp).setPeer(eid0, oftPeerSrc);
        OFTUSDTadapter(oapp).setPeer(eid1, oftPeerDst);

        bytes32 oftPeerSrc2 = bytes32(uint256(uint160(address(oapp2)))); // oappSrc2
        bytes32 oftPeerDst2 = bytes32(uint256(uint160(address(oapp2)))); // oappDst2
        OFTKAIAadapter(oapp2).setPeer(eid0, oftPeerSrc2);
        OFTKAIAadapter(oapp2).setPeer(eid1, oftPeerDst2);

        bytes32 oftPeerSrc3 = bytes32(uint256(uint160(address(oapp3)))); // oappSrc3
        bytes32 oftPeerDst3 = bytes32(uint256(uint160(address(oapp3)))); // oappDst3
        OFTKAIAadapter(oapp3).setPeer(eid0, oftPeerSrc3);
        OFTKAIAadapter(oapp3).setPeer(eid1, oftPeerDst3);
    }

    function _setEnforcedOptions() internal {
        uint16 send = 1;
        bytes memory options1 = OptionsBuilder.newOptions().addExecutorLzReceiveOption(80000, 0);
        bytes memory options2 = OptionsBuilder.newOptions().addExecutorLzReceiveOption(100000, 0);

        EnforcedOptionParam[] memory enforcedOptions = new EnforcedOptionParam[](2);
        enforcedOptions[0] = EnforcedOptionParam({ eid: eid0, msgType: send, options: options1 });
        enforcedOptions[1] = EnforcedOptionParam({ eid: eid1, msgType: send, options: options2 });

        MyOApp(oapp).setEnforcedOptions(enforcedOptions);
        MyOApp(oapp2).setEnforcedOptions(enforcedOptions);
        MyOApp(oapp3).setEnforcedOptions(enforcedOptions);
    }

    function _deployTokenDataStream() internal {
        tokenDataStream = new TokenDataStream();
        bytes memory data = abi.encodeWithSelector(tokenDataStream.initialize.selector);
        proxy = new ERC1967Proxy(address(tokenDataStream), data);
        tokenDataStream = TokenDataStream(address(proxy));
        tokenDataStream.setTokenPriceFeed(usdt, USDT_USD);
        tokenDataStream.setTokenPriceFeed(wNative, NATIVE_USDT);
        tokenDataStream.setTokenPriceFeed(native, NATIVE_USDT);
    }

    function _deployDeployer() internal {
        lendingPoolDeployer = new LendingPoolDeployer();
        lendingPoolRouterDeployer = new LendingPoolRouterDeployer();
        positionDeployer = new PositionDeployer();
        proxyDeployer = new ProxyDeployer();
        sharesTokenDeployer = new SharesTokenDeployer();
    }

    function _deployIsHealthy() internal {
        isHealthy = new IsHealthy();
        bytes memory data = abi.encodeWithSelector(isHealthy.initialize.selector);
        proxy = new ERC1967Proxy(address(isHealthy), data);
        isHealthy = IsHealthy(address(proxy));
    }

    function _deploySupalaEmitter() internal {
        supalaEmitter = new SupalaEmitter();
        bytes memory data = abi.encodeWithSelector(supalaEmitter.initialize.selector);
        proxy = new ERC1967Proxy(address(supalaEmitter), data);
        supalaEmitter = SupalaEmitter(address(proxy));
    }

    function _deployProtocol() internal {
        protocol = new Protocol();
    }

    function _deployFactory() internal {
        lendingPoolFactory = new LendingPoolFactory();
        bytes memory data = abi.encodeWithSelector(lendingPoolFactory.initialize.selector);
        proxy = new ERC1967Proxy(address(lendingPoolFactory), data);
        lendingPoolFactory = LendingPoolFactory(address(proxy));
    }

    function _setCoreFactoryConfig() internal {
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

    function _setSharesTokenDeployerConfig() internal {
        sharesTokenDeployer.setFactory(address(lendingPoolFactory));
    }

    function _setDeployerToFactory() internal {
        lendingPoolDeployer.setFactory(address(lendingPoolFactory));
        lendingPoolRouterDeployer.setFactory(address(lendingPoolFactory));
        isHealthy.setFactory(address(lendingPoolFactory));
    }

    function _setEmittedRoles() internal {
        supalaEmitter.grantRole(DEFAULT_ADMIN_ROLE, address(lendingPoolFactory));
        supalaEmitter.grantRole(ADMIN_ROLE, address(lendingPoolFactory));
    }

    function _setFactoryConfig() internal {
        IFactory(address(lendingPoolFactory)).setOperator(address(lendingPoolFactory), true);
        IFactory(address(lendingPoolFactory)).setTokenDataStream(address(tokenDataStream));
        IFactory(address(lendingPoolFactory)).setWrappedNative(wNative);
        IFactory(address(lendingPoolFactory)).setInterestRateModel(address(interestRateModel));

        IFactory(address(lendingPoolFactory)).setMinAmountSupplyLiquidity(usdt, 1e6);
        IFactory(address(lendingPoolFactory)).setMinAmountSupplyLiquidity(wNative, 0.1 ether);
        IFactory(address(lendingPoolFactory)).setMinAmountSupplyLiquidity(native, 0.1 ether);
    }

    function _setMockDexFactory() internal {
        // Set the factory address on MockDex after proxy is created
        // This is needed because MockDex is created before the factory proxy in _getUtils()
        if (address(mockDex) != address(0) && block.chainid == 1001) {
            mockDex.setFactory(address(lendingPoolFactory));
        }
    }

    function _setInterestRateModelToFactory() internal {
        interestRateModel.grantRole(OWNER_ROLE, address(lendingPoolFactory));
    }

    function _setInterestRateModelTokenReserveFactor() internal {
        interestRateModel.setTokenReserveFactor(usdt, 10e16);
        interestRateModel.setTokenReserveFactor(wNative, 10e16);
        interestRateModel.setTokenReserveFactor(native, 10e16);
    }

    function _configIsHealthy() internal {
        IIsHealthy(address(isHealthy)).setFactory(address(lendingPoolFactory));
    }

    function _createLendingPool() internal {
        LendingPoolFactoryHook.LendingPoolParams memory lendingPoolParams1 = LendingPoolFactoryHook.LendingPoolParams({
            collateralToken: wNative,
            borrowToken: usdt,
            ltv: 60e16,
            supplyLiquidity: amountStartSupply1,
            baseRate: 0.05e16,
            rateAtOptimal: 80e16,
            optimalUtilization: 60e16,
            maxUtilization: 60e16,
            maxRate: 20e16,
            liquidationThreshold: 85e16,
            liquidationBonus: 5e16
        });

        IERC20(usdt).approve(address(lendingPoolFactory), amountStartSupply1);
        lendingPool = IFactory(address(lendingPoolFactory)).createLendingPool(lendingPoolParams1);

        LendingPoolFactoryHook.LendingPoolParams memory lendingPoolParams2 = LendingPoolFactoryHook.LendingPoolParams({
            collateralToken: usdt,
            borrowToken: wNative,
            ltv: 8e17,
            supplyLiquidity: amountStartSupply2,
            baseRate: 0.05e16,
            rateAtOptimal: 80e16,
            optimalUtilization: 60e16,
            maxUtilization: 6e16,
            maxRate: 20e16,
            liquidationThreshold: 85e16,
            liquidationBonus: 5e16
        });
        IERC20(wNative).approve(address(lendingPoolFactory), amountStartSupply2);
        lendingPool2 = IFactory(address(lendingPoolFactory)).createLendingPool(lendingPoolParams2);

        LendingPoolFactoryHook.LendingPoolParams memory lendingPoolParams3 = LendingPoolFactoryHook.LendingPoolParams({
            collateralToken: native,
            borrowToken: usdt,
            ltv: 8e17,
            supplyLiquidity: amountStartSupply3,
            baseRate: 0.05e16,
            rateAtOptimal: 80e16,
            optimalUtilization: 60e16,
            maxUtilization: 6e16,
            maxRate: 20e16,
            liquidationThreshold: 85e16,
            liquidationBonus: 5e16
        });
        IERC20(usdt).approve(address(lendingPoolFactory), amountStartSupply3);
        lendingPool3 = IFactory(address(lendingPoolFactory)).createLendingPool(lendingPoolParams3);
    }

    function _deployHelperUtils() internal {
        helperUtils = new HelperUtils(address(lendingPoolFactory));
    }

    function _setOftAddress() internal {
        IFactory(address(lendingPoolFactory)).setOftAddress(wNative, oftNativeAdapter);
        IFactory(address(lendingPoolFactory)).setOftAddress(usdt, oftUsdtAdapter);
        IFactory(address(lendingPoolFactory)).setOftAddress(native, oftNativeAdapter);
    }

    // RUN
    // forge test --match-test test_factory -vvv
    function test_factory() public view {
        address router = ILendingPool(lendingPool).router();
        assertEq(ILPRouter(router).lendingPool(), address(lendingPool));
        assertEq(ILPRouter(router).factory(), address(lendingPoolFactory));
        assertEq(ILPRouter(router).collateralToken(), wNative);
        assertEq(ILPRouter(router).borrowToken(), usdt);
        assertEq(ILPRouter(router).ltv(), 60e16);
    }

    // RUN
    // forge test --match-test test_oftaddress -vvv
    function test_oftaddress() public view {
        assertEq(IFactory(address(lendingPoolFactory)).oftAddress(wNative), oftNativeAdapter);
        assertEq(IFactory(address(lendingPoolFactory)).oftAddress(usdt), oftUsdtAdapter);
    }

    // RUN
    // forge test --match-test test_roles -vvv
    function test_roles() public view {
        console.log("DEFAULT_ADMIN_ROLE:");
        console.logBytes32(lendingPoolFactory.DEFAULT_ADMIN_ROLE());

        console.log("PAUSER_ROLE:");
        console.logBytes32(lendingPoolFactory.PAUSER_ROLE());

        console.log("UPGRADER_ROLE:");
        console.logBytes32(lendingPoolFactory.UPGRADER_ROLE());

        console.log("OWNER_ROLE:");
        console.logBytes32(lendingPoolFactory.OWNER_ROLE());

        console.log("MINTER_ROLE (keccak256):");
        console.logBytes32(keccak256("MINTER_ROLE"));

        console.log("ADMIN_ROLE (keccak256):");
        console.logBytes32(keccak256("ADMIN_ROLE"));
    }

    // RUN
    // forge test --match-test test_checkorakl -vvv
    function test_checkorakl() public view {
        address _tokenDataStream = IFactory(address(lendingPoolFactory)).tokenDataStream();
        (, uint256 price,,,) = TokenDataStream(_tokenDataStream).latestRoundData(address(usdt));
        console.log("usdt/USD price", price);
        (, uint256 price2,,,) = TokenDataStream(_tokenDataStream).latestRoundData(wNative);
        console.log("wNative/USD price", price2);
        (, uint256 price3,,,) = TokenDataStream(_tokenDataStream).latestRoundData(native);
        console.log("native/USD price", price3);
    }

    // RUN
    // forge test --match-test test_supply_liquidity -vvv
    function test_supply_liquidity() public {
        vm.startPrank(alice);

        // Supply 1000 usdt as liquidity
        IERC20(usdt).approve(lendingPool, 1_000e6);
        ILendingPool(lendingPool).supplyLiquidity(alice, 1_000e6);

        // Supply 1000 wNative as liquidity
        IERC20(wNative).approve(lendingPool2, 1_000 ether);
        ILendingPool(lendingPool2).supplyLiquidity(alice, 1_000 ether);

        // Supply 1000 usdt as liquidity (borrow token for lendingPool3)
        IERC20(usdt).approve(lendingPool3, 1_000e6);
        ILendingPool(lendingPool3).supplyLiquidity(alice, 1_000e6);
        vm.stopPrank();

        address router = ILendingPool(lendingPool).router();
        address sharesToken = ILPRouter(router).sharesToken();
        console.log("address sharesToken", sharesToken);
        console.log("IERC20Metadata(sharesToken).decimals()", IERC20Metadata(sharesToken).decimals());
        console.log("IERC20Metadata(sharesToken).symbol()", IERC20Metadata(sharesToken).symbol());
        console.log("IERC20Metadata(sharesToken).name()", IERC20Metadata(sharesToken).name());
        console.log("IERC20(sharesToken).balanceOf(alice)", IERC20(sharesToken).balanceOf(alice));
        // Check balances
        assertEq(IERC20(usdt).balanceOf(lendingPool), 1_000e6 + amountStartSupply1);
        assertEq(IERC20(wNative).balanceOf(lendingPool2), 1_000 ether + amountStartSupply2);
        assertEq(IERC20(usdt).balanceOf(lendingPool3), 1_000e6 + amountStartSupply3);
    }

    // RUN
    // forge test --match-test test_withdraw_liquidity -vvv
    function test_withdraw_liquidity() public {
        test_supply_liquidity();
        vm.startPrank(alice);

        // Get shares token balance (18 decimals) to withdraw
        address sharesToken1 = _sharesToken(lendingPool);
        address sharesToken2 = _sharesToken(lendingPool2);
        address sharesToken3 = _sharesToken(lendingPool3);

        uint256 aliceShares1 = IERC20(sharesToken1).balanceOf(alice);
        uint256 aliceShares2 = IERC20(sharesToken2).balanceOf(alice);
        uint256 aliceShares3 = IERC20(sharesToken3).balanceOf(alice);

        ILendingPool(lendingPool).withdrawLiquidity(aliceShares1);
        ILendingPool(lendingPool2).withdrawLiquidity(aliceShares2);
        ILendingPool(lendingPool3).withdrawLiquidity(aliceShares3);
        vm.stopPrank();

        assertEq(IERC20(usdt).balanceOf(lendingPool), 0 + amountStartSupply1);
        assertEq(IERC20(wNative).balanceOf(lendingPool2), 0 + amountStartSupply2);
        assertEq(IERC20(usdt).balanceOf(lendingPool3), 0 + amountStartSupply3);
    }

    // RUN
    // forge test --match-test test_supply_collateral -vvv
    function test_supply_collateral() public {
        vm.startPrank(alice);

        IERC20(wNative).approve(lendingPool, 1000 ether);
        ILendingPool(lendingPool).supplyCollateral(alice, 1000 ether);

        IERC20(usdt).approve(lendingPool2, 1_000e6);
        ILendingPool(lendingPool2).supplyCollateral(alice, 1_000e6);

        ILendingPool(lendingPool3).supplyCollateral{ value: 1_000 ether }(alice, 1_000 ether);
        vm.stopPrank();

        assertEq(IERC20(wNative).balanceOf(_addressPosition(lendingPool, alice)), 1000 ether);
        assertEq(IERC20(usdt).balanceOf(_addressPosition(lendingPool2, alice)), 1_000e6);
        assertEq(IERC20(wNative).balanceOf(_addressPosition(lendingPool3, alice)), 1000 ether);
    }

    // RUN
    // forge test --match-test test_withdraw_collateral -vvv
    function test_withdraw_collateral() public {
        test_supply_collateral();
        vm.startPrank(alice);
        ILendingPool(lendingPool).withdrawCollateral(1_000 ether);
        ILendingPool(lendingPool2).withdrawCollateral(1_000e6);
        ILendingPool(lendingPool3).withdrawCollateral(1_000 ether);
        vm.stopPrank();

        assertEq(IERC20(wNative).balanceOf(_addressPosition(lendingPool, alice)), 0);
        assertEq(IERC20(usdt).balanceOf(_addressPosition(lendingPool2, alice)), 0);
        assertEq(IERC20(wNative).balanceOf(_addressPosition(lendingPool3, alice)), 0);
    }

    // RUN
    // forge test --match-test test_borrow_debt -vvv
    function test_borrow_debt() public {
        test_supply_liquidity();
        test_supply_collateral();

        vm.startPrank(alice);
        ILendingPool(lendingPool).borrowDebt(10e6);
        ILendingPool(lendingPool).borrowDebt(10e6);

        ILendingPool(lendingPool2).borrowDebt(0.1 ether);
        ILendingPool(lendingPool2).borrowDebt(0.1 ether);

        ILendingPool(lendingPool3).borrowDebt(10e6);
        ILendingPool(lendingPool3).borrowDebt(10e6);
        vm.stopPrank();

        assertEq(ILPRouter(_router(lendingPool)).userBorrowShares(alice), 2 * 10e6);
        assertEq(ILPRouter(_router(lendingPool)).totalBorrowAssets(), 2 * 10e6);
        assertEq(ILPRouter(_router(lendingPool)).totalBorrowShares(), 2 * 10e6);
        assertEq(ILPRouter(_router(lendingPool2)).userBorrowShares(alice), 2 * 0.1 ether);
        assertEq(ILPRouter(_router(lendingPool2)).totalBorrowAssets(), 2 * 0.1 ether);
        assertEq(ILPRouter(_router(lendingPool2)).totalBorrowShares(), 2 * 0.1 ether);
        assertEq(ILPRouter(_router(lendingPool3)).userBorrowShares(alice), 2 * 10e6);
        assertEq(ILPRouter(_router(lendingPool3)).totalBorrowAssets(), 2 * 10e6);
        assertEq(ILPRouter(_router(lendingPool3)).totalBorrowShares(), 2 * 10e6);
    }

    // RUN
    // forge test --match-test test_repay_debt -vvv
    function test_repay_debt() public {
        test_borrow_debt();

        vm.startPrank(alice);
        IERC20(usdt).approve(lendingPool, 10e6);
        ILendingPool(lendingPool)
            .repayWithSelectedToken(RepayParams({ user: alice, token: usdt, shares: 10e6, amountOutMinimum: 0, fromPosition: false, fee: 1000 }));
        IERC20(usdt).approve(lendingPool, 10e6);
        ILendingPool(lendingPool)
            .repayWithSelectedToken(RepayParams({ user: alice, token: usdt, shares: 10e6, amountOutMinimum: 500, fromPosition: false, fee: 1000 }));
        // For wNative repayment, send native native which gets auto-wrapped
        IERC20(wNative).approve(lendingPool2, 0.1 ether);
        ILendingPool(lendingPool2)
            .repayWithSelectedToken(
                RepayParams({ user: alice, token: wNative, shares: 0.1 ether, amountOutMinimum: 500, fromPosition: false, fee: 1000 })
            );
        IERC20(wNative).approve(lendingPool2, 0.1 ether);
        ILendingPool(lendingPool2)
            .repayWithSelectedToken(
                RepayParams({ user: alice, token: wNative, shares: 0.1 ether, amountOutMinimum: 500, fromPosition: false, fee: 1000 })
            );

        IERC20(usdt).approve(lendingPool3, 10e6);
        ILendingPool(lendingPool3)
            .repayWithSelectedToken(RepayParams({ user: alice, token: usdt, shares: 10e6, amountOutMinimum: 500, fromPosition: false, fee: 1000 }));
        IERC20(usdt).approve(lendingPool3, 10e6);
        ILendingPool(lendingPool3)
            .repayWithSelectedToken(RepayParams({ user: alice, token: usdt, shares: 10e6, amountOutMinimum: 500, fromPosition: false, fee: 1000 }));
        vm.stopPrank();

        assertEq(ILPRouter(_router(lendingPool)).userBorrowShares(alice), 0);
        assertEq(ILPRouter(_router(lendingPool2)).userBorrowShares(alice), 0);
        assertEq(ILPRouter(_router(lendingPool3)).userBorrowShares(alice), 0);
        assertEq(ILPRouter(_router(lendingPool)).totalBorrowAssets(), 0);
        assertEq(ILPRouter(_router(lendingPool2)).totalBorrowAssets(), 0);
        assertEq(ILPRouter(_router(lendingPool3)).totalBorrowAssets(), 0);
        assertEq(ILPRouter(_router(lendingPool)).totalBorrowShares(), 0);
        assertEq(ILPRouter(_router(lendingPool2)).totalBorrowShares(), 0);
        assertEq(ILPRouter(_router(lendingPool3)).totalBorrowShares(), 0);
    }

    // RUN
    // forge test --match-test test_borrow_crosschain -vvv --match-contract SupalaTest
    function test_borrow_crosschain() public {
        test_supply_liquidity();
        test_supply_collateral();

        // Provide enough ETH for LayerZero cross-chain fees
        vm.deal(alice, 10 ether);

        vm.startPrank(alice);

        SendParam memory sendParam = SendParam({
            dstEid: eid1, to: bytes32(uint256(uint160(alice))), amountLD: 10e6, minAmountLD: 10e6, extraOptions: "", composeMsg: "", oftCmd: ""
        });
        MessagingFee memory fee = MessagingFee({ nativeFee: 0, lzTokenFee: 0 });
        BorrowParams memory params = BorrowParams({ sendParam: sendParam, fee: fee, amount: 10e6, chainId: eid1, addExecutorLzReceiveOption: 0 });
        (uint256 nativeFee, uint256 lzTokenFee) = helperUtils.getFee(params, lendingPool, false);
        fee = MessagingFee({ nativeFee: nativeFee, lzTokenFee: lzTokenFee });
        params.fee = fee; // Update params.fee with actual fee
        console.log("nativeFee", nativeFee);
        console.log("lzTokenFee", lzTokenFee);
        console.log("alice native balance", alice.balance);
        ILendingPool(lendingPool).borrowDebtCrossChain{ value: nativeFee }(params);

        vm.deal(alice, 15 ether);

        sendParam = SendParam({
            dstEid: eid1, to: bytes32(uint256(uint160(alice))), amountLD: 10e6, minAmountLD: 10e6, extraOptions: "", composeMsg: "", oftCmd: ""
        });
        fee = MessagingFee({ nativeFee: 0, lzTokenFee: 0 });
        params = BorrowParams({ sendParam: sendParam, fee: fee, amount: 10e6, chainId: eid1, addExecutorLzReceiveOption: 0 });
        (nativeFee, lzTokenFee) = helperUtils.getFee(params, lendingPool, false);
        fee = MessagingFee({ nativeFee: nativeFee, lzTokenFee: lzTokenFee });
        params.fee = fee; // Update params.fee with actual fee
        console.log("nativeFee", nativeFee);
        console.log("lzTokenFee", lzTokenFee);
        console.log("alice native balance", alice.balance);
        ILendingPool(lendingPool).borrowDebtCrossChain{ value: nativeFee }(params);
        vm.stopPrank();

        assertEq(ILPRouter(_router(lendingPool)).userBorrowShares(alice), 2 * 10e6);
        assertEq(ILPRouter(_router(lendingPool)).totalBorrowAssets(), 2 * 10e6);
        assertEq(ILPRouter(_router(lendingPool)).totalBorrowShares(), 2 * 10e6);
    }

    // RUN
    // forge test --match-test test_swap_collateral -vvv --match-contract SupalaTest
    function test_swap_collateral() public {
        test_supply_collateral();
        console.log("wNative balance before", IERC20(wNative).balanceOf(_addressPosition(lendingPool2, alice)));

        vm.startPrank(alice);
        ILendingPool(lendingPool2).swapTokenByPosition(SwapHook.SwapParams(usdt, wNative, 100e6, 100, 1000));
        vm.stopPrank();

        console.log("wNative balance after", IERC20(wNative).balanceOf(_addressPosition(lendingPool2, alice)));
    }

    // RUN
    // forge test --match-test test_comprehensive_collateral_swap_repay -vvv
    function test_comprehensive_collateral_swap_repay() public {
        // Step 1: Supply liquidity to enable borrowing
        test_supply_liquidity();

        // Step 2: Supply collateral
        test_supply_collateral();

        // Step 3: Borrow debt
        vm.startPrank(alice);
        ILendingPool(lendingPool).borrowDebt(10e6);
        vm.stopPrank();

        // Verify initial state
        assertEq(ILPRouter(_router(lendingPool)).userBorrowShares(alice), 10e6);
        assertEq(ILPRouter(_router(lendingPool)).totalBorrowAssets(), 10e6);

        // Get position address
        address position = _addressPosition(lendingPool, alice);

        vm.startPrank(alice);
        console.log("Initial wNative in position:", IERC20(wNative).balanceOf(position));
        console.log("Initial usdt in position:", IERC20(usdt).balanceOf(position));
        ILendingPool(lendingPool).swapTokenByPosition(SwapHook.SwapParams(wNative, usdt, 100 ether, 10000, 1000));
        console.log("Final wNative in position:", IERC20(wNative).balanceOf(position));
        console.log("Final usdt in position:", IERC20(usdt).balanceOf(position));
        vm.stopPrank();

        vm.startPrank(alice);
        console.log("Before second swap - wNative:", IERC20(wNative).balanceOf(position));
        console.log("Before second swap - usdt:", IERC20(usdt).balanceOf(position));
        ILendingPool(lendingPool).swapTokenByPosition(SwapHook.SwapParams(usdt, wNative, 1e6, 10000, 1000));
        console.log("After second swap - wNative:", IERC20(wNative).balanceOf(position));
        console.log("After second swap - usdt:", IERC20(usdt).balanceOf(position));
        vm.stopPrank();

        vm.startPrank(alice);
        console.log("Before repayment - wNative:", IERC20(wNative).balanceOf(position));
        console.log("Before repayment - usdt:", IERC20(usdt).balanceOf(position));
        IERC20(usdt).approve(lendingPool, 5e6);
        ILendingPool(lendingPool)
            .repayWithSelectedToken(RepayParams({ user: alice, token: usdt, shares: 5e6, amountOutMinimum: 500, fromPosition: false, fee: 1000 }));
        console.log("After repayment - wNative:", IERC20(wNative).balanceOf(position));
        console.log("After repayment - usdt:", IERC20(usdt).balanceOf(position));
        vm.stopPrank();

        assertLt(ILPRouter(_router(lendingPool)).userBorrowShares(alice), 50e6);
        assertLt(ILPRouter(_router(lendingPool)).totalBorrowAssets(), 50e6);

        console.log("Remaining borrow shares:", ILPRouter(_router(lendingPool)).userBorrowShares(alice));
        console.log("Remaining total borrow assets:", ILPRouter(_router(lendingPool)).totalBorrowAssets());
    }

    // RUN
    // forge test --match-test test_repay_with_collateral -vvv
    function test_repay_with_collateral() public {
        // Setup: Supply liquidity, collateral, and borrow
        test_supply_liquidity();
        test_supply_collateral();

        vm.startPrank(alice);
        ILendingPool(lendingPool).borrowDebt(20e6);
        vm.stopPrank();

        address position = _addressPosition(lendingPool, alice);
        vm.startPrank(alice);
        console.log("Initial wNative in position:", IERC20(wNative).balanceOf(position));
        console.log("Initial usdt in position:", IERC20(usdt).balanceOf(position));
        console.log("Initial borrow shares:", ILPRouter(_router(lendingPool)).userBorrowShares(alice));
        // Use 10e6 shares (USDT amount to repay) but token is wNative which needs 18-decimal compatible amount
        ILendingPool(lendingPool)
            .repayWithSelectedToken(RepayParams({ user: alice, token: wNative, shares: 10e6, amountOutMinimum: 0, fromPosition: true, fee: 1000 }));
        console.log("Final wNative in position:", IERC20(wNative).balanceOf(position));
        console.log("Final usdt in position:", IERC20(usdt).balanceOf(position));
        console.log("Final borrow shares:", ILPRouter(_router(lendingPool)).userBorrowShares(alice));
        vm.stopPrank();
        assertLt(ILPRouter(_router(lendingPool)).userBorrowShares(alice), 20e6);
    }

    // RUN
    // forge test --match-test test_swap_with_zero_min_amount_out_minimum -vvv
    function test_swap_with_zero_min_amount_out_minimum() public {
        test_supply_collateral();

        address position = _addressPosition(lendingPool, alice);

        vm.startPrank(alice);

        uint256 swapAmount = 50 ether;

        console.log("Testing swap with 10000 slippage tolerance (100%)");
        console.log("Initial wNative:", IERC20(wNative).balanceOf(position));
        console.log("Initial usdt:", IERC20(usdt).balanceOf(position));

        ILendingPool(lendingPool).swapTokenByPosition(SwapHook.SwapParams(wNative, usdt, swapAmount, 10000, 1000));

        console.log("After swap wNative:", IERC20(wNative).balanceOf(position));
        console.log("After swap usdt:", IERC20(usdt).balanceOf(position));

        uint256 usdtAmount = 1e6;
        ILendingPool(lendingPool).swapTokenByPosition(SwapHook.SwapParams(usdt, wNative, usdtAmount, 10000, 1000));

        console.log("After swap back wNative:", IERC20(wNative).balanceOf(position));
        console.log("After swap back usdt:", IERC20(usdt).balanceOf(position));

        vm.stopPrank();
    }

    // RUN
    // forge test --match-test test_position_repay_collateral_swap -vvv
    function test_position_repay_collateral_swap() public {
        // Setup: Supply liquidity, collateral, and borrow
        test_supply_liquidity();
        test_supply_collateral();

        vm.startPrank(alice);
        ILendingPool(lendingPool).borrowDebt(20e6);
        vm.stopPrank();

        address position = _addressPosition(lendingPool, alice);

        vm.startPrank(alice);
        console.log("Before swap - wNative:", IERC20(wNative).balanceOf(position));
        console.log("Before swap - usdt:", IERC20(usdt).balanceOf(position));
        console.log("Before swap - borrow shares:", ILPRouter(_router(lendingPool)).userBorrowShares(alice));
        ILendingPool(lendingPool)
            .swapTokenByPosition(SwapHook.SwapParams({ tokenIn: wNative, tokenOut: usdt, amountIn: 200 ether, amountOutMinimum: 0, fee: 1000 }));
        console.log("After swap - wNative:", IERC20(wNative).balanceOf(position));
        console.log("After swap - usdt:", IERC20(usdt).balanceOf(position));
        vm.stopPrank();

        vm.startPrank(alice);
        ILendingPool(lendingPool)
            .repayWithSelectedToken(RepayParams({ user: alice, token: usdt, shares: 10e6, amountOutMinimum: 500, fromPosition: true, fee: 1000 }));
        console.log("After repayment - wNative:", IERC20(wNative).balanceOf(position));
        console.log("After repayment - usdt:", IERC20(usdt).balanceOf(position));
        console.log("After repayment - borrow shares:", ILPRouter(_router(lendingPool)).userBorrowShares(alice));
        vm.stopPrank();

        assertLt(ILPRouter(_router(lendingPool)).userBorrowShares(alice), 20e6);
    }

    // RUN
    // forge test --match-test test_position_repay_with_collateral_swap -vvv
    function test_position_repay_with_collateral_swap() public {
        test_supply_liquidity();
        test_supply_collateral();

        vm.startPrank(alice);
        ILendingPool(lendingPool).borrowDebt(20e6);
        vm.stopPrank();

        address position = _addressPosition(lendingPool, alice);

        vm.startPrank(alice);
        console.log("Before repayment - wNative:", IERC20(wNative).balanceOf(position));
        console.log("Before repayment - usdt:", IERC20(usdt).balanceOf(position));
        console.log("Before repayment - borrow shares:", ILPRouter(_router(lendingPool)).userBorrowShares(alice));
        // Repay 10e6 shares using wNative from position - use amountOutMinimum: 0 since MockDex may return small amounts
        ILendingPool(lendingPool)
            .repayWithSelectedToken(RepayParams({ user: alice, token: wNative, shares: 10e6, amountOutMinimum: 0, fromPosition: true, fee: 1000 }));
        console.log("After repayment - wNative:", IERC20(wNative).balanceOf(position));
        console.log("After repayment - usdt:", IERC20(usdt).balanceOf(position));
        console.log("After repayment - borrow shares:", ILPRouter(_router(lendingPool)).userBorrowShares(alice));
        vm.stopPrank();
        assertLt(ILPRouter(_router(lendingPool)).userBorrowShares(alice), 20e6);
    }

    // RUN
    // forge test --match-test test_position_repay_other_token_direct -vvv
    function test_position_repay_other_token_direct() public {
        test_supply_liquidity();
        test_supply_collateral();

        vm.startPrank(alice);
        ILendingPool(lendingPool).borrowDebt(15e6);
        vm.stopPrank();

        address position = _addressPosition(lendingPool, alice);

        vm.startPrank(alice);
        console.log("Initial state:");
        console.log("wNative in position:", IERC20(wNative).balanceOf(position));
        console.log("usdt in position:", IERC20(usdt).balanceOf(position));
        console.log("Borrow shares:", ILPRouter(_router(lendingPool)).userBorrowShares(alice));
        console.log("Total borrow assets:", ILPRouter(_router(lendingPool)).totalBorrowAssets());

        // Use 0.01 ether for wNative (18 decimals) approval and amountOutMinimum: 0 for MockDex compatibility
        IERC20(wNative).approve(lendingPool, 0.01 ether);
        ILendingPool(lendingPool)
            .repayWithSelectedToken(RepayParams({ user: alice, token: wNative, shares: 5e6, amountOutMinimum: 0, fromPosition: false, fee: 1000 }));

        console.log("After first repayment:");
        console.log("wNative in position:", IERC20(wNative).balanceOf(position));
        console.log("usdt in position:", IERC20(usdt).balanceOf(position));
        console.log("Borrow shares:", ILPRouter(_router(lendingPool)).userBorrowShares(alice));
        console.log("Total borrow assets:", ILPRouter(_router(lendingPool)).totalBorrowAssets());

        IERC20(wNative).approve(lendingPool, 0.01 ether);
        ILendingPool(lendingPool)
            .repayWithSelectedToken(RepayParams({ user: alice, token: wNative, shares: 5e6, amountOutMinimum: 0, fromPosition: false, fee: 1000 }));

        console.log("After second repayment:");
        console.log("wNative in position:", IERC20(wNative).balanceOf(position));
        console.log("usdt in position:", IERC20(usdt).balanceOf(position));
        console.log("Borrow shares:", ILPRouter(_router(lendingPool)).userBorrowShares(alice));
        console.log("Total borrow assets:", ILPRouter(_router(lendingPool)).totalBorrowAssets());
        vm.stopPrank();

        // Verify repayments occurred
        assertLt(ILPRouter(_router(lendingPool)).userBorrowShares(alice), 15e6);
        assertLt(ILPRouter(_router(lendingPool)).totalBorrowAssets(), 15e6);
    }

    // RUN
    // forge test --match-test test_borrow_higher_than_liquidation_threshold -vvv
    function test_borrow_higher_than_liquidation_threshold() public {
        test_supply_liquidity();
        test_supply_collateral();
        console.log("_tokenPrice(wNative)", 1000 * helperTokenPrice(wNative) / 1e8);

        vm.startPrank(alice);
        vm.expectRevert();
        ILendingPool(lendingPool).borrowDebt(35e6);
        vm.stopPrank();
    }

    // RUN
    // forge test --match-test test_borrow_more_than_ltv -vvv
    function test_borrow_more_than_ltv() public {
        test_supply_liquidity();
        test_supply_collateral();
        console.log("_tokenPrice(wNative)", 1000 * helperTokenPrice(wNative) / 1e8);

        vm.startPrank(alice);
        // Expect ExceedsMaxLTV error because 65 USDT exceeds the 60% LTV limit
        vm.expectRevert(); // Will revert with ExceedsMaxLTV
        ILendingPool(lendingPool).borrowDebt(37e6);
        vm.stopPrank();
    }

    // RUN
    // forge test --match-test test_borrow_exceeds_liquidation_threshold -vvv
    function test_borrow_exceeds_liquidation_threshold() public {
        test_supply_liquidity();
        test_supply_collateral();

        vm.startPrank(alice);
        vm.expectRevert(); // Will revert with ExceedsMaxLTV since we check LTV first
        ILendingPool(lendingPool).borrowDebt(45e6);
        vm.stopPrank();
    }

    function helperTokenPrice(address _token) internal view returns (uint256) {
        (, uint256 price,,,) = ITokenDataStream(helperTokenDataStream()).latestRoundData(_token);
        return price;
    }

    function helperTokenDataStream() internal view returns (address) {
        return IFactory(address(lendingPoolFactory)).tokenDataStream();
    }

    // RUN
    // forge test --match-test test_liquidation -vvv
    function test_liquidation() public {
        test_supply_liquidity();
        test_supply_collateral();

        vm.startPrank(alice);
        ILendingPool(lendingPool).borrowDebt(9e6);
        vm.stopPrank();

        _deployMockOrakl();

        address borrowToken = address(usdt);
        address collateralToken = address(wNative);

        uint256 protocolBorrowBefore = IERC20(borrowToken).balanceOf(address(protocol));
        uint256 protocolCollateralBefore = IERC20(collateralToken).balanceOf(address(protocol));
        console.log("protocolBorrowBefore", protocolBorrowBefore / 1e6);
        console.log("protocolCollateralBefore", protocolCollateralBefore / 1e18);
        uint256 borrowBalanceBefore = IERC20(borrowToken).balanceOf(owner);
        uint256 collateralBalanceBefore = IERC20(collateralToken).balanceOf(owner);
        console.log("balance borrowToken before", borrowBalanceBefore / 1e6);
        console.log("balance collateralToken before", collateralBalanceBefore / 1e18);

        vm.startPrank(owner);
        IERC20(borrowToken).approve(lendingPool, 9e6);
        ILendingPool(lendingPool).liquidation(alice);
        vm.stopPrank();

        uint256 protocolBorrowAfter = IERC20(borrowToken).balanceOf(address(protocol));
        uint256 protocolCollateralAfter = IERC20(collateralToken).balanceOf(address(protocol));
        console.log("protocolBorrowAfter", protocolBorrowAfter / 1e6);
        console.log("protocolCollateralAfter", protocolCollateralAfter / 1e18);
        uint256 borrowBalanceAfter = IERC20(borrowToken).balanceOf(owner);
        uint256 collateralBalanceAfter = IERC20(collateralToken).balanceOf(owner);
        console.log("balance borrowToken after", borrowBalanceAfter / 1e6);
        console.log("balance collateralToken after", collateralBalanceAfter / 1e18);
        console.log("gap after - before", (collateralBalanceAfter - collateralBalanceBefore) / 1e18);
    }

    function _toDynamicArray(address[2] memory fixedArray) internal view returns (address[] memory) {
        if (block.chainid == 1001) {
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

    function _deployMockOrakl() internal {
        vm.startPrank(owner);
        mockOrakl = new Orakl(address(wNative));
        mockOrakl.setPrice(1 * 1e6);
        tokenDataStream.setTokenPriceFeed(address(wNative), address(mockOrakl));
        vm.stopPrank();
    }

    function _router(address _lendingPool) internal view returns (address) {
        return ILendingPool(_lendingPool).router();
    }

    function _sharesToken(address _lendingPool) internal view returns (address) {
        return ILPRouter(_router(_lendingPool)).sharesToken();
    }

    function _addressPosition(address _lendingPool, address _user) internal view returns (address) {
        return ILPRouter(_router(_lendingPool)).addressPositions(_user);
    }
}
