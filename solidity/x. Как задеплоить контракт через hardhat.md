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
# ./ignition/modules/Lock.ts

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const SimpleContractModule = buildModule("SimpleContractModule", (m) => {
  const simpleContract = m.contract("SimpleContract", [], {});

  return { simpleContract };
});

export default SimpleContractModule;
```

4. Деплой:
```bash
npx hardhat ignition deploy ./ignition/modules/Lock.ts --network sepolia
```
