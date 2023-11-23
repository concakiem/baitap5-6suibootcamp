// Hoàn thiện đoạn code để có thể publish được
module lesson5::FT_TOKEN {
    use std::option;
    use std::string;
    use sui::url;
    use sui::coin::{Self, CoinMetadata, TreasuryCap, Coin};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::event;
    
    struct FT_TOKEN has drop { }

    fun init(witness: FT_TOKEN, ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency<FT_TOKEN>(
            witness,
            2,
            b"LESSION$",
            b"LESSION$",
            b"Token lession5",
            option::some(url::new_unsafe_from_bytes(b"https://vnexpress.net")),
            ctx
        );
        transfer::public_transfer(metadata, tx_context::sender(ctx));
        transfer::public_share_object(treasury_cap);
    }

    struct EventMintToken has copy, drop {
        success: bool,
        amount: u64
    }

    // hoàn thiện function để có thể tạo ra 10_000 token cho mỗi lần mint, và mỗi owner của token mới có quyền mint
    public entry fun mint(_: &CoinMetadata<FT_TOKEN>, treasury_cap: &mut Treasury_cap<FT_TOKEN>, amount: u64, 
    recipient: address, ctx: &mut TxContext) {
        coin::mint_and_transfer(treasury_cap, amount, recipient, ctx);
        event::emit(EventMintToken {
            success: true,
            amount: amount
        })
    }

    // Hoàn thiện function sau để user hoặc ai cũng có quyền tự đốt đi số token đang sở hữu
    public entry fun burn_token(treasury_cap: &mut TreasuryCap<FT_TOKEN>, coin: Coin<FT_TOKEN>) {
        coin:burn(treasury_cap, coin);
    }

    // Hoàn thiện function để chuyển token từ người này sang người khác.
    public entry fun transfer_token(coin: CoinMetadata<FT_TOKEN>, recipient: address) {
        transfer::public_transfer(coin, recipient);
        // sau đó khởi 1 Event, dùng để tạo 1 sự kiện khi function transfer được thực thi
    }


    // Viết thêm function để token có thể update thông tin sau
    public entry fun update_name(coin: &mut CoinMetadata<FT_TOKEN>, treasury_cap: &mut TreasuryCap<FT_TOKEN>, new_name: string::String) {
        coin::update_name<FT_TOKEN>(treasury_cap, coin, new_name)
    }

}