module staking_contract::staking {
    use sui::balance::{Self, Balance};
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::table::{Self, Table};
    use sui::event;
    use sui::clock::{Self, Clock};
    use std::debug;

    const EAccountInDesiredState: u64 = 0;
    const EAccountIsBlacklisted: u64 = 1;
    const ECoinValueIsZero: u64 = 2;
    const EInvalidPoolForPosition: u64 = 3;

    public struct AdminCap has key, store {
        id: UID,
    }

    public struct BlacklistCap has key, store {
        id: UID,
    }

    public struct Pool has key {
        id: UID,
        balance: Balance<SUI>,
        reward_rate: u64,
        blacklist: Table<address, bool>,
    }

    public struct Position has key, store {
        id: UID,
        value: u64,
        pool_id: ID,
        stake_time: u64,
    }

    // events
    public struct BlacklistStateChanged has copy, drop {
        account: address,
        new_state: bool,
    }

    public struct Staked has copy, drop {
        account: address, 
        value: u64,
    }

    public struct Unstaked has copy, drop {
        account: address, 
        value: u64,
    }

    public struct ClaimedRewards has copy, drop {
        account: address,
        reward: u64,
    }

    fun init(ctx: &mut TxContext) {
        transfer::transfer( AdminCap { id: object::new(ctx) 
        }, ctx.sender());

        transfer::transfer(BlacklistCap {
            id: object::new(ctx),
        }, ctx.sender());
    }

    public fun create_pool(reward_rate: u64, _: &AdminCap, ctx: &mut TxContext): Pool {
        Pool { 
            id: object::new(ctx), 
            balance: balance::zero(), 
            reward_rate: reward_rate,
            blacklist: table::new<address, bool>(ctx),
        }
    }

    public fun stake(coin: Coin<SUI>, clock: &Clock, pool: &mut Pool, ctx: &mut TxContext): Position {
        let account = ctx.sender();
        if (is_blacklisted(account, pool)) {
            abort EAccountIsBlacklisted
        };

        let value = coin::value(&coin);
        if (value == 0) {
            abort ECoinValueIsZero
        };

        let new_balance = coin::into_balance(coin);
        pool.balance.join(new_balance);

        event::emit(Staked {
            account: account,
            value: value,
        });

        Position {
            id: object::new(ctx),
            value: value,
            pool_id: get_pool_id(pool),
            stake_time: clock.timestamp_ms() / 1000,
        }
    }

    public fun unstake(pos: Position, pool: &mut Pool, clock: &Clock, ctx: &mut TxContext): Coin<SUI> {
        let account = ctx.sender();
        let Position {id, value, pool_id, stake_time} = pos;
        assert!(pool_id == object::uid_to_inner(&pool.id), EInvalidPoolForPosition);

        let reward = (clock.timestamp_ms() / 1000 - stake_time) * pool.reward_rate;
        let refund = reward + value;

        let refund_balance = balance::split(&mut pool.balance, refund);
        let refund_coin = coin::from_balance(refund_balance, ctx);

        object::delete(id);

        event::emit(Unstaked {
            account: account,
            value: refund,
        });

        refund_coin
    }

    public fun claim_rewards(pos: &mut Position, pool: &mut Pool, clock: &Clock, ctx: &mut TxContext): Coin<SUI> {
        let account = ctx.sender();
        assert!(pos.pool_id == object::uid_to_inner(&pool.id), EInvalidPoolForPosition);
        
        let reward = (clock.timestamp_ms() / 1000 - pos.stake_time) * pool.reward_rate;
        pos.stake_time = clock.timestamp_ms() / 1000;

        let reward_balance = balance::split(&mut pool.balance, reward);
        let reward_coin = coin::from_balance(reward_balance, ctx);

        event::emit(ClaimedRewards { account: account, reward: reward });

        reward_coin
    }
    
    public fun blacklist(account: address, state: bool, pool: &mut Pool, _: &BlacklistCap, ctx: &mut TxContext) {
        let current_state = pool.blacklist.borrow(account);
        assert!(current_state != state, EAccountInDesiredState);

        pool.blacklist.add(account, state);

        event::emit(BlacklistStateChanged { account: account, new_state: state });
    }

    public fun is_blacklisted(account: address, pool: &Pool): bool {
        if (!pool.blacklist.contains(account)) {
            return false
        };

        *pool.blacklist.borrow(account)
    }

    // pool
    public fun get_pool_id(pool: &Pool): ID {
        object::uid_to_inner(&pool.id)
    }

    public fun get_reward_rate(pool: &Pool): u64 {
        pool.reward_rate
    }

    public fun get_balance(pool: &Pool): u64 {
        balance::value(&pool.balance)
    }

    // position
    public fun get_position_value(pos: &Position): u64 {
        pos.value
    }

    public fun get_current_reward(pos: &Position, pool: &Pool, clock: &Clock): u64 {
        (clock.timestamp_ms() / 1000 - pos.stake_time) * pool.reward_rate
    }

    #[test_only]
    public fun receive_sui(coin: Coin<SUI>, pool: &mut Pool) {
        let coin_balance = coin::into_balance(coin);
        balance::join(&mut pool.balance, coin_balance);
    }

    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext): (AdminCap, BlacklistCap) {
        (
            AdminCap { id: object::new(ctx) }, 
            BlacklistCap { id: object::new(ctx) }
        )
    }
}
