pragma solidity ^0.4.15;

import './F_ICO.sol';

contract killable is ICO {
    
    function killContract() ownerOnly{
        selfdestruct(ownerMultisig);
    }
}