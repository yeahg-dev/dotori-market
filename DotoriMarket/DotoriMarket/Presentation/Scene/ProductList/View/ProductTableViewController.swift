//
//  ProductTableViewController.swift
//  DotoriMarket
//
//  Created by 예거 on 2022/01/12.
//

import UIKit

import RxSwift
import RxCocoa

final class ProductTableViewController: UITableViewController {
    
    // MARK: - UI Property
    
    private let loadingIndicator = UIActivityIndicatorView()
    
    // MARK: - Property
    
    private var coordinator: ProductListCoordinator?
    
    private let disposeBag = DisposeBag()
    private let viewModel: ProductListSceneViewModel
    
    // MARK: - Initializer
    
    init?(viewModel: ProductListSceneViewModel,
          coordinator: ProductListCoordinator,
          coder: NSCoder) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.tableView.dataSource = nil
        self.configureLoadingIndicator()
        self.configureRefreshControl()
        self.configureTableViewLayout()
        self.bindViewModel()
    }
    
    // MARK: - binding
    
    private func bindViewModel() {
        guard let refreshControl = self.tableView.refreshControl else {
            return
        }
        
        let input = ProductListSceneViewModel.Input(
            viewWillAppear: self.rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:)))
                .map{ _ in },
            willDisplayCellAtIndex: self.tableView.rx.willDisplayCell.map{ $1 },
            listViewDidStartRefresh: refreshControl.rx.controlEvent(.valueChanged).asObservable(),
            cellDidSelectedAt: self.tableView.rx.itemSelected.asObservable())
        let output = self.viewModel.transform(input: input)
        
        output.navigationBarComponent
            .drive(onNext: {[weak self] component in
                self?.confiureNavigationItem(with: component) })
            .disposed(by: disposeBag)
        
        output.willStartLoadingIndicator
            .drive{ [weak self] _ in
                self?.loadingIndicator.startAnimating() }
            .disposed(by: disposeBag)
        
        output.willEndLoadingIndicator
            .drive{ [weak self] _ in
                self?.loadingIndicator.stopAnimating() }
            .disposed(by: disposeBag)
        
        output.products
            .drive(tableView.rx.items(cellIdentifier: "ProductTableViewCell",
                                      cellType: ProductTableViewCell.self))
        { (_, element, cell) in
            cell.fillContent(of: element) }
        .disposed(by: disposeBag)
        
        output.networkErrorAlert
            .drive{ [weak self] viewModel in
                self?.presentNetworkErrorAlert(viewModel: viewModel) }
            .disposed(by: disposeBag)
        
        output.listViewWillEndRefresh
            .drive(onNext: { [weak self] _ in
                self?.tableView?.refreshControl?.endRefreshing() })
            .disposed(by: disposeBag)
        
        output.pushProductDetailView
            .drive{ [weak self] productID in
                self?.coordinator?.cellDidTapped(of: productID) }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Configure UI
    
    private func configureLoadingIndicator() {
        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            loadingIndicator.centerYAnchor.constraint(
                equalTo: safeArea.centerYAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor)
        ])
    }
    
    private func configureRefreshControl() {
        self.tableView.refreshControl = UIRefreshControl()
    }
    
    private func confiureNavigationItem(
        with navigationBarComponent: NavigationBarComponentViewModel)
    {
        let toggleViewModeButton = UIBarButtonItem(
            image: UIImage(systemName: navigationBarComponent.rightBarButtonImageSystemName),
            style: .plain,
            target: self,
            action: #selector(toggleViewMode))
        self.navigationItem.setRightBarButton(toggleViewModeButton, animated: false)
        
        self.navigationItem.title = navigationBarComponent.title
    }
    
    @objc func toggleViewMode() {
        coordinator?.rightNavigationItemDidTapped(from: self)
    }
    
    private func configureTableViewLayout() {
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.separatorStyle = .none
    }
    
    // MARK: - Present Alert
    
    private func presentNetworkErrorAlert(viewModel: AlertViewModel) {
        let alert = UIAlertController(title: viewModel.title, message: viewModel.message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: viewModel.actionTitle, style: .default)
        alert.addAction(okAction)
        self.present(alert, animated: false)
    }
    
}

// MARK: - UIGestureRecognizerDelegate

extension ProductTableViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
    -> Bool
    {
        return false
    }
}
