/**
 * @title Interface Blacklist
 * @dev IBlacklist contract
 *
 * @author Felix Götz - <AUREUM VICTORIA>
 * on behalf of Securus Technologies LLC
 *
 * SPDX-License-Identifier: GNU GPLv2
 *
 **/

pragma solidity ^0.6.12;

interface IBlacklist {
    function isBlacklisted(address _address) external view returns (bool);
}