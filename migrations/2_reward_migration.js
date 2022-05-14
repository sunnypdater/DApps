const RewardContract = artifacts.require("StakingRewards")

const tokenAddress = '0x751eFC89D4E6Be9c215e76dCcC65f2C03E387118'

module.exports = function (deployer) {
  deployer.deploy(RewardContract, tokenAddress, tokenAddress);
};
