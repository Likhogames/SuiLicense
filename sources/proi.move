module ProiProtocol::proi {
    use std::option;
    use sui::coin::{Self, TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    const ENotEnoughSubmissionFee: u64 = 0;
    const DECIMALS: u64 = 10000;
    const DECIMALS_NUM: u8 = 4;

    struct PROI has drop {}

    fun init(witness: PROI, ctx: &mut TxContext) {
        // Create new token PROI
        let (treasury, metadata) = coin::create_currency(witness, DECIMALS_NUM, b"PROI", b"PROI", b"PROI is the token for the Proi protocol on the Sui blockchain.", option::none(), ctx);

        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury, tx_context::sender(ctx))
    }

    public entry fun mint(
        treasury_cap: &mut TreasuryCap<PROI>,
        amount: u64,
        recipient: address,
        ctx: &mut TxContext
    ) {
        coin::mint_and_transfer(treasury_cap, amount, recipient, ctx)
    }

    public fun get_decimal()
    : u64{
        DECIMALS
    }

    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(PROI {}, ctx)
    }
}