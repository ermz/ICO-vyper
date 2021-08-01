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
    _started_ico.buyToken(9, {"from": bob, "value": "9 ether"})
    assert _started_ico.currentPurchase({"from": bob}) == 9
    with brownie.reverts("You can't buy more than the maximum purchase amount"):
        _started_ico.buyToken(11, {"from": bob, "value": "11 ether"})
    with brownie.reverts("Insufficient funds being sent"):
        _started_ico.buyToken(4, {"from": bob, "value": "3 ether"})
    with brownie.reverts("You must be whitelisted by admin first"):
        _started_ico.buyToken(5, {"from": charles, "value": "5 ether"})
    chain.sleep(12)
    with brownie.reverts("The time has run up, you can't purchase anymore tokens at this time"):
        _started_ico.buyToken(5, {"from": bob, "value": "5 ether"})

def test_transfer_token(_started_ico, alice, bob):
    _started_ico.whitelist(bob, {"from": alice})
    _started_ico.whitelist(accounts[3], {"from": alice})
    _started_ico.buyToken(7, {"from": bob, "value": "7 ether"})
    _started_ico.buyToken(3, {"from": bob, "value": "3 ether"})
    with brownie.reverts("You would exceed max purchase with this transaction"):
        _started_ico.buyToken(3, {"from": bob, "value": "3 ether"})
    _started_ico.buyToken(7, {"from": accounts[3], "value": "7 ether"})
    with brownie.reverts("Only admin may distribute tokens"):
        _started_ico.transferTokens({"from": bob})
    with brownie.reverts("The ICO is ongoing"):
        _started_ico.transferTokens({"from": alice})
    with brownie.reverts("Either time for the ICO has elapsed or all tokens have been sold"):
        _started_ico.endIco({"from": alice})
    chain.sleep(12)
    _started_ico.endIco({"from": alice})
    assert _started_ico.viewBalanceOf(bob) == 0
    _started_ico.transferTokens({"from": alice})
    assert _started_ico.viewBalanceOf(bob) == 10
    assert _started_ico.viewBalanceOf(accounts[3]) == 7

def test_withdraw(_started_ico, alice, bob, charles):
    _started_ico.whitelist(bob, {"from": alice})
    _started_ico.whitelist(charles, {"from": alice})
    _started_ico.buyToken(5, {"from": charles, "value": "5 ether"})
    _started_ico.buyToken(8, {"from": bob, "value": "8 ether"})
    chain.sleep(12)
    _started_ico.endIco({"from": alice})
    with brownie.reverts("Can only withdraw once tokens have been transferred to respective investors"):
        _started_ico.withdraw({"from": alice})
    _started_ico.transferTokens({"from": alice})
    with brownie.reverts("Only the admin may withdraw funds"):
        _started_ico.withdraw({"from": bob})
    assert alice.balance() == (100 * 1_000_000_000_000_000_000)
    _started_ico.withdraw({"from": alice})
    assert alice.balance() == (113 * 1_000_000_000_000_000_000)
    