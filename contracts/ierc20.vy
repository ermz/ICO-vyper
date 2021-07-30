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
