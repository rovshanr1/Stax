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
        let shareWorkout: PassthroughSubject<String, Never>
    }
    
    ///Output: "Data" to VC (Data Streams)
    struct Output{
        let workouts: CurrentValueSubject<[HomeWorkoutPresentationItem], Never>
        let showShareSheet: PassthroughSubject<String, Never>
    }
    
    //MARK: - Properties
    let input: Input
    let output: Output
    
    //Repositorys & Services
    private let workoutRepo: DataRepository<Workout>
    private let shareService: WorkoutShareServiceProtocol

    //State
    private var frc: NSFetchedResultsController<Workout>?
    
    //Combine
    private var cancellables = Set<AnyCancellable>()
    
    init(workoutRepo: DataRepository<Workout>, shareService: WorkoutShareServiceProtocol){
        self.workoutRepo = workoutRepo
        self.shareService = shareService
        
        self.input = .init(viewDidLoad: .init(),
                           deleteWorkout: .init(),
                           shareWorkout: .init()
        )
        self.output = .init(workouts: .init([]),
                            showShareSheet: .init()
            
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
                self.deleteWorkout(with: id)
            }
            .store(in: &cancellables)
        input.shareWorkout
            .sink { [weak self] id  in
                guard let self else { return }
                guard let workout = self.frc?.fetchedObjects?.first(where: { $0.objectID.uriRepresentation().absoluteString == id }) else { return }
                let shareText = self.shareService.generateShareText(from: workout)
                self.output.showShareSheet.send(shareText)
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
            return String(format: "%02dmin %02dsec", minutes, seconds)
        }else{
            return String(format: "%02dh %02dmin %02dsec", hours, minutes, seconds)
        }
    }
    
    private func deleteWorkout(with id: String){
        workoutRepo.delete(by: id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    private func getShareText(for id: String) -> String{
        guard let workout = frc?.fetchedObjects?.first(where: { $0.objectID.uriRepresentation().absoluteString == id }) else { return "No Workout Found" }
        
        return shareService.generateShareText(from: workout)
    }
}

//MARK: - FRC Delegate Extension
extension HomeVM: NSFetchedResultsControllerDelegate{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        output.workouts.send(mappingFromFRC())
    }
}
