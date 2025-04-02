npx hardhat vars set ETHEREUM_RPC ${ETHEREUM_RPC}
npx hardhat --network mainnet deploy:logic ConvexCurveEthereumUSDCfxUSD
npx hardhat vars set ETHERSCAN_API_KEY ${ETHERSCAN_API_KEY}
npx hardhat --network mainnet verify <deployed-contract-address>
