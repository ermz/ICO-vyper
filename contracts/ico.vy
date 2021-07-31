# @version ^0.2.0

event TokenPurchase:
    buyer: indexed(address)
    amount: uint256
    id: uint256

event FundsWithdrawn:
    Receiver: address
    amount: uint256

interface erc20Receiver:
    def name() -> String[30]: view
    def symbol() -> String[3]: view
    def decimals() -> uint256: view
    def totalSupply() -> uint256: view
    def balanceOf(addr: address) -> uint256: view
    def allowance(addr: address) -> uint256: view
    def transfer(addr: address, amount: uint256) -> bool: nonpayable
    def transferFrom(_from: address, _to: address, amount: uint256) -> bool: nonpayable
    def approve(addr: address, amount: uint256) -> bool: nonpayable

admin: address
erc20: address
endTime: uint256
tokenPrice: uint256
availableTokens: uint256
minimumPurchase: uint256
maxPurchase: uint256
icoActive: bool
tokensTransferred: bool

icoInvestors: HashMap[address, bool]
# purchaseLedger will hold an id for purchase, that will then correspond to purchaser address and amount purchase
# I'm using a purchase id so that I can iterate over them with range(...), for when I transfer tokens later
purchaseInvestor: HashMap[uint256, address]
purchaseAmount: HashMap[uint256, uint256]
# purchaseId will serve as a counter for purchaseLedger
purchaseId: uint256
# This can be used to check what id belongs to who
# Can also be used to check how much they've bought up to that point
# This will allow them to purchase more than once
addressToId: HashMap[address, uint256]

# Remember that the address that instantiates erc20.vy will have to approve
# the address of this contract(ico.vy) in order for this contract to
# have access to admin roles in erc20.vy, since erc20.vy won't be calling that function

@external
def __init__(_ERC20: address, _endTime: uint256):
    self.admin = msg.sender
    self.endTime = _endTime
    self.erc20 = _ERC20

@external
@view
def currentPurchase() -> uint256:
    return self.purchaseAmount[self.addressToId[msg.sender]]

@external
def icoStart(_duration: uint256, _tokenPrice: uint256, _availableTokens: uint256, _minimumPurchase: uint256, _maxPurchase: uint256) -> bool:
    assert msg.sender == self.admin, "Only the admin may start the ico"
    assert _duration > 0, "Duration should be longer than that"
    assert self.icoActive == False, "ICO has already started"
    assert _availableTokens > 0, "There has to be atleast some tokens for sale"
    assert _availableTokens < erc20Receiver(self.erc20).totalSupply(), "Avaiable tokens can't be higher than total supply"
    assert _minimumPurchase > 0, "Minimum purchase can't be zero"
    assert _maxPurchase > 0 and _maxPurchase < _availableTokens, "Max purchase # can't be zero and higher than avaialble tokens"
    self.endTime = block.timestamp + _duration
    self.tokenPrice = _tokenPrice
    self.availableTokens = _availableTokens
    self.minimumPurchase = _minimumPurchase
    self.maxPurchase = _maxPurchase
    return True

@external
def whitelist(investor: address) -> bool:
    assert msg.sender == self.admin, "Only admin can add investors"
    self.icoInvestors[investor] = True
    return True

@external
@payable
def buyToken(amount: uint256) -> bool:
    assert msg.value >= amount, "Insufficient funds being sent"
    assert self.icoInvestors[msg.sender] == True, "You must be whitelisted by admin first"
    assert self.minimumPurchase <= amount, "You must buy atleast the minimum purchase amount"
    assert self.maxPurchase >= amount, "You can't buy more than the maximum purchase amount"
    assert self.endTime > block.timestamp, "The time has run up, you can't purchase anymore tokens at this time"
    assert self.icoActive == True, "The ICO is inactive"
    assert self.purchaseAmount[self.addressToId[msg.sender]] + amount <= self.maxPurchase, "You would exceed max purchase with this transaction"
    
    # If statement checks if this particular account has bought tokens before
    # If they have it will just increase purchase amount w/out incrementing purchaseId
    if self.purchaseAmount[self.addressToId[msg.sender]] > 0:
        self.purchaseAmount[self.addressToId[msg.sender]] += amount
        log TokenPurchase(msg.sender, amount, self.addressToId[msg.sender])
        return True

    self.purchaseInvestor[self.purchaseId] = msg.sender
    self.purchaseAmount[self.purchaseId] += amount
    log TokenPurchase(msg.sender, amount, self.purchaseId)
    self.purchaseId += 1
    return True


@external
def transferTokens() -> bool:
    assert msg.sender == self.admin, "Only admin may distribute tokens"
    assert self.icoActive == False, "The ICO is ongoing"
    assert self.endTime < block.timestamp, "The ICO time hasn't elapsed yet"
    assert self.tokensTransferred == False, "Tokens have been transferred already"
    # The if statement should break/stop the for loop once it finds an id
    # that holds no value, so that should be the end transferring tokens
    for i in range(0, 1_000_000):
        if self.purchaseAmount[i] == 0:
            break
        else:
            erc20Receiver(self.erc20).transferFrom(self.admin, self.purchaseInvestor[i], self.purchaseAmount[i])

    self.tokensTransferred = True
    return True

@external
def withdraw() -> bool:
    assert msg.sender == self.admin, "Only the admin may withdraw funds"
    assert self.tokensTransferred == True, "Can only withdraw once tokens have been transferred to respective investors"
    contract_balance: uint256 = self.balance
    send(msg.sender, contract_balance)
    log FundsWithdrawn(msg.sender, contract_balance)
    return True
