// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract rewardToken is ERC20{
    error InvalidInput();

constructor()ERC20("Stake Token", "STAKE"){

    _mint(msg.sender,1000000*10**18);
}

function mintReward(uint amount)external {
    if(amount == 0) revert InvalidInput();
    _mint(msg.sender,amount);
}
}
