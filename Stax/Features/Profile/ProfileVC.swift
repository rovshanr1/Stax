//
//  ProfileVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 28.11.25.
//

import UIKit
import Combine

class ProfileVC: UIViewController {
    //MARK: - Diffable Data Source
    nonisolated enum Section: Hashable, Sendable {
        case profile
        case charts
        case workouts
    }
    
    nonisolated enum RowItem: Hashable, Sendable {
        case profileInfo(UserModel)
        case chart
        case workout
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, RowItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, RowItem>
    
    //Closures
    var didSendEventClosure: ((ProfileEvent) -> Void)?
        
    //Private properties
    private let contentView = ProfileUIView()
    private let viewModel: ProfileVM
    
    private var dataSource: DataSource!
    private var cancellables: Set<AnyCancellable> = []
    
    init(viewModel: ProfileVM) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        
        configureDataSource()
        bindViewModel()
    }
    
    override func loadView() {
        self.view = contentView
    }
    
    deinit{
        print("Deninited Profile")
    }
    
    //MARK: - DataSource Configuration
    private func configureDataSource() {
        contentView.collectionView.delegate = self
        
        let profileInfoRegistration = UICollectionView.CellRegistration<ProfileInfoCell, UserModel> { (cell, _, userModel) in
            cell.configurationCell(with: userModel)
        }
        
        
        dataSource = DataSource(collectionView: contentView.collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier{
                
            case .profileInfo(let userData):
                return collectionView.dequeueConfiguredReusableCell(using: profileInfoRegistration, for: indexPath, item: userData)
            default:
                fatalError("Unhandled case")
                
            }
        })
    }
    
    private func bindViewModel(){
        viewModel.output.userInfo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userData in
                guard let self else {return}
                guard let userData else {return}
                self.updateSnapshot(with: userData)
            }
            .store(in: &cancellables)
        
        viewModel.input.viewDidLoad.send()
    }
    
    private func updateSnapshot(with profileInfo: UserModel){
        var snapshot = Snapshot()
        
        snapshot.appendSections([.profile])
        snapshot.appendItems([.profileInfo(profileInfo)])
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension ProfileVC: UICollectionViewDelegate{
    
}
