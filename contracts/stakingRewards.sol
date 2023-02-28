// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// This contract allows users to stake their ERC20 tokens and receive rewards per second.
import "./stakingToken.sol";

contract StakingContract {
    error Forbidden();
    error InvalidInput();
    error InsufficientBalance();
    error ApproveOrAddAllowance();
    error NoRewards();

    IRewards private rewardsCoin;

    address private owner;
    uint256 public stepID;
    uint256 public amtToTreasury;

    // Mapping to store user stakes
    struct StakingInfo{
        uint amountStaked;
        uint stepStakedOn;
    }
    struct StepInfo {
        uint treasury;
        uint rewardsPerSec;
        uint totalEarned;
        uint startTime;
        uint userAmt;
        uint totalStaked;

    }
    mapping (address => StakingInfo) public userStakes;
    mapping (uint => StepInfo) public steps;
    
    
    constructor(address _token){
        if(_token == address(0)) revert InvalidInput();
        owner = msg.sender;
        stepID = 0;
        rewardsCoin = IRewards(_token);
    }
    modifier onlyOwner {
        if(msg.sender!=owner) revert Forbidden();
        _;
    }

    function fillRewards(uint amount) external {
        if(amount==0) revert InvalidInput();
        amtToTreasury+=amount;

    }
    function stake(uint _amount) external {
        if(_amount == 0 ) revert InvalidInput();
        address caller = msg.sender;
        uint approvedAllowance = rewardsCoin.allowance(caller,address(this));
        if(rewardsCoin.balanceOf(caller)<_amount) revert InsufficientBalance();
        if(approvedAllowance<100000) revert ApproveOrAddAllowance();
        
        rewardsCoin.transferFrom(caller, address(this), _amount);
        _update(_amount,0);
        userStakes[caller].amountStaked = _amount;
        userStakes[caller].stepStakedOn = stepID;
        
    }
    function unstake() external{
        address caller = msg.sender;
        uint rewardsDue = totalDueRewards(caller);
        uint stakedAmt = userStakes[caller].amountStaked;
        if (rewardsDue > 0)
         {
            rewardsCoin.mintReward(caller, rewardsDue);
        }
        rewardsCoin.transfer(caller,stakedAmt);
        delete userStakes[caller];

        _update(0, stakedAmt);

    }
    function claim() external {
        address caller = msg.sender;

        uint rewardsDue = totalDueRewards(caller);
        if (rewardsDue>0) {
            rewardsCoin.mintReward(caller,rewardsDue);
        } else {
            revert NoRewards();
        }
    }
    function totalDueRewards(address _address) public view returns (uint) {
        StakingInfo storage details = userStakes[_address];
        uint totalRewards= 0;
        uint id = stepID;
        //accumulate rewards from previous steps
        for(uint i = details.stepStakedOn; i<=id; ) {
            totalRewards+= (details.amountStaked * steps[i].totalEarned) / steps[i].totalStaked;
         unchecked {
            i++;
        }
         }
     //add current step's reward
        totalRewards+= ((details.amountStaked * steps[id].rewardsPerSec)/steps[id].totalStaked) * (block.timestamp - steps[id].startTime);
    return totalRewards;
    }


    function _update(uint _amtStaked, uint _amtUnstaked)internal {
            StepInfo memory laststepinfo = steps[stepID];
            StepInfo storage newstep = steps[++stepID];

            uint newTreasury = laststepinfo.treasury + amtToTreasury;

//first deposit
            if(laststepinfo.totalStaked == 0 && _amtStaked>0){
              //  newstep.userAmt = _amtStaked;
                newstep.treasury = newTreasury;
                newstep.totalStaked = _amtStaked;
                newstep.rewardsPerSec = newTreasury/100000;
                newstep.startTime = block.timestamp;
            }
//regular deposit
            else if(laststepinfo.totalStaked>0 && _amtStaked>0){
             uint rewarded=(block.timestamp - laststepinfo.startTime) * laststepinfo.rewardsPerSec;
                laststepinfo.totalEarned+=rewarded;

                newstep.totalStaked+=_amtStaked;
                newstep.treasury = newTreasury - rewarded;
                newstep.rewardsPerSec = newstep.treasury/100000;
                newstep.totalStaked=laststepinfo.totalStaked + _amtStaked;
                newstep.startTime = block.timestamp;
            }
  //claim           
            else if(_amtStaked == 0 && _amtUnstaked == 0){
                uint rewarded = (block.timestamp - laststepinfo.startTime) * laststepinfo.rewardsPerSec;
                newstep.treasury = newTreasury - rewarded;

                laststepinfo.totalEarned += rewarded;

                newstep.rewardsPerSec = newstep.treasury/100000;
                newstep.totalStaked = laststepinfo.totalStaked;
                newstep.startTime = block.timestamp;


            }
            else if(_amtStaked==0 &&_amtUnstaked >0){
                uint rewarded = (block.timestamp - laststepinfo.startTime) * laststepinfo.rewardsPerSec;
                newstep.treasury = newTreasury - rewarded;

                laststepinfo.totalEarned = rewarded;

                newstep.totalStaked = laststepinfo.totalStaked - _amtUnstaked;
                newstep.rewardsPerSec = newstep.treasury/100000;
                newstep.startTime = block.timestamp;

            }
    }


}