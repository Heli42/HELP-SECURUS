/**
 * @title Interface Zero Fee
 * @dev IZeroFee contract
 *
 * @author Felix Götz - <AUREUM VICTORIA>
 * on behalf of Securus Technologies LLC
 *
 * SPDX-License-Identifier: GNU GPLv2
 *
 **/

pragma solidity ^0.6.12;

interface IZeroFee {
  function isZeroFeeSender(address _address) external view returns(bool);

  function isZeroFeeRecipient(address _address) external view returns(bool);
}
