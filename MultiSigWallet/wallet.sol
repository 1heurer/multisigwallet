/*

    HOW TO USE:

(1) Deposit ether to address
(2) setOwners 
(3) requestTransfer
(4) approveTransfer - account that requested transfer automaticaly approves the transfer. Switch to other owner accounts and approveTransfer (2/3 approves needed)
    For every approve the approvalCounter will increase by 1.
(5) completeTransfer - will require 'require(approvalCounter == 2 || approvalCounter == 3);

*/

pragma solidity 0.7.5;

import "./ownable.sol";
import "./government.sol";


contract Wallet is Ownable, Government{
 
    event depositDone (uint amount, address indexed depositedTo);
        
    constructor(){
        owner = msg.sender;
        ownersList.push(_walletOwners(owner, false));
        pendingTransfer = false;
        approvalCounter = 0;
    }
 
    //multisig transfer functions
    
    function requestTransfer(uint _amount, address _recipient)public {
        require(balance[msg.sender] >= _amount, "Balance not sufficient.");
        require(msg.sender == ownersList[0].owner || msg.sender == ownersList[1].owner || msg.sender == ownersList[2].owner, "You don't have access to this contract!");
        transctionLog.push(Transactions(_recipient, _amount));
        pendingTransfer = true;
        transferRequester = msg.sender;
        approvalCounter = 1;
    }
    
    function approveTransfer() public {
        require((msg.sender == ownersList[0].owner || msg.sender == ownersList[1].owner || msg.sender == ownersList[2].owner) && msg.sender != transferRequester, "You are not allowed to approve this transfer.");
        for(uint i = 0; i <= 2; i++){
            if(ownersList[i].owner == msg.sender && ownersList[i].hasApprovedTransfer == false){
                approvalCounter++;
                ownersList[i].hasApprovedTransfer = true;
            }
        }
    }
    
    function completeTransfer() public returns(string memory){
        require(approvalCounter == 2 || approvalCounter == 3);
        for(uint i = 0; i <= 2; i++){
            ownersList[i].hasApprovedTransfer = false;
        }
        
        uint previousSenderBalance = balance[transferRequester];
        
        _transfer(transferRequester, transctionLog[0].recipient, transctionLog[0].amount);
        
        pendingTransfer = false;
        approvalCounter = 0;
        
        assert(balance[transferRequester] == previousSenderBalance - transctionLog[0].amount);
        
        return ("Transfer was successful!");
    }
    
    function _transfer(address from, address to, uint amount) private {
        balance[from] -= amount;
        balance[to] += amount;
    }
    
    //setter functions
    
    function setOwners(address secondOwner, address thirdOwner) public onlyOwner {
        ownersList.push(_walletOwners(secondOwner, false));
        ownersList.push(_walletOwners(thirdOwner, false));
    }
    
    // deposit and withdraw
    
    function deposit() public payable returns(uint){
        balance[msg.sender] += msg.value;
        emit depositDone(msg.value, msg.sender);
        return balance[msg.sender];
    }
    
    function withdraw(uint amount) public returns(uint){
        require(balance[msg.sender] >= amount, "Balance not sufficient.");
        balance[msg.sender] -= amount;
        msg.sender.transfer(amount);
        return balance[msg.sender];
    }
    
    //getter-functions
    
        
    function getOwners() public view returns(address, address, address){
        return (ownersList[0].owner, ownersList[1].owner, ownersList[2].owner);
    }
    
    function getCurrentUser() public view returns(address){
        return (msg.sender);
        
    }
    
    function getContractInfo() public view returns(string memory, address, string memory, uint, string memory, bool, string memory, uint){
        return ("Contract Owner: ", owner, "owner balance: ", balance[owner], "Pending transfer: ", pendingTransfer, "approval counter: ", approvalCounter);
    }
    
    function getPendingTransfer(uint _index) public view returns(address, uint, uint){
        require(pendingTransfer == true, "No transfer requested at the moment.");
        return (transctionLog[_index].recipient, transctionLog[_index].amount, approvalCounter);
    }
    
    function getUserBalance() public view returns(uint){
        return balance[msg.sender];
    }
}