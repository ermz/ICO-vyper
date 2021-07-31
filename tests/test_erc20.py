import pytest
from brownie import accounts, Contract, erc20
import brownie

def test_view_functions(_erc20):
    assert _erc20.name() == "Edson Token"
    assert _erc20.symbol() == "ERZ"
    assert _erc20.totalSupply() == 1_000_000
    assert _erc20.decimals() == 18

def test_transfer(_erc20, alice, bob):
    _erc20.transfer(bob, 20, {"from": alice})
    assert _erc20.balanceOf(bob) == 20
    assert _erc20.balanceOf(alice) == 999_980
    with brownie.reverts():
        _erc20.transfer(accounts[2], 30, {"from": bob})

def test_transfer_from(_erc20, alice, bob, charles):
    _erc20.transfer(bob, 35, {"from": alice})
    with brownie.reverts():
        _erc20.transferFrom(bob, accounts[3], 35, {"from": charles})
    _erc20.approve(charles, 35, {"from": bob})
    _erc20.transferFrom(bob, accounts[3], 35, {"from": charles})
    assert _erc20.balanceOf(accounts[3]) == 35
