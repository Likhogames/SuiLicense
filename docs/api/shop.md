# Module `ProiProtocol::shop`
## Struct `ProiShop`
게임 마켓플레이스 Object. 수수료에 관한 정보와 게임 정보를 저장하고 있으며 모듈 배포 시 Shared Object로 공유됩니다.
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

- `id`: Sui 오브젝트 고유 아이디
- `submission_fee`: 게임 등록 수수료(PROI). Oracle을 통해 매일 100USD:?PROI 비율로 업데이트
- `purchase_fee_rate`: 구매 수수료 비율
- `game_list`: 게임 리스트
    - key - 게임을 고유하게 구분할 수 있는 game_id. 게임 등록 시 입력
    - value - 게임 정보를 저장하고 있는 Game Object
- `purchase_fee_storage`: 구매 수수료 저장소 Object
- `submission_fee_storage`: 게임 등록 수수료 저장소 Object

</details>

## Struct `Game`
게임 정보 Object
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

- `id`: Sui 오브젝트 고유 아이디
- `game_id`: 게임을 고유하게 구분할 수 있는 game_id
- `name`: 게임 이름
- `thumbnail`: 대표 이미지(작은 이미지)
- `image_url`: 게임 소개 이미지 URL 리스트
- `video_url`: 게임 소개 영상 URL 리스트
- `short_intro`: 언어별 짧은 게임 소개
    - key - ISO 639 Alpha-2 Language code
    - value - 게임 소개 
- `intro`: 게임 소개 글. 마크다운 문법 권장
- `release_date`: 출시 일자
- `genre`: 장르
- `developer`: 개발사
- `publisher`: 배급사
- `language`: 지원 언어 리스트, ISO 639 Alpha-2 Language code
- `platform`: 지원 플랫폼 리스트
- `system_requirements`: 시스템 권장 사양. 마크다운 문법 권장
- `sale_lock`: 판매 On/Off
- `license_list`: 게임 가격과 인증 정보가 저장되어 있는 License Object List 

</details>

## Struct `GamePubCap`
Game Object에 대한 권한 증명 오브젝트
```rust
struct GamePubCap has key, store{
    id: UID,
    for: ID
}
```
<details>
<summary>Fields</summary>

- `id`: Sui 오브젝트 고유 아이디
- `for`: Game Object ID

</details>

## Struct `PurchaseFeeStorage`
구매 수수료 저장소 Object
```rust
struct PurchaseFeeStorage has key, store{
    id: UID,
    fees: Balance<PROI>
}
```
<details>
<summary>Fields</summary>

- `id`: Sui 오브젝트 고유 아이디
- `fees`: 저장된 PROI 토큰

</details>

## Struct `SubmissionFeeStorage`
게임 등록 수수료 저장소 Object
```rust
struct SubmissionFeeStorage has key, store{
    id: UID,
    fees: Balance<PROI>
}
```
<details>
<summary>Fields</summary>

- `id`: Sui 오브젝트 고유 아이디
- `fees`: 저장된 PROI 토큰

</details>

## Struct `ResellerShop`
재판매 마켓플레이스 Object. 구매한 게임을 재판매 하기 위한 정보가 저장되어 있으며 모듈 배포 시 Shared Object로 공유됩니다.
```rust
struct ResellerShop has key {
    id: UID,
    item_list: VecMap<ID, ResellerItem>
}
```
<details>
<summary>Fields</summary>

- `id`: Sui 오브젝트 고유 아이디
- `item_list`: vec_map으로 구성된 재판매 아이템 리스트
    - key - ResellerItem ID
    - value - 재판매 정보가 저장된 ResellerItem Object

</details>

## Struct `ResellerItem`
재판매 마켓플레이스 Object. 구매한 게임을 재판매 하기 위한 정보가 저장되어 있으며 모듈 배포 시 Shared Object로 공유됩니다.
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

- `id`: Sui 오브젝트 고유 아이디
- `reseller`: 재판매자 이름
- `description`: 재판매 아이템 설명
- `price`: 가격(USD)
- `item`: 재판매 아이템(License Object)

</details>

## Struct `License`
Game Object에 종속되어 판매 금액, 인증 및 재판매에 대한 정보를 가지는 Object
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

- `id`: Sui 오브젝트 고유 아이디
- `name`: 라이선스 이름
- `thumbnail`: 대표 이미지(작은 이미지)
- `short_intro`: 언어별 짧은 게임 소개
    - key - ISO 639 Alpha-2 Language code
    - value - 게임 소개 
- `publisher_price`: 퍼블리셔가 지정한 가격
- `discount_rate`: 퍼블리셔가 설정한 할인 비율, 퍼블리셔 가격 기준 할인 적용
- `royalty_rate`: 재판매 시 로열티 비율
- `permit_resale`: 재판매 허용 여부
- `limit_auth_count`: 인증 가능 횟수

</details>

## Struct `LicenseKey`
유저가 구매한 라이선스정보가 기록된 NFT 오브젝트
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

- `id`: Sui 오브젝트 고유 아이디
- `game_id`: 게임을 고유하게 구분할 수 있는 game_id
- `license_id`: 구매한 라이선스 Object ID
- `auth_count`: 인증 횟수
- `license_name`: 라이선스 이름
- `license_thumbnail`: 라이선스 대표 이미지
- `owner`: 라이선스키를 소유한 주소
- `user`: 마지막으로 인증한 유저 주소

</details>

## Struct `RegisterGameEvent`
게임 등록 이벤트 오브젝트
```rust
struct RegisterGameEvent has copy, drop{
    game_id: String
}
```
<details>
<summary>Fields</summary>

- `game_id`: 게임을 고유하게 구분할 수 있는 game_id

</details>

## Struct `CreateLicenseEvent`
라이선스 생성 이벤트 오브젝트
```rust
struct CreateLicenseEvent has copy, drop{
    game_id: String,
    license_id: ID
}
```
<details>
<summary>Fields</summary>

- `game_id`: 게임을 고유하게 구분할 수 있는 game_id
- `license_id`: License Object ID

</details>

## Struct `PurchaseEvent`
구매 이벤트 오브젝트
```rust
struct PurchaseEvent has copy, drop{
    game_id: String,
    license_id: ID,
    license_key_id: ID
}
```
<details>
<summary>Fields</summary>

- `game_id`: 게임을 고유하게 구분할 수 있는 game_id
- `license_id`: License Object ID
- `license_key_id`: 유저에게 전달한 LicenseKey Object ID

</details>

## Struct `ResellEvent`
구매 이벤트 오브젝트
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
- `game_id_bytes`: 게임을 고유하게 구분할 수 있는 game_id, 변경 불가
- `name_bytes`: 게임 이름
- `thumbnail`: 대표 이미지(작은 이미지)
- `image_url`: 게임 소개 이미지 URL 리스트
- `video_url`: 게임 소개 영상 URL 리스트
- `short_intro`: 언어별 짧은 게임 소개
    - key - ISO 639 Alpha-2 Language code
    - value - 게임 소개 
- `intro`: 게임 소개 글. 마크다운 문법 권장
- `release_date`: 출시 일자
- `genre`: 장르
- `developer`: 개발사
- `publisher`: 배급사
- `language`: 지원 언어 리스트, ISO 639 Alpha-2 Language code
- `platform`: 지원 플랫폼 리스트
- `system_requirements`: 시스템 권장 사양. 마크다운 문법 권장
- `sale_lock`: 판매 On/Off
- `submission_fee`: 게임 등록 수수료(PROI)

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
- `cap`: Game Object에 대한 권한 증명 오브젝트
- `game_id_bytes`: 게임을 고유하게 구분할 수 있는 game_id, 변경 불가
- `name_bytes`: 게임 이름
- `thumbnail`: 대표 이미지(작은 이미지)
- `image_url`: 게임 소개 이미지 URL 리스트
- `video_url`: 게임 소개 영상 URL 리스트
- `short_intro`: 언어별 짧은 게임 소개
    - key - ISO 639 Alpha-2 Language code
    - value - 게임 소개 
- `intro`: 게임 소개 글. 마크다운 문법 권장
- `release_date`: 출시 일자
- `genre`: 장르
- `developer`: 개발사
- `publisher`: 배급사
- `language`: 지원 언어 리스트, ISO 639 Alpha-2 Language code
- `platform`: 지원 플랫폼 리스트
- `system_requirements`: 시스템 권장 사양. 마크다운 문법 권장
- `sale_lock`: 판매 On/Off

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
- `cap`: Game Object에 대한 권한 증명 오브젝트
- `game_id_bytes`: 게임을 고유하게 구분할 수 있는 game_id
- `name_bytes`: 라이선스 이름
- `thumbnail`: 대표 이미지(작은 이미지)
- `short_intro`: 언어별 짧은 게임 소개
    - key - ISO 639 Alpha-2 Language code
    - value - 게임 소개 
- `publisher_price`: 퍼블리셔가 지정한 가격
- `discount_rate`: 퍼블리셔가 설정한 할인 비율, 퍼블리셔 가격 기준 할인 적용
- `royalty_rate`: 재판매 시 로열티 비율
- `permit_resale`: 재판매 허용 여부
- `limit_auth_count`: 인증 가능 횟수

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
- `cap`: Game Object에 대한 권한 증명 오브젝트
- `game_id_bytes`: 게임을 고유하게 구분할 수 있는 game_id
- `name_bytes`: 라이선스 이름
- `thumbnail`: 대표 이미지(작은 이미지)
- `short_intro`: 언어별 짧은 게임 소개
    - key - ISO 639 Alpha-2 Language code
    - value - 게임 소개 
- `publisher_price`: 퍼블리셔가 지정한 가격
- `discount_rate`: 퍼블리셔가 설정한 할인 비율, 퍼블리셔 가격 기준 할인 적용
- `royalty_rate`: 재판매 시 로열티 비율

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
- `game_id_bytes`: 게임을 고유하게 구분할 수 있는 game_id
- `license_id`: License Object ID
- `paid`: 지불 금액(PROI)
- `buyer`: 구매한 유저 주소

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
- `license_key`: 판매하려는 LicenseKey Object
- `reseller_bytes`: 판매자 이름
- `description_bytes`: 판매 아이템 설명
- `price`: 판매 가격

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
- `game_id_bytes`: 게임을 고유하게 구분할 수 있는 game_id
- `item_id`: 구매한 ResellerItem Object ID
- `paid`: 지불 금액(PROI)
- `buyer`: 구매한 유저 주소

* * *