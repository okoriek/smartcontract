import json
from solcx import compile_standard

class Command:
    help = "Compile the smart contract"

    def handle(self, *args, **kwargs):
        with open("BettingSubscription.sol", "r") as file:
            contract_code = file.read()

        compiled_sol = compile_standard({
            "language": "Solidity",
            "sources": {"BettingSubscription.sol": {"content": contract_code}},
            "settings": {"outputSelection": {"*": {"*": ["abi", "evm.bytecode"]}}},
        })

        with open("compiled_contract.json", "w") as file:
            json.dump(compiled_sol, file)
        print("Contract compiled successfully.")

