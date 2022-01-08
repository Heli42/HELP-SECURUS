/**
 * @title Wrapped Securus Coin
 * @dev WXSCR contract
 *
 * @author Felix Götz - <AUREUM VICTORIA>
 * on behalf of Securus Technologies LLC
 *
 * SPDX-License-Identifier: GNU GPLv2
 *
 **/

pragma solidity ^0.6.12;

import "./ERC20.sol";

contract WXSCR is ERC20 {
     constructor() public ERC20("Wrapped-Securus", "WXSCR") {
    }  
}