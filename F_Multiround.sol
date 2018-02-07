pragma solidity ^0.4.15;

import './F_ICO.sol';

contract MultiRound is ICO{
    function newICORound(uint256 _newSupply) ownerOnly {//This is different from Stages which means multiple parts of one round
        _newSupply = _newSupply.mul(multiplier);
        balances[owner] = balances[owner].add(_newSupply);
        totalSupply = totalSupply.add(_newSupply);
    }

    function destroyUnsoldTokens(uint256 _tokens) ownerOnly{
        _tokens = _tokens.mul(multiplier);
        totalSupply = totalSupply.sub(_tokens);
        balances[owner] = balances[owner].sub(_tokens);
    }

    
}