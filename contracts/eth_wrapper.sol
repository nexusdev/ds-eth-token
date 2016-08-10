import 'erc20/base.sol';
import 'actor/base.sol';

contract DSEthTokenEvents {
    event Deposit( address indexed who, uint amount );
    event Withdrawal( address indexed who, uint amount );
}

contract DSEthToken is ERC20Base(0)
                     , DSBaseActor
                     , DSEthTokenEvents
{
    function totalSupply() constant returns (uint supply) {
        return this.balance;
    }
    function withdraw( uint amount ) {
        if (!tryWithdraw(amount)) {
            throw;
        }
    }
    function tryWithdraw( uint amount ) returns (bool ok) {
        _balances[msg.sender] = safeSub(_balances[msg.sender], amount);
        bytes memory calldata; // define a blank `bytes`
        if (tryExec(msg.sender, calldata, amount)) { 
            Withdrawal( msg.sender, amount );
            return true;
        } else {
            _balances[msg.sender] = safeAdd(_balances[msg.sender], amount);
            return false;
        }
    }
    function deposit() returns (bool ok) {
        _balances[msg.sender] += msg.value;
        Deposit( msg.sender, msg.value );
        return true;
    }
    function() returns (bool) {
        return deposit();
    }

    // Hoisted to remove dependency on entire util package
    function safeToAdd(uint a, uint b) internal returns (bool) {
        return (a + b >= a);
    }
    function safeAdd(uint a, uint b) internal returns (uint) {
        if (!safeToAdd(a, b)) throw;
        return a + b;
    }
    function safeToSubtract(uint a, uint b) internal returns (bool) {
        return (b <= a);
    }
    function safeSub(uint a, uint b) internal returns (uint) {
        if (!safeToSubtract(a, b)) throw;
        return a - b;
    } 

}
