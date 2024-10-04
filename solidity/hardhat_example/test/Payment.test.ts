import { loadFixture, ethers, expect } from "./setup";

describe("Payments contract", function() {
    async function deploy() {
        const [user1, user2] = await ethers.getSigners();

        const Factory = await ethers.getContractFactory("Payments");
        const payments = await Factory.deploy();
        await payments.waitForDeployment();

        return {user1, user2, payments};
    }

    it ("should be depoyed", async function() {
        const {payments} = await loadFixture(deploy);
    
        expect(payments.target).to.be.properAddress;
    });

    it ("should have 0 ethers", async function() {
        const {payments} = await loadFixture(deploy);
    
        // const balance = await payments.currentBalance();
        const balance = await ethers.provider.getBalance(payments.target);
        expect(balance).to.be.eq(0);
    });

    it ("should be possible to send funds", async function() {
        const {user1, user2, payments} = await loadFixture(deploy);
    
        const sum = 100; //wei
        const msg = "initial payment";
        
        // const beforeBalance1 = await ethers.provider.getBalance(user1.address);

        // await payments.pay(msg, {value: sum}); 

        // const afterBalance1 = await ethers.provider.getBalance(user1.address);
 
        // // вызывается от первого юзера из getSigners
        // console.log(beforeBalance1);
        // console.log(afterBalance1);

        await payments.connect(user2).pay(msg, {value: sum});
        const tx = await payments.pay(msg, {value: sum}); 
        await tx.wait(1);

        expect(tx).to.changeEtherBalance(user2, -sum);

        const paym = await payments.getPayment(user2.address, 0);

        // expect(paym.timestamp).to.be.greaterThan(1728048156n);
        expect(paym.message).to.be.eq(msg);
        expect(paym.amount).to.be.eq(sum);
        expect(paym.from).to.be.eq(user2.address);
    });
})
