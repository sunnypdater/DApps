// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./IERC20.sol";

contract StakingNewsRewards {
    IERC20 public rewardsToken;
    IERC20 public stakingToken;

    uint public rewardRate = 100;
    uint public lastUpdateTime;
    uint public rewardPerTokenStored;
    mapping(address => mapping(address => uint) ) public sheetLastUpdateTime;
    mapping(address => uint) public sheetRewardPerTokenStored;

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

    function rewardPerToken() public view returns (uint) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored +
            (((block.timestamp - lastUpdateTime) * rewardRate * 1e18) / _totalSupply);
    }

    function earned(address account) public view returns (uint) {
        return
            ((_balances[account] *
                (rewardPerToken() - userRewardPerTokenPaid[account])) / 1e18) +
            rewards[account];
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;

        rewards[account] = earned(account);
        userRewardPerTokenPaid[account] = rewardPerTokenStored;
        _;
    }

    // ***************************************************************************
    // ***************************************************************************
    // ***************************************************************************

    function _beforeTokenTransfer(
        address from,
        address sheet
    ) internal sheetUpdateReward(from, sheet) {}

    function _afterTokenTransfer(
        address from,
        address sheet
    ) internal sheetUpdateReward(from, sheet) {}

    // ***************************************************************************
    // ***************************************************************************
    // ***************************************************************************

    function sheetRewardPerToken(address account, address sheet) public view returns (uint) {
        if (_totalSheetSupply[sheet] == 0) {
            return sheetRewardPerTokenStored[sheet];
        }
        return
            sheetRewardPerTokenStored[sheet] +
            (((block.timestamp - sheetLastUpdateTime[account][sheet]) * rewardRate * 1e18) / _totalSheetSupply[sheet]);
    }

    function sheetEarned(address account, address sheet) public view returns (uint) {
        return
            (( _balancesSheet[account][sheet] *
                (sheetRewardPerToken(account, sheet) - userSheetRewardPerTokenPaid[account][sheet])) / 1e18) +
            sheetRewards[account][sheet];
    }

    modifier sheetUpdateReward(address account, address sheet) {
        sheetRewardPerTokenStored[sheet] = sheetRewardPerToken(account, sheet);
        sheetLastUpdateTime[account][sheet] = block.timestamp;

        sheetRewards[account][sheet] = sheetEarned(account, sheet);
        userSheetRewardPerTokenPaid[account][sheet] = sheetRewardPerTokenStored[sheet];
        _;
    }


    // ***************************************************************************
    // ***************************************************************************
    // ***************************************************************************
    
    function stakeSheet(address sheet, uint _amount) external sheetUpdateReward(msg.sender, sheet) {
        _totalSupply += _amount;
        _balances[msg.sender] += _amount;
        _totalSheetSupply[sheet] += _amount;
        _balancesSheet[msg.sender][sheet] += _amount;

        // stakingToken.transferFrom(msg.sender, sheet, _amount);
        stakingToken.transferFrom(msg.sender, address(this), _amount);

        _afterTokenTransfer(msg.sender, sheet);
        
    }

    function withdrawSheet(address sheet, uint _amount) external sheetUpdateReward(msg.sender, sheet) {
        _totalSupply -= _amount;
        _totalSheetSupply[sheet] -= _amount;
        _balances[msg.sender] -= _amount;
        _balancesSheet[msg.sender][sheet] -= _amount;

        stakingToken.approve(sheet, _amount);
        // stakingToken.transferFrom(sheet, msg.sender, _amount);
        stakingToken.transfer(msg.sender, _amount);

    }

    function getRewardSheet(address sheet) external sheetUpdateReward(msg.sender, sheet) {
        // uint reward = rewards[msg.sender];
        // rewardsToken.transfer(msg.sender, reward);

        uint reward = sheetRewards[msg.sender][sheet];
        require(_totalSheetSupply[sheet] >= reward, "Reward pooling is not Enough");
        sheetRewards[msg.sender][sheet] = 0;
        // rewardsToken.transferFrom(sheet, msg.sender, reward);
        
        rewardsToken.transfer(msg.sender, reward);
        _afterTokenTransfer(msg.sender, sheet);

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
        // return sheetEarned(msg.sender, sheet);
    }

    function TimeSpending(address sheet)
        public
        view
        returns (uint256) 
    {
        // return sheetRewards[msg.sender][sheet];
        return sheetLastUpdateTime[msg.sender][sheet];
    }

    function TimeNow()
        public
        view
        returns (uint256) 
    {
        // return sheetRewards[msg.sender][sheet];
        return block.timestamp;
    }

}