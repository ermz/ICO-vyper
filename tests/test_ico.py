import pytest
from brownie import accounts, ico, Contract, chain
import brownie

def test_ico_start(_ico, alice, bob):
    with brownie.reverts("Max purchase # can't be zero and higher than avaialble tokens"):
        _ico.icoStart(1628899200, 1, 30, 3, 40, {"from": alice})
    # ico can't start with a duration of 0
    with brownie.reverts("Duration should be longer than 0"):
        _ico.icoStart(0, 1, 700_000, 3, 10, {"from": alice})
    with brownie.reverts("Only the admin may start the ico"):
        _ico.icoStart(1628899200, 1, 700_000, 3, 10, {"from": bob})
    _ico.icoStart(1628899200, 1, 700_000, 3, 10, {"from": alice})
    assert _ico.viewAvailableTokens() == 700_000

def test_whitelist(_started_ico, alice, bob, charles):
    with brownie.reverts("Only admin can add investors"):
        _started_ico.whitelist(bob, {"from": charles})
    _started_ico.whitelist(bob, {"from": alice})
    assert _started_ico.viewIcoInvestors(bob) == True

def test_buy_token(_started_ico, alice, bob, charles):
    _started_ico.whitelist(bob, {"from": alice})
    assert _started_ico.currentPurchase({"from": bob}) == 0
    _started_ico.buyToken(8, {"from": bob, "value": "8 ether"})
    assert _started_ico.currentPurchase({"from": bob}) == 8
    with brownie.reverts("You can't buy more than the maximum purchase amount"):
        _started_ico.buyToken(11, {"from": bob, "value": "11 ether"})
    with brownie.reverts("Insufficient funds being sent"):
        _started_ico.buyToken(4, {"from": bob, "value": "3 ether"})
    with brownie.reverts("You must be whitelisted by admin first"):
        _started_ico.buyToken(5, {"from": charles, "value": "5 ether"})
    chain.sleep(12)
    with brownie.reverts("The time has run up, you can't purchase anymore tokens at this time"):
        _started_ico.buyToken(5, {"from": bob, "value": "5 ether"})

def test_transfer_token(_started_ico, alice, bob, charles):
    _started_ico.whitelist(bob, {"from": alice})
    _started_ico.whitelist(accounts[5], {"from": alice})
    _started_ico.buyToken(4, {"from": bob, "value": "4 ether"})
    _started_ico.buyToken(8, {"from": accounts[5], "value": "8 ether"})
    with brownie.reverts("Only admin may distribute tokens"):
        _started_ico.transferTokens({"from": bob})