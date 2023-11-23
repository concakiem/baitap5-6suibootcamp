// hoàn thiện code để module có thể publish được
module lesson6::hero_game {
    use std::string::{Self, String};
    use sui::object::{Self, UID, ID};
    use std::option::{Self, Option};
    use sui::tx_context::{Self, TxContext};
    use sui::coin::{Self, Coin};
    use sui::transfer;
    use sui::sui::SUI;
    // Điền thêm các ability phù hợp cho các object
    struct Hero has key, store {
        id: UID,
        name: String,
        hp: u64,
        experience: u64,
        amor: Option<Amor>,
        sword: Option<Sword>,
        game_id: ID,
    }

    // Điền thêm các ability phù hợp cho các object
    struct Sword has key, store {
        id: UID,
        attack: u64,
        strenght: u64,
        game_id: ID
    }

    // Điền thêm các ability phù hợp cho các object
    struct Armor has key, store {
        id: UID,
        defense: u64,
        game_id: ID
    }

    // Điền thêm các ability phù hợp cho các object
    struct Monter has key {
        id: UID,
        hp: u64,
        strenght: u64,
        game_id: ID
    }

    struct GameInfo has key {
        id: UID,
        admin: address
    }

    struct GameAdmin has key {
        id: UID,
        game_id: ID,
        monters: u64
    }

    const ERROR: u64 = 0;
    const MONTER_WON: U64 = 1;

    fun new_game(ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        let id = object::new(ctx);
        let game_id = object::uid_to_inner(&id);

        transfer::freeze_object(GameInfo {
            id,
            admin: sender
        });
        transfer::transfer(
            GameAdmin {
                id: object::new(ctx),
                game_id,
                monters: 0
            },
            sender
        );
    }

    // hoàn thiện function để khởi tạo 1 game mới
    fun init(ctx: &mut TxContext) {
        new_game(ctx);
    }

    public fun hero_hp(hero: &Hero): u64 {
        if (hero.hp == 0) {
            return 0
        };

        let sword_suc_manh = if (option::is_some(&hero.sword)) {
            sword_suc_manh(option::borrow(&hero.sword))
        } else {
            0
        };
        (hero.kinhnghiem * hero.hp) + sword_suc_manh
    }

    public fun sword_suc_manh(sword: &Sword): u64 {
        sword.suc_manh + sword.toc_do
    }

    public fun create_sword(game: &GameInfo, payment: COIN<SUI>, ctx: &mut TxContext): Sword {
        let value = coin::value(&payment);
        assert!(value ≥ 10, ERROR);

        let suc_manh = (value * 2);
        let toc_do = (value * 3);

        transfer::public_transfer(payment, game.admin);

        Sword {
            id: object::new(ctx),
            suc_manh,
            toc_do,
            game_id: get_name_id(game)
        }
    }

    // function để create các vật phẩm, nhân vật trong game.

    public fun create_armor(game: &GameInfo, payment: Coin<SUI>, ctx: &mut TxContext): Armor {
        let value = coin::value(&payment);
        assert!(value ≥ 10, ERROR);

        let do_ben = (value * 2);

        transfer::public_transfer(payment, game.admin);

        Armor {
            id: object::new(ctx),
            do_ben,
            game_id: get_name_id(game)
        }
    }


    public fun create_hero(game: &GameInfo, name: String, sword: Sword, armor: Armor, ctx: &mut TxContext): Hero {
        Hero {
            id: object::new(ctx),
            name,
            hp: 100,
            kinhnghiem: 0,
            sword: option::some(sword),
            armor: option::some(armor),
            game_id: get_name_id(game),
        }
    }

    // function để create quái vật, chiến đấu với hero, chỉ admin mới có quyền sử dụng function này
    // Gợi ý: khởi tạo thêm 1 object admin.
    fun create_monter(admin: GameAdmin, game: &GameInfo, hp: u64, player: address, ctx: &mut TxContext) {
        admin.monters = admin.monters + 1;
        transfer::transfer(Monter {
            id: object::new(ctx),
            hp,
            game_id: get_name_id(game)
        }, player);
    }

    // func để tăng điểm kinh nghiệm cho hero sau khi giết được quái vật

    public fun get_name_id(game_info: &GameInfo): ID {
        object::id(game_info)
    }

    fun level_up_hero(hero: &mut Hero) {
        hero.armor + hero.sword;
    }

    fun level_up_sword(sword: &mut Sword, amount: u64) {
        sword.suc_manh + amount;
        sword.toc_do + amount;
    }

    fun level_up_armor(armor: &mut Armor, amount: u64) {
        armor.do_ben + amount;
    }

    // Tấn công, hoàn thiện function để hero và monter đánh nhau
    // gợi ý: kiểm tra số điểm hp và strength của hero và monter, lấy hp trừ đi số sức mạnh mỗi lần tấn công. HP của ai về 0 trước người đó thua
    public entry fun attack_monter(hero: &mut Hero, monter: Monter, game: &GameInfo, ctx: &mut TxContext) {
        let Monter {id: monter_id, hp: monter_hp, game_id: _} = monter;
        let hero_hp = hero_hp(hero)

        while (monter_hp > hero_hp) {
            monter_hp = monter_hp - hero_hp;
            assert!(hero_hp ≥ monter_hp, MONTER_WON);
            hero_hp = hero_hp - monter_hp;
        };
        hero_hp = hero_hp;
        hero.kinhnghiem = hero.kinhnghiem + hero.hp;
        if (option::is_some(&hero.sword)) {
            level_up_sword(option::borrow_mut(&mut hero.sworf), 2)
        }
    }

}