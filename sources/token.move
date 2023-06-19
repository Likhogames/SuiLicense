module ProiProtocol::token {
    use std::option;
    use sui::coin;
    use sui::pay;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    struct PROI has drop {}

    fun init(witness: PROI, ctx: &mut TxContext) {
        // Create new token PROI
        let (treasury, metadata) = coin::create_currency(witness, 4, b"PROI", b"PROI", b"PROI is the token for the Proi protocol on the Sui blockchain.", option::none(), ctx);

        // Mint 1 Billion
        let balance = coin::mint_balance<PROI>(&mut treasury, 1000000000);
        let coin = coin::from_balance(balance, ctx);
        pay::keep(coin, ctx);

        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury, tx_context::sender(ctx))
    }
}