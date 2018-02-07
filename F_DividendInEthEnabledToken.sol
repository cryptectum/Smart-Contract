pragma solidity ^0.4.15;
//import './F_DateTime.sol';
//import './F_ICO.sol';
import './F_BaseToken.sol';

contract DividendInEthEnabledToken is BaseToken{

    //to avoid rounding off errors
    uint256 constant pointsMultiplier = 10e18;
    uint256 public totalDividendPoints;

    mapping (address => uint256) public lastDividendPoints;

    function dividendOwing(address account) internal returns(uint256){
        var newDividendPoints = totalDividendPoints.sub(lastDividendPoints[account]);
        return (balances[account].mul(newDividendPoints)).div(pointsMultiplier);
    }
    
    function updateAccount (address account) internal {
        var owing = dividendOwing(account);
        if(owing > 0) {
            lastDividendPoints[account] = totalDividendPoints;
            account.transfer(owing);
            Dividend(account,owing);
        }
    }
    
    function disburse() payable onlyWhenTokenIsOn ownerOnly {
        require(msg.sender == owner && msg.value >0);
        totalDividendPoints = totalDividendPoints.add((msg.value.mul(pointsMultiplier)).div(totalSupply));
        //owner.transfer(msg.value);
    }
    
    function claimDividend() onlyWhenTokenIsOn {
        //this will just run the updateAccount modifier
        updateAccount(msg.sender);
    }
    
    function checkBalance() returns (uint256) {
        return this.balance;
    }

    function transfer(address _to, uint _value) onlyWhenTokenIsOn onlyPayloadSize(2 * 32) returns (bool success){
        //_value = _value.mul(1e18);
        require(
            balances[msg.sender]>=_value 
            && _value > 0);
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
            );
        updateAccount(_from);
        updateAccount(_to);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
            
    }

    function dividendBalance() returns(uint256){
        return this.balance;
    }

    
    event Dividend(address indexed account, uint256 amount);
}



