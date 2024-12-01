// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract GameContract is Ownable(0x50DD541ad540d046E5822a1D5440060D58776eA6) {
    using SafeERC20 for IERC20;
    // CZ4 : https://cz4png.vercel.app | https://t.me/cz4png
    // CZ2049 (FASU) : https://dexscreener.com/ethereum/0x64d52885d4a37926E1f299A9ab248900248933A6

    IERC20 public cz4Token; 
    IERC20 public fasuToken;
    // Total prize amount in CZ4
    uint public prizeAmount;
    // Events
    event PrizeAdded(uint amount);
    event FASUDeposited(address indexed user, uint fasuAmount, uint cz4Reward);

    constructor(address _cz4TokenAddress, address _fasuTokenAddress) 
    {
        cz4Token = IERC20(_cz4TokenAddress);
        fasuToken = IERC20(_fasuTokenAddress);
    }
    // Admin function to add CZ4 to the prize pool
    function addPrize(uint amount) external onlyOwner {
        require(amount > 0, "Prize amount must be greater than zero");
        cz4Token.safeTransferFrom(msg.sender, address(this), amount);
        prizeAmount += amount;

        emit PrizeAdded(amount);
    }


    function depositFASU(uint fasuAmount) external {
        // Depesosits FASU and withdraws
        require(fasuAmount > 0, "Deposit amount must be greater than zero");
        require(prizeAmount > 0, "Prize pool is empty");

        fasuToken.safeTransferFrom(msg.sender, address(this), fasuAmount);
        
        uint randomFactor = (uint(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender))) % 5) + 1;
        uint cz4Reward = (fasuAmount / 1_000_000) * randomFactor;

        require(cz4Reward <= prizeAmount, "Not enough CZ4 in prize pool");
        prizeAmount -= cz4Reward;

        cz4Token.safeTransfer(msg.sender, cz4Reward);

        emit FASUDeposited(msg.sender, fasuAmount, cz4Reward);
    }

    // Admin function to withdraw all funds (ETH and tokens)
    function withdrawFunds() external onlyOwner {
        uint ethBalance = address(this).balance;
        uint cz4Balance = cz4Token.balanceOf(address(this));
        uint fasuBalance = fasuToken.balanceOf(address(this));
        // Withdraw ETH if any
        if (ethBalance > 0) {
            payable(owner()).transfer(ethBalance);
        }
        // Withdraw CZ4 tokens if any
        if (cz4Balance > 0) {
            cz4Token.safeTransfer(owner(), cz4Balance);
        }
        // Withdraw FASU tokens if any
        if (fasuBalance > 0) {
            fasuToken.safeTransfer(owner(), fasuBalance);
        }
    }
    // Allow contract to receive ETH
    receive() external payable {}
}
