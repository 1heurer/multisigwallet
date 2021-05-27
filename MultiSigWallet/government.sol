pragma solidity 0.7.5;


contract Government {
    
    mapping(address => uint) balance;
    
    uint approvalCounter; //tracks number of transfer approvals
    
    bool pendingTransfer; //checks if there is a pending transfer
    
    address transferRequester; 
    
    struct _walletOwners {          //tracks all wallet owners for multisig and wether they have already approved a pending transfer
        address owner;
        bool hasApprovedTransfer;
    }
    
    struct Transactions {   
        address recipient;
        uint amount;
    }
    
    _walletOwners[] ownersList; 
    Transactions[] transctionLog;
}