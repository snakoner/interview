

module staking_contract::staking_test {
    use sui::test_scenario;
    use sui::test_utils;
    use staking_contract::staking::{Self};
    use std::debug;
    use sui::coin::{Self};
    use sui::sui::SUI;
    use sui::clock::{Self};
    use std::ascii::String;
    use std::string;

    const ADMIN: address = @0x0011;
    const BLACKLISTER: address = @0x0012;
    const STAKER: address = @0x0013;

    // stake
    const REWARD_RATE: u64 = 1;
    const STAkE_AMOUNT: u64 = 100_000; // SUI
    const UPDATE_TIME: u64 = 1_000_000; // 1000 sec
    const INIT_TIME: u64 = 1747903670;

    #[test]
    fun test_stake_and_claim_rewards() {
        let mut scenario = test_scenario::begin(ADMIN);

        // clock
        let mut clock = clock::create_for_testing(scenario.ctx());
        clock.set_for_testing(INIT_TIME * 1000);

        debug::print(&clock.timestamp_ms());

        // caps
        let (admin_cap, blacklist_cap) = staking::init_for_testing(scenario.ctx());

        // create pool
        let mut pool = staking::create_pool(REWARD_RATE, &admin_cap, scenario.ctx());
        assert!(pool.get_reward_rate() == REWARD_RATE);
        assert!(pool.get_balance() == 0);

        scenario.next_tx(STAKER);
        // stake
        let mut position = staking::stake(
            coin::mint_for_testing<SUI>(STAkE_AMOUNT, scenario.ctx()), 
            &clock, 
            &mut pool, 
            scenario.ctx(),
        );
    
        assert!(pool.get_balance() == STAkE_AMOUNT);
        assert!(position.get_position_value() == STAkE_AMOUNT);
        assert!(position.get_current_reward(&pool, &clock) == 0); // clock the same

        // update clock timestamp
        let current_timestamp = clock.timestamp_ms();
        clock.set_for_testing(current_timestamp + UPDATE_TIME);

        let calculated_reward = UPDATE_TIME / 1000 * REWARD_RATE;
        assert!(&position.get_current_reward(&pool, &clock) == calculated_reward);

        let reward_coin = staking::claim_rewards(&mut position, &mut pool, &clock, scenario.ctx());
        assert!(&coin::value(&reward_coin) == calculated_reward);
        assert!(pool.get_balance() == STAkE_AMOUNT - calculated_reward);
        
        test_utils::destroy(admin_cap);
        test_utils::destroy(blacklist_cap);
        test_utils::destroy(pool);
        test_utils::destroy(clock);
        test_utils::destroy(reward_coin);
        test_utils::destroy(position);

        scenario.end();
    }

    #[test]
    fun test_stake_and_unstake() {
        let mut scenario = test_scenario::begin(ADMIN);

        // clock
        let mut clock = clock::create_for_testing(scenario.ctx());
        clock.set_for_testing(INIT_TIME * 1000);

        debug::print(&clock.timestamp_ms());

        // caps
        let (admin_cap, blacklist_cap) = staking::init_for_testing(scenario.ctx());

        // create pool
        let mut pool = staking::create_pool(REWARD_RATE, &admin_cap, scenario.ctx());
        assert!(pool.get_reward_rate() == REWARD_RATE);
        assert!(pool.get_balance() == 0);

        scenario.next_tx(STAKER);

        // stake
        let mut position = staking::stake(
            coin::mint_for_testing<SUI>(STAkE_AMOUNT, scenario.ctx()), 
            &clock, 
            &mut pool, 
            scenario.ctx(),
        );
    
        // update clock timestamp
        let current_timestamp = clock.timestamp_ms();
        clock.set_for_testing(current_timestamp + UPDATE_TIME);

        let calculated_reward = UPDATE_TIME / 1000 * REWARD_RATE;
        assert!(&position.get_current_reward(&pool, &clock) == calculated_reward);

        // update pool balance for test
        let update_balance_coin = coin::mint_for_testing<SUI>(10000000, scenario.ctx());
        staking::receive_sui(update_balance_coin, &mut pool);

        let unstake_coin = staking::unstake(position, &mut pool, &clock, scenario.ctx());

        assert!(&coin::value(&unstake_coin) == STAkE_AMOUNT + calculated_reward);

        test_utils::destroy(admin_cap);
        test_utils::destroy(blacklist_cap);
        test_utils::destroy(pool);
        test_utils::destroy(clock);
        test_utils::destroy(unstake_coin);

        scenario.end();
    }

    #[test]
    fun test_blacklist() {
        let mut scenario = test_scenario::begin(ADMIN);

        // clock
        let mut clock = clock::create_for_testing(scenario.ctx());
        clock.set_for_testing(INIT_TIME * 1000);

        // caps
        let (admin_cap, blacklist_cap) = staking::init_for_testing(scenario.ctx());

        // create pool
        let mut pool = staking::create_pool(REWARD_RATE, &admin_cap, scenario.ctx());
        assert!(pool.get_reward_rate() == REWARD_RATE);
        assert!(pool.get_balance() == 0);

        staking::blacklist(STAKER, true, &mut pool, &blacklist_cap,scenario.ctx());

        scenario.next_tx(STAKER);

        // stake
        let mut position = staking::stake(
            coin::mint_for_testing<SUI>(STAkE_AMOUNT, scenario.ctx()), 
            &clock, 
            &mut pool, 
            scenario.ctx(),
        );

        test_utils::destroy(admin_cap);
        test_utils::destroy(blacklist_cap);
        test_utils::destroy(pool);
        test_utils::destroy(clock);
        test_utils::destroy(position);

        scenario.end();
    }
}
