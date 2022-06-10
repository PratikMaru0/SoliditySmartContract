// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.5.0 < 0.9.0;

contract assignment{

    mapping(address=>uint) public depositors;
    mapping(address=>uint) public depositTime;
    mapping(address=>uint) public tokenRewards;
    mapping(address=>uint) public ethRewardPaid;
    address public admin;
    uint public raisedAmount;
    uint public noOfDepositors;
    uint public blocktime;
    uint public poolAmount;
    uint totalDepositTime;
    uint unit;


    // .... Constructor to decide our Admin.
    constructor(){
        blocktime = block.timestamp;
        admin = msg.sender;
    }


    // .... Function to send ether to contract
    function sendEther() public payable {
        if(depositors[msg.sender] == 0){
            noOfDepositors++;
        }
        depositors[msg.sender] += msg.value;
        raisedAmount+=msg.value;
        depositTime[msg.sender] = block.timestamp;
        totalDepositTime += block.timestamp;
    }


    // .... Function to get current contract balance
    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }


    // .... User can withdraw money after 1 year with additional 10% reward.
    function withdraw() public {
        require(depositors[msg.sender] > 0);
        // require(block.timestamp >= depositTime[msg.sender] + 365 days , "Sorry you are not eligible to withdraw");
        require(block.timestamp >= depositTime[msg.sender] + 1 minutes , "Sorry you are not eligible to withdraw");
        address payable user = payable(msg.sender);
        uint reward = depositors[msg.sender] / 10;
        tokenRewards[msg.sender] += reward;
        uint withdrawAmount = depositors[msg.sender];
        uint totalAmount = withdrawAmount + reward;
        user.transfer(totalAmount);
        depositors[msg.sender] = 0;
    }


    // .... Users can see their deposits
    function myBalance() public view returns(uint){
        return depositors[msg.sender];        
    }


    // .... User can see their token rewards 
    function myRewardsEarned() public view returns(uint){
        return tokenRewards[msg.sender];
    }

    // Question :- Admin can add ETH in contract which can be distributed proportionally - 
    // to all deposit users based on their total deposit and time of deposit.
    // 365 * noOfContributors. (Total No of days)
    // eg :- 5 ether 
    // currtime * NoOfDepositors. - all( deposiotrs[time]) => unit jisko main 5 ether / uint => per uint ka miljayega.


    // .... Function to add ETH reward (only admin)
    function pool() payable public{
        require(msg.sender == admin, "Sorry only admin can call this function");   // I didn't used modifier becoz In this contract there is only one admin require.
        poolAmount += msg.value;
        uint currTime = block.timestamp * noOfDepositors;
        uint diffTime = currTime - totalDepositTime;
        unit = poolAmount/diffTime;
    }


    // .... Function to withdraw admin pool reward. 
    function ethRewardWithdraw() public {
        require(depositors[msg.sender] > 0);
        address payable user1 = payable(msg.sender);
        uint diff = block.timestamp - depositTime[msg.sender];
        uint amount = diff * unit;
        require(ethRewardPaid[msg.sender] == 0,"You already claimed your reward. Reward can be claimed once per user");
        user1.transfer(amount);
        ethRewardPaid[msg.sender] = 1;
        poolAmount = poolAmount - amount;
    }

}