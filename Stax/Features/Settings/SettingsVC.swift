//
//  SettingsVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 26.04.26.
//

import UIKit
import Combine

//MARK: - Diffable Data Soruce Section
nonisolated enum SettingsSection: Int, Hashable, Sendable, CaseIterable{
    case account
    case preferences
    case about
    case logout
    
    var title: String {
        switch self {
        case .account: return "Account"
        case .preferences: return "Preferences"
        case .about: return "About"
        default:
            return ""
        }
    }
}

//MARK: - Items
nonisolated enum SettingsItem: Hashable, Sendable{
    case navigation(id: String, icon: String, title: String, color: String)
    case toggle(id: String, icon: String, title: String, isOn: Bool, color: String)
    case action(id: String, icon: String, title: String)
}


class SettingsVC: UIViewController {
    //MARK: - Diffable Datasource
    typealias DataSource = UICollectionViewDiffableDataSource<SettingsSection, SettingsItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<SettingsSection, SettingsItem>
    
    //closures
    var didSentEventClosure: ((SettingsEvent) -> Void)?
    
    //private properties
    private var contentView = SettingsView()
    private let vm: SettingsVM
    private var cancellables: Set<AnyCancellable> = []
    
    private var dataSource: DataSource!
    
    
    init(vm: SettingsVM) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        
        configureDataSource()
        bindViewModel()
        
    }
    
    override func loadView() {
        self.view = contentView
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            didSentEventClosure?(.dismiss)
        }
    }
    
    deinit{
        print("Setting Deinited")
    }
    
    private func bindViewModel() {
        vm.output.logoutCompleted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                
                self?.didSentEventClosure?(.logout)
            }
            .store(in: &cancellables)
        
        vm.output.settingData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.updateSnapshot(with: data)
                
            }
            .store(in: &cancellables)
        
        vm.input.viewDidLoad.send()
        
    }
    
    //MARK: - DiffiableDataSource Configuration
    private func configureDataSource() {
        contentView.collectionView.delegate = self
        
        let cellRegistration = UICollectionView.CellRegistration<SettingsCell, SettingsItem>{ cell, _, itemIdentifier in
            
            cell.configurationSettingsCell(with: itemIdentifier)
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] supplementaryView, elementKind, indexPath in
            guard let self else { return }
            
            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            var content = UIListContentConfiguration.header()
            content.text = section.title
            
            supplementaryView.contentConfiguration = content
        }
        
        
        dataSource = DataSource(collectionView: contentView.collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
        
        dataSource.supplementaryViewProvider = {(collectionView, kind, indexPath) in
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
    }
    
    //MARK: - Snapshot configuration
    private func updateSnapshot(with data: [(SettingsSection, [SettingsItem])]) {
        var snapshot = Snapshot()
        
        for(section, items) in data{
            snapshot.appendSections([section])
            snapshot.appendItems(items, toSection: section)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
        
        
    }
}


extension SettingsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let tappedItem = dataSource.itemIdentifier(for: indexPath) else { return }
        
        vm.input.itemTapped.send(tappedItem)
    }
}
