// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// This contract allows users to stake their ERC20 tokens and receive rewards per second.

contract StakingContract {
    // Mapping to store user stakes
    mapping (address => uint256) public userStakes;

    // Reward pool
    uint256 public rewardPool;

    // Function to allow users to stake their ERC20 tokens
    function stake(uint256 amount) public {
        // Update user stake
        userStakes[msg.sender] += amount;
        // Update reward pool
        rewardPool += amount;
    }

    // Function to allow users to unstake their ERC20 tokens
    function unstake(uint256 amount) public {
        // Check if user has enough tokens staked
        require(userStakes[msg.sender] >= amount);
        // Update user stake
        userStakes[msg.sender] -= amount;
        // Update reward pool
        rewardPool -= amount;
    }

    // Function to calculate rewards per second
    function calculateRewardsPerSecond() public view returns (uint256) {
        // Calculate total staked tokens
        uint256 totalStakedTokens = 0;
        for (address user in userStakes) {
            totalStakedTokens += userStakes[user];
        }
        // Calculate rewards per second
        return rewardPool / totalStakedTokens;
    }
}