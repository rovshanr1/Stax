//
//  EditProfileVC.swift
//  Stax
//
//  Created by Rovshan Rasulov on 24.04.26.
//

import UIKit
import Combine
import PhotosUI

class EditProfileVC: UIViewController {
    
    //closures
    var didSentEventClosure: ((EditProfileEvent) -> Void)?
    
    //private properties
    private let contentView = EditProfileView()
    private let vm: EditProfileVM
    
    private var cancellables: Set<AnyCancellable> = []
    
    //MARK: - initialization
    init(vm: EditProfileVM){
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Profile"
        
        setupNavigationBar()
        bindViewModel()
        bindContentView()
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
        print("Edit Profile screen deinited")
    }
    
    
    //MARK: - Bind VM
    private func bindViewModel(){
        vm.output.isSaveEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.navigationItem.rightBarButtonItem?.isEnabled = isEnabled
            }
            .store(in: &cancellables)
        
        vm.output.saveCompleted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.didSentEventClosure?(.saveChanges)
            }
            .store(in: &cancellables)
        
        vm.output.errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let self else { return }
                AlertManager.showErrorAlert(on: self, message: message)
            }
            .store(in: &cancellables)
        
        vm.output.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.showIndicator(isLoading)
            }
            .store(in: &cancellables)
        
        vm.output.currentProfileImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.contentView.changeProfilePhoto.setDraftImage(image)
            }
            .store(in: &cancellables)
    }
    
    //MARK: - Binding ContentView
    private func bindContentView(){
        //Initial Image
        contentView.changeProfilePhoto.loadInitialImage(from: vm.initialImageURL)
        
        contentView.changeProfilePhoto.profileImageTapped = {[weak self]  in
            self?.presentImagePicker()
        }
        
        contentView.changeProfilePhoto.changeImageOnTapped = {[weak self] in
            self?.presentImagePicker()
        }
        
        //Initial NameAndBio
        contentView.changeNameandBioView.configure(vm.initialName ?? "", vm.initialBio ?? "")
        
        contentView.changeNameandBioView.onNameChanged = {[weak self] text in
            self?.vm.input.nameChanged.send(text)
        }
        
        contentView.changeNameandBioView.onBioChanged = {[weak self] text in
            self?.vm.input.bioChanged.send(text)
        }
    }
    
    //MARK: - Image Picker
    private func presentImagePicker(){
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    //MARK: - Helpers
    private func showIndicator(_ isLoading: Bool){
        if isLoading {
            LoadingManager.shared.show()
            
        } else {
            LoadingManager.shared.hide()
        }
    }
    
    
    
    //MARK: - Save Button
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.tintColor = .activeItems
        button.addTarget(self, action: #selector(handleSaveButton), for: .touchUpInside)
        return button
    }()
    
    private func setupNavigationBar() {
        let barButton = UIBarButtonItem(customView: saveButton)
        navigationItem.rightBarButtonItem = barButton
    }
    
    @objc private func handleSaveButton(){
        vm.input.saveButtonTapped.send()
    }
}

extension EditProfileVC: PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else {
            return
        }
        
        provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            guard let self = self, let uiImage = image as? UIImage else { return }
            
            guard let imageData = uiImage.jpegData(compressionQuality: 0.5) else { return }
            self.vm.input.profileItemSelected.send(imageData)
        }
    }
}
