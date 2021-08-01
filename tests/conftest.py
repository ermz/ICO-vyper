import pytest
from brownie import accounts, Contract, erc20, ico

@pytest.fixture(scope="module")
def alice(accounts):
    return accounts[0]

@pytest.fixture(scope="module")
def bob(accounts):
    return accounts[1]

@pytest.fixture(scope="module")
def charles(accounts):
    return accounts[2]

@pytest.fixture()
def _erc20(alice):
    _erc20 = erc20.deploy("Edson Token", "ERZ", 1_000_000, {"from" : alice})
    return _erc20

@pytest.fixture()
def _ico(_erc20, alice):
    _ico = ico.deploy(_erc20, 700_000, {"from": alice})
    _erc20.approve(_ico, 700_000, {"from": alice})
    return _ico

@pytest.fixture()
def _started_ico(_ico, alice):
    _ico.icoStart(10, 1, 700_000, 3, 10, {"from": alice})
    return _ico
