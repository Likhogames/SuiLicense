module ProiProtocol::shop {
    
    use std::string::{Self, String};
    //use std::vector;

    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::dynamic_object_field as dof;
    use sui::dynamic_field as df;
    use sui::object::{Self, ID, UID};
    use sui::transfer;
    use sui::event;
    use sui::tx_context::{Self, TxContext};
    use sui::vec_map::{Self,VecMap};
    use sui::object_bag::{Self, ObjectBag};

    use ProiProtocol::proi::{PROI};

    const ENotPublisher: u64 = 0;
    const EAlreadyExistGameID: u64 = 1;
    const ENotExistGameID: u64 = 2;
    const ENotExistLicenseID: u64 = 3;
    const EInsufficientFee: u64 = 4;
    const EInsufficientFunds: u64 = 5;
    const ENotOwner: u64 = 6;
    const EInvalidDiscountRate: u64 = 7;
    const ENotEnoughAuthCount: u64 = 8;
    const ENotAllowedResell: u64 = 9;
    const ENotExistItemID: u64 = 10;

    const MaxDiscount: u64 = 10000;
    const MaxPurchaseFeeRate: u64 = 10000;

    // Game Publisher. 
    // A Capability granting the bearer a right to `edit game info` 
    // and 'listed, mint, regist license'
    struct GamePubCap has key, store{
        id: UID,
        for: ID
    }

    // Objests
    struct ProiShop has key {
        id: UID,
        submission_fee: u64,    // PROI. Update with Oracle (ex Switchboard)
        purchase_fee_rate: u64,  // Basis point
        game_list: VecMap<String, Game>,
        purchase_fee_storage: PurchaseFeeStorage,
        submission_fee_storage: SubmissionFeeStorage
    }

    struct ResellerShop has key {
        id: UID,
        game_list: VecMap<String, ObjectBag>    // key : game_id, val : listed ResellerItem
    }
    
    struct ResellerItem has key, store {
        id: UID,
        reseller: String,
        description: String,
        price: u64,
        item: LicenseKey
    }
    
    struct SubmissionFeeStorage has key, store {
        id: UID,
        fees: Balance<PROI>
    }

    struct PurchaseFeeStorage has key, store{
        id: UID,
        fees: Balance<PROI>
    }

    struct Game has key, store {
        id: UID,
        game_id: String,
        name: String,
        license_list: VecMap<ID, License> 
    }

    struct License has key, store {
        id: UID,
        name: String,
        thumbnail: String,
        short_intro: VecMap<String, String>,
        publisher_price: u64,
        discount_rate: u64,
        royalty_rate: u64,
        permit_resale: bool,
        limit_auth_count: u64,
    }

    struct LicenseKey has key, store{
        id: UID,
        game_id: String,
        license_id: ID,
        auth_count: u64,
        license_name: String,
        license_thumbnail: String,
        owner: address,
        user: address
    }

    // Events
    struct RegisterGameEvent has copy, drop{
        game_id: String
    }
    struct CreateLicenseEvent has copy, drop{
        game_id: String,
        license_id: ID
    }
    struct PurchaseEvent has copy, drop{
        game_id: String,
        license_id: ID,
        license_key_id: ID
    }
    struct ResellEvent has copy, drop{
        game_id: String,
        item_id: ID
    }

    // Function
    fun init(ctx: &mut TxContext) {        
        let p_storage = PurchaseFeeStorage{
            id: object::new(ctx),
            fees: balance::zero<PROI>()
        };
        let s_storage = SubmissionFeeStorage{
            id: object::new(ctx),
            fees: balance::zero<PROI>()
        };

        transfer::share_object(ProiShop {
            id: object::new(ctx),
            submission_fee: 100,
            purchase_fee_rate: 5,
            game_list: vec_map::empty<String, Game>(),
            purchase_fee_storage: p_storage,
            submission_fee_storage: s_storage
        });

        transfer::share_object(ResellerShop {
            id: object::new(ctx),
            game_list: vec_map::empty<String, ObjectBag>()
        });
    }

    // Regist game. Would be publisher.
    public entry fun regist_game(
        proi_shop: &mut ProiShop,
        game_id_bytes: vector<u8>,
        name_bytes: vector<u8>,
        submission_fee: Coin<PROI>,
        ctx: &mut TxContext
    ) {
        // Check game_id
        let game_id = string::utf8(game_id_bytes);
        assert!(vec_map::contains(&proi_shop.game_list, &game_id) == false, EAlreadyExistGameID);
        
        // Check submit fee
        assert!(proi_shop.submission_fee == coin::value(&submission_fee), EInsufficientFee);
        df::add<String, u64>(&mut proi_shop.id, game_id, coin::value(&submission_fee));
        
        // Pay a fee
        let fee_storage = &mut proi_shop.submission_fee_storage;
        let balance_fee = coin::into_balance(submission_fee);
        balance::join(&mut fee_storage.fees, balance_fee);

        // Create Game object
        let game = Game{
            id: object::new(ctx),
            game_id,
            name: string::utf8(name_bytes),
            license_list: vec_map::empty<ID, License>(),
        };

        let cap = GamePubCap{
            id: object::new(ctx),
            for: object::id(&game)
        };
        let game_list = &mut proi_shop.game_list;
        vec_map::insert(game_list, game_id, game);

        // Transfer cpapbility
        transfer::transfer(cap, tx_context::sender(ctx));

        // Emit Event
        event::emit(RegisterGameEvent{game_id})
    }

    public entry fun update_game(){
        // TODO : Update Game Object
    }

    public entry fun create_license(
        proi_shop: &mut ProiShop,
        cap: &GamePubCap,
        game_id_bytes: vector<u8>,
        name_bytes: vector<u8>,
        thumbnail: vector<u8>,
        // short_intro: VecMap<String, String>,
        publisher_price: u64,
        discount_rate: u64,
        royalty_rate: u64,
        permit_resale: bool,
        limit_auth_count: u64,
        ctx: &mut TxContext
    ){
        // Data Validate
        assert!(discount_rate >= 0, EInvalidDiscountRate);
        assert!(discount_rate <= MaxDiscount, EInvalidDiscountRate);

        // Game Publisher Capability
        let game_id = string::utf8(game_id_bytes);
        assert!(vec_map::contains(&proi_shop.game_list, &game_id) == true, ENotExistGameID);
        
        let game = vec_map::get_mut(&mut proi_shop.game_list, &game_id);
        assert!(object::id(game) == cap.for, ENotPublisher);

        // Create License object
        let new_license = License{
            id: object::new(ctx),
            name: string::utf8(name_bytes),
            thumbnail: string::utf8(thumbnail),
            short_intro: vec_map::empty<String, String>(),
            publisher_price,
            discount_rate,
            royalty_rate,
            permit_resale,
            limit_auth_count,
        };
        let license_id = object::id(&new_license);
        vec_map::insert(&mut game.license_list, license_id, new_license);

        // Emit Event
        event::emit(CreateLicenseEvent{game_id, license_id})
    }

    public entry fun update_license(){
        // TODO : Update License Object
    } 

    public entry fun purchase(
        proi_shop: &mut ProiShop,
        game_id_bytes: vector<u8>,
        license_id: ID,
        paid: Coin<PROI>,
        buyer: address,
        ctx: &mut TxContext
    ){
        // Load License
        let game_id = string::utf8(game_id_bytes);
        let license = get_license(&proi_shop.game_list, &game_id, &license_id);
        
        // Discount
        let publisher_price = license.publisher_price;
        if (license.discount_rate > 0){
            publisher_price = publisher_price - (publisher_price * license.discount_rate / MaxDiscount);
        };
        assert!(publisher_price == coin::value(&paid), EInsufficientFunds);
        
        // Pay a fee
        if (publisher_price > 0){
            let fee = publisher_price - (publisher_price * proi_shop.purchase_fee_rate / MaxPurchaseFeeRate);
            let purchase_fee = coin::take(coin::balance_mut(&mut paid), fee, ctx);
            let fee_storage = &mut proi_shop.purchase_fee_storage;
            balance::join(&mut fee_storage.fees, coin::into_balance(purchase_fee));
        };
        
        // Save paid
        if (dof::exists_<String>(&proi_shop.id, game_id)) {
            coin::join(
                dof::borrow_mut<String, Coin<PROI>>(&mut proi_shop.id, game_id),
                paid
            )
        } else {
            dof::add(&mut proi_shop.id, game_id, paid)
        };

        // Create LicenseKey
        let default_address:address = @0x00;
        let license_key = LicenseKey{
            id: object::new(ctx),
            game_id,
            license_id,
            auth_count: 0,
            license_name: license.name,
            license_thumbnail: license.thumbnail,
            owner: buyer,
            user: default_address
        };
        
        // Emit Event
        event::emit(PurchaseEvent{
            game_id,
            license_id,
            license_key_id: object::id(&license_key)
        });
        transfer::public_transfer(license_key, buyer)
    }

    public entry fun authenticate(
        proi_shop: &mut ProiShop,
        license_key: &mut LicenseKey,
        ctx: &mut TxContext
    ){
        // Check Owner
        let sender = tx_context::sender(ctx);
        assert!(license_key.owner == sender, ENotOwner);

        // Authenticate
        if (license_key.user != sender){
            let license = get_license(
                &proi_shop.game_list,
                &license_key.game_id,
                &license_key.license_id
            );

            assert!(license.limit_auth_count > license_key.auth_count, ENotEnoughAuthCount);

            license_key.auth_count = license_key.auth_count + 1;
            license_key.user = sender;
        };
    }

    public fun get_license(
        game_list: & VecMap<String, Game>,
        game_id: & String,
        license_id: & ID
    ): & License{
        assert!(vec_map::contains(game_list, game_id) == true, ENotExistGameID);
        let game = vec_map::get(game_list, game_id);
        assert!(vec_map::contains(&game.license_list, license_id) == true, ENotExistLicenseID);
        vec_map::get(& game.license_list, license_id)
    }

    public entry fun list_license_key(
        proi_shop: &mut ProiShop,
        reseller_shop: &mut ResellerShop,
        license_key: LicenseKey,
        reseller_bytes: vector<u8>,
        description_bytes: vector<u8>,
        price: u64,
        ctx: &mut TxContext
    ){
        // Check Owner
        let sender = tx_context::sender(ctx);
        assert!(license_key.owner == sender, ENotOwner);

        // Check permit resell
        let license = get_license(
            &proi_shop.game_list,
            &license_key.game_id,
            &license_key.license_id
        );
        assert!(license.permit_resale == true, ENotAllowedResell);

        // Check auth count
        assert!(license.limit_auth_count > license_key.auth_count, ENotEnoughAuthCount);
        
        // Create reselling item
        let game_id = license_key.game_id;
        let reseller = string::utf8(reseller_bytes);
        let description = string::utf8(description_bytes);
        let item = ResellerItem{
            id: object::new(ctx),
            reseller,
            description,
            price,
            item: license_key
        };

        // Save reselling list
        let game_list = &mut reseller_shop.game_list;
        if (vec_map::contains(game_list, &game_id) == true){
            let item_list = vec_map::get_mut(game_list, &game_id);
            object_bag::add(item_list, object::id(&item), item);
        }else{
            let item_list = object_bag::new(ctx);
            object_bag::add(&mut item_list, object::id(&item), item);
            vec_map::insert(game_list, game_id, item_list);
        };
    }

    public entry fun resell(
        proi_shop: &mut ProiShop,
        reseller_shop: &mut ResellerShop,
        game_id: & String,
        item_id: ID,
        paid: Coin<PROI>,
        ctx: &mut TxContext
    ){
        // Load Item
        let game_list = &mut reseller_shop.game_list;
        assert!(vec_map::contains(game_list, game_id) == true, ENotExistGameID);
        let item_list = vec_map::get_mut(game_list, game_id);
        assert!(object_bag::contains_with_type<ID, LicenseKey>(item_list, item_id) == true, ENotExistItemID);
        let item_info = object_bag::borrow<ID, ResellerItem>(item_list, item_id);

        // Check paid
        assert!(item_info.price == coin::value(&paid), EInsufficientFunds);

        // Royalty
        let license_key = &item_info.item;
        let license = get_license(
            &proi_shop.game_list,
            &license_key.game_id,
            &license_key.license_id
        );

        if (license.royalty_rate > 0){
            
        };

        // Save paid

        // Transfer item
    }

    // // User direct purchase license with coin
    // public fun buy_license<COIN>(
    //     game: &mut Game,
    //     license_id: ID,
    //     paid: Coin<COIN>,   
    //     ctx: &mut TxContext
    // ) {

    //     // Coin stack to seller
    //     let License<COIN> {
    //         id: license_uid, 
    //         price, 
    //         resale: _, 
    //         limit_auth: _, 
    //         seller
    //     } = dof::borrow_mut(&mut game.id, license_id);
    //     assert!(*price == coin::value(&paid), EAmountIncorrect);
        
    //     if (dof::exists_<address>(license_uid, *seller)) {
    //         coin::join(
    //             dof::borrow_mut<address, Coin<COIN>>(license_uid, *seller),
    //             paid
    //         )
    //     } else {
    //         dof::add(license_uid, *seller, paid)
    //     };

    //     // Mint and send license key to buyer
    //     let license_key = LicenseKey{
    //         id: object::new(ctx),
    //         license_id: license_id
    //         };
    //     df::add<ID, address>(license_uid, object::id(&license_key), tx_context::sender(ctx));
    //     transfer::public_transfer(license_key, tx_context::sender(ctx))
    // }

    // // Call function for seller giving license to user 
    // // after User purchase license by other system.
    // public fun buy_license_callback<COIN>(
    //     game: &mut Game,
    //     license_id: ID,
    //     buyer: address,
    //     ctx: &mut TxContext
    // ) {

    //     // Check seller
    //     let License<COIN> {
    //         id: license_uid, 
    //         price: _, 
    //         resale: _, 
    //         limit_auth: _, 
    //         seller
    //     } = dof::borrow_mut(&mut game.id, license_id);
    //     assert!(*seller == tx_context::sender(ctx), ENotOwner);

    //     let license_key = LicenseKey{
    //         id: object::new(ctx),
    //         license_id: license_id
    //         };
            
    //     df::add<ID, address>(license_uid, object::id(&license_key), buyer);
    //     transfer::public_transfer(license_key, buyer)
    // }

    // // License authentication.
    // // Only buyers can pass through.
    // public fun auth<COIN>(
    //     license: &mut License<COIN>,
    //     license_key: &LicenseKey,
    //     ctx: &mut TxContext
    // ) {
    //     let buyer = df::borrow<ID, address>(&mut license.id, object::id(license_key));

    //     // [TODO] Check limit auth count
    //     // ...
    //     // ...

    //     assert!(*buyer == tx_context::sender(ctx), ENotBuyer)
    // }

    // // Transaction between users.
    // public fun change_buyer<COIN>(
    //     license: &mut License<COIN>,
    //     license_key: &LicenseKey,
    //     new_buyer: address,
    //     ctx: &mut TxContext
    // ){
    //     auth(license, license_key, ctx);

    //     // [TODO] Check resale is possible
    //     // ...
    //     // ...

    //     // [TODO] Send fee to Publisher or Creator or Seller
    //     // ...
    //     // ...

    //     // Change buyer
    //     df::add(&mut license.id, object::id(license_key), new_buyer)
    // }

    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(ctx)
    }
}