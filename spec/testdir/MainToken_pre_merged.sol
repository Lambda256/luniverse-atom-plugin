pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    assert(c / _a == _b);

    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    assert(c >= _a);

    return c;
  }
}

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

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

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