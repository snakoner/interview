// in this example make shared object, but with owner, who can do everything with counter

module counter::counter {

    public struct Counter has key {
        id: UID,
        owner: address,
        value: u64,
    }

    public fun owner(counter: &Counter): address {
        counter.owner
    }

    public fun value(counter: &Counter): u64 {
        counter.value
    }

    fun init(ctx: &mut TxContext) {
        let counter = Counter {
            id: object::new(ctx),
            owner: ctx.sender(),
            value: 0,
        };

        transfer::share_object(counter);
    }

    // fun init with be called once while deploy, for test use this
    #[test_only]
    public fun create_counter(ctx: &mut TxContext) {
        let counter = Counter {
            id: object::new(ctx),
            owner: ctx.sender(),
            value: 0,
        };

        transfer::share_object(counter); 
    }

    public fun increment(counter: &mut Counter) {
        counter.value = counter.value + 1
    }

    public fun set_value(counter: &mut Counter, value: u64, ctx: &mut TxContext) {
        assert!(counter.owner == ctx.sender());
        counter.value = value;
    }

    public fun delete(counter: Counter, ctx: &mut TxContext) {
        assert!(counter.owner == ctx.sender());
        let Counter {id, owner: _, value: _} = counter;

        id.delete();
    }

}

#[test_only]
module counter::counter_test {
    use counter::counter::{Self, Counter};
    use sui::test_scenario as ts;

    #[test]
    fun test_counter() {
        let owner = @0xC0FFEE;
        let user1 = @0xA1;

        let mut ts = ts::begin(user1);

        {
            ts.next_tx(owner);
            counter::create_counter(ts.ctx());
        };

        {
            ts.next_tx(user1);
            let mut counter: Counter = ts.take_shared();

            assert!(counter.owner() == owner);
            assert!(counter.value() == 0);

            counter.increment();
            counter.increment();
            counter.increment();

            ts::return_shared(counter);
        };

        {
            ts.next_tx(owner);
            let mut counter: Counter = ts.take_shared();

            assert!(counter.owner() == owner);
            assert!(counter.value() == 3);

            counter.set_value(100, ts.ctx());

            ts::return_shared(counter);
        };

        {
            ts.next_tx(user1);
            let mut counter: Counter = ts.take_shared();

            assert!(counter.owner() == owner);
            assert!(counter.value() == 100);

            counter.increment();
            assert!(counter.value() == 101);

            ts::return_shared(counter);
        };

        ts.end();
    }
}
