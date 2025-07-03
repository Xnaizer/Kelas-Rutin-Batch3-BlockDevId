// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title CampusCredit
 * @dev ERC-20 token untuk transaksi dalam kampus
 * Use cases:
 * - Pembayaran di kafetaria
 * - Biaya printing dan fotokopi
 * - Laundry service
 * - Peminjaman equipment
 */
contract CampusCredit is ERC20, ERC20Burnable, Pausable, AccessControl {
    // TODO: Define role constants
    // bytes32 public constant DEFAULT_OWNER = keccak256("DEFAULT_ADMIN");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    // Additional features untuk kampus
    mapping(address => uint256) public dailySpendingLimit;
    mapping(address => uint256) public spentToday;
    mapping(address => uint256) public lastSpendingReset;
    
    // Merchant whitelist
    mapping(address => bool) public isMerchant;
    mapping(address => string) public merchantName;

    constructor(uint256 _initialSupply) ERC20("Campus Credit", "CREDIT") {
        // TODO: Setup roles
        // Hint:
        // 1. Grant DEFAULT_ADMIN_ROLE ke msg.sender
        // 2. Grant PAUSER_ROLE ke msg.sender
        // 3. Grant MINTER_ROLE ke msg.sender
        // 4. Consider initial mint untuk treasury

        _grantRole(DEFAULT_ADMIN_ROLE,msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);

        _mint(msg.sender, _initialSupply * (10**18));  
    }

    // modifier OnlyPause() {
    //     require(hasRole(PAUSER_ROLE),"Only Pausable Role Can Use Pause");
    //     _;
    // }

    /**
     * @dev Pause all token transfers
     * Use case: Emergency atau maintenance
     */
    function pause() public onlyRole(PAUSER_ROLE)  {
        // TODO: Implement dengan role check
        // Only PAUSER_ROLE can pause
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE){
        // TODO: Implement unpause
        _unpause();
    }

    /**
     * @dev Mint new tokens
     * Use case: Top-up saldo mahasiswa
     */
    function mint(address _to, uint256 _amount) public onlyRole(MINTER_ROLE){
        // TODO: Implement dengan role check
        // Only MINTER_ROLE can mint
        // Consider adding minting limits

        require(_amount > 0, "Masukkan amount dengan benar!");
        require(_to != address(0), "Masukkan address dengan benar!");
        
        if(_amount < 10000 * (10**18)){
            _mint(_to, _amount * (10**18));
        } else {
            revert("Jumlah token yang dimint berlebihan!!");
        }
    }

    /**
     * @dev Register merchant
     * Use case: Kafetaria, toko buku, laundry
     */
    function registerMerchant(address _merchant, string memory _name) 
        public onlyRole(DEFAULT_ADMIN_ROLE) 
    {
        // TODO: Register merchant untuk accept payments
        require(_merchant != address(0), "Masukkan address dengan benar!");
        require(bytes(_name).length > 0, "Masukkan nama dengan benar!");

        merchantName[_merchant] = _name;
        isMerchant[_merchant] = true;

    }

    /**
     * @dev Set daily spending limit untuk mahasiswa
     * Use case: Parental control atau self-control
     */
    function setDailyLimit(address _student, uint256 _limit) 
        public onlyRole(DEFAULT_ADMIN_ROLE) 
    {
        // TODO: Set spending limit
        require(_student != address(0), "Masukkan address dengan benar!");
        require(_limit > 0, "Masukkan limit dengan benar!");

        dailySpendingLimit[_student] = _limit;


    }

    /**
     * @dev Transfer dengan spending limit check
     */
    function transferWithLimit(address _to, uint256 _amount) public {
        // TODO: Check daily limit before transfer
        // Reset limit if new day
        // Update spent amount
        // Then do normal transfer
        require(_to != address(0), "Masukkan address dengan benar!");
        require(_amount > 0, "Masukkan amount dengan benar!");


        if (spentToday[msg.sender] > dailySpendingLimit[msg.sender]) {
            revert("Kamu sudah melebihi Limit Harian!");
        }


        if(block.timestamp > lastSpendingReset[msg.sender] + 1 days) {
            spentToday[msg.sender] = 0;
        }

        spentToday[msg.sender] += _amount;
        _transfer(msg.sender,_to, _amount);
        lastSpendingReset[msg.sender] = block.timestamp;

    }

    // /**
    //  * @dev Override _beforeTokenTransfer untuk add pause functionality
    //  */
    function _update(
        address _from,
        address _to,
        uint256 _amount
    ) internal override(ERC20) {
        // TODO: Add pause check
        // super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "Token transfers paused");
        // require(_from != address(0), "Masukkan address dengan benar!");
        require(_to != address(0), "Masukkan addres dengan benar!");
        require(_amount > 0, "Masukkan amount dengan benar!");

        super._update(_from, _to, _amount );
    }

    // /**
    //  * @dev Cashback mechanism untuk encourage usage
    //  */
    uint256 public cashbackPercentage = 2; // 2%
    
    function transferWithCashback(address _merchant, uint256 _amount) public {
        // TODO: Transfer to merchant dengan cashback ke sender
        // Calculate cashback
        // Transfer main amount
        // Mint cashback to sender
        require(_merchant != address(0), "Masukkan address dengan benar!" );
        require(_amount > 0, "Masukkan amount dengan benar!");

        _transfer(msg.sender, _merchant, _amount * (1 - cashbackPercentage / 100));

    }
}