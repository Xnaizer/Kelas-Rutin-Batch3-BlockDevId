// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract DigitalWalletKampus {
    mapping(address => uint256) public balances;
    address public admin;
    
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    
    constructor() {
        admin = msg.sender;
    }
    
    function deposit() public payable {
        require(msg.value > 0, "Amount harus lebih dari 0");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    
    // TODO: Implementasikan withdraw function
    function withdraw (uint256 _amount) public payable{
        require(balances[msg.sender] > 0, "balance tidak cukup");
        require(_amount > 0, "Input a correct amount!");

        balances[msg.sender] -= _amount;
        payable (msg.sender).transfer(_amount);

        emit Withdrawal(msg.sender, _amount);
    }

    // TODO: Implementasikan transfer function

    function transfer(address _from, address _to, uint256 _amount) public {
        require(balances[_from] > 0, "Balance tidak cukup!");
        require(_amount > 0, "Input Amount yang bener!");
        require(address(0) != _from, "Invalid Address");
        require(address(0) != _to, "Invalid Address");

        balances[_from] -= _amount;
        balances[_to] += _amount;

        emit Transfer(msg.sender, _to, _amount);
    }

    // TODO: Tambahkan access control

    // modifier onlyOwner {
    //     require(admin == msg.sender, "only admin can call this function!");
    //     _;
    // }

    function accessControl(address _user, uint256 _amount) public payable {
        require(balances[_user] > 0, "Balance tidak cukup!");

        if(msg.sender == admin) {
            balances[_user] -= _amount;
            payable (_user).transfer(_amount);

            emit Withdrawal(_user, _amount);
        }
    }
}