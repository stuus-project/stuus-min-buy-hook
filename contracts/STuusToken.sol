// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @notice Fixed-supply STuus token. There is no mint, tax, blacklist, or pause function.
contract STuusToken is ERC20 {
    uint256 public constant INITIAL_SUPPLY = 100_000_000_000 ether;

    constructor(address recipient) ERC20("STuus", "STUUS") {
        require(recipient != address(0), "STuus: zero recipient");
        _mint(recipient, INITIAL_SUPPLY);
    }
}
