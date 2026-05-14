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
        
        bindViewModel()
        bindingActions()
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
        
    }
    
    private func bindingActions() {
        contentView.logoutTapped = { [weak self] in
            self?.vm.input.logoutTapped.send()
        }
    }
    
}
