// Copyright (c) ProiProtocol, Inc.
module ProiProtocol::shop {
    
    use std::string::{Self, String};

    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::dynamic_object_field as dof;
    use sui::dynamic_field as df;
    use sui::object::{Self, ID, UID};
    use sui::transfer;
    use sui::event;
    use sui::tx_context::{Self, TxContext};
    use sui::vec_map::{Self,VecMap};

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
    const EOutOfIndex: u64 = 11;

    const MaxDiscount: u64 = 10000;
    const MaxPurchaseFeeRate: u64 = 10000;
    const MaxRoyaltyRate: u64 = 10000;

    // Objests
    struct ProiShop has key {
        id: UID,
        submission_fee: u64,    // PROI. Update with Oracle (ex Switchboard)
        purchase_fee_rate: u64, 
        game_list: VecMap<String, Game>,
        purchase_fee_storage: PurchaseFeeStorage,
        submission_fee_storage: SubmissionFeeStorage
    }

    struct Game has key, store {
        id: UID,
        game_id: String,
        name: String,
        // For testing purposes, other fields have been omitted. 
        // You can refer to the API documentation for the omitted fields.
        license_list: VecMap<ID, License> 
    }

    struct GamePubCap has key, store{
        id: UID,
        for: ID
    }

    struct PurchaseFeeStorage has key, store{
        id: UID,
        fees: Balance<PROI>
    }

    struct SubmissionFeeStorage has key, store {
        id: UID,
        fees: Balance<PROI>
    }

    struct ResellerShop has key {
        id: UID,
        item_list: VecMap<ID, ResellerItem> 
    }
    
    struct ResellerItem has key, store {
        id: UID,
        reseller: String,
        description: String,
        price: u64,
        item: LicenseKey
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

    /// Events
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
        item_id: ID
    }

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
            item_list: vec_map::empty<ID, ResellerItem>()
        });
    }

    // Regist game
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
        let proi_fee_amount = change_price_usd_to_proi(proi_shop.submission_fee);
        assert!(proi_fee_amount == coin::value(&submission_fee), EInsufficientFee);
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

    /// Create License
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

    /// Purchase License
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
        let proi_price = change_price_usd_to_proi(publisher_price);
        assert!(proi_price == coin::value(&paid), EInsufficientFunds);
        
        // Pay a fee
        if (proi_price > 0){
            let fee = proi_price - (proi_price * proi_shop.purchase_fee_rate / MaxPurchaseFeeRate);
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

    /// Authenticate in game sdk
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
    
    public fun get_game(
        proi_shop: & ProiShop,
        game_id: & String
    ): & Game{
        assert!(vec_map::contains(&proi_shop.game_list, game_id) == true, ENotExistGameID);
        vec_map::get(&proi_shop.game_list, game_id)
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

    public fun get_license_by_idx(
        game: & Game,
        idx: u64
    ): & License{
        assert!(vec_map::size(&game.license_list) > idx, EOutOfIndex);
        let (_, license) = vec_map::get_entry_by_idx(& game.license_list, idx);
        license
    }

    /// List LicenseKey for reselling
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
        let item_list = &mut reseller_shop.item_list;
        vec_map::insert(item_list, object::id(&item), item);
    }

    /// Resell Item
    public entry fun resell(
        proi_shop: &mut ProiShop,
        reseller_shop: &mut ResellerShop,
        game_id_bytes: vector<u8>,
        item_id: ID,
        paid: Coin<PROI>,
        buyer: address,
        ctx: &mut TxContext
    ){
        let game_id = string::utf8(game_id_bytes);

        // Load Item
        let item_list = &mut reseller_shop.item_list;
        assert!(vec_map::contains(item_list, &item_id) == true, ENotExistItemID);
        let item_info = vec_map::get<ID, ResellerItem>(item_list, &item_id);

        // Check paid
        let proi_price = change_price_usd_to_proi(item_info.price);
        assert!(proi_price == coin::value(&paid), EInsufficientFunds);

        // Royalty
        let license_key = &item_info.item;
        let license = get_license(
            &proi_shop.game_list,
            &license_key.game_id,
            &license_key.license_id
        );

        if (license.royalty_rate > 0){
            let royalty_price = item_info.price - (item_info.price * license.royalty_rate / MaxRoyaltyRate);
            let royalty = coin::take(coin::balance_mut(&mut paid), royalty_price, ctx);

            // Save Royalty
            if (dof::exists_<String>(&reseller_shop.id, game_id)) {
                coin::join(
                    dof::borrow_mut<String, Coin<PROI>>(&mut proi_shop.id, game_id),
                    royalty
                );
            } else {
                dof::add(&mut reseller_shop.id, game_id, royalty);
            };
        };
        
        // Save paid
        if (dof::exists_<address>(&reseller_shop.id, license_key.owner)) {
            coin::join(
                dof::borrow_mut<address, Coin<PROI>>(&mut proi_shop.id, license_key.owner),
                paid
            );
        } else {
            dof::add(&mut reseller_shop.id, license_key.owner, paid);
        };

        // Transfer item
        let (_, origin_item_info) = vec_map::remove<ID, ResellerItem>(item_list, &item_id);
        let ResellerItem{
            id,
            reseller: _reseller,
            description: _description,
            price: _price,
            item: origin_license_key
        } = origin_item_info;

        origin_license_key.owner = buyer;
        transfer::transfer(origin_license_key, buyer);
        object::delete(id);

        // Emit Event
        event::emit(ResellEvent{item_id})
    }

    /// exchange usd to proi
    public fun change_price_usd_to_proi(
        usd: u64
    ): u64{
        // For testing purposes, PROI has been set to be converted to USD at a 1:1 ratio. 
        // In the future, Every day at a specified time, the PROI:USD ratio is refreshed and applied through Oracle.
        usd
    }

    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(ctx)
    }
    #[test_only]
    public fun get_item_id_by_idx_for_testing(
        reseller_shop: &ResellerShop,
        idx: u64
    ): ID {
        let (_, v) = vec_map::get_entry_by_idx<ID, ResellerItem>(&reseller_shop.item_list, idx);
        object::id(v)
    }
}
