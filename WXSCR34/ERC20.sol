/**
 * @title ERC20
 * @dev ERC20 contract
 *
 * @author Felix Götz - <AUREUM VICTORIA>
 * on behalf of Securus Technologies LLC
 *
 * SPDX-License-Identifier: GNU GPLv2
 *
 * File @openzeppelin/contracts/utils/Address.sol
 *
 **/

pragma solidity ^0.6.12;

import "./Context.sol";
import "./IERC20.sol";
import "./SafeMath.sol";
import "./Pausable.sol";
import "./Manager.sol";

contract ERC20 is Context, IERC20, Pausable, Manager, MintRole{
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint256 private _decimals;

    bool public statusStoreWhitelist;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: 
     * it does not affect any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint256) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    
     /**
     * @dev See {IERC20-totalSupply} correct tokens.
     */
    function totalSupplyCoins() public view returns (uint256) {
        return _totalSupply.div(10**_decimals);
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor.
     *  Most applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }
    
    /**
     * @dev See {IERC20-transfer}.
     * Send amount sub fee or without fee.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) override external whenNotPaused returns (bool)
    {
        _transfer(_msgSender(), recipient, amount); 
        return true;
    }
    
    /**
     * @dev See {IERC20-transfer}.
     * Send correct amount add fee.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transferCorrectAmount(address recipient, uint256 amount)  external whenNotPaused returns (bool)
    {
        _transferCorrectAmount(_msgSender(), recipient, amount); 
        return true;
    }
    
    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view whenNotPaused virtual override returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public whenNotPaused virtual override returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     * Send amount - fee or without fee.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public whenNotPaused virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount,"ERC20: transfer amount exceeds allowance"));
        return true;
    }
    
    /**
     * @dev See {IERC20-transferFrom}.
     * Send correct amount + fee.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferCorrectAmountFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public whenNotPaused virtual returns (bool) {
        _transferCorrectAmount(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount,"ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Automatically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public whenNotPaused virtual returns (bool){ 
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Automatically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue,"ERC20: decreased allowance below zero"));
        return true;
        
    }

    /**
     * @dev set the whitelist true or false.
     *
     * Requirements:
     *
     * bool `_statusStoreWhitelistIs` can be true or false.
     */
    function statusStoreWhitelistIs(bool _statusStoreWhitelistIs)
        public
        onlyOwner
    {
        statusStoreWhitelist = _statusStoreWhitelistIs;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient` and `feeReceiver`.
     *
     * This is internal function is equivalent to {transfer}, and used also for automatic token fees.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer( //fee off amount
        address sender,
        address recipient,
        uint256 amount
    ) internal whenNotPaused virtual {  // check if contract is not paused
        
        require(whitelist.isWhitelisted(msg.sender) == true && whitelist.isWhitelisted(recipient) == true || statusStoreWhitelist == false || whitelist.statusWhitelist() == false, "not Whitelisted"); // sender or/and recipient not on the whitelist // whitelist is activ
        require(blacklist.isBlacklisted(msg.sender) == false || blacklist.isBlacklisted(recipient) == false, "you are Blacklisted"); // sender or/and recipient is on the blacklist

   if (zeroFee.isZeroFeeSender(msg.sender) == false && fee > 0 || zeroFee.isZeroFeeRecipient(recipient) && fee > 0 ){ // check if the sender or the recipient is not a zerofee sender and then fee is more them 0
       uint256 feeamount = amount.div(10000).mul(fee);                                                  // set the feeamount what the sender must pay
        _balances[sender] = _balances[sender].sub(amount,"ERC20: transfer amount exceeds balance");     // sub send amount from the sender balances
        _balances[recipient] = _balances[recipient].add(amount.sub(feeamount));                         // add the send amount to the recipient and sub the feeamount
        _balances[feeReceiver] = _balances[feeReceiver].add(feeamount);                                 // add the fee to the feeReceiver
        emit Transfer(sender, recipient, amount.sub(feeamount));                                        // transfer from sender to recipient the amount sub feeamount
        emit Transfer(sender, feeReceiver, feeamount);                                                  // transfer from sender to feeReceiver the feeamount
            
        } else {                                                                                        
        
        _balances[sender] = _balances[sender].sub(amount,"ERC20: transfer amount exceeds balance");     // sub send amount from the sender balances
        _balances[recipient] = _balances[recipient].add(amount);                                        // add the send amount to the recipient
        
        emit Transfer(sender, recipient, amount);                                                       // transfer from sender to recipient
    } 

      if (strategyTrigger == true){                                                                     // is strategy trigger on or off
            if (amount > triggerAmount){                                                                // is your send amount bigger them the trigger amount 
                if (triggerTime < block.timestamp){                                                     // is time for a trigger
                   if (dontTrigger.isDontTrigger(msg.sender) == false){                                 // can this sender trigger (some contracts shouldn't trigger)
                
        triggerTime = block.timestamp.add(nextTrigger);                                                 // set the next trigger time

        strategy.contractTrigger();                                                                     // trigger the strategy
        
        }}}}
        
    } 
    
    /**
     * @dev Moves tokens `amount` from `sender` to `recipient` and `feeReceiver`.
     *
     * This is internal function is equivalent to {transfer}, and used also for automatic token fees.
     *
     * Emits a {Transfer} event with fee on the amount.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount` + `fee`.
     */                                                                                             
        function _transferCorrectAmount( //fee on amount
        address sender,
        address recipient,
        uint256 amount
    ) internal whenNotPaused virtual {

        require(whitelist.isWhitelisted(msg.sender) == true && whitelist.isWhitelisted(recipient) == true || statusStoreWhitelist == false || whitelist.statusWhitelist() == false, "not Whitelisted"); // sender or/and recipient not on the whitelist // whitelist is activ
        require(blacklist.isBlacklisted(msg.sender) == false  || blacklist.isBlacklisted(recipient) == false, "you are Blacklisted"); // sender or/and recipient is on the blacklist

        if (zeroFee.isZeroFeeSender(msg.sender) == false && fee > 0 || zeroFee.isZeroFeeRecipient(recipient) && fee > 0 ){ // check if the sender or the recipient is not a zerofee sender and then fee is more them 0   
        uint256 feeamount = amount.div(10000).mul(fee);                                                 // set the feeamount / What the sender have to pay
        _balances[sender] = _balances[sender].sub(amount.add(feeamount),"ERC20: transfer amount exceeds balance");  // sub send amount and add the feeamount from the sender balances
        _balances[recipient] = _balances[recipient].add(amount.div(feeamount));                         // add the send amount to the recipient and sub the feeamount
        _balances[feeReceiver] = _balances[feeReceiver];                                                // add the fee to the feeReceiver
        
        emit Transfer(sender, recipient, amount);                                                       // transfer from sender to recipient the amount sub feeamount
        emit Transfer(sender, feeReceiver, feeamount);    
            
        } else {                                                                                       

        _balances[sender] = _balances[sender].sub(amount,"ERC20: transfer amount exceeds balance");     // sub send amount from the sender balances
        _balances[recipient] = _balances[recipient].add(amount);                                        // add the send amount to the recipient

        emit Transfer(sender, recipient, amount);                                                       // transfer from sender to recipient
    } 

      if (strategyTrigger == true){                                                                     // is strategy trigger on or off
            if (amount > triggerAmount){                                                                // is your send amount bigger them the trigger amount 
                if (triggerTime < block.timestamp){                                                     // it is time for a trigger
                   if (dontTrigger.isDontTrigger(msg.sender) == false){                                 // can this sender trigger (some contracts shouldn't trigger)
                
        triggerTime = block.timestamp.add(nextTrigger);                                                 // set the next trigger time

        strategy.contractTrigger();                                                                     // trigger the strategy
        
        }}}}

    }
    
    /** @dev Emits a {burn} event and set the BlackFund address to 0.
     *
     * Requirements:
     *
     * - only `onlyMinter` can trigger the destroyBlackFunds
     * - `_blackListedUser` cannot be the zero address.
     * - `_blackListedUser` is on the Blacklisted.
     * 
     */
        function destroyBlackFunds (address _blackListedUser) public onlyMinter {
        require(blacklist.isBlacklisted(_blackListedUser) == true , "is not Blacklisted");                         // sender on the blacklist
        uint dirtyFunds = balanceOf(_blackListedUser);
        _balances[_blackListedUser] = 0;
        _totalSupply.sub(dirtyFunds);
        DestroyedBlackFunds(_blackListedUser, dirtyFunds);
    }
     event DestroyedBlackFunds(address _blackListedUser, uint _balance);
    
    /** @dev Moves tokens `amount` from `sender` to `recipient`.
     * 
     * Emits a Admin {Transfer} event on the amount.
     *
     * Requirements:
     *
     * - only `onlyMinter` can trigger the redemFunds
     * - `sender`must be on the blacklist.
     * 
     */
    function redemFunds (address sender, address recipient, uint256 amount) public onlyMinter {
        require(blacklist.isBlacklisted(sender) == true , "is not Blacklisted");                         // sender on the blacklist
        _balances[sender] = _balances[sender].sub(amount);                                               // sub send amount from the `sender` balances
        _balances[recipient] = _balances[recipient].add(amount);                                         // add the send `amount` to the `recipient`
     
         emit Transfer(sender, recipient, amount);                                                       // Transfer from `sender` to `recipient` the `amount`
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `freeSupply`must be larger than the amount to be created.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        require(freeMintSupply >= amount, "ERC20: no more free supply");
        freeMintSupply = freeMintSupply.sub(amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    
    /**
     * Purpose:
     * onlyMinter mint tokens on the _to address
     *
     * @param _amount - amount of newly issued tokens
     * @param _to - address for the new issued tokens
     */
    function mint(address _to, uint256 _amount) public onlyMinter {
        _mint(_to, _amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    
    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal whenNotPaused virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}