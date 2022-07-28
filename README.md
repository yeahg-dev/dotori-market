# 🐿 도토리 마켓 
> RESTAPI 통신을 이용한 오픈마켓 앱


# 1. 프로젝트 소개
## 1) 진행
- 개발자 : [릴리](https://github.com/yeahg-dev), [예거](https://github.com/Jager-yoo) (팀 프로젝트 + 개인 프로젝트)
- 1차 : 2022.1. 3 ~ 1. 28 (페어프로그래밍/ MVC 설계로 네트워크 모듈, 상품 등록, 리스트 기능 구현)
- 2차: 2022. 6. 13 ~ 7. 28 (개인/ MVVM Clean + rxSwift 설계로 리팩터링, 상품 수정, 좋아요 기능 구현)
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
> **도입 이유** 
> 
> - 뷰모델에서 비지니스 로직을 분리하고, 재사용하기 위해 `Usecase`를 도입
>  -  데이터 소스에 의존성을 낮추기 위해 `Repository`인터페이스 정의  

- `ProductListUsecase`를 프로토콜로 정의 
-  모든 상품, 좋아요한 상품, 등록한 상품 뷰에서 사용할 Usecase를 구체타입으로 구현 

<img src = "https://user-images.githubusercontent.com/81469717/181518807-612507a3-0247-48b8-89e5-f933b7e87088.png" width = "1000" >


-  비지니스로직이 포함되지 않은 순수한 뷰 
-  프레젠테이션, 도메인, 데이터 레이어간의 낮은 의존성 
-  의존성 주입, 추상화로 Testable한 각 레이어

<br>

### 화면 전환을 담당하는` Coordinator Pattern` 적용
> **도입 이유** 
>
> 뷰컨에서 화면 전환을 실행하기 때문에, 뷰컨을 뷰로서 재사용하기 어려웠기 어려웠음. 
> 코디네이터 객체에게 화면 전환에 대한 역할을 위임하여 뷰컨에서 비지니스 로직 분리를 도모 

- 각 탭마다 코디네이터 생성하여, MainCoordinator의 child로 관리

<img src = "https://user-images.githubusercontent.com/81469717/181521003-14fa2a21-81d2-47ca-8e18-f55088fdac28.png" width = "600" >



### 뷰 재사용, 낮은 결합도를 위한 시도 

1)  usecase를 프로토콜로 추상화

2) 동일 뷰에 대한 Coordinator를 포로토콜로 추상화

3)`FactoryPattern`으로 동일한 뷰컨을 공유하는 뷰 생성

<img width="920" alt="스크린샷 2022-07-28 오후 9 40 11" src="https://user-images.githubusercontent.com/81469717/181519170-6f7bab8a-1860-4b53-8cc7-dce6d8095fbe.png">


### 2) 동일 뷰에 대한 Coordinator를 포로토콜로 추상화

- 코디네이터는 추상적 인터페이스를 정의 (어떠한 액션이 일어나는지에 대해서만 정의)

```swift
protocol ProductListCoordinator: Coordinator {
    
    func rightNavigationItemDidTapped(from: UIViewController)
    func cellDidTapped(of productID: Int) 
    
}
```

- 각 뷰(모든 상품/ 좋아요한 상품/ 등록 상품) 의 코디네이터를 구체타입으로 구현 
- 뷰컨에 코디네이터를 주입하여 뷰의 재사용성 향상


<br>

### 3)`FactoryPattern`으로 동일한 뷰컨을 공유하는 뷰 생성
> **문제 상황** : 코디네이터에서 뷰 생성시 usecase를 주입해야하기 때문에 코디네이터가 도메인을 알게되는 문제 발생 

- `모든 상품`, `좋아요한 상품`, `등록한 상품` 뷰는 동일한 뷰(뷰컨)을 사용
- 동일한VC를 사용하는 뷰를 열거형으로 정의, 팩토리 패턴으로 생성

<details>
<summary>ProductListViewFactory 구현</summary>
<div markdown="1">

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
	        switch viewType {
	        case .allProduct:
	            return UIStoryboard.main.instantiateViewController(
	                identifier: "ProductTableViewController", creator:  { coder -> ProductTableViewController in
	                    let viewModel = ProductListSceneViewModel(usecase: AllProductListUsecase())
	                    let vc = ProductTableViewController(
	                        viewModel: viewModel,
	                        coordinator: coordinator,
	                        coder: coder)
	                    return vc!
	                })
	                ... 
	  }

}
```
</div>
</details>

 **결과** 
 
 - 하나의 뷰를 공유하는 Scene을 한 지점에서 관리하기 위함
- 코디네이터에서 비지니스로직을 분리하고, 각 뷰에 대한 결합성을 낮출 수 있었음


<br>

# 3. 트러블 슈팅 
<details>
<summary><h3>Testable한 Network Layer는 어떻게 만들까?</h3></summary>

> **문제 상황** : network를 이용한 API로 데이터를 받아 사용하는  ViewModel을 테스트하기 위해선 Network객체도 테스터블하게 만들어야함

- `URLProtocol` 을 상속한 `MockURLProtocol` 을 구현
- `MockURLProtocol` 에서 서버와 통신을 통해 받은 `data`와 `response`대신  `mockResponse, data` 를 전달하도록 `startLoading() ` 오버라이딩
- 따라서 실제 통신을 하지 않고도 작동하는 mock `APIService` 가 구현 가능

➡️`APIService` 의 코드 수정 없이, `MockURLProtocol`로 설정한 urlSession configuration만 변경하여 네트워크와 무관하게 바인딩, 뷰모델 로직 테스트 가능


[test: MockURLProtocol 구현 및 테스트 코드 적용](https://github.com/yeahg-dev/dotori-market/commit/16560b6895dc9fbdc4fc121f25bf6cb285f03d33)

</details>

<details>
<summary><h3>Observable은 어떻게 테스트 해야할까?</h3></summary>

Observable 타입으로 구현된 Input, Ouput을 테스트하기 위해 `rxTest` 라이브러리를 공부하여 사용했습니다.

- TestScheduler로 `ColdObservable`과 `Obeserver`를 생성
- Input을 `PublishSubject`로 정의, `ColdObservable`에서 방출하는 아이템을 바인딩
- `Observer.events`와 기대결과 비교

➡️ 뷰모델의 바인딩과 input -> output 로직을 테스트 해보았습니다.

</details>

<details>
<summary><h3>RxSwift 에러 핸들링 </h3></summary>

> **문제 상황** : 뷰컨에서 각 에러에 따른 노티를 사용자에게 차별적으로 보여주려면 에러를 구독해야한다. 근데 에러가 한번 방출되면 스트림은 종료되고, 다시 이벤트를 받지 못하게된다. 

**시도**

- `retry` 를 쓰면 에러가 방출되어도 그 즉시 dispose되고 다시 구독되기 때문에 스트림을 살릴 수 있지만, 에러가 옵저버에게 전달되지 않기 때문에 뷰에서 어떤 에러가 방출됐는지 알 수 없다. 
- `catch(onErrorJustReturn:)`, `asDriver(onErrorJustReturn:)` 를 쓰면 에러대신 다른 값을 넥스트로 보내고 complete되기 때문에 더 이상 사용자 이벤트를 받을 수 없다. 
- `Result`타입으로 값과 에러를 wrapping해서 next로 방출하면 뷰에서 핸들링이 가능하다. 하지만 뷰컨이 분기를 하는 것과 같은 로직을 갖게되어 역할 분리 측면에선 좋은 방법은 아닌 것 같다. 

**해결 방법**

- 에러에 대한 Alert을 별도의 Output으로 정의, `Subject`타입으로 구현
- 스트림에서 error방출시 `do`에서 Subject로 `AlertViewModel`을 next로 보냄

```swift
protocol AlertViewModel {
    
    var title: String? { get }
    var message: String? { get }
    var actionTitle: String? { get }
}
```
</details>

<details>
<summary><h3> 통신 절감 및 빠른 이미지 보기 위한 Cache 구현 </h3></summary>

> **문제 상황** : 이미지는 용량이 크기 때문에 스크롤 할 때마다 셀에 느리게 바인딩되는 상황

`UIImage+Extension`에  `NScache`를 사용해 해당 이미지 URL을 key로 데이터를 캐싱했습니다.

➡️ 사용성과 통신 비용을 개선했습니다. 
</details>

<br>

# 4. 학습한 내용

<details>
<summary><h3>Escaping Closure 사용시 유의 사항 </h3></summary>

escapingClosure는 참조타입으로 강한 순환참조로 인한 메모리 누수를 유발할 수 있습니다. 

- 객체의 `reference count`를 증가 시켜야할 상황인지 판단해 참조를 해야한다는 것, `[weak self]` `unowned`로 강한 순환참조를 해결할 수 있다는 점을 학습했습니다.

- RxSwift의 operator들은 escaping closure로 정의 되어있습니다. 따라서 뷰컨트롤러를 `[weak self]`로 참조해야만 disposeBag이 작동될 때 모든 스트림이 종료되고, 뷰컨도 해제될 수 있습니다. 

</details>

<details>
<summary><h3>HTTP구조와 URLSession을 사용한 통신</h3></summary>

- 직접 HTTP header, body, httpMethod, boundary를 구현해보며 HTTP 프로토콜의 구조에 대해 깊게 학습할 수 있던 기회였습니다.
- 각 API요청을 프로토콜로 공통화하여 재사용 가능한 타입을 정의했습니다.

```swift
protocol APIRequest {
    
    associatedtype Response: ResponseDataType
    
    var url: URL? { get }
    var httpMethod: HTTPMethod { get }
    var header: [String: String] { get }
    var body: Data? { get }
    
}

extension APIRequest {
    
    func urlRequest() -> URLRequest? {
        guard let url = url else {
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = header
        urlRequest.httpBody = body
        return urlRequest
    }
    
}
```
</details>
