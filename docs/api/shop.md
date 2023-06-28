# Module `ProiProtocol::shop`
## Struct `ProiShop`
Game Marketplace Object. It stores information about fees and game details and is shared as a Shared Object when the module is deployed.
```rust
struct ProiShop has key {
    id: UID,
    submission_fee: u64,
    purchase_fee_rate: u64,
    game_list: VecMap<String, Game>,
    purchase_fee_storage: PurchaseFeeStorage,
    submission_fee_storage: SubmissionFeeStorage
}
```
<details>
<summary>Fields</summary>

- `id`: Sui Object unique id
- `submission_fee`: Submission fee(PROI).Update the 100USD:PROI ratio daily through Oracle
- `purchase_fee_rate`: Purchase fee rate
- `game_list`: Game list
    - key - The game_id, which uniquely identifies a game.
    - value - The Game Object that stores game information.
- `purchase_fee_storage`: Storage Object for purchase fee
- `submission_fee_storage`: Storage Object for submission fee

</details>

## Struct `ProiCap`
Capability Object for ProiShop Object
```rust
struct ProiCap has key, store{
    id: UID,
    for: ID
}
```
<details>
<summary>Fields</summary>

- `id`: Sui Object unique id
- `for`: ProiShop Object ID

</details>

## Struct `Game`
The Game Object that stores game information.
```rust
struct Game has key, store {
    id: UID,
    game_id: String,
    name: String,
    thumbnail: String,
    image_url: VecSet<String>,
    video_url: VecSet<String>,
    short_intro: VecMap<String, String>,
    intro: String,
    release_date: String,
    genre: String,
    developer: String,
    publisher: String,
    language: VecSet<String>,
    platform: VecSet<String>,
    system_requirements: String,
    sale_lock: bool,
    license_list: VecMap<ID, License> 
}
```
<details>
<summary>Fields</summary>

- `id`: Sui Object unique id
- `game_id`: The game_id, which uniquely identifies a game
- `name`: Game name
- `thumbnail`: Game representative image (thumbnail image)
- `image_url`: List of Game introduction image URLs
- `video_url`: List of Game introduction video URLs
- `short_description`: Short game introduction in different languages
    - key - ISO 639 Alpha-2 Language code
    - value - Short game introduction
- `description`: Game description. recommanded markdown
- `release_date`: release date
- `genre`: genre
- `developer`: Game developer name
- `publisher`: Game publisher name
- `language`: List of support language, ISO 639 Alpha-2 Language code
- `platform`: List of support platform
- `system_requirements`: System specs and requirements. recommanded markdown
- `sale_lock`: sales On/Off
- `license_list`: List of License Object that store game price and authentication information.

</details>

## Struct `GamePubCap`
Capability Object for Game Object.
```rust
struct GamePubCap has key, store{
    id: UID,
    for: ID
}
```
<details>
<summary>Fields</summary>

- `id`: Sui Object unique id
- `for`: Game Object ID

</details>

## Struct `PurchaseFeeStorage`
Storage Object for purchase fee
```rust
struct PurchaseFeeStorage has key, store{
    id: UID,
    fees: Balance<PROI>
}
```
<details>
<summary>Fields</summary>

- `id`: Sui Object unique id
- `fees`: stored PROI token

</details>

## Struct `SubmissionFeeStorage`
Storage Object for submission fee
```rust
struct SubmissionFeeStorage has key, store{
    id: UID,
    fees: Balance<PROI>
}
```
<details>
<summary>Fields</summary>

- `id`: Sui Object unique id
- `fees`: stored PROI token

</details>

## Struct `ResellerShop`
Marketplace Object for reseller. It stores information about resold items and is shared as a Shared Object when the module is deployed.
```rust
struct ResellerShop has key {
    id: UID,
    item_list: VecMap<ID, ResellerItem>
}
```
<details>
<summary>Fields</summary>

- `id`: Sui Object unique id
- `item_list`: List of resale items composed of vector maps.
    - key - ResellerItem ID
    - value - ResellerItem Object that stored resold item information.

</details>

## Struct `ResellerItem`
Item Object that stored resale item information.
```rust
struct ResellerItem has key, store {
    id: UID,
    reseller: String,
    description: String,
    price: u64,
    item: LicenseKey
}
```
<details>
<summary>Fields</summary>

- `id`: Sui Object unique id
- `reseller`: Reseller name
- `description`: Description about resold item
- `price`: Price(USD)
- `item`: Resold item object(License Object)

</details>

## Struct `License`
Object that stored game price and authentication information. Save in Game Object.
```rust
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
```
<details>
<summary>Fields</summary>

- `id`: Sui Object unique id
- `name`: License name
- `thumbnail`: License representative image (thumbnail image)
- `short_description`: Short license introduction in different languages
    - key - ISO 639 Alpha-2 Language code
    - value - Short license introduction
- `publisher_price`: The Publisher Price guarantees the minimum price of the license. [More information](https://likhogames.gitbook.io/proi-protocol/protocol-overview/creating-license#publisher-price)
- `discount_rate`: Discount rate to publisher price
- `royalty_rate`: Royalty on resale
- `permit_resale`: Permit resale
- `limit_auth_count`: Limit authentication count

</details>

## Struct `LicenseKey`
License key object given when purchasing a license
```rust
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
```
<details>
<summary>Fields</summary>

- `id`: Sui Object unique id
- `game_id`: The game_id, which uniquely identifies a game
- `license_id`: License Object ID
- `auth_count`: Authentication count
- `license_name`: License name
- `license_thumbnail`: License representative image (thumbnail image)
- `owner`: LicenseKey Object owner
- `user`: Last authenticated user address

</details>

## Struct `RegisterGameEvent`
Registering game event object
```rust
struct RegisterGameEvent has copy, drop{
    game_id: String
}
```
<details>
<summary>Fields</summary>

- `game_id`: The game_id, which uniquely identifies a game

</details>

## Struct `CreateLicenseEvent`
Creating license event object
```rust
struct CreateLicenseEvent has copy, drop{
    game_id: String,
    license_id: ID
}
```
<details>
<summary>Fields</summary>

- `game_id`: The game_id, which uniquely identifies a game
- `license_id`: License Object ID

</details>

## Struct `PurchaseEvent`
Purchasing event object
```rust
struct PurchaseEvent has copy, drop{
    game_id: String,
    license_id: ID,
    license_key_id: ID
}
```
<details>
<summary>Fields</summary>

- `game_id`: The game_id, which uniquely identifies a game
- `license_id`: License Object ID
- `license_key_id`: LicenseKey Object ID

</details>

## Struct `ResellEvent`
Reselling event object
```rust
struct ResellEvent has copy, drop{
    item_id: ID
}
```
<details>
<summary>Fields</summary>

- `item_id`: ResellerItem Object ID

</details>

* * *

## Function `regist_game`
Regist game info.
```rust
public entry fun regist_game(
    proi_shop: &mut ProiShop,
    game_id_bytes: vector<u8>,
    name_bytes: vector<u8>,
    thumbnail: vector<u8>,
    image_url: VecSet<vector<u8>>,
    video_url: VecSet<vector<u8>>,
    short_intro: VecMap<vector<u8>, vector<u8>>,
    intro: vector<u8>,
    release_date: vector<u8>,
    genre: vector<u8>,
    developer: vector<u8>,
    publisher: vector<u8>,
    language: VecSet<vector<u8>>,
    platform: VecSet<vector<u8>>,
    system_requirements: vector<u8>,
    sale_lock: bool,
    submission_fee: Coin<PROI>,
    ctx: &mut TxContext
)
```
<details>
<summary>Parameter</summary>

- `proi_shop`: ProiShop Shared Object
- `game_id_bytes`: The game_id, which uniquely identifies a game, Not changed
- `name_bytes`: Game name
- `thumbnail`: Game representative image (thumbnail image)
- `image_url`: List of Game introduction image URLs
- `video_url`: List of Game introduction video URLs
- `short_description`: Short game introduction in different languages
    - key - ISO 639 Alpha-2 Language code
    - value - Short game introduction
- `description`: Game description. recommanded markdown
- `release_date`: release date
- `genre`: genre
- `developer`: Game developer name
- `publisher`: Game publisher name
- `language`: List of support language, ISO 639 Alpha-2 Language code
- `platform`: List of support platform
- `system_requirements`: System specs and requirements. recommanded markdown
- `sale_lock`: sales On/Off
- `submission_fee`: Submission fee(PROI)

</details>

## Function `update_game`
Update game info. Limit change the game_id.
```rust
public entry fun update_game(
    proi_shop: &mut ProiShop,
    cap: &GamePubCap,
    game_id_bytes: vector<u8>,
    name_bytes: vector<u8>,
    thumbnail: vector<u8>,
    image_url: VecSet<vector<u8>>,
    video_url: VecSet<vector<u8>>,
    short_intro: VecMap<vector<u8>, vector<u8>>,
    intro: vector<u8>,
    release_date: vector<u8>,
    genre: vector<u8>,
    developer: vector<u8>,
    publisher: vector<u8>,
    language: VecSet<vector<u8>>,
    platform: VecSet<vector<u8>>,
    system_requirements: vector<u8>,
    sale_lock: bool,
    ctx: &mut TxContext
)
```
<details>
<summary>Parameter</summary>

- `proi_shop`: ProiShop Shared Object
- `cap`: Capability object for Game Object
- `game_id_bytes`: The game_id, which uniquely identifies a game, Not changed
- `name_bytes`: Game name
- `thumbnail`: Game representative image (thumbnail image)
- `image_url`: List of Game introduction image URLs
- `video_url`: List of Game introduction video URLs
- `short_description`: Short game introduction in different languages
    - key - ISO 639 Alpha-2 Language code
    - value - Short game introduction
- `description`: Game description. recommanded markdown
- `release_date`: release date
- `genre`: genre
- `developer`: Game developer name
- `publisher`: Game publisher name
- `language`: List of support language, ISO 639 Alpha-2 Language code
- `platform`: List of support platform
- `system_requirements`: System specs and requirements. recommanded markdown
- `sale_lock`: sales On/Off

</details>

## Function `create_license`
Create license.
```rust
public entry fun create_license(
    proi_shop: &mut ProiShop,
    cap: &GamePubCap,
    game_id_bytes: vector<u8>,
    name_bytes: vector<u8>,
    thumbnail: vector<u8>,
    short_intro: VecMap<vector<u8>, vector<u8>>,
    publisher_price: u64,
    discount_rate: u64,
    royalty_rate: u64,
    permit_resale: bool,
    limit_auth_count: u64,
    ctx: &mut TxContext
)
```
<details>
<summary>Parameter</summary>

- `proi_shop`: ProiShop Shared Object
- `cap`: Capability object for Game Object
- `game_id_bytes`: The game_id, which uniquely identifies a game
- `name_bytes`: License name
- `thumbnail`: License representative image (thumbnail image)
- `short_description`: Short license introduction in different languages
    - key - ISO 639 Alpha-2 Language code
    - value - Short license introduction
- `publisher_price`: The Publisher Price guarantees the minimum price of the license. [More information](https://likhogames.gitbook.io/proi-protocol/protocol-overview/creating-license#publisher-price)
- `discount_rate`: Discount rate to publisher price
- `royalty_rate`: Royalty on resale
- `permit_resale`: Permit resale
- `limit_auth_count`: Limit authentication count

</details>

## Function `update_license`
Update license. Limit change the permit_resale, limit_auth_count.
```rust
public entry fun update_license(
    proi_shop: &mut ProiShop,
    cap: &GamePubCap,
    game_id_bytes: vector<u8>,
    name_bytes: vector<u8>,
    thumbnail: vector<u8>,
    short_intro: VecMap<vector<u8>, vector<u8>>,
    publisher_price: u64,
    discount_rate: u64,
    royalty_rate: u64,
    ctx: &mut TxContext
)
```
<details>
<summary>Parameter</summary>

- `proi_shop`: ProiShop Shared Object
- `cap`: Capability object for Game Object
- `game_id_bytes`: The game_id, which uniquely identifies a game
- `name_bytes`: License name
- `thumbnail`: License representative image (thumbnail image)
- `short_description`: Short license introduction in different languages
    - key - ISO 639 Alpha-2 Language code
    - value - Short license introduction
- `publisher_price`: The Publisher Price guarantees the minimum price of the license. [More information](https://likhogames.gitbook.io/proi-protocol/protocol-overview/creating-license#publisher-price)
- `discount_rate`: Discount rate to publisher price
- `royalty_rate`: Royalty on resale

</details>

## Function `purchase`
Purchase license.
```rust
public entry fun purchase(
    proi_shop: &mut ProiShop,
    game_id_bytes: vector<u8>,
    license_id: ID,
    paid: Coin<PROI>,
    buyer: address,
    ctx: &mut TxContext
)
```
<details>
<summary>Parameter</summary>

- `proi_shop`: ProiShop Shared Object
- `game_id_bytes`: The game_id, which uniquely identifies a game
- `license_id`: License Object ID
- `paid`: Payment(PROI)
- `buyer`: Buyer address

</details>

## Function `authenticate`
Authenticate license key in game sdk.
```rust
public entry fun authenticate(
    proi_shop: &mut ProiShop,
    license_key: &mut LicenseKey,
    ctx: &mut TxContext
)
```
<details>
<summary>Parameter</summary>

- `proi_shop`: ProiShop Shared Object
- `license_key`: LicenseKey Object

</details>

## Function `list_license_key`
List licenseKey object for resell.
```rust
public entry fun list_license_key(
    proi_shop: &mut ProiShop,
    reseller_shop: &mut ResellerShop,
    license_key: LicenseKey,
    reseller_bytes: vector<u8>,
    description_bytes: vector<u8>,
    price: u64,
    ctx: &mut TxContext
)
```
<details>
<summary>Parameter</summary>

- `proi_shop`: ProiShop Shared Object
- `reseller_shop`: ResellerShop Shared Object
- `license_key`: Resold LicenseKey Object
- `reseller_bytes`: Reseller name
- `description_bytes`: Description about resold item
- `price`: Price(USD)

</details>

## Function `resell`
Purchase reselling license.
```rust
public entry fun resell(
    proi_shop: &mut ProiShop,
    reseller_shop: &mut ResellerShop,
    game_id_bytes: vector<u8>,
    item_id: ID,
    paid: Coin<PROI>,
    buyer: address,
    ctx: &mut TxContext
)
```
<details>
<summary>Parameter</summary>

- `proi_shop`: ProiShop Shared Object
- `reseller_shop`: ResellerShop Shared Object
- `game_id_bytes`: The game_id, which uniquely identifies a game
- `item_id`: Purchasing ResellerItem Object ID
- `paid`: Payment(PROI)
- `buyer`: Buyer address

</details>

## Function `take_proi_for_labs`
Take the stored PROI token from purchase fee storage. 
```rust
public entry fun take_proi_for_labs(
    proi_shop: &mut ProiShop,
    cap: & ProiCap,
    ctx: &mut TxContext
)
```
<details>
<summary>Parameter</summary>

- `proi_shop`: ProiShop Shared Object
- `cap`: Capability of ProiShop Object

</details>

## Function `take_proi_for_publisher`
Take the stored PROI tokens after purchase.
```rust
public entry fun take_proi_for_publisher(
    proi_shop: &mut ProiShop,
    cap: & GamePubCap,
    game_id_bytes: vector<u8>,
    ctx: &mut TxContext
)
```
<details>
<summary>Parameter</summary>

- `proi_shop`: ProiShop Shared Object
- `cap`: Capability of Game Object
- `game_id_bytes`: The game_id, which uniquely identifies a game

</details>

## Function `take_proi_for_reseller`
Take the stored PROI tokens after resale.
```rust
public entry fun take_proi_for_reseller(
    reseller_shop: &mut ResellerShop,
    ctx: &mut TxContext
)
```
<details>
<summary>Parameter</summary>

- `reseller_shop`: ResellerShop Shared Object

</details>

## Function `take_proi_for_publisher`
Take the stored PROI token for royalty. 
```rust
public entry fun take_proi_for_royalty(
    proi_shop: &mut ProiShop,
    reseller_shop: &mut ResellerShop,
    cap: & GamePubCap,
    game_id_bytes: vector<u8>,
    ctx: &mut TxContext
)
```
<details>
<summary>Parameter</summary>

- `proi_shop`: ProiShop Shared Object
- `reseller_shop`: ResellerShop Shared Object
- `cap`: Capability of Game Object
- `game_id_bytes`: The game_id, which uniquely identifies a game

</details>

* * *