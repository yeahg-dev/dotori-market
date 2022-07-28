//
//  LlikeProductListUsecase.swift
//  DotoriMarket
//
//  Created by lily on 2022/07/21.
//

import Foundation

import RxSwift

struct LlikeProductListUsecase: ProductListUsecase {

    let productRepository: ProductRepository
    private let favoriteProductRepository: FavoriteProductRepository
    
    private var likeProducts = [Int]()
    private var likeProductPages = [[Int]]()
    
    init(productRepository: ProductRepository = MarketProductRepository(),
         favoriteProdcutRepository: FavoriteProductRepository = MarketFavoriteProductRepository()) {
        self.productRepository = productRepository
        self.favoriteProductRepository = favoriteProdcutRepository
    }
    
    mutating func fetchPrdoucts(
        pageNo: Int,
        itemsPerPage: Int) -> Observable<([ProductViewModel], Bool)> {
        if self.likeProducts.isEmpty ||
            self.likeProducts != self.favoriteProductRepository.fetchFavoriteProductIDs() {
            self.readLikeProductIDs()
        }
        
        guard let pageToRequest = self.likeProductPages[safe: pageNo - 1],
              let lastPage = self.likeProductPages.last  else {
        return Observable.just(([ProductViewModel](), false))
        }
        
        let hasNext = (lastPage == pageToRequest) ? false :true
        
            return self.fetchProductViewModels(of: pageToRequest)
            .map{ ($0, hasNext) }
        }
    
    func fetchNavigationBarComponent() -> Observable<NavigationBarComponent> {
        return Observable.just(
            NavigationBarComponent(
                title: "좋아요한 상품",
                rightBarButtonImageSystemName: ""))
    }
    
    private mutating func readLikeProductIDs() {
        self.likeProducts = self.favoriteProductRepository.fetchFavoriteProductIDs()
        self.likeProductPages = likeProducts.chunked(into: 20)
    }
    
    private func fetchProductViewModels(of page: [Int]) -> Observable<[ProductViewModel]> {
        let requests = Observable.from(page)
            .flatMap({ id in
                self.productRepository.fetchProductDetail(of: id) })
     
        let productViewModels = requests
            .map{ detail in
                Product(id: detail.id, vendorID: detail.vendorID, name: detail.name, thumbnail: detail.thumbnail, currency: detail.currency, price: detail.price, bargainPrice: detail.bargainPrice, discountedPrice: detail.discountedPrice, stock: detail.stock) }
            .map{ ProductViewModel(product: $0) }
            .take(page.count)
            .reduce([]) { acc, element in return acc + [element] }
            .map { array in
                array.sorted { $0.id > $1.id }
            }
            
      return productViewModels
    }
    
}
