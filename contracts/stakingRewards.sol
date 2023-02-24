// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

// This contract allows users to stake their ERC20 tokens and receive rewards per second.

contract StakingContract {
    error Forbidden();


    address private owner;
    uint256 public totalStaked;
    uint256 public rewardPool;

    // Mapping to store user stakes
    struct StakingInfo{
        uint amountStaked;
        uint stepStakedOn;
    }
    struct StepInfo {
        
    }
    mapping (address => StakingInfo) public userStakes;

    
    
    constructor(){
        owner = msg.sender;
    }
    modifier onlyOwner {
        if(msg.sender!=owner) revert Forbidden();
        _;
    }

    function fillRewards(uint amount) {
        
    }
    


}