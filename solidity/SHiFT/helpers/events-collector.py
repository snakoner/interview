import datetime
import web3
from web3 import Web3, HTTPProvider
from utils import get_block_by_timestamp

event_abi = '''[
    {"anonymous":false,"inputs":[],"name":"OptimisticMintingUnpaused","type":"event"}
]'''

event_abi = '''[
    {"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"newVault","type":"address"},{"indexed":false,"internalType":"uint256","name":"timestamp","type":"uint256"}],"name":"UpgradeInitiated","type":"event"}
]'''

event_abi = '''[
    {"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint32","name":"newOptimisticMintingDelay","type":"uint32"}],"name":"OptimisticMintingDelayUpdateStarted","type":"event"}
]'''

event_abi = '''[
    {"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint32","name":"newOptimisticMintingFeeDivisor","type":"uint32"}],"name":"OptimisticMintingFeeUpdateStarted","type":"event"}
]'''

w3 = Web3(HTTPProvider('https://eth-mainnet.g.alchemy.com/v2/n5x-siXFHP3bEokNDewq5cPfL2a-zw80'))
deployment_block = 16472741
chain = "ethereum"
block_to = 0
step = 10000
contract_address = web3.Web3.to_checksum_address("0x9C070027cdC9dc8F82416B2e5314E11DFb4FE3CD")
contract = w3.eth.contract(contract_address, abi=event_abi)

GREEN = '\033[32m'
YELLOW = '\033[33m'
RED = '\033[31m'
RESET = '\033[0m'

def format_int(number):
    return "{:,}".format(number)

def scan_evm_blocks():
    global block_to

    if block_to == 0:
        tnow = int(datetime.datetime.utcnow().timestamp())
        block_to = get_block_by_timestamp(chain, tnow)
    blocks_to_scan = block_to - deployment_block
    print(f'Blocks to scan: {GREEN}{format_int(block_to - deployment_block)}{RESET}')

    for i in range(deployment_block, block_to, step):
        from_formated = format_int(i - 1)
        to_formated = format_int(i + step)
        left_formated = format_int(block_to - i)
        execution_ratio = ((i - deployment_block) / blocks_to_scan) * 100
        color = RED
        if execution_ratio >= 33.3 and execution_ratio <= 66.6:
            color = YELLOW
        elif execution_ratio > 66.6:
            color = GREEN
        print(f'\rscanning: {from_formated} - {to_formated}. left = {left_formated} {color}{round(execution_ratio, 1)}%{RESET}', end='', flush=True)
        logs = contract.events.OptimisticMintingFeeUpdateStarted().get_logs(fromBlock=i - 1, toBlock=i + step)
    
        for log in logs:
            print('\n', log)
    
if __name__ == '__main__':
    scan_evm_blocks()
