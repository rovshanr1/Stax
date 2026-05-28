//
//  EditAccountVM.swift
//  Stax
//
//  Created by Rovshan Rasulov on 16.05.26.
//

import Foundation
import Combine

nonisolated enum EditAccountItemIdentity: Sendable{
    case changeUserName
    case changePassword
    case changeEmail
    case deleteAccount
}

final class EditAccountVM {
    
    struct Input {
        let viewDidLoad: PassthroughSubject<Void, Never>
        let itemTapped: PassthroughSubject<EditAccountItem, Never>
    }
    
    struct Output {
        let editAccountData: CurrentValueSubject<[(EditAccountSection, [EditAccountItem])], Never>
        let itemsOnTapped: PassthroughSubject<EditAccountEvent, Never>

    }
    
    let input: Input
    let output: Output
    
    //Services&Managers
    private let userManager: UserManager

    
    private var cancellables: Set<AnyCancellable> = []
    
    init(userManager: UserManager) {
        self.userManager = userManager
        self.input = .init(
            viewDidLoad: .init(),
            itemTapped: .init(),
           
        )
        
        
        self.output = .init(
            editAccountData: .init([]),
            itemsOnTapped: .init(),
           
      
        )
        
        transform()
    }
    
    private func transform() {
        input.viewDidLoad
            .sink { [weak self] in
                self?.buildEditAccountData()
            }
            .store(in: &cancellables)
        
        input.itemTapped
            .sink { [weak self] items in
                self?.handleItemTapped(items)
            }
            .store(in: &cancellables)
    }
    
    
    //MARK: - Helpers
    private func buildEditAccountData(){
        var data: [(EditAccountSection, [EditAccountItem])] = []
        
        let main: [EditAccountItem] = [
            .navigation(id: .changeUserName, icon: "person.fill", title: "Change Username", color: "#707173"),
            .navigation(id: .changeEmail, icon: "envelope.fill", title: "Change Email", color: "#707173"),
            .navigation(id: .changePassword, icon: "lock.fill", title: "Change Password", color: "#707173")
        ]
        data.append((.main, main))
        
        let deleteAccount: [EditAccountItem] = [
            .deleteAccount(id: .deleteAccount, title: "Delete Account")
        ]
        data.append((.deleteAccount, deleteAccount))
        
        output.editAccountData.send(data)
    }
    
 
    private func handleItemTapped(_ item: EditAccountItem){
        switch item{
            
        case .navigation(id: let id, _, _, _):
            switch id{
                
            case .changeUserName:
                output.itemsOnTapped.send(.changeUsername)
            case .changePassword:
                output.itemsOnTapped.send(.changePassword)
            case .changeEmail:
                output.itemsOnTapped.send(.changeEmail)
    
            default:
                break
            }
        case .deleteAccount(id: let id, _):
            switch id{
            case .deleteAccount:
                output.itemsOnTapped.send(.deleteAccount)
            default:
                break
            }
        }
    }
}


