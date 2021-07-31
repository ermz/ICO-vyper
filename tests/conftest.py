import pytest
from brownie import accounts, Contract, erc20

@pytest.fixture(scope="module")
def alice(accounts):
    return accounts[0]

@pytest.fixture(scope="module")
def bob(accounts):
    return accounts[1]

@pytest.fixture(scope="module")
def charles(accounts):
    return accounts[2]

@pytest.fixture(scope="module")
def _erc20(alice):
    _erc20 = erc20.deploy("Edson Token", "ERZ", 1_000_000, {"from" : alice})
    return _erc20