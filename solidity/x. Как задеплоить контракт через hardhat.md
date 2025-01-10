1. Создаем файл .env:
```bash
# .env
PRIVATE_KEY=<YOUR_PRIVATE_KEY>
PRC_URL="https://eth-sepolia.g.alchemy.com/v2/UtjFRzFoEQd533NSskUCCCKEpW7z93t2"
```

2. В файле hardhat.config.ts добавить конфиг:
```ts
# hardhat.config.ts
# ...
require('dotenv').config()

const ALCHEMY_PRC_URL = process.env.ALCHEMY_PRC_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;

console.log(ALCHEMY_PRC_URL);

module.exports = {
  defaultNetwork: "sepolia",
  networks: {
    hardhat: {
      
    },
    sepolia: {
      url: ALCHEMY_PRC_URL, 
      accounts: [PRIVATE_KEY],
      saveDeployments: true,
    }
  },
  solidity: "0.8.27",
};
# ...
```

3. В файле ./ignition/modules/Lock.ts:
```ts
# ./scripts/deploy.ts
const { ethers, upgrades } = require("hardhat");

const contractParams = {
    ownerFee: 2,
    duration: 60 * 60 * 24,
    ticketPrice: 100000000000000, // 10 ^ 15 wei = 0.0001 eth
};
  
async function main() {
    const lottery = await ethers.getContractFactory("DecentralizedLottery");

    console.log("Deploying contract...");
    const proxy = await upgrades.deployProxy(lottery, [		
        contractParams.ownerFee,
        contractParams.duration,
		contractParams.ticketPrice
    ], {
        initializer: "initialize",
    });

    console.log("DecentralizedLottery:", await proxy.getAddress());
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

```

4. Деплой:
```bash
npx hardhat run ./scripts/deploy.ts --network sepolia
```
