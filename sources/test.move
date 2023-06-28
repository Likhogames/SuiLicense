#[test_only]
module ProiProtocol::Tests {
    use ProiProtocol::shop::{Self, ProiShop, ProiCap, GamePubCap, LicenseKey, ResellerShop};
    use ProiProtocol::proi::{Self, PROI};
    
    use std::debug;
    use std::string::{Self};
    use std::vector;
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::object;
    use sui::test_scenario;

    const PROILAB:address = @0xBABE;
    const PUBLISHER:address = @0xCAFE;
    const SELLER:address = @0xFACE;
    const USER1:address = @0x00A;
    const USER2:address = @0x00B;
    const GAME_ID_BYTES:vector<u8> = b"com.blizzard.diablo4";

    #[test]
    fun test_market(){
        let scenario_val = test_scenario::begin(PROILAB);
        let scenario = &mut scenario_val;
        
        {
            let ctx = test_scenario::ctx(scenario);
            shop::init_for_testing(ctx);
            proi::init_for_testing(ctx);
        };

        test_scenario::next_tx(scenario, PROILAB);
        {
            let t_cap = test_scenario::take_from_sender<TreasuryCap<PROI>>(scenario);
            let ctx = test_scenario::ctx(scenario);
            proi::mint(
                &mut t_cap,
                proi_with_decimal(100),
                PUBLISHER,
                ctx
            );

            proi::mint(
                &mut t_cap,
                proi_with_decimal(200),
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
            let submission_fee = coin::take(coin::balance_mut(&mut company_coin), proi_with_decimal(100), ctx);

            let v_image_url = vector::empty<vector<u8>>();
            vector::push_back(&mut v_image_url, b"ipfs://{image_1}");
            vector::push_back(&mut v_image_url, b"ipfs://{image_2}");
            let v_video_url = vector::empty<vector<u8>>();
            vector::push_back(&mut v_video_url, b"ipfs://{video_1}");
            vector::push_back(&mut v_video_url, b"ipfs://{video_2}");
            let v_short_intro = vector::empty<vector<vector<u8>>>();
            let v_pair = vector::empty<vector<u8>>();
            vector::push_back(&mut v_pair, b"en");
            vector::push_back(&mut v_pair, b"short intro.");
            vector::push_back(&mut v_short_intro, v_pair);
            let v_language = vector::empty<vector<u8>>();
            vector::push_back(&mut v_language, b"en");
            vector::push_back(&mut v_language, b"zh");
            let v_platform = vector::empty<vector<u8>>();
            vector::push_back(&mut v_platform, b"pc");
            vector::push_back(&mut v_platform, b"ps");

            shop::regist_game(
                &mut proi_shop,
                GAME_ID_BYTES,
                b"Blizzard",
                b"ipfs://{thumbnail}",
                v_image_url,
                v_video_url,
                v_short_intro,
                b"intro",
                b"2024-01-01",
                b"puzzle",
                b"blizzard",
                b"blizzard",
                v_language,
                v_platform,
                b"system_requirements",
                false,
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
            let v_short_intro = vector::empty<vector<vector<u8>>>();
            let v_pair = vector::empty<vector<u8>>();
            vector::push_back(&mut v_pair, b"en");
            vector::push_back(&mut v_pair, b"short intro.");
            vector::push_back(&mut v_short_intro, v_pair);

            shop::create_license(
                &mut proi_shop,
                &cap,
                GAME_ID_BYTES,
                b"Digital Edition",
                b"ipfs://{img_url}",
                v_short_intro,
                70,
                0,
                500,
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
            let proi_shop = test_scenario::take_shared<ProiShop>(scenario);
            let seller_coin = test_scenario::take_from_sender<Coin<PROI>>(scenario);
            let ctx = test_scenario::ctx(scenario);
            let paid = coin::take(coin::balance_mut(&mut seller_coin), proi_with_decimal(70), ctx);

            let game_id = string::utf8(GAME_ID_BYTES);
            let game = shop::get_game_for_testing(&proi_shop, &game_id);
            let license = shop::get_license_by_idx(game, 0);

            shop::purchase(
                &mut proi_shop,
                GAME_ID_BYTES,
                object::id(license),
                paid,
                USER1,
                ctx
            );

            debug::print(&proi_shop);
            test_scenario::return_to_sender(scenario, seller_coin);
            test_scenario::return_shared(proi_shop);
        };

        // Authenticate USER1
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

        // List licensekey for reselling
        test_scenario::next_tx(scenario, USER1);
        {
            let proi_shop = test_scenario::take_shared<ProiShop>(scenario);
            let reseller_shop = test_scenario::take_shared<ResellerShop>(scenario);
            let license_key = test_scenario::take_from_sender<LicenseKey>(scenario);
            let ctx = test_scenario::ctx(scenario);

            shop::list_license_key(
                &mut proi_shop,
                &mut reseller_shop,
                license_key,
                b"User1",
                b"Daiblo4 License key",
                50,
                ctx
            );
            debug::print(&reseller_shop);
            test_scenario::return_shared(reseller_shop);
            test_scenario::return_shared(proi_shop);
        };

        // Resell
        test_scenario::next_tx(scenario, SELLER);
        {
            let proi_shop = test_scenario::take_shared<ProiShop>(scenario);
            let reseller_shop = test_scenario::take_shared<ResellerShop>(scenario);
            let seller_coin = test_scenario::take_from_sender<Coin<PROI>>(scenario);
            let ctx = test_scenario::ctx(scenario);

            let paid = coin::take(coin::balance_mut(&mut seller_coin), proi_with_decimal(50), ctx);
            let item_id = shop::get_item_id_by_idx_for_testing(&reseller_shop,0);

            shop::resell(
                &mut proi_shop,
                &mut reseller_shop,
                GAME_ID_BYTES,
                item_id,
                paid,
                USER2,
                ctx
            );
            
            test_scenario::return_to_sender(scenario, seller_coin);
            test_scenario::return_shared(reseller_shop);
            test_scenario::return_shared(proi_shop);
        };
        
        // Authenticate USER2
        test_scenario::next_tx(scenario, USER2);
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


        // Take fees
        test_scenario::next_tx(scenario, PROILAB);
        {
            let proi_shop = test_scenario::take_shared<ProiShop>(scenario);
            let proi_cap = test_scenario::take_from_sender<ProiCap>(scenario);
            let ctx = test_scenario::ctx(scenario);
            shop::take_proi_for_labs(
                &mut proi_shop,
                &proi_cap,
                ctx
            );

            test_scenario::return_to_sender(scenario, proi_cap);
            test_scenario::return_shared(proi_shop);
        };
        test_scenario::next_tx(scenario, PROILAB);
        {
            let coin = test_scenario::take_from_sender<Coin<PROI>>(scenario);
            debug::print(& coin);

            test_scenario::return_to_sender(scenario, coin);
        };

        // Take fees for purchase
        test_scenario::next_tx(scenario, PUBLISHER);
        {
            let proi_shop = test_scenario::take_shared<ProiShop>(scenario);
            let game_cap = test_scenario::take_from_sender<GamePubCap>(scenario);
            let ctx = test_scenario::ctx(scenario);
            shop::take_proi_for_publisher(
                &mut proi_shop,
                &game_cap,
                GAME_ID_BYTES,
                ctx
            );

            test_scenario::return_to_sender(scenario, game_cap);            
            test_scenario::return_shared(proi_shop);
        };
        test_scenario::next_tx(scenario, PUBLISHER);
        {
            let coin = test_scenario::take_from_sender<Coin<PROI>>(scenario);
            debug::print(& coin);

            test_scenario::return_to_sender(scenario, coin);
        };


        // Take fees for user
        test_scenario::next_tx(scenario, USER1);
        {
            let reseller_shop = test_scenario::take_shared<ResellerShop>(scenario);
            let ctx = test_scenario::ctx(scenario);
            shop::take_proi_for_reseller(
                &mut reseller_shop,
                ctx
            );

            test_scenario::return_shared(reseller_shop);
        };
        test_scenario::next_tx(scenario, USER1);
        {
            let coin = test_scenario::take_from_sender<Coin<PROI>>(scenario);
            debug::print(& coin);

            test_scenario::return_to_sender(scenario, coin);
        };

        // Take fees for royalty
        test_scenario::next_tx(scenario, PUBLISHER);
        {
            let proi_shop = test_scenario::take_shared<ProiShop>(scenario);
            let reseller_shop = test_scenario::take_shared<ResellerShop>(scenario);
            let game_cap = test_scenario::take_from_sender<GamePubCap>(scenario);
            let ctx = test_scenario::ctx(scenario);
            shop::take_proi_for_royalty(
                &mut proi_shop,
                &mut reseller_shop,
                &game_cap,
                GAME_ID_BYTES,
                ctx
            );

            test_scenario::return_to_sender(scenario, game_cap);            
            test_scenario::return_shared(reseller_shop);
            test_scenario::return_shared(proi_shop);
        };
        test_scenario::next_tx(scenario, PUBLISHER);
        {
            let coin = test_scenario::take_from_sender<Coin<PROI>>(scenario);
            debug::print(& coin);

            test_scenario::return_to_sender(scenario, coin);
        };
        

        test_scenario::end(scenario_val);        
        
    }

    fun proi_with_decimal(amount: u64): u64{
        amount * proi::get_decimal()
    }
}