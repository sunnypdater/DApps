const Migrations = artifacts.require("Migrations");
const ERC20 = artifacts.require("SunnyERC20")

const tokenName = 'SunnyPdaterCoin'
const tokenSymbol = 'SPC'
const tokenDecimals = 18
const initialSupply = (10e22).toString()

module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(ERC20, web3.utils.toBN("10000000000000000000000000000"), tokenName, tokenDecimals, tokenSymbol);
};
