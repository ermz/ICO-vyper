# @version ^0.2.0

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

# Remember that the address that instantiates erc20.vy will have to approve
# the address of this contract(ico.vy) in order for this contract to
# have access to admin roles in erc20.vy, since erc20.vy won't be calling that function

@external
def __init__(_ERC20: address, _endTime: uint256):
    self.admin = msg.sender
    self.endTime = _endTime
    self.erc20 = _ERC20

@external
def icoStart(_endTime: uint256, _tokenPrice: uint256, _availableTokens: uint256, _minimumPurchase: uint256, _maxPurchase: uint256) -> bool:
    assert msg.sender == self.admin, "Only the admin may start the ico"
    assert _endTime > 0, "Duration should be longer than that"
    assert self.icoActive == False, "ICO has already started"
    assert _availableTokens > 0, "There has to be atleast some tokens for sale"
    assert _availableTokens < erc20Receiver(self.erc20).totalSupply(), "Avaiable tokens can't be higher than total supply"
    self.endTime = _endTime
    self.tokenPrice = _tokenPrice
    self.availableTokens = _availableTokens
    self.minimumPurchase = _minimumPurchase
    self.maxPurchase = _maxPurchase
    return True

@external
def startERC20(_name: String[30], _symbol: String[3], _supply: uint256) -> address:
    assert msg.sender == self.admin, "Only the admin may start the ERC20 contract"

    return ZERO_ADDRESS



# @external
# def __init__(newName: String[30], newSymbol: String[3], amount: uint256):

