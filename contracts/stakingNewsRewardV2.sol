// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./IERC20.sol";

contract StakingNewsRewardsV2 {
    IERC20 public rewardsToken;
    IERC20 public stakingToken;

    uint public rewardRate = 100;
    uint public lastUpdateTime;
    uint public rewardPerTokenStored;
    mapping(address => mapping(address => uint) ) public sheetLastUpdateTime;
    mapping(address => uint) public sheetRewardPerTokenStored;
    mapping(address => uint) public sheetRewardPooling;

    mapping(address => uint) public userRewardPerTokenPaid;
    mapping(address => mapping(address => uint) ) public userSheetRewardPerTokenPaid;

    mapping(address => uint) public rewards;
    mapping(address => mapping(address => uint) ) public sheetRewards;

    uint public _totalSupply;
    uint public _totalReward;

    mapping(address => uint) public _totalSheetSupply;
    mapping(address => uint) public _balances;
    mapping(address => mapping(address => uint) ) public _balancesSheet;

    constructor(address _stakingToken, address _rewardsToken) {
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
    }

    // ***************************************************************************
    // ***************************************************************************
    // ***************************************************************************

    function _afterTokenTransfer(
        address account,
        address sheet
    ) internal {

        sheetRewards[account][sheet] += sheetEarnedX(account, sheet);
        // userSheetRewardPerTokenPaid[account][sheet] = sheetRewardPerTokenStored[sheet];
        sheetLastUpdateTime[account][sheet] = block.timestamp;

    }

    // ***************************************************************************
    // ***************************************************************************
    // ***************************************************************************

    function sheetEarnedX(address account, address sheet) public view returns (uint) {

        if (sheetRewardPooling[sheet] == 0) {
            return 0;
        }
        return ((block.timestamp - sheetLastUpdateTime[account][sheet]) * rewardRate * 1e18) / sheetRewardPooling[sheet];

    }

    // ***************************************************************************
    // ***************************************************************************
    // ***************************************************************************
    
    function stakeSheet(address sheet, uint _amount) external {
        _totalSupply += _amount;
        _balances[msg.sender] += _amount;
        _totalSheetSupply[sheet] += _amount;
        _balancesSheet[msg.sender][sheet] += _amount;

        // stakingToken.transferFrom(msg.sender, sheet, _amount);
        stakingToken.transferFrom(msg.sender, address(this), _amount);

        _afterTokenTransfer(msg.sender, sheet);
        
    }

    function withdrawSheet(address sheet, uint _amount) external {
        _totalSupply -= _amount;
        _totalSheetSupply[sheet] -= _amount;
        _balances[msg.sender] -= _amount;
        _balancesSheet[msg.sender][sheet] -= _amount;

        stakingToken.approve(sheet, _amount);
        // stakingToken.transferFrom(sheet, msg.sender, _amount);
        stakingToken.transfer(msg.sender, _amount);

    }

    function getRewardSheet(address sheet) external {
        // uint reward = rewards[msg.sender];
        // rewardsToken.transfer(msg.sender, reward);

        uint reward = sheetRewards[msg.sender][sheet];
        require(_totalSheetSupply[sheet] >= reward, "Reward pooling is not Enough");
        sheetRewards[msg.sender][sheet] = 0;
        // rewardsToken.transferFrom(sheet, msg.sender, reward);
        
        rewardsToken.transfer(msg.sender, reward);

    }

    // ***************************************************************************
    // ***************************************************************************
    // ***************************************************************************

    function setSupply(address sheet, uint _amount) external {

        stakingToken.transferFrom(msg.sender, address(this), _amount);
        sheetRewardPooling[sheet] += _amount ;

    }

    // ***************************************************************************
    // ***************************************************************************
    // ***************************************************************************

    function totalSupply()
        public
        view
        returns (uint256)
    {
        return _totalSupply;
    }

    function balanceStakeOf()
        public
        view
        returns (uint256)
    {
        return _balances[msg.sender];
    }

    function RewardPooling(address sheet)
        public
        view
        returns (uint256)
    {
        return sheetRewardPooling[sheet];
    }

    function totalSupplySheet(address sheet)
        public
        view
        returns (uint256)
    {
        return _totalSheetSupply[sheet];
    }

    function balanceStakeOfSheet(address sheet)
        public
        view
        returns (uint256)
    {
        return _balancesSheet[msg.sender][sheet];
    }

    function rewardSheet(address sheet)
        public
        view
        returns (uint256) 
    {
        return sheetRewards[msg.sender][sheet];
    }

    function rewardPooling(address sheet)
        public
        view
        returns (uint256) 
    {
        return sheetRewardPooling[sheet];
    }

    function TimeSpending(address sheet)
        public
        view
        returns (uint256) 
    {
        return sheetLastUpdateTime[msg.sender][sheet];
    }

    function TimeNow()
        public
        view
        returns (uint256) 
    {
        return block.timestamp;
    }

}