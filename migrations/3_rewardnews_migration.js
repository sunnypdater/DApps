const RewardContract = artifacts.require("StakingNewsRewards")

const tokenAddress = '0x751eFC89D4E6Be9c215e76dCcC65f2C03E387118'
const r_tokenAddress = '0x751eFC89D4E6Be9c215e76dCcC65f2C03E387118'

module.exports = function (deployer) {
  deployer.deploy(RewardContract, r_tokenAddress, r_tokenAddress);
};
