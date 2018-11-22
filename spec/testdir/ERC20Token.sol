pragma solidity ^0.4.24;

import "./SafeMath.sol";

contract ERC20Token {
  using SafeMath for uint;

  string public name;
  string public symbol;
  uint256 public totalSupply;
  uint256 public maxSupply;
  uint8 public decimals;

  mapping(address => uint256) balances;

  mapping(address => mapping (address => uint256)) public allowance;

  event Transfer(address from, address to, uint value);
  event Approval(address from, address to, uint value);

  constructor(string _name, string _symbol, uint8 _decimals, uint256 _initialSupply, uint256 _maxSupply) public {
    require(_maxSupply >= _initialSupply);

    name = _name;
    symbol = _symbol;
    decimals = _decimals;

    balances[msg.sender] = _initialSupply;
    totalSupply = _initialSupply;
    maxSupply = _maxSupply;
  }

  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }

  function transfer(address _to, uint _amount) public returns (bool success) {
    require(_to != address(0));
    require(balances[msg.sender] >= _amount);

    balances[msg.sender] = balances[msg.sender].sub(_amount);
    balances[_to] = balances[_to].add(_amount);

    emit Transfer(msg.sender, _to, _amount);

    return true;
  }

  function transferFrom(address _from, address _to, uint _amount) public returns (bool success) {
    require(_to != address(0));
    require(balances[_from] >= _amount);
    require(allowance[_from][msg.sender] >= _amount);

    balances[_from] = balances[_from].sub(_amount);
    allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_amount);
    balances[_to] = balances[_to].add(_amount);

    emit Transfer(_from, _to, _amount);

    return true;
  }

  function approve(address _spender, uint _amount) public returns (bool success) {
    require(_spender != address(0));
    require(balances[msg.sender] >= _amount);

    allowance[msg.sender][_spender] = allowance[msg.sender][_spender].add(_amount);

    emit Approval(msg.sender, _spender, _amount);

    return true;
  }
}
