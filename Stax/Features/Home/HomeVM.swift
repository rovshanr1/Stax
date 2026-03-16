//
//  HomeVM.swift
//  Stax
//
//  Created by Rovshan Rasulov on 01.12.25.
//

import Foundation
import CoreData
import Combine

//MARK: -

final class HomeVM: NSObject {
    //MARK: - I/O Structs
    ///Input: "Orders" fromd the VC (Orders)
    struct Input{
        let viewDidLoad: PassthroughSubject<Void, Never>
        let deleteWorkout: PassthroughSubject<String, Never>
    }
    
    ///Output: "Data" to VC (Data Streams)
    struct Output{
        let workouts: CurrentValueSubject<[HomeWorkoutPresentationItem], Never>
    }
    
    //MARK: - Properties
    let input: Input
    let output: Output
    
    //Repositorys
    private let workoutRepo: DataRepository<Workout>

    //State
    private var frc: NSFetchedResultsController<Workout>?
    
    //Combine
    private var cancellables = Set<AnyCancellable>()
    
    init(workoutRepo: DataRepository<Workout>){
        self.workoutRepo = workoutRepo
        
        
        self.input = .init(viewDidLoad: .init(),
                           deleteWorkout: .init()
        )
        self.output = .init(workouts: .init([])
            
        )
        
        super.init()
        transform()
    }
    
    //MARK: - Transform Method
    private func transform(){
        input.viewDidLoad
            .sink { [weak self] in
                guard let self else { return }
                self.startFeatchedResultsController()
            }
            .store(in: &cancellables)
        input.deleteWorkout
            .sink { [weak self] id in
                guard let self else { return }
                self.deleteWorkout()
            }
            .store(in: &cancellables)
    }
    
    
    private func mappingFromFRC() -> [HomeWorkoutPresentationItem] {
        guard let fw = frc?.fetchedObjects as? [Workout] else {return []}
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        return fw.map { workout in
            HomeWorkoutPresentationItem(id: workout.objectID.uriRepresentation().absoluteString,
                                        title: workout.name ?? "",
                                        dateString: dateFormatter.string(from: workout.date ?? Date()),
                                        time: formatDuration(seconds: workout.duration),
                                        volume: String(workout.volume)
            )
        }
    }
    
    private func startFeatchedResultsController(){
        let sort = NSSortDescriptor(key: "date", ascending: false)
        let predicate = NSPredicate(format: "duration > 0")
        
        frc = workoutRepo.makeFetchResultsController(sortDescriptors: [sort], predicate: predicate)
        frc?.delegate = self
        
        do{
            try frc?.performFetch()
            
            let presentationItems = mappingFromFRC()
            output.workouts.send(presentationItems)
        }catch{
            print("Home FRC Error: \(error)")
        }
    }
    
    private func formatDuration(seconds: Double) -> String{
        let totalSeconds = Int(seconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours == 0{
            return String(format: "%02d:%02d", minutes, seconds)
        }else{
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
    
    private func deleteWorkout(){
        print("Delete Workout")
    }
}

//MARK: - FRC Delegate Extension
extension HomeVM: NSFetchedResultsControllerDelegate{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        output.workouts.send(mappingFromFRC())
    }
}
