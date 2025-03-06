// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SimpleStaking {
    IERC20 public stakingToken;
    uint256 public constant REWARD_RATE = 1e16; // 1% в день (примерно)
    
    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public lastStakeTime;
    mapping(address => uint256) public rewards;

    constructor(address _stakingToken) {
        stakingToken = IERC20(_stakingToken);
    }

    function stake(uint256 amount) external {
        _updateReward(msg.sender);
        stakingToken.transferFrom(msg.sender, address(this), amount);
        stakedBalance[msg.sender] += amount;
        lastStakeTime[msg.sender] = block.timestamp;
    }

    function withdraw(uint256 amount) external {
        require(stakedBalance[msg.sender] >= amount, "Insufficient balance");
        _updateReward(msg.sender);
        stakedBalance[msg.sender] -= amount;
        stakingToken.transfer(msg.sender, amount);
    }

    function claimReward() external {
        _updateReward(msg.sender);
        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        stakingToken.transfer(msg.sender, reward);
    }

    function _updateReward(address user) internal {
        uint256 timePassed = block.timestamp - lastStakeTime[user];
        rewards[user] += stakedBalance[user] * timePassed * REWARD_RATE / 1e18;
        lastStakeTime[user] = block.timestamp;
    }

    function getPendingReward(address user) public view returns(uint256) {
        uint256 timePassed = block.timestamp - lastStakeTime[user];
        return rewards[user] + (stakedBalance[user] * timePassed * REWARD_RATE / 1e18);
    }
}
