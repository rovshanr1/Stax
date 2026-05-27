//
//  EditAccountVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 16.05.26.
//

import UIKit
import Combine

//MARK: - Diffable Data Soruce Section
nonisolated enum EditAccountSection: Int, Hashable, Sendable, CaseIterable{
    case main
    case deleteAccount
}

//MARK: - Items
nonisolated enum EditAccountItem: Hashable, Sendable{
    case navigation(id: EditAccountItemIdentity, icon: String, title: String, color: String)
    case deleteAccount(id: EditAccountItemIdentity, title: String)
}

class EditAccountVC: UIViewController {
    
    //MARK: - Diffable Datasource
    typealias DataSource = UICollectionViewDiffableDataSource<EditAccountSection, EditAccountItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<EditAccountSection, EditAccountItem>
    
    //Event Closure
    var didSentEventClosure: ((EditAccountEvent) -> Void)?
    
    //ViewModel and Conten View
    private var viewModel: EditAccountVM
    private let contentView = EditAccountView()
    
    //Private Properties
    private var cancellables: Set<AnyCancellable> = []
    private var dataSource: DataSource!
    
    init(viewModel: EditAccountVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Eddit Account"
        
        configurationDataSourcre()
        bindViewModel()
    }
    
    override func loadView() {
        self.view = contentView
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        
        if parent == nil{
            didSentEventClosure?(.dismiss)
        }
    }
    
    deinit{
     print("EditAccount deinited")
    }
  
    
    //MARK: - Bind ViewModel
    private func bindViewModel(){
        
        viewModel.output.editAccountData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.updateSnapshot(with: data)
            }
            .store(in: &cancellables)
        
        viewModel.input.viewDidLoad.send()
            
    }
    
    //MARK: - DiffiableDataSource Configuration
    private func configurationDataSourcre(){
        contentView.collectionView.delegate = self
        
        let mainCellRegistraition = UICollectionView.CellRegistration<GlobalListCell, EditAccountItem>{ cell, _, item in
            
            if case .navigation(id: _, icon: let icon, title: let title, color: let color) = item{
                let iconColor = UIColor(hex: color) ?? .systemBlue
                cell.configureiconListCell(title: title,
                                           icon: icon,
                                           iconColor: iconColor,
                                           showChevron: true, showSwitch: false)
            }
            
        }
        
        let deleteAccountRegistration = UICollectionView.CellRegistration<DestructiveCell, EditAccountItem>{ cell, _, item in
            
            if case .deleteAccount(_, let title) = item{
                cell.configureLabel(title: title)
            }
        }
        
        dataSource = DataSource(collectionView: contentView.collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
          
            switch item {
            case .navigation:
                return collectionView.dequeueConfiguredReusableCell(using: mainCellRegistraition, for: indexPath, item: item)
            case .deleteAccount:
                return collectionView.dequeueConfiguredReusableCell(using: deleteAccountRegistration, for: indexPath, item: item)
            }
        })
    }
    
    private func updateSnapshot(with items: [(EditAccountSection, [EditAccountItem])]) {
        var snapshot = Snapshot()
        
        for (section, items) in items {
            snapshot.appendSections([section])
            snapshot.appendItems(items, toSection: section)
                     
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension EditAccountVC: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let tappedItem = dataSource.itemIdentifier(for: indexPath) else{
            return
        }
          
        viewModel.input.itemTapped.send(tappedItem)
    }
}
