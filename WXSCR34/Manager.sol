/**
 * @title Fee Manager
 * @dev FeeManager contract
 *
 * @author Felix Götz - <AUREUM VICTORIA>
 * on behalf of Securus Technologies LLC
 *
 * SPDX-License-Identifier: GNU GPLv2
 *
 **/

pragma solidity ^0.6.12;

import "./Ownable.sol";
import "./MinterRole.sol";
import "./IDontTrigger.sol";
import "./IWhitelist.sol";
import "./IBlacklist.sol";
import "./IStrategy.sol";
import "./IZeroFee.sol";
import "./SafeMath.sol";

contract Manager is Ownable{
    using SafeMath for uint256;

    IWhitelist public whitelist;
    IBlacklist public blacklist;
    IStrategy public strategy;
    IDontTrigger public dontTrigger;
    IZeroFee public zeroFee;

    bool public strategyTrigger;
    uint256 public nextTrigger;
    uint256 public triggerTime;
    uint256 public triggerAmount;
    uint256 public fee;
    address public feeReceiver;
    uint256 public freeMintSupply;
    uint256 public safetyTimelock;
    uint256 public blockTimelock;
    address public newStrategyContract;

   /**  
    * @dev set the {triggerAmount} for the trigger. 
    * 
    * Says from which coin transfer size the trigger should be on. 
    * 
    */
    function setTriggerAmount(uint256 _triggerAmount) external onlyOwner {
        triggerAmount = _triggerAmount;
    }

   /**  
    * @dev set the {fee} for transfers. 
    *
    * how many fees should be taken from a transaction 
    *
    * Requirements:
    *
    * - only `owner` can update the `fee`
    * - fee can only be lower then 10%
    *   
    */
    function setFee(uint256 _fee) public onlyOwner {
    require(_fee <= 1000, "too high");
        fee = _fee;
    }
    
    /**  
    * @dev set the {StrategyTrigger} for transfers. 
    *
    * The `owner` decides whether the `StrategyTrigger` is activated or deactivated. 
    *   
    * Requirements:
    *
    * - only `owner` can update the `strategyTrigger`
    */
    function setStrategyTrigger(bool _strategyTrigger) public onlyOwner {
        strategyTrigger = _strategyTrigger;
    }
    
   /**  
    * @dev set the {feeReceiver} for transfers. 
    *
    * The `owner` decides which address the fee should get.
    *   
    * Requirements:
    *
    * - only `owner` can update the `feeReceiver`
    */
    function setfeeReceiver(address _feeReceiver) public onlyOwner {
        feeReceiver = _feeReceiver;
    }
    
   /**  
    * @dev set the {nextTrigger} for contract trigger.
    *
    * The owner decides after which blocktime the strategy may be executed again.
    *   
    * Requirements:
    *
    * - only `owner` can update the `nextTrigger`
    */
    function setNextTrigger(uint256 _nextTrigger) public onlyOwner {
        nextTrigger = _nextTrigger;
    }

    /**  
    * @dev set the {freeMintSupply} that the minter can create new coins.
    *
    * The owner decides how many new coins may be created by the minter. 
    *   
    * Requirements:
    *
    * - only `owner` can update the `strategyTfreeMintSupplyrigger`
    */
    function setFreeMintSupply(uint256 _freeMintSupply) public onlyOwner {
        freeMintSupply = _freeMintSupply;
    }

    /**  
    * @dev set the {blockTimelock} to define block waiting times.
    *
    * This function ensures that functions cannot be executed immediately
    * but have to wait for a defined block time. 
    *
    * Requirements:
    *
    * - only `owner` can update the blockTimelock
    * - blockTimelock can only be bigger them last blockTimelock
    * - blockTimelock lower than 30 days
    *
    */
    function setBlockTimelock(uint256 _setBlockTimelock)
        public
        onlyOwner
    {
    require(blockTimelock < _setBlockTimelock, "SAFETY FIRST || blockTimelock can only be bigger them last blockTimelock");
    require(_setBlockTimelock <= 864000, "SAFETY FIRST || blockTimelock greater than 30 days");
    blockTimelock = _setBlockTimelock;

    }

    /**
     * @dev Outputs the remaining time of the BlockTimelock
     */
    function checkRemainingBlockTimelock() public view returns (uint256) {

       uint256 RemainingBlockTimelock = safetyTimelock.sub(block.timestamp);

        return RemainingBlockTimelock;
    }

    /**
     * @dev Sets `external smart contracts` 
     *
     * These functions serve to be flexible and to connect further automated systems 
     * that will require an update in the long term. 
     *
     * Requirements:
     *
     * - only `owner` can update the external smart contracts
     * - `external smart contracts` must be correct and work 
     */
    function updateZeroFeerContract(address _ZeroFeeContract)
        public
        onlyOwner
    {
        zeroFee = IZeroFee(_ZeroFeeContract);
    }

    function updateDontTriggerContract(address _dontTriggerContract)
        public
        onlyOwner
    {

        dontTrigger = IDontTrigger(_dontTriggerContract);

    }

    function updateWhitelistContract(address _whitelistContract)
        public
        onlyOwner
    {
        whitelist = IWhitelist(_whitelistContract);
    }

    function updateBlacklistContract(address _blacklistContract)
        public
        onlyOwner
    {
        blacklist = IBlacklist(_blacklistContract);
    }

    /**
     * @dev Sets `external strategy smart contract` 
     *
     * This function shows that the owner wants to update 
     * the `StrategyContract` and activates the `safetyTimelock`.
     *
     * the new `StrategyContract` is now shown to everyone
     * and people can make their necessary decisions from it.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - only `owner` can update the external smart contracts
     * - `external smart contracts` must be correct and work 
     */
    function updateStrategyContract(address _strategyContract)
        public
        onlyOwner
    {

        newStrategyContract = _strategyContract; 
        safetyTimelock = block.timestamp.add(blockTimelock);

    }

    /**
     * @dev Activate new `external strategy smart contract` 
     *
     * After the safetyTimelock time has expired,
     * the owner can now activate his submitted `external strategy smart contract` 
     * and resets the `blockTimelock` to 1 day.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - only `owner` can update the external smart contracts
     * - `external smart contracts` must be correct and work 
     */
    function activateNewStrategyContract()
        public
        onlyOwner
    {
        require(safetyTimelock < block.timestamp , "SAFETY FIRST || safetyTimelock smaller than current block");
        strategy = IStrategy(newStrategyContract);
        blockTimelock = 28800; //Set the update time back to 1 day in case there is an error and you need to intervene quickly.

    }
    
}