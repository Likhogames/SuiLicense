# License Module
* * *
## Objects
### Game
규격화된 필드를 가진 게임 정보 오프젝트
- Property
|Name|Type|Description|
|:---:|:---:|:---|
|id|sui::object::UID|오브젝트 고유 아이디|
|name|sui::object::UID|오브젝트 고유 아이디|
|thumbnail|sui::object::UID|오브젝트 고유 아이디|
|image_url|sui::object::UID|오브젝트 고유 아이디|
|video_url|sui::object::UID|오브젝트 고유 아이디|
|short_intro|sui::object::UID|오브젝트 고유 아이디|
|intro|sui::object::UID|오브젝트 고유 아이디|


### GamePubCap
Game Object에 대한 스마트컨트렉트 실행 권한 증명 오브젝트
### License
Game Object에 종속되어 판매 금액, 인증 및 재판매에 대한 정보를 가지는 오브젝트
### LicenseKey
유저가 구매한 라이센스의 고유한 Key를 가진 오브젝트

## Event Objects

## Entry Functions
## Functions