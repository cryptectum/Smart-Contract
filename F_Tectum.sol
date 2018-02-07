pragma solidity ^0.4.15;

import './F_ICO.sol';
import './F_FileUploadEnabled.sol';
import './F_DividendInEthEnabledToken.sol';
import './F_MiscFeatures.sol';
import './F_VotingEnabledTokenWithblocking.sol';
//import './F_Multiround.sol';

//ADD Total ETH raised    
contract TectumToken is ICO,fileUploadEnabled,killable,DividendInEthEnabledToken,VotingEnabledToken_blocking {
    
    address tokenBurner = 0xc02e948729bd19A22600A07A8F9d7f8eA9C5CEd0;
    address OwnersFund = 0x4f065ED5ED710323C32217CaDfBD4b33758e7926;
    
    function TectumToken() {
        symbol = "TECT";
        name = "Tectum Token";
        decimals = 18;
        multiplier=base**decimals;
            //totalSupply = 1000000000*multiplier;//1bn-- extra 18 zeroes are for the wallets which use decimal variable to show the balance 
            owner = msg.sender;
        ownerMultisig = 0xF1DfB2AF5dFb683626Faa8576DDf83e1F6e96fa6;
        currentICOPhase = 1;
        addICOPhase("Pre ICO",1000000000*multiplier,100,9999999999999);
        addICOPhase("ICO",1000000000*multiplier,100,9999999999999);
    }
    
    function () payable {
        createTokens();
    }   
    
    function burnTokens() {
        totalSupply = totalSupply.sub(balances[tokenBurner]);
        balances[tokenBurner] = 0;
        
    }
    
    function createTokens() payable {
        ICOPhase storage i = icoPhases[currentICOPhase]; 
        require(msg.value > 0
            && i.saleOn == true);
        updateAccount(msg.sender);    
        uint256 tokens = msg.value.mul(i.RATE);
        //balances[owner] = balances[owner].sub(tokens);
        ownerMultisig.transfer(msg.value);
        balances[msg.sender] = balances[msg.sender].add(tokens);
        totalSupply = totalSupply.add(tokens);
        balances[OwnersFund] = balances[OwnersFund].add((15*tokens)/100);
        totalSupply = totalSupply.add((15*tokens)/100);
        
        i.tokensAllocated = i.tokensAllocated.add(tokens);
        if(i.tokensAllocated>=i.tokensStaged){
            i.saleOn = !i.saleOn; 
            currentICOPhase++;
        }
    }
    
    function dividendBalance() returns(uint256){
        return this.balance;
    }
    
    function transfer(address _to, uint _value) onlyWhenTokenIsOn onlyPayloadSize(2 * 32) returns (bool success){
        //_value = _value.mul(1e18);
        require(
            balances[msg.sender]>=_value 
            && _value > 0
            && now > blockedTill[msg.sender]
        );
        updateAccount(msg.sender);
        updateAccount(_to);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender,_to,_value);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint _value) onlyWhenTokenIsOn onlyPayloadSize(3 * 32) returns (bool success){
        //_value = _value.mul(10**decimals);
        require(
            allowed[_from][msg.sender]>= _value
            && balances[_from] >= _value
            && _value >0 
            && now > blockedTill[_from]            
        );
        updateAccount(_from);
        updateAccount(_to);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
            
    }
    
}



