// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract ProxyDeployer {
    ERC1967Proxy public proxy;

    function deployProxy(address _implementation, bytes memory _data) public returns (address) {
        proxy = new ERC1967Proxy(_implementation, _data);
        return address(proxy);
    }
}
