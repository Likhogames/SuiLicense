# License Module API Doc
## Objects
### ProiShop
Proi Protocol 관련 정보
- Property

|Name|Type|Description|
|:---:|:---:|:---|
|id|sui::object::UID|Sui 오브젝트 고유 아이디|
|submission_fee|u64|게임 등록 시 수수료|
|purchase_fee_rate|u64|구매 시 수수료 비율|
|purchase_fees|Balance<COIN>|구매 수수료 적재|

### GameList
등록된 게임이 리스트 형태로 저장되는 오브젝트
- Property

|Name|Type|Description|
|:---:|:---:|:---|
|game_list|sui::vec_map::VecMap<String, Game>|등록된 게임 리스트|

### Game
규격화된 필드를 가진 게임 정보 오프젝트
- Property

|Name|Type|Description|
|:---:|:---:|:---|
|id|sui::object::UID|Sui 오브젝트 고유 아이디|
|game_id|String|Game IDs that uniquely identify game.|
|name|String|게임 이름|
|thumbnail|String|대표 이미지|
|image_url|sui::vec_set::VecSet<String>|게임 소개 이미지 URL|
|video_url|sui::vec_set::VecSet<String>|게임 영상 URL|
|short_intro|sui::vec_map::VecMap<String, String>|언어별 짧은 게임 소개. 키-ISO 639 Alpha-2|
|intro|String|게임 소개 글. 마크다운 문법 권장|
|release_date|String|출시 일자|
|genre|String|장르|
|developer|String|개발사|
|publisher|String|배급사|
|language|sui::vec_set::VecSet<String>|지원 언어|
|platform|sui::vec_set::VecSet<String>|지원 플랫폼|
|system_requirements|String|시스템 권장 사양. 마크다운 문법 권장|
|sale_lock|bool|판매 On/Off|

### GamePubCap
Game Object에 대한 스마트컨트렉트 실행 권한 증명 오브젝트
- Property

|Name|Type|Description|
|:---:|:---:|:---|
|id|sui::object::UID|Sui 오브젝트 고유 아이디|
|for|sui::object::ID|ID from Game object UID|

### License
Game Object에 종속되어 판매 금액, 인증 및 재판매에 대한 정보를 가지는 오브젝트
- Property

|Name|Type|Description|
|:---:|:---:|:---|
|id|sui::object::UID|Sui 오브젝트 고유 아이디|
|name|String|라이선스 이름|
|thumbnail|String|대표 이미지|
|short_intro|sui::vec_map::VecMap<String, String>|언어별 짧은 라이선스 소개. 키-ISO 639 Alpha-2|
|publisher_price|u32|퍼블리셔 가격|
|discount_rate|u16|퍼블리셔 할인 비율. 만분률|

### LicenseKey
유저가 구매한 라이선스정보가 기록된 NFT 오브젝트
- Property

|Name|Type|Description|
|:---:|:---:|:---|
|id|sui::object::UID|Sui 오브젝트 고유 아이디|
|game_id|string|game_id in Game Object|
|license_id|sui::object::ID|ID from license UID|
|auth_count|u16|라이선스 인증한 횟수|
|license_name|String|라이선스 이름|
|license_thumbnail|String|라이선스 대표 이미지|
|lock|bool|라이선스 키 장금 On/Off|
* * *
## Event Objects
### RegisterGameEvent
게임 신규 등록 시 발생하는 이벤트
- Property

|Name|Type|Description|
|:---:|:---:|:---|
|game_id|string|game_id in Game Object|

### UpdateGameEvent
게임 오브젝트 수정 시 발생하는 이벤트
- Property

|Name|Type|Description|
|:---:|:---:|:---|
|game_id|string|game_id in Game Object|

### CreateLicenseEvent
신규 라이센스 생성 시 발생하는 이벤트
- Property

|Name|Type|Description|
|:---:|:---:|:---|
|game_id|string|game_id in Game Object|
|license_id|sui::object::ID|ID from license UID|

### UpdateLicenseEvent
라이센스 수정 시 발생하는 이벤트
- Property

|Name|Type|Description|
|:---:|:---:|:---|
|game_id|string|game_id in Game Object|
|license_id|sui::object::ID|ID from license UID|

### PurchaseEvent
게임 구매 시 발생하는 이벤트
- Property

|Name|Type|Description|
|:---:|:---:|:---|
|game_id|string|game_id in Game Object|
|license_id|sui::object::ID|ID from license UID|
|license_key|sui::object::ID|ID from license UID|

### ResellEvent
게임 재판매 시 발생하는 이벤트
- Property

|Name|Type|Description|
|:---:|:---:|:---|
|game_id|string|game_id in Game Object|
|license_id|sui::object::ID|ID from license UID|
|license_key_id|sui::object::ID|ID from licenseKey UID|
* * *
## Entry Functions
### regist_game
게임 등록
- Parameter

|Name|Type|Description|
|:---:|:---:|:---|
|proi_shop|Object<ProiShop>|Proi Shop shared object|
|game_id|String|Game IDs that uniquely identify game.|
|name|String|게임 이름|
|thumbnail|String|대표 이미지|
|image_url|sui::vec_set::VecSet<String>|게임 소개 이미지 URL|
|video_url|sui::vec_set::VecSet<String>|게임 영상 URL|
|short_intro|sui::vec_map::VecMap<String, String>|언어별 짧은 게임 소개. 키-ISO 639 Alpha-2|
|intro|String|게임 소개 글. 마크다운 문법 권장|
|release_date|String|출시 일자|
|genre|String|장르|
|developer|String|개발사|
|publisher|String|배급사|
|language|sui::vec_set::VecSet<String>|지원 언어|
|platform|sui::vec_set::VecSet<String>|지원 플랫폼|
|system_requirements|String|시스템 권장 사양. 마크다운 문법 권장|
|sale_lock|bool|판매 On/Off|
|submission_fee|Coin<PROI>|등록 수수료|

### update_game
게임 정보 수정
- Parameter

|Name|Type|Description|
|:---:|:---:|:---|
|game_cap|Object<GamePubCap>|Game Publisher Capability|
|proi_shop|Object<ProiShop>|Proi Shop shared object|
|game_id|String|Game IDs that uniquely identify game.|
|name|String|게임 이름|
|thumbnail|String|대표 이미지|
|image_url|sui::vec_set::VecSet<String>|게임 소개 이미지 URL|
|video_url|sui::vec_set::VecSet<String>|게임 영상 URL|
|short_intro|sui::vec_map::VecMap<String, String>|언어별 짧은 게임 소개. 키-ISO 639 Alpha-2|
|intro|String|게임 소개 글. 마크다운 문법 권장|
|release_date|String|출시 일자|
|genre|String|장르|
|developer|String|개발사|
|publisher|String|배급사|
|language|sui::vec_set::VecSet<String>|지원 언어|
|platform|sui::vec_set::VecSet<String>|지원 플랫폼|
|system_requirements|String|시스템 권장 사양. 마크다운 문법 권장|
|sale_lock|bool|판매 On/Off|

### create_license
라이선스 신규 등록
- Parameter

|Name|Type|Description|
|:---:|:---:|:---|
|game_cap|Object<GamePubCap>|Game Publisher Capability|
|proi_shop|Object<ProiShop>|Proi Shop shared object|
|name|String|라이선스 이름|
|thumbnail|String|대표 이미지|
|short_intro|sui::vec_map::VecMap<String, String>|언어별 짧은 라이선스 소개. 키-ISO 639 Alpha-2|
|publisher_price|u32|퍼블리셔 가격|
|discount_rate|u16|퍼블리셔 할인 비율. 만분률|

### update_license
라이선스 수정
- Parameter

|Name|Type|Description|
|:---:|:---:|:---|
|game_cap|Object<GamePubCap>|Game Publisher Capability|
|proi_shop|Object<ProiShop>|Proi Shop shared object|
|name|String|라이선스 이름|
|thumbnail|String|대표 이미지|
|short_intro|sui::vec_map::VecMap<String, String>|언어별 짧은 라이선스 소개. 키-ISO 639 Alpha-2|
|publisher_price|u32|퍼블리셔 가격|
|discount_rate|u16|퍼블리셔 할인 비율. 만분률|

### purchase
라이선스 구매
- Parameter

|Name|Type|Description|
|:---:|:---:|:---|
|proi_shop|Object<ProiShop>|Proi Shop shared object|
|game_id|String|Proi Shop shared object|
|license_id|ObjectID|Proi Shop shared object|
|paid|Coin<COIN><ProiShop>|Proi Shop shared object| 
|buyer|Address|Buyer address| 

### authenticate
라이선스 인증
- Parameter

|Name|Type|Description|
|:---:|:---:|:---|
|proi_shop|Object<ProiShop>|Proi Shop shared object|
|license_key|Object<LicenseKey>|License Key object in user wallet|

### list_used_license
라이선스 재판매 등록
- Parameter

|Name|Type|Description|
|:---:|:---:|:---|
|proi_shop|Object<ProiShop>|Proi Shop shared object|
|license_key|Object<LicenseKey>|LicenseKey object in user wallet|
|price|u32|재판매 금액|

### resell
라이선스 재판매
- Parameter

|Name|Type|Description|
|:---:|:---:|:---|
|proi_shop|Object<ProiShop>|Proi Shop shared object|
|license_key_id|sui::object::ID|ID from LicenseKey UID|
|paid|Coin<COIN><ProiShop>|Proi Shop shared object| 

* * *
## Functions