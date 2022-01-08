/**
 * @title Interface dont Trigger
 * @dev IDontTrigger contract
 *
 * @author Felix Götz - <AUREUM VICTORIA>
 * on behalf of Securus Technologies LLC
 *
 * SPDX-License-Identifier: GNU GPLv2
 *
 **/

pragma solidity ^0.6.12;

interface IDontTrigger {
 function isDontTrigger(address _address) external view returns(bool);
}
