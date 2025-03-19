import datetime
import sys
import web3
from web3 import Web3, HTTPProvider
from utils import get_block_by_timestamp
from typing import Tuple
import argparse

CONTRACT_ADDRESS_LENGTH = 40
CONTRACT_ADDRESS_LENGTH_WITH_PREFIX = CONTRACT_ADDRESS_LENGTH + 2
SEPARATOR = '#' * 60
ETHEREUM_RPC_URL = 'https://eth-mainnet.g.alchemy.com/v2/n5x-siXFHP3bEokNDewq5cPfL2a-zw80'
ARBITRUM_RPC_URL = 'https://arb-mainnet.g.alchemy.com/v2/Qe7gm1l0s5SS0F0AzQBOOwz-zuOrlyW-'
AVALANCHE_RPC_URL = 'https://avax-mainnet.g.alchemy.com/v2/KHvUQx__u1IofiV7X_XHnZcamRW3-Qai'
BSC_RPC_URL = 'https://bnb-mainnet.g.alchemy.com/v2/jR0UBe5C0RS_iKukMbnTW7hAiiI0PTFR'
OPTIMISM_RPC_URL = 'https://opt-mainnet.g.alchemy.com/v2/14-VmQKw4dTHVk1Hn30Vts-E3Yb_0_Ie'
POLYGON_RPC_URL = 'https://polygon-mainnet.g.alchemy.com/v2/Jw1pZZ8wINVU--vkLSIPsgDqq4x_zkPS'
BASE_RPC_URL = 'https://base-mainnet.g.alchemy.com/v2/gcEMY3Rnr1amFk1Z9t1Wqnh9-mWsQ1kt'

chains = {
    'ethereum': {
        'rpc': ETHEREUM_RPC_URL
    },
    'arbitrum': {
        'rpc': ARBITRUM_RPC_URL
    },
    'avalanche': {
        'rpc': AVALANCHE_RPC_URL
    },
    'bsc': {
        'rpc': BSC_RPC_URL
    },
    'optimism': {
        'rpc': OPTIMISM_RPC_URL
    },
    'polygon': {
        'rpc': POLYGON_RPC_URL
    },
    'base': {
        'rpc': BASE_RPC_URL
    },    
}

# chain: ethereum, arbitrum
def parse_args():
    parser = argparse.ArgumentParser(description="Read smart contract slot")

    parser.add_argument("-c", "--chain", type=str, help="Chain name, e.g ethereum", default="ethereum")
    parser.add_argument("-a", "--address", type=str, help="Contract address in hex format", required=True)
    parser.add_argument("-s", "--slot", type=str, help="Slot number in hex format", required=True)

    args = parser.parse_args()

    chain = args.chain
    if chain not in chains.keys():
        print('Unknown chain')
        exit(-1)

    address = args.address
    if len(address) != CONTRACT_ADDRESS_LENGTH_WITH_PREFIX:
        print(f'Invalid address length: {4 * (len(address) - 2)} bits but required {CONTRACT_ADDRESS_LENGTH}')
        exit(-1)

    slot = args.slot

    return args.chain, web3.Web3.to_checksum_address(address), int(slot, 16)

if __name__ == '__main__':
    chain, contract_address, slot = parse_args()
    w3 = Web3(HTTPProvider(chains[chain]['rpc']))

    storage_value = w3.eth.get_storage_at(contract_address, slot)
    print(f"\n{SEPARATOR}\n[{hex(slot)}] = \n{storage_value.hex()}\n{SEPARATOR}")
