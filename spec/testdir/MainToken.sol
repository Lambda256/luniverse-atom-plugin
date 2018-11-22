pragma solidity ^0.4.24;

import "./ERC20Token.sol";
import "./Ownable.sol";

contract MainToken is ERC20Token, Ownable {

  constructor(
    string _name,
    string _symbol,
    uint8 _decimals,
    uint256 _initialSupply,
    uint256 _maxSupply
  ) ERC20Token(_name, _symbol, _decimals, _initialSupply, _maxSupply)
  public { }
}