//
//  ExerciseListVM.swift
//  Stax
//
//  Created by Rovshan Rasulov on 10.12.25.
//

import Foundation
import Combine

final class ExerciseListVM{
    //MARK: - I/O Structs
    ///Input: "Orders" fromd the VC (Orders)
    struct Input {
        let viewDidLoad: PassthroughSubject<Void, Never>
        let searchTrigger: PassthroughSubject<String, Never>
        let didSelectRow: PassthroughSubject<Int, Never>
    }
    ///Output: "Data" to VC (Data Streams)
    struct Output {
        let exerciseList: CurrentValueSubject<[Exercise], Never>
        let navigationEvent: PassthroughSubject<ExerciseListEvent, Never>
    }
    
    //MARK: - Properties
    let input: Input
    let output: Output
    
    private var cancellables: Set<AnyCancellable> = []
    private let dataRepo: DataRepository<Exercise>
    
    init(dataRepo: DataRepository<Exercise>){
        self.dataRepo = dataRepo
        
        self.input = .init(viewDidLoad: .init(),
                           searchTrigger: .init(),
                           didSelectRow: .init())
        
        self.output = .init(exerciseList: .init([]),
                            navigationEvent: .init())
        
        transform()
    }
    
    private func transform(){
        input.viewDidLoad
            .sink { [weak self] _ in
                self?.fetchExercise(with: nil)
            }
            .store(in: &cancellables)
        
        input.searchTrigger
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query  in
                guard let self else { return }
                
                if query.isEmpty {
                    self.fetchExercise(with: nil)
                }else{
                    let predicate = NSPredicate(format: "name CONTAINS[cd] %@", query)
                    self.fetchExercise(with: predicate)
                }
            }
            .store(in: &cancellables)
        
        input.didSelectRow
            .sink { [weak self] index in
                guard let self else { return }
                
                let currentList = self.output.exerciseList.value
                
                if currentList.indices.contains(index) {
                    let selectedExercise = currentList[index]
                    self.output.navigationEvent.send(.exerciseSelected(selectedExercise))
                }
            }
            .store(in: &cancellables)
    }
    //MARK: - Helper Method
    private func fetchExercise(with predicate: NSPredicate?){
        let publisher = (predicate == nil) ? dataRepo.fetchAll() : dataRepo.search(by: predicate)
        
        publisher
            .replaceError(with: [])
            .sink { [weak self] exercise in
                self?.output.exerciseList.send(exercise)
            }
            .store(in: &cancellables)
    }
}
