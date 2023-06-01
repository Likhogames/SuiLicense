module proto_02::license {
    use sui::dynamic_object_field as ofield;
    use std::string::{Self, String};
    use sui::object::{Self, ID, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    /// For when amount paid does not match the expected.
    const ENotPublisher: u64 = 0;

    struct CompanyMarket<phantom COIN> has key, store {
        id: UID,
        name: String,
        link: String,
        image_url : String,
        description : String
    }

    struct GameTitle has key, store {
        id: UID,
        name: String,
        link: String,
        image_url : String,
        thumbnail_url : String,
        project_url : String,
        description : String,
        creator : String,
        publisher: address
    }

    struct License has key, store {
        id: UID,
        ask: u64,
        owner: address,
        title_id: ID,
    }

    public entry fun create_market<COIN>(
        name: vector<u8>, 
        link: vector<u8>, 
        image_url: vector<u8>, 
        description: vector<u8>, 
        ctx: &mut TxContext
        ) {
        let id = object::new(ctx);
        transfer::share_object(CompanyMarket<COIN> { 
            id, 
            name: string::utf8(name), 
            link: string::utf8(link), 
            image_url: string::utf8(image_url), 
            description: string::utf8(description)
        })
    }

    public entry fun create_goods<COIN>(
        marketplace: &mut CompanyMarket<COIN>,
        name: vector<u8>,
        link: vector<u8>,
        image_url : vector<u8>,
        thumbnail_url : vector<u8>,
        project_url : vector<u8>,
        description : vector<u8>,
        creator : vector<u8>,
        ctx: &mut TxContext
        ) {
        let game_id = object::new(ctx);
        let game = GameTitle { 
                id : game_id, 
                name: string::utf8(name), 
                link: string::utf8(link), 
                image_url: string::utf8(image_url), 
                thumbnail_url: string::utf8(thumbnail_url),
                project_url: string::utf8(project_url),
                creator: string::utf8(creator),
                description: string::utf8(description),
                publisher: tx_context::sender(ctx) 
        };
        
        // Game List for company market
        ofield::add(&mut marketplace.id, object::id(&game), game)
    }

    public entry fun create_license<T: key + store, COIN>(
        game: &mut GameTitle,
        item: T,
        ask: u64,
        ctx: &mut TxContext
    ){
        assert!(tx_context::sender(ctx) == game.publisher, ENotPublisher);

        let item_id = object::id(&item);
        let title_id = object::id(game);
        
        let license = License {
            ask,
            id: object::new(ctx),
            owner: tx_context::sender(ctx),
            title_id: title_id
        };

        ofield::add(&mut license.id, true, item);
        ofield::add(&mut game.id, item_id, license)

    }
}

#[test_only]
module proto_02::Tests {
    use proto_01::license::{Self};
    use sui::sui::SUI;
    use sui::test_scenario;

    const LIKHO:address = @0xBABE;
    const COMPANY1:address = @0xCAFE;
    const COMPANY2:address = @0xFACE;
    const USER1:address = @0x00A;
    const USER2:address = @0x00B;

    fun entry test_market(){
        let scenario = &mut test_scenario::begin(LIKHO);

        // Create Company Market
        test_scenario::next_tx(scenario, COMPANY1);
        license::create_market<SUI>(
            b"Blizzard",
            b"https://www.blizzard.com",
            b"https://blz-contentstack-images.akamaized.net/v3/assets/blta8f9a8e092360c6c/blteb3521249ab5f92e/61e765b0819be248ba63157d/2600_Featured_Games.jpg?format=webply&quality=80&auto=webp",
            b"PC Game Company.",
            test_scenario::ctx(scenario)
        );

        test_scenario::next_tx(scenario, COMPANY2);
        license::create_market<SUI>(
            b"EPIC",
            b"https://www.epicgames.com",
            b"data:image/png;base64,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",
            b"PC Game Company.",
            test_scenario::ctx(scenario)
        )

        // Create Game Title

        // Create License

        // Showping
        
        // Buy License

        // Auth License
    }
}