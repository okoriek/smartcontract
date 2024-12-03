import json
from web3 import Web3

def deploy_contract():
    w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:8545"))  # Update with your provider
    w3.eth.default_account = w3.eth.accounts[0]

    with open("compiled_contract.json", "r") as file:
        compiled_sol = json.load(file)

    abi = compiled_sol["contracts"]["BettingSubscription.sol"]["BettingSubscription"]["abi"]
    bytecode = compiled_sol["contracts"]["BettingSubscription.sol"]["BettingSubscription"]["evm"]["bytecode"]["object"]

    BettingSubscription = w3.eth.contract(abi=abi, bytecode=bytecode)
    tx_hash = BettingSubscription.constructor().transact()
    tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)

    return {
        "address": tx_receipt.contractAddress,
        "abi": abi
    }
