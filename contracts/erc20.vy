# @version ^0.2.0

event Transfer:
    _to: address
    _from: address
    amount: uint256

event Approval:
    _to: address
    _from: address
    amount: uint256

_name: String[30]
_symbol: String[3]
_decimal: uint256
tokenSupply: uint256

userTokens: HashMap[address, uint256]
userAllowance: HashMap[address, HashMap[address, uint256]]

@external
def __init__(newName: String[30], newSymbol: String[3], amount: uint256):
    self._name = newName
    self._symbol = newSymbol
    self._decimal = 18
    self.tokenSupply = amount
    self.userTokens[msg.sender] = amount

@external
@view
def name() -> String[30]:
    return self._name

@external
@view
def symbol() -> String[3]:
    return self._symbol

@external
@view
def decimals() -> uint256:
    return self._decimal

@external
@view
def totalSupply() -> uint256:
    return self.tokenSupply

@external
@view
def balanceOf(addr: address) -> uint256:
    return self.userTokens[addr]

@external
@view
def allowance(addr: address) -> uint256:
    return self.userAllowance[addr][msg.sender]

@external
def transfer(addr: address, amount: uint256) -> bool:
    assert self.userTokens[msg.sender] >= amount, "You have insufficient funds to transfer"
    self.userTokens[msg.sender] -= amount
    self.userTokens[addr] += amount
    log Transfer(msg.sender, addr, amount)
    return True

@external
def transferFrom(_from: address, _to: address, amount: uint256) -> bool:
    assert self.userAllowance[_from][msg.sender] >= amount, "You don't have permission to transfer this amount"
    assert self.userTokens[_from] >= amount, "The sender doesn't have enough to transfer expected amount"
    self.userTokens[_from] -= amount
    self.userTokens[_to] += amount
    self.userAllowance[_from][msg.sender] -= amount
    log Transfer(_from, _to, amount)
    return True

@external
def approve(addr: address, amount: uint256) -> bool:
    assert self.userTokens[msg.sender] >= amount, "You can't give allowance for an amount you don't currenlty own"
    self.userAllowance[msg.sender][addr] += amount
    log Approval(msg.sender, addr, amount)
    return True




