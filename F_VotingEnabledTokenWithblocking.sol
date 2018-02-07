pragma solidity ^0.4.15;

import './F_DateTime.sol';
import './F_BaseToken.sol';

contract VotingEnabledToken_blocking is BaseToken,DateTimeEnabled {

    struct proposal {
        string description;
        uint256 yays;
        uint256 nays;
        mapping(address=>bool) voted;
        address owner;
        uint deadline; //timestamp
        mapping(address=>int256) voters;//key is the address and the value is the no. of tokens held by the member
        
    }
    
    mapping(address=>uint) blockedTill; //stores timestamp of time till a particular address is blocked

    mapping(uint=>proposal) public voting;
    uint8 latestProposalIndex = 1;

    //event Transfer(address indexed _from, address indexed _to, uint _value);
    //event Approval(address indexed _owner, address indexed _spender, uint _value);

    event Vote(address indexed _by,uint8 indexed _voteIndex, string _vote);

    function createProposal(string _desc,uint8 _daysOpen) ownerOnly onlyWhenTokenIsOn {
        require(balances[msg.sender]>0);
        voting[latestProposalIndex].owner = msg.sender;
        voting[latestProposalIndex].description = _desc;
        voting[latestProposalIndex].yays=0;
        voting[latestProposalIndex].nays=0;
        //voting[latestProposalIndex].deadline = addDaystoTimeStamp(_daysOpen);
        voting[latestProposalIndex].deadline = addDaystoTimeStamp(_daysOpen);
        latestProposalIndex += 1;
        
    }

    function vote(uint8 _index, uint256 _response) onlyWhenTokenIsOn { //1 for Yes 0 for No
        require(balances[msg.sender] > 0);
        require(voting[_index].deadline>now);        
        require(voting[_index].voters[msg.sender]==0);
        if(_response == 1 ){
            voting[_index].yays = voting[_index].yays.add(balances[msg.sender]);//INCREASE BY balance IF 1 token 1 vote
            voting[_index].voters[msg.sender]=int256(balances[msg.sender]);
            if(voting[_index].deadline > blockedTill[msg.sender]){
                blockedTill[msg.sender]=voting[_index].deadline;
            }
            Vote(msg.sender,_index,"yes");
        } else if (_response == 0){
            voting[_index].nays = voting[_index].nays.add(balances[msg.sender]);            
            voting[_index].voters[msg.sender]=-int256(balances[msg.sender]);
            blockedTill[msg.sender]=voting[_index].deadline;
            if(voting[_index].deadline > blockedTill[msg.sender]){
                blockedTill[msg.sender]=voting[_index].deadline;
            }
            Vote(msg.sender,_index,"no");
        }
    }
    
    
    function voteResult(uint8 _index) returns (string description,uint256 yays,uint256 nays, address owner,uint deadline,int256){
        require(now>voting[_index].deadline);
        return (
            voting[_index].description,
            voting[_index].yays,
            voting[_index].nays,
            voting[_index].owner,
            voting[_index].deadline,
            voting[_index].voters[msg.sender]
        );
    }
    
    function transfer(address _to, uint _value) onlyWhenTokenIsOn returns (bool success){
        //_value = _value.mul(1e18);
        require(
            balances[msg.sender]>=_value 
            && _value > 0
            && now > blockedTill[msg.sender]
        );
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender,_to,_value);
        return true;
    }

}    