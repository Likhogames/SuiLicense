module ProiProtocol::license {
    
    use std::string::{Self, String};

    use sui::coin::{Self, Coin};
    use sui::dynamic_object_field as dof;
    use sui::dynamic_field as df;
    use sui::object::{Self, ID, UID};
    use sui::transfer;
    use sui::event;
    use sui::tx_context::{Self, TxContext};

    const ENotPublisher: u64 = 0;
    const ENotOwner: u64 = 1;
    const EAmountIncorrect: u64 = 2;
    const ENotBuyer: u64 = 3;


    /// Game Publisher. 
    /// A Capability granting the bearer a right to `edit game info` 
    /// and 'listed, mint, regist license'
    struct GamePubCap has key, store{
        id: UID,
        for: ID
    }

    /// Objests
    struct Game has key, store {
        id: UID,
        name: String
//        link: String,
//        image_url : String,
//        thumbnail_url : String,
//        project_url : String,
//        description : String,
//        creator : address,
//        publish_date : String,
    }

    struct License<phantom COIN> has key, store {
        id: UID,
        price: u64,
        resale: bool,
        limit_auth: u64,
        seller: address
    }

    struct LicenseKey has key, store{
        id: UID,
        license_id: ID
    }

    /// Events
    struct GameListed has copy, drop{
        game: ID
    }

    /// Create game title. Would be publisher.
    public fun create_game(
        name_bytes: vector<u8>, 
        ctx: &mut TxContext
    ): (Game, GamePubCap) {
        let game = Game{
            id: object::new(ctx),
            name: string::utf8(name_bytes)
        };

        let cap = GamePubCap{
            id: object::new(ctx),
            for: object::id(&game)
        };

        event::emit(GameListed{game: object::id(&game)});
        (game, cap)
    }

    /// Create license. Only publisher
    public fun create_license<COIN>(
        game: &mut Game,
        cap: &GamePubCap,
        price: u64,
        resale: bool,
        limit_auth : u64,
        seller: address,
        ctx: &mut TxContext
    ): ID{
        assert!(object::id(game) == cap.for, ENotPublisher);
        
        let license = License<COIN> { 
                id : object::new(ctx), 
                price, 
                resale, 
                limit_auth,
                seller
        };
        let license_id = object::id(&license);
        dof::add(&mut game.id, license_id, license);
        license_id
    }

    /// User direct purchase license with coin
    public entry fun buy_license<COIN>(
        game: &mut Game,
        license_id: ID,
        paid: Coin<COIN>,   
        ctx: &mut TxContext
    ) {

        let price = check_paid<COIN>(game, license_id, &paid);

        // Settlement between seller and publisher
        // paid - price = seller profit
        let proceeds = coin::take(coin::balance_mut(&mut paid), price, ctx);

        // Stack to publisher
        if (dof::exists_<u64>(&mut game.id, 0)) {
            coin::join(
                dof::borrow_mut<u64, Coin<COIN>>(&mut game.id, 0),
                proceeds
            )
        } else {
            dof::add(&mut game.id, 0, proceeds);
        };

        // Stack to seller
        let License<COIN> {
            id: license_uid, 
            price: _, 
            resale: _, 
            limit_auth: _, 
            seller
        } = dof::borrow_mut(&mut game.id, license_id);

        if (dof::exists_<address>(license_uid, *seller)) {
            coin::join(
                dof::borrow_mut<address, Coin<COIN>>(license_uid, *seller),
                paid
            )
        } else {
            dof::add(license_uid, *seller, paid);
        };


        // Mint and send license key to buyer
        let license_key = LicenseKey{
            id: object::new(ctx),
            license_id: license_id
            };
        df::add<ID, address>(license_uid, object::id(&license_key), tx_context::sender(ctx));
        transfer::public_transfer(license_key, tx_context::sender(ctx))
    }

    public fun check_paid<COIN>(
        game: &mut Game,
        license_id: ID,
        paid: &Coin<COIN>
    ): u64{
        // Check seller
        let License<COIN> {
            id: _, 
            price, 
            resale: _, 
            limit_auth: _, 
            seller: _
        } = dof::borrow_mut(&mut game.id, license_id);

        // Check paid
        assert!(*price <= coin::value(paid), EAmountIncorrect);

        *price
    }

    /// Call function for seller giving license to user 
    /// after User purchase license by other system(Credit Card).
    public entry fun buy_license_callback<COIN>(
        game: &mut Game,
        license_id: ID,
        buyer: address,
        ctx: &mut TxContext
    ) {

        // Check seller
        let License<COIN> {
            id: license_uid, 
            price: _, 
            resale: _, 
            limit_auth: _, 
            seller
        } = dof::borrow_mut(&mut game.id, license_id);
        assert!(*seller == tx_context::sender(ctx), ENotOwner);

        let license_key = LicenseKey{
            id: object::new(ctx),
            license_id: license_id
            };
            
        df::add<ID, address>(license_uid, object::id(&license_key), buyer);
        transfer::public_transfer(license_key, buyer)
    }

    /// License authentication.
    /// Only buyers can pass through.
    public entry fun auth<COIN>(
        game: &mut Game,
        license_key: &LicenseKey,
        ctx: &mut TxContext
    ) {
        let License<COIN> {
            id: license_uid, 
            price: _, 
            resale: _, 
            limit_auth: _, 
            seller: _
        } = dof::borrow_mut(&mut game.id, license_key.license_id);

        let buyer = df::borrow<ID, address>(license_uid, object::id(license_key));

        // [TODO] Check limit auth count
        // ...
        // ...

        assert!(*buyer == tx_context::sender(ctx), ENotBuyer)
    }

    /// Transaction between users.
    public entry fun change_buyer<COIN>(
        game: &mut Game,
        license_key: &LicenseKey,
        new_buyer: address,
        ctx: &mut TxContext
    ){

        let License<COIN> {
            id: license_uid, 
            price: _, 
            resale: _, 
            limit_auth: _, 
            seller: _
        } = dof::borrow_mut(&mut game.id, license_key.license_id);

        let buyer = df::borrow<ID, address>(license_uid, object::id(license_key));
        assert!(*buyer == tx_context::sender(ctx), ENotBuyer);

        // [TODO] Check resale is possible
        // ...
        // ...

        // [TODO] Send fee to Publisher or Creator or Seller
        // ...
        // ...

        // Change buyer
        df::add(license_uid, object::id(license_key), new_buyer);
    }

    /// Transfer Coin to the publisher.
    public entry fun take_proceeds<COIN>(
        game: &mut Game,
        cap: &GamePubCap,
        ctx: &mut TxContext
    ) {
        assert!(object::id(game) == cap.for, ENotPublisher);

        let proceeds = dof::remove<u64, Coin<COIN>>(&mut game.id, 0);

        transfer::public_transfer(proceeds, tx_context::sender(ctx))
    }
}

#[test_only]
module ProiProtocol::Tests {
    use ProiProtocol::license::{Self, LicenseKey};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::test_scenario;
    use std::debug;
    use sui::transfer;

    const LIKHO:address = @0xBABE;
    const COMPANY1:address = @0xCAFE;
    const COMPANY2:address = @0xFACE;
    const USER1:address = @0x00A;
    const USER2:address = @0x00B;

    #[test]
    fun test_market(){
        let scenario = test_scenario::begin(LIKHO);

        // Create Game Title
        test_scenario::next_tx(&mut scenario, COMPANY1);
        let (game, cap) = license::create_game(
            b"Blizzard",
            test_scenario::ctx(&mut scenario)
        );
        //let mkp_val = test_scenario::take_shared<CompanyMarket<SUI>>(&mut scenario);
        debug::print(&game);

        // Create License
        test_scenario::next_tx(&mut scenario, COMPANY1);
        let license_id = license::create_license<SUI>(
            &mut game,
            &cap,
            100,
            false,
            3,
            COMPANY1,
            test_scenario::ctx(&mut scenario)
        );
        
        // Give License By Companey
        license::buy_license_callback<SUI>(
            &mut game,
            license_id,
            USER1,
            test_scenario::ctx(&mut scenario)
        );

        
        // Buy License
        // - mint test sui
        test_scenario::next_tx(&mut scenario, LIKHO);
        let coin = coin::mint_for_testing<SUI>(1000, test_scenario::ctx(&mut scenario));
        transfer::public_transfer(coin, USER2);
        
        // - buy license
        test_scenario::next_tx(&mut scenario, USER2);
        let user_coin = test_scenario::take_from_sender<Coin<SUI>>(&mut scenario);
        let payment = coin::take(coin::balance_mut(&mut user_coin), 100, test_scenario::ctx(&mut scenario));
        license::buy_license<SUI>(
            &mut game,
            license_id,
            payment,
            test_scenario::ctx(&mut scenario)
        );
        test_scenario::return_to_sender(&mut scenario, user_coin);


        // Auth License USER1
        test_scenario::next_tx(&mut scenario, USER1);
        let user1_key = test_scenario::take_from_address<LicenseKey>(&mut scenario, USER1);
        license::auth<SUI>(
            &mut game,
            &user1_key,
            test_scenario::ctx(&mut scenario)
        );
        test_scenario::return_to_address(USER1, user1_key);

        
        // Auth License USER2
        test_scenario::next_tx(&mut scenario, USER2);
        let user2_key = test_scenario::take_from_sender<LicenseKey>(&mut scenario);
         license::auth<SUI>(
            &mut game,
            &user2_key,
            test_scenario::ctx(&mut scenario)
        );
        test_scenario::return_to_sender(&mut scenario, user2_key);


        // Auth License
        test_scenario::next_tx(&mut scenario, COMPANY1);
        license::take_proceeds<SUI>(
            &mut game,
            &cap,
            test_scenario::ctx(&mut scenario)
        );


        // Check Coin
        test_scenario::next_tx(&mut scenario, LIKHO);
        let company_coin = test_scenario::take_from_address<Coin<SUI>>(&mut scenario, COMPANY1);
        debug::print(&company_coin);
        test_scenario::return_to_address(COMPANY1, company_coin);

        
        // End Test
        transfer::public_transfer(game, COMPANY1);
        transfer::public_transfer(cap, COMPANY1);
        test_scenario::end(scenario);        
        
    }
}