#[test_only]
module ProiProtocol::Tests {
    use ProiProtocol::shop::{Self, ProiShop, GamePubCap, LicenseKey};
    use ProiProtocol::proi::{Self, PROI};
    
    use std::debug;
//    use std::string::{Self, String};
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::object;
    use sui::test_scenario;
//    use sui::vec_map::{Self, VecMap};
//    use sui::transfer;

    const LIKHO:address = @0xBABE;
    const PUBLISHER:address = @0xCAFE;
    const SELLER:address = @0xFACE;
    const USER1:address = @0x00A;
    const USER2:address = @0x00B;

    #[test]
    fun test_market(){
        let scenario_val = test_scenario::begin(LIKHO);
        let scenario = &mut scenario_val;
        
        {
            let ctx = test_scenario::ctx(scenario);
            shop::init_for_testing(ctx);
            proi::init_for_testing(ctx);
        };

        test_scenario::next_tx(scenario, LIKHO);
        {
            let t_cap = test_scenario::take_from_sender<TreasuryCap<PROI>>(scenario);
            let ctx = test_scenario::ctx(scenario);
            proi::mint(
                &mut t_cap,
                100,
                PUBLISHER,
                ctx
            );

            proi::mint(
                &mut t_cap,
                100,
                SELLER,
                ctx
            );
            test_scenario::return_to_sender(scenario, t_cap);
        };
        
        // Regist Game Title
        test_scenario::next_tx(scenario, PUBLISHER);
        {
            let proi_shop = test_scenario::take_shared<ProiShop>(scenario);
            let company_coin = test_scenario::take_from_sender<Coin<PROI>>(scenario);
            let ctx = test_scenario::ctx(scenario);

            let submission_fee = coin::take(coin::balance_mut(&mut company_coin), 100, ctx);
            shop::regist_game(
                &mut proi_shop,
                b"com.blizzard.diablo4",
                b"Blizzard",
                submission_fee,
                ctx
            );
            

            test_scenario::return_to_sender(scenario, company_coin);
            test_scenario::return_shared(proi_shop);
        };

        // Create License
        test_scenario::next_tx(scenario, PUBLISHER);
        {
            let proi_shop = test_scenario::take_shared<ProiShop>(scenario);
            let cap = test_scenario::take_from_sender<GamePubCap>(scenario);
            let ctx = test_scenario::ctx(scenario);

            shop::create_license(
                &mut proi_shop,
                &cap,
                b"com.blizzard.diablo4",
                b"Digital Edition",
                b"https://ipfs",
                70,
                0,
                5,
                true,
                3,
                ctx
            );
            debug::print(&proi_shop);
            test_scenario::return_to_sender(scenario, cap);
            test_scenario::return_shared(proi_shop);
        };

        // Purchase
        test_scenario::next_tx(scenario, SELLER);
        {
            let game_id_bytes = b"com.blizzard.diablo4";
            let proi_shop = test_scenario::take_shared<ProiShop>(scenario);
            let seller_coin = test_scenario::take_from_sender<Coin<PROI>>(scenario);
            let ctx = test_scenario::ctx(scenario);
            let paid = coin::take(coin::balance_mut(&mut seller_coin), 70, ctx);

            shop::purchase(
                &mut proi_shop,
                game_id_bytes,
                object::id_from_address(@0x75c3360eb19fd2c20fbba5e2da8cf1a39cdb1ee913af3802ba330b852e459e05),
                paid,
                USER1,
                ctx
            );

            debug::print(&proi_shop);
            test_scenario::return_to_sender(scenario, seller_coin);
            test_scenario::return_shared(proi_shop);
        };

        // Authenticate
        test_scenario::next_tx(scenario, USER1);
        {
            let proi_shop = test_scenario::take_shared<ProiShop>(scenario);
            let license_key = test_scenario::take_from_sender<LicenseKey>(scenario);
            let ctx = test_scenario::ctx(scenario);

            shop::authenticate(
                &mut proi_shop,
                &mut license_key,
                ctx
            );
            debug::print(&license_key);
            test_scenario::return_to_sender(scenario, license_key);
            test_scenario::return_shared(proi_shop);
        };

        // // Give License By Companey
        // license::buy_license_callback<SUI>(
        //     &mut game,
        //     license_id,
        //     USER1,
        //     test_scenario::ctx(&mut scenario)
        // );

        
        // // Buy License
        // // - mint test sui
        // test_scenario::next_tx(&mut scenario, LIKHO);
        // let coin = coin::mint_for_testing<SUI>(1000, test_scenario::ctx(&mut scenario));
        // transfer::public_transfer(coin, USER2);
        
        // // - buy license
        // test_scenario::next_tx(&mut scenario, USER2);
        // let user_coin = test_scenario::take_from_sender<Coin<SUI>>(&mut scenario);
        // let payment = coin::take(coin::balance_mut(&mut user_coin), 100, test_scenario::ctx(&mut scenario));
        // license::buy_license<SUI>(
        //     &mut game,
        //     license_id,
        //     payment,
        //     test_scenario::ctx(&mut scenario)
        // );
        // test_scenario::return_to_sender(&mut scenario, user_coin);


        // // Check
        // let user1_key = test_scenario::take_from_address<LicenseKey>(&mut scenario, USER1);
        // debug::print(&user1_key);
        // test_scenario::return_to_address(USER1, user1_key);

        
        // // Check
        // // let user2_key = test_scenario::take_from_sender<LicenseKey>(&mut scenario);
        //  let ids = test_scenario::most_recent_id_for_sender<LicenseKey>(&mut scenario);
        //  debug::print(&ids);
        // // test_scenario::return_to_sender(&mut scenario, user2_key);


        // // Auth License

        
        // // End Test
        // transfer::public_transfer(game, COMPANY1);
        // transfer::public_transfer(cap, COMPANY1);
        test_scenario::end(scenario_val);        
        
    }
}