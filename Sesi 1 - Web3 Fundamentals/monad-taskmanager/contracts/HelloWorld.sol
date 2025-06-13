// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

contract HelloWorld {
    string public say = "Hello World";

    function setSay(string memory _newSay) public {
        say = _newSay;
    }

    function getSay() public view returns (string memory){
        return say;
    }
}
