// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract Helper {
    // ***** MAINNET *****
    address public constant BASE_LZ_ENDPOINT = 0x1a44076050125825900e736c501f859c50fE728c;
    address public constant KAIA_LZ_ENDPOINT = 0x1a44076050125825900e736c501f859c50fE728c;
    address public constant GLMR_LZ_ENDPOINT = 0x1a44076050125825900e736c501f859c50fE728c;
    address public constant KAIA_TESTNET_LZ_ENDPOINT = 0x6EDCE65403992e310A62460808c4b910D972f10f;
    address public constant BASE_TESTNET_LZ_ENDPOINT = 0x6EDCE65403992e310A62460808c4b910D972f10f;
    address public constant MANTLE_TESTNET_LZ_ENDPOINT = 0x6EDCE65403992e310A62460808c4b910D972f10f;

    address public constant BASE_SEND_LIB = 0xB5320B0B3a13cC860893E2Bd79FCd7e13484Dda2;
    address public constant KAIA_SEND_LIB = 0x9714Ccf1dedeF14BaB5013625DB92746C1358cb4;
    address public constant GLMR_SEND_LIB = 0xeac136456d078bB76f59DCcb2d5E008b31AfE1cF;
    address public constant KAIA_TESTNET_SEND_LIB = 0x6bd925aA58325fba65Ea7d4412DDB2E5D2D9427d;
    address public constant BASE_TESTNET_SEND_LIB = 0xC1868e054425D378095A003EcbA3823a5D0135C9;
    address public constant MANTLE_TESTNET_SEND_LIB = 0x9A289B849b32FF69A95F8584a03343a33Ff6e5Fd;

    address public constant BASE_RECEIVE_LIB = 0xc70AB6f32772f59fBfc23889Caf4Ba3376C84bAf;
    address public constant KAIA_RECEIVE_LIB = 0x937AbA873827BF883CeD83CA557697427eAA46Ee;
    address public constant GLMR_RECEIVE_LIB = 0x2F4C6eeA955e95e6d65E08620D980C0e0e92211F;
    address public constant KAIA_TESTNET_RECEIVE_LIB = 0xFc4eA96c3de3Ba60516976390fA4E945a0b8817B;
    address public constant BASE_TESTNET_RECEIVE_LIB = 0x12523de19dc41c91F7d2093E0CFbB76b17012C8d;
    address public constant MANTLE_TESTNET_RECEIVE_LIB = 0x8A3D588D9f6AC041476b094f97FF94ec30169d3D;

    uint32 public constant BASE_EID = 30184;
    uint32 public constant KAIA_EID = 30150;
    uint32 public constant GLMR_EID = 30126;
    uint32 public constant KAIA_TESTNET_EID = 40150;
    uint32 public constant BASE_TESTNET_EID = 40245;
    uint32 public constant MANTLE_TESTNET_EID = 40246;

    address public constant BASE_DVN1 = 0x554833698Ae0FB22ECC90B01222903fD62CA4B47; // Canary
    address public constant BASE_DVN2 = 0xa7b5189bcA84Cd304D8553977c7C614329750d99; // Horizen
    address public constant BASE_DVN3 = 0x9e059a54699a285714207b43B055483E78FAac25; // LayerZeroLabs

    address public constant KAIA_DVN1 = 0x1154d04d07AEe26ff2C200Bd373eb76a7e5694d6; // Canary
    address public constant KAIA_DVN2 = 0xaCDe1f22EEAb249d3ca6Ba8805C8fEe9f52a16e7; // Horizen
    address public constant KAIA_DVN3 = 0xc80233AD8251E668BecbC3B0415707fC7075501e; // LayerZeroLabs

    address public constant GLMR_DVN1 = 0x33E5fcC13D7439cC62d54c41AA966197145b3Cd7; // Canary
    address public constant GLMR_DVN2 = 0x34730f2570E6cff8B1C91FaaBF37D0DD917c4367; // Horizen
    address public constant GLMR_DVN3 = 0x8B9b67b22ab2ed6Ee324C2fd43734dBd2dDDD045; // LayerZeroLabs

    address public constant KAIA_TESTNET_DVN1 = 0xe4Fe9782b809b7D66f0Dcd10157275D2C4e4898D; // LayerZeroLabs
    address public constant KAIA_TESTNET_DVN2 = 0xe4Fe9782b809b7D66f0Dcd10157275D2C4e4898D; // LayerZeroLabs
    address public constant KAIA_TESTNET_DVN3 = 0xe4Fe9782b809b7D66f0Dcd10157275D2C4e4898D; // LayerZeroLabs

    address public constant BASE_TESTNET_DVN1 = 0xe1a12515F9AB2764b887bF60B923Ca494EBbB2d6; // LayerZeroLabs
    address public constant BASE_TESTNET_DVN2 = 0xe1a12515F9AB2764b887bF60B923Ca494EBbB2d6; // LayerZeroLabs
    address public constant BASE_TESTNET_DVN3 = 0xe1a12515F9AB2764b887bF60B923Ca494EBbB2d6; // LayerZeroLabs

    address public constant MANTLE_TESTNET_DVN1 = 0x9454f0EABc7C4Ea9ebF89190B8bF9051A0468E03; // LayerZeroLabs
    address public constant MANTLE_TESTNET_DVN2 = 0x9454f0EABc7C4Ea9ebF89190B8bF9051A0468E03; // LayerZeroLabs
    address public constant MANTLE_TESTNET_DVN3 = 0x9454f0EABc7C4Ea9ebF89190B8bF9051A0468E03; // LayerZeroLabs

    address public constant BASE_EXECUTOR = 0x2CCA08ae69E0C44b18a57Ab2A87644234dAebaE4;
    address public constant KAIA_EXECUTOR = 0xe149187a987F129FD3d397ED04a60b0b89D1669f;
    address public constant GLMR_EXECUTOR = 0xEC0906949f88f72bF9206E84764163e24a56a499;
    address public constant KAIA_TESTNET_EXECUTOR = 0xddF3266fEAa899ACcf805F4379E5137144cb0A7D;
    address public constant BASE_TESTNET_EXECUTOR = 0x8A3D588D9f6AC041476b094f97FF94ec30169d3D;
    address public constant MANTLE_TESTNET_EXECUTOR = 0x8BEEe743829af63F5b37e52D5ef8477eF12511dE;

    address public constant KAIA_USDT = 0xd077A400968890Eacc75cdc901F0356c943e4fDb;
    address public constant KAIA_USDT_STARGATE = 0x9025095263d1E548dc890A7589A4C78038aC40ab; // stargate
    address public constant KAIA_KAIA = address(1);
    address public constant KAIA_WKAIA = 0x19Aac5f612f524B754CA7e7c41cbFa2E981A4432;
    address public constant KAIA_WETH = 0x98A8345bB9D3DDa9D808Ca1c9142a28F6b0430E1;
    address public constant KAIA_WBTC = 0x981846bE8d2d697f4dfeF6689a161A25FfbAb8F9;

    address public constant BASE_USDT = 0xfde4C96c8593536E31F229EA8f37b2ADa2699bb2;
    address public constant BASE_KAIA = address(0);
    address public constant BASE_WETH = 0x4200000000000000000000000000000000000006;
    address public constant BASE_WBTC = 0x0555E30da8f98308EdB960aa94C0Db47230d2B9c;

    address public constant KAIA_DEX_ROUTER = 0xA324880f884036E3d21a09B90269E1aC57c7EC8a;

    // ** SELF DEPLOYED Mainnet **
    address public constant KAIA_OFT_USDT_ADAPTER = 0x6D68A52Bc77F2eAc3582a7072eAd94C19B9f480c;
    address public constant KAIA_OFT_USDT_STARGATE_ADAPTER = 0x920Cd2F6e139b6C40053BCd5F67923d1d7Dd3140;
    address public constant KAIA_OFT_WKAIA_ADAPTER = 0x5DDbbC68527214E0aCA3B4175860080cBDAA12ff;
    address public constant KAIA_OFT_WBTC_ADAPTER = 0xFe5138A42dc1fc335455b505E036784A33F7F102;
    address public constant KAIA_OFT_WETH_ADAPTER = 0xB0E96105543cBA4B3D82911E7336f19BD03b0360;

    address public constant KAIA_MOCK_USDT = 0xCEb5c8903060197e46Ab5ea5087b9F99CBc8da49;
    address public constant KAIA_MOCK_USDT_ELEVATED_MINTER_BURNER = 0xA628a83cc869b82A684895f628029Eb90ee60224;
    address public constant KAIA_OFT_MOCK_USDT_ADAPTER = 0xaf9842ADacB4b2fA619D45fE11579Fae5FAf1698;

    address public constant KAIA_MOCK_WKAIA = 0x684a2aAF3d98bC8eD2c07988E8da9023026aD511;
    address public constant KAIA_MOCK_WKAIA_ELEVATED_MINTER_BURNER = 0xC7e9CF4Bc5f6C43e1410FfA33436287968003aCE;
    address public constant KAIA_OFT_MOCK_WKAIA_ADAPTER = 0xDa5D036f51Bd6Fe5e32915a53595B71312d45f91;

    address public constant KAIA_MOCK_WETH = 0x649eF2a788732900B82237C126a121be3282997c;
    address public constant KAIA_MOCK_WBTC = 0x8Bf79e425B54ecD75907B4Eda00DCED8C1a97DB0;
    address public constant KAIA_OAPP_SUPPLY_LIQUIDITY_USDT = 0xF8Af5114ad19422e059797CA2515FeBD8Bc06bd1;

    address public constant BASE_SUSDT = 0xc3be8ab4CA0cefE3119A765b324bBDF54a16A65b;
    address public constant BASE_SKAIA = 0x46dA9F76c20a752132dDaefD2B14870e0A152D71;
    address public constant BASE_SWKAIA = 0x3703a1DA99a2BDf2d8ce57802aaCb20fb546Ff12;
    address public constant BASE_SWBTC = 0x394239573079a46e438ea6D118Fd96d37A61f270;
    address public constant BASE_SWETH = 0xec32CC0267002618c339274C18AD48D2Bf2A9c7e;

    address public constant BASE_MOCK_USDT = 0x7bb55D2D27194a25517F8a47cDaF227fD413DCA6;
    address public constant BASE_M0CK_WKAIA = 0xF3f7c9320b0dbf780092DAAab740B7b855522258;

    address public constant BASE_SUSDT_ELEVATED_MINTER_BURNER = 0xDa5D036f51Bd6Fe5e32915a53595B71312d45f91;
    address public constant BASE_SKAIA_ELEVATED_MINTER_BURNER = 0xCFAF23d5d5F144F66A13E05a41B97c0C23Aa4E1F;
    address public constant BASE_SWKAIA_ELEVATED_MINTER_BURNER = 0xA5B25a041cfC241f2B808B3298e2Cb7ceB5DfCD2;
    address public constant BASE_SWETH_ELEVATED_MINTER_BURNER = 0x8FEd03c9d8ed1237b76BE271a49D11CCE5dFd81e;
    address public constant BASE_SWBTC_ELEVATED_MINTER_BURNER = 0xf15f575095a37A0325182C49a45Fe05f09Fc6b4D;

    address public constant BASE_MOCK_USDT_ELEVATED_MINTER_BURNER = 0x26991986AEc6748F439940949B74873418006383;
    address public constant BASE_MOCK_WKAIA_ELEVATED_MINTER_BURNER = 0x943fCC03799400a672a8f82907d3a320FA76eFC1;

    address public constant BASE_OFT_SUSDT_ADAPTER = 0xAd063B1915Bf95fB32f79138c0B668F232676333;
    address public constant BASE_OFT_SKAIA_ADAPTER = 0x7F047526f942147a228F2709BB66A3bDEA71eD26;
    address public constant BASE_OFT_SWKAIA_ADAPTER = 0xB83E44F1D59Bd8743AE45816ACd5622fA1a5624D;
    address public constant BASE_OFT_SWBTC_ADAPTER = 0x1EffDCF81A95398920e024BB3b9ff60CE14590e7;
    address public constant BASE_OFT_SWETH_ADAPTER = 0x6C71b7bbDE382f12165D5f7749B5fD37965B1E8a;

    address public constant BASE_OFT_MOCK_USDT_ADAPTER = 0x560Bd1836C348c4a10EED7008e68AE58228dD117;
    address public constant BASE_OFT_MOCK_WKAIA_ADAPTER = 0x9eaA6eC9e0b55948309Eb320166312cb0807B6de;

    address public constant BASE_OAPP_SUPPLY_LIQUIDITY_USDT = 0x374427909212B29fcC3Ffe8e7920a190a3031CB8;

    address public constant BASE_OAPP_ADAPTER = 0x43BB8bEb166c8786C50a9D1D5c8482D667CF981A;
    // *******************

    // ORACLE - MANTLE TESTNET
    address public constant USDT_USD = 0x71c184d899c1774d597d8D80526FB02dF708A69a;
    address public constant USDC_USD = 0x1d6F6dbD68BD438950c37b1D514e49306F65291E;
    address public constant NATIVE_USDT = 0x4c8962833Db7206fd45671e9DC806e4FcC0dCB78;
    address public constant ETH_USDT = 0x9bD31B110C559884c49d1bA3e60C1724F2E336a7;
    address public constant BTC_USDT = 0xecC446a3219da4594d5Ede8314f500212e496E17;

    // *******************

    address public constant KAIA_USDT_USD_ADAPTER = 0xC72f2eb4A97F19ecD0C10b5201676a10B6D8bB67;
    address public constant KAIA_KAIA_USDT_ADAPTER = 0x46638aD472507482B7D5ba45124E93D16bc97eCE;
    address public constant KAIA_ETH_USDT_ADAPTER = 0xdbbb07E1AE9D0F23Ac6dA9BDDA3Dff96fcA73650;
    address public constant KAIA_BTC_USDT_ADAPTER = 0x3703a1DA99a2BDf2d8ce57802aaCb20fb546Ff12;

    address public constant KAIA_LIQUIDATOR = 0x530F48Df8e4D60BBF9BbcFE8cF584344514af193;
    address public constant KAIA_IS_HEALTHY = 0x057852e8211698a22953e0343Aae24E446ECF105;
    address public constant KAIA_POSITION_DEPLOYER = 0x1385Df17F009F88e6cA1380798BF20B0669C8ee0;
    address public constant KAIA_PROTOCOL = 0xd8d5edCE9F0e3544D2A712818232fdA7502BA1A6;
    address public constant KAIA_LENDING_POOL_DEPLOYER = 0x677f0172ff3E8EEf477Ce811Ed57A85B8d8a3bDa;
    address public constant KAIA_LENDING_POOL_ROUTER_DEPLOYER = 0x60377628d1733fe0FB64D8B84466b461974DA60A;
    address public constant KAIA_LENDING_POOL_FACTORY_IMPLEMENTATION = 0xc28446267B3c9a733D6C7419535B883908e55813;
    address public constant KAIA_LENDING_POOL_FACTORY_PROXY = 0xa971CD2714fbCc9A942b09BC391a724Df9338206;
    address public constant KAIA_HELPER_UTILS = 0x3De8C22F6b84C575429c1B9cbf5bdDd49cf129fC;

    // *******************

    address public constant KAIA_TESTNET_MOCK_USDT = 0xEb36AA674745c48381AA3A8074E5485586dBD308;
    address public constant KAIA_TESTNET_MOCK_WKAIA = 0xFE4f79Ea2211660A221bed8b4E2de7Eb8579Fe67;
    address public constant KAIA_TESTNET_MOCK_WETH = 0x7B3C20D2B3F8C205f624e62D356354Ed1Ae9F64b;

    address public constant KAIA_TESTNET_MOCK_DEX = 0x10FD0d8280E94D0DbC3013b778Ef26d47105Ea7b;

    address public constant KAIA_TESTNET_USDT_ELEVATED_MINTER_BURNER = 0xeBb7a56fd2D0231A9BF7240542cbD09a641a29Fc;
    address public constant KAIA_TESTNET_USDT_OFT_ADAPTER = 0x1e68394DBd41F77Adf0644CE47b25D1023D664B1;

    address public constant KAIA_TESTNET_WKAIA_ELEVATED_MINTER_BURNER = 0x53D7f02e72d62f7b7B41F6B622A7d79694BED966;
    address public constant KAIA_TESTNET_WKAIA_OFT_ADAPTER = 0xd506b22a6b3216b736021FA262D0F5D686e07b35;

    address public constant KAIA_TESTNET_WETH_ELEVATED_MINTER_BURNER = 0xBdC661EECb0dcFB940A34008e0190c9103013C41;
    address public constant KAIA_TESTNET_WETH_OFT_ADAPTER = 0x31fC86E13108A098830eea63A8A9f6d80DfC89Aa;

    address public constant KAIA_TESTNET_TOKEN_DATA_STREAM_IMPLEMENTATION = 0xec32CC0267002618c339274C18AD48D2Bf2A9c7e;
    address public constant KAIA_TESTNET_TOKEN_DATA_STREAM = 0xfBC915dc39654b52B2E9284FB966C79A1071eA3A;

    // address public constant KAIA_TESTNET_INTEREST_RATE_MODEL_IMPLEMENTATION = 0x32822138bc93390f236B4a629EA793dE12b92d19;
    // address public constant KAIA_TESTNET_INTEREST_RATE_MODEL_IMPLEMENTATION = 0x26991986AEc6748F439940949B74873418006383;
    address public constant KAIA_TESTNET_INTEREST_RATE_MODEL_IMPLEMENTATION = 0x96949b9F94b84eeb2b590AEC033a825f17D5D6Dd;
    address public constant KAIA_TESTNET_INTEREST_RATE_MODEL = 0xbd699511ce18407485D8572Ef0fBa783283fd982;

    // address public constant KAIA_TESTNET_LENDING_POOL_DEPLOYER = 0x95608557Eb1fa88D07fB6Af29FcB76b25A93bB2c;
    address public constant KAIA_TESTNET_LENDING_POOL_DEPLOYER = 0x9e77F602e0ec09078F9ba50C9a453EDC795B0A4E;
    // address public constant KAIA_TESTNET_LENDING_POOL_ROUTER_DEPLOYER = 0xe19784dd55E2D7B610b53B5379EFf878c75A7cd4;
    address public constant KAIA_TESTNET_LENDING_POOL_ROUTER_DEPLOYER = 0x3A1353926e2c1aDA7acc93A6fBE73C1EC6B1e931;
    address public constant KAIA_TESTNET_POSITION_DEPLOYER = 0x034cf520e48C7e87763466949058965F7a5A3181;
    address public constant KAIA_TESTNET_PROXY_DEPLOYER = 0x252D67D23308646cf6dAe32A826DE24Ba21e7c12;
    address public constant KAIA_TESTNET_SHARES_TOKEN_DEPLOYER = 0x5E66DE02c77eA971Bbd2bc37a31Cc9860e6a01d3;

    address public constant KAIA_TESTNET_IS_HEALTHY_IMPLEMENTATION = 0x74E79E900A20d841d9Af9fC5361cefEA9a3247c2;
    address public constant KAIA_TESTNET_IS_HEALTHY = 0xCEb5c8903060197e46Ab5ea5087b9F99CBc8da49;

    address public constant KAIA_TESTNET_PROTOCOL = 0x684a2aAF3d98bC8eD2c07988E8da9023026aD511;

    // address public constant KAIA_TESTNET_LENDING_POOL_FACTORY_IMPLEMENTATION = 0x369e7557C195371547bcC5409E97177173544C35;
    // address public constant KAIA_TESTNET_LENDING_POOL_FACTORY_IMPLEMENTATION = 0x8a105Bd6153561f48c9034623e811FC0B379dfc8;
    // address public constant KAIA_TESTNET_LENDING_POOL_FACTORY_IMPLEMENTATION = 0x79152D82ad821E80F8758838fA4605f658cB2d18;
    address public constant KAIA_TESTNET_LENDING_POOL_FACTORY_IMPLEMENTATION = 0x33d56fc7eF4B54A8C358548CEa3D9aEAd1619ee9;
    address public constant KAIA_TESTNET_LENDING_POOL_FACTORY = 0x3705620C09D43935C00852d3610e31C942595cE8;

    address public constant KAIA_TESTNET_SUPALA_EMITTER_IMPLEMENTATION = 0xFc7920756B2983Af98C5edD94034f748eEF25aEf;
    address public constant KAIA_TESTNET_SUPALA_EMITTER = 0x677f0172ff3E8EEf477Ce811Ed57A85B8d8a3bDa;

    address public constant KAIA_TESTNET_HELPER_UTILS = 0xF6d95EeFF99E171Bb150d736eb2BE23c9cF6a6ef;

    address public constant MANTLE_TESTNET_MOCK_USDT = 0xdF05e9AbF64dA281B3cBd8aC3581022eC4841FB2;
    address public constant MANTLE_TESTNET_MOCK_USDC = 0x04C37dc1b538E00b31e6bc883E16d97cD7937a10;
    address public constant MANTLE_TESTNET_MOCK_WMNT = 0x15858A57854BBf0DF60A737811d50e1Ee785f9bc;
    address public constant MANTLE_TESTNET_MOCK_WETH = 0x4Ba8D8083e7F3652CCB084C32652e68566E9Ef23;
    address public constant MANTLE_TESTNET_MOCK_WBTC = 0x007F735Fd070DeD4B0B58D430c392Ff0190eC20F;

    address public constant MANTLE_TESTNET_MOCK_DEX = 0x5C368bd6cE77b2ca47B4ba791fCC1f1645591c84;

    address public constant MANTLE_TESTNET_USDT_ELEVATED_MINTER_BURNER = 0x175867CAF278eB0610F216F3E0a6E671f2382E22;
    address public constant MANTLE_TESTNET_USDT_OFT_ADAPTER = 0xC327486Db1417644f201d84414bbeA6C8A948bef;

    address public constant MANTLE_TESTNET_USDC_ELEVATED_MINTER_BURNER = 0x6Ab9c1AAf4f8172138086AA72be2AB8aA6579dbd;
    address public constant MANTLE_TESTNET_USDC_OFT_ADAPTER = 0x886ba47579DC4f5DcB53ffd20429089A7788C072;

    address public constant MANTLE_TESTNET_WMNT_ELEVATED_MINTER_BURNER = 0x39926DA4905f5Edb956F5dB5F2e2FF044E0882B2;
    address public constant MANTLE_TESTNET_WMNT_OFT_ADAPTER = 0xAE1b8d3B428d6A8F62df2f623081EAC8734168fe;

    address public constant MANTLE_TESTNET_WETH_ELEVATED_MINTER_BURNER = 0xF0D1c69cc148db2437131a5A736d77FD6fa20B47;
    address public constant MANTLE_TESTNET_WETH_OFT_ADAPTER = 0x487b1e0177B3ac1ACA7e8c353ed0Df133593a8EB;

    address public constant MANTLE_TESTNET_WBTC_ELEVATED_MINTER_BURNER = 0xe5D4C481e25880eaD3A1647A210A9f219204f3CA;
    address public constant MANTLE_TESTNET_WBTC_OFT_ADAPTER = 0xC746B3AaB0C6Da075C9b7b43CEebd437Ef759D5b;

    address public constant MANTLE_TESTNET_TOKEN_DATA_STREAM_IMPLEMENTATION = 0x7B3C20D2B3F8C205f624e62D356354Ed1Ae9F64b;
    address public constant MANTLE_TESTNET_TOKEN_DATA_STREAM = 0x10FD0d8280E94D0DbC3013b778Ef26d47105Ea7b;

    address public constant MANTLE_TESTNET_INTEREST_RATE_MODEL_IMPLEMENTATION = 0x5C43afab54BD5E5568d0aD54ea60D4d065303C35;
    address public constant MANTLE_TESTNET_INTEREST_RATE_MODEL = 0xBdC661EECb0dcFB940A34008e0190c9103013C41;

    address public constant MANTLE_TESTNET_LENDING_POOL_DEPLOYER = 0x31fC86E13108A098830eea63A8A9f6d80DfC89Aa;
    address public constant MANTLE_TESTNET_LENDING_POOL_ROUTER_DEPLOYER = 0x02a66B51Fc24E08535a6Cfe1e11E532D8A089212;
    address public constant MANTLE_TESTNET_POSITION_DEPLOYER = 0x4852Bc014401415C4CE4788A04cAB019d1527aAa;
    address public constant MANTLE_TESTNET_PROXY_DEPLOYER = 0xb516190F8192CCEaF8B1DA7D9Ca1C6C75b9F410c;
    address public constant MANTLE_TESTNET_SHARES_TOKEN_DEPLOYER = 0x33FaBa0e0cE340AfC4fb03038151FF7EE1d5f95b;

    address public constant MANTLE_TESTNET_IS_HEALTHY_IMPLEMENTATION = 0xc3be8ab4CA0cefE3119A765b324bBDF54a16A65b;
    address public constant MANTLE_TESTNET_IS_HEALTHY = 0xE2e025Ff8a8adB2561e3C631B5a03842b9A1Ae88;

    address public constant MANTLE_TESTNET_PROTOCOL = 0x5E6AAd48fB0a23E9540A5EAFfb87846E8ef04C42;

    address public constant MANTLE_TESTNET_LENDING_POOL_FACTORY_IMPLEMENTATION = 0x718b1b67f287571767452CC7d24BCD95c63DbA13;
    address public constant MANTLE_TESTNET_LENDING_POOL_FACTORY = 0x46dA9F76c20a752132dDaefD2B14870e0A152D71;

    address public constant MANTLE_TESTNET_SUPALA_EMITTER_IMPLEMENTATION = 0xC72f2eb4A97F19ecD0C10b5201676a10B6D8bB67;
    address public constant MANTLE_TESTNET_SUPALA_EMITTER = 0x46638aD472507482B7D5ba45124E93D16bc97eCE;

    address public constant MANTLE_TESTNET_HELPER_UTILS = 0x6c454d20F4CB5f69e2D66693fA8deE931D7432dF;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    address public usdt;
    address public usdc;
    address public wNative;
    address public native = address(1); // Using wNative instead of native token address(1) for better DeFi composability
    address public weth;
    address public wbtc;

    address public usdtUsdAdapter;
    address public nativeUsdtAdapter;
    address public ethUsdtAdapter;
    address public btcUsdtAdapter;

    address public oftNativeOriAdapter;
    address public oftNativeAdapter;
    address public oftWethAdapter;
    address public oftUsdtAdapter;

    address public dexRouter;

    address endpoint;
    address oapp;
    address oapp2;
    address oapp3;
    address sendLib;
    address receiveLib;
    uint32 srcEid;
    uint32 gracePeriod;

    address dvn1;
    address dvn2;
    address executor;

    uint32 eid0;
    uint32 eid1;
    uint32 constant EXECUTOR_CONFIG_TYPE = 1;
    uint16 constant SEND = 1;
    uint32 constant ULN_CONFIG_TYPE = 2;
    uint32 constant RECEIVE_CONFIG_TYPE = 2;

    string public chainName;

    function _getUtils() internal virtual {
        if (block.chainid == 8453) {
            endpoint = BASE_LZ_ENDPOINT;
            sendLib = BASE_SEND_LIB;
            receiveLib = BASE_RECEIVE_LIB;
            srcEid = BASE_EID;
            gracePeriod = uint32(0);
            dvn1 = BASE_DVN1;
            dvn2 = BASE_DVN2;
            executor = BASE_EXECUTOR;
            eid0 = BASE_EID;
            eid1 = KAIA_EID;
            usdt;
            wNative;
            dexRouter;
            chainName = "BASE";
        } else if (block.chainid == 8217) {
            endpoint = KAIA_LZ_ENDPOINT;
            sendLib = KAIA_SEND_LIB;
            receiveLib = KAIA_RECEIVE_LIB;
            srcEid = KAIA_EID;
            gracePeriod = uint32(0);
            dvn1 = KAIA_DVN1;
            dvn2 = KAIA_DVN2;
            executor = KAIA_EXECUTOR;
            eid0 = KAIA_EID;
            eid1 = BASE_EID;
            usdt = KAIA_USDT;
            wNative = KAIA_WKAIA;
            dexRouter = KAIA_DEX_ROUTER;
            chainName = "KAIA";
        } else if (block.chainid == 1284) {
            endpoint = GLMR_LZ_ENDPOINT;
            sendLib = GLMR_SEND_LIB;
            receiveLib = GLMR_RECEIVE_LIB;
            srcEid = GLMR_EID;
            gracePeriod = uint32(0);
            dvn1 = GLMR_DVN1;
            dvn2 = GLMR_DVN2;
            executor = GLMR_EXECUTOR;
            eid0 = GLMR_EID;
            eid1 = BASE_EID;
            usdt;
            wNative;
            dexRouter;
            chainName = "GLMR";
        } else if (block.chainid == 1001) {
            chainName = "KAIA_TESTNET";
            endpoint = KAIA_TESTNET_LZ_ENDPOINT;
            sendLib = KAIA_TESTNET_SEND_LIB;
            receiveLib = KAIA_TESTNET_RECEIVE_LIB;
            srcEid = KAIA_TESTNET_EID;
            gracePeriod = uint32(0);
            dvn1 = KAIA_TESTNET_DVN1;
            dvn2 = KAIA_TESTNET_DVN2;
            executor = KAIA_TESTNET_EXECUTOR;
            eid0 = KAIA_TESTNET_EID;
            eid1 = BASE_TESTNET_EID;
            usdt = KAIA_TESTNET_MOCK_USDT;
            wNative = KAIA_TESTNET_MOCK_WKAIA;
            weth = KAIA_TESTNET_MOCK_WETH;
            dexRouter = KAIA_TESTNET_MOCK_DEX;
            oapp = KAIA_TESTNET_USDT_OFT_ADAPTER;
            oapp2 = KAIA_TESTNET_WKAIA_OFT_ADAPTER;
            oapp3 = KAIA_TESTNET_WETH_OFT_ADAPTER;
        } else if (block.chainid == 5003) {
            chainName = "MANTLE_TESTNET";
            endpoint = MANTLE_TESTNET_LZ_ENDPOINT;
            sendLib = MANTLE_TESTNET_SEND_LIB;
            receiveLib = MANTLE_TESTNET_RECEIVE_LIB;
            srcEid = MANTLE_TESTNET_EID;
            gracePeriod = uint32(0);
            dvn1 = MANTLE_TESTNET_DVN1;
            dvn2 = MANTLE_TESTNET_DVN2;
            executor = MANTLE_TESTNET_EXECUTOR;
            eid0 = MANTLE_TESTNET_EID;
            eid1 = BASE_TESTNET_EID;
            usdt = MANTLE_TESTNET_MOCK_USDT;
            usdc = MANTLE_TESTNET_MOCK_USDC;
            wNative = MANTLE_TESTNET_MOCK_WMNT;
            weth = MANTLE_TESTNET_MOCK_WETH;
            wbtc = MANTLE_TESTNET_MOCK_WBTC;
            dexRouter = MANTLE_TESTNET_MOCK_DEX;
            oapp;
            oapp2;
            oapp3;
        }
    }
}
