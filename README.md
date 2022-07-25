# 🐿 도토리 마켓 
> RESTAPI 통신을 이용한 오픈마켓 앱


# 1. 프로젝트 소개
## 1) 진행
- 개발자 : [릴리](https://github.com/yeahg-dev), [예거](https://github.com/Jager-yoo) (팀 프로젝트 + 개인 프로젝트)
- 1차 : 2022.1. 3 ~ 1. 28 (페어프로그래밍/ MVC 설계로 네트워크 모듈, 상품 등록, 리스트 기능 구현)
- 2차: 2022. 6. 13 ~ 7. 23 (개인/ MVVM Clean + rxSwift 설계로 리팩터링, 상품 수정, 좋아요 기능 구현)
- 코드 리뷰 진행 / 리뷰어 : [찰리](https://github.com/kcharliek), [숲재](https://github.com/forestjae)

<br>

## 2) 코드 리뷰

| STEP          | 구현 기능                                                    | 해당 PR                                                   |
| ------------- | ------------------------------------------------------------ | --------------------------------------------------------- |
| STEP 1        | 모델, 네트워크 모듈 설계, 네트워크 테스트                    | https://github.com/yagom-academy/ios-open-market/pull/89  |
| STEP 2        | 상품 리스트(Table/CollectionVIew), 캐싱, pagination          | https://github.com/yagom-academy/ios-open-market/pull/101 |
| STEP 3        | 상품 상세 화면, ImagePicker, RefreshControl                       | https://github.com/yagom-academy/ios-open-market/pull/121 |
| MVVM 리팩터링 | 상품 등록, 사용자 인풋 Validation, rxSwift+MVVM으로 구조 리팩터링, 네트워크와 무관한 ViewModel 테스트 | https://github.com/yeahg-dev/dotori-market/pull/13        |

<br>

## 3) 구현 기능

>  상품 보기 (리스트/그리드뷰 지원)
> - `UITableViewController`, `UICollectionViewController` 로 상품 정보를 표시
> - 제공하는 데이터가 동일하기 때문에 `ProductListSceneViewModel`을 공유
> - `willDisplayCell`활용 pagination 구현
> <img src = "https://user-images.githubusercontent.com/81469717/180616559-549fdcf2-f5d5-4dab-aa32-980e0f32de01.gif" width = "200" >


> 상품 상세정보 보기
> - `UICollectionView` + `UIPageControl`로 여러 이미지 보기 구현
> - ❤️를 눌러 관심 상품 저장
> <img src = "https://user-images.githubusercontent.com/81469717/180616531-80835c32-e693-416d-a496-400ccd4af90f.gif" width = "200" >


> **새로운 상품 등록**
> - `UIImagePickerController`로 기기 이미지 첨부 가능
> - 입력 정보의 유효성 검증 및 알맞은 알럿 메시지 사용자에게 표시
> <img src = "https://user-images.githubusercontent.com/81469717/180616128-dcfff904-ceb8-4d34-88f0-22376566dad3.gif" width = "200" >


> **상품 수정 기능**
> - 키보드 등장시 컨텐츠 가림을 `KeyboardNotification`을 활용하여 사용성 개선 
> <img src = "https://user-images.githubusercontent.com/81469717/180616132-12426fe1-0ee0-484a-9c99-6c9da8b6a4f9.gif" width = "200" >

<br>

# 2. 설계 개요
## 1) 개발 환경

- 배포 타겟: iOS 13.2
- UI : UIKit, Storyboard, AutoLayout 
- Network : URLSession, RESTAPI
- Database : RealmSwfit
- RxSwift, RxCocoa, RxTest
- 의존성 관리 툴 : SPM

<br>

## 2) 프레임워크 선택 시 고려사항
### RxSwift
- 목적 : 모델의 변화를 뷰에 자동으로 업데이트하는 리액티브한 구조 구현 
- 선택 이유 
	- 다양한 operator를 제공, 데이터 스트림을 컴바인하기 편리함
	- RxCocoa 활용시 뷰에서 생성되는 이벤트 관리, 데이터 바인딩 편리
	- 비동기 코드를 동기 코드처럼 선언형으로 작성 가능, 가독성 향상
- 리스크
	- 메모리 누수 가능성 (	`weak self`,`disposeBag`사용하여 retain cycle 방지)

### RealmSwift
- 목적 : 좋아요한 상품, 등록 상품 ID 저장을 위한 persistent DB 구현
- 선택 이유
	- 간단한 API로 데이터의 영구적 저장 가능
	- 안드로이드와 공유 가능, 현업에서 쓰이는 프레임워크라 학습 위해
	- Object 확장성 좋음
- 리스크
	- 앱의 용량이 커짐
	- 데이터 스레드간 공유 불가 (스케줄러로 강제)

<br>

## 3) 아키텍처 및 패턴 
### MVVM + 클린 아키텍처
> 도입 이유 : 뷰모델에서 비지니스 로직을 분리하고, 재사용하기 위해 `ProductListUsecase`를 사용

- `ProductListUsecase`를 프로토콜로 정의 
-  모든 상품, 좋아요한 상품, 등록한 상품 뷰에서 사용할 Usecase를 구체타입으로 구현 
-  뷰의 재사용성 개선
-  도메인 레이어와 데이터 레이어간의 낮은 의존성 
 <img src = "https://user-images.githubusercontent.com/81469717/180616356-3e3809cd-a748-40ad-a83a-1af73881f982.png" width = "1000" >

### 화면 전환을 담당하는` Coordinator Pattern` 적용
> 도입 이유 : 기존 뷰컨이 화면 전환을 수행하기 때문에, 뷰컨을 재사용하기 어려웠기 때문에 뷰컨에서 비지니스 로직을 분리하기 위해 도입

- 코디네이터는 추상적 인터페이스를 채택 (어떠한 액션이 일어나는지에 대해서만 정의)
- 각 뷰(모든 상품/ 좋아요한 상품/ 등록 상품) 의 코디네이터를 구체타입으로 구현 
- 뷰컨에 코디네이터를 주입하여 재사용 가능해짐
- 각 뷰컨 간 의존성 해체 효과

<br>

### `FactoryPattern`으로 동일한 뷰컨 사용하는 뷰 생성
> 도입 이유 : - 동일한 뷰를 공유하는 Scene을 한 곳에서 관리 가능

- 모든 상품, 좋아요한 상품, 등록한 상품 뷰는 동일한 뷰컨을 사용
- 코디네이터에서 뷰를 만들 때 usecase를 주입해야했음. 그럼 코디네이터가 도메인을 알아야함
- 따라서 동일한VC를 사용하는 뷰를 열거형으로 정의, 팩토리패턴으로 생성
- 코디네이터에서 비지니스로직을 분리하고, 각 뷰에 대한 결합성을 낮출 수 있음

```swift
struct ProductListViewFactory {
    
    // MARK: - ProductListView Type
    
    enum ProductListView {
        case allProduct
        case likedProuduct
        case myProduct
    }
    
    func make(
        viewType: ProductListView,
        coordinator: ProductListCoordinator) -> ProductTableViewController {
             
             ... 생성
    }

}
```


